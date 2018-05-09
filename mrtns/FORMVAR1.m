FORMVAR1	;Screen data item definition window 
	;;Copyright(c)2000 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/30/00 17:02:25 - SPIER
	;     ORIG:  Frank R. Sanchez (1) - 10/26/88
	;CALLED BY:  ^FORMVAR
	;     DESC: Data Item/Variable Definition window manager 
	;
	; I18N=QUIT	Excluded from I18N Standards
	; ---------- Revision History ------------------------------------------
	; 07/14/06 - RussellDS - CR22121
	;	     Replaced  $C with $$BTYECHAR^SQLUTL to ensure Unicode 
	;	     compliance.
	;
	; 06/08/06 - RussellDS - CR20967
	;	     Add note in DIREFDFT section.
	;
	; 10/30/00 - SPIER - 37209
	;            Modified DIREFDFT section, changed starting value for 
	;	     required to reflect that of the column definition.
	;
        ; 02/23/99  -  Chiang - 31754
        ;              Modified to use +$H (system date) as the input value
        ;              for the ^%ZM date utility.
        ;
        ;              Removed old revision history.
	;
	; 11/13/97 - SPIER - 26811
	;            Changed DIREFDFT section, the pre-processer code from the
	;	     data item deinition was not being defaulted when the DI 
	;	     was added to the screen. This occurred because the variable
	;	     Z2 was overwritten by protection of access keys.
	;	     Changed $zp to $O in two locations.
	;
	;----------------------------------------------------------------------
START	;
	;
	N ZVAR,ZNEW,vtblrtn,status
	K zztblfid
	;
	S vtblrtn="N X D VW^FORMVAR1",status=$G(STATUS)
	S ZNEW=1 I $D(D(py,ox)) S ZNEW=0
	I $G(VFMQ)?1N!'ZNEW G START1
	;
	S VFMQ="Q",REPAINT=-1,ZNEW=1
	;
	; ========== Create new object
	;
	;	Data Item,Variable,Expression,Quick Layout
	;
	S OP=$$^DBSMBAR(100) Q:'OP		; *** BC - menu option 100 (PF2 key) 10/25/93
	; 
	S ZVAR=0 
	I OP=4 D QL^FORMDQ2C() Q 		; Quick layout 04/26/93 BC
	I OP=2 D MUMPS Q:X=""  G START1 	; User Variables
	I OP=3 D EXPRESS Q:X=""  G START1 	; MUMPS expression
	;
START1	;
	;
	; ========== Clear Region for OBJECT definiition
	;
	D CLRRGN^FORMFUN S REPAINT=0
	I $P(DQP,dl,1)'="" S EDI(3)=0
	;
	N VO
	;
	S POSX=RHTMAR-33
	;
	I STATUS D OFF^FORMSTAT ; Remove status line
	;
	S TOPY=ORIGIN+1
	;
	D VBX,VPR,VDA,^DBSPNT(),VTAB Q
	;
