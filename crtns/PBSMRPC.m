 ; 
 ; **** Routine compiled from DATA-QWIK Procedure PBSMRPC ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
PBSMRPC(vzreply,vzstfflg,vzrecord,vzrectyp,vzcontxt) ; Context  /NOREQ
 ;
 N vziserror N vzerror
 N i N ignore N vzptr N vzver
 N TSPV N verrors N vzcall N vzermsg N vzfld N vzpar N vzpgm N vzprocid N vzsupv N vzx
 ;
 S vziserror=0
 ;
 ; Public/private fields
 S vzptr=$$LV2V^MSG(vzrecord,.vzfld)
 ;
 ; Procedure name/RPC ID
 S vzprocid=$get(vzfld(1))
 ;
 ; Version number
 S vzver=$get(vzfld(2))
 ;
 ; Input parameters
 S vzpar=$get(vzfld(3))
 ;
 ; Restriction/override information
 D SPV($get(vzfld(4)),.vzsupv,.vzrstflg,.TSPV)
 ;
 I (vzprocid="") D  Q 1
 .	;
 .	; Server Error - request message requires an MRPC ID
 .	S vzreply=$$CSERR^PBSUTL("SV_RPCIDREQ")
 .	I vzstfflg D STF(vzrecord,.vzreply)
 .	Q 
 ;
 I (vzver="") D  Q 1
 .	;
 .	; Server Error - request message requires a version number
 .	S vzreply=$$CSERR^PBSUTL("SV_VERSNREQ")
 .	I vzstfflg D STF(vzrecord,.vzreply)
 .	Q 
 ;
 N scatbl5,vop1 S scatbl5=$$vCa6(vzprocid,.vop1)
 ;
 I ($G(vop1)=0) D  Q 1
 .	;
 .	; Server Error - the MRPC requested is not valid
 .	S vzreply=$$CSERR^PBSUTL("SV_INVLDRPC")
 .	I vzstfflg D STF(vzrecord,.vzreply)
 .	Q 
 ;
 ; For MRPCs, pad with leading zeros if less than three digits.
 I (vzprocid?1.N.E) D
 .	;
 .	N numpart S numpart=+vzprocid
 .	;
 .	I (numpart<10) S vzcall="$$^MRPC00"_vzprocid
 .	E  I (numpart<100) S vzcall="$$^MRPC0"_vzprocid
 .	E  S vzcall="$$^MRPC"_vzprocid
 .	;
 .	S vzpgm=$piece(vzcall,"^",2)
 .	Q 
 E  D
 .	;
 .	N label N proc
 .	;
 .	S proc=vzprocid
 .	;
 .	I (proc["^") D
 ..		;
 ..		S label=$piece(proc,"^",1)
 ..		S proc=$piece(proc,"^",2)
 ..		Q 
 .	E  S label=""
 .	;
 .	N dbtbl25,vop2 S dbtbl25=$$vCa7("SYSDEV",proc,.vop2)
 .	;
 .	; Not in DBTBL25, assume a .psl procedure
 .	I ($G(vop2)=0) S vzcall="^"_proc
 .	E  D
 ..		;
 ..		S vzpgm=$P(dbtbl25,$C(124),2)
 ..		S vzcall="^"_vzpgm
 ..		Q 
 .	;
 .	S vzcall="$$"_vzcall
 . Q 
 ;
 N scatbl5a,vop3 S scatbl5a=$$vCa8(vzprocid,%UCLS,.vop3)
 ;
 ; Determine if authorized for this userclass
 I ($G(vop3)=0),'$$vCaEx1() D  Q 1
 .	;
 .	; Server Error - user is not authorized to execute MRPC
 .	S vzreply=$$CSERR^PBSUTL("SV_NOAUTRPC")
 .	I vzstfflg D STF(vzrecord,.vzreply)
 .	Q 
 ;
 ; Check to see if valid 24x7 if in host STF mode
 I ($get(%STFHOST)>0) D  I vziserror Q 1
 .	;
 .	N utblrtns,vop4 S utblrtns=$$vCa9(vzprocid,.vop4)
 .	;
 .	I '$P(utblrtns,$C(124),1) D
 ..		;
 ..		S vziserror=1
 ..		;
 ..		; Access not allowed for MRPC ~p1 at this time
 ..		S vzreply=$$ERRMSG^PBSUTL($$^MSG(3247,vzprocid),"")
 ..		I vzstfflg D STF(vzrecord,.vzreply)
 ..		Q 
 . Q 
 ;
 ; Add parameters to procedure and execute the call
 S vzptr=$$LV2V^MSG(vzpar,.vzx)
 S vzpar=""
 F i=1:1 Q:'($D(vzx(i))#2)  S vzpar=vzpar_"vzx("_i_"),"
 S vzpar=$E(vzpar,1,$L(vzpar)-1)
 ;
 S vzcall=vzcall_"(.vzreply,vzver,"_vzpar_")"
 ;
 ; Log if required
 I $P(scatbl5a,$C(124),1) S ignore=$$auditLog^SQLAUDIT("EXECUTE",vzpgm,vzcall,"")
 ;
 S vzx="set vzermsg="_vzcall
 ;
 ; Execute Remote Procedure Call
 ;  #ACCEPT DATE=5/15/03; PGM=Erik Scheetz; CR=30802; Group=Xecute
 XECUTE vzx
 ;
 S vzerror=0
 ;
 I '(vzermsg="") D
 .	;
 .	S vzerror=1
 .	S vzreply=vzermsg
 .	Q 
 E  I $get(vzrstflg) D
 .	;
 .	I $D(verrors) D APPLYOVR(.verrors,.vzsupv)
 .	I $D(verrors) D
 ..		;
 ..	  TRO:$TL>0 
 ..		;
 ..		S vzerror=1
 ..		S vzreply=$$OVRMSG(.verrors)
 ..		Q 
 .	Q 
 ;
 Q vzerror
 ;
STF(pkt,reply) ; Reply  /MECH=REF:W
 ;
 N io S io=$$vClVobj($ST,"IO")
 ;
 S $P(vobj(io,1),"|",2)=$$SCAU^%TRNLNM("SPOOL")
 S $P(vobj(io,1),"|",1)="STF_"_$$vdat2str($P($H,",",1),"DDMMYEAR")_".MRPC"
 ;
 S $P(vobj(io,1),"|",3)="WRITE/APPEND/SHARE"
 S $P(vobj(io,1),"|",4)=2
 S $P(vobj(io,1),"|",5)=16384
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ;
 D open^UCIO(io,$T(+0),"STF","io")
 ;
 D write^UCIO(io,"")
 D write^UCIO(io,pkt) ;Log original client message to RMS
 D write^UCIO(io,reply) ;Log server/application reply to RMS
 ;
 D close^UCIO(io)
 ;
 S reply=""
 ;
 K vobj(+$G(io)) Q 
 ;
STFGBL(pkt,reply) ; Reply  /MECH=REF:W
 N vTp
 ;
 ; File record to global
 ;
 N %seq N %sq
 N STF
 ;
 S STF(%UID)="" ; Prevent warning related to lock
 L +STF(%UID)
 ;
 S %sq=$O(^STF(%UID,""),-1)+1
 ;
 N stf1,vop1,vop2,vop3 S stf1="",vop3=0
 ;
  S vop2=%UID
  S vop1=%sq
  S $P(stf1,$C(124),6)=TLO
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^STF(vop2,vop1)=$$RTBAR^%ZFUNC(stf1) S vop3=1 TC:vTp  
 ;
 L -STF(%UID)
 ;
 ; Save in 400 byte chunks
 S %seq=1
 F  Q:'('(pkt=""))  D
 .	;
 .	N saveVal S saveVal=$ZSUBSTR(pkt,1,400)
 .	;
 .	S pkt=$E(pkt,$L(saveVal)+1,1048575)
 .	;
 .	N stf,vop4,vop5,vop6,vop7 S stf="",vop7=0 S vop6=%UID S vop5=%sq S vop4=%seq
 .	;
 .  S $P(stf,$C(124),1)=saveVal
 .	;
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^STF(vop6,vop5,vop4)=$$RTBAR^%ZFUNC(stf) S vop7=1 TC:vTp  
 .	S %seq=%seq+1
 . Q 
 ;
 F  Q:'('(reply=""))  D
 .	;
 .	N saveVal S saveVal=$ZSUBSTR(reply,1,400)
 .	;
 .	S reply=$E(reply,$L(saveVal)+1,1048575)
 .	;
 .	N stf,vop8,vop9,vop10,vop11 S stf="",vop11=0 S vop10=%UID S vop9=%sq S vop8=%seq
 .	;
 .  S $P(stf,$C(124),1)=saveVal
 .	;
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^STF(vop10,vop9,vop8)=$$RTBAR^%ZFUNC(stf) S vop11=1 TC:vTp  
 .	S %seq=%seq+1
 . Q 
 ;
 S reply=""
 ;
 Q 
 ;
