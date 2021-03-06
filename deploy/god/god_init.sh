#!/bin/bash

### BEGIN INIT INFO
# Provides: god
# Default-Start:  2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: start and stop god
# Description: monitoring by god.
### END INIT INFO

# source function library
#. /etc/rc.d/init.d/functions
RETVAL=0
prog="god"

set -e

DESC="god daemon"
NAME=god
DAEMON=/home/ubuntu/.rvm/bin/bootup_$NAME
CONFIGFILEDIR=/etc/god
PIDFILE=/var/run/$NAME.pid
LOGFILE=/var/log/god.log
SCRIPTNAME=/etc/init.d/$NAME

# Gracefully exit if the package has been removed.
test -x $DAEMON || exit 0

d_start() {
  $DAEMON -l $LOGFILE -P $PIDFILE || echo -en "\n already running"
  for file in `ls -1 $CONFIGFILEDIR/*.god`; do $DAEMON load $file; done
}

d_stop() {
  kill -QUIT `cat $PIDFILE` || echo -en "\n not running"
}

d_reload() {
  kill -HUP `cat $PIDFILE` || echo -en "\n can't reload"
}

case "$1" in
  start)
    echo -n "Starting $DESC: $NAME"
    d_start
        echo "."
  ;;
  stop)
    echo -n "Stopping $DESC: $NAME"
    d_stop
        echo "."
  ;;
  reload)
    echo -n "Reloading $DESC configuration..."
    d_reload
        echo "."
  ;;
  restart)
    echo -n "Restarting $DESC: $NAME"
    d_stop
    sleep 5
    d_start
    echo "."
  ;;
  *)
    echo "Usage: $SCRIPTNAME {start|stop|restart|reload}" >&2
    exit 3
  ;;
esac

exit 0