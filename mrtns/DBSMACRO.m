DBSMACRO(expr)	;;DBS - UTL - V5.0 - Data Qwik Macro Command Interpretor
	;;Copyright(c)2003 Sanchez Computer Associates, Inc.  All Rights Reserved - 03/04/03 16:08:19 - CHENARDP
	;     ORIG:  FSANCHEZ - 13 AUG 1991
	;     DESC:  Screen MACRO command parser
	;
	;
	; ARGUMENTS:
	;
	;     . expr  Screen MACRO command expression
	;
	;     macro ::=				expr ::=
	;
	;	CHANGE	expr			TBL | MIN | MAX | REQ | PAT
	;	DEFAULT ddref value /UX         ddref
	;	DELETE	expr /UX		ALL | ddref
	;	DISPLAY expr value		ALL | ddref
	;	GOTO	expr			END | NEXT | ddref
	;	PROTECT expr			ALL | ddref
	;	UNPROT  expr			ALL | ddref
	;I18N=OFF
	;---- Revision History -------------------------------------------------
	; 07/31/06 - Pete Chenard - CR22438
	;	     Corrected parameters passed to CUP^%TRMVT. 
	;	     Replaced occurances of $A with $$BSASCII^SQLUTL
	;
	; 04/26/06 - Allan Mattson - CR20048
	;            Modified function $$CUP to call $$CUP^%TRMVT in order to
	;            resolve problems with terminal emulation in a Unicode
	;            environment.
	;
	;            Deleted pre-2006 revision history.
	;
	; 04/14/06 - Pete Chenard CR19883
	;	     Corrects problem in RETVAL section to use current screen
	;	     object.
	;
	; 02/22/06 - Pete Chenard CR19551
	;	     Modified DISPAY and DEFAULT sections to use $G around 
	;	     value parameter, as it is not required and may not be 
	;	     passed in.
	;
	; 01/26/06 - Pete Chenard - CR19036
	;	     Fixed error in SETVAL and RETVAL sections when reading from
	;	     or writing to a variable (as opposed to an actual column).
	;-----------------------------------------------------------------------
	;
	N tree,CMD
	;
	S ER=0 D ^DBSINT(expr,"smac(") I ER Q
	;
	S tree=$O(tree(""),-1)
	F CMD=1:1:tree D @tree(CMD)
	Q
	;
	;----------------------------------------------------------------------
CHANGE(expr,value)	;Public; Change the value of a field attribute
	;
	; ARGUMENTS:
	;     . expr    Field keyword			/TYP=T/REQ/MECH=VAL
	;
	;               Valid keyword:
	;
	;                              MIN     Minimum value
	;                              MAX     Maximum value
	;                              TBL     Lookup table
	;			       PAT     Pattern check syntax
	;                              DEC     Decimal Precision
	;                              REQ     Required indicator	
	;
	;     . value   Value to be used to replace this field attribute
	;                                               /TYP=T/REQ/MECH=VAL
	; EXAMPLE:
	;
	;     D CHANGE^DBSMACRO("TBL","^XCLS")
	;     D CHANGE^DBSMACRO("REQ")
	;----------------------------------------------------------------------
	;
	I $G(%TAB) D  Q					; New screen version
	.	I expr="MIN" S vi(7)=value Q
	.	I expr="MAX" S vi(8)=value Q
	.	I expr="TBL" S vi(3)=value Q
	.	I expr="PAT" S vi(4)=value Q
	.	I expr="DEC" S vi(9)=value Q
	.	I expr="REQ" S vreq=1 Q                  ; *** BC 10/17/94
	;
	I expr="MIN" S I(7)=value Q
	I expr="MAX" S I(8)=value Q
	I expr="TBL" S I(3)=value Q
	I expr="PAT" S I(4)=value Q
	I expr="DEC" S I(9)=value Q
	I expr="REQ" S E5=1 Q
	Q
	;
	;----------------------------------------------------------------------
COMPUTE(expr)	;Public; Compute 
	;----------------------------------------------------------------------
	;
	I $E("ALL",1,$L(expr))=expr D VCOMP^@PGM
	;
	Q
	;
	;----------------------------------------------------------------------
