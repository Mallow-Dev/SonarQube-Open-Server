# SonarQube Open Server

A Docker Compose setup for running SonarQube locally with PostgreSQL database.

## Prerequisites

- Docker Engine 20.10+
- Docker Compose 2.0+
- At least 4GB of available RAM
- At least 2GB of available disk space

## Quick Start

1. **Clone or navigate to this directory**

   ```bash
   cd /path/to/this/directory
   ```

2. **Start the services**

   ```bash
   docker-compose up -d
   ```

3. **Wait for initialization**

   - SonarQube may take 2-5 minutes to fully start up
   - Check logs: `docker-compose logs -f sonarqube`

4. **Access SonarQube**

   - URL: http://localhost:9000
   - Default credentials:
     - Username: `admin`
     - Password: `admin`

5. **Change default password** after first login for security

## Configuration

### Environment Variables

The setup uses the following environment variables defined in `.env`:

- Database credentials
- JVM memory settings
- Timezone configuration
- Logging levels

### Volumes

Persistent data is stored in Docker volumes:

- `sonarqube_data`: SonarQube configuration and data
- `sonarqube_extensions`: Custom extensions and plugins
- `sonarqube_plugins`: SonarQube plugins
- `postgresql_data`: PostgreSQL database data

### Customization

#### Changing Database Passwords

1. Update passwords in `.env`
2. Update corresponding values in `sonar.properties`
3. Restart services: `docker-compose down && docker-compose up -d`

#### JVM Memory Tuning

Adjust memory settings in `.env` based on your system's resources:

```env
SONAR_WEB_JAVA_OPTS=-Xmx2g -Xms512m
SONAR_CE_JAVA_OPTS=-Xmx4g -Xms2g
SONAR_SEARCH_JAVA_OPTS=-Xms1g -Xmx1g
```

## Usage

### Basic Commands

```bash
# Start services
docker-compose up -d

# View logs
docker-compose logs -f

# Stop services
docker-compose down

# View service status
docker-compose ps

# Restart services
docker-compose restart
```

### Development Overrides

Use `docker-compose.override.yml` for development-specific configurations:

```yaml
version: "3.8"
services:
  sonarqube:
    ports:
      - "9001:9000" # Different port for dev
    environment:
      - SONAR_LOG_LEVEL=DEBUG
```

### Installing Plugins

1. Download plugin JAR files
2. Place them in `./plugins/` directory
3. Restart SonarQube: `docker-compose restart sonarqube`

### Analyzing Code

#### Using SonarScanner CLI

```bash
# Install SonarScanner
npm install -g sonarsource/sonar-scanner-cli

# Run analysis
sonar-scanner \
  -Dsonar.projectKey=myproject \
  -Dsonar.sources=. \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=your-token
```

#### Using Maven

```xml
<plugin>
  <groupId>org.sonarsource.scanner.maven</groupId>
  <artifactId>sonar-maven-plugin</artifactId>
  <version>3.9.1.2184</version>
</plugin>
```

```bash
mvn sonar:sonar \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=your-token
```

#### Using Gradle

```groovy
plugins {
  id "org.sonarqube" version "4.0.0.2929"
}
```

```bash
./gradlew sonarqube \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.login=your-token
```

#### Analyzing a Python Project

To analyze a Python project, you can use the SonarScanner CLI. Here's an example configuration in a file named `sonar-project.properties` at the root of your Python project:

```properties
# must be unique in a given SonarQube instance
sonar.projectKey=my-python-project
sonar.projectName=My Python Project

# --- optional properties ---
# defaults to project key
#sonar.projectVersion=1.0

# Path is relative to the sonar-project.properties file. Defaults to .
sonar.sources=.

# Encoding of the source code. Default is default system encoding
#sonar.sourceEncoding=UTF-8
```

Then, from the root of your project, run the SonarScanner CLI:

```bash
sonar-scanner
```

