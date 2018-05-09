UCTS	;wittef;2007-12-13 19:22:00;Library of Transaction Set Class Methods
	;;Copyright(c)2003 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/16/03 12:31:59 - SPIER
	; ORIG: MATTSON - 04/07/98
	; DESC: Library of Class TranSet methods
	;
	; KEYWORDS: Transaction processing
	;
	; I18N=QUIT
	;-----------------------------------------------------------------------
	; LIBRARY:
	;	copyTran	Copy transaction object to transaction set
	;	getTran		Get transaction from transaction set
	;	postTSet	Post transaction set
	;
	;-----------------------------------------------------------------------
	; The purpose of the TranSet class is to provide the ability to store up
	; transaction data of multiple transactions, and pass them to a
	; transaction driver. Originally in the 6.x versions, it was bridging a
	; gap between PSL procedures/batches and an M based transaction driver
	; TTXP2.m. In Profile04, the new transaction driver TRNDRV.PROC is in
	; PSL, yet the "bridge" still exists.
	; The TranSet object is used as a container for transactions. It allows
	; one to build up a set of transactions, by copying parts of the ttx
	; data into the TranSet object. Using the TranSet class requires pretty
	; good knowledge of the transaction driver(s).
	;
	; To be more precise, a TranSet object will serve as a containter for
	; all properties of a RecordTTX instance except the properties that
	; represent the primary key of a TTX row (i.e. the non-key-data).
	; Within the TransSet container, individual non-key-data multi values
	; are indexed by a sequence number. This number will be returned by
	; TranSet.copyTran(), and needs to be supplied to TransSet.getTran().
	; - The copyTran() method will copy TTX non-key-data into the TranSet
	;   object.
	; - The getTran() method can be used to retrieve the TTX non-key-data of
	;   a single row from the TransSet instance.
	; - The postTSet() method is used to "post" all TTX non-key-data, using
	;   a common (TJD,BRCD) pair.
	;   The implementation of the postTSet() depends on the "transaction
	;   driver" that is available at compile time:
	;   - When only TTXP2 is available, each non-key-data multi value is
	;     copied into a one dimensional array TR(), that is passed to TTXP2
	;   - When TRNDRV is available, a RecordTTX instance is constructed that
	;     contains all non-key-data and the supplied values for TTX.TJD and
	;     TTX.BRCD. The remaining keys (TTX.UID and TTX.TSEQ) will be
	;     supplied as "".
	;   In both cases, all non-key-data that is present at return from the
	;   call to the transaction driver will be copied back into the
	;   TranSet's container.
	;
	; Because the TranSet object only stores property values of a RecordTTX
	; instance, the data in a TranSet object can hardly be used in an RDB
	; environment: All information about properties that changed in the
	; RecordTTX object (-150 tree) is lost when the data is copied into a
	; TranSet object, and unavailable when the data is retrieved from the
	; TranSet object, or when TranSet.postTset() passes non-key-data in a
	; RecordTTX object to the transaction driver.
	;
	;----- Revision History ------------------------------------------------
	; 10/20/2008 - RussellDS - CR35741/35918
	;	Modified postTSet to eliminate use of third parameter.
	;
	; 09/09/2008 - RussellDS - CR30801
	;	* Modified copyTran, getTran, and post to consider the negative
	;	  nodes -1 through -6, as well as -161 and -162
	;	* Removed obsolete postOld section and related sections that
	;	  it used
	;
	; 07/18/07 - Frans S.C. Witte - CR: 27800
	;	* Modified call to $$newObj^UCCLASS().
	;	* Replaced $D(labels()) with $$hasSubr^UCGM()
	;	* Added TTXOBJS,TRNDRVI,TRNPSSTK to the NEW in post()
	;
	; 01/24/07 - Frans S.C. Witte - CRs: 24902 / 24903 / 24974
	;	Replaced invalid 8-bit characters (all Windows "smart" chars) by
	;	their ASCII equivalent.
	;
	; 07/11/06 - Frans S.C. Witte - CRs: 22720 / 22061
	;	* Modified getTran to conform to current coding practices.
	;
	; 06/12/06 - Frans S.C. Witte CRs: 21158 / 18164
	;	* Corrected bug in code for getTran.
	;
	; 03/06/06 - Frans S.C. Witte CRs: 20280 / 18164
	;	* Modified code generated for TranSet.getTran() to return a
	;	  well-formed RecordTTX object (all 4 keys empty).
	;
	; 02/02/06 - Pete Chenard, Frans S.C. Witte - CRs: 18163 / 18164
	;	* Modified post section to referece TPD as the key rather than
	;	  TJD.
	;	* Modified call to newObj^UCCLASS()
	;	* Added NOTE on call to $$VERSION^TRNDRV from postTSet.
	;	* Subroutine post now initiates all 4 key columns of the TTX
	;	  object (UID and TSEQ will both be "").
	;
	; 01/23/06 - Pete Chenard - CR19046
	;	* Modified post section to set up key levels in vobj array for new
	;	  objects.
	;
	; 05/26/05 - RussellDS - CR16079
	;	* Added transactionID = "CS" for TP in the post section
	;	* Added documentation to the postOld section to explain why there
	;	  is no TP there
	;
	; 05/19/05 - Frans S.C. Witte - Crs 16031 / 16032
	;	Subroutine postOld(): non-numeric subscripts are no longer copied
	;	from vobj(oid,*) into TR(*). Note that vobj(oid,"status") will
	;	only exist if a TranSet.postTSet() is called more than once for
	;	the same TranSet instance: vobj(oid,"status") is created by this
	;	subroutine. Since vobj(oid,"status") is not reset in the
	;	subroutine, the interpretation of its value after the return
	;	from the repeated call may be difficult to interpret.
	;
	; 04/13/05 - Frans S.C. Witte - CRs 15411 / 15422
	;	* Subroutine post(): corrected value assigned to TranSet.status
	;	  property (real truthvalue)
	;	* Replaced function $$getAcnobj() by subroutine getAcnObj() to
	;	  conform to Object conventions (Object.exist()), and changed
	;	  subroutine post() to use the new signature.
	;	* Replaced calls to subroutine copyobj() by M Merge commands
	;	  (2 occurrences), and commented out subroutine.
	;	NOTE: The modifications only impact P04, because code generated
	;	for P01 will call postOld() instead of post().
	;
	; 05/13/04 - RussellDSR - CR9172
	;	     Incorporated option to support both new transaction posting
	;	     in Profile04 and later, as well as continued support for
	;	     prior logic.  This was done in postTset section and by
	;	     adding a postOld section.
	;
	; 05/12/04 - RussellDS - CR9676
	;	     Move Profile04 version to Profile01 to support single code
	;	     base for PSL.
	;
	; 05/16/03 - Spier - 51423
	;	     Modiied Post section to call trndrv instead of ttxp2,
	;	     and pass objects to it when the account has been
	;	     instantiated by the process calling transet posting.
	;
	; 02/25/03 - SPIER - 51423
	;            Modified getTran to use the methods array.
	;
	;-----------------------------------------------------------------------
	;
	;----------------------------------------------------------------------
