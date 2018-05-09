DBSCRT8D	;DBSCRT8D; -  - V4.4 - DQ Screen Print Utility
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/26/02 09:35:01 - PARRAS
	;     ORIG:  CHIANG - 08/10/89
	;CALLED BY:  ^DBSCRT8
	;    CALLS:  ^%TRMVT,^DBSCRT,^DBSMBAR,^DBSPNT,^SCAIO,^USID
	;     DESC:  Screen print utility  (CTRL/P)
	;
	;
	;---------- Revision History -------------------------------------------
	; 02/26/02 - PARRAS - 45065
	;	     Modified the SCREEN section to reload the data when %O=1. 
	;	     In modify mode, if the user chose to print the screen 
	;	     without header, no information would be displayed.
	;
	; 07/26/94 - Steve Canfield - I18N
	;	     Converted msgid from DQnnnn to nnnn.
	;
	; 10/08/93  Frank Prendergast - I18N#18
	;
	; 	    Change call to DBSMBAR from DBSMENU
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
	; 10/20/92  Bob Chiang
	;
	;           Modified to replace open/close IO with standard calls to
	;           OPEN^SCAIO and CLOSE^SCAIO
	;
	;-----------------------------------------------------------------------
	;
SCREEN	; Print screen
	;
	I '$D(%O) Q
	;
	N ZPGM
	I $G(VPGM)'="" S ZPGM=VPGM ;		Screen run-time routine name
	;
	E  S ZPGM=$G(PGM) ;			Link screen or UTLREAD screen
	;
	I '$D(ZPGM) Q
	;
	N IO,POP,%EXT,z,ZZO,%NOFF
	S ZZO=%O N %O
	S %O=ZZO
	;
	S %NOCLOSE=1 ;W $$CLR^%TRMVT(24)
	;
	; Select output device
	;
	D CLOSE^DBSCRT
	;
	D ^DBSIO					; Select Device
	I IO="" Q
	D HDR I (%O=4)!(%O=1)!(%O=0)!($D(UX)) D VDA^@ZPGM	; PAR 02/26/02
	D PNT
	;
	D CLOSE^SCAIO
	; Done
	W $$MSG^%TRMVT($$^MSG(855),"",1)
	D OPEN^DBSCRT
	Q
	;
HDR	; Load screen header VO array, if selected
	N SID S SID=$P($G(^CUVAR("DBS")),"|",5) I SID="" Q
	N PGM D ^USID I PGM="" Q
	;
	; Print screen header
	I '$$YN^DBSMBAR("",$$^MSG(2226)) Q
	;
	N VO D VPR^@PGM,VDA^@PGM
	D PNT S %NOFF=1
	Q
	;
PNT	; ========== Switch to printer mode
	;
	S %O=4 D ^DBSPNT()
	Q
	;
