"""
CLI interface for Daem0nMCP.

Provides command-line access to memory management functions.
"""

import json
import os
import sys
from typing import Optional

import click

from daem0nmcp import __version__
from daem0nmcp.server import Daem0nMCPServer, get_server


def get_project_path(ctx_project_path: Optional[str] = None) -> str:
    """Get project path from argument or current directory."""
    if ctx_project_path:
        return os.path.abspath(ctx_project_path)
    return os.getcwd()


def output_json(data: dict) -> None:
    """Output data as JSON."""
    click.echo(json.dumps(data, indent=2, default=str))


def output_text(message: str) -> None:
    """Output a text message."""
    click.echo(message)


@click.group()
@click.version_option(version=__version__, prog_name="daem0nmcp")
@click.option(
    "--project", "-p",
    help="Project path (defaults to current directory)",
    type=click.Path(exists=True),
)
@click.option("--json", "use_json", is_flag=True, help="Output as JSON")
@click.pass_context
def main(ctx: click.Context, project: Optional[str], use_json: bool) -> None:
    """Daem0nMCP - Persistent AI Memory Management.

    The Daem0n remembers your decisions, learns from failures,
    and provides context across sessions.
    """
    ctx.ensure_object(dict)
    ctx.obj["project_path"] = get_project_path(project)
    ctx.obj["use_json"] = use_json
    ctx.obj["server"] = get_server()


@main.command()
@click.pass_context
def briefing(ctx: click.Context) -> None:
    """Get session briefing (call first at session start)."""
    server: Daem0nMCPServer = ctx.obj["server"]
    project_path = ctx.obj["project_path"]

    result = server.get_briefing(project_path)

    if ctx.obj["use_json"]:
        output_json(result)
    else:
        output_text("\n=== Daem0n Briefing ===\n")
        output_text(f"Project: {project_path}")
        output_text(f"Total Memories: {result['total_memories']}")
        output_text(f"  - Decisions: {result['total_decisions']}")
        output_text(f"  - Warnings: {result['total_warnings']}")
        output_text(f"  - Patterns: {result['total_patterns']}")
        output_text(f"  - Learnings: {result['total_learnings']}")

        if result["active_warnings"]:
            output_text("\n--- Active Warnings ---")
            for w in result["active_warnings"]:
                output_text(f"  [{w['id']}] {w['summary']}")

        if result["failed_approaches"]:
            output_text("\n--- Failed Approaches ---")
            for f in result["failed_approaches"]:
                output_text(f"  [{f['id']}] {f['summary']}")

        if result["recent_decisions"]:
            output_text("\n--- Recent Decisions ---")
            for d in result["recent_decisions"][:5]:
                status = "✓" if d["worked"] else ("✗" if d["worked"] is False else "?")
                output_text(f"  [{d['id']}] {status} {d['summary']}")

        if result.get("git_changes"):
            git = result["git_changes"]
            output_text(f"\n--- Git Status ---")
            output_text(f"  Branch: {git.get('branch', 'unknown')}")
            changes = git.get("uncommitted_changes", [])
            if changes:
                output_text(f"  Uncommitted: {len(changes)} file(s)")


@main.command()
@click.argument("description")
@click.pass_context
def context(ctx: click.Context, description: str) -> None:
    """Check context before making changes."""
    server: Daem0nMCPServer = ctx.obj["server"]
    project_path = ctx.obj["project_path"]

    result = server.context_check(description, project_path)

    if ctx.obj["use_json"]:
        output_json(result)
    else:
        output_text(f"\n=== Context Check: {description} ===\n")
        output_text(f"Advice: {result['advice']}")

        if result["warnings"]:
            output_text("\n--- Warnings ---")
            for w in result["warnings"]:
                output_text(f"  - {w['content'][:100]}")

        if result["failed_approaches"]:
            output_text("\n--- Past Failures ---")
            for f in result["failed_approaches"]:
                output_text(f"  - {f['content'][:100]}")

        if result["matching_rules"]:
            output_text("\n--- Matching Rules ---")
            for r in result["matching_rules"]:
                output_text(f"  Trigger: {r['trigger']}")
                if r["must_do"]:
                    output_text(f"    Must do: {', '.join(r['must_do'])}")
                if r["must_not"]:
                    output_text(f"    Must not: {', '.join(r['must_not'])}")


