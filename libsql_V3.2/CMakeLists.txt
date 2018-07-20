cmake_minimum_required(VERSION 3.5)

project(libsql)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -fpic -std=c89")
add_definitions(-D_GNU_SOURCE)

set(SOURCES src/client.c
	    src/libsql.c
	    src/scafmtcol.c
	    src/util.c
	    src/utils.c)
add_library(libsql SHARED ${SOURCES})
include_directories(libsql ${CMAKE_CURRENT_SOURCE_DIR}/src)

add_executable(libsqlversion src/version.c)
include_directories(libsqlversion ${CMAKE_CURRENT_SOURCE_DIR}/src)
target_link_libraries(libsqlversion libsql)

add_executable(libsqlexample src/example.c)
include_directories(libsqlexample ${CMAKE_CURRENT_SOURCE_DIR}/src)
target_link_libraries(libsqlexample libsql)
