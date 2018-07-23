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

project(extcall)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fpic -std=c89")
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")

add_subdirectory(alerts)
add_subdirectory(shlib)

set(SOURCES src/asc2ebc.c
	    src/atmutils.c
	    src/devutils.c
	    src/ebc2asc.c
	    src/elfhash.c
	    src/expsca.c
	    src/lnx.c
	    src/logsca.c
	    src/md5c.c
	    src/pidutils.c
	    src/readport.c
	    src/remote.c
	    src/rtb.c
	    src/rtbar.c
	    src/scamd5.c
	    src/string.c
	    src/sysutils.c
	    src/unpack.c
	    src/unpack2.c
	    src/utils.c
	    src/xor.c)
add_library(extcall SHARED ${SOURCES})
include_directories(extcall ${CMAKE_CURRENT_SOURCE_DIR}/src)
target_link_libraries(extcall shlib)
install(TARGETS extcall DESTINATION lib)

add_executable(extcallversion src/version.c)
include_directories(extcallversion ${CMAKE_CURRENT_SOURCE_DIR}/src)
target_link_libraries(extcallversion extcall)
target_link_libraries(extcallversion m)
install(TARGETS extcallversion DESTINATION bin)
