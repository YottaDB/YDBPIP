# Installation guide

 * Download the source code from github:
   * Type: `git clone https://github.com/YottaDB/pip.git`
 * Compile mtm (verified works)
   * Type: `cd ~/pip/mtm_*`
   * Type: `make`
 * Compile extcall
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
 * Compile libsql
   * Type: `cd ~/pip/libsql_*`
   * Type: `make LINUX`
   * Type: `make version`
 * Compile mintrpt
   * Type: `cd ~/pip/util`
   * Type: `make -f mintrpt.mk`

 * Create GDE file
   * This is based on using the default templates for YottaDB and making targeted changes to support PIP:
     * Type: `source gtmenv`
     * Type: `/usr/local/lib/yottadb/r120/mumps -run ^GDE`
     * `change -region DEFAULT -RECORD_SIZE=4080`
     * `change -segment DEFAULT -alloc=4000 -exten=5000 -glob=2000 -FILE=$HOME/Projects/yottadb/pip/gbls/mumps.dat`
     * Type: `exit`
 * Fix `*.xc` files
   * Each `*.xc` file has a reference to the shared library that needs to be executed that is system dependent. Modify the following files to have the correct path to the shared library:
     * ~/pip/extcall_V1.2/extcall.xc
     * ~/pip/extcall_V1.2/alerts.xc
     * ~/pip/mtm_V2.4.5/mtm.xc
