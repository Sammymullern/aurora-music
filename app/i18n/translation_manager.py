"""
Translation Manager for Aurora Music
Handles internationalization (i18n) and language switching
"""
import os
from pathlib import Path
from PySide6.QtCore import QObject, Signal, QTranslator, QLocale, Property
from PySide6.QtWidgets import QApplication


class TranslationManager(QObject):
    """Manages application translations"""
    
    languageChanged = Signal()
    
    def __init__(self):
        super().__init__()
        self._translator = QTranslator()
        self._current_language = "English"
        self._translations_dir = Path(__file__).parent / "translations"
        self._translations_dir.mkdir(parents=True, exist_ok=True)
        
        # Language code mapping
        self._language_codes = {
            "English": "en_US",
            "Spanish": "es_ES",
            "French": "fr_FR",
            "German": "de_DE",
            "Japanese": "ja_JP"
        }
    
    def get_current_language(self):
        return self._current_language
    
    def get_empty_string(self):
        """Empty property to force QML binding updates"""
        return ""
    
    currentLanguage = Property(str, get_current_language, notify=languageChanged)
    emptyString = Property(str, get_empty_string, notify=languageChanged)
    
    def set_language(self, language_name):
        """Set application language"""
        if language_name not in self._language_codes:
            return
        
        self._current_language = language_name
        language_code = self._language_codes[language_name]
        
        # Remove old translator
        app = QApplication.instance()
        if app:
            app.removeTranslator(self._translator)
        
        # Load new translator
        translation_file = self._translations_dir / f"aurora_{language_code}.qm"
        
        if translation_file.exists():
            if self._translator.load(str(translation_file)):
                app = QApplication.instance()
                if app:
                    app.installTranslator(self._translator)
        
        self.languageChanged.emit()
    
    def get_language_code(self, language_name):
        """Get Qt locale code for language name"""
        return self._language_codes.get(language_name, "en_US")
    
    def get_available_languages(self):
        """Get list of available languages"""
        return list(self._language_codes.keys())
