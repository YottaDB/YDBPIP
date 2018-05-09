%RSEL	;M Utility;SCA routine select into a local array
	;;Copyright(c)1996 Sanchez Computer Associates, Inc.  All Rights Reserved - 06/28/96 14:58:22 - CHENARD
	; ORIG: RUSSELL -  1 NOV 1989
	;
	; Modified version of GT.M's %RSEL utility for selecting a list of 
	; routines and placing in %ZR array.
	;
	; Various entry points for multiple purposes:
	;
	; ^%RSEL for prompted input using .M modules
	;            
	; KEYWORDS:	Routine handling
	;
	; RETURNS:
	;	. %ZR		Number of routines selected	/TYP=N
	;
	;	. %ZR(rtn	Routine name			/TYP=T
	;
	;	. %ZR(rtn)	.M file routine locations	/TYP=T
	;
	; EXAMPLE:
	;	D ^%RSEL
	;
	; LIBRARY:
	;	. OBJ^%RSEL	- prompted input using .o modules
	;	. CALL^%RSEL	- uses %ZR as input
	;	. INT^%RSEL	- uses %ZI as input
	;	. BOTH^%RSEL	- uses %ZI or prompted uses both .m and .o
	;	. TWO^%RSEL	- allows selection from two directories
	;
	;---- Revision History -----------------------------------------------
	;
	; 10/07/98 - Phil Chenard
	;            Replace .OBJ references to object files with .o
	;
	;-----------------------------------------------------------------------
SRC	n add,beg,cnt,ctrap,d,delim,end,exc,from,i,k,last,mtch,r,rd,rdf
	n out,scwc,to,%ZE,%ZL
	s %ZE=".m"
	n $zt s %ZL=$zl,$ZT="zg %ZL:ERR^%RSEL"
	d init,initzro,main
	u "":(ctrap="":exc="")
	q
	;
	;-----------------------------------------------------------------------
OBJ	;M Utility;Select routines, returning location of .OBJ modules
	;----------------------------------------------------------------------
	;
	; Allows prompted input of routines, returning selected routines with
	; location of .o modules
	;
	; KEYWORDS:	Routine handling
	;
	; RETURNS:
	;	. %ZR		Number of routines selected	/TYP=N
	;
	;	. %ZR(rtn	Routine name			/TYP=T
	;
	;	. %ZR(rtn)	.o file routine locations	/TYP=T
	;
	; EXAMPLE:
	;	D OBJ^%RSEL
	;
	n add,beg,cnt,d,end,i,k,mtch,r,rd,rdf,out,%ZE,%ZL
	s %ZE=".o"
	n $zt s %ZL=$zl,$ZT="zg %ZL:ERR^%RSEL"
	d init,initzro,main
	u "":(ctrap="":exc="")
	q
	;
	;-----------------------------------------------------------------------
RD	n add,beg,cnt,d,end,i,k,mtch,r,rd,rdf,out
	s cnt=0,(out,rd,rdf)=1
	d initzro
	i $l($g(%ZR)) d setup,it k r q
	d main i rdf d
	.	s %ZR="*" 
	.	d setup,it 
	.	W !,"Total of ",cnt," routine",$s(cnt=1:".",1:"s."),!
	q
	;
	;-----------------------------------------------------------------------
CALL	;Pubic; Returns locations of input routines
	;----------------------------------------------------------------------
	;
	; Based on input of routine list and file type (.m or .o),
returns
	; list and location of selected routine files
	;
	; KEYWORDS:	Routine handling
	;
	; INPUTS:
	;	. %ZE		Select .o or .m files		/TYP=T
	;			If = ".o" selects on .o files
	;			Otherwise, selects on .m files
	;
	;	. %ZR(rtn	Routine name			/TYP=T
	;
	;	. %ZR(rtn)	Null				/TYP=T
	;
	; RETURNS:
	;	. %ZR		Number of routines selected	/TYP=N
	;
	;	. %ZR(rtn	Routine name			/TYP=T
	;
	;	. %ZR(rtn)	Select routines and locations	/TYP=T
	;			Contains either .o location or
	;			.M location, depending on input
	;			value of %ZE
	;
	; EXAMPLE:
	;	D CALL^%RSEL
	;
	n add,beg,cnt,d,end,i,k,mtch,r,rd,rdf,out n:'$d(%ZE) %ZE
	s (cnt,rd)=0
	i $g(%ZE)'=".o" s %ZE=".m"
	i $d(%ZR)>1 s r="" f  s r=$o(%ZR(r)) q:'$l(r)  s cnt=cnt+1
	d initzro
	i $l($g(%ZR)) s out=0 d setup,it k r s %ZR=cnt q
	s out=1
	d initzro,main
	q
	;
	;-----------------------------------------------------------------------
init	u "":(ctrap=$c(3):exc="zg %ZL:LOOP^%RSEL")
	k %ZR
	s (cnt,rd)=0,out=1
	q
	;
	;-----------------------------------------------------------------------
initzro
	s delim=" ",scwc="?",from=" !""#$&'()+'-./;<=>@[]\^_`{}|~",to=""
	s from=from_$c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,127)
	zsh "d":d
	s d=""
	f  s d=$o(d("D",d)) q:d=""  i $p=$p(d("D",d)," ") s d=d("D",d),ctrap=$p($p(d,"CTRA=",2)," "),exc=$p(d,"EXCE=",2) q
	e  s (ctrap,exc)="" ; should never happen
	s k=$l(exc,"""")
	i k>1 f k=k:-1:2 s $p(exc,"""",k)=""""_$p(exc,"""",k)
	k d
	s (cnt,rd)=0,out=1,(last,r(0))=$c(255)
	i '$l($zro) s d=1,d(1)="" q
        s d=0
	f k=1:1:$l($zro,delim) d  i $l(r) s d=d+1,d(d)=$p(r,"*")
	. s r=$p($zro,delim,k) 
	. i delim=" " d  s:$l(r) r=$zparse(r_"/","","*") q                        ; UNIX conventions
	.. i r'["(" q                                                            ; no source info - it does both
	.. i %ZE[".o" d  q                                                       ; only want objects
	... s r=$p(r,"(")                                                       ; grab object directory
	... f k=k:1:$l($zro,delim) q:$p($zro,delim,k)[")"                       ; and step over source info
	.. s r=$p(r,"(",2)                                                       ; grab 1st souce directory
	.. i r[")" s r=$p(r,")") q                                               ; it's the only one - we're done
	.. d  f k=k+1:1 s r=$p($zro,delim,k) i $l(r) d  i r[")" s r=$p(r,")") q  ; record all but the last
	... i r'[")" s r=$p($zparse(r_"/","","*"),"*") i $l(r) s d=d+1,d(d)=r
	. e  d  s:$l(r) r=$zparse(r,"","*") q                                     ; VMS conventions
	.. i r[".sl" s r="" q ; it's an object library and we don't pokethem in
	.. i r'["/" q                                                            ; no souces info - it does both
	.. i %ZE[".o" d  q                                                       ; only want objects
	... s r=$p(r,"/")                                                       ; grab the object directory 
	... f k=k:1:$l($zro,delim) q:$p($zro,delim,k)[")"                       ; and step over source info
	.. s r=$p(r,"=",2)                                                       ; grab 1st source directory
	.. i $e(r)'="(" q                                                        ; /SRC or /NOSRC - we're done
	.. s r=$p(r,"(",2)                                                       ; strip the opening (
	.. i r[")" s r=$p(r,")") q                                               ; it's in parens but only one
	.. d  f k=k+1:1 s r=$p($zro,delim,k) i $l(r) d  i r[")" s r=$p(r,")") q  ; record all but the last
	... i r'[")" s r=$p($zparse(r,"","*"),"*") i $l(r) s d=d+1,d(d)=r
	q
	;
	;-----------------------------------------------------------------------
	;-----------------------------------------------------------------------
main	n READ
	f  d inter q:'$l(%ZR)
	s %ZR=cnt
	q
	;
	;-----------------------------------------------------------------------
inter	S %ZR=$$PROMPT^%READ("Routine:  ","") W ! q:'$l(%ZR)
	i $e(%ZR)="?" d help q
	i $e(%ZR)="@" d file q
	d setup,it k r
	w !,$s(rd:"T",1:"Current t"),"otal of ",cnt," routine",$s(cnt=1:".",1:"s."),!
	q
	;
	;-----------------------------------------------------------------------
file	; Input routines in an RMS file
	;-----------------------------------------------------------------------
	;
	n ok,file
	s file=$e(%ZR,2,$l(%ZR))
	s ok=$$FILE^%ZOPEN(file,"READ") I 'ok w !,$P(ok,"|",2) Q
	;
	f  u file r %ZR Q:$ZEOF  U 0 w !,%ZR d
	.	;
	.	I $e(%ZR)'="@" D setup,it k r
	.	D file
	Q
	;
	;-----------------------------------------------------------------------
setup	i rd s add=1,cnt=0,r=%ZR k %ZR s %ZR=r
	e  i "'-"[$e(%ZR) s add=0,r=$e(%ZR,2,999)
	e  s add=1,r=%ZR
	;s r=$$UPPER^%ZFUNC(r)
	s r=$tr(r," !""#$&'()+'-./;<=>?@[]\^_`{}|~")
	s r=$tr(r,$c(0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,127))
	s end=$p(r,":",2),beg=$p(r,":")
	i end=beg s end=""
	q
	;
	;-----------------------------------------------------------------------
it	s r(0)=$c(255),rdf=0
	i end'?."*",end']beg q
	i $e(beg)="*" d  
	.	s mtch="_"_beg_%ZE 
	.	d start 
	.	f  d search q:'$l(r)  d save
	;
	i $e(beg)="%",beg'["*" d  
	.	s mtch="_"_$e(beg,2,9999)_%ZE 
	.	d start 
	.	f  d  q:'$L(r)
	..		d search 
	..		q:$e(r)'="_"  
	..		d save
	;
	i $e(beg)="%",beg["*" d  
	.	s mtch="_"_$e(beg,2,9999)_%ZE 
	.	d start 
	.	f  d  q:'$l(r)
	..		d search 
	..		q:$e(r)'="_"  
	..		d save
	;
	i $e(beg)'="%" d
	.	s mtch=beg_%ZE 
	.	d start f  d search q:$e(r)="_"!'$l(r)  d save
	i '$l(end) q
	i end'?."*",end']beg q
	;
	; Do range in sections if necesary, one for %, one for non-% routines
	i $e(beg)="%"&($e(end)="%")!($e(beg)'="%"&($e(end)'="%")) d range(beg,end) q
	; Mixed range, e.g. %ABC:XYZ
	d range(beg,"%zzzzzzzz") ; Get %
	d range("A",end) ; Get non-%
	q 
	;
	;-----------------------------------------------------------------------
range(beg,end)	; Get range
	;-----------------------------------------------------------------------
	i $e(beg)="%" s beg="_"_$e(beg,2,9999),mtch="_*"_%ZE
	e  s mtch="*"_%ZE
	s beg=$p($p(beg,"*"),"%")
	s end=$tr($e(end),"%","_")_$e(end,2,9999) d start D
	.	F  d search q:end']r!'$l(r)  d:beg']r save
	s mtch="________________" d start
	s beg=$s($e(end)="*":"_",1:""),mtch=end_%ZE d start D
	.	F  d search q:$e(r)=beg  d save
	q
	;
	;-----------------------------------------------------------------------
start	f k=1:1:d s r(k)=$$next(k)
	q
	;
	;-----------------------------------------------------------------------
search	s r=$c(255)
	f k=d:-1:1 i r(k)'="" D
	.	s:r(k)=r(k-1) r(k)=$$next(k) 
	.	i $l(r(k)),r(k)']r s i=k,r=r(k)
	i r=$c(255) s r=""
	e  s r(i)=$$next(i)
	q
	;
	;-----------------------------------------------------------------------
next(k)	;
	;-----------------------------------------------------------------------
	q $zparse($zsearch(d(k)_mtch,k),"NAME")
	;
	;-----------------------------------------------------------------------
save	i $e(r)="_" s r="%"_$e(r,2,9999)
	i $G(TWODIRS),add D
	.	s:'$d(%ZR(r)) cnt=cnt+1 
	.	s $P(%ZR(r),"|",TWODIRS)=d(i) 
	.	d prt:out 			; ** Added by SCA for TWO section
	i r="" q				; ** Added 4/15
	i add,'$d(%ZR(r)) s %ZR(r)=d(i),cnt=cnt+1 d prt:out
	i 'add,$d(%ZR(r)) k %ZR(r) s cnt=cnt-1 d prt:out
	q
	;
	;-----------------------------------------------------------------------
prt	w:$x>70 ! w r,?$x\10+1*10
	q
	;
	;-----------------------------------------------------------------------
help	i "Dd"[$e(%ZR,2),$l(%ZR)=2 d cur q
	w !,"<RET> to leave",!,"* for all",!,"rout for 1 routine",!,"rout1:rout2 for a range"
	w !,"* as wildcard permitting any number of characters"
	w !,"% as a single character wildcard in positions other than the first"
	i rd q
	w !,"' as the 1st character to remove routines from the list"
	w !,"?D for the currently selected routines"
	q
	;
	;-----------------------------------------------------------------------
cur	w ! s r="" 
	f  s r=$o(%ZR(r)) q:'$l(r)  w:$x>70 ! w r,?($x\10+1*10)
	q
	;
	;-----------------------------------------------------------------------
ERR	u "" w !,$p($ZS,",",2,999),!
	u "":(ctrap="":exc="")
	q
	;
	;-----------------------------------------------------------------------
LOOP	d main
	u "":(ctrap="":exc="")
	q
	;
	;**********************************************************************
	;**********************************************************************
	; The following sections have been added by SCA
	;----------------------------------------------------------------------
INT	;M Utility;Return info on routines from list provided in %ZI
	;----------------------------------------------------------------------
	;
	; %ZI contains array specifying routines to select.  %ZR is returned
	; with routine locations
	;
	; KEYWORDS:	Routine handling
	;
	; INPUTS:
	;	. %ZI(rtn	Routine name			/TYP=T
	;
	;	. %ZI(rtn)	Null				/TYP=T
	;
	;	. %ZE		Source or object		/TYP=T/NOREQ
	;			indicator
	;			If = ".o", returns info on
	;			object files.  Otherwise, on
	;			source files
	;
	; RETURNS:
	;	. %ZR		Number of routines selected	/TYP=N
	;
	;	. %ZR(rtn	Routine name			/TYP=T
	;
	;	. %ZR(rtn)	Select routines and locations	/TYP=T
	;			Contains either .o location or
	;			.m location, depending on input
	;			value of %ZE
	;
	; EXAMPLE:
	;	D INT^%RSEL
	;
	K %ZR Q:'$D(%ZI)
	N add,beg,cnt,ctrap,d,delim,end,exc,from,i,k,last,mtch,NXT,out
	N r,rd,rdf,scwc,to
	S (cnt,rd)=0
	I $G(%ZE)'=".o" S %ZE=".m"
	D initzro
	S out=0,NXT=""
	F  S NXT=$O(%ZI(NXT)) Q:NXT=""  I $E(NXT)'="'" S %ZR=NXT D setup,it
	F  S NXT=$O(%ZI(NXT)) Q:NXT=""  I $E(NXT)="'" S %ZR=NXT D setup,it
	S %ZR=cnt
	I %ZR=0 K %ZR
	K %ZE
	Q
	;
	;----------------------------------------------------------------------
BOTH	;M Utility;For selected routines, returns both source and object locations
	;----------------------------------------------------------------------
	;
	; Returns both source and object locations for routines selected.
	; Routines may either be passed in in %ZI or, if %ZI not defined, will
	; be prompted.  %ZR is returned with source code locations, %ZRO with
	; object locations.
	;
	; KEYWORDS:	Routine handling
	;
	; INPUTS:
	;	. %ZI(rtn	Routine name			/TYP=T/NOREQ
	;			If not provided, will
	;			prompt for routine selection
	;
	;	. %ZI(rtn)	Null				/TYP=T
	;
	; RETURNS:
	;	. %ZR		Number of routines selected	/TYP=N
	;
	;	. %ZR(rtn	Routine name			/TYP=T
	;
	;	. %ZR(rtn)	Source locations		/TYP=T
	;
	;	. %ZRO(rtn	Routine name			/TYP=T
	;
	;	. %ZRO(rtn)	Object locations		/TYP=T
	;
	; EXAMPLE:
	;	D BOTH^%RSEL
	;
	;
	N N,%ZRTMP,%ZIDEF,%ZE,CNT
	S %ZIDEF=$D(%ZI)
	K %ZR,%ZRO
	S N=""
	I '%ZIDEF D  K %ZI 	;Prompt for routines
	.	D SRC ; Get source code, prompted
	.	Q:'$G(%ZR)
	.	S %ZRTMP=%ZR
	.	F  S N=$O(%ZR(N)) Q:N=""  D
	..		S %ZRTMP(N)=%ZR(N) I '%ZIDEF S %ZI(N)=""
	.	S %ZE=".o" D INT I $G(%ZR) S %ZRO=%ZR
	.	F  S N=$O(%ZR(N)) Q:N=""  D
	..		S %ZRO(N)=%ZR(N)
	.	S %ZR=%ZRTMP
	.	F  S N=$O(%ZRTMP(N)) Q:N=""  S %ZR(N)=%ZRTMP(N) K %ZRTMP(N)
	;
	E  D			;Routine list pre-defined
	.	S %ZE=".o" D INT I $G(%ZR) S %ZRO=%ZR
	.	S N=""
	.	F  S N=$O(%ZR(N)) Q:N=""  D
	..		S %ZRO(N)=%ZR(N)
	.	S %ZE=".m" D INT	
	Q
	;
	;----------------------------------------------------------------------
TWO(DIR1,DIR2)	;M Utility;Selection of routines from two directories
	;----------------------------------------------------------------------
	;
	; Allows prompted selection of routines which reside in either one or
	; both input directories.
	;
	; This subroutine is called by ^%ZRDIF
	;
	; KEYWORDS:	Routine handling
	;
	; ARGUMENTS:
	;	. DIR1		First search list		/TYP=T
	;			May be individual directory
	;			or search list
	;
	;	. DIR2		Second search list		/TYP=T
	;			May be individual directory
	;			or search list
	;
	; RETURNS:
	;	. %ZR		Number of routines selected	/TYP=N
	;
	;	. %ZR(rtn	Routine name			/TYP=T
	;
	;	. %ZR(rtn)	Source locations		/TYP=T
	;			%ZR(rtn)=DIR1 location | DIR2 location
	;			Either piece may be null if routine
	;			not in search list
	;
	; EXAMPLE:
	;	D TWO^%RSEL("V50DEVM","V44DEVM")
	;
	K %ZR Q:'$D(DIR1)  Q:'$D(DIR2)
	N (%ZR,DIR1,DIR2)
	S (cnt,rd)=0,%ZE=".m",out=0
	S SAVRO=$ZRO
	N $ZT
	S $ZT="ZG "_$ZL_":TWOEXIT^%RSEL"
	S $ZRO=DIR1 D initzro ; Set up first directory info
	S HOLDD1=d(1)
	S $ZRO=DIR2 D initzro ; Set up second directory info
	S HOLDD2=d(1)
	S d=1
	F  D TWORTN Q:%ZR=""
	S %ZR=cnt
	;
TWOEXIT	; Error trap and exit
	S $ZRO=SAVRO
	Q
	;
TWORTN	S %ZR=$$PROMPT^%READ("Routine: ","") W ! Q:%ZR=""
	I $E(%ZR)="?" D help Q
	S d(1)=HOLDD1,TWODIRS=1 D setup,it k r
	S d(1)=HOLDD2,TWODIRS=2 D setup,it k r
	W !,$S(rd:"T",1:"Current t"),"otal of ",cnt," routine",$s(cnt=1:".",1:"s."),!
	Q