This will send the analysis report to your SonarQube server.

## SonarQube MCP Server

The SonarQube MCP (Micro-Component-based Platform) Server is a new, experimental way of running SonarQube that is designed for analyzing code snippets and integrating with SonarQube Server or Cloud.

### Working with the MCP Server Submodule

The `sonarqube-mcp-server` is included as a submodule in this repository. To initialize the submodule, run the following command:

```bash
git submodule update --init --recursive
```

To update the submodule to the latest version, run the following command:

```bash
git submodule update --remote
```

### Enabling the MCP Server

To enable the MCP server, you need to generate a SonarQube token and add it to the `.env` file. You can generate a token in SonarQube by going to **My Account > Security**.

Once you have added the token to the `.env` file, you can start the MCP server along with the other services:

```bash
docker-compose up -d --build
```

The MCP server will be available on port 8080.

Here is an example of how to use the MCP server to analyze a code snippet:

```bash
curl -X POST http://localhost:8080/api/code_snippets/analyze \
-H "Content-Type: application/json" \
-d '{
  "code": "public class MyClass { public void myMethod() { } }",
  "language": "java"
}'
```

## Troubleshooting

For more detailed troubleshooting information, please see the [troubleshooting.md](./memory-bank/troubleshooting.md) file in the memory-bank.

### Common Issues

#### SonarQube not starting

```bash
# Check logs
docker-compose logs sonarqube

# Check if port 9000 is available
netstat -tulpn | grep :9000

# Restart services
docker-compose down && docker-compose up -d
```

#### Database connection issues

```bash
# Verify database is running
docker-compose logs db

# Check database connectivity
docker-compose exec sonarqube curl -f http://db:5432
```

#### Out of memory errors

```bash
# Increase memory allocation in .env
SONAR_WEB_JAVA_OPTS=-Xmx2g -Xms1g

# Restart services
docker-compose restart
```

#### Docker authentication errors

If you encounter Docker Hub authentication or rate limiting errors:

```bash
# Login to Docker Hub (create account at hub.docker.com if needed)
docker login

# Or use a mirror registry
# Edit docker-compose.yml to use a mirror:
# image: mirror.gcr.io/library/sonarqube:10.7-community
# image: mirror.gcr.io/library/postgres:15-alpine
```

#### ElasticSearch errors

If you see ElasticSearch bootstrap check errors:

1. Ensure `SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true` in environment
2. Check available memory (ES requires significant resources)

### Logs and Debugging

```bash
# View all logs
docker-compose logs

# Follow logs in real-time
docker-compose logs -f

# View specific service logs
docker-compose logs sonarqube
docker-compose logs db
```

## Production Considerations

### Security

- Change default passwords
- Use strong passwords for database and SonarQube admin
- Consider using Docker secrets for sensitive data
- Configure SSL/TLS termination (nginx reverse proxy recommended)

### Backup Strategy

```bash
# Backup volumes
docker run --rm -v sonarqube-local_postgresql_data:/data -v $(pwd):/backup alpine tar czf /backup/postgresql_backup.tar.gz -C /data .
docker run --rm -v sonarqube-local_sonarqube_data:/data -v $(pwd):/backup alpine tar czf /backup/sonarqube_backup.tar.gz -C /data .
```

### Monitoring

Consider installing monitoring solutions like:

- Prometheus for metrics collection
- Grafana for visualization
- ELK stack for log aggregation

### Scaling

For higher load environments:

- Increase JVM heap sizes
- Use dedicated database server
- Configure load balancer
- Consider SonarQube Data Center Edition

## Support

For more information:

- [SonarQube Documentation](https://docs.sonarsource.com/sonarqube/)
- [SonarQube Docker Image](https://hub.docker.com/_/sonarqube)
- [PostgreSQL Docker Image](https://hub.docker.com/_/postgres)

## License

This setup uses SonarQube Community Edition, which is free and open-source.
