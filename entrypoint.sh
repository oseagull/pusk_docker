#!/bin/sh

JAVA_HOME=/opt/java/openjdk
PUSK_DIR=/opt/pusk
JAVA_CHECK_VER=$JAVA_HOME/bin/java

# Load secrets into environment variables
if [ -f "$CRYPTOGRAPHY_KEY_FILE" ]; then
    export CRYPTOGRAPHY_KEY=$(cat "$CRYPTOGRAPHY_KEY_FILE")
else
    echo "Error: Encryption key secret not found at $CRYPTOGRAPHY_KEY_FILE"
    exit 1
fi

if [ -f "$SECURITY_SALT_FILE" ]; then
    export SECURITY_SALT=$(cat "$SECURITY_SALT_FILE")
else
    echo "Error: Security salt secret not found at $SECURITY_SALT_FILE"
    exit 1
fi

# Get Java version
JAVA_VER=$($JAVA_HOME/bin/java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}' | awk -F '.'  '{print $1}')

# Проверка статуса приложения
check_status() {
    pid=$(pgrep -f ite-pusk.jar)
}

# Проверка наличия библиотек 1С
check_1c_libs() {
    cd $PUSK_DIR;
    if [ -f lib/com._1c.v8.core-1.0.30-SNAPSHOT.jar -a -f lib/netty-3.2.6.Final.jar -a -f lib/com._1c.v8.ibis-1.1.1-SNAPSHOT.jar -a -f lib/com._1c.v8.ibis.admin-1.6.7.jar -a -f lib/com._1c.v8.ibis.swp-1.1.1-SNAPSHOT.jar -a -f lib/com._1c.v8.swp-1.0.3-SNAPSHOT.jar -a -f lib/com._1c.v8.swp.netty-1.0.3-SNAPSHOT.jar ]; then
        echo "Библиотеки 1С присутствуют."
    else
        echo "Библиотеки 1С не найдены. Обратитесь к документации!"
        exit 1
    fi
}

# Проверка версии JAVA
check_java_ver() {
    if type $JAVA_CHECK_VER; then
        echo "Найдена JAVA $JAVA_VER версии в PATH."
        if [ $JAVA_VER -lt 17 ] ; then
            echo "Для корректной работы приложения установите Java версии не ниже 17,"
            echo "либо укажите требуемый путь до нужной версии в переменной JAVA_HOME в скрипте запуска."
            exit 1
        fi
    else
        echo "Java не найдена - требуется Java 17 версии или выше!"
        echo "Для корректной работы приложения установите Java версии не ниже 17,"
        echo "либо укажите требуемый путь до нужной версии в переменной JAVA_HOME в скрипте запуска."
        exit 1
    fi
}

# Handle shutdown signals
trap 'echo "Received SIGTERM/SIGINT, shutting down..."; exit 0' SIGTERM SIGINT

# Старт приложения
start() {
    check_java_ver
    check_status
    check_1c_libs

    if [ "$pid" ]; then
        echo "Приложение уже запущено."
        exit 1
    fi

    echo "Старт приложения: "

    # Create log directory if it doesn't exist
    mkdir -p "$PUSK_DIR/log"

    # Ensure proper permissions
    chown -R pusk:pusk "$PUSK_DIR/data" "$PUSK_DIR/log"

    # Лог консоли
    cd "$PUSK_DIR/bin"
    exec $JAVA_HOME/bin/java \
        -cp ite-pusk.jar:../lib/* \
        -Dloader.main=com.ite.utils.pusk.Application \
        org.springframework.boot.loader.PropertiesLauncher \
        --spring.config.import=optional:"$PUSK_DIR"/data/application.properties
}

# Старт приложения
start
