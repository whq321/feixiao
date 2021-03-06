#!/bin/sh

### BEGIN INIT INFO
# Provides:	  nginx
# Required-Start:    $local_fs $remote_fs $network $syslog $named
# Required-Stop:     $local_fs $remote_fs $network $syslog $named
# Default-Start:     2 3 4 5
# Default-Stop:      0 1 6
# Short-Description: starts the nginx web server
# Description:       starts nginx using start-stop-daemon
### END INIT INFO

PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
DAEMON=/usr/sbin/nginx
NAME=nginx
DESC=nginx

# Include nginx defaults if available
if [ -f /etc/default/nginx ]; then
	. /etc/default/nginx
fi

test -x $DAEMON || exit 0

set -e

. /lib/lsb/init-functions

test_nginx_config() {
	if $DAEMON -t $DAEMON_OPTS >/dev/null 2>&1; then
		return 0
	else
		$DAEMON -t $DAEMON_OPTS
		return $?
	fi
}

start() {
		test_nginx_config
		# Check if the ULIMIT is set in /etc/default/nginx
		if [ -n "$ULIMIT" ]; then
			# Set the ulimits
			ulimit $ULIMIT
		fi
		log_daemon_msg "Starting $DESC" "$NAME"
		start-stop-daemon --start --quiet --pidfile /run/$NAME.pid \
			--retry 5 --exec $DAEMON -- $DAEMON_OPTS || true
		log_end_msg $?
}

stop() {
		log_daemon_msg "Stopping $DESC" "$NAME"
		start-stop-daemon --stop --quiet --pidfile /run/$NAME.pid \
			--retry 5 --exec $DAEMON || true
		log_end_msg $?
}

case "$1" in
	start)
		start
		;;

	stop)
		stop
		;;

	restart|force-reload)
		log_daemon_msg "Restarting $DESC"
		stop
		sleep 1
		start
		log_end_msg 0
		;;

	reload)
		log_daemon_msg "Reloading $DESC configuration..."
		test_nginx_config
		start-stop-daemon --stop --signal HUP --quiet --pidfile /run/$NAME.pid \
			--exec $DAEMON || true
		log_end_msg 0
		;;

	configtest|testconfig)
		log_daemon_msg "Testing $DESC configuration"
		if test_nginx_config; then
			log_daemon_msg "$NAME"
		else
			exit $?
		fi
		log_end_msg $?
		;;

	status)
		status_of_proc -p /run/$NAME.pid "$DAEMON" nginx && exit 0 || exit $?
		status=$?

		if [ $status -eq 0 ]; then
			log_success_msg "$DESC is running"
		else
			log_failure_msg "$DESC is not running"
		fi
		exit $status
		;;

	*)
		echo "Usage: $NAME {start|stop|restart|reload|force-reload|status|configtest}" >&2
		exit 1
		;;
esac

exit 0
