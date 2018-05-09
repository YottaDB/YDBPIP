V01S311(%O,dbtbl22c)	;DBS -  - SID= <DBTBL22C> DATA-QWIK Aggregate Column definition
	;
	; **** Routine compiled from DATA-QWIK Screen DBTBL22C ****
	;
	; 09/14/2007 10:49 - chenardp
	;
	;;Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/14/2007 10:49 - chenardp
	;
	N KEYS N KVAR N VFSN N VO N VODFT N VPGM N vPSL N VSID N VSNAME
	;
	; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
	;
	S:'($D(%O)#2) %O=5
	I (%O=5) D
	.	I '($D(dbtbl22c)#2) K vobj(+$G(dbtbl22c)) S dbtbl22c=$$vDbNew1("","","")
	.	Q 
	S KVAR="kill %TAB,VFSN,VO,VPTBL,vtab,COL,DELETE" S VSID="DBTBL22C" S VPGM=$T(+0) S VSNAME="DATA-QWIK Aggregate Column definition"
	S VFSN("DBTBL22C")="zdbtbl22c"
	S vPSL=1
	S KEYS(1)=vobj(dbtbl22c,-3)
	S KEYS(2)=vobj(dbtbl22c,-4)
	S KEYS(3)=vobj(dbtbl22c,-5)
	;
	; ==================== Display blank screen         (%O=5)
	;
	I %O=5 D VPR(.dbtbl22c) D VDA1(.dbtbl22c) D ^DBSPNT() Q 
	;
	I '%O D VNEW(.dbtbl22c) D VPR(.dbtbl22c) D VDA1(.dbtbl22c)
	I %O D VLOD(.dbtbl22c) Q:$get(ER)  D VPR(.dbtbl22c) D VDA1(.dbtbl22c)
	;
	; ====================  Display Form
	D ^DBSPNT()
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=XECUTE
	I %O=2!(%O=3) D ^DBSCRT8A XECUTE:'$D(%PAGE) KVAR Q  ; Inquiry/Delete
	; ====================  Set up data entry control table
	;
	I %O<2 D VTAB(.dbtbl22c)
	Q 
	;
