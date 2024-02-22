FROM eclipse-temurin:17

LABEL maintainer="Egor Ivanov <e.ivanov@1cdevelopers.ru>"

COPY ./pusk /opt/pusk
COPY ./lib /opt/pusk/lib

RUN chmod +x /opt/pusk/ite-pusk-linux.sh

VOLUME [ "/opt/pusk/data" ]
VOLUME [ "/opt/pusk/log" ]

COPY ./entrypoint.sh /opt/entrypoint.sh

ENTRYPOINT [ "/opt/entrypoint.sh" ]
