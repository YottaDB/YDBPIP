TBXIDX	;Private;DataQwik index file handler
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/08/02 16:52:41 - KWANL
	; ORIG:	KWANL - 05/08/02
	; DESC:	DataQwik index file handler
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
	;-----------------------------------------------------------------------
	; Revision History:
	; 10/10/2007	KWANL
	;		Added missing KEY in CHECKOBJ section
	;
	; 01/24/2005	KWANL
	;		Change PACKTYPE to MRPC in SAVEOBJ
	;	
	; 11/17/2005	KWANL
	;		Prevent identifier name to be too long. Truncate constraint 
	;		name to 30 characters long if constraint name contains more than
	;		30 characters long. Added code to remove index from RDB.
	;		Replaced reference to ^CUVAR with $$SCAU^%TRNLNM("DDPLOG")
	;
	; 10/20/2005	KWANL
	;		Prevent mrpc to update relational db in LOAD section.
	;		Modified the RDB section to check the index to install if it
	;		is already exists in the database, if it is drop it first.
	;
	; 09/27/2005	KWANL
	;		Modified the LOAD section to install index to a relational db.
	;		Modified the OBSDQW section to remove index from a relational db.
	;
	; 05/05/2005	Lik Kwan
	;		Removed the top node if there is no other child node under
	;		it after the oboslete.
	;
	;
	;-----------------------------------------------------------------------
GETCODE(OBJECTID,CODE,FILENAME)	; Get object contents
	;-----------------------------------------------------------------------
	;
	N IDXID,KEY
	;
	I $G(OBJECTID)="" Q 0_$C(13,10)_$$^MSG(741)
	;
	S IDXID=$P(OBJECTID,"-",1),KEY=$P(OBJECTID,"-",2)
	S FILENAME=IDXID_"-"_KEY_".IDX"
	Q $$EXTRACT(.CODE,IDXID,KEY)
	;
	;-----------------------------------------------------------------------
CHECKOBJ(TOK,OBJECTID)	; Return a message for update or create prompt
	;-----------------------------------------------------------------------
	;
	N HEADER,USER,DATE,TIME,END,CONAME,MESSAGE,IDXID,KEY
	;
	; S CONAME=$$^CUVAR("CONAM")
	S CONAME=$$SCAU^%TRNLNM("DDPLOG")
	;
	S END=$O(^TMP(TOK,""),-1)
	I END="" Q 0_$C(13,10)_"Missing source code"
	;
	S IDXID=$P(OBJECTID,"-",1),KEY=$P(OBJECTID,"-",2)
	I '$D(^DBTBL(%LIBS,8,IDXID,KEY)) D  Q MESSAGE
	.	S MESSAGE=1_$C(13,10)_"Create new Index Definition in "_CONAME
	;
	; Index Definition exists, return user and date modified
	S HEADER=^DBTBL(%LIBS,8,IDXID,KEY)
	S USER=$P(HEADER,"|",13)
	S DATE=$$^%ZD($P(HEADER,"|",12))
	S TIME=$$TIME^%ZD($P(HEADER,"|",17))
	;
	S MESSAGE="Update Index Definition: "_OBJECTID_" Modified by "_USER
	S MESSAGE=MESSAGE_" on "_DATE_" at "_TIME_" in "_CONAME
	;
	Q 1_$C(13,10)_MESSAGE
	;
	;-----------------------------------------------------------------------
SAVEOBJ(TOK,OBJECTID,USER)	; Save Batch Def sent by client
	;-----------------------------------------------------------------------
	;
	N SEQ,CODE,FILENAME,IDXID,KEY
	;
	; Load from buffer into CODE array
	S SEQ="" F  S SEQ=$O(^TMP(TOK,SEQ)) Q:SEQ=""  S CODE(SEQ)=^TMP(TOK,SEQ)
	;
	; Delete buffer
	K ^TMP(TOK)
	;
	S IDXID=$P(OBJECTID,"-",1),KEY=$P($P(OBJECTID,".",1),"-",2)
	S FILENAME=IDXID_"-"_KEY_".IDX"
	Q $$LOAD(.CODE,FILENAME,3,USER,+$H,$P($H,",",2))
	;
        ;-----------------------------------------------------------------------
