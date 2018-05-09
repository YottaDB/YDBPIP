DBSRPT(from,select,where,orderby,rptnam)	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSRPT ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	N ER S ER=0
	N expr N QRID N RM
	;
	S expr="SELECT "_select_" FROM "_from
	I '($get(where)="") S expr=expr_" WHERE "_where
	I '($get(orderby)="") S expr=expr_"ORDER BY "_orderby
	;
	; Generate QWIK report
	S QRID="TMP"_$J
	D SQLRW^DBSRWQR(expr,QRID,6)
	;
	I ER D
	.	;
	.	I (RM="") S RM=$$^MSG(979) ; Error
	.	;
	.	WRITE $$MSG^%TRMVT(RM,"",1)
	.	Q 
	;
	E  D
	.	;
	.	N dbtbl5q S dbtbl5q=$$vDb1("SYSDEV",QRID)
	.	;
	. S vobj(dbtbl5q,-100,"0*")="",$P(vobj(dbtbl5q),$C(124),1)=$E(rptnam,1,40)
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBTBL5QL(dbtbl5q,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(dbtbl5q,-100) S vobj(dbtbl5q,-2)=1 Tcommit:vTp  
	.	;
	.	D COMPILE^DBSEXEQ(QRID) ; Compile the report
	.	;
	.	D QRPT^URID ; Run the report
	.	;
	.	WRITE $$CLEAR^%TRMVT
	.	;
	.	D vDbDe1()
	. K ^DBTBL("SYSDEV",6,QRID)
	.	K vobj(+$G(dbtbl5q)) Q 
	;
	Q 
	;
vSIG()	;
	Q "60659^41667^Dan Russell^1988" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM DBTBL6F WHERE LIBS='SYSDEV' AND QRID=:QRID
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen1()
	F  Q:'($$vFetch1())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^DBTBL(v1,6,v2,v3)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(DBTBL5Q,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL5Q"
	S vobj(vOid)=$G(^DBTBL(v1,6,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,6,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL5Q" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vOpen1()	;	LIBS,QRID,SEQ FROM DBTBL6F WHERE LIBS='SYSDEV' AND QRID=:QRID
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(QRID) I vos2="" G vL1a0
	S vos3=100
vL1a3	S vos3=$O(^DBTBL("SYSDEV",6,vos2,vos3),1) I vos3="" G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
