 ; 
 ; **** Routine compiled from DATA-QWIK Procedure PBSTST ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
PBSTST ; Private;Test PROFILE Server
 ;
 N quit
 N et N IO
 ;
 D ^SCAIO
 D OPEN^SCAIO Q:ER 
 ;
 WRITE $$SCR132^%TRMVT
 D signon
 ;
 USE 0:wid=132
 S quit=0
 ;
 F  D  Q:quit 
 .	;
 .	N i
 .	N %JRNL N reply N svcls N x N vzmsg
 .	;
 .	USE IO R x
 .	S quit=$ZEOF USE 0 Q:quit 
 .	;
 .	S svcls=$E(x,1)
 .	S vzmsg=$$cntrl($E(x,2,1048575))
 .	WRITE !!,"svclass: ",svcls,!,"message: ",vzmsg
 .	;
 .	I svcls=2 D
 ..		S %JRNL(1)=$piece(vzmsg,$char(28),2)
 ..		S reply=$$FSSP^PBSCLI($piece(vzmsg,$char(28),1))
 ..		Q 
 .	;
 .	I svcls=3 D
 ..		F i=1:1:6 S x(i)=$piece(vzmsg,$char(28),i)
 ..		S reply=$$MRPC^PBSCLI(x(1),x(2),x(3),x(4),x(5),x(6))
 ..		Q 
 .	;
 .	F  S x=$F(reply,$char(28)) Q:'x  D
 ..		S reply=$E(reply,1,x-2)_"<fs>"_$E(reply,x,1048575)
 ..		;
 ..		Q 
 .	;
 .	WRITE !,"  reply: ",reply
 .	WRITE !,"   quit: ",x R x
 .	I x="Y" S quit=1
 .	Q 
 ;
 S et=$$CLDSCNCT^%MTAPI(%CSID) I et'="" WRITE !,et
 ;
 WRITE $$SCR80^%TRMVT
 ;
 CLOSE IO
 ;
 Q 
 ;
cntrl(vzmsg) ; 
 ;
 N l
 N x
 ;
 S l=$L(vzmsg)
 ;
 F  S x=$F(vzmsg,"<fs>") Q:'x  D
 .	S vzmsg=$E(vzmsg,1,x-5)_$char(28)_$E(vzmsg,x,1)
 .	Q 
 ;
 F  S x=$F(vzmsg,"<gs>") Q:'x  D
 .	S vzmsg=$E(vzmsg,1,x-5)_$char(29)_$E(vzmsg,x,l)
 .	Q 
 ;
 F  S x=$F(vzmsg,"<rs>") Q:'x  D
 .	S vzmsg=$E(vzmsg,1,x-5)_$char(30)_$E(vzmsg,x,l)
 .	Q 
 ;
 F  S x=$F(vzmsg,"<us>") Q:'x  D
 .	S vzmsg=$E(vzmsg,1,x-5)_$char(31)_$E(vzmsg,x,l)
 .	Q 
 ;
 Q vzmsg
 ;
svr ; Start server in direct mode
 ;
 N debug N X
 ;
 ;  #ACCEPT Date=03/08/06; Pgm=RussellDS; CR=19962
 ;*** Start of code by-passed by compiler
 kill
 ;*** End of code by-passed by compiler ***
 ;
 ; get address of line after call to $$PROC in LOOP section
 S debug=$$nxtline("LOOP^PBSSRV","$$PROC(")
 ;
 I debug="" WRITE !,"Cannot Locate call to PROC^PBSSRV, ABORTING." Q 
 ;
 S debug="zb "_debug_":""u 0 w !! zwr vzpkt,vzreply zc"""
 ;
 N rs,vos1,vos2,vos3 S rs=$$vOpen1()
 I $$vFetch1() S X=rs+1
 E  S X=1
 ;
 D SVCNCT^PBSSRV("SCA$IBS",X,debug)
 ;
 Q 
 ;
cmd ; Issue command to server
 ;
 N %FRAME N SVID
 N %NOPRMT N %READ N CMD N SVTYP N %TAB N VFMQ
 ;
 S %TAB("SVTYP")="/DES=SVTYP/TYP=T/LEN=12/TBL=[CTBLSVTYP]"
 S %TAB("SVID")="/DES=SVID/TYP=N/LEN=2" S SVID=1
 S %TAB("CMD")="/DES=CMD/TYP=T/LEN=40"
 S %READ="SVTYP/REQ,SVID/REQ,CMD/REQ"
 S SVTYP="SCA$IBS"
 ;
 S %FRAME=1
 S %NOPRMT="F"
 D ^UTLREAD
 I VFMQ="Q" Q 
 ;
 D EXEC^PBSUTL(SVTYP,SVID,CMD)
 ;
 Q 
 ;
signon ; Client sign-on
 ;
 ; Terminal Parameters
 D TERMSET^SCADRV
 ;
 ; Define Driver Context
 D UID
 I ($get(%UID)="") Q 
 ;
 ; Client connect API
 D CLCNCT^SCADRV
 ;
 Q 
 ;
