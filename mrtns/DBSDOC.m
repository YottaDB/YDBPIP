DBSDOC	;;DBS - U - V 4.2 - DATA QWIK DOCUMENTATION
	;;Copyright(c)2000 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/15/00 15:34:43 - DOUGANM
	;     ORIG:  CHIANG - 1/1/85
	;     DESC:  DATA ITEM DOCUMENTATIONS
	;
	; I18N=QUIT: Excluded from I18N standards.
	;---------- Revision History -------------------------------------------
	; 12/27/06 - RussellDS - CR24349
	;	     Fix undefined in ASK.
	;
	; 09/28/04 - RussellDS - CR12334
	;	     Replaced obsoleted calls to ^DBSANS with new procedure
	;	     DBSGETID.
	;
	; 05/12/00 - DOUGANM- 39582 
	;            To improve the performance of error handling, cleaned up 
	;            call to $$NEW^%ZT, and removed use of indirection. 
	;	     Replaced $ZP reference with $O(^gbl(...),-1) syntax.
	;-----------------------------------------------------------------------
	;
	Q
EDIT	;
	;
	S %SN="DBS",REGION=0
	S FID=$$FIND^DBSGETID("DBTBL1",0) Q:FID=""
	S %FID=FID
	S FDOC="" I $D(^DBTBL(%LIBS,1,FID,13)),^(13)'="" S FDOC=^(13) ; DOC FILE
	;
	S DLIB=%LIBS,DFID=FID,X="["_DLIB_","_DFID_"]" D ^DBSDI ; IMPLICIT MODE
	S XLIB=LIB
DI	;
	K DITEM,OLNTB
	;
	S %TAB("DITEM")=".ORGDI1/TBL=^DBTBL(XLIB,1,%FID,9,#10"
	;
	S %READ="@@%FN,,DITEM/REQ,",%NOPRMT="F",%FRAME=2
	D ^UTLREAD I VFMQ="Q" G EDIT
	S FID=%FID
	;
	I OPT'="T" G DI1
	;
TABLE	;
	;
	; Look-Up Table
	;
	S X=^DBTBL(XLIB,1,FID,9,DITEM),LNM=$P(X,"|",10)
	; Look-up table not defined for ~p1 ... Continue?
	I $P(X,"|",5)="" W $$^MSG(1660,LNM) G DI	; *** 10/27/94
	;
