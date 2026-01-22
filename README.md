# Daem0nMCP

Persistent AI memory management for Claude Code/Desktop.

## Overview

Daem0nMCP is a Model Context Protocol (MCP) server that gives Claude persistent memory across sessions. It enables:

- **Decision tracking** - Remember architectural choices with rationale
- **Pattern recognition** - Store recurring approaches that work
- **Warning system** - Track things to avoid
- **Learning from failures** - Failed decisions get amplified in future recalls
- **Rule enforcement** - Define must-do/must-not rules for actions

## Installation

```bash
# Clone the repository
git clone <repository-url>
cd grimoire

# Install in development mode
pip install -e .

# Or install with MCP server support
pip install -e ".[dev]"
```

## Quick Start

### CLI Usage

```bash
# Get session briefing (call first!)
daem0nmcp briefing

# Check context before changes
daem0nmcp context "adding user authentication"

# Remember a decision
daem0nmcp remember decision "Use JWT for auth" -r "Stateless, scales horizontally"

# Record outcome
daem0nmcp record-outcome 1 "Works great, load tests pass" --worked

# Search memories
daem0nmcp search "authentication"

# Recall memories for a file
daem0nmcp recall-file src/auth.py
```

### Python API

```python
from daem0nmcp.server import Daem0nMCPServer

server = Daem0nMCPServer()
project_path = "/path/to/your/project"

# Get briefing
briefing = server.get_briefing(project_path)

# Remember a decision
result = server.remember(
    category="decision",
    content="Use PostgreSQL for the database",
    rationale="ACID compliance needed for financial data",
    project_path=project_path,
    file_path="src/database.py",
)

# Record outcome
server.record_outcome(
    memory_id=result["id"],
    outcome="Working well, handles 10k TPS",
    worked=True,
    project_path=project_path,
)

# Search
results = server.search_memories("database", project_path)
```

## Memory Categories

| Category | Persistence | Purpose |
|----------|-------------|---------|
| `decision` | 30-day half-life | Architectural/design choices |
| `pattern` | **Eternal** | Recurring approaches to follow |
| `warning` | **Eternal** | Things to avoid |
| `learning` | 30-day half-life | Lessons from experience |

## Core Commands

### Session Management

- `briefing` - Get session briefing with recent decisions, warnings, failures
- `context <description>` - Check context before making changes
- `health` - Get server health and statistics

### Memory Operations

- `remember <category> <content>` - Create a new memory
- `recall <topic>` - Search memories by topic
- `recall-file <path>` - Get memories for a specific file
- `search <query>` - Full-text search across memories
- `record-outcome <id> <outcome>` - Record decision outcome

### Rule Management

- `add-rule <trigger>` - Add a new rule
- `list-rules` - List all rules
- `check-rules <action>` - Check which rules apply

### Data Management

- `export` - Export all memories and rules
- `import <file>` - Import from backup

## The Protocol

Follow this workflow for best results:

1. **Session Start** → `briefing`
2. **Before Changes** → `context "<what you plan to do>"`
3. **After Decisions** → `remember decision "<what you decided>" -r "<why>"`
4. **After Testing** → `record-outcome <id> "<result>" --worked/--failed`

## Storage

Data is stored per-project at:
```
<project>/.daem0nmcp/storage/daem0nmcp.db
```

## Features

### Failed Decision Amplification
Failed decisions receive 1.5x relevance boost in future recalls - learn from mistakes.

### Auto Tag Inference
Tags are automatically inferred from content:
- "fix", "bug" → `bugfix`
- "cache", "performance" → `perf`
- "security", "auth" → `security`

### Git Integration
The briefing includes git status - uncommitted changes, current branch, recent commits.

## MCP Server Mode

To run as an MCP server for Claude Code/Desktop:

```bash
# Requires fastmcp
pip install fastmcp

# Run the server
daem0nmcp serve

# Or directly
python -m daem0nmcp.server
```

Add to Claude Code:
```bash
claude mcp add daem0nmcp -- python -m daem0nmcp.server
```

## License

MIT
