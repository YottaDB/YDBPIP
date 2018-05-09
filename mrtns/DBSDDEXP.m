DBSDDEXP	;;DBS - UTL - V5.0 - EXPORT/IMPORT DATA-QWIK Definition
	;;Copyright(c)2003 Sanchez Computer Associates, Inc.  All Rights Reserved - 03/19/03 13:22:22 - RUSSELL
	;     ORIG:  CHIANG - 16 DEC 1991
	;     DESC:  EXPORT/IMPORT DQ DEFINITIONS
	;
	; I18N=QUIT: Excluded from I18N standards.
	;---------- Revision History -------------------------------------------
	; 05/11/06 - Allan Mattson - CR20048
	;            Replaced occurrences of $C(255) with the value returned
	;            from $$getPslValue^UCOPTS("maxCharValue").
	;
	;            Replaced calls to $$UPPER^%ZFUNC with $$UPPER^SCAUTL.
	;
	;	     Modified to allow calls to FILE^%ZOPEN to consider character
	;	     set exceptions for Unicode.
	;
	;            Deleted pre-2004 revision history.
	;
	; 09/28/04 - RussellDS - CR12334
	;	     Replaced obsoleted calls to ^DBSANS1 with new procedure
	;	     DBSGETID.
	;
	;-----------------------------------------------------------------------
	;
CREATE	;
	N %JRNL	
	D INIT
	S %O=0 D EXPID I VFMQ="Q" Q
	;
	S %PAGE=30,%PG=1,%O=1 G MODIFY1 ;	use modify mode to force
	;                                       FILE option for each page
	Q
MODIFY	;
	N %JRNL	
	D INIT
	S %O=1 D EXPID I VFMQ="Q" Q
	;
	L +^DBTBL(%LIBS,17,EXPID):5 I '$T W $$MSG^%TRMVT("Record locked","",1) Q
	S %PAGE=30,%PG=1
	D MODIFY1 L -^DBTBL(%LIBS,17,EXPID)
	Q
MODIFY1	;
	F Z=1:1 Q:'$D(^DBTBL(%LIBS,17,EXPID,0,Z))  S COMMT(Z)=^(Z)  ; Comments
	I $D(COMMT) S COMMENT=1
	S SID="DBTBL17" D ^USID I PGM="" Q ; Access screen
	D ^@PGM I VFMQ="Q" Q 
	I VFMQ="F" D FILE Q			; File data
	S %PG=%PG+1,%MODS=%PG-1*15+1		; Next page
	G MODIFY1
	;
COPY	;
	; 
	S MSG=$$BANNER^DBSGETID($G(%FN)) K FIO,TXXX,LOG,OLNTB
	D INIT^%ZM()
	S F(98)="" 
	S READCNT=0
	S %O=2
	S %TAB("EXPID")=".IDX2/TBL=[DBTBL17H]"
	S %READ="@MSG/CEN/REV,,EXPID/REQ,",%FRAME=2
	D ^UTLREAD I VFMQ="Q"!(EXPID="") Q
	I '$D(^DBTBL(%LIBS,17,EXPID)) Q		
	S %O=2,%NOPRMT="Q"
	S SID="DBTBL17" D ^USID I PGM="" Q ; Access screen
	D ^@PGM  
	S DES=^DBTBL(%LIBS,17,EXPID) 
	S DLIB=%LIBS  
	; 
	S $P(STS,"|",2)="",$P(STS,"|",3)=+$H 
	; 
TCOPY	; 
	N DQREF,OLNTB,Z,I,%TAB
	;
	S TLIB=%LIBS,OLNTB=22020,DQREF="DBTBL17"
	S NAME=$G(^DBTBL(%LIBS,1,DQREF,16)) I NAME="" Q 
	S NAME=$P(NAME,",",$L(NAME,",")) 
	S @NAME="" 
	S DQREF="["_DQREF_"]"_NAME
	;
	S Z="" F I=1:1 S Z=$O(^DBTBL(Z)) Q:Z=""!(I>1)
	;
	S %READ=DQREF
	S %READ=%READ_"/REQ/TYP=U/DES=To Export Definition"
	;
	I I>1 D
	.	S %CTPRMT="2|30",%READ="TLIB/REQ,"_%READ
	.	S %TAB("TLIB")=".TLIB1/TBL=^DBTBL("
	;
	S %NOPRMT="F" D ^UTLREAD I VFMQ'="F" Q
	;
	I $D(^DBTBL(TLIB,17,@NAME)) Q		;Do not overwrite another one
	;
	S ^DBTBL(TLIB,17,@NAME)=$G(^DBTBL(%LIBS,17,EXPID))
	S X=""
	F  S X=$O(^DBTBL(%LIBS,17,EXPID,X)) Q:X=""  S ^DBTBL(TLIB,17,@NAME,X)=$G(^DBTBL(%LIBS,17,EXPID,X))
	F  S X=$O(^DBTBL(%LIBS,17,EXPID,0,X)) Q:X=""  S ^DBTBL(TLIB,17,@NAME,0,X)=^DBTBL(%LIBS,17,EXPID,0,X)	; JMH - 02/28/01
	Q
	;
