R01S220	; DBSMDDLST - Master Data Dictionary Listing
	;
	; **** Routine compiled from DATA-QWIK Report DBSMDDLST ****
	;
	; 09/14/2007 09:23 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/14/2007 09:23 - chenardp
	;
	 S ER=0
	N OLNTB
	N %READ N RID N RN N %TAB N VFMQ
	N VERIFY
	N VIN3 S VIN3="ALL"
	N VIN4 S VIN4="ALL"
	;
	S RID="DBSMDDLST"
	S RN="Master Data Dictionary Listing"
	I $get(IO)="" S IO=$I
	;
	D INIT^%ZM()
	;
	S %TAB("IO")=$$IO^SCATAB
	S %TAB("VERIFY")="|1|||||||L|Verification Report Only|||||"
	S %TAB("VIN3")="|255||[DBTBL1D]MDDFID|[DBTBL1D]MDDFID:DISTINCT:QU ""[DBTBL1D]%LIBS=""SYSDEV""""||D EXT^DBSQRY||T|MDD Name|||||"
	S %TAB("VIN4")="|255||[DBTBL1D]MDD|||D EXT^DBSQRY||T|Master Dictionary Reference|||||"
	;
	S %READ="IO/REQ,VERIFY#0,VIN3#0,VIN4#0,"
	;
	; Skip device prompt option
	I $get(VRWOPT("NOOPEN")) S %READ="VERIFY#0,VIN3#0,VIN4#0,"
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
	N %TIM N CONAM N MDDDEC N MDDDESC N MDDFDES N MDDLEN N MDDTYPE N RID N RN N VERCNT N VL N VLOF N VRF N VSTATS N vCOL N vHDG N vc1 N vc2 N vc3 N vc4 N vc5 N vc6 N vc7 N vc8 N vc9 N verify N vovc1 N vovc2 N vovc3 N vovc4 N vovc5 N vrundate N vsysdate
	;
	N cuvar S cuvar=$$vDb4()
	 S cuvar=$G(^CUVAR("BANNER"))
	;
	S CONAM="DATA-QWIK 7.2"
	S ER=0 S RID="DBSMDDLST" S RN="Master Data Dictionary Listing"
	S VL=""
	;
	USE 0 I '$get(VRWOPT("NOOPEN")) D  Q:ER 
	.	I '($get(VRWOPT("IOPAR"))="") S IOPAR=VRWOPT("IOPAR")
	.	E  I (($get(IOTYP)="RMS")!($get(IOTYP)="PNTQ")),('($get(IOPAR)["/OCHSET=")),$$VALID^%ZRTNS("UCIOENCD") D
	..		; Accept warning if ^UCIOENCD does not exist
	..		;    #ACCEPT Date=07/26/06; Pgm=RussellDS; CR=22121; Group=MISMATCH
	..		N CHRSET S CHRSET=$$^UCIOENCD("Report","DBSMDDLST","V0","*")
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
	S vCOL="[DBTBL1D]FID#3#25,[DBTBL1D]DI#30#20,[DBTBL1D]DES#51#40,[DBTBL1D]TYP#94#1,[DBTBL1D]LEN#98#4,[DBTBL1D]DEC#108#2"
	;
	; Build WHERE clause to use for dynamic query
	D
	.	N SEQ S SEQ=1
	.	N DQQRY N FROM
	.	S DQQRY(1)="[DBTBL1D]%LIBS = ""SYSDEV""" S SEQ=SEQ+1
	.	I $get(VIN3)="" S VIN3="ALL"
	.	I VIN3'="ALL" S DQQRY(2)="[DBTBL1D]MDDFID "_VIN3 S SEQ=SEQ+1
	.	I $get(VIN4)="" S VIN4="ALL"
	.	I VIN4'="ALL" S DQQRY(SEQ)="[DBTBL1D]MDD "_VIN4 S SEQ=SEQ+1
	.	S DQQRY(SEQ)="[DBTBL1D]MDDFID '= """"" S SEQ=SEQ+1
	.	S DQQRY(SEQ)="[DBTBL1D]MDD '= """"" S SEQ=SEQ+1
	.	S FROM=$$DQJOIN^SQLCONV("DBTBL1D") Q:ER 
	.	S VWHERE=$$WHERE^SQLCONV(.DQQRY,"")
	.	Q 
	;
	; Print Report Banner Page
	I $P(cuvar,$C(124),1),'$get(VRWOPT("NOBANNER")),IOTYP'="TRM",'$get(AUXPTR) D
	.	N VBNRINFO
	.	;
	.	S VBNRINFO("PROMPTS",3)="WC2|"_"MDD Name"_"|VIN3|"_$get(VIN3)
	.	S VBNRINFO("PROMPTS",4)="WC2|"_"Master Dictionary Reference"_"|VIN4|"_$get(VIN4)
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
	.	S VBNRINFO("DESC")="Master Data Dictionary Listing"
	.	S VBNRINFO("PGM")="R01S220"
	.	S VBNRINFO("RID")="DBSMDDLST"
	.	S VBNRINFO("TABLES")="DBTBL1D"
	.	;
	.	S VBNRINFO("ORDERBY",1)="[SYSDEV,DBTBL1D]%LIBS"
	.	S VBNRINFO("ORDERBY",2)="[SYSDEV,DBTBL1D]""MDD"""
	.	S VBNRINFO("ORDERBY",3)="[SYSDEV,DBTBL1D]MDDFID"
	.	S VBNRINFO("ORDERBY",4)="[SYSDEV,DBTBL1D]MDD"
	.	S VBNRINFO("ORDERBY",5)="[SYSDEV,DBTBL1D]FID"
	.	S VBNRINFO("ORDERBY",6)="[SYSDEV,DBTBL1D]DI"
	.	;
	.	S VBNRINFO("DOC",1)="The DBSMDDLST report lists all data items linked to (or referencing) the data"
	.	S VBNRINFO("DOC",2)="items in the master data dictionary."
	.	;
	.	D ^DBSRWBNR(IO,.VBNRINFO) ; Print banner
	.	Q 
	;
	; Initialize variables
	S (vc1,vc2,vc3,vc4,vc5,vc6,vc7,vc8,vc9)=""
	S (VFMQ,vlc,VLC,VOFFLG,VPN,VRG)=0
	S VNEWHDR=1
	S VLOF=""
	S %TIM=$$TIM^%ZM
	S vrundate=$$vdat2str($P($H,",",1),"MM/DD/YEAR") S vsysdate=$S(TJD'="":$ZD(TJD,"MM/DD/YEAR"),1:"")
	;
	D
	.	N I N J N K
	.	F I=0:1:6 D
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
	;  #ACCEPT DATE=09/14/2007;PGM=Report Writer Generator;CR=20967
	N rwrs,vos1,vos2,sqlcur,exe,sqlcur,vd,vi,vsql,vsub S rwrs=$$vOpen0(.exe,.vsql,"DBTBL1D.%LIBS,DBTBL1D.MDDFID,DBTBL1D.MDD,DBTBL1D.FID,DBTBL1D.DI,DBTBL1D.DES,DBTBL1D.TYP,DBTBL1D.LEN,DBTBL1D.DEC","DBTBL1D",VWHERE,"DBTBL1D.%LIBS,DBTBL1D.MDDFID,DBTBL1D.MDD,DBTBL1D.FID,DBTBL1D.DI","","/DQMODE=1")
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
	S vovc1="" S vovc2="" S vovc3="" S vovc4="" S vovc5=""
	Q 
	;
VSAVLAST	; Save last access keys values
	S vovc1=vc1 S vovc2=vc2 S vovc3=vc3 S vovc4=vc4 S vovc5=vc5
	Q 
	;
VGETDATA(V,VI)	;
	S vc1=$piece(V,$char(9),1) ; DBTBL1D.%LIBS
	S vc2=$piece(V,$char(9),2) ; DBTBL1D.MDDFID
	S vc3=$piece(V,$char(9),3) ; DBTBL1D.MDD
	S vc4=$piece(V,$char(9),4) ; DBTBL1D.FID
	S vc5=$piece(V,$char(9),5) ; DBTBL1D.DI
	S vc6=$piece(V,$char(9),6) ; DBTBL1D.DES
	S vc7=$piece(V,$char(9),7) ; DBTBL1D.TYP
	S vc8=$piece(V,$char(9),8) ; DBTBL1D.LEN
	S vc9=$piece(V,$char(9),9) ; DBTBL1D.DEC
	Q 
	;
	; User-defined pre/post-processor code
	;
VPREAQ	; Pre-processor (after query)
	;
	S VERCNT=0
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
	S vs(1)=0 S vs(2)=0 S vs(3)=0 S vs(4)=0 S vs(5)=0 S vs(6)=0
	I 'VFMQ D VSUM
	I 'VFMQ D VRSUM
	I 'VFMQ D
	.	; No information available to display
	.	I NOINFO=1 S VL=$$^MSG(4655) D VOM
	.	I vcrt S VL="" F z=VLC+1:1:IOSL D VOM
	.	;
	.	I '($D(VTBLNAM)#2) D
	..		S vs(2)=0
	..		D VBREAK D stat^DBSRWUTL(2)
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
	I $get(VRWOPT("NODTL")) S vskp(1)=1 S vskp(2)=1 S vskp(3)=1 S vskp(4)=1 S vskp(5)=1 S vskp(6)=1 ; Skip detail
	D VBREAK
	D VSUM Q:VFMQ 
	;
	I $get(VH0) S vh(0)=0 S VNEWHDR=1 K VH0 ; Page Break
	I 'vh(0) D VHDG0 Q:VFMQ 
	D VHDG5 Q:VFMQ 
	I '$get(vskp(6)) D VDTL6 Q:VFMQ 
	D VSTAT
	Q 
	;
VBREAK	;
	Q:'VT(6) 
	N vb1 N vb2 N vb3 N vb4 N vb5 N vb6
	S (vb1,vb2,vb3,vb4,vb5,vb6)=0
	I 0!(vovc1'=vc1) S vs(3)=0 S vh(3)=0 S VD(1)=0 S vb2=1 S vb3=1 S vb4=1 S vb5=1 S vb6=1 S VH0=1
	I vb3!(vovc2'=vc2) S vs(4)=0 S vh(4)=0 S VD(3)=0 S vb4=1 S vb5=1 S vb6=1 S VH0=1
	I vb4!(vovc3'=vc3) S vs(5)=0 S vh(5)=0 S VD(4)=0 S vb5=1 S vb6=1
	I vb5!(vovc4'=vc4) S vs(6)=0 S vh(6)=0 S VD(5)=0 S vb6=1
	Q 
	;
VSUM	; Report Group Summary
	I 'vs(6) S vs(6)=1 D stat^DBSRWUTL(6)
	I 'vs(5) S vs(5)=1 D stat^DBSRWUTL(5)
	I 'vs(4) S vs(4)=1 D stat^DBSRWUTL(4)
	I 'vs(3) S vs(3)=1 D stat^DBSRWUTL(3)
	I 'vs(2) S vs(2)=1 D stat^DBSRWUTL(2)
	Q 
	;
VSTAT	; Data field statistics
	;
	S VT(6)=VT(6)+1
	Q 
	;
VHDG5	; Group Header
	;
	Q:vh(5)  S vh(5)=1 ; Print flag
	I VLC+3>IOSL D VHDG0 Q:VFMQ 
	;
	S VL="" D VOM
	S VL="      "_$E(vc3,1,12)
	D VP1 Q:VFMQ!$get(verror)  S V=$E(MDDDESC,1,40)
	S VL=VL_$J("",50-$L(VL))_V
	S VL=VL_$J("",93-$L(VL))_$E(MDDTYPE,1)
	S VL=VL_$J("",97-$L(VL))_$J(MDDLEN,4)
	S VL=VL_$J("",107-$L(VL))_$J(MDDDEC,2)
	D VOM
	S VL="" D VOM
	Q 
	;
VDTL6	; Detail
	;
	I VLC+1>IOSL D VHDG0 Q:VFMQ 
	;
	S VL="  "_$E(vc4,1,25)
	S VL=VL_$J("",29-$L(VL))_$E(vc5,1,20)
	S VL=VL_$J("",50-$L(VL))_$E(vc6,1,40)
	S VL=VL_$J("",93-$L(VL))_$E(vc7,1)
	S VL=VL_$J("",97-$L(VL))_$J(vc8,4)
	S VL=VL_$J("",107-$L(VL))_$J(vc9,2)
	D VP2 Q:VFMQ!$get(verror)  S V=$E(verify,1)
	S VL=VL_$J("",114-$L(VL))_V
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
	.	E  S VLC=VLC+8 S VPN=VPN+1
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
	S VL=VL_$J("",128-$L(VL))_$J(VPN,3)
	D VOM
	S VL="" D VOM
	S VL=" "_"MDD Name:"
	S VL=VL_$J("",12-10)_$E(vc2,1,12)
	D VP3 Q:VFMQ!$get(verror)  S V=$E(MDDFDES,1,40)
	S VL=VL_$J("",27-$L(VL))_V
	D VOM
	S VL="" D VOM
	S VL="      "_"MDD Reference"
	D VOM
	S VL="  "_"File Name                  Data Item            Description                             Type  Length    Dec     Error Flag"
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
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	;
	S VL="" D VOM
	S VL="                                                                                      "_"Total Verification Errors: "
	S VL=VL_$J("",114-113)_$J(VERCNT,5)
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
VP1	; Column pre-processor - Variable: MDDDESC
	;
	N MDD N MDDFID
	;
	S MDD=vc3
	S MDDFID=vc2
	;
	N dbtbl1d S dbtbl1d=$G(^DBTBL("SYSDEV",1,MDDFID,9,MDD))
	;
	S MDDDEC=$P(dbtbl1d,$C(124),14)
	S MDDDESC=$P(dbtbl1d,$C(124),10)
	S MDDLEN=$P(dbtbl1d,$C(124),2)
	S MDDTYPE=$P(dbtbl1d,$C(124),9)
	;
	Q 
	;
VP2	; Column pre-processor - Variable: verify
	;
	S verify="*"
	I MDDDESC=vc6,MDDLEN=vc8,MDDTYPE=vc7,MDDDEC=vc9 D
	.	S verify=""
	.	I $get(VERIFY) S VL="" ; Suppress print line
	.	Q 
	E  D
	.	;
	.	S verify="*"
	.	S VERCNT=VERCNT+1
	.	Q 
	;
	Q 
	;
VP3	; Column pre-processor - Variable: MDDFDES
	;
	N MDDFID
	;
	S MDDFID=vc2
	;
	N dbtbl1 S dbtbl1=$G(^DBTBL("SYSDEV",1,MDDFID))
	;
	S MDDFDES=$P(dbtbl1,$C(124),1)
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
vDb4()	;	voXN = Db.getRecord(CUVAR,,0)
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
	S vRs=vos2_$C(9)_$S(vos3=$$BYTECHAR^SQLUTL(254):"",1:vos3)_$C(9)_$S(vos4=$$BYTECHAR^SQLUTL(254):"",1:vos4)_$C(9)_$S(vos5=$$BYTECHAR^SQLUTL(254):"",1:vos5)
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
