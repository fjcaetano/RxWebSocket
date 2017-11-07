#! /bin/sh

cd "${0%/*}"
PORT=9000

if [[ $1 == 'start' ]]; then
  if [ ! -z "$(lsof -ti :9000)" ]; then
    echo '\n-> Server is already running. Try stopping it first'
    exit 0
  fi

  echo '\n-> Starting echoserver'

  LOGS=/tmp/wstest.log
  venv/bin/wstest -m echoserver -w ws://127.0.0.1:$PORT > $LOGS 2>&1 &
  echo "$!" > .pid

  echo "Logs can be fount at $LOGS"

elif [[ $1 == 'stop' ]]; then
  if [ ! -f .pid ]; then
    echo '\n-> PID not found. Attempting stop anyway'
    PID=$(lsof -ti :$PORT)
  else
    PID=$(cat .PID)
    rm .pid
  fi

  if [ -z $PID ]; then
    echo '\n-> Server not running'
    exit 1
  fi

  echo "\n-> Stopping echoserver [$PID]"
  kill -9 $PID
else
  echo 'Usage: server [start|stop]'
fi