copyTran ;public;method copyTran;Copy transaction obj to transaction set
	;----------------------------------------------------------------------
	;
	; EXAMPLE:  set seq=ts.copyTran(tranObj,.TTXBLD,1.01)
	;----------------------------------------------------------------------
	;
	i $G(actual(1))="" d ERROR^UCGM("Required") q
	s actual(2)=$g(actual(2))
	s actual(3)=$g(actual(3))
	s actual(4)=$g(actual(4))
	i actual(4)'="",actual(4)'["SYSTEM",actual(4)'["SECONDARY" d ERROR^UCGM("Sub-Sequence must have value SYSTEM or SECONDARY") q
	;
	i return'="" s return=return_"("_objectName_","_actual(1)_","_actual(2)_","_actual(3)_")" q
	;
	s label=$$newLabel^UCGM("TSet",.labels)
	d addSubr^UCGM(label,"(TSet,tranObj,colRefs,tranSeq)",class_"."_method)
	;
	d append(tab_"s "_oLvn_"(tranObj)=$G("_oLvn_"(tranObj))",label)
	d append(tab_"d TTX^TTXBLD(tranObj,.colRefs)",label)
	d append(tab_"n i,seq",label)
	;
	I actual(4)'="" D
	.	I actual(4)["SYSTEM" S string="($O("_oLvn_"(TSet,tranSeq*1000\1/1000+.001),-1)*1000\1/1000)+.001"
	.	E  S string="$O("_oLvn_"(TSet,tranSeq*1000\1/1000+.001),-1)+.000001"
	.	d append(tab_"S tranSeq="_string,label)
	d append(tab_"i $G(tranSeq) s seq=tranSeq",label)
	d append(tab_"e  s seq=$O("_oLvn_"(TSet,""""),-1)\1+1 i seq<1 s seq=1",label)
	d append(tab_"s "_oLvn_"(TSet,seq)="_oLvn_"(tranObj)",label)
	d append(tab_"s "_oLvn_"(TSet,seq,-2)=0",label)
	d append(tab_"f i=-1,-3:-1:-6 i $d("_oLvn_"(tranObj,i)) s "_oLvn_"(TSet,seq,i)="_oLvn_"(tranObj,i)",label)
	d append(tab_"f i=-161,-162 i $d("_oLvn_"(tranObj,i,""0*"")) s "_oLvn_"(TSet,seq,i,""0*"")="_oLvn_"(tranObj,i,""0*"")",label)
	d append(tab_"q seq",label)
	;
	s return="$$"_label_"("_objectName_","_actual(1)_","_actual(2)_","_actual(3)_")"
	s formal="*"
	q
	;
	;----------------------------------------------------------------------
getTran ;public;method getTran;Get transaction object from transaction set
	;----------------------------------------------------------------------
	; Generated subroutine returns a new RecordTTX instance with:
	; - RecordMode = 0
	; - primary key (1-4) IS NULL
	; - non-key data from requested TranSet element
	;
	; NOTES:
	; . This uses knowledge of the number of keys of table TTX
	;
	if actual(1)="" do ERROR^UCGM("Parameter Required") quit
	;
	new cmt
	set cmt="TranSet.getTran"
	;
	set label=$$findSubr^UCGM("TStGet",cmt)
	set return="$$"_label_"("_$$newObjSt^UCCLASS(var)_","_objectName_","_actual(1)_")"
	if $$hasSubr^UCGM(label) quit
	;
	do addSubr^UCGM(label,"(vS,vTSt,vTseq)",cmt)
	;
	do append(tab_"n vRet",label)
	;
	do append(tab_"s vRet="_$$newObj^UCCLASS("RecordTTX","vS"),label)
	do append(tab_"merge "_oLvn_"(vRet)="_oLvn_"(vTSt,vTseq)",label)
	do append(tab_"q vRet",label)
	quit
	;
	;----------------------------------------------------------------------
postTSet ;method postTSet;Post transaction set
	;----------------------------------------------------------------------
	;
	; EXAMPLE:  do ts.postTSet(TJD,BRCD,.par)
	;
	; NOTES:
	; - The call to $$VERSION^TRNDRV at compile time is a violation of the
	;	Framework Upgrade Rules. If the version number to be returned by
	;	$$VERSION^TRNDRV is ever incremented, pre-upgrade / post-upgrade
	;	version mismatches will occur, and need to be handled.
	; - This method used to take three parameters.  actual(3) was parameters
	;	to be used for TTXP2 calls.  It no longer has relevance for TRNDRV.
	;	Because this method is deprecated, instead of requiring modification
	;	of callers to remove the third parameter, it is just ignored here.
	;	Eventually, all callers should be changed to call TRNDRV directly.
	;----------------------------------------------------------------------
	i $G(actual(1))="" d ERROR^UCGM("Parameter 1 required - postTSet")
	i $G(actual(2))="" d ERROR^UCGM("Parameter 2 required - postTSet")
	;i $G(actual(3))="" d ERROR^UCGM("Parameter 3 required - postTSet")
	;
	s return="post^UCTS("_actual(1)_","_actual(2)_","_objectName_")"
	s formal="Transaction"
	q
	;
	;----------------------------------------------------------------------
post(TPD,BRCD,ttx,par) ;public;Post transactions
	;----------------------------------------------------------------------
	;
	; ARGUMENTS:
	;     .TPD	Teller posting date		TYP=D/MECH=VAL/REQ
	;
	;     .BRCD	Branch code			TYP=N/MECH=VAL/REQ
	;
	;     .ttx	A pointer to the TranSet	TYP=N/MECH=REF/REQ
	;		object which contains an array
	;		of non key data strings of
	;		TTX (transaction) objects.
	;
	;     .par	Processing qualifiers		TYP=T/MECH=REFARR/REQ
	;		(For details, refer to
	;		the documentation in
	;		TTXP2.)
	;
	; NOTES:
	; . This subroutine passes %TRNMODE=4 to TRNSINGL^TRNDRV. This means
	;	that TRNNDRV will treat the RecordTTX object as a system
	;	generated transaction which means that it does not get filed to
	;	TTX. If %TRNMODE is ever going to be changed, to a value that
	;	would update TTX we'd likely have problems.
	; . The handling of the TTX data is still questionable. The TTX object
	;	passed to TRNSINGL^TRNDRV will be well-defined, with TTX.UID=""
	;	and TTX.TSEQ="", but when TRNDRV modifies the TTX object, only
	;	changes to non-key columns will be copied back into the TranSet
	;	structure.
	;----------------------------------------------------------------------
	;
	new CID,obj,savePtr1,seq,%TRNMODE,ttxDup
	;
	; For each entry in the ttx container, copy it to
	; a new object for processing in TRNDRV. Determine if
	; the account for that record exists in vobj and pass it as well
	;
	; This processing assumes process and update system generated
	; transactions.
	;
	set savePtr1=$TLEVEL
	tstart (vobj):transactionid="CS"
	set seq=0
	for  set seq=$o(vobj(ttx,seq)) quit:+seq=0  do  quit:$G(ER)
	.	new RJ,acnDup,acnOrig,TTXOBJS,TRNDRVI,TRNPSSTK
	.	set ttxDup=$o(vobj(""),-1)+1
	.	merge vobj(ttxDup)=vobj(ttx,seq)
	.	set vobj(ttxDup,-3)=TPD
	.	set vobj(ttxDup,-4)=BRCD
	.	set vobj(ttxDup,-5)=""
	.	set vobj(ttxDup,-6)=""
	.	; Modify -161/-162 to reflect key changes
	.	if $d(vobj(ttxDup,-161)) do
	..		new ign
	..		set ign=$$rdbColUpd^UCDBRT(0,ttxDup,"S_TJD","0*","|",TPD)
	..		set ign=$$rdbColUpd^UCDBRT(0,ttxDup,"BRCD","0*","|",BRCD)
	..		set ign=$$rdbColUpd^UCDBRT(0,ttxDup,"S_UID","0*","|","")
	..		set ign=$$rdbColUpd^UCDBRT(0,ttxDup,"TSEQ","0*","|","")
	.	;
	.	; FSCW CR15411: TRNSINGL^TRNDRV requires a RecordACN instance,
	.	; and "" is not a valid value in this case.
	.	;;set acnDup=$$getAcnobj^UCTS(ttxDup,.acnOrig)
	.	do getAcnObj^UCTS(ttxDup,.acnOrig,.acnDup)
	.	;
	.	set %TRNMODE=4		; system generated
	.	do TRNSINGL^TRNDRV(ttxDup,.acnDup,TPD,BRCD,%TRNMODE,.RJ)
	.	kill RJ(1,"HIST")
	.	;
	.	; Update the transaction and transaction container objects to
	.	; reflect changes made by the transaction
	.	if '$G(ER) do
	..		set vobj(ttx,seq)=vobj(ttxDup)
	..		;
	..		; no errors, then reset the calling program's object to
	..		; reflect the change that occurred during processing.
	..		; Do this only if we did find an ACN object. The check
	..		; MUST use acnOrig, because TRNDRV may pass back a value
	..		; in acnDup, regardless of acnDup.exists() before the call.
	..		if '$D(acnOrig) quit
	..		kill vobj(acnOrig)
	..		;
	..		; CR15411: use M MERGE command to copy object
	..		;;do copyobj(acnDup,acnOrig)
	..		merge vobj(acnOrig)=vobj(acnDup)
	.	set $P(vobj(ttx,"status"),"|",seq)=''$D(RJ)
	.	kill vobj(ttxDup)
	.	if $D(acnDup) kill vobj(acnDup)
	;
	if $G(ER) trollback:$TLEVEL savePtr1 quit
	tcommit:$TLEVEL
	;
	quit
	;
	;----------------------------------------------------------------------
getAcnObj(ttxobj,vOrig,vDup) ;local void; Return pointer to object already established for the account
	;----------------------------------------------------------------------
	; Arguments:
	; . ttxobj = ttx pointer				/TYP=N/MECH=VAL/REQ
	; . vOrig = account pointer	 			/TYP=N/MECH=REF:W/REQ
	;	Supplied value will be overwritten
	; . vDup = pointer to replicated account object	/TYP=N/MECH=REF:W/REQ
	;	Shall be undefined at input
	;
	; OUTPUT:
	; . vOrig = pointer original account object
	;	If undefined at output, no matching account has been found.
	; . vDup - pointer to replicated account object
	;	If undefined at output, no matching account has been found.
	;	If defined, the object contains a copy of the account record.
	;
	; NOTES:
	; . If multiple instances of the same RecordDEP (RecordLN) account are
	;	present in vobj(), the one with the lowest Object ID will be
	;	returned. This is likely to correspond to the "oldest" instance.
	; . Only non-optimized occurrences of RecordDEP (RecordLN) will be found.
	; . This is very hard-coded !!
	;
	new CID,obj
	set CID=$$TRANCID^TRNUTL(.ttxobj)
	set (obj,vOrig)=""
	for  set obj=$o(vobj(obj)) quit:obj=""  do  quit:vOrig
	.	if $P(vobj(obj,-1),$C(9))="RecordDEP",$g(vobj(obj,-3))=CID set vOrig=obj
	.	else  if $P(vobj(obj,-1),$C(9))="RecordLN",$g(vobj(obj,-3))=CID set vOrig=obj
	if vOrig do
	.	set vDup=$o(vobj(""),-1)+1
	.	;
	.	; CR15411: use M MERGE command to copy object
	.	;;do copyobj(vOrig,vDup)
	.	merge vobj(vDup)=vobj(vOrig)
	else  kill vOrig
	quit
	;
	;----------------------------------------------------------------------
append(code,label) ;
	;----------------------------------------------------------------------
	;
	d append^UCGM(code,label)
	q
