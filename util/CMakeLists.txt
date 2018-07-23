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

cmake_minimum_required(VERSION 2.8)

project(util)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fpic -std=c89")

set(SOURCES mintrpt.c)
add_executable(mintrpt ${SOURCES})
install(TARGETS mintrpt DESTINATION bin)

install(DIRECTORY . DESTINATION util
	PATTERN "CMakeLists.txt" EXCLUDE
	PATTERN ".git*" EXCLUDE
	PATTERN "*.c" EXCLUDE)