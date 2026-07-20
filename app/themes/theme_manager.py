"""
Theme manager for Aurora Music
"""

import logging
from pathlib import Path
from typing import Dict, Optional
from enum import Enum
from dataclasses import dataclass

from PySide6.QtCore import QObject, Signal
from PySide6.QtGui import QColor, QPalette

logger = logging.getLogger(__name__)


class ThemeName(Enum):
    """Available themes"""
    DARK = "dark"
    LIGHT = "light"
    MIDNIGHT = "midnight"
    AURORA = "aurora"


@dataclass
class ThemeColors:
    """Color scheme for a theme"""
    # Primary colors
    primary: str
    primary_light: str
    primary_dark: str
    
    # Background colors
    background: str
    background_dark: str
    background_light: str
    
    # Surface colors
    surface: str
    surface_variant: str
    
    # Text colors
    text_primary: str
    text_secondary: str
    text_disabled: str
    
    # Accent colors
    accent: str
    accent_secondary: str
    
    # Border colors
    border: str
    border_light: str
    
    # Glass effect
    glass: str
    glass_border: str
    glass_opacity: float


class ThemeManager(QObject):
    """Manager for application themes"""
    
    # Signals
    theme_changed = Signal(str)
    
    # Theme definitions
    THEMES = {
        ThemeName.DARK: ThemeColors(
            primary="#7c3aed",
            primary_light="#a78bfa",
            primary_dark="#5b21b6",
            background="#1a1a2e",
            background_dark="#16162b",
            background_light="#252542",
            surface="#252542",
            surface_variant="#2a2a52",
            text_primary="#e0e0e0",
            text_secondary="#a0a0a0",
            text_disabled="#606060",
            accent="#7c3aed",
            accent_secondary="#3b82f6",
            border="#3a3a5c",
            border_light="#4a4a6c",
            glass="#252542",
            glass_border="#3a3a5c",
            glass_opacity=0.7
        ),
        ThemeName.LIGHT: ThemeColors(
            primary="#7c3aed",
            primary_light="#a78bfa",
            primary_dark="#5b21b6",
            background="#ffffff",
            background_dark="#f5f5f5",
            background_light="#e8e8e8",
            surface="#f5f5f5",
            surface_variant="#e8e8e8",
            text_primary="#1a1a1a",
            text_secondary="#606060",
            text_disabled="#a0a0a0",
            accent="#7c3aed",
            accent_secondary="#3b82f6",
            border="#d0d0d0",
            border_light="#e0e0e0",
            glass="#f5f5f5",
            glass_border="#d0d0d0",
            glass_opacity=0.8
        ),
        ThemeName.MIDNIGHT: ThemeColors(
            primary="#8b5cf6",
            primary_light="#a78bfa",
            primary_dark="#6d28d9",
            background="#0f0f1a",
            background_dark="#0a0a12",
            background_light="#1a1a2e",
            surface="#1a1a2e",
            surface_variant="#252542",
            text_primary="#f0f0f0",
            text_secondary="#b0b0b0",
            text_disabled="#707070",
            accent="#8b5cf6",
            accent_secondary="#ec4899",
            border="#2a2a4a",
            border_light="#3a3a5a",
            glass="#1a1a2e",
            glass_border="#2a2a4a",
            glass_opacity=0.6
        ),
        ThemeName.AURORA: ThemeColors(
            primary="#ec4899",
            primary_light="#f472b6",
            primary_dark="#be185d",
            background="#1a1a2e",
            background_dark="#16162b",
            background_light="#252542",
            surface="#252542",
            surface_variant="#2a2a52",
            text_primary="#e0e0e0",
            text_secondary="#a0a0a0",
            text_disabled="#606060",
            accent="#ec4899",
            accent_secondary="#8b5cf6",
            border="#3a3a5c",
            border_light="#4a4a6c",
            glass="#252542",
            glass_border="#3a3a5c",
            glass_opacity=0.7
        )
    }
    
    def __init__(self, parent: Optional[QObject] = None):
        super().__init__(parent)
        self._current_theme = ThemeName.DARK
        self._custom_themes: Dict[str, ThemeColors] = {}
    
    def set_theme(self, theme: ThemeName) -> bool:
        """Set the current theme"""
        if theme in self.THEMES:
            self._current_theme = theme
            self.theme_changed.emit(theme.value)
            logger.info(f"Theme changed to: {theme.value}")
            return True
        return False
    
    def get_current_theme(self) -> ThemeName:
        """Get the current theme"""
        return self._current_theme
    
    def get_colors(self) -> ThemeColors:
        """Get colors for the current theme"""
        return self.THEMES[self._current_theme]
    
    def get_color(self, color_name: str) -> str:
        """Get a specific color from the current theme"""
        colors = self.get_colors()
        return getattr(colors, color_name, "#000000")
    
    def add_custom_theme(self, name: str, colors: ThemeColors) -> bool:
        """Add a custom theme"""
        if name not in self.THEMES and name not in self._custom_themes:
            self._custom_themes[name] = colors
            logger.info(f"Added custom theme: {name}")
            return True
        return False
    
    def get_qml_theme_string(self) -> str:
        """Generate QML theme string"""
        colors = self.get_colors()
        return f"""
        property color primary: "{colors.primary}"
        property color primaryLight: "{colors.primary_light}"
        property color primaryDark: "{colors.primary_dark}"
        property color background: "{colors.background}"
        property color backgroundDark: "{colors.background_dark}"
        property color backgroundLight: "{colors.background_light}"
        property color surface: "{colors.surface}"
        property color surfaceVariant: "{colors.surface_variant}"
        property color textPrimary: "{colors.text_primary}"
        property color textSecondary: "{colors.text_secondary}"
        property color textDisabled: "{colors.text_disabled}"
        property color accent: "{colors.accent}"
        property color accentSecondary: "{colors.accent_secondary}"
        property color border: "{colors.border}"
        property color borderLight: "{colors.border_light}"
        property color glass: "{colors.glass}"
        property color glassBorder: "{colors.glass_border}"
        property real glassOpacity: {colors.glass_opacity}
        """
