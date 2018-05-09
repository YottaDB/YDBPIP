DBSSCR0	;; -  - V4.4 - SCREEN COMPILER
	;;Copyright(c)1999 Sanchez Computer Associates, Inc.  All Rights Reserved - 07/29/99 12:00:04 - CHIANG
	;     ORIG:  CHIANG - 15 AUG 1991
	;     DESC:  
        ; I18N=QUIT: Exculded from I18N standards.
	;
	;---------- Revision History -------------------------------------------
	; 08/31/2008 - RussellDS - CR30801
	;	Removed call to ^MSG.  Causing problems with bootstrap.  Will
	;	eventually provide framework message handler.
	;
	; 11/29/05 - RussellDS - CR18065
	;	     Removed reference to DBSPARS3, which has been obsoleted.
	;	     Replaced with call to DBS2PSL0.
	;
	;	     Removed old revision history.
	;
	;----------------------------------------------------------------------- 
	;
	; set up variable EXTSID for .MACRO. processor
	;
	S EXTSID=SID
	;
	S VSAV(1)="",VSAV(2)="",CORPGM="DBSBUR"
	S Q=$C(34),%="|",QQ=Q_Q
	S (BLKSIZ,DEFV,PXSEQ,PON,ISEQ,%MOD,MAXLN,SAVT,%OFF)=0,D=1,C=1
	S PLIB=%LIBS,PFID=""
	; K %A,%TAB,VFSN,UX,VO,VPTBL,vtab
	S KVAR="K %A,%TAB,VFSN,UX,VO,VPTBL,vtab"
	S (VPRV1,VPRV2,VDAV1,VDAV2)=0 ; Default all video to 0
	S VPRTYP=" " ; Literal field, no data type
	S VPRPRO=1 ; Protection Code for Literals, read only
	S VDAGI=0 ; Graphics toggle off for data
	;
	S OLNTB=1001
	S DES=^DBTBL(%LIBS,2,SID),STS=$G(^(SID,0))
	S FILES=$P(STS,"|",1),PGM=$P(STS,"|",2),CNTL=$P(STS,"|",10),%REPREQ=$P(STS,"|",5),%FLGPROT=$P(STS,"|",16)
	;
	I PGM="" D GTPGM^DBSDS
	S PGM=$TR(PGM,"*","S") D:PGM="" GTPGM^DBSDS S $P(^DBTBL(%LIBS,2,SID,0),"|",2)=PGM
	;
	; - Compile Run-Time Program - 
	W !!,SID,?11," - Compile Run-Time Program - ",PGM," "
	W $$TIM^%ZM,"  (",$G(^CUVAR("%VN")),")",!	; *** 07/29/99
	;
	S %LOOP=$P(STS,"|",7)
	;
	S SCRCLR=$P(STS,"|",8)+0 ; Screen Clear option 1=All, 0=To EOF, 2=Region
	;
	S PRE=$P(STS,"|",4) I PRE'?.E1"^"1A.AN S PRE=""
	;  S ER=0 D ~p1  I ER Q
	I PRE'="" S PRE=" S ER=0 D "_PRE_" I ER Q"
	E  S PRE=" ;"
	;
	I FILES'="" DO  ;			Implicit Logic
	.	;
	.	S DLIB=%LIBS,PFID=$P(FILES,",",1)
	.	S X=$$LIB^DBSDI(PFID),LIB=$P(X,",",1),PFID=$P(X,",",2)
	;
	S TOTOBJ=0,SEQ=0,ESEQ=SEQ,%NAMCUR=%LOOP*1000
	D LOAD,TABINFO^DBS2PSL0(SID,.ditab)
	S VPROBJ=0
	;
	S VPT=DT(1)\1000,VPB=DT($O(DT(""),-1))\1000	; 07/29/99
	;
	Q
	;
