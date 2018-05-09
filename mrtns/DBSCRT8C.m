DBSCRT8C	;; -  - V5.0 - DQ field attributes display utility
	;;Copyright(c)2001 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/15/01 10:08:52 - DALYE
	;     ORIG:  CHIANG - 08/10/89
	;     DESC:  Fiels attributes display utility
	;
	; INPUTS:
	;
	;     %TAB	Screen/UTLREAD %TAB array
	;
	;---------- Revision History -------------------------------------------
	; 07/14/06 - RussellDS - CR22121
	;	     Replaced $A references with $$BSASCII^SQLUTL and $C with
	;	     $$BTYECHAR^SQLUTL to ensure Unicode compliance.
	;
	; 08/15/01  -  DALYE - 44255
	;	       Modified sections VAR and DINAM1 to store the correct
	;	       field delimiter (numeric value) and position for
	;	       display.
	;
	; 02/23/99  -  Chiang - 31754
	;              Modified to use +$H (system date) as the input value
	;              for the ^%ZM date utility.
	;
	;	       Removed old revision history.
	;-----------------------------------------------------------------------
	;-----------------------------------------------------------------------
START	;
	;
	;
	; version 3 to version 4 conversion
	;
	; Change old %TAB() format    DY,DY,DX,DX,REQ,LN,LN,TYPE,...
	;                    to >     $A(DY,DX,LN),0,REQ,TYPE,...
	;
	N I,X,DX
	S I=0
NI	;
	S I=$O(%TAB(I)) I I="" Q
	I %TAB(I)="" G NI
	S X=%TAB(I),DX=$E(X,3,4)
	;
	; 132 column mode ?
	;
	I DX?1A.N S DX=$S($E(DX)="A":100,$E(DX)="B":110,$E(DX)="C":120,1:130)+$E(DX,2)
	;
	S %TAB(I)=$$BYTECHAR^SQLUTL($E(X,1,2))_$$BYTECHAR^SQLUTL($E(X,3,4))_$$BYTECHAR^SQLUTL($E(X,6,7))_0_$E(X,5)_$E(X,8,999)
	G NI
	;
	; F14  - Display data item definition 
	;
	;----------------------------------------------------------------------
DIHELP(DINAM)	; Display data item or variable data dictionary attribues
	;----------------------------------------------------------------------
	;
	; ARGUMENTS:
	;
	;     . DINAM   Field Name
	;
	;               Valid Syntax
	;
	;               []DI          LIB=%LIBS  FID=DFID
	;               [FID]DI       LIB=%LIBS
	;               [LIB,FID]DI
	;               [LIB,]DI      User defined variable
	;               [*]DI         User defined variable
	;
	; INPUTS:
	;
	;     .   %fkey,%LIBS,DINAM,DFID,NI,%TAB
	;-----------------------------------------------------------------------
	;
	N (%fkey,%LIBS,DINAM,DFID,NI,%TAB,%REPEAT,%MODOFF,%MOD,%MODS)
	;
	I DINAM'?1"[*]"1E.E D VAR,DINAM,DISP Q
	;
	;----------------------------------------------------------------------
	; [*]VAR syntax
	;----------------------------------------------------------------------
	S ER=0 D VAR I ER Q
	I DI?1"@".E S DI="<"_$E(DI,2,99)_">"
	I $G(%FID)="*" S %FID=""
	D DISP Q
	;
VAR	;
	;----------------------------------------------------------------------
	; Get attributes from %TAB(NI)
	;----------------------------------------------------------------------
	;
	F I=1:1:25 S %A(I)=""
	;
	I '$G(NI) S ER=1 Q
	;
	I '$D(%TAB(NI)) S ER=1 Q		
	S X=$G(%TAB(NI))			; Field attributes
	I X="",'$G(%REPEAT) S ER=1 Q		; Repeat region ?
	;					; Use base definition
	I X="",%REPEAT S X=NI-1-%MODOFF#%MOD+%MODOFF+1,X=$G(%TAB(X))
	I X="" S ER=1 Q
	;
	; ---------- size , format , variavle name
	;
	S %A(2)=$$BSASCII^SQLUTL(X,3),%A(9)=$E(X,6),DI=$P(DINAM,"]",2),%FID="*"
	;
	; ---------- tbl , min , max , pre , post ; decimal
	;
	S %A(5)=$P(X,"|",4)
	S %A(6)=$P(X,"|",5),%A(12)=$P(X,"|",8),%A(13)=$P(X,"|",9)
	S %A(7)=$P(X,"|",6),%A(8)=$P(X,"|",7),%A(14)=$P(X,"|",10)
	S X=$P(X,"|",1),%A(20)=$E(X,7,9)
	;
	I %A(20)>0 S %A(21)=$E(X,10,11)+0 ; Delimiter ; EMD 8/15/01 [44255] removed S %A(20)=$C(%A(20))
	;
	Q
