TBXG	;Private;TBX GLOBAL UTILITIES
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/07/02 09:29:27 - KWANL
	; ORIG:	Frans S.C. Witte, 2008-11-02
	; DESC:	TBX GOBAL UTILITIES
	;
	;-------- Comments -----------------------------------------------------
	; This module implements the interface to TBXSPIN, TBXFPIN, and MRPC121
	; for M Globals, stored in files with a .G extension.
	; Originally M Globals were handled by TBXDATA, but TBXDATA has been
	; modified to support a data-exchange format that is database
	; independent.
	; This module only deals with the data that is not (yet) database
	; independent, i.e. is unconditionally stored in an M Global.
	;
	; The get and put of M Global data is based on a naming convention of
	; the filename. A .G file supports up to three dash-delimited pieces.
	; The first piece is the global name, the second piece denotes a
	; constant first-level subscript, the third piece denotes a constant
	; second-level subscript.
	;
	; Unfortunately, the original "M Global only" TBXDATA was modified to
	; support both .G and .DAT files, but the original file-name
	; conventions were not maintained or converted consistently.
	; These inconsistencies are inherited by this TBXG module. 
	;
	; The following OBJECTIDs have special processing:
	; - SCATBL:
	;	CHECKOBJ returns update-not-allowed error
	; - SCATBL-1[-.]*
	;	LOAD will NOT delete the current contents
	; - SCATBL-5[-.]*
	;	LOAD will NOT delete the current contents
	; - SCATBL3:
	;	CHECKOBJ returns update-not-allowed error, but SCATBL-3[-key]
	;		will exhibit standard behavior
	; - SCATBLDOC:
	;	CHECKOBJ returns update-not-allowed error
	; - STBL-MSG[-.]*
	;	LOAD will NOT delete the current contents
	; - STBL-XBAD[-.]*
	;	LOAD will NOT delete the current contents
	;
	;-------- Revision History ---------------------------------------------
	; 2009-04-24, CR39019, Jaywant Khairmar
	;	Corrected issue in OBSOBJ when obsoleting GLOBAL.G (no
	;	subscripts).
	;
	; 2008-11-02, Frans S.C. Witte, CR36017
	;	Initial program, derived from TBXDATA.
	;	Removed numerous $GET() functions
	;
	Q
	;
	;-----------------------------------------------------------------------
GETCODE(OBJECTID,CODE,FILENAME)	; Get object contents
	;-----------------------------------------------------------------------
	; Called via MRPC121.
	; Calls $$EXTRACT().
	;
	; ARGUMENTS:
	; . req String OBJECTID = identification of object
	;	Dash-delimited name, without the ".G" extension
	; . ret void CODE(String) = data to be returned
	; . ret String FILENAME = name of output file
	;	Will be set to OBJECTID_".G"
	;
	N VN
	;
	; Get profile version
	S VN=$G(^CUVAR("%VN"))
	;
	N KEY1,KEY2,KEY3
	;
	I $G(OBJECTID)="" Q 0_$C(13,10)_$$^MSG(741)
	;
	S KEY1=$P(OBJECTID,"-",1),KEY2=$P(OBJECTID,"-",2),KEY3=$P(OBJECTID,"-",3)
	;
	; add quotes if keys contain at least one alphabetic characters
	I KEY2?.E1A.E S KEY2=$$QADD^%ZS(KEY2)
	I KEY3?.E1A.E S KEY3=$$QADD^%ZS(KEY3)
	;
	S FILENAME=OBJECTID_".G"
	Q $$EXTRACT(.CODE,KEY1,KEY2,KEY3)
	;
	;-----------------------------------------------------------------------
