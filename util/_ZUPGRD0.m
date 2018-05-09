%ZUPGRD0	;Private;Automated Version Upgrade Project
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/05/94 09:32:40 - SYSRUSSELL
	; ORIG:  PHIL CHENARD (6938) - 05/01/89
	;
	; Program for the automation of PROFILE/IBS upgrade to next generic 
	; version
	;
	; Version Upgrade Project
	;
	; Intent of this program is to be run from the upgrade dir-
	; ectory.  Therefore, this program must exist in directory before
	; beginning upgrade. Because of the nature of this program, i.e.
	; it kills globals and deletes routines, great care should be taken
	; when running it.
	;
	; As the upgrade progresses, start and end times of each task
	; is logged in the global ^UPGRADE so that the user can identify
	; where in the process things are.  Also, this global is referenced
	; during a restart to determine which steps have already been 
	; completed and can therefore be skipped in a restart.
	;
DIR	K (RMS,RMSDIR,RESTART)
	S %SYS=$$^%ZSYS
	S %TO=99 D INT^%DIR
	I %SYS="GT.M" S %DIR=$$TRNLNM^%ZFUNC("SCAU$DIR")
	S %PG=0,%PAGE=1
	S %HDG=$J("",20)_"PROFILE/IBS Version Upgrade"_$J("",25)
	S T(1)=$J("",5)_"This program will upgrade "_%DIR_", to the                  " 
	S T(2)=$J("",5)_"current version of PROFILE/IBS. If you are not in the       "
	S T(3)=$J("",5)_"directory you wish to upgrade, quit now and run this        "
	S T(4)=$J("",5)_"function from that intended directory.                      "
	S %READ="@%HDG#1,,@T(1)#2,@T(2),@T(3),@T(4)"
	D ^UTLREAD I VFMQ="Q" G EXIT
	;
RMSLD	K T
	S T(1)=$J("",8)_"If the RMS files are already loaded on to disk,        "
	S T(2)=$J("",8)_"answer ""Y"" for YES to this prompt and then enter the "
	S T(3)=$J("",8)_"directory where they reside. If they are to be loaded "
	S T(4)=$J("",8)_"in from tape, answer ""N"" for NO to this prompt and   "
	S T(5)=$J("",8)_"you will then be requested to enter the directory name "
	S T(6)=$J("",8)_"to where these RMS files are to be loaded .            "
	S %TAB("RMS")="|1|||||||L|RMS files loaded",RMS=0
	S %READ="@%HDG#1,,@T(1)#2,@T(2),@T(3),@T(4),@T(5),@T(6),,RMS#1",OLNTB=40
	S %NOPRMT="N"
	D ^UTLREAD 
	I RMS=0 G RMSDIR 
	S OLNTB=10040
	S %TAB("RMSDIR")="|20|||||D DIRCHK^%ZUPGRD0||T|   RMS Directory",RMSDIR=%DIR
	S %READ="RMSDIR#1"
	D ^UTLREAD
	I VFMQ="Q" G EXIT
	;
RMSDIR	K T
	I $D(RMSDIR) G INIT  ; skip over this section if files are already on disk
	S T(1)=$J("",5)_"This procedure will load RMS files containing the new version "
	S T(2)=$J("",5)_"software for this upgrade from tape. These RMS files use app- "
	S T(3)=$J("",5)_"oximately 50,000 VMS blocks. Designate the physical directory "
	S T(4)=$J("",5)_"where these RMS files should be loaded.  The default directory"
	S T(5)=$J("",5)_"will be the current directory being upgraded.                 "
	S %TAB("RMSDIR")="|20|||||D RMS^%ZUPGRD0||T|   RMS Directory ",RMSDIR=%DIR
	S %READ="@%HDG#1,,@T(1)#2,@T(2),@T(3),@T(4),@T(5),,,RMSDIR#1"
	D ^UTLREAD I VFMQ="Q" G EXIT
	K T
	;
