"""
MCP Server for Daem0nMCP.

Provides persistent AI memory management through the Model Context Protocol.
"""

import json
import os
import subprocess
from datetime import datetime
from typing import Any, Optional

from daem0nmcp.models import BriefingResponse, Memory, MemoryCategory, Rule
from daem0nmcp.search import SearchEngine, infer_tags
from daem0nmcp.storage import Storage


class Daem0nMCPServer:
    """MCP Server providing persistent memory management."""

    def __init__(self):
        """Initialize the server."""
        self._storages: dict[str, Storage] = {}
        self._search_engines: dict[str, SearchEngine] = {}
        self._communion_state: dict[str, datetime] = {}  # Track communion per project

    def _get_storage(self, project_path: str) -> Storage:
        """Get or create storage for a project."""
        project_path = os.path.abspath(project_path)
        if project_path not in self._storages:
            self._storages[project_path] = Storage(project_path)
        return self._storages[project_path]

    def _get_search_engine(self, project_path: str) -> SearchEngine:
        """Get or create search engine for a project."""
        project_path = os.path.abspath(project_path)
        if project_path not in self._search_engines:
            self._search_engines[project_path] = SearchEngine()
        return self._search_engines[project_path]

    def _mark_communion(self, project_path: str) -> None:
        """Mark that communion has occurred for this project."""
        self._communion_state[os.path.abspath(project_path)] = datetime.utcnow()

    def _check_communion(self, project_path: str) -> bool:
        """Check if communion has occurred recently (within session)."""
        project_path = os.path.abspath(project_path)
        return project_path in self._communion_state

    def _get_git_info(self, project_path: str) -> Optional[dict]:
        """Get git information for the project."""
        try:
            # Check if git repo
            result = subprocess.run(
                ["git", "rev-parse", "--git-dir"],
                cwd=project_path,
                capture_output=True,
                text=True,
                timeout=5,
            )
            if result.returncode != 0:
                return None

            git_info = {}

            # Get current branch
            result = subprocess.run(
                ["git", "branch", "--show-current"],
                cwd=project_path,
                capture_output=True,
                text=True,
                timeout=5,
            )
            if result.returncode == 0:
                git_info["branch"] = result.stdout.strip()

            # Get uncommitted changes
            result = subprocess.run(
                ["git", "status", "--porcelain"],
                cwd=project_path,
                capture_output=True,
                text=True,
                timeout=5,
            )
            if result.returncode == 0:
                changes = result.stdout.strip().split("\n") if result.stdout.strip() else []
                git_info["uncommitted_changes"] = [c[3:] for c in changes if c]

            # Get recent commits
            result = subprocess.run(
                ["git", "log", "--oneline", "-5"],
                cwd=project_path,
                capture_output=True,
                text=True,
                timeout=5,
            )
            if result.returncode == 0:
                commits = result.stdout.strip().split("\n") if result.stdout.strip() else []
                git_info["recent_commits"] = commits

            return git_info

        except (subprocess.TimeoutExpired, FileNotFoundError):
            return None

    # Core Tools

    def get_briefing(
        self,
        project_path: str,
        focus_areas: Optional[list[str]] = None,
    ) -> dict:
        """Get session briefing with relevant memories.

        This is the entry point - call first at session start.

        Args:
            project_path: Absolute path to the project.
            focus_areas: Optional list of topics to focus on.

        Returns:
            Briefing with recent decisions, warnings, failed approaches, and git info.
        """
        storage = self._get_storage(project_path)
        self._mark_communion(project_path)

        # Get memory counts
        counts = storage.get_memory_counts()

        # Get recent decisions (last 10)
        decisions = storage.get_memories(
            category=MemoryCategory.DECISION,
            limit=10,
        )

        # Get warnings
        warnings = storage.get_warnings(limit=20)

        # Get failed approaches
        failed = storage.get_failed_memories(limit=10)

        # Get patterns
        patterns = storage.get_patterns(limit=10)

        # Build response
        response = BriefingResponse(
            recent_decisions=[
                {
                    "id": m.id,
                    "summary": m.summary(100),
                    "worked": m.worked,
                    "file_path": m.file_path,
                }
                for m in decisions
            ],
            active_warnings=[
                {
                    "id": m.id,
                    "summary": m.summary(100),
                    "file_path": m.file_path,
                }
                for m in warnings
            ],
            failed_approaches=[
                {
                    "id": m.id,
                    "summary": m.summary(100),
                    "outcome": m.outcome,
                    "file_path": m.file_path,
                }
                for m in failed
            ],
            patterns=[
                {
                    "id": m.id,
                    "summary": m.summary(100),
                }
                for m in patterns
            ],
            total_memories=counts["total"],
            total_decisions=counts["decision"],
            total_warnings=counts["warning"],
            total_patterns=counts["pattern"],
            total_learnings=counts["learning"],
            git_changes=self._get_git_info(project_path),
        )

        return response.to_dict()

    def context_check(
        self,
        description: str,
        project_path: str,
    ) -> dict:
        """Check context before making changes.

        Args:
            description: Description of what you intend to do.
            project_path: Absolute path to the project.

        Returns:
            Relevant memories, matching rules, and warnings.
        """
        storage = self._get_storage(project_path)
        search = self._get_search_engine(project_path)

        # Get all memories for search
        memories = storage.get_memories(limit=500)

        # Search for relevant memories
        results = search.search(description, memories, limit=10)

        # Get matching rules
        rules = storage.get_rules()
        matching_rules = search.match_rules(description, rules)

        # Separate by type
        relevant_warnings = [
            r.memory.to_dict() for r in results
            if r.memory.category == MemoryCategory.WARNING
        ]
        relevant_failures = [
            r.memory.to_dict() for r in results
            if r.memory.worked is False
        ]
        relevant_patterns = [
            r.memory.to_dict() for r in results
            if r.memory.category == MemoryCategory.PATTERN
        ]
        relevant_decisions = [
            r.memory.to_dict() for r in results
            if r.memory.category == MemoryCategory.DECISION and r.memory.worked is not False
        ]

        return {
            "description": description,
            "warnings": relevant_warnings,
            "failed_approaches": relevant_failures,
            "patterns": relevant_patterns,
            "related_decisions": relevant_decisions,
            "matching_rules": [
                {
                    "trigger": r.trigger,
                    "must_do": r.must_do,
                    "must_not": r.must_not,
                    "ask_first": r.ask_first,
                }
                for r in matching_rules
            ],
            "advice": self._generate_advice(relevant_warnings, relevant_failures, matching_rules),
        }

    def _generate_advice(
        self,
        warnings: list,
        failures: list,
        rules: list,
    ) -> str:
        """Generate advice based on context."""
        advice_parts = []

        if warnings:
            advice_parts.append(f"CAUTION: {len(warnings)} warning(s) apply to this area.")

        if failures:
            advice_parts.append(f"LEARN FROM PAST: {len(failures)} previous attempt(s) failed here.")

        if rules:
            must_do = []
            must_not = []
            for rule in rules:
                must_do.extend(rule.must_do)
                must_not.extend(rule.must_not)

            if must_do:
                advice_parts.append(f"REQUIRED: {', '.join(must_do[:3])}")
            if must_not:
                advice_parts.append(f"FORBIDDEN: {', '.join(must_not[:3])}")

        return " | ".join(advice_parts) if advice_parts else "No specific guidance found."

    def recall(
        self,
        topic: str,
        project_path: str,
        categories: Optional[list[str]] = None,
        limit: int = 20,
        condensed: bool = False,
    ) -> dict:
        """Recall memories related to a topic.

        Args:
            topic: Topic to search for.
            project_path: Absolute path to the project.
            categories: Optional filter by categories.
            limit: Maximum results.
            condensed: If True, return condensed summaries (50-75% less tokens).

        Returns:
            Matching memories grouped by category.
        """
        storage = self._get_storage(project_path)
        search = self._get_search_engine(project_path)

        # Get all memories
        memories = storage.get_memories(limit=500)

        # Convert category strings to enums
        category_filter = None
        if categories:
            category_filter = [MemoryCategory(c) for c in categories]

        # Search
        results = search.search(topic, memories, limit=limit, categories=category_filter)

        # Increment recall counts
        for result in results:
            if result.memory.id:
                storage.increment_recall_count(result.memory.id)

        # Format results
        if condensed:
            return {
                "topic": topic,
                "total_found": len(results),
                "memories": [
                    {
                        "id": r.memory.id,
                        "category": r.memory.category.value,
                        "summary": r.memory.summary(150),
                        "worked": r.memory.worked,
                        "score": round(r.score, 3),
                    }
                    for r in results
                ],
            }
        else:
            return {
                "topic": topic,
                "total_found": len(results),
                "memories": [r.to_dict() for r in results],
            }

    def recall_for_file(
        self,
        file_path: str,
        project_path: str,
        limit: int = 50,
    ) -> dict:
        """Recall all memories associated with a file.

        Args:
            file_path: Path to the file (relative or absolute).
            project_path: Absolute path to the project.
            limit: Maximum results.

        Returns:
            Memories linked to this file.
        """
        storage = self._get_storage(project_path)

        # Normalize file path
        if not os.path.isabs(file_path):
            file_path = os.path.join(project_path, file_path)

        memories = storage.get_memories_for_file(file_path, limit=limit)

        # Also search by relative path
        rel_path = os.path.relpath(file_path, project_path)
        memories_rel = storage.get_memories_for_file(rel_path, limit=limit)

        # Combine and deduplicate
        seen_ids = set()
        all_memories = []
        for m in memories + memories_rel:
            if m.id not in seen_ids:
                seen_ids.add(m.id)
                all_memories.append(m)

                # Increment recall count
                if m.id:
                    storage.increment_recall_count(m.id)

        # Separate by type
        warnings = [m.to_dict() for m in all_memories if m.category == MemoryCategory.WARNING]
        failures = [m.to_dict() for m in all_memories if m.worked is False]
        patterns = [m.to_dict() for m in all_memories if m.category == MemoryCategory.PATTERN]
        decisions = [m.to_dict() for m in all_memories if m.category == MemoryCategory.DECISION]

        return {
            "file_path": file_path,
            "total_memories": len(all_memories),
            "warnings": warnings,
            "failed_approaches": failures,
            "patterns": patterns,
            "decisions": decisions,
            "attention_needed": len(warnings) > 0 or len(failures) > 0,
        }

    def remember(
        self,
        category: str,
        content: str,
        project_path: str,
        rationale: Optional[str] = None,
        context: Optional[str] = None,
        tags: Optional[list[str]] = None,
        file_path: Optional[str] = None,
    ) -> dict:
        """Remember a new decision, pattern, warning, or learning.

        Args:
            category: One of: decision, pattern, warning, learning.
            content: What to remember.
            project_path: Absolute path to the project.
            rationale: Why this decision was made.
            context: Additional context.
            tags: Optional tags.
            file_path: Associated file path.

        Returns:
            Created memory with ID.
        """
        storage = self._get_storage(project_path)

        # Auto-infer tags
        auto_tags = infer_tags(content, rationale)
        all_tags = list(set((tags or []) + auto_tags))

        memory = Memory(
            category=MemoryCategory(category),
            content=content,
            rationale=rationale,
            context=context,
            tags=all_tags,
            file_path=file_path,
            project_path=project_path,
        )

        created = storage.create_memory(memory)

        return {
            "id": created.id,
            "category": created.category.value,
            "content": created.content,
            "tags": created.tags,
            "message": f"Memory inscribed with ID {created.id}",
        }

    def remember_batch(
        self,
        memories: list[dict],
        project_path: str,
    ) -> dict:
        """Remember multiple memories at once.

        Args:
            memories: List of memory dictionaries.
            project_path: Absolute path to the project.

        Returns:
            Summary with created count and IDs.
        """
        storage = self._get_storage(project_path)
        created_ids = []
        errors = []

        for i, mem_data in enumerate(memories):
            try:
                auto_tags = infer_tags(
                    mem_data.get("content", ""),
                    mem_data.get("rationale"),
                )
                all_tags = list(set(mem_data.get("tags", []) + auto_tags))

                memory = Memory(
                    category=MemoryCategory(mem_data.get("category", "decision")),
                    content=mem_data.get("content", ""),
                    rationale=mem_data.get("rationale"),
                    context=mem_data.get("context"),
                    tags=all_tags,
                    file_path=mem_data.get("file_path"),
                    project_path=project_path,
                )
                created = storage.create_memory(memory)
                created_ids.append(created.id)
            except Exception as e:
                errors.append({"index": i, "error": str(e)})

        return {
            "created_count": len(created_ids),
            "error_count": len(errors),
            "ids": created_ids,
            "errors": errors if errors else None,
        }

    def record_outcome(
        self,
        memory_id: int,
        outcome: str,
        worked: bool,
        project_path: str,
    ) -> dict:
        """Record the outcome of a decision.

        Args:
            memory_id: ID of the memory to update.
            outcome: What actually happened.
            worked: Whether it succeeded.
            project_path: Absolute path to the project.

        Returns:
            Updated memory.
        """
        storage = self._get_storage(project_path)

        memory = storage.get_memory(memory_id)
        if not memory:
            return {"error": f"Memory {memory_id} not found"}

        memory.outcome = outcome
        memory.worked = worked

        updated = storage.update_memory(memory)

        status = "SUCCESS" if worked else "FAILURE"
        return {
            "id": updated.id,
            "outcome": updated.outcome,
            "worked": updated.worked,
            "message": f"Memory {memory_id} sealed with {status}",
        }

    def search_memories(
        self,
        query: str,
        project_path: str,
        limit: int = 20,
    ) -> dict:
        """Search all memories.

        Args:
            query: Search query.
            project_path: Absolute path to the project.
            limit: Maximum results.

        Returns:
            Matching memories with scores.
        """
        storage = self._get_storage(project_path)
        search = self._get_search_engine(project_path)

        memories = storage.get_memories(limit=500)
        results = search.search(query, memories, limit=limit)

        return {
            "query": query,
            "total_found": len(results),
            "results": [r.to_dict() for r in results],
        }

    def find_related(
        self,
        memory_id: int,
        project_path: str,
        limit: int = 10,
    ) -> dict:
        """Find memories related to a specific memory.

        Args:
            memory_id: ID of the memory.
            project_path: Absolute path to the project.
            limit: Maximum results.

        Returns:
            Related memories.
        """
        storage = self._get_storage(project_path)
        search = self._get_search_engine(project_path)

        memory = storage.get_memory(memory_id)
        if not memory:
            return {"error": f"Memory {memory_id} not found"}

        all_memories = storage.get_memories(limit=500)
        similar = search.find_similar(memory, all_memories, limit=limit)

        return {
            "memory_id": memory_id,
            "related": [r.to_dict() for r in similar],
        }

    # Rule Management

    def add_rule(
        self,
        trigger: str,
        project_path: str,
        must_do: Optional[list[str]] = None,
        must_not: Optional[list[str]] = None,
        ask_first: Optional[list[str]] = None,
        warnings: Optional[list[str]] = None,
        priority: int = 10,
    ) -> dict:
        """Add a new rule.

        Args:
            trigger: What action triggers this rule.
            project_path: Absolute path to the project.
            must_do: Required actions.
            must_not: Forbidden actions.
            ask_first: Questions to ask.
            warnings: Warning messages.
            priority: Rule priority (higher = more important).

        Returns:
            Created rule.
        """
        storage = self._get_storage(project_path)

        rule = Rule(
            trigger=trigger,
            must_do=must_do or [],
            must_not=must_not or [],
            ask_first=ask_first or [],
            warnings=warnings or [],
            priority=priority,
            project_path=project_path,
        )

        created = storage.create_rule(rule)

        return {
            "id": created.id,
            "trigger": created.trigger,
            "message": f"Rule inscribed with ID {created.id}",
        }

    def update_rule(
        self,
        rule_id: int,
        project_path: str,
        must_do: Optional[list[str]] = None,
        must_not: Optional[list[str]] = None,
        ask_first: Optional[list[str]] = None,
        warnings: Optional[list[str]] = None,
        priority: Optional[int] = None,
        enabled: Optional[bool] = None,
    ) -> dict:
        """Update an existing rule.

        Args:
            rule_id: ID of the rule to update.
            project_path: Absolute path to the project.
            must_do: New required actions (replaces existing).
            must_not: New forbidden actions (replaces existing).
            ask_first: New questions (replaces existing).
            warnings: New warnings (replaces existing).
            priority: New priority.
            enabled: Enable/disable rule.

        Returns:
            Updated rule.
        """
        storage = self._get_storage(project_path)

        rule = storage.get_rule(rule_id)
        if not rule:
            return {"error": f"Rule {rule_id} not found"}

        if must_do is not None:
            rule.must_do = must_do
        if must_not is not None:
            rule.must_not = must_not
        if ask_first is not None:
            rule.ask_first = ask_first
        if warnings is not None:
            rule.warnings = warnings
        if priority is not None:
            rule.priority = priority
        if enabled is not None:
            rule.enabled = enabled

        updated = storage.update_rule(rule)

        return updated.to_dict()

    def list_rules(
        self,
        project_path: str,
        enabled_only: bool = True,
        limit: int = 100,
    ) -> dict:
        """List all rules.

        Args:
            project_path: Absolute path to the project.
            enabled_only: Only return enabled rules.
            limit: Maximum results.

        Returns:
            List of rules.
        """
        storage = self._get_storage(project_path)
        rules = storage.get_rules(enabled_only=enabled_only, limit=limit)

        return {
            "total": len(rules),
            "rules": [r.to_dict() for r in rules],
        }

    def check_rules(
        self,
        action: str,
        project_path: str,
    ) -> dict:
        """Check which rules apply to an action.

        Args:
            action: Description of the action.
            project_path: Absolute path to the project.

        Returns:
            Matching rules with guidance.
        """
        storage = self._get_storage(project_path)
        search = self._get_search_engine(project_path)

        rules = storage.get_rules()
        matching = search.match_rules(action, rules)

        # Aggregate guidance
        must_do = []
        must_not = []
        ask_first = []
        warnings = []

        for rule in matching:
            must_do.extend(rule.must_do)
            must_not.extend(rule.must_not)
            ask_first.extend(rule.ask_first)
            warnings.extend(rule.warnings)

        return {
            "action": action,
            "matching_rules": len(matching),
            "must_do": list(set(must_do)),
            "must_not": list(set(must_not)),
            "ask_first": list(set(ask_first)),
            "warnings": list(set(warnings)),
        }

    # Memory Management

    def pin_memory(
        self,
        memory_id: int,
        pinned: bool,
        project_path: str,
    ) -> dict:
        """Pin or unpin a memory.

        Args:
            memory_id: ID of the memory.
            pinned: Whether to pin.
            project_path: Absolute path to the project.

        Returns:
            Updated memory status.
        """
        storage = self._get_storage(project_path)

        memory = storage.get_memory(memory_id)
        if not memory:
            return {"error": f"Memory {memory_id} not found"}

        memory.pinned = pinned
        storage.update_memory(memory)

        action = "pinned" if pinned else "unpinned"
        return {
            "id": memory_id,
            "pinned": pinned,
            "message": f"Memory {memory_id} {action}",
        }

    def archive_memory(
        self,
        memory_id: int,
        archived: bool,
        project_path: str,
    ) -> dict:
        """Archive or unarchive a memory.

        Args:
            memory_id: ID of the memory.
            archived: Whether to archive.
            project_path: Absolute path to the project.

        Returns:
            Updated memory status.
        """
        storage = self._get_storage(project_path)

        memory = storage.get_memory(memory_id)
        if not memory:
            return {"error": f"Memory {memory_id} not found"}

        memory.archived = archived
        storage.update_memory(memory)

        action = "archived" if archived else "restored"
        return {
            "id": memory_id,
            "archived": archived,
            "message": f"Memory {memory_id} {action}",
        }

    # Maintenance

    def health(self, project_path: str) -> dict:
        """Get health status.

        Args:
            project_path: Absolute path to the project.

        Returns:
            Health status with statistics.
        """
        storage = self._get_storage(project_path)
        counts = storage.get_memory_counts()

        return {
            "status": "healthy",
            "version": "0.1.0",
            "project_path": project_path,
            "storage_path": storage.db_path,
            "memory_counts": counts,
            "rule_count": len(storage.get_rules(enabled_only=False)),
        }

    def export_data(self, project_path: str) -> dict:
        """Export all data.

        Args:
            project_path: Absolute path to the project.

        Returns:
            Exported data.
        """
        storage = self._get_storage(project_path)
        return storage.export_data()

    def import_data(
        self,
        data: dict,
        project_path: str,
        merge: bool = True,
    ) -> dict:
        """Import data.

        Args:
            data: Data to import.
            project_path: Absolute path to the project.
            merge: Whether to merge with existing data.

        Returns:
            Import statistics.
        """
        storage = self._get_storage(project_path)
        return storage.import_data(data, merge=merge)


