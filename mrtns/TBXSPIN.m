TBXSPIN	;;	Profile Software Installation Driver
	;
	; Original: Jim Joyce - 05/10/2001
	;
	; This routine is responsible for loading Service and Fix
	; Packs into a Profile runtime environment.
	;
	;-------- Comments -----------------------------------------------------
	; Considerations for the the rewrite of TBXSPIN and TBXFPIN per CR39019
	; The routines TBXSPIN and TBXFPIN contain a lot of almost identical
	; code. As the fundamental structure of a Service Pack and a Fix Pack is 
	; identical, the code for their installation is fine tuned and made
	; common.
	; Another source of potentially unnessary complexity was the way in
	; which "framework" and "application" elements were processed and
	; stored. This did not invite adding additional layer such as a "custom"
	; layer.
	;
	; To reduce the complexity, and provide transparant support for multiple
	; layers of software, a separate TBXBUILD table is created, which maps
	; to ^TBXBUILD(PRIO) as follows: 
	;	PRIO : Priority of the build element with
	;		*  0 : Last fixpack installed
	;		* 10 : Framework element,
	;		* 20 : Application element
	;		* 30 : Custom element
	;	Piece info of ^TBXBUILD(PRIO)
	;	1 : Descriptive name of build (application, framework or custom)
	;	2 : project
	;	3 : view
	;	4 : build for service pack and CR number for fix pack
	;	5 : user
	;	6 : date
	;	7 : build status (0- sucessful,1- in progress,2- fatal error)
	; Just like the standard Framework Version 3 package structure, in which
	; the search order is: custom overwrites application overwrites
	; framework, the element with higher priority is getting installed.
	;
	;-------- Revision History ---------------------------------------------
	; 2009-06-12, CR40964, Jaywant Khairnar
	; 	* modified to support for automatic builds
	;	* call to TBXSPIN is replaced with call to TBXINST
	;
	; 2009-04-01, CR39019, Jaywant Khairnar
	;	* Rewritten to support more than two builds and for cleaner code
	;	* Combined with (most of) TBXFPIN
	;
	; 2008-12-29, CR37328, Frans S.C. Witte
	;	* modified SQLLOOP to suppress calling a non-standard script.
	;	* modified ERROR ("GTM..." now reads "%GTM ...")
	;
	; 2008-11-02, CR36017, Frans S.C. Witte
	;	* Modified OBSLOOP to call OBSOBJ^TBXG() for .G and
	;	  OBSOBJ^TBXDATA() for .DAT
	;	* Modified TYPEINIT to set routine for "G" to "TBXG"
	;	* Removed FTYPE-parameter from GBLLOOP (and callers)
	;	* Modified ERROR to look at $ZSTATUS or $ZERROR
	; 
	; 2008-09-19, CR34458,  Frans S.C. Witte
	;	* Subroutine SFLOOP() rewritten to use new signature of
	;	  LOAD^TBXSFILE().
	;	* Added comment and removed old revision history.
	;
	; 06/16/2008 - RussellDS CR 34458
	;	       Changes to support framework 3.0
	;
	; 02/14/2008	KWANL
	;		Enable support for CDM
	;
	; 02/04/2008	KWANL
	;		Fixed the LOAD section to build DBAMP when database type
	;		is not GTM.
	;
	; 01/09/2008	KWANL
	;		Modified the OBSLOOP section to remove the element from 
	;		^TBXFIX if it is already obsoleted by a FIXPACK.
	;
	;---------------------------------------------------------------------
