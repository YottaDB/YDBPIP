TBXDQUTL;Private;DQ	UTILITIES 
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/09/02 16:35:27 - KWANL
	; ORIG:	KWANL - 05/02/02
	; DESC:	DQ UTILITIES
	;
	; KEYWORDS:	
	;
	; INPUTS:
	;	. System	
	;
	;	. Data	[ddfile]di
	;  
	;	. v1	desc of variable	/TYP=T
	;
	; RETURNS:
	;	. XX	desc of return		/TYP=T
	;
	; RELATED:
	;	. $$func^rtn - description of how related
	;
	; EXAMPLE:
	;	Text of example (line one)
	;
	;--------- Revision History ------------------------------------------
	; 10/31/2006	Frans S.C. Witte
	;		Added NEW ER,RM in loop that compiles the filers,
	;		because these variables may be returned by COMPILE^DBSFILB
	;		which would screw up the ER and RM maintained by TBX*.
	;
	; 10/23/2006	Frans S.C. Witte
	;		Modified COMPFRW to compile filers specified for "phase2"
	;
	; 03/17/2006	KWANL
	;		Modified runpgm section not to pass crtns so that *.proc
	;		can be removed.
	;
	; 01/17/2006	KWANL
	;		Commented out the check for ^TMPDQC(J) in COMPALL section.
	;		To allow PSL upgrade continue.
	;
	; 12/22/2005	Pete Chenard
	;		Added third parameter to logmsg section to allow 
	;		an option to suppress messages to the screen.
	;		Since all messages go to the log file, most screen
	;		output is noise.  This change allows for the 
	;		ability to only write errors to the screen, which
	;		wil make sorting through the capture file for 
	;		errors easier.
	;
	; 10/03/2005	Lik Kwan
	;		Added UPGRADE, COMPPSL and COMPFRW to handle PSL or framework upgrade.
	;		The entry point is UPGRADE which is added to ZENT after the ZDELETE.
	;		Added a GETVAR to read variable from a text file called release.dat.
	;		The GETVAR will only be called when it is in a initial environment where 
	;		when CUVAR is not setup.
	;		Removed call to UTLERR. Instead of logging the error to ERROR global, we will
	;		only log to a log file.
	;		ZLINK UCGMCU in ZENT section
	;		
	; 06/02/2005	Lik kwan
	;		Modified to skip Xref, sort definitions, open oracle connection,
	;		and rebuild DBMAP(full rebuild) for Profile version 7.0 or above.
	;
	; 04/26/2005	MBUIM CR 14804
	;		Modified sections outil, odifd and COMPALL to
	;		initialize system variables.
	;
	; 02/10/2005	Lik Kwan
	;		Fixed ofile section to use %LIBS instead of SYSDEV.
	;
	; 12/08/2004	Lik Kwan
	;		Use SQL call to remove file definitions.
	;
	; 09/10/2004	Lik Kwan
	;		Remove the obsolete entry from ^TMPDQC in ZDELETE section.
	;
	; 08/24/2004	Lik Kwan
	;		Removed review reject message.
	;
	; 07/09/2004	Lik Kwan
	;		Fixed hang problem due to error trap. Move error trap for each
	;		procudure definition instead of a batch. Rearrange compile order
	;		based on Diane's list. Enabled purge SQL cache.
	;
	; 12/22/2003	Lik Kwan
	;		Modified for Profile 7.0. Changed to compile report, screen,
	;		batch, and procedure in a small batch to prevent out of memory.
	;
	; 09/25/2003	Lik Kwan
	;		Zlink "UTLERR" before DQ compile to prevent the process hangs 
	;		during DQ compile if it is out of memory.
	;
	; 09/03/2003	Lik Kwan
	;		Rewrote FIXCCHR section.
	;		Added error trap to handle error during DQ compile so
	;		that it will not exist to command prompt if there is any problem.
	; 
	; 05/28/2003	Lik Kwan
	;		Replace %ZCHKDIR with a local call CHKDIR.
	;		Added CHKDIRU to check directory in Unix and 
	;		CHKDIRV to check directory in VMS. Changed CHKDIR to CHKDIRX. 
	;
	; 12/05/2002	Lik Kwan
	;		Remove implicit, rmcrtn, and filenx section. Modify runpgm
	;		to remove run-time program from crtns directory.
	;		Added messages.
	;
	; 10/12/2002	Lik kwan
	;		Modified the ZDELETE section to remove foreign keys.
	;
	; 10/03/2002	Lik Kwan
	;		Added CHKDIR section to check if directory exists if not 
	;		create it.
	;
	;-----------------------------------------------------------------------
	Q
	;-----------------------------------------------------------------------
CKDTUSR(COREDATE,COREUSER,CUSTDATE,CUSTUSER,NEWDATE,NEWUSER)	; Check element
	; date and user for customization
	;-----------------------------------------------------------------------
	;
	; No lower case dbtbl
	I COREDATE="" Q 1
	;
	; Upper and lower match
	I (COREDATE=CUSTDATE),(COREUSER=CUSTUSER) Q 1
	;
	; Compare date stamp between released elements and ^DBTBL
	I (NEWDATE=CUSTDATE)&(NEWUSER=CUSTUSER) Q 1 
	;
	; Element has been customized, return date and user 
	Q "0|"_CUSTDATE_"|"_CUSTUSER
	;
	;-----------------------------------------------------------------------
