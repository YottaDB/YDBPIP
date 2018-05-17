#!/bin/bash

# Install required tools
#apt-get install git build-essential

# Clone repo
#cd ~
#git clone https://github.com/YottaDB/pip.git

# Build Message Transfer Manager
cd ~/pip/mtm_*
make

# Build External Call Utility
cd ~/pip/extcall_*/shlib
make
cd ../alerts
make
cd ../src
make
make -f version.mk

# Build SQL Library
cd ~/pip/libsql_*/src
make LINUX
make version

# Compile M interrupt
cd ~/pip/util
make -f mintrpt.mk

# Create database
cd ~/pip
export gtm_chset=UTF-8
export gtm_icu_version=55.1
export gtmgbldir=/home/pip/pip/gbls/pip.gld
export gtm_dist=/opt/yottadb/current
export gtmroutines=${gtm_dist}/utf8/libyottadbutil.so
$gtm_dist/mumps -run ^GDE < gbls/db.gde
$gtm_dist/mupip create
$gtm_dist/mupip set -journal="enable,on,before" -file gbls/pip.dat

# Import globals
cd ~/pip
$gtm_dist/mupip load gbls/globals.zwr