@main.command()
@click.argument("topic")
@click.option("--limit", "-l", default=20, help="Maximum results")
@click.option("--condensed", "-c", is_flag=True, help="Condensed output")
@click.option("--category", "-t", multiple=True, help="Filter by category")
@click.pass_context
def recall(
    ctx: click.Context,
    topic: str,
    limit: int,
    condensed: bool,
    category: tuple,
) -> None:
    """Recall memories related to a topic."""
    server: Daem0nMCPServer = ctx.obj["server"]
    project_path = ctx.obj["project_path"]

    categories = list(category) if category else None
    result = server.recall(topic, project_path, categories, limit, condensed)

    if ctx.obj["use_json"]:
        output_json(result)
    else:
        output_text(f"\n=== Recall: {topic} ({result['total_found']} found) ===\n")
        for m in result["memories"]:
            if condensed:
                status = "✓" if m.get("worked") else ("✗" if m.get("worked") is False else " ")
                output_text(f"  [{m['id']}] {status} [{m['category']}] {m['summary']}")
            else:
                mem = m["memory"]
                output_text(f"  [{mem['id']}] [{mem['category']}]")
                output_text(f"    {mem['content'][:150]}")
                if mem.get("rationale"):
                    output_text(f"    Why: {mem['rationale'][:100]}")


@main.command("recall-file")
@click.argument("file_path")
@click.pass_context
def recall_file(ctx: click.Context, file_path: str) -> None:
    """Recall memories for a specific file."""
    server: Daem0nMCPServer = ctx.obj["server"]
    project_path = ctx.obj["project_path"]

    result = server.recall_for_file(file_path, project_path)

    if ctx.obj["use_json"]:
        output_json(result)
    else:
        attention = "⚠️  ATTENTION NEEDED" if result["attention_needed"] else ""
        output_text(f"\n=== Memories for {file_path} {attention} ===\n")
        output_text(f"Total: {result['total_memories']}")

        if result["warnings"]:
            output_text("\n--- Warnings ---")
            for w in result["warnings"]:
                output_text(f"  [{w['id']}] {w['content'][:100]}")

        if result["failed_approaches"]:
            output_text("\n--- Failed Approaches ---")
            for f in result["failed_approaches"]:
                output_text(f"  [{f['id']}] {f['content'][:100]}")

        if result["decisions"]:
            output_text("\n--- Decisions ---")
            for d in result["decisions"][:5]:
                output_text(f"  [{d['id']}] {d['content'][:100]}")


@main.command()
@click.argument("category", type=click.Choice(["decision", "pattern", "warning", "learning"]))
@click.argument("content")
@click.option("--rationale", "-r", help="Why this decision was made")
@click.option("--file", "-f", "file_path", help="Associated file path")
@click.option("--tag", "-t", multiple=True, help="Tags")
@click.pass_context
def remember(
    ctx: click.Context,
    category: str,
    content: str,
    rationale: Optional[str],
    file_path: Optional[str],
    tag: tuple,
) -> None:
    """Remember a new decision, pattern, warning, or learning."""
    server: Daem0nMCPServer = ctx.obj["server"]
    project_path = ctx.obj["project_path"]

    result = server.remember(
        category=category,
        content=content,
        project_path=project_path,
        rationale=rationale,
        file_path=file_path,
        tags=list(tag) if tag else None,
    )

    if ctx.obj["use_json"]:
        output_json(result)
    else:
        output_text(f"✓ {result['message']}")
        output_text(f"  Category: {result['category']}")
        if result["tags"]:
            output_text(f"  Tags: {', '.join(result['tags'])}")


@main.command("record-outcome")
@click.argument("memory_id", type=int)
@click.argument("outcome")
@click.option("--worked/--failed", default=True, help="Whether it worked")
@click.pass_context
def record_outcome(
    ctx: click.Context,
    memory_id: int,
    outcome: str,
    worked: bool,
) -> None:
    """Record the outcome of a decision."""
    server: Daem0nMCPServer = ctx.obj["server"]
    project_path = ctx.obj["project_path"]

    result = server.record_outcome(memory_id, outcome, worked, project_path)

    if ctx.obj["use_json"]:
        output_json(result)
    else:
        if "error" in result:
            output_text(f"✗ Error: {result['error']}")
        else:
            output_text(f"✓ {result['message']}")


@main.command()
@click.argument("query")
@click.option("--limit", "-l", default=20, help="Maximum results")
@click.pass_context
def search(ctx: click.Context, query: str, limit: int) -> None:
    """Search all memories."""
    server: Daem0nMCPServer = ctx.obj["server"]
    project_path = ctx.obj["project_path"]

    result = server.search_memories(query, project_path, limit)

    if ctx.obj["use_json"]:
        output_json(result)
    else:
        output_text(f"\n=== Search: {query} ({result['total_found']} found) ===\n")
        for r in result["results"]:
            mem = r["memory"]
            score = r["score"]
            output_text(f"  [{mem['id']}] (score: {score:.3f}) [{mem['category']}]")
            output_text(f"    {mem['content'][:100]}")


