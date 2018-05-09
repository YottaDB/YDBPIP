UCRUNTIM	; Class Runtime methods 
	;;Copyright(c)2003 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/18/03 09:19:46 - GIRIDHARANB
	; ORIG: FSANCHEZ - 04/06/98
	; DESC: Library of Runtime methods
	;
	; KEYWORDS: 
	;
	; I18N=QUIT
	;
	;----------------------------------------------------------------------
	; LIBRARY:
	;	charset		Return character set of current process
	;	commit		Commit a transaction
	;	delayCommit	Run subroutine with delayed commits to RDB
	;	rollback	Rollback a transaction to a starting point
	;	start		Begin a transaction fence
	;
	; Note that property Runtime.charsetName is implemented in UCBYTSTR
	;
	;---- Revision History -------------------------------------------------
	; 10/09/06 - Frans S.C. Witte - CRs 22719 / 20613
	;	Calls to %DBAPI now pass 0 (zero) for vIndex (was "").
	;
	; 08/30/06 - Badrinath Giridharan - CR 22807 / 20163
	;	* Modified the delayCommit method to set the COMMIT_WRITE
	;	  parameter.
	;	* Modified routine to correct indenting of code in several places.
	;
	; 06/14/06 - Frans S.C. Witte - CRs: 22060 / 22061
	;	* Deprecated Runtime.charset().
	;
	; 04/06/06 - Frans S.C. Witte - CRs: 20280 / 18164
	;	* Added delayCmt. Modified public lvn vCmtCnt to vRunCmCt and
	;	  public lvn cSavePnt to vRunSvPt.
	;
	; 02/24/06 - Frans S.C. Witte - CRs: 19772 / 18164
	;	* Corrected Runtime.start to deal with array parameter
	;
	; 01/31/06 Frans S.C. Witte - CRs: 18163 / 18164
	;	* Replaced $G(list) by """".
	;	* Rewrote Charset to prevent call to DBSPARS2 and to correct
	;	  problem with assignment.
	;	* Generated labels now start with "vRun"
	;
	; 01/24/06 - RussellDS - CR19046
	;	* Added code to start section to perform a rollback in the
	;	  event of a GT.M restart.  A restart always returns to the
	;	  outermost transaction level, rolling back any MDB updates.
	;	  This change will also rollback the RDB updates.
	;
	; 12/01/05 - Frans S.C. Witte - CRs: 18727 / 18728
	;	* Replaced $G(index) by """"
	;
	; 11/04/05 - Frans S.C. Witte - CRs: 17937 / 15593
	;	* type(level,"Runtime") replaced by type(0,"Runtime"), to place
	;	  calls to vRunCmtF at the "quit from subroutine" level (instead
	;	  of "quit from do-level").
	;
	; 08/31/05 - Frans S.C. Witte - CRs: 17056 / 17057
	;	* Replaced call to $$CmtCnt^UCOPTS by call to
	;	  $$getPslValue^UCOPTS("batchCommitCount")
	;
	; 06/27/05 - RussellDS - CR16442
	;	* Corrected reference to vEr after calls to ^%DBAPI.
	;
	; 06/15/05 - RussellDS - CR16303
	;	* Corrected defect in commit section - missing dot in structured
	;	  DO preventing appending of RDB commit logic
	;
	; 06/05/05 - RussellDS - CR16207
	;	* Added section CommitC to consolidate code used by commit
	;	  section and saveTP^UCRECORD for generation of vRunCmtC
	;	  section.
	;
	; 05/26/05 - RussellDS - CR16079
	;	Major changes to start, commit, and rollback sections for
	;	handling RDBs.  This includes:
	;	* Using vEr and vRm instead of ER and RM
	;	* Structing generated code as calls to sub-routines to avoid
	;	  changes in intended user flow
	;	* In start section, set up type() array to add call to final
	;	  commit when leaving this stack level to deal with RDB
	;	  delayed commits; save transactionID to type() and eliminate
	;	  use of %TranID variable
	;	* Make use of new CmitCnt^UCOPTS to retrieve commit count for
	;	  delayed commits
	;	* Added save point logic to commit and rollback sections for RDBs
	;	  so that if we do a rollback, we do it to the right point
	;
	; 04/07/05 - Frans S.C. Witte - CRs: 14919 / 14920
	;	$$rdb^UCDB() changed to $$rdb^UCDBRT() (3 occurrences)
	;	Removed code that has been commented out.
	;
	; 10/19/04 - Frans S.C. Witte - CRs: 11445 / 11446
	;	Commented out procedure setTrap (it is no longer used by PSL).
	;	Moved code for Runtime methods .charset(), .delErrXBAD(),
	;	.setErrMSG(), .setErrSTBLERR(), and .setErrXBAD() from UCERROR
	;	to this routine.
	;
	; 05/12/04 - RussellDS - CR9676
	;	Move Profile04 version to Profile01 to support single code
	;	base for PSL.
	;
	; 02/12/04 - GIRIDHARANB - CR 8287
	;	     Modified section rollback to rollback to last known commit
	;	     if no savepoitn parameter is passed in.
	;	     Modified section start to store the transaction ID in %TranID.
	;	     Modified section commit to check %TranID on a relational database
	;
	; 08/15/03 - GIRIDHARANB -51637
	;	     Minor change to correct an error in the Tcommit linetag for the
	;	     relational database
	;
	; 08/05/03 - SPIER - 51423
	;            Modified sections start,commit and rollback to initialize
	;	     variable return to prevent duplication when these commands
	;	     are used in the same procedure.
	;
	; 07/31/03 - GIRIDHARANB - 45497
	;	     Modified the runtime start,commit and rollback sections to
	;	     add support for non-M databases
	;
	; 07/11/03 - SPIER - 51423
	;            Change to code generated to use conditional tests.
	;
	; 01/10/03 - SPIER - 51423
	;            Bug fixes to 51089 release
	;
	; 11/14/02 - SPIER - 51089
	;            Changes to start,commit and rollback to reflect
	;	     changed requirement for v7.0
	;
	; 10/15/02 - SPIER - 51089
	;            Modifications for v7.0 enhancements
	;
	;-----------------------------------------------------------------------
