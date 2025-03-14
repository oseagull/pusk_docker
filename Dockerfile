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
RUN echo -e '#!/bin/sh\n echo "systemd (systemctl) is not available in this container."\n exit 0' > /usr/local/bin/systemctl && \
    chmod +x /usr/local/bin/systemctl && \
    ln -s /usr/local/bin/systemctl /bin/systemctl


# Add health check
HEALTHCHECK --interval=30s --timeout=3s \
    CMD wget --no-verbose --tries=1 --spider http://localhost:8080/actuator/health || exit 1

WORKDIR /opt/pusk

ENTRYPOINT [ "/opt/entrypoint.sh" ]
