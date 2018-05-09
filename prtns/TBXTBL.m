TBXTBL	;Private;Dataqwik table handler
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/07/02 09:39:47 - KWANL
	; ORIG:	KWANL - 05/07/02
	; DESC:	Dataqwik table handler
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
	; Revision History
	; 02/14/07 KWANL
	;  	Added code to check table type before setting up ^TMPSQL 
	; 	global in OBSDQW section.	
	; 
	; 01/24/2005	KWANL
	;		Change PACKTYPE to MRPC in SAVEOBJ
	;
	; 11/17/2005	KWANL
	;		Replaced reference to ^CUVAR with $$SCAU^%TRNLNM("DDPLOG")
	;	
	; 10/19/2005	KWANL
	;		Modified the OBSDQW section to create an entry in 
	;		^TMPSQL global for obsoleted table.
	;		 
	;-----------------------------------------------------------------------
GETCODE(TBLID,CODE,FILENAME)	; Get object contents
	;-----------------------------------------------------------------------
	;
	I $G(TBLID)="" Q 0_$C(13,10)_$$^MSG(741)
	;
	S FILENAME=TBLID_".TBL"
	Q $$EXTRACT(.CODE,TBLID)
	;
	;-----------------------------------------------------------------------
CHECKOBJ(TOK,OBJECTID)	; Return a message for update or create prompt
	;-----------------------------------------------------------------------
	;
	N HEADER,USER,DATE,TIME,END,CONAME,MESSAGE
	;
	; S CONAME=$$^CUVAR("CONAM")
	S CONAME=$$SCAU^%TRNLNM("DDPLOG")
	;
	S END=$O(^TMP(TOK,""),-1)
	I END="" Q 0_$C(13,10)_"Missing source code"
	;
	I '$D(^DBTBL(%LIBS,1,OBJECTID)) D  Q MESSAGE
	.	S MESSAGE=1_$C(13,10)_"Create new Table Definition in "_CONAME
	;
	; Table Definition exists, return user and date modified
	S HEADER=^DBTBL(%LIBS,1,OBJECTID,10)
	S USER=$P(HEADER,"|",11)
	S DATE=$$^%ZD($P(HEADER,"|",10))
	;
	S MESSAGE="Update Table Definition: "_OBJECTID_" Modified by "_USER
	S MESSAGE=MESSAGE_" on "_DATE_" in "_CONAME
	;
	Q 1_$C(13,10)_MESSAGE
	;
	;-----------------------------------------------------------------------
SAVEOBJ(TOK,TBLID,USER)	; Save Table Def sent by client
	;-----------------------------------------------------------------------
	;
	N SEQ,CODE
	;
	; Load from buffer into CODE array
	S SEQ="" F  S SEQ=$O(^TMP(TOK,SEQ)) Q:SEQ=""  S CODE(SEQ)=^TMP(TOK,SEQ)
	;
	; Delete buffer
	K ^TMP(TOK)
	;
	S FILENAME=TBLID_".TBL"
	Q $$LOAD(.CODE,FILENAME,3,USER,+$H,$P($H,",",2))
	;
	;-----------------------------------------------------------------------
CHECK(FILE,RUSER,RDATE,RTIME);	Compare date stamp between ^DBTBL and ^dbtbl 
	;-----------------------------------------------------------------------
	; ARGUMENTS: 
	;       . FILE          RMS file name           /TYP=T 
	; RETURNS: 
	;       . $$            Match or Mismatch    /TYP=T 
	;                       Match = 1 
	;                       Mismatch 
	;                         "0|Date Stamp mismatch" 
	;      
	;----------------------------------------------------------------------- 
	; 
	N TBLID,EXT,CDATE,CUSER,DDATE,DUSER 
	S TBLID=$P(FILE,".",1),EXT=$P(FILE,".",2) 
	;
	S CDATE=$P($G(^DBTBL("SYSDEV",1,TBLID,10)),%,10)               ; ^DBTBL date stamp 
	S CUSER=$P($G(^DBTBL("SYSDEV",1,TBLID,10)),%,11)
	S DDATE=$P($G(^dbtbl("SYSDEV",1,TBLID,10)),%,10)               ; ^dbtbl date stamp 
	S DUSER=$P($G(^dbtbl("SYSDEV",1,TBLID,10)),%,11) 
	; 
	Q $$CKDTUSR^TBXDQUTL(DDATE,DUSER,CDATE,CUSER,RDATE,RUSER) 
	;
	;-----------------------------------------------------------------------
