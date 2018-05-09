SQLCRE(expr,par,sqlsta,sqldta,tok)	;public;SQL Library of SQL Create Functions
	;;Copyright(c)2001 Sanchez Computer Associates, Inc.  All Rights Reserved - 12/15/01 01:31:48 - SPIER
	; ORIG:	FSANCHEZ - 12/16/94
	; DESC:	This program contains a library of SQL functions used to
	;       create stored procedures.
	;
	; KEYWORDS:	DATABASE
	;
	; RETURNS:
	;	. $$	Error Status		/TYP=T
	;
	; RELATED:
	;	. SQL - SQL Interpreter
	;----------------------------------------------------------------------
	; I18N=QUIT: Exculded from I18N standards. 
	;----------------------------------------------------------------------
	;---------- Revision History ------------------------------------------
	; 07/10/07 - Pete Chenard - CR28171
	;	     Replaced references to $C(255) with $$BYTECHAR^SQLUTL(255)
	;  	     for unicode compliance.
	;
	; 10/12/06 - Pete Chenard - CR23583
	;	     Modified COMPILE section to recognize situations where 
	;	     a line of code sets vsql=vsql+n, in addition to the current
	;	     check for setting vsql=n.
	;
	; 07/26/06 - RussellDS - CR22121
	;	     Added %DB to exclusive new in BUILDSP to prevent later
	;	     undedefined.
	;
	; 05/03/04 - Pete Chenard - CR13875
	;            Retrofitted changes made to the Profile01 version by Pete
	;            Chenard (additional parameter to SPSEL() and in calls to
	;            SAV^SQLCACHE().
	;            Added passing SQL statement type in par("_sqltype") (proc.
	;            SPSEL()).
	;            Added tying of ^TMPCACHE(,,i), ^(i+.4), and ^(i+.5):
	;            Modified procedure SPSEL() to call KILL^SQLCACHE().
	;
	;      Removed "PURGE" and "DELETE" sections.  
	;      The table "DBTBL18" - 'DATA-QWIK SQL Stored Procedures'
	;            and Function "DBSSPP" - 'Delete Stored Procedures" were
	;	     obsoleted.
	;
	; 09/28/04 - RussellDS - CR12334
	;	     Replaced obsoleted calls to ^DBSANS1 with new procedure
	;	     DBSGETID.
	;
	;	     Added changes from Profile01 to move stored procedure table
	;	     from DBTBL18 to DBTBLSP. Removed PURGE and DELETE - obsoleted.
	;
	; 12/13/01 - SPIER - 48677
	;            Modified Delete section to kill TMPCACHE entry when deleting a SP
	;	     This prevents cahe entries from looping after a SP delete.
	;
	; 04/08/01 - Spier - 44495 ipb reported error
	;	      correct error in COMPILE section that would
	;	      cause stored procedures to repeat the return value
	;	      because passed by ref sqldta was being set to null in the 
	;	      OPEN section prior to its use.
	;
	;----------------------------------------------------------------------
	; 
	I $P(expr," ",1)="PROCEDURE" S expr=$P(expr," ",2,99) D CREPRC(expr) Q
	;
	D CREATE^SQLTBL(expr) 				; Create table statement
	I '$G(ER) S sqlcnt=1
	Q			
	;----------------------------------------------------------------------
CREPRC(expr)	; Create a stored procedure
	;----------------------------------------------------------------------
	;
	I '$D(%LIBS) N %LIBS S %LIBS="SYSDEV"
	;
	N AS,args,fsn,spnam,sptype,z
	;
	S spnam=$$TOK^SQL(expr,"AS",.tok)			; format the statement
	S spnam=$$FUN^SQL(spnam,.args,tok)			; get SP name
	I spnam="" S ER=1,RM=$$^MSG(8568) Q			; Missing name
	I $L(spnam)>20 S ER=1,RM=$$^MSG(3037,spnam,20) Q 	; Invalid name
	;
	I $G(AS)="" S ER=1,RM=$$^MSG(8577) Q			; Invalid statement
	;
	S sptype=$P(AS," ",1)					; SQL type (INSERT/UPDATE/DELETE/SELECT)
	S AS=$E(AS,$L(sptype)+2,$L(AS))				; Remove keyword
	;							; 
	I ",SELECT,INSERT,UPDATE,DELETE,"'[(","_sptype_",") S ER=1,RM=$$^MSG(8564,expr) Q		; Invalid command
	;
	I $G(par("DEBUG")) S RM=$$DEBUG^SQLTESTS("SELECT "_AS,.par,.tok) I ER Q 
	;
	D SPSEL(AS,spnam,.par,.args,0,sptype)			; Match/create one
	Q
	;
	;----------------------------------------------------------------------
SPSEL(AS,spnam,par,args,nolink,sptype,sphk)	; Create a stored procedure
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;
	;     . AS	SQL select statemnet	/TYP=T/REQ/MECH=REFVAL
	;     . spnam	Stored procedure name	/TYP=T/REQ/MECH=REFVAL
	;     . par     SQL qualifier		/TYP=T/NOREQ/MECH=REFVAL
	;     . args    List of host variables  /TYP=T/NOREQ/MECH=REFVAL
	;     . nolink  Do not link routine     /TYP=L/NOREQ/DEF=N/MECH=REFVAL
	;     . sptype	Procedure Type		/TYPE=T/REQ/MECH=VAL
	;     . sphk    Hash Key                /TYP=T/NOREQ/MECH=VAL
	;----------------------------------------------------------------------
	N I,colatt,exe,vsql,scache,vdd,zpar
	N c,goto,hk,lin,oldsts,rtn,seq,spas,str
	;
	; System assigned, exit if one already on file
	;
	S spnam=$g(spnam)						; 04/20/99
	I $g(sptype)="" S sptype="SELECT"				; Default type
	S par("_sqltype")=sptype					; pass to called procs
	S RM=""								; Stored procedure name is NULL or *
	I "*"[spnam D  Q:"*"'[spnam  S spnam="*"			; Try to match it with the same hash key
	.	;
	.	I $G(sphk)="" S sphk=$$ELFHASH^%ZFUNC(AS_$$PARS^SQLCACHE(.par))	; Hash key
	.	I '$D(^DBINDX("SYSDEV","SPHK",sphk)) Q  			; No match
	.	S spnam="",sqldta=""					; 
	.	F  S spnam=$O(^DBINDX("SYSDEV","SPHK",sphk,spnam)) Q:spnam=""  D  Q:sqldta'=""  ; Match
	..		S z=$G(^DBTBLSP(spnam)) I z="" Q		; Missing definition
	..		S seq="",spas=""				; Try to match SQL statement
	..		F  S seq=$O(^DBTBLSP(spnam,seq)) Q:seq=""  S spas=spas_^DBTBLSP(spnam,seq)
	..		I spas=AS S RM=spnam_"-"_$p(z,"|",6)_"-"_$p(z,"|",7),sqldta=RM Q  ; name-date-time
	;
	; no match, create a new one
	;
	S nolink=$G(nolink)
	S scache=$G(par("CACHE")),par("CACHE")=0
	;
	D PARSE(sptype,AS)			; Build exe() array 
	;
	; Record size too large
	;
	S I="" F  S I=$O(exe(I)) q:I=""  I $$BSL^SQLUTL(exe(I))>500 S ER=1,RM=$$^MSG(2338) Q
	I ER Q
	;
	S par("CACHE")=scache
	;
	I '$D(exe) Q
	;
	I "*"'[spnam L +^DBTBLSP(spnam):5
	;
	S z=$G(^DBTBLSP(spnam))
	S oldsts=z					; Save old definiiton
	S rtn=$P(z,"|",1)
	;						; Replace old SP with a new one
	I z'="" D					; Delete old definitions
	.	;
	.	N expr,i,par
	.	D PARSPAR^%ZS($P(z,"|",4),.par)
	.	S expr=$$SPSQL^SQLCACHE(spnam)	; Hash key
	.	I $G(sphk)="" S sphk=$$ELFHASH^%ZFUNC(expr_$$PARS^SQLCACHE(.par))
	.	;
	.	K ^DBTBLSP(spnam)		; delete old definition
	.	K ^DBINDX(%LIBS,"SPHK",sphk,spnam)	; delete hash key index
	.	I $$LOD^SQLCACHE(expr,.par,sphk,.i)'="" D
	..		;
	..		; 05/03/04, FSCW replaced by DO KILL^SQLCACHE(sphk,i)
	..		D KILL^SQLCACHE(sphk,i)
	;
	I rtn="" D					; Create new SP name
	.	L +^DBTBL("SYSDEV",0,"P"):30
	.	S c=$G(^DBTBL("SYSDEV",0,"P"))+1,^("P")=c	; next sequence
	.	;					; 06/30/99
	.       ; Don't release the lock if this process is under TP fence, 
	.       ; otherwise identical run-time routines will be created by 
	.       ; separate servers 
	.       ; 
	.       I '$Tlevel L -^DBTBL("SYSDEV",0,"P")       ; 
	.       S c=$E(10000000+c,2,99)                 ; Procedure name S0000000 
	.	S rtn="S"_c				; Run-time SP_seq
	.	I "*"[spnam S spnam=rtn			; Same as the SP name
	;
	I sptype="SELECT" D COMPILE(.exe,.vsql,.par,rtn,spnam,AS) 	; Create run-time routine
	;
	I $E($G(exe(.1)))="*" S exe(.1)=rtn_" ;"	; Routine name
	;
	D ^%ZRTNCMP(rtn,"exe",nolink)  			; Compile routine
	;
	I $G(par("ODBC")) D LINK^PBSUTL("SCA$IBS",rtn)	; Link it to the server
	S AS=$$UNTOK^%ZS(AS,.tok)
	;
	I $D(sphk) S hk=sphk
	E  S hk=$$ELFHASH^%ZFUNC(AS_$$PARS^SQLCACHE(.par)) 
	;
	S args=$TR($G(args),":_ ","")
	;
	I $D(vsql("V")) D				; Save run-time host variables
	.	N v
	.	S v="" F  S v=$O(vsql("V",v)) Q:v=""  D
	..		I args="" S args=v
	..		E  I '$$CONTAIN(args,v) S args=args_","_v
	;
	I args="" S args=$$HOSTVAR(AS)  		; Host variables
	;
	S zpar=""
	I sptype="SELECT" D				; SELECT qualifiers
	.	I $G(par("PROTECTION")) S zpar=zpar_"/PROTECTION="_par("PROTECTION")
	.	I $G(par("DQMODE")) S zpar=zpar_"/DQMODE=1"
	;
	; SP definiiton
	S z=rtn_"|"_args_"|"_hk_"|"_zpar_"|"_$G(%UID)_"|"_+$H_"|"_$P($H,",",2)_"|"_sptype
	;
	; on rebuild, use old timestamp information 
	;
	I $G(nolink),$P(oldsts,"|",1,4)=$P(z,"|",1,4) S z=oldsts
	;
	S ^DBTBLSP(spnam)=z  			; Create SP entry
	;
	S ^DBINDX(%LIBS,"SPHK",hk,spnam)=""  		; Index by hash key
	;
	S sqldta=spnam	; Return name
	if spnam?1"S".N set sqldta=sqldta_"-"_$p(z,"|",6)_"-"_$p(z,"|",7)
	; 						; Column attributes
	I $G(vsql("A"))'="" S sqldta=sqldta_$C(13,10)_vsql("A")
	;
	N exe,vsql
	S exe=1,exe(1)=rtn
	;
	I sptype'="SELECT" N par S exe(1)=exe(1)_"|||||||"_sptype	; Identify SQL statement INSERT/UPDATE/DELETE
	;
	D SAV^SQLCACHE(AS,.par,hk)  			; Pack and save it in
	;						; 255 byte block
	F I=1:1 S ^DBTBLSP(spnam,I)=$E(AS,1,255),AS=$E(AS,256,$L(AS)) Q:AS=""
	;
	L -^DBTBLSP(spnam)
	;
	S RM=spnam					; return value
	if spnam?1"S".N set RM=RM_"-"_$p(z,"|",6)_"-"_$p(z,"|",7) 	; *** 08/15/98 mas
	S sqldta=RM
	Q
	;
	;----------------------------------------------------------------------
PARSE(sptype,spsql)	; Build exe() code
	;----------------------------------------------------------------------
	K exe
	I sptype="INSERT" D SPINSERT(spsql,spnam,.exe) Q	; Insert
	I sptype="UPDATE" D SPUPDATE(spsql,spnam,.exe) Q	; Update
	I sptype="DELETE" D SPDELETE(spsql,spnam,.exe) Q	; Delete
	;						; select
	S par("PREPARE")=1				; get prepare information
	D SELECT^SQL(AS,.par,.sqlsta,.sqldta,.sqlcnt,.sqlind,.tok,-1) I ER Q
	I $G(vsql("I"))=""!($G(vsql("D"))="") S colatt="" Q
	S colatt=$$COLATT^SQLODBC(vsql("I"),vsql("D"))	; Column format and access keys 02/10/2000
	;
	Q
	;----------------------------------------------------------------------
COMPILE(exe,vsql,par,src,spnam,expr,tags)	;public; Create program code from SELECT
	;----------------------------------------------------------------------
	; DESC:	Converts executable code from SQL select statements into
	;       compileable code.  To get the SQL code associated with a
	;	SELECT statement, use the following procedures:
	;
	;	S ER=$$^SQL(expr,.par,,,,,-1) I ER ...
	;	D COMPILE^SQLCRE(.exe,.vsql,.par,rtn,spnam,expr)
	;
	; KEYWORDS:	DATABASE
	;
	;  PARAMS:
	;	. exe	SELECT exe(array)		/MECH=REFNAM:R
	;	. vsql	SELECT Data array		/MECH=REFNAM:R
	;	. par   Input Parameter Array		/MECH=REFNAM:R/NOREQ
	;	. src	M source module spnam		/MECH=VAL/NOREQ
	;	. spnam Stored procedure name		/MECH=VAL/NOREQ
	;       . expr  SQL statement			/MECH=VAL/NOREQ
	;	. tags	Tags externally 		/MECK=REFNAM:RW
	;
	N I,J,c,goto,i,mcode,one,prefix,tag,v,zexpr
	;
	I $G(tags)="" S tags="OPEN,FETCH,FETCHBLK"
	;
	S one=0
	;
	S prefix=$P(tags,",",4)
	;
	S exe(0)=$G(src)_"(sqlcur,vsql,sqldta,sqlind,sqlcnt) ; "
	S exe(0)=exe(0)_$G(spnam)_" ; "
	S zexpr=$$UNTOK^%ZS(expr,.tok)
	D ^SCACOPYR(.c)
	S exe(.001)=c  						; Header
	S c=.002,exe(c)=" ; "_$E($G(zexpr),1,250)		; Select statement
	S c=c+.001,exe(c)=" ; "_$E($G(zexpr),251,500)		; 
	S c=c+.001,exe(c)=" ;"
	S c=c+.001,exe(c)=" D OPEN(.sqlcur,.vsql) I vsql(0)=100 S vsql=0 Q"
	S c=c+.001,exe(c)=" D FETCH(.sqlcur,.vsql,.sqldta,.sqlind) I vsql(0)=100 S vsql=0"
	S c=c+.001,exe(c)=" S sqlcnt=1 Q"
	S c=c+.001,exe(c)=" ;"
	;
	S c=c+.001,exe(c)=" ;"
	S c=c+.001,exe(c)=prefix_"0 S vsql(0)=100 Q"
	S c=c+.001,exe(c)=" ;"
	;
	S goto="S vsql="
	S tag="",tag(0)=""
	;
	F I=1:1:vsql("P") D
	.	;
	.	S mcode=exe(I)
	.	;
	.	I mcode[goto D
	..		;
	..		S tag=$P(mcode,goto,2)
	..		I tag["vsql+" S tag=I+$P(tag,"vsql+",2)  ;check for "vsql=vsql+n"
	..		S tag=tag+1
	..		; If tag is greater than the colation pointer, then we should
	..		; add a quit rather than a goto, because the Goto would result in
	..		; collation logic being generated inside the FETCH label.  See
	..		; documentation in CR ????? for details.
	..		I tag'>vsql("P") D
	...			S mcode=$P(mcode,goto,1)_"G "_prefix_tag
	...			I $D(tag(tag)) Q
	...			S exe(tag)=prefix_tag_$S(tag>I:" ",1:"")_exe(tag),tag(tag)=""
	..		E  S mcode=$P(mcode,goto,1)_"Q"
	.	;
	.	I '$D(tag(I)) S mcode=" "_mcode
	.	S exe(I)=mcode
	;
	I $G(vsql("P")) D
	.	S $P(exe(1)," ",1)=prefix_"1",tag(1)=""  ; *** 04/28/97
	.	S tag=$G(vsql(0)) I tag,'$D(tag(tag)) S exe(tag)=prefix_tag_exe(tag)
	;
	S c=exe+1,exe(c)=" Q"
	;
	S c=c+.001,exe(c)=" ;"
	S c=c+.001,exe(c)=$P(tags,",",1)_"(sqlcur,vsql) ; Open Cursor"
	S c=c+.001,exe(c)=" S sqlcnt=0,sqlind="""""
	S c=c+.001,exe(c)=" ;"
	;
	; vsql("T") indicates temporary results tables are used
	I $G(vsql("T")) S c=c+.001,exe(c)=" K ^DBTMP(%TOKEN,sqlcur)"
	;
	S c=c+.001,exe(c)=" S vsql=1,vsql(0)=1,vsql(""K"")="_+vsql("K")_",vsql(""D"")="""""
	;
	; Break up long statement  01/22/99 BC
	;
	f i=1:100:9999 Q:$E(vsql("D"),i,i+99)=""  D
	.	S c=c+.001,exe(c)=" S vsql(""D"")=vsql(""D"")_"_""""_$E(vsql("D"),i,i+99)_""""
	;
	I vsql("P") S exe(c)=exe(c)_" D "_prefix_"1"
	S c=c+.001,exe(c)=" Q"
	S c=c+.001,exe(c)=" ;"
	S c=c+.001,exe(c)=$P(tags,",",2)_"(sqlcur,vsql,vd,vi) ; Fetch Row"
	S c=c+.001,exe(c)=" ;"
	S c=c+.001,exe(c)=" I vsql(0)=100 S vsql=-1 Q"
	S c=c+.001,exe(c)=" ;"
	F I=vsql("P")+1:1:exe D
	. 	S c=c+.001,exe(c)=" "_exe(I)
	.	I exe(I)="S vsql(0)=100" S one=1
	.	K exe(I)
	S c=c+.001,exe(c)=" ;"
	I tag,'one S c=c+.001,exe(c)=" D "_prefix_tag
	S c=c+.001,exe(c)=" Q"
	;
	; Add ODBC Prepare information
	;
	S v=$G(vsql("A")) I v="" Q
	;
	N cnt,dinam,hdr,i,odinam,v1,x
	S c=c+.001,exe(c)="PREPARE() ; ODBC prepare information"
	S c=c+.001,exe(c)=" N v"
	S odinam="",cnt=0
	F  Q:v=""  D
	.	S v1=$$BSE^SQLUTL(v,1,11)			; Fixed attributes
	.	S v=$$BSE^SQLUTL(v,12,999999)
	.	S dinam=$$BSP^SQLUTL(v,$$BYTECHAR^SQLUTL(255),1)		; table.column
	.	S v1=v1_dinam			; single row data
	.	S v=$$BSE^SQLUTL(v,$L(dinam)+2,999999)	; point to next column
	.	;
	.	S hdr=""
	.	F i=1:1:11 S hdr=hdr_","_$$BSASCII^SQLUTL(v1,i)
	.	S x=" S v="
	.	I cnt S x=x_"v_"
	.	S x=x_"$$BYTECHAR^SQLUTL("_$$BSE^SQLUTL(hdr,2,9999)_")_"_""""_dinam_""""_"_$$BYTECHAR^SQLUTL(255)"
	.	S cnt=cnt+1,c=c+.001
	.	S exe(c)=x
	S c=c+.001,exe(c)=" Q v"
	; 02/10/2000
	S c=c+.001,exe(c)="PREPARE3() ; PFW/PIA column format information"
	S c=c+.001,exe(c)=" Q "_""""_colatt_""""
	Q
	;
	;----------------------------------------------------------------------
FETCHBLK	; old fetchblk coding -- no longer used (at least for now)
	;----------------------------------------------------------------------
	;
	S c=c+.001,exe(c)=" ;"
	S c=c+.001,exe(c)=$P(tags,",",3)_"(sqlcur,vsql,sqldta,sqlcnt,sqlind,rows) ; Fetch a block of records"
	S c=c+.001,exe(c)=" ;"
	S c=c+.001,exe(c)=" D "_$P(tags,",",2)_"(sqlcur,.vsql,.sqldta,.sqlind)"
	I one S exe(c)=exe(c)_" S sqlcnt=''vsql Q" Q
	S c=c+.001,exe(c)=" I vsql=0 S sqlcnt=0,sqldta="""",sqlind="""" Q"
	S c=c+.001,exe(c)=" ;"
	S c=c+.001,exe(c)=" S sqlcnt=1,sqldta=$$FORMAT^SQLF(sqldta),sqlind=$G(sqlind) I $G(rows)<2 Q"
	S c=c+.001,exe(c)=" ;"
	S c=c+.001,exe(c)=" N vd,vi,vr"
	S c=c+.001,exe(c)=" S vr=$P($G(vsql(""F"")),""|"",8) I vr="""" S vr=$C(13,10)"
	S c=c+.001,exe(c)=" E  S vr=$S($L(vr,"","")=1:$C(vr),1:$C($P(vr,"","",1),$P(vr,"","",2)))"
	S c=c+.001,exe(c)=" ;"
	S c=c+.001,exe(c)=" F sqlcnt=2:1:rows Q:vsql(0)=100  D "_$P(tags,",",2)_"(sqlcur,.vsql,.vd,.vi) S sqldta=sqldta_vr_$$FORMAT^SQLF(vd),sqlind=sqlind_vr_$G(vi)"
	S c=c+.001,exe(c)=" I vsql=0 S sqlcnt=sqlcnt-1"
	S c=c+.001,exe(c)=" Q"
	Q
	;
	;----------------------------------------------------------------------
ERROR(num,par)	; Return Error from message table
	;----------------------------------------------------------------------
	;
	S ER=1
	Q
	;
CONTAIN(A,B)	Q (","_A_",")[(","_B_",")
	;
	;----------------------------------------------------------------------
BUILD	; Prompt and rebuild stored procedures (Called by function DBSSPB)
	;----------------------------------------------------------------------
	;
	I '$D(%LIBS) N %LIBS S %LIBS="SYSDEV"
	;
	N %CTPRMT,%FRAME,%READ,%TAB,CNT,DTL,FID,H2,I,OLNTB
	N fsn
	;
	S DBOPT=18,DTL=0,TEMP=0
	S H2=$$^MSG(8360)
	;
	S %TAB("FID")="/DES=Procedure Name/TBL=[DBTBLSP]/XPP=D LISTPP^DBSGETID(""DBTBLSP"")"
	S %TAB("FID(0)")=%TAB("FID")
	;
	S %READ="@@%FN,,@H2,,FID(0)/REQ,FID/REP=19/NOREQ"
	;
	S %FRAME=2
	S OLNTB=20,%CTPRMT="2|41"
	D ^UTLREAD I VFMQ="Q" Q
	;
	K ^TEMP($J)
	S CNT=0
	F I=0:1:19 S X=FID(I) I X'="" S CNT=CNT+$$LISTBLD^DBSGETID(X,"DBTBLSP")
	Q:'CNT
	;
	D BUILDALL
	Q
	;
	;----------------------------------------------------------------------
BUILDALL	; Build stored procedures 
	;----------------------------------------------------------------------
	N spnam
	S spnam=""
	I $G(%LIBS)="" N %LIBS S %LIBS="SYSDEV"
	F  S spnam=$O(^TEMP($J,spnam)) Q:spnam=""  D
	.	;
	.	W !,spnam
	.	D BUILDONE(spnam)
	.	I $G(ER) W !,$$MSG^%TRMVT(RM) H 2	; Error message
	Q
	;----------------------------------------------------------------------
BUILDONE(spnam)	; 
	;----------------------------------------------------------------------
	N i,par,sphk,spsql,z
	S z=$G(^DBTBLSP(spnam)) I z="" Q
	S sphk=$P(z,"|",3)				; Hash key
	S par=$P(z,"|",4)				; Qualifiers
	S sptype=$P(z,"|",8)				; Type
	I sptype="" S $P(^DBTBLSP(spnam),"|",8)="SELECT",sptype="SELECT"
	I par'="" D PARSPAR^%ZS(par,.par)	
	;
	S spsql=$G(^DBTBLSP(spnam,1)) I spsql="" Q
	F i=2:1 S z=$G(^(i)) Q:z=""  S spsql=spsql_z	; SQL statement
	I sptype="SELECT" D BUILDSP Q			; Select statement
	;
	I sptype="INSERT" D SPINSERT(spsql,spnam,.exe),CREATRTN(spnam) Q  ; Insert
	I sptype="UPDATE" D SPUPDATE(spsql,spnam,.exe),CREATRTN(spnam) Q  ; Update
	I sptype="DELETE" D SPDELETE(spsql,spnam,.exe),CREATRTN(spnam) Q  ; Delete
	K ^DBTBLSP(spnam)			; Invalid definition
	Q
BUILDSP	; 
	N (sphk,spsql,spnam,par,%DB,%UID)
	D SPSEL(spsql,spnam,.par,,1)  		; Compile but don't link
	Q
	;
CREATRTN(rtn)	
	Q:$G(ER)
	D ^%ZRTNCMP(rtn,"exe")                   ; Compile routine
	; 
	I $G(par("ODBC")) D LINK^PBSUTL("SCA$IBS",rtn)  ; Link it to the server 
	Q
	;
	;----------------------------------------------------------------------
HOSTVAR(expr)	; Extract host variables from the SQL expression 
	;----------------------------------------------------------------------
	; Example:  SELECT CID,BAL,LNM FROM DEP WHERE CID=:ACCOUNT
	;           returns ACCOUNT
	;----------------------------------------------------------------------
	N i,v,var
	I expr'[":" Q ""
	S var=""
	F i=2:1:$L(expr,":") D
	.	S v=$P(expr,":",i),v=$P(v," ",1)	; Host variable
	.	S v=$p(v,",",1)
	.	I v'="" S var=var_","_v
	S var=$P(var,")",1)
	Q $E(var,2,999)	
	;
	;----------------------------------------------------------------------
SQLCODE(pid)	; Called by computed data item DBTBLSP.SQLSTMT 
	;----------------------------------------------------------------------
	N i,v
	S v="" F i=1:1 Q:'$D(^DBTBLSP(pid,i))  S v=v_^(i)
	Q v
	;
	;----------------------------------------------------------------------
SPINSERT(expr,spnam,code)	; 
	;----------------------------------------------------------------------
	N c,msrc,q,rtn,sql
	S q=""""
	I $G(tok)'="" S expr=$$UNTOK^%ZS(expr,.tok)
	S sql="INSERT "_expr
	;I $P(expr," ",1)="INTO" S expr=$p(expr," ",2,999)	; Remove INTO
	D INSERT^SQLCMP(expr,1,.code,1)			; compile
	I ER,$G(RM)'="" Q				; Syntax error
	I ER S RM=$$^MSG(8564,sql) Q 		; Invalid statement
	D RTNHDR
	Q
	;----------------------------------------------------------------------
SPUPDATE(expr,spnam,code)	; 
	;----------------------------------------------------------------------
	N c,msrc,q,rem,rtn,sql
	S q=""""
	I $G(tok)'="" S expr=$$UNTOK^%ZS(expr,.tok)
	S sql="UPDATE "_expr
	D UPDATE^SQLCMP(expr,1,.code,1)			; compile
	I ER S RM=$$^MSG(8564,sql) Q 
	D RTNHDR
	Q
	;----------------------------------------------------------------------
SPDELETE(expr,spnam,code)	; 
	;----------------------------------------------------------------------
	N c,msrc,rem,rtn,sql
	I $g(tok)'="" S expr=$$UNTOK^%ZS(expr,.tok)
	; 
	S sql=" DELETE "_expr
	D DELETE^SQLCMP(expr,1,.code,1)
	I ER S RM=$$^MSG(8564,sql) Q 
	D RTNHDR
	Q
RTNHDR	;
	S rtn=spnam
	D ^SCACOPYR(.c) 
	;
	S code(0.1)=rtn_" ; "
	S code(0.2)=c
	S code(0.3)=" ;"
	S code(0.4)=" ; "_sql
	S code(0.5)=" ;"
	Q
