 ; 
 ; **** Routine compiled from unknown source ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
DBSTBLMB(%O,dbtbl1,KEY) ; C-S-UTBL Table Maintenance Compiled Program
  S:'$D(vobj(dbtbl1,22)) vobj(dbtbl1,22)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),22)),1:"")
 ; Last compiled:  02/24/2010 06:22 PM - pip
 ;
 ; THIS IS A COMPILED ROUTINE.  Compiled by procedure DBSTBLMA
 ;
 ; See DBSTBLMA for argument definitions
 ;
 N ERMSG N SCREEN N TABLE
 ;
 S SCREEN=$P(vobj(dbtbl1,22),$C(124),8)
 S TABLE=vobj(dbtbl1,-4)
 ;
 I TABLE="STBLER" S ERMSG=$$tm1(%O,.KEY,SCREEN)
 E  I TABLE="UTBLACHRT" S ERMSG=$$tm2(%O,.KEY,SCREEN)
 E  I TABLE="UTBLBRCD" S ERMSG=$$tm3(%O,.KEY,SCREEN)
 E  I TABLE="UTBLBSC" S ERMSG=$$tm4(%O,.KEY,SCREEN)
 E  I TABLE="UTBLRSC" S ERMSG=$$tm5(%O,.KEY,SCREEN)
 ;
 Q ERMSG
 ;
