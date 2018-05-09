R01S252	; DBSQRPLST - QWIK Report Definition Listing
	;
	; **** Routine compiled from DATA-QWIK Report DBSQRPLST ****
	;
	; 09/14/2007 10:49 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/14/2007 10:49 - chenardp
	;
	 S ER=0
	N OLNTB
	N %READ N RID N RN N %TAB N VFMQ
	;
	S RID="DBSQRPLST"
	S RN="QWIK Report Definition Listing"
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
	N %TIM N CONAM N RID N RN N VL N VLOF N VRF N VSTATS N ZFORMAT N ZSTAT N vCOL N vHDG N vc1 N vc10 N vc11 N vc12 N vc13 N vc14 N vc15 N vc16 N vc17 N vc18 N vc19 N vc2 N vc20 N vc21 N vc22 N vc23 N vc24 N vc25 N vc26 N vc27 N vc28 N vc29 N vc3 N vc30 N vc4 N vc5 N vc6 N vc7 N vc8 N vc9 N vovc1 N vovc2 N vrundate N vsysdate
	;
	S CONAM="DATA-QWIK 7.2"
	S ER=0 S RID="DBSQRPLST" S RN="QWIK Report Definition Listing"
	S VL=""
	;
	USE 0 I '$get(VRWOPT("NOOPEN")) D  Q:ER 
	.	I '($get(VRWOPT("IOPAR"))="") S IOPAR=VRWOPT("IOPAR")
	.	E  I (($get(IOTYP)="RMS")!($get(IOTYP)="PNTQ")),('($get(IOPAR)["/OCHSET=")),$$VALID^%ZRTNS("UCIOENCD") D
	..		; Accept warning if ^UCIOENCD does not exist
	..		;    #ACCEPT Date=07/26/06; Pgm=RussellDS; CR=22121; Group=MISMATCH
	..		N CHRSET S CHRSET=$$^UCIOENCD("Report","DBSQRPLST","V0","*")
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
	; Initialize variables
	S (vc1,vc2,vc3,vc4,vc5,vc6,vc7,vc8,vc9,vc10,vc11,vc12,vc13,vc14,vc15,vc16,vc17,vc18,vc19,vc20,vc21,vc22,vc23,vc24,vc25,vc26,vc27,vc28,vc29,vc30)=""
	S (VFMQ,vlc,VLC,VOFFLG,VPN,VRG)=0
	S VNEWHDR=1
	S VLOF=""
	S %TIM=$$TIM^%ZM
	S vrundate=$$vdat2str($P($H,",",1),"MM/DD/YEAR") S vsysdate=$S(TJD'="":$ZD(TJD,"MM/DD/YEAR"),1:"")
	;
	D
	.	N I N J N K
	.	F I=0:1:2 D
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
	N rwrs,vos1,vos2,vos3,vos4,vos5,vos20,vos21,vos22,vos7,vos8,vos9,vos10,vos11,vos12,vos13,vos14,vos15,vos16,vos23,vos6,vos17,vos18,vos19,vOid  N V2 S V2=$J S rwrs=$$vOpen1()
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
	S vovc1="" S vovc2=""
	Q 
	;
VSAVLAST	; Save last access keys values
	S vovc1=vc1 S vovc2=vc2
	Q 
	;
VGETDATA(V,VI)	;
	S vc1=$piece(V,$char(9),1) ; DBTBL5Q.LIBS
	S vc2=$piece(V,$char(9),2) ; DBTBL5Q.QRID
	S vc3=$piece(V,$char(9),3) ; DBTBL5Q.DESC
	S vc4=$piece(V,$char(9),4) ; DBTBL5Q.UID
	S vc5=$piece(V,$char(9),5) ; DBTBL5Q.LTD
	S vc6=$piece(V,$char(9),6) ; DBTBL5Q.PGM
	S vc7=$piece(V,$char(9),7) ; DBTBL5Q.TRANS
	S vc8=$piece(V,$char(9),8) ; DBTBL5Q.PFID
	S vc9=$piece(V,$char(9),9) ; DBTBL5Q.DTL
	S vc10=$piece(V,$char(9),10) ; DBTBL5Q.BANNER
	S vc11=$piece(V,$char(9),11) ; DBTBL5Q.STAT
	S vc12=$piece(V,$char(9),12) ; DBTBL5Q.MSQL
	S vc13=$piece(V,$char(9),13) ; DBTBL5Q.CSCMP
	S vc14=$piece(V,$char(9),14) ; DBTBL5Q.ORDERBY
	S vc15=$piece(V,$char(9),15) ; DBTBL5Q.BREAKON
	S vc16=$piece(V,$char(9),16) ; DBTBL5Q.FLD1
	S vc17=$piece(V,$char(9),17) ; DBTBL5Q.FLD2
	S vc18=$piece(V,$char(9),18) ; DBTBL5Q.FLD3
	S vc19=$piece(V,$char(9),19) ; DBTBL5Q.FLD4
	S vc20=$piece(V,$char(9),20) ; DBTBL5Q.FLD5
	S vc21=$piece(V,$char(9),21) ; DBTBL5Q.QID1
	S vc22=$piece(V,$char(9),22) ; DBTBL5Q.QID2
	S vc23=$piece(V,$char(9),23) ; DBTBL5Q.QID3
	S vc24=$piece(V,$char(9),24) ; DBTBL5Q.QID4
	S vc25=$piece(V,$char(9),25) ; DBTBL5Q.QID5
	S vc26=$piece(V,$char(9),26) ; DBTBL5Q.QID6
	S vc27=$piece(V,$char(9),27) ; DBTBL5Q.QID7
	S vc28=$piece(V,$char(9),28) ; DBTBL5Q.QID8
	S vc29=$piece(V,$char(9),29) ; DBTBL5Q.QID9
	S vc30=$piece(V,$char(9),30) ; DBTBL5Q.QID10
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
	S vs(1)=0 S vs(2)=0
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
	I $get(VRWOPT("NODTL")) S vskp(1)=1 S vskp(2)=1 ; Skip detail
	D VBREAK
	D VSUM Q:VFMQ 
	;
	I $get(VH0) S vh(0)=0 S VNEWHDR=1 K VH0 ; Page Break
	I 'vh(0) D VHDG0 Q:VFMQ 
	I '$get(vskp(2)) D VDTL2 Q:VFMQ 
	D VSTAT
	Q 
	;
VBREAK	;
	Q:'VT(2) 
	S VH0=1 ; Page break
	N vb1 N vb2
	S (vb1,vb2)=0
	I 0!(vovc1'=vc1) S vs(2)=0 S vh(2)=0 S VD(1)=0 S vb2=1 S VH0=1
	Q 
	;
VSUM	; Report Group Summary
	I 'vs(2) S vs(2)=1 D stat^DBSRWUTL(2)
	Q 
	;
VSTAT	; Data field statistics
	;
	S VT(2)=VT(2)+1
	Q 
	;
VDTL2	; Detail
	;
	I VLC+26>IOSL D VHDG0 Q:VFMQ 
	;
	S VL=" "_"Name: "
	S VL=VL_$J("",7-7)_$E(vc2,1,12)
	S VL=VL_$J("",23-$L(VL))_$E(vc3,1,40)
	S VL=VL_$J("",81-$L(VL))_"User ID: "
	S VL=VL_$J("",90-$L(VL))_$E(vc4,1,20)
	S VL=VL_$J("",113-$L(VL))_"Date: "
	S VL=VL_$J("",119-$L(VL))_$J($S(vc5'="":$ZD(vc5,"MM/DD/YEAR"),1:""),10)
	D VOM
	S VL="                                                                                 "_"Routine:"
	S VL=VL_$J("",90-89)_$E(vc6,1,8)
	S VL=VL_$J("",102-$L(VL))_"Transfer Option:"
	S VL=VL_$J("",119-$L(VL))_$E(vc7,1,12)
	D VOM
	S VL="              "_"File(s): "
	S VL=VL_$J("",23-23)_$E(vc8,1,60)
	S VL=VL_$J("",97-$L(VL))_"Print Detail: "
	S VL=VL_$J("",111-$L(VL))_$S(vc9:"Y",1:"N")
	S VL=VL_$J("",115-$L(VL))_"Banner Page:"
	S VL=VL_$J("",128-$L(VL))_$S(vc10:"Y",1:"N")
	D VOM
	S VL="                                                                                   "_"Statistics:"
	S VL=VL_$J("",95-94)_$S(vc11:"Y",1:"N")
	S VL=VL_$J("",100-$L(VL))_"SQL Query: "
	S VL=VL_$J("",111-$L(VL))_$S(vc12:"Y",1:"N")
	S VL=VL_$J("",114-$L(VL))_"C/S Compiler: "
	S VL=VL_$J("",128-$L(VL))_$S(vc13:"Y",1:"N")
	D VOM
	S VL="             "_"Order By:"
	S VL=VL_$J("",23-22)_$E(vc14,1,100)
	D VOM
	S VL="             "_"Break On: "
	S VL=VL_$J("",23-23)_$E(vc15,1,60)
	D VOM
	S VL="              "_"Item(s):"
	S VL=VL_$J("",23-22)_$E(vc16,1,78)
	D VOM
	S VL="                       "_$E(vc17,1,78)
	I '($translate(VL," ")="") D VOM
	S VL="                       "_$E(vc18,1,78)
	I '($translate(VL," ")="") D VOM
	S VL="                       "_$E(vc19,1,78)
	I '($translate(VL," ")="") D VOM
	S VL="                       "_$E(vc20,1,78)
	I '($translate(VL," ")="") D VOM
	S VL="                "_"Query: "
	S VL=VL_$J("",23-23)_$E(vc21,1,78)
	D VOM
	S VL="                       "_$E(vc22,1,78)
	I '($translate(VL," ")="") D VOM
	S VL="                       "_$E(vc23,1,78)
	I '($translate(VL," ")="") D VOM
	S VL="                       "_$E(vc24,1,78)
	I '($translate(VL," ")="") D VOM
	S VL="                       "_$E(vc25,1,78)
	I '($translate(VL," ")="") D VOM
	S VL="                       "_$E(vc26,1,78)
	I '($translate(VL," ")="") D VOM
	S VL="                       "_$E(vc27,1,78)
	I '($translate(VL," ")="") D VOM
	S VL="                       "_$E(vc28,1,78)
	I '($translate(VL," ")="") D VOM
	S VL="                       "_$E(vc29,1,78)
	I '($translate(VL," ")="") D VOM
	S VL="                       "_$E(vc30,1,78)
	I '($translate(VL," ")="") D VOM
	D VP1 Q:VFMQ!$get(verror)  S V=$E(ZSTAT,1,79) S VL="                       "_V
	I '($translate(VL," ")="") D VOM
	S VL="                                                                                     "_"Spaces"
	S VL=VL_$J("",120-91)_"Lines"
	D VOM
	S VL="                                "_"Field Name"
	S VL=VL_$J("",47-42)_"Column Heading"
	S VL=VL_$J("",85-$L(VL))_"Before"
	S VL=VL_$J("",94-$L(VL))_"Size"
	S VL=VL_$J("",101-$L(VL))_"Format"
	S VL=VL_$J("",113-$L(VL))_"Math"
	S VL=VL_$J("",120-$L(VL))_"Skip"
	D VOM
	S VL="                                "_"-----------"
	S VL=VL_$J("",47-43)_"------------------------------------"
	S VL=VL_$J("",85-$L(VL))_"-------"
	S VL=VL_$J("",94-$L(VL))_"----"
	S VL=VL_$J("",101-$L(VL))_"------"
	S VL=VL_$J("",113-$L(VL))_"----"
	S VL=VL_$J("",120-$L(VL))_"-----"
	D VOM
	D VP2 Q:VFMQ!$get(verror)  S V=$E(ZFORMAT,1,99) S VL="                                "_V
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
	.	E  S VLC=VLC+3 S VPN=VPN+1
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
VP1	; Column pre-processor - Variable: ZSTAT
	;
	N QRID
	;
	S verror=0
	S ZSTAT=""
	;
	S QRID=vc2
	;
	N ds,vos1,vos2,vos3,vos4 S ds=$$vOpen2()
	;
	F  Q:'($$vFetch2())  D  Q:verror 
	.	;
	.	N dbtbl6sq S dbtbl6sq=$G(^DBTBL($P(ds,$C(9),1),6,$P(ds,$C(9),2),$P(ds,$C(9),3)))
	.	;
	.	S VL="                       "_"Statistics:  "_$P(dbtbl6sq,$C(124),4)
	.	S VL=VL_" Based On "_$P(dbtbl6sq,$C(124),1)
	.	I '($P(dbtbl6sq,$C(124),5)="") S VL=VL_" Increments "_$P(dbtbl6sq,$C(124),5)
	.	I VLC+2>IOSL D
	..		D VHDG0
	..		I VFMQ S verror=1
	..		Q 
	.	E  D VOM
	.	Q 
	;
	Q 
	;
VP2	; Column pre-processor - Variable: ZFORMAT
	;
	N QRID
	;
	S verror=0
	S ZFORMAT=""
	;
	S QRID=vc2
	;
	N ds,vos1,vos2,vos3 S ds=$$vOpen3()
	;
	F  Q:'($$vFetch3())  D  Q:verror 
	.	;
	.	N dbtbl6f S dbtbl6f=$G(^DBTBL($P(ds,$C(9),1),6,$P(ds,$C(9),2),$P(ds,$C(9),3)))
	.	;
	.	S VL="                                "_$P(dbtbl6f,$C(124),1)_$J("",15-$L($P(dbtbl6f,$C(124),1)))
	.	S VL=VL_$P(dbtbl6f,$C(124),2)_$J("",40-$L($P(dbtbl6f,$C(124),2)))
	.	S VL=VL_$P(dbtbl6f,$C(124),3)_$J("",7-$L($piece((dbtbl6f),$char(124),3)))
	.	S VL=VL_$P(dbtbl6f,$C(124),4)_$J("",7-$L($piece((dbtbl6f),$char(124),4)))
	.	S VL=VL_$P(dbtbl6f,$C(124),5)_$J("",12-$L($P(dbtbl6f,$C(124),5)))
	.	S VL=VL_$P(dbtbl6f,$C(124),6)_$J("",7-$L($P(dbtbl6f,$C(124),6)))
	.	S VL=VL_$P(dbtbl6f,$C(124),7)_$J("",7-$L($piece((dbtbl6f),$char(124),7)))
	.	I VLC+2>IOSL D
	..		D VHDG0
	..		I VFMQ S verror=1
	..		Q 
	.	E  D VOM
	.	Q 
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
	; ----------------
	;  #OPTION ResultClass 0
vDbDe2()	; DELETE FROM TMPRPTBR WHERE JOBNO=:V1
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3 N v4
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4,vos5 S vRs=$$vOpen5()
	F  Q:'($$vFetch5())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3) S v4=$P(vRs,$C(9),4)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^TMPRPTBR(v1,v2,v3,v4)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	;
vOpen1()	;	DBTBL5Q.LIBS,DBTBL5Q.QRID,DBTBL5Q.DESC,DBTBL5Q.UID,DBTBL5Q.LTD,DBTBL5Q.PGM,DBTBL5Q.TRANS,DBTBL5Q.PFID,DBTBL5Q.DTL,DBTBL5Q.BANNER,DBTBL5Q.STAT,DBTBL5Q.MSQL,DBTBL5Q.CSCMP,DBTBL5Q.ORDERBY,DBTBL5Q.BREAKON,DBTBL5Q.FLD1,DBTBL5Q.FLD2,DBTBL5Q.FLD3,DBTBL5Q.FLD4,DBTBL5Q.FLD5,DBTBL5Q.QID1,DBTBL5Q.QID2,DBTBL5Q.QID3,DBTBL5Q.QID4,DBTBL5Q.QID5,DBTBL5Q.QID6,DBTBL5Q.QID7,DBTBL5Q.QID8,DBTBL5Q.QID9,DBTBL5Q.QID10 FROM DBTBL5Q WHERE DBTBL5Q.QRID IN (SELECT ELEMENT FROM TMPDQ WHERE PID=:V2) ORDER BY DBTBL5Q.LIBS,DBTBL5Q.QRID
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
	I '($D(^DBTBL(vos4,6,vos5))) G vL1a10
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a10
	I vos1=2 S vos1=1
	;
	I vos1=0 K ^DBTMP($J,vOid) Q 0
	;
	S vos6=$G(^DBTBL(vos4,6,vos5,0))
	S vos7=$G(^DBTBL(vos4,6,vos5,1))
	S vos8=$G(^DBTBL(vos4,6,vos5,2))
	S vos9=$G(^DBTBL(vos4,6,vos5,3))
	S vos10=$G(^DBTBL(vos4,6,vos5,4))
	S vos11=$G(^DBTBL(vos4,6,vos5,5))
	S vos12=$G(^DBTBL(vos4,6,vos5,6))
	S vos13=$G(^DBTBL(vos4,6,vos5,7))
	S vos14=$G(^DBTBL(vos4,6,vos5,8))
	S vos15=$G(^DBTBL(vos4,6,vos5,9))
	S vos16=$G(^DBTBL(vos4,6,vos5,10))
	S vos17=$G(^DBTBL(vos4,6,vos5,11))
	S vos18=$G(^DBTBL(vos4,6,vos5,12))
	S vos19=$G(^DBTBL(vos4,6,vos5,13))
	S vos20=$G(^DBTBL(vos4,6,vos5,14))
	S vos21=$G(^DBTBL(vos4,6,vos5,15))
	S vos22=$G(^DBTBL(vos4,6,vos5,16))
	S vos23=$G(^DBTBL(vos4,6,vos5))
	S rwrs=$S(vos4=$$BYTECHAR^SQLUTL(254):"",1:vos4)_$C(9)_vos5_$C(9)_$P(vos23,"|",1)_$C(9)_$P(vos6,"|",15)_$C(9)_$P(vos6,"|",3)_$C(9)_$P(vos6,"|",2)_$C(9)_$P(vos17,"|",1)_$C(9)_$P(vos6,"|",1)_$C(9)_$P(vos6,"|",4)
	S rwrs=rwrs_$C(9)_$P(vos6,"|",12)_$C(9)_$P(vos6,"|",8)_$C(9)_$P(vos6,"|",13)_$C(9)_$P(vos6,"|",14)_$C(9)_$P(vos6,"|",10)_$C(9)_$P(vos6,"|",11)_$C(9)_$P(vos18,"|",1)_$C(9)_$P(vos19,"|",1)_$C(9)_$P(vos20,"|",1)_$C(9)_$P(vos21,"|",1)
	S rwrs=rwrs_$C(9)_$P(vos22,"|",1)_$C(9)_$P(vos7,"|",1)_$C(9)_$P(vos8,"|",1)_$C(9)_$P(vos9,"|",1)_$C(9)_$P(vos10,"|",1)_$C(9)_$P(vos11,"|",1)_$C(9)_$P(vos12,"|",1)_$C(9)_$P(vos13,"|",1)_$C(9)_$P(vos14,"|",1)_$C(9)_$P(vos15,"|",1)
	S rwrs=rwrs_$C(9)_$P(vos16,"|",1)
	;
	Q 1
	;
vOpen2()	;	LIBS,QID,SEQ FROM DBTBL6SQ WHERE LIBS='SYSDEV' AND QID=:QRID AND (QDI IS NOT NULL OR QBASE IS NOT NULL OR QINCR IS NOT NULL) ORDER BY SEQ ASC
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(QRID) I vos2="" G vL2a0
	S vos3=20
vL2a3	S vos3=$O(^DBTBL("SYSDEV",6,vos2,vos3),1) I vos3=""!(vos3'<41) G vL2a0
	S vos4=$G(^DBTBL("SYSDEV",6,vos2,vos3))
	I '(($P(vos4,"|",4)'=""!($P(vos4,"|",1)'="")!($P(vos4,"|",5)'=""))) G vL2a3
	Q
	;
vFetch2()	;
	;
	;
	I vos1=1 D vL2a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$$BYTECHAR^SQLUTL(254):"",1:vos3)
	;
	Q 1
	;
vOpen3()	;	LIBS,QRID,SEQ FROM DBTBL6F WHERE LIBS='SYSDEV' AND QRID=:QRID ORDER BY SEQ ASC
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(QRID) I vos2="" G vL3a0
	S vos3=100
vL3a3	S vos3=$O(^DBTBL("SYSDEV",6,vos2,vos3),1) I vos3="" G vL3a0
	Q
	;
vFetch3()	;
	;
	;
	I vos1=1 D vL3a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$$BYTECHAR^SQLUTL(254):"",1:vos3)
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
	;
vOpen5()	;	JOBNO,LINENO,PAGENO,SEQ FROM TMPRPTBR WHERE JOBNO=:V1
	;
	;
	S vos1=2
	D vL5a1
	Q ""
	;
vL5a0	S vos1=0 Q
vL5a1	S vos2=$G(V1) I vos2="" G vL5a0
	S vos3=""
vL5a3	S vos3=$O(^TMPRPTBR(vos2,vos3),1) I vos3="" G vL5a0
	S vos4=""
vL5a5	S vos4=$O(^TMPRPTBR(vos2,vos3,vos4),1) I vos4="" G vL5a3
	S vos5=""
vL5a7	S vos5=$O(^TMPRPTBR(vos2,vos3,vos4,vos5),1) I vos5="" G vL5a5
	Q
	;
vFetch5()	;
	;
	;
	I vos1=1 D vL5a7
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$$BYTECHAR^SQLUTL(254):"",1:vos3)_$C(9)_$S(vos4=$$BYTECHAR^SQLUTL(254):"",1:vos4)_$C(9)_$S(vos5=$$BYTECHAR^SQLUTL(254):"",1:vos5)
	;
	Q 1
