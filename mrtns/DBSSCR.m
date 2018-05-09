DBSSCR(SID,NOLINK)	; V 5.0 - Screen Compiler
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/07/02 14:37:25 - CHENARDP
	;     ORIG: Frank R. Sanchez (2497)
	;
	; DESC:  Compile screen into run-time routine
	;
	; KEYWORDS: SCREEN,COMPILER
	;
	; ARGUMENTS:
	;	. SID	  Screen Name			/TYP=T/REQ/MECH=VAL
	;	. NOLINK  Don't link run-time image	/TYP/L/DEF=0/NOREQ
	;                                               /MECH=MECH=VAL
	; INPUTS:
	;	. %LIBS   Library name			/TYP=T/REQ
	;
	; I18N=QUIT: Exculded from I18N standards. 
	;---------- Revision History -------------------------------------------
	; 02/14/06 - RussellDS - CR19065
	;	     Removed reference to obsolete routine DBSFRM.
	;
	; 09/28/04 - RussellDS - CR12334
	;	     Replaced obsoleted calls to ^DBSANS1 with new procedure
	;	     DBSGETID.
	;
	;	     Added %DB to exclusive new list to prevent problems
	;	     compiling in Oracle environment.
	;
	; 01/07/02   Pete Chenard 51138
	;            Implemented the fix from Bob from 7/8/98.  This fix is
	;   	     being brought back from v6.1 to v5.3
	;
	; 07/08/98   Bob Chiang - 29252
	;            Modified VDA2 section to include data item protection logic
	;            in the run-time routine for the first data item defined on
	;            the screen.
	;
	; 11/11/96   Bob Chiang - 20948
	;            Modified to remove references to [DBTBL1D]%NOREST
	;            (Maintenance restriction flag).  Filer triggers now
	;            manage the field maintenance restriction logic.
	;
	; 10/23/96   Bob Chiang - 20948
	;            Modified COMPILE section to get field delimiter information
	;	     from the file attribute.
	;-----------------------------------------------------------------------
	N (%DB,%LIBS,PGM,SID,%UID,ZREPEAT,NOLINK,%MSKC)
	;
	S NOLINK=$G(NOLINK)
	;
	I '$D(%LIBS) S %LIBS=$$^CUVAR("%LIBS")
	I '$D(SID) S SID=$$FIND^DBSGETID("DBTBL2",0)
	;
	;----------------------------------------------------------------------
	; Which compiler to use?
	;----------------------------------------------------------------------
	;
	K ^TMP($J)
	;
	; Linked screen ?
	;
	I $D(^DBTBL(%LIBS,2,SID,-1)) D ^DBSDSMP Q
	;
	D ^DBSSCR0
	;
	S LOOP="NOLOOP"
	;
	I SCRCLR=1 S X=""
	E  I SCRCLR=0 S X=VPT ; first line number
	E  I SCRCLR=2 S X=VPT_":"_VPB ; top : last
	;
	D TMPC(" S VO(0)="""_X_"|"_$P(STS,"|",6)_"""")
	;
SEQ	;
	S SEQ=$O(DT(SEQ)) I SEQ="" G END
	;
	S X=DT(SEQ),secret=0
	;
	S PRO=0 I $P(X,"|",1)["*"!($P(X,"|",2)?1N1"*") S PRO=1 ; Protect flag
	I 'PRO,$P(X,"|",17)'="" S PRO=2			; Computed operation
	S P(1)=$P(X,"|",1) ; Y*1000+X & Protect_flag & (# or {) & Video_display
	S P(2)=$P(X,"|",18)				; Print edit
	I P(2)="" S P(2)=$P(X,"|",10)
	S P(3)=$P(X,"|",3)				; Field Length
	S P(4)=$P(X,"|",4)				; Default
	S P(5)=$P(X,"|",5)				; [LIB,FID]DI or VAR
	S P(6)=$P(X,"|",6)				; Table lookup
	S P(7)=$P(X,"|",7)				; Pattern match
	S P(10)=$P(X,"|",10)				; Data type
	S P(11)=$P(X,"|",11)				; Prompt
	I P(11)["""",P(11)'?.E1"<<"1E.E1">>".E S P(11)=$$DBLQ(P(11))
	S P(12)=$P(X,"|",12)				; Required flag
	S P(13)=$P(X,"|",13)				; Minimum value
	S P(14)=$P(X,"|",14)				; Maximum value
	S P(15)=$P(X,"|",15)				; Decimal precision
	S P(18)=""	 				; Subfield Logic
	S P(19)=""
	;
	I P(5)["[" D
	.	S P(19)=$$LEN^DBSDD(P(5))		; Internal Length *** - BC - 10/19/93
	.	S $P(X,"|",22)=$$POS^DBSDD(P(5))	; *** 11/11/96 delimeter
	.	I $P(X,"|",22) S $P(X,"|",21)=124	; *** position
	;
	I P(19)="" S P(19)=P(3)				; Default to Display Size *** - BC - 10/19/93
	S P(21)=$P(X,"|",21)				; Field delimeter
	S P(22)=$P(X,"|",22)				; Column Position
	S P(30)=$P(X,"|",30)				; Orig DINAM
	;						; *** 03/15/96
	I P(30)?1"@["1A.AN1"]"1A.AN D			; Help file syntax @[fid]di
	.	S Z=$$LEN^DBSDD($E(P(30),2,99))		; Use DD internal field length
	.	I $G(ER) S ER=0,RM=""			; If invalid, reset error flag
	.	E  I Z>P(19) S P(19)=Z			; Internal length (overflow)
	;
	I P(10)="T",P(2)'=P(10),P(11)'?1"["1A.AN1"]"1E.E S P(10)=P(2)
	S P(8)=$O(^DBTBL(%LIBS,2,SID,SEQ,20)) I P(8)>40 S P(8)=0 ; POST
	S P(9)=$O(^DBTBL(%LIBS,2,SID,SEQ,0.99)) I P(9)>20 S P(9)=0 ; PRE
	;
	S DINAM=P(5)
	I DINAM="",((P(11)?1"<<"1A.AN1">>")!(P(11)?1"<<%"1A.AN1">>")) S DINAM=P(11)
	;
	; Data field defaults to HIGHLIGHT mode
	;
	I P(1)'["{" S VPRGI=0,VPRV1=$$VIDEO($P(P(1),"#",2)),VDAV1=2
	E  S VPRV1=$$VIDEO($P(P(1),"{",2)),VDAV1=VPRV1,VPRGI=1
	I $P(STS,"|",17) S VDAV1=VPRV1 ; OOE option
	;
	S OLNTB=+P(1),CY=P(1)\1000,CX=P(1)#1000
	;
	; ---------- Calculate maximum right margin for this field
	;
	S MARGIN=$G(DT(SEQ+1))
	I MARGIN\1000'=CY S MARGIN=$S($P(STS,"|",6):132,1:80) ; last object
	E  S MARGIN=MARGIN#1000 ; Up to the next object on the same line	
	;
	S NODE=""
	;
	I $E(DINAM)?1A!($E(DINAM)="%") S NODE="*"_DINAM,NS=$$NS(DINAM),KVAR=$$KVAR(KVAR,DINAM,.VARLIST)
	I DINAM'="" D VDA
	I P(11)'="" D VPR
	;
	I %LOOP,CY'<%LOOP,$E(NODE)="*" S NODE=NODE_"(1)"
	;
	I DINAM'="" D VTAB
	G SEQ
	;
VDA	; Build the data section (VDA) of the program
	;
	S PF="",L=$L(P(11)),VDACX=CX+L ; Cursor position for data
	F L=L:-1:0 Q:$E(P(11),L)'=" "  S P(11)=$E(P(11),1,L-1)
	;
	S DI=$P(DINAM,"]",2) I DI="" S DI=DINAM,FID=""
	E  D COMPILE(DINAM)
	I $G(NS)="" W $$^MSG(1300,DINAM) Q	; *** BC - Error Message 10/07/93
	;
	I %LOOP,CY'<%LOOP S NS=$$RPTFLD(NS)	; Build repeat field logic
	S NS=$$DGET^DBSSCR1(NS)			; Find variables
	;
	I 'P(3) G VDA2 				; No length check
	;
	D EDIT
	;
	; ---------- Pad field with blanks (reverse image mode)
	;
	I VDAV1#2 S PF="$$VRV("_$S(PF="":NS,1:PF)_","_+P(3)_")"
	;
VDA2	;
	;
	S REF=NS
	;
	I PF="" S PF=REF
	I $P(PF,REF,2,99)[REF,REF["," S PF=$$REPLACE(PF,REF,"V"),REF=" S V="_REF
	E  S REF=""
	;
	I secret S REF=" S V=""""",PF=$C(34,34)
	;
	S len=+P(3)
	;
	; ---------- Check field screen margin overflow condition
	;
	I len,(len+VDACX-1>MARGIN) S len=MARGIN-VDACX+1 ; Display size *** - BC - 10/21/93
	;
	; ========== .DEFAULT. macro command on this data item ?
	;
	S VDAV2=0,zDFT=0
	;
	s zt=P(10) I PRO,P(2)'="",P(2)'=P(10) S zt="T" ; display format
	;
	S HEADER=$$HEADER(CY,VDACX,len,VDAV1,VDAV2,PRO,VDAGI,zt,zDFT)
	;
	I FID=""!'%FLGPROT
	E  D PROTECT ; Build data item protection if necessary
	;
	I %LOOP,CY<%LOOP=0,'$D(RPTDA) D RPTDA ; Repeating data subroutine
	;
	I '$D(RPTCNT) S RPTCNT=0
	;
	I %LOOP S RPTCNT=RPTCNT+1 I CY'<%LOOP S X=" S VO(VX+"_(RPTCNT-1)_")="
	E  S X=" S VO(@)="
	S XVO=$E($P(X,"=",1),4,99)
	D TMPD(REF_X_HEADER_"""_"_PF)
	;
	; Check data item maintenance restrict flag
	;
	I '$D(DI) Q
	I DINAM="" Q
	I $E($P(DINAM,"]",1),2,99)="" Q		; *** 07/08/98
	;
	D PROT^DBSSCR0
	Q
TMPT(X)	D ERROR("Unimplemented-W-Index function not implemented "_P(16)) Q
TMPC(X)	S C=C+1,TMPC(C)=X Q
TMPD(X)	S D=D+1,TMPD(D)=X Q
	;
EDIT	; Build Display Format P(2)=FMT P(3)=SIZE P(15)=PRECISION
	;
	N fmt					; *** BC - 03/31/94 - Defaults
	S fmt=P(2)				; *** to E format if display
	I $P(STS,"|",18),fmt="$" S fmt="E"	; *** option defined
	S PF=$$fmt^DBSEXEP(fmt,NS,P(3),P(15)) 	; 
	I $E(PF,1,3)="$E(" s PF=$E($P(PF,",",1,$L(PF,",")-2),4,999)     ; FRS 
	Q
	;
PROTECT	; Build display protection logic
	;
	D ^DBSPROT4(FID,DI,.VP,P(10),SAVT+1)
	Q
	;
VPR	; Build the prompt (VPR) section of the program
	;
	I P(11)[$C(128) S P(11)=$TR(P(11),$C(128),$C(124))
	I P(11)?.E1"<<"1E.E1">>".E S P11=P(11) D VARSUB^DBSSCR1 S NS=$$NS(NS) D VPR1 D EDIT:P(3)>0 G VDA2
	;
	S HEADER=$$HEADER(CY,CX,$L(P(11)),VPRV1,VPRV2,VPRPRO,VPRGI,"T")
	;
	I %LOOP,(CY'<%LOOP) D RPTPR Q
	S VPROBJ=VPROBJ+1
	;
	S X=" S VO("_VPROBJ_")="_HEADER_P(11)_""""
	D TMPC(X) Q
VPR1	;
	I '%LOOP Q
	I CY<%LOOP Q
	;
	; Repeat Region
	;
	N Z
	S Z=$P(P11,"<<",2),Z=$P(Z,">>",1)
	I '((Z?1A.AN)!(Z?1"%".AN)) Q
	S NS=$P(NS,Z,1)_Z_"(I)"_$P(NS,Z,2,99)
	Q
	;
HEADER(DY,DX,LEN,VID1,VID2,PRO,GI,TYP,zDFT)	; Create object header
	;
	N X
	S zDFT=$G(zDFT)
	I %LOOP,DY'<%LOOP S DY=$S(DY=%LOOP:"DY",1:"DY+"_(DY-%LOOP))
	I $P(VID2,",",6)="" S VID2="0,0,0,0,0,0"
	S X="$C("_DY_","_+DX_","_+LEN_","_VID1_","_VID2_")_"
	;
	I $L(TYP)>1 S TYP="T"				; JRC 14070
	I zDFT S X=X_""""_GI_9_TYP
	E  S X=X_""""_GI_PRO_TYP
	Q X
	;
	;
VTAB	; Build the table section VTAB of the program
	;
	I $G(LIB)'="",$G(FID)'="" S P(16)=$$REQ^DBSDD(FID_"."_DI,"",.vdd)
	;
	I PRO S secret=2
	;
	I P(12)=1,P(10)="L" S P(12)=0 ; Not required for logical data types
	;;I P(6)'="","@^["'[$E(P(6)) S P(6)="^DBCTL(%LIBS,"""_P(6)_""","
	I P(6)'="",P(6)?1A.AN S P(6)="^DBCTL(%LIBS,"""_P(6)_""","
	I P(7)'="" S P(7)="I "_P(7)
	;
	S VDACX=VDACX-1,SAVT=SAVT+1
	I CY'<%LOOP S %MOD=%MOD+1
	E  S %OFF=%OFF+1
	S DX=VDACX
	;
	; @[FID]DI syntax  ... COPY FILE ID FROM [...]
	;
	I FID="" DO
	.I $G(P(30))?1"@["1E.E1"]"1E.E S DINAM="["_$E($P(P(30),"]",1),3,99)_"]"_DINAM
	.E  S DINAM="[*]"_DINAM ; Variable name syntax for I(1)
	.I $G(P(30))?1"@"1E.E S DINAM="[*]"_P(30)
	;
	E  S DINAM="["_FID_"]"_DI
	;
	S PRMBL="$C("_(CY-1)_","_DX_","_len_")_"""_secret_+P(12)_P(10)
	S BLKSIZ=BLKSIZ+P(3)
	I P(21) S PRMBL=PRMBL_$E(1000+P(21),2,4)_$E(100+P(22),2,3)
	;
	S X=$S(P(30)'="":P(30),1:P(5))
	I X?1"[".E1",".E1"]".E S X="["_$P(X,",",2)
	;
	S %NAMCUR(X)=%NAMCUR(X)_"|"_SAVT ; %TAB SEQUENCE
	;
	I FID'="" D
	.	S z=fsn(FID),gbl=$P(z,"|",2),rectyp=$P(z,"|",4)
	.	S bkey=$P($P(gbl,"(",2),",",$L(gbl,","))
	.	I rectyp=1,$P(z,"|",1)[")" S NODE="",bkey=""
	;
	E  I "*"[FID S bkey=""
	;
	I 'P(8) S P(8)=""
	I 'P(9) S P(9)=""
	;
	I P(8) S POPT="PO",PP=21 D PP^DBSSCR1 S P(8)=PP ; Post processor
	I P(9) S POPT="PR",PP=1 D PP^DBSSCR1 S P(9)=PP ; Pre processor
	;
	S $P(P,"|",1)=PRMBL ; CYXXRLLTDELPP
	S $P(P,"|",2)=$S(NODE?1A.E&(NODE=bkey):"",1:NODE)
	I FID'="",DI'="",$$CMP^DBSDD(FID_"."_DI,"",.vdd)'="" S $P(P,"|",2)="*"_DI
VTAB3	;
	I NODE="",$$CMP^DBSDD(FID_"."_DI)="" S $P(P,"|",2)="*"_DI	; *** 09/01/95
	S $P(P,"|",3)=DINAM ;				[FID]DI
	S $P(P,"|",4)=$$DBLQ(P(6)) ;			Table lookup
	S $P(P,"|",5)=$$DBLQ(P(7)) ;			Pattern match
	S $P(P,"|",6)=$$DBLQ(P(8)) ;			Post processor
	S $P(P,"|",7)=$$DBLQ(P(9)) ;			Pre processor
	S $P(P,"|",8)=P(13) ;				Minimum value
	S $P(P,"|",9)=P(14) ;				Maximum value
	S $P(P,"|",10)=P(15) ;				Decimal precision
	S $P(P,"|",11)=P(18) ;				Sub-Field Definition
	I len<P(19) S $P(P,"|",12)=P(19) ;		Maximum field length
	;
	F L=$L(P):-1:0 Q:$E(P,L)'="|"  ; Strip trailing blanks
	;
	S TAB(SAVT)=" S %TAB("_SAVT_")="_$E(P,1,L)_""""
	S P=""
	;
	; *** 11/11/96 Removed [DBTBL1D]%NOREST logic
	;
	S DFID=$E($P(DINAM,"]",1),2,99)		; *** - BC - Modified to define DFID variable 09/29/93
	I $G(DFID)="" Q
	;
	; PROTECTION ON ? YES ... remove %TAB ( no pre/post processor defined )
	;
	;                         I $D(VPTBL(SEQ)) K %TAB(SEQ)
	;
	D STATUS^UPID(DFID,DI,.FLGPROT)
	Q
	;
RPTFLD(NS)	; Fix NS for repeating fields
	;
	N I,X
	;
	I '$D(RPTDA) D RPTDA
	;
	I $E(NODE)="*" S NS=$P(NODE,"*",2)_"(I)" S:P(21) NS="$P("_NS_","""_$C(P(21))_""","_P(22)_")"
	E  S NS=$$ADDSUB(NS,"I")
	Q NS
	;
ADDSUB(expr,var)	; Add subscript var to expr
	;
	I $G(var)="" S var="I"
	;
	I expr'["(" Q expr_"("_var_")"
	I expr["(1)" Q $P(expr,"(1)",1)_"("_var_")"_$P(expr,"(1)",2,99)
	I expr[(var_")") Q expr
	;
	F I=1:1:$L(expr) Q:"),"[$E(expr,I)
	I $E(expr,I)=")" Q $E(expr,1,I-1)_","_var_$E(expr,I,$L(expr))
	I $E(expr,I-1)=")" Q $E(expr,1,I-2)_","_var_$E(expr,I,$L(expr))
	Q $E(expr,1,I-1)_"("_var_")"_$E(expr,I,$L(expr))
	;
RPTDA	; Repeating data subroutine
	;
	S RPTBLK=BLKSIZ ; Set flag
	;
	D TMPD(" ; ")
	;
	I '$D(RPTCNT) S RPTCNT=0
	;
	D TMPD(" S:'$D(%MODS) %MODS=1 S VX=$P(VO,""|"",2)+"_(RPTCNT-1)_",DY="_%LOOP_" F I=%MODS:1:%REPEAT+%MODS-1 D VRDA")
	D TMPD(" S $P(VO,""|"",1)=VX Q  ; EOD pointer")
	;
	D TMPD(" ;")
	D TMPD("VRDA ; Display data %REPEAT times")
	D TMPD(" ;")
	S RPTDA=D+1,RPTCNT=1
	Q
	;
RPTPR	; Repeating prompt subroutine
	;
	I $D(RPTPR) G RPTPR1
	;
	D TMPC(" I '$D(%MODS) S %MODS=1")
	D TMPC(" S DY="_%LOOP_" F I=%MODS:1:%REPEAT+%MODS-1 D VRPR")
	;
	; *** - BC - 03/31/94 - Add currency display flag in piece 4 of VO
	;
	I $P(STS,"|",18) D TMPC(" S VO=+VO_""|""_(VO+1)_""|13|1"" Q  ; BOD pointer")
	E  D TMPC(" S VO=+VO_""|""_(VO+1)_""|13"" Q  ; BOD pointer")
	;
	D TMPC(" ;")
	D TMPC("VRPR ; Display prompts %REPEAT times")
	D TMPC(" ;")
	S RPTPR=1
RPTPR1	;
	S X=" S VO(VO+"_RPTPR_")="_HEADER_P(11)_""""
	D TMPC(X)
	S RPTPR=RPTPR+1 ; next repeating PR counter
	Q
	;
VIDEO(X)	; Build video attribute string (New structure)
	;
	S VPRGI=0,VPRV2=0,secret=0
	I X>63 S VPRV2=$P(X,",",2,99)
	I X>128 S VPRGI=1,X=X-128 ; Graphic Mode
	I X>79 S secret=1 Q X-80 ; Secret Mode
	I X>63 Q X-64
	S Z1=0
	I $F(X,2) S Z1=Z1+1
	I $F(X,1) S Z1=Z1+2
	I $F(X,3) S Z1=Z1+4
	I $F(X,4) S Z1=Z1+8
	Q Z1
	;
VARCHK(X)	; 1 if expression is a local variable, 0 if not
	;
	I X?1AN.AN Q 1
	I X?1"%".AN Q 1
	I X?1AN.AN1"(".E1")" Q 1
	I X?1"%".AN1"(".E1")" Q 1
	Q 0
	;
DBLQ(X)	; Replace " with "" and | with $C(124)
	;
	; *** BC - 12/14/93
	;
	I X[(""""_$C(128)_"""") S X=$$REPLACE(X,""""_$C(128)_"""","$C(124)")
	I X["""" S X=$$REPLACE(X,"""","""""")
	I X["|" S X=$$REPLACE(X,"|","""_$C(124)_""")
	Q X
	;
REPLACE(X,OS,NS)	; Change all occurrances of OS to NS
	;
	I $G(X)="" Q ""
	;
	S L=0
	F I=1:1 S L=$F(X,OS,L) Q:'L  S X=$E(X,1,L-$L(OS)-1)_NS_$E(X,L,9999),L=L+$L(NS)-$L(OS)
	Q X
	;
	;
NS(X)	; Build record access string for variables
	;
	I $E(X)=$C(34) Q X
	I $G(X)="" Q ""
	;
	I X?1A.AN!(X?1"%".AN)!(X?1A.AN1"("1E.E1")") S X="$G("_X_")" ; RC 2/12/93
	I $G(P(21))="" Q X
	I '$G(P(22)) S POS=1 ; Default to 1st position
	Q "$P("_X_","""_$C(P(21))_""","_P(22)_")"
	;
KVAR(KVAR,X,LIST)	; Build KVAR string for variables and save it in LIST()
	;
	S KVAR=$G(KVAR)
	S LIST(X)=""
	I ","_KVAR_","[(","_X_",")!PRO Q KVAR
	Q KVAR_","_X
	;
	;
COMPILE(DINAM)	; Substitute actual DINAM for explicit image
	;
	N X
	D PARSE^DBSDD(.DINAM,.X,.comp,.fsn,"",.vdd) Q:ER
	;
	; Patch NODE,DEL,POS,TABLE,PATTERN,MIN,MAX,DEC
	;
	S LIB=$P(DINAM,".",1),FID=$P(DINAM,".",2),DI=$P(DINAM,".",3)
	I (","_FILES_",")'[(","_FID_",") S NS="" Q	; *** BC - error 10/07/93
	;
	S NODE=$P(X,"|",1),P(18)=$P(X,"|",18)
	I NODE="",$P(X,"|",16)="" S NS=DI		; *** 09/08/95 BC
	;
	; *** 10/23/96 Get missing field delimiter from file attribute
	;
	I $P(X,"|",21),$P(X,"|",20)="" D
	.	S $P(X,"|",20)=$P(fsn(FID),"|",10)	; Get from file header
	.	S P(21)=$P(X,"|",20)			; Update screen attribute
	;
	; *** 09/01/95 BC (Added logic to also check protected data items)
	;
	F I=6,7,10,13,14,15,21,22 I P(I)'=$P(X,"|",I-1) D
	.	S z=$P("/////TABLE/PATTERN///TYPE///MIN/MAX/DECIMAL//////DEL/POS","/",I)
	.	I PRO D  Q
	..		I '((I=10)!(I=15)) Q
	..		W !,"Warning - [",$P(P(5),",",2)," mismatch on attribute ",z," screen=",P(I)," file=",$P(X,"|",I-1) Q
	.	S P(I)=$P(X,"|",I-1)
	.	W !,"Change ",P(5)," attribute ("_z_"="_P(I)_") to match file definition",!
	Q
	;
ERROR(X)	; Print errors
	;
	I ESEQ'=SEQ S ESEQ=SEQ W !,SEQ," - Col: ",CY," Row: ",CX,"  ",DINAM,!
	W X,! Q
	;
BIT(X)	; Change a number to it's binary equivalent
	;
	Q $C((128\X*128)+(64\X+64)+(32\X+32)+(16\X*16)+(8\X*8)+(4\X*4)+(2\X*2))
	;
END	; Go to build program
	;
	G ^DBSSCR1
