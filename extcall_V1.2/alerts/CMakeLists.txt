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

project(alerts)

set(SOURCES alerts.c)
add_library(alerts SHARED ${SOURCES})
target_link_libraries(alerts shlib)
include_directories(alerts ${CMAKE_CURRENT_SOURCE_DIR})
install(TARGETS alerts DESTINATION lib)

add_executable(alertsversion version.c)
target_link_libraries(alertsversion alerts)
install(TARGETS alertsversion DESTINATION bin)

configure_file(alerts.xc.in alerts.xc)
install(FILES ${CMAKE_BINARY_DIR}/extcall_V1.2/alerts/alerts.xc DESTINATION lib)

install(PROGRAMS sca_alert.sh DESTINATION bin)
