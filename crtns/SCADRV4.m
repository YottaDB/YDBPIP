 ; 
 ; **** Routine compiled from DATA-QWIK Procedure SCADRV4 ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
SCADRV4 ; ;Function maintenance
 ;
NEW ; 
 ;
 D INIT(0)
 Q 
 ;
UPD ; 
 ;
 D INIT(1)
 Q 
 ;
INQ ; 
 ;
 D INIT(2)
 Q 
 ;
DEL ; 
 ;
 D INIT(3)
 Q 
 ;
INIT(%O) ; 
 ;
 N OLNTB,VFMQ
 S %PG=0
 S %PAGE=1
 I %O<2,$get(%IPMODE)'["NOINT" S %PAGE=2
 K FN
 N fSCATBL
 D VPG(.fSCATBL)
 K vobj(+$G(fSCATBL)) Q 
 ;
VPG(fSCATBL) ; Page control
 ;
 N FINISH
 S FINISH=0
 F  D  Q:FINISH 
 .	I %PG=0 D VPG00 I ER S FINISH=1 Q 
 .	I %PG=1 D VPG01(.fSCATBL) I "DFQ"[VFMQ D VER(.fSCATBL) S FINISH=1 Q 
 .	I %PG=2,$get(%IPMODE)'["NOINT" D VPG02(.fSCATBL) I ER S FINISH=1 Q 
 .	I "DFQ"[VFMQ D VER(.fSCATBL) S FINISH=1 Q 
 .	S %PG=%PG+1
 .	Q 
 Q 
 ;
VPG00 ; Set up
 ;
 S %TAB("FN")=".FN2/TBL=[SCATBL]/XPP=D PPFUN^SCADRV4"
 I %O=2 S %TAB("IO")=$$IO^SCATAB($I)
 ;
 S %READ="@@%FN,,,FN/REQ" S %NOPRMT="N"
 I %O=2 S %READ=%READ_",IO/REQ"
 ;
 D ^UTLREAD
 ;
 I VFMQ="Q" S ER=1
 Q 
 ;
PPFUN ; UID post processor
 ;
 I '%OSAVE S I(3)=""
 ;
 I '%OSAVE,X'="",($D(^SCATBL(1,X))#2) S ET="RECOF" D ERR Q 
 I %OSAVE=3 D DELCHK
 I ER Q 
 ;
 ; SCA can modify anything
 I %UCLS="SCA" Q 
 ;
 ; Z's can be modified
 I $E(X,1)="Z" Q 
 ;
 ; Inquiry OK
 I %OSAVE=2 Q 
 ;
 ; Userclass ~p1 must use function name starting with ""Z""
 S ER=1
 S RM=$$^MSG(2897,%UCLS)
 Q 
 ;
DELCHK ; Ensure cannot delete if linked in a menu or sub-menu
 ;
 S (N,M)=""
 S ER=0
 ;
 N rs,vos1,vos2,vos3,vos4,vos5 S rs=$$vOpen1()
 F  Q:'$$vFetch1()  D
 . N scamenu,vop1,vop2 S vop2=$P(rs,$C(9),1),vop1=$P(rs,$C(9),2),scamenu=$$vRCgetRecord1Opt^RecordSCAMENU(vop2,vop1,1,"")
 .	S N=vop2
 . I N="" Q 
 .	S M=vop1
 . I M="" Q 
 . I $P(scamenu,$C(124),2)=X S ER=1 S RM=$$^MSG(1134,N) Q 
 . Q 
 I ER Q 
 ;
 N rs,vos6,vos7,vos8,vos9,vos10 S rs=$$vOpen2()
 F  Q:'$$vFetch2()  D
 . N scatbl4,vop3,vop4 S vop4=$P(rs,$C(9),1),vop3=$P(rs,$C(9),2),scatbl4=$$vRCgetRecord1Opt^RecordSCATBL4(vop4,vop3,1,"")
 .	S N=vop4
 . I N="" Q 
 .	S M=vop3
 . I M="" Q 
 .	;
 .	; Function is linked on a sub-menu for function ~p1
 . I $TR($P(scatbl4,$C(124),2),"@")=X S ER=1 S RM=$$^MSG(1133,N) Q 
 . Q 
 Q 
 ;
VPG01(fSCATBL) ; Function screen
 ;
  K vobj(+$G(fSCATBL)) S fSCATBL=$$vRCgetRecord1^RecordSCATBL(FN,0)
 I %O=2,IO'=$I D OPEN^SCAIO I ER S VFMQ="Q" Q 
 ;
 N vo1 N vo2 N vo3 N vo4 D DRV^USID(%O,"SCATBL",.fSCATBL,.vo1,.vo2,.vo3,.vo4) K vobj(+$G(vo1)) K vobj(+$G(vo2)) K vobj(+$G(vo3)) K vobj(+$G(vo4))
 ;
 Q 
 ;
VPG02(fSCATBL) ; Documentation screen
 ;
 S %OSAV=%O
 S %SN="FUNDOC"
 S PG=FN
 K DOC
 S N=""
 ;
 N rs,vos1,vos2,vos3,vos4,vos5 S rs=$$vOpen3()
 F  Q:'$$vFetch3()  D
 . N scatbld S scatbld=$$vRCgetRecord1^RecordSCATBLDOC($P(rs,$C(9),1),$P(rs,$C(9),2),1)
 .	S DOC(vobj(scatbld,-4))=$P(vobj(scatbld),$C(124),1)
 .	K vobj(+$G(scatbld)) Q 
 ;
 ; Turn I18N checking off, phrases OK (I18N=OFF)
 I '$D(DOC) D
 .	S DOC(1)="Function Name:  "_FN
 .	;
 .	; Function Description
 .	S DOC(2)="  Description:  "_$P(vobj(fSCATBL),$C(124),1)
 .	;
 .	; Program Name
 .	S DOC(3)="      Routine:  "_$P(vobj(fSCATBL),$C(124),4)
 .	S DOC(4)=" "
 .	Q 
 ;
 ; Turn I18N checking back on (I18N=ON)
 S (END,DX,FPF,OVFL,LM,OPT,REGION)=0
 S ARM=71
 S SRM=80
 S PIO=$I
 S %TB=$char(9)
 S JOB=$J
 S (DTAB,MR)=5
 ;
 ; Function Documentation
 D ^DBSWRITE("DOC",3,22,99999,"",$$^MSG(3248))
 ;
 S %O=%OSAV
 Q 
 ;
VER(fSCATBL) ; 
 ;
 I %O=2!(%O=4)!(VFMQ="Q") D END Q 
 ;
 D FILE(.fSCATBL)
 ;
 D END
 ;
 Q 
 ;
FILE(fSCATBL) ; 
 N vTp
 ;
 N option,seq,TEMP,user
 ;
 S option=%O
 S (user,seq)=""
 ;
 I VFMQ="F",$D(DOC) D
 .	;
 .	D vDbDe1()
 .	;
 .	S X1=""
 .	F I=1:1 D  Q:X1="" 
 ..		S X1=$order(DOC(X1))
 ..		I X1="" Q 
 ..		N scatbld S scatbld=$$vRCgetRecord1^RecordSCATBLDOC(FN,X1,0)
 ..	  S $P(vobj(scatbld),$C(124),1)=DOC(X1)
 ..	 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vReSav1(scatbld) S vobj(scatbld,-2)=1 TC:vTp  
 ..		K vobj(+$G(scatbld)) Q 
 .	Q 
 ;
 S %O=option
 K X
 ;
 I %O'=3 D
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSCATBL(fSCATBL,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(fSCATBL,-100) S vobj(fSCATBL,-2)=1 TC:vTp  
 .	N scatbl3 S scatbl3=$$vRCgetRecord1^RecordSCATBL3(FN,"SCA",0)
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vReSav2(scatbl3) S vobj(scatbl3,-2)=1 TC:vTp  
 .	K vobj(+$G(scatbl3)) N scatbl3 S scatbl3=$$vRCgetRecord1^RecordSCATBL3(FN,%UCLS,0)
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vReSav2(scatbl3) S vobj(scatbl3,-2)=1 TC:vTp  
 .	K vobj(+$G(scatbl3)) Q 
 E  I VFMQ="D" D
 .	D vDbDe2()
 .	D vDbDe3()
 .	Q 
 ;
END ; 
 ;
 I ER!(%O=2)!(%O=4) Q 
 ;
 I VFMQ="Q" D
 .	;
 .	; Function ~p1 not created
 .	I %O=0 S RM=$$^MSG(1148,FN) Q 
 .	;
 .	; Function ~p1 not modified
 .	I %O=1 S RM=$$^MSG(1150,FN) Q 
 .	;
 .	; Function ~p1 not deleted
 .	S RM=$$^MSG(1149,FN)
 .	Q 
 E  D
 .	;
 .	; Function ~p1 created
 .	I %O=0 S RM=$$^MSG(1144,FN) Q 
 .	;
 .	; Function ~p1 modified
 .	I %O=1 S RM=$$^MSG(1147,FN) Q 
 .	;
 .	; Function ~p1 deleted
 .	S RM=$$^MSG(1145,FN)
 .	Q 
 S ER="W"
 Q 
 ;
PROG ; Check validity of program name
 ;
 N Z
 I X="" Q 
 S Z=X
 ;
 ; Program name must contain the ^ symbol
 I Z'["^" D  Q 
 .	S ER=1
 .	S RM=$$^MSG(2273)
 .	Q 
 ;
 ; Strip off parameter passing
 S Z=$piece(Z,"(",1)
 ;
 ; Program ~p1 does not exist
 I '$$VALID^%ZRTNS($piece(Z,"^",2)) D
 .	S ER=1
 .	S RM=$$^MSG(2275,Z)
 .	Q 
 Q 
 ;
ERR ; 
 ;
 S ER=1
 ;
 D ^UTLERR
 S VFMQ="Q"
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "59553^73403^Dan Russell^5290" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM SCATBLDOC WHERE FN=:FN
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vDs,vos1,vos2,vos3,vos4 S vDs=$$vOpen4()
 F  Q:'$$vFetch4()  D
 . N vRec S vRec=$$vRCgetRecord1^RecordSCATBLDOC($P(vDs,$C(9),1),$P(vDs,$C(9),2),1)
 .	S vobj(vRec,-2)=3
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordSCATBLDOC(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	K vobj(+$G(vRec)) Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe2() ; DELETE FROM SCATBL WHERE FN=:FN
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vRec S vRec=$$vRCgetRecord1^RecordSCATBL(FN,0)
 I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordSCATBL(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 K vobj(+$G(vRec)) Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe3() ; DELETE FROM SCATBLDOC WHERE FN=:FN
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vDs,vos1,vos2,vos3,vos4 S vDs=$$vOpen5()
 F  Q:'$$vFetch5()  D
 . N vRec S vRec=$$vRCgetRecord1^RecordSCATBLDOC($P(vDs,$C(9),1),$P(vDs,$C(9),2),1)
 .	S vobj(vRec,-2)=3
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordSCATBLDOC(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	K vobj(+$G(vRec)) Q 
  TC:$TL 
 Q 
 ;
vOpen1() ; MNUMB,SNUMB FROM SCAMENU WHERE MNUMB>:N
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(N)
 S vos4=vos3
vL1a4 S vos4=$O(^SCATBL(0,vos4),1) I vos4="" G vL1a0
 S vos5=""
vL1a6 S vos5=$O(^SCATBL(0,vos4,vos5),1) I vos5="" G vL1a4
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos4=vos2:"",1:vos4)_$C(9)_$S(vos5=vos2:"",1:vos5)
 ;
 Q 1
 ;
vOpen2() ; FN,SEQ FROM SCATBL4 WHERE FN>:N
 ;
 ;
 S vos6=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos6=0 Q
vL2a1 S vos7=$$BYTECHAR^SQLUTL(254)
 S vos8=$G(N) I vos8="",'$D(N) G vL2a0
 S vos9=vos8
vL2a4 S vos9=$O(^SCATBL(4,vos9),1) I vos9="" G vL2a0
 S vos10=""
vL2a6 S vos10=$O(^SCATBL(4,vos9,vos10),1) I vos10="" G vL2a4
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos6=1 D vL2a6
 I vos6=2 S vos6=1
 ;
 I vos6=0 S rs="" Q 0
 ;
 S rs=$S(vos9=vos7:"",1:vos9)_$C(9)_$S(vos10=vos7:"",1:vos10)
 ;
 Q 1
 ;
vOpen3() ; FN,SEQ FROM SCATBLDOC WHERE FN=:FN AND SEQ>:N
 ;
 ;
 S vos1=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos1=0 Q
vL3a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(FN) I vos3="" G vL3a0
 S vos4=$G(N)
 S vos5=vos4
vL3a5 S vos5=$O(^SCATBL(3,vos3,vos5),1) I vos5="" G vL3a0
 Q
 ;
vFetch3() ;
 ;
 ;
 I vos1=1 D vL3a5
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=vos3_$C(9)_$S(vos5=vos2:"",1:vos5)
 ;
 Q 1
 ;
vOpen4() ; FN,SEQ FROM SCATBLDOC WHERE FN=:FN
 ;
 ;
 S vos1=2
 D vL4a1
 Q ""
 ;
vL4a0 S vos1=0 Q
vL4a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(FN) I vos3="" G vL4a0
 S vos4=""
vL4a4 S vos4=$O(^SCATBL(3,vos3,vos4),1) I vos4="" G vL4a0
 Q
 ;
vFetch4() ;
 ;
 ;
 I vos1=1 D vL4a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vDs="" Q 0
 ;
 S vDs=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen5() ; FN,SEQ FROM SCATBLDOC WHERE FN=:FN
 ;
 ;
 S vos1=2
 D vL5a1
 Q ""
 ;
vL5a0 S vos1=0 Q
vL5a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(FN) I vos3="" G vL5a0
 S vos4=""
vL5a4 S vos4=$O(^SCATBL(3,vos3,vos4),1) I vos4="" G vL5a0
 Q
 ;
vFetch5() ;
 ;
 ;
 I vos1=1 D vL5a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vDs="" Q 0
 ;
 S vDs=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vReSav1(scatbld) ; RecordSCATBLDOC saveNoFiler(LOG)
 ;
 D ^DBSLOGIT(scatbld,vobj(scatbld,-2))
 S ^SCATBL(3,vobj(scatbld,-3),vobj(scatbld,-4))=$$RTBAR^%ZFUNC($G(vobj(scatbld)))
 Q
 ;
vReSav2(scatbl3) ; RecordSCATBL3 saveNoFiler(LOG)
 ;
 D ^DBSLOGIT(scatbl3,vobj(scatbl3,-2))
 S ^SCATBL(1,vobj(scatbl3,-3),vobj(scatbl3,-4))=$$RTBAR^%ZFUNC($G(vobj(scatbl3)))
 Q
