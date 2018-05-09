FORMDQ2A(FSID)	;;DBS - UTL - V5.0
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/26/94 13:18:53 - CANFIELDS
	;     ORIG:  CHIANG - 19 JAN 1990
	;     DESC:  CONVERT SCREEN TTO V4.0 FORMAT
	;
	; I18N=QUIT	Excluded from I18N Standards
	; ---------- Revision History ------------------------------------------
	;
	; 10/26/94 - Steve Canfield - I18N
	;	     Removed calls to $$^MSG.
	;
	; 05/25/94 - Steve Canfield - I18N
	;            Replaced embedded messages with a call to extrinsic 
	;            function $$^MSG(msgid,p1,p2...) for phrase independence.
	;	     Also converted msgid from RMnnnn to nnnn.
	;
	; 11/02/93 - Bob Chiang - I18N#7
	;
	;            Modified return message handling with a call to extrinsic
	;            function $$^MSG(msgid,p1,p2...) for I18N development
	;            (phrase independence).
	;-----------------------------------------------------------------------
	;
START	;
	I $G(%LIBS)="" S %LIBS=^CUVAR("%LIBS")
	S %TO=$$TO^FORMVAR
	S DBOPT=2,OLNTB=40
	S MSG="Convert "_FSID_" to V4.0 format"
	;
	;
SCREEN	;
	S TSID=$$^FORMREAD("",12," ... new screen name: ") I TSID="" Q
	;
	I $D(^DBTBL(%LIBS,2,TSID)) W $$MSG^FORM("Already exists",1) G SCREEN	; *** BC - 11/02/93
	S SEQ=""
	S ^DBTBL(%LIBS,2,TSID)=^DBTBL(%LIBS,2,FSID)
	;
NSEQ	;
	S SEQ=$O(^DBTBL(%LIBS,2,FSID,SEQ)) I SEQ="" W $$MSG^FORM("Done") Q	; *** BC - 11/02/93
	I SEQ<0 G NSEQ
	S X=^(SEQ)
	I SEQ=0 S $P(X,"|",17)="",$P(X,"|",2)="" D SET G NSEQ ; Remove OOE flag
	S ATT=$P($P(X,"|",1),"#",2) ; Video Attributes
	I +ATT>127 S ATT=ATT-128 ; Graphic Mode
	I +ATT>63 S ATT=ATT-64 ; Convert to 0,1,2 (Normal,Hightlight,Reverse)
	S ATT=$S(ATT=1:2,ATT=2:1,1:0)
	;
	I $P(X,"|",5)?1"[".E1"]"1E.E,$P(X,"|",11)="" S ATT=0
	;
	S X=$P($P(X,"|",1),"#",1)_"#"_ATT_"|"_$P(X,"|",2,99) D SET G NSEQ
	;
	Q
	;
SET	;
	;W "." ;W !,SEQ,?5,^(SEQ),!,?5,X,!
	S ^DBTBL(%LIBS,2,TSID,SEQ)=X
	;
	; PRE/POST PROCESSOR
	;
	S Y="" F Z=1:1 S Y=$O(^DBTBL(%LIBS,2,FSID,SEQ,Y)) Q:Y=""  S ^DBTBL(%LIBS,2,TSID,SEQ,Y)=^(Y)
	Q
	
