#!/bin/sh
# compile and build mtmtest on Linux platform
cc -g -c -I../../include mtmtest.c
cc -g -c -I../../include hexdmp.c
cc -g -c -I../../libsql_V3.2/src -I../../include client.c
cc -g -c -I../../libsql_V3.2/src -I../../include ../../libsql_V3.2/src/utils.c
cc -g -o mtmtest mtmtest.o hexdmp.o client.o utils.o -L../../libsql_V3.2 -lsql 
