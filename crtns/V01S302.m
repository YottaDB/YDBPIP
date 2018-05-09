V01S302(%O,dbtbl14q,dbtbl14)	; -  - SID= <DBTBL14> Data-Item Protection
	;
	; **** Routine compiled from DATA-QWIK Screen DBTBL14 ****
	;
	; 09/14/2007 10:48 - chenardp
	;
	;;Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/14/2007 10:48 - chenardp
	; (DESC,PROT,RUCLS)#1
	;
	N KEYS N KVAR N VFSN N VO N VODFT N VPGM N vPSL N VSID N VSNAME
	;
	; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
	;
	S:'($D(%O)#2) %O=5
	I (%O=5) D
	.	I '($D(dbtbl14q(1))#2) K vobj(+$G(dbtbl14q(1))) S dbtbl14q(1)=$$vDbNew1("","","","","")
	.	I '($D(dbtbl14)#2) K vobj(+$G(dbtbl14)) S dbtbl14=$$vDbNew2("","","","")
	.	Q 
	S KVAR="kill %TAB,VFSN,VO,VPTBL,vtab" S VSID="DBTBL14" S VPGM=$T(+0) S VSNAME="Data-Item Protection"
	S VFSN("DBTBL14")="zdbtbl14" S VFSN("DBTBL14Q")="zdbtbl14q"
	S vPSL=1
	S KEYS(1)=vobj(dbtbl14,-3)
	S KEYS(2)=vobj(dbtbl14,-4)
	S KEYS(3)=vobj(dbtbl14,-5)
	S KEYS(4)=vobj(dbtbl14,-6)
	;
	; ==================== Display blank screen         (%O=5)
	;
	I %O=5 S %MODS=1 S %REPEAT=11 D VPR(.dbtbl14q,.dbtbl14) D VDA1(.dbtbl14q,.dbtbl14) D V5^DBSPNT Q 
	;
	I '%O D VNEW(.dbtbl14q,.dbtbl14) D VPR(.dbtbl14q,.dbtbl14) D VDA1(.dbtbl14q,.dbtbl14)
	I %O D VLOD(.dbtbl14q,.dbtbl14) Q:$get(ER)  D VPR(.dbtbl14q,.dbtbl14) D VDA1(.dbtbl14q,.dbtbl14)
	;
	; ====================  Display Form
	D ^DBSPNT()
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=XECUTE
	I %O=2!(%O=3) D ^DBSCRT8A XECUTE:'$D(%PAGE) KVAR Q  ; Inquiry/Delete
	; ====================  Set up data entry control table
	;
	I %O<2 D VTAB(.dbtbl14q,.dbtbl14)
	N ptr
	S ptr=""
	F  S ptr=$order(dbtbl14q(ptr)) Q:(ptr="")  D
	.	I vobj(dbtbl14q(ptr),-7)="" K vobj(+$G(dbtbl14q(ptr))) K dbtbl14q(ptr)
	.	Q 
	Q 
	;