UID ; Prompt for User ID in direct mode
 ;
 N %FRAME
 N % N %NOPRMT N %READ N %TAB N drvlist N HDR N KVAR
 N PGM N PWD N UTLO N VFMQ
 ;
 S ER=0
 ;
 S drvlist="%InputTimeOut|300,CONAM,%ET"
 ;
 D LIST^CUVAR("%InputTimeOut|300,CONAM,%ET")
 D INIT^%ZM(.drvlist)
 ;
 S %LOGID=$$LOGID^SCADRV
 D ^UTLO
 S TLO=UTLO
 ;
 N ddpsts S ddpsts=$$vRCgetRecord0Opt^RecordDDPSTS(0,"")
  S ddpsts=$G(^%ZDDP("%NET"))
 S %NET=$P(ddpsts,$C(124),1)
 I %NET="" S %NET=1
 S %="|"
 ;
 S %TAB("%UID")=".UID1"
 S %TAB("PWD")=".PWD1"
 S %READ="%UID/REQ,PWD/SEC"
 ;
 S %FRAME=1
 S %NOPRMT="F"
 D ^UTLREAD
 I VFMQ="Q" S ER=1 Q 
 ;
 ; Invalid password
 I '$$VALIDATE^SCADRV1(PWD,%UID) S ER=1 S RM=$$^MSG(1419) Q 
 ;
 N scau S scau=$$vRCgetRecord0Opt^RecordSCAU(%UID,0,"")
 S %UCLS=$P(scau,$C(124),5)
 ;
 Q 
 ;
nmsp ; Private;Test Public MRPCs
 ;
  S ER=0
 ;
 N VFMQ
 ;
 D signon
 I ER Q 
 ;
 F  D  I VFMQ="Q" Q 
 .	;
 .	N %FRAME
 .	N %NOPRMT N %READ N %TAB N FUNC N PAR N PARAM N PTR N RETURN N RPCID N VERSN
 .	;
 .	S %TAB("FUNC")="/DES=FUNNAM/TYP=T/LEN=20"
 .	S %TAB("PARAM")="/DES=PARAM/TYP=T/LEN=40"
 .	S %READ="FUNC/REQ,PARAM"
 .	;
 .	S %FRAME=1
 .	S %NOPRMT="F"
 .	D ^UTLREAD
 .	I VFMQ="Q" Q 
 .	;
 .	S PTR=$$COLUMN^MSG(PARAM,44,.PAR)
 .	S ER=$$NMSP^PBSCLI(3,.RETURN,FUNC,.PAR)
 .	;
 .	ZWRITE ER,RETURN
 .	WRITE $$MSG^%TRMVT("",0,1)
 .	Q 
 ;
 D CLDSCNCT^SCADRV
 ;
 Q 
 ;
fssp ; Private;Test FSSP service class
 ;
  S ER=0
 ;
 N VFMQ
 ;
 D signon
 I ER Q 
 ;
 F  D  I VFMQ="Q" Q 
 .	;
 .	N %FRAME
 .	N %NOPRMT N %READ N %TAB N FUNCT N PAR N PARAM N PTR N RETURN
 .	;
 .	S %TAB("FUNCT")=".FN2"
 .	S %TAB("PARAM")="/DES=PARAM/TYP=T/LEN=40"
 .	S %READ="FUNCT/REQ,PARAM/REQ"
 .	;
 .	S %FRAME=1
 .	S %NOPRMT="F"
 .	D ^UTLREAD
 .	I VFMQ="Q" Q 
 .	;
 .	S RETURN=""
 .	S PTR=$$COLUMN^MSG(PARAM,44,.PAR)
 .	S ER=$$FSSP^PBSCLI(FUNCT,.PAR,.RETURN)
 .	;
 .	ZWRITE ER,RETURN
 .	WRITE $$MSG^%TRMVT("",0,1)
 .	Q 
 ;
 D CLDSCNCT^SCADRV
 ;
 Q 
 ;
mrpc ; Private;Test Public MRPCs
 ;
  S ER=0
 ;
 N VFMQ
 ;
 D signon
 I ER Q 
 ;
 F  D  I VFMQ="Q" Q 
 .	;
 .	N %FRAME N VERSN
 .	N %NOPRMT N %READ N %TAB N PAR N PARAM N PTR N RETURN N RPCID N VFMQ
 .	;
 .	S %TAB("RPCID")="/DES=RPCID/TYP=T/LEN=20"
 .	S %TAB("VERSN")="/DES=VERSN/TYP=N/LEN=6"
 .	S %TAB("PARAM")="/DES=PARAM/TYP=T/LEN=40"
 .	S %READ="RPCID/REQ,VERSN/REQ,PARAM/REQ"
 .	;
 .	S %FRAME=1
 .	S %NOPRMT="F"
 .	D ^UTLREAD
 .	I VFMQ="Q" Q 
 .	;
 .	S PTR=$$COLUMN^MSG(PARAM,44,.PAR)
 .	S RETURN=$$MRPC^PBSCLI(RPCID,VERSN,.PAR)
 .	;
 .	ZWRITE ER,RETURN,RM
 .	WRITE $$MSG^%TRMVT("",0,1)
 .	Q 
 ;
 D CLDSCNCT^SCADRV
 ;
 Q 
 ;
