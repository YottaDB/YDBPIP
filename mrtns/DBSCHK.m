DBSCHK	;;DBS - U - V5.0 - CONVERT DATA ITEM INTO MUMPS INTERNAL REFERENCE  
	;;Copyright(c)1996 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/23/96 09:40:43 - CHIANG
	;     ORIG:  CHIANG - 7/28/88   Based on program DBSDITR by FRS
	;     DESC: Convert data item syntax [FID]DI to short name format
	;
	;             [DEP]BAL    -->    $P(DEP(51),"|",1)
	;
	; INPUT  :     DINAM   - DATA ITEM REFERENCE  [LIB,FID]DI or [FID]DI
	;                      - SWITCH FILE ID ONLY  [FID]
	;
	;              DFID    - DEFAULT FILE ID ( optional )
	;              DLIB    - DEFAULT LIBRARY NAME ( optional )
	;
	; OUTPUT :     ER      - ERROR MESSAGE (NULL OR MESSAGE)
	;              DI      - DATA ITEM SHORT NAME
	;              DILNM   - DATA ITEM LONG NAME
	;              NS      - TRANSLATED STRING DATA 
	;              LOOP()  - VLOD section
	;              COMP()  - VCOM section
	;              DFV()   - VDEF section
	;
	;---- Revision History ------------------------------------------------
	; 05/17/06 - Pete Chenard - CR21340
	;	     Modified PARSE section to reset ER="" if ER is set to 0
	;	     when calling fsn^DBSDD.  This routine expects ER to be an 
	;	     empty string if no errors are encountered.
	;	     If this routine ever gets converted to PSL, the logic may be
	;	     changed to handle error conditions in a more standard way.
	;
	; 02/14/06 - RussellDS - CR19065
	;	     Change reference to delimiter to use DBTBL1, not the 
	;	     obsoleted delimiter from DBTBL1D.
	;
	; 10/23/96 - Bob Chiang - 20948
	;            Modified PARSE section to get missing field delimiter from
	;            the file attribute.
	;
	; 10/27/94 - Bob Chiang - ARQ 18
	;            Removed calls to $$^MSG.
	;
	; 05/10/95 - Bob Chiang - I18N#7
	;
	;            Modified return message handling with a call to extrinsic
	;            function $$^MSG(msgid,p1,p2...) for I18N development
	;            (phrase independence).
	;
	; 04/15/94  Bob Chiang - Trackware
	;
	;           Modified to add $G() checking for run-time data item
	;           expression based on a variable 'undefchk'.
	;
	;           Example:  DINAME="[DEP]BAL"  returns $P(DEP(51),"|",1)
	;                     with undefchk=1    returns $P($G(DEP(51)),"|",1)
	;
	; 04/19/93  Bob Chiang - Trackware
	;
	;           Modified to support <<[FID]DI>> or <<FID.DI>> field
	;           default syntax.  
	;
	;-----------------------------------------------------------------------
	;   I18N=QUIT : Excluded From I18N Standards 
START	;
	N ZFLAG,ZCOMP
	S ER="",ZFLAG=0,ZCOMP=0,Q=$C(34)
	;
	; Invalid parameter
	I '$D(DINAM) S ER=1,RM=$$^MSG(1417,DINAM) G EXIT
	;
	I DINAM'["[" S DINAM="["_$G(DFID)_"]"_DINAM
	;
	D PARSE(DINAM)
	;
	I $P(NS,$C(0),1)'="" S NS=$P(NS,$C(0),1)
	E  S NS=$P(NS,$C(0),2)
	;
	; Set up COMP() array for building VCOM section
	;
	I 'ZCOMP Q
	I NS'="" S COMP(DI)=NS
	E  S COMP(DI)=""""""
	I $G(undefchk) S NS="$G("_DI_")" Q	; *** BC - support $G logic
	S NS=DI
	Q
	;
	;
