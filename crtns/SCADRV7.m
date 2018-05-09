 ; 
 ; **** Routine compiled from DATA-QWIK Procedure SCADRV7 ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
SCADRV7 ; Userclass Maintenance
 ;
 Q 
 ;
NEW ; Userclass Creation
 ;
 D INIT(0)
 ;
 Q 
 ;
UPD ; Userclass Maintenance
 ;
 D INIT(1)
 ;
 Q 
 ;
INQ ; Userclass Inquiry
 ;
 D INIT(2)
 ;
 Q 
 ;
DEL ; Userclass Deletion
 ;
 D INIT(3)
 ;
 Q 
 ;
INIT(%O) ; Screen Control
 ;
 N %OSAVE
 N UCLS N VFMQ
 ;
 S %OSAVE=%O
 ;
 D QUERY
 ;
 I "Q"[VFMQ D END Q 
 ;
 N scau0
 ;
 D SCREEN(.scau0)
 ;
 D FILE(.scau0)
 ;
 K vobj(+$G(scau0)) Q 
 ;
QUERY ; Set up query screen for Userclass selection
 ;
 N %NOPRMT N %READ N %TAB
 ;
 S %TAB("UCLS")=".UCLS4/HLP=[SCAU0]UCLS/XPP=D PPUCLS^SCADRV7"
 I %O S %TAB("UCLS")=%TAB("UCLS")_"/TBL=[SCAU0]"
 I %O=2 S %TAB("IO")=$$IO^SCATAB($I)
 ;
 S %READ="@@%FN,,,UCLS/REQ"
 I %O=2 S %READ=%READ_",IO/REQ"
 ;
 S %NOPRMT="N"
 ;
 D ^UTLREAD
 ;
 Q 
 ;
PPUCLS ; UCLS post processor
 ;
 I (X="") Q 
 ;
 I %OSAVE=3 D  Q:ER 
 .	;
 .	N ds,vos1,vos2,vos3 S ds=$$vOpen1()
 .	F  Q:'$$vFetch1()  D  Q:ER 
 ..		;
 ..  N scau S scau=$$vRCgetRecord1Opt^RecordSCAU(ds,1,"")
 ..		;
 ..		; Cannot delete - User ID's are tied to Userclass ~p1
 ..  I $P(scau,$C(124),5)=X D SETERR^DBSEXECU("SCAU0","MSG","8484",X) Q:ER 
 ..  Q 
 . Q 
 ;
 I %OSAVE Q 
 ;
 ; Record already exists
 I ($D(^SCAU(0,X))#2) D SETERR^DBSEXECU("SCAU0","MSG","2327") Q:ER 
 ;
 Q 
 ;
SCREEN(scau0) ; Userclass screen
 ;
  K vobj(+$G(scau0)) S scau0=$$vRCgetRecord1^RecordSCAU0(UCLS,0)
 ;
 I %O=2 D OPEN^SCAIO
 ;
 I ER S VFMQ="Q" Q 
 ;
 N vo1 N vo2 N vo3 N vo4 D DRV^USID(%O,"SCAUSRC",.scau0,.vo1,.vo2,.vo3,.vo4) K vobj(+$G(vo1)) K vobj(+$G(vo2)) K vobj(+$G(vo3)) K vobj(+$G(vo4))
 ;
 Q 
 ;
FILE(scau0) ; File/Delete the Userclass
 N vTp
 ;
 I %O=2!(VFMQ="Q") D END Q 
 ;
 I %O=3 D  Q 
 .	 N V1 S V1=vobj(scau0,-3) D vDbDe1()
 .	D END
 .	Q 
 ;
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSCAU0(scau0,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(scau0,-100) S vobj(scau0,-2)=1 TC:vTp  
 ;
 D END
 ;
 Q 
 ;
END ; Finish up
 ;
 I ER!(%O=2) Q 
 ;
 S UCLS=$get(UCLS)
 S ER="W"
 I VFMQ="Q" D
 .	;
 .	; Userclass ~p1 not created
 .	I %O=0 S RM=$$^MSG(2903,UCLS) Q 
 .	;
 .	; Userclass ~p1 not modified
 .	I %O=1 S RM=$$^MSG(2905,UCLS) Q 
 .	;
 .	; Userclass ~p1 not deleted
 .	I %O=3 S RM=$$^MSG(2904,UCLS) Q 
 .	Q 
 E  D
 .	;
 .	; Userclass ~p1 created
 .	I %O=0 S RM=$$^MSG(4886,UCLS) Q 
 .	;
 .	; Userclass ~p1 modified
 .	I %O=1 S RM=$$^MSG(4887,UCLS)
 .	;
 .	; Userclass ~p1 deleted
 .	I %O=3 S RM=$$^MSG(5431,UCLS) Q 
 .	Q 
 Q 
 ;
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60275^61883^kellytp^3285" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM SCAU0 WHERE UCLS=:V1
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vRec S vRec=$$vRCgetRecord1^RecordSCAU0(V1,0)
 I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordSCAU0(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 K vobj(+$G(vRec)) Q 
 ;
vOpen1() ; UID FROM SCAU
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL1a3 S vos3=$O(^SCAU(1,vos3),1) I vos3="" G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a3
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds="" Q 0
 ;
 S ds=$S(vos3=vos2:"",1:vos3)
 ;
 Q 1
