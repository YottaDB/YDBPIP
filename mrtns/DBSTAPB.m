DBSTAPB	;; -  - V4.2 - Tape Input Bill File Conversion
	;;Copyright(c)2000 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/04/00 10:52:59 - TANY
	;     ORIG:  David F. Murray (8992) - 06/18/91
	;CALLED BY:
	;    CALLS:
	; PROJ #'S:  
	;     DESC:
	;
	; GLOBALS -
	;     READ:
	;      SET:
	;
	;    INPUT:
	;   OUTPUT:
	;
	;
	; REC is the record from tape or RMS
	; FILEID is the primary file.  i.e. "LN" or "DEP"
	; FN is the secondary file which gets converted along with (or because
	;    of) the primary file.
	; PRIO gets built when LNBIL0 is encountered.  In LNBIL1, when we've
	;      hit all the priorities we know to quit
	;
	;
	;---- Revision History ------------------------------------------------
	; 04/03/00 - TANY - 37915
	;            Optimized performance by modifying ^SCADAT1 calls 
	;            to ^SCAJD. Also remove revision history older than 
	;            one year. 
	;
	; 03/17/98 - Matthew Zwitkowits - 25246
	;	     Modified EXEC section:
	;	     1) Replace S $P(P,"#",IPC)=X 
	;	     with S:X'="" $P(P,"#",IPC)=X
	;	     to remove the extra # after the element ("P#####" => "P")
	;	     2) Replace S:P'="#" $P(BL,"|",FLD)=P
	;	     with S:$TR(P,"#","")'="" $P(BL,"|",FLD)=P
	;	     to prevent a bill record like "|I|P#####|#####|#####" from 
	;	     being created.
	;
	; 02/12/97 - MANDERBACHS - 23824
	;            Modified INIT and EXEC sections to reflect the changes 
	;	     to data elements in v5.2 and up.  Previously, all of the 
	;	     sub-fields (payment elements separated by the "#" sign) 
	;	     were computed data items.  These are now set up under 
	;	     sub-field definitions.
	;
	; 05/17/94 - SPIER - ARQ 13023
	;            Modified exec section to change
	;            s $P(BL,"|",FLD)=P     TO
	;            S:P'="#" $P(BL,"|",FLD)=P         
	;            when running a conversion a "|" piece was being created 
	;	     with just a # which caused scapcu to bomb.
	;----------------------------------------------------------------------
	; 
INIT	;
	N DBREC,DI,FLD,IPC,REC,X,Y,Z
	S X=""
NX	S X=$O(^CNVTBL(FILEID,FN,X)) Q:X=""
	S Y=""
NY	S Y=$O(^CNVTBL(FILEID,FN,X,Y)) I Y="" G NX
	S Z=""
NZ	S Z=$O(^CNVTBL(FILEID,FN,X,Y,Z)) I Z="" G NY
	D INITA
	G NZ
	;
INITA	;
	S REC=$G(^(Z)) I REC="" Q
	S DI=$P(REC,"|",1)                                     ; Data Item
	;
	; Skip over non-data items
	;
	S DBREC=$G(^DBTBL(%LIBS,1,FN,9,DI)) I DBREC="" Q
	;
	; If there is nothing in the subfield (piece 18), it's not computed.
	;
	I $P(DBREC,"|",18)="" Q
	S FMT=$P(REC,"|",2)                                    ; Format
	S LEN=$P(REC,"|",4)                                    ; Length
	S PO1=$P(REC,"|",6)                                    ; Start
	S PO2=$P(REC,"|",7)                                    ; End
	S SFD=$P(DBREC,"|",18)                                 ; Sub-field
	S FLD=$P(DBREC,"|",21)				       ; Field 
	S IPC=+$P(SFD,"~",4)                                   ; Piece in field
	S BILTYP(FN,Y,Z)=FMT_"|"_LEN_"|"_FLD_"|"_IPC_"|"
	S BILTYP(FN,Y,Z)=BILTYP(FN,Y,Z)_PO1_"|"_PO2
	Q
