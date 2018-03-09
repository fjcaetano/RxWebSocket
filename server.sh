#! /bin/sh

cd "${0%/*}"
PORT=9000
pid_file=".pid"

open_port_pid() {
  lsof -ti :$PORT
}

is_running() {
    [ -f "$pid_file" ] || [ ! -z $(open_port_pid) ]
}

case "$1" in
    start)
      if is_running; then
        echo '\n-> Server is already running. Try stopping it first'
        exit 0
      fi

      echo '\n-> Starting echoserver'

      LOGS=/tmp/wstest.log
      venv/bin/wstest -m echoserver -w ws://127.0.0.1:$PORT > $LOGS 2>&1 &
      echo "$!" > $pid_file

      echo "Logs can be fount at $LOGS"
    ;;
    stop)
      if [ ! -f $pid_file ]; then
        echo '\n-> PID not found. Attempting stop anyway'
        PID=$(open_port_pid)
      else
        PID=$(cat $pid_file)
      fi

      if ! is_running; then
        echo '\n-> Server not running'
        exit 1
      fi

      echo "\n-> Stopping echoserver [$PID]"
      kill -9 $PID
      rm $pid_file > /dev/null
    ;;
    restart)
      $0 stop
      if is_running; then
          echo "Unable to stop, will not attempt to start"
          exit 1
      fi
      $0 start
    ;;
    status)
      if is_running; then
          echo "Running"
      else
          echo "Stopped"
          exit 1
      fi
    ;;
    *)
    echo "Usage: $0 {start|stop|restart|status}"
    exit 1
    ;;
esac

exit 0
