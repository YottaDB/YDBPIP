# VistA and PIP
This document describes how to make VistA and PIP coexist together.

## Docker Container
There is a pre-configured docker container that has all of the modifications below already done. The following command will pull the image and start it:

`docker run -d -p 2222:22 -p 8001:8001 -p 9430:9430 -p 8080:8080 -p 61012:61012 --sysctl kernel.msgmax=1048700 --sysctl kernel.msgmnb=65536000 --name=vehu-pip cje1985/vehu-pip`

## Manual Instructions
This will walk a user through manually configuring a VistA instance (based on https://github.com/OSEHRA/docker-vista configuration).

Note: If you are using docker to install vista the run command arguments need to include:
`--sysctl kernel.msgmax=1048700 --sysctl kernel.msgmnb=65536000`

### Build VistA Docker Container
This uses the VEHU instance as it contains sample data.

Type: `git clone https://github.com/OSEHRA/docker-vista.git`
Type: `cd docker-vista`
Type: `docker build --build-arg flags="-y -b -s -m -a https://github.com/OSEHRA-Sandbox/VistA-VEHU-M/archive/master.zip" --build-arg instance="vehu" --build-arg postInstallScript="-p ./Common/removeVistaSource.sh" -t vehu .`
Type: `docker run -d -p 2222:22 -p 8001:8001 -p 9430:9430 -p 8080:8080 -p 61012:61012 --sysctl kernel.msgmax=1048700 --sysctl kernel.msgmnb=65536000 --name=vehu vehu`

### SSH to the Container
Type: `ssh -p2222 root@localhost`
Password: `docker`

### Change to the Instance User
Type: `su - vehu`

### Clone the Repository
Type: `cd ~`
Type: `git clone https://github.com/YottaDB/pip.git`

### Build PIP
The following is in a single text block as it can be copy/pasted into the terminal as-is

```
# Build Message Transfer Manager
cd ~/pip/mtm_*
make

# Build External Call Utility
cd ~/pip/extcall_*/shlib
make
cd ../alerts
make
cd ../src
make
make -f version.mk

# Build SQL Library
cd ~/pip/libsql_*/src
make LINUX
make version

# Compile M interrupt
cd ~/pip/util
make -f mintrpt.mk
```

### Add New Region/Segment for Mapping PIP Data Away from VistA
Note: I did verify with ZWR that these globals don't exist in VistA, but it does step on some namespaces like SC*
Type: `cd ~`
Type: `mumps -run ^GDE`
Copy/Paste the following block:
```
add -segment PIP -alloc=4000 -exten=5000 -glob=2000 -FILE=/home/vehu/g/pip.dat
add -region PIP -RECORD_SIZE=4080 -KEY_SIZE=255 -DYNAMIC_SEGMENT=PIP
add -name %ZDDP -region=PIP
add -name CTBL -region=PIP
add -name CUVAR -region=PIP
add -name DBCTL -region=PIP
add -name DBINDX -region=PIP
add -name DBSUCLS -region=PIP
add -name DBSUSER -region=PIP
add -name DBTBL -region=PIP
add -name OBJECT -region=PIP
add -name PROCID -region=PIP
add -name SCATBL -region=PIP
add -name SCAU -region=PIP
add -name SQL -region=PIP
add -name STBL -region=PIP
add -name SVCTRL -region=PIP
add -name SYSMAP -region=PIP
add -name SYSMAPX -region=PIP
add -name TBXBUILD -region=PIP
add -name TBXFIX -region=PIP
add -name TBXINST -region=PIP
add -name TBXLOAD -region=PIP
add -name TBXLOG -region=PIP
add -name TBXLOGX -region=PIP
add -name TBXREJ -region=PIP
add -name UTBL -region=PIP
add -name XDBREF -region=PIP
add -name dbtbl  -region=PIP
sh -a
```

### Create PIP Database
Type:
```
$gtm_dist/mupip create
$gtm_dist/mupip set -journal="enable,on,before" -file g/pip.dat
```

### Import PIP Globals
Note: I had to remove ` UTF-8` from header as VistA is M charset only
Type: `$gtm_dist/mupip load /home/vehu/pip/gbls/globals.zwr`

### Fix `*.xc` Files
Since we aren't installing as the pip user the following files need to be modified
 * `~/pip/extcall_V1.2/extcall.xc`
 * `~/pip/extcall_V1.2/alerts.xc`
 * `~/pip/mtm_V2.4.5/mtm.xc`
To use the path: `/home/vehu/pip`

### Fix gtmenv
Find the lines (except for the unset gtm_lvnullsubs, just put it somewhere logical) and replace them with the values below:

```
gtm_dist=/home/vehu/lib/gtm
gtmgbldir=/home/vehu/g/vehu.gld
unset gtm_lvnullsubs
rtn_list="$basedir/p/$gtmver($basedir/p) $basedir/s/$gtmver($basedir/s) $basedir/r/$gtmver($basedir/r) ${SCAU_PRTNS} ${SCAU_ZRTNS} ${SCAU_SRTNS}/obj(${SCAU_SRTNS}) ${SCAU_MRTNS}/obj(${SCAU_MRTNS}) ${SCAU_CRTNS}/obj(${SCAU_CRTNS}) ${SCA_GTMO}(${SCA_RTNS}) ${gtm_dist}/libgtmutil.so"
```

### Fix gtmenv1
This is mainly setting gtm_chset to M mode as VistA doesn't run in UTF-8 mode

```
# For $ZCHSET="UTF-8"
#
#export gtm_chset=UTF-8
#export LC_CTYPE=en_US.UTF-8
#export LD_LIBRARY_PATH=/usr/lib
# For $ZCHSET="M"
#
export gtm_chset=M
```

### Modify pipstart
Below is the relevant section of pip start. The changes are to the file paths to `muip journal`, `mupip set`, and the `find` commands.
```
$gtm_dist/mupip journal -recover -backward /home/vehu/g/pip.mjl \
 && $gtm_dist/mupip set -journal="enable,on,before" -file /home/vehu/g/pip.dat \
 && ./dm <<EOF
do JOB^PBSUTL("SCA\$IBS",2)
halt
EOF
find gbls -iname pip.mjl_* -mtime +3 -exec rm -v {} \;
```

### Modify pipstop
This is very much like pipstart, so just follow that part again

### Start PIP
NOTE: full path is required
Type: `/home/vehu/pip/pipstart`

### Modify init Scripts to Start/Stop PIP
This is mainly inserting `/home/vehu/pip/pipstart` and `/home/vehu/pip/pipstop` into logical places in `/etc/init.d/vehuvista`. It should be obvious as to the file format and logical places to put those lines. Don't forget to `su - $instance -c source $basedir/etc/env &&` the commands (just like other commands in that file)
