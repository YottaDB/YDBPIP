TBXJRNL	;Private;DataQwik journal handler
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/08/02 17:31:53 - KWANL
	; ORIG:	KWANL - 05/08/02
	; DESC:	DataQwik journal handler
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
	; 03/21/2007	KWANL
	;		Checked the top level of a journal definition. If it 
	;		ends at position 14 add time and followed by a double 
	;		quote, otherwise just add time. 	
	;		
	; 11/17/2005	KWANL
	;		Replaced reference to ^CUVAR with $$SCAU^%TRNLNM("DDPLOG")
	;	
	;-----------------------------------------------------------------------
GETCODE(OBJECTID,CODE,FILENAME)	; Get object contents
	;-----------------------------------------------------------------------
	;
	N JRNID,KEY
	;
	I $G(OBJECTID)="" Q 0_$C(13,10)_$$^MSG(741)
	;
	S JRNID=$P(OBJECTID,"-",1),KEY=$P(OBJECTID,"-",2)
	;
	S FILENAME=JRNID_"-"_KEY_".JFD"
	Q $$EXTRACT(.CODE,JRNID,KEY)
	;
	;-----------------------------------------------------------------------
CHECKOBJ(TOK,OBJECTID)	; Return a message for update or create prompt
	;-----------------------------------------------------------------------
	;
	N HEADER,USER,DATE,TIME,END,CONAME,MESSAGE,FID,KEY
	;
	; S CONAME=$$^CUVAR("CONAM")
	S CONAME=$$SCAU^%TRNLNM("DDPLOG")
	;
	S END=$O(^TMP(TOK,""),-1)
	I END="" Q 0_$C(13,10)_"Missing source code"
	;
	S JRNID=$P(OBJECTID,"-",1),KEY=$P(OBJECTID,"-",2)
	;
	I '$D(^DBTBL(%LIBS,9,JRNID,KEY)) D  Q MESSAGE
	.	S MESSAGE=1_$C(13,10)_"Create new Journal in "_CONAME
	;
	; Journal Definition exists, return user and date modified
	S HEADER=^DBTBL(%LIBS,9,JRNID,KEY)
	S USER=$$^%ZD($P(HEADER,"|",10))
	S DATE=$P(HEADER,"|",9)
	;
	S MESSAGE="Update Data Item : "_JRNID_"-"_KEY_" Modified by "_USER
	S MESSAGE=MESSAGE_" on "_DATE_" in "_CONAME
	;
	Q 1_$C(13,10)_MESSAGE
	;
	;-----------------------------------------------------------------------
SAVEOBJ(TOK,OBJECTID,USER)	; Save Foreign Key Def sent by client
	;-----------------------------------------------------------------------
	;
	N SEQ,CODE,JRNID,KEY,FILENAME
	S SEQ=""
	;
	; Load from buffer into CODE array
	F  S SEQ=$O(^TMP(TOK,SEQ)) Q:SEQ=""  S CODE(SEQ)=^TMP(TOK,SEQ)
	;
	; Delete buffer
	K ^TMP(TOK)
	;
	S JRNID=$P(OBJECTID,"-",1),KEY=$P(OBJECTID,"-",2)
	S FILENAME=JRNID_"-"_KEY_".JFD"
	Q $$LOAD(.CODE,FILENAME,3,USER,+$H,$P($H,",",2))
	;
	;----------------------------------------------------------------------- 
CHECK(FILE,RUSER,RDATE,RTIME);	Compare date stamp between ^DBTBL and ^dbtbl 
	;----------------------------------------------------------------------- 
	; ARGUMENTS: 
	;       . FILE          RMS file name           /TYP=T 
	; RETURNS: 
	;       . $$            Match or Failure        /TYP=T 
	;                       Match = 1 
	;                       Failure returns 
	;                         "0|Wrong file type" 
	;                         "0|Date Stamp Mistmatch" 
	;  
	;----------------------------------------------------------------------- 
	; 
	N JRNID,KEY,CDDATE,CUSER,DDATE,DUSER 
	; 
	S JRNID=$P(FILE,"-",1),KEY=$P($P(FILE,".",1),"-",2) 
	S CDATE=$P($G(^DBTBL("SYSDEV",9,JRNID,KEY)),%,9) 
	S CUSER=$P($G(^DBTBL("SYSDEV",9,JRNID,KEY)),%,10)                 
	S DDATE=$P($G(^dbtbl("SYSDEV",9,JRNID,KEY)),%,9)  
	S DUSER=$P($G(^dbtbl("SYSDEV",9,JRNID,KEY)),%,10) 
	; 
	Q $$CKDTUSR^TBXDQUTL(DDATE,DUSER,CDATE,CUSER,RDATE,RUSER) 
	;
	;----------------------------------------------------------------------- 
