 ; 
 ; **** Routine compiled from DATA-QWIK Procedure SQLGRANT ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
 ;  #PACKAGE framework
 ;  #OPTION ResultClass ON
 ;
 Q  ; No access from top
 ;
GRANT(expr,tok,sqlcnt) ; Rows inserted or updated
 N vTp
 ;
 N privileges N TO
 N I
 N cols N funcs N N N ON N privopt N RESTRICT N tblwhr N WITH N UCLS N vals
 ;
 S sqlcnt=0
 ;
 I ($get(tok)="") S expr=$$SQL^%ZS(expr,.tok) Q:ER  ; If called directly
 ;
 S (ON,RESTRICT,TO,WITH)=""
 S privileges=$$TOK^SQL(expr,"ON,TO,WITH,RESTRICT")
 I (privileges="") D ERROR^SQL("Privileges required") Q 
 I ((","_privileges_",")[",ALL PRIVILEGES,") D
 .	;
 .	I ($S((privileges=""):0,1:$L(privileges,","))=1) S privileges="INSERT,UPDATE,DELETE,SELECT"
 .	E  D ERROR^SQL("ALL PRIVILEGES must be the only privilege, if used")
 .	Q 
 E  F I=1:1:$S((privileges=""):0,1:$L(privileges,",")) I '(",INSERT,UPDATE,DELETE,SELECT,"[(","_$piece(privileges,",",I)_",")) D ERROR^SQL("Invalid privilege "_$piece(privileges,",",I)) Q 
 Q:ER 
 ;
 I (ON="") D ERROR^SQL("ON parameter required") Q 
 I $piece(ON," ",1)="TABLE" S ON=$piece(ON," ",2) I (ON="") D ERROR^SQL("Table name required") Q 
 ; Invalid table name - ~p1
 I '($E(ON,$L(ON))="*"),'($D(^DBTBL("SYSDEV",1,ON))) D ERROR^SQL($$^MSG(1484,ON)) Q 
 ;
 I (TO="") D ERROR^SQL("TO parameter required") Q 
 ;
 ; Invalid userclass ~p1
 I (TO'="PUBLIC") F I=1:1:$S((TO=""):0,1:$L(TO,",")) S UCLS=$piece(TO,",",I) I '(UCLS=""),'($D(^SCAU(0,UCLS))#2) D ERROR^SQL($$^MSG(6755,UCLS)) Q 
 Q:ER 
 ;
 I '(WITH=""),(WITH'="GRANT OPTION") D ERROR^SQL("Invalid WITH GRANT OPTION syntax") Q 
 ;
 ; Not valid for RDB Table
 I '($E(ON,$L(ON))="*"),$$rdb^UCDBRT(ON) D ERROR^SQL($$^MSG(6762)) Q 
 ;
 F I=1:1:$S((privileges=""):0,1:$L(privileges,",")) S funcs($piece(privileges,",",I))=""
 ;
 I (WITH="") S privopt=1
 E  S privopt=2
 ;
 I (ON="*") S tblwhr=""
 E  I ($E(ON,$L(ON))="*") S tblwhr="FID LIKE '"_$E(ON,1,$L(ON)-1)_"%'"
 E  S tblwhr="FID = '"_ON_"'"
 ;
 TS (vobj):transactionid="CS"
 ;
 ;  #ACCEPT Date=01/20/2008; Pgm=RussellDS; CR=30801; Group=Dynamic
 N rs,exe,sqlcur,vd,vi,vsql,vsub S rs=$$vOpen0(.exe,.vsql,"FID","DBTBL1",tblwhr,"FID ASC","","",1)
 ;
 F  Q:'$$vFetch0(rs)  D
 .	;
 .	N tbl S tbl=vobj(rs)
 .	;
 .	Q:$$rdb^UCDBRT(tbl) 
 .	;
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 .	;
 .	F I=1:1:$S((TO=""):0,1:$L(TO,",")) S UCLS=$piece(TO,",",I) I '(UCLS="") D
 ..		;
 ..		N dbaccrts S dbaccrts=$$vRCgetRecord1^RecordDBACCRTS(tbl,UCLS,0)
 ..		 S vobj(dbaccrts,1)=$G(^DBACCRTS(vobj(dbaccrts,-3),vobj(dbaccrts,-4),1))
 ..		 S vobj(dbaccrts,2)=$G(^DBACCRTS(vobj(dbaccrts,-3),vobj(dbaccrts,-4),2))
 ..		 S vobj(dbaccrts,3)=$G(^DBACCRTS(vobj(dbaccrts,-3),vobj(dbaccrts,-4),3))
 ..		 S vobj(dbaccrts,4)=$G(^DBACCRTS(vobj(dbaccrts,-3),vobj(dbaccrts,-4),4))
 ..		;
 ..		I ($D(funcs("INSERT"))#2) D
 ...			;
 ...		  S:'$D(vobj(dbaccrts,-100,"0*","INSERTRTS")) vobj(dbaccrts,-100,"0*","INSERTRTS")="N001"_$P(vobj(dbaccrts),$C(124),1),vobj(dbaccrts,-100,"0*")="" S $P(vobj(dbaccrts),$C(124),1)=privopt
 ...		  S:'$D(vobj(dbaccrts,-100,1,"INSRESTRICT")) vobj(dbaccrts,-100,1,"INSRESTRICT")="T001"_$P(vobj(dbaccrts,1),$C(124),1),vobj(dbaccrts,-100,1)="" S $P(vobj(dbaccrts,1),$C(124),1)=RESTRICT
 ...			Q 
 ..		I ($D(funcs("UPDATE"))#2) D
 ...			;
 ...		  S:'$D(vobj(dbaccrts,-100,"0*","UPDATERTS")) vobj(dbaccrts,-100,"0*","UPDATERTS")="N002"_$P(vobj(dbaccrts),$C(124),2),vobj(dbaccrts,-100,"0*")="" S $P(vobj(dbaccrts),$C(124),2)=privopt
 ...		  S:'$D(vobj(dbaccrts,-100,2,"UPDRESTRICT")) vobj(dbaccrts,-100,2,"UPDRESTRICT")="T001"_$P(vobj(dbaccrts,2),$C(124),1),vobj(dbaccrts,-100,2)="" S $P(vobj(dbaccrts,2),$C(124),1)=RESTRICT
 ...			Q 
 ..		I ($D(funcs("DELETE"))#2) D
 ...			;
 ...		  S:'$D(vobj(dbaccrts,-100,"0*","DELETERTS")) vobj(dbaccrts,-100,"0*","DELETERTS")="N003"_$P(vobj(dbaccrts),$C(124),3),vobj(dbaccrts,-100,"0*")="" S $P(vobj(dbaccrts),$C(124),3)=privopt
 ...		  S:'$D(vobj(dbaccrts,-100,3,"DELRESTRICT")) vobj(dbaccrts,-100,3,"DELRESTRICT")="T001"_$P(vobj(dbaccrts,3),$C(124),1),vobj(dbaccrts,-100,3)="" S $P(vobj(dbaccrts,3),$C(124),1)=RESTRICT
 ...			Q 
 ..		I ($D(funcs("SELECT"))#2) D
 ...			;
 ...		  S:'$D(vobj(dbaccrts,-100,"0*","SELECTRTS")) vobj(dbaccrts,-100,"0*","SELECTRTS")="N004"_$P(vobj(dbaccrts),$C(124),4),vobj(dbaccrts,-100,"0*")="" S $P(vobj(dbaccrts),$C(124),4)=privopt
 ...		  S:'$D(vobj(dbaccrts,-100,4,"SELRESTRICT")) vobj(dbaccrts,-100,4,"SELRESTRICT")="T001"_$P(vobj(dbaccrts,4),$C(124),1),vobj(dbaccrts,-100,4)="" S $P(vobj(dbaccrts,4),$C(124),1)=RESTRICT
 ...			Q 
 ..		;
 ..	 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBACCRTS(dbaccrts,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbaccrts,-100) S vobj(dbaccrts,-2)=1 TC:vTp  
 ..		;
 ..		S sqlcnt=sqlcnt+1
 ..		K vobj(+$G(dbaccrts)) Q 
 .	Q 
 ;
 I ER  TRO:$TL>0  K vobj(+$G(rs)) Q 
 ;
  TC:$TL 
 ;
 K vobj(+$G(rs)) Q 
 ;
REVOKE(expr,tok,sqlcnt) ; Rows deleted
 N vTp
 ;
 N privileges N FOR N FROM
 N isGrantOpt
 N I
 N funcs N N N ON N tblwhr N UCLS
 ;
 S sqlcnt=0
 ;
 I ($get(tok)="") S expr=$$SQL^%ZS(expr,.tok) Q:ER  ; If called directly
 ;
 I ($E(expr,1,17)="GRANT OPTION FOR ") D
 .	;
 .	S isGrantOpt=1
 .	S expr=$piece(expr,"GRANT OPTION FOR ",2,$L(expr))
 .	Q 
 E  S isGrantOpt=0
 ;
 S (FOR,ON,FROM)=""
 S privileges=$$TOK^SQL(expr,"ON,FROM")
 I (privileges="") D ERROR^SQL("Privileges required") Q 
 I ((","_privileges_",")[",ALL PRIVILEGES,") D
 .	;
 .	I ($S((privileges=""):0,1:$L(privileges,","))=1) S privileges="INSERT,UPDATE,DELETE,SELECT"
 .	E  D ERROR^SQL("ALL PRIVILEGES must be the only privilege, if used")
 .	Q 
 E  F I=1:1:$S((privileges=""):0,1:$L(privileges,",")) I '(",INSERT,UPDATE,DELETE,SELECT,"[(","_$piece(privileges,",",I)_",")) D ERROR^SQL("Invalid privilege "_$piece(privileges,",",I)) Q 
 Q:ER 
 ;
 I (ON="") D ERROR^SQL("ON parameter required") Q 
 I $piece(ON," ",1)="TABLE" S ON=$piece(ON," ",2) I (ON="") D ERROR^SQL("Table name required") Q 
 ; Invalid table name - ~p1
 I '($E(ON,$L(ON))="*"),'($D(^DBTBL("SYSDEV",1,ON))) D ERROR^SQL($$^MSG(1484,ON)) Q 
 ;
 I (FROM="") D ERROR^SQL("FROM parameter required") Q 
 ;
 ; Invalid userclass ~p1
 I (FROM'="PUBLIC") F I=1:1:$S((FROM=""):0,1:$L(FROM,",")) S UCLS=$piece(FROM,",",I) I '(UCLS=""),'($D(^SCAU(0,UCLS))#2) D ERROR^SQL($$^MSG(6755,UCLS)) Q 
 Q:ER 
 ;
 ; Not valid for RDB Table
 I '($E(ON,$L(ON))="*"),$$rdb^UCDBRT(ON) D ERROR^SQL($$^MSG(6762)) Q 
 ;
 F I=1:1:$S((privileges=""):0,1:$L(privileges,",")) S funcs($piece(privileges,",",I))=""
 ;
 I (ON="*") S tblwhr=""
 E  I ($E(ON,$L(ON))="*") S tblwhr="FID LIKE '"_$E(ON,1,$L(ON)-1)_"%'"
 E  S tblwhr="FID = '"_ON_"'"
 ;
 TS (vobj):transactionid="CS"
 ;
 ;  #ACCEPT Date=01/20/2008; Pgm=RussellDS; CR=30801; Group=Dynamic
 N rs,exe,sqlcur,vd,vi,vsql,vsub S rs=$$vOpen0(.exe,.vsql,"FID","DBTBL1",tblwhr,"FID ASC","","",1)
 ;
 F  Q:'$$vFetch0(rs)  D
 .	;
 .	N tbl S tbl=vobj(rs)
 .	;
 .	Q:$$rdb^UCDBRT(tbl) 
 .	;
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch2^"_$T(+0)
 .	;
 .	F I=1:1:$S((FROM=""):0,1:$L(FROM,",")) S UCLS=$piece(FROM,",",I) I '(UCLS="") D
 ..		;
 ..		N dbaccrts S dbaccrts=$$vRCgetRecord1^RecordDBACCRTS(tbl,UCLS,0)
 ..		;
 ..		I ($D(funcs("INSERT"))#2) D
 ...			;
 ...			; Revoke right
 ...			I 'isGrantOpt  S:'$D(vobj(dbaccrts,-100,"0*","INSERTRTS")) vobj(dbaccrts,-100,"0*","INSERTRTS")="N001"_$P(vobj(dbaccrts),$C(124),1),vobj(dbaccrts,-100,"0*")="" S $P(vobj(dbaccrts),$C(124),1)=0
 ...			; Or, just revoke GRANT OPTION, if they had it
 ...			E  I ($P(vobj(dbaccrts),$C(124),1)=2)  S:'$D(vobj(dbaccrts,-100,"0*","INSERTRTS")) vobj(dbaccrts,-100,"0*","INSERTRTS")="N001"_$P(vobj(dbaccrts),$C(124),1),vobj(dbaccrts,-100,"0*")="" S $P(vobj(dbaccrts),$C(124),1)=1
 ...			Q 
 ..		I ($D(funcs("UPDATE"))#2) D
 ...			;
 ...			; Revoke right
 ...			I 'isGrantOpt  S:'$D(vobj(dbaccrts,-100,"0*","UPDATERTS")) vobj(dbaccrts,-100,"0*","UPDATERTS")="N002"_$P(vobj(dbaccrts),$C(124),2),vobj(dbaccrts,-100,"0*")="" S $P(vobj(dbaccrts),$C(124),2)=0
 ...			; Or, just revoke GRANT OPTION, if they had it
 ...			E  I ($P(vobj(dbaccrts),$C(124),2)=2)  S:'$D(vobj(dbaccrts,-100,"0*","UPDATERTS")) vobj(dbaccrts,-100,"0*","UPDATERTS")="N002"_$P(vobj(dbaccrts),$C(124),2),vobj(dbaccrts,-100,"0*")="" S $P(vobj(dbaccrts),$C(124),2)=1
 ...			Q 
 ..		I ($D(funcs("DELETE"))#2) D
 ...			;
 ...			; Revoke right
 ...			I 'isGrantOpt  S:'$D(vobj(dbaccrts,-100,"0*","DELETERTS")) vobj(dbaccrts,-100,"0*","DELETERTS")="N003"_$P(vobj(dbaccrts),$C(124),3),vobj(dbaccrts,-100,"0*")="" S $P(vobj(dbaccrts),$C(124),3)=0
 ...			; Or, just revoke GRANT OPTION, if they had it
 ...			E  I ($P(vobj(dbaccrts),$C(124),3)=2)  S:'$D(vobj(dbaccrts,-100,"0*","DELETERTS")) vobj(dbaccrts,-100,"0*","DELETERTS")="N003"_$P(vobj(dbaccrts),$C(124),3),vobj(dbaccrts,-100,"0*")="" S $P(vobj(dbaccrts),$C(124),3)=1
 ...			Q 
 ..		I ($D(funcs("SELECT"))#2) D
 ...			;
 ...			; Revoke right
 ...			I 'isGrantOpt  S:'$D(vobj(dbaccrts,-100,"0*","SELECTRTS")) vobj(dbaccrts,-100,"0*","SELECTRTS")="N004"_$P(vobj(dbaccrts),$C(124),4),vobj(dbaccrts,-100,"0*")="" S $P(vobj(dbaccrts),$C(124),4)=0
 ...			; Or, just revoke GRANT OPTION, if they had it
 ...			E  I ($P(vobj(dbaccrts),$C(124),4)=2)  S:'$D(vobj(dbaccrts,-100,"0*","SELECTRTS")) vobj(dbaccrts,-100,"0*","SELECTRTS")="N004"_$P(vobj(dbaccrts),$C(124),4),vobj(dbaccrts,-100,"0*")="" S $P(vobj(dbaccrts),$C(124),4)=1
 ...			Q 
 ..		;
 ..		I (($P(vobj(dbaccrts),$C(124),1)=0)&($P(vobj(dbaccrts),$C(124),2)=0)&($P(vobj(dbaccrts),$C(124),3)=0)&($P(vobj(dbaccrts),$C(124),4)=0)) D
 ...			;
 ...			 N V1 S V1=tbl D vDbDe1()
 ...			Q 
 ..		E  S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBACCRTS(dbaccrts,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbaccrts,-100) S vobj(dbaccrts,-2)=1 TC:vTp  
 ..		;
 ..		S sqlcnt=sqlcnt+1
 ..		K vobj(+$G(dbaccrts)) Q 
 .	Q 
 ;
 I ER  TRO:$TL>0  K vobj(+$G(rs)) Q 
 ;
  TC:$TL 
 ;
 K vobj(+$G(rs)) Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61332^71489^Dan Russell^8199" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM DBACCRTS WHERE TABLENAME=:V1 AND USERCLASS=:UCLS
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vRec S vRec=$$vRCgetRecord1^RecordDBACCRTS(V1,UCLS,0)
 I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordDBACCRTS(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 K vobj(+$G(vRec)) Q 
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
vCatch2 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 D ERROR^SQL($P(error,",",4))
 ;
 S sqlcnt=0
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch1 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 D ERROR^SQL($P(error,",",4))
 ;
 S sqlcnt=0
 D ZX^UCGMR(voxMrk) Q 
