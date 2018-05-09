 ; 
 ; **** Routine compiled from DATA-QWIK Procedure SCADRV11 ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
SCADRV11 ; Function/MRPC Userclass Authorization
 ;
 Q 
 ;
ADD(LV) ; Add authorization
 ;
 N HDRMSG N OPT
 ;
 S OPT="A"
 ;
 ; The following authorization will be added:
 S HDRMSG=$$^MSG(6271)
 ;
 D INIT
 ;
 Q 
 ;
DEL(LV) ; 
 ;
 N HDRMSG N OPT
 ;
 S OPT="D"
 ;
 ; The following authorization will be deleted:
 S HDRMSG=$$^MSG(6272)
 ;
 D INIT
 ;
 Q 
 ;
INIT ; Initialize query screen
 N vpc
 ;
 N SEC
 N CNT N I N N
 N FNARR N HDG N MSG N OLNTB N PRM1 N PRM2 N %READ N UCLSARR N %UX N VFMQ
 ;
 N scau0 S scau0=$$vRCgetRecord0Opt^RecordSCAU0(%UCLS,0,"")
 N scatbl S scatbl=$$vRCgetRecord0Opt^RecordSCATBL(%FN,0,"")
 ;
 ; Define current user's class as secure (SEC=1) or not secured (SEC=0)
 S SEC=$P(scau0,$C(124),6)
 ;
 ; Function description
 S HDG=$P(scatbl,$C(124),1)
 ;
 D FN S vpc='$D(FNARR) Q:vpc  S vpc=VFMQ="Q" Q:vpc 
 D UCLS S vpc='$D(UCLSARR) Q:vpc 
 ;
 S vpc=VFMQ="Q" Q:vpc 
 ;
 S MSG(1)=PRM1
 S MSG(2)=""
 S CNT=2
 ;
 S N=""
 F  S N=$order(FNARR(N)) Q:(N="")  D MSG(N)
 ;
 S MSG(CNT+1)=""
 S MSG(CNT+2)=PRM2
 S MSG(CNT+3)=""
 S CNT=CNT+3
 ;
 S N=""
 F  S N=$order(UCLSARR(N)) Q:(N="")  D MSG(N)
 ;
 S %READ="@@%FN,,@HDRMSG,"
 ;
 F I=1:1 Q:'$D(MSG(I))  S %READ=%READ_",@MSG("_I_")"
 ;
 K OLNTB
 ;
 S %UX=""
 ;
 D ^UTLREAD Q:ER 
 ;
 D VER
 ;
 Q 
 ;
VER ; Page control
 ;
 I VFMQ'="Q" D FILE
 ;
 D END
 ;
 Q 
 ;
FILE ; File data
 N vTp
 ;
 N LOGIT
 N RPCID
 N FID N FN N SCATBL3 N SCATBL5A N UCLS N UX
 ;
 S FN=""
 S UCLS=""
 ;
 I LV=1 S FID="SCATBL3"
 I LV=5 S FID="SCATBL5A"
 ;
 F  S FN=$order(FNARR(FN)) Q:(FN="")  D
 .	F  S UCLS=$order(UCLSARR(UCLS)) Q:(UCLS="")  D
 ..		;
 ..		S LOGIT=0
 ..		;
 ..		I LV=1,OPT="A" D  ; Add func. auth.
 ...			N scatbl3 S scatbl3=$$vRCgetRecord1^RecordSCATBL3(FN,UCLS,0)
 ...			I $G(vobj(scatbl3,-2))  S $P(vobj(scatbl3),$C(124),1)=1
 ...		 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSCATBL3(scatbl3,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(scatbl3,-100) S vobj(scatbl3,-2)=1 TC:vTp  
 ...			S %O=0
 ...			S SCATBL3=""
 ...			S LOGIT=1
 ...			K vobj(+$G(scatbl3)) Q 
 ..		E  I LV=1,OPT="D" D  ; Delete func. auth.
 ...			I '($D(^SCATBL(1,FN,UCLS))#2) Q 
 ...			I $$SECURE(UCLS) D vDbDe1()
 ...			S %O=3
 ...			S LOGIT=1
 ...			Q 
 ..		E  I LV=5,OPT="A" D  ; Add MRPC auth.
 ...			N scatbl5a S scatbl5a=$$vRCgetRecord1^RecordSCATBL5A(FN,UCLS,0)
 ...			I $G(vobj(scatbl5a,-2)) K vobj(+$G(scatbl5a)) Q 
 ...		 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSCATBL5A(scatbl5a,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(scatbl5a,-100) S vobj(scatbl5a,-2)=1 TC:vTp  
 ...			S %O=0
 ...			S SCATBL5A=""
 ...			S LOGIT=1
 ...			S RPCID=FN
 ...			K vobj(+$G(scatbl5a)) Q 
 ..		E  I LV=5,OPT="D" D  ; Delete MRPC auth.
 ...			I '($D(^SCATBL(5,FN,UCLS))#2) Q 
 ...			I $$SECURE(UCLS) D vDbDe2()
 ...			S %O=3
 ...			S LOGIT=1
 ...			S RPCID=FN
 ...			Q 
 ..		;
 ..		I LOGIT D ^DBSLOG(FID,%O,.UX)
 ..		Q 
 .	Q 
 Q 
 ;
SECURE(UCLS) ; Check for unsecured user deleting a secure userclass
 ;
 I SEC Q 1
 ;
 N scau0 S scau0=$$vRCgetRecord0Opt^RecordSCAU0(UCLS,0,"")
 ;
 I '$P(scau0,$C(124),6) Q 1
 ;
 Q 0
 ;
FN ; Create function input list
 ;
 N FID
 ;
 I LV=1 D
 .	S FID="[SCATBL]"
 .	S PRM1=$$DES^DBSDD("SCATBL.FN")
 .	Q 
 E  D
 .	S FID="[SCATBL5]"
 .	S PRM1=$$DES^DBSDD("SCATBL5.RPCID")
 .	Q 
 ;
 D ^UTLLIST(FID,"FNARR",PRM1,HDG)
 ;
 I 'ER K RM
 ;
 Q 
 ;
UCLS ; Create userclass input list
 ;
 S PRM2=$$DES^DBSDD("SCAU0.UCLS")
 ;
 D ^UTLLIST("[SCAU0]","UCLSARR",PRM2,HDG)
 ;
 I 'ER K RM
 ;
 Q 
 ;
MSG(N) ; Build messages for display
 ;
 I ($L(MSG(CNT))+$L(N))>79 S CNT=CNT+1
 ;
 S MSG(CNT)=$get(MSG(CNT))_N_" "
 ;
 Q 
 ;
ERR ; 
 ;
 S ER=1
 D ^UTLERR
 S VFMQ="Q"
 ;
 Q 
 ;
END ; 
 ;
 Q:ER 
 ;
 ; Authorization not modified
 I VFMQ="Q" S RM=$$^MSG(312)
 ; Authorization modified
 E  S RM=$$^MSG(311)
 ;
 S ER="W"
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60773^54317^Aries Beltran^4825" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM SCATBL3 WHERE FN=:FN AND UCLS=:UCLS
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vRec S vRec=$$vRCgetRecord1^RecordSCATBL3(FN,UCLS,0)
 I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordSCATBL3(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 K vobj(+$G(vRec)) Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe2() ; DELETE FROM SCATBL5A WHERE RPCID=:FN AND UCLS=:UCLS
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vRec S vRec=$$vRCgetRecord1^RecordSCATBL5A(FN,UCLS,0)
 I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordSCATBL5A(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 K vobj(+$G(vRec)) Q 
