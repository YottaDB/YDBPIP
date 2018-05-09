DBSEXE2C	;;DBS - U - V4.4 - /QB command peocessor
	;;Copyright(c)1996 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/17/96 10:11:35 - CHIANG
	;     ORIG:  BOB CHIANG (8447) - 02/06/89
	;     DESC:  /QB COMMAND PROCESSOR
	;
	;---------- Revision History -------------------------------------------
        ;
        ; 10/17/96 - Bob Chiang - 20948
        ;            Modified to replace node 1-7 references with node 16
        ;            (file access keys).
	;
	; 03/31/95  Bob Chiang - 253
	;           Removed bad $$^MSG calls.
	;
	; 08/22/94  Shaodong Tony Xu -ARQ 14621
	;           Modified the variables %READ and %TAB.
	;
	; 08/20/92  Robert Chiang
	;
	;           Added logic to set up correct @TOT function when using
	;           OOE report QUICK_LAYOUT option.
	;-----------------------------------------------------------------------
        ;  I18N=QUIT: Excluded from I18N standards
	;
START	;
	;---------------------------------------------------------------------
	; /QB  ( quick build option )
	;
QB	;
	;
	S CURGRP=$G(GRP) ; Current page
	;
	N GRP,%BPH,%BGH,%BCH,%BRS,%BQRY,%DEL,DTL,ZMSG,X,Y,Z,SUM,ER,RM,%TAB,X1,X2,X3,X4,ZRID,ZNOGRP,ZNODTL
	;
	; Locate detail information for the lowest access keys
	S (%BPH,%BGH,%BRS,%BCH,%BQRY,%DTL,ZNOGRP,ZNODTL)="",%DEL=1
	;
	S X=$P(^DBTBL(%LIBS,5,RID,0),"|",5) ; page width
	;
	; default page header source
	;
	;
	I $P($G(^CUVAR("DBS")),"|",2)="" S $P(^("DBS"),"|",2,3)="SCA80|SCA132"
	;
	S ZRID=$S(X'>80:$P(^CUVAR("DBS"),"|",2),1:$P(^("DBS"),"|",3))
	S:ZRID[":" ZRID=$P($P(ZRID,":",2),".",1) I ZRID["_" S ZRID=$P(ZRID,"_",2)
	;
	; Detail region
	;
	S X1=^DBTMP(PIO,CURGRP,0)+2,X2=$P(^(0),",",2)+X1
	;
	S X=100
QB1	;
	S X=$O(^DBTMP(PIO,CURGRP,X)) I X="" G QB2
	S X3=^(X)\1000 I X3<X1!(X3>X2) G QB1
	I %DTL="" S %DTL=X3 G QB1
	I %DTL'[X3 S %DTL=%DTL_","_X3
	G QB1
	;
	;
QB2	;
	;
	S OLNTB=11030,DBOPT=5
	; *** 03/31/95 BC
	S ZMSG=$J("",10)_"Based on detail information defined on line(s) "_%DTL
	;
	S %TAB("%BPH")=".%BPH1/XPP=I 'X S NI=NI+1"
	S %TAB("ZRID")=".ZRID2/TBL=[SYSDEV,DBTBL]"
	S %TAB("%BCH")=".%BCH1"
	S %TAB("%BGH")=".%BGH1"
	S %TAB("%BQRY")=".%BQRY1"
	S %TAB("%DEL")=".%DEL1"
	;
	I '$D(^DBTBL(%LIBS,5,RID,2)) S ZNOGRP=1
	;
	; single level key
	;
QLENT	; Entry point from /QL command with QBOPT=1
	;
	I $G(QBOPT)=1 S (%BPH,%BQRY,%BCH,%BGH,%BRS,%DEL)=1 G QB4
	;
	S %CTPRMT="2|35",OLNTB=11030
	S %READ=",%BPH,ZRID,,%BQRY,,@ZMSG/REV,,%BCH/NOREQ,%BGH,,%DEL/REQ"
	;
	I '%DTL S %READ=",%BPH,ZRID,,%BQRY,,%DEL/REQ" G QB3 ; build RH & Query only
	;
QB3	;
	;
	D ^UTLREAD I VFMQ="Q" Q
	;
QB4	;
	I %BGH S %BRS=1
	;
	; ------------------------------------------------
	; Delete old data first
	; ------------------------------------------------
	;
	;
	I %DEL,%BCH D KILL("@PH","ch")
	I %DEL,%BPH D KILL("@PH","ph")
	;
	I %BPH D BPH I CURGRP="@PH" S WINDOW=1
	;
	; Detail information available ?
	;
	; Build column heading
	;
	I %BCH D BCH I CURGRP="@PH" S WINDOW=1
	;
	I %BGH!%BRS D SUM ; Build @TOT() function line
	;
	I %BGH D BGH I CURGRP'="@PH" S WINDOW=1
	I %BRS D BRS I CURGRP="@RS" S WINDOW=1
	;
	; Default query <<**>>
	;
	I %BQRY D BQRY
	;
	S DBOPT=5 D VER^DBSEXE5
	;
	Q
BPH	;
	; ------------------------------------------------------------------
	; Build default report header ( SCA80 / SCA132 )
	; ------------------------------------------------------------------
	;
	N SEQ,TSEQ,LSEQ,ZLIBS
	;
	I '$D(^DBTMP(PIO,"@PH",0)) S ^DBTMP(PIO,"@PH",0)="3,3,3"
	;
	; Find valid sequence number
	;
	S SEQ=$$SEQUENCE("@PH")+10
	;
	;
	S SEQ=SEQ+1\100+1*100+1 ; @data item
	S TSEQ=$ZP(^DBTMP(PIO,"@PH",""))+1 ; Next item sequence number
	S LSEQ=$G(^(TSEQ-1))+0\1000 ; Last line # used
	I TSEQ<101 S TSEQ=101
	;
	S ZLIBS=%LIBS I $G(^DBTBL(%LIBS,5,ZRID,-3))'="" S ZLIBS=^(-3)
	;
	S Z=0,X=100 F I=1:1 S X=$O(^DBTBL(ZLIBS,5,ZRID,"@PH",X)) Q:X=""  D BPH1
	;
	; Adjust region
	;
	S Z=Z\1000+1
	I Z>^DBTMP(PIO,"@PH",0) S $P(^(0),",",1)=Z
	;
	;
	Q
BPH1	;
	S Z=LSEQ*1000+^(X)
	S Y=Z_"|"_$P(^(X),"|",2,5)_"|"_"@"_SEQ_"|"_$P(^(X),"|",7,9)
	S $P(Y,"|",2)="@ph"
	;
	S ^DBTMP(PIO,"@PH",TSEQ)=Y
	S SEQ=SEQ+1,TSEQ=TSEQ+1
	;
	D STATUS
	Q
	;
BCH	;
	; ------------------------------------------------------------------
	; Build column header
	; ------------------------------------------------------------------
	;
	N SEQ,LEN,FMT,DINAM,TAB,XLINE,LINE,LSEQ,NXSEQ,X1,X2,X3,X4,COLHDR
	;
	S LSEQ=$ZP(^DBTMP(PIO,"@PH",""))+1
	I LSEQ<101 S LSEQ=201,^(0)="3,3,3",LINE=1 ; Start at line 2
	;
	E  S LINE=^(LSEQ-1)\1000+2 ; start at end of last data item
	;
	S NXSEQ=$$SEQUENCE("@PH")+10
	;
	S X1=^DBTMP(PIO,CURGRP,0)+2,X2=X1+$P(^(0),",",2)
	;
	S SEQ=100 F I=1:1 S SEQ=$O(^DBTMP(PIO,CURGRP,SEQ)) Q:SEQ=""  D BCH1
	;
	; Adjust @PH regions
	;
	S LSEQ=$ZP(^DBTMP(PIO,"@PH","")),X=^(LSEQ),LINE=+X\1000+1
	;
	; @CHR(=) after last line of column heading
	;
	I '$D(XLINE) Q
	S ^DBTMP(PIO,"@PH",LSEQ+1)=XLINE+2*1000+1_"|@ch|"_7_"|T||@"_NXSEQ_"|@CHR(=)"
	;
	S $P(^(0),",",1)=XLINE+2
	;
	Q
	;
BCH1	;
	N I
	;
	; Data item information
	;
	S X=^(SEQ),X3=X\1000 I X3<X1!(X3>X2) Q  ; not detail information
	;
	I '$D(X4) S X4=X3 ; top line
	;
	S LEN=$P(X,"|",3),FMT=$P(X,"|",4),DINAM=$P(X,"|",6),COLHDR=$P(X,"|",8)
	S TAB=+X#1000
	;
	I DINAM?1"@".E,COLHDR'?1A.E Q  ; computed data item without column header
	;
	I DINAM'?1"@".E S COLHDR=""
	; Default column heading from file definition
	;
	D HEADER(DINAM,LEN,FMT,COLHDR,.HD1,.HD2)
	;
	; Build single column header
	;
	;
	S XLINE=X3-X4*2+LINE ; reserve 2-line heading/detail
	;
	I HD1?." " G BCH2
	S ^DBTMP(PIO,"@PH",LSEQ)=XLINE*1000+TAB_"|@ch|"_LEN_"|T||@"_NXSEQ_"|"_HD1
	S NXSEQ=NXSEQ+1,LSEQ=LSEQ+1
	;
BCH2	;
	I HD2?." " Q
	;
	S ^DBTMP(PIO,"@PH",LSEQ)=XLINE+1*1000+TAB_"|@ch|"_LEN_"|T||@"_NXSEQ_"|"_HD2
	S NXSEQ=NXSEQ+1,LSEQ=LSEQ+1
	;
	Q
	;
	; ------------------------------------------------------------------
	; Build group heading and trailer section
	; ------------------------------------------------------------------
	;
BGH	;
	; Build default group header and trailer ( for multi-level keys only )
	;
	N FID,DI,GRP1,LEV,GRP,SEQ,NODE
	;
	I '$D(^DBTBL(%LIBS,5,RID,2)) Q  ; Single level access key
	;
	; Create group header for each level
	;
	F LEV=2:1:7 I $D(^DBTBL(%LIBS,5,RID,LEV)) D BGH1
	Q
	;
BGH1	;
	S GRP=$P(^(LEV),"|",1) ;    current level key name
	S GRP1=$P(^(LEV-1),"|",1) ; Higher level key name
	I $P(GRP,"]",2)'?1A.E Q  ;  Dummy access key
	;
	I $P(GRP1,"]",2)'?1A.E,LEV>2 S GRP1=$P(^(LEV-2),"|",1) ; Skip level
	;
	I %DEL D KILL(GRP,"grp")
	;
	; Build description   KEYNAME <<KEY>>
	;
	S X=$P(GRP1,",",2),FID=$P(X,"]",1),DI=$P(X,"]",2)
	;
	;I DI?.E1N.E!(DI[$C(34)) Q  ; dummy key
	;
	S ZLIBS=%LIBS,Z=$P($G(^DBTBL(%LIBS,1,FID,10)),"|",5)
	I Z'="" S ZLIBS=$E($P(Z,",",1),2,99)
	S DESC=$P(^DBTBL(ZLIBS,1,FID,9,DI),"|",10)_" <<"_DI_">>"
	;
	S SEQ=$ZP(^DBTMP(PIO,GRP,""))+1
	I SEQ<101 S SEQ=101,^DBTMP(PIO,GRP,0)="3,3,3"
	;
	; Group header region
	;
	S R1=^DBTMP(PIO,GRP,0)+1
	S NODE=$S(R1=4:2,1:1)*1000+1_"|@grp|"_$L(DESC)_"|T||@"_NXSEQ_"|"_DESC
	;
	S ^DBTMP(PIO,GRP,SEQ)=NODE,NXSEQ=NXSEQ+1
	;
	D SUMMARY(GRP)
	;
	Q
	;
SUM	;
	;
	N GRP,I,FMT,SIZE,DINAM,LINE
	;
	K SUM S LINE=1
	S X=$ZP(^DBTBL(%LIBS,5,RID,8)),GRP=$P(^(X),"|",1)
	;
	S NXSEQ=$$SEQUENCE(GRP)
	;
	S X=0 F  S X=$O(^DBTMP(PIO,GRP,X)) Q:X=""  D SUM1
	Q
	;
	; Pick out data items with $ or E format
	;
SUM1	;
	S Y=^(X) I $P(Y,"|",2)?1"@".E Q
	S SIZE=$P(Y,"|",3),FMT=$P(Y,"|",4),DINAM=$P(Y,"|",6)
	I '((FMT["$")!(FMT["E")) Q
	;
	S $P(Y,"|",2)="@grp",$P(Y,"|",6)="@"_NXSEQ,NXSEQ=NXSEQ+1
	S $P(Y,"|",4)="T"
	;
	; @TOT([fid]di,,fmt,size)
	;
	S $P(Y,"|",6)="@"_NXSEQ,NXSEQ=NXSEQ+1
	S $P(Y,"|",1)=$P(Y,"|",1)+1000
	S $P(Y,"|",7)="@TOT(["_$P(DINAM,",",2)_",,"_FMT_","_SIZE_")"
	;
	S SUM(LINE)=Y,LINE=LINE+1
	Q
	;
	; Build trailer section
	;
SUMMARY(GRP)	;
	;
	N LINE,LNOFF,LN,SEQ,XDESC,NXSEQ,ZEXTRA,REGION
	;
	I '$D(SUM) Q
	;
	S NXSEQ=$$SEQUENCE(GRP)+100
	;
	I '$D(^DBTMP(PIO,GRP,0)) S ^DBTMP(PIO,GRP,0)="3,3,3"
	;
	I GRP="@RS" S REGION="H",DESC="REPORT"
	E  S REGION="T"
	;
	; Next available line number on the screen
	;
	S LINE=$$NEXTLINE(GRP,REGION)+2*1000
	;
	S SEQ=$ZP(^DBTMP(PIO,GRP,""))+1 I SEQ<101 S SEQ=101
	;
	S XDESC=DESC_" TOTALS: "		; *** 03/31/95 BC
	S ^(SEQ)=LINE+1_"|@grp|"_$L(XDESC)_"|T||@"_NXSEQ_"|"_XDESC
	S SEQ=SEQ+1,NXSEQ=NXSEQ+1
	;
	S ZEXTRA=0
	;
	S X=$O(SUM(0)) S LNOFF=+SUM(X)\1000 ; Line offset
	S LN=0 F  S LN=$O(SUM(LN)) Q:LN=""  D SUM9
	;
	; Adjust region size
	;
	S LINE=$$NEXTLINE(GRP,REGION)
	;
	I GRP="@RS" S ^DBTMP(PIO,GRP,0)=LINE_",3,3"
	E  S $P(^(0),",",3)=LINE-^DBTMP(PIO,GRP,0)-$P(^(0),",",2)-2
	;
	Q
	;
SUM9	;
	S X=SUM(LN),Y=+X-(LNOFF*1000)+LINE
	;
	I GRP="@RS" S X=$P(X,",,",1)_",0,"_$P(X,",,",2)	; Report total
	;
	; Enough room on this line ??
	;
	I $L(XDESC)'<(Y#1000) S Y=Y+1000,ZEXTRA=1
	E  I ZEXTRA S Y=Y+1000
	;
	S ^DBTMP(PIO,GRP,SEQ)=Y_"|"_$P(X,"|",2,99),SEQ=SEQ+1
	Q
	;
BRS	;
	; ------------------------------------------------------------------
	; Build report summary section for $ format type data items
	; ------------------------------------------------------------------
	;
	I %DEL D KILL("@RS","grp")
	D SUMMARY("@RS")
	Q
	;
BQRY	;
	; ------------------------------------------------------------------
	; Build query definitions
	; ------------------------------------------------------------------
	; <<**>> query definitions for primary & secondary access keys
	;
	K Y,NODE,ZLIB,ZFID
	;
	; Delete old query definitions
	;
	S X=30.99 F  S X=$O(^DBTBL(%LIBS,5,RID,X)) Q:X<0!(X>50)!(+X=0)  K ^(X)
	;
	S NODE=31
	;
	D ^DBSIMP(%LIBS,FILES,.ZLIB,.ZFID,.ER)
	I ER Q
	;
	S Z=^DBTBL(ZLIB,1,ZFID,16)			; *** 10/17/96
	F I=1:1:$L(Z,",") S X=$P(Z,",",I) I X'="" D BQRY1
	Q
	;
BQRY1	;
	I X?.E1N.E!(X[$C(34)) Q  ; dummy key
	S X="["_ZFID_"]"_X_" <<**>>" ; [fid]di <<**>>
	;
	I $D(Y(X)) Q  ; Already defined
	;
	S ^DBTBL(%LIBS,5,RID,NODE)=X,NODE=NODE+1
	Q
	;
	Q
	;
	; ------------------------------------------------------------------
	; Return single data item column heading
	; ------------------------------------------------------------------
	;
	;
HEADER(DINAM,LEN,FMT,COLHDR,H1,H2)	;
	;
	;  Input:
	;
	;     DINAM  = data item name in [lib,fid]di format
	;       LEN  = data item field length or default to file definition
	;       FMT  = data item print format ... use file def for adjustment
	;    COLHDR  = default column header ( defined in computed operation)
	;
	; Output:
	;
	;        H1  = column heading line 1
	;        H2  = column heading line 2
	;
	N LIB,FID,DI
	;
	;
	I COLHDR'="" S X=COLHDR G HDR1 ; computed operation EXP@HDR;FMT
	;
	;
	S LIB=$E($P(DINAM,",",1),2,99),FID=$P($P(DINAM,"]",1),",",2),DI=$P(DINAM,"]",2)
	;
	S DATA=^DBTBL(LIB,1,FID,9,DI)
	;
	S X=$P(DATA,"|",22) ;            Default column heading
	I X="" S X=$P(DATA,"|",10) ;     Default to item description
	;
	S FMT=$P(DATA,"|",9) ;           format
	I 'LEN S LEN=$P(DATA,"|",2) ;    length
	;
	D HEADING(X,LEN,FMT,.H1,.H2)
	Q
	;
HEADING(X,LEN,FMT,H1,H2)	;
	;
	I X["@"!($L(X)'>LEN) G HDR1
	;
	; ========  convert to 2-line heading
	;
	I X'[" " G HDR1
	;
	S X=$P(X," ",1)_"@"_$P(X," ",2,99)
	;
	;
	; ===== column heading
HDR1	;
	S H1=$P(X,"@",1),H2=$P(X,"@",2)
	S H1=$E(H1,1,LEN),H2=$E(H2,1,LEN) ; try to fit in column width
	;
	I $L(H1)>$L(H2) D HCTR(.H2,$L(H1)) D HADJ(.H1) Q
	D HCTR(.H1,$L(H2)) D HADJ(.H2)
	Q
	;
HADJ(H)	;
	; Adjust heading based on format type
	;
	; Right justify
	;
	I "$NE"[FMT!(FMT?1"RD".E) S H=$J("",LEN-$L(H))_H
	;
	; Left justify
	;
	E  S H=H_$J("",LEN-$L(H))
	Q
	;
HCTR(H,L)	;
	;
	; Center heading based on the longer heading
	;
	S X=L-$L(H)\2
	S H=$J("",X)_H_$J("",X)
	D HADJ(.H)
	Q
	;
	;
	; Display status
	;
STATUS	;
	;
	Q
	;
	;
	;
KILL(GRP,ID)	;
	; ---------------------------------------------------------------
	; Delete old data first
	; ---------------------------------------------------------------
	;
	; ID = ch (column header)
	;      ph (page header)
	;      grp (group header & trailer)
	;      rs  (report summary)
	;
	S X=100 F I=1:1 S X=$O(^DBTMP(PIO,GRP,X)) Q:X=""  I "@"_ID=$P(^(X),"|",2) K ^(X)
	;
	Q
	;
	; ========== Locate next highest dummy sequence # in GRP section
	;
SEQUENCE(GRP)	;
	;
	N SEQ,X
	S X=100 F I=1:1 S X=$O(^DBTMP(PIO,GRP,X)) Q:X=""  D SEQ1
	;
	S SEQ=$G(SEQ)+1
	Q SEQ
	;
SEQ1	;
	S Y=$P(^(X),"|",6) I Y'?1"@"1N.N Q
	I '$D(SEQ) S SEQ=0
	I $E(Y,2,99)>SEQ S SEQ=$E(Y,2,99)+0
	Q
	;
	; ===== Locate next highest line number in GRP section from REGION
	;
NEXTLINE(GRP,REGION)	;
	;
	N LINE,X
	;
	I REGION="H" S LINE=0
	I REGION="D" S LINE=^DBTMP(PIO,GRP,0)=1
	I REGION="T" S LINE=^DBTMP(PIO,GRP,0)+$P(^(0),",",2)+2
	;
	S X=100 F I=1:1 S X=$O(^DBTMP(PIO,GRP,X)) Q:X=""  D NXLINE1
	;
	Q LINE
	;
	;
NXLINE1	;
	;
	I ^(X)\1000>LINE S LINE=^(X)\1000
	Q
