SQLI	;library;Interactive SQL shell(s)
	;;Copyright(c)2000 Sanchez Computer Associates, Inc.  All Rights Reserved - 03/23/00 14:56:23 - DOUGANM
	; ORIG:	FSANCHEZ - 12/16/94
	; DESC:	Run Interactive SQL
	;
	; KEYWORDS:	DATABASE,SQL
	;
	; RELATED:
	;	. $$SQL - SQL Processor
	;
	; I18N=QUIT: Excluded from I18N standards. 
	;---- Revision History ------------------------------------------------
	; 04/25/06 - RussellDS - CR20967
	;	     Remove obsolete schema references and reference to ^DBW.
	;
	; 12/06/05 - RussellDS - CR18400
	;	     Moved NPC code here, from DBSDD.
	;
	; 04/01/05 - RussellDS - CR14908
	;	     Modify RUNPROC section to pass par("PROTECTION") to
	;	     INSERT, UPDATE, and DELETE
	;
	; 09/28/04 - RussellDS - CR12334
	;	     Added changes from Profile01 to move stored procedure table
	;	     from DBTBL18 to DBTBLSP.
	;
	; 03/23/00 - DOUGANM 37707
	;	     Modified code within PWD linetag to validate passwordd with
	;	     call to VALIDATE^SCADRV1 instead of directly to ENC^SCAENC.
	;
	; 03/15/00 - Chiang 32557 QAR #4
	;            Modified SYSVAR section to call standard utility to
	;            initialize system variables.
	;
	; 01/13/00 - Chiang 32557
	;	     Modified RUN section to initialize system variables.
	;
	;            Removed old revision history.
	;
	; 09/08/98 - Chiang 29789
	;            Modified to prompt for user ID if it's not defined.
	;
	;----------------------------------------------------------------------
	; 
	N COLUMNS,HELP,SQLIHELP,LIST,NAME,PLIST,SCRIPT
	N cmd,key
	;
	I $G(%UID)="" N %UID,%UCLS D UID I VFMQ'="F" Q
	;
	W $$CLEAR^%TRMVT()
	;
	S ER=0
	;
	S par("DIRECTORY")=$$HOME^%TRNLNM
	S par("DQMODE")=0
	S par("EXTENSION")="SQL"
	S par("FORMAT")="IMAGE"
	S par("CODE")=0
	S par("OUTPUT")=""
	S par("PLAN")=0  
	S par("STATISTICS")=0
	S par("PROTECTION")=2
	S par("STATUS")="OUTPUT,FORMAT,PROTECTION,CACHE,PLAN"
	S par("ROWS")=1
	S par("BLOCK")=20
	S par("OPTIMIZE")=1
	S par("DEBUG")=0
	S par("CACHE")=0
	;
	I $G(IO)="" S IO=$P
	D SYSVAR I ER Q
	;
	D EXEC
	Q
EXEC	;
	S par="CODE/TYP=L,DIRECTORY,DQMODE/TYP=L,EXTENSION,FORMAT"
	S par=par_",OUTPUT,PROMPT,MATCH/TYP=N,PLAN/TYP=L,ROWS/TYP=N" 
	S par=par_",PROTECTION/TYP=N,STATISTICS/TYP=L,INDEX/TYP=T,STATUS" 
	S par=par_",MASK/TYP=U,TIMEOUT/TYP=N,CACHE/TYP=L,BLOCK/TYP=N"
	S par=par_",EFD/TYP=N,USING/TYP=T"  		; EFD and hhost variable
	S par=par_",OPTIMIZE/TYP=L"                  
	S par=par_",DYNAMIC/TYY=L"
	S par=par_",DEBUG/TYP=L"  			; Debug mode
	S par=par_",DATE/TYP=D"  			; Date format
	S par=par_",DEC/TYP=T"  			; Decimal character
	S par=par_",SPVOVR/TYP=L"  			; SUPV override logic
	S par=par_",PREPARE/TYP=L"  			; ODBC column attributes
	;
	S SQLIHLP(1)=$$SCAU^%TRNLNM("HELP","SQLI.HLP")
	S SQLIHLP(2)=$$SCAU^%TRNLNM("HELP","SQL.HLP")
	S HELP(1)="Editor"
	S HELP(2)="PROFILE/SQL-Commands"
	S NAME="SQL Command" 
	S SCRIPT=$$HOME^%TRNLNM("SQLI.INI") 
	;
	S LIST("TABLES")="SELECT FID,DES,GLOBAL FROM DBTBL1"
	S LIST("COLUMNS")="SELECT DI,DES,TYP,LEN FROM DBTBL1D WHERE FID=?"
	;
	S cmd("RUN")="D RUN^SQLI(1,rec),REF^EDIT"
	S cmd("LIST")="D LIST^SQLI(1/REQ),REF^EDIT"
	S cmd("INCLUDE","PROCEDURE")="D INCPRE^SQLI(1),REF^EDIT"
	S cmd("COLUMNS")="D COLUMNS^SQLI(1/REQ)"
	S cmd("CONVERT")="D CONVERT^SQLI(1/REQ),REF^EDIT"
	S cmd("TUTORIAL")="D ^DBSTEST9,REF^EDIT"
	;
	S key("END")="RUN"
	;
	D ^EDIT(,,,,,.cmd,.key,.par,NAME,.HELP,SCRIPT)
	D SEEYA
	Q
	;
	;---------------------------------------------------------------------
