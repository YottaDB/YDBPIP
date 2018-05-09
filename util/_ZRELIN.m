%ZRELIN	;Private;Automated IBS release load
	;;Copyright(c)1995 Sanchez Computer Associates, Inc.  All Rights Reserved - 03/21/95 19:07:51 - JOYNER
	; ORIG:  CHENARD - 10/24/89
	;
	; This utility will handle the loading and installation of a
	; PROFILE/IBS release. It will  mount the tape containing the
	; files for the release, check to determine that the cor-
	; rect version and release  id is being applied. It will then
	; load and install each project contained in the release, one
	; project at a time by calling a compiled program specific to
	; this release and version.
	;
	; Prior to loading,  the client must define the system logical
	; of the directory to where the files are to be loaded and
	; stored. This directory will be assigned to the logical name
	; SCA$IBS_UPDATE. All files from releases will be loaded in
	; to this directory and called from the application directory.
	;
	; During the release installation, custom projects will be loaded
	; only if the customer id is defined as SCA$CUS_ID. The compiled
	; release installation routine checks the value of this logical 
	; to determine whether or not a custom project will be loaded
	; at this client site.
	;
	;---- Revision History ------------------------------------------------
	; 03/21/95 - JOYNER - 17212
	;	     Modified call to %EXIMP^DDPXFR, added var DIR to call.
	;	     Also added a definition for TJD to prevent another undef
	;	     in DDPXFR.
	;
	; 03/01/95 - DANTZER
	;	     Reset RELDIR to fix the undefined error.
	;	     Changed FEPLOAD to FEPLD, to match routine _ZRELEAS.
	;
	; 12/01/94 - JOYNER
	;	     Changed routine to check compiled pgm name length. If
	;	     length is > 8, then shorten relid to 2 digits. To shorten
	;	     name to 8 characters.
	;----------------------------------------------------------------------
INIT	N %TO,VNM,%VN,RELID,%PG,%PAGE,%SYS,UTLO,TLO,USERNAME,DIR,%DIR,RELDIR,CUS,IMAGE,RTNDIR
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZT^%ZRELIN")
	S %TO=99,VNM="",RELID="",ER=0,%PG=0,%PAGE=1,%SYS=$$^%ZSYS
	D ^UTLO S TLO=UTLO
	S USERNAME=$$USERNAM^%ZFUNC
	S %VN=$G(^CUVAR("%VN")) S:%VN=4 %VN="4.0" S VNM=$TR(%VN,".")
	D INT^%DIR S %DIR=$$CDIR^%LNM
	S DIR=%DIR,RFLG=0
	S RELDIR=$$TRNLNM^%ZFUNC("SCA_IBS_UPDATE")
	I RELDIR="" W !,"Release directory not defined. Process aborted." Q 
	S CUS=$$TRNLNM^%ZFUNC("SCA_CUS_ID")
	I CUS=CUS="" W !,"Client logical name not defined in SCA_CUS_ID. Process aborted." Q
	S RTNDIR=$$MRTNS^%LNM
	S IMAGE=$G(^CUVAR("IMAGE")) I IMAGE S RTNDIR=$$PRTNS^%LNM
	;
	;----------------------------------------------------------------------
START	; Begin processing
	;----------------------------------------------------------------------
	N %HDG,H1,H2,DEVICE,DATE,DTYPE,%TIM,%TS
	S %HDG=$J("",15)_"PROFILE/IBS Software Release Installation Procedure"_$J("",12)
	S H1="         PROFILE/IBS Version: "_%VN
	S %READ="@%HDG#1,,,@H1#2",OLNTB=45,%NOPRMT="C"
	D ^UTLREAD
	S H2="         Apply Release to Directory: "_DIR
	S %TAB("RELID")="|6|||||D POSREL^%ZRELIN||T|  Enter the Release ID to Install "
	S %TAB("RDEL")="|1|||||||L|   Delete files on Completion ",RDEL=0
	S %TAB("DEVICE")=$$IO^SCATAB
	S $P(%TAB("DEVICE"),"|",5)=""
	S $P(%TAB("DEVICE"),"|",7)="D POSDIR^%ZRELIN"
	S $P(%TAB("DEVICE"),"|",10)="Where are release volumes mounted"
	S %READ="@H2#2,,RELID#1,DEVICE,RDEL"
	S OLNTB=5036
	D ^UTLREAD I VFMQ="Q" Q
	K %TAB,OLNTB
	S DATE=$$^%ZD($H),%TN=$P($H,",",2) D ^SCATIM1 S %TIM=%TS
	W $$CLEAR^%TRMVT
	D TAPE
	;I DTYPE="TAPE" D TAPE
	;I DTYPE="DISK" D DISK
	;
	;----------------------------------------------------------------------
