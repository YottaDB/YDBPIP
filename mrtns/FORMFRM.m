FORMFRM(COL)	;JSC;11:43 PM  25 Apr 1993
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/27/94 08:37:04 - CANFIELDS
	;
	;      ORIG: Robert Chiang
	;
	;      DESC: Create Screen Frame
	;
	;            Option to create a standard screen frame or a smaller
        ;            frame based on the first and last prompts on the screen.
	;
	; ARGUMENTS:
	;
	;    COl	Column size (80 or 132)		/TYP=N/REQ/REF=VAL
	;
	; EXAMPLE:     D ^FORMFRM(80)
	; I18N=QUIT	Excluded from I18N Standards
	; ---------- Revision History ------------------------------------------
	; 07/14/06 - RussellDS - CR22121
	;	     Replaced $C(192) reference with $$BYTECHAR^SQLUTL to ensure
	;	     Unicode compliance.
	;
	; 10/26/94 - Steve Canfield - I18N
	;	     Removed calls to $$^MSG.
	;
	; 10/25/93  Bob Chiang - I18N#23
	;
	;           Modified to replace DBSMENU routine calls with DBSMBAR.
	;
	;-----------------------------------------------------------------------
	N OP,X,FR,TO
	; "Create Frame (Max),Create Frame (Min),Create Frame (*),Delete Frame"
	S OP=$$^DBSMBAR(115) I 'OP Q	; *** BC - menu option 115 - 10/25/93
	;
	I $G(COL)<80 S COL=80				; Column Size
ROW	;
	I OP=1 D CREATE("","") D PUTRGN^FORMFUN() Q	; Create Maximum Frame
	I OP=2 D CREATE("*","*") D PUTRGN^FORMFUN() Q	; Create Minimum Frame
	I OP=4 D DELETE,PUTRGN^FORMFUN() Q		; Delete Frame
	S X=$$^FORMREAD("",20,"Row Range (from-to): ","T")
	I X="" Q					; Range
	I X'?1N.N1"-"1N.N W $$MSG^%TRMVT("Invalid Format","",1) G ROW
	S FR=$P(X,"-",1),TO=$P(X,"-",2)			; From row- to row
	I TO="" S TO=FR
	I FR'?1N.N!(TO'?1N.N)!(FR>TO) W $$MSG^%TRMVT("Invalid Format","",1) G ROW
	D CREATE(FR,TO) D PUTRGN^FORMFUN()		; Display
	Q
	;-----------------------------------------------------------------------
CREATE(FL,TL)	; Private ; Create a new screen frame
	;-----------------------------------------------------------------------
	; ARGUMENTS:
	;
	;   FL    From Line Number		/TYP=N/NOREQ/DEF=1/REF=VAL
	;         * (One line above the first object)
	;
	;   TL    To Line Number		/TYP=N/NOREQ/DEF=22/REF=VAL
	;         * (One line below the last object)
	;
	; INPUTS:
	;
	;   COL	  Column Size (80 or 132)
	;
	; EXAMPLE:
	;
	;      D ^FORMFRM(1,10)         Partial screen (line 1 to 10)
	;      D ^FORMFRM("","")	Full screen (line 1 to 22)
	;      D ^FORMFRM("*","*")	System calculated frame
	;-----------------------------------------------------------------------
	N LN,TOP,BOT,I,AT
	;
	D DELETE					; Delete Frame First 
	I FL="*" S FL=$O(M(""))-1			; Before First Obj
	I TL="*" S TL=$ZP(M(""))+1			; After Last Obj
	;
	I $G(FL)<1 S FL=1				; Default to line 1
	I '$G(TL) S TL=22				; Default to line 22
	I $ZP(M(""))+1>22 S TL=$ZP(M(""))+1		; Increase Size
	I $D(M(FL)) S TL=TL+1 D MOVE(FL,.M),MOVE(FL,.D)	; Move screen down by 1
	I $D(M(TL)) S TL=TL+1 D MOVE(TL,.M),MOVE(TL,.D)
	;
	I $$LINEL(FL,TL) D SHIFTR(.D),SHIFTR(.M)	; Shift Right By 1
	S G=$$BYTECHAR^SQLUTL(192)			; Graphic Mode
	S LN="",$P(LN,"q",COL-1)=""			; Line (qqqq)
	S AT=$C(0,0,0,0,0)				; Field Header
	S TOP="l"_LN_"k"				; Top Line
	S BOT="m"_LN_"j"				; Bottom Line
	;
	F I=FL:1:TL D
	.	I I=FL S M(FL,1)=G_AT_TOP Q		; First Line
	.	I I=TL S M(TL,1)=G_AT_BOT Q		; Last Line
	.	S M(I,1)=G_AT_"x"			; Left |
	.	I $$SHIFTL(I) Q				; Shift Left if required
	.	S M(I,COL)=G_AT_"x"			; Right |	
	Q
	;-----------------------------------------------------------------------