INIT	; Initialize variables
	W #,*27,*91,*63,*51,*108
	W !,"Begin automated upgrade at " D ^%T W " on ",$$^%ZD($H),!! H 5
	I '$D(RESTART) ;K ^UPGRADE  ; ^UPGRADE is temp conversion global
	S ER=0
	S LAST="" 
	F VER=3.3,3.5,3.6,4.0,4.1,4.2,4.3 S VER(VER)="V"_$TR(VER,".") I VER=4 S VER(VER)="V40"  ; build version array V33,V35, etc. will need to be modified when versions go past 4.0
	S %TO=99,%LIBS=^CUVAR("%LIBS") 
	I '^CUVAR("%VN") W !,"Upgrade cannot continue due to undefined value of %VN" G EXIT
	S OLDVER=+$P(^CUVAR("%VN"),"|",1),VER=$O(VER(OLDVER)),VNM=VER(VER)   ; define version number as V35, V36, etc.
	S ^UPGRADE("OLDVER")=OLDVER,^("VER")=VER,^("VNM")=VNM
	S CNVPRE="CN"_VNM_"PRE",CNVDRV="CN"_VNM  ; sets the pre-conversion and conversion driver program names
	I VNM="V35" S CNVPRE="CNV34PRE",CNVDRV="CNV34"  ; for 3.5 upgrade ONLY
	S DBSCNV="DBSCN"_VNM   ; set the data qwik conversion program name 
	D INT^%DIR
	S HOMERTN=$ZROUTINES,HOMEGBL=$ZGBLDIR
	I %SYS="GT.M" S %DIR=$P(%DIR,".",1),%DIR=%DIR_"]"
	S LAST=$ZP(VER(VER))
	S WRITE="W $J(N,15) I $X>65 W !"
	S %PG=0,%PAGE=1
	S %MCP=$G(^CUVAR("%MCP"))
	;
START	; Begin upgrade process
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZTQ^%ZUPGRD0")
	I OLDVER'=LAST I VER=4 S VER="4.0" W *7,!!,"Upgrade to ",VER," cannot be done. Upgrade aborted. Check the value of ^CUVAR(""%VN"")." W *7 Q
	I VER=4 S VER="4.0"
	S HDG=$J("",20)_"PROFILE/IBS Version "_VER_" Upgrade"_$J("",20)
	S HDG(1)=$J("",20)_"Upgrade Directory: "_%DIR_$J("",10)
	S T(1)=$J("",5)_"This program will upgrade a PROFILE directory from "_OLDVER_" to "_VER_"."
	S T(2)=$J("",5)_"Prior to running this program, backups should be performed,    "
	S T(3)=$J("",5)_"and custom globals being reinstalled during the upgrade        "
	S T(4)=$J("",5)_"must be output to RMS. If this has not yet been done,          "
	S T(5)=$J("",5)_"quit this program and perform those tasks before continuing.   "
	S %READ="@HDG#1,,@HDG(1)#2,,,@T(1)#2,,,@T(2)#0,@T(3),@T(4),@T(5)"
	D ^UTLREAD I VFMQ="Q" G EXIT
	K T
	;
MGR	; prompt for setting up MGR userclass for new functions and user tables
	K T
	S T(1)=$J("",5)_"This upgrade will set up userclass ""SCA"" for access to    "
	S T(2)=$J("",5)_"all new functions and user tables. If you wish to also      "
	S T(3)=$J("",5)_"include userclass ""MGR"" for access as well, enter yes now."
	S %TAB("MGR")="|1|||||||L|Set up MGR Userclass",MGR=0
	S %READ="@%HDG#1,,@T(1)#2,@T(2),@T(3),,,MGR#1",OLNTB=40
	D ^UTLREAD
	K T
	;
	;
TAPE0	; Load in the upgrade RMS files from tape.
	I $D(RMS) G LOAD^%ZUPGRD1  ; RMS is set when upgrade RMS files are loaded onto disk.
	S T(1)=$J("",5)_"Mount the SCA tape containing the upgrade RMS files.       "
	S T(2)=$J("",5)_"When the tape has been mounted and placed online, continue."
	S %READ="@%HDG#1,,,@T(1)#0,@T(2)"
	D ^UTLREAD I VFMQ="Q" G EXIT
	K T 
	;
	G ^%ZUPGRD1
	;
ZTQ	; error trap
	D ZE^UTLERR
	G EXIT
	;
EXIT	S %TN=$P($H,",",2) D ^SCATIM1
	S ER=1,RM="Upgrade aborted at "_%TS
	Q
	;
DIRCHK	; check for valid directory
	N IO
	S IO=X_"XXX.XXX"
	S Z=$$FILE^%ZOPEN(IO,"WRITE/NEWV",2) I 'Z S ER=1,RM="Invalid directory" C IO Q
	C IO
	S Z=$$SYS^%ZFUNC("DEL "_IO_";")
	K IO
	Q
RMS	; verify that there is enough room on disk to fit the RMS files
	I X="" S ER=1,RM="Enter a directory name." Q
	S Z=$$TRNLNM^%ZFUNC(X) I Z'=""&(Z'=X) S X=Z
	S BLKS=50000  ; number of blocks needed to fit RMS files
	S DEVICE=$P(X,":",1)
	S Z=$$GETDVI^%ZFUNC(DEVICE,"FREEBLOCKS")  ; determines free blks on disk DEVICE
	I Z<BLKS S ER=1,RM="Not enough free blocks on disk, choose another directory."
	Q
	;