DEFAULT(ddref,value,ux,nullonly,chgonly)	; Default and display a value 
	;----------------------------------------------------------------------
	;
	I $G(chgonly),X=V Q			; No Change to current field
	I '$D(ux) S ux=1			; Insert in update array
	I '$D(nullonly) S nullonly=0		; Execute if null value only
	S value=$G(value)
	N cv
	;I nullonly!ux S cv=$$RETVAL(ddref)	; Get current value of data
	S cv=$$RETVAL(ddref)	; Get current value of data
	;
	; Invalid macro command ~p1
	N TEMP
	S TEMP=".DEFAULT. "_ddref
	I ER S RM=$$^MSG("1397",TEMP) Q
	;
	I nullonly,cv'="" Q			; Update if null 
	;
	D SETVAL(ddref,value)			; Set new value into array
	;
	N ni
	S ni=$$TAB(ddref)			; Get field number
	D UX(cv,value,ux)			; Update UX() array
	I ni D DSP(value,ni) I value'="" K REQ(ni)
	Q
	;
	;----------------------------------------------------------------------
DELETE(ddref,ux,chgonly)	; Change the Value of a field to null
	;
	;                         .DELETE. ALL
	;                         .DELETE. [fid]di
	;                         .DELETE. @field_tag
	;----------------------------------------------------------------------
	;
	I $G(chgonly),X=V Q			; Skip if no Change
	;
	I $E("ALL",1,$L(ddref))=ddref D DELALL Q  ; Delete all
	;
	I '$D(ux) S ux=0			; Insert in update array
	N cv,ni
	I $E(ddref)'="@",($$NOD^DBSDD(ddref)?1N1"*") Q		; *** XUS 10/13/94    Access key
	S cv=$$RETVAL(ddref)			;Get Current Value
	; Invalid macro command ~p1
	N TEMP
	S TEMP=".DELETE. "_ddref
	I ER S RM=$$^MSG(1397,TEMP) Q
	;
	I cv="" Q				; No action
	I cv'="" D SETVAL(ddref,"")		; Set field to a null value
	;
	S ni=$$TAB(ddref)			; Get field number
	D UX(cv,"",ux)				; Update UX() array ; JMB - 49022
	I ni D DSP("",+ni) Q			; Display ______ at field ni
	Q
	;
DELALL	; ---------- Delete all fields on the screen
	;
	I '$D(vtab) D VTAB Q:'$D(vtab)
	;
	S ddref=""
	F  S ddref=$O(vtab(ddref)) Q:ddref=""  D DELETE(ddref)
	Q
	;
	;----------------------------------------------------------------------
DISPLAY(ddref,value,chgonly)	; Display a value on screen
	;
	;                         .DISPLAY. [fid]di=value / @field_tag
	;                         .DISPLAY. [fid]di
	;
	;----------------------------------------------------------------------
	;
	I $G(vdsp)=0 Q				; Output turned off in batch mode
	I $G(chgonly),X=V Q			; No Change to current field
	S value=$G(value)
	;
	; ---------- If no value defined, displays current value
	;
	I $E("ALL",1,$L(ddref))=ddref S vdsp=2 D VDA^@PGM,^DBSPNT(0,2) Q
	;
	N NI S NI=$$TAB(ddref) I 'NI Q		; Not on the current screen
	;
	I value'="" D DSP(value,NI) Q		; .DISPLAY. [DIF]DI=v
	;
	D DSP($$RETVAL(ddref),NI) Q		; .DISPLAY. [FID]DI
	Q
	;
	;----------------------------------------------------------------------
GOTO(expr)	;                  Move cursor to a new location 
	;
	;                      .GOTO. END
	;                      .GOTO. NEXT
	;                      .GOTO. [fid]di
	;                      .GOTO. @field_tag
	;----------------------------------------------------------------------
	;
	I $E("END",1,$L(expr))=expr S NI=%MAX Q  ; Go to end of the screen
	I $E("NEXT",1,$L(expr))=expr DO  Q
	.	;
	.	I $G(%MOD) S NI=NI+%MOD-1 Q  ;	Go to next line (repeat group)
	.	S NI=NI+1 Q  ;			Skip next field
	;
	N ni S ni=$$TAB(expr) I ni S NI=ni-1 Q  ;  Go to [fid]di
	;
	Q
	;
	;----------------------------------------------------------------------
