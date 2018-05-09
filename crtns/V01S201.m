V01S201(%O,dbtbl22r)	; -  - SID= <DBTBL22R> DATA-QWIK Row Definition
	;
	; **** Routine compiled from DATA-QWIK Screen DBTBL22R ****
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
	.	I '($D(dbtbl22r)#2) K vobj(+$G(dbtbl22r)) S dbtbl22r=$$vDbNew1("","","")
	.	Q 
	S KVAR="kill %TAB,VFSN,VO,VPTBL,vtab,ROW,DELETE" S VSID="DBTBL22R" S VPGM=$T(+0) S VSNAME="DATA-QWIK Row Definition"
	S VFSN("DBTBL22R")="zdbtbl22r"
	S vPSL=1
	S KEYS(1)=vobj(dbtbl22r,-3)
	S KEYS(2)=vobj(dbtbl22r,-4)
	S KEYS(3)=vobj(dbtbl22r,-5)
	;
	; ==================== Display blank screen         (%O=5)
	;
	I %O=5 D VPR(.dbtbl22r) D VDA1(.dbtbl22r) D ^DBSPNT() Q 
	;
	I '%O D VNEW(.dbtbl22r) D VPR(.dbtbl22r) D VDA1(.dbtbl22r)
	I %O D VLOD(.dbtbl22r) Q:$get(ER)  D VPR(.dbtbl22r) D VDA1(.dbtbl22r)
	;
	; ====================  Display Form
	D ^DBSPNT()
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=XECUTE
	I %O=2!(%O=3) D ^DBSCRT8A XECUTE:'$D(%PAGE) KVAR Q  ; Inquiry/Delete
	; ====================  Set up data entry control table
	;
	I %O<2 D VTAB(.dbtbl22r)
	Q 
	;
VNEW(dbtbl22r)	; Initialize arrays if %O=0
	;
	D VDEF(.dbtbl22r)
	D VLOD(.dbtbl22r)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VDEF(dbtbl22r)	;
	Q:(vobj(dbtbl22r,-3)="")!(vobj(dbtbl22r,-4)="")!(vobj(dbtbl22r,-5)="") 
	Q:%O  S ER=0 I (vobj(dbtbl22r,-3)="")!(vobj(dbtbl22r,-4)="")!(vobj(dbtbl22r,-5)="") S ER=1 S RM=$$^MSG(1767,"%LIBS,AGID,ROW") Q 
	 N V1,V2,V3 S V1=vobj(dbtbl22r,-3),V2=vobj(dbtbl22r,-4),V3=vobj(dbtbl22r,-5) I ($D(^DBTBL(V1,22,V2,"R",V3))#2) S ER=1 S RM=$$^MSG(2327) Q 
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
VLOD(dbtbl22r)	; Load data from disc - %O = (1-5)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VPR(dbtbl22r)	; Display screen prompts
	S VO="4||13|0"
	S VO(0)="|0"
	S VO(1)=$C(2,17,12,1,0,0,0,0,0,0)_"01T Row Number:"
	S VO(2)=$C(2,43,7,0,0,0,0,0,0,0)_"01TDelete:"
	S VO(3)=$C(3,16,13,1,0,0,0,0,0,0)_"01T Description:"
	S VO(4)=$C(6,19,35,0,0,0,0,0,0,0)_"01TEnter SQL Row Selection Query Below"
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VDA1(dbtbl22r)	; Display screen data
	N V
	I %O=5 N DELETE,ROW
	I   S (DELETE,ROW)=""
	E  S DELETE=$get(DELETE) S ROW=$get(ROW)
	;
	S DELETE=$get(DELETE)
	S ROW=$get(ROW)
	;
	S VO="12|5|13|0"
	S VO(5)=$C(2,30,4,2,0,0,0,0,0,0)_"00N"_$get(ROW)
	S VO(6)=$C(2,51,1,2,0,0,0,0,0,0)_"00L"_$S($get(DELETE):"Y",1:"N")
	S VO(7)=$C(3,30,40,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(dbtbl22r),$C(124),1)),1,40)
	S VO(8)=$C(8,1,80,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(dbtbl22r),$C(124),3)),1,80)
	S VO(9)=$C(9,1,80,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(dbtbl22r),$C(124),4)),1,80)
	S VO(10)=$C(10,1,80,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(dbtbl22r),$C(124),5)),1,80)
	S VO(11)=$C(11,1,80,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(dbtbl22r),$C(124),6)),1,80)
	S VO(12)=$C(12,1,80,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(dbtbl22r),$C(124),7)),1,80)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTAB(dbtbl22r)	;
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
	S %MAX=8 S VPT=2 S VPB=12 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="DBTBL22R"
	S OLNTB=12001
	;
	S VFSN("DBTBL22R")="zdbtbl22r"
	;
	;
	S %TAB(1)=$C(1,29,4)_"01N|*ROW|[*]@ROW|[DBTBL22R]ROW,DES/LE=30,WHR1/LE=20:NOVAL:QU ""AGID=<<AGID>>""||do VP1^V01S201(.dbtbl22r)"
	S %TAB(2)=$C(1,50,1)_"00L|*DELETE|[*]@DELETE|,0#Insert,1#Modify,3#Delete||do VP2^V01S201(.dbtbl22r)"
	S %TAB(3)=$C(2,29,40)_"01T12401|1|[DBTBL22R]DES"
	S %TAB(4)=$C(7,0,80)_"00T12403|1|[DBTBL22R]WHR1"
	S %TAB(5)=$C(8,0,80)_"00T12404|1|[DBTBL22R]WHR2"
	S %TAB(6)=$C(9,0,80)_"00T12405|1|[DBTBL22R]WHR3"
	S %TAB(7)=$C(10,0,80)_"00T12406|1|[DBTBL22R]WHR4"
	S %TAB(8)=$C(11,0,80)_"00T12407|1|[DBTBL22R]WHR5"
	D VTBL(.dbtbl22r)
	D ^DBSCRT8 ; data entry
	Q 
	;
