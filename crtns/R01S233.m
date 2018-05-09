R01S233	; DBARCHIST - Archive History Report
	;
	; **** Routine compiled from DATA-QWIK Report DBARCHIST ****
	;
	; 09/14/2007 10:49 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/14/2007 10:49 - chenardp
	;
	 S ER=0
	N OLNTB
	N %READ N RID N RN N %TAB N VFMQ
	N VIN1 S VIN1="ALL"
	N VIN2 S VIN2="ALL"
	;
	S RID="DBARCHIST"
	S RN="Archive History Report"
	I $get(IO)="" S IO=$I
	;
	D INIT^%ZM()
	;
	S %TAB("IO")=$$IO^SCATAB
	S %TAB("VIN1")="|255||[DBARCHIST]ARCHTBL|[DBARCHIST]ARCHTBL:DISTINCT:NOVAL||D EXT^DBSQRY||T|Archive Table|||||"
	S %TAB("VIN2")="|255||[DBARCHIST]BEGDAT|||D EXT^DBSQRY||T|Process Start Date|||||"
	;
	S %READ="IO/REQ,VIN1#0,VIN2#0,"
	;
	; Skip device prompt option
	I $get(VRWOPT("NOOPEN")) S %READ="VIN1#0,VIN2#0,"
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
	N %TIM N CONAM N RID N RN N STP N VL N VLOF N VRF N VSTATS N vCOL N vHDG N vc1 N vc2 N vc3 N vc4 N vc5 N vc6 N vc7 N vc8 N vc9 N vovc1 N vovc2 N vrundate N vsysdate
	;
	N cuvar S cuvar=$$vDb2()
	 S cuvar=$G(^CUVAR("BANNER"))
	;
	S CONAM="DATA-QWIK 7.2"
	S ER=0 S RID="DBARCHIST" S RN="Archive History Report"
	S VL=""
	;
	USE 0 I '$get(VRWOPT("NOOPEN")) D  Q:ER 
	.	I '($get(VRWOPT("IOPAR"))="") S IOPAR=VRWOPT("IOPAR")
	.	E  I (($get(IOTYP)="RMS")!($get(IOTYP)="PNTQ")),('($get(IOPAR)["/OCHSET=")),$$VALID^%ZRTNS("UCIOENCD") D
	..		; Accept warning if ^UCIOENCD does not exist
	..		;    #ACCEPT Date=07/26/06; Pgm=RussellDS; CR=22121; Group=MISMATCH
	..		N CHRSET S CHRSET=$$^UCIOENCD("Report","DBARCHIST","V0","*")
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
	S vCOL="[DBARCHIST]ARCHSEQ#1#6,[DBARCHIST]BEGDAT#9#10,[DBARCHIST]BEGTIM#21#8,[DBARCHIST]ENDDAT#33#10,[DBARCHIST]ENDTIM#45#8,[DBARCHIST]PRIMCNT#57#15,[DBARCHIST]RECCNT#79#18"
	;
	; Build WHERE clause to use for dynamic query
	D
	.	N SEQ S SEQ=1
	.	N DQQRY N FROM
	.	I $get(VIN1)="" S VIN1="ALL"
	.	I VIN1'="ALL" S DQQRY(1)="[DBARCHIST]ARCHTBL "_VIN1 S SEQ=SEQ+1
	.	I $get(VIN2)="" S VIN2="ALL"
	.	I VIN2'="ALL" S DQQRY(SEQ)="[DBARCHIST]BEGDAT "_VIN2 S SEQ=SEQ+1
	.	S FROM=$$DQJOIN^SQLCONV("DBARCHIST") Q:ER 
	.	S VWHERE=$$WHERE^SQLCONV(.DQQRY,"")
	.	Q 
	;
	; Print Report Banner Page
	I $P(cuvar,$C(124),1),'$get(VRWOPT("NOBANNER")),IOTYP'="TRM",'$get(AUXPTR) D
	.	N VBNRINFO
	.	;
	.	S VBNRINFO("PROMPTS",1)="WC2|"_"Archive Table"_"|VIN1|"_$get(VIN1)
	.	S VBNRINFO("PROMPTS",2)="WC2|"_"Process Start Date"_"|VIN2|"_$get(VIN2)
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
	.	S VBNRINFO("DESC")="Archive History Report"
	.	S VBNRINFO("PGM")="R01S233"
	.	S VBNRINFO("RID")="DBARCHIST"
	.	S VBNRINFO("TABLES")="DBARCHIST"
	.	;
	.	S VBNRINFO("ORDERBY",1)="[SYSDEV,DBARCHIST]ARCHTBL"
	.	S VBNRINFO("ORDERBY",2)="[SYSDEV,DBARCHIST]ARCHSEQ"
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
	.	F I=0:1:2 D
	..		S (vh(I),VD(I))=0 S vs(I)=1 ; Group break flags
	..		S VT(I)=0 ; Group count
	..		F J=1:1:1 D
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
	;  #ACCEPT DATE=09/14/2007;PGM=Report Writer Generator;CR=20967
	N rwrs,vos1,vos2,sqlcur,exe,sqlcur,vd,vi,vsql,vsub S rwrs=$$vOpen0(.exe,.vsql,"DBARCHIST.ARCHTBL,DBARCHIST.ARCHSEQ,DBARCHIST.BEGDAT,DBARCHIST.BEGTIM,DBARCHIST.ENDDAT,DBARCHIST.ENDTIM,DBARCHIST.PRIMCNT,DBARCHIST.RECCNT,DBARCHIST.STOPPED","DBARCHIST",VWHERE,"DBARCHIST.ARCHTBL,DBARCHIST.ARCHSEQ","","/DQMODE=1")
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
	S vc1=$piece(V,$char(9),1) ; DBARCHIST.ARCHTBL
	S vc2=$piece(V,$char(9),2) ; DBARCHIST.ARCHSEQ
	S vc3=$piece(V,$char(9),3) ; DBARCHIST.BEGDAT
	S vc4=$piece(V,$char(9),4) ; DBARCHIST.BEGTIM
	S vc5=$piece(V,$char(9),5) ; DBARCHIST.ENDDAT
	S vc6=$piece(V,$char(9),6) ; DBARCHIST.ENDTIM
	S vc7=$piece(V,$char(9),7) ; DBARCHIST.PRIMCNT
	S vc8=$piece(V,$char(9),8) ; DBARCHIST.RECCNT
	S vc9=$piece(V,$char(9),9) ; DBARCHIST.STOPPED
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
	I $get(VRWOPT("NODTL")) S vskp(2)=1 ; Skip detail
	D VBREAK
	D VSUM Q:VFMQ 
	;
	I $get(VH0) S vh(0)=0 S VNEWHDR=1 K VH0 ; Page Break
	I 'vh(0) D VHDG0 Q:VFMQ 
	D VHDG2 Q:VFMQ 
	I '$get(vskp(2)) D VDTL2 Q:VFMQ 
	D VSTAT
	Q 
	;
VBREAK	;
	Q:'VT(2) 
	N vb1 N vb2
	S (vb1,vb2)=0
	I 0!(vovc1'=vc1) S vs(2)=0 S vh(2)=0 S VD(1)=0 S vb2=1 S VH0=1
	Q 
	;
VSUM	; Report Group Summary
	I 'vs(2) S vs(2)=1 D VSUM2 Q:VFMQ  D stat^DBSRWUTL(2)
	Q 
	;
VSTAT	; Data field statistics
	;
	S VT(2)=VT(2)+1
	S VT(2,1,1)=VT(2,1,1)+vc8 ; @TOT([DBARCHIST]RECCNT)
	Q 
	;
VHDG2	; Group Header
	;
	Q:vh(2)  S vh(2)=1 ; Print flag
	I VLC+4>IOSL D VHDG0 Q:VFMQ 
	;
	S VL="Archive Table:  "
	S VL=VL_$J("",16-16)_$E(vc1,1,80)
	D VOM
	S VL="" D VOM
	S VL="   "_"Seq  ------  Start ------    ------- End --------    Primary Records         Archived Records    Stopped"
	D VOM
	S VL="===================================================================================================================================="
	D VOM
	Q 
	;
VDTL2	; Detail
	;
	I VLC+1>IOSL D VHDG0 Q:VFMQ  S vh(2)=0 D VHDG2 Q:VFMQ 
	;
	S VL=$J(vc2,6)
	S VL=VL_$J("",8-$L(VL))_$J($S(vc3'="":$ZD(vc3,"MM/DD/YEAR"),1:""),10)
	S VL=VL_$J("",20-$L(VL))_$J($$TIM^%ZM(vc4),8)
	S VL=VL_$J("",32-$L(VL))_$J($S(vc5'="":$ZD(vc5,"MM/DD/YEAR"),1:""),10)
	S VL=VL_$J("",44-$L(VL))_$J($$TIM^%ZM(vc6),8)
	S VL=VL_$J("",56-$L(VL))_$J($FN(vc7,",",0),15)
	S VL=VL_$J("",78-$L(VL))_$J($FN(vc8,",",0),18)
	D VP1 Q:VFMQ!$get(verror)  S V=$E(STP,1,3)
	S VL=VL_$J("",102-$L(VL))_V
	D VOM
	Q 
	;
VSUM2	; Summary
	;
	I 'VT(2) Q 
	I VLC+2>IOSL D VHDG0 Q:VFMQ  S vh(2)=0 D VHDG2 Q:VFMQ 
	;
	S VL="" D VOM
	S VL="                                                                          "_"----------------------"
	D VOM
	S VL="                                                 "_"Total Archived Records"
	S V=VT(2,1,1) ; @TOT([DBARCHIST]RECCNT,)
	S VL=VL_$J("",74-71)_$J($FN(V,",",0),22)
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
	S VL=VL_$J("",128-$L(VL))_$J(VPN,3)
	D VOM
	S VL="" D VOM
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
VP1	; Column pre-processor - Variable: STP
	;
	I vc9 S STP="Yes"
	E  S STP=""
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
