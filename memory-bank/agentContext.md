# Agent Active Context

## Purpose
Track active agent sessions and maintain context continuity across conversations. Each agent maintains their own UUID and updates this file with their current activities.

## Schema

### Agent Entry Format
```yaml
agent_id: UUID (e.g., claude-sonnet-4-20250918-001)
session_start: ISO timestamp
last_update: ISO timestamp
status: active|paused|completed
current_tasks: Array of active tasks
context_summary: Brief description of what agent is working on
memory_references: Links to relevant memory bank entries
```

## Active Sessions

### claude-sonnet-4-20250918-001
- **Session Start**: 2025-09-18T[current_time]
- **Last Update**: 2025-09-21T[current_time]
- **Status**: paused
- **Current Tasks**:
  - Creating agent active context system
  - Reviewing v2 memory bank implementation
  - Updating memory bank with session context
- **Context Summary**: Resuming work on v2 memory bank after VSCode extension conflicts caused by diagram rendering. User had to reload VSCode. Working on implementing agent UUID tracking system.
- **Memory References**:
  - memory-bank/progress.md (for v2 implementation status)
  - memory-bank/systemPatterns.md (for architectural patterns)

### gemini-20250921-001
- **Session Start**: 2025-09-21T[current_time]
- **Last Update**: 2025-09-21T[current_time]
- **Status**: active
- **Current Tasks**:
  - Updating memory bank with current session context.
  - Implementing agent UUID continuity system.
- **Context Summary**: I am Gemini, a new agent on this project. I have reviewed the `memory-bank` to understand the project's context. I am now updating the `agentContext.md` file to reflect my presence and the tasks I am working on.
- **Memory References**:
  - memory-bank/progress.md
  - memory-bank/agentContext.md

## Session History
- Previous session worked on v2 memory bank implementation
- VSCode extension conflicts occurred with diagram rendering
- User had to reload VSCode, breaking conversation context
- Plugin removal and service restart resolved SonarQube issues

## Notes
- Agents should update their entry whenever starting new tasks
- Include references to memory bank entries being modified
- Track decision points and architectural changes
- Maintain continuity for future agents picking up work