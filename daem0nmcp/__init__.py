"""
Daem0nMCP - Persistent AI Memory Management for Claude Code/Desktop

A Model Context Protocol (MCP) server that provides persistent memory
across Claude sessions, enabling decision tracking, pattern recognition,
and learning from past outcomes.
"""

__version__ = "0.1.0"
__author__ = "Daem0n"

from daem0nmcp.models import Memory, MemoryCategory, Rule
from daem0nmcp.storage import Storage
from daem0nmcp.search import SearchEngine

__all__ = [
    "__version__",
    "Memory",
    "MemoryCategory",
    "Rule",
    "Storage",
    "SearchEngine",
]