SPINST	; Service Pack Install Prompt
	;---------------------------------------------------------------------
	; Release Directory - The directory where the Service Pack has been 
	;	unzipped to. This will be a common directory for each server.
	; Prompt for different builds - For service pack framework build,
	;	application build and custom build are requested.
	;
	; Prompt for Overwrite Customized DQ element- the installation program will
	;	* 0 - never overlay
	;	* 1 - always overlay
	;	* 2 - overlay with confirmation	
	;
	; Prompt for Overwrite Fix pack element- the installation program will
	;	* 0 - never overlay
	;	* 1 - always overlay
	;	* 2 - overlay with confirmation
	;
	N %READ,%TAB,BUILDS,DES,DIRLIST,INSTDIR,HDG,OPT,OWCUST,OWFIX,RES,VAR,initEnv,$ZT
	;
        s initEnv='$D(^DBTBL)	; initial environment for a empty shell is to be set
	;
	; if it is a empty shell
	;
	i initEnv d
	.	;
	.	s OWCUST=1
	.	s OWFIX=1
	.	w !,"Enter Service Pack Directory: (eg: /profile_release/sp)",!
        .	read INSTDIR
	.	;
	.	; An "initial environment" is "empty": is does not
	.	; contain routines or globals, so there will probably not
	.	; be a ^TBXBUILD global.
	.	; For an initial environment, we CREATE the ^TBXBUILD() nodes for 10,20 and 30. 
        .	;
        .	S VAR=""
        .	F PRIO=10,20,30 D
        ..		S ^TBXBUILD(PRIO)=$P("Framework;Application;Custom",";",PRIO/10)
        ..		S VAR="BUILDS("_PRIO_")" w !,"Enter "_$P(^TBXBUILD(PRIO),"|")_" Build to install: (eg: SP_Profile04_P04_DEV_01)",!
        ..		r @VAR
        ;
	e  d  Q:ER
	.	; Display warning page
	.	;
	.	D WARN()
	.	S HDG="Install Service Pack"
	.	;
	.	S INSTDIR="/profile_release/sp" 	; default installation directory for service pack
	.	S OWCUST=0,OWFIX=0			; default overlay paramters are false.
	.	;
	.	; We may need to address the initial conversion here as
	.	; well. If this is the first time that the "new" TBXSPIN
	.	; is called, ^TBXBUILD() will not exist. So we will need
	.	; to create it from ^TBXFIX and ^TBXINST.
	.	;
	.	I '$D(^TBXBUILD) D CRTBXBLD^TBXINST() 		; builds the TBXBUILD global if not already available
	.	;
	.	; Start at PRIO=0 to "skip" Fix Pack build
	.	S %TAB("INSTDIR")=".INSTDIR/REQ/DES=Service Pack Directory/TYP=T/LEN=80/XPP=D GETDIRS^TBXINST(X,.DIRLIST)"
	.	S PRIO=0,VAR=""
	.	F  S PRIO=$O(^TBXBUILD(PRIO)) Q:PRIO=""  S VAR=VAR_",BUILDS("_PRIO_")",DES=$P(^TBXBUILD(PRIO),"|"),%TAB("BUILDS("_PRIO_")")=".BUILDS("_PRIO_")/DES="_DES_" Build to install/TYP=T/LEN=80/TBL=DIRLIST(/XPP=S X=$$SPDIRS^TBXINST(X,.DIRLIST)"
	.	S %TAB("OWCUST")=".OWCUST/REQ/DES=Overwrite Customized DQ Elements/TYP=N/LEN=1/TBL=,0# Never overlay,1# Always overlay,2# Overlay with confirmation"
	.	S %TAB("OWFIX")=".OWFIX/REQ/DES=Overwrite Fix Pack Elements/TYP=I/LEN=1/TBL=,0# Never overlay,1# Always overlay,2# Overlay with confirmation"
	.	S %READ="@HDG/CEN/REV,,,INSTDIR"_VAR_",OWCUST,OWFIX"
	.	D ^UTLREAD				; reads the screen input	
	.	I VFMQ="Q" S ER=1 Q
	.	;
	;
	; check for no builds specified for install
	;
	S PRIO="",ER=1
	F  S PRIO=$O(BUILDS(PRIO)) Q:(PRIO="")!(ER=0)  D
	.	I BUILDS(PRIO)'="" S ER=0
	S:ER=1 RM="Please specify a build to install."
	I ER W !,RM,! Q  
	;
	i 'initEnv d 	
	.	; Note that ^TBXREJ is not relevant for FP Install.
	.	;
	.	I '$D(^dbtbl) W !,"Abort! Global ^dbtbl is necessary for proper software installation.  It is not present in the run-time environment.  Please contact your Sanchez Client Support Analyst for information.",! S ER=1 Q
	.	; removes the previously rejected file entries from ^TBXREJ
	.	I $D(^TBXREJ) I '$$PROMPT^TBXINST("Please resolve all rejects before installing a new build. Continue?") S ER=1 Q
	.	I $D(^TBXREJ) I '$$PROMPT^TBXINST("Continue will remove all rejects from the Reject Global. Continue?") S ER=1 Q
	.	K ^TBXREJ
	Q:ER
	;
	; external call for installation
	;
	S RES=$$install^TBXINST(.BUILDS,initEnv,INSTDIR,OWCUST,OWFIX)
	;
	Q
	;
	;---------------------------------------------------------------------
WARN()	; Preach about the use of backups, screen captures use of caution
	;---------------------------------------------------------------------
	;
	N %READ,%NOPRMT,HDG,LINE1,LINE2,LINE3,LINE4,LINE5,LINE6
	;
	S HDG="NOTICE"
	S LINE0="  ***   YOU ARE IN "_$ZDIR_"   ***"
	S LINE1="You are about to load a full build into this Profile Runtime"
	S LINE2="Environment. All database and program files should be"
	S LINE3="backed-up before proceeding. If your terminal emulator supports"
	S LINE4="screen capture, we strongly recommended you enable it now."
	S LINE5="Refer to the Profile Software Installation Instructions for"
	S LINE6="more details on how to use this function."
	;
	S %READ="@HDG/CEN/REV,,@LINE0/CEN,@LINE1/CEN,@LINE2/CEN,@LINE3/CEN,@LINE4/CEN,,,@LINE5/CEN,@LINE6/CEN"
	D INQ^UTLREAD
	Q
	;
	