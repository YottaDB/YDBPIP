PBSMRPC(vzreply,vzstfflg,vzrecord,vzrectyp,vzcontxt)	;Private;M Remote Procedure Calls
	;
	; **** Routine compiled from DATA-QWIK Procedure PBSMRPC ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	N rpcerror,vzermsg,vzfld,vzlod,vzlog,vzlst,vzpar,vzptr
	N vld24x7,vzrpc,vzsav,vzver,vzx
	N vsupv N verrors
	;
	S rpcerror=0
	S ER=0
	;
	; Public/private fields
	S vzptr=$$LV2V^MSG(vzrecord,.vzfld)
	;
	; MRPC ID/pgm
	S vzrpc=$get(vzfld(1))
	;
	; Version number
	S vzver=$get(vzfld(2))
	;
	; Input parameters
	S vzpar=$get(vzfld(3))
	;
	; Restriction/override information
	D SPV($get(vzfld(4)),.vsupv,.vzrstflg)
	;
	I vzrpc="" D  Q ER
	.	; Server Error - request message requires an MRPC ID
	.	S vzreply=$$CSERR^PBSUTL("SV_RPCIDREQ")
	.	I vzstfflg D STF(vzrecord,.vzreply)
	.	Q 
	;
	; Public MRPC
	I vzrpc'["^" D  Q rpcerror
	.	I vzver="" D  Q 
	..		S rpcerror=1
	..		; Server Error - request message requires a version number
	..		S vzreply=$$CSERR^PBSUTL("SV_VERSNREQ")
	..		I vzstfflg D STF(vzrecord,.vzreply)
	..		Q 
	.	;
	.	N scatbl5 S scatbl5=$G(^SCATBL(5,vzrpc))
	.	S vzpgm=$P(scatbl5,$C(124),2)
	.	S vzlog=$P(scatbl5,$C(124),3)
	.	;
	.	I vzpgm="" D  Q 
	..		S rpcerror=1
	..		; Server Error - the MRPC requested is not valid
	..		S vzreply=$$CSERR^PBSUTL("SV_INVLDRPC")
	..		I vzstfflg D STF(vzrecord,.vzreply)
	..		Q 
	.	;
	.	N UCLS
	.	S UCLS="*"
	.	 N V1 S V1=vzrpc I '$$vDbEx1()  N V2 S V2=vzrpc I '($D(^SCATBL(5,V2,UCLS))#2) D  Q 
	..		S rpcerror=1
	..		; Server Error - user is not authorized to execute MRPC
	..		S vzreply=$$CSERR^PBSUTL("SV_NOAUTRPC")
	..		I vzstfflg D STF(vzrecord,.vzreply)
	..		Q 
	.	;
	.	I $get(%STFHOST) D  Q:rpcerror 
	..		N rtn
	..		S rtn=$piece(vzpgm,"(",1)
	..		I $E(rtn,1,2)="$$" S rtn=$E(rtn,3,1048575)
	..		I $L(rtn,"^")'=2 S rtn="^"_rtn
	..		;
	..		;VALID24X7
	..		N utblrtns S utblrtns=$G(^UTBL("RTNS",rtn))
	..		I $P(utblrtns,$C(124),1) Q 
	..		;
	..		; Access not allowed for MRPC ~p1 at this time
	..		S ER=1
	..		S RM=$$^MSG(3247,vzrpc)
	..		S rpcerror=1
	..		S vzreply=$$ERRMSG^PBSUTL($get(RM),$get(ET))
	..		I vzstfflg D STF(vzrecord,.vzreply)
	..		Q 
	.	;
	.	; Add parameters to MRPC; execute remote procedure call
	.	S vzptr=$$LV2V^MSG(vzpar,.vzx)
	.	S vzpar=$$PARAM(.vzx)
	.	S vzx="S vzermsg="_vzpgm_"(.vzreply,vzver,"_vzpar_")"
	.	;
	.	; Execute Remote Procedure Call
	.	;   #ACCEPT DATE=5/15/03;PGM=Erik Scheetz
	.	XECUTE vzx
	.	;
	.	I '(vzermsg="") S rpcerror=1 S vzreply=vzermsg
	.	E  I $get(vzrstflg) D
	..		I $D(verrors) D APPLYOVR(.verrors,.vsupv)
	..		I $D(verrors) D
	...		 Trollback:$Tlevel 
	...			S rpcerror=1
	...			S vzreply=$$OVRMSG^PBSMSQL(.verrors)
	...			Q 
	..		Q 
	.	Q 
	;
	Q ""
	;
exec()	;Private;Execute MRPC ($$tag^pgm) or stub (D @pgm)
	;
	N vzsav
	I vzlst'="" S %RPC=vzlst
	I vzlod'="" D VLOD^PBSUTL(.vzlod)
	;
	I $E(vzpgm,1,2)="$$" D
	.	;   #ACCEPT DATE=12/17/03;PGM=John Carroll
	.	XECUTE "S vzx="_vzpgm
	.	Q 
	;
	E  D @vzpgm S vzx=""
	;
	I $get(ER),vzstfflg D STF(vzrecord,$$ERRMSG^PBSUTL($get(RM),$get(ET)))
	;
	Q vzx
	;
list()	;Private;Return ordered list of values specified by %RPC
	;
	I $get(%RPC)="" Q ""
	I $piece(%RPC,",",1)'=vzver S ER=1 Q ""
	;
	N vz,vzi,vzx
	;
	S vz=""
	F vzi=2:1 S vzx=$piece(%RPC,",",vzi) Q:vzx=""  D
	.	S $piece(vz,$char(28),vzi-1)=$get(@vzx)
	.	Q 
	Q vz
	;
STF(pkt,reply)	; Private; Store and forward handling of rejected updates
	;
	N io,JD,x,X
	;
	S JD=+$P($H,",",1)
	S X=$$DAY^SCADAT(JD,1)_$$MON^SCADAT(JD,1)_$$YEAR^SCADAT(JD,1)
	S io=$$SCAU^%TRNLNM("SPOOL","STF_"_X_".MRPC")
	;
	S x=$$FILE^%ZOPEN(io,"WRITE/APPEND/SHARE",2,16384)
	I 'x D STFGBL(pkt,.reply) Q 
	;
	USE io
	;
	; I18N=OFF
	WRITE !
	;
	;Log original client message to RMS
	WRITE pkt,!
	;
	;Log server/application reply to RMS
	WRITE reply,!
	;
	; I18N=ON
	CLOSE io
	;
	S ER=0
	S reply=""
	;
	Q 
	;
STFGBL(pkt,reply)	; File record to global
	;
	N i,%seq,%sq
	;
	LOCK +STF(%UID)
	;
	S %sq=$O(^STF(%UID,""),-1)+1
	;
	N stf1,vop1,vop2,vop3 S stf1="",vop2="",vop1="",vop3=0
	S vop2=%UID
	S vop1=%sq
	S $P(stf1,$C(124),6)=TLO
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^STF(vop2,vop1)=$$RTBAR^%ZFUNC(stf1) S vop3=1 Tcommit:vTp  
	;
	LOCK -STF(%UID)
	;
	N stf,vop4,vop5,vop6,vop7
	;
	F i=1:400:$L(pkt) D
	.	S %seq=i\400+1
	.	N STFMSG
	.	S STFMSG=$E(pkt,i,i+399)
	.	;
	. S stf="",vop6="",vop5="",vop4="",vop7=0
	. S vop6=%UID
	. S vop5=%sq
	. S vop4=%seq
	. S $P(stf,$C(124),1)=STFMSG
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^STF(vop6,vop5,vop4)=$$RTBAR^%ZFUNC(stf) S vop7=1 Tcommit:vTp  
	.	Q 
	;
	F i=1:400:$L(reply) D
	.	S %seq=%seq+1
	.	N STFMSG1
	.	S STFMSG1=$E(reply,i,i+399)
	.	;
	. S stf="",vop6="",vop5="",vop4="",vop7=0
	. S vop6=%UID
	. S vop5=%sq
	. S vop4=%seq
	. S $P(stf,$C(124),1)=STMSG1
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^STF(vop6,vop5,vop4)=$$RTBAR^%ZFUNC(stf) S vop7=1 Tcommit:vTp  
	.	Q 
	;
	S ER=0
	S reply=""
	;
	Q 
	;
SPV(ovr,vsupv,vzrstflg)	;Convert override info to vsupv array
	;
	N vzrest N spvarr
	N INDX N SPVUID N VZPTR1
	N DONE N ER S ER=0
	N SPVREST
	;
	I ovr="" S vzrstflg=0
	;
	E  D
	.	S VZPTR1=$$LV2V^MSG(ovr,.vzrest)
	.	S INDX=""
	.	;
	.	F  S INDX=$order(vzrest(INDX)) Q:(INDX="")  D  Q:$get(ER)!$get(DONE) 
	..		S VZPTR1=$$LV2V^MSG(ovr,.spvarr)
	..		S SPVREST=spvarr(1)
	..		;
	..		I SPVREST=0 D
	...			S vzrstflg=0
	...			S DONE=1
	...			Q 
	...			Q 
	..		;
	..		I (SPVREST=1!(SPVREST="*"&(""=1))) D
	...			S vzrstflg=1
	...			S DONE=1
	...			Q 
	..		S SPVUID=$get(spvarr(2))
	..		;
	..		I (SPVUID="") D
	...			S SPVUID=%UID
	...			;
	...			Q 
	..		E  D
	...			; Invalid user ~p1
	...			I '($D(^SCAU(1,SPVUID))#2) D SETERR^DBSEXECU("SCAU","MSG",7591,SPVUID) Q 
	...			;
	...			; Invalid password
	...			I '$$VALIDATE^SCADRV1($get(spvarr(3)),SPVUID) D SETERR^DBSEXECU("SCAU","MSG",1419)
	...			Q 
	..		;
	..		I (SPVREST["_") S SPVREST=$piece(SPVREST,"_",3)
	..		;
	..		S vsupv(SPVREST)=SPVUID
	..		;
	..		I SPVREST="*" S DONE=1
	..		Q 
	.	I $D(vsupv) S vzrstflg=1
	.	Q 
	;
	Q 
	;
APPLYOVR(verrors,vsupv)	;Apply overrides to restrictions
	;
	; Save overridden errors. In the event that all errors can not be overridden
	; they must be restored so all restrictions can be passed back to client.
	;
	N verrsav
	N ET N IDENT N REST N SEQ N SPVUID N TBL N UCLS N UCLSARR
	N DONE
	;
	S DONE=0
	S REST="" S SEQ=""
	;
	F  S REST=$order(verrors(REST)) Q:(REST="")  D  Q:DONE 
	.	F  S SEQ=$order(verrors(REST,SEQ)) Q:(SEQ="")  D  Q:$get(DONE)!$get(ER) 
	..		S SPVUID=""
	..		S ET=$piece(verrors(REST,SEQ),"|",3)
	..		I ($D(vsupv("*"))#2) S SPVUID=vsupv("*")
	..		E  I ($D(vsupv(ET))#2) S SPVUID=vsupv(ET)
	..		;
	..		; authorization not provided
	..		I (SPVUID="") S DONE=1 Q 
	..		;
	..		; setup user class array
	..		I '($D(UCLSARR(SPVUID))#2) D
	...			N scau S scau=$G(^SCAU(1,SPVUID))
	...			;
	...			S UCLSARR(SPVUID)=$P(scau,$C(124),5)
	...			Q 
	..		S UCLS=UCLSARR(SPVUID)
	..		I '($D(^UTBL("XBAD",ET,UCLS))#2) S DONE=1 Q 
	..		S TBL=$piece(verrors(REST),"|",1)
	..		S IDENT=$piece(verrors(REST),"|",2)
	..		I TBL="CIF" D
	...			N xbadc S xbadc=$$vDb4(TJD,SPVUID,IDENT,REST,ET)
	...		 S $P(vobj(xbadc),$C(124),1)=SPVUID
	...		 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DAYXBCFL(xbadc,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(xbadc,-100) S vobj(xbadc,-2)=1 Tcommit:vTp  
	...			K vobj(+$G(xbadc)) Q 
	..		E  D
	...			N xbad,vop1,vop2,vop3,vop4,vop5,vop6 S vop5=TJD,vop4=SPVUID,vop3=IDENT,vop2=REST,vop1=ET,xbad=$$vDb6(TJD,SPVUID,IDENT,REST,ET,.vop6)
	...		 S $P(xbad,$C(124),1)=SPVUID
	...		 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^DAYEND(vop5,"XBAD",vop4,vop3,vop2,vop1)=$$RTBAR^%ZFUNC(xbad) S vop6=1 Tcommit:vTp  
	...			Q 
	..		S verrsav(REST)=verrors(REST)
	..		S verrsav(REST,SEQ)=verrors(REST,SEQ)
	..		K verrors(REST,SEQ)
	..		I $D(verrors(REST))<10 K verrors(REST)
	..		Q 
	.	Q 
	;
	I $D(verrors) D
	.	S REST="" S SEQ=""
	.	;
	.	F  S REST=$order(verrsav(REST)) Q:(REST="")  D
	..		S verrors(REST)=verrsav(REST)
	..		;
	..		F  S SEQ=$order(verrsav(REST,SEQ)) Q:(SEQ="")  D
	...			S verrors(REST,SEQ)=verrsav(REST,SEQ)
	...			Q 
	..		Q 
	.	Q 
	;
	Q 
	;
PARAM(vzx)	; Create parameter string for indirection call
	;
	N i
	N str S str=""
	;
	; build parameter string
	F i=1:1 Q:'$D(vzx(i))  S str=str_"vzx("_i_"),"
	;
	; remove trailing comma
	S str=$E(str,1,$L(str)-1)
	;
	Q str
	;
vSIG()	;
	Q "60638^40806^Shriram Deshpande^9811" ; Signature - LTD^TIME^USER^SIZE
	;
vDb4(v1,v2,v3,v4,v5)	;	vobj()=Db.getRecord(DAYENDXBADC,,1)
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
vDb6(v1,v2,v3,v4,v5,v2out)	;	voXN = Db.getRecord(DAYENDXBAD,,1,-2)
	;
	N xbad
	S xbad=$G(^DAYEND(v1,"XBAD",v2,v3,v4,v5))
	I xbad="",'$D(^DAYEND(v1,"XBAD",v2,v3,v4,v5))
	S v2out='$T
	;
	Q xbad
	;
vDbEx1()	;	min(1): DISTINCT RPCID,UCLS FROM SCATBL5A WHERE RPCID=:V1 AND UCLS=:%UCLS
	;
	N vsql2
	;
	S vsql2=$G(%UCLS) I vsql2="" Q 0
	I '($D(^SCATBL(5,V1,vsql2))#2) Q 0
	Q 1
