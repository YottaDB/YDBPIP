SQLTESTF	;Private;QA/Test MSQL from a file
	;;Copyright(c)2001 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/18/01 11:23:39 - CHENARDP
	; ORIG:	CHIANG - 09/20/95
	; DESC:	QA/Test MSQL/QWIK Report interface
	;
	; KEYWORDS:	MSQL,QWIK Report
	;
	; INPUTS:
	;	. %LIBS				/TYP=T/DEF=^CUVAR("%LIBS")
	;
	; RELATED:
	;	. $$RUN^SQLI - MSQL API
	;
	;I18N=QUIT
	;
	;---- Revision History ------------------------------------------------
	; 04/18/01 - CHENARDP - 43811
	;	     Modified to correct error when selecting data
	;	     DBTMP global needed to be killed.
	;
	; 03/16/99 - John Du  - ARQ 32298
	;	     Replaced %LIBS="PRD" with %LIBS="SYSDEV".
	;
	;----------------------------------------------------------------------
	I $G(%LIBS)="" N %LIBS S %LIBS=^CUVAR("%LIBS")
	I $g(%TOKEN)="" N %TOKEN S %TOKEN=$J
	;
	N TJD,dsp,line,par,quit,rms,mat,rng,stat,test,x,z,zpar
	;
	S mat=3,rng="ALL",rms="/home/chenardp/SQL.TEST"
	S IO="/home/chenardp/SQL.OUT"
	S par="/NODQMODE/NODEBUG/NOCACHE/OPTIMIZE/PROTECTION=0"
	S dsp="/CODE/ACCESS/DATA/NOSTATISTICS/VSQL"
	S $P(line,"-",30)=""
	;
	S %TAB("rms")="/DES=Input Filename"
	S %TAB("par")="/DES=SQL Parameters/TYP=T/LEN=70"
	S %TAB("dsp")="/DES=Display Parameters/TYP=T/LEN=50"
	S %TAB("mat")="/DES=Match Count/TYP=N/LEN=3"
	S %TAB("rng")="/DES=Test # Range/TYP=T/LEN=40"
	S %TAB("IO")=$$IO^SCATAB()
	;
	S %READ="@@%FN,,rms/REQ,IO/REQ,mat,par,dsp,rng"
	D ^UTLREAD I VFMQ="Q" Q
	;
	D IO(rms,"READ") I ER W $$MSG^%TRMVT(.RM) Q
	;
	D OPEN^SCAIO					; Open output device
	S %LIBS=$$^CUVAR("%LIBS")
	;
	I $G(dsp)'=""  D PARSPAR^%ZS(dsp,.dsp)		; Display Parameters
	;
	S TLO=$I,%UID=1,TJD=^CUVAR(2),%CRCD="USD" 
	D ZBINIT^%TRMVT(),TERMSET^SCADRV 
	;
	I mat="" S mat=1E18
	I rng="ALL" S rng=""
	;
	I IO'=$P U IO W "SQL Parameters:",?20,par,!,"Display Parameters:",?20,dsp,!!
	;
	S expr="",flag=0,quit=0,test=0
	S zpar=par
	I $G(par("DEBUG")) K ^ZSQLERR
	;
	F numrec=1:1 U rms Q:$ZEOF  R rec D  Q:quit
	.	;
	.	I rec="" Q
	.	I $E(rec,1,2)="/*" U IO W !,rec Q
	.	I rec=";" D  Q
	..		;
	..		S flag='flag
	..		I flag S test=test+1
	..		I rng,'$$CONTAIN(rng,test) Q
	..		;
	..		U IO 
	..		;
	..		I flag W !,$$LINE("Test # "_test),!,rec,! Q
	..		;
	..		W rec,!,$$LINE(""),!
	..		;
	..		D RUN(expr,zpar) S expr="",zpar=par
	..		I IO=$P S quit='$$YN^DBSMBAR("","Next Report?",1)
	..		U $P W ! I IO'=$P W "Test # ",test,!
	.	;
	.	I 'flag Q
	.	I rng,'$$CONTAIN(rng,test) Q
	.	;
	.	I expr="",$E(rec)="/" S zpar=zpar_rec
	.	E  S expr=expr_rec_" "
	.	;
	.	U IO W rec,! I IO'=$P U $P W rec,!
	;
	C rms
	U IO W !
	C IO
	Q
	;
	;----------------------------------------------------------------------