@main.command("add-rule")
@click.argument("trigger")
@click.option("--must-do", "-d", multiple=True, help="Required actions")
@click.option("--must-not", "-n", multiple=True, help="Forbidden actions")
@click.option("--ask-first", "-a", multiple=True, help="Questions to ask")
@click.option("--priority", "-p", default=10, help="Rule priority")
@click.pass_context
def add_rule(
    ctx: click.Context,
    trigger: str,
    must_do: tuple,
    must_not: tuple,
    ask_first: tuple,
    priority: int,
) -> None:
    """Add a new rule."""
    server: Daem0nMCPServer = ctx.obj["server"]
    project_path = ctx.obj["project_path"]

    result = server.add_rule(
        trigger=trigger,
        project_path=project_path,
        must_do=list(must_do) if must_do else None,
        must_not=list(must_not) if must_not else None,
        ask_first=list(ask_first) if ask_first else None,
        priority=priority,
    )

    if ctx.obj["use_json"]:
        output_json(result)
    else:
        output_text(f"✓ {result['message']}")


@main.command("list-rules")
@click.option("--all", "show_all", is_flag=True, help="Include disabled rules")
@click.pass_context
def list_rules(ctx: click.Context, show_all: bool) -> None:
    """List all rules."""
    server: Daem0nMCPServer = ctx.obj["server"]
    project_path = ctx.obj["project_path"]

    result = server.list_rules(project_path, enabled_only=not show_all)

    if ctx.obj["use_json"]:
        output_json(result)
    else:
        output_text(f"\n=== Rules ({result['total']} total) ===\n")
        for r in result["rules"]:
            status = "✓" if r["enabled"] else "✗"
            output_text(f"  [{r['id']}] {status} {r['trigger']} (priority: {r['priority']})")
            if r["must_do"]:
                output_text(f"    Must do: {', '.join(r['must_do'])}")
            if r["must_not"]:
                output_text(f"    Must not: {', '.join(r['must_not'])}")


@main.command("check-rules")
@click.argument("action")
@click.pass_context
def check_rules(ctx: click.Context, action: str) -> None:
    """Check which rules apply to an action."""
    server: Daem0nMCPServer = ctx.obj["server"]
    project_path = ctx.obj["project_path"]

    result = server.check_rules(action, project_path)

    if ctx.obj["use_json"]:
        output_json(result)
    else:
        output_text(f"\n=== Rules for: {action} ===\n")
        output_text(f"Matching rules: {result['matching_rules']}")

        if result["must_do"]:
            output_text(f"\nMust do:")
            for item in result["must_do"]:
                output_text(f"  - {item}")

        if result["must_not"]:
            output_text(f"\nMust NOT do:")
            for item in result["must_not"]:
                output_text(f"  - {item}")

        if result["ask_first"]:
            output_text(f"\nAsk first:")
            for item in result["ask_first"]:
                output_text(f"  - {item}")


@main.command()
@click.pass_context
def health(ctx: click.Context) -> None:
    """Get health status."""
    server: Daem0nMCPServer = ctx.obj["server"]
    project_path = ctx.obj["project_path"]

    result = server.health(project_path)

    if ctx.obj["use_json"]:
        output_json(result)
    else:
        output_text(f"\n=== Daem0n Health ===\n")
        output_text(f"Status: {result['status']}")
        output_text(f"Version: {result['version']}")
        output_text(f"Project: {result['project_path']}")
        output_text(f"Storage: {result['storage_path']}")
        output_text(f"\nMemories:")
        for k, v in result["memory_counts"].items():
            output_text(f"  {k}: {v}")
        output_text(f"\nRules: {result['rule_count']}")


@main.command()
@click.option("--output", "-o", help="Output file path", type=click.Path())
@click.pass_context
def export(ctx: click.Context, output: Optional[str]) -> None:
    """Export all data."""
    server: Daem0nMCPServer = ctx.obj["server"]
    project_path = ctx.obj["project_path"]

    result = server.export_data(project_path)

    if output:
        with open(output, "w") as f:
            json.dump(result, f, indent=2, default=str)
        output_text(f"✓ Exported to {output}")
    else:
        output_json(result)


@main.command("import")
@click.argument("input_file", type=click.Path(exists=True))
@click.option("--replace", is_flag=True, help="Replace existing data (default: merge)")
@click.pass_context
def import_data(ctx: click.Context, input_file: str, replace: bool) -> None:
    """Import data from file."""
    server: Daem0nMCPServer = ctx.obj["server"]
    project_path = ctx.obj["project_path"]

    with open(input_file) as f:
        data = json.load(f)

    result = server.import_data(data, project_path, merge=not replace)

    if ctx.obj["use_json"]:
        output_json(result)
    else:
        output_text(f"✓ Imported {result['memories_imported']} memories")
        output_text(f"✓ Imported {result['rules_imported']} rules")


@main.command()
def serve() -> None:
    """Run the MCP server."""
    try:
        from daem0nmcp.server import create_mcp_app
        app = create_mcp_app()
        output_text("Starting Daem0nMCP server...")
        app.run()
    except ImportError as e:
        output_text(f"Error: {e}")
        output_text("Install fastmcp with: pip install fastmcp")
        sys.exit(1)


if __name__ == "__main__":
    main()
