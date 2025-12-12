# Multi-stage Dockerfile for Strapi v5
# Optimized for Render.com deployment

# ============================================
# Stage 1: Base - Common setup
# ============================================
FROM node:22-alpine AS base

RUN apk update && apk add --no-cache \
    build-base \
    gcc \
    autoconf \
    automake \
    zlib-dev \
    libpng-dev \
    nasm \
    bash \
    vips-dev \
    git

WORKDIR /opt/app

# ============================================
# Stage 2: Dependencies - Install ALL packages (including devDependencies for build)
# ============================================
FROM base AS dependencies

# Don't set NODE_ENV=production here - we need devDependencies for building
ENV NODE_ENV=development

COPY package.json package-lock.json ./

RUN npm ci

# ============================================
# Stage 3: Build - Build the application
# ============================================
FROM dependencies AS build

COPY . .

# Keep NODE_ENV=development during build to ensure all dependencies are available
RUN npm run build

# ============================================
# Stage 4: Production - Final image
# ============================================
FROM node:22-alpine AS production

RUN apk add --no-cache vips-dev

ENV NODE_ENV=production

WORKDIR /opt/app

# Copy package files
COPY --from=build /opt/app/package.json /opt/app/package-lock.json ./

# Copy built application (using compiled JS from dist/)
COPY --from=build /opt/app/dist ./dist
COPY --from=build /opt/app/dist/build ./build
COPY --from=build /opt/app/dist/config ./config
COPY --from=build /opt/app/dist/src ./src
COPY --from=build /opt/app/public ./public
COPY --from=build /opt/app/database ./database

# Install production dependencies only
RUN npm ci --omit=dev

# Create uploads directory
RUN mkdir -p ./public/uploads

# Set proper permissions
RUN chown -R node:node /opt/app
USER node

EXPOSE 1337

CMD ["npm", "run", "start"]

