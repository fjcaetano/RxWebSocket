#! /bin/sh

cd "${0%/*}"

set -o pipefail

mkdir build > /dev/null 2>&1

exe() { echo "\$ ${@/eval/}" ; "$@" ; }

verify() {
  if [ ! $(which $1) ]; then
    echo 'ERROR: $1 still not installed. Aborting'
    exit 1
  fi
}

# Bundle
install_bundle() {
  echo 'Installing bundle'

  # Bundle install
  if [ ! $(which bundle) ]; then
    exe gem install bundler
  fi

  exe bundle install

  if [ ! $(bundle check) ]; then
    echo "ERROR: bundle still not installed. Aborting"
    exit 1
  fi
}

# Websocket server
install_websocket() {
  echo 'Installing Websocket server'

  if [[ -f venv/bin/wstest ]] || [ $(which wstest) ]; then
    echo ' -> wstest already installed'
    return
  fi

  if [ ! -f venv/bin/activate ]; then
    if [[ $(which virtualenv) ]]; then
      echo 'Creating virtual env'
      exe virtualenv -p python3 "$(pwd)/venv"
    else
      echo ' -> virtualenv not installed.'
    fi
  fi

  if [ -f venv/bin/activate ]; then
    exe source venv/bin/activate
  else
    echo ' -> Virtual env not found. Attempting to install anyway'
  fi

  if [[ ! $(which pip3) ]]; then
    echo 'Installing pip'
    exe easy_install --user pip && export PATH=/Users/travis/Library/Python/2.7/bin:${PATH}
  fi

  echo 'Installing wstest'
  exe pip3 install -r requirements.txt
}

# Homebrew
install_homebrew() {
  if [ ! $(which homebrew) ]; then
    /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
  fi
}

# Swiftlint
install_swiftlint() {
  echo 'Installing swiftlint'

  if [ $(which swiftlint) ]; then
    echo ' -> Swiftlint already installed'
    return
  fi

  install_homebrew
  exe brew install swiftlint

  verify "swiftlint"
}

# Carthage
install_carthage() {
  echo 'Installing Carthage'

  if [ $(which carthage) ]; then
    echo ' -> Carthage already installed'
    return
  fi

  install_homebrew
  exe brew install carthage
}

xcode_error() {
  if [[ ! -z "$XCODE_VERSION_MAJOR" ]]; then
    echo "$(pwd)/Classes/RxWebSocket.swift:$1: "
  else
    echo ""
  fi
}

if [[ "$1" == 'verify' ]]; then
  if [ ! -f build/.deps ] && [ "$CARTHAGE" != "YES" ]; then
    echo `xcode_error 1` "error: Dependencies not installed"
    echo `xcode_error 2` "error: Run \`$(pwd)/install_dependencies.sh\` to install all required dependencies"
    exit 2
  fi

  exit 0
fi

install_bundle
install_websocket
install_swiftlint
install_carthage
echo 'Success! All requirements are installed'

touch build/.deps
