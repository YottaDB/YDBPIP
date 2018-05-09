USUB	;
	;
	; **** Routine compiled from DATA-QWIK Procedure USUB ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	Q 
	;
GET(V,sft,sfd1,sfd2,sfp)	; Get a value (substring) from a string
	;
	I $get(sft)="",$get(sfd1)="",$get(sfd2)="" Q $E(V,sfp)
	I '$get(sfp) S sfp=1
	;
	I sft="" Q $piece(V,sfd1,sfp)
	;
	I $get(sfd2)="" S sfd2=sfd1
	;
	Q $piece(($piece(($piece((sfd1_V),(sfd1_sft_sfd2),2)),sfd1,1)),sfd2,sfp)
	;
PUT(V,X,sft,sfd1,sfd2,sfp)	; Poke a value X into a string V
	;
	N field
	;
	I '$get(sfp) S sfp=1
	;
	I sft="" S $piece(V,sfd1,sfp)=X Q $$STRIP(V,sfd1)
	;
	I $get(sfd2)="" S sfd2=sfd1
	I V="" S $piece(V,sfd2,sfp)=X Q sft_sfd2_V
	;
	S field=$piece(($piece((sfd1_V),(sfd1_sft_sfd2),2)),sfd1,1)
	I field'="" D
	.	N z
	.	S z=sfd1_sft_sfd2_field
	.	S V=$piece((sfd1_V),z,1)_$piece((sfd1_V),z,2)
	.	I $E(V,1)=sfd1 S V=$E(V,2,1048575)
	.	Q 
	S $piece(field,sfd2,sfp)=X
	;
	I V="" Q sft_sfd2_field
	;
	Q V_sfd1_sft_sfd2_field
	;
STRIP(V,D)	; Strip trailing D's from V
	;
	F  Q:$E(V,$L(V))'=D  S V=$E(V,1,$L(V)-1)
	;
	Q V
	;
PARSE(expr,value,mode)	; Change $$GET^USUB format into SET $P format
	;
	N cnt,del,exp,pos,z,zexp
	;
	S cnt=$L(expr,",")
	S pos=$piece(expr,",",cnt)+0
	S del=$piece(expr,",",cnt-2)
	S exp=$piece(expr,",",1,cnt-4)
	S exp=$piece(exp,"(",2,99)
	S z=$piece(exp,",",1)
	S zexp=$piece(z,"(",1)_"($G("_$piece(z,"(",2,99)_")"_","_$piece(exp,",",2,99)
	;
	; I18N=OFF
	; create
	Q " S v="_zexp_",$P(v,"_del_","_pos_")="_value_","_exp_"=v"
	; I18N=ON
	;
vSIG()	;
	Q "59495^75670^Lik Kwan^1600" ; Signature - LTD^TIME^USER^SIZE
