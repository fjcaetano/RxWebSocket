#! /bin/sh

cd "${0%/*}"

set -o pipefail

LOGS_PATH="/tmp/RxWebSocket_Install"
mkdir $LOGS_PATH > /dev/null 2>&1
mkdir build > /dev/null 2>&1

verify() {
  if [ ! $(which $0) ]; then
    echo 'ERROR: $0 still not installed. Aborting'
    exit 1
  fi
}

# Fastlane
install_fastlane() {
  echo "Installing Fastlane"

  if [ $(which fastlane) ]; then
    echo ' -> Fastlane already installed'
    return
  fi

  # Installing Homebrew
  if [ ! $(which brew) ]; then
    echo "Installing Homebrew"

    # https://brew.sh/
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)" > "$LOGS_PATH/fastlane.log"
  fi

  brew cask install fastlane

  verify "fastlane"
}

# Autobahn Test Suite
install_wstest() {
  echo 'Installing wstest'

  if [[ -f venv/bin/wstest ]] || [ $(which wstest) ]; then
    echo ' -> wstest already installed'
    return
  fi

  if [ ! -f venv/bin/activate ]; then
    if [[ $(which virtualenv) ]]; then
      echo 'Creating virtual env'
      virtualenv "$(pwd)/venv" > "$LOGS_PATH/venv.log" 2>&1
    else
      echo ' -> Virtual env not installed. Attempting to install anyway'
    fi
  fi

  source venv/bin/activate

  if [[ ! $(which pip) ]]; then
    echo 'Installing pip'
    easy_install --user pip > "$LOGS_PATH/pip.log" && export PATH=/Users/travis/Library/Python/2.7/bin:${PATH}
  fi

  echo 'Installing wstest'
  pip install -r requirements.txt > "$LOGS_PATH/requirements.log"

  verify "wstest"
}

# Swiftlint
install_swiftlint() {
  echo 'Installing swiftlint'

  if [ $(which swiftlint) ]; then
    echo ' -> Swiftlint already installed'
    return
  fi

  brew install swiftlint > "$LOGS_PATH/swiftlint.log"

  verify "swiftlint"
}

xcode_error() {
  if [[ ! -z $XCODE_VERSION_MAJOR ]]; then
    echo "$(pwd)/Classes/RxWebSocket.swift:$1: "
  else
    echo ""
  fi
}

if [[ $1 == 'verify' ]]; then
  if [ ! -f build/.deps ]; then
    echo `xcode_error 1` "error: Dependencies not installed"
    echo `xcode_error 2` "error: Run \`$(pwd)/install_dependencies.sh\` to install all required dependencies"
    exit 2
  fi

  exit 0
fi

install_fastlane
install_wstest
install_swiftlint
echo 'Success! All requirements are installed'
echo "Logs can be found at $LOGS_PATH"

touch build/.deps
