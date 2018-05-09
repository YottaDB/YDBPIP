%ZGCMP	;M Utility;Inter-directory global compare
	;;Copyright(c)1998 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/20/98 07:09:38 - CHENARD
	; ORIG:  Dan Russell (2417) - 13 Oct 1989
	; 
	; Compares globals between two directories.  Allows use of %G syntax 
	; for global specifications.
	;
	; Ignores trailing up-bar delimiters
	;
	; KEYWORDS:	Global handling
	;		UNIX Version
	;
	N (READ)
	;
	;
	D INT^%DIR,INT^%T		;%DIR now = path of global directory
	S DIRPNT=$$DIRPNT(%DIR)
	;
	W !!,"Inter-directory global compare"
	W !!,"Nodes defined in other directory but not in this will not be compared."
	W !,"Up-bar (|) delimiters will be ignored."
DIR	S CDIR=$$PROMPT^%READ("Compare to directory:  ","") I CDIR="" Q
	I '$$DIRCHK  W !!," ... you don't have access to that directory" G DIR
	S CDIRPNT=$$DIRPNT(CDIR)
	; 
DEV	S X=$$PROMPT^%READ("Show undefined nodes only?  No=> ","") I X="" S X="N"
	W !
	S UNDEF=$E($TR(X,"y","Y"))="Y"
DQ	S DQ=$$PROMPT^%READ("For DQ ignore program name difference?  Yes=> ","") W !
	S DQ="Y"[$E($TR(DQ,"y","Y"))
	D ^%SCAIO
	N $ZT
	S $ZT="ZG "_$ZL_":ERR^%ZGCMP"
	;
LOOP	U 0:(CTRAP=$C(3)) S READ("PROMPT")="Global ^",X=""
	D ^%READ I X="" G EXIT
	D VALID^%G(X) I ER U 0 W "  ",RM S ER=0 G LOOP
	U IO:(CTRAP=$C(3))
	W #!
	W "Global compare of ",X," between ",DIRPNT," and ",CDIRPNT," on ",$$^%ZD($H)," at ",%TIM,!!
	D OUTPUT^%G(X,"X","COMPARE^%ZGCMP")
	G LOOP
	;
ERR	I $ZS["CTRAP" G LOOP
	U 0 W !,$P($ZS,",",2,999)
	G LOOP
	;
EXIT	U IO W #
	U 0 I IO'=$P D CLOSE^%SCAIO
	Q
	;
COMPARE	;Compare between directories
	N X,NVAL,VALUE
	S X="^[CDIR]"_$E(%NODE,2,99)
	I $D(@X)#10 S NVAL=@X
	E  S NVAL="[NOT DEFINED]"
	S VALUE=$$RTBAR^%ZFUNC(%DATA),NVAL=$$RTBAR^%ZFUNC(NVAL)
	I NVAL=VALUE!(UNDEF&(NVAL'="[NOT DEFINED]")) Q  ; same values or only print undef's
	I $Y>(IOSL-8) W #
	;
	; For Data-Qwik screens - P|2 = routine, P|3 = date, P|10 = number of
	;                             updates, P|13 = project #, P|14 = modes,
	;                             P|15 = user id, P|16 = data item protect
	;               reports - P|2 = routine, P|3 = date
	;                             P|7 = data item prot, P|15 = user id
	;   pre/post-processors - P|2 = user id
	;
	I '(DQ&(%NODE?1"^DBTBL(".E)&("/2/5/13/"[("/"_$P(%NODE,",",2)_"/"))&(%NODE[",0)")) G WRITE
	;
	S TYPE=$P(%NODE,",",2)
	S Z1=VALUE,Z2=NVAL
	S $P(Z1,"|",2,3)="|",$P(Z2,"|",2,3)="|",$P(Z1,"|",15)="",$P(Z2,"|",15)=""
	I TYPE=2 F I=10,13,14,16 S $P(Z1,"|",I)="",$P(Z2,"|",I)=""
	I TYPE=5 S $P(Z1,"|",7)="",$P(Z2,"|",7)=""
	S Z1=$$RTBAR^%ZFUNC(Z1),Z2=$$RTBAR^%ZFUNC(Z2)
	I Z1=Z2 Q
WRITE	;
	W !,DIRPNT,?15,%NODE," = ",! ZWR VALUE
	W !,CDIRPNT,?15,%NODE," = ",! ZWR NVAL
	W ! 
	Q
	;
DIRCHK()	; Check for valid directory
	; If input is not valid but is logical name, add _GBLDIR to see if OK
	S CDIR=CDIR_"/gbls/mumps.gld"
	;F  Q:$ZSEARCH(CDIR)=""  ; Clear F$SEARCH
	I $ZSEARCH(CDIR)'="" Q 1 ; OK
	;
	;S CDIR=$$UPPER^%ZFUNC(CDIR)
	;I '(CDIR["]"!(CDIR["_GBLDIR")) S CDIR=CDIR_"_GBLDIR"
	I $ZSEARCH(CDIR)'="" Q 1 ; OK   
	Q 0 ; Not OK
	;
DIRPNT(DIR)	; Get printable directory name
	I DIR["_GBLDIR" Q $P(DIR,"_",1)
	I DIR["/gbls/" Q $P($P(DIR,"/",2),"/gbls",1)
	Q DIR
