"""
Data models for Daem0nMCP memory system.
"""

from dataclasses import dataclass, field
from datetime import datetime
from enum import Enum
from typing import Optional


class MemoryCategory(str, Enum):
    """Categories of memories with different persistence behaviors."""

    DECISION = "decision"    # Architectural/design choices (30-day half-life)
    PATTERN = "pattern"      # Recurring approaches (eternal)
    WARNING = "warning"      # Things to avoid (eternal)
    LEARNING = "learning"    # Lessons from experience (30-day half-life)

    @property
    def is_eternal(self) -> bool:
        """Check if this category has eternal persistence."""
        return self in (MemoryCategory.PATTERN, MemoryCategory.WARNING)


@dataclass
class Memory:
    """A single memory unit stored by the Daem0n."""

    id: Optional[int] = None
    category: MemoryCategory = MemoryCategory.DECISION
    content: str = ""
    rationale: Optional[str] = None
    context: Optional[str] = None
    tags: list[str] = field(default_factory=list)
    file_path: Optional[str] = None
    project_path: str = ""

    # Outcome tracking
    outcome: Optional[str] = None
    worked: Optional[bool] = None

    # Metadata
    created_at: datetime = field(default_factory=datetime.utcnow)
    updated_at: datetime = field(default_factory=datetime.utcnow)
    recall_count: int = 0

    # Management flags
    pinned: bool = False
    archived: bool = False

    def to_dict(self) -> dict:
        """Convert memory to dictionary for serialization."""
        return {
            "id": self.id,
            "category": self.category.value if isinstance(self.category, MemoryCategory) else self.category,
            "content": self.content,
            "rationale": self.rationale,
            "context": self.context,
            "tags": self.tags,
            "file_path": self.file_path,
            "project_path": self.project_path,
            "outcome": self.outcome,
            "worked": self.worked,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
            "recall_count": self.recall_count,
            "pinned": self.pinned,
            "archived": self.archived,
        }

    @classmethod
    def from_dict(cls, data: dict) -> "Memory":
        """Create memory from dictionary."""
        category = data.get("category", "decision")
        if isinstance(category, str):
            category = MemoryCategory(category)

        created_at = data.get("created_at")
        if isinstance(created_at, str):
            created_at = datetime.fromisoformat(created_at)
        elif created_at is None:
            created_at = datetime.utcnow()

        updated_at = data.get("updated_at")
        if isinstance(updated_at, str):
            updated_at = datetime.fromisoformat(updated_at)
        elif updated_at is None:
            updated_at = datetime.utcnow()

        return cls(
            id=data.get("id"),
            category=category,
            content=data.get("content", ""),
            rationale=data.get("rationale"),
            context=data.get("context"),
            tags=data.get("tags", []),
            file_path=data.get("file_path"),
            project_path=data.get("project_path", ""),
            outcome=data.get("outcome"),
            worked=data.get("worked"),
            created_at=created_at,
            updated_at=updated_at,
            recall_count=data.get("recall_count", 0),
            pinned=data.get("pinned", False),
            archived=data.get("archived", False),
        )

    def summary(self, max_length: int = 150) -> str:
        """Get a condensed summary of the memory."""
        content = self.content[:max_length]
        if len(self.content) > max_length:
            content += "..."
        return content


@dataclass
class Rule:
    """A rule/law that governs actions in a project."""

    id: Optional[int] = None
    trigger: str = ""  # What action triggers this rule
    must_do: list[str] = field(default_factory=list)
    must_not: list[str] = field(default_factory=list)
    ask_first: list[str] = field(default_factory=list)
    warnings: list[str] = field(default_factory=list)
    priority: int = 10
    enabled: bool = True
    project_path: str = ""
    created_at: datetime = field(default_factory=datetime.utcnow)
    updated_at: datetime = field(default_factory=datetime.utcnow)

    def to_dict(self) -> dict:
        """Convert rule to dictionary for serialization."""
        return {
            "id": self.id,
            "trigger": self.trigger,
            "must_do": self.must_do,
            "must_not": self.must_not,
            "ask_first": self.ask_first,
            "warnings": self.warnings,
            "priority": self.priority,
            "enabled": self.enabled,
            "project_path": self.project_path,
            "created_at": self.created_at.isoformat() if self.created_at else None,
            "updated_at": self.updated_at.isoformat() if self.updated_at else None,
        }

    @classmethod
    def from_dict(cls, data: dict) -> "Rule":
        """Create rule from dictionary."""
        created_at = data.get("created_at")
        if isinstance(created_at, str):
            created_at = datetime.fromisoformat(created_at)
        elif created_at is None:
            created_at = datetime.utcnow()

        updated_at = data.get("updated_at")
        if isinstance(updated_at, str):
            updated_at = datetime.fromisoformat(updated_at)
        elif updated_at is None:
            updated_at = datetime.utcnow()

        return cls(
            id=data.get("id"),
            trigger=data.get("trigger", ""),
            must_do=data.get("must_do", []),
            must_not=data.get("must_not", []),
            ask_first=data.get("ask_first", []),
            warnings=data.get("warnings", []),
            priority=data.get("priority", 10),
            enabled=data.get("enabled", True),
            project_path=data.get("project_path", ""),
            created_at=created_at,
            updated_at=updated_at,
        )


@dataclass
class BriefingResponse:
    """Response from get_briefing containing session context."""

    recent_decisions: list[dict] = field(default_factory=list)
    active_warnings: list[dict] = field(default_factory=list)
    failed_approaches: list[dict] = field(default_factory=list)
    patterns: list[dict] = field(default_factory=list)

    total_memories: int = 0
    total_decisions: int = 0
    total_warnings: int = 0
    total_patterns: int = 0
    total_learnings: int = 0

    git_changes: Optional[dict] = None

    def to_dict(self) -> dict:
        """Convert to dictionary."""
        return {
            "recent_decisions": self.recent_decisions,
            "active_warnings": self.active_warnings,
            "failed_approaches": self.failed_approaches,
            "patterns": self.patterns,
            "total_memories": self.total_memories,
            "total_decisions": self.total_decisions,
            "total_warnings": self.total_warnings,
            "total_patterns": self.total_patterns,
            "total_learnings": self.total_learnings,
            "git_changes": self.git_changes,
            "drill_down": "Use recall(topic) or recall_for_file(path) for full details",
        }
