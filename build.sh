#!/bin/bash

#################################################################
#								#
# Copyright (c) 2017-2018 YottaDB LLC. and/or its subsidiaries.	#
# All rights reserved.						#
#								#
#	This source code contains the intellectual property	#
#	of its copyright holder(s), and is made available	#
#	under a license.  If you do not know the terms of	#
#	the license, please stop and do not read further.	#
#								#
#################################################################

# Install required tools
#apt-get install git build-essential

# Clone repo
#cd ~
#git clone https://github.com/YottaDB/pip.git

# Compile and Install PIP code
mkdir -p ~/Projects/pip-build
cd ~/Projects/pip-build
cmake -D CMAKE_INSTALL_PREFIX=~/pip ~/Projects/pip && make && make install

# Create database
cd ~
export gtm_chset=UTF-8
export gtm_icu_version=55.1
export gtmgbldir=~/pip/gbls/pip.gld
export gtm_dist=/opt/yottadb/current
export gtmroutines=${gtm_dist}/utf8/libyottadbutil.so
$gtm_dist/mumps -run ^GDE < ~/pip/gbls/db.gde
$gtm_dist/mupip create
$gtm_dist/mupip set -journal="enable,on,before" -file ~/pip/gbls/pip.dat

# Import globals
$gtm_dist/mupip load ~/pip/gbls/globals.zwr
