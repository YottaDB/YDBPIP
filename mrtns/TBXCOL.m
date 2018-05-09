TBXCOL	;Private;DataQwik data item handler
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/08/02 16:52:41 - KWANL
	; ORIG:	KWANL - 05/08/02
	; DESC:	DataQwik data item handler
	;
	;-------- Revision History ---------------------------------------------
	; 2008-12-05, CR37058, Frans S.C. Witte
	;	Added support for obsoletion of %-column
	;
        ; 02/20/08	KWANL
        ;		Modified RDB section to use isTblExt^TBXSQL to check if
        ;		table exists in RDB or not.
        ;
        ; 01/09/08	KWANL
        ;		Modified RDB section to treat DEPSEG and LNSEG as wide table
        ;
        ; 07/20/07	KWANL
        ;		Skip the computed column when loading to RDB.
        ;		
        ; 02/14/07 KWANL
        ;	   Added code to check table type before setting up ^TMPSQL global in OBSDQW section.	   
        ;
        ; 05/23/06 LK
        ;	   Fixed typos.
        ;
        ; 04/06/06 KWANL
        ;	   Modified RDB section to check if the column to be installed is
        ;	   a sub-type. Quit, if it is.
        ;	
        ; 03/08/06 KWANL
        ;	   Per Dan R. modified LOAD and EXTRACT section to set DEL="". 
        ;
	; 01/24/05 KWANL
	;	   Change PACKTYPE to MRPC in SAVEOBJ
	;        
        ; 01/03/06 KWANL
        ;	   Modified RDB section to handle wide table.
        ;
        ; 11/17/05 KWANL
        ;	   Replaced reference to ^CUVAR with $$SCAU^%TRNLNM("DDPLOG")
        ;	   Moved the code to obsolete and install to TBXDQL for RDB
        ;	   environment.
        ;	
        ; 10/20/05 KWANL
        ;	   Prevent MRPC updating relational db in LOAD section.
        ;
        ; 10/19/05 KWANL
        ;	   Modifed the OBSDWQ section to create an entry in ^TMPSQL global
        ;	   such that the column will be drop at a later time.
        ;
        ; 09/27/05 KWANL
        ;	   Modified the LOAD section to check if there is any column assoicated with PSL or
        ;	   Framework upgrade. If there is, set up the entry in ^TMPDQS($J,"phase1")
        ;	   or ^TMPDQS($J,"phase2"). This will tigger the related procedures to be compiled 
        ;	   at an earlier stage.
        ;	   Modified the RDB section as follows:
        ;	   1.) Added code to prevent loading computed column and master field to relational db.
        ;	   2.) Removed create table logic from RDB section.
        ;	   3.) Changed to use type^TBXSQL to return the proper type for the column.
        ;	   4.) Checked if table exists in user_table, if not set up ^TMPSQL($J,"TBL",FID)
        ;              The table will be created after all schema changes are updated to DBTBL.
        ;	   5.) Changed the SQL command to update NOT NULL field with default value, if the column
        ;	       about to modified becomes NOT NULL.
	;	   Modifed the OBSDQW section to drop a column from the table.
        ;	   	
        ; 07/11/05 MBUIM CR 14804
        ;	   Modified RDB section to change REQ="" from REQ=NULL and 
        ;	   SQL statement depending on the value of REQ.
        ;
        ; 06/20/05 MBUIM CR 14804
        ;	   Modified RDB section to set REQ="NULL" instead of REQ=""
        ;
        ; 06/15/05 MBUIM CR 14804
        ;	   Removed call to FILE^DBMAP in RDB section. The ^DBTBL global
        ;	   must be defined completely for the table before FILE^DBMAP is 
        ;	   called
        ;
        ; 06/09/05 MBUIM CR 14804
	;	   Modified RDB section to map the reserved names in a 
	;	   relational database and builds the DBMAP global.
        ;
        ; 03/15/05 MBUIM CR 14804
        ;	   Added RDB section called from LOAD section to consider 
        ;	   relational database and either create, add or modify column.
        ;	   Also added a DBAPI section that is called from RDB to 
        ;	   process the calls and ZRDB to trap errors.
        ;
        ; 09/10/04 LK
        ;          Check to see if the table is obsoleted or not
        ;          ie ^TMPDQC($J,"SYSDEV",TABLE)=-1
        ;          before set up an entry in ^TMPDQC to recompile the data item.
        ;
	;-----------------------------------------------------------------------
