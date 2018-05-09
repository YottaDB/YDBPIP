 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSPROT ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSPROT ; 
 ;
 Q  ; No entry from top
 ;
CREATE ; 
 ;
 N rebuild
 ;
 F  Q:'$$SCREEN(0,.rebuild) 
 ;
 I ($D(rebuild)>0) D BUILD0(.rebuild)
 ;
 Q 
 ;
MODIFY ; 
 ;
 N rebuild
 ;
 F  Q:'$$SCREEN(1,.rebuild) 
 ;
 I ($D(rebuild)>0) D BUILD0(.rebuild)
 ;
 Q 
 ;
DELETE ; 
 ;
 N DINAM N FID N GROUP N rebuild
 ;
 F  Q:'$$SCREEN(3,.rebuild,.FID,.DINAM,.GROUP) 
 ;
 I ($D(rebuild)>0) D BUILD0(.rebuild)
 ;
 Q 
 ;
LIST ; 
 ;
 N RID S RID="DBTBL14"
 ;
 D DRV^URID ; Run report
 ;
 Q 
 ;
BUILD ; 
 ;
 D ^DBSPROT3
 ;
 Q 
 ;
BUILDALL ; 
 ;
 N rs,vos1,vos2,vos3 S rs=$$vOpen1()
 ;
 F  Q:'$$vFetch1()  D BUILD^DBSPROT3(rs)
 ;
 Q 
 ;
BUILD0(rebuild) ; List of element to rebuild
 ;
 N FID S FID=""
 ;
 F  S FID=$order(rebuild(FID)) Q:(FID="")  D BUILD^DBSPROT3(FID)
 ;
 Q 
 ;
