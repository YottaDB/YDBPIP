FORMEDIT(FN)	;; -  - V5.0 - FORM editor commands
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/12/97 14:20:35 - NIB
	;     ORIG:  Frank R. Sanchez (1) - 11/03/88
	;
	; I18N=QUIT	Excluded from I18N Standards
	; ---------- Revision History ------------------------------------------
	; 07/14/06 - RussellDS - CR22121
	;	     Replaced $A references with $$BSASCII^SQLUTL and $C with
	;	     $$BTYECHAR^SQLUTL to ensure Unicode compliance.
	;
	; 08/12/97 - Betty Ni - 25653
        ;            Replaced follows operator "]" with a "]]".
	;
	; 10/26/94 - Steve Canfield - I18N
	;	     Removed calls to $$^MSG.
	;
	; 10/13/94 - Ying A.C. Liu - I18N
	;            Removed duplicate messages.

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
	;
	; 10/25/93  Bob Chiang - I18N#23
	;
	;           Modified to replace DBSMENU routine calls with DBSMBAR.
	;
	; 12/08/92  Jorma Sinnamo - I18N#7
	;
	;	    Modified call(s) to YN^DBSMENU to include return message
	;	    handling for I18N development (phrase independence.)
	;
	;-----------------------------------------------------------------------
	;
START	;
	N OPTION,MENUID
	S OPTION(1)="Command|COMMAND"
	S OPTION(2)="File|FILE"
	S OPTION(3)="Edit|EDIT"
	S OPTION(4)="Format|FORMAT"
	S OPTION(5)="Print|PRINT"
	S OPTION(6)="Select|SELECT"
	;
	S MENUID=91			; *** BC - new menu option 10/25/93
	D CALLFUN Q
	;
FILE(FN)	; Save, Load, Include, Exit
	;
	N OPTION,MENUID
	S OPTION(1)="Save|SAVE"
	S OPTION(2)="Load|LOAD"
	S OPTION(3)="Include|INCLUDE"
	S OPTION(4)="Function|FUNCTION"
	S OPTION(5)="Exit|EXIT"
	;
	S MENUID=92			; *** BC - new menu option 10/25/93
	D CALLFUN Q
	;
FORMAT(FN)	; Format item
	;
	N OPTION,MENUID
	S OPTION(1)="Style|STYLE"
	S OPTION(2)="Size|SIZE"
	S OPTION(3)="Graphic|GRAPH_ON"
	;
	S MENUID=93			; *** BC - new menu option 10/25/93
	D CALLFUN Q
	;
CALLFUN	; Call function
	;
	S FN=$G(FN)
	S FN=$$^DBSMBAR(MENUID)			; *** BC - Replace DBSMENU - 10/25/93
	I 'FN W:FN]]"" $$MSG^FORM(FN) Q
	;
	S CMMD=$P(OPTION(FN),"|",2)
	I $D(cmmd(CMMD)) X cmmd(CMMD) Q
	;
	I '$$PARSCMD^FORMCMD(CMMD) W $$MSG^FORM("Invalid command "_CMMD,1) Q	; *** BC - 11/02/93
	X cmmd(CMMD) Q
	;
EDIT(FN)	; File, load or print data
	;
	N OPTION,MENUID
	S OPTION(1)="Data|DATA"
	S OPTION(2)="Find|FIND"
	S OPTION(3)="Goto|GOTO"
	S OPTION(4)="Insert|INSERT"
	S OPTION(5)="Remove|DEL_OBJ"
	;
	S MENUID=94			; *** BC - new menu option 10/25/93
	D CALLFUN  Q
	;
ALIGN(FN)	; Align objects
	;
	I '$D(P) W $$MSG^FORM("No objects are selected",1) Q	; *** BC - 11/02/93
	;
	S FN=$G(FN)
	;
	; Alignment optins: Left Sides,Centers,Right Sides
	;
	S FN=$$^DBSMBAR(95) I 'FN Q	; *** BC - replace DBSMENU call 10/26/93
	;
ALIGNB	; Branch tag if FN parameter is defined
	;
	N BFR,m,d ; Temporary array to copy the P array into
	;
	S py="",px=""
	;
	N XEKUT,ax,lx,rx,xl,ox
	;
	S ax=$$ABSLTX^FORM
	;
	S XEKUT="F  S py=$O(P(py)) Q:py=""""  F  S px="_$S(FN=2:"$O",1:"$ZP")_"(P(py,px)) Q:px=""""  S xl=$L(M(py,px))-1-6,ox=ax"_$S(FN=3:"-xl",FN=2:"-(xl\2)",1:"")_" D ALIGNC"
	X XEKUT
	K P
	;
	I '$D(BFR) Q
	S oy=$O(R(BFR,"")),R(BFR)=$$HEADER^FORMBFR
	; 
	W $$MSG^FORM("Overlayed objects saved into buffer "_BFR)		; *** BC - 11/02/93
	Q
	;
ALIGNC	; Move the objects
	;
	I px=ox S M(py,ox)=P(py,ox)_$E(M(py,ox),2,999) D PUTOBJ^FORMFUN(py,ox) Q
	D CLROBJ^FORMFUN(py,px)
	S m=P(py,px)_$E(M(py,px),7,999),d=$G(D(py,px))
	K M(py,px),D(py,px),P(py,px)
	D FIT^FORMFUN(py,ox,xl)
	S M(py,ox)=m
	I d'="" S D(py,ox)=d
	D PUTOBJ^FORMFUN(py,ox)
	Q
	;