DISP	;
	N (%fkey,DI,%FID,%A,%O,%TO,I)
	;
	S z="" F  s z=$O(%A(z)) Q:z=""  S $P(fDBTBL1D,"|",z)=%A(z)
	S %O=2 S SID="DBTBL1H" D ^USID I PGM'="" D ^@PGM
	W $$CLEAR^%TRMVT			; Clear screen after displaying
	;                                       ; field attributes
	Q
	;
DINAM	;----------------------------------------------------------------------
	; Copy DINAM attributes into %A() array
	;----------------------------------------------------------------------
	;
	I DINAM?1"[]"1E.E Q:$G(DFID)=""  S XF=DFID,XL=%LIBS G DINAM1
	;
	I DINAM["," S X=$P(DINAM,"]",1),XL=$E($P(X,",",1),2,99),XF=$P($P(X,",",2),"]",1)
	E  S XL=$G(%LIBS),XF=$E($P(DINAM,"]",1),2,99)
DINAM1	;
	S XD=$P(DINAM,"]",2)
	I $G(XL)="" S XL=^CUVAR("%LIBS")
	;
	I XF="" Q
	S X=$P($G(^DBTBL(XL,1,XF,10)),"|",5)
	I X'="" S XL=$E($P(X,",",1),2,99)
	I $G(^DBTBL(XL,1,XF,9,XD))="" Q
	S X=^(XD)
	F Z=1:1:20,22:1:25 I "*"[%A(Z) S %A(Z)=$P(X,"|",Z)
	S %A(21)=$P(X,"|",21)			; EMD 8/15/01 [44255]
	;
	S DI=XD,%FID=XF
	Q
	;
	;
	; ---------- Data Item Reference Report
REF(NAME)	;
	;
	N (NAME,DFID)
	;
	S CONAM=$G(^CUVAR("CONAM")),LIB=^CUVAR("%LIBS")
	;
	I NAME?1"["1E.E1","1E.E1"]"1E.E D FULL G DSP
	I NAME?1"["1E.E1"]"1E.E D PART G DSP
	I NAME?1"[]"1E.E S FID=$G(DFID),DI=$P(NAME,"]",2) G DSP
	Q
FULL	;
	S FID=$P($P(NAME,"]",1),",",2),DI=$P(NAME,"]",2) Q
	;
PART	;
	S FID=$P($P(NAME,"]",1),"[",2),DI=$P(NAME,"]",2) Q
	Q
DSP	;
	D ^SCAIO
	S %BLK="/,"_IO_","_LIB_",,"_FID_","_DI
	I '$D(%LIBS) N %LIBS S %LIBS=^CUVAR("%LIBS")
	S RID="DBINDX"    ; *** XUS 08/08/94  
	D DRV^URID
	Q
	;
	;----------------------------------------------------------------------
	; Screen Status       Function Name , Date , Time
	;----------------------------------------------------------------------
STATUS	;
	;
	; %FN (20)   DESC (35)   DATE (10)  TIME (10)
	;
	; Screen Name/Master Screen , Function Description ,  Date , Time
	;
	N FNDES,SCREEN
	;
	S FNDES="" I $G(%FN)'="" S FNDES=$P($G(^SCATBL(1,%FN)),"|",1)
	S FNDES=FNDES_$J("",42-$L(FNDES))
	;
	I $G(PGM)="UTLREAD" S SCREEN="" G STATUS1 ; UTLREAD Utiilty
	;
	S SCREEN=$G(VSID)
	I SCREEN'="",$G(SID)'="",SID'=SCREEN S SCREEN=SID_"/"_SCREEN ; Linked
	;
STATUS1	;
	; I18N=OFF
	W $$BTM^%TRMVT,$$VIDREV^%TRMVT
	W " "_SCREEN_$J("",16-$L(SCREEN))_FNDES		; *** 02/11/97
	W " ",$J($$DAT^%ZM(+$H),10)," ",$J($$TIM^%ZM,8)," "	; 02/23/99 BC
	W $$VIDOFF^%TRMVT				; with %ZM calls
	; I18N=ON
	Q
