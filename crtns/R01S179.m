R01S179	; DBSBCHLST - List Batch Definition
	;
	; **** Routine compiled from DATA-QWIK Report DBSBCHLST ****
	;
	; 09/14/2007 09:16 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/14/2007 09:16 - chenardp
	;
	 S ER=0
	N OLNTB
	N %READ N RID N RN N %TAB N VFMQ
	N VIN2 S VIN2="ALL"
	;
	S RID="DBSBCHLST"
	S RN="List Batch Definition"
	I $get(IO)="" S IO=$I
	;
	D INIT^%ZM()
	;
	S %TAB("IO")=$$IO^SCATAB
	S %TAB("VIN2")="|255||[DBTBL33D]BCHID|[DBTBL33D]BCHID:DISTINCT:NOVAL||D EXT^DBSQRY||T|Batch Name|||||"
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
	N %TIM N CONAM N RID N RN N VL N VLOF N VRF N VSTATS N vCOL N vHDG N vc1 N vc10 N vc11 N vc12 N vc13 N vc14 N vc15 N vc2 N vc3 N vc4 N vc5 N vc6 N vc7 N vc8 N vc9 N vovc1 N vovc2 N vovc3 N vovc4 N vrundate N vsysdate N zcode
	;
	N cuvar S cuvar=$$vDb3()
	 S cuvar=$G(^CUVAR("BANNER"))
	;
	S CONAM="DATA-QWIK 7.2"
	S ER=0 S RID="DBSBCHLST" S RN="List Batch Definition"
	S VL=""
	;
	USE 0 I '$get(VRWOPT("NOOPEN")) D  Q:ER 
	.	I '($get(VRWOPT("IOPAR"))="") S IOPAR=VRWOPT("IOPAR")
	.	E  I (($get(IOTYP)="RMS")!($get(IOTYP)="PNTQ")),('($get(IOPAR)["/OCHSET=")),$$VALID^%ZRTNS("UCIOENCD") D
	..		; Accept warning if ^UCIOENCD does not exist
	..		;    #ACCEPT Date=07/26/06; Pgm=RussellDS; CR=22121; Group=MISMATCH
	..		N CHRSET S CHRSET=$$^UCIOENCD("Report","DBSBCHLST","V0","*")
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
	.	S DQQRY(1)="[DBTBL33D]%LIBS = ""SYSDEV""" S SEQ=SEQ+1
	.	I $get(VIN2)="" S VIN2="ALL"
	.	I VIN2'="ALL" S DQQRY(2)="[DBTBL33D]BCHID "_VIN2 S SEQ=SEQ+1
	.	S FROM=$$DQJOIN^SQLCONV("DBTBL33D,DBTBL33") Q:ER 
	.	S VWHERE=$$WHERE^SQLCONV(.DQQRY,"")
	.	Q 
	;
	; Print Report Banner Page
	I $P(cuvar,$C(124),1),'$get(VRWOPT("NOBANNER")),IOTYP'="TRM",'$get(AUXPTR) D
	.	N VBNRINFO
	.	;
	.	S VBNRINFO("PROMPTS",2)="WC2|"_"Batch Name"_"|VIN2|"_$get(VIN2)
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
	.	S VBNRINFO("DESC")="List Batch Definition"
	.	S VBNRINFO("PGM")="R01S179"
	.	S VBNRINFO("RID")="DBSBCHLST"
	.	S VBNRINFO("TABLES")="DBTBL33D,DBTBL33"
	.	;
	.	S VBNRINFO("ORDERBY",1)="[SYSDEV,DBTBL33D]%LIBS"
	.	S VBNRINFO("ORDERBY",2)="[SYSDEV,DBTBL33D]33"
	.	S VBNRINFO("ORDERBY",3)="[SYSDEV,DBTBL33D]BCHID"
	.	S VBNRINFO("ORDERBY",4)="[SYSDEV,DBTBL33D]LABEL"
	.	S VBNRINFO("ORDERBY",5)="[SYSDEV,DBTBL33D]SEQ"
	.	;
	.	D ^DBSRWBNR(IO,.VBNRINFO) ; Print banner
	.	Q 
	;
	; Initialize variables
	S (vc1,vc2,vc3,vc4,vc5,vc6,vc7,vc8,vc9,vc10,vc11,vc12,vc13,vc14,vc15)=""
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
	S vh(0)=0
	;
	; Run report directly
	D VINILAST
	;
	;  #ACCEPT DATE=09/14/2007;PGM=Report Writer Generator;CR=20967
	N rwrs,vos1,vos2,sqlcur,exe,sqlcur,vd,vi,vsql,vsub S rwrs=$$vOpen0(.exe,.vsql,"DBTBL33D.%LIBS,DBTBL33D.BCHID,DBTBL33D.LABEL,DBTBL33D.SEQ,DBTBL33.BCHID,DBTBL33.DES,DBTBL33.LTD,DBTBL33.TIME,DBTBL33.PGM,DBTBL33.USER,DBTBL33.PFID,DBTBL33.WHERE,DBTBL33.DISTINCT,DBTBL33.MTZ,DBTBL33.RESTIND","DBTBL33D,DBTBL33",VWHERE,"DBTBL33D.%LIBS,DBTBL33D.BCHID,DBTBL33D.LABEL,DBTBL33D.SEQ","","/DQMODE=1")
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
	S vc1=$piece(V,$char(9),1) ; DBTBL33D.%LIBS
	S vc2=$piece(V,$char(9),2) ; DBTBL33D.BCHID
	S vc3=$piece(V,$char(9),3) ; DBTBL33D.LABEL
	S vc4=$piece(V,$char(9),4) ; DBTBL33D.SEQ
	S vc5=$piece(V,$char(9),5) ; DBTBL33.BCHID
	S vc6=$piece(V,$char(9),6) ; DBTBL33.DES
	S vc7=$piece(V,$char(9),7) ; DBTBL33.LTD
	S vc8=$piece(V,$char(9),8) ; DBTBL33.TIME
	S vc9=$piece(V,$char(9),9) ; DBTBL33.PGM
	S vc10=$piece(V,$char(9),10) ; DBTBL33.USER
	S vc11=$piece(V,$char(9),11) ; DBTBL33.PFID
	S vc12=$piece(V,$char(9),12) ; DBTBL33.WHERE
	S vc13=$piece(V,$char(9),13) ; DBTBL33.DISTINCT
	S vc14=$piece(V,$char(9),14) ; DBTBL33.MTZ
	S vc15=$piece(V,$char(9),15) ; DBTBL33.RESTIND
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
	D VHDG3 Q:VFMQ 
	D VHDG5 Q:VFMQ 
	I '$get(vskp(5)) D VDTL5 Q:VFMQ 
	D VSTAT
	Q 
	;
VBREAK	;
	Q:'VT(5) 
	N vb1 N vb2 N vb3 N vb4 N vb5
	S (vb1,vb2,vb3,vb4,vb5)=0
	I 0!(vovc1'=vc1) S vs(3)=0 S vh(3)=0 S VD(1)=0 S vb2=1 S vb3=1 S vb4=1 S vb5=1 S VH0=1
	I vb3!(vovc2'=vc2) S vs(4)=0 S vh(4)=0 S VD(3)=0 S vb4=1 S vb5=1 S VH0=1
	I vb4!(vovc3'=vc3) S vs(5)=0 S vh(5)=0 S VD(4)=0 S vb5=1
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
VHDG3	; Group Header
	;
	Q:vh(3)  S vh(3)=1 ; Print flag
	I VLC+8>IOSL D VHDG0 Q:VFMQ 
	;
	S VL=" "_"Batch Name: "
	S VL=VL_$J("",13-13)_$E(vc5,1,12)
	S VL=VL_$J("",28-$L(VL))_"Description: "
	S VL=VL_$J("",41-$L(VL))_$E(vc6,1,40)
	S VL=VL_$J("",86-$L(VL))_"Date: "
	S VL=VL_$J("",92-$L(VL))_$J($S(vc7'="":$ZD(vc7,"MM/DD/YEAR"),1:""),10)
	S VL=VL_$J("",104-$L(VL))_$J($$TIM^%ZM(vc8),10)
	D VOM
	S VL="                                "_"Routine: "
	S VL=VL_$J("",41-41)_$E(vc9,1,8)
	S VL=VL_$J("",86-$L(VL))_"User: "
	S VL=VL_$J("",92-$L(VL))_$E(vc10,1,20)
	D VOM
	S VL="                            "_"Access File:"
	S VL=VL_$J("",41-40)_$E(vc11,1,12)
	D VOM
	S VL="                       "_"SQL Where Clause:"
	S VL=VL_$J("",41-40)_$E(vc12,1,90)
	D VOM
	S VL="                    "_"SQL Distinct Clause:"
	S VL=VL_$J("",41-40)_$E(vc13,1,40)
	D VOM
	S VL="               "_"Multiple Time Zone logic:"
	S VL=VL_$J("",41-40)_$S(vc14:"Y",1:"N")
	D VOM
	S VL="                   "_"Insert Restart Logic:"
	S VL=VL_$J("",41-40)_$S(vc15:"Y",1:"N")
	D VOM
	S VL="------------------------------------------------------------------------------------------------------------------------------------"
	D VOM
	Q 
	;
VHDG5	; Group Header
	;
	Q:vh(5)  S vh(5)=1 ; Print flag
	I VLC+2>IOSL D VHDG0 Q:VFMQ 
	;
	S VL=" "_$E(vc3,1,12)
	D VOM
	S VL=" "_"------------"
	D VOM
	Q 
	;
VDTL5	; Detail
	;
	I VLC+1>IOSL D VHDG0 Q:VFMQ  S vh(5)=0 D VHDG5 Q:VFMQ 
	;
	D VP1 Q:VFMQ!$get(verror)  S V=$E(zcode,1,132) S VL=" "_V
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
VP1	; Column pre-processor - Variable: zcode
	;
	N SEQ
	N BCHID N LABEL
	;
	; Because code has tabs, can include in result set, so get it this way
	S BCHID=vc2
	S LABEL=vc3
	S SEQ=vc4
	;
	N dbtbl33d S dbtbl33d=$$vDb4("SYSDEV",BCHID,LABEL,SEQ)
	;
	S zcode=$P(dbtbl33d,$C(12),1)
	;
	; Replace tabs with equivalent spaces
	I $$vStrLike(zcode,"%"_$char(9)_"%","") D
	.	;
	.	N loc N sp
	.	N p1
	.	;
	.	F  S loc=$F(zcode,$char(9)) Q:(loc=0)  D
	..		;
	..		S p1=$E(zcode,1,loc-2)
	..		S sp=8-($L(p1)#8)
	..		S zcode=p1_$E("        ",1,sp)_$E(zcode,loc,1048575)
	..		Q 
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
	; ----------------
	;  #OPTION ResultClass 0
vStrLike(object,p1,p2)	; String.isLike
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I (p1="") Q (object="")
	I p2 S object=$$vStrUC(object) S p1=$$vStrUC(p1)
	I ($E(p1,1)="%"),($E(p1,$L(p1))="%") Q object[$E(p1,2,$L(p1)-1)
	I ($E(p1,1)="%") Q ($E(object,$L(object)-$L($E(p1,2,1048575))+1,1048575)=$E(p1,2,1048575))
	I ($E(p1,$L(p1))="%") Q ($E(object,1,$L(($E(p1,1,$L(p1)-1))))=($E(p1,1,$L(p1)-1)))
	Q object=p1
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ","ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ")
	;
vDb3()	;	voXN = Db.getRecord(CUVAR,,0)
	;
	I '$D(^CUVAR)
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,CUVAR" X $ZT
	Q ""
	;
vDb4(v1,v2,v3,v4)	;	voXN = Db.getRecord(DBTBL33D,,0)
	;
	N dbtbl33d
	S dbtbl33d=$G(^DBTBL(v1,33,v2,v3,v4))
	I dbtbl33d="",'$D(^DBTBL(v1,33,v2,v3,v4))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL33D" X $ZT
	Q dbtbl33d
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
