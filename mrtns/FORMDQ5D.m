FORMDQ5D	;; V 5.0
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/26/94 14:58:04 - CANFIELDS
	;     DESC:  Utility to set up RW repeat region, blank line suppress
	;            and line feed suppress definitions. 
	;
	; I18N=QUIT	Excluded from I18N Standards
	; ---------- Revision History ------------------------------------------
	; 05/17/06 - Allan Mattson - CR20048
	;            Replaced calls to $$UPPER^%ZFUNC with $$UPPER^SCAUTL.
	;
	;            Deleted pre-1993 revision history.
	;
	; 10/26/94 - Steve Canfield - I18N
	;	     Removed calls to $$^MSG.
	;
	; 11/02/93 - Bob Chiang - I18N#7
	;
	;            Modified return message handling with a call to extrinsic
	;            function $$^MSG(msgid,p1,p2...) for I18N development
	;            (phrase independence).
	;
	; 10/25/93    Bob Chiang - I18N#23
	;
	;             Modified to replace DBSMENU routine calls with DBSMBAR.
	;-----------------------------------------------------------------------
	;
COMMAND(OP)	;Private; Command dispatch driver
	;
	;
	S OP(1)="Status|STATUS^FORMDQ5D"
	S OP(2)="Repeat_field|CMDRF^FORMDQ5D"
	S OP(3)="Blank_line_suppress|CMDSBL^FORMDQ5D"
	S OP(4)="Line_feed_suppress|CMDLF^FORMDQ5D"
	S OP(5)="Cancel|RESET^FORMDQ5D"
	;
	; Status,Repeat_field,Blank_line_suppress,Line_feed_suppress,Cancel
	I $G(OP)="" S OP=$$^DBSMBAR(125) I 'OP Q	; *** BC - replace DBSMENU call 10/26/93
	;
	D @$P(OP(OP),"|",2)
	;
	Q
RESET	; ---------- Remove RF, SBL and SLF definitions
	N DY,Z
	S DY=""
	K zrf,zslf,zsbl
	;
	F  S DY=$O(D(DY)) Q:DY=""  I $E($G(D(DY,1)))="#" D RESET1
	Q
RESET1	;
	; Remove sl , sf indicator
	;
	S Z=$TR(M(DY,1),"xhe","q") I Z=M(DY,1) Q
	S M(DY,1)=Z D PUTOBJ^FORMFUN(DY,1)
	Q
	;
CMDRF	; ---------- Repeat field definition (valid for report detail
	;                                     region only !!)
	;
	N SIZE,COUNT,GROUP,OP,LN,XGRP,OPT
	S LN=""
	;
	F  S LN=$O(D(LN)) Q:LN=""  DO
	.	;
	.	I $E($G(D(LN,1)))="#",$P(D(LN,1),dl,1)'["-"
	.	E  Q
	.	S X=$E($P(D(LN,1),dl,1),2,99),XGRP(X)=LN
	;
	K XGRP("SUMMARY")
	;
	I $O(zrf(""))="" G RF1
	; 
	I '$$YN^DBSMBAR("","Delete repeat group definition",1) Q	; *** BC - replace DBSMENU call 10/26/93
	;
	; Delete
	;
	S GROUP=$O(XGRP(""))
	K zrf(GROUP)
	G RF2
	;
	; Define RF definitions
RF1	;
	;
	N ZSIZE,ZCOUNT,OP,I,LN,XSIZE,TAB
	S ZSIZE=$P(^DBTBL(%LIBS,5,RID,0),"|",5),X=$ZP(^(11))
	S GROUP="["_$P($P(^(X),"|",1),",",2)		; DETAIL LEVEL
	; 
	I '$D(XGRP(GROUP)) W $$MSG^%TRMVT("Report detail section missing","",1) Q
	S LN=XGRP(GROUP),LN=$O(D(LN)) I 'LN Q	; First detail line after marker
	S TAB=$ZP(D(LN,""))			; Last object on this line
	I $E(D(LN,TAB))="#" Q
	S XSIZE=TAB+$P(D(LN,TAB),$C(0),3)-1 	; Last position on this line
	;
	S SIZE=$$^FORMREAD("",3,"Enter Field Length("_XSIZE_"-"_ZSIZE_"): ")	; *** BC - 11/02/93
	I 'SIZE Q
	; 
	I SIZE'?1N.N!(SIZE<XSIZE)!(SIZE>ZSIZE) W $$MSG^%TRMVT("Invalid field length","",1) G RF1
	S ZCOUNT=ZSIZE\SIZE I ZCOUNT>40 S ZCOUNT=40
	F I=1:1:ZCOUNT S OP(I)=I
	;
	; "~,~,~,~,~,~,~,~,~,~|Select Repeat Count
	;
	S COUNT=$$^DBSMBAR(126,"","","",.OP) I 'COUNT Q		; *** BC -
	S zrf(GROUP)=SIZE_"|"_COUNT
