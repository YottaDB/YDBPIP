V01S202(%O,fDBTBL25)	; -  - SID= <DBTBL25> Procedure Definition
	;
	; **** Routine compiled from DATA-QWIK Screen DBTBL25 ****
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
	.	I '($D(fDBTBL25)#2) K vobj(+$G(fDBTBL25)) S fDBTBL25=$$vDbNew1("","")
	.	Q 
	S KVAR="kill %TAB,VFSN,VO,VPTBL,vtab" S VSID="DBTBL25" S VPGM=$T(+0) S VSNAME="Procedure Definition"
	S VFSN("DBTBL25")="zfDBTBL25"
	S vPSL=1
	S KEYS(1)=vobj(fDBTBL25,-3)
	S KEYS(2)=vobj(fDBTBL25,-4)
	;
	; ==================== Display blank screen         (%O=5)
	;
	I %O=5 D VPR(.fDBTBL25) D VDA1(.fDBTBL25) D ^DBSPNT() Q 
	;
	S ER=0 D VSCRPRE(.fDBTBL25) I ER Q  ; Screen Pre-Processor
	;
	I '%O D VNEW(.fDBTBL25) D VPR(.fDBTBL25) D VDA1(.fDBTBL25)
	I %O D VLOD(.fDBTBL25) Q:$get(ER)  D VPR(.fDBTBL25) D VDA1(.fDBTBL25)
	;
	; ====================  Display Form
	D ^DBSPNT()
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=XECUTE
	I %O=2!(%O=3) D ^DBSCRT8A XECUTE:'$D(%PAGE) KVAR Q  ; Inquiry/Delete
	; ====================  Set up data entry control table
	;
	I %O<2 D VTAB(.fDBTBL25)
	Q 
	;
