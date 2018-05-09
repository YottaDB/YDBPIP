%ZUPGRD	;Private;Automated PROFILE version upgrade project
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/05/94 09:31:50 - SYSRUSSELL
	; ORIG:  PHIL CHENARD (6938) - 06/21/89
	;
	; Internal program to output new version software to RMS files and
	; tape, if desired, for upgrade of prior PROFILE/IBS version to 
	; current.  Will be run from the QA side from the correct,current
	; version directory.
	;
	N
	S %TO=99,%PG=0,%PAGE=1
	S %HDG="PROFILE/IBS Version Upgrade",%HDG=$J("",80-$L(%HDG)\2)_%HDG_$J("",25)
	S T(1)=$J("",5)_"This program will create the RMS files, from the proper  "
	S T(2)=$J("",5)_"QA directory, for upgrading IBS to the current version.  "
	S T(3)=$J("",5)_"It will automatically create these files and put them to "
	S T(4)=$J("",5)_"tape, if so desired, to be sent to clients for upgrading "
	S T(5)=$J("",5)_"their version to the current version.                    "
	S T(6)=$J("",5)_"This program must be run from a stable directory, i.e.,  "
	S T(7)=$J("",5)_"there must not be any project software loads occurring   "
	S T(8)=$J("",5)_"while this program runs.                                 "
	S T(9)=$J("",5)_"If you are not ready to create the new version RMS files,"
	S T(10)=$J("",5)_"quit this program now.                                  "
	S %READ="@%HDG#1,,,@T(1)#0,@T(2),@T(3),@T(4),@T(5),,@T(6),@T(7),@T(8),,@T(9),@T(10)",OLNTB=30
	D ^UTLREAD I VFMQ="Q" Q
	K T
	;
DIR	S %DIR=$$CDIR^%LNM
	S T(1)=$J("",10)_"This program will create the version upgrade RMS files "
	S T(2)=$J("",10)_"out of this current directory  "_%DIR_".               "
	S T(3)=$J("",10)_"If this is not the correct directory, quit now and     "
	S T(4)=$J("",10)_"run this utility from the intended directory.          "
	S %READ="@%HDG#1,,@T(1)#0,@T(2),@T(3),@T(4)"
	D ^UTLREAD I VFMQ="Q" Q
	;
INIT	;
	S ER=0
	F VER=3.5,3.6,4.0,4.1,4.2,4.3,4.4,4.5 S VER(VER)="V"_$TR(VER,".") I VER=4 S VER(VER)="V40"
	I '$G(^CUVAR("%VN")) W !,"Cannot continue. Check value of ^CUVAR(""%VN"")." Q
	S VER=+$P($G(^CUVAR("%VN")),"|",1) 
	S OLDVER=$ZP(VER(VER)),VNM=VER(VER) I VER=4 S VER="4.0"
	S WRITE="W $J(N,15) I $X>65 W !"
	S CNVPRE="CN"_VNM_"PRE",CNVDRV="CN"_VNM
	I VNM="V35" S CNVPRE="CNV34PRE",CNVDRV="CNV34"  ; only for 3.5 upgrade
	S DBSCNV="DBSCN"_VNM ; set the DATA-QWIK conversion program
	;
