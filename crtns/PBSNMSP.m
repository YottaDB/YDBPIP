PBSNMSP(reply,stfflg,record,rectyp,contxt)	;NMSP Service Class Driver
	;
	; **** Routine compiled from DATA-QWIK Procedure PBSNMSP ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	N field,ptr
	;
	S ptr=$$LV2V^MSG(record,.field)
	I $get(field(1))=0 Q $$NMSP0(.reply,.field)
	I $get(field(1))=1 Q $$NMSP1(.reply,.field)
	I $get(field(1))=2 Q $$NMSP2(.reply,.field)
	I $get(field(1))=3 Q $$NMSP3(.reply,.field)
	I $get(field(1))=4 Q $$NMSP4(.reply,.field)
	I $get(field(1))=5 Q $$NMSP5(.reply,.field)
	I $get(field(1))=99 Q $$NMSP99(.reply,.field)
	;
	; Invalid service procedure
	S reply=$$CSERR^PBSUTL("SV_INVLDNMP")
	Q 1
	;
NMSP0(reply,field)	;Private;Sign-off
	;
	N TOKEN
	;
	S TOKEN=$get(field(2))
	I TOKEN="" S reply=$$CSERR^PBSUTL("SV_TOKENREQ") Q 1
	;
	N token,vop1,vop2 S vop1=TOKEN,token=$$vDb10(TOKEN,.vop2)
	I $G(vop2)=0 S reply=$$CSERR^PBSUTL("SV_INVLDTKN") Q 1
	S $P(token,$C(124),1)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^TOKEN(vop1)=$$RTBAR^%ZFUNC(token) S vop2=1 Tcommit:vTp  
	S reply=$$V2LV^MSG("")
	Q 0
	;
