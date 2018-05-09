R01S244	; DBSFILLST - Data Dictionary Listing
	;
	; **** Routine compiled from DATA-QWIK Report DBSFILLST ****
	;
	; 09/14/2007 10:49 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/14/2007 10:49 - chenardp
	;
	 S ER=0
	N OLNTB
	N %READ N RID N RN N %TAB N VFMQ
	N VIN2 S VIN2="ALL"
	;
	S RID="DBSFILLST"
	S RN="Data Dictionary Listing"
	I $get(IO)="" S IO=$I
	;
	D INIT^%ZM()
	;
	D VPREBQ Q:$get(VFMQ)  ; Pre-processor (before query)
	;
	S %TAB("IO")=$$IO^SCATAB
	S %TAB("VIN2")="|255||[DBTBL1D]FID|[DBTBL1]:NOVAL||D EXT^DBSQRY||T|File Name|||||"
	;
	S %READ="IO/REQ,VIN2#0,"
	;
	; Skip device prompt option
	I $get(VRWOPT("NOOPEN")) S %READ="VIN2#0,"
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
	N %TIM N CONAM N DC N DC2 N RID N RN N VL N VLOF N VRF N VSTATS N ZEXTRA N ZZLOC N vCOL N vHDG N vc1 N vc10 N vc11 N vc12 N vc13 N vc14 N vc15 N vc16 N vc17 N vc18 N vc19 N vc2 N vc20 N vc21 N vc22 N vc23 N vc24 N vc25 N vc26 N vc27 N vc28 N vc29 N vc3 N vc30 N vc31 N vc32 N vc33 N vc34 N vc35 N vc36 N vc37 N vc4 N vc5 N vc6 N vc7 N vc8 N vc9 N vorder N vovc1 N vovc2 N vovc3 N vrundate N vsysdate
	;
	S CONAM="DATA-QWIK 7.2"
	S ER=0 S RID="DBSFILLST" S RN="Data Dictionary Listing"
	S VL=""
	;
	USE 0 I '$get(VRWOPT("NOOPEN")) D  Q:ER 
	.	I '($get(VRWOPT("IOPAR"))="") S IOPAR=VRWOPT("IOPAR")
	.	E  I (($get(IOTYP)="RMS")!($get(IOTYP)="PNTQ")),('($get(IOPAR)["/OCHSET=")),$$VALID^%ZRTNS("UCIOENCD") D
	..		; Accept warning if ^UCIOENCD does not exist
	..		;    #ACCEPT Date=07/26/06; Pgm=RussellDS; CR=22121; Group=MISMATCH
	..		N CHRSET S CHRSET=$$^UCIOENCD("Report","DBSFILLST","V0","*")
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
	S vCOL="[DBTBL1D]DI#1#80\[DBTBL1D]NOD#22#10,[DBTBL1D]POS#33#2,[DBTBL1D]DES#36#40,[DBTBL1D]LEN#77#2,[DBTBL1D]TYP#81#3,[DBTBL1D]DEC#86#2,[DBTBL1D]REQ#90#1"
	;
	; Build WHERE clause to use for dynamic query
	D
	.	N SEQ S SEQ=1
	.	N DQQRY N FROM
	.	S DQQRY(1)="[DBTBL1D]%LIBS=""SYSDEV""" S SEQ=SEQ+1
	.	I $get(VIN2)="" S VIN2="ALL"
	.	I VIN2'="ALL" S DQQRY(2)="[DBTBL1D]FID "_VIN2 S SEQ=SEQ+1
	.	S FROM=$$DQJOIN^SQLCONV("DBTBL1D,DBTBL1") Q:ER 
	.	S VWHERE=$$WHERE^SQLCONV(.DQQRY,"")
	.	Q 
	;
	; Initialize variables
	S (vc1,vc2,vc3,vc4,vc5,vc6,vc7,vc8,vc9,vc10,vc11,vc12,vc13,vc14,vc15,vc16,vc17,vc18,vc19,vc20,vc21,vc22,vc23,vc24,vc25,vc26,vc27,vc28,vc29,vc30,vc31,vc32,vc33,vc34,vc35,vc36,vc37)=""
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
	D VOPRE I VFMQ D VEXIT(0) Q 
	;
	S VWHERE=""
	I '($D(vorder)#2) S vorder="DBTBL1D.%LIBS,DBTBL1D.FID,DBTBL1D.DI"
	I ($D(vudwhere)#2) S VWHERE=vudwhere
	;  #ACCEPT DATE=09/14/2007;PGM=Report Writer Generator;CR=20967
	N rwrs,vos1,vos2,sqlcur,exe,sqlcur,vd,vi,vsql,vsub S rwrs=$$vOpen0(.exe,.vsql,"DBTBL1D.%LIBS,DBTBL1D.FID,DBTBL1D.DI,DBTBL1.DES,DBTBL1.GLOBAL,DBTBL1.FILETYP,DBTBL1.RECTYP,DBTBL1.DEL,DBTBL1.FSN,DBTBL1.FDOC,DBTBL1.PARFID,DBTBL1.ACCKEYS,DBTBL1.UDFILE,DBTBL1.UDACC,DBTBL1.DFTDES,DBTBL1.QID1,DBTBL1D.NOD,DBTBL1D.POS,DBTBL1D.DES,DBTBL1D.LEN,DBTBL1D.TYP,DBTBL1D.DEC,DBTBL1D.REQ,DBTBL1.NETLOC,DBTBL1D.CMP,DBTBL1D.TBL,DBTBL1D.DFT,DBTBL1D.PTN,DBTBL1D.MIN,DBTBL1D.MAX,DBTBL1D.XPR,DBTBL1D.XPO,DBTBL1D.DEPREP,DBTBL1D.DEPOSTP,DBTBL1D.MDD,DBTBL1D.DOM,DBTBL1D.SFD","DBTBL1D,DBTBL1",VWHERE,vorder,"","/DQMODE=1")
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
	S vovc1="" S vovc2="" S vovc3=""
	Q 
	;
VSAVLAST	; Save last access keys values
	S vovc1=vc1 S vovc2=vc2 S vovc3=vc3
	Q 
	;
VGETDATA(V,VI)	;
	S vc1=$piece(V,$char(9),1) ; DBTBL1D.%LIBS
	S vc2=$piece(V,$char(9),2) ; DBTBL1D.FID
	S vc3=$piece(V,$char(9),3) ; DBTBL1D.DI
	S vc4=$piece(V,$char(9),4) ; DBTBL1.DES
	S vc5=$piece(V,$char(9),5) ; DBTBL1.GLOBAL
	S vc6=$piece(V,$char(9),6) ; DBTBL1.FILETYP
	S vc7=$piece(V,$char(9),7) ; DBTBL1.RECTYP
	S vc8=$piece(V,$char(9),8) ; DBTBL1.DEL
	S vc9=$piece(V,$char(9),9) ; DBTBL1.FSN
	S vc10=$piece(V,$char(9),10) ; DBTBL1.FDOC
	S vc11=$piece(V,$char(9),11) ; DBTBL1.PARFID
	S vc12=$piece(V,$char(9),12) ; DBTBL1.ACCKEYS
	S vc13=$piece(V,$char(9),13) ; DBTBL1.UDFILE
	S vc14=$piece(V,$char(9),14) ; DBTBL1.UDACC
	S vc15=$piece(V,$char(9),15) ; DBTBL1.DFTDES
	S vc16=$piece(V,$char(9),16) ; DBTBL1.QID1
	S vc17=$piece(V,$char(9),17) ; DBTBL1D.NOD
	S vc18=$piece(V,$char(9),18) ; DBTBL1D.POS
	S vc19=$piece(V,$char(9),19) ; DBTBL1D.DES
	S vc20=$piece(V,$char(9),20) ; DBTBL1D.LEN
	S vc21=$piece(V,$char(9),21) ; DBTBL1D.TYP
	S vc22=$piece(V,$char(9),22) ; DBTBL1D.DEC
	S vc23=$piece(V,$char(9),23) ; DBTBL1D.REQ
	S vc24=$piece(V,$char(9),24) ; DBTBL1.NETLOC
	S vc25=$piece(V,$char(9),25) ; DBTBL1D.CMP
	S vc26=$piece(V,$char(9),26) ; DBTBL1D.TBL
	S vc27=$piece(V,$char(9),27) ; DBTBL1D.DFT
	S vc28=$piece(V,$char(9),28) ; DBTBL1D.PTN
	S vc29=$piece(V,$char(9),29) ; DBTBL1D.MIN
	S vc30=$piece(V,$char(9),30) ; DBTBL1D.MAX
	S vc31=$piece(V,$char(9),31) ; DBTBL1D.XPR
	S vc32=$piece(V,$char(9),32) ; DBTBL1D.XPO
	S vc33=$piece(V,$char(9),33) ; DBTBL1D.DEPREP
	S vc34=$piece(V,$char(9),34) ; DBTBL1D.DEPOSTP
	S vc35=$piece(V,$char(9),35) ; DBTBL1D.MDD
	S vc36=$piece(V,$char(9),36) ; DBTBL1D.DOM
	S vc37=$piece(V,$char(9),37) ; DBTBL1D.SFD
	Q 
	;
	; User-defined pre/post-processor code
	;
VOPRE	; OPEN pre-processor
	;
	I $get(SORT)'="" S vorder="DBTBL1D.FID,"_SORT_",DBTBL1D.DI"
	Q 
	;
VPREBQ	; Pre-processor (before query)
	;
	;Incoming=DOC,FID,SORT,vudwhere
	S DOC=0 S SORT=""
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
	S vs(1)=0 S vs(2)=0 S vs(3)=0
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
	I $get(VRWOPT("NODTL")) S vskp(1)=1 S vskp(2)=1 S vskp(3)=1 ; Skip detail
	D VBREAK
	D VSUM Q:VFMQ 
	;
	I $get(VH0) S vh(0)=0 S VNEWHDR=1 K VH0 ; Page Break
	I 'vh(0) D VHDG0 Q:VFMQ 
	D VHDG3 Q:VFMQ 
	I '$get(vskp(3)) D VDTL3 Q:VFMQ 
	D VSTAT
	Q 
	;
VBREAK	;
	Q:'VT(3) 
	N vb1 N vb2 N vb3
	S (vb1,vb2,vb3)=0
	I 0!(vovc1'=vc1) S vs(2)=0 S vh(2)=0 S VD(1)=0 S vb2=1 S vb3=1
	I vb2!(vovc2'=vc2) S vs(3)=0 S vh(3)=0 S VD(2)=0 S vb3=1
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
VHDG3	; Group Header
	;
	Q:vh(3)  S vh(3)=1 ; Print flag
	I VLC+12>IOSL D VHDG0 Q:VFMQ 
	;
	S VL="------------------------------------------------------------------------------------------------------------------------------------"
	D VOM
	S VL=$E(vc2,1,70)
	D VOM
	S VL="             "_$E(vc4,1,31)
	S VL=VL_$J("",45-$L(VL))_"Global:"
	S VL=VL_$J("",53-$L(VL))_$E(vc5,1,8)
	S VL=VL_$J("",63-$L(VL))_"File Type:"
	S VL=VL_$J("",74-$L(VL))_$J(vc6,1)
	S VL=VL_$J("",77-$L(VL))_"Record Type:"
	S VL=VL_$J("",90-$L(VL))_$J(vc7,2)
	S VL=VL_$J("",94-$L(VL))_"Delimiter:"
	S VL=VL_$J("",105-$L(VL))_$J(vc8,3)
	S VL=VL_$J("",110-$L(VL))_"Location:"
	D VP1 Q:VFMQ!$get(verror)  S V=$E(ZZLOC,1,11)
	S VL=VL_$J("",120-$L(VL))_V
	D VOM
	S VL="                                         "_"Short Name:"
	S VL=VL_$J("",53-52)_$E(vc9,1,8)
	S VL=VL_$J("",64-$L(VL))_"File Doc:"
	S VL=VL_$J("",74-$L(VL))_$E(vc10,1,11)
	S VL=VL_$J("",89-$L(VL))_"Supertype File Name:"
	S VL=VL_$J("",110-$L(VL))_$E(vc11,1,12)
	D VOM
	S VL="                                       "_"Primary Keys:"
	S VL=VL_$J("",53-52)_$E(vc12,1,78)
	D VOM
	S VL="                                      "_"Filer Routine:"
	S VL=VL_$J("",53-52)_$E(vc13,1,8)
	S VL=VL_$J("",64-$L(VL))_"Access Routine:"
	S VL=VL_$J("",80-$L(VL))_$E(vc14,1,8)
	D VOM
	S VL="                                      "_"Look-up Table:"
	S VL=VL_$J("",53-52)_$E(vc15,1,78)
	D VOM
	S VL="                                              "_"Query:"
	S VL=VL_$J("",53-52)_$E(vc16,1,78)
	D VOM
	S VL="------------------------------------------------------------------------------------------------------------------------------------"
	D VOM
	S V="--------------------------------------------------------------------------------" D VP2 Q:VFMQ!$get(verror)  S VL="                               "_V
	I '($translate(VL," ")="") D VOM
	D VP3 Q:VFMQ!$get(verror)  S V=$E(DC2,1,80) S VL="                               "_V
	I '($translate(VL," ")="") D VOM
	S V="--------------------------------------------------------------------------------" D VP4 Q:VFMQ!$get(verror)  S VL="                               "_V
	I '($translate(VL," ")="") D VOM
	Q 
	;
VDTL3	; Detail
	;
	I VLC+2>IOSL D VHDG0 Q:VFMQ  S vh(3)=0 D VHDG3 Q:VFMQ 
	;
	S VL=$E(vc3,1,80)
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	S V=vc17 S VO=V D VP5 Q:VFMQ!$get(verror)  S V=$E(V,1,10) S VL="                     "_V
	S VL=VL_$J("",32-$L(VL))_$J(vc18,2)
	S VL=VL_$J("",35-$L(VL))_$E(vc19,1,40)
	S VL=VL_$J("",76-$L(VL))_$J(vc20,2)
	S VL=VL_$J("",80-$L(VL))_$E(vc21,1,3)
	S VL=VL_$J("",85-$L(VL))_$J(vc22,2)
	S VL=VL_$J("",89-$L(VL))_$S(vc23:"Y",1:"N")
	D VP6 Q:VFMQ!$get(verror)  S V=$E(ZEXTRA,1,40) D VP7 Q:VFMQ!$get(verror) 
	S VL=VL_$J("",91-$L(VL))_V
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	I '($translate(VL," ")="") D VOM
	D VP8 Q:VFMQ!$get(verror)  S V=$E(DC,1,80) S VL="                               "_V
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
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
	S VL="Data Item            Field     Pos Description                             Size Type Dec Req"
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
VP1	; Column pre-processor - Variable: ZZLOC
	;
	; I18N=OFF: Excluded from I18N standards.
	S ZZLOC=""
	I vc24+0=0 S ZZLOC="Server Only" Q 
	I vc24=1 S ZZLOC="Client Only" Q 
	I vc24=2 S ZZLOC="Client and Server" Q 
	; I18N=ON
	Q 
	;
VP2	; Column post-processor - @CHR(-,80)
	;
	I 'DOC S (V,VL)=""
	Q 
	;
VP3	; Column pre-processor - Variable: DC2
	;
	N FID
	I 'DOC S DC2="" Q 
	S verror=0
	S FID=vc2
	; I18N=OFF
	N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen1()
	I ''$G(vos1) D
	.	F  Q:'($$vFetch1())  D  Q:verror 
	..		S DC2=rs
	..		S VL="                                "_DC2
	..		I VLC+1>IOSL D
	...			D VHDG0
	...			I VFMQ S verror=1
	...			Q 
	..		E  D VOM
	..		Q 
	.	Q 
	S DC2=""
	Q 
	;
VP4	; Column post-processor - @CHR(-,80)
	;
	I 'DOC S (V,VL)=""
	Q 
	;
VP5	; Column pre-processor - [SYSDEV,DBTBL1D]NOD
	;
	I V="" Q 
	I V["*" S V=$J(V,10) Q 
	S V=$J(V,10)
	Q 
	;
VP6	; Column pre-processor - Variable: ZEXTRA
	;
	S ZEXTRA=""
	Q 
	;
VP7	; Column post-processor - Variable: ZEXTRA
	;
	N ZI
	N CODE N TYPE N Z
	S verror=0
	S ZEXTRA=""
	S TYPE="Computed,Table,Default,Pattern,Minimum,Maximum,Scr_pre,Scr_pos,"
	S TYPE=TYPE_"Entry_pre,Entry_pos,MDD,DOMAIN"
	S CODE(1)=vc25
	S CODE(2)=vc26
	S CODE(3)=vc27
	S CODE(4)=vc28
	S CODE(5)=vc29
	S CODE(6)=vc30
	S CODE(7)=vc31
	S CODE(8)=vc32
	S CODE(9)=vc33
	S CODE(10)=vc34
	S CODE(11)=vc35
	S CODE(12)=vc36
	S CODE(13)=""
	;I18N=OFF
	I vc37'="" D
	.	S Z=vc37
	.	S Z=" Sub-field "_$char(($piece(Z,"~",2)))_$piece(Z,"~",4)
	.	S CODE(13)=Z
	.	Q 
	;I18N=ON
	F ZI=1:1:13 S Z=CODE(ZI) I Z'="" D  Q:verror 
	.	N X
	.	S X="  "_$J($piece(TYPE,",",ZI),9)_": "_Z
	.	I VL'="",$L(X)>41 D ZPNT Q:verror 
	.	I VL="" S VL="                                                                                         "
	.	S VL=VL_X I $L(VL)>132 S VL=$E(VL,$L(VL)-131,999)
	.	D ZPNT
	.	Q 
	Q 
ZPNT	;
	I VLC+1'>IOSL D VOM Q 
	D VHDG0 I VFMQ S verror=1 Q 
	Q 
	;
VP8	; Column pre-processor - Variable: DC
	;
	N FID N DI
	I 'DOC S DC="" Q 
	S FID=vc10
	S DI=vc3
	S verror=0
	; I18N=OFF
	N rs,vos1,vos2,vos3,vos4,vos5 S rs=$$vOpen2()
	I ''$G(vos1) D
	.	S VL="" D VOM ; Blank line
	.	F  Q:'($$vFetch2())  D  Q:verror 
	..		S DC=rs
	..		S VL="                                "_DC
	..		I VLC+1>IOSL D
	...			D VHDG0
	...			I VFMQ S verror=1
	...			Q 
	..		E  D VOM
	..		Q 
	.	S VL=""
	.	I VLC+2'>IOSL D VOM ; Blank line
	.	Q 
	S DC=""
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
vOpen1()	;	DES FROM DBTBL1TBLDOC WHERE %LIBS='SYSDEV' AND FID=:FID
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(FID) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^DBTBL("SYSDEV",1,vos2,0,vos3),1) I vos3="" G vL1a0
	Q
	;
vFetch1()	;
	;
	I vos1=1 D vL1a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos4=$G(^DBTBL("SYSDEV",1,vos2,0,vos3))
	S rs=$P(vos4,"|",1)
	;
	Q 1
	;
vOpen2()	;	DOC FROM DBTBL11D WHERE %LIBS='SYSDEV' AND FID=:FID AND DI=:DI
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(FID) I vos2="" G vL2a0
	S vos3=$G(DI) I vos3="" G vL2a0
	S vos4=""
vL2a4	S vos4=$O(^DBTBL("SYSDEV",11,vos2,vos3,vos4),1) I vos4="" G vL2a0
	Q
	;
vFetch2()	;
	;
	I vos1=1 D vL2a4
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos5=$G(^DBTBL("SYSDEV",11,vos2,vos3,vos4))
	S rs=$P(vos5,$C(1),1)
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