CHECK(FILE,RDATE,RTIME,RUSER); Compare date stamp between ^DBTBL and ^dbtbl
        ;-----------------------------------------------------------------------
        ; ARGUMENTS:
        ;       . FILE          RMS file name           /TYP=T
        ; RETURNS:
        ;       . $$            Match or Failure        /TYP=T
        ;                       Match = 1
        ;                       Failure returns
        ;                         "0|Date Stamp Mistmatch"
	; 
        ;-----------------------------------------------------------------------
        ;
	N IDXID,KEY,CDATE,CUSER,DDATE,DUSER
	;
	S IDXID=$P(FILE,"-",1),KEY=$P($P(FILE,".",1),"-",2)
        S CDATE=$P($G(^DBTBL("SYSDEV",8,IDXID,KEY)),%,12)               ; ^DBTBL^
	S CUSER=$P($G(^DBTBL("SYSDEV",8,IDXID,KEY)),%,13) 
        S DDATE=$P($G(^dbtbl("SYSDEV",8,IDXID,KEY)),%,12)               ; ^dbtbl^
        S DUSER=$P($G(^dbtbl("SYSDEV",8,IDXID,KEY)),%,13)
        ;
        Q $$CKDTUSR^TBXDQUTL(DDATE,DUSER,CDATE,CUSER,RDATE,RUSER)
        ;
        ;-----------------------------------------------------------------------
