DBSRWBR2	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSRWBR2 ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	N DX N DY N I N LINE N LN1 N LN2 N MAXCOL N QUIT N SIZE N TAB N ZLN1 N ZLN2
	N BTM N COL N DATA N OLD N VCOL N VIDINC N VIDOFF N VIDREV N X
	;
	S BTM=$$BTM^%TRMVT S VIDREV=$$VIDREV^%TRMVT
	S VIDINC=$$VIDINC^%TRMVT S VIDOFF=$$VIDOFF^%TRMVT
	;
	S VCOL=$piece(vCOL,"\",1)
	;
	I PGNO=1 S LN1=1
	E  S X=$$TMPGET^DBSRWBR(0,PGNO,0,.DATA) S LN1=+DATA
	S X=$$TMPGET^DBSRWBR(0,PGNO+1,0,.DATA)
	I X S LN2=DATA-1
	E  S LN2=$$LASTLINE^DBSRWBR
	;
	S LN1=LN1-lnoff S LN2=LN2-lnoff
	S ZLN1=LN1 S ZLN2=LN2
	;
	; Number of columns, column ID, column position
	;
	S MAXCOL=$L(VCOL,",")
	F I=1:1:MAXCOL D
	.	S X=$piece(VCOL,",",I)
	.	S COL(I)=$piece(X,"#",1)
	.	S TAB(I)=$piece(X,"#",2)
	.	S SIZE(I)=$piece(X,"#",3)
	.	Q 
	;
	D STATUS
	;
	; Start at line 1 column 1
	;
	S LINE=LN1 S QUIT=0
	F  D  Q:QUIT 
	.	N BLK N COLUMN
	.	;
	.	S COLUMN=1
	.	S BLK=$$DSPNEW(1,LINE)
	.	I 'BLK D
	..		D ASK
	..		S QUIT=1
	..		Q 
	.	;
	.	; Try next field
	.	E  I BLK=1 S LINE=LINE+1
	.	E  S QUIT=1
	.	Q 
	;
	; No valid field on screen
	; BROWSE option not available for this page
	I 'QUIT WRITE $$MSG^%TRMVT($$^MSG("4912"),0,1)
	;
	Q 
	;
ASK	; Read next input key  read X#1 do ZB^%ZREAD
	;
	N BLK N QUIT
	N X N z
	;
	S QUIT=0
	;
	F  D  Q:QUIT 
	.	;
	.	READ X#1 D ZB^%ZREAD
	.	S z=%fkey
	.	;
	.	I z="ENT" S z="CUD" ; Change enter to down
	.	;
	.	I z="ESC" D  ; Exit
	..		D DSPOLD
	..		S QUIT=1
	..		Q 
	.	;
	.	E  I z="DSP" D  ; refresh screen CTRL/W
	..		D PRINT
	..		D STATUS
	..		S BLK=$$DSPNEW(COLUMN,LINE)
	..		Q 
	.	;
	.	E  I "/CUU/CUD/CUF/CUB/"[("/"_z_"/") D
	..		F  D  Q:'BLK 
	...			D DSPOLD
	...			I z="CUU" D MOVUP
	...			I z="CUD" D MOVDN
	...			I z="CUF" D MOVRT
	...			I z="CUB" D MOVLF
	...			S BLK=$$DSPNEW(COLUMN,LINE)
	...			Q 
	..		Q 
	.	;
	.	E  I z="HLP" D
	..		I $$HELP D
	...			D PRINT
	...			D STATUS
	...			S BLK=$$DSPNEW(COLUMN,LINE)
	...			Q 
	..		Q 
	.	;
	.	E  I z="SEL" D
	..		I $$SELECT D
	...			D PRINT
	...			D STATUS
	...			S BLK=$$DSPNEW(COLUMN,LINE)
	...			Q 
	..		Q 
	.	;
	.	D DSPNEW1
	.	Q 
	Q 
	;
MOVUP	; Private - Move up one row
	;
	I LINE=LN1 S LINE=LN2
	E  S LINE=LINE-1
	Q 
	;
MOVDN	; Private - Move down one row
	;
	I LINE=LN2 S LINE=LN1
	E  S LINE=LINE+1
	Q 
	;
MOVRT	; Private - Move right one column
	;
	I COLUMN=MAXCOL S COLUMN=1
	E  S COLUMN=COLUMN+1
	Q 
	;
MOVLF	; Private - Move left one column
	;
	I COLUMN=1 S COLUMN=MAXCOL
	E  S COLUMN=COLUMN-1
	Q 
	;
PRINT	; Private
	;
	S LN1=+ZLN1 S LN2=+ZLN2
	I 'LN1 S LN1=1
	;
	D PRINT^DBSRWBR(LN1,LN2)
	;
	S LN1=ZLN1 S LN2=ZLN2
	Q 
	;
DSPNEW(COLUMN,LINE)	;
	;
	N BLK N LEN N X
	N FIELD
	;
	S BLK=""
	;
	S X=$$TMPGET^DBSRWBR(LINE,0,0,.FIELD)
	I 'X Q -1 ; Not defined
	;
	S DX=TAB(COLUMN) S DY=LINE-LN1+vHDG
	S LEN=SIZE(COLUMN)
	I LEN>0 S OLD=$E(FIELD,DX,LEN+DX-1)
	E  D
	.	N DX1
	.	I $D(TAB(COLUMN+1)) S DX1=TAB(COLUMN+1)-2
	.	E  S DX1=999
	.	I DX1<DX S DX1=999
	.	S OLD=$E(FIELD,DX,DX1)
	.	Q 
	;
	I OLD?." "!(OLD?."-"." ")!(OLD?."="." ") D  ; Skip field
	.	S BLK=1
	.	S OLD=""
	.	Q 
	;
	E  I '$get(OP) D DSPNEW1
	;
	Q BLK
	;
DSPNEW1	; Private
	;
	WRITE $$CUP^%TRMVT(DX,DY),VIDREV,OLD,VIDOFF
	WRITE $$CUP^%TRMVT(DX,DY),$$CUOFF^%TRMVT
	Q 
	;
DSPOLD	; Private
	;
	WRITE OLD
	Q 
	;
SELECT()	;
	;
	N DINAM N %O
	N I N RM N X
	;
	S DINAM=COL(COLUMN)
	I DINAM'["[" D MSG Q 0
	;
	D FILEDEF(DINAM)
	I I(5)="" D MSG Q 0
	;
	; Reset screen right margin
	S %O=2
	S X=$$^DBSTBL(I(5))
	D TERM^%ZUSE(0,"ECHO/WIDTH=133")
	I $get(RM)'="" D MSG Q 0
	;
	Q 1
	;
HELP()	; Private - Help key
	;
	N DOCFLG N DINAM N OLNTB N VPT
	N I N RM N X N ZDI N ZFID
	;
	S DINAM=COL(COLUMN)
	I $E(DINAM,1)=""""!(DINAM'["[") D MSG Q 0
	;
	D FILEDEF(DINAM)
	S I(2)="["_ZFID_"]"_ZDI
	;
	N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen1()
	I '$G(vos1) S DOCFLG=""
	E  I $$vFetch1() S DOCFLG=rs
	;
	S VPT=OLNTB\1000
	;
	WRITE $$CPS^%TRMVT ; Save current locstion
	;
	D SEL^DBSHLP(DINAM,.VPT,"","",1)
	;
	I 'VPT!(VPT=24) D  Q 0 ; Option not selected
	.	HANG 2
	.	D STATUS
	.	WRITE $$CPR^%TRMVT
	.	Q 
	;
	I VPT=1 D PNTHDR^SCAVHDG Q 1 ; Repaint column header
	;
	WRITE $$LOCK^%TRMVT(vHDG,24) ; Lock column header
	Q 1
	;
FILEDEF(DINAM)	; Private
	;
	N %TO
	;
	S OLNTB=((vHDG-1)*1000)+1 S %TO=60
	;
	S ZFID=$E($piece(DINAM,"]",1),2,99)
	S ZDI=$piece(DINAM,"]",2)
	;
	N dbtbl1d S dbtbl1d=$$vDb2("SYSDEV",ZFID,ZDI)
	S I(1)=$P(dbtbl1d,$C(124),1)
	S I(2)=$P(dbtbl1d,$C(124),2)
	S I(3)=$P(dbtbl1d,$C(124),3)
	S I(4)=$P(dbtbl1d,$C(124),4)
	S I(5)=$P(dbtbl1d,$C(124),5)
	S I(6)=$P(dbtbl1d,$C(124),6)
	S I(7)=$P(dbtbl1d,$C(124),7)
	S I(8)=$P(dbtbl1d,$C(124),8)
	S I(9)=$P(dbtbl1d,$C(124),9)
	S I(10)=$P(dbtbl1d,$C(124),10)
	S I(11)=$P(dbtbl1d,$C(124),11)
	S I(12)=$P(dbtbl1d,$C(124),12)
	S I(13)=$P(dbtbl1d,$C(124),13)
	S I(14)=$P(dbtbl1d,$C(124),14)
	S I(15)=$P(dbtbl1d,$C(124),15)
	;
	S E8=I(9) S E67=I(2) S FID=ZFID S ZB=13
	Q 
	;
MSG	; Private
	;
	WRITE $$CPS^%TRMVT ; save current location
	;
	; Option not available for this field
	WRITE $$MSG^%TRMVT($$^MSG("4913"),0,1)
	;
	D STATUS
	WRITE $$CPR^%TRMVT ; restore
	Q 
	;
STATUS	; Private - Display function key name at status line
	;
	WRITE BTM
	I $get(ZSTATUS)="" D
	.	N A
	.	;
	.	S A(1)="HLP"
	.	S A(2)="SEL|List"
	.	S A(3)="ESC"
	.	;
	.	S ZSTATUS=$$SHOWKEY^%TRMVT(.A)
	.	Q 
	;
	WRITE ZSTATUS
	Q 
	;
vSIG()	;
	Q "60107^24086^sviji^6996" ; Signature - LTD^TIME^USER^SIZE
	;
vDb2(v1,v2,v3)	;	voXN = Db.getRecord(DBTBL1D,,0)
	;
	N dbtbl1d
	S dbtbl1d=$G(^DBTBL(v1,1,v2,9,v3))
	I dbtbl1d="",'$D(^DBTBL(v1,1,v2,9,v3))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1D" X $ZT
	Q dbtbl1d
	;
vOpen1()	;	SEQ FROM DBTBL11D WHERE %LIBS='SYSDEV' AND FID=:ZFID AND DI=:ZDI ORDER BY SEQ DESC
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(ZFID) I vos2="" G vL1a0
	S vos3=$G(ZDI) I vos3="" G vL1a0
	S vos4=""
vL1a4	S vos4=$O(^DBTBL("SYSDEV",11,vos2,vos3,vos4),-1) I vos4="" G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a4
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
