DBSCLIN	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSCLIN ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	Q
CALFRMC(str1,str2,str3)	; handle call-in to evaluate computeds
	;
	N ARG N ET N PAR N RET N RM
	N I N ER
	;
	;  #ACCEPT CR=23210;PGM=KELLYP;DATE=9/20/06
	;*** Start of code by-passed by compiler
	kill (str1,str2,str3)
	;*** End of code by-passed by compiler ***
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	;
	D RUNC^ORACON
	I ER=-4 S ER=0 S RM=""
	E  I ER Q "Database connection error"
	;
	F I=1:1:$L(str2,$char(31)) D
	.	S PAR=$piece(str2,$char(31),I)
	.	I PAR'=+PAR S $piece(str2,$char(31),I)=$S(PAR'["""":""""_PAR_"""",1:$$QADD^%ZS(PAR,""""))
	.	Q 
	;
	S str2=$translate(str2,$char(31),",")
	;
	; process user/terminal information in str3
	I $D(str3) D
	.	Q:str3=" " 
	.	S opt=$E(str3,1) S ptoken=$E(str3,2,99)
	.	I opt=1 D EXECPID(ptoken)
	.	E  D EXECTKN(ptoken)
	.	Q 
	;
	D SYSVAR^SCADRV0()
	S ARG="S RET="_str1_"("_str2_")"
	;  #ACCEPT DATE=07/11/04; CR=21139; PGM=Badri Giridharan
	XECUTE ARG
	Q RET
	;
EXECTKN(ptoken)	;
	;
	N tkn,vop1 S tkn=$$vDb3(ptoken,.vop1)
	;
	I '$G(vop1) D  Q 
	.	S (%UID,%UCLS)=""
	.	Q 
	;
	S %UID=$P(tkn,$C(124),2)
	S %UCLS=$P(tkn,$C(124),6)
	;
	Q 
	;
EXECPID(ptoken)	;
	;
	N savedrv,vop1,vop2,vop3 S vop1=ptoken,savedrv=$$vDb4(ptoken,.vop2)
	 S vop3="" N von S von="" F  S von=$O(^TMP(0,"SAVEDRV",vop1,von)) quit:von=""  S vop3=vop3_^TMP(0,"SAVEDRV",vop1,von)
	;
	I '$G(vop2) D  Q 
	.	S (%UID,%UCLS)=""
	.	Q 
	;
	S drvvars=vop3
	;
	;  #ACCEPT DATE=03/19/07; CR=24702; PGM=Badri Giridharan; GROUP=execute;
	XECUTE drvvars
	;
	Q 
	;
vSIG()	;
	Q "60808^44184^Badrinath Giridharan^2905" ; Signature - LTD^TIME^USER^SIZE
	;
vDb3(v1,v2out)	;	voXN = Db.getRecord(TOKEN,,1,-2)
	;
	N tkn
	S tkn=$G(^TOKEN(v1))
	I tkn="",'$D(^TOKEN(v1))
	S v2out='$T
	;
	Q tkn
	;
vDb4(v1,v2out)	;	voXN = Db.getRecord(SAVEDRV,,1,-2)
	;
	N savedrv
	S savedrv=$G(^TMP(0,"SAVEDRV",v1))
	I savedrv="",'$D(^TMP(0,"SAVEDRV",v1))
	S v2out='$T
	;
	Q savedrv
	;
vtrap1	;	Error trap
	;
	N error S error=$ZS
	;
	S ER=1
	S ET=$P(error,",",3)_"-"_$P(error,",",2)
	S RM=$P(error,",",4)
	;
	I ET["%GTM-" D ZE^UTLERR Q 
	D ^UTLERR
	Q 
