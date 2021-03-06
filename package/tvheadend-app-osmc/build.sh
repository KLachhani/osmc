# (c) 2014-2015 Sam Nazarko
# email@samnazarko.co.uk

#!/bin/bash

. ../common.sh

pull_source "https://github.com/tvheadend/tvheadend/archive/v3.9.tar.gz" "$(pwd)/src"
if [ $? != 0 ]; then echo -e "Error downloading" && exit 1; fi
# Build in native environment
build_in_env "${1}" $(pwd) "tvheadend-app-osmc"
if [ $? == 0 ]
then
	echo -e "Building TVHeadend"
	out=$(pwd)/files
	sed '/Package/d' -i files/DEBIAN/control
	rm -f files/etc/osmc/apps.d/*tvheadend-app-osmc
	update_sources
	handle_dep "pkg-config"
	handle_dep "libssl-dev"
	handle_dep "git" # for dvbscan info?
	test $1 == gen && echo "Package: tvheadend-app-osmc" >> files/DEBIAN/control && APP_FILE="files/etc/osmc/apps.d/tvheadend-app-osmc"
	test $1 == rbp && echo "Package: rbp-tvheadend-app-osmc" >> files/DEBIAN/control && APP_FILE="files/etc/osmc/apps.d/rbp-tvheadend-app-osmc"
	test $1 == armv7 && echo "Package: armv7-tvheadend-app-osmc" >> files/DEBIAN/control && APP_FILE="files/etc/osmc/apps.d/armv7-tvheadend-app-osmc"
        echo -e "TVHeadend Server\n/lib/systemd/system/tvheadend.service" > $APP_FILE
	pushd src/tvheadend*
	./configure --prefix=/usr
	sed -e "s/-Werror//" -i Makefile
	$BUILD
	make install DESTDIR=${out}
	if [ $? != 0 ]; then echo "Error occured during build" && exit 1; fi
	strip_files "${out}"
	popd
	fix_arch_ctl "files/DEBIAN/control"
	dpkg -b files/ tvheadend-app-osmc.deb
fi
teardown_env "${1}"