GETCODE(OBJECTID,CODE,FILENAME)	; Get object contents
	;-----------------------------------------------------------------------
	;
	N FID,KEY
	;
	I $G(OBJECTID)="" Q 0_$C(13,10)_$$^MSG(741)
	;
	S FID=$P(OBJECTID,"-",1),KEY=$P(OBJECTID,"-",2)
	;
	; The first character in the column name may be a "%". This is
	; will be translated to an underscore fo that it can be used in the file
	; name. 
	I $E(KEY,1)="%" S KEY="_"_$E(KEY,2,999)
	;
	; skip data item begins with "$","%" and in quotes
	I (KEY["*")!(KEY["""")!(KEY["$") Q 0_$C(13,10)_" This Data item should be in table header"
	;
	S FILENAME=FID_"-"_KEY_".COL"
	Q $$EXTRACT(.CODE,FID,KEY)
	;
	;-----------------------------------------------------------------------
CHECKOBJ(TOK,OBJECTID)	; Return a message for update or create prompt
	;-----------------------------------------------------------------------
	;
	N HEADER,USER,DATE,TIME,END,CONAME,MESSAGE,FID,KEY
	;
	; S CONAME=$$^CUVAR("CONAM")
	S CONAME=$$SCAU^%TRNLNM("DDPLOG")
	S END=$O(^TMP(TOK,""),-1)
	I END="" Q 0_$C(13,10)_"Missing source code"
	;
	S FID=$P(OBJECTID,"-",1),KEY=$P(OBJECTID,"-",2)
	;
	I '$D(^DBTBL(%LIBS,1,FID,9,KEY)) D  Q MESSAGE
	.	S MESSAGE=1_$C(13,10)_"Create new Data Item in "_CONAME
	;
	S HEADER=^DBTBL(%LIBS,1,FID,9,KEY)
	S USER=$P(HEADER,"|",26)
	S DATE=$$^%ZD($P(HEADER,"|",25))
	;
	S MESSAGE="Update Data Item : "_FID_"-"_KEY_" Modified by "_USER
	S MESSAGE=MESSAGE_" on "_DATE_" in "_CONAME
	;
	Q 1_$C(13,10)_MESSAGE
	;
	;-----------------------------------------------------------------------
SAVEOBJ(TOK,OBJECTID,USER)	; Save Foreign Key Def sent by client
	;-----------------------------------------------------------------------
	;
	N SEQ,CODE,FID,KEY,FILENAME
	S SEQ=""
	;
	; Load from buffer into CODE array
	F  S SEQ=$O(^TMP(TOK,SEQ)) Q:SEQ=""  S CODE(SEQ)=^TMP(TOK,SEQ)
	;
	; Delete buffer
	K ^TMP(TOK)
	;
	S FID=$P(OBJECTID,"-",1),KEY=$P(OBJECTID,"-",2)
	S FILENAME=FID_"-"_KEY_".COL"
	Q $$LOAD(.CODE,FILENAME,3,USER,+$H,$P($H,",",2))
	;
        ;-----------------------------------------------------------------------
CHECK(FILE,RUSER,RDATE,RTIME); Compare date stamp between ^DBTBL and ^dbtbl
        ;-----------------------------------------------------------------------
        ; ARGUMENTS:
        ;       . FILE          RMS file name           /TYP=T
	;	. RUSER		Last modified user on released file
	;	. RDATE		Last modified date on released file
	;	. RTIME		Last modified time on released file
        ; RETURNS:
        ;       . $$            Match or Failure        /TYP=T
        ;                       Match = 1
        ;                       Failure returns
        ;                         0|cdate|cuser
	; 
        ;-----------------------------------------------------------------------
        ;
	N TBLID,KEY,CDATE,CUSER,DDATE,DUSER
	S TBLID=$P(FILE,"-",1),KEY=$P($P(FILE,".",1),"-",2)
	;
	; The first character in the column name may be a "%". This is
	; translated to an underscore fo that it can be used in the file
	; name. Translate it back to a percent sign before checking the column.
	I $E(KEY,1)="_" S KEY="%"_$E(KEY,2,999)
	;
        S CDATE=$P($G(^DBTBL("SYSDEV",1,TBLID,9,KEY)),"|",25)               ; ^DBTBL^
	S CUSER=$P($G(^DBTBL("SYSDEV",1,TBLID,9,KEY)),"|",26)
	S DDATE=$P($G(^dbtbl("SYSDEV",1,TBLID,9,KEY)),"|",25)               ; ^dbtbl^
	S DUSER=$P($G(^dbtbl("SYSDEV",1,TBLID,9,KEY)),"|",26)
        ;
	Q $$CKDTUSR^TBXDQUTL(DDATE,DUSER,CDATE,CUSER,RDATE,RUSER)
        ;
        ;-----------------------------------------------------------------------
LOAD(CODE,FILE,RTYPE,USER,DATE,TIME) ; Load a column (data item)
        ;-----------------------------------------------------------------------
        ; ARGUMENTS:
	;	. CODE        Content of dataqewik element	/TYP=ARR
	;	. FILE        RMS file name			/TYP=T
        ;       . RTYPE       Release type
        ;                       1: fixpack
        ;                       2: service pack
	;		        3: mrpc
        ;       . USER        Last modified user		/TYP=T
        ;       . DATE        Last modified date		/TYP=N
        ;       . TIME        Last modified time		/TYP=N
        ;       
        ; RETURNS:
        ;       . $$            Success or failure		/TYP=T
        ;                       Success = 1
        ;                       Failure returns
        ;			  "0|Wrong file type"
        ;-----------------------------------------------------------------------
        ;
        N $ZT,ER,EXIT,IDX,KEY,LEN,REQ,SEQ,SRC,SQL,TBLID,TMPSTR,TYP,X,Y
        ;
	S $ZT=$$SETZT^%ZT("ZTL^TBXCOL")
	;
        S TBLID=$P(FILE,"-",1),KEY=$P($P(FILE,".",1),"-",2)
	;
	; The first character in the column name may be a "%". This is
	; translated to an underscore fo that it can be used in the file
	; name. Translate it back to a percent sign before loading it.
	I $E(KEY,1)="_" S KEY="%"_$E(KEY,2,999)
	;
        K ^DBTBL("SYSDEV",1,TBLID,9,KEY),^DBTBL("SYSDEV",11,TBLID,KEY)
	;
	; update ^DBTBL and insert last modified info 
	; lines above line 32 are belongs to data item
	; lines below line 32 are belongs to documentation
	;
	S IDX=0,SEQ1="",SEQ1=$O(CODE(SEQ1),-1)
	S SEQ="" F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  D
	. I SEQ<32 D  Q
	.. S $P(TMPSTR,"|",SEQ)=$P(CODE(SEQ),"=",2,9999)
	. E  D
	.. I (SEQ1=SEQ)&(CODE(SEQ)="") Q
	.. S IDX=IDX+1
	.. S ^DBTBL("SYSDEV",11,TBLID,KEY,IDX)=CODE(SEQ)
	I IDX'=0 S ^DBTBL("SYSDEV",11,TBLID,KEY)=IDX
	S $P(TMPSTR,"|",25)=DATE,$P(TMPSTR,"|",26)=USER
	;
	; set DEL="" per Dan R.
	S $P(TMPSTR,"|",20)=""
	S ^DBTBL("SYSDEV",1,TBLID,9,KEY)=TMPSTR
	;
	; if service pack, udpate ^dbtbl
	I RTYPE=2 D
	. K ^dbtbl("SYSDEV",1,TBLID,9,KEY),^dbtbl("SYSDEV",11,TBLID,KEY)
	. S SRC="^DBTBL(""SYSDEV"",1,"""_TBLID_""",9,"""_KEY_""")"
	. S X=$$CP^TBXDQUTL(SRC,"^dbtbl")
	. I $D(^DBTBL("SYSDEV",11,TBLID,KEY)) D
	.. S SRC="^DBTBL(""SYSDEV"",11,"""_TBLID_""","""_KEY_""")"
	.. S Y=$$CP^TBXDQUTL(SRC,"^dbtbl")
	;
	;
	I (RTYPE=1)!(RTYPE=2) D
	. S ^TMPDQC($J,"SYSDEV",1,TBLID_"."_KEY)=""
	. ; 09/27/2005. Check column type
	. I $D(^TMPDQS($J,"phase1",$$LOWER^%ZFUNC(TBLID),TBLID_".TBL")) s ^TMPDQS($J,"phase1")=1
	. I $D(^TMPDQS($J,"phase2",$$LOWER^%ZFUNC(TBLID),TBLID_".TBL")) s ^TMPDQS($J,"phase2")=1
	;
	I RTYPE=3 Q 1
	; Create/Add/Modify table in oracle database
	I $G(db)'="GTM" D
	.	D RDB(KEY,TBLID,TMPSTR)
	Q:$G(ER) "0|Failed to update column definition "_TBLID_"."_KEY
	Q 1        
	;-----------------------------------------------------------------------
EXTRACT(CODE,TBLID,KEY)        ;
        ;-----------------------------------------------------------------------
        ;
        N DATA,$ZT,IDX
	S $ZT=$$SETZT^%ZT("ZTE^TBXCOL")
        ;
        Q:(KEY["*")!(KEY["""")!(KEY["$") "0|Not a valid data item"
	;
	; The first character in the column name may be a "%". This is
	; translated to an underscore fo that it can be used in the file
	; name. Translate it back to a percent sign before loading it.
	I $E(KEY,1)="_" S KEY="%"_$E(KEY,2,999)
	;
        Q:'$D(^DBTBL("SYSDEV",1,TBLID,9,KEY)) "0|Data item "_TBLID_"."_KEY_" does not exist"
	;
	S DATA=$G(^DBTBL("SYSDEV",1,TBLID,9,KEY))
        S CODE($O(CODE(""),-1)+1)="NOD="_$P(DATA,"|",1)
        S CODE($O(CODE(""),-1)+1)="LEN="_$P(DATA,"|",2)
        S CODE($O(CODE(""),-1)+1)="DFT="_$P(DATA,"|",3)
        S CODE($O(CODE(""),-1)+1)="DOM="_$P(DATA,"|",4)
        S CODE($O(CODE(""),-1)+1)="TBL="_$P(DATA,"|",5)
        S CODE($O(CODE(""),-1)+1)="PTN="_$P(DATA,"|",6)
        S CODE($O(CODE(""),-1)+1)="XPO="_$P(DATA,"|",7)
        S CODE($O(CODE(""),-1)+1)="XPR="_$P(DATA,"|",8)
        S CODE($O(CODE(""),-1)+1)="TYP="_$P(DATA,"|",9)
        S CODE($O(CODE(""),-1)+1)="DES="_$P(DATA,"|",10)
        S CODE($O(CODE(""),-1)+1)="ITP="_$P(DATA,"|",11)
        S CODE($O(CODE(""),-1)+1)="MIN="_$P(DATA,"|",12)
        S CODE($O(CODE(""),-1)+1)="MAX="_$P(DATA,"|",13)
        S CODE($O(CODE(""),-1)+1)="DEC="_$P(DATA,"|",14)
        S CODE($O(CODE(""),-1)+1)="REQ="_$P(DATA,"|",15)
        S CODE($O(CODE(""),-1)+1)="CMP="_$P(DATA,"|",16)
        S CODE($O(CODE(""),-1)+1)="ISMASTER="_$P(DATA,"|",17)
        S CODE($O(CODE(""),-1)+1)="SFD="_$P(DATA,"|",18)
        S CODE($O(CODE(""),-1)+1)="SIZ="_$P(DATA,"|",19)
        S CODE($O(CODE(""),-1)+1)="DEL="_$P(DATA,"|",20)
        S CODE($O(CODE(""),-1)+1)="POS="_$P(DATA,"|",21)
        S CODE($O(CODE(""),-1)+1)="RHD="_$P(DATA,"|",22)
        S CODE($O(CODE(""),-1)+1)="SRL="_$P(DATA,"|",23)
        S CODE($O(CODE(""),-1)+1)="CNV="_$P(DATA,"|",24)
        S CODE($O(CODE(""),-1)+1)="LTD="
        S CODE($O(CODE(""),-1)+1)="USER="
        S CODE($O(CODE(""),-1)+1)="MDD="_$P(DATA,"|",27)
        S CODE($O(CODE(""),-1)+1)="VAL4EXT="_$P(DATA,"|",28)
        S CODE($O(CODE(""),-1)+1)="DEPREP="_$P(DATA,"|",29)
        S CODE($O(CODE(""),-1)+1)="DEPOSTP="_$P(DATA,"|",30)
        S CODE($O(CODE(""),-1)+1)="NULLIND="_$P(DATA,"|",31)
        S IDX=""
        I $D(^DBTBL("SYSDEV",11,TBLID,KEY))  D
        . F  S IDX=$O(^DBTBL("SYSDEV",11,TBLID,KEY,IDX)) Q:IDX=""  D
        ..  S CODE($O(CODE(""),-1)+1)=^DBTBL("SYSDEV",11,TBLID,KEY,IDX)
        ;
        Q 1
	;-----------------------------------------------------------------------	
OBSDQW(FILE); Obsolete a data item
	;-----------------------------------------------------------------------
	;
	N TBLID,DI,NAME,X,FID,COL
	S NAME=$P(FILE,".",1),TBLID=$P(NAME,"-",1),DI=$P(NAME,"-",2)
	;
	; The first character in the column name may be a "%". This is
	; translated to an underscore fo that it can be used in the file
	; name. Translate it back to a percent sign before loading it.
	I $E(DI)="_" S DI="%"_$E(DI,2,999)
	;
	Q:'$D(^DBTBL("SYSDEV",1,TBLID,9,DI)) 1
	;
	I $G(db)="" S db="GTM"
	I $G(db)'="GTM" D
	.	Q:'$$rdb^UCDBRT(TBLID)
	.	n v s v=^DBTBL("SYSDEV",1,TBLID,9,DI)
	.	i $P(v,"|",16)'="",($P(v,"|",16)'=" ") Q ; Computed	; skip computeds
	.	S ^TMPSQL($J,"obsolete",TBLID,DI)=""
	;
	K ^DBTBL("SYSDEV",1,TBLID,9,DI)				; remove data item
	K ^dbtbl("SYSDEV",1,TBLID,9,DI)
	K ^DBTBL("SYSDEV",11,TBLID,DI)				; remove documentation
	K ^dbtbl("SYSDEV",11,TBLID,DI)
	S X=$G(^TMPDQC($J,"SYSDEV",1,TBLID))
	I X=-1 Q 1
	E  S ^TMPDQC($J,"SYSDEV",1,TBLID_"."_DI)=""		; need to be recompiled
	;
	Q 1
	;
	;----------------------------------------------------------------------
RDB(KEY,TBLID,TMPSTR)     ; Relational DataBase Load
        ;----------------------------------------------------------------------
        ;
        N table,IsSubTyp,DATA
        S $ZT=$$SETZT^%ZT("ZRDB^TBXCOL")
	;
	I '$$rdb^UCDBRT(TBLID) Q 			; quit if it is belongs to a M table
	Q:$D(^TMPSQL($J,"TABLE",TBLID))
	; 
	I $P(TMPSTR,"|",16)'="",($P(TMPSTR,"|",16)'=" ") Q ; Computed	; skip computeds
	;
	s IsSubTyp=0
	;; I "DEP,LN"[TBLID D
	I $$isWdTbl^TBXSQL(TBLID) D
	. s table=$$getWtbl^TBXSQL(TBLID,KEY)
	. I (table="ACN")!(table="ACNSEG") s IsSubTyp=1
	E  D
	. S table=$$RESWRD^DBMAP(TBLID)
	;
	I IsSubTyp Q
	;
	I $G(table)="" d  Q
	. d logmsg^TBXDQUTL("Error : wide table is not defined",zlogf)
	; 
	s DATA=$$isTblExt^TBXSQL(table)
	I DATA<0 Q		; SQL error
	;
	; if the table is not found, add it to a temp global.
	I DATA'=1 D  Q
	. S ^TMPSQL($J,"TABLE",TBLID)=""
	;
	; defer the column to create later.
	s ^TMPSQL($J,"COLUMN",TBLID,KEY)=""
	;
	Q 
	;
	;----------------------------------------------------------------------
ZTL     ; Error trap for load
        ;----------------------------------------------------------------------
        ;
	N X
	S X=$ZSTATUS
	S ER=1
        S RM="Failed to load element. "_X
        ;
        Q 0_"|"_RM
        ;
        ;----------------------------------------------------------------------
ZTE     ; Error trap for extract
        ;----------------------------------------------------------------------
        ;
	N X
	S X=$ZSTATUS
	S ER=1
	S RM="Failed to extract element "_X
	;
	Q 0_"|"_RM
	;
	;----------------------------------------------------------------------
ZRDB    ; Error trap for relational database element load 
        ;----------------------------------------------------------------------
        ;
	N X
	S X=$ZSTATUS
	S ER=1
        S RM="Failed to load relational database element. "_X
        ;
        Q
        ;