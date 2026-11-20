"""
Database session management
"""

import logging
import os
import shutil
from pathlib import Path
from typing import Optional

from sqlalchemy import create_engine
from sqlalchemy import inspect, text
from sqlalchemy.orm import Session, sessionmaker
from sqlalchemy.pool import StaticPool

from app.database.models import Base

logger = logging.getLogger(__name__)


class DatabaseSession:
    """Database session manager"""
    
    _instance: Optional["DatabaseSession"] = None
    _engine = None
    _session_factory = None
    
    def __new__(cls) -> "DatabaseSession":
        if cls._instance is None:
            cls._instance = super().__new__(cls)
        return cls._instance
    
    def initialize(self, db_path: str | Path | None = None) -> None:
        """Initialize database connection and create tables"""
        if db_path is None:
            data_home = Path(os.environ.get("XDG_DATA_HOME", Path.home() / ".local/share"))
            db_path = data_home / "aurora-music" / "aurora.db"
            legacy_candidates = (
                Path(__file__).resolve().parents[2] / "aurora.db",
                Path.home() / "aurora.db",
                Path.cwd() / "aurora.db",
            )
            if not Path(db_path).exists():
                legacy_path = next(
                    (candidate for candidate in legacy_candidates if candidate.is_file()),
                    None,
                )
                if legacy_path is not None and legacy_path.resolve() != Path(db_path).resolve():
                    Path(db_path).parent.mkdir(parents=True, exist_ok=True)
                    shutil.copy2(legacy_path, db_path)
        db_path = Path(db_path)
        
        # Create database directory if it doesn't exist
        db_path.parent.mkdir(parents=True, exist_ok=True)
        
        # Create engine with SQLite
        connection_string = f"sqlite:///{db_path}"
        engine_options = {
            "connect_args": {"check_same_thread": False, "timeout": 30},
            "echo": False,
        }
        if str(db_path) == ":memory:":
            engine_options["poolclass"] = StaticPool
        self._engine = create_engine(connection_string, **engine_options)
        
        # Create session factory
        self._session_factory = sessionmaker(
            bind=self._engine,
            autocommit=False,
            autoflush=False
        )
        
        # Create all tables
        Base.metadata.create_all(self._engine)

        # Keep existing user libraries compatible with additive model fields.
        # SQLite's create_all does not alter tables that already exist.
        if inspect(self._engine).has_table("tracks"):
            columns = {column["name"] for column in inspect(self._engine).get_columns("tracks")}
            if "album_artist" not in columns or "metadata_version" not in columns:
                with self._engine.begin() as connection:
                    if "album_artist" not in columns:
                        connection.execute(text("ALTER TABLE tracks ADD COLUMN album_artist VARCHAR(255)"))
                    if "metadata_version" not in columns:
                        connection.execute(text("ALTER TABLE tracks ADD COLUMN metadata_version INTEGER NOT NULL DEFAULT 0"))
        
        logger.info(f"Database initialized at {db_path}")
    
    def get_session(self) -> Session:
        """Get a new database session"""
        if self._session_factory is None:
            raise RuntimeError("Database not initialized. Call initialize() first.")
        return self._session_factory()
    
    def close(self) -> None:
        """Close database connection"""
        if self._engine:
            self._engine.dispose()
            self._engine = None
            self._session_factory = None
            logger.info("Database connection closed")


# Global database instance
db = DatabaseSession()
