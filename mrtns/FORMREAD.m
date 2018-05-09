FORMREAD(X,L,D,T,ZV,TR1,TR2)	; -  - V4.2 - Read a single line
	;;Copyright(c)2000 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/03/00 17:15:40 - TANY
	;     ORIG:  Frank R. Sanchez (2497) - 08/27/89
	;CALLED BY:
	;    CALLS:  ^%TRMVT,^%ZREAD,^FORMCMD,^SCADAT1
	;     DESC: This Extrinsic function quits with a string value read
	;           from the current IO device.  It prompts at the screen
	;           location BTMPAG.
	;
	;           -  Insert mode only
	;           -  RECALL saved in RBU(sub) - Up to 10 previous lines
	;
	;           PARAMETERS:  X - Default response
	;                        L - Maximum string length
	;                        D - Prompt
	;                        T - Data type
	;                        ZV - Video option
	;                        TR1 - Input string
	;                        TR2 - Ouput string
	;---- Revision History ------------------------------------------------
	; 05/17/06 - Allan Mattson - CR20048
	;            Replaced calls to $$UPPER^%ZFUNC with $$UPPER^SCAUTL.
	;
	; 04/03/00 - TANY - 37915
        ;            Optimized performance by modifying ^SCADAT1 calls
        ;            to ^SCAJD. Also remove revision history older than
        ;            one year.
	;----------------------------------------------------------------------
	U ""
	;
	N P,V,Z,INPUT
	;
	S RBU=+$G(RBU),V=RBU+1
	;
	I '$D(X) S X=""
	I '$G(L) S L=$S($D(RHTMAR):RHTMAR,1:79-$L(D))
	I '$D(D) S D=""
	I '$D(T) S T="T"
	;
	I $G(inputdev)'="" N Z S Z=$$READAHED^FORMCMD I Z'="" S X=Z G EXIT
	;
	I $G(ZV) W BTMPAG,$$VIDREV^%TRMVT,D,$$VIDOFF^%TRMVT," "
	E  W BTMPAG,D
	;
	W $$CPS^%TRMVT ; save cursor position
	;
LDISP	; Display data
	;
	W X
	W $$CPR^%TRMVT ; Restore cursor position
LPTR	;
	;
	S X=$$TERM^%ZREAD(X,255,"")
	;
	I %fkey="CUD" D LRBU(V) S V=V+1,X=$G(RBU(V#10)) G LBUFR
	I %fkey="CUU" D LRBU(V) S V=V-1,X=$G(RBU(V#10)) G LBUFR
	I "T"'[T,'$$TYPE G LBUFR
	;
EXIT	;
	D LRBU(RBU)
	I $G(JRNL)'="" U JRNL W !,X U ""
	W BTMPAG
	I $G(TR1)'="" S X=$TR(X,TR1,$G(TR2))
	Q X
	;
LBUFR	W $$CPR^%TRMVT,$$CLL^%TRMVT G LDISP
	;
LRBU(V)	; File buffer
	;
	I X'="",$G(RBU(V#10))'=X S RBU=RBU+1,RBU(RBU#10)=X
	Q
	;
TYPE()	; Convert X to it's internal format
	;
	I "L"[T S X=$S("1YyTt"[X:1,1:0) Q 1 ; Convert logic data items
	I "N$"[T,'(X?1N.N)!(X?1N.N1".".N) G TYPERR
	I "D"[T S X=$$^SCAJD(X) G TYPERR:X<0 Q 1
	I "U"[T S X=$$UPPER^SCAUTL(X) Q 1
	Q 1
	;
TYPERR	W $C(7) Q 0
	;
