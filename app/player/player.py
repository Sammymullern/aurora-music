"""
MPV-based audio player with advanced features
"""

import logging
import math
import ctypes.util
import os
from pathlib import Path
from typing import Optional, Callable, List, Dict, Any

_bundled_mpv = os.environ.get("NELVA_LIBMPV", "")
_original_find_library = ctypes.util.find_library
if _bundled_mpv and Path(_bundled_mpv).is_file():
    def _find_bundled_mpv(name: str):
        if name == "mpv":
            return _bundled_mpv
        return _original_find_library(name)

    ctypes.util.find_library = _find_bundled_mpv
try:
    import mpv
finally:
    ctypes.util.find_library = _original_find_library
from PySide6.QtCore import QObject, Signal, Slot, Property, QTimer
from app.player.equalizer import DSPManager

logger = logging.getLogger(__name__)


class Player(QObject):
    """Audio player using MPV backend"""

    # Signals
    position_changed = Signal(float)  # Current playback position in seconds
    duration_changed = Signal(float)  # Track duration in seconds
    playback_state_changed = Signal(str)  # 'playing', 'paused', 'stopped'
    track_changed = Signal(str)  # Path to current track
    volume_changed = Signal(int)  # Volume level 0-100
    shuffle_changed = Signal(bool)  # Shuffle state
    repeat_changed = Signal(str)  # 'off', 'all', 'one'
    track_info_changed = Signal()  # Track metadata changed
    audioDevicesChanged = Signal()
    audioDeviceChanged = Signal(str)
    audioBufferChanged = Signal(float)
    dspStatusChanged = Signal(str)
    dsp_track_loaded = Signal()
    dsp_command_completed = Signal(str, str, object)
    auto_advance_requested = Signal(int, str)

    def __init__(self, parent: Optional[QObject] = None):
        super().__init__(parent)
        self._mpv: Optional[mpv.MPV] = None
        self._current_track: Optional[Path] = None
        self._current_track_id: str = ""
        self._current_track_favorite: bool = False
        self._volume: int = 100
        self._is_initialized: bool = False
        # Playlist items are dicts: {"id": str, "file_path": str, "title": str, "artist": str, "album": str, "album_art": str, "favorite": bool}
        self._playlist: List[Dict[str, Any]] = []
        self._current_index: int = -1
        self._stopped_index: Optional[int] = None
        self._shuffle: bool = False
        self._repeat: str = "off"  # 'off', 'all', 'one'
        self._current_title: str = ""
        self._current_artist: str = ""
        self._current_album: str = ""
        self._current_album_art: str = ""
        self._current_position: float = 0.0
        self._current_duration: float = 0.0
        self._user_paused = False
        self._track_loaded = False
        self._pending_seek_position: Optional[float] = None
        self._audio_devices = [{"name": "auto", "description": "System default"}]
        self._audio_device = "auto"
        self._audio_buffer = 0.2
        self._pending_audio_device = "auto"
        self._pending_audio_buffer = 0.2
        self.dsp_manager = DSPManager(self)
        self._dsp_graph_ready = False
        self._dsp_graph_pending = False
        self._dsp_status = "Audio processing ready"
        self._dsp_applied_parameters: Dict[str, str] = {}
        self._dsp_pending_parameters = set()
        self._dsp_applied_switches: Dict[str, bool] = {}
        self._dsp_pending_switches = set()
        self._dsp_update_timer = QTimer(self)
        self._dsp_update_timer.setSingleShot(True)
        self._dsp_update_timer.setInterval(45)
        self._dsp_update_timer.timeout.connect(self._apply_audio_filters)
        self.dsp_manager.settings_changed.connect(self._schedule_audio_filter_update)
        self.dsp_manager.equalizer.settings_changed.connect(self._schedule_audio_filter_update)
        self.dsp_command_completed.connect(self._on_dsp_command_completed)
        self.dsp_track_loaded.connect(self._on_dsp_track_loaded)
        self.auto_advance_requested.connect(self._on_auto_advance_requested)

        self._advancing: bool = False
        self._eof_watchdog_counter: int = 0
        self._last_load_mono: int = 0
        self._last_played_position: float = 0.0
        self._playback_proven_active: bool = False
        self._proven_active_load_mono: int = -1
        self._load_time_ms: int = 0
        self._stale_end_flag_cleared: bool = False
        
        self._update_timer = QTimer(self)
        self._update_timer.setInterval(100)
        self._update_timer.timeout.connect(self._update_position_duration)
        
        self._initialize_mpv()
    
    def _initialize_mpv(self) -> None:
        """Initialize MPV player with settings"""
        try:
            self._mpv = mpv.MPV(
                audio_format="float",
                audio_wait_open=0,
                vo="null",
                video_sync="audio",
                gapless_audio=True,
                keep_open="yes",
                idle=True,
                log_handler=self._on_mpv_log,
                loglevel="warn",
            )

            @self._mpv.event_callback("end-file")
            def _on_end_file(event):
                try:
                    load_generation = self._last_load_mono
                    reason_raw = self._get_mpv_end_file_reason(event)
                    is_eof = False
                    try:
                        if isinstance(reason_raw, int):
                            is_eof = (reason_raw == 0)
                        elif isinstance(reason_raw, str):
                            is_eof = (reason_raw == "eof")
                        else:
                            try:
                                is_eof = str(reason_raw).lower() in ("eof", "0")
                            except Exception:
                                is_eof = False
                    except Exception:
                        is_eof = False

                    if is_eof:
                        load_age_ms = 0
                        try:
                            from PySide6.QtCore import QDateTime
                            now_ms = QDateTime.currentMSecsSinceEpoch()
                            load_age_ms = max(0, int(now_ms) - int(getattr(self, "_load_time_ms", 0)))
                        except Exception:
                            load_age_ms = 0
                        proven = (
                            getattr(self, "_playback_proven_active", False)
                            and getattr(self, "_proven_active_load_mono", -1) == getattr(self, "_last_load_mono", 0)
                            and getattr(self, "_current_index", -1) >= 0
                        )
                        if (proven or load_age_ms > 800) and not self._user_paused:
                            logger.info(
                                f"MPV end-file (reason={reason_raw!r}) -> auto-advance "
                                f"(load_age={load_age_ms}ms, proven={proven}, "
                                f"playlist={len(self._playlist)} tracks, index={self._current_index}, "
                                f"repeat={self._repeat}, shuffle={self._shuffle})"
                            )
                            # MPV invokes event callbacks on its own thread. Queue
                            # playlist and Qt state changes onto the Player thread.
                            self.auto_advance_requested.emit(load_generation, "end-file-event")
                        elif self._user_paused:
                            logger.info("MPV reached EOF while user-paused; suppressing auto-advance")
                        else:
                            logger.info(
                                f"MPV end-file (reason={reason_raw!r}) SUSPENDED "
                                f"(load_age={load_age_ms}ms, proven={proven}) "
                                f"- watchdog will advance when safe"
                            )
                    else:
                        logger.debug(
                            f"MPV end-file (reason={reason_raw!r}) - not EOF, ignoring"
                        )
                except Exception as e:
                    logger.error(f"Error in end-file handler: {e}", exc_info=True)

            @self._mpv.event_callback("file-loaded")
            def _on_file_loaded(_event):
                self._track_loaded = True
                self._apply_pending_audio_settings()
                self._apply_pending_seek()
                self.dsp_track_loaded.emit()

            @self._mpv.event_callback("playback-restart")
            def _on_playback_restart(_event):
                self._apply_pending_seek()

            self._is_initialized = True
            self._install_audio_filter_graph()
            self.refreshAudioDevices()
            logger.info("MPV player initialized successfully")

        except Exception as e:
            logger.error(f"Failed to initialize MPV: {e}")
            self._is_initialized = False

    @staticmethod
    def _get_mpv_end_file_reason(event):
        """Read the end reason from python-mpv's MpvEvent payload."""
        reason = getattr(event, "reason", None)
        if reason is not None:
            return reason
        try:
            event_data = event.data
        except (AttributeError, ValueError, TypeError):
            return None
        return getattr(event_data, "reason", None)

    def _install_audio_filter_graph(self) -> None:
        """Install one labeled filter graph without replacing other MPV filters."""
        if not self._is_initialized or not self._mpv or self._dsp_graph_pending:
            return
        self._dsp_graph_pending = True
        self._queue_dsp_command(
            "install", "",
            "af", "add", self.dsp_manager.get_mpv_audio_filters(),
        )

    def _queue_dsp_command(self, key: str, value: str, *args: str) -> None:
        try:
            future = self._mpv.command_async(*args)
            future.add_done_callback(
                lambda completed, op=key, val=value: self.dsp_command_completed.emit(op, val, completed)
            )
        except Exception as exc:
            self._handle_dsp_command_error(key, exc)

    def _on_dsp_command_completed(self, key: str, value: str, future) -> None:
        try:
            future.result()
        except Exception as exc:
            self._handle_dsp_command_error(key, exc)
            return

        if key == "install":
            self._dsp_graph_pending = False
            self._dsp_graph_ready = True
            self._dsp_applied_parameters.clear()
            self._set_dsp_status("Audio processing active")
            self._schedule_audio_filter_update()
        elif key.startswith("switch:"):
            switch = key.partition(":")[2]
            self._dsp_pending_switches.discard(switch)
            self._dsp_applied_switches[switch] = value == "on"
            if self._dsp_current_value(key) != value:
                self._schedule_audio_filter_update()
        else:
            self._dsp_pending_parameters.discard(key)
            self._dsp_applied_parameters[key] = value
            if self._dsp_current_value(key) != value:
                self._schedule_audio_filter_update()
            else:
                self._set_dsp_status("Audio processing active")

    def _handle_dsp_command_error(self, key: str, error: Exception) -> None:
        if key == "install":
            self._dsp_graph_pending = False
        elif key.startswith("switch:"):
            self._dsp_pending_switches.discard(key.partition(":")[2])
        else:
            self._dsp_pending_parameters.discard(key)
        logger.error("MPV audio processing command failed (%s): %s", key, error)
        self._set_dsp_status("An audio effect could not be applied")

    def _set_dsp_status(self, status: str) -> None:
        if self._dsp_status != status:
            self._dsp_status = status
            self.dspStatusChanged.emit(status)

    def get_dsp_status(self) -> str:
        return self._dsp_status

    def _schedule_audio_filter_update(self) -> None:
        if not self._is_initialized or not self._mpv:
            return
        if not self._dsp_graph_ready:
            self._install_audio_filter_graph()
            return
        if self._track_loaded:
            self._dsp_update_timer.start()

    def _on_dsp_track_loaded(self) -> None:
        # MPV can reconstruct its audio chain at every file load. Restore the
        # current values through runtime commands without replacing the graph.
        self._dsp_applied_parameters.clear()
        self._schedule_audio_filter_update()

    def _dsp_current_parameters(self) -> Dict[str, str]:
        parameters = self.dsp_manager.equalizer.runtime_parameters()
        parameters.update(self.dsp_manager.runtime_parameters())
        return parameters

    def _dsp_current_value(self, key: str) -> Optional[str]:
        if key == "spatial" or key.startswith("switch:"):
            switch = key.partition(":")[2] if key.startswith("switch:") else key
            value = self.dsp_manager.runtime_switches().get(switch, False)
            return "on" if value else "off"
        return self._dsp_current_parameters().get(key)

    def _apply_audio_filters(self) -> None:
        """Push only changed values to named filters, asynchronously."""
        if not self._is_initialized or not self._mpv or not self._dsp_graph_ready or not self._track_loaded:
            return
        commands = {
            "preamp": ("volume", "volume@preamp"),
            "bass": ("gain", "bass@bass"),
            "treble": ("gain", "treble@treble"),
            "vocal": ("gain", "equalizer@vocal"),
            "stereo": ("m", "extrastereo@stereo"),
        }
        for frequency in self.dsp_manager.equalizer.FREQUENCY_BANDS:
            commands[f"band_{frequency}"] = ("gain", f"equalizer@eq{frequency}")

        for key, value in self._dsp_current_parameters().items():
            if self._dsp_applied_parameters.get(key) == value or key in self._dsp_pending_parameters:
                continue
            command, target = commands[key]
            self._dsp_pending_parameters.add(key)
            self._queue_dsp_command(
                key, value, "af-command", "nelva_dsp", command, value, target
            )

        for switch, enabled in self.dsp_manager.runtime_switches().items():
            if self._dsp_applied_switches.get(switch, False) == enabled or switch in self._dsp_pending_switches:
                continue
            operation = "switch:" + switch
            self._dsp_pending_switches.add(switch)
            self._queue_dsp_command(
                operation,
                "on" if enabled else "off",
                "af", "toggle", "@nelva_" + switch,
            )

    def _on_mpv_log(self, level: str, component: str, message: str) -> None:
        if level in ("error", "fatal"):
            logger.error("mpv [%s] %s", component, message)
            if any(token in f"{component} {message}".lower() for token in ("audio", "filter", "lavfi", "af")):
                self._set_dsp_status("MPV rejected an audio filter")
        elif level == "warn":
            logger.warning("mpv [%s] %s", component, message)

    dspStatus = Property(str, get_dsp_status, notify=dspStatusChanged)

    @Slot(int, str)
    def _on_auto_advance_requested(self, load_generation: int, source: str) -> None:
        # A watchdog or manual action may already have loaded another track
        # while this queued MPV event was waiting for the GUI thread.
        if load_generation != self._last_load_mono or self._user_paused:
            return
        self._do_auto_advance(source=source)

    def _do_auto_advance(self, source: str = "unknown") -> bool:
        """Attempt to advance to the next track, guarding against double-fires.

        Respects repeat modes:
        - repeat='one': replay current track
        - repeat='all': wrap playlist around
        - repeat='off': advance if not at end; stop cleanly at playlist end
        """
        if self._advancing:
            logger.debug(f"Auto-advance ({source}): already advancing, skipping")
            return False
        if not self._is_initialized or not self._mpv:
            return False

        self._advancing = True
        try:
            # Repeat-one: always re-play current (restart) if we have a valid index
            if self._repeat == "one" and self._current_index >= 0:
                logger.info(f"Auto-advance ({source}): repeat-one -> restart current")
                return self._restart_current()

            # No playlist available
            if not self._playlist:
                logger.warning(f"Auto-advance ({source}): no playlist, stopping")
                self.stop_playback()
                return False

            advance_ok = self.next_track()
            if advance_ok:
                logger.info(f"Auto-advance ({source}): next_track succeeded")
                return True
            else:
                logger.info(
                    f"Auto-advance ({source}): next_track returned False "
                    f"(end of playlist with repeat-off) - stopping cleanly"
                )
                self.stop_playback()
                return False
        finally:
            QTimer.singleShot(250, self._clear_advancing)

    def _clear_advancing(self) -> None:
        """Release the auto-advance guard after a cool-down period."""
        self._advancing = False

    
    def _update_position_duration(self) -> None:
        """Poll MPV for position/duration + safe EOF-watchdog fallback.

        NEW GUARDS vs the previous aggressive version
        ----------------------------------------------
        1. ``_playback_proven_active`` is only set to True when we have seen a
           playback position of >=0.25s *and* the position has advanced since
           the last poll. This filters out the very common case where MPV's
           ``end`` / ``eof_reached`` / ``idle_active`` flags briefly carry over
           from a previous track while the new track is still buffering.

        2. ``_last_load_mono`` is incremented every time a fresh track is
           loaded. We capture a snapshot of it *when playback was last
           proven active*; if load generation no longer matches at EOF-check
           time, we simply do not advance.

        3. ``at_eof`` by itself is never enough to advance. Even when dur is
           known, we require *at least 5 consecutive 100ms hits* where we are
           also in a stopped/idle state before the watchdog calls
           auto-advance. For most cases the native ``end-file`` event fires
           first.

        4. The watchdog fast-path (triggered by MPV's ended/eof/idle flags)
           still applies ONLY when playback has been proven active at least
           once during this track lifetime. Otherwise those flags are treated
           as stale/early and ignored.
        """
        if not self._is_initialized or not self._mpv:
            return

        try:
            prev_pos = self._current_position
            pos = self._mpv.time_pos
            if pos is not None and pos != self._current_position:
                self._current_position = pos
                self.position_changed.emit(pos)

            duration = self._mpv.duration
            if duration is not None and duration != self._current_duration:
                self._current_duration = duration
                self.duration_changed.emit(duration)

            # --- Prove playback is actually progressing ---
            # Need to see *some* progress, but keep the threshold small so that
            # even short ~0.6s clips can satisfy it before they naturally end.
            if pos is not None and pos > 0.15 and (
                pos > self._last_played_position + 0.02 or prev_pos != self._current_position
            ):
                self._last_played_position = pos
                self._playback_proven_active = True
                self._proven_active_load_mono = self._last_load_mono

            dur = self._current_duration
            pos_now = self._current_position
            near_end_by_fraction = False
            near_end_abs = False
            at_eof = False
            if dur and dur > 0 and pos_now is not None:
                near_end_abs = (dur - pos_now) <= 0.6
                near_end_by_fraction = pos_now >= (dur * 0.55)
                at_eof = (dur - pos_now) <= 0.3 or pos_now >= (dur - 0.15)

            # Critical guard: NEVER consider mpv's end/eof_reached/idle_active as
            # sufficient EOF proof on their own. These flags often stay sticky from
            # the previous track while the new file is still establishing playback,
            # causing the watchdog to skip songs. Instead, those flags are only
            # treated as a *secondary* confirmation after we've proven the current
            # file is actually close to its documented duration (by fraction and
            # absolute time-left).
            mpv_eof = False
            mpv_ended = False
            mpv_idle = False
            try:
                raw_eof = getattr(self._mpv, "eof_reached", None)
                if raw_eof is not None:
                    mpv_eof = bool(raw_eof)
                raw_end = getattr(self._mpv, "end", None)
                if raw_end is not None:
                    mpv_ended = bool(raw_end)
                raw_idle = getattr(self._mpv, "idle_active", None)
                if raw_idle is not None:
                    mpv_idle = bool(raw_idle)
                if not mpv_idle:
                    raw_coreidle = getattr(self._mpv, "core_idle", None)
                    if raw_coreidle is not None:
                        mpv_idle = bool(raw_coreidle)
            except Exception:
                pass
            mpv_ended_flags = (mpv_eof or mpv_ended or mpv_idle)

            # --- STALE FLAG RECOVERY ---
            # MPV's internal end/eof/idle flags are NOT reliably cleared right
            # after loading a new file; they often stick True from the
            # PREVIOUS track for 300-800ms, which used to cause the watchdog
            # to immediately skip to the next song (rapid-skip bug).
            # If we can see playback has actually started moving (proven_active
            # or position past 150ms), duration is known, AND we're clearly
            # before the final half — but mpv's end-flags still say True —
            # then those flags are 100% stale. Invalidate them for this cycle
            # AND force a property-write to prompt MPV's property engine to
            # refresh its state. We only do this clear once per load to avoid
            # ping-ponging on legitimately-stopped playback.
            clearly_not_at_end = (
                dur is not None and dur > 0.5
                and pos_now is not None
                and pos_now < dur * 0.45
            )
            playback_has_begun = (
                (self._playback_proven_active
                 and self._proven_active_load_mono == self._last_load_mono)
                or (pos_now is not None and pos_now > 0.15 and dur and pos_now < dur)
            )
            if (
                mpv_ended_flags
                and playback_has_begun
                and clearly_not_at_end
                and not getattr(self, "_stale_end_flag_cleared", False)
            ):
                logger.info(
                    f"Stale MPV end-flags detected (pos={pos_now:.3f}/{dur:.3f}, "
                    f"eof={mpv_eof}, ended={mpv_ended}, idle={mpv_idle}); "
                    f"forcing a state refresh."
                )
                self._stale_end_flag_cleared = True
                try:
                    # Write a property we know is current; this triggers MPV
                    # property-system updates and generally knocks the internal
                    # end/eof/idle booleans back in sync with the actual file.
                    self._mpv.pause = bool(self._mpv.pause)
                except Exception:
                    pass
                try:
                    # Alternative: force a property refresh via seek(0) of 0.0s
                    # We only do this for non-critical first-hit case, so noop:
                    pass
                except Exception:
                    pass
                # For this iteration override: those flags are invalid, don't
                # trust them for EOF detection.
                mpv_eof = False
                mpv_ended = False
                mpv_idle = False
                mpv_ended_flags = False

            mpv_paused = True
            try:
                raw_p = getattr(self._mpv, "pause", None)
                if raw_p is not None:
                    mpv_paused = bool(raw_p)
            except Exception:
                mpv_paused = True

            # A user pause is an explicit request to hold the current track,
            # even when its playhead is close to the duration. Let playback
            # reach EOF after the user resumes it.
            if self._user_paused:
                self._eof_watchdog_counter = 0
                return

            track_was_loaded = (
                bool(self._current_track)
                or (self._current_title and len(self._current_title) > 0)
                or self._current_index >= 0
            )

            now_ms = 0
            try:
                from PySide6.QtCore import QDateTime
                now_ms = int(QDateTime.currentMSecsSinceEpoch())
            except Exception:
                now_ms = 0
            load_age_ms = max(0, now_ms - int(self._load_time_ms)) if self._load_time_ms else 0

            # Absolute hard floor: never allow watchdog to advance within first 350ms
            # of loading a new track.
            hard_gate_open = load_age_ms >= 350

            safe_to_advance = (
                hard_gate_open
                and self._playback_proven_active
                and self._proven_active_load_mono == self._last_load_mono
                and self._current_index >= 0
            )

            # New stricter readiness rules:
            #  A. Duration-based EOF path (gold standard):
            #       (pos >= 55% of dur OR <= 0.6s left)
            #       AND (mpv says it's paused OR we are within final 300ms/end of dur)
            #       + debounce hits
            #  B. End-file catch-up:
            #       mpv reports ended/idle flags, BUT ONLY IF we are also past
            #       55% of duration AND 55% of the LOADED track has been proven
            #       via playback progress (the watchdog's "near_end" guard).
            #
            #  Without duration (dur unknown), do NOT trust the mpv flags alone
            #  since they give false positives for tiny/clipped files.

            dur_ok_for_stopped = (dur is not None and dur > 0 and near_end_by_fraction and near_end_abs)

            # --- Debounce counting ---
            # Count consecutive polls where EOF *conditions* hold, regardless
            # of whether we're "ready" yet. The ready_to_advance thresholds
            # then reference this counter. This ordering is critical: a
            # chicken-and-egg bug existed previously where we incremented
            # the counter *after* testing ready_to_advance (which already
            # required counter >= N), so the counter never moved from 0.
            debounce_key = None
            if track_was_loaded and safe_to_advance and at_eof and (mpv_ended_flags or mpv_paused):
                debounce_key = "at_eof_stopped_or_paused_2hit"
            elif track_was_loaded and safe_to_advance and dur_ok_for_stopped and mpv_ended_flags:
                debounce_key = "dur_ok_ended_3hit"
            elif (
                track_was_loaded
                and safe_to_advance
                and dur is not None
                and dur > 0
                and at_eof
            ):
                debounce_key = "at_eof_6or2hit"

            if debounce_key is not None:
                self._eof_watchdog_counter += 1
            else:
                self._eof_watchdog_counter = 0

            ready_to_advance = False
            if debounce_key == "at_eof_stopped_or_paused_2hit":
                ready_to_advance = self._eof_watchdog_counter >= 2
            elif debounce_key == "dur_ok_ended_3hit":
                ready_to_advance = self._eof_watchdog_counter >= 3
            elif debounce_key == "at_eof_6or2hit":
                if mpv_paused or mpv_ended_flags:
                    ready_to_advance = self._eof_watchdog_counter >= 2
                else:
                    ready_to_advance = self._eof_watchdog_counter >= 6

            if ready_to_advance:
                logger.info(
                    f"EOF watchdog fired via {debounce_key} (pos={pos_now}/{dur}, at_eof={at_eof}, "
                    f"near_frac={near_end_by_fraction}, near_abs={near_end_abs}, "
                    f"eof={mpv_eof}, ended={mpv_ended}, idle={mpv_idle}, paused={mpv_paused}, "
                    f"load_age={load_age_ms}ms, safe={safe_to_advance}, "
                    f"load_mono={self._proven_active_load_mono}/{self._last_load_mono}, "
                    f"hits={self._eof_watchdog_counter}) -> auto-advance"
                )
                self._eof_watchdog_counter = 0
                self._do_auto_advance(source="watchdog")
        except Exception as e:
            logger.debug(f"Error in position/duration poll: {e}")


    
    def load_track(self, track_path: str | Path, title: str = "", artist: str = "", album: str = "", album_art: str = "", track_id: str = "", favorite: bool = False, auto_play: bool = False) -> bool:
        """Load a track for playback"""
        if not self._is_initialized:
            logger.error("Player not initialized")
            return False

        try:
            track_path = Path(track_path)
            if not track_path.exists():
                logger.error(f"Track not found: {track_path}")
                return False

            self._advancing = False
            self._eof_watchdog_counter = 0
            self._stopped_index = None
            self._last_load_mono += 1
            self._last_played_position = 0.0
            self._playback_proven_active = False
            self._proven_active_load_mono = -1
            self._stale_end_flag_cleared = False
            from PySide6.QtCore import QDateTime
            self._load_time_ms = int(QDateTime.currentMSecsSinceEpoch())
            self._current_track = track_path
            self._track_loaded = False
            self._pending_seek_position = None
            self._current_title = title
            self._current_artist = artist
            self._current_album = album
            self._current_album_art = album_art
            self._current_track_id = str(track_id) if track_id != "" else ""
            self._current_track_favorite = bool(favorite)
            self._current_position = 0.0
            self._current_duration = 0.0

            # Do NOT call self._mpv.stop() before loading! stop() triggers the
            # exact same end-file/eof_reached/ended=true flag transition that
            # caused the rapid-skip bug, and python-mpv/python binding don't
            # always clear those flags synchronously before the next play().
            # Instead, rely on loadfile ("replace" semantics) plus the
            # watchdog's stale-flag detection to recover from any carry-over.
            try:
                self._mpv.play(str(track_path))
            except Exception as play_exc:
                logger.warning(f"MPV.play raised on load: {play_exc}")
            if auto_play:
                self._user_paused = False
                try:
                    self._mpv.pause = False
                except Exception:
                    pass
                self.playback_state_changed.emit("playing")
            else:
                self._user_paused = True
                try:
                    self._mpv.pause = True
                except Exception:
                    pass

            self._update_timer.start()

            self.track_changed.emit(str(track_path))
            self.track_info_changed.emit()

            logger.info(f"Loaded track: {track_path} (auto_play={auto_play})")
            return True

        except Exception as e:
            logger.error(f"Failed to load track: {e}")
            return False
    
    def play(self) -> bool:
        """Start or resume playback"""
        if not self._is_initialized:
            return False

        if self._current_track is None:
            index = self._stopped_index
            if index is None or not 0 <= index < len(self._playlist):
                return False
            if not self._play_at_index(index, auto_play=True):
                return False
            self._stopped_index = None
            self._user_paused = False
            return True
        
        try:
            self._mpv.pause = False
            self._user_paused = False
            self.playback_state_changed.emit("playing")
            logger.debug("Playback started")
            return True
        except Exception as e:
            logger.error(f"Failed to play: {e}")
            return False
    
    def pause(self) -> bool:
        """Pause playback"""
        if not self._is_initialized:
            return False
        
        try:
            self._mpv.pause = True
            self._user_paused = True
            self.playback_state_changed.emit("paused")
            logger.debug("Playback paused")
            return True
        except Exception as e:
            logger.error(f"Failed to pause: {e}")
            return False
    
    def stop_playback(self) -> bool:
        """Stop playback and clear current track info so UI reflects stopped state"""
        if not self._is_initialized:
            return False

        try:
            self._advancing = False
            self._user_paused = True
            self._eof_watchdog_counter = 0
            self._update_timer.stop()
            if 0 <= self._current_index < len(self._playlist):
                self._stopped_index = self._current_index
            self._current_index = -1
            try:
                self._mpv.pause = True
                self._mpv.stop()
            except Exception:
                pass
            self._current_track = None
            self._track_loaded = False
            self._pending_seek_position = None
            self._current_track_id = ""
            self._current_track_favorite = False
            self._current_title = ""
            self._current_artist = ""
            self._current_album = ""
            self._current_album_art = ""
            self._current_position = 0.0
            self._current_duration = 0.0
            self.position_changed.emit(0.0)
            self.duration_changed.emit(0.0)
            self.track_changed.emit("")
            self.track_info_changed.emit()
            self.playback_state_changed.emit("stopped")
            logger.debug("Playback stopped")
            return True
        except Exception as e:
            logger.error(f"Failed to stop: {e}")
            return False
    
    def seek(self, position: float) -> bool:
        """Seek to position in seconds"""
        if not self._is_initialized or not self._current_track:
            return False
        try:
            position = float(position)
        except (TypeError, ValueError):
            return False
        if not math.isfinite(position):
            return False
        position = max(0.0, position)
        duration = self.get_duration()
        if duration > 0:
            position = min(position, duration)
        if not self._track_loaded:
            # Session restore and early slider input can arrive before mpv has
            # opened the new file. Keep only the latest requested position.
            self._pending_seek_position = position
            return True
        try:
            self._mpv.seek(position, reference="absolute")
            self._pending_seek_position = None
            logger.debug(f"Seeked to {position}s")
            return True
        except Exception as e:
            self._pending_seek_position = position
            logger.debug("Seek is not ready yet; will retry after mpv playback restarts: %s", e)
            return False

    def _apply_pending_seek(self) -> None:
        if self._track_loaded and self._pending_seek_position is not None:
            self.seek(self._pending_seek_position)
    
    def set_volume(self, volume: int) -> bool:
        """Set volume (0-100)"""
        if not self._is_initialized:
            return False
        
        try:
            volume = max(0, min(100, volume))
            self._volume = volume
            self._mpv.volume = volume
            self.volume_changed.emit(volume)
            logger.debug(f"Volume set to {volume}")
            return True
        except Exception as e:
            logger.error(f"Failed to set volume: {e}")
            return False
    
    def get_volume(self) -> int:
        """Get current volume"""
        return self._volume
    
    def get_position(self) -> float:
        """Get current playback position in seconds"""
        if not self._is_initialized:
            return 0.0
        return self._mpv.time_pos or 0.0
    
    def get_duration(self) -> float:
        """Get current track duration in seconds"""
        if not self._is_initialized:
            return 0.0
        return self._mpv.duration or 0.0
    
    def is_playing(self) -> bool:
        """Check if currently playing"""
        if not self._is_initialized:
            return False
        return not self._mpv.pause
    
    def get_current_track(self) -> Optional[Path]:
        """Get current track path"""
        return self._current_track
    
    # QML-exposed methods with Slot decorator
    @Slot()
    def playPause(self) -> None:
        """Toggle play/pause"""
        if self.is_playing():
            self.pause()
        else:
            self.play()
    
    @Slot()
    def stop(self) -> bool:
        """Stop playback"""
        return self.stop_playback()
    
    @Slot()
    def next(self) -> bool:
        """Play next track"""
        return self.next_track()
    
    @Slot()
    def previous(self) -> bool:
        """Play previous track"""
        return self.previous_track()
    
    @Slot()
    def toggleShuffle(self) -> None:
        """Toggle shuffle mode"""
        self.toggle_shuffle()
    
    @Slot()
    def toggleRepeat(self) -> None:
        """Toggle repeat mode"""
        self.toggle_repeat()
    
    @Slot(float)
    def seekTo(self, position: float) -> bool:
        """Seek to position (0.0 to 1.0)"""
        if not self._is_initialized:
            return False
        duration = self.get_duration()
        if duration > 0:
            return self.seek(position * duration)
        return False
    
    @Slot(int)
    def setVolume(self, volume: int) -> bool:
        """Set volume (0-100)"""
        return self.set_volume(volume)
    
    # Properties for QML binding
    def get_isPlaying(self) -> bool:
        return self.is_playing()

    def get_isPaused(self) -> bool:
        return not self.is_playing()

    def get_currentPosition(self) -> float:
        return self.get_position()

    def get_currentDuration(self) -> float:
        return self.get_duration()

    def get_currentVolume(self) -> int:
        return self.get_volume()

    def get_isShuffle(self) -> bool:
        return self.get_shuffle()

    def get_repeatMode(self) -> str:
        return self.get_repeat()

    def get_currentTitle(self) -> str:
        return self._current_title

    def get_currentDisplayTitle(self) -> str:
        if self._current_title:
            return self._current_title
        return self._current_track.stem if self._current_track else ""

    def get_hasCurrentTrack(self) -> bool:
        return self._current_track is not None

    def get_currentArtist(self) -> str:
        return self._current_artist

    def get_currentAlbum(self) -> str:
        return self._current_album

    def get_currentAlbumArt(self) -> str:
        return self._current_album_art

    def get_currentTrackId(self) -> str:
        return self._current_track_id

    def get_currentTrackFavorite(self) -> bool:
        return self._current_track_favorite

    @Slot(bool)
    def set_currentTrackFavorite(self, fav: bool) -> None:
        """Update the currently-playing favorite flag (called from manager after DB save)."""
        if self._current_track_favorite != bool(fav):
            self._current_track_favorite = bool(fav)
            self.track_info_changed.emit()
            # If it exists in the active playlist, sync its cached favorite too
            if 0 <= self._current_index < len(self._playlist):
                self._playlist[self._current_index]["favorite"] = bool(fav)

    isPlaying = Property(bool, get_isPlaying, notify=playback_state_changed)
    isPaused = Property(bool, get_isPaused, notify=playback_state_changed)
    currentPosition = Property(float, get_currentPosition, notify=position_changed)
    currentDuration = Property(float, get_currentDuration, notify=duration_changed)
    currentVolume = Property(int, get_currentVolume, notify=volume_changed)
    isShuffle = Property(bool, get_isShuffle, notify=shuffle_changed)
    repeatMode = Property(str, get_repeatMode, notify=repeat_changed)
    currentTitle = Property(str, get_currentTitle, notify=track_info_changed)
    currentDisplayTitle = Property(str, get_currentDisplayTitle, notify=track_info_changed)
    hasCurrentTrack = Property(bool, get_hasCurrentTrack, notify=track_info_changed)
    currentArtist = Property(str, get_currentArtist, notify=track_info_changed)
    currentAlbum = Property(str, get_currentAlbum, notify=track_info_changed)
    currentAlbumArt = Property(str, get_currentAlbumArt, notify=track_info_changed)
    currentTrackId = Property(str, get_currentTrackId, notify=track_info_changed)
    currentTrackFavorite = Property(bool, get_currentTrackFavorite, notify=track_info_changed)

    def get_audio_devices(self):
        return self._audio_devices

    def get_audio_device(self):
        return self._audio_device

    def get_audio_buffer(self):
        return self._audio_buffer

    audioDevices = Property("QVariantList", get_audio_devices, notify=audioDevicesChanged)
    audioDevice = Property(str, get_audio_device, notify=audioDeviceChanged)
    audioBuffer = Property(float, get_audio_buffer, notify=audioBufferChanged)

    @Slot()
    def refreshAudioDevices(self):
        devices = [{"name": "auto", "description": "System default"}]
        if self._is_initialized:
            try:
                for device in self._mpv.get_property("audio-device-list") or []:
                    name = str(device.get("name", ""))
                    if name and name != "auto":
                        devices.append({
                            "name": name,
                            "description": str(device.get("description") or name),
                        })
            except Exception as exc:
                logger.debug("Could not query MPV audio devices: %s", exc)
        self._audio_devices = devices
        self.audioDevicesChanged.emit()

    def _apply_pending_audio_settings(self) -> None:
        """Apply settings when mpv has initialized its audio output properties."""
        if not self._is_initialized or not self._mpv:
            return
        try:
            self._mpv.set_property("audio-device", self._pending_audio_device)
            self._audio_device = self._pending_audio_device
            self.audioDeviceChanged.emit(self._audio_device)
        except Exception as exc:
            logger.debug("MPV audio device will remain pending until an output is available: %s", exc)
        try:
            self._mpv.set_property("audio-buffer", self._pending_audio_buffer)
            self._audio_buffer = self._pending_audio_buffer
            self.audioBufferChanged.emit(self._audio_buffer)
        except Exception as exc:
            logger.debug("MPV audio buffer will remain pending until an output is available: %s", exc)
        self.refreshAudioDevices()

    @Slot(str, result=bool)
    def setAudioDevice(self, name: str) -> bool:
        if not self._is_initialized or not name:
            return False
        self._pending_audio_device = name
        self._apply_pending_audio_settings()
        return True

    @Slot(float, result=bool)
    def setAudioBuffer(self, seconds: float) -> bool:
        seconds = max(0.05, min(2.0, float(seconds)))
        if not self._is_initialized:
            return False
        self._pending_audio_buffer = seconds
        self._apply_pending_audio_settings()
        return True

    @staticmethod
    def _normalize_playlist_item(item: Any) -> Dict[str, Any]:
        """Normalize a playlist item (can be path string, Path, or dict) to a dict.

        Preserves id and favorite when provided by MusicManager so player bar heart button
        can identify and toggle the favorite state on the correct DB track.
        """
        if isinstance(item, dict):
            raw_id = item.get("id", "")
            return {
                "id": str(raw_id) if raw_id not in (None, "") else "",
                "file_path": str(item.get("file_path", item.get("path", ""))),
                "title": str(item.get("title", "")),
                "artist": str(item.get("artist", "Unknown")),
                "album": str(item.get("album", "Unknown")),
                "album_art": str(item.get("album_art", item.get("artwork_path", ""))),
                "favorite": bool(item.get("favorite", False)),
            }
        # String or Path: only file path is known
        file_path = str(item)
        file_name = Path(file_path).stem if file_path else ""
        return {
            "id": "",
            "file_path": file_path,
            "title": file_name,
            "artist": "Unknown",
            "album": "Unknown",
            "album_art": "",
            "favorite": False,
        }

    def set_playlist(self, tracks: List[Any]) -> None:
        """Set the playlist. Accepts list of paths or list of song dicts with metadata."""
        self._playlist = [self._normalize_playlist_item(t) for t in tracks]
        self._current_index = -1
        self._stopped_index = None
        logger.info(f"Playlist set with {len(self._playlist)} tracks")

    @Slot("QVariantList", int, result=bool)
    def playPlaylist(self, tracks: List[Any], index: int = 0) -> bool:
        """Load a QML playlist and start at the requested track."""
        self.set_playlist(tracks)
        return self._play_at_index(index, auto_play=True)

    def get_session_state(self) -> Dict[str, Any]:
        return {
            "playlist": self._playlist,
            "index": self._current_index,
            "position": self.get_position(),
            "shuffle": self._shuffle,
            "repeat": self._repeat,
        }

    def restore_session(self, state: Dict[str, Any]) -> bool:
        tracks = [
            item for item in state.get("playlist", [])
            if isinstance(item, dict) and Path(item.get("file_path", "")).is_file()
        ]
        if not tracks:
            return False
        self._shuffle = bool(state.get("shuffle", False))
        repeat = state.get("repeat", "off")
        self._repeat = repeat if repeat in {"off", "all", "one"} else "off"
        self.set_playlist(tracks)
        index = int(state.get("index", 0))
        index = max(0, min(index, len(tracks) - 1))
        if not self._play_at_index(index, auto_play=False):
            return False
        position = max(0.0, float(state.get("position", 0.0)))
        if position:
            self.seek(position)
        self.shuffle_changed.emit(self._shuffle)
        self.repeat_changed.emit(self._repeat)
        return True

    def get_current_index(self) -> int:
        """Get current playlist index"""
        return self._current_index

    def set_current_index(self, index: int) -> None:
        """Set current playlist index (for example after playSong sets the playlist)"""
        if self._playlist and 0 <= index < len(self._playlist):
            self._current_index = index
            logger.debug(f"Current playlist index set to {index}")
    
    def _play_at_index(self, index: int, auto_play: bool = True) -> bool:
        """Play playlist entry at given index using its stored metadata + id/favorite"""
        if 0 <= index < len(self._playlist):
            item = self._playlist[index]
            previous_index = self._current_index
            self._current_index = index
            loaded = self.load_track(
                item["file_path"],
                title=item.get("title", ""),
                artist=item.get("artist", ""),
                album=item.get("album", ""),
                album_art=item.get("album_art", ""),
                track_id=item.get("id", ""),
                favorite=bool(item.get("favorite", False)),
                auto_play=auto_play,
            )
            if not loaded:
                self._current_index = previous_index
            return loaded
        return False

    def _restart_current(self) -> bool:
        """Re-play the current track from the beginning.

        Goes through the standard ``_play_at_index`` path so that all state
        (advancing guard, watchdog counter, position poll timer, and the
        ``track_changed`` / ``track_info_changed`` signals) is reset the same
        way as for any other track load. This avoids edge cases where the MPV
        ``end`` / ``idle`` flags linger after a natural EOF, and ensures the
        UI (waveform, progress, title bindings) properly reflects the restart.
        """
        if self._current_index < 0 or self._current_index >= len(self._playlist):
            return False
        return self._play_at_index(self._current_index, auto_play=True)

    def next_track(self) -> bool:
        """Play next track in playlist, respecting repeat modes"""
        if not self._playlist:
            logger.warning("No playlist set")
            return False

        cursor = self._current_index
        if not 0 <= cursor < len(self._playlist):
            cursor = self._stopped_index if self._stopped_index is not None else -1

        # Repeat one: re-play the current track from the beginning
        if self._repeat == "one" and cursor >= 0:
            logger.info("Repeat-one: restarting current track")
            self._current_index = cursor
            return self._play_at_index(cursor, auto_play=True)

        if self._shuffle:
            import random
            candidates = [index for index in range(len(self._playlist)) if index != cursor]
            if candidates:
                self._current_index = random.choice(candidates)
            else:
                self._current_index = 0
        else:
            new_index = cursor + 1
            # Repeat all: wrap around. Off: stop at the end
            if self._repeat == "all":
                self._current_index = new_index % len(self._playlist)
            else:
                if new_index >= len(self._playlist):
                    logger.info("End of playlist (repeat off)")
                    return False
                self._current_index = new_index

        return self._play_at_index(self._current_index, auto_play=True)

    def previous_track(self) -> bool:
        """Play previous track in playlist"""
        if not self._playlist:
            logger.warning("No playlist set")
            return False

        cursor = self._current_index
        if not 0 <= cursor < len(self._playlist):
            cursor = self._stopped_index if self._stopped_index is not None else -1
        if cursor < 0:
            return False

        # Repeat one: restart current track (standard behavior)
        if self._repeat == "one":
            logger.info("Repeat-one (prev): restarting current track")
            self._current_index = cursor
            return self._play_at_index(cursor, auto_play=True)

        self._current_index = (cursor - 1) % len(self._playlist)
        return self._play_at_index(self._current_index, auto_play=True)
    
    def toggle_shuffle(self) -> None:
        """Toggle shuffle mode"""
        self._shuffle = not self._shuffle
        self.shuffle_changed.emit(self._shuffle)
        logger.info(f"Shuffle: {self._shuffle}")
    
    def toggle_repeat(self) -> None:
        """Cycle through repeat modes: off -> all -> one -> off"""
        modes = ["off", "all", "one"]
        current_index = modes.index(self._repeat)
        self._repeat = modes[(current_index + 1) % len(modes)]
        self.repeat_changed.emit(self._repeat)
        logger.info(f"Repeat: {self._repeat}")
    
    def get_shuffle(self) -> bool:
        """Get shuffle state"""
        return self._shuffle
    
    def get_repeat(self) -> str:
        """Get repeat mode"""
        return self._repeat
    
    def cleanup(self) -> None:
        """Clean up resources"""
        self._update_timer.stop()
        self._dsp_update_timer.stop()
        if self._mpv:
            self._mpv.terminate()
            self._mpv = None
        self._is_initialized = False
        logger.info("Player cleaned up")
