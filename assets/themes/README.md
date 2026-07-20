# Theme Assets

This directory contains theme assets for Aurora Music.

## Theme Structure

Each theme should include:
- `colors.json`: Color palette definition
- `styles.qss`: Qt stylesheet (optional)
- `qml/`: QML theme files
- `fonts/`: Custom fonts (optional)

## Color Palette Format

```json
{
  "name": "Theme Name",
  "colors": {
    "primary": "#7c3aed",
    "background": "#1a1a2e",
    "surface": "#252542",
    "text": "#e0e0e0",
    ...
  }
}
```

## Default Themes

- **Dark**: Default dark theme
- **Light**: Light theme variant
- **Midnight**: Deep dark theme
- **Aurora**: Vibrant gradient theme

## Adding Custom Themes

1. Create a new directory with the theme name
2. Add a `colors.json` file with the color palette
3. Optional: Add custom QML stylesheets
4. Register the theme in `app/themes/theme_manager.py`
