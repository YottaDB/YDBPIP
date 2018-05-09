DBSRWALN(RID,IO,COUNT)	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSRWALN ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	N vpc
	;
	N FROM N I N RPTCNT N RPTFROM N RPTSIZE N RPTTO N TO
	N ALL9 N ALLX N GRP N PRINT
	;
	USE IO WRITE !
	;
	; Find last key level with detail
	N dbtbl5h,vop1,vop2,vop3,vop4,vop5,vop6,vop7,vop8,vop9,vop10,vop11,vop12 S vop1="SYSDEV",vop2=RID,dbtbl5h=$$vDb4("SYSDEV",RID)
	 S vop12=$G(^DBTBL(vop1,5,vop2,10))
	 S vop11=$G(^DBTBL(vop1,5,vop2,9))
	 S vop10=$G(^DBTBL(vop1,5,vop2,8))
	 S vop9=$G(^DBTBL(vop1,5,vop2,7))
	 S vop8=$G(^DBTBL(vop1,5,vop2,6))
	 S vop7=$G(^DBTBL(vop1,5,vop2,5))
	 S vop6=$G(^DBTBL(vop1,5,vop2,4))
	 S vop5=$G(^DBTBL(vop1,5,vop2,3))
	 S vop4=$G(^DBTBL(vop1,5,vop2,2))
	 S vop3=$G(^DBTBL(vop1,5,vop2,1))
	S GRP=$P(vop12,$C(124),1) I $$GRPDTL(RID,GRP,.FROM,.TO)
	E  S GRP=$P(vop11,$C(124),1) I $$GRPDTL(RID,GRP,.FROM,.TO)
	E  S GRP=$P(vop10,$C(124),1) I $$GRPDTL(RID,GRP,.FROM,.TO)
	E  S GRP=$P(vop9,$C(124),1) I $$GRPDTL(RID,GRP,.FROM,.TO)
	E  S GRP=$P(vop8,$C(124),1) I $$GRPDTL(RID,GRP,.FROM,.TO)
	E  S GRP=$P(vop7,$C(124),1) I $$GRPDTL(RID,GRP,.FROM,.TO)
	E  S GRP=$P(vop6,$C(124),1) I $$GRPDTL(RID,GRP,.FROM,.TO)
	E  S GRP=$P(vop5,$C(124),1) I $$GRPDTL(RID,GRP,.FROM,.TO)
	E  S GRP=$P(vop4,$C(124),1) I $$GRPDTL(RID,GRP,.FROM,.TO)
	E  S GRP=$P(vop3,$C(124),1) I '$$GRPDTL(RID,GRP,.FROM,.TO) Q 
	;
	S ALL9="" S $piece(ALL9,"9",31)=""
	S ALLX="" S $piece(ALLX,"X",121)=""
	;
	; Set up print buffers
	N dbtbl5dg,vop13,vop14,vop15 S vop13="SYSDEV",vop14=RID,vop15=GRP,dbtbl5dg=$$vDb5("SYSDEV",RID,GRP)
	 S dbtbl5dg=$G(^DBTBL(vop13,5,vop14,vop15,25))
	;
	S RPTFROM=$P(dbtbl5dg,$C(124),1)
	S RPTTO=$P(dbtbl5dg,$C(124),2)
	S RPTSIZE=$P(dbtbl5dg,$C(124),3)
	S RPTCNT=$P(dbtbl5dg,$C(124),4)
	;
	F I=FROM:1:TO S PRINT(I)=""
	;
	N ds,vos1,vos2,vos3,vos4 S ds=$$vOpen1()
	F  Q:'($$vFetch1())  D
	.	N LINE N SIZE N TAB
	.	N BLANK N OUT N TYPE N VAR
	.	N dbtbl5d S dbtbl5d=$G(^DBTBL($P(ds,$C(9),1),5,$P(ds,$C(9),2),$P(ds,$C(9),3),$P(ds,$C(9),4)))
	.	;
	.	S LINE=$P(dbtbl5d,$C(124),1)\1000
	.	S TAB=$P(dbtbl5d,$C(124),1)#1000
	.	;
	.	S vpc=(LINE<FROM) Q:vpc  ; Group header
	.	S vpc=(LINE>TO) Q:vpc  ; Group trailer
	.	;
	.	S SIZE=$P(dbtbl5d,$C(124),3)
	.	S TYPE=$P(dbtbl5d,$C(124),4)
	.	S VAR=$P(dbtbl5d,$C(124),7)
	.	;
	.	I $P(dbtbl5d,$C(124),2)?1"@".E,VAR["," D  ; Convert type and size
	..		N I
	..		;
	..		F I=1:1:10 Q:$piece(VAR,",",I)="" 
	..		I $piece(VAR,",",I-1) S SIZE=$piece(VAR,",",I-1)
	..		S TYPE=$piece(VAR,",",I-2)
	..		Q 
	.	;
	.	; Set up to print 99999 or XXXX  based on format type
	.	;
	.	I TYPE="N" S OUT=$E(ALL9,1,SIZE)
	.	E  I TYPE="$"!(TYPE="E") S OUT=$E(ALL9,1,SIZE-3)_".99"
	.	E  I TYPE="T",VAR'?1"@".E,$P(dbtbl5d,$C(124),6)?1"@".E,VAR'?1"<<".E S OUT=VAR
	.	;
	.	; <<VAR,D,SIZE>>
	.	E  I VAR?1"<<"1E.E1">>",$piece(VAR,",",2)="D" S OUT="MM/DD/YY"
	.	;
	.	; @CHR
	.	E  I $P(dbtbl5d,$C(124),6)?1"@".E,VAR?1"@CHR(".E D
	..		N I
	..		N X
	..		;
	..		S X=$piece($piece(VAR,",",1),"(",2)
	..		S OUT=""
	..		F I=1:1:SIZE S OUT=OUT_X
	..		Q 
	.	;
	.	E  S OUT=$E(ALLX,1,SIZE)
	.	;
	.	S BLANK=$J("",TAB-1-$L(PRINT(LINE)))
	.	S PRINT(LINE)=PRINT(LINE)_BLANK_OUT
	.	Q 
	;
	F I=1:1:COUNT D  ; Output buffer information
	.	N J N K N LINE
	.	;
	.	S LINE=""
	.	F J=1:1 S LINE=$order(PRINT(LINE)) Q:LINE=""  D
	..		I LINE<RPTFROM!(LINE>RPTTO) WRITE PRINT(LINE),!
	..		E  D  ; Repeat Group
	...			N BLANK
	...			S BLANK=$J("",RPTSIZE-$L(PRINT(LINE)))
	...			F K=1:1:RPTCNT WRITE PRINT(LINE)_BLANK
	...			WRITE !
	...			Q 
	..		Q 
	.	Q 
	Q 
	;
GRPDTL(RID,GRP,FROM,TO)	;
	;
	N DETAIL S DETAIL=0
	;
	Q:GRP="" 0
	;
	N dbtbl5dg,vop1,vop2,vop3 S vop1="SYSDEV",vop2=RID,vop3=GRP,dbtbl5dg=$$vDb5("SYSDEV",RID,GRP)
	 S dbtbl5dg=$G(^DBTBL(vop1,5,vop2,vop3,0))
	;
	S FROM=$piece($P(dbtbl5dg,$C(124),1),",",1)+2
	S TO=$piece($P(dbtbl5dg,$C(124),1),",",2)+FROM-1
	;
	N rs,vos1,vos2,vos3,vos4,vos5 S rs=$$vOpen2()
	F  Q:'($$vFetch2())  D  Q:DETAIL 
	.	N X
	.	;
	.	S X=rs\1000
	.	I X'<FROM,X'>TO S DETAIL=1
	.	Q 
	;
	Q DETAIL
	;
vSIG()	;
	Q "60107^24077^sviji^3967" ; Signature - LTD^TIME^USER^SIZE
	;
vDb4(v1,v2)	;	voXN = Db.getRecord(DBTBL5H,,0)
	;
	N dbtbl5h
	S dbtbl5h=$G(^DBTBL(v1,5,v2))
	I dbtbl5h="",'$D(^DBTBL(v1,5,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL5H" X $ZT
	Q dbtbl5h
	;
vDb5(v1,v2,v3)	;	voXN = Db.getRecord(DBTBL5DGC,,0)
	;
	I '(v3]]"@")
	E  I '$D(^DBTBL(v1,5,v2,v3))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL5DGC" X $ZT
	Q ""
	;
vOpen1()	;	LIBS,RID,GRP,ITMSEQ FROM DBTBL5D WHERE LIBS='SYSDEV' AND RID=:RID AND GRP=:GRP ORDER BY ITMSEQ ASC
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(RID) I vos2="" G vL1a0
	S vos3=$G(GRP) I vos3="" G vL1a0
	S vos4=100
vL1a4	S vos4=$O(^DBTBL("SYSDEV",5,vos2,vos3,vos4),1) I vos4="" G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a4
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds="SYSDEV"_$C(9)_vos2_$C(9)_vos3_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen2()	;	STATUS FROM DBTBL5D WHERE LIBS='SYSDEV' AND RID=:RID AND GRP=:GRP
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(RID) I vos2="" G vL2a0
	S vos3=$G(GRP) I vos3="" G vL2a0
	S vos4=100
vL2a4	S vos4=$O(^DBTBL("SYSDEV",5,vos2,vos3,vos4),1) I vos4="" G vL2a0
	Q
	;
vFetch2()	;
	;
	I vos1=1 D vL2a4
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos5=$G(^DBTBL("SYSDEV",5,vos2,vos3,vos4))
	S rs=$P(vos5,"|",1)
	;
	Q 1