Charset	; Return character set 
	;-----------------------------------------------------------------------
	; Syntax: Runtine.charset()  Example:  set char=Runtime.charset()
	;
	;;N nv,ptr,v
	;;D charset^DBSPARS2				; return list in 'nv'
	;;I nv'[$c(0,0) S return=nv Q			; short list
	;;D ADD^UCGM(" S "_var_"="_$P(nv,$C(0,0),1))	; break up into two lines
	;;S v=$P(nv,$C(0,0),2)				; part 2
	;;S return=var_$E(v,5,9999)			; remaining characters
	;;Q
	do warnGroup^UCGM("DEPRECATED","method Runtime.charset() will not be available for Unicode version")
	;
	new ascList set ascList=$$charAscii()
	if $length(ascList)<450 set return="$C("_ascList_")" quit	; inline
	;
	; Use subroutine
	new lbl set lbl="vRunChrs"
	set return="$$"_lbl_"()"
	if $data(labels(lbl))#2 quit		; already defined
	;
	; Create subroutine vRunChrs
	new max set max=$$getPslValue^UCOPTS("maxLineLength")
	set labels(lbl)=""
	do addSubr^UCGM(lbl,"()","get characterset")
	;
	; Fits on single line
	if $length(ascList)+6<max do append^UCGM(" Q $C("_ascList_")",lbl) quit
	;
	; Need multiple lines
	new line,pos
	do append^UCGM(" N vRet",lbl)
	set max=max-50,line=" S vRet=$C("
	set pos=$find(ascList,",",max)
	do append^UCGM(line_$extract(ascList,1,pos-2)_")",lbl)
	do append^UCGM(" Q vRet_$C("_$extract(ascList,pos,$length(ascList))_")",lbl)
	quit
	;
	;-----------------------------------------------------------------------
