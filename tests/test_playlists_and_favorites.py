from pathlib import Path

from app.database.models import PlaylistTrack, Track
from app.database.session import db
from app.library.music_manager import MusicManager
from app.library.playlist import PlaylistManager
from app.library.watcher import LibraryEventHandler


def test_playlists_and_favorites_stay_in_sync(tmp_path):
    db.close()
    db.initialize(tmp_path / "library.db")
    session = db.get_session()
    try:
        tracks = [
            Track(
                file_path=str(tmp_path / f"track-{index}.mp3"),
                file_name=f"track-{index}.mp3",
                file_size=10,
                format="mp3",
                title=f"Track {index}",
            )
            for index in range(2)
        ]
        session.add_all(tracks)
        session.commit()
        track_ids = [track.id for track in tracks]

        playlists = PlaylistManager(session)
        playlist = playlists.create_playlist(" Mix ", "Road songs")
        assert playlist is not None
        assert playlist.name == "Mix"
        assert playlists.add_track_to_playlist(playlist.id, track_ids[0])
        assert not playlists.add_track_to_playlist(playlist.id, track_ids[0])
        assert playlists.add_track_to_playlist(playlist.id, track_ids[1])
        assert playlists.move_track_in_playlist(playlist.id, track_ids[1], 1)
        assert [track.id for track in playlists.get_playlist_tracks(playlist.id)] == [track_ids[1], track_ids[0]]

        manager = MusicManager()
        assert manager.toggleFavorite(str(track_ids[0]))
        assert manager.isFavorite(str(track_ids[0]))
        assert playlists.get_playlist_tracks(playlist.id)[1].favorite is True
        manager.setFilter("favorites")
        assert [song["id"] for song in manager.songs] == [track_ids[0]]

        duplicate = playlists.duplicate_playlist(playlist.id)
        assert duplicate is not None
        assert len(playlists.get_playlist_tracks(duplicate.id)) == 2

        LibraryEventHandler()._remove_track(Path(tracks[1].file_path))
        assert [track.id for track in playlists.get_playlist_tracks(playlist.id)] == [track_ids[0]]
        assert [track.id for track in playlists.get_playlist_tracks(duplicate.id)] == [track_ids[0]]

        links = session.query(PlaylistTrack).all()
        assert sorted(link.position for link in links) == [1, 1]
        assert playlists.delete_playlist(playlist.id)
    finally:
        session.close()
        db.close()
