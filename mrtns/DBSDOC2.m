DBSDOC2	;;DBS - UTL - V5.0 - DOCUMENTATION BY FILE ID
	;;Copyright(c)1999 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/23/99 18:02:46 - CHIANG
	;     ORIG:  CHIANG -  4 APR 1990
	;     DESC:  COPY/RESTORE DATA ITEM DOCUMENTATION (RMS INTERFACE)
	;
	;  I18N=QUIT: Excluded from I18N standards 
	;---------- Revision History -------------------------------------------
	; 07/10/06 - RussellDS - CR22121
	;	     Modified CREATE1 section to eliminate use of $A and $C for
	;	     starting collation to make Unicode compliant.
	;
	;	     Removed old revision history.
	;
	;-----------------------------------------------------------------------
START	;
	N OP,OLNTB,IO
	S OLNTB=38
	S OP("L")="Load",OP("C")="Create"
	S MSG=$$BANNER^DBSGETID($G(%FN))
	S %READ="@MSG/CEN/REV,,OPT/REQ,IO/REQ"
	; /DES=Documentation File Option/LEN=1
	S %TAB("OPT")=".OPT9/TBL=OP(/XPP=I X=""C"" S NI=99 K REQ"
	; /DES=RMS File Name/TYP=U/LEN=40
	S %TAB("IO")=".RMS5/XPP=D LOADPP^DBSDOC2"
	S %FRAME=2
	D ^UTLREAD I VFMQ="Q" Q
	I OPT="" Q
	I OPT="L" D LOAD Q
	I OPT="C" D CREATE Q
	;
CREATE	;
	K OLNTB
	;
	S FROM="A",TOITEM="ZZZ"
	S %TAB("DOCFID")=".FID1/TBL=^DBTBL(%LIBS,1,/XPP=D PP^DBSDOC2" ; *** 11/24/97
	S %TAB("FROM")=".FROM3"
	S %TAB("TOITEM")=".TOITEM1"
	S %TAB("IO")=".RMS5"
	;
	S %READ="@@%FN,,DOCFID/REQ,FROM/REQ,TOITEM/REQ,IO/REQ,"
	S %FRAME=2
	D ^UTLREAD I VFMQ="Q" Q
	;
CREATE1	;
	;
	S Z=$$FILE^%ZOPEN(IO,"WRITE/NEWV",5)
	;  Invalid RMS file name
	I 'Z U 0 W $$^MSG(7264) G CREATE
	;
	U 0 W !!
	;
	S FID=DOCFID
	;
	S Z="" F I=1:1:79 S Z=Z_"-"
	;
	; 02/23/99 BC
	;
	U IO W !,"["_FID,"]   ---  "_$$^MSG(7221)_" ("_FROM_" - "_TOITEM_")  "_$$DAT^%ZM(+$H)_"  "_$$TIM^%ZM,!!
	W !,Z,!
	S I="" F  S I=$O(^DBTBL(%LIBS,1,FID,0,I)) Q:I=""  W ^(I),!
	W Z,!
	I TOITEM="" S TOITEM=$C($$getPslValue^UCOPTS("maxCharValue"))
	;
	; Do first item if it exists
	I FROM'="",$D(^DBTBL(%LIBS,1,FID,9,FROM)) S N=FROM D DOC
	; Do remaining items
	S N=FROM F  S N=$O(^DBTBL(%LIBS,1,FID,9,N)) Q:N=""!(N]]TOITEM)  D DOC
	D CLOSE^SCAIO    ; ***XUS 07/22/94
	Q
DOC	;
	U 0 W $J(N,12) I $X>70 W !
	U IO W !!,"["_N_"]  - "_$P(^DBTBL(%LIBS,1,FID,9,N),"|",10),!
	S M="" F  S M=$O(^DBTBL(%LIBS,11,FID,N,M)) Q:M=""  W !,^(M)
	Q
	;
LOADPP	;
	; Invalid RMS file ~p1
	S Z=$$FILE^%ZOPEN(X,"READ",5) I 'Z U 0 S ER=1,RM=$$^MSG(1453)
	Q