PROTECT(expr)	; Protect fields
	N ni,x
	I $E("ALL",1,$L(expr))=expr D  K REQ Q
	.	S ni=""
	.	F  S ni=$O(%TAB(ni)) Q:ni=""  I +ni,%TAB(ni)'="" DO
	..		S x=%TAB(ni) I $E(x,4)>4 Q	; *** BC - Modified to setup protection flag
	..		S %TAB(ni)=$E(x,1,3)_($E(x,4)+5)_$E(x,5,999)
	;
	S ni=$$TAB(expr)
	I 'ni Q						; Item not on screen
	I %TAB(ni)="" S %TAB(ni)=$$TAB^DBSCRT8(ni) 	; In repeat region
	;                                               ; *** 01/24/95 BC 
	I ni K REQ(ni) S x=%TAB(ni) I $E(x,4)<5 S %TAB(ni)=$E(x,1,3)_($E(x,4)+5)_$E(x,5,999)
	Q
	;----------------------------------------------------------------------
UNPROT(expr)	; Unprotect fields
	;----------------------------------------------------------------------
	;
	N ni,x
	I $E("ALL",1,$L(expr))=expr D  Q
	.	S ni=""
	.	F  S ni=$O(%TAB(ni)) Q:ni=""  I +ni,%TAB(ni)'="" DO
	..		S x=%TAB(ni) I $E(x,4)<5 Q  ; *** BC - Modified to remove protection flag
	..		S %TAB(ni)=$E(x,1,3)_($E(x,4)-5)_$E(x,5,999)
	;
	N ni S ni=$$TAB(expr)
	I 'ni Q					; *** 01/23/95 BC
	S x=%TAB(ni) I x="" S %TAB(ni)=$$TAB^DBSCRT8(ni),x=%TAB(ni)
	I $E(x,4)>4 S %TAB(ni)=$E(x,1,3)_($E(x,4)-5)_$E(x,5,999)
	Q
	;
	;----------------------------------------------------------------------
