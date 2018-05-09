FORMFILL	;; -  - V5.0 - Batch fill data items into screen
	;;Copyright(c)2001 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/19/01 16:17:46 - SPIER
	;     ORIG:  Frank R. Sanchez (2497) - 07/20/89
	;
	; I18N=QUIT	Excluded from I18N Standards
	; ---------- Revision History ------------------------------------------
	;
	; 02/28/07 - RussellDS - CR25382
	;	     Eliminated ability to call from top.  Obsoleted that code,
	;	     which is no longer used.
	;
	;	     Removed old revision history.
	;-----------------------------------------------------------------------
	;
	Q
	;
PUT	; Put the selected objects into the screen
	;
	N BFR,FORMAT,FN
	;
	S FN=$P(FF,";",2),FORMAT="D OBJ^"_MAINPGM_"(DQP)"
	;;;W $$MSG^FORM((FF-$P(FF,";",2))_" Items selected")
	W $$MSG^FORM(FF-$P(FF,";",2)_" items selected")	
	;
PUTNXT	; Collate through FF and insert objects
	;
	S FN=FN+1 I FN>FF K FF G EXIT
	S DQP=FF(FN)
	;
	S py=$$ABSLTY^FORM,px=$$ABSLTX^FORM,ox=$$ORIGIN^FORM
	I $D(M(py,ox))  D CLROBJ^FORMFUN(py,ox)
	;
	X FORMAT ; Build the display
	;
	D ^FORMHDG($P(DQP,dl,1)_$S($P(DQP,$C(0),7)=0:$C(0),1:"")):FORMHDG
	I ER D MORE G EXIT
	;
	D FIT^FORMFUN(py,ox,$L(m))
	S M(py,ox)=VIDHL_m,D(py,ox)=DQP
	D PUTOBJ^FORMFUN(py,ox)
	;
	; If the next line down on a row based fast fill is past the limit, exit
	;
	I +FORMHDG<3,YLIMIT,FN<FF,py+1>YLIMIT S FN=FN+1,RM="Bottom margin ("_YLIMIT_")" D MORE Q
	G PUTNXT
	;
MORE	; Prompt for more fill
	;
	I '$$YN^DBSMBAR("",RM_", "_(FF-FN+1)_" objects left in buffer ... Continue?",1) Q
	;
	; 
	W $$MSG^FORM("Move the cursor to a new location and recall FILL command")
	S $P(FF,";",2)=FN-1
	Q
	;
EXIT	; Exit from function
	;
	Q:'$D(BFR)
	S R(BFR)=$$HEADER^FORMBFR W $$MSG^FORM("Object(s) overlayed "_BFR) ; *** BC - 11/02/93
	Q