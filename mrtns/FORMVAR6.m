FORMVAR6	;; - UTL - V5.0
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 01/24/97 18:42:59 - CHIANG
	;     ORIG:  CHIANG -  8 FEB 1990
	;     DESC:  REPORT WRITER SECTION MARKER UTILITY
	;
	; I18N=QUIT	Excluded from I18N Standards
	; ---------- Revision History ------------------------------------------
	;
	; 01/24/97 - Bob Chiang - 23631
	;            Modified MUMPS2 section to change the field length of
	;            Run_Date and System_Date to 10 characters.
	;
	; 10/26/94 - Steve Canfield - I18N
	;	     Removed calls to $$^MSG.
	;
	; 10/25/93    Bob Chiang - I18N#23 (MENU BAR)
	;
	;             Modified to replace DBSMENU routine calls with DBSMBAR.
	;
	; 05/29/92    Robert Chiang
	;
	;             Use lookup table utility to create new marker
	;-----------------------------------------------------------------------
MARK	;
	;
	;
	I $D(M(py)) W $$MSG^FORM("Place marker on blank line only",1) q
	;
	; #MARK  or #MARK-T
	;
	N OP,OPT,Z,KEY,PFID,MARK,ZMARK,ZMARKER
	;
	; Define markers for all levels
	;
	D INIT
	I '$D(MARK) Q
	F I=1:1 Q:'$D(MARK(I))  D
	.	S Z=$$SEQBY^FORMDQ5D(MARK(I))
	.	I Z'="" S ZMARK(I)=Z_$J("",41-$L(Z))_" ("_MARK(I)_")" Q
	.	S ZMARK(I)=" "_MARK(I)
	;
	D MARK0
	;
	; ---------- Repaint region 10 to 24
	;
	D PUTRGN^FORMFUN(10_";"_LFTMAR,(BOTMAR-10)_";"_NUMCOL,1)
	Q
MARK0	;
	S Z="",I=0
	;
	S OLNTB=11001
	I STATUS D OFF^FORMSTAT
	S OPT=$$^DBSTBL("ZMARK(")
	D TERM^FORMINIT(133)
	;
	I 'OPT S X="" Q
	;
	S KEY=MARK(OPT)
	;
	I KEY="PAGE-HEADER",$ZP(M(PY))'="" W $$MSG^FORM("Place PAGE-HEADER on line 1 only",1) q
	I KEY="SUMMARY" Q:$$SUMCHK
	;
	;
	S ZMARKER(KEY)=1
	S X="#"_KEY
	;
	S H=$$HEADER^FORMINIT(128+2)
	I '$D(VA(H)) D VIDSP^FORMINIT(H)
	S ox=1,GROUP=KEY
	;
	D MARKER^FORMDQ5D ;		Return variable m (image)
	;
	S M(py,1)=H_m,D(py,1)="#"_KEY_dl_"T"_dl_120
	;
	D PUTOBJ^FORMFUN(py,1) ;	Display marker
	S VFMQ="Q"
	Q
	;
MARK3()	;
	N Z,Z1,Z2,Z3
	S Z3=""
MARK4	;
	S Z3=$O(^DBTBL(%LIBS,5,RID,Z3)) I Z3="" Q $P(FILES,",",1)
	S Z=$P(^(Z3),"|",1),Z1=$P($P(Z,"]",1),",",2),Z2=$P(Z,"]",2)
	I Z2=KEY Q Z1
	G MARK4
	;
INIT	;
	N I,X,Y,Z,J
	;
	S X="",Y="",J=1
	F  S X=$O(D(X)) Q:X=""  F  S Y=$O(D(X,Y)) Q:Y=""  D	; current marker
	.	S Z=$P(D(X,Y),dl,1) I $E(Z,1)="#" S ZMARKER($E(Z,2,99))=1
	;
	F I=1:1:10 Q:'$D(^DBTBL(%LIBS,5,RID,I))  D		; each level
	.	S X="["_$P($P(^(I),"|",1),",",2)		; skip header
	.	I I=1,'$D(ZMARKER(X)) S MARK(J)=X,J=J+1		; and trailer
	.	I I=1 Q						; for base level
	.	F Z=X,X_"-H",X_"-T" I '$D(ZMARKER(Z)) S MARK(J)=Z,J=J+1
	;
	F I="PAGE-HEADER","PAGE-TRAILER","SUMMARY" D		; special marker
	.	I '$D(ZMARKER(I)) S MARK(J)=I,J=J+1
	Q
	;
SUMCHK()	;
	; Place SUMMARY after last marker
	;
	N X,Y,Z,ER
	;
	S X="",Y=PY,ER=0
	F  S Y=$O(D(Y)) Q:Y=""  I $E($G(D(Y,1)))="#" S ER=Y
	I 'ER Q 0
	;
	W $$MSG^FORM("Invalid marker location",1)
	Q 1
	;
