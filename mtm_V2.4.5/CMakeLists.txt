cmake_minimum_required(VERSION 3.5)

project(mtm)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fpic -std=c89")
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
