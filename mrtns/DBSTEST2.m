DBSTEST2	;; -  - V5.0
	;;Copyright(c)1998 Sanchez Computer Associates, Inc.  All Rights Reserved - 07/15/98 08:55:35 - NIB
	;     ORIG:  CHIANG - 16 JUL 1992
	;CALLED BY:  
	;    CALLS:  ^%TRMVT,^DBSTBL,^UTLREAD
	;     DESC:  Utility for DEMO/QA routine DBSTBL (look-up table)
	;
        ; I18N=QUIT: Exculded from I18N standards.
	;---------- Revision History -------------------------------------------
	;
	; 07/15/98 - Betty Ni - 29370
	;	     Add code to eliminate $TEXT function.
	;
	; 01/09/95 - Bob Chiang - 17591
	;            Added logic to test lookup table :DISTINCT qualifier.
	;
	;-----------------------------------------------------------------------
	;
	N X,Y,Z,MSG,MS1,XYZ,%,TJD,OLNTB,DOC
	;
	; ---------- Display documentation
	;
	;
	S DOC(1)=""
	S DOC(2)="                        DATA-QWIK LOOKUP TABLE SYNTAX"
	S DOC(3)="                       ==============================="
	S DOC(4)="+-------------------------------------------------------------------------+"
	S DOC(5)="|    Type         |  Syntax                 | Example                     |"
	S DOC(6)="+-----------------+-------------------------+-----------------------------+"
	S DOC(7)="|    M Global     | ^gbl(                   | ^CIF(                       |"
	S DOC(8)="|                 | ^gbl(key1,key2,...      | ^UTBL(""BRCD"",               |"
	S DOC(9)="|                 |                         | ^DBTBL(%LIBS,1,             |"
	S DOC(10)="|                 |                         | ^DBTBL(%LIBS,1,""DEP"",#10    |"
	S DOC(11)="+-----------------+-------------------------+-----------------------------+"
	S DOC(12)="|  Local Array    | array(                  | TYPE(                       |"
	S DOC(13)="|                 |                         | POTION(""A"",                 |"
	S DOC(14)="+-----------------+-------------------------+-----------------------------+"
	S DOC(15)="|  Pick List      | ,OP1#DESC1,OP2#DESC2... | ,C#Create,M#Modify,L#List   |"
	S DOC(16)="+-----------------+-------------------------+-----------------------------+"
	S DOC(17)="|  Pre-processor  | @tag^routine            | VERIFY^XYZ                  |"
	S DOC(18)="|  (Callback)     |                         |                             |"
	S DOC(19)="+-----------------+-------------------------+-----------------------------+"
	S DOC(20)="|  DQ Directory   | [fid]dinam/keyword=,... | [DEP]CID,LNM,BOO            |"
	S DOC(21)="|                 |                         |                             |"
	S DOC(22)="|                 | Valid Keyword:          |                             |"
	S DOC(23)="|                 |                         |                             |"
	S DOC(24)="|                 |   /LEN Field Length     | [CIF]ACN,DOB/LE=15,AGE      |"
	S DOC(25)="|                 |   /RHD Column Heading   | [DEP]CID,LNM,[CIF]TAXID     |"
	S DOC(26)="|                 |   /TYP Format Type      | [DEP]CID/RH=Account,BOO     |"
	S DOC(27)="|                 |                         | [DEP]CID/TY=T,LNM/LE=20     |"
	S DOC(28)="+-----------------+-------------------------+-----------------------------+"
	S DOC(29)=""
	S DOC(30)="                         VALID PARAMETERS"
	S DOC(31)=""
	S DOC(32)="+-------------------------------------------------------------------------+"
	S DOC(33)="| Type                |   Syntax           | Example                      |"
	S DOC(34)="+---------------------+--------------------+------------------------------+"
	S DOC(35)="| Descending Order    |   :DESCEND         | ^CIF(:DESC                   |"
	S DOC(36)="|                     |                    | ^UTBL(""BRCD"",:DESC         |"
	S DOC(37)="|                     |                    | [DEP]CID,BAL,LNM:DESC        |"
	S DOC(38)="+---------------------+--------------------+------------------------------+"
	S DOC(39)="| Multi-Item Selection|   :LIST            | ^DBTBL(%LIBS,1,:LIST         |"
	S DOC(40)="|                     |                    | [DEP]CID,LNM:LIST            |"
	S DOC(41)="|                     |   :LIST n          |                              |"
	S DOC(42)="|                     |                    |                              |"
	S DOC(43)="|                     |  Limit to n entrie | [DEP]CID,BOO:LIST 3          |"
	S DOC(44)="+---------------------+--------------------+------------------------------+"
	S DOC(45)="| No Validation       |   :NOVALIDATE      | ^ACN(:NOVAL                  |"
	S DOC(46)="|                     |                    |                              |"
	S DOC(47)="|                     |                    | S %READ=                     |"
	S DOC(48)="|                     |                    | ""[DEPCID/TBL=[DEP]CID,LNM"" |"
	S DOC(49)="|                     |                    |I '%O S %READ=%READ_"":NOVAL""|"
	S DOC(50)="+---------------------+--------------------+------------------------------+"
        S DOC(51)="| DQ Query Syntax     |   :QUERY var       | S XYZ=""[DEP]BAL>1000""      |"  
	S DOC(52)="|                     |                    |                              |"
	S DOC(53)="|                     |                    | [DEP]CID,BAL,BOO:QUERY XYZ   |"
	S DOC(54)="|                     |                    |                              |"
	S DOC(55)="|                     |   :QUERY var(#)    | S XYZ(1)=""[DEP]BAL>1000""   |"
	S DOC(56)="|                     |              ^     | S XYZ(2)=""[DEP]BOO=2""      |"
	S DOC(57)="|                     |              |     |                              |"
	S DOC(58)="|                     |           array    | [DEP]CID,BAL,BOO:QU XYZ(#)   |"
	S DOC(59)="+---------------------+--------------------+------------------------------+"
	S DOC(60)="| Unique value        |   :DISTINCT        | [DEP]GRP,TYPE:DISTINCT       |"
	S DOC(61)="|                     |                    | [LN]GRP,TYPE:DISTINCT        |"
	S DOC(62)="|                     |                    | [HIST]CID:DISTINCT           |"
	S DOC(63)="|                     |                    | S XYZ=""[DEP]GRP=DDA""       |"
	S DOC(64)="|                     |                    | [DEP]TYPE:DISTINCT:QU XYZ    |"
	S DOC(65)="+---------------------+--------------------+------------------------------+"
	S DOC(66)=""
	;
	;
	D ^DBSHLP("DOC(")
	;
	K DOC
	;
	; Continue?
	I '$$YN^DBSMBAR("","Continue?",1) Q	; *** BC - 11/05/93
	;
	I $G(%LIBS)="" S %LIBS=^CUVAR("%LIBS")
	;
	S %="|",TJD=+$H
	I $G(%UCLS)="" N %UCLS S %UCLS="SCA"
	S MS1="LOOK-UP TABLE SYNTAX"
	;
	S MSG(1)="  Global Format: ^gbl(                 CIF number"
	S SYNTAX="^CIF(" Q:'$$DSP()
	;
	S MSG(1)="  Global Format: ^gbl(                 BRANCH CODE"
	S SYNTAX="^UTBL(""BRCD""," Q:'$$DSP()
	;
	S MSG(1)="  Global Format: ^gbl(                 DQ FILES"
	S SYNTAX="^DBTBL(%LIBS,1," Q:'$$DSP()
	;
	S MSG(1)=" Global Format: ^gbl(k1,...,#P"
	S MSG(2)="                             ^---- field position with | delimiter"
	S MSG(3)=""
	S SYNTAX="^DBTBL(""SYSDEV"",1,""DEP"",9,#10" Q:'$$DSP()
	;
	;---------------------------------- Local format ----------------------
	;
	S MSG(1)=" Local Format: array("
	S MSG(2)=""
	S MSG(3)="Example:"
	S MSG(4)="          S OP(1)=""CREATE"",OP(2)=""MODIFY"",OP(3)=""DELETE"""
	;
	S OP(1)="CREATE",OP(2)="MODIFY",OP(3)="DELETE"
	S SYNTAX="OP(" Q:'$$DSP()
	;
	; --------------------------------- Pick List --------------------------
	;
	S MSG(1)="      Pick List Format: ,op1#desc1,op2#desc2,..."
	S MSG(2)="                        ^   ^"
	S MSG(3)="                        |   |_____________ field delimiter"
	S MSG(4)="                        __________________ option separator"
	;
	S SYNTAX=",C#CREATE,M#MODIFY,D#DELETE,L#LIST" Q:'$$DSP()
	;
	;
	; --------------------------------- [FID]DI SYNTAX ---------------------
	;
	K MSG
	S MSG(1)=" Data Dictionary Format: [FID]DI     Single File"
	S SYNTAX="[DEP]CID/RH=Account,LNM,BOO" Q:'$$DSP()
	;
	S MSG(1)=" Data Dictionary Format: [FID]DI     Computed Item"
	;
	S SYNTAX="[CIF]ACN,TAXID,DOB/LE=15,AGE,TDB/LE=25" Q:'$$DSP()
	;
	S MSG(1)=" Data Dictionary Format: [FID]DI     Multiple Files"
	S SYNTAX="[DEP]CID/RH=Account,LNM,BOO,[CIF]TAXID"
	Q:'$$DSP()
	;
	; ---------- /LE , /RH , /TY options
	;
	S MSG(1)=" Data Dictionary Format: [FID]DI     With / options"
	S MSG(2)=""
	S MSG(3)="   /LEN  Field Length"
	S MSG(4)="   /RHD  Field Column Heading"
	S MSG(5)="   /TYP  Field Format Type"
	;
	S SYNTAX="[DEP]CID/LE=8/TY=T/RH=Account,[DEP]LNM/LE=15/RH=Name,BOO"
	Q:'$$DSP()
	K MSG
	;
	S MSG(1)="Table Lookup Parameters"
	S MSG(2)=""
	S MSG(3)=" : DESCEND     Display Table In Descending Order"
	S MSG(4)=" : LIST        Multi-Item Selection"
	S MSG(5)=" : NOVALIDATE  Conditional Input Validation"
	S MSG(6)=" : QUERY       Query Definition (DQ query syntax)"
	;
	K SYNTAX Q:'$$DSP()
	;
	; ---------- :DESC option  (descending Display Qualifier)
	;
	K MSG
	S MSG(1)="  :DESC   Descending Display Qualifier)"
	S SYNTAX="[DEP]CID/LE=16,BAL/LE=16,LNM:DESC" Q:'$$DSP()
	;
	S SYNTAX="^ACN(:DESC" Q:'$$DSP()
	;
	; ---------- :LIST option
	;
	K MSG
	S MSG(1)="  :LIST    Multiple Selections (use INSERT/REMOVE key)"
	S SYNTAX="[DEP]CID/RH=Account,LNM:LIST" Q:'$$DSP()
	;
	S SYNTAX="^DBTBL(%LIBS,1,:LIST" Q:'$$DSP()
	;
	S SYNTAX="^DBTBL(""SYSDEV"",1,""DEP"",9,#10:LIST" Q:'$$DSP()
	;
	S MSG(1)="  :LIST n  Limit to n Entries"
	S SYNTAX="[DEP]CID/RH=Account,LNM:LIST 3" Q:'$$DSP()