RUN(expr,par)	; MSQL interface 
	;----------------------------------------------------------------------
	;
	U IO
	K ^DBTMP(%TOKEN),vsql,exe
	;
	I expr="" Q
	;
	N data,exe,fsn,sqlsta,sqldta,sqlcnt,stat,tok,vdd,vsql,RM
	;
	I $G(par)'=""  D PARSPAR^%ZS(par,.par)		; User Override
	;
	I $$NEW^%ZT N $ZT 
	S @$$SET^%ZT("ET^"_$T(+0)) 
	;
	S ER=0
	;
	I mat=0 S mode=-1
	E  S mode=1
	;
	S stat=$G(dsp("STATISTICS"))
	;
	I stat S dsp("ACCESS")=0 D INISTAT^SQLI
	; 
	S expr=$$SQL^%ZS(.expr,.tok) I ER Q
	;
	I $E(expr,1,7)'="SELECT " S ER=1,RM="Invalid SQL expression"
	E  D
	. I $G(par("DEBUG")) S RM=$$DEBUG^SQLTESTS(expr,.par,.tok) 
	. I ER D JOINERR S ER=0,RM=""
	. S expr=$E(expr,8,$L(expr))
	. D SELECT^SQL(expr,.par,.sqlsta,.sqldta,.sqlcnt,.sqlind,.tok,mode)
	;
	I $G(ER) W !!,$$LINE("*** ERROR ***"),!,$G(RM),! Q
	;
	I $G(dsp("ACCESS")),$D(vsql("C")) W !,vsql("C"),!
	;
	I $D(vsql("P"))>1 D
	.	;
	.	W !,$$LINE("ACCESS PLAN"),!
	.	S n=""
	.	F  S n=$O(vsql("P",n)) Q:n=""  W n,?14,vsql("P",n),!
	;
	I $G(dsp("CODE")) D
	.	;
	.	S n=""
	.	F  S n=$O(exe(n)) Q:n=""  W !,$J(n,2),"| ",$TR(exe(n),$C(255),"~")
	.	W !
	;
	I '$G(mat) Q
	;
	S data=$G(dsp("DATA")) I data W !,$$LINE("DATA"),!
	;
	F sqlcnt=1:1:mat S vsql=$$^SQLF(.exe,.v) Q:vsql=0  I data W v,!
	;
	I vsql=0 S sqlcnt=sqlcnt-1
	;
	I sqlcnt W !,sqlcnt," Records Selected",!
	I stat D DSPSTA^SQLI
	Q
	;
	;----------------------------------------------------------------------
JOINERR	; Error on join syntax
	;----------------------------------------------------------------------
	N i,seq,ln,z
	W !!," *** ERROR *** ",$G(RM),!!
	S ln=1,seq=$O(^ZSQLERR(""),-1)+1
	S ^ZSQLERR(seq,0)=RM			; Error condition
	F i=1:70 S z=$E(expr,i,i+69) Q:z=""  S ^ZSQLERR(seq,ln)=z,ln=ln+1
	Q
	;----------------------------------------------------------------------
DSPERR	; Display error log
	;----------------------------------------------------------------------
	K
	U 0 R !,"Short display: ",DSP
	S $P(line,"-",35)=""
	D ^SCAIO
	U IO
	S seq="",ln=""
	F  S seq=$O(^ZSQLERR(seq)) Q:seq=""  D
	.	W !,line,seq,line,!,";",!,"/* "_^ZSQLERR(seq,0),!,"/* "
	.	S ln=0,z=""
	.	F  S ln=$O(^ZSQLERR(seq,ln)) Q:ln=""  W !,"/* ",^(ln) S z=z_^(ln)
	.	I DSP="N" W !,z
	.	W !,";"
	W !!
	C IO
	q	 
	;----------------------------------------------------------------------