LOAD1	; load in the first file from tape and verify info is correct
	;----------------------------------------------------------------------
	N RELVER,IO
	S RELVER="V"_VNM_"RELID."_RELID
	S IO=RELDIR_RELVER
	W !!,"Verifying release ID..."
	; Get first file off of tape
	S X=RELID
	I X'=RELID W *7,!!,"***Release ID entered to load does not match ID file in ",RELVER,!,"on ",DEVICE,". Installation aborted.***" Q
	W " OK" H 2
	I ER Q
	S %TN=$P($H,",",2) D ^SCATIM1 S %TIM=%TS
	S H1=$J("",5)_"The following release will be applied to "_DIR
	S H2=$J("",30)_RELID
	S H3=$J("",5)_"Beginning installation of PROFILE/IBS release "_RELID_" at "_%TIM
	S H4="=========================================================================="
	S %READ="@%HDG#1,,,,@H1#2,,@H2,,,,@H3,@H4#0",%NOPRMT="C"
	D ^UTLREAD
	;
	D LOAD2
	D EXEC
	I $G(RFLG)=1 W *7,!!,"Installation aborted at " D ^%T Q
	I RDEL D RDEL
	;----------------------------------------------------------------------
	; *** grj 12/01/94 - Chk RPGM len, if >8 shorten relid to 2 chars
	S RPGM="REL"_VNM_$E(RELID,4,6)
	I $L(RPGM)>8 S RPGM="REL"_VNM_$E(RELID,5,6) 
	D DEL^%ZRTNDEL(RPGM)
	;----------------------------------------------------------------------
	S $P(^CUVAR("RELID"),"|",1)=RELID
	S $P(^CUVAR("RELID"),"|",2,5)=+$H_"|"_$P($H,",",2)_"|"_USERNAME_"|"_TLO
	W !!,"*** PROFILE/IBS update to directory ",DIR," completed at " D ^%T W " ***"
	W !,"    PROFILE Images being used MUST now be rebuilt."
	;
	; Load release at remote branches, if they exist
	S DIR=$$DIR^DDPUTL
	I DIR="" Q
	; *** 03/01/95 added set RELDIR to correct undefined error
	;              and changed fep name to match _ZRELEAS.
	S RELDIR=$$TRNLNM^%ZFUNC("SCA_IBS_UPDATE")	  ;*** DD 03/01/95
	I $D(^%ZDDP("DDP",DIR))>1 D
	.	S DDPFIL=RELDIR_"V"_VNM_"FEPLD."_RELID	  ;*** DD 03/01/95
	.	I $ZSEARCH(DDPFIL)="" Q
	.	N TJD S TJD=^CUVAR(2)			  ;*** GJ 03/21/95
	.	S ER=$$%EXIMP^DDPXFR(DDPFIL,DIR)	  ;*** GJ 03/21/95
	Q
	;
	;----------------------------------------------------------------------
EXEC	; execute the compiled program to install release
	;----------------------------------------------------------------------
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZT^%ZRELIN")
	W !!,"Executing release installation program...",!!
	S IO="V"_VNM_"RELID.REL"_VNM_$E(RELID,4,6)
	S IO=RELDIR_IO
	U IO R X,Y S DIRDEF=$$CRTNS^%LNM D EXT^%RI(IO,DIRDEF,"A",0,1,1) C IO
	;----------------------------------------------------------------------
	; grj 12/01/94 - Chk RPGM len, if >8 shorten relid to 2 chars
	S RPGM="REL"_VNM_$E(RELID,4,6)
	I $L(RPGM)>8 S RPGM="REL"_VNM_$E(RELID,5,6) 
	;----------------------------------------------------------------------
	N DIR,ER,RDEL,RELVER,USERNAME,DATE,%TIM,TLO,IMAGE
	D ^@RPGM
	I $G(ER) S RFLG=1
	Q
	;
	;
	;----------------------------------------------------------------------