LOAD(CODE,FILE,RTYPE,USER,DATE,TIME)	; Load a filer executive definition 
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
	;                         "0|"_$ZS
	;			  "0|Failed to update ^dbtbl"
	;----------------------------------------------------------------------- 
	; 
	N JRNID,KEY,LINE,EXT,TMPSTR,SEQ,$ZT,SEQ1,SRC 
	; 
	S $ZT=$$SETZT^%ZT("ZTL^TBXJRNL")
	S JRNID=$P(FILE,"-",1),KEY=$P($P(FILE,".",1),"-",2),EXT=$P(FILE,".",2) 
	;
	K ^DBTBL("SYSDEV",9,JRNID,KEY) 
	; 
	S SEQ1="",SEQ1=$O(CODE(SEQ1),-1)
	; update ^DBTBL and insert last modified info on the header
	S SEQ="" F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  D 
	. I CODE(SEQ)[("^DBTBL(""SYSDEV"",9,"""_JRNID_""","""_KEY_""")")  d
	.. S $P(CODE(SEQ),"|",9)=DATE,$P(CODE(SEQ),"|",10)=USER
	.. I $L(CODE(SEQ),"|")>14 S $P(CODE(SEQ),"|",14)=TIME Q
	.. S $P(CODE(SEQ),"|",14)=TIME_$C(34)
	. I (SEQ=SEQ1)&(CODE(SEQ)="") Q				; to fix carriage return on windows
	. S @CODE(SEQ) 
	;
	S X=1
	;
	; if service pack, update ^dbtbl
	I RTYPE=2 D
	. K ^dbtbl("SYSDEV",9,JRNID,KEY)
	. S SRC="^DBTBL(""SYSDEV"",9,"""_JRNID_""","""_KEY_""")"
	. S X=$$CP^TBXDQUTL(SRC,"^dbtbl")
	;
	; set up for DQ compile
	I (RTYPE=1)!(RTYPE=2) S ^TMPDQC($J,"SYSDEV",9,JRNID_"."_KEY)=""
	Q:X=0 "0|Failed to update Journal: "_JRNID_" into ^dbtbl"
	Q 1 
	;----------------------------------------------------------------------- 
EXTRACT(CODE,JRNID,KEY);	Extract a journal definition into an array. 
	;----------------------------------------------------------------------- 
	; ARGUMENTS: 
	;       . CODE          Contents of a journal defintion 	/TYP=ARR
	;	. JRNID		A journal ID				/TYP=T
	;	. KEY		A journal sub key			/TYP=T
	; RETURNS: 
	;       . $$            Success or Failure 	        /TYP=T
	;                       Success = 1 
	;                       Failure returns 
	;                         "0|"_$ZS 
	;----------------------------------------------------------------------- 
	; 
	N %ZT,SEQ,DATA,DREF 
	S $ZT=$$SETZT^%ZT("ZTE^TBXJRNL")
	;
	I '$D(^DBTBL("SYSDEV",9,JRNID)) Q "0|Journal definition "_JRNID_"."_KEY_" does not exists" 
	;
	D CPYARR^TBXDQUTL(.CODE,9,JRNID,KEY)
	; 
	Q 1 
	;
	;-----------------------------------------------------------------------
OBSDQW(FILE);	Obsolete a Journal definition 
	;-----------------------------------------------------------------------
	;
	N NAME,JRNID,KEY
	S NAME=$P(FILE,".",1)
	S JRNID=$P(NAME,"-",1),KEY=$P(NAME,"-",2)
	;
	K ^DBTBL("SYSDEV",9,JRNID,KEY)
	K ^dbtbl("SYSDEV",9,JRNID,KEY)
	;
	S ^TMPDQC($J,"SYSDEV",9,JRNID)=""
	;    
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
