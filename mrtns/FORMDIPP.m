FORMDIPP(X,FILES,FLAG)	;; -  - V5.0 - Standard file lookup
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/26/94 17:16:15 - CANFIELDS
	;     ORIG:  FSANCHEZ - 19 MAR 1990
	;
	;    INPUT:  X  - data item name in DI or [FID]DI format
	;            FILES - Access files in PFID,FID,... format
	;            FLAG  - Selection flag ( data item defined in more than
	;                                     one file)
	;   OUTPUT:  ER - Error Flag
	;            RM - Message
	;
	; I18N=QUIT	Excluded from I18N Standards
	; ---------- Revision History ------------------------------------------
	;
	; 10/26/94 - Steve Canfield - I18N
	;	     Removed calls to $$^MSG.
	;
	; 10/13/94 - Ying A.C. Liu - I18N
	;            Removed duplicate messages.
	;
	; 05/25/94 - Steve Canfield - I18N
	;            Replaced embedded messages with a call to extrinsic 
	;            function $$^MSG(msgid,p1,p2...) for phrase independence.
	;	     Also converted msgid from RMnnnn to nnnn.
	;
	; 10/25/93  Bob Chiang - I18N#23
	;
	;           Modified to replace DBSMENU routine calls with DBSMBAR.
	;
	; 02/18/93  Bob Chiang 
	;
	;           Modified to change [fid]di pattern check to screen out
	;           [fid] syntax.
	;
	; 11/18/92 - Allan Mattson - I18N#7
	;
	;            Modified return message handling with a call to extrinsic
	;            function $$^MSG(msgid,p1,p2...) for I18N development
	;            (phrase independence).
	;
	;-----------------------------------------------------------------------
	S ER=0,FLAG=0
	I '$D(ZB) S ZB=13
	;
	Q $$VER(X,FILES)
	;
VER(X,FILES)	; ---------- Verify unique data item reference ---------- 
	;
	I $G(X)="" Q ""
	;
	N DI,FID,LIB,Z
	;
	I X?1"["1AN.E1"]"1E.E S DI=$P(X,"]",2),FID=$E($P(X,"]",1),2,999),LIB=""
	E  S DI=X,FID="",LIB="" ; Naked data item reference
	I FID["," S LIB=$P(FID,",",1),FID=$P(FID,",",2) ; Explicit library
	;
	I LIB="" S LIB=$$LIBRARY ; Default library
	I FID="" Q $$VERFID ; Choose from list (FILES)
	S Z=$P($G(^DBTBL(LIB,1,FID,10)),"|",5) I Z'="" S LIB=$E($P(Z,",",1),2,99)
	I '$D(^DBTBL(LIB,1,FID,9,DI)) D ERR Q ""
	;
	I (","_FILES_",")'[(","_FID_",") D ERR Q ""
	Q "["_FID_"]"_DI
	;
VERFID()	; ---------- Verify data item in list of files ----------
	;
	N C,I,OP,FID
	;
	S C=0
	F I=1:1 S FID=$P(FILES,",",I) Q:FID=""  D CHECK
	;
	I C=0 D ERR Q ""
	I C=1 Q "["_OP(1)_"]"_DI
	S FLAG=1
	;
	; ~,~,~,~|Select <<DI>> From File:"
	;
	S C=$$^DBSMBAR(113,"","","",.OP) I 'C Q ""	; *** BC - Replace DBSMENU calls 10/25/93
	Q "["_OP(C)_"]"_DI
	;
CHECK	;
	N Z,LIB
	S LIB=%LIBS
	I '$D(^DBTBL(%LIBS,1,FID)) Q
	S Z=$P($G(^DBTBL(%LIBS,1,FID,10)),"|",5)
	I Z'="" S LIB=$P($P(Z,",",1),"[",2)
	I $D(^DBTBL(LIB,1,FID,9,DI)) S C=C+1,OP(C)=FID
	Q
	;
LIBRARY()	Q $S($G(%LIBS)'="":%LIBS,$G(^CUVAR("%LIBS"))'="":^("%LIBS"),1:"SYSDEV") 
	;
	Q
ERR	;
	S ER=1,RM="Invalid data item - "_X
	Q
