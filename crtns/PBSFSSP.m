 ; 
 ; **** Routine compiled from DATA-QWIK Procedure PBSFSSP ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
PBSFSSP(reply,stfflg,record,rectyp,contxt) ; FSSP Service Class Driver
 ;
 N field,FN,i,INPUT,MSGS,ptr,sub
 ;
 I $get(%STFHOST) D  Q ER
 .	; Access not allowed for service class ~p1 at this time
 .	S ER=1 S RM=$$^MSG(3246,2)
 .	S reply=$$ERRMSG^PBSUTL($get(RM),$get(ET))
 .	Q 
 ;
 S ptr=$$LV2V^MSG(record,.field)
 S FN=$get(field(1))
 I FN="" S reply=$$CSERR^PBSUTL("SV_INVLDSFC") Q 1
 ;
 S ptr=$$LV2V^MSG($get(field(2)),.sub)
 S INPUT=""
 F i=1:1 Q:'$D(sub(i))  S $piece(INPUT,"|",i)=sub(i)
 ;
 ;I18N=OFF
 I rectyp D
 .	;
 .	; Foreign client
 .	S %IPMODE="NOINT:ORDER INPUT/NULL=127"
 .	;
 .	; NULL = new change
 .	S %OPMODE="DEVICE FC"
 .	Q 
 ;
 E  D
 .	S %IPMODE="NOINT:NOVAL:ORDER INPUT"
 .	S %OPMODE="NOOUT"
 .	S %NOLOCK=1
 .	Q 
 ;
 ;I18N=ON
 ;
 D
 .	N record,stfflg
 .	D EXEC
 .	Q 
 ;
 I $get(ER) D  Q ER
 .	S reply=$$ERRMSG^PBSUTL($get(RM),$get(ET))
 .	I stfflg D STF(record,.reply)
 .	;
 .	Q 
 ;
 I $get(MSGS)'="" D
 .	K field
 .	F i=1:1:$L(MSGS,"|") S field(i)=$piece(MSGS,"|",i)
 .	S reply=$$V2LV^MSG(.field)
 .	;
 .	Q 
 E  S reply=$$V2LV^MSG($get(RM))
 Q 0
 ;
EXEC ; Execute function
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ;
 ; Execute standard function call
 D EXT^SCADRV0(%UID,FN) L 
 ;
 Q 
 ;
STF(pkt,reply) ; Private; Log original message and reply in exception file
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch2^"_$T(+0)
 ;
 N CONT,fn,JD,x,X
 ;
 S JD=$P($H,",",1)
 S X=$$DAY^SCADAT(JD,1)_$$MON^SCADAT(JD,1)_$$YEAR^SCADAT(JD,1)
 S fn=$$SCAU^%TRNLNM("SPOOL","STF_"_X_".FSSP")
 ;
 N io S io=$$vClVobj($ST,"IO")
 S $P(vobj(io,1),"|",1)=fn
 S $P(vobj(io,1),"|",3)="WRITE/APPEND/SHARED"
 S $P(vobj(io,1),"|",4)=2
 S $P(vobj(io,1),"|",5)=16384
 D open^UCIO(io,$T(+0),"STF","io")
 ;
 ; I18N=OFF
 ;
 ; Log original client message to RMS
 S REC=$C(13,10)_pkt
 D write^UCIO(io,REC)
 ;
 S REC=$C(13,10)_reply_$C(13,10)
 D write^UCIO(io,REC)
 ;
 D close^UCIO(io)
 ;
 ; I18N=OFF
 ;
 S ER=0 S reply=""
 ;
 K vobj(+$G(io)) Q 
 ;
STFGBL(pkt,reply) ; File record to global
 N vTp
 ;
 N I,SEQ,STFMSG,SQ,UID
 ;
 S SQ=0
 S UID=%UID
 L +STF(UID)
 ;
 S SQ=$O(^STF(UID,""),-1)+1
 ;
 N stf1,vop1,vop2,vop3 S stf1="",vop3=0
  S vop2=UID
  S vop1=SQ
  S $P(stf1,$C(124),6)=TLO
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^STF(vop2,vop1)=$$RTBAR^%ZFUNC(stf1) S vop3=1 TC:vTp  
 L -STF(UID)
 ;
 S SEQ=0
 F I=1:400:$L(pkt) D
 .	S SEQ=SEQ+1
 .	S STFMSG=$E(pkt,I,I+399)
 .	N stf,vop4,vop5,vop6,vop7 S stf="",vop7=0
 .  S vop6=UID
 .  S vop5=SQ
 .  S vop4=SEQ
 .  S $P(stf,$C(124),1)=STFMSG
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^STF(vop6,vop5,vop4)=$$RTBAR^%ZFUNC(stf) S vop7=1 TC:vTp  
 . Q 
 ;
 F I=1:400:$L(reply) D
 .	S SEQ=SEQ+1
 .	S STFMSG=$E(reply,I,I+399)
 .	N stf,vop8,vop9,vop10,vop11 S stf="",vop11=0
 .  S vop10=UID
 .  S vop9=SQ
 .  S vop8=SEQ
 .  S $P(stf,$C(124),1)=STFMSG
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^STF(vop10,vop9,vop8)=$$RTBAR^%ZFUNC(stf) S vop11=1 TC:vTp  
 . Q 
 ;
 S ER=0 S reply=""
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "59886^43595^Sanchez SCM Administrator^3991" ; Signature - LTD^TIME^USER^SIZE
 ;
vClVobj(vSt,vCls) ; Create a new object
 ;
 N vOid
 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)=vCls_$C(9)_vSt
 Q vOid
 ;
vCatch2 ; Error trap
 ;
 N vERROR,$ET,$ES S vERROR=$ZE,$EC="",$ET="Q",$ZE=""
 N ET,RM
 S ET=$P(vERROR,",",3)
 ;
 I ET["%GTM-" D  D ZX^UCGMR(voxMrk) Q 
 .		D ZE^UTLERR
 .		D STFGBL(pkt,.reply)
 .		Q 
 S ET=ET_"-"_$P(vERROR,",",2)
 S RM=$P(vERROR,",",4)
 D ^UTLERR
 D STFGBL(pkt,.reply)
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch1 ; Error trap
 ;
 N vERROR,$ET,$ES S vERROR=$ZE,$EC="",$ET="Q",$ZE=""
 N ET,RM
 S ET=$P(vERROR,",",3)
 ;
 I ET["%GTM-" D ZE^UTLERR D ZX^UCGMR(voxMrk) Q 
 ;
 S ET=ET_"-"_$P(vERROR,",",2)
 S RM=$P(vERROR,",",4)
 D ^UTLERR
 D ZX^UCGMR(voxMrk) Q 
