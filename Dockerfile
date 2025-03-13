FROM eclipse-temurin:17-jre-alpine

# Create directories
RUN mkdir -p /opt/pusk/data /opt/pusk/log /opt/pusk/config

# Copy application files
COPY ./pusk /opt/pusk
COPY ./lib /opt/pusk/lib

# Copy configuration file
COPY ./pusk/data/application.properties /opt/pusk/config/application.properties

# Set execute permissions
RUN chmod +x /opt/pusk/ite-pusk-linux.sh

# Define volumes
VOLUME [ "/opt/pusk/data" ]
VOLUME [ "/opt/pusk/log" ]

# Copy and set entrypoint
COPY ./entrypoint.sh /opt/entrypoint.sh
RUN chmod +x /opt/entrypoint.sh

# Add health check
HEALTHCHECK --interval=30s --timeout=3s \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

WORKDIR /opt/pusk

ENTRYPOINT [ "/opt/entrypoint.sh" ]