MUMPS	;
	N OP,F
	D MUMPS2 I 'OP Q
	I OP>1 Q
	W BTMPAG
	S X=$$^FORMREAD("",99,"Variable/Expression: ")
	I X["?" S X="" Q
	I X="" Q
	;
	S UX=1,ZVAR=1
	;
	; Report writer functions ?   @TOT([DEP]BALAVL)*100/@TOT([DEP]BAL)
	;
	S F=0 F I="@TOT","@MIN","@MIN","@CNT" I X[I S F=1 Q
	I F G MUMPS1
	;
	; Math operation ?   [DEP]BAL*[DEP]IRN/36500
	;
	I X?.E1"["1E.AN1"]"1E.AN.E F I="+","-","*","/","\","#" I X[I S F=1 Q
	I F G MUMPS1
	;
	I $E(X,1,2)'="<<" S X="<<"_X
	I X'?3E.E1">>" S X=X_">>"
	S DQP=X_dl_"T"_dl_20
	Q
MUMPS1	;
	S DQP=X_dl_"E"_dl_12
	Q
MUMPS2	;
	S X=""
	S OP(1)="Other",OP(2)="Run_Date|vrundate|T10" 		; *** 01/24/97
	S OP(3)="System_date|vsysdate|T10"			; *** 01/24/97
	S OP(4)="Time|%TIM|T8",OP(5)="Page|VPN|N3"
	S OP(6)="Rpt_ID|RID|T12",OP(7)="Rpt_Name|RN|T30"
	S OP(8)="Inst_Name|CONAM|T20"
	;
	; Other,Run_Date,System_Date,Time,Page,Peport_ID,Report_Name,Inst_Name
	;
	S OP=$$^DBSMBAR(103) I 'OP Q	; *** - BC - menu option 103 - 10/25/93
	;
	S X="<<"_$P(OP(OP),"|",2)_">>"
	S DQP=X_dl_$E($P(OP(OP),"|",3))_dl_$E($P(OP(OP),"|",3),2,3)
	S UX=1,ZVAR=1
	Q
COMPUTE	;
	W BTMPAG
	S X=$$^FORMREAD($P(DQP,dl,1),999,"Computed Operation: ")
	I X="?" D COMPUTE1 G COMPUTE
	I X="" Q
	I X'["[" W $$MSG^FORM("Invalid syntax",1) G COMPUTE
	S UX=1
	S DQP=X_dl_"E"_dl_12 Q  ; Computed [FID]DI*[FID]DI
	Q
COMPUTE1	;
	;
	W $$MSG^FORM("[FID]DI*[FID]DI ...",1)
	Q
	;
	; @FUN(...)     CNT,MIN,MAX,AVG,TOT,CHR,TBL
	;
FUNC	;
	;
	N OPT,OP,Z,HIT,Y
	; ----------------------------------------------------------------------
	; *** BC - Modified to add internal and external option descriptions 10/25/93
	;
	S OP(1)="Total|TOT",OP(2)="Count|CNT",OP(3)="Minimum|MIN",OP(4)="Maximum|MAX"
	S OP(5)="Average|AVG",OP(6)="Character|CHR",OP(7)="Table Description|TBL"
	;
	; Total,Count,Minimum,Maximum,Average,Character,Table Description
	;
	S OPT=$$^DBSMBAR(104) I 'OPT S X="" Q
	;
	S z=$P(OP(OPT),"|",2),X="@"_z,$P(DQP,dl,1)=X
	;
	; *** ------------------------------------------------------------------
	K REQ
	;
	S $P(DQP,dl,3)=12 ; size
	S $P(DQP,dl,2)="E" ; format
	;
	I z="CNT" S $P(DQP,dl,2)="N",$P(DQP,dl,3)=8,$P(DQP,dl,5)="R" Q
	I z="CHR" S $P(DQP,dl,2)="T",$P(DQP,dl,3)=12,$P(DQP,dl,4)="-" Q
	I z="TBL" S $P(DQP,dl,2)="T",$P(DQP,dl,3)=20 Q
	S Y=py,Z="",HIT=0
	F  S Y=$O(D(Y)) Q:Y=""  F  S Z=$O(D(Y,Z)) Q:Z=""  I D(Y,Z)?1"#SUMMARY".E S HIT=1
	I 'HIT S $P(DQP,dl,5)="R" ; report summary
	E  S $P(DQP,dl,5)="G"
	;
	; Locate data item defined on the same column position
	;
	S Z=py,HIT=0 F  S Z=$ZP(D(Z)) Q:Z=""  D ITEM1 I HIT Q
	I 'HIT Q
	S Z=$TR(Y,"[]%","") I Z?.E1P.E S Y="<<"_Y_">>" ; Computed Items
	;
	S $P(DQP,dl,4)=Y
	Q
	;
ITEM1	;
	;
	I '$D(D(Z,px)) Q
	S Y=$P(D(Z,px),dl,1) I $E(Y)="[" S HIT=1 Q
	Q
