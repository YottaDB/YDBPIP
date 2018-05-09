 ; 
 ; **** Routine compiled from DATA-QWIK Procedure SCATAB ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
SCATAB ; 
 ; SCA Standard %TAB Definitions
 ;
 Q 
 ;
IO(DFT) ; Return %TAB("IO")
 ;
 N IOTYP
 N IOSL
 I $get(%IPMODE)["NOINT" D  Q ""
 .	I $get(IO)="" D
 ..		S %NOOPEN=""
 ..		S IO=$I
 ..		S IOTYP="TRM"
 ..		S IOSL=22
 ..		Q 
 .	Q 
 I $get(DFT)'="" S IO=DFT
 ;
 Q ".IO4/TBL=[DEVICE]DEVNAME:NOVAL/XPP=S %EXT=1 do ^SCAIO"
 ;
DI(DI,DES,LEN,TBL,XPP,XPR,TYP,MIN,MAX,DEC) ; Formatted %TAB entry
 ;
 N DINAM,ER,FID,X
 ;
 S ER=0
 ;
 N dbtbl1d
 ;
 I DI'="" D  I ER Q ""
 .	S FID=$piece($piece(DI,"]",1),"[",2)
 .	S DINAM=$piece(DI,"]",2)
 .	S dbtbl1d=$$vRCgetRecord0Opt^RecordDBTBL1D("SYSDEV",FID,DINAM,0,"")
 .	Q 
 I DI=""  S dbtbl1d=""
 ;
 I $get(DES)="" S DES=$P(dbtbl1d,$C(124),10)
 I DES="" Q ""
 I $get(TYP)="" S TYP=$P(dbtbl1d,$C(124),9) S:TYP="" TYP="T"
 ;
 I $get(LEN)="" D  I LEN="" Q ""
 .	S LEN=$P(dbtbl1d,$C(124),2)
 .	I LEN Q 
 .	I TYP="$"!(TYP="F")!(TYP="N") S LEN=12 Q 
 .	I TYP="T"!(TYP="U") S LEN=40 Q 
 .	I TYP="D" S LEN=10 Q 
 .	I TYP="C" S LEN=8 Q 
 .	I TYP="L" S LEN=1 Q 
 .	Q 
 ;
 ; Prompt/data type/length
 S X="/DES="""_DES_"""/TYP="_TYP_"/LEN="_LEN
 ;
 ; Table look-up
 I $get(TBL)="" S TBL=$P(dbtbl1d,$C(124),5)
 I TBL'="",TBL'="NOTABLE" S X=X_"/TBL="_TBL
 ;
 ; Post-processor
 I $get(XPP)="" S XPP=$P(dbtbl1d,$C(124),7)
 I XPP'="" S X=X_"/XPP="_XPP
 ;
 ; Pre-processor
 I $get(XPR)="" S XPR=$P(dbtbl1d,$C(124),8)
 I XPR'="" S X=X_"/XPR="_XPR
 ;
 ; Minimum value
 I $get(MIN)="" S MIN=$P(dbtbl1d,$C(124),12)
 I MIN'="" S X=X_"/MIN="_MIN
 ;
 ; Maximum value
 I $get(MAX)="" S MAX=$P(dbtbl1d,$C(124),13)
 I MAX'="" S X=X_"/MAX="_MAX
 ;
 ; Decimal precision
 I $get(DEC)="" S DEC=$P(dbtbl1d,$C(124),14)
 I DEC="",TYP="$" S DEC=2
 I DEC'="" S X=X_"/DEC="_DEC
 ;
 Q X
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60227^22950^Hema Puttaswamy^5053" ; Signature - LTD^TIME^USER^SIZE
