"""Audio playback components.

Keep importing the queue and equalizer usable when the optional MPV binding is
not installed. The playback backend itself is loaded only when requested.
"""

__all__ = ["Player"]


def __getattr__(name):
    if name == "Player":
        from app.player.player import Player

        return Player
    raise AttributeError(f"module {__name__!r} has no attribute {name!r}")