CPYARR(CODE,LEVEL,NAME,KEY);	Copy a DQ element into an array. 
	; The following section is only valid for DQ levels: 2,4,5,9,10,13,16,17,18
	; DQ level 1,1.9,3,7,8,12,25,33 are handle differently 
	;-----------------------------------------------------------------------
	;
	N REF,SRC
	I $G(KEY)'="" S SRC="^DBTBL(""SYSDEV"","_LEVEL_","""_NAME_""","_""""_KEY_""")"
	E  S SRC="^DBTBL(""SYSDEV"","_LEVEL_","""_NAME_""")"
	;
	S REF=$S(SRC["(":$E(SRC,1,$L(SRC)-1),1:SRC)
	I $D(@SRC)#10 D  
	.  I LEVEL'=9 D ONENODE(LEVEL,NAME) Q
	.  E  D ONENODE(LEVEL,NAME,KEY)
	F  S SRC=$q(@SRC) q:(SRC="")!($E(SRC,1,$l(REF))'=REF)  D  
	.  I LEVEL'=9 D ONENODE(LEVEL,NAME) Q
	.  E  D ONENODE(LEVEL,NAME,KEY)
	;
	Q
	;
	;-----------------------------------------------------------------------
ONENODE(TYPE,NAME,KEY)	;  Copy a single global node. 
	;----------------------------------------------------------------------- 
	; 
	N DATA,POS
	S DATA=@SRC
	I (TYPE=2)!(TYPE=5) D
	. 	I SRC=("^DBTBL(""SYSDEV"","_TYPE_","""_NAME_""",0)") D
	.. 	S $P(DATA,"|",2)="",$P(DATA,"|",3)="",$P(DATA,"|",15)=""	; remove program name,date,user name
	I (TYPE=4) D
	. 	I SRC=("^DBTBL(""SYSDEV"","_TYPE_","""_NAME_""",0)") D
	.. 	S $P(DATA,"|",2)="",$P(DATA,"|",3)="",$P(DATA,"|",15)=""	; remove date,user name
	I (TYPE=13) D
	. 	I SRC=("^DBTBL(""SYSDEV"","_TYPE_","""_NAME_""",0)") D
	.. 	S $P(DATA,"|",3)="",$P(DATA,"|",15)=""				; remove date,user name
	I (TYPE=9) D
	. 	I SRC=("^DBTBL(""SYSDEV"","_TYPE_","""_NAME_""","""_KEY_""")") D
	.. 	S $P(DATA,"|",9)="",$P(DATA,"|",10)="",$P(DATA,"|",14)=""
	I (TYPE=16) D
	. 	I SRC=("^DBTBL(""SYSDEV"","_TYPE_","""_NAME_""")") D
	.. 	S $P(DATA,"|",2)="",$P(DATA,"|",4)="",$P(DATA,"|",5)=""
	I (TYPE=17) D
	. 	I SRC=("^DBTBL(""SYSDEV"","_TYPE_","""_NAME_""")") D
	.. 	S $P(DATA,"|",2)="",$P(DATA,"|",3)=""
	I (TYPE=18) D
	. 	I SRC=("^DBTBL(""SYSDEV"","_TYPE_","""_NAME_""")") D
	..  	S $P(DATA,"|",5)="",$P(DATA,"|",6)=""
	I (TYPE=22) D
	. 	I SRC=("^DBTBL(""SYSDEV"","_TYPE_","""_NAME_""")") D
	.. 	S $P(DATA,"|",4)=""						; remove program name
	I DATA="" S CODE($O(CODE(""),-1)+1)=""_SRC_"="_"""""" Q
	I DATA?.E1C.E D  Q								; if the string contains controler char
	.	S CODE($O(CODE(""),-1)+1)=""_SRC_"="_$$FIXCCHR(DATA)
	I DATA?.N D  Q
	.	S CODE($O(CODE(""),-1)+1)=""_SRC_"="_DATA
	S CODE($O(CODE(""),-1)+1)=""_SRC_"="_$$QADD^%ZS(DATA)
	Q 
	; 	
	;-----------------------------------------------------------------------
CP(src,tgt,nix)	;  Copy global (subtree). 
	;----------------------------------------------------------------------- 
	;  This is a simplified global copy program that is able to copy a 
	;  global [subtree] from one global to another one.  However, the 
	;  structure and levels will be the same in both globals, i.e. one 
	;  cannot copy a global subtree of the source global into another 
	;  place in the target global (like the MERGE command can do). 
	; 
	;  So, in other words, only the target global name can be specified. 
	; 
	n cnt,org,ref 
	s cnt=0,org=$s(src["(":$e(src,1,$l(src)-1),1:src) 
	k:+$g(nix) @tgt 
	; 
	s ref=$s(src["(":tgt_"("_$p(src,"(",2,$l(src,"(")),1:tgt) 
	k @ref 
	; 
	i $d(@src)#10 d cnode 
	f  s src=$q(@src) q:(src="")!($e(src,1,$l(org))'=org)  d cnode 
	q cnt 
	; 
	;-----------------------------------------------------------------------
cnode	;  Copy a single global node. 
	;----------------------------------------------------------------------- 
	;
	s ref=$s(src["(":tgt_"("_$p(src,"(",2,$l(src,"(")),1:tgt),@ref=@src,cnt=cnt+1 
	q 
	; 
	;=======================================================================
	;  The following code is taken from the old kit pre-processor routine.
	;-----------------------------------------------------------------------
	;***********************************************************************
dqobso(lib,typ,elm,ISVMS,zlogf)	
	; Purpose: Use DQ Utility to obsolete DQ element.
	;
	; NOTE: Current DATA-QWIK level definition is as followed:
	; level		description
	; 0		library being used
	; 1		file definition
	; 2		screen definition
	; 3		sort definition
	; 4		query definition
	; 5		report definition
	; 6		qwik-report definition
	; 8		index file definition
	; 9		journal file definition
	; 10		pre/post-processor filer definition
	; 11		data item documentation
	; 12		table value documentation
	; 13		pre/post-processor library
	; 14		data item protection definition
	; 16		data item exchange definition
	; 20		data item index file
	; 22		aggregate definition
	; 25 		procedure definition
	; 33		batch definition
	;
	; The DQTA-QWIK obsolete process is defined as followed:
	; 1) remove implicit definition.
	; 2) remove associated application program.
	; 3) remove DATA-QWIK element from database.
	;***********************************************************************
	n (lib,typ,elm,ISVMS,zlogf)
	i '$D(^DBTBL(lib,typ,elm)) q						; nothing to obsolete
	d implicit(lib,typ,elm)                                                 ; remove implicit first
	d runpgm(lib,typ,elm)
	;									; remove run time program
	I (typ=1) d ofile q							; obsolete file definition
	;
	; I typ=8 d odifd(lib,typ,elm) q					; obsolete index file definition
	;
	I (typ>1)&(typ<7)!(typ=13) d outil					; rm index for screen,sort,query,report,qwik,pplib
	q
	;
implicit(lib,typ,elm)	
	;*********************************************************************** 
	; Purpose: Remove implicit because DQ element is no longer valid. 
	;*********************************************************************** 
	n zxlib,zimp 
	s zxlib=""                                                              ; go through all library 
	f  s zxlib=$O(^DBTBL(zxlib)) q:zxlib=""  d                              ; get library name 
	. i zxlib=lib q                                                         ; skip checking the current library 
	. i typ=1 s zimp=$P($G(^DBTBL(zxlib,typ,elm,10)),"|",5)                 ; check node 10 piece 5 for file def 
	. e  s zimp=$G(^DBTBL(zxlib,typ,elm,-3))                                ; check node -3 for screen and report 
	. i zimp[lib k ^DBTBL(zxlib,typ,elm)                                    ; if implicit then kill it 
	q 
	; 
runpgm(lib,typ,elm)	
	;***********************************************************************
	; Purpose: Remove run time program associated with DQ element.
	; Note: Only file, screen, sort, report, protection, and data item
	;	exchange definitions have run time programs.
	;***********************************************************************
	n rname
	s rname="VP01"								; this has some purpose, don't set it to null
	;
	i typ=1 s rname=$P($G(^DBTBL(lib,typ,elm,99)),"|",2)			; file definition
	i (typ=2)!(typ=5) s rname=$P($G(^DBTBL(lib,typ,elm,0)),"|",2)		; screen, sort, report definition
	i (typ=3)!(typ=16) s rname=$P($G(^DBTBL(lib,typ,elm)),"|",2)		; record map,filer executive definition
	i typ=14 s rname=rname_$P($G(^DBTBL(lib,typ,elm,99)),"|",2)		; protection definition
	i (typ=25)!(typ=33) s rname=$P($G(^DBTBL(lib,typ,elm)),"|",2)		; procedure,batch definition
	i (rname="")!(rname="VP01") q						; no routine to delete
	d logmsg("Removing run time program : "_rname_" from crtns.",zlogf)
	d DEL^%ZRTNDEL(rname)							; delete routine
	i typ=5 d								; report may have sort and stat routine
	. s rname=$TRANSLATE(rname,"S","Z")					; get sort routine name
	. d logmsg("Removing run time program : "_rname_" from crtns.",zlogf)
	. d DEL^%ZRTNDEL(rname)							; delete sort routine
	. s rname=$TRANSLATE(rname,"Z","T")					; get stat routine name
	. d logmsg("Removing run time program : "_rname_" from crtns.",zlogf)
	. d DEL^%ZRTNDEL(rname)							; delete stat routine
	q
	;
ofile	;***********************************************************************
	; Purpose: Obsolete file definitions.
	; 10/3/2005 lk. Use drop table command to delete RDB table if database 
	; is not GTM.
	;***********************************************************************
	n (lib,typ,elm,zlogf)						; refresh stack - make sure it's clean
	d logmsg("Removing file definitions : "_lib_"."_typ_"."_elm,zlogf)
	s %LIBS=lib,FID=elm							; set up variables for PROFILE
	; d @"^DBSDF1F(3)"
	S ER=$$^SQL("DELETE DBTBL1 WHERE %LIBS=:%LIBS AND FID=:FID")
	I ER D
	. d logmsg("Error removing file defintion. SQL error code : "_ER)
	q									; done
	;
outil	;***********************************************************************
	; Purpose: Call delete data item index utility.
	; Assume:  PROFILE recognizes the following variables for processing:
	;	   %LIBS = library
	;	   DBOPT = DQ type
	;	   ID    = DQ element name
	;	   DQFUN = function - "D" is used here for delete
	; The statement n (lib,typ,elm) is used to clear all local variables.
	;***********************************************************************
	n (lib,typ,elm,zlogf)	
	d SYSVAR^SCADRV0()						; refresh the stack - make sure it's clean
	d logmsg("Removing data item index : "_lib_"."_typ_"."_elm,zlogf)
	s %LIBS=lib,DBOPT=typ,ID=elm,DQFUN="D"					; set up variables for PROFILE
	d ^DBSUTL3								; actual call to delete
	q									; done
	;
	;***********************************************************************
odifd(lib,typ,elm,INDEXNM);	
	; Purpose: Delete index file definition.
	; Assume: PROFILE recognizes the following variables for processing:
	;	  %LIBS = library
	;	  FID   = index definition
	;	  INDEXNM = index name
	;	  fDBTBL8 = index info
	; This will obsolete index file one at a time.
	;***********************************************************************
	Q		; not used 
	n (lib,typ,elm,INDEXNM)							; refresh the stack - make sure it's clean
	n fDBTBL8
	d SYSVAR^SCADRV0()
	d logmsg("Removing index file definition : "_lib_"."_typ_"."_elm_"."_INDEXNM,zlogf)
	S fDBTBL8=$G(^DBTBL(lib,8,elm,INDEXNM))	
	S %LIBS=lib,FID=elm
	d ^DBSINDXF(3)							; actual call to delete index
	q
	;
appdir(tgt,dir)	;  Append directory specifications.
	;
	n x,isvms
	;
	S isvms=($P($ZVER," ",3)="VMS")
	i isvms s x=$e(tgt,1,$l(tgt)-1)_$tr(dir,"[",".")
	e  s:$e(tgt,$l(tgt))="/" tgt=$e(tgt,1,$l(tgt)-1) s x=tgt_$tr(dir,"[.]","///")
	;
	q x
	;
	;-----------------------------------------------------------------------
COMPALL	; 
	; ORIG:	LYH - 05/12/95
	; DESC:	DQ Compilation at Target Area
	;	Attempt to automate the task of recompiling, building implicit,
	;	index, etc... files at the target area.
	;	DQ Level	Action Required
	;	1,7,8,9,19	build filer
	;	1		data item control,implicit,index
	;	2		recompile screen
	;	3		compile executive routine
	;	5		recompile report
	;	14		build data item protection logic
	;	1,13		recompile all related screens and reports
	;	16		recompile record exchange definitions
	;	22		recompile aggregate definitions
	;       25              recompile procedure routine
	;
	;	This routine depended on the DQ utilities at the target node.
	;	If changes to these utilities are not reflected here, we may
	;	reference an undefined label when placing actual call to
	;	compile DQ elements, and we will ultimately crash. In that 
	;	case, we will have to manually set the LRQ status to 4 or 5,
	;	depending on whether every element in the LRQ has been
	;	libraried, or not.
	;	This routine is called by DQ_COMPILE.COM
	;-----------------------------------------------------------------------
	;
	N cmd,ok,sid2,vpos,x,y,blogf
	;
	I '$G(db) s db=$$TRNLNM^%ZFUNC("SCAU_DB")
	;I '$D(^TMPDQC($J)) d logmsg("No DataQwik found to compile.",zlogf) q ; exit
	i $$NEW^%ZT n $ZT                               ; set up error trap
	s @$$SET^%ZT("PPSER^TBXDQUTL")			; to execute line tag PPSER
	d init						; system var
	;
	d ZENT						; process DQ elements 
	d ZMDD 						; Rebuild MDD index file
	; *** by ZCL - 07/09/1999 - build xref for file definitions
	d:'dqvn7 logmsg("Building xref for file definitions......",zlogf)
	d:'dqvn7 ADD^DBSINDXZ("DBTBL1")
	d:'dqvn7 ZFEP					; set up auto FEP transfer
	d done						; clean up
	q
	;
	;
init	;***********************************************************************
	; Purpose: Initialize variables to be used in post-processor
	;***********************************************************************
	; !!! Use date from last revision history entry !!!
	;
	s $p(zline,"*",50)=""
	d logmsg(zline,zlogf)
	d logmsg("DATA-QWIK compilation begins ",zlogf)
	d logmsg(zline,zlogf)
	d logmsg("Routine search list: "_$zro,zlogf)
	d logmsg("Init I18n edit mask",zlogf)  		; *** 03/27/97
	; d ^DBSINIT1  					; ***
	d logmsg("Init system variables.",zlogf)
	; d SYSVAR^SCADRV0("PBS")				; init system variable (V50 only)
	d logmsg("You are in directory: "_$$SCAU^%TRNLNM("DDPLOG"),zlogf)
	d logmsg("DATA-QWIK version: "_dqv,zlogf)
	S:'$D(ISVMS) ISVMS=($ZVER["VMS")
	i $D(^TMPREL($J)) k ^TMPREL($J)
	i $D(^TMPXFR($J)) k ^TMPXFR($J)
	d logmsg("ISVMS: "_ISVMS,zlogf)
	s blogf=$$SCAU^%TRNLNM("SPOOL","BATCH_"_$P($H,",")_"_"_$P($H,",",2)_".LOG")
	q
	;
done	;***********************************************************************
	; Purpose: Clean up temp global and close log file.
	;***********************************************************************
	i $D(^TMPDQC($J)) k ^TMPDQC($J)						; clean up
	i $D(^TMPREL($J)) k ^TMPREL($J)
	i $D(^TMPXFR($J)) k ^TMPXFR($J)
	i $D(^TEMP($J)) k ^TEMP($J)
	i $D(^TMP($J)) k ^TMP($J)
	d logmsg("Dataqwik compile completed",zlogf)
	d logmsg("",zlogf)
	q									; all done
	;
logmsg(str,logf,supr);	
	;***********************************************************************
	; Purpose: Log message to screen and log file.
	;***********************************************************************
	; Arguments:
	;	str	Text to be logged.  NOREQ/MECH=VAL
	;	logf	Log file name.	    REQ/MECH=VAL
	;	supr	Supress output to screen.	NOREQ/MECH=VAL
	;
	i $D(logf),logf'=0 u logf w $ZD($H,"DD-MON 24:60"),"  ",str,!	; write message to log file
	;quit:$G(supr)
	u 0 w !,$ZD($H,"DD-MON 24:60"),"  ",str,!
	q									; done
	;
ZENT	;***********************************************************************
	; Purpose: Process DQ elements at target directory
	;***********************************************************************
	;
	ZLINK "UCGMCU"
	;
	d ZXCACHE				; Purge SQL cache table
	d ZDELETE				; obsolte DQ elements
	d UPGRADE
	I '$D(^TMPDQC($J)) d logmsg("No DataQwik found to compile.",zlogf) q ; nothing to compile
	d ZPPP					; rebuild pre/post-processor index file
	d initproc
	d ZCTL					; rebuild data item control file
	d ZPROC					; build procedure routine - 25
	d ZFIL					; compile filer routine - 1,7,8,9
	d ZDPL					; rebuild data item protection logic
	d ZDIX					; rebuild data item cross reference file
	d ZTBL					; build table index
	d ZSCR					; compile screen -2
	d ZREP					; compile report - 5
	d:'dqvn7 ZREX				; Compile record exchange - 16
	d ZAGG					; Compile aggregate - 22
	d ZBAT					; Compile batch - 33 *** by ZCL - 07/01/98
	d:'dqvn7 ZEXC				; build executive routine - 3
	; d ZAUT				; build authorization file
	q					; done
	;
	;----------------------------------------------------------------------
ZXCACHE	; Purge SQL cache table 
	;----------------------------------------------------------------------
	Q:($G(initEnv)=1)
	if $G(db)="ORACLE" K ^DBTBLSP
	Q:($G(db)="ORACLE")
	d logmsg("Purge SQL cache table",zlogf)
	d PURGE^SQLCACHE
	q
	;***********************************************************************
ZDELETE	; Purpose: Delete DQ elements 
	;***********************************************************************
	Q:($G(initEnv)=1)
	N lib,lev,elem
	S (lib,lev,elem)=""
	F  s lib=$O(^TMPDQC($J,lib)) Q:lib=""  F  s lev=$O(^TMPDQC($J,lib,lev)) q:lev=""  D
	.	F  S elem=$O(^TMPDQC($J,lib,lev,elem)) Q:elem=""  D
	..		I $G(^(elem))'=-1 Q
	.. 		D dqobso(lib,lev,elem,ISVMS,zlogf)
	..		K ^TMPDQC($J,lib,lev,elem)
	..		K ^DBTBL(lib,lev,elem)
	..		K ^dbtbl(lib,lev,elem)
	Q
	; *** by ZCL - 07/01/98
ZBAT	;***********************************************************************
	; Purpose: Compile batch - 33
	;***********************************************************************
	n lib,elem
	s elem=""
	s lib=""  
	K:$D(^TEMP($J)) ^TEMP($J) 
	f  s lib=$O(^DBTBL(lib)) q:lib=""  d                                    ; go through each library 
	. i lib="PRD" q 
	. i $D(^TMPDQC($J,lib,33)) d
	.. d logmsg("***** Compiling batch routine in "_lib_".",zlogf)
	.. f  s elem=$O(^TMPDQC($J,lib,33,elem)) q:elem=""  d                 ; check for modified batch in this release
	... S ^TEMP($J,elem)=""
	.. d bat
	.. d appfile(blogf,zlogf)
	.. d logmsg("***** Done compiling batch routine "_lib_".",zlogf)
	q
	;
	;***********************************************************************
bat	; Purpose: place a call to build procedure in a smaller batch
	;***********************************************************************
	; keep calling batch until ^TEMP($J) is exhausted
	s stat=$$batch(lib,33,ISVMS)						; compile in small batch of 100
	i stat'=1  k ^TEMP($J) q						; error - forget it, no more compile
	i $D(^TEMP($J)) g bat							; no error - process next 100
	q									; done
	;
	;**********************************************************************
cbat	; Purpose: place a call to build procedure
	;**********************************************************************
	N elem,$ZT
	;
	;
	d LOGF(.blogf,"APPEND")
	s elem="" f  s elem=$O(^TEMP($J,elem)) q:elem=""  d
	. d logmsg("Compiling batch "_elem_" in library "_%LIBS_".",blogf)
	. S @$$SET^%ZT("PPSER2^TBXDQUTL")
	. d COMPILE^DBSBAT(elem)
	. d logmsg("Done compiling batch "_elem_" in library "_%LIBS_".",blogf)
	c blogf
	Q	
	;
ZSCR	;***********************************************************************
	; Purpose: Compile screen.
	;***********************************************************************
	n lib
	s lib=""
	f  s lib=$O(^DBTBL(lib)) q:lib=""  d					; go through each library
	. i lib="PRD" q
	. d getall(lib,2)							; get screens to compile
	. i '$D(^TEMP($J)) q							; nothing to compile
	. d logmsg("Compiling screens",zlogf)
	. d zsmc(lib)								; compile screens for this library
	. k ^TEMP($J)								; clean up
	. d logmsg("Done compiling screens",zlogf)
	q									; done
	;
getall(lib,level)	
	;***********************************************************************
	; Purpose: Build screen name in ^TEMP($J) global.
	;***********************************************************************
	n elem,ppp,type,xlib,master
	i $D(^TEMP($J)) k ^TEMP($J)						; init
	i $D(master) k master
	s elem="",ppp="",xlib=""
	f  s xlib=$O(^TMPDQC($J,xlib)) q:xlib=""  d
	. f type=1,13 d								; check for file and pre/post processor
	.. f  s ppp=$O(^TMPDQC($J,xlib,type,ppp)) q:ppp=""  d			; get name of modified element
	... i type=1 d relate(lib,ppp,level)					; any screen related to this modified file?
	... i type=13 d prelate(lib,ppp,level)					; any screen related to this modified ppp?
	i $D(^TMPDQC($J,lib)) d
	. i level=2 d getmscr(lib)						; build array of all master screens in this library
	. f  s elem=$O(^TMPDQC($J,lib,level,elem)) q:elem=""  d			; check for modified screen in this release
	.. i $G(^(elem))=-1 Q  							; Obsoleted element
	.. i '$D(^TEMP($J,elem)) s ^TEMP($J,elem)=""				; save screen name
	.. i level=2,$D(master(elem)) d						; if this screen has a master screen
	... i '$D(^TEMP($J,master(elem))) s ^TEMP($J,master(elem))=""		; save master screen
	... s ^TMPREL($J,lib,level,master(elem))=""				; set up for DDPXFR
	q									; done
	;
relate(lib,ppp,level)	
	;***********************************************************************
	; Purpose: If data item changed recompile related screen/report
	;***********************************************************************
	n item,elem,fid
	s item="",elem=""
	s fid=$P(ppp,".",1),item=$P(ppp,".",2)	; *** 02/21/97 fid or fid.di format
	I item'="" D relate1 Q
	f  s item=$O(^DBINDX(lib,"DI",level,fid,item)) q:item=""  d relate1      ; look through all data items in the index
	Q
relate1	; 
	f  s elem=$O(^DBINDX(lib,"DI",level,fid,item,elem)) q:elem=""  d	; get screen or report
	. i '$D(^DBTBL(lib,level,elem)) q					; element is not in library
	. i $D(^DBTBL(lib,level,elem,-3)) q					; no need to recompile implicit definition
	. i '$D(^TEMP($J,elem)) s ^TEMP($J,elem)=""				; record element to be recompiled
	. s ^TMPREL($J,lib,level,elem)=""					; set up for DDPXFR
	q									; done
	;
prelate(lib,ppp,level)	
	;***********************************************************************
	; Purpose: Get related screen/report to be re-compiled.
	;***********************************************************************
	n xlevel,elem
	s xlevel=-level								; go to this - level to look for scr/rep
	i $D(^DBTBL(lib,13,ppp,xlevel)) d					; does this ppp has any thing at the - level?
	. s elem=""								; ok 
	. f  s elem=$O(^DBTBL(lib,13,ppp,xlevel,elem)) q:elem=""  d		; go through each one
	.. i '$D(^DBTBL(lib,level,elem)) q					; make sure element is defined
	.. i '$D(^TEMP($J,elem)) s ^TEMP($J,elem)=""				; record element to be recompiled
	.. s ^TMPREL($J,lib,level,elem)=""					; set up for DDPXFR
	q
	;
zsmc(lib)	
	;***********************************************************************
	; Purpose: Compile screen in smaller batch in a different image.
	;***********************************************************************
	n stat
	; i ISVMS=0 d  q  ; * js * 17-Sep-1996 (unix version)
	; . n (lib) s %LIBS=lib d EXT^DBSDSMC q  ; * js * 17-Sep-1996
	;
loop1	; keep calling batch until ^TEMP($J) is exhausted
	s stat=$$batch(lib,2,ISVMS)						; compile in small batch of 100
	i stat'=1  k ^TEMP($J) q						; error - forget it, no more compile
	i $D(^TEMP($J)) g loop1							; no error - process next 100
	q									; done
	;
getmscr(lib)	
	;***********************************************************************
	; Purpose: Build a list of linked screens in a given library.
	; Assume:  The format of the list is:
	;	   master(slave_screen)=master_screen
	;***********************************************************************
	n count,mscr,sscr,str
	s mscr=""
	f  s mscr=$O(^DBTBL(lib,2,mscr)) q:mscr=""  d				; go thru each screen in this library
	. s str=$G(^DBTBL(lib,2,mscr,-1)) q:str=""				; -1 denotes a master screen
	. i $D(^DBTBL(lib,2,mscr,-3)) q						; skip, this screen is an implicit
	. f count=1:1:$L(str,"|") d						; how many potential slave screens does it have?
	.. s sscr=$P(str,"|",count) q:sscr=""					; break str into slave screen, throw away null sscr
	.. s master(sscr)=mscr							; save master/slave relationship
	q
	;
ZREP	;***********************************************************************
	; Purpose: Compile report.
	;***********************************************************************
	n lib
	s lib=""
	f  s lib=$O(^DBTBL(lib)) q:lib=""  d					; go through each library
	. i lib="PRD" q
	. d getall(lib,5)							; get report to compile
	. i '$D(^TEMP($J)) q							; nothing to compile
	. d logmsg("***** Compiling reports in library "_lib_".",zlogf)
	. h 2									; slow down so display on screen will be ok
	. d zrmc(lib)								; place a call to mass compile report
	. d:dqvn7 appfile(blogf,zlogf)
	. d logmsg("***** Done compiling reports in library "_lib_".",zlogf)
	q									; done
ZREX	;***********************************************************************
	; Purpose: Compile record exchange run-time routines
	;***********************************************************************
	n lib,rex
	s lib=""
	f  s lib=$O(^DBTBL(lib)) q:lib=""  d					; go through each library
	. i lib="PRD" q
	. d getall(lib,16)							; get list to compile
	. i '$D(^TEMP($J)) q							; nothing to compile
	. d logmsg("Compiling exchanges in library "_lib_".",zlogf)
	. h 2									; slow down so display on screen will be ok
	. S rex="" F  S rex=$O(^TEMP($J,rex)) Q:rex=""  S $P(^DBTBL(lib,16,rex),"|",2)="" d rex
	. d logmsg("Done compiling exchanges in library "_lib_".",zlogf)
	q
	;
	;***********************************************************************
rex	; Purpose: place a call to build record exchange
	;***********************************************************************
	;
	n (lib,rex,zlogf)
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("PPSER^TBXDQUTL") 
	d ^DBSEXCHC(rex) 
	q
	;
ZAGG	;***********************************************************************
	; Purpose: Compile Aggregate run-time routines
	;***********************************************************************
	n lib,agg
	s lib=""
	f  s lib=$O(^DBTBL(lib)) q:lib=""  d					; go through each library
	. i lib="PRD" q
	. d getall(lib,22)							; get list to compile
	. i '$D(^TEMP($J)) q							; nothing to compile
	. d logmsg("***** Compiling aggregates in library "_lib_".",zlogf)
	. h 2									; slow down so display on screen will be ok
	. S agg="" F  S agg=$O(^TEMP($J,agg)) Q:agg=""  S $P(^DBTBL(lib,22,agg),"|",4)="" W !,agg D agg
	. d logmsg("***** Done compiling aggregates in library "_lib_".",zlogf)
	q
	;
	;***********************************************************************
agg	; Purpose: place a call to rebuild aggregate
	;***********************************************************************
	;
	n (agg,zlogf)
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("PPSER^TBXDQUTL") 
	d CREATE^SQLAG(agg) 
	q
	;
zrmc(lib)	
	;***********************************************************************
	; Purpose: Compile report in smaller batch in a different image.
	;***********************************************************************
	n stat,RID
	;
loop2	; keep calling batch until ^TEMP($J) is exhausted
	s stat=$$batch(lib,5,ISVMS)						; compile report in batch of 100
	i stat'=1  k ^TEMP($J) q						; error - forget it, no more compile
	i $D(^TEMP($J)) g loop2							; no error - process next 100
	q									; done
	;
	;**********************************************************************
rep	; Purpose: place a call to build procedure
	;**********************************************************************
	N elem,$ZT
	d LOGF(.blogf,"APPEND") 
	s elem="" f  s elem=$O(^TEMP($J,elem)) q:elem=""  d
	. d logmsg("Compiling report "_elem_" in library "_%LIBS_".",blogf)
	. S @$$SET^%ZT("PPSER2^TBXDQUTL")
	. d ^DBSRW(elem)
	. d logmsg("Done compiling report "_elem_" in library "_%LIBS_".",blogf)
	c blogf
	Q	
batch(lib,type,ISVMS)	
	;***********************************************************************
	; Purpose: Compile at most 100 screens/reports in a different image.
	;***********************************************************************
	n file,count,x,cmd
	i type'=2,type'=5,type'=25,type'=33 q 0					; double check - make sure type is 2,5,25, or 33
	I ISVMS s file=$$HOME^%TRNLNM("dqc_temp_"_$J_".com")			; name of temporary .COM file
	I 'ISVMS s file=$$HOME^%TRNLNM("dqc_temp_"_$J_".sh")
	s x=$$create(file,lib,ISVMS)						; create .COM file write in the header
	i x=0 q 0								; bad return status
	s count=0
	f  s x=$O(^TEMP($J,"")) q:(x="")!(count=100)  d				; go thru ^TEMP global - max 100 scr/rep
	. s count=count+1
	. k ^TEMP($J,x)
	. I ISVMS u file w "S ^TEMP($J,"""_x_""")=""""",!			; record screen in .COM file
	. I 'ISVMS u file w "S ^TEMP(\$J,"""_x_""")=""""",!
	i type=5,'dqvn7 u file w "D EXT^DBSEXE",!				; line tag to compile report
	i type=5,dqvn7 u file w "D rep^TBXDQUTL",!
	i type=2 u file w "D EXT^DBSDSMC",!					; line tag to compile screen
	i type=25 u file w "D cproc^TBXDQUTL",!					; line tag to compile procedure
	i type=33 u file w "D cbat^TBXDQUTL",!					; line tag to compile batch 
	u file w "H",!
	I ISVMS u file w "$ exit",!
	I 'ISVMS u file w "gtm_eof",!,"exit",!
	c file
	I ISVMS D
	. s cmd="@"_file							; set up dcl command to execute .com file
	. s x=$$SYS^%ZFUNC(cmd)							; spawn out and execute .com file
	. s cmd="DELETE/NOLOG "_file_";*"					; set up dcl command to delete .com file
	. s x=$$SYS^%ZFUNC(cmd)							; spawn out and delete .com file
	I 'ISVMS D
	. s cmd="chmod +x "_file
	. s x=$$SYS^%ZFUNC(cmd)
	. s cmd=file
	. s x=$$SYS^%ZFUNC(cmd)
	. s cmd="rm "_file
	. s x=$$SYS^%ZFUNC(cmd)	
	q 1
	;
