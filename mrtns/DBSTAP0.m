DBSTAP0	;;PBS -  - V3.7 - Conversion Init Routine
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/27/94 11:56:23 - ZENGF
	;     ORIG:  Robert B. Sproul (8971) - 06/16/89
	;     DESC:
	;
	;---- Revision History ------------------------------------------------
	; 09/27/94 - Fan Zeng - I18N
	;            Prompt table cleanup. Changed LAB1 to LBL1.
	;            Also changed %READ to comply with the new qualifier
	;            format.
	;
	; 07/26/94 - Steve Canfield - I18N
	;	     Converted msgid from DQnnnn to nnnn.
	;
	; 12/12/92 - Allan Mattson - I18N#7
	;
	;            Modified return message handling with a call to extrinsic
	;            function $$^MSG(msgid,p1,p2...) for I18N development
	;            (phrase independence).
	;-----------------------------------------------------------------------
INIT	S %PG=0,%PAGE=1
	K VFMQ
	;
VPG	; Page control
	I $D(VFMQ),"DFQ"[VFMQ G VER
	I %PG=0 D VPG00 G VPG0
	I %PG>0 D VPG01 G VPG0
	;
VPG0	I $D(%PGM) S %PGM=%PGM_$S($D(%LINK):"VPG0^",1:"VPG^")_$T(+0)_"," G VSAV
	I "DFQ"[VFMQ G VER ; Process completed/aborted
	S %PG=%PG+1
	G VPG
	;
VPG00	; Prompt for file name
	; DATA-QWIK File Conversion
	S HDG=$$^MSG(7738)
	S HDG=$J("",80-$L(HDG)\2)_HDG
	K OLNTB
	;
	; /DES=Conversion File Name/TYP=T/LEN=10
	S %TAB("FN")=".FNUM2/TBL=^CNVTBL("
	; /DES=<R>MS or <T>ape/TYP=T/LEN=1
	S %TAB("INPUT")=".INPUT4/XPP=D PP00^DBSTAP0"
	; /DES=Option",OPTION=1/TYP=N/LEN=1
	S %TAB("OPTION")=".OPTION/TBL=TMP("
	;
	; Conversion options
	; Skip records that already exist
	S TMP(1)=$$^MSG(7740)
	; Merge data if record already exists
	S TMP(2)=$$^MSG(7739)
	;
	S %READ="@HDG,,FN/REQ,INPUT/REQ,OPTION/REQ",%NOPRMT="N"
	D ^UTLREAD I $D(%PGM) Q
	I VFMQ="Q" S ER=1 Q
	Q
	;
VPG01	; Tape format or RMS file name
	; /DES=RMS File Name/TYP=T/LEN=50
        I INPUT="R" S %TAB("RMS")=".RMS7/XPP=D PP01A^DBSTAP0"
	; /DES=<L>abeled or <U>nlabeled/TYP=T/LEN=1
	E  S %TAB("LBL")=".LBL1/XPP=D PP01B^DBSTAP0"
	; /DES=<A>SCII or <E>BCIDIC/TYP=T/LEN=1
	E  S %TAB("FRM")=".FRM4/XPP=D PP01C^DBSTAP0"
	; /DES=Log Device",LOG=$I/TYP=T/LEN=40
	S %TAB("LOG")=".LOGFILE3/XPP=S %EXT=1 D ^SCAIO"
	S OLNTB=6000
	;
	I INPUT="T" S %READ="LBL/REQ,FRM/REQ,LOG/REQ"
	E  S %READ="RMS/REQ,LOG/REQ"
	;
	D ^UTLREAD I $D(%PGM) Q
	I VFMQ="Q" S ER=1 Q
	;
VPG01A	; Open log device 
	I $E(LOG)="[" S Z=$$FILE^%ZOPEN(LOG,"WRITE/NEWV",5)
	I $E(LOG)'="[" S Z=$$TERM^%ZOPEN(LOG,5)
	I 'Z S ER=1,RM=$P(Z,"|",2)
	Q
	;
PP00	; RMS or tape post-processor
	I X="R"!(X="T") Q
	; Enter 'R' for RMS or 'T' for tape
	S ER=1,RM=$$^MSG(909)
	Q
	;
PP01A	; RMS file name
	; RMS file input only
	Q:X=""  I X'["." S ER=1,RM=$$^MSG(2428) Q
	S %EXT=1 D ^SCAIO Q:ER  S DEVICE=X C DEVICE
	S Z=$$FILE^%ZOPEN(DEVICE,"READ",5)
	I 'Z S ER=1,RM=$P(Z,"|",2)
	Q
	;
PP01B	; Tape parameters
	I X="L"!(X="U") Q
	; Enter 'L' for labeled or 'U' for unlabeled
	S ER=1,RM=$$^MSG(907)
	Q
	;
PP01C	; Tape parameters
	I X="A"!(X="E") Q
	; Enter 'A' for ASCII or 'E' for EBCDIC
	S ER=1,RM=$$^MSG(903)
	Q
	;
VSAV	; Save variables in %V(array)
	F I="DEVICE" S %V(I)=""
	Q
	;
ERR	S ER=1 D ^UTLERR
	S VFMQ="Q"
	Q
	;
VER	I VFMQ="Q" G END
	I INPUT="R" G CONV
	S X=$G(^CNVTBL(FN))
	S REC=$P(X,"|",7) I 'REC S REC=256
	S BLK=$P(X,"|",8) I 'BLK S BLK=4096
	;
	K %TDRV D ENT^%ZMOUNT I $G(ER) Q
	S (DEVICE,TDRV)=%TDRV
	;
	S P=$S(FRM="E":"EBCDIC/",1:"")_$S(LBL="L":"LABEL/",1:"")
	S P=P_"FIXED/RECORD="_REC_"/BLOCK="_BLK,PARAMS=P
	S X=$$TAPE^%ZOPEN(TDRV,PARAMS)
	;
	; Cannot open tape drive ~p1
	I 'X S ER=1,RM=$$^MSG(469,$P(X,"|",2)) Q
	D TAPE^%ZUSE(TDRV,"REWIND")
	;
CONV	D ENT^DBSTAPIN ; Compiler
	I LOG'=$I C LOG
	;
END	K %TAB L
	Q
