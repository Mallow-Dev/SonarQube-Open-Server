# Product Context

## Overview

This project provides a local development environment for SonarQube, an open-source platform for continuous inspection of code quality. The project is a development log and project space for creating, configuring, and deploying the SonarQube server. It uses Docker Compose to orchestrate the SonarQube server, a PostgreSQL database, and the experimental SonarQube MCP server.

## Core Features

-   **SonarQube Server:** The core SonarQube server for code analysis.
-   **PostgreSQL Database:** A production-ready database for storing SonarQube data.
-   **SonarQube MCP Server:** An experimental server for analyzing code snippets.
-   **Docker Compose Setup:** A single command to start and stop the entire environment.
-   **Memory Bank:** A knowledge base with documentation about the project.

## Technical Stack

-   **SonarQube:** Community Edition
-   **PostgreSQL:** 15-alpine
-   **Docker Compose:** For container orchestration
-   **Gradle:** For building the `sonarqube-mcp-server` from source
-   **cspell:** For spell checking the documentation