create(file,lib,ISVMS)	
	;***********************************************************************
	; Purpose: Create temporary .COM file to execute at target area.
	;***********************************************************************
	n dir,x
	s dir=$$SCAU^%TRNLNM("DIR")
	S:ISVMS dir=$$SCAU^%TRNLNM("DIRNAME")
	I dir="" d logmsg("Error - Missing current directory logical name",zlogf) q 0
	s x=+$$FILE^%ZOPEN(file,"WRITE/NEWV",5)					; attempt to open file
	i x=0 d logmsg("Error - unable to open file "_file,zlogf) q 0			; failed to open file
	I ISVMS D
	. u file w "$ gm :== $sca$zcall:scadmod",!
	. u file w "$ set default "_dir,!
	. u file w "$ @gtmenv 1",!
	. u file w "$ gm",!
	. u file w "S %LIBS="""_lib_"""",!
	. u file w "S blogf="""_blogf_"""",!
	. u file w "K ^TEMP($J)",!
	I 'ISVMS D
	. u file w "#!/bin/ksh",!
	. u file w "cd "_dir,!
	. u file w ". /SCA/scaenv",!
	. u file w ". ./gtmenv",!
	. u file w:(($G(db)="ORACLE")) "$gtm_dist/mumps -run C^ORACON <<-gtm_eof",!
	. u file w:($G(db)'="ORACLE") "$gtm_dist/mumps -direct <<-gtm_eof",!
	. ; u file w:(dqvn7&($G(db)="ORACLE")) "D C^ORACON",!			; open oracle connection
	. u file w "S %LIBS="""_lib_"""",!
	. u file w "S blogf="""_blogf_"""",!
	. u file w "K ^TEMP(\$J)",!
	q x
	;
ZFIL	;***********************************************************************
	; Purpose: Compile filer routine.
	;***********************************************************************
	n lib,elem
	d getfile								; get all files to be compiled
	i '$D(^TEMP($J)) q							; nothing to compile
	D VIDXBLD^DBSDFKF()							; create index file for foreign keys
	s lib="",elem="" 	
	f  s lib=$O(^TEMP($J,lib)) q:lib=""  d					; get library name
	. f  s elem=$O(^TEMP($J,lib,elem)) q:elem=""  d				; get element name
	.. d logmsg("Compiling run time filer routine for "_elem_" in library "_lib_".",zlogf)
	.. d filer(lib,elem)							; compile filer routine
	.. d logmsg("Done compiling run time filer routine for "_elem_" in library "_lib_".",zlogf)
	k ^TEMP($J)								; clean up
	q									; done
	;
filer(lib,elem)	
	;***********************************************************************
	; Purpose: When compile filer routine, we should clean up all local var
	;	   This routine provides an opportunity to save local var lib
	;	   and elem.
	;***********************************************************************
	n (lib,elem,zlogf)
	i $$NEW^%ZT n $ZT				; set up error trap
	; s @$$SET^%ZT("err^TBXDQUTL")			; Error trap
	s @$$SET^%ZT("PPSER^TBXDQUTL")
	s %LIBS=lib								; PROFILE should recognize %LIBS
	s ^TMPXFR($J,"FILER",elem)=0			; set up for transfer
	d COMPILE^DBSFILB(elem)							; actual call to compile   ;10/30/96 mas
	q
err	;
	w !!,"****************************************************************",!
	w !,$ZS,!
	w !!,"****************************************************************",!!
	q
	;
getfile	;***********************************************************************
	; Purpose: Set up file name in ^TEMP($J) global
	;***********************************************************************
	n lib,level,elem,fid
	s lib="",elem=""
	i $D(^TEMP($J)) k ^TEMP($J)						; init
	f  s lib=$O(^TMPDQC($J,lib)) q:lib=""  d				; get library name
	. f level=1,7,8,9,19 d							; build filer for level 1,7,8,9 only
	.. f  s elem=$O(^TMPDQC($J,lib,level,elem)) q:elem=""  d		; get element name
	... s fid=$P(elem,".",1)						; *** 02/21/97
	... i $P($G(^DBTBL(lib,1,fid,99)),"|",2)="" q				; make sure there is a filer routine name
	... s ^TEMP($J,lib,fid)=""						; save library and element name
	q									; done
	;
ZTBL	;***********************************************************************
	; Purpose: Build table index ^XDBREF
	;***********************************************************************
	n lib,done
	s lib="",done=0  	
	f  s lib=$O(^TMPDQC($J,lib)) q:(lib="")!(done=1)  d			; go through each library
	. i $D(^TMPDQC($J,lib,1)) s done=1					; any file def in export?
	i done=1 d								; should rebuild table only if file def in export
	. d logmsg("Building table index for file definition.",zlogf)
	. d table								; refresh the stack before rebuild table index
	. d logmsg("Done building table index for file definition.",zlogf)
	q									; done
	;
table	;***********************************************************************
	; Purpose: Place a call to rebuild table index.
	; Note: Subroutine VIDXBLD^DBSDF1F will call SYSVAR^SCADRV0("PBS")
	;***********************************************************************
	i $$NEW^%ZT n $ZT							; set up error trap
	s @$$SET^%ZT("PPSER^TBXDQUTL")						; Error trap
	d VIDXBLD^DBSDF1F("VINDEX")						; actual call to compile
	q									; done
	;
ZCTL	;***********************************************************************
	; Purpose: Build data item control file.
	;***********************************************************************
	n lib,elem,fid
	s lib="",elem=""
	f  s lib=$O(^TMPDQC($J,lib)) q:lib=""  d
	. f  s elem=$O(^TMPDQC($J,lib,1,elem)) q:elem=""   d
	.. d ctrfile
	q
	;
ctrfile	;***********************************************************************
	; Purpose: Place a call to rebuild control file.			
	;***********************************************************************
	;
	N (elem,lib,fid,zlogf)
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("PPSER^TBXDQUTL") 
	S fid=$P(elem,".",1) 
	I $D(fid(fid)) q 
	S fid(fid)="" 
	S %LIBS=lib 
	d logmsg("Building data item control file for "_fid_" in library "_lib_".",zlogf) 
	d BLDINDX^DBSDF9(fid) 
	d logmsg("Done Building data item control file for "_fid_" in library "_lib_".",zlogf) 
	q
	;
ZAUT	;***********************************************************************
	; Purpose: Rebuild filer authorization routine.
	;***********************************************************************
	n lib,elem
	s lib="",elem=""
	f  s lib=$O(^TMPDQC($J,lib)) q:lib=""  d				; go through each library
	. f  s elem=$O(^TMPDQC($J,lib,10,elem)) q:elem=""  d			; build authorization file for level 10 only
	.. s %LIBS=lib								; PROFILE should recognize %LIBS
	.. d logmsg("Building filer authorization routine for "_elem_" in library "_lib_".",zlogf)
	.. d ^DBSFILAU(elem)							; actual call to compile
	.. d logmsg("Done building filer authorization routine for "_elem_" in library "_lib_".",zlogf)
	q									; done
	;
ZEXC	;***********************************************************************
	; Purpose: Rebuild executive routine.
	;***********************************************************************
	n lib,elem
	s lib="",elem=""  
	f  s lib=$O(^TMPDQC($J,lib)) q:lib=""  d				; go through each library
	. f  s elem=$O(^TMPDQC($J,lib,3,elem)) q:elem=""  d			; build executive file for level 3 only
	.. d logmsg("Building executive routine for "_elem_" in library "_lib_".",zlogf)	
	.. d exec								; actual call to compile   10/30/96 mas
	.. d logmsg("Done building executive routine for "_elem_" in library "_lib_".",zlogf)
	q
exec	;***********************************************************************
	; Purpose: place a call to rebuild executive
	;***********************************************************************
	n (lib,elem,zlogf)
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("PPSER^TBXDQUTL") 
	s %LIBS=lib 
	d COMPILE^DBSEXEC(elem)
	q
	;
ZPROC	;***********************************************************************
	; Purpose: Rebuild procedure routine.
	;***********************************************************************
	n lib,elem
	s lib="",elem=""
	k:$D(^TEMP($J)) ^TEMP($J)	
	f  s lib=$O(^TMPDQC($J,lib)) q:lib=""  d				; go through each library
	. I $D(^TMPDQC($J,lib,25)) D
	.. f  s elem=$O(^TMPDQC($J,lib,25,elem)) q:elem=""  d			; build executive file for level 3 only
	... s ^TEMP($J,elem)=""
	.. d logmsg("***** Compiling procedure routine "_lib_".",zlogf)
	.. d proc
	.. d appfile(blogf,zlogf)
	.. d logmsg("***** Done compiling procedure routine "_lib_".",zlogf)
	q
	;
	;***********************************************************************
proc	; Purpose: place a call to build procedure
	;***********************************************************************
	; keep calling batch until ^TEMP($J) is exhausted
	s stat=$$batch(lib,25,ISVMS)						; compile in small batch of 100
	i stat'=1  k ^TEMP($J) q						; error - forget it, no more compile
	i $D(^TEMP($J)) g proc							; no error - process next 100
	q									; done
	;
	;**********************************************************************
cproc	; Purpose: place a call to build procedure
	;**********************************************************************
	N elem,$ZT
	;
	d LOGF(.blogf,"APPEND") 							; open a log file for this batch process
	;
	s elem="" f  s elem=$O(^TEMP($J,elem)) q:elem=""  d
	. d logmsg("Compiling procedure routine "_elem_" in library "_%LIBS_".",blogf)
	. S @$$SET^%ZT("PPSER2^TBXDQUTL")
	. d COMPILE^DBSPROC(elem)
	. d logmsg("Done compiling procedure routine "_elem_" in library "_%LIBS_".",blogf)
	c blogf
	Q										
	;
getimpl(level)	
	;***********************************************************************
	; Purpose: Set up implicit file name in ^TEMP($J) global.
	;***********************************************************************
	i $D(^TEMP($J)) k ^TEMP($J)						; init
	s elem=""
	f  s elem=$O(^TMPDQC($J,"SYSDEV",level,elem)) q:elem=""  d		; build implicit for SYSDEV library only
	. s ^TEMP($J,elem)=""							; save element name
	q
	;
ZDIX	;***********************************************************************
	; Purpose: Rebuild data item cross reference file for screen, sort,
	; query, report, qwik report, pre/post-processor. 
	;***********************************************************************
	n lib,DQOPT,DBOPT,DQFUN,ID
	d logmsg("Begin rebuild data item cross reference file.",zlogf)
	s lib="",DBOPT="",ID="",DQFUN="A"
	s DQOPT(2)="Screen",DQOPT(3)="Sort",DQOPT(4)="Query"			; set up options
	s DQOPT(5)="Report",DQOPT(6)="Qwik Report",DQOPT(13)="PPLIB"		; PROFILE should recognize DQOPT
	f  s lib=$O(^TMPDQC($J,lib)) q:lib=""  d				; go through each library
	. f DBOPT=13,2:1:6 d							; PROFILE should recognize DBOPT
	.. i '$D(^TMPDQC($J,lib,DBOPT)) q					; quit if there is no element to rebuild
	.. f  s ID=$O(^TMPDQC($J,lib,DBOPT,ID)) q:ID=""  d			; PROFILE should recognize ID
	... d dix								; actual call to rebuild
	d logmsg("End rebuild data item cross reference.",zlogf)
	q
	;
	;***********************************************************************
dix	; Purpose: place a call to build data item cross reference
	;***********************************************************************
	;
	n (lib,DQOPT,DBOPT,DQFUN,ID,zlogf,dqvn7)
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("PPSER^TBXDQUTL") 
	s %LIBS=lib 						
	d logmsg(DQOPT(DBOPT)_" definition "_ID_" in library "_lib,zlogf)
	d SET^DBSUTL3
	q
	;
ZPPP	;***********************************************************************
	; Purpose: Rebuild pre/post-processor index file.
	;***********************************************************************
	n lib
	s lib=""
	f  s lib=$O(^TMPDQC($J,lib)) q:(lib="")  d				
	. i $D(^TMPDQC($J,lib,13)) d
	.. d logmsg("Building pre/post-processor index file for library "_lib_".",zlogf)
	.. d ppp 						; check if any pre/post-processor was released
	.. d logmsg("Done building pre/post-processor index file for library "_lib_".",zlogf)
	q
	;
	;***********************************************************************
ppp	; Purpose: place a call to build pre/post processor
	;***********************************************************************
	;
	n (lib,zlogf)
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("PPSER^TBXDQUTL") 
	s %LIBS=lib								; PROFILE should recognize %LIBS
	d %EXT^DBSPP								; actual call to rebuild
	Q 
	; 
ZDPL	;***********************************************************************
	; Purpose: Rebuild data item protection logic.
	;***********************************************************************
	n lib,elem
	s lib="",elem=""
	f  s lib=$O(^TMPDQC($J,lib)) q:lib=""  d				; go though each library
	. f  s elem=$O(^TMPDQC($J,lib,14,elem)) q:elem=""  d			; check level 14 only
	.. d logmsg("Building data item protection logic for "_elem_" in library "_lib_".",zlogf)
	.. d dpl								; actual call to rebuild
	.. d logmsg("Done building data item protection logic for "_elem_" in library "_lib_".",zlogf)
	q									; done
	;
	;***********************************************************************
dpl	; Purpose: place a call to build data item protection logic
	;***********************************************************************
	;
	n (lib,elem,zlogf)
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("PPSER^TBXDQUTL") 
	s %LIBS=lib 							; PROFILE should recognize %LIBS
	d BUILD^DBSPROT3(elem)							; actual call to rebuild
	q
	;
ZMDD	;***********************************************************************
	; Purpose: Set up MDD index file
	;***********************************************************************
	;
	d logmsg("Building MDD index file",zlogf)
	K ^DBINDX("SYSDEV","MDD")
	D VIDXBLD^DBSDFF()
	q
	;
ZFEP	;***********************************************************************
	; Purpose: Set up auto FEP transfer.
	;***********************************************************************
	; *** by ZCL - 05/11/1999 - local variable for FEP transfer
	n QUE
	; *** BY ZCL - 08/17/98 - setup the DDPXFR for Unix too.
	;I $zvn'["VMS" q	;get rid of this line		; Skip for UNIX system
	n lib
	d initxfr								; init dopt() and get var dir and TJD
	i (DIR="")!(TJD="") d logmsg("Can not set up auto xfer via DDPXFR",zlogf) q	; make sure DIR and TJD are defined
	s lib=""
	f  s lib=$O(^DBTBL(lib)) q:lib=""  d					; any modified element in this library?
	. i lib="PRD" q
	. d default(lib)							; default processing for library lib
	. i $D(^TMPXFR($J)) d submit(lib)					; is there anything in this library for transfer?
	. k ^TMPXFR($J)								; clean up
	. ;*** by ZCL - 05/11/1999 - clean up the files created by Tw. Requested by Mark.
	. I 'dqvn7 D
	.. S QUE=""
	.. F  S QUE=$O(^DDP("TQUE",QUE)) Q:QUE=""  D END^DDPSRVR 
	q									; done
	;
initxfr	;***********************************************************************
	; Purpose: Init local var needed by DDPXFR
	;***********************************************************************
	s dopt(1)="FILE"
	s dopt(2)="SCREEN"
	s dopt(3)="EXEC"
	s dopt(4)="QUERY"
	s dopt(5)="REPORT"
	s dopt(6)="QWIK"
	s dopt(7)="TRIGGER"
	s dopt(8)="FILER"
	s dopt(9)="FILER"
	s dopt(10)="FILER"
	s dopt(11)="DOC"
	s dopt(12)="TVDOC"
	s dopt(13)="PPLIB"
	s dopt(14)="PROT"
	s dopt(15)="CVDOC"
	s dopt(16)="RECEXCH"
	s dopt(19)="FKDEF"
	s dopt(25)="PROC"		; *** 01/03/97
	s DIR=$$DIR^DDPUTL
	;s DIR=$$DDPDIR^DDPUTL
	s TJD=$G(^CUVAR(2))
	q
	;
default(lib)	
	;***********************************************************************
	; Purpose: Default processing for DDPXFR
	;***********************************************************************
	d crt(lib)								; recompiled routines
	d dqw(lib)								; loaded dataqwik
	q
	;
crt(lib)	
	;***********************************************************************
	; Purpose: Check for re-compiled routines.
	; Assume: ^TMPREL is built only for dq level 2 and 5.
	;***********************************************************************
	n level,elem,rname
	i '$D(^TMPREL($J,lib)) q						; nothing re-compiled in this library
	s level="",elem=""
	f  s level=$O(^TMPREL($J,lib,level)) q:level=""  d
	. f  s elem=$O(^TMPREL($J,lib,level,elem)) q:elem=""  d
	.. s rname=$P($G(^DBTBL(lib,level,elem,0)),"|",2) q:rname=""		; get run-time routine name
	.. i $$VALID^%ZRTNS(rname) s ^TMPXFR($J,"ROUTINE",rname)=0		; check if it's valid
	.. i level=5 d								; for report, check sort program
	... s rname=$translate(rname,"S","Z")					; sort routine name
	... i $$VALID^%ZRTNS(rname) s ^TMPXFR($J,"ROUTINE",rname)=0		; check if it's valid
	q									; done
	;
dqw(lib)	
	;***********************************************************************
	; Purpose: Set up new or modified dataqwik in this release in global 
	;	   ^TMPXFR for library lib.
	;***********************************************************************
	n type,elem,node4
	i '$D(^TMPDQC($J,lib)) q						; nothing to do
	s type="",elem=""
	f  s type=$O(^TMPDQC($J,lib,type)) q:type=""  d
	. f  s elem=$O(^TMPDQC($J,lib,type,elem)) q:elem=""  d
	.. 	s node4=$p(elem,".",1)
	..	i $D(^DBTBL(lib,type,node4)) d
	...		s dtype=$$xch(type,1)
	... 		s ^TMPXFR($J,dtype,node4)=0
	q
	;
xch(type,flag)	
	;***********************************************************************
	; Purpose: Convert dataqwik type (integer) or SCATBL type (integer) to 
	;	   dtype (string) for use in DDPXFR.
	;***********************************************************************
	n dtype
	i flag=1 d								; dataqwik conversion
	. i $D(dopt(type)) s dtype=dopt(type)
	. e  s dtype="UNKNOWN"
	i flag=2 d								; scatbl conversion
	. i $D(sopt(type)) s dtype=sopt(type)
	. e  s dtype="UNKNOWN"
	q dtype
	;
submit(lib)	
	;***********************************************************************
	; Purpose: Place a call to set up DDPXFR.
	;***********************************************************************
	n dtype,elem,fname,ok,ER,IOLIST		; *** by ZCL - 02/11/2000 - Add the change Mark made to solve some problem
	d logmsg("Set up auto transfer to all FEPs via DDPXFR",zlogf)
	s fname=$$SCAU^%TRNLNM("SPOOL",lib_"_"_$J_"_LOAD.DAT")			; file name is scau$spool:library_$J_load.dat
	s ok=$$FILE^%ZOPEN(fname,"WRITE/NEWV",5)				; attemp to open file in WRITE mode
	i +ok=0 d logmsg("Can not create file "_fname_". Attempt to transfer has failed.",zlogf) q
	u fname w "Release|Load|",lib,!						; library is needed in DDPXFR
	s dtype="",elem=""
	f  s dtype=$O(^TMPXFR($J,dtype)) q:dtype=""  d
	. f  s elem=$O(^TMPXFR($J,dtype,elem)) q:elem=""  d
	.. u fname w dtype,"|",elem,"|",^TMPXFR($J,dtype,elem),!		; please note obsolete flag
	u fname w "<EOH>",!							; mark end of file
	c fname									; remember to close file
	s ER=$$%EXIMP^DDPXFR(fname,DIR)						; place a call to set up transfer queue
	i ER=0 d logmsg("Done setting up DDPXFR for library "_lib_".",zlogf) i 1
	e  d logmsg("Error detected in DDPXFR. Please check DDP queue, and set up DDPXFR manually.",zlogf)
	q									; done
	;
	;-----------------------------------------------------------------------
FIXCCHR(STR);	This section of code will parse a string and convert control
	;	charcter to $C(A). eg convert tab to $C(9)
	;-----------------------------------------------------------------------
	;  
	N Y,STRARR,COUNT,K
	;
	; Splits the string when matches of any control characters
	; eg string is "abcdefg		adfa" ("abcdefg"_$C(9,9)_"adfa")
	;    STR(0)="abcdefg"
	;    STR(1)=$C(9)
	;    STR(2)=$C(9)
	;    STR(3)="adfa"
	S COUNT=0
	F K=1:1:$L(STR) D
	.	S Y=$A($E(STR,K))
	.	I ((Y>-1)&(Y<32))!(Y>126) D  Q
	..		S COUNT=COUNT+1
	..		S STRARR(COUNT)=$C(Y)
	..		S:'(K=$L(STR)) COUNT=COUNT+1
	.	E  D
	..		S:K=1 COUNT=COUNT+1
	..		S STRARR(COUNT)=$G(STRARR(COUNT))_$C(Y)
	Q $$CSTR(.STRARR)
	;
	;----------------------------------------------------------------------
CSTR(TARR);	Rebuild the string from an array. 
	; 
	;  Local variables:
	;	LAST:		The last index in the array
	;	OUT:		Output String
	;	J:		Arrary index
	;	C:		ASCII value of the character
	;	TMPSTR:		Temparory string
	;	SetQuote:	Boolean flag indicates the asicc value of the character is 128
	;	IsCtrl		Boolean flag indicates the character is a control Character 		
	;----------------------------------------------------------------------
	;
	N FIRST,LAST,OUT,C,J,TMPSTR,SetQuote,IsCtrl
	;
	S LAST="",LAST=$O(TARR(LAST),-1)
	;
	S OUT=""
	I LAST=1 D  Q OUT
	. S C=$A(TARR(1))
	. I ((C>-1)&(C<32))!(C>126) S OUT="$C("_$A(TARR(1))_")"
	. E  S OUT=$$QADD^%ZS(TARR(1)) 
	;
	; IsCtrl is a boolean indicates if the character is a control character or not
	; and is used to determine when to append "," , "$C(" or ")" if it is a control character
	;
	S IsCtrl=0,SetQuote=0
	;
	S J="" F  S J=$O(TARR(J)) Q:J=""  D
	.	S C=$A(TARR(J),1)
	.	I ((C>-1)&(C<32))!(C>126) D  Q
	..		S:C=128 SetQuote=1
	..		I 'IsCtrl D  Q
	...			S OUT=OUT_$S(J=LAST:"$C("_C_")",1:"$C("_C)
	...			S IsCtrl=1
	..		I IsCtrl D  Q
	...			S OUT=OUT_$S(J=LAST:","_C_")",1:","_C)
	.	I SetQuote&(C=34) D  Q	; if previous char is 128 convert the following quote to 34
	..		S SetQuote=0,OUT=OUT_","_C_")_"_$$QADD^%ZS($E(TARR(J),2,$L(TARR(J))))
	.	E  D
	..		S:IsCtrl IsCtrl=0
	..		S:SetQuote SetQuote=0
	..		S TMPSTR=$$QADD^%ZS(TARR(J))
	..		S OUT=OUT_$S(J=LAST:")_"_TMPSTR,J=1:TMPSTR_"_",1:")_"_TMPSTR_"_")	
	Q OUT
	;
	;-----------------------------------------------------------------------
LOGF(logf,option);	Create a log file 
	;-----------------------------------------------------------------------
	;
	s ok=$$FILE^%ZOPEN(logf,option,5)					; try to open log file in WRITE mode
	i +ok=0 s logf=0							; how can we log anything if we can't open log file?
	Q
	;
	;-----------------------------------------------------------------------
TRLNAM(LNM);	Translate a logical name. 
	;----------------------------------------------------------------------- 
	;
	Q $ZTRNLNM(LNM) 
	; 
	; 
NFSVMS(nfs)	;  Convert a Unix NFS file name into a VMS RMS file name. 
	; 
	;  This routine takes a Unix file specification and converts it into 
	;  the equivalent RMS file name, supporting mixed case characters as 
	;  well as some special characters ("$", "_", and "-"). 
	; 
	n vms,i,fp,lc 
	s vms="",(fp,lc)=1 
	; 
	f i=1:1:$l(nfs) s vms=vms_$$rms($e(nfs,i)) 
	q vms 
	; 
rms(c)	;  Convert a single NFS file name character into an RMS file name char. 
	; 
	;  Local variables used to determine the current state: 
	; 
	;       fp      no period seen yet in the file name 
	;       lc      currently using lower case letters 
	; 
	i c?1N q c 
	i c?1U s c=$s(lc:"$"_c,1:c),lc=0 q c 
	i c?1L s c=$c($a(c)-32) s:lc=0 c="$"_c s lc=1 q c 
	i c="-" q c 
	i c="_" q c 
	i c="." s c=$s(fp:".",1:"$5N"),fp=0 q c 
	i c="$" s:$e(nfs,i+1)?1LU c="$$" q c 
	q "?" 
	; 
VMSNFS(vms)	;  Convert a VMS RMS file name into a Unix NFS file name. 
	; 
	n nfs,i,fp,lc 
	s nfs="",(fp,lc)=1 
	; 
	s i=1 
	f  q:i>$l(vms)  s nfs=nfs_$$nfs() ;(vms,i) 
	q nfs 
	; 
nfs()	;  Convert a single RMS file name character into an NFS file name char. 
	; 
	;  Input as local variables: 
	; 
	;       vms     string representing the VMS file name 
	;       i       current character position 
	; 
	n c 
	; 
	;  Get a character from the current position. 
	; 
	s c=$e(vms,i),i=i+1 
	; 
	;  Numbers and certain punctuation are just fine. 
	; 
	i c?1N q c 
	i c="_" q c 
	i c="-" q c 
	i c="." q c 
	; 
	;  Upper case letters should be dealt with appropriately. 
	; 
	i c?1U s:lc c=$c($a(c)+32) q c 
	; 
	;  Dollar sign will be tricky ... process further. 
	; 
	i c="$" d  q c 
	. i $e(vms,i)?1U s lc='lc,c="" q 
	. i $e(vms,i)?1N s c=$$esc() i c'="" s i=i+2 q 
	. s c="$" 
	; 
	;  Don't know what to do with this (yet)! 
	; 
	q "?" 
	; 
	; 
esc()	;  Process NFS escape character. 
	; 
	;  Get possible escape code. 
	; 
	s z=$e(vms,i,i+1) 
	; 
	;  Check it against any known code;  if it's real, return the Unix 
	;  file name character counterpart.  Otherwise, retunr null string. 
	; 
	i z="5N" q "." 
	q "" 
	;
	;-----------------------------------------------------------------------
CHKDIRX(PATH,ISVMS);	Check directory, if not exist creates it. 
	; return 1 if directory exists or directory created
	; 0 if failed to create directory 	
	;-----------------------------------------------------------------------
	N STATUS,CMD,X,ER,PGM
	;
	S STATUS=1
	D CHKDIR(PATH) 
	I $G(ER) D
	.	S CMD="mkdir -p "_PATH
	.	S:ISVMS CMD="CREATE/DIRECTORY "_PATH
	.	S X=$$SYS^%ZFUNC(CMD)
	.	I (X'=0)&('ISVMS) S STATUS=0
	.	I ('X#2)&(ISVMS) S STATUS=0
	Q STATUS
	;
CHKDIR(PATH);	
	N PGM,X
	Q:$$SCAU^%TRNLNM($$UPPER^%ZFUNC(PATH))'=""
	S PGM="CHKDIRU^TBXDQUTL"			; default is unix
	I (ISVMS) S PGM="CHKDIRV^TBXDQUTL"
	S X=PATH D @PGM 
	Q 
	;
CHKDIRV	;================= Directory checker (post-processor) =============== 
	; for vms
	I '$D(X) Q 
	N FILE,NODE,DEV,DIR,Z 
	S FILE=$S("]:"[$E(X,$L(X)):X_"X",1:X_":"_X) 
	S Z=$ZPARSE(FILE,"NODE") I Z'="" S Z=$$TRNLNM^%ZFUNC($P(Z,":",1)) I Z'["::" S Z=Z_"::" 
	S X=Z 
	S Z=$ZPARSE(FILE,"DEVICE") I Z'="" S Z=$$TRNLNM^%ZFUNC($P(Z,":",1)) I Z'[":" S Z=Z_":" 
	S X=X_Z 
	S X=X_$ZPARSE(FILE,"DIRECTORY") 
	I X="" S ER=1,RM="Invalid directory" 
	Q 
	;
CHKDIRU	;================= Directory checker (post-processor) =============== 
	; for unix
	I '$D(X) Q 
	N Z 
	S Z=$ZSEARCH("/tmp")    ; reset the context 
	S X=$ZSEARCH(X) 
	I X="" S ER=1,RM="Invalid directory" 
	Q 
	; 
PPSER;***********************************************************************	
	; Purpose: Error trapping
	;***********************************************************************
	;
	s $ZT=""								; clear $ZT to prevent infinite error trapping
	; S %ZTHALT=0 D ZE^UTLERR
	d logmsg("Error detected check log file for detail "_zlogf,zlogf)
	u zlogf w !!,"****************************************************************",!
	u zlogf w !,"Error detected during DATA-QWIK compilation.",!		; write error message in log file
	u zlogf w "$ZSTATUS=",$ZSTATUS,!					; write $ZSTATUS to log file
	u zlogf w !,"Current stack information:",!				; dump stack to log file
	u zlogf zwr								; what is on stack
	u zlogf w !,"Printing routine that failed to execute.",!		; dump routine in log file
	s crash=$P($ZSTATUS,",",2)						; try to find out what routine it crashed in
	s crash=$P(crash,"^",2)							; extract routine name
	s crash="zp ^"_crash							; format so we can do a zp
	u zlogf x crash								; print routine
	u zlogf w !,"Unsuccessful compilation."
	u zlogf w !!,"****************************************************************",!
	q
	;  
PPSER2	;***********************************************************************
	; Purpose: Error trapping
	;***********************************************************************
	;
	s $ZT=""								; clear $ZT to prevent infinite error trapping
	; S %ZTHALT=0 D ZE^UTLERR
	u blogf w !!,"****************************************************************",!
	u blogf w !,"Error detected during DATA-QWIK compilation.",!		; write error message in log file
	u blogf w "$ZSTATUS=",$ZSTATUS,!					; write $ZSTATUS to log file
	u blogf w !,"Current stack information:",!				; dump stack to log file
	u blogf zwr								; what is on stack
	u blogf w !,"Printing routine that failed to execute.",!		; dump routine in log file
	s crash=$P($ZSTATUS,",",2)						; try to find out what routine it crashed in
	s crash=$P(crash,"^",2)							; extract routine name
	s crash="zp ^"_crash							; format so we can do a zp
	u blogf x crash								; print routine
	u blogf w !,"Unsuccessful compilation."
	u blogf w !!,"****************************************************************",!
	q
	; 	
appfile(blogf,zlogf);	
	n ok,cmd
	i $D(zlogf),zlogf'=0 d							; if log file is not open no need to write it again.
	. s ok=$$FILE^%ZOPEN(blogf,"READ",5)
	. f  u blogf r ln q:$ZEOF  u zlogf w ln,!
	c blogf:(DELETE)
	q
	;
	;
	;***********************************************************************
COMPPSL	; Run PSL upgrade
	; 
	;***********************************************************************
	;
	Q:$G(^TMPDQS($J,"phase1"))=""
	;
	s dir=$$appdir(INSTDIR,"[data]")
	; dqv is %VN
	d logmsg("***** Compiling PSL routine.",zlogf)
	d boot^UCGMCU(dir,dqv)
	d linkAll^UCGMCU()
	s ^TMPDQS($J,"phase2")=1	; for every PSL upgrade, we will need to recompile the framework
	Q
	;
	;***********************************************************************
COMPFRW	; Run Framework upgrade
	;***********************************************************************
	;
	Q:$G(^TMPDQS($J,"phase2"))=""
	n bootopts,dqname,elem
	d logmsg("***** Compiling framework routine .",zlogf)
	;
	s elem="" f  s elem=$O(^TMPDQS($J,"phase2","procedure",elem)) q:elem=""  d
	.	d logmsg("***** Compiling procedure routine "_elem_".",zlogf)
	.	s dqname=$P(elem,".",1)
	.	d bootProc^UCGMCU(dqname)
	;
	; Compile those filers that are known to be called in phase 3.
	; Note that this uses ^TMPDQS($J,"phase2","filer",table), which excludes
	; "filer" as the name of a (framework) table.
	d logmsg("***** Compiling framework filer .",zlogf)
	s elem=""
	f  s elem=$O(^TMPDQS($J,"phase2","filer",elem)) q:elem=""  d
	.	n ER,RM		; may be returned by COMPILE^DBSFILB()
	.	s dqname=$P(elem,".",1)
	.	d logmsg("***** Compiling run time filer routine for "_dqname_".",zlogf)
	.	k bootopts
	.	d getBootOptions^UCGMCU(.bootopts),COMPILE^DBSFILB(dqname,,.bootopts)
	Q
	;***********************************************************************
UPGRADE	; Run Upgrade
	;***********************************************************************
	;
	D COMPPSL
	D COMPFRW
	Q
	;-----------------------------------------------------------------------
GETVAR();	Get variables from release.dat file 
	;-----------------------------------------------------------------------
	;	
	N IO,X,dqv,LINE
	Q:'$G(initEnv) 0
	S IO=$$SCAU^%TRNLNM("DIR")_"/release.dat"
	S:ISVMS IO=$$SCAU^%TRNLNM("DIRNAME")_":release.dat"
	S X=$$FILE^%ZOPEN(IO,"READ")
	I 'X S ER=1,RM=$P(X,"|",2) Q 0_%_RM
	;
	U IO
	I $ZEOF U 0 S ER=1,RM=IO_" file missing"
	Q:ER 0_%_RM								        
	R LINE
	S dqv=$P(LINE,"%VN=",2)
	C IO
	Q dqv
	;
	;----------------------------------------------------------------------------
GETVN()	; Get %VN from CUVAR if db is GTM or XVN from RDB
	;----------------------------------------------------------------------------
	;
	n SQL,tbl,col
	;
	i '$D(db) d
	. S db=$$TRNLNM^%ZFUNC("SCAU$DB")
	. i db="" s db="GTM"
	;
	i db="GTM" Q $G(^CUVAR("%VN"))
	i db'="GTM" d
	. s tbl="CUVAR",col="%VN" 
	. d MAP^DBMAP(db,.tbl,.col)
	. s SQL="SELECT "_col_" FROM "_tbl
	. s ER=$$SELECT^%DBAPI("",SQL,$C(9),"",.DATA,.RM)
	Q DATA
	;
initproc;	
	;
	i '$G(initEnv) Q
	;
	i $$NEW^%ZT n $ZT                               ; set up error trap
	d logmsg("Compiling filer...",zlogf)
	; 
	n elem,%LIBS
	F elem="DBTBL1F","DBTBL1","DBTBL1D" d
	. d logmsg("Compiling filer "_elem,zlogf)
	. s @$$SET^%ZT("err^TBXDQUTL")
	. s %LIBS="SYSDEV"
	. d COMPILE^DBSFILB(elem)
	;
	d logmsg("Building table index for file definition.",zlogf)
	d table								; refresh the stack before rebuild table index
	d logmsg("Done building table index for file definition.",zlogf)
	;
	f elem="SCADRV0","UTLERR" d
	. d logmsg("Compiling procedure "_elem,zlogf)
	. s @$$SET^%ZT("err^TBXDQUTL")
	. s %LIBS="SYSDEV"
	. d COMPILE^DBSPROC(elem)
	q
	
