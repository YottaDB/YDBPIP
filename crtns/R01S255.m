R01S255	; DBSRPTLST - DATA-QWIK Report Definition Listing
	;
	; **** Routine compiled from DATA-QWIK Report DBSRPTLST ****
	;
	; 09/14/2007 10:49 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/14/2007 10:49 - chenardp
	;
	 S ER=0
	N OLNTB
	N %READ N RID N RN N %TAB N VFMQ
	;
	S RID="DBSRPTLST"
	S RN="DATA-QWIK Report Definition Listing"
	I $get(IO)="" S IO=$I
	;
	D INIT^%ZM()
	;
	D VPREBQ Q:$get(VFMQ)  ; Pre-processor (before query)
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
	N VWHERE
	N %TIM N CONAM N INCTXT N RID N RN N SEQDESC N VL N VLOF N VRF N VSTATS N ZKEYDESC N ZLINE N ZPREPP N ZREPEAT N ZSBL N ZSEC N ZSECTION N ZSLF N vCOL N vHDG N vc1 N vc10 N vc11 N vc12 N vc13 N vc14 N vc15 N vc16 N vc17 N vc18 N vc19 N vc2 N vc20 N vc21 N vc22 N vc23 N vc24 N vc25 N vc26 N vc27 N vc28 N vc29 N vc3 N vc30 N vc31 N vc32 N vc33 N vc34 N vc35 N vc36 N vc37 N vc38 N vc39 N vc4 N vc40 N vc41 N vc42 N vc43 N vc44 N vc45 N vc46 N vc47 N vc48 N vc49 N vc5 N vc50 N vc51 N vc52 N vc53 N vc54 N vc55 N vc56 N vc57 N vc58 N vc59 N vc6 N vc60 N vc61 N vc62 N vc63 N vc64 N vc65 N vc66 N vc67 N vc68 N vc69 N vc7 N vc70 N vc71 N vc72 N vc73 N vc74 N vc75 N vc76 N vc8 N vc9 N vovc1 N vovc2 N vovc3 N vovc4
	N vovc5 N vrundate N vsysdate
	;
	S CONAM="DATA-QWIK 7.2"
	S ER=0 S RID="DBSRPTLST" S RN="DATA-QWIK Report Definition Listing"
	S VL=""
	;
	USE 0 I '$get(VRWOPT("NOOPEN")) D  Q:ER 
	.	I '($get(VRWOPT("IOPAR"))="") S IOPAR=VRWOPT("IOPAR")
	.	E  I (($get(IOTYP)="RMS")!($get(IOTYP)="PNTQ")),('($get(IOPAR)["/OCHSET=")),$$VALID^%ZRTNS("UCIOENCD") D
	..		; Accept warning if ^UCIOENCD does not exist
	..		;    #ACCEPT Date=07/26/06; Pgm=RussellDS; CR=22121; Group=MISMATCH
	..		N CHRSET S CHRSET=$$^UCIOENCD("Report","DBSRPTLST","V0","*")
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
	S vCOL="[DBTBL5D]NAME#2#30,[DBTBL5D]PROMPT#34#40,[DBTBL5D]SIZE#77#3,[DBTBL5D]FMT#82#12,[DBTBL5D]COL#102#3"
	;
	; Initialize variables
	S (vc1,vc2,vc3,vc4,vc5,vc6,vc7,vc8,vc9,vc10,vc11,vc12,vc13,vc14,vc15,vc16,vc17,vc18,vc19,vc20,vc21,vc22,vc23,vc24,vc25,vc26,vc27,vc28,vc29,vc30,vc31,vc32,vc33,vc34,vc35,vc36,vc37,vc38,vc39,vc40,vc41,vc42,vc43,vc44,vc45,vc46,vc47,vc48,vc49,vc50,vc51,vc52,vc53,vc54,vc55,vc56,vc57,vc58,vc59,vc60,vc61,vc62,vc63,vc64,vc65,vc66,vc67,vc68,vc69,vc70,vc71,vc72,vc73,vc74,vc75,vc76)=""
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
	S vh(0)=0
	;
	; Run report directly
	D VINILAST
	;
	S VWHERE="DBTBL5D.ITMSEQ>0"
	I ($D(vudwhere)#2) S VWHERE=vudwhere
	;  #ACCEPT DATE=09/14/2007;PGM=Report Writer Generator;CR=20967
	N rwrs,vos1,vos2,sqlcur,exe,sqlcur,vd,vi,vsql,vsub S rwrs=$$vOpen0(.exe,.vsql,"DBTBL5D.LIBS,DBTBL5D.RID,DBTBL5D.RPTSEQ,DBTBL5D.GRP,DBTBL5D.ITMSEQ,DBTBL5D.NAME,DBTBL5D.PROMPT,DBTBL5D.SIZE,DBTBL5D.FMT,DBTBL5D.COL,DBTBL5H.DESC,DBTBL5H.PGM,DBTBL5H.UID,DBTBL5H.DATE,DBTBL5H.PSIZE,DBTBL5H.BANNER,DBTBL5H.FIXLEN,DBTBL5H.RSIZE,DBTBL5H.ALIGN,DBTBL5H.RESFLG,DBTBL5H.MSQL,DBTBL5H.PFID,DBTBL5H.SEQ,DBTBL5H.PGBK,DBTBL5H.PHDR,DBTBL5H.PRNG,DBTBL5H.SORTORD,DBTBL5H.SEQ2,DBTBL5H.PGBK2,DBTBL5H.PHDR2,DBTBL5H.PRNG2,DBTBL5H.SORTORD2,DBTBL5H.SEQ3,DBTBL5H.PGBK3,DBTBL5H.PHDR3,DBTBL5H.PRNG3,DBTBL5H.SORTORD3,DBTBL5H.SEQ4,DBTBL5H.PGBK4,DBTBL5H.PHDR4,DBTBL5H.PRNG4,DBTBL5H.SORTORD4,DBTBL5H.SEQ5,DBTBL5H.PGBK5,DBTBL5H.PHDR5,DBTBL5H.PRNG5,DBTBL5H.SORTORD5,DBTBL5H.SEQ6,DBTBL5H.PGBK6,DBTBL5H.PHDR6,DBTBL5H.PRNG6,DBTBL5H.SORTORD6,DBTBL5H.SEQ7,DBTBL5H.PGBK7,DBTBL5H.PHDR7,DBTBL5H.PRNG7,DBTBL5H.SORTORD7,DBTBL5H.SEQ8,DBTBL5H.PGBK8,DBTBL5H.PHDR8,DBTBL5H.PRNG8,DBTBL5H.SORTORD8,DBTBL5H.SEQ9,DBTBL5H.PGBK9,DBTBL5H.PHDR9,DBTBL5H.PRNG9,DBTBL5H.SORTORD9,DBTBL5H.SEQ10,DBTBL5H.PGBK10,DBTBL5H.PHDR10,DBTBL5H.PRNG10,DBTBL5H.SORTORD10,DBTBL5H.STATTRGT1,DBTBL5H.STATSRC1,DBTBL5H.STATINC1,DBTBL5D.LINE","DBTBL5D,DBTBL5H",VWHERE,"DBTBL5D.LIBS,DBTBL5D.RID,DBTBL5D.RPTSEQ,DBTBL5D.GRP,DBTBL5D.ITMSEQ","","/DQMODE=1")
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
	S vc1=$piece(V,$char(9),1) ; DBTBL5D.LIBS
	S vc2=$piece(V,$char(9),2) ; DBTBL5D.RID
	S vc3=$piece(V,$char(9),3) ; DBTBL5D.RPTSEQ
	S vc4=$piece(V,$char(9),4) ; DBTBL5D.GRP
	S vc5=$piece(V,$char(9),5) ; DBTBL5D.ITMSEQ
	S vc6=$piece(V,$char(9),6) ; DBTBL5D.NAME
	S vc7=$piece(V,$char(9),7) ; DBTBL5D.PROMPT
	S vc8=$piece(V,$char(9),8) ; DBTBL5D.SIZE
	S vc9=$piece(V,$char(9),9) ; DBTBL5D.FMT
	S vc10=$piece(V,$char(9),10) ; DBTBL5D.COL
	S vc11=$piece(V,$char(9),11) ; DBTBL5H.DESC
	S vc12=$piece(V,$char(9),12) ; DBTBL5H.PGM
	S vc13=$piece(V,$char(9),13) ; DBTBL5H.UID
	S vc14=$piece(V,$char(9),14) ; DBTBL5H.DATE
	S vc15=$piece(V,$char(9),15) ; DBTBL5H.PSIZE
	S vc16=$piece(V,$char(9),16) ; DBTBL5H.BANNER
	S vc17=$piece(V,$char(9),17) ; DBTBL5H.FIXLEN
	S vc18=$piece(V,$char(9),18) ; DBTBL5H.RSIZE
	S vc19=$piece(V,$char(9),19) ; DBTBL5H.ALIGN
	S vc20=$piece(V,$char(9),20) ; DBTBL5H.RESFLG
	S vc21=$piece(V,$char(9),21) ; DBTBL5H.MSQL
	S vc22=$piece(V,$char(9),22) ; DBTBL5H.PFID
	S vc23=$piece(V,$char(9),23) ; DBTBL5H.SEQ
	S vc24=$piece(V,$char(9),24) ; DBTBL5H.PGBK
	S vc25=$piece(V,$char(9),25) ; DBTBL5H.PHDR
	S vc26=$piece(V,$char(9),26) ; DBTBL5H.PRNG
	S vc27=$piece(V,$char(9),27) ; DBTBL5H.SORTORD
	S vc28=$piece(V,$char(9),28) ; DBTBL5H.SEQ2
	S vc29=$piece(V,$char(9),29) ; DBTBL5H.PGBK2
	S vc30=$piece(V,$char(9),30) ; DBTBL5H.PHDR2
	S vc31=$piece(V,$char(9),31) ; DBTBL5H.PRNG2
	S vc32=$piece(V,$char(9),32) ; DBTBL5H.SORTORD2
	S vc33=$piece(V,$char(9),33) ; DBTBL5H.SEQ3
	S vc34=$piece(V,$char(9),34) ; DBTBL5H.PGBK3
	S vc35=$piece(V,$char(9),35) ; DBTBL5H.PHDR3
	S vc36=$piece(V,$char(9),36) ; DBTBL5H.PRNG3
	S vc37=$piece(V,$char(9),37) ; DBTBL5H.SORTORD3
	S vc38=$piece(V,$char(9),38) ; DBTBL5H.SEQ4
	S vc39=$piece(V,$char(9),39) ; DBTBL5H.PGBK4
	S vc40=$piece(V,$char(9),40) ; DBTBL5H.PHDR4
	S vc41=$piece(V,$char(9),41) ; DBTBL5H.PRNG4
	S vc42=$piece(V,$char(9),42) ; DBTBL5H.SORTORD4
	S vc43=$piece(V,$char(9),43) ; DBTBL5H.SEQ5
	S vc44=$piece(V,$char(9),44) ; DBTBL5H.PGBK5
	S vc45=$piece(V,$char(9),45) ; DBTBL5H.PHDR5
	S vc46=$piece(V,$char(9),46) ; DBTBL5H.PRNG5
	S vc47=$piece(V,$char(9),47) ; DBTBL5H.SORTORD5
	S vc48=$piece(V,$char(9),48) ; DBTBL5H.SEQ6
	S vc49=$piece(V,$char(9),49) ; DBTBL5H.PGBK6
	S vc50=$piece(V,$char(9),50) ; DBTBL5H.PHDR6
	S vc51=$piece(V,$char(9),51) ; DBTBL5H.PRNG6
	S vc52=$piece(V,$char(9),52) ; DBTBL5H.SORTORD6
	S vc53=$piece(V,$char(9),53) ; DBTBL5H.SEQ7
	S vc54=$piece(V,$char(9),54) ; DBTBL5H.PGBK7
	S vc55=$piece(V,$char(9),55) ; DBTBL5H.PHDR7
	S vc56=$piece(V,$char(9),56) ; DBTBL5H.PRNG7
	S vc57=$piece(V,$char(9),57) ; DBTBL5H.SORTORD7
	S vc58=$piece(V,$char(9),58) ; DBTBL5H.SEQ8
	S vc59=$piece(V,$char(9),59) ; DBTBL5H.PGBK8
	S vc60=$piece(V,$char(9),60) ; DBTBL5H.PHDR8
	S vc61=$piece(V,$char(9),61) ; DBTBL5H.PRNG8
	S vc62=$piece(V,$char(9),62) ; DBTBL5H.SORTORD8
	S vc63=$piece(V,$char(9),63) ; DBTBL5H.SEQ9
	S vc64=$piece(V,$char(9),64) ; DBTBL5H.PGBK9
	S vc65=$piece(V,$char(9),65) ; DBTBL5H.PHDR9
	S vc66=$piece(V,$char(9),66) ; DBTBL5H.PRNG9
	S vc67=$piece(V,$char(9),67) ; DBTBL5H.SORTORD9
	S vc68=$piece(V,$char(9),68) ; DBTBL5H.SEQ10
	S vc69=$piece(V,$char(9),69) ; DBTBL5H.PGBK10
	S vc70=$piece(V,$char(9),70) ; DBTBL5H.PHDR10
	S vc71=$piece(V,$char(9),71) ; DBTBL5H.PRNG10
	S vc72=$piece(V,$char(9),72) ; DBTBL5H.SORTORD10
	S vc73=$piece(V,$char(9),73) ; DBTBL5H.STATTRGT1
	S vc74=$piece(V,$char(9),74) ; DBTBL5H.STATSRC1
	S vc75=$piece(V,$char(9),75) ; DBTBL5H.STATINC1
	S vc76=$piece(V,$char(9),76) ; DBTBL5D.LINE
	Q 
	;
	; User-defined pre/post-processor code
	;
VPREBQ	; Pre-processor (before query)
	;
	;Incoming=vudwhere,ZRID
	S vudwhere=""
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
	I 'vh(0) D VHDG0
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
	I '$get(vskp(3)) D VDTL3 Q:VFMQ 
	D VHDG6 Q:VFMQ 
	I '$get(vskp(6)) D VDTL6 Q:VFMQ 
	D VSTAT
	Q 
	;
VBREAK	;
	Q:'VT(6) 
	N vb1 N vb2 N vb3 N vb4 N vb5 N vb6
	S (vb1,vb2,vb3,vb4,vb5,vb6)=0
	I 0!(vovc1'=vc1) S vs(3)=0 S vh(3)=0 S VD(1)=0 S vb2=1 S vb3=1 S vb4=1 S vb5=1 S vb6=1
	I vb3!(vovc2'=vc2) S vs(4)=0 S vh(4)=0 S VD(3)=0 S vb4=1 S vb5=1 S vb6=1 S VH0=1
	I vb4!(+vovc3'=+vc3) S vs(5)=0 S vh(5)=0 S VD(4)=0 S vb5=1 S vb6=1
	I vb5!(vovc4'=vc4) S vs(6)=0 S vh(6)=0 S VD(5)=0 S vb6=1
	Q 
	;
VSUM	; Report Group Summary
	I 'vs(6) S vs(6)=1 D stat^DBSRWUTL(6)
	I 'vs(5) S vs(5)=1 D VSUM5 Q:VFMQ  D stat^DBSRWUTL(5)
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
VDTL3	; Detail
	;
	Q:VD(3)  S VD(3)=1 ; Print flag
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	;
	S VL=" "_"Name: "
	S VL=VL_$J("",7-7)_$E(vc2,1,12)
	S VL=VL_$J("",21-$L(VL))_$E(vc11,1,40)
	S VL=VL_$J("",66-$L(VL))_"Program: "
	S VL=VL_$J("",75-$L(VL))_$E(vc12,1,8)
	S VL=VL_$J("",85-$L(VL))_"User ID: "
	S VL=VL_$J("",94-$L(VL))_$E(vc13,1,20)
	S VL=VL_$J("",116-$L(VL))_"Date: "
	S VL=VL_$J("",122-$L(VL))_$J($S(vc14'="":$ZD(vc14,"MM/DD/YEAR"),1:""),10)
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	D VOM
	S VL="                                                                        "_"Page Length:"
	S VL=VL_$J("",85-84)_$J(vc15,3)
	S VL=VL_$J("",97-$L(VL))_"Banner: "
	S VL=VL_$J("",105-$L(VL))_$S(vc16:"Y",1:"N")
	S VL=VL_$J("",112-$L(VL))_"Fixed Length: "
	S VL=VL_$J("",126-$L(VL))_$S(vc17:"Y",1:"N")
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	D VOM
	S VL="                                                                         "_"Page Width:"
	S VL=VL_$J("",85-84)_$J(vc18,3)
	S VL=VL_$J("",94-$L(VL))_"Alignment:"
	S VL=VL_$J("",105-$L(VL))_$S(vc19:"Y",1:"N")
	S VL=VL_$J("",111-$L(VL))_"Protect Logic:"
	S VL=VL_$J("",126-$L(VL))_$J(vc20,1)
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	D VOM
	S VL="                                                                                                            "_"SQL Query Syntax:"
	S VL=VL_$J("",126-125)_$S(vc21:"Y",1:"N")
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	D VOM
	S VL="                         "_"File(s):"
	S VL=VL_$J("",34-33)_$E(vc22,1,60)
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	D VOM
	S VL="                                                                                                  "_"New Page At"
	S VL=VL_$J("",111-109)_"Print"
	S VL=VL_$J("",119-$L(VL))_"Min"
	S VL=VL_$J("",125-$L(VL))_"Order"
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	D VOM
	S VL="                                  "_"--------------- Report Sequence By ---------------"
	S VL=VL_$J("",99-84)_"Key"
	S VL=VL_$J("",104-$L(VL))_"Break"
	S VL=VL_$J("",111-$L(VL))_"Header"
	S VL=VL_$J("",119-$L(VL))_"Line"
	S VL=VL_$J("",126-$L(VL))_"By"
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	D VOM
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	S VL="" D VOM
	S VL="                                  "_$E(vc23,1,33)
	D VP1 Q:VFMQ!$get(verror)  S V=$E(SEQDESC,1,25)
	S VL=VL_$J("",69-$L(VL))_V
	S VL=VL_$J("",104-$L(VL))_$S(vc24:"Y",1:"N")
	S VL=VL_$J("",113-$L(VL))_$S(vc25:"Y",1:"N")
	S VL=VL_$J("",120-$L(VL))_$E(vc26,1,2)
	S VL=VL_$J("",127-$L(VL))_$E(vc27,1)
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="                                  "_$E(vc28,1,33)
	D VP2 Q:VFMQ!$get(verror)  S V=$E(SEQDESC,1,25)
	S VL=VL_$J("",69-$L(VL))_V
	S VL=VL_$J("",104-$L(VL))_$S(vc29:"Y",1:"N")
	S VL=VL_$J("",113-$L(VL))_$S(vc30:"Y",1:"N")
	S VL=VL_$J("",120-$L(VL))_$E(vc31,1,2)
	S V=vc32 S VO=V S V=$E(V,1) D VP3 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",127-$L(VL))_V ; [SYSDEV,DBTBL5H]SORTORD2
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="                                  "_$E(vc33,1,33)
	D VP4 Q:VFMQ!$get(verror)  S V=$E(SEQDESC,1,25)
	S VL=VL_$J("",69-$L(VL))_V
	S VL=VL_$J("",104-$L(VL))_$S(vc34:"Y",1:"N")
	S VL=VL_$J("",113-$L(VL))_$S(vc35:"Y",1:"N")
	S VL=VL_$J("",120-$L(VL))_$E(vc36,1,2)
	S V=vc37 S VO=V S V=$E(V,1) D VP5 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",127-$L(VL))_V ; [SYSDEV,DBTBL5H]SORTORD3
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="                                  "_$E(vc38,1,33)
	D VP6 Q:VFMQ!$get(verror)  S V=$E(SEQDESC,1,25)
	S VL=VL_$J("",69-$L(VL))_V
	S VL=VL_$J("",104-$L(VL))_$S(vc39:"Y",1:"N")
	S VL=VL_$J("",113-$L(VL))_$S(vc40:"Y",1:"N")
	S VL=VL_$J("",120-$L(VL))_$E(vc41,1,2)
	S V=vc42 S VO=V S V=$E(V,1) D VP7 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",127-$L(VL))_V ; [SYSDEV,DBTBL5H]SORTORD4
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="                                  "_$E(vc43,1,33)
	D VP8 Q:VFMQ!$get(verror)  S V=$E(SEQDESC,1,25)
	S VL=VL_$J("",69-$L(VL))_V
	S VL=VL_$J("",104-$L(VL))_$S(vc44:"Y",1:"N")
	S VL=VL_$J("",113-$L(VL))_$S(vc45:"Y",1:"N")
	S VL=VL_$J("",120-$L(VL))_$E(vc46,1,2)
	S V=vc47 S VO=V S V=$E(V,1) D VP9 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",127-$L(VL))_V ; [SYSDEV,DBTBL5H]SORTORD5
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="                                  "_$E(vc48,1,33)
	D VP10 Q:VFMQ!$get(verror)  S V=$E(SEQDESC,1,25)
	S VL=VL_$J("",69-$L(VL))_V
	S VL=VL_$J("",104-$L(VL))_$S(vc49:"Y",1:"N")
	S VL=VL_$J("",113-$L(VL))_$S(vc50:"Y",1:"N")
	S VL=VL_$J("",120-$L(VL))_$E(vc51,1,2)
	S V=vc52 S VO=V S V=$E(V,1) D VP11 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",127-$L(VL))_V ; [SYSDEV,DBTBL5H]SORTORD6
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="                                  "_$E(vc53,1,33)
	D VP12 Q:VFMQ!$get(verror)  S V=$E(SEQDESC,1,25)
	S VL=VL_$J("",69-$L(VL))_V
	S VL=VL_$J("",104-$L(VL))_$S(vc54:"Y",1:"N")
	S VL=VL_$J("",113-$L(VL))_$S(vc55:"Y",1:"N")
	S VL=VL_$J("",120-$L(VL))_$E(vc56,1,2)
	S V=vc57 S VO=V S V=$E(V,1) D VP13 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",127-$L(VL))_V ; [SYSDEV,DBTBL5H]SORTORD7
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="                                  "_$E(vc58,1,33)
	D VP14 Q:VFMQ!$get(verror)  S V=$E(SEQDESC,1,25)
	S VL=VL_$J("",69-$L(VL))_V
	S VL=VL_$J("",104-$L(VL))_$S(vc59:"Y",1:"N")
	S VL=VL_$J("",113-$L(VL))_$S(vc60:"Y",1:"N")
	S VL=VL_$J("",120-$L(VL))_$E(vc61,1,2)
	S V=vc62 S VO=V S V=$E(V,1) D VP15 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",127-$L(VL))_V ; [SYSDEV,DBTBL5H]SORTORD8
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="                                  "_$E(vc63,1,33)
	D VP16 Q:VFMQ!$get(verror)  S V=$E(SEQDESC,1,25)
	S VL=VL_$J("",69-$L(VL))_V
	S VL=VL_$J("",104-$L(VL))_$S(vc64:"Y",1:"N")
	S VL=VL_$J("",113-$L(VL))_$S(vc65:"Y",1:"N")
	S VL=VL_$J("",120-$L(VL))_$E(vc66,1,2)
	S V=vc67 S VO=V S V=$E(V,1) D VP17 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",127-$L(VL))_V ; [SYSDEV,DBTBL5H]SORTORD9
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="                                  "_$E(vc68,1,33)
	D VP18 Q:VFMQ!$get(verror)  S V=$E(SEQDESC,1,25)
	S VL=VL_$J("",69-$L(VL))_V
	S VL=VL_$J("",104-$L(VL))_$S(vc69:"Y",1:"N")
	S VL=VL_$J("",113-$L(VL))_$S(vc70:"Y",1:"N")
	S VL=VL_$J("",120-$L(VL))_$E(vc71,1,2)
	S V=vc72 S VO=V S V=$E(V,1) D VP19 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",127-$L(VL))_V ; [SYSDEV,DBTBL5H]SORTORD10
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="           "_"Statistics:  "
	S VL=VL_$J("",24-24)_$E(vc73,1,25)
	S VL=VL_$J("",51-$L(VL))_"Based On:  "
	S VL=VL_$J("",62-$L(VL))_$E(vc74,1,25)
	D VP20 Q:VFMQ!$get(verror)  S V=$E(INCTXT,1,11)
	S VL=VL_$J("",89-$L(VL))_V
	S V=vc75 S VO=V S V=$E(V,1,26) D VP21 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",102-$L(VL))_V ; [SYSDEV,DBTBL5H]STATINC1
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="           "_"Statistics:  "
	S VL=VL_$J("",24-24)_$E(vc73,1,25)
	S VL=VL_$J("",51-$L(VL))_"Based On:  "
	S VL=VL_$J("",62-$L(VL))_$E(vc74,1,25)
	D VP22 Q:VFMQ!$get(verror)  S V=$E(INCTXT,1,11)
	S VL=VL_$J("",89-$L(VL))_V
	S V=vc75 S VO=V S V=$E(V,1,26) D VP23 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",102-$L(VL))_V ; [SYSDEV,DBTBL5H]STATINC1
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="           "_"Statistics:  "
	S VL=VL_$J("",24-24)_$E(vc73,1,25)
	S VL=VL_$J("",51-$L(VL))_"Based On:  "
	S VL=VL_$J("",62-$L(VL))_$E(vc74,1,25)
	D VP24 Q:VFMQ!$get(verror)  S V=$E(INCTXT,1,11)
	S VL=VL_$J("",89-$L(VL))_V
	S V=vc75 S VO=V S V=$E(V,1,26) D VP25 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",102-$L(VL))_V ; [SYSDEV,DBTBL5H]STATINC1
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="           "_"Statistics:  "
	S VL=VL_$J("",24-24)_$E(vc73,1,25)
	S VL=VL_$J("",51-$L(VL))_"Based On:  "
	S VL=VL_$J("",62-$L(VL))_$E(vc74,1,25)
	D VP26 Q:VFMQ!$get(verror)  S V=$E(INCTXT,1,11)
	S VL=VL_$J("",89-$L(VL))_V
	S V=vc75 S VO=V S V=$E(V,1,26) D VP27 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",102-$L(VL))_V ; [SYSDEV,DBTBL5H]STATINC1
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="           "_"Statistics:  "
	S VL=VL_$J("",24-24)_$E(vc73,1,25)
	S VL=VL_$J("",51-$L(VL))_"Based On:  "
	S VL=VL_$J("",62-$L(VL))_$E(vc74,1,25)
	D VP28 Q:VFMQ!$get(verror)  S V=$E(INCTXT,1,11)
	S VL=VL_$J("",89-$L(VL))_V
	S V=vc75 S VO=V S V=$E(V,1,26) D VP29 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",102-$L(VL))_V ; [SYSDEV,DBTBL5H]STATINC1
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="           "_"Statistics:  "
	S VL=VL_$J("",24-24)_$E(vc73,1,25)
	S VL=VL_$J("",51-$L(VL))_"Based On:  "
	S VL=VL_$J("",62-$L(VL))_$E(vc74,1,25)
	D VP30 Q:VFMQ!$get(verror)  S V=$E(INCTXT,1,11)
	S VL=VL_$J("",89-$L(VL))_V
	S V=vc75 S VO=V S V=$E(V,1,26) D VP31 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",102-$L(VL))_V ; [SYSDEV,DBTBL5H]STATINC1
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="           "_"Statistics:  "
	S VL=VL_$J("",24-24)_$E(vc73,1,25)
	S VL=VL_$J("",51-$L(VL))_"Based On:  "
	S VL=VL_$J("",62-$L(VL))_$E(vc74,1,25)
	D VP32 Q:VFMQ!$get(verror)  S V=$E(INCTXT,1,11)
	S VL=VL_$J("",89-$L(VL))_V
	S V=vc75 S VO=V S V=$E(V,1,26) D VP33 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",102-$L(VL))_V ; [SYSDEV,DBTBL5H]STATINC1
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="           "_"Statistics:  "
	S VL=VL_$J("",24-24)_$E(vc73,1,25)
	S VL=VL_$J("",51-$L(VL))_"Based On:  "
	S VL=VL_$J("",62-$L(VL))_$E(vc74,1,25)
	D VP34 Q:VFMQ!$get(verror)  S V=$E(INCTXT,1,11)
	S VL=VL_$J("",89-$L(VL))_V
	S V=vc75 S VO=V S V=$E(V,1,26) D VP35 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",102-$L(VL))_V ; [SYSDEV,DBTBL5H]STATINC1
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="           "_"Statistics:  "
	S VL=VL_$J("",24-24)_$E(vc73,1,25)
	S VL=VL_$J("",51-$L(VL))_"Based On:  "
	S VL=VL_$J("",62-$L(VL))_$E(vc74,1,25)
	D VP36 Q:VFMQ!$get(verror)  S V=$E(INCTXT,1,11)
	S VL=VL_$J("",89-$L(VL))_V
	S V=vc75 S VO=V S V=$E(V,1,26) D VP37 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",102-$L(VL))_V ; [SYSDEV,DBTBL5H]STATINC1
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="           "_"Statistics:  "
	S VL=VL_$J("",24-24)_$E(vc73,1,25)
	S VL=VL_$J("",51-$L(VL))_"Based On:  "
	S VL=VL_$J("",62-$L(VL))_$E(vc74,1,25)
	D VP38 Q:VFMQ!$get(verror)  S V=$E(INCTXT,1,11)
	S VL=VL_$J("",89-$L(VL))_V
	S V=vc75 S VO=V S V=$E(V,1,26) D VP39 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",102-$L(VL))_V ; [SYSDEV,DBTBL5H]STATINC1
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="           "_"Statistics:  "
	S VL=VL_$J("",24-24)_$E(vc73,1,25)
	S VL=VL_$J("",51-$L(VL))_"Based On:  "
	S VL=VL_$J("",62-$L(VL))_$E(vc74,1,25)
	D VP40 Q:VFMQ!$get(verror)  S V=$E(INCTXT,1,11)
	S VL=VL_$J("",89-$L(VL))_V
	S V=vc75 S VO=V S V=$E(V,1,26) D VP41 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",102-$L(VL))_V ; [SYSDEV,DBTBL5H]STATINC1
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="           "_"Statistics:  "
	S VL=VL_$J("",24-24)_$E(vc73,1,25)
	S VL=VL_$J("",51-$L(VL))_"Based On:  "
	S VL=VL_$J("",62-$L(VL))_$E(vc74,1,25)
	D VP42 Q:VFMQ!$get(verror)  S V=$E(INCTXT,1,11)
	S VL=VL_$J("",89-$L(VL))_V
	S V=vc75 S VO=V S V=$E(V,1,26) D VP43 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",102-$L(VL))_V ; [SYSDEV,DBTBL5H]STATINC1
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="           "_"Statistics:  "
	S VL=VL_$J("",24-24)_$E(vc73,1,25)
	S VL=VL_$J("",51-$L(VL))_"Based On:  "
	S VL=VL_$J("",62-$L(VL))_$E(vc74,1,25)
	D VP44 Q:VFMQ!$get(verror)  S V=$E(INCTXT,1,11)
	S VL=VL_$J("",89-$L(VL))_V
	S V=vc75 S VO=V S V=$E(V,1,26) D VP45 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",102-$L(VL))_V ; [SYSDEV,DBTBL5H]STATINC1
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="           "_"Statistics:  "
	S VL=VL_$J("",24-24)_$E(vc73,1,25)
	S VL=VL_$J("",51-$L(VL))_"Based On:  "
	S VL=VL_$J("",62-$L(VL))_$E(vc74,1,25)
	D VP46 Q:VFMQ!$get(verror)  S V=$E(INCTXT,1,11)
	S VL=VL_$J("",89-$L(VL))_V
	S V=vc75 S VO=V S V=$E(V,1,26) D VP47 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",102-$L(VL))_V ; [SYSDEV,DBTBL5H]STATINC1
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="           "_"Statistics:  "
	S VL=VL_$J("",24-24)_$E(vc73,1,25)
	S VL=VL_$J("",51-$L(VL))_"Based On:  "
	S VL=VL_$J("",62-$L(VL))_$E(vc74,1,25)
	D VP48 Q:VFMQ!$get(verror)  S V=$E(INCTXT,1,11)
	S VL=VL_$J("",89-$L(VL))_V
	S V=vc75 S VO=V S V=$E(V,1,26) D VP49 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",102-$L(VL))_V ; [SYSDEV,DBTBL5H]STATINC1
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="           "_"Statistics:  "
	S VL=VL_$J("",24-24)_$E(vc73,1,25)
	S VL=VL_$J("",51-$L(VL))_"Based On:  "
	S VL=VL_$J("",62-$L(VL))_$E(vc74,1,25)
	D VP50 Q:VFMQ!$get(verror)  S V=$E(INCTXT,1,11)
	S VL=VL_$J("",89-$L(VL))_V
	S V=vc75 S VO=V S V=$E(V,1,26) D VP51 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",102-$L(VL))_V ; [SYSDEV,DBTBL5H]STATINC1
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="           "_"Statistics:  "
	S VL=VL_$J("",24-24)_$E(vc73,1,25)
	S VL=VL_$J("",51-$L(VL))_"Based On:  "
	S VL=VL_$J("",62-$L(VL))_$E(vc74,1,25)
	D VP52 Q:VFMQ!$get(verror)  S V=$E(INCTXT,1,11)
	S VL=VL_$J("",89-$L(VL))_V
	S V=vc75 S VO=V S V=$E(V,1,26) D VP53 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",102-$L(VL))_V ; [SYSDEV,DBTBL5H]STATINC1
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="           "_"Statistics:  "
	S VL=VL_$J("",24-24)_$E(vc73,1,25)
	S VL=VL_$J("",51-$L(VL))_"Based On:  "
	S VL=VL_$J("",62-$L(VL))_$E(vc74,1,25)
	D VP54 Q:VFMQ!$get(verror)  S V=$E(INCTXT,1,11)
	S VL=VL_$J("",89-$L(VL))_V
	S V=vc75 S VO=V S V=$E(V,1,26) D VP55 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",102-$L(VL))_V ; [SYSDEV,DBTBL5H]STATINC1
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="           "_"Statistics:  "
	S VL=VL_$J("",24-24)_$E(vc73,1,25)
	S VL=VL_$J("",51-$L(VL))_"Based On:  "
	S VL=VL_$J("",62-$L(VL))_$E(vc74,1,25)
	D VP56 Q:VFMQ!$get(verror)  S V=$E(INCTXT,1,11)
	S VL=VL_$J("",89-$L(VL))_V
	S V=vc75 S VO=V S V=$E(V,1,26) D VP57 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",102-$L(VL))_V ; [SYSDEV,DBTBL5H]STATINC1
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S VL="           "_"Statistics:  "
	S VL=VL_$J("",24-24)_$E(vc73,1,25)
	S VL=VL_$J("",51-$L(VL))_"Based On:  "
	S VL=VL_$J("",62-$L(VL))_$E(vc74,1,25)
	D VP58 Q:VFMQ!$get(verror)  S V=$E(INCTXT,1,11)
	S VL=VL_$J("",89-$L(VL))_V
	S V=vc75 S VO=V S V=$E(V,1,26) D VP59 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",102-$L(VL))_V ; [SYSDEV,DBTBL5H]STATINC1
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	S VL="" D VOM
	D VP60 Q:VFMQ!$get(verror)  S V=$E(ZPREPP,1,100) S VL="                         "_V
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	Q 
	;
VSUM5	; Summary
	;
	I 'VT(5) Q 
	I VLC+0>IOSL D VHDG0 Q:VFMQ 
	;
	S VL="------------------------------------------------------------------------------------------------------------------------------------"
	D VOM
	Q 
	;
VHDG6	; Group Header
	;
	Q:vh(6)  S vh(6)=1 ; Print flag
	I VLC+3>IOSL D VHDG0 Q:VFMQ 
	;
	S VL="------------------------------------------------------------------------------------------------------------------------------------"
	D VOM
	S VL="                   "_"-----------"
	S VL=VL_$J("",34-30)_$E(vc4,1,25)
	D VP61 Q:VFMQ!$get(verror)  S V=$E(ZKEYDESC,1,35)
	S VL=VL_$J("",62-$L(VL))_V
	S VL=VL_$J("",99-$L(VL))_"----------"
	D VP62 Q:VFMQ!$get(verror)  S V=$E(ZSEC,1,10)
	S VL=VL_$J("",114-$L(VL))_V
	D VOM
	S VL="" D VOM
	Q 
	;
VDTL6	; Detail
	;
	I VLC+1>IOSL D VHDG0 Q:VFMQ 
	;
	S VL=" "_$E(vc6,1,30)
	S V=vc7 S VO=V D VP63 Q:VFMQ!$get(verror)  S V=$E(V,1,40)
	S VL=VL_$J("",33-$L(VL))_V ; [SYSDEV,DBTBL5D]PROMPT
	S VL=VL_$J("",76-$L(VL))_$J(vc8,3)
	S VL=VL_$J("",81-$L(VL))_$E(vc9,1,12)
	D VP64 Q:VFMQ!$get(verror)  S V=$J(ZLINE,3)
	S VL=VL_$J("",95-$L(VL))_V
	S VL=VL_$J("",101-$L(VL))_$J(vc10,3)
	S VL=VL_$J("",108-$L(VL))_$E(ZSECTION,1,8)
	D VP65 Q:VFMQ!$get(verror)  S V=$E(ZSBL,1)
	S VL=VL_$J("",119-$L(VL))_V
	D VP66 Q:VFMQ!$get(verror)  S V=$E(ZSLF,1)
	S VL=VL_$J("",123-$L(VL))_V
	D VP67 Q:VFMQ!$get(verror)  S V=$E(ZREPEAT,1)
	S VL=VL_$J("",127-$L(VL))_V
	I VLC+1>IOSL D VHDG0 Q:VFMQ 
	D VOM
	D VP68 Q:VFMQ!$get(verror)  S V=$E(ZPREPP,1,40) S VL="                         "_V
	I VLC+1>IOSL D VHDG0 Q:VFMQ 
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
	.	E  S VLC=VLC+6 S VPN=VPN+1
	.	Q 
	;
	S ER=0 S VPN=VPN+1 S VLC=0
	;
	S VL=$E(($get(CONAM)),1,45)
	S VL=VL_$J("",100-$L(VL))_"Run Date:"
	S VL=VL_$J("",110-$L(VL))_$E(vrundate,1,10)
	S VL=VL_$J("",123-$L(VL))_$E(%TIM,1,8)
	D VOM
	S VL=RN_"  ("_vc2_")"
	S VL=VL_$J("",102-$L(VL))_"System:"
	S VL=VL_$J("",110-$L(VL))_$E(vsysdate,1,10)
	S VL=VL_$J("",122-$L(VL))_"Page:"
	S VL=VL_$J("",128-$L(VL))_$E(($J(VPN,3)),1,3)
	D VOM
	S VL="" D VOM
	S VL="                                                                                                            "_"Region  Suppress  Repeat"
	D VOM
	S VL=" "_"Item Name                       Text/Function/Variable                    Size  Format       Line  Column  (H,D,T)  Line  LF Field"
	D VOM
	S VL="===================================================================================================================================="
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
VP1	; Column pre-processor - Variable: SEQDESC
	;
	S SEQDESC=$$GETDESC(vc23)
	Q 
	;
GETDESC(DATA)	;
	N vret
	N DI N FID
	;
	I DATA="" Q ""
	;
	S FID=$piece(DATA,"]",1)
	I FID["," S FID=$piece(FID,",",2)
	E  S FID=$piece(FID,"[",2)
	S DI=$piece(DATA,"]",2)
	N dbtbl1d S dbtbl1d=$G(^DBTBL("SYSDEV",1,FID,9,DI))
	S vret=$P(dbtbl1d,$C(124),10) Q vret
	;
VP2	; Column pre-processor - Variable: SEQDESC
	;
	S SEQDESC=$$GETDESC(vc28)
	Q 
	;
VP3	; Column post-processor - [SYSDEV,DBTBL5H]SORTORD2
	;
	; Blank suppress the line
	I vc28="" S (V,VL)=""
	Q 
	;
VP4	; Column pre-processor - Variable: SEQDESC
	;
	S SEQDESC=$$GETDESC(vc33)
	Q 
	;
VP5	; Column post-processor - [SYSDEV,DBTBL5H]SORTORD3
	;
	; Blank suppress the line
	I vc33="" S (V,VL)=""
	Q 
	;
VP6	; Column pre-processor - Variable: SEQDESC
	;
	S SEQDESC=$$GETDESC(vc38)
	Q 
	;
VP7	; Column post-processor - [SYSDEV,DBTBL5H]SORTORD4
	;
	; Blank suppress the line
	I vc38="" S (V,VL)=""
	Q 
	;
VP8	; Column pre-processor - Variable: SEQDESC
	;
	S SEQDESC=$$GETDESC(vc43)
	Q 
	;
VP9	; Column post-processor - [SYSDEV,DBTBL5H]SORTORD5
	;
	; Blank suppress the line
	I vc43="" S (V,VL)=""
	Q 
	;
VP10	; Column pre-processor - Variable: SEQDESC
	;
	S SEQDESC=$$GETDESC(vc48)
	Q 
	;
VP11	; Column post-processor - [SYSDEV,DBTBL5H]SORTORD6
	;
	; Blank suppress the line
	I vc48="" S (V,VL)=""
	Q 
	;
VP12	; Column pre-processor - Variable: SEQDESC
	;
	S SEQDESC=$$GETDESC(vc53)
	Q 
	;
VP13	; Column post-processor - [SYSDEV,DBTBL5H]SORTORD7
	;
	; Blank suppress the line
	I vc53="" S (V,VL)=""
	Q 
	;
VP14	; Column pre-processor - Variable: SEQDESC
	;
	S SEQDESC=$$GETDESC(vc58)
	Q 
	;
VP15	; Column post-processor - [SYSDEV,DBTBL5H]SORTORD8
	;
	; Blank suppress the line
	I vc58="" S (V,VL)=""
	Q 
	;
VP16	; Column pre-processor - Variable: SEQDESC
	;
	S SEQDESC=$$GETDESC(vc63)
	Q 
	;
VP17	; Column post-processor - [SYSDEV,DBTBL5H]SORTORD9
	;
	; Blank suppress the line
	I vc63="" S (V,VL)=""
	Q 
	;
VP18	; Column pre-processor - Variable: SEQDESC
	;
	S SEQDESC=$$GETDESC(vc68)
	Q 
	;
VP19	; Column post-processor - [SYSDEV,DBTBL5H]SORTORD10
	;
	; Blank suppress the line
	I vc68="" S (V,VL)=""
	Q 
	;
VP20	; Column pre-processor - Variable: INCTXT
	;
	I vc75'="" S INCTXT="Increments:"
	E  S INCTXT=""
	Q 
	;
VP21	; Column post-processor - [SYSDEV,DBTBL5H]STATINC1
	;
	; Blank line if no info
	I vc74="" S (V,VL)=""
	Q 
	;
VP22	; Column pre-processor - Variable: INCTXT
	;
	I vc75'="" S INCTXT="Increments:"
	E  S INCTXT=""
	Q 
	;
VP23	; Column post-processor - [SYSDEV,DBTBL5H]STATINC1
	;
	; Blank line if no info
	I vc74="" S (V,VL)=""
	Q 
	;
VP24	; Column pre-processor - Variable: INCTXT
	;
	I vc75'="" S INCTXT="Increments:"
	E  S INCTXT=""
	Q 
	;
VP25	; Column post-processor - [SYSDEV,DBTBL5H]STATINC1
	;
	; Blank line if no info
	I vc74="" S (V,VL)=""
	Q 
	;
VP26	; Column pre-processor - Variable: INCTXT
	;
	I vc75'="" S INCTXT="Increments:"
	E  S INCTXT=""
	Q 
	;
VP27	; Column post-processor - [SYSDEV,DBTBL5H]STATINC1
	;
	; Blank line if no info
	I vc74="" S (V,VL)=""
	Q 
	;
VP28	; Column pre-processor - Variable: INCTXT
	;
	I vc75'="" S INCTXT="Increments:"
	E  S INCTXT=""
	Q 
	;
VP29	; Column post-processor - [SYSDEV,DBTBL5H]STATINC1
	;
	; Blank line if no info
	I vc74="" S (V,VL)=""
	Q 
	;
VP30	; Column pre-processor - Variable: INCTXT
	;
	I vc75'="" S INCTXT="Increments:"
	E  S INCTXT=""
	Q 
	;
VP31	; Column post-processor - [SYSDEV,DBTBL5H]STATINC1
	;
	; Blank line if no info
	I vc74="" S (V,VL)=""
	Q 
	;
VP32	; Column pre-processor - Variable: INCTXT
	;
	I vc75'="" S INCTXT="Increments:"
	E  S INCTXT=""
	Q 
	;
VP33	; Column post-processor - [SYSDEV,DBTBL5H]STATINC1
	;
	; Blank line if no info
	I vc74="" S (V,VL)=""
	Q 
	;
VP34	; Column pre-processor - Variable: INCTXT
	;
	I vc75'="" S INCTXT="Increments:"
	E  S INCTXT=""
	Q 
	;
VP35	; Column post-processor - [SYSDEV,DBTBL5H]STATINC1
	;
	; Blank line if no info
	I vc74="" S (V,VL)=""
	Q 
	;
VP36	; Column pre-processor - Variable: INCTXT
	;
	I vc75'="" S INCTXT="Increments:"
	E  S INCTXT=""
	Q 
	;
VP37	; Column post-processor - [SYSDEV,DBTBL5H]STATINC1
	;
	; Blank line if no info
	I vc74="" S (V,VL)=""
	Q 
	;
VP38	; Column pre-processor - Variable: INCTXT
	;
	I vc75'="" S INCTXT="Increments:"
	E  S INCTXT=""
	Q 
	;
VP39	; Column post-processor - [SYSDEV,DBTBL5H]STATINC1
	;
	; Blank line if no info
	I vc74="" S (V,VL)=""
	Q 
	;
VP40	; Column pre-processor - Variable: INCTXT
	;
	I vc75'="" S INCTXT="Increments:"
	E  S INCTXT=""
	Q 
	;
VP41	; Column post-processor - [SYSDEV,DBTBL5H]STATINC1
	;
	; Blank line if no info
	I vc74="" S (V,VL)=""
	Q 
	;
VP42	; Column pre-processor - Variable: INCTXT
	;
	I vc75'="" S INCTXT="Increments:"
	E  S INCTXT=""
	Q 
	;
VP43	; Column post-processor - [SYSDEV,DBTBL5H]STATINC1
	;
	; Blank line if no info
	I vc74="" S (V,VL)=""
	Q 
	;
VP44	; Column pre-processor - Variable: INCTXT
	;
	I vc75'="" S INCTXT="Increments:"
	E  S INCTXT=""
	Q 
	;
VP45	; Column post-processor - [SYSDEV,DBTBL5H]STATINC1
	;
	; Blank line if no info
	I vc74="" S (V,VL)=""
	Q 
	;
VP46	; Column pre-processor - Variable: INCTXT
	;
	I vc75'="" S INCTXT="Increments:"
	E  S INCTXT=""
	Q 
	;
VP47	; Column post-processor - [SYSDEV,DBTBL5H]STATINC1
	;
	; Blank line if no info
	I vc74="" S (V,VL)=""
	Q 
	;
VP48	; Column pre-processor - Variable: INCTXT
	;
	I vc75'="" S INCTXT="Increments:"
	E  S INCTXT=""
	Q 
	;
VP49	; Column post-processor - [SYSDEV,DBTBL5H]STATINC1
	;
	; Blank line if no info
	I vc74="" S (V,VL)=""
	Q 
	;
VP50	; Column pre-processor - Variable: INCTXT
	;
	I vc75'="" S INCTXT="Increments:"
	E  S INCTXT=""
	Q 
	;
VP51	; Column post-processor - [SYSDEV,DBTBL5H]STATINC1
	;
	; Blank line if no info
	I vc74="" S (V,VL)=""
	Q 
	;
VP52	; Column pre-processor - Variable: INCTXT
	;
	I vc75'="" S INCTXT="Increments:"
	E  S INCTXT=""
	Q 
	;
VP53	; Column post-processor - [SYSDEV,DBTBL5H]STATINC1
	;
	; Blank line if no info
	I vc74="" S (V,VL)=""
	Q 
	;
VP54	; Column pre-processor - Variable: INCTXT
	;
	I vc75'="" S INCTXT="Increments:"
	E  S INCTXT=""
	Q 
	;
VP55	; Column post-processor - [SYSDEV,DBTBL5H]STATINC1
	;
	; Blank line if no info
	I vc74="" S (V,VL)=""
	Q 
	;
VP56	; Column pre-processor - Variable: INCTXT
	;
	I vc75'="" S INCTXT="Increments:"
	E  S INCTXT=""
	Q 
	;
VP57	; Column post-processor - [SYSDEV,DBTBL5H]STATINC1
	;
	; Blank line if no info
	I vc74="" S (V,VL)=""
	Q 
	;
VP58	; Column pre-processor - Variable: INCTXT
	;
	I vc75'="" S INCTXT="Increments:"
	E  S INCTXT=""
	Q 
	;
VP59	; Column post-processor - [SYSDEV,DBTBL5H]STATINC1
	;
	; Blank line if no info
	I vc74="" S (V,VL)=""
	Q 
	;
VP60	; Column pre-processor - Variable: ZPREPP
	;
	N SEQ
	N RID
	;
	S RID=vc2
	;
	; I18N=OFF: Excluded from I18N standards
	S verror=0
	F SEQ=91,111,31,51,71,201:20:281 D ZDBSPP5(SEQ,RID) Q:verror 
	;
	S ZPREPP=""
	Q 
	;
ZDBSPP5(SEQ,RID)	;
	N vpc
	;
	N END N START
	;
	S START=SEQ-.001 S END=SEQ+20
	; I18N=OFF
	N rs,vos1,vos2,vos3,vos4,vos5,vos6 S rs=$$vOpen1()
	S vpc=('$G(vos1)) Q:vpc 
	I SEQ=31 S VL="Query"
	E  I SEQ=51 S VL="Report Pre-Processor (After QUERY)"
	E  I SEQ=71 S VL="Report Post-Processor"
	E  I SEQ=91 S VL="Documentation"
	E  I SEQ=111 S VL="Report Pre-Processor (Before QUERY)"
	E  I SEQ=201 S VL="OPEN Pre-Processor"
	E  I SEQ=221 S VL="OPEN post-Processor"
	E  I SEQ=241 S VL="FETCH Pre-Processor"
	E  I SEQ=261 S VL="FETCH post-Processor"
	E  I SEQ=281 S VL="PRINT Pre-Processor"
	E  S VL=""
	S VL="                         "_"<"_VL_">" D ZPPDSP Q:verror 
	S VL=" " D ZPPDSP Q:verror 
	F  Q:'($$vFetch1())  D  Q:verror 
	.	S VL="                         "_rs
	.	D ZPPDSP Q:verror 
	.	Q 
	S VL=" " D ZPPDSP Q:verror 
	Q 
	;
	; I18N=ON
	;
VP61	; Column pre-processor - Variable: ZKEYDESC
	;
	N X
	;
	; I18N=OFF : excluded from I18N standards.
	; ---------- Report Section Description
	;
	S X=vc4
	I X="@PH" S ZKEYDESC="Page Header & Trailer"
	E  I X="@RS" S ZKEYDESC="Report Summary"
	E  I X'?1"["1E.E1"]"1E.E S ZKEYDESC=""
	E  D
	.	N DI N FID
	.	;
	.	S FID=$piece($piece(X,",",2),"]",1)
	.	S DI=$piece(X,"]",2)
	.	N dbtbl1d S dbtbl1d=$G(^DBTBL("SYSDEV",1,FID,9,DI))
	.	S ZKEYDESC=$P(dbtbl1d,$C(124),10)
	.	Q 
	; I18N=ON
	Q 
	;
VP62	; Column pre-processor - Variable: ZSEC
	;
	N GRP
	S GRP=vc4
	N db5dgc,vop1,vop2,vop3,vop4,vop5,vop6 S vop1="SYSDEV",vop2=RID,vop3=GRP,db5dgc=$$vDb3("SYSDEV",RID,GRP)
	 S db5dgc=$G(^DBTBL(vop1,5,vop2,vop3,0))
	 S vop5=$G(^DBTBL(vop1,5,vop2,vop3,26))
	 S vop6=$G(^DBTBL(vop1,5,vop2,vop3,27))
	 S vop4=$G(^DBTBL(vop1,5,vop2,vop3,25))
	S ZSEC=$P(db5dgc,$C(124),1)
	S ZZSBL=$P(vop5,$C(124),1) ; Suppress blank line indicator
	S ZZSLF=$P(vop6,$C(124),1) ; Suppress line feed indicator
	; Repeat count
	S ZZREP=$P(vop4,$C(124),1)_","_$P(vop4,$C(124),2)_","_$P(vop4,$C(124),3)_","_$P(vop4,$C(124),4)
	Q 
	;
VP63	; Column pre-processor - [SYSDEV,DBTBL5D]PROMPT
	;
	S V=$TR(V,$char(128),$char(124))
	Q 
	;
VP64	; Column pre-processor - Variable: ZLINE
	;
	N H1 N H2
	N X N Y
	;
	S X=ZSEC
	S Y=vc76
	S H1=X+$piece(X,",",2)+1
	S H2=X+1
	;
	I Y>H1 D
	.	S ZSECTION="Trailer"
	.	S ZLINE=Y-H1-1
	.	Q 
	E  I Y>H2 D
	.	S ZSECTION="Detail"
	.	S ZLINE=Y-X-1
	.	Q 
	E  D
	.	S ZSECTION="Header"
	.	S ZLINE=Y
	.	Q 
	;
	Q 
	;
VP65	; Column pre-processor - Variable: ZSBL
	;
	N I N L
	N X
	;
	S ZSBL=""
	Q:$get(ZZSBL)="" 
	;
	S L=$L(ZZSBL,",")
	F I=1:1:L S X=$piece(ZZSBL,",",I) Q:X=""  D  Q:ZSBL="Y" 
	.	N FROM N TO
	.	S FROM=+X
	.	I X["-" S TO=$piece(X,"-",2)
	.	E  S TO=FROM
	.	I vc76'<FROM,vc76'>TO S ZSBL="Y"
	.	Q 
	Q 
	;
VP66	; Column pre-processor - Variable: ZSLF
	;
	; ---------- Suppress line feed ?
	;
	S ZSLF=$S(+ZZSLF=vc76:"Y",1:"")
	Q 
	;
VP67	; Column pre-processor - Variable: ZREPEAT
	;
	S ZREPEAT=""
	Q:ZZREP="" 
	I vc76'<ZZREP,vc76'>$piece(ZZREP,"|",2) S ZREPEAT="Y"
	Q 
	;
VP68	; Column pre-processor - Variable: ZPREPP
	;
	N ITMSEQ N SEQ
	N GRP N RID
	S verror=0
	S GRP=vc4
	S ITMSEQ=vc5
	S RID=vc2
	F SEQ=1,21 D ZDBSPP1(GRP,ITMSEQ,SEQ,RID) Q:verror 
	Q 
ZDBSPP1(GRP,ITMSEQ,SEQ,RID)	;
	N vpc
	N END N START
	S START=SEQ-.001 S END=SEQ+20
	; I18N=OFF
	N rs,vos1,vos2,vos3,vos4,vos5,vos6,vos7,vos8 S rs=$$vOpen2()
	S vpc=('$G(vos1)) Q:vpc 
	I SEQ=1 S VL="Pre-Processor"
	E  I SEQ=21 S VL="Post-Processor"
	E  S VL=""
	S VL="                         "_"<"_VL_">" D ZPPDSP Q:verror 
	S VL=" " D ZPPDSP Q:verror 
	F  Q:'($$vFetch2())  D
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
	;
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
vDb3(v1,v2,v3)	;	voXN = Db.getRecord(DBTBL5DGC,,1)
	;
	I '(v3]]"@")
	E  I '$D(^DBTBL(v1,5,v2,v3))
	;
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
vOpen1()	;	DATA FROM DBTBL5PR WHERE LIBS='SYSDEV' AND RID=:RID AND SEQ>:START AND SEQ<:END ORDER BY SEQ ASC
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(RID) I vos2="" G vL1a0
	S vos3=$G(START) I vos3="",'$D(START) G vL1a0
	S vos4=$G(END) I vos4="",'$D(END) G vL1a0
	S vos5=30.999
vL1a5	S vos5=$O(^DBTBL("SYSDEV",5,vos2,vos5),1) I vos5=""!(vos4']]vos5) G vL1a0
	I '(vos5]]vos3) G vL1a5
	Q
	;
vFetch1()	;
	;
	I vos1=1 D vL1a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos6=$G(^DBTBL("SYSDEV",5,vos2,vos5))
	S rs=$P(vos6,$C(12),1)
	;
	Q 1
	;
vOpen2()	;	DATA FROM DBTBL5D1 WHERE LIBS='SYSDEV' AND RID=:RID AND GRP=:GRP AND ITMSEQ=:ITMSEQ AND SEQ>:START AND SEQ<:END ORDER BY SEQ ASC
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(RID) I vos2="" G vL2a0
	S vos3=$G(GRP) I vos3="" G vL2a0
	S vos4=$G(ITMSEQ) I vos4="" G vL2a0
	S vos5=$G(START) I vos5="",'$D(START) G vL2a0
	S vos5=+vos5
	S vos6=$G(END) I vos6="",'$D(END) G vL2a0
	S vos6=+vos6
	I '(vos4>100) G vL2a0
	S vos7=vos5
vL2a10	S vos7=$O(^DBTBL("SYSDEV",5,vos2,vos3,vos4,vos7),1) I vos7=""!(vos7'<vos6) G vL2a0
	Q
	;
vFetch2()	;
	;
	I vos1=1 D vL2a10
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos8=$G(^DBTBL("SYSDEV",5,vos2,vos3,vos4,vos7))
	S rs=$P(vos8,$C(12),1)
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
