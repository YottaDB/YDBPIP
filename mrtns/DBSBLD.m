DBSBLD	;;DBS - REP - V3.4 - BUILD DATA QWIK ACCESS METHOD 
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/08/97 09:40:12 - CHIANG
	;     ORIG:  CHIANG - 1/1/85
	;CALLED BY:  ^DBSDS8
	;    CALLS:  ^DBSDE,^DBSREL
	; PROJ #'S:  
	;     DESC:  BUILD RECORD ACCESS METHOD
	;
	;---------- Revision History -------------------------------------------
	;
	; 05/08/97 - Chiang - 24661
	;            Modified ERR section to display error message and then exit
	;            from compiler.
	;            
	; 09/05/96 - SPIER - 20948
	;            Remove sections A,B,SELECT,BLD which are no longer called
	;
	; 08/23/96 - SPIER - 22637
	;            Changed $n to $o 
	;
	; 10/27/94 - Bob Chiang - ARQ 18
	;            Removed calls to $$^MSG.
	;
	;----------------------------------------------------------------------
        ;   I18N=QUIT : Excluded From I18N Standards
	Q
ERR	;
	; 
	U 0 W !!,"Invalid file linkages ... "
	W PFID," - ",^DBTBL(%LIBS,1,PFID)
	W !!,$G(FILES),!!
	F I=1:1 Q:'$D(XFID(I))  W !,XFID(I),?12,^DBTBL(%LIBS,1,XFID(I))
	; 
	Q
	;
FLD	;
	S L=L+1,BLD(L)=" ;",BLD(L+1)="EXEC ;",L=L+1
	S SVL=L
	;
	I $D(LOOP(-2,1)) S FID=LOOP(-2,1)
	;
	S LOOP=L
	Q
	;
	Q
