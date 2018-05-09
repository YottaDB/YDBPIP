DBSSCR1	;DBSDS5A;DBS - U - V4.4 - PART II OF ^DBSSCR
	;;Copyright(c)1996 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/23/96 15:03:49 - SPIER
	;     ORIG:  BOB CHIANG (8447) - 07/11/86
	;     DESC:  PART II OF ^DBSDS5
        ; I18N=QUIT: Exculded from I18N standards.
	;
	;---------- Revision History -------------------------------------------
	;
	; 08/23/96 - SPIER - 22637
	;           Commented out a validation of $N comment
	;
	; 03/31/94  Bob Chiang - 12839
	;           Modified to save currency display flag in piece 4 of
	;           variable VO (screen display status flags). 
	;
	; 01/10/93  Frank Sanchez - DQDD001
	;
	;           Modified DGET subroutine to change $G(%) to "|"
	;
	; 01/04/93  Bob Chiang - FMSQA
	;          
	;           Modified to include vtab() in the KVAR list.
	;
	; 07/14/92  Robert Chiang  QA3163
	;
	;           Modified to replace screen post-processor flag REQ variable
	;           with a DQ reserved variable VSCRPP
	;-----------------------------------------------------------------------
START	;
	; *** BC - 03/31/94 - Save currency display flag in piece 4 of VO variable
	;
	S TMPC(1)=" S VO="_""""_+VPROBJ_"||13|"_$P(STS,"|",18)_""""
	S C(1)=" K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab"
	S C(2)=" S %MAX="_+SAVT_",VPT="_VPT_",VPB="_VPB
	I SCRCLR<2 S C(3)=$S(%LOOP:" S OLNTB=VPB*1000",1:" S OLNTB="_OLNTB)
	E  S C(3)=" S:'$D(OLNTB) OLNTB=0 I VPB*1000>OLNTB S OLNTB=VPB*1000"
	I $D(RPTPR) D RPTPR
	I $D(RPTDA) D RPTDA
	D NORPTDA
	;
	K XR,ZREPEAT G ^DBSSCR3
	;
RPTPR	; Repeating prompts logic
	;
	S X=" S VO=VO+"_(RPTPR-1)_",DY=DY+"_(VPB+1-%LOOP)
	D ADDC(X)
	Q
	;
RPTDA	; Clean up coding for repeating data items
	S VDAOBJ=VPROBJ+1
	S D=$ZP(TMPD(""))
	;
	I $G(RPTPR)="" S TMPD(1)=" S VX="_VPROBJ
	E  S TMPD(1)=" S VX=$P(VO,""|"",2)",C=0 F I=2:1:D S X=TMPD(I),Y=$F(X,"(@)") I Y S TMPD(I)=$E(X,1,Y-3)_"VX+"_C_$E(X,Y-1,999),C=C+1
	;
	I %REPREQ="A" S C(1)=C(1)_" S %REPREQ=%REPEAT*"_%MOD
	E  I %REPREQ>0 S C(1)=C(1)_" S %REPREQ="_(%REPREQ*%MOD+%OFF)
	;
	S REGION=VPB-%LOOP
	S D=D+1,TMPD(D)=" S DY=DY+"_(REGION+1)_",VX=VX+"_(RPTCNT-1)
	S C(1)=C(1)_" S %MODGRP="_(REGION+1)
	S C(2)=" S %MODOFF="_%OFF_",%MOD="_%MOD_",%MAX=%MOD*%REPEAT+%MODOFF,VPT="_VPT_",VPB="_(%LOOP-1)_"+"_$S(REGION:"(%REPEAT*"_(REGION+1)_")",1:"%REPEAT")_",BLKSIZ="_(BLKSIZ-RPTBLK)_"*%REPEAT+"_RPTBLK
	Q
	;
NORPTDA	; Assign object numbers to data objects
	;
	D NMBROBJ
	Q
	;
