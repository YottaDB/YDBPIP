SCAENC	;
	;
	; **** Routine compiled from DATA-QWIK Procedure SCAENC ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	;
	S ENC=$$ENC(X)
	;
	Q 
	;
ENC(PWD)	;
	;
	I $E(PWD,1)=$char(1) Q $E(PWD,2,999)
	;
	N ENC,I,L,SUM,XOR
	;
	S PWD=$$vStrUC(PWD)
	S XOR=$$XOR^%ZFUNC(PWD)
	S L=$L(PWD)
	;
	S SUM=0
	F I=1:1:L-1 S SUM=SUM+($A(PWD,I)*$A(PWD,I+1)*(I+1))
	S SUM=SUM+($A(PWD,L)*(L+1))+(XOR*L)
	S ENC=SUM#999999
	;
	Q ENC
	;
vSIG()	;
	Q "59495^75633^Lik Kwan^1030" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïğñòóôõöøùúûüış","ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖØÙÚÛÜİŞ")
