# Memory Bank Index

This memory bank contains standardized documentation for the SonarQube Open Server project setup using Docker Compose.

## Purpose

This memory bank serves as a knowledge base following standardized patterns for cross-agent collaboration, tracking decisions, progress, architectural choices, and patterns used in the implementation.

## Schema Version

**Version**: 2.0.0
**Compliance**: All entries follow the standardized schema defined in `schema.json`

## Memory Types

This memory bank supports the following standardized types:

- **context**: Active project context and current state
- **decision**: Important decisions made during development
- **progress**: Project progress tracking and milestones
- **brief**: Project overview and purpose
- **pattern**: System patterns and development patterns
- **architect**: System architecture decisions and design patterns
- **troubleshoot**: Problem-solving documentation
- **reference**: Quick reference information and documentation

## Active Memories

### Core Documentation

- **[Active Context](./activeContext.md)**: Current project state and focus areas
- **[Project Brief](./projectBrief.md)**: Project purpose and target users
- **[Project Architect](./architect.md)**: Architectural decisions and rationale

### Templates

Standardized templates are available in `templates/` directory for creating new memory entries:

- `context.md` - Current state documentation
- `decision.md` - Decision logging
- `progress.md` - Progress tracking
- `brief.md` - Project briefs
- `pattern.md` - Design patterns
- `architect.md` - Architecture documentation
- `troubleshoot.md` - Problem-solving
- `reference.md` - Reference documentation

## Schema Compliance

All memory entries MUST conform to the standardized schema defined in [schema.json](./schema.json) v2.0.0:

### Required Fields
- `id`: Unique identifier (kebab-case)
- `title`: Human-readable title (1-100 characters)
- `type`: Memory entry type (enum)
- `tags`: Array of lowercase, kebab-case tags (minimum 1)
- `updated_at`: ISO 8601 timestamp

### Optional Fields
- `status`: active (default), archived, or draft
- `priority`: low, medium, high, or critical
- `related`: Array of related memory entry IDs

## Standardized Tags

Consistent tagging vocabulary across all entries:

- `docker`: Docker and containerization
- `sonarqube`: SonarQube server setup
- `postgres`: PostgreSQL database configuration
- `infrastructure`: Infrastructure and deployment setup
- `security`: Security configurations and considerations
- `development`: Development workflow and practices
- `troubleshoot`: Problem-solving and debugging
- `reference`: Reference documentation and guides

## Guidelines

Detailed guidelines for creating and maintaining memory entries are available in [GUIDELINES.md](./GUIDELINES.md), including:

- Schema compliance requirements
- Content structure standards
- Naming conventions
- Maintenance procedures
- Agent collaboration protocols

## Usage Guidelines

- Keep entries focused and atomic (one logical memory entry per file)
- Update timestamps whenever content changes
- Use consistent tagging for discoverability
- Cross-reference related entries where appropriate
- Archive outdated entries rather than deleting them

## Maintenance

Regular maintenance tasks:

- Review and update timestamps monthly
- Archive completed phases or outdated decisions
- Validate schema compliance
- Clean up redundant or merged entries

---

_Schema version: 2.0.0 | Last updated: 2025-09-18T08:31:00Z_
