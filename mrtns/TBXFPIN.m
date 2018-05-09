TBXFPIN	;;	Profile Software Installation Driver
	;
	; Original: Jim Joyce - 05/10/2001
	;
	; This routine is responsible for loading a Fix Pack into a Profile
	; runtime environment.
	;
	;--------- Revision History --------------------------------------------
	; 2009-06-12, CR40964, Jaywant Khairnar
	; 	* modified to support for automatic builds
	;	* call to TBXSPIN is replaced with call to TBXINST
	;
	; 2009-04-01, CR39019, Jaywant Khairnar
	;	* Rewritten to support more than two builds
	;	* Combined with (most of) TBXFPIN
	;
	; 2008-12-29, CR37328, Frans S.C. Witte
	;	* modified SQLLOOP to suppress calling a non-standard script.
	;
	; 2008-11-02, CR36017, Frans S.C. Witte
	;	* Removed TYPEINIT, and modified LOAD() to call
	;	  TYPEINIT^TBXSPIN().
	;	* Removed ERROR, and modified all callers to call ERROR^TBXSPIN.
	;	* Modified OBSLOOP to call OBSOBJ^TBXG and OBSOBJ^TBXDATA
	;	* Removed FTYPE-parameter from GBLLOOP (and callers)
	;
	; 2008-09-19, CR34458, Frans S.C. Witte
	;	Subroutines SFLOOP() rewritten to use new signature of
	;	LOAD^TBXSFILE(). Signatures of ELLOOP(), GBLLOOP(), PSLXLOOP(),
	;	RTNLOOP(), SFLOOP(), SQLLOOP(), TBLLOOP(), and their callers
	;	modified to pass the installation directory instead of relying
	;	on public variables.
	;
	; 09/08/2008	RussellDS CR 34458
	;		Set SRCPATH for use by TBXPROC(Changes to support 
	;		newest Framework release)
	;
	; 06/16/2008	RussellDS CR 34458
	;		Changes to support Framework 3.0
	;
	; 02/14/08	KWANL
	;		Enabled support for CDM
	;
	; 02/04/2008	KWANL
	;		Added ALL^DBMAP in load section.
	;
	;---------------------------------------------------------------------
	;
FPINST	; Fix Pack Install Prompt
	;---------------------------------------------------------------------
	; Fix Pack Directory - The directory where the Fix Pack has been 
	;	unzipped to. This will be a common directory for each server.
	;
	; Fix Pack to install - Fix pack build is requested.	
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
	; Display warning page
	D WARN()
	;
	N %READ,%TAB,DIRLIST,FP,HDG,INSTBUILD,INSTDIR,OWCUST,RES,$ZT
        ; 
	S HDG="Install Fix Pack"
	;
	S INSTDIR="/profile_release/fp"
	;
	S OWCUST=0
	S OWFIX=0
	;
	S %TAB("INSTDIR")=".INSTDIR/REQ/DES=Fix Pack Directory/TYP=T/LEN=80/XPP=D GETDIRS^TBXINST(X,.DIRLIST)"
	S %TAB("FP")=".INSTBUILD/REQ/DES=Fix Pack to install/TYP=T/LEN=80/TBL=DIRLIST(/XPP=S X=$$SPDIRS^TBXINST(X,.DIRLIST)"
	S %TAB("OWCUST")=".OWCUST/REQ/DES=Overwrite Customized DQ Elements/TYP=N/LEN=1/TBL=,0# Never overlay,1# Always overlay,2# Overlay with confirmation"
	S %TAB("OWFIX")=".OWFIX/REQ/DES=Overwrite Fix Pack Elements/TYP=I/LEN=1/TBL=,0# Never overlay,1# Always overlay,2# Overlay with confirmation"
	S %READ="@HDG/CEN/REV,,,INSTDIR,FP,OWCUST,OWFIX"
	D ^UTLREAD
	I VFMQ="Q" Q
	I '$D(^dbtbl) D  Q
	.	W !,"Abort! Global ^dbtbl is necessary for proper software installation.  It is not present in the run-time environment.  Please contact your Sanchez Client Support Analyst for information.",!
	.	;
	;
	S BUILDS(0)=FP  ; to have compatability with service pack installation
	;
	; builds the TBXBUILD global if not already available 
	;
	I '$D(^TBXBUILD) D CRTBXBLD^TBXINST() 
	;		
	S RES=$$install^TBXINST(.BUILDS,0,INSTDIR,OWCUST,OWFIX)
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
	S LINE1="You are about to load a fix pack into this Profile Runtime"
	S LINE2="Environment. All database and program files should be"
	S LINE3="backed-up before proceeding. If your terminal emulator supports"
	S LINE4="screen capture, we strongly recommended you enable it now."
	S LINE5="Refer to the Profile Software Installation Instructions for"
	S LINE6="more details on how to use this function."
	;
	S %READ="@HDG/CEN/REV,,@LINE1/CEN,@LINE2/CEN,@LINE3/CEN,@LINE4/CEN,,,@LINE5/CEN,@LINE6/CEN"
	D INQ^UTLREAD
	Q
	;
	;---------------------------------------------------------------------
