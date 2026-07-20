"""
Automatic library monitoring using watchdog
"""

import logging
from pathlib import Path
from typing import Callable, Optional, Set

from watchdog.observers import Observer
from watchdog.events import FileSystemEventHandler, FileSystemEvent

from app.database.session import db
from app.library.scanner import LibraryScanner

logger = logging.getLogger(__name__)


class LibraryEventHandler(FileSystemEventHandler):
    """File system event handler for library changes"""
    
    def __init__(self, scanner: LibraryScanner, callback: Optional[Callable] = None):
        super().__init__()
        self.scanner = scanner
        self.callback = callback
        self._pending_files: Set[Path] = set()
    
    def on_created(self, event: FileSystemEvent) -> None:
        """Handle file creation"""
        if not event.is_directory:
            file_path = Path(event.src_path)
            if MetadataExtractor.is_supported(file_path):
                logger.debug(f"File created: {file_path}")
                self._pending_files.add(file_path)
                self._schedule_processing()
    
    def on_modified(self, event: FileSystemEvent) -> None:
        """Handle file modification"""
        if not event.is_directory:
            file_path = Path(event.src_path)
            if MetadataExtractor.is_supported(file_path):
                logger.debug(f"File modified: {file_path}")
                self._pending_files.add(file_path)
                self._schedule_processing()
    
    def on_deleted(self, event: FileSystemEvent) -> None:
        """Handle file deletion"""
        if not event.is_directory:
            file_path = Path(event.src_path)
            logger.debug(f"File deleted: {file_path}")
            self._remove_track(file_path)
    
    def on_moved(self, event: FileSystemEvent) -> None:
        """Handle file move/rename"""
        if not event.is_directory:
            old_path = Path(event.src_path)
            new_path = Path(event.dest_path)
            logger.debug(f"File moved: {old_path} -> {new_path}")
            self._update_track_path(old_path, new_path)
    
    def _schedule_processing(self) -> None:
        """Schedule processing of pending files"""
        # In a real implementation, this would use a timer/debouncer
        # For now, process immediately
        self._process_pending()
    
    def _process_pending(self) -> None:
        """Process all pending files"""
        if not self._pending_files:
            return
        
        session = db.get_session()
        try:
            scanner = LibraryScanner(session)
            for file_path in list(self._pending_files):
                try:
                    scanner._process_file(file_path)
                except Exception as e:
                    logger.error(f"Error processing {file_path}: {e}")
                finally:
                    self._pending_files.discard(file_path)
            
            session.commit()
            
            if self.callback:
                self.callback()
                
        except Exception as e:
            logger.error(f"Error processing pending files: {e}")
            session.rollback()
        finally:
            session.close()
    
    def _remove_track(self, file_path: Path) -> None:
        """Remove track from database"""
        session = db.get_session()
        try:
            track = session.query(Track).filter_by(file_path=str(file_path)).first()
            if track:
                session.delete(track)
                session.commit()
                logger.info(f"Removed track: {file_path}")
                
                if self.callback:
                    self.callback()
        except Exception as e:
            logger.error(f"Error removing track: {e}")
            session.rollback()
        finally:
            session.close()
    
    def _update_track_path(self, old_path: Path, new_path: Path) -> None:
        """Update track path in database"""
        session = db.get_session()
        try:
            track = session.query(Track).filter_by(file_path=str(old_path)).first()
            if track:
                track.file_path = str(new_path)
                track.file_name = new_path.name
                session.commit()
                logger.info(f"Updated track path: {old_path} -> {new_path}")
                
                if self.callback:
                    self.callback()
        except Exception as e:
            logger.error(f"Error updating track path: {e}")
            session.rollback()
        finally:
            session.close()


class LibraryWatcher:
    """Automatic library monitoring using watchdog"""
    
    def __init__(self):
        self.observer = Observer()
        self.handlers: dict = {}
        self._is_running = False
    
    def add_directory(self, directory: str | Path, callback: Optional[Callable] = None) -> bool:
        """Add directory to watch"""
        directory = Path(directory)
        
        if not directory.exists() or not directory.is_dir():
            logger.error(f"Invalid directory: {directory}")
            return False
        
        if str(directory) in self.handlers:
            logger.warning(f"Directory already watched: {directory}")
            return True
        
        session = db.get_session()
        try:
            scanner = LibraryScanner(session)
            handler = LibraryEventHandler(scanner, callback)
            
            self.observer.schedule(handler, str(directory), recursive=True)
            self.handlers[str(directory)] = handler
            
            logger.info(f"Watching directory: {directory}")
            return True
        except Exception as e:
            logger.error(f"Failed to watch directory: {e}")
            return False
        finally:
            session.close()
    
    def remove_directory(self, directory: str | Path) -> bool:
        """Remove directory from watch"""
        directory = str(directory)
        
        if directory not in self.handlers:
            logger.warning(f"Directory not watched: {directory}")
            return False
        
        # In a real implementation, we'd need to unschedule the handler
        # For now, just remove from our tracking
        del self.handlers[directory]
        logger.info(f"Stopped watching: {directory}")
        return True
    
    def start(self) -> None:
        """Start watching"""
        if not self._is_running:
            self.observer.start()
            self._is_running = True
            logger.info("Library watcher started")
    
    def stop(self) -> None:
        """Stop watching"""
        if self._is_running:
            self.observer.stop()
            self.observer.join()
            self._is_running = False
            self.handlers.clear()
            logger.info("Library watcher stopped")
    
    def is_running(self) -> bool:
        """Check if watcher is running"""
        return self._is_running
