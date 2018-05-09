DBSTAP1	;; -  - V4.0 - Conversion Template Routine
	;;Copyright(c)2000 Sanchez Computer Associates, Inc.  All Rights Reserved - 06/21/00 13:42:02 - DOUGANM
	;     ORIG:  MATTSON - 08/29/89
	;     DESC:
	;
	; I18N=QUIT: Exculded from I18N standards. 
	;
	;---------- Revision History -------------------------------------------
	;
	; 05/17/00 - DOUGANM- 39582 
	;            To improve the performance of error handling, cleaned up 
	;            call to $$NEW^%ZT, and removed use of indirection. 
	;	     Replaced $ZP references with $O(^gbl(...),-1) syntax.
	;
	; 10/04/96 - SPIER - 20948
	;            Added coding for ACNADDR global as part of a dep/ln account
	;
	; 06/24/96 - SPIER - 20948
	;            Removed processing behind addr global, this global will
	;	     not exist under the new filers and so the processing 
	;	     associated with duplication is not required.
	;
	; 12/13/94 - Ying A.C. Liu - I18N
	;	     Replaced MSG 8096 with MSG 1233.
	;
	; 07/27/94 - Shaodong Tony Xu - ARQ 10174
	;            Review and retrofit the prior version bugs resolved.
	;
	; 07/26/94 - Steve Canfield - I18N
	;	     Converted msgid from DQnnnn to nnnn.
	;
	; 10/16/93  Frank Prendergast - I18N#18
	;
	; 	    Change call to DBSMBAR from DBSMENU
	;
	; 12/08/92  Jorma Sinnamo - I18N#7
	;
	;	    Modified call(s) to YN^DBSMENU to include return message
	;	    handling for I18N development (phrase independence.)
	;
	;-----------------------------------------------------------------------
	;
	;-----------------------------------------------------------------------
	;-----------------------------------------------------------------------
	;
INIT	S XSEQ=$O(^XCNV(""),-1)+1,^XCNV(XSEQ)=FILEID_"|"_+$H_"|"_$P($H,",",2)
	S CNT=0,RECSEQ=1,RECOF=$S(OPTION=1:1,1:0)
	;
	N $ZT
	S $ZT=$$SETZT^%ZT("ZT^"_$T(+0))
	;
	F FN="LNBIL0","LNBIL1" D INIT^DBSTAPB
	;
	;-----------------------------------------------------------------------
READ	; Read a record from RMS/tape
	;-----------------------------------------------------------------------
	S REC=$$^%ZREAD(DEVICE,.ER) I ER G READERR
	S RECID=$E(REC),FN=$$RTB^%ZFUNC($E(REC,2,9))
	S RECSEQ=RECSEQ+1
	;
	I RECID=2 D DTL G READ ; Detail record
	I RECID=3 D ADD G READ ; Addendum
	I RECID=1 D KEY G READ
	I RECID=9 G EOJ
	;
	; Invalid record
	U LOG W !,$$^MSG(8097),!,REC
	G READ
	;
	;-----------------------------------------------------------------------
DTL	; Detail record
	;-----------------------------------------------------------------------
	; Record already exists
	I RECOF U LOG W !,$$^MSG(2327),!,REC Q  ; Skip record
	S RECNUM=+$E(REC,10,11)
	;
	I FN="LN" D @("^"_PGMNAM_RECNUM) Q
	D @(FN(FN)_RECID_RECNUM)
	Q
	;
	;-----------------------------------------------------------------------
ADD	; Addendum record
	;-----------------------------------------------------------------------
	; Record already exists
	I RECOF U LOG W !,$$^MSG(2327),!,REC Q  ; Skip record
	S RECNUM=+$E(REC,10,11)
	;
	I FN="CIFS" D CIFLNK Q
	I FN="ACNADDR" D ADDRACN
	I FN="LNBIL0" D LNBIL0^DBSTAPB Q
	I FN="LNBIL1" D LNBIL1^DBSTAPB Q
	Q 
	;
	;-----------------------------------------------------------------------
KEY	; Extract access key(s)
	;-----------------------------------------------------------------------
	S CNT=CNT+1
	;  type '1' records 
	I CNT#100=0 U LOG W !,CNT,$$^MSG(8094) D ^%T
	S PF=FN ; Primary file
	D @FN
	Q
	;
	;-----------------------------------------------------------------------
READERR	; Input error
	;-----------------------------------------------------------------------
	I +ER=1 G EOJ:INPUT="R" I INPUT="T" S ER=0 D EOT Q:ER  G READ
	; Input error...
	U LOG W !!,$$^MSG(1233),$P(ER,"|",2),!!
	G EXIT
	;
	;-----------------------------------------------------------------------
EOT	; End of tape
	;-----------------------------------------------------------------------
	D TAPE^%ZUSE(TDRV,"REWIND")
	C TDRV H 3
	D ENT^%ZDISMOU
	;
	; Tape has completed ... please remove and ready the next tape
	U 0 W !!,$$^MSG(8098)
	D ENT^%ZMOUNT
	I $G(ER) U 0 W !!,RM Q
	S X=$$TAPE^%ZOPEN(TDRV,PARAMS)
	D TAPE^%ZUSE(TDRV,"REWIND")
	Q
	;
	;-----------------------------------------------------------------------
EOJ	; End of job
	;-----------------------------------------------------------------------
	; Total type '1' records read: 
	U LOG W !!,$$^MSG(8099),CNT
	; Trailer record control: 
	W !,$$^MSG(8100),+$E(REC,12,19)
	; Conversion complete 
	U 0 W !,$$^MSG(8095) D ^%T
	;
EXIT	I INPUT="R" C RMS Q
	D TAPE^%ZUSE(TDRV,"REWIND") C TDRV
	D ENT^%ZDISMOU(%TDRV)
	Q
	;
	;-----------------------------------------------------------------------
ZT	; Error trap
	;-----------------------------------------------------------------------
	D ET^%ZT(.ET) ; Determine error type. If INTERRUPT, prompt to abort
	; Stop process
	I ET="INTERRUPT",$$YN^DBSMBAR("",$$^MSG(2552)) Q
	D ZE^UTLERR
	Q
	;
	;-----------------------------------------------------------------------
CIFLNK	; ACN/CIF linkage
	;-----------------------------------------------------------------------
	S POINT=2
	;
NXCIF	S POINT=POINT+2 I POINT=12 Q
	S X=^CNVTBL(FILEID,FN,3,1,POINT),P1=$P(X,"|",6),P2=$P(X,"|",7)
	S CIF=+$E(REC,P1,P2),ROLE=$$RTB^%ZFUNC($E(REC,P2+1,P2+2))
	I CIF-0=0 Q  ; No information
	S ^ACN(CID,99,CIF)=ROLE
	G NXCIF
	;
	;-----------------------------------------------------------------------
ADDRACN	;Loan/Dep account address file
	;-----------------------------------------------------------------------
	S STRING=""
	D @(FN(FN)_RECID_RECNUM)
	S ^ACNADDR(CID)=STRING
	Q
	;-----------------------------------------------------------------------
CMP	; Compiled code inserted here
	;-----------------------------------------------------------------------
	
