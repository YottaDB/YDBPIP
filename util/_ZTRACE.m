%ZTRACE	;M Utility;Utility to provide code tracing capabilities
	;;Copyright(c)1999 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/07/99 00:09:48 - RUSSELL
	; ORIG:	RUSSELL - 05/04/99
	; DESC:	Utilities to provide basic code tracing capabilities
	;
	;	This routine will modify the source code for the named
	;	routine by placing a function call at the beginning of
	;	each line that is either a tagged line or code.  The
	;	function call will log, during execution of the routine,
	;	a running list of lines executed.  The trace information
	;	is filed in ^%ztrace(key), where key is a unique identifier
	;	provided by you when setting up the trace.
	;
	;	Steps to use:
	;
	;		. D ADD^%ZTRACE(key,rtn,dir) - add trace code to rtn
	;		. D INIT^%ZTRACE(key,trace,count,stop) - initialize
	;		. D OUTPUT^%ZTRACE(key,option,io) - results for Excel
	;
	; KEYWORDS:     Coding tools
	;
	; LIBRARY:
	;	. ADD		- Add trace code to routine
	;	. INIT		- Initialize pre-run info
	;	. OUTPUT	- Output results file for Excel
	;
	;----------------------------------------------------------------------
ADD(key,rtn,dir)	; Add trace code to named routine
	;----------------------------------------------------------------------
	;
	; ARGUMENTS:
	;
	;	. key	Unique key to id this trace	/TYP=T/REQ/MECH=VAL
	;		Used as first key to ^%ztrace to
	;		avoid conflicts with other traces
	;		underway
	;
	;	. rtn	Routine to add trace code to	/TYP=T/REQ/MECH=VAL
	;
	;	. dir	Directory to place new routine	/TYP=T/NOREQ
	;		Default value is CRTNS, as defined
	;		by ^%ZRTNCMP
	;
	;
	n code,i,len,line,n,new,nline,tag,x
	s rtn=$tr(rtn,"^")
	d ^%ZRTNLOD(rtn,"x")
	s code=$$code(key)			; Get trace code to insert
	s n=""
	f  s n=$o(x(n)) q:n=""  d  s new(n)=nline
	.	s line=x(n),len=$l(line)
	.	i $e(line)?1AN!($e(line)?1"%") d  	; Get tag, if any
	..		f i=2:1:len q:$C(9,32)[$e(line,i)
	..		s tag=$e(line,1,i-1)
	..		s line=$e(line,i,len)
	.	e  s tag=""
	.	f i=1:1:len q:$c(9,32)'[$e(line,i)	; Strip tabs and spaces
	.	s line=$e(line,i,len)
	.	;
	.	; If comment only, don't add trace code
	.	i tag="",$e(line)=";" s nline=" "_line q
	.	;
	.	; If not structured DO, add code to front of line
	.	i $e(line)'="." s nline=tag_" "_code_line q
	.	;
	.	; If structured DO, find first code past last .
	.	; $c(9,32,46) = tab, space, period
	.	f i=1:1:$l(line) q:$c(9,32,46)'[$e(line,i)
	.	i $e(line,i)=";" s nline=x(n) q		; Comment
	.	s nline=tag_" "_$e(line,1,i-1)_code_$e(line,i,999)
	;
	d ^%ZRTNCMP(rtn,"new",0,$g(dir))
	q
	;
code(key)	; Return code segement added to provide trace
	q "s %ztrz=$$SV^%ZTRACE("""_key_""",$ZPOS) "
	;
SV(key,pos)	; Save trace data
	; ^%ztrace(key)=trace_flag|count_flag|stop_count
	; ^%ztrace(key,$j)=count, if stop flag set
	; ^%ztrace(key,"trace",$j,seq)=tag
	; ^%ztrace(key,"count",tag)=count
	;
	n x
	s x=^%ztrace(key)
	i $p(x,"|",1) d
	.	n seq
	.	s seq=$o(^%ztrace(key,"trace",$j,""),-1)+1
	.	s ^%ztrace(key,"trace",$j,seq)=pos
	i $p(x,"|",2) s ^(pos)=$g(^%ztrace(key,"count",pos))+1
	i $p(x,"|",3) d
	.	n count
	.	s count=$g(^%ztrace(key,$j))
	.	i count'<$p(x,"|",3) h
	.	s ^%ztrace(key,$j)=count+1
	q ""
	;
	;----------------------------------------------------------------------
INIT(key,trace,count,stop)	; Initialize trace structure & instructions
	;----------------------------------------------------------------------
	;
	; ARGUMENTS
	;	. key		Trace file key		/TYP=T/REQ
	;
	;	. trace		Flag to trace		/TYP=L/NOREQ/DEF=1
	;			If set, each thread (or job) running
	;			under this key will keep track of each
	;			line of code executed.
	;
	;	. count		Flag to count		/TYP=L/NOREQ/DEF=1
	;			If set, cumulative count of number
	;			of times each line is executed across
	;			all threads is gathered.
	;
	;	. stop		Stop count		/TYP=N/NOREQ
	;			Number of lines of code to execute,
	;			per thread, before halting execution.
	;			Halting is a hard (M Halt command) halt.
	;
	s trace=$s('$d(trace):1,trace:1,1:0)
	s count=$s('$d(count):0,count:1,1:0)
	k ^%ztrace(key)
	s ^%ztrace(key)=trace_"|"_count_"|"_$g(stop)
	q
	;
	;----------------------------------------------------------------------
OUTPUT(key,option,io)	; Out tab delimited file for Excel import
	;----------------------------------------------------------------------
	;
	; Arguments:
	;	. key		Trace file key		/TYP=T/REQ
	;
	;	. option	Trace or count info	/TYP=N/NOREQ/DEF=0
	;			=0 => output trace info
	;			=1 => output count info
	;
	;	. io		Output file		/TYP=T/REQ/NOREQ
	;
	; Output format for trace info:
	;	$j	sequence	tag	code
	;
	; Output format for count info (sorted by highest count first):
	;	count	tag	code
	;
	n code,ER,x
	s option=+$g(option)
	i $g(io)="" d  q:$g(ER)
	.	n IO
	.	d ^%SCAIO q:$g(ER)
	.	s io=IO
	e  d  q:$g(ER)
	.	s x=$$FILE^%ZOPEN(io,"WRITE/NEWV")
	.	i 'x w !,"Invalid file - "_$p(x,"|",2) s ER=1
	;
	u io
	i $g(IOTYP)="TRM" w !
	;
	s code=$$code(key)
	i 'option d  				; Trace output
	.	n job,line,n,pos
	.	w "Job",$c(9),"Seq",$c(9),"Position",$c(9),"Code",!
	.	s (n,job)=""
	.	f  s job=$o(^%ztrace(key,"trace",job)) q:job=""  d
	..		f  s n=$o(^%ztrace(key,"trace",job,n)) q:n=""  d
	...			s pos=^%ztrace(key,"trace",job,n)
	...			s line=$$line(pos)
	...			w job,$c(9),n,$c(9),pos,$c(9),line,!
	;
	e  d  					; Count output
	.	n count,line,pos
	.	w "Count",$c(9),"Position",$c(9),"Code",!
	.	k ^tmp($j)
	.	s pos=""
	.	f  s pos=$o(^%ztrace(key,"count",pos)) q:pos=""  d
	..		s count=^(pos)
	..		s ^tmp($j,count,pos)=""
	.	s count=""
	.	f  s count=$o(^tmp($j,count),-1) q:count=""  d
	..		f  s pos=$o(^tmp($j,count,pos)) q:pos=""  d
	...			s line=$$line(pos)
	...			w count,$c(9),pos,$c(9),line,!
	.	k ^tmp($j)
	;
	c io
	q
	;
line(pos)	; Return line of code, without trace code, and convert
	; tabs into single spaces
	n line
	x "s line=$t("_pos_")"
	s line=$p(line,code,1)_$p(line,code,2,999) 	; Strip trace code
	s line=$tr(line,$c(9)," ") 			; Tabs to space
	q line