A	;
	; ---------- :NOVAL
	;
	S MSG(1)="  :NOVALIDATE     Conditional Input Validation"
	S MSG(2)=""
	S MSG(3)="  Example:   S %READ=""[DEP]CID/TBL=[DEP]CID/RH=Account,LNM"""
	S MSG(4)="             I '%O S %READ=%READ_"":NOVAL"""
	S MSG(5)="             D ^UTLREAD"
	S MSG(6)=""
	S MSG(7)="                 Account Number: ____________"
	;
	S SYNTAX="[DEP]CID/RH=Account,LNM:NOVAL" Q:'$$DSP()
	K MSG
	;
	; ---------- :QUERY
	;
	S MSG(1)="  :QUERY var        Query Command in DQ query syntax"
	S MSG(2)="",MSG(3)="Example:  S XYZ=""[DEP]BAL>1000"""
	S XYZ="[DEP]BAL>1000"
	S SYNTAX="[DEP]CID/RH=Account,BAL/RH=Balance,LNM,BOO:QUERY XYZ" Q:'$$DSP()
	;
	S MSG(1)="  :QUERY  var       Query Command in DQ query syntax"
	S MSG(2)="",MSG(3)="Example:  S XYZ=""[DEP]BAL>100000 OR [DEP]BOO=2"""
	S XYZ="[DEP]BAL>100000 OR [DEP]BOO=2"
	;
	S SYNTAX="[DEP]CID/RH=Account,BAL/RH=Balance,LNM,BOO:QUERY XYZ"
	Q:'$$DSP() 
	;
	; ---------- Function NONDOCB2 ----------
	;
	S SRC="NDPO"
	S MSG(1)="  :QUERY  var       Query Command in DQ query syntax"
	S MSG(2)=""
	;
	S EFTQRY="[EFTPAY]STATUS=V,M AND [EFTPAY]EFTTYPE=<<SRC>>"
	S MSG(3)="Example: "_EFTQRY
	;
	S SYNTAX="[EFTREF]REFNO,[EFTREF]CID,[EFTREF]SEQ,[EFTPAY]EFD,[EFTPAY]AMOUNT,[EFTPAY]CRCD,[EFTPAY]STATUS:QU EFTQRY"
	Q:'$$DSP()
	;----------------------------------------------------------------------
	;
	S MSG(1)="  :QUERY var(#)     (multiple AND conditions)"
	S MSG(2)="             ^"
	S MSG(3)="             |__________ array syntax"
	S MSG(4)=""
	S MSG(5)="Example:  S ABC(1)=""[DEP]BAL>1000"""
	S MSG(6)="          S ABC(2)=""[DEP]BOO=1"""
	K ABC S ABC(1)="[DEP]BAL>1000",ABC(2)="[DEP]BOO=1"
	S SYNTAX="[DEP]CID/RH=Account,BAL/RH=Balance,LNM,BOO:QUERY ABC(#)"
	Q:'$$DSP()
	;
	; ---------- Partial CRTHLP listing ----------
	;
	S CLS="D",GRP="DDA"
        S QRY(1)="[XTRN]CLS=D"
        S QRY(2)="[XTRN]GRP=DDA" 
	S QRY(3)="[XTRN]SGT=0"				
	S QRY(4)="[XTRN]UCLS=1"
	S QRY(5)="[XTRN]ETC'>ZZZZZZZZZ"
	F I=1:1:5 S MSG(I)=" S QRY("_I_")="_""""_QRY(I)_""""
        S SYNTAX="[XTRN]ETC/LEN=16,[TRN]DES:QUERY QRY(#)"
	Q:'$$DSP()
	K QRY,CLS,GRP,MSG
	;
	; ---------- :DISTINCT qualifier
	;
	K MSG
	S MSG(1)=" :DISTINCT qualifier"
	S SYNTAX="[DEP]GRP,CLS:DISTINCT"
	Q:'$$DSP()
	S MSG(1)=" :DISTINCT qualifier"
	S SYNTAX="[LN]GRP,CLS:DISTINCT"
	Q:'$$DSP()
	S MSG(1)=" :DISTINCT qualifier"
	S SYNTAX="[DEP]TYPE,GRP:DISTINCT:QUERY ""[DEP]GRP=""DDA"""
	Q:'$$DSP()
	S MSG(1)=" :DISTINCT qualifier"
	S SYNTAX="[HIST]CID:DISTINCT"
	Q:'$$DSP()
	;----------------------------------------------------------------------
	;
	Q
DSP()	;
	N OLNTB
	S %READ="@MS1/REV/CEN,"
   	I $D(MSG) S I="" F  S I=$O(MSG(I)) Q:I=""  DO
	.	S MSG(I)=MSG(I)_$J("",80-$L(MSG(I)))	; 80 column message
	.	S %READ=%READ_",@MSG("_I_")"
	I $G(SYNTAX)'="" S %READ=%READ_",,@SYNTAX/INC/CEN"
	S %NOPRMT="F",%FRAME=2				; *** BC - Frame option
	D ^UTLREAD
	;
	I $G(SYNTAX)="" W $$MSG^%TRMVT("","",1) Q 1
	;
	S OLNTB=13001
	S X=$$^DBSTBL(SYNTAX)
	I ER S RM=$ZS W $$MSG^%TRMVT(RM,"",1) Q 1
	;
	; Value selected:  ~p1 
	S Y="" I X'="" S Y="Value selected: "_X_" "
	; Continue?
	S Y=Y_"Continue?"			; ***
	Q $$YN^DBSMBAR("",Y,1)
	;
