DBSDYNRA	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSDYNRA ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	; I18N=QUIT
	; *******************************************************************
	; * IMPORTANT NOTE:                                                 *
	; * According to the rules that apply to PSL compiler upgrades,     *
	; * the generated M routine associated with this procedure must be  *
	; * checked into StarTeam and released with the procedure whenever  *
	; * changes are made to this procedure.                             *
	; *                                                                 *
	; * The mrtns version will be used during upgrades and will then be *
	; * removed from the mrtns directory.  Therefore, other than in a   *
	; * development environment, or during an upgrade, an mrtns version *
	; * of this routine should not exist.                               *
	; *                                                                 *
	; * Keep these comments as single line to ensure they exist in the  *
	; * generated M code.                                               *
	; *******************************************************************
	Q 
	;
	; ---------------------------------------------------------------------
classNew	;
	;
	D setOpti^UCGM(var,$$getLevel^UCGM(var),-1)
	;
	I '$D(labels("vReNew")) D
	.	N sr S sr=$$vaddSubr("vReNew","(vTbl)","new Record",0)
	.	D addCode^UCPSLSR(sr," new vOid set vOid="_$$newObj^UCCLASS("Record""_vTbl_"""))
	.	D addCode^UCPSLSR(sr," set "_oLvn_"(vOid,-2)=0")
	.	D addCode^UCPSLSR(sr," new vT set vT=$$getPslTbl^UCXDD(vTbl,0)")
	.	D addCode^UCPSLSR(sr," if $piece(vT,""|"",4)#10 set vobj(vOid)=""""")
	.	D addCode^UCPSLSR(sr," Q vOid")
	.	Q 
	;
	S return="$$"_"vReNew"_"("_actual(2)_")"
	;
	Q 
	;
	; ---------------------------------------------------------------------
bypassSave(vOid)	; the Record instance (*1)
	N vTbl S vTbl=$$getReTable^UCGM(vobj(vOid,-1))
	;
	N vT S vT=$$getPslTbl^UCXDD(vTbl,0)
	N vDlm S vDlm=$P(vT,"|",10) ; delimiter
	;
	I ($P(vT,"|",8)'="GTM") D  ; RDB code
	.	;
	.	; Remove this when we eventually can deal with the proper passing
	.	; of an object and use of the object pointer.  See VOBJ^DBSDBASE
	.	;   #ACCEPT CR=22719; Pgm=RussellDS; Date=09/06/2006;Group=MISMATCH
	.	D VOBJ^DBSDBASE(vOid,vDlm)
	.	Q 
	E  D  ; MDB code
	.	N vMod S vMod=vobj(vOid,-2) ; record Mode
	.	N ftyp S ftyp=$P(vT,"|",4) ; record type
	.	N gbl S gbl=$$getGbl^UCXDD(vT,"vOid") ; global
	.	;
	.	I ftyp#2>0 D  ; top node depends on $D(vobj(vOid))
	..		N gblTop S gblTop=$E(gbl,1,$L(gbl)-1)
	..		I gblTop["(" S gblTop=gblTop_")"
	..		S @gblTop=vobj(vOid)
	..		Q 
	.	;
	.	I ftyp>1 S gbl=gbl_"vSub)" ; add type 10/11 node subscript
	.	;
	.	N vNod S vNod="" ; -100 node iterator
	.	N vSub ; Subscript in global
	.	;
	.	F  S vNod=$order(vobj(vOid,-100,vNod)) Q:vNod=""  D
	..		I '$D(vobj(vOid,vNod)) Q  ; 0*, 1*, etc.
	..		;
	..		I vNod?1"v".N.1"."1.N S vSub=-$E(vNod,2,1048575)
	..		E  S vSub=vNod
	..		;
	..		I $D(vobj(vOid,vNod))>1 D  ; blob or memo
	...			N gblBm S gblBm=$E(gbl,1,$L(gbl)-1)_",vBms)"
	...			N vBmi ; chunck iterator
	...			N vBms S vBms=0 ; chunck subscript
	...			;
	...			I (vobj(vOid,vNod,1)="")!(vMod=2) ZWITHDRAW:vMod>0 @gblBm Q 
	...			;
	...			F vBmi=1:450:$L(vobj(vOid,vNod,1)) S vBms=vBms+1 S @gblBm=$E(vobj(vOid,vNod,1),vBmi,vBmi+449)
	...			Q  
	..		E  D
	...			I vDlm=124 S vobj(vOid,vNod)=$$RTCHR^%ZFUNC(vobj(vOid,vNod),$char(124))
	...			;
	...			I '(vobj(vOid,vNod)=""),vMod<2 S @gbl=vobj(vOid,vNod) Q 
	...			;
	...			I vMod>0 ZWITHDRAW @gbl
	...			Q  
	..		Q  
	.	Q  
	;
	D ccAftSave(vOid,vT) ; common after save code
	;
	Q 
	;
	; ---------------------------------------------------------------------
dispose(vOid)	; object ID
	K vobj(+$G(vOid)) K vOid
	Q 
	;
	; ---------------------------------------------------------------------
new(TBL)	; table name
	N rec S rec=$$vReNew(TBL)
	Q rec
	;
	; ---------------------------------------------------------------------
get(vOid,allowNew)	;
	N vT S vT=$$getPslTbl^UCXDD($$getReTable^UCGM(vobj(vOid,-1)),0)
	;
	N vData N vEr N vRm ; NEW local vars used by RDB code
	;
	N load
	N i
	D getRecCode^UCXDD(vT,"vOid",,.load)
	;  #ACCEPT CR=18163;DATE=2005-11-29;PGM=FSCW;GROUP=XECUTE
	F i=1:1:$order(load(""),-1) XECUTE load(i)
	;
	N isNew S isNew=$T ; save $TEST as set by load code
	;
	I isNew,'allowNew S $ZS="-1,"_$ZPOS_","_"%PSL-E-RECNOFL,Record"_$P(vT,"|",1)_" not found,"_$P(vT,"|",1) X $ZT
	S vobj(return,-2)='isNew
	;
	;  #ACCEPT CR=18163;DATE=2005-11-29;PGM=FSCW;GROUP=XECUTE
	I ($P(vT,"|",8)'="GTM"),'isNew,'$$isOneNode^UCXDD(vT) XECUTE $$getUpdKey^UCXDD(vT,"return")
	Q 
	;
	; ---------------------------------------------------------------------
propGet(vOid,vProp)	;
	N vTbl S vTbl=$$getReTable^UCGM(vobj(vOid,-1))
	;
	N vP S vP=$$getPslCln^UCXDD(vTbl,vProp)
	N vT S vT=$$getPslTbl^UCXDD(vTbl,0)
	N vNod S vNod=$$getCurNode^UCXDD(vP,1)
	N vRet
	;
	I '(vNod=""),+vNod'<0 D
	.	;   #ACCEPT CR=15592;DATE=2005-09-23;PGM=FSCW;GROUP=XECUTE
	.	I '($D(vobj(vOid,vNod))#2) XECUTE $$getLodCode^UCXDD(vT,"vOid",vNod,+$get(vobj(vOid,-2)),1,"")
	.	Q 
	;
	N vCmp S vCmp=$P(vP,"|",14)
	;
	I '(vCmp=""),$P(vT,"|",4)>1 D
	.	N vpt
	.	D parseCmp^UCXDD(vCmp,.vpt)
	.	N vCnt S vCnt=$order(vpt(""),-1)
	.	N vVal
	.	N vElm
	.	S vCmp=""
	.	F vElm=2:2:vCnt S vCmp=vCmp_vpt(vElm-1)_$$QADD^%ZS($$propGet(vOid,vpt(vElm)),"""")
	.	;
	.	;   #ACCEPT CR=15592;DATE=2005-09-23;PGM=FSCW;GROUP=XECUTE
	.	XECUTE "SET vRet="_vCmp_vpt(vCnt)
	.	Q 
	;
	;  #ACCEPT CR=15592;DATE=2005-09-23;PGM=FSCW;GROUP=XECUTE
	E  I $P(vP,"|",15)=2 XECUTE "SET vRet="_$translate($$getCurExpr^UCXDD(vP,"vOid",0),$char(9),"_")
	;
	;  #ACCEPT CR=15592;DATE=2005-09-23;PGM=FSCW;GROUP=XECUTE
	E  XECUTE "SET vRet="_$$getCurExpr^UCXDD(vP,"vOid",0)
	;
	Q vRet
	;
	; ---------------------------------------------------------------------
propSet(vOid,vProp,vVal,vAudit)	;
	N vTbl S vTbl=$$getReTable^UCGM(vobj(vOid,-1))
	;
	N vP S vP=$$getPslCln^UCXDD(vTbl,vProp)
	;
	I '($P(vP,"|",14)="") S $ZS="-1,"_$ZPOS_","_"%PSL-E-INVALIDREF,"_vTbl_"."_vProp X $ZT
	;
	N vNod S vNod=$$getCurNode^UCXDD(vP,1)
	I '(vNod=""),+vNod'<0 D
	.	;   #ACCEPT CR=15592;DATE=2005-09-23;PGM=FSCW;GROUP=XECUTE
	.	XECUTE "IF '$D(vobj(vOid,"_vNod_")) "_$$getLodCode^UCXDD($$getPslTbl^UCXDD(vTbl,0),"vOid",vNod,+$get(vobj(vOid,-2)),1,"")
	.	Q 
	;
	;  #ACCEPT CR=15592;DATE=2005-09-23;PGM=FSCW;GROUP=XECUTE
	XECUTE $$getUpdCode^UCXDD(vP,"vOid","vVal",vAudit)
	;
	Q 
	;
	; ---------------------------------------------------------------------
save(vOid,vQual)	;
	N vTbl S vTbl=$$getReTable^UCGM(vobj(vOid,-1))
	;
	N vT S vT=$$getPslTbl^UCXDD(vTbl,0)
	N vFlr S vFlr=$P(vT,"|",6)
	;
	S vQual=$$fileQual^UCDB("Record.save",vQual)
	;
	Tstart (vobj):transactionid="CS" ; start transaction
	;
	I (vFlr="") D
	.	;   #ACCEPT CR=21101;DATE=2005-11-29;PGM=FSCW;GROUP=MISMATCH
	.	I $P(vT,"|",16) D ^DBSLOGIT(vOid,vobj(vOid,-2)) ; LOG if applicable
	.	D bypassSave(vOid) ; no filer, call bypassSave
	.	Q 
	E  S vFlr="^"_vFlr_"(vOid,vQual)" D @vFlr ; call filer
	;
	Tcommit:$Tlevel  ; commit transaction
	D ccAftSave(vOid,vT) ; common after save code
	;
	Q 
	;
	; ---------------------------------------------------------------------
ccAftSave(vOid,vT)	;
	K vobj(vOid,-100)
	S vobj(vOid,-2)=1
	;
	;  #ACCEPT CR=15592;DATE=2005-09-23;PGM=FSCW;GROUP=XECUTE
	I ($P(vT,"|",8)'="GTM") XECUTE $$getUpdKey^UCXDD(vT,"vOid")
	;
	Q 
	;
vSIG()	;
	Q "60785^67328^Frans S.C. Witte^22904" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vaddSubr(p1,p2,p3,p4)	; PSL.addSubrou
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I $get(p4) S p1=$$newLabel^UCGM(p1,.labels)
	E  I ($D(labels(p1))#2) D ERROR^UCGM("Subroutine exists: "_p1) Q p1
	D addSubr^UCGM(p1,p2,p3)
	Q p1
	;
vClNew(vCls)	;	Create a new object
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)=vCls
	Q vOid
	;
vReNew(vTbl)	;	new Record
	;
	new vOid set vOid=$$vClNew("Record"_vTbl_"")
	set vobj(vOid,-2)=0
	new vT set vT=$$getPslTbl^UCXDD(vTbl,0)
	if $piece(vT,"|",4)#10 set vobj(vOid)=""
	Q vOid