CHECKOBJ(TOK,OBJECTID)	; Return a message for update or create prompt
	;-----------------------------------------------------------------------
	; Check save-status of OBJECTID.
	; Called via MRPC121.
	;
	; ARGUMENTS:
	; . req String TOK = token
	;	First subscript in ^TMP(), used as token for transfers that
	;	span multiple requests.
	; . req String OBJECTID
	;	Data identification annex file name (without extension).
	;
	N CONAME,END,KEY1,KEY2,KEY3
	;
	; S CONAME=$$^CUVAR("CONAM")
	S CONAME=$$SCAU^%TRNLNM("DDPLOG")
	;
	S END=$O(^TMP(TOK,""),-1)
	I END="" Q 0_$C(13,10)_"Missing source code"
	;
	S KEY1=$P(OBJECTID,"-",1),KEY2=$P(OBJECTID,"-",2),KEY3=$P(OBJECTID,"-",3)
	;
	I KEY1=OBJECTID,("SCATBL,SCATBLDOC,SCATBL3"[KEY1) Q 0_$C(13,10)_"Error: "_KEY1_" table is not allowed to update"
	;
	; add quotes if keys contain at least one alphabetic characters
	I $G(KEY2)?.E1A.E S KEY2=$$QADD^%ZS(KEY2)
	I $G(KEY3)?.E1A.E S KEY3=$$QADD^%ZS(KEY3)
	;
	; Use KEY2="" and KEY3="" to deal with trailing dashes
	; NOTE: IF-ELSE !!
	I KEY1="" Q 0_$C(13,10)_"Invalid object name "_OBJECTID
	I KEY2="" S GREF="^"_KEY1 Q:KEY3'="" 0_$C(13,10)_"Invalid object name "_OBJECTID
	E  I KEY3="" S GREF="^"_KEY1_"("_KEY2_")"
	E  S GREF="^"_KEY1_"("_KEY2_","_KEY3_")"
	I '$D(@GREF) Q 1_$C(13,10)_"Create new Data in "_CONAME
	;
	; Data exists
	Q 1_$C(13,10)_"Update Data : "_OBJECTID_" Modified in "_CONAME
	;
	;-----------------------------------------------------------------------
SAVEOBJ(TOK,OBJECTID,USER)	; Save Batch Def sent by client
	;-----------------------------------------------------------------------
	; Called via MRPC121.
	; Calls $$LOAD() to store the data into the gobal.
	;
	; ARGUMENTS:
	; . TOK and OBJECTID: see CHECKOBJ
	; . USER = current user
	;
	N CODE,SEQ
	S SEQ=""
	;
	; Load from buffer into CODE array
	F  S SEQ=$O(^TMP(TOK,SEQ)) Q:SEQ=""  S CODE(SEQ)=^TMP(TOK,SEQ)
	;
	; Delete buffer
	K ^TMP(TOK)
	;
	Q $$LOAD(.CODE,OBJECTID,3,USER,+$H,$P($H,",",2))
	;
	;-----------------------------------------------------------------------
CHECK(FILE,RUSER,RDATE,RTIME);
	;-----------------------------------------------------------------------
	; 
	Q 1
	;
	;-----------------------------------------------------------------------
LOAD(CODE,FILE,RTYPE,USER,DATE,TIME) ; Load a .G file
	;-----------------------------------------------------------------------
	; Called by SAVEOBJ via MRPC121, by TBXSPIN, and by TBXFPIN
	;
	; The old contents of the global (as determined by the file-name
	; convention) is deleted, except for the following file-name patterns:
	; . STBL-MSG[-.]*
	; . STBL-XBAD[-.]*
	; . SCATBL-1[-.]*
	; . SCATBL-5[-.]*
	;
	; ARGUMENTS:
	; . req void CODE(String)
	;	The data to be stored into the global
	; . req String FILE
	;	The name of the file or the name of the object (i.e. with or
	;	without extension). The value is supposed to be well-formed.
	; . req Integer RTYPE
	;	1 = TBXSPIN
	;	2 = TBXFPIN
	;	3 = other (MRPC)
	;
	; RETURNS:
	; . $$ = 1 (success) or 0|reason (M runtime failure)
	;
	N CLEAN,EXIT,GREF,GNAME,KEY1,KEY2,KEY3,RESULT,SEQ,$ZT
	;
	S $ZT=$$SETZT^%ZT("ZTL^TBXG")
	;
	S GNAME=$P(FILE,".",1)
	S KEY1=$P(GNAME,"-",1),KEY2=$P(GNAME,"-",2),KEY3=$P(GNAME,"-",3)
	;
	; CLEAN flag indicates that the global should be deleted (killed) before 
	; the new data is loaded.
	S CLEAN=1
	;
	I (KEY1="STBL"),(KEY2="MSG") S CLEAN=0
	I (KEY1="STBL"),(KEY2="XBAD") S CLEAN=0
	I (KEY1="SCATBL"),(KEY2="1") S CLEAN=0
	I (KEY1="SCATBL"),(KEY2="5") S CLEAN=0
	;
	; add quotes if keys contain at least one alphabetic characters
	I KEY2?.E1A.E S KEY2=$$QADD^%ZS(KEY2)
	I KEY3?.E1A.E S KEY3=$$QADD^%ZS(KEY3)
	;
	; NOTE: IF-ELSE !!
	I KEY2="" S GREF="^"_GNAME
	E  I KEY3="" S GREF="^"_KEY1_"("_KEY2_")"
	E  S GREF="^"_KEY1_"("_KEY2_","_KEY3_")"
	;
	; Kill existing data
	I CLEAN K @GREF
	;
	; Load new data
	S SEQ="" F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  D
	. ; This is to fix the end of file
	. I CODE(SEQ)="" Q						
	. S @CODE(SEQ)
	; 
	I (RTYPE=1)!(RTYPE=2) D
	.	I $D(^TMPDQS($J,"phase1","data",FILE)) S ^TMPDQS($J,"phase1")=1
	.	I $D(^TMPDQS($J,"phase2","data",FILE)) S ^TMPDQS($J,"phase2")=1
	Q 1
	;
	;-----------------------------------------------------------------------
EXTRACT(CODE,KEY1,KEY2,KEY3) ; extract data from M Global
	;-----------------------------------------------------------------------
	; Called by GETCODE via MRPC121
	;
	; ARGUMENTS:
	; . req String KEY1
	;	global name (without "^"). Shall not be "".
	; . req String KEY2
	;	first level subscript (or "" for entire global).
	; . req String KEY3
	;	second level subscript (or ""). Shall be "" if KEY2="".
	;
	N DATA,GREF,REF,$ZT
	S $ZT=$$SETZT^%ZT("ZTE^TBXG")
	;
	; NOTE: IF-ELSE !!
	I KEY2="" S GREF="^"_KEY1 Q:'$D(@GREF) "0|Global definition "_KEY1_" does not exist"
	E  I KEY3="" S GREF="^"_KEY1_"("_KEY2_")" Q:'$D(@GREF) "0|Global definition "_KEY1_"."_KEY2_" does not exist"
	E  S GREF="^"_KEY1_"("_KEY2_","_KEY3_")" Q:'$D(@GREF) "0|Global definition "_KEY1_"."_KEY2_"."_KEY3_" does not exist"
	;
	N REF
        S REF=$P(GREF,")",1)
	;
	; convert control characters
	I $D(@GREF)#10 D  
	.	I @GREF="" S CODE(1)=""_GREF_"="_"""""" Q
	.	I @GREF?.N S CODE(1)=""_GREF_"="_@GREF Q
	.	I @GREF?.E1C.E S Y=@GREF,Y=$$FIXCCHR^TBXDQUTL(Y),CODE(1)=""_GREF_"="_Y Q
	.	S CODE(1)=""_GREF_"="_$$QADD^%ZS(@GREF) Q
        F  S GREF=$Q(@GREF) Q:(GREF="")!($E(GREF,1,$L(REF))'=REF)  D
	.	I @GREF="" S CODE($O(CODE(""),-1)+1)=""_GREF_"="_"""""" Q
	.	I @GREF?.N S CODE($O(CODE(""),-1)+1)=""_GREF_"="_@GREF Q
	.	I @GREF?.E1C.E S Y=@GREF,Y=$$FIXCCHR^TBXDQUTL(Y),CODE($O(CODE(""),-1)+1)=""_GREF_"="_Y Q
        . 	S CODE($O(CODE(""),-1)+1)=""_GREF_"="_$$QADD^%ZS(@GREF)
        ;
        Q 1
	;
	;-----------------------------------------------------------------------
OBSOBJ(FILE) ; Obsolete data specified by FILE
	;-----------------------------------------------------------------------
	; Called by TBXSPIN and TBXFPIN.
	; The global implied by the supplied filename is unconditionally KILLed.
	;
	; ARGUMENTS:
	; . req String FILE
	;	Name of the file. Shall be well-formed.
	;
	N GREF,KEY1,KEY2,KEY3,NAME,REF
	;
	S NAME=$P(FILE,".",1)
	S KEY1=$P(NAME,"-",1),KEY2=$P(NAME,"-",2),KEY3=$P(NAME,"-",3)
	;
	; add quotes if keys contain at least one alphabetic characters
	I KEY2?.E1A.E S KEY2=$$QADD^%ZS(KEY2)
	I KEY3?.E1A.E S KEY3=$$QADD^%ZS(KEY3)
	;
	; NOTE: IF-ELSE !!
	I KEY2="" S GREF="^"_KEY1
	E  I KEY3="" S GREF="^"_KEY1_"("_KEY2_")"
	E  S GREF="^"_KEY1_"("_KEY2_","_KEY3_")" 
	;
	K @GREF
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
        ;---------------------------------------------------------------------
ADDQ(STR); Double the single quote to prevent string being truncated when inserting
	; to Oracle.
	;---------------------------------------------------------------------
        ;
        N TMPSTR,INC
        S TMPSTR=""
        I $F(STR,"'")=0 Q STR
        F INC=1:1:$L(STR,"'") S TMPSTR=TMPSTR_$P(STR,"'",INC)_"''"  
        Q $E(TMPSTR,1,$L(TMPSTR)-2)
	;
	;---------------------------------------------------------------------