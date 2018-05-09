 ; 
 ; **** Routine compiled from DATA-QWIK Procedure USID ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
 ; Program name/screen id linkage utility
 ;
 I $get(SID)="" S PGM="" Q 
 N mode
 ;
 S mode=$get(%O)
 I mode="" S mode=0
 ;
 N dbtbl2 S dbtbl2=$$vRCgetRecord0^RecordDBTBL2("SYSDEV",SID,0)
  S vobj(dbtbl2,0)=$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0))
 S PGM=$P(vobj(dbtbl2,0),$C(124),2)
 ;
 I PGM="" D ^DBSSCR(SID,.PGM)
 S %LINK=$$LINK(.dbtbl2,mode)
 K vobj(+$G(dbtbl2)) Q 
 ;
DRV(%O,SID,Obj1,Obj2,Obj3,Obj4,Obj5) ; 
 ;
 N I
 N PFID N X
 ;
 N dbtbl2 S dbtbl2=$$vRCgetRecord0^RecordDBTBL2("SYSDEV",SID,0)
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
LINK(dbtbl2,%O) ; 
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
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "59922^59214^Dan Russell^3454" ; Signature - LTD^TIME^USER^SIZE
