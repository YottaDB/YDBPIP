DBSDSMC	;DBSDSMC;DBS - U - V4.4 - Mass screen compiler
	;;Copyright(c)2003 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/01/03 10:41:17 - CHENARDP
	;     ORIG: Frank R. Sanchez (FRS)
	;     DESC: Screen Compiler
	;
	;---------- Revision History -------------------------------------------
	; 01/31/07 - Pete Chenard - CR23705
	;	     Modified LOAD to make sure delimiter is correct on the screen.
	;
	; 10/23/06 - RussellDS - CR22719
	;	     Added BUILDALL section to allow mass recompiles.
	;
	; 09/14/06 - Pete Chenard - CR23007
	;	     Modified LOAD section to take the delimiter from the table
	;	     definition rather than the column, since delimiter is no longer
	;	     stored at the column level.
	;
	; 04/30/06 - RussellDS - CR20130
	;	     Fixed error in LOAD section.  Reference to FID should be DFID.
	;
	; 12/04/05 - Pete Chenard - CR 18258
	;	     Eliminated call to MPCLT^DBSDI
	;
	; 09/28/04 - RussellDS - CR12334
	;	     Replaced obsoleted calls to ^DBSANS1 with new procedure
	;	     DBSGETID.
	;
	; 01/13/03 - CHENARDP - 45497
	;	     Modified to call the new PSL Screen compiler.
	;
	; 05/12/00 - DOUGANM- 39582 
	;            To improve the performance of error handling, cleaned up 
	;            call to $$NEW^%ZT, and removed use of indirection. 
	;
	;-----------------------------------------------------------------------
START	;
	; I18N=QUIT
	;
	N CNT,CSCMP
	I $G(%LIBS)="" N %LIBS S %LIBS="SYSDEV"
	I $G(%UID)="" Q
	;
	S CNT=$$LIST^DBSGETID("DBTBL2") Q:'CNT
	;
	S NOLINK=0 ; Always link run-time routines
	;
SIDEXT	; Called from EXT (external entry point) to include
	; error trapping.
	;
	N $ZT
	S $ZT=$$SETZT^%ZT("ZT^DBSDSMC")
	;
	S ZSID="",%TO=0
	W !!!!!!!
	W "Compiling screens"
	W "   ",$$TIM^%ZM	; *** BC - Replace ^%T with ^%ZM
	;
SID	S ZSID=$O(^TEMP($J,ZSID)) I ZSID="" Q
	;
SID1	W !,%LIBS,"   ",ZSID,"   "
	S PGM=$P(^DBTBL(%LIBS,2,ZSID,0),"|",2)
	;
	N (io,%DB,%UID,%LIBS,ZSID,%TO,TEMP,PGM,NOLINK,%MSKC)
	K TEMP(ZSID) S SID=ZSID
	S LINKAGE=$D(^DBTBL(%LIBS,2,SID,-1)),ER=0
	S CSCMP=$P(^DBTBL(%LIBS,2,SID,0),"|",22)	; *** BC - 06/24/94
	I LINKAGE,'CSCMP D LINKAGE G SID
	D CMODES
	G SID
	;
CMODES	;Compile various modes
	S ER=0 D RELOAD I ER Q  ; Update DI info from files def.
	;
	; ================ v 7.0 COMPILER ===============
	;
	D ^DBS2PSL(SID,NOLINK) Q  ; compile for PSL
	;
	;
LINKAGE	;Screen linkages
	;
	W " - linkage"
	;
	D ^DBSDSMP,DSPPGM
	Q
	;
DSPPGM	;Display compiled pgm and any error
	S:'$D(ER) ER=""
	I 'ER W ?5,"  ",PGM
	E  D ERR
	Q
	;
ERR	; Error encountered with screen integrity (Screen NOT compiled)
	;
	S:'$D(RM) RM="" S ^UTILITY("SIDERR",ZSID)=RM
	Q
	;
ZT	;
	;
	K (NOLINK,%UID,%LIBS,ZSID,TEMP,BPSOPT,PGM)
	D ET^%ZT(.ET)
	I ET="INTERRUPT" Q
	W !!,$P($ZS,",",2,99),!!
	G SID
	;
NEWVN	; Reassign screen numbers based NEWVN
	;
	S N="" W !!,"Deleting V programs",!
	S ^DBTBL(%LIBS,0,"S")=1
	;
