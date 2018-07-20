cmake_minimum_required(VERSION 3.5)

project(extcall)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fpic -std=c89")

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

add_executable(extcallversion src/version.c)
include_directories(extcallversion ${CMAKE_CURRENT_SOURCE_DIR}/src)
target_link_libraries(extcallversion extcall)
target_link_libraries(extcallversion m)
