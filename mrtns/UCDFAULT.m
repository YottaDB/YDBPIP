UCDFAULT	;public; New record default and overlay methods.
	;;Copyright(c)1999 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/22/99 16:02:07 - SPIER
	; ORIG: Spier - 3 Sep 1999 
	; DESC: Methods used in the creation of new accounts via RPC
	;	Method Library :
	;	 default - Loan,Deposit and Cif new account default utility. Retrieve defaults from product defaults table
	;	           and move into a object. This is a node copy, it will need to change to column level when a DB
	;	           other then M is used.
	;	 overlay - Add fields to a object based on the existence of a array entry for each field. 
	; 
	;
	;---- Revision History ------------------------------------------------
	;
	;----------------------------------------------------------------------
	;
	quit
	;
default	; Default product defaults to a object
	; INPUTS:
	;
	; expr		method expression
	; type()	object definition table
	;
	; OUTPUTS:
	;
	; mcode		input expression substitution
	;
	; EXAMPLES:
	;
	; // loan renewal
	; new ln
	; type RecordLN ln=Class.new("LN")
	; set ln.cid=CID
	; do ln.default("TYPE")
	; do ln.save()
	;
	; // deposit renewal
	; new dep
	; type RecordDEP dep=Class.new("DEP")
	; set dep.cid=CID
	; do dep.renew("TYPE")
	; do dep.save()
	;
	;----------------------------------------------------------------------
	N col,cola,colb,di,i,key,objnam,pcode,x,z,zkey,zseq,ztbl
	S objnam=$P(expr,".",1)			; object name
	S ztbl=$P(type(objectLevel,objnam),"Record",2)	; table name
	I ztbl="CIF" D PRODDFTC Q		; cif table
	I ztbl="DEP" D PRODDFTD Q		; deposit table
	I ztbl="LN" D PRODDFTL Q		; loan table
	S mcode=""				; Return expression
	Q
PRODDFTL;	loan defaults 
	;
	S key=actual(1) I key["""" S key=$P(key,"""",2)
	S zkey=key
	;I18N=OFF 
	do line^UCGM(" do {")
	do line^UCGM(" new product,node")
	do line^UCGM(" set node=""""")
	S mcode=$$initLine^UCGM(level)
	S mcode=mcode_"for  set node=$O(^UTBLDFTL("_key_",node)) quit:node=""""  set vobj(objnam,node)=^UTBLDFTL("_key_",node)"
	D ADD^UCGM(mcode)
	do line^UCGM(" }")
	S mcode=""				; Return expression
	;
	Q
	;
PRODDFTD;	deposit renewal 
	;
	S key=actual(1) I key["""" S key=$P(key,"""",2)
	S zkey=key
	;I18N=OFF 
	do line^UCGM(" do {")
	do line^UCGM(" new product,node")
	do line^UCGM(" set node=""""")
	S mcode=$$initLine^UCGM(level)
	S mcode=mcode_"for  set node=$O(^UTBLDFTD("_key_",node)) quit:node=""""  set vobj(objnam,node)=^UTBLDFTD("_key_",node)"
	D ADD^UCGM(mcode)
	do line^UCGM(" }")
	S mcode=""				; Return expression
	;
	Q
	;
PRODDFTC;	deposit renewal 
	;
	S key=actual(1) I key["""" S key=$P(key,"""",2)
	S zkey=key
	;I18N=OFF 
	do line^UCGM(" do {")
	do line^UCGM(" new product,node")
	do line^UCGM(" set node=""""")
	S mcode=$$initLine^UCGM(level)
	S mcode=mcode_"for  set node=$O(^UTBLDFTC("_key_",node)) quit:node=""""  set vobj(objnam,node)=^UTBLDFTC("_key_",node)"
	D ADD^UCGM(mcode)
	do line^UCGM(" }")
	S mcode=""				; Return expression
	;
	Q
	;
overlay	; Move overlay information from array into primary table object 
	;
	; INPUTS:
	;
	; 	expr		method expression
	; 	type()		object definition table
	; 	actual() 	parameter 
	;
	; OUTPUTS:
	;
	; mcode		input expression substitution
	;
	; EXAMPLES:
	;
	new cola,colb,di,i,j,file,objnam,pcode,x,z,zseq
	S array=actual(1) I array["""" S array=$P(array,"""",2)
	S objnam=$P(expr,".",1)			; object name
	I objnam["(" set objnam=$p(objnam,"(",1)_"()"
	S file=$P(type(objectLevel,objnam),"Record",2)	; table name
	S objnam=$P(expr,".",1)			; object name
	S zseq=10
	;S zseq=zseq+1,
	S mcode=$$initLine^UCGM(level)
	s x=" new vfid,vdata set vfid="""_file_""""
	do line^UCGM(x)
	S di="" F  S di=$O(^DBTBL("SYSDEV",1,file,9,di)) Q:di=""  D
	.	S z=$P(^(di),"|",1)			; column attributes (node number)
	.	I z="" Q				; Computed
	.	I z["*" Q				; Access key
	.	;I z'?1N.N Q				; Status level
	.	I $P(^(di),"|",18)'="" Q			; Sub-fields can not be set
	.	;
	.	S cola=file_"."_di			; from table
	.	S col=$$LOWER^%ZFUNC(di)		; Lower case item name
	.	S colb=objnam_"."_col			; to table
	.	;I18N=OFF 
	.	S mcode=$$initLine^UCGM(level)
	.	D ADD^UCGM(mcode_"set vdata=vfid_"".""_"""_di_"""")
	.	S x=" if $D("_array_"(vdata)) set "_colb_"="_array_"(vdata)"
	.	D line^UCGM(x)
	;
	; compile PSL code into M code
	;
	S mcode="",return=" "					; Return expression
	;
	Q
	;
