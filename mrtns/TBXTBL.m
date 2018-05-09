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
        ; 02/14/07	KWANL
        ;	 	Added code to check table type before setting up ^TMPSQL 
        ;		global in OBSDQW section.	
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
CHECK(FILE,RUSER,RDATE,RTIME); Compare date stamp between ^DBTBL and ^dbtbl
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
LOAD(CODE,FILE,RTYPE,USER,DATE,TIME); Load a table header
	;-----------------------------------------------------------------------
        ; ARGUMENTS:
        ;       . CODE        Content of the file
        ;  	. FILE	      DQ file name
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
EXTRACT(CODE,TBLID); Extract a table header
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
        .	I KEY=10 D  Q 
	..		S TMPSTR=^DBTBL("SYSDEV",1,TBLID,10)
        ..		S $P(TMPSTR,"|",10)=""
        ..		S $P(TMPSTR,"|",11)=""
        ..		S CODE($O(CODE(""),-1)+1)="^DBTBL(""SYSDEV"",1,"""_TBLID_""","_KEY_")="_$$QADD^%ZS(TMPSTR)
	.	; if data item contains *, $, quotes, keep it in the table definition
        .	I KEY=9 S DI="" D  Q							
        ..		F  S DI=$O(^DBTBL("SYSDEV",1,TBLID,KEY,DI)) Q:DI=""  D
        ...			I (DI["*")!(DI["$")!(DI["""") D
	....				S TMPSTR=^DBTBL("SYSDEV",1,TBLID,KEY,DI)
	....				S $P(TMPSTR,"|",25)=""
        ....				I $P(TMPSTR,"|",26)[$C(34) S $P(TMPSTR,"|",26)=""_$C(34)
        ....				E  S $P(TMPSTR,"|",26)=""
	....				I (DI["""") S CODE($O(CODE(""),-1)+1)="^DBTBL(""SYSDEV"",1,"""_TBLID_""",9,"""""_DI_""""")="_$$QADD^%ZS(TMPSTR)
	....				E  S CODE($O(CODE(""),-1)+1)="^DBTBL(""SYSDEV"",1,"""_TBLID_""",9,"""_DI_""")="_$$QADD^%ZS(TMPSTR)
        .	E  D
        ..		S SRC="^DBTBL(""SYSDEV"",1,"""_TBLID_""","_KEY_")"
        ..		S REF=$S(SRC["(":$E(SRC,1,$L(SRC)-1),1:SRC)
        ..		I $D(@SRC)#10 D
	...			I @SRC?.E1C.E S CODE($O(CODE(""),-1)+1)="^DBTBL"_$E(SRC,7,$L(SRC))_"="_$$FIXCCHR^TBXDQUTL(@SRC) Q
        ...			E  S CODE($O(CODE(""),-1)+1)="^DBTBL"_$E(SRC,7,$L(SRC))_"="_$$QADD^%ZS(@SRC)
        ..		F  S SRC=$q(@SRC) q:(SRC="")!($E(SRC,1,$l(REF))'=REF)  D
	...			I @SRC?.E1C.E S CODE($O(CODE(""),-1)+1)="^DBTBL"_$E(SRC,7,$L(SRC))_"="_$$FIXCCHR^TBXDQUTL(@SRC) Q
        ...			S CODE($O(CODE(""),-1)+1)="^DBTBL"_$E(SRC,7,$L(SRC))_"="_$$QADD^%ZS(@SRC)
        Q 1
	;-----------------------------------------------------------------------
RMTBLHDR(GLOBAL,TBL); Remove table header.
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
OBSDQW(FILE); Obsolete a table definition
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
        .	Q:'$$rdb^UCDBRT(TBLID)
        .	s ^TMPSQL($J,"obsolete",TBLID)=1
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