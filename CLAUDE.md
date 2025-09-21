# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Docker Compose-based SonarQube Open Server setup with PostgreSQL database. The project provides a containerized local development environment for SonarQube code analysis.

## Architecture

### Core Components
- **SonarQube Community Edition 10.7**: Main static analysis server
- **PostgreSQL 15 Alpine**: Database backend for SonarQube data persistence
- **Docker Compose**: Orchestration layer with volume persistence and networking

### Key Files
- `docker-compose.yml`: Main service definitions and container orchestration
- `docker-compose.override.yml`: Development-specific overrides
- `.env`: Environment variables for database credentials and JVM settings
- `sonar.properties`: SonarQube server configuration
- `memory-bank/`: Knowledge base tracking architectural decisions and patterns

### Volume Structure
- `sonarqube_data`: SonarQube configuration and analysis data
- `sonarqube_extensions`: Custom extensions and plugins
- `sonarqube_plugins`: SonarQube bundled plugins
- `postgresql_data`: PostgreSQL database persistence

## Development Commands

### Service Management
```bash
# Start all services (primary command)
docker-compose up -d

# View service logs (for debugging)
docker-compose logs -f

# View specific service logs
docker-compose logs sonarqube
docker-compose logs db

# Stop all services
docker-compose down

# Restart services (after config changes)
docker-compose restart

# Check service status
docker-compose ps
```

### Configuration Updates
```bash
# After modifying .env or sonar.properties
docker-compose down && docker-compose up -d

# Restart only SonarQube (for property changes)
docker-compose restart sonarqube
```

### Plugin Management
```bash
# Install new plugins (place JAR in ./plugins/ then restart)
docker-compose restart sonarqube
```

### Code Analysis Examples
```bash
# Using SonarScanner CLI
sonar-scanner \
  -Dsonar.projectKey=myproject \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=your-token

# Using Maven
mvn sonar:sonar \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=your-token

# Using Gradle
./gradlew sonarqube \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=your-token
```

### Troubleshooting Commands
```bash
# Check port availability
netstat -tulpn | grep :9000

# Database connectivity test
docker-compose exec sonarqube curl -f http://db:5432

# Memory and resource monitoring
docker stats
```

### Backup Operations
```bash
# Backup persistent volumes
docker run --rm -v sonarqube-local_postgresql_data:/data -v $(pwd):/backup alpine tar czf /backup/postgresql_backup.tar.gz -C /data .
docker run --rm -v sonarqube-local_sonarqube_data:/data -v $(pwd):/backup alpine tar czf /backup/sonarqube_backup.tar.gz -C /data .
```

## Configuration Management

### Environment Variables
Key variables in `.env`:
- Database credentials (POSTGRES_USER, POSTGRES_PASSWORD)
- JVM memory settings (SONAR_WEB_JAVA_OPTS, SONAR_CE_JAVA_OPTS)
- Logging levels (SONAR_LOG_LEVEL)
- Timezone configuration (TZ)

### Memory Tuning
Adjust JVM settings in `.env` based on system resources:
- Web server: `-Xmx1g -Xms256m` (default)
- Compute engine: `-Xmx2g -Xms1g` (default)
- Search: `-Xms512m -Xmx512m` (default)

### Security Considerations
- Default credentials: admin/admin (change after first login)
- Database uses default credentials (change for production)
- SSL/TLS termination should be configured via reverse proxy
- Consider Docker secrets for production deployments

## Development Workflow

1. **Initial Setup**: Run `docker-compose up -d` and wait 2-5 minutes for initialization
2. **Access**: Navigate to http://localhost:9000 (admin/admin)
3. **Configuration**: Change default passwords and configure projects
4. **Analysis**: Use appropriate scanner for your project type
5. **Monitoring**: Use `docker-compose logs -f` for real-time monitoring

## Access Information

- **SonarQube Web UI**: http://localhost:9000
- **Default Login**: admin/admin
- **Database**: PostgreSQL on internal network (not exposed)
- **Volumes**: All data persisted in Docker volumes with `sonarqube-local` prefix

## Memory Bank Integration

This project includes a structured memory bank at `memory-bank/` containing:
- Architectural decisions and patterns
- Progress tracking and decision logs
- Project context and system documentation

The memory bank follows a schema-based approach for knowledge management and should be updated when making significant architectural changes.