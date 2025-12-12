# Debug & Troubleshooting Guide

Quick reference for debugging the Strapi Docker setup.

## 📋 View Logs

```bash
# Last 50 lines
docker compose -f docker-compose.dev.yml logs strapi --tail 50

# Follow logs in real-time
docker compose -f docker-compose.dev.yml logs -f strapi

# All services logs (strapi + database)
docker compose -f docker-compose.dev.yml logs -f

# Filter logs by time (last 5 minutes)
docker compose -f docker-compose.dev.yml logs --since 5m strapi
```

## 🔍 Container Status

```bash
# List running containers
docker compose -f docker-compose.dev.yml ps

# Show resource usage (CPU, memory)
docker compose -f docker-compose.dev.yml stats

# See running processes inside container
docker compose -f docker-compose.dev.yml top
```

## 🔄 Container Management

```bash
# Restart Strapi (keeps database running)
docker compose -f docker-compose.dev.yml restart strapi

# Stop all services
docker compose -f docker-compose.dev.yml stop

# Start all services
docker compose -f docker-compose.dev.yml start

# Stop and remove containers (keeps volumes/data)
docker compose -f docker-compose.dev.yml down

# Stop, remove containers AND volumes (⚠️ deletes data)
docker compose -f docker-compose.dev.yml down -v

# Rebuild and start (after Dockerfile changes)
docker compose -f docker-compose.dev.yml up -d --build
```

## 🖥️ Execute Commands Inside Container

```bash
# Open shell in Strapi container
docker compose -f docker-compose.dev.yml exec strapi sh

# Run a single command
docker compose -f docker-compose.dev.yml exec strapi ls -la /opt/app

# Check Node version
docker compose -f docker-compose.dev.yml exec strapi node -v

# Check npm packages
docker compose -f docker-compose.dev.yml exec strapi npm list --depth=0

# Clear Strapi cache
docker compose -f docker-compose.dev.yml exec strapi rm -rf .cache .strapi node_modules/.strapi
```

## 🗄️ Database Commands

```bash
# Access PostgreSQL shell
docker compose -f docker-compose.dev.yml exec strapiDB psql -U strapi -d strapi

# List tables
docker compose -f docker-compose.dev.yml exec strapiDB psql -U strapi -d strapi -c "\dt"

# Backup database
docker compose -f docker-compose.dev.yml exec strapiDB pg_dump -U strapi strapi > backup.sql

# Restore database
cat backup.sql | docker compose -f docker-compose.dev.yml exec -T strapiDB psql -U strapi -d strapi
```

## 🧹 Cleanup Commands

```bash
# Remove unused Docker images
docker image prune -f

# Remove unused volumes
docker volume prune -f

# Full cleanup (containers, networks, images, volumes)
docker system prune -a --volumes

# Remove project-specific volumes
docker volume rm strapi-dockerized_strapi-data strapi-dockerized_strapi-uploads
```

## 🐛 Common Issues

### Vite Cache Issues (React errors in admin)
```bash
docker compose -f docker-compose.dev.yml exec strapi rm -rf node_modules/.strapi/vite
docker compose -f docker-compose.dev.yml restart strapi
```

### 401 Errors in Admin Panel
1. Hard refresh browser: `Cmd+Shift+R` (Mac) / `Ctrl+Shift+R` (Windows)
2. Log out and log back in
3. Clear browser cookies for localhost:1337

### Database Connection Issues
```bash
# Check if database is running
docker compose -f docker-compose.dev.yml ps strapiDB

# Check database logs
docker compose -f docker-compose.dev.yml logs strapiDB --tail 20

# Restart database
docker compose -f docker-compose.dev.yml restart strapiDB
```

### Container Won't Start
```bash
# Check for errors
docker compose -f docker-compose.dev.yml logs strapi

# Rebuild from scratch
docker compose -f docker-compose.dev.yml down
docker compose -f docker-compose.dev.yml build --no-cache
docker compose -f docker-compose.dev.yml up -d
```

## ⚡ Shell Alias (Optional)

Add to your `~/.zshrc` or `~/.bashrc`:

```bash
alias dcd="docker compose -f docker-compose.dev.yml"
alias dcp="docker compose -f docker-compose.yml"
```

Then use:
```bash
dcd logs -f strapi
dcd restart strapi
dcd exec strapi sh
```

## 🌐 Production Commands

```bash
# Production logs
docker compose logs strapi --tail 50

# Production restart
docker compose restart strapi

# Rebuild production
docker compose down
docker compose build --no-cache
docker compose up -d
```

