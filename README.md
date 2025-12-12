# Strapi v5 Dockerized

A production-ready Strapi v5 CMS with PostgreSQL, Docker Compose for local development, and optimized for Render.com deployment.

## Prerequisites

- [Docker](https://docs.docker.com/get-docker/) and Docker Compose
- [Node.js](https://nodejs.org/) v18+ (for local development without Docker)

## Quick Start

### 1. Clone and Setup

```bash
git clone <your-repo-url>
cd strapi-dockerized
```

### 2. Start Development Environment

```bash
docker compose -f docker-compose.dev.yml up -d
```

This starts:
- **Strapi** on `http://localhost:1337` with hot reloading
- **PostgreSQL** on `localhost:5432`

### 3. View Logs

```bash
docker compose -f docker-compose.dev.yml logs -f strapi
```

Wait until you see `Strapi started successfully`.

### 4. Access Admin Panel

Open [http://localhost:1337/admin](http://localhost:1337/admin) and create your first admin user.

## Development

### Hot Reloading

The development setup mounts your local files into the container. Any changes to:
- `src/` - API routes, controllers, services
- `config/` - Configuration files

Will automatically restart the Strapi server.

### Useful Commands

```bash
# Start development environment
docker compose -f docker-compose.dev.yml up -d

# Stop development environment
docker compose -f docker-compose.dev.yml down

# View logs
docker compose -f docker-compose.dev.yml logs -f strapi

# Restart Strapi (after config changes)
docker compose -f docker-compose.dev.yml restart strapi

# Access Strapi container shell
docker exec -it strapi-dev sh

# Reset everything (including database)
docker compose -f docker-compose.dev.yml down -v
```

### Without Docker

If you prefer running without Docker:

```bash
# Install dependencies
npm install

# Start PostgreSQL separately (or use Docker)
docker compose -f docker-compose.dev.yml up -d strapiDB

# Copy and configure environment
cp env.example .env
# Edit .env with your settings

# Run development server
npm run develop
```

## Project Structure

```
strapi-dockerized/
├── config/                 # Strapi configuration
│   ├── admin.ts           # Admin panel settings
│   ├── api.ts             # API settings
│   ├── database.ts        # Database connection
│   ├── middlewares.ts     # Middleware stack
│   ├── plugins.ts         # Plugin configuration
│   └── server.ts          # Server settings
├── src/
│   ├── admin/             # Admin panel customization
│   ├── api/               # Your content-types and APIs
│   ├── extensions/        # Plugin extensions
│   └── index.ts           # Application lifecycle hooks
├── public/
│   └── uploads/           # Media uploads
├── docker-compose.yml     # Production Docker Compose
├── docker-compose.dev.yml # Development Docker Compose
├── Dockerfile             # Multi-stage production build
├── render.yaml            # Render Blueprint
└── package.json
```

## Configuration

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `DATABASE_HOST` | PostgreSQL host | `localhost` |
| `DATABASE_PORT` | PostgreSQL port | `5432` |
| `DATABASE_NAME` | Database name | `strapi` |
| `DATABASE_USERNAME` | Database user | `strapi` |
| `DATABASE_PASSWORD` | Database password | `password` |
| `APP_KEYS` | Session keys (comma-separated) | - |
| `API_TOKEN_SALT` | API token salt | - |
| `ADMIN_JWT_SECRET` | Admin JWT secret | - |
| `TRANSFER_TOKEN_SALT` | Transfer token salt | - |
| `JWT_SECRET` | JWT secret | - |

### Generate Secrets

For production, generate secure secrets:

```bash
openssl rand -base64 32
```

## Production Build

### Test Production Build Locally

```bash
# Build and run production image
docker compose up --build -d

# View logs
docker compose logs -f strapi
```

Access at [http://localhost:1337/admin](http://localhost:1337/admin)

### Stop Production

```bash
docker compose down
```

## Deployment

See [DEPLOYMENT.md](./DEPLOYMENT.md) for detailed Render.com deployment instructions.

## Creating Content Types

1. Access admin panel at `/admin`
2. Go to **Content-Type Builder**
3. Create your content types
4. Content types are saved to `src/api/`

## Troubleshooting

### Container won't start

```bash
# Check logs
docker compose -f docker-compose.dev.yml logs strapi

# Reset node_modules volume
docker compose -f docker-compose.dev.yml down
docker volume rm strapi-dockerized_strapi-node-modules
docker compose -f docker-compose.dev.yml up -d
```

### Database connection errors

```bash
# Check if PostgreSQL is healthy
docker compose -f docker-compose.dev.yml ps

# View PostgreSQL logs
docker compose -f docker-compose.dev.yml logs strapiDB
```

### Port already in use

```bash
# Find process using port 1337
lsof -i :1337

# Or change the port in docker-compose.dev.yml
ports:
  - "3000:1337"  # Use port 3000 instead
```

## License

MIT

