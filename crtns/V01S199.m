V01S199(%O,dbtbl22)	; -  - SID= <DBTBL22> DATA-QWIK Aggregate Definition (Master)
	;
	; **** Routine compiled from DATA-QWIK Screen DBTBL22 ****
	;
	; 09/14/2007 08:41 - chenardp
	;
	;;Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/14/2007 08:41 - chenardp
	;
	N KEYS N KVAR N VFSN N VO N VODFT N VPGM N vPSL N VSID N VSNAME
	;
	; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
	;
	S:'($D(%O)#2) %O=5
	I (%O=5) D
	.	I '($D(dbtbl22)#2) K vobj(+$G(dbtbl22)) S dbtbl22=$$vDbNew1("","")
	.	Q 
	S KVAR="kill %TAB,VFSN,VO,VPTBL,vtab" S VSID="DBTBL22" S VPGM=$T(+0) S VSNAME="DATA-QWIK Aggregate Definition (Master)"
	S VFSN("DBTBL22")="zdbtbl22"
	S vPSL=1
	S KEYS(1)=vobj(dbtbl22,-3)
	S KEYS(2)=vobj(dbtbl22,-4)
	;
	; ==================== Display blank screen         (%O=5)
	;
	I %O=5 D VPR(.dbtbl22) D VDA1(.dbtbl22) D ^DBSPNT() Q 
	;
	I '%O D VNEW(.dbtbl22) D VPR(.dbtbl22) D VDA1(.dbtbl22)
	I %O D VLOD(.dbtbl22) Q:$get(ER)  D VPR(.dbtbl22) D VDA1(.dbtbl22)
	;
	; ====================  Display Form
	D ^DBSPNT()
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=XECUTE
	I %O=2!(%O=3) D ^DBSCRT8A XECUTE:'$D(%PAGE) KVAR Q  ; Inquiry/Delete
	; ====================  Set up data entry control table
	;
	I %O<2 D VTAB(.dbtbl22)
	Q 
	;
VNEW(dbtbl22)	; Initialize arrays if %O=0
	;
	D VDEF(.dbtbl22)
	D VLOD(.dbtbl22)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VDEF(dbtbl22)	;
	Q:(vobj(dbtbl22,-3)="")!(vobj(dbtbl22,-4)="") 
	Q:%O  S ER=0 I (vobj(dbtbl22,-3)="")!(vobj(dbtbl22,-4)="") S ER=1 S RM=$$^MSG(1767,"%LIBS,AGID") Q 
	 N V1,V2 S V1=vobj(dbtbl22,-3),V2=vobj(dbtbl22,-4) I ($D(^DBTBL(V1,22,V2))#2) S ER=1 S RM=$$^MSG(2327) Q 
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
VLOD(dbtbl22)	; Load data from disc - %O = (1-5)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VPR(dbtbl22)	; Display screen prompts
	S VO="8||13|0"
	S VO(0)="|0"
	S VO(1)=$C(2,13,16,0,0,0,0,0,0,0)_"01T Aggregate Name:"
	S VO(2)=$C(3,16,13,1,0,0,0,0,0,0)_"01T Description:"
	S VO(3)=$C(4,16,13,1,0,0,0,0,0,0)_"01T Select From:"
	S VO(4)=$C(5,19,10,0,0,0,0,0,0,0)_"01T Group By:"
	S VO(5)=$C(6,15,14,0,0,0,0,0,0,0)_"01T Routine Name:"
	S VO(6)=$C(7,13,16,0,0,0,0,0,0,0)_"01T Extract Detail:"
	S VO(7)=$C(8,12,17,0,0,0,0,0,0,0)_"01T Date Key Option:"
	S VO(8)=$C(10,26,21,0,0,0,0,0,0,0)_"01TEnter SQL Query Below"
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VDA1(dbtbl22)	; Display screen data
	N V
	I %O=5 N AGID
	I   S (AGID)=""
	E  S AGID=$get(AGID)
	;
	S AGID=$get(AGID)
	;
	S VO="20|9|13|0"
	S VO(9)=$C(2,30,12,2,0,0,0,0,0,0)_"01T"_$get(AGID)
	S VO(10)=$C(3,30,40,0,0,0,0,0,0,0)_"00T"_$E(($P(vobj(dbtbl22),$C(124),1)),1,40)
	S VO(11)=$C(4,30,40,0,0,0,0,0,0,0)_"00U"_$E(($P(vobj(dbtbl22),$C(124),3)),1,40)
	S VO(12)=$C(5,30,40,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(dbtbl22),$C(124),7)),1,40)
	S VO(13)=$C(6,30,8,2,0,0,0,0,0,0)_"01T"_$E(($P(vobj(dbtbl22),$C(124),4)),1,8)
	S VO(14)=$C(7,30,1,0,0,0,0,0,0,0)_"00L"_$S($P(vobj(dbtbl22),$C(124),5):"Y",1:"N")
	S VO(15)=$C(8,30,1,0,0,0,0,0,0,0)_"00N"_$P(vobj(dbtbl22),$C(124),6)
	S VO(16)=$C(12,1,80,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(dbtbl22),$C(124),9)),1,80)
	S VO(17)=$C(13,1,80,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(dbtbl22),$C(124),10)),1,80)
	S VO(18)=$C(14,1,80,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(dbtbl22),$C(124),11)),1,80)
	S VO(19)=$C(15,1,80,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(dbtbl22),$C(124),12)),1,80)
	S VO(20)=$C(16,1,80,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(dbtbl22),$C(124),13)),1,80)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTAB(dbtbl22)	;
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
	S %MAX=12 S VPT=2 S VPB=16 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="DBTBL22"
	S OLNTB=16001
	;
	S VFSN("DBTBL22")="zdbtbl22"
	;
	;
	S %TAB(1)=$C(1,29,12)_"20T|*AGID|[*]@AGID"
	S %TAB(2)=$C(2,29,40)_"01T12401|1|[DBTBL22]DES"
	S %TAB(3)=$C(3,29,40)_"01U12403|1|[DBTBL22]FRM|||do VP1^V01S199(.dbtbl22)|do VP2^V01S199(.dbtbl22)"
	S %TAB(4)=$C(4,29,40)_"00T12407|1|[DBTBL22]GRP|||do VP3^V01S199(.dbtbl22)|do VP4^V01S199(.dbtbl22)"
	S %TAB(5)=$C(5,29,8)_"20T12404|1|[DBTBL22]RTN"
	S %TAB(6)=$C(6,29,1)_"00L12405|1|[DBTBL22]DTL"
	S %TAB(7)=$C(7,29,1)_"00N12406|1|[DBTBL22]DTP|,0#No Date,1#Calendar Date,2#System Date (CUVAR.TJD)||do VP5^V01S199(.dbtbl22)"
	S %TAB(8)=$C(11,0,80)_"00T12409|1|[DBTBL22]WHR1"
	S %TAB(9)=$C(12,0,80)_"00T12410|1|[DBTBL22]WHR2"
	S %TAB(10)=$C(13,0,80)_"00T12411|1|[DBTBL22]WHR3"
	S %TAB(11)=$C(14,0,80)_"00T12412|1|[DBTBL22]WHR4"
	S %TAB(12)=$C(15,0,80)_"00T12413|1|[DBTBL22]WHR5"
	D VTBL(.dbtbl22)
	D ^DBSCRT8 ; data entry
	Q 
	;
