USID	; Program name/screen id linkage utility
	;
	; **** Routine compiled from DATA-QWIK Procedure USID ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	;
	I $get(SID)="" S PGM="" Q 
	N mode
	;
	S mode=$get(%O)
	I mode="" S mode=0
	;
	N dbtbl2 S dbtbl2=$$vDb1("SYSDEV",SID)
	 S vobj(dbtbl2,0)=$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0))
	S PGM=$P(vobj(dbtbl2,0),$C(124),2)
	;
	I PGM="" D ^DBSSCR(SID,.PGM)
	S %LINK=$$LINK(.dbtbl2,mode)
	K vobj(+$G(dbtbl2)) Q 
	;
DRV(%O,SID,Obj1,Obj2,Obj3,Obj4,Obj5)	;
	;
	N I
	N PFID N X
	;
	N dbtbl2 S dbtbl2=$$vDb1("SYSDEV",SID)
	 S vobj(dbtbl2,0)=$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0))
	S PFID=$P(vobj(dbtbl2,0),$C(124),1)
	S PGM=$P(vobj(dbtbl2,0),$C(124),2)
	;
	I PGM="" D ^DBSSCR(SID,.PGM) I PGM="" K vobj(+$G(dbtbl2)) Q 
	S %LINK=$$LINK(.dbtbl2,%O)
	;
	S X="^"_PGM_"(%O"
	I PFID'="" F I=1:1:$L(PFID,",") S X=X_",.Obj"_I
	S X=X_")"
	D @X
	K vobj(+$G(dbtbl2)) Q 
	;
LINK(dbtbl2,%O)	;
	 S:'$D(vobj(dbtbl2,"v1")) vobj(dbtbl2,"v1")=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),-1)),1:"")
	;
	N %LINK S %LINK=0
	;
	I $P(vobj(dbtbl2,"v1"),$C(124),1)="" D
	.	I %O=2 S %LINK=1
	.	E  I %O=3 S %LINK=1
	.	Q 
	;
	E  I $P(vobj(dbtbl2,"v1"),$C(124),2)="" S %LINK=1
	E  I $P(vobj(dbtbl2,"v1"),$C(124),3)="" S %LINK=2
	E  I $P(vobj(dbtbl2,"v1"),$C(124),4)="" S %LINK=3
	E  I $P(vobj(dbtbl2,"v1"),$C(124),5)="" S %LINK=4
	E  I $P(vobj(dbtbl2,"v1"),$C(124),6)="" S %LINK=5
	E  I $P(vobj(dbtbl2,"v1"),$C(124),7)="" S %LINK=6
	E  I $P(vobj(dbtbl2,"v1"),$C(124),8)="" S %LINK=7
	E  I $P(vobj(dbtbl2,"v1"),$C(124),9)="" S %LINK=8
	E  I $P(vobj(dbtbl2,"v1"),$C(124),10)="" S %LINK=9
	E  I $P(vobj(dbtbl2,"v1"),$C(124),11)="" S %LINK=10
	E  I $P(vobj(dbtbl2,"v1"),$C(124),12)="" S %LINK=11
	E  I $P(vobj(dbtbl2,"v1"),$C(124),13)="" S %LINK=12
	E  I $P(vobj(dbtbl2,"v1"),$C(124),14)="" S %LINK=13
	E  I $P(vobj(dbtbl2,"v1"),$C(124),15)="" S %LINK=14
	E  I $P(vobj(dbtbl2,"v1"),$C(124),16)="" S %LINK=15
	E  I $P(vobj(dbtbl2,"v1"),$C(124),17)="" S %LINK=16
	E  I $P(vobj(dbtbl2,"v1"),$C(124),18)="" S %LINK=17
	E  I $P(vobj(dbtbl2,"v1"),$C(124),19)="" S %LINK=18
	E  I $P(vobj(dbtbl2,"v1"),$C(124),20)="" S %LINK=19
	E  I $P(vobj(dbtbl2,"v1"),$C(124),21)="" S %LINK=20
	E  I $P(vobj(dbtbl2,"v1"),$C(124),22)="" S %LINK=21
	E  I $P(vobj(dbtbl2,"v1"),$C(124),23)="" S %LINK=22
	E  I $P(vobj(dbtbl2,"v1"),$C(124),24)="" S %LINK=23
	E  I $P(vobj(dbtbl2,"v1"),$C(124),25)="" S %LINK=24
	E  I $P(vobj(dbtbl2,"v1"),$C(124),26)="" S %LINK=25
	E  I $P(vobj(dbtbl2,"v1"),$C(124),27)="" S %LINK=26
	E  I $P(vobj(dbtbl2,"v1"),$C(124),28)="" S %LINK=27
	E  S %LINK=28
	Q %LINK
	;
vSIG()	;
	Q "59922^59214^Dan Russell^3412" ; Signature - LTD^TIME^USER^SIZE
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(DBTBL2,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL2"
	S vobj(vOid)=$G(^DBTBL(v1,2,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,2,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL2" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
