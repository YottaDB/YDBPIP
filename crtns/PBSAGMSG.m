 ; 
 ; **** Routine compiled from DATA-QWIK Procedure PBSAGMSG ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
PBSAGMSG(agmhdr,vzrecord,vzreply) ; 
 ;
 ; I18N=OFF
 ;
 N isDone
 N agmlen N erhopt N failures N I N num N vzstatus
 N fap N reply
 ;
 S isDone=0
 S erhopt=agmhdr(5) ; Error handling option
 S agmhdr(5)=0 ; Set to non-group option
 S agmlen=50 ; Total message length (header estimate)
 ;
 F num=2:1:$order(vzrecord(""),-1) D  Q:isDone 
 .	;
 .	N vzptr N vzstart
 .	N minihdr N msg N submsg
 .	;
 .	; Transaction start time
 .	S vzstart=$$GETTIM^%ZFUNC
 .	;
 .	I (erhopt'=1)  TRO:$TL>0 
 .	I (erhopt'=1) TS (vobj):transactionid="CS"
 .	;
 .	; Parse sub-msg into mini-header and message
 .	S vzptr=$$LV2V^MSG(vzrecord(num),.submsg)
 .	;
 .	; Parse mini-header
 .	S vzptr=$$LV2V^MSG(submsg(1),.minihdr)
 .	;
 .	; Save service class for FAP usage
 .	S reply(num,0)=minihdr(1)
 .	;
 .	; Service class NMSP and AGMSG not allowed
 .	I ((minihdr(1)=0)!(minihdr(1)=7)) D
 ..		;
 ..		S reply(num,1)=1
 ..		;
 ..		; Server Error - the service class requested is not valid
 ..		S reply(num,2)=$$CSERR^PBSUTL("SV_INVLDSRV")
 ..		;
 ..		; Formatted message for logging
 ..		S reply(num,3)=$$FMTREPLY(1,reply(num,2))
 ..		Q 
 .	;
 .	E  D
 ..		;
 ..		N field N hdr N msgreply N vzagmrep
 ..		;
 ..		; Build standard messge
 ..		S hdr(1)=minihdr(1) ; Service class
 ..		S hdr(3)=minihdr(2) ; Message ID
 ..		;
 ..		; Remaining fields stay same as master header
 ..		F I=2,4:1:8 S hdr(I)=agmhdr(I)
 ..		;
 ..		S field(1)=$$V2LV^MSG(.hdr,"",0)
 ..		S field(2)=submsg(2)
 ..		S msg=$$V2LV^MSG(.field,"",0)_$C(0,0)
 ..		;
 ..		D
 ...			; Protect variables used here from abuse elsewhere
 ...			N isDone N vzlogmsg N vzlogrep
 ...			N agmlen N erhopt N num N vzstatus
 ...			N agmhdr N agmhdr N reply N vzcltokn N vzfaps
 ...			N vzmssgid N vzrecord N vzrecord
 ...			;
 ...			; Process the client message (sub-message)
 ...			S msgreply=$$PROC^PBSSRV(msg,vzsvfap,vzsvsec,.vzsav,vzmsgpgm,1,.vzagmrep)
 ...			Q 
 ..		;
 ..		I ((erhopt=1)&'$TLevel) D
 ...			;
 ...			S reply(num,1)=1
 ...			;
 ...			; Server Error - rollback error
 ...			S reply(num,2)=$$CSERR^PBSUTL("SV_ROLLBACK")
 ...			;
 ...			; If original reply is an ER, get description and append
 ...			; to the ROLLBACK description
 ...			D
 ....				;
 ....				N vzptr
 ....				N L1 N L2 N L3 N R2
 ....				;
 ....				S vzptr=$$LV2V^MSG(msgreply,.L1)
 ....				Q:'($D(L1(2))#2) 
 ....				;
 ....				S vzptr=$$LV2V^MSG(L1(2),.L2)
 ....				Q:'($D(L2(2))#2) 
 ....				;
 ....				S vzptr=$$LV2V^MSG(L2(2),.L3)
 ....				Q:($get(L3(1))'="ER") 
 ....				;
 ....				S vzptr=$$LV2V^MSG(reply(num,2),.R2)
 ....				S R2(5)=R2(5)_": "_$get(L3(5))
 ....				S R2(5)=$E(R2(5),1,254)
 ....				;
 ....				S reply(num,2)=$$V2LV^MSG(.R2,"",0)
 ....				Q 
 ...			;
 ...			; Formatted message for logging
 ...			S reply(num,3)=$$FMTREPLY(1,reply(num,2))
 ...			Q 
 ..		;
 ..		E  D  ; Get reply components
 ...			;
 ...			S reply(num,1)=$piece(vzagmrep,"|",1) ; Status
 ...			S reply(num,2)=$piece(vzagmrep,"|",2,99999) ; Reply message
 ...			S reply(num,3)=msgreply ; Formatted reply
 ...			Q 
 ..		Q 
 .	;
 .	S agmlen=agmlen+10+$ZLENGTH(reply(num,2))
 .	I (agmlen>1048575) D
 ..		;
 ..	  TRO:$TL>0 
 ..		;
 ..		S reply(num,1)=1
 ..		;
 ..		; Message exceeds length of ~p2
 ..		S reply(num,2)=$$ERRMSG^PBSUTL($$^MSG(3037,$$^MSG(3737),1048575))
 ..		;
 ..		S reply(num,3)=""
 ..		Q 
 .	;
 .	; If error and error handling option is all or nothing, roll back earlier results
 .	I (reply(num,1)'=0),(erhopt=1) D
 ..		;
 ..	  TRO:$TL>0 
 ..		;
 ..		F I=2:1:num-1 D
 ...			;
 ...			S reply(I,1)=2
 ...			S reply(I,2)=""
 ...			S reply(I,3)=""
 ...			Q 
 ..		Q 
 .	;
 .	; If error, determine if keep going or done
 .	I (reply(num,1)'=0),(erhopt'=3) S isDone=1
 .	;
 .	; Log the result
 .	;
 .	; TRollback occured in application, issue new TStart
 .	I $TLevel=0 TS (vobj):transactionid="CS"
 .	;
 .	; Log message in message log
 .	I '(reply(num,3)="") D LOG^PBSUTL($get(vzcltokn),minihdr(2),msg,reply(num,3),reply(num,1),minihdr(1),"PBSSRV",$get(vzlogmsg),$get(vzlogrep))
 .	;
 .	I ((erhopt'=1)!(reply(num,1)'=0))  TC:$TL 
 .	Q 
 ;
 ; Determine master status
 S failures=0
 ;
 ; Number of replies may be less than records if quit early
 S num=$order(reply(""),-1)
 F I=2:1:num I (reply(I,1)'=0) S failures=failures+1
 I (failures=(num-1)) S vzstatus=1 ; All failed
 E  I (failures>0) S vzstatus=3 ; Some, but not all, failed
 E  S vzstatus=0 ; All succeeded
 ;
 ; Build master reply
 S vzreply=""
 F I=2:1:num D
 .	;
 .	N fld N repmsg
 .	;
 .	S fld(1)=reply(I,1) ; Status
 .	S fld(2)=reply(I,2) ; Reply
 .	;
 .	S repmsg=$$V2LV^MSG(.fld,"",1)
 .	;
 .	; Execute service class layer exit FAP
 .	S fap=$piece(vzfaps,"~",reply(I,0))
 .	S vzreply=vzreply_$$FAPOUT^PBSSRV(repmsg,fap,7,vzstfflg)
 .	Q 
 ;
 Q vzstatus
 ;
FMTREPLY(status,reply) ; 
 ;
 N x
 ;
 S x(1)=status
 S x(2)=reply
 ;
 Q $$REPLY^PBSSRV($$V2LV^MSG(.x,"",1),status)
 ;
TEST(DIR,FILE,UID) ; User ID - needed for sign-on if no token
 ;
 N TJD
 N ER N isEOF
 N CNT
 N %SVCHNID N AGMSG N INPUT N SRVCLSES
 ;
 I (DIR="") S ER=$$TESTERR("DIR parameter is null",0) Q 
 I (FILE="") S ER=$$TESTERR("FILE parameter is null",0) Q 
 I (UID="") S ER=$$TESTERR("UID parameter is null",0) Q 
 ;
 I '($D(^SCAU(1,UID))#2) S ER=$$TESTERR("Invalid user ID",0) Q 
 ;
 N INFILE S INFILE=$$vClVobj($ST,"IO")
 ;
 S $P(vobj(INFILE,1),"|",2)=DIR
 S $P(vobj(INFILE,1),"|",1)=FILE
 S $P(vobj(INFILE,1),"|",3)="READ"
 ;
 ; Catch error on open
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ;
 D open^UCIO(INFILE,$T(+0),"TEST","INFILE")
 ;
 S (ER,isEOF)=0
 S CNT=1
 ;
 F  D  Q:(isEOF!ER) 
 .	;
 .	N X
 .	;
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch2^"_$T(+0)
 .	;
 .	S X=$$read^UCIO(INFILE) Q:isEOF 
 .	;
 .	S X=$$RTCHR^%ZFUNC(X,$char(11)) ; Remove trailing <LF>
 .	S X=$$RTCHR^%ZFUNC(X,$char(13)) ; Remove trailing <CR>
 .	S X=$$vStrTrim(X,0,$char(9)) ; Remove leading/trailing tabs
 .	S X=$$vStrTrim(X,0," ") ; Remove leading/trailing spaces
 .	;
 .	I '((X="")!($E(X,1)="<")) D
 ..		;
 ..		D close^UCIO(INFILE)
 ..		S ER=$$TESTERR("All non-blank lines must begin with '<'",0)
 ..		Q 
 .	;
 .	; Don't save blank lines or comment lines
 .	E  I '((X="")!($E(X,1,5)="<?xml")!($E(X,1,4)="<!--")) D
 ..		S INPUT(CNT)=X
 ..		S CNT=CNT+1
 ..		Q 
 .	Q 
 ;
 N cuvar S cuvar=$$vRCgetRecord0Opt^RecordCUVAR(0,"")
  S cuvar=$G(^CUVAR(2))
 ;
 S TJD=$P(cuvar,$C(124),1)
 ;
 S %SVCHNID="AGMSG" ; Needed for PBSNMSP
 ;
 I 'ER D
 .	;
 .	D TESTBLD(.INPUT,UID,.AGMSG,.SRVCLSES)
 .	;
 .	I '(AGMSG="") D TESTPROC(AGMSG,SRVCLSES)
 .	Q 
 ;
 K vobj(+$G(INFILE)) Q 
 ;
TESTBLD(INPUT,UID,AGMSG,SRVCLSES) ; Service classes for sub messages /MECH=REFNAM:W
 ;
 N ER N isDONE N stfflag
 N CNT N erhopt N MAXCNT N msgid N submsgno N svclass
 N clntvrsn N field N msgbody N msghdr N token N srvchnid N webid
 ;
 S ER=0
 S AGMSG=""
 ;
 S MAXCNT=$order(INPUT(""),-1)
 ;
 ; Work through the input and build a message
 I (INPUT(1)'="<PBSMessage>") S ER=$$TESTERR("<PBSMessage>",1) Q 
 I (INPUT(2)'="<MessageHeader>") S ER=$$TESTERR("<MessageHeader>",1) Q 
 ;
 ; Initialize header fields
 S (svclass,token,msgid,stfflag,erhopt,clntvrsn,webid,srvchnid)=""
 ;
 S isDONE=0
 F CNT=3:1:MAXCNT D  Q:isDONE 
 .	;
 .	N FIELD N VALUE
 .	;
 .	D TESTPARS(INPUT(CNT),.FIELD,.VALUE)
 .	;
 .	I (FIELD="/MessageHeader") S isDONE=1
 .	E  D
 ..		I (FIELD="ServiceClass") S svclass=VALUE
 ..		E  I (FIELD="Token") S token=VALUE
 ..		E  I (FIELD="MessageID") S msgid=VALUE
 ..		E  I (FIELD="STFFlag") S stfflag=VALUE
 ..		E  I (FIELD="ErrorHandlingOption") S erhopt=VALUE
 ..		E  I (FIELD="ClientVersion") S clntvrsn=VALUE
 ..		E  I (FIELD="WebUserID") S webid=VALUE
 ..		E  I (FIELD="ServerChannelID") S srvchnid=VALUE
 ..		Q 
 .	Q 
 ;
 I 'isDONE S ER=$$TESTERR("</MessageHeader>",1) Q 
 I (svclass="") S svclass=7
 I (svclass'=7) S ER=$$TESTERR("Only service class 7 currently supported",0) Q 
 I (msgid="") S msgid=$E($P($H,",",1),3,5)_$P($H,",",2)
 I (stfflag="") S stfflag=0
 I (erhopt="") S ER=$$TESTERR("No error handling option specified",0) Q 
 ;
 I (token="") D  Q:(token="")  ; Generate token
 .	;
 .	N ptr
 .	N fld N record N reply
 .	;
 .	S fld(1)=1 ; Sign-on
 .	S fld(2)=UID
 .	S fld(3)="AGMSG Test" ; Station ID
 .	;
 .	S record=$$V2LV^MSG(.fld,"",0)
 .	K fld
 .	;
 .	S ER=$$^PBSNMSP(.reply,0,.record,0,"/TRUST=1")
 .	;
 .	S ptr=$$LV2V^MSG(reply,.fld)
 .	;
 .	I ER D
 ..		;
 ..		N ERMSG
 ..		;
 ..		S ERMSG="Error trying to generate token - "
 ..		S ERMSG=ERMSG_$get(fld(3))_" - "_$get(fld(5))
 ..		S ER=$$TESTERR(ERMSG,0)
 ..		Q 
 .	;
 .	E  D
 ..		;
 ..		S token=$get(fld(1))
 ..		I (token="") S ER=$$TESTERR("Token generation failed",0)
 ..		Q 
 .	Q 
 ;
 ; OK ... we've got our header data, build the header
 S field(1)=svclass
 S field(2)=token
 S field(3)=msgid
 S field(4)=stfflag
 S field(5)=erhopt
 S field(6)=clntvrsn
 S field(7)=webid
 S field(8)=srvchnid
 ;
 S msghdr=$$V2LV^MSG(.field,"",1)
 ;
 ; Now build message body, add sub-records
 ;
 S CNT=CNT+1
 S msgbody=""
 S isDONE=0
 S submsgno=0
 ;
 F  D  Q:(ER!isDONE) 
 .	;
 .	N body N subhdr N submsgid
 .	;
 .	I ((CNT=MAXCNT)&(INPUT(CNT)'="</PBSMessage>")) S ER=$$TESTERR("</PBSMessage>",1) Q 
 .	;
 .	I (INPUT(CNT)'="<MessageBody>") S ER=$$TESTERR("<MessageBody>",1) Q 
 .	;
 .	S CNT=CNT+1
 .	S (submsgid,svclass)=""
 .	S submsgno=submsgno+1
 .	;
 .	; Mini-header first
 .	I (INPUT(CNT)'="<MiniHeader>") S ER=$$TESTERR("<MiniHeader>",1) Q 
 .	;
 .	F CNT=CNT+1:1:MAXCNT D  Q:(ER!isDONE) 
 ..		;
 ..		N FIELD N VALUE
 ..		;
 ..		D TESTPARS(INPUT(CNT),.FIELD,.VALUE)
 ..		;
 ..		I ((FIELD="Body")!(FIELD="MessageBody")) S ER=1
 ..		E  I (FIELD="/MiniHeader") S isDONE=1
 ..		E  D
 ...			I (FIELD="ServiceClass") S svclass=VALUE
 ...			E  I (FIELD="MessageID") S submsgid=VALUE
 ...			Q 
 ..		Q 
 .	;
 .	I 'isDONE S ER=$$TESTERR("</MiniHeader>",1) Q 
 .	;
 .	S isDONE=0
 .	;
 .	I (svclass="") S ER=$$TESTERR("Missing sub-record service class - record "_submsgno,0) Q 
 .	;
 .	I (submsgid="") S submsgid=msgid_"."_submsgno
 .	;
 .	K field
 .	S field(1)=svclass
 .	S field(2)=submsgid
 .	S subhdr=$$V2LV^MSG(.field,"",1)
 .	;
 .	; Save service class by sub-message so can de-code replies
 .	S $E(SRVCLSES,submsgno)=svclass
 .	;
 .	; Build sub-record body
 .	S CNT=CNT+1
 .	S body=$$TESTBODY(.INPUT,.CNT)
 .	;
 .	I (body="") S ER=1 Q 
 .	;
 .	K field
 .	S field(1)=subhdr_body
 .	S msgbody=msgbody_$$V2LV^MSG(.field,"",0)
 .	;
 .	S CNT=CNT+1
 .	;
 .	I (INPUT(CNT)'="</MessageBody>") S ER=$$TESTERR("</MessageBody>",1) Q 
 .	;
 .	S CNT=CNT+1
 .	;
 .	I (INPUT(CNT)="</PBSMessage>") S isDONE=1
 .	Q 
 ;
 I 'ER S AGMSG=msghdr_msgbody_$C(0,0)
 ;
 Q 
 ;
TESTBODY(INPUT,CNT) ; Input array pointer /MECH=REFNAM:RW
 N vret
 ;
 N ER N isDONE
 N SEQ
 N body N DATA N field
 ;
 S body=""
 ;
 I (INPUT(CNT)'="<Body>") S ER=$$TESTERR("<Body>",1) Q ""
 ;
 ; Get all fields into DATA and make sure they are correctly ordered
 S SEQ=1
 S (ER,isDONE)=0
 F CNT=CNT+1:1:$order(INPUT(""),-1) D  Q:(ER!isDONE) 
 .	;
 .	N FIELD N VALUE
 .	;
 .	D TESTPARS(INPUT(CNT),.FIELD,.VALUE)
 .	;
 .	I ($E(FIELD,1,6)="/Field") Q  ; Ignore complex field end markers
 .	;
 .	I (FIELD="MessageBody") S ER=1
 .	E  I (FIELD="/Body") S isDONE=1
 .	E  D
 ..		;
 ..		N LASTNUM N NUMPCES
 ..		N fieldid N PRIORIS N PRIORSB
 ..		;
 ..		I '(FIELD["Field_") S ER=$$TESTERR("Bad/missing '<Field_' field",0) Q 
 ..		;
 ..		S fieldid=$piece(FIELD,"_",2)
 ..		;
 ..		; Make sure in correct order
 ..		I (((SEQ=1)&(fieldid'=1))!((fieldid=1)&(SEQ'=1))) S ER=$$TESTERR("Sequence 1 must be first",0) Q 
 ..		;
 ..		I (fieldid'=1) D  Q:ER 
 ...			;
 ...			S NUMPCES=$L(fieldid,".")
 ...			S LASTNUM=$piece(fieldid,".",NUMPCES)
 ...			S PRIORIS=$piece(DATA(SEQ-1),"|",1)
 ...			;
 ...			; Determine what prior should be
 ...			I (LASTNUM=1) S PRIORSB=$piece(fieldid,".",1,NUMPCES-1)
 ...			E  I (NUMPCES=1) D
 ....				S PRIORSB=LASTNUM-1
 ....				S PRIORIS=$piece(PRIORIS,".",1)
 ....				Q 
 ...			E  D
 ....				S PRIORSB=$piece(fieldid,".",1,NUMPCES-1)_"."_(LASTNUM-1)
 ....				S PRIORIS=$piece(PRIORIS,".",1,NUMPCES)
 ....				Q 
 ...			;
 ...			I (PRIORIS'=PRIORSB) S ER=$$TESTERR("Field "_PRIORSB_" does not preceed field "_fieldid,0)
 ...			Q 
 ..		;
 ..		S DATA(SEQ)=fieldid_"|"_VALUE
 ..		S SEQ=SEQ+1
 ..		Q 
 .	Q 
 ;
 I ER Q ""
 ;
 I 'isDONE S ER=$$TESTERR("</Body>",1) Q ""
 ;
 ; Have it all in DATA(), build it into an LV record
 ;
 S SEQ=1
 F  S body=body_$$TESTADD(.DATA,.SEQ) Q:(SEQ="") 
 ;
 S field(1)=body
 ;
 S vret=$$V2LV^MSG(.field,"",0) Q vret
 ;
TESTADD(DATA,SEQ) ; Working sequence /MECH=REFNAM:RW
 ;
 N field N FIELD N NXTFIELD N return N VALUE
 ;
 S return=""
 ;
 S FIELD=$piece(DATA(SEQ),"|",1)
 S VALUE=$piece(DATA(SEQ),"|",2,999999)
 ;
 S SEQ=SEQ+1
 I '($D(DATA(SEQ))#2) D  ; On last field
 .	S SEQ=""
 .	S NXTFIELD=""
 .	Q 
 E  S NXTFIELD=$piece(DATA(SEQ),"|",1)
 ;
 ; Not a complex field, i.e., sub-fields don't follow
 I ((SEQ="")!($L(FIELD,".")'<$L(NXTFIELD,"."))) S return=VALUE
 ;
 ; Complex, so build sub-fields
 E  D
 .	N isDONE S isDONE=0
 .	N SUBFLDLN
 .	;
 .	; Sub-field size, so know when done
 .	S SUBFLDLN=$L($piece(DATA(SEQ),"|",1),".")
 .	;
 .	F  D  Q:isDONE 
 ..		S return=return_$$TESTADD(.DATA,.SEQ)
 ..		I (SEQ="") S isDONE=1
 ..		E  I (SUBFLDLN'=$L($piece(DATA(SEQ),"|",1),".")) S isDONE=1
 ..		Q 
 .	Q 
 ;
 S field(1)=return
 ;
 Q $$V2LV^MSG(.field,"",0)
 ;
TESTPROC(AGMSG,SRVCLSES) ; Service classes for sub messages
 ;
 N ER N vzlogmsg N vzlogrep N vzsvsec
 N vzmaxtim
 N vzmsgpgm N vzreply N vzsav N vzsvfap N vzsvtyp N vzx
 ;
 S vzsvtyp="SCA$IBS"
 ;
 N svtyp,vop1 S svtyp=$$vRCgetRecord1Opt^RecordCTBLSVTYP(vzsvtyp,0,.vop1)
 I ($G(vop1)=0) S ER=$$TESTERR("SCA$IBS not set up as server type",0) Q 
 ;
 S vzsvfap=$P(svtyp,$C(124),2) ; Server FAP ID
 S vzsvsec=$P(svtyp,$C(124),3) ; Security level
 S vzlogmsg=$P(svtyp,$C(124),6) ; Log client messages
 S vzlogrep=$P(svtyp,$C(124),7) ; Log server replies
 S vzmaxtim=$P(svtyp,$C(124),8) ; Transaction TP timeout
 ;
 I 'vzmaxtim S vzmaxtim=45 ; (default is 45 seconds)
 ;
 S vzx="s $zmaxtptime="_vzmaxtim
 ;
 ;  #ACCEPT PGM=Dan Russell; DATE=02/23/05; CR=14553
 XECUTE vzx
 ;
 S vzmsgpgm=$P(svtyp,$C(124),12) ; Non-std message handler
 ;
 S vzsav=$$INIT^PBSUTL
 ;
 ; Process the message
 ;
 TS (vobj):transactionid="CS"
 ;
 ; If transaction is restarted, clean-up symbol table
 I $TRestart D
 .	;
 .	D XKILL^PBSUTL
 .	I ($get(vzsav)="") S vzsav=$$INIT^PBSUTL
 .	D VLOD^PBSUTL(vzsav)
 .	Q 
 ;
 S vzreply=$$PROC^PBSSRV(AGMSG,vzsvfap,vzsvsec,.vzsav,vzmsgpgm,0)
 ;
  TC:$TL 
 ;
 ; Parse and output reply message
 D TESTREPL(vzreply,SRVCLSES)
 ;
 Q 
 ;
TESTREPL(reply,SRVCLSES) ; Service classes for sub messages
 ;
 N ptr N recnum
 N header N records N TAB
 ;
 S TAB=$char(9)
 ;
 S ptr=$$LV2V^MSG(reply,.records)
 S ptr=$$LV2V^MSG(records(1),.header)
 ;
 WRITE !,"<?xml version=""1.0"" encoding=""UTF-8""?>",!
 WRITE "<!-- Reply from PBS Server test message -->",!
 WRITE "<PBSReply>",!
 ;
 WRITE "<ReplyHeader>",!
 WRITE TAB,"<Token>",$get(header(1)),"</Token>",!
 WRITE TAB,"<MessageID>",$get(header(2)),"</MessageID>",!
 WRITE TAB,"<MessageStatus>",$get(header(3)),"<MessageStatus>",!
 WRITE TAB,"<VersionID>",$get(header(4)),"<VersionID>",!
 WRITE "</ReplyHeader>",!
 ;
 F recnum=2:1:$order(records(""),-1) D
 .	;
 .	N I N N
 .	N fields N LAST N NEXT N subrecs
 .	;
 .	S ptr=$$LV2V^MSG(records(recnum),.subrecs)
 .	;
 .	D TESTREPF(.subrecs,.fields,$E(SRVCLSES,recnum-1))
 .	;
 .	WRITE "<ReplyBody>",!
 .	WRITE TAB,"<Status>",subrecs(1),"</Status>",!
 .	WRITE TAB,"<Reply>",!
 .	;
 .	S (LAST,N)=""
 .	F  S N=$order(fields(N)) Q:(N="")  D
 ..		;
 ..		N noCLOSE S noCLOSE=0
 ..		;
 ..		; Open nested XML section
 ..		S NEXT=$order(fields(N))
 ..		I ($L(NEXT,".")>$L(N,".")) S noCLOSE=1
 ..		;
 ..		; Close nested XML
 ..		I ($L(N,".")<$L(LAST,".")) D
 ...			;
 ...			N X
 ...			;
 ...			S X=$piece(LAST,".",1,$L(LAST,".")-1)
 ...			;
 ...			WRITE TAB
 ...			F I=1:1:$L(X,".") WRITE TAB
 ...			;
 ...			WRITE "</Field",X,">",!
 ...			Q 
 ..		;
 ..		WRITE TAB
 ..		F I=1:1:$L(N,".") WRITE TAB
 ..		;
 ..		WRITE "<Field",N,">",$$TESTCHR(fields(N))
 ..		I 'noCLOSE WRITE "</Field",N,">"
 ..		WRITE !
 ..		;
 ..		S LAST=N
 ..		;
 ..		; Close last field(s)
 ..		I (NEXT="") D
 ...			;
 ...			N J
 ...			N X
 ...			;
 ...			I 'noCLOSE S LAST=$piece(LAST,".",$L(LAST,".")-1)
 ...			;
 ...			I '(LAST="") F I=$L(LAST,"."):-1:1 D
 ....				;
 ....				S X=$piece(LAST,".",1,I)
 ....				;
 ....				WRITE TAB
 ....				F J=1:1:$L(X,".") WRITE TAB
 ....				;
 ....				WRITE "</Field",X,">",!
 ....				Q 
 ...			Q 
 ..		Q 
 .	;
 .	WRITE TAB,"</Reply>",!
 .	WRITE "</ReplyBody>",!
 .	Q 
 ;
 WRITE "</PBSReply>",!
 ;
 Q 
 ;
TESTREPF(subrecs,fields,SRVCLASS) ; Service class for this message
 ;
 N N N ptr
 N lvlone
 ;
 ; Break down level one body fields
 I '($get(subrecs(2))="") S ptr=$$LV2V^MSG(subrecs(2),.lvlone)
 E  S lvlone(1)=""
 ;
 ; Success formats depend on service class
 I (subrecs(1)=0) D  ; Success
 .	;
 .	I (SRVCLASS=0) D
 ..		;
 ..		F N=1:1:$order(lvlone(""),-1) S fields("_"_N)=lvlone(N)
 ..		Q 
 .	;
 .	; TSSP top record contains one sub-record per transaction
 .	E  I (SRVCLASS=1) D
 ..		;
 ..		F N=1:1:$order(lvlone(""),-1) D
 ...			;
 ...			N J
 ...			N values
 ...			;
 ...			S fields("_"_N)=""
 ...			;
 ...			S ptr=$$LV2V^MSG(lvlone(N),.values)
 ...			;
 ...			F J=1:1:$order(values(""),-1) I (J'=2) S fields("_"_N_"."_J)=values(J)
 ...			;
 ...			; Break TAMT - complex field
 ...			S fields("_"_N_".2")=""
 ...			I '(values(2)="") D
 ....				;
 ....				N K
 ....				N tamt
 ....				;
 ....				S ptr=$$LV2V^MSG(values(2),.tamt)
 ....				F K=1:1:$order(tamt(""),-1) S fields("_"_N_".2."_K)=tamt(K)
 ....				Q 
 ...			Q 
 ..		Q 
 .	;
 .	; FSSP - One Record at top, then complex single level
 .	E  I (SRVCLASS=2) D
 ..		;
 ..		N lvltwo
 ..		;
 ..		S fields("_1")=""
 ..		;
 ..		S ptr=$$LV2V^MSG(lvlone(1),.lvltwo)
 ..		;
 ..		F N=1:1:$order(lvltwo(""),-1) S fields("_1."_N)=lvltwo(N)
 ..		Q 
 .	;
 .	E  I ((SRVCLASS=3)!(SRVCLASS=6)) S fields("_1")=subrecs(2)
 .	;
 .	; PSQL - Flat, with one complex field
 .	E  I (SRVCLASS=5) D
 ..		;
 ..		F N=1:1:$order(lvlone(""),-1) I (N'=5) S fields("_"_N)=lvlone(N)
 ..		;
 ..		; Break colattrib - complex field
 ..		I '(lvlone(5)="") D
 ...			;
 ...			N colatt
 ...			;
 ...			S fields("_5")=""
 ...			;
 ...			S ptr=$$LV2V^MSG(lvlone(5),.colatt)
 ...			F N=1:1:$order(colatt(""),-1) S fields("_5."_N)=colatt(N)
 ...			Q 
 ..		Q 
 .	;
 .	E  S fields("_1")="TEST^PBSAGMSG message - unknown service class reply format"
 .	Q 
 ;
 E  I (subrecs(1)=1) D  ; Failure
 .	;
 .	I lvlone(1)="ER" D  ; Basic error
 ..		;
 ..		F N=1:1:$order(lvlone(""),-1) I (N'=4) S fields("_"_N)=lvlone(N)
 ..		;
 ..		; Break parameters - complex field
 ..		S fields("_4")=""
 ..		I '(lvlone(4)="") D
 ...			;
 ...			N params
 ...			;
 ...			S ptr=$$LV2V^MSG(lvlone(4),.params)
 ...			F N=1:1:$order(params(""),-1) S fields("_4."_N)=params(N)
 ...			Q 
 ..		Q 
 .	;
 .	E  I lvlone(1)="AU" D  ; Authorization restriction
 ..		;
 ..		N aurecs
 ..		;
 ..		S fields("_1")="AU"
 ..		S fields("_2")=lvlone(2)
 ..		;
 ..		; Break down AUINFO field - one record per transaction
 ..		S ptr=$$LV2V^MSG(lvlone(3),.aurecs)
 ..		;
 ..		; Handle each transaction's restriction sub-records
 ..		F N=1:1:$order(aurecs(""),-1) D
 ...			;
 ...			N J N K
 ...			N rest
 ...			;
 ...			S fields("_3."_N)=""
 ...			;
 ...			S ptr=$$LV2V^MSG(aurecs(N),.rest)
 ...			;
 ...			; Break down the individual fields
 ...			F J=1:1:$order(rest(""),-1) D
 ....				;
 ....				N values
 ....				;
 ....				S fields("_3."_N_"."_J)=""
 ....				;
 ....				S ptr=$$LV2V^MSG(rest(J),.values)
 ....				;
 ....				F K=1:1:$order(values(""),-1) S fields("_3."_N_"."_J_"."_K)=values(K)
 ....				Q 
 ...			Q 
 ..		Q 
 .	;
 .	E  S fields("_1")="TEST^PBSAGMSG message - unknown error reply format"
 .	Q 
 ;
 E  D  ; Rollback
 .	;
 .	; Will only have single field, should be null
 .	S fields("_1")=lvlone(1)
 .	Q 
 ;
 Q 
 ;
TESTCHR(X) ; Input string
 ;
 N return S return=""
 ;
 I X'?.E1C.E S return=X
 E  D
 .	;
 .	N isCTRL S isCTRL=0
 .	N I
 .	N CHR
 .	;
 .	F I=1:1:$L(X) D
 ..		;
 ..		S CHR=$E(X,I)
 ..		I CHR?1C D
 ...			I 'isCTRL D
 ....				I '(return="") S return=return_"""_"
 ....				S return=return_"$C("_$ascii(CHR)
 ....				S isCTRL=1
 ....				Q 
 ...			E  S return=return_","_$ascii(CHR)
 ...			Q 
 ..		E  D
 ...			I isCTRL D
 ....				S return=return_")_"""_CHR
 ....				S isCTRL=0
 ....				Q 
 ...			E  D
 ....				I (return="") S return=""""
 ....				S return=return_CHR
 ....				Q 
 ...			Q 
 ..		Q 
 .	;
 .	I isCTRL S return=return_")"
 .	E  S return=return_""""
 .	Q 
 ;
 Q return
 ;
TESTPARS(INPUT,FIELD,VALUE) ; Field value  /MECH=REFNAM:W
 ;
 S FIELD=$piece($piece(INPUT,"<",2),">",1)
 ;
 I ($E(FIELD,1)="/") S VALUE="" ; </abc>
 E  I ($E(FIELD,$L(FIELD))="/") S VALUE="" ; <abc/> syntax
 E  S VALUE=$piece($piece(INPUT,"<"_FIELD_">",2),"</"_FIELD_">",1)
 ;
 Q 
 ;
TESTERR(MSG,isMISING) ; Use missing record message
 ;
 I isMISING WRITE "Missing ",MSG," record",!!
 E  WRITE MSG,!!
 ;
 Q 1
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60461^55036^Dan Russell^27663" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vStrTrim(object,p1,p2) ; String.trim
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I p1'<0 S object=$$RTCHR^%ZFUNC(object,p2)
 I p1'>0 F  Q:$E(object,1)'=p2  S object=$E(object,2,1048575)
 Q object
 ;
vClVobj(vSt,vCls) ; Create a new object
 ;
 N vOid
 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)=vCls_$C(9)_vSt
 Q vOid
 ;
vCatch2 ; Error trap
 ;
 N readerr,$ET,$ES S readerr=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 D close^UCIO(INFILE)
 ;
 I ($P(readerr,",",3)["IOEOF") S isEOF=1
 E  S $ZE=readerr,$EC=",U1001,"
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch1 ; Error trap
 ;
 N openerr,$ET,$ES S openerr=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 I ($P(openerr,",",3)["IOOPEN") WRITE "Open failed",!
 E  D
 .		;
 .		WRITE "Error:  "
 .		WRITE $P(openerr,",",2)," - "
 .		WRITE $P(openerr,",",3)," - "
 .		WRITE $P(openerr,",",4),!
 .		Q 
 D ZX^UCGMR(voxMrk) Q 