VNEW(fDBTBL25)	; Initialize arrays if %O=0
	;
	D VDEF(.fDBTBL25)
	D VLOD(.fDBTBL25)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VDEF(fDBTBL25)	;
	Q:(vobj(fDBTBL25,-3)="")!(vobj(fDBTBL25,-4)="") 
	Q:%O  S ER=0 I (vobj(fDBTBL25,-3)="")!(vobj(fDBTBL25,-4)="") S ER=1 S RM=$$^MSG(1767,"%LIBS,PROCID") Q 
	 N V1,V2 S V1=vobj(fDBTBL25,-3),V2=vobj(fDBTBL25,-4) I ($D(^DBTBL(V1,25,V2))#2) S ER=1 S RM=$$^MSG(2327) Q 
	I $P(vobj(fDBTBL25),$C(124),3)="" N vSetMf S vSetMf=$P(vobj(fDBTBL25),$C(124),3) S $P(vobj(fDBTBL25),$C(124),3)=+$H,vobj(fDBTBL25,-100,"0*")=""
	I $P(vobj(fDBTBL25),$C(124),9)="" N vSetMf S vSetMf=$P(vobj(fDBTBL25),$C(124),9) S $P(vobj(fDBTBL25),$C(124),9)=1,vobj(fDBTBL25,-100,"0*")=""
	I $P(vobj(fDBTBL25),$C(124),4)="" N vSetMf S vSetMf=$P(vobj(fDBTBL25),$C(124),4) S $P(vobj(fDBTBL25),$C(124),4)=%UID,vobj(fDBTBL25,-100,"0*")=""
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
VLOD(fDBTBL25)	; Load data from disc - %O = (1-5)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VPR(fDBTBL25)	; Display screen prompts
	S VO="21||13|0"
	S VO(0)="|0"
	S VO(1)=$C(2,1,80,0,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
	S VO(2)=$C(3,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(3)=$C(3,9,16,1,0,0,0,0,0,0)_"01T Procedure Name:"
	S VO(4)=$C(3,41,15,1,0,0,0,0,0,0)_"01T Last Modified:"
	S VO(5)=$C(3,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(6)=$C(4,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(7)=$C(4,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(8)=$C(5,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(9)=$C(5,7,18,1,0,0,0,0,0,0)_"01T Run-time Routine:"
	S VO(10)=$C(5,47,9,1,0,0,0,0,0,0)_"01T By User:"
	S VO(11)=$C(5,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(12)=$C(6,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(13)=$C(6,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(14)=$C(7,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(15)=$C(7,12,13,1,0,0,0,0,0,0)_"01T Description:"
	S VO(16)=$C(7,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(17)=$C(8,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(18)=$C(8,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(19)=$C(9,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(20)=$C(9,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(21)=$C(10,1,80,0,0,0,0,0,0,0)_"11Tmqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqj"
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VDA1(fDBTBL25)	; Display screen data
	N V
	;
	S VO="28|22|13|0"
	S VO(22)=$C(1,2,79,1,0,0,0,0,0,0)_"01T"_$S(%O=5:"",1:$$BANNER^UTLREAD($get(%FN)))
	S VO(23)=$C(3,26,12,2,0,0,0,0,0,0)_"01T"_$E((vobj(fDBTBL25,-4)),1,12)
	S VO(24)=$C(3,57,10,2,0,0,0,0,0,0)_"01D"_$$vdat2str(($P(vobj(fDBTBL25),$C(124),3)),"MM/DD/YEAR")
	S VO(25)=$C(3,69,10,2,0,0,0,0,0,0)_"01C"_$$TIM^%ZM($P(vobj(fDBTBL25),$C(124),5))
	S VO(26)=$C(5,26,8,2,0,0,0,0,0,0)_"00U"_$E(($P(vobj(fDBTBL25),$C(124),2)),1,8)
	S VO(27)=$C(5,57,20,2,0,0,0,0,0,0)_"01T"_$E(($P(vobj(fDBTBL25),$C(124),4)),1,20)
	S VO(28)=$C(7,26,40,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fDBTBL25),$C(124),1)),1,40)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTAB(fDBTBL25)	;
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
	S %MAX=6 S VPT=1 S VPB=10 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="DBTBL25"
	S OLNTB=10001
	;
	S VFSN("DBTBL25")="zfDBTBL25"
	;
	;
	S %TAB(1)=$C(2,25,12)_"20U12402|1|[DBTBL25]PROCID"
	S %TAB(2)=$C(2,56,10)_"20D12403|1|[DBTBL25]LTD"
	S %TAB(3)=$C(2,68,10)_"20C12405|1|[DBTBL25]TIME"
	S %TAB(4)=$C(4,25,8)_"01U12402|1|[DBTBL25]PGM|||do VP1^V01S202(.fDBTBL25)"
	S %TAB(5)=$C(4,56,20)_"20T12404|1|[DBTBL25]USER"
	S %TAB(6)=$C(6,25,40)_"01T12401|1|[DBTBL25]DES"
	D VTBL(.fDBTBL25) D VDEPRE(.fDBTBL25) I $get(ER) Q 
	D ^DBSCRT8 ; data entry
	Q 
	;
VREQ	; Create REQ() array
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTBL(fDBTBL25)	;Create %TAB(array)
	; 1 2 3  4 5   6   7-9 10-11
	; DY,DX,SZ PT REQ TYPE DEL POS |NODE|ITEM NAME|TBL|FMT|PP|PRE|MIN|MAX|DEC
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VDEPRE(fDBTBL25)	; Data Entry Pre-processor
	;
	I ($P(vobj(fDBTBL25),$C(124),2)="") Q 
	I %O'=1 Q 
	D PROTECT^DBSMACRO("[DBTBL25]PGM")
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
	;user-defined post procs
	;
VP1(fDBTBL25)	;
	; Validate routine name
	;
	I V'=X S ER=$$VALPGM^DBSCDI(X) I ER Q 
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VRV(V,L)	;
	Q V_$J("",L-$L(V))
VREPRNT	;
	D VPR(.fDBTBL25)
	D VDA1(.fDBTBL25)
	D ^DBSPNT()
	Q 
	;
VW(fDBTBL25)	;
	D VDA1(.fDBTBL25)
	D ^DBSPNT(10)
	Q 
	;
VDAPNT(fDBTBL25)	;
	D VDA1(.fDBTBL25)
	D ^DBSPNT(0,2)
	Q 
	;
VDA	;
	D VDA1(.fDBTBL25)
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
vSET(sn,di,X)	;
	I sn="DBTBL25" D vSET1(.fDBTBL25,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
vSET1(fDBTBL25,di,X)	;
	D vCoInd1(fDBTBL25,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di)	;
	I fid="DBTBL25" Q $$vREAD1(.fDBTBL25,di)
	Q ""
vREAD1(fDBTBL25,di)	;
	Q $$vCoInd2(fDBTBL25,di)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VSCRPRE(fDBTBL25)	; Screen Pre-Processor
	N %TAB,vtab ; Disable .MACRO. references to %TAB()
	;
	S UX=1
	Q 
	;  #ACCEPT date=11/05/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	; ----------------
	;  #OPTION ResultClass 0
vdat2str(object,mask)	; Date.toString
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I (object="") Q ""
	I (mask="") S mask="MM/DD/YEAR"
	N cc N lday N lmon
	I mask="DL"!(mask="DS") D  ; Long or short weekday
	.	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
	.	I (cc="") S cc="US"
	.	S lday=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
	.	S mask="DAY" ; Day of the week
	.	Q 
	I mask="ML"!(mask="MS") D  ; Long or short month
	.	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
	.	I (cc="") S cc="US"
	.	S lmon=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
	.	S mask="MON" ; Month of the year
	.	Q 
	Q $ZD(object,mask,$get(lmon),$get(lday))
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS1(vRec,vVal)	; RecordDBTBL25.setDES(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",1)
	S $P(vobj(vRec),"|",1)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS2(vRec,vVal)	; RecordDBTBL25.setLTD(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",3)
	S $P(vobj(vRec),"|",3)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS3(vRec,vVal)	; RecordDBTBL25.setMPLUS(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",9)
	S $P(vobj(vRec),"|",9)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS4(vRec,vVal)	; RecordDBTBL25.setPFID(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",8)
	S $P(vobj(vRec),"|",8)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS5(vRec,vVal)	; RecordDBTBL25.setPGM(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",2)
	S $P(vobj(vRec),"|",2)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS6(vRec,vVal)	; RecordDBTBL25.setRPCVAR(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",6)
	S $P(vobj(vRec),"|",6)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS7(vRec,vVal)	; RecordDBTBL25.setRPCVAR1(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",7)
	S $P(vobj(vRec),"|",7)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS8(vRec,vVal)	; RecordDBTBL25.setTIME(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",5)
	S $P(vobj(vRec),"|",5)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS9(vRec,vVal)	; RecordDBTBL25.setUSER(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",4)
	S $P(vobj(vRec),"|",4)=vVal S vobj(vRec,-100,"0*")=""
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
vCoInd1(vOid,vCol,vVal)	; RecordDBTBL25.setColumn(1,0)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("DBTBL25",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	N vTyp S vTyp=$P(vP,"|",6)
	I vNod["*" S vPos=-$P(vP,"|",4)-2 S:'($D(vobj(vOid,-100,$P(vP,"|",4)_"*",vCol))#2) vobj(vOid,-100,$P(vP,"|",4)_"*",vCol)=vTyp_"000"_vobj(vOid,vPos) S vobj(vOid,vPos)=vVal Q 
	;
	S vPos=$P(vP,"|",4)
	I vCol="DES" D vCoMfS1(vOid,vVal) Q 
	I vCol="LTD" D vCoMfS2(vOid,vVal) Q 
	I vCol="MPLUS" D vCoMfS3(vOid,vVal) Q 
	I vCol="PFID" D vCoMfS4(vOid,vVal) Q 
	I vCol="PGM" D vCoMfS5(vOid,vVal) Q 
	I vCol="RPCVAR" D vCoMfS6(vOid,vVal) Q 
	I vCol="RPCVAR1" D vCoMfS7(vOid,vVal) Q 
	I vCol="TIME" D vCoMfS8(vOid,vVal) Q 
	I vCol="USER" D vCoMfS9(vOid,vVal) Q 
	N vOldNod S vOldNod=$$getOldNode^UCXDD(vP,0)
	N vOld S vOld=$piece(vobj(vOid),"|",vPos)
	I '($P(vP,"|",13)="") S vOld=$$vStrGSub(vOld,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	I '$D(vobj(vOid,-100,vOldNod,vCol)) S vobj(vOid,-100,vOldNod,vCol)=vTyp_$E(1000+vPos,2,4)_vOld
	I '($P(vP,"|",13)="") S vVal=$$vStrPSub($piece(vobj(vOid),"|",vPos),vVal,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	S $piece(vobj(vOid),"|",vPos)=vVal
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoInd2(vOid,vCol)	; RecordDBTBL25.getColumn()
	N vret
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("DBTBL25",$$vStrUC(vCol))
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
vDbNew1(v1,v2)	;	vobj()=Class.new(DBTBL25)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL25",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
