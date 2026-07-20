"""
Database session management
"""

import logging
from pathlib import Path
from typing import Optional

from sqlalchemy import create_engine
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
    
    def initialize(self, db_path: str | Path = "aurora.db") -> None:
        """Initialize database connection and create tables"""
        db_path = Path(db_path)
        
        # Create database directory if it doesn't exist
        db_path.parent.mkdir(parents=True, exist_ok=True)
        
        # Create engine with SQLite
        connection_string = f"sqlite:///{db_path}"
        self._engine = create_engine(
            connection_string,
            connect_args={"check_same_thread": False},
            poolclass=StaticPool,
            echo=False
        )
        
        # Create session factory
        self._session_factory = sessionmaker(
            bind=self._engine,
            autocommit=False,
            autoflush=False
        )
        
        # Create all tables
        Base.metadata.create_all(self._engine)
        
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
