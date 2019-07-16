#!/bin/bash
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# Copyright Clairvoyant 2019
#
if [ -n "$DEBUG" ]; then set -x; fi
#
##### START CONFIG ###################################################

##### STOP CONFIG ####################################################
PATH=/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin

# Function to print the help screen.
print_help() {
  echo "Usage:  $1 --rabbitmq <version> --erlang <version> --parcel <version>"
  echo "        $1 [-h|--help]"
  echo "        $1 [-v|--version]"
  echo ""
  echo "   ex.  $1 --rabbitmq 3.7.15 --erlang 22.0 --parcel b0"
  exit 1
}

# Function to check for root priviledges.
check_root() {
  if [[ $(/usr/bin/id | awk -F= '{print $2}' | awk -F"(" '{print $1}' 2>/dev/null) -ne 0 ]]; then
    echo "You must have root priviledges to run this program."
    exit 2
  fi
}

## If the variable DEBUG is set, then turn on tracing.
## http://www.research.att.com/lists/ast-users/2003/05/msg00009.html
#if [ $DEBUG ]; then
#  # This will turn on the ksh xtrace option for mainline code
#  set -x
#
#  # This will turn on the ksh xtrace option for all functions
#  typeset +f |
#  while read F junk
#  do
#    typeset -ft $F
#  done
#  unset F junk
#fi

# Process arguments.
while [[ $1 = -* ]]; do
  case $1 in
    -a|--rabbitmq)
      shift
      RABBITMQ_VERSION=$1
      ;;
    -p|--erlang)
      shift
      ERLANG_VERSION=$1
      ELIXIR_VERSION=1.8.2
      ;;
    -P|--parcel)
      shift
      PARCEL_VERSION=$1
      ;;
    -h|--help)
      print_help "$(basename "$0")"
      ;;
    -v|--version)
      echo "Builds a parcel of RabbitMQ for Cloudera Manager."
      exit 0
      ;;
    *)
      print_help "$(basename "$0")"
      ;;
  esac
  shift
done

# Check to see if we have the required parameters.
if [ -z "$RABBITMQ_VERSION" ] || [ -z "$ERLANG_VERSION" ] || [ -z "$PARCEL_VERSION" ]; then print_help "$(basename "$0")"; fi

# Lets not bother continuing unless we have the privs to do something.
#check_root

# main
set -euo pipefail
echo "*** Downloading Erlang/OTP ${ERLANG_VERSION} sourcecode ..."
echo "*** Downloading Elixir ${ELIXIR_VERSION} sourcecode ..."
echo "*** Downloading RabbitMQ ${RABBITMQ_VERSION} sourcecode ..."
if command -v wget; then
  #wget -c "https://github.com/erlang/otp/archive/OTP-${ERLANG_VERSION}.tar.gz"
  wget -c "http://erlang.org/download/otp_src_${ERLANG_VERSION}.tar.gz"
  wget -c "https://raw.githubusercontent.com/rabbitmq/erlang-rpm/master/versions/${ERLANG_VERSION}/otp-0001-Do-not-format-man-pages-and-do-not-install-miscellan.patch"
  wget -c "https://raw.githubusercontent.com/rabbitmq/erlang-rpm/master/versions/${ERLANG_VERSION}/otp-0002-Remove-rpath.patch"
  wget -c "https://raw.githubusercontent.com/rabbitmq/erlang-rpm/master/versions/${ERLANG_VERSION}/otp-0003-Do-not-install-C-sources.patch"
  wget -c "https://raw.githubusercontent.com/rabbitmq/erlang-rpm/master/versions/${ERLANG_VERSION}/otp-0007-Do-not-install-erlang-sources.patch"
  wget -c "https://github.com/elixir-lang/elixir/archive/v${ELIXIR_VERSION}.tar.gz"
  wget -c "https://github.com/rabbitmq/rabbitmq-server/releases/download/v${RABBITMQ_VERSION}/rabbitmq-server-${RABBITMQ_VERSION}.tar.xz"
elif command -v curl; then
  #curl -LOR "https://github.com/erlang/otp/archive/OTP-${ERLANG_VERSION}.tar.gz"
  curl -LOR "http://erlang.org/download/otp_src_${ERLANG_VERSION}.tar.gz"
  curl -LOR "https://raw.githubusercontent.com/rabbitmq/erlang-rpm/master/versions/${ERLANG_VERSION}/otp-0001-Do-not-format-man-pages-and-do-not-install-miscellan.patch"
  curl -LOR "https://raw.githubusercontent.com/rabbitmq/erlang-rpm/master/versions/${ERLANG_VERSION}/otp-0002-Remove-rpath.patch"
  curl -LOR "https://raw.githubusercontent.com/rabbitmq/erlang-rpm/master/versions/${ERLANG_VERSION}/otp-0003-Do-not-install-C-sources.patch"
  curl -LOR "https://raw.githubusercontent.com/rabbitmq/erlang-rpm/master/versions/${ERLANG_VERSION}/otp-0007-Do-not-install-erlang-sources.patch"
  curl -LOR "https://github.com/elixir-lang/elixir/archive/v${ELIXIR_VERSION}.tar.gz"
  curl -LOR "https://github.com/rabbitmq/rabbitmq-server/releases/download/v${RABBITMQ_VERSION}/rabbitmq-server-${RABBITMQ_VERSION}.tar.xz"
else
  echo "ERROR: Missing wget or curl."
  exit 10
fi
if [ ! -d target ]; then mkdir target; fi

for DIST in centos6 centos7 debian8 ubuntu1404 ubuntu1604 ubuntu1804; do
  case $DIST in
    centos6)    PARCEL_DIST=el6    ;;
    centos7)    PARCEL_DIST=el7    ;;
    debian8)    PARCEL_DIST=jessie ;;
    ubuntu1404) PARCEL_DIST=trusty ;;
    ubuntu1604) PARCEL_DIST=xenial ;;
    ubuntu1804) PARCEL_DIST=bionic ;;
  esac
  PARCEL_NAME=RABBITMQ-${RABBITMQ_VERSION}-erlang${ERLANG_VERSION}_${PARCEL_VERSION}

  echo "*** Building RabbitMQ ${RABBITMQ_VERSION} parcel for ${DIST} ..."
  docker build -f docker/${DIST}/Dockerfile -t "rabbitmq/${DIST}:${RABBITMQ_VERSION}-erlang${ERLANG_VERSION}_${PARCEL_VERSION}" \
    --build-arg RABBITMQ_VERSION="$RABBITMQ_VERSION" \
    --build-arg ERLANG_VERSION="$ERLANG_VERSION" \
    --build-arg ELIXIR_VERSION="$ELIXIR_VERSION" \
    --build-arg PARCEL_VERSION="$PARCEL_VERSION" .

  echo "*** Extracting RabbitMQ parcel ${PARCEL_VERSION} for ${DIST} ..."
  docker run -d --name rabbitmq-${DIST} "rabbitmq/${DIST}:${RABBITMQ_VERSION}-erlang${ERLANG_VERSION}_${PARCEL_VERSION}"
  docker cp "rabbitmq-${DIST}:/BUILD/${PARCEL_NAME}-${PARCEL_DIST}.parcel" target/
  docker cp "rabbitmq-${DIST}:/BUILD/${PARCEL_NAME}-${PARCEL_DIST}.parcel.sha" target/
  docker rm rabbitmq-${DIST}
done

echo "*** Creating manifest.json in target/ directory ..."
./make_manifest.py target/

