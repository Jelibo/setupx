# DevOps Scripts

Bash scripts for day-to-day full-stack development with Kubernetes, Java, Angular, Nginx, and AWS.
All scripts are tested on **macOS** and **Ubuntu**.

## Prerequisites

Install the tools required by the scripts you intend to use:

| Tool | Install |
|---|---|
| `kubectl` | [kubernetes.io/docs/tasks/tools](https://kubernetes.io/docs/tasks/tools/) |
| `aws` CLI v2 | [docs.aws.amazon.com/cli](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) |
| `docker` | [docs.docker.com/get-docker](https://docs.docker.com/get-docker/) |
| `node` / `npm` | [nodejs.org](https://nodejs.org/) |
| `java` / `jps` | JDK 11+ |
| `nginx` | `apt install nginx` / `brew install nginx` |
| `certbot` | `apt install certbot` / `brew install certbot` |
| `flyway` or `liquibase` | [flywaydb.org](https://flywaydb.org/) / [liquibase.org](https://www.liquibase.org/) |
| `python3` | Pre-installed on both platforms |
| `curl` | Pre-installed on both platforms |
| `git` | Pre-installed / `apt install git` |

Make all scripts executable after cloning:

```bash
chmod +x scripts/*.sh
```

---

## Kubernetes

### `k8s-pod-restart.sh` — Rolling restart a deployment

Triggers a zero-downtime rolling restart and waits for completion.

```bash
./k8s-pod-restart.sh <namespace> <deployment>
```

**Examples:**
```bash
./k8s-pod-restart.sh default my-api
./k8s-pod-restart.sh production frontend
```

---

### `k8s-logs-follow.sh` — Tail logs from all matching pods

Streams logs from every pod that matches a label selector, across all containers.

```bash
./k8s-logs-follow.sh <namespace> <label-selector>
```

**Examples:**
```bash
./k8s-logs-follow.sh default app=my-api
./k8s-logs-follow.sh production app=worker,tier=backend
```

---

### `k8s-port-forward.sh` — Port-forward to a pod

Finds the first running pod matching a label and opens a local port forward to it.

```bash
./k8s-port-forward.sh <namespace> <label-selector> <local-port> <remote-port>
```

**Examples:**
```bash
# Forward local 8080 to port 8080 in the pod
./k8s-port-forward.sh default app=my-api 8080 8080

# Forward local 5432 to a sidecar Postgres port
./k8s-port-forward.sh staging app=my-service 5432 5432
```

---

### `k8s-image-update.sh` — Update a container image tag

Sets a new image on a specific container in a deployment and waits for rollout.

```bash
./k8s-image-update.sh <namespace> <deployment> <container> <new-image>
```

**Examples:**
```bash
./k8s-image-update.sh default my-api api 123456789.dkr.ecr.eu-west-1.amazonaws.com/my-api:1.2.3
./k8s-image-update.sh production frontend app myrepo/frontend:abc1234
```

---

### `k8s-scale.sh` — Scale a deployment

Scales replica count up or down. Waits for rollout when scaling up; immediate when scaling to 0.

```bash
./k8s-scale.sh <namespace> <deployment> <replicas>
```

**Examples:**
```bash
./k8s-scale.sh default my-worker 0        # scale down
./k8s-scale.sh default my-worker 3        # scale up
./k8s-scale.sh production my-api 5
```

---

### `k8s-exec-shell.sh` — Open a shell in a pod

Drops into a shell (`/bin/sh` by default) in the first running pod matching a label.

```bash
./k8s-exec-shell.sh <namespace> <label-selector> [shell]
```

**Examples:**
```bash
./k8s-exec-shell.sh default app=my-api
./k8s-exec-shell.sh production app=my-api /bin/bash
```

---

### `k8s-namespace-resources.sh` — Resource summary for a namespace

Prints resource counts (pods, deployments, services, etc.) and a pod status breakdown.

```bash
./k8s-namespace-resources.sh <namespace>
```

**Examples:**
```bash
./k8s-namespace-resources.sh default
./k8s-namespace-resources.sh production
```

**Sample output:**
```
=== Resource summary for namespace: production ===
  pods                 8
  deployments          3
  services             4
  ...

=== Pod status breakdown ===
      8 Running
      1 Pending
```

---

## Java

### `java-build-push.sh` — Build and push a Docker image to ECR

Runs `./mvnw clean package`, builds a Docker image, and pushes it to AWS ECR. The image tag defaults to the current short git commit SHA.

```bash
./java-build-push.sh <image-name> [tag]
```

**Required env vars:**

| Variable | Description |
|---|---|
| `AWS_REGION` | e.g. `eu-west-1` |
| `AWS_ACCOUNT_ID` | 12-digit AWS account ID |

**Examples:**
```bash
AWS_REGION=eu-west-1 AWS_ACCOUNT_ID=123456789012 ./java-build-push.sh my-api
AWS_REGION=eu-west-1 AWS_ACCOUNT_ID=123456789012 ./java-build-push.sh my-api 1.4.2
```

---

### `java-thread-dump.sh` — JVM thread dump from a pod

Sends `SIGQUIT` (`kill -3`) to the JVM process inside a pod, printing a full thread dump to the pod's stdout (visible in `kubectl logs`).

```bash
./java-thread-dump.sh <namespace> <pod-name> [container]
```

**Examples:**
```bash
./java-thread-dump.sh default my-api-7d9f8b6c4-xkpqr
./java-thread-dump.sh production my-api-7d9f8b6c4-xkpqr app

# Then check logs:
kubectl logs -n production my-api-7d9f8b6c4-xkpqr | grep -A 200 "Full thread dump"
```

---

## Angular

### `angular-deploy-s3.sh` — Build and deploy to S3 + CloudFront

Builds the Angular app, syncs the `dist/` output to an S3 bucket with correct cache headers, and optionally invalidates a CloudFront distribution. Reads the output path from `angular.json` automatically.

- Hashed assets (`main.abc123.js`) → `max-age=1year, immutable`
- `index.html` and `.json` files → `no-cache`

```bash
./angular-deploy-s3.sh [build-configuration]
```

Default build configuration is `production`.

**Required env var:**

| Variable | Description |
|---|---|
| `S3_BUCKET` | Target S3 bucket name |

**Optional env var:**

| Variable | Description |
|---|---|
| `CF_DISTRIBUTION_ID` | CloudFront distribution ID to invalidate after deploy |

**Examples:**
```bash
S3_BUCKET=my-app-bucket ./angular-deploy-s3.sh
S3_BUCKET=my-app-staging CF_DISTRIBUTION_ID=E1234ABCDEFG ./angular-deploy-s3.sh staging
```

---

## Nginx

### `nginx-reload.sh` — Test config and gracefully reload

Validates `nginx.conf` syntax then sends a graceful reload signal. Zero downtime — existing connections finish before workers are replaced.

```bash
sudo ./nginx-reload.sh
```

---

### `nginx-cert-renew.sh` — Renew a Let's Encrypt certificate

Runs `certbot renew` for a specific domain and reloads nginx to pick up the new certificate.

```bash
sudo ./nginx-cert-renew.sh <domain>
```

**Examples:**
```bash
sudo ./nginx-cert-renew.sh api.example.com
```

> Tip: add this to a daily cron: `0 3 * * * /path/to/nginx-cert-renew.sh api.example.com`

---

### `nginx-access-stats.sh` — Access log analysis

Parses a nginx access log (combined log format) and prints top IPs, top URIs, status code distribution, and top user agents.

```bash
./nginx-access-stats.sh [log-file] [top-n]
```

Defaults: log file `/var/log/nginx/access.log`, top N = `10`.

**Examples:**
```bash
./nginx-access-stats.sh
./nginx-access-stats.sh /var/log/nginx/mysite.access.log 20
```

---

## AWS

### `aws-ecr-cleanup.sh` — Delete untagged ECR images

Removes all untagged (dangling) images from an ECR repository to reduce storage costs.

```bash
./aws-ecr-cleanup.sh <ecr-repo-name>
```

**Required env var:** `AWS_REGION`

**Examples:**
```bash
AWS_REGION=eu-west-1 ./aws-ecr-cleanup.sh my-api
```

---

### `aws-ssm-env.sh` — Export SSM parameters as env vars

Fetches all parameters under an SSM path prefix and exports them as environment variables in the current shell. The parameter name suffix is uppercased and `/` is replaced with `_`.

```bash
source ./aws-ssm-env.sh <ssm-prefix>
```

**Optional env var:** `AWS_REGION` (default: `us-east-1`)

**Examples:**
```bash
source ./aws-ssm-env.sh /my-app/prod
# /my-app/prod/db-password  →  exports DB_PASSWORD=...
# /my-app/prod/api/key      →  exports API_KEY=...
```

> Must be `source`d (not executed) so exports reach the calling shell.

---

### `aws-rds-tunnel.sh` — SSH tunnel to RDS through a bastion

Opens an SSH port-forward so you can connect to an RDS instance on `localhost` using any database client.

```bash
./aws-rds-tunnel.sh <bastion-host> <rds-endpoint> [local-port] [remote-port]
```

Defaults: local port `5432`, remote port `5432`.

**Optional env vars:**

| Variable | Default | Description |
|---|---|---|
| `SSH_KEY` | `~/.ssh/id_rsa` | Path to SSH private key |
| `SSH_USER` | `ec2-user` | SSH username on the bastion |

**Examples:**
```bash
# PostgreSQL tunnel
./aws-rds-tunnel.sh bastion.example.com mydb.cluster-xyz.eu-west-1.rds.amazonaws.com

# MySQL tunnel on non-default ports
SSH_USER=ubuntu ./aws-rds-tunnel.sh bastion.example.com mydb.rds.amazonaws.com 3307 3306

# Then connect with psql:
psql -h localhost -p 5432 -U myuser mydb
```

---

### `aws-cost-report.sh` — Monthly cost breakdown by service

Prints AWS spend grouped by service for the current and previous month using the Cost Explorer API.

```bash
./aws-cost-report.sh
```

**Optional env var:** `AWS_REGION` (default: `us-east-1`)

> Requires the `ce:GetCostAndUsage` IAM permission.

**Sample output:**
```
=== Last Month (2026-02-01 to 2026-02-28) ===
  Amazon EC2                                         $  1234.56
  Amazon RDS                                         $   456.78
  ...

=== This Month (2026-03-01 to 2026-03-26) ===
  Amazon EC2                                         $   890.12
  ...
```

---

## Database

### `db-migration-run.sh` — Run Flyway or Liquibase migrations

Applies pending database migrations. Supports both Flyway and Liquibase. Pairs well with `aws-ssm-env.sh` to pull credentials from SSM before running.

```bash
./db-migration-run.sh [flyway|liquibase]
```

Default tool is `flyway`.

**Required env vars:**

| Variable | Description |
|---|---|
| `DB_URL` | JDBC URL, e.g. `jdbc:postgresql://localhost:5432/mydb` |
| `DB_USER` | Database username |
| `DB_PASSWORD` | Database password |

**Optional env var:**

| Variable | Default | Description |
|---|---|---|
| `MIGRATIONS_DIR` | `./src/main/resources/db/migration` | Path to migration scripts |

**Examples:**
```bash
DB_URL=jdbc:postgresql://localhost:5432/mydb DB_USER=app DB_PASSWORD=secret ./db-migration-run.sh

# With Liquibase
DB_URL=... DB_USER=... DB_PASSWORD=... ./db-migration-run.sh liquibase

# Pull creds from SSM first
source ./aws-ssm-env.sh /my-app/prod
./db-migration-run.sh
```

---

## Git / CI

### `git-tag-release.sh` — Create and push a semver release tag

Validates the version string against semver, creates an annotated git tag, and pushes it to the remote (triggering CI release pipelines that watch for tags).

```bash
./git-tag-release.sh <version> [remote]
```

Default remote is `origin`.

**Examples:**
```bash
./git-tag-release.sh 1.4.2
./git-tag-release.sh 2.0.0-rc.1
./git-tag-release.sh 1.4.2 upstream
```

---

## General

### `healthcheck-endpoints.sh` — Smoke-test HTTP endpoints

Checks a list of URLs and reports pass/fail per endpoint. Exits with status `1` if any check fails — useful in CI pipelines after deploy.

```bash
./healthcheck-endpoints.sh [endpoints-file]
```

Default file: `endpoints.txt`

**Endpoints file format:**
```
# comments are ignored
https://api.example.com/health
https://app.example.com/
201 https://api.example.com/users   # optional: expected status code prefix
```

**Optional env var:** `TIMEOUT` — per-request timeout in seconds (default: `10`)

**Examples:**
```bash
./healthcheck-endpoints.sh
./healthcheck-endpoints.sh prod-endpoints.txt
TIMEOUT=5 ./healthcheck-endpoints.sh prod-endpoints.txt
```

**Sample output:**
```
  [PASS] https://api.example.com/health  (200)
  [FAIL] https://api.example.com/broken  (expected 200, got 503)

Results: 1 passed, 1 failed.
```

---

## Common Patterns

**Combine scripts for a full deploy flow:**
```bash
# 1. Build and push new image
AWS_REGION=eu-west-1 AWS_ACCOUNT_ID=123456789012 ./java-build-push.sh my-api

# 2. Update k8s deployment to new image
./k8s-image-update.sh production my-api app 123456789012.dkr.ecr.eu-west-1.amazonaws.com/my-api:$(git rev-parse --short HEAD)

# 3. Smoke-test after deploy
./healthcheck-endpoints.sh prod-endpoints.txt
```

**Tunnel into RDS and run migrations:**
```bash
# In one terminal — keep tunnel open
./aws-rds-tunnel.sh bastion.example.com mydb.rds.amazonaws.com

# In another terminal
source ./aws-ssm-env.sh /my-app/prod
DB_URL=jdbc:postgresql://localhost:5432/mydb ./db-migration-run.sh
```
