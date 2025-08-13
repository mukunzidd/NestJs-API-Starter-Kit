# Deployment Guide

This comprehensive guide covers deploying the NestJS API Starter Kit to
production environments, including cloud platforms, containerized deployments,
and best practices for security, scalability, and monitoring.

## Table of Contents

- [Deployment Overview](#deployment-overview)
- [Pre-deployment Checklist](#pre-deployment-checklist)
- [Environment Configuration](#environment-configuration)
- [Build Process](#build-process)
- [Docker Deployment](#docker-deployment)
- [Cloud Platforms](#cloud-platforms)
- [Database Deployment](#database-deployment)
- [Load Balancing](#load-balancing)
- [SSL/TLS Configuration](#ssltls-configuration)
- [Monitoring & Logging](#monitoring--logging)
- [CI/CD Pipelines](#cicd-pipelines)
- [Security Considerations](#security-considerations)
- [Performance Optimization](#performance-optimization)
- [Scaling Strategies](#scaling-strategies)
- [Backup & Recovery](#backup--recovery)
- [Troubleshooting](#troubleshooting)

## Deployment Overview

### Deployment Architecture

```
Internet
    ↓
Load Balancer (SSL Termination)
    ↓
Reverse Proxy (Nginx)
    ↓
NestJS Application Instances (Multiple)
    ↓
Database Cluster (PostgreSQL)
    ↓
Redis Cache
    ↓
Monitoring & Logging Services
```

### Deployment Options

| Option              | Use Case                           | Complexity | Cost        |
| ------------------- | ---------------------------------- | ---------- | ----------- |
| **Docker Compose**  | Small deployments, single server   | Low        | Low         |
| **Kubernetes**      | Enterprise, auto-scaling           | High       | Medium-High |
| **Cloud PaaS**      | Rapid deployment, managed services | Low        | Medium      |
| **Serverless**      | Event-driven, variable load        | Medium     | Variable    |
| **Traditional VPS** | Simple deployments, full control   | Medium     | Low         |

## Pre-deployment Checklist

### Code Quality Assurance

- [ ] **All tests passing**: `npm run test:all`
- [ ] **Code linting**: `npm run lint:check`
- [ ] **Code formatting**: `npm run format:check`
- [ ] **TypeScript compilation**: `npm run build`
- [ ] **Security audit**: `npm audit --audit-level moderate`
- [ ] **Dependency updates**: Recent updates applied and tested

### Security Checklist

- [ ] **Environment variables**: No secrets in code
- [ ] **JWT secrets**: Strong, unique secrets for production
- [ ] **Database credentials**: Secure credentials configured
- [ ] **CORS origins**: Properly configured for production domains
- [ ] **Rate limiting**: Configured for production load
- [ ] **Input validation**: All endpoints validated
- [ ] **Error handling**: No sensitive information in error responses

### Infrastructure Checklist

- [ ] **Database**: Production database configured
- [ ] **SSL certificates**: Valid SSL/TLS certificates
- [ ] **Domain configuration**: DNS records configured
- [ ] **Backup strategy**: Database and application backups
- [ ] **Monitoring**: Application and infrastructure monitoring
- [ ] **Logging**: Centralized logging configured

## Environment Configuration

### Production Environment Variables

Create a production-specific environment configuration:

```bash
# Production Environment (.env.production)

# ======================
# APPLICATION SETTINGS
# ======================
NODE_ENV=production
PORT=3000
HOST=0.0.0.0
API_PREFIX=api

# ======================
# DATABASE CONFIGURATION
# ======================
DB_HOST=production-db-cluster.example.com
DB_PORT=5432
DB_USERNAME=app_user
DB_PASSWORD=super_secure_production_password_2024
DB_NAME=nestjs_production
DB_SSL=true

# ======================
# SECURITY CONFIGURATION
# ======================
JWT_SECRET=A7x9K2m5P8q3W6e1R4t7Y0u2I5o8P1a3S6d9F2g5H8j1K4m7N0q3T6w9E2r5T8y1
JWT_EXPIRES_IN=1h
CORS_ORIGINS=https://app.example.com,https://admin.example.com

# ======================
# RATE LIMITING
# ======================
THROTTLE_TTL=60000
THROTTLE_LIMIT=1000

# ======================
# LOGGING
# ======================
LOG_LEVEL=info
LOG_FORMAT=json

# ======================
# EXTERNAL SERVICES
# ======================
REDIS_HOST=redis-cluster.example.com
REDIS_PORT=6379
REDIS_PASSWORD=redis_production_password

# ======================
# MONITORING
# ======================
SENTRY_DSN=https://your-sentry-dsn@sentry.io/project-id
DATADOG_API_KEY=your_datadog_api_key
```

### Secret Management

**AWS Secrets Manager:**

```bash
#!/bin/bash
# deploy/get-secrets.sh

export JWT_SECRET=$(aws secretsmanager get-secret-value \
  --secret-id prod/nestjs/jwt-secret \
  --query SecretString --output text)

export DB_PASSWORD=$(aws secretsmanager get-secret-value \
  --secret-id prod/nestjs/db-password \
  --query SecretString --output text)
```

**HashiCorp Vault:**

```bash
#!/bin/bash
# deploy/vault-secrets.sh

vault auth -method=aws
export JWT_SECRET=$(vault kv get -field=secret auth/jwt)
export DB_PASSWORD=$(vault kv get -field=password database/credentials)
```

**Kubernetes Secrets:**

```yaml
# k8s/secrets.yaml
apiVersion: v1
kind: Secret
metadata:
  name: nestjs-secrets
type: Opaque
data:
  jwt-secret: <base64-encoded-secret>
  db-password: <base64-encoded-password>
```

## Build Process

### Production Build

```bash
#!/bin/bash
# deploy/build.sh

set -e

echo "🔧 Installing production dependencies..."
npm ci --only=production

echo "📦 Building application..."
npm run build

echo "🧹 Cleaning development files..."
rm -rf src/
rm -rf test/
rm -rf coverage/
rm -rf .git/

echo "✅ Build completed successfully"
```

### Multi-stage Docker Build

```dockerfile
# Production-optimized Dockerfile
FROM node:20-alpine AS base
WORKDIR /usr/src/app
RUN apk add --no-cache dumb-init

# Dependencies stage
FROM base AS dependencies
COPY package*.json ./
RUN npm ci --only=production && npm cache clean --force

# Build stage
FROM base AS build
COPY package*.json ./
RUN npm ci
COPY . .
RUN npm run build

# Production stage
FROM base AS production
RUN addgroup -g 1001 -S nodejs && adduser -S nestjs -u 1001

COPY --from=dependencies --chown=nestjs:nodejs /usr/src/app/node_modules ./node_modules
COPY --from=build --chown=nestjs:nodejs /usr/src/app/dist ./dist
COPY --chown=nestjs:nodejs package*.json ./

USER nestjs
EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost:3000/health/live || exit 1

ENTRYPOINT ["dumb-init", "--"]
CMD ["node", "dist/main.js"]
```

### Build Optimization

```bash
# .dockerignore
node_modules
npm-debug.log
coverage
.git
.gitignore
README.md
.env*
.nyc_output
.vscode
.idea
test
coverage
docs
scripts
*.md
Dockerfile*
docker-compose*
```

## Docker Deployment

### Docker Compose Production

```yaml
# docker-compose.production.yml
version: '3.8'

services:
  app:
    image: nestjs-api:latest
    restart: unless-stopped
    ports:
      - '3000:3000'
    environment:
      NODE_ENV: production
      DB_HOST: postgres
      REDIS_HOST: redis
    env_file:
      - .env.production
    depends_on:
      postgres:
        condition: service_healthy
      redis:
        condition: service_healthy
    healthcheck:
      test: ['CMD', 'curl', '-f', 'http://localhost:3000/health/live']
      interval: 30s
      timeout: 10s
      retries: 5
      start_period: 40s
    deploy:
      resources:
        limits:
          memory: 512M
          cpus: '1.0'
        reservations:
          memory: 256M
          cpus: '0.5'
    logging:
      driver: 'json-file'
      options:
        max-size: '10m'
        max-file: '3'

  postgres:
    image: postgres:16-alpine
    restart: unless-stopped
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USERNAME}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    ports:
      - '5432:5432'
    healthcheck:
      test: ['CMD-SHELL', 'pg_isready -U ${DB_USERNAME} -d ${DB_NAME}']
      interval: 10s
      timeout: 5s
      retries: 5

  redis:
    image: redis:7-alpine
    restart: unless-stopped
    command: redis-server --appendonly yes --requirepass ${REDIS_PASSWORD}
    volumes:
      - redis_data:/data
    ports:
      - '6379:6379'
    healthcheck:
      test: ['CMD', 'redis-cli', 'ping']
      interval: 10s
      timeout: 5s
      retries: 5

  nginx:
    image: nginx:alpine
    restart: unless-stopped
    ports:
      - '80:80'
      - '443:443'
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf:ro
      - ./ssl:/etc/nginx/ssl:ro
    depends_on:
      - app

volumes:
  postgres_data:
  redis_data:
```

### Nginx Configuration

```nginx
# nginx.conf
events {
    worker_connections 1024;
}

http {
    upstream api {
        server app:3000;
        keepalive 32;
    }

    server {
        listen 80;
        server_name api.example.com;
        return 301 https://$server_name$request_uri;
    }

    server {
        listen 443 ssl http2;
        server_name api.example.com;

        ssl_certificate /etc/nginx/ssl/certificate.crt;
        ssl_certificate_key /etc/nginx/ssl/private.key;
        ssl_protocols TLSv1.2 TLSv1.3;

        # Security headers
        add_header X-Frame-Options DENY;
        add_header X-Content-Type-Options nosniff;
        add_header X-XSS-Protection "1; mode=block";
        add_header Strict-Transport-Security "max-age=31536000; includeSubDomains";

        # Rate limiting
        limit_req_zone $binary_remote_addr zone=api:10m rate=10r/s;
        limit_req zone=api burst=20 nodelay;

        location / {
            proxy_pass http://api;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection 'upgrade';
            proxy_set_header Host $host;
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_cache_bypass $http_upgrade;
            proxy_read_timeout 86400;
        }

        location /health {
            proxy_pass http://api;
            access_log off;
        }
    }
}
```

### Docker Swarm Deployment

```bash
# Initialize Docker Swarm
docker swarm init

# Deploy stack
docker stack deploy -c docker-compose.production.yml nestjs-app

# Scale services
docker service scale nestjs-app_app=3

# Update services
docker service update --image nestjs-api:v1.2.0 nestjs-app_app

# Monitor services
docker service ls
docker service logs -f nestjs-app_app
```

## Cloud Platforms

### AWS ECS Deployment

**Task Definition:**

```json
{
  "family": "nestjs-api",
  "networkMode": "awsvpc",
  "requiresCompatibilities": ["FARGATE"],
  "cpu": "512",
  "memory": "1024",
  "executionRoleArn": "arn:aws:iam::account:role/ecsTaskExecutionRole",
  "containerDefinitions": [
    {
      "name": "nestjs-api",
      "image": "your-account.dkr.ecr.region.amazonaws.com/nestjs-api:latest",
      "portMappings": [
        {
          "containerPort": 3000,
          "protocol": "tcp"
        }
      ],
      "environment": [
        {
          "name": "NODE_ENV",
          "value": "production"
        }
      ],
      "secrets": [
        {
          "name": "JWT_SECRET",
          "valueFrom": "arn:aws:secretsmanager:region:account:secret:jwt-secret"
        }
      ],
      "healthCheck": {
        "command": [
          "CMD-SHELL",
          "curl -f http://localhost:3000/health/live || exit 1"
        ],
        "interval": 30,
        "timeout": 5,
        "retries": 3
      },
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": {
          "awslogs-group": "/ecs/nestjs-api",
          "awslogs-region": "us-east-1",
          "awslogs-stream-prefix": "ecs"
        }
      }
    }
  ]
}
```

**Service Configuration:**

```bash
# Create ECS service
aws ecs create-service \
  --cluster production-cluster \
  --service-name nestjs-api-service \
  --task-definition nestjs-api:1 \
  --desired-count 3 \
  --launch-type FARGATE \
  --network-configuration "awsvpcConfiguration={subnets=[subnet-12345],securityGroups=[sg-12345],assignPublicIp=ENABLED}"
```

### Kubernetes Deployment

**Deployment manifest:**

```yaml
# k8s/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nestjs-api
  labels:
    app: nestjs-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nestjs-api
  template:
    metadata:
      labels:
        app: nestjs-api
    spec:
      containers:
        - name: nestjs-api
          image: nestjs-api:latest
          ports:
            - containerPort: 3000
          env:
            - name: NODE_ENV
              value: 'production'
            - name: JWT_SECRET
              valueFrom:
                secretKeyRef:
                  name: nestjs-secrets
                  key: jwt-secret
            - name: DB_PASSWORD
              valueFrom:
                secretKeyRef:
                  name: nestjs-secrets
                  key: db-password
          resources:
            limits:
              memory: '512Mi'
              cpu: '500m'
            requests:
              memory: '256Mi'
              cpu: '250m'
          livenessProbe:
            httpGet:
              path: /health/live
              port: 3000
            initialDelaySeconds: 30
            periodSeconds: 10
          readinessProbe:
            httpGet:
              path: /health/ready
              port: 3000
            initialDelaySeconds: 5
            periodSeconds: 5
---
apiVersion: v1
kind: Service
metadata:
  name: nestjs-api-service
spec:
  selector:
    app: nestjs-api
  ports:
    - protocol: TCP
      port: 80
      targetPort: 3000
  type: LoadBalancer
```

**Horizontal Pod Autoscaler:**

```yaml
# k8s/hpa.yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nestjs-api-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nestjs-api
  minReplicas: 3
  maxReplicas: 10
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80
```

### Google Cloud Run

```yaml
# cloudbuild.yaml
steps:
  - name: 'gcr.io/cloud-builders/docker'
    args: ['build', '-t', 'gcr.io/$PROJECT_ID/nestjs-api', '.']
  - name: 'gcr.io/cloud-builders/docker'
    args: ['push', 'gcr.io/$PROJECT_ID/nestjs-api']
  - name: 'gcr.io/cloud-builders/gcloud'
    args:
      - 'run'
      - 'deploy'
      - 'nestjs-api'
      - '--image'
      - 'gcr.io/$PROJECT_ID/nestjs-api'
      - '--region'
      - 'us-central1'
      - '--platform'
      - 'managed'
      - '--allow-unauthenticated'
```

### Heroku Deployment

```bash
# Heroku deployment
heroku create your-app-name
heroku addons:create heroku-postgresql:hobby-dev
heroku addons:create heroku-redis:hobby-dev

# Set environment variables
heroku config:set NODE_ENV=production
heroku config:set JWT_SECRET=your-jwt-secret

# Deploy
git push heroku main
```

**Procfile:**

```
web: node dist/main.js
release: npm run typeorm:migration:run
```

## Database Deployment

### Managed Database Services

**AWS RDS PostgreSQL:**

```bash
# Create RDS instance
aws rds create-db-instance \
  --db-instance-identifier nestjs-production \
  --db-instance-class db.t3.micro \
  --engine postgres \
  --engine-version 16.1 \
  --allocated-storage 20 \
  --storage-type gp2 \
  --db-name nestjs_production \
  --master-username dbadmin \
  --master-user-password your-secure-password \
  --vpc-security-group-ids sg-12345678 \
  --backup-retention-period 7 \
  --storage-encrypted
```

**Google Cloud SQL:**

```bash
# Create Cloud SQL instance
gcloud sql instances create nestjs-production \
  --database-version=POSTGRES_16 \
  --tier=db-f1-micro \
  --region=us-central1 \
  --storage-type=SSD \
  --storage-size=10GB \
  --backup-start-time=03:00
```

### Database Migration in Production

```bash
#!/bin/bash
# deploy/migrate.sh

set -e

echo "🗄️  Running database migrations..."

# Backup database before migration
pg_dump $DATABASE_URL > "backup-$(date +%Y%m%d-%H%M%S).sql"

# Run migrations
npm run typeorm:migration:run

echo "✅ Database migration completed"
```

**Migration Strategy:**

```bash
# Zero-downtime migration strategy
# 1. Deploy new version with backward-compatible changes
# 2. Run migrations
# 3. Verify application health
# 4. Remove old code/columns in next release
```

## Load Balancing

### Application Load Balancer (AWS)

```bash
# Create target group
aws elbv2 create-target-group \
  --name nestjs-api-targets \
  --protocol HTTP \
  --port 3000 \
  --vpc-id vpc-12345678 \
  --health-check-path /health/live \
  --health-check-interval-seconds 30

# Create load balancer
aws elbv2 create-load-balancer \
  --name nestjs-api-lb \
  --subnets subnet-12345678 subnet-87654321 \
  --security-groups sg-12345678 \
  --scheme internet-facing
```

### Nginx Load Balancer

```nginx
upstream api_backend {
    least_conn;
    server api1.example.com:3000 weight=1 max_fails=3 fail_timeout=30s;
    server api2.example.com:3000 weight=1 max_fails=3 fail_timeout=30s;
    server api3.example.com:3000 weight=1 max_fails=3 fail_timeout=30s;
}

server {
    listen 80;

    location / {
        proxy_pass http://api_backend;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;

        # Health check
        proxy_connect_timeout 5s;
        proxy_send_timeout 5s;
        proxy_read_timeout 5s;
    }
}
```

## SSL/TLS Configuration

### Let's Encrypt with Certbot

```bash
# Install certbot
sudo apt-get install certbot python3-certbot-nginx

# Obtain certificate
sudo certbot --nginx -d api.example.com

# Auto-renewal
echo "0 12 * * * /usr/bin/certbot renew --quiet" | sudo crontab -
```

### AWS Certificate Manager

```bash
# Request certificate
aws acm request-certificate \
  --domain-name api.example.com \
  --subject-alternative-names *.api.example.com \
  --validation-method DNS
```

### SSL Configuration

```nginx
# Strong SSL configuration
ssl_protocols TLSv1.2 TLSv1.3;
ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:ECDHE-RSA-AES256-GCM-SHA384;
ssl_prefer_server_ciphers off;
ssl_session_cache shared:SSL:10m;
ssl_session_timeout 10m;

# HSTS
add_header Strict-Transport-Security "max-age=31536000; includeSubDomains" always;

# OCSP stapling
ssl_stapling on;
ssl_stapling_verify on;
```

## Monitoring & Logging

### Application Performance Monitoring

**Sentry Integration:**

```typescript
// src/main.ts
import * as Sentry from '@sentry/node';

if (process.env.NODE_ENV === 'production') {
  Sentry.init({
    dsn: process.env.SENTRY_DSN,
    environment: process.env.NODE_ENV,
  });
}
```

**Datadog APM:**

```typescript
// src/main.ts
import tracer from 'dd-trace';

if (process.env.NODE_ENV === 'production') {
  tracer.init({
    service: 'nestjs-api',
    env: process.env.NODE_ENV,
  });
}
```

### Structured Logging

```typescript
// src/common/logger/winston.config.ts
import { format, transports } from 'winston';

export const productionWinstonConfig = {
  level: 'info',
  format: format.combine(
    format.timestamp(),
    format.errors({ stack: true }),
    format.json(),
  ),
  transports: [
    new transports.Console(),
    new transports.File({
      filename: 'logs/error.log',
      level: 'error',
      maxsize: 5242880, // 5MB
      maxFiles: 5,
    }),
    new transports.File({
      filename: 'logs/combined.log',
      maxsize: 5242880, // 5MB
      maxFiles: 5,
    }),
  ],
};
```

### Prometheus Metrics

```typescript
// src/common/metrics/prometheus.service.ts
import { Injectable } from '@nestjs/common';
import { register, Counter, Histogram } from 'prom-client';

@Injectable()
export class PrometheusService {
  private readonly httpRequestsTotal = new Counter({
    name: 'http_requests_total',
    help: 'Total number of HTTP requests',
    labelNames: ['method', 'route', 'status_code'],
  });

  private readonly httpRequestDuration = new Histogram({
    name: 'http_request_duration_seconds',
    help: 'Duration of HTTP requests in seconds',
    labelNames: ['method', 'route'],
  });

  recordHttpRequest(
    method: string,
    route: string,
    statusCode: number,
    duration: number,
  ) {
    this.httpRequestsTotal.inc({ method, route, status_code: statusCode });
    this.httpRequestDuration.observe({ method, route }, duration);
  }

  getMetrics(): string {
    return register.metrics();
  }
}
```

## CI/CD Pipelines

### GitHub Actions

```yaml
# .github/workflows/deploy.yml
name: Deploy to Production

on:
  push:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Node.js
        uses: actions/setup-node@v3
        with:
          node-version: '18'
          cache: 'npm'
      - name: Install dependencies
        run: npm ci
      - name: Run tests
        run: npm run test:all
      - name: Security audit
        run: npm audit --audit-level moderate

  build-and-deploy:
    needs: test
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3

      - name: Configure AWS credentials
        uses: aws-actions/configure-aws-credentials@v2
        with:
          aws-access-key-id: ${{ secrets.AWS_ACCESS_KEY_ID }}
          aws-secret-access-key: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
          aws-region: us-east-1

      - name: Login to Amazon ECR
        id: login-ecr
        uses: aws-actions/amazon-ecr-login@v1

      - name: Build and push Docker image
        env:
          ECR_REGISTRY: ${{ steps.login-ecr.outputs.registry }}
          ECR_REPOSITORY: nestjs-api
          IMAGE_TAG: ${{ github.sha }}
        run: |
          docker build -t $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG .
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG
          docker tag $ECR_REGISTRY/$ECR_REPOSITORY:$IMAGE_TAG $ECR_REGISTRY/$ECR_REPOSITORY:latest
          docker push $ECR_REGISTRY/$ECR_REPOSITORY:latest

      - name: Deploy to ECS
        run: |
          aws ecs update-service \
            --cluster production-cluster \
            --service nestjs-api-service \
            --force-new-deployment
```

### GitLab CI/CD

```yaml
# .gitlab-ci.yml
stages:
  - test
  - build
  - deploy

variables:
  DOCKER_DRIVER: overlay2
  DOCKER_TLS_CERTDIR: '/certs'

test:
  stage: test
  image: node:18
  cache:
    paths:
      - node_modules/
  script:
    - npm ci
    - npm run test:all
    - npm audit --audit-level moderate

build:
  stage: build
  image: docker:latest
  services:
    - docker:dind
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA

deploy:
  stage: deploy
  image: alpine/k8s:latest
  script:
    - kubectl set image deployment/nestjs-api
      nestjs-api=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
    - kubectl rollout status deployment/nestjs-api
  only:
    - main
```

## Security Considerations

### Production Security Checklist

- [ ] **Environment Variables**: No secrets in code or logs
- [ ] **HTTPS Only**: Force HTTPS redirect
- [ ] **Security Headers**: CSP, HSTS, X-Frame-Options
- [ ] **Rate Limiting**: API rate limiting configured
- [ ] **Input Validation**: All inputs validated and sanitized
- [ ] **Authentication**: JWT tokens with short expiration
- [ ] **Authorization**: Role-based access control
- [ ] **Database Security**: Connection encryption, least privilege
- [ ] **Container Security**: Non-root user, minimal base image
- [ ] **Network Security**: Firewall rules, VPC configuration

### Security Headers Configuration

```typescript
// src/main.ts
import helmet from 'helmet';

app.use(
  helmet({
    contentSecurityPolicy: {
      directives: {
        defaultSrc: ["'self'"],
        styleSrc: ["'self'", "'unsafe-inline'"],
        scriptSrc: ["'self'"],
        imgSrc: ["'self'", 'data:', 'https:'],
      },
    },
    hsts: {
      maxAge: 31536000,
      includeSubDomains: true,
      preload: true,
    },
  }),
);
```

### WAF Configuration (AWS)

```bash
# Create WAF rule to block common attacks
aws wafv2 create-rule-group \
  --name "NestJSAPIProtection" \
  --scope "REGIONAL" \
  --capacity 100 \
  --rules file://waf-rules.json
```

## Performance Optimization

### Application Optimization

```typescript
// src/main.ts
import compression from 'compression';

// Enable compression
app.use(
  compression({
    filter: (req, res) => {
      if (req.headers['x-no-compression']) {
        return false;
      }
      return compression.filter(req, res);
    },
    level: 6,
    threshold: 100 * 1024, // 100KB
  }),
);

// Connection pooling
app.use(compression());
```

### Database Optimization

```typescript
// src/database/data-source.ts
export const AppDataSource = new DataSource({
  type: 'postgres',
  // Connection pooling
  extra: {
    max: 20,
    min: 5,
    acquire: 30000,
    idle: 10000,
    evict: 60000,
  },
  // Query optimization
  logging: false,
  cache: {
    duration: 30000, // 30 seconds
  },
});
```

### Caching Strategy

```typescript
// src/common/interceptors/cache.interceptor.ts
@Injectable()
export class CacheInterceptor implements NestInterceptor {
  constructor(private readonly redis: Redis) {}

  async intercept(
    context: ExecutionContext,
    next: CallHandler,
  ): Promise<Observable<any>> {
    const request = context.switchToHttp().getRequest();
    const cacheKey = this.getCacheKey(request);

    const cachedResponse = await this.redis.get(cacheKey);
    if (cachedResponse) {
      return of(JSON.parse(cachedResponse));
    }

    return next.handle().pipe(
      tap((response) => {
        this.redis.setex(cacheKey, 300, JSON.stringify(response)); // 5 minutes
      }),
    );
  }
}
```

## Scaling Strategies

### Horizontal Scaling

**Auto Scaling Group (AWS):**

```bash
# Create launch template
aws ec2 create-launch-template \
  --launch-template-name nestjs-api-template \
  --version-description "NestJS API v1.0" \
  --launch-template-data file://launch-template.json

# Create auto scaling group
aws autoscaling create-auto-scaling-group \
  --auto-scaling-group-name nestjs-api-asg \
  --launch-template "LaunchTemplateName=nestjs-api-template,Version=1" \
  --min-size 2 \
  --max-size 10 \
  --desired-capacity 3 \
  --target-group-arns arn:aws:elasticloadbalancing:region:account:targetgroup/nestjs-api-targets/1234567890123456
```

**Kubernetes HPA:**

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: nestjs-api-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: nestjs-api
  minReplicas: 3
  maxReplicas: 20
  metrics:
    - type: Resource
      resource:
        name: cpu
        target:
          type: Utilization
          averageUtilization: 70
  behavior:
    scaleUp:
      stabilizationWindowSeconds: 60
      policies:
        - type: Percent
          value: 100
          periodSeconds: 15
    scaleDown:
      stabilizationWindowSeconds: 300
      policies:
        - type: Percent
          value: 10
          periodSeconds: 60
```

### Database Scaling

**Read Replicas:**

```typescript
// src/database/data-source.ts
export const AppDataSource = new DataSource({
  type: 'postgres',
  replication: {
    master: {
      host: 'primary-db.example.com',
      port: 5432,
      username: 'app_user',
      password: 'password',
      database: 'nestjs_production',
    },
    slaves: [
      {
        host: 'replica1-db.example.com',
        port: 5432,
        username: 'app_user',
        password: 'password',
        database: 'nestjs_production',
      },
      {
        host: 'replica2-db.example.com',
        port: 5432,
        username: 'app_user',
        password: 'password',
        database: 'nestjs_production',
      },
    ],
  },
});
```

## Backup & Recovery

### Database Backup Strategy

```bash
#!/bin/bash
# backup/db-backup.sh

set -e

BACKUP_DIR="/backups/postgresql"
DB_NAME="nestjs_production"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
BACKUP_FILE="${BACKUP_DIR}/${DB_NAME}_${TIMESTAMP}.sql"

# Create backup directory
mkdir -p $BACKUP_DIR

# Create database backup
pg_dump $DATABASE_URL > $BACKUP_FILE

# Compress backup
gzip $BACKUP_FILE

# Upload to S3
aws s3 cp "${BACKUP_FILE}.gz" s3://your-backup-bucket/database/

# Cleanup local backups older than 7 days
find $BACKUP_DIR -name "*.gz" -type f -mtime +7 -delete

echo "Backup completed: ${BACKUP_FILE}.gz"
```

### Automated Backup with Cron

```bash
# Crontab entry for daily backups at 2 AM
0 2 * * * /opt/nestjs-api/backup/db-backup.sh >> /var/log/backup.log 2>&1
```

### Disaster Recovery Plan

**Recovery Procedures:**

1. **Database Recovery:**

   ```bash
   # Restore from backup
   gunzip < backup_file.sql.gz | psql $DATABASE_URL
   ```

2. **Application Recovery:**

   ```bash
   # Redeploy application
   docker stack deploy -c docker-compose.production.yml nestjs-app

   # Scale up services
   docker service scale nestjs-app_app=3
   ```

3. **Data Verification:**

   ```bash
   # Health checks
   curl -f https://api.example.com/health/ready

   # Functional tests
   npm run test:e2e:production
   ```

## Troubleshooting

### Common Production Issues

**Application Won't Start:**

```bash
# Check logs
docker service logs nestjs-app_app

# Check environment variables
docker exec -it <container_id> env | grep -E '^(NODE_ENV|DB_|JWT_)'

# Test database connection
docker exec -it <container_id> npm run typeorm:schema:log
```

**High Memory Usage:**

```bash
# Monitor memory usage
docker stats

# Check for memory leaks
docker exec -it <container_id> node --inspect=0.0.0.0:9229 dist/main.js

# Analyze heap dumps
node --inspect --heap-prof dist/main.js
```

**Database Connection Issues:**

```bash
# Test database connectivity
pg_isready -h $DB_HOST -p $DB_PORT -U $DB_USERNAME

# Check connection pool
docker exec -it <container_id> npm run typeorm:query "SELECT * FROM pg_stat_activity"

# Monitor slow queries
docker exec -it <postgres_container> psql -c "SELECT query, calls, total_time FROM pg_stat_statements ORDER BY total_time DESC LIMIT 10"
```

**SSL/TLS Issues:**

```bash
# Test SSL certificate
openssl s_client -connect api.example.com:443 -servername api.example.com

# Check certificate expiration
openssl x509 -in certificate.crt -text -noout | grep "Not After"

# Verify certificate chain
curl -I https://api.example.com
```

### Monitoring and Alerting

**Prometheus Alerts:**

```yaml
# prometheus/alerts.yml
groups:
  - name: nestjs-api
    rules:
      - alert: HighMemoryUsage
        expr:
          container_memory_usage_bytes{name="nestjs-api"} /
          container_spec_memory_limit_bytes{name="nestjs-api"} > 0.8
        for: 5m
        labels:
          severity: warning
        annotations:
          summary: High memory usage detected

      - alert: HighErrorRate
        expr:
          rate(http_requests_total{status=~"5.."}[5m]) /
          rate(http_requests_total[5m]) > 0.1
        for: 2m
        labels:
          severity: critical
        annotations:
          summary: High error rate detected
```

### Performance Debugging

```bash
# CPU profiling
node --prof dist/main.js
node --prof-process isolate-*.log > profile.txt

# Memory profiling
node --inspect --expose-gc dist/main.js

# Network debugging
tcpdump -i any port 3000

# Database query analysis
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'user@example.com';
```

---

This comprehensive deployment guide provides everything needed to deploy the
NestJS API Starter Kit to production environments. Following these practices
will ensure a secure, scalable, and maintainable production deployment.

Remember to always test deployments in staging environments before production,
implement proper monitoring and alerting, and have a disaster recovery plan in
place.

**Congratulations!** You now have complete documentation for the NestJS API
Starter Kit, covering everything from setup to production deployment.