VNEW(dbtbl14q,dbtbl14)	; Initialize arrays if %O=0
	;
	D VDEF(.dbtbl14q,.dbtbl14)
	D VLOD(.dbtbl14q,.dbtbl14)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VDEF(dbtbl14q,dbtbl14)	;
	Q:(vobj(dbtbl14q(I),-3)="")!(vobj(dbtbl14q(I),-4)="")!(vobj(dbtbl14q(I),-5)="")!(vobj(dbtbl14q(I),-6)="")!(vobj(dbtbl14q(I),-7)="") 
	Q:%O  S ER=0 I (vobj(dbtbl14q(I),-3)="")!(vobj(dbtbl14q(I),-4)="")!(vobj(dbtbl14q(I),-5)="")!(vobj(dbtbl14q(I),-6)="")!(vobj(dbtbl14q(I),-7)="") S ER=1 S RM=$$^MSG(1767,"PLIBS,FID,DINAM,GROUP,QUERY") Q 
	 N V1,V2,V3,V4,V5 S V1=vobj(dbtbl14q(I),-3),V2=vobj(dbtbl14q(I),-4),V3=vobj(dbtbl14q(I),-5),V4=vobj(dbtbl14q(I),-6),V5=vobj(dbtbl14q(I),-7) I ($D(^DBTBL(V1,14,V2,V3,V4,V5))#2) S ER=1 S RM=$$^MSG(2327) Q 
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
VLOD(dbtbl14q,dbtbl14)	; Load data from disc - %O = (1-5)
	I '$D(%REPEAT) S %REPEAT=11
	I '$D(%MODS) S %MODS=1
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VPR(dbtbl14q,dbtbl14)	; Display screen prompts
	S VO="30||13|0"
	S VO(0)="|0"
	S VO(1)=$C(2,1,80,0,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
	S VO(2)=$C(3,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(3)=$C(3,2,10,0,0,0,0,0,0,0)_"01TFile Name:"
	S VO(4)=$C(3,26,8,0,0,0,0,0,0,0)_"01TUser ID:"
	S VO(5)=$C(3,56,13,0,0,0,0,0,0,0)_"01TLast Updated:"
	S VO(6)=$C(3,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(7)=$C(4,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(8)=$C(4,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(9)=$C(5,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(10)=$C(5,2,10,0,0,0,0,0,0,0)_"01TData Item:"
	S VO(11)=$C(5,28,12,0,0,0,0,0,0,0)_"01T Group Code:"
	S VO(12)=$C(5,49,15,1,0,0,0,0,0,0)_"01T Access Option:"
	S VO(13)=$C(5,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(14)=$C(6,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(15)=$C(6,49,15,1,0,0,0,0,0,0)_"01T 1-Read   2-No "
	S VO(16)=$C(6,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(17)=$C(7,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(18)=$C(7,2,13,1,0,0,0,0,0,0)_"01T Description:"
	S VO(19)=$C(7,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(20)=$C(8,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(21)=$C(8,2,1,0,0,0,0,0,0,0)_"01T "
	S VO(22)=$C(8,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(23)=$C(9,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(24)=$C(9,21,29,1,0,0,0,0,0,0)_"01T   Restricted  Userclasses   "
	S VO(25)=$C(9,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(26)=$C(10,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(27)=$C(10,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(28)=$C(11,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(29)=$C(11,26,20,1,0,0,0,0,0,0)_"01T Query  Definitions "
	S VO(30)=$C(11,80,1,0,0,0,0,0,0,0)_"11Tx"
	I '($D(%MODS)#2) S %MODS=1
	S DY=12 F I=%MODS:1:%REPEAT+%MODS-1 D VRPR(.dbtbl14q,.dbtbl14)
	S VO=(+VO)_"|"_(VO+1)_"|13" Q  ; BOD pointer
	;
VRPR(dbtbl14q,dbtbl14)	; Display prompts %REPEAT times
	;
	S VO(VO+1)=$C(DY,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(VO+2)=$C(DY,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO=VO+2 S DY=DY+1
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VDA1(dbtbl14q,dbtbl14)	; Display screen data
	N V
	;
	S VX=$piece(VO,"|",2)
	S VO(VX+0)=$C(1,1,80,1,0,0,0,0,0,0)_"01T"_$S(%O=5:"",1:$$BANNER^DBSGETID($get(%FN)))
	S VO(VX+1)=$C(3,13,12,2,0,0,0,0,0,0)_"01T"_$E((vobj(dbtbl14,-4)),1,12)
	S VO(VX+2)=$C(3,35,20,2,0,0,0,0,0,0)_"01T"_$E(($P(vobj(dbtbl14),$C(124),15)),1,20)
	S VO(VX+3)=$C(3,70,10,2,0,0,0,0,0,0)_"01D"_$$vdat2str(($P(vobj(dbtbl14),$C(124),6)),"MM/DD/YEAR")
	S VO(VX+4)=$C(5,13,15,2,0,0,0,0,0,0)_"01T"_$E((vobj(dbtbl14,-5)),1,15)
	S VO(VX+5)=$C(5,41,2,2,0,0,0,0,0,0)_"01N"_vobj(dbtbl14,-6)
	S VO(VX+6)=$C(5,65,1,2,0,0,0,0,0,0)_"00N"_$P(vobj(dbtbl14),$C(124),2)
	S VO(VX+7)=$C(7,16,50,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(dbtbl14),$C(124),1)),1,50)
	S VO(VX+8)=$C(10,2,75,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(dbtbl14),$C(124),3)),1,75)
	;
	S:'($D(%MODS)#2) %MODS=1 S VX=$piece(VO,"|",2)+8 S DY=12 F I=%MODS:1:%REPEAT+%MODS-1 D VRDA(.dbtbl14q,.dbtbl14)
	S $piece(VO,"|",1)=VX Q  ; EOD pointer
	;
VRDA(dbtbl14q,dbtbl14)	; Display data %REPEAT times
	;instantiate new object if necessary
	;   #ACCEPT;DATE=08/08/06; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEPRECATED
	I '$G(dbtbl14q(I)) D
	. K vobj(+$G(dbtbl14q(I))) S dbtbl14q(I)=$$vDbNew1($get(KEYS(1)),$get(KEYS(2)),$get(KEYS(3)),$get(KEYS(4)),"")
	.	Q 
	S VO(VX+1)=$C(DY,2,70,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(dbtbl14q(I)),$C(124),1)),1,70)
	S DY=DY+1 S VX=VX+1
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTAB(dbtbl14q,dbtbl14)	;
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab S %MODGRP=1
	S %MODOFF=8 S %MOD=1 S %MAX=(%MOD*%REPEAT)+%MODOFF S VPT=1 S VPB=11+%REPEAT S BLKSIZ=(70*%REPEAT)+185 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="DBTBL14Q,DBTBL14"
	S OLNTB=VPB*1000
	;
	S VFSN("DBTBL14")="zdbtbl14" S VFSN("DBTBL14Q")="zdbtbl14q"
	;
	F I=10:1:%MAX S %TAB(I)=""
	;
	S %TAB(1)=$C(2,12,12)_"21U12402|1|[DBTBL14]FID||if X?1A.AN!(X?1""%"".AN)!(X?.A.""_"".E)|||||||256"
	S %TAB(2)=$C(2,34,20)_"21T12415||[DBTBL14]UID"
	S %TAB(3)=$C(2,69,10)_"21D12406||[DBTBL14]DATE"
	S %TAB(4)=$C(4,12,15)_"21U12403|1|[DBTBL14]DINAM||if X?1""%"".AN!(X?.A.""_"".E)|||||||256"
	S %TAB(5)=$C(4,40,2)_"21N12404|1|[DBTBL14]GROUP"
	S %TAB(6)=$C(4,64,1)_"01N12402||[DBTBL14]PROT"
	S %TAB(7)=$C(6,15,50)_"01T12401||[DBTBL14]DESC"
	S %TAB(8)=$C(9,1,75)_"01T12403||[DBTBL14]RUCLS1|||do VP1^V01S302(.dbtbl14q,.dbtbl14)"
	S %TAB(9)=$C(11,1,70)_"00T12401|1|[DBTBL14Q]QRYDESC|||do VP2^V01S302(.dbtbl14q,.dbtbl14)"
	D VTBL(.dbtbl14q,.dbtbl14)
	D ^DBSCRT8 ; data entry
	Q 
	;
VREQ	; Create REQ() array
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTBL(dbtbl14q,dbtbl14)	;Create %TAB(array)
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
VP1(dbtbl14q,dbtbl14)	;
	;
	; Check valid syntax      *,ABC*,AB-CD,'ABC
	;
	N isDone
	N I
	N XU N XU2
	;
	Q:(X="") 
	;
	S ER=0
	;
	F I=1:1:$L(X,",") D  Q:ER 
	.	;
	.	S XU=$piece(X,",",I)
	.	Q:(XU="") 
	.	;
	.	S XU2=$E(XU,2,1048575) ; Strip leading '
	.	;
	.	; All userclasses
	.	I (XU="*") S RM=$$^MSG(245)
	.	; Single user class - OK
	.	E  I (XU?1AN.AN),($D(^SCAU(0,XU))#2)
	.	; Range - from-to
	.	E  I (XU?1AN.AN1"-"1AN.AN) S RM=$$^MSG(2305)
	.	; Range - AB* from AB to ABz
	.	E  I (XU?1AN.AN1"*") S RM=$$^MSG(2305)
	.	; All except ~p1 - 'AB except AB
	.	E  I (XU?1"'"1AN.AN),($D(^SCAU(0,XU2))#2) S RM=$$^MSG(242,XU2)
	.	E  D
	..		;
	..		S ER=1
	..		; Invalid syntax for userclass ~p1
	..		S RM=$$^MSG(1478,X)
	..		Q 
	.	Q 
	;
	Q 
	;
VP2(dbtbl14q,dbtbl14)	;
	;
	N CNT N INDEX
	;
	Q:(X="") 
	;
	S ER=0
	;
	S CNT=$L(X,"]")
	F INDEX=1:1:CNT-1 D  Q:ER 
	.	;
	.	I $piece($piece(X,"]",INDEX),"[",2)'=vobj(dbtbl14,-4) D
	..		;
	..		S ER=1
	..		; The table used in the query must match the protected table ~p1
	..		S RM=$$^MSG(3981,vobj(dbtbl14,-4))
	..		Q 
	.	Q 
	;
	I 'ER D ^DBSQRY
	;
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VRV(V,L)	;
	Q V_$J("",L-$L(V))
VREPRNT	;
	D VPR(.dbtbl14q,.dbtbl14)
	D VDA1(.dbtbl14q,.dbtbl14)
	D ^DBSPNT()
	Q 
	;
VW(dbtbl14q,dbtbl14)	;
	D VDA1(.dbtbl14q,.dbtbl14)
	D ^DBSPNT(10)
	Q 
	;
VDAPNT(dbtbl14q,dbtbl14)	;
	D VDA1(.dbtbl14q,.dbtbl14)
	D ^DBSPNT(0,2)
	Q 
	;
VDA	;
	D VDA1(.dbtbl14q,.dbtbl14)
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
vSET(sn,di,X)	;
	I sn="DBTBL14Q" D vSET1(dbtbl14q(I(1)),di,X)
	I sn="DBTBL14" D vSET2(.dbtbl14,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
vSET1(dbtbl14q,di,X)	;
	D vCoInd1(dbtbl14q,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
vSET2(dbtbl14,di,X)	;
	D vCoInd2(dbtbl14,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di)	;
	I fid="DBTBL14Q" Q $$vREAD1(dbtbl14q(I(1)),di)
	I fid="DBTBL14" Q $$vREAD2(.dbtbl14,di)
	Q ""
vREAD1(dbtbl14q,di)	;
	Q $$vCoInd3(dbtbl14q,di)
vREAD2(dbtbl14,di)	;
	Q $$vCoInd4(dbtbl14,di)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
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
vCoMfS1(vRec,vVal)	; RecordDBTBL14Q.setQRYDESC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",1)
	S $P(vobj(vRec),"|",1)=vVal S vobj(vRec,-100,"0*")=""
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
vCoInd1(vOid,vCol,vVal)	; RecordDBTBL14Q.setColumn(1,0)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("DBTBL14Q",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	N vTyp S vTyp=$P(vP,"|",6)
	I vNod["*" S vPos=-$P(vP,"|",4)-2 S:'($D(vobj(vOid,-100,$P(vP,"|",4)_"*",vCol))#2) vobj(vOid,-100,$P(vP,"|",4)_"*",vCol)=vTyp_"000"_vobj(vOid,vPos) S vobj(vOid,vPos)=vVal Q 
	;
	S vPos=$P(vP,"|",4)
	I vCol="QRYDESC" D vCoMfS1(vOid,vVal) Q 
	N vOldNod S vOldNod=$$getOldNode^UCXDD(vP,0)
	N vOld S vOld=$piece(vobj(vOid),"|",vPos)
	I '($P(vP,"|",13)="") S vOld=$$vStrGSub(vOld,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	I '$D(vobj(vOid,-100,vOldNod,vCol)) S vobj(vOid,-100,vOldNod,vCol)=vTyp_$E(1000+vPos,2,4)_vOld
	I '($P(vP,"|",13)="") S vVal=$$vStrPSub($piece(vobj(vOid),"|",vPos),vVal,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	S $piece(vobj(vOid),"|",vPos)=vVal
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS2(vRec,vVal)	; RecordDBTBL14.setDATE(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",6)
	S $P(vobj(vRec),"|",6)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS3(vRec,vVal)	; RecordDBTBL14.setDESC(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",1)
	S $P(vobj(vRec),"|",1)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS4(vRec,vVal)	; RecordDBTBL14.setPROT(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",2)
	S $P(vobj(vRec),"|",2)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS5(vRec,vVal)	; RecordDBTBL14.setRUCLS1(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",3)
	S $P(vobj(vRec),"|",3)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoMfS6(vRec,vVal)	; RecordDBTBL14.setUID(1)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vSetMf S vSetMf=$P(vobj(vRec),"|",15)
	S $P(vobj(vRec),"|",15)=vVal S vobj(vRec,-100,"0*")=""
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoInd2(vOid,vCol,vVal)	; RecordDBTBL14.setColumn(1,0)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("DBTBL14",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	N vTyp S vTyp=$P(vP,"|",6)
	I vNod["*" S vPos=-$P(vP,"|",4)-2 S:'($D(vobj(vOid,-100,$P(vP,"|",4)_"*",vCol))#2) vobj(vOid,-100,$P(vP,"|",4)_"*",vCol)=vTyp_"000"_vobj(vOid,vPos) S vobj(vOid,vPos)=vVal Q 
	;
	N vCmp S vCmp=$P(vP,"|",14)
	I vCmp'="" S $ZS="-1,"_$ZPOS_","_"%PSL-E-INVALIDREF" X $ZT
	;
	S vPos=$P(vP,"|",4)
	I vCol="DATE" D vCoMfS2(vOid,vVal) Q 
	I vCol="DESC" D vCoMfS3(vOid,vVal) Q 
	I vCol="PROT" D vCoMfS4(vOid,vVal) Q 
	I vCol="RUCLS1" D vCoMfS5(vOid,vVal) Q 
	I vCol="UID" D vCoMfS6(vOid,vVal) Q 
	N vOldNod S vOldNod=$$getOldNode^UCXDD(vP,0)
	N vOld S vOld=$piece(vobj(vOid),"|",vPos)
	I '($P(vP,"|",13)="") S vOld=$$vStrGSub(vOld,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	I '$D(vobj(vOid,-100,vOldNod,vCol)) S vobj(vOid,-100,vOldNod,vCol)=vTyp_$E(1000+vPos,2,4)_vOld
	I '($P(vP,"|",13)="") S vVal=$$vStrPSub($piece(vobj(vOid),"|",vPos),vVal,$P(vP,"|",10),$P(vP,"|",11),$P(vP,"|",12),$P(vP,"|",13))
	S $piece(vobj(vOid),"|",vPos)=vVal
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoInd3(vOid,vCol)	; RecordDBTBL14Q.getColumn()
	N vret
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("DBTBL14Q",$$vStrUC(vCol))
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
vCoInd4(vOid,vCol)	; RecordDBTBL14.getColumn()
	N vret
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("DBTBL14",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	I vNod["*" S vret=$get(vobj(vOid,-$P(vP,"|",4)-2)) Q vret
	;
	N vCmp S vCmp=$P(vP,"|",14)
	I vCmp'="" S vCmp=$$getCurExpr^UCXDD(vP,"vOid",0) Q @vCmp
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
vDbNew1(v1,v2,v3,v4,v5)	;	vobj()=Class.new(DBTBL14Q)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL14Q",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	S vobj(vOid,-6)=v4
	S vobj(vOid,-7)=v5
	Q vOid
	;
vDbNew2(v1,v2,v3,v4)	;	vobj()=Class.new(DBTBL14)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL14",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	S vobj(vOid,-6)=v4
	Q vOid