VNEW(dbtbl22c)	; Initialize arrays if %O=0
	;
	D VDEF(.dbtbl22c)
	D VLOD(.dbtbl22c)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VDEF(dbtbl22c)	;
	Q:(vobj(dbtbl22c,-3)="")!(vobj(dbtbl22c,-4)="")!(vobj(dbtbl22c,-5)="") 
	Q:%O  S ER=0 I (vobj(dbtbl22c,-3)="")!(vobj(dbtbl22c,-4)="")!(vobj(dbtbl22c,-5)="") S ER=1 S RM=$$^MSG(1767,"%LIBS,AGID,COL") Q 
	 N V1,V2,V3 S V1=vobj(dbtbl22c,-3),V2=vobj(dbtbl22c,-4),V3=vobj(dbtbl22c,-5) I ($D(^DBTBL(V1,22,V2,"C",V3))#2) S ER=1 S RM=$$^MSG(2327) Q 
	I $P(vobj(dbtbl22c),$C(124),3)="" N vSetMf S vSetMf=$P(vobj(dbtbl22c),$C(124),3) S $P(vobj(dbtbl22c),$C(124),3)="SUM",vobj(dbtbl22c,-100,"0*")=""
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
VLOD(dbtbl22c)	; Load data from disc - %O = (1-5)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VPR(dbtbl22c)	; Display screen prompts
	S VO="7||13|0"
	S VO(0)="|0"
	S VO(1)=$C(2,18,13,1,0,0,0,0,0,0)_"01T Column name:"
	S VO(2)=$C(2,48,7,0,0,0,0,0,0,0)_"01TDelete:"
	S VO(3)=$C(3,18,13,1,0,0,0,0,0,0)_"01T Description:"
	S VO(4)=$C(4,12,19,1,0,0,0,0,0,0)_"01T Column Expression:"
	S VO(5)=$C(5,16,15,1,0,0,0,0,0,0)_"01T Function Type:"
	S VO(6)=$C(7,10,21,0,0,0,0,0,0,0)_"01TLink Query to Column:"
	S VO(7)=$C(7,46,31,0,0,0,0,0,0,0)_"01Tor enter SQL Column Query Below"
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VDA1(dbtbl22c)	; Display screen data
	N V
	I %O=5 N COL,DELETE
	I   S (COL,DELETE)=""
	E  S COL=$get(COL) S DELETE=$get(DELETE)
	;
	S COL=$get(COL)
	S DELETE=$get(DELETE)
	;
	S VO="18|8|13|0"
	S VO(8)=$C(2,32,4,2,0,0,0,0,0,0)_"00U"_$get(COL)
	S VO(9)=$C(2,56,1,2,0,0,0,0,0,0)_"00L"_$S($get(DELETE):"Y",1:"N")
	S VO(10)=$C(3,32,40,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(dbtbl22c),$C(124),1)),1,40)
	S VO(11)=$C(4,32,20,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(dbtbl22c),$C(124),4)),1,20)
	S VO(12)=$C(5,32,3,2,0,0,0,0,0,0)_"00U"_$E(($P(vobj(dbtbl22c),$C(124),3)),1,3)
	S VO(13)=$C(7,32,4,2,0,0,0,0,0,0)_"00U"_$E(($P(vobj(dbtbl22c),$C(124),6)),1,4)
	S VO(14)=$C(9,1,80,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(dbtbl22c),$C(124),9)),1,80)
	S VO(15)=$C(10,1,80,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(dbtbl22c),$C(124),10)),1,80)
	S VO(16)=$C(11,1,80,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(dbtbl22c),$C(124),11)),1,80)
	S VO(17)=$C(12,1,80,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(dbtbl22c),$C(124),12)),1,80)
	S VO(18)=$C(13,1,80,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(dbtbl22c),$C(124),13)),1,80)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTAB(dbtbl22c)	;
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
	S %MAX=11 S VPT=2 S VPB=13 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="DBTBL22C"
	S OLNTB=13001
	;
	S VFSN("DBTBL22C")="zdbtbl22c"
	;
	;
	S %TAB(1)=$C(1,31,4)_"01U|*COL|[*]@COL|[DBTBL22C]COL,DES/LE=30,EXP/LE=12,FUN:NOVAL:QU ""AGID=<<AGID>>""|if X?1A.A|do VP1^V01S311(.dbtbl22c)"
	S %TAB(2)=$C(1,55,1)_"00L|*DELETE|[*]@DELETE|,0#Insert,1#Modify,3#Delete||do VP2^V01S311(.dbtbl22c)"
	S %TAB(3)=$C(2,31,40)_"01T12401|1|[DBTBL22C]DES"
	S %TAB(4)=$C(3,31,20)_"01T12404|1|[DBTBL22C]EXP||||do VP3^V01S311(.dbtbl22c)|||||255"
	S %TAB(5)=$C(4,31,3)_"01U12403|1|[DBTBL22C]FUN|,SUM#Sum,MIN#Minimum,MAX#MAximum,AVG#Average,CNT#Count"
	S %TAB(6)=$C(6,31,4)_"00U12406|1|[DBTBL22C]LNK|[DBTBL22C]COL,DES/LE=30,WHR1/LE=30:QU ""AGID=<<AGID>>""||do VP4^V01S311(.dbtbl22c)"
	S %TAB(7)=$C(8,0,80)_"00T12409|1|[DBTBL22C]WHR1"
	S %TAB(8)=$C(9,0,80)_"00T12410|1|[DBTBL22C]WHR2"
	S %TAB(9)=$C(10,0,80)_"00T12411|1|[DBTBL22C]WHR3"
	S %TAB(10)=$C(11,0,80)_"00T12412|1|[DBTBL22C]WHR4"
	S %TAB(11)=$C(12,0,80)_"00T12413|1|[DBTBL22C]WHR5"
	D VTBL(.dbtbl22c)
	D ^DBSCRT8 ; data entry
	Q 
	;
VREQ	; Create REQ() array
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTBL(dbtbl22c)	;Create %TAB(array)
	; 1 2 3  4 5   6   7-9 10-11
	; DY,DX,SZ PT REQ TYPE DEL POS |NODE|ITEM NAME|TBL|FMT|PP|PRE|MIN|MAX|DEC
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
	;user-defined post procs
	;
