TBXCOL	;Private;DataQwik data item handler
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/08/02 16:52:41 - KWANL
	; ORIG:	KWANL - 05/08/02
	; DESC:	DataQwik data item handler
	;
	; KEYWORDS:	
	;
	; INPUTS:
	;	. System	
	;
	;	. Data	[ddfile]di
	;
	;	. v1	desc of variable	/TYP=T
	;
	; RETURNS:
	;	. XX	desc of return		/TYP=T
	;
	; RELATED:
	;	. $$func^rtn - description of how related
	;
	; EXAMPLE:
	;	Text of example (line one)
	;
	;********************************************************************** 
	; Revision History: 
	; 02/14/07 KWANL 
	;    Added code to check table type before setting up ^TMPSQL global in OBSDQW section.	   
	; 
	; 05/23/06 LK 
	;    Fixed typos.
	; 
	; 04/06/06 KWANL 
	;    Modified RDB section to check if the column to be installed is
	;    a sub-type. Quit, if it is.
	; 
	; 03/08/06 KWANL 
	;    Per Dan R. modified LOAD and EXTRACT section to set DEL="". 
	; 
	; 01/24/05 KWANL
	;	   Change PACKTYPE to MRPC in SAVEOBJ
	;        
	; 01/03/06 KWANL 
	;    Modified RDB section to handle wide table.
	; 
	; 11/17/05 KWANL 
	;    Replaced reference to ^CUVAR with $$SCAU^%TRNLNM("DDPLOG")
	;    Moved the code to obsolete and install to TBXDQL for RDB
	;    environment.
	; 
	; 10/20/05 KWANL 
	;    Prevent MRPC updating relational db in LOAD section.
	; 
	; 10/19/05 KWANL 
	;    Modifed the OBSDWQ section to create an entry in ^TMPSQL global
	;    such that the column will be drop at a later time.
	; 
	; 09/27/05 KWANL 
	;    Modified the LOAD section to check if there is any column assoicated with PSL or
	;    Framework upgrade. If there is, set up the entry in ^TMPDQS($J,"phase1")
	;    or ^TMPDQS($J,"phase2"). This will tigger the related procedures to be compiled 
	;    at an earlier stage.
	;    Modified the RDB section as follows:
	;    1.) Added code to prevent loading computed column and master field to relational db.
	;    2.) Removed create table logic from RDB section.
	;    3.) Changed to use type^TBXSQL to return the proper type for the column.
	;    4.) Checked if table exists in user_table, if not set up ^TMPSQL($J,"TBL",FID)
	;              The table will be created after all schema changes are updated to DBTBL. 
	;    5.) Changed the SQL command to update NOT NULL field with default value, if the column
	;        about to modified becomes NOT NULL.
	;	   Modifed the OBSDQW section to drop a column from the table.
	;    	
	; 07/11/05 MBUIM CR 14804 
	;    Modified RDB section to change REQ="" from REQ=NULL and 
	;    SQL statement depending on the value of REQ.
	; 
	; 06/20/05 MBUIM CR 14804 
	;    Modified RDB section to set REQ="NULL" instead of REQ=""
	; 
	; 06/15/05 MBUIM CR 14804 
	;    Removed call to FILE^DBMAP in RDB section. The ^DBTBL global
	;    must be defined completely for the table before FILE^DBMAP is 
	;    called
	; 
	; 06/09/05 MBUIM CR 14804 
	;	   Modified RDB section to map the reserved names in a 
	;	   relational database and builds the DBMAP global.
	; 
	; 03/15/05 MBUIM CR 14804 
	;    Added RDB section called from LOAD section to consider 
	;    relational database and either create, add or modify column.
	;    Also added a DBAPI section that is called from RDB to 
	;    process the calls and ZRDB to trap errors.
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
CHECK(FILE,RUSER,RDATE,RTIME);	Compare date stamp between ^DBTBL and ^dbtbl 
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
LOAD(CODE,FILE,RTYPE,USER,DATE,TIME)	; Load a column (data item) 
	;----------------------------------------------------------------------- 
	; ARGUMENTS: 
	;	. CODE        Content of dataqewik element	/TYP=ARR
	;	. FILE        RMS file name			/TYP=T
	;       . RTYPE       Release type 
	;                       1: fixpack 
	;                       2: service pack 
	;		        3: mrpc
	;       . USER        Last modified user 	/TYP=T
	;       . DATE        Last modified date 	/TYP=N
	;       . TIME        Last modified time 	/TYP=N
	;        
	; RETURNS: 
	;       . $$            Success or failure 	/TYP=T
	;                       Success = 1 
	;                       Failure returns 
	; 		  "0|Wrong file type"
	;----------------------------------------------------------------------- 
	; 
	N $ZT,ER,EXIT,IDX,KEY,LEN,REQ,SEQ,SRC,SQL,TBLID,TMPSTR,TYP,X,Y 
	I $E(CODE($O(CODE(""),1)))="<" Q $$ATTIN(.CODE,FILE,RTYPE,USER,DATE,TIME)
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
EXTRACT(CODE,TBLID,KEY)	; 
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
OBSDQW(FILE);	Obsolete a data item 
	;-----------------------------------------------------------------------
	;
	N TBLID,DI,NAME,X,FID,COL
	S NAME=$P(FILE,".",1),TBLID=$P(NAME,"-",1),DI=$P(NAME,"-",2)
	;
	Q:'$D(^DBTBL("SYSDEV",1,TBLID,9,DI)) 1
	;
	I $G(db)="" S db="GTM"
	I $G(db)'="GTM" D
	.	Q:'$$rdb^UCDBRT(TBLID)
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
RDB(KEY,TBLID,TMPSTR)	; Relational DataBase Load 
	;---------------------------------------------------------------------- 
	; 
	N table,col,IsSubTyp 
	S $ZT=$$SETZT^%ZT("ZRDB^TBXCOL") 
	;
	I '$$rdb^UCDBRT(TBLID) Q 			; quit if it is belongs to a M table
	Q:$D(^TMPSQL($J,"TABLE",TBLID))
	; 
	;
	s IsSubTyp=0
	I "DEP,LN"[TBLID D
	. s table=$$getWtbl^TBXSQL(TBLID,KEY)
	. I table="ACN" s IsSubTyp=1
	E  D
	. S table=$$RESWRD^DBMAP(TBLID)
	;
	I IsSubTyp Q
	;
	I $G(table)="" d  Q
	. d logmsg^TBXDQUTL("Error : wide table is not defined",zlogf)
	;
	S col=$$RESWRD^DBMAP(KEY)
	;
	; Create table if it does not exist in the oracle DB
	S SQL=("SELECT COUNT(1) FROM USER_TABLES WHERE TABLE_NAME = '"_table_"'")
	S ER=$$SELECT^%DBAPI("",SQL,$C(9),"",.DATA,.RM)
	d:ER logmsg^TBXDQUTL("SQL Error : "_RM,zlogf)
	d:ER logmsg^TBXDQUTL(SQL,zlogf)
	Q:ER
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
ZTL	; Error trap for load 
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
ZTE	; Error trap for extract 
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
ZRDB	; Error trap for relational database element load  
	;---------------------------------------------------------------------- 
	; 
	N X
	S X=$ZSTATUS
	S ER=1
	S RM="Failed to load relational database element. "_X 
	; 
	Q 
	; 
        ;-----------------------------------------------------------------------
ATTIN(CODE,FILE,RTYPE,USER,DATE,TIME)	; Insert or update Attribute
        ;-----------------------------------------------------------------------
	;
	N ARY,MAP,COL,TAG,SEQ,TAB,DOC,INDENT,BUF,MODE,SQL
	;
	;
	D BLDPARSE(.MAP)
	D XMLTOARY^TBXTBL(.CODE,.MAP,.ARY)
	I '$D(ARY) Q 0_"|Error parsing XML document"
	;
	; SET UP VARS
	S CMP=ARY("CMP")
	S DEC=ARY("DEC")
	S DEPOSTP=ARY("DEPOSTP")
	S DEPREP=ARY("DEPREP")
	S DES=ARY("DES")
	S DFT=ARY("DFT")
	S DI=ARY("DI")
	S DOM=ARY("DOM")
	S FID=ARY("FID")
	S ISMASTER=+$G(ARY("ISMASTER"))
	S LEN=ARY("LEN")
	S MAX=ARY("MAX")
	S MDD=ARY("MDD")
	S MIN=ARY("MIN")
	S NOD=ARY("NOD")
	S NULLIND=+ARY("NULLIND")
	S POS=ARY("POS")
	S PTN=ARY("PTN")
	S REQ=ARY("REQ")
	S RHD=ARY("RHD")
	S SFD1=ARY("SFD1")
	S SFD2=ARY("SFD2")
	S SFP=ARY("SFP")
	S SFT=ARY("SFT")
	S SIZ=ARY("SIZ")
	S SRL=+ARY("SRL")
	S TBL=ARY("TBL")
	S TYP=ARY("TYP")
	S XPO=ARY("XPO")
	S XPR=ARY("XPR")
	;
	I $D(^DBTBL("SYSDEV",1,FID,9,DI)) S SQL="UPDATE DBTBL1D SET CMP=:CMP, DEC=:DEC, DEPOSTP=:DEPOSTP, DEPREP=:DEPREP, DES=:DES, DFT=:DFT, DI=:DI, DOM=:DOM, FID=:FID, ISMASTER=:ISMASTER, LEN=:LEN, MAX=:MAX, MDD=:MDD, MIN=:MIN, NOD=:NOD, NULLIND=:NULLIND, POS=:POS, PTN=:PTN, REQ=:REQ, RHD=:RHD, SFD1=:SFD1, SFD2=:SFD2, SFP=:SFP, SFT='', SIZ=:SIZ, SRL=:SRL, TBL=:TBL, TYP=:TYP, XPO=:XPO, XPR=:XPR WHERE FID=:FID AND DI=:DI"
	E  S SQL="INSERT INTO DBTBL1D (%LIBS, CMP, DEC, DEPOSTP, DEPREP, DES, DFT, DI, DOM, FID, ISMASTER, LEN, MAX, MDD, MIN, NOD, NULLIND, POS, PTN, REQ, RHD, SFD1, SFD2, SFP, SFT, SIZ, SRL, TBL, TYP, XPO, XPR) VALUES ('SYSDEV', :CMP, :DEC, :DEPOSTP, :DEPREP, :DES, :DFT, :DI, :DOM, :FID, :ISMASTER, :LEN, :MAX, :MDD, :MIN, :NOD, :NULLIND, :POS, :PTN, :REQ, :RHD, :SFD1, :SFD2, :SFP, '', :SIZ, :SRL, :TBL, :TYP, :XPO, :XPR)"
	;
	S ER=$$^SQL(SQL)
	I ER Q 0_$C(13,10)_$G(RM)_SQL
	;
	; remove SFT values.
	;S SFT=""
	;S SQL="UPDATE DBTBL1D SET SFT='' WHERE FID=:FID AND DI=:DI"
	;
	;S ER=$$^SQL(SQL)
	;I ER Q 0_$C(13,10)_$G(RM)
	;	
	; Remove table documentation. This is done regardless of mode (insert/update)
	S SQL="DELETE FROM DBTBL11D WHERE FID=:FID AND DI=:DI"
	;
	S ER=$$^SQL(SQL)
	I ER Q 0_$C(13,10)_$G(RM)
	;
	N SEQ,LINE
	F SEQ=1:1:$L(ARY("_doc_"),$C(13,10)) D  I ER Q
	.	S LINE=$P(ARY("_doc_"),$C(13,10),SEQ)
	.	S SQL="INSERT INTO DBTBL11D (%LIBS, FID, DI, SEQ, DOC) VALUES (:%LIBS, :FID, :DI, :SEQ, :LINE)"
	.	S ER=$$^SQL(SQL)
	;
	I ER Q 0_$C(13,10)_$G(RM)
	;
	; Attribute loaded successfully
	Q 1
	
	;
        ;-----------------------------------------------------------------------
ATTEXT(CODE,FID,DI)	; Extract Attribute
        ;-----------------------------------------------------------------------
	;
	N DATA,ARY,INDENT,BUF,VALS
	;
	; Tab buffer is 4 spaces
	S BUF=$J("",4)
	S INDENT=1
	;
	S CODE($O(CODE(""),-1)+1)="<?xml version=""1.0""?>"
	S CODE($O(CODE(""),-1)+1)="<Attribute>"
	N ARY,COL,TAG,SEQ,VALS
	D BLDPARSE(.ARY)
	;
	S DATA=$G(^DBTBL("SYSDEV",1,FID,9,DI))
	D SETVALS(DATA,FID,DI,.VALS)
	;
	; Load data item documentation
	I $D(^DBTBL("SYSDEV",11,FID,DI))  D
	.	N IDX S IDX=""
        .	F  S IDX=$O(^DBTBL("SYSDEV",11,FID,DI,IDX)) Q:IDX=""  D
        ..		S VALS("_doc_",IDX)=^DBTBL("SYSDEV",11,FID,DI,IDX)
        ;
	; Load computational PSL code
	I $O(^DBTBL("SYSDEV",99,FID,DI,""))'=""  D
	.	N IDX S IDX=""
        .	F  S IDX=$O(^DBTBL("SYSDEV",99,FID,DI,IDX)) Q:IDX=""  D
        ..		S VALS("_psl_",IDX)=^DBTBL("SYSDEV",99,FID,DI,IDX)
	;
	F I=1:1:$O(ARY(""),-1) D
	.	S COL=$O(ARY(I,""))
	.	S TAG=ARY(I,COL)
	.	;
	.	; Opening tag
	.	I COL="+" D  Q
	..		S CODE($O(CODE(""),-1)+1)=BUF_"<"_TAG_">"
	..		S INDENT=INDENT+1
	..		S BUF=$J("",INDENT*4)
	.		;
	.	; Closing tag
	.	I COL="-" D  Q
	..		S INDENT=INDENT-1
	..		S BUF=$J("",INDENT*4)
	..		S CODE($O(CODE(""),-1)+1)=BUF_"</"_TAG_">"
	.	;
	.	I COL="_doc_" D  Q
	..		N IDX S IDX=""
	..		I '$D(VALS("_doc_")) S CODE($O(CODE(""),-1)+1)=BUF_"<"_TAG_">"
	..		F  S IDX=$O(VALS("_doc_",IDX)) Q:IDX=""  D
	...			I IDX=1 S CODE($O(CODE(""),-1)+1)=BUF_"<"_TAG_">"_$$XMLTR^TBXTBL(VALS("_doc_",IDX)) Q
	...			S CODE($O(CODE(""),-1)+1)=$$XMLTR^TBXTBL(VALS("_doc_",IDX))
	..		S CODE($O(CODE(""),-1))=CODE($O(CODE(""),-1))_"</"_TAG_">"
	.	;
	.	I COL="_psl_" D  Q
	..		N IDX S IDX=""
	..		I $O(VALS("_psl_",IDX))="" S CODE($O(CODE(""),-1)+1)=BUF_"<"_TAG_"></"_TAG_">" Q
	..		S CODE($O(CODE(""),-1)+1)=BUF_"<"_TAG_">"
	..		S CODE($O(CODE(""),-1)+1)="<![CDATA["
	..		F  S IDX=$O(VALS("_psl_",IDX)) Q:IDX=""  D
	...			S CODE($O(CODE(""),-1)+1)=VALS("_psl_",IDX)
	..		S CODE($O(CODE(""),-1)+1)="]]>"
	..		S CODE($O(CODE(""),-1)+1)="</"_TAG_">"
	.		;
	.	S CODE($O(CODE(""),-1)+1)=BUF_"<"_TAG_">"_$$XMLTR^TBXTBL($G(VALS(COL)))_"</"_TAG_">"
	;
	S CODE($O(CODE(""),-1)+1)="</Attribute>"
	Q 1
	;
SETVALS(DATA,FID,DI,VALS)
	;
        S VALS("FID")=FID
        S VALS("DI")=DI
        S VALS("NOD")=$P(DATA,"|",1)
        S VALS("LEN")=$P(DATA,"|",2)
	S VALS("DFT")=$P(DATA,"|",3)
	S VALS("DOM")=$P(DATA,"|",4)
	S VALS("TBL")=$P(DATA,"|",5)
	S VALS("PTN")=$P(DATA,"|",6)
	S VALS("XPO")=$P(DATA,"|",7)
	S VALS("XPR")=$P(DATA,"|",8)
        S VALS("TYP")=$P(DATA,"|",9)
        S VALS("DES")=$P(DATA,"|",10)
        S VALS("ITP")=$P(DATA,"|",11)
        S VALS("MIN")=$P(DATA,"|",12)
        S VALS("MAX")=$P(DATA,"|",13)
        S VALS("DEC")=$P(DATA,"|",14)
        S VALS("REQ")=$P(DATA,"|",15)
        S VALS("CMP")=$P(DATA,"|",16)
	;			  17 is not used in DBTBL1D
	; Sub-field definition is a complex field
        S VALS("SFT")=$P($P(DATA,"|",18),"~",1)
        S VALS("SFD1")=$P($P(DATA,"|",18),"~",2)
        S VALS("SFD2")=$P($P(DATA,"|",18),"~",3)
        S VALS("SFP")=$P($P(DATA,"|",18),"~",4)
	;
        S VALS("SIZ")=$P(DATA,"|",19)
        S VALS("DEL")=$P(DATA,"|",20)
        S VALS("POS")=$P(DATA,"|",21)
        S VALS("RHD")=$P(DATA,"|",22)
        S VALS("SRL")=$P(DATA,"|",23)
        S VALS("CNV")=$P(DATA,"|",24)
        S VALS("MDD")=$P(DATA,"|",27)
        S VALS("VAL4EXT")=$P(DATA,"|",28)
        S VALS("DEPREP")=$P(DATA,"|",29)
        S VALS("DEPOSTP")=$P(DATA,"|",30)
        S VALS("NULLIND")=$P(DATA,"|",31)
        Q
        ;
        ;----------------------------------------------------------------------	
BLDPARSE(ARY)	; Build XML structure array
        ;----------------------------------------------------------------------
	;
	S ARY($O(ARY(""),-1)+1,"FID")="EntityName"
	S ARY($O(ARY(""),-1)+1,"DI")="AttributeName"
	S ARY($O(ARY(""),-1)+1,"DES")="Description"
	S ARY($O(ARY(""),-1)+1,"REQ")="Required"
	S ARY($O(ARY(""),-1)+1,"LEN")="Length"
	S ARY($O(ARY(""),-1)+1,"DEC")="DecimalPrecision"
	S ARY($O(ARY(""),-1)+1,"TYP")="DataType"
	S ARY($O(ARY(""),-1)+1,"MAX")="MaximumValue"
	S ARY($O(ARY(""),-1)+1,"MIN")="MinimumValue"
	S ARY($O(ARY(""),-1)+1,"DFT")="DefaultValue"
	S ARY($O(ARY(""),-1)+1,"CMP")="ComputedExpression"
	S ARY($O(ARY(""),-1)+1,"SRL")="IsSerialValue"
	S ARY($O(ARY(""),-1)+1,"TBL")="LookupEntity"
	S ARY($O(ARY(""),-1)+1,"NULLIND")="NullIndicator"
	S ARY($O(ARY(""),-1)+1,"MDD")="MasterAttribute"
	S ARY($O(ARY(""),-1)+1,"DOM")="Domain"
	;
	; Profile Database information
	S ARY($O(ARY(""),-1)+1,"+")="ProfileDB"
	S ARY($O(ARY(""),-1)+1,"PTN")="PatternMatch"	
	S ARY($O(ARY(""),-1)+1,"POS")="FieldPosition"
	S ARY($O(ARY(""),-1)+1,"NOD")="SubScriptLiteral"
	S ARY($O(ARY(""),-1)+1,"SFD")="SubFieldDefinition"
	S ARY($O(ARY(""),-1)+1,"SFD1")="SubFieldPrefix"
	S ARY($O(ARY(""),-1)+1,"SFD2")="SubFieldSuffix"
	S ARY($O(ARY(""),-1)+1,"SFP")="SubFieldPosition"
	S ARY($O(ARY(""),-1)+1,"SFT")="SubFieldTag"
	S ARY($O(ARY(""),-1)+1,"-")="ProfileDB"	
	;
	; Character screen information
	S ARY($O(ARY(""),-1)+1,"+")="CharacterScreen"
	S ARY($O(ARY(""),-1)+1,"XPO")="PostProcessor"
	S ARY($O(ARY(""),-1)+1,"XPR")="PreProcessor"
	S ARY($O(ARY(""),-1)+1,"DEPOSTP")="DataEntryPostProcessor"
	S ARY($O(ARY(""),-1)+1,"DEPREP")="DataEntryPreProcessor"
	S ARY($O(ARY(""),-1)+1,"SIZ")="DisplaySize"
	S ARY($O(ARY(""),-1)+1,"RHD")="ReportHeader"
	S ARY($O(ARY(""),-1)+1,"-")="CharacterScreen"	
	;
	; Column Documentation
	S ARY($O(ARY(""),-1)+1,"_doc_")="Documentation"
	;
	; PSL Code for computed operations
	S ARY($O(ARY(""),-1)+1,"_psl_")="PSLCode"
	Q
	;
testout	; Entry point for testing
	;
	N FID,DI
	S (FID,DI)=""
	;
	D DILOOP("DEP")	; one off 
	D DILOOP("ACN")	; one off
	;
	; Build all
	;F  S FID=$O(^DBTBL("SYSDEV",1,FID)) Q:FID=""  D DILOOP(FID)
	Q
DILOOP(FID)	;
	;
	N CODE
	F  S DI=$O(^DBTBL("SYSDEV",1,FID,9,DI)) Q:DI=""  D
	.	D ATTEXT(.CODE,FID,DI)
	.	N IO,SEQ
	.	S IO="/p01scmix/spool/"_FID_"-"_DI_".COL"
	.	O IO:NEWV
	.	U IO
	.	S SEQ=""
	.	F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  W !,CODE(SEQ)
	.	U 0
	.	C IO
	;
	Q
	;
testin	; Test attribute loading
	;
	D testin2("/p01scmix/spool/DEPSEG-BAL.COL")
	Q
	;
testin2(IO)	;
	;
	N REC,CODE,FILE,RTYPE,USER,DATE,TIME
	;
	O IO:READ
	U IO
	F  Q:$ZEOF  R REC S CODE($O(CODE(""),-1)+1)=REC
	U 0
	C IO
	;
	;W $$LOAD(.CODE,FILE,3,"joycejt",59347,34588)
	D gencode(.CODE)
	Q
	;	
	;-----------------------------------------------------------------------
gencode(CODE) ; SCRAP CODE TO GENERATE HARD CODED REFERENCES TO TABLE
	;-----------------------------------------------------------------------
	;
	N COL,MAP,ARY
	;
	D BLDPARSE(.MAP)
	D XMLTOARY^TBXTBL(.CODE,.MAP,.ARY)
	;
	; Splash the insert statement
	W !!,"INSERT INTO DBTBL1D ("
 	S COL=""
	F  S COL=$O(ARY(COL)) Q:COL=""  D
	.	W !,", ",COL
	W ") VALUES ("
	;
	F  S COL=$O(ARY(COL)) Q:COL=""  D
	.	W !,", :",COL
	W ")"
	;
	W !!!,"---------------------------------------"
	;
	; Splash update statement to the screen
	W !!,"UPDATE DBTBL1D SET "
 	S COL=""
	F  S COL=$O(ARY(COL)) Q:COL=""  D
	.	W !,", ",COL,"=:",COL
	;
	W !!!,"---------------------------------------"
	; Splash code to set variables to array values
	W !!,"; SET UP VARS"
	F  S COL=$O(ARY(COL)) Q:COL=""  D
	.	W !,"S ",COL,"=ARY(""",COL,""")"
	Q
	;
DUMP	;
	N IO
	S IO="/p01scmix/spool/attin.dmp"
	O IO:NEWV
	U IO
	ZSH "*"
	C IO
	U 0
	Q