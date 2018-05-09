DBSUTL8	;Public;DBTBL access utility routine
	;;Copyright(c)1996 Sanchez Computer Associates, Inc.  All Rights Reserved - 06/24/96 09:40:53 - SPIER
	; ORIG:	SPIER - 06/21/96
	; DESC:	DBTBL INDEX access utility routine
	; 	This routine contains functions used to return DQ data
	;	item information. All functions are based on the information
	;	stored in the index DBINDX.
	;
	; KEYWORDS:	DATA-QWIK,INDEX
	;
	; INPUTS:
	;	. System	
	;
	;	. Data	[ddfile]di
	;
	;	. v1	desc of variable	/TYP=T
	;
	; RETURNS:
	; FUNCTIONS:
	;	DILIST  - passed (FID,NODE,POS,LIBS) 
	;			- Return a data item name
	;
	Q
	;----------------------------------------------------------------------
DILIST(FID,NODE,POS,LIBS)	;Public;Return a data item name
	;----------------------------------------------------------------------
	;
	; Passed a node and piece assignment, return the data item
	; associated with that node and piece for a given table.
	; Null is returned for invalid node,pos,file. 
	;
	; KEYWORDS:	DATA-QWIK,INDEX
	;
	; ARGUMENTS:
	;	. FID	FID			/TYP=T/REQ/MECH=VAL
	;
	;	. NODE	NODE			/TYP=T/REQ/MECH=VAL
	;
	;	. POS	PIECE			/TYP=T/REQ/MECH=VAL
	;
	; RETURNS:
	;	. $$	data item name		/TYP=T
	;
	; EXAMPLE:
	;	W $$DILIST^DBSTBLU("DEP",1,1)
	;	returns TITLE1
	;	DBINDX("SYSDEV","STR","DEP",1,1,"TITLE1")=""
	I FID=""!(NODE="")!(POS="") Q ""
	N RETURN,%LIBS,IMPLICIT
	S %LIBS=$G(LIBS)
	I $G(%LIBS)="" S %LIBS=$$^CUVAR("%LIBS")
	S IMPLICIT=$P($G(^DBTBL(%LIBS,1,FID,10)),"|",5)
	I IMPLICIT'="" S %LIBS=$P($P(IMPLICIT,"[",2),",",1)
	S RETURN=$O(^DBINDX(%LIBS,"STR",FID,NODE,POS,""))
	Q RETURN
	;