TAB(ddref)	; Find this reference in %TAB
	;----------------------------------------------------------------------
	; 
	I '$D(vtab) D VTAB
	I "[@"[$E(ddref) S ddref=$$REFCNV(ddref)
	;
	N z S z=$G(vtab(ddref))
	I '$G(NI) Q z				; Data entry pre-processor
	I $G(%TAB) Q $$TABCS			; *** 06/06/94 BC
	I NI'>$G(%MODOFF) Q z			; Outside repeat region
	I '$D(z1)!'$G(%MOD)!(z'>%MODOFF) Q z	; Return %TAB of reference
	;
	Q (z1-%MODS)*%MOD+z			; Repeat region
	;----------------------------------------------------------------------
TABCS()	;
	N i
	I '$G(%REPEAT) Q z			; Non-repeat region items
	;					; *** 02/05/97
	F i=1:1:$L(z,"|") I $P(z,"|",i)'<NI Q	; Next match from the current
	Q $P(z,"|",i)				; location
	;
	;----------------------------------------------------------------------
VTAB	; Build table cross reference	vtab(tag)=ni
	;                                    tag=@var or fid.di
	;----------------------------------------------------------------------
	;       piece 2       Piece 3             source
	;    -------------------------------------------------------------
	;       *VAR          [*]@TAG      UTLREAD or screen variable
	;       *VAR          [fid]di      UTLREAD with documentation ptr
	;                                  or screen with computed item
	;       NULL          [fid]di      Screen with data on access key
	;       node          [fid]di      Screen with data with unique field 
	;       1*            [fid]di      Access keys 
	; 
	I '$D(%TAB) Q
	;
	N ni,tbl,col,X,p2,p3,z
	F ni=$O(%TAB("")):1:%MAX DO
	.	;
	.	S X=%TAB(ni) I X="" Q  ;		Repeat Region
	.	;
	.	S p2=$P(X,"|",2),p3=$P(X,"|",3)
	.	I p3?1"[*]@"1E.E D  Q                   ; [*]@TAG
	..           S z=$P(p3,"]",2,9)                 ; *** 01/31/97 
	..           I '$D(vtab(z)) S vtab(z)=ni Q 
	..           S vtab(z)=vtab(z)_"|"_ni Q  ; 
	.       ; 
	.	S tbl=$P(p3,"]",1),col=$P(p3,"]",2)
	.	I col="" Q
	.	I $E(tbl)="[" S tbl=$E(tbl,2,999) 
	.	I $E(tbl)="*" S tbl=""
	.	I tbl'="",col'="",p2?1"*"1E.E s vtab("@"_$E(p2,2,99))=ni
	.	I tbl["," S tbl=$P(tbl,",",2) ;	Library syntax included
	.	I tbl'="" S col=tbl_"."_col
	.	;
	.	I '$D(vtab(col)) S vtab(col)=ni Q
	.	S vtab(col)=vtab(col)_"|"_ni
	Q
	;
	;----------------------------------------------------------------------
DSP(X,ni)	; Display string X at position ni
	;----------------------------------------------------------------------
	;
	I $G(vdsp)=0 Q
	;
	N tb,v1,len
	S v1=X,tb="T"
	; ---------- Format data based on field data type
	;
	I '$G(%TAB) S tb=$$TAB^DBSCRT8(ni)
	E  S tb=%TAB(ni)			; ***
	I $E(tb,6)="L"!((X'=""&("UTF"'[$E(tb,6)))) S v1=$$EXTYP^DBSCRT8(X,$E(tb,6),$P(tb,"|",10)) ;fmt,dec (format data)
	;
	;              length   format   DY       DX
	;
	S len=$$BSASCII^SQLUTL(tb,3)					; *** 05/13/94 - BC -
	I $L(v1)>len S v1=$E(v1,1,len-1)_$C(14,96,15)   ; Display field overflow
	W $$PNTFMT(v1,len,$E(tb,6),$$BSASCII^SQLUTL(tb,1)+1,$$BSASCII^SQLUTL(tb,2)+1)	; indicator
	Q
	;
	;----------------------------------------------------------------------
UX(old,new,ux)	; Set up update array
	;	ux = 1 set UX as usual
	;	ux = 0 set UX as usual plus set piece 5=1 to indicate to not 
	;	       file changes into database (replaces /NOUX functionality)
	;----------------------------------------------------------------------
	I $G(%TAB) Q				; *** BC - 07/21/94
	;
	S ux=$G(ux)				;pc 4/2/02
	I '$G(%O),'$D(vux) Q	  		; Set up in Modify mode only
	I old=new Q				; *** BC - Skip UX logic
	;					; *** added vdf,vlen to list
	N I,V,X,DATA,E4,E5,E67,E8,E9,E12,SFD,TYP,vfid,vsn,vhdr,NI,vdi,vsf,vlen
	;
	I 'ni DO  Q  ;			Not on the current screen
	.	;
	.	S X=$$DI^DBSDD(ddref) ; Item attributes
	.	I X="" Q
	.	S SFD=$P(X,"|",18)	;sub-field info
	.	S TYP=$P(X,"|",9)	;data type
	.	S I=$$REFCNV(ddref)			; *** BC - 11/23/93
	.	S vfid=$P(I,".",1),vdi=$P(I,".",2)
	.	;Piece 5 of UX indicates whether to file into history (0) or not (1)
	.	S UX(vfid,vdi)=old_"|"_new_"|"_$P(X,"|",1)_"|"_$P(X,"|",21)_"|"_'ux_"||||"_TYP_"|"_SFD
	.	;
	S NI=ni
	D RESET^DBSCRT8(ni) ;		Get field attribute
	;
	S V=old,X=new ;			Define old and new data
	;
	D SETUX^DBSCRT8 ;		Update or delete UX array
	Q:ux				;
	;
	; The following is only done if /NOUX is used.
	S I=$$REFCNV(ddref)
	S vfid=$P(I,".",1),vdi=$P(I,".",2)
	S $P(UX(vfid,vdi),"|",6)=1  ;don't file in history
	Q
	;
	;----------------------------------------------------------------------
SETVAL(ref,value)	; Set Value into @ref
	;----------------------------------------------------------------------
	;
	I '$D(vtab) D VTAB				; %TAB()/NI index table
	;
	I "[@"[$E(ref) S ref=$$REFCNV(ref)		; Internal reference
	;
	I '$D(vtab(ref)),$E(ref)="@" DO  Q		; Not defined on current
	.	; Invalid macro command tag name ~p1
	.	S ER=1,RM=$$^MSG("1399",ref)		; screen
	;
	I '$G(%TAB),'$D(vtab(ref)) DO  Q				; Set into local name
	.	I $G(vPSL),$G(PGM)'="UTLREAD" DO
	..		N DI,FID,Z
	..		I ref["[" do
	...			S DI=$P(ref,"]",2)
	...			S FID=$P($P(ref,"]",1),"[",2)
	..		E  D
	...			S DI=$P(ref,".",2)
	...			S FID=$P(ref,".",1)
	..		Q:FID=""!(DI="")
	..		I '$D(fsn(FID)) D fsn^DBSDD(.fsn,FID)
	.. 	S Z="vSET^"_PGM_"(FID,DI,value)"
	.. 	D @Z
	.	E  D SETVAL^DBSDD(ref,value,"","","","",$G(z1))
	;
	I '$G(%TAB),$G(vkeyb),$G(vtab(ref)) D			; Patch into <PF1><REMOVE>
	.	;
	.       N ni,zval
	.	S ni=$$TAB(ref)				; *** 06/30/95 BC
	.	S zval=value				; Store external format
	.	I zval,$E(%TAB(ni),6)="D" S zval=$$EXT^%ZM(zval,"D")
	.	I '$D(vdft(ni)) S vdft(ni)=zval_"|"_$G(cv) Q
	.	S vdft(ni)=zval_"|"_vdft(ni)
	;						
	I $G(%TAB) D  Q					; Save data in buffer
	.	N di
	.	S di=$P(ref,".",2)
	.	I '$D(vhis(vfrm,vrec,di)) s vhis(vfrm,vrec,di)=$G(vbuf(vfrm,vrec,di))
	.	S vbuf(vfrm,vrec,di)=value
	;
	; set value into vobj array
	I $E(ref)'="@",$G(vPSL),$G(PGM)'="UTLREAD" DO  	; DQ screen PSL
	.	N ni,DI,FID,Z
	.	S ni=$$TAB(ref)
	.	S Z=$$TAB^DBSCRT8(ni)
	.	S DI=$P(Z,"|",3)
	.	S DI=$P(DI,"]",2)
	.	S FID=$P($P(Z,"]",1),"[",2)
	.	I '$D(fsn(FID)) D fsn^DBSDD(.fsn,FID)
	.	S Z="vSET^"_PGM_"(FID,DI,value)"
	.	D @Z
	;
	E  S ref=$$REF(ref) X "S "_ref_"=value"		; Put value into ref
	;
	Q
	;
	;----------------------------------------------------------------------
RETVAL(ref)	; Return Value for ref
	;----------------------------------------------------------------------
	;
	N zzz
	S ER=0
	I '$D(vtab) D VTAB
	;
	I "[@"[$E(ref) S ref=$$REFCNV(ref)
	;
	I '$D(vtab(ref)),$E(ref)="@" S ER=1 Q ""	; Invalid DI reference
	I '$D(vtab(ref)),'$G(%O) Q ""			; NULL value
	I '$D(vtab(ref)) Q $$RETVAL^DBSDD(.ref)		; Get it from disk
	;
	I $E(ref)'="@",$G(vPSL),$G(PGM)'="UTLREAD" DO  Q V  ; DQ screen PSL
	.	N DI,FID,ni,Z
	.	S ni=$$TAB(ref)
	.	S Z=$$TAB^DBSCRT8(ni)
	.	S DI=$P(Z,"|",3)
	.	S DI=$P(DI,"]",2)
	.	S FID=$P($P(Z,"]",1),"[",2)
	.	I '$D(fsn(FID)) D fsn^DBSDD(.fsn,FID)
	.	S Z="S V=$$vREAD^"_PGM_"(FID,DI)"
	.	X Z
	;
	I $G(%TAB) Q $G(vbuf(vfrm,vrec,$P(ref,".",2)))	; *** BC - 07/21/94
	;						; ***
	S zzz=$$REF(ref)
	I zzz?1A.AN S zzz="$G("_zzz_")"
	X "S ref="_zzz
	Q ref
	;
	;----------------------------------------------------------------------
REFCNV(ref)	; Convert [fid]di -> fid.di    @var -> @var(z1)
	;----------------------------------------------------------------------
	;
	I $E(ref)="[" Q $TR($E(ref,2,$L(ref)),"]",".")
	;
	Q ref
	;
	;----------------------------------------------------------------------
REF(ref)	; Data Item Local Array Reference returned locally
	;----------------------------------------------------------------------
	;
	N node,del,pc,repeat,X
	;
	S repeat=0
	I $D(%MODOFF),vtab(ref)>%MODOFF S repeat=1	; In Repeat Region ?
	S %MODOFF=$G(%MODOFF)
	;
	S X=$$TAB^DBSCRT8(vtab(ref)) ;			Get %TAB attributes
	S node=$P(X,"|",2),del=$E(X,7,9),pc=$E(X,10,11)
	;
	I $E(node)="*" D
	.	S ref=$E(node,2,999)			; Local variable
	.       I repeat S ref=$P(ref,"(",1)		; Remove (1) ref
	E  S ref=VFSN($P(ref,".",1))			; File short name
	I $G(%MOD),NI>%MODOFF,repeat S node=z1 ; Repeat region
	I node'="",$E(node)'="*" S ref=ref_"("""_node_""")"
REF1	;
	I del S ref="$P("_ref_","""_$C(del)_""","_+pc_")"
	Q ref
	;
	;----------------------------------------------------------------------
PNTFMT(X,len,typ,py,px)	; Display formatted string
	;----------------------------------------------------------------------
	;
	Q $$CUP_$S("TUFLDC"[typ!(X=""):X_$$UL(len-$L(X)),1:$J(X,len))
UL(L)	Q $E("_________________________________________________________________________________",1,L)
CUP()	Q $$CUP^%TRMVT(px,py)
	;
	;----------------------------------------------------------------------
FMTABLE(DDREF)	; Return File Maintenance Description Table
	;----------------------------------------------------------------------
	;
	; ARGUMENTS:
	;     . DDREF   Data Item Reference		/TYP=T/REQ/MECH=VAL
	;		Must be in FID.DI format (ex. DEP.IACM)
	;
	; EXAMPLE:
	;		S $P(UX(FID,DI),"|",11)=$$FMTABLE^DBSMACRO(FID_"."_DI)
	;
	;----------------------------------------------------------------------
	;
	N ER,FMTABLE,RM,TBL,TBLFID
	;
	; get look-up table for data item
	S TBL=$P($$DI^SQLDD(DDREF),"|",5)
	I '((TBL["[CTBL")!(TBL["[STBL")!(TBL["[UTBL")) Q ""
	;
	S TBLFID=$E($P(TBL,"]",1),2,999)
	; get file maintenance description table
	S FMTABLE=$P($$DI^SQLDD(TBLFID_".FMDESC"),"|",16)
	;
	; if none, quit
	I FMTABLE="" Q ""
	;
	D fsn^SQLDD(.fsn,TBLFID)
	;
	; [TABLE] and Keys(nolits) (ex. [STBLIACM]IACM)
	Q $P(FMTABLE,"]",1)_"]"_$P(fsn(TBLFID),"|",3)