LOAD(CODE,FILE,RTYPE,USER,DATE,TIME);	Load a table header 
	;-----------------------------------------------------------------------
	; ARGUMENTS: 
	;       . CODE        Content of the file 
	;   . FILE	      DQ file name
	; 	. RTYPE	      Load type
	;		        1: Fixpack
	;                       2: Servicepack
	;                       3: MRPC	
	;       . USER        Last modified user 
	;       . DATE        Last modified date 
	;       . TIME        Last modified time  
	; 
	; RETURNS: 
	;       . $$            Success or failure      /TYP=T 
	;                       Success = 1 
	;                       Failure returns         
	;                         "0|Wrong file type"
	;----------------------------------------------------------------------- 
	;Detect XML format
	I $E(CODE($O(CODE(""),1)))="<" Q $$ENTIN(.CODE,FILE,RTYPE,USER,DATE,TIME)
	;
	N KEY,LINE,EXT,TMPSTR,SEQ,$ZT,X,SEQ1,SRC,TBLID 
	; 
	S $ZT=$$SETZT^%ZT("ZTL^TBXTBL")
	S TBLID=$P(FILE,".",1) 
	; 
	; first save data item then remove table header
	D RMTBLHDR("^DBTBL",TBLID)
	; 
	S SEQ1="",SEQ1=$O(CODE(SEQ1),-1)
	; update ^DBTBL and insert last modified info into the header
	S SEQ="" F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  D 
	.	I CODE(SEQ)[("^DBTBL(""SYSDEV"",1,"""_TBLID_""",10)") D
	..		S $P(CODE(SEQ),"|",10)=DATE
	..		I $L(CODE(SEQ),"|")'>11 S $P(CODE(SEQ),"|",11)=USER_$C(34)
	..		I $L(CODE(SEQ),"|")>11 S $P(CODE(SEQ),"|",11)=USER
	.	I CODE(SEQ)[$C(9) S @$P(CODE(SEQ),"=",1)=$P(CODE(SEQ),"=",2,99) Q	; catch tab on table description
	.	I (SEQ=SEQ1)&(CODE(SEQ)="") Q
	.	E  S @CODE(SEQ)
	S X=1
	;
	; if service pack, update ^dbtbl
	I RTYPE=2 D
	.	D RMTBLHDR("^dbtbl",TBLID)
	.	S SRC="^DBTBL(""SYSDEV"",1,"""_TBLID_""")"
	.	S X=$$CP^TBXDQUTL(SRC,"^dbtbl")
	; for table header, we do not setup ^TMPDQC
	Q:X=0 "0|Failed to update file definition "_TBLID_" in ^dbtbl"
	Q 1 
	;
	;-----------------------------------------------------------------------
EXTRACT(CODE,TBLID);	Extract a table header 
	;-----------------------------------------------------------------------
	; ARGUMENTS: 
	;	. CODE	      Array contains the contents of the file 
	;	. TBLID	      	
	; RETURNS: 
	;       . $$            Success or failure      /TYP=T 
	;                       Success = 1 
	;                       Failure returns 
	;                         "0|Table definition "_TBLID_" does not exist" 
	;			  "0|"_$ZS
	;----------------------------------------------------------------------- 
	;
	N KEY,$ZT,DI,TMPSTR,SRC,REF
	S $ZT=$$SETZT^%ZT("ZTE^TBXTBL")
	Q:'$D(^DBTBL("SYSDEV",1,TBLID)) "0|Table does not exists"
	S KEY="" 
	I ($D(^DBTBL("SYSDEV",1,TBLID)))#10 S CODE($O(CODE(""),-1)+1)="^DBTBL(""SYSDEV"",1,"""_TBLID_""")="_$$QADD^%ZS(^DBTBL("SYSDEV",1,TBLID)) 
	F  S KEY=$O(^DBTBL("SYSDEV",1,TBLID,KEY)) Q:KEY=""  D 
	.	; remove last modified info from the table header
	. I KEY=10 D  Q 
	..		S TMPSTR=^DBTBL("SYSDEV",1,TBLID,10)
	.. 	S $P(TMPSTR,"|",10)=""
	.. 	S $P(TMPSTR,"|",11)=""
	.. 	S CODE($O(CODE(""),-1)+1)="^DBTBL(""SYSDEV"",1,"""_TBLID_""","_KEY_")="_$$QADD^%ZS(TMPSTR)
	.	; if data item contains *, $, quotes, keep it in the table definition
	. I KEY=9 S DI="" D  Q							
	.. 	F  S DI=$O(^DBTBL("SYSDEV",1,TBLID,KEY,DI)) Q:DI=""  D
	... 		I (DI["*")!(DI["$")!(DI["""") D
	....				S TMPSTR=^DBTBL("SYSDEV",1,TBLID,KEY,DI)
	....				S $P(TMPSTR,"|",25)=""
	.... 			I $P(TMPSTR,"|",26)[$C(34) S $P(TMPSTR,"|",26)=""_$C(34)
	.... 			E  S $P(TMPSTR,"|",26)=""
	....				I (DI["""") S CODE($O(CODE(""),-1)+1)="^DBTBL(""SYSDEV"",1,"""_TBLID_""",9,"""""_DI_""""")="_$$QADD^%ZS(TMPSTR)
	....				E  S CODE($O(CODE(""),-1)+1)="^DBTBL(""SYSDEV"",1,"""_TBLID_""",9,"""_DI_""")="_$$QADD^%ZS(TMPSTR)
	. E  D
	.. 	S SRC="^DBTBL(""SYSDEV"",1,"""_TBLID_""","_KEY_")"
	.. 	S REF=$S(SRC["(":$E(SRC,1,$L(SRC)-1),1:SRC)
	.. 	I $D(@SRC)#10 D
	...			I @SRC?.E1C.E S CODE($O(CODE(""),-1)+1)="^DBTBL"_$E(SRC,7,$L(SRC))_"="_$$FIXCCHR^TBXDQUTL(@SRC) Q
	... 		E  S CODE($O(CODE(""),-1)+1)="^DBTBL"_$E(SRC,7,$L(SRC))_"="_$$QADD^%ZS(@SRC)
	.. 	F  S SRC=$q(@SRC) q:(SRC="")!($E(SRC,1,$l(REF))'=REF)  D
	...			I @SRC?.E1C.E S CODE($O(CODE(""),-1)+1)="^DBTBL"_$E(SRC,7,$L(SRC))_"="_$$FIXCCHR^TBXDQUTL(@SRC) Q
	... 		S CODE($O(CODE(""),-1)+1)="^DBTBL"_$E(SRC,7,$L(SRC))_"="_$$QADD^%ZS(@SRC)
	Q 1 
	;-----------------------------------------------------------------------
RMTBLHDR(GLOBAL,TBL);	Remove table header. 
	; 
	;-----------------------------------------------------------------------
	; ARGUMENTS: 
	;	. GLOBAL	Global reference: ^DBTBL or ^dbtbl 
	;	. TBL      	Table name
	;-----------------------------------------------------------------------
	;
	N KEY,DI,SRC
	K ^dbtbl1
	S (KEY,DI)=""
	F  S DI=$O(@GLOBAL@("SYSDEV",1,TBL,9,DI)) Q:DI=""  D
	.	I '((DI["*")!(DI["""")!(DI["$")) D
	..		S ^dbtbl1("SYSDEV",1,TBL,9,DI)=@GLOBAL@("SYSDEV",1,TBL,9,DI)	; save data item into ^dbtbl1
	K @GLOBAL@("SYSDEV",1,TBL)
	S SRC="^dbtbl1(""SYSDEV"",1,"""_TBL_""")"
	S X=$$CP^TBXDQUTL(SRC,GLOBAL)
	K ^dbtbl1
	Q
	;-----------------------------------------------------------------------
OBSDQW(FILE);	Obsolete a table definition 
	;-----------------------------------------------------------------------
	; ARGUMENTS:
	;	. FILE		Table definition to be obsoleted	/TYP=T 
	; RETURN:
	;       . $$            Success or failure      /TYP=T 
	;                       Success = 1 
	;                       Failure returns 
	;                         "0|"_$ZS 
	;----------------------------------------------------------------------- 
	;
	N TBLID
	;
	S TBLID=$P(FILE,".",1)
	S ^TMPDQC($J,"SYSDEV",1,TBLID)=-1
	; 
	I $G(db)="" S db="GTM" 
	I $G(db)'="GTM" D 
	. Q:'$$rdb^UCDBRT(TBLID)
	. s ^TMPSQL($J,"obsolete",TBLID)=1
	Q 1 
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
	S RM="Failed to extract element. "_X
	;
	Q 0_"|"_RM
	;
	;
XMLEXTR(DOC,ENTITY)
	;
        ; ARGUMENTS:
	;	. DOC		Array contains the contents of the XML document
	;	. ENTITY	Entity name (table name)
	;
        ; RETURNS:
        ;       . $$            Success or failure      /TYP=T
        ;                       Success = 1
        ;                       Failure returns
        ;                         "0|Entity "_ENTITY_" does not exist"
	;			  "0|"_$ZS
        ;-----------------------------------------------------------------------
	;
	Q
	;
        ;-----------------------------------------------------------------------
ENTIN(CODE,FILE,RTYPE,USER,DATE,TIME)	; Insert or update entity
        ;-----------------------------------------------------------------------
	;
	N ARY,MAP,COL,TAG,SEQ,TAB,DOC,INDENT,BUF,MODE,SQL
	;
	;
	D BLDPARSE(.MAP)
	D XMLTOARY(.CODE,.MAP,.ARY)
	I '$D(ARY) Q 0_"|Error parsing XML document"
	;
	; SET UP VARS
	S ACCKEYS=ARY("ACCKEYS")
	;S CDILIBRTN=ARY("CDILIBRTN")
	S DEL=ARY("DEL")
	S DES=ARY("DES")
	S DFLAG=+ARY("DFLAG")
	S DFTDES=ARY("DFTDES")
	S DFTDES1=ARY("DFTDES1")
	S DFTHDR=ARY("DFTHDR")
	S DFTORD=+ARY("DFTORD")
	S EXIST=ARY("EXIST")
	S FID=ARY("FID")
	S FILETYP=ARY("FILETYP")
	S FPN=ARY("FPN")
	S FSN=ARY("FSN")
	S GLOBAL=ARY("GLOBAL")
	S LOG=+ARY("LOG")
	S NETLOC=ARY("NETLOC")
	S PACKAGE=ARY("PACKAGE")
	S PARFID=ARY("PARFID")
	S PREDAEN=ARY("PREDAEN")
	S PTRTIM=ARY("PTRTIM")
	S PTRTIMU=ARY("PTRTIMU")
	S PTRTLD=ARY("PTRTLD")
	S PTRTLDU=ARY("PTRTLDU")
	S PTRUSER=ARY("PTRUSER")
	S PTRUSERU=ARY("PTRUSERU")
	S PUBLISH=ARY("PUBLISH")
	S QID1=ARY("QID1")
	S RECTYP=ARY("RECTYP")
	S RFLAG=+ARY("RFLAG")
	S SCREEN=ARY("SCREEN")
	S SYSSN=ARY("SYSSN")
	S UDFILE=ARY("UDFILE")
	;S XFORMRTN=ARY("XFORMRTN")
	;
	; Patch for New Table Wizard
	I DEL="" S DEL=124
	;
        ; This line needs to change. global reference needs to be removed
	I $D(^DBTBL("SYSDEV",1,FID,10)) S SQL="UPDATE DBTBL1 SET ACCKEYS=:ACCKEYS, DEL=:DEL, DES=:DES, DFLAG=:DFLAG, DFTDES=:DFTDES, DFTDES1=:DFTDES1, DFTHDR=:DFTHDR, DFTORD=:DFTORD, EXIST=:EXIST, FILETYP=:FILETYP, FPN=:FPN, FSN=:FSN, GLOBAL=:GLOBAL, LOG=:LOG, NETLOC=:NETLOC, PARFID=:PARFID, PREDAEN=:PREDAEN, PTRTIM=:PTRTIM, PTRTIMU=:PTRTIMU, PTRTLD=:PTRTLD, PTRTLDU=:PTRTLDU, PTRUSER=:PTRUSER, PTRUSERU=:PTRUSERU, PUBLISH=:PUBLISH, QID1=:QID1, RECTYP=:RECTYP, RFLAG=:RFLAG, SCREEN=:SCREEN, SYSSN=:SYSSN, UDFILE=:UDFILE, USER=:USER WHERE FID=:FID"
	E  S SQL="INSERT INTO DBTBL1 (%LIBS, FDOC, ACCKEYS, DEL, DES, DFLAG, DFTDES, DFTDES1, DFTHDR, DFTORD, EXIST, FID, FILETYP, FPN, FSN, GLOBAL, LOG, NETLOC, PARFID, PREDAEN, PTRTIM, PTRTIMU, PTRTLD, PTRTLDU, PTRUSER, PTRUSERU, PUBLISH, QID1, RECTYP, RFLAG, SCREEN, SYSSN, UDFILE, USER) VALUES ('SYSDEV', :FID, :ACCKEYS, :DEL, :DES, :DFLAG, :DFTDES, :DFTDES1, :DFTHDR, :DFTORD, :EXIST, :FID, :FILETYP, :FPN, :FSN, :GLOBAL, :LOG, :NETLOC, :PARFID, :PREDAEN, :PTRTIM, :PTRTIMU, :PTRTLD, :PTRTLDU, :PTRUSER, :PTRUSERU, :PUBLISH, :QID1, :RECTYP, :RFLAG, :SCREEN, :SYSSN, :UDFILE, :USER)"
	;
	S ER=$$^SQL(SQL)
	I ER Q 0_$C(13,10)_$G(RM)
	;
	; Remove table documentation. This is done regardless of mode (insert/update)
	S SQL="DELETE FROM DBTBL1TBLDOC WHERE FID=:FID"
	;
	S ER=$$^SQL(SQL)
	I ER Q 0_$C(13,10)_$G(RM)
	;
	N SEQ,LINE
	F SEQ=1:1:$L(ARY("_doc_"),$C(13,10)) D  I ER Q
	.	S LINE=$P(ARY("_doc_"),$C(13,10),SEQ)
	.	S SQL="INSERT INTO DBTBL1TBLDOC (%LIBS, FID, SEQ, DES) VALUES (:%LIBS, :FID, :SEQ, :LINE)"
	.	S ER=$$^SQL(SQL)
	;
	I ER Q 0_$C(13,10)_$G(RM)
	;
	; Table definition load successfull
	Q 1
	;
	;
        ;-----------------------------------------------------------------------
ENTEXT(CODE,FID)	;
        ;-----------------------------------------------------------------------
	;
	;
	N M,COL,TAG,SEQ,TAB,DOC,INDENT,BUF
	;
	; Tab buffer is 4 spaces
	S BUF=$J("",4)
	S INDENT=1
	;
	S CODE($O(CODE(""),-1)+1)="<?xml version=""1.0""?>"
	S CODE($O(CODE(""),-1)+1)="<Entity>"	
	;
	D BLDPARSE(.ARY)
	;	
	; Load table documentation
	I $D(^DBTBL("SYSDEV",1,FID,0))=11  D
	.	N IDX S IDX=""
        .	F  S IDX=$O(^DBTBL("SYSDEV",1,FID,0,IDX)) Q:IDX=""  D
        ..		S DOC("_docs_",$O(DOC("_docs_",""),-1)+1)=^DBTBL("SYSDEV",1,FID,0,IDX)
	;
	; Loop through columns in the order in which they will appear
	; in the XML document
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
	.	; Documentation flag
	.	I COL="_doc_" D  Q
	..		N IDX S IDX=""
	..		I '$D(DOC("_docs_")) S CODE($O(CODE(""),-1)+1)=BUF_"<"_TAG_">"
	..		F  S IDX=$O(DOC("_docs_",IDX)) Q:IDX=""  D
	...			I IDX=1 S CODE($O(CODE(""),-1)+1)=BUF_"<"_TAG_">"_$$XMLTR^TBXTBL(DOC("_docs_",IDX)) Q
	...			S CODE($O(CODE(""),-1)+1)=$$XMLTR^TBXTBL(DOC("_docs_",IDX))
	..		S CODE($O(CODE(""),-1))=CODE($O(CODE(""),-1))_"</"_TAG_">"
	.		;
	.	I COL="_transquery_" D  Q
	..		S CODE($O(CODE(""),-1)+1)=BUF_"<"_TAG_">"
	..		S CODE($O(CODE(""),-1)+1)="<![CDATA["
	..		S CODE($O(CODE(""),-1)+1)="]]>"
	..		S CODE($O(CODE(""),-1)+1)=BUF_"</"_TAG_">"
	.		;
	.	I COL="_transproc_" D  Q
	..		S CODE($O(CODE(""),-1)+1)=BUF_"<"_TAG_">"
	..		S CODE($O(CODE(""),-1)+1)="<![CDATA["
	..		S CODE($O(CODE(""),-1)+1)="]]>"
	..		S CODE($O(CODE(""),-1)+1)=BUF_"</"_TAG_">"
	.		;
	.	S CODE($O(CODE(""),-1)+1)=BUF_"<"_TAG_">"_$$XMLTR($$GETVAL(FID,COL))_"</"_TAG_">"
	;
	S CODE($O(CODE(""),-1)+1)="</Entity>"
	Q 1
	;
GETVAL(XFID,COL)
	;
	N ER,%TOKEN,VAL
	S ER=$$^SQL("SELECT "_COL_" FROM DBTBL1 WHERE FID=:XFID",,,.VAL)
	I ER Q ""
	Q VAL
	;
	;-----------------------------------------------------------------------
BLDPARSE(ARY)	; Build map between DBTBL1 and XML document vocabulary
	;-----------------------------------------------------------------------
	;
	; Primary entity information
	S ARY($O(ARY(""),-1)+1,"FID")="EntityName"
	S ARY($O(ARY(""),-1)+1,"DES")="Description"
	S ARY($O(ARY(""),-1)+1,"FILETYP")="EntityType"
	S ARY($O(ARY(""),-1)+1,"ACCKEYS")="PrimaryKeys"
	S ARY($O(ARY(""),-1)+1,"PUBLISH")="PublishRoutine"
	;S ARY($O(ARY(""),-1)+1,"CDILIBRTN")="ComputedLibraryRoutineName"
	;S ARY($O(ARY(""),-1)+1,"XFORMRTN")="TransformationRoutineName"
	S ARY($O(ARY(""),-1)+1,"PARFID")="SuperEntity"
	S ARY($O(ARY(""),-1)+1,"SYSSN")="SystemName"
	S ARY($O(ARY(""),-1)+1,"PACKAGE")="Package"
	;
	; Profile Database information
	S ARY($O(ARY(""),-1)+1,"+")="ProfileDB"
	S ARY($O(ARY(""),-1)+1,"DEL")="AttributeDelimiter"
	S ARY($O(ARY(""),-1)+1,"GLOBAL")="Global"
	S ARY($O(ARY(""),-1)+1,"EXIST")="RecordExistsNode"		
	S ARY($O(ARY(""),-1)+1,"QID1")="Query"
	S ARY($O(ARY(""),-1)+1,"UDFILE")="Filer"
	S ARY($O(ARY(""),-1)+1,"RECTYP")="RecordType"
	S ARY($O(ARY(""),-1)+1,"FPN")="AttributeProtectionRoutine"
	S ARY($O(ARY(""),-1)+1,"NETLOC")="NetworkLocation"
	S ARY($O(ARY(""),-1)+1,"-")="ProfileDB"
	;
	; Audit information
	S ARY($O(ARY(""),-1)+1,"+")="Audit"
	S ARY($O(ARY(""),-1)+1,"LOG")="EnableLogging"
	S ARY($O(ARY(""),-1)+1,"PTRTLD")="CreateDate"
	S ARY($O(ARY(""),-1)+1,"PTRTIM")="CreateTime"
	S ARY($O(ARY(""),-1)+1,"PTRUSER")="CreateUser"
	S ARY($O(ARY(""),-1)+1,"PTRTLDU")="ModifyDate"
	S ARY($O(ARY(""),-1)+1,"PTRTIMU")="ModifyTime"
	S ARY($O(ARY(""),-1)+1,"PTRUSERU")="ModifyUser"
	S ARY($O(ARY(""),-1)+1,"-")="Audit"
	;
	; Character screen information
	S ARY($O(ARY(""),-1)+1,"+")="CharacterScreen"
	S ARY($O(ARY(""),-1)+1,"FSN")="LocalArrayName"
	S ARY($O(ARY(""),-1)+1,"DFTDES")="LookupLineOne"
	S ARY($O(ARY(""),-1)+1,"DFTDES1")="LookupLineTwo"
	S ARY($O(ARY(""),-1)+1,"DFLAG")="DeletionRestricted"
	S ARY($O(ARY(""),-1)+1,"DFTHDR")="DefaultHeading"
	S ARY($O(ARY(""),-1)+1,"DFTORD")="DescendingOrder"
	S ARY($O(ARY(""),-1)+1,"PREDAEN")="DataEntryPreProcessor"
	S ARY($O(ARY(""),-1)+1,"RFLAG")="RestrictEntityMaintenance"
	S ARY($O(ARY(""),-1)+1,"SCREEN")="DataEntryScreen"
	S ARY($O(ARY(""),-1)+1,"-")="CharacterScreen"
	;
	S ARY($O(ARY(""),-1)+1,"_doc_")="Documentation"
	;
	; PSL code tags
	;S ARY($O(ARY(""),-1)+1,"_transquery_")="TransformationQueryScript"
	;S ARY($O(ARY(""),-1)+1,"_transproc_")="TransformationProcedureScript"
	;
	Q
	;
	;-----------------------------------------------------------------------
XMLTR(PHRASE)	; Translate phrase to use escaped XML characters
	;-----------------------------------------------------------------------
	;
	;
	N XMLPHRASE,INC
	S XMLPHRASE=""
	;
	F INC=1:1:$L(PHRASE) do 
	.	N char
	.	S char=$E(PHRASE,INC)
	.	I char="<" set XMLPHRASE=XMLPHRASE_"&lt;" quit
	.	I char=">" set XMLPHRASE=XMLPHRASE_"&gt;" quit
	.	I char="&" set XMLPHRASE=XMLPHRASE_"&amp;" quit
	.	I char="'" set XMLPHRASE=XMLPHRASE_"&apos;" quit
	.	I char="""" set XMLPHRASE=XMLPHRASE_"&quot;" quit
	.	S XMLPHRASE=XMLPHRASE_char
	;
	Q XMLPHRASE
	;
	;
	;-----------------------------------------------------------------------
XMLTOARY(CODE,MAP,ARY)	; Parse XML document, return array with DQ key/value pair
	;-----------------------------------------------------------------------
	;
	N LINE,DOC
	S (LINE,DOC)=""
	F  S LINE=$O(CODE(LINE)) Q:LINE=""  S DOC=DOC_CODE(LINE)_$C(13,10)
	;
	N I,COL,TAG,DATA
	F I=1:1:$O(MAP(""),-1) D
	.	S COL=$O(MAP(I,""))
	.	I COL="" Q
	.	S TAG=MAP(I,COL)
	.	I (COL="+")!(COL="-") Q
	.	I DOC'["<"_TAG_">" Q
	.	S DATA=$$UNESC($P($P(DOC,"<"_TAG_">",2),"</"_TAG_">",1))
	.	S ARY(COL)=DATA
	Q
	;-----------------------------------------------------------------------
UNESC(XMLPHRASE)	; Translate phrase to unescaped XML characters
	;-----------------------------------------------------------------------
	;
	;
	N PHRASE,INC,CHAR
	S PHRASE=""
	;
	F INC=1:1:$L(XMLPHRASE) do 
	.	S CHAR=$E(XMLPHRASE,INC)
	.	I CHAR'="&" S PHRASE=PHRASE_CHAR Q
	.	I $E(XMLPHRASE,INC,INC+$L("&lt;")-1)="&lt;" S PHRASE=PHRASE_"<",INC=INC+3
	.	I $E(XMLPHRASE,INC,INC+$L("&gt;")-1)="&gt;" S PHRASE=PHRASE_">",INC=INC+3
	.	I $E(XMLPHRASE,INC,INC+$L("&amp;")-1)="&amp;" S PHRASE=PHRASE_"&",INC=INC+4
	.	I $E(XMLPHRASE,INC,INC+$L("&quot;")-1)="&quot;" S PHRASE=PHRASE_"""",INC=INC+5
	.	I $E(XMLPHRASE,INC,INC+$L("&apos;")-1)="&apos;" S PHRASE=PHRASE_"'",INC=INC+5
	;
	Q PHRASE
	;
	;
	;***************************************************************
	;
	;
	;   THE FOLLOWING TAGS ARE USED TO PRODUCT DOCUMENTATION
	;
	;
	;***************************************************************
	;-----------------------------------------------------------------------
xmlmap(CTL)	;generate map describing the XML transformation of DBTBL1
	;-----------------------------------------------------------------------
	;
	;	CTL	0 = Process Tables
	;		1 = Process Columns
	;		2 = Foreign Keys
	;		3 = Index Definitions
	;
	N SEQ,ARY,DI,TAG,DES,LEN,TYPE,IO,LOOKUP,FNAME,FID,XREF
	;
	I CTL=0 S FID="DBTBL1" D BLDPARSE(.ARY) S FNAME="ENTITY.XLS"
	I CTL=1 S FID="DBTBL1D" D BLDPARSE^TBXCOL(.ARY) S FNAME="ATTRIBUTE.XLS"
	I CTL=2 S FID="DBTBL1F" D BLDPARSE^TBXFKEY(.ARY) S FNAME="FKEY.XLS"
	I CTL=3 S FID="DBTBL8" D BLDPARSE^TBXIDX(.ARY) S FNAME="INDEX.XLS"
	I CTL=4 S FID="DBTBL9" D BLDPARSE^TBXJRNL(.ARY) S FNAME="JOURNAL.XLS"
	;
	S IO="/p01scmix/spool/"_FNAME
	;
	O IO:NEWV
	;
	U IO
	W "DQ Name",$C(9),"Tag",$C(9),"Description",$C(9),"Data Type",$C(9),"Max Length",$C(9),"Look-up"
	F I=1:1:$O(ARY(""),-1) D
	.	S DI=$O(ARY(I,""))
	.	S XREF(DI)=""
	.	S TAG=ARY(I,DI)
	.	I DI="-" W !,$C(9),TAG,$C(9),"End" Q
	.	I DI="+" W !,$C(9),TAG,$C(9),"Start" Q
	.	;
	.	S REC=$G(^DBTBL("SYSDEV",1,FID,9,DI))
	.	S DES=$P(REC,"|",10)
	.	S TYPE=$P(REC,"|",9)
	.	S LEN=$P(REC,"|",2)
	.	S LOOKUP=$P(REC,"|",5)
	.	W !,DI,$C(9),TAG,$C(9),DES,$C(9),TYPE,$C(9),LEN,$C(9),LOOKUP
	;
	W !!,"The following properties from "_FID_" are not included in the schema"
	; Loop through all properties in DATA QWIK to identify which ones are not included
	N DI S DI=""
	F  S DI=$O(^DBTBL("SYSDEV",1,FID,9,DI)) Q:DI=""  D
	.	; Property is accounted for
	.	I $D(XREF(DI)) Q
	.	;
	.	S REC=$G(^DBTBL("SYSDEV",1,FID,9,DI))
	.	S DES=$P(REC,"|",10)
	.	S TYPE=$P(REC,"|",9)
	.	S LEN=$P(REC,"|",2)
	.	S LOOKUP=$P(REC,"|",5)
	.	W !,DI,$C(9),"",$C(9),DES,$C(9),TYPE,$C(9),LEN,$C(9),LOOKUP
	;
	U 0
	C IO
	;
	Q
	;-----------------------------------------------------------------------
xmlhelp(CTL)	; Generate help file in XML
	;-----------------------------------------------------------------------
	;
	;	CTL	0 = Process Tables
	;		1 = Process Columns
	;		2 = Foreign Keys
	;		3 = Index Definitions
	;
	N SEQ,ARY,DI,TAG,DES,LEN,TYPE,IO,LOOKUP,FNAME,FID,XREF
	;
	I CTL=0 S FID="DBTBL1" D BLDPARSE(.ARY) S FNAME="ENTITYHELP.XML",TOP="EntityHelp"
	I CTL=1 S FID="DBTBL1D" D BLDPARSE^TBXCOL(.ARY) S FNAME="ATTRIBUTEHELP.XML",TOP="AttributeHelp"
	I CTL=2 S FID="DBTBL1F" D BLDPARSE^TBXFKEY(.ARY) S FNAME="FKEYHELP.XML",TOP="ForeignKeyHelp"
	I CTL=3 S FID="DBTBL8" D BLDPARSE^TBXIDX(.ARY) S FNAME="INDEXHELP.XML",TOP="IndexHelp"
	I CTL=3 S FID="DBTBL9" D BLDPARSE^TBXJRNL(.ARY) S FNAME="JOURNALHELP.XML",TOP="JournalHelp"
	;
	S IO="/p01scmix/spool/"_FNAME
	;
	O IO:NEWV
	;
	U IO
	W "<"_TOP_">"
	F I=1:1:$O(ARY(""),-1) D
	.	S DI=$O(ARY(I,""))
	.	S XREF(DI)=""
	.	S TAG=ARY(I,DI)
	.	;
	.	S REC=$G(^DBTBL("SYSDEV",1,FID,9,DI))
	.	S DES=$P(REC,"|",10)
	.	S TYPE=$P(REC,"|",9)
	.	S LEN=$P(REC,"|",2)
	.	S LOOKUP=$S(($P(REC,"|",5)'=""):"true",1:"false")
	.	W !,"<help tag="""_TAG_""">"
	.	W !,"<info>"_FID_"."_DI_"="_DES_"   Data Type="_TYPE_" Max Size="_LEN_" Look-up Table="_LOOKUP
	.	; Load data item documentation
	.	I $D(^DBTBL("SYSDEV",11,FID,DI))  D
	..		N IDX S IDX=""
        ..		F  S IDX=$O(^DBTBL("SYSDEV",11,FID,DI,IDX)) Q:IDX=""  D
        ...			W !,$$XMLTR($G(^DBTBL("SYSDEV",11,FID,DI,IDX)))
	.	W !,"</info>"
	.	W !,"</help>"
	;
	W "</"_TOP_">" 
	U 0
	C IO
	;
	Q
	;
	;
	;***************************************************************
	;
	;
	;   THE REMAINING CODE IS FOR TESTING PURPOSES 
	;
	;
	;***************************************************************
	;
testout	; Test entity output
	;
	N FID
	S FID=""
	F  S FID=$O(^DBTBL("SYSDEV",1,FID)) Q:FID=""  D testout1(FID)
	;
	Q
	;
testout1(FID)
	;
	N IO,CODE
	S IO="/p01scmix/spool/"_FID_".TBL"
	;
	O IO:NEWV
	U IO
	D ENTEXT(.CODE,FID)
	N SEQ
	S SEQ=""
	F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  W !,CODE(SEQ)	
	U 0
	C IO
	;
	Q
	;
testin	; Test entity loading
	;
	;D testin2("/p01scmix/spool/DEP.TBL")
	;D testin2("/p01scmix/spool/ACN.TBL")
	D testin2("/p01scmix/spool/DEPSEG.TBL")
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
	D XMLTOARY(.CODE,.MAP,.ARY)
	;
	; Splash the insert statement
	W !!,"INSERT INTO DBTBL1 ("
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
	W !!,"UPDATE DBTBL1 SET "
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
	;----------------------------------------------------------------------
GBLMAP	; Generate map from global to Column to TAG
	;----------------------------------------------------------------------
	;
	N ARY,TAG,DI,NOD,POS,SEQ
	;
	D BLDPARSE(.ARY)
	;
	S TAG=""
	F SEQ=1:1:$O(ARY(""),-1) D
	.	S DI=$O(ARY(SEQ,""))
	.	I '$D(^DBTBL("SYSDEV",1,"DBTBL1",9,DI)) Q
	.	S TAG=ARY(SEQ,DI)
	.	S NOD=$P(^DBTBL("SYSDEV",1,"DBTBL1",9,DI),"|",1)
	.	S POS=$P(^DBTBL("SYSDEV",1,"DBTBL1",9,DI),"|",21)
	.	W !,TAG,",",DI,",",NOD,",",POS
	Q
		
