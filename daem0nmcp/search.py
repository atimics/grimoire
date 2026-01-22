"""
TF-IDF based search engine for Daem0nMCP.

Provides keyword-based search with relevance scoring.
"""

import math
import re
from collections import Counter
from dataclasses import dataclass
from datetime import datetime
from typing import Optional

from daem0nmcp.models import Memory, MemoryCategory


@dataclass
class SearchResult:
    """A search result with relevance score."""

    memory: Memory
    score: float
    matched_terms: list[str]

    def to_dict(self) -> dict:
        """Convert to dictionary."""
        return {
            "memory": self.memory.to_dict(),
            "score": self.score,
            "matched_terms": self.matched_terms,
        }


class SearchEngine:
    """TF-IDF based search engine for memories."""

    # Stop words to ignore in searches
    STOP_WORDS = {
        "a", "an", "the", "and", "or", "but", "in", "on", "at", "to", "for",
        "of", "with", "by", "from", "is", "are", "was", "were", "be", "been",
        "being", "have", "has", "had", "do", "does", "did", "will", "would",
        "could", "should", "may", "might", "must", "shall", "can", "need",
        "this", "that", "these", "those", "it", "its", "i", "you", "he", "she",
        "we", "they", "my", "your", "his", "her", "our", "their", "what",
        "which", "who", "when", "where", "why", "how", "all", "each", "every",
        "both", "few", "more", "most", "other", "some", "such", "no", "not",
        "only", "same", "so", "than", "too", "very", "just", "also", "now",
    }

    def __init__(self):
        """Initialize the search engine."""
        self._document_frequencies: dict[str, int] = {}
        self._total_documents: int = 0

    def tokenize(self, text: str) -> list[str]:
        """Tokenize text into lowercase words."""
        if not text:
            return []

        # Convert to lowercase and split on non-alphanumeric
        words = re.findall(r'\b[a-z0-9]+\b', text.lower())

        # Remove stop words and short words
        return [w for w in words if w not in self.STOP_WORDS and len(w) > 2]

    def _get_memory_text(self, memory: Memory) -> str:
        """Get all searchable text from a memory."""
        parts = [memory.content]
        if memory.rationale:
            parts.append(memory.rationale)
        if memory.context:
            parts.append(memory.context)
        if memory.tags:
            parts.extend(memory.tags)
        if memory.file_path:
            parts.append(memory.file_path)
        if memory.outcome:
            parts.append(memory.outcome)
        return " ".join(parts)

    def build_index(self, memories: list[Memory]) -> None:
        """Build TF-IDF index from memories."""
        self._document_frequencies = {}
        self._total_documents = len(memories)

        for memory in memories:
            text = self._get_memory_text(memory)
            tokens = set(self.tokenize(text))  # Unique tokens per document

            for token in tokens:
                self._document_frequencies[token] = self._document_frequencies.get(token, 0) + 1

    def _calculate_tf(self, term: str, tokens: list[str]) -> float:
        """Calculate term frequency."""
        if not tokens:
            return 0.0
        count = tokens.count(term)
        return count / len(tokens)

    def _calculate_idf(self, term: str) -> float:
        """Calculate inverse document frequency."""
        if self._total_documents == 0:
            return 0.0

        doc_freq = self._document_frequencies.get(term, 0)
        if doc_freq == 0:
            return 0.0

        return math.log(self._total_documents / doc_freq) + 1

    def _calculate_relevance_boost(self, memory: Memory) -> float:
        """Calculate relevance boost based on memory properties."""
        boost = 1.0

        # Failed decisions get 1.5x boost (learn from failures)
        if memory.worked is False:
            boost *= 1.5

        # Warnings and patterns are more important
        if memory.category == MemoryCategory.WARNING:
            boost *= 1.3
        elif memory.category == MemoryCategory.PATTERN:
            boost *= 1.2

        # Pinned memories get boost
        if memory.pinned:
            boost *= 1.4

        # Recent memories get slight boost
        if memory.created_at:
            days_old = (datetime.utcnow() - memory.created_at).days
            recency_boost = max(0.5, 1.0 - (days_old / 365))  # Decay over a year
            boost *= recency_boost

        # Frequently recalled memories might be more relevant
        if memory.recall_count > 0:
            recall_boost = min(1.3, 1.0 + (memory.recall_count * 0.05))
            boost *= recall_boost

        return boost

    def search(
        self,
        query: str,
        memories: list[Memory],
        limit: int = 20,
        categories: Optional[list[MemoryCategory]] = None,
    ) -> list[SearchResult]:
        """Search memories using TF-IDF scoring.

        Args:
            query: Search query string.
            memories: List of memories to search.
            limit: Maximum results to return.
            categories: Optional filter by categories.

        Returns:
            List of SearchResults sorted by relevance.
        """
        # Build index if needed
        if self._total_documents != len(memories):
            self.build_index(memories)

        query_tokens = self.tokenize(query)
        if not query_tokens:
            return []

        results: list[SearchResult] = []

        for memory in memories:
            # Filter by category if specified
            if categories and memory.category not in categories:
                continue

            # Skip archived memories
            if memory.archived:
                continue

            text = self._get_memory_text(memory)
            doc_tokens = self.tokenize(text)

            if not doc_tokens:
                continue

            # Calculate TF-IDF score
            score = 0.0
            matched_terms = []

            for term in query_tokens:
                tf = self._calculate_tf(term, doc_tokens)
                if tf > 0:
                    idf = self._calculate_idf(term)
                    score += tf * idf
                    matched_terms.append(term)

            if score > 0:
                # Apply relevance boost
                boost = self._calculate_relevance_boost(memory)
                score *= boost

                results.append(SearchResult(
                    memory=memory,
                    score=score,
                    matched_terms=matched_terms,
                ))

        # Sort by score descending
        results.sort(key=lambda r: r.score, reverse=True)

        return results[:limit]

    def find_similar(
        self,
        memory: Memory,
        all_memories: list[Memory],
        limit: int = 10,
    ) -> list[SearchResult]:
        """Find memories similar to the given memory.

        Args:
            memory: The memory to find similar items for.
            all_memories: List of all memories to search.
            limit: Maximum results to return.

        Returns:
            List of similar memories (excluding the input memory).
        """
        # Use memory content as query
        query = self._get_memory_text(memory)

        # Search and filter out the input memory
        results = self.search(query, all_memories, limit=limit + 1)
        return [r for r in results if r.memory.id != memory.id][:limit]

    def match_rules(
        self,
        action: str,
        rules: list,
    ) -> list:
        """Match rules against an action description.

        Args:
            action: Description of the action being taken.
            rules: List of Rule objects to match against.

        Returns:
            List of matching rules sorted by priority.
        """
        action_tokens = set(self.tokenize(action))
        if not action_tokens:
            return []

        matches = []
        for rule in rules:
            if not rule.enabled:
                continue

            trigger_tokens = set(self.tokenize(rule.trigger))
            overlap = action_tokens & trigger_tokens

            if overlap:
                # Score by overlap ratio
                score = len(overlap) / len(trigger_tokens) if trigger_tokens else 0
                if score > 0.3:  # At least 30% overlap
                    matches.append((rule, score))

        # Sort by priority then score
        matches.sort(key=lambda x: (x[0].priority, x[1]), reverse=True)
        return [rule for rule, _ in matches]


