DBE	;;DBS - UTL - V5.0 - Direct Mode Database Editor
	;;Copyright(c)1995 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/02/95 10:37:00 - ZENGF
	;     ORIG:  FSANCHEZ - 28 DEC 1992
	;    CALLS:  ^DBSEDIT,SCADRV,UTLO,UTLREAD
	;     DESC:  This utility is used to view or modify a DATA-QWIK
	;	     database in direct mode.
	;	
	;
	;---- Revision History ------------------------------------------------
	; 05/11/06 - Allan Mattson - CR20048
	;            Replaced occurrences of $C(255) with the value returned
	;            from $$getPslValue^UCOPTS("maxCharValue").
	;
	;            Replaced calls to $$UPPER^%ZFUNC with $$UPPER^SCAUTL.
	;
	; 12/06/05 - RussellDS - CR18400
	;	     Remove reference to HEADING^DBSDD.  The tag did not
	;	     exist in DBSDD.
	;
	;	     Moved NPC code here, from DBSDD.
	;
	; 09/17/04 - RussellDS - CR8102
	;	     Remove main levelwhich called DBEENTRY^DBSTBLM.  No longer
	;	     appears to be used anywhere, and DBSTBLM rewritten to PSL.
	;
	;	     Remove old revision history.
	;
	;-----------------------------------------------------------------------
	;
	;
	Q
	;
	;----------------------------------------------------------------------
EXT(RSO)	; External prompt interface (opt=R-Report, F=Form)
	;----------------------------------------------------------------------
	;
	D TERMSET^SCADRV			; Terminal Parameters
	D UID I $G(%UID)="" Q 0			; Define Driver Context
	D CLCNCT^SCADRV				; Client connect API
	;