VREQ	; Create REQ() array
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTBL(dbtbl22r)	;Create %TAB(array)
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
VP1(dbtbl22r)	;
	;
	Q:(X="") 
	;
	N load22r S load22r=$$vDb1("SYSDEV",vobj(dbtbl22r,-4),X)
	;
	I ($G(vobj(load22r,-2))=1) D
	.	;
	. K vobj(+$G(dbtbl22r)) S dbtbl22r=$$vReCp1(load22r)
	.	S vobj(dbtbl22r,-2)=1
	.	;
	.	D UNPROT^DBSMACRO("@DELETE")
	.	;
	.	D DISPLAY^DBSMACRO("ALL")
	.	Q 
	;
	E  D  ; New row
	.	;
	. S vobj(dbtbl22r,-5)=X
	.	S vobj(dbtbl22r,-2)=0
	.	;
	.	D PROTECT^DBSMACRO("@DELETE")
	.	;
	.	D GOTO^DBSMACRO("[DBTBL22R]DES")
	.	Q 
	;
	K vobj(+$G(load22r)) Q 
VP2(dbtbl22r)	;
	;
	Q:(X=0) 
	;
	D GOTO^DBSMACRO("END")
	;
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VRV(V,L)	;
	Q V_$J("",L-$L(V))
VREPRNT	;
	D VPR(.dbtbl22r)
	D VDA1(.dbtbl22r)
	D ^DBSPNT()
	Q 
	;
VW(dbtbl22r)	;
	D VDA1(.dbtbl22r)
	D ^DBSPNT(10)
	Q 
	;
VDAPNT(dbtbl22r)	;
	D VDA1(.dbtbl22r)
	D ^DBSPNT(0,2)
	Q 
	;
VDA	;
	D VDA1(.dbtbl22r)
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
vSET(sn,di,X)	;
	I sn="DBTBL22R" D vSET1(.dbtbl22r,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
vSET1(dbtbl22r,di,X)	;
	D vCoInd1(dbtbl22r,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di)	;
	I fid="DBTBL22R" Q $$vREAD1(.dbtbl22r,di)
	Q ""
vREAD1(dbtbl22r,di)	;
	Q $$vCoInd2(dbtbl22r,di)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS1(vRec,vVal)	; RecordDBTBL22R.setDES(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",1)
	S $P(vobj(vRec),"|",1)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS2(vRec,vVal)	; RecordDBTBL22R.setWHR1(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",3)
	S $P(vobj(vRec),"|",3)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS3(vRec,vVal)	; RecordDBTBL22R.setWHR2(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",4)
	S $P(vobj(vRec),"|",4)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS4(vRec,vVal)	; RecordDBTBL22R.setWHR3(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",5)
	S $P(vobj(vRec),"|",5)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS5(vRec,vVal)	; RecordDBTBL22R.setWHR4(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",6)
	S $P(vobj(vRec),"|",6)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS6(vRec,vVal)	; RecordDBTBL22R.setWHR5(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",7)
	S $P(vobj(vRec),"|",7)=vVal S vobj(vRec,-100,"0*")=""
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
vCoInd1(vOid,vCol,vVal)	; RecordDBTBL22R.setColumn(1,0)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("DBTBL22R",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	N vTyp S vTyp=$P(vP,"|",6)
	I vNod["*" S vPos=-$P(vP,"|",4)-2 S:'($D(vobj(vOid,-100,$P(vP,"|",4)_"*",vCol))#2) vobj(vOid,-100,$P(vP,"|",4)_"*",vCol)=vTyp_"000"_vobj(vOid,vPos) S vobj(vOid,vPos)=vVal Q 
	;
	S vPos=$P(vP,"|",4)
	I vCol="DES" D vCoMfS1(vOid,vVal) Q 
	I vCol="WHR1" D vCoMfS2(vOid,vVal) Q 
	I vCol="WHR2" D vCoMfS3(vOid,vVal) Q 
	I vCol="WHR3" D vCoMfS4(vOid,vVal) Q 
	I vCol="WHR4" D vCoMfS5(vOid,vVal) Q 
	I vCol="WHR5" D vCoMfS6(vOid,vVal) Q 
	N vOldNod S vOldNod=$$getOldNode^UCXDD(vP,0)
	N vOld S vOld=$piece(vobj(vOid),"|",vPos)
	I '($P(vP,"|",13)="") S vOld=$$vStrGSub(vOld,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	I '$D(vobj(vOid,-100,vOldNod,vCol)) S vobj(vOid,-100,vOldNod,vCol)=vTyp_$E(1000+vPos,2,4)_vOld
	I '($P(vP,"|",13)="") S vVal=$$vStrPSub($piece(vobj(vOid),"|",vPos),vVal,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	S $piece(vobj(vOid),"|",vPos)=vVal
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoInd2(vOid,vCol)	; RecordDBTBL22R.getColumn()
	N vret
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("DBTBL22R",$$vStrUC(vCol))
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
vDb1(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL22R,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL22R"
	S vobj(vOid)=$G(^DBTBL(v1,22,v2,"R",v3))
	I vobj(vOid)="",'$D(^DBTBL(v1,22,v2,"R",v3))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDbNew1(v1,v2,v3)	;	vobj()=Class.new(DBTBL22R)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL22R",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vReCp1(v1)	;	RecordDBTBL22R.copy: DBTBL22R
	;
	Q $$copy^UCGMR(load22r)
