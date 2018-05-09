V01S377(%O,fSCAU)	; -  - SID= <SCAUSTAT> User Status Information
	;
	; **** Routine compiled from DATA-QWIK Screen SCAUSTAT ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	;;Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 12/06/2007 16:14 - chenardp
	;
	N KEYS N KVAR N VFSN N VO N VODFT N VPGM N vPSL N VSID N VSNAME
	;
	; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
	;
	S:'($D(%O)#2) %O=5
	I (%O=5) D
	.	I '($D(fSCAU)#2) K vobj(+$G(fSCAU)) S fSCAU=$$vDbNew1("")
	.	Q 
	S KVAR="kill %TAB,VFSN,VO,VPTBL,vtab" S VSID="SCAUSTAT" S VPGM=$T(+0) S VSNAME="User Status Information"
	S VFSN("SCAU")="zfSCAU"
	S vPSL=1
	S KEYS(1)=vobj(fSCAU,-3)
	;
	; ==================== Display blank screen         (%O=5)
	;
	I %O=5 D VPR(.fSCAU) D VDA1(.fSCAU) D ^DBSPNT() Q 
	;
	I '%O D VNEW(.fSCAU) D VPR(.fSCAU) D VDA1(.fSCAU)
	I %O D VLOD(.fSCAU) Q:$get(ER)  D VPR(.fSCAU) D VDA1(.fSCAU)
	;
	; ====================  Display Form
	D ^DBSPNT()
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=XECUTE
	I %O=2!(%O=3) D ^DBSCRT8A XECUTE:'$D(%PAGE) KVAR Q  ; Inquiry/Delete
	; ====================  Set up data entry control table
	;
	I %O<2 D VTAB(.fSCAU)
	Q 
	;
VNEW(fSCAU)	; Initialize arrays if %O=0
	;
	D VDEF(.fSCAU)
	D VLOD(.fSCAU)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VDEF(fSCAU)	;
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
VLOD(fSCAU)	; Load data from disc - %O = (1-5)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VPR(fSCAU)	; Display screen prompts
	S VO="7||13|0"
	S VO(0)="|0"
	S VO(1)=$C(1,22,23,1,0,0,0,0,0,0)_"01TUser Status Information"
	S VO(2)=$C(3,10,12,0,0,0,0,0,0,0)_"01TUser Status:"
	S VO(3)=$C(3,46,20,0,0,0,0,0,0,0)_"01T User Status Reason:"
	S VO(4)=$C(4,1,21,0,0,0,0,0,0,0)_"01T Date Last Signed On:"
	S VO(5)=$C(4,37,29,0,0,0,0,0,0,0)_"01T Number of Password Failures:"
	S VO(6)=$C(6,1,21,0,0,0,0,0,0,0)_"01TManual Revoke Status:"
	S VO(7)=$C(6,38,28,0,0,0,0,0,0,0)_"01TManual Revoke Status Reason:"
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VDA1(fSCAU)	; Display screen data
	N V
	;
	S VO="13|8|13|0"
	S VO(8)=$C(3,23,2,2,0,0,0,0,0,0)_"01N"_($$STATUS^SCAUCDI($P(vobj(fSCAU),$C(124),5),$P(vobj(fSCAU),$C(124),8),$P(vobj(fSCAU),$C(124),44),$P(vobj(fSCAU),$C(124),43)))
	S VO(9)=$C(3,67,2,2,0,0,0,0,0,0)_"01N"_($$SREASON^SCAUCDI($P(vobj(fSCAU),$C(124),5),$P(vobj(fSCAU),$C(124),8),$P(vobj(fSCAU),$C(124),44),$P(vobj(fSCAU),$C(124),43)))
	S VO(10)=$C(4,23,10,2,0,0,0,0,0,0)_"01D"_$$vdat2str(($P(vobj(fSCAU),$C(124),8)),"MM/DD/YEAR")
	S VO(11)=$C(4,67,2,2,0,0,0,0,0,0)_"01N"_$P(vobj(fSCAU),$C(124),43)
	S VO(12)=$C(6,23,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fSCAU),$C(124),44):"Y",1:"N")
	S VO(13)=$C(6,67,2,2,0,0,0,0,0,0)_"00N"_$P(vobj(fSCAU),$C(124),45)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTAB(fSCAU)	;
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
	S %MAX=6 S VPT=1 S VPB=6 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="SCAU"
	S OLNTB=6067
	;
	S VFSN("SCAU")="zfSCAU"
	;
	;
	S %TAB(1)=$C(2,22,2)_"20N12400|*STATUS|[SCAU]STATUS|[STBLUSERSTAT]"
	S %TAB(2)=$C(2,66,2)_"20N12400|*SREASON|[SCAU]SREASON|[STBLREASON]"
	S %TAB(3)=$C(3,22,10)_"20D12408|1|[SCAU]LSGN"
	S %TAB(4)=$C(3,66,2)_"20N12443|1|[SCAU]PWDFAIL"
	S %TAB(5)=$C(5,22,1)_"00L12444|1|[SCAU]MRSTAT|||do VP1^V01S377(.fSCAU)"
	S %TAB(6)=$C(5,66,2)_"00N12445|1|[SCAU]MREASON|[UTBLMREASON]||do VP2^V01S377(.fSCAU)"
	D VTBL(.fSCAU)
	D ^DBSCRT8 ; data entry
	Q 
	;
