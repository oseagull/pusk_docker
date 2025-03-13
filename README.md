# PUSK Docker Implementation

This repository contains Docker configuration for building and running the PUSK application.

## Building the Docker Image

1. Build the image locally:
```bash
# Build with default tag
docker build -t segateekb/pusk:latest .

# Or with a specific version
docker build -t segateekb/pusk:1.0.0 .
```

2. Push to registry (optional):
```bash
docker push segateekb/pusk:latest
```

## Deployment Options

You can deploy this image using either Docker Compose or Docker Swarm.

### Option 1: Docker Compose Deployment

1. Create secrets directory and generate secrets:
```bash
# Create directory for secrets
mkdir -p secrets

# Generate encryption key
openssl rand -hex 16 > secrets/crypto_key.txt

# Generate salt
openssl rand -base64 16 > secrets/security_salt.txt

# Set proper permissions
chmod 600 secrets/crypto_key.txt secrets/security_salt.txt
```

2. Deploy with docker-compose:
```bash
docker-compose up -d

# Check logs
docker-compose logs -f
```

### Option 2: Docker Swarm Deployment

1. Initialize swarm (if not already done):
```bash
docker swarm init
```

2. Create Docker secrets:
```bash
# Create secrets in Swarm
openssl rand -hex 16 | docker secret create crypto_key -
openssl rand -base64 16 | docker secret create security_salt -
```

3. Deploy stack:
```bash
docker stack deploy -c docker-compose.yaml pusk
```

## Configuration

### Required Configuration Files

1. Application configuration (pusk/data/application.properties):
```properties
# Core settings remain the same
server.port=${PORT:8080}
...
# Secrets will be injected based on deployment method
cryptography.key=${CRYPTOGRAPHY_KEY}
security.salt=${SECURITY_SALT}
```

### Environment Variables
Available in both deployment methods:
- `PORT`: Application port (default: 8080)
- `LOGGING_LEVEL`: Log level (default: INFO)
- `SYSLOG_ENABLED`: Enable syslog (default: false)
- `SYSLOG_HOST`: Syslog server (default: localhost)
- `SYSLOG_FACILITY`: Syslog facility (default: LOCAL0)

## Monitoring

### Docker Compose
```bash
# View logs
docker-compose logs -f

# Check container status
docker-compose ps

# Container health
docker inspect $(docker-compose ps -q) | grep -A 10 Health
```

### Docker Swarm
```bash
# View service logs
docker service logs pusk_pusk

# Check service status
docker service ls

# View tasks
docker stack ps pusk
```

## Troubleshooting

### Common Issues

1. Container won't start:
```bash
# Check logs
# For Docker Compose:
docker-compose logs

# For Swarm:
docker service logs pusk_pusk
```

2. Secret access issues:
```bash
# For Docker Compose - verify secrets exist:
ls -l secrets/

# For Swarm - list secrets:
docker secret ls
```

## Security Notes

- Keep secrets secure and properly permissioned
- Regular security updates
- Monitor logs for issues
- Backup data regularly
- Rotate secrets periodically

## Important Notes

- The image contains everything needed to run the application
- Choose deployment method based on your needs:
  * Docker Compose: Simpler for single-host deployment
  * Docker Swarm: Better for production, multi-host deployment
- Both methods support secrets management, just implemented differently