csis(signont) ; Private;Test CSIS service class
 ;
  S ER=0
 ;
 N token N VFMQ
 ;
 D signon
 I ER Q 
 ;
 S token=$piece(%LOGID,"|",6)
 ; type RecordSIGNONT signont=Db.getRecord("SIGNONT","UID='*',TOKEN=:token")
 ; set signont.="/HTML"
 ;
 F  D  I VFMQ="Q" Q 
 .	;
 .	N %FRAME
 .	N %NOPRMT N %READ N %TAB N FUNCT N PAR N PARAM N PTR N RETURN
 .	;
 .	S %TAB("FUNCT")=".FN2"
 .	S %TAB("PARAM")="/DES=PARAM/TYP=T/LEN=40"
 .	S %READ="FUNCT/REQ,PARAM/REQ"
 .	;
 .	S %FRAME=1
 .	S %NOPRMT="F"
 .	D ^UTLREAD
 .	I VFMQ="Q" Q 
 .	;
 .	S RETURN=""
 .	S PTR=$$COLUMN^MSG(PARAM,44,.PAR)
 .	;
 .	ZWRITE ER,RETURN
 .	WRITE $$MSG^%TRMVT("",0,1)
 .	Q 
 ;
 D CLDSCNCT^SCADRV
 ;
 Q 
 ;
msql ; Private;Test MSQL service class
 ;
  S ER=0
 ;
 N MSG N VFMQ
 ;
 D signon
 I ER Q 
 ;
 F  D  I VFMQ="Q" Q 
 .	;
 .	N %FRAME
 .	N %NOPRMT N %READ N %TAB N FLD N RETURN N SUB
 .	;
 .	S %TAB("FLD(1)")="/DES=SQL Command/TYP=T/LEN=255"
 .	S %TAB("FLD(2)")="/DES=SQL Cmd Rec/TYP=T/LEN=255"
 .	S %TAB("FLD(3)")="/DES=Parameters/TYP=T/LEN=255"
 .	S %READ="FLD(1)/NOREQ,FLD(2)/NOREQ,FLD(3)/NOREQ"
 .	;
 .	S %FRAME=1
 .	S %NOPRMT="F"
 .	D ^UTLREAD
 .	I VFMQ="Q" Q 
 .	;
 .	I FLD(1)'="" D
 ..		N I
 ..		;
 ..		F I=1:1:$L(FLD(2)," ") S SUB(I)=$piece(FLD(2)," ",I)
 ..		S FLD(2)=$$V2LV^MSG(.SUB)
 ..		Q 
 .	;
 .	S MSG=$$V2LV^MSG(.FLD)
 .	;
 .	S RETURN=""
 .	S ER=$$^PBSMSQL(.RETURN,0,MSG,1)
 .	;
 .	ZWRITE ER,MSG,RETURN
 .	WRITE $$MSG^%TRMVT("",0,1)
 .	Q 
 ;
 D CLDSCNCT^SCADRV
 ;
 Q 
 ;