VP1(dbtbl22c)	;
	;
	Q:(X="") 
	;
	N load22c S load22c=$$vDb1("SYSDEV",vobj(dbtbl22c,-4),X)
	;
	I ($G(vobj(load22c,-2))=1) D
	.	;
	. K vobj(+$G(dbtbl22c)) S dbtbl22c=$$vReCp1(load22c)
	.	S vobj(dbtbl22c,-2)=1
	.	;
	.	D UNPROT^DBSMACRO("@DELETE")
	.	;
	.	D DISPLAY^DBSMACRO("ALL")
	.	Q 
	;
	E  D  ; New column
	.	;
	. S vobj(dbtbl22c,-5)=X
	.	S vobj(dbtbl22c,-2)=0
	.	;
	.	D PROTECT^DBSMACRO("@DELETE")
	.	;
	.	D GOTO^DBSMACRO("[DBTBL22C]DES")
	.	Q 
	;
	K vobj(+$G(load22c)) Q 
VP2(dbtbl22c)	;
	;
	Q:(X=0) 
	;
	D GOTO^DBSMACRO("END")
	;
	Q 
VP3(dbtbl22c)	;
	;
	N dbtbl22 S dbtbl22=$$vDb3("SYSDEV",vobj(dbtbl22c,-4))
	;
	D CHANGE^DBSMACRO("TBL","[DBTBL1D]DI,DES:NOVAL:QU ""DBTBL1D.FID=<<FILE>>""")
	;
	Q 
VP4(dbtbl22c)	;
	;
	Q:(X="") 
	;
	D DELETE^DBSMACRO("[DBTBL22C]WHR1")
	D DELETE^DBSMACRO("DBTBL22C.WHR2")
	D DELETE^DBSMACRO("DBTBL22C.WHR3")
	;
	D GOTO^DBSMACRO("END")
	;
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VRV(V,L)	;
	Q V_$J("",L-$L(V))
VREPRNT	;
	D VPR(.dbtbl22c)
	D VDA1(.dbtbl22c)
	D ^DBSPNT()
	Q 
	;
VW(dbtbl22c)	;
	D VDA1(.dbtbl22c)
	D ^DBSPNT(10)
	Q 
	;
VDAPNT(dbtbl22c)	;
	D VDA1(.dbtbl22c)
	D ^DBSPNT(0,2)
	Q 
	;