TAPE	; load in files from tape TO SCA$IBS_UPDATE
	;----------------------------------------------------------------------
	S RELDIR=$$TRNLNM^%ZFUNC("SCA_IBS_UPDATE")
	S TAPE=DEVICE
	;----------------------------------------------------------------------
MOUNT	; mount the tape 
	;----------------------------------------------------------------------
	S %PG=0,%PAGE=1,%NOPRMT="C"
	S H1=$J("",13)_"Mount the release tape onto the tape drive, "_TAPE
	S %TAB("CONT")="|1|||||||L|Are you ready ",CONT=0
	S %READ="@%HDG#1,,,@H1#0,,,CONT#1",OLNTB=40
	D ^UTLREAD 
	I 'CONT Q  G MOUNT
	Q
	;
	;----------------------------------------------------------------------
LOAD2	; load the release files to disk
	;----------------------------------------------------------------------
	W !!,"Loading release files to ",RELDIR,!!
	;S X=$$SYS^%ZFUNC("cpio -icmduv <"_TAPE)
	;S X=$$SYS^%ZFUNC("sh </dev/rmt/0m")
	W !!,"files loaded at " D ^%T
	W !,"========================================================================="
	Q
	;
	;----------------------------------------------------------------------
DISK	; load files from disk
	;----------------------------------------------------------------------
	S RELDIR=$$TRNLNM^%ZFUNC(DEVICE)
	Q
	;
	;----------------------------------------------------------------------
RDEL	; delete rms files upon completion of release update
	;----------------------------------------------------------------------
	W !!,"Now deleting files from ",RELDIR," ..."
	S X=$$DELETE^%ZFUNC(RELDIR_"V"_VNM_"*.*")
	W " done."
	Q
	;
	;----------------------------------------------------------------------
POSVNM	; post processor for version number
	;----------------------------------------------------------------------
	I X'=%VN S ER=1,RM="This directory is version V"_VNM Q
	Q
	;
	;----------------------------------------------------------------------
POSREL	; post processor for release id
	;----------------------------------------------------------------------
	I X'?1"REL"3N S ER=1,RM="Release ID must be in ""RELnnn"" format." Q
	S NUM=+$E(X,4,6),PNUM=$P($G(^CUVAR("RELID")),"|",1),RNUM=+$E(PNUM,4,6)
	I NUM=RNUM S ER="W",RM="Release "_X_" has already been loaded. Are you sure you want to continue?"
	I NUM<RNUM S ER=1,RM="Last release loaded was "_PNUM_". Cannot apply "_X_" subsequent to "_PNUM_"." Q
	Q
	;
	;----------------------------------------------------------------------
POSDIR	; post processor for release directory
	;----------------------------------------------------------------------
	I $$TRNLNM^%ZFUNC(X)'="" S X=$$TRNLNM^%ZFUNC(X)
	S DTYPE="DISK" 
	S DEV=$$TRNLNM^%ZFUNC(X) S:DEV'="" X=DEV,DEVTR=$$TRNLNM^%ZFUNC(X) S:$G(DEVTR)'="" X=DEVTR
	I X'=RELDIR S ER=1,RM="Device "_X_" is not the defined name for SCA$IBS_UPDATE." Q
	S ER="W",RM="Load from disk."
	Q
	;
	;----------------------------------------------------------------------
ZT	; log error and abort
	;----------------------------------------------------------------------
	D ZE^UTLERR
	W !,"Release Installation Aborted on Error."
	Q
	;
	;----------------------------------------------------------------------
QUIT	W !,"Release aborted on error."
	;----------------------------------------------------------------------
	S ER=1
	Q
