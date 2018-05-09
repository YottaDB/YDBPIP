OPTFILCK	;; Options file check
	;;Copyright(c) Sanchez Computer Associates, Inc.  All Rights Reserved -  - 
	;
	; Reset option file based on locations of files between SRTNS and MRTNS.
	;
	; Creates new version of options file if necessary
	;
	;    INPUT:  Option file name
	;   OUTPUT:  May be new options file
	;
	N
	S X=$ZCMDLINE			; Name of options file
	I X="" R !,"Option file name:  ",X
	S OPTFILE=X
	O OPTFILE:READ
	S DIR="",END=0
	F I=1:1 U OPTFILE R X Q:$ZEOF  D
	.	I 'END,X["SCA$" S END=1
	.	I END S END(I)=X Q
	.	I X[".OBJ]" S DIR=$P(X,"]",1)_"]",X=","_$P(X,"]",2)
	.	I DIR="" S START(I)=X Q
	.	S X=$TR(X,"-")
	.	S X=$TR(X,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
	.	F J=2:1 S FILE=$P(X,",",J) Q:FILE=""  D
	..		I FILE'[".OBJ" S FILE=FILE_".OBJ"
	..		S TMP(DIR,FILE)=""
	U 0 C OPTFILE
	;
	; Check any files in non .SRTNS directories.  If the files are
	; in .SRTNS, OPT file info to .SRTNS.  For files in .SRTNS, be
	; sure they are still there, if not move to .MRTNS.
	;
	S DIR="" 
	F  S DIR=$O(TMP(DIR)) Q:DIR=""  D
	.	I DIR["SRTNS.OBJ]" S SDIR=DIR
	.	I DIR["MRTNS.OBJ]" S MDIR=DIR
	Q:SDIR=""
	;
	S (DIR,FILE)="",CHANGES=0
	F  S DIR=$O(TMP(DIR)) Q:DIR=""  I DIR'=SDIR D
	.	F  S FILE=$O(TMP(DIR,FILE)) Q:FILE=""  D
	..		Q:$ZSEARCH(SDIR_FILE)=""		; Not in SRTNS
	..		K TMP(DIR,FILE)
	..		S TMP(SDIR,FILE)=""
	..		W !,FILE,?15,"moved from ",DIR," to SRTNS"
	..		S CHANGES=1
	;
	; Now do SRTNS to see if still there
	;
	S FILE=""
	F  S FILE=$O(TMP(SDIR,FILE)) Q:FILE=""  D
	.	Q:$ZSEARCH(SDIR_FILE)'=""		; Not in SRTNS
	.	K TMP(SDIR,FILE)
	.	S TMP(MDIR,FILE)=""
	.	W !,FILE,?15,"moved from SRTNS to ",MDIR
	.	S CHANGES=1
	;
	W !!
	;
	I 'CHANGES W "No changes to options file "_OPTFILE,! Q
	;
	; Rebuild new options file
	O OPTFILE:(WRITE:NEWV) U OPTFILE
	S N=""
	F  S N=$O(START(N)) Q:N=""  W START(N),!
	S (DIR,FILE)=""
	F  S DIR=$O(TMP(DIR)) Q:DIR=""  S X=DIR D
	.	F  S FILE=$O(TMP(DIR,FILE)) D  Q:FILE=""
	..		I FILE="" S X=$E(X,1,$L(X)-1) W:X'="" X,! Q
	..		I $L(X)+$L(FILE)>75 W $E(X,1,$L(X)-1),"-",! S X=","
	..		S X=X_FILE_","
	F  S N=$O(END(N)) Q:N=""  W END(N),!
	U 0 C OPTFILE
	W !!,"New options file ",OPTFILE," created",!!
	Q
