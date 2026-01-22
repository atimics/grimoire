"""
SQLite storage layer for Daem0nMCP.

Provides persistent storage for memories and rules with project isolation.
Each project has its own database at .daem0nmcp/storage/daem0nmcp.db
"""

import json
import os
import sqlite3
from contextlib import contextmanager
from datetime import datetime
from pathlib import Path
from typing import Generator, Optional

from daem0nmcp.models import Memory, MemoryCategory, Rule


class Storage:
    """SQLite-based storage for memories and rules."""

    def __init__(self, project_path: str):
        """Initialize storage for a project.

        Args:
            project_path: Absolute path to the project root.
        """
        self.project_path = os.path.abspath(project_path)
        self.storage_dir = os.path.join(self.project_path, ".daem0nmcp", "storage")
        self.db_path = os.path.join(self.storage_dir, "daem0nmcp.db")

        # Ensure storage directory exists
        os.makedirs(self.storage_dir, exist_ok=True)

        # Initialize database
        self._init_db()

    @contextmanager
    def _get_connection(self) -> Generator[sqlite3.Connection, None, None]:
        """Get a database connection with row factory."""
        conn = sqlite3.connect(self.db_path)
        conn.row_factory = sqlite3.Row
        try:
            yield conn
        finally:
            conn.close()

    def _init_db(self) -> None:
        """Initialize database schema."""
        with self._get_connection() as conn:
            cursor = conn.cursor()

            # Memories table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS memories (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    category TEXT NOT NULL,
                    content TEXT NOT NULL,
                    rationale TEXT,
                    context TEXT,
                    tags TEXT DEFAULT '[]',
                    file_path TEXT,
                    project_path TEXT NOT NULL,
                    outcome TEXT,
                    worked INTEGER,
                    created_at TEXT NOT NULL,
                    updated_at TEXT NOT NULL,
                    recall_count INTEGER DEFAULT 0,
                    pinned INTEGER DEFAULT 0,
                    archived INTEGER DEFAULT 0
                )
            """)

            # Rules table
            cursor.execute("""
                CREATE TABLE IF NOT EXISTS rules (
                    id INTEGER PRIMARY KEY AUTOINCREMENT,
                    trigger TEXT NOT NULL,
                    must_do TEXT DEFAULT '[]',
                    must_not TEXT DEFAULT '[]',
                    ask_first TEXT DEFAULT '[]',
                    warnings TEXT DEFAULT '[]',
                    priority INTEGER DEFAULT 10,
                    enabled INTEGER DEFAULT 1,
                    project_path TEXT NOT NULL,
                    created_at TEXT NOT NULL,
                    updated_at TEXT NOT NULL
                )
            """)

            # Indexes for common queries
            cursor.execute("""
                CREATE INDEX IF NOT EXISTS idx_memories_category
                ON memories(category)
            """)
            cursor.execute("""
                CREATE INDEX IF NOT EXISTS idx_memories_file_path
                ON memories(file_path)
            """)
            cursor.execute("""
                CREATE INDEX IF NOT EXISTS idx_memories_project_path
                ON memories(project_path)
            """)
            cursor.execute("""
                CREATE INDEX IF NOT EXISTS idx_memories_worked
                ON memories(worked)
            """)
            cursor.execute("""
                CREATE INDEX IF NOT EXISTS idx_rules_project_path
                ON rules(project_path)
            """)

            conn.commit()

    # Memory operations

    def create_memory(self, memory: Memory) -> Memory:
        """Create a new memory and return it with ID."""
        now = datetime.utcnow().isoformat()
        memory.created_at = datetime.utcnow()
        memory.updated_at = datetime.utcnow()
        memory.project_path = self.project_path

        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT INTO memories (
                    category, content, rationale, context, tags, file_path,
                    project_path, outcome, worked, created_at, updated_at,
                    recall_count, pinned, archived
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                memory.category.value if isinstance(memory.category, MemoryCategory) else memory.category,
                memory.content,
                memory.rationale,
                memory.context,
                json.dumps(memory.tags),
                memory.file_path,
                memory.project_path,
                memory.outcome,
                1 if memory.worked else (0 if memory.worked is False else None),
                now,
                now,
                memory.recall_count,
                1 if memory.pinned else 0,
                1 if memory.archived else 0,
            ))
            conn.commit()
            memory.id = cursor.lastrowid

        return memory

    def get_memory(self, memory_id: int) -> Optional[Memory]:
        """Get a memory by ID."""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM memories WHERE id = ?", (memory_id,))
            row = cursor.fetchone()
            if row:
                return self._row_to_memory(row)
        return None

    def update_memory(self, memory: Memory) -> Memory:
        """Update an existing memory."""
        memory.updated_at = datetime.utcnow()

        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                UPDATE memories SET
                    category = ?, content = ?, rationale = ?, context = ?,
                    tags = ?, file_path = ?, outcome = ?, worked = ?,
                    updated_at = ?, recall_count = ?, pinned = ?, archived = ?
                WHERE id = ?
            """, (
                memory.category.value if isinstance(memory.category, MemoryCategory) else memory.category,
                memory.content,
                memory.rationale,
                memory.context,
                json.dumps(memory.tags),
                memory.file_path,
                memory.outcome,
                1 if memory.worked else (0 if memory.worked is False else None),
                memory.updated_at.isoformat(),
                memory.recall_count,
                1 if memory.pinned else 0,
                1 if memory.archived else 0,
                memory.id,
            ))
            conn.commit()

        return memory

    def delete_memory(self, memory_id: int) -> bool:
        """Delete a memory by ID."""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM memories WHERE id = ?", (memory_id,))
            conn.commit()
            return cursor.rowcount > 0

    def get_memories(
        self,
        category: Optional[MemoryCategory] = None,
        file_path: Optional[str] = None,
        include_archived: bool = False,
        limit: int = 100,
        offset: int = 0,
    ) -> list[Memory]:
        """Get memories with optional filters."""
        conditions = ["project_path = ?"]
        params: list = [self.project_path]

        if category:
            conditions.append("category = ?")
            params.append(category.value if isinstance(category, MemoryCategory) else category)

        if file_path:
            conditions.append("file_path = ?")
            params.append(file_path)

        if not include_archived:
            conditions.append("archived = 0")

        query = f"""
            SELECT * FROM memories
            WHERE {' AND '.join(conditions)}
            ORDER BY created_at DESC
            LIMIT ? OFFSET ?
        """
        params.extend([limit, offset])

        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute(query, params)
            return [self._row_to_memory(row) for row in cursor.fetchall()]

    def get_memories_for_file(self, file_path: str, limit: int = 50) -> list[Memory]:
        """Get all memories associated with a specific file."""
        return self.get_memories(file_path=file_path, limit=limit)

    def get_failed_memories(self, limit: int = 20) -> list[Memory]:
        """Get memories where worked=False."""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                SELECT * FROM memories
                WHERE project_path = ? AND worked = 0 AND archived = 0
                ORDER BY created_at DESC
                LIMIT ?
            """, (self.project_path, limit))
            return [self._row_to_memory(row) for row in cursor.fetchall()]

    def get_warnings(self, limit: int = 50) -> list[Memory]:
        """Get all warning memories."""
        return self.get_memories(category=MemoryCategory.WARNING, limit=limit)

    def get_patterns(self, limit: int = 50) -> list[Memory]:
        """Get all pattern memories."""
        return self.get_memories(category=MemoryCategory.PATTERN, limit=limit)

    def increment_recall_count(self, memory_id: int) -> None:
        """Increment the recall count for a memory."""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                UPDATE memories SET recall_count = recall_count + 1
                WHERE id = ?
            """, (memory_id,))
            conn.commit()

    def get_memory_counts(self) -> dict:
        """Get counts of memories by category."""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                SELECT category, COUNT(*) as count
                FROM memories
                WHERE project_path = ? AND archived = 0
                GROUP BY category
            """, (self.project_path,))

            counts = {
                "total": 0,
                "decision": 0,
                "pattern": 0,
                "warning": 0,
                "learning": 0,
            }
            for row in cursor.fetchall():
                counts[row["category"]] = row["count"]
                counts["total"] += row["count"]

            return counts

    def _row_to_memory(self, row: sqlite3.Row) -> Memory:
        """Convert a database row to a Memory object."""
        worked = row["worked"]
        if worked is not None:
            worked = bool(worked)

        return Memory(
            id=row["id"],
            category=MemoryCategory(row["category"]),
            content=row["content"],
            rationale=row["rationale"],
            context=row["context"],
            tags=json.loads(row["tags"]) if row["tags"] else [],
            file_path=row["file_path"],
            project_path=row["project_path"],
            outcome=row["outcome"],
            worked=worked,
            created_at=datetime.fromisoformat(row["created_at"]),
            updated_at=datetime.fromisoformat(row["updated_at"]),
            recall_count=row["recall_count"],
            pinned=bool(row["pinned"]),
            archived=bool(row["archived"]),
        )

    # Rule operations

    def create_rule(self, rule: Rule) -> Rule:
        """Create a new rule and return it with ID."""
        now = datetime.utcnow().isoformat()
        rule.created_at = datetime.utcnow()
        rule.updated_at = datetime.utcnow()
        rule.project_path = self.project_path

        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                INSERT INTO rules (
                    trigger, must_do, must_not, ask_first, warnings,
                    priority, enabled, project_path, created_at, updated_at
                ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
            """, (
                rule.trigger,
                json.dumps(rule.must_do),
                json.dumps(rule.must_not),
                json.dumps(rule.ask_first),
                json.dumps(rule.warnings),
                rule.priority,
                1 if rule.enabled else 0,
                rule.project_path,
                now,
                now,
            ))
            conn.commit()
            rule.id = cursor.lastrowid

        return rule

    def get_rule(self, rule_id: int) -> Optional[Rule]:
        """Get a rule by ID."""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("SELECT * FROM rules WHERE id = ?", (rule_id,))
            row = cursor.fetchone()
            if row:
                return self._row_to_rule(row)
        return None

    def update_rule(self, rule: Rule) -> Rule:
        """Update an existing rule."""
        rule.updated_at = datetime.utcnow()

        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("""
                UPDATE rules SET
                    trigger = ?, must_do = ?, must_not = ?, ask_first = ?,
                    warnings = ?, priority = ?, enabled = ?, updated_at = ?
                WHERE id = ?
            """, (
                rule.trigger,
                json.dumps(rule.must_do),
                json.dumps(rule.must_not),
                json.dumps(rule.ask_first),
                json.dumps(rule.warnings),
                rule.priority,
                1 if rule.enabled else 0,
                rule.updated_at.isoformat(),
                rule.id,
            ))
            conn.commit()

        return rule

    def delete_rule(self, rule_id: int) -> bool:
        """Delete a rule by ID."""
        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute("DELETE FROM rules WHERE id = ?", (rule_id,))
            conn.commit()
            return cursor.rowcount > 0

    def get_rules(self, enabled_only: bool = True, limit: int = 100) -> list[Rule]:
        """Get all rules for this project."""
        conditions = ["project_path = ?"]
        params: list = [self.project_path]

        if enabled_only:
            conditions.append("enabled = 1")

        query = f"""
            SELECT * FROM rules
            WHERE {' AND '.join(conditions)}
            ORDER BY priority DESC, created_at DESC
            LIMIT ?
        """
        params.append(limit)

        with self._get_connection() as conn:
            cursor = conn.cursor()
            cursor.execute(query, params)
            return [self._row_to_rule(row) for row in cursor.fetchall()]

    def _row_to_rule(self, row: sqlite3.Row) -> Rule:
        """Convert a database row to a Rule object."""
        return Rule(
            id=row["id"],
            trigger=row["trigger"],
            must_do=json.loads(row["must_do"]) if row["must_do"] else [],
            must_not=json.loads(row["must_not"]) if row["must_not"] else [],
            ask_first=json.loads(row["ask_first"]) if row["ask_first"] else [],
            warnings=json.loads(row["warnings"]) if row["warnings"] else [],
            priority=row["priority"],
            enabled=bool(row["enabled"]),
            project_path=row["project_path"],
            created_at=datetime.fromisoformat(row["created_at"]),
            updated_at=datetime.fromisoformat(row["updated_at"]),
        )

    # Export/Import

    def export_data(self) -> dict:
        """Export all data for this project."""
        memories = self.get_memories(include_archived=True, limit=10000)
        rules = self.get_rules(enabled_only=False, limit=1000)

        return {
            "version": "0.1.0",
            "project_path": self.project_path,
            "exported_at": datetime.utcnow().isoformat(),
            "memories": [m.to_dict() for m in memories],
            "rules": [r.to_dict() for r in rules],
        }

    def import_data(self, data: dict, merge: bool = True) -> dict:
        """Import data into this project.

        Args:
            data: Exported data dictionary.
            merge: If True, merge with existing data. If False, replace all.

        Returns:
            Import statistics.
        """
        if not merge:
            # Clear existing data
            with self._get_connection() as conn:
                cursor = conn.cursor()
                cursor.execute("DELETE FROM memories WHERE project_path = ?", (self.project_path,))
                cursor.execute("DELETE FROM rules WHERE project_path = ?", (self.project_path,))
                conn.commit()

        memories_imported = 0
        rules_imported = 0

        for memory_data in data.get("memories", []):
            memory = Memory.from_dict(memory_data)
            memory.id = None  # Force new ID
            self.create_memory(memory)
            memories_imported += 1

        for rule_data in data.get("rules", []):
            rule = Rule.from_dict(rule_data)
            rule.id = None  # Force new ID
            self.create_rule(rule)
            rules_imported += 1

        return {
            "memories_imported": memories_imported,
            "rules_imported": rules_imported,
        }
