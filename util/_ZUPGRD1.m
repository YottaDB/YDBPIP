%ZUPGRD1	;Private;Automated Upgrade Project
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/05/94 09:33:35 - SYSRUSSELL
	; ORIG: Phil Chenard (6938) 5/01/89
	;
	; Automated PROFILE/IBS version upgrade
	;
	; This program handles the RMS file load, including mounting
	; and dismounting the tape device and putting the RMS files
	; onto disk.
	;
	; It calls ^%ZUPGRD2 and is called by ^%ZUPGRD0.
	;
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZTQ^%ZUPGRD1")
	;
	I $P($G(^UPGRADE("TAPE")),"|",2) G CHKRMS
	;
	;Mount the tape to load in the RMS files
TAPE1	S $P(^UPGRADE("TAPE"),"|",1)=$H
	D ENT^%ZMOUNT  ; external call to retain value of %TDRV
	; Use $ZF to load in RMS files from tape
	S $P(^UPGRADE("RMS"),"|",1)=$H
	S %TDRV=$TR(%TDRV,":") ; removes the colon if it already exists
	S X=$$SYS^%ZFUNC("BACKUP/LOG "_%TDRV_":*.* "_RMSDIR_"*.*") ; call DCL BACKUP 
	;               utility to load in RMS files from %TDRV tape drive
	W !,"RMS files loaded in ",RMSDIR S RMS=1
	S $P(^UPGRADE("RMS"),"|",2)=$H
	D ^%ZDISMOU
	S $P(^UPGRADE("TAPE"),"|",2)=$H
	;  
LOAD	; Begin loading in the routines and globals from RMS
	S TEXT(1)=$J("",8)_"Routine and Global RMS files have been loaded     "
	S TEXT(2)=$J("",8)_"on to disk in directory "_RMSDIR_". Continue here "
	S TEXT(3)=$J("",8)_"to begin the PROFILE/IBS Software Upgrade process."
	S %READ="@%HDG#1,,,@TEXT(1)#2,@TEXT(2),@TEXT(3)"
	D ^UTLREAD I VFMQ="Q" G EXIT
	K TEXT
	;
CHKRMS	; check to see if proper RMS files were loaded onto disk,
	; based on the upgrade version, VNM
	W #,*27,*91,*63,*51,*108
	I $P($G(^UPGRADE("MISC")),"|",2) G BEGIN
	S VRMS=$$SYS^%ZFUNC("DIR/SIZ/DAT "_RMSDIR_VNM) H 5
	I VRMS'=1 W !,"Files not found in ",RMSDIR  G EXIT
	H 4
	;
BEGIN	; Set the ^CUVAR("%VN") to indicate where in the upgrade process
	; things are. Also, begin setting ^CNV w/ start and end times.
	;
	I $D(RESTART) S $P(^CUVAR("%VN"),"|",4)=$H,$P(^UPGRADE(VNM),"|",4)=$H 
	; if a restart is being performed, indicate the time in piece 3 and 
	; return to tag RESTART in ^%ZUPGRD2
	;
	S $P(^CUVAR("%VN"),"|",2)="Upgrade to version "_VNM_" in progress."
	S $P(^("%VN"),"|",3)="*1"
	S $P(^UPGRADE(VNM),"|",1)=$H 
	;
	G ^%ZUPGRD2
	;
ZTQ	; error trap
	D ZE^UTLERR
	G EXIT
	;
EXIT	
	S ER=1,RM="Upgrade aborted on error at " D ^%T
	S $P(^UPGRADE(VNM),"|",3)="Upgrade aborted"_"|"_$H
	Q
