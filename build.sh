#!/usr/bin/env bash

set -e

echo "prepping clamav"
amazon-linux-extras install epel -y
yum install -y cpio yum-utils zip

# extract binaries for clamav, json-c, pcre
mkdir -p /tmp/build
pushd /tmp/build
yumdownloader -x \*i686 --archlist=x86_64 clamav clamav-lib clamav-update json-c pcre2 libxml2 bzip2-libs libtool-ltdl xz-libs
rpm2cpio clamav-0*.rpm | cpio -vimd
rpm2cpio clamav-lib*.rpm | cpio -vimd
rpm2cpio clamav-update*.rpm | cpio -vimd
rpm2cpio json-c*.rpm | cpio -vimd
rpm2cpio pcre*.rpm | cpio -vimd
rpm2cpio libxml2*.rpm | cpio -vimd
rpm2cpio bzip2-libs*.rpm | cpio -vimd
rpm2cpio libtool-ltdl*.rpm | cpio -vimd
rpm2cpio xz-libs*.rpm | cpio -vimd
# reset the timestamps so that we generate a reproducible zip file where
# running with the same file contents we get the exact same hash even if we
# run the same build on different days
find usr -exec touch -t 200001010000 "{}" \;
popd

mkdir -p build/bin
mkdir -p build/lib

cp /tmp/build/usr/bin/clamscan /tmp/build/usr/bin/freshclam build/bin/.
cp /tmp/build/usr/lib64/* build/lib/.
cp freshclam.conf clamd.conf build/bin/.

zip -r9 lambda_layer.zip build/bin
zip -r9 lambda_layer.zip build/lib