VREQ	; Create REQ() array
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTBL(dbtbl22)	;Create %TAB(array)
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
VP1(dbtbl22)	;
	; Validate file relationships
	;
	N %LIBS N FILES
	;
	S %LIBS="SYSDEV"
	;
	S FILES=X
	;
	D ^DBSFVER ; Will return ER and RM if problems
	;
	Q 
VP2(dbtbl22)	;
	D CHANGE^DBSMACRO("TBL","[DBTBL1]FID,DES:LIST")
	;
	Q 
VP3(dbtbl22)	;
	;
	S ER=0
	;
	; Check to see if valid columns in some table
	I '(X="") D  Q:ER 
	.	;
	.	N I
	.	N FRM
	.	;
	.	S FRM=$P(vobj(dbtbl22),$C(124),3)
	.	;
	.	F I=1:1:$L(X,",") D  Q:ER 
	..		;
	..		N HIT S HIT=0
	..		N J
	..		N COL
	..		;
	..		S COL=$piece(X,",",I)
	..		;
	..		F J=1:1:$L(FRM,",") D  Q:HIT 
	...			;
	...			N TABLE
	...			;
	...			S TABLE=$piece(FRM,",",J)
	...			;
	...			N dbtbl1d,vop1 S dbtbl1d=$$vDb2("SYSDEV",TABLE,COL,.vop1)
	...			;
	...			I ($G(vop1)=1) S HIT=1
	...			;
	...			Q 
	..		;
	..		I 'HIT D
	...			;
	...			S ER=1
	...			; Invalid column name ~p1
	...			S RM=$$^MSG(1286,COL)
	...			Q 
	..		Q 
	.	Q 
	;
	; Check to make sure, if GRP changed, there is no data in tables
	Q:(%O=0) 
	;
	Q:(X=V)  ; No changes
	;
	; See if data in MATRIX* tables - can't change GRP if there is data
	D CHKDATA^DBSAG(vobj(dbtbl22,-4))
	;
	Q 
	;
VP4(dbtbl22)	;
	;
	S FILE=$piece($P(vobj(dbtbl22),$C(124),3),",",1)
	;
	D CHANGE^DBSMACRO("TBL","[DBTBL1D]DI,DES:LIST:NOVAL:QU ""DBTBL1D.FID=<<FILE>>""")
	;
	Q 
VP5(dbtbl22)	;
	;
	Q:(%O=0) 
	;
	Q:(+X=+V)  ; No changes
	;
	; See if data in MATRIX* tables
	D CHKDATA^DBSAG(vobj(dbtbl22,-4))
	;
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VRV(V,L)	;
	Q V_$J("",L-$L(V))
