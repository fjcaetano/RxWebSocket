#! /bin/sh

cd "${0%/*}"

if [[ $1 == 'start' ]]; then
  if [ ! -z "$(lsof -ti :9000)" ]; then
    echo '\n-> Server is already running. Try stopping it first'
    exit 0
  fi

  if [[ ! -f venv/bin/wstest ]]; then
    if [ -f venv/bin/activate ]; then
      echo '\n-> Activating virtual env'
      source venv/bin/activate
    else
      if [[ $(which virtualenv) ]]; then
        echo '-> Creating virtual env'
        virtualenv "$(pwd)/venv"
      else
        echo 'Virtual env not installed. Attempting to install anyway'
      fi
    fi

    echo '\n-> Installing requirements'
    pip install -r requirements.txt
  fi

  echo '\n-> Starting echoserver'

  LOGS=/tmp/wstest.log
  venv/bin/wstest -m echoserver -w ws://127.0.0.1:9000 > $LOGS 2>&1 &
  echo "$!" > .pid

  echo "Logs can be fount at $LOGS"

elif [[ $1 == 'stop' ]]; then
  if [ ! -f .pid ]; then
    echo '\n-> PID not found. Attempting stop anyway'
    PID=$(lsof -ti :9000)
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
