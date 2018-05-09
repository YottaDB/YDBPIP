R01S250	; DBSPPLST - DATA-QWIK Pre/Post-Proc Library Listing
	;
	; **** Routine compiled from DATA-QWIK Report DBSPPLST ****
	;
	; 09/14/2007 10:49 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/14/2007 10:49 - chenardp
	;
	 S ER=0
	N OLNTB
	N %READ N RID N RN N %TAB N VFMQ
	;
	S RID="DBSPPLST"
	S RN="DATA-QWIK Pre/Post-Proc Library Listing"
	I $get(IO)="" S IO=$I
	;
	D INIT^%ZM()
	;
	S %TAB("IO")=$$IO^SCATAB
	;
	S %READ="IO/REQ,"
	;
	; Skip device prompt option
	I $get(VRWOPT("NOOPEN")) S %READ=""
	;
	S VFMQ=""
	I %READ'="" D  Q:$get(VFMQ)="Q" 
	.	S OLNTB=30
	.	S %READ="@RN/CEN#1,,"_%READ
	.	D ^UTLREAD
	.	Q 
	;
	I '$get(vbatchq) D V0
	Q 
	;
V0	; External report entry point
	;
	N vcrt N VD N VFMQ N vh N vI N vlc N VLC N VNEWHDR N VOFFLG N VPN N VR N VRG N vs N VSEQ N VT
	N %TIM N BLANK N CONAM N LINKS N RID N RN N VL N VLOF N VRF N VSTATS N vCOL N vHDG N vc1 N vc10 N vc11 N vc2 N vc3 N vc4 N vc5 N vc6 N vc7 N vc8 N vc9 N vovc1 N vovc2 N vovc3 N vrundate N vsysdate
	;
	N cuvar S cuvar=$$vDb2()
	 S cuvar=$G(^CUVAR("BANNER"))
	;
	S CONAM="DATA-QWIK 7.2"
	S ER=0 S RID="DBSPPLST" S RN="DATA-QWIK Pre/Post-Proc Library Listing"
	S VL=""
	;
	USE 0 I '$get(VRWOPT("NOOPEN")) D  Q:ER 
	.	I '($get(VRWOPT("IOPAR"))="") S IOPAR=VRWOPT("IOPAR")
	.	E  I (($get(IOTYP)="RMS")!($get(IOTYP)="PNTQ")),('($get(IOPAR)["/OCHSET=")),$$VALID^%ZRTNS("UCIOENCD") D
	..		; Accept warning if ^UCIOENCD does not exist
	..		;    #ACCEPT Date=07/26/06; Pgm=RussellDS; CR=22121; Group=MISMATCH
	..		N CHRSET S CHRSET=$$^UCIOENCD("Report","DBSPPLST","V0","*")
	..		I '(CHRSET="") S IOPAR=IOPAR_"/OCHSET="_CHRSET
	..		Q 
	.	D OPEN^SCAIO
	.	Q 
	S vcrt=(IOTYP="TRM")
	I 'vcrt S IOSL=60 ; Non-interactive
	E  D  ; Interactive
	.	D TERM^%ZUSE(IO,"WIDTH=133")
	.	WRITE $$CLEARXY^%TRMVT
	.	WRITE $$SCR132^%TRMVT ; Switch to 132 col mode
	.	Q 
	;
	D INIT^%ZM()
	;
	S vCOL="[DBTBL13D]DATA#6#120"
	;
	; Print Report Banner Page
	I $P(cuvar,$C(124),1),'$get(VRWOPT("NOBANNER")),IOTYP'="TRM",'$get(AUXPTR) D
	.	N VBNRINFO N VWHERE
	.	;
	.	S VWHERE=""
	.	S VWHERE=VWHERE_"DBTBL13.PID IN (SELECT ELEMENT FROM TMPDQ WHERE PI"
	.	S VWHERE=VWHERE_"D=:%ProcessID)"
	.	S VBNRINFO("WHERE")=VWHERE
	.	;
	.	S VBNRINFO("DESC")="DATA-QWIK Pre/Post-Proc Library Listing"
	.	S VBNRINFO("PGM")="R01S250"
	.	S VBNRINFO("RID")="DBSPPLST"
	.	S VBNRINFO("TABLES")="DBTBL13D,DBTBL13"
	.	;
	.	S VBNRINFO("ORDERBY",1)="[SYSDEV,DBTBL13D]LIBS"
	.	S VBNRINFO("ORDERBY",2)="[SYSDEV,DBTBL13D]13"
	.	S VBNRINFO("ORDERBY",3)="[SYSDEV,DBTBL13D]PID"
	.	S VBNRINFO("ORDERBY",4)="[SYSDEV,DBTBL13D]SEQ"
	.	;
	.	D ^DBSRWBNR(IO,.VBNRINFO) ; Print banner
	.	Q 
	;
	; Initialize variables
	S (vc1,vc2,vc3,vc4,vc5,vc6,vc7,vc8,vc9,vc10,vc11)=""
	S (VFMQ,vlc,VLC,VOFFLG,VPN,VRG)=0
	S VNEWHDR=1
	S VLOF=""
	S %TIM=$$TIM^%ZM
	S vrundate=$$vdat2str($P($H,",",1),"MM/DD/YEAR") S vsysdate=$S(TJD'="":$ZD(TJD,"MM/DD/YEAR"),1:"")
	;
	D
	.	N I N J N K
	.	F I=0:1:4 D
	..		S (vh(I),VD(I))=0 S vs(I)=1 ; Group break flags
	..		S VT(I)=0 ; Group count
	..		F J=1:1:0 D
	...			F K=1:1:3 S VT(I,J,K)="" ; Initialize function stats
	...			Q 
	..		Q 
	.	Q 
	;
	 N V1 S V1=$J D vDbDe1() ; Report browser data
	S vh(0)=0
	;
	; Run report directly
	D VINILAST
	N rwrs,vos1,vos2,vos3,vos4,vos5,vos7,vos6,vos8,vos9,vOid  N V2 S V2=$J S rwrs=$$vOpen1()
	I $get(ER) USE 0 WRITE $$MSG^%TRMVT($get(RM),"",1) ; Debug Mode
	I '$G(vos1) D VEXIT(1) Q 
	F  Q:'($$vFetch1())  D  Q:VFMQ 
	.	N V N VI
	.	S V=rwrs
	.	S VI=""
	.	D VGETDATA(V,"")
	.	D VPRINT Q:VFMQ 
	.	D VSAVLAST
	.	Q 
	D VEXIT(0)
	;
	Q 
	;
VINILAST	; Initialize last access key values
	S vovc1="" S vovc2="" S vovc3=""
	Q 
	;
VSAVLAST	; Save last access keys values
	S vovc1=vc1 S vovc2=vc2 S vovc3=vc3
	Q 
	;
VGETDATA(V,VI)	;
	S vc1=$piece(V,$char(9),1) ; DBTBL13D.LIBS
	S vc2=$piece(V,$char(9),2) ; DBTBL13D.PID
	S vc3=$piece(V,$char(9),3) ; DBTBL13D.SEQ
	S vc4=$piece(V,$char(9),4) ; DBTBL13.PID
	S vc5=$piece(V,$char(9),5) ; DBTBL13.DESC
	S vc6=$piece(V,$char(9),6) ; DBTBL13.UID
	S vc7=$piece(V,$char(9),7) ; DBTBL13.DATE
	S vc8=$piece(V,$char(9),8) ; DBTBL13.DOC
	S vc9=$piece(V,$char(9),9) ; DBTBL13.DOC2
	S vc10=$piece(V,$char(9),10) ; DBTBL13.DOC3
	S vc11=$piece(V,$char(9),11) ; DBTBL13D.DATA
	Q 
	;
VBRSAVE(LINE,DATA)	; Save for report browser
	N tmprptbr,vop1,vop2,vop3,vop4,vop5 S tmprptbr="",vop4="",vop3="",vop2="",vop1="",vop5=0
	S vop4=$J
	S vop3=LINE
	S vop2=0
	S vop1=0
	S $P(tmprptbr,$C(12),1)=DATA
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^TMPRPTBR(vop4,vop3,vop2,vop1)=tmprptbr S vop5=1 Tcommit:vTp  
	Q 
	;
MEMO(MEMO,LINE,SIZE)	; Print all lines of memo, except last - return it in V
	;
	N I N TAB N VLLEN
	N X
	;
	S TAB=(LINE#1000)-1 ; Location
	S MEMO=$$vStrTrim(MEMO,0," ")
	;
	I $L(MEMO)'>SIZE Q MEMO
	;
	S VLLEN=$L(VL)
	F  D  Q:VFMQ!(MEMO="") 
	.	S X=$E(MEMO,1,SIZE)
	.	I X[" " D
	..		F I=SIZE:-1:1 Q:$E(X,I)=" " 
	..		S X=$E(X,1,I-1)
	..		Q 
	.	S MEMO=$E(MEMO,$L(X)+1,1048575)
	.	S X=$$vStrTrim(X,0," ")
	.	S MEMO=$$vStrTrim(MEMO,0," ") Q:(MEMO="") 
	.	; Print this portion
	.	I VLC+1>IOSL D VHDG0 I VFMQ S VFMQ=1 Q 
	.	S VL=VL_$J("",TAB-$L(VL))_X D VOM
	.	S VL=$J("",TAB)
	.	Q 
	S VL=$J("",VLLEN)
	Q X
	;
VEXIT(NOINFO)	; Exit from report
	N I N PN N vs N z
	N VL S VL=""
	S vs(1)=0 S vs(2)=0 S vs(3)=0 S vs(4)=0
	I 'VFMQ D VSUM
	I 'vh(0) D VHDG0
	I 'VFMQ D
	.	; No information available to display
	.	I NOINFO=1 S VL=$$^MSG(4655) D VOM
	.	I vcrt S VL="" F z=VLC+1:1:IOSL D VOM
	.	;
	.	I '($D(VTBLNAM)#2) D
	..		S vs(2)=0
	..		Q 
	.	Q 
	;
	I 'VFMQ,vcrt S PN=-1 D ^DBSRWBR(2)
	I '$get(VRWOPT("NOCLOSE")) D CLOSE^SCAIO
	 N V1 S V1=$J D vDbDe2() ; Report browser data
	;
	Q 
	;
VPRINT	; Print section
	N vskp
	;
	I $get(VRWOPT("NODTL")) S vskp(3)=1 S vskp(4)=1 ; Skip detail
	D VBREAK
	D VSUM Q:VFMQ 
	;
	I $get(VH0) S vh(0)=0 S VNEWHDR=1 K VH0 ; Page Break
	I 'vh(0) D VHDG0 Q:VFMQ 
	I '$get(vskp(3)) D VDTL3 Q:VFMQ 
	I '$get(vskp(4)) D VDTL4 Q:VFMQ 
	D VSTAT
	Q 
	;
VBREAK	;
	Q:'VT(4) 
	N vb1 N vb2 N vb3 N vb4
	S (vb1,vb2,vb3,vb4)=0
	I 0!(vovc1'=vc1) S vs(3)=0 S vh(3)=0 S VD(1)=0 S vb2=1 S vb3=1 S vb4=1
	I vb3!(vovc2'=vc2) S vs(4)=0 S vh(4)=0 S VD(3)=0 S vb4=1
	Q 
	;
VSUM	; Report Group Summary
	I 'vs(4) S vs(4)=1 D stat^DBSRWUTL(4)
	I 'vs(3) S vs(3)=1 D stat^DBSRWUTL(3)
	I 'vs(2) S vs(2)=1 D stat^DBSRWUTL(2)
	Q 
	;
VSTAT	; Data field statistics
	;
	S VT(4)=VT(4)+1
	Q 
	;
VDTL3	; Detail
	;
	Q:VD(3)  S VD(3)=1 ; Print flag
	I VLC+8>IOSL D VHDG0 Q:VFMQ 
	;
	S VL="" D VOM
	S VL=$E(vc4,1,12)
	S VL=VL_$J("",17-$L(VL))_$E(vc5,1,40)
	S VL=VL_$J("",66-$L(VL))_"User: "
	S VL=VL_$J("",72-$L(VL))_$E(vc6,1,20)
	S VL=VL_$J("",106-$L(VL))_"Date: "
	S VL=VL_$J("",112-$L(VL))_$J($S(vc7'="":$ZD(vc7,"MM/DD/YEAR"),1:""),10)
	D VOM
	S VL="" D VOM
	S V=vc8 S VO=V D VP1 Q:VFMQ!$get(verror)  S V=$E(V,1,75) S VL="                 "_V
	I '($translate(VL," ")="") D VOM
	S VL="                 "_$E(vc9,1,75)
	I '($translate(VL," ")="") D VOM
	S VL="                 "_$E(vc10,1,75)
	I '($translate(VL," ")="") D VOM
	D VP2 Q:VFMQ!$get(verror)  S V=$$MEMO(LINKS,7018,100) S VL="                 "_V
	I '($translate(VL," ")="") D VOM
	D VP3 Q:VFMQ!$get(verror)  S V=$E(BLANK,1) S VL="                 "_V
	I '($translate(VL," ")="") D VOM
	Q 
	;
VDTL4	; Detail
	;
	I VLC+1>IOSL D VHDG0 Q:VFMQ 
	;
	S VL="     "_$E(vc11,1,120)
	D VOM
	Q 
	;
VHDG0	; Page Header
	N PN N V N VO
	I $get(VRWOPT("NOHDR")) Q  ; Skip page header
	S vh(0)=1 S VRG=0
	I VL'="" D VOM
	I vcrt,VPN>0 D  Q:VFMQ!'VNEWHDR 
	.	N PN N X
	.	S VL=""
	.	F X=VLC+1:1:IOSL D VOM
	.	S PN=VPN
	.	D ^DBSRWBR(2)
	.	S VLC=0
	.	Q:VFMQ 
	.	I VNEWHDR WRITE $$CLEARXY^%TRMVT
	.	E  S VLC=VLC+5 S VPN=VPN+1
	.	Q 
	;
	S ER=0 S VPN=VPN+1 S VLC=0
	;
	S VL=$E(($get(CONAM)),1,45)
	S VL=VL_$J("",100-$L(VL))_"Run Date:"
	S VL=VL_$J("",110-$L(VL))_$E(vrundate,1,10)
	S VL=VL_$J("",123-$L(VL))_$E(%TIM,1,8)
	D VOM
	S VL=RN_"  ("_RID_")"
	S VL=VL_$J("",102-$L(VL))_"System:"
	S VL=VL_$J("",110-$L(VL))_$E(vsysdate,1,10)
	S VL=VL_$J("",122-$L(VL))_"Page:"
	S VL=VL_$J("",128-$L(VL))_$E(($J(VPN,3)),1,3)
	D VOM
	S VL="" D VOM
	S VL=" "_"Name            Description"
	D VOM
	S VL="------------------------------------------------------------------------------------------------------------------------------------"
	D VOM
	;
	S VNEWHDR=0
	I vcrt S PN=VPN D ^DBSRWBR(2,1) ; Lock report page heading
	;
	Q 
	;
VOM	; Output print line
	;
	USE IO
	;
	; Advance to a new page
	I 'VLC,'vcrt D  ; Non-CRT device (form feed)
	.	I '$get(AUXPTR) WRITE $char(12),!
	.	E  WRITE $$PRNTFF^%TRMVT,!
	.	S $Y=1
	.	Q 
	;
	I vcrt<2 WRITE VL,! ; Output line buffer
	I vcrt S vlc=vlc+1 D VBRSAVE(vlc,VL) ; Save in BROWSER buffer
	S VLC=VLC+1 S VL="" ; Reset line buffer
	Q 
	;
	; Pre/post-processors
	;
VP1	; Column pre-processor - [SYSDEV,DBTBL13]DOC
	;
	; Use BLANK to add or not a blank line after all documentation.
	; Keeps us from having two blanks in case there is no documentation.
	;
	S BLANK=$char(9) ; Line will not be blank to start
	;
	Q 
	;
VP2	; Column pre-processor - Variable: LINKS
	N vpc
	;
	N rptHit N scrnHit
	N PID
	;
	S PID=vc4
	S LINKS=""
	;
	N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen2()
	;
	S vpc=('$G(vos1)) Q:vpc 
	;
	S LINKS="Screen/Report References: "
	;
	S (rptHit,scrnHit)=0
	;
	F  Q:'($$vFetch2())  D
	.	;
	.	I ($P(rs,$C(9),1)=-2),'scrnHit D
	..		;
	..		S LINKS=LINKS_"  Screen(s) - "
	..		S scrnHit=1
	..		Q 
	.	E  I 'rptHit D
	..		;
	..		S LINKS=LINKS_"  Report(s) - "
	..		S rptHit=1
	..		Q 
	.	;
	.	S LINKS=LINKS_$P(rs,$C(9),2)_"; "
	.	Q 
	;
	I ($E(LINKS,$L(LINKS)-2+1,1048575)="; ") S LINKS=$E(LINKS,1,$L(LINKS)-2)
	;
	Q 
	;
VP3	; Column pre-processor - Variable: BLANK
	;
	; If all preceeding lines are null, don't need another blank line
	;
	I (vc8=""),(vc9=""),(vc10=""),(LINKS="") S BLANK=""
	;
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vdat2str(object,mask)	; Date.toString
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I (object="") Q ""
	I (mask="") S mask="MM/DD/YEAR"
	N cc N lday N lmon
	I mask="DL"!(mask="DS") D  ; Long or short weekday
	.	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
	.	I (cc="") S cc="US"
	.	S lday=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
	.	S mask="DAY" ; Day of the week
	.	Q 
	I mask="ML"!(mask="MS") D  ; Long or short month
	.	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
	.	I (cc="") S cc="US"
	.	S lmon=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
	.	S mask="MON" ; Month of the year
	.	Q 
	Q $ZD(object,mask,$get(lmon),$get(lday))
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM TMPRPTBR WHERE JOBNO=:V1
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3 N v4
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4,vos5 S vRs=$$vOpen3()
	F  Q:'($$vFetch3())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3) S v4=$P(vRs,$C(9),4)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^TMPRPTBR(v1,v2,v3,v4)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vStrTrim(object,p1,p2)	; String.trim
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I p1'<0 S object=$$RTCHR^%ZFUNC(object,p2)
	I p1'>0 F  Q:$E(object,1)'=p2  S object=$E(object,2,1048575)
	Q object
	; ----------------
	;  #OPTION ResultClass 0
vDbDe2()	; DELETE FROM TMPRPTBR WHERE JOBNO=:V1
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3 N v4
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4,vos5 S vRs=$$vOpen4()
	F  Q:'($$vFetch4())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3) S v4=$P(vRs,$C(9),4)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^TMPRPTBR(v1,v2,v3,v4)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	;
vDb2()	;	voXN = Db.getRecord(CUVAR,,0)
	;
	I '$D(^CUVAR)
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,CUVAR" X $ZT
	Q ""
	;
vOpen1()	;	DBTBL13D.LIBS,DBTBL13D.PID,DBTBL13D.SEQ,DBTBL13.PID,DBTBL13.DESC,DBTBL13.UID,DBTBL13.DATE,DBTBL13.DOC,DBTBL13.DOC2,DBTBL13.DOC3,DBTBL13D.DATA FROM DBTBL13D,DBTBL13 WHERE DBTBL13.PID IN (SELECT ELEMENT FROM TMPDQ WHERE PID=:V2) ORDER BY DBTBL13D.LIBS,DBTBL13D.PID,DBTBL13D.SEQ
	;
	;
	S vOid=$G(^DBTMP($J))-1,^($J)=vOid K ^DBTMP($J,vOid)
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(V2) I vos2="" G vL1a7
	S vos3=""
vL1a3	S vos3=$O(^TEMP(vos2,vos3),1) I vos3="" G vL1a7
	S vd=$S(vos3=$$BYTECHAR^SQLUTL(254):"",1:vos3)
	I vd'="" S ^DBTMP($J,vOid,1,vd)=""
	G vL1a3
vL1a7	S vos4=""
vL1a8	S vos4=$O(^DBTBL(vos4),1) I vos4="" G vL1a0
	S vos5=""
vL1a10	S vos5=$O(^DBTMP($J,vOid,1,vos5),1) I vos5="" G vL1a8
	I '($D(^DBTBL(vos4,13,vos5))) G vL1a10
	S vos6=$G(^DBTBL(vos4,13,vos5,0))
	S vos7=$G(^DBTBL(vos4,13,vos5))
	S vos8=0
vL1a15	S vos8=$O(^DBTBL(vos4,13,vos5,vos8),1) I vos8="" G vL1a10
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a15
	I vos1=2 S vos1=1
	;
	I vos1=0 K ^DBTMP($J,vOid) Q 0
	;
	S vos9=$G(^DBTBL(vos4,13,vos5,vos8))
	S rwrs=$S(vos4=$$BYTECHAR^SQLUTL(254):"",1:vos4)_$C(9)_vos5_$C(9)_$S(vos8=$$BYTECHAR^SQLUTL(254):"",1:vos8)_$C(9)_vos5_$C(9)_$P(vos7,"|",1)_$C(9)_$P(vos6,"|",15)_$C(9)_$P(vos6,"|",3)_$C(9)_$P(vos6,"|",4)_$C(9)_$P(vos6,"|",5)
	S rwrs=rwrs_$C(9)_$P(vos6,"|",6)_$C(9)_$P(vos9,$C(12),1)
	;
	Q 1
	;
vOpen2()	;	TYP,NAME FROM DBTBL13LNK WHERE LIBS='SYSDEV' AND PID=:PID ORDER BY TYP ASC
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(PID) I vos2="" G vL2a0
	S vos3=""
vL2a3	S vos3=$O(^DBTBL("SYSDEV",13,vos2,vos3),1) I vos3=""!(vos3'<0) G vL2a0
	S vos4=""
vL2a5	S vos4=$O(^DBTBL("SYSDEV",13,vos2,vos3,vos4),1) I vos4="" G vL2a3
	Q
	;
vFetch2()	;
	;
	;
	I vos1=1 D vL2a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos3=$$BYTECHAR^SQLUTL(254):"",1:vos3)_$C(9)_$S(vos4=$$BYTECHAR^SQLUTL(254):"",1:vos4)
	;
	Q 1
	;
vOpen3()	;	JOBNO,LINENO,PAGENO,SEQ FROM TMPRPTBR WHERE JOBNO=:V1
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(V1) I vos2="" G vL3a0
	S vos3=""
vL3a3	S vos3=$O(^TMPRPTBR(vos2,vos3),1) I vos3="" G vL3a0
	S vos4=""
vL3a5	S vos4=$O(^TMPRPTBR(vos2,vos3,vos4),1) I vos4="" G vL3a3
	S vos5=""
vL3a7	S vos5=$O(^TMPRPTBR(vos2,vos3,vos4,vos5),1) I vos5="" G vL3a5
	Q
	;
vFetch3()	;
	;
	;
	I vos1=1 D vL3a7
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$$BYTECHAR^SQLUTL(254):"",1:vos3)_$C(9)_$S(vos4=$$BYTECHAR^SQLUTL(254):"",1:vos4)_$C(9)_$S(vos5=$$BYTECHAR^SQLUTL(254):"",1:vos5)
	;
	Q 1
	;
vOpen4()	;	JOBNO,LINENO,PAGENO,SEQ FROM TMPRPTBR WHERE JOBNO=:V1
	;
	;
	S vos1=2
	D vL4a1
	Q ""
	;
vL4a0	S vos1=0 Q
vL4a1	S vos2=$G(V1) I vos2="" G vL4a0
	S vos3=""
vL4a3	S vos3=$O(^TMPRPTBR(vos2,vos3),1) I vos3="" G vL4a0
	S vos4=""
vL4a5	S vos4=$O(^TMPRPTBR(vos2,vos3,vos4),1) I vos4="" G vL4a3
	S vos5=""
vL4a7	S vos5=$O(^TMPRPTBR(vos2,vos3,vos4,vos5),1) I vos5="" G vL4a5
	Q
	;
vFetch4()	;
	;
	;
	I vos1=1 D vL4a7
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$$BYTECHAR^SQLUTL(254):"",1:vos3)_$C(9)_$S(vos4=$$BYTECHAR^SQLUTL(254):"",1:vos4)_$C(9)_$S(vos5=$$BYTECHAR^SQLUTL(254):"",1:vos5)
	;
	Q 1
