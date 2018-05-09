DBSDDIMP	; 
	;;Copyright(c)2003 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/28/03 17:52:02 - RUSSELL
	;     ORIG:   CHIANG
	;     DESC:  IMPORT DQ DEFINITIONS
	;
	;  ------------- File Layout -------------------------------------------
	;
	; Description
	;
	; ---------------------------------------
	;  Comments
	;  ...
	; ---------------------------------------
	;
	; <BOH>                                 Example
	; Import Definition #1
	; Import Definition #2                  FILE|DEP|0
	; Import Definition #3                  ROUTINE|DBS|0|55555,12345|03/05
	; Import Definition #4                  GLOBAL|^XYZ|0
	;  ..
	;  ..
	; <EOH>
	; Transferring files on DD-MON-YEAR at HH:MM AM/PM
	; DQ definitions (file, screen, report ,... in %GOGEN format)
	;
	; ***DONE***
	;
	; <EOD>
	;
	; <BOF>					DATAFILE, PRODUCT,TRAN CODE
	;  ..
	;  ..
	; <EOR>
	;  ..
	;  ..
	; <EOR>
	; <EOF>
	; <BOP>
	; Export Routines
	; DD-MON-YEAR HH:MM:SS
	; Routine Name #1
	;     Routine source
	;     ..
	; <CR><LF>
	; Routine Name # 2
	;
	;     Routine source
	;
	; <CR><LF>
	; <CR><LF>
        ;---------- Revision History -------------------------------------------
        ; 07/18/06 - RussellDS - CR22121
  	;	     Modified to allow calls to FILE^%ZOPEN to consider character
  	;	     set exceptions for Unicode.
  	;	   
        ; 02/16/06 - RussellDS - CR19065
        ;	     Modified saving of DBIMPORT data to correspond to new
        ;	     table structure.
        ;
        ; 10/31/05 - RussellDS - CR17834
        ;	     Replaced call to obsolete INS^DBSINS in IMPORT1 section with
        ;	     use of DELETE^SQL.
        ;
        ;	     Removed old revision history.
	;----------------------------------------------------------------------
        ;   I18N=QUIT : Excluded From I18N Standards
IMPORT	;
	;
	N X,CDT,IDT,ZCDT,ERROR,MSG,ZMSG,MSG1,MSG2,LOG,RTNDIR,VERSION
	N %READ,%TAB,OLNTB,%FRAME,LOG,IO,IMPIO,type,opt,ZDBTBL,HDR
	K ^TMP2($J),IO
	D INIT^DBSDDEXP,INIT1^DBSDDEXP
	;
	S MSG=$$BANNER^DBSGETID($G(%FN)),OLNTB=30	; *** 11/02/95
	S ZMSG="Valid directory name: SCAU$MRTNS, SCAU$SRTNS or SCAU$PRTNS"
	;
	S MSG1="You are in directory: "_$$CDIR^%TRNLNM
	S MSG2="Global directory: "_$ZGBLDIR
	S LOG=$$SCAU^%TRNLNM("EXP","IMPORT_LOG."_$$DAT^%ZM($H,"MONDD"))
	S RTNDIR=$$SCAU^%TRNLNM("MRTNS")			
	;
	; /DES=Import File Name/TYP=U/LEN=60			
	S %TAB("IMPIO")=".IODUMP2/LEN=60/XPP=D IMPP^DBSDDIMP"	
	; /DES=Log File Name/TYP=T/LEN=60
	S %TAB("LOG")=".LOG4/LEN=60/XPP=S %EXT=1 D ^SCAIO"	
	; /DES=Restore Routines to Directory/TYP=U/LEN=40
	S %TAB("RTNDIR")=".RTNDIR"	
	;
	S %FRAME=2
	S %READ="@MSG/REV,,@MSG1/INC,,@MSG2/INC,,IMPIO/REQ,LOG/REQ,,@ZMSG/INC,,RTNDIR/REQ," D ^UTLREAD
	I VFMQ="Q" Q
	;
	;
	;----------------------------------------------------------------------