TABLE1	;
	S X=^DBTBL(XLIB,1,FID,9,DITEM),LNM=$P(X,"|",10)
	;
	N $ZT
	S $ZT=$$SETZT^%ZT("ZT^DBSDOC")
	;
	K TBNAM,OLNTB
	;
	S %TAB("TBNAM")="|"_$P(X,"|",2)_"|||"_$P(X,"|",5)_"||S I(3)=""""||U|"_LNM_" OPTION"
	;
	S %READ="@@%FN,,TBNAM/REQ,",%NOPRMT="F",%FRAME=2
	D ^UTLREAD I VFMQ="Q" G DI
	;
DI1	;
	;
	S DI=DITEM
	S PG=DI
	;
	I FDOC'="" S FID=FDOC ; SWITCH DOC FILE ID
	K X S N=""
	I OPT="D" F OP=1:1 S N=$O(^DBTBL(%LIBS,11,FID,PG,N)) Q:N=""  S X(N)=^(N)
	I OPT="T" F OP=1:1 S N=$O(^DBTBL(%LIBS,12,FID,PG,TBNAM,N)) Q:N=""  S X(N)=^(N)
	D INIT
	;
GOTO	;
	;
	; STANDARD EDITOR
	;
	D ^DBSWRITE("X",3,22,99999,"",MESSAGE)
	;
	S LSEQ=$O(X(""),-1) I LSEQ<1 G ABORT
	;
	I OPT="D" G FILED
	;
	K ^DBTBL(%LIBS,12,FID,PG,TBNAM)
	I LSEQ=1,X(1)?." " G GOTO1
	;
	S ^DBTBL(%LIBS,12,FID,PG,TBNAM)=LSEQ
	F I=1:1:LSEQ S ^DBTBL(%LIBS,12,FID,PG,TBNAM,I)=X(I)
GOTO1	;
	K X S FID=%FID G TABLE1
	;
	; Post processor for valid look-up table entry
	;
	;
FILED	;
	;
	K ^DBTBL(%LIBS,11,FID,PG)
	I LSEQ=1,X(1)?." " G ABORT
	S ^DBTBL(%LIBS,11,FID,PG)=LSEQ
	F I=1:1:LSEQ S ^DBTBL(%LIBS,11,FID,PG,I)=X(I)
	;
	;
ABORT	;
	K X
	S FID=%FID ; RESTORE ORIG FILE ID
	I OPT="T" G TABLE1
	G DI
	;
	;----------------------------------------------------------------------
DELETE	; Delete data item documentation (function DBSDOCDEL)
	;----------------------------------------------------------------------
	N %TAB,%READ,%FRAME,VFMQ,FID,p1
	S %TAB("FID")=".FID1/TBL=^DBTBL(%LIBS,11,"
	S %READ="@@%FN,,FID/REQ"
	S %FRAME=2
	D ^UTLREAD					; Select file name
	I VFMQ="Q" Q
	S p1=FID
	I $$^DBSMBAR(164)'=2 Q				; Verify again
	K ^DBTBL(%LIBS,11,FID)				; Delete documentation
	Q
	;----------------------------------------------------------------------
MOVE	; Copy documentation between files (function DBSDOCM)
	;----------------------------------------------------------------------
	K OLNTB,FFID,TFID
	S %TAB("FFID")=".FFID1/TBL=^DBTBL(%LIBS,1,/XPP=D FILEPP^DBSDOC"
	S %TAB("TFID")=".TFID1/TBL=^DBTBL(%LIBS,1,/XPP=D FILEPP^DBSDOC"
	;
	S %READ="@@%FN,,FFID/REQ,TFID/REQ,",%FRAME=2,%NOPRMT="F"
	D ^UTLREAD I VFMQ="Q" Q
	;
	; CHECK IMPLICIT  MODE
	;
	S DLIB=%LIBS,DFID=FFID,X="["_DLIB_","_DFID_"]" D ^DBSDI I ER Q
	S XLIB=LIB,XFID=FID
	S DLIB=%LIBS,DFID=TFID,X="["_DLIB_","_DFID_"]" D ^DBSDI I ER Q
	S YLIB=LIB,YFID=FID
	;
ASK	;
	N I
	S OLNTB=7030 K FFDI,TTDI
	S %TAB("FFDI")=".FROM3/TBL=^DBTBL(XLIB,1,XFID,9,#10/XPP=D FFDIPP^DBSDOC"
	S %TAB("TTDI")=".TOITEM1/TBL=^DBTBL(YLIB,1,YFID,9,#10/XPP=D TTDIPP^DBSDOC"
	;
	S %READ=",FFDI/REQ,TTDI/REQ,",%FRAME=2
	D ^UTLREAD I VFMQ="Q" G MOVE
	;
	S X="" F I=1:1 S X=$O(^DBTBL(%LIBS,11,FFID,FFDI,X)) Q:X=""  S ^DBTBL(%LIBS,11,TFID,TTDI,X)=^(X)
	S ^DBTBL(%LIBS,11,TFID,TTDI)=I-1
	;
	G ASK
	;
	Q
FILEPP	;
	I X="" S NI=999,%NOPRMT="F" Q
	Q
FFDIPP	;
	I X="" S NI=999,%NOPRMT="F" Q
	; No help documentation
	I '$D(^DBTBL(%LIBS,11,FFID,X)) S RM=$$^MSG(1947),ER=1 Q
	K RM F ZZ=1:1:10 I $D(^DBTBL(%LIBS,11,FFID,X,ZZ)) S RM(ZZ)=^(ZZ)_"|"_(ZZ+12*1000+1)
	S I(3)=""
	Q
TTDIPP	;
	I X="" S NI=999,%NOPRMT="F" Q
	; Same data item name? 
	I X=FFDI,XFID=YFID S ER=1,RM=$$^MSG(2448) Q
	Q
	;
INIT	;
	;
	;  -  Data Item Documentation 
	I OPT="D" S MESSAGE="["_FID_"]"_PG_$$^MSG(7221)
	;  Documentation 
	E  S MESSAGE="["_FID_"]"_PG_" - "_LNM_" "_TBNAM_$$^MSG(7164)
	Q
	;
	; ERROR TRAP
	;
ZT	;
	D ET^%ZT(.ET)
	I ET="INTERRUPT" Q
	G TABLE1