LOAD	; Create DT(SEQ) & %NAMCUR(DINAM) array's
	;
	S SEQ=$O(^DBTBL(%LIBS,2,SID,SEQ)) I SEQ="" Q
	S X=^(SEQ),TOTOBJ=TOTOBJ+1
	;
	I $P(X,"|",5)?1"<<".E1">>" S $P(X,"|",5)=$E($P($P(X,"|",5),">>",1),3,999)
	;
	; Convert <<VAR,FMT,SIZE,...>> to standard DT()
	;
	S DINAM=$P(X,"|",5)
	;
	; convert <<"TEXT">> to TEXT
	;
	I $P(X,"|",11)?1"<<"1E.E1">>" S X=$$VAR(X)
	;
	;I "@ooe"[$E(DINAM,1,4) S $P(X,"|",5)="" G LOADA
	I $E(DINAM)="[",DINAM?.E1",".E1"]"1E.E S DINAM="["_$P(DINAM,",",2)
	S %NAMCUR(DINAM)=$P(X,"|",1)
	I %NAMCUR,%NAMCUR(DINAM)>%NAMCUR S %NAMCUR(DINAM)=%NAMCUR(DINAM)_"+"
	I  S ZREPEAT($P(X,"|",5))=""
	I $E(DINAM)="@",$P(X,"|",2)["*" S $P(X,"|",5)="" ; Null text tags
LOADA	S DT(SEQ)=X
	G LOAD
VAR(X)	; <<VAR,PMT,FMT,SIZE,TBL,MIN,MAX,DEC>>
	;
	N Y,Z
	;
	S Y=$P(X,"|",11),Y=$E(Y,3,$L(Y)-2)
	S $P(X,"|",30)=$P(X,"|",5)
	;
	I Y?1A.AN!(Y?1"%".AN)!(Y?1A.AN1"("1AN.AN1")") DO  Q X
	.	;
	.	S $P(X,"|",5)=Y,$P(X,"|",11)="",$P(X,"|",2)=$P(X,"|",10)
	;
	;
	; <<VAR>> or <<$function>> syntax
	;
	I $E(Y)="$" Q X
	I ($P(Y,",",4)="") Q X
	I $P(Y,",",4)=0 Q $P(X,"|",1,10)_"|<<"_$P(Y,",",1)_">>|"_$P(X,"|",12,99)
	;
	S $P(Z,"|",5)=$P(Y,",",1) ; data item name ... replace with var name
	S $P(Z,"|",11)=$P(Y,",",2) ; Prompt
	S $P(Z,"|",10)=$P(Y,",",3) ; Type
	S $P(Z,"|",3)=$P(Y,",",4) ; Length
	S $P(Z,"|",13)=$P(Y,",",5) ; Minimum
	S $P(Z,"|",14)=$P(Y,",",6) ; Maximum
	S $P(Z,"|",15)=$P(Y,",",7) ; Decimal
	I $P(Y,",",8)>0 S $P(Z,"|",21)=124,$P(Z,"|",22)=$P(Y,",",8) ; position
	S $P(Z,"|",6)=$P(Y,",",9,99) ; Table
	;
	S $P(Z,"|",1)=$P(X,"|",1) ; Location preamble
	S $P(Z,"|",12)=$P(X,"|",12) ; Required flag
	S $P(Z,"|",18)=$P(X,"|",18) ; Print edit
	S $P(Z,"|",2)=$P(Y,",",3) ; format
	I $D(^DBTBL(%LIBS,2,SID,SEQ,1)) S $P(Z,"|",9)=1
	S $P(Z,"|",30)=$P(X,"|",30)
	I $D(^DBTBL(%LIBS,2,SID,SEQ,21)) S $P(Z,"|",8)=1
	Q Z
	;
IMPLICIT(Z)	;
	S NLIB=%LIBS
	S X=$P(^DBTBL(%LIBS,1,Z,10),"|",5) I X="" Q
	S NLIB=$E($P(X,",",1),2,99)
	Q
	;
	; ---------- Data item protection
PROT	;
	;
	I $G(VP(1))'["VPTBL(" Q
	D TMPD(" ;")
	; ~p1 S VO(@)=$E(VO(@),1,11)_(VP+1)_$E(VO(@),13,99)
	S X=VP(1)_" S VO(@)=$E(VO(@),1,11)_(VP+1)_$E(VO(@),13,99)"
	D TMPD(X)
	D TMPD(" ;")
	Q
TMPD(X)	S D=D+1,TMPD(D)=X Q