RF2	;
	S Z=GROUP D MARKER
	;
	; Display new marker
	;
	S LN=XGRP(GROUP),M(LN,1)=H_m D PUTOBJ^FORMFUN(LN,1)
	S VFMQ="Q"
	Q
PPGRP	;
	I X="" Q
	I X'["["!('$D(XGRP(X))) S ER=1,RM="Invalid group name"
	Q
	;
	;---------- Suppress blank lines
CMDSBL	;
	;
	N LN,XGRP,GROUP,LINE,OP,ZOP,I,X,xsbl,ER,ZOLD
	;
	;---------- Sort definitions by line number order
	;
	S X="" F  S X=$O(zsbl(X)) Q:X=""  S xsbl(+zsbl(X))=zsbl(X)
	S LN="",LINE="",GROUP=""
	F  S LN=$O(D(LN)) Q:LN=""  I $E($G(D(LN,1)))="#",$O(D(LN))'="" DO
	.	S X=$E($P(D(LN,1),dl,1),2,99),XGRP(LN)=X
	;
	; ---------- Display ruler first
	;
	I 'RULER D ^FORMRULR
	;
	;
	; Create,Delete|Suppress Blank Line Definition
	;
	I '$D(zsbl) S OP=1
	E  S OP=$$^DBSMBAR(127) I 'OP Q		; *** BC - Replace DBSMENU call 10/26/93
	;
	I OP=2 DO  Q:'X
	.	S X="" F I=1:1 S X=$O(xsbl(X)) Q:X=""  DO
	..		S ZOP(I)=$P(xsbl(X),",",2,99)
	..		; Select Line Number
	.	S X=$$^DBSMBAR(128,"","","",.ZOP) Q:'X	; *** BC - replace DBSMENU call 10/26/93
	.	S LINE=ZOP(X)
	;
	I OP=1 DO  Q:'LINE
	.	S LINE=$$^FORMREAD("",40,"Enter line number (n,m) or range (from-to,from-to,...): ")	; *** BC - 11/02/93
	.	I 'LINE Q
	.	D UNPAK(LINE,.LN)
	.	S I="",ER="" F  S I=$O(LN(I)) Q:I=""  I $D(XGRP(I)) S ER=ER_","_I
	.	; 
	.	I ER'="" W $$MSG^%TRMVT("Invalid line number "_$E(ER,2,999),"",1) S LINE=""
	;
	S XGRP="",ZOLD=""
	S I="" F  S I=$O(zsbl(I)) Q:I=""  S ZOLD=ZOLD_$P(zsbl(I),",",2,99)_","
	;
	I OP=1 S LINE=$$PACK(ZOLD,LINE)
	;
	F I=1:1 S LNX=$P(LINE,",",I) Q:LNX=""  DO
	.	;
	.	S LN=$ZP(XGRP(+LNX)) I 'LN Q
	.	S GROUP=XGRP(LN)
	.	I OP=2 K zsbl(GROUP) D MARK0,MARKSBL Q
	.	I GROUP'=XGRP S XGRP=GROUP,zsbl(GROUP)=LN	; Line offset
	.	S zsbl(GROUP)=zsbl(GROUP)_","_LNX		; from-to,...
	.	D MARK0,MARKSBL
	S DSP="",OP="SBL" D STATUS0
	Q
	;
	; /SFL   Suppress line feeds
	;
CMDLF	;
	;
	N LN,XGRP,GROUP,LINE,OP,XLN,I
	;
	S LN="",LINE="",GROUP="",I=1
	F  S LN=$O(D(LN)) Q:LN=""  I $E($G(D(LN,1)))="#" DO
	.	S X=$E($P(D(LN,1),dl,1),2,99),XGRP(LN)=X
	.	I X'?1E.E1"-H" Q
	.	S XLN=$O(M(LN)) I 'XLN Q
	.	I $E($G(D(XLN,1)))="#" Q
	.       S LINE(I)=XLN,I=I+1
	;
	I I=1,'$D(slf) W $$MSG^%TRMVT("Invalid function for this report layout","",1) Q
	I I=1,$D(slf) G SLF1			; Delete only
	;
	I '$D(zslf) G SLF2			; Create only
	;
	; Create,Delete|Suppress Line Feed
	S OP=$$^DBSMBAR(129) I 'OP Q	; *** BC - Replace DBSMENU call 10/26/93
	I OP=1 G SLF2
	;
	; DELETE
