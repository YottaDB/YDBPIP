# PIP Installation guide
Installing PIP requires compiling various C applications, changing Linux kernel parameters, and setting up YottaDB. There will be some manual edits to certain files depending on the directory structures used for installation. This guide assumes that PIP is cloned into the installing user's home directory, if it is different for your installation - adjust paths as required.

## Manual installation

### Prerequisites
PIP requires the following software packages:

 * [YottaDB](https://github.com/YottaDB/YottaDB)
 * Linux C application build tools (aka build-essential). Examples of required applications:
   * gcc
   * ld
   * make

### Compile PIP C applications

 * Download the source code from github:
   * Type: `git clone https://github.com/YottaDB/pip.git`
 * Compile source code:
   * Type: `mkdir pip-build`
   * Type: `cd pip-build`
   * Type: `cmake ../pip`
   * Type: `make`

### Setting Kernel parameters
PIP uses kernel system calls to pass messages. The messages and queues are larger than most linux defaults:

 * msgmax = 1048700
 * msgmnb = 65536000
 * msgmni = 512

 To see what they are currently set to:
 * Type: `cat /proc/sys/kernel/msgmax`
 * Type: `cat /proc/sys/kernel/msgmnb`
 * Type: `cat /proc/sys/kernel/msgmni`

 To modify these values:
 Note: If the current values are larger than below omit the value
 * Type: `sudo vi /etc/sysctl.conf`
 * Go to the bottom of the file and add:
   ```
   kernel.msgmax = 1048700
   kernel.msgmnb = 65536000
   kernel.msgmni = 512
   ```
  * To activate the values:
    * Type: `sudo sysctl -p`

### YottaDB configuration

 * Create GDE file
   This is based on using the default templates for YottaDB and making targeted changes to support PIP.
   
   Note: We are manually set some environment variables just to create the global directory. The `dm` or `drv` script should normally be used to run PIP.
   
   Note: Set ydb_dist to the correct location for your environment

    * Type: `export ydb_chset=UTF-8`
    * Type: `export ydb_icu_version=55.1`
    * Type: `export ydb_gbldir=/home/pip/pip/gbls/pip.gld`
    * Type: `export ydb_dist=/opt/yottadb/current`
    * Type: `export ydb_routines=${ydb_dist}/utf8/libyottadbutil.so`
    * Type: `$ydb_dist/mumps -run ^GDE`
    * Type: `change -region DEFAULT -RECORD_SIZE=4080`
    * Type: `change -segment DEFAULT -alloc=4000 -exten=5000 -glob=2000 -FILE=/home/pip/pip/gbls/pip.dat`
    * Type: `exit`
    * Type: `$ydb_dist/mupip create`

 * Import PIP globals
   * Type: `export ydb_chset=UTF-8`
   * Type: `export ydb_icu_version=55.1`
   * Type: `export ydb_gbldir=/home/pip/pip/gbls/pip.gld`
   * Type: `export ydb_dist=/opt/yottadb/current`
   * Type: `export ydb_routines=${ydb_dist}/utf8/libyottadbutil.so`
   * Type: `$ydb_dist/mupip load /home/pip/pip/gbls/globals.zwr`

 * Fix C callout files
   The C callout files - `*.xc` - file has a reference to the shared library that needs to be executed that is system dependent. Modify the following files to have the correct full path to the shared library:
   * ~/pip/extcall_V1.2/extcall.xc
   * ~/pip/extcall_V1.2/alerts.xc
   * ~/pip/mtm_V2.4.5/mtm.xc
 * Enable journaling
   * Type: `$ydb_dist/mupip set -journal="enable,on,before" -file gbls/pip.dat`

### Starting PIP
Included in the installation are scripts used to start, stop, and recover the PIP environment. These scripts should be reviewed for applicability in your environment. This starts MTM and the PBS Server.

MTM by default is listening on TCP Port: `61012`
 * Type: `cd ~/pip`
 * Type: `./pipstart`

## Docker container
A Dockerfile is provided that automates the manual build instructions

### Prerequisites
PIP on Docker requires the following software packages:

 * [Docker](https://docs.docker.com/install/)

### Building the image

 * Type: `git clone https://github.com/YottaDB/pip.git`
 * Type: `cd pip`
 * Type: `docker build . -t pip:0.2`

### Running the image

 * Type: `docker run -d -P --sysctl kernel.msgmax=1048700 --sysctl kernel.msgmnb=65536000 -p61012:61012 --name=pip pip:0.2`

### Accessing PIP
SSH isn't installed on the container - the only access to the command prompt, direct mode and Data-Qwik are through the docker exec function.

#### Accessing the Linux command prompt

 * Type: `docker exec -it pip /bin/bash`

#### Accessing direct mode

 * Type: `docker exec -it pip /home/pip/pip/dm`

#### Accessing Data-Qwik

 * Type: `docker exec -it pip /home/pip/pip/drv`

## Using PIP
PIP provides a terminal based application for various management tasks and a listener for a JDBC connection using the provided JDBC jar.

### Starting Data-Qwik
There is a utility script designed for starting the Data-Qwik environment.
 * Type: `cd ~/pip`
 * Type: `./drv`

### Starting direct mode
To get to the direct mode prompt for advanced users.
 * Type: `cd ~/pip`
 * Type: `./dm`

### Using the JDBC connection
The JDBC connection connects to the MTM server to process SQL queries. It uses the included JDBC jar to connect to PIP and allow for SQL access to M data. ODBC access should be possible using a ODBC to JDBC bridge software.

Relevant information:
 * JDBC url scheme: protocol=jdbc:sanchez/database={PIP server IP/hostname}:{MTM Port}:SCA$IBS
 * userid: 1
 * password: XXX

Tips:
 * Do not pass a schema to PIP queries as it will fail.
 