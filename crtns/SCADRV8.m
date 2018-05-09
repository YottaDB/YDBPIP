 ; 
 ; **** Routine compiled from DATA-QWIK Procedure SCADRV8 ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
SCADRV8 ; 
 ;
 Q 
 ;
NEW ; 
 S %O=0 D INIT Q 
 ;
UPD ; 
 S %O=1 D INIT Q 
 ;
DEL ; 
 S %O=3 D INIT Q 
 ;
INIT ; 
 ;
 K OLNTB
 ;
 S %TAB("MENU")=".MENU1/TBL=[SCAMENU0]/XPP=D PPMENU^SCADRV8"
 S %READ="@@%FN,,,MENU/REQ" S %NOPRMT="F"
 ;
 D ^UTLREAD
 ;
 ; No changes made
 I VFMQ="Q"!'$D(MENU) S ER="W" S RM=$$^MSG(1905) Q 
 ;
 D VPG1
 Q 
 ;
VPG1 ; 
 ;
 N HDG N HDG2
 ;
 S (DESC,PROMPT)=""
 ;
 ; Menu Number ~p1
 S HDG=$$^MSG(5484,MENU) S HDG=$J("",(80-$L(HDG))\2)_HDG
 ;
 ; Enter ~p1 function
 S %TAB("DESC")=".DESC2/XPP=if PROMPT="""" set PROMPT=$$^MSG(8370,X),RM=PROMPT_%_(NI+1)"
 S %TAB("PROMPT")=".PROMPT1"
 ;
 N scamenu0,vop1 S scamenu0=$$vRCgetRecord1Opt^RecordSCAMENU0(MENU,0,.vop1)
 I $G(vop1) S DESC=$P(scamenu0,$C(124),1) S PROMPT=$P(scamenu0,$C(124),2)
 ;
 S DEL=0
 ;
 S %READ="@@%FN,,,DESC/REQ,PROMPT/REQ"
 ;
 ; Description: ~p1
 I %O=3 S %TAB("DEL")=".DEL1" S HDG2=$$^MSG(8233,DESC) S %READ="@HDG,,@HDG2,DEL/REQ" S DEL=1 S %NOPRMT="F"
 D ^UTLREAD
 ;
 I %O=3,'DEL S VFMQ="Q"
 ;
 D VER
 Q 
 ;
VER ; 
 ;
 I VFMQ="Q" D END Q 
 D FILE
 ;
 I %O=0 D EXT^SCADRV5
 ;
 D END
 Q 
 ;
FILE ; 
 N vTp
 ;
 I %O=3 D vDbDe1() Q 
 ;
 N scamenu0 S scamenu0=$$vRCgetRecord1^RecordSCAMENU0(MENU,0)
  S $P(vobj(scamenu0),$C(124),1)=DESC
  S $P(vobj(scamenu0),$C(124),2)=PROMPT
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vReSav1(scamenu0) S vobj(scamenu0,-2)=1 TC:vTp  
 K vobj(+$G(scamenu0)) Q 
 ;
END ; 
 ;
 I VFMQ="Q" D
 .	;
 .	; Menu ~p1 not created
 .	I %O=0 S RM=$$^MSG(1711,MENU) Q 
 .	;
 .	; Menu ~p1 not modified
 .	I %O=1 S RM=$$^MSG(1713,MENU) Q 
 .	;
 .	; Menu ~p1 not deleted
 .	S RM=$$^MSG(1712,MENU)
 .	Q 
 ;
 E  D
 .	;
 .	; Menu ~p1 created
 .	I %O=0 S RM=$$^MSG(1708,MENU) Q 
 .	;
 .	; Menu ~p1 modified
 .	I %O=1 S RM=$$^MSG(1710,MENU) Q 
 .	;
 .	; Menu ~p1 deleted
 .	S RM=$$^MSG(1709,MENU)
 .	Q 
 ;
 S ER="W"
 Q 
 ;
PPMENU ; 
 N FMENU N M N N N SUBM
 ;
 ; MENU post processor
 I '%OSAVE S I(3)=""
 ;
 N rs,vos1,vos2,vos3 S rs=$$vOpen1()
 ;
 ; Record already exists
 I '%OSAVE,'(X=""),''$G(vos1) S ER=1 S RM=$$^MSG(2327)
 ;
 I %OSAVE'=3 Q 
 ;
 N rs1,vos4,vos5,vos6,vos7 S rs1=$$vOpen2()
 ;
 ; Menu not empty
 I '(X=""),''$G(vos4) S ER=1 S RM=$$^MSG(1705) Q 
 ;
 ; Check other menus and sub-menus
 S (N,M)=""
 S ER=0
 ;
 N rs2,vos8,vos9,vos10 S rs2=$$vOpen3()
 F  Q:'$$vFetch3()  D
 . S N=rs2
 .	N rs3,vos11,vos12,vos13,vos14,vos15 S rs3=$$vOpen4()
 .	F  Q:'$$vFetch4()  D
 ..  S M=$P(rs3,$C(9),1)
 ..  S FMENU=$P(rs3,$C(9),2)
 ..		I FMENU'=X Q 
 ..		;
 ..		; Menu is linked to menu #~p1
 ..		S ER=1 S RM=$$^MSG(1704,N)
 ..		Q 
 . Q 
 Q:ER 
 ;
 N rs4,vos16,vos17,vos18,vos19 S rs4=$$vOpen5()
 F  Q:'$$vFetch5()  D
 . S N=rs4
 .	N rs5,vos20,vos21,vos22,vos23,vos24 S rs5=$$vOpen6()
 .	F  Q:'$$vFetch6()  D
 ..  S M=$P(rs5,$C(9),1)
 ..  S SUBM=$P(rs5,$C(9),2)
 ..		I $translate(SUBM,"@")'=X Q 
 ..		Q 
 . Q 
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60218^26329^Sanjay Chhrabria^3557" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM SCAMENU0 WHERE MENU=:MENU
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vRec S vRec=$$vRCgetRecord1^RecordSCAMENU0(MENU,0)
 I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordSCAMENU0(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 K vobj(+$G(vRec)) Q 
 ;
vOpen1() ; MENU FROM SCAMENU0 WHERE MENU=:X
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(X)
 I '($D(^SCATBL(0,vos3))#2) G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos1=100
 S rs=vos3
 S vos1=0
 ;
 Q 1
 ;
vOpen2() ; SNUMB FROM SCAMENU WHERE MNUMB=:X
 ;
 ;
 S vos4=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos4=0 Q
vL2a1 S vos5=$$BYTECHAR^SQLUTL(254)
 S vos6=$G(X)
 S vos7=""
vL2a4 S vos7=$O(^SCATBL(0,vos6,vos7),1) I vos7="" G vL2a0
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos4=1 D vL2a4
 I vos4=2 S vos4=1
 ;
 I vos4=0 S rs1="" Q 0
 ;
 S rs1=$S(vos7=vos5:"",1:vos7)
 ;
 Q 1
 ;
vOpen3() ; MENU FROM SCAMENU0
 ;
 ;
 S vos8=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos8=0 Q
vL3a1 S vos9=$$BYTECHAR^SQLUTL(254)
 S vos10=""
vL3a3 S vos10=$O(^SCATBL(0,vos10),1) I vos10="" G vL3a0
 Q
 ;
vFetch3() ;
 ;
 ;
 I vos8=1 D vL3a3
 I vos8=2 S vos8=1
 ;
 I vos8=0 S rs2="" Q 0
 ;
 S rs2=$S(vos10=vos9:"",1:vos10)
 ;
 Q 1
 ;
vOpen4() ; SNUMB,FUNMENU FROM SCAMENU WHERE MNUMB=:N
 ;
 ;
 S vos11=2
 D vL4a1
 Q ""
 ;
vL4a0 S vos11=0 Q
vL4a1 S vos12=$$BYTECHAR^SQLUTL(254)
 S vos13=$G(N)
 S vos14=""
vL4a4 S vos14=$O(^SCATBL(0,vos13,vos14),1) I vos14="" G vL4a0
 Q
 ;
vFetch4() ;
 ;
 ;
 I vos11=1 D vL4a4
 I vos11=2 S vos11=1
 ;
 I vos11=0 S rs3="" Q 0
 ;
 S vos15=$G(^SCATBL(0,vos13,vos14))
 S rs3=$S(vos14=vos12:"",1:vos14)_$C(9)_$P(vos15,"|",2)
 ;
 Q 1
 ;
vOpen5() ; FN FROM SCATBL4
 ;
 ;
 S vos16=2
 D vL5a1
 Q ""
 ;
vL5a0 S vos16=0 Q
vL5a1 S vos17=$$BYTECHAR^SQLUTL(254)
 S vos18=""
vL5a3 S vos18=$O(^SCATBL(4,vos18),1) I vos18="" G vL5a0
 S vos19=""
vL5a5 S vos19=$O(^SCATBL(4,vos18,vos19),1) I vos19="" G vL5a3
 Q
 ;
vFetch5() ;
 ;
 ;
 I vos16=1 D vL5a5
 I vos16=2 S vos16=1
 ;
 I vos16=0 S rs4="" Q 0
 ;
 S rs4=$S(vos18=vos17:"",1:vos18)
 ;
 Q 1
 ;
vOpen6() ; SEQ,SUB FROM SCATBL4 WHERE FN=:N
 ;
 ;
 S vos20=2
 D vL6a1
 Q ""
 ;
vL6a0 S vos20=0 Q
vL6a1 S vos21=$$BYTECHAR^SQLUTL(254)
 S vos22=$G(N) I vos22="" G vL6a0
 S vos23=""
vL6a4 S vos23=$O(^SCATBL(4,vos22,vos23),1) I vos23="" G vL6a0
 Q
 ;
vFetch6() ;
 ;
 ;
 I vos20=1 D vL6a4
 I vos20=2 S vos20=1
 ;
 I vos20=0 S rs5="" Q 0
 ;
 S vos24=$G(^SCATBL(4,vos22,vos23))
 S rs5=$S(vos23=vos21:"",1:vos23)_$C(9)_$P(vos24,"|",2)
 ;
 Q 1
 ;
vReSav1(scamenu0) ; RecordSCAMENU0 saveNoFiler(LOG)
 ;
 D ^DBSLOGIT(scamenu0,vobj(scamenu0,-2))
 S ^SCATBL(0,vobj(scamenu0,-3))=$$RTBAR^%ZFUNC($G(vobj(scamenu0)))
 Q
