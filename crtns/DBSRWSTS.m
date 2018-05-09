 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSRWSTS ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSRWSTS(VSTATS) ; 
 ;
 N LOW N HIGH N TOTAMT N TOTCNT N vcrt
 N BTYP N SEQ N TYP N VL
 ;
 Q:'$D(VSTATS) 
 ;
 S VL=""
 ;
 S vcrt=0
 USE 0 I $I=IO S vcrt=1 S vlc=$$LASTLINE^DBSRWBR
 ;
 USE IO D HDR Q:VFMQ 
 ;
 I vcrt D VLOCK
 ;
 S SEQ=""
 F  S SEQ=$order(VSTATS(SEQ)) Q:(SEQ="")  D  Q:VFMQ 
 .	N MULTINCS N QUIT N TOPAMT N TOPCNT
 .	N COLUMN N INCS N INFO N N N SOURCE N TABLE N TARGET N TC
 .	;
 .	I VLC+5>IOSL D HDR Q:VFMQ 
 .	S INFO=VSTATS(SEQ)
 .	S SOURCE=$piece(INFO,"|",5) S TARGET=$piece(INFO,"|",7)
 .	Q:'$$validtcr^DBSRWUTL(SOURCE,.TC) 
 .	S TABLE=$piece(TC,".",1) S COLUMN=$piece(TC,".",2)
 .	;
 .	N src S src=$$vRCgetRecord0Opt^RecordDBTBL1D("SYSDEV",TABLE,COLUMN,0,"")
 .	;
 .	D VOM
 .	;
 .	S VL="<< "_$P(src,$C(124),10)_" >>"
 .	S QUIT=0
 .	I SOURCE=TARGET S BTYP=$piece(INFO,"|",6)
 . E  D  Q:QUIT 
 ..		I '$$validtcr^DBSRWUTL(TARGET,.TC) S QUIT=1 Q 
 ..		S TABLE=$piece(TC,".",1) S COLUMN=$piece(TC,".",2)
 ..		N trc S trc=$$vRCgetRecord0Opt^RecordDBTBL1D("SYSDEV",TABLE,COLUMN,0,"")
 ..		S BTYP=$P(trc,$C(124),9)
 ..		S VL=VL_$J("",(73-$L(VL)-$L($P(trc,$C(124),10))))_"<< "_$P(trc,$C(124),10)_" >>"
 ..  Q 
 .	;
 .	D VOM
 .	;
 .	S (TOTAMT,TOTCNT)=0
 .	S TOPCNT=$piece(INFO,"|",1) S TOPAMT=$piece(INFO,"|",2)
 .	S LOW=$piece(INFO,"|",3) S HIGH=$piece(INFO,"|",4)
 .	;
 .	S INCS=$piece(INFO,"|",8,99)
 .	I $piece(INCS,"|",2) S MULTINCS=1
 .	E  S MULTINCS=0
 .	;
 .	S TYP=$piece(INFO,"|",6)
 .	I "$"[TYP S TYP="E"
 .	E  I TYP="*" S TYP="T"
 .	;
 .	S N=""
 .	F  S N=$order(VSTATS(SEQ,N)) D  Q:VFMQ!(N="") 
 ..		N AMT N CNT
 ..		;
 ..		; End of this section, print summary
 ..		I (N="") D  Q 
 ...			D VOM
 ...			D SUMMARY(.TOTCNT,.TOTAMT,LOW,HIGH,TYP,BTYP)
 ...			Q 
 ..		;
 ..		I VLC+2>IOSL D HDR Q:VFMQ 
 ..		S CNT=$piece(VSTATS(SEQ,N),"|",1)
 ..		S AMT=$piece(VSTATS(SEQ,N),"|",2)
 ..		D VOM
 ..		I SOURCE'=TARGET S VL=$J($$CONV(TYP,N),31)
 ..		E  I "TUFL"[TYP!(INCS="") S VL=$J($$CONV(TYP,N),14)_"                 "
 ..		E  D
 ...			N OV
 ...			;
 ...			S OV=N*INCS
 ...			I MULTINCS S OV=$piece(INCS,"|",N-1) I N=1 S OV=LOW
 ...			S VL=$J($$CONV(TYP,OV),14)
 ...			;
 ...			S OV=((N+1)*INCS)-.01
 ...			I MULTINCS S OV=$piece(INCS,"|",N)-.01 I OV<0 S OV=HIGH
 ...			S VL=VL_" - "_$J($$CONV(TYP,OV),14)
 ...			Q 
 ..		D ACCUM(CNT,AMT,TYP,BTYP)
 ..		Q 
 . Q 
 ;
 D SUMMARY(TOTCNT,TOTAMT,LOW,HIGH,TYP,BTYP)
 ;
 I 'VFMQ D
 .	D VOM D VOM
 .	K VSTATS
 .	Q 
 ;
 Q 
 ;
ACCUM(CNT,AMT,TYP,BTYP) ; 
 ;
 ; COUNT and % COUNT
 S VL=VL_$J(CNT,15)
 S TOTCNT=TOTCNT+CNT
 S TOTAMT=TOTAMT+AMT
 ;
 S VL=VL_$J($$CONV("N",$J(((CNT*100)/TOPCNT),0)),8)
 ;
 ; TOTAL & % TOTALS
 I '(BTYP="") S TYP=BTYP
 Q:'TOPAMT 
 Q:"DCLT"[TYP 
 ;
 S VL=VL_$J($$CONV(TYP,AMT),17)
 S VL=VL_$J($$CONV(TYP,$J(((AMT*100)/TOPAMT),0)),8)
 ;
 Q 
 ;
SUMMARY(TOTCNT,TOTAMT,LOW,HIGH,TYP,BTYP) ; 
 ;
 N LINES S LINES=""
 ;
 Q:'TOTCNT 
 ;
 S $piece(LINES,"=",43)=""
 ;
 I VLC+4>IOSL D HDR Q:VFMQ 
 D VOM D VOM
 S VL="       ** LOW **        ** HIGH **   "_LINES
 D VOM
 I VLC+3>IOSL D HDR Q:VFMQ 
 D VOM
 I "UTF"'[TYP D
 .	S VL=$J($$CONV(TYP,LOW),14)
 .	S VL=VL_" - "_$J($$CONV(TYP,HIGH),14)
 .	Q 
 S VL=VL_$J("",(31-$L(VL)))_$J(TOTCNT,15)
 I "N$"[BTYP S VL=VL_$J($$CONV(BTYP,TOTAMT),25)
 S (TOTCNT,TOTAMT)=0
 D VOM
 ;
 Q 
 ;
CONV(TYP,INPUT) ; 
 ;
 N NEWVAL S NEWVAL=""
 ;
 I TYP="T"!(TYP["*")!(TYP="F")!(TYP="U") S NEWVAL=INPUT
 E  I TYP="D",INPUT>0,INPUT<99999 S NEWVAL=$S(INPUT'="":$ZD(INPUT,"MM/DD/YEAR"),1:"")
 E  I TYP="N" S NEWVAL=INPUT
 E  I TYP="C" S NEWVAL=$$TIM^%ZM(INPUT)
 E  I TYP="E"!(TYP="$") S NEWVAL=$FN(+INPUT,",",2)
 E  I TYP="L" S NEWVAL=$S(INPUT:"Y",1:"N")
 E  I TYP="K" S NEWVAL=$$EXT^%ZM((INPUT+500)\1000,"$",0)
 E  I TYP="X" S NEWVAL=$$EXT^%ZM((INPUT+.5)\1,"$",0)
 Q NEWVAL
 ;
HDR ; Private - Print header
 ;
 I 'vcrt D  ; Flush print buffer
 .	USE IO
 .	I '(VL="") WRITE VL,#
 .	D VLOCK
 .	Q 
 E  D
 .	D ^DBSRWBR(2)
 .	S VLC=5
 .	Q 
 Q 
 ;
VLOCK ; Private - Lock CRT header
 ;
 N VL
 ;
 S PN=$get(PN)+1 S VLC=0
 I vcrt WRITE $$CLRXY^%TRMVT
 ;
 ; Summary Report
 S VL=$$^MSG(7985)
 D VOM
 S VL="=============="
 D VOM D VOM
 S VL="               "_"RANGE "_"                    "_"COUNT      %"_"            "_"TOTAL       %"
 D VOM
 S VL=""
 S $piece(VL,"-",80)=""
 D VOM
 I vcrt D ^DBSRWBR(2,1,1) S VLC=5
 ;
 Q 
 ;
VOM ; Private - Output print line
 ;
 ; Advance to a new page
 USE IO I 'VLC,'vcrt D  ; Non-CRT device (form feed)
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
VBRSAVE(LINE,DATA) ; Private - Save for report browser
 N vTp
 ;
 N tmprptbr,vop1,vop2,vop3,vop4,vop5 S tmprptbr="",vop5=0
 ;
  S vop4=$J
  S vop3=LINE
  S vop2=0
  S vop1=0
  S $P(tmprptbr,$C(12),1)=DATA
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^TMPRPTBR(vop4,vop3,vop2,vop1)=tmprptbr S vop5=1 TC:vTp  
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61288^64007^Dan Russell^6291" ; Signature - LTD^TIME^USER^SIZE