LOAD(CODE,FILE,RTYPE,USER,DATE,TIME) ; Load a filer executive definition
        ;-----------------------------------------------------------------------
        ; ARGUMENTS:
	;	. CODE        Content of dataqewik element
	;	. FILE        RMS file name           /TYP=T
        ;       . RTYPE       Release type
        ;                       1: fixpack
        ;                       2: service pack
	;      		        3: mrpc
        ;       . USER        Last modified user     /TYP=T
        ;       . DATE        Last modified date     /TYP=N
        ;       . TIME        Last modified time     /TYP=N
        ;       
        ; RETURNS:
        ;       . $$            Success or failure      /TYP=T
        ;                       Success = 1
        ;                       Failure returns
        ;                         "0|Unable to open DEVICE"
        ;			  "0|Wrong file type"
        ;-----------------------------------------------------------------------
        ;
        N IDXID,KEY,TMPSTR,SEQ,$ZT,SRC,X,SEQ1
	S $ZT=$$SETZT^%ZT("ZTL^TBXIDX")
        ;
        S IDXID=$P(FILE,"-",1),KEY=$P($P(FILE,".",1),"-",2)
        ;
        K ^DBTBL("SYSDEV",8,IDXID,KEY)
        ;
	S SEQ1="",SEQ1=$O(CODE(SEQ1),-1)
	; update ^DBTBL
	S SEQ="" F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  D
	. I SEQ=1 S ^DBTBL("SYSDEV",8,IDXID)=CODE(1) Q
	. I (SEQ=SEQ1)&(CODE(SEQ)="") Q
	. E  S $P(TMPSTR,"|",SEQ-1)=$P(CODE(SEQ),"=",2,9999)
	;
	; update file last modified date-time stamp and user 
	S $P(TMPSTR,"|",13)=USER,$P(TMPSTR,"|",12)=DATE,$P(TMPSTR,"|",16)=TIME	
	S ^DBTBL("SYSDEV",8,IDXID,KEY)=TMPSTR
	;
	; if Serivce Pack update ^dbtbl
	I RTYPE=2 D								
	. K ^dbtbl("SYSDEV",8,IDXID,KEY)
	. S SRC="^DBTBL(""SYSDEV"",8,"""_IDXID_""","""_KEY_""")"
	. S X=$$CP^TBXDQUTL(SRC,"^dbtbl")
	. ;
	. ; 09/27/2005. Check index type
	I RTYPE=3 Q 1
	;
	S ^TMPDQC($J,"SYSDEV",8,IDXID_"."_KEY)=""
	;
	I $G(db)'="GTM" D 
	.	d RDB(IDXID,KEY)
	Q:$G(ER) "0|index"_IDXID_"."_KEY_" failed to load: "_$G(RM)	
	Q 1        
	;-----------------------------------------------------------------------
EXTRACT(CODE,INDXID,KEY); Extract DQ contents into an array
        ;-----------------------------------------------------------------------
        ;
        N DATA,$ZT
	S $ZT=$$SETZT^%ZT("ZTE^TBXIDX")
        ;
        I '$D(^DBTBL("SYSDEV",8,INDXID,KEY)) Q "0|Index file definition "_INDXID_"."_KEY_" does not exist"
	S DATA=(^DBTBL("SYSDEV",8,INDXID,KEY))
	S CODE(1)=$G(^DBTBL("SYSDEV",8,INDXID))
	S CODE(2)="NULLFLG="_$P(DATA,"|",1)
	S CODE(3)="GLOBAL="_$P(DATA,"|",2)
	S CODE(4)="ORDERBY="_$P(DATA,"|",3)
	S CODE(5)=""
	S CODE(6)="IDXDESC="_$P(DATA,"|",5)
	S CODE(7)=""
	S CODE(8)="QRY1="_$P(DATA,"|",7)
	S CODE(9)="QRY2="_$P(DATA,"|",8)
	S CODE(10)=""
	S CODE(11)=""
	S CODE(12)="SAVFLG="_$P(DATA,"|",11)
	S CODE(13)="LTD="
	S CODE(14)="USER="
	S CODE(15)="UPCASE="_$P(DATA,"|",14) 
	S CODE(16)="PARFID="_$P(DATA,"|",15)
	S CODE(17)="TIME="
        ;
        Q 1
	;-----------------------------------------------------------------------
OBSDQW(FILE); Obsolete a index file definition.
	;-----------------------------------------------------------------------
	;
	;
	N NAME,IDXID,KEY
	;
	S NAME=$P(FILE,".",1)
	S IDXID=$P(NAME,"-",1),KEY=$P(NAME,"-",2)
	;
	I '$D(^DBTBL("SYSDEV",8,IDXID,KEY)) Q 1
	;
	; Create/Add/Modify table in oracle database
	I $G(db)'="GTM" D
	.	d REMIDX(IDXID,KEY)
	;
	K ^DBTBL("SYSDEV",8,IDXID,KEY)
	K ^dbtbl("SYSDEV",8,IDXID,KEY)
	K:$D(^DBTBL("SYSDEV",8,IDXID))=1 ^DBTBL("SYSDEV",8,IDXID)
	S ^TMPDQC($J,"SYSDEV",8,IDXID)=""
        ;
	;
        Q 1
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
	S RM="Failed to extract element. "_X
	;
	Q 0_"|"_RM
	;
	;-----------------------------------------------------------------------
REMIDX(tbl,idx)	; Remove index from RDB
	; 
	;-----------------------------------------------------------------------
        ; 09/23/2005 LK. use SQL to delete foriegn key
	N indexnm,key,temptab,sqlstr
	;
	I '$$rdb^UCDBRT(tbl) Q
	; 	
	S key=$$getidxky^TBXSQL(tbl,idx)
	I key="" D logmsg^TBXDQUTL("Invalid index definition "_tbl_" ("_idx_")",zlogf) Q
	;
	S ER=$$vindex^TBXSQL(key,tbl,idx,.indexnm,.indtbl)
	I ER d logmsg^TBXDQUTL(RM,zlogf) Q
	;
	s indexnm="IDX_"_indexnm
	; prevent indentifier to be too long
	i $L(indexnm)>30 d
	. s indexnm=$E(indexnm,1,30)
	;
	S SQL=("SELECT COUNT(1) FROM USER_INDEXES WHERE INDEX_NAME = '"_indexnm_"'")
	S ER=$$SELECT^%DBAPI("",SQL,$C(9),"",.DATA,.RM)
	;
	; if index doesn't exist quit.
	I DATA'=1 d logmsg^TBXDQUTL("Error: "_indexnm_" does not exists in the database.",zlogf) Q
	;
	s sqlstr="DROP INDEX "_indexnm
	d DBAPI^TBXSQL(sqlstr)
	d:(ER<0) logmsg^TBXDQUTL("SQL ERROR: "_RM,zlogf),logmsg^TBXDQUTL(sqlstr,zlogf)    	
       	Q
 	;	
	;
	;------------------------------------ ----------------------------------
RDB(proftbl,index)	; Index definition
	;----------------------------------------------------------------------
	; DROP INDEX index_name
	; CREATE INDEX index_name ON Table (index_key1,index_key2)
	; The majority of the code is copied from the SQLUTIL.m
	;----------------------------------------------------------------------
	N indexnm,key,temptab,sqlstr
	;
	I '$$rdb^UCDBRT(proftbl) Q
	;
	s ^TMPSQL($J,"INDEX",proftbl,index)=""
	Q