import math
from datetime import datetime, timedelta

from app.database.models import Track
from app.database.session import db
from app.library.music_manager import MusicManager


def test_track_duration_format_drops_fractional_seconds():
    assert MusicManager.format_track_duration(182.95) == "3:02"
    assert MusicManager.format_track_duration(3661.8) == "1:01:01"
    assert MusicManager.format_track_duration(0) == "0:00"
    assert MusicManager.format_track_duration(-2) == "0:00"
    assert MusicManager.format_track_duration(math.nan) == "0:00"
    assert MusicManager.format_track_duration("not a duration") == "0:00"


def test_total_library_duration_uses_compact_human_units():
    assert MusicManager._format_duration(36) == "36 sec"
    assert MusicManager._format_duration(125.9) == "2 min"
    assert MusicManager._format_duration(3665.9) == "1h 1m"
    assert MusicManager._format_duration(math.inf) == "0 min"


def test_music_sort_options_update_song_order(tmp_path):
    db.close()
    db.initialize(tmp_path / "library.db")
    session = db.get_session()
    try:
        base = datetime.now() - timedelta(days=2)
        tracks = [
            Track(file_path=f"{tmp_path}/a.mp3", file_name="a.mp3", file_size=10, format="mp3", title="Alpha", play_count=2, added_at=base),
            Track(file_path=f"{tmp_path}/b.mp3", file_name="b.mp3", file_size=10, format="mp3", title="Bravo", play_count=9, added_at=base + timedelta(days=1)),
            Track(file_path=f"{tmp_path}/c.mp3", file_name="c.mp3", file_size=10, format="mp3", title="Charlie", play_count=5, added_at=base + timedelta(days=2)),
        ]
        session.add_all(tracks)
        session.commit()

        manager = MusicManager()
        assert [song["title"] for song in manager.songs] == ["Alpha", "Bravo", "Charlie"]
        assert manager.songs[0]["album_artist"] == "Unknown"
        assert "sample_rate" in manager.songs[0]["metadata"]
        manager.setSortOrder("Z-A")
        assert [song["title"] for song in manager.songs] == ["Charlie", "Bravo", "Alpha"]
        manager.setSortOrder("Most Played")
        assert [song["title"] for song in manager.songs] == ["Bravo", "Charlie", "Alpha"]
        manager.setSortOrder("Recently Added")
        assert [song["title"] for song in manager.songs] == ["Charlie", "Bravo", "Alpha"]
        manager.setSortOrder("A-Z")
        manager.setFilter("recently_added")
        assert [song["title"] for song in manager.songs] == ["Charlie", "Bravo", "Alpha"]
    finally:
        session.close()
        db.close()