START	; Begin process
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZTQ^%ZUPGRD")
	;
	K T
	S HDG=$J("",15)_"PROFILE/IBS Version "_VER_" Upgrade                  "
	S T(1)=$J("",15)_"Version Source Directory: "_%DIR_"                  "
	S T(2)=$J("",5)_"This program will create the RMS files required for  "
	S T(3)=$J("",5)_"a version upgrade.  These files comprise a total of  "
	S T(4)=$J("",5)_"approximately 50,000 VMS blocks.  Name the directory "
	S T(5)=$J("",5)_"where the created upgrade RMS files are to be placed."
	S %TAB("RMSDIR")="|20|||||D RMS^%ZUPGRD||T|RMS directory"
	S %READ="@%HDG#1,,,@HDG#2,,@T(1)#0,,@T(2),@T(3),@T(4),@T(5),,RMSDIR#1",OLNTB=35
	D ^UTLREAD
	I VFMQ="Q" Q
	K T
	S T(1)=$J("",5)_"Do you wish to copy the RMS files to tape as part of    "
	S T(2)=$J("",5)_"this process. If so, you will be prompted for the tape  "
	S T(3)=$J("",5)_"information after the RMS files have been created. Enter"
	S T(4)=$J("",5)_"""Y"" for YES if you wish to copy the RMS files to tape."
	S %TAB("TPYN")="|1|||||||L|Copy RMS files to tape ",TPYN=0
	S %READ="@%HDG#1,,,@T(1)#0,@T(2),@T(3),@T(4),,,TPYN#1",OLNTB=40
	D ^UTLREAD
	;
BEGIN	;
	S %TN=$P($H,",",2) D ^SCATIM1 S %TIM=%TS
	W !!,"^%ZUPGRD begun at ",%TIM,! H 5
	; begin rms outputs.  6 RMS files will be created, one for the 
	; routine set and five for the globals.  The global categories are 
	; as follows: 1= ^DBTBL("SYSDEV",0   library controls
	;    ,1   standard files
	;    ,2   standard screens
	;    ,3   sort files
	;    ,4   query definitions
	;    ,5   standard reports
	;    ,11  standard on-line documentation
	;    ,13  standard pre/post processors
	;       2= ^SCATBL(0,1:99999                 standard menus
	;   ^SCATBL(1,"%A"-"%Yzzz") and ^("A":"Yzzz")  standard functions
	;   ^SCATBL(2      system variables
	;   ^SCATBL(3      function documentation
	;       3= ^STBL       system tables
	;       4= ^TRN(,)      top levels of transaction codes
	;       5= ^UTBL()      top level of user tables
	;    and any other miscellaneous global, including ^CNVTBL
	;
	; The fifth global RMS file may contain miscellaneous globals.
	; This program will therefore prompt for the entry of these
	; globals here.
	;
	K T
	S T(1)=$J("",5)_"If there will be miscellaneous globals included in   "
	S T(2)=$J("",5)_"the outputs to RMS files, enter ""Y"" for Yes now    "
	S T(3)=$J("",5)_"and the globals can be input one at a time Otherwise,"
	S T(4)=$J("",5)_"only the top level of ^UTBL will be output to RMS.   "
	S %TAB("MSC")="|1|||||||L|Include Misc. Globals",MSC=0
	S %READ="@%HDG#1,,,@T(1)#0,@T(2),@T(3),@T(4),,MSC#1",OLNTB=40
	D ^UTLREAD W #
	I VFMQ="Q" S MSC=0
	I MSC D MISC
	W #,*27,*91,*63,*51,*108
	;
	W !!,"Now creating RMS files for "_VNM_" upgrade at " D ^%T 
	S LINE="",$P(LINE,"=",80)=""
	W !,LINE,! H 5
	D GOGEN
	D RO,RO3
	D PROT
	S X=$$SYS^%ZFUNC("PURGE "_RMSDIR_VNM_".*")
	D TAPE S %TN=$P($H,",",2) D ^SCATIM1 
	W !!,"Process completed at ",%TS," on " D ^%D W !
	Q
	;
MISC	; Miscellaneous global section
	S PASS=0
MISC1	; loop
	N I
	K RM,MISC
	S HDG="Miscellaneous Globals",HDG=$J("",80-$L(HDG)\2)_HDG
	S %TAB("MISC")="|40|||||D MISCHK^%ZUPGRD||T|Global ^"
	S %TAB("MORE")="|1|||||||L|More ",MORE=0
	S %READ="@%HDG#1,,@HDG#2,,MISC*15#0,,MORE"
	D ^UTLREAD
	I VFMQ="Q" Q   ; quits out of misc section and continues on w/ GOGEN
	F I=1:1 Q:'$D(MISC(I))  S SAV(I+(PASS*15))=MISC(I)
	I MORE S PASS=PASS+1 G MISC1
	F I=1:1 Q:'$D(SAV(I))  S MISC(I)=SAV(I)
	S Z="" F I=1:1 S Z=$O(MISC(Z)) Q:Z=""  I MISC(Z)="" K MISC(Z)
	K SAV
	Q
	;
MISCHK	; post processor for miscellaneous globals
	I X="" Q
	S Y=$P(X,"(",1) I Y'?.U S ER=1,RM="Invalid syntax " Q
	S XX="^"_Y I '$D(@XX) S ER=1,RM="Invalid GLobal " Q
	S %G="^"_X D MISCHK1
	Q
MISCHK1	;
	D VALID^%G(%G) Q:ER
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("MISCHKER^%ZUPGRD")
	N LAST,G,CHK
	S LAST=$E(%G,$L(%G)),G=$E(%G,1,$L(%G)-1)
	I LAST="("!(%G'["(") Q
	I LAST="," S G=G_")",CHK=9
	E  I LAST=")" S G=%G,CHK=0
	E  S G=%G_")",CHK=0
	I $D(@G)'>CHK S ER=1,RM="Global not defined"	
	Q
MISCHKER ;
	S ER=1,RM="Invalid Syntax"
	Q
	;
GOGEN	; Create global RMS files
	S G=1
	S IOP1=VNM_".GBL1"
	;
DBTBL	; create RMS file GBL1
	S IOP=RMSDIR_IOP1
	W !,"Now creating RMS file ",IOP1," to directory ",RMSDIR," at " D ^%T W !
	S IO=IOP 
	S X=$$FILE^%ZOPEN(IO,"WRITE/NEWV",2) I 'X#2 W !!,"Unable to open "_IOP1 Q
	U IO
	;
	S %G="DBTBL(""SYSDEV"",0" D %GSET
	S %G="DBTBL(""SYSDEV"",1)" D %GSET
	S %G="DBTBL(""SYSDEV"",1,""A"":""Yzzzz""" D %GSET
	S %G="DBTBL(""SYSDEV"",2)" D %GSET
	S %G="DBTBL(""SYSDEV"",2,""A"":""Yzzzz""" D %GSET
	S %G="DBTBL(""SYSDEV"",3,""A"":""Yzzzz""" D %GSET
	S %G="DBTBL(""SYSDEV"",4,""A"":""Yzzzz""" D %GSET
	S %G="DBTBL(""SYSDEV"",5)" D %GSET
	S %G="DBTBL(""SYSDEV"",5,""A"":""Yzzzz""" D %GSET
	S %G="DBTBL(""SYSDEV"",11" D %GSET
	S %G="DBTBL(""SYSDEV"",13,""A"":""Yzzzz""" D %GSET
	S %G="DBTBL(""SYSDEV"",13,""ZIP""" D %GSET
	U IO D EXIT^%GOGEN C IO
	U 0 W "***DONE***",!!
	;