nxtline(routine,text) ; Private;Return tag of next line containing argument
 ;
 N i N lv N lv2 N off N off2
 N t N tag N x
 ;
 I routine'["^" S routine="^"_routine
 S tag=$piece(routine,"^",1) S routine="^"_$piece(routine,"^",2)
 ;
 ; find "text" in "tag" section of "routine"
 S t=""
 F off=1:1:200 D  I t[text Q 
 .	S x="S t=$P($T("_tag_"+"_off_routine_"),"";"",1)"
 .	;   #ACCEPT DATE=12/17/03;PGM=John Carroll
 .	XECUTE x
 .	Q 
 ;
 I t'[text Q ""
 ;
 ; remove tabs and spaces from source text and find nesting level
 S t=$TR(t,$char(9)_" ","") S lv=0
 F i=1:1:$L(t) S x=$E(t,i) Q:x'="."  S lv=lv+1
 ;
 ; locate next non-comment line on same or less nesting level
 F off2=off+1:1:200 D  Q:lv2'>lv 
 .	S t=""
 .	S x="S t=$P($T("_tag_"+"_off2_routine_"),"";"",1)"
 .	;   #ACCEPT DATE=12/17/03;PGM=John Carroll
 .	XECUTE x
 .	S t=$TR(t,$char(9)_" ","")
 .	S lv2=0
 .	F i=1:1:$L(t) S x=$E(t,i) Q:x'="."  S lv2=lv2+1
 .	I $E(t,lv2+1)="" S lv2=99
 .	Q 
 ;
 Q tag_"+"_off2_routine
 ;
ztrap ; Private;Setup PBSSRV to trap all messages to ZTRAP global
 N vpc,vTp
 ;
 N %FRAME
 N %READ N %TAB N after N before N DTS N EXAMPLE N K1 N K2 N NMS N PGM N SVPGM N T1 N T2 N VFMQ N UID
 ;
 S (UID,SVPGM)=""
 ;
 S before=$$nxtline("LOOP^PBSSRV","$$GETMSG^%MTAPI")
 S after=$$nxtline("LOOP^PBSSRV","STATS^PBSUTL")
 I before=""!(after="") WRITE !,"Unable to locate break points, Aborting" Q 
 ;
 N trap1u,vop1,vop2
 N trap1p,vop3,vop4
 ;
 I ($D(^TRAP1("UID"))#2) D
 .	S vop1="UID",trap1u=$$vRCgetRecord0Opt^RecordTRAP1("UID",0,.vop2)
 .	S UID=$P(trap1u,$C(124),1)
 .	Q 
 ;
 I ($D(^TRAP1("PGM"))#2) D
 .	S vop3="PGM",trap1p=$$vRCgetRecord0Opt^RecordTRAP1("PGM",0,.vop4)
 .	S SVPGM=$P(trap1p,$C(124),1)
 .	Q 
 ;
 N trap1n,vop5,vop6 S vop5="NMS",trap1n=$$vRCgetRecord1Opt^RecordTRAP1("NMS",0,.vop6)
 S NMS=$P(trap1n,$C(124),1)
 ;
 N trap1d,vop7,vop8 S vop7="DTS",trap1d=$$vRCgetRecord1Opt^RecordTRAP1("DTS",0,.vop8)
 S DTS=$P(trap1d,$C(124),1)
 ;
 I ($get(OPER)="") S OPER="ENABLE"
 I ($get(SVTYP)="") S SVTYP="SCA$IBS"
 I ($get(SVID)="") S SVID="*"
 ;
 S %TAB("OPER")="/DES=Operation/TYP=T/LEN=12/TBL=,ENABLE,DISABLE"
 S %TAB("SVTYP")="/DES=SVTYP/TYP=T/LEN=12/TBL=[SVCTRLT]SVTYP:DISTINCT:NOVAL"
 S %TAB("SVTYP")=%TAB("SVTYP")_"/XPP=D zpp1^PBSTST"
 S %TAB("UID")="[SCAU]UID"
 S %TAB("SVPGM")="/DES=Evaluation routine/LEN=40/TYP=T"
 S %TAB("NMS")="/DES=Log sign-on messages/TYP=L"
 ;
 S T1="Enable Logging of all Messages and Replies to ^TRAP"
 ;
 I (UID="") D
 .	S T2="Last User: "_"   "_$S(DTS'="":$ZD(DTS,"MM/DD/YEAR"),1:"")_" "_$$TIM^%ZM($piece(DTS,",",2))
 .	Q 
 E  D
 .	N scau S scau=$G(^SCAU(1,UID))
 .	S T2="Last User: "_$P(scau,$C(124),1)_"   "_$S(DTS'="":$ZD(DTS,"MM/DD/YEAR"),1:"")_" "_$$TIM^%ZM($piece(DTS,",",2))
 . Q 
 ;
 S EXAMPLE="                    "_"Example: if vzpkt'[""IVRXFR"" set quit=1"
 ;
 S %READ="@T1/CEN,,OPER/REQ,SVTYP/REQ,UID/NOREQ,SVPGM/NOREQ"
 S %READ="@T1/CEN,@T2/CEN,,OPER/REQ,SVTYP/REQ,UID/NOREQ,SVPGM/NOREQ,@EXAMPLE,NMS/NOREQ"
 ;
 S SVTYP="SCA$IBS"
 ;
 S %FRAME=1
 D ^UTLREAD S vpc=VFMQ="Q" Q:vpc 
 I (SVTYP="")!(SVID="") Q 
 ;
  S vop1="UID",trap1u=$$vRCgetRecord1Opt^RecordTRAP1("UID",0,.vop2)
  S $P(trap1u,$C(124),1)=UID
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^TRAP1(vop1)=$$RTBAR^%ZFUNC(trap1u) S vop2=1 TC:vTp  
 ;
  S vop3="PGM",trap1p=$$vRCgetRecord1Opt^RecordTRAP1("PGM",0,.vop4)
  S $P(trap1p,$C(124),1)=SVPGM
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^TRAP1(vop3)=$$RTBAR^%ZFUNC(trap1p) S vop4=1 TC:vTp  
 ;
  S $P(trap1n,$C(124),1)=NMS
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^TRAP1(vop5)=$$RTBAR^%ZFUNC(trap1n) S vop6=1 TC:vTp  
 ;
  S $P(trap1d,$C(124),1)=$P($H,",",1)_","_$P($H,",",2)
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^TRAP1(vop7)=$$RTBAR^%ZFUNC(trap1d) S vop8=1 TC:vTp  
 ;
 N rs
 I SVTYP="*" S rs=$$vOpen2()
 E   K vobj(+$G(rs)) S rs=$$vOpen3()
 F  Q:'$$vFetch(rs)  D
 .	S SVTYP=$P(vobj(rs),$C(9),1)
 .	S SVID=$P(vobj(rs),$C(9),2)
 .	;
 .	N svctrl,vop9,vop10,vop11,vop12 S svctrl="",vop12=0
 .  S vop11=SVTYP
 .  S vop10=SVID
 .  S vop9=$O(^SVCTRL(SVTYP,SVID,""),-1)+1
 .  S $P(svctrl,$C(124),1)="TRAP=0"
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^SVCTRL(vop11,vop10,vop9)=$$RTBAR^%ZFUNC(svctrl) S vop12=1 TC:vTp  
 .	;
 .	I OPER="ENABLE" D
 ..		D EXEC^PBSUTL(SVTYP,SVID,"ZB "_before_":""d ztrapm^PBSTST""")
 ..		D EXEC^PBSUTL(SVTYP,SVID,"ZB "_after_":""d ztrapr^PBSTST""")
 ..		Q 
 .	E  D EXEC^PBSUTL(SVTYP,SVID,"ZB -*")
 .	; zwrite ^SVCTRL(SVTYP,SVID,*)
 . Q 
 ;
 K vobj(+$G(rs)) Q 
 ;
zpp1 ; 
 ;
 N LSVTYP
 ;
 ; Invalid table value ~p1
 I X="" S ER=1 S RM=$$^MSG(1485) Q 
 ;
 ; Invalid table value ~p1
 N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen4()
 I X'="*",'$G(vos1) S ER=1 S RM=$$^MSG(1485,X) Q 
 ;
 S ER=0
 S RM=""
 S LSVTYP=SVTYP
 S SVTYP=X
 ;
 I SVTYP="*" D  Q 
 .	S SVID="*"
 .	D DISPLAY^DBSMACRO("@SVID","*")
 .	D PROTECT^DBSMACRO("@SVID")
 .	Q 
 ;
 I LSVTYP="*" D UNPROT^DBSMACRO("@SVID")
 ;
 I (SVID="")!((SVID'="")&(SVID'="*")&('($D(^SVCTRL(SVTYP,SVID))#2))) D
 . S SVID=$P(rs,$C(9),2)
 .	D DISPLAY^DBSMACRO("@SVID",SVID)
 .	Q 
 Q 
 ;
zpp2 ; 
 ;
 ; Invalid table value ~p1
 I X="" S ER=1 S RM=$$^MSG(1485) Q 
 ;
 ; Invalid table value ~p1
 I X'="*",'($D(^SVCTRL(SVTYP,X))#2) S ER=1 S RM=$$^MSG(1485,X) Q 
 S ER=0
 S RM=""
 S SVID=X
 Q 
 ;
ztrapm ; 
 N vTp
 ;
 N quit N seq
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ;
 I vzpkt="",vzermsg="CS_TIMEOUT" Q 
 ;
  K ^SVTRAP($J)
 ;
 S quit=0
 D  I quit Q 
 .	;
 .	N ar N bdy N hdr N x N ZPGM
 .	;
 .	S x=$$LV2V^MSG($get(vzpkt),.ar)
 .	S x=$$LV2V^MSG($get(ar(1)),.hdr)
 .	S x=$$LV2V^MSG($get(ar(2)),.bdy)
 .	;
 .	I ('($get(hdr(2))="")),$$zchkuid(hdr(2)) D  Q 
 ..		S quit=1
 ..		N svtrap S svtrap=$$vRCgetRecord1^RecordSVTRAP($J,0)
 ..	  S $P(vobj(svtrap),$C(124),1)=1
 ..	 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSVTRAP(svtrap,"/CASDEL/INDEX/NOJOURNAL/LOG/NOTRIGAFT/NOTRIGBEF/UPDATE/NOVALDD/VALFK/NOVALREQ/NOVALRI/NOVALST/") K vobj(svtrap,-100) S vobj(svtrap,-2)=1 TC:vTp  
 ..		K vobj(+$G(svtrap)) Q 
 .	;
 .	I $get(hdr(1))=0,$$zchknmsp($get(bdy(1))) D  Q 
 ..		S quit=1
 ..		N svtrap S svtrap=$$vRCgetRecord1^RecordSVTRAP($J,0)
 ..	  S $P(vobj(svtrap),$C(124),1)=1
 ..	 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSVTRAP(svtrap,"/CASDEL/INDEX/NOJOURNAL/LOG/NOTRIGAFT/NOTRIGBEF/UPDATE/NOVALDD/VALFK/NOVALREQ/NOVALRI/NOVALST/") K vobj(svtrap,-100) S vobj(svtrap,-2)=1 TC:vTp  
 ..		K vobj(+$G(svtrap)) Q 
 .	;
 .	N trap1 S trap1=$G(^TRAP1("PGM"))
 . I $P(trap1,$C(124),1)="" Q 
 .	S ZPGM=$P(trap1,$C(124),1)
 .	;   #ACCEPT DATE=12/17/03;PGM=John Carroll
 .	XECUTE ZPGM
 . Q 
 ;
 N trap0 S trap0=$$vRCgetRecord1^RecordTRAP0($J,0,0)
 S seq=$P(vobj(trap0),$C(124),1)+1
 I seq>50 S seq=1
 ;
  S $P(vobj(trap0),$C(124),1)=seq_" PBSSRV"
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordTRAP0(trap0,"/CASDEL/INDEX/NOJOURNAL/LOG/NOTRIGAFT/NOTRIGBEF/UPDATE/NOVALDD/VALFK/NOVALREQ/NOVALRI/NOVALST/") K vobj(trap0,-100) S vobj(trap0,-2)=1 TC:vTp  
 ;
  N V1,V2 S V1=$J,V2=seq  K ^TRAP(V1,V2)
 ;
 N trap0s S trap0s=$$vcdmNew^RecordTRAP0()
  S vobj(trap0s,1,1)=""
  S vobj(trap0s,-3)=$J
  S vobj(trap0s,-4)=seq
  S $P(vobj(trap0s),$C(124),1)="M:"_$$vdat2str(($P($H,",",1)_","_$P($H,",",2)),"MM/DD/YY 24:60:SS")_"|"_vzermsg
  S vobj(trap0s,1,1)=vzpkt
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordTRAP0(trap0s,"/CASDEL/INDEX/NOJOURNAL/LOG/NOTRIGAFT/NOTRIGBEF/UPDATE/NOVALDD/VALFK/NOVALREQ/NOVALRI/NOVALST/") K vobj(trap0s,-100) S vobj(trap0s,-2)=1 TC:vTp  
 ;
 K vobj(+$G(trap0)),vobj(+$G(trap0s)) Q 
 ;
ztrapr ; 
 N vTp
 ;
 N quit N seq
 ;
 S quit=0
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch2^"_$T(+0)
 ;
 N svtrap S svtrap=$G(^SVTRAP($J))
 ;
 ; Ignore if ztrapm said to ignore
 I $P(svtrap,$C(124),1) Q 
 ;
 ; Ignore network management reply
 I $get(vzsrvcls)=0 D  Q:quit 
 .	;
 .	N ar N x
 .	;
 .	S x=$$LV2V^MSG($get(vzrecord(2)),.ar)
 .	I $$zchknmsp($get(ar(1))) S quit=1
 .	Q 
 ;
 I $$zchkuid($get(vzcltokn)) Q 
 ;
 N trap0 S trap0=$$vRCgetRecord1^RecordTRAP0($J,0,0)
 S seq=$P(vobj(trap0),$C(124),1)+1
 I seq>51 S seq=1
 ;
  S $P(vobj(trap0),$C(124),1)=seq_" PBSSRV"
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordTRAP0(trap0,"/CASDEL/INDEX/NOJOURNAL/LOG/NOTRIGAFT/NOTRIGBEF/UPDATE/NOVALDD/VALFK/NOVALREQ/NOVALRI/NOVALST/") K vobj(trap0,-100) S vobj(trap0,-2)=1 TC:vTp  
 ;
  N V1,V2 S V1=$J,V2=seq  K ^TRAP(V1,V2)
 ;
 N trap0s S trap0s=$$vcdmNew^RecordTRAP0()
  S vobj(trap0s,1,1)=""
  S vobj(trap0s,-3)=$J
  S vobj(trap0s,-4)=seq
  S $P(vobj(trap0s),$C(124),1)="R:"_$$vdat2str(($P($H,",",1)_","_$P($H,",",2)),"MM/DD/YY 24:60:SS")_"|"_vzermsg
  S vobj(trap0s,1,1)=vzreply
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordTRAP0(trap0s,"/CASDEL/INDEX/NOJOURNAL/LOG/NOTRIGAFT/NOTRIGBEF/UPDATE/NOVALDD/VALFK/NOVALREQ/NOVALRI/NOVALST/") K vobj(trap0s,-100) S vobj(trap0s,-2)=1 TC:vTp  
 ;
  N V3 S V3=$J  K ^SVTRAP(V3)
 ;
 K vobj(+$G(trap0)),vobj(+$G(trap0s)) Q 
 ;
zchknmsp(mprc) ; 
 ; mrpc - process code
 ; Skip sign-on messages (by default all nmsp messages are not logged)
 ;
 N trap1n S trap1n=$G(^TRAP1("NMS"))
 I $P(trap1n,$C(124),1)'=1 Q 1
 ;
 ; Skip sign-off messages
 I mprc=0 Q 1
 ;
 ; Skip heartbeat messages
 I mprc=2 Q 1
 ;
 ; Skip change context messages
 I mprc=3 Q 1
 ;
 Q 0
 ;
zchkuid(mtok) ; 
 ;
 N muid
 ;
 I ($get(mtok)="") Q 1
 ;
 N token,vop1 S token=$$vRCgetRecord1Opt^RecordTOKEN(mtok,0,.vop1)
 I $G(vop1)=0 Q 1
 ;
 N trap1 S trap1=$G(^TRAP1("UID"))
 I $P(trap1,$C(124),1)'="" S muid=$P(token,$C(124),2) I muid'=$P(trap1,$C(124),1) Q 1
 ;
 Q 0
 ;
xtrap ; Index ^ZTRAP entries into XTRAP
 ;
 N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen5()
 ;
 I ''$G(vos1) F  Q:'$$vFetch5()  D
 .	;
 .	N date
 .	N i N time
 .	N seq N x N y
 .	;
 . S x=$P(rs,$C(9),1)
 . S y=$P(rs,$C(9),2)
 .	N trap0,vop1,vop2,vop3 S vop1=x,vop2=y,trap0=$$vRCgetRecord0Opt^RecordTRAP0(x,y,0,"")
 .	 S vop3="" N von S von="" F  S von=$O(^TRAP(vop1,vop2,von)) quit:von=""  S vop3=vop3_^TRAP(vop1,vop2,von)
 .	;
 .	S date=$E($P(trap0,$C(124),1),3,10)
 .	S time=$E($P(trap0,$C(124),1),12,19)
 .	;
 .	S seq=x_"_"_y
 .	S XTRAP(date,time,seq)=$P(trap0,$C(124),1)
 .	F i=1:400:$L(vop3) D
 ..		S XTRAP(date,time,seq,(i\400)+1)=$E(vop3,i,i+399)
 ..		Q 
 . Q 
 ;
 Q 
 ;
 ;----------------------------------------------------------------------
REPLAY(SERVER,SEQ) ; 
 N vTp
 ;
 N FLD N HDR N MSG N P N X
 ;
 ; Build message
 S (MSG,X)=""
 ;
 N rs,vos1,vos2,vos3,vos4,vos5 S rs=$$vOpen6()
 I $$vFetch6() S MSG=rs
 ;
 ; Unwrap message header
 S P=$$LV2V^MSG(MSG,.FLD)
 S P=$$LV2V^MSG(FLD(1),.HDR)
 ;
 ; Make sure Token is signed on
 N token,vop1,vop2 S vop1=HDR(2),token=$$vRCgetRecord1Opt^RecordTOKEN(vop1,0,.vop2)
 I $G(vop2) D
 .  S $P(token,$C(124),1)=1
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^TOKEN(vop1)=$$RTBAR^%ZFUNC(token) S vop2=1 TC:vTp  
 .	Q 
 ;
 ; Remove entry from ^MSGLOG
  N V1,V2 S V1=HDR(2),V2=HDR(3) D vDbDe1()
 ;
 WRITE !
 ZWRITE MSG
 WRITE !,!,!
 ;
 ; Process message
 S X=$$PROC^PBSSRV(MSG,"","","","")
 ZWRITE X
 ;
 Q 
 ;
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61116^11513^Savitha Venkatesh^18596" ; Signature - LTD^TIME^USER^SIZE
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
vDbDe1() ; DELETE FROM MSGLOG WHERE TOKEN=:V1 and MSGID=:V2
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen7()
 F  Q:'$$vFetch7()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^MSGLOG(v1,v2)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ;
vFetch(vRs) ; Runtime fetch
 ;
 N vPgm,vTag
 S vPgm=$TEXT(+0),vTag=vobj(vRs,-2)
 I vTag=("$$vFetch2^"_vPgm) Q $$vFetch2(vRs)
 I vTag=("$$vFetch3^"_vPgm) Q $$vFetch3(vRs)
 X "set vTag="_vTag_"(vRs)"
 Q vTag
 ;
vOpen1() ; SVID FROM SVCTRLT WHERE SVTYP='SCA$IBS' ORDER BY SVID DESC
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL1a3 S vos3=$O(^SVCTRL("SCA$IBS",vos3),-1) I vos3="" G vL1a0
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
vOpen2() ; SVTYP,SVID FROM SVCTRLT ORDER BY SVTYP,SVID
 ;
 N vOid
 ;
 S vOid=$O(vobj(""),-1)+1
 S vobj(vOid,0)=2
 S vobj(vOid,-1)="ResultSet"
 S vobj(vOid,-2)="$$vFetch2^"_$T(+0)
 S vobj(vOid,-3)="SVTYP,SVID"
 S vobj(vOid,-4)="T0T0"
 D vL2a1
 Q vOid
 ;
vL2a0 S vobj(vOid,0)=0 Q
vL2a1 S vobj(vOid,1)=$$BYTECHAR^SQLUTL(254)
 S vobj(vOid,2)=""
vL2a3 S vobj(vOid,2)=$O(^SVCTRL(vobj(vOid,2)),1) I vobj(vOid,2)="" G vL2a0
 S vobj(vOid,3)=""
vL2a5 S vobj(vOid,3)=$O(^SVCTRL(vobj(vOid,2),vobj(vOid,3)),1) I vobj(vOid,3)="" G vL2a3
 Q
 ;
vFetch2(vOid) ;
 ;
 ;
 I vobj(vOid,0)=1 D vL2a5
 I vobj(vOid,0)=2 S vobj(vOid,0)=1
 ;
 I vobj(vOid,0)=0 S vobj(vOid)="" Q 0
 ;
 S vobj(vOid)=$S(vobj(vOid,2)=vobj(vOid,1):"",1:vobj(vOid,2))_$C(9)_$S(vobj(vOid,3)=vobj(vOid,1):"",1:vobj(vOid,3))
 ;
 Q 1
 ;
vOpen3() ; SVTYP,SVID FROM SVCTRLT WHERE SVTYP =:SVTYP ORDER BY SVTYP,SVID
 ;
 N vOid
 ;
 S vOid=$O(vobj(""),-1)+1
 S vobj(vOid,0)=2
 S vobj(vOid,-1)="ResultSet"
 S vobj(vOid,-2)="$$vFetch3^"_$T(+0)
 S vobj(vOid,-3)="SVTYP,SVID"
 S vobj(vOid,-4)="T0T0"
 D vL3a1
 Q vOid
 ;
vL3a0 S vobj(vOid,0)=0 Q
vL3a1 S vobj(vOid,1)=$$BYTECHAR^SQLUTL(254)
 S vobj(vOid,2)=$G(SVTYP) I vobj(vOid,2)="" G vL3a0
 S vobj(vOid,3)=""
vL3a4 S vobj(vOid,3)=$O(^SVCTRL(vobj(vOid,2),vobj(vOid,3)),1) I vobj(vOid,3)="" G vL3a0
 Q
 ;
vFetch3(vOid) ;
 ;
 ;
 I vobj(vOid,0)=1 D vL3a4
 I vobj(vOid,0)=2 S vobj(vOid,0)=1
 ;
 I vobj(vOid,0)=0 S vobj(vOid)="" Q 0
 ;
 S vobj(vOid)=vobj(vOid,2)_$C(9)_$S(vobj(vOid,3)=vobj(vOid,1):"",1:vobj(vOid,3))
 ;
 Q 1
 ;
vOpen4() ; SVTYP,SVID FROM SVCTRLT WHERE SVTYP=:X ORDER BY SVID
 ;
 ;
 S vos1=2
 D vL4a1
 Q ""
 ;
vL4a0 S vos1=0 Q
vL4a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(X) I vos3="" G vL4a0
 S vos4=""
vL4a4 S vos4=$O(^SVCTRL(vos3,vos4),1) I vos4="" G vL4a0
 Q
 ;
vFetch4() ;
 ;
 ;
 I vos1=1 D vL4a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen5() ; PID,SEQ FROM TRAP0 WHERE SEQ>0
 ;
 ;
 S vos1=2
 D vL5a1
 Q ""
 ;
vL5a0 S vos1=0 Q
vL5a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL5a3 S vos3=$O(^TRAP(vos3),1) I vos3="" G vL5a0
 S vos4=0
vL5a5 S vos4=$O(^TRAP(vos3,vos4),1) I vos4="" G vL5a3
 Q
 ;
vFetch5() ;
 ;
 ;
 I vos1=1 D vL5a5
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos3=vos2:"",1:vos3)_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen6() ; MESSAGE FROM TRAP0 WHERE PID=:SERVER AND SEQ=:SEQ
 ;
 ;
 S vos1=2
 D vL6a1
 Q ""
 ;
vL6a0 S vos1=0 Q
vL6a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(SERVER)
 S vos4=$G(SEQ)
 I '($D(^TRAP(vos3,vos4))#2) G vL6a0
 Q
 ;
vFetch6() ;
 ;
 ;
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos1=100
 S vos5=$$READ^DBSMEMO("^TRAP("_vos3_","_vos4_")")
 S rs=vos5
 S vos1=0
 ;
 Q 1
 ;
vOpen7() ; TOKEN,MSGID FROM MSGLOG WHERE TOKEN=:V1 AND MSGID=:V2
 ;
 ;
 S vos1=2
 D vL7a1
 Q ""
 ;
vL7a0 S vos1=0 Q
vL7a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL7a0
 S vos4=$G(V2) I vos4="" G vL7a0
 I '($D(^MSGLOG(vos3,vos4))#2) G vL7a0
 Q
 ;
vFetch7() ;
 ;
 ;
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vos1=100
 S vRs=vos3_$C(9)_vos4
 S vos1=0
 ;
 Q 1
 ;
vCatch2 ; Error trap
 ;
 N vError,$ET,$ES S vError=$ZE,$EC="",$ET="Q",$ZE=""
 D ZE^UTLERR
 WRITE !,"Problem in ztrapr^PBSTST",!!
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch1 ; Error trap
 ;
 N vError,$ET,$ES S vError=$ZE,$EC="",$ET="Q",$ZE=""
 D ZE^UTLERR
 WRITE !,"Problem in ztrapm^PBSTST",!!
 D ZX^UCGMR(voxMrk) Q 
