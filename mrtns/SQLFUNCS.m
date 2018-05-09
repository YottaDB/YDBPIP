SQLFUNCS;;Library of functions for use with SQL
	;;Copyright(c)2001 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/22/01 15:53:17 - SANTOSL

	;			to get next results set segment
	;
	;       . INSCMD        Returns SQL INSERT command baased on column
	;                       names and input data
	;
	;       . UPDCMD        Returns SQL UPDATE command based on column
	;                       names and input data
	;
	;	. SQLTOSHR	Returns updated Local arrray (short name)
	;			based on SQL command passed
	;
	;	. NVL		Scalar function NVL, Null Value Default
	;
	;	. DECODE	Scalar function DECODE
	;
	;	. ROUND		Scalar function ROUND
	;
	;	. SIGN		Scalar function SIGN
	;
	;---- Revision History ------------------------------------------------
	;
	; 10/23/2008 - RussellDS - CRs 35741/35918
	;	Added /SAVECUR parameter to FETCH section.
	;
	;	Removed old revision history.
	;            
	;----------------------------------------------------------------------
FETCH(cursor,rownum,row,stat,rowdata,cnt,rows)	;Private;Get next row
	;----------------------------------------------------------------------
	; Gets the next row number (rownum) for 'cursor' from 'rows'.  Must
	; have called OPEN with /ROWS and /SAVECUR qualifiers prior to first use.
	;
	; Note:  To use, define 'rownum' as 1 on first call.  Do not manipulate
	;        any of the other parameters.  The row requested is returned
	;        in 'row'.
	;
	; ARGUMENTS:
	;	. cursor	Name of cursor			/MECH=VAL
	;	. rownum	Number of row to return		/MECH=REFNAM:RW
	;	. row		Row data return in row		/MECH=REFNAM:W
	;	. stat		sqlsta = SQL status		/MECH=REFNAM:RW
	;	. rowdata	sqldta = SQL data		/MECH=REFNAM:RW
	;	. cnt		sqlcnt = SQL rows returned	/MECH=REFNAM:RW
	;	. rows		Used in /ROWS qualifier		/MECH=VAL/NOREQ
	;	
	; RETURNS:
	;	. $$		Success indicator
	;			0 = done - end of data
	;			1 = row returned
	;
	; EXAMPLE:
	;	S X=$$FETCH("ABC",.NUM,.DATA,.STAT,.ROWDATA,.CNT,20)
	;I18N=QUIT
	;
	N DONE,ER,SQL
	I '$G(rows) S rows=20			; Default to 20 rows per fetch
	I rownum>cnt,stat=100 Q 0  		; All done
	I rownum>cnt D  I DONE Q 0    		; Get more records
	.	S DONE=0
	.	S SQL="FETCH FROM "_cursor
	.	S ER=$$^SQL(SQL,"/ROWS="_rows_"/SAVECUR",.stat,.rowdata,.cnt)
	.	;I ER!(cnt)=0 S DONE=1
	.	I ER!(cnt=0) S DONE=1	;WVB - 28755
	.	E  S rownum=1
	S row=$P(rowdata,$C(13,10),rownum),rownum=rownum+1
	Q 1					; Data returned
	;
	;----------------------------------------------------------------------
INSCMD(column,data) ; Private ; Return SQL INSERT command
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;	. column	Column names	/TYP=T/REQ/MECH=VAL
	;       . data          Column values	/TYP=T/REQ/MECH=VAL
	;
	; RETURN:
	;	$$		SQL INSERT command
	;
	; EXAMPLE:
	;
	;       $$INSCMD("AD1,AD2,CITY","line 1"_$C(9,9)_"MALVERN")
	;         
	;       (AD1,AD2,CITY) VALUES ('line 1','NULL','MALVERN')
	;
	;----------------------------------------------------------------------
	N i,v,v1
	S v=""
	F i=1:1:$L(data,$C(9)) D
	.	S v1=$P(data,$C(9),i)				; Column value
	.	I $P(data,$C(9),i)'="" S v=v_",'"_v1_"'" Q
	.	S v=v_",NULL"					; NULL value
	Q "("_column_") VALUES ("_$E(v,2,9999)_")"
	;
	;----------------------------------------------------------------------
