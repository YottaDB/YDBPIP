 ; 
 ; **** Routine compiled from DATA-QWIK Procedure PBSNSM ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
PBSNSM(vzpkt,vznsmpgm,vstart,vtprest) ; 
 ;
 ;---------------------------------------------------------------------
 ;Process message
 ;---------------------------------------------------------------------
 ;
 N reply N x
 ;
 ; Initialize system variables
 S:$get(vzsav)="" vzsav=$$INIT^PBSUTL D VLOD^PBSUTL(vzsav)
 ;
 N cuvar S cuvar=$$vRCgetRecord0Opt^RecordCUVAR(0,"")
  S cuvar=$G(^CUVAR(2))
 ;
 I TJD'=$P(cuvar,$C(124),1) D
 .	S vzsav=$$INIT^PBSUTL
 .	D VLOD^PBSUTL(vzsav)
 .	Q 
 ;
 S %STFHOST=$$%STFHOST^PBSUTL()
 ;
 ;  #ACCEPT DATE=12/17/03; PGM=John Carroll; CR=unknown
 S x="S reply=$$^"_vznsmpgm_"(vzpkt)" XECUTE x
 ;
 Q reply
 ;
 ;---------------------------------------------------------------------
DUPMSG(msgtyp,msgid) ; Public/Duplicate message?
 ;---------------------------------------------------------------------
 ;---------------------------------------------------------------------
 ;
  N V1,V2 S V1=msgtyp,V2=msgid I ($D(^NSMLOG(V1,V2))#2) Q 1
 Q 0
 ;
 ;---------------------------------------------------------------------
NSMLOG(msgtyp,msgid,clmsg,reply,status) ; Public/Log non-standard message
 N vTp
 ;---------------------------------------------------------------------
 ;---------------------------------------------------------------------
 ;
 N vztime
 ;
 I $get(msgtyp)="" Q 
 I $get(msgid)="" Q 
 I $get(clmsg)="" Q 
 I $get(reply)="" Q 
 ;
 I ($get(vzstart)="") S vzstart=$$GETTIM^%ZFUNC
 ;
 S vztime=$J((($$GETTIM^%ZFUNC-vzstart)/1000000),0,3)
 ;
 N nsmlog,vop1,vop2,vop3 S nsmlog="",vop3=0
 ;
  S vop2=msgtyp
  S vop1=msgid
 ;
  S $P(nsmlog,$C(124),1)=$J
  S $P(nsmlog,$C(124),2)=$P($H,",",1)
  S $P(nsmlog,$C(124),3)=$P($H,",",2)
  S $P(nsmlog,$C(124),4)=$get(status)
  S $P(nsmlog,$C(124),5)=TJD
  S $P(nsmlog,$C(124),8)=vztime
  S $P(nsmlog,$C(124),9)=$get(vztprest)
 ;
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^NSMLOG(vop2,vop1)=$$RTBAR^%ZFUNC(nsmlog) S vop3=1 TC:vTp  
 ;
 D log(clmsg,1)
 D log(reply,2)
 Q 
 ;
 ;---------------------------------------------------------------------
log(msg,typ) ; Private/Log messag,e in 400 byte segments, to NSMLOG
 N vTp
 ;---------------------------------------------------------------------
 ;
 N i N seq
 ;
 N rec
 ;
 F i=1:400:$L(msg) D
 .	S seq=(i\400)+1
 .	;
 .  K vobj(+$G(rec(seq))) S rec(seq)=$$vcdmNew^RecordNSMLOGD()
 .  S vobj(rec(seq),-3)=msgtyp
 .  S vobj(rec(seq),-4)=msgid
 .  S vobj(rec(seq),-5)=typ
 .  S vobj(rec(seq),-6)=seq
 .	;
 .  S $P(vobj(rec(seq)),$C(124),1)=$E(msg,i,i+399)
 .	;
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vReSav1(rec(seq)) S vobj(rec(seq),-2)=1 TC:vTp  
 .	Q 
 ;
 D vKill1("") Q 
 ;
 ;---------------------------------------------------------------------
PGMNAM(clmsg) ; Private//Non-standard message template
 ;---------------------------------------------------------------------
 ;---------------------------------------------------------------------
 ;
 N fields N reply
 ;
 S ER=$$MSGINP(.clmsg,.fields)
 ;
 S ER=$$EXEC(.fields)
 ;
 S ER=$$MSGOUT(.reply,.fields)
 Q reply
 ;
 ;---------------------------------------------------------------------
EXEC(fields) ; Private/Parse client message
 ;---------------------------------------------------------------------
 ;---------------------------------------------------------------------
 ;
 ;Insert code to process client message
 Q 0
 ;
 ;---------------------------------------------------------------------
MSGINP(clmsg,fields) ; Private/Parse client message
 ;---------------------------------------------------------------------
 ;---------------------------------------------------------------------
 ;
 ;Insert code to parse client message
 Q 0
 ;
 ;---------------------------------------------------------------------
MSGOUT(reply,fields) ; Private//Build server reply
 ;---------------------------------------------------------------------
 ;---------------------------------------------------------------------
 ;
 ;Insert code to construct server reply
 Q 0
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60876^56527^Dan Russell^5302" ; Signature - LTD^TIME^USER^SIZE
 ;
vKill1(ex1) ; Delete objects rec()
 ;
 N n1 S (n1)=""
 F  S n1=$O(rec(n1)) Q:n1=""  K:'((n1=ex1)) vobj(rec(n1))
 Q
 ;
vReSav1(vOid) ; RecordNSMLOGD saveNoFiler()
 ;
 S ^NSMLOG(vobj(vOid,-3),vobj(vOid,-4),vobj(vOid,-5),vobj(vOid,-6))=$$RTBAR^%ZFUNC($G(vobj(vOid)))
 Q
