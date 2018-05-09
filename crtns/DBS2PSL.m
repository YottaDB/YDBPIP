DBS2PSL(SID,NOLINK)	; V 7.0 - PSL Screen Compiler
	;
	; **** Routine compiled from DATA-QWIK Procedure DBS2PSL ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	N %FLGPROT N %MOD N %NAMCUR N %OFF N bkey N BLKSIZ N cmd N cmdDel N codPtr N code N CX N CY N DBOPT N DES N DFID N di N dinam
	N DINAM N ditab N DLIB N DILIST N DT N DXESEQ N EXTSID N FA N FB N FID N file N FIND N FLGPROT N fsn N gbl N HEADER N L N len N LIB
	N LOOP N MARGIN N MPLCT N NODE N NS N OLNTB N P N PF N pfid N POPT N PP N PRMBL N PRO N rectyp N REF N RPTCNT N RPTPR
	N secret N sn N src N STS N SYS N TAB N TMP N TMPC N TMPD N TMPZ N TYP
	N USERVLOD N VDACX N VDAGI N VDAOBJ N VDAV1 N VDAV2 N vdd N VFSN N vobject N vobjlst N vobjref N VPB N VPRGI N VPROBJ N VPRPRO
	N VPRTYP N VPRV1 N VPRV2 N VPT N VSAV N VZSEQ N X N X1 N X41 N XLT N XV0 N Z N Z1 N zt
	N SEQ N seq
	;
	S NOLINK=$get(NOLINK)
	;
	; Which compiler to use - Original or extra crispy (PSL)
	N dbtbl2 S dbtbl2=$$vDb1(%LIBS,SID)
	 S vobj(dbtbl2,0)=$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0))
	 S vobj(dbtbl2,"v1")=$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),-1))
	I '$P(vobj(dbtbl2,0),$C(124),22) D ^DBSSCR(SID) K vobj(+$G(dbtbl2)) Q  ;Non-PSL compiler
	I $P(vobj(dbtbl2,"v1"),$C(124),1)'="" D ^DBSLINK(.dbtbl2) K vobj(+$G(dbtbl2)) Q  ; linked screen
	;
	D ^DBS2PSL0(.dbtbl2,.VPT,.VPB)
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	S LOOP="NOLOOP"
	I $P(vobj(dbtbl2,0),$C(124),8)=1 S X=""
	E  I $P(vobj(dbtbl2,0),$C(124),8)=0 S X=VPT ; first line number
	E  I $P(vobj(dbtbl2,0),$C(124),8)=2 S X=VPT_":"_VPB ; top : last
	D TMPC(" set VO(0)="""_X_"|"_$P(vobj(dbtbl2,0),$C(124),6)_"""")
	S %FLGPROT=$P(vobj(dbtbl2,0),$C(124),16)
	;
	S SEQ=""
	F  S SEQ=$order(DT(SEQ)) Q:SEQ=""  D SEQ(SEQ,.dbtbl2)
	D END(.dbtbl2)
	K vobj(+$G(dbtbl2)) Q 
	;
SEQ(SEQ,dbtbl2)	;
	N vobjref N X N Z
	;
	S X=DT(SEQ) S secret=0
	S PRO=0 I $piece(X,"|",1)["*"!($piece(X,"|",2)?1N1"*") S PRO=1 ; Protect flag
	I 'PRO,$piece(X,"|",17)'="" S PRO=2 ; Computed operation
	S P(1)=$piece(X,"|",1) ; Y*1000+X & Protect_flag & (# or {) & Video_display
	S P(2)=$piece(X,"|",18) ; Print edit
	I P(2)="" S P(2)=$piece(X,"|",10)
	S P(3)=$piece(X,"|",3) ; Field Length
	S P(4)=$piece(X,"|",4) ; Default
	S P(5)=$piece(X,"|",5) ; [LIB,FID]DI or VAR
	S P(6)=$piece(X,"|",6) ; Table lookup
	S P(7)=$piece(X,"|",7) ; Pattern match
	S P(10)=$piece(X,"|",10) ; Data type
	S P(11)=$piece(X,"|",11) ; Prompt
	I P(11)["""",P(11)'?.E1"<<"1E.E1">>".E S P(11)=$$DBLQ(P(11))
	S P(12)=$piece(X,"|",12) ; Required flag
	S P(13)=$piece(X,"|",13) ; Minimum value
	S P(14)=$piece(X,"|",14) ; Maximum value
	S P(15)=$piece(X,"|",15) ; Decimal precision
	S P(18)="" ; Subfield Logic
	S P(19)=""
	;
	I P(5)["[" D
	.	S P(19)=$$LEN^DBSDD(P(5),,.vdd) ; Internal Length
	.	S $piece(X,"|",22)=$$POS^DBSDD(P(5)) ; delimeter
	.	I $piece(X,"|",22) S $piece(X,"|",21)=124 ; position
	.	Q 
	;
	I P(19)="" S P(19)=P(3)
	S P(21)=$piece(X,"|",21) ; Field delimeter
	S P(22)=$piece(X,"|",22) ; Column Position
	S P(30)=$piece(X,"|",30) ; Orig DINAM
	I P(30)?1"@["1A.AN1"]"1A.AN D  ; Help file syntax @[fid]di
	.	S Z=$$LEN^DBSDD($E(P(30),2,99)) ; Use DD internal field length
	.	I $get(ER) S ER=0 S RM="" ; If invalid, reset error flag
	.	E  I Z>P(19) S P(19)=Z ; Internal length (overflow)
	.	Q 
	;
	I P(10)="T",P(2)'=P(10),P(11)'?1"["1A.AN1"]"1E.E S P(10)=P(2)
	I '$$vDbEx1() S P(8)=0 ; Post processor
	E  S P(8)=21
	I '$$vDbEx2() S P(9)=0 ; Pre Processor
	E  S P(9)=1
	;
	S DINAM=P(5)
	I DINAM="",((P(11)?1"<<"1A.AN1">>")!(P(11)?1"<<%"1A.AN1">>")) S DINAM=P(11)
	;
	; Data field defaults to HIGHLIGHT mode
	I P(1)'["{" S VPRGI=0 S VPRV1=$$VIDEO($piece(P(1),"#",2)) S VDAV1=2
	E  S VPRV1=$$VIDEO($piece(P(1),"{",2)) S VDAV1=VPRV1 S VPRGI=1
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	I $P(vobj(dbtbl2,0),$C(124),17) S VDAV1=VPRV1 ; OOE option
	S OLNTB=+P(1) S CY=P(1)\1000 S CX=P(1)#1000
	;
	; ---------- Calculate maximum right margin for this field
	S MARGIN=$get(DT(SEQ+1))
	I MARGIN\1000'=CY S MARGIN=$S($P(vobj(dbtbl2,0),$C(124),6):132,1:80) ; last object
	E  S MARGIN=MARGIN#1000 ; Up to the next object on the same line
	;
	S NODE=""
	I $E(DINAM,1)?1A!($E(DINAM,1)="%") D
	.	S NODE="*"_DINAM
	.	S NS=$$NS(DINAM)
	.	S KVAR=$$KVAR(KVAR,DINAM,.VARLIST)
	.	Q 
	;
	S vobject=""
	I DINAM'="" D VDA(.dbtbl2)
	I P(11)'="" D VPR(.dbtbl2)
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	I $P(vobj(dbtbl2,0),$C(124),7),CY'<$P(vobj(dbtbl2,0),$C(124),7),$E(NODE,1)="*" S NODE=NODE_"(1)"
	I DINAM'="" D VTAB(.dbtbl2)
	Q 
	;
VDA(dbtbl2)	; Build the data section (VDA) of the program
	N L
	; Cursor position for data
	S PF="" S L=$L(P(11)) S VDACX=CX+L
	F L=L:-1:0 Q:$E(P(11),L)'=" "  S P(11)=$E(P(11),1,L-1)
	S DI=$piece(DINAM,"]",2) I DI="" S DI=DINAM S FID=""
	E  D COMPILE(DINAM,.dbtbl2) S vobject=1
	; Invalid data item name ~ p1
	I $get(NS)="" WRITE $$^MSG(1300,DINAM) Q 
	;
	; Build repeat field logic
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	I $P(vobj(dbtbl2,0),$C(124),7),CY'<$P(vobj(dbtbl2,0),$C(124),7) S NS=$$RPTFLD(NS,.dbtbl2)
	; Find variables
	S NS=$$DGET^DBS2PSL1(NS,.dbtbl2)
	I 'P(3) D VDA2(.dbtbl2) Q  ; No length check
	D EDIT(.dbtbl2)
	;
	; ---------- Pad field with blanks (reverse image mode)
	I VDAV1#2 S PF="$$VRV("_$S(PF="":NS,1:PF)_","_+P(3)_")"
	D VDA2(.dbtbl2)
	Q 
	;
VDA2(dbtbl2)	;
	N X N zDFT N zt
	S REF=NS
	I PF="" S PF=REF
	I $piece(PF,REF,2,99)[REF,REF["," S PF=$$REPLACE(PF,REF,"V") S REF=" set V="_$S(vobject:vobjref,1:REF)
	E  S REF=""
	I secret S REF=" set V=""""" S PF=""""""
	S len=+P(3)
	;
	; ---------- Check field screen margin overflow condition
	I len,(len+VDACX-1>MARGIN) S len=MARGIN-VDACX+1
	;
	; ========== .DEFAULT. macro command on this data item
	S VDAV2=0 S zDFT=0
	;
	; display format
	S zt=P(10) I PRO,P(2)'="",P(2)'=P(10) S zt="T"
	S HEADER=$$HEADER(CY,VDACX,len,VDAV1,0,PRO,VDAGI,zt,0,.dbtbl2)
	;
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	I '(FID=""!'$P(vobj(dbtbl2,0),$C(124),16)) D PROTECT ; Build data item protection if necessary
	; Repeating data subroutine
	I $P(vobj(dbtbl2,0),$C(124),7),CY<$P(vobj(dbtbl2,0),$C(124),7)=0,'($D(RPTDA)#2) D RPTDA(.dbtbl2)
	I '($D(RPTCNT)#2) S RPTCNT=0
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	I $P(vobj(dbtbl2,0),$C(124),7) S RPTCNT=RPTCNT+1 I CY'<$P(vobj(dbtbl2,0),$C(124),7) S X=" set VO(VX+"_(RPTCNT-1)_")="
	E  S X=" set VO(@)="
	S XVO=$E(($piece(X,"=",1)),4,99)
	I $get(vobject)="" D
	.	D TMPD(REF_X_HEADER_"""_"_PF)
	.	Q 
	E  D TMPD(REF_X_HEADER_"""_"_$S(secret:$get(PF),1:$get(vobjref)))
	;
	; Check data item maintenance restrict flag
	I '($D(DI)#2) Q 
	I DINAM="" Q 
	I $E(($piece(DINAM,"]",1)),2,99)="" Q 
	D PROT^DBS2PSL0
	Q 
	;
TMPT(X)	;
	D ERROR("Unimplemented-W-Index function not implemented "_P(16))
	Q 
	;
TMPC(X)	;
	S C=C+1
	S TMPC(C)=X
	Q 
	;
TMPD(X)	;
	S D=D+1
	S TMPD(D)=X
	Q 
	;
EDIT(dbtbl2)	; Build Display Format P(2)=FMT P(3)=SIZE P(15)=PRECISION
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	Q:'P(3) 
	N fmt
	; *** to E format if display
	S fmt=P(2)
	; *** option defined
	I $P(vobj(dbtbl2,0),$C(124),18),fmt="$" S fmt="E"
	S PF=$$fmt^DBSEXEP(fmt,NS,P(3),P(15))
	I $get(vobjref)'="" S vobjref=$$fmt^DBSEXEP(fmt,vobjref,P(3),P(15))
	I $E(PF,1,3)="$E(" S PF=$E(($piece(PF,",",1,$L(PF,",")-2)),4,999)
	Q 
	;
PROTECT	; Build display protection logic
	D ^DBSPROT4(FID,DI,.VP,P(10),SAVT+1,.vobjlst)
	Q 
	;
VPR(dbtbl2)	; Build the prompt (VPR) section of the program
	N X
	;
	I P(11)[$char(128) S P(11)=$TR(P(11),$char(128),$char(124))
	I P(11)?.E1"<<"1E.E1">>".E S P11=P(11) D VARSUB^DBS2PSL1(.dbtbl2) S NS=$$NS(NS) D VPR1(.dbtbl2) D EDIT(.dbtbl2) D VDA2(.dbtbl2) Q 
	S HEADER=$$HEADER(CY,CX,$L(P(11)),VPRV1,VPRV2,VPRPRO,VPRGI,"T",,.dbtbl2)
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	I $P(vobj(dbtbl2,0),$C(124),7),(CY'<$P(vobj(dbtbl2,0),$C(124),7)) D RPTPR(.dbtbl2) Q 
	S VPROBJ=VPROBJ+1
	S X=" set VO("_VPROBJ_")="_HEADER_P(11)_""""
	D TMPC(X) Q 
	;
VPR1(dbtbl2)	;
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	N Z
	I '$P(vobj(dbtbl2,0),$C(124),7) Q 
	I CY<$P(vobj(dbtbl2,0),$C(124),7) Q 
	;
	; Repeat Region
	S Z=$piece(P11,"<<",2) S Z=$piece(Z,">>",1)
	I '((Z?1A.AN)!(Z?1"%".AN)) Q 
	S NS=$piece(NS,Z,1)_Z_"(I)"_$piece(NS,Z,2,99)
	Q 
	;
HEADER(DY,DX,LEN,VID1,VID2,PRO,GI,TYP,zDFT,dbtbl2)	;
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	;
	N X
	;
	S zDFT=$get(zDFT)
	I $P(vobj(dbtbl2,0),$C(124),7),DY'<$P(vobj(dbtbl2,0),$C(124),7) S DY=$S(DY=$P(vobj(dbtbl2,0),$C(124),7):"DY",1:"DY+"_(DY-$P(vobj(dbtbl2,0),$C(124),7)))
	I $piece(VID2,",",6)="" S VID2="0,0,0,0,0,0"
	S X="$C("_DY_","_+DX_","_+LEN_","_VID1_","_VID2_")_"
	I $L(TYP)>1 S TYP="T"
	I zDFT S X=X_""""_GI_9_TYP
	E  S X=X_""""_GI_PRO_TYP
	Q X
	;
VTAB(dbtbl2)	; Build the table section VTAB of the program
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	N bkey N gbl N rectyp N X N z
	;
	I $get(LIB)'="",$get(FID)'="" S P(16)=$$REQ^DBSDD(FID_"."_DI,"",.vdd)
	I PRO S secret=2
	; Not required for logical data types
	I P(12)=1,P(10)="L" S P(12)=0
	I P(6)'="",P(6)?1A.AN S P(6)="^DBCTL(%LIBS,"""_P(6)_""","
	I P(7)'="" S P(7)="if "_P(7)
	;
	S VDACX=VDACX-1 S SAVT=SAVT+1
	I CY'<$P(vobj(dbtbl2,0),$C(124),7) S %MOD=%MOD+1
	E  S %OFF=%OFF+1
	S DX=VDACX
	;
	; @[FID]DI syntax  ... COPY FILE ID FROM [...]
	I FID="" D
	.	I $get(P(30))?1"@["1E.E1"]"1E.E S DINAM="["_$E(($piece(P(30),"]",1)),3,99)_"]"_DINAM
	.	; Variable name syntax for I(1)
	.	E  S DINAM="[*]"_DINAM
	.	I $get(P(30))?1"@"1E.E S DINAM="[*]"_P(30)
	.	Q 
	E  S DINAM="["_FID_"]"_DI
	S PRMBL="$C("_(CY-1)_","_DX_","_len_")_"""_secret_+P(12)_P(10)
	S BLKSIZ=BLKSIZ+P(3)
	I P(21) S PRMBL=PRMBL_$E((1000+P(21)),2,4)_$E((100+P(22)),2,3)
	S X=$S(P(30)'="":P(30),1:P(5))
	I X?1"[".E1",".E1"]".E S X="["_$piece(X,",",2)
	;
	; %TAB SEQUENCE
	S %NAMCUR(X)=%NAMCUR(X)_"|"_SAVT
	;
	I FID'="" D
	.	S z=fsn(FID) S gbl=$piece(z,"|",2) S rectyp=$piece(z,"|",4)
	.	S bkey=$piece(($piece(gbl,"(",2)),",",$L(gbl,","))
	.	I rectyp=1,$piece(z,"|",1)[")" S NODE="" S bkey=""
	.	I NODE?1N1"*" S NODE=1
	.	I CY'<$P(vobj(dbtbl2,0),$C(124),7) S NODE=1
	.	Q 
	;
	E  I "*"[FID S bkey=""
	;
	I 'P(8) S P(8)=""
	I 'P(9) S P(9)=""
	I P(8) S POPT="PO" S PP=21 D PP^DBS2PSL1 S P(8)=PP ; Post processor
	I P(9) S POPT="PR" S PP=1 D PP^DBS2PSL1 S P(9)=PP ; Pre processor
	;
	; CYXXRLLTDELPP
	S $piece(P,"|",1)=PRMBL
	S $piece(P,"|",2)=$S(NODE?1A.E&(NODE=bkey):"",1:NODE)
	I FID'="",DI'="",$$CMP^DBSDD(FID_"."_DI,"",.vdd)'="" S $piece(P,"|",2)="*"_DI
	;
	I NODE="",$$CMP^DBSDD(FID_"."_DI)="" S $piece(P,"|",2)="*"_DI
	S $piece(P,"|",3)=DINAM ;    [FID]DI
	S $piece(P,"|",4)=$$DBLQ(P(6)) ;    Table lookup
	S $piece(P,"|",5)=$$DBLQ(P(7)) ;    Pattern match
	S $piece(P,"|",6)=$$DBLQ(P(8)) ;    Post processor
	S $piece(P,"|",7)=$$DBLQ(P(9)) ;    Pre processor
	S $piece(P,"|",8)=P(13) ;    Minimum value
	S $piece(P,"|",9)=P(14) ;    Maximum value
	S $piece(P,"|",10)=P(15) ;    Decimal precision
	S $piece(P,"|",11)=P(18) ;    Sub-Field Definition
	I len<P(19) S $piece(P,"|",12)=P(19) ;    Maximum field length
	;
	F L=$L(P):-1:0 Q:$E(P,L)'="|"  ;    Strip trailing blanks
	S TAB(SAVT)=" set %TAB("_SAVT_")="_$E(P,1,L)_""""
	S P=""
	S DFID=$E(($piece(DINAM,"]",1)),2,99)
	I $get(DFID)="" Q 
	;
	D STATUS^UPID(DFID,DI,.FLGPROT)
	Q 
	;
RPTFLD(NS,dbtbl2)	; Fix NS for repeating fields
	N I N X
	I '($D(RPTDA)#2) D RPTDA(.dbtbl2)
	I $E(NODE,1)="*" S NS=$piece(NODE,"*",2)_"(I)" S:P(21) NS="$P("_NS_","""_$char(P(21))_""","_P(22)_")"
	E  S NS=$$ADDSUB(NS,"I")
	Q NS
	;
ADDSUB(expr,var)	; Add subscript var to expr
	N I
	I $get(var)="" S var="I"
	I expr'["(" Q expr_"("_var_")"
	I expr["(1)" Q $piece(expr,"(1)",1)_"("_var_")"_$piece(expr,"(1)",2,99)
	I expr[(var_")") Q expr
	F I=1:1:$L(expr) Q:"),"[$E(expr,I) 
	I $E(expr,I)=")" Q $E(expr,1,I-1)_","_var_$E(expr,I,1048575)
	I $E(expr,I-1)=")" Q $E(expr,1,I-2)_","_var_$E(expr,I,1048575)
	Q $E(expr,1,I-1)_"("_var_")"_$E(expr,I,1048575)
	;
RPTDA(dbtbl2)	; Repeating data subroutine
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	;
	N acckeys N fid N keys N pfid N sn
	N count N I N quit
	;
	S count=0
	S quit=0
	;
	S keys=""
	S pfid=$$Primary^DBS2PSL4(PFID) ;.piece(",",1) // primary file on screen
	I '(pfid="") D
	.	N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=pfid,dbtbl1=$$vDb3("SYSDEV",pfid)
	.	 S vop3=$G(^DBTBL(vop1,1,vop2,16))
	.	S acckeys=$P(vop3,$C(124),1)
	.	F I=1:1:$L(acckeys,",") D  Q:quit 
	..		I $$isLit^UCGM($piece(acckeys,",",I)) Q  ;ignore literals
	..		I $L(PFID,",")=1,(I=$L(acckeys,",")) S quit=1 Q 
	..		S count=count+1
	..		S keys=keys_",$G(KEYS("_count_"))"
	..		Q 
	.	Q 
	S keys=$E(keys,2,1048575)
	;
	S RPTBLK=BLKSIZ
	D TMPD("  ")
	I '($D(RPTCNT)#2) S RPTCNT=0
	D TMPD(" set:'%MODS.exists() %MODS=1 set VX=VO.piece(""|"",2)+"_(RPTCNT-1)_",DY="_$P(vobj(dbtbl2,0),$C(124),7)_" for I=%MODS:1:%REPEAT+%MODS-1 do VRDA("_vobjlst("actual")_")")
	D TMPD(" set VO.piece(""|"",1)=VX quit  // EOD pointer")
	D TMPD(" ")
	D TMPD("VRDA("_vobjlst("formal")_")  // Display data %REPEAT times")
	D TMPD(" //instantiate new object if necessary")
	;
	S fid=""
	F  S fid=$order(vFID(fid)) Q:fid=""  D
	.	S sn=vFID(fid)_"(I)"
	.	D TMPD("  #ACCEPT;DATE=08/08/06; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEPRECATED")
	.	D TMPD("  if '"_sn_".getPointer() do {")
	.	D TMPD("     set "_sn_"=Class.new(""Record"_fid_""","""_keys_""")")
	.	D TMPD("     }")
	.	Q 
	S RPTDA=D+1 S RPTCNT=1
	Q 
	;
RPTPR(dbtbl2)	; Repeating prompt subroutine
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	N X
	I '($D(RPTPR)#2) D
	.	D TMPC(" if '%MODS.exists() set %MODS=1")
	.	D TMPC(" set DY="_$P(vobj(dbtbl2,0),$C(124),7)_" for I=%MODS:1:%REPEAT+%MODS-1 do VRPR("_vobjlst("actual")_")")
	.	I $P(vobj(dbtbl2,0),$C(124),18) D TMPC(" set VO=(+VO)_""|""_(VO+1)_""|13|1"" quit  // BOD pointer")
	.	E  D TMPC(" set VO=(+VO)_""|""_(VO+1)_""|13"" quit  // BOD pointer")
	.	D TMPC(" ")
	.	D TMPC("VRPR("_vobjlst("formal")_")  // Display prompts %REPEAT times")
	.	D TMPC(" ")
	.	S RPTPR=1
	.	Q 
	;
	S X=" set VO(VO+"_RPTPR_")="_HEADER_P(11)_""""
	D TMPC(X)
	; next repeating PR counter
	S RPTPR=RPTPR+1
	Q 
	;
VIDEO(X)	; Build video attribute string (New structure)
	N Z1
	;
	S VPRGI=0 S VPRV2=0 S secret=0
	I X>63 S VPRV2=$piece(X,",",2,99)
	; Graphic Mode
	I X>128 S VPRGI=1 S X=X-128
	; Secret Mode
	I X>79 S secret=1 Q X-80
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
	I X[(""""_$char(128)_"""") S X=$$REPLACE(X,""""_$char(128)_"""","$C(124)")
	I X["""" S X=$$REPLACE(X,"""","""""")
	I X["|" S X=$$REPLACE(X,"|","""_$C(124)_""")
	Q X
	;
REPLACE(X,OS,NS)	; Change all occurrances of OS to NS
	N I
	N L
	;
	I ($get(X)="") Q ""
	S L=0
	F I=1:1 S L=$F(X,OS,L) Q:'L  S X=$E(X,1,L-$L(OS)-1)_NS_$E(X,L,9999) S L=L+$L(NS)-$L(OS)
	Q X
	;
NS(X)	; Build record access string for variables
	;
	I ($get(X)="") Q ""
	I $E(X,1)=$char(34) Q X
	;
	I X?1A.AN!(X?1"%".AN)!(X?1A.AN1"("1E.E1")") S X=X_".get()"
	I $get(P(21))="" Q X
	; Default to 1st position
	I '$get(P(22)) S POS=1
	Q "$P("_X_","""_$char(P(21))_""","_P(22)_")"
	;
KVAR(KVAR,X,LIST)	; Build KVAR string for variables and save it in LIST()
	;
	S KVAR=$get(KVAR)
	S LIST(X)=""
	I ","_KVAR_","[(","_X_",")!PRO Q KVAR
	Q KVAR_","_X
	;
COMPILE(DINAM,dbtbl2)	;
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	;
	N I
	N X N z
	;
	S DI=$piece(DINAM,"]",2)
	S FID=$piece($piece(DINAM,"]",1),",",2)
	S LIB=$piece($piece(DINAM,"[",2),",",1)
	D PARSE^DBSDD(.DINAM,.X,.comp,.fsn,"",.vdd) Q:ER 
	;   Patch NODE,DEL,POS,TABLE,PATTERN,MIN,MAX,DEC
	;set LIB=$P(DINAM,".",1) set FID=$P(DINAM,".",2) set DI=$P(DINAM,".",3)
	I (","_FILES_",")'[(","_FID_",") S NS="" Q 
	S sn=$piece(fsn(FID),"|",1)
	I $E(sn,$L(sn))="(" S sn=$E(sn,1,$L(sn)-1)
	I '$P(vobj(dbtbl2,0),$C(124),7) S vobjref=sn_"."_DI ; this DI not in a repeat region
	E  I P(1)/1000<$P(vobj(dbtbl2,0),$C(124),7),($D(vFID(FID))#2) S vobjref=sn_"(1)."_DI ; Repeating file, but this col not in repeat region.  Use 1.
	E  I P(1)/1000<$P(vobj(dbtbl2,0),$C(124),7) S vobjref=sn_"."_DI ; this DI not in a repeat region
	E  S vobjref=sn_"(I)."_DI ; this DI is in a repeat region
	S NODE=$piece(X,"|",1) S P(18)=$piece(X,"|",18)
	I NODE="",$piece(X,"|",16)="" S NS=DI
	I $piece(X,"|",21),$piece(X,"|",20)="" D
	.	S $piece(X,"|",20)=$piece(fsn(FID),"|",10)
	.	S P(21)=$piece(X,"|",20) ; Update screen attribute
	.	Q 
	;
	; logic to also check protected data items)
	F I=6,7,10,13,14,15,21,22 I P(I)'=$piece(X,"|",I-1) D
	.	S z=$piece("\\\\\TABLE\PATTERN\\\TYPE\\\MIN\MAX\DECIMAL\\\\\\DEL\POS","\",I)
	.	I PRO D  Q 
	..		I '((I=10)!(I=15)) Q 
	..		WRITE !,"Warning - [",$piece(P(5),",",2)," mismatch on attribute ",z," screen=",P(I)," file=",$piece(X,"|",I-1) Q 
	..		Q 
	.	S P(I)=$piece(X,"|",I-1)
	.	WRITE !,"Change ",P(5)," attribute ("_z_"="_P(I)_") to match file definition",!
	.	Q 
	Q 
	;
ERROR(X)	; Print errors
	;
	I ESEQ'=SEQ S ESEQ=SEQ WRITE !,SEQ," - Col: ",CY," Row: ",CX,"  ",DINAM,!
	WRITE X,!
	Q 
	;
END(dbtbl2)	; Go to build program
	D ^DBS2PSL1(.dbtbl2)
	Q 
	;
vSIG()	;
	Q "60680^50197^Pete Chenard^19694" ; Signature - LTD^TIME^USER^SIZE
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(DBTBL2,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL2"
	S vobj(vOid)=$G(^DBTBL(v1,2,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,2,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL2" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDb3(v1,v2)	;	voXN = Db.getRecord(DBTBL1,,0)
	;
	N dbtbl1
	S dbtbl1=$G(^DBTBL(v1,1,v2))
	I dbtbl1="",'$D(^DBTBL(v1,1,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1" X $ZT
	Q dbtbl1
	;
vDbEx1()	;	min(1): DISTINCT LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS=:%LIBS AND SID=:SID AND SEQ=:SEQ AND PSEQ=21
	;
	N vsql1
	S vsql1=$G(%LIBS) I vsql1="" Q 0
	;
	;
	S SEQ=+SEQ
	I '($D(^DBTBL(vsql1,2,SID,SEQ,21))#2) Q 0
	Q 1
	;
vDbEx2()	;	min(1): DISTINCT LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS=:%LIBS AND SID=:SID AND SEQ=:SEQ AND PSEQ=1
	;
	N vsql1
	S vsql1=$G(%LIBS) I vsql1="" Q 0
	;
	;
	S SEQ=+SEQ
	I '($D(^DBTBL(vsql1,2,SID,SEQ,1))#2) Q 0
	Q 1
