 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSRW3 ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSRW3(dbtbl5h,ddmap,RPTINFO) ; 
 ;
 N SKIPLF
 N LVL N PGTRRGN
 N CODE N TABCHR
 ;
 S TABCHR=$char(9)
 ;
 ; Key break logic
 D
 .	N I
 .	N BRKCODE
 .	;
 .	D addcode^DBSRWUTL(0,"VBREAK"_TABCHR_"//")
 .	D addcode^DBSRWUTL(1,"type public Number VD(),vh(),VH0,vs(),VT()")
 .	D addcode^DBSRWUTL(1,"quit:'VT("_RPTINFO("LASTLVL")_")")
 .	;
 .	; Access keybreak and group header indicators
 .	D BRKINFO(.dbtbl5h,.ddmap,.RPTINFO,.BRKCODE)
 .	;
 .	F I=1:1 Q:'($D(BRKCODE(I))#2)  D addcode^DBSRWUTL(1,BRKCODE(I))
 .	;
 .	I RPTINFO("REPEATSIZE") D addcode^DBSRWUTL(1,"if VH0.get() do VOM2"_TABCHR_"// Flush print buffer at page break")
 .	D addcode^DBSRWUTL(1,"quit")
 .	D addcode^DBSRWUTL(0,"")
 .	Q 
 ;
 I RPTINFO("LASTLVL")>1 D
 .	N LVL
 .	N CODE
 .	;
 .	D addcode^DBSRWUTL(0,"VSUM"_TABCHR_"// Report Group Summary")
 .	D addcode^DBSRWUTL(1,"type public Number VFMQ,vs()")
 .	F LVL=RPTINFO("LASTLVL"):-1:2 D
 ..		S CODE="if 'vs("_LVL_") set vs("_LVL_")=1"
 ..		I '($order(RPTINFO("DSP",LVL,"T",""))="") S CODE=CODE_" do VSUM"_LVL_" quit:VFMQ "
 ..		S CODE=CODE_" do stat^DBSRWUTL("_LVL_")"
 ..		D addcode^DBSRWUTL(1,CODE)
 ..		Q 
 .	D addcode^DBSRWUTL(1,"quit")
 .	D addcode^DBSRWUTL(0,"")
 .	Q 
 ;
 ; Set up code for data field statistics
 D
 .	N FUNTYP N I N LINENO
 .	N DI N DINAM N FUN N GT N LE N NEWLIST N TYPE N v N V N Z
 .	;
 .	D addcode^DBSRWUTL(0,"VSTAT"_TABCHR_"// Data field statistics")
 .	;
 .	D addcode^DBSRWUTL(1,"// Placeholder for type public",.LINENO)
 .	D addcode^DBSRWUTL(1,"type public String VSTATS()")
 .	D addcode^DBSRWUTL(0,"")
 .	S NEWLIST="type public Number VRWOPT(),VT(),"
 .	;
 .	; Deal with functions, @TOT, @MIN, @MAX
 .	D addcode^DBSRWUTL(1,"set VT("_RPTINFO("LASTLVL")_")=VT("_RPTINFO("LASTLVL")_")+1") ; Group record cound
 .	S DINAM=""
 .	F I=1:1 S DINAM=$order(RPTINFO("FMT",0,DINAM)) Q:DINAM=""  D
 ..		N varList
 ..		N elem
 ..		;
 ..		S DI=DINAM
 ..		I $E(DI,1,2)="<<" S DI=$piece($piece(DI,">>",1),"<<",2)
 ..		; Convert to internal format and add to data map
 ..		S V=$$map^DBSRWUTL(DI,.ddmap,1,.varList)
 ..		F elem=1:1:$S((varList=""):0,1:$L(varList,",")) I NEWLIST'[(","_$piece(varList,",",elem)_",") S NEWLIST=NEWLIST_$piece(varList,",",elem)_","
 ..		S TYPE="$"
 ..		I DINAM'["<<",V?1A.AN S TYPE=$$TYP^DBSDD(DINAM)
 ..		S FUN=""
 ..		F  S FUN=$order(RPTINFO("FMT",0,DINAM,FUN)) Q:FUN=""  D
 ...			S FUNTYP=$S(FUN="TOT":1,FUN="MAX":2,FUN="MIN":3,FUN="AVG":4,1:5)
 ...			Q:FUNTYP=5 
 ...			I FUNTYP=4,($D(RPTINFO("FMT",0,DINAM,"TOT"))#2) Q  ; @AVG
 ...			I FUNTYP=4 S FUNTYP=1 ; Use TOT logic
 ...			I V'?1A.AN S V="("_V_")"
 ...			S v=V
 ...			; Great than and less than
 ...			I "TUF"[TYPE S GT="]" S LE="']"
 ...			E  S GT=">" S LE="<" S v="+"_v
 ...			S CODE="VT("_RPTINFO("LASTLVL")_","_I_","_FUNTYP_")"
 ...			I FUNTYP=1 S Z="set "_CODE_"="_CODE_"+"_V
 ...			I FUNTYP=2 S Z="if "_CODE_"="_""""""_"!("_V_GT_CODE_") set "_CODE_"="_v
 ...			I FUNTYP=3 S Z="if "_CODE_"="_""""""_"!("_V_LE_CODE_") set "_CODE_"="_v
 ...			;
 ...			D addcode^DBSRWUTL(1,Z_TABCHR_"// @"_FUN_"("_DINAM_")")
 ...			Q 
 ..		Q 
 .	;
 .	;   RPTINFO("STAT",SEQ)=Source|fmt|Target|Increments
 .	I $D(RPTINFO("STAT")) D
 ..		N I
 ..		N SOURCE N TARGET N X
 ..		;
 ..		; Suppress STAT flag
 ..		D addcode^DBSRWUTL(1,"if VRWOPT(""NOSTAT"").get() quit")
 ..		F I=1:1 Q:'$D(RPTINFO("STAT",I))  D
 ...			S SOURCE=$piece(RPTINFO("STAT",I),"|",1)
 ...			S TARGET=$piece(RPTINFO("STAT",I),"|",3)
 ...			; Make sure in TABLE.COLUMN format
 ...			S X=$$validtcr^DBSRWUTL(SOURCE,.SOURCE)
 ...			S X=$$validtcr^DBSRWUTL(TARGET,.TARGET)
 ...			S CODE="do vstats^DBSRWUTL("_I_","_ddmap(SOURCE)_","_ddmap(TARGET)_","
 ...			S CODE=CODE_""""_RPTINFO("STAT",I)_""",VSTATS())"
 ...			D addcode^DBSRWUTL(1,CODE)
 ...			I NEWLIST'[(","_ddmap(SOURCE)_",") S NEWLIST=NEWLIST_ddmap(SOURCE)_","
 ...			I NEWLIST'[(","_ddmap(TARGET)_",") S NEWLIST=NEWLIST_ddmap(TARGET)_","
 ...			Q 
 ..		Q 
 .	;
 .	D addcode^DBSRWUTL(1,$E(NEWLIST,1,$L(NEWLIST)-1),LINENO)
 .	;
 .	; End of VSTAT section
 .	D addcode^DBSRWUTL(1,"quit")
 .	Q 
 ;
 ; Page trailer region
 S PGTRRGN=0
 I $order(RPTINFO("DSP",90,"T",0)) S PGTRRGN=$piece(RPTINFO("DSP",90),",",3)+1
 ;
 S SKIPLF=0
 F LVL=1:1:RPTINFO("LASTLVL"),90,92 I $D(RPTINFO("DSP",LVL)) D
 .	;
 .	N SEC
 .	;
 .	F SEC="H","D","T" I '($order(RPTINFO("DSP",LVL,SEC,""))="") D BUILDSEC(LVL,SEC,PGTRRGN,.RPTINFO,.ddmap,.SKIPLF)
 .	Q 
 ;
 ; Page header without info
 I $order(RPTINFO("DSP",90,""))="" D
 .	D BUILDPH(0,.RPTINFO,.ddmap) D BUILDLC
 .	D addcode^DBSRWUTL(0,"")
 .	D addcode^DBSRWUTL(1,"quit")
 .	Q 
 ;
 D BLDPRNT(.RPTINFO)
 ;
 ; Report pre/post-processors
 D addcode^DBSRWUTL(1,"// Pre/post-processors")
 S PPNUM=""
 F  S PPNUM=$order(RPTINFO("VPSUBS",PPNUM)) Q:PPNUM=""  D
 .	D addcode^DBSRWUTL(0,"")
 .	D addcode^DBSRWUTL(0,"VP"_PPNUM_RPTINFO("VPSUBS",PPNUM,0))
 .	D addcode^DBSRWUTL(0,"")
 .	;
 .	S I=0
 .	F  S I=$order(RPTINFO("VPSUBS",PPNUM,I)) Q:I=""  D addcode^DBSRWUTL(-1,RPTINFO("VPSUBS",PPNUM,I))
 .	D addcode^DBSRWUTL(1,"quit")
 .	Q 
 ;
 D addcode^DBSRWUTL(1,"quit")
 ;
 Q 
 ;
BUILDSEC(LVL,SEC,PGTRRGN,RPTINFO,ddmap,SKIPLF) ; 
 ;
 N FLDOVF N LN N RGNSIZE
 N X
 ;
 ; Get region size
 S X=$S(SEC="H":1,SEC="D":2,1:3)
 S RGNSIZE=+$piece(RPTINFO("DSP",LVL),",",X)
 ;
 D addcode^DBSRWUTL(0,"")
 ;
 I LVL<90 D  ; VHGn,VDTLn,VSUMn
 .	N I
 .	N CODE N EXCLVARS N NEWLIST N SECVAR N vclist N vovclist
 .	;
 .	S EXCLVARS=""
 .	;
 .	I SEC="H" D
 ..		S CODE="VHDG"_LVL_$char(9)_"// Group Header"
 ..		S NEWLIST="CONAM,ER,IOSL,%MSKD,RID,RN,%TIM,V,vcrt,verror,VFMQ,vh(),VL,VLC,VNEWHDR,VO,VOFFLG,VPN,VRG,vrundate"
 ..		S SECVAR="vh"
 ..		Q 
 .	E  I SEC="D" D
 ..		S CODE="VDTL"_LVL_$char(9)_"// Detail"
 ..		S NEWLIST="IOSL,V,VD(),verror,VFMQ,vh(),VL,VLC,VO,VOFFLG,VRG,VT()"
 ..		S SECVAR="VD"
 ..		Q 
 .	E  D
 ..		S CODE="VSUM"_LVL_$char(9)_"// Summary"
 ..		S NEWLIST="I,IOSL,VFMQ,V,verror,vh(),VL,VLC,VO,VOFFLG,VT(),VX()"
 ..		S (vclist,vovclist)=""
 ..		; Add ddmap and vo* variables to exclude list
 ..		F I=1:1:ddmap(0)-1 D
 ...			;
 ...			N TC
 ...			S TC=ddmap(I)
 ...			S EXCLVARS=EXCLVARS_ddmap(TC)_",vo"_ddmap(TC)_","
 ...			S vclist=vclist_ddmap(TC)_","
 ...			S vovclist=vovclist_"vo"_ddmap(TC)_","
 ...			Q 
 ..		S EXCLVARS=$E(EXCLVARS,1,$L(EXCLVARS)-1)
 ..		S vclist=$E(vclist,1,$L(vclist)-1)
 ..		S vovclist=$E(vovclist,1,$L(vovclist)-1)
 ..		Q 
 .	D addcode^DBSRWUTL(0,CODE)
 .	;
 .	S NEWLIST=$$newlist^DBSRWUTL("ALL",.RPTINFO,.ddmap,NEWLIST,.EXCLVARS)
 .	F  D  Q:(NEWLIST="") 
 ..		D addcode^DBSRWUTL(1,"type public String "_$piece(NEWLIST,",",1,100))
 ..		S NEWLIST=$piece(NEWLIST,",",101,$L(NEWLIST))
 ..		Q 
 .	D addcode^DBSRWUTL(0,"")
 .	;
 .	I LVL=RPTINFO("LASTLVL"),SEC="D" Q  ; Print last level data
 .	I SEC="T" D  Q 
 ..		;
 ..		N X
 ..		;
 ..		; Old values
 ..		F  D  Q:(vovclist="") 
 ...			D addcode^DBSRWUTL(1,"type public String "_$piece(vovclist,",",1,100))
 ...			S vovclist=$piece(vovclist,",",101,$L(vovclist))
 ...			Q 
 ..		S X=vclist ; New values
 ..		F  D  Q:(X="") 
 ...			D addcode^DBSRWUTL(1,"type String "_$piece(X,",",1,100))
 ...			S X=$piece(X,",",101,$L(X))
 ...			Q 
 ..		;
 ..		D addcode^DBSRWUTL(1,"if 'VT("_LVL_") quit") ; Print if count>0
 ..		;
 ..		; Re-assign old value for this sub-routine
 ..		F I=1:1:$L(vclist,",") D addcode^DBSRWUTL(1,"set "_$piece(vclist,",",I)_"=vo"_$piece(vclist,",",I))
 ..		Q 
 .	S CODE="quit:"_SECVAR_"("_LVL_")  set "_SECVAR_"("_LVL_")=1"
 .	S CODE=CODE_$char(9)_"// Print flag"
 .	D addcode^DBSRWUTL(1,CODE)
 .	Q 
 ;
 I LVL=90 D
 .	I SEC="H" D BUILDPH(RGNSIZE,.RPTINFO,.ddmap) ; Page Header
 .	I SEC="T" D  ; Page Trailer
 ..		N NEWLIST N NUMTYPE
 ..		D addcode^DBSRWUTL(0,"VTRL0"_$char(9)_"// Page Trailer")
 ..		S NUMTYPE="IOSL,verror,vh,VFMQ,VLC,VT(),VX()"
 ..		D addcode^DBSRWUTL(1,"type public Number IOSL,verror,vh,VFMQ,VLC,VT(),VX()")
 ..		S NEWLIST=$$newlist^DBSRWUTL("ALL",.RPTINFO,.ddmap,"",NUMTYPE)
 ..		I NEWLIST'="" D
 ...			;
 ...			F  D  Q:(NEWLIST="") 
 ....				D addcode^DBSRWUTL(1,"type public String "_$piece(NEWLIST,",",1,100))
 ....				S NEWLIST=$piece(NEWLIST,",",101,$L(NEWLIST))
 ....				Q 
 ...			Q 
 ..		D addcode^DBSRWUTL(1,"type Number I")
 ..		D addcode^DBSRWUTL(1,"type String VL")
 ..		D addcode^DBSRWUTL(0,"")
 ..		D addcode^DBSRWUTL(1,"set VL=""""")
 ..		; Bottom of the page
 ..		D addcode^DBSRWUTL(1,"for I=VLC:1:IOSL-"_PGTRRGN_" do VOM")
 ..		Q 
 .	Q 
 ;
 I LVL=92 D
 .	N NEWLIST N NUMTYPE
 .	D addcode^DBSRWUTL(0,"VRSUM"_$char(9)_"// Report Summary")
 .	S NUMTYPE="IOSL,verror,VFMQ,vh,VLC,VT(),VX()"
 .	D addcode^DBSRWUTL(1,"type public Number IOSL,verror,VFMQ,vh,VLC,VT(),VX()")
 .	S NEWLIST=$$newlist^DBSRWUTL("UD",.RPTINFO,.ddmap,"",NUMTYPE_",I,V,VL")
 .	I NEWLIST'="" D
 ..		;
 ..		F  D  Q:(NEWLIST="") 
 ...			D addcode^DBSRWUTL(1,"type public String "_$piece(NEWLIST,",",1,100))
 ...			S NEWLIST=$piece(NEWLIST,",",101,$L(NEWLIST))
 ...			Q 
 ..		Q 
 .	D addcode^DBSRWUTL(1,"type Number I")
 .	D addcode^DBSRWUTL(1,"type String V,VL")
 .	D addcode^DBSRWUTL(0,"")
 .	D addcode^DBSRWUTL(1,"set VL=""""")
 .	I RPTINFO("REPEATSIZE") D addcode^DBSRWUTL(1,"do VOM2")
 .	D addcode^DBSRWUTL(1,"if 'vh(0) do VHDG0 quit:VFMQ")
 .	Q 
 ;
 I LVL'=90 D  ; Page overflow checking
 .	N CODE
 .	;
 .	I RPTINFO("REPEATSIZE"),SEC="H" D addcode^DBSRWUTL(1,"do VOM2") ; Flush buffer
 .	I LVL'=92 D
 ..		N X
 ..		S X=RGNSIZE+PGTRRGN ; Section size
 ..		I SEC="D","*"'[$get(RPTINFO("SEQBY",LVL,"MINPNT")) S X=RPTINFO("SEQBY",LVL,"MINPNT")
 ..		I SEC="T" S X=X-1
 ..		S CODE="if VLC+"_X_">IOSL do VHDG0 quit:VFMQ "
 ..		Q 
 .	E  S CODE="if VLC+"_RGNSIZE_">IOSL do VHDG0 quit:VFMQ "
 .	;
 .	; Save line from prior if doing linefeed suppress until end of VSUMn
 .	I (SEC="T") D addcode^DBSRWUTL(1,"type String VLSAV = """"")
 .	;
 .	I (SEC'="H")&$get(RPTINFO("SEQBY",LVL,"PNTHDR"))&'($order(RPTINFO("DSP",LVL,"H",""))="") D
 ..		; Print group
 ..		S CODE=CODE_" set vh("_LVL_")=0 do VHDG"_LVL
 ..		I (SEC="T") S CODE=CODE_" set VLSAV=VL"
 ..		S CODE=CODE_" quit:VFMQ"
 ..		Q 
 .	D addcode^DBSRWUTL(1,CODE)
 .	I RPTINFO("REPEATSIZE"),(RPTINFO("REPEATGRPLVL")=LVL),(SEC="D") D addcode^DBSRWUTL(1,"set VRG=1")
 .	Q 
 ;
 D addcode^DBSRWUTL(0,"")
 ;
 S FLDOVF=RPTINFO("CUVAR","FLDOVF") ; Field overflow logic on
 I LVL'<90 S FLDOVF=0 ; Only on in detail sections
 ;
 ; Link fields located on the same line
 F LN=1:1:RGNSIZE D  ; Loop through the region
 .	N CODE N L N ZBLK
 .	;
 .	I ($order(RPTINFO("DSP",LVL,SEC,LN,""))="") D  Q  ; Blank line
 ..		D BUILDOF(.RPTINFO) ; overflow
 ..		D addcode^DBSRWUTL(1,"do VOM") ; Blank line (or linefeed suppressed line
 ..		Q 
 .	;
 .	S L=""
 .	F  S L=$order(RPTINFO("DSP",LVL,SEC,LN,L)) Q:L=""  D
 ..		N ITEM1 N LEN N PPFLG
 ..		N FUN N X N X1 N XFMT N Z
 ..		; Insert MUMPS code for this detail line
 ..		S Z=RPTINFO("DSP",LVL,SEC,LN,L) ; Get format code
 ..		S ITEM1=0
 ..		;
 ..		; First Item
 ..		I $order(RPTINFO("DSP",LVL,SEC,LN,L),-1)="" S ITEM1=1
 ..		S X=RPTINFO("FMT",LVL,SEC,(LN*1000)+L)
 ..		S XFMT=$piece(X,"|",1) S LEN=$piece(X,"|",2) S FUN=$piece(X,"|",3)
 ..		S PPFLG=$piece(X,"|",4)+$piece(X,"|",5) S ZBLK=$piece(X,"|",6)
 ..		;
 ..		; Page Break <<#>>
 ..		I FUN="~#" D  Q 
 ...			D addcode^DBSRWUTL(1,"do VHDG0 quit:VFMQ"_$char(9)_"// <<#>>")
 ...			Q 
 ..		;
 ..		; Convert Z to M code in CODE (was $$MUMPS())
 ..		D
 ...			I $E(Z,1)="~" S Z=$E(Z,2,1048575)
 ...			;
 ...			; First item on this line
 ...			I ITEM1 D
 ....				;
 ....				I 'PPFLG D  Q 
 .....					I SKIPLF S CODE="set VL=VL_"""".justify("_(L-1)_"-VL.length())_("_Z_")"
 .....					E  I L=1 S CODE="set VL="_Z ; On column one
 .....					E  S CODE="set VL="""_$J("",(L-1))_"""_("_Z_")"
 .....					Q 
 ....				E  D  ; With pre/post proc
 .....					I SKIPLF S CODE=Z_"set VL=VL_"""".justify("_(L-1)_"-VL.length())_V"
 .....					E  I L=1 S CODE=Z_"set VL=V" ; On column one
 .....					E  S CODE=Z_"set VL="""_$J("",(L-1))_"""_V"
 .....					Q 
 ....				;
 ....				S SKIPLF=0
 ....				Q 
 ...			;
 ...			; Second - nth item on line - pad with spaces
 ...			E  D
 ....				I 'PPFLG D
 .....					S CODE="set VL=VL_"""".justify("_(L-1)_"-VL.length())_("_Z_")"
 .....					I FLDOVF S CODE=CODE_",VOFFLG=0"
 .....					Q 
 ....				E  S CODE=Z
 ....				Q 
 ...			Q 
 ..		;
 ..		; @function
 ..		I $E(FUN,1)="@" D STAT(FUN,LVL,.RPTINFO,.ddmap)
 ..		;
 ..		D addcode^DBSRWUTL(1,CODE)
 ..		;
 ..		I 'ITEM1,PPFLG D  ; PP flag on
 ...			I FLDOVF,$$OVFFMT(XFMT) S CODE="do VOFN(V,"_(L-1)_","_LEN_")"
 ...			E  D
 ....				S CODE="set VL=VL_"_""""""_".justify("_(L-1)_"-VL.length())_V"
 ....				I FLDOVF S CODE=CODE_",VOFFLG=0"
 ....				Q 
 ...			I "@["[$E(FUN,1) S CODE=CODE_$char(9)_"// "_FUN
 ...			D addcode^DBSRWUTL(1,CODE)
 ...			Q 
 ..		Q 
 .	;
 .	D BUILDOF(.RPTINFO)
 .	; Suppress BL (ZBLK=1) or LF (ZBLK=2) - if suppressing line feed
 .	; just don't print buffer, i.e., no VOM
 .	I 'ZBLK D
 ..		S CODE="do VOM"
 ..		I FLDOVF S CODE=CODE_",VOMOF"
 ..		D addcode^DBSRWUTL(1,CODE)
 ..		Q 
 .	E  I ZBLK=1 D
 ..		S CODE="if 'VL.translate("" "").isNull() do VOM"
 ..		I FLDOVF S CODE=CODE_",VOMOF"
 ..		D addcode^DBSRWUTL(1,CODE)
 ..		Q 
 .	E  I ZBLK=2 S SKIPLF=1
 .	Q 
 ;
 ; If header suppresses line feed, need to restore the line's value
 I (SEC="T") D addcode^DBSRWUTL(1,"set VL = VLSAV.get()")
 ;
 I '(LVL=90&(SEC="H")) D addcode^DBSRWUTL(1,"quit") Q 
 ;
 D BUILDLC
 ;
 D addcode^DBSRWUTL(0,"")
 D addcode^DBSRWUTL(1,"quit")
 D addcode^DBSRWUTL(0,"")
 ;
 Q 
 ;
OVFFMT(FMT) ; Private - Determine if overflow format, i.e., N, $, E, or RD
 ;
 N I N OVFFMT
 N X
 ;
 S OVFFMT=0
 F I=1:1:$L(FMT,",") D  Q:OVFFMT 
 .	S X=$piece(FMT,",",I)
 .	I X="N"!(X="$")!(X="E")!(X?1"RD".E) S OVFFMT=1
 .	Q 
 Q OVFFMT
 ;
BUILDOF(RPTINFO) ; Private - Page overflow logic
 ;
 I SEC="D",$get(RPTINFO("SEQBY",LVL,"MINPNT")) D
 .	D addcode^DBSRWUTL(1,"if VLC+"_RPTINFO("SEQBY",LVL,"MINPNT")_">IOSL do VHDG0 quit:VFMQ")
 .	Q 
 Q 
 ;
BUILDLC ; Private - Logic to lock report page header in VT mode
 ;
 D addcode^DBSRWUTL(0,"")
 D addcode^DBSRWUTL(1,"set VNEWHDR=0")
 D addcode^DBSRWUTL(1,"if vcrt set PN=VPN do ^DBSRWBR(2,1)"_$char(9)_"// Lock report page heading")
 ;
 Q 
 ;
BUILDPH(RGNSIZE,RPTINFO,ddmap) ; 
 ;
 N NEWLIST N NUMTYPE
 ;
 S NUMTYPE="ER,IOSL,vcrt,verror,VFMQ,vh(),VLC,VNEWHDR,VPN,VRG,VRWOPT()"
 ;
 D addcode^DBSRWUTL(0,"")
 ;
 D addcode^DBSRWUTL(0,"VHDG0"_$char(9)_"// Page Header")
 D addcode^DBSRWUTL(1,"type public Number "_NUMTYPE)
 ;
 S NEWLIST=$$newlist^DBSRWUTL("ALL",.RPTINFO,.ddmap,"CONAM,%MSKD,RID,RN,%TIM,VL,vrundate,vsysdate",NUMTYPE_",PN,V,VO")
 F  D  Q:(NEWLIST="") 
 .	D addcode^DBSRWUTL(1,"type public String "_$piece(NEWLIST,",",1,100))
 .	S NEWLIST=$piece(NEWLIST,",",101,$L(NEWLIST))
 .	Q 
 ;
 D addcode^DBSRWUTL(1,"type Number PN,V,VO")
 D addcode^DBSRWUTL(1,"if VRWOPT(""NOHDR"").get() quit"_$char(9)_"// Skip page header")
 D addcode^DBSRWUTL(1,"set vh(0)=1,VRG=0")
 D addcode^DBSRWUTL(1,"if VL'="""" do VOM")
 I '($order(RPTINFO("DSP",90,"T",""))="") D addcode^DBSRWUTL(1,"if VPN do VTRL0")
 D addcode^DBSRWUTL(1,"if vcrt,VPN>0 do { quit:VFMQ!'VNEWHDR")
 D addcode^DBSRWUTL(2,"type Number PN,X")
 D addcode^DBSRWUTL(2,"set VL=""""")
 D addcode^DBSRWUTL(2,"for X=VLC+1:1:IOSL do VOM")
 D addcode^DBSRWUTL(2,"set PN=VPN")
 D addcode^DBSRWUTL(2,"do ^DBSRWBR(2)")
 D addcode^DBSRWUTL(2,"set VLC=0")
 D addcode^DBSRWUTL(2,"quit:VFMQ")
 D addcode^DBSRWUTL(2,"#ACCEPT Date=10/13/2008;Pgm=RussellDS;CR=35741;Group=READ")
 D addcode^DBSRWUTL(2,"if VNEWHDR write $$CLEARXY^%TRMVT")
 D addcode^DBSRWUTL(2,"else  set VLC=VLC+"_(+RGNSIZE)_",VPN=VPN+1")
 D addcode^DBSRWUTL(2,"}")
 D addcode^DBSRWUTL(0,"")
 D addcode^DBSRWUTL(1,"set ER=0,VPN=VPN+1,VLC=0")
 ;
 Q 
 ;
STAT(REF,LVL,RPTINFO,ddmap) ; 
 ;
 ; Attempt to use V as often as possible for variable name.  When can't
 ; use VX(seq)
 ;
 N VXCNT
 N NEWVAL N OLDVAL N ORIG N X
 ;
 S ORIG=REF
 ;
 S VXCNT=0 ; Variable number for complex functions
 F  S X=$piece(REF,"@",2) Q:X=""  D
 .	S VXCNT=VXCNT+1
 .	S OLDVAL="@"_$piece(X,")",1)_")"
 .	S NEWVAL=$$STAT1(OLDVAL,LVL,.RPTINFO,.ddmap,.VXCNT)
 .	I NEWVAL="" S REF=""
 .	E  S REF=$piece(REF,OLDVAL,1)_NEWVAL_$piece(REF,OLDVAL,2,99)
 .	Q 
 ;
 ; If complex function involves divide, set up error handling to avoid
 ; divide by zero error
 I REF["/" D
 .	D addcode^DBSRWUTL(1,"do {")
 .	D addcode^DBSRWUTL(2,"// Continue with V="""" if divide by zero error")
 .	D addcode^DBSRWUTL(2,"catch error {")
 .	D addcode^DBSRWUTL(3,"if '(error.type[""DIV""&(error.type[""ZERO"")) throw error")
 .	D addcode^DBSRWUTL(3,"set V=""""")
 .	D addcode^DBSRWUTL(3,"}")
 .	D addcode^DBSRWUTL(2,"set V="_REF_$char(9)_"// "_ORIG)
 .	D addcode^DBSRWUTL(2,"}")
 .	Q 
 ;
 E  I REF'="V" D addcode^DBSRWUTL(1,"set V="_REF_$char(9)_"// "_ORIG)
 ;
 Q 
 ;
STAT1(REF,LVL,RPTINFO,ddmap,VXCNT) ; 
 ;
 N RPTLVL
 N CODE N DI N FOR N FUN N PARAMS N SEQ N X
 ;
 S FUN=$E(REF,2,4)
 S PARAMS=$piece($piece(REF,"(",2),")",1)
 S DI=$piece(PARAMS,",",1)
 ;
 I DI?1A.AN S DI="["_$piece(ddmap,",",1)_"]"_DI ; Convert @FUN(di) to @FUN([fid]di)
 ;
 ; Determine if group or report level
 I LVL=92 S RPTLVL=1 ; Report summary
 E  I FUN="CNT" D
 .	I $piece(PARAMS,",",1)="0" S RPTLVL=1
 .	E  S RPTLVL=0
 .	Q 
 E  I LVL=90 S RPTLVL=1 ; Page trailer always report level
 E  D
 .	I $piece(PARAMS,",",2)="0" S RPTLVL=1
 .	E  S RPTLVL=0
 .	Q 
 ;
 I FUN="CNT",'RPTLVL Q "VT("_LVL_")" ; Group record count
 I FUN="CNT" D  Q CODE ; Report record count
 .	N I
 .	S CODE="("
 .	F I=0:1:RPTINFO("LASTLVL") S CODE=CODE_"VT("_I_")+"
 .	S CODE=$E(CODE,1,$L(CODE)-1)_")"
 .	Q 
 ;
 S SEQ=RPTINFO("FMT",0,DI)
 ;
 ; RPTLVL=1 => use report/running totals
 I RPTLVL,FUN'="TBL" D  Q CODE
 .	;
 .	N VX
 .	;
 .	I VXCNT=1 S VX="V"
 .	E  S VX="VX("_VXCNT_")"
 .	;
 .	S CODE="for I=0:1:"_RPTINFO("LASTLVL")
 .	I FUN="TOT" D
 ..		D addcode^DBSRWUTL(1,"set "_VX_"=0"_$char(9)_"// "_REF)
 ..		S CODE=CODE_" set "_VX_"="_VX_"+VT(I,"_SEQ_",1)"
 ..		D addcode^DBSRWUTL(1,CODE)
 ..		S CODE=VX
 ..		Q 
 .	E  I FUN="MAX" D
 ..		D addcode^DBSRWUTL(1,"set "_VX_"="""""_$char(9)_"// "_REF)
 ..		S CODE=CODE_" if VT(I,"_SEQ_",2)'="""",(VT(I,"_SEQ_",2)>"_VX_")!("_VX_"="""")"
 ..		S CODE=CODE_" set "_VX_"=VT(I,"_SEQ_",2)"
 ..		D addcode^DBSRWUTL(1,CODE)
 ..		S CODE=VX
 ..		Q 
 .	E  I FUN="MIN" D
 ..		D addcode^DBSRWUTL(1,"set "_VX_"="""""_$char(9)_"// "_REF)
 ..		S CODE=CODE_" if VT(I,"_SEQ_",3)'="""",(VT(I,"_SEQ_",3)<"_VX_")!("_VX_"="""")"
 ..		S CODE=CODE_" set "_VX_"=VT(I,"_SEQ_",3)"
 ..		D addcode^DBSRWUTL(1,CODE)
 ..		S CODE=VX
 ..		Q 
 .	;
 .	E  I FUN="AVG" D
 ..		N VX2 S VX2="VX("_(VXCNT+1)_")"
 ..		;
 ..		D addcode^DBSRWUTL(1,"set ("_VX_","_VX2_")=0")
 ..		S CODE=CODE_" set "_VX_"="_VX_"+VT(I,"_SEQ_",1),"_VX2_"="_VX2_"+VT(I)"
 ..		D addcode^DBSRWUTL(1,CODE)
 ..		S CODE="set "_VX_"=$select("_VX2_":"_VX_"/"_VX2_",1:0)"
 ..		D addcode^DBSRWUTL(1,CODE_$char(9)_"// "_REF)
 ..		S CODE=VX
 ..		S VXCNT=VXCNT+1
 ..		Q 
 .	E  D
 ..		WRITE !!,"Invalid Function "_REF
 ..		S CODE="""?"""
 ..		Q 
 .	Q 
 ;
 I LVL=92 S LVL=1 ; Report summary
 ;
 I FUN="TOT" Q "VT("_LVL_","_SEQ_",1)" ; @TOT
 I FUN="MAX" Q "VT("_LVL_","_SEQ_",2)" ; @MAX
 I FUN="MIN" Q "VT("_LVL_","_SEQ_",3)" ; @MIN
 I FUN="AVG" Q "$select(VT("_LVL_"):VT("_LVL_","_SEQ_",1)/VT("_LVL_"),1:0)" ;@AVG
 I FUN="TBL" S X=$$TBL^DBSDD(DI) D  Q CODE
 .	N LINENO N VALID
 .	N ACCKEYS N CALL1 N CALL2 N DESCCOL N DITC N ERROR N I N KEYS N PPNUM N TABLE N WHERE
 .	;
 .	I X'?1"["1E.E1"]" D  Q 
 ..		WRITE !!,"Invalid @TBL table reference "_REF
 ..		S CODE="""?"""
 ..		Q 
 .	;
 .	S VALID=$$validtcr^DBSRWUTL(DI,.DITC)
 .	;
 .	; First, get access keys
 .	S TABLE=$translate(X,"[]") S KEYS=""
 .	N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=TABLE,dbtbl1=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",TABLE,0,"")
 .	 S vop3=$G(^DBTBL(vop1,1,vop2,16))
 .	S ACCKEYS=$$TOKEN^%ZS($P(vop3,$C(124),1))
 .	F I=1:1:$L(ACCKEYS,",") D
 ..		N KEY
 ..		S KEY=$piece(ACCKEYS,",",I)
 ..		Q:KEY?1.N  ; Ignore numeric keys
 ..		Q:$E(KEY,1)=$char(0)  ; Ignore literal strings
 ..		S KEYS=KEYS_KEY_","
 ..		Q 
 .	;
 .	; Find description column
 .	N dbtbl1d,vos1,vos2,vos3,vos4,vos5 S dbtbl1d=$$vOpen1()
 . I '$G(vos1) S CODE="No description column for "_REF Q 
 .	F  Q:'$$vFetch1()  D  Q  ; Only care about 1st in case more
 ..  S DESCCOL=dbtbl1d
 ..		Q 
 .	;
 .	S KEYS=$E(KEYS,1,$L(KEYS)-1)
 .	S (CALL1,CALL2,ERROR,WHERE)=""
 .	F I=1:1:$L(KEYS,",") D  Q:ERROR 
 ..		N KEY N VAR
 ..		S KEY=$piece(KEYS,",",I)
 ..		I I=$L(KEYS,",") S VAR=ddmap(DITC)
 ..		E  D
 ...			N J
 ...			;
 ...			S VAR=""
 ...			F J=1:1:ddmap(0) I $piece(ddmap(J),".",2)=KEY S VAR=ddmap(ddmap(J)) Q 
 ...			Q 
 ..		I VAR="" S ERROR=1
 ..		S CALL1=CALL1_VAR_","
 ..		S CALL2=CALL2_"KEY"_I_","
 ..		S WHERE=WHERE_KEY_"=:KEY"_I_","
 ..		Q 
 .	;
 . I ERROR D  Q 
 ..		WRITE !!,"Invalid @TBL table reference "_REF
 ..		S CODE="""?"""
 ..		Q 
 .	;
 .	S WHERE=$E(WHERE,1,$L(WHERE)-1)
 .	S PPNUM=$order(RPTINFO("VPSUBS",""),-1)+1
 .	S RPTINFO("VPSUBS",PPNUM,0)="("_$E(CALL2,1,$L(CALL2)-1)_")"_$char(9)_"// "_REF
 .	; Handle possibility that key may be null -- if so, just return
 .	; null for description
 .	S LINENO=1
 .	F I=1:1:$L(KEYS,",") D
 ..		S RPTINFO("VPSUBS",PPNUM,LINENO)=$char(9)_"if KEY"_I_"="""" quit """""
 ..		S LINENO=LINENO+1
 ..		Q 
 .	S RPTINFO("VPSUBS",PPNUM,LINENO)=$char(9)_"type public Cache %CACHE()"
 .	S RPTINFO("VPSUBS",PPNUM,LINENO+1)=$char(9)_"type Record"_TABLE_" tbl=%CACHE("""_TABLE_""").getRecord("""_TABLE_""","""_WHERE_""")"
 .	S RPTINFO("VPSUBS",PPNUM,LINENO+2)=$char(9)_"quit tbl."_DESCCOL
 .	S CODE="$$VP"_PPNUM_"("_$E(CALL1,1,$L(CALL1)-1)_")"
 . Q 
 ;
 WRITE !!,"Invalid Function "_REF
 Q """?"""
 ;
BRKINFO(dbtbl5h,ddmap,RPTINFO,BRKCODE) ; 
 ;
 N I N LASTLVL N LINENO
 N CODE N NEWLIST N TABCHR N VKEY N VTYPE N X
 ;
 S TABCHR=$char(9)
 ;
 S LASTLVL=RPTINFO("LASTLVL") ; Last key level
 Q:'LASTLVL  ; Not sure how this could happen
 ;
 D addcode^DBSRWUTL(1,"// Placeholder for type public",.LINENO)
 S NEWLIST="type public String "
 ;
 I RPTINFO("SEQBY",LASTLVL,"PAGEBRK") D addcode^DBSRWUTL(1,"set VH0=1"_TABCHR_"// Page break")
 ;
 ; Get non-dummy key references
 F I=1:1:LASTLVL D
 .	N COLUMN N TABLE N TC
 .	;
 .	S X=RPTINFO("SEQBY",I,"COL")
 .	Q:'$$validtcr^DBSRWUTL(X,.TC) 
 .	S VKEY(I)=ddmap(TC) ; Get map name
 .	; Get data type
 .	S TABLE=$piece(TC,".",1) S COLUMN=$piece(TC,".",2)
 .	N dbtbl1d S dbtbl1d=$$vRCgetRecord0Opt^RecordDBTBL1D("SYSDEV",TABLE,COLUMN,0,"")
 .	S VTYPE(I)=$P(dbtbl1d,$C(124),9)
 . Q 
 ;
 ; Save keybreak variables in vb1,vb2,...
 S CODE=""
 F I=1:1:LASTLVL S CODE=CODE_"vb"_I_","
 S CODE=$E(CODE,1,$L(CODE)-1)
 D addcode^DBSRWUTL(1,"type Number "_CODE)
 D addcode^DBSRWUTL(1,"set ("_CODE_")=0")
 ;
 ; Generate code for keybreaks
 S I="" S BRKCODE=1
 F  S I=$order(VKEY(I)) Q:I=""  D
 .	N K N NEXTLVL
 .	N V N VN
 .	;
 .	S V=VKEY(I) ; variable name
 .	S VN="vo"_V ; key name - last value
 .	S NEWLIST=NEWLIST_V_","_VN_","
 .	; Plus if numeric
 .	I "N$L"[VTYPE(I) S CODE="if vb"_I_"!(+"_VN_"'=+"_V_")"
 .	E  S CODE="if vb"_I_"!("_VN_"'="_V_")"
 .	;
 .	S NEXTLVL=$order(VKEY(I))
 .	Q:'NEXTLVL 
 .	S CODE=CODE_" set vs("_NEXTLVL_")=0,vh("_NEXTLVL_")=0,VD("_I_")=0"
 .	F K=I+1:1:LASTLVL S CODE=CODE_",vb"_K_"=1"
 .	I RPTINFO("SEQBY",I,"PAGEBRK") S CODE=CODE_",VH0=1"
 .	S BRKCODE(BRKCODE)=CODE S BRKCODE=BRKCODE+1
 .	Q 
 ;
 D addcode^DBSRWUTL(1,$E(NEWLIST,1,$L(NEWLIST)-1),LINENO)
 ;
 Q 
 ;
BLDPRNT(RPTINFO) ; Private - Build print section
 ; Was ^DBSRWBUF
 ;
 N CODE N TABCHR
 ;
 S TABCHR=$char(9)
 ;
 D addcode^DBSRWUTL(0,"")
 D addcode^DBSRWUTL(0,"VOM"_TABCHR_"// Output print line")
 ;
 ; Tape format - fixed length
 I RPTINFO("FIXLEN") D  Q 
 .	D addcode^DBSRWUTL(1,"type public Number VLC")
 .	D addcode^DBSRWUTL(1,"type public String IO,VL")
 .	D addcode^DBSRWUTL(0,"")
 .	D addcode^DBSRWUTL(1,"use IO")
 .	D addcode^DBSRWUTL(1,"#ACCEPT Date=10/13/2008;Pgm=RussellDS;CR=35741;Group=READ")
 .	D addcode^DBSRWUTL(1,"write VL_"""".justify("_RPTINFO("RSIZE")_"-VL.length()),!")
 .	D addcode^DBSRWUTL(1,"set VL="""",VLC=VLC+1")
 .	D addcode^DBSRWUTL(1,"quit")
 .	D addcode^DBSRWUTL(0,"")
 .	Q 
 ;
 ; Continue only if report is not fixed length
 ;
 D addcode^DBSRWUTL(1,"type public Number AUXPTR,vcrt,vlc,VLC,VRG")
 D addcode^DBSRWUTL(1,"type public String IO,VL")
 D addcode^DBSRWUTL(0,"")
 D addcode^DBSRWUTL(1,"use IO")
 D addcode^DBSRWUTL(0,"")
 ;
 I RPTINFO("REPEATSIZE") D
 .	D addcode^DBSRWUTL(1,"if VRG do VOM1 quit"_TABCHR_"// Store line image in print buffer")
 .	D addcode^DBSRWUTL(0,"")
 .	Q 
 ;
 D addcode^DBSRWUTL(1,"// Advance to a new page")
 I RPTINFO("PAGESIZE")>999 D addcode^DBSRWUTL(1,"use IO if 'VLC,'vcrt set $Y=1")
 E  D
 .	D addcode^DBSRWUTL(1,"if 'VLC,'vcrt do {"_TABCHR_"// Non-CRT device (form feed)")
 .	D addcode^DBSRWUTL(2,"#ACCEPT Date=10/13/2008;Pgm=RussellDS;CR=35741;Group=READ")
 .	D addcode^DBSRWUTL(2,"if 'AUXPTR.get() write 12.char(),!")
 .	D addcode^DBSRWUTL(2,"#ACCEPT Date=10/13/2008;Pgm=RussellDS;CR=35741;Group=READ")
 .	D addcode^DBSRWUTL(2,"else  write $$PRNTFF^%TRMVT,!")
 .	D addcode^DBSRWUTL(2,"set $Y=1")
 .	D addcode^DBSRWUTL(2,"}")
 .	D addcode^DBSRWUTL(0,"")
 .	Q 
 ;
 D addcode^DBSRWUTL(1,"#ACCEPT Date=10/13/2008;Pgm=RussellDS;CR=35741;Group=READ")
 D addcode^DBSRWUTL(1,"if vcrt<2 write VL,!"_TABCHR_"// Output line buffer")
 D addcode^DBSRWUTL(1,"if vcrt set vlc=vlc+1 do VBRSAVE(vlc,VL)"_TABCHR_"// Save in BROWSER buffer")
 D addcode^DBSRWUTL(1,"set VLC=VLC+1,VL="""""_TABCHR_"// Reset line buffer")
 D addcode^DBSRWUTL(1,"quit")
 D addcode^DBSRWUTL(0,"")
 ;
 ; Field overflow logic
 I RPTINFO("CUVAR","FLDOVF") D
 .	D addcode^DBSRWUTL(0,"VOMOF"_TABCHR_"// Display overflow print line")
 .	D addcode^DBSRWUTL(0,"")
 .	D addcode^DBSRWUTL(1,"type public String VL,VOFFLG,VLOF")
 .	D addcode^DBSRWUTL(0,"")
 .	D addcode^DBSRWUTL(1,"quit:VLOF.get()=""""")
 .	D addcode^DBSRWUTL(1,"set VL=VLOF")
 .	D addcode^DBSRWUTL(1,"do VOM")
 .	D addcode^DBSRWUTL(1,"set VLOF="""",VOFFLG=0")
 .	D addcode^DBSRWUTL(1,"quit")
 .	D addcode^DBSRWUTL(0,"")
 .	D addcode^DBSRWUTL(0,"VOFN(V,LOC,LN)"_TABCHR_"// Field Overflow Logic (Numeric or Currency)")
 .	D addcode^DBSRWUTL(0,"")
 .	D addcode^DBSRWUTL(1,"type public String VL,VLOF,VOFFLG")
 .	D addcode^DBSRWUTL(0,"")
 .	D addcode^DBSRWUTL(1,"if V.length()'>LN!VOFFLG!(VL="""") do {")
 .	D addcode^DBSRWUTL(2,"set VL=VL_"""".justify(LOC+LN-VL.length()-V.length())_V")
 .	D addcode^DBSRWUTL(2," set VOFFLG=0")
 .	D addcode^DBSRWUTL(2,"}")
 .	D addcode^DBSRWUTL(1,"else  do {")
 .	D addcode^DBSRWUTL(2,"set VLOF=VLOF_"""".justify(LOC+LN-V.length()-VLOF.length())_V")
 .	D addcode^DBSRWUTL(2,"set VOFFLG=1")
 .	D addcode^DBSRWUTL(2,"}")
 .	D addcode^DBSRWUTL(1,"quit")
 .	D addcode^DBSRWUTL(0,"")
 .	Q 
 ;
 ; Deal with repeat regions, e.g., labels
 I RPTINFO("REPEATSIZE") D
 .	;
 .	I RPTINFO("LINECNT")>1 D
 ..		; Box
 ..		D addcode^DBSRWUTL(0,"")
 ..		D addcode^DBSRWUTL(0,"VOM1"_TABCHR_"//")
 ..		D addcode^DBSRWUTL(1,"type public Number vcrt,vlc,VLC,VR,VRF(),VRG,VSEQ")
 ..		D addcode^DBSRWUTL(1,"type public String VL")
 ..		D addcode^DBSRWUTL(1,"type Number DONE,I")
 ..		D addcode^DBSRWUTL(1,"set DONE=0")
 ..		D addcode^DBSRWUTL(1,"for  do { quit:DONE")
 ..		D addcode^DBSRWUTL(2,"if VR<"_(RPTINFO("REPEATCNT")+1)_" do { quit")
 ..		D addcode^DBSRWUTL(3,"if VR>1 set VRF(VSEQ)=VRF(VSEQ)_"""".justify(((VR-1)*"_RPTINFO("REPEATSIZE")_")-VRF(VSEQ).length())")
 ..		D addcode^DBSRWUTL(3,"set VRF(VSEQ)=VRF(VSEQ)_VL,VL="""",VSEQ=VSEQ+1")
 ..		D addcode^DBSRWUTL(3,"set DONE=1")
 ..		D addcode^DBSRWUTL(3,"}")
 ..		D addcode^DBSRWUTL(2,"for I=1:1:"_RPTINFO("LINECNT")_" do {")
 ..		D addcode^DBSRWUTL(2,"#ACCEPT Date=10/13/2008;Pgm=RussellDS;CR=35741;Group=READ")
 ..		D addcode^DBSRWUTL(3,"if vcrt<2 write VRF(I),!")
 ..		D addcode^DBSRWUTL(3,"if vcrt set vlc=vlc+1 do VBRSAVE(vlc,VRF(I))")
 ..		D addcode^DBSRWUTL(3,"set VRF(I)=""""")
 ..		D addcode^DBSRWUTL(3,"}")
 ..		D addcode^DBSRWUTL(2,"set VLC=VLC+"_RPTINFO("LINECNT"))
 ..		Q 
 .	E  D
 ..		;
 ..		D addcode^DBSRWUTL(0,"VOM1"_TABCHR_"// Repeat group print logic")
 ..		D addcode^DBSRWUTL(1,"type public Number vcrt,vlc,VLC,VR,VRG")
 ..		D addcode^DBSRWUTL(1,"type public String VL,VRF")
 ..		D addcode^DBSRWUTL(1,"type Number DONE=0")
 ..		D addcode^DBSRWUTL(1,"for  do { quit:DONE")
 ..		D addcode^DBSRWUTL(2,"if VR<"_(RPTINFO("REPEATCNT")+1)_" do { quit")
 ..		D addcode^DBSRWUTL(3,"if VR>1 set VRF=VRF_"""".justify(((VR-1)*"_RPTINFO("REPEATSIZE")_")-VRF.length())")
 ..		D addcode^DBSRWUTL(3,"set VRF=VRF_VL,VL=""""")
 ..		D addcode^DBSRWUTL(3,"set DONE=1")
 ..		D addcode^DBSRWUTL(3,"}")
 ..		D addcode^DBSRWUTL(2,"#ACCEPT Date=10/13/2008;Pgm=RussellDS;CR=35741;Group=READ")
 ..		D addcode^DBSRWUTL(2,"if vcrt<2 write VRF,!")
 ..		D addcode^DBSRWUTL(2,"if vcrt set vlc=vlc+1 do VBRSAVE(vlc,VRF)")
 ..		D addcode^DBSRWUTL(2,"set VLC=VLC+1,VRF=""""")
 ..		Q 
 .	;
 .	D addcode^DBSRWUTL(2,"if VR=999 set VR=0,VRG=0,DONE=1"_TABCHR_"// End of report")
 .	D addcode^DBSRWUTL(2,"set VR=1"_TABCHR_"// Reset repeat field buffer")
 .	D addcode^DBSRWUTL(2,"}")
 .	D addcode^DBSRWUTL(0,"")
 .	D addcode^DBSRWUTL(1,"quit")
 .	D addcode^DBSRWUTL(0,"")
 .	D addcode^DBSRWUTL(0,"")
 .	D addcode^DBSRWUTL(0,"VOM2"_TABCHR_"// Flush print buffer")
 .	D addcode^DBSRWUTL(1,"type public Number VR,VRG")
 .	D addcode^DBSRWUTL(1,"type public String VL")
 .	D addcode^DBSRWUTL(1,"if VL="""",'VR quit")
 .	D addcode^DBSRWUTL(1,"if VR set VRG=1,VR=999")
 .	D addcode^DBSRWUTL(1,"do VOM")
 .	D addcode^DBSRWUTL(1,"quit")
 .	D addcode^DBSRWUTL(0,"")
 .	Q 
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61288^63985^Dan Russell^31525" ; Signature - LTD^TIME^USER^SIZE
 ;
vOpen1() ; DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:TABLE AND POS=1
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(TABLE) I vos3="" G vL1a0
 S vos4=""
vL1a4 S vos4=$O(^DBINDX("SYSDEV","STR",vos3,vos4),1) I vos4="" G vL1a0
 S vos5=""
vL1a6 S vos5=$O(^DBINDX("SYSDEV","STR",vos3,vos4,1,vos5),1) I vos5="" G vL1a4
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S dbtbl1d="" Q 0
 ;
 S dbtbl1d=$S(vos5=vos2:"",1:vos5)
 ;
 Q 1
