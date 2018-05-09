%ZRTNCMP(RTN,ARRAY,NOLINK,DIR,NOCMTS)	;M Utility; Compile MUMPS source code into a GT.M routine
	;;Copyright(c)1995 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/11/95 15:27:40 - CHENARD
	; ORIG:  Dan S. Russell (2417) - 10/21/88
	;
	; GT.M utility to compile MUMPS source code in input array ARRAY, into 
	; object file RTN.
	;
	; The directory in which the routine is created and compiled
	; is pointed to by ${SCA_CRTNS}.
	; However, since
	; $ZROUTINES may be changed at a GT.M level, ${SCA_CRTNS} 
	; may not be correct.  Therefore, the directory is determined
	; as follows:
	;
	;     1)  If DIR is passed as a parameter, use it
	;     2)  If ${SCAU_CRTNS} is defined as an env, use it
	;     3)  Locate crtns directory in $ZROUTINES, and use it
	;     4)  If all that fails, use ${SCAU_CRTNS}
	;
	;
	; KEYWORDS:	Routine handling
	;
	; ARGUMENTS:
	;	. RTN 	 - The program name that this source file will create
	;                  If not defined or null, will us TMP_($J#10000)
	;					/TYP=T/REQ/LEN=8/MECH=VAL
	;
	;	. ARRAY  - The array name where the source code is contained
	;                  local and global arrays are acceptable, as are
	;                  multiple subscripted (no limit) arrays.
	;                  If not defined or null will use ^TMP($J
	;					/TYP=T/MECH=VAL
	;	. NOLINK - If set, do not ZLink new routine
	;					/TYP=L/MECH=VAL
	;
	;	. DIR 	 - Explicit directory to compile to, if specified.
	;                  If not specified, use SCAU$CRTNS
	;					/TYP=T/NOREQ/MECH=VAL
	;
	;	. NOCMTS - If set, do not include comment lines unless they
	;                  have a line tag or a double semi-colon
	;					/TYP=L/MECH=VAL
	; INPUTS:
	;	. ${SCA_CRTNS} - Logical name defining directory for compiled
	;                      routines, must exist at OS level
	;					/TYP=T
	;
	; EXAMPLE:
	;	D ^%ZRTNCMP(RTN,ARRAY,NOLINK,DIR)
	;	
	;
	; *** NOTE:  Do not use any of the variables newed on the first
	;            line of code for ARRAY.
	;
	;---- Revision History-------------------------------------------------
	;
	; 03/19/02 - Pete Chenard - 43659
	;	     Modified Open command to open file with max record
	;	     length of 2K.
	;
	; 12/16/98 - Phil Chenard - 31142
	;            Modified COMPILE section to remove extra "" placed at
	;            the end of the the ZSY command string.  While some shells
	;            ignore this syntax, others (/bin/bash) complain.
	;
	; 10/11/95 - Phil Chenard - 13005
	;            Modified references to CRTNS directory by calling into
	;            platform specific utilities.
	;
	; 03/11/95 - Dan Russell
	;            Modified GETDIR function to make a more detailed attempt
	;            to determine CRTNS directory when various logical name
	;            are used.
	;
	;----------------------------------------------------------------------
	N %i,%io,%x,%z,%zx,%zz
	;
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZT^%ZRTNCMP")
	;
	I $G(RTN)="" S RTN="TMP"_$J#100000
	;
	I $G(ARRAY)="" S ARRAY="^TMP($J"
	E  I "),"[$E(ARRAY,$L(ARRAY)) S ARRAY=$E(ARRAY,1,$L(ARRAY)-1)
	;
	I ARRAY'["(" S ARRAY=ARRAY_"("
	;
	I $G(DIR)="" S DIR=$$GETDIR
	S %io=$$FILE^%TRNLNM(RTN_".m",DIR)
	O %io:(NEWV:REC=2048)
	N %img,%pdir
	S %img=$$^CUVAR("IMAGE")
	S %pdir=0
	I %img D GETOPT(RTN)   ; search through SCAU$DIR for *.OPT files for RTN
	;
	S %z=0
	U %io D WRTFILE(ARRAY) C %io
	I %img,%pdir D COPY
	D COMPILE
	D LINK
	Q
	;
COMPILE	; Compile the routine.  Do not compile if NOLINK and there is no
	; MUMPS.OLB in which to place routine.  In that case, recompile will
	; take place next time routine is accessed.
	;
	N LIB
	S LIB=""
	N OBJDIR
	S OBJDIR=DIR_"/obj"
	I DIR["/rtns" S OBJDIR="../obj"
	ZSY "${SCA_RTNS}/sca_compile.sh 1 "_DIR_" "_OBJDIR_" "_RTN_".m"
	Q
	;
LINK	; ZLink the routine into image
	I '$G(NOLINK) ZL RTN
	Q
	;
GETDIR()	; Get directory
	N CRTNS,END,I,P,X,Y
	S Y=$$SCAU^%TRNLNM("CRTNS")
	I Y'="" Q Y
	S X=$ZROUTINES
	S END=$F(X,"/crtns")
	I END D  Q CRTNS
	.	F I=END-1:-1:0 Q:" "[$E(X,I)
	.	S CRTNS=$E(X,I+1,END-1)
	;
	; Try parsing each element and finding "/crtns"
	S CRTNS=""
	F I=1:1 S P=$P(X," ",I) Q:P=""  D  Q:CRTNS'=""
	.	S P=$$TRNLNM^%ZFUNC(P,1)
	.	I P["/crtns" S CRTNS=P
	;
	I CRTNS="" S CRTNS="${SCAU_CRTNS}" 		; If all else fails!
	Q CRTNS
	;
GETOPT(rtn)	; Determine if rtn is in an .OPT file
	N ZOPT,I
	F I=1:1 S ZOPT=$ZSEARCH($$CDIR^%TRNLNM("*.OPT")) Q:ZOPT=""  D OPT1
	Q
	;
OPT1	N X,ET
	S X=$$FILE^%ZOPEN(ZOPT,"READ") 
	F  S X=$$^%ZREAD(ZOPT,.ET) Q:+ET=1  I X[rtn S %pdir=1 Q
	C ZOPT
	Q
	;
COPY	; copy routine to patch directory
	ZSY "cp "_$$SCAU^%TRNLNM("CRTNS",RTN_".m")_" "_$$SCAU^%TRNLNM("PRTNS")
	ZSY $$SCA^%TRNLNM("RTNS","sca_compile")_" "_$$SCAU^%TRNLNM("PRTNS","sca_compile")_" "_RTN_".m"
	Q
	;
ZT	D ZE^UTLERR
	Q
	;
WRTFILE(ARRAY)	; Output array to file
	N %vtop,%varray,%vnv,%vsubs,%v,%vi,%vx
	;
	S %vtop=0
	I $E(ARRAY,$L(ARRAY))="(" S %vtop=1
	;
	S %varray=ARRAY_$S(%vtop:"",1:","),%vsubs="%v)"
	;
DESCEND	N %vl,%v S %vl=$L(%vsubs)-3,%v="" F %vi=1:1 S %v=$O(@(%varray_%vsubs)) Q:%v=""  D SUBS
	Q
	;
SUBS	I $D(@(%varray_%vsubs))#10 D 
	. S %vx=%varray_$E(%vsubs,1,%vl)
	. S %vnv=$$QUOTES(%v),%vx=%vx_%vnv_")",%vx=@%vx
	. S %vx=$P(%vx," ",1)_$C(9)_$P(%vx," ",2,999)
	. I $G(NOCMTS),$E(%vx,1,2)=($C(9)_";"),$E(%vx,3)'=";"
	. E  W %vx,! ; Write the line
	;
	I $D(@(%varray_%vsubs))\10=0 Q
	S %vnv=$$QUOTES(%v) S %vsubs=$E(%vsubs,1,%vl)_%vnv_",%v)"
	D DESCEND S %vsubs=$E(%vsubs,1,%vl)_"%v)"
	Q
	;
QUOTES(data)	; Add quotes for subscripts
	N I,X,Z
	I +data=data Q data
	I data'["""" Q """"_data_""""
	S X=""
	F I=1:1:$L(data) S Z=$E(data,I),X=X_$S(Z="""":Z_Z,1:Z)
	Q """"_X_""""
