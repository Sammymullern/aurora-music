"""
Plugin system for Aurora Music
"""

from app.plugins.manager import PluginManager
from app.plugins.base import Plugin, PluginInfo

__all__ = ["PluginManager", "Plugin", "PluginInfo"]
