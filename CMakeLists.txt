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

project(pip)

# PSL/M code
add_subdirectory(crtns)
add_subdirectory(mrtns)
add_subdirectory(prtns)
add_subdirectory(srtns)
add_subdirectory(zrtns)
add_subdirectory(gbls)

# Add compiled projects
add_subdirectory(extcall_V1.2)
add_subdirectory(libsql_V3.2)
add_subdirectory(mtm_V2.4.5)
add_subdirectory(util)
add_subdirectory(jdbc)

install(FILES
	     gtmenv
	     gtmenv1
	     UCOPTS.ini
	     UCOPTS_2_7DEV.ini
	     UCOPTS_3DEV.ini
	DESTINATION .)

install(PROGRAMS
		 dm
		 drv
	         piprecover
	         pipstart
	         pipstart-docker
	         pipstop
	DESTINATION .)
