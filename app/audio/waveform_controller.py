"""Asynchronous waveform extraction for the currently loaded audio track."""

from __future__ import annotations

import logging
import threading
from collections import OrderedDict
from pathlib import Path
from typing import List, Optional, Tuple

from PySide6.QtCore import QObject, Property, QRunnable, QThreadPool, Signal, Slot

logger = logging.getLogger(__name__)


class _WaveformSignals(QObject):
    finished = Signal(int, str, object, str)


class _WaveformJob(QRunnable):
    def __init__(self, token: int, path: str, cancel_event: threading.Event):
        super().__init__()
        self.token = token
        self.path = path
        self.cancel_event = cancel_event
        self.signals = _WaveformSignals()

    def run(self) -> None:
        try:
            samples = _decode_waveform(self.path, self.cancel_event)
            self.signals.finished.emit(self.token, self.path, samples, "")
        except Exception as exc:
            self.signals.finished.emit(self.token, self.path, [], str(exc))


def _decode_waveform(path: str, cancel_event: threading.Event, bin_count: int = 256) -> List[float]:
    """Read real PCM in bounded chunks and return a normalized peak envelope."""
    import numpy as np
    import soundfile as sf

    info = sf.info(path)
    if info.frames <= 0:
        return []

    peaks = np.zeros(bin_count, dtype=np.float32)
    frame_cursor = 0
    block_frames = 65536

    with sf.SoundFile(path) as source:
        while frame_cursor < info.frames:
            if cancel_event.is_set():
                return []
            audio = source.read(block_frames, dtype="float32", always_2d=True)
            if audio.size == 0:
                break

            sample_peaks = np.max(np.abs(audio), axis=1)
            frame_end = frame_cursor + len(sample_peaks)
            bins = np.arange(frame_cursor, frame_end, dtype=np.int64) * bin_count // info.frames
            np.maximum.at(peaks, np.minimum(bins, bin_count - 1), sample_peaks)
            frame_cursor = frame_end

    peak_max = float(np.max(peaks))
    if peak_max <= 1e-8:
        return [0.035] * bin_count

    # A light three-bin smoothing keeps adjacent peaks readable while retaining
    # the track's actual loud and quiet sections.
    padded = np.pad(peaks, (1, 1), mode="edge")
    smoothed = (padded[:-2] + 2 * padded[1:-1] + padded[2:]) * 0.25
    normalized = np.sqrt(np.clip(smoothed / peak_max, 0.0, 1.0))
    return [round(0.035 + float(value) * 0.965, 4) for value in normalized]


class WaveformController(QObject):
    """Loads and caches a track waveform without blocking playback or the GUI."""

    waveform_changed = Signal()

    def __init__(self, parent: Optional[QObject] = None):
        super().__init__(parent)
        self._path = ""
        self._waveform: List[float] = []
        self._loading = False
        self._error = ""
        self._token = 0
        self._cancel_event: Optional[threading.Event] = None
        self._jobs: dict[int, _WaveformJob] = {}
        self._cache: OrderedDict[Tuple[str, int, int], List[float]] = OrderedDict()
        self._cache_limit = 8

    @Slot(str)
    def load(self, path: str) -> None:
        path = str(path or "").strip()
        if path == self._path and (self._loading or self._waveform):
            return
        self._token += 1
        token = self._token
        if self._cancel_event is not None:
            self._cancel_event.set()
            self._cancel_event = None

        self._path = path
        self._waveform = []
        self._error = ""
        self._loading = False
        if not path:
            self.waveform_changed.emit()
            return

        try:
            source = Path(path)
            stat = source.stat()
            cache_key = (str(source.resolve()), stat.st_mtime_ns, stat.st_size)
        except OSError as exc:
            self._error = str(exc)
            self.waveform_changed.emit()
            return

        cached = self._cache.get(cache_key)
        if cached is not None:
            self._cache.move_to_end(cache_key)
            self._waveform = cached
            self.waveform_changed.emit()
            return

        self._loading = True
        cancel_event = threading.Event()
        self._cancel_event = cancel_event
        job = _WaveformJob(token, path, cancel_event)
        job.signals.finished.connect(self._on_finished)
        self._jobs[token] = job
        self.waveform_changed.emit()
        QThreadPool.globalInstance().start(job)

    @Slot(int, str, object, str)
    def _on_finished(self, token: int, path: str, samples, error: str) -> None:
        self._jobs.pop(token, None)
        if token != self._token or path != self._path:
            return

        self._loading = False
        self._cancel_event = None
        self._error = error
        self._waveform = list(samples) if not error else []
        if self._waveform:
            try:
                source = Path(path)
                stat = source.stat()
                key = (str(source.resolve()), stat.st_mtime_ns, stat.st_size)
                self._cache[key] = self._waveform
                self._cache.move_to_end(key)
                while len(self._cache) > self._cache_limit:
                    self._cache.popitem(last=False)
            except OSError:
                pass
        if error:
            logger.warning("Could not analyze waveform for %s: %s", path, error)
        self.waveform_changed.emit()

    def cancel(self) -> None:
        self._token += 1
        if self._cancel_event is not None:
            self._cancel_event.set()
            self._cancel_event = None
        self._loading = False

    def get_waveform_data(self) -> List[float]:
        return self._waveform

    def get_loading(self) -> bool:
        return self._loading

    def get_error(self) -> str:
        return self._error

    def get_path(self) -> str:
        return self._path

    waveformData = Property("QVariantList", get_waveform_data, notify=waveform_changed)
    isLoading = Property(bool, get_loading, notify=waveform_changed)
    error = Property(str, get_error, notify=waveform_changed)
    path = Property(str, get_path, notify=waveform_changed)
