DBS2PSL3(dbtbl2)	; DBS - U - V7.0 - PSL Screen compiler
	;
	; **** Routine compiled from DATA-QWIK Procedure DBS2PSL3 ****
	;
	; 09/14/2007 10:46 - chenardp
	;
	N I N SAVC N SAVD N X
	;
	S SAVD=D S SAVC=C
	;
	K BLD,TMP(998),TMP(999)
	S EXTSID=SID
	;
	; Data entry pre/post processor
	K OM
	N ds,vos1,vos2,vos3 S ds=$$vOpen1()
	I ''$G(vos1) D
	.	F  Q:'($$vFetch1())  D
	..		N code N pseq
	..		N dbtbl2pp,vop1 S vop1=$P(ds,$C(9),4),dbtbl2pp=$G(^DBTBL($P(ds,$C(9),1),2,$P(ds,$C(9),2),$P(ds,$C(9),3),vop1))
	..		S pseq=vop1
	..		S code=$P(dbtbl2pp,$C(12),1)
	..		S OM(pseq)=code
	..		Q  ; while ...
	.	;
	.	D PPLIB^DBS2PSL4(.OM) ; parse for PP Libs
	.	;
	.	S TMP(998,1)="VDEPRE("_vobjlst("formal")_")  // Data Entry Pre-processor"
	.	S TMP(998,2)=" "
	.	S X="" F I=3:1 S X=$order(OM(X)) Q:X=""  S TMP(998,I)=OM(X)
	.	Q  ;isEmpty
	;
	K OM
	N ds1,vos4,vos5,vos6 S ds1=$$vOpen2()
	I ''$G(vos4) D
	.	F  Q:'($$vFetch2())  D
	..		N code,pseq
	..		N dbtbl2pp,vop2 S vop2=$P(ds1,$C(9),4),dbtbl2pp=$G(^DBTBL($P(ds1,$C(9),1),2,$P(ds1,$C(9),2),$P(ds1,$C(9),3),vop2))
	..		S pseq=vop2
	..		S code=$P(dbtbl2pp,$C(12),1)
	..		S OM(pseq)=code
	..		Q  ; while ...
	.	;
	.	D PPLIB^DBS2PSL4(.OM) ; parse for PP Libs
	.	;
	.	S X="" F I=1:1 S X=$order(OM(X)) Q:X=""  S TMP(999,I)=OM(X)
	.	Q  ; is Empty
	;
	K OM
	;
	I $$vDbEx1() D
	.	D SUBVLOD(.dbtbl2)
	.	Q 
	;
	E  D  Q:ER 
	.	D ^DBSREL I ER D ERR^DBSBLD Q 
	.	S L=0 S FID=PFID D FLD^DBSBLD
	.	S AR=""
	.	Q 
	;
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	I $P(vobj(dbtbl2,0),$C(124),7) S VNEW(1)=" do VLOD("_vobjlst("actual")_")"
	;
	S %TIM=$$TIM^%ZM
	S C=" //" S QUIT=" quit"
	I $P(vobj(dbtbl2,0),$C(124),7) D
	.	S X41=" //" I SAVT S X41=" for I="_(SAVT+1)_":1:%MAX set %TAB(I)="_Q_Q
	.	S C1=" kill VSCRPP,REQ,%TAB,vtab,%MOD,%MODOFF set %MODOFF="_%OFF
	.	Q 
	E  S X41=" // "
	;
	I $D(BLD(2)),$piece(BLD(2)," ;",1)="EXEC" S BLD(2)="VLOD("_vobjlst("formal")_") // Load data from disc - %O = (1-5)"
	I $P(vobj(dbtbl2,0),$C(124),7) S BLD(2.5)=" if '$D(%REPEAT) set %REPEAT="_(23-$P(vobj(dbtbl2,0),$C(124),7))
	I $P(vobj(dbtbl2,0),$C(124),7) S BLD(2.55)=" if '$D(%MODS) set %MODS=1" S VSAV(1,"%MODS")="" S VSAV(1,"%REPEAT")=""
	D ^DBS2PSL4(.dbtbl2)
	Q 
	;
