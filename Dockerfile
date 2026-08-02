# ==============================================================================
# CodeAlpha Docker Web Server - Optimized Lightweight Production Build
# Base Image: Nginx Alpine (Lightweight & Stateless)
# ==============================================================================
FROM nginx:1.27-alpine

LABEL maintainer="CodeAlpha Docker Project <admin@codealpha.dev>"
LABEL description="Optimized Nginx Alpine Web Server with Health Check & Volume Persistence"

# Install curl for HEALTHCHECK probes
RUN apk add --no-cache curl

# Copy custom Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

# Copy web static application content
COPY html /usr/share/nginx/html

# Expose HTTP port 80 inside container
EXPOSE 80

# HEALTHCHECK directive to monitor container health automatically
HEALTHCHECK --interval=15s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/healthz || exit 1

# Start Nginx in foreground
CMD ["nginx", "-g", "daemon off;"]
