#!/bin/sh
#
# script for a ite-pusk application with java-check
JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/bin/java::")

# Раскомментируйте строку ниже и заполните вручную путь к каталогу с java в случае, если переменная $JAVA_HOME отсутствует или в ней указан путь к java ниже 17 версии
JAVA_HOME=/opt/java/openjdk

JAVA_VER=$($JAVA_HOME/bin/java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}' | awk -F '.'  '{print $1}')
PUSK_DIR=$(dirname $(readlink -e "$0"))
JAVA_CHECK_VER=$JAVA_HOME/bin/java

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
    if [ $JAVA_VER -lt 17 ] ;  then
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
  return 0

}

# Старт приложения
start() {

  check_java_ver
  check_status
  check_1c_libs

  if [ $pid ] ; then
    echo "Приложение уже запущено."
    exit 1
  fi

  echo -n "Старт приложения: "

  # Лог консоли
  cd "$PUSK_DIR/bin";
  $JAVA_HOME/bin/java -cp ite-pusk.jar:../lib/* -Dloader.main=com.ite.utils.pusk.Application org.springframework.boot.loader.PropertiesLauncher --spring.config.import=optional:"$PUSK_DIR"/data/application.properties >> /dev/null 2>&1 &
  echo "OK"

}

# Остановка приложения
stop() {

  check_status

  if [ -n "${pid}" ]; then
      echo -n "Остановка приложения: "
      kill -9 $pid & sleep 5 & echo "OK"
  else
      echo "Приложение не запущено."
      exit 1
  fi

}

# Статус приложения
status() {

  check_java_ver
  check_status
  check_1c_libs

  if [ -n "${pid}" ] ; then
    echo "Приложение запущено."
  else
    echo "Приложение не запущено."
  fi

}

# # Генерация файла для сервиса
# install() {
  
#   check_java_ver

#   echo "Создание службы ite-pusk.service..."
#   cat > /etc/systemd/system/ite-pusk.service << EOF
# [Unit]
# Description=ite-pusk
# Wants=network-online.target
# After=network-online.target

# [Service]
# WorkingDirectory=$(dirname $(readlink -e "$0"))/
# Type=forking
# Restart=on-failure
# TimeoutStartSec=5
# TimeoutStopSec=5
# ExecStart=$(dirname $(readlink -e "$0"))/ite-pusk-linux.sh start
# SyslogIdentifier=ite-pusk
# ExecStop=$(dirname $(readlink -e "$0"))/ite-pusk-linux.sh stop
# RemainAfterExit=yes

# [Install]
# WantedBy=multi-user.target
# EOF
#   # restart daemon and enable service
#   echo "Обновление списка сервисов и включение автостарта ПУСКа"
#   sudo systemctl daemon-reload
#   sudo systemctl enable ite-pusk

#   echo "Введите 'sudo systemctl start ite-pusk' для запуска сервиса."
#   echo "Введите 'sudo systemctl stop ite-pusk' для остановки сервиса."

# }

# # Удаление сервиса

# uninstall() {

#   sudo systemctl disable ite-pusk
#   sudo rm /etc/systemd/system/ite-pusk.service
#   sudo systemctl daemon-reload
#   echo "Служба ite-pusk.service удалена."

# }

check() {

  cd "$PUSK_DIR/bin";
  $JAVA_HOME/bin/java -cp ite-pusk.jar:../lib/* -Dloader.main=com.ite.utils.pusk.Application org.springframework.boot.loader.PropertiesLauncher --spring.config.import=optional:"$PUSK_DIR"/data/application.properties check

}

# База
case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  status)
    status
    ;;
  restart)
    stop
    start
    ;;
  # install)
  #   install
  #   ;;
  # uninstall)
  #   uninstall
  #   ;;
  check)
    check
    ;;
  *)
    echo "Использование: $0 {start|stop|restart|status|install|uninstall|check}"
    exit 1
esac

exit 0