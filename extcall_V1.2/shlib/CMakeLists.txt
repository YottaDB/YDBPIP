cmake_minimum_required(VERSION 3.5)

project(shlib)

set(SOURCES shlib.c)
add_library(shlib SHARED ${SOURCES})
