# Deploying to Render.com

This guide covers deploying your Strapi CMS to Render.com with a managed PostgreSQL database.

## Option 1: One-Click Deploy with Blueprint (Recommended)

The easiest way to deploy is using Render's Blueprint feature with the included `render.yaml`.

### Steps

1. **Push to GitHub**
   ```bash
   git init
   git add .
   git commit -m "feat: PROJ-0000: Initial Strapi setup"
   git remote add origin <your-github-repo-url>
   git push -u origin main
   ```

2. **Create Render Account**
   - Go to [render.com](https://render.com) and sign up

3. **Deploy Blueprint**
   - Click **New** → **Blueprint**
   - Connect your GitHub repository
   - Render will detect `render.yaml` and configure:
     - Web service with Docker
     - PostgreSQL database
     - All environment variables (auto-generated secrets)

4. **Wait for Deployment**
   - Initial build takes ~5-10 minutes
   - PostgreSQL provisioning may take a few minutes

5. **Access Your CMS**
   - Once deployed, click on your web service
   - Open the provided URL + `/admin`
   - Create your first admin user

## Option 2: Manual Deployment

If you prefer manual setup or need more control:

### Step 1: Create PostgreSQL Database

1. Go to Render Dashboard
2. Click **New** → **PostgreSQL**
3. Configure:
   - **Name**: `strapi-db`
   - **Database**: `strapi`
   - **User**: `strapi`
   - **Region**: Choose closest to your users
   - **Plan**: Starter ($7/month) or higher
4. Click **Create Database**
5. Copy the **Internal Database URL** for later

### Step 2: Create Web Service

1. Click **New** → **Web Service**
2. Connect your GitHub repository
3. Configure:
   - **Name**: `strapi-cms`
   - **Region**: Same as database
   - **Runtime**: Docker
   - **Dockerfile Path**: `./Dockerfile`
   - **Plan**: Starter ($7/month) or higher

### Step 3: Configure Environment Variables

Add these environment variables in your web service settings:

| Key | Value |
|-----|-------|
| `NODE_ENV` | `production` |
| `HOST` | `0.0.0.0` |
| `PORT` | `1337` |
| `DATABASE_CLIENT` | `postgres` |
| `DATABASE_URL` | *(from your PostgreSQL internal URL)* |
| `APP_KEYS` | *(click Generate)* |
| `API_TOKEN_SALT` | *(click Generate)* |
| `ADMIN_JWT_SECRET` | *(click Generate)* |
| `TRANSFER_TOKEN_SALT` | *(click Generate)* |
| `JWT_SECRET` | *(click Generate)* |

### Step 4: Deploy

Click **Create Web Service** and wait for the build to complete.

## Environment Variables Reference

### Required for Production

| Variable | Description | How to Generate |
|----------|-------------|-----------------|
| `DATABASE_URL` | PostgreSQL connection string | Provided by Render |
| `APP_KEYS` | Session encryption keys | `openssl rand -base64 32` (run twice, comma-separate) |
| `API_TOKEN_SALT` | API token salt | `openssl rand -base64 32` |
| `ADMIN_JWT_SECRET` | Admin panel JWT secret | `openssl rand -base64 32` |
| `TRANSFER_TOKEN_SALT` | Data transfer token salt | `openssl rand -base64 32` |
| `JWT_SECRET` | API JWT secret | `openssl rand -base64 32` |

### Optional

| Variable | Description | Default |
|----------|-------------|---------|
| `PUBLIC_URL` | Public URL of your Strapi instance | Auto-detected |
| `DATABASE_SSL` | Enable SSL for database | `true` in production |

## render.yaml Explained

```yaml
services:
  - type: web
    name: strapi-cms
    runtime: docker
    dockerfilePath: ./Dockerfile
    plan: starter
    region: frankfurt
    healthCheckPath: /_health
    envVars:
      - key: DATABASE_URL
        fromDatabase:
          name: strapi-db
          property: connectionString  # Auto-links to database
      - key: APP_KEYS
        generateValue: true  # Auto-generates secure value

databases:
  - name: strapi-db
    plan: starter
    databaseName: strapi
    user: strapi
    region: frankfurt
```

## Updating Your Deployment

### Automatic Deploys

By default, Render auto-deploys when you push to the main branch:

```bash
git add .
git commit -m "feat: PROJ-0000: Add new content type"
git push origin main
```

### Manual Deploys

1. Go to your web service in Render
2. Click **Manual Deploy** → **Deploy latest commit**

## Persistent Storage for Uploads

By default, uploaded media is stored in the container and will be lost on redeploys. For production, configure external storage:

### Option A: Cloudinary (Recommended)

1. Install the Cloudinary provider:
   ```bash
   npm install @strapi/provider-upload-cloudinary
   ```

2. Configure in `config/plugins.ts`:
   ```typescript
   export default ({ env }) => ({
     upload: {
       config: {
         provider: 'cloudinary',
         providerOptions: {
           cloud_name: env('CLOUDINARY_NAME'),
           api_key: env('CLOUDINARY_KEY'),
           api_secret: env('CLOUDINARY_SECRET'),
         },
       },
     },
   });
   ```

3. Add environment variables in Render:
   - `CLOUDINARY_NAME`
   - `CLOUDINARY_KEY`
   - `CLOUDINARY_SECRET`

### Option B: AWS S3

1. Install the AWS provider:
   ```bash
   npm install @strapi/provider-upload-aws-s3
   ```

2. Configure in `config/plugins.ts`:
   ```typescript
   export default ({ env }) => ({
     upload: {
       config: {
         provider: 'aws-s3',
         providerOptions: {
           s3Options: {
             credentials: {
               accessKeyId: env('AWS_ACCESS_KEY_ID'),
               secretAccessKey: env('AWS_ACCESS_SECRET'),
             },
             region: env('AWS_REGION'),
             params: {
               Bucket: env('AWS_BUCKET'),
             },
           },
         },
       },
     },
   });
   ```

## Monitoring & Logs

### View Logs

1. Go to your web service in Render
2. Click **Logs** tab
3. Filter by type: Build, Deploy, or Runtime

### Health Checks

Render automatically monitors the `/_ health` endpoint. If your service becomes unhealthy, Render will:
1. Attempt to restart the service
2. Alert you via email/Slack (if configured)

## Scaling

### Vertical Scaling

Upgrade your plan for more resources:
- **Starter**: 512 MB RAM, 0.5 CPU
- **Standard**: 2 GB RAM, 1 CPU
- **Pro**: 4 GB RAM, 2 CPU

### Horizontal Scaling (Pro+)

On Pro plans, you can run multiple instances behind a load balancer.

## Troubleshooting

### Build Fails

1. Check build logs in Render
2. Common issues:
   - Missing dependencies in `package.json`
   - TypeScript errors (check locally with `npm run build`)

### Database Connection Errors

1. Verify `DATABASE_URL` is set correctly
2. Check PostgreSQL is running in Render dashboard
3. Ensure database and web service are in the same region

### 502 Bad Gateway

1. Check runtime logs
2. Verify the `PORT` environment variable is set to `1337`
3. Check health endpoint: `https://your-app.onrender.com/_health`

### Slow Cold Starts

Free tier services spin down after inactivity. Consider:
- Upgrading to Starter plan ($7/month)
- Using a service like UptimeRobot to ping your app

## Costs

| Service | Plan | Monthly Cost |
|---------|------|--------------|
| Web Service | Starter | $7 |
| PostgreSQL | Starter | $7 |
| **Total** | | **$14/month** |

Free tier is available but has limitations:
- Services spin down after 15 minutes of inactivity
- 750 hours/month across all free services
- PostgreSQL expires after 90 days

## Support

- [Strapi Documentation](https://docs.strapi.io)
- [Render Documentation](https://render.com/docs)
- [Strapi Discord](https://discord.strapi.io)

