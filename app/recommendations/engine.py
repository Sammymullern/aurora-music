"""
AI-powered recommendation engine using librosa for audio analysis
"""

import logging
import numpy as np
from pathlib import Path
from typing import List, Optional, Dict, Tuple
from dataclasses import dataclass
from sqlalchemy.orm import Session

import librosa
import librosa.feature

from app.database.models import Track

logger = logging.getLogger(__name__)


@dataclass
class AudioFeatures:
    """Extracted audio features for a track"""
    track_id: int
    tempo: float  # BPM
    spectral_centroid_mean: float
    spectral_centroid_std: float
    spectral_rolloff_mean: float
    spectral_rolloff_std: float
    zero_crossing_rate_mean: float
    zero_crossing_rate_std: float
    mfcc_mean: np.ndarray  # 20 MFCC coefficients
    mfcc_std: np.ndarray
    chroma_mean: np.ndarray  # 12 chroma features
    chroma_std: np.ndarray
    energy: float
    danceability: float
    valence: float  # Emotional content (sad/happy)
    
    def to_dict(self) -> Dict:
        """Convert to dictionary for storage"""
        return {
            "track_id": self.track_id,
            "tempo": self.tempo,
            "spectral_centroid_mean": self.spectral_centroid_mean,
            "spectral_centroid_std": self.spectral_centroid_std,
            "spectral_rolloff_mean": self.spectral_rolloff_mean,
            "spectral_rolloff_std": self.spectral_rolloff_std,
            "zero_crossing_rate_mean": self.zero_crossing_rate_mean,
            "zero_crossing_rate_std": self.zero_crossing_rate_std,
            "energy": self.energy,
            "danceability": self.danceability,
            "valence": self.valence,
        }


