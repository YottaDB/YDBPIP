%ZRELPIN	;Private;Automated IBS release load
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/05/94 09:02:33 - SYSRUSSELL
	; ORIG:  CHENARD - 10/24/89
	;
	; This utility will handle the loading and installation of a
	; PROFILE/IBS Pre-release. It will  mount the tape containing
	; the RMS files for the release, check to determine that the cor-
	; rect version and release  id is being applied. It will then
	; load and install each project contained in the release, one
	; project at a time by calling a compiled program specific to
	; this release and version.
	;
	; Prior to loading,  the client must define the system logical
	; of the directory to where the RMS files are to be loaded and
	; stored. This directory will be assigned to the logical name
	; SCA$IBS_UPDATE. All RMS files from releases will be loaded in
	; to this directory and called from the application directory.
	;
	; During the release installation, custom projects will be loaded
	; only if the customer id is defined as SCA$CUS_ID. The compiled
	; release installation routine checks the value of this logical 
	; to determine whether or not a custom project will be loaded
	; at this client site.
	;
	N
INIT	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZT^%ZRELPIN")
	S %TO=99,VNM="",PRELID="",ER=0,%PG=0,%PAGE=1,%SYS=$$^%ZSYS
	D ^UTLO S TLO=UTLO
	S USERNAME=$$GETJPI^%ZFUNC($J,"USERNAME"),USERNAME=$$RTB^%ZFUNC(USERNAME)
	S %VN=$G(^CUVAR("%VN")) S:%VN=4 %VN="4.0" S VNM=$TR(%VN,".")
	D INT^%DIR I %SYS="GT.M" S %DIR=$P(%DIR,".",1),%DIR=%DIR_"]"
	S DIR=%DIR,RFLG=0
	S RELDIR=$$TRNLNM^%ZFUNC("SCA$IBS_UPDATE")
	I RELDIR="SCA$IBS_UPDATE"!(RELDIR="") W !,"Release directory not defined. Process aborted." Q 
	S X=$$TRNLNM^%ZFUNC(RELDIR) S:X'=""&(X'=RELDIR) RELDIR=X,XX=$$TRNLNM^%ZFUNC(RELDIR) S:$G(XX)'="" RELDIR=XX
	S CUS=$$TRNLNM^%ZFUNC("SCA$CUS_ID")
	I CUS="SCA$CUS_ID"!(CUS="") W !,"Client logical name not defined in SCA$CUS_ID. Process aborted." Q
	;
START	;
	S %HDG=$J("",8)_"PROFILE/IBS Software Release Installation Procedure - PRE-RELEASE"_$J("",7)
	S H1="               PROFILE/IBS Version: "_%VN
	S %READ="@%HDG#1,,,@H1#2",OLNTB=41,%NOPRMT="C"
	D ^UTLREAD
	S H2="Apply Pre-Release to Directory: "_DIR
	S %TAB("PRELID")="|6|||||D POSREL^%ZRELPIN||T| Enter the Pre-Release ID to Install "
	S %TAB("RDEL")="|1|||||||L|  Delete RMS files on Completion ",RDEL=0
	S %TAB("DEVICE")="|20|||||D POSDIR^%ZRELPIN||T|Device where release volumes are mounted "
	S %READ="@H2#2,,PRELID#1,,DEVICE,,RDEL"
	S OLNTB=5047
	D ^UTLREAD I VFMQ="Q" Q
	K %TAB,OLNTB
	S DATE=$$^%ZD($H),%TN=$P($H,",",2) D ^SCATIM1 S %TIM=%TS
	I %SYS="GT.M" S RTNDIR=$$MRTNS^%LNM
	W #,*27,*91,*63,*51,*108
	I DTYPE="TAPE" D TAPE
LOAD1	; load in the first RMS file from tape and verify info is correct
	S RELVER="V"_VNM_"PRELID."_PRELID
	S IO=RELDIR_RELVER
	S X=$$FILE^%ZOPEN(IO,"READ",2) I X'=1 W *7,"Error opening ",IO,". Release installation aborted." Q
	W !!,"Verifying release ID..."
	U IO R X C IO
	I X'=PRELID W *7,!!,"***Pre-Release ID entered to load does not match ID file in ",RELVER,!,"on ",DEVICE,". Installation aborted.***" S:DEV="TAPE" X=$$SYS^%ZFUNC("DISM "_TAPE) Q
	W " OK" H 3
	I ER Q
	S %TN=$P($H,",",2) D ^SCATIM1 S %TIM=%TS
	S H1=$J("",5)_"The following release will be applied to "_DIR
	S H2=$J("",30)_PRELID
	S H3=$J("",5)_"Beginning installation of PROFILE/IBS Pre-release "_PRELID_" at "_%TIM
	S H4="=========================================================================="
	S %READ="@%HDG#1,,,,@H1#2,,@H2,,,,@H3,@H4#0",%NOPRMT="C"
	D ^UTLREAD
	;
	I DTYPE="TAPE" D LOAD2
	D EXEC
	I $G(RFLG)=1 W *7,!!,"Installation aborted at " D ^%T H 3 Q
	I RDEL D RDEL
	S RPGM="PRE"_VNM_$E(PRELID,4,6) D DEL^%ZRTNDEL(RPGM)
	S $P(^CUVAR("PRELID"),"|",1)=PRELID
	S $P(^CUVAR("PRELID"),"|",2,5)=DATE_"|"_%TIM_"|"_USERNAME_"|"_TLO
	W !!,"*** PROFILE/IBS update to directory ",DIR," completed at " D ^%T W " ***"
	H 3
	Q
	;
	;
