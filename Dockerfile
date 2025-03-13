FROM eclipse-temurin:17-jre-alpine

# Create non-root user
RUN addgroup -S pusk && \
    adduser -S pusk -G pusk && \
    mkdir -p /opt/pusk/data /opt/pusk/log && \
    chown -R pusk:pusk /opt/pusk

# Copy application files
COPY --chown=pusk:pusk ./pusk /opt/pusk
COPY --chown=pusk:pusk ./lib /opt/pusk/lib

# Set execute permissions
RUN chmod +x /opt/pusk/ite-pusk-linux.sh

# Define volumes
VOLUME [ "/opt/pusk/data" ]
VOLUME [ "/opt/pusk/log" ]

# Copy and set entrypoint
COPY --chown=pusk:pusk ./entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

# Switch to non-root user
USER pusk

# Add health check
HEALTHCHECK --interval=30s --timeout=3s \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

WORKDIR /opt/pusk

ENTRYPOINT [ "/opt/entrypoint.sh" ]
