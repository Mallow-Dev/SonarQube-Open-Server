# Troubleshooting

This document provides detailed troubleshooting information for the SonarQube Open Server setup.

## Common Issues

### SonarQube not starting

If the `sonarqube` container is not starting, here are a few things to check:

1.  **Check the logs:**

    ```bash
    docker-compose logs sonarqube
    ```

    Look for any error messages, such as port conflicts, memory issues, or database connection problems.

2.  **Check for port conflicts:**

    Make sure that port 9000 (or 9001 if you are using the override file) is not already in use by another application.

    ```bash
    netstat -tulpn | grep :9000
    ```

3.  **Restart the services:**

    Sometimes, a simple restart can fix the problem.

    ```bash
    docker-compose down && docker-compose up -d
    ```

### Database connection issues

If SonarQube is having trouble connecting to the database, here are a few things to check:

1.  **Verify that the database is running:**

    ```bash
    docker-compose logs db
    ```

    Look for any error messages.

2.  **Check the database connection from the SonarQube container:**

    ```bash
    docker-compose exec sonarqube curl -f http://db:5432
    ```

    If this command fails, there is a network connectivity issue between the two containers.

### Out of memory errors

If you are seeing out of memory errors in the SonarQube logs, you may need to increase the memory allocation for the SonarQube container. You can do this by editing the `.env` file:

```env
SONAR_WEB_JAVA_OPTS=-Xmx2g -Xms1g
```

Then, restart the services:

```bash
docker-compose restart
```

### Docker authentication errors

If you are encountering Docker Hub authentication or rate limiting errors, you can try the following:

1.  **Login to Docker Hub:**

    ```bash
    docker login
    ```

2.  **Use a mirror registry:**

    You can edit the `docker-compose.yml` file to use a mirror registry:

    ```yaml
    image: mirror.gcr.io/library/sonarqube:10.7-community
    image: mirror.gcr.io/library/postgres:15-alpine
    ```

### ElasticSearch errors

If you are seeing ElasticSearch bootstrap check errors, you can try the following:

1.  **Ensure that `SONAR_ES_BOOTSTRAP_CHECKS_DISABLE=true` is set in the environment.**
2.  **Check the available memory on your system.** ElasticSearch requires a significant amount of memory.

## Advanced Troubleshooting

### Analyzing SonarQube logs

You can view the logs for all services using the following command:

```bash
docker-compose logs
```

To follow the logs in real-time, use the `-f` flag:

```bash
docker-compose logs -f
```

To view the logs for a specific service, specify the service name:

```bash
docker-compose logs sonarqube
docker-compose logs db
```

### Connecting to the PostgreSQL database

You can connect to the PostgreSQL database using the following command:

```bash
docker-compose exec db psql -U sonar -d sonar
```

This will give you a psql prompt, from which you can run SQL queries against the database.

### Inspecting Docker volumes

You can inspect the Docker volumes to see where the data is being stored. To get a list of volumes, run the following command:

```bash
docker volume ls
```

To inspect a specific volume, run the following command:

```bash
docker volume inspect <volume_name>
```
