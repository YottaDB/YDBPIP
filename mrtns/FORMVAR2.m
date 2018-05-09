FORMVAR2	;; -  - V5.0 - Form system, variable defini, Data edits
	;;Copyright(c)1996 Sanchez Computer Associates, Inc.  All Rights Reserved - 07/09/96 13:34:32 - CHENARD
	;     ORIG:  Frank R. Sanchez (1) - 10/26/88
	;CALLED BY:
	;    CALLS:  ^%ZM,^DBSCRT8,^DBSPNT,^FORMBOX,^FORMFUN,^FORMREAD,^FORMVAR,
	;            ^FORMVAR2
	;     DESC:  Screen variable definition (page 2)
	;
        ; I18N=QUIT: Excleded from I18N standards.
	;---------- Revision History -------------------------------------------
	; 07/14/06 - RussellDS - CR22121
	;	     Replaced  $C with $$BTYECHAR^SQLUTL to ensure Unicode 
	;	     compliance.
	;
	; 07/09/96 - Phil Chenard - 22347
	;            Replace call to ^FORMBOX w/ call to BOX^%TRMVT in order
	;            to support open platform implementations.  Some platforms
	;            interpret the carriage return differnetly and therefore
	;            affected the results of the graphics box.
	;
	; 12/27/95 - Bob Chiang - 20593
	;            Changed minimum value prompt from "mon" to "min".
	;
	; 11/14/95 - Bob Chiang - 10195
	;            Modified table and pattern check post-processor to prompt
	;            user for the input only if the option is being selected.
	;
	;-----------------------------------------------------------------------
	;
	N VO
	S POSX=RHTMAR-33
	I '$G(TOPY) S TOPY=BOTMAR-6
	;
	I $P(DQP,dl,4)="","E$"[$P(DQP,dl,18) S $P(DQP,dl,4)=2,$P(DQP,dl,5)="$"
	;
	;
	D VBX,VPR,VDA,^DBSPNT(),VTAB Q
	;
VPR	; Build the prompts
	;
	N pr
	S VO="16|9|13"
	;
	S pr="Type:,Decimal:,Table:,Pattern:,Min:,Max:,Del:,Pos:"
	;
	S VO(1)=$$BYTECHAR^SQLUTL(TOPY)_$$BYTECHAR^SQLUTL(POSX+1)_$C(5,0,0,0,0,0,0,0)_"01T"_$p(pr,",",1)
	S VO(2)=$$BYTECHAR^SQLUTL(TOPY)_$$BYTECHAR^SQLUTL(POSX+15)_$C(8,0,0,0,0,0,0,0)_"01T"_$p(pr,",",2)
	S VO(3)=$$BYTECHAR^SQLUTL(TOPY+1)_$$BYTECHAR^SQLUTL(POSX)_$C(6,0,0,0,0,0,0,0)_"01T"_$p(pr,",",3)
	S VO(4)=$$BYTECHAR^SQLUTL(TOPY+1)_$$BYTECHAR^SQLUTL(POSX+15)_$C(8,0,0,0,0,0,0,0)_"01T"_$p(pr,",",4)
	S VO(5)=$$BYTECHAR^SQLUTL(TOPY+2)_$$BYTECHAR^SQLUTL(POSX+2)_$C(4,0,0,0,0,0,0,0)_"01T"_$p(pr,",",5)
	S VO(6)=$$BYTECHAR^SQLUTL(TOPY+3)_$$BYTECHAR^SQLUTL(POSX+2)_$C(4,0,0,0,0,0,0,0)_"01T"_$p(pr,",",6)
	S VO(7)=$$BYTECHAR^SQLUTL(TOPY+4)_$$BYTECHAR^SQLUTL(POSX+2)_$C(4,0,0,0,0,0,0,0)_"01T"_$p(pr,",",7)
	S VO(8)=$$BYTECHAR^SQLUTL(TOPY+4)_$$BYTECHAR^SQLUTL(POSX+19)_$C(4,0,0,0,0,0,0,0)_"01T"_$p(pr,",",8)
	Q
	;
VDA	; Print the data
	;
	N DEL,PY,PX
	S PY=TOPY,PX=POSX+7
	S VO(9)=$$BYTECHAR^SQLUTL(PY)_$$BYTECHAR^SQLUTL(PX)_$C(1,0,0,0,0,0,0,0)_"00T"_$P(DQP,dl,5)
	S VO(10)=$$BYTECHAR^SQLUTL(PY)_$$BYTECHAR^SQLUTL(PX+17)_$C(2,0,0,0,0,0,0,0)_"00N"_$P(DQP,dl,4)
	S VO(11)=$$BYTECHAR^SQLUTL(PY+1)_$$BYTECHAR^SQLUTL(PX)_$C(1,0,0,0,0,0,0,0)_"00L"_$$YN(TABLE)
	S VO(12)=$$BYTECHAR^SQLUTL(PY+1)_$$BYTECHAR^SQLUTL(PX+17)_$C(1,0,0,0,0,0,0,0)_"00L"_$$YN(PTRN)
	S VO(13)=$$BYTECHAR^SQLUTL(PY+2)_$$BYTECHAR^SQLUTL(PX)_$C(20,0,0,0,0,0,0,0)_"00T"_$P(DQP,dl,10)
	S VO(14)=$$BYTECHAR^SQLUTL(PY+3)_$$BYTECHAR^SQLUTL(PX)_$C(20,0,0,0,0,0,0,0)_"00T"_$P(DQP,dl,11)
	S VO(15)=$$BYTECHAR^SQLUTL(PY+4)_$$BYTECHAR^SQLUTL(PX)_$C(1,0,0,0,0,0,0,0)_"00T"_$S($P(DQP,dl,16)="":"",1:$C($P(DQP,dl,16)))
	S VO(16)=$$BYTECHAR^SQLUTL(PY+4)_$$BYTECHAR^SQLUTL(PX+17)_$C(2,0,0,0,0,0,0,0)_"00N"_$P(DQP,dl,17)
	Q
	;
VW	N X D PUTRGN^FORMFUN(10_";"_LFTMAR,(BOTMAR-10)_";"_NUMCOL,1),VREPAINT Q
VBX	D BOX^%TRMVT(ORIGIN,EXTANT) Q
VREPAINT	D CLRRGN^FORMFUN,VBX,VDA,^DBSPNT() Q
VREPRNT	D VBX,VPR,VDA,^DBSPNT() Q  ; CTRL/W
	;
CUR(Y,X)	Q CSI_Y_";"_X_"H" ; Direct cursor address
	;
VTAB	; Build the %TAB(array)
	;
	N PY,PX
	S PY=TOPY-1,PX=POSX+6
	;
	K REQ,%TAB,%MOD S %MAX=8,OLNTB=24001,PGM=$T(+0),%VERSN=4
	;
	S DLIB="SYSDEV",DFID="DBTBL2D",VFSN("DBTBL2D")="DQP"
	;
	S %TAB(1)=$$BYTECHAR^SQLUTL(PY)_$$BYTECHAR^SQLUTL(PX)_$C(1)_"01T00005|*DQP|[DBTBL2D]TYPE|^DBCTL(""SYS"",""DVFM"",|||D VP1^FORMVAR2"
	S %TAB(2)=$$BYTECHAR^SQLUTL(PY)_$$BYTECHAR^SQLUTL(PX+17)_$C(2)_"00N00004|*DQP|[DBTBL2D]DEC"
	S %TAB(3)=$$BYTECHAR^SQLUTL(PY+1)_$$BYTECHAR^SQLUTL(PX)_$C(1)_"00L|*TABLE|[DBTBL2D]TABLE|||D VP4^FORMVAR2"
	S %TAB(4)=$$BYTECHAR^SQLUTL(PY+1)_$$BYTECHAR^SQLUTL(PX+17)_$C(1)_"00L|*PTRN|[DBTBL2D]PTRN|||D VP5^FORMVAR2"
	S %TAB(5)=$$BYTECHAR^SQLUTL(PY+2)_$$BYTECHAR^SQLUTL(PX)_$C(20)_"00T00010|*DQP|[DBTBL2D]MIN"
	S %TAB(6)=$$BYTECHAR^SQLUTL(PY+3)_$$BYTECHAR^SQLUTL(PX)_$C(20)_"00T00011|*DQP|[DBTBL2D]MAX"
	S %TAB(8)=$$BYTECHAR^SQLUTL(PY+4)_$$BYTECHAR^SQLUTL(PX+17)_$C(2)_"00N00017|*DQP|[DBTBL2D]POSIT"
	;
	I $E(DQP,1,2)'="<<" K %TAB ; Don't allow modification to DD
	I $P(DQP,dl,8) F I=3:1:7 K %TAB(I) ; Protected
	D ^DBSCRT8
	I $P(DQP,dl,17) Q			; Del and position
	S $P(DQP,dl,16)="",$P(DQP,dl,17)="",DELIM=""
	Q
	;
YN(X)	Q $$LOG^%ZM(X,%MSKL)
	;					; *** 11/14/94 BC
VP1	S vtblrtn="D VP0^FORMVAR2" Q		; Call ball after table lookup
VP0	D VW					; Repaint partial screen
	Q
VP4	;
	N ORIG,CURR
	I $G(FID)="" S FID=DFID
	I $D(UX(FID,vsn)) S ORIG=$P(UX(FID,vsn),"|",1)
	E  S ORIG=$P(DQP,dl,6)
	;
	I 'X S CURR=""					; *** 11/14/94
	E  W BTMPAG S CURR=$$^FORMREAD($P(DQP,dl,6),999,"Table: ","T","","|")  ; *** BC - Table 11/02/93
	;
	I CURR'=$P(DQP,dl,6) S $P(DQP,dl,6)=CURR D UX^FORMVAR(FID,vsn,ORIG,CURR)
	S TABLE=(CURR'=""),X=TABLE Q
	;
VP5	;
	N ORIG,CURR
	I $D(UX(FID,vsn)) S ORIG=$P(UX(FID,vsn),"|",1)
	E  S ORIG=$P(DQP,dl,9)
	;
	I 'X S CURR=""					; *** 11/14/94 BC
	E  W BTMPAG S CURR=$$^FORMREAD($P(DQP,dl,9),999,"Pattern: ","T","","|")  ; *** BC - Pattern 11/02/93
	I CURR'=$P(DQP,dl,9) S $P(DQP,dl,9)=CURR D UX^FORMVAR(FID,vsn,ORIG,CURR)
	S PTRN=CURR'="",X=PTRN Q
	;
