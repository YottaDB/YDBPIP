 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBARCHIVE ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBARCHIVE ; 
 ;
 ; *******************************************************************
 ; * IMPORTANT NOTE:                                                 *
 ; * According to the rules that apply to PSL compiler upgrades,     *
 ; * the generated M routine associated with this procedure must be  *
 ; * checked into StarTeam and released with the procedure whenever  *
 ; * changes are made to this procedure.  The M routine from the     *
 ; * crtns directory should be used for this purpose.                *
 ; *                                                                 *
 ; * The M routine will be loaded to the mrtns directory during      *
 ; * upgrades and will then be removed from that directory as part   *
 ; * of the upgrade process.  Therefore, other during an upgrade,    *
 ; * an mrtns version of this routine should not exist.              *
 ; *                                                                 *
 ; * Keep these comments as single line to ensure they exist in the  *
 ; * generated M code.                                               *
 ; *******************************************************************
 ;
 ; Compile procedure DBARCHIVE1 (DBARCHIVE2 Builder)
 ;
 ; Generated DBARCHIVE2
 ;
 N cnt N i N keycnt N reccnt
 N %READ N %TAB N ARCHTBL N keys N keyvals N THRUDATE N VFMQ
 ;
 S %TAB("ARCHTBL")=".ARCHTABLE/TBL=[DBUTARCHIVE]"
 S %TAB("THRUDATE")=".ARCHDATE"
 ;
 S %READ="@@%FN,,ARCHTBL,THRUDATE"
 ;
 D ^UTLREAD Q:(VFMQ="Q") 
 ;
 S RM=$$ARCHIVE(ARCHTBL,THRUDATE,"","","")
 ;
 I '(RM="") S ER=1
 ;
 Q 
 ;
