 ; 
 ; **** Routine compiled from DATA-QWIK Procedure PBSMSQL ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
PBSMSQL(REPLY,STFFLG,RECORD,RECTYP,CONTEXT) ; MSQL Service Class Driver
 ;
 N RETVAL
 ;
 S RETVAL=0
 D MAIN(.RETVAL,.REPLY,$get(%MSKC),$get(%MSKD),$get(%MSKE),$get(%MSKL),$get(%MSKN))
 ;
 ; Return Value: 0 = success, 1 = processing error
 Q RETVAL
 ;
MAIN(RETVAL,REPLY,%MSKC,%MSKD,%MSKE,%MSKL,%MSKN) ; 
 ;
 ; Main processing for MSQL Service Class Driver
 ;
 N PTR
 N bufname N FLD
 N SQLCNT N SQLCOD N SQLDTA N SQLEXPR N SQLIND N SQLPAR N SQLREC N SQLTOK
 N verrors N vrflg N vsupv N ZUID
 ;
 S bufname=""
 ;
 S PTR=$$LV2V^MSG(RECORD,.FLD)
 ;
 ; Invalid SQL Command
 I $get(FLD(1))="" D SETERR^DBSEXECU("STBLER","MSG",8564) S RETVAL=$$ERRRPLY(bufname) Q 
 ;
 ; Overlay saved context
 I $get(CONTEXT)'="" D PARSPAR^%ZS(CONTEXT,.SQLPAR)
 ;
 ; Overlay parameters from this message
 I $get(FLD(2))'="" D PARSPAR^%ZS(FLD(2),.SQLPAR)
 ;
 I ($D(SQLPAR("FORMAT"))#2) S ER=$$FORMAT(SQLPAR("FORMAT")) I ER S RETVAL=$$ERRRPLY(bufname) Q 
 I ($D(SQLPAR("DATE"))#2) S %MSKD=SQLPAR("DATE")
 I ($D(SQLPAR("DEC"))#2) S (%MSKE,%MSKN)=SQLPAR("DEC")
 ;
 ; Setup par("SAVECUR")
 S SQLPAR("SAVECUR")=""
 ;
 S SQLEXPR=$$SQL^%ZS(FLD(1),.SQLTOK) I ER S RETVAL=$$ERRRPLY(bufname) Q 
 ;
 ; If buffered.. get buffer name
 I $piece(SQLEXPR," ",1)="BUFFER" S bufname=$piece(SQLEXPR," ",3)
 ;
 ; Check 24x7 access
 ; Database Update Restricted
 I $get(%STFHOST),('$$VALID(SQLEXPR,SQLTOK)) D SETERR^DBSEXECU("STBLER","MSG",7912) S RETVAL=$$ERRRPLY(bufname) Q 
 ;
 ; Supvervisory override
 I $get(FLD(3))'="" D SPV(FLD(3),.vsupv) I ER S RETVAL=$$ERRRPLY(bufname) Q 
 ;
 ; Need ODBC V2.0 to match the server software
 ; Version number of client message is not compatible with server
 I $get(SQLPAR("ODBC"))=1 D SETERR^DBSEXECU("STBLER","MSG",2951) S RETVAL=$$ERRRPLY(bufname) Q 
 ;
 ; Store and forward, force check of store and forward user class in sqlbuf
 I STFFLG D
 .	S SQLPAR("SPVOVR")=1
 .	S vsupv(1,"~")=""
 .	I vsupv(1,"~")="" S UCLS="MGR"
 .	Q 
 ;
 S ER=$$^SQL(SQLEXPR,.SQLPAR,.SQLCOD,.SQLDTA,.SQLCNT,.SQLIND,.SQLTOK)
 ;
 ; For non-buffered SQL commands copy verrors(,) into vrflg(,,)
 ; This should only happen for non-buffered SQL statements.
 I $D(verrors),'$D(vrflg) D
 .	N s1 S s1="" N s2 S s2=""
 .	F  S s1=$order(verrors(s1)) Q:(s1="")  D
 ..		S vrflg(1,s1)=verrors(s1)
 ..		F  S s2=$order(verrors(s1,s2)) Q:(s2="")  D
 ...			S vrflg(1,s1,s2)=verrors(s1,s2)
 ...			Q 
 ..		Q 
 .	Q 
 ;
 ; Returns status, error code
 S SQLCOD=$$SQLCOD($get(SQLCOD),.ER)
 ;
 ; Apply supvervisory override when they exist and authorizations exist, but not
 ; when they have already been checked by COMMIT^SQLBUF (vrflg=1)
 I $D(vsupv),$D(vrflg),'$get(vrflg) D SPVOVR(.vrflg,.vsupv)
 ;
 ; Check override array
 I 'ER,'$D(vrflg) D  S RETVAL=0 Q 
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
 .	Q 
 ;
 ; Error reply
 I ER S RETVAL=$$ERRRPLY(bufname) Q 
 ;
 ; Got here because of restrictions
  TRO:$TL>0  ; Non-fatal restrictions
 ;
 ; Override AU message
 S REPLY=$$OVRMSG(.vrflg)
 S RETVAL=1
 ;
 Q 
 ;
SPV(OVR,vsupv) ; Convert override information into vsupv() array
 ;
 N ET N I N SPVREST N SPVUID N UCLS N Z N ZOVR
 N DONE
 ;
 S ER=0
 S DONE=0
 ;
 I '(OVR="") D
 .	; Supv override
 .	S Z=$$LV2V^MSG(OVR,.ZOVR)
 .	F I=1:1 Q:'($D(ZOVR(I))#2)  D  Q:ER!DONE 
 ..		N V
 ..		;
 ..		; Type|UID|PSW|CID
 ..		S Z=$$LV2V^MSG(ZOVR(I),.V)
 ..		S SPVUID=$get(V(2))
 ..		;
 ..		I (SPVUID="") D  Q:ER 
 ...			I 0 ;*    if CUVAR.AUTOAUTH=2 set SPVUID = %UserID
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
 ..		S vsupv(1,SPVREST)=SPVUID
 ..		;
 ..		I SPVREST="*" S DONE=1
 ..		Q 
 .	Q 
 Q 
 ;
SPVOVR(vrflg,vsupv) ; 
 N vTp
 N ovrsav
 N ET N IDENT N STSEQ N SEQ1 N SEQ2 N UCLSARR N UCLS N UID N ZTBL
 N ALL N FAIL
 ;
 I '$D(vsupv) Q 
 ;
 S STSEQ="" S FAIL=0
 F  S STSEQ=$order(vrflg(STSEQ)) Q:(STSEQ="")  D
 .	S ALL=0 S UID="" S UCLS=""
 .	; vsupv("*") = all restrictions, UID=vsupv("*"), UCLS=scau.%ucls
 .	; vsupv("~") = all restricitons, UID=%UID,       UCLS=vsupv("~")
 .	I ($D(vsupv(STSEQ,"*"))#2) D
 ..		S ALL=1
 ..		S UID=vsupv(STSEQ,"*")
 ..		I '($D(UCLSARR(UID))#2) D
 ...			N scau S scau=$G(^SCAU(1,UID))
 ...			S UCLSARR(UID)=$P(scau,$C(124),5)
 ...   Q 
 ..		S UCLS=UCLSARR(UID)
 ..		Q 
 .	E  I ($D(vsupv(STSEQ,"~"))#2) D
 ..		S ALL=1
 ..		S UID=%UID
 ..		S UCLS=vsupv(STSEQ,"~")
 ..		Q 
 .	;
 .	S (SEQ1,SEQ2)=""
 .	F  S SEQ1=$order(vrflg(STSEQ,SEQ1)) Q:(SEQ1="")  D
 ..		F  S SEQ2=$order(vrflg(STSEQ,SEQ1,SEQ2)) Q:(SEQ2="")  D
 ...			; Error type
 ...			S ET=$piece(vrflg(STSEQ,SEQ1,SEQ2),"|",3)
 ...			I 'ALL,'($D(vsupv(STSEQ,ET))#2) S FAIL=1 Q 
 ...			;
 ...			I 'ALL D
 ....				S UID=$get(vsupv(STSEQ,ET))
 ....				I '$D(UCLSARR(UID)) D
 .....					N scau S scau=$G(^SCAU(1,UID))
 .....					S UCLSARR(UID)=$P(scau,$C(124),5)
 .....     Q 
 ....				S UCLS=UCLSARR(UID)
 ....				Q 
 ...			I (UCLS="") S FAIL=1 Q 
 ...			;
 ...			; can it be overridden? if not quit
 ...			I '($D(^UTBL("XBAD",ET,UCLS))#2) D  Q 
 ....				S FAIL=1
 ....				S $piece(vrflg(STSEQ,SEQ1,SEQ2),"|",10)=1 ; SPVST flag
 ....				Q 
 ...			;
 ...			S ovrsav(STSEQ,SEQ1,SEQ2)=vrflg(STSEQ,SEQ1,SEQ2)
 ...			I FAIL Q 
 ...			;
 ...			; Record authorization for CIF,DEP,LN,ACN
 ...			S ZTBL=$piece(vrflg(STSEQ,SEQ1),"|",1)
 ...			S IDENT=$piece(vrflg(STSEQ,SEQ1),"|",2)
 ...			I ZTBL="CIF" D
 ....				I (IDENT="") Q  ; null values
 ....				N XSEQ S XSEQ=$O(^DAYEND(TJD,"XBADC",%UID,IDENT,""),-1)+1
 ....				N xbadc S xbadc=$$vRCgetRecord1^RecordDAYENDXBADC(TJD,%UID,IDENT,XSEQ,ET,0)
 ....			  S $P(vobj(xbadc),$C(124),1)=UID
 ....			 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDAYENDXBADC(xbadc,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(xbadc,-100) S vobj(xbadc,-2)=1 TC:vTp  
 ....				K vobj(+$G(xbadc)) Q 
 ...			E  D
 ....				N CID S CID=0
 ....				N I N X N XSEQ
 ....				;
 ....				; Find account number
 ....				F I=1:1:$L(IDENT,",") S X=+$piece(IDENT,",",I) I ($D(^ACN(X,50))) S CID=X Q 
 ....				;
 ....				; Don't log unless we've got a valid account number
 ....				Q:(CID'>0) 
 ....				;
 ....				S XSEQ=$O(^DAYEND(TJD,"XBAD",%UID,CID,""),-1)+1
 ....				;
 ....				N xbad S xbad=$$vRCgetRecord1^RecordDAYENDXBAD(TJD,%UID,CID,XSEQ,ET,0)
 ....				;
 ....			  S $P(vobj(xbad),$C(124),1)=UID
 ....			  S $P(vobj(xbad),$C(124),2)=IDENT
 ....			 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDAYENDXBAD(xbad,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(xbad,-100) S vobj(xbad,-2)=1 TC:vTp  
 ....				K vobj(+$G(xbad)) Q 
 ...			Q 
 ..		I FAIL Q 
 ..		S ovrsav(STSEQ,SEQ1)=vrflg(STSEQ,SEQ1)
 ..		K vrflg(STSEQ,SEQ1)
 ..		Q 
 .	Q 
 ;
 I $D(vrflg) D
 .	S vrflg=1 ; this tells MAIN^PBSMSQL vrflg() has been processed
 .	S (STSEQ,SEQ1,SEQ2)=""
 .	F  S STSEQ=$order(ovrsav(STSEQ)) Q:(STSEQ="")  D
 ..		F  S SEQ1=$order(ovrsav(STSEQ,SEQ1)) Q:(SEQ1="")  D
 ...			I ($D(ovrsav(STSEQ,SEQ1))#2) S vrflg(STSEQ,SEQ1)=ovrsav(STSEQ,SEQ1)
 ...			F  S SEQ2=$order(ovrsav(STSEQ,SEQ1,SEQ2)) Q:(SEQ2="")  D
 ....				S vrflg(STSEQ,SEQ1,SEQ2)=ovrsav(STSEQ,SEQ1,SEQ2)
 ....				S $piece(vrflg(STSEQ,SEQ1,SEQ2),"|",10)=0 ; SPVST flag
 ....				Q 
 ...			Q 
 ..		Q 
 .	Q 
 Q 
 ;
OVRMSG(vrflg) ; Build override message
 N vret
 ;
 N AU1 N STSEQ N FID N KEYS N MSG N SEQ1 N SEQ2 N Z
 ;
 S (STSEQ,SEQ1,SEQ2)=""
 F STSEQ=1:1:$order(vrflg(""),-1) D
 .	N AU2
 .	N CNT S CNT=0
 .	F  S SEQ1=$order(vrflg(STSEQ,SEQ1)) Q:SEQ1=""  D
 ..		S FID=$piece(vrflg(STSEQ,SEQ1),"|",1) ; Table name
 ..		S KEYS=$piece(vrflg(STSEQ,SEQ1),"|",2) ; Access keys
 ..		F  S SEQ2=$order(vrflg(STSEQ,SEQ1,SEQ2)) Q:SEQ2=""  D
 ...			N AU3
 ...			S AU3(1)="XBAD_"_FID_"_"_$piece(vrflg(STSEQ,SEQ1,SEQ2),"|",3)
 ...			S AU3(2)=""
 ...			S AU3(3)=$piece(vrflg(STSEQ,SEQ1,SEQ2),"|",8) ; Error description
 ...			S AU3(4)=KEYS ; Access keys
 ...			S AU3(5)=$piece(vrflg(STSEQ,SEQ1,SEQ2),"|",10) ; SPVST flag
 ...			;
 ...			S CNT=CNT+1
 ...			S AU2(CNT)=$$V2LV^MSG(.AU3)
 ...			Q 
 ..		Q 
 .	S AU1(STSEQ)=$$V2LV^MSG(.AU2)
 .	Q 
 ;
 S MSG(1)="AU"
 S MSG(2)=""
 S MSG(3)=$$V2LV^MSG(.AU1)
 ;
 S vret=$$V2LV^MSG(.MSG) Q vret
 ;
ERRRPLY(buffer) ; Build standard server error reply
 ;
 I $get(RM)="",$D(RM)>1 S RM=$get(RM(1))_" "_$get(RM(2))
 ;
 S REPLY=$$ERRMSG^PBSUTL($get(RM),$get(ET))
 ;
 ; If off-line, put into exception
 I STFFLG D STF
 ;
 I '(buffer="") D clearBuffer^SQLBUF(%TOKEN,buffer)
 ;
 Q 1
 ;
SQLCOD(SQLCOD,ER) ; Return appropriate SQL status
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
FORMAT(FMT) ; Redefine format masks for this message
 ;
 N X
 ;
 ; Load format from table
 N tfmt,vop1 S tfmt=$$vRCgetRecord1Opt^RecordSTBLTFMT(FMT,0,.vop1)
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
STF ; Store and forward handling of rejected updates
 N vTp
 ;
 N NSEQ N ZBRCD N ZBUF N ZDATE N ZTOKEN N ZUID
 ;
 S ZTOKEN=%TOKEN
 ;
 ; Buffer Name
 N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen1()
 I '$G(vos1) Q  ; Missing buffer name
 I $$vFetch1() S ZBUF=rs
 ;
 N token,vop1 S token=$$vRCgetRecord1Opt^RecordTOKEN(ZTOKEN,0,.vop1)
 I $G(vop1)=0 Q 
 S ZUID=$P(token,$C(124),2)
 ;
 N scau,vop2 S scau=$$vRCgetRecord1Opt^RecordSCAU(ZUID,0,.vop2)
 I $G(vop2)=0 Q 
 S ZBRCD=$P(scau,$C(124),22)
 ;
 I ZBRCD="" S ZBRCD="" ; Back Office Branch Code
 ;
 ; Get next SEQ from STFSQL
 S ZDATE=$P($H,",",1)
 N rsstf,vos5,vos6,vos7,vos8 S rsstf=$$vOpen2()
 I $$vFetch2() S NSEQ=rsstf+1
 E  S NSEQ=1
 ;
 N rs1,vos9,vos10,vos11,vos12,vos13 S rs1=$$vOpen3()
 I '$G(vos9) Q 
 F  Q:'$$vFetch3()  D
 . N dbbuf,vop3,vop4,vop5,vop6 S vop3=$P(rs1,$C(9),1),vop4=$P(rs1,$C(9),2),vop5=$P(rs1,$C(9),3),dbbuf=$$vRCgetRecord1Opt^RecordDBBUFCOM(vop3,vop4,vop5,1,"")
 .	 S vop6="" N von S von="" F  S von=$O(^DBBUF(vop3,vop4,vop5,von)) quit:von=""  S vop6=vop6_^DBBUF(vop3,vop4,vop5,von)
 .	;
 .	; set the record in STFSQL
 .	N stfsql S stfsql=$$vcdmNew^RecordSTFSQL()
 .	 S vobj(stfsql,1,1)=""
 .  S vobj(stfsql,-3)=$P($H,",",1)
 .  S vobj(stfsql,-4)=NSEQ
 .  S vobj(stfsql,-5)=vop5
 .  S $P(vobj(stfsql),$C(124),3)=ZBRCD
 .  S $P(vobj(stfsql),$C(124),2)=ZUID
 .  S $P(vobj(stfsql),$C(124),1)=$get(RM)
 .  S vobj(stfsql,1,1)=vop6
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSTFSQL(stfsql,"/CASDEL/INDEX/NOJOURNAL/LOG/NOTRIGAFT/NOTRIGBEF/UPDATE/NOVALDD/VALFK/NOVALREQ/NOVALRI/NOVALST/") K vobj(stfsql,-100) S vobj(stfsql,-2)=1 TC:vTp  
 . K vobj(+$G(stfsql)) Q 
 ;
 S ER=0
 S REPLY=""
 ;
 Q 
 ;
VALID(EXPR,TOK,SPEC) ; Check if message can be processed during end of day
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
 .	I X'[$char(0) S TABLE=X
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
CHKTBL(TABLE) ; Check if table is restricted
 ;
 I TABLE["""" S TABLE=$$QSUB^%ZS(TABLE,"""")
 I TABLE="ACN" Q 0
 I TABLE="DEP" Q 0
 I TABLE="LN" Q 0
 ;
 Q 1
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61571^56885^Dan Russell^23849" ; Signature - LTD^TIME^USER^SIZE
 ;
vOpen1() ; BUFFER FROM DBBUF WHERE TOKEN=:ZTOKEN
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(ZTOKEN) I vos3="" G vL1a0
 S vos4=""
vL1a4 S vos4=$O(^DBBUF(vos3,vos4),1) I vos4="" G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen2() ; DISTINCT SEQ FROM STFSQL WHERE DATE=:ZDATE ORDER BY SEQ DESC
 ;
 ;
 S vos5=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos5=0 Q
vL2a1 S vos6=$$BYTECHAR^SQLUTL(254)
 S vos7=$G(ZDATE)
 ;
 S vos8=""
vL2a5 S vos8=$O(^STFSQL(vos7,vos8),-1) I vos8="" G vL2a0
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos5=1 D vL2a5
 I vos5=2 S vos5=1
 ;
 I vos5=0 S rsstf="" Q 0
 ;
 S rsstf=$S(vos8=vos6:"",1:vos8)
 ;
 Q 1
 ;
vOpen3() ; TOKEN,BUFFER,BUFREC FROM DBBUFCOM WHERE TOKEN=:ZTOKEN AND BUFFER=:ZBUF
 ;
 ;
 S vos9=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos9=0 Q
vL3a1 S vos10=$$BYTECHAR^SQLUTL(254)
 S vos11=$G(ZTOKEN) I vos11="" G vL3a0
 S vos12=$G(ZBUF) I vos12="" G vL3a0
 S vos13=""
vL3a5 S vos13=$O(^DBBUF(vos11,vos12,vos13),1) I vos13="" G vL3a0
 Q
 ;
vFetch3() ;
 ;
 ;
 I vos9=1 D vL3a5
 I vos9=2 S vos9=1
 ;
 I vos9=0 S rs1="" Q 0
 ;
 S rs1=vos11_$C(9)_vos12_$C(9)_$S(vos13=vos10:"",1:vos13)
 ;
 Q 1