PARSE(DINAM)	;
	;
	N (FILES,%LIBS,ER,RM,DLIB,DFID,DINAM,DILNM,DI,NS,LOOP,DFV,COMP,ZFLAG,ZCOMP,undefchk)
	;
	S NU=$C(0) ; Function<NU>Command<NU>Dataitem
	S SH=$C(1) ; Function<SH>Function<NU>Command<SH>Command<NU>Dataitem<SH>...
	;
	S X=$P($P(DINAM,"]",1),"[",2)
	S DATAITEM=$P(DINAM,"]",2)
	S FILENAME=$P(X,",",2),LIBRARY=$P(X,",",1)
	I FILENAME="",LIBRARY'="" S FILENAME=LIBRARY,LIBRARY=""
	I LIBRARY="" S LIBRARY=$$LIBRARY
	;
	; File name not defined
	I FILENAME="" S ER=1,RM=$$^MSG("1087") G EXIT
	; Library not defined
	I LIBRARY="" S ER=1,RM=$$^MSG("1606") G EXIT
	; Data item not defined
	I DATAITEM="" S ER=1,RM=$$^MSG("732") G EXIT
	;
	;
	S X=$P($G(^DBTBL(LIBRARY,1,FILENAME,10)),"|",5) ; Implicit ?
	I X'="" S LIBRARY=$E($P(X,",",1),2,20) ; Source library
	;
	I $G(FILES)'="" I ","_FILES_","'[(","_FILENAME_",") D ERROR G EXIT
	;
	S X=$G(^DBTBL(LIBRARY,1,FILENAME,9,DATAITEM))
	;
	I X="" D ERROR G EXIT
	;
	; Data Item Long Name
	;
	I 'ZFLAG S DILNM=$P(X,"|",10),DI=DATAITEM,ZFLAG=1
	;
	S DEFAULT=$P(X,"|",3),POS=$P(X,"|",21)+0
	S DELIM=""			; Force to get delimiter from file
	;
	I DELIM="",POS D				; *** 10/23/96
	.	D fsn^DBSDD(.fsn,FILENAME)		; Get delimiter
	.	I ER=0 S ER=""				; if no error reset ER=""
	.	S DELIM=$P(fsn(FILENAME),"|",10)	; from file attribute
	.	S $P(X,"|",20)=DELIM
	;
	S STRLOC=$P(X,"|",18),STRLEN=$P(X,"|",19)+0,DATATYPE=$P(X,"|",11)
	;
	; ---------- sub-field   $P([fid]di,del,pos)
	;
	I $P(X,"|",1)?1"["1E.E1"]"1E.E DO
	.	;
	.	N X16 S X16=$P(X,"|",1),$P(X,"|",1)=""
	.	I DELIM'="" S X16="$P("_X16_","_""""_$C(DELIM)_""""_","_POS_")"
	.	I STRLOC S X16="$E("_X16_","_STRLOC_","_(STRLOC+STRLEN-1)_")"
	.	I DATATYPE?1"B"1N S Z=$E(DATATYPE,2) DO
	..	S Z=$P("1/2/4/8/16/32/64/128","/",Z),X16="$A("_X16_")\"_Z_"#2"
	.	S $P(X,"|",16)=X16
	.	;
	;
	; Computed Operation
	;
	I $P(X,"|",1)="" S NS=$$COMPUTED($P(X,"|",16)) G EXIT
	;
	; Normal Data Item Syntax
	;
	S ARRAY=^DBTBL(LIBRARY,1,FILENAME,12) ; The local array name
	;
	S NODE=$P(X,"|",1)
	S DEFAULT=$P(X,"|",3),DELIM=$P(X,"|",20),POS=$P(X,"|",21)+0
	I DEFAULT?1"["1E.E1"]"1E.E S DEFAULT="" ;	V 4.3 (disabled)
	I $P(X,"|",17)'="" S LOOP(-3,FILENAME,DATAITEM)=""
	;
	; Set Up LOOP array
	;
	I '$D(LOOP(-1,FILENAME)) DO
	.	;
	.	N z
	.	S z=$P($P(^(100),"|",1),"(",2),KEYS=""
	.	F I=1:1:$L(z,",") S KEYS=KEYS_$P(z,",",I)_"|"
	.	S LOOP(ARRAY)=KEYS,LOOP(-1,FILENAME)=ARRAY
	.	;
	E  s KEYS=LOOP(ARRAY)
	S bkey=$C(34)_$P(KEYS,"|",$L(KEYS,"|")-1)_$C(34)
	;
	; Access Keys -- no translation required
	;
	I $P(X,"|",1)["*" D  G EXIT			; *** BC - modified to add $G() checking
	.	I '$G(undefchk) S NS=DATAITEM Q
	.	E  S NS="$G("_DATAITEM_")"
	;
	; Set Up field id for building VLOD section
	;
	I 'DELIM!(DEFAULT?1"["1AP.AN1"]".E) S $P(LOOP(ARRAY,NODE),"|",1)=DEFAULT
	E  S $P(LOOP(ARRAY,NODE),$C(DELIM),POS)=DEFAULT
	;
	I NODE'=+NODE S NODE=""""_NODE_""""
	;
	; Set up default value for building VDEF section ( screen only )
	;
	I $G(undefchk) S NS="$G("_ARRAY_"("_NODE_"))"	; *** BC - add $G logic
	E  S NS=ARRAY_"("_NODE_")"
	I $P(DINAM,"]",1)'["CUVAR",$E(NODE)=$C(34),NODE=bkey D
	.	I '$G(undefchk) S NS=ARRAY		; *** BC - 04/15/94
	.	E  S NS="$G("_ARRAY_")"			; ***
	;
	I DEFAULT=""!(DEFAULT["[") G VALUE
	I 'DELIM S Z=NS_"="
	E  S Z=$C(DELIM),Z="$P("_NS_","_""""_Z_""""_","_POS_")="
	;
	;------ Convert <<fid.di>> to $$RETVAL^DBSDD(fid.di)  04/19/93 BC
	;
	S XDF=DEFAULT I XDF?1"<<"1E.E1">>" S XDF=$P(XDF,"<<",2),XDF=$P(XDF,">>",1)
	E  S XDF=""""_XDF_""""
	I XDF?1"["1A.AN1"]"1A.AN!(XDF?1A.AN1"."1A.AN) S XDF="$$RETVAL^DBSDD("_""""_XDF_""""_")"
	S DFV(FILENAME_"."_DI)=" I "_Z_""""_""""_" S "_Z_XDF
	;
VALUE	;
	;
	; Field Delimiter
	;
	I DELIM S NS="$P("_NS_","""_$C(DELIM)_""","_POS_")"
	G EXIT
	;
	;
LIBRARY()	; Define current library
	;
	;
	I $G(DLIB)'="" Q DLIB
	;
	I $G(%LIBS)'="" Q %LIBS
	;
	; Default to system parameter
	;
	Q $G(^CUVAR("%LIBS"))
	;
COMPUTED(COMPUTED)	; Decode computed data items
	;
	S ZCOMP=1
	;
	;
	S Y=0 ; Replace all ",$C(124)," strings with ",""|"","
	F  S Y=$F(COMPUTED,",$C(124),",Y) Q:Y=0  S COMPUTED=$E(COMPUTED,1,Y-10)_",""|"","_$E(COMPUTED,Y,999)
	;
COMPA	;
	;
	S DINAM=$$FINDINAM($P(COMPUTED,NU,1))
	I DINAM="" DO  Q COMPUTED
	.	I (($E(COMPUTED,1,3)="($$")!($E(COMPUTED,1,2)="$$")!($E(COMPUTED,1,2)?1A1" ")) S COMPUTED=NU_COMPUTED
	D PARSE(DINAM) S X=NS I ER'="" Q ""
	;
	; Save all routine calls
	;
	I NS[NU,$P(NS,NU,2)'="",$P(NS,NU,3)="" S COMP($P(DINAM,"]",2))=$P($P(NS,NU,2),SH,1)
	;
	I X[NU D NESTED
	;
	I X="" S COMPUTED=$P(COMPUTED,DINAM,1)_$P(DINAM,"]",2)_$P(COMPUTED,DINAM,2,99),$P(COMPUTED,NU,2)=$P(COMPUTED,NU,2)_SH
	
	E  S COMPUTED=$P(COMPUTED,DINAM,1)_X_$P(COMPUTED,DINAM,2,99)
	I $P(COMPUTED,NU,3)'[DINAM S $P(COMPUTED,NU,3)=$P(COMPUTED,NU,3)_DINAM_SH
	G COMPA
	;
NESTED	; Nested computed operations !!!
	;
	I $P(X,NU,2)'="",$P(COMPUTED,NU,2)'[$P(X,NU,2) S $P(COMPUTED,NU,2)=$P(COMPUTED,NU,2)_$P(X,NU,2)
	I $P(X,NU,3)'="",$P(COMPUTED,NU,3)'[$P(X,NU,3) S $P(COMPUTED,NU,3)=$P(COMPUTED,NU,3)_$P(X,NU,3)
	S X=$P(X,NU,1)
	Q
	;
FINDINAM(X)	; Find the first data item in this string
	;
	N (X)
	S Y=1
	;
FINDLOOP	;
	;
	S INQUOTES=0,L=$L(X)
	F I=Y:1:L S Z=$E(X,I) S:Z="""" INQUOTES='INQUOTES I 'INQUOTES,Z="[" Q
	I I=L Q "" ; No data item references
	S Y=$F(X,"]",I) I Y=0 Q "" ; No data item references
	I $E(X,I+1,Y-2)'?1A.AN.",".AN S Y=I+1 G FINDLOOP
	F Z=Y:1:L+1 Q:$E(X,Z)'?1AN
	I Z=Y G FINDLOOP
	Q $E(X,I,Z-1)
	;
	; Exit from routine
	;
EXIT	;
	;
	; current version will use ER="" or ER=Message fromat
	;
	I ER S ER=RM,NS="" K RM
	;
	Q
	;
	;
ERROR	;
	;
	; Invalid data item name - [~p1,~p2]~p3
	S ER=1,RM=$$^MSG(1298,LIBRARY_"."_FILENAME_"."_DATAITEM)
	Q
