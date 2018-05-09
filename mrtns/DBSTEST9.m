DBSTEST9	;Private;Test routine for PROFILE/SQL project
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 12/31/97 08:19:59 - CHIANG
	; ORIG:	CHIANG - 08/15/95
	; DESC:	Test routine for PROFILE/SQL
	; 
	;I18N=QUIT
	;
	;---------- Revision History ------------------------------------------
	; 05/17/06 - Allan Mattson - CR20048
	;            Replaced calls to $$UPPER^%ZFUNC with $$UPPER^SCAUTL.
	;
	; 12/31/97 - Chiang - 27244
	;            Modified to correct <UNDEF> error on variable "recdel".
	;
	; 04/01/97 - Chiang - 24160
	;            Modified to replace DBCTL lookup table syntax with STBLTFMT
	;----------------------------------------------------------------------
	S IOINPUT=$$SCAU^%TRNLNM("HELP","sql.hlp")
	S IO=$P
	S MSG="PROFILE/SQL QUERY Test Utility"
	S (z1,z2,z3)=0,z4=1,z5="IMAGE",z6="US",z8=5
	S %TAB("z1")="/DES=DATA-QWIK Mode/TYP=L"
	S %TAB("z2")="/DES=Display Procedural Code/TY=L"
	S %TAB("z3")="/DES=Display Optimization Plan/TYP=L"
	S %TAB("z4")="/DES=Outer Join/TYP=L"
	S %TAB("z5")="/DES=Output Format/TYP=T/TBL=[STBLTFMT]"
	S %TAB("z6")="/DES=Format Mask/TYP=T/XPP=D Z6PP^SQLI(X,1)"
	S %TAB("z8")="/DES=Maximum Record Count/TYP=N/LEN=10/MIN=1"
	S %TAB("IOINPUT")=".IO2/DES=SQL commands input file"
	S %TAB("par(""XCODE"")")=".%A26/DES=Execute MSQL Command"
	S %READ="@MSG/CEN/REV,IOINPUT,z1,z2,z3,z4,z5,z6/REQ,z8"
	S %FRAME=2,%NOPRMT="F"
	D ^UTLREAD I VFMQ="Q" Q
	;
	S par="BUFFER/TYP=N,CODE/TYP=L,DIRECTORY,EXTENSION,FORMAT/TBL=DBTBL6E,"
	S par=par_"JOIN/TYP=L,OUTPUT,PROMPT,MATCH/TYP=N,PLAN/TYP=L," 
	S par=par_"STATISTICS/TYP=L,OPTIMIZE/TYP=L,STATUS,DQMODE/TYP=L" 
	;
	S par("BUFFER")=20
	S par("DIRECTORY")=$$HOME^%TRNLNM
	S par("DQMODE")=z1
	S par("EXTENSION")="SQL"
	S par("FORMAT")=z5
	S par("CODE")=z2
	S par("JOIN")=z4
	S par("MATCH")=z8
	S par("OUTPUT")=IO
	S par("PLAN")=z3  
	S par("STATISTICS")=0
	S par("OPTIMIZE")=1
	S par("STATUS")="OUTPUT,FORMAT,JOIN,PLAN"
	D SYSVAR^SCADRV0("PBS")				; Init system variables
	D Z6PP^SQLI(z6)
	;
	;
	;
	S depcid=$O(^XCLSACN("D",""))			; First deposit account
	S cid=depcid+200				; First account + 200
	S cr=$C(13,10)					; CR.LF
	S par("BUFFER")=20				; Fetch buffer size
	S par("EXTENSION")="SQL" 
	S par("OPTIMIZE")=1 
	S par("STATUS")="CODE,OUTPUT,FORMAT,JOIN,PLAN" 
	;
	S TLO=$I,%UID=1,TJD=^CUVAR(2),%CRCD="USD"
	;
	S ET=0,ER=0
	I $G(REPEAT) D REPEAT Q
	S Z=$$FILE^%ZOPEN(IOINPUT,"READ",10,$G(RECSIZ))
	Q:ER
	S IO=$P
	I '$$INTRACT^%ZFUNC() D  Q:ER
	.	S IO=$$TRNLNM^%ZFUNC("SYS$LOGIN")
	. 	S IO=IO_"SQLQRY.OUTPUT"
	. 	S Z=$$FILE^%ZOPEN(IO,"WRITE/NEWV",10,$G(RECSIZ))
	S GETOUT=1
	F  D  Q:ET!(GETOUT=2)
	.	U IO W #
	.	D READ
	.	Q:$G(EXEC(1))=""
	.	D EXEC
	C IOINPUT,IO
	Q
