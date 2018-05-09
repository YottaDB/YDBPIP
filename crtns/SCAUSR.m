 ; 
 ; **** Routine compiled from DATA-QWIK Procedure SCAUSR ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
SCAUSR ; Set up new Employee/User
 ;
 Q 
 ;
NEW ; User Creation
 ;
 D INIT(0)
 Q 
 ;
UPD ; User Modification
 ;
 D INIT(1)
 Q 
 ;
INQ ; User Inquiry
 ;
 D INIT(2)
 Q 
 ;
DEL ; User Deletion
 ;
 ; Function disabled
 D SETERR^DBSEXECU("SCAU","MSG","1129") Q:ER 
 ;
 Q 
 ;
INIT(%O) ; 
 ;
 N CIFNAM N IO N RELCIF N UID N VFMQ
 ;
 D QUERY
 ;
 I VFMQ="Q" Q 
 ;
 N scau
 ;
 D SCREEN(.scau)
 ;
 D VER(.scau)
 ;
 K vobj(+$G(scau)) Q 
 ;
QUERY ; Query for User ID
 ;
 N %READ N %TAB
 ;
 S %TAB("UID")=".UID1/HLP=[SCAU]UID/XPP=D PPUID^SCAUSR"
 I %O S %TAB("UID")=%TAB("UID")_"/TBL=[SCAU]"
 ;
 S %READ="@@%FN,,,UID/REQ"
 ;
 I %O=2 D
 .	S %TAB("IO")=$$IO^SCATAB($I)
 .	S %READ=%READ_",IO"
 .	Q 
 ;
 D ^UTLREAD
 ;
 Q 
 ;
