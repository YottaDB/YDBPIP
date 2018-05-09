 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSRPT ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSRPT(from,select,where,orderby,rptnam) ; 
 N vTp
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
 .	N dbtbl5q S dbtbl5q=$$vRCgetRecord0^RecordDBTBL5Q("SYSDEV",QRID,0)
 .	;
 .  S vobj(dbtbl5q,-100,"0*")="" S $P(vobj(dbtbl5q),$C(124),1)=$E(rptnam,1,40)
 .	;
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL5Q(dbtbl5q,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbtbl5q,-100) S vobj(dbtbl5q,-2)=1 TC:vTp  
 .	;
 .	D COMPILE^DBSEXEQ(QRID) ; Compile the report
 .	;
 .	D QRPT^URID ; Run the report
 .	;
 .	WRITE $$CLEAR^%TRMVT
 .	;
 .	D vDbDe1()
 .  K ^DBTBL("SYSDEV",6,QRID)
 .	K vobj(+$G(dbtbl5q)) Q 
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60659^41667^Dan Russell^2076" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM DBTBL6F WHERE LIBS='SYSDEV' AND QRID=:QRID
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2 N v3
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen1()
 F  Q:'$$vFetch1()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^DBTBL(v1,6,v2,v3)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ;
vOpen1() ; LIBS,QRID,SEQ FROM DBTBL6F WHERE LIBS='SYSDEV' AND QRID=:QRID
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(QRID) I vos3="" G vL1a0
 S vos4=100
vL1a4 S vos4=$O(^DBTBL("SYSDEV",6,vos3,vos4),1) I vos4="" G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs="SYSDEV"_$C(9)_vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
