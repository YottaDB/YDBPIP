TBXCDCVR(glob,dir)	;Private;Code coverage analyzer HTML report generator
	;;Copyright(c)2001 Sanchez Computer Associates, Inc.  All Rights Reserved - 12/07/01 14:28:30 - RUSSELL
	; ORIG:	SPIER - 08/03/01
	; DESC:	Code coverage analyzer report generator
	;
	;       Generates HTML files for each routine analyzed.
	;
	; To see documentation on the use of this utility, go to the DOC
	; section at the end of the routine, or D DOC^TBXCDCVR to display it,
	;
	; KEYWORDS:	Toolbox, QA, Testing
	;
	; ARGUMENTS:
	;	. glob	Global with data	/TYP=T/REQ/MECH=VAL
	;		May be of form ^GLOB
	;		or ^GLOB(key,key)
	;
	; 	. dir	Output directory	/TYP=L/NOREQ/MECH=VAL
	;		Default = spool
	;
	;----------------------------------------------------------------------
	; 05/10/06 - Allan Mattson - CR20048
	;            Replaced occurrences of $C(255) with the value returned
	;            from $$getPslValue^UCOPTS("maxCharValue").
	;
	;            Replaced calls to $$UPPER^%ZFUNC with $$UPPER^SCAUTL.
	;
	; 12/07/01 - Dan Russell - 48646
	;	     Modify to avoid problems with routines where there is
	;	     no longer any source code, e.g., schedule or thread
	;	     compiled code.  Plus, explicitly ignore SCHnnn and THRnnn
	;	     if they do exist.
	;
	;	     Generate STATS.CSV file of statistics.
	;
	; 11/14/01 - Dan Russell - 48301
	;	     Changed name from COVER to TBXCDCVR and made various
	;	     other revisions:
	;
	;		- added dir parameter
	;		- added prompt for output directory if no dir
	;		- eliminated default for input global, now required
	;		- add discliamer call
	;		- changed global used to TBXCDCVR
	;		- change variable names that were > 8 characters
	;
	; 10/18/01 - Dan Russell
	;	     Modified to use data from input global
	;
	;----------------------------------------------------------------------
	;
	N (dir,ER,glob,RM)
	;
	; Skip disclaimer if all input is defined, otherwise display
	; disclaimer and determine if want to continue
	I '($D(glob)&$D(dir)) Q:'$$DISCLAIM^TBX
	;
	I $G(glob)="" S ER=1,RM="Input global required" Q
	;
	I $G(dir)="" D  Q:VFMQ="Q"
	.	S %TAB("dir")="/DES=Output to directory/TYP=T/LEN=40/XPP=D PROCRPT^TBXCDCV"
	.	S hdr="Generate HTML Reporting from Code Coverage Data"
	.	S %READ="@hdr/CEN,,dir/REQ"
	.	S %FRAME=1,%NOPRMT="F"
	.	S dir=$$SCAU^%TRNLNM("SPOOL")
	.	D ^UTLREAD Q:VFMQ="Q"
	;
	D INIT
	;
	; Set up global reference to get data
	I glob'["(" S glob=glob_"("
	I $E(glob,$L(glob))=")" S glob=$E(glob,1,$L(glob)-1)_","
	I $E(glob)'="^" S glob="^"_glob
	;
	S (ROUTINE,LABEL,PTR)=""
	;
	U 0 W !,"Working "
	F  S ROUTINE=$O(@(glob_"ROUTINE)")) Q:ROUTINE=""  D
	.	Q:ROUTINE?1"TBX".E  			; Ignore TBX* routines
	.	Q:ROUTINE?1"SCH"1.N			; Ignore schedulers
	.	Q:ROUTINE?1"THR"1.N			; Ingore threads
	.	I $E(ROUTINE)="%" S ^TBXCDCVR(ROUTINE)="||||1" Q
	.	I ROUTINE["$" S ^TBXCDCVR(ROUTINE)="||||1" Q
	.	K %ZI
	.	S %ZI(ROUTINE)=""
	.	D INT^%RSEL
	.	S IO=$G(%ZR(ROUTINE))
	.	Q:IO=""					; No source code
	.	S IO=IO_ROUTINE_".m"			; Source code file
	.	U 0 W "."				; Progress being made
	.	S (ELEMENT,FILETYPE)=""
	.	O IO:READ
	.	;I IO["crtns" S DUMMY=$$GETTYPE() 	; For future use (Mark)
	.	D READRTN
	C IOSTATS
	Q
	;
INIT	;
	S TESTED="lightskyblue"				; Covered
	S DEAD="lightgreen"				; Dead code
	S UNTEST="lightpink"				; Uncovered
	S COMMENTS="bisque"				; Comments
	S MRTNS=$$SCAU^%TRNLNM("MRTNS")
	S CRTNS=$$SCAU^%TRNLNM("CRTNS")
	S IOSTATS=$$FILE^%TRNLNM("STATS",dir)_".CSV"	; Stats file
	O IOSTATS:NEWV
	U IOSTATS W "Routine,Hit,Miss,Percent",!	; Stats header line
	q
	;
READRTN	;
	N EOT,maxCharV,PSLSRC,ROU
	D HEADER(ROUTINE,TESTED,DEAD,UNTEST,COMMENTS)
	S (TSTEDCOD,DEADCODE,UNTSTDCD,COMMNTCD)=0
	S QUITFRML=0
	S STARTHIS=0,REVHIST=0
	;
	S maxCharV=$$MAXCHARV
	;
	F  S CODE=$$^%ZREAD(IO,.EOT) Q:EOT  D
	.	S SEQ=SEQ+1
	.	I $TR($TR($E(CODE)," ",""),$C(9),"")'="" D GETLAB(CODE,.LABEL)
	.	S LABSEQ=LABSEQ+1,NEWLINE=0
	.	I $G(FILETYPE)'="",CODE["PSL++" D 
	..		I LABSEQ=0,$D(@(glob_"ROUTINE,LABEL)")) S PSLSRC(+$P(CODE,"PSL++",2))=$G(@(glob_"ROUTINE,LABEL)"))
	..		E  S PSLSRC($P(CODE,"PSL++",2))=$G(@(glob_"ROUTINE,LABEL,LABSEQ)"))
	.	I LABSEQ=0,$D(@(glob_"ROUTINE,LABEL)")) D WRITE(CODE,TESTED,$G(@(glob_"ROUTINE,LABEL)"))) S TSTEDCOD=TSTEDCOD+1 Q
	.	I CODE["Revision History" S STARTHIS=1
	.	S QUITCHK=$TR($$UPPER^SCAUTL($$TRIM^%ZS(CODE)),$C(9),"")
	.	I 'QUITFRML,QUITCHK="Q"!(QUITCHK="QUIT") S QUITFRML=1,NEWLINE=1
	.	I $TR($TR($P(CODE,";",1)," ",""),$C(9),"")="" D WRITE(CODE,COMMENTS) S:STARTHIS=0 COMMNTCD=COMMNTCD+1   S:STARTHIS=1 REVHIST=REVHIST+1  Q
	.	S STARTHIS=0
	.	I $D(@(glob_"ROUTINE,LABEL,LABSEQ)")) D WRITE(CODE,TESTED,$G(@(glob_"ROUTINE,LABEL,LABSEQ)"))) S TSTEDCOD=TSTEDCOD+1 Q
	.	I QUITFRML,'NEWLINE D WRITE(CODE,DEAD) S DEADCODE=DEADCODE+1 Q
	.	D WRITE(CODE,UNTEST) S UNTSTDCD=UNTSTDCD+1
	C IO
	I '$D(ROU(34)) S ^TBXCDCVR(ROUTINE)="|||||1" Q
	I $G(FILETYPE)'="" D PSLCODE
	S ^TBXCDCVR(ROUTINE)=TSTEDCOD_"|"_UNTSTDCD_"|"_COMMNTCD_"|"_DEADCODE_"|"_REVHIST
	U IOSTATS
	; STATS CSV file - routine,hit,miss,percent
	W ROUTINE,",",TSTEDCOD,",",UNTSTDCD,",",$J(TSTEDCOD/(TSTEDCOD+UNTSTDCD)*100,0,5),!
	S IO2=$$FILE^%TRNLNM(ROUTINE,dir)_".HTM"
	O IO2:NEWV
	U IO2
	S SEQ=""
	f i=1:1:17 W ROU(i),!
	W "<TR><TD>&nbsp;</TD></TR>",!
	W "<TR><TD>&nbsp;</TD></TR>",!
	; Tested Code
	W "<TR><Td>Tested Code:</TD>",!
	W "<TD>&#09;</TD>",!
	W "<TD>&#09;</TD>",!
	W "<TD>"_TSTEDCOD_"</TD></TR>",!
	;
	;Not tested
	W "<TR><TD>Untested LOC:</TD>",!
	W "<TD>&#09;</TD>",!
	W "<TD>&#09;</TD>",!
	W "<TD>"_UNTSTDCD_"</TD></TR>",!
	;
	; Total LOC
	W "<TR><TD>Total LOC:</TD>",!
	W "<TD>&#09;</TD>",!
	W "<TD>&#09;</TD>",!
	W "<TD>"_(TSTEDCOD+UNTSTDCD)_"</TD></TR>",!
	;
	I TSTEDCOD+UNTSTDCD=0 S UNTSTDCD=1
	W "<TR><TD>%Coverage:</TD>",!
	W "<TD>&#09;</TD>",!
	W "<TD>&#09;</TD>",!
	W "<TD>"_($J(TSTEDCOD/(TSTEDCOD+UNTSTDCD),0,2)*100)_"</TD></TR>",!
	;
	;Coomented Code
	W "<TR><TD>Comment Lines:</TD>",!
	W "<TD>&#09;</TD>",!
	W "<TD>&#09;</TD>",!
	W "<TD>"_COMMNTCD_"</TD></TR>",!
	;
	;Dead Code
	W "<TR><TD>Dead Code:</TD>"
	W "<TD>&#09;</TD>",!
	W "<TD>&#09;</TD>",!
	W "<TD>"_DEADCODE_"</TD></TR>",!
	W "<TR><TD>&nbsp;</TD></TR>",!
	;
	W "</TABLE>"
	W "<TABLE>"
	;
	; Header for code
	W "<TR><TD width=""30"">Hits</TD>",!
	W "<TD width=""30"">Time</TD>",!
	W "<TD>Code</TD></TR>",!
	S SEQ=32
	F  S SEQ=$O(ROU(SEQ)) Q:SEQ=""  D
	.	W $P(ROU(SEQ),$C(maxCharV),1),!
	.	W "<TD width=""30"">"_$P(ROU(SEQ),$C(maxCharV),2)_"</TD>",!
	.;	W "<TD>&#09;</TD>",!
	.	W "<TD width=""30"">"_$P(ROU(SEQ),$C(maxCharV),3)_"</TD>",!
	.;	W "<TD>&#09;</TD>",!
	.	W "<TD><pre>"_$P(ROU(SEQ),$C(maxCharV),4)_"</pre></TD></TR>",!
	W "</TABLE>",!
	W "</BODY>",!
	W "<HTML>"
	C IO2
	K ROU
	Q
WRITE(CODE,COLOR,INFO)
	S INFO=$G(INFO)
	;
	N maxCharV
	S maxCharV=$$MAXCHARV
	;
	I $P(INFO,":",1)="" S $P(INFO,":",1)="&#09;"
	I $P(INFO,":",2)="" S $P(INFO,":",2)="&#09;"
	S CODE=$P(INFO,":",1)_$C(maxCharV)_$P(INFO,":",2)_$C(maxCharV)_CODE
	S ROU(SEQ)="<TR BGCOLOR="""_COLOR_""">"_$C(maxCharV)_CODE
	S SEQ=SEQ+1
	;
	Q
GETLAB(CODE,LABEL)
	I $E(CODE)=";" Q
	S LABEL=""
	F I=1:1 S CHAR=$E(CODE,I) Q:I>8!(CHAR=" ")!(CHAR=$C(9))!(CHAR=";")!(CHAR="(")  S LABEL=LABEL_CHAR Q:I>7
	S LABSEQ=-1
	S QUITFRML=0
	Q
	;
HEADER(ROUTINE,TESTED,DEAD,UNTESTED,COMMENTS)
	S ROU(1)="<HTML>"
	S ROU(2)="<BODY>"
	S ROU(3)=""
	S ROU(4)="<TABLE>"
	S ROU(5)="<TR><TD><FONT SIZE=+1><B>Coverage Analysis: "_ROUTINE_".m<BR></B></FONT></TD></TR>"
	S ROU(6)="</TABLE>"
	S ROU(7)=""
	S ROU(8)="<TABLE>"
	S ROU(9)="<TR><TD><B>Legend:</B> lines with the following background colors</TD></TR>"
	S ROU(10)=""
	S ROU(11)="<TR><TD BGCOLOR="""_UNTESTED_""">&nbsp;&nbsp;&nbsp;&nbsp;- have not been covered/tested</TD></TR>"
	S ROU(12)="<TR><TD BGCOLOR="""_TESTED_""">&nbsp;&nbsp;&nbsp;&nbsp;- have been covered</TD></TR>"
	S ROU(13)="<TR><TD BGCOLOR="""_COMMENTS_""">&nbsp;&nbsp;&nbsp;&nbsp;- comment line - unreachable</TD></TR>"
	S ROU(14)="<TR><TD BGCOLOR="""_DEAD_""">&nbsp;&nbsp;&nbsp;&nbsp;- dead code - unreachable</TD></TR>"
	S ROU(15)="</TABLE>"
	S ROU(16)=""
	S ROU(17)="<TABLE>"
	S SEQ=33
	Q
	;
GETTYPE()	;
	N LINE,RETURN
	S RETURN=0
	U IO R LINE
	S FILETYPE="",ELEMENT=""
	I LINE["Procedure" S LINE=";Procedure"_$p(LINE,"Procedure",2)
	S LINE=$P(LINE,";",2)
	I $E(ROUTINE,1,2)="AG" S FILETYPE="Aggregate Function",ELEMENT=ROUTINE
	I $E(ROUTINE,1,2)="F0" S FILETYPE="DEPFEES",ELEMENT=ROUTINE
	I LINE["Filer" S FILETYPE="FILER",ELEMENT=$P(LINE," ",2) I '$D(^DBTBL("SYSDEV",1,ELEMENT)) S RETURN=1
	I LINE["Batch" S FILETYPE="BATCH",ELEMENT=$P(LINE," ",2) I '$D(^DBTBL("SYSDEV",25,ELEMENT)) S RETURN=1
	I LINE["Procedure" S FILETYPE="Procedure",ELEMENT=$P(LINE," ",2) I '$D(^DBTBL("SYSDEV",33,ELEMENT)) S RETURN=1
	I LINE["Executive" S FILETYPE="Executive",ELEMENT=$P(LINE," ",2) I '$D(^DBTBL("SYSDEV",33,ELEMENT)) S RETURN=1
	; Close and re-open file to reposition at start
	C IO
	;I FILETYPE="" U 0 W ROUTINE,?10,FILETYPE,?20,ELEMENT,?35,IO,!
	O IO:READ
	Q RETURN
PSL	;
	D PROCEED
	U 0 W "Complete Procedure Counts",!
	D TRIG
	U 0 W "Complete Trigger Counts",!
	D BCH
	U 0 W "Complete Batch Counts",!
	Q
PROCEED	;
	S PROC="",Y=""
	F  S PROC=$O(^DBTBL("SYSDEV",25,PROC)) Q:PROC=""!($E(PROC)="Z")  DO
	.	I $P(^DBTBL("SYSDEV",25,PROC),"|",9)'=1 Q
	.	S PGM=$P(^DBTBL("SYSDEV",25,PROC),"|",2) 
	.	I PGM="" Q
	.	S comments=0
	.	S CODE=0
	.	F  S Y=$O(^DBTBL("SYSDEV",25,PROC,Y)) Q:Y=""  D CHECKPRC(PGM,Y,25,PROC,Y)
	.	S $P(^TBXCDCVR(PGM),"|",7)=comments_"|"_CODE_"|Procedure|"_PROC
	Q
TRIG	;
	S PROC="",Y="",TBL="",QQ=""
	F  S TBL=$O(^DBTBL("SYSDEV",7,TBL)) Q:TBL=""!($E(TBL,1,2)="ZZ")  DO
	.	S PGM=$P(^DBTBL("SYSDEV",1,TBL,99),"|",2) 
	.	I PGM="" Q
	.	S comments=0
	.	S CODE=0
	.	F  S Y=$O(^DBTBL("SYSDEV",7,TBL,Y)) Q:Y=""   F  S QQ=$O(^DBTBL("SYSDEV",7,TBL,Y,QQ)) Q:QQ=""  D CHECKPRC(PGM,QQ,7,PGM,Y)
	.	S $P(^TBXCDCVR(PGM),"|",7)=comments_"|"_CODE_"|Trigger|"_TBL
	Q
BCH	;
	S PROC="",Y="",BCH="",QQ=""
	F  S BCH=$O(^DBTBL("SYSDEV",33,BCH)) Q:BCH=""!($E(BCH)="Z")  DO
	.	S PGM=$P(^DBTBL("SYSDEV",33,BCH),"|",2) 
	.	I PGM="" Q
	.	S comments=0
	.	S CODE=0
	.	F  S Y=$O(^DBTBL("SYSDEV",33,BCH,Y)) Q:Y=""!(Y="REVHIST")  F  S QQ=$O(^DBTBL("SYSDEV",33,BCH,Y,QQ)) Q:QQ=""  D CHECKPRC(PGM,QQ,33,BCH,Y)
	.	S $P(^TBXCDCVR(PGM),"|",7)=comments_"|"_CODE_"|BATCH|"_BCH
	Q
CHECKPRC(PGM,Y,level,PROC,y);
	S LINE=$G(^(Y))
	D CHK
	Q
CHK
	I LINE["*/",$G(COMMFLAG) S COMMFLAG=0 Q
	if LINE["/*" set COMMFLAG=1 Q
	I $G(COMMFLAG) S comments=comments+1
	E  I $TR($$TRIM^%ZS(LINE),$C(9)_"/","")'="" S CODE=CODE+1
	Q
PSLCODE	;
	N src
	S debug=1
	S (TSTEDCOD,DEADCODE,UNTSTDCD,COMMNTCD)=0
	S QUITFRML=0
	S STARTHIS=0,REVHIST=0
	I FILETYPE="Procedure" D PROC(ELEMENT,.src)
	I FILETYPE="Trigger" D COMPILE^DBSTRG(ELEMENT,.src)
	;
	I $D(src)  s SEQ=32  F  S SEQ=$O(ROU(SEQ)) Q:SEQ=""  K ROU(SEQ)
	S SEQ=33
	I $D(src) S SEQI="",COMM=0  F  S SEQI=$O(src(SEQI)) Q:SEQI=""  D
	.	S CODE=src(SEQI)
	.	S src=$E($TR($TR(CODE," ",""),$C(9),""),1,2)
	.	I $E(src)=";" Q
	.	I CODE["/*" S COMM=1
	.	I CODE["Revision History" S STARTHIS=1
	.	I $E(src,1,2)="//" D WRITE(CODE,COMMENTS) S:STARTHIS=0 COMMNTCD=COMMNTCD+1 Q
	.	I COMM,CODE["*/" D WRITE(CODE,COMMENTS) S COMM=0 Q
	.	I COMM D WRITE(CODE,COMMENTS) S:STARTHIS=0 COMMNTCD=COMMNTCD+1 Q
	.	S QUITCHK=$TR($$UPPER^SCAUTL($$TRIM^%ZS(CODE)),$C(9),"")
	.	I 'QUITFRML,QUITCHK="Q"!(QUITCHK="QUIT") S QUITFRML=1,NEWLINE=1
	.	S STARTHIS=0
	.
	.	I $D(PSLSRC(SEQI)) D WRITE(CODE,TESTED,PSLSRC(SEQI)) S TSTEDCOD=TSTEDCOD+1 Q
	.	I QUITFRML,'NEWLINE D WRITE(CODE,DEAD) S DEADCODE=DEADCODE+1 Q
	.	D WRITE(CODE,UNTEST) S UNTSTDCD=UNTSTDCD+1
	Q
	;
PROC(PROCID,src)	;
	N FILES,PGM,PFID,code,desc,i,ii,increm,rpcvar,rpcvar1,mplus,v,vpgm,z,zvar
	S v=^DBTBL("SYSDEV",25,PROCID)		        ; Header
	S vpgm=$G(^DBTBL("SYSDEV",25,PROCID,1))				; First line
	S desc=$P(v,"|",1)				; Description
	S PGM=$P(v,"|",2)				; Routine name
	I PGM="" S RM=$$^MSG(3056,PROCID) W $$MSG^%TRMVT(RM) H 2 Q
	S FILES=$P(v,"|",8)				; Access files
	S PFID=$P(FILES,",",1)				; Primary table
	S rpcvar=$P(v,"|",6)				; Variable names
	S rpcvar1=$P(v,"|",7)				; Additional names
	S mplus=$P(v,"|",9)				; Compiler option
	;
	I 'mplus S ER=1,RM=$$^MSG(4432,PROCID) Q
	S zvar=rpcvar
	I rpcvar1'="" S rpcvar=rpcvar_","_rpcvar1
	I rpcvar'="" S rpcvar=rpcvar_","
	S rpcvar=rpcvar_"UX,%O,vovrflg"			; Required variables
	;
	; *** 12/03/97 BC
	S z=PGM						; Parameter defined?
	S i=0
	I $P(vpgm,"(",1)=PGM S z=vpgm,i=1		;  Use user-defined tag
	;
	D add(z_" ; Procedure "_PROCID_" - "_desc)	; Routine header
	D ^SCACOPYR(.z)
	D add(z)					; Copyright message
	D add(" ;")
	D add(" ; **** This is a DATA-QWIK generated routine (level 25) ****")
	D add(" ;")
	;
	D
	.	s ii=""
	.	F  s ii=$o(code(ii)) q:ii=""  s src(ii)=code(ii),increm=ii ;6/7/99 mas
	.	s i=$g(i)    					;6/7/99 mas
	.	F  s i=$O(^DBTBL("SYSDEV",25,PROCID,i)) Q:i=""  S src(i+increm)=^(i)
	Q
	;----------------------------------------------------------------------
add(data)	; Insert procedural code into buffer 
	;----------------------------------------------------------------------
	S v=$o(code(""),-1)+1
	S code(v)=data
	Q
	;
MAXCHARV()	;
	;
	Q $$getPslValue^UCOPTS("maxCharValue")
	;
	;----------------------------------------------------------------------
DOC	;Private; Display documentation
	;----------------------------------------------------------------------
	N (VFMQ)
	S hdr="Display TBXCDCVR utility documentation"
	D DOCPRINT^TBX("DOCTEXT^TBXCDCVR",hdr)
	Q
	;
DOCTEXT	;Note that line are not tabbed to improve readability in the code
 ; Documentation for code coverage analyzer report generator utility TBXCDCVR
 ;
 ; This utility is used to produce a set of html files that show the results
 ; of the code coverage analysis gathered by TBXCDCV or otherwise.  The
 ; utility takes two input parameters:
 ;
 ;     . glob = global reference where coverage data is stored (required)
 ;     . dir  = directory to output .htm files (not required); if not
 ;              input, you will be prompted for it.
 ;
 ; For each routine that has coverage data, a .htm file will be generated
 ; reflecting the coverage information.
 ; $$EOF
