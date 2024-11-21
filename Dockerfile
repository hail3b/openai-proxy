# Build stage
FROM node:18-alpine AS builder

# Install build dependencies
RUN apk add --no-cache libc6-compat python3 make g++

# Install pnpm
RUN npm install -g pnpm@8.9.0

WORKDIR /app

# Copy package files
COPY package.json pnpm-lock.yaml ./

# Install dependencies with specific network timeout and retry settings
RUN pnpm install --frozen-lockfile --network-timeout 100000 --retry 3

# Copy source code
COPY . .

# Build the application
RUN pnpm run vercel-build

# Production stage
FROM node:18-alpine AS runner

WORKDIR /app

# Create a non-root user
RUN addgroup --system --gid 1001 nodejs && \
    adduser --system --uid 1001 nextjs

# Install production only dependencies
RUN apk add --no-cache libc6-compat && \
    npm install -g pnpm@8.9.0

# Copy necessary files from builder
COPY --from=builder --chown=nextjs:nodejs /app/package.json .
COPY --from=builder --chown=nextjs:nodejs /app/pnpm-lock.yaml .
COPY --from=builder --chown=nextjs:nodejs /app/.next ./.next
COPY --from=builder --chown=nextjs:nodejs /app/public ./public

# Install production dependencies only with specific network timeout and retry settings
RUN pnpm install --prod --frozen-lockfile --network-timeout 100000 --retry 3

# Set environment variables
ENV NODE_ENV=production \
    PORT=3000

# Switch to non-root user
USER nextjs

# Expose the port the app runs on
EXPOSE 3000

# Start the application
CMD ["pnpm", "start"]
