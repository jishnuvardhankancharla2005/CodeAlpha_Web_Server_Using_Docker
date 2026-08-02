FROM nginx:1.27-alpine

LABEL description="Nginx Load Balancer for Web Server Replicas"

# Install curl for health probes
RUN apk add --no-cache curl

# Copy Load Balancer Nginx configuration
COPY nginx.conf /etc/nginx/nginx.conf

EXPOSE 80

HEALTHCHECK --interval=10s --timeout=3s --start-period=5s --retries=3 \
  CMD curl -f http://localhost/lb-healthz || exit 1

CMD ["nginx", "-g", "daemon off;"]