ARCHIVE(ARCHTBL,THRUDATE,SELECT,FROM,WHERE) ; Where clause [*]
 N vTp
 ;
 N stop
 N archkey N ARCHNUM N archseq
 N ARCHDIR N DBARCHIVE N ERMSG N keys N keyvals
 ;
 S stop=0
 ;
 ; If any provided, all must be
 I '((SELECT_FROM_WHERE)=""),((SELECT="")!(FROM="")!(WHERE="")) D  Q ERMSG
 .	;
 .	; Invalid SELECT/FROM/WHERE set
 .	S ERMSG=$$^MSG(6903)
 .	Q 
 ;
 L +DBARCHIVE(ARCHTBL):1 E  D  Q ERMSG
 .	;
 .	; Only a single archive process, per table, can be run at a time
 .	S ERMSG=$$^MSG(6902)
 .	Q 
 ;
 ; Get archive information
 ;         #ACCEPT Date=03/01/07; Pgm=RussellDS; CR=25675; Group=Bypass
 ;*** Start of code by-passed by compiler
 set ARCHNUM=$ZTRNLNM("SCAU_ARCHIVE_CURRENT")
 set ARCHDIR=$ZTRNLNM("SCAU_ARCHIVE_"_ARCHNUM)
 ;*** End of code by-passed by compiler ***
 ;
 I ((ARCHDIR="")!(ARCHNUM'>0)) D  Q ERMSG
 .	;
 .	; Archive directory information missing
 .	S ERMSG=$$^MSG(6905)
 .	Q 
 ;
 ; Register M process
 D REGISTER^IPCMGR("ARCHIVE",ARCHTBL)
 ;
 ; Select top-level keys and pass to ARCHIVE^filerPGM to archive
 ;
 N tblDes S tblDes=$$getPslTbl^UCXDD(ARCHTBL,0)
 ;
 S keys=$P(tblDes,"|",3)
 S archkey=$$getArchiveKey^DBARCHIVE(tblDes,0)
 S keys=$piece(keys,",",1,archkey-1) ; Ignore archive key
 ;
 ; SELECT/FROM/WHERE not valid if archive key is first key
 I (archkey=1),'(SELECT="") D  Q ERMSG
 .	;
 .	; Invalid SELECT/FROM/WHERE set
 .	S ERMSG=$$^MSG(6903)
 .	Q 
 ;
 N rsarchist,vos1,vos2,vos3,vos4,vos5 S rsarchist=$$vOpen1()
 ;
 I $$vFetch1() S archseq=rsarchist+1
 E  S archseq=1
 ;
 N dbarchist S dbarchist=$$vcdmNew^RecordDBARCHIST() S vobj(dbarchist,-3)=ARCHTBL S vobj(dbarchist,-4)=archseq
 ;
  S $P(vobj(dbarchist),$C(124),1)=$P($H,",",1)
  S $P(vobj(dbarchist),$C(124),2)=$P($H,",",2)
  S $P(vobj(dbarchist),$C(124),5)=0
  S $P(vobj(dbarchist),$C(124),6)=0
  S $P(vobj(dbarchist),$C(124),7)=0
  S $P(vobj(dbarchist),$C(124),8)=THRUDATE
  S $P(vobj(dbarchist),$C(124),9)=SELECT
  S $P(vobj(dbarchist),$C(124),10)=FROM
  S $P(vobj(dbarchist),$C(124),11)=WHERE
 ;
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBARCHIST(dbarchist,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbarchist,-100) S vobj(dbarchist,-2)=1 TC:vTp  
 ;
 I (archkey=1) D
 .	;
 .	N reccnt
 .	;
 .	S reccnt=$$^DBARCHIVE2(ARCHDIR,ARCHNUM,THRUDATE,ARCHTBL,.keyvals)
 .	;
 .  S $P(vobj(dbarchist),$C(124),5)=reccnt
 .  S $P(vobj(dbarchist),$C(124),6)=reccnt
 .	;
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBARCHIST(dbarchist,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbarchist,-100) S vobj(dbarchist,-2)=1 TC:vTp  
 .	;
 .	; If was interrupted, indicate that here
 .	I '($get(%INTRPT)="") D
 ..		;
 ..		I %INTRPT="STOP" S stop=1
 ..		;
 ..		; Clear Interrupt indicator
 ..		S %INTRPT=""
 ..		Q 
 .	Q 
 E  D
 .	;
 .	N i N primcnt N reccnt
 .	N ORDERBY
 .	;
 .	; If no SELECT/FROM/WHERE, just select top keys from archive table
 .	I (SELECT="") D
 ..		;
 ..		S SELECT=keys
 ..		S FROM=ARCHTBL
 ..		Q 
 .	;
 .	; Add DISTINCT to SELECT if it's not there
 .	I '($E($ZCONVERT(SELECT,"U"),1,8)="DISTINCT") S SELECT="DISTINCT "_SELECT
 .	;
 .	; Strip DISTINCT for order by
 .	S ORDERBY=$piece(SELECT," ",2,$L(SELECT))
 .	;
 .	;          #ACCEPT Date=03/12/07; Pgm=RussellDS; CR=25675; Group=Dynamic
 .	N rs,exe,sqlcur,vd,vi,vsql,vsub S rs=$$vOpen0(.exe,.vsql,SELECT,FROM,WHERE,ORDERBY,"","",1)
 .	;
 .	S (primcnt,reccnt)=0
 .	F  Q:'$$vFetch0(rs)  D  Q:stop 
 ..		;
 ..		F i=1:1:archkey-1 S keyvals(i)=$P(vobj(rs),$C(9),$$vRsGetCol(rs,i))
 ..		;
 ..		S reccnt=reccnt+$$^DBARCHIVE2(ARCHDIR,ARCHNUM,THRUDATE,ARCHTBL,.keyvals)
 ..		S primcnt=primcnt+1
 ..		;
 ..		I (primcnt#10000=0) D
 ...			;
 ...		  S $P(vobj(dbarchist),$C(124),5)=primcnt
 ...		  S $P(vobj(dbarchist),$C(124),6)=reccnt
 ...			;
 ...		 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBARCHIST(dbarchist,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbarchist,-100) S vobj(dbarchist,-2)=1 TC:vTp  
 ...			Q 
 ..		;
 ..		; Check Interrupt status for stop
 ..		I $D(%INTRPT)>1 D INTRPT^IPCMGR
 ..		I '($get(%INTRPT)="") D
 ...			;
 ...			I %INTRPT="STOP" S stop=1
 ...			;
 ...			; Clear Interrupt indicator
 ...			S %INTRPT=""
 ...			Q 
 ..		Q 
 .	;
 .	; Update final numbers
 .  S $P(vobj(dbarchist),$C(124),5)=primcnt
 .  S $P(vobj(dbarchist),$C(124),6)=reccnt
 .	;
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBARCHIST(dbarchist,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbarchist,-100) S vobj(dbarchist,-2)=1 TC:vTp  
 .	K vobj(+$G(rs)) Q 
 ;
  S $P(vobj(dbarchist),$C(124),3)=$P($H,",",1)
  S $P(vobj(dbarchist),$C(124),4)=$P($H,",",2)
 ;
 I stop  S $P(vobj(dbarchist),$C(124),7)=1
 ;
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBARCHIST(dbarchist,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbarchist,-100) S vobj(dbarchist,-2)=1 TC:vTp  
 ;
 L -DBARCHIVE(ARCHTBL)
 ;
 ; Unregister M Process
 D CLOSE^IPCMGR()
 ;
 K vobj(+$G(dbarchist)) Q ""
 ;
STOP ; Allow stop of running archive process
 N vpc
 ;
 ; Called by function DBARCHSTOP
 ;
 N %READ N %TAB N ARCHSTOP N LOOKUP N VFMQ
 ;
 N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen2()
 ;
 I '$G(vos1) D  Q 
 .	;
 .	S ER=1
 .	; No archiving processes are currently running
 .	S RM=$$^MSG(6904)
 .	Q 
 ;
 F  Q:'$$vFetch2()  S LOOKUP($P(rs,$C(9),2))=$P(rs,$C(9),1)
 ;
 S %TAB("ARCHSTOP")=".ARCHSTOP/TBL=LOOKUP("
 ;
 S %READ="@@%FN,,ARCHSTOP"
 ;
 D ^UTLREAD S vpc=(VFMQ="Q") Q:vpc 
 ;
 ; Signal Interrupt to STOP
 D SIGNAL^IPCMGR(LOOKUP(ARCHSTOP),"STOP")
 ;
 S ER="W"
 ; Signal sent. May take up to ~p1 seconds for process to stop.
 S RM=$$^MSG(5533,"10+")
 ;
 Q 
 ;
getArchiveTable(tblDes) ; table descriptor
 ;
 N ArchTbl N TBL
 ;
 S TBL=$P(tblDes,"|",1)
 ;
 I ($D(^UTBL("DBARCHIVE",TBL))#2) Q TBL
 ;
 ; Check each archive enabled table to see if this is a sub-table of it
 ; or is included with it, or is a sub-table of an included table
 N ds,vos1,vos2,vos3 S ds=$$vOpen3()
 ;
 S ArchTbl=""
 F  Q:'$$vFetch3()  D  Q:'(ArchTbl="") 
 .	;
 . N dbutarchive,vop1 S vop1=ds,dbutarchive=$$vRCgetRecord1Opt^RecordDBUTARCHIVE(vop1,1,"")
 .	;
 .	N archDes S archDes=$$getPslTbl^UCXDD(vop1,0)
 .	;
 .	; Sub-table
 .	I ((","_$$getArchiveSubs(archDes)_",")[(","_TBL_",")) S ArchTbl=vop1
 .	E  D
 ..		;
 ..		N included
 ..		;
 ..		S included=$P(dbutarchive,$C(124),1)
 ..		;
 ..		; Related table
 ..		I ((","_included_",")[(","_TBL_",")) S ArchTbl=vop1
 ..		E  D
 ...			;
 ...			N i
 ...			N incltbl
 ...			;
 ...			F i=1:1:$S((included=""):0,1:$L(included,",")) D  Q:'(ArchTbl="") 
 ....				;
 ....				S incltbl=$piece(included,",",i)
 ....				;
 ....				N inclDes S inclDes=$$getPslTbl^UCXDD(incltbl,0)
 ....				;
 ....				; Sub-table of related table
 ....				I ((","_$$getArchiveSubs(inclDes)_",")[(","_TBL_",")) S ArchTbl=vop1
 ....				Q 
 ...			Q 
 ..		Q 
 . Q 
 ;
 Q ArchTbl
 ;
getArchivable(tblDes) ; Table descriptor of table to check
 ;
 N isArchivable
 N ARCHTBL N global
 ;
 S ARCHTBL=$P(tblDes,"|",1)
 ;
 I ($$getArchiveKey(tblDes,0)=0) Q 0
 ;
 ; Archivable table cannot have a query (DBTBL1.QID1) associated with it
 I '($$getQuery^UCXDD(tblDes)="") Q 0
 ;
 ; Archivable table cannot be a parent table
 I $$isParent^UCXDD(tblDes) Q 0
 ;
 S isArchivable=1
 ;
 ; Check to see if a sub-table of another archivable table
 S global=$translate($piece($P(tblDes,"|",2),"(",1),"^","")
 ;
 N rs,vos1,vos2,vos3,vos4,vos5  N V1 S V1=global S rs=$$vOpen4()
 ;
 F  Q:'$$vFetch4()  D  Q:'isArchivable 
 .	;
 .	N FID
 .	;
 . S FID=rs
 .	;
 . N fidDes S fidDes=$$getPslTbl^UCXDD(rs,0)
 .	;
 .	I ((","_$$getArchiveSubs(fidDes)_",")[(","_ARCHTBL_",")),$$getArchivable(fidDes) S isArchivable=0
 .	Q 
 ;
 Q isArchivable
 ;
getArchiveIncluded(tblDes) ; Table descriptor of table to check
 ;
 N X
 ;
 N dbutarchive S dbutarchive=$G(^UTBL("DBARCHIVE",$P(tblDes,"|",1)))
 ;
 S X=$P(dbutarchive,$C(124),1)
 ;
 Q X
 ;
getArchiveKey(tblDes,forArch) ; Get archive key for archive table
 ;
 N primkeys
 N archkey N i
 N key N table
 ;
 S archkey=0
 ;
 S table=$P(tblDes,"|",1)
 ;
 I (forArch=0) S primkeys=$P(tblDes,"|",3)
 E  D
 .	;
 .	S table=$$getArchiveTable(tblDes)
 .	;
 .	I '(table="") D
 ..		;
 ..		N td S td=$$getPslTbl^UCXDD(table,0)
 ..		;
 ..		S primkeys=$P(td,"|",3)
 ..		Q 
 .	Q 
 ;
 I (table="") Q 0
 ;
 F i=1:1:$S((primkeys=""):0,1:$L(primkeys,",")) D  Q:(archkey>0) 
 .	;
 .	S key=$piece(primkeys,",",i)
 .	;
 .	N colrec S colrec=$$getSchCln^UCXDD(table,key)
 .	;
 .	I ($P(colrec,"|",6)="D") S archkey=i
 .	Q 
 ;
 ; No date key, look for serial
 I (archkey=0) D
 .	;
 .	N rs,vos1,vos2,vos3,vos4,vos5  N V1 S V1=table S rs=$$vOpen5()
 .	;
 .	I $$vFetch5() S archkey=$S((primkeys=""):0,1:$L(primkeys,",")) ; Use bottom key
 . Q 
 ;
 Q archkey
 ;
getArchiveSubs(tblDes) ; Table descriptor of table to check
 ;
 N ArchSubs N tblkeys
 N TBL
 ;
 I ($$getArchiveKey(tblDes,0)=0) Q ""
 ;
 S ArchSubs=""
 ;
 S TBL=$P(tblDes,"|",1)
 ;
 N tbldbtbl1,vop1,vop2,vop3,vop4 S vop1="SYSDEV",vop2=TBL,tbldbtbl1=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",TBL,0,"")
  S vop4=$G(^DBTBL(vop1,1,vop2,16))
  S vop3=$G(^DBTBL(vop1,1,vop2,0))
 ;
 S tblkeys=$P(vop4,$C(124),1)
 ;
 N rs,vos1,vos2,vos3,vos4,vos5  N V1 S V1=$P(vop3,$C(124),1) S rs=$$vOpen6()
 ;
 F  Q:'$$vFetch6()  D
 .	;
 .	N isSubTbl
 .	N psubkeys
 .	N i
 .	N PSUBTBL
 .	;
 . S PSUBTBL=rs
 .	;
 .	N psubdbtbl1,vop5,vop6,vop7 S vop5="SYSDEV",vop6=PSUBTBL,psubdbtbl1=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",PSUBTBL,0,"")
 .	 S vop7=$G(^DBTBL(vop5,1,vop6,16))
 .	;
 .	S psubkeys=$P(vop7,$C(124),1)
 .	;
 .	I ($S((psubkeys=""):0,1:$L(psubkeys,","))>$S((tblkeys=""):0,1:$L(tblkeys,","))) D
 ..		;
 ..		; Check any literal keys
 ..		S isSubTbl=1
 ..		F i=1:1:$S((tblkeys=""):0,1:$L(tblkeys,",")) D  Q:'isSubTbl 
 ...			;
 ...			N P N T
 ...			;
 ...			S P=$piece(psubkeys,",",i)
 ...			S T=$piece(tblkeys,",",i)
 ...			;
 ...			I ($$isLit^UCGM(T)!$$isLit^UCGM(P)),(T'=P) S isSubTbl=0
 ...			Q 
 ..		;
 ..		I isSubTbl S ArchSubs=$S((ArchSubs=""):PSUBTBL,1:ArchSubs_","_PSUBTBL)
 ..		Q 
 . Q 
 ;
 Q ArchSubs
 ;
ARCHTBLCHK(ARCHTBL) ; Archive Table Name
 ;
 N primkeys
 N ERRMSG N tmkey N global
 ;
 S ERRMSG=""
 ;
 ; Only valid with a GT.M database
 I '((%DB="")!(%DB="GTM")) Q $$^MSG(6900)
 ;
 N tblDes S tblDes=$$getPslTbl^UCXDD(ARCHTBL,0)
 ;
 I '($$getQuery^UCXDD(tblDes)="") Q $$^MSG(6892)
 ;
 ; Archivable table cannot be a parent table
 I $$isParent^UCXDD(tblDes) Q $$^MSG(6893)
 ;
 I '$$getArchivable(tblDes) Q $$^MSG(6891)
 ;
 Q ERRMSG
 ;
INCLUDEDCHK(ARCHTBL,INCLUDED) ; List of included with tables
 ;
 N ERR
 N archkeys
 N i
 N archkey N ERRMSG
 ;
 S ERR=0
 S ERRMSG=""
 ;
 N archDes S archDes=$$getPslTbl^UCXDD(ARCHTBL,0)
 ;
 S archkey=$$getArchiveKey(archDes,0)
 S archkeys=$P(archDes,"|",3)
 ;
 F i=1:1:$S((INCLUDED=""):0,1:$L(INCLUDED,",")) D  Q:'(ERRMSG="") 
 .	;
 .	N inclkeys
 .	N TBL
 .	;
 .	S TBL=$piece(INCLUDED,",",i)
 .	;
 .	N inclDes S inclDes=$$getPslTbl^UCXDD(TBL,0)
 .	;
 .	; Archive Table and Included Table must use different globals
 .	I $piece($P(archDes,"|",2),"(",1)=$piece($P(inclDes,"|",2),"(",1) S ERRMSG=$$^MSG(6895) Q 
 .	;
 .	S inclkeys=$P(inclDes,"|",3)
 .	;
 .	I ($S((inclkeys=""):0,1:$L(inclkeys,","))<archkey) S ERR=1
 .	E  F i=1:1:archkey D  Q:ERR 
 ..		;
 ..		N colarch S colarch=$$getSchCln^UCXDD(ARCHTBL,$piece(archkeys,",",i))
 ..		N colincl S colincl=$$getSchCln^UCXDD(TBL,$piece(inclkeys,",",i))
 ..		;
 ..		I ($P(colarch,"|",6)'=$P(colincl,"|",6)) S ERR=1
 ..		E  I ($P(colarch,"|",7)'=$P(colincl,"|",7)) S ERR=1
 ..		Q 
 .	;
 .	; Number, type, and length of keys for ~p1 and ~p2 must match
 .	I ERR S ERRMSG=$$^MSG(6896,TBL,ARCHTBL) Q 
 .	;
 .	N ds,vos1,vos2,vos3,vos4 S ds=$$vOpen7()
 .	;
 .	F  Q:'$$vFetch7()  D  Q:ERR 
 ..		;
 ..  N dbutarchive,vop1 S vop1=ds,dbutarchive=$$vRCgetRecord1Opt^RecordDBUTARCHIVE(vop1,1,"")
 ..		;
 ..		I (TBL=vop1) D
 ...			;
 ...			S ERR=1
 ...			; Included table ~p already entered as ARCHTBL in DBUTARCHIVE
 ...			S ERRMSG=$$^MSG(6897,TBL)
 ...			Q 
 ..		E  I ((","_$P(dbutarchive,$C(124),1)_",")[(","_TBL_",")) D
 ...			;
 ...			S ERR=1
 ...			; Included table ~p already set as included for ~p2
 ...			S ERRMSG=$$^MSG(6898,TBL,vop1)
 ...			Q 
 ..  Q 
 . Q 
 ;
 Q ERRMSG
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61254^68475^Dan Russell^22653" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vRsGetCol(object,column) ; Runtime ResultSet.getCol()
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;
 I (column="") Q ""
 I column Q column
 ;
 N select S select=$piece(vobj(object,-3)," FROM ")
 N pos S pos=$L($piece((","_select_","),","_column_",",1),",")
 Q pos
 ;
vOpen0(exe,vsql,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist,vOff) ; Dynamic MDB ResultSet
 ;
 N vOid
 N ER,vExpr,mode,RM,vOpen,vTok S ER=0 ;=noOpti
 ;
 S vExpr="SELECT "_vSelect_" FROM "_vFrom
 I vWhere'="" S vExpr=vExpr_" WHERE "_vWhere
 I vOrderby'="" S vExpr=vExpr_" ORDER BY "_vOrderby
 I vGroupby'="" S vExpr=vExpr_" GROUP BY "_vGroupby
 S vExpr=$$UNTOK^%ZS($$SQL^%ZS(vExpr,.vTok),vTok)
 ;
 S sqlcur=$O(vobj(""),-1)+1
 ;
 I $$FLT^SQLCACHE(vExpr,vTok,.vParlist)
 E  S vOpen=$$OPEN^SQLM(.exe,vFrom,vSelect,vWhere,vOrderby,vGroupby,vParlist,,1,,sqlcur) I 'ER D SAV^SQLCACHE(vExpr,.vParlist) s vsql=vOpen
 I ER S $ZE="0,"_$ZPOS_",%PSL-E-SQLFAIL,"_$TR($G(RM),$C(10,44),$C(32,126)),$EC=",U1001,"
 ;
 S vOid=sqlcur
 S vobj(vOid,0)=vsql
 S vobj(vOid,-1)="ResultSet"
 S vobj(vOid,-2)="$$vFetch0^"_$T(+0)
 S vobj(vOid,-3)=$$RsSelList^UCDBRT(vSelect)
 S vobj(vOid,-4)=$G(vsql("D"))
 S vobj(vOid,-5)=0
 Q vOid
 ;
vFetch0(vOid) ; MDB dynamic FETCH
 ;
 ; type public String exe(),sqlcur,vd,vi,vsql()
 ;
 I vsql=0 S vobj(vOid)="" Q 0
 S vsql=$$^SQLF(.exe,.vd,.vi,.sqlcur)
 S vobj(vOid)=vd
 S vobj(vOid,0)=vsql
 S vobj(vOid,.1)=$G(vi)
 Q vsql
 ;
vOpen1() ; MAX(ARCHSEQ) FROM DBARCHIST WHERE ARCHTBL=:ARCHTBL
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(ARCHTBL) I vos3="" G vL1a0
 S vos4=""
vL1a4 S vos4=$O(^DBARCHIS(vos3,vos4),1) I vos4="" G vL1a7
 S vos5=$S($G(vos5)="":$S(vos4=vos2:"",1:vos4),vos5<$S(vos4=vos2:"",1:vos4):$S(vos4=vos2:"",1:vos4),1:vos5)
 G vL1a4
vL1a7 I $G(vos5)="" S vd="" G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a7
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rsarchist="" Q 0
 ;
 S rsarchist=$G(vos5)
 S vos1=100
 ;
 Q 1
 ;
vOpen2() ; PID,SUBTYP FROM PROCESSID WHERE PRCTYP='ARCHIVE'
 ;
 ;
 S vos1=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos1=0 Q
vL2a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL2a3 S vos3=$O(^PROCID(vos3),1) I vos3="" G vL2a0
 S vos4=$G(^PROCID(vos3))
 I '($P(vos4,"|",6)="ARCHIVE") G vL2a3
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos1=1 D vL2a3
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos4=$G(^PROCID(vos3))
 S rs=$S(vos3=vos2:"",1:vos3)_$C(9)_$P(vos4,"|",7)
 ;
 Q 1
 ;
vOpen3() ; ARCHTBL FROM DBUTARCHIVE
 ;
 ;
 S vos1=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos1=0 Q
vL3a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL3a3 S vos3=$O(^UTBL("DBARCHIVE",vos3),1) I vos3="" G vL3a0
 Q
 ;
vFetch3() ;
 ;
 ;
 I vos1=1 D vL3a3
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds="" Q 0
 ;
 S ds=$S(vos3=vos2:"",1:vos3)
 ;
 Q 1
 ;
vOpen4() ; FID FROM DBTBL1 WHERE %LIBS='SYSDEV' AND FID<>:ARCHTBL AND GLOBAL=:V1
 ;
 ;
 S vos1=2
 D vL4a1
 Q ""
 ;
vL4a0 S vos1=0 Q
vL4a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(ARCHTBL) I vos3="",'$D(ARCHTBL) G vL4a0
 S vos4=$G(V1) I vos4="",'$D(V1) G vL4a0
 S vos5=""
vL4a5 S vos5=$O(^XDBREF("DBTBL1.GLOBAL","SYSDEV",vos4,vos5),1) I vos5="" G vL4a0
 I '(vos5'=vos3) G vL4a5
 Q
 ;
vFetch4() ;
 ;
 ;
 I vos1=1 D vL4a5
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos5=vos2:"",1:vos5)
 ;
 Q 1
 ;
vOpen5() ; DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1 AND SRL=1
 ;
 ;
 S vos1=2
 D vL5a1
 Q ""
 ;
vL5a0 S vos1=0 Q
vL5a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL5a0
 S vos4=""
vL5a4 S vos4=$O(^DBTBL("SYSDEV",1,vos3,9,vos4),1) I vos4="" G vL5a0
 S vos5=$G(^DBTBL("SYSDEV",1,vos3,9,vos4))
 I '(+$P(vos5,"|",23)=1) G vL5a4
 Q
 ;
vFetch5() ;
 ;
 ;
 I vos1=1 D vL5a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos5=$G(^DBTBL("SYSDEV",1,vos3,9,vos4))
 S rs=$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen6() ; FID FROM DBTBL1 WHERE %LIBS='SYSDEV' AND GLOBAL=:V1 AND FID<>:TBL
 ;
 ;
 S vos1=2
 D vL6a1
 Q ""
 ;
vL6a0 S vos1=0 Q
vL6a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="",'$D(V1) G vL6a0
 S vos4=$G(TBL) I vos4="",'$D(TBL) G vL6a0
 S vos5=""
vL6a5 S vos5=$O(^XDBREF("DBTBL1.GLOBAL","SYSDEV",vos3,vos5),1) I vos5="" G vL6a0
 I '(vos5'=vos4) G vL6a5
 Q
 ;
vFetch6() ;
 ;
 ;
 I vos1=1 D vL6a5
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos5=vos2:"",1:vos5)
 ;
 Q 1
 ;
vOpen7() ; ARCHTBL FROM DBUTARCHIVE WHERE ARCHTBL<>:ARCHTBL
 ;
 ;
 S vos1=2
 D vL7a1
 Q ""
 ;
vL7a0 S vos1=0 Q
vL7a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(ARCHTBL) I vos3="",'$D(ARCHTBL) G vL7a0
 S vos4=""
vL7a4 S vos4=$O(^UTBL("DBARCHIVE",vos4),1) I vos4="" G vL7a0
 I '(vos4'=vos3) G vL7a4
 Q
 ;
vFetch7() ;
 ;
 ;
 I vos1=1 D vL7a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds="" Q 0
 ;
 S ds=$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
