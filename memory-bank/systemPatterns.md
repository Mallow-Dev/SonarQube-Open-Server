# System Patterns

## Architectural Patterns

-   **Microservices:** The project is composed of multiple services that work together, including the SonarQube server, the PostgreSQL database, and the MCP server. This allows for independent development and deployment of each service.
-   **Containerization:** The project uses Docker to containerize the services. This makes them portable and easy to deploy across different environments.

## Design Patterns

-   **Configuration as Code:** The configuration for the project is stored in files (`docker-compose.yml`, `.env`, `sonar.properties`). This makes it easy to version and manage the configuration, and it allows for easy replication of the environment.
-   **Infrastructure as Code:** The entire infrastructure for the project is defined in the `docker-compose.yml` file. This makes it easy to create and destroy the environment, and it ensures that the environment is consistent across all deployments.

## Common Idioms

-   **Conventional Commits:** The project uses conventional commits for version control. This provides a standardized format for commit messages, which makes it easier to understand the history of the project and to generate release notes.
-   **Memory Bank:** The project uses a `memory-bank` to store documentation and knowledge about the project. This helps to ensure that the project is well-documented and that knowledge is not lost over time.