GT	G GO:VIDEO]]"~"
GI	; Graphics toggle on
	;
	I VIDEO']]"~" S VIDEO=$$BYTECHAR^SQLUTL(128+$$BSASCII^SQLUTL(VIDEO,1))_$E(VIDEO,2,6)
	S X="" F I=0:1:26 S $P(X," ",I)=GT(0)_$$BYTECHAR^SQLUTL(96+I)_GT(1)_$$BYTECHAR^SQLUTL(96+I)
	D GP
	W $$MSG^FORM(X)
	I video']]"~" W GT(0)
	Q
	;
GO	; Graphics toggle off
	;
	I VIDEO]]"~" S VIDEO=$$BYTECHAR^SQLUTL($$BSASCII^SQLUTL(VIDEO,1)#128)_$E(VIDEO,2,6)
	D GP
	W $$MSG^FORM("Graphics OFF") Q		; *** BC - 11/02/93
	;
GP	; Change the graphics attributes within the paste buffer
	;
	S py="",px=""
	F  S py=$O(P(py)) Q:py=""  F  S px=$O(P(py,px)) Q:px=""  S P(py,px)=$E(VIDEO)_$E(P(py,px),2,999)
	Q
	;
JOIN	; ---------- Join a group of objects (if possible) ----------
	;
	I '$D(P) W $$MSG^FORM("No objects are selected",1) Q	; *** BC - 11/02/93
	;
	N py,px,oy,ox
	S py="",px="",oy="",ox=""
	;
	F  S py=$O(P(py)) Q:py=""  F  S px=$O(P(py,px)) Q:px=""  D JOINB S oy=py,ox=px
	K P Q
	;
JOINB	;
	;
	S M(py,px)=P(py,px)_$E(M(py,px),7,9999)
	D PUTOBJ^FORMFUN(py,px)
	I $D(D(py,px)),$P(D(py,px),$C(0),1)'?1"@".E Q  ; Data, cannot join
	I py'=oy Q  ; Cannot join objects that are not on the same line
	I $D(D(oy,ox)),$P(D(oy,ox),$C(0),1)'?1"@".E Q  ; Previous object was data, cannot join
	; I ox+$L(M(oy,ox))'=px Q  ; Objects are not adjacent
	; I M(py,px)?.UNP S A(py,px)=$E(A(oy,ox))_$E(A(py,px),2,999) ; Upper case OK
	I $E(M(oy,ox),1,6)'=$E(M(py,px),1,6) Q  ; different headers
	S M(oy,ox)=M(oy,ox)_$J("",px-ox-$L(M(oy,ox))+6)_$E(M(py,px),7,99999)
	K M(py,px),D(py,px),P(py,px)
	S px=ox Q
	;
BREAK	; Break one object into two at cursor position
	;
	S py=$$ABSLTY^FORM,px=$$ABSLTX^FORM,ox=$$ORIGIN^FORM
	I '$D(M(py,ox)) Q  ; There is no object to break
	; 
	I $D(D(py,ox)) W $$MSG^FORM("Variable object, cannot break") Q	; *** BC - 11/02/93
	I px=ox Q  ; At the 1st character
	S M(py,px)=$E(M(py,ox),1,6)_$E($E(M(py,ox),7,99999),px-ox+1,99999)
	S M(py,ox)=$E(M(py,ox),1,6)_$E($E(M(py,ox),7,99999),1,px-ox)
	I $D(P(py,ox)) S P(py,px)=P(py,ox) ; Add object to paste buffer
	Q
	;
FUNCTION(%FN)	; Direct function call
	;
FUNC1	;
	I $G(%FN)="" S %FN=$$^FORMREAD("",20,"Function name","U") Q:%FN=""
	;
	I %FN[" " N %BLK S %BLK="/,"_$P(%FN," ",2,999),%FN=$P(%FN," ",1)
	;
	I '$D(^SCATBL(1,%FN)) W $$MSG^FORM("Invalid function "_%FN,1) K %FN G FUNC1
	; 
	I %FN'?1"DBS".E W $$MSG^FORM("Invalid DATA-QWIK function "_%FN,1) K %FN G FUNC1
	;
	D TRMRES^FORMINIT
	D DBSONLY ; Data Qwik only in direct mode
	W $$MSG^FORM("Control returned from FUNCTION",1)		; *** BC - 11/02/93
	D PUTRGN^FORMFUN()
	Q
	;
DBSONLY	; Direct mode, call Data-Qwik functions only
	;
	N (%BLK,%FN,%LIBS,%UID,%TO,CONAM)
	;
	I '$D(%LIBS) S %LIBS=$S($D(^CUVAR("%LIBS")):^("%LIBS"),1:"SYSDEV")
	I '$D(CONAM) S CONAM=$G(^CUVAR("CONAM"))
	;
	S X=^SCATBL(1,%FN),%SN=$P(X,"|",11)
	I %SN'="DBS" W $$MSG^FORM("Only DATA-QWIK functions allowed in Direct mode",1)	; *** BC - 11/02/93
	D @$P(X,"|",4)
	Q
	;
DCL(X)	; Exit to DCL
	;
	W CLSCREEN
	D TRMRES^FORMINIT ; Reset the terminal
	S X=$$SYS^%ZFUNC($G(X))
	D TRMSET^FORMINIT
	; 
	W !,$$MSG^FORM("Control returned from DCL",1)	; *** - BC - 11/02/93
	D PUTRGN^FORMFUN()
	Q
	;
DR	; Fast exit from the editor
	;
	; 
	S ZB=$S($$YN^DBSMBAR("","Exit from the editor without filing changes"):"",1:13)
	Q
	;
	;
CUR(Y,X)	Q CSI_$G(Y)_";"_$G(X)_"H"