SUBVLOD(dbtbl2)	; Substitute VLOD with user defined access section
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	;
	N OM N X
	N I
	;
	K BLD
	S BLD(1)="VLOD("_vobjlst("formal")_") // User defined access section"
	S BLD(1.1)=" //"
	K OM
	N ds,vos1,vos2,vos3 S ds=$$vOpen3()
	I ''$G(vos1) D
	.	F  Q:'($$vFetch3())  D
	..		N code N pseq
	..		N dbtbl2pp,vop1 S vop1=$P(ds,$C(9),4),dbtbl2pp=$G(^DBTBL($P(ds,$C(9),1),2,$P(ds,$C(9),2),$P(ds,$C(9),3),vop1))
	..		S pseq=vop1
	..		S code=$P(dbtbl2pp,$C(12),1)
	..		S OM(pseq)=code
	..		Q  ; while ...
	.	;
	.	D PPLIB^DBS2PSL4(.OM) ; parse for PP Libs
	.	S X="" F I=3:.001 S X=$order(OM(X)) Q:X=""  S BLD(I)=OM(X)
	.	K OM
	.	I '$P(vobj(dbtbl2,0),$C(124),7) S VNEW(100)=" do VLOD("_vobjlst("actual")_")"
	.	Q  ;isEmpty
	Q 
	;  #OPTION ResultClass ON
vSIG()	;
	Q "60108^5233^sviji^3449" ; Signature - LTD^TIME^USER^SIZE
	;
vDbEx1()	;	min(1): DISTINCT LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS=:%LIBS AND SID=:SID AND SEQ=0 AND PSEQ=101
	;
	N vsql1
	S vsql1=$G(%LIBS) I vsql1="" Q 0
	;
	I '($D(^DBTBL(vsql1,2,SID,0,101))#2) Q 0
	Q 1
	;
vOpen1()	;	LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS='SYSDEV' AND SID=:SID AND SEQ=0 AND PSEQ BETWEEN 1 AND 20
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(SID) I vos2="" G vL1a0
	S vos3=1
	I $D(^DBTBL("SYSDEV",2,vos2,0,vos3)),'(vos3>20) G vL1a5
vL1a4	S vos3=$O(^DBTBL("SYSDEV",2,vos2,0,vos3),1) I vos3=""!(vos3>20) G vL1a0
vL1a5	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a4
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds="SYSDEV"_$C(9)_vos2_$C(9)_0_$C(9)_$S(vos3=$$BYTECHAR^SQLUTL(254):"",1:vos3)
	;
	Q 1
	;
vOpen2()	;	LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS='SYSDEV' AND SID=:SID AND SEQ=0 AND PSEQ BETWEEN 21 AND 40
	;
	;
	S vos4=2
	D vL2a1
	Q ""
	;
vL2a0	S vos4=0 Q
vL2a1	S vos5=$G(SID) I vos5="" G vL2a0
	S vos6=21
	I $D(^DBTBL("SYSDEV",2,vos5,0,vos6)),'(vos6>40) G vL2a5
vL2a4	S vos6=$O(^DBTBL("SYSDEV",2,vos5,0,vos6),1) I vos6=""!(vos6>40) G vL2a0
vL2a5	Q
	;
vFetch2()	;
	;
	;
	I vos4=1 D vL2a4
	I vos4=2 S vos4=1
	;
	I vos4=0 Q 0
	;
	S ds1="SYSDEV"_$C(9)_vos5_$C(9)_0_$C(9)_$S(vos6=$$BYTECHAR^SQLUTL(254):"",1:vos6)
	;
	Q 1
	;
vOpen3()	;	LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS='SYSDEV' AND SID=:SID AND SEQ=0 AND PSEQ BETWEEN 101 AND 120
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(SID) I vos2="" G vL3a0
	S vos3=101
	I $D(^DBTBL("SYSDEV",2,vos2,0,vos3)),'(vos3>120) G vL3a5
vL3a4	S vos3=$O(^DBTBL("SYSDEV",2,vos2,0,vos3),1) I vos3=""!(vos3>120) G vL3a0
vL3a5	Q
	;
vFetch3()	;
	;
	;
	I vos1=1 D vL3a4
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds="SYSDEV"_$C(9)_vos2_$C(9)_0_$C(9)_$S(vos3=$$BYTECHAR^SQLUTL(254):"",1:vos3)
	;
	Q 1
