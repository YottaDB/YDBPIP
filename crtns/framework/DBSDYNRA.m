 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSDYNRA ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
 ;  #PACKAGE framework
 ;  #OPTION ResultClass ON
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
classNew ; 
 ;
 ; Implementation of Class.new("Record",tablename)
 I (class="Record") D
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	N lvl S lvl=$$getLevel^UCGM(var)
 .	;   #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 .	D setOpti^UCGM(var,lvl,-1)
 .	;
 .	I '$$hasSubr^UCGM("vReNew") D
 ..		N sr S sr=$$vaddSubr("vReNew","(vS,vTbl)","new Record",0)
 ..		D addCode^UCPSLSR(sr," new vT,vXcode")
 ..		D addCode^UCPSLSR(sr," set vT=$$getPslTbl^UCXDD(vTbl,0)")
 ..		D addCode^UCPSLSR(sr," set vXcode=$$getNewCode^UCXDD(vT,""vOid"",0,0) xecute vXcode")
 ..		D addCode^UCPSLSR(sr," quit vOid")
 ..		Q 
 .	;
 .	S return="$$"_"vReNew"_"("_$$newObjSt^UCCLASS($get(var))_","_actual(2)_")"
 .	Q 
 ;
 ; M Implementation of Class.new("RecordTABLE", keys)
 E  D
 .	;
 .	N tableName S tableName=$$tableNameOf^PSLClass($$QSUB^%ZS(actual(1),""""))
 .	N td S td=$$getPslTbl^UCXDD(tableName,0)
 .	;
 .	S return="$$vcdmNew^Record"_tableName_"()"
 .	;
 .	; Add initialization of keys
 .	I '($get(actual(2))="") D
 ..		;
 ..		N assignCode S assignCode=$$akey2asgn^UCDB(td,var,actual(2),1)
 ..		;
 ..		I '(assignCode="") S pslP1Ap=assignCode ;PSL.return = PSL.return_ assignCode
 ..		Q 
 .	Q 
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
bypassSave(vOid) ; the Record instance (*1)
 ;
 N vTbl S vTbl=$$tableNameOf^PSLClass($piece(vobj(vOid,-1),$char(9)))
 ;
 N vT S vT=$$getPslTbl^UCXDD(vTbl,0)
 N vDlm S vDlm=$P(vT,"|",10) ; delimiter
 ;
 N rights S rights=$$checkAccessRights^UCXDD(vT,0)
 N auditLog S auditLog=$$getLogging^UCXDD(vT,0)
 ;
 I ($P(vT,"|",8)'="GTM") D  ; RDB code
 .	;
 .	N where S where=$$getPrimaryKeyWhere^UCXDD(vT)
 .	;
 .	;   #ACCEPT Date=09/30/2007; Pgm=RussellDS; CR=29295; Group=MISMATCH
 .	D rdbSaveC^UCDBRT(vOid,vDlm,where)
 .	Q 
 E  I (((","_rights_",")[",insert,")!((","_rights_",")[",insertRestrict,")!((","_rights_",")[",update,")!((","_rights_",")[",updateRestrict,")!((","_auditLog_",")[",insert,")!((","_auditLog_",")[",update,")!((","_auditLog_",")[",delete,")) D  Q 
 .	;
 .	;   #ACCEPT GROUP=ACCESS;CR=30801;DATE=2008-06-21;PGM=RussellDS
 .	D save(vOid,$$bypassQual^UCRECORD)
 .	Q 
 E  D  ; MDB code
 .	N vMod S vMod=vobj(vOid,-2) ; record Mode
 .	N vTyp S vTyp=$P(vT,"|",4) ; record type
 .	N vGbl S vGbl=$$getGbl^UCXDD(vT,"vOid") ; global
 .	;
 .	I vTyp#2>0 D  ; top node depends on $D(vobj(vOid))
 ..		N vTop S vTop=$E(vGbl,1,$L(vGbl)-1)
 ..		I vTop["(" S vTop=vTop_")"
 ..		S @vTop=vobj(vOid)
 ..		Q 
 .	;
 .	I vTyp>1 S vGbl=vGbl_"vSub)" ; add type 10/11 node subscript
 .	;
 .	N vNod S vNod="" ; -100 node iterator
 .	N vSub ; Subscript in global
 .	;
 .	F  S vNod=$order(vobj(vOid,-100,vNod)) Q:vNod=""  D
 ..		I '$D(vobj(vOid,vNod)),'($E(vNod,$L(vNod)-2+1,1048575)=",1") Q  ; 0*, 1*, etc.
 ..		;
 ..		I vNod?1"v".N.1"."1.N S vSub=-$E(vNod,2,1048575)
 ..		E  I ($E(vNod,$L(vNod)-2+1,1048575)=",1") S vSub=$E(vNod,1,$L(vNod)-2)
 ..		E  S vSub=vNod
 ..		;
 ..		I $D(vobj(vOid,vSub))>1 D  ; blob or memo
 ...			N vGblBm S vGblBm=$E(vGbl,1,$L(vGbl)-1)_",vBms)"
 ...			N vBmi ; chunck iterator
 ...			N vBms S vBms=0 ; chunck subscript
 ...			;
 ...			I (vobj(vOid,vSub,1)="")!(vMod=2) D  Q 
 ....				;
 ....				;      #ACCEPT Date=01/12/2008; Pgm=RussellDS; CR=27800; Group=Bypass
 ....				;*** Start of code by-passed by compiler
 ....				IF (vMod>0) ZWITHDRAW @vGbl
 ....				;*** End of code by-passed by compiler ***
 ....				Q 
 ...			;
 ...			F vBmi=1:450:$L(vobj(vOid,vSub,1)) S vBms=vBms+1 S @vGblBm=$E(vobj(vOid,vSub,1),vBmi,vBmi+449)
 ...			Q  
 ..		E  D
 ...			I vDlm=124 S vobj(vOid,vNod)=$$RTCHR^%ZFUNC(vobj(vOid,vNod),$char(124))
 ...			;
 ...			I '(vobj(vOid,vNod)=""),vMod<2 S @vGbl=vobj(vOid,vNod) Q 
 ...			;
 ...			;     #ACCEPT Date=01/12/2008; Pgm=RussellDS; CR=27800; Group=Bypass
 ...			;*** Start of code by-passed by compiler
 ...			IF vMod>0 ZWITHDRAW @vGbl
 ...			;*** End of code by-passed by compiler ***
 ...			Q  
 ..		Q  
 .	Q  
 ;
 D ccAftSave(vOid,vT) ; common after save code
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
dispose(vOid) ; object ID
 K vobj(+$G(vOid)) K vOid
 Q 
 ;
 ; ---------------------------------------------------------------------
new(TBL) ; table name
 N rec S rec=$$vReNew($ST,$ZCONVERT(TBL,"U"))
 Q rec
 ;
 ; ---------------------------------------------------------------------
get(vOid,allowNew) ; accept non-existing row?
 ;
 N vT S vT=$$getPslTbl^UCXDD($$tableNameOf^PSLClass($piece(vobj(vOid,-1),$char(9))),0)
 ;
 N vData N vEr N vRm ; NEW local vars used by RDB code
 ;
 N vLoad
 N vI
 D getRecCode^UCDB(vT,"vOid",,.vLoad)
 ;  #ACCEPT CR=18163;DATE=2005-11-29;PGM=FSCW;GROUP=XECUTE
 F vI=1:1:$order(vLoad(""),-1) XECUTE vLoad(vI)
 ;
 N isNew
 ;
 ;  #ACCEPT Date=01/12/2008; Pgm=RussellDS; CR=27800; Group=Bypass
 ;*** Start of code by-passed by compiler
 SET isNew=$T
 ;*** End of code by-passed by compiler ***
 ;
 N rights S rights=$$checkAccessRights^UCXDD(vT,0)
 ;
 I (((","_rights_",")[",select,")!((","_rights_",")[",selectRestrict,")) D
 .	;
 .	N isOK
 .	N table S table=$P(vT,"|",1)
 .	;
 .	;   #ACCEPT Date=05/21/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	xecute ("S isOK=$$vselectOK^Record"_table_"(vOid,%UCLS)")
 .	;*** End of code by-passed by compiler ***
 .	;
 .	; No access rights for tabel ~p1
 .	I 'isOK S $ZE="0,"_$ZPOS_","_"%PSL-E-ACCESS,"_$$^MSG(6754,$P(vT,"|",1)),$EC=",U1001,"
 .	Q 
 ;
 I isNew,'allowNew S $ZE="0,"_$ZPOS_","_"%PSL-E-RECNOFL,Record"_$P(vT,"|",1)_" not found,"_$P(vT,"|",1),$EC=",U1001,"
 S vobj(vOid,-2)='isNew
 K vobj(vOid,-100)
 ;
 ;  #ACCEPT CR=18163;DATE=2005-11-29;PGM=FSCW;GROUP=XECUTE
 I ($P(vT,"|",8)'="GTM"),'isNew,'$$isOneNode^UCXDD(vT) XECUTE $$getUpdKey^UCXDD(vT,"vOid")
 Q 
 ;
 ; ---------------------------------------------------------------------
propGet(vOid,vProp) ; column expression (*2)
 ;
 N vTbl S vTbl=$$tableNameOf^PSLClass($piece(vobj(vOid,-1),$char(9)))
 ;
 S vProp=$ZCONVERT(vProp,"U") ; Indirection may use lowercase
 ;
 N vP S vP=$$getPslCln^UCXDD(vTbl,vProp)
 N vT S vT=$$getPslTbl^UCXDD(vTbl,0)
 N vNod S vNod=$$getCurNode^UCXDD(vP,1)
 N vRet
 ;
 I '(vNod=""),+vNod'<0 D
 .	N lvpm
 .	I ($P(vT,"|",8)'="GTM") D
 ..		S lvpm(-161)="vobj(vOid,-161,"
 ..		S lvpm(-162)="vobj(vOid,-162,"
 ..		Q 
 .	;   #ACCEPT CR=15592;DATE=2005-09-23;PGM=FSCW;GROUP=XECUTE
 .	I '($D(vobj(vOid,vNod))#2) XECUTE $$getLodCode^UCXDD(vT,"vOid",$$getPurNode^UCXDD(vP),+$get(vobj(vOid,-2)),1,.lvpm)
 .	;
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
propSet(vOid,vProp,vVal,vAudit,vExternal) ; external formats? (*5)
 ;
 N vTbl S vTbl=$$tableNameOf^PSLClass($piece(vobj(vOid,-1),$char(9)))
 N vXcode
 ;
 ;  #ACCEPT Date=01/12/2008; Pgm=RussellDS; CR=27800; Group=Bypass
 ;*** Start of code by-passed by compiler
 NEW vTestIn SET vTestIn=$T
 ;*** End of code by-passed by compiler ***
 ;
 S vProp=$ZCONVERT(vProp,"U") ; Indirection may use lowercase
 ;
 N vP S vP=$$getPslCln^UCXDD(vTbl,vProp)
 ;
 I '($P(vP,"|",14)="") S $ZE="0,"_$ZPOS_","_"%PSL-E-INVALIDREF,"_vTbl_"."_vProp,$EC=",U1001,"
 ;
 N vNod S vNod=$$getCurNode^UCXDD(vP,1)
 ;
 I '(vNod=""),+vNod'<0,'(vNod[",")!vAudit D
 .	N lvpm
 .	N tblDes S tblDes=$$getPslTbl^UCXDD(vTbl,0)
 .	I ($P(tblDes,"|",8)'="GTM") D
 ..		S lvpm(-161)="vobj(vOid,-161,"
 ..		S lvpm(-162)="vobj(vOid,-162,"
 ..		Q 
 .	;   #ACCEPT CR=15592;DATE=2005-09-23;PGM=FSCW;GROUP=XECUTE
 .	XECUTE "IF '$D(vobj(vOid,"_vNod_")) "_$$getLodCode^UCXDD(tblDes,"vOid",$$getPurNode^UCXDD(vP),+$get(vobj(vOid,-2)),1,.lvpm)
 .	Q 
 ;
 I $get(vExternal) D  ; convert external to internal
 .	N vTyp S vTyp=$P(vP,"|",6)
 .	;   #ACCEPT GROUP=ACCESS;CR=35741;DATE=2008-10-23;PGM=Frans S.C. Witte
 .	I "CDLU"[vTyp S vVal=$$INT^%ZM(vVal,vTyp)
 .	;   #ACCEPT GROUP=ACCESS;CR=35741;DATE=2008-10-23;PGM=Frans S.C. Witte
 .	I "$N"[vTyp,'(vVal="")!$P(vP,"|",9) S vVal=+$$INT^%ZM(vVal,vTyp,,$P(vP,"|",8))
 .	Q 
 ;
 S vXcode=$$getUpdCode^UCXDD(vP,"vOid","vVal",vAudit,1)
 I '($ZLENGTH(vXcode)'>1980) D
 .	N vI
 .	F vI=1:1:$L(vXcode,$char(9)) D
 ..		;    #ACCEPT CR=29295;Date=2007-10-05;PGM=RussellDS;GROUP=XECUTE
 ..		XECUTE $piece(vXcode,$char(9),vI)
 ..		Q 
 .	Q 
 ;  #ACCEPT CR=15592;DATE=2005-09-23;PGM=FSCW;GROUP=XECUTE
 E  XECUTE vXcode
 ;
 ; Make sure $T is same as on entry
 ;  #ACCEPT Date=01/12/2008; Pgm=RussellDS; CR=27800; Group=Bypass
 ;*** Start of code by-passed by compiler
 IF vTestIn
 ;*** End of code by-passed by compiler ***
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
save(vOid,vQual) ; applicable filer qualifiers
 ;
 N vTbl S vTbl=$$tableNameOf^PSLClass($piece(vobj(vOid,-1),$char(9)))
 ;
 N vT S vT=$$getPslTbl^UCXDD(vTbl,0)
 N vFlr
 ;
 S vQual=$$fileQual^UCDB("Record.save",vQual)
 ;
 TS (vobj):transactionid="CS" ; start transaction
 ;
 S vFlr="vSave^Record"_vTbl_"(vOid,vQual,0)"
 D @vFlr ; call save method
 ;
  TC:$TL  ; commit transaction
 D ccAftSave(vOid,vT) ; common after save code
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
ccAftSave(vOid,vT) ; 
 K vobj(vOid,-100)
 S vobj(vOid,-2)=1
 ;
 ;  #ACCEPT CR=15592;DATE=2005-09-23;PGM=FSCW;GROUP=XECUTE
 I ($P(vT,"|",8)'="GTM") XECUTE $$getUpdKey^UCXDD(vT,"vOid")
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61339^56517^Dan Russell^29730" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vaddSubr(p1,p2,p3,p4) ; PSL.addSubrou
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I $get(p4) S:$E(p1,1)'="v" p1="v"_p1 S p1=$$findSubr^UCGM(p1,"")
 E  I $$hasSubr^UCGM(p1) D ERROR^UCGM("Subroutine exists: "_p1) Q p1
 D addSubr^UCGM(p1,p2,p3)
 Q p1
 ;
vReNew(vS,vTbl) ; new Record
 ;
 new vT,vXcode
 set vT=$$getPslTbl^UCXDD(vTbl,0)
 set vXcode=$$getNewCode^UCXDD(vT,"vOid",0,0) xecute vXcode
 quit vOid
