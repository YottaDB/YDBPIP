 ; 
 ; **** Routine compiled from DATA-QWIK Procedure SQLAUDIT ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
 ;  #PACKAGE framework
 ;  #OPTION ResultClass ON
 ;
 ; **********************************************************************
 ; * IMPORTANT NOTE:                                                    *
 ; * According to the rules that apply to PSL compiler upgrades,        *
 ; * the generated M routine associated with this procedure must be     *
 ; * checked into StarTeam and released with the procedure whenever     *
 ; * changes are made to this procedure.                                *
 ; *                                                                    *
 ; * The mrtns version will be used during upgrades and will then be    *
 ; * removed from the mrtns directory.  Therefore, other than in a      *
 ; * development environment, or during an upgrade, an mrtns version of *
 ; * this routine should not exist.                                     *
 ; *                                                                    *
 ; * Keep these comments as single line to ensure they exist in the     *
 ; * generated M code.                                                  *
 ; **********************************************************************
 ;
 Q  ; No access from top
 ;
AUDIT(expr,tok,sqlcnt) ; Rows inserted or updated
 N vTp
 ;
 N operations N TO
 N I
 N funcs N ON N OPTION N tblwhr N UCLS
 ;
 S sqlcnt=0
 ;
 I ($get(tok)="") S expr=$$SQL^%ZS(expr,.tok) Q:ER  ; If called directly
 ;
 S (ON,TO,OPTION)=""
 S operations=$$TOK^SQL(expr,"ON,TO,OPTION")
 I (operations="") D ERROR^SQL("Operations required") Q 
 I ((","_operations_",")[",ALL OPERATIONS,") D
 .	;
 .	I ($S((operations=""):0,1:$L(operations,","))=1) S operations="INSERT,UPDATE,DELETE,SELECT"
 .	E  D ERROR^SQL("ALL OPERATIONS must be the only operation, if used")
 .	Q 
 E  F I=1:1:$S((operations=""):0,1:$L(operations,",")) I '(",INSERT,UPDATE,DELETE,SELECT,"[(","_$piece(operations,",",I)_",")) D ERROR^SQL("Invalid operation "_$piece(operations,",",I)) Q 
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
 F I=1:1:$S((TO=""):0,1:$L(TO,",")) S UCLS=$piece(TO,",",I) I '(UCLS=""),'($D(^SCAU(0,UCLS))#2) D ERROR^SQL($$^MSG(6755,UCLS)) Q 
 Q:ER 
 ;
 I (OPTION="") D ERROR^SQL("OPTION parameter required") Q 
 ;
 I (OPTION="OFF") S OPTION=0
 E  I (OPTION="LOG") S OPTION=1
 E  I (OPTION="LOGRECORDS") S OPTION=2
 E  I (OPTION="LOGDATA") S OPTION=3
 E  D ERROR^SQL("Invalid OPTION value - must be OFF, LOG, LOGRECORDS, or LOGDATA") Q 
 ;
 I ((OPTION=2)!(OPTION=3)),(((","_operations_",")[",INSERT,")!((","_operations_",")[",SELECT,")) D ERROR^SQL("OPTION LOGDATA not valid for INSERT or SELECT") Q 
 ;
 ; Not valid for RDB Table
 I '($E(ON,$L(ON))="*"),$$rdb^UCDBRT(ON) D ERROR^SQL($$^MSG(6762)) Q 
 ;
 F I=1:1:$S((operations=""):0,1:$L(operations,",")) S funcs($piece(operations,",",I))=""
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
 ..		N dbauditdef S dbauditdef=$$vRCgetRecord1^RecordDBAUDITDEF(tbl,UCLS,0)
 ..		;
 ..		I ($D(funcs("INSERT"))#2)  S:'$D(vobj(dbauditdef,-100,"0*","INSERTLOG")) vobj(dbauditdef,-100,"0*","INSERTLOG")="N001"_$P(vobj(dbauditdef),$C(124),1),vobj(dbauditdef,-100,"0*")="" S $P(vobj(dbauditdef),$C(124),1)=OPTION
 ..		I ($D(funcs("UPDATE"))#2)  S:'$D(vobj(dbauditdef,-100,"0*","UPDATELOG")) vobj(dbauditdef,-100,"0*","UPDATELOG")="N002"_$P(vobj(dbauditdef),$C(124),2),vobj(dbauditdef,-100,"0*")="" S $P(vobj(dbauditdef),$C(124),2)=OPTION
 ..		I ($D(funcs("DELETE"))#2)  S:'$D(vobj(dbauditdef,-100,"0*","DELETELOG")) vobj(dbauditdef,-100,"0*","DELETELOG")="N003"_$P(vobj(dbauditdef),$C(124),3),vobj(dbauditdef,-100,"0*")="" S $P(vobj(dbauditdef),$C(124),3)=OPTION
 ..		I ($D(funcs("SELECT"))#2)  S:'$D(vobj(dbauditdef,-100,"0*","SELECTLOG")) vobj(dbauditdef,-100,"0*","SELECTLOG")="N004"_$P(vobj(dbauditdef),$C(124),4),vobj(dbauditdef,-100,"0*")="" S $P(vobj(dbauditdef),$C(124),4)=OPTION
 ..		;
 ..		; If all are now off, delete the row
 ..		I ($P(vobj(dbauditdef),$C(124),1)+$P(vobj(dbauditdef),$C(124),2)+$P(vobj(dbauditdef),$C(124),3)+$P(vobj(dbauditdef),$C(124),4)=0) S vobj(dbauditdef,-2)=3
 ..		;
 ..	 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBAUDITDEF(dbauditdef,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbauditdef,-100) S vobj(dbauditdef,-2)=1 TC:vTp  
 ..		;
 ..		S sqlcnt=sqlcnt+1
 ..		K vobj(+$G(dbauditdef)) Q 
 .	Q 
 ;
 I ER  TRO:$TL>0  K vobj(+$G(rs)) Q 
 ;
  TC:$TL 
 ;
 K vobj(+$G(rs)) Q 
 ;
usingAuditLog() ; 
 ;
 N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen1()
 ;
 I '$G(vos1) Q 0
 ;
 Q 1
 ;
shouldLog(TABLE,operation,option,userclasses,isPositive) ; Returned list is positive list
 ;
 S userclasses=""
 ;
 N isLogged
 N check N publicOpt
 ;
 N publicLog,vop1 S publicLog=$$vRCgetRecord1Opt^RecordDBAUDITDEF(TABLE,"PUBLIC",0,.vop1)
 ;
 ;  #ACCEPT Date=06/01/2008; Pgm=RussellDS; CR=30801; Group=DYNAMIC
 N rs,exe,sqlcur,vd,vi,vsql,vsub S rs=$$vOpen0(.exe,.vsql,$ZCONVERT(operation,"U")_"LOG,USERCLASS","DBAUDITDEF","TABLENAME=:TABLE AND USERCLASS<>'PUBLIC'","","","",1)
 ;
 I (($G(vop1)=0)&'$G(vobj(rs,0))) K vobj(+$G(rs)) Q 0 ; No logging for this table
 ;
 I (operation="insert") S publicOpt=$P(publicLog,$C(124),1)
 E  I (operation="update") S publicOpt=$P(publicLog,$C(124),2)
 E  I (operation="delete") S publicOpt=$P(publicLog,$C(124),3)
 E  S publicOpt=$P(publicLog,$C(124),4)
 ;
 I (option="log") S check=0
 E  I (option="detail") S check=1
 E  S check=2
 ;
 ; Build positive list - those userclasses who will log for this operation/option
 I (publicOpt'>check) D
 .	;
 .	S isPositive=1
 .	;
 .	F  Q:'$$vFetch0(rs)  I ($P(vobj(rs),$C(9),1)>check) S userclasses=$S((userclasses=""):$P(vobj(rs),$C(9),2),1:userclasses_","_$P(vobj(rs),$C(9),2))
 .	;
 .	; Neither public nor any userclasses log for this option
 .	I ($S((userclasses=""):0,1:$L(userclasses,","))=0) S isLogged=0
 .	E  S isLogged=1
 .	Q 
 ; Otherwise, negative list - those userclasses who don't log
 E  D
 .	;
 .	S isPositive=0
 .	;
 .	F  Q:'$$vFetch0(rs)  I ($P(vobj(rs),$C(9),1)'>check) S userclasses=$S((userclasses=""):$P(vobj(rs),$C(9),2),1:userclasses_","_$P(vobj(rs),$C(9),2))
 .	;
 .	; At least public logs, even if no userclasses
 .	S isLogged=1
 .	Q 
 ;
 K vobj(+$G(rs)) Q isLogged
 ;
auditLog(operation,opon,statement,using) ; Using clause
 N vTp
 ;
 N SEQ S SEQ=$O(^DBAUDITLOG($P($H,",",1),$J,""),-1)+1
 ;
 N auditlog S auditlog=$$vcdmNew^RecordDBAUDITLOG() S vobj(auditlog,-3)=$P($H,",",1) S vobj(auditlog,-4)=$J S vobj(auditlog,-5)=SEQ
  S vobj(auditlog,1,1)=""
  S vobj(auditlog,2,1)=""
 ;
  S vobj(auditlog,-100,"0*")="" S $P(vobj(auditlog),$C(124),1)=%UID
  S vobj(auditlog,-100,"0*")="" S $P(vobj(auditlog),$C(124),2)=TLO
  S vobj(auditlog,-100,"0*")="" S $P(vobj(auditlog),$C(124),3)=$P($H,",",2)
  S vobj(auditlog,-100,"0*")="" S $P(vobj(auditlog),$C(124),4)=operation
  S vobj(auditlog,-100,"0*")="" S $P(vobj(auditlog),$C(124),5)=opon
  S vobj(auditlog,-100,"1,1")="" S vobj(auditlog,1,1)=statement
  S vobj(auditlog,-100,"2,1")="" S vobj(auditlog,2,1)=using
 ;
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBAUDITLOG(auditlog,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(auditlog,-100) S vobj(auditlog,-2)=1 TC:vTp  
 ;
 K vobj(+$G(auditlog)) Q SEQ
 ;
auditLogDetail(SEQ,KEYS) ; key(s) as name-value pairs
 N vTp
 ;
 N RECSEQ S RECSEQ=$O(^DBAUDITLOG($P($H,",",1),$J,SEQ,""),-1)+1
 ;
 N auditlogd S auditlogd=$$vcdmNew^RecordDBAUDITLOGD() S vobj(auditlogd,-3)=$P($H,",",1) S vobj(auditlogd,-4)=$J S vobj(auditlogd,-5)=SEQ S vobj(auditlogd,-6)=RECSEQ
 ;
  S vobj(auditlogd,-100,"0*")="" S $P(vobj(auditlogd),$C(124),1)=KEYS
 ;
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBAUDITLOGD(auditlogd,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(auditlogd,-100) S vobj(auditlogd,-2)=1 TC:vTp  
 ;
 K vobj(+$G(auditlogd)) Q RECSEQ
 ;
buildSQL(recobj,del,map,origdata,SQL) ; Corresponding SQL statement(s)
 ;
 N isDelete S isDelete=0
 N isUpdate S isUpdate=0
 N i N obj
 N colInfo N inscols N insvals N n N origvalue N position
 N sfd N table N update N value N where
 ;
 S obj=$G(recobj)
 ;
 S table=$$tableNameOf^PSLClass(vobj(obj,-1))
 ;
 I (vobj(obj,-2)=1) S isUpdate=1
 E  I (vobj(obj,-2)=3) S isDelete=1
 ;
 S where=""
 ;
 ; Build WHERE clause
 I (isUpdate!isDelete) D
 .	;
 .	S n=""
 .	F  S n=$order(map(n)) Q:((n="")!(n'<-1))  D
 ..		;
 ..		I isUpdate S value=origdata(n)
 ..		E  S value=vobj(obj,n)
 ..		I '(value=+value) S value=$S(value'["'":"'"_value_"'",1:$$QADD^%ZS(value,"'"))
 ..		S where=$piece(map(n),":",1)_"="_value_" AND "_where
 ..		Q 
 .	;
 .	I '(where="") S where=" WHERE "_$E(where,1,$L(where)-5)
 .	Q 
 ;
 I isDelete S SQL(1)="DELETE "_table_where Q 
 ;
 S (inscols,insvals,update)=""
 ;
 S n=""
 F  S n=$order(map(n)) Q:(n="")  D
 .	;
 .	N notChanged S notChanged=0
 .	N isBM S isBM=($E(n,$L(n)-2+1,1048575)=",1")
 .	N mapinfo S mapinfo=map(n)
 .	;
 .	; Skip a node if it's not here
 .	I (n=-1),'($D(vobj(obj))#2) Q 
 .	I (n'<0),'isBM,'($D(vobj(obj,n))#2) Q 
 .	;
 .	I isBM D  Q 
 ..		;
 ..		N seq
 ..		N BMnode
 ..		;
 ..		S BMnode=$piece(n,",",1)
 ..		;
 ..		Q:'($D(vobj(obj,BMnode,1))#2)  ; Skip if not here
 ..		;
 ..		S value=vobj(obj,BMnode,1)
 ..		;
 ..		Q:(isUpdate&(value=origdata(n))) 
 ..		;
 ..		S seq=$order(SQL(""),-1)+1
 ..		I (seq=1) S seq=2
 ..		;
 ..		S colInfo=$piece(mapinfo,";",1)
 ..		;
 ..		S SQL(seq)="UPDATE "_table_" SET "_$piece(colInfo,":",1)_"="_$S(value'["'":"'"_value_"'",1:$$QADD^%ZS(value,"'"))_where
 ..		Q 
 .	;
 .	; If UPDATE, skip node if it hasn't changed
 .	I isUpdate D  Q:notChanged 
 ..		;
 ..		I (n=-1),vobj(obj)=origdata(n) S notChanged=1 Q 
 ..		I vobj(obj,n)=origdata(n) S notChanged=1
 ..		Q 
 .	;
 .	F i=1:1:$S((mapinfo=""):0,1:$L(mapinfo,";")) D
 ..		;
 ..		S colInfo=$piece(mapinfo,";",i)
 ..		S position=$piece(colInfo,":",3)
 ..		I (position="") S position=1
 ..		S sfd=$piece(colInfo,":",4)
 ..		;
 ..		I (n<-1) S value=vobj(obj,n) ; Key
 ..		E  I '($piece(sfd,"~",3)="") D  ; Sub-field
 ...			;
 ...			N master
 ...			;
 ...			I (n=-1) S master=$piece(vobj(obj),del,position)
 ...			E  S master=$piece(vobj(obj,n),del,position)
 ...			;
 ...			S value=$$vStrGSUB(master,$piece(sfd,"~",4),$piece(sfd,"~",1),$piece(sfd,"~",2),$piece(sfd,"~",3))
 ...			Q 
 ..		E  I (n=-1) S value=$piece(vobj(obj),del,position) ; Top node
 ..		E  S value=$piece(vobj(obj,n),del,position)
 ..		;
 ..		; If update, only care if value is different
 ..		I isUpdate D
 ...			;
 ...			S origvalue=$piece(origdata(n),del,position)
 ...			;
 ...			; Sub-field
 ...			I '($piece(sfd,"~",3)="") S origvalue=$$vStrGSUB(origvalue,$piece(sfd,"~",4),$piece(sfd,"~",1),$piece(sfd,"~",2),$piece(sfd,"~",3))
 ...			;
 ...			I (value'=origvalue) D
 ....				;
 ....				I '(value=+value) S value=$S(value'["'":"'"_value_"'",1:$$QADD^%ZS(value,"'"))
 ....				S update=update_$piece(colInfo,":",1)_"="_value_","
 ....				Q 
 ...			Q 
 ..		;
 ..		; If INSERT, ignore null values
 ..		E  I '(value="") D
 ...			;
 ...			I '(value=+value) S value=$S(value'["'":"'"_value_"'",1:$$QADD^%ZS(value,"'"))
 ...			;
 ...			S inscols=inscols_$piece(colInfo,":",1)_","
 ...			S insvals=insvals_value_","
 ...			Q 
 ..		Q 
 .	Q 
 ;
 I isUpdate S SQL(1)="UPDATE "_table_" SET "_$E(update,1,$L(update)-1)_where
 ;
 E  S SQL(1)="INSERT INTO "_table_" ("_$E(inscols,1,$L(inscols)-1)_") VALUES ("_$E(insvals,1,$L(insvals)-1)_")"
 ;
 Q 
 ;
BIDATA(CDATE,PID,SEQ,RECSEQ,KEYS) ; DBAUDITLOGD.KEYS
 N vpc
 ;
 N collist
 N return S return=KEYS
 N i
 N column N data N datanodes N node N table N value
 ;
 N auditlog S auditlog=$G(^DBAUDITLOG(CDATE,PID,SEQ))
 ;
 S table=$P(auditlog,$C(124),5)
 ;
 S vpc=(table="") Q:vpc "" ; Invalid entry
 ;
 ; Load the data
 ;  #ACCEPT Date=05/28/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 ;*** Start of code by-passed by compiler
 S data=$G(^DBAUDITLOG(CDATE,PID,SEQ,RECSEQ,"*"))
 N n
 S n=""
 F  S n=$O(^DBAUDITLOG(CDATE,PID,SEQ,RECSEQ,"*",n)) Q:n=""  S datanodes(n)=^(n)
 X "S collist=$$columnList^Record"_table
 ;*** End of code by-passed by compiler ***
 ;
 ; No before image data saved
 I ($D(datanodes)=0) Q ""
 ;
 F i=1:1:$L(collist) D
 .	;
 .	S column=$piece(collist,",",i)
 .	;
 .	N cd S cd=$$getPslCln^UCXDD(table,column)
 .	;
 .	S node=$$getCurNode^UCXDD(cd,0)
 .	;
 .	Q:(node<0)  ; Key
 .	;
 .	; Get sub-field value
 .	I '($P(cd,"|",13)="") D
 ..		;
 ..		N master
 ..		;
 ..		I (node="") S master=$piece(data,$char($P(cd,"|",5)),$P(cd,"|",4))
 ..		E  S master=$piece($get(datanodes(node)),$char($P(cd,"|",5)),$P(cd,"|",4))
 ..		;
 ..		S value=$$vStrGSUB(master,$P(cd,"|",10),$char($P(cd,"|",11)),$char($P(cd,"|",12)),$P(cd,"|",13))
 ..		Q 
 .	E  D
 ..		;
 ..		I (node="") S value=$piece(data,$char($P(cd,"|",5)),$P(cd,"|",4))
 ..		E  S value=$piece($get(datanodes(node)),$char($P(cd,"|",5)),$P(cd,"|",4))
 ..		Q 
 .	;
 .	I '(value=+value) S value=$S(value'["'":"'"_value_"'",1:$$QADD^%ZS(value,"'"))
 .	;
 .	S return=$S((return=""):(column_"="_value),1:return_","_(column_"="_value))
 .	Q 
 ;
 Q return
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61216^57448^Dan Russell^18343" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vStrGSUB(object,tag,del1,del2,pos) ; String.getSub passing Strings
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I (pos="") S pos=1
 I (tag=""),(del1="") Q $E(object,pos)
 I $L(del1)>1 S $ZE="0,"_$ZPOS_","_"%PSL-E-STRGETSUB",$EC=",U1001,"
 I (tag="") Q $piece(object,del1,pos)
 I (del2="") S del2=del1
 I $L(del2)>1 S $ZE="0,"_$ZPOS_","_"%PSL-E-STRGETSUB",$EC=",U1001,"
 I del1=del2,pos>1 S $ZE="0,"_$ZPOS_","_"%PSL-E-STRGETSUB",$EC=",U1001,"
 Q $piece($piece($piece((del1_object),del1_tag_del2,2),del1,1),del2,pos)
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
vOpen1() ; TABLENAME FROM DBAUDITDEF
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL1a3 S vos3=$O(^DBAUDITDEF(vos3),1) I vos3="" G vL1a0
 S vos4=""
vL1a5 S vos4=$O(^DBAUDITDEF(vos3,vos4),1) I vos4="" G vL1a3
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a5
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos3=vos2:"",1:vos3)
 ;
 Q 1
 ;
vCatch1 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 D ERROR^SQL($P(error,",",4))
 ;
 S sqlcnt=0
 D ZX^UCGMR(voxMrk) Q 