VPR	; Build the prompts
	;
	N pr
	S VO="18|10|13"
	;
	; 
	S pr="Name:,Prot:,Req'd:,Disp:,Length:,Pre:,Post:,Tag:,Header:"
	;
	S VO(1)=$$BYTECHAR^SQLUTL(TOPY)_$$BYTECHAR^SQLUTL(POSX)_$C(5,0,0,0,0,0,0,0)_"01T"_$P(pr,",",1)
	S VO(2)=$$BYTECHAR^SQLUTL(TOPY+1)_$$BYTECHAR^SQLUTL(POSX)_$C(5,0,0,0,0,0,0,0)_"01T"_$P(pr,",",2)
	S VO(3)=$$BYTECHAR^SQLUTL(TOPY+1)_$$BYTECHAR^SQLUTL(POSX+23)_$C(6,0,0,0,0,0,0,0)_"01T"_$p(pr,",",3)
	S VO(4)=$$BYTECHAR^SQLUTL(TOPY+2)_$$BYTECHAR^SQLUTL(POSX)_$C(5,0,0,0,0,0,0,0)_"01T"_$P(pr,",",4)
	S VO(5)=$$BYTECHAR^SQLUTL(TOPY+2)_$$BYTECHAR^SQLUTL(POSX+22)_$C(7,0,0,0,0,0,0,0)_"01T"_$P(pr,",",5)
	S VO(6)=$$BYTECHAR^SQLUTL(TOPY+3)_$$BYTECHAR^SQLUTL(POSX+1)_$C(4,0,0,0,0,0,0,0)_"01T"_$P(pr,",",6)
	S VO(7)=$$BYTECHAR^SQLUTL(TOPY+3)_$$BYTECHAR^SQLUTL(POSX+24)_$C(5,0,0,0,0,0,0,0)_"01T"_$p(pr,",",7)
	S VO(8)=$$BYTECHAR^SQLUTL(TOPY+4)_$$BYTECHAR^SQLUTL(POSX+1)_$C(4,0,0,0,0,0,0,0)_"01T"_$P(pr,",",8)
	S VO(9)=$$BYTECHAR^SQLUTL(TOPY+4)_$$BYTECHAR^SQLUTL(POSX+22)_$C(7,0,0,0,0,0,0,0)_"01T"
	;
	; Default HEADING for new object only
	;
	S VO(9)=VO(9)_$S('ZNEW:"    ",'$G(FORMHDG):"    ",1:$P(pr,",",9))
	Q
	;
VDA	; Print the data
	;
	N PX,PY,X
	;
	S PX=POSX+6,PY=TOPY
	;
	S VO(10)=$$BYTECHAR^SQLUTL(PY)_$$BYTECHAR^SQLUTL(PX)_$C(26,0,0,0,0,0,0,0)_"01T"_$P(DQP,dl,1)
	S VO(11)=$$BYTECHAR^SQLUTL(PY+1)_$$BYTECHAR^SQLUTL(PX)_$C(1,0,0,0,0,0,0,0)_"01L"_$$YN($P(DQP,dl,8))
	S VO(12)=$$BYTECHAR^SQLUTL(PY+1)_$$BYTECHAR^SQLUTL(PX+24)_$C(1,0,0,0,0,0,0,0)_"00L"_$$YN($P(DQP,dl,7))
	S VO(13)=$$BYTECHAR^SQLUTL(PY+2)_$$BYTECHAR^SQLUTL(PX)_$C(12,0,0,0,0,0,0,0)_"01T"_$P(DQP,dl,18)
	S VO(14)=$$BYTECHAR^SQLUTL(PY+2)_$$BYTECHAR^SQLUTL(PX+24)_$C(3,0,0,0,0,0,0,0)_"01N"_$P(DQP,dl,3)
	S VO(15)=$$BYTECHAR^SQLUTL(PY+3)_$$BYTECHAR^SQLUTL(PX)_$C(1,0,0,0,0,0,0,0)_"01L"_$$YN(EDI(1))
	S VO(16)=$$BYTECHAR^SQLUTL(PY+3)_$$BYTECHAR^SQLUTL(PX+24)_$C(1,0,0,0,0,0,0,0)_"01L"_$$YN(EDI(2))
	S VO(17)=$$BYTECHAR^SQLUTL(PY+4)_$$BYTECHAR^SQLUTL(PX)_$C(14,0,0,0,0,0,0,0)_"01T"_$P(DQP,dl,2)
	I 'ZNEW!'$G(FORMHDG) S $P(VO,"|",1)=17
	E  S VO(18)=$$BYTECHAR^SQLUTL(PY+4)_$$BYTECHAR^SQLUTL(PX+24)_$C(1,0,0,0,0,0,0,0)_"01L"_$$YN($G(EDI(3)))
	;
	I FILES="" Q
	;
	; ============ Displsy current Access files
	;
	W BTMPAG,FILES
	Q
	;
VW	D PUTRGN^FORMFUN(10_";"_LFTMAR,(BOTMAR-10)_";"_NUMCOL,1)
	;
	D VREPAINT Q
	;
VBX	D BOX^%TRMVT(ORIGIN,EXTANT) Q
VREPAINT	D CLRRGN^FORMFUN,VBX,VDA,^DBSPNT() Q
VREPRNT	D VPR,VDA,^DBSPNT() Q  ; CTRL/W
	;