VREQ	; Create REQ() array
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTBL(fSCAU)	;Create %TAB(array)
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
VP1(fSCAU)	;
	I X D UNPROT^DBSMACRO("SCAU.MREASON") Q 
	;
	D DELETE^DBSMACRO("SCAU.MREASON","1","0")
	D PROTECT^DBSMACRO("SCAU.MREASON")
	Q 
	;
VP2(fSCAU)	;
	I $P(vobj(fSCAU),$C(124),44) D CHANGE^DBSMACRO("REQ","")
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VRV(V,L)	;
	Q V_$J("",L-$L(V))
VREPRNT	;
	D VPR(.fSCAU)
	D VDA1(.fSCAU)
	D ^DBSPNT()
	Q 
	;
VW(fSCAU)	;
	D VDA1(.fSCAU)
	D ^DBSPNT(10)
	Q 
	;
VDAPNT(fSCAU)	;
	D VDA1(.fSCAU)
	D ^DBSPNT(0,2)
	Q 
	;
VDA	;
	D VDA1(.fSCAU)
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
vSET(sn,di,X)	;
	I sn="SCAU" D vSET1(.fSCAU,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
vSET1(fSCAU,di,X)	;
	D vCoInd1(fSCAU,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di)	;
	I fid="SCAU" Q $$vREAD1(.fSCAU,di)
	Q ""
vREAD1(fSCAU,di)	;
	Q $$vCoInd2(fSCAU,di)
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
vCoInd1(vOid,vCol,vVal)	; RecordSCAU.setColumn(1,0)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("SCAU",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	N vTyp S vTyp=$P(vP,"|",6)
	I vNod["*" S vPos=-3 S:'($D(vobj(vOid,-100,$P(vP,"|",4)_"*",vCol))#2) vobj(vOid,-100,$P(vP,"|",4)_"*",vCol)=vTyp_"000"_vobj(vOid,vPos) S vobj(vOid,vPos)=vVal Q 
	;
	N vCmp S vCmp=$P(vP,"|",14)
	I vCmp'="" S $ZS="-1,"_$ZPOS_","_"%PSL-E-INVALIDREF" X $ZT
	;
	S vPos=$P(vP,"|",4)
	N vOldNod S vOldNod=$$getOldNode^UCXDD(vP,0)
	I '$D(vobj(vOid,-100,vOldNod,vCol)) S vobj(vOid,-100,vOldNod,vCol)=vTyp_$E(1000+vPos,2,4)_$piece(vobj(vOid),"|",vPos)
	S $piece(vobj(vOid),"|",vPos)=vVal
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoInd2(vOid,vCol)	; RecordSCAU.getColumn()
	N vret
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("SCAU",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	I vNod["*" S vret=$get(vobj(vOid,-3)) Q vret
	;
	N vCmp S vCmp=$P(vP,"|",14)
	I vCmp'="" S vCmp=$$getCurExpr^UCXDD(vP,"vOid",0) Q @vCmp
	;
	S vPos=$P(vP,"|",4)
	N vRet
	S vRet=vobj(vOid)
	S vRet=$piece(vRet,"|",vPos)
	Q vRet
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ","ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ")
	;
vDbNew1(v1)	;	vobj()=Class.new(SCAU)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSCAU",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	Q vOid
