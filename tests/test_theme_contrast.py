from PySide6.QtGui import QColor

from app.themes.theme_manager import ThemeManager


def _luminance(value):
    color = QColor(value)
    channels = [color.redF(), color.greenF(), color.blueF()]
    linear = [c / 12.92 if c <= 0.04045 else ((c + 0.055) / 1.055) ** 2.4 for c in channels]
    return sum(channel * weight for channel, weight in zip(linear, (0.2126, 0.7152, 0.0722)))


def _contrast(foreground, background):
    light, dark = sorted((_luminance(foreground), _luminance(background)), reverse=True)
    return (light + 0.05) / (dark + 0.05)


def test_all_theme_text_colors_are_readable_on_background_and_surface():
    for name, colors in ThemeManager.THEMES.items():
        for text_color in (colors.text_primary, colors.text_secondary, colors.text_disabled):
            assert _contrast(text_color, colors.background) >= 4.5, name.value
            assert _contrast(text_color, colors.surface) >= 4.5, name.value
