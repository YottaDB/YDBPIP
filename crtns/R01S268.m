R01S268	; SCAER - Profile Error Report
	;
	; **** Routine compiled from DATA-QWIK Report SCAER ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 12/06/2007 16:14 - chenardp
	;
	 S ER=0
	N OLNTB
	N %READ N RID N RN N %TAB N VFMQ
	N DSPVAR S DSPVAR=0
	N MUMPS S MUMPS=0
	N VIN3 S VIN3="ALL"
	N VIN4 S VIN4="ALL"
	N VIN5 S VIN5="ALL"
	N VIN6 S VIN6="ALL"
	N VIN7 S VIN7="ALL"
	N VIN8 S VIN8="ALL"
	;
	S RID="SCAER"
	S RN="Profile Error Report"
	I $get(IO)="" S IO=$I
	;
	D INIT^%ZM()
	;
	D VPREBQ Q:$get(VFMQ)  ; Pre-processor (before query)
	;
	S %TAB("DSPVAR")="|1|||||||L|Display Variables|||||"
	S %TAB("IO")=$$IO^SCATAB
	S %TAB("MUMPS")="|1|||||||L|Display MUMPS Errors Only|||||"
	S %TAB("VIN3")="|255||[ERROR9]DATE|[ERROR9]DATE:DISTINCT:NOVAL||D EXT^DBSQRY||T|Calendar Date of Error|||||"
	S %TAB("VIN4")="|255||[ERROR9]ET|[ERROR9]ET:DISTINCT:NOVAL||D EXT^DBSQRY||T|Error Type Code|||||"
	S %TAB("VIN5")="|255||[ERROR9]SEQ|[ERROR9]SEQ:DISTINCT:NOVAL||D EXT^DBSQRY||T|Error Sequence Number|||||"
	S %TAB("VIN6")="|255||[ERROR]RTN|||D EXT^DBSQRY||T|Routine Name|||||"
	S %TAB("VIN7")="|255||[ERROR]TERM|||D EXT^DBSQRY||T|Terminal|||||"
	S %TAB("VIN8")="|255||[ERROR]MPSZTCOM|||D EXT^DBSQRY||T|Attached Comment|||||"
	;
	S %READ="IO/REQ,MUMPS#0,DSPVAR#0,VIN3#0,VIN4#0,VIN5#0,VIN6#0,VIN7#0,VIN8#0,"
	;
	; Skip device prompt option
	I $get(VRWOPT("NOOPEN")) S %READ="MUMPS#0,DSPVAR#0,VIN3#0,VIN4#0,VIN5#0,VIN6#0,VIN7#0,VIN8#0,"
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
	N %TIM N CONAM N RID N RN N VARH N VL N VLOF N VRF N VSTATS N vCOL N vHDG N vc1 N vc10 N vc11 N vc12 N vc13 N vc14 N vc15 N vc16 N vc17 N vc18 N vc19 N vc2 N vc20 N vc21 N vc22 N vc23 N vc24 N vc25 N vc3 N vc4 N vc5 N vc6 N vc7 N vc8 N vc9 N vovc1 N vovc2 N vovc3 N vovc4 N vrundate N vsysdate
	;
	N cuvar S cuvar=$$vDb2()
	 S cuvar=$G(^CUVAR("BANNER"))
	;
	S CONAM="Profile Framework"
	S ER=0 S RID="SCAER" S RN="Profile Error Report"
	S VL=""
	;
	USE 0 I '$get(VRWOPT("NOOPEN")) D  Q:ER 
	.	I '($get(VRWOPT("IOPAR"))="") S IOPAR=VRWOPT("IOPAR")
	.	E  I (($get(IOTYP)="RMS")!($get(IOTYP)="PNTQ")),('($get(IOPAR)["/OCHSET=")),$$VALID^%ZRTNS("UCIOENCD") D
	..		; Accept warning if ^UCIOENCD does not exist
	..		;    #ACCEPT Date=07/26/06; Pgm=RussellDS; CR=22121; Group=MISMATCH
	..		N CHRSET S CHRSET=$$^UCIOENCD("Report","SCAER","V0","*")
	..		I '(CHRSET="") S IOPAR=IOPAR_"/OCHSET="_CHRSET
	..		Q 
	.	D OPEN^SCAIO
	.	Q 
	S vcrt=(IOTYP="TRM")
	I 'vcrt S IOSL=60 ; Non-interactive
	E  D  ; Interactive
	.	D TERM^%ZUSE(IO,"WIDTH=81")
	.	WRITE $$CLEARXY^%TRMVT
	.	Q 
	;
	D INIT^%ZM()
	;
	S vCOL="[ERROR9]VAR#1#20,[ERROR9]VALUE#22#50"
	;
	; Build WHERE clause to use for dynamic query
	D
	.	N SEQ S SEQ=1
	.	N DQQRY N FROM
	.	I $get(VIN3)="" S VIN3="ALL"
	.	I VIN3'="ALL" S DQQRY(1)="[ERROR9]DATE "_VIN3 S SEQ=SEQ+1
	.	I $get(VIN4)="" S VIN4="ALL"
	.	I VIN4'="ALL" S DQQRY(SEQ)="[ERROR9]ET "_VIN4 S SEQ=SEQ+1
	.	I $get(VIN5)="" S VIN5="ALL"
	.	I VIN5'="ALL" S DQQRY(SEQ)="[ERROR9]SEQ "_VIN5 S SEQ=SEQ+1
	.	I $get(VIN6)="" S VIN6="ALL"
	.	I VIN6'="ALL" S DQQRY(SEQ)="[ERROR]RTN "_VIN6 S SEQ=SEQ+1
	.	I $get(VIN7)="" S VIN7="ALL"
	.	I VIN7'="ALL" S DQQRY(SEQ)="[ERROR]TERM "_VIN7 S SEQ=SEQ+1
	.	I $get(VIN8)="" S VIN8="ALL"
	.	I VIN8'="ALL" S DQQRY(SEQ)="[ERROR]MPSZTCOM "_VIN8 S SEQ=SEQ+1
	.	S DQQRY(SEQ)="(<<MUMPS>>=1 AND [ERROR]MUMPSZE'="""") OR <<MUMPS>>=0" S SEQ=SEQ+1
	.	S DQQRY(SEQ)="[ERROR]JOB'=""""" S SEQ=SEQ+1
	.	S FROM=$$DQJOIN^SQLCONV("ERROR9,ERROR") Q:ER 
	.	S VWHERE=$$WHERE^SQLCONV(.DQQRY,"")
	.	Q 
	;
	; Print Report Banner Page
	I $P(cuvar,$C(124),1),'$get(VRWOPT("NOBANNER")),IOTYP'="TRM",'$get(AUXPTR) D
	.	N VBNRINFO
	.	;
	.	S VBNRINFO("PROMPTS",3)="WC2|"_"Calendar Date of Error"_"|VIN3|"_$get(VIN3)
	.	S VBNRINFO("PROMPTS",4)="WC2|"_"Error Type Code"_"|VIN4|"_$get(VIN4)
	.	S VBNRINFO("PROMPTS",5)="WC2|"_"Error Sequence Number"_"|VIN5|"_$get(VIN5)
	.	S VBNRINFO("PROMPTS",6)="WC2|"_"Routine Name"_"|VIN6|"_$get(VIN6)
	.	S VBNRINFO("PROMPTS",7)="WC2|"_"Terminal"_"|VIN7|"_$get(VIN7)
	.	S VBNRINFO("PROMPTS",8)="WC2|"_"Attached Comment"_"|VIN8|"_$get(VIN8)
	.	;
	.	D
	..		N SEQ
	..		N VALUE N VAR N X
	..		S X=VWHERE
	..		S SEQ=""
	..		F  S SEQ=$order(VBNRINFO("PROMPTS",SEQ)) Q:SEQ=""  D
	...			S VAR=$piece(VBNRINFO("PROMPTS",SEQ),"|",3)
	...			S VALUE=$piece(VBNRINFO("PROMPTS",SEQ),"|",4,99)
	...			S X=$$replace^DBSRWUTL(X,":"_VAR,"'"_VALUE_"'")
	...			Q 
	..		S VBNRINFO("WHERE")=X
	..		Q 
	.	;
	.	S VBNRINFO("DESC")="Profile Error Report"
	.	S VBNRINFO("PGM")="R01S268"
	.	S VBNRINFO("RID")="SCAER"
	.	S VBNRINFO("TABLES")="ERROR9,ERROR"
	.	;
	.	S VBNRINFO("ORDERBY",1)="[SYSDEV,ERROR9]DATE"
	.	S VBNRINFO("ORDERBY",2)="[SYSDEV,ERROR9]ET"
	.	S VBNRINFO("ORDERBY",3)="[SYSDEV,ERROR9]SEQ"
	.	S VBNRINFO("ORDERBY",4)="[SYSDEV,ERROR9]9"
	.	S VBNRINFO("ORDERBY",5)="[SYSDEV,ERROR9]VAR"
	.	;
	.	D ^DBSRWBNR(IO,.VBNRINFO) ; Print banner
	.	Q 
	;
	; Initialize variables
	S (vc1,vc2,vc3,vc4,vc5,vc6,vc7,vc8,vc9,vc10,vc11,vc12,vc13,vc14,vc15,vc16,vc17,vc18,vc19,vc20,vc21,vc22,vc23,vc24,vc25)=""
	S (VFMQ,vlc,VLC,VOFFLG,VPN,VRG)=0
	S VNEWHDR=1
	S VLOF=""
	S %TIM=$$TIM^%ZM
	S vrundate=$$vdat2str($P($H,",",1),"MM/DD/YEAR") S vsysdate=$S(TJD'="":$ZD(TJD,"MM/DD/YEAR"),1:"")
	;
	D
	.	N I N J N K
	.	F I=0:1:5 D
	..		S (vh(I),VD(I))=0 S vs(I)=1 ; Group break flags
	..		S VT(I)=0 ; Group count
	..		F J=1:1:0 D
	...			F K=1:1:3 S VT(I,J,K)="" ; Initialize function stats
	...			Q 
	..		Q 
	.	Q 
	;
	 N V1 S V1=$J D vDbDe1() ; Report browser data
	I $get(VDISTKEY)="" D  Q:VFMQ  ; Report Pre-processor (after query)
	.	D VPREAQ
	.	I VFMQ S vh(0)=1 D VEXIT(0)
	.	Q 
	;
	S vh(0)=0
	;
	; Run report directly
	D VINILAST
	;
	;  #ACCEPT DATE=12/06/2007;PGM=Report Writer Generator;CR=20967
	N rwrs,vos1,vos2,sqlcur,exe,sqlcur,vd,vi,vsql,vsub S rwrs=$$vOpen0(.exe,.vsql,"ERROR9.DATE,ERROR9.ET,ERROR9.SEQ,ERROR9.VAR,ERROR.SEQ,ERROR.DATE,ERROR.MUMPSZE,ERROR.TERM,ERROR.JOB,ERROR.MUMPSZA,ERROR.TIME,ERROR.UID,ERROR.MUMPSZB,ERROR.LSTDATE,ERROR.DIR,ERROR.MUMPSZS,ERROR.MPSZTCOM,ERROR.ELN1,ERROR.ELN2,ERROR.ELN3,ERROR.ELN4,ERROR.ELN5,ERROR.ELN6,ERROR.ELN7,ERROR9.VALUE","ERROR9,ERROR",VWHERE,"ERROR9.DATE,ERROR9.ET,ERROR9.SEQ,ERROR9.VAR","","/DQMODE=1")
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
	S vovc1="" S vovc2="" S vovc3="" S vovc4=""
	Q 
	;
VSAVLAST	; Save last access keys values
	S vovc1=vc1 S vovc2=vc2 S vovc3=vc3 S vovc4=vc4
	Q 
	;
VGETDATA(V,VI)	;
	S vc1=$piece(V,$char(9),1) ; ERROR9.DATE
	S vc2=$piece(V,$char(9),2) ; ERROR9.ET
	S vc3=$piece(V,$char(9),3) ; ERROR9.SEQ
	S vc4=$piece(V,$char(9),4) ; ERROR9.VAR
	S vc5=$piece(V,$char(9),5) ; ERROR.SEQ
	S vc6=$piece(V,$char(9),6) ; ERROR.DATE
	S vc7=$piece(V,$char(9),7) ; ERROR.MUMPSZE
	S vc8=$piece(V,$char(9),8) ; ERROR.TERM
	S vc9=$piece(V,$char(9),9) ; ERROR.JOB
	S vc10=$piece(V,$char(9),10) ; ERROR.MUMPSZA
	S vc11=$piece(V,$char(9),11) ; ERROR.TIME
	S vc12=$piece(V,$char(9),12) ; ERROR.UID
	S vc13=$piece(V,$char(9),13) ; ERROR.MUMPSZB
	S vc14=$piece(V,$char(9),14) ; ERROR.LSTDATE
	S vc15=$piece(V,$char(9),15) ; ERROR.DIR
	S vc16=$piece(V,$char(9),16) ; ERROR.MUMPSZS
	S vc17=$piece(V,$char(9),17) ; ERROR.MPSZTCOM
	S vc18=$piece(V,$char(9),18) ; ERROR.ELN1
	S vc19=$piece(V,$char(9),19) ; ERROR.ELN2
	S vc20=$piece(V,$char(9),20) ; ERROR.ELN3
	S vc21=$piece(V,$char(9),21) ; ERROR.ELN4
	S vc22=$piece(V,$char(9),22) ; ERROR.ELN5
	S vc23=$piece(V,$char(9),23) ; ERROR.ELN6
	S vc24=$piece(V,$char(9),24) ; ERROR.ELN7
	S vc25=$piece(V,$char(9),25) ; ERROR9.VALUE
	Q 
	;
	; User-defined pre/post-processor code
	;
VPREAQ	; Pre-processor (after query)
	;
	S VARH=$S(DSPVAR:"Variables:",1:"")
	Q 
	;
VPREBQ	; Pre-processor (before query)
	;
	;Incoming=SCAER
	Q 
	;
VRPOST	; Report post-processor
	;
	I $D(SCAER) S VFMQ=1 ; External call
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
	S vs(1)=0 S vs(2)=0 S vs(3)=0 S vs(4)=0 S vs(5)=0
	I 'VFMQ D VSUM
	I 'vh(0) D VHDG0
	I 'VFMQ D
	.	; No information available to display
	.	I NOINFO=1 S VL=$$^MSG(4655) D VOM
	.	I vcrt S VL="" F z=VLC+1:1:IOSL D VOM
	.	;
	.	I '($D(VTBLNAM)#2) D
	..		S vs(2)=0
	..		D VRPOST ; Report Post-Processor
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
	I $get(VRWOPT("NODTL")) S vskp(1)=1 S vskp(2)=1 S vskp(3)=1 S vskp(4)=1 S vskp(5)=1 ; Skip detail
	D VBREAK
	D VSUM Q:VFMQ 
	;
	I $get(VH0) S vh(0)=0 S VNEWHDR=1 K VH0 ; Page Break
	I 'vh(0) D VHDG0 Q:VFMQ 
	I '$get(vskp(3)) D VDTL3 Q:VFMQ 
	I '$get(vskp(5)) D VDTL5 Q:VFMQ 
	D VSTAT
	Q 
	;
VBREAK	;
	Q:'VT(5) 
	N vb1 N vb2 N vb3 N vb4 N vb5
	S (vb1,vb2,vb3,vb4,vb5)=0
	I 0!(vovc1'=vc1) S vs(2)=0 S vh(2)=0 S VD(1)=0 S vb2=1 S vb3=1 S vb4=1 S vb5=1
	I vb2!(vovc2'=vc2) S vs(3)=0 S vh(3)=0 S VD(2)=0 S vb3=1 S vb4=1 S vb5=1
	I vb3!(+vovc3'=+vc3) S vs(5)=0 S vh(5)=0 S VD(3)=0 S vb4=1 S vb5=1
	Q 
	;
VSUM	; Report Group Summary
	I 'vs(5) S vs(5)=1 D stat^DBSRWUTL(5)
	I 'vs(4) S vs(4)=1 D stat^DBSRWUTL(4)
	I 'vs(3) S vs(3)=1 D stat^DBSRWUTL(3)
	I 'vs(2) S vs(2)=1 D stat^DBSRWUTL(2)
	Q 
	;
VSTAT	; Data field statistics
	;
	S VT(5)=VT(5)+1
	Q 
	;
VDTL3	; Detail
	;
	Q:VD(3)  S VD(3)=1 ; Print flag
	I VLC+4>IOSL D VHDG0 Q:VFMQ 
	;
	S VL="   "_"Sequence:"
	S VL=VL_$J("",13-12)_$E(vc5,1,20)
	I VLC+4>IOSL D VHDG0 Q:VFMQ 
	D VOM
	I VLC+4>IOSL D VHDG0 Q:VFMQ 
	D VOM
	S VL="  "_$J($S(vc6'="":$ZD(vc6,"MM/DD/YEAR"),1:""),10)
	S V=vc7 S VO=V S V=$E(V,1,35) D VP1 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",13-$L(VL))_V ; [SYSDEV,ERROR]MUMPSZE
	S VL=VL_$J("",49-$L(VL))_$E(vc8,1,9)
	S VL=VL_$J("",59-$L(VL))_$E(vc9,1,7)
	S VL=VL_$J("",70-$L(VL))_$E(vc10,1,10)
	I VLC+4>IOSL D VHDG0 Q:VFMQ 
	D VOM
	S VL="    "_$J($$TIM^%ZM(vc11),8)
	S VL=VL_$J("",49-$L(VL))_$E(vc12,1,20)
	S VL=VL_$J("",70-$L(VL))_$E(vc13,1,10)
	I VLC+4>IOSL D VHDG0 Q:VFMQ 
	D VOM
	S V=vc14 S VO=V D VP2 Q:VFMQ!$get(verror)  S V=$E(V,1,10) S VL="                                                "_V
	S V=vc15 S VO=V S V=$E(V,1,9) D VP3 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",59-$L(VL))_V ; [SYSDEV,ERROR]DIR
	S VL=VL_$J("",70-$L(VL))_$E(vc16,1,7)
	I VLC+4>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S V=vc17 S VO=V S V=$E(V,1,60) D VP4 Q:VFMQ!$get(verror)  S VL="             "_V
	I VLC+4>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	I VLC+4>IOSL D VHDG0 Q:VFMQ 
	D VOM
	S V=vc18 S VO=V S V=$E(V,1,75) D VP5 Q:VFMQ!$get(verror)  S VL="    "_V
	I VLC+4>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="    "_$E(vc19,1,75)
	I VLC+4>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="    "_$E(vc20,1,75)
	I VLC+4>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="    "_$E(vc21,1,75)
	I VLC+4>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="    "_$E(vc22,1,75)
	I VLC+4>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="    "_$E(vc23,1,75)
	I VLC+4>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="    "_$E(vc24,1,75)
	I VLC+4>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	I VLC+4>IOSL D VHDG0 Q:VFMQ 
	D VOM
	S VL="    "_$E(VARH,1)
	I VLC+4>IOSL D VHDG0 Q:VFMQ 
	D VOM
	Q 
	;
VDTL5	; Detail
	;
	I VLC+1>IOSL D VHDG0 Q:VFMQ 
	;
	S V=vc4 S VO=V S V=$E(V,1,20) D VP6 Q:VFMQ!$get(verror)  S VL=V
	S V=vc25 S VO=V S V=$E(V,1,50) D VP7 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",21-$L(VL))_V ; [SYSDEV,ERROR9]VALUE
	I '($translate(VL," ")="") D VOM
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
	.	E  S VLC=VLC+7 S VPN=VPN+1
	.	Q 
	;
	S ER=0 S VPN=VPN+1 S VLC=0
	;
	S VL=$E(CONAM,1,40)
	S VL=VL_$J("",46-$L(VL))_"Run Date:"
	S VL=VL_$J("",56-$L(VL))_$E(vrundate,1,10)
	S VL=VL_$J("",70-$L(VL))_$E(%TIM,1,8)
	D VOM
	S VL="Profile Error Report                                                  Page:"
	S VL=VL_$J("",76-75)_$E(($J(VPN,3)),1,3)
	D VOM
	D VOM
	S VL="    "_"Date     Error                               Device    Job        $ZA"
	D VOM
	S VL="    "_"Time                                         User ID              $ZB"
	D VOM
	S VL="                                                 "_"Last Mod  Directory  $ZS"
	D VOM
	S VL="================================================================================"
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
VP1	; Column post-processor - [SYSDEV,ERROR]MUMPSZE
	;
	I V="" S V=vc2
	Q 
	;
VP2	; Column pre-processor - [SYSDEV,ERROR]LSTDATE
	;
	; If not a date, ignore it
	I V'?1.2N1"/"1.2N1"/"1.4N S V=""
	Q 
	;
VP3	; Column post-processor - [SYSDEV,ERROR]DIR
	;
	I V["[" S V=$piece($piece(V,"]",1),"[",2)
	Q 
	;
VP4	; Column post-processor - [SYSDEV,ERROR]MPSZTCOM
	;
	; Comment: ~p1
	I V'="" S V=$$^MSG(6690,V)
	Q 
	;
VP5	; Column post-processor - [SYSDEV,ERROR]ELN1
	;
	I V="?" S V=""
	Q 
	;
VP6	; Column post-processor - [SYSDEV,ERROR9]VAR
	;
	I 'DSPVAR S V=""
	E  S V=$J(VO,20)_"="
	Q 
	;
VP7	; Column post-processor - [SYSDEV,ERROR9]VALUE
	;
	I 'DSPVAR S V=""
	E  S V=$$TRCTRL^SCAER(VO)
	I $L(V)>480 S V=$E(V,1,480)_"..."
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
	N vRs,vos1,vos2,vos3,vos4,vos5 S vRs=$$vOpen1()
	F  Q:'($$vFetch1())  D
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
	;
vDb2()	;	voXN = Db.getRecord(CUVAR,,0)
	;
	I '$D(^CUVAR)
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,CUVAR" X $ZT
	Q ""
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
vOpen1()	;	JOBNO,LINENO,PAGENO,SEQ FROM TMPRPTBR WHERE JOBNO=:V1
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(V1) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^TMPRPTBR(vos2,vos3),1) I vos3="" G vL1a0
	S vos4=""
vL1a5	S vos4=$O(^TMPRPTBR(vos2,vos3,vos4),1) I vos4="" G vL1a3
	S vos5=""
vL1a7	S vos5=$O(^TMPRPTBR(vos2,vos3,vos4,vos5),1) I vos5="" G vL1a5
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a7
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)_$C(9)_$S(vos5=$C(254):"",1:vos5)
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
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)_$C(9)_$S(vos5=$C(254):"",1:vos5)
	;
	Q 1
