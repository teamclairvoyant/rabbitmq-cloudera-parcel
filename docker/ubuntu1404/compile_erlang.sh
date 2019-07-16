#!/bin/bash
# https://github.com/rabbitmq/erlang-rpm/blob/master/erlang.spec
export RPM_OPT_FLAGS="-O2 -g -m64 -mtune=generic"
#-pipe -Wall -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector-strong --param=ssp-buffer-size=4 -grecord-gcc-switches
export RPM_LD_FLAGS="-Wl,-z,relro"
export CFLAGS="$RPM_OPT_FLAGS -D_GNU_SOURCE -fPIC -fwrapv -fno-strict-aliasing"
export CXXFLAGS="$RPM_OPT_FLAGS -D_GNU_SOURCE -fPIC -fwrapv"
export CPPFLAGS="$(pkg-config --cflags-only-I libffi)"
export OPT="$RPM_OPT_FLAGS -D_GNU_SOURCE -fPIC -fwrapv"
export LINKCC="gcc"
export LDFLAGS="$RPM_LD_FLAGS"
if pkg-config openssl ; then
  export CFLAGS="$CFLAGS $(pkg-config --cflags openssl)"
  export LDFLAGS="$LDFLAGS $(pkg-config --libs-only-L openssl)"
fi

patch -p1 </BUILD/otp-0001-Do-not-format-man-pages-and-do-not-install-miscellan.patch
patch -p1 </BUILD/otp-0002-Remove-rpath.patch
patch -p1 </BUILD/otp-0003-Do-not-install-C-sources.patch
patch -p1 -F2 </BUILD/otp-0007-Do-not-install-erlang-sources.patch

# Fix 664 file mode
chmod 644 lib/kernel/examples/uds_dist/c_src/Makefile
chmod 644 lib/kernel/examples/uds_dist/src/Makefile
chmod 644 lib/ssl/examples/certs/Makefile
chmod 644 lib/ssl/examples/src/Makefile

touch lib/common_test/SKIP
touch lib/debugger/SKIP
touch lib/dialyzer/SKIP
touch lib/diameter/SKIP
touch lib/edoc/SKIP
touch lib/et/SKIP
touch lib/erl_docgen/SKIP
touch lib/ftp/SKIP
touch lib/jinterface/SKIP
touch lib/megaco/SKIP
touch lib/observer/SKIP
touch lib/odbc/SKIP
touch lib/ssh/SKIP
touch lib/tftp/SKIP
touch lib/wx/SKIP

