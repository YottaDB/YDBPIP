%ZULVLOD	;Public;Utility to load global to local array
	;;Copyright(c) Sanchez Computer Associates, Inc.  All Rights Reserved - // - 
	; ORIG: Frank R. Sanchez  (2497)
	;
	; This is a general purpose utility that loads the data saved in global
	; %GLO(key1,key2,...keyn) by utility ^%ZULVSAV into a local array.
	;
	; Global is stored as GLOB(KEY,KEY,array)=data which is loaded
	; to array=data
	;
	; KEYWORDS: System utilities
	;
	; INPUTS:
	;     . %GLO	Global reference		/TYP=T/REQ
	;
	; RELATED:
	;     . ^%ZULVSAV - Save local array to global
	;----------------------------------------------------------------------
	;
	N %ZTX,%ZTI
	;
	S:$E(%GLO,1)'="^" %GLO="^"_%GLO
	I %GLO["(",$E(%GLO,$L(%GLO))'="," S %GLO=%GLO_","
	S:%GLO["("=0 %GLO=%GLO_"("
	;
	; Load variables
	S %ZTX=%GLO_""""")"
	S %ZTX=$O(@%ZTX)
	S %ZTX=""
	;
	F %ZTI=1:1 S %ZTX=$O(^(%ZTX)) Q:%ZTX=""  S @%ZTX=^(%ZTX)
	Q
