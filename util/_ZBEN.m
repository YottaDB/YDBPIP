%ZBEN(par,input)	;Library;Benchmark Utilities
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/04/94 20:34:31 - SYSRUSSELL
	; ORIG:	Frank Sanchez
	;
	;----------------------------------------------------------------------
PROC(par,input)	;
	;----------------------------------------------------------------------
	;
	N z,I
	;
	S z=""
	F I=1:1:$L(par,",") S $P(z,",",I)=$$GETJPI^%ZFUNC("",$P(par,",",I))
	I $TR($g(input),",","")'="" s Z=$$NET(z,input)
	Q z
	;
	;----------------------------------------------------------------------
NET(par,input)	;
	;----------------------------------------------------------------------
	;
	F I=1:1:$L(par,",") S $P(z,",",I)=$P(par,",",I)-$P(input,",",I)
	Q par
	;
CPUTIM()	Q $$GETJPI^%ZFUNC("","CPUTIM")
BUFIO()	Q $$GETJPI^%ZFUNC("","BUFIO")
DIRIO()	Q $$GETJPI^%ZFUNC("","DIRIO")
	;
	;----------------------------------------------------------------------
GVSTAT(gvn) ; Return Global statistics
	;----------------------------------------------------------------------
	; 
	N region
	Q $VIEW("REGION",gvn)
	;
	;----------------------------------------------------------------------
GVACCUM(region,savrec) ; Accumulate into GTM gvstat string - Subtract input
	;----------------------------------------------------------------------
	;
	N z,I
	;
	I $$REGCK(region) S z=""
	E  S z=$VIEW("GVSTAT",region)
	;
	I $G(savrec)'="" F I=2:1:$L(z,",") D
	.	;
	.	N cat1,cat2,val1,val2
	.	S cat1=$P(z,",",I),cat2=$P($G(savrec),",",I)
	.	S val1=$P(cat1,":",2),val2=$P(cat2,":",2)
	.	S $P(z,",",I)=$P(cat1,":",1)_":"_(val1-val2)
	Q z
	;
	;----------------------------------------------------------------------
GVLIST(array,input)	; Returns an array of all database regions
	;----------------------------------------------------------------------
	;
	N z
	S z=$VIEW("GVFIRST"),array(z)=$$GVACCUM(z,$G(input(z)))
	F  S z=$VIEW("GVNEXT",z) Q:z=""  S array(z)=$$GVACCUM(z,$G(input(z)))
	Q
	;
        ;----------------------------------------------------------------------
REGCK(REGION)	; check for remote regions
        ;----------------------------------------------------------------------
	;
	S REMOTE=0
	S FILE=$V("GVFILE",REGION),FILE=$P($ZPARSE(FILE),";",1)
	S REMOTE=FILE["::"
	I REMOTE S DSP="W !,REGION,"" is on remote node.""" 
	Q REMOTE
	;
        ;----------------------------------------------------------------------
TIME(z) ; Print formatted elapsed time in 100's seconds
        ;----------------------------------------------------------------------
	;
        Q $E(z\360000+100,2,3)_":"_$E(z\6000#60+100,2,3)_":"_$E(z\100#60+100,2,3)_":"_$E(z#100+100,2,3)