SCATBL	; create RMS file GBL2
	S IOP1=VNM_".GBL2"
	S IOP=RMSDIR_IOP1
	W !,"Now creating RMS file ",IOP1," to directory ",RMSDIR," at " D ^%T W !
	S IO=IOP
	S X=$$FILE^%ZOPEN(IO,"WRITE/NEWV",2) I 'X#2 W !!,"Unable to open "_IOP1 Q
	U IO
	;
	S %G="SCATBL(0,1:99999" D %GSET
	S %G="SCATBL(1,""%"":""%Yzzzzz"")" D %GSET
	S %G="SCATBL(1,""A"":""Yzzzzz"")" D %GSET
	S %G="SCATBL(2" D %GSET
	S %G="SCATBL(3" D %GSET
	U IO D EXIT^%GOGEN C IO
	U 0 W "***DONE***",!!
	;
STBL	; create RMS file GBL3
	S IOP1=VNM_".GBL3"
	S IOP=RMSDIR_IOP1
	W !,"Now creating RMS file ",IOP1," to directory ",RMSDIR," at " D ^%T W !
	S IO=IOP
	S X=$$FILE^%ZOPEN(IO,"WRITE/NEWV",2) I 'X#2 W !!,"Unable to open "_IOP1 Q
	U IO
	;
	S %G="STBL(""A"":""Yzzzz""" D %GSET
	U IO D EXIT^%GOGEN C IO
	U 0 W "***DONE***",!!
	;
