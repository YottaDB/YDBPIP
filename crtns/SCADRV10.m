 ; 
 ; **** Routine compiled from DATA-QWIK Procedure SCADRV10 ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
SCADRV10 ; ;Create/Modify Sub-menus
 D INIT
 Q 
 ;
INIT ; 
 ;
 S %PG=0
 S %PAGE=1
 S %O=0
 D VPG
 Q 
 ;
VPG ; Page control
 ;
 N FINISH
 N FN
 ;
 S FN=""
 ;
 S FINISH=0
 F  D  Q:FINISH 
 .	I %PG=0 D VPG00(.FN) I ER!(VFMQ="Q") S FINISH=1 Q 
 .	I %PG>0 D VPG01(FN)
 .	I "DFQ"[VFMQ D VER(FN) S FINISH=1 Q 
 .	S %PG=%PG+1
 .	Q 
 Q 
 ;
VPG00(FN) ; Set up
 ;
 S %TAB("FN")=".FN1/TBL=[SCATBL]"
 S %READ="@@%FN,,,FN/REQ"
 S %NOPRMT="N"
 ;
 D ^UTLREAD
 I VFMQ="Q" Q 
 ;
 N scatbl S scatbl=$$vRCgetRecord0Opt^RecordSCATBL(FN,0,"")
 S DESC=$P(scatbl,$C(124),1)
 D PPG00(FN)
 Q 
 ;
VPG01(FN) ; Call screen
 ;
 N fSCATBL4 S fSCATBL4=$$vcdmNew^RecordSCATBL4()
  S vobj(fSCATBL4,-3)=FN
 ;
 N vo1 N vo2 N vo3 N vo4 D DRV^USID(%O,"SCATBL4",.fSCATBL4,.vo1,.vo2,.vo3,.vo4) K vobj(+$G(vo1)) K vobj(+$G(vo2)) K vobj(+$G(vo3)) K vobj(+$G(vo4))
 K vobj(+$G(fSCATBL4)) Q 
 ;
PPG00(FN) ; Set up repeat fields
 ;
 N I
 N N
 ;
 S N=""
 S I=1
 N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen1()
 F  Q:'$$vFetch1()  D
 . N scatbl4,vop1 S vop1=$P(rs,$C(9),2),scatbl4=$$vRCgetRecord1Opt^RecordSCATBL4($P(rs,$C(9),1),vop1,1,"")
 .	S N=vop1
 .	S LINK(I)=$TR($P(scatbl4,$C(124),2),"@")
 .	S DSC(I)=$P(scatbl4,$C(124),1)
 .	S I=I+1
 . Q 
 ;
 F I=I:1:15 D
 .	S LINK(I)=""
 .	S DSC(I)=""
 .	Q 
 S %REPEAT=15
 Q 
 ;
ERR ; 
 ;
 S ER=1
 D ^UTLERR
 S VFMQ="Q"
 Q 
 ;
VER(FN) ; 
 ;
 I VFMQ="Q" D END(FN) Q 
 D FILE(FN)
 I ER D ERR
 D END(FN)
 Q 
 ;
FILE(FN) ; File data
 N vTp
 ;
 N L N N N M
 N I
 ;
 N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen2()
 F  Q:'$$vFetch2()  D
 . N scatbl4,vop1 S vop1=$P(rs,$C(9),2),scatbl4=$$vRCgetRecord1Opt^RecordSCATBL4($P(rs,$C(9),1),vop1,1,"")
 .	S OLDARR(vop1)=$P(scatbl4,$C(124),1)_"|"_$P(scatbl4,$C(124),2)
 .	 N V1 S V1=vop1 D vDbDe1()
 . Q 
 ;
 S N=""
 F I=1:1 S N=$order(LINK(N)) Q:N=""  D
 .	I LINK(N)="" Q 
 .	S NEWARR(I)=DSC(N)_"|@"_LINK(N)
 .	Q 
 ;
 S (L,M)=""
 F  S M=$order(OLDARR(M)) Q:M=""  D
 .	S %O=3
 .	S SNAME=OLDARR(M)
 .	D vDbDe2()
 .	Q 
 ;
 F  S L=$order(NEWARR(L)) Q:L=""  D
 .	S %O=0
 .	N fSCATBL4 S fSCATBL4=$$vRCgetRecord1^RecordSCATBL4(FN,L,0)
 .	;
 .  S $P(vobj(fSCATBL4),$C(124),1)=$piece(NEWARR(L),"|",1)
 .  S $P(vobj(fSCATBL4),$C(124),2)=$piece(NEWARR(L),"|",2)
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSCATBL4(fSCATBL4,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(fSCATBL4,-100) S vobj(fSCATBL4,-2)=1 TC:vTp  
 .	K vobj(+$G(fSCATBL4)) Q 
 Q 
 ;
END(FN) ; 
 ;
 I ER Q 
 I '($D(FN)#2) Q 
 ;
 ; Sub-menu for function ~p1 not modified
 I VFMQ="Q" S RM=$$^MSG(2564,FN)
 ;
 ; Sub-menu for function ~p1 modified
 E  S RM=$$^MSG(2563,FN)
 S ER="W"
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60582^20585^SChhabria^4613" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM SCATBL4 WHERE FN='FN' AND SEQ=:V1
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vRec S vRec=$$vRCgetRecord1^RecordSCATBL4("FN",V1,0)
 I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordSCATBL4(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 K vobj(+$G(vRec)) Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe2() ; DELETE FROM SCATBL4 WHERE FN=:FN AND SEQ=:M
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vRec S vRec=$$vRCgetRecord1^RecordSCATBL4(FN,M,0)
 I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordSCATBL4(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 K vobj(+$G(vRec)) Q 
 ;
vOpen1() ; FN,SEQ FROM SCATBL4 WHERE FN=:FN
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(FN) I vos3="" G vL1a0
 S vos4=""
vL1a4 S vos4=$O(^SCATBL(4,vos3,vos4),1) I vos4="" G vL1a0
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
 S rs=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen2() ; FN,SEQ FROM SCATBL4 WHERE FN=:FN
 ;
 ;
 S vos1=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos1=0 Q
vL2a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(FN) I vos3="" G vL2a0
 S vos4=""
vL2a4 S vos4=$O(^SCATBL(4,vos3,vos4),1) I vos4="" G vL2a0
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos1=1 D vL2a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
