%ZUPGRD2	;Private;Automated Version Upgrade Project
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/05/94 09:34:06 - SYSRUSSELL
	; ORIG:  Phil Chenard (6938) - 05/01/89
	;
	; Automated PROFILE/IBS version upgrade 
	;
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZTQ^%ZUPGRD2")
	;
CUSRO	; output all "Z" routines to RMS
	W $$CLEAR^%TRMVT
	I $P($G(^UPGRADE("RLOADZ")),"|",2) W "Custom routine output already complete." W ! G RDEL
	S $P(^UPGRADE("RLOADZ"),"|",1)=$H
	W !!,"Now outputting custom routines to RMS file at " D ^%T W !
	S %ZI("Z*")=""
	D INT^%RSEL
	S IO=RMSDIR_VNM_".ZRO"
	S X=$$FILE^%ZOPEN(IO,"WRITE/NEWV",2) I 'X#2 W !,"Unable to open custom RMS file." Q
	S DESCR="Custom routine output"
	S CNT=$$EXT^%RO(IO,DESCR,.%ZR,0)
	C IO
	;
RDEL	; Delete routines except for custom "Z" programs and this program
	W !!
	W !!,"Now deleting routines in ",%DIR," at " D ^%T W !
	I $P($G(^UPGRADE("RDEL")),"|",2) W "Routine deletion already completed. " W ! G RLOADM
	S $P(^UPGRADE("RDEL"),"|",1)=$H
	W !,"Main routines...",!
	S X=$$SYS^%ZFUNC("rm "_$$MRTNS^%LNM("*.M"))
	S X=$$SYS^%ZFUNC("rm "_$$MOBJ^%LNM("*.o"))
	W !,"Compiled routines...",!
	S X=$$SYS^%ZFUNC("rm "_$$CRTNS^%LNM("*.M"))
	S X=$$SYS^%ZFUNC("rm "_$$COBJ^%LNM("*.o"))
	W !,"Routine deletion complete at " D ^%T W !
	S $P(^UPGRADE("RDEL"),"|",2)=$H
	;
RLOADM	; new version OF "main" routine set will be loaded in 
	W !,"Now loading ",VER," MAIN routine set at " D ^%T W !
	I $P($G(^UPGRADE("RLOADM")),"|",2) W "Routine load already completed" D ^%T G RLOADC
	; Load in routine set(s) from RMS. ^UPGRADE("RLOADM")
	S $P(^UPGRADE("RLOADM"),"|",1)=$H
	S IO=RMSDIR_VNM_".RO1"
	S RTNDIR=$$MRTNS^%LNM
	S X=$$FILE^%ZOPEN(IO,"READ",5) I X=0 W "No routines loaded!" S:'$D(FLG) FLG=1 S $P(^UPGRADE("RLOADM"),"|",3)="Routines not loaded." G EXIT   ;log a message and quit
	D ^%ZUPGRRI ; utility program to load in ALL routines from an RMS file
	C IO
	S $P(^UPGRADE("RLOADM"),"|",2)=$H
	W !,"Main routine load done at " D ^%T W !
	;
RLOADC	; new version of "compiled" routine set will be loaded in 
	W !,"Now loading ",VER," COMPILED routine set at " D ^%T W !
	I $P($G(^UPGRADE("RLOADC")),"|",2) W "Compiled routine load already completed" D ^%T G RLOADZ
	; Load in routine set(s) from RMS. ^UPGRADE("RLOADC")
	S $P(^UPGRADE("RLOADC"),"|",1)=$H
	S IO=RMSDIR_VNM_".RO2"
	S RTNDIR=$$CRTNS^%LNM
	S X=$$FILE^%ZOPEN(IO,"READ",5) I X=0 W "No routines loaded!" S:'$D(FLG) FLG=1 S $P(^UPGRADE("RLOADC"),"|",3)="Routines not loaded." G EXIT   ;log a message and quit
	U IO R X,Y
	D EXT^%RI(IO,RTNDIR,"A",1,0)   ; load in routines but don't compile
	;D ^%ZUPGRRI ; utility program to load in ALL routines from an RMS file
	C IO
	S $P(^UPGRADE("RLOADC"),"|",2)=$H
	W !,"Compiled routine load done at " D ^%T W !
	;
	; now submit to compile the routines in SCAU$CRTNS
	S IO=$$CRTNS^%LNM("CRTNS_COMPILE.COM")
	S X=$$FILE^%ZOPEN(IO,"WRITE/NEWV",2)
	U IO
	W "$! Command procedure to compile routines in SCAU$CRTNS",!
	W "$ SET NOVERIFY",!
	W "$ MC :== "_$$RTNS^%LNM("SCA_COMPILE"),!
	W "$ SET DEF "_%DIR,!
	W "$ @GTMENV 1",!
	W "$ SET DEF "_$$CRTNS^%LNM,!
	W "$ MC *",!
	W "$ EXIT",!
	W "$!",!
	C IO
	S X=$$SYS^%ZFUNC("SUBMIT/LOG=SCAU$CRTNS:COMPILE.LOG/NOPRINT/NOIDENTIFY/DEL SCAU$CRTNS:CRTNS_COMPILE")
	;
RLOADZ	; Custom "Z" routines will be loaded back in
	W !,"Now loading custom routine set at " D ^%T W !
	I $P($G(^UPGRADE("RLOADZ")),"|",2) W "Custom routine load already completed" D ^%T G ^%ZUPGRD3
	; Load in routine set(s) from RMS. ^UPGRADE("RLOADZ")
	S $P(^UPGRADE("RLOADZ"),"|",1)=$H
	S IO=RMSDIR_VNM_".ZRO"
	S RTNDIR=$$MRTNS^%LNM
	S X=$$FILE^%ZOPEN(IO,"READ",5) I X=0 W "Custom routines not loaded!" S:'$D(FLG) FLG=1 S $P(^UPGRADE("RLOADC"),"|",3)="Routines not loaded." G EXIT   ;log a message and quit
	D ^%ZUPGRRI ; utility program to load in ALL routines from an RMS file
	C IO
	S $P(^UPGRADE("RLOADZ"),"|",2)=$H
	W !,"Custom routine load done at " D ^%T W !
	;
	W !,"Deletions and standard release load complete at " D ^%T W !
	;
	G ^%ZUPGRD3
	;
ZTQ	D ZE^UTLERR
	W !,"Upgrade aborted on error."
	Q
	;
EXIT	W !,"Upgrade aborted due to error in routine load at " D ^%T
	Q
