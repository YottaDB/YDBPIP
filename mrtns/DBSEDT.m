DBSEDT(ARRAY,EDTOPT,HEADER)	;;DBS - DATA-QWIK INTERFACE TO VMS EDITOR
	;;Copyright(c)2000 Sanchez Computer Associates, Inc.  All Rights Reserved - 07/10/00 13:56:19 - SHANL
	;     ORIG:  BOB CHIANG (8447) - 12/14/88
	;     DESC:  VMS EDITORS
	;
	;  I18N=QUIT: Excluded from I18N standards              
	;---- Revision History ------------------------------------------------
	;
	; 07/06/00 - SHANL - 40858
	;            Added section STDASCII to convert a string to plain 
	;            ASCII; 
	;            Modified section INIT to convert extended ASCII to 
	;            standard ASCII. 
	; 
	; 05/12/00 - DOUGANM- 39582 
	;            To improve the performance of error handling, cleaned up 
	;            call to $$NEW^%ZT, and removed use of indirection. 
	;
INIT	; --------------------- Initialization Section ----------------------
	;
	N (ARRAY,EDTOPT,VFMQ,SOURCE,HEADER)
	;
	I $G(HEADER)="" S RMS=$$HOME^%TRNLNM("TMP"_($J#100000)_".DQ") G INIT1
	;
	; Create Temp File Based On Function Description
	;
	I HEADER["]" S HEADER=$P(HEADER,"]",2,99)
	S RMS=$TR(HEADER,"%<>, ]/\[().;:?*&$#@!']","_______") ; *** 12/23/94 BC
	I RMS["__" S RMS=$P(RMS,"__",1)_"_"_$P(RMS,"__",2,99)
	S RMS=$$HOME^%TRNLNM($E(RMS,1,30)_".TMP"_($J#100000))
	;
	S RMS=$$STDASCII(RMS) ;Convert extended ASCII to standard ASCII
INIT1	;
	I $G(SOURCE)>80 S SCR=1
	E  S SCR=""
	;
	;
	; Copy data into rms file
	;
	; Unable to open file ~p1
	C RMS S z=$$FILE^%ZOPEN(RMS,"WRITE/NEWV",5) I 'z S RM=$$^MSG(2799,RMS) G DONE
	;
	S X=0 F I=1:1 S X=$O(ARRAY(X)) Q:X=""  U RMS W ARRAY(X),!   ;  9/27/94   XUS
	;
	C RMS
	;
	; Delay enough time for CURON operation to compete
	;
	H 1 S ER=$$EDTOPT^%OSSCRPT(EDTOPT,RMS,SCR)		; 06/26/97 - HL
	;
	;----------------------------------------------------------------------
SAVE	; Copy RMS file into local array
	;----------------------------------------------------------------------
	;
	D IOF
	;
	;
	; Restore auto-wrap
	;
	U 0 W $$SCRAWON^%TRMVT
	;
	; Quit ...
	I ER S RM=$$^MSG(2299)			;09/12/95
	I  S VFMQ="Q" K ARRAY D DEL G DONE
	;
	S VFMQ="F"
	; Copy RMS into local data array
	;
	; Missing RMS file ~p1
	S z=$$FILE^%ZOPEN(RMS,"READ",5) I 'z S RM=$$^MSG(1769,RMS) G DONE
	;
	;
	N $ZT
	S $ZT=$$SETZT^%ZT("ET^DBSEDT")
	;
	S FLG=1 I RMS["DOCUMENT"!(RMS["Document") S FLG=""
	K ARRAY S ARRAY(1)=""
	;
	; *** 04/09/96 Removed tab conversion logic
	;
	F I=1:1 S X=$$^%ZREAD(RMS,.ET) Q:ET  S ARRAY(I)=X
	;
	;----------------------------------------------------------------------
ET	;
	;----------------------------------------------------------------------
	;
	C RMS
	; 
	;
DEL	; Delete RMS file
	N $ZT
	S $ZT=$$SETZT^%ZT("DELERR")
	;
	;
	S X=$$DELETE^%OSSCRPT(RMS)
	;
DELERR	;
	Q
	;
	;----------------------------------------------------------------------
DONE	; Exit from routine
	;----------------------------------------------------------------------
	;
	D IOBP,H1 W " ",RM," " D H0 H 2
	;
	Q
	;
	;
	;----------------------------------------------------------------------
FORMAT(LINE,SPACE1)	; Remove tabs, replace with correct number of spaces
	;----------------------------------------------------------------------
	; First tab becomes a single space if SPACE1 = 1
	; Called by other utilities, e.g. ^%RTNDESC
	; Call by:  S X=$$FORMAT(X)
	;
	I LINE="" Q "" ; If null, return null
	N TAB,X
	I $G(SPACE1) S LINE=$P(LINE,$C(9),1)_" "_$P(LINE,$C(9),2,999) ; Make 1st tab a space
	S TAB=0
	F ZZ=1:1 S TAB=$F(LINE,$C(9),TAB) Q:'TAB  S LINE=$E(LINE,1,TAB-2)_$J("",8-(TAB-2#8))_$E(LINE,TAB,999)
	F X=$L(LINE):-1:0 Q:$E(LINE,X)'=" "
	S LINE=$E(LINE,1,X)
	Q LINE
	;
	;----------------------------------------------------------------------
IOF	W $$CLEAR^%TRMVT Q
IOBP	W $$BTM^%TRMVT Q
H1	W $$VIDREV^%TRMVT Q
H0	W $$VIDOFF^%TRMVT Q
	;
CONV	;
	; Convert TAB from data item documentations
	;
	N
	D ^SCAIO U IO
	;
	S LIB="SYSDEV",FL="",DI=""
CONV1	;
	S FL=$O(^DBTBL(LIB,11,FL)) I FL="" D CLOSE^SCAIO Q  ; *** XUS 07/25/94
CONV2	;
	S DI=$O(^DBTBL(LIB,11,FL,DI)) I DI="" G CONV1
	S SEQ=""
CONV3	;
	S SEQ=$O(^DBTBL(LIB,11,FL,DI,SEQ)) I SEQ="" G CONV2
	S X=^(SEQ) I X'[$C(9) G CONV3
	W !!,"[",FL,"]",DI,!!
	W !,"*",X S X=$$FORMAT(X) S ^(SEQ)=X
	W !," ",X
	G CONV3
	Q
	;
STDASCII(S)	;Convert a string to plain ASCII 
	N A1,A2 
	S A1="" 
	S A2="AAAAAAACEEEEIIIINOOOOOOUUUUaaaaaaaceeeeiiiinoooooouuuuww" 
	F I=192:1:207  S A1=A1_$C(I) 
	F I=209:1:220  S A1=A1_$C(I) 
	F I=224:1:239  S A1=A1_$C(I) 
	F I=241:1:252  S A1=A1_$C(I) 
	Q $TR(S,A1,A2) 
	; 
