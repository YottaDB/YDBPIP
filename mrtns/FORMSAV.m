FORMSAV(ID,OPT)	;;DBS - UTL - V5.0 - SAVE SCREEN/REPORT DEFINITIONS
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/26/94 17:07:16 - CANFIELDS
	;     ORIG:  CHIANG - 15 FEB 1990
	;     DESC:  SAVE/RESTORE SCREEN OR REPORT DEFINITIONS
	;
	; I18N=QUIT	Excluded from I18N Standards
	; ---------- Revision History ------------------------------------------
	;
	; 10/26/94 - Steve Canfield - I18N
	;	     Removed calls to $$^MSG.
	;
	; 05/25/94 - Steve Canfield - I18N
	;            Replaced embedded messages with a call to extrinsic 
	;            function $$^MSG(msgid,p1,p2...) for phrase independence.
	;	     Also converted msgid from RMnnnn to nnnn.
	;
	; 10/26/93  Bob Chiang - I18N#23
	;
	;           Modified to replace DBSMENU routine calls with DBSMBAR.
	;
	; 12/08/92  Jorma Sinnamo - I18N#7
	;
	;	    Modified call(s) to YN^DBSMENU to include return message
	;	    handling for I18N development (phrase independence.)
	;
	;-----------------------------------------------------------------------
	;
START	;
	N SEQ,ZID,PP,LEV
	;
	S ZID=ID I ZID'?1"z".E S ZID="z"_ID
	;
	I $D(^DBTBL(%LIBS,OPT,ZID)),$$USE Q  ; Use backup copy
	;
	K ^DBTBL(%LIBS,OPT,ZID)
	;
	S ^DBTBL(%LIBS,OPT,ZID)=^DBTBL(%LIBS,OPT,ID)
	;
	S SEQ="",PP="",LEV=""
NSEQ	;
	S SEQ=$O(^DBTBL(%LIBS,OPT,ID,SEQ)) I SEQ="" Q
	I $D(^(SEQ))#2 S ^DBTBL(%LIBS,OPT,ZID,SEQ)=^(SEQ)
	I $O(^DBTBL(%LIBS,OPT,ID,SEQ,""))="" G NSEQ
	;
NPP	;
	S PP=$O(^DBTBL(%LIBS,OPT,ID,SEQ,PP)) I PP="" G NSEQ
	I $D(^(PP))#2 S ^DBTBL(%LIBS,OPT,ZID,SEQ,PP)=^(PP)
	I $O(^DBTBL(%LIBS,OPT,ID,SEQ,PP,""))="" G NPP
NLEV	;
	S LEV=$O(^DBTBL(%LIBS,OPT,ID,SEQ,PP,LEV)) I LEV="" G NPP
	I $D(^(LEV))#2 S ^DBTBL(%LIBS,OPT,ZID,SEQ,PP,LEV)=^(LEV)
	G NLEV
USE()	; ---------- Backup copy exists, use or delete -----------
	;
	; 
	Q $$YN^DBSMBAR("","Use backup copy of "_ID_"?")	
