# PIP Installation guide

Installing PIP requires compiling various C applications, setting up YottaDB, and changing Linux kernel parameters. There will be some manual edits to certain files depending on the directory structures used for installation. This guide assumes that PIP is cloned into the installing user's home directory, if it is different for your installation - adjust paths as required.

## Prerequisites
PIP requires the following software packages:

 * [YottaDB](https://github.com/YottaDB/YottaDB)
 * Linux C application build tools (aka build-essential). Examples of required applications:
   * gcc
   * ld
   * make

## Compile PIP C applications

 * Download the source code from github:
   * Type: `git clone https://github.com/YottaDB/pip.git`
 * Compile Message Transfer Manager (MTM)
   * Type: `cd ~/pip/mtm_*`
   * Type: `make`
 * Compile External Call Utility (extcall)
   This is broken into multiple parts: shlib, alerts, and the main extcall library. The order below is required to be followed due to dependencies in the libraries.
   * Compile shlib
     * Type: `cd ~/pip/extcall_*/shlib`
     * Type: `make`
   * Compile alerts
     * Type: `cd ../alerts`
     * Type: `make`
   * Compile extcall
     * Type: `cd ../src`
     * Type: `make`
     * Type: `make -f version.mk`
 * Compile SQL library (libsql)
   * Type: `cd ~/pip/libsql_*`
   * Type: `make LINUX`
   * Type: `make version`
 * Compile M interrupt utility (mintrpt)
   * Type: `cd ~/pip/util`
   * Type: `make -f mintrpt.mk`

## YottaDB configuration

 * Create GDE file
   This is based on using the default templates for YottaDB and making targeted changes to support PIP:
    * Type: `cd ~/pip`
    * Type: `./dm`
    * Type: `D ^GDE`
    * `change -region DEFAULT -RECORD_SIZE=4080`
    * `change -segment DEFAULT -alloc=4000 -exten=5000 -glob=2000 -FILE=$HOME/Projects/yottadb/pip/gbls/mumps.dat`
    * Type: `exit`
    * Type: `H`

 * Import PIP globals
   * Type: ``

 * Fix C callout files
   The C callout files - `*.xc` - file has a reference to the shared library that needs to be executed that is system dependent. Modify the following files to have the correct full path to the shared library:
   * ~/pip/extcall_V1.2/extcall.xc
   * ~/pip/extcall_V1.2/alerts.xc
   * ~/pip/mtm_V2.4.5/mtm.xc

 * Enable journaling
   * Type: `/usr/local/lib/yottadb/r120/utf8/mupip set -journal="enable,on,before" -file gbls/mumps.dat`

## Setting Kernel parameters
PIP uses kernel system calls to pass messages. The messages and queues are larger than most linux defaults:

 * msgmax = 1048700
 * msgmnb = 65536000
 * msgmni = 512

 To see what they are currently set to:
 * Type: `cat /proc/sys/kernel/msgmax`
 * Type: `cat /proc/sys/kernel/msgmnb`
 * Type: `cat /proc/sys/kernel/msgmni`

 To modify these values:
 Note: if the current values are larger than below omit the value
 * Type: `sudo vi /etc/sysctl.conf`
 * Go to the bottom of the file and add:
   ```
   kernel.msgmax = 1048700
   kernel.msgmnb = 65536000
   kernel.msgmni = 512
   ```
  * To activate the values:
    * Type: `sudo sysctl -p`

## Starting PIP
Included in the installation are scripts used to start, stop, and recover the PIP environment. These scripts should be reviewed for applicability in your environment. This starts MTM and the PBS Server.

MTM by default is listening on TCP Port: `61012`
 * Type: `cd ~/pip`
 * Type: `./pipstart`

## Using PIP
PIP provides a terminal based application for various management tasks and a listener for a JDBC connection using the provided JDBC jar.

### Starting Data-Qwik
There is a utility script designed for starting the Data-Qwik environment.
 * Type: `cd ~/pip`
 * Type: `./drv`

### Using the JDBC connection
The JDBC connection connects to the MTM server to process SQL queries. It uses the included JDBC jar to connect to PIP and allow for SQL access to M data. ODBC access should be possible using a ODBC to JDBC bridge software.

Relevant information:
 * JDBC url scheme: protocol=jdbc:sanchez/database={PIP server IP/hostname}:{MTM Port}:SCA$IBS
 * userid: 1
 * password: xxx

Tips:
 * Do not pass a schema to PIP queries as it will fail.
 