# Global server instance
_server: Optional[Daem0nMCPServer] = None


def get_server() -> Daem0nMCPServer:
    """Get or create the global server instance."""
    global _server
    if _server is None:
        _server = Daem0nMCPServer()
    return _server


# MCP Tool definitions for FastMCP integration
def create_mcp_app():
    """Create FastMCP application with all tools.

    Returns:
        FastMCP application instance.
    """
    try:
        from fastmcp import FastMCP
    except ImportError:
        raise ImportError(
            "fastmcp is required for MCP server mode. "
            "Install with: pip install fastmcp"
        )

    mcp = FastMCP("daem0nmcp")
    server = get_server()

    @mcp.tool()
    def get_briefing(
        project_path: str,
        focus_areas: Optional[list[str]] = None,
    ) -> dict:
        """Get session briefing - call first at session start."""
        return server.get_briefing(project_path, focus_areas)

    @mcp.tool()
    def context_check(description: str, project_path: str) -> dict:
        """Check context before making changes."""
        return server.context_check(description, project_path)

    @mcp.tool()
    def recall(
        topic: str,
        project_path: str,
        categories: Optional[list[str]] = None,
        limit: int = 20,
        condensed: bool = False,
    ) -> dict:
        """Recall memories related to a topic."""
        return server.recall(topic, project_path, categories, limit, condensed)

    @mcp.tool()
    def recall_for_file(
        file_path: str,
        project_path: str,
        limit: int = 50,
    ) -> dict:
        """Recall all memories associated with a file."""
        return server.recall_for_file(file_path, project_path, limit)

    @mcp.tool()
    def remember(
        category: str,
        content: str,
        project_path: str,
        rationale: Optional[str] = None,
        context: Optional[str] = None,
        tags: Optional[list[str]] = None,
        file_path: Optional[str] = None,
    ) -> dict:
        """Remember a new decision, pattern, warning, or learning."""
        return server.remember(
            category, content, project_path, rationale, context, tags, file_path
        )

    @mcp.tool()
    def remember_batch(memories: list[dict], project_path: str) -> dict:
        """Remember multiple memories at once."""
        return server.remember_batch(memories, project_path)

    @mcp.tool()
    def record_outcome(
        memory_id: int,
        outcome: str,
        worked: bool,
        project_path: str,
    ) -> dict:
        """Record the outcome of a decision."""
        return server.record_outcome(memory_id, outcome, worked, project_path)

    @mcp.tool()
    def search_memories(query: str, project_path: str, limit: int = 20) -> dict:
        """Search all memories."""
        return server.search_memories(query, project_path, limit)

    @mcp.tool()
    def find_related(memory_id: int, project_path: str, limit: int = 10) -> dict:
        """Find memories related to a specific memory."""
        return server.find_related(memory_id, project_path, limit)

    @mcp.tool()
    def add_rule(
        trigger: str,
        project_path: str,
        must_do: Optional[list[str]] = None,
        must_not: Optional[list[str]] = None,
        ask_first: Optional[list[str]] = None,
        warnings: Optional[list[str]] = None,
        priority: int = 10,
    ) -> dict:
        """Add a new rule."""
        return server.add_rule(
            trigger, project_path, must_do, must_not, ask_first, warnings, priority
        )

    @mcp.tool()
    def update_rule(
        rule_id: int,
        project_path: str,
        must_do: Optional[list[str]] = None,
        must_not: Optional[list[str]] = None,
        ask_first: Optional[list[str]] = None,
        warnings: Optional[list[str]] = None,
        priority: Optional[int] = None,
        enabled: Optional[bool] = None,
    ) -> dict:
        """Update an existing rule."""
        return server.update_rule(
            rule_id, project_path, must_do, must_not, ask_first, warnings, priority, enabled
        )

    @mcp.tool()
    def list_rules(
        project_path: str,
        enabled_only: bool = True,
        limit: int = 100,
    ) -> dict:
        """List all rules."""
        return server.list_rules(project_path, enabled_only, limit)

    @mcp.tool()
    def check_rules(action: str, project_path: str) -> dict:
        """Check which rules apply to an action."""
        return server.check_rules(action, project_path)

    @mcp.tool()
    def pin_memory(memory_id: int, pinned: bool, project_path: str) -> dict:
        """Pin or unpin a memory."""
        return server.pin_memory(memory_id, pinned, project_path)

    @mcp.tool()
    def archive_memory(memory_id: int, archived: bool, project_path: str) -> dict:
        """Archive or unarchive a memory."""
        return server.archive_memory(memory_id, archived, project_path)

    @mcp.tool()
    def health(project_path: str) -> dict:
        """Get health status."""
        return server.health(project_path)

    @mcp.tool()
    def export_data(project_path: str) -> dict:
        """Export all data."""
        return server.export_data(project_path)

    @mcp.tool()
    def import_data(data: dict, project_path: str, merge: bool = True) -> dict:
        """Import data."""
        return server.import_data(data, project_path, merge)

    return mcp


if __name__ == "__main__":
    # Run the MCP server
    app = create_mcp_app()
    app.run()