tm1(ProcMode,KEY,SCREEN) ; STBLER - Error Table
 N vTp
 ;
 N ER S ER=0
 N ERMSG N RM
 ;
 S (ERMSG,VFMQ)=""
 ;
 N UTBL S UTBL=$$vRCgetRecord1^RecordSTBLER(KEY(1),0)
 ;
 ;  #ACCEPT Date=03/04/07; Pgm=RussellDS; CR=25558; Group=MISMATCH
 N vo1 N vo2 N vo3 N vo4 D DRV^USID(ProcMode,SCREEN,.UTBL,.vo1,.vo2,.vo3,.vo4) K vobj(+$G(vo1)) K vobj(+$G(vo2)) K vobj(+$G(vo3)) K vobj(+$G(vo4))
 I 'ER,(VFMQ'="Q") D
 .	;
 .	I ProcMode<2 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSTBLER(UTBL,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(UTBL,-100) S vobj(UTBL,-2)=1 TC:vTp  
 .	I ProcMode=3  N V1 S V1=KEY(1) D vDbDe1()
 .	Q 
 ;
 I ER S ERMSG=$get(RM)
 ;
 K vobj(+$G(UTBL)) Q ERMSG
 ;
tm2(ProcMode,KEY,SCREEN) ; UTBLACHRT - ACH Routing & Transit Numbers
 N vTp
 ;
 N ER S ER=0
 N ERMSG N RM
 ;
 S (ERMSG,VFMQ)=""
 ;
 N fUTACHRT S fUTACHRT=$$vRCgetRecord1^RecordUTBLACHRT(KEY(1),0)
 ;
 ;  #ACCEPT Date=03/04/07; Pgm=RussellDS; CR=25558; Group=MISMATCH
 N vo5 N vo6 N vo7 N vo8 D DRV^USID(ProcMode,SCREEN,.fUTACHRT,.vo5,.vo6,.vo7,.vo8) K vobj(+$G(vo5)) K vobj(+$G(vo6)) K vobj(+$G(vo7)) K vobj(+$G(vo8))
 I 'ER,(VFMQ'="Q") D
 .	;
 .	I ProcMode<2 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordUTBLACHRT(fUTACHRT,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(fUTACHRT,-100) S vobj(fUTACHRT,-2)=1 TC:vTp  
 .	I ProcMode=3  N V1 S V1=KEY(1) D vDbDe2()
 .	Q 
 ;
 I ER S ERMSG=$get(RM)
 ;
 K vobj(+$G(fUTACHRT)) Q ERMSG
 ;
tm3(ProcMode,KEY,SCREEN) ; UTBLBRCD - Branch Codes User Table
 N vTp
 ;
 N ER S ER=0
 N ERMSG N RM
 ;
 S (ERMSG,VFMQ)=""
 ;
 N fUTBRCD S fUTBRCD=$$vRCgetRecord1^RecordUTBLBRCD(KEY(1),0)
 ;
 ;  #ACCEPT Date=03/04/07; Pgm=RussellDS; CR=25558; Group=MISMATCH
 N vo9 N vo10 N vo11 N vo12 D DRV^USID(ProcMode,SCREEN,.fUTBRCD,.vo9,.vo10,.vo11,.vo12) K vobj(+$G(vo9)) K vobj(+$G(vo10)) K vobj(+$G(vo11)) K vobj(+$G(vo12))
 I 'ER,(VFMQ'="Q") D
 .	;
 .	I ProcMode<2 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordUTBLBRCD(fUTBRCD,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(fUTBRCD,-100) S vobj(fUTBRCD,-2)=1 TC:vTp  
 .	I ProcMode=3  N V1 S V1=KEY(1) D vDbDe3()
 .	Q 
 ;
 I ER S ERMSG=$get(RM)
 ;
 K vobj(+$G(fUTBRCD)) Q ERMSG
 ;
tm4(ProcMode,KEY,SCREEN) ; UTBLBSC - Branch Set Code
 N vTp
 ;
 N ER S ER=0
 N ERMSG N RM
 ;
 S (ERMSG,VFMQ)=""
 ;
 N UTBL S UTBL=$$vRCgetRecord1^RecordUTBLBSC(KEY(1),0)
 ;
 ;  #ACCEPT Date=03/04/07; Pgm=RussellDS; CR=25558; Group=MISMATCH
 N vo13 N vo14 N vo15 N vo16 D DRV^USID(ProcMode,SCREEN,.UTBL,.vo13,.vo14,.vo15,.vo16) K vobj(+$G(vo13)) K vobj(+$G(vo14)) K vobj(+$G(vo15)) K vobj(+$G(vo16))
 I 'ER,(VFMQ'="Q") D
 .	;
 .	I ProcMode<2 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordUTBLBSC(UTBL,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(UTBL,-100) S vobj(UTBL,-2)=1 TC:vTp  
 .	I ProcMode=3  N V1 S V1=KEY(1) D vDbDe4()
 .	Q 
 ;
 I ER S ERMSG=$get(RM)
 ;
 K vobj(+$G(UTBL)) Q ERMSG
 ;
tm5(ProcMode,KEY,SCREEN) ; UTBLRSC - Region Set Code
 N vTp
 ;
 N ER S ER=0
 N ERMSG N RM
 ;
 S (ERMSG,VFMQ)=""
 ;
 N UTBL S UTBL=$$vRCgetRecord1^RecordUTBLRSC(KEY(1),0)
 ;
 ;  #ACCEPT Date=03/04/07; Pgm=RussellDS; CR=25558; Group=MISMATCH
 N vo17 N vo18 N vo19 N vo20 D DRV^USID(ProcMode,SCREEN,.UTBL,.vo17,.vo18,.vo19,.vo20) K vobj(+$G(vo17)) K vobj(+$G(vo18)) K vobj(+$G(vo19)) K vobj(+$G(vo20))
 I 'ER,(VFMQ'="Q") D
 .	;
 .	I ProcMode<2 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordUTBLRSC(UTBL,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(UTBL,-100) S vobj(UTBL,-2)=1 TC:vTp  
 .	I ProcMode=3  N V1 S V1=KEY(1) D vDbDe5()
 .	Q 
 ;
 I ER S ERMSG=$get(RM)
 ;
 K vobj(+$G(UTBL)) Q ERMSG
 ;
LOWERLVL(fid,KEY) ; Check tables at lower level
 N RETURN S RETURN=0
 ;
 I fid="STBLCNTRY" S RETURN=$$LL1(.KEY)
 E  I fid="UTBLNBD" S RETURN=$$LL2(.KEY)
 E  I fid="UTBLPRODRL" S RETURN=$$LL3(.KEY)
 E  I fid="UTBLPRODRT" S RETURN=$$LL4(.KEY)
 ;
 Q RETURN
 ;
LLSELECT(SELECT,FROM,WHERE) ; 
 ;
 ;  #ACCEPT Date=09/21/04; PGM=Dan Russell; CR=unknown
 N rs,vos1,vos2,sqlcur,exe,sqlcur,vd,vi,vsql,vsub S rs=$$vOpen0(.exe,.vsql,SELECT,FROM,WHERE,"","","",1)
 ;
 I $$vFetch0() Q 1
 ;
 Q 0
 ;
LL1(KEY) ; STBLCNTRY
 ;
 N KEY1 S KEY1=KEY(1)
 I $$LLSELECT("STBLCNTRY1.CNTRY","STBLCNTRY1","STBLCNTRY1.CNTRY = :KEY1") Q 1
 ;
 Q 0
 ;
LL2(KEY) ; UTBLNBD
 ;
 N KEY1 S KEY1=KEY(1)
 I $$LLSELECT("UTBLNBD1.NBDC","UTBLNBD1","UTBLNBD1.NBDC = :KEY1") Q 1
 ;
 Q 0
 ;
LL3(KEY) ; UTBLPRODRL
 ;
 N KEY1 S KEY1=KEY(1)
 I $$LLSELECT("UTBLPRODRLDT.RULEID","UTBLPRODRLDT","UTBLPRODRLDT.RULEID = :KEY1") Q 1
 ;
 Q 0
 ;
LL4(KEY) ; UTBLPRODRT
 ;
 N KEY1 S KEY1=KEY(1)
 N KEY2 S KEY2=KEY(2)
 I $$LLSELECT("UTBLPRODRTDT.COLNAME,UTBLPRODRTDT.RESULTSID","UTBLPRODRTDT","UTBLPRODRTDT.COLNAME = :KEY1 AND UTBLPRODRTDT.RESULTSID = :KEY2") Q 1
 ;
 Q 0
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM STBLER WHERE KEY = :V1
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vRec S vRec=$$vRCgetRecord1^RecordSTBLER(V1,0)
 I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordSTBLER(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 K vobj(+$G(vRec)) Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe2() ; DELETE FROM UTBLACHRT WHERE KEY = :V1
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vRec S vRec=$$vRCgetRecord1^RecordUTBLACHRT(V1,0)
 I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordUTBLACHRT(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 K vobj(+$G(vRec)) Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe3() ; DELETE FROM UTBLBRCD WHERE BRCD = :V1
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vRec S vRec=$$vRCgetRecord1^RecordUTBLBRCD(V1,0)
 I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordUTBLBRCD(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 K vobj(+$G(vRec)) Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe4() ; DELETE FROM UTBLBSC WHERE KEY = :V1
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vRec S vRec=$$vRCgetRecord1^RecordUTBLBSC(V1,0)
 I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordUTBLBSC(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 K vobj(+$G(vRec)) Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe5() ; DELETE FROM UTBLRSC WHERE KEY = :V1
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vRec S vRec=$$vRCgetRecord1^RecordUTBLRSC(V1,0)
 I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordUTBLRSC(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 K vobj(+$G(vRec)) Q 
 ;
vOpen0(exe,vsql,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist,vOff) ; Dynamic MDB ResultSet
 ;
 set sqlcur="LLSELECT.rs"
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
 S vos1=vsql
 Q ""
 ;
vFetch0() ; MDB dynamic FETCH
 ;
 ; type public String exe(),sqlcur,vd,vi,vsql()
 ;
 I vsql=0 S rs="" Q 0
 S vsql=$$^SQLF(.exe,.vd,.vi,.sqlcur)
 S rs=vd
 S vos1=vsql
 S vos2=$G(vi)
 Q vsql
