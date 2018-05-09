DBSRJC	;
	;;Copyright(c)1999 Sanchez Computer Associates, Inc.  All Rights Reserved - 01/25/99 13:06:10 - ZHOUC
	;
	; I18N=QUIT
	;---------- Revision History -------------------------------------------
	; 01/25/99 - Chunling Zhou - 999999
	;	     Updated PROC section to kill ^DBSTAT(file) when the file
	;	     def is moved to ^DBTBL.
	;
	; 04/29/98 - Chunling Zhou - 999999
	;	     Modified PROC section to save all fields in a file 
	;	     definition from ^DBTBL to ^dbtbl5 in order to keep 
	;	     customer's change.
	; 
	; 12/31/97 - Chiang 999999 
	;            Modified ITEM definition to change input format from U 
	;            (Uppercase) to T (Text). 
	;
	;            Added option to accept "*" at the "Item" prompt for all
	;            items.
	;
	; 10/06/97 - LAMY - ARQ26323
	;            Removed [ from lookup table definition for ITEM. This
	;	     corrects lookup table error.
	;
	; 09/25/97 - SPIER - 999999
	;            Modified main section to save off custom DI identified 
	;	     in DBSRJC and all Z-named data items. Once this is done
	;	     files are then copied and the custom fields are reloaded.
	;
	; 08/14/97 - SPIER - 25631
	;          Modified calls to routines ztarget and zloader to reference
	;	   these routines in lower case not upper, tw copies the 
	;	   routines to lower not upper.
	;
	; 07/02/97 Chiang - 25124
	;          Modified to support DQ level 7,8 and 9.
	;----------------------------------------------------------------------
	;
	S %TAB("LEVEL")="/LEN=2/TYP=N/DES=DATA QWIK Level/TBL=^DBSRJC(""SYSDEV"","
	; *** 12/31/97 BC
	S %TAB("ITEM")="/LEN=30/TYP=T/DES=Item (enter * for ALL)/TBL=[DBSRJC]/XPP=D PP^DBSRJC"
	S HEAD="DATA-QWIK ELEMENT LOAD"
	;
	S %READ="@HEAD/CEN/REV,,LEVEL/REQ,ITEM/REQ"
	;
	D ^UTLREAD
	I VFMQ="Q" Q
	;
	W $$MSG^%TRMVT("You are about to overlay the selected DATA-QWIK element(s)",0,0,1,23)
	S OK=$$YN^DBSMBAR("","Do you want to continue?",1)
	W $$CLR^%TRMVT(23,24)
	;
	I OK=0 W $$MSG^%TRMVT("Operation cancelled.") H 2 Q
	;
	S ER=0
	I ER W $$MSG^%TRMVT("DATA-QWIK element source not found.",0,1) Q
	;
	I ITEM'="*" D PROC,DONE Q
	S ITEM="" F  S ITEM=$O(^DBSRJC("SYSDEV",LEVEL,ITEM)) Q:ITEM=""  D PROC
	D DONE
	Q
	;----------------------------------------------------------------------
PROC	; Load DQ element
	;----------------------------------------------------------------------
	W $$MSG^%TRMVT(ITEM) H 1
	;;Q
	i LEVEL=1,ITEM'["." D			;9/25/97 MAS
	.	N J
	. 	K ^dbtbl5("SYSDEV",1,ITEM)
	. ; *** by ZCL - 04/29/98
	. ;	S J=ITEM
	. ;	F  S J=$O(^DBSRJC("SYSDEV",LEVEL,J)) Q:J'[ITEM  D
	. ;. ;		S FIELD=$P(J,".",2)
	. ;. ;		S ^dbtbl5("SYSDEV",1,ITEM,9,FIELD)=^DBTBL("SYSDEV",1,ITEM,9,FIELD)
	. ;	S FIELD="Z"
	. ;	F  S FIELD=$O(^DBTBL("SYSDEV",1,ITEM,9,FIELD)) Q:$E(FIELD,1)'="Z"  D
	. 	S FIELD=""
	.	F  S FIELD=$O(^DBTBL("SYSDEV",1,ITEM,9,FIELD)) Q:FIELD=""  D
	..		S ^dbtbl5("SYSDEV",1,ITEM,9,FIELD)=^DBTBL("SYSDEV",1,ITEM,9,FIELD)
	. ;*** BY ZCL
	;
	d dqc^zloader("^dbtbl","^DBTBL",LEVEL,ITEM)  	; Copy
	;
	; *** by ZCL - 01/25/99 - kill ^DBSTAT when a file def is moved to ^DBTBL
	i LEVEL=1 k ^DBSTAT($P(ITEM,"."))
	;
	; restore customizations
	I LEVEL=1,ITEM'["." D			;9/25/97 MAS
	.	S FIELD=""
	.	F  S FIELD=$O(^dbtbl5("SYSDEV",1,ITEM,9,FIELD)) Q:FIELD=""  D
	..		S ^DBTBL("SYSDEV",1,ITEM,9,FIELD)=^dbtbl5("SYSDEV",1,ITEM,9,FIELD)
	.	K ^dbtbl5("SYSDEV",1,ITEM)
	;
	k ^DBSRJC("SYSDEV",LEVEL,ITEM)			; Delete old entry
	s ^TMPDQC($j,"SYSDEV",LEVEL,ITEM)=""		; Force recompile
	d twload^ztarget
	Q
DONE	;
	W $$MSG^%TRMVT("Processing completed",0,1)
	Q
	;----------------------------------------------------------------------
check	; Check source file
	;----------------------------------------------------------------------
	I ITEM["." D  Q
	.	S FLD=$P(ITEM,".",2),ZITEM=$P(ITEM,".",1)
	.	I '$D(^dbtbl("SYSDEV",LEVEL,ZITEM,FLD)) S ER=1 Q
	I '$D(^dbtbl("SYSDEV",LEVEL,ITEM)) S ER=1 Q
	Q
PP	;
	I X="*" D CHANGE^DBSMACRO("TBL","")
	Q
