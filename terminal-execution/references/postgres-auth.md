# Containerized PostgreSQL credential diagnosis

Use this procedure when pgAdmin or another libpq client cannot authenticate to a Docker-hosted PostgreSQL instance.

1. Discover service names, mounts, and environment variable names without emitting values:

   docker ps --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}'

   Inspect the target container and print only mount paths and the left side of each environment assignment.

2. Prove the database's configured credential works over TCP from its container. Keep the password expansion inside the container and return only the connected identity:

   docker exec <postgres-container> sh -c 'PGPASSWORD="$POSTGRES_PASSWORD" psql -h 127.0.0.1 -U "$POSTGRES_USER" -d "$POSTGRES_DB" -Atc "select current_user || chr(58) || current_database()"'

3. If pgAdmin uses a mounted `PassFile`, compare its entry to the container environment in a non-printing script. Do not use `cat` or include the value in output.

4. Enforce libpq permissions on the host-side file, then validate it from pgAdmin's Docker network:

   chmod 600 <host-path-to-pgpass>

   docker run --rm --network container:<pgadmin-container> -v <host-path-to-pgpass>:/pgpass:ro -e PGPASSFILE=/pgpass postgres:16-alpine psql -h <postgres-service-name> -U <db-user> -d <db-name> -Atc 'select current_user'

The final command must return only the database role. This confirms the exact passfile is accepted on the same service DNS and network route pgAdmin uses.

Do not place a plaintext password in shell history, terminal output, source control, or an agent reply.