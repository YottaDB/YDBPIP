DBSCRT8	;; DATA-QWIK Input Parser
	;;Copyright(c)2003 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/07/03 11:08:55 - CHENARDP
	;     ORIG:  Frank R. Sanchez (2497)
	;
	; Data entry utility for V**S*** screens
	;
	;   I18N=QUIT: Excluded from I18N Standards
	;---- Revision History -------------------------------------------------
	;
	; 08/21/07 - Vertliba - CR28077
	;	     The Variable "vni" is Newed at the top to avoid the
	;            <UNDEFINED> error in Tax ID lookup when Customer 
	;            Number entered as a [*]. 
	;
	; 07/14/06 - RussellDS - CR22121
	;	     Replaced $A references with $$BSASCII^SQLUTL and $C with
	;	     $$BTYECHAR^SQLUTL to ensure Unicode compliance.
	;
	; 12/16/05 - RussellDS - CR18400
	;	     Removed call to TYPERR^DBSVER.
	;
	;	     Modified call to VAL^DBSVER to pass GDSP as a parameter to
	;	     eliminate as public scope variable.
	;
	; 03/23/05 - Pete Chenard - 14146
	;	     Modified to only reference @DATA if it is working
	;	     with a screen that was compiled with the native
	;	     screen compiler.  Under the new PSL compiler, this
	;	     variable is no longer used.
	;
	; 03/03/03 - Pete Chenard - 49451
	;	     Modified to call back into the screen program (PGM)
	;	     to read/set the vaues from/to the vobj object for screens
	;	     that are compiled for PSL. 
	;
	; 03/19/02 - Pete Chenard - 49515
	;	     Modified SETUX section to set the data type and the
	;	     subfield information into pieces 9 and 10 of the UX
	;	     array.  This is used in DBSEXECC to ensure a record
	;	     has not been changed while another process is modifying
	;	     it.
	;
	; 05/24/01 - MATTSONA - 44311:1
	;            Modified previous change to prevent Effective Date and
	;            Teller Key fields from being skipped on the Teller
	;            screen.
	;
	; 05/08/01 - MATTSONA - 44311
	;	     Added a call to CUD in section EXEC for both the Enter and
	;	     Down Arrow keys so the description message at the bottom of
	;	     the screen displays an unprotected field's description 
	;	     rather than the protected field's message.  This is called
	;	     after the variable E4 (protection flag) is set up.
	;
	; 04/10/01 - SISONG - 44204 
	;            Replaced "$D(RM)" with "$G(RM)'=""" in section READ to 
	;            fix problem on description not showing at the bottom 
	;            page when running @OVR001 
	;
	; 05/12/00 - DOUGANM- 39582 
	;            To improve the performance of error handling, cleaned up 
	;            call to $$NEW^%ZT, and removed use of indirection. 
	;
	; 07/15/99 - Chiang - 34007
	;            Modified to not allow comma as the thousand separator in
	;            the input value if it is also the decimal separator.
	;
	;	     Removed old revision history.
	;
	; 02/23/98 - BECKERW - 27566
	;            Replaced "Q NI-1" with "Q $A(vgoto)-1" in section CUU.
	;	     This was causing an infinite loop when cursoring up
	;	     through a screen that has most of its fields protected.
	;
	; 08/11/97 - Betty Ni - 25653
	;            Replaced follows operator "]" with a "]]". 
	;
	; 04/16/97 - HYCHKOS - 24415
	;	     Modified VDSP section to not overwrite a null value
	; 	     with a justified null.  ie. 0.0
	;
	;-----------------------------------------------------------------------
	;
	N vcsi,vbtm,vext,vkeyb,validate,vdft,vsf,vsn,vdsp,vfid,vhdr,vexit,vgoto
	N vkill,vlen,vjrnl,vni,vptr,V,E4,E5,E67,E8,E12,DATA,I,N,NI,z
	;
	I '$D(%MSKN) N %MSKD,%MSKC,%MSKE,%MSKL,%MSKN D INIT^%ZM()
	;
	; *** Allow 1,000,000 inputs and display on this screen *** 07/15/99
	I $P($G(VO),"|",4) S z=$G(%MSKE) N %MSKE S:z="" z="." S:($L(z)=1)&(z'=",") z=z_"," S %MSKE=z
	;
	I '$D(%PG) N %PG S %PG=1
	I '$D(%MODOFF) N %MODOFF S %MODOFF=""
	I '$D(%MODGRP) N %MODGRP S %MODGRP=1
	;
	S validate=1,vext=1				; Validate field entry
	S vdsp='($G(%OPMODE)["NOO"),vkeyb=vdsp		; Keyboard, display flag
	I vdsp S vcsi=$$CSI^%TRMVT,vbtm=$$BTM^%TRMVT
	;
	I $G(%IPMODE)'="" D ^DBSCRTNL(%MAX,1) Q:ER  I $D(vdft),vdsp D DSPVDFT^DBSCRT()
	I $G(%NOPRMT)="Q" D ^DBSCRT8A Q
	;
	I vkeyb D ZBINIT^DBSCRT ;			Initialize keypad
	;
	S vgoto="",vjrnl="",vexit=0,%fkey="ENT"
	;
	S NI=$O(%TAB(""))-1 ;				Initialize %TAB pointer
	;
	;----------------------------------------------------------------------
EXEC	; 			Loop through %TAB
	;----------------------------------------------------------------------
	;
	S NI=NI+1 ; 					Increment %TAB pointer
	I NI>%MAX Q:$$EXIT  G EXEC
	I '$D(%TAB(NI)) G EXEC
	;
	D RESET(NI) I E4>1 G EXEC	;ACM 44311:1
	D READ
	I $D(vni) S NI=vni K vni ;			Restore new NI variable
	G EXEC
	;
	;----------------------------------------------------------------------
READ	; Input from terminal or array and process %TAB(NI)
	;----------------------------------------------------------------------
	;
	I $D(vkill) K @("vkill"_vkill) ;		Kill use variables
	S ER=0
	;
	I E4<3 S vgoto=$$BYTECHAR^SQLUTL(NI)_vgoto	; Build entry path
	;
	; Replace $D(RM) with $G(RM)'="" 
	I I(6)'="" D XPRE I $G(RM)'="" D REPLY          ; Pre processor 
	;
	S X=$S($D(vdft(NI)):$P(vdft(NI),"|",1),(V="")&(E8'="L"):"",1:$$EXT^%ZM(V,E8,I(9)))
	;
	I 'vkeyb D PROCESS G ERROR:ER Q			; Not interactive
	I vexit>NI D PROCESS G ERROR:ER Q		; Drop through
	;
	I E4<2 D ^DBSCRT(X,E67,E8,I(3),I(2),I(9),I(7),I(8),$$BSASCII^SQLUTL(vhdr,1),$$BSASCII^SQLUTL(vhdr,2),E4,vlen)
	;
	N protall
	I %fkey="CUU" D  Q:protall
	.	N nii,x
	. S nii="",protall=1
	. F  S nii=$O(%TAB(nii)) Q:nii=""  I +nii,%TAB(nii)'="" D  Q:protall=0	;8/26/96 MAS
	..              S x=%TAB(nii) I $E(x,4)<2 S protall=0   
	.	I 'protall,nii>NI S %fkey="CUD"         ;8/26/96 MAS
	I %fkey="CUU",X=""!(vptr=0) S NI=$$CUU Q  	; Cursor up one field
	I %fkey="PUP" D  I ER G ERROR			; Previous screen
	.	I $D(vNOPREV) S ER=1,RM=$$PUPERR	; *** 11/29/94 BC
	.	S vexit=$$VEXIT(%MAX+1)
	I %fkey="ESC" S NI=%MAX,vexit=$$VEXIT(%MAX+1) Q
	I %fkey="END"!(%fkey="PDN") S vexit=$$VEXIT(%MAX+1)
	;
	D PROCESS I ER G ERROR				; Stay on current field
	;
	I vdsp=2,E4'=4 D VDSP
	;						; *** 02/17/97 Display table description
	I $G(validate),E8'="F",X'="",I(3)'="",'$D(vline24) W vbtm,$E(GDSP,1,70)
	;
	I %fkey="CUU" D  Q:protall
	.	N nii,x
	. S nii="",protall=1
	. F  S nii=$O(%TAB(nii)) Q:nii=""  I +nii,%TAB(nii)'="" DO
	..              S x=%TAB(nii) I $E(x,4)<2 S protall=0   
	I %fkey="CUU" S NI=$$CUU Q  			;Cursor up
	I %fkey="CUD" D CUD				;Cursor down
	Q
	;
	;----------------------------------------------------------------------
PROCESS	; Internal format, post processor, validate & set data
	;----------------------------------------------------------------------
	I X'="","TF"'[E8,vext S X=$$INT^%ZM(X,E8,,I(9)) I ER S RM=$$TYPERR(E8) Q
	;
	;  patch the Validation flags if offline
	I '$$ONLINE() D  
	.	S E5=$S(%O:0,1:0),I(3)="",I(4)=""	; *** 10/22/96
	;
	I I(5)'="" D XPP Q:ER  D REPLY:$D(RM) ; Execute post processor
	;
	I validate D  I ET'="" Q
	.	S ET=$$VAL^DBSVER(E8,vlen,E5,I(3),I(4),I(7),I(8),I(9),"|",I(2),1,.GDSP)
	.	I ET'="" D  Q
	..		S ER=1,RM=ET
	..		I $G(%IPMODE)["NOINT",$G(SID)'=""  S RM=RM_".  SCR="_$G(SID)_" "_$P(%TAB(NI),"|",3)
	;
	D SET Q					; Set value into array
	;
	;----------------------------------------------------------------------
EXTYP(v,fmt,dec)	; Format string for external display REPLACE W/ EXT^%ZM
	;----------------------------------------------------------------------
	;
	Q $$EXT^%ZM(v,fmt,.dec)
	;
	;----------------------------------------------------------------------
INTYP(X,TYP,DEC)	; Format to Internal REPLACE W/ INT^%ZM(X,TYP)
	;----------------------------------------------------------------------
	;
	Q $$INT^%ZM(X,TYP,,.DEC)
	;
	;----------------------------------------------------------------------
VALIDATE(typ,len,req,tbl,pat,min,max,dec,noc)	;public;Input Validation
	;----------------------------------------------------------------------
	;
	Q $$VAL^DBSVER(typ,len,req,tbl,pat,min,max,dec,$G(noc))
	;
	;----------------------------------------------------------------------
SET	; 	Set the input string into it's underlying array
	;----------------------------------------------------------------------
	;
	I X'="" K REQ(NI)
	;
	;  Update UX() table when %O=1 (screen modify mode)
	;  or based on a user defined flag vux(vfid)
	;     vfid is any valid DQ file name      vux("CIF")=""
	;     or * for user defined variables     vux("*")=""
	;
	I V'=X,(%O!$D(vux(vfid))) D SETUX ;		Build UX(array)
	;
	S $P(vjrnl,"|",NI)=$S(E4=1:" ",1:X)	; JRC 02/28/94 ARQ 11723
	I $G(vsf)'="" D  Q					; Subfield
	.	;
	.	N vsft,vsfd1,vsfd2,vsfp
	.	S vsft=$P(vsf,"~",1),vsfd1=$P(vsf,"~",2),vsfd2=$P(vsf,"~",3),vsfp=$P(vsf,"~",4)
	.	S:vsfd1 vsfd1=$$BYTECHAR^SQLUTL(vsfd1) S:vsfd2 vsfd2=$$BYTECHAR^SQLUTL(vsfd2)
	.	;
	.	I PGM'="UTLREAD",$G(vPSL),(vfid'="*") D SETOBJ I 1
	.	E  DO  
	..		I E12="" S @DATA=$$PUT^USUB(@DATA,X,vsft,vsfd1,vsfd2,vsfp) Q
	..		S $P(@DATA,E9,E12)=$$PUT^USUB($P(@DATA,E9,E12),X,vsft,vsfd1,vsfd2,vsfp)
	;
	;
	; For PSL-compiled screens, set the value into the object
	I PGM'="UTLREAD",$G(vPSL),(vfid'="*") D SETOBJ I 1
	;Native screen compiler
	E  D
	.	I E12 S $P(@DATA,E9,E12)=X
	.	E  S @DATA=X
	Q
	;
SETOBJ	; set the value into the object by calling vSET tag in screen program
	Q:V=X
	N DI,FID,Z
	S Z=$P($$TAB(NI),"|",3)
	S DI=$P(Z,"]",2)
	S FID=$P($P(Z,"]",1),"[",2) 
	I '$D(fsn(FID)) D fsn^DBSDD(.fsn,FID)
	S Z="vSET^"_PGM_"(FID,DI,X)"
	D @Z
	Q
	;
	;----------------------------------------------------------------------
SETUX	; Create UX array  UX(vfid,DI)=old value | new value | node | piece
	;----------------------------------------------------------------------
	;
	N dd,sfd
	S I1=I(1) I $E(I1)="*" S I1=$P(I1,"(",2)+0	; *VAR(1)
	;
	I %O,"N$"[E8,V-X=0,V'="",X'="" Q		; No change
	I %O,E8="L",+V=+X S X=V Q			; No change 
	;
	I V["|" S V=$TR(V,"|"," ")			; Remove |
	I $D(%MOD)&(NI>%MODOFF) D SETUXR Q		; In repeat region
	;
	I vfid="*",E12 S vsn=vsn_E9_+E12		; var|piece
	I vfid'="*" D					;pc 03/24/02
	.	S dd=""
	.	S dd=$$DI^DBSDD(vfid_"."_vsn)
	.	S sfd=$P(dd,"|",18)
	I '$D(UX(vfid,vsn)) S UX(vfid,vsn)=V_"|"_X_"|"_I1_"|"_E12_"|||||"_E8_"|"_$G(sfd)
	I $P(UX(vfid,vsn),"|",1)=X K UX(vfid,vsn) Q
	I E8="L",$P(UX(vfid,vsn),"|",1)-X=0 K UX(vfid,vsn) Q  ; NULL/0 for
	S $P(UX(vfid,vsn),"|",2)=X			      ; logical
	Q
	;
	;----------------------------------------------------------------------
SETUXR	; Create UX array  UX(vfid,DI,SEQ)=old | new | node | piece
	;----------------------------------------------------------------------
	;
	; ---------- UX("*",VAR_del_pos,SEQ)=...
	;
	I vfid="*",E12 S vsn=vsn_E9_+E12
	;
	I '$D(UX(vfid,vsn,I1)) S UX(vfid,vsn,I1)=V_"|"_X_"|"_I1_"|"_E12 Q
	I $P(UX(vfid,vsn,I1),"|",1)=X K UX(vfid,vsn,I1) Q
	S $P(UX(vfid,vsn,I1),"|",2)=X Q
	;
	;----------------------------------------------------------------------
XPRE	;	Execute the pre processor I(6)
	;----------------------------------------------------------------------
	;
	S X=""
	; For PSL compiled screens, set V from the vobj array
	I PGM'="UTLREAD",$G(vPSL),(vfid'="*") S V=$$SETV()
	E  S V=$G(@DATA) I E12 S V=$P(V,E9,E12)
	D EXECUTE(I(6),PGM,$G(DFID),$G(DLIB),1)
	Q
	;
	;----------------------------------------------------------------------
XPP	;	Execute the post processor I(5)
	;----------------------------------------------------------------------
	;
	I X="",E5,E8'="L" Q  ; REQUIRED
	;
	D EXECUTE(I(5),PGM,$G(DFID),$G(DLIB),0)
	I E4=1,ER S X=""    ; *** XUS    09/15/94
	I "DL"[E8,X?.N,ER S X=$$EXT^%ZM(X,E8)	; *** 06/29/95 BC
	Q					; Convert to external format
	;
SETV()	; Called for PSL-compiled screens.  Sets V from the vobj array
	N DI,FID,Z
	;S Z=$P($G(%TAB(NI)),"|",3)
	S Z=$P($$TAB(NI),"|",3)
	S DI=$P(Z,"]",2)
	S FID=$P($P(Z,"]",1),"[",2)
	I '$D(fsn(FID)) D fsn^DBSDD(.fsn,FID)
	S Z="S V=$$vREAD^"_PGM_"(FID,DI)"
	X Z
	Q V
	;
	;---------------------------------------------------------------------
EXECUTE(%CODE,PGM,DFID,DLIB,preflg)	; Execute pre/post processors
	;----------------------------------------------------------------------
	;
	N ZB,DY,DX,vx,z,z1,vdspscr,%JRNL
	S vx=X,vni=NI,ZB=13
	S z1=$G(I(1)) I 'z1 S z1=+$P(z1,"(",2)	; Reverse compt  ????
	I %fkey="SEL" S ZB=3
	S DY=$$BSASCII^SQLUTL(vhdr,1)-1,DX=$$BSASCII^SQLUTL(vhdr,2)-1		; Reverse compatible
	;
	X %CODE					; field pre/post-proc
	I preflg DO
	.	I PGM'="UTLREAD",$G(vPSL),(vfid'="*") S V=$$SETV()
	.	E  S V=$G(@DATA) I E12 S V=$P(V,E9,E12)
	.	S X=$$EXT^%ZM(V,E8,I(9))
	;
	E  I vdsp,vx'=X,'E4 D			; Value changed by user
	.	S vdsp=2			; Re-display flag
	.	I $D(vdft(vni)) S $P(vdft(vni),"|",1)=X
	;
	I NI'=vni S z=vni,vni=NI,NI=z		; Save new NI variable
	E  K vni
	I %fkey="ESC" S vdspscr=1,X=vx,$P(vdft(NI),"|",1)=vx    ; 8/29/96  MJZ 
	I $G(vdspscr) D DSP^DBSCRT(1)		; Redisplay screen
	Q
	;
	;----------------------------------------------------------------------
RESET(NI)	; Set %TAB, V and X to original data
	;----------------------------------------------------------------------
	;
	S X=$$TAB(NI)
	;
	; Load I(array), E4,E5,E67,E8,E9,E12,V
	;
	S vhdr=$$BYTECHAR^SQLUTL($$BSASCII^SQLUTL(X,1)+1)_$$BYTECHAR^SQLUTL($$BSASCII^SQLUTL(X,2)+1)_$E($P(X,"|",1),3,99),X=$P(X,"|",2,99)
	S E4=$E(vhdr,4),E5=$E(vhdr,5)
	S E67=$$BSASCII^SQLUTL(vhdr,3),E8=$E(vhdr,6),E12=$E(vhdr,10,11)
	;
	F I=1:1:9 S I(I)=$P(X,"|",I)
	S vsf=$P(X,"|",10)			; *** - FRS - Sub-field definition 8/24/93
	S vlen=$P(X,"|",11) I 'vlen S vlen=E67
	;
	; ---------- User defined variable in repeat region *VAR(1)
	;
	I $E(I(1))="*" D
	.	S DATA=$E(I(1),2,99),vfid="*"			; Variable
	.	I $D(%MOD),NI>%MODOFF S vsn=$P(DATA,"(",1) Q	; Repeat Region
	.	S vsn=DATA					; Regular var
	E  S vsn=$P(I(2),"]",2),vfid=$E($P(I(2),"]",1),2,99),DATA=VFSN(vfid) I I(1)'="" S DATA=DATA_"("""_I(1)_""")"
	;
	;
	; For PSL-compiled screens, set V from the vobj array
	I PGM'="UTLREAD",$G(vPSL),(vfid'="*") do
	.	N DI,FID,Z
	.	S Z=$P($G(X),"|",2)
	.	S DI=$P(Z,"]",2)
	.	S FID=$P($P(Z,"]",1),"[",2)
	.	I '$D(fsn(FID)) D fsn^DBSDD(.fsn,FID)
	.	S Z="S V=$$vREAD^"_PGM_"(FID,DI)"
	.	X Z
	;
	; Native screen compiler.
	E  D
	.	S V=$G(@DATA) I E12 S E9=$$BYTECHAR^SQLUTL($E(vhdr,7,9)),V=$P(V,E9,E12)
	.	I vsf'="" D						; Subfield
	..		;
	..		N vsft,vsfd1,vfd2,vsfp
	..		S vsft=$P(vsf,"~",1),vsfd1=$P(vsf,"~",2),vsfd2=$P(vsf,"~",3),vsfp=$P(vsf,"~",4)
	..		S:vsfd1 vsfd1=$$BYTECHAR^SQLUTL(vsfd1) S:vsfd2 vsfd2=$$BYTECHAR^SQLUTL(vsfd2)
	..		S V=$$GET^USUB(V,vsft,vsfd1,vsfd2,vsfp)
	Q
	;
	;----------------------------------------------------------------------
TAB(NI)	; Return %TAB for NI
	; %MOD      -  Number of data items in repeat group
	; %MODOFF   -  %TAB sequence # of first repeat data item
	; %MODGRP   -  Number of detail lines in repeat group
	; %MODS     -  Field # offset ( for 2 thru Nth page screen only )
	;-----------------------------------------------------------------------
	;
	I $G(%MODOFF)="" Q %TAB(NI)	; 		No repeat regions
	I NI'>%MODOFF Q %TAB(NI) ; 			Above repeat region
	I '$D(%MODS) S %MODS=1	; 			Base %TAB, Page 2-n
	;
	I %TAB(NI)'="",%MODS=1 Q %TAB(NI) ;	 	Base %TAB, Page 1
	;
	N X,X1,X2,X3
	;
	S X2=NI-1-%MODOFF\%MOD ; 			Field id offset
	;
	I %TAB(NI)'="" S X=%TAB(NI) G TABNOD
	;
	S X1=%TAB($$TABROOT(NI)) ;			Set to root %TAB
	S X=$$BYTECHAR^SQLUTL($$BSASCII^SQLUTL(X1,1)+(%MODGRP*X2)),X=X_$E(X1,2,999) ; Change line #
	;
TABNOD	; Change the array subscript
	;
	S X3=$P(X,"|",2)+X2 I %MODS>1 S X3=X3+%MODS-1 ; Change field #
	;
	; ---------- Change *VAR(1) to *VAR(1+%MODS+offset) ----------
	;
	I $P(X,"|",2)?1"*"1E.E1"(1)" S X3=$P($P(X,"|",2),"(",1)_"("_(X2+%MODS)_")"
	;
	S X=$P(X,"|",1)_"|"_X3_"|"_$P(X,"|",3,99) ; 	Create new %TAB
	;
	I $D(%REPREQ),NI>%REPREQ S X=$E(X,1,4)_"0"_$E(X,6,999) ; Required flag
	Q X
	;
TABROOT(N)	S N=N-1-%MODOFF#%MOD+%MODOFF+1 S:N=0 N=%MOD Q N
	;
	;----------------------------------------------------------------------
VARIABLE(X,TYPE)	; Convert <<xxx...>> to it's underlying value
	;----------------------------------------------------------------------
	;
	S X=$E(X,3,$L(X)-2) ;					Strip << ... >>
	I X?1A.AN!(X?1"%".AN) Q $G(@X) ;			Local variable
	I X?1"$$"1E.E N z X "S z="_X Q z ;			$$^ROUTINE
	N $ZT
	S $ZT=$$SETZT^%ZT("UNDEF^DBSCRT8")
	;
	I X?1A.AN1"("1E.E1")"!(X?1"%".AN1"("1E.E1")") Q $G(@X) ;Local array
	I $$VER^DBSDD(.X) N ER Q $$RETVAL^DBSDD(X)
	;
UNDEF	Q ""
	;
	;----------------------------------------------------------------------
REPLY	; Pre/Post processing or edit checking message to terminal
	;----------------------------------------------------------------------
	;
	I 'vdsp K:'ER RM Q
	D PNTRM^DBSCRT K RM Q
	;
	;----------------------------------------------------------------------
ERROR	; Error flag (ER) set, reprocess field on interactive or exit
	;----------------------------------------------------------------------
	; *** BC - 04/12/94 ARQ 10572 	 	; Insert field input sequence
	;					; number with return message
	N z					; (piece 3)
	I 'vkeyb D  S NI=%MAX+1 Q		; Non-interactive mode
	.	I $G(%IPMODE)'["POINTER" Q	; Last field sequence
	.	S z=$P(%IPMODE,"/POINTER=",2)	;
	.	S z=z-%MAX+NI,$P(RM,"|",3)=z	; Input list sequence number
	; ***
	;	
	I E4>2 S RM=RM_" ("_$P(%TAB(NI),"|",3)_")"	; Identify field
	;						; *** 10/20/94 BC
	I "|"'[X,E8'="D" S z=$O(RM(""),-1)+1,RM(z)=X_"|"_NI  ; JRC 02/25/94 ARQ 12147
	;
	D REPLY
	I 'vkeyb S NI=%MAX+1 Q   	      	; Error in non-interactive
	I E4>2 DO  Q
	.	I vgoto="" S NI=%MAX+1 Q	; First field - exit from screen
	.	S vni=$$BSASCII^SQLUTL(vgoto,1)-1		; Return to previous field
	.	S vexit=0			; Cancel past path logic
	;					; *** 06/06/95 BC
	;
	S vgoto=$E(vgoto,2,99)                	; Reset cursor path
	S vexit=0                             	; Cancel <DO> key logic
	G READ
	Q
	;
EXIT()	;
	I $G(ER) S (X,VFMQ)="Q" X KVAR Q 1          ;  *** XUS 2/10/95 
	I vdsp W $$CLR^%TRMVT(OLNTB\1000+1) D CLOSE^DBSCRT
	D ^DBSCRT8A I 'ER!'vkeyb Q 1
	D OPEN^DBSCRT Q 0
	;
CUU()	N X
	I $L(vgoto)=1 Q $$BSASCII^SQLUTL(vgoto,1)-1
	S X=$$BSASCII^SQLUTL(vgoto,2)-1,vgoto=$E(vgoto,3,$L(vgoto)),vexit=0 Q X
	;
	;----------------------------------------------------------------------
CUD	; Go to first field or same column (repeat region) of next line
	;----------------------------------------------------------------------
	;
	I NI=0 Q			; .GOTO. command on first prompt
	I '$D(%TAB) S NI=999 Q		; .PROTECT. ALL command on first prompt
	N zdy
	S zdy=$E($G(%TAB(NI))) ; current line number
	I $G(%TAB(NI+1))'="",zdy]]$E(%TAB(NI+1)) Q
	;
	I zdy="" S zdy=$E(%TAB($O(%TAB(NI),-1)))
	;
	F z=(NI+1):1:(%MAX+1) Q:$D(%TAB(z))
	I z>%MAX Q
	I $D(%MOD),%MODGRP=1,z-1>%MODOFF S z=z+%MOD-1 S:z>%MAX z=NI
	E  F z=z:1:(%MAX+1) Q:$E($G(%TAB(z)))]]zdy
	S:z'>%MAX vexit=$$VEXIT(z) ; Next cursor position
	Q
	;
VEXIT(XNI)	Q (XNI)_"|"_%fkey
DATAITEM(X)	Q X?1"["1AN.E1"]"1AN.E
	;
	;----------------------------------------------------------------------
VDSP	; Redisplay value & Patch input buffer if necessary
	;----------------------------------------------------------------------
	;
	N vx
	I X'="" D	; HYC 04/16/97
	.	S vx=$$EXT^%ZM(X,E8,I(9)),vdsp=1
	.	W $$PNTFMT^DBSCRT(vx,E67,E8,$$BSASCII^SQLUTL(vhdr,1),$$BSASCII^SQLUTL(vhdr,2))
	E  S vx=X
	;
	I '$D(vdft(NI)) Q
	S $P(vdft(NI),"|",1)=vx
	Q
	;
	;----------------------------------------------------------------------
ONLINE()	;  Private ; Check %NET and %CSID
	;----------------------------------------------------------------------
	I '$G(%LOGID) Q 1		;  Host
	I '%NET Q 0			;  Net flagged down
	I $G(%CSID)="" Q 0		;  No HOST connection
	Q 1
	;
	;
	;
LENERR(len)	Q $$^MSG("1076",len) 	; "Field length ~p1 exceeded"
TBLERR(tbl)	Q $$^MSG("1485") 	; "Invalid table value "
PATERR(pat)	Q $$^MSG("1421",pat)	; "Invalid pattern "_pat
TYPERR(typ)	Q $$^MSG("742",$P(^DBCTL("SYS","DVFM",typ),"|",1)) ; type error
DECERR(dec)	Q $$^MSG("774",$TR($J("",+dec)," ","N")) ; decimal error
REQERR(req)	Q $$^MSG("741")	; "Data Required"
MINERR(X)	Q $$^MSG("2920",X)	; "Value below minimum range "_X
MAXERR(X)	Q $$^MSG("2919",X)	; "Value above maximum range "_X
FRQERR()	Q $S($D(RM)#10:RM,1:$$TYPERR("F"))
DELERR(del)	Q $$^MSG("1380",del) ; "Invalid input, replace '"_$C(del)_"' with $C("_del_")"
PUPERR()	Q $$^MSG("2222")	; "Previous screen access disabled"
