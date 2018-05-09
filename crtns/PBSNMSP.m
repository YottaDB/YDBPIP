 ; 
 ; **** Routine compiled from DATA-QWIK Procedure PBSNMSP ****
 ; 
 ; 02/27/2009 10:31 - pip
 ; 
PBSNMSP(reply,stfflg,record,rectyp,contxt) ; NMSP Service Class Driver
 N field,ptr
 ;
 S ptr=$$LV2V^MSG(record,.field)
 I $get(field(1))=0 Q $$NMSP0(.reply,.field)
 I $get(field(1))=1 Q $$NMSP1(.reply,.field)
 I $get(field(1))=2 Q $$NMSP2(.reply,.field)
 I $get(field(1))=3 Q $$NMSP3(.reply,.field)
 I $get(field(1))=4 Q $$NMSP4(.reply,.field)
 I $get(field(1))=5 Q $$NMSP5(.reply,.field)
 I $get(field(1))=6 Q $$NMSP6(.reply,.field)
 I $get(field(1))=99 Q $$NMSP99(.reply,.field)
 ;
 ; Invalid service procedure
 S reply=$$CSERR^PBSUTL("SV_INVLDNMP")
 Q 1
 ;
NMSP0(reply,field) ; Private;Sign-off
 N vTp
 ;
 N TOKEN
 ;
 S TOKEN=$get(field(2))
 I TOKEN="" S reply=$$CSERR^PBSUTL("SV_TOKENREQ") Q 1
 ;
 N token,vop1,vop2 S vop1=TOKEN,token=$$vRCgetRecord1Opt^RecordTOKEN(TOKEN,0,.vop2)
 I $G(vop2)=0 S reply=$$CSERR^PBSUTL("SV_INVLDTKN") Q 1
  S $P(token,$C(124),1)=0
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^TOKEN(vop1)=$$RTBAR^%ZFUNC(token) S vop2=1 TC:vTp  
 S reply=$$V2LV^MSG("")
 Q 0
 ;
