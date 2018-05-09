PBSMSQL(REPLY,STFFLG,RECORD,RECTYP,CONTEXT)	; MSQL Service Class Driver
	;
	; **** Routine compiled from DATA-QWIK Procedure PBSMSQL ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	;
	;  #OPTIMIZE
	;
	N RETVAL
	S RETVAL=0
	D MAIN(.RETVAL,.REPLY)
	;
	; Return Value: 0 = success, 1 = processing error
	Q RETVAL
	;
MAIN(RETVAL,REPLY)	; Main processing for MSQL Service Class Driver
	;
	N FLD N PTR N SQLCNT N SQLCOD N SQLDTA N SQLEXPR N SQLIND N SQLPAR N SQLREC N SQLTOK N verrors N vsupv N ZUID
	;
	; Protect system defined edit masks & initialize to SQL defaults
	N %MSKC N %MSKD N %MSKE N %MSKL N %MSKN
	S (%MSKC,%MSKD,%MSKE,%MSKL,%MSKN)=""
	;
	S PTR=$$LV2V^MSG(RECORD,.FLD)
	;
	; Invalid SQL Command
	I $get(FLD(1))="" D SETERR^DBSEXECU("STBLER","MSG",8564) S RETVAL=$$ERRRPLY Q 
	;
	; Overlay saved context
	I $get(CONTEXT)'="" D PARSPAR^%ZS(CONTEXT,.SQLPAR)
	;
	; Overlay parameters from this message
	I $get(FLD(2))'="" D PARSPAR^%ZS(FLD(2),.SQLPAR)
	;
	I ($D(SQLPAR("FORMAT"))#2) S ER=$$FORMAT(SQLPAR("FORMAT")) I ER S RETVAL=$$ERRRPLY Q 
	I ($D(SQLPAR("DATE"))#2) S %MSKD=SQLPAR("DATE")
	I ($D(SQLPAR("DEC"))#2) S (%MSKE,%MSKN)=SQLPAR("DEC")
	;
	; Supvervisory override
	I $get(FLD(3))'="" D SPV(FLD(3),.vsupv) I ER S RETVAL=$$ERRRPLY Q 
	;
	; Need ODBC V2.0 to match the server software
	; Version number of client message is not compatible with server
	I $get(SQLPAR("ODBC"))=1 D SETERR^DBSEXECU("STBLER","MSG",2951) S RETVAL=$$ERRRPLY Q 
	;
	; Already pre-processed by the ODBC driver
	I ($get(SQLPAR("ICODE"))=1)!($get(SQLPAR("ODBC"))=2) S SQLEXPR=$$TOKEN^%ZS(FLD(1),.SQLTOK,"'")
	;
	; Otherwise, tokenize the string
	E  S SQLEXPR=$$SQL^%ZS(FLD(1),.SQLTOK) I ER S RETVAL=$$ERRRPLY Q 
	;
	; Check 24x7 access
	; Database Update Restricted
	I ($get(%STFHOST)),('$$VALID(SQLEXPR,SQLTOK)) D SETERR^DBSEXECU("STBLER","MSG",7912) S RETVAL=$$ERRRPLY Q 
	;
	; Store and forward, force check of store and forward user class in sqlbuf
	I STFFLG D
	.	S SQLPAR("SPVOVR")=1
	.	S vsupv("~")=""
	.	I vsupv("~")="" S UCLS="MGR"
	.	Q 
	;
	S ER=$$^SQL(SQLEXPR,.SQLPAR,.SQLCOD,.SQLDTA,.SQLCNT,.SQLIND,.SQLTOK)
	;
	; Returns status, error code
	S SQLCOD=$$SQLCOD($get(SQLCOD),.ER)
	;
	; Apply supvervisory override when they exist and authorizations exist, but not
	; when they have already been checked by COMMIT^SQLBUF (verrors=1)
	I $D(verrors),'$get(verrors),$D(vsupv),(+$get(verrors)=0) D SPVOVR(.verrors)
	;
	; Check override array
	I 'ER,'$D(verrors) D  S RETVAL=0 Q 
	.	;
	.	; SQL state code
	.	S FLD(1)=SQLCOD
	.	;
	.	; Stored procedure name
	.	S FLD(2)=$get(RM)
	.	;
	.	; Number of rows returned
	.	S FLD(3)=$get(SQLCNT)
	.	;
	.	; Results table
	.	S FLD(4)=$get(SQLDTA)
	.	;
	.	; Column protection attributes
	.	S FLD(5)=$piece($get(SQLIND),$char(0),1)
	.	;
	.	; Column format attributes 03/03/2000
	.	S FLD(6)=$piece($get(SQLIND),$char(0),2)
	.	;
	.	; Convert to pack format
	.	I FLD(5)'="" S FLD(5)=$$COLOUT^%ZFUNC(FLD(5))
	.	;
	.	S REPLY=$$V2LV^MSG(.FLD)
	.	;
	.	Q 
	;
	; Error reply
	I ER S RETVAL=$$ERRRPLY Q 
	;
	; Got here because of restrictions
	Trollback:$Tlevel  ; Non-fatal restrictions
	;
	; Override AU message
	S REPLY=$$OVRMSG(.verrors)
	S RETVAL=1
	;
	Q 
	;
SPV(OVR,vsupv)	; Convert override information into vsupv() array
	;
	N ET N I N SPVREST N SPVUID N UCLS N V N Z N ZOVR
	;
	N DONE
	;
	K vsupv
	;
	S ER=0
	S DONE=0
	;
	I '(OVR="") D
	.	; Supv override
	.	S Z=$$LV2V^MSG(OVR,.ZOVR)
	.	;
	.	F I=1:1 Q:'$D(ZOVR(I))  D  Q:ER!DONE 
	..		K V
	..		;
	..		; Type|UID|PSW
	..		S Z=$$LV2V^MSG(ZOVR(I),.V)
	..		S SPVUID=$get(V(2))
	..		;
	..		I (SPVUID="") D  Q:ER 
	...			I 0 ;*     if CUVAR.AUTOAUTH = 2 set SPVUID = %UserID
	...			E  D SETERR^DBSEXECU("CUVAR","MSG",1504) ; Invalid user ID
	...			Q 
	..		E  D  Q:ER 
	...			; Invalid user
	...			I '($D(^SCAU(1,SPVUID))#2) D
	....				D SETERR^DBSEXECU("SCAU","MSG",7591,SPVUID)
	....				S DONE=1
	....				Q 
	...			; Invalid password
	...			I '$$VALIDATE^SCADRV1($get(V(3)),SPVUID) D
	....				D SETERR^DBSEXECU("SCAU","MSG",1419)
	....				S DONE=1
	....				Q 
	...			Q 
	..		;
	..		S SPVREST=$piece(V(1),"_",3)
	..		S vsupv(SPVREST)=SPVUID
	..		;
	..		I SPVREST="*" S DONE=1
	..		Q 
	.	Q 
	Q 
	;
SPVOVR(OVR)	; Apply override logic
	;
	N rest N buf N ovrsav
	N DONE
	N ET N IDENT N SEQ N UCLSARR N UCLS N UID N ZTBL
	;
	I '($D(vsupv)) Q 
	;
	S buf="" S DONE=0 S SEQ=""
	;
	I ($D(vsupv("*")))!($D(vsupv("~"))) D
	.	I ($D(vsupv("*"))) D
	..		S UID=vsupv("*")
	..		I '($D(UCLSARR(UID))) D
	...			N scau S scau=$G(^SCAU(1,UID))
	...			;
	...			S UCLSARR(UID)=$P(scau,$C(124),5)
	...			Q 
	..		S UCLS=UCLSARR(UID)
	..		Q 
	.	E  D
	..		S UID=%UID
	..		S UCLS=vsupv("~")
	..		Q 
	.	;
	.	F  S buf=$order(OVR(buf)) Q:(buf="")!DONE  D
	..		F  S SEQ=$order(OVR(buf,SEQ)) Q:(SEQ="")  D
	...			;
	...			; Error type
	...			S ET=$piece(OVR(buf,SEQ),"|",3)
	...			;
	...			; can it be overridden? if not quit
	...			I '($D(^UTBL("XBAD",ET,UCLS))#2) S DONE=1 Q 
	...			S ZTBL=$piece(OVR(buf),"|",1)
	...			S IDENT=$piece(OVR(buf),"|",2)
	...			;
	...			I ZTBL="CIF" D
	....				N xbadc S xbadc=$$vDb2(TJD,UID,IDENT,SEQ,ET)
	....			 S $P(vobj(xbadc),$C(124),1)=UID
	....			 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DAYXBCFL(xbadc,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(xbadc,-100) S vobj(xbadc,-2)=1 Tcommit:vTp  
	....				K vobj(+$G(xbadc)) Q 
	...			E  D
	....				I IDENT["," S IDENT=$piece(IDENT,",",2)
	....				N xbad,vop1,vop2,vop3,vop4,vop5,vop6 S vop5=TJD,vop4=UID,vop3=IDENT,vop2=SEQ,vop1=ET,xbad=$$vDb7(TJD,UID,IDENT,SEQ,ET,.vop6)
	....			 S $P(xbad,$C(124),1)=UID
	....			 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^DAYEND(vop5,"XBAD",vop4,vop3,vop2,vop1)=$$RTBAR^%ZFUNC(xbad) S vop6=1 Tcommit:vTp  
	....				Q 
	...			S ovrsav(buf,SEQ)=OVR(buf,SEQ)
	...			K OVR(buf,SEQ)
	...			I $D(OVR(buf))=1 S ovrsav(buf)=OVR(buf) K OVR(buf)
	...			Q 
	..		Q 
	.	Q 
	E  D
	.	F  S buf=$order(OVR(buf)) Q:(buf="")  D
	..		F  S SEQ=$order(OVR(buf,SEQ)) Q:(SEQ="")!DONE  D
	...			S ET=$piece(OVR(buf,SEQ),"|",3) ; Error type
	...			;
	...			;No match
	...			I '($D(vsupv(ET))) S DONE=1
	...			;
	...			S UID=vsupv(ET)
	...			I '($D(UCLSARR(UID))) D
	....				N scau S scau=$G(^SCAU(1,UID))
	....				S UCLSARR(UID)=$P(scau,$C(124),5)
	....				Q 
	...			S UCLS=UCLSARR(UID)
	...			I '($D(^UTBL("XBAD",ET,UCLS))#2) S DONE=1 Q 
	...			S ZTBL=$piece(OVR(buf),"|",1)
	...			S IDENT=$piece(OVR(buf),"|",2)
	...			I ZTBL="CIF" D
	....				N xbadc S xbadc=$$vDb2(TJD,UID,IDENT,SEQ,ET)
	....			 S $P(vobj(xbadc),$C(124),1)=UID
	....			 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DAYXBCFL(xbadc,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(xbadc,-100) S vobj(xbadc,-2)=1 Tcommit:vTp  
	....				K vobj(+$G(xbadc)) Q 
	...			E  D
	....				I IDENT["," S IDENT=$piece(IDENT,",",2)
	....				N xbad,vop7,vop8,vop9,vop10,vop11,vop12 S vop11=TJD,vop10=UID,vop9=IDENT,vop8=SEQ,vop7=ET,xbad=$$vDb7(TJD,UID,IDENT,SEQ,ET,.vop12)
	....			 S $P(xbad,$C(124),1)=UID
	....			 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^DAYEND(vop11,"XBAD",vop10,vop9,vop8,vop7)=$$RTBAR^%ZFUNC(xbad) S vop12=1 Tcommit:vTp  
	....				Q 
	...			S ovrsav(buf,SEQ)=OVR(buf,SEQ)
	...			K OVR(buf,SEQ) ; Delete this entry
	...			I ($D(OVR(buf)))=1 D
	....				S ovrsav(buf)=OVR(buf)
	....				K OVR(buf) ; Delete empty buffer
	....				Q 
	...			Q 
	..		Q 
	.	Q 
	;
	; If restrictions exist that can not be authorized, move those that could be back
	; into OVR array and set top level of OVR to indicate that restrictions have been
	; checked to prevent re-processing them since COMMIT^SQLBUF and the main
	; label of this routine call this label.
	;
	I ($D(OVR)) D
	.	S (rest,SEQ)="" S OVR=1
	.	F  S rest=$order(ovrsav(rest)) D  Q:(rest="") 
	..		I (($D(ovrsav(rest))#2)) S OVR(rest)=ovrsav(rest)
	..		F  S SEQ=$order(ovrsav(rest,SEQ)) D  Q:(SEQ="") 
	...			S OVR(rest,SEQ)=ovrsav(rest,SEQ)
	...			Q 
	..		Q 
	.	Q 
	;
	Q 
	;
OVRMSG(OVR)	; Build override message
	N vret
	;
	N CNT
	N AU N BUF N FID N KEYS N MSG N SEQ N Z N ZAU
	;
	S BUF=""
	S CNT=0
	S SEQ=""
	;
	F  S BUF=$order(OVR(BUF)) Q:BUF=""  D
	.	;
	.	; Table name
	.	S FID=$piece(OVR(BUF),"|",1)
	.	;
	.	; Access keys
	.	S KEYS=$piece(OVR(BUF),"|",2)
	.	;
	.	F  S SEQ=$order(OVR(BUF,SEQ)) Q:SEQ=""  D
	..		;
	..		S Z=OVR(BUF,SEQ)
	..		S AU(1)="XBAD_"_FID_"_"_$piece(Z,"|",3)
	..		S AU(2)=""
	..		;
	..		; Error description
	..		S AU(3)=$piece(Z,"|",8)
	..		;
	..		; Access keys
	..		S AU(4)=KEYS
	..		;
	..		; SPVST flag
	..		S AU(5)=""
	..		S CNT=CNT+1
	..		;
	..		; Convert to LV format
	..		S ZAU(CNT)=$$V2LV^MSG(.AU) ; 11059 - Use CNT not "1"
	..		;
	..		Q 
	.	Q 
	;
	S MSG(1)="AU"
	S MSG(2)=""
	S MSG(3)=$$V2LV^MSG(.ZAU)
	;
	S vret=$$V2LV^MSG(.MSG) Q vret
	;
ERRRPLY()	; Build standard server error reply
	;
	I $get(RM)="",$D(RM)>1 S RM=$get(RM(1))_" "_$get(RM(2))
	;
	S REPLY=$$ERRMSG^PBSUTL($get(RM),$get(ET))
	;
	; If off-line, put into exception
	I STFFLG D STF
	;
	Q 1
	;
SQLCOD(SQLCOD,ER)	; Return appropriate SQL status
	;
	N RETURN
	;
	S SQLCOD=$S(SQLCOD=100:"1500",1:+SQLCOD)
	;
	I SQLCOD>0,SQLCOD<1500 S SQLCOD=0
	;
	S RETURN=$translate($J("",5-$L(SQLCOD))," ","0")_SQLCOD ; Zero pad
	;
	;Invalid stored procedure name
	I (RETURN=50001) S ER=0
	;
	Q RETURN
	;
FORMAT(FMT)	; Redefine format masks for this message
	;
	N X
	;
	; Load format from table
	N tfmt,vop1 S tfmt=$$vDb8(FMT,.vop1)
	;
	; Invalid format
	I $G(vop1)=0 S RM=$$^MSG(1350,FMT) Q 1
	;
	S %MSKD=$P(tfmt,$C(124),7) ; Date mask
	S %MSKL=$P(tfmt,$C(124),8) ; Logical mask
	S %MSKC=$P(tfmt,$C(124),9) ; Clock time mask
	S %MSKE=$P(tfmt,$C(124),10) ; Currency mask
	S %MSKN=$P(tfmt,$C(124),11) ; Numeric mask
	;
	Q 0
	;
STF	; Store and forward handling of rejected updates
	;
	N NSEQ N ZBRCD N ZBUF N ZDATE N ZTOKEN N ZUID
	;
	S ZTOKEN=%TOKEN
	;
	; Buffer Name
	N rs,vos1,vos2,vos3 S rs=$$vOpen1()
	I '$G(vos1) Q  ; Missing buffer name
	I $$vFetch1() S ZBUF=rs
	;
	N token,vop1 S token=$$vDb9(ZTOKEN,.vop1)
	I $G(vop1)=0 Q 
	S ZUID=$P(token,$C(124),2)
	;
	N scau,vop2 S scau=$$vDb10(ZUID,.vop2)
	I $G(vop2)=0 Q 
	S ZBRCD=$P(scau,$C(124),22)
	;
	I ZBRCD="" S ZBRCD="" ; Back Office Branch Code
	;
	; Get next SEQ from STFSQL
	S ZDATE=$P($H,",",1)
	N rsstf,vos4,vos5,vos6 S rsstf=$$vOpen2()
	I $$vFetch2() S NSEQ=rsstf+1
	E  S NSEQ=1
	;
	N rs1,vos7,vos8,vos9,vos10 S rs1=$$vOpen3()
	I '$G(vos7) Q 
	F  Q:'($$vFetch3())  D
	.	;
	.	N dbbuf,vop3,vop4,vop5,vop6 S vop3=$P(rs1,$C(9),1),vop4=$P(rs1,$C(9),2),vop5=$P(rs1,$C(9),3),dbbuf=$G(^DBBUF(vop3,vop4,vop5))
	.	 S vop6="" N von S von="" F  S von=$O(^DBBUF(vop3,vop4,vop5,von)) quit:von=""  S vop6=vop6_^DBBUF(vop3,vop4,vop5,von)
	.	;
	.	; set the record in STFSQL
	.	N stfsql S stfsql=$$vDbNew1("","","")
	.	 S vobj(stfsql,1,1)=""
	. S vobj(stfsql,-3)=$P($H,",",1)
	. S vobj(stfsql,-4)=NSEQ
	. S vobj(stfsql,-5)=vop5
	. S $P(vobj(stfsql),$C(124),3)=ZBRCD
	. S $P(vobj(stfsql),$C(124),2)=ZUID
	. S $P(vobj(stfsql),$C(124),1)=$get(RM)
	. S vobj(stfsql,1,1)=vop6
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(stfsql) S vobj(stfsql,-2)=1 Tcommit:vTp  
	.	K vobj(+$G(stfsql)) Q 
	;
	S ER=0
	S REPLY=""
	;
	Q 
	;
VALID(EXPR,TOK,SPEC)	; Check if message can be processed during end of day
	N CMD
	;
	S CMD=$piece(EXPR," ",1)
	S EXPR=$E(EXPR,$L(CMD)+2,1048575)
	S SPEC=0
	;
	; Do not restrict the following SQL statements during end-of-day
	I ",BUFFER,CLOSE,CREATE,DESCRIBE,FETCH,OPEN,SELECT,"[(","_CMD_",") Q 1
	;
	; Restrict the following SQL statements during end-of-day
	I ",ALTER,DROP,"[(","_CMD_",") Q 0
	;
	N VALID
	N TABLE N X
	;
	S VALID=1
	;
	I CMD="INSERT" D
	.	;
	.	N INTO
	.	;
	.	S X=$$TOK^SQL(EXPR,"INTO",.TOK)
	.	;
	.	I $get(INTO)="" S INTO=X I INTO="" Q 
	.	;
	.	S TABLE=$$FUN^SQL(INTO,,TOK)
	.	S VALID=$$CHKTBL(TABLE)
	.	;
	.	I VALID=0 S VALID=1 S SPEC=1
	.	;
	.	Q 
	;
	I CMD="UPDATE" D
	.	;
	.	N SET
	.	;
	.	S X=$$TOK^SQL(EXPR,"SET",.TOK)
	.	I X'[($char(0)) S TABLE=X
	.	E  S TABLE=$$UNTOK^%ZS(X,TOK)
	.	S VALID=$$CHKTBL(TABLE)
	.	;
	.	Q 
	;
	I CMD="DELETE" D
	.	;
	.	N FROM
	.	;
	.	S X=$$TOK^SQL(EXPR,"FROM",.TOK)
	.	;
	.	I $get(FROM)="" S FROM=X I FROM="" Q 
	.	;
	.	S TABLE=$$FUN^SQL(FROM,,TOK)
	.	S VALID=$$CHKTBL(TABLE)
	.	;
	.	Q 
	;
	I CMD="EXECUTE" D
	.	S X=$piece(EXPR," ",2)
	.	;
	.	I $E(X,1,2)'="$$" Q 
	.	;
	.	S X=$E(X,3,1048575)
	.	S X=$piece(X,"(",1)
	.	I '($D(^UTBL("RTNS",X))#2) S VALID=0
	.	;
	.	Q 
	;
	Q VALID
	;
CHKTBL(TABLE)	;Check if table is restricted
	;
	I TABLE["""" S TABLE=$$QSUB^%ZS(TABLE,"""")
	I TABLE="ACN" Q 0
	I TABLE="DEP" Q 0
	I TABLE="LN" Q 0
	;
	Q 1
	;
vSIG()	;
	Q "60673^35782^Dhanalakshmi R^20242" ; Signature - LTD^TIME^USER^SIZE
	;
vDb10(v1,v2out)	;	voXN = Db.getRecord(SCAU,,1,-2)
	;
	N scau
	S scau=$G(^SCAU(1,v1))
	I scau="",'$D(^SCAU(1,v1))
	S v2out='$T
	;
	Q scau
	;
vDb2(v1,v2,v3,v4,v5)	;	vobj()=Db.getRecord(DAYENDXBADC,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDAYENDXBADC"
	S vobj(vOid)=$G(^DAYEND(v1,"XBADC",v2,v3,v4,v5))
	I vobj(vOid)="",'$D(^DAYEND(v1,"XBADC",v2,v3,v4,v5))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	S vobj(vOid,-6)=v4
	S vobj(vOid,-7)=v5
	Q vOid
	;
vDb7(v1,v2,v3,v4,v5,v2out)	;	voXN = Db.getRecord(DAYENDXBAD,,1,-2)
	;
	N xbad
	S xbad=$G(^DAYEND(v1,"XBAD",v2,v3,v4,v5))
	I xbad="",'$D(^DAYEND(v1,"XBAD",v2,v3,v4,v5))
	S v2out='$T
	;
	Q xbad
	;
vDb8(v1,v2out)	;	voXN = Db.getRecord(STBLTFMT,,1,-2)
	;
	N tfmt
	S tfmt=$G(^STBL("TFMT",v1))
	I tfmt="",'$D(^STBL("TFMT",v1))
	S v2out='$T
	;
	Q tfmt
	;
vDb9(v1,v2out)	;	voXN = Db.getRecord(TOKEN,,1,-2)
	;
	N token
	S token=$G(^TOKEN(v1))
	I token="",'$D(^TOKEN(v1))
	S v2out='$T
	;
	Q token
	;
vDbNew1(v1,v2,v3)	;	vobj()=Class.new(STFSQL)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSTFSQL",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vOpen1()	;	BUFFER FROM DBBUF WHERE TOKEN=:ZTOKEN
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(ZTOKEN) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^DBBUF(vos2,vos3),1) I vos3="" G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen2()	;	DISTINCT SEQ FROM STFSQL WHERE DATE=:ZDATE ORDER BY SEQ DESC
	;
	;
	S vos4=2
	D vL2a1
	Q ""
	;
vL2a0	S vos4=0 Q
vL2a1	S vos5=$G(ZDATE) I vos5="" G vL2a0
	;
	S vos6=""
vL2a4	S vos6=$O(^STFSQL(vos5,vos6),-1) I vos6="" G vL2a0
	Q
	;
vFetch2()	;
	;
	;
	I vos4=1 D vL2a4
	I vos4=2 S vos4=1
	;
	I vos4=0 Q 0
	;
	S rsstf=$S(vos6=$C(254):"",1:vos6)
	;
	Q 1
	;
vOpen3()	;	TOKEN,BUFFER,BUFREC FROM DBBUFCOM WHERE TOKEN=:ZTOKEN AND BUFFER=:ZBUF
	;
	;
	S vos7=2
	D vL3a1
	Q ""
	;
vL3a0	S vos7=0 Q
vL3a1	S vos8=$G(ZTOKEN) I vos8="" G vL3a0
	S vos9=$G(ZBUF) I vos9="" G vL3a0
	S vos10=""
vL3a4	S vos10=$O(^DBBUF(vos8,vos9,vos10),1) I vos10="" G vL3a0
	Q
	;
vFetch3()	;
	;
	;
	I vos7=1 D vL3a4
	I vos7=2 S vos7=1
	;
	I vos7=0 Q 0
	;
	S rs1=vos8_$C(9)_vos9_$C(9)_$S(vos10=$C(254):"",1:vos10)
	;
	Q 1
	;
vReSav1(stfsql)	;	RecordSTFSQL saveNoFiler()
	;
	S ^STFSQL(vobj(stfsql,-3),vobj(stfsql,-4),vobj(stfsql,-5))=$$RTBAR^%ZFUNC($G(vobj(stfsql)))
	N vC,vS s vS=0
	F vC=1:450:$L($G(vobj(stfsql,1,1))) S vS=vS+1,^STFSQL(vobj(stfsql,-3),vobj(stfsql,-4),vobj(stfsql,-5),vS)=$E(vobj(stfsql,1,1),vC,vC+449)
	Q
