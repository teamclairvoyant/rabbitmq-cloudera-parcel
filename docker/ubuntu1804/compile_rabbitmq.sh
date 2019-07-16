#!/bin/bash
# https://stackoverflow.com/questions/32407164/the-vm-is-running-with-native-name-encoding-of-latin1-which-may-cause-elixir-to
#locale
localedef -c -f UTF-8 -i C C.UTF-8
export LC_ALL=C.UTF-8
#export LC_ALL=C.UTF-8
#export LC_CTYPE=C.UTF-8
#export LANG=C.UTF-8
#locale

export PATH="${INSTALL_DIR}/${PARCEL_NAME}/bin:${PATH}"
export PREFIX="${INSTALL_DIR}/${PARCEL_NAME}"
#export REBAR=/usr/bin/rebar
#export ERL_LIBS=/usr/share/erlang/lib/
export ERL_LIBS=${INSTALL_DIR}/${PARCEL_NAME}/lib/erlang
export REBAR_DEPS_PREFER_LIBS=TRUE
export RPM_OPT_FLAGS="-O2 -g -m64 -mtune=generic"
#-pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches
export RPM_LD_FLAGS="-Wl,-z,relro"
export CFLAGS="$RPM_OPT_FLAGS -D_GNU_SOURCE -fPIC -fwrapv"
export CXXFLAGS="$RPM_OPT_FLAGS -D_GNU_SOURCE -fPIC -fwrapv"
export CPPFLAGS="$(pkg-config --cflags-only-I libffi)"
export OPT="$RPM_OPT_FLAGS -D_GNU_SOURCE -fPIC -fwrapv"
export LINKCC="gcc"
export LDFLAGS="$RPM_LD_FLAGS"
