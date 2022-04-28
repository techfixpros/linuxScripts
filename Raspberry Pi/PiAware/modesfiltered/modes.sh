#!/bin/bash
### BEGIN INIT INFO
# Provides:				modes
# Required-Start:		$local_fs
# Required-Stop:		$local_fs
# Default-Start:		2 3 4 5
# Default-Stop:			0 1 6
# Short-Description:	modes initscript
### END INIT INFO


PROG="modesfiltered.jar"
PROG_PATH="/home/pi/modesfiltered"
PIDFILE="/var/run/modes.pid"
LOGFILE="/var/log/modes.log"

start() {

      if pidof dump1090-fa; then
        echo "Checked dump1090 is running."
      else
        sleep 20
        # check one more time
        if pidof dump1090-fa; then
          echo "Checked dump1090 is running."
        else
          # message only
          echo "No running dump1090 found."
        fi
      fi 

      if [ -e $PIDFILE ]; then
          ## Program is running, exit with error.
          echo "Error! $PROG is already running!" 1>&2
          exit 1
      else
          ## Change from /dev/null to something like /var/log/$PROG if you want to save output.
          cd $PROG_PATH
          touch $LOGFILE
          java -jar $PROG > $LOGFILE 2>$LOGFILE &
          echo "$PROG started"
          touch $PIDFILE
      fi
}

stop() {
      if [ -e $PIDFILE ]; then
          ## Program is running, so stop it
         echo "$PROG is running, PIDFILE exists"
         killall java
         rm -f $PIDFILE
         echo "$PROG stopped, PIDFILE deleted"
      else
          ## Program is not running, exit with error.
          echo "Error! $PROG not started! No PIDFILE found." 1>&2
          exit 1
      fi
}

## Check to see if we are running as root first.
## Found at http://www.cyberciti.biz/tips/shell-root-user-check-script.html
if [ "$(id -u)" != "0" ]; then
      echo "This script must be run as root" 1>&2
      exit 1
fi

case "$1" in
      start)
          start
          exit 0
      ;;
      stop)
          stop
          exit 0
      ;;
      reload|restart|force-reload)
          stop
          start
          exit 0
      ;;
      **)
          echo "Usage: $0 {start|stop|reload}" 1>&2
          exit 1
      ;;
esac
exit 0
