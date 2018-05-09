UPID(FID,PGM)	;Data item protection utility
	;
	; **** Routine compiled from DATA-QWIK Procedure UPID ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	N vpc
	;
	 S ER=0
	;
	N FPN N MPLCTDD N X N ZFID N ZLIBS
	;
	S (PGM,RM)=""
	;
	N rs,vos1,vos2,vos3 S rs=$$vOpen1()
	S vpc=('$G(vos1)) Q:vpc 
	;
	; Get protection program FILE ID from file definition
	N dbtbl1,vop1,vop2,vop3,vop4 S vop1="SYSDEV",vop2=FID,dbtbl1=$$vDb2("SYSDEV",FID,.vop3)
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
STATUS(FID,DINAM,FLG)	;
	;
	S FLG=0
	;
	I ($D(^DBTBL("SYSDEV",1,FID))) D
	.	;
	.	; Any data item
	.	I DINAM="#" D
	..		N rs,vos1,vos2,vos3 S rs=$$vOpen2()
	..		I ''$G(vos1) S FLG=1
	..		Q 
	.	;
	.	; Specific data item
	.	E  D
	..		N rs,vos4,vos5,vos6,vos7 S rs=$$vOpen3()
	..		I ''$G(vos4) S FLG=1
	..		Q 
	.	Q 
	;
	Q 
	;
EXT(FID,REC)	;
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
PGM(FID)	;
	;
	N FPN N PGM
	;
	I $get(FID)="" Q ""
	;
	; Get protection program FILE ID from file definition
	N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=FID,dbtbl1=$$vDb3("SYSDEV",FID)
	 S vop3=$G(^DBTBL(vop1,1,vop2,99))
	S FPN=$P(vop3,$C(124),3)
	;
	I FPN="" Q ""
	;
	S PGM="VP01"_FPN
	;
	Q PGM
	;
vSIG()	;
	Q "60282^65131^Dan Russell^4574" ; Signature - LTD^TIME^USER^SIZE
	;
vDb2(v1,v2,v2out)	;	voXN = Db.getRecord(DBTBL1,,1,-2)
	;
	N dbtbl1
	S dbtbl1=$G(^DBTBL(v1,1,v2))
	I dbtbl1="",'$D(^DBTBL(v1,1,v2))
	S v2out='$T
	;
	Q dbtbl1
	;
vDb3(v1,v2)	;	voXN = Db.getRecord(DBTBL1,,1)
	;
	N dbtbl1
	S dbtbl1=$G(^DBTBL(v1,1,v2))
	I dbtbl1="",'$D(^DBTBL(v1,1,v2))
	;
	Q dbtbl1
	;
vOpen1()	;	DISTINCT FID FROM DBTBL14 WHERE FID=:FID
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(FID) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^DBTBL(vos3),1) I vos3="" G vL1a0
	I '($D(^DBTBL(vos3,14,vos2))) G vL1a3
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=vos2
	S vos1=100
	;
	Q 1
	;
vOpen2()	;	DISTINCT FID FROM DBTBL14 WHERE FID=:FID
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(FID) I vos2="" G vL2a0
	S vos3=""
vL2a3	S vos3=$O(^DBTBL(vos3),1) I vos3="" G vL2a0
	I '($D(^DBTBL(vos3,14,vos2))) G vL2a3
	Q
	;
vFetch2()	;
	;
	;
	I vos1=1 D vL2a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=vos2
	S vos1=100
	;
	Q 1
	;
vOpen3()	;	DINAM FROM DBTBL14 WHERE PLIBS='SYSDEV' AND FID=:FID AND DINAM=:DINAM
	;
	;
	S vos4=2
	D vL3a1
	Q ""
	;
vL3a0	S vos4=0 Q
vL3a1	S vos5=$G(FID) I vos5="" G vL3a0
	S vos6=$G(DINAM) I vos6="" G vL3a0
	S vos7=""
vL3a4	S vos7=$O(^DBTBL("SYSDEV",14,vos5,vos6,vos7),1) I vos7="" G vL3a0
	Q
	;
vFetch3()	;
	;
	;
	I vos4=1 D vL3a4
	I vos4=2 S vos4=1
	;
	I vos4=0 Q 0
	;
	S rs=vos6
	;
	Q 1
