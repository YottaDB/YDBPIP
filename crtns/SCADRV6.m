 ; 
 ; **** Routine compiled from DATA-QWIK Procedure SCADRV6 ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
 ;
 Q 
 ;
UPD ; 
 D INIT(1)
 Q 
 ;
INQ ; 
 ;
 D INIT(2)
 Q 
 ;
INIT(%O) ; init variables
 N FINISH S FINISH=0
 N %PG S %PG=0 N %PAGE S %PAGE=10
 N SEC
 ;
 N scau0 S scau0=$$vRCgetRecord0Opt^RecordSCAU0(%UCLS,0,"")
 S SEC=$P(scau0,$C(124),6)
 ;
 N fSCATBL
 N fSCATBL3
 ;
 F  D  Q:FINISH 
 .	I %PG=0 D VPG00(.fSCATBL,.fSCATBL3) I VFMQ="Q" S FINISH=1 Q 
 .	;
 .	I %PG>0 D VPG01(.fSCATBL,.fSCATBL3)
 .	;
 .	I "DFQ"[VFMQ D VER(.fSCATBL3) S FINISH=1 Q 
 .	;
 .	S %PG=%PG+1
 .	Q 
 ;
 D vKill1("") K vobj(+$G(fSCATBL)) Q 
 ;
VPG00(fSCATBL,fSCATBL3) ; 
 ;
 N I
 ;
 S %TAB("FUN")=".FUN1/TBL=[SCATBL]"
 I %O=2 S %TAB("IO")=$$IO^SCATAB($I)
 ;
 S %READ="@@%FN,,,FUN/REQ"
 S %NOPRMT="N"
 I %O=2 S %READ=%READ_",IO/REQ"
 ;
 D ^UTLREAD
 I VFMQ="Q" S ER=1 Q 
 ;
  K vobj(+$G(fSCATBL)) S fSCATBL=$$vRCgetRecord1^RecordSCATBL(FUN,0)
 ;
 S I=0
 ;
 N rs,vos1,vos2,vos3 S rs=$$vOpen1()
 F  Q:'$$vFetch1()  D
 . N scau0,vop1 S vop1=rs,scau0=$$vRCgetRecord1Opt^RecordSCAU0(vop1,1,"")
 . I 'SEC,$P(scau0,$C(124),6) Q 
 .	S I=I+1
 .  K vobj(+$G(fSCATBL3(I))) S fSCATBL3(I)=$$vRCgetRecord1^RecordSCATBL3(FUN,vop1,0)
 . Q 
 ;
 Q 
 ;
VPG01(fSCATBL,fSCATBL3) ; actual authorize info
 ;
 N %MODS
 ;
 I '($D(%REPEAT)#2) S %REPEAT=14
 ;
 S %MODS=((%PG*%REPEAT)-%REPEAT)+1
 ;
 I %O=2 D OPEN^SCAIO I ER S VFMQ="Q" Q 
 ;
 N vo1 N vo2 N vo3 D DRV^USID(%O,"SCADRV6",.fSCATBL,.fSCATBL3,.vo1,.vo2,.vo3) K vobj(+$G(vo1)) K vobj(+$G(vo2)) K vobj(+$G(vo3))
 ;
 I "DFQ"[VFMQ D VER(.fSCATBL3)
 ;
 Q 
 ;
VER(fSCATBL3) ; verify and process
 ;
 I %O=2!(%O=4)!(VFMQ="Q") D VEXIT Q 
 ;
 D FILE(.fSCATBL3)
 ;
 D VEXIT
 Q 
 ;
FILE(fSCATBL3) ; 
 N vTp
 ;
 N I
 ;
 S (I,N)=""
 ;
 F  S I=$order(fSCATBL3(I)) Q:(I="")  D
 .	S N=vobj(fSCATBL3(I),-4)
 .	;
 .	; Check for an unsecured user deleting a secured userclass
 .	N scau0 S scau0=$G(^SCAU(0,N))
 . I 'SEC,$P(scau0,$C(124),6) Q 
 .	;
 .	I ALL  S $P(vobj(fSCATBL3(I)),$C(124),1)=1
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vReSav1(fSCATBL3(I)) K vobj(fSCATBL3(I),-100) S vobj(fSCATBL3(I),-2)=1 TC:vTp  
 . Q 
 ;
 Q 
 ;
VEXIT ; 
 ;
 I ER!(%O=2)!(%O=4) Q 
 ;
 ; Authorization not modified
 I VFMQ="Q" S RM=$$^MSG("312")
 ;
 ; Authorization modified
 E  S RM=$$^MSG("311")
 S ER="W"
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60620^27431^Renga SP^3570" ; Signature - LTD^TIME^USER^SIZE
 ;
vKill1(ex1) ; Delete objects fSCATBL3()
 ;
 N n1 S (n1)=""
 F  S n1=$O(fSCATBL3(n1)) Q:n1=""  K:'((n1=ex1)) vobj(fSCATBL3(n1))
 Q
 ;
vOpen1() ; UCLS FROM SCAU0
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL1a3 S vos3=$O(^SCAU(0,vos3),1) I vos3="" G vL1a0
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
vReSav1(vOid) ; RecordSCATBL3 saveNoFiler(LOG)
 ;
 D ^DBSLOGIT(vOid,vobj(vOid,-2))
 S ^SCATBL(1,vobj(vOid,-3),vobj(vOid,-4))=$$RTBAR^%ZFUNC($G(vobj(vOid)))
 Q