ET	;
	;----------------------------------------------------------------------
	;
	I $ZS[",%GTM-E-CTRAP," S quit=1 Q
	;
	W !!,$$LINE("*** ERROR ***")
	W !!,$ZS,!
	I $D(vsql) ZWR vsql
	Q
	;----------------------------------------------------------------------
LINE(x)	;
	;----------------------------------------------------------------------
	;
	N line,y
	S $p(line,"-",81)=""
	I $L(x)=0 Q line
	S y=78-$L(x)\2
	Q $E(line,1,y)_" "_x_" "_$E(line,1,y)
	;
INIT	;
	D SYSVAR^SQLI
	S CONAM=^CUVAR("CONAM")
	Q
	;
	;----------------------------------------------------------------------
IO(IO,IOPAR)	; Initialize Device's
	;----------------------------------------------------------------------
	;
	I $G(IOPAR)="" S IOPAR="NEWV"
	S OK=$$FILE^%ZOPEN(IO,IOPAR)
	I 'OK S ER=1,RM=$P(OK,"|",2)
	Q
	;
	;----------------------------------------------------------------------
QREPORT	; Write Qwik Report SQL to a file
	;----------------------------------------------------------------------
	;
	N IO,rid,sql,sql,frm,whr,oby,test
	;
	S IO=$P
	;
	S %TAB("IO")=$$IO^SCATAB()
	;
	S %READ="@@%FN,,IO/REQ"
	D ^UTLREAD I VFMQ="Q" Q
	;
	D OPEN^SCAIO					; Open output device
	;
	U IO
	;
	S %LIBS="SYSDEV"
	;
	S rid="",test=0
	F  S rid=$O(^DBTBL(%LIBS,6,rid)) Q:rid=""!($E(rid)="z")  D
	.	I $G(^(rid,-3))'="" Q			; Implicit
	.	;
	.	N sql,sql,frm,whr,oby
	.	D QRPT^SQLCONV(rid,.sql,.sel,.frm,.whr,.oby)
	.	S test=test+1
	.	W $$LINE("Test # "_test),!,";",!
	.	;
	.	I $G(sel)'="" D OUT("select",sel)
	.	I $G(frm)'="" D OUT("from",frm)
	.	I $G(whr)'="" D OUT("where",whr)
	.	I $G(oby)'="" D OUT("order by",oby)
	.	W ";",!
	Q
	;
OUT(cmd,expr)	; Output SQL expression -- pretty
	;
	W cmd
	;
	N i
	F  D  Q:expr=""
	.	;
	.	I $L(expr)<70 W ?9,expr,! S expr="" Q
	.	F i=70:-1:1 Q:", "[$E(expr,i)
	.	I i=1 S i=$L(expr)
	.	W ?9,$E(expr,1,i-($E(expr)=" ")),!
	.	S expr=$E(expr,i+1,$L(expr))
	Q
CONTAIN(X,Y)	Q ","_X_","[(","_Y_",") 
	;
	;----------------------------------------------------------------------
QAJOIN	; Test DQJOIN^SQLJ logic
	;----------------------------------------------------------------------
	N files,sql,v,RID,IO  
	I $G(%LIBS)="" N %LIBS S %LIBS=^CUVAR("%LIBS")
	D ^SCAIO U IO
	S RID=""
	F  S RID=$O(^DBTBL(%LIBS,5,RID)) Q:RID=""  D
	.	S v=$G(^(RID,0))			; Report header
	.	S files=$P(v,"|",1)			; Access files
	.	I files'["," Q				; Single file
	.	S sql=$$DQJOIN^SQLJ(files)		; Left outer join
	.	W !,RID,?15,files,!,?15,sql
	W !
	D CLOSE^SCAIO
	Q
	;----------------------------------------------------------------------
CACHE	; Build test data from SQL currently stored in the cache table
	;----------------------------------------------------------------------
	;
	N line
	S $P(line,"-",30)=""
	D ^SCAIO
	S vsql=$$OPEN^SQLM(.exe,"SQLCACHE","EXPR") I ER Q ; Open cursor
	; 
	F i=1:1 S vsql=$$^SQLF(.exe,.v) Q:vsql=0  D ; Fetch record
	.	U IO W line," Test ",i," ",line,!		; --- Test ---
	.	D CACHE1
	.	W "Select ",v,!,";",!			; ;
	C IO							; SQL statement
	Q							; ;
CACHE1	;
	N i
	W ";",!,"/*",!
	F i=1:70 S z=$E(v,i,i+69) Q:z=""  W "/* ",z,!
	W "/*",!
	Q
	;----------------------------------------------------------------------
EXTRACT	; Extract SQL statements from a RMS file 
	;----------------------------------------------------------------------
	;
	S rms="HOME:SQLTEST.1230",fid="RELCIF",IO="HOME:REL.REL"
	S $P(line,"-",30)=""
	S msg="Extract SQL statements"
	S %TAB("rms")="/DES=Input File"
	S %TAB("fid")="/DES=Table Name"
	S %TAB("IO")="/DES=Output File/XPP=S %EXT=1 D ^SCAIO"
	;
	S %READ="@msg/CEN/REV,,rms/REQ,IO/REQ,fid/REQ"
	D ^UTLREAD I VFMQ="Q" Q
	;
	D OPEN^SCAIO
	S i=1
	D IO(rms,"READ") I ER W $$MSG^%TRMVT(.RM) Q
	F numrec=1:1 U rms Q:$ZEOF  R v D 
	.	I v'[fid Q
	.	I v'["Select" Q
	.	U IO W line," Test ",i," ",line,!		; --- Test ---
	.	S i=i+1
	.	D CACHE1
	.	W v,!,";",!			; ;
	;
	C IO,rms
	Q
