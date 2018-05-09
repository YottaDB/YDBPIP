UCRECORD ;wittef;2008-03-10 12:55:00;Library of RecordTABLE methods
	;;Copyright(c)2003 Sanchez Computer Associates, Inc.  All Rights Reserved
	; ORIG: FSANCHEZ - 01/15/98
	; DESC: Library of Record<class> methods
	;
	; KEYWORDS:	DATABASE
	;
	;---------- Comments ---------------------------------------------------
	; The M implementation of the Record class and its descendants either
	; uses the standard vobj(,) model, or uses the voXN model, in which each
	; node is mapped to a separate unsubscripted lvn. See UCREC4OP for a
	; description of the relationship between the two models, and the
	; criteria to use one or the other. See UCXDD for details of code that
	; manipulates the special purpose nodes/trees.
	;
	; The Record class uses the following special purpose nodes, in addition
	; to the special purpose nodes of the Reference class:
	; vobj(oid,-2) = Record mode (0 = insert, 1 = update, 3 = delete)
	; vobj(oid,-2 - keyOrdinal) = value of the keyOrdinal-th primary key column
	; vobj(oid,-99) = archive global environemnt
	;	For archived MDB tables, the environemnt name for the extended
	;	global reference is stored in this node.
	; vobj(oid,-100,) = change audit tree with:
	;	vobj(oid,-100,node) = 0 (modified) or 1 (not modified)
	;	vobj(oid,-100,node,colname) = oldval information
	; vobj(oid,-152) = host variable values list, with leading delimiter
	; vobj(oid,-161,nod) = column update list (see cdRdbAsn^UCXDD)
	; vobj(oid,-162,nod) = host variable values list (paired with -161)
	; vobj(oid,-400,colname) = 0 (suppress journal) or 1 (do not suppress)
	;	See UCCOLUMN and UCUTLN
	;
	;---------- Revision History -------------------------------------------
	; 2009-05-11 - RussellDS - CR40357
	;	* Fix problem in copySubf section causing sub-fields to not be
	;	  copied correctly.
	;
	; 2009-03-04, Frans S.C. Witte, CRs 35741/38252/38491
	;	* Removed some commented-out code
	;	* subroutine save() now alwyas generates code that calls the
	;	  filer if a Blob or Memo is present (prevents BADCHAR in UTF-8)
	;
	; 2009-01-12, Frans S.C. Witte, CR 37558
	;	* Modified copy() to generate code that uses the runtime class
	;	  name and if-else blocks to incrementally load the (remaining)
	;	  child nodes). The code inside these blocks are constructed by
	;	  PSLTable.getLoadCode().
	;
	; 2008-06-03, Frans S.C. Witte, CR 35741/35918
	;	* isChanged() now generates code that calls rtOldCode^UCXDD(,,0)
	;	  it also uses parenthesis to enforce a single expratom.
	;	* setMode() now calls caPslCln^UCXDD() instead of getPslCln.
	;
	; 03/04/2008 - RussellDS - CR30801
	;	* Removed new section.  Record constructor is now all in
	;	  classNew^DBSDYNRA
	;	* Modified setAudit section to ignore attempts to turn off the
	;	  audit flag for tables with UPDATE_RESTRICT access rights.
	;	* Remove descendants sub-routine since Record Classes now
	;	  contain the inheritance behavior
	;	* Added getPurVar() and modified getArchiveVar() and
	;	  getModeVar() to use it.
	;	* Modified overlay to generate code that calls propSet^DBSDYNRA
	;	  instead of calling dynamic^UCCOLUMN to return that call.
	;	* Modified isChanged() to test new value '= old value
	;
	; 09/21/07 - Russell - CR29295
	;	* Add new parameters to calls to getUpdCode^UCXDD and
	;	  getRdbAsn^UCXDD.
	;	* Modified new to add LVL parameter = 1 for call to
	;	  caPslTbl^UCXDD.  Need blob/memo data for getNewCode call.
	;	* Added check that TARGET of copyDiff is recordType 1 (as well).
	;
	; 05/30/07 - Frans S.C. Witte - CR: 27800 / 27491
	;	* Replaced commands(,) by pslPrsr(,)
	;	* Replaced $D(labels()) with $$hasSubr^UCGM()
	;	* Corrected code that fills vobj(,-100,) for Record.fromArray()
	;	* replaced calls to $$getReTable^UCGM() by calls to
	;	  $$tableNameOf^PSLClass.
	;	* Turn off optimize of RDB target in copyDiff
	;	* modified setMode to deal with setMode(0)+MDB+autlog+audit
	;
	; 08/20/07 - KWANL / Frans S.C. Witte - CR 28995
	;	* Adapted to new CATCH/THROW mechanism
	;
	; 05/30/07 - Frans S.C. Witte - CR: 27486
	;	* Added support for PSLParser.getSetting("DEBUG","DBIOCOUNT")
	;	  in save
	;	* Removed dead-code sections
	;
	; 23/03/07 - RussellDS - CRs 26386
	;	* Changes to support archiving
	;	   - Added fromArchive method
	;	   - Modified copy to consider archiving when loading nodes
	;	   - Modified toString to consider archiving when loading nodes
	;
	; 18/01/07 - Frans S.C. Witte - CRs: 24899 / 24925
	;	Subroutine new: removed code that (incorrectly) inserted -150
	;	assignments for wide tables (now handled by $$getUpdCode^UCXDD).
	;
	; 10/19/06 - Frans S.C. Witte - CRs: 23841 / 23842
	;	* Added InstMode parameter in call to $$insByOvs^UCREC4OP
	;
	; 09/06/06 - Frans S.C. Witte - CRs: 22719 / 20613
	;	* Modified save and saveNoFl to allow UCREC4OP to insert calls
	;	  that include direct SQL statements for INSERT and/or UPDATE.
	;	* Removed resetlod and call to it from copytf()
	;	  (creates dbLoad(,,) nodes).
	;	* Subroutine copyDiff() now turns off optimzation of source
	;	* Modified setMode for expr>0 and RDB to force -151 node
	;
	; 08/14/06 - Frans S.C. Witte - CRs: 22720 / 22274
	;	Corrected overlay to new class.
	;
	; 07/05/06 - Frans S.C. Witte - CRs: 21397 / 21937
	;	Rewrote save* in anticipation of save optimize for RDB.
	;
	; 05/24/06 - Frans S.C. Witte - CRs: 21394 / 21395
	;	* Added support for save without filer of "negative nodes".
	;	* Code generated for blob/memo store now uses PSL.maxDataLength.
	;	* Code for Record.copy() (copy same) rewritten to deal with nodes
	;	  that require special incremental load code.
	;
	; 05/09/06 - Frans S.C. Witte - CRs: 21101 / 18164
	;	* /NOVALFK qualifier removed from Record.bypassSave() implied
	;	  qualifiers (to ensure consistent behavior for MDB and RDB).
	;	* Subroutine save:
	;	  Added support for tables with PSLTble.isAutoLog=1.
	;
	; 03/20/06 - Frans S.C. Witte - CRs: 20280 / 18164
	;	* All calls to addSubr^UCGM now supply all 3 parameters.
	;	* Corrected copy-to-same when recordType>1, and no primary key
	;
	; 03/07/06 - Frans S.C. Witte - CRs: 19821 / 18164
	;	* Record.overlay is now noted as instantiation through parameter
	;	  passing
	;
	; 01/11/06 - Frans S.C. Witte - CRs: 18163 / 18164
	;	* Added support for dbAcc()
	;	* setCreate/setUpdate now call forceMode^UCREC4OP, editMode
	;	  commented out.
	;	* $$rdb^UCDBRT() changed to $$rtIsRdb^UCXDD() (7 occurrences)
	;	* Code generated by saveNoFl now uses v* lvns and supports blob
	;	  and memo columns for all recordTypes.
	;	* $$isBlob commented out (no longer used)
	;	* Added support for Record.save() and Record.bypassSave() of
	;	  dynamic Record instance.
	;
	; 01/10/06 - Frans S.C. Witte - CRs: 19000
	;	* Corrected DILIST and compare
	;
	; 12/13/05 - Frans S.C. Witte - CRs: 18727 / 18728
	;	* Subroutine compare rewritten
	;
	; 10/13/05 - Frans S.C. Witte - CRs: 15592 / 15593
	;	* replaced call to fsn^DBSDD by call to fsn^SQLDD.
	;	* Replaced pslSchCln() by pslCln(), and pslSchTbl() by pslTbl().
	;	* Replaced SchemaTable by PSLTable.
	;	* Corrected problem in code generated by copyDiff.
	;
	; 06/17/05 - Frans S.C. Witte - CR16346
	;	* Modified calls to $$getGbl^UCDB()
	;	* Record mode now set to 1 after .save() / .bypassSave() and for
	;	  RDB the -151 mode will be updated
	;	* bypassSave() now equivalent to
	;	  save("/NOJOURNAL/NOTRIGAFT/NOTRIGBEF/NOVALDD/NOVALFK/NOVALREQ/NOVALRI/NOVALST")
	;	* Modified save to handle former bypassSave cases (no filer).
	;	* Modified copyDiff and new.
	;	* created local function $$getModeVar() to generate access to
	;	  record mode.
	;	* Commented out ET.
	;	* Corrected copy (dynamic load)
	;	* RdbFetch no longer SETs -150 of keys
	;	* Corrected netNodes() (and subroutines it calls)
	;	* subroutine lodData: fix loading Blob/Memo for recordType=1
	;	* subroutine setMode: replaced reference to node "ORACLE"
	;	* subroutine RdbFetch: force loading of complex computeds
	;
	; 06/17/05 - RussellDS, Frans S.C. Witte - CR16344
	;	* RbypassSave section - add quit after call to filer in generated
	;	  code.
	;	* Subroutine RdbFetch: renamed variables in generated code to
	;	  start with 'v'.
	;
	; 06/05/05 - RussellDS - CR16207
	;	* Modified save, bypassSave, and RbypassSave sections to generate
	;	  TP code (start/commit) if $TLevel=0, i.e., in the event the
	;	  application is managing TP.  Added saveTP section to support
	;	  this.
	;	* Modified setMode to add quit for masterfields or computeds when
	;	  constructing -150 node for RDBs.
	;
	; 05/19/05 - Frans S.C. Witte - CRs: 15028 / 16039
	;	* $$rdb^UCDB() changed to $$rdb^UCDBRT() (9 occurrences)
	;	* added subroutine getTable that returns the code for the method
	;	  Record.getTable().
	;	* Subroutine compare: Assignments to struct("s",,,) and
	;	  vobj(oid,) conform to revised use of select-list and
	;	  select-types.
	;	* Subroutine compare: set keys=$C(254) ==> set keys="$C(254)"
	;	* Subroutine overlay rewritten.
	;	* Subroutine isChanged now uses ^UCXDD utility functions
	;	* subroutine setMode: added $G() around all vobj(obj,nod) and
	;	  vobj(obj) access. Noted that this code does not handle
	;	  blob/memo.
	;
	; 05/15/05 - Frans S.C. Witte - CRs 15210 / 15211
	;	* Subroutine setAudit: removed $GET() (actual(1) is always
	;	  defined)
	;	* Subroutine compare: code generated for vOpen() now correctly
	;	  sets vobj(diffobj,0)=0 (instead of "") when resultset is empty.
	;	  Generated code now always uses $G() when looking at nodes.
	;	* Changed ERROR^UCGM(.RM) to ERROR^UCGM($G(RM)) (4 occurrences)
	;	* subroutine copytf(): replaced 'ztbl' by 'table'.
	;	* subroutine bypassSave: corrected problem with code generated
	;	  for type 10/11 tables without key(s).
	;
	; 05/24/05 - Pete Chenard - 16087
	;	* Modified setMode section to create level -150 for all defined
	;	  columns in the record object if the mode is being changed to 0
	;	  and the database is RDB.
	;
	; 03/31/05 - GIRIDHARANB - CR15215
	;	* Subroutine save: included a call to the commit API when not in
	;	  TP
	;	* Subroutine RbypassSave: Modified the compiled code to check for
	;	  check for errors after every call to EXECUTE^%DBAPI.
	;
	; 02/07/05 - GIRIDHARANB - CR14407
	;	* Modified section bypassSave to pass 'table' into the rdb check
	;	  and new'ed ER and RM in section RbypassSave
	;	* Modified section isChanged to build the -100 level with the rdb
	;	  node when on a relational database.
	;
	; 01/12/05 - Frans S.C. Witte - CRs: 11398 / 11399
	;	* Subroutine netNodes(): use methods(subRou) to prevent DO-stack
	;	  overflow due to recursion.
	;	* Subroutine setAudit: removed extra "quit"
	;	* Subroutines Checkrec, Checkstck, and Stackbld:
	;	  Inserted SPACE between label and ";" to conform to M standard.
	;	* Inserted QUIT before first subroutine of this routine.
	;
	; 12/21/04 - Frans S.C. Witte - CRs 13403 / 13404
	;	Subroutine new: replaced "RECEXISTS" with "%PSL-E-RECEXISTS".
	;	Subroutine loddata: fixed construction of $ZS to conform to class
	;	Error, replaced "DBCREATEONLY" with %PSL-E-DBCREATEONLY", replaced
	;	"DBUPDATEONLY" with "%PSL-E-DBUPDATEONLY".
	;
	; 12/06/04 - Frans S.C. Witte - CRs 11445 / 11446
	;	Changed $D(pslPrsr("WARN",)) to $G(pslPrsr("WARN",)
	;	(2 occurrences)
	;
	; 10/26/04 - Frans S.C. Witte - CRs 11441, 12564 / 11442, 12565
	;	Subroutine getMode: Added initialization of actual(3) when
	;	transferring control to isDefined^UCDB.
	;	Generic copy method for Record.copy() and toString method for
	;	Record.toString are now in UCREF.
	;	Removed remaining code that generated kill -150 node in
	;	subroutines save and bypassSave.
	;
	; 09/22/04 - GIRIDHARANB - CR12285
	;	     Corrected a undefined error in section bypassSave (filerpgm)
	;
	; 09/17/04 - GIRIDHARANB - CR11515
	;	     Minor change in section RbypassSave to correct the parameters
	;	     being passed in to the filer.
	;
	; 09/13/04 - GIRIDHARANB - CR11860
	;	     Modified sections Rdbfetch to correct errors in the
	;	     incremental database loading. Section RbypassSave was changed
	;	     to not kill the -150 level of the object (this operation is
	;	     now done in DBSDBASE)
	;	     Also modified CopyDiff section to provide support for object
	;	     copy in a rdb (per Pete Chenard)
	;
	; 07/07/04 - Frans S.C. Witte - CR10940 (P04) / CR10941 (P01)
	;	     Modified subroutine acCaller() to take into account public
	;	     subroutines.
	;	     Modified subroutines lodData(), and netNodes() to use
	;	     variable 'dbLoad' in stead of 'dbload'.
	;	     Modified code generation for Record.copy() in subroutine
	;	     copyDiff() when columnvalue contains single quote (SQL
	;	     literal).
	;
	; 06/23/04 - RussellDS - CR10719 (P04) / CR10720 (P01)
	;	     Modified save, bypassSave and RbypassSave sections to remove
	;	     nodes -100 and -150 nodes after filing.  This cleans up
	;	     change history after the record has been filed.
	;
	; 06/04/04 - GIRIDHARANB - CR10186
	;	     Fixed section class.new to build level -150 for all versions of the
	;	     wide table. Also added check for fkeys being null before buidling the -150.
	;
	; 05/12/04 - RussellDS - CR9676
	;	     Move Profile04 version to Profile01 to support single code
	;	     base for PSL.
	;
	; 03/29/04 - RussellDS - CR9172
	;	     Integrate changes as part of move of filers to PSL.
	;
	;	     Includes FRS changes to add streamlined bypassSave for
	;	     filer.
	;
	;	     Corrected MEMO and BLOB loading under all state modes
	;            Also modified local test to avoid setting $T.
	;
	;	     Added coding to support Profile01 CR1390.  This modifies
	;	     the copyTf section.
	;
	;	     NOTE that support for CR1390 is not yet fully implemented.
	;	     This change just brings PSL in line across the versions.
	;
	;	     Added code to handle automatically treating ER and RM as
	;	     public scope for versions prior to Profile04.
	;
	; 02/02/04 - FSANCHEZ/KELLYP - 7813
	;	     Modified isChanged to accept no parameters and to return
	;	     whether or not the object has any changes in that case.  Also
	;	     corrected MEMO and BLOB loading under all state modes and
	;	     modified local test to avoid setting $T.
	;
	; 11/03/03 - Spier 51640
	;	     Corrected loading of MEMO AND BLOBS in lodData section.
	;	     They were being loaded from disk even if the object already
	;	     contained them.
	;
	; 10/28/03 - GIRIDHARANB - 51637
	;	     Modified RdbFetch Section to load the wide table, also
	;	     made minor fixes to correct the -150 level of the vobj
	;	     array.
	;
	; 10/16/03 - Spier -51640
	;	     Modified to correct handling of memo and blobs
	;
	; 09/10/03 - SPIER - 51623
	;            Modified getRecord section to properly deal with
	;	     recexists code when we are dealing with an object
	;	     array rather then an object. In this case, the rec exists
	;	     messages has to be tested closer to where the object is
	;	     being instantiated.
	;
	; 08/20/03 - FSANCHEZ
	;            Fixed data loading error when FORMAL scope object
	;            is instantiated
	;
	; 08/07/03 - FSANCHEZ 51423
	;            Fixed bugs in copyDiff related to %SystemKeywords
	;
	; 8/1/03  - GIRIDHARANB - 45497
	;	    Minor fixes to pass table parameter into the DBMAP check.
	;	    Also modified the call to where^UCDB with correct no of params
	;
	; 7/30/03 - Spier 51423
	;	    Added support in compare line tag for non-m database's.
	;
	; 7/11/03 - Spier
	;	    Added compare line tag.
	;	    Modified copydiff to account for numeric literal keys
	;	    Fix's to getMode label to deal with keyless tables
	;
	; 05/22/03 - Spier CR3795
	;	     Added section resetlod and a call to it,this corrects an error where
	;	     copy from an array needed to be recognized as a public instantiation.
	;
	; 3/13/03 - CHENARDP/GIRIDHARAN - 45497
	;	     Modified the rbypassSave section to return proper value
	;	     of ER after a database update/insert.Also modified getMode
	;	     section to just quit after returning the vobj reference at
	;	     the top of the section in case of an rdb
	;
	; 2/13/03 - Sanchez - 51423
	;            Modified lodData to fix issues with blob and optimized
	;            loading.  Also, indefined bug in new
	;
	; 02/03/02 - GIRIDHARAN - 45497
	;	     Modified the copy section to correct errors while copying
	;	     split tables objects. Fix to load appropriate split table
	;	     data on a wide table column reference.
	;
	; 11/21/02 - Sanchez - 51089
	;            Added ability to copy method to copy an object from
	;	     similar tables (hist to ttx)
	;
	; 11/18/02 - CHENARDP - 45497
	;	       Added support for Oracle and DB2
	;
	; 11/14/02 - Sanchez/SPIER - 51089
	;            Further v7.0 enhancements
	;
	; 07/22/02 - FSANCHEZ - 51089
	;	     Implemented object instantiation optimization and cache.
	;	     Modifications for v7.0 enhancements
	;-----------------------------------------------------------------------
	; I18N=QUIT
	quit
	;
	;-----------------------------------------------------------------------
copytf(opt) ; private; method Record.fromArray() and .toArray
	;-----------------------------------------------------------------------
	; ARGUMENTS:
	; . opt = copy direction
	;	0 = Record.fromArray()
	;	1 = Record.toArray()
	;
	; INPUTS:
	;
	; NOTES:
	; . The code references actual(3), but the method has only two arguments
	;	according to OBJECTMET. For this reason, references to actual(3)
	;	have been removed.
	; . The code also uses opt=2, but no calls are found that supply this
	;	value. The code has not yet been commented out.
	; . The code that implements .fromArray() copies UX(table,column) into
	;	vobj(oid,-100). This code needs to be adapted to reflect the
	;	current layout of vobj(oid,-100)
	; . The code that implements .fromArray() does not maintain the -150
	;	tree for RDB tables. In order to do that, the code would need to
	;	create and interpret PSLColumn descriptors at runtime for every
	;	column in the UX() array.
	;
	new code,i,key,keys,lvn,ref,rtyp,td,to,to1,z ;;,uvn
	;
	set ref=$$newLabel^UCGM("Met",.labels)
	;
	set lvn=actual(1)
	set kvn=$G(actual(2))
	;;set uvn=$G(actual(3))
	;
	set lvn=$$QSUB^%ZS(lvn),kvn=$$QSUB^%ZS(kvn) ;;,uvn=$$QSUB^%ZS(uvn)
	;
	if '$$isVar^UCGM($P(lvn,"(",1)) do ERROR^UCGM("Variable expected") quit
	;
	;;if '$D(fsn(table)) do fsn^SQLDD(.fsn,table) if ER do ERROR^UCGM(RM) quit
	;;;
	;;set z=fsn(table),keys=$P(z,"|",3),rtyp=$P(z,"|",4)
	set td=$$caPslTbl^UCXDD(.pslTbl,table,1),keys=$P(td,"|",3),rtyp=$P(td,"|",4)
	;
	; report error (RDB.fromArray) or deprecation warning (all others)
	if ($P(td,"|",8)'="GTM"),'opt do ERROR^UCGM("Record.fromArray() not supported on RDB; use Record.copy()") quit
	do WARNDEP^UCGM(2.6,0,"Record."_method_"(); use Record.copy()")
	;
	if lvn["(" S:$E(lvn,$L(lvn))'=","&($P(lvn,"(",2)'="") lvn=lvn_","
	else  set lvn=lvn_"("
	;
	if opt set from=oLvn_"(object,",to=lvn
	else  set from=lvn,to=oLvn_"(object,"
	;
	do addSubr^UCGM(ref,"(object)","Copy "_from_" to "_to)
	;
	if opt=0					; Add error checking
	if opt=2 do					; 12/28/99
	.	;
	.	set code="N %O,UX"
	.	if $P(fsn(table),"|",3)'="" S code=code_","_$P(fsn(table),"|",3)	; file short name
	.	set code=code_","_$E(to,1,$L(to)-1)
	;
	if $G(code)'="" do append(tab_code,ref)
	;
	if opt=2 do append(tab_"S %O=+$G("_oLvn_"(object,-2))",ref)
	;
	if kvn'="" for i=1:1:$L(kvn,",") do
	.	;
	.	new key,node
	.	set key=$P(kvn,",",i),node="-"_(i+2)
	.	if '$$isVar^UCGM(key),'$$isArr^UCGM(key) D ERROR^UCGM("Variable expected") Q
	.	if opt S code="S "_key_"=$G("_from_node_"))"
	.	else  S code="S "_to_node_")=$G("_key_")"
	.	do append(tab_code,ref)
	;
	if rtyp=1!(rtyp=11) do
	.	;
	.	new zfrom,zto
	.	set zfrom=$E(from,1,$L(from)-1),zto=$E(to,1,$L(to)-1)
	.	if zfrom["(" S zfrom=zfrom_")"
	.	if zto["(" S zto=zto_")"
	.	do append(tab_"S "_zto_"=$G("_zfrom_")",ref)
	;
	if rtyp>9 do
	.	;
	.	set from=from_"n)",to1=""
	.	if 'opt S to1=","_to_"-100,n)="""""
	.	set to=to_"n)"
	.	do append(tab_"N n s n=-.001",ref)
	.	do append(tab_"F  S n=$O("_from_") Q:n=""""  I $D("_from_")#2 S "_to_"="_from_to1,ref)
	.	;
	.	; Mark as access occurrence through method (endsWith("()"))
	.	; If this is fromArray, mark as bAudit and bAssign
	.	;;do setDb^UCCOLUMN(subRou,objectName)
	.	new dummy,hr set dummy=$$accByOvs^UCREC4OP(subRou,objectName,$$getClass^UCGM(objectName)_"."_method_"()",'opt,'opt,.hr)
	.	if 'hr do WARN^UCGM(objectName_" may not have been instantiated")
	.	;;if opt=0 do resetlod(subRou,objectName)
	;
	; 09/18/00 move memo and blob's into short name
	if rtyp=1 do
	.	;
	.	new isTyp
	.	if '$D(index(table)) N index do getValues^SQLDD(table,"TYP,CMP,SFD",.index)
	.	set isTyp=($D(index(table,"TYP","M"))!$D(index(table,"TYP","B")))
	.	if 'isTyp quit
	.	do append(tab_"I $D("_from_"1))#2 S "_to_"1)="_from_"1)",ref)
	;
	if rtyp>0 do
	.	;
	.	if opt quit
	.	if '$p(type(objectLevel,objectName),tab,12) quit
	.	;
	.	; Include code that copies UX() to vobj(,-100)
	.	; In particular:
	.	; - $P(UX(fid,column),"|",1) = old value
	.	; - $P(UX(fid,column),"|",6) = 1 to indicate suppress journal
	.	; - datatype in -100 forced to "T" !!
	.	; The code immediately below needs work: the value of node in
	.	; UX() is unknown for the top-node of rtyp=11 tables.
	.	; The code that has been included is more expensive because it
	.	; calls $$getPslCln^UCXDD and XECUTES $$getUpdAudit^UCXDD() at
	.	; runtime, but at least we know that the code that gets executed
	.	; will be correct for all values of rtyp.
	.	;;new dlm,zux,zsdf
	.	;;set dlm=$p(td,"|",10)
	.	;;set zux="UX("_""""_table_""""_",n)"
	.	;;set zsfd=$S(dlm=126:"$TR(sfd,""~"","";""",1:"sfd")
	.	;;;
	.	;;do append(" N fmtable,n,nod,ov,pos,sfd S n="""" F  S n=$O("_zux_") quit:n=""""  D",ref)
	.	;;do append(" . S ov=$P("_zux_",""|""),nod=$P("_zux_",""|"",3),pos=$E($P("_zux_",""|"",4)+1000,2,4),sfd=$p("_zux_",""|"",10),fmtable=$P("_zux_",""|"",11)",ref)
	.	;;if rtyp=1 do
	.	;;.	do append(" . S vobj(object,-100,""0*"",n)=""T""_pos_ov",ref)
	.	;;else  do
	.	;;.	if rtyp=11 do append(" . S:nod=""?"" nod=""0*""",ref)
	.	;;.	do append(" . S vobj(object,-100,nod,n)=""T""_pos_ov",ref)
	.	;;do append(" . I sfd'="""" S $P(vobj(object,-100,nod,n),""|"",3)="_zsfd,ref)
	.	;;do append(" . I fmtable'="""" S $P(vobj(object,-100,nod,n),""|"",11)=fmtable",ref)
	.	;;do append(" . I $P("_zux_",""|"",6) S $P(vobj(object,-400,n)=0",ref)
	.	new zux,zuxqt
	.	set zux="UX("_""""_table_""""_",vC)",zuxqt=$$QADD^%ZS("$P("_zux_",$C(124))")
	.	do append(" N vC,vCd,vTd S vC="""" F  S vC=$O("_zux_") quit:vC=""""  D",ref)
	.	do append(" . S vCd=$$getPslCln^UCXDD("""_table_""",vC,.vTd)",ref)
	.	do append(" . X $$getUpdAudit^UCXDD(vCd,""object"","_zuxqt_",0)",ref)
	.	do append(" . I $P("_zux_",""|"",6) S vobj(object,-400,vC)=0",ref)
	;
	if '(opt=2) do append(tab_"Q",ref)
	set return=ref_"("_objectName_")"
	quit
	;
	;-----------------------------------------------------------------------
getPurVar(recInst,pur,bPatch) ;local String; return purpose node reference
	;-----------------------------------------------------------------------
	; Returns vobj(recInst,pur), patched as requested.
	;
	; If recInst is an array reference, don't patch, even if requested.
	;
	if (recInst["(")!'bPatch quit $$lvpm^UCXDD(recInst,pur)
	quit $$purByOvs^UCREC4OP(subRou,recInst,pur)
	;
	;-----------------------------------------------------------------------
getTable ; private; method Record.getTable(); returns String
	;-----------------------------------------------------------------------
	; Including this method in PSL code turns off object optimization, unless
	; it can be inferred that the supplied instance cannot have descendants.
	;
	new isAnces set isAnces=0
	new table set table=$$tableNameOf^PSLClass(class)
	if table="" set isAnces=1
	else  if $D(^DBINDX("SYSDEV","PARFID",table)) set isAnces=1
	if isAnces do
	.	set return="$$tableNameOf^PSLClass($P($G("_oLvn_"(+$G("_objectName_"),-1)),$C(9)))"
	.	do setOpti^UCGM(objectName,objectLevel,1)
	else  set return=$$QADD^%ZS(class)
	quit
	;
	;-----------------------------------------------------------------------
save	; private; method Record.save(); returns void
	;-----------------------------------------------------------------------
	; NOTES:
	; . Object optimization is turned off in the following cases:
	;	- The save method requires a subroutine call
	;	- The table has insert, update, delete, or selectRestrict
	;	  table access rights in use
	;
	; Update and standardize filer run-time qualifiers
	new comment,dbiocount,isSimple,line,par
	set par=$$fileQual^UCDB("Record.save",actual(1))
	set dbiocount=$$getSetting^PSLCC(.pslPrsr,"DEBUG","DBIOCOUNT","")
	;
	; If abstract, all runtime processing (including TP) is handled by
	; save^DBSDYNRA()
	if table="" set return="save^DBSDYNRA("_objectName_","_par_")" set:dbiocount'="" return=return_","_dbiocount_"($E("_olvn_"("_objectName_",-1),7,"_$$getPslValue^UCOPTS("maxStringLength")_"),""WRITE"")" quit
	;
	; The code that will be associated with the save operation fits on a
	; single line. If the method call (Record.save() or Record.bypassSave())
	; occurs in a "simple" context, then the code can be inserted in-line.
	; The simple context is defined as: the current mcode line ends in "D ".
	; If not, then append a simple subroutine that we can call. The appended
	; subroutine will be expressed in PSL:
	;	vReSavNN( RecordXXX vOid, String vPar) //
	;		do vOid.save( vPar)
	;		quit
	;
	set isSimple=($GET(mcode)?.E1"D ")
	;
	; If not simple allocate the subroutine, and generate it if needed.
	; Turn off optimization, because the instance will be passed to a
	; subroutine.
	; NOTE: This code would largely benefit from conversion to PSL.
	if 'isSimple do  quit
	.	do setOpti^UCGM(objectName,objectLevel,-1)
	.	set comment="Record"_table_".save()"
	.	set sr=$$findSubr^UCGM("vReSav",comment)
	.	set return=sr_"("_objectName_","_par_")"
	.	quit:$$hasSubr^UCGM(sr)
	.	;
	.	set line="private void "_sr_"( Record"_table_" vOid, String vPar) // "_comment
	.	;;do addSubr^UCGM(sr,"(vOid,vPar)",comment)
	.	set append(sr)=0_$char(9)_comment
	.	;
	.	do addM2src^UCGM(" //")
	.	do addM2src^UCGM(" #OPTION ResultClass 1")
	.	do addM2src^UCGM(" #WARN 0")
	.	do addM2src^UCGM(line)
	.	do addM2src^UCGM(" do vOid.save(vPar)")
	.	do addM2src^UCGM(" quit")
	;
	new accessRts,auditLog,decPos,del,doCode,doMTP,flrLgc,fType,gbl,isFiler,isKill,isRdb
	new keys,label,list,objSig,purPos,ref,sr,td
	;
	set td=$$caPslTbl^UCXDD(.pslTbl,table,1)
	;
	set fType=$P(td,"|",4)		; PSLTable.recordType
	set isRdb=($P(td,"|",8)'="GTM")	; PSLTable.isRdb
	;
	set isFiler=1			; Assume need to call RecordTABLE code
	;
	; Kill vobj(,-100) needed if recordType other than 1, or if auditing or
	; if scope not NEW
	set isKill=(fType'=1)!''$$getAtt^UCGM(objectName,objectLevel,12)!($$getScope^UCGM(objectName,objectLevel)'="NEW")
	;
	; If all qualifiers of bypassSave, and no index column modifications,
	; it is safe to discard the filer program, even if it is present
	set flrLgc=$$getFlrLgc^UCXDD(td,"SAVE",par,1)
	; Filer required for access rights checking  or for audit logging
	; for INSERT, UPDATE, DELETE,
	set accessRts=$$checkAccessRights^UCXDD(td,0)
	set auditLog=$$getLogging^UCXDD(td,0)
	if '((accessRts["insert")!(accessRts["update")!(accessRts["delete")!(auditLog["insert")!(auditLog["update")!(auditLog["delete")) do
	.	; Do not skip filer for table with memo/blob (UTF-8 requires $Z*)
        .	if '(($P(td,"|",5)["B")!($P(td,"|",5)["M")),flrLgc="LOG"!(flrLgc="") set isFiler=0
	;
	; If no need to call filer, then $$saveNoFl() will return the code to insert,
	; else insert call to filer (add uparrow and filer qualifiers).
	; If there is a filer, force isKill=1, to ensure KILL vobj(,-100) code
	; will be included, and turn off optimization.
	if 'isFiler set doCode=$$saveNoFl(td,flrLgc)
	else  do
	.	set doCode=" D vSave^Record"_table_"("_objectName_","_par_")",isKill=1
	.	do setOpti^UCGM(objectName,objectLevel,-1)
	;
	do autoERRM^UCGM()
	;
	; Notify dbAcc of "assignment"
	set objSig=$$leftSig^UCGM(objectName)
	set decPos=$$findDec^UCREC4OP(subRou,objSig)
	do setAssign^UCREC4OP(subRou,objSig,1+isFiler)
	;
	; FSCW, CR35741: Because some of the RDB errors and the zero-rows-
	; updated condition may trigger an M TRESTART, an M Transaction
	; must be "active" regardless whether the table resides in an MDB or an
	; RDB.
	; Because the PSL runtime exception handling will do a call to
	; rollback^vRuntime(), all TSTARTs are potential rollback points, and
	; require an RDB save point. If we generate unconditional TSTART/TCOMMIT
	; then we also need to generate a call to Oracle to set the save point
	; for every Record.save(). Because the majority of the calls are likely
	; to operate under an outer TSTART, the TSTART before the Record.save()
	; will happen infrequently, and calling start^vRuntime() in these cases
	; has a slight performance penalty but guarantees that even the single
	; operation can handle TRESTARTs.
	;
	new code
	set pslNew(subRou)=$$addList^UCGM(pslNew(subRou),"vTp"),code=" S vTp=($TL=0) TS:vTp (vobj):transactionid=""CS"""
	if isRdb set code=code_" D:vTp "_$$callStart^UCRUNTIM()
	;
	; append filer code and trace code if requested
	set code=code_doCode
	if dbiocount'="" set code=code_" D "_dbiocount_"("""_table_""",""WRITE"")"
	;
	if isKill set code=code_" K "_oLvn_"("_objectName_",-100)"
	;
	; If instance is subscripted, or using a filer, vobj() will be
	; used and there is no need to wrap the recordmode assignment.
	; If no filer is used, the assignment to the recordmode variable
	; may be optimized out of the code in pass 2, and needs to be
	; found easily. Use a dummy declaration position, because this is not a
	; "real" access value.
	if (objectName["(")!isFiler set code=code_" S "_$$getModeVar(objectName,0)_"=1"
	else  set code=code_$$clnAsn1^UCREC4OP(-1," S "_$$getModeVar(objectName,1),"1")
	;
	; For RDB: in addition to setting the record mode, also set the
	; WHERE clause for the next update.
	if isRdb do
	.	new topNode
	.	set topNode=$S(objectName["(":objectName,1:decPos)
	.	set code=code_$$rtUpdKey^UCXDD(table,topNode)
	.	;;set topNode=$$getPurVar(objectName,"0*",1)
	.	;;set code=code_" S:$P("_topNode_",$C("_dlm_"),2)]"""" $P("_topNode_",$C("_dlm_"))=$G(vRunPTN)"
	;
	; FSCW, CR?????:
	; Use DO:vTp commit^vRuntime() for the RDB variant (which will do the
	; ISO-M TCOMMIT) and just TCOMMIT:vTp for the MDB variant.
	if isRdb set code=code_" D:vTp "_$$callCommitCS^UCRUNTIM()
	else  set code=code_" TC:vTp "
	;
	; At this point code contains the single line of code that
	; represents the save operation.
	; Return must be non-empty, because an empty value has special
	; meaning in methods^UCGM.
	set mcode=$e(mcode,1,$l(mcode)-3)_code,return=" "
	quit
	;
	;-----------------------------------------------------------------------
saveNoFl(tbldes,flrLgc) ;local String;Code for save()/bypassSave() without Filer
	;-----------------------------------------------------------------------
	; NOTES:
	; . This subroutine does not check to see if a filer is required.
	; . The code generated by this subroutine uses objectName both as formal
	;	parameter and in all generated code. This allows standard
	;	handling of Record-occurrence-wraps etc. to support optimization
	;	if there happens to be only a single call to the subroutine.
	;	At the same time, "unoptimized" vobj(,) access will still work,
	;	even if the subroutine is called from multiple places, provided
	;	that all callers are aware of the un-optimized access.
	; . The only exception to the above rule is when objectName contains a
	;	subscripted variable. In that case "vOid" will be used.
	;	Note that these calls can never be optimized anyway.
	; . The comment used to locate a matching subroutine shall be different
	;	from the label used by the caller to wrap the call to this
	;	subroutine.
	; . This function will return a wrapped "save occurrence" for all RDB
	;	saves. It is up to the optimizer / pass 2 generator (UCREC4OP)
	;	to replace the wrap by the correct DB API calls, and to turn off
	;	optimization of the instance. On the other hand, for MDB save
	;	this function will always return the resulting MDB code, and it
	;	will set the optimization accordingly.
	;	Consequently, decSav^UCREC4OP shall NOT modify decPos.assign for
	;	MDB tables, as that would impact the optimziation of the
	;	instance.
	;
	new akeys,cmt,decPos,del,fSubr,gbl,gkeys,fkeys,fpName,ftype,i,index
	new label,line,newPtr,rdb,ref,return,tblBM,tok,var,z
	;
	; FSCW: newPtr not used within this subroutine
	;;set newPtr=$$getNew^UCGM(objectName)
	;
	set tbldes=$$tAssert^UCXDD(tbldes,1)
	set fkeys=$P(tbldes,"|",3)
	set ftype=$P(tbldes,"|",4)
	set del=$P(tbldes,"|",10)
	set rdb=($P(tbldes,"|",8)'="GTM")
	set tblBM=($P(tbldes,"|",5)["B")!($P(tbldes,"|",5)["M")
	;
	; Variable fSubr is used to indicate if the code to save this Record can
	; be generated without a subroutine call. The following values of fSubr
	; are distinguished:
	; - fSubr = 0
	;	This indicates that an unconditional in-line M SET command can
	;	be used. This is the case if:
	;	- It is an MDB table
	;	- PSLTable.recordType = 1
	;	- no additional filer logic (currently only LOG)
	;	- The call does not include Blob/Memo columns
	;		This used to be detected using vdd(), which is a very
	;		dangerous way, because it assumes that the contents of
	;		vdd() at the time that Record.save() is encountered
	;		contains all column references. It is now detected using
	;		the PSLTable properties.
	; - fSubr = -1
	;	This indicates that a subroutine will be used for an RDB table
	;	with NEW scope, that could possibly bypass the call to
	;	rdbSave*^UCDBRT(,) by generating a known SQL INSERT and/or UPDATE
	;	statement.
	;	Note that this is independent of PSLTable.recordType, blob/memo,
	;	and the additional filer logic, but better not be applied to
	;	subscripted instances.
	; - fSubr = 1
	;	All other cases. The object passed to the subroutine cannot be
	;	optimized.
	;
	if 'rdb,ftype=1,flrLgc="",'tblBM,objectName'["(" set fSubr=0
	else  if rdb,$$getScope^UCGM(objectName)="NEW",objectName'["(" set fSubr=-1
	else  set fSubr=1
	;
	; If fSubr<1, the Record instance is optimizable.
	if fSubr<1,$$getOpti^UCGM(objectName,objectLevel)>msrc do setOpti^UCGM(objectName,objectLevel,0)
	if fSubr>0 do setOpti^UCGM(objectName,objectLevel,-1)
	;
	set akeys=""
	set decPos=$$findDec^UCREC4OP(subRou,objectName)
	if fkeys'="" for i=1:1:$L(fkeys,",") do
	.	;
	.	new cd,key,keySub
	.	;
	.	set key=table_"."_$P(fkeys,",",i)
	.	;
	.	; report key as referenced for db access / optimize,
	.	; but discard return value of $$accByOvs^UCREC4OP()
	.	set cd=$$caPslCln^UCXDD(.pslCln,key)
	.	set keySub=$$accByOvs^UCREC4OP(subRou,objectName,key,0,0)
	.	set keySub=$$getCurExpr^UCXDD(cd,decPos,0)
	.	if i>1 set akeys=akeys_","
	.	set akeys=akeys_keySub
	;
	if fSubr=0 do  quit return		; known to apply to MDB only
	.	;
	.	; In-line
	.	new ref
	.	;
	.	if objectName["(" set return=$$getGvn^UCXDD(tbldes,objectName),ref=oLvn_"("_objectName_")"
	.	else  set return=$$getGvn^UCXDD(tbldes,decPos),ref=$$lvpm^UCREC4OP(decPos,"0*",1)
	.	;
	.	if del=124 set return=" S "_return_"="_$$%RTBAR^%ZFUNC(ref)
	.	else  set return=" S "_return_"="_ref
	;
	; If RDB:
	; - Include call to ^DBSLOGIT() if needed (same for pass 1 and pass 2,
	;	provided the "mode variable" is wrapped)
	;	Indicate that vobj() is indeed needed.
	; - create SAVE occurrence and append it to the save code.
	;	The actual call will be determined in pass 2.
	if rdb do  quit line
	.	if ("/"_flrLgc_"/")["/LOG/" set line=" D ^DBSLOGIT("_objectName_","_$$getModeVar(objectName,1)_") " do setNeedVobj^UCREC4OP(subRou,objectName,1)
	.	else  set line=""
	.	set line=line_$$savByOvs^UCREC4OP(subRou,objectName,objectName)
	.	if fSubr>0 do setAssign^UCREC4OP(subRou,$$leftSig^UCGM(objectName),2)
	;
	; Code below will end up in subroutine, and deals with MDB code only:
	; - PSLTable.recordType in (10,11) or
	; - PSLTable.recordType=1 and PSLTable.hasBlob!PSLTable.hasMemo
	; Note that this part could also be handled by UCREC4OP, with the
	; possibility to generate direct SETs of the nodes that are accessed
	; (in combination with declaration.assign=1).
	;
	; If objectName unsubscripted use it as formal parameter name as well,
	; otherwise use "vOid"
	if objectName["(" set fpName="vOid"
	else  set fpName=objectName
	;
	set cmt="Record"_$P(tbldes,"|",1)_" saveNoFiler("_flrLgc_")"
	;
	; For (remaining) RDB, use a separate subroutine per save occurrence
	set label=$$findSubr^UCGM("vReSav",cmt)
	set return=" D "_label_"("_objectName_")"
	quit:$DATA(append(label)) return
	;
	; Use 'fpName' as the object var.
	do addSubr^UCGM(label,"("_fpName_")",cmt)
	;
	; Include code for LOGging if needed.
	; Since the generated code does not pass vx() into or outof DBSLOGIT,
	; this call shall never be included when a filer is going to be invoked,
	; because DBSLOGIT will call AUDIT^UCUTILN if vx() is not defined, thus
	; deleting information that would usually be needed by the filer.
	if ("/"_flrLgc_"/")["/LOG/" do append(" D ^DBSLOGIT("_fpName_","_oLvn_"("_fpName_",-2))",label)
	set gbl=$$getGvn^UCXDD(tbldes,fpName)
	if del=124,ftype#2 do append(" S "_gbl_"="_$$%RTBAR^%ZFUNC("$G("_oLvn_"("_fpName_"))"),label) i 1
	else  if ftype#2 do append(" S "_gbl_"=$G("_oLvn_"("_fpName_"))",label)
	if ftype>1 do
	.	new var
	.	set var="vN"
	.	;
	.	; if table has negative nodes, transform vobj-node to data-node
	.	if $$hasNegNode(tbldes) set var="$S($E("_var_")=""v"":-$E("_var_",2,99),1:"_var_")"
	.	;
	.	if gbl["(" set gbl=$E(gbl,1,$L(gbl)-1)_","_var_")"
	.	else  set gbl=gbl_"("_var_")"
	.	;
	.	do append(" N vD,vN S vN=-1",label)
	.	set var=oLvn_"("_fpName_",vN)"
	.	if tblBM set var="$G("_var_")"
	.	if del=124 set var=$$%RTBAR^%ZFUNC(var)
	.	;
	.	; Add code for INSERT
	.	do append(" I '$G("_oLvn_"("_fpName_",-2)) F  S vN=$O("_oLvn_"("_fpName_",vN)) Q:vN=""""  S vD="_var_" S:vD'="""" "_gbl_"=vD",label)
	.	;
	.	; Add code for UPDATE
	.	set line=" E  F  S vN=$O("_oLvn_"("_fpName_",-100,vN)) Q:vN=""""  "
	.	if ftype=11!tblBM set line=line_"I $D("_oLvn_"("_fpName_",vN))#2 "
	.	if del'=124 do
	.	.	do append(line_"S "_gbl_"="_oLvn_"("_fpName_",vN)",label)
	.	else  do
	.	.	do append(line_"S vD="_var_" S:vD'="""" "_gbl_"=vD I vD="""" "_$$%ZKILL^%ZFUNC(gbl),label)
	;
	; The code below will not be valid for UTF-8 blobs because the data will
	; most likely contain BADCHARs, and $ZL(), $ZE() etc. are needed to deal
	; with them. For UTF-8 memos using $Z* is needed as well since the
	; PSL.maxDataLength value is supposed to be an octet length.
	; Note that save() ensures that saveNoFl() will not be called if tblBM.
	if tblBM do	; to be executed for both INSERT and UPDATE
	.	do append(" N vC,vS s vS=0",label)
	.	new mxD,mxDTail
	.	set mxD=$$getPslValue^UCOPTS("maxDataLength"),mxDTail=",1),vC,vC+"_(mxD-1)_")"
	.	if ftype=1 do
	.	.	do append(" F vC=1:"_mxD_":$L($G("_oLvn_"("_fpName_",1,1))) S vS=vS+1,"_$E(gbl,1,$L(gbl)-1)_",vS)=$E("_oLvn_"("_fpName_",1"_mxDTail,label)
	.	else  do
	.	.	;
	.	.	set line=" F  S vN=$O("_oLvn_"("_fpName_",-100,vN)) Q:vN=""""  I $D("_oLvn_"("_fpName_",vN))>9"
	.	.	do append(line_" F vC=1:450:$L($G("_oLvn_"("_fpName_",vN,1))) S vS=vS+1,"_$E(gbl,1,$L(gbl)-1)_",vS)=$E("_oLvn_"("_fpName_",vN"_mxDTail,label)
	;
	do append(" Q",label)
	quit return
	;
	;-----------------------------------------------------------------------
hasNegNode(td) ; local Boolean; has table negative subscript nodes?
	;-----------------------------------------------------------------------
	; ARGUMENTS:
	; . PSLTable td = table descriptor
	;	Shall have assertion level 1 (not validated here!)
	;
	; NOTES:
	; . At some point in time we may want to move this function to UCXDD.
	;
	quit ","_$P(td,"|",15)[",""v"
	;
	;-----------------------------------------------------------------------
copy(p1) ; private; method: Record.copy ;  Copy one record object into another
	;-----------------------------------------------------------------------
	;
	; INPUTS:
	; - objectName and objectLevel = source instance
	; - var and varLevel = target instance
	; - table = name of source table
	;
	if $G(p1)="toString" do toString quit
	;
	new fType,td,varClass,vptr
	;
	set vptr=$S(var["(":$$leftSig^UCGM(var),1:var)
	set varClass=$$getClass^UCGM(var,varLevel)
	;
	set td=$$caPslTbl^UCXDD(.pslTbl,table,1)	; need extended PSLTable
	set td=$$tAssert^UCXDD(td,1,.pslCln)		; so force it
	set fType=$P(td,"|",4)
	;
	if varClass'=class do  quit
	.	;
	.	if $$isRecord^PSLClass(varClass)=0 do ERROR^UCGM("Identifier class must be a Record<class>: "_varClass)
	.	if fType>1 do ERROR^UCGM("Multi-node records must be the same class")
	.	do copyDiff
	;
	; Record.copy to same class ================
	new gbl,i,isParent,isRdb,label,lstN,lstS,tblBM,v
	;
	set isParent=$D(^DBINDX(%LIBS,"PARFID",table))
	set isRdb=($P(td,"|",8)'="GTM")
	set tblBM=($P(td,"|",5)["B")!($P(td,"|",5)["M")
	;
	; Each Record.copy() occurrence will end up in a separate subroutine
	; This is used by the optimization code.
	set label=$$newLabel^UCGM("ReCp",.labels)
	do addSubr^UCGM(label,"(v1)",class_"."_method_": "_table)
	;
	; Type 1 tables (except parents) without Blob/Memo can be handled by
	; Object.copy() / Object.toString() without additional processing
	if fType=1,'isParent,'tblBM do   quit
	.	;
	.	do @(p1_"^UCREF")
	.	do append(tab_"Q "_return,label)
	.	set return="$$"_label_"("_objectName_")"
	;
	; Records with incremental loading:
	; Include code to ensure that all nodes are loaded for an exisiting
	; record before the call to the runtime copy method.
	; There are several cases (both for RDB and MDB):
	; - parent table (nodes not known until runtime)
	; - tables with Blob/Memo
	; - recordType IN (10, 11)
	; - negative node numbers on MDB
	; The code below assumes that parent tables do not have Blob or Memo
	; columns, and do not have negative subscript nodes.
	set lstN=$P(td,"|",15)		; list of all "normal" nodes
	set lstS=""			; list of all "special" nodes
	;
	; If there are nodes that requires special treatment, split the lists
	if tblBM!$$hasNegNode(td) do
	.	new lst,nod
	.	set lst=lstN,lstN=""
	.	for i=1:1:$L(lst,",") do
	..		set nod=$P(lst,",",i)
	..		;
	..		; embedded comma
	..	 	if $L(nod,"""")#2=0 for i=i+1:1:$L(lst,",") set nod=nod_","_$P(lst,",",i) quit:$L(nod,"""")#2
	..		if nod?1"*".ANP set lstS=lstS_","_nod quit
	..		if nod?1"""v".N.1"."1.N1"""" set lstS=lstS_","_nod quit
	..		set lstN=lstN_","_nod
	.	if lstN'="" set lstN=$e(lstN,2,$l(lstN))
	else  if isRdb,$P(td,"|",9)["," do
	.	;
	.	; RDB wide table, treat all nodes as special (force leading ",")
	.	set lstS=","_lstN,lstN=""
	;
	; Turn off object optimization for source (pass 2 only supports target
	; optimization).
	do setOpti^UCGM(objectName,objectLevel,-1)
	do append(tab_"N vNod,vOid",label)
	do append(tab_"I $G("_oLvn_"(v1,-2)) D",label)
	;
	set gbl=$$getGbl^UCXDD(td,"v1")
	if isParent do
	.	;
	.	; For parent tables the nodes are not known until runtime
	.	if isRdb do
	..		new chld,ctd,elswte,lvpm,wtl,wtn
	..		set chld="",els="",lvpm(-161)=oLvn_"(v1,-161,",lvpm(-162)=oLvn_"(v1,-162,"
	..		for  set chld=$O(^DBINDX(%LIBS,"PARFID",table,chld)) quit:chld=""  do
	...			do append(" ."_els_" I $P("_oLvn_"(v1,-1),$C(9))=""Record"_chld_""" D",label)
	...			set ctd=$$caPslTbl^UCXDD(.pslTbl,chld,0),els=" E "
	...			set wtl=$$mpPslTbl^UCXDD(ctd,"internalNames")
	...			for wte=1:1:$l(wtl,",") do
	....				set wtn=$P(wtl,",",wte) quit:wtn=table
	....				do append(" . ."_$$getLodCode^UCXDD(ctd,"v1",$P(wtn,"_",$L(wtn,"_")),1,1,.lvpm),label)
	.	else  do
	..		;
	..		; MDB parent:
	..		; Assume is is safe to load all nodes for ACN/DEP/LN
	..		; This mimics the "old behavior"
	..		do append(tab_"."_tab_"S vNod=""""",label)
	..		do append(tab_"."_tab_"F  S vNod=$O("_gbl_"vNod)) Q:vNod=""""  S:'$D("_oLvn_"(v1,vNod)) "_oLvn_"(v1,vNod)=$G(^(vNod))",label)
	else  do
	.	;
	.	; Known nodes at compile time.
	.	; Insert incremental load code for each "special" node
	.	; Note that lstS always starts with a comma (except if empty)
	.	if lstS'="" do
	..		new lvpm
	..		do loadXnodes(td,"v1",.lvpm)
	..		for i=2:1:$L(lstS,",") do append(tab_"."_$$getLodCode^UCXDD(td,"v1",$p(lstS,",",i),1,1,.lvpm),label)
	.	if lstN'="" for  do  quit:lstN=""
	..		;
	..		; In case lstN contains embedded comma at the wrong place
	..		set v=$P(lstN,",",1,127),lstN=$P(lstN,",",128,32767)
	..		if $L(v,"""")#2=0 for  set v=v_","_$P(lstN,","),lstN=$P(lstN,",",2,32767) quit:$L(v,"""")#2
	..		do append(tab_"."_tab_"F vNod="_v_" S:'$D("_oLvn_"(v1,vNod)) "_oLvn_"(v1,vNod)=$G("_gbl_"vNod))",label)
	;
	; In all cases the Record.copy() ends as an ordinary Object.copy()
	set return=tab_"S vOid=$$"_p1_"^UCGMR(v1)"
	do append(return,label)
	do append(tab_"Q vOid",label)
	set return="$$"_label_"("_objectName_")"
	quit
	;
	;-----------------------------------------------------------------------
copyDiff ; local; Copy a record from one class to another
	;-----------------------------------------------------------------------
	; This subroutine generates code to copy a record between classes,
	; overlaying columns based on name matches and optimizes. It also allows
	; :hostVariable and 'SQL Literal' in the column mapping expression.
	;
	; INPUTS:
	; . table = name of table
	; . class = class of current record (source record)
	; . var = target variable
	; . varClass = class of destination record
	; . varLevel = static declaration level of var
	; . actual(1) = comma separated list of toColumn=fromExpr
	;	with:
	;	- toColumn = column name in destination table
	;	- fromExpr = fromColumn or SQL literal or :hostvar
	;
	; OUTPUTS:
	; . code generated for the instantiation of a new destination record
	;	with column values obtained from the source record as specified
	;	by the mapping.
	;	The Record mode of the destination record will be zero, as if
	;	a Class.new("Record") has been executed, followed by a number of
	;	column assignments.
	;
	; NOTES:
	; . The code generated by this subroutine needs to be synchronized with
	;	the code in ^UCREC4OP.
	; . The code generated in append() does not use purpose node wrappers to
	;	represent the top node, the key variables and the special
	;	purpose nodes. So append() contains hard-coded vobj() references
	;	and the generated subroutine expects an objectID as parameter.
	;	If this subroutine would be rewritten to insert purpose wraps
	;	instead of hardcoded vobj() values, standard code in UCREC4OP
	;	would take care of the replacement.
	;
	; Turn off object optimization for source (pass 2 only supports target
	; optimization).
	do setOpti^UCGM(objectName,objectLevel,-1)
	;
	new d1,di1,keys1,obj1,pos1,table1,z1		; source table related
	new cd2,d1,di2,keys2,map2,obj2,pos2,table2,td2,var2,z2	; destination
	;
	new bulk,cnt,end,i,isRdb,key,label,n,nod,rdbasn,tok,winner,wincnt,x,xmap,z
	;
	set xmap=actual(1)
	;
	if xmap'="" do
	.	;
	.	set xmap=$$QSUB^%ZS(xmap)
	.	set xmap=$$TOKEN^%ZS(xmap,.tok,"'")
	.	set xmap=$$TOKEN^%ZS(xmap,.tok,"""")
	;
	set table1=$$tableNameOf^PSLClass(class)
	set table2=$$tableNameOf^PSLClass(varClass)
	set td2=$$caPslTbl^UCXDD(.pslTbl,table2,0)
	if $P(td2,"|",4)'=1 do ERROR^UCGM("Multi-node records must be the same class") quit
	if '$D(fsn(table1)) do fsn^SQLDD(.fsn,table1) if ER do ERROR^UCGM($G(RM)) quit
	if '$D(fsn(table2)) do fsn^SQLDD(.fsn,table2) if ER do ERROR^UCGM($G(RM)) quit
	;
	; Check if table2 is on a relational database.
	; If so, turn off optimization of target as well, because it is almost
	; impossible to just remove the -150 assignments
	set isRdb=$$rtIsRdb^UCXDD(table2)
	if isRdb do setOpti^UCGM(var,varLevel,-1)
	;
	; build xmap(toColumn)=fromExpr
	if xmap'="" for i=1:1:$L(xmap,",") do  quit:ER
	.	;
	.	set x=$P(xmap,",",i)
	.	set di2=$P(x,"=",1),di1=$P(x,"=",2)
	.	set di2=$$UNTOK^%ZS(di2,.tok),di1=$$UNTOK^%ZS(di1,.tok)
	.	if di2=""!(di1="") do ERROR^UCGM("Invalid Map Expression: "_x) quit
	.	;
	.	set di2=$$UPCASE^UCGM(di2)
	.	if '("':"[$E(di1)) set di1=$$UPCASE^UCGM(di1)
	.	;
	. 	set xmap(di2)=di1
	;
	set keys1=$P(fsn(table1),"|",3)
	set keys2=$P(fsn(table2),"|",3)
	;
	set di2=""
	;
	; For each column in table2 build:
	; - map(toPos)=fromExpr, translated to its M code:
	;	* :hostvar the result of $$varExpr^UCGM / $$valExpr^UCGM
	;	* 'SQL literal' will be tranfromed to "M literal"
	;	* column reference will be replaced by
	;		PSLColumn.getCurrentExpr("p1",0)
	; - cd2(toPos)=PSLColumn
	; - cd1(fromPos)=PSLColumn
	; toPos<0 will be used for key positions,
	; Special care is needed to handle subfields: multiple columns could
	; map to the same position in that case. This is solved by adding .001
	; to the position until a "free slot" is found.
	for  set di2=$O(^DBTBL("SYSDEV",1,table2,9,di2)) quit:di2=""  do
	.	;
	.	set cd=$$getPslCln^UCXDD(table2,di2,.pslTbl)
	.	set pos2=$$mpPslCln^UCXDD(cd,"position")
	.	if +pos2=0 quit		; no position: computed, RDB master, ...
	.	set nod=$$getCurNode^UCXDD(cd,0)
	.	if nod<0 set pos2=nod
	.	for pos2=pos2:.001 quit:'$DATA(cd2(pos2))
	.	set cd2(pos2)=cd
	.	;
	.	set di1=$GET(xmap(di2),di2)
	.	if $E(di1)=":" do  quit			; HostVar or Expression
	..		;
	..		set di1=$E(di1,2,$L(di1))
	..		if $$isVar^UCGM(di1) set di1=$$varExpr^UCGM(di1,0)
	..		else  set di1=$$valExpr^UCGM(di1,,0)
	..		set map2(pos2)=di1
	.	if $E(di1)="'" set map2(pos2)=$$QSWP^%ZS(di1,",","""") quit
	.	;
	.	; must be table1.column (provided it exists in table1)
	.	if '$$isColumn^UCXDD(table1,di1) quit
	.	;
	.	; All conditions are satisfied to include column
	.	set cd=$$getPslCln^UCXDD(table1,di1,.pslTbl)
	.	set map2(pos2)=$$getCurExpr^UCXDD(cd,"v1",0)
	.	set pos1=$$mpPslCln^UCXDD(cd,"position")
	.	set nod=$$getCurNode^UCXDD(cd,0)
	.	if nod<0 set pos1=nod
	.	;
	.	; Build an array of "position shift" counts.
	.	; The shift with the highest number of matches will be used
	.	; set the bulk number of fields
	.	; exclude keycolumns from both sides (posN<0)
	.	; exlude subfields from both sides (always requires assignment)
	.	; If the source is computed, a masterfield, or a subfield,
	.	; it can never participate in the bulk from-piece-x-to-piece-y
	.	; assignment. Similarly if the target is a subfield.
	.	quit:pos2<0
	.	quit:pos1'>0
	.	quit:$$mpPslCln^UCXDD(cd,"subfieldPosition")'=""
	.	quit:$$mpPslCln^UCXDD(cd2(pos2),"subfieldPosition")'=""
	.	set bulk(pos2)=pos2\1-pos1
	.	set cnt(bulk(pos2))=$GET(cnt(bulk(pos2)))+1
	;
	; and the winner is ... (with wincnt matches)
	set n="",winner=0,wincnt=0
	for  set n=$O(cnt(n)) quit:n=""  if cnt(n)>wincnt set wincnt=cnt(n),winner=n
	;
	; Each Record.copy() occurrence will end up in a separate subroutine
	; The difference between copy-to-same and copy-to-different is the text
	; ' to: ' in copy-to-different.
	; This is used by the optimization code.
	set label=$$newLabel^UCGM("ReCp",.labels)
	do addSubr^UCGM(label,"(v1)",class_"."_method_": "_table1_" to: "_table2)
	;
	set obj1=oLvn_"(v1)"
	set obj2=oLvn_"(vOid)"
	set var2="vRec"
	do append(tab_"N vOid,vRec",label)
	;
	do append(tab_";",label)
	set td2=$$caPslTbl^UCXDD(.pslTbl,table2,0)
	do append(tab_$$getNewCode^UCXDD(td2,"vOid",0,0),label)
	;
	; Record type and mode of destination record
	do append(tab_"S "_oLvn_"(vOid,-2)=0",label)
	;
	set d1=$P(fsn(table1),"|",10) if d1="" set d1=124
	set d2=$P(fsn(table2),"|",10) if d2="" set d2=124
	;
	set d1="$C("_d1_")"
	set d2="$C("_d2_")"
	;
	set keys=$P(fsn(table2),"|",3)
	set end=$O(map2(""),-1)\1
	;
	; Construct the first "bulk" assignment
	if wincnt do
	.	set z=obj1
	.	if d1'=d2 set z="$TR("_z_","_d1_","_d2_")"
	;
	else  set z=""""""
	;
	; If winner=0, then the bulk remains in the same position
	; If winner>0, then the bulk needs to be shifted to the right:
	;	set $PIECE(vobj(object),d2,1+winner)=$P(vobj(p1),d1,1,(end-winner))
	; If winner<0, then the bulk needs to be shifted to the left:
	;	set vobj(object)=$P(vobj(p1),d1,1-winner,(end-winner))
	; Note that if the delimiters are different, this has already been
	; expressed in z ($TR(vobj(p1),d1,d2)), so all pieces are d2 delimited
	if winner do
	.	;
	.	if winner>0 set z="$P("_var2_","_d2_","_(1+winner)_")=$P("_z_","_d2_",1,"_(end-winner)_")"
	.	else  set z=var2_"=$P("_z_","_d2_","_(1-winner)_","_(end-winner)_")"
	else  set z=var2_"="_z
	;
	do append(tab_"S "_z,label)
	;
	; The following for-loop uses the integer values of pos2.
	; For RDB this will be the only case. For MDB the integer value may
	; be accompanied by non-integer values if (and only if) subfields
	; are involved.
	for pos2=1:1:end do
	.	;
	.	; If this is a masterfield with subfields ...
	.	if $d(cd2(pos2+.001)) do copySubf(pos2,.cd2,.map2,"vOid",d2,var2,label) quit
	.	;
	.	; if not in map2(), then it is not included in the copy, but its
	.	; position may be garbaged by the bulk copy. Note that we can
	.	; safely use $$getCurExpr^UCXDD() for the leftexpr, because even
	.	; if this happens to be the first of a subfield/masterfield
	.	; cluster, the leftexpr references the entire field
	.	if '$DATA(map2(pos2)) do  quit
	..		if pos2'>winner quit	;already empty due to bulk assign
	..		if '$DATA(cd2(pos2)) set z2="$P("_var2_","_d2_","_pos2_")"
	..		else  set z2=$$VarSub^UCPATCH($$getCurExpr^UCXDD(cd2(pos2),"vOid",1),obj2,var2)
	..		do append(tab_"S "_z2_"=""""",label)
	.	;
	.	; if MDB and ordinary columns, who's distance matches the winner,
	.	; nothing more to include
	.	if $DATA(bulk(pos2)),bulk(pos2)=winner do  quit
	..		quit:'isRdb
	..		; For RDB, get post update code and do it
	..		new ovhCode
	..		set ovhCode=$$getUpdOvh^UCXDD(cd2(pos2),td2,"vOid",0,0)
	..		set ovhCode=$P(ovhCode,$C(9),2)
	..		if ovhCode'="" do append(tab_" "_$$VarSub^UCPATCH(ovhCode,obj2,var2),label)
	.	;
	.	; need complete assignment, but use short form for RDB (no need to check for overlay)
	.	do append($$VarSub^UCPATCH($$getUpdCode^UCXDD(cd2(pos2),"vOid",map2(pos2),0,2),obj2,var2),label)
	;
	; Add code to assign vRes to vobj(vOid)
	do append(tab_"S "_obj2_"="_var2,label)
	;
	for i=1:1:$L(keys,",") do		; Do access keys
	.	;
	.	set pos2=-2-i
	.	set z1=$GET(map2(pos2))
	.	if z1="" set z1=""""""
	.	do append($$getUpdCode^UCXDD(cd2(pos2),"vOid",z1,0,2),label)
	;
	do append(tab_"Q vOid",label)
	;
	set class=varClass
	set return="$$"_label_"("_objectName_")"
	quit
	;
	;-----------------------------------------------------------------------
copySubf(pos,cd,map,inst,del,lvn,sr) ; copy code for subfield / masterfield
	;-----------------------------------------------------------------------
	; ARGUMENTS:
	; . pos = PSLColumn.position of masterfield
	; . cd() = column descriptor array
	;	materfields and subfields are in cd(pos), cd(pos+.001), etc
	; . map() = map expression
	;	if map(pos+off) exists, then it contains the rightexpr to assign
	;	if map(pos+off) does not exist, the subfield is not mapped
	;	(and can be ignored)
	; . inst = target instance variable name
	; . del = delimiter to use when masterfield is assigned at once
	; . lvn = lvn used for "local copy" of toRecord.
	; . sr = subroutine name where code shall be appended
	;
	new lst,mf,off,vo
	set lst=$ORDER(cd(pos+1),-1)
	set vo=oLvn_"("_inst_")"
	;
	; find the masterfield
	for off=pos:.001:lst if $$mpPslCln^UCXDD(cd(off),"masterfieldType")>0 set mf=off quit
	;
	; If it is mapped, use this mapping and ignore all subfield mappings
	if $DATA(map(mf)) do append(tab_"S $P("_lvn_","_del_","_pos_")="_$$VarSub^UCPATCH(map(mf),vo,lvn),sr) quit
	;
	; insert assignments of individual subfields
	for off=pos:.001:lst if $DATA(map(off)) do append($$VarSub^UCPATCH($$getUpdCode^UCXDD(cd(off),inst,map(off),0,2),vo,lvn),sr)
	quit
	;
	;-----------------------------------------------------------------------
toString ; private; method: Record.toString ;  Copy a record object to a string
	;-----------------------------------------------------------------------
	;
	do warnGroup^UCGM("DATABASE","Method is not Database Independant: toString")
	;
	if '$D(fsn(table)) do fsn^SQLDD(.fsn,table)
	if $P(fsn(table),"|",4) do toString^UCREF quit
	;
	new akeys,fkeys,gbl,label,td
	;
	set td=$$caPslTbl^UCXDD(.pslTbl,table,1)	; need extended PSLTable
	set td=$$tAssert^UCXDD(td,1,.pslCln)		; so force it
	;
	S fkeys=$P(fsn(table),"|",3)
	S label=$$newLabel^UCGM("Db",.labels)
	;
	D addSubr^UCGM(label,"(p1)",class_"."_method_": "_table)
	D append(tab_"N nod,object",label)
	D append(tab_"I $G("_oLvn_"(p1,-2)) D",label)
	D append(tab_"."_tab_"S nod=""""",label)
	S akeys=oLvn_"(p1,-3)"
	for i=2:1:$L(fkeys,",") S akeys=akeys_","_oLvn_"(p1,-"_(i+2)_")"
	S gbl=$$getGbl^UCDB($P(fsn(table),"|",2),akeys)
	if $$getArchiveTable^DBARCHIVE(td)'="" set gbl="^|"_oLvn_"(p1,-99)|"_$E(gbl,2,$L(gbl))
	D append(tab_"."_tab_"F  S nod=$O("_$E(gbl,1,$L(gbl)-1)_",nod)) Q:nod=""""  S:'$D("_oLvn_"(p1,nod)) "_oLvn_"(p1,nod)=$G(^(nod))",label)
	;
	; Modified section to consider parameter 'mode' for all record types
	; greater than 1.
	S return=tab_"S object=$$toString^UCGMR(p1)"
	D append(return,label)
	D append(tab_"Q object",label)
	S return="$$"_label_"("_objectName_")"
	quit
	;
	;-----------------------------------------------------------------------
copyUX(table,fsn) ; local; Build code to copy to UX array
	;-----------------------------------------------------------------------
	;
	new do,del,fType,label
	;
	set fType=$P(fsn(table),"|",4)
	set label="vUX"_fType
	;
	if $$hasSubr^UCGM(label) quit
	;
	do addSubr^UCGM(label,"(table,object)","Build UX array from Record")
	;
	set del=$P(fsn(table),"|",10)
	if del="" set del=124
	if del>31 set del=""""_$C(del)_""""
	else  set del="$C("_del_")"
	;
	if fType>1 do  do copyUX1(10,fType)
	.	;
	.	set do=".."_tab_tab,ref=oLvn_"(object,-100,n,di)"
	.	do append(tab_"N di,ov,n,nv,pos,typ",label)
	.	do append(tab_"S n="""",di=""""",label)
	.	do append(tab_"F  S n=$O("_oLvn_"(object,-100,n)) Q:n=""""  D",label)
	;
	if fType=1 do  do copyUX1(1,fType) quit			; Record type 1
	.	;
	.	set do="."_tab,ref=oLvn_"(object,-100,di)"
	.	do append(tab_"N di,ov,nv,pos,typ",label)
	.	do append(tab_"S di=""""",label)
	;
	if fType=11 do  do copyUX1(1,fType)			; Record type 11
	.	;
	.	set do="."_tab,ref=oLvn_"(object,-100,di)"
	.	do append(tab_"S di=""""",label)
	;
	do append(tab_"Q",label)
	Q
	;
	;-----------------------------------------------------------------------
copyUX1(fType,xtype) ; local;
	;-----------------------------------------------------------------------
	;
	do append(tab_$E(do,2,3)_"F  S di=$O("_ref_") quit:di=""""  D",label)
	do append(tab_do_"S ov=$G("_ref_")",label)
	do append(tab_do_"I ov="_""""""_" Q",label)
	do append(tab_do_"S typ=$E(ov),pos=$E(ov,2,4),ov=$E(ov,5,$L(ov))",label)  ;pc 11/19/02 increase to 3 bytes for pos
	do append(tab_do_"S nv=$P("_oLvn_"(object"_$S(fType=10:",n",1:"")_"),"_del_",+pos)",label)
	do append(tab_do_"I ov=nv Q",label)
	do append(tab_do_"I typ=""L"",+ov=+nv Q",label)
	do append(tab_do_"I ""N$""[typ,ov-nv=0,ov'="""",nv'="""" Q",label)
	do append(tab_do_"S UX(table,di)=ov_""|""_nv"_$S(fType>1:"_""|""_n_""||1""",1:"_""|||1"""),label)
	if xtype=11 quit				; need to call this section again
	do append(tab_"Q",label)
	quit
	;
	;-----------------------------------------------------------------------
bypassQual() ;public Sting; return the Qualifiers that constitute bypassSave
	;-----------------------------------------------------------------------
	; Record.bypassSave() is now short for
	; Record.save("/NOJOURNAL/NOTRIGAFT/NOTRIGBEF/NOVALDD/NOVALREQ/NOVALRI/NOVALST")
	;
	; Return applicable qualifiers
	quit "/NOJOURNAL/NOTRIGAFT/NOTRIGBEF/NOVALDD/NOVALREQ/NOVALRI/NOVALST"
	;
	;-----------------------------------------------------------------------
bypassSave ; private; method Record.bypassSave; returns void
	;-----------------------------------------------------------------------
	; Record.bypassSave() is now short for
	; Record.save("/NOJOURNAL/NOTRIGAFT/NOTRIGBEF/NOVALDD/NOVALFK/NOVALREQ/NOVALRI/NOVALST")
	;
	; NOTES:
	; . Subroutines xindex(), and copyUX() were only called from the code
	;	that has been commented out. These subroutines may be removed
	;	later. Subroutine copyUX1() is only called from copyUX() and may
	;	be removed as well.
	;
	; If dynamic, all runtime processing (including TP) is handled by
	; bypassSave^DBSDYNRA()
	if table="" set return="bypassSave^DBSDYNRA("_objectName_")" quit
	;
	; set actual(1) for save and call save
	set actual(1)=""""_$$bypassQual_""""
	do save
	quit
	;
	;-----------------------------------------------------------------------
overlay ; private; generate code for Record.overlay
	;-----------------------------------------------------------------------
	; Move overlay information from array into primary table object
	;
	; INPUTS:
	;
	;	expr		method expression
	;	type()		object definition table
	;	actual()	parameter
	;
	; OUTPUTS:
	; . return = DO argument for this RecordXxx.overlay appended to mcode
	; . subroutine vReOvlNN() appended to generated code
	; . subroutine for indirect column assignment added to generated code
	;	(see dynamic^UCCOLUMN).
	;
	; NOTES:
	; . The current version discards the value of the audit flag for the
	;	record instance being passed, because there is no easy way to set
	;	this for the "vOid" variable that is passed to dynamic^UCCOLUMN.
	;	Once UCRECORD is migrated to PSL, the code for the overlay
	;	subroutine can be generated using PSLBuffer, and a line can be
	;	inserted that "copies" the audit flag of ObjectName into the
	;	new subbroutine (cf setMaster^UCCOLSF).
	; . Similarly, the call to dynamic^UCCOLUMN() can be replaced by ordinary
	;	column indirection, provided the datatype translation is handled
	;	here
	;
	new array set array=actual(1)
	if array["""" set array=$P(array,"""",2)
	if $E(array)="." set array=$E(array,2,$L(array))
	;;;
	;;; call dynamic^UCCOLUMN with:
	;;; - dynamic = 1 to build code to convert external formats to internal
	;;; - recInst = vOid
	;;; - table
	;;;- property = colmn name derived from subsrcipt in vArr()
	;;; Protect lvn class, because it is assigned by $$dynamic^UCCOLUMN
	;;;new apl,class set apl=$$dynamic^UCCOLUMN(1,"vOid",table,"@$P(vi,""."",2)",1)
	;;;new vsr set vsr=struct("setProperty") kill struct("setProperty")
	;
	; Mark as instantiation
	new dummy set dummy=$$insByOvs^UCREC4OP(subRou,objectName,"","U")
	;
	; Build a label to loop through the data and call the label
	; generated to update an object
	;
	set comment="Record"_table_".overlay()"
	set label=$$findSubr^UCGM("vReOvl",comment)
	;;for i=1:1 do  quit:QUIT
	;;.	;
	;;.	set QUIT=0
	;;.	set label="vReOvl"_i
	;;.	if '$D(labels(label)) set QUIT=1 quit
	if '$$hasSubr^UCGM(label) do
	.	;
	.	do addSubr^UCGM(label,"(vOid,vArr)",comment)
	.	;
	.	do append(tab_"new vi",label)
	.	do append(tab_"set vi="""_table_".""",label)
	.	;
	.	do append(tab_"for  set vi=$O(vArr(vi)) Q:vi=""""!(vi'["""_table_"."")  do propSet^DBSDYNRA(vOid,$P(vi,""."",2),vArr(vi),1,1)",label)
	.	do append(tab_"quit",label)
	;
	set return=label_"("_objectName_",."_array_")"
	;
	quit
	;
	;-----------------------------------------------------------------------
setCreate ; private; method Record.setCreateOnly; returns void
	;-----------------------------------------------------------------------
	;
	do forceMode^UCREC4OP(subRou,objectName,0)
	quit
	;
	;-----------------------------------------------------------------------
setUpdate ; private; method Record.setUpdateOnly; returns void
	;-----------------------------------------------------------------------
	;
	do forceMode^UCREC4OP(subRou,objectName,1)
	quit
	;
	;-----------------------------------------------------------------------
getMode ; private; method Record.getMode
	;-----------------------------------------------------------------------
	;
	set return="$G("_$$getModeVar(objectName,1)_")"
	;
	if '($$getOpti^UCGM(objectName,objectLevel)>msrc) quit
	;
	do setOpti^UCGM(objectName,objectLevel,0)
	quit
	;
	;-----------------------------------------------------------------------
getModeVar(recInst,bPatch) quit $$getPurVar(recInst,-2,bPatch) ;local String; return Record mode variable reference
	;-----------------------------------------------------------------------
	;
	;-----------------------------------------------------------------------
setMode ; private; method Record.setMode
	;-----------------------------------------------------------------------
	;
	; FSCW CR?: actual() has already been parsed as valExpr.
	; Its value shall be used as supplied.
	; If RDB:
	; - if value not literal, defer manipulation (mode value not known until
	;	runtime).
	; - if value literal, setMode(0) shall create the -161/-162 for all
	;	non-null column values, whereas setMode(1) shall create the -152
	;	for the current key.
	;
	if actual(1)="" do ERROR^UCGM("Mode parameter Required") quit
	;
	new autolog,expr,label,needSR,td
	set needSR=$$rtIsRdb^UCXDD(table)
	;
	set expr=$$valExpr^UCGM(actual(1)) if ER quit
	;
	set mcode=$E(mcode,1,$L(mcode)-2)_"S "
	set return=$$getModeVar(objectName,1)
	;
	; FSCW/DSR CR27491: The statement below may need to be reconsidered.
	; Just like a setMode(0) requires level -150 assignments, there are
	; cases for both MDB and RDB that -100 assignments may be in order.
	; For example if the table has .autoLog=true, DBSLOGIT will look at -100
	; nodes to perform the logging.
	; Since not all copy() calls would need this, the most natural way to
	; implement this would be to include -100 management if (and only if)
	; .setAuditFlag(1) has been invoked on the target.
	;
	set td=$$caPslTbl^UCXDD(.pslTbl,table,expr>0)
	set autolog=$P(td,"|",16)
	if expr=0,'needSR,autolog,$$getAtt^UCGM(objectName,,12) set needSR=1
	;
	; 'needSR is OK here. So are setMode(2) and setMode(3) (by definition)
	if expr>1!'needSR set return=return_"="_expr quit
	;
	; RDB, or setMode(0) + MDB + autolog + audit.
	;
	; For a relational database, and setMode(0), the -161/-162 level
	; must be set to include all non-null columns, otherwise these columns
	; will not get written to the database. This should only apply to cases
	; where the mode is set to zero, because that would mean there is no
	; record in the database for this object, and in order to get it into
	; the database, all columns must be included in the insert statement.
	; For setMode(1), the situation is slightly simpler because any
	; columns already set will have -161/-162 present, but the UPDATE code
	; expects the -152 node to be present.
	; Furthermore setMode(2) and setMode(3) are likely to result in calls to
	; the filer that may load nodes incrementally using the -152 node
	; values.  In these cases the -152 node will only be created when it does
	; not yet exist.
	;
	; Label vReModnn is reserved for the setMode method labels in the
	; compiled code.  The name corresponds to Record Class (Re) and
	; method name (setMode).
	set label=$$newLabel^UCGM("ReMod",.labels)
	do addSubr^UCGM(label,"()",class_"."_method_": "_table)
	set return=return_"=$$"_label_"()"
	;
	; If setMode(1)
	if expr>0 do  quit
	.	new code,i,pkl
	.	set pkl=$p(td,"|",3)
	.	set code=" new v0 for v0=-3:-1:-"_($l(pkl,",")+2)_" if "_oLvn_"("_objectName_",v0)="""" set $ZE=""0,""_$ZPOS_"",%PSL-E-ACCKEY,Incomplete access key on Record.setMode("_expr_")"",$EC="",U1001,"""
	.	do append(" if '$D("_oLvn_"("_objectName_",-152))"_$$getUpdKey^UCXDD(td,objectName)_code,label)
	.	do append(" quit "_expr,label)
	;
	; Else setMode(0):
	new cd,curexpr,di,line,updOvh,X
	;
	; For wide tables, need to initialize -161/-162 and node if they aren't
	; already present
	set cd=$$getInitCode^UCXDD(td,objectName,1)
	if cd'="" do append(tab_cd,label)
	;
	set di=""
	for  set di=$O(^DBTBL("SYSDEV",1,table,9,di)) quit:di=""  do
	.	quit:$E(di)=""""	; ignore literals
	.	quit:di?.n		; ignore numeric keys
	.	set X=^DBTBL("SYSDEV",1,table,9,di)
	.	quit:$P(X,"|",16)'=""	; ignore computeds
	.	quit:$$isSfdMaster^UCXDD(table,di,$P(X,"|",17))	; ignore masterfields
	.	set cd=$$caPslCln^UCXDD(.pslCln,table_"."_di,.pslTbl),line=""
	.	if $$getCurNode^UCXDD(cd,0)'="" set line="$d("_$$getCurLvn^UCXDD(cd,objectName)_"),"
	.	set curexpr=$$getCurExpr^UCXDD(cd,objectName,0)
	.	set updOvh=$$getUpdOvh^UCXDD(cd,td,objectName,autolog,0)
	.	; If line too long, use RdbCodeForm for function, versus in-line
	.	if $L(line_curexpr)+20+$L(updOvh)>$$getPslValue^UCOPTS("maxLineLength") set updOvh=$$getUpdOvh^UCXDD(cd,td,objectName,autolog,1)
	.	do append(" if "_line_curexpr_"'="""""_$TR(updOvh,$C(9)),label)
	do append(" quit "_expr,label)
	quit
	;
	;-----------------------------------------------------------------------
setAudit ; private; method Record.setAuditFlag(state)
	;-----------------------------------------------------------------------
	;
	if actual(1)="" set actual(1)=1			; default to true
	;
	; Cannot turn off if access rights include UPDATE_RESTRICT
	if actual(1)=0 do
	.	set table=$E($P(type(newLevel,objectName),tab,1),7,999)
	.	set td=$$getPslTbl^UCXDD(table,0)
	.	quit:$$checkAccessRights^UCXDD(td,0)'["updateRestrict"
	.	do INFO^UCGM("DATABASE","Ignoring set Audit Flag off for table "_table_" with UPDATE_RESRICT access rights checking")
	.	set actual(1)=1
	;
	set $P(type(newLevel,objectName),tab,12)=actual(1)
	quit
	;
	;-----------------------------------------------------------------------
isChanged ;Private;isChanged method
	;-----------------------------------------------------------------------
	; DESC:	Determine if a column has been changed. This function will
	; generate code to be added to the routine being compiled.
	;
	; INPUTS:
	; . actual(1) - column name				/TYP=T/REQ
	;	Accepts literal column name or a variable
	; . actual(2) - Change Type				/TYP=T/NOREQ
	;	Check to determine if the column was changed by the
	;	USER or the SYSTEM. These two keywords are the only possible
	;	values accepted.
	; . pslCln() - array of SchemaColumn instances
	;	the column of actual(1) will be added to the definition if not
	;	yet present
	; . pslTbl() - array of PSLTable instances
	;	the table asspociated with the Record class will be added to the
	;	definition if not yet present
	; . table = table associated with current record
	;
	; RETURNS:
	; . return = generated code to be added to the compiled code
	;
	new code,col,dlm
	set col=$G(actual(1))
	;
	; CR 7813 - No column parameter, return whether object has any changes
	if col="" set return="$D(vobj("_objectName_",-100))" quit
	;
	if '$D(pslTbl(table)) set pslTbl(table)=$$getPslTbl^UCXDD(table,0)
	set dlm=$P(pslTbl(table),"|",10)
	;
	set code=$$QSUB^%ZS($G(actual(2)))
	if code'="",code'="USER",code'="SYSTEM" D ERROR^UCGM("Incorrect Change value entered")
	;
	; FSCW CR15028: code commented out because it ignores the possibility
	;	to supply the name of a key column
	;;; record Type 1's will use the last key as the nod into level -100
	;;; get that key from the fsn returned for the table
	;;if recType=1 do  quit
	;;.	;
	;;.	; Record type 1
	;;.	set nod=$p(keys,",",$l(keys,","))
	;;.       if rdb set nod="ORACLE"                 ; Dummy node
	;;.	if code="USER" S return="+$P($G(vobj("_objectName_",-100,"""_nod_""","_col_")),""|"",2)" Q
	;;.	if code="SYSTEM" S return="($G(vobj("_objectName_",-100,"""_nod_""","_col_"))'=""""&('$P($G(vobj("_objectName_",-100,"""_nod_""","_col_")),""|"",2)))" Q
	;;.	set return="$D(vobj("_objectName_",-100,"""_nod_""","_col_"))"
	;
	; Handle literal column names. Column is known at compile time, so node
	; is known at compile time, and correct reference can be generated here.
	if $$isLit^UCGM(col) do  quit
	.	;;;
	.	;;; FSCW CR15028: code identical for all recTypes
	.	;;if recType>1 do  quit
	.	;;set nod=$P($$DI^SQLDD(col,table,,.fsn),"|",1)
	.	;;if rdb set nod=$$nod^DBMAP(%DB,table,$$QSUB^%ZS(col))  ;wide table
	.	;;if $E(nod)?1A S nod=""""_nod_""""
	.	set col=$p(col,"""",2)
	.	new z set z=$$rtOldLvn^UCXDD(table,col,objectName,.pslTbl,.pslCln)
	.	if code="USER" set return="+$P($G("_z_"),$C("_dlm_"),2)"
	.	else  if code="SYSTEM" set return="($G("_z_")'=""""&('$P($G("_z_"),$C("_dlm_"),2)))"
	.	else  set return="$D("_z_")"
	.	set return="("_return_"&($P($E($G("_z_"),5,9999),$C("_dlm_"))'="_$$getCurExpr^UCXDD(pslCln(table_"."_col),objectName,0)_"))"
	;
	; Handle columns when value not literal.
	; For usageType="" and usageType="USER", only a single reference to the
	; "oldval" node is needed. This can be coded by an in-line call to
	; $$rtOldNode^UCXDD() in combination with indirection
	; The node will not be known at compile time, this code adds a new label
	; in order to determine that node and perform the test.
	;
	new src,ref
	set ref=$$newLabel^UCGM("Met",.labels)
	do addSubr^UCGM(ref,"(object,p1,p2)","Column Changed Check")
	;
	;;set src="N nod"
	;;do append^UCRECORD(tab_src,ref)
	;;set src="S nod=$P($G(^DBTBL(""SYSDEV"",1,p1,9,p2)),""|"",1)"
	set src="N nod S nod=$$rtOldNode^UCXDD(p1,p2,0)"
	do append^UCRECORD(tab_src,ref)
	;;set src="I $E(nod)?1A S nod=""""""""_nod_"""""""""
	;;do append^UCRECORD(tab_src,ref)
	if code="USER" S src="Q +$P($G(vobj(object,-100,nod,p2)),$C("_dlm_"),2)"
	else  if code="SYSTEM" S src="Q $G(vobj(object,-100,nod,p2))'=""""&('$P($G(vobj(object,-100,nod,p2)),$C("_dlm_"),2))"
	else  set src="Q $D(vobj(object,-100,nod,p2))"
	set src=src_"&($P($E($G(vobj(object,-100,nod,p2)),5,9999),$C("_dlm_"))'=$$propGet^DBSDYNRA(object,p2))"
	;
	do append^UCRECORD(tab_src,ref)
	;
	set return="$$"_ref_"("_objectName_","""_table_""","_col_")"
	;
	quit
	;
	;-----------------------------------------------------------------------
fromArchive ; private; method Record.fromArchive
	;-----------------------------------------------------------------------
	;
	set return="$G("_$$getArchiveVar(objectName,1)_")'="""""
	;
	if '($$getOpti^UCGM(objectName,objectLevel)>msrc) quit
	;
	do setOpti^UCGM(objectName,objectLevel,0)
	;
	; See comments associated with getMode related to additional optimization
	;
	quit
	;
	;-----------------------------------------------------------------------
getArchiveVar(recInst,bPatch) quit $$getPurVar(recInst,-99,bPatch) ;local String; return Record archive directory variable reference
	;-----------------------------------------------------------------------
	;
	;-----------------------------------------------------------------------
xindex(table) ;local; Load xindex for a table
	;-----------------------------------------------------------------------
	;
	new i,keys,index,test,z
	;
	set test=","_$P(fsn(table),"|",3)_","
	;
	set index=""
	for  set index=$O(^DBTBL("SYSDEV",8,table,index)) quit:index=""  do
	.	;
	.	new tok
	.	set z=^(index),keys=$$TOKEN^%ZS($P(z,"|",3),.tok)
	.	for i=1:1:$L(keys,",") do
	..		;
	..		set key=$P(keys,",",i)
	..		if $A(key)=0 quit
	..		if keys=+keys quit
	..		if test[(","_key_",") quit
	..		if '$D(xindex(table,key)) set xindex(table,key)=index
	..		else  S xindex(table,key)=xindex(table,key)_","_index
	;
	set xindex(table)=""
	quit
	;
	;-----------------------------------------------------------------------
append(code,label) do addCode^UCPSLSR(label,code) quit ; local; Add code to the append
	;-----------------------------------------------------------------------
	;
	;-----------------------------------------------------------------------
ET	; local; Error trap
	;-----------------------------------------------------------------------
	;
	do ERROR^UCGM($$ETLOC^%ZT)
	quit
	;
	;-----------------------------------------------------------------------
Checkrec ; local; check for recursive calls to a label.
	;-----------------------------------------------------------------------
	; This check will help avoid stack critical errors in
	; runtime processing as well as during the compile of the procedure.
	;
	new calllist,checklist,count,I
	do Stackbld
	set calllist=$G(calllist(subRou))
	if calllist=""!(calllist=",") quit
	for I=2:1:$L(calllist,",")-1 if $p(calllist,",",I)'="" set checklist(subRou,$p(calllist,",",I))="",checklist(subRou)=$g(checklist(subRou))+1
	set ER=0
	quit:'$D(checklist(subRou))
	;
	; Loop until all labels have been traced (count value will be equal)
	; or ER is defined (recursive error)
	for  do Checkstck quit:checklist(subRou)=count!(ER)
	;
	quit
	;
	;-----------------------------------------------------------------------
Checkstck ; local; Verify that the current subRou is not called by another label
	; within this procedure.
	;-----------------------------------------------------------------------
	;
	; Based on the labels called from the subroutine, build entries in
	; array checklist to specify that the label has already been checked
	; by setting it to *. Add to checklist array any label in the calling
	; structure which is called by a label but has not been checked. The
	; checking of each label has to verify that the original subroutine
	; is not called by label being checked. If that occurs, then the an
	; error is generated and the compile will be stopped.
	;
	set count=0
	new calling,check
	set calling=""
	for  set calling=$o(checklist(subRou,calling)) quit:calling=""  do  quit:ER
	.	set calllist=$G(calllist(calling))
	.	if checklist(subRou,calling)="*" set count=count+1 quit
	.	if calllist=""!($TR(calllist,",","")="") set checklist(subRou,calling)="*" quit
	.	set check=","_calling_","
	.	for I=2:1:$L(calllist,",")-1 do  quit:ER
	..		set list=$p(calllist,",",I)
	..		quit:list=""
	..		set check=","_list_","
	..		if calllist(subRou)[check,$L($G(calllist(list)))>1 D  Q
	...			new subRou
	...			set subRou=calling
	...			do ERROR^UCGM("Recursive loop, Label called by label within lower level of stack list :"_list)
	...			set ER=1
	..		if $d(checklist(subRou,list)) quit
	..		set checklist(subRou,list)=""
	..		set checklist(subRou)=$g(checklist(subRou))+1
	.	set checklist(subRou,calling)="*"
	quit
	;
	;-----------------------------------------------------------------------
Stackbld ; local; Build array 'calllist' to use in checking recursive stacks
	;-----------------------------------------------------------------------
	;
	; The output from this label is an array named calllist which is
	; keyed by the label name. The data stored in the array are all
	; of the labels called by the label. Many of those labels are removed
	; by the reduce section by determining that the label called does
	; not call another label.
	;
	new called,caller,i,index,list,lnum,subcalls,xcalls
	set (called,lnum,subcalls)=""
	for  set subcalls=$o(calls(subcalls)) quit:subcalls=""  do
	.	set calllist(subcalls)=","
	.	for  set lnum=$o(calls(subcalls,lnum)) quit:lnum=""  do
	..;		if msrc(lnum)[" I " quit
	..		for  set called=$o(calls(subcalls,lnum,called)) quit:called=""  do
	...			set caller=$p(called,"(",1)
	...			if caller["^" quit
	...			set caller=","_caller_","
	...			if calllist(subcalls)[caller quit
	...			set calllist(subcalls)=calllist(subcalls)_$e(caller,2,100)
	...			set xcalls($tr(caller,",",""),subcalls)=""
	;
	set caller=""
	for  set caller=$o(calllist(caller)) quit:caller=""  if $TR(calllist(caller),",","")="" kill calllist(caller)
	for index=1:1:8 do reduce
	;
	quit
	;-----------------------------------------------------------------------
reduce	; local;
	;-----------------------------------------------------------------------
	; reduce is used to remove all labels from the calllist array that
	; can not possibly cause a stack crit error. By the time it is called
	; labels which do not call another label have been removed. Once those
	; are removed, the remaining entries are reviewed and the labels called
	; from those entries that do not exist in calllist are removed from
	; the list of labels called by that label. Through iteration, we reduce
	; the number of labels in this array to a list of labels called which
	; can not be reduced any further. This list will be used by Checkbld
	; label to determine if a stack crit error can occur due to labels
	; calling back to a label that called them.
	;
	set caller=""
	for  set caller=$o(xcalls(caller)) quit:caller=""  do:'$D(calllist(caller))
	.	set subcalls=""
	.	for  set subcalls=$o(xcalls(caller,subcalls)) quit:subcalls=""  do
	..		set calllist=$g(calllist(subcalls))
	..		if calllist="" quit
	..		for i=2:1:$l(calllist,",")-1 if $p(calllist,",",i)=caller!('$D(calllist($p(calllist,",",i)))) set $p(calllist,",",i)=""
	..		if $TR(calllist,",","")="" kill calllist(subcalls)
	..		set calllist(subcalls)=calllist
	for  set caller=$o(calllist(caller)) quit:caller=""  if $TR(calllist(caller),",","")="" kill calllist(caller)
	quit
	;
	;-----------------------------------------------------------------------
compare ; private; record.compare
	;-----------------------------------------------------------------------
	; Generate code to compare node by node and column by column any
	; two instantiated objects of the same record type.
	; data is returned in a result set format column name, oldval,newval.
	; The vobj() structure is used as follows:
	; * vobj(rs,-3) = "COLUMNNAME,OLDVALUE,NEWVALUE"
	; * vobj(rs,-4) = "T0T0T0"
	; * vobj(rs,-5) = 0 (not RDB)
	; * vobj(rs, 1) = columnname for next fetch
	; * vobj(rs,columnname) = old_value <tab> new_value
	; * all other nodes are standard
	;
	new class,code,del,fetcLabel,label,keys,obj1,obj2,openLabel,ftype,rdb,seq,table,varPtr,ztbl
	;
	set obj1=objectName
	set ztbl=$$getClass^UCGM(obj1)
	set table=$P(ztbl,"Record",2)
	;
	set obj2=actual(1)
	if obj2["." set obj2=$p(obj2,".",2)
	set class=$$getClass^UCGM(obj2)
	;;if class="",$g(res)["="_obj2 set class=$$getClass^UCGM($p(res,"=",1))
	if class'=ztbl do ERROR^UCGM("Compare class must be the same") quit
	;
	if '$D(fsn(table)) do fsn^SQLDD(.fsn,table)
	set ftype=$p(fsn(table),"|",4)
	set del=$p(fsn(table),"|",10)
	;
	set varPtr=$$getNew^UCGM(var,.varLevel)
	;
	; open code
	set openLabel=$$newLabel^UCGM("Open",.labels)
	set seq=$E(openLabel,6,$L(openLabel))
	set struct("s",subRou,varPtr,var)=(msrc+1)_tab_seq_tab_tab_"COLUMNNAME,OLDVALUE,NEWVALUE"_tab_1_tab_"T0T0T0"
	set fetcLabel="vFetch"_seq
	set lineLabel="vL"_seq_"a"
	;
	do addSubr^UCGM(openLabel,"(vObj1,vObj2)","Record.compare("_class_")")
	do append^UCGM(" N vRsObj",openLabel)
	do append^UCGM(" S vRsObj=$O("_oLvn_"(""""),-1)+1",openLabel)
	do append^UCGM(" S "_oLvn_"(vRsObj,0)=1",openLabel)
	do append^UCGM(" S "_oLvn_"(vRsObj,-1)=""ResultSet""",openLabel)
	do append^UCGM(" S "_oLvn_"(vRsObj,-2)=""$$"_fetcLabel_"^""_$T(+0)",openLabel)
	do append^UCGM(" S "_oLvn_"(vRsObj,-3)=""COLUMNNAME,OLDVALUE,NEWVALUE""",openLabel)
	do append^UCGM(" S "_oLvn_"(vRsObj,-4)=""T0T0T0""",openLabel)
	do append^UCGM(" S "_oLvn_"(vRsObj,-5)=0",openLabel)
	;
	do append^UCGM(" N vCol,vMax,vNod1,vNod2,vNod,vPos",openLabel)
	do append^UCGM(" D "_lineLabel_"0",openLabel)
	do append^UCGM(" Q vRsObj",openLabel)
	;
	do append^UCGM(lineLabel,openLabel)
	do append^UCGM(" S "_oLvn_"(vRsObj,0)=0",openLabel)
	do append^UCGM(" Q",openLabel)
	;
	do append^UCGM(lineLabel_0,openLabel)
	do append^UCGM(" S "_oLvn_"(vRsObj,0)=1",openLabel)
	;
	; key compare
	set keys=$p(fsn(table),"|",3)
	if keys["," do
	.	; multiple keys
	.	set code=" F vNod=-3:-1:"_(-2-$L(keys,","))
	.	set code=code_" I "_oLvn_"(vObj1,vNod)'="_oLvn_"(vObj2,vNod)"
	.	set code=code_" S "_oLvn_"(vRsObj,$P("""_keys_""","","",-vNod-2))="_oLvn_"(vObj1,vNod)_$C(9)_"_oLvn_"(vObj2,vNod)"
	else  if keys'="" do
	.	; single key
	.	set code=" I "_oLvn_"(vObj1,-3)'="_oLvn_"(vObj2,-3)"
	.	set code=code_" S "_oLvn_"(vRsObj,"""_keys_""")="_oLvn_"(vObj1,-3)_$C(9)_"_oLvn_"(vObj2,-3)"
	else  set code=" ;"	; no key
	do append^UCGM(code,openLabel)
	;
	; top node compare
	; use name of last key as "node" to tranlate position to columnname
	if ftype#2 do
	.	set code="I "_oLvn_"(vObj1)="_oLvn_"(vObj2) "
	.	if ftype=1 set code=code_"G "_lineLabel
	.	else  set code=code_"S vNod=-.01 G "_lineLabel_2
	.	do append^UCGM(tab_code,openLabel)
	.	do append^UCGM(" S vNod="""_$p(keys,",",$l(keys,","))_"""",openLabel)
	.	do append^UCGM(" S vPos=1",openLabel)
	.	do append^UCGM(" S vMax=$S($L("_oLvn_"(vObj1),$C("_del_"))>$L("_oLvn_"(vObj2),$C("_del_")):$L("_oLvn_"(vObj1),$C("_del_")),1:$L("_oLvn_"(vObj2),$C("_del_")))+1",openLabel)
	.	do append^UCGM(lineLabel_"1",openLabel)
	.	set code=" F vPos=vPos:1:vMax "
	.	set code=code_"Q:$P("_oLvn_"(vObj1),$C("_del_"),vPos)"
	.	set code=code_"'=$P("_oLvn_"(vObj2),$C("_del_"),vPos)"
	.	do append^UCGM(code,openLabel)
	.	set code=" I vPos=vMax "
	.	if ftype>1 s code=code_"S vNod=-.01 G "_lineLabel_2
	.	else  set code=code_" G "_lineLabel_4
	.	do append^UCGM(code,openLabel)
	.	do append^UCGM(" S vCol="_$$DILIST(table,"vNod","vPos"),openLabel)
	.	do append^UCGM(" S "_oLvn_"(vRsObj,vCol)=$P("_oLvn_"(vObj1),$C("_del_"),vPos)_$C(9)_$P("_oLvn_"(vObj2),$C("_del_"),vPos)",openLabel)
	.	do append^UCGM(" S vPos=vPos+1",openLabel)
	.	do append^UCGM(" G "_lineLabel_1,openLabel)
	;
	; Code to iterate over and compare other nodes
	if ftype>1 do
	.	if ftype=10 do
	..		do append^UCGM(" S vNod=-.01",openLabel)
	..		do append^UCGM(" S "_oLvn_"(vRsObj,0)=1",openLabel)
	.	;
	.	do append^UCGM(lineLabel_2,openLabel)		; label to advance to next node
	.	do append^UCGM(" S vNod1=$O("_oLvn_"(vObj1,vNod))",openLabel)
	.	do append^UCGM(" S vNod2=$O("_oLvn_"(vObj2,vNod))",openLabel)
	.	do append^UCGM(" S vNod=$S(vNod1=""""!(vNod1<0):vNod2,vNod2=""""!(vNod2<0):vNod1,vNod1]]vNod2:vNod2,1:vNod1)",openLabel)
	.	do append^UCGM(" I vNod="""" G "_lineLabel_4,openLabel)
	.	do append^UCGM(" I $G("_oLvn_"(vObj1,vNod))=$G("_oLvn_"(vObj2,vNod)) G "_lineLabel_2,openLabel)
	.	;
	.	; add code that initiates 'position' (=1) and code that
	.	; initiates max position (= 'longest' string + 1)
	.	do append^UCGM(" S vPos=1",openLabel)	; code that initiates 'position'
	.	do append^UCGM(" S vMax=$S($L($G("_oLvn_"(vObj1,vNod)),$C("_del_"))>$L($G("_oLvn_"(vObj2,vNod)),$C("_del_")):$L($G("_oLvn_"(vObj1,vNod)),$C("_del_")),1:$L($G("_oLvn_"(vObj2,vNod)),$C("_del_")))+1",openLabel)
	.	;
	.	do append^UCGM(lineLabel_3,openLabel)		; label to loop though one node
	.	;
	.	; FSCW CR18163: next two line moved.
	.	; First line moved up (vMax is constant for current node)
	.	; Second line moved down (it is the only terminating condition
	.	; for a node)
	.	;;do append^UCGM(" S vMax=$S($L($G("_oLvn_"(vObj1,vNod)),$C("_del_"))>$L($G("_oLvn_"(vObj2,vNod)),$C("_del_")):$L($G("_oLvn_"(vObj1,vNod)),$C("_del_")),1:$L($G("_oLvn_"(vObj2,vNod)),$C("_del_")))+1",openLabel)
	.	;;do append^UCGM(" I vPos=vMax G "_lineLabel_"2",openLabel)
	.	set code=" F vPos=vPos:1:vMax "
	.	set code=code_"Q:$P($G("_oLvn_"(vObj1,vNod)),$C("_del_"),vPos)"
	.	set code=code_"'=$P($G("_oLvn_"(vObj2,vNod)),$C("_del_"),vPos)"
	.	do append^UCGM(code,openLabel)
	.	do append^UCGM(" I vPos=vMax G "_lineLabel_2,openLabel)
	.	;
	.	; FSCW CR18163: line below commented out, vObj1 node could be the shortest!
	.	;;do append^UCGM(" I vPos>$L($G("_oLvn_"(vObj1,vNod)),$C("_del_")) G "_lineLabel_"2",openLabel)
	.	do append^UCGM(" S vCol="_$$DILIST(table,"vNod","vPos"),openLabel)
	.	do append^UCGM(" S "_oLvn_"(vRsObj,vCol)=$P($G("_oLvn_"(vObj1,vNod)),$C("_del_"),vPos)_$C(9)_$P($G("_oLvn_"(vObj2,vNod)),$C("_del_"),vPos)",openLabel)
	.	do append^UCGM(" S vPos=vPos+1",openLabel)
	.	do append^UCGM(" G "_lineLabel_3,openLabel)
	do append^UCGM(" Q",openLabel)
	;
	; Check for any differences found
	do append^UCGM(lineLabel_4,openLabel)			; label to set row-pointer and state
	do append^UCGM(" S "_oLvn_"(vRsObj,1)=$O("_oLvn_"(vRsObj,1))",openLabel)
	do append^UCGM(" I "_oLvn_"(vRsObj,1)="""" S "_oLvn_"(vRsObj,0)=0",openLabel)
	do append^UCGM(" Q",openLabel)
	do append^UCGM(" ;",openLabel)
	;
	;fetch code
	do append^UCGM(fetcLabel_"(vRsObj)"_tab_";",openLabel)
	do append^UCGM(" I "_oLvn_"(vRsObj,0)=0  Q 0",openLabel)
	do append^UCGM(" S "_oLvn_"(vRsObj)="_oLvn_"(vRsObj,1)_$C(9)_"_oLvn_"(vRsObj,"_oLvn_"(vRsObj,1))",openLabel)
	do append^UCGM(" S "_oLvn_"(vRsObj,1)=$O("_oLvn_"(vRsObj,"_oLvn_"(vRsObj,1)))",openLabel)
	do append^UCGM(" I "_oLvn_"(vRsObj,1)="""" S "_oLvn_"(vRsObj,0)=0",openLabel)
	do append^UCGM(" Q 1",openLabel)
	set return="$$"_openLabel_"("_obj1_","_obj2_")"
	quit
	;-----------------------------------------------------------------------
DILIST(FID,NODE,POS) ; local;
	;-----------------------------------------------------------------------
	; returns FIRST column at that position, which may be incorrect for
	; masterfield/subfield on MDB.
	;
	; INPUTS:
	; . type public String %DB
	;	internal data store. Only used if $$rtIsRdb^UCXDD(FID)
	;
	if '$$rtIsRdb^UCXDD(FID) quit "$O(^DBINDX(""SYSDEV"",""STR"","""_FID_""","_NODE_","_POS_",""""),1)"
	quit "$O(^DBINDX(""SYSDEV"",""DBMAP"","""_%DB_""","""_FID_""","_NODE_","_POS_",""""),1)"
	;
	;-----------------------------------------------------------------------
loadXnodes(td,nam,lvpm) ; create the extra nodes (-99, -161, and -162)
	;-----------------------------------------------------------------------
	; This subroutine creates the nodes in lvpm() that are common to both
	; loadAcc() and loadIns():
	;  - lvpm(-99) for access to archived date
	;  - lvpm(-161) and lvpm(-162) for database modify code on RDB.
	;	Note that these nodes actually reference the top of a (sub)tree
	;	so the values created for them end with a comma, not with the
	;	closing parenthesis.
	;
	; NOTES:
	; . See loadXnodes^UCXDD
	; . When we rewrite UCRECORD to PSL, eliminate this section and use
	;   loadXnodes^UCXDD or great new common sub-routine
	;
	; If archived (purpose node -99), set lvpm to ensure extended reference
	if $$getArchiveTable^DBARCHIVE(td)'="" set lvpm(-99)=oLvn_"("_nam_",-99)"
	;
	; If is RDB, set up map for -161/-162
	quit:($P(td,"|",8)="GTM")
	;
	set lvpm(-161)=oLvn_"("_nam_",-161,"
	set lvpm(-162)=oLvn_"("_nam_",-162,"
	;
	quit
	;
	;-------------------------------------------------------------------
ZT	; local; error trap to catch recursion
	;-------------------------------------------------------------------
	if '$ZS["STACKCRIT" D ZE^UTLERR quit
	do Checkrec
	if $G(ER) quit
	new subRou
	set subRou=""
	for  S subRou=$O(dbLoad(subRou)) quit:subRou=""  do Checkrec
	quit