SPV(ovr,vzsupv,vzrstflg,TSPV) ; Transaction processing override  /MECH=REFARR:W
 ;
 ;Convert override info to vzsupv and TSPV array
 ;
 N DONE N ER
 N INDX1 N INDX2 N SPVREST N SPVUID N VZPTR1 N VZPTR2 N vzrest1
 ;
 S vzrstflg=0
 S DONE=0
 S ER=0
 ;
 I (ovr="") Q 
 ;
 S VZPTR1=$$LV2V^MSG(ovr,.vzrest1)
 S (INDX1,INDX2)=""
 F  S INDX1=$order(vzrest1(INDX1)) Q:(INDX1="")  D  Q:ER!DONE 
 .	;
 .	N vzrest2
 .	;
 .	S VZPTR2=$$LV2V^MSG(vzrest1(INDX1),.vzrest2)
 .	F  S INDX2=$order(vzrest2(INDX2)) Q:(INDX2="")  D  Q:ER!DONE 
 ..		;
 ..		N spvarr
 ..		;
 ..		S VZPTR2=$$LV2V^MSG(vzrest2(INDX2),.spvarr)
 ..		S SPVREST=spvarr(1)
 ..		;
 ..		I (SPVREST=0) D
 ...			;
 ...			K TSPV,vzsupv
 ...			;
 ...			S vzrstflg=0
 ...			S DONE=1
 ...			Q 
 ..		;
 ..		I (SPVREST=1) D
 ...			;
 ...			K TSPV,vzsupv
 ...			;
 ...			S vzrstflg=1
 ...			S DONE=1
 ...			Q 
 ..		;
 ..		S SPVUID=$get(spvarr(2))
 ..		;
 ..		I (SPVUID="") D  Q:ER 
 ...			;
 ...			; Invalid user ID
 ...			D SETERR^DBSEXECU("CUVAR","MSG",1504) Q:ER 
 ...			;
 ...			Q 
 ..		E  D
 ...			;
 ...			; Invalid user ~p1
 ...			I '$$vCaEx2() D SETERR^DBSEXECU("SCAU","MSG",7591,SPVUID) Q:ER 
 ...			;
 ...			; Invalid password
 ...			E  I '$$VALIDATE^SCADRV1($get(spvarr(3)),SPVUID) D SETERR^DBSEXECU("SCAU","MSG",1419) Q:ER 
 ...			Q 
 ..		;
 ..		N scau,vop1 S scau=$$vCa10(SPVUID,.vop1)
 ..		;
 ..  Q:DONE 
 ..		;
 ..		;If SPVREST begins with either OVR or RFLG, set up the TSPV() array.
 ..		;
 ..		I (SPVREST="*") D
 ...			;
 ...			S TSPV(INDX1)=SPVUID_"|"_$P(scau,$C(124),5)
 ...			;
 ...			S vzsupv(SPVREST)=SPVUID
 ...			;
 ...			Q 
 ..		E  I ($E(SPVREST,1,3)="OVR")!($E(SPVREST,1,4)="RFLG") D
 ...			;
 ...			S TSPV(INDX1,spvarr(4),$piece(SPVREST,"_",1),$piece(SPVREST,"_",3))=SPVUID_"|"_$P(scau,$C(124),5)
 ...			;
 ...			Q 
 ..		E  D
 ...			;
 ...			I (SPVREST["_") S SPVREST=$piece(SPVREST,"_",3)
 ...			;
 ...			S vzsupv(SPVREST)=SPVUID
 ...			Q 
 ..  Q 
 .	Q 
 ;
 I $D(vzsupv)!$D(TSPV) S vzrstflg=1
 ;
 Q 
 ;
APPLYOVR(verrors,vzsupv) ; Supervisor override array
 N vTp
 ;
 N DONE
 N ET N IDENT N REST N SEQ N SPVUID N TBL N UCLS N UCLSARR N verrsav
 ;
 S DONE=0
 ;
 S REST=""
 S SEQ=""
 F  S REST=$order(verrors(REST)) Q:(REST="")  D  Q:DONE 
 .	;
 .	F  S SEQ=$order(verrors(REST,SEQ)) Q:(SEQ="")  D  Q:DONE 
 ..		;
 ..		S SPVUID=""
 ..		S ET=$piece(verrors(REST,SEQ),"|",3)
 ..		I ($D(vzsupv("*"))#2) S SPVUID=vzsupv("*")
 ..		E  I ($D(vzsupv(ET))#2) S SPVUID=vzsupv(ET)
 ..		;
 ..		; authorization not provided
 ..		I (SPVUID="") S DONE=1 Q 
 ..		;
 ..		; setup user class array
 ..		I '($D(UCLSARR(SPVUID))#2) D
 ...			;
 ...			N scau S scau=$G(^SCAU(1,SPVUID))
 ...			;
 ...			S UCLSARR(SPVUID)=$P(scau,$C(124),5)
 ...   Q 
 ..		;
 ..		S UCLS=UCLSARR(SPVUID)
 ..		;
 ..		I '($D(^UTBL("XBAD",ET,UCLS))#2) S DONE=1 Q 
 ..		;
 ..		S TBL=$piece(verrors(REST),"|",1)
 ..		S IDENT=$piece(verrors(REST),"|",2)
 ..		;
 ..		I (TBL="CIF") D
 ...			I (IDENT="") Q  ; null values
 ...			N XSEQ S XSEQ=$O(^DAYEND(TJD,"XBADC",%UID,IDENT,""),-1)+1
 ...			N xbadc S xbadc=$$vRCgetRecord1^RecordDAYENDXBADC(TJD,%UID,IDENT,XSEQ,ET,0)
 ...		  S $P(vobj(xbadc),$C(124),1)=SPVUID
 ...		 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDAYENDXBADC(xbadc,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(xbadc,-100) S vobj(xbadc,-2)=1 TC:vTp  
 ...			K vobj(+$G(xbadc)) Q 
 ..		E  D
 ...			N CID S CID=0
 ...			N I N X N XSEQ
 ...			;
 ...			; Find account number
 ...			F I=1:1:$L(IDENT,",") S X=+$piece(IDENT,",",I) I ($D(^ACN(X,50))) S CID=X Q 
 ...			;
 ...			; Don't log unless we've got a valid account number
 ...			Q:(CID'>0) 
 ...			;
 ...			S XSEQ=$O(^DAYEND(TJD,"XBAD",%UID,CID,""),-1)+1
 ...			;
 ...			N xbad S xbad=$$vRCgetRecord1^RecordDAYENDXBAD(TJD,%UID,CID,XSEQ,ET,0)
 ...			;
 ...		  S $P(vobj(xbad),$C(124),1)=SPVUID
 ...		  S $P(vobj(xbad),$C(124),2)=IDENT
 ...		 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDAYENDXBAD(xbad,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(xbad,-100) S vobj(xbad,-2)=1 TC:vTp  
 ...			K vobj(+$G(xbad)) Q 
 ..		;
 ..		S verrsav(REST)=verrors(REST)
 ..		S verrsav(REST,SEQ)=verrors(REST,SEQ)
 ..		;
 ..		K verrors(REST,SEQ)
 ..		;
 ..		I ($D(verrors(REST))<10) K verrors(REST)
 ..		Q 
 .	Q 
 ;
 I ($D(verrors)>0) D
 .	;
 .	S REST=""
 .	S SEQ=""
 .	;
 .	F  S REST=$order(verrsav(REST)) Q:(REST="")  D
 ..		;
 ..		S verrors(REST)=verrsav(REST)
 ..		;
 ..		F  S SEQ=$order(verrsav(REST,SEQ)) Q:(SEQ="")  S verrors(REST,SEQ)=verrsav(REST,SEQ)
 ..		Q 
 .	Q 
 ;
 Q 
 ;
OVRMSG(OVR) ; Build override message
 ;
 N CNT
 N AU N BUF N FID N KEYS N MSG N SEQ N Z N ZAU
 ;
 S BUF=""
 S CNT=0
 S SEQ=""
 ;
 F  S BUF=$order(OVR(BUF)) Q:(BUF="")  D
 .	;
 .	; Table name
 .	S FID=$piece(OVR(BUF),"|",1)
 .	;
 .	; Access keys
 .	S KEYS=$piece(OVR(BUF),"|",2)
 .	;
 .	F  S SEQ=$order(OVR(BUF,SEQ)) Q:(SEQ="")  D
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
 ..		S ZAU(CNT)=$$V2LV^MSG(.AU)
 ..		;
 ..		Q 
 .	Q 
 ;
 S MSG(1)="AU"
 S MSG(2)=""
 S MSG(3)=$$V2LV^MSG($$V2LV^MSG(.ZAU))
 ;
 Q $$V2LV^MSG(.MSG)
 ;
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61475^61681^Dan Russell^14970" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vCaEx1() ; {Cache}%CACHE("SCATBL5A").isDefined("SCATBL5A","RPCID=:vzprocid,UCLS='*'")
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vRec,vop1 S vRec=$$vCa8(vzprocid,"*",.vop1)
 S vret=$G(vop1)=1 Q vret
 ; ----------------
 ;  #OPTION ResultClass 1
vdat2str(vo,mask) ; Date.toString
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I (vo="") Q ""
 I (mask="") S mask="MM/DD/YEAR"
 N cc N lday N lmon
 I mask="DL"!(mask="DS") D  ; Long or short weekday
 .	;    #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL
 .	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
 .	I (cc="") S cc="US"
 .	;    #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL
 .	S lday=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
 .	S mask="DAY" ; Day of the week
 .	Q 
 I mask="ML"!(mask="MS") D  ; Long or short month
 .	;    #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL
 .	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
 .	I (cc="") S cc="US"
 .	;    #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL
 .	S lmon=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
 .	S mask="MON" ; Month of the year
 .	Q 
 ;  #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=BYPASS
 ;*** Start of code by-passed by compiler
 set cc=$ZD(vo,mask,$G(lmon),$G(lday))
 ;*** End of code by-passed by compiler ***
 Q cc
 ; ----------------
 ;  #OPTION ResultClass 1
vCaEx2() ; {Cache}%CACHE("SCAU").isDefined("SCAU","UID = :SPVUID")
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vRec,vop1 S vRec=$$vCa10(SPVUID,.vop1)
 S vret=$G(vop1)=1 Q vret
 ;
vCa10(v1,v2out) ; voXN = ({Cache}%CACHE("SCAU").getRecord(SCAU,1)
 ;
 I '$D(%CACHE("SCAU",v1)) D
 .  I $G(%CACHE("SCAU"))>100 KILL %CACHE("SCAU")
 .  S %CACHE("SCAU")=$G(%CACHE("SCAU"))+1
 .  S %CACHE("SCAU",v1)=$$vRCgetRecord1Opt^RecordSCAU(v1,0,.v2out),%CACHE("SCAU",v1,-2)=v2out
 ;
 ;
 E  S v2out=%CACHE("SCAU",v1,-2)
 Q %CACHE("SCAU",v1)
 ;
vCa6(v1,v2out) ; voXN = ({Cache}%CACHE("SCATBL5").getRecord(SCATBL5,1)
 ;
 I '$D(%CACHE("SCATBL5",v1)) D
 .  I $G(%CACHE("SCATBL5"))>100 KILL %CACHE("SCATBL5")
 .  S %CACHE("SCATBL5")=$G(%CACHE("SCATBL5"))+1
 .  S %CACHE("SCATBL5",v1)=$$vRCgetRecord1Opt^RecordSCATBL5(v1,0,.v2out),%CACHE("SCATBL5",v1,-2)=v2out
 ;
 ;
 E  S v2out=%CACHE("SCATBL5",v1,-2)
 Q %CACHE("SCATBL5",v1)
 ;
vCa7(v1,v2,v2out) ; voXN = ({Cache}%CACHE("DBTBL25").getRecord(DBTBL25,1)
 ;
 I '$D(%CACHE("DBTBL25",v1,v2)) D
 .  I $G(%CACHE("DBTBL25"))>100 KILL %CACHE("DBTBL25")
 .  S %CACHE("DBTBL25")=$G(%CACHE("DBTBL25"))+1
 .  S %CACHE("DBTBL25",v1,v2)=$$vRCgetRecord1Opt^RecordDBTBL25(v1,v2,0,.v2out),%CACHE("DBTBL25",v1,v2,-2)=v2out
 ;
 ;
 E  S v2out=%CACHE("DBTBL25",v1,v2,-2)
 Q %CACHE("DBTBL25",v1,v2)
 ;
vCa8(v1,v2,v2out) ; voXN = ({Cache}%CACHE("SCATBL5A").getRecord(SCATBL5A,1)
 ;
 I '$D(%CACHE("SCATBL5A",v1,v2)) D
 .  I $G(%CACHE("SCATBL5A"))>100 KILL %CACHE("SCATBL5A")
 .  S %CACHE("SCATBL5A")=$G(%CACHE("SCATBL5A"))+1
 .  S %CACHE("SCATBL5A",v1,v2)=$$vRCgetRecord1Opt^RecordSCATBL5A(v1,v2,0,.v2out),%CACHE("SCATBL5A",v1,v2,-2)=v2out
 ;
 ;
 E  S v2out=%CACHE("SCATBL5A",v1,v2,-2)
 Q %CACHE("SCATBL5A",v1,v2)
 ;
vCa9(v1,v2out) ; voXN = ({Cache}%CACHE("UTBLRTNS").getRecord(UTBLRTNS,1)
 ;
 I '$D(%CACHE("UTBLRTNS",v1)) D
 .  I $G(%CACHE("UTBLRTNS"))>100 KILL %CACHE("UTBLRTNS")
 .  S %CACHE("UTBLRTNS")=$G(%CACHE("UTBLRTNS"))+1
 .  S %CACHE("UTBLRTNS",v1)=$$vRCgetRecord1Opt^RecordUTBLRTNS(v1,0,.v2out),%CACHE("UTBLRTNS",v1,-2)=v2out
 ;
 ;
 E  S v2out=%CACHE("UTBLRTNS",v1,-2)
 Q %CACHE("UTBLRTNS",v1)
 ;
vClVobj(vSt,vCls) ; Create a new object
 ;
 N vOid
 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)=vCls_$C(9)_vSt
 Q vOid
 ;
vCatch1 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 I '($P(error,",",3)["%PSL-E-IOOPEN") D close^UCIO(io)
 ;
 ; Problem opening or writing to file - fallback to this
 I '($P(error,",",3)["%PSL-E-IOEOF") D STFGBL(pkt,.reply)
 D ZX^UCGMR(voxMrk) Q 
