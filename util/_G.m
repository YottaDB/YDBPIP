%G	;M Utility;Standard SCA global display
	;;Copyright(c)1998 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/13/98 08:54:22 - SYSCHENARD
	; ORIG:  Dan S. Russell (2417) - 09 Jan 89
	;
	; Standard SCA global output (%G format).  
	; VMS/OPEN VMS Platforms
	;
	; Includes utility section, OUTPUT, for one of three purposes:
	;
	;   1) Output in either %G format, i.e.,
	;
	;      ^ABC(1,2)="data"
	;
	;   2) Output in %GO format, i.e.,
	;
	;      ^ABC(1,2,3)
	;      data
	;
	;   3) No output, as finds each node, executes specified
	;     tag^rtn to act on the data
	;
	; Also includes global parser to allow ranges, etc.
	;
	; Section OUTPUT outputs to current device in requested format, or 
	; executes a specified line tag for each node hit.
	;
	; Section GPARSE parses global for proper syntax and returns necessary 
	; variables for OUTPUT section.
	;
	; Call at top for standard %G.
	;
	; NOTES:  Exercise care in making changes since this utility
	;         is used by a number of others.
	;
	; See note in OUTPUT section for use of X format.
	;
	; KEYWORDS:	Global handling
	;
	;-----Revision History-------------------------------------------------
	;
	; 10/13/98 - Phil Chenard
	;            Modified GPARSE section when referencing $$VALID^%ZRTNS
	;            to not include the "^" in the routine name argument.
	;
	; 11/09/95 - Dan Russell
	;            Modified Phil's addition to only call $$CUVAR if valid
	;            routine.  May not be in routine search list if not IBS.
	;
	; 10/10/95 - Phil Chenard - 
	;            Implemented the use of T and C for PROFILE system date
	;            and computer system date.
	;
	;----------------------------------------------------------------------
START	N (READ)
	W !,"Global output",!
	D ^%SCAIO Q:$G(ER)
LOOP	N $ZT
	S $ZT="ZG "_$ZL_":ERR^%G"
	U 0:(CTRAP=$C(3)) S READ("PROMPT")="Global ^",X=""
	D ^%READ
	I X="" G EXIT
	I X="?" D ^%GD G LOOP
	U IO:(CTRAP=$C(3)) D OUTPUT(X,"%G")
	I ER U 0 W "  ",RM S ER=0
	G LOOP
	;