VREPRNT	;
	D VPR(.dbtbl22)
	D VDA1(.dbtbl22)
	D ^DBSPNT()
	Q 
	;
VW(dbtbl22)	;
	D VDA1(.dbtbl22)
	D ^DBSPNT(10)
	Q 
	;
VDAPNT(dbtbl22)	;
	D VDA1(.dbtbl22)
	D ^DBSPNT(0,2)
	Q 
	;
VDA	;
	D VDA1(.dbtbl22)
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
vSET(sn,di,X)	;
	I sn="DBTBL22" D vSET1(.dbtbl22,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
vSET1(dbtbl22,di,X)	;
	D vCoInd1(dbtbl22,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di)	;
	I fid="DBTBL22" Q $$vREAD1(.dbtbl22,di)
	Q ""
vREAD1(dbtbl22,di)	;
	Q $$vCoInd2(dbtbl22,di)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS1(vRec,vVal)	; RecordDBTBL22.setDES(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",1)
	S $P(vobj(vRec),"|",1)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS2(vRec,vVal)	; RecordDBTBL22.setDTL(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",5)
	S $P(vobj(vRec),"|",5)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS3(vRec,vVal)	; RecordDBTBL22.setDTP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",6)
	S $P(vobj(vRec),"|",6)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS4(vRec,vVal)	; RecordDBTBL22.setFRM(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",3)
	S $P(vobj(vRec),"|",3)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS5(vRec,vVal)	; RecordDBTBL22.setGRP(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",7)
	S $P(vobj(vRec),"|",7)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS6(vRec,vVal)	; RecordDBTBL22.setRTN(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",4)
	S $P(vobj(vRec),"|",4)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS7(vRec,vVal)	; RecordDBTBL22.setWHR1(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",9)
	S $P(vobj(vRec),"|",9)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS8(vRec,vVal)	; RecordDBTBL22.setWHR2(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",10)
	S $P(vobj(vRec),"|",10)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS9(vRec,vVal)	; RecordDBTBL22.setWHR3(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",11)
	S $P(vobj(vRec),"|",11)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS10(vRec,vVal)	; RecordDBTBL22.setWHR4(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",12)
	S $P(vobj(vRec),"|",12)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS11(vRec,vVal)	; RecordDBTBL22.setWHR5(1)
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
vCoInd1(vOid,vCol,vVal)	; RecordDBTBL22.setColumn(1,0)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("DBTBL22",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	N vTyp S vTyp=$P(vP,"|",6)
	I vNod["*" S vPos=-$P(vP,"|",4)-2 S:'($D(vobj(vOid,-100,$P(vP,"|",4)_"*",vCol))#2) vobj(vOid,-100,$P(vP,"|",4)_"*",vCol)=vTyp_"000"_vobj(vOid,vPos) S vobj(vOid,vPos)=vVal Q 
	;
	S vPos=$P(vP,"|",4)
	I vCol="DES" D vCoMfS1(vOid,vVal) Q 
	I vCol="DTL" D vCoMfS2(vOid,vVal) Q 
	I vCol="DTP" D vCoMfS3(vOid,vVal) Q 
	I vCol="FRM" D vCoMfS4(vOid,vVal) Q 
	I vCol="GRP" D vCoMfS5(vOid,vVal) Q 
	I vCol="RTN" D vCoMfS6(vOid,vVal) Q 
	I vCol="WHR1" D vCoMfS7(vOid,vVal) Q 
	I vCol="WHR2" D vCoMfS8(vOid,vVal) Q 
	I vCol="WHR3" D vCoMfS9(vOid,vVal) Q 
	I vCol="WHR4" D vCoMfS10(vOid,vVal) Q 
	I vCol="WHR5" D vCoMfS11(vOid,vVal) Q 
	N vOldNod S vOldNod=$$getOldNode^UCXDD(vP,0)
	N vOld S vOld=$piece(vobj(vOid),"|",vPos)
	I '($P(vP,"|",13)="") S vOld=$$vStrGSub(vOld,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	I '$D(vobj(vOid,-100,vOldNod,vCol)) S vobj(vOid,-100,vOldNod,vCol)=vTyp_$E(1000+vPos,2,4)_vOld
	I '($P(vP,"|",13)="") S vVal=$$vStrPSub($piece(vobj(vOid),"|",vPos),vVal,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	S $piece(vobj(vOid),"|",vPos)=vVal
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoInd2(vOid,vCol)	; RecordDBTBL22.getColumn()
	N vret
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("DBTBL22",$$vStrUC(vCol))
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
vDb2(v1,v2,v3,v2out)	;	voXN = Db.getRecord(DBTBL1D,,1,-2)
	;
	N dbtbl1d
	S dbtbl1d=$G(^DBTBL(v1,1,v2,9,v3))
	I dbtbl1d="",'$D(^DBTBL(v1,1,v2,9,v3))
	S v2out='$T
	;
	Q dbtbl1d
	;
vDbNew1(v1,v2)	;	vobj()=Class.new(DBTBL22)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL22",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