INCPRE	; Load a procedure into the buffer
	;----------------------------------------------------------------------
	;
	S X=$$TRIM^%ZS($P(X," ",2,999))
	; Procedure Name required
	I X="" S ER=1,RM=$$^MSG(8568) Q
	;
	N i,str
	S str=$G(^DBTBLSP(X,1))
	; No definition for Procedure ~p1
	I str="" S ER=1,RM=$$^MSG(8610,X) Q
	;
	F i=2:1 Q:'$D(^(i))  S str=str_" "_^(i)
	;
	D BREAK^SQLCRE(str,.bfr,80-$L(PROMPT))
	Q
	;
	;----------------------------------------------------------------------
LIST(X)	; Run Script in List buffer
	;----------------------------------------------------------------------
	;
	N ER,I,exe,expr,name,par,parms,vsql,y,z
	;
	S ER=0
	;
	S par("FORMAT")="IMAGE"
	S name=$P(X," ",1),parms=$$TRIM^%ZS($P(X," ",2,999))
	;
	I name="" D  Q
	.	;
	.	N n
	.	S n=""
	.	F  S n=$O(LIST(n)) Q:n=""  W n,?12,LIST(n),!
	;
	S name=$$UPPER^%ZFUNC(name)
	;
	I $E(name)="-" D  Q				; Delete
	.	;
	.	S name=$E(name,2,$L(name))
	.	I name="" S name=$P(parms," ",1),parms=$P(parms," ",2,999) I name="" Q
	.	; List ~p1 Doesn't exist
	.	I '$D(LIST(name)) S ER=1,RM=$$^MSG(8605,name) Q
	.	; List ~p1 deleted
	.	K LIST(name) S RM=$$^MSG(8604,name)
	;
	I $E(name)="+" D  Q				; Insert
	.	;
	.	S name=$E(name,2,$L(name))
	.	I name="" S name=$P(parms," ",1),parms=$P(parms," ",2,999) I name="" Q
	.	;I parms="" S parms=$$EXPR(.bfr)
	.	; Missing LIST Arguement
	.	I parms="" S ER=1,RM=$$^MSG(8606) Q
	.	; LIST ~p1 created
	.	S LIST(name)=parms,RM=$$^MSG(8603,name)
	;
	I '$D(LIST(name)) D
	.	;
	.	S z=$O(LIST(name))
	.	; Name ~p1 not found
	.	I $E(z,1,$L(name))'=name S ER=1,RM=$$^MSG(8609,name) Q
	.	; Ambigious name ~p1
	.	I $E($O(LIST(z)),1,$L(name))=name S ER=1,RM=$$^MSG(8596,name) Q
	.	S name=z
	;
	I ER Q
	;
	S expr=LIST(name)
	;
	; User has replaced the where clause
	;
	I $TR($P(parms," ",1),"wher","WHER")="WHERE" S expr=$P(expr,"WHERE",1)_" "_parms,parms=""
	;
	S y=0
	F  S y=$F(expr,"?",y) Q:y=0  I $L($E(expr,1,y-1),"""")#2 D  Q:ER
	.	;
	.	; Missing parameter
	.	I parms="" S ER=1,RM=$$^MSG(8607) Q
	.	S z=$P(parms," ",1),parms=$P(parms," ",2,999)
	.	I $E(z)'="'" s z=$$QADD^%ZS($$UPPER^%ZFUNC(z),"'")
	.	S expr=$E(expr,1,y-2)_z_$E(expr,y,$L(expr))
	;
	I ER Q
	; More parameters than arguments ~p1
	I parms'="" S RM=$$^MSG(8608,parms) Q
	;
	U IO
	D RUNPROC(expr)
	;
	W $$MSG^%TRMVT("",0,1)
	Q
	;
	;----------------------------------------------------------------------
RUN(X,rec)	; Run an RMS file or the current Buffer
	;----------------------------------------------------------------------
	;
	S ER=0
	;
	N del,dlcr,dlsp,expr,exprnum,verrors
	;
	D SYSVAR^SCADRV0()		; Initialize system variables 01/13/00
	;
	S dlcr=$C(13,10),dlsp=" "
	S del=";"_dlcr
	;
	I $G(X)'="" N rec S rec=$$LOADFILE^EDIT(X) Q:ER
	;
	F exprnum=1:1:$L(rec,del) D
	.	;
	.	N RM,ER,sqlsta,sqldta,sqlcnt
	.	;
	.	S expr=$TR($P($G(rec),del,exprnum),dlcr,dlsp) I expr="" Q
	.	D RUNPROC(expr,.par,.sqlsta,.sqldta,.sqlcnt)
	.	;
	.	I $G(sqldta)'="" D
	..		I IO'=$P D  Q
	...			D OPEN^SCAIO 
	...			U IO W sqldta 
	..		W $$CLEAR^%TRMVT,sqldta
	.	I $G(IOTYP)'="TRM" D CLOSE^SCAIO	;6/28/96 MAS
	.	U 0					;6/28/96 MAS
	.	I '$G(ER),$D(verrors) D 
	..		N CUX,CUY,LAST,LEV1,LEV2,MSG,PWZ
	..		S LAST=$O(verrors(""),-1),LEV1="",LEV2=""
	..		F  S LEV1=$O(verrors(LEV1)) Q:LEV1=""  F  S LEV2=$O(verrors(LEV1,LEV2)) Q:LEV2=""  D
	...			; warning message
	...			S MSG="*W* "_$P(verrors(LEV1,LEV2),"|",8)
	...			S CUY=24-LAST+LEV1
	...			S CUX=1
	...			S PWZ=$S(CUY=24:1,1:0)
	...			W $$MSG^%TRMVT(MSG,0,PWZ,CUX,CUY)
	.	I '$G(ER) D  Q
	..		W $$MSG^%TRMVT($G(sqlcnt)_" Rows Processed",0,1)
	..		W $$SCR80^%TRMVT
	.	;
	.	I $D(RM)=1 W $$MSG^%TRMVT(exprnum_") "_$G(RM),0,ER)
	.	E  D DSPMSG(.RM)
	.	S exprnum=$L(rec,del)+1
	.	W $$SCR80^%TRMVT
	;
	Q 
	;
	;----------------------------------------------------------------------
SHOW	; Show variables
	;----------------------------------------------------------------------
	;
	I X'="" D  Q
	.	;
	.	I $E(X)=":" S X=$E(X,2,$L(X))
	.	I $D(@X)#2 W !,X,?12,"""",$G(@X),"""" Q
	.	I $D(@X)>1 zwr @X
	;
	N I,v
	F I=1:1:$L(VARLIST,",") D
	.	;
	.	S v=$P(VARLIST,",",I) I $E(v)=":" S v=$E(v,2,$L(v))
	.	I v["/" S v=$P(v,"/",1)
	.	I $D(@v)#2 W !,v,?12,"""",$G(@v),""""
	.	I $D(@v)>1 zwr @v
	Q
	;
	;----------------------------------------------------------------------
RUNPROC(expr,par,sqlsta,sqldta,sqlcnt)	; Run Interactive SQL Buffer
	;----------------------------------------------------------------------
	;
	N %fkey,x,z
	;
	S expr=$$TRIM^%ZS(expr)				; Remove extra blanks
	S z=$$UPPER^%ZFUNC($P(expr," ",1))
	I z="SELECT" D SELECT(expr,.par,.sqlcnt) Q
	; Pass protection parameter only
	I z="INSERT"!(z="UPDATE")!(z="DELETE") S x=$G(par("PROTECTION")) N par S par("PROTECTION")=x
	S ER=$$^SQL(expr,.par,.sqlsta,.sqldta,.sqlcnt,.sqlind)
	Q
	;----------------------------------------------------------------------
SELECT(expr,par,sqlcnt)	; Run Interactive SQL
	;----------------------------------------------------------------------
	;
	U 0
	;
	N I
	N col,del,exe,fmt,fmtr,fsn,hdg,len,linum,msk,noout
	N qwt,recdel,rows,spa,stats,tok,vdd,vsql,z
	N sqldta,sqlind,sqlcur,sqlsta
	;
	S expr=$$SQL^%ZS(expr,.tok) Q:ER
	;
	I $G(par("DEBUG")) D DEBUG I ER Q 
	;
	S expr=$E(expr,8,$L(expr))
	;
	I $G(par("PROMPT"))'="" D PROMPT(par("PROMPT"),.par)
	I $G(par("MASK"))'="" D Z6PP($G(par("MASK")))
	I $D(par("EFD")) N EFD S EFD=$$FDAT^%ZM(par("EFD")) Q:ER 
	;
	S stats=$G(par("STATISTICS")),noout=0
	I stats N tcpu,icpu,tproc,iproc,tmdb,imdb,time D INISTAT
	;
	N SELECT,FROM,WHERE,ORDER,GROUP
	S SELECT=$$TOK^SQL(expr,"FROM,WHERE,ORDER,GROUP",.tok)
	;
	I $G(SELECT)="" D ERROR($$^MSG(8569)) Q
	I $G(FROM)="" D ERROR($$^MSG(8561)) Q
	;
	; *** 12/22/97 BC
	;
	I $E(SELECT,1,4)="ALL " S SELECT=$E(SELECT,5,9999)
	I SELECT="*" S SELECT="" D  Q:ER
	.	N i
	.       F i=1:1:$L(FROM,",") S SELECT=SELECT_","_$$LIST^SQLDD($P(FROM,",",i)) 
	.       S SELECT=$E(SELECT,2,99999) 
	S fmt=$G(par("FORMAT"))
	;
	I "IMAGE"[fmt S fmt="",fmtr="|||||3|*|*|*|*|*"
	E  S fmtr=$G(^STBL("TFMT",fmt)),$P(fmtr,"|",1)=""
	;
	S qwt=$P(fmtr,"|",2),del=$P(fmtr,"|",3)
	;
	S hdg=$$HEADING^SQLFMT(FROM,SELECT,fmtr,.col,.COLUMNS,.tok,.fsn,.vdd)
	I ER Q
	;
	N %EXT,AUXPTR,HDG,IO,IOHDG,IOPAR,IORM,IOSL,IOSUB,IOTYP,PN,X,mod
	;
	S X=$G(par("OUTPUT"))
	I X="" S X=$P
	I X'=$P W $$MSG^%TRMVT("Output Directed to: "_X) H 2	; *** 11/14/97 BC
	S %EXT=1 D ^SCAIO
	D OPEN^SCAIO I ER Q
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
	U IO f i=1:1:$L(hdg,$C(13,10)) W $P(hdg,$C(13,10),i),! ; heading
	;
	S rows=$G(par("ROWS")),par("ROWS")=0
	;
	D SELECT^SQL(expr,.par,.sqlsta,.sqldta,.sqlcnt,.sqlind,.tok,-1)
	I ER Q
	;
	S par("ROWS")=rows
	;
	I $G(par("CODE")) D DSPCOD			; Display code
	I $G(par("MATCH"))=0 Q				; Exit
	;
	I vsql=0!ER Q
	;
	S recdel=$P($G(vsql("F")),"|",8) I recdel="" S recdel=$C(13,10)
	E  S recdel=$S($L(recdel,",")=1:$C(recdel),1:$C($P(recdel,",",1),$P(recdel,",",2)))
	;
	S linum=0,PN=0,noout=$S($G(col):0,1:1)
	;
	U IO
	;
z	F sqlcnt=0:1 D  Q:vsql=0  D ROWOUT Q:vsql(0)=100
	.	S vsql=$$^SQLF(.exe,.sqldta,.sqlind,.sqlcur)
	;
	D CLOSE^SQLM(0)					; Remove cursor context
	I stats D ENDSTAT
	;
	D CLOSE^SCAIO
	D OPEN^EDIT 
	;
	W $$LOCK^%TRMVT
	;
	I stats D DSPSTA			; Display Stats
	I $G(par("PLAN")) D DSPLAN		; Display Execution Plan
	Q
	;
ROWOUT	; Output a formatted row
	;
	I noout Q				; No output flag is on
	;
	I del'="" D  Q
	.	;
	.	W sqldta,recdel
	.	I IOSL S linum=linum+1 I linum'<IOSL D WAIT
	;
	N I,cptr,d,dec,jus,typ,z
	;
	S z=col(1)
	S cptr=$P(z,"|",1),typ=$P(z,"|",2),dec=$P(z,"|",3),jus=$P(z,"|",6)
	;
	S d=$P(sqldta,$C(9),1)
	I $L(d)>cptr S d=$E(d,1,cptr)
	I $P(z,"|",6)="R" S d=$J(d,cptr)
	;
	F I=2:1:col D
	.	;
	.	S z=col(I)
	.	S len=$P(z,"|",1),typ=$P(z,"|",2),dec=$P(z,"|",3),jus=$P(z,"|",6)
	.	S spa=$P(z,"|",7) I spa="" S spa=2
	.	;
	.	S z=$P(sqldta,$C(9),I)
	.	I $E($G(sqlind),I)=2 S z=$TR($J("",len)," ","*") ; display ****
	.	;
	.	S cptr=cptr+spa
	.	I jus="R" S cptr=cptr+len,d=d_$J(z,cptr-$L(d))
	.	E  S d=d_$J("",cptr-$L(d))_$E(z,1,len),cptr=cptr+len
	;
	I IO'=$P,recdel=$C(13,10) W d,!
	E  W d,recdel
	;
	I IOSL S linum=linum+1 I linum'<IOSL D WAIT
	Q
	;
	;----------------------------------------------------------------------
WAIT	; Wait for user response
	;----------------------------------------------------------------------
	;
	S linum=0
	I IO'=$P W #,hdg,! Q
	;
	I stats N z,h S z=$$PROC^%ZBEN("CPUTIM,BUFIO,DIRIO"),h=$P($H,",",2)
	;
	N x
	S PN=$G(PN)+1
	I IO=$P S x=$$^DBSMBAR(41)
	;
	I stats D
	.	S z=$$PROC^%ZBEN("CPUTIM,BUFIO,DIRIO",z)
	.	S itime=itime+$P($H,",",2)-h
	.	F I=1:1:3 S $P(iproc,",",I)=$P(iproc,",",I)+$P(z,",",I)
	;
	I x=3 S vsql(0)=100,sqlcnt=sqlcnt+1 Q
	I x=2 S noout=1 Q
	Q
	;
	;----------------------------------------------------------------------
DEBUG	; Debug option is on
	;----------------------------------------------------------------------
	;
	N lit,msg
	;
	S lit=0
	;
	D RUN^SQLTESTS(expr,lit,.msg,.par,.tok) I '$D(msg) Q
	;
	U 0
	W $$CUP^%TRMVT(1,20-$O(msg(""),-1)),$$CLP^%TRMVT
	W $C(13),?27,"**** /DEBUG Warnings ****",!
	F i=1:1 Q:'$D(msg(i))  W !,$E(msg(i),1,79)
	S x=$$^DBSMBAR(96)
	S ER=x=2
	Q
	;
	;----------------------------------------------------------------------
INISTAT	; Start Stats counter
	;----------------------------------------------------------------------
	;
	S stats=1
	;
	S tproc=$$PROC^%ZBEN("CPUTIM,BUFIO,DIRIO"),iproc=tproc
	;
	S tmdb=""
	F  S tmdb=$O(tmdb(tmdb)) Q:tmdb=""  S imdb(tmdb)=tmdb(tmdb)
	;
	S (isys,imdb,itime)=0,time=$P($H,",",2)
	Q
	;
	;----------------------------------------------------------------------
ENDSTAT	; End stats counter
	;----------------------------------------------------------------------
	;
	I stats<0 Q				; Already Accumulated
	;
	S tproc=$$PROC^%ZBEN("CPUTIM,BUFIO,DIRIO",iproc)
	;
	I $P($H,",",2)<time S time=86400-time+$P($H,",",2)-itime
	E  S time=$P($H,",",2)-time-itime
	;
	S stats=-1
	Q
	;
	;----------------------------------------------------------------------
DSPMSG(msg)	; Display messages
	;----------------------------------------------------------------------
	;
	N cy,last,i
	;
	S last=$O(msg(""),-1)
	F i=1:1 Q:'$D(msg(i))  S cy=24-last+i W $$MSG^%TRMVT(msg(i),0,$S(cy=24:1,1:0),1,cy)
	Q
	;
	;----------------------------------------------------------------------
DSPCOD	; Display executable code
	;----------------------------------------------------------------------
	;
	I '$G(exe) Q
	I $ZMODE="BATCH" zwr exe Q	;Do NOT PROMPT
	;
	U 0
	W !,$$MSG^%TRMVT("Display executable code",0,1),!
	W $$CLEAR^%TRMVT
	W $$LOCK^%TRMVT
	;
	; Display default DQ mode join syntax
	;
	I $G(par("DQMODE")),$G(vsql("I"))["," W $$DQJOIN^SQLJ(vsql("I")),!!
	zwr exe					; Display code
	;
	S PN=0
	;					; Continue ?
	S x=$$^DBSMBAR(41)
	I x=3 S vsql=0 Q			; Reach end of table
	I x=2 S noout=1 Q			; Suppreess output
	;
	U IO I IO'=$P Q
	;
	W $$CLEAR^%TRMVT			; Clear screen 
	W $$LOCK^%TRMVT($L(hdg,$C(13))+1)	; Lock header region
	;
	W hdg,!					; Disply column header
	Q
	;
	;----------------------------------------------------------------------
DSPLAN	; Display Index Access Plan
	;----------------------------------------------------------------------
	;
	I '$D(vsql("P")) Q
	;
	W !,$$MSG^%TRMVT("Database Access Plan",0,1)
	U 0
	W !,"Index",?13,"Primary Keys",?46,"Cost",?52,"Code  Distribution",!
	;
	N index
	;
	S index="" F  S index=$O(vsql("P",index)) Q:index=""  D
	.	;
	.	S z=vsql("P",index)
	.	W !,index
	.	W ?13,$E($P(z,"|",2),1,30)
	.	W ?44,$J($P(z,"|",4)+.05,7,0)
	.	W ?52,$J($P(z,"|",5),3)
	.	W ?57,$E($P(z,"|",3),1,22)
	W !
	Q
	;
	;----------------------------------------------------------------------
DSPTOT	; Display Total at end of file
	;----------------------------------------------------------------------
	;
	U IO
	W !,vsql(1),!
	;
	S rec=$$MEM^SQLM("T") I rec="" Q
	;
	F I=2:1:$L(rec,$c(28)) D
	.	;
	.	S z=$P(rec,$C(28),I),col=+z,dta=$P(z,$C(29),2)
	.	S ptr=0
	.	F  S expr=$$NPC(dta,.ptr,"/") D  Q:'ptr
	..		;
	..		S fun=$P(expr,"=",1),v=$P(expr,"=",2)
	..		I $G(tot)'[fun S tot=$G(tot)_fun_"/"
	..		S line=$L($P(tot,fun,1),"/")
	..		;
	..		I '$D(tot(line)) S tot(line)=fun
	..		S tot(line)=tot(line)_$J("",col-$L(tot(line)))
	..		S tot(line)=tot(line)_v
	;
	F line=1:1 Q:'$D(tot(line))  W tot(line),!
	Q
	;
CONTAIN(A,B)	Q (","_A_",")[(","_B_",")
	;
	;----------------------------------------------------------------------
DSPSTA	; Display Resource Stats at end of file
	;----------------------------------------------------------------------
	;
	D ENDSTAT
	;
	; Resource Stats
	W !,$$MSG^%TRMVT($$^MSG(8611),0,1)
	;
	W !," RUN=",$$DAT^%ZM(+$H,.%MSKD)," @ "
	W $$TIM^%ZM($P($H,",",2),"24:60")
	;
	W " - TIM=",$$TIME^%ZBEN(time*100)
	W " - CPU=",$$TIME^%ZBEN($P(tproc,",",1))
	W " - BUFIO=",$P(tproc,",",2)
	W " - DIRIO=",$P(tproc,",",3),!
	;
	I $D(vsql("C")) D
	.	W !
	.	W " INDEX="
	.	;
	.	I $P(vsql("C"),"|",5)="" W $P(vsql("G"),",",1)
	.	E  W $P(vsql("C"),"|",5)
	.	;
	.	W ?35," DENS=",$P(vsql("C"),"|",3)
	.	W " - COST=",$P(vsql("C"),"|",4)
	.	I $P(vsql("C"),"|",6) W " - JOIN=",$P(vsql("C"),"|",6)
	.	W !
	;
	N f
	S tmdb=""
	F  S tmdb=$O(tmdb(tmdb)) Q:tmdb=""  D
	.	;
	.	S z=tmdb(tmdb),f=1
	.	F I=2:1:$L(z,",") D
	..		;
	..		N cat
	..		S cat=$P(z,",",I)
	..		I $P(cat,":",2) W:f !,tmdb,?10 W $J($TR(cat,":","="),12) S f=0
	;
	W !
	Q
	;
	;----------------------------------------------------------------------
PROMPT(list,par)	; Prompt for attributes
	;----------------------------------------------------------------------
	;
	N i,p,z,X
	;
	F i=1:1:$L(list,",") D
	.	;
	.	S z=$P(list,",",i)
	.	I '(","_par[(","_z)) Q
	.	;
	.	S z=z_$P($E(","_par_",",$F(","_par,","_z),9999),",",1)
	.	S p=$P(z,"/",2,999),z=$P(z,"/",1)
	.	W $$CUP^%TRMVT(1,pb+2),z_": ",cll
	.	;
	.	S X=$G(par(z)) I $G(X)'="" W X,$$CUB^%TRMVT($L(X))
	.	S X=$$TERM^%ZREAD($G(X))
	.	D SET^EDIT(z_" "_X)
	;
	Q
	;
	;----------------------------------------------------------------------
SEEYA	; Exit program
	;----------------------------------------------------------------------
	;
	W $$LOCK^%TRMVT
	W $$CLEAR^%TRMVT
	Q
	;
	;---------------------------------------------------------------------
COLUMNS(X)	; Set column attributes for SELECT list
	;----------------------------------------------------------------------
	;
	;  col(colnum)=Length|Type|Decimal|Format|Heading|Justify|Spaces|Math 
	;
	S list=",LENGTH,TYPE,DECIMAL,FORMAT,HEADING,JUSTIFY,SPACE,MATH,"
	;
	N tok,I
	;
	S ER=0
	S X=$$SQL^%ZS(X,.tok)
	I ER Q
	;
	S col=$P(X," ",1)
	I col'?1N.N S ER=1,RM="Column Number required" Q
	;
	I $P(X," ",2)="" D SHOWCOL Q
	;
	F I=2:2:$L(X," ") S attr=$P(X," ",I),value=$P(X," ",I+1) D  Q:ER
	.	;
	.	;I value="" S ER=1,RM="Missing attribute value" Q
	.	I value[$C(0) S value=$$UNTOK^%ZS(value,tok)
	.	I value["""" S value=$$QSUB^%ZS(value)
	.	;
	.	S z=$L($P(list,(","_attr),1),",")
	.	I z+2>$L(list,",") S ER=1,RM="Invalid column attribute "_z Q
	.	;
	.	S $P(COLUMNS(col),"|",z)=value
	.	I value="" S value="(Default)"
	.	S RM=$P(list,",",z+1)_"="_value
	;
	Q
	;
	;---------------------------------------------------------------------
SHOWCOL	; SHOW column attributes
	;----------------------------------------------------------------------
	;
	N i,z
	;
	S z=$G(COLUMNS(col))
	S RM="Column "_col
	;
	F i=1:1:$L(z,"|") I $P(z,"|",i)'="" S RM=RM_" "_$P(list,",",i+1)_" "_$P(z,"|",i)
	;
	Q
	;
	;----------------------------------------------------------------------
CONVERT(RID)	; Convert SELECT statement into a RW report 
	;----------------------------------------------------------------------
	N sql,key,type
	S type=$p(RID," ",1),RID=$P(RID," ",2)          ; Report type and name 
	S type=$$UPPER^%ZFUNC(type) 
	S type=$S(type="REPORT":5,type="QWIK":6,1:0) 
	I 'type S ER=1,RM="Invalid Report Type" Q       ; Invalid type 
	; 
	I $G(RID)="" S ER=1,RM="Missing report name" Q  ; Missing RW name 
	S sql=$TR(rec,$C(13,10)," ")                    ; Remove delimiters 
	I sql="" Q                                      ; Invalid SQL statement 
	; 
	D SQLRW^DBSRWQR(sql,RID,type)                   ; Convert to RW format 
	I $G(ER),$G(RM)="" Q 
	I $G(ER) W $$MSG^%TRMVT(RM,"",1) Q              ; Error 
	I '$$YN^DBSMBAR("","Run Report?",1) Q           ; Run it now? 
	I type=5 D 
	.       D ^DBSRW(RID,0,1)                       ; Compile it first 
	.       D RPT^URID                              ; Run report 
	I type=6 D 
	.       D COMPILE^DBSEXEQ(RID)                  ; Compile QWIK report 
	.       S QRID=RID D QRPT^URID 
	W $$CLEAR^%TRMVT 
	Q
	;----------------------------------------------------------------------
EXT	; Entry point for function DBSMSQL
	;----------------------------------------------------------------------
	N cmd,key,%MSKC,%MSKD,%MSKL,%MSKN,%MSKE
	N IO,VFMQ,%FRAME,%READ,%TAB,z1,z2,z3,z4,z9
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZT^SQLI")
	S ER=0
	;
	S z9="MSQL Run-Time Parameters"
	S z1=1,(z2,z3)=0,z4=0,z5="IMAGE",z6="US",z7=0,IO=$P
	S %TAB("z1")="/DES=DATA-QWIK Mode/TYP=L"
	S %TAB("z2")="/DES=Display Procedural Code/TY=L"
	S %TAB("z3")="/DES=Display Optimization Plan/TYP=L"
	S %TAB("z4")="/DES=Data Item Protection Option/TYP=N/LEN=1/TBL=^DBCTL(""SYS"",""RWPROT"","
	S %TAB("z5")="/DES=Output Format/TYP=T/TBL=[STBLTFMT]"
	S %TAB("z6")="/DES=I18n Format Mask/TYP=T/TBL=^DBCTL(""SYS"",""*RFMT"",/XPP=D Z6PP^SQLI(X,1)"
	S %TAB("z7")="/DES=SQL Statement Cache option/TYP=L"
	S %TAB("IO")=$$IO^SCATAB()
	S %READ="@z9/CEN/REV,IO,z1,z2,z3,z4,z5,z6,z7"
	S %FRAME=2,%NOPRMT="F"
	D ^UTLREAD I VFMQ="Q" Q
	;
	;
	S par("DIRECTORY")=$$HOME^%TRNLNM 
	S par("DQMODE")=z1
	S par("EXTENSION")="SQL"
	S par("PROTECTION")=z4
	S par("FORMAT")=z5
	S par("CODE")=z2
	S par("CACHE")=z7
	S par("OUTPUT")=IO
	S par("PLAN")=z3  
	S par("STATS")=0
	S par("STATUS")="DQMODE,FORMAT,PROTECTION,CACHE"
	S par("ROWS")=20
	;
	D SYSVAR I ER Q
	;
	D Z6PP(z6)
	D EXEC
	Q
SYSVAR	;Init PBS system variables
	; 
	N i,list,x,y 
	D SYSVAR^SCADRV0()			; 03/15/2000
	;
	S %LOGID=$$LOGID^SCADRV
	; 
	D ^UTLO S TLO=UTLO 
	Q 
Z6PP(X,opt)	;
	I $G(opt) S RM=""
	I X="" Q				; *** 12/16/97
	I '$D(^DBCTL("SYS","*RFMT",X)) S ER=1,RM=$$^MSG(1485) Q
	F N="$","N","D","C","L" S z=^DBCTL("SYS","*RFMT",X,N) DO
	.	;
	.	S zz="%MSK"_$TR(N,"$","E") ;		Translate $ - E
	.	S @zz=$S($P(z,"|",2)["$$":$P($P(z,"|",2),$c(34),2),1:$P(z,"|",6))
	.	I $G(opt) S RM=RM_$E(zz,5)_"="_@zz_"  "
	;
	Q
	;
ERROR(M)	;
	S ER=1
	I $G(M)="" S M="Syntax error"
	S RM=M Q
	;
	;----------------------------------------------------------------------
ZT	; Mumps error
	;----------------------------------------------------------------------
	;
	S %ZTHALT=0 D ZE^UTLERR ; Log MUMPS error
	; Error Log Sequence #~p1
	I $D(%ZTSEQ) S %ZTSEQ=$$^MSG(3389,%ZTSEQ)
	;
	; Log error in exception file
	;----------------------------------------------------------------------
	;
	I $G(ET)="" S ET=$G(RM)
	;
	D LOG^UTLEXC($T(+0),"*","","",$G(%ZTSEQ),$G(ET))
	K ET,%ZTSEQ
	Q
UID	;
	N PWD
	S %TAB("%UID")=".UID1/HLP=[SCAU]UID/TBL=[SCAU]" 
	S %TAB("PWD")=".PWD1/XPP=D PWD^SQLI" 
	S %READ="%UID/REQ,PWD/REQ/SEC" D ^UTLREAD 
	Q
PWD	;
	I $$VALIDATE^SCADRV1(X) S %UCLS=$P(^SCAU(1,%UID),"|",5) Q   ;Valid password 
	; Invalid - Re-enter 
	S ER=1,RM=$$^MSG(8301) 
	Q
	;
NPC(v,ptr,del)	;private; Return Next Unquoted Piece
	;----------------------------------------------------------------------
	;
	N y
	S y=$F(v,del,ptr) I y=0 S v=$E(v,ptr,$L(v)),ptr=0 Q v
	I $L($E(v,ptr,y-1),"'")#2 S v=$E(v,ptr,y-2),ptr=y Q v
	F  S y=$F(v,del,y) Q:'y  I $L($E(v,ptr,y-1),"'")#2 Q
	S v=$E(v,ptr,$S(y:y-2,1:$L(v))),ptr=y
	Q v