PPUID ; User ID Post-Processor
 ;
 I (X="") Q 
 I %OSAVE Q 
 ;
 S X=$ZCONVERT(X,"U")
 ;
 ; Record already on file
 I ($D(^SCAU(1,X))#2) D SETERR^DBSEXECU("SCAU","ER","RECOF") Q:ER 
 ;
 Q 
 ;
SCREEN(fSCAU) ; Call screen driver
 ;
 N %MODS N %REPEAT
 ;
 S %MODS=1
 S %REPEAT=16
 ;
  K vobj(+$G(fSCAU)) S fSCAU=$$vRCgetRecord1^RecordSCAU(UID,0)
 ;
 I %O D LOADRA
 I %O=2,IO'=$I D OPEN^SCAIO Q:ER 
 ;
 N vo1 N vo2 N vo3 N vo4 D DRV^USID(%O,"SCAUSR1",.fSCAU,.vo1,.vo2,.vo3,.vo4) K vobj(+$G(vo1)) K vobj(+$G(vo2)) K vobj(+$G(vo3)) K vobj(+$G(vo4))
 ;
 Q 
 ;
LOADRA ; Load related account customer #'s and names
 ;
 N I
 ;
 S I=1
 ;
 N rs,vos1,vos2,vos3,vos4,vos5 S rs=$$vOpen1()
 F  Q:'$$vFetch1()  D  Q:I>16 
 . S RELCIF(I)=$P(rs,$C(9),1)
 . S CIFNAM(I)=$P(rs,$C(9),2)
 .	S I=I+1
 .	Q 
 ;
 Q 
 ;
VER(scau) ; Verify screen status and file
 ;
 I %O=2!(%O=4)!(VFMQ="Q") D END Q 
 ;
 D FILE(.scau)
 ;
 D END
 ;
 Q 
 ;
FILE(scau) ; File data
 N vTp
 ;
 N RECIF
 ;
 I (%O=0)!(%O=1) S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSCAU(scau,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(scau,-100) S vobj(scau,-2)=1 TC:vTp  
 ;
 I ER Q 
 ;
 ; Delete any existing SCAUR1 entries
 D vDbDe1()
 ;
 S RECIF=""
 ; Add SCAUR1 entries from the screen
 F  S RECIF=$order(RELCIF(RECIF)) Q:(RECIF="")  D
 .	;
 .	I (RELCIF(RECIF)="") Q 
 .	;
 .	N scaur1 S scaur1=$$vcdmNew^RecordSCAUR1()
 .  S vobj(scaur1,-3)=UID
 .  S vobj(scaur1,-4)=RELCIF(RECIF)
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSCAUR1(scaur1,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(scaur1,-100) S vobj(scaur1,-2)=1 TC:vTp  
 .	K vobj(+$G(scaur1)) Q 
 ;
 Q 
 ;
END ; End of processing
 ;
 I ER!(%O=2)!(%O=4) Q 
 ;
 I VFMQ="Q" D
 .	; User ~p1 not created
 .	I %O=0 S RM=$$^MSG(2873,UID)
 .	;
 .	; User ~p1 not modified
 .	E  I %O=1 S RM=$$^MSG(2875,UID)
 .	Q 
 E  D
 .	; User ~p1 created
 .	I %O=0 S RM=$$^MSG(2868,UID) Q 
 .	;
 .	; User ~p1 modified
 .	E  I %O=1 S RM=$$^MSG(2872,UID) Q 
 .	Q 
 ;
 S ER="W"
 ;
 Q 
 ;
RESET ; Reset user's manual revoke status
 N vTp
 ;
 N %READ N %TAB N UID N VFMQ
 ;
 S %TAB("UID")=".UID1/HLP=[SCAU]UID/TBL=[SCAU]"
 S %READ="@@%FN,,,UID/REQ"
 ;
 D ^UTLREAD
 ;
 I VFMQ="Q" Q 
 ;
 N scau S scau=$$vRCgetRecord0^RecordSCAU(UID,0)
 ;
 ; Only save the SCAU record STATUS isn't already ACTIVE
 I $$STATUS^SCAUCDI($P(vobj(scau),$C(124),5),$P(vobj(scau),$C(124),8),$P(vobj(scau),$C(124),44),$P(vobj(scau),$C(124),43))'=1 D
 .	;
 .  S $P(vobj(scau),$C(124),43)=0
 .  S $P(vobj(scau),$C(124),8)=$P($H,",",1)
 .  S $P(vobj(scau),$C(124),44)=0
 .  S $P(vobj(scau),$C(124),45)=""
 .	;
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSCAU(scau,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(scau,-100) S vobj(scau,-2)=1 TC:vTp  
 .	Q 
 ;
 ; User ~p1 not modified
 I ER S RM=$$^MSG(2875,UID) K vobj(+$G(scau)) Q 
 ;
 ; User ~p1 modified
 E  S RM=$$^MSG(2872,UID)
 ;
 S ER="W"
 ;
 K vobj(+$G(scau)) Q 
 ;
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60604^26252^SSethy^4079" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM SCAUR1 WHERE UID=:UID
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen2()
 F  Q:'$$vFetch2()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^SCAU(1,v1,v2)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ;
vOpen1() ; SCAUR1.RECIF,CIF.NAM FROM SCAUR1,CIF WHERE CIF.ACN=SCAUR1.RECIF AND SCAUR1.UID=:UID
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(UID) I vos3="" G vL1a0
 S vos4=""
vL1a4 S vos4=$O(^SCAU(1,vos3,vos4),1) I vos4="" G vL1a0
 I '($D(^CIF(vos4))#2) G vL1a4
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos5=$G(^CIF(vos4))
 S rs=$S(vos4=vos2:"",1:vos4)_$C(9)_$P(vos5,"|",1)
 ;
 Q 1
 ;
vOpen2() ; UID,RECIF FROM SCAUR1 WHERE UID=:UID
 ;
 ;
 S vos1=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos1=0 Q
vL2a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(UID) I vos3="" G vL2a0
 S vos4=""
vL2a4 S vos4=$O(^SCAU(1,vos3,vos4),1) I vos4="" G vL2a0
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos1=1 D vL2a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
