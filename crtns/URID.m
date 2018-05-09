URID	;
	;
	; **** Routine compiled from DATA-QWIK Procedure URID ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	;
	D GET
	;
	Q 
	;
GET	;
	;
	K %LINK
	;
	N dbtbl5h,vop1,vop2,vop3 S vop1="SYSDEV",vop2=RID,dbtbl5h=$$vDb4("SYSDEV",RID)
	 S vop3=$G(^DBTBL(vop1,5,vop2,0))
	S PGM=$P(vop3,$C(124),2)
	;
	Q 
	;
DRV	;
	;
	D RPT
	Q 
	;
RPT	;
	;
	N PGM
	;
	I '$D(RID) D ERR Q 
	D GET I PGM="" D ERR Q 
	;
	D ^@PGM
	;
	Q 
	;
QRPT	;
	;
	N ER S ER=0
	N PGM
	;
	Q:'$D(QRID) 
	;
	N dbtbl5q,vop1,vop2,vop3,vop4 S vop1="SYSDEV",vop2=QRID,dbtbl5q=$$vDb5("SYSDEV",QRID,.vop3)
	 S vop4=$G(^DBTBL(vop1,6,vop2,0))
	I '$G(vop3) D ERR Q 
	;
	S PGM=$P(vop4,$C(124),2)
	;
	; If no program, compile and try again
	I PGM="" D
	.	D COMPILE^DBSEXEQ(QRID) Q:ER 
	.	;
	.	N dbtbl5q2,vop5,vop6,vop7 S vop5="SYSDEV",vop6=QRID,dbtbl5q2=$$vDb6("SYSDEV",QRID)
	.	 S vop7=$G(^DBTBL(vop5,6,vop6,0))
	.	;
	.	S PGM=$P(vop7,$C(124),2)
	.	Q 
	;
	I ER!(PGM="") D ERR Q 
	;
	D ^@PGM
	;
	Q 
	;
ERR	; Private
	;
	N ER S ER=1
	N ET S ET="INVLDRPT"
	;
	D DSP^UTLERR
	;
	Q 
	;
vSIG()	;
	Q "59973^70888^Chad Smith^2779" ; Signature - LTD^TIME^USER^SIZE
	;
vDb4(v1,v2)	;	voXN = Db.getRecord(DBTBL5H,,1)
	;
	N dbtbl5h
	S dbtbl5h=$G(^DBTBL(v1,5,v2))
	I dbtbl5h="",'$D(^DBTBL(v1,5,v2))
	;
	Q dbtbl5h
	;
vDb5(v1,v2,v2out)	;	voXN = Db.getRecord(DBTBL5Q,,1,-2)
	;
	N dbtbl5q
	S dbtbl5q=$G(^DBTBL(v1,6,v2))
	I dbtbl5q="",'$D(^DBTBL(v1,6,v2))
	S v2out='$T
	;
	Q dbtbl5q
	;
vDb6(v1,v2)	;	voXN = Db.getRecord(DBTBL5Q,,0)
	;
	N dbtbl5q2
	S dbtbl5q2=$G(^DBTBL(v1,6,v2))
	I dbtbl5q2="",'$D(^DBTBL(v1,6,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL5Q" X $ZT
	Q dbtbl5q2
