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

project(mtm)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fpic -std=c89")
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
add_definitions(-D_GNU_SOURCE)

set(APISOURCES client.c
	       server.c
	       mtm.c
	       utils.c
	       sca_wrapper.c
	       socket_utils.c
	       alarm_utils.c
	       msg_utils.c)
add_library(mtmapi SHARED ${APISOURCES})
include_directories(mtmapi ${CMAKE_CURRENT_SOURCE_DIR})
target_link_libraries(mtmapi m)
install(TARGETS mtmapi DESTINATION lib)

set(MTMSOURCES mtmcntrl.c
	       mtmclnt.c
	       mtmmain.c
	       mtmserver.c
	       mtmcomm.c
	       mtmutils.c
	       utils.c
	       sca_wrapper.c
	       socket_utils.c
	       alarm_utils.c
	       msg_utils.c)
add_executable(mtm ${MTMSOURCES})
target_link_libraries(mtm m)
install(TARGETS mtm DESTINATION bin)
