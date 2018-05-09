DBSDI	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSDI ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	S (DLIB,LIB)="SYSDEV"
	I '($D(DFID)#2) S DFID=""
	I '($D(FILES)#2) S FILES=""
	;
	S ER=0
	;
	S DI=X
	S DINAM=""
	S FID=DFID
	;
	I ($E(DI,1)="["),(DI["]") D
	.	;
	.	S FID=$piece($piece(DI,"]",1),"[",2)
	.	S DI=$piece(DI,"]",2)
	.	Q 
	;
	I (FID[".") S FID=$piece(FID,".",2)
	I (FID[",") S FID=$piece(FID,",",2)
	I (FID="") S FID=DFID
	;
	S FID=$$vStrUC(FID)
	S DI=$$vStrUC(DI)
	;
	Q:(FID="") 
	Q:(FID["?") 
	Q:(FID["!") 
	;
	N tableinfo
	;
	S ER=$$getTableInfo(FID,.tableinfo)
	;
	I ER D  Q 
	.	;
	.	; Invalid file name - ~p1
	.	S RM=$$^MSG(1337,FID)
	.	S (LIB,FID,DI)=""
	.	Q 
	;
	I '(FILES=""),'((","_FILES_",")[(","_FID_",")) D  Q 
	.	;
	.	S ER=1
	.	; Invalid file linkage - ~p1
	.	S RM=$$^MSG(1335,FILES)
	.	S (LIB,FID,DI)=""
	.	Q 
	;
	S DFID=FID
	;
	Q:((DI="")!(DI["?")!(DI["!")) 
	;
	N colinfo
	;
	S ER=$$getColInfo(FID,DI,.colinfo)
	;
	I ER D  Q 
	.	;
	.	; Invalid data item - ~p1
	.	S RM=$$^MSG(1298,DI)
	.	S (LIB,FID,DI)=""
	.	Q 
	;
	S DI(1)=$P(colinfo,"|",3)
	S DI(2)=$P(colinfo,"|",7)
	S DI(3)=$P(colinfo,"|",18)
	S DI(4)=$P(colinfo,"|",19)
	S DI(5)=$P(colinfo,"|",20)
	S DI(6)=$P(colinfo,"|",21)
	S DI(7)=$P(colinfo,"|",22)
	S DI(8)=$P(colinfo,"|",23)
	S DI(9)=$P(colinfo,"|",6)
	S DI(10)=$P(colinfo,"|",24)
	S DI(11)=$P(colinfo,"|",25)
	S DI(12)=$P(colinfo,"|",26)
	S DI(13)=$P(colinfo,"|",27)
	S DI(14)=$P(colinfo,"|",8)
	S DI(15)=$P(colinfo,"|",28)
	S DI(16)=$P(colinfo,"|",14)
	S DI(17)=($P(colinfo,"|",15)>0)
	S DI(18)=$P(colinfo,"|",10)_"~"_$P(colinfo,"|",11)_"~"_$P(colinfo,"|",12)_"~"_$P(colinfo,"|",13)
	I (($translate(DI(18),"~","")="")) S DI(18)=""
	S DI(19)=$P(colinfo,"|",29)
	S DI(20)=$P(tableinfo,"|",10)
	S DI(21)=$P(colinfo,"|",4)
	S DI(22)=$P(colinfo,"|",30)
	S DI(23)=$P(colinfo,"|",31)
	;
	S DINAM="["_DLIB_","_DFID_"]"_DI
	S DILNM=DI(10)
	;
	Q 
	;
LIB(file,libr)	;
	;
	N ER
	N return
	;
	I ($get(libr)="") S libr="SYSDEV"
	;
	S return=""
	;
	N tableinfo
	;
	S ER=$$getTableInfo(file,.tableinfo)
	;
	I 'ER S return=libr_","_file
	;
	Q return
	;
STBLER(KEY)	; STBLER.KEY
	N vret
	;
	N stbler S stbler=$G(^STBL("ER",KEY))
	;
	S vret=$P(stbler,$C(124),1)_"|||||"_$P(stbler,$C(124),6) Q vret
	;
STBLXBAD(KEY)	; STBLXBAD.KEY
	N vret
	;
	N stblxbad S stblxbad=$G(^STBL("XBAD",KEY))
	;
	S vret=$P(stblxbad,$C(124),1)_"|||"_$P(stblxbad,$C(124),4) Q vret
	;
STBLSKWD(KEYWORDS)	; Keyword list  /MECH=REFARR:W
	;
	N rs,vos1,vos2,vos3 S rs=$$vOpen1()
	;
	F  Q:'($$vFetch1())  S KEYWORDS($P(rs,$C(9),1))=$P(rs,$C(9),2)
	;
	Q 
	;
XBAD(TDATE,TABLE,AKEYS,ET,data)	;
	;
	N xbad,vop1,vop2,vop3,vop4,vop5 S vop4=TDATE,vop3=TABLE,vop2=AKEYS,vop1=ET,xbad=$$vDb4(TDATE,TABLE,AKEYS,ET,.vop5)
	;
	S $P(xbad,$C(124),1)=$piece(data,"|",1)
	S $P(xbad,$C(124),2)=$piece(data,"|",2)
	S $P(xbad,$C(124),3)=$piece(data,"|",3)
	S $P(xbad,$C(124),4)=$piece(data,"|",4)
	S $P(xbad,$C(124),5)=$piece(data,"|",5)
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^XBAD(vop4,vop3,vop2,vop1)=$$RTBAR^%ZFUNC(xbad) S vop5=1 Tcommit:vTp  
	;
	Q 
	;
getTableInfo(table,tableInfo)	;
	;
	N return S return=0
	;
	D
	.	;
	.	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	.	;
	.	S tableInfo=$$getSchTbl^UCXDD(table)
	.	Q 
	;
	Q return
	;
getColInfo(table,column,colInfo)	;
	;
	N return S return=0
	;
	D
	.	;
	.	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap2^"_$T(+0)_""")"
	.	;
	.	S colInfo=$$getSchCln^UCXDD(table,column)
	.	Q 
	;
	Q return
	;
vSIG()	;
	Q "60340^8519^ASivakumar1^6564" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
	;
vDb4(v1,v2,v3,v4,v2out)	;	voXN = Db.getRecord(XBAD,,1,-2)
	;
	N xbad
	S xbad=$G(^XBAD(v1,v2,v3,v4))
	I xbad="",'$D(^XBAD(v1,v2,v3,v4))
	S v2out='$T
	;
	Q xbad
	;
vOpen1()	;	KEYWORD,DES FROM STBLSYSKEYWD
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=""
vL1a2	S vos2=$O(^STBL("SYSKEYWORDS",vos2),1) I vos2="" G vL1a0
	Q
	;
vFetch1()	;
	;
	I vos1=1 D vL1a2
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos3=$G(^STBL("SYSKEYWORDS",vos2))
	S rs=$S(vos2=$C(254):"",1:vos2)_$C(9)_$P(vos3,"|",1)
	;
	Q 1
	;
vtrap1	;	Error trap
	;
	N error S error=$ZS
	;
	S return=1
	Q 
	;
vtrap2	;	Error trap
	;
	N error S error=$ZS
	;
	S return=1
	Q 
