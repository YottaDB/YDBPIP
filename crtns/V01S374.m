V01S374(%O,fSCAU)	; -  - SID= <SCAUR> User Related CIF Input
	;
	; **** Routine compiled from DATA-QWIK Screen SCAUR ****
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
	S KVAR="kill %TAB,VFSN,VO,VPTBL,vtab,RELCIF,CIFNAM" S VSID="SCAUR" S VPGM=$T(+0) S VSNAME="User Related CIF Input"
	S VFSN("SCAU")="zfSCAU"
	S vPSL=1
	S KEYS(1)=vobj(fSCAU,-3)
	;
	; ==================== Display blank screen         (%O=5)
	;
	I %O=5 S %MODS=1 S %REPEAT=16 D VPR(.fSCAU) D VDA1(.fSCAU) D V5^DBSPNT Q 
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
	I '$D(%REPEAT) S %REPEAT=16
	I '$D(%MODS) S %MODS=1
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VPR(fSCAU)	; Display screen prompts
	S VO="7||13|"
	S VO(0)="|0"
	S VO(1)=$C(1,24,33,2,0,0,0,0,0,0)_"01TUser ""Related"" CIF Input Screen"
	S VO(2)=$C(3,1,47,0,0,0,0,0,0,0)_"01TCIF's entered on this screen will be considered"
	S VO(3)=$C(3,49,19,0,0,0,0,0,0,0)_"01T""related"" to user"
	S VO(4)=$C(4,1,62,0,0,0,0,0,0,0)_"01TThis User will be restricted from posting transactions to asso"
	S VO(5)=$C(4,63,16,0,0,0,0,0,0,0)_"01Tciated accounts."
	S VO(6)=$C(6,1,15,0,0,0,0,0,0,0)_"01TCustomer Number"
	S VO(7)=$C(6,20,13,0,0,0,0,0,0,0)_"01TCustomer Name"
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VDA1(fSCAU)	; Display screen data
	N V
	S CIFNAM=$get(CIFNAM)
	S RELCIF=$get(RELCIF)
	;
	S VO="8|8|13|"
	S VO(8)=$C(3,68,6,2,0,0,0,0,0,0)_"01T"_$E((vobj(fSCAU,-3)),1,6)
	;
	S:'($D(%MODS)#2) %MODS=1 S VX=8+0 S DY=7 F I=%MODS:1:%REPEAT+%MODS-1 D VRDA(.fSCAU)
	S $piece(VO,"|",1)=VX Q  ; EOD pointer
	;
VRDA(fSCAU)	; Display data %REPEAT times
	;instantiate new object if necessary
	I %O=5 N v2,v1
	I   S (v2,v1)=""
	E  N v2,v1
	E  S (v2,CIFNAM(I))=$get(CIFNAM(I)) S (v1,RELCIF(I))=$get(RELCIF(I))
	;
	S VO(VX+1)=$C(DY,4,12,2,0,0,0,0,0,0)_"00N"_v1
	S VO(VX+2)=$C(DY,20,40,2,0,0,0,0,0,0)_"00T"_v2
	S DY=DY+1 S VX=VX+2
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTAB(fSCAU)	;
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab S %MODGRP=1
	S %MODOFF=1 S %MOD=2 S %MAX=(%MOD*%REPEAT)+%MODOFF S VPT=1 S VPB=6+%REPEAT S BLKSIZ=(52*%REPEAT)+6 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="SCAU"
	S OLNTB=VPB*1000
	;
	S VFSN("SCAU")="zfSCAU"
	;
	F I=4:1:%MAX S %TAB(I)=""
	;
	S %TAB(1)=$C(2,67,6)_"21T12401|1|[SCAU]UID|||||||||20"
	S %TAB(2)=$C(6,3,12)_"00N|*RELCIF(1)|[*]@RELCIF|||do VP1^V01S374(.fSCAU)"
	S %TAB(3)=$C(6,19,40)_"00T|*CIFNAM(1)|[*]@CIFNAM"
	D VTBL(.fSCAU) D VDEPRE(.fSCAU) I $get(ER) Q 
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
VDEPRE(fSCAU)	; Data Entry Pre-processor
	;
	; CIF entry on this screen will disallow ~p1
	S VAR1=$$^MSG(6195,UID)
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
	;user-defined post procs
	;
VP1(fSCAU)	;
	I X="",V="" D GOTO^DBSMACRO("NEXT") Q 
	I X="" D  Q 
	.	S NAM=""
	.	F W=1:1:40 S NAM=NAM_"_"
	.	D DEF
	.	Q 
	S ER=0 D CUS^UACN1 Q:ER 
	;
	N cif S cif=$$vDb2(X)
	S NAM=$P(cif,$C(124),1)
	D DEF
	Q 
	;
DEF	;
	D DEFAULT^DBSMACRO("@CIFNAM",NAM,"1","0","0")
	D GOTO^DBSMACRO("NEXT")
	Q 
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
vDb2(v1)	;	voXN = Db.getRecord(CIF,,0)
	;
	N cif
	S cif=$G(^CIF(v1,1))
	I cif="",'$D(^CIF(v1,1))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,CIF" X $ZT
	Q cif
	;
vDbNew1(v1)	;	vobj()=Class.new(SCAU)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSCAU",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	Q vOid