DELETE	;
	D INIT
	S %O=3 D EXPID I VFMQ="Q" Q
	;
	S %PG=1 
	S SID="DBTBL17" D ^USID I PGM="" Q ; Access screen
	D ^@PGM I VFMQ="Q" Q 
	K ^DBTBL(%LIBS,17,EXPID)
	Q	
	;
LIST	;
	N RID S RID="DBSEXPLST" D DRV^URID
	Q
RPT	;
	N RID S RID="DBIMPORT" D DRV^URID
	Q
EXPORT	;
	N CHARSET,PARAMS
	D INIT
	;
	S MSG=$$BANNER^DBSGETID($G(%FN)) K IO,LOG,OLNTB
	;
	; /DES=Export Name/TYP=U/LEN=12
	S %TAB("ID")=".IDX2/TBL=[DBTBL17H]/XPP=D PPEXP^DBSDDEXP"
	; /DES=Export RMS File Name/TYP=U/LEN=40
	S %TAB("IO")=".IODUMP3/XPP=S %EXT=1 D ^SCAIO S EXPIO=IO"
	; /DES=Export Log File/TYP=U/LEN=40
	S %TAB("LOG")=".LOGFILE2/XPP=S %EXT=1 D ^SCAIO"
	;
	S %READ="@MSG/CEN/REV,,ID/REQ,IO/REQ,LOG/REQ,",%FRAME=2
	D ^UTLREAD I VFMQ="Q"!(ID="") Q
	;
	I '$D(^DBTBL(%LIBS,17,ID)) Q
	;
	; ---------- Open RMS files for export definitions and log file
	;
	S IO=EXPIO
	S CHARSET=$$CHARSET("EXPORT","IO")
	I CHARSET="" S PARAMS="WRITE/NEWV"
	E  S PARAMS="WRITE/NEWV/OCHSET="_CHARSET
	S Z=$$FILE^%ZOPEN(IO,PARAMS,5,4096) I 'Z S ER=1,RM=$P(Z,"|",2) Q
	;
	S CHARSET=$$CHARSET("EXPORT","LOG")
	I CHARSET="" S PARAMS="WRITE/NEWV"
	E  S PARAMS="WRITE/NEWV/OCHSET="_CHARSET
	S Z=$$FILE^%ZOPEN(LOG,PARAMS,5) I 'Z S ER=1,RM=$P(Z,"|",2) Q
	;
	D LOG("****** Create Export File "_ID_" ******")
	;
	D INIT,INIT1
	;
	; ---------- Output file header        Message,date,time
	;                                      type|name|date
	;                                       ""   ""   ""
	;                                      <EOH>
	;                 
	;                                      DATA (%GOGEN format)
	;
	S DESC=$P($G(^DBTBL(%LIBS,17,ID)),"|",1)
	; 02/23/99 BC
	U IO W "Export Definitions - "_DESC_"|Created On "_$$DAT^%ZM(+$H)_"  "_$$TIM^%ZM_"|"_%LIBS_"|V5.0",!!
	;
	K LIST,%ZI,%ZR,ROU
	S ZL=0,GBLNO=1,$P(LINE,"-",81)=""
	W !,LINE
	F I=1:1 Q:'$D(^DBTBL(%LIBS,17,ID,0,I))  W !,^(I)
	W !,LINE,!,"<BOH>",!
	N ZCDT
	F  S ZL=$O(^DBTBL(%LIBS,17,ID,ZL)) Q:ZL=""  D
	.	;
	.	S X=^(ZL),TYPE=$P(X,"|",1),NAMES=$P(X,"|",2),DELFLG=$P(X,"|",3)
	.	S opt=$P(type(TYPE),"|",2)
	.	;
	.	I opt>200,'DELFLG d		;31145 mas
	..		I opt=201,$E(NAMES)="@" S datafl(TYPE,""""_NAMES_"""")=DELFLG Q
	..		S datafl(TYPE,NAMES)=DELFLG
	.	;
	.	I opt=100 D  Q  ; Routines
	.. 	  S L=$L(NAMES,",")
	..        F J=1:1:L K %ZI,%ZR S K=$P(NAMES,",",J),%ZI(K)="" S:'DELFLG ROU(K)="" DO
	...	    D INT^%RSEL I $O(%ZR(""))="" Q
	...	    S I="" F  S I=$O(%ZR(I)) Q:I=""  D
	....          I $E(I)="%" S ZCDT=+$H			; %RTN
	....          E  S ZCDT=$$ZFILE(%ZR(I)_I_".m") ;	Date Created
	....	      W TYPE_"|"_I_"|"_DELFLG_"|"_ZCDT_"|"_$$DAT^%ZM(+ZCDT),! ;	Routine Header
	.
	.	I opt=99 W X,! S LIST(99,GBLNO,+DELFLG)=NAMES,GBLNO=GBLNO+1 Q  ; Global
	.	;
	.	K NAME
	.	I opt=96!(opt=11) D			  ; [fid]di or [fid]
	..	  N I,J,Z
	..	  F I=1:1 S Z=$P(NAMES,",",I) Q:Z=""  S NAME(Z)=""
	..	  ;
	.	E  D LISTA(opt,NAMES,.NAME)
	.	;
	.	; ---------- Header Record TYPE|NAME|DATE
	.	;
	.	S X="" F  S X=$O(NAME(X)) Q:X=""  D
	..	  S z="" I opt=2!(opt=5) S z=$P($G(^DBTBL(%LIBS,opt,X,0)),"|",3)
	..	  W TYPE_"|"_X_"|"_DELFLG_"|"_z_"|"_$$DAT^%ZM(z),! 
	..	  I 'DELFLG S LIST(opt,X)=TYPE
	.	;
	U IO W "<EOH>",!
	;
	D EXP99
	;
	U IO W !!,"<EOD>",!
	; ---------- Tran code , IBS product ----------------
	;
	U IO W "<BOF>",!
	S TYPE="" F  S TYPE=$O(datafl(TYPE)) Q:TYPE=""  D  Q:$G(ER)
	.	;
	.	I TYPE="DATAFILE" D  Q			; DQ files
	..		S file=""
	..		F  S file=$O(datafl(TYPE,file)) Q:file=""  D EXP^DBSDDEXQ(file,"C")
	.	S dinam=$P(type(TYPE),"|",4)		; FID.DI
	.	S file=$P(dinam,".",1)			; File name
	.	S query=dinam_"=",qry=""		; Combine queries
	.	S ER=0
	.	I TYPE="CIFPROD"!(TYPE="DEPPROD")!(TYPE="LNPROD") D  Q:ER 
	..		F  S qry=$O(datafl(TYPE,qry)) Q:qry=""  D  I ER Q
	...			D PRODINTG I ER Q
	..		I ER Q
	..		N query
	..		s query="PRODCTL."_$P(dinam,".",2)_"="
	..		F  S qry=$O(datafl(TYPE,qry)) Q:qry=""  S query=query_qry_","
	..		S query=$E(query,1,$L(query)-1)
	..		D EXP^DBSDDEXQ("PRODCTL","C",query)
	.	F  S qry=$O(datafl(TYPE,qry)) Q:qry=""  S query=query_qry_","
	.	S query=$E(query,1,$L(query)-1)
	.	D EXP^DBSDDEXQ(file,"C",query)		; Output data file
	I $G(ER) Q
	U IO W "<EOF>",!
	;
	; ---------- Output Routines
	;
	D LOG(""),LOG("****** Output Routines ******"),LOG("")
	;
	U IO W "<BOP>",!	
	K %ZI,%ZR S I="" F  S I=$O(ROU(I)) Q:I=""  S %ZI(I)=""
	;
	U IO D INT^%RSEL ; Convert %ZI() to %ZR()
	;
	S Z="" F  S Z=$O(%ZR(Z)) Q:Z=""  DO
	.	I $E(Z)="%" S ZDIR=$$SCA^%TRNLNM("RTNS"),ZCDT=+$H
	.	E  S ZDIR=%ZR(Z)_Z_".m",ZCDT=$$ZFILE(ZDIR),ZDIR=ZDIR_$J("",45-$L(ZDIR))
	.	DO LOG(ZDIR_" "_$$DAT^%ZM(+ZCDT)_" "_$$TIM^%ZM($P(ZCDT,",",2),"24:60:SS"))
	.	;
	D LOG("-----------------------------------------"),LOG("")
	;
	S COUNT=$$EXT^%RO(IO,"Export Routines - "_ID,.%ZR)
	;
	; ~p1 routines saved
	D LOG(""),LOG(COUNT_" routines saved")
	D LOG(""),LOG("<ENDLOG>")
	;
	C IO,LOG
	; 
	W $$MSG^%TRMVT("Export completed","",1)
	Q
EXP99	;
	N LEV,NM,Q
	;
	S LEV="",NM="",Q=$C(34)
	;
	D INIT1
	F  S LEV=$O(LIST(LEV)) Q:LEV=""!(LEV>99)  D
	.	;
	.	D LOG($J(opt(LEV),14)_": ")
	.	F  S NM=$O(LIST(LEV,NM)) Q:NM=""  D EXPNAM(LEV,NM)
	;
	F LEV=107,108,109,119 D
	.	I '$D(LIST(LEV)) Q
	.	D LOG($J(opt(LEV),14)_": ")
	.	F  S NM=$O(LIST(LEV,NM)) Q:NM=""  D EXPNAM(LEV,NM)
	Q
	;
	;---------------------------------------------------------------------
EXPNAM(LEV,NM)	; Export Name for LEV
	;---------------------------------------------------------------------
	;
	I LEV=10 D  Q				; DQ Filers
	.	;
	.	F zlev=7,8,9,19 D
	..		S DES=$G(^DBTBL(%LIBS,zlev,NM))
	..		S GBL="^DBTBL("_Q_%LIBS_Q_","_zlev_","_Q_NM_Q
	..		D EXPORT2
	;
	I LEV=11 D  Q				; Documentation
	.	;
	.	S zfl=$E($P(NM,"]",1),2,99),zdi=$P(NM,"]",2)
	.	I zdi="" S GBL="^DBTBL("_Q_%LIBS_Q_",11,"_Q_zfl_Q,DES="AAA"		
	.	E  S GBL="^DBTBL("_Q_%LIBS_Q_",11,"_Q_zfl_Q_","_Q_zdi_Q
	.	E  S DES=$P($G(^DBTBL(%LIBS,1,zfl,9,zdi)),"|",10)
	.	D EXPORT2
	;
	I LEV<20!(LEV=25)!(LEV=33) D  Q			; DATA-QWIK table
	.	;
	.	S DES=$G(^DBTBL(%LIBS,LEV,NM))
	.	S GBL="^DBTBL("_Q_%LIBS_Q_","_LEV_","_Q_NM_Q
	.	D EXPORT2
	;
	I LEV=96 D  Q				; Data Item
	.	;
	.	S zfl=$E($P(NM,"]",1),2,99),zdi=$P(NM,"]",2)
	.	S GBL="^DBTBL("_Q_%LIBS_Q_",1,"_Q_zfl_Q_",9,"_Q_zdi_Q
	.	S DES=$P($G(^DBTBL(%LIBS,1,zfl,9,zdi)),"|",10)
	.	D EXPORT2
	;
	I LEV=97 S GBL="^SCATBL(1,"_Q_NM_Q_")",DES=$P($G(^SCATBL(1,NM)),"|",1)
	I LEV=97.5 S GBL="^SCATBL(3,"_Q_NM_Q,DES=$P($G(^SCATBL(1,NM)),"|",1)_" (DOC)"
	I LEV=98 S GBL="^SCATBL(0,"_NM,DES=$P($G(^SCATBL(0,NM)),"|",1)
	I LEV=99 S ZZ=$O(LIST(LEV,NM,"")) I ZZ=1 Q	; Delete Only
	I LEV=99 S GBL=LIST(LEV,NM,ZZ),DES=GBL
	;
	; Trigger, Index, Journal and Foreign Key
	I (LEV=107)!(LEV=108)!(LEV=109)!(LEV=119) D  Q
	.	;
	.	N zlev,zfl,zelm
	.	S zlev=+$E(LEV,2,3)
	.	S zfl=$P(NM,"/",1)
	.	S zelm=$P(NM,"/",2)
	.	;
	.	S DES=$G(^DBTBL(%LIBS,zlev,zfl,zelm))
	.	S GBL="^DBTBL("_Q_%LIBS_Q_","_zlev_","_Q_zfl_Q_","_Q_zelm_Q
	.	D EXPORT2
	;
	D EXPORT2
	Q
EXPORT2	;
	D LOG($J(NM,30)_" - "_DES)
	U IO D EXT^%GOGEN(GBL)
	Q
	;
PPEXP	;
	I X="" Q
	I '$D(^DBTBL(%LIBS,17,X)) Q
	;
	; *** Default export file name
	;
	S IO=$$FILE^%TRNLNM(X,"SCAU$EXP")
	;
	S LOG=IO_".LOG",IO=IO_".EXP"
	S RM(1)=IO_"|2" ; D DISPLAY^DBSMACRO("@IO",IO)
	S RM(2)=LOG_"|3" ; D DISPLAY^DBSMACRO("@LOG",LOG)
	Q
LOG(Z)	;
	U 0 W !,Z
	U LOG W !,Z
	Q
	;
	; ---------- Import Definitions (function DBSEXPI)
FILE	; File Data
	;----------------------------------------------------------------------
	K ^DBTBL(%LIBS,17,EXPID)
	S ^DBTBL(%LIBS,17,EXPID)=$G(EXPDESC)_"|"_(+$H)_"|"_$$USERNAM^%ZFUNC
	;
	F I=1:1 Q:'$D(COMMT(I))  S ^DBTBL(%LIBS,17,EXPID,0,I)=COMMT(I)
	S I="",OK=0 F  S I=$O(DDTYPE(I)) Q:I=""  DO		; Export File
	.	I $P(DDTYPE(I),"|",1,2)=("EXPORT|"_EXPID) S OK=1	; Defined
	;
	I OK S SEQ=1						; Add EXPORT def
	E  S SEQ=2,^DBTBL(%LIBS,17,EXPID,1)="EXPORT|"_EXPID_"|"	; as first entry
	;
	S I="" F  S I=$O(DDTYPE(I)) Q:I=""  DO
	.	;
	.	I $P(DDTYPE(I),"|",1)="" Q  ;			Skip blank entries
	.	S ^DBTBL(%LIBS,17,EXPID,SEQ)=DDTYPE(I)
	.	S SEQ=SEQ+1
	.	;
	X KVAR
	Q
	;
	; ---------- Screen VLOD section
	;
VLOD	;
	I READCNT Q
	S READCNT=READCNT+1
	S X=$G(^DBTBL(%LIBS,17,EXPID))
	S EXPDESC=$P(X,"|",1),ZLTD=$P(X,"|",2),ZUID=$P(X,"|",3)
	I ZLTD="" S ZLTD=+$H
	I ZUID="" S ZUID=$$USERNAM^%ZFUNC
	I %O=0 Q
	K DDTYPE,NAMES,yn
	S I="" F  S I=$O(^DBTBL(%LIBS,17,EXPID,I)) Q:I=""  S DDTYPE(I)=$G(^(I))
	Q	
	;
	;
	; ---------- Screen Pre-Processor for item NAMES
	;
PRENAME	;
	;
	; Get current sequence number, load lookup table syntax
	;
	N z
	S z=$P(DDTYPE(z1),"|",1) I z="" Q
	S z=type(z),zname=$P(z,"|",1),zopt=$P(z,"|",2),I(3)=$P(z,"|",3)
	Q
	;
	; ---------- Post-Processor for item NAMES
	;
PPNAME	;
	; ---------- 96=[fid]di 97=function 98=menu 99=global 100=routines
	;
	N name
	;
	; VLM 09/05/01 Added zopt=107 and zopt=96
	I '((zopt=107)!(zopt=99)!(zopt=96)!(zopt=93)) S E8="U" DO
	. S X=$$UPPER^SCAUTL(X)
	;
	I X="" S ER=1,RM="Required" Q
	;
	D PPNAME1(X)
	I $P(DDTYPE(z1),"|",3) D
	.	S I(3)=""		; Delete definitions
	.	I '$G(ER) Q		; Continue on error
	.	;
	.	I $G(ER) S ER=0,RM="Warning ... "_$G(RM)
	.	
	Q
PPNAME1(X)	;
	;
	I zopt=11 DO  Q  ; [fid] or [fid]di documentation
	.	;
	.	N zfl,zdi,I,Z
	.	S ER=0 F I=1:1 S Z=$P(X,",",I) Q:Z=""  DO  I ER Q
	..	 I Z?1"["1E.AN1"]" DO  Q  ;	single file [fid]
	...	  ; 
	...	  S Z=$E($P(Z,"]",1),2,99) I '$D(^DBTBL(%LIBS,11,Z)) S ER=1,RM="Invalid documentation file name - "_Z Q
	..	 ; 
	..	 I Z'?1"["1E.AN1"]"1E.AN S ER=1,RM="Invalid [FID]DI syntax" Q
	..	 S zfl=$E($P(Z,"]",1),2,99),zdi=$P(Z,"]",2)
	..	 ; 
	..	 I '$D(^DBTBL(%LIBS,1,zfl,9,zdi)) S ER=1,RM="Invalid data item name - "_zdi Q
	..	;
	I zopt=96 DO  Q  ; [fid]di data item
	.	;
	.	N zfl,zdi,I,Z
	.	S ER=0 F I=1:1 S Z=$P(X,",",I) Q:Z=""  DO  I ER Q
	..	;
	..	I Z'?1"["1E.AN1"]"1E.AN S ER=1,RM="Invalid [FID]DI syntax" Q
	..	S zfl=$E($P(Z,"]",1),2,99),zdi=$P(Z,"]",2)
	..	; Invalid data item name - ~p1
	..	I '$D(^DBTBL(%LIBS,1,zfl,9,zdi)) S ER=1,RM="Invalid data item name - "_zdi Q
	;
	I zopt=99 DO  Q  ; ^globals
	.	; Single global reference only
	.	I $L(X,"^")>2 S ER=1,RM="Single global reference only" Q
	.	;
	.	I $P(X,"(",1)'?1"^"1A.AN S ER=1,RM="Invalid global syntax" Q
	.	S Z=$P(X,"(",1)
	.	; Invalid global name
	.	I '$D(@Z) S ER=1,RM="Invalid global name" Q
	.	I $$gblref(Z) S ER=1,RM="Invalid reference to a protected global "_$P(Z,"(",1) Q
	;
	I zopt=206 D  Q					; DATAFILE
	.	F Z=1:1:$L(X,",") S z=$P(X,",",Z) D  I $G(ER) Q
	..		I z="" S ER=1,RM="Invalid syntax" Q  		; Invalid syntax
	..		I '$D(^DBTBL(%LIBS,1,z)) S ER=1,RM="Invalid file name - "_z Q  ; Invalid file name
	..		S GBL=$P(^DBTBL(%LIBS,1,z,100),"|",1)
	..		I $$gblref(GBL) S ER=1,RM="Invalid reference to a protected global "_$P(GBL,"(",1) Q
	;
	; 
	I zopt=100 DO  Q:ER  S RM=COUNT_" routines selected" Q
	.	;
	.	S COUNT=0
	.	; 
	.	I X["-" S ER=1,RM="Invalid syntax.  Use * for range." Q
	.	S L=$L(X,",")
	.	F J=1:1:L K %ZI,%ZR S K=$P(X,",",J),%ZI(K)="" DO
	..	  ; 
	..	  D INT^%RSEL I $O(%ZR(""))="" S ER=1,RM="Invalid routine name "_K Q
	..	  S COUNT=COUNT+$G(%ZR)
	;
	; Trigger, Index and Journal post-processor
	I (zopt=107)!(zopt=108)!(zopt=109) D  Q
	.	;
	.	N zfl,zelm,I,Z,zlevel,zdesc
	.	S zlevel=+$E(zopt,2,3)
	.	S zdesc=$P(zname," Definition",1)
	.	;
	.	S ER=0 F I=1:1 S Z=$P(X,",",I) Q:Z=""  DO  I ER Q
	..	;
	..	I Z["*" S ER=1,RM="Wildcard not permitted" Q
	..	I Z'["/" S ER=1,RM="Invalid syntax - "_Z Q
	..	S zfl=$P(Z,"/",1),zelm=$P(Z,"/",2)
	..	I zfl="" S ER=1,RM="Table required" Q
	..	I zelm="" S ER=1,RM=zdesc_" required" Q
	..	; Invalid file name
	..	I '$D(^DBTBL(%LIBS,1,zfl)) S ER=1,RM="Invalid table name - "_zfl Q
	..	; Invalid element name - ~p1
	..	I '$D(^DBTBL(%LIBS,zlevel,zfl,zelm)) S ER=1,RM="Invalid "_zdesc_" - "_zelm Q
	;
	I zopt=119 D  Q
	.	;
	.	N zfl,zelm,zdesc       ; LJS 08/07/01
	.	S zdesc=$P(zname," Definition",1)
	.	;
	.	I (X["*")!(X["-")!(X["@") S ER=1,RM="Wildcard not permitted" Q
	.	I X'["/" S ER=1,RM="Invalid syntax - "_X Q     ; LJS 07/25/01
	.	I $L(X,"/")>2 S ER=1,RM="One "_zdesc_" per line" Q
	.	S zfl=$P(X,"/",1),zelm=$P(X,"/",2)
	.	I zfl="" S ER=1,RM="Table required" Q
	.	I zelm="" S ER=1,RM=zdesc_" required" Q
	.	; Invalid file name
	.	I '$D(^DBTBL(%LIBS,1,zfl)) S ER=1,RM="Invalid table name - "_zfl Q
	.	; Invalid element name - ~p1
	.	I '$D(^DBTBL(%LIBS,19,zfl,zelm)) S ER=1,RM="Invalid "_zdesc_" - "_zelm Q
	;
	I '((X[",")!(X["-")!(X["*")) Q
	;
	S I(3)="",CNT=0
	;
	D LISTA(zopt,X,.name)
	S Z="" F  S Z=$O(name(Z)) Q:Z=""  S CNT=CNT+1 I zopt<20 DO
	.	;  
	.	I '$D(^DBTBL(%LIBS,zopt,Z)) S ER=1,RM="Invalid name - "_Z Q
	;
	;
	S CNT=0
	S Z="" F  S Z=$O(name(Z)) Q:Z=""!(ER=1)  S CNT=CNT+1 I zopt=203 DO 
	.       I '$D(^UTBLDFTC(Z)) S ER=1,RM=$$^MSG(1485,Z) 
	; 
	S CNT=0 
	S Z="" F  S Z=$O(name(Z)) Q:Z=""!(ER=1)  S CNT=CNT+1 I zopt=204 DO 
	.       I '$D(^UTBLDFTD(Z)) S ER=1,RM=$$^MSG(1485,Z) 
	; 
	S CNT=0 
	S Z="" F  S Z=$O(name(Z)) Q:Z=""!(ER=1)  S CNT=CNT+1 I zopt=201 DO 
	.       I '$D(^TRN(Z)) S ER=1,RM=$$^MSG(1485,Z) 
	; 
	;Added this for Trancode Authorizations  3/15/01 jcl
	S CNT=0
	S Z="" F  S Z=$O(name(Z)) Q:Z=""!(ER=1)  S CNT=CNT+1 I zopt=202 DO
	.       I '$D(^TRN(Z)) S ER=1,RM=$$^MSG(1485,Z)
	;
	S CNT=0 
	S Z="" F  S Z=$O(name(Z)) Q:Z=""!(ER=1)  S CNT=CNT+1 I zopt=205 DO 
	.       I '$D(^UTBLDFTL(Z)) S ER=1,RM=$$^MSG(1485,Z) 
	; 
	S CNT=0 
	S Z="" F  S Z=$O(name(Z)) Q:Z=""!(ER=1)  S CNT=CNT+1 I zopt=97 DO 
	.       I '$D(^SCATBL(1,Z)) S ER=1,RM=$$^MSG(1485,Z) 
	; 
	S CNT=0 
	S Z="" F  S Z=$O(name(Z)) Q:Z=""!(ER=1)  S CNT=CNT+1 I zopt=97.5 DO 
	.       I '$D(^SCATBL(3,Z)) S ER=1,RM=$$^MSG(1485,Z) 
	; 
	S CNT=0 
	S Z="" F  S Z=$O(name(Z)) Q:Z=""!(ER=1)  S CNT=CNT+1 I zopt=98 DO 
	.       I '$D(^SCATBL(0,Z)) S ER=1,RM=$$^MSG(1485,Z) 
	; 
	I 'ER S RM=zname_" ("_CNT_" entries selected)"
	Q
	;----------------------------------------------------------------------
gblref(ref)	; Check global reference ref against user-defined table GBLNOLOD
	;----------------------------------------------------------------------
	; ARGUMENT:
	;
	;    	ref	Global reference		/TYP=T/REQ/MECH=VAL
	;
	; RETURN:
	;	$$	Status				/TYPE=N
	;		0 = No match
	;		1 = Defined in user table GBLNOLOD
	;
	; EXAMPLE:
	;       
	;       S match=$$gblref("ACN")
	;       S match=$$gblref("^SCAU(1")
	;----------------------------------------------------------------------
	N maxCharV,z
	;
	S maxCharV=$$getPslValue^UCOPTS("maxCharValue")
	;
	I $E(ref)="^" S ref=$E(ref,2,99)		; Remove Leading ^
	I $E(ref,$L(ref))=")" S ref=$E(ref,1,$L(ref)-1)	; Remove trailing )
	;
	S z=$O(^UTBL("GBLNOLOD",ref_$C(maxCharV)),-1)
	I z=""!($E(z,1,$L(z))'=$E(ref,1,$L(z))) Q 0	; No match
	;
	Q 1
	;
	;----------------------------------------------------------------------
LISTA(opt,X,NAME)	; 
	;
	N Z1,Z2,Z3
	I opt=17 S NAME(X)="" Q
	I opt=101 S NAME(X)="" Q		; JRC ARQ 10174
	I opt=119 S NAME(X)="" Q
	;
	F Z=1:1 S Z1=$P(X,",",Z) Q:Z1=""  DO
	.	;
	.       ; Added the last % pattern check for functions
	.       I Z1'["*",Z1'["-",Z1?1A.E!(Z1?1N.N)!(Z1?1"@"1E.E)!(Z1?1"%"1E.E) S NAME(Z1)="" Q 
	.	I '((Z1?1AN.AN1"-"1AN.AN)!(Z1?1A.AN1"*")) Q
	.	;
	.	I Z1["*" S Z2=$P(Z1,"*",1),Z3=Z2_"zzzzz"
	.	E  S Z2=$P(Z1,"-",1),Z3=$P(Z1,"-",2)
	.	;
	.	I opt=91 DO	
	..	S Z2=$O(^UTBL(Z2),-1)
	..	F  S Z2=$O(^UTBL(Z2)) Q:Z2=""!(Z2]]Z3)  S NAME(Z2)=""
	..	Q
	.	I opt=92 DO
	..	S Z2=$O(^STBL(Z2),-1)
	..	F  S Z2=$O(^STBL(Z2)) Q:Z2=""!(Z2]]Z3)  S NAME(Z2)=""
	..	Q
	.	I opt=94 DO
	..	S Z2=$O(^CTBL(Z2),-1)
	..	F  S Z2=$O(^CTBL(Z2)) Q:Z2=""!(Z2]]Z3)  S NAME(Z2)=""
	..	Q
	.	I opt=93 DO
	..	S Z2=$O(^TRN(Z2),-1)
	..	F  S Z2=$O(^TRN(Z2)) Q:Z2=""!(Z2]]Z3)  S NAME(Z2)=""
	..	Q
	.	I opt=97 DO
	..	S Z2=$O(^SCATBL(1,Z2),-1)
	..	F  S Z2=$O(^SCATBL(1,Z2)) Q:Z2=""!(Z2]]Z3)  S NAME(Z2)=""
	..	Q
	.	I opt=98 DO  Q
	..	S Z2=$O(^SCATBL(0,Z2-1),-1)
	..	F  S Z2=$O(^SCATBL(0,Z2)) Q:Z2=""!(Z2>Z3)  S NAME(Z2)=""
	..	Q
	.	I opt>0!(opt<20) DO  Q
	..	S Z2=$O(^DBTBL(%LIBS,opt,Z2),-1)
	..	F  S Z2=$O(^DBTBL(%LIBS,opt,Z2)) Q:Z2=""!(Z2]]Z3)  S NAME(Z2)=""
	Q
	;
	; ---------- Access Export ID
	;