NMSP1(reply,field) ; Private;Sign-on
 N vTp
 ;
 N CLTYP,CTXT,CLVER,er,FAP,FAPS,FLD,GBLDIR
 N INST,LANG,list,NPWD,PSWD,PSWDAUT,PWD,PWDFAIL,STN,TOKEN,UCLS,UID
 ;
 S er=0
 S GBLDIR=""
 S UID=$get(field(2))
 S STN=$get(field(3))
 S PWD=$get(field(4))
 S INST=$get(field(5))
 S FAPS=$get(field(6))
 S CTXT=$get(field(7))
 S NPWD=$get(field(8))
 S CLTYP=$get(field(9))
 S CLVER=$get(field(10))
 S UCLS=$get(field(11))
 ;
 I UID="" S reply=$$CSERR^PBSUTL("SV_USRIDREQ") Q 1
 I STN="" S reply=$$CSERR^PBSUTL("SV_STNIDREQ") Q 1
 I '$$chkver(CLTYP,CLVER,.%VNC) S reply=$$CSERR^PBSUTL("SV_MISMATCH") Q 1
 I INST'="" D  I er Q 1
 .	I '($D(^CTBL("INST",INST))#2) S er=1 S reply=$$CSERR^PBSUTL("SV_INVLDINS") Q 
 .	N ctblinst S ctblinst=$$vRCgetRecord0Opt^RecordCTBLINST(INST,0,"")
 .	S GBLDIR=$P(ctblinst,$C(124),2) I GBLDIR'="" S $ZGBLDIR=GBLDIR
 .	Q 
 ;
 S %UID=UID
 I '$$vDbEx2() S reply=$$CSERR^PBSUTL("SV_INVLDUID") Q 1
 I rectyp,%UID'?1N.N S reply=$$CSERR^PBSUTL("SV_USRIDFMT") Q 1
 ;
 N scau S scau=$$vRCgetRecord0^RecordSCAU(%UID,0)
 ;
 I $$STATUS^SCAUCDI($P(vobj(scau),$C(124),5),$P(vobj(scau),$C(124),8),$P(vobj(scau),$C(124),44),$P(vobj(scau),$C(124),43))=3 S reply=$$CSERR^PBSUTL("SV_USRIDREV") K vobj(+$G(scau)) Q 1
 ;
 S LANG=$P(vobj(scau),$C(124),3)
 ;
 I (UCLS="") S UCLS=$P(vobj(scau),$C(124),5) ; Use primary userclass
 E  I (UCLS'=$P(vobj(scau),$C(124),5)) D  I er K vobj(+$G(scau)) Q 1
 .	;
 .	I '((","_$P(vobj(scau),$C(124),13)_",")[(","_UCLS_",")) D  ; Not valid alternative userclass
 ..		;
 ..		S er=1
 ..		; Invalid userclass ~p1
 ..		S reply=$$ERRMSG^PBSUTL($$^MSG(6755,UCLS),"")
 ..		Q 
 .	Q 
 ;
 S PWDFAIL=$P(vobj(scau),$C(124),43)
 ;
 D chkpwd(.scau,field(1)) I er D  K vobj(+$G(scau)) Q 1
 .	S PWDFAIL=PWDFAIL+1
 .  S:'$D(vobj(scau,-100,"0*","PWDFAIL")) vobj(scau,-100,"0*","PWDFAIL")="N043"_$P(vobj(scau),$C(124),43),vobj(scau,-100,"0*")="" S $P(vobj(scau),$C(124),43)=PWDFAIL
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSCAU(scau,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(scau,-100) S vobj(scau,-2)=1 TC:vTp  
 .	Q 
 ;
 ; Check password expiration
 I $P(vobj(scau),$C(124),7)<$P($H,",",1) D  I er K vobj(+$G(scau)) Q 1
 .	; Allow native STF
 .	I stfflg,'rectyp Q 
 .	S er=1 S reply=$$CSERR^PBSUTL("SV_PSWRDEXP")
 .	Q 
 ;
 I LANG'="" D  I er K vobj(+$G(scau)) Q 1
 .	I '($D(^UTBL("LANG",LANG))#2) D  I er Q 
 ..		; Allow native STF
 ..		I stfflg,'rectyp Q 
 ..		S er=1 S reply=$$CSERR^PBSUTL("SV_INVLDLNG") Q 
 ..		Q 
 .	E  D
 ..		N lang S lang=$$vRCgetRecord0Opt^RecordUTBLLANG(LANG,0,"")
 ..		S GBLDIR=$P(lang,$C(124),2)
 ..		Q 
 .	I $get(GBLDIR)'="" S $ZGBLDIR=GBLDIR
 .	Q 
 ;
 D  I er K vobj(+$G(scau)) Q 1
 .	I FAPS=$char(0) Q 
 .	N I,PTR,SRV,SUB
 .	;
 .	S PTR=$$LV2V^MSG(FAPS,.SUB)
 .	F I=1:2 Q:'$D(sub(i))  D  Q:er 
 ..		S SRV=SUB(I) I SRV="" Q 
 ..		S FAP=$get(SUB(I+1)) I FAP="" Q 
 ..		I ($D(^CTBL("FAP",FAP))#2) S FAP(SRV)=FAP Q 
 ..		S er=1 S reply=$$CSERR^PBSUTL("SV_INVLDFAP")
 ..		Q 
 .	;
 .	S FAPS=""
 .	N rs,vos1,vos2,vos3 S rs=$$vOpen1()
 .	I ''$G(vos1) F  Q:'$$vFetch1()  D
 ..		S SRV=rs
 ..		I $D(FAP(SRV)) S $piece(FAPS,"~",SRV)=FAP(SRV)
 ..		Q 
 .	Q 
 ;
 I field(1)=1!($get(%TOKEN)="") D
 .	S TOKEN=$$TOKEN
 .  K ^MSGLOG(TOKEN)
 .  K ^SQLCUR(TOKEN)
 .	Q 
 E  D  I er K vobj(+$G(scau)) Q 
 .	I '$$vDbEx5() S TOKEN=%TOKEN Q 
 .	N token2 S token2=$$vRCgetRecord0Opt^RecordTOKEN(%TOKEN,0,"")
 .	I '$P(token2,$C(124),1) S TOKEN=%TOKEN Q 
 .	S er=1 S reply=$$CSERR^PBSUTL("SV_TOKINUSE")
 .	Q 
 ;
 N token,vop1,vop2 S vop1=TOKEN,token=$$vRCgetRecord1Opt^RecordTOKEN(TOKEN,0,.vop2)
  S $P(token,$C(124),1)=1
  S $P(token,$C(124),2)=UID
  S $P(token,$C(124),3)=STN
  S $P(token,$C(124),4)=%VNC
  S $P(token,$C(124),5)=FAPS
  S $P(token,$C(124),6)=UCLS
  S $P(token,$C(124),7)=LANG
  S $P(token,$C(124),8)=INST
  S $P(token,$C(124),9)=GBLDIR
  S $P(token,$C(124),10)=$$ctxt(CTXT)
  S $P(token,$C(124),11)=TJD
  S $P(token,$C(124),12)=""
  S $P(token,$C(124),13)=%SVCHNID
 ;
 ; Only need to update these two fields if they're actually going to change
 I $P(vobj(scau),$C(124),8)'=$P($H,",",1)  S:'$D(vobj(scau,-100,"0*","LSGN")) vobj(scau,-100,"0*","LSGN")="D008"_$P(vobj(scau),$C(124),8),vobj(scau,-100,"0*")="" S $P(vobj(scau),$C(124),8)=$P($H,",",1)
 I $P(vobj(scau),$C(124),43)'=0  S:'$D(vobj(scau,-100,"0*","PWDFAIL")) vobj(scau,-100,"0*","PWDFAIL")="N043"_$P(vobj(scau),$C(124),43),vobj(scau,-100,"0*")="" S $P(vobj(scau),$C(124),43)=0
 ;
 I NPWD="" D  I er K vobj(+$G(scau)) Q 1
 .	I $P(vobj(scau),$C(124),4) S er=1 S reply=$$CSERR^PBSUTL("SV_NEWPWREQ") Q 
 .	;
 .	; If password is already encrypted quit
 .	I $E(PWD,1)=$char(1) Q 
 .	I $P(vobj(scau),$C(124),39)'="" Q 
 .	D pswdaut(PWD,.PSWDAUT) I er Q 
 .  S:'$D(vobj(scau,-100,"0*","PSWDAUT")) vobj(scau,-100,"0*","PSWDAUT")="T039"_$P(vobj(scau),$C(124),39),vobj(scau,-100,"0*")="" S $P(vobj(scau),$C(124),39)=PSWDAUT
 .	Q 
 ;
 I NPWD'="" D  I er K vobj(+$G(scau)) Q 1
 .	S PSWD=$$ENC^SCAENC(NPWD)
 .	D pswdaut(NPWD,.PSWDAUT) I er Q 
 .  S:'$D(vobj(scau,-100,"0*","PSWD")) vobj(scau,-100,"0*","PSWD")="T006"_$P(vobj(scau),$C(124),6),vobj(scau,-100,"0*")="" S $P(vobj(scau),$C(124),6)=PSWD
 .  S:'$D(vobj(scau,-100,"0*","PSWDAUT")) vobj(scau,-100,"0*","PSWDAUT")="T039"_$P(vobj(scau),$C(124),39),vobj(scau,-100,"0*")="" S $P(vobj(scau),$C(124),39)=PSWDAUT
 .  S:'$D(vobj(scau,-100,"0*","NEWPWDREQ")) vobj(scau,-100,"0*","NEWPWDREQ")="L004"_$P(vobj(scau),$C(124),4),vobj(scau,-100,"0*")="" S $P(vobj(scau),$C(124),4)=0
 .	Q 
 ;
 I $D(vobj(scau,-100)) D  I er K vobj(+$G(scau)) Q 1
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSCAU(scau,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(scau,-100) S vobj(scau,-2)=1 TC:vTp  
 .	I ER S er=1 S reply=$$ERRMSG^PBSUTL($get(RM),$get(ET)) Q 
 .	Q 
 ;
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^TOKEN(vop1)=$$RTBAR^%ZFUNC(token) S vop2=1 TC:vTp  
 S FLD(1)=vop1
 S FLD(2)=TJD
 S FLD(3)=LANG
 S reply=$$V2LV^MSG(.FLD)
 K vobj(+$G(scau)) Q 0
 ;
chkver(CLTYP,CLVER,%VNC) ; Private;Check client for compatibility w/ server
 ;
 ;  #ACCEPT DATE=12/17/03;PGM=John Carroll;CR=7239
 S %VNC=""
 I $get(CLTYP)="" Q 1
 I $get(CLVER)="" Q 1
 ;
 N PAR,PARAM,PGM,STS,X
 ;
 I '($D(^VERSION(CLTYP))#2) Q 1
 N version S version=$$vRCgetRecord0Opt^RecordVERSION(CLTYP,0,"")
 S PGM=$P(version,$C(124),1)
 I PGM="" Q 1
 ;
 ; Execute the validation routine to determine if the client version
 ; is supported by the server.
 ;
 S PAR(1)=CLTYP
 S PAR(2)=CLVER
 S PARAM=$$param^PBSUTL(.PAR)
 ;
 ;  #ACCEPT DATE=12/17/03;PGM=John Carroll;CR=7239
 S X="S STS="_PGM_"("_PARAM_")" XECUTE X
 ;  #ACCEPT DATE=12/17/03;PGM=John Carroll;CR=7239
 I STS S %VNC=CLTYP_"-"_CLVER
 Q STS
 ;
CHKVER(CLTYP,CLVER) ; Standard version compatibility validation routine
 ;
 N X
 ;
 I $get(%VN)="" N %VN D
 .	N cuvar S cuvar=$$vRCgetRecord0Opt^RecordCUVAR(0,"")
 .	 S cuvar=$G(^CUVAR("%VN"))
 .	;   #ACCEPT DATE=12/17/03;PGM=John Carroll;CR=7239
 .	S %VN=$P(cuvar,$C(124),1)
 .	Q 
 I '$$vDbEx7() Q 1
 N version S version=$$vRCgetRecord0Opt^RecordVERSIONCL(CLTYP,%VN,0,"")
 ;
 I $P(version,$C(124),2)="" S newversionid=99999
 I CLVER<$P(version,$C(124),1) Q 0
 I CLVER>$P(version,$C(124),2) Q 0
 Q 1
 ;
chkpwd(scau,SRVPRC) ; Private;Check password
 ;
 ; Allow null password if trusted
 I PWD="",$$trust Q 
 ;
 I SRVPRC=1 D
 .	I $$ENC^SCAENC(PWD)=$P(vobj(scau),$C(124),6) Q 
 .	; Allow native STF
 .	I stfflg,'rectyp Q 
 .	S er=1 S reply=$$CSERR^PBSUTL("SV_INVLDPWD")
 .	Q 
 ;
 I SRVPRC=5 D
 .	N AUT,X
 .	N token S token=$$vRCgetRecord0Opt^RecordTOKEN(%TOKEN,0,"")
 .	I $P(token,$C(124),12)="" S er=1 S reply=$$CSERR^PBSUTL("SV_INVLDTKN") Q 
 .	;
 .	S X=$$AUT^%ENCRYPT($P(token,$C(124),12),$P(vobj(scau),$C(124),39),.AUT)
 .	I X S er=1 S reply=$$CSERR^PBSUTL("SV_INVLDENC") Q 
 .	I AUT'=PWD S er=1 S reply=$$CSERR^PBSUTL("SV_INVLDPWD") Q 
 .	Q 
 Q 
 ;
pswdaut(PWD,PSWDAUT) ; Private;32 character encryption
 ;
 S er=$$ENC^%ENCRYPT(PWD,.PSWDAUT)
 I er S reply=$$CSERR^PBSUTL("SV_INVLDENC")
 Q 
 ;
trust() ; Private;Trusted mode?
 ;
 I $get(contxt)="" Q ""
 Q $E(contxt,$F(contxt,"/TRUST="))
 ;
NMSP2(reply,field) ; Private;Heartbeat
 ;
 S reply=$$V2LV^MSG("")
 Q 0
 ;
NMSP3(reply,field) ; Private;Client context
 N vTp
 ;
 N TOKEN
 ;
 S TOKEN=$get(field(2))
 I TOKEN="" S reply=$$CSERR^PBSUTL("SV_TOKENREQ") Q 1
 I '($D(^TOKEN(TOKEN))#2) S reply=$$CSERR^PBSUTL("SV_INVLDTKN") Q 1
 N token,vop1,vop2 S vop1=TOKEN,token=$$vRCgetRecord0Opt^RecordTOKEN(TOKEN,0,.vop2)
  S $P(token,$C(124),10)=$$ctxt($get(field(3)))
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^TOKEN(vop1)=$$RTBAR^%ZFUNC(token) S vop2=1 TC:vTp  
 S reply=$$V2LV^MSG("")
 Q 0
 ;
NMSP4(reply,field) ; Private;Sign-on request
 N vTp
 ;
 N KEY,TOKEN,UID
 ;
 S UID=$get(field(2))
 I UID="" S reply=$$CSERR^PBSUTL("SV_USRIDREQ") Q 1
 I '($D(^SCAU(1,UID))#2) S reply=$$CSERR^PBSUTL("SV_INVLDUID") Q 1
 ;
 ; Generate SignOnKey
 S KEY=$$KEY^%ENCRYPT
 N scau S scau=$$vRCgetRecord0Opt^RecordSCAU(UID,0,"")
 I $P(scau,$C(124),39)="" S TOKEN=""
 E  D
 .	N token,vop1,vop2 S token="",vop2=0
 .  S $P(token,$C(124),1)=0
 .	S TOKEN=$$TOKEN
 .  S vop1=TOKEN
 .  S $P(token,$C(124),12)=KEY
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^TOKEN(vop1)=$$RTBAR^%ZFUNC(token) S vop2=1 TC:vTp  
 .	Q 
 ;
 S FLD(1)=TOKEN
 S FLD(2)=KEY
 S reply=$$V2LV^MSG(.FLD)
 Q 0
 ;
NMSP5(reply,field) ; Private;Sign-on authentication
 ;
 Q $$NMSP1(.reply,.field)
 ;
NMSP6(reply,field) ; Private;Switch Userclasses
 N vTp
 ;
 N er S er=0
 N TOKEN N UCLS N UID
 ;
 S TOKEN=$get(field(2))
 I (TOKEN="") S reply=$$CSERR^PBSUTL("SV_TOKENREQ") Q 1
 ;
 S UCLS=$get(field(3))
 ;
 N token,vop1,vop2 S vop1=TOKEN,token=$$vRCgetRecord0Opt^RecordTOKEN(TOKEN,0,.vop2)
 ;
 N scau S scau=$$vRCgetRecord0Opt^RecordSCAU(UID,0,"")
 ;
 I (UCLS'=$P(scau,$C(124),5)) D  I er Q 1
 .	;
 .	I '((","_$P(scau,$C(124),13)_",")[(","_UCLS_",")) D  ; Not valid alternative userclass
 ..		;
 ..		S er=1
 ..		; Invalid userclass ~p1
 ..		S reply=$$ERRMSG^PBSUTL($$^MSG(6755,UCLS),"")
 ..		Q 
 .	Q 
 ;
  S $P(token,$C(124),6)=UCLS
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^TOKEN(vop1)=$$RTBAR^%ZFUNC(token) S vop2=1 TC:vTp  
 ;
 S reply=$$V2LV^MSG("")
 ;
 D vKill1("") K %CACHE
 S %CACHE=$P($H,",",2)
 ;
 Q 0
 ;
NMSP99(reply,field) ; Private;Function calls (non-IBS specific)
 ;
 N FUNC,PAR,PTR,X
 ;
 S PTR=$$LV2V^MSG($get(field(3)),.PAR)
 S FUNC="$$"_$get(field(2))_"^%ZFUNC("
 S FUNC=FUNC_$$param^PBSUTL(.PAR)_")"
 ;  #ACCEPT DATE=12/17/03;PGM=John Carroll;CR=7239
 XECUTE "S X="_FUNC
 ;
 S reply=$$V2LV^MSG(.X)
 Q 0
 ;
TOKEN() ; Private;Generate client token
 ;
 N token N encodepid N uppertkn
 N dpid N dseq N tlength
 N pid S pid=$J
 ;
 S encodepid=$$ENCODE(pid)
 S uppertkn=encodepid_"{{{{"
 ;
 N rs,vos1,vos2,vos3,vos4,vos5  N V1 S V1=uppertkn S rs=$$vOpen2()
 I $$vFetch2() D  ; at most one row, but may be empty
 .	;
 .	S token=rs
 .	S tlength=$L(token)
 .	;
 .	I $E(token,1,tlength-4)=encodepid D
 ..		S dseq=$$DECODE($E(token,tlength-3,tlength))
 ..		S token=encodepid_$$ENCODE(dseq+1)
 ..		Q 
 .	E  S token=encodepid_")((("
 .	;
 .	Q 
 E  S token=encodepid_")((("
 ;
 Q token
 ;
ENCODE(pidseq) ; 
 ; Encode process id and sequence.
 ;
 N base83 S base83=""
 ;
 F  D  Q:'pidseq 
 .	;
 .	S base83=$char(((pidseq#83)+40))_base83
 .	S pidseq=pidseq\83
 .	Q 
 ;
 Q base83
 ;
DECODE(token) ; 
 ;
 ;Decode before incrementing to get next sequence.
 ;
 N tlen
 N return S return=0
 N y S y=1
 ;
 S tlen=$L(token)
 ;
 F i=1:1:tlen D
 .	;
 .	S return=return+(($ascii(token,i)-40)*(83**(tlen-y)))
 .	S y=y+1
 .	;
 .	Q 
 Q return
 ;
ctxt(CONTXT) ; Private;Parse client context data
 ;
 I CONTXT="" Q ""
 ;
 N DATA,I,J,NAM,PTR,SRVCLS,STRING,SUB,VAL,X
 ;
 S PTR=$$LV2V^MSG(CONTXT,.SUB)
 S STRING=""
 ;
 F I=1:1 Q:'$D(SUB(I))  K DATA D
 .	S PTR=$$LV2V^MSG(SUB(I),.DATA)
 .	S SRVCLS=$get(DATA(1)) Q:'SRVCLS 
 .	S X=""
 .	;
 .	; Qualifier^value
 .	F J=2:2 Q:$get(DATA(J))=""  D
 ..		S NAM=DATA(J)
 ..		S X=X_"/"_NAM
 ..		S VAL=$get(DATA(J+1))
 ..		I VAL'="" S X=X_"="_VAL
 ..		;
 ..		Q 
 .	S $piece(STRING,$char(28),SRVCLS)=X
 .	Q 
 ;
 Q STRING
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61262^51156^Badrinath Giridharan^16438" ; Signature - LTD^TIME^USER^SIZE
 ;
vDbEx2() ; min(1): DISTINCT UID FROM SCAU WHERE UID=:%UID
 ;
 N vsql1,vsql2
 S vsql1=$$BYTECHAR^SQLUTL(254)
 S vsql2=$G(%UID) I vsql2="" Q 0
 I '($D(^SCAU(1,vsql2))#2) Q 0
 Q 1
 ;
vDbEx5() ; min(1): DISTINCT TOKEN FROM TOKEN WHERE TOKEN=:%TOKEN
 ;
 N vsql1,vsql2
 S vsql1=$$BYTECHAR^SQLUTL(254)
 S vsql2=$G(%TOKEN) I vsql2="" Q 0
 I '($D(^TOKEN(vsql2))#2) Q 0
 Q 1
 ;
vDbEx7() ; min(1): DISTINCT CLTYP,VERSID FROM VERSIONCL WHERE CLTYP=:CLTYP AND VERSID=:%VN
 ;
 N vsql1,vsql3
 S vsql1=$$BYTECHAR^SQLUTL(254)
 ;
 S vsql3=$G(%VN)
 I '($D(^VERSION(CLTYP,vsql3))#2) Q 0
 Q 1
 ;
vKill1(ex1) ; Delete objects %CACHE()
 ;
 N n1 S (n1)=""
 F  S n1=$O(%CACHE(n1)) Q:n1=""  K:'((n1=ex1)) vobj(%CACHE(n1))
 Q
 ;
vOpen1() ; SRVCLS FROM STBLSRVCLS WHERE SRVCLS>0
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=0
vL1a3 S vos3=$O(^STBL("SRVCLS",vos3),1) I vos3="" G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a3
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos3=vos2:"",1:vos3)
 ;
 Q 1
 ;
vOpen2() ; MAX(TOKEN) FROM TOKEN WHERE TOKEN < :V1
 ;
 ;
 S vos1=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos1=0 Q
vL2a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="",'$D(V1) G vL2a0
 S vos4=""
vL2a4 S vos4=$O(^TOKEN(vos4),1) I vos4=""!(vos3']]vos4) G vL2a7
 I $S(vos4=vos2:"",1:vos4)'="" S vos5=$S($G(vos5)="":$S(vos4=vos2:"",1:vos4),vos5']$S(vos4=vos2:"",1:vos4):$S(vos4=vos2:"",1:vos4),1:vos5)
 G vL2a4
vL2a7 I $G(vos5)="" S vd="" G vL2a0
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos1=1 D vL2a7
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$G(vos5)
 S vos1=100
 ;
 Q 1
