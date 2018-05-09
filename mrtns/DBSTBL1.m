DBSTBL1	;; -  - V4.4 - Display look-up table entries (CTRL/P) option
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 07/26/94 19:22:56 - CANFIELDS
	;     ORIG:  CHIANG -  5 APR 1991
	;CALLED BY:  DBSTBL
	;    CALLS:  ^%TRMVT,^%ZD,^%ZREAD,^DBSMBAR,^SCAIO
	;     DESC:  Display look-up table entries
	;
	;-------- Revision History ---------------------------------------------
	; 07/26/94 - Steve Canfield - I18N
	;	     Converted msgid from DQnnnn to nnnn.
	;
	; 03/10/94  Bob Chiang - I18N
	;
	;           Modified to replace $J format command with $$^%ZM call.
	;
	; 10/17/93  Frank Prendergast - I18N#18
	;
	; 	    Change call to DBSMBAR from DBSMENU
	;	    Text moved to ^STBL("MBAR")
	;
	; 12/15/92 - Allan Mattson - I18N#7
	;
	;            Replaced messages imbedded in calls to $$MSG^%TRMVT with a
	;            call to extrinsic function $$^MSG(msgid,p1,p2...) for I18N
	;            development (phrase independence).
	;
	;
	; 12/08/92  Jorma Sinnamo - I18N#7
	;
	;	    Modified call(s) to YN^DBSMENU to include return message
	;	    handling for I18N development (phrase independence.)
	;
	; 07/14/92   Robert Chiang   (9595.43)
	;
	;            Modified to check valid date format (julian) before
	;            converting it to external format with standard %ZM
	;            utility.
	;
	; 10/06/92   Modified to handle CTRL/P (print screen) option 
	;            correctly.
	;
	; 10/20/92   Bob Chiang
	;
	;            Modified to replace OPEN^SCAIO with ^DBSIO and
	;	     'C IO' command  with 'D CLOSE^SCAIO'
	;            (close PNT/Q device correctly)
	;----------------------------------------------------------------------
PNT	; Print out look-up table
	;----------------------------------------------------------------------
	;
	;   Input variables:  
	; 
	;               vcol(col)= size ,type
	;
	;                r(seq)= column data <tab> column data <tab> ...
	;
	;                 pn(n)= page/line number pointer
	;
	N (HDG,r,vcol,rows,recs,ofset,pn)
	;					; *** BC - 03/10/94
	D INIT^%ZM()				; Init format mask variables
	S OP=1 I pn>1 S OP=$$^DBSMBAR(27) I 'OP Q
	;
	S ER=0,two=0 I recs'<rows s two=1		; one or two columns
	;
	; Display table in single column
	I two,$$YN^DBSMBAR(.OPM,$$^MSG(835)) s two=0 ; Switch to 1-up
	;
	D ^DBSIO I IO="" Q				; Select output device
	U IO W !					
	;
	s ncol=$ZP(vcol(""))				; No of columns
	;
	I $G(HDG)'="" W !,HDG,!				; Column heading
	;
	I OP=2 S z1=1,z2=pn(pn)+recs			; Range
	E  S z1=pn(pn)+1,z2=z1+recs-1			; Current Page
	;
	S seq=z2-z1+1
	I two S seq=seq+1\2,z2=z1+seq-1			; 2-up display
	;
	F J=z1:1:z2 S line=$$BUILD(r(J)) S:two line=line_$$BUILD($G(r(J+seq))) W !,line
	;
	W !
	D CLOSE^SCAIO
	; Done
	W $$MSG^%TRMVT($$^MSG(855),"",1)			; DONE message
	Q
	;
BUILD(x)	;
	S ln=""
	F I=1:1:ncol S v=$P(x,$C(9),I),ln=ln_$$FORMAT_"  "	; format output
	I two s ln=ln_$J("",40-$L(ln))				; 2-up
	Q ln
FORMAT()	;
	S size=$P(vcol(I),",",1),type=$P(vcol(I),",",2)
	I type="D" I v'?1.5N Q v			; Already converted
	I type="D" Q $$DAT^%ZM(v)			; External format
	I type="C",v'?1N.N Q v
	I type="C" Q $$TIM^%ZM(v)			; Time HH:MM AM/PM
	I type="$" Q $J($$NUM^%ZM(v,2,$G(%MSKE)),size)	; Dollar $$.CC *** 03/10/94
	I type="N" Q $J(v,size)				; Numeric
	I type="L" Q $S(v:"Y",1:"N")			; Logical Y/N
	Q v_$J("",size-$L(v))				; Format T,U,F
