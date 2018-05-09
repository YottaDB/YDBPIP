DBSEXEQ6	;DBSEXEQ6; -  - V5.0 - BUILD QWIK REPORT SORT FILE
	;;Copyright(c)1996 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/17/96 10:16:58 - CHIANG
	;     ORIG:  CHIANG - 10/16/89
	;
	;---- Revision History ------------------------------------------------
	; 
	; 10/17/96 - Bob Chiang - 20948 
	;            Modified to replace node 1-7 references with node 16 
	;            (file access keys). 
	;
	; 06/21/96 - Bob Chiang -20948
	;            Modified to remove DQ level 20 references.
	;
	; 06/05/96 - Bob Chiang -21733
	;            Modified LIBRARY section to return the correct target
	;            library name.
	;----------------------------------------------------------------------
	; I18N=QUIT: Excluded from I18N standards. 
	;----------------------------------------------------------------------
	Q
	;
	; ========== Post-Processor for checking valid ORDERBY data field
	;
ORDERBY(FILES,ORDER,NEWORD)	;
	;
	; Input:
	;
	;          FILES = primary file,secondary file,...
	;          ORDER = data item,data item,...
	;
	; Output:
	;
	;          NEWORD    = [fid]di,[fid]di,...
	;          VORDER(DI)=""  /DESC flag
	;          VDUP(DI)=""    Non-unique data item name
	;
	; Example: ORDERBY("DEP,CIF","BAL,AGE",.ORD)
	;
	;          ORD = [DEP]BAL,[CIF]AGE,[DEP]CID
	;
	;
	N ORD,LIB,ON,PF,FL,I,J,ZORD,X,Y,Z
	S ER=0,NEWORD=""
	K VORDER,VDUP
	;
	; ========== Append missing primary file access keys to ORDER
	;
	S PF=$P(FILES,",",1),LIB=$$LIBRARY(PF)
	;
	; Assume primary file if [fid] not specified
	;
	S I=$L(ORDER,","),Z=""
	F J=1:1:I D SELECT I ER Q
	I ER Q
	;
	; Include any missing keys from the primary file
	;
	S z=^DBTBL(LIB,1,PF,16)				; *** 10/17/96
	F I=1:1:$L(z,",") S Y="["_PF_"]"_$P(z,",",I)_"," I Z'[Y S Z=Z_Y
	;
	; ========== Check ORDER data item names
	;
	S ORDER=Z
	F I=1:1 S ORD=$P(ORDER,",",I) Q:ORD=""  D VER1 I ER Q
	I ER S NEWORD="" Q
	;
	; Return new ORDER syntax
	;
	S NEWORD=$E(NEWORD,1,$L(NEWORD)-1)
	Q
	;
VER1	;
	; ========== Remove / option  ( descending option )
	;
	;
	S ZORD=ORD
	I ORD?1E.E1"/DESC" S ZORD=$P(ORD,"/",1),VORDER($P(ZORD,"]",2))=""
	I ORD?1E1E1"/ASC" S ZORD=$P(ORD,"/",1)
	;
	S ON=0 I ZORD?1"["1E.E1"]"1E.E D VER3 I ON Q
	;
	;F J=1:1 S FL=$P(FILES,",",J) Q:FL=""  D VER2 I ON Q
VER1A	;
	; Invalid data item - ~p1
	I 'ON S ER=1,RM=$$^MSG(1298,ORD) Q
	Q
VER2	;
	S LIB=$$LIBRARY(FL)
	I '$D(^DBTBL(LIB,1,FL,9,ZORD)) Q
	;
	S ON=1,NEWORD=NEWORD_"["_%LIBS_","_FL_"]"_ZORD_"|"
	Q
	;
VER3	;
	N FL
	S FL=$E($P(ZORD,"]",1),2,99),ZORD=$P(ZORD,"]",2)
	G VER2
LIBRARY(FL)	;
	;
	; ========== Implicit File Checking
	;
	N X,LIB
	S LIB=%LIBS
	S X=$P($G(^DBTBL(%LIBS,1,FL,10)),"|",5)		; *** 06/05/96
	I X'="" S LIB=$E($P(X,",",1),2,99)
	Q LIB
SELECT	;
	;
	S X=$P($P(ORDER,",",J),"/",1),ZORD=$P($P(ORDER,",",J),"/",2)
	I X?1"["1E.E1"]"1E.E S VDUP(X)=""
	S X=$$^FORMDIPP(X,FILES,.ZFLG) I ER Q
	I ZFLG S VDUP(X)=""
	I ZORD="" S Z=Z_X_"," Q
	S Z=Z_X_"/"_ZORD_","
	Q
