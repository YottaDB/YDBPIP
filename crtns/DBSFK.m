 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSFK ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSFK ; 
 N vpc,vTp
 ;
 N DELETE
 N OPTION
 N FID N FKEYS N VFMQ
 ;
 S FID=$$FIND^DBSGETID("DBTBL1",0) Q:(FID="") 
 ;
 S DELETE=0
 S FKEYS=" "
 ;
 N fDBTBL1 S fDBTBL1=$$vRCgetRecord0^RecordDBTBL1("SYSDEV",FID,0)
 N fDBTBL1F S fDBTBL1F=$$vcdmNew^RecordDBTBL1F() S vobj(fDBTBL1F,-3)="SYSDEV" S vobj(fDBTBL1F,-4)=FID
 ;
 S OPTION=0
 ;
 ; Avoid warning on mismatch in number of parameters
 ;  #ACCEPT Date=05/17/06;PGM=RussellDS;CR=21340
 N vo1 N vo2 N vo3 D DRV^USID(0,"DBTBL1K",.fDBTBL1F,.fDBTBL1,.vo1,.vo2,.vo3) K vobj(+$G(vo1)) K vobj(+$G(vo2)) K vobj(+$G(vo3)) S vpc=(VFMQ="Q") K:vpc vobj(+$G(fDBTBL1)),vobj(+$G(fDBTBL1F)) Q:vpc 
 ;
 I DELETE D
 .	;
 .	 N V1,V2 S V1=vobj(fDBTBL1F,-4),V2=vobj(fDBTBL1F,-5) D vDbDe1()
 .	;
 .	; ~p1 deleted
 .	S RM=$$^MSG(3028,FKEYS)
 .	Q 
 E  I (OPTION<2) D
 .	;
 .	S vobj(fDBTBL1F,-2)=OPTION
 .	;
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL1F(fDBTBL1F,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(fDBTBL1F,-100) S vobj(fDBTBL1F,-2)=1 TC:vTp  
 .	;
 .	; ~p1 created
 .	S RM=$$^MSG(6712,FKEYS)
 .	Q 
 ;
 ; Rebuild indexes for DBTBL1F
 D ADD^DBSINDXZ("DBTBL1F")
 ;
 K vobj(+$G(fDBTBL1)),vobj(+$G(fDBTBL1F)) Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61161^48265^Dan Russell^1410" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM DBTBL1F WHERE %LIBS='SYSDEV' AND FID=:V1 AND FKEYS=:V2
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vRec S vRec=$$vRCgetRecord1^RecordDBTBL1F("SYSDEV",V1,V2,0)
 I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordDBTBL1F(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 K vobj(+$G(vRec)) Q 