LOAD	;
	S Z=$$FILE^%ZOPEN(IO,"READ",5) I 'Z U 0 W " ??" G LOAD
	;
	F  U IO R X U 0 W !,X I X'?." " Q
	;
	S FID=$P($P(X,"]",1),"[",2)
	;
	F I=1:1:10 U IO R X U 0 W !,X I X["----------" Q
	;
LOAD1	;
	; Continue?
	I '$$YN^DBSMBAR("",$$^MSG(603)) D CLOSE^SCAIO Q   ; ***XUS 07/22/94
	W !!
	S I=1,ON=0 K SAVE
LOAD2	;
	U IO S X=$$^%ZREAD(IO,.ZEOF) I ZEOF G END
	;
	I X'?1"["1E.E1"]".E S:X["--------" ON=I S SAVE(I)=X,I=I+1 G LOAD2
	;
	; File documentation
	;
	I ON<2 G LOAD2A
	S GLOBAL=$G(^DBTBL(%LIBS,1,FID,0))
	K ^DBTBL(%LIBS,1,FID,0)
	S ^DBTBL(%LIBS,1,FID,0)=GLOBAL
	F I=1:1:ON-1 S ^DBTBL(%LIBS,1,FID,0,I)=SAVE(I)
	;
LOAD2A	;
	S DI=$P($P(X,"]",1),"[",2)
	;
	; Invalid data item syntax 
	I '$D(^DBTBL(%LIBS,1,FID,9,DI)) U 0 W !,$$^MSG(1303,DI),X G LOAD2
	;
	S ON=0,I=1
	K SAVE
LOAD3	;
	U IO S X=$$^%ZREAD(IO,.ZEOF) I ZEOF G END
	I 'ON,X?." " G LOAD3
	S ON=1
	I X?1"["1E.E1"]".E D LOAD4 G LOAD2A
	;
	S SAVE(I)=X,I=I+1 G LOAD3
	;
LOAD4	;
	;
	F Z=I-1:-1:1 Q:SAVE(Z)'?." "  K SAVE(Z)
	;
	; Delete old documentation
	;
	K ^DBTBL(%LIBS,11,FID,DI)
	;
	U 0 W $J(DI,12) I $X>70 W !
	I Z=0 U IO Q
	;
	S ^DBTBL(%LIBS,11,FID,DI)=Z
	F I=1:1:Z S ^DBTBL(%LIBS,11,FID,DI,I)=$$FORMAT(SAVE(I))
	K SAVE
	U IO
	Q
END	;
	I $D(SAVE) D LOAD4
	D CLOSE^SCAIO     ;  *** XUS 07/22/94
	Q
FORMAT(LINE,SPACE1)	; Remove tabs, replace with correct number of spaces
	; First tab becomes a single space if SPACE1 = 1
	; Called by other utilities, e.g. ^%RTNDESC
	; Call by:  S X=$$FORMAT(X)
	;
	I LINE="" Q "" ; If null, return null
	N TAB,X
	I $G(SPACE1) S LINE=$P(LINE,$C(9),1)_" "_$P(LINE,$C(9),2,999) ; Make 1st tab a space
	S TAB=0
	F  S TAB=$F(LINE,$C(9),TAB) Q:'TAB  S LINE=$E(LINE,1,TAB-2)_$J("",8-(TAB-2#8))_$E(LINE,TAB,999)
	F X=$L(LINE):-1:0 Q:$E(LINE,X)'=" "
	S LINE=$E(LINE,1,X)
	Q LINE
	;
PP	;
	I X="" Q
	I '$D(^DBTBL(%LIBS,1,X)) Q
	I IO'="" Q
	S IO=$$HOME^%TRNLNM(X_".DOC")			;08/31/95
	S RM=IO_"|4"
	Q
	;
REPORT	; ---------- Report Documentation
	;
	N MSG,%TAB,SEQ,INC,N,DOC
	S MSG=$$BANNER^DBSGETID($G(%FN))
	S %TAB("RID")=".RID2/TBL=^DBTBL(%LIBS,5,"
	S %READ="@@%FN,,RID/REQ,",%FRAME=2
	D ^UTLREAD
	I VFMQ="Q" Q
	K DOC
	S X=90.99,ER=0
	F SEQ=1:1 S X=$O(^DBTBL(%LIBS,5,RID,X)) DO  I ER Q
	.	;
	.	I X=""!(X'?1N.E)!(X>110) S ER=1 Q
	.	S DOC(SEQ)=^(X)
	;
	D ^DBSWRITE("DOC")
	S SEQ=$O(DOC(""),-1) I 'SEQ Q
	;
	S X=90.99,ER=0
	F  S X=$O(^DBTBL(%LIBS,5,RID,X)) DO  I ER Q
	.	;
	.	I X=""!(X'?1N.E)!(X>110) S ER=1 Q
	.	K ^(X)
	.	;
	S INC=1 I SEQ>20 S INC=0.001
	S N=91
	F SEQ=1:1 Q:'$D(DOC(SEQ))  S ^DBTBL(%LIBS,5,RID,N)=DOC(SEQ),N=N+INC
	S X=^DBTBL(%LIBS,5,RID,0),X1=$P($P(X,"|",15),"#",1)
	S $P(X,"|",3)=+$H,$P(X,"|",15)=X1_"#"_$G(%UID)
	S ^(0)=X
	Q	
	;
SCREEN	; ---------- Screen Documentation
	;
	N %TAB,SEQ,INC,N,DOC
	S %TAB("SID")=".SID1/TBL=^DBTBL(%LIBS,2,"
	S %READ="@@%FN,,SID/REQ,",%FRAME=2
	D ^UTLREAD I VFMQ="Q" Q
	;
	K DOC
	S X=80.99,ER=0
	F SEQ=1:1 S X=$O(^DBTBL(%LIBS,2,SID,0,X)) DO  I ER Q
	.	;
	.	I X=""!(X'?1N.E)!(X>100) S ER=1 Q
	.	S DOC(SEQ)=^(X)
	;
	D ^DBSWRITE("DOC")
	S SEQ=$O(DOC(""),-1) I 'SEQ Q
	;
	S X=80.99,ER=0
	F  S X=$O(^DBTBL(%LIBS,2,SID,0,X)) DO  I ER Q
	.	;
	.	I X=""!(X'?1N.E)!(X>100) S ER=1 Q
	.	K ^(X)
	.	;
	S INC=1 I SEQ>20 S INC=0.001
	S N=81
	F SEQ=1:1 Q:'$D(DOC(SEQ))  S ^DBTBL(%LIBS,2,SID,0,N)=DOC(SEQ),N=N+INC
	S X=^DBTBL(%LIBS,2,SID,0),X1=$P($P(X,"|",15),"#",1)
	S $P(X,"|",3)=+$H,$P(X,"|",15)=X1_"#"_$G(%UID)
	S ^(0)=X
	Q	
