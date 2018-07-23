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

project(libsql)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fpic -std=c89")
set(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
add_definitions(-D_GNU_SOURCE)

set(SOURCES src/client.c
	    src/libsql.c
	    src/scafmtcol.c
	    src/util.c
	    src/utils.c)
add_library(libsql SHARED ${SOURCES})
include_directories(libsql ${CMAKE_CURRENT_SOURCE_DIR}/src)
install(TARGETS libsql DESTINATION lib)

add_executable(libsqlversion src/version.c)
include_directories(libsqlversion ${CMAKE_CURRENT_SOURCE_DIR}/src)
target_link_libraries(libsqlversion libsql)
install(TARGETS libsqlversion DESTINATION bin)

add_executable(libsqlexample src/example.c)
include_directories(libsqlexample ${CMAKE_CURRENT_SOURCE_DIR}/src)
target_link_libraries(libsqlexample libsql)
install(TARGETS libsqlexample DESTINATION bin)
