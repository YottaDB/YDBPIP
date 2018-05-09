%ZULVSAV	;Public;Utility to save local array to global
	;;Copyright(c) Sanchez Computer Associates, Inc.  All Rights Reserved - // - 
	; ORIG: Frank R. Sanchez  (3497)
	;
	; This utility saves the current symbol table to the
	; global file contained in the variable %GLO.
	;
	; %ZT variables are used by this routine and can't be included
	; in the save set
	;
	; KEYWORDS: System utilities
	;
	; INPUTS:
	;     . %GLO	Global reference		/TYP=T/REQ
	;
	;     . %V	Variable name(s) to save	/TYP=T/REQ
	;
	;		%V not defined - quits immediately
	;		%V="" Saves entire symbol table
	;		%V]"" saves variables in argument %V="VAR1,VAR2,..."
	;
	; RELATED:
	;     . ^%ZULVLOD - Utility to load local array
	;----------------------------------------------------------------------
	;
	I '$D(%V) Q
	;
	N %ZTX,%ZTI,%ZTARR,%ZTS,%ZTSUBS,%ZTL,%ZTNS,%ZTL,%ZTZ
	S:$E(%GLO,1)'="^" %GLO="^"_%GLO
	I %GLO["(",$E(%GLO,$L(%GLO))'="," S %GLO=%GLO_","
	S:%GLO["("=0 %GLO=%GLO_"("
	;
	I $D(%V),%V'="" G SPARSE
	S %ZTX="%" I $D(%) D SAVE
	;
ALL	; Save the entire symbol table;
	S %ZTX=$O(@%ZTX) Q:%ZTX=""  G ALL:%ZTX="%ZTX"
	D SAVE
	G ALL
	;
SAVE	; Save variables
	I $D(@%ZTX)#10,%ZTX'?1"%ZT".E S @(%GLO_"%ZTX)")=@%ZTX
	I $D(@%ZTX)\10=0 Q  ; Not an array
	S %ZTARR=%ZTX_"(",%ZTSUBS="%ZTS)"
	;
DESCEND	N %ZTL,%ZTS
	S %ZTL=$L(%ZTSUBS)-5,%ZTS=""
	F %ZTZ=1:1 S %ZTS=$O(@(%ZTARR_%ZTSUBS)) Q:%ZTS=""  D SUBS
	Q
	;
SUBS	I $D(@(%ZTARR_%ZTSUBS))#10 D SAV
	I $D(@(%ZTARR_%ZTSUBS))\10=0 Q
	D ZTNS S %ZTSUBS=$E(%ZTSUBS,1,%ZTL)_%ZTNS_",%ZTS)"
	D DESCEND S %ZTSUBS=$E(%ZTSUBS,1,%ZTL)_"%ZTS)"
	Q
	;
ZTNS	N I,Z
	I +%ZTS=%ZTS S %ZTNS=%ZTS Q
	I %ZTS'["""" S %ZTNS=""""_%ZTS_"""" Q
	S %ZTNS=""
	F I=1:1:$L(%ZTS) S Z=$E(%ZTS,I),%ZTNS=%ZTNS_$S(Z="""":Z_Z,1:Z)
	S %ZTNS=""""_%ZTNS_""""
	Q
	;
SAV	S %ZTZ=%ZTX_"("_$E(%ZTSUBS,1,%ZTL)
	D ZTNS S %ZTZ=%ZTZ_%ZTNS_")"
	S @(%GLO_"%ZTZ)")=@%ZTZ
	Q
	;
SPARSE	; Used if only certain variables are saved
	F %ZTI=1:1 S %ZTX=$P(%V,",",%ZTI) Q:%ZTX=""  D SAVE
	;
EXIT	K %GLO
	Q