NMSP1(reply,field)	;Private;Sign-on
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
	;
	I UID="" S reply=$$CSERR^PBSUTL("SV_USRIDREQ") Q 1
	I STN="" S reply=$$CSERR^PBSUTL("SV_STNIDREQ") Q 1
	I '$$chkver(CLTYP,CLVER,.%VNC) S reply=$$CSERR^PBSUTL("SV_MISMATCH") Q 1
	I INST'="" D  I er Q 1
	.	I '($D(^CTBL("INST",INST))#2) S er=1 S reply=$$CSERR^PBSUTL("SV_INVLDINS") Q 
	.	N ctblinst S ctblinst=$$vDb11(INST)
	.	S GBLDIR=$P(ctblinst,$C(124),2) I GBLDIR'="" S $ZGBLDIR=GBLDIR
	.	Q 
	;
	S %UID=UID
	I '$$vDbEx2() S reply=$$CSERR^PBSUTL("SV_INVLDUID") Q 1
	I rectyp,%UID'?1N.N S reply=$$CSERR^PBSUTL("SV_USRIDFMT") Q 1
	;
	N scau S scau=$$vDb3(%UID)
	;
	I $$STATUS^SCAUCDI($P(vobj(scau),$C(124),5),$P(vobj(scau),$C(124),8),$P(vobj(scau),$C(124),44),$P(vobj(scau),$C(124),43))=3 S reply=$$CSERR^PBSUTL("SV_USRIDREV") K vobj(+$G(scau)) Q 1
	;
	S LANG=$P(vobj(scau),$C(124),3)
	S UCLS=$P(vobj(scau),$C(124),5)
	S PWDFAIL=$P(vobj(scau),$C(124),43)
	;
	; Check password expiration
	I $P(vobj(scau),$C(124),7)<$P($H,",",1) D  I er K vobj(+$G(scau)) Q 1
	.	; Allow native STF
	.	I stfflg,'rectyp Q 
	.	S er=1 S reply=$$CSERR^PBSUTL("SV_PSWRDEXP")
	.	Q 
	;
	D chkpwd(.scau,field(1)) I er D  K vobj(+$G(scau)) Q 1
	.	S PWDFAIL=PWDFAIL+1
	. S:'$D(vobj(scau,-100,"0*","PWDFAIL")) vobj(scau,-100,"0*","PWDFAIL")="N043"_$P(vobj(scau),$C(124),43) S vobj(scau,-100,"0*")="",$P(vobj(scau),$C(124),43)=PWDFAIL
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^SCAUFILE(scau,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(scau,-100) S vobj(scau,-2)=1 Tcommit:vTp  
	.	Q 
	;
	I LANG'="" D  I er K vobj(+$G(scau)) Q 1
	.	I '($D(^UTBL("LANG",LANG))#2) D  I er Q 
	..		; Allow native STF
	..		I stfflg,'rectyp Q 
	..		S er=1 S reply=$$CSERR^PBSUTL("SV_INVLDLNG") Q 
	..		Q 
	.	E  D
	..		N lang S lang=$$vDb12(LANG)
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
	.	N rs,vos1,vos2 S rs=$$vOpen1()
	.	I ''$G(vos1) F  Q:'($$vFetch1())  D
	..		S SRV=rs
	..		I $D(FAP(SRV)) S $piece(FAPS,"~",SRV)=FAP(SRV)
	..		Q 
	.	Q 
	;
	N token,vop1,vop2 S token="",vop1="",vop2=0
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
	I field(1)=1!($get(%TOKEN)="") D
	.	S TOKEN=$$TOKEN
	. S vop1=TOKEN
	. K ^MSGLOG(TOKEN)
	. K ^SQLCUR(TOKEN)
	.	Q 
	;
	E  D  I er K vobj(+$G(scau)) Q 
	.	I '$$vDbEx5() S vop1=%TOKEN Q 
	.	N token2 S token2=$$vDb13(%TOKEN)
	.	I '$P(token2,$C(124),1) S vop1=%TOKEN Q 
	.	S er=1 S reply=$$CSERR^PBSUTL("SV_TOKINUSE")
	.	Q 
	;
	; Only need to update these two fields if they're actually going to change
	I $P(vobj(scau),$C(124),8)'=$P($H,",",1) S:'$D(vobj(scau,-100,"0*","LSGN")) vobj(scau,-100,"0*","LSGN")="D008"_$P(vobj(scau),$C(124),8) S vobj(scau,-100,"0*")="",$P(vobj(scau),$C(124),8)=$P($H,",",1)
	I $P(vobj(scau),$C(124),43)'=0 S:'$D(vobj(scau,-100,"0*","PWDFAIL")) vobj(scau,-100,"0*","PWDFAIL")="N043"_$P(vobj(scau),$C(124),43) S vobj(scau,-100,"0*")="",$P(vobj(scau),$C(124),43)=0
	;
	I NPWD="" D  I er K vobj(+$G(scau)) Q 1
	.	I $P(vobj(scau),$C(124),4) S er=1 S reply=$$CSERR^PBSUTL("SV_NEWPWREQ") Q 
	.	;
	.	; If password is already encrypted quit
	.	I $E(PWD,1)=$char(1) Q 
	.	I $P(vobj(scau),$C(124),39)'="" Q 
	.	D pswdaut(PWD,.PSWDAUT) I er Q 
	. S:'$D(vobj(scau,-100,"0*","PSWDAUT")) vobj(scau,-100,"0*","PSWDAUT")="T039"_$P(vobj(scau),$C(124),39) S vobj(scau,-100,"0*")="",$P(vobj(scau),$C(124),39)=PSWDAUT
	.	Q 
	;
	I NPWD'="" D  I er K vobj(+$G(scau)) Q 1
	.	S PSWD=$$ENC^SCAENC(NPWD)
	.	D pswdaut(NPWD,.PSWDAUT) I er Q 
	. S:'$D(vobj(scau,-100,"0*","PSWD")) vobj(scau,-100,"0*","PSWD")="T006"_$P(vobj(scau),$C(124),6) S vobj(scau,-100,"0*")="",$P(vobj(scau),$C(124),6)=PSWD
	. S:'$D(vobj(scau,-100,"0*","PSWDAUT")) vobj(scau,-100,"0*","PSWDAUT")="T039"_$P(vobj(scau),$C(124),39) S vobj(scau,-100,"0*")="",$P(vobj(scau),$C(124),39)=PSWDAUT
	. S:'$D(vobj(scau,-100,"0*","NEWPWDREQ")) vobj(scau,-100,"0*","NEWPWDREQ")="L004"_$P(vobj(scau),$C(124),4) S vobj(scau,-100,"0*")="",$P(vobj(scau),$C(124),4)=0
	.	Q 
	;
	I $D(vobj(scau,-100)) D  I er K vobj(+$G(scau)) Q 1
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^SCAUFILE(scau,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(scau,-100) S vobj(scau,-2)=1 Tcommit:vTp  
	.	I ER S er=1 S reply=$$ERRMSG^PBSUTL($get(RM),$get(ET)) Q 
	.	Q 
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^TOKEN(vop1)=$$RTBAR^%ZFUNC(token) S vop2=1 Tcommit:vTp  
	S FLD(1)=vop1
	S FLD(2)=TJD
	S FLD(3)=LANG
	S reply=$$V2LV^MSG(.FLD)
	K vobj(+$G(scau)) Q 0
	;
chkver(CLTYP,CLVER,%VNC)	;Private;Check client for compatibility w/ server
	;
	;  #ACCEPT DATE=12/17/03;PGM=John Carroll;CR=7239
	S %VNC=""
	I $get(CLTYP)="" Q 1
	I $get(CLVER)="" Q 1
	;
	N PAR,PARAM,PGM,STS,X
	;
	I '($D(^VERSION(CLTYP))#2) Q 1
	N version S version=$$vDb14(CLTYP)
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
CHKVER(CLTYP,CLVER)	;Standard version compatibility validation routine
	;
	N X
	;
	I $get(%VN)="" N %VN D
	.	N cuvar S cuvar=$$vDb15()
	.	 S cuvar=$G(^CUVAR("%VN"))
	.	;   #ACCEPT DATE=12/17/03;PGM=John Carroll;CR=7239
	.	S %VN=$P(cuvar,$C(124),1)
	.	Q 
	I '$$vDbEx7() Q 1
	N version S version=$$vDb16(CLTYP,%VN)
	;
	I $P(version,$C(124),2)="" S newversionid=99999
	I CLVER<$P(version,$C(124),1) Q 0
	I CLVER>$P(version,$C(124),2) Q 0
	Q 1
	;
chkpwd(scau,SRVPRC)	;Private;Check password
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
	.	N token S token=$$vDb13(%TOKEN)
	.	I $P(token,$C(124),12)="" S er=1 S reply=$$CSERR^PBSUTL("SV_INVLDTKN") Q 
	.	;
	.	S X=$$AUT^%ENCRYPT($P(token,$C(124),12),$P(vobj(scau),$C(124),39),.AUT)
	.	I X S er=1 S reply=$$CSERR^PBSUTL("SV_INVLDENC") Q 
	.	I AUT'=PWD S er=1 S reply=$$CSERR^PBSUTL("SV_INVLDPWD") Q 
	.	Q 
	Q 
	;
pswdaut(PWD,PSWDAUT)	;Private;32 character encryption
	;
	S er=$$ENC^%ENCRYPT(PWD,.PSWDAUT)
	I er S reply=$$CSERR^PBSUTL("SV_INVLDENC")
	Q 
	;
trust()	;Private;Trusted mode?
	;
	I $get(contxt)="" Q ""
	Q $E(contxt,$F(contxt,"/TRUST="))
	;
NMSP2(reply,field)	;Private;Heartbeat
	;
	S reply=$$V2LV^MSG("")
	Q 0
	;
NMSP3(reply,field)	;Private;Client context
	;
	N TOKEN
	;
	S TOKEN=$get(field(2))
	I TOKEN="" S reply=$$CSERR^PBSUTL("SV_TOKENREQ") Q 1
	I '($D(^TOKEN(TOKEN))#2) S reply=$$CSERR^PBSUTL("SV_INVLDTKN") Q 1
	N token,vop1,vop2 S vop1=TOKEN,token=$$vDb17(TOKEN,.vop2)
	S $P(token,$C(124),10)=$$ctxt($get(field(3)))
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^TOKEN(vop1)=$$RTBAR^%ZFUNC(token) S vop2=1 Tcommit:vTp  
	S reply=$$V2LV^MSG("")
	Q 0
	;
NMSP4(reply,field)	;Private;Sign-on request
	;
	N KEY,TOKEN,UID
	;
	S UID=$get(field(2))
	I UID="" S reply=$$CSERR^PBSUTL("SV_USRIDREQ") Q 1
	I '($D(^SCAU(1,UID))#2) S reply=$$CSERR^PBSUTL("SV_INVLDUID") Q 1
	;
	; Generate SignOnKey
	S KEY=$$KEY^%ENCRYPT
	N scau S scau=$$vDb18(UID)
	I $P(scau,$C(124),39)="" S TOKEN=""
	E  D
	.	N token,vop1,vop2 S token="",vop1="",vop2=0
	. S $P(token,$C(124),1)=0
	.	S TOKEN=$$TOKEN
	. S vop1=TOKEN
	. S $P(token,$C(124),12)=KEY
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^TOKEN(vop1)=$$RTBAR^%ZFUNC(token) S vop2=1 Tcommit:vTp  
	.	Q 
	;
	S FLD(1)=TOKEN
	S FLD(2)=KEY
	S reply=$$V2LV^MSG(.FLD)
	Q 0
	;
NMSP5(reply,field)	;Private;Sign-on authentication
	;
	Q $$NMSP1(.reply,.field)
	;
NMSP99(reply,field)	;Private;Function calls (non-IBS specific)
	;
	N FUNC,PAR,PTR,X
	;
	S PTR=$$LV2V^MSG($get(field(3)),.PAR)
	S FUNC="$$"_$get(field(2))_"^%ZFUNC("
	S FUNC=FUNC_$$param^PBSUTL(.PAR)_")"
	;  #ACCEPT DATE=12/17/03;PGM=John Carroll;CR=7239
	XECUTE "S X="_FUNC
	;
	S reply=$$V2LV^MSG(X)
	Q 0
	;
TOKEN()	;Private;Generate client token
	;
	N STR,X,Y
	S STR="0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
	;
	N tok S tok=$$vDb9()
	 S vobj(tok,"LAST")=$G(^TOKENL("LAST"))
	S X=$P(vobj(tok,"LAST"),$C(124),1)+1
	I X>15018570 S X=1
	S vobj(tok,-100,"LAST")="",$P(vobj(tok,"LAST"),$C(124),1)=X
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(tok) K vobj(tok,-100) S vobj(tok,-2)=1 Tcommit:vTp  
	S Y="" F  Q:'X  S Y=$E(STR,((X-1)#62)+1)_Y S X=(X-1)\62
	K vobj(+$G(tok)) Q Y
	;
ctxt(CONTXT)	;Private;Parse client context data
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
	;
vSIG()	;
	Q "60445^58847^Pat Kelly^13314" ; Signature - LTD^TIME^USER^SIZE
	;
vDb10(v1,v2out)	;	voXN = Db.getRecord(TOKEN,,1,-2)
	;
	N token
	S token=$G(^TOKEN(v1))
	I token="",'$D(^TOKEN(v1))
	S v2out='$T
	;
	Q token
	;
vDb11(v1)	;	voXN = Db.getRecord(CTBLINST,,0)
	;
	N ctblinst
	S ctblinst=$G(^CTBL("INST",v1))
	I ctblinst="",'$D(^CTBL("INST",v1))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,CTBLINST" X $ZT
	Q ctblinst
	;
vDb12(v1)	;	voXN = Db.getRecord(UTBLLANG,,0)
	;
	N lang
	S lang=$G(^UTBL("LANG",v1))
	I lang="",'$D(^UTBL("LANG",v1))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,UTBLLANG" X $ZT
	Q lang
	;
vDb13(v1)	;	voXN = Db.getRecord(TOKEN,,0)
	;
	N token2
	S token2=$G(^TOKEN(v1))
	I token2="",'$D(^TOKEN(v1))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,TOKEN" X $ZT
	Q token2
	;
vDb14(v1)	;	voXN = Db.getRecord(VERSION,,0)
	;
	N version
	S version=$G(^VERSION(v1))
	I version="",'$D(^VERSION(v1))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,VERSION" X $ZT
	Q version
	;
vDb15()	;	voXN = Db.getRecord(CUVAR,,0)
	;
	I '$D(^CUVAR)
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,CUVAR" X $ZT
	Q ""
	;
vDb16(v1,v2)	;	voXN = Db.getRecord(VERSIONCL,,0)
	;
	N version
	S version=$G(^VERSION(v1,v2))
	I version="",'$D(^VERSION(v1,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,VERSIONCL" X $ZT
	Q version
	;
vDb17(v1,v2out)	;	voXN = Db.getRecord(TOKEN,,0,-2)
	;
	N token
	S token=$G(^TOKEN(v1))
	I token="",'$D(^TOKEN(v1))
	S v2out=1
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,TOKEN" X $ZT
	Q token
	;
vDb18(v1)	;	voXN = Db.getRecord(SCAU,,0)
	;
	N scau
	S scau=$G(^SCAU(1,v1))
	I scau="",'$D(^SCAU(1,v1))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,SCAU" X $ZT
	Q scau
	;
vDb3(v1)	;	vobj()=Db.getRecord(SCAU,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSCAU"
	S vobj(vOid)=$G(^SCAU(1,v1))
	I vobj(vOid)="",'$D(^SCAU(1,v1))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,SCAU" X $ZT
	S vobj(vOid,-3)=v1
	Q vOid
	;
vDb9()	;	vobj()=Db.getRecord(TOKENLAST,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordTOKENLAST"
	I '$D(^TOKENL)
	S vobj(vOid,-2)='$T
	;
	Q vOid
	;
vDbEx2()	;	min(1): DISTINCT UID FROM SCAU WHERE UID=:%UID
	;
	N vsql1
	S vsql1=$G(%UID) I vsql1="" Q 0
	I '($D(^SCAU(1,vsql1))#2) Q 0
	Q 1
	;
vDbEx5()	;	min(1): DISTINCT TOKEN FROM TOKEN WHERE TOKEN=:%TOKEN
	;
	N vsql1
	S vsql1=$G(%TOKEN) I vsql1="" Q 0
	I '($D(^TOKEN(vsql1))#2) Q 0
	Q 1
	;
vDbEx7()	;	min(1): DISTINCT CLTYP,VERSID FROM VERSIONCL WHERE CLTYP=:CLTYP AND VERSID=:%VN
	;
	N vsql2
	;
	S vsql2=$G(%VN) I vsql2="" Q 0
	I '($D(^VERSION(CLTYP,vsql2))#2) Q 0
	Q 1
	;
vOpen1()	;	SRVCLS FROM STBLSRVCLS WHERE SRVCLS>0
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=0
vL1a2	S vos2=$O(^STBL("SRVCLS",vos2),1) I vos2="" G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a2
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos2=$C(254):"",1:vos2)
	;
	Q 1
	;
vReSav1(tok)	;	RecordTOKENLAST saveNoFiler()
	;
	N vD,vN S vN=-1
	I '$G(vobj(tok,-2)) F  S vN=$O(vobj(tok,vN)) Q:vN=""  S vD=$$RTBAR^%ZFUNC(vobj(tok,vN)) S:vD'="" ^TOKENL(vN)=vD
	E  F  S vN=$O(vobj(tok,-100,vN)) Q:vN=""  S vD=$$RTBAR^%ZFUNC(vobj(tok,vN)) S:vD'="" ^TOKENL(vN)=vD I vD="" ZWI ^TOKENL(vN)
	Q