CUR(Y,X)	Q CSI_Y_";"_X_"H" ; Cursor address
	;
VTAB	; Build the %TAB(array)
	;
	N PX,PY
	;
	S zlen=132
	S PX=POSX+5,PY=TOPY-1
	;
	K REQ,UX,%TAB,%MOD S %MAX=9,OLNTB=24001,PGM=$T(+0),%VERSN=4
	;
	S DLIB="SYSDEV",DFID="DBTBL2D",VFSN("DBTBL2D")="DQP"
	;
	S %TAB(1)=$$BYTECHAR^SQLUTL(PY)_$$BYTECHAR^SQLUTL(PX)_$C(26)_"01U00001|*DQP|[]NAME|||D DINAM^FORMVAR1|D DINAMPRE^FORMVAR1"
	S %TAB(2)=$$BYTECHAR^SQLUTL(PY+1)_$$BYTECHAR^SQLUTL(PX)_$C(1)_"00L00008|*DQP|[]PROT|||D PROT^FORMVAR1"
	S %TAB(3)=$$BYTECHAR^SQLUTL(PY+1)_$$BYTECHAR^SQLUTL(PX+24)_$C(1)_"00L00007|*DQP|[]REQD|||D REQD^FORMVAR1"
	S %TAB(4)=$$BYTECHAR^SQLUTL(PY+2)_$$BYTECHAR^SQLUTL(PX)_$C(12)_"01T00018|*DQP|[]DISP|||D PFMT^FORMVAR1|D PREFMT^FORMVAR1"
	S %TAB(5)=$$BYTECHAR^SQLUTL(PY+2)_$$BYTECHAR^SQLUTL(PX+24)_$C(3)_"01N00003|*DQP|[]LGTH|||D LGTH^FORMVAR1||0|<<zlen>>" I $P(DQP,dl,3)="" S REQ(3)=""
	S %TAB(6)=$$BYTECHAR^SQLUTL(PY+3)_$$BYTECHAR^SQLUTL(PX)_$C(1)_"00L|*EDI(1)|[]PRE"
	S %TAB(7)=$$BYTECHAR^SQLUTL(PY+3)_$$BYTECHAR^SQLUTL(PX+24)_$C(1)_"00L|*EDI(2)|[]POST|||I $E(DQP)=""["" S NI=NI+1"
	S %TAB(8)=$$BYTECHAR^SQLUTL(PY+4)_$$BYTECHAR^SQLUTL(PX)_$C(14)_"00U00002|*DQP|[]TAG|||D TAG^FORMVAR1"
	S %TAB(9)=$$BYTECHAR^SQLUTL(PY+4)_$$BYTECHAR^SQLUTL(PX+24)_$C(1)_"00L|*EDI(3)|[]HDR"
	;
	S UX=1
	;
	; In MODIFY mode ... skip HEADING option
	;
	I $P(DQP,dl,1)'="" DO
	.	N Z,DI,FID,LIB
	.	K %TAB(1),%TAB(9) S EDI(3)=0 ;		Data Item,HDR option
	.	S Z=$P(DQP,dl,1),DI=$P(Z,"]",2),FID=$E($P(Z,"]",1),2,999)
	.	I DI="" Q
	.	S LIB=%LIBS,LIB=$$IMPLIT(LIB,FID)
	.	I $P($G(^DBTBL(LIB,1,FID,9,DI)),"|",16)'="" K %TAB(2) ;Computed
	.	;;I $P(^(DI),"|",1)?1N.N1"*" K %TAB(2) ; Unprotect access key *** 06/06/94 BC
	.	I '$D(%TAB(2)) S $P(DQP,dl,8)=1 ;	Protect flag
	;
	I '$G(FORMHDG) K %TAB(9)
	;
	; <<VAR> or <<%VAR>> or <<VAR(n)>>
	;
	S Z=$P(DQP,dl,1)
	I Z="" G VTAB1
	I (Z?1"<<"1A.AN1">>")!($E(DQP)="[")!(Z?1"<<"1A.AN1"("1E.E1")>>")!(Z?1"<<%"1A.AN1">>")
	E  K %TAB(2),%TAB(3)
	I Z="<<CONAM>>"!(Z?1"<<V"1E.E) K %TAB(2),%TAB(3)