REPEAT	;
	f j=1:1:REPEAT d
	.	U 0 W !,"Count: ",j
	.	S Z=$$FILE^%ZOPEN(IOINPUT,"READ",10,$G(RECSIZ))
	.	S GETOUT=1
	.		F  D  Q:ET!(GETOUT=2)
	..			U IO W #
	..			D READ
	..			Q:$G(EXEC(1))=""
	..			D EXEC
	.	C IOINPUT
	Q
READ	
	K EXEC
	S QUIT=0
	S I=1,COUNT=0
	F  D  Q:QUIT  
	.	S EXEC(I)=$$RTB^%ZFUNC($$^%ZREAD(IOINPUT,.ET)) I ET S QUIT=1 Q 
	.	S COUNT=COUNT+1	;
	.	I $A($E(EXEC(I)))=12 D  Q
	..		U IO
	..		S:I>0 QUIT=1
	..		S EXEC(I)=""
	.	I $P(EXEC(I),"~2",2)'="" D  Q
	..		S par=$P(EXEC(I),"~2",2) D PARSPAR^%ZS(.par,.par)
	..		U IO W !,par
	.	I $P(EXEC(I),"~1",2)'="" D  Q
	..		S XVAL=$P(EXEC(I),"~1",2) X XVAL
	..		U IO W !,XVAL
	.	U IO W !,$S($E(EXEC(I),1)="$":$E(EXEC(I),2,1000),1:EXEC(I))
	.	F J=1:1 S TMP=$E(EXEC(I),J) Q:TMP'=" "&(TMP'=$C(9))
	.	S EXEC(I)=$E(EXEC(I),J,200)
	.	I $$UPPER^SCAUTL($E(EXEC(I),1,2))="S " X EXEC(I) Q
	.	I $E(EXEC(I),1)["$" S I=I+1
	I IO=$P,$ZMODE'="BATCH" U IO W $$MSG^%TRMVT("","",1) W #	; "Continue" message
	Q
EXEC	;
	S X=""
	F I=1:1 Q:EXEC(I)=""!(EXEC(I)["$RUN")  D
	.	I $E(EXEC(I))'="$" Q
	.	S EXEC(I)=$$RTB^%ZFUNC($E(EXEC(I),2,1000))
	.	I EXEC(I)="" Q
	.	F J=1:1 S TMP=$E(EXEC(I),J) Q:TMP'=" "&(TMP'=$C(9))
	.	S EXEC(I)=$E(EXEC(I),J,1000)   
	.	I $$UPPER^SCAUTL($E(EXEC(I),1,2))="S " X X Q
	.	S X=X_$S(X'=""&($E(EXEC(I))'="_")&($E(EXEC(I))'=",")&($E(X,$L(X))'=","):" ",1:"")_EXEC(I)
	I $$RTB^%ZFUNC(X)="" Q
	I X["INSERT",X["CIF.NEXTVAL" D  Q:ER
	.	S X=$P(X,"CIF.NEXTVAL",1)_ACN_$P(X,"CIF.NEXTVAL",2)
	I X["INSERT",X["DEP.NEXTVAL" D  Q:ER
	.	S X=$P(X,"DEP.NEXTVAL",1)_CID_$P(X,"DEP.NEXTVAL",2) 
	I X["INSERT",X["LN.NEXTVAL" D  Q:ER
	.	S X=$P(X,"LN.NEXTVAL",1)_CID_$P(X,"LN.NEXTVAL",2) 
	U IO W ! D RUN
	Q
RUN	;
	K ER,RM
	S ER=0,RM=""
	D RUNP(X)					; Execute command
	I IO=$P,$ZMODE'="BATCH" U IO W $$SCR80^%TRMVT			; Reset screen
	I $G(ER) U IO W !,RM,!				; Display error message
	I IO=$P,$ZMODE'="BATCH" U IO S GETOUT=$$^DBSMBAR(161)
	Q
	;---------------------------------------------------------------------- 
RUNP(rec)	; Run an RMS file or the current Buffer 
	;---------------------------------------------------------------------- 
	; 
	S ER=0 
	; 
	N del,dlcr,dlsp,expr,exprnum 
	S dlcr=$C(13,10),dlsp=" " 
	S del=";"_dlcr 
	; 
	I $G(%TOKEN)="" S %TOKEN=$P($G(%LOGID),"|",6) I %TOKEN="" S %TOKEN=$J
	; 
	F exprnum=1:1:$L(rec,del) D 
	.       ; 
	.       N RM,ER,sqlcod,sqldta,sqlcnt 
	.       ; 
	.       S expr=$TR($P($G(rec),del,exprnum),dlcr,dlsp) I expr="" Q 
	.       D RUNPROC(expr,.par,.sqlcod,.sqldta,.sqlcnt) 
	I IO=$P,$ZMODE'="BATCH" W $$MSG^%TRMVT("",0,1)
	Q
	;----------------------------------------------------------------------
RUNPROC(expr,par,sqlcod,sqldta,sqlcnt)	; Run Interactive SQL Buffer
	;----------------------------------------------------------------------
	;
	N %fkey,tok
	;
	S ER=0
	;
	S expr=$$SQL^%ZS(.expr,.tok) I ER Q
	S z=$P(expr," ",1),expr=$E(expr,$L(z)+2,$L(expr))
	;
	I z="SELECT" D SELECT(expr,.par,.tok,.sqlcnt) Q
	I z="FETCH" D FETCH^SQL(expr,.par,.sqlcod,.sqldta,.sqlcnt,.sqlind) Q
	I z="EXECUTE" D EXECUTE^SQL(expr,.par,.sqlcod,.sqldta,.sqlcnt,.sqlind,.tok) Q
	I z="INSERT" D INSERT^SQL(expr,.par,.sqlcod,.sqldta,.sqlcnt,.sqlind,.tok) Q
	I z="UPDATE" D UPDATE^SQL(expr,.par,.sqlcod,.sqldta,.sqlcnt,.sqlind,.tok) Q
	I z="BUFFER" D BUFFER^SQL(expr,.par,.sqlcod,.sqldta,.sqlcnt,.sqlind,.tok) Q
	I z="DELETE" D DELETE^SQL(expr,.par,.sqlcod,.sqldta,.sqlcnt,.sqlind,.tok) Q
	I z="OPEN" D OPEN^SQL(expr,.par,.sqlcod,.sqldta,.sqlcnt,.sqlind,.tok) Q
	I z="DROP" D DROP^SQL(expr,.par,.sqlcod,.sqldta,.sqlcnt,.sqlind,.tok) Q
	I z="CREATE" D ^SQLCRE(expr,.par,.sqlcod,.sqldta,.tok) Q   ;mas (params)
	S ER=1,RM=$$^MSG(8564,z)
	Q
	;
	;----------------------------------------------------------------------
SELECT(expr,par,tok,sqlcnt)	; Run Interactive SQL
	;----------------------------------------------------------------------
	;
	U 0
	;
	N col,cnt,del,exe,fmt,fmtr,fsn,hdg,linum,msk,noout,qwt,rows,stats,vdd,vsql
	N sqldta,sqlind,sqlcur
	;
	I $G(par("MASK"))'="" D Z6PP^SQLI($G(par("MASK")))
	;
	S stats=$G(par("STATISTICS")),noout=0
	I stats N tcpu,icpu,tproc,iproc,tmdb,imdb,time D INISTAT^SQLI
	;
	N SELECT,FROM,WHERE,ORDER,GROUP
	S SELECT=$$TOK^SQL(expr,"FROM,WHERE,ORDER,GROUP",.tok)
	;
	I $G(SELECT)="" D ERROR^SQLI($$^MSG(8569)) Q
	I $G(FROM)="" D ERROR^SQLI($$^MSG(8561)) Q
	I $G(GROUP)'="" D ERROR^SQLI($$^MSG(8562)) Q
	;
	S fmt=$G(par("FORMAT"))
	;
	I "IMAGE"[fmt S fmt="",fmtr="|||||3|*|*|*|*|*"
	E  S fmtr=$G(^STBL("TFMT",fmt)),$P(fmtr,"|",1)=""
	;
	S qwt=$P(fmtr,"|",2),del=$P(fmtr,"|",3),msk=$P(fmtr,"|",7,11)
	;
	I msk'="" F I=1:1:5 D
	.	;
	.	S z=$P(msk,"|",I)
	.	I z="*" S z=$G(@$P("%MSKD,%MSKL,%MSKC,%MSKE,%MSKN",",",I)) I z="" S z=$P("MM/DD/YY,NY,12:60 AM,.",",",I)
	.	S $P(msk,"|",I)=z
	;
	I del'="" S del=$C(del)
	I qwt'="" S qwt=$C(qwt)
	;
	S hdg=$$HEADING^SQLFMT(FROM,SELECT,fmtr,.col,.COLUMNS,.tok,.fsn,.vdd)
	I ER Q
	;
	N AUXPTR,HDG,IOHDG,IOPAR,IORM,IOSL,IOSUB,IOTYP,X
	;
	;
	S IORM=80
	F I=1:1:$L(hdg,$C(13)) I $L($P(hdg,$C(13),I))>IORM S IORM=$L($P(hdg,$C(13),I))
	I '$G(IOSL) S IOSL=$S($P=IO:23,1:60)
	S IOSL=IOSL-$L(hdg,$C(13))+1
	;
	I fmtr'="",IO'=$P S IOSL=0				; No page breaks
	;
	I $G(IOTYP)="TRM" D
	.	;
	.	S $X=0,$Y=0 D TERM^%ZUSE($I,"WIDTH="_(IORM+1)_"/ECHO")
	.	I IORM>80 W $$SCR132^%TRMVT
	.	W $$CLEAR^%TRMVT
	.	W $$LOCK^%TRMVT($L(hdg,$C(13))+1)
	;
	;
	U IO W hdg,!
	;
	S par("FORMAT")=""				; Internal format
	S (saverows,rows)=$G(par("ROWS")),par("ROWS")=0
	D SELECT^SQL(expr,.par,.sqlcod,.sqldta,.sqlcnt,.sqlind,.tok,1)
	S par("FORMAT")=fmt,par("ROWS")=saverows
	;
	I $G(par("CODE")) U IO D DSPCOD^SQLI
	;
	I vsql=0!ER Q
	;
	S linum=0,PN=0,noout=$S($G(col):0,1:1)
	;
	U IO
	;
	;
	S recdel=$C(13,10)	; jpb 10/9/97
	;
	I '$G(NODSPLY) F sqlcnt=0:1 S vsql=$$FETCH^SQLM(.exe,.sqldta,.sqlind,.sqlcur) Q:vsql=0  D ROWOUT^SQLI Q:vsql=0
	;
	D CLOSE^SQLM(" ")			; Remove cursor context
	I stats U IO D ENDSTAT^SQLI
	;
	D OPEN^EDIT 
	;
	W $$LOCK^%TRMVT
	;
	I stats D DSPSTA^SQLI			; Display Stats
	I $G(par("PLAN")) D DSPLAN^SQLI		; Display Execution Plan
	Q
