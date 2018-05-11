#!/bin/sh

./extcall_rm.sh

make

make -f version.mk

./extcall_tar.sh
