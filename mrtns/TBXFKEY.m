TBXFKEY	;Private;DataQwik foreign key handler
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/08/02 16:52:41 - KWANL
	; ORIG:	KWANL - 05/08/02
	; DESC:	DataQwik foreign key handler
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
	;-----------------------------------------------------------------------
	; Revision History:
	; 02/20/2008	KWANL
	;		Fixed issue found  in OBSDQW section.
	;	
	; 01/24/2005	KWANL
	;		Change PACKTYPE to MRPC in SAVEOBJ
	;	
	; 01/04/2006	KWANL
	;		Merged Pete's changes.
	;
	; 11/17/2005	KWANL
	;		Prevent identifier name to be too long. Trauncate the name
	;		constraint to 30 characters long if constraint name constains 
	;		more than 30 characters. Added code to remove foreign key from RDB.
	;		Replaced reference to ^CUVAR with $$SCAU^%TRNLNM("DDPLOG")
	;
	; 10/20/2005	KWANL
	;		Prevent MRPC updating relational db.
	;		Modified RDB section to check if the constaints exists, if it 
	;		is use modify, if not use add.
	;
	; 09/25/2005	KWANL
	;		Modified the LOAD section to install foreign key in a relational 
	;               db.(Reuse the code in SQLUTIL) Append prefix "fk" to the foreign 
	;		key which will make it easier to delete in the future.
	;		Modified the OBSDQW section to remove foreign key in a relational
	;		db.
	;
	; 11/22/2002	Lik Kwan
	;		Modified OBSDQW section to remove keys from DBTBL and dbtbl 
	;		rather do it in TBXDQUTL.
	;
	; 10/17/2002	Lik Kwan
	;		Fixed CHECKOBJ and EXTRACT section to convert keys from "_"
	;		to ",".
	;
	; 10/115/2002	Lik kwan
	;		Fixed problem when obsoleting Foreign keys.
	;
	; 10/03/2002	Lik Kwan
	;		Convert , to _ in filename when extract from a host
	;
	;-----------------------------------------------------------------------