TOP	N BANNER,FILES,HDR,VO,%FRAME,%READ,%TAB,OLNTB,OP,TABLE,VQRY
	;
	I '$D(%LIBS) S %LIBS=$$^CUVAR("%LIBS")
	;
	S %FRAME=1,%NOPRMT="F",OLNTB=0
	S (opt,oby,sel,whr,fmt,frm,IO)=""
	;
	S %TAB("frm")=".FRM3/TBL=[DBTBL1]:LIST"
	S %TAB("oby")=".OBY1/TBL=@SELDI^DBSFUN(frm,X)"
	S %TAB("sel")="/TYP=T/LEN=500/SIZ=78/TBL=@SELDI^DBSFUN(frm,X):LIST:NOVAL/XPP=D SELPP^DBE(frm,.X)"
	S %TAB("whr")="/TYP=T/LE=78/SIZ=255/XPP=S FILES=frm D ^DBSQRY"
	;
	S %READ="@@%FN,"
	I $G(RSO)="R" D 
	.	;
	.	S IO=""
	.	S TABLE="ADHOCR"
	.	S %READ=%READ_",.NAME4/TBL=[UTBLADHOCR]:NOVAL:QU VQRY/VAR=NAME/XPP=D DEFPP^DBE"
	.	S %READ=%READ_",[DBTBL6E]TFMT/XPP=D PPFMT^DBE/VAR=fmt/TBL=[DBTBL6E]/REQ"
	.	S %READ=%READ_",.IO4/TBL=[DEVICE]DEVNAME/XPP=I X'="""" S %EXT=1 D ^SCAIO/VAR=IO"
	.	I $D(^DBCTL("SYS","TFMT","IMAGE")) S fmt="IMAGE"
	E  D
	.	S TABLE="ADHOCF"
	.	S OP=",0#Add,1#Modify,2#Inquire,3#Delete"
	.	S %TAB("frm")=%TAB("frm")_"/XPP=D FILEPP^DBE"
	.	S %TAB("opt")=".OPT1/TBL="_OP
	.	S %READ=%READ_",opt,",OP=""
	.	S %READ=%READ_",.NAME4/TBL=[UTBLADHOCF]:NOVAL:QU VQRY/VAR=NAME/XPP=D DEFPP^DBE"
	;
	S %READ=%READ_",frm/REQ,oby,,"""_$$^MSG(2465)_""",,sel"
	S %READ=%READ_",,"""_$$^MSG(2337)_""",,whr*3"
	;
	S VQRY="UTBL"_TABLE_".UID="_%UID
	D ^UTLREAD
	I VFMQ="Q" Q 0
	;
	I NAME'="" D SAVEDEF(TABLE,NAME)		; Save the definition
	I $G(IO)="" S X=$P,%EXT=1 D ^SCAIO
	Q 1
	;
	;----------------------------------------------------------------------
DEFPP	;	Post Processor Load for Definition
	;----------------------------------------------------------------------
	;
	I X="" Q
	D LOADDEF(TABLE,X) I frm="" Q
	;S vdsp=2 D VW^UTLREAD
	D VDA^UTLREAD,^DBSPNT(0,2)		; Redisplay Form
	Q
	;
	;----------------------------------------------------------------------
LOADDEF(TABLE,NAME)	; Load the definition name into local variables
	;----------------------------------------------------------------------
	;
	S z=$G(^UTBL(TABLE,%UID,NAME)) I z="" Q
	;
	S frm=$P(z,"|",1),sel=$P(z,"|",2),oby=$P(z,"|",3)
	S whr(1)=$P(z,"|",4),whr(2)=$P(z,"|",5)
	S brk=$P(z,"|",6),fmt=$P(z,"|",7),IO=$P(z,"|",8)
	Q
	;
	;----------------------------------------------------------------------
SAVEDEF(TABLE,NAME)	; Save a local definition name
	;----------------------------------------------------------------------
	;
	S $P(z,"|",1)=$G(frm)
	S $P(z,"|",2)=$G(sel)
	S $P(z,"|",3)=$G(oby)
	S $P(z,"|",4)=$G(whr(1))
	S $P(z,"|",5)=$G(whr(2))
	S $P(z,"|",6)=$G(brk)
	S $P(z,"|",7)=$G(fmt)
	S $P(z,"|",8)=$G(IO)
	S ^UTBL(TABLE,%UID,NAME)=z
	Q
	;
	;----------------------------------------------------------------------
UID	; Prompt for User ID in direct mode
	;----------------------------------------------------------------------
	;
	S ER=0
	;
	N drvlist,UTLO,SCAU,X,PWD,ENC,KVAR,%READ,HDR
	N VFMQ,PGM,PFID,DFID,FID,%NOPRMT
	;
	S drvlist="%TO|300,CONAM,%ET" 
	D LIST^CUVAR(drvlist),INIT^%ZM(.drvlist) 
	S %LOGID=$$LOGID^SCADRV 
	; 
	S %="|",%NOPRMT="F" 
	D ^UTLO S TLO=UTLO 
	; 
	I $G(%UID)'="",$G(%UCLS)'="" Q
	;
	S %READ="@@%FN,,.UID1/VAR=%UID/REQ,.PWD1/VAR=PWD/SEC/REQ"
	S %FRAME=2
	;
	D ^UTLREAD I VFMQ="Q" S ER=1 Q
	;
	S SCAU=$G(^SCAU(1,%UID))			; Load User Record
	S X=PWD D ^SCAENC				; Check encryption
	; Invalid password 
	I ENC'=$P(SCAU,"|",6) S RM=$$^MSG("1419"),ER=1 Q  ; "Invalid password" 
	;
	S %UCLS=$P(SCAU,"|",5)
	Q 
	;
	;---------------------------------------------------------------------- 
SELPP(frm,X)	; List Post Processor 
	;---------------------------------------------------------------------- 
	; 
	I $E(X)'="*" Q 
	; 
	N I,z 
	; 
	S z=$E(X,2,$L(X)) 
	F I=1:1:$L(z,"/") I "/NODE/REQ/EXCEPT"'[$P($P(z,"/",I),"=",1) S ER=1 Q 
	; Valid qualifiers are * (all) or *NODE=node or *REQ 
	I ER S RM=$$^MSG("2917") Q 
	;S X=$$GETLIST($P(frm,",",1),$e(X,2,$L(X)))
	Q 
	;
	;----------------------------------------------------------------------
GETLIST(file,expr,comp)	; Generate a list base on wildcard input and qualifiers
	;----------------------------------------------------------------------
	;
	S ER=0
	;
	N req,nodes,except,I,qfy,val
	N libr,maxCharV,sel,nod,pos,di,z
	;
	S maxCharV=$$getPslValue^UCOPTS("maxCharValue")
	;
	S nodes="",except="",req="",sel=""
	S expr=$$UPPER^SCAUTL($G(expr))
	;
	F I=1:1:$L(expr,"/") D
	.	;
	.	S z=$P(expr,"/",I) I z="" Q
	.	S qfy=$P(expr,"=",1),val=$P(expr,"=",2,99)
	.	;
	.	I $E("REQ",1,$L(qfy))=qfy S req=1 Q
	.	I $E("NODES",1,$L(qfy))=qfy S nodes=val Q
	.	I $E("EXCEPT",1,$L(qfy))=qfy S except=val Q
	.	; Unrecognized Qualifier ~p1
	.	I qfy'="" S ER=1,RM=$$^MSG("5517",qfy) Q
	;
	I ER Q ""
	;
	S z=$$LIB^DBSDD(file,"","",.vdd)		; Resolve Implicit
	S libr=$P(z,".",1),file=$P(z,".",2) I file="" Q ""
	;
	I '$D(vfsn(file)) D fsn^DBSDD(.vfsn,file) Q:ER
	;
	S sel=$P(vfsn(file),"|",3)			; Access keys
	;
	I nodes="" D
	.	;
	.	I req S sel=$G(^DBTBL(libr,1,file,102)) Q
	.	S z="" 
	.	F  S z=$O(^DBINDX(libr,"STR",file,z)) Q:z=""  S nodes=nodes_z_","
	;
	I (expr="*")!(expr="") D
	.	N sel1 S sel1=$G(^DBTBL(libr,1,file,102))
	.	F I=1:1:$L(sel1,",") D
	..		I '$$CONTAIN(sel,$P(sel1,",",I)) S sel=sel_","_$P(sel1,",",I) 
	S pos="",di=""
	;
	F I=1:1 S nod=$P(nodes,",",I),pos="" Q:nod=""  D
	.	F  S pos=$O(^DBINDX(libr,"STR",file,nod,pos)),di="" Q:pos'?1N.N  D
	..		F  S di=$O(^DBINDX(libr,"STR",file,nod,pos,di)) Q:(di="")!(di=$C(maxCharV))  D
	...			I '$G(comp),$$CMP^DBSDD(file_"."_di)'="" Q
	...			I '$$CONTAIN(sel,di) S sel=sel_","_di
	;
	I except'="" F I=1:1:$L(except,",") S di=$P(except,",",I) I di="" I $$CONTAIN(sel,di) S sel=$$SUBLIST(sel,di)
	;
	F  Q:$E(sel)'=","  S sel=$E(sel,2,$L(sel))
	Q sel
	;
	;----------------------------------------------------------------------- 
SUBLIST(LIST,DI)	; Subtract a Data Item from a list 
	;----------------------------------------------------------------------- 
	;
	N I,z
	F I=1:1:$L(LIST,",") I $P(LIST,",",I)=DI D  Q
	.	S z=$P(LIST,",",I+1,999)
	.	S LIST=$P(LIST,",",1,I-1)
	.	I LIST'="",z'="" S LIST=LIST_","
	.	S LIST=LIST_z
	;
	Q LIST
	;
CONTAIN(A,B)	Q (","_A_",")[(","_B_",")
	;
	;----------------------------------------------------------------------
REPORT	; External prompt interface
	;----------------------------------------------------------------------
	;
	N ER,FILES,HDG,I,IO,IOSL,IORM,IOSUB,IOTYP,Q,QD,VFMQ
	;
	S ER=0
	;
	I '$$EXT("R") Q
	D OPEN^SCAIO I ER Q
	;
	N exe,fsn,join,msk,new,noout,rec,tcpu,tproc,tmdb,tmo,icpu,iproc,imdb,vdd,vsql
	;
	U 0 I IO=$P W $$CLEAR^%TRMVT
	;
	S fid=$P(frm,",",1)
	D fsn^DBSDD(.fsn,fid)
	;
	S tproc=$$PROC^%ZBEN("CPUTIM,BUFIO,DIRIO"),iproc=tproc
	D GVLIST^%ZBEN(.tmdb)
	S tmdb=""
	F  S tmdb=$O(tmdb(tmdb)) Q:tmdb=""  S imdb(tmdb)=tmdb(tmdb)
	;
	S (isys,imdb)=0
	;
	S time=$P($H,",",2),itime=0,idle=0
	;
	S vsql=$$OPEN^DBSFETCH(.exe,frm,sel,.Q,oby,.join,fmt,.tmo,.mat,22)
	I vsql=0 G EXIT
	;
	I $D(vsql("I")) D CONT G EXIT:vsql=0
	;
	S del=""
	I fmt'="" S del=$$RETREC^DBSDD("DBTBL6E","DEL",fmt)
	;
	I $D(vsql("H")) F I=1:1 Q:'$D(vsql("H",I))  S HDG(I)=vsql("H",I)
	E  S HDG(1)=""
	;
	S HDG=$O(HDG(""),-1)
	I sel="" S IOSL=1E18,IORM=80,noout=1
	E  D
	.	S noout=0,IORM=80
	.	F I=1:1:HDG I $L(HDG(I))>IORM S IORM=$L(HDG(I))
	.	I '$G(IOSL) S IOSL=$S($P=IO:23,1:60)
	.	S IOSL=IOSL-HDG+1
	.	I $G(IOTYP)'="TRM",$G(IOSUB)'="VT" Q
	.	S $X=0,$Y=0 D TERM^%ZUSE($I,"WIDTH="_(IORM+1)_"/ECHO")
	.	I IORM>80 W $$SCR132^%TRMVT
	.	W $$CLEAR^%TRMVT
	.	W $$LOCK^%TRMVT(HDG+1)
	.	F I=1:1:HDG W HDG(I),!
	.	S HDG=0
	;
	F PN=1:1 D  Q:vsql=0
	.	;
	.	U IO
	.	I 'noout,HDG D
	..		F I=1:1:HDG W HDG(I),!
	..		I del S HDG=0			; Display once only
	.	;
	.	S vsql=$$FETCHBLK^DBSFETCH(.exe,.IOSL,noout)
	.	I IO'=$P!(vsql=0) Q
	.	;
	.	U $P
	.	S z=$$PROC^%ZBEN("CPUTIM,BUFIO,DIRIO")
	.	S vfreez=$P($H,",",2)
	.	;
	.	; Page: PN Next,End,Quit
	.	;
	.	S x=$$^DBSMBAR(41)	; *** BC - 01/05/94
	.	;
	.	S z=$$PROC^%ZBEN("CPUTIM,BUFIO,DIRIO",z)
	.	S itime=itime+$P($H,",",2)-vfreez
	.	F I=1:1:3 S $P(iproc,",",I)=$P(iproc,",",I)+$P(z,",",I)
	.	;
	.	I x=3 S vsql=0 Q
	.	I x=2 S noout=1 Q
	;
	N dta,expr,col,line,len,ptr,rec,tot,v,z
	;
	S rec=$$MEM^DBSFETCH("T")
	I rec'="" D DSPTOT				; Display report totals
	I IO=$P D DSPSTA				; Display run statistics
	;
EXIT	;
	I '$G(ER) N RM
	;
	I IO'=$P C IO Q
	W !,$$MSG^%TRMVT($G(RM),0,1),$$LOCK^%TRMVT,$$SCR80^%TRMVT
	D CLOSE^SCADRV
	Q
	;
	;----------------------------------------------------------------------
DSPTOT	; Display Total at end of file
	;----------------------------------------------------------------------
	;
	U IO
	W !,$P(rec,$C(28),1),!
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
	;----------------------------------------------------------------------
DSPSTA	; Display Resource Statistics at end of file
	;----------------------------------------------------------------------
	;
	; I18N=OFF
	W !," RUN=",$$DAT^%ZM(+$H,.%MSKD)," @ "
	W $$TIM^%ZM(time,"24:60")
	;
	I $P($H,",",2)<time S time=86400-time+$P($H,",",2)-itime
	E  S time=$P($H,",",2)-time-itime
	;
	S tproc=$$PROC^%ZBEN("CPUTIM,BUFIO,DIRIO",iproc)	; Net
	S z=$P(tproc,",",1)
	;
	W " - TIM=",$$TIME^%ZBEN(time*100)
	W " - CPU=",$$TIME^%ZBEN($P(tproc,",",1))
	W " - BUFIO=",$P(tproc,",",2)
	W " - DIRIO=",$P(tproc,",",3),!
	; I18N=ON
	;
	I $D(vsql("G")) W ! F I=1:1 S z=$G(vsql("G",I)) Q:z=""  W $P(z,"|",1),?50,$P(z,"|",3),?60,$P(z,"|",4),!
	;
	D GVLIST^%ZBEN(.tmdb,.imdb)
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
	Q
	;
	;----------------------------------------------------------------------
CONT	; Open or fetch timeout - Continue
	;----------------------------------------------------------------------
	;
	N x
	; Timeout: Continue,Quit
	U $P S x=$$^DBSMBAR(133)	; *** BC - 01/05/94
	I 2[x S vsql=0 Q
	S vsql=$$RESUME^DBSFETCH(.exe,.vsql,.rec)
	Q
	;
	;----------------------------------------------------------------------
PPFMT	; Post Processor for FMT 
	;----------------------------------------------------------------------
	;
	I X="" Q
	;
	N z
	S z=$$RETREC^DBSDD("DBTBL6E","DFTDIR,DFTSFX,HDR",X) Q:ER
	I $G(NAME)="" S IO=$P(z,"|",1) S:IO'="" IO=IO_":" S:$P(z,"|",2)'="" IO=IO_"*."_$P(z,"|",2)
	;
	S HDR=$P(z,"|",3)
	D DISPLAY^DBSMACRO("@HDR",HDR)
	D DISPLAY^DBSMACRO("@IO",IO)
	Q
	;
	;--------------------------------------------------------------------
FILEPP	; File Name Post processor
	;-------------------------------------------------------------------
	;
	I X="" Q
	I $G(opt)=2 Q
	;
	N vscreen,vfile
	S vfile=$P(X,",",1)                           ; get first file
	S vscreen=$G(^DBTBL(%LIBS,1,vfile,22)),vscreen=$P(vscreen,"|",8) ; get  data entry screen
	I vscreen'="" D PROTECT^DBSMACRO("@sel")      ; protect the select field
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