class RecommendationEngine:
    """AI-powered recommendation engine using audio analysis"""
    
    def __init__(self, session: Session):
        self.session = session
        self._feature_cache: Dict[int, AudioFeatures] = {}
        self._sample_rate = 22050
        self._duration = 30  # Analyze 30 seconds from the middle
    
    def extract_features(self, track: Track) -> Optional[AudioFeatures]:
        """Extract audio features from a track"""
        if track.id in self._feature_cache:
            return self._feature_cache[track.id]
        
        try:
            file_path = Path(track.file_path)
            if not file_path.exists():
                logger.error(f"File not found: {file_path}")
                return None
            
            # Load audio
            y, sr = librosa.load(file_path, sr=self._sample_rate, duration=self._duration, offset=30)
            
            # Extract features
            features = self._compute_features(track.id, y, sr)
            
            # Cache features
            self._feature_cache[track.id] = features
            
            # Update database
            self._update_track_features(track, features)
            
            logger.info(f"Extracted features for track: {track.title}")
            return features
            
        except Exception as e:
            logger.error(f"Error extracting features from {track.file_path}: {e}")
            return None
    
    def _compute_features(self, track_id: int, y: np.ndarray, sr: int) -> AudioFeatures:
        """Compute audio features from audio data"""
        
        # Tempo (BPM)
        tempo, _ = librosa.beat.beat_track(y=y, sr=sr)
        
        # Spectral features
        spectral_centroids = librosa.feature.spectral_centroid(y=y, sr=sr)[0]
        spectral_rolloff = librosa.feature.spectral_rolloff(y=y, sr=sr)[0]
        
        # Zero crossing rate
        zcr = librosa.feature.zero_crossing_rate(y)[0]
        
        # MFCCs
        mfccs = librosa.feature.mfcc(y=y, sr=sr, n_mfcc=20)
        
        # Chroma features
        chroma = librosa.feature.chroma_stft(y=y, sr=sr)
        
        # Energy
        energy = np.mean(librosa.feature.rms(y=y))
        
        # Compute statistics
        features = AudioFeatures(
            track_id=track_id,
            tempo=float(tempo),
            spectral_centroid_mean=float(np.mean(spectral_centroids)),
            spectral_centroid_std=float(np.std(spectral_centroids)),
            spectral_rolloff_mean=float(np.mean(spectral_rolloff)),
            spectral_rolloff_std=float(np.std(spectral_rolloff)),
            zero_crossing_rate_mean=float(np.mean(zcr)),
            zero_crossing_rate_std=float(np.std(zcr)),
            mfcc_mean=np.mean(mfccs, axis=1),
            mfcc_std=np.std(mfccs, axis=1),
            chroma_mean=np.mean(chroma, axis=1),
            chroma_std=np.std(chroma, axis=1),
            energy=float(energy),
            danceability=self._compute_danceability(tempo, energy, spectral_centroids),
            valence=self._compute_valence(chroma, energy)
        )
        
        return features
    
    def _compute_danceability(self, tempo: float, energy: float, 
                              spectral_centroids: np.ndarray) -> float:
        """Compute danceability score (0-1)"""
        # Simple heuristic based on tempo and energy
        tempo_score = min(1.0, max(0.0, (tempo - 60) / 100))  # 60-160 BPM range
        energy_score = min(1.0, energy / 0.5)
        
        return (tempo_score * 0.6 + energy_score * 0.4)
    
    def _compute_valence(self, chroma: np.ndarray, energy: float) -> float:
        """Compute valence (emotional content) score (0-1)"""
        # Major/minor key estimation based on chroma
        chroma_mean = np.mean(chroma, axis=1)
        
        # Simple heuristic: higher chroma variance often indicates more complex/emotional
        chroma_variance = np.var(chroma_mean)
        valence = min(1.0, chroma_variance * 2 + energy * 0.5)
        
        return valence
    
    def _update_track_features(self, track: Track, features: AudioFeatures) -> None:
        """Update track with extracted features"""
        try:
            track.bpm = int(features.tempo)
            track.energy = features.energy
            track.danceability = features.danceability
            
            # Determine mood based on features
            if features.valence > 0.6:
                track.mood = "happy"
            elif features.valence < 0.4:
                track.mood = "sad"
            elif features.tempo > 120:
                track.mood = "energetic"
            else:
                track.mood = "calm"
            
            self.session.commit()
        except Exception as e:
            logger.error(f"Error updating track features: {e}")
            self.session.rollback()
    
    def get_similar_tracks(self, track: Track, limit: int = 10) -> List[Track]:
        """Get tracks similar to the given track"""
        features = self.extract_features(track)
        if not features:
            return []
        
        # Get all tracks
        all_tracks = self.session.query(Track).filter(Track.id != track.id).all()
        
        # Compute similarity scores
        similarities = []
        for other_track in all_tracks:
            other_features = self.extract_features(other_track)
            if other_features:
                similarity = self._compute_similarity(features, other_features)
                similarities.append((other_track, similarity))
        
        # Sort by similarity and return top matches
        similarities.sort(key=lambda x: x[1], reverse=True)
        return [t for t, s in similarities[:limit]]
    
    def _compute_similarity(self, features1: AudioFeatures, features2: AudioFeatures) -> float:
        """Compute similarity between two tracks (0-1)"""
        # Weighted combination of feature similarities
        
        # Tempo similarity (within 10 BPM)
        tempo_diff = abs(features1.tempo - features2.tempo)
        tempo_sim = max(0.0, 1.0 - tempo_diff / 20.0)
        
        # Energy similarity
        energy_sim = 1.0 - abs(features1.energy - features2.energy)
        
        # Danceability similarity
        dance_sim = 1.0 - abs(features1.danceability - features2.danceability)
        
        # MFCC similarity (cosine similarity)
        mfcc_sim = np.dot(features1.mfcc_mean, features2.mfcc_mean) / (
            np.linalg.norm(features1.mfcc_mean) * np.linalg.norm(features2.mfcc_mean)
        )
        
        # Chroma similarity
        chroma_sim = np.dot(features1.chroma_mean, features2.chroma_mean) / (
            np.linalg.norm(features1.chroma_mean) * np.linalg.norm(features2.chroma_mean)
        )
        
        # Weighted average
        similarity = (
            tempo_sim * 0.2 +
            energy_sim * 0.15 +
            dance_sim * 0.15 +
            mfcc_sim * 0.3 +
            chroma_sim * 0.2
        )
        
        return float(similarity)
    
    def get_recommendations_by_mood(self, mood: str, limit: int = 20) -> List[Track]:
        """Get tracks by mood"""
        return self.session.query(Track).filter(
            Track.mood == mood
        ).order_by(Track.play_count.desc()).limit(limit).all()
    
    def get_recommendations_by_genre(self, genre: str, limit: int = 20) -> List[Track]:
        """Get tracks by genre"""
        return self.session.query(Track).filter(
            Track.genre == genre
        ).order_by(Track.play_count.desc()).limit(limit).all()
    
    def get_mixed_playlist(self, seed_tracks: List[Track], length: int = 30) -> List[Track]:
        """Generate a mixed playlist based on seed tracks"""
        if not seed_tracks:
            return []
        
        # Extract features from seed tracks
        seed_features = []
        for track in seed_tracks:
            features = self.extract_features(track)
            if features:
                seed_features.append(features)
        
        if not seed_features:
            return []
        
        # Get all tracks
        all_tracks = self.session.query(Track).all()
        
        # Compute average features
        avg_tempo = np.mean([f.tempo for f in seed_features])
        avg_energy = np.mean([f.energy for f in seed_features])
        avg_danceability = np.mean([f.danceability for f in seed_features])
        
        # Select tracks that match the average profile
        scored_tracks = []
        for track in all_tracks:
            if track in seed_tracks:
                continue
            
            features = self.extract_features(track)
            if features:
                # Compute distance from average
                tempo_dist = abs(features.tempo - avg_tempo) / avg_tempo
                energy_dist = abs(features.energy - avg_energy)
                dance_dist = abs(features.danceability - avg_danceability)
                
                score = 1.0 - (tempo_dist * 0.4 + energy_dist * 0.3 + dance_dist * 0.3)
                scored_tracks.append((track, score))
        
        # Sort by score and return top matches
        scored_tracks.sort(key=lambda x: x[1], reverse=True)
        return [t for t, s in scored_tracks[:length]]
    
    def clear_cache(self) -> None:
        """Clear the feature cache"""
        self._feature_cache.clear()
        logger.info("Feature cache cleared")
