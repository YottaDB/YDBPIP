FORMCOPY	;
	;
	; **** Routine compiled from DATA-QWIK Procedure FORMCOPY ****
	;
	; 08/30/2007 13:48 - joynerd
	;
	;
	N %TAB N %READ
	N CO N FORM N VAR N VFMQ N XCO1 N XVAR1
	;
	S %TAB("CO")="[UTBLFORMVAR]CO"
	S %TAB("FORM")="[UTBLFORMVAR]FORM"
	S %TAB("VAR")="[UTBLFORMVAR]VAR/TBL=[UTBLFORMVAR]"
	S %TAB("XCO1")="/DES=Copy to new Company Code/LEN=12/TYP=T/TBL=[UTBLCO]DES/REQ/XPP=S XVAR1=$$POST1^FORMCOPY(X,FORM,VAR)"
	S %TAB("XVAR1")="/DES=Variation/LEN=3/TYP=N/XPP=D POST^FORMCOPY(XCO1,FORM,X)/REQ/XPR=D DSP^DBSMACRO(XVAR1,5)"
	S %READ="@@%FN/REV/CEN,,CO,FORM,VAR,,,XCO1,XVAR1"
	D ^UTLREAD Q:VFMQ="Q" 
	;
	N form1 S form1=$$vDb1(CO,FORM,VAR)
	N form2 S form2=$$vReCp1(form1)
	;
	S vobj(form2,-3)=XCO1
	S vobj(form2,-5)=XVAR1
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(form2) S vobj(form2,-2)=1 Tcommit:vTp  
	;
	K vobj(+$G(form1)),vobj(+$G(form2)) Q 
	;
	;----------------------------------------------------------------
POST1(XCOD,XFORMD,XVARD)	;
	;----------------------------------------------------------------
	;
	N formvar,vop1 S formvar=$$vDb3(XCOD,XFORMD,XVARD,.vop1)
	I $G(vop1) Q $O(^UTBL("FORMVAR",XCOD,XFORMD,""),-1)+1
	Q XVARD
	;
	;----------------------------------------------------------------
POST(XCOD,XFORMD,XVARD)	;
	;----------------------------------------------------------------
	;
	N frmvar,vop1 S frmvar=$$vDb3(XCOD,XFORMD,XVARD,.vop1)
	I $G(vop1) S ER=1 D SETERR^DBSEXECU("4475","MSG",)
	;
	I ((FORM="IRAMADNOT")!(FORM="IRAMADMIN"))&($O(^UTBL("FORMVAR",XCO1,FORM,""),-1)) S ER=1 S RM=$$^MSG(4474,FORM)
	Q 
	;  #OPTION ResultClass ON
vSIG()	;
	Q "60295^32769^Jaimano Prakash^2000" ; Signature - LTD^TIME^USER^SIZE
	;
vDb1(v1,v2,v3)	;	vobj()=Db.getRecord(UTBLFORMVAR,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordUTBLFORMVAR"
	S vobj(vOid)=$G(^UTBL("FORMVAR",v1,v2,v3))
	I vobj(vOid)="",'$D(^UTBL("FORMVAR",v1,v2,v3))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,UTBLFORMVAR" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDb3(v1,v2,v3,v2out)	;	voXN = Db.getRecord(UTBLFORMVAR,,1,-2)
	;
	N formvar
	S formvar=$G(^UTBL("FORMVAR",v1,v2,v3))
	I formvar="",'$D(^UTBL("FORMVAR",v1,v2,v3))
	S v2out='$T
	;
	Q formvar
	;
vReCp1(v1)	;	RecordUTBLFORMVAR.copy: UTBLFORMVAR
	;
	Q $$copy^UCGMR(form1)
	;
vReSav1(form2)	;	RecordUTBLFORMVAR saveNoFiler(LOG)
	;
	D ^DBSLOGIT(form2,vobj(form2,-2))
	S ^UTBL("FORMVAR",vobj(form2,-3),vobj(form2,-4),vobj(form2,-5))=$$RTBAR^%ZFUNC($G(vobj(form2)))
	Q