ERR	I $ZS["CTRAP" G LOOP
	U 0 W !,$P($ZS,",",2,999)
	G LOOP
	;
EXIT	U 0 I $D(IO),$I'=IO D CLOSE^%SCAIO
	Q
	;
	;----------------------------------------------------------------------
OUTPUT(%G,FORMAT,XTAG)	;System;Find next global node and output or process
	;----------------------------------------------------------------------
	;
	; Called by ^%G and variants to output global nodes
	;
	; If outputting to device, must have issued U device prior to call
	;
	;**NOTES on use of X format:
	;
	;        X format is handled by D @XTAG with the variables
	;          %NODE = global node reference
	;          %DATA = data at that node
	;        defined so that @XTAG can act upon them.
	;
	;        XTAG should protect all variables, i.e., NEW everything
	;        but %NODE and %DATA.
	;
	;        After call to XTAG, if $G(%STOP), OUTPUT section will be exited
	;
	;        See ^%GCOPY for sample use of X format
	;
	; Uses variables returned by GPARSE section plus the following
	;
	; %G is a printable full global reference string
	; %G(level) = number of characters in %G that should always be
	;             printed for that level
	;
	; %GS(level) = current subscript at that level
	;
	; KEYWORDS:	Global handling
	;
	; ARGUMENTS:  
	;	. %G		Global reference	/TYP=T/MECH=VAL
	;
	;	. FORMAT	Output format		/TYP=T
	;			  %G  for %G format
	;			  %GO for %GO format (also used for %GOGEN)
	;			  X   for process node by node
	;
	; RETURNS:
	;	. ER		Error flag		/TYP=N/COND
	;
	;	. RM		Error message		/TYP=T/COND
	;
	Q:'$D(%G)
	N OLDG,%COM,%DATA,%DEPTH,%END,%GD,%GLOBF,%GLOBG,%GS,%I,%LOW,%LSTWR,%LWLEN,%NODE,%NUM,%START,%Z
	I "/%G/%GO/X/"'[("/"_$G(FORMAT)_"/") S ER=1,RM="Invalid format" Q
	I FORMAT="X",$G(XTAG)'["^" S ER=1,RM="Invalid execution tag^rtn" Q
	D GPARSE Q:%G=""!ER
	S OLDG=%G
	I %GLOBF'=%GLOB,FORMAT'="X" W !,"Global ",%GLOB,!
	S %LWLEN=0
	F %I=1:1:%NUM+1 S %GS(%I)=$G(%START(%I))
	S %COM="",%LSTWR=0
	S %G=%GLOBF_"(" F %GS=1:1:%LOW D QUOTES S %G=%G_","
	I %LOW S %G=$E(%G,1,$L(%G)-1)
	E  I %GLOBF_"("=OLDG,@("$D("_%GLOBF_")-10") S %DATA=@%GLOBF D PNTTOP Q:$G(%STOP)
	I @("$O("_%GLOBF_"("_""""""_"))="_"""""") Q
	S %GS=1,%G=%GLOBF_"(",%G(1)=$L(%G)
	I '$D(%GS(1)) S %GS(1)="" 
	G OUT4
	;
OUT1	; Process this node as legitimate and in-range
	I %GS=%NUM,%DEPTH=2 D PNT:%D-10,PNTP:%D>9 Q:$G(%STOP)  G OUT2
	I %D-10,%GS>%NUM D PNT:%DEPTH-2 Q:$D(%STOP)
	I %D-10,%GS=%NUM D PNT:%DEPTH-1 Q:$D(%STOP)
	I %D>9 D QUOTES S %GS=%GS+1,%GS(%GS)=$S(%GS'>%NUM:%START(%GS),1:""),%G=%G_",",%G(%GS)=$L(%G),%D=$O(^(%GS(%GS-1),%GS(%GS))) G OUT4 ; Drop a level
	;
OUT2	S %GS(%GS)=$O(^(%GS(%GS)))
OUT3	I %GS(%GS)="" G BACKUP
	S %DATA="",%D=$D(^(%GS(%GS))) S:%D-10 %DATA=^(%GS(%GS))
	I %GS'>%NUM D EXCEED G BACKUP:%START
	G OUT1
	;
OUT4	; Get first node for lower subscript level
	I %GS(%GS)'="",$D(^(%GS(%GS))) G OUT3 ; Does node exist
	G OUT2 ; If not, start with $O()
	;
BACKUP	; Backup a level
	S %GS=%GS-1
	I %GS<1!(%GS<%LOW)!(%GS=%LOW&(%DEPTH'=3)) Q
	D PREV
	G OUT2
	;
PNT	; Print global
	; %LWLEN = length of last write
	;   %COM = what's in common
	; %LSTWR = level of last write
	;
	D QUOTES
	I FORMAT="X" S %NODE=%G_")" D @XTAG S X=@%NODE G PNTEND
	I FORMAT'="%G" W %G_")",!,%DATA,! G PNTEND
	I %LSTWR=%GS W !,?%LWLEN-$L(%G)+$L(%COM),$E(%G,$L(%COM)+1,256),")=",%DATA
	E  W !,%G,")=",%DATA S %LWLEN=$L(%G),%LSTWR=%GS
PNTEND	S %G=$E(%G,1,%G(%GS)),%COM=%G
	Q
	;
PNTTOP	; Handle top level data
	I FORMAT="X" S %NODE=%GLOBF D @XTAG S X=@%NODE G QUOTES
	I FORMAT="%G" W !,%GLOBF,"=",%DATA
	E  W %GLOBF,!,%DATA,!
	;
QUOTES	; Put double quotes back in
	I %GS(%GS)["""" G QUOT0
	I %GS(%GS)'["E",%GS(%GS)=+%GS(%GS) S %G=%G_%GS(%GS) ; Numeric
	E  S %G=%G_""""_%GS(%GS)_"""" ; String
	Q
	;
QUOT0	; String contains single quote, convert to double quote
	S %Z=$L(%G)+2,%G=%G_""""_%GS(%GS)_""""
QUOT1	S %Z=$F(%G,"""",%Z)
	I %Z'>$L(%G) S %G=$E(%G,1,%Z-1)_""""_$E(%G,%Z,999),%Z=%Z+1 G QUOT1
	Q
	;
EXCEED	; See if exceeded range of subscripts, if so, %START=1, else %START=0
	S %START=0 I %END(%GS)'="" G EXC1
	I %START(%GS)=""!(%START(%GS)=%GS(%GS)) Q
	S %START=1
	Q
	;
EXC1	I %GS(%GS)=%END(%GS) Q
	I %GS(%GS)'["E",%GS(%GS)=+%GS(%GS) G EXC2 ; Numeric
	; String
	I %END(%GS)'["E",%END(%GS)=+%END(%GS) S %START=1 Q  ; Endpoint is a string, too far
	S %START=%GS(%GS)]%END(%GS)
	Q
	;
EXC2	; Have a numeric subscript currently
	I %END(%GS)'["E",%END(%GS)=+%END(%GS) S %START=%GS(%GS)>%END(%GS) Q
	Q  ; Endpoint is a string, o.k.
	;
PNTP	; Print pointer
	I FORMAT'="%G" Q  ; Don't print pointer for %GO or X formats
	D QUOTES
	I %LSTWR=%GS W !,?%LWLEN-$L(%G)+$L(%COM),$E(%G,$L(%COM)+1,256),")pointer"
	E  W !,%G_")pointer" S %LWLEN=$L(%G),%LSTWR=%GS
	S %G=$E(%G,1,%G(%GS)),%COM=%G
	Q
	;
PREV	; Get previous naked level
	N X
	S X=$O(@($E(%G,1,$L(%G)-1)_")"))
	S %G=$E(%G,1,%G(%GS))
	S %COM="",%LSTWR=0 ; reset format for output
	Q
	;
	;----------------------------------------------------------------------
VALID(%G)	;Private;Validate global input using GPARSE section
	;----------------------------------------------------------------------
	; Called by various other utilities to validate input
	; Call by:  D VALID^%G(glob_ref)
	; Returns ER and RM if bad
	N (%G,ER,RM,READ)
	D GPARSE
	Q
	;
	;----------------------------------------------------------------------
GPARSE	;Private;Parse and validate global referenced
	;----------------------------------------------------------------------
	; INPUT:  %G - global reference
	;OUTPUT:  Return the following variables:
	;
	; %DEPTH specifies how low to go:
	;        1=> everything below this level, reference ended in ",",
	;        2=> this level only, reference ended in ")",
	;        3=> this and lower levels, reference ended in 
	;              neither "," or ")"
	; %GLOBF = global name, including extended reference, if any
	; %GLOB = global name, excluding extended reference
	; %START(subscript level) = starting subscript specified for that level,
	;                           or null string if start from beginning
	; %END(subscript level) = specifies terminating subscript if a : range
	;                         was specified (uses $C(255,255) for end of 
	;                         indefinite range) or a null string if not a
	;                         range or if want all subscripts on a level
	;                         (in which case %START(level) also = null)
	; %NUM = number of subscript levels specified
	; %LOW = lowest subscript level for which it and all higher subscripts
	;        are single (nonrange) well defined subscripts
	;        (you never have to backup to this level)
	;
	S ER=0
	I $G(%G)="" Q
	N (%DEPTH,%G,%GLOB,%GLOBF,%START,%END,%NUM,%LOW,ER,RM,READ)
	;
	; Add mnemonics for system dates (T & C)
	I $$VALID^%ZRTNS("CUVAR") S T=$$^CUVAR("TJD")
	I '$G(T) S T=+$H
	S T1=T+1
	S C=+$H,C1=C+1
	;
	I %G?.E1"LAST"1N.N.E D GPLAST
	D GPVER I ER S RM="Invalid syntax" Q
	K %START,%A
	S %X=$P(%G,"(",2,256),(%GLOB,%GLOBF)=$P(%G,"(",1)
	I %GLOB["]" S %GLOB=$P(%GLOB,"]",1)
	I @("'$D("_%GLOBF_")") S ER=1,RM="Global not defined" Q
	D GPMAIN I %LOW=-2 S ER=1,RM="Invalid syntax" Q
	Q
	;
GPVER	; Verify input syntax
	S ER=0
	I $E(%G,1)'="^" S %G="^"_%G
	I %G?1"^(".E S ER=1 Q  ; Invalid reference - naked not allowed
	I %G'["(" S %G=%G_"(" ; Select entire global
	I $E(%G,$L(%G))="," S %DEPTH=1 ; Select everything below this level
	E  I $E(%G,$L(%G))=")" S %DEPTH=2,%G=$E(%G,1,$L(%G)-1)_"," ; Select this level only
	E  S %DEPTH=3 ; Select this level and everything below
	Q
	;
GPMAIN	; Parse %G, doesn't accept scientific notation
	S %LOW=1,%START=1,%NUM=0,%P=0 G GPM3:%X=""
	; Start scanning a new subscript
GPM1	S %A=""
	I $E(%X,%LOW)="," S %X=$E(%X,1,%LOW-1)_""""""_$E(%X,%LOW,999)
GPM2	I $E(%X,%LOW)="""" F %I=1:1 S %LOW=%LOW+1 Q:%LOW>$L(%X)  I $E(%X,%LOW)="""" S %LOW=%LOW+1 G GPM2
	I $E(%X,%LOW)="(" S %P=%P+1,%LOW=%LOW+1 G GPM2
	I $E(%X,%LOW)=")",%P S %P=%P-1,%LOW=%LOW+1 G GPM2
	I ":,)"'[$E(%X,%LOW),$E(%X,%LOW)'?1C S %LOW=%LOW+1 G GPM2
	I $E(%X,%LOW)?1P,%P S %LOW=%LOW+1 G GPM2
	I $E(%X,%LOW)=":" G GPERR:%A'="" S %A=1_$E(%X,%START,%LOW-1),%LOW=%LOW+1,%START=%LOW G GPM2
	I $E(%X,%LOW)'=",",$E(%X,%LOW)'=")",$E(%X,%LOW)'="" G GPERR
	S %NUM=%NUM+1,%START(%NUM)=$E(%X,%START,%LOW-1),%LOW=%LOW+1,%START=%LOW D SUBS Q:%LOW=-2  G GPM1:%LOW'>$L(%X)
GPM3	F %I=1:1:%NUM Q:%START(%I)=""!(%END(%I)'="")
	S %LOW=%I-1
	Q
GPERR	S %LOW=-2 Q
	;
SUBS	; Put subscript in purer form without "", etc.
	; and setup %END() for ranges
	S %END(%NUM)=""
	I %A'="" D SUBS1 S %END(%NUM)=$S(%START(%NUM)]"":%START(%NUM),1:$C(255,255)),%START(%NUM)=$E(%A,2,999) D SUBS1 Q
	;
SUBS1	I %START(%NUM)'["E",%START(%NUM)=+%START(%NUM) Q  ; Numeric
SUBS10	I %P=1,%DEPTH=2,%LOW'<$L(%X) S:%START(%NUM)?.E1"," %START(%NUM)=$E(%START(%NUM),1,$L(%START(%NUM))-1),%LOW=%LOW-1 S %DEPTH=3,%START(%NUM)=%START(%NUM)_")" ; Right paren mistakenly
	; attached to whole global, not just this subexpression
	I %START(%NUM)'="" S @("%START(%NUM)="_%START(%NUM))
	Q
	;
GPLAST	; Parse entry of LASTnnn
	N ZLAST,VV,ZZ,Z
	S ZLAST=+$P(%G,"LAST",2),ZLAST=$P(%G,"LAST"_ZLAST,2)
	S X="S VV=$ZP(^"_$P(%G,"LAST",1)_$C(34)_"zzzzzzzzzz"_$C(34)_"))"
	X X S Z="^"_$P(%G,"LAST",1)_$C(34)_VV_$C(34)_")"
	F I=1:1:$P(%G,"LAST",2)-1 S ZZ=$ZP(@Z) Q:ZZ=""  S Z="^"_$P(%G,"LAST",1)_$C(34)_ZZ_$C(34)_")"
	I $L(Z) S %G=$E(Z,1,$L(Z)-1)_":""zzzzzzzzzzz"""_ZLAST
	Q
