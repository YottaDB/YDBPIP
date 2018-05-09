R01S170	; DBSSCRLSTLNK - DATA-QWIK Screen Definition Linked
	;
	; **** Routine compiled from DATA-QWIK Report DBSSCRLSTLNK ****
	;
	; 09/14/2007 08:42 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/14/2007 08:42 - chenardp
	;
	 S ER=0
	N OLNTB
	N %READ N RID N RN N %TAB N VFMQ
	N VIN1 S VIN1="ALL"
	;
	S RID="DBSSCRLSTLNK"
	S RN="DATA-QWIK Screen Definition Linked"
	I $get(IO)="" S IO=$I
	;
	D INIT^%ZM()
	;
	D VPREBQ Q:$get(VFMQ)  ; Pre-processor (before query)
	;
	S %TAB("IO")=$$IO^SCATAB
	S %TAB("VIN1")="|255||[DBTBL2]SID|[DBTBL2]SID:DISTINCT:NOVAL||D EXT^DBSQRY||T|Screen Name|||||"
	;
	S %READ="IO/REQ,VIN1#0,"
	;
	; Skip device prompt option
	I $get(VRWOPT("NOOPEN")) S %READ="VIN1#0,"
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
	N VWHERE
	N %TIM N CONAM N RID N RN N VL N VLOF N VRF N VSTATS N ZLINK N ZPREPP N vCOL N vHDG N vc1 N vc10 N vc11 N vc12 N vc13 N vc14 N vc15 N vc16 N vc17 N vc18 N vc19 N vc2 N vc20 N vc21 N vc22 N vc23 N vc24 N vc25 N vc26 N vc27 N vc28 N vc29 N vc3 N vc30 N vc31 N vc32 N vc33 N vc34 N vc35 N vc36 N vc37 N vc38 N vc39 N vc4 N vc5 N vc6 N vc7 N vc8 N vc9 N vovc1 N vovc2 N vrundate N vsysdate
	;
	S CONAM="DATA-QWIK 7.2"
	S ER=0 S RID="DBSSCRLSTLNK" S RN="DATA-QWIK Screen Definition Linked"
	S VL=""
	;
	USE 0 I '$get(VRWOPT("NOOPEN")) D  Q:ER 
	.	I '($get(VRWOPT("IOPAR"))="") S IOPAR=VRWOPT("IOPAR")
	.	E  I (($get(IOTYP)="RMS")!($get(IOTYP)="PNTQ")),('($get(IOPAR)["/OCHSET=")),$$VALID^%ZRTNS("UCIOENCD") D
	..		; Accept warning if ^UCIOENCD does not exist
	..		;    #ACCEPT Date=07/26/06; Pgm=RussellDS; CR=22121; Group=MISMATCH
	..		N CHRSET S CHRSET=$$^UCIOENCD("Report","DBSSCRLSTLNK","V0","*")
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
	; Build WHERE clause to use for dynamic query
	D
	.	N SEQ S SEQ=1
	.	N DQQRY N FROM
	.	I $get(VIN1)="" S VIN1="ALL"
	.	I VIN1'="ALL" S DQQRY(1)="[DBTBL2]SID "_VIN1 S SEQ=SEQ+1
	.	S DQQRY(SEQ)="[DBTBL2]LNK1'=""""" S SEQ=SEQ+1
	.	S FROM=$$DQJOIN^SQLCONV("DBTBL2") Q:ER 
	.	S VWHERE=$$WHERE^SQLCONV(.DQQRY,"")
	.	Q 
	;
	; Initialize variables
	S (vc1,vc2,vc3,vc4,vc5,vc6,vc7,vc8,vc9,vc10,vc11,vc12,vc13,vc14,vc15,vc16,vc17,vc18,vc19,vc20,vc21,vc22,vc23,vc24,vc25,vc26,vc27,vc28,vc29,vc30,vc31,vc32,vc33,vc34,vc35,vc36,vc37,vc38,vc39)=""
	S (VFMQ,vlc,VLC,VOFFLG,VPN,VRG)=0
	S VNEWHDR=1
	S VLOF=""
	S %TIM=$$TIM^%ZM
	S vrundate=$$vdat2str($P($H,",",1),"MM/DD/YEAR") S vsysdate=$S(TJD'="":$ZD(TJD,"MM/DD/YEAR"),1:"")
	;
	D
	.	N I N J N K
	.	F I=0:1:3 D
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
	;
	S VWHERE=""
	I ($D(vudwhere)#2) S VWHERE=vudwhere
	;  #ACCEPT DATE=09/14/2007;PGM=Report Writer Generator;CR=20967
	N rwrs,vos1,vos2,sqlcur,exe,sqlcur,vd,vi,vsql,vsub S rwrs=$$vOpen0(.exe,.vsql,"DBTBL2.LIBS,DBTBL2.SID,DBTBL2.DESC,DBTBL2.VPGM,DBTBL2.UID,DBTBL2.DATE,DBTBL2.PFID,DBTBL2.SCRCLR,DBTBL2.REPEAT,DBTBL2.RESFLG,DBTBL2.REPREQ,DBTBL2.LNK1,DBTBL2.LNK2,DBTBL2.LNK3,DBTBL2.LNK4,DBTBL2.LNK5,DBTBL2.LNK6,DBTBL2.LNK7,DBTBL2.LNK8,DBTBL2.LNK9,DBTBL2.LNK10,DBTBL2.LNK11,DBTBL2.LNK12,DBTBL2.LNK13,DBTBL2.LNK14,DBTBL2.LNK15,DBTBL2.LNK16,DBTBL2.LNK17,DBTBL2.LNK18,DBTBL2.LNK19,DBTBL2.LNK20,DBTBL2.LNK21,DBTBL2.LNK22,DBTBL2.LNK23,DBTBL2.LNK24,DBTBL2.LNK25,DBTBL2.LNK26,DBTBL2.LNK27,DBTBL2.LNK28","DBTBL2",VWHERE,"DBTBL2.LIBS,DBTBL2.SID","","/DQMODE=1")
	I $get(ER) USE 0 WRITE $$MSG^%TRMVT($get(RM),"",1) ; Debug Mode
	I '$G(vos1) D VEXIT(1) Q 
	F  Q:'($$vFetch0())  D  Q:VFMQ 
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
	S vovc1="" S vovc2=""
	Q 
	;
VSAVLAST	; Save last access keys values
	S vovc1=vc1 S vovc2=vc2
	Q 
	;
VGETDATA(V,VI)	;
	S vc1=$piece(V,$char(9),1) ; DBTBL2.LIBS
	S vc2=$piece(V,$char(9),2) ; DBTBL2.SID
	S vc3=$piece(V,$char(9),3) ; DBTBL2.DESC
	S vc4=$piece(V,$char(9),4) ; DBTBL2.VPGM
	S vc5=$piece(V,$char(9),5) ; DBTBL2.UID
	S vc6=$piece(V,$char(9),6) ; DBTBL2.DATE
	S vc7=$piece(V,$char(9),7) ; DBTBL2.PFID
	S vc8=$piece(V,$char(9),8) ; DBTBL2.SCRCLR
	S vc9=$piece(V,$char(9),9) ; DBTBL2.REPEAT
	S vc10=$piece(V,$char(9),10) ; DBTBL2.RESFLG
	S vc11=$piece(V,$char(9),11) ; DBTBL2.REPREQ
	S vc12=$piece(V,$char(9),12) ; DBTBL2.LNK1
	S vc13=$piece(V,$char(9),13) ; DBTBL2.LNK2
	S vc14=$piece(V,$char(9),14) ; DBTBL2.LNK3
	S vc15=$piece(V,$char(9),15) ; DBTBL2.LNK4
	S vc16=$piece(V,$char(9),16) ; DBTBL2.LNK5
	S vc17=$piece(V,$char(9),17) ; DBTBL2.LNK6
	S vc18=$piece(V,$char(9),18) ; DBTBL2.LNK7
	S vc19=$piece(V,$char(9),19) ; DBTBL2.LNK8
	S vc20=$piece(V,$char(9),20) ; DBTBL2.LNK9
	S vc21=$piece(V,$char(9),21) ; DBTBL2.LNK10
	S vc22=$piece(V,$char(9),22) ; DBTBL2.LNK11
	S vc23=$piece(V,$char(9),23) ; DBTBL2.LNK12
	S vc24=$piece(V,$char(9),24) ; DBTBL2.LNK13
	S vc25=$piece(V,$char(9),25) ; DBTBL2.LNK14
	S vc26=$piece(V,$char(9),26) ; DBTBL2.LNK15
	S vc27=$piece(V,$char(9),27) ; DBTBL2.LNK16
	S vc28=$piece(V,$char(9),28) ; DBTBL2.LNK17
	S vc29=$piece(V,$char(9),29) ; DBTBL2.LNK18
	S vc30=$piece(V,$char(9),30) ; DBTBL2.LNK19
	S vc31=$piece(V,$char(9),31) ; DBTBL2.LNK20
	S vc32=$piece(V,$char(9),32) ; DBTBL2.LNK21
	S vc33=$piece(V,$char(9),33) ; DBTBL2.LNK22
	S vc34=$piece(V,$char(9),34) ; DBTBL2.LNK23
	S vc35=$piece(V,$char(9),35) ; DBTBL2.LNK24
	S vc36=$piece(V,$char(9),36) ; DBTBL2.LNK25
	S vc37=$piece(V,$char(9),37) ; DBTBL2.LNK26
	S vc38=$piece(V,$char(9),38) ; DBTBL2.LNK27
	S vc39=$piece(V,$char(9),39) ; DBTBL2.LNK28
	Q 
	;
	; User-defined pre/post-processor code
	;
VPREBQ	; Pre-processor (before query)
	;
	;Incoming=DOC,SID,vudwhere
	S DOC=0
	; set vudwhere=""
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
VEXIT(NOINFO)	; Exit from report
	N I N PN N vs N z
	N VL S VL=""
	S vs(1)=0 S vs(2)=0 S vs(3)=0
	I 'VFMQ D VSUM
	I 'VFMQ D VRSUM
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
	I $get(VRWOPT("NODTL")) S vskp(3)=1 ; Skip detail
	D VBREAK
	D VSUM Q:VFMQ 
	;
	I $get(VH0) S vh(0)=0 S VNEWHDR=1 K VH0 ; Page Break
	I 'vh(0) D VHDG0 Q:VFMQ 
	I '$get(vskp(3)) D VDTL3 Q:VFMQ 
	D VSTAT
	Q 
	;
VBREAK	;
	Q:'VT(3) 
	N vb1 N vb2 N vb3
	S (vb1,vb2,vb3)=0
	I 0!(vovc1'=vc1) S vs(3)=0 S vh(3)=0 S VD(1)=0 S vb2=1 S vb3=1
	Q 
	;
VSUM	; Report Group Summary
	I 'vs(3) S vs(3)=1 D stat^DBSRWUTL(3)
	I 'vs(2) S vs(2)=1 D stat^DBSRWUTL(2)
	Q 
	;
VSTAT	; Data field statistics
	;
	S VT(3)=VT(3)+1
	Q 
	;
VDTL3	; Detail
	;
	I VLC+7>IOSL D VHDG0 Q:VFMQ 
	;
	S VL=" "_"Name: "
	S VL=VL_$J("",7-7)_$E(vc2,1,12)
	S VL=VL_$J("",24-$L(VL))_$E(vc3,1,40)
	S VL=VL_$J("",67-$L(VL))_"Program:"
	S VL=VL_$J("",77-$L(VL))_$E(vc4,1,8)
	S VL=VL_$J("",87-$L(VL))_"User ID:"
	S VL=VL_$J("",96-$L(VL))_$E(vc5,1,16)
	S VL=VL_$J("",114-$L(VL))_"Date: "
	S VL=VL_$J("",120-$L(VL))_$J($S(vc6'="":$ZD(vc6,"MM/DD/YEAR"),1:""),10)
	D VOM
	S VL="" D VOM
	S VL="                        "_"Files:"
	S VL=VL_$J("",32-30)_$E(vc7,1,40)
	S VL=VL_$J("",88-$L(VL))_"Screen Clear Option: "
	S VL=VL_$J("",109-$L(VL))_$J(vc8,1)
	S VL=VL_$J("",114-$L(VL))_"Repeat Region: "
	S VL=VL_$J("",129-$L(VL))_$J(vc9,2)
	D VOM
	S VL="                                                                                           "_"Protection Logic:"
	S VL=VL_$J("",109-108)_$S(vc10:"Y",1:"N")
	S VL=VL_$J("",113-$L(VL))_"Group Required:"
	S VL=VL_$J("",129-$L(VL))_$E(vc11,1,2)
	D VOM
	D VP1 Q:VFMQ!$get(verror)  S V=$E(ZPREPP,1,60) S VL="                         "_V
	D VOM
	D VP2 Q:VFMQ!$get(verror)  S V=$E(ZLINK,1,60) S VL="                         "_V
	D VOM
	S VL="------------------------------------------------------------------------------------------------------------------------------------"
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
	S VL="    "_"Data Item Name             Field Name/Description                Size  Format      Style            Req   Line  Column  Protect"
	D VOM
	S VL="------------------------------------------------------------------------------------------------------------------------------------"
	D VOM
	;
	S VNEWHDR=0
	I vcrt S PN=VPN D ^DBSRWBR(2,1) ; Lock report page heading
	;
	Q 
	;
VRSUM	; Report Summary
	N I
	N V N VL
	;
	S VL=""
	I 'vh(0) D VHDG0 Q:VFMQ 
	I VLC+1>IOSL D VHDG0 Q:VFMQ 
	;
	S VL="------------------------------------------------------------------------------------------------------------------------------------"
	D VOM
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
VP1	; Column pre-processor - Variable: ZPREPP
	;
	N SEQ
	N SID
	;
	S SID=vc2
	;
	; I18N=OFF: Excluded from I18N standards
	S verror=0
	F SEQ=81,61,101,121,1,21,41 D ZDBSPP2(SEQ,SID) Q:verror 
	S ZPREPP=""
	Q 
	;
ZDBSPP2(SEQ,SID)	;
	N vpc
	;
	N END N START
	;
	S START=SEQ-.001 S END=SEQ+20
	N rs,vos1,vos2,vos3,vos4,vos5,vos6 S rs=$$vOpen1()
	S vpc=('$G(vos1)) Q:vpc 
	I SEQ=1 S VL="Data Entry Pre-Processor"
	E  I SEQ=21 S VL="Screen Post-Processor"
	E  I SEQ=41 S VL="Required Data Item Set Definition"
	E  I SEQ=61 S VL="Screen Pre-Processor"
	E  I SEQ=81 S VL="Documentation"
	E  I SEQ=101 S VL="User Defined VLOD Definition"
	E  I SEQ=121 S VL="Display Pre-Processor"
	E  S VL=""
	S VL="                         "_"<"_VL_">" D ZPPDSP Q:verror 
	S VL=" " D ZPPDSP Q:verror 
	F  Q:'($$vFetch1())  D
	.	S VL="                         "_rs
	.	D ZPPDSP Q:verror 
	.	Q 
	S VL=" " D ZPPDSP Q:verror 
	Q 
	;
ZPPDSP	; Display line
	I VLC+2>IOSL D
	.	D VHDG0
	.	I VFMQ S verror=1
	.	Q 
	E  D VOM
	Q 
	; I18N=ON
	;
VP2	; Column pre-processor - Variable: ZLINK
	;
	S ZLINK="" S PREPP="" S ZLNKFLG=0
	I vc12="" Q 
	S ZLNKFLG=1 S verror=0
	D ZPNTLNK(vc12) Q:verror 
	D ZPNTLNK(vc13) Q:verror 
	D ZPNTLNK(vc14) Q:verror 
	D ZPNTLNK(vc15) Q:verror 
	D ZPNTLNK(vc16) Q:verror 
	D ZPNTLNK(vc17) Q:verror 
	D ZPNTLNK(vc18) Q:verror 
	D ZPNTLNK(vc19) Q:verror 
	D ZPNTLNK(vc20) Q:verror 
	D ZPNTLNK(vc21) Q:verror 
	D ZPNTLNK(vc22) Q:verror 
	D ZPNTLNK(vc23) Q:verror 
	D ZPNTLNK(vc24) Q:verror 
	D ZPNTLNK(vc25) Q:verror 
	D ZPNTLNK(vc26) Q:verror 
	D ZPNTLNK(vc27) Q:verror 
	D ZPNTLNK(vc28) Q:verror 
	D ZPNTLNK(vc29) Q:verror 
	D ZPNTLNK(vc30) Q:verror 
	D ZPNTLNK(vc31) Q:verror 
	D ZPNTLNK(vc32) Q:verror 
	D ZPNTLNK(vc33) Q:verror 
	D ZPNTLNK(vc34) Q:verror 
	D ZPNTLNK(vc35) Q:verror 
	D ZPNTLNK(vc36) Q:verror 
	D ZPNTLNK(vc37) Q:verror 
	D ZPNTLNK(vc38) Q:verror 
	D ZPNTLNK(vc39) Q:verror 
	S ZLINK=""
	Q 
ZPNTLNK(SID)	;
	N vpc
	Q:SID="" 
	N dbtbl2,vop1,vop2,vop3,vop4 S vop1="SYSDEV",vop2=SID,dbtbl2=$$vDb2("SYSDEV",SID,.vop3)
	 S vop4=$G(^DBTBL(vop1,2,vop2,0))
	S vpc=('$G(vop3)) Q:vpc 
	S VL="                         "_SID_$J("",20-$L(SID))_$P(vop4,$C(124),9)
	D ZPPDSP
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
	N vRs,vos1,vos2,vos3,vos4,vos5 S vRs=$$vOpen2()
	F  Q:'($$vFetch2())  D
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
vDbDe2()	; DELETE FROM TMPRPTBR WHERE JOBNO=:V1
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
	;
vDb2(v1,v2,v2out)	;	voXN = Db.getRecord(DBTBL2,,1,-2)
	;
	N dbtbl2
	S dbtbl2=$G(^DBTBL(v1,2,v2))
	I dbtbl2="",'$D(^DBTBL(v1,2,v2))
	S v2out='$T
	;
	Q dbtbl2
	;
vOpen0(exe,vsql,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist)	;	Dynamic MDB ResultSet
	;
	set sqlcur="V0.rwrs"
	N ER,vExpr,mode,RM,vTok S ER=0 ;=noOpti
	;
	S vExpr="SELECT "_vSelect_" FROM "_vFrom
	I vWhere'="" S vExpr=vExpr_" WHERE "_vWhere
	I vOrderby'="" S vExpr=vExpr_" ORDER BY "_vOrderby
	I vGroupby'="" S vExpr=vExpr_" GROUP BY "_vGroupby
	S vExpr=$$UNTOK^%ZS($$SQL^%ZS(vExpr,.vTok),vTok)
	;
	S sqlcur=$O(vobj(""),-1)+1
	;
	I $$FLT^SQLCACHE(vExpr,vTok,.vParlist)
	E  S vsql=$$OPEN^SQLM(.exe,vFrom,vSelect,vWhere,vOrderby,vGroupby,vParlist,,1,,sqlcur) I 'ER D SAV^SQLCACHE(vExpr,.vParlist)
	I ER S $ZS="-1,"_$ZPOS_",%PSL-E-SQLFAIL,"_$TR($G(RM),$C(10,44),$C(32,126)) X $ZT
	;
	S vos1=vsql
	Q ""
	;
vFetch0()	; MDB dynamic FETCH
	;
	; type public String exe(),sqlcur,vd,vi,vsql()
	;
	I vsql=0 Q 0
	S vsql=$$^SQLF(.exe,.vd,.vi,.sqlcur)
	S rwrs=vd
	S vos1=vsql
	S vos2=$G(vi)
	Q vsql
	;
vOpen1()	;	CODE FROM DBTBL2PP WHERE LIBS='SYSDEV' AND SID=:SID AND SEQ=0 AND PSEQ>:START AND PSEQ<:END ORDER BY PSEQ ASC
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(SID) I vos2="" G vL1a0
	S vos3=$G(START) I vos3="",'$D(START) G vL1a0
	S vos3=+vos3
	S vos4=$G(END) I vos4="",'$D(END) G vL1a0
	S vos4=+vos4
	S vos5=vos3
vL1a7	S vos5=$O(^DBTBL("SYSDEV",2,vos2,0,vos5),1) I vos5=""!(vos5'<vos4) G vL1a0
	Q
	;
vFetch1()	;
	;
	I vos1=1 D vL1a7
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos6=$G(^DBTBL("SYSDEV",2,vos2,0,vos5))
	S rs=$P(vos6,$C(12),1)
	;
	Q 1
	;
vOpen2()	;	JOBNO,LINENO,PAGENO,SEQ FROM TMPRPTBR WHERE JOBNO=:V1
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(V1) I vos2="" G vL2a0
	S vos3=""
vL2a3	S vos3=$O(^TMPRPTBR(vos2,vos3),1) I vos3="" G vL2a0
	S vos4=""
vL2a5	S vos4=$O(^TMPRPTBR(vos2,vos3,vos4),1) I vos4="" G vL2a3
	S vos5=""
vL2a7	S vos5=$O(^TMPRPTBR(vos2,vos3,vos4,vos5),1) I vos5="" G vL2a5
	Q
	;
vFetch2()	;
	;
	;
	I vos1=1 D vL2a7
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$$BYTECHAR^SQLUTL(254):"",1:vos3)_$C(9)_$S(vos4=$$BYTECHAR^SQLUTL(254):"",1:vos4)_$C(9)_$S(vos5=$$BYTECHAR^SQLUTL(254):"",1:vos5)
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
