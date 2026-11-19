from pathlib import Path

from app.database.models import Playlist, PlaylistTrack, Track
from app.database.session import db
from app.settings.settings_manager import SettingsManager, _LibraryTask


def test_audio_and_theme_settings_persist(tmp_path, monkeypatch):
    monkeypatch.setattr(Path, "home", lambda: tmp_path)

    settings = SettingsManager()
    assert settings.theme == "Light"
    settings.theme = "Aurora"
    settings.outputDevice = "alsa/device-1"
    settings.audioBuffer = 0.735

    reloaded = SettingsManager()
    assert reloaded.theme == "Aurora"
    assert reloaded.outputDevice == "alsa/device-1"
    assert reloaded.audioBuffer == 0.73


def test_clean_missing_tracks_removes_playlist_links(tmp_path):
    db.close()
    db.initialize(tmp_path / "library.db")
    try:
        session = db.get_session()
        playlist = Playlist(name="Favorites")
        track = Track(
            file_path=str(tmp_path / "deleted.flac"),
            file_name="deleted.flac",
            file_size=0,
            format="flac",
            title="Deleted track",
        )
        session.add_all([playlist, track])
        session.flush()
        session.add(PlaylistTrack(playlist_id=playlist.id, track_id=track.id, position=0))
        session.commit()
        session.close()

        result = []
        task = _LibraryTask("clean", [])
        task.signals.finished.connect(lambda operation, status: result.append((operation, status)))
        task.run()

        session = db.get_session()
        assert session.query(Track).count() == 0
        assert session.query(PlaylistTrack).count() == 0
        session.close()
        assert result and result[0][0] == "clean"
        assert "Removed 1 missing tracks" in result[0][1]
    finally:
        db.close()