TRN	; create RMS file GBL4
	S IOP1=VNM_".GBL4"
	S IOP=RMSDIR_IOP1
	W !,"Now creating RMS file ",IOP1," to directory ",RMSDIR," at " D ^%T W !
	S IO=IOP
	S X=$$FILE^%ZOPEN(IO,"WRITE/NEWV",2) I 'X#2 W !!,"Unable to open "_IOP1 Q
	U IO
	;
	S %G="TRN(""@a"":""@yzzz"",)" D %GSET
	S %G="TRN(""a"":""yzzzz"",)" D %GSET
	U IO D EXIT^%GOGEN C IO
	U 0 W "***DONE***",!!
	;
MISC2	; create RMS file GBL5
	N I
	S IOP1=VNM_".GBL5"
	S IOP=RMSDIR_IOP1
	W !,"Now creating RMS file ",IOP1," to directory ",RMSDIR," at " D ^%T W !
	S IO=IOP
	S X=$$FILE^%ZOPEN(IO,"WRITE/NEWV",2) I 'X#2 W !!,"Unable to open "_IOP1 Q
	U IO
	;
	S %G="UTBL(""A"":""Yzzzz"")" D %GSET
	S %G="CNVTBL" D %GSET
	I $D(MISC) S X="" F I=1:1 S X=$O(MISC(X)) Q:X=""  S %G=MISC(X) D %GSET
	U IO D EXIT^%GOGEN C IO
	U 0 W "***DONE***",!!
	;
	W !,"Global RMS files completed at " D ^%T W !
	H 4
	Q
%GSET	; create RMS file
	U IO D EXT^%GOGEN(%G)
	Q
	;
RO	; routine output to RMS file VNM.RO1
	K T
	S T(1)=$J("",20)_"Version "_VER_" Routine Output                          "
	S T(2)=$J("",10)_"Standard routines will now be output to RMS file.       " 
	S T(3)=$J("",10)_"If you wish to include custom routines as part of       "
	S T(4)=$J("",10)_"this routine output, enter ""Y"" for YES here and       "
	S T(5)=$J("",10)_"enter those custom routines now.                        "
	S %TAB("CUSRI")="|1|||||||L|Include Custom Routines",CUSRI=0
	S %READ="@%HDG#1,,,@T(1)#2,,,@T(2)#0,@T(3),@T(4),@T(5),,CUSRI#1",OLNTB=45
	D ^UTLREAD
	I VFMQ="Q" G EXIT
	S RTNDIR=$$MRTNS^%LNM
	S CNTC=0,CNTM=0
	I CUSRI D CUSRI
	;
	S %ZI("A:Yzzzzz")="" D INT^%RSEL
	F OMIT="'B0:B99","'FEE*","'R02*","'R01B*","'V02*","'V01B*","'YLB*","'VP0*" S %ZI(OMIT)="" D INT^%RSEL
	Q
	;
CUSRI	; enter custom routines into %ZR
	S PASS=0
CUS1	K RM,CUS,HDG
	N I
	S HDG="  Custom Routines:"
	S HDG2=" ----------------"
	S %READ="@%HDG#1,,,@HDG#2,@HDG2#0",%NOPRMT="C"
	D ^UTLREAD
	W !
	D ^%RSEL
	S X=""
	F I=1:1 S X=$O(%ZR(X)) Q:X=""  S:%ZR(X)[".MRTNS" %ZRM(X)=%ZR(X),CNTM=CNTM+1 S:%ZR(X)[".CRTNS" %ZRC(X)=%ZR(X),CNTC=CNTC+1
	K SAV
	Q
	;
ROUCHK	; check if routine exists in directory
	N I
	I X="" Q
	K RM
	I '$$VALID^%ZRTNS(X) S ER=1,RM="Invalid routine" Q
	S ER="W",RM=" "
	Q
RO3	; create the RMS file
	W #,*27,*91,*63,*51,*108
	S ROU=""
	F I=1:1 S ROU=$O(%ZR(ROU)) Q:ROU=""  S:%ZR(ROU)[".CRTNS" %ZRC(ROU)=%ZR(ROU),CNTC=CNTC+1 S:%ZR(ROU)[".MRTNS" %ZRM(ROU)=%ZR(ROU),CNTM=CNTM+1
	K %ZR
	I $D(%ZRM) S %ZRM=CNTM D ROM
	I $D(%ZRC) S %ZRC=CNTC D ROC
	Q
	;
ROM	N (%ZRM,IOP,IODAT,VNM,ROU,RMSDIR,RTNDIR)
	S IOP2=VNM_".RO1"
	S IOP=RMSDIR_IOP2,IOPAR="WN"
	W !!,"Now creating RMS file ",IOP2," for main routines in directory ",RMSDIR," at " D ^%T 
	S LINE="",$P(LINE,"=",80)=""
	W !,LINE,! H 4
	W !!,"The following "_%ZRM_" routines are being output to ",IOP,!
	S IO=IOP 
	O IO:(WRITE:NEWV):2 E  W !,"Unable to open routine RMS file. Q"
	S DESCR="PROFILE/IBS Version upgrade main routine set for "_VNM
	S CNT=$$EXT^%RO(IO,DESCR,.%ZRM,0)
	C IO
	Q
	;
ROC	N (%ZRC,IOP,IODAT,VNM,ROU,RMSDIR,RTNDIR)
	S IOP2=VNM_".RO2"
	S IOP=RMSDIR_IOP2,IOPAR="WN"
	W !!,"Now creating RMS file ",IOP2," for compiled routines in directory ",RMSDIR," at " D ^%T 
	S LINE="",$P(LINE,"=",80)=""
	W !,LINE,! H 4
	W !!,"The following "_%ZRC_" routines are being output to ",IOP,!
	S IO=IOP O IO:(WRITE:NEWV):2 E  W !,"Unable to open routine RMS file. Q"
	S DESCR="PROFILE/IBS Version upgrade compiled routine set for "_VNM
	S CNT=$$EXT^%RO(IO,DESCR,.%ZRC,0)
	C IO
	Q
	;
PROT	; set protection on RMS files
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZTQ^%ZUPGRD")
	S X=$$SYS^%ZFUNC("SET PROT=(S:RWED,G:RWED,W:RWED) "_RMSDIR_VNM_"*.*")
	;
	W !!,"Routine RMS file completed at " D ^%T 
	H 4 W !
	Q
	;
ERRW	; error trap for writing routines
	U 0 W !,"Error writing routine ",ROU
	Q
	;
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZTQ^%ZUPGRD")
	;
TAPE	I $G(TPYN)=0 G EXIT
	; prompt for tape handling now or quit program
	K T
	S T(1)=$J("",5)_"If you wish to create the tape with the RMS files "
	S T(2)=$J("",5)_"now, continue on.  Otherwise quit and create the  "
	S T(3)=$J("",5)_"upgrade tape with the RMS files at another time.  "
	S %READ="@%HDG#1,,,@T(1)#0,@T(2),@T(3)"
	D ^UTLREAD
	I VFMQ="Q" W !,"Tape creation aborted.",! Q
	;
TAPFMT	; determine if tape will be created during this process
	S HDG="  PROFILE/IBS Version Upgrade                                 "
	S T(1)=$J("",5)_"RMS files can be put onto one of two different tape          "
	S T(2)=$J("",5)_"drives, a TK50/70 drive, or the 9 track drive. Also,         "
	S T(3)=$J("",5)_"if the 9 track drive is chosen, output can be either         "
	S T(4)=$J("",5)_"1600 or 6250 bpi density. Choose one of these three          "
	S T(5)=$J("",5)_"options by entering one of the following:                    "
	S T(6)=$J("",5)_"""A"":  TK50 or TK70  (drive MUB0:, device 48)              "
	S T(7)=$J("",5)_"""B"":  9 track, 1600 bpi density (drive MUA0:)            "
	S T(8)=$J("",5)_"""C"":  9 track, 6250 bpi density                           "
	S T(9)=$J("",5)_"Based on your selection, the RMS files will be automatically"
	S T(10)=$J("",5)_"put to tape in the proper format as a save set ""SCA.BCK""."
	S %TAB("TP")="|1|||||I ""ABC""'[X S ER=1,RM=""Enter A,B, or C""||T|Tape option",TP="C"
	S %READ=",@HDG#2,,,@T(1),@T(2),@T(3),@T(4),@T(5),@T(6),,,@T(7),@T(8),@T(9),,@T(10),@T(11),,,TP"
	D ^UTLREAD
	I VFMQ="Q" W !,"Tape creation aborted at " D ^%T Q
	; TP will be used to determine which tape drive is used and what
	; density the tape should be created at.
	K T
	;
LOAD	S T(1)=$J("",5)_"Load your tape on the drive and put it on-line.    "
	S T(2)=$J("",5)_"Process will pause here until you are ready to con-"
	S T(3)=$J("",5)_"tinue.                                             "
	S %TAB("CONT")="|1|||||||L|Are you ready to continue?",CONT="N"
	S %READ="@T(1),@T(2),@T(3),,,,<<CONT#1>>"
	K OLNTB D ^UTLREAD
	I VFMQ="Q" W !,"Process aborted.  Tape was not created." Q
	;
MOUNT	; mount the tape through $ZF
	; tape options are "A" - TK50 on device MUB0
	;      "B" - 9 track on device MUA0, 1600 bpi
	;     "C" - 9 track on device MUA0, 6250 bpi
	;
	I TP="A" D A
	I TP="B" D B
	I TP="C" D C
	Q
	;
A	; mount the TK50
	S %TDRV="MUB0"
	S DENS=1600
	D BACKUP
	Q
	;
B	; mount MUA0
	S %TDRV="MUA0"
	S DENS=1600
	D BACKUP
	Q
	;
C	; mount MUAO at high density
	S %TDRV="MUA0"
	S DENS=6250
	D BACKUP
	Q
	;
BACKUP	;
	S X=$$SYS^%ZFUNC("INIT/OVER=OWNER/DEN="_DENS_" "_%TDRV_" SCA")
	S X=$$SYS^%ZFUNC("MOUNT/FOR "_%TDRV)
	S X=$$SYS^%ZFUNC("BACKUP/LOG/LIST/VERIFY/DEN="_DENS_" "_RMSDIR_VNM_".* "_%TDRV_":SCA.BCK")
	W !!," RMS files now loaded on to tape on ",%TDRV," at " D ^%T W !
	S X=$$SYS^%ZFUNC("DISMOUNT "_%TDRV)
	Q
ZTQ	; error trap
	D ZE^UTLERR
	W !,"Process aborted at " D ^%T W !
	Q
	;
EXIT	; 
	S %TN=$P($H,",",2) D ^SCATIM1 S %TIM=%TS
	W !!,"RMS files for version ",VER," done at ",%TIM
	Q
	;
RMS	; verify that there is enough room on disk to place RMS files
	I X="" S ER=1,RM="Enter a directory name." Q
	S Z=$$TRNLNM^%ZFUNC(X) S:Z'="" X=Z,ZZ=$$TRNLNM^%ZFUNC(Z) I $D(ZZ) S:ZZ'="" X=ZZ
	N IO
	S IO=X_"XXX.XXX"
	S Z=$$FILE^%ZOPEN(IO,"WRITE/NEWV",2) I 'Z S ER=1,RM="Invalid Directory"  C IO Q
	S BLKS=50000
	S DEVICE=$P(X,":",1)
	S Z=$$GETDVI^%ZFUNC(DEVICE,"FREEBLOCKS")
	I Z<BLKS S ER=1,RM="Not enough blocks on this disk. Choose another directory."
	K Z
	C IO
	S Y=$$SYS^%ZFUNC("DEL "_IO_";")
	Q
	;
