cmake_minimum_required(VERSION 3.5)

project(alerts)

set(SOURCES alerts.c)
add_library(alerts SHARED ${SOURCES})
target_link_libraries(alerts shlib)
include_directories(alerts ${CMAKE_CURRENT_SOURCE_DIR})

add_executable(alertsversion version.c)
target_link_libraries(alertsversion alerts)
