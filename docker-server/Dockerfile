# Example Dockerfile for custom applications
# Based on Alpine Linux for minimal size
FROM alpine:latest

# Install basic packages
RUN apk add --no-cache \
    bash \
    curl \
    wget \
    nano \
    htop

# Create app directory
WORKDIR /app

# Copy application files (if any)
# COPY . /app

# Expose port (adjust as needed)
EXPOSE 8080

# Create non-root user for security
RUN addgroup -g 1000 appuser && \
    adduser -D -s /bin/bash -u 1000 -G appuser appuser

# Switch to non-root user
USER appuser

# Default command
CMD ["sh"]