def infer_tags(content: str, rationale: Optional[str] = None) -> list[str]:
    """Automatically infer tags from memory content.

    Args:
        content: Memory content.
        rationale: Optional rationale text.

    Returns:
        List of inferred tags.
    """
    text = f"{content} {rationale or ''}".lower()
    tags = []

    # Bug/fix related
    if any(word in text for word in ["fix", "bug", "error", "broken", "crash", "issue"]):
        tags.append("bugfix")

    # Tech debt
    if any(word in text for word in ["todo", "hack", "workaround", "temporary", "tech debt"]):
        tags.append("tech-debt")

    # Performance
    if any(word in text for word in ["cache", "slow", "fast", "performance", "optimize", "speed"]):
        tags.append("perf")

    # Security
    if any(word in text for word in ["security", "auth", "permission", "access", "token", "encrypt"]):
        tags.append("security")

    # Database
    if any(word in text for word in ["database", "sql", "query", "migration", "schema"]):
        tags.append("database")

    # API
    if any(word in text for word in ["api", "endpoint", "rest", "graphql", "request", "response"]):
        tags.append("api")

    # Testing
    if any(word in text for word in ["test", "testing", "unittest", "mock", "assert"]):
        tags.append("testing")

    # Architecture
    if any(word in text for word in ["architecture", "design", "pattern", "structure", "refactor"]):
        tags.append("architecture")

    return list(set(tags))  # Deduplicate