VDA	;
	D VDA1(.dbtbl22c)
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
vSET(sn,di,X)	;
	I sn="DBTBL22C" D vSET1(.dbtbl22c,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
vSET1(dbtbl22c,di,X)	;
	D vCoInd1(dbtbl22c,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di)	;
	I fid="DBTBL22C" Q $$vREAD1(.dbtbl22c,di)
	Q ""
vREAD1(dbtbl22c,di)	;
	Q $$vCoInd2(dbtbl22c,di)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS1(vRec,vVal)	; RecordDBTBL22C.setDES(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",1)
	S $P(vobj(vRec),"|",1)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS2(vRec,vVal)	; RecordDBTBL22C.setEXP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",4)
	S $P(vobj(vRec),"|",4)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS3(vRec,vVal)	; RecordDBTBL22C.setFUN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",3)
	S $P(vobj(vRec),"|",3)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS4(vRec,vVal)	; RecordDBTBL22C.setLNK(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",6)
	S $P(vobj(vRec),"|",6)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS5(vRec,vVal)	; RecordDBTBL22C.setWHR1(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",9)
	S $P(vobj(vRec),"|",9)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS6(vRec,vVal)	; RecordDBTBL22C.setWHR2(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",10)
	S $P(vobj(vRec),"|",10)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS7(vRec,vVal)	; RecordDBTBL22C.setWHR3(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",11)
	S $P(vobj(vRec),"|",11)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS8(vRec,vVal)	; RecordDBTBL22C.setWHR4(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",12)
	S $P(vobj(vRec),"|",12)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS9(vRec,vVal)	; RecordDBTBL22C.setWHR5(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",13)
	S $P(vobj(vRec),"|",13)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vStrGSub(object,tag,del1,del2,pos)	; String.getSub passing Numbers
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I (pos="") S pos=1
	I (tag=""),(del1="") Q $E(object,pos)
	S del1=$CHAR(del1)
	I (tag="") Q $piece(object,del1,pos)
	S del2=$CHAR(del2)
	I del1=del2,pos>1 S $ZS="-1,"_$ZPOS_","_"%PSL-E-STRGETSUB" X $ZT
	Q $piece($piece($piece((del1_object),del1_tag_del2,2),del1,1),del2,pos)
	; ----------------
	;  #OPTION ResultClass 0
vStrPSub(object,ins,tag,del1,del2,pos)	; String.putSub passing Numbers
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I (pos="") S pos=1
	I (tag=""),(del1="") S $E(object,pos)=ins Q object
	S del1=$CHAR(del1)
	I (tag="") S $piece(object,del1,pos)=ins Q $$RTCHR^%ZFUNC(object,del1)
	S del2=$CHAR(del2)
	I del1=del2,pos>1 S $ZS="-1,"_$ZPOS_","_"%PSL-E-STRPUTSUB" X $ZT
	I (object="") S $piece(object,del2,pos)=ins Q tag_del2_object
	N field S field=$piece($piece((del1_object),(del1_tag_del2),2),del1,1)
	I '(field="") D
	.	N z S z=del1_tag_del2_field
	.	S object=$piece((del1_object),z,1)_$piece((del1_object),z,2)
	.	I $E(object,1)=del1 S object=$E(object,2,1048575)
	.	Q 
	S $piece(field,del2,pos)=ins
	I (object="") Q tag_del2_field
	Q object_del1_tag_del2_field
	; ----------------
	;  #OPTION ResultClass 0
vCoInd1(vOid,vCol,vVal)	; RecordDBTBL22C.setColumn(1,0)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("DBTBL22C",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	N vTyp S vTyp=$P(vP,"|",6)
	I vNod["*" S vPos=-$P(vP,"|",4)-2 S:'($D(vobj(vOid,-100,$P(vP,"|",4)_"*",vCol))#2) vobj(vOid,-100,$P(vP,"|",4)_"*",vCol)=vTyp_"000"_vobj(vOid,vPos) S vobj(vOid,vPos)=vVal Q 
	;
	S vPos=$P(vP,"|",4)
	I vCol="DES" D vCoMfS1(vOid,vVal) Q 
	I vCol="EXP" D vCoMfS2(vOid,vVal) Q 
	I vCol="FUN" D vCoMfS3(vOid,vVal) Q 
	I vCol="LNK" D vCoMfS4(vOid,vVal) Q 
	I vCol="WHR1" D vCoMfS5(vOid,vVal) Q 
	I vCol="WHR2" D vCoMfS6(vOid,vVal) Q 
	I vCol="WHR3" D vCoMfS7(vOid,vVal) Q 
	I vCol="WHR4" D vCoMfS8(vOid,vVal) Q 
	I vCol="WHR5" D vCoMfS9(vOid,vVal) Q 
	N vOldNod S vOldNod=$$getOldNode^UCXDD(vP,0)
	N vOld S vOld=$piece(vobj(vOid),"|",vPos)
	I '($P(vP,"|",13)="") S vOld=$$vStrGSub(vOld,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	I '$D(vobj(vOid,-100,vOldNod,vCol)) S vobj(vOid,-100,vOldNod,vCol)=vTyp_$E(1000+vPos,2,4)_vOld
	I '($P(vP,"|",13)="") S vVal=$$vStrPSub($piece(vobj(vOid),"|",vPos),vVal,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	S $piece(vobj(vOid),"|",vPos)=vVal
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoInd2(vOid,vCol)	; RecordDBTBL22C.getColumn()
	N vret
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("DBTBL22C",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	I vNod["*" S vret=$get(vobj(vOid,-$P(vP,"|",4)-2)) Q vret
	;
	S vPos=$P(vP,"|",4)
	N vRet
	S vRet=vobj(vOid)
	S vRet=$piece(vRet,"|",vPos)
	I '($P(vP,"|",13)="") Q $$getSf^UCCOLSF(vRet,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	Q vRet
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
	;
vDb1(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL22C,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL22C"
	S vobj(vOid)=$G(^DBTBL(v1,22,v2,"C",v3))
	I vobj(vOid)="",'$D(^DBTBL(v1,22,v2,"C",v3))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDb3(v1,v2)	;	voXN = Db.getRecord(DBTBL22,,0)
	;
	N dbtbl22
	S dbtbl22=$G(^DBTBL(v1,22,v2))
	I dbtbl22="",'$D(^DBTBL(v1,22,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL22" X $ZT
	Q dbtbl22
	;
vDbNew1(v1,v2,v3)	;	vobj()=Class.new(DBTBL22C)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL22C",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vReCp1(v1)	;	RecordDBTBL22C.copy: DBTBL22C
	;
	Q $$copy^UCGMR(load22c)