NMBROBJ	; Number VDA objects
	;
	S VDAOBJ=VPROBJ+1
	;
	F I=2:1:D S X=TMPD(I) D OBJ1
	;
	; *** BC - 03/31/94 - Save currency display flag in piece 4 of VO variable
	;
	I $G(RPTPR)="" S TMPD(1)=" S VO="""_(VDAOBJ-1)_"|"_(VPROBJ+1)_"|13|"_$P(STS,"|",18)_""""
	Q
OBJ1	;
	I X["VPTBL" S Z=1 D OBJ2 S TMPD(I)=X Q  ; data item protection
	;
	; convert VO(@) to next sequence number VO(n)
	;
	S Y=$F(X,"(@)") I 'Y Q
	S TMPD(I)=$E(X,1,Y-3)_VDAOBJ_$E(X,Y-1,999),VDAOBJ=VDAOBJ+1
	Q
	;
OBJ2	;
	;
	; Replace variable %MOD with constant
	;
	;
	S VPTBL=1
	I X["@%MOD" S X=$P(X,"@%MOD",1)_%MOD_$P(X,"@%MOD",2,99)
	;
	S Y=$F(X,"(@)",Z) Q:'Y  S X=$E(X,1,Y-3)_(VDAOBJ-1)_$E(X,Y-1,999)
	S Z=Y+1 G OBJ2
	Q
	;
ADDC(P)	; Add prompt lines of code
	;
	S C=C+1,TMPC(C)=P Q
	;
PP	; Merge post processor into compiled program
	;
	N OM,ZIPP
	;
	S EXTSID=SID,Z=1,N=PP-1,NN=PP+19
	;
	F  S N=$O(^DBTBL(%LIBS,2,SID,SEQ,N)) Q:N=""!(N>NN)  S X=^(N) I X'?." " S ZIPP(Z)=X,Z=Z+1
	;
	Q:'$D(ZIPP)  D ^DBSPARS I ER W !,RM,! Q
	;
	S PXSEQ=PXSEQ+1
	S PON=PON+1,^TMP($J,"PO",PON)="VP"_PXSEQ_" ;"
	S N="" F  S N=$O(OM(N)) Q:N=""  S PON=PON+1,^(PON)=OM(N)
	;
	; Insert Quit command
	;
	S N=$ZP(OM("")) I OM(N)'=" Q" S PON=PON+1,^(PON)=" Q"
	S PP="D VP"_PXSEQ_"^"_PGM Q
	;
VARSUB	; Build correct variable syntax V
	;
	N I,X,Y
	;
	S V="",Y=0,X=P(11),P(11)=""
	;
	F  S Y=$F(X,"<<",Y) Q:Y=0  I $P($E(X,Y+1,999),"<<",1)[">>" S X=$E(X,1,Y-3)_"""_"_$$DGET($P($E(X,Y,999),">>",1))_"_"""_$P($E(X,Y+1,999),">>",2,99)
	;
	S NS=""""_X_""""
	I $E(NS,1,3)="""""_" S NS=$E(NS,4,999) ; remove ""_
	I $E(NS,$L(NS)-2,999)="_""""" S NS=$E(NS,1,$L(NS)-3) ; REMOVE _""
	S FID="",VDACX=CX,PF="",PRO=1,VDAV1=VPRV1
	I (P(10)="$")!(P(10)="N") Q
	S P(10)="T"
	Q
	;
DGET(X)	; Insert $G() around variable references
	;
	I X[",%,",$L($P(X,",%,",1),"""")#2 S X=$P(X,",%,",1)_",""|"","_$P(X,",%,",2,99)
	;
	I X?.E1"^".E!(X?.E1"/".E) Q "$S(%O=5:"""",1:"_X_")" ; Global or /0
	;
	N Y,Z
	;
	F I=1:1 S Y=$E(X,I) Q:Y=""  D
	.	;
	.	I '(Y?1A!(Y="%")) Q
	.	I "+-*/\#&!_(:,><"'[$E(X,I-1) Q
	.	I $L($E(X,1,I),"""")#2=0
	.	;
	.	I $E(X,I-3,I-1)="$G(" Q
	.	I $E(X,I-3,I-1)="$O(" Q
	.;	I $E(X,I-3,I-1)="$N(" Q
	.	I $E(X,I-4,I-1)="$ZP(" Q
	.	D VAR
	Q X
	;
VAR	; Place $G() around variables
	;
	N II,lvn,nlvn,ar,Z
	;
	S ar=$S(%LOOP&(CY'<%LOOP):"rptlvns(lvn)",1:"lvns(lvn)")
	;
	I $E(X,I,$L(X))'["(" S lvn=$P($E(X,I,$L(X)),",",1) S:'$D(@ar) @ar=lvn Q
	;
	S II=I
	F I=I+1:1:$L(X)+1 Q:$E(X,I)'?1AN
	I $E(X,I)="(" F  S I=$F(X,")",I) Q:'I  S z=$E(X,II,I-1) I $L(z,"(")=$L(z,")") Q
	I I=0 S I=$L(X)+1
	;
	S lvn=$E(X,II,I-1) 				; Strip lvn from string
	;
	I lvn'["(" S:'$D(@ar) @ar=lvn Q			; Not an array
	;
	S nlvn=$G(@ar)
	I nlvn="" S lvns=$G(lvns)+1,nlvn="v"_lvns,@ar=nlvn
	;
	S X=$E(X,1,II-1)_nlvn_$E(X,I,$L(X))
	S I=I+$L(lvn)-$L(nlvn)
	Q
