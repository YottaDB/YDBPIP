 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UPID ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
UPID(FID,PGM) ; Data item protection utility
 N vpc
 ;
  S ER=0
 ;
 N FPN N MPLCTDD N X N ZFID N ZLIBS
 ;
 S (PGM,RM)=""
 ;
 N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen1()
 S vpc='$G(vos1) Q:vpc 
 ;
 ; Get protection program FILE ID from file definition
 N dbtbl1,vop1,vop2,vop3,vop4 S vop1="SYSDEV",vop2=FID,dbtbl1=$$vRCgetRecord1Opt^RecordDBTBL1("SYSDEV",FID,0,.vop3)
  S vop4=$G(^DBTBL(vop1,1,vop2,99))
 ; Invalid file name ~p1
 I '$G(vop3) S RM=$$^MSG(1337) Q 
 ;
 S FPN=$P(vop4,$C(124),3)
 ;
 ; Protection program name not set up for file ~p1
 I FPN="" D SETERR^DBSEXECU("DBTBL1","MSG",2279,FID) Q:ER 
 ;
 S PGM="VP01"_FPN
 Q 
 ;
STATUS(FID,DINAM,FLG) ; 
 ;
 S FLG=0
 ;
 I ($D(^DBTBL("SYSDEV",1,FID))) D
 .	;
 .	; Any data item
 .	I DINAM="#" D
 ..		N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen2()
 ..  I ''$G(vos1) S FLG=1
 ..  Q 
 .	;
 .	; Specific data item
 .	E  D
 ..		N rs,vos5,vos6,vos7,vos8,vos9 S rs=$$vOpen3()
 ..  I ''$G(vos5) S FLG=1
 ..  Q 
 .	Q 
 ;
 Q 
 ;
EXT(FID,REC) ; Record object
 ;
 N FLG
 N PGM
 ;
 ; Name not defined
 D UPID(FID,.PGM) I PGM="" S RM="" Q 
 ;
 ; No definition
 D STATUS(FID,"#",.FLG) I 'FLG S PGM="" Q 
 ;
 D @("%EXT^"_PGM_"(.REC,.VP)")
 ;
 Q 
 ;
PGM(FID) ; 
 ;
 N FPN N PGM
 ;
 I $get(FID)="" Q ""
 ;
 ; Get protection program FILE ID from file definition
 N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=FID,dbtbl1=$$vRCgetRecord1Opt^RecordDBTBL1("SYSDEV",FID,0,"")
  S vop3=$G(^DBTBL(vop1,1,vop2,99))
 S FPN=$P(vop3,$C(124),3)
 ;
 I FPN="" Q ""
 ;
 S PGM="VP01"_FPN
 ;
 Q PGM
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60282^65131^Dan Russell^4639" ; Signature - LTD^TIME^USER^SIZE
 ;
vOpen1() ; DISTINCT FID FROM DBTBL14 WHERE FID=:FID
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(FID) I vos3="" G vL1a0
 S vos4=""
vL1a4 S vos4=$O(^DBTBL(vos4),1) I vos4="" G vL1a0
 I '($D(^DBTBL(vos4,14,vos3))) G vL1a4
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
 S rs=vos3
 S vos1=100
 ;
 Q 1
 ;
vOpen2() ; DISTINCT FID FROM DBTBL14 WHERE FID=:FID
 ;
 ;
 S vos1=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos1=0 Q
vL2a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(FID) I vos3="" G vL2a0
 S vos4=""
vL2a4 S vos4=$O(^DBTBL(vos4),1) I vos4="" G vL2a0
 I '($D(^DBTBL(vos4,14,vos3))) G vL2a4
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
 S rs=vos3
 S vos1=100
 ;
 Q 1
 ;
vOpen3() ; DINAM FROM DBTBL14 WHERE PLIBS='SYSDEV' AND FID=:FID AND DINAM=:DINAM
 ;
 ;
 S vos5=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos5=0 Q
vL3a1 S vos6=$$BYTECHAR^SQLUTL(254)
 S vos7=$G(FID) I vos7="" G vL3a0
 S vos8=$G(DINAM) I vos8="" G vL3a0
 S vos9=""
vL3a5 S vos9=$O(^DBTBL("SYSDEV",14,vos7,vos8,vos9),1) I vos9="" G vL3a0
 Q
 ;
vFetch3() ;
 ;
 ;
 I vos5=1 D vL3a5
 I vos5=2 S vos5=1
 ;
 I vos5=0 S rs="" Q 0
 ;
 S rs=vos8
 ;
 Q 1