SCREEN(%O,rebuild,FID,DINAM,GROUP) ; Protection group /NOREQ/MECH=REF:W
 N vTp
 ;
 N %FRAME N %REPEAT N I N OLNTB N PRTOPT
 N %READ N %TAB N DIPROT N GROUPDES N PROTDI N PROTFL N VFMQ N ZMSG1
 ;
 N dbtbl14q
 ;
 S (DINAM,FID,GROUP)=""
 ;
 S %REPEAT=12
 S PRTOPT=%O
 ;
 ; Read Access
 S DIPROT(1)=$$^MSG(6357)
 ; No Access
 S DIPROT(2)=$$^MSG(5186)
 ; ~p1Enter * for record level protection
 S ZMSG1=$$^MSG(5190,"     ")
 ;
 S %TAB("FID")=".FID1/TBL=[DBTBL1]/XPP=D PP1^DBSPROT"
 S %TAB("DINAM")=".ORGDI1/TBL=[DBTBL1D]:QUERY ""[DBTBL1D]FID=<<FID>>"""
 S %TAB("GROUP")=".DQGRP1/TBL=[DBTBL14]:QUERY ""[DBTBL14]FID=<<FID>> AND [DBTBL14]DINAM=<<DINAM>>""/XPP=D PP3^DBSPROT/MIN=1/MAX=99"
 ;
 I (%O=0) S %TAB("DINAM")=%TAB("DINAM")_"/XPP=D PP2^DBSPROT"
 E  D
 .	;
 .	; Create look-up table for modify/delete
 .	;
 .	N rs,vos1,vos2,vos3 S rs=$$vOpen2()
 .	;
 .	F  Q:'$$vFetch2()  D
 ..		;
 ..  N FID S FID=rs
 ..		;
 ..		N dbtbl1 S dbtbl1=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",FID,0,"")
 ..		;
 ..		S PROTFL(FID)=$P(dbtbl1,$C(124),1)
 ..  Q 
 .	;
 .	S %TAB("FID")=%TAB("FID")_"/TBL=PROTFL("
 .	S %TAB("DINAM")=%TAB("DINAM")_"/TBL=PROTDI("
 . Q 
 ;
 S %READ="@@%FN,,FID/REQ,,DINAM/REQ,,GROUP/REQ,"
 S %FRAME=2
 ;
 D ^UTLREAD I (VFMQ="Q") D vKill1("") Q 0 ; Done
 ;
 I ((FID="")!(DINAM="")!(GROUP="")) D vKill1("") Q 0 ; Done
 ;
 ; Record Level Protection
 I (GROUP="*") S GROUPDES=$$^MSG(5188)
 E  S GROUPDES=""
 ;
 N dbtbl14 S dbtbl14=$$vRCgetRecord1^RecordDBTBL14("SYSDEV",FID,DINAM,GROUP,0)
 ;
 F I=1:1:%REPEAT  K vobj(+$G(dbtbl14q(I))) S dbtbl14q(I)=$$vRCgetRecord1^RecordDBTBL14Q("SYSDEV",FID,DINAM,GROUP,I,0)
 ;
 N vo1 N vo2 N vo3 D DRV^USID(%O,"DBTBL14",.dbtbl14q,.dbtbl14,.vo1,.vo2,.vo3) K vobj(+$G(vo1)) K vobj(+$G(vo2)) K vobj(+$G(vo3))
 ;
 I (VFMQ="Q") D vKill1("") K vobj(+$G(dbtbl14)) Q 0 ; Done
 ;
 S rebuild(FID)="" ; Flag to rebuild
 ;
 TS (vobj):transactionid="CS"
 ;
 I (PRTOPT=3) D  ; Delete definition
 .	;
 .	D vDbDe1()
 .	D vDbDe2()
 .	Q 
 ;
 E  D  ; File data
 .	;
 .	N SEQ
 .	;
 .  S $P(vobj(dbtbl14),$C(124),6)=$P($H,",",1)
 .  S $P(vobj(dbtbl14),$C(124),15)=%UID
 .	;
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL14(dbtbl14,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbtbl14,-100) S vobj(dbtbl14,-2)=1 TC:vTp  
 .	;
 .	; Remove old queries first
 .	D vDbDe3()
 .	;
 .	S SEQ=0
 .	F I=1:1:%REPEAT I '($P(vobj(dbtbl14q(I)),$C(124),1)="") D
 ..		;
 ..		S SEQ=SEQ+1
 ..	  S vobj(dbtbl14q(I),-7)=SEQ
 ..		;
 ..	 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL14Q(dbtbl14q(I),"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbtbl14q(I),-100) S vobj(dbtbl14q(I),-2)=1 TC:vTp  
 ..		Q 
 .	;
 .	; Keep a single blank query, at least for report DBTBL14
 .	I (SEQ=0) S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL14Q(dbtbl14q(1),"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbtbl14q(1),-100) S vobj(dbtbl14q(1),-2)=1 TC:vTp  
 .	Q 
 ;
  TC:$TL 
 ;
 D vKill1("") K vobj(+$G(dbtbl14)) Q 1 ; Continue
 ;
PP1 ; FID post processor
 ;
 Q:(X="") 
 ;
 I ($$PGM^UPID(X)="") D  Q 
 .	;
 .	S ER=1
 .	; Set up protection program name first (file definition control page)
 .	S RM=$$^MSG(2506)
 .	Q 
 ;
 ; Setup look-up table
 K PROTDI
 ;
 N rs,vos1,vos2,vos3,vos4,vos5 S rs=$$vOpen3()
 ;
 F  Q:'$$vFetch3()  D
 .	;
 . N DINAM S DINAM=rs
 .	;
 .	; Record Protection
 .	I (DINAM="*") S PROTDI(DINAM)=$$^MSG(5189)
 .	E  D
 ..		;
 ..		N dbtbl1d S dbtbl1d=$$vRCgetRecord0Opt^RecordDBTBL1D("SYSDEV",X,DINAM,0,"")
 ..		;
 ..		S PROTDI(DINAM)=$P(dbtbl1d,$C(124),10)
 ..  Q 
 .	Q 
 ;
 Q 
 ;
PP2 ; DINAM post processor
 ;
 I (X="") D
 .	;
 .	S NI=0
 .	S %NOPRMT="Q"
 .	Q 
 E  I (X="*") D
 .	;
 .	; Record level protection
 .	S RM=$$^MSG(5188)
 .	S I(3)=""
 .	Q 
 ;
 E  I ($D(^DBTBL("SYSDEV",1,FID,9,X))#2) S I(3)=""
 ;
 Q 
 ;
PP3 ; GROUP post processor
 ;
 Q:(X="") 
 Q:(PRTOPT>0) 
 ;
 S I(3)=""
 ;
 Q:'($D(^DBTBL("SYSDEV",14,FID,DINAM,X))#2) 
 ;
 S ER=1
 ; Protection definition already created
 S RM=$$^MSG("2278")
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60257^34885^Dan Russell^5734" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM DBTBL14Q WHERE PLIBS='SYSDEV' AND FID=:FID AND DINAM=:DINAM AND GROUP=:GROUP
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vDs,vos1,vos2,vos3,vos4,vos5,vos6 S vDs=$$vOpen4()
 F  Q:'$$vFetch4()  D
 . N vRec S vRec=$$vRCgetRecord1^RecordDBTBL14Q($P(vDs,$C(9),1),$P(vDs,$C(9),2),$P(vDs,$C(9),3),$P(vDs,$C(9),4),$P(vDs,$C(9),5),1)
 .	S vobj(vRec,-2)=3
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordDBTBL14Q(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	K vobj(+$G(vRec)) Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe2() ; DELETE FROM DBTBL14 WHERE PLIBS='SYSDEV' AND FID=:FID AND DINAM=:DINAM AND GROUP=:GROUP
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vRec S vRec=$$vRCgetRecord1^RecordDBTBL14("SYSDEV",FID,DINAM,GROUP,0)
 I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordDBTBL14(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 K vobj(+$G(vRec)) Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe3() ; DELETE FROM DBTBL14Q WHERE PLIBS='SYSDEV' AND FID=:FID AND DINAM=:DINAM AND GROUP=:GROUP
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vDs,vos1,vos2,vos3,vos4,vos5,vos6 S vDs=$$vOpen5()
 F  Q:'$$vFetch5()  D
 . N vRec S vRec=$$vRCgetRecord1^RecordDBTBL14Q($P(vDs,$C(9),1),$P(vDs,$C(9),2),$P(vDs,$C(9),3),$P(vDs,$C(9),4),$P(vDs,$C(9),5),1)
 .	S vobj(vRec,-2)=3
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordDBTBL14Q(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	K vobj(+$G(vRec)) Q 
  TC:$TL 
 Q 
 ;
vKill1(ex1) ; Delete objects dbtbl14q()
 ;
 N n1 S (n1)=""
 F  S n1=$O(dbtbl14q(n1)) Q:n1=""  K:'((n1=ex1)) vobj(dbtbl14q(n1))
 Q
 ;
vOpen1() ; DISTINCT FID FROM DBTBL14 WHERE PLIBS='SYSDEV'
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL1a3 S vos3=$O(^DBTBL("SYSDEV",14,vos3),1) I vos3="" G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a3
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos3=vos2:"",1:vos3)
 ;
 Q 1
 ;
vOpen2() ; DISTINCT FID FROM DBTBL14 WHERE PLIBS='SYSDEV'
 ;
 ;
 S vos1=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos1=0 Q
vL2a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL2a3 S vos3=$O(^DBTBL("SYSDEV",14,vos3),1) I vos3="" G vL2a0
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
 S rs=$S(vos3=vos2:"",1:vos3)
 ;
 Q 1
 ;
vOpen3() ; DINAM FROM DBTBL14 WHERE PLIBS='SYSDEV' AND FID=:X
 ;
 ;
 S vos1=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos1=0 Q
vL3a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(X) I vos3="" G vL3a0
 S vos4=""
vL3a4 S vos4=$O(^DBTBL("SYSDEV",14,vos3,vos4),1) I vos4="" G vL3a0
 S vos5=""
vL3a6 S vos5=$O(^DBTBL("SYSDEV",14,vos3,vos4,vos5),1) I vos5="" G vL3a4
 Q
 ;
vFetch3() ;
 ;
 ;
 I vos1=1 D vL3a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen4() ; PLIBS,FID,DINAM,GROUP,QUERY FROM DBTBL14Q WHERE PLIBS='SYSDEV' AND FID=:FID AND DINAM=:DINAM AND GROUP=:GROUP
 ;
 ;
 S vos1=2
 D vL4a1
 Q ""
 ;
vL4a0 S vos1=0 Q
vL4a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(FID) I vos3="" G vL4a0
 S vos4=$G(DINAM) I vos4="" G vL4a0
 S vos5=$G(GROUP)
 S vos6=""
vL4a6 S vos6=$O(^DBTBL("SYSDEV",14,vos3,vos4,vos5,vos6),1) I vos6="" G vL4a0
 Q
 ;
vFetch4() ;
 ;
 ;
 I vos1=1 D vL4a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vDs="" Q 0
 ;
 S vDs="SYSDEV"_$C(9)_vos3_$C(9)_vos4_$C(9)_vos5_$C(9)_$S(vos6=vos2:"",1:vos6)
 ;
 Q 1
 ;
vOpen5() ; PLIBS,FID,DINAM,GROUP,QUERY FROM DBTBL14Q WHERE PLIBS='SYSDEV' AND FID=:FID AND DINAM=:DINAM AND GROUP=:GROUP
 ;
 ;
 S vos1=2
 D vL5a1
 Q ""
 ;
vL5a0 S vos1=0 Q
vL5a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(FID) I vos3="" G vL5a0
 S vos4=$G(DINAM) I vos4="" G vL5a0
 S vos5=$G(GROUP)
 S vos6=""
vL5a6 S vos6=$O(^DBTBL("SYSDEV",14,vos3,vos4,vos5,vos6),1) I vos6="" G vL5a0
 Q
 ;
vFetch5() ;
 ;
 ;
 I vos1=1 D vL5a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vDs="" Q 0
 ;
 S vDs="SYSDEV"_$C(9)_vos3_$C(9)_vos4_$C(9)_vos5_$C(9)_$S(vos6=vos2:"",1:vos6)
 ;
 Q 1