EXPID	;
	K EXPID
	S ZOPT=%O
	S %TAB("EXPID")="|12|||[DBTBL17H]||D PPEXPID^DBSDDEXP||U|Export Definition Name"
	S %READ="@MSG/CEN/REV,,EXPID/NOREQ,",%NOPRMT="F",%FRAME=2
	D ^UTLREAD I $G(EXPID)="" S VFMQ="Q"
	Q
PPEXPID	; 
	I ZOPT Q
	;
	I X="" Q
	; 
	I '$$VALIDKEY(X) S ER=1,RM="Alphanumeric format only" Q
	S I(3)="" ; Disable lookup table
	;
	I X'="",$D(^DBTBL(%LIBS,17,X)) S ER=1,RM="Already created" Q
	Q
	;
VALIDKEY(X)	; Return Valid/Invalid key string flag
	;
	I X[" " Q 0
	I $E(X)'?1AN Q 0
	;
	S Z=$TR($E(X,2,99),"`~!@#$%^&*()-+={}[]:;|\,.?/<>vx","")=$E(X,2,99)
	Q Z
	;
	;----------------------------------------------------------------------
INIT	;
	S READCNT=0,COMMENT=0
	F I=1:1:30 S VPG(I)="Page "_I_"|DBTBL17"
	;
	K OLNTB,NAMES,DDTYPE,ZDBTBL,COMMT
	I $G(%LIBS)="" S %LIBS=^CUVAR("%LIBS")
	S type("FILE")="File Definition (File Name,fid-fid)|1|^DBTBL(%LIBS,1,"
	S type("SCREEN")="Screen Definition (Screen Name,sid-sid)|2|^DBTBL(%LIBS,2,"
	S type("QUERY")="Query Definition (Query Name,qid-qid)|4|^DBTBL(%LIBS,4,"
	S type("REPORT")="Report Definition (Report Name,report-report)|5|^DBTBL(%LIBS,5,"
	S type("QWIK")="QWIK Report Definition (QWIK Report Name,report-report)|6|^DBTBL(%LIBS,6,"
	S type("PPLIB")="Pre/Post-Processor Library (Proc Library Name,pplib-pplib)|13|^DBTBL(%LIBS,13,"
	S type("DOC")="Data Item Documentation ([fid] or [fid]di)|11|"
	S type("RECEXCH")="Data Exchange Definition|16|^DBTBL(%LIBS,16,"
	S type("PROC")="Procedure Definition|25|^DBTBL(%LIBS,25,"
	S type("BATCH")="Procedure Definition|33|^DBTBL(%LIBS,33,"
	S type("ITEM")="Data Item Definition ([fid]di,[fid]di,...)|96"
	S type("FUNCTION")="Function (function Name,function-function)|97|^SCATBL(1,"
	S type("FUNC-DOC")="Function Documentation (Function Name,function-function)|97.5|^SCATBL(3,"
	S type("MENU")="Menu (Menu Number,menu-menu)|98|^SCATBL(0,"
	S type("GLOBAL")="MUMPS Global (^Global or partial ^Global(key1,...  )|99"
	S type("ROUTINE")="MUMPS Routine (Routine Name,routine*)|100"
	S type("FILER")="Filer Definition (DQ level 7,8,9,19)|10|ZDBTBL("
	S type("TRIGGER")="Trigger Definition (fid/trigger)|107"
	S type("INDEX")="Index File Definition (fid/index)|108"
	S type("JOURNAL")="Journal Definition (fid/journal)|109"
	S type("FRNKEY")="Foreign Key Definition (fid/frnkey)|119"
	S type("EXPORT")="Export/Import Definition|17|^DBTBL(%LIBS,17,"
	S type("MUMPS")="MUMPS Command|101"
	S type("TRNCODE")="IBS Tran Code (code1,code2,...)|201|^TRN(|TRN.ETC"
	S type("TRNAUT")="IBS Tran Code Authorizations|202|^TRN(|TRNAUT.ETC"
	S type("CIFPROD")="CIF Product Type (product #,...)|203|^UTBLDFTC(|PRODDFTC.TYPE"
	S type("DEPPROD")="Deposit Product Type (product #,...)|204|^UTBLDFTD(|PRODDFTD.TYPE"
	S type("LNPROD")="Loan Product Type (product #,...)|205|^UTBLDFTL(|PRODDFTL.TYPE"
	S type("DATAFILE")="Data File (file1,file2,...)|206|^DBTBL(%LIBS,1,"
	S MSG=$$BANNER^DBSGETID($G(%FN))
	;
	F I=7,8,9,19 S J="" F  S J=$O(^DBTBL(%LIBS,I,J)) Q:J=""  S ZDBTBL(J)=""
	Q
INIT1	;
	s opt(1)="File",opt(2)="Screen",opt(4)="Query",opt(5)="Report"
	s opt(6)="QWIK Report",opt(11)="Document",opt(13)="PP Library"
	S opt(10)="DQ Filer",opt(16)="Record Exchange",opt(17)="Export Definition"
	S opt(25)="Procedure",opt(33)="Batch"
	S opt(96)="Data Item"
	S opt(97)="Function",opt(98)="Menu",opt(99)="Global",opt(100)="Routine" 
	S opt(97.5)="Function Documentation" 
	S opt(101)="MUMPS Command",opt(201)="PROFILE/IBS Product"
	S opt(107)="Trigger",opt(108)="Index",opt(109)="Journal"
	S opt(119)="Foreign Key"
	Q
PRODINTG;	
	N TYPE,verrors,cls
	S ER=0
	F INDEX=1:1 Q:$P(qry,",",INDEX)=""  S TYPE=$P(qry,",",INDEX) D  Q:ER
	.	S cls=$P($G(^UTBLCTL(TYPE,50)),"|",2)	; Class 
	.	K verrors  
	.	I cls="*" D EXT^DBSFILER("PRODDFTC",2),EXT^DBSFILER("PRODCTL",2) Q	; PRODDFTC filer
	.	I cls="D" D EXT^DBSFILER("PRODDFTD",2),EXT^DBSFILER("PRODCTL",2) Q	; PRODDFTD filer
	.	i cls="L" D EXT^DBSFILER("PRODDFTL",2),EXT^DBSFILER("PRODCTL",2) Q	; PRODDFTL filer
	I $D(verrors) S ER=1,RM=$$^MSG(2617,INDEX)
	Q
ZT	;
	U 0 W $ZS
	C IO,LOG
	Q
	;-----------------------------------------------------------------------
ZTRNLNM(X)	; Private ; Return RMS file name or NULL
	;-----------------------------------------------------------------------
	Q $$TRNLNM^%ZFUNC(X)
	;
	;-----------------------------------------------------------------------
ZFILE(X)	; Private ; Return RMS file create date ( $H format ) 
	;-----------------------------------------------------------------------
	Q $$FILE^%ZFUNC(X,"CDT")
	;
	;-----------------------------------------------------------------------
ZSEARCH(X)	; Private ; Return NULL if new routine 
	;-----------------------------------------------------------------------
	Q $$SEARCH^%ZFUNC(X)
	;
	;-----------------------------------------------------------------------
IMPORT	;
	G ^DBSDDIMP
	;
	;----------------------------------------------------------------------
CHARSET(LABEL,INSTNAME)	; Get alternate character set
	;----------------------------------------------------------------------
	N CHARSET
	S CHARSET=""
	I $$VALID^%ZRTNS("UCIOENCD") S CHARSET=$$^UCIOENCD("Routine","DBSDDEXP",LABEL,INSTNAME)
	Q CHARSET