VTAB1	;
	D ^DBSCRT8
	I status D ON^FORMSTAT
	S ZB=13
	Q
DINAMPRE	;
	;
	S I(3)="@SELDI^DBSFUN(FILES,.X)"
	Q
DINAM	; Check for valid data item syntax
	;
	I X'="",X'["[",$G(zztblfid)'="" S X="["_zztblfid_"]"_X
	S I(3)=""
	S ZVAR=0,UX=1
	S X=$$^FORMDIPP(X,FILES)
	;
	I %fkey="SEL"!(%fkey="FND") D VW
	S ZB=""
	I X="" Q
	I X?1"[".E1"]".E D DIREF Q
	; 
	S ER=1,RM="Invalid data item or variable name"
	Q
	;
MUMPS	;
	;
	N OP
	S X=""
	S OP(1)="Other"
	S OP(2)="User_ID|%UID|T12"
	S OP(3)="User_Name|$P(^SCAU(1,%UID),%,1)|T20"
	S OP(4)="Date|$$DAT^%ZM(+$H)|T10"
	S OP(5)="Time|$$TIM^%ZM|T8"		; 02/23/99
	S OP(6)="Screen_ID|VSID|T12"
	S OP(7)="Screen_Name|VSNAME|T30"
	S OP(8)="Inst_Name|CONAM|T30"
	I $G(RHTMAR)>80 S OP(9)="Banner|$$BANNER^UTLREAD($G(%FN),132)|T132|1"
	E  S OP(9)="Banner|$$BANNER^UTLREAD($G(%FN))|T80|1"	; 05/26/93 BC
	; 
	S OP(10)="Func_Desc|$P(^SCATBL(1,%FN),%,1)|T40"
	;
	; Other,User_ID,User_Name,Date,Time,Screen_ID,Screen_Name,Inst_Name,Banner,Func_Desc
	;
	S OP=$$^DBSMBAR(101) I 'OP Q	; *** - BC - menu option 101 - 10/25/93
	I OP=1 G MUMPS1 
	S X=$P(OP(OP),"|",2) 				; Variable/Function
	S $P(DQP,dl,18)=$E($P(OP(OP),"|",3)) 		; Format Type
	S $P(DQP,dl,3)=$E($P(OP(OP),"|",3),2,4)+0 	; Field Size
	S vudh=$P(OP(OP),"|",4)				; Display Attributes
	G DIVAR 
	Q
MUMPS1	;
	S ZVAR=1
	W BTMPAG S X=$$^FORMREAD("",10,"Variable: ","T",1)
	I X="" Q
	I X?1A.AN,$L(X)<9 G DIVAR
	I X?1"%".AN,$L(X)<9 G DIVAR
	I X?1A.AN1"("1E.E1")" G DIVAR
	W $$MSG^FORM("Invalid variable name syntax",1) G MUMPS1	; *** BC - 11/02/93
	Q
EXPRESS	;
	S ZVAR=2
	W BTMPAG S X=$$^FORMREAD("",80,"Expression: ","T",1)
	Q:X=""
	I X="?" Q
	G DIVAR
	;
DIVAR	;
	I $E(X,1,2)'="<<" S X="<<"_X
	I X'?3E.E1">>" S X=X_">>"
	;
	N Y
	S Y=$TR(X,"<>","")
	;
	; User Defined MUMPS code ... Change PROT to yes
	;
	S $P(DQP,dl,8)=1
DIVAR1	;
	;
	; New data item
	;
	I $P(DQP,dl,18)="" S $P(DQP,dl,18)="T" ; Display
	I $P(DQP,dl,3)="" S $P(DQP,dl,3)=20 ;  Length
	I $P(DQP,dl,5)="" S $P(DQP,dl,5)="T" ;  Data type
	S $P(DQP,dl,1)=X
	Q
	;
DIREF	; Build a data item reference
	;
	S ER=0
	D  I ER S RM="Duplicate name - "_X Q
	.	N DX,DY
	.	S DX="",DY="" F  S DX=$O(D(DX)) Q:DX=""  F  S DY=$O(D(DX,DY)) Q:DY=""  D
	..		I $P(D(DX,DY),$C(0),1)=X S ER=1 Q
	S DI=$P(X,"]",2),FID=$E($P(X,"]",1),2,999)
	S LIB=$P(FID,",",1),FID=$P(FID,",",2)
	I FID="" S FID=LIB,LIB=$$LIBRARY^FORMVAR
	S LIB=$$IMPLIT(LIB,FID),NEWFID=FID
	;
	I $F((","_FILES_","),(","_FID_","))=0 S FILES=$$FILES(FILES,FID) I ER Q
	;
	I LIB=""!(FID="")!(DI="") S ER=1,RM="Invalid data item syntax "_X Q
	I '$D(^DBTBL(LIB,1,FID,9,DI)) S ER=1,RM="Invalid reference "_X Q
	;
	I $P(DQP,dl,1)'=X S DQP=$$DIREFDFT(^(DI))
	I $G(PROT) S NI=NI+1
	I $P(DQP,dl,3) K REQ(3)
	S TABLE=$P(DQP,dl,6)'=""
	S PTRN=$P(DQP,dl,9)'=""
	I $P(DQP,dl,19) S $P(DQP,dl,3)=$P(DQP,dl,19)	; *** - BC - Display Size 10/19/93
	Q
	;
DIREFDFT(P)	; Load attributes from the DD
	;
	; NOTE:  A version of this section has been moved to FORMDQ2C.PROC
	;	 in PSL.  When this routine is rewritten to PSL, reconsolidate
	;	 the code.
	;
	N Z,Z1,Z2,Z3					; *** 06/16/95 	BC
	;
	F I=1:1:21 S P(I)=$P(P,"|",I)
	;
	S PROT=0 I (P(1)=""&(P(16)'=""))!($E(P(1))="[") S PROT=1 ; 06/06/94 BC
	;
	S RM(1)=$$YN(PROT)_"|2"				; Protect flag
	I P(1)["*" S RM(1)=$$YN(1)_"|2"			; Access key
	S RM(2)=$$YN(P(15))_"|3"			; Required flag *** BC - Logical edit mask
	S RM(3)=P(9)_$J("",12)_"|4"			; Display format
	I P(19) S P(2)=P(19)				; *** - BC - 10/19/93
	S RM(4)=P(2)_"|5" ; Length
	;
	I P(8)'="" S EDI(1)=1,RM(5)=$$YN(1)_"|6" ; Pre-proc *** BC - Logical edit mask
	I  S Z3=$O(PP(""),-1)+1,PP(Z3,1)=" "_P(8)		;11/13/97 MAS
	E  S RM(5)=$$YN(0)_"|6"				; *** - BC - Logical edit mask
	;
	I P(7)'="" S EDI(2)=1,RM(6)=$$YN(1)_"|7" ; Post proc *** BC - Logical edit mask
	;
	I  S Z1=$O(PP(""),-1)+1,PP(Z1,1)=" "_P(7)
	E  S RM(6)=$$YN(0)_"|7" ; Post processor *** - BC - Logical edit mask
	;
	S RM(7)=$P(P,"|",10) ; Description
	;
	S Z2=PROT I P(1)["*" S Z2=1			; Protect access keys 06/16/95 BC
	S Z=X_dl_P(9)_dl_P(2)_dl_P(14)_dl_P(9)_dl_P(5)_dl_dl_Z2_dl_P(6)_dl_P(12)_dl_P(13)
	S $P(Z,dl,7)=P(15),$P(Z,dl,18)=P(9)
	I P(7)'="" S $P(Z,dl,14)=Z1
	I P(8)'="" S $P(Z,dl,13)=Z3					;11/13/97 MAS
	I P(21)'="" S $P(Z,dl,17)=P(21),$P(Z,dl,16)=P(20)
	;
	S $P(Z,dl,19)=P(19)		; *** - BC - Display size 10/19/93
	Q Z
	;
	;
FILES(FILIST,FID)	; Add FID to FILIST after checking relationship
	;
	N (vtblrtn,%LIBS,ER,FILIST,FID,RM)
	;
	S FILES=FID I FILIST'="" S FILES=FILIST_","_FID
	D ^DBSFVER
	I 'ER Q FILES
	;
	Q FILIST
	;
PREFMT	; Pre-processor for display format   	 *** 06/28/95 BC
	;
	I '$P(DQP,dl,8) S I(3)="[DBCTLDVFM]" Q  ; Not protected
	S I(3)="^DBCTL(""SYS"",""RFMT"","	; *** 
	Q
PFMT	; Post processor for print format
	;
	I "!?"[X Q
	I X["ML"!(X["MS")!(X["DL")!(X["DS") S I(3)="" Q
	S (I,RM)="" D CHK Q:ER
	S RM=$E(RM,3,80),I(3)=""
	I "E$"[X S $P(DQP,dl,4)=2,$P(DQP,dl,5)="$" ; Display Type
	Q
	;
CHK	;
	;
	S I=I+1 I $P(X,",",I)="" Q
	S X(I)=$P(X,",",I)
	I X(I)?1"@"1E.E S X(I)=$E(X(I),2,99) ; ACCUMULATION TYPE
	;
	I $E(X(I),1,2)="RD" S RM=RM_", round decimal "_$E(X(I),3,99) G CHK
	I $E(X(I),1,2)="EM" S RM=RM_", format mask "_$E(X(I),3,99),I=999 G CHK
	I $E(X(I),1,2)="IN"!($E(X(I),1,2)="ID")!(X(I)?1"I$".N) S RM=RM_" , fixed length field" G CHK
	;
	I X(I)="F" Q				; *** 06/28/95 BC
	I '$D(^DBCTL("SYS","RFMT",X(I))) S ER=1,RM="Invalid print option "_X(I) Q
	S RM=RM_", "_$P(^DBCTL("SYS","RFMT",X(I)),"|",1) G CHK
	Q
	;
PROT	; Protect field Post-processor
	;
	S zlen=132
	I $P(DQP,dl,1)'?1"["1E.E1"]"1E.E Q
	;
	S zlen=$$LEN^DBSDD($P(DQP,dl,1))
	I V=1,X=0
	E  Q
	;
	; PROT flag changed from Yes to No ... Defualt TYPE & SIZE
	;
	N DI,FID,LIB,TYPE,LEN,Z
	;
	S Z=$P(DQP,dl,1),DI=$P(Z,"]",2),FID=$E($P(Z,"]",1),2,999)
	S LIB=%LIBS,LIB=$$IMPLIT(LIB,FID)
	S Z=$G(^DBTBL(LIB,1,FID,9,DI)),LEN=$P(Z,"|",2),TYPE=$P(Z,"|",9)
	S RM(1)=TYPE_$J("",11)_"|4" ; *** RM(2)=LEN_"|5"
	S $P(DQP,dl,18)=TYPE ; *** ,$P(DQP,dl,3)=LEN
	S X=0
	S zlen=LEN
	Q
REQD	;
	S UX=1
	I $E(DQP)'="[" Q
	I $P(DQP,dl,8) Q  		; Protected
	S NI=NI+1 			; *** - BC - Skip TYPE field 10/19/93
	Q
	;
LGTH	;
	;
	; protected ?
	;
	I '$P(DQP,dl,8) Q
	;
	; Remove pre/post processor flags
	;
	S PRE=0,POST=0,EDI(1)=0,EDI(2)=0
	S RM(1)=$$YN(0)_"|6",RM(2)=$$YN(0)_"|7"		; *** BC - Edit mask
	;
	; Skip PRE/POST processor
	;
	S NI=NI+2
	;
	; Skip TAG if [fid]di syntax
	;
	I $E(DQP)="[" S NI=NI+1
	Q
TAG	;
	;
	I $E(DQP)="[" S X="",$P(DQP,dl,2)="" Q
	I X="" Q
	I $E(X)'="@" S X="@"_X
	Q
	;
IMPLIT(LIB,FID)	;
	;
	N Z,X
	I FID="" Q LIB
	S Z=LIB,X=$P($G(^DBTBL(LIB,1,FID,10)),"|",5)
	I X'="" S Z=$E($P(X,",",1),2,99)
	Q Z
	;
DECSED()	Q CSI_"?2J"
YN(X)	Q $$LOG^%ZM(X,%MSKL)