GETCODE(OBJECTID,CODE,FILENAME)	; Get object contents
	;-----------------------------------------------------------------------
	;
	N FKEYID,KEY
	;
	I $G(OBJECTID)="" Q 0_$C(13,10)_$$^MSG(741)
	;
	S FKEYID=$P(OBJECTID,"-",1),KEY=$P(OBJECTID,"-",2)
	I KEY["," S FILENAME=FKEYID_"-"_$TR(KEY,",","_")_".FKY"
	E  S FILENAME=FKEYID_"-"_KEY_".FKY"
	Q $$EXTRACT(.CODE,FKEYID,KEY)
	;
	;-----------------------------------------------------------------------
CHECKOBJ(TOK,OBJECTID)	; Return a message for update or create prompt
	;-----------------------------------------------------------------------
	;
	N HEADER,USER,DATE,TIME,END,CONAME,MESSAGE,FKEYID,KEY
	;
	; S CONAME=$$^CUVAR("CONAM")
	S CONAME=$$SCAU^%TRNLNM("DDPLOG")
	;
	S END=$O(^TMP(TOK,""),-1)
	I END="" Q 0_$C(13,10)_"Missing source code"
	;
	S FKEYID=$P(OBJECTID,"-",1),KEY=$P(OBJECTID,"-",2)
	;
	S KEY=$$GETKEY(KEY)
	;
	I '$D(^DBTBL(%LIBS,19,FKEYID,KEY)) D  Q MESSAGE
	.	S MESSAGE=1_$C(13,10)_"Create new Foreign key Definition in "_CONAME
	;
	S MESSAGE="Update Foreign key Definition: "_FKEYID_"-"_KEY
	S MESSAGE=MESSAGE_" in "_CONAME
	;
	Q 1_$C(13,10)_MESSAGE
	;
	;-----------------------------------------------------------------------
SAVEOBJ(TOK,OBJECTID,USER)	; Save Foreign Key Def sent by client
	;-----------------------------------------------------------------------
	;
	N SEQ,CODE,FKEYID,KEY,FILENAME
	S SEQ=""
	;
	; Load from buffer into CODE array
	F  S SEQ=$O(^TMP(TOK,SEQ)) Q:SEQ=""  S CODE(SEQ)=^TMP(TOK,SEQ)
	;
	; Delete buffer
	K ^TMP(TOK)
	;
	S FKEYID=$P(OBJECTID,"-",1),KEY=$P(OBJECTID,"-",2)
	S FILENAME=FKEYID_"-"_KEY_".FKY"
	Q $$LOAD(.CODE,FILENAME,3,USER,+$H,$P($H,",",2))
	;
        ;-----------------------------------------------------------------------
CHECK(FILE,USER,DATE,TIME); Compare date stamp between ^DBTBL and ^dbtbl
        ;-----------------------------------------------------------------------
        ; ARGUMENTS:
        ;       . FILE          RMS file name           /TYP=T
        ; RETURNS:
        ;       . $$            Match or Failure        /TYP=T
        ;                       Match = 1
        ;                       Failure returns
        ;                         "0|Date Stamp Mistmatch"
	; NOTE: No date stamp check for foreign key definition
        ;-----------------------------------------------------------------------
        ;
        Q 1
        ;
        ;-----------------------------------------------------------------------
LOAD(CODE,FILE,RTYPE,USER,DATE,TIME) ; Load a filer executive definition
        ;-----------------------------------------------------------------------
        ; ARGUMENTS:
	;	. CODE        Content of dataqewik element
	;	. FILE        RMS file name           /TYP=T
        ;       . RTYPE       Release type
        ;                     1: fixpack
        ;                     2: service pack
	;		      3: mrpc
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
        N FKEYID,KEY,EXT,TMPSTR,SEQ,$ZT,SRC,X,SEQ1
	S $ZT=$$SETZT^%ZT("ZTL^TBXFKEY")
        ;
        S FKEYID=$P(FILE,"-",1),KEY=$P($P(FILE,".",1),"-",2,999),EXT=$P(FILE,".",2)
	;
	; Column names may be seperated by a comma. This is
	; translated to an underscore so that it can be used in the file
	; name. Translate it back to an underscore before loading it.
	S KEY=$$GETKEY(KEY)
	;
	; remove ^DBTBL
        K ^DBTBL("SYSDEV",19,FKEYID,KEY)
	;
	S SEQ1="",SEQ1=$O(CODE(SEQ1),-1)
	; update ^DBTBL
	S TMPSTR=""
	S SEQ="" F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  D
	. I (SEQ=SEQ1)&(CODE(SEQ)="") Q
	. S $P(TMPSTR,"|",SEQ)=$P(CODE(SEQ),"=",2)
	S ^DBTBL("SYSDEV",19,FKEYID,KEY)=TMPSTR
	;
	; if service pack update ^dbtbl
	I RTYPE=2 D						; if service pack update ^dbtbl
	. K ^dbtbl("SYSDEV",19,FKEYID,KEY)
	. S SRC="^DBTBL(""SYSDEV"",19,"""_FKEYID_""","""_KEY_""")"
	. S X=$$CP^TBXDQUTL(SRC,"^dbtbl")
	;
	I (RTYPE=1)!(RTYPE=2) D
	. S ^TMPDQC($J,"SYSDEV",19,FKEYID_"."_KEY)=""
	;
	I RTYPE=3 Q 1
	I $G(db)'="GTM" D 
	.	D RDB(FKEYID,KEY)
	Q:$G(ER) "0|Foreign key "_FKEYID_"."_KEY_" failed to load: "_$G(RM)
	Q 1        
	;-----------------------------------------------------------------------
EXTRACT(CODE,FKEYID,KEY); Extract a foreign key definition into an array
        ;-----------------------------------------------------------------------
        ;
        N DATA,$ZT,KEY1
	S $ZT=$$SETZT^%ZT("ZTE^TBXFKEY")
        ;
	S KEY1=$$GETKEY(KEY)
	;
        I '$D(^DBTBL("SYSDEV",19,FKEYID,KEY1)) Q "0|Foreign key definition "_FKEYID_"."_KEY1_" does not exist"
	;
	S DATA=(^DBTBL("SYSDEV",19,FKEYID,KEY1))
	S CODE(1)="RCTOMIN="_$P(DATA,"|",1)
	S CODE(2)="RCTOMAX="_$P(DATA,"|",2)
	S CODE(3)="DEL="_$P(DATA,"|",3)
	S CODE(4)="UPD="_$P(DATA,"|",4)
	S CODE(5)="TBLREF="_$P(DATA,"|",5)
	S CODE(6)="RCFRMIN="_$P(DATA,"|",6)
	S CODE(7)="RCFRMAX="_$P(DATA,"|",7)
	S CODE(8)="PKEYS="_$P(DATA,"|",8)
        Q 1
	;-----------------------------------------------------------------------
OBSDQW(FILE); Obsolete a foreign key definition.
	;-----------------------------------------------------------------------
	;
	N $ZT,NAME,FKEYID,KEY,SQL
	;
	S NAME=$P(FILE,".",1)
	S FKEYID=$P(NAME,"-",1),KEY=$P(NAME,"-",2)
	;
	; Column names may be seperated by a comma. This is
	; translated to an underscore so that it can be used in the file
	; name. Translate it back to an underscore before loading it.
	S KEY=$$GETKEY(KEY)
	;
	Q:'$D(^DBTBL("SYSDEV",19,FKEYID,KEY)) 1
	;
	I $G(db)'="GTM" D
	.	d REMFKY(FKEYID,KEY)
        ;
	K ^DBTBL("SYSDEV",19,FKEYID,KEY)
	K ^dbtbl("SYSDEV",19,FKEYID,KEY)
       	S ^TMPDQC($J,"SYSDEV",19,FKEYID_"."_KEY)=""
       	;
        Q 1
	;
	;-----------------------------------------------------------------------
GETKEY(KEY)	; Translate file name into Colunm key references
	;-----------------------------------------------------------------------
	;
	I $E(KEY)="_" S KEY="%"_$E(KEY,2,999)
	Q $TR(KEY,"_",",")
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
REMFKY(PROFTBL,PROFFKEY)	; Remove foreign key from RDB
	;-----------------------------------------------------------------------
	;
	n akey,fkyname,$ZT,tbl
	;
	S $ZT=$$SETZT^%ZT("ZRDB^TBXSQL")
	;
	I '$$rdb^UCDBRT(PROFTBL) Q
	;
	; if the foreign key is alreay setup in RDB, it can assume that 
	; the keys are only referencing to one table. therefor use the   
	; combination of first key and table name should give us the correct
	; table name.
	s tbl=PROFTBL
	S akey=$P(PROFFKEY,",",1)
	d MAP^DBMAP(db,.tbl,.akey)
	;;d MAP^DBMAP(db,.tbl)
	;
	s fkyname="FKY_"_PROFTBL_"_"_$$TRKEY^TBXFKEY(PROFFKEY)
	;
	; prevent identifier to be too long.
	i $L(fkyname)>30 d
	. s fkyname=$E(fkyname,1,30)	
	;
	S SQL=("SELECT COUNT(1) FROM USER_CONSTRAINTS WHERE CONSTRAINT_NAME = '"_fkyname_"'")
	S ER=$$SELECT^%DBAPI("",SQL,$C(9),"",.DATA,.RM)
	;
	I DATA'=1 d logmsg^TBXDQUTL("Warning: "_fkyname_" constraint does not exist in the database.",zlogf) Q
	;
       	S SQL=("ALTER TABLE "_tbl_" drop CONSTRAINT "_fkyname)
       	;
       	D DBAPI^TBXSQL(SQL)
       	d:(ER<0) logmsg^TBXDQUTL("SQL ERROR : "_RM,zlogf)
	Q
        ;----------------------------------------------------------------------
RDB(tbl,key); Output foreign key info
	;----------------------------------------------------------------------
	;
	;
	I '$$rdb^UCDBRT(tbl) Q
	S ^TMPSQL($J,"FOREIGN_KEY",tbl,key)=""
	;
	Q
	;
	;
TRKEY(KEY)	;
	;
	Q $TR(KEY,",","_")		