UPDCMD(column,data) ; Private ; Return SQL UPDATE command
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;	. column	Column names	/TYP=T/REQ/MECH=VAL
	;       . data          Column values	/TYP=T/REQ/MECH=VAL
	;
	; RETURN:
	;	$$		SQL UPDATE command
	;
	; EXAMPLE:
	;
	;       $$INSCMD("AD1,AD2,CITY","line 1"_$C(9,9)_"MALVERN")
	;       
	;	SET AD1='line1',AD2=NULL,CITY='MALVERN'
	;----------------------------------------------------------------------
	N i,v,v1,v2
	S v="SET "
	F i=1:1:$L(data,$C(9)) D
	.	S v1=$P(data,$C(9),i)				; Column value
	.	I v1'="" S v2="'"_v1_"'"
	.	E  S v2="NULL"					; NULL value
	.	S v=v_$P(column,",",i)_"="_v2_","
	Q $E(v,1,$L(v)-1)
	;
	;----------------------------------------------------------------------
SQLTOSHR(SQL,FID,UX)       ;Public;Convert SQL command to file Local Array 
        ;----------------------------------------------------------------------
        ;
        ; This function uses a  sql command as input and executes that command
        ; to update a Local Array. The file definition name is passed from
        ; the calling routine in order to define the data items.  The Local
        ; array is never loaded from disk if it is not currently loaded.
        ;
        ;
        ; KEYWORDS:
        ; 
        ; ARGUMENTS:
        ;       . SQL   SQL command             /TYP=T/REQ/MECH=VAL
        ;
        ;       . FID   file definition         /TYP=T/REQ/MECH=VAL
	;
	;	. UX	UX array returned	/TYP=T/NOREQ/MECH=REF
	;               UX array will be returned if
	;               passed in
        ;
        ; INPUTS:
        ;
        ; RETURNS:
        ;       .     Local Array of FID containing changed values
        ;
        ; RELATED:
        ;       . $$func^rtn - description of how related
        ;
        ; EXAMPLE:
        ;       $$SQLTOSHR^TEST1("UPDATE DEP SET BAL=123 WHERE CID=1234","DEP")
        ;   returns DEP(51)=123
        ;
        ;
        N DI,I,EXPR,ND,PC,VAL,X,TESTVAL,tok
        S ER=0
        S TESTVAL=FID_"."
        S SQL=$P($P(SQL,"SET ",2)," WHERE",1)
        F I=1:1:$L(SQL,"=")-1 D  Q:ER
        .       S DI=$P(SQL,"=",I)
        .       I I>1 S DI=$P(DI,",",$L(DI,","))
        .       S DI=$TR(DI,"'","")
        .       I $E(DI,1,$L(FID)+1)=TESTVAL S DI=$E(DI,$L(FID)+2,1000)
	.	S DI=$TR(DI," ","")
        .       S EXPR=$$PARSE^SQLDD(FID_"."_DI)
        .       I ER Q
        .       S VAL=$P(SQL,"=",I+1)
	.	I VAL["'" S VAL=$$TOKEN^%ZS(VAL,.tok,"'")		; LJS 05/16/01
	.	I VAL["""" S VAL=$$TOKEN^%ZS(VAL,.tok)		; LJS 05/16/01
	.	I $L(VAL,",")>1 S VAL=$P(VAL,",",1,$L(VAL,",")-1) 	; LJS
	.	I VAL[$C(0) S VAL=$$UNTOK^%ZS(VAL,.tok) I "'"""[$E(VAL) S VAL=$$QSUB^%ZS(VAL,$E(VAL))   ; LJS
        .       S VAL=$TR(VAL,"'","")		
        .       S VAL=$$QSUB^%ZS(VAL)			
        .       S EXPR="S "_EXPR_"="""_VAL_"""" 	
        .       X EXPR					
	.	;
	.	; Create UX array
	.	N X,ND,PC
	.	S X=$$DI^SQLDD(FID_"."_DI)
	.	S ND=$P(X,"|",1),PC=$P(X,"|",21)
	.	I ND'["*" S UX(FID,DI)="|"_VAL_"|"_ND_"|"_PC	;9/23/97 mas
        Q ER
	;
	;----------------------------------------------------------------------
NVL(T,D)	;Public; Null value default
	;----------------------------------------------------------------------
	;
	; Returns D if T is Null.  This will be used by PROFILE/SQL scalar
	; function NVL.  (Select NVL(CRCD,'USD') from HIST)
	;
	; KEYWORDS:	SQL
	;
	; ARGUMENTS:
	;     . T	Text string			/TYP=T/REQ/MECH=VAL
	;
	;     . D	Default value			/TYP=T/REQ/MECH=VAL
	;
	; RETURNS:
	;     . $$	Formatted string		/TYP=T
	;
	; EXAMPLE:
	;     $$NVL^SQLFUNCS("","HELLO")="HELLO"
	;----------------------------------------------------------------------
	Q $S(T'="":T,1:$G(D))
	;
	;----------------------------------------------------------------------
DECODE(P1,P2,P3,P4,P5,P6,P7,P8)	; Public; PROFILE/SQL DECODE scalar function
	;----------------------------------------------------------------------
	;
	; Determines whether the value of P1 is equal to the value of either
	; P2,P4 or P6.  If the value equals either P2, P4 or P6, then the
	; value of the function is equal to the value of the next parameter.
	; If P1 does not equal one of the others, then the value of the
	; function will be either the last position if it's even or NULL.
	; This will be used by PROFILE/SQL scalar function DECODE.
	; (Select DECODE(TYPE,0,'Individual','1',Corporate') from CIF)
	;
	; KEYWORDS:	SQL
	;
	; ARGUMENTS:
	;     . P1	Test Value			/TYP=T/REQ/MECH=VAL
	;
	;     . P2	Choice 1			/TYP=T/REQ/MECH=VAL
	;
	;     . P3	Return 1			/TYP=T/REQ/MECH=VAL
	;
	; RETURNS:
	;     . $$	Formatted string		/TYP=T
	;
	; EXAMPLE:
	;     $$DECODE^SQLFUNCS(0,0,"Individual",1,"Corporate")="Individual"
	;     $$DECODE^SQLFUNCS(1,0,"Individual",1,"Corporate")="Corporate"
	;     $$DECODE^SQLFUNCS(2,0,"Individual",1,"Corporate")=""
	;     $$DECODE^SQLFUNCS(3,0,"Individual",1,"Corporate","Other")="Other"
	;----------------------------------------------------------------------
	N expr,ret
	S expr="S ret=$S(P1=P2:P3,"
	I $G(P4)="" S expr=expr_"1:"""")" X expr Q ret
	I $G(P5)="" S expr=expr_"1:P4)" X expr Q ret
	S expr=expr_"P1=P4:P5,"
	I $G(P6)="" S expr=expr_"1:"""")" X expr Q ret
	I $G(P7)="" S expr=expr_"1:P6)" X expr Q ret
	S expr=expr_"P1=P6:P7,"
	I $G(P8)="" S expr=expr_"1:"""")" X expr Q ret
	S expr=expr_"1:P8)"
	X expr
	Q ret
	;
	;----------------------------------------------------------------------
ROUND(N,D)	;Public; PROFILE/SQL ROUND scalar function
	;----------------------------------------------------------------------
	;
	; Rounds N to a specified number of decimal spaces, D.  Omitting
	; D is equal to specifying 0.  If the second parameter is negative,
	; the value is rounded to the left of the decimal point.  This will
	; be used by PROFILE/SQL scalar function ROUND.
	; (Select ROUND(POSACR,2) from DEP)
	;
	; KEYWORDS:	SQL
	;
	; ARGUMENTS:
	;     . N	Amount field			/TYP=N/REQ/MECH=VAL
	;
	;     . D	Decimal precision		/TYP=N/DFT=0/MECH=VAL
	;
	; RETURNS:
	;     . $$	Rounded value			/TYP=N
	;
	; EXAMPLE:
	;     $$ROUND^SQLFUNCS("123.456",2)=123.46
	;     $$ROUND^SQLFUNCS("123.456",0)=123
	;     $$ROUND^SQLFUNCS("123.456",-2)=100
	;----------------------------------------------------------------------
	I +$G(N)=0 Q 0
	S D=+$G(D)
	I D'<0 Q $$^SCARND(N,,,,D)
	S D=D*-1
	N fac S fac=1_$E("00000000",1,D)
	Q $$^SCARND(N/fac,,,,0)*fac
	;
	;----------------------------------------------------------------------
SIGN(N)	;Public; PROFILE/SQL SIGN scalar function
	;----------------------------------------------------------------------
	;
	; Returns a number representing the mathematical sign of a numeric
	; expression.  This will be used by PROFILE/SQL scalar function SIGN.
	; (Select SIGN(BAL) from DEP)
	;
	; KEYWORDS:	SQL
	;
	; ARGUMENTS:
	;     . N	Numeric expression		/TYP=N/REQ/MECH=VAL
	;
	; RETURNS:
	;     . $$	Mathematical sign		/TYP=N
	;
	; EXAMPLE:
	;     $$SIGN^SQLFUNCS(50)=1
	;     $$SIGN^SQLFUNCS(0)=0
	;     $$SIGN^SQLFUNCS(-50)=-1
	;----------------------------------------------------------------------
	Q $S(N>0:1,+N=0:0,1:-1)
	;