EXEC	; execute the compiled program to install release
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZT^%ZRELPIN")
	W !!,"Executing release installation program...",!!
	S IO="V"_VNM_"PRELID.PRE"_VNM_$E(PRELID,4,6)
	S IO=RELDIR_IO
	S X=$$FILE^%ZOPEN(IO,"READ",2) I X'=1 S RFLG=1 W !,"Error opening RMS file. Release aborted." Q
	I %SYS="GT.M" U IO R X,Y S DIRDEF=$$MRTNS^%LNM D EXT^%RI(IO,DIRDEF,"A",0,1,1) C IO
	I %SYS="M/VX" D ^%ZRELRI C IO
	S RPGM="PRE"_VNM_$E(PRELID,4,6)
	N DIR,ER,RDEL,RELVER,USERNAME,%TIM,DATE,TLO
	D ^@RPGM
	I $G(ER) S RFLG=1
	Q
	;
	;
TAPE	; load in files from tape TO SCA$IBS_UPDATE
	S RELDIR=$$TRNLNM^%ZFUNC("SCA$IBS_UPDATE")
	S TAPE=DEVICE
MOUNT	; mount the tape 
	S %PG=0,%PAGE=1,%NOPRMT="C"
	S H1=$J("",13)_"Mount the release tape onto the tape drive, "_TAPE
	S %TAB("CONT")="|1|||||||L|Are you ready ",CONT=0
	S %READ="@%HDG#1,,,@H1#0,,,CONT#1",OLNTB=40
	D ^UTLREAD 
	I 'CONT Q  G MOUNT
	W !!,"Mounting device ",TAPE,!
	S X=$$SYS^%ZFUNC("MOUNT/FOR "_TAPE) I X>1 W !,"Error mounting tape." G QUIT
	S X=$$SYS^%ZFUNC("BACKUP/LOG "_TAPE_"SCA.BCK "_RELDIR_"*.*")
	Q
LOAD2	; load the release RMS files to disk
	W !!,"Loading release RMS files to ",RELDIR,!!
	S X=$$SYS^%ZFUNC("BACKUP/LOG "_TAPE_"SCA.BCK "_RELDIR_"*.*")
	S X=$$SYS^%ZFUNC("DISM "_TAPE)
	W !!,"RMS files loaded at " D ^%T
	W !,"========================================================================="
	Q
	;
RDEL	; delete rms files upon completion of release update
	W !!,"Now deleting RMS files from ",RELDIR," ..."
	S X=$$SYS^%ZFUNC("DEL "_RELDIR_"V"_VNM_"PRE*.*;*")
	W " done."
	Q
	;
POSVNM	; post processor for version number
	I X'=%VN S ER=1,RM="This directory is version V"_VNM Q
	Q
	;
POSREL	; post processor for release id
	I X'?1"PRE"3N S ER=1,RM="Pre-Release ID must be in ""PREnnn"" format." Q
	S NUM=+$E(X,4,6),PNUM=$P($G(^CUVAR("PRELID")),"|",1),RNUM=+$E(PNUM,4,6)
	I NUM=RNUM S ER="W",RM="Pre-Release "_X_" has already been loaded. Are you sure you want to continue?"
	I NUM<RNUM S ER=1,RM="Last pre-release loaded was "_PNUM_". Cannot apply "_X_" subsequent to "_PNUM_"." Q
	Q
	;
POSDIR	; post processor for release directory
	S DEV=$$GETDVI^%ZFUNC(X,"DEVCLASS") I DEV=2 S DTYPE="TAPE" S ER="W",RM="Load from tape." Q
	S DTYPE="DISK" 
	S DEV=$$TRNLNM^%ZFUNC(X) S:DEV'="" X=DEV,DEVTR=$$TRNLNM^%ZFUNC(X) S:$G(DEVTR)'="" X=DEVTR
	I X'=RELDIR S ER=1,RM="Device "_X_" is not the defined name for SCA$IBS_UPDATE." Q
	;I X'=RELDIR,X'=DEV,$$TRNLNM^%ZFUNC(X)'=RELDIR S ER=1,RM="Device "_X_" is not the defined name for SCA$IBS_UPDATE." Q
	;I X'=RELDIR,X'=DEV S ER=1,RM="Directory "_X_" is not the defined name for SCA$IBS_UPDATE" Q
	S ER="W",RM="Load from disk."
	Q
	;
ZT	; log error and abort
	D ZE^UTLERR
	W !,"Release Installation Aborted on Error."
	Q
	;
QUIT	W !,"Release aborted on error."
	S ER=1
	Q