charAscii()	;Return list of $ASCII() values of character set 
	;-----------------------------------------------------------------------
	; This function returns a comma separated list of all $ASCII() values.
	; The values occur in the order in which they are returned by $ORDER()
	; of the individual characters.
	;
	; NOTES:
	; . Because the individual digits sort as canonic numbers, they preceed
	;	all other characters.
	; . This code is derived from charset^DBSPARS2 that parsed var=&&charset
	;
	new char,i,v
	set v=$$LC^%CHARSET_$$UC^%CHARSET_"/0123456789@[\]^_`%!~$#&*()-+={}<>?:."
	for i=1:1:$length(v) set char($extract(v,i))=""        ; Sort it in order
	set i="",v=""
	for  set i=$order(char(i)) quit:i=""  set v=v_","_$A(i)
	quit $extract(v,2,$length(v))
	;
	;-----------------------------------------------------------------------
commit	;Commit a transaction
	;
	; If RDB, generates labels - vRunCmtB and vRunCmtC
	;-----------------------------------------------------------------------
	; Remove D command
	S mcode=$$backup^UCGM(mcode)
	I mcode="" S mcode=$C(9)
	E  S mcode=mcode_" "
	;
	S return=""
	;
	; Oracle commits must check $tlevel=0 do Oracle commit
	; Call a sub-routine in this case to avoid changing logic flow of user code,
	;   i.e., execution of code after the do Runtime.commit call.
	; If we are not committing to Oracle with each commit, we need to protect
	;   ourselves from a rollback that rollsback all the updates that haven't
	;   been committed.  Use a save point for that purpose and set flag to
	;   indicate the savepoint is active (vRunSvPt as save point name and
	;   flag).  Then, if we do a rollback, only roll back to that savepoint
	;   and then commit to harden earlier, committed (but not to Oracle)
	;   updates.
	; NOTE:  The code can probably be optimized to avoid calling the
	;   vCommit sub-routines and be place in-line if we can determine
	;   there are no commands following the Runtime.commit
	;
	I $$rdb^UCDBRT() D
	.	N label,nocnt,tranid
	.	S nocnt=0
	.	; tranid will default to "CS", i.e., not "BA" if type(0,"Runtime")
	.	; is not defined.  This will happen if the commit occurs in
	.	; a different subroutine from where start was done
	.	S tranid=$P($G(type(0,"Runtime")),tab,11)
	.	I tranid="BA" D
	..		N cmitcnt
	..		S cmitcnt=500			; Default
	..		D
	...			N $ZT
	...			S $ZT="Q"
	...			S cmitcnt=$$getPslValue^UCOPTS("batchCommitCount")
	...			if cmitcnt="" set cmitcnt=500
	..		S cmitcnt=cmitcnt-1
	..		;
	..		I cmitcnt'>0 S nocnt=1 Q	; No commit count, commit each time
	..		;
	..		S label="vRunCmtB"
	..		I postCond="" S return=" D:$TLEVEL=0 "_label
	..		E  S return=" D:("_$E(postCond,2,$L(postCond))_")&($TLEVEL=0) "_label
	..		I $D(labels(label))#2 Q		; Already exists
	..		S labels(label)=""
	..		D addSubr^UCGM(label,"","RDB delayed commit (""BA"" with commit count)")
	..		D append^UCGM($C(9)_"N vEr,vRm,vRmsg",label)
	..		D append^UCGM($C(9)_"S vRunCmCt=$G(vRunCmCt)+1",label)
	..		D append^UCGM($C(9)_"I vRunCmCt>"_cmitcnt_" S (vRunCmCt,vRunSvPt)=0,vEr=$$COMMIT^%DBAPI(0,.vRm) S:(vEr<0) vRmsg=""COMMITFAIL""",label)
	..		D append^UCGM($C(9)_"E  S vRunSvPt=1,vEr=$$EXECUTE^%DBAPI(0,""SAVEPOINT vRunSvPt"",$C(124),"""",.vRm) S:(vEr<0) vRmsg=""SAVEPNTFAIL""",label)
	..		D append^UCGM($C(9)_"I vEr<0 S $ZS=""-1,""_$ZPOS_"",%PSL-E-""_vRmsg_"",""_$G(vRm) X $ZT",label)
	..		D append^UCGM($C(9)_"Q",label)
	.	I (tranid'="BA")!nocnt D
	..		D CommitC(.label)				; Add vRunCmtC section
	..		I postCond="" S return=" D:$TLEVEL=0 "_label
	..		E  S return=" D:("_$E(postCond,2,$L(postCond))_")&($TLEVEL=0) "_label
	;
	I postCond="" S return="Tcommit:$Tlevel "_return
	E  S return="Tcommit:("_$E(postCond,2,$L(postCond))_")&$Tlevel "_return
	Q
	;
	;----------------------------------------------------------------------
CommitC(label)	; private ; Add vRunCmtC code 
	;----------------------------------------------------------------------
	;
	; ARGUMENTS:
	;	. label		Sub-routine label (vRunCmtC)	/MECH=REFNAM:W
	;
	; This is called by the local commit section as well as saveTP^UCRECORRD
	;
	S label="vRunCmtC"
	I $D(labels(label))#2 Q		; Already exists
	S labels(label)=""
	;
	D addSubr^UCGM(label,"","RDB commit (""CS"" or ""BA"" with no commit count)")
	D append^UCGM($C(9)_"N vEr,vRm",label)
	D append^UCGM($C(9)_"S (vRunCmCt,vRunSvPt)=0",label)
	D append^UCGM($C(9)_"S vEr=$$COMMIT^%DBAPI(0,.vRm)",label)
	D append^UCGM($C(9)_"I vEr<0 S $ZS=""-1,""_$ZPOS_"",%PSL-E-COMMITFAIL,""_$G(vRm) X $ZT",label)
	D append^UCGM($C(9)_"Q",label)
	Q
	;
	;----------------------------------------------------------------------
commitF(label)	; private ; Add vRunCmtF code 
	;----------------------------------------------------------------------
	;
	; ARGUMENTS:
	;	. label		Sub-routine label (vRunCmtF)	/MECH=REFNAM:W
	;
	; This is called by the local commit section as well as saveTP^UCRECORRD
	;
	S label="vRunCmtF"
	Q:($D(methods("Object","killCasc","Runtime"))#2)	; Already set up
	S methods("Object","killCasc","Runtime")=label
	I $D(labels(label))#2 D ERROR^UCGM("Subroutine exists: "_label) Q
	S labels(label)=""
	D addSubr^UCGM(label,"(object)","Final commit for stack level")
	D append^UCGM($C(9)_"Q:$TLevel!'$G(vRunCmCt)!$G(vRunDlay)",label)
	D append^UCGM($C(9)_"N vEr,vRm",label)
	D append^UCGM($C(9)_"S (vRunCmCt,vRunSvPt)=0",label)
	D append^UCGM($C(9)_"S vEr=$$COMMIT^%DBAPI(0,.vRm)",label)
	D append^UCGM($C(9)_"I vEr<0 S $ZS=""-1,""_$ZPOS_"",%PSL-E-COMMITFAIL,""_$G(vRm) X $ZT",label)
	D append^UCGM($C(9)_"Q",label)
	Q
	;
	;---------------------------------------------------------------------- 
delayCmt	; Implementation of Runtime.delayCommit() 
	;---------------------------------------------------------------------- 
	; 
	new call 
	; 
	; check value of call as if DO call occurred in the code 
	set call=$$actual^UCGM($$QSUB^%ZS(actual(1)),.called) 
	; 
	if $$rtIsRdb^UCXDD() do 
	. ;
	. new cmt,cmtF,lbl
	. set cmt="delay commits for "_call
	. set lbl=$$findSubr^UCGM("vRunDC",cmt)
	. set return=lbl_"()"
	. quit:$D(labels(lbl))
	. do commitF(.cmtF)
	.	do addSubr^UCGM(lbl,"()",cmt)
	.	do append^UCGM(" N vRunDlay S vRunDlay=1",lbl)
	.	do append^UCGM(" N vEr,vRm",lbl)
	.	; enable COMMIT_WRITE setting.
	.	do append^UCGM(" S vEr=$$EXECUTE^%DBAPI(0,""ALTER SESSION SET COMMIT_WRITE=NOWAIT,BATCH"",$C(124),"""",.vRm)",lbl)
	.	do append^UCGM(" D "_call,lbl)
	.	do append^UCGM(" K vRunDlay",lbl)
	.	do append^UCGM(" D "_cmtF_"(0)",lbl)
	.	; disable COMMIT_WRITE setting.
	.	do append^UCGM(" S vEr=$$EXECUTE^%DBAPI(0,""ALTER SESSION SET COMMIT_WRITE=WAIT,IMMEDIATE"",$C(124),"""",.vRm)",lbl)
	.	do append^UCGM(" Q",lbl)
	else  set return=call 
	quit 
	;
	;----------------------------------------------------------------------
delxbad	; Called by Runtime.delErrXBAD method 
	;----------------------------------------------------------------------
	; syntax: do Runtime.delErrXBAD
	;         (object,error_code,column,current_value,alternate_value)
	;
	;----------------------------------------------------------------------
	I $$QSUB^%ZS(actual(1))="*" s mcode=$e(mcode,1,$l(mcode)-2),return="kill verrors" Q
	S return="DELERR^DBSEXECU("_actual(1)_",""XBAD"","_actual(2)_")"
	Q
	;----------------------------------------------------------------------
er	; Called by Runtime.setErrSTBLER method
	;----------------------------------------------------------------------
	; syntax: do Runtime.setErrSTBLER(object,error_code)
	;
	;----------------------------------------------------------------------
	S return="SETERR^DBSEXECU("_actual(1)_",""ER"","_actual(2)_")"
	Q
	;----------------------------------------------------------------------
msg	; Called by Runtime.setErrMSG method
	;----------------------------------------------------------------------
	; syntax: do Runtime.setErrMSG(object,msg_number,variable)
	;
	;----------------------------------------------------------------------
	N p1,p2,p3
	S p1=actual(1),p2=actual(2),p3=$G(actual(3))
	I p3?1a.an1"."1a.an S actual(2)=actual(3) D procPar^UCDB(.fsn,1) S p3=actual(2)
	;
	S return="SETERR^DBSEXECU("_p1_",""MSG"","_p2
	I $E(p3,$L(p3))="," S p3=$E(p3,1,$L(p3)-1)	; Remove extra comma
	I p3'="" S return=return_","_p3
	S return=return_")"
	Q
	;-----------------------------------------------------------------------
rollback	;Rollback a transaction to a starting point 
	;
	; If RDB, generates labels - vRunRbkN and vRunRbkS
	;-----------------------------------------------------------------------
	new saveptr
	S saveptr=$$QSUB^%ZS($g(actual(1)))
	;
	; Remove D command
	S mcode=$$backup^UCGM(mcode)
	I mcode="" S mcode=$C(9)
	E  S mcode=mcode_" "
	;
	S return=""
	;
	; Oracle must rollback to %OrcPoints(saveptr)
	; Oracle issues a rollback to last commit if no
	; savepoint parameter is passed in - CR8287
	;
	; If we aren't rolling back to an application save point, need to check
	;   to see if there is an delayed commit save point set (vRunSvPt) - see
	;   commit section.  If so, roll back to that point, and then commit
	;   the previously uncommitted updates.
	;
	I $$rdb^UCDBRT() D  Q
	.	I saveptr'="" D
	..		N label
	..		S label="vRunRbkS"
	..		I postCond="" S return="D:$TLEVEL "_label_"("_saveptr_")"
	..		E  S return="D:("_$E(postCond,2,$L(postCond))_")&$TLEVEL "_label_"("_saveptr_")"
	..		I $D(labels(label))#2 Q		; Already exists
	..		S labels(label)=""
	..		D addSubr^UCGM(label,"(vSavePtr)","RDB rollback to save point")
	..		D append^UCGM($C(9)_"N vEr,vRm",label)
	..		D append^UCGM($C(9)_"TROLLBACK vSavePtr",label)
	..		D append^UCGM($C(9)_"S vEr=$$EXECUTE^%DBAPI(0,""ROLLBACK TO save_point_""_vSavePtr,$C(124),"""",.vRm)",label)
	..		D append^UCGM($C(9)_"I vEr<0 S $ZS=""-1,""_$ZPOS_"",%PSL-E-ROLLBACKFAIL,""_$G(vRm) X $ZT",label)
	..		D append^UCGM($C(9)_"Q",label)
	.	E  D
	..		N label
	..		S label="vRunRbkN"
	..		I postCond="" S return="D:$TLEVEL "_label
	..		E  D
	...			I postCond'="restart logic" S return="D:("_$E(postCond,2,$L(postCond))_")&$TLEVEL "_label
	...			E  S return="D:($TRESTART)&($TLEVEL=1) "_label
	..		I $D(labels(label))#2 Q		; Already exists
	..		S labels(label)=""
	..		D addSubr^UCGM(label,"","RDB rollback (no save point)")
	..		D append^UCGM($C(9)_"N vEr,vRm,vRmsg",label)
	..		D append^UCGM($C(9)_"TROLLBACK ",label)
	..		D append^UCGM($C(9)_"I $G(vRunSvPt) D",label)
	..		D append^UCGM($C(9)_"."_$C(9)_"S vEr=$$EXECUTE^%DBAPI(0,""ROLLBACK TO vRunSvPt"",$C(124),"""",.vRm)",label)
	..		D append^UCGM($C(9)_"."_$C(9)_"I vEr<0 S vRmsg=""ROLLBACKFAIL""",label)
	..		D append^UCGM($C(9)_"."_$C(9)_"E  S vEr=$$COMMIT^%DBAPI(0,.vRm) I vEr<0 S vRmsg=""COMMITFAIL""",label)
	..		D append^UCGM($C(9)_"E  S vEr=$$EXECUTE^%DBAPI(0,""ROLLBACK"",$C(124),"""",.vRm) I vEr<0 S vRmsg=""ROLLBACKFAIL""",label)
	..		D append^UCGM($C(9)_"S (vRunCmCt,vRunSvPt)=0",label)
	..		D append^UCGM($C(9)_"I vEr<0 S $ZS=""-1,""_$ZPOS_"",%PSL-E-""_vRmsg_"",""_$G(vRm) X $ZT",label)
	..		D append^UCGM($C(9)_"Q",label)
	;
	I saveptr'="" S return="Trollback:$Tlevel "_saveptr_" "
	E  S return="Trollback:$Tlevel "
	Q
	;-----------------------------------------------------------------------
start	;Begin a transaction fence
	;
	; If RDB, generates label - vRunCmtF
	;-----------------------------------------------------------------------
	;
	N param1,param2,param3,rollback
	S return=""
	S param1=$$QSUB^%ZS(actual(1))
	I param1'="CS",param1'="BA" D ERROR^UCGM("Transaction ID required") quit
	set param2=actual(2)
	;
	; if sourcecode contained Runtime.start(,array()), then UCGM will force
	; the pass-by-reference
	if $E(param2)="." set param2=$e(param2,2,$l(param2))
	else  if $E(param2)="""" set param2=$$QSUB^%ZS(param2)
	I param2="" S param2="vobj"
	else  if param2'="*",param2'["vobj" s param2=param2_",vobj"
	set param3=$$QSUB^%ZS(actual(3))
	;
	; Add code to deal with restart if not on MDB - generate call to vRunRbkN
	; but save it to append after the TSTART is issued.  Note that I also changed
	; the order of the Oracle save point call and TStart since the final code
	; needs to look like:
	;
	;	TSTART D:$TRESTART&($TLEVEL=1) vRunRbkN D OracleSavePoint
	;
	; This also changed the rollback section above to look for the postCond
	; containing "restart logic".  Want postCond to contain something that
	; is invalid as a real postCond that could be passed to rollback.
	;
	I $$rdb^UCDBRT() D
	.	N actual,mcode,postCond
	.	S mcode="",actual(1)=""
	.	S postCond="restart logic"
	.	D rollback
	.	S rollback=return
	;
	set return=""
	if param3'="" do
	.	set return="S "_param3_"=$Tlevel "
	.	if '$$getInst^UCGM(param3) do setInst^UCGM(param3,msrc+1,"")
	if param2="*" S return=return_"Tstart *"
	else  set return=return_"Tstart ("_param2_")"
	set return=return_":transactionid="""_param1_""""
	;
	if $$rdb^UCDBRT() D
	.	S return=return_" "_rollback
	.	;if ORACLE,param3 S return=return_"S %OrcPoints($Tlevel)=CALL OUT TO GET SAVEPOINT"_ " "
	.	I param3'="" S return=return_" N vEr,vRm S vEr=$$EXECUTE^%DBAPI(0,""SAVEPOINT save_point_""_"_param3_",$C(124),"""",.vRm) S:(vEr<0) $ZS=""-1,""_$ZPOS_"",%PSL-E-TRANSTARTFAIL,""_$G(vRm) X:(vEr<0) $ZT"
	;
	S mcode=$E(mcode,1,$L(mcode)-2)		; remove "D " from generated code
	;
	; Set up clean-up code when leave this subroutine - finish commits
	; Note that we do this regardless of the transactionID (CS or BA) for the
	; transaction since we may be doing nested TP and don't commit to the RDB
	; until the final commit ($TLevel=0)
	I $$rdb^UCDBRT() D
	.	set type(0,"Runtime")="Runtime"_tab_(msrc+1)_tab_"NEW"_tab_(msrc+1)
	.	set $P(type(0,"Runtime"),tab,11)=param1		; Save CS or BA transaction ID
	.	do commitF()
	Q
	;
	;;append(code,label)
	;;D append^UCGM(code,label) Q
	;;ERROR(message)
	;;D ERROR^UCGM(message) Q
	;----------------------------------------------------------------------
xbad	; Called by Runtime.setErrXBAD method
	;----------------------------------------------------------------------
	; syntax: do Runtime.setErrXBAD
	;         (object,error_code,column,current_value,alternate_value)
	;
	;----------------------------------------------------------------------
	N i,expr,save2
	S save2=actual(2)
	S expr="SETERR^DBSEXECU("_actual(1)_",""XBAD"","_actual(2)
	I $G(actual(4))?1a.an1"."1a.an S actual(2)=actual(4) D procPar^UCDB(.fsn,1) S actual(4)=actual(2)
	I $G(actual(5))?1a.an1"."1a.an S actual(2)=actual(5) D procPar^UCDB(.fsn,1) S actual(5)=actual(2)
	S actual(2)=save2
	F i=3:1:5 I $G(actual(i))'="" S expr=expr_","_actual(i)
	S return=expr_")"
	Q