SLF1	;
	N OPT,I,J
	S I="" F J=1:1 S I=$O(zslf(I)) Q:I=""  S OPT(J)=$P(zslf(I),",",2)
	;
	; Delete Definition ... Select Line Number:
	;
	S X=$$^DBSMBAR(130,"","","",.OPT) I 'X Q	; *** BC - replace DBSMENU call 10/26/93
	;
	S LN=OPT(X)
	S LN=$ZP(XGRP(LN)),GROUP=XGRP(LN)
	K zslf(GROUP)
	D MARK0,MARKSLF
	S DSP="",OP="SLF" D STATUS0
	Q
SLF2	;	
	I 'RULER D ^FORMRULR
	;
SLF3	;
	;
	; Create Definition ... Select Line Number:
	;
	S OP=$$^DBSMBAR(131,"","","",.LINE) I 'OP Q	; *** BC - replace DBSMENU call 10/26/93
	S X=LINE(OP)
	S LN=$ZP(XGRP(X)) I LN="" Q
	S GROUP=XGRP(LN),LINE=X
	; 
	I GROUP'?1E.E1"-H" W $$MSG^%TRMVT("Invalid group header region","",1) G SLF3
	S zslf(GROUP)=LN_","_LINE
	D MARK0,MARKSLF
	S DSP="",OP="SLF" D STATUS0
	Q
	;
MARKER	;
	; #marker
	;
	N Z2,Z1,Z
	S Z=GROUP
	D MARK0
	I $D(zsbl(Z)) s m=$E(m,1,2)_"h"_$E(m,4,999)
	I $D(zslf(Z)) s m=$E(m,1,3)_"e"_$E(m,5,999)
	I '$D(zrf(Z)) Q
	;
	S Z2=$P(zrf(Z),"|",1),Z3=$P(zrf(Z),"|",2)*Z2+1
	F Z1=Z2:Z2:Z3 S m=$E(m,1,Z1)_"x"_$E(m,Z1+2,999)
	;
	;
	Q
MARK0	;
	;
	N Z,ZDES
	S Z=GROUP
	I '$D(zline) S zline="",$P(zline,"qqqqqqqqqq",13)=""
	;
	S H=$$HEADER^FORMINIT(128+2)
	I '$D(VA(H)) D VIDSP^FORMINIT(H)
	;
	S m=$$MRKDSP(Z)
	;
	Q
MARKSBL	;
	D MARKER
	;S LN=XGRP(GROUP),M(LN,1)=H_m D PUTOBJ^FORMFUN(LN,1)
	S M(LN,1)=H_m D PUTOBJ^FORMFUN(LN,1)
	S VFMQ="Q"
	Q
MARKSLF	;
	D MARKER
	S M(LN,1)=H_m D PUTOBJ^FORMFUN(LN,1)
	S VFMQ="Q"
	Q
	;
PACK(OLD,NEW)	; 
	;
	N I,J,K,L,NLN,LN,LINE,HIT,X
	;
	S LINE=""
	D UNPAK(OLD,.LN)			; Unpack original definition
	;
	D UNPAK(NEW,.NLN)			; Unpack new definition
	;
	S I="" F  S I=$O(NLN(I)) Q:I=""  S LN(I)=""	; Combine both
	;
	S I="",HIT=0
	F  S I=$O(LN(I)) Q:I=""  DO			; Pack again
	.	I 'HIT,'$D(LN(I+1)) S LINE=LINE_I_"," Q
	.	I 'HIT,$D(LN(I+1)) S HIT=1,LINE=LINE_I_"-" Q
	.	I HIT,'$D(LN(I+1)) S HIT=0,LINE=LINE_I_"," Q
	;
	I $E(LINE,$L(LINE))="," S LINE=$E(LINE,1,$L(LINE)-1)
	Q LINE
	;
UNPAK(IN,LN)	; 
	;
	F I=1:1 S X=$P(IN,",",I) Q:X=""  DO
	.	I X'["-" S LN(+X)="" Q
	.	S J=+X,K=$P(X,"-",2)
	.	F L=J:1:K S LN(L)=""
	;
	Q	
	;