LP	S N=$O(^DBTBL(%LIBS,2,N)) Q:N=""
	I $D(^DBTBL(%LIBS,2,N,-3)) G LP ; Skip implicits
	S X=$P(^DBTBL(%LIBS,2,N,0),"|",2)
	I X'?1"V"2N.E G LP ;Not a V pgm
	S $P(^DBTBL(%LIBS,2,N,0),"|",2)="" ;Null old pgm name
	S:X?1"V"2N1E3.4N X=$E(X,1,3)_"S"_$E(X,5,8)_","_$E(X,1,3)_"B"_$E(X,5,8)
	D DEL^%ZRTNDEL(X) W !,N,?12,X
	G LP
	;
	;
RELOAD	; Re-load current DI info during mass compile
	N tbl
	S NI=0,PFID=$P(^DBTBL(%LIBS,2,SID,0),"|",1),FILES=PFID
	F SEQ=0:1 S NI=$O(^DBTBL(%LIBS,2,SID,NI)) Q:NI=""  D LOAD
	Q
	;
LOAD	; Load DT and XR arrays from disk
	N del
	S D=^DBTBL(%LIBS,2,SID,+NI),OLNTB=$P(D,"|",1),D=$P(D,"|",2,99)
	S NM=$P(D,"|",4)
	;
	I "@"[$E(NM) Q  ; Literal or null
	;
	I NM["[" S X=NM D MPLCT S NM="["_DLIB_","_DFID_"]"_DI I $D(%LIBSRW) I DLIB'=LIB!(DFID'=FID) S OLNTB=+OLNTB_"*#"_$P(OLNTB,"#",2)
	;
	; Get table delimiter since it is no longer stored at th column level
	I '$D(tbl(DFID)) S tbl(DFID)=^DBTBL("SYSDEV",1,DFID,10)
	S del=$P(tbl(DFID),"|",1)
	;
	I '$D(^DBTBL(%LIBS,1,DFID,9,DI)) S NEW=D W !,?15,"[",DFID,"]",DI," - invalid data item",! S ER=1
	E  S NEW=^(DI)
	S X=$P(D,"|",17)
	S D=$P(NEW,"|",1,3)_"|"_NM_"|"_$P(NEW,"|",5,6)_"|"_$P(D,"|",7,8)_"|"_$P(NEW,"|",9)_"|"_$P(D,"|",10,11)_"|"_$P(NEW,"|",12,99) ; FILE DEFINITION
	S $P(D,"|",17)=X
	S $P(D,"|",20)=del
	;
	S Z=^DBTBL(%LIBS,2,SID,+NI),Z1=0
	S:$P(Z,"|",21)="" $P(Z,"|",21)=del
	;
	I $P(Z,"|",1)'["*" F I=3:1:9,12:1:14,20,21 I $P(Z,"|",I+1)'=$P(D,"|",I) S Z1=1 Q
	;
	; Copy file definition attributes into screen definition
	;
	I 'Z1 Q
	;
	S ^DBTBL(%LIBS,2,SID,+NI)=OLNTB_"|"_$P(D,"|",1,21) Q
	;
MPLCT	; Find source file & library
	;
	S DFID=$E($P(X,"]",1),2,99),DI=$P(X,"]",2,9),DLIB=""
	S:DFID["," DLIB=$P(DFID,",",1),DFID=$P(DFID,",",2)
	S:DLIB="" DLIB=%LIBS S:DFID="" DFID=PFID
	;
	I $D(MPLCT(DLIB,DFID)) S X=MPLCT(DLIB,DFID),LIB=$P(X,"|",1),FID=$P(X,"|",2) Q
	Q
	;
	;
	; External entry point for mass screen compiler
	;
	; Input :  ^TEMP($J,SID)=""
	;
	;       :  %UID  - User Id ( Default to 1 )
	;
EXT	;
	;
	I '$D(%LIBS) Q
	;
	S NEWVN=0,TEMP="",ZSID="",NOLINK=1 ; Skip Zlink
	I $G(%UID)="" S %UID=$O(^SCAU(1,0))
	;
	D SIDEXT
	Q
	;
BUILDALL	; Re-build all screens
	N %LIBS,%UID,NOLINK,SID
	;
	K ^TEMP($J)
	;
	S SID=""
	F  S SID=$O(^DBTBL("SYSDEV",2,SID)) Q:SID=""  S ^TEMP($J,SID)=""
	;
	S %LIBS="SYSDEV"
	S %UID=$$USERNAM^%ZFUNC
	S NOLINK=0
	;
	D SIDEXT
	;
	Q
	;
COMPILE(SID)	; Public - build one screen
	N %LIBS,%UID,NOLINK
	;
	K ^TEMP($J)
	S ^TEMP($J,SID)=""
	;
	S %LIBS="SYSDEV"
	S %UID=$$USERNAM^%ZFUNC
	S NOLINK=0
	;
	D SIDEXT
	;
	Q
