UCDTASYS	;
	;
	; **** Routine compiled from DATA-QWIK Procedure UCDTASYS ****
	;
	; 11/08/2007 14:08 - chenardp
	;
	Q 
	;
	; ---------------------------------------------------------------------
loadFunc(parMap,funcs)	;
	;
	N return S return=""
	N BEG S BEG=$piece(parMap,"(",1)_"(" N END S END=BEG_999
	N list1 S list1=$piece($piece(parMap,"(",2),")",1)
	;
	N rs,vos1,vos2,vos3,vos4,vos5 S rs=$$vOpen1()
	;
	F  Q:'($$vFetch1())  D  I '(return="") Q 
	.	;
	.	; Convert all the condition parameters to 1, use alpha after 9 up to limit of 36
	.	;
	.	N list2 S list2=$translate($piece($piece($P(rs,$C(9),1),"(",2),")",1),"023456789ABCDEFGHIJKLMNOPQRSTUVWXYZ","111111111111111111111111111111111111")
	.	I ($E(list2,1,$L(list1))=list1) S return=rs S funcs(parMap)=return
	.	Q 
	;
	N method S method=$piece($piece(return,$C(9),2),"(",1)
	N class S class=$piece(return,$C(9),3)
	I (class="") S class="String"
	;
	; If the method doesn't exist in OBJECTMET, null it out
	 N V1,V2 S V1=class,V2=method I '(method="")&'($D(^OBJECT(V1,1,V2))#2) S return=""
	;
	I (return="") S funcs(parMap)=$C(9) ; No matches
	;
	Q return
	;
	; ---------------------------------------------------------------------
xiniPSLFUNSUB()	; 1st initialization of table in MDB
	;
	Q 
	;
vSIG()	;
	Q "60472^36119^Dan Russell^6283" ; Signature - LTD^TIME^USER^SIZE
	;
vOpen1()	;	TEMPLATE,METHOD,CLASS,LITRESET FROM STBLPSLFUNSUB WHERE TEMPLATE BETWEEN :BEG AND :END ORDER BY TEMPLATE
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(BEG) I vos2="",'$D(BEG) G vL1a0
	S vos3=$G(END) I vos3="",'$D(END) G vL1a0
	S vos4=vos2
	I $D(^STBL("PSLFUNSUB",vos4)),'(vos4]]vos3) G vL1a6
vL1a5	S vos4=$O(^STBL("PSLFUNSUB",vos4),1) I vos4=""!(vos4]]vos3) G vL1a0
vL1a6	Q
	;
vFetch1()	;
	;
	I vos1=1 D vL1a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos5=$G(^STBL("PSLFUNSUB",vos4))
	S rs=$S(vos4=$C(254):"",1:vos4)_$C(9)_$P(vos5,"|",1)_$C(9)_$P(vos5,"|",2)_$C(9)_$P(vos5,"|",3)
	;
	Q 1