IMPORT1	; Load export file
	;----------------------------------------------------------------------
	N CHARSET,PARAMS
	S IO=IMPIO		
	;
	S CHARSET=$$CHARSET("IMPORT1","IO")
	I CHARSET="" S PARAMS="READ"
	E  S PARAMS="READ/ICHSET="_CHARSET
	S Z=$$FILE^%ZOPEN(IO,PARAMS,5,4096)  		; *** 04/01/97 
	I 'Z S ER=1,RM=$P(Z,"|",2) Q 
	;
	S CHARSET=$$CHARSET("IMPORT1","LOG")
	I CHARSET="" S PARAMS="WRITE/NEWV"
	E  S PARAMS="WRITE/NEWV/OCHSET="_CHARSET
	S Z=$$FILE^%ZOPEN(LOG,PARAMS,5) 
	I 'Z S ER=1,RM=$P(Z,"|",2) Q  
	;
	N %LIBS,%FN
	;
	; ---------- Use source library name
	;
	U 0 W $$CLEAR^%TRMVT
	U IO R X D LOG($P(X,"|",1)),LOG($P(X,"|",2))
	S %LIBS=$P(X,"|",3),VERSION=$P(X,"|",4)
	I %LIBS="" S %LIBS="SYSDEV"
	;
	D LOG("  ** Library "_%LIBS)
	;							; *** 10/18/94 	BC	
	D LOG("Version Number: "_VERSION)			; Version number
	I VERSION="" W $$MSG^%TRMVT("Invalid version number","",1) Q  	; Error message
	;
	; ---------- Display File Header Information
	;
	S routine=0,global=0,dqfile=0
	;
	F  U IO R X Q:X="<BOH>"  U 0 D LOG(X)
	;
	U 0 W !,$$MSG^%TRMVT("End of comments","",1)
	;
	W $$CLEAR^%TRMVT
	;
	D LOG("Import Source Date        Current Date"),LOG("")
	;
	F  U IO R X Q:X="<EOH>"  DO
	.	I X="" Q
	.	F I=1:1:4 S X(I)=$P(X,"|",I)
	.	S ZM=$J("",10)_$$RJ(X(1),10)_"   "_$$RJ(X(2),12)
	.	S ZM=ZM_$J("",5)_$$DAT^%ZM(X(4))
	.	; 
	.	I X(3) S ZM=ZM_"  Delete" D LOG(ZM) Q
	.	S ZM=ZM_$J("",12)
	.	S opt=$P(type(X(1)),"|",2)
	.	I opt>200,'X(3) S dqfile=1  Q		; Flat file
	.	I opt=100 S routine=1 D  Q		; Routines
	..						
	..	 I $E(X(2))="%" D
	...			S ZNAME=$$SCA^%TRNLNM("RTNS")
	...			S ZNAME=ZNAME_"_"_$E(X(2),2,99)
	...			S ZNAME=ZNAME_$$SRCEXT^%ZFUNC
	..	 E  S ZNAME=$$FILE^%TRNLNM(X(2)_$$SRCEXT^%ZFUNC,RTNDIR)
	..	 ; PAR 09/06/01
	.. 	 N RESET S RESET=$ZSEARCH(" ")	; Reset the $ZSEARCH function
	..	 ; ** New **
	..	 I $$ZSEARCH^DBSDDEXP(ZNAME)="" D LOG(ZM_" ** New **") Q	; New routine
	..	 S ZCDT=$$ZFILE^DBSDDEXP(ZNAME)			; Date Modified
	..	 S ZM=ZM_$$DAT^%ZM(+ZCDT)
	..	 I ZCDT>X(4) S ZM=ZM_" ??"
	..	 D LOG(ZM)
	.	S global=1
	.	;
	.	I (opt<2)!(opt>6) D LOG(ZM) Q  ;Screen/query/Report/QWIK
	.	;
	.	; ~p1 ** New ~p2
	.	I opt=3 D  Q				; PAR 09/06/01
	.	.	I '$D(^DBTBL(%LIBS,opt,X(2))) D LOG(ZM_" ** New "_X(1)) Q
	.	.	D LOG(ZM_$$DAT^%ZM($P(^DBTBL(%LIBS,opt,X(2)),"|",3)))
	.	I '$D(^DBTBL(%LIBS,opt,X(2),0)) D LOG(ZM_" ** New "_X(1)) Q
	.	D LOG(ZM_$$DAT^%ZM($P(^DBTBL(%LIBS,opt,X(2),0),"|",3)))
	;
	D CLOSE^SCAIO U 0 W !! I '$$YN^DBSMBAR("","Ready to import data?",1) C LOG Q
	;
	; ---------- Import log (data,time,user,location)
	;
	S ^DBIMPORT(+$H,IO)=$H_"|"_$$USERNAM^%ZFUNC_"|"_$I
	;
	S CHARSET=$$CHARSET("IMPORT1","IO2")
	I CHARSET="" S PARAMS="READ"
	E  S PARAMS="READ/ICHSET="_CHARSET
	S Z=$$FILE^%ZOPEN(IO,PARAMS,5,4096) I 'Z Q  	; *** 04/01/97
	;
	F  U IO R X Q:X="<BOH>"  D LOG(X),LOG("")	; Header Message
	;
	K HDR F I=1:1 U IO R X Q:X="<EOH>"  S HDR(I)=X,^DBIMPORT(+$H,IO,I)=X
	;
	D LOG(""),LOG(" ****** Delete Old Definitions ******"),LOG("")
	;
	S XLEV="",XNAME=""
	S Z="" F  S Z=$O(HDR(Z)) Q:Z=""  DO
	.	;
	.	S TYPE=$P(HDR(Z),"|",1),NAME=$P(HDR(Z),"|",2),DEL=$P(HDR(Z),"|",3)
	.	S LEV=$P(type(TYPE),"|",2)
	.	I LEV'=99 D LOG($J(TYPE,14)_": "_NAME)		; Skip Global
	.	;
	.	I LEV=101 X NAME				; MUMPS command
	.	I LEV=100,DEL D DEL^%ZRTNDEL(NAME,RTNDIR) 	; Delete routine
	.	I LEV=100 S routine=1 Q  			; Routine
	.	;
	.	; ---------- Delete screen and report run-time name
	.	;
	.	I LEV=6 S XLEV=6,XNAME=NAME 
	.	I ",1,2,5,10,25,33,"[(","_LEV_",") D		; *** 03/24/98
	..		S ^TMP2($J,LEV,NAME)=""			; Compiler flag
	..		S z=$P($G(^DBTBL(%LIBS,LEV,NAME,0)),"|",2)
	..		I z'="" D
	...		I (z?1A2N1"S"3.4N)!(z?1A2N1"Q"3.4N) D DEL^%ZRTNDEL(z)
        ..              I LEV=5 D
        ...                     N SORTRTN
        ...                     S SORTRTN=$P(z,"S",1)_"Z"_$P(z,"S",2)
        ...                     I $$VALID^%ZRTNS(SORTRTN) D DEL^%ZRTNDEL(SORTRTN)
	.	;						; *** 10/18/94 BC
	.	
	.	I LEV=1 K ^DBSTAT(NAME)			;1/14/98 mas
	.	I LEV=201,'DEL D 			;1/11/99 mas
	..		N X S X=""
	..		F  S X=$O(^TRN(NAME,2,X)) Q:X=""  S ^SAVETRN(NAME,X)=^TRN(NAME,2,X)
	.	I LEV=201 D DELETE^SQL("TRN WHERE ETC='"_NAME_"'")	; Tran code
	.	       ; restore authorization
        .	;I LEV=201,'DEL D                
        ..	;	N X S X=""
        ..	;	F  S X=$O(^SAVETRN(NAME,X)) Q:X=""  S ^TRN(NAME,2,X)=^SAVETRN(NAME,X)
        ..	;	K ^SAVETRN(NAME)
	. 
	.	I LEV=202,DEL D					; Tran code authorization
	..              N X S X=""
        ..              F  S X=$O(^TRN(NAME,2,X)) Q:X=""  K ^TRN(NAME,2) Q
	.	;						; CIFTYP,DTYPE,LTYPE
        .       I LEV=203!(LEV=204)!(LEV=205) K ^UTBLCTL(NAME)
        .       I LEV=203 K ^UTBLDFTC(NAME)
        .       I LEV=204 K ^UTBLDFTD(NAME)
        .       I LEV=205 K ^UTBLDFTL(NAME)
        .       ;	
	.	I LEV=96,DEL D  				; Delete data item  [fid]di
	..		N fid,di
	..		S fid=$E($P(NAME,"]",1),2,99),di=$P(NAME,"]",2)
	..		K ^DBTBL(%LIBS,1,fid,9,di)
	.	I LEV=97,DEL D            ;             *** XUS 07/22/94
	..		K ^SCATBL(1,NAME) 			; Function
	..		K ^SCATBL(3,NAME)			; Function doc
	..		K ^SCATBL(4,NAME)			; Function sub-menu
	..		;
	.	I LEV=97.5 K ^SCATBL(3,NAME)			; Function doc
	.	I LEV=98 K ^SCATBL(0,NAME)			; Menu
	.	I LEV=99,DEL X "K "_NAME			; Global
	.	I LEV<20!(LEV=25)!(LEV=33) K ^DBTBL(%LIBS,LEV,NAME)	; DQ definitions
	.	I LEV=10 F I=7,8,9,19 K ^DBTBL(%LIBS,I,NAME) 	; DQ filer *** 08/13/96
	.	;
	.	I (LEV=107)!(LEV=108)!(LEV=109)!(LEV=119) D
	..		N zlv,zfl,zelm
	..		S zlv=+$E(LEV,2,3)
	..		S zfl=$P(NAME,"/",1)
	..		S zelm=$P(NAME,"/",2)
	..		;
	..		K ^DBTBL(%LIBS,zlv,zfl,zelm)
	..		; Flag filer recompile
	..		S ^TMP2($J,10,zfl)=""
	;
	D LOG(""),LOG("****** Create Definitions ******"),LOG("")
	;
	I global D GLOBAL				; Load MUMPS globals
	;
	; Compile DQ reports
	S Z="" F  S Z=$O(HDR(Z)) Q:Z=""  DO
	.	S TYPE=$P(HDR(Z),"|",1),NAME=$P(HDR(Z),"|",2),DEL=$P(HDR(Z),"|",3)
	.	S LEV=$P(type(TYPE),"|",2)
	.	I LEV=6,'DEL S XNAME=NAME D COMPDQ
	;
	I dqfile D IMP^DBSDDEXQ				; Flat file loader
	;
	S Z="" F  S Z=$O(HDR(Z)) Q:Z=""  DO
        .       S TYPE=$P(HDR(Z),"|",1),NAME=$P(HDR(Z),"|",2),DEL=$P(HDR(Z),"|",3)
	.       I LEV=201,'DEL D
        ..              N X S X=""
        ..              F  S X=$O(^SAVETRN(NAME,X)) Q:X=""  S ^TRN(NAME,2,X)=^SAVETRN(NAME,X)
        ..              K ^SAVETRN(NAME)

	I routine D ROUTINE				; Load MUMPS routines

	D CLOSE
	Q
	;-----------------------------------------------------------------------
GLOBAL	; Private ; Create global
	;-----------------------------------------------------------------------
	U IO R X,MSG,X,Y
	D DSPHDR
	;-----------------------------------------------------------------------
GLOBAL1	;
	F  U IO R X,Y Q:X="***DONE***"  S @X=Y
	R X I X'="" R X,Y D DSPHDR G GLOBAL1
	Q
	;-----------------------------------------------------------------------
ROUTINE	; Private ; Load and compile Routines
	;-----------------------------------------------------------------------
	F  U IO R X I X="<BOP>" Q
	U IO R X,Y
	;
	U IO D EXT^%RI(IO,RTNDIR,"A",1,1,"",.ERROR)	; *** 01/15/96 BC
	I $G(ERROR)'="" D LOG(ERROR) H 3
	Q
	;----------------------------------------------------------------------
CLOSE	; End of input file
	;----------------------------------------------------------------------
	D CLOSE^SCAIO
	;
	; ---------- Compile procedure  *** 12/06/96
	;
	S Z="" F  S Z=$O(^TMP2($J,25,Z)) Q:Z=""  D COMPILE^DBSPROC(Z)
	;
	; ---------- Compile batch  *** 03/24/98 BC
	;
	S Z="" F  S Z=$O(^TMP2($J,33,Z)) Q:Z=""  D COMPILE^DBSBAT(Z)
	;
	; ---------- Compile filer	*** 08/13/96
	;
	F i=1,10 I $D(^TMP2($J,i)) D
	.	S Z="" F  S Z=$O(^TMP2($J,i,Z)) Q:Z=""  S ^TMP2($J,"F",Z)=""
	I $D(^TMP2($J,"F")) D
	.	; *** BC 09/10/96
	.	S Z="" F  S Z=$O(^TMP2($J,"F",Z)) Q:Z=""  D COMPILE^DBSFILB(Z)
	;
	;
	; ---------- Compile screens/reports
	;
	I $D(^TMP2($J,2)) DO
	.	;
	.	S ZCNTT=0
	.	;					; Compile Screens
	.	D LOG(""),LOG("Compile screens"),LOG("")
	.	K ^TEMP($J)
	.	S Z="" F  S Z=$O(^TMP2($J,2,Z)) Q:Z=""  D COMPILE(2)
	.	S ^TMP2($J,2)=ZCNTT
	.	N LOG
	.	U $P
	.	D EXT^DBSDSMC				; Screen compiler
	;
	I $D(^TMP2($J,2)) D LOG(^TMP2($J,2)_" screen(s) compiled"),LOG("")
	;
	I $D(^TMP2($J,5)) DO
	.	;
	.	S ZCNTT=0
	.	; 					; Compile Reports
	.	D LOG(""),LOG("Compile reports"),LOG("")
	.	K ^TEMP($J)
	.	S Z="" F  S Z=$O(^TMP2($J,5,Z)) Q:Z=""  D COMPILE(5)
	.	S ^TMP2($J,5)=ZCNTT
	.	N LOG
	.	D EXT^DBSRWDRV				; Report compiler
	;
	I $D(^TMP2($J,5)) D LOG(^TMP2($J,5)_" report(s) compiled"),LOG("")
	C LOG
	U $P
	I $G(%FN)="" S %FN="DBSDDIMP"		; *** BC - Restore system variables
	I '$G(%TO) S %TO=$$^CUVAR("%TO")
	;
	W $$MSG^%TRMVT("Import completed","",1)	; ** BC - Message added 08/17/93
	Q
	;-----------------------------------------------------------------------
COMPILE(OPT)	; Private ; Remove run-time routine name
	;-----------------------------------------------------------------------
	;
	S ZCNTT=ZCNTT+1
	D LOG(Z),LOG("")
	I '$D(^DBTBL(%LIBS,OPT,Z,0)) Q		; New screen/report
	S X=$P(^DBTBL(%LIBS,OPT,Z,0),"|",2)			; Run-time routine name
	I X?1A2N1"S"3.4N S $P(^DBTBL(%LIBS,OPT,Z,0),"|",2)=""	; Assign new run-time name
	S ^TEMP($J,Z)=""			; Protect DBS,FMS routines
	Q
DSPHDR	;
	D LOG(X)
	Q
	;-----------------------------------------------------------------------
IMPP	; Private ; Field Post-Processor (check valid import file name)
	;-----------------------------------------------------------------------
	N CHARSET,PARAMS,Z
	S CHARSET=$$CHARSET("IMPP","*")
	I CHARSET="" S PARAMS="READ"
	E  S PARAMS="READ/ICHSET="_CHARSET
	S Z=$$FILE^%ZOPEN(X,PARAMS,5) I 'Z S ER=1,RM=$P(Z,"|",2) C X Q
	C X						; *** 11/02/95 BC
	Q
	;
	;----------------------------------------------------------------------
LOG(Z)	;
	U LOG W !,Z
	U 0 W !,Z
	Q
RJ(X,SIZE)	;
	Q X_$J("",SIZE-$L(X))
	;
	;----------------------------------------------------------------------
EXT(IMPIO,LOG,RTNDIR) ; Import from extrnal call
	;----------------------------------------------------------------------
	;
	;	.IMPIO	File to import (name and path)	/REQ
	;	.LOG	Log file (name and path)	/NOREQ
	;	.RTNDIR	Target directory for routines	/REQ
	;	
	N X,CDT,IDT,ZCDT,ERROR,VERSION,OLNTB,IO,type,opt,ZDBTBL,HDR,IO
	K ^TMP2($J)
	;
	D INIT^DBSDDEXP,INIT1^DBSDDEXP
	;
	S X=$G(IMPIO) D IMPP^DBSDDIMP I $G(ER) Q
	;
	I $G(LOG)="" S LOG=$$SCAU^%TRNLNM("EXP","IMPORT_LOG."_$$DAT^%ZM($H,"MONDD"))
	;
	D IMPORT1
	Q
	;----------------------------------------------------------------------
COMPDQ	; Compile data qwik reports 
	;---------------------------------------------------------------------- 
	N pgm,seq
	L +^DBTBL(%LIBS,0,"Q"):10
	S seq=$G(^DBTBL(%LIBS,0,"Q"))+1
	S ^DBTBL(%LIBS,0,"Q")=seq
	L -^DBTBL(%LIBS,0,"Q")          ; R01Qnnnn format
	S pgm="R"_$E(100+^DBTBL(%LIBS,0,"L"),2,3)_"Q"_$E(10000+seq,2,5)
	S $P(^DBTBL(%LIBS,6,XNAME,0),"|",2)=pgm
	U 0
	D COMPILE^DBSEXEQ(XNAME)
	Q
	;
	;----------------------------------------------------------------------
CHARSET(LABEL,INSTNAME)	; Get alternate character set
	;----------------------------------------------------------------------
	N CHARSET
	S CHARSET=""
	I $$VALID^%ZRTNS("UCIOENCD") S CHARSET=$$^UCIOENCD("Routine","DBSDDIMP",LABEL,INSTNAME)
	Q CHARSET