STATUS	;
	;
	; Merge all groups
	;
	N I,ZGRP,OPT,GRP,FROM,TO,X,S,OP,xsbl,mask
	;-----------------------------------------------------------------------
	; *** BC - Modified to use MASK parameter to skip menu options
	;
	S I=3
	S OP(1)="Repeat_Field|RF" I '$D(zrf) S mask(1)="",I=I-1
	S OP(2)="Blank_Line_Suppress|SBL" I '$D(zsbl) S mask(2)="",I=I-1
	S OP(3)="Line_Feed_Suppress|SLF" I '$D(zslf) S mask(3)="",I=I-1
	;
	; Repeat_Field,Blank_Line_Suppress,Line_Feed_suppress
	;
	I 'I Q
	S OP=$$^DBSMBAR(132,"",.mask,"",.OP) Q:'OP
	S DSP=$P(OP(OP),"|",1)_" ",OP=$P(OP(OP),"|",2)
	;-----------------------------------------------------------------------
STATUS0	;
	S GRP=""
	I OP="RF" F  S GRP=$O(zrf(GRP)) Q:GRP=""  DO
	.	;
	.	S DSP=DSP_" Field Size "_$P(zrf(GRP),"|",1)_" Repeat Count "_$P(zrf(GRP),"|",2)
	.	;	;
	I OP="SBL" D
	.	S DSP=DSP_"LINE STATUS: " K xsbl
	.	S X="" F  S X=$O(zsbl(X)) Q:X=""  S xsbl(+zsbl(X))=zsbl(X)
	.	F  S GRP=$O(xsbl(GRP)) Q:GRP=""  DO
	..		S DSP=DSP_$P(xsbl(GRP),",",2,99)_","
	;
	I OP="SLF" S DSP=DSP_" LINE STATUS: " D
	.	;
	.	F  S GRP=$O(zslf(GRP)) Q:GRP=""  S DSP=DSP_$P(zslf(GRP),",",2,99)_","
	;
	I $E(DSP,$L(DSP))="," S DSP=$E(DSP,1,$L(DSP)-1)
	W $$MSG^%TRMVT(DSP)
	Q
STATUS1	;
	;
	N S1,S2,S3,I
	S S1=$L(zsbl(GRP),",")
	F I=2:1:S1 D ADJSTS
	Q
ADJSTS	;
	S S2=$P(zsbl(GRP),",",I),S3=$P(S2,"-",2)
	S X=X_(FROM-S+S2)
	I S3 S X=X_"-"_(FROM-S+S3)
	S X=X_","
	Q
	;
MRKDSP(KEY)	;
	N ZNM
	S ZNM=$$SEQBY(KEY)
	D SEQBY1
	Q m
	;	
SEQBY(KEY)	; 
	N I,LEV,Z,X,HT,LASTLEV,BASLEV
	;
	I KEY'["[" Q ""
	S LEV="",BASLEV="",LASTLEV=$ZP(^DBTBL(%LIBS,5,RID,11))
	F I=1:1:10 S Z=$G(^DBTBL(%LIBS,5,RID,I)) Q:Z=""  D  I LEV Q
	.	S Z="["_$P($P(Z,"|",1),",",2)
	.	I Z=$P(KEY,"-",1) S BASLEV=I D
	..		I $P(^(BASLEV),"|",1)["""" S BASLEV=""
	..		S LEV=I-1
	..		I $P(^(LEV),"|",1)["""" S LEV=LEV-1
	..		I LEV<0 S LEV=0
	;
	I KEY'["-" S LEV=BASLEV
	I 'LEV Q ""
	;
	S Z=$P(^(LEV),"|",1) S Z=$$DES^DBSDD(Z,.X)		; Description
	S Z=" "_$$UPPER^SCAUTL(Z)_" "				; Upper case
	I LEV=LASTLEV,KEY'["-" Q Z_"(REPORT DETAIL)"		; data level
	I KEY'["-" Q Z_"DETAIL"				; Other detail
	;
	S HT=$P(KEY,"-",2),HT=$S(HT="H":"HEADER",1:"SUBTOTALS")
	Q Z_HT_" "
	;
SEQBY1	;
	I ZNM="" D
	.	I Z["PAGE-" S ZNM=" "_Z_" ",Z=""
	.       I Z="SUMMARY" S ZNM=" REPORT SUMMARY ",Z=""
	;
	S H=$$HEADER^FORMINIT(128+2)
	S m=$S(Z["-T":"m",1:"l")_$E(zline,1,15)_ZNM_$E(zline,1,85-$L(ZNM))
	I Z="" S m=m_$E(zline,1,30)_"k"
	E  S m=m_" "_$J(Z,16)_"  "_$E(zline,1,11)_$S(Z["-T":"j",1:"k")
	I '$D(VA(H)) D VIDSP^FORMINIT(H)
	;
	Q