DELETE	; Private ; Delete graphic objects
	;-----------------------------------------------------------------------
	;
	; INPUT: M()    Text Object Definition
	;-----------------------------------------------------------------------
	;
	N I,J
	;
	S I="",J="" 
	F  S I=$O(M(I)) Q:I=""  F  S J=$O(M(I,J)) Q:J=""  I $E(M(I,J))=$$BYTECHAR^SQLUTL(192) K M(I,J)
	Q
	;
	;-----------------------------------------------------------------------
MOVE(LN,O)	; Private ; Move Screen down by one line
	;-----------------------------------------------------------------------
	; ARGUMENTS:
	;
	;   LN    Starting Line Number
	;   O     Object Type  (M or D)
	;-----------------------------------------------------------------------
	N I,J
	S I=$ZP(O(""))+1,J=""
	F  S I=$ZP(O(I)) Q:I=""!(I<LN)  F  S J=$ZP(O(I,J)) Q:J=""  D
	.	S O(I+1,J)=O(I,J)
	.	K O(I,J)
	Q
	;-----------------------------------------------------------------------
SHIFTR(O)	; Private ; Shift Screen right by one line
	;-----------------------------------------------------------------------
	;
	; ARGUMENT:
	;
	;   O     Object Type  (M or D)
	;-----------------------------------------------------------------------
	N I,J
	S I="",J=""
	F  S I=$O(O(I)) Q:I=""  F  S J=$ZP(O(I,J)) Q:J=""  D
	.	S O(I,J+1)=O(I,J)
	.	K O(I,J)
	Q
	;-----------------------------------------------------------------------
LINEL(FL,TL)	; Check region for objects located on column 1
	;-----------------------------------------------------------------------
	N I,HIT
	S I=FL-1,HIT=0
	F  S I=$O(M(I)) Q:I=""!(I>TL)  I $D(M(I,1)),$E(M(I,1))'=$$BYTECHAR^SQLUTL(192) S HIT=1 Q
	Q HIT
	;-----------------------------------------------------------------------
SHIFTL(LN) ; Private ; Shift Object left by 1 position
	;-----------------------------------------------------------------------
	;
	N I,J,N
	I '$D(M(LN)) Q 0				; Blank Line
	S J=$ZP(M(LN,""))				; Last Obj on the line
	S N=J+$L(M(LN,J))-COL-6 I N'>0 Q 0		; Have room
	I N>2 Q 1					; Skip This Line
	S J="" F  S J=$O(M(LN,J)) Q:J=""  D		; Shift Left (text)
	.	I J-N<1 Q
	.	S M(LN,J-N)=M(LN,J) K M(LN,J)
	;	
	S J="" F  S J=$O(D(LN,J)) Q:J=""  D		; Shift Left (data)
	.	I J-N<1 Q
	.	S D(LN,J-N)=D(LN,J) K D(LN,J)
	
	Q 0