LNBIL1	;
LNBIL0	;
	S JUST=$G(JUST)
	S q=$C(0),PRIO=q
	S Y1=$E(REC,12)
	S Y=$A(Y1)-64
	I FN="LNBIL0" S BSEQ=0
	E  I Y=1 S BSEQ=$O(^BIL(CID,""),-1)+1
	;
	I Y=1 S BL=""
	E  S BL=^BIL(CID,BSEQ)
	S Z=""
NNZ	S Z=$O(BILTYP(FN,Y,Z)) I Z="" G SET
	D EXEC
	G NNZ
	;
EXEC	;
	S FMT=$P(BILTYP(FN,Y,Z),"|",1)
	S FLD=$P(BILTYP(FN,Y,Z),"|",3)		 ; Field
	S IPC=$P(BILTYP(FN,Y,Z),"|",4)           ; Internal piece	
	S PO1=$P(BILTYP(FN,Y,Z),"|",5)           ; Start
	S PO2=$P(BILTYP(FN,Y,Z),"|",6)           ; End
	S LEN=$P(BILTYP(FN,Y,Z),"|",2)           ; Length
	S X=$E(REC,PO1,PO2) I $A(X)=32 Q         ; Get data, if 1st piece
	;                                          is equal to a blank, then 
	;                                          quit since there is no
	;                                          item to process
	; 
	S DFMT=$S(FMT="T":"RTB",FMT="N":"NUM",FMT="$":"DOL",1:"DATE")
	D @DFMT
	I (FN="LNBIL0"),(LEN=1) S:(X<1!(X>4)) X=""
	E  I (FMT="N")!(FMT="$") S:'+X X=""
	;
	S P=$P(BL,"|",FLD)
	;S $P(P,"#",IPC)=X					; MJZ - 25246
	S:X'="" $P(P,"#",IPC)=X					; MJZ - 25246
	I (FN="LNBIL0"),(IPC=1) S PRIO=PRIO_X_q                ; Priority
	E  I (FN="LNBIL1"),(IPC=1),(Y>1) S PRIO=$P(PRIO,q_X_q,1)_q_$P(PRIO,q_X_q,2,999) I '$L($TR(PRIO,q,"")) S NOFILE=0
	;S:P'="#" $P(BL,"|",FLD)=P         ;Spier 4/21/94	; MJZ - 25246
	S:$TR(P,"#","")'="" $P(BL,"|",FLD)=P			; MJZ - 25246
	Q
	;
SET	;I $G(NOFILE) Q
	S BL=BL_"|"
	S ^BIL(CID,BSEQ)=$$RTBAR^%ZFUNC(BL)
	Q
	;
RTB	S X=$$RTB^%ZFUNC(X)
	Q
	;
NUM	; Format numerics
	I X?1" "." " S X="" Q
	S X=+X
	Q
	;
DOL	; Format the dollar amount
	I X?1" "." " S X="" Q
	S ZB=$E(X,$L(X))
	I X["." S X=+X Q
	I ZB?1N S X=+X D DOL2 Q  ; Not zone X
	S ZBT=$TR(ZB,"{ABCDEFGHI}JKLMNOPQR","01234567890123456789")
	S DIV=100 I JUST S DIV=1 F I=1:1:JUST S DIV=DIV_0
	S X=$E(X,1,$L(X)-1)_ZBT,X=X/DIV
	I $A(ZB)>73,$A(ZB)'=123 S X=-X ; Negtive number
	S X=+X
	Q
	;
DOL2	S DIV=100 I JUST S DIV=1 F I=1:1:JUST S DIV=DIV_0
	S X=X/DIV
	Q
	;
DATE	; Format date
	I $E(X,1,8)="00/00/00" S X="" Q
	S %DS=$$RTB^%ZFUNC(X)
	S %JD=$$^SCAJD(%DS) S X="" I %JD'=-1 S X=%JD
	Q
	;
