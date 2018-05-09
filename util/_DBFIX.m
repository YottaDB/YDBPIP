%DBFIX	;Public;
	;;Copyright(c)1999 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/12/99 11:23:36 - SILVAGNIR
	;
	; ORIG:	SILVAGNIR - 07/30/99
	;
	; DESC:	This routine will run a fast integrity check with the NOMAP
	; qualifier and put the results into a file.  The integ report
	; is then read, and a db_drive command file is created to repair any
	; Block incorrectly marked Busy, or any Block incorrectly marked Free.
	; errors.
	;
	; Note : This routine should only be run after a FULL integrity check
	;	 only reports benign errors.
	;
	; Directions:
	; 1.  Run routine from the GT.M prompt: D ^%DBFIX.
	; 2.  Enter in the region to repair.
	; 3.  After the routine has returned to the GTM> prompt HALT
	;     out of M.  At this point the DB.GO file can be edited to
	;     verify the contents.
	; 4.  Once the contents of the DB.GO file has been verified,
	;     use MUPIP LOAD DB.GO to load in the data.
	;
	;----------------------------------------------------------------------
	; KEYWORDS: GT.M
	;
	; INPUTS:
	;	None
	;
	; EXAMPLE:
	;	GTM>D ^%DBFIX
	;
	;---- Revision History ------------------------------------------------
	;
	; 06/08/04 - SCHILLW
	;	     Added check for value 45568 from ZSY call that
	;	     spawned integ.  AIX reports -19968, but all other
	;	     UNIX platforms report 45568.
	;
	; 10/18/00 - SILVAGNIR - 42403
	;	     Standardize for /SCA/sca_gtm/rtns
	;
        ; 10/17/00 - SILVAGNIR
	;            - If running version 4.2 there have been some changes
	;              made in regards to how integ reports are displayed.
	;              In the OUT section, if a comma is found, the error is
	;              modified to be the second piece, this will strip the
	;              %GTM messages.  The setting of BLK, and STATE in OUT
	;              were also changed due to the different spacing.
	;              BLK is now determined by $P($P(x," ",1),":",1)
	;              STATE now uses "marked" as it's delimiter, instead of
	;              using $E since the spacing is so different.
	;	     - Also added $gtm_dist in front of all GT.M utilities
	;	       for version 4.2 since it is now required.
	;
	; 08/12/99 - SILVAGNIR
	;	     - Ported to UNIX
	;	     - Documented and cleaned up
	;	     - Removed multiple files, now everything loads into one
	;	       file, DB.GO.
	;
	;----------------------------------------------------------------------
	;
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ERROR^%DBFIX")
	;
	D INIT I ER W !,RM Q
	D INTEG I ER W !,RM Q
	D EXEC I ER W !,RM Q
	D DONE 
	Q
	;---------------------------------------------------------	
INIT	; Initialize variables
	;---------------------------------------------------------	
	W #,!,!
	W "NOTE: This routine should only be run after a FULL integrity",!
	W "      check reports benign errors.",!,!
	W "Directions:",!
	W " 1.  Enter in the region to repair.",!
	W " 2.  After the routine has returned to the GTM> prompt HALT",!
	W "     out of M.  At this point the DB.GO file can be edited to",!
	W "     verify the contents.",!
	W " 3.  Once the contents of the DB.GO file has been verified,",!
	W "     use MUPIP LOAD DB.GO to load in the data.",!,!
	;
	; Find region to run fix against
	W !,"SET REGION to <NULL to exit>: "
	S REG=$$UPPER^%ZFUNC($$TERM^%ZREAD()) W !
	I REG="" S ER=1,RM="Terminated by user - NO REGION SPECIFIED" Q
	;
	S (ER,RM)=""
	S LOG="DB_INTEG.LOG"	; Integ Log File
	S OUT="DB_DRIVE"	; Command file to extract/repair DB
	S SKIP=$C(32,10,13)
	S PREFIX="MAP -BL=",BLK=0
	;
	; Open Files (Write)
	S X=$$FILE^%ZOPEN(OUT,"WRITE/NEWV")
	I +X'=1 S ER=1,RM=$P(X,"|",2) 
	Q
	;---------------------------------------------------------	
INTEG	; Run the Integrity Check against the region to be repaired.
	;---------------------------------------------------------
	;
	; Create and Run INTEG Command file
	S INTEG="$gtm_dist/mupip integ -fast -nomap -reg "_REG_" 2> "_LOG
	S X=$$SYS^%ZFUNC(INTEG)	
	I (X'=0),(X'=-19968),(X'=45568) D
	.	S X=$$SYS^%ZFUNC("cat "_LOG)
	.	S ER=1,RM="Integ Check could not be run due to above errors"
	Q
	;---------------------------------------------------------	
EXEC	; Read integ report and create command files
	;---------------------------------------------------------	
	; Read through integ log and if the line contains 'marked', process. 
	;
	; Open integ log File
	S X=$$FILE^%ZOPEN(LOG,"READ")
	I +X'=1 S ER=1,RM=$P(X,"|",2) Q
	;
	D SETOUT
	F  U LOG R LINE Q:$ZEOF  I LINE["marked" D OUT
        Q
	Q
	;---------------------------------------------------------
SETOUT	; Setup up OUT to find the correct region and
	; open the .go file.
	;---------------------------------------------------------
	U OUT
	W "$gtm_dist/dse <<\xyz",!,"FIND -REGION=",REG,!,"OPEN -FILE=DB.GO",!
	U 0
	Q
	;---------------------------------------------------------
OUT	; Place code in OUT for DSE.
	;---------------------------------------------------------
	; Skip of %GTM messages
	I LINE["," S LINE=$P(LINE,",",2)
	;
	F JUSTIFY=1:1:$L(LINE) Q:SKIP'[$E(LINE,JUSTIFY)
	S ERROR=$E(LINE,JUSTIFY,999)
	S BLK=$P($P(ERROR," ",1),":",1)
        S STATE=$S($E($P(ERROR,"marked",2),2)="f":" -busy",1:" -free")
	U OUT
	I STATE=" -free" W "dump -glo -bl=",BLK,!
	W PREFIX,BLK,STATE,!
	U 0
	Q
	;---------------------------------------------------------
DONE	; Close db_drive.com and create db_load.com
	;---------------------------------------------------------
	D SETCLOSE
	C LOG,OUT
        S X=$$SYS^%ZFUNC("chmod 744 "_OUT)
	I X'=1 S ER=1,RM="Permissions could not be modified for "_OUT
        S X=$$SYS^%ZFUNC(OUT)
        I X'=1 S ER=1,RM="Blocks could not be dumped to DB.GO" Q
 	Q
	;---------------------------------------------------------
SETCLOSE	; Write lines needed to close the .go file
	;---------------------------------------------------------
	U OUT
	W "CLOSE",!
	W "EXIT",!
	W "\xyz",!
	U 0
	Q
	;---------------------------------------------------------
ERROR	;Error handleing
	;---------------------------------------------------------
	U 0
	W $zstatus
	W !,!,"Error - please read above line for explaination"
	Q
