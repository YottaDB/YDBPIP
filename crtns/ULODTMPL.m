ULODTMPL(TEMPLATE,ARRAY,START,XTAGS)	;
	;
	; **** Routine compiled from DATA-QWIK Procedure ULODTMPL ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	;
	N %I N LINE N %START N STOP N TAG
	;
	I $E(ARRAY,$L(ARRAY))=")" S ARRAY=$E(ARRAY,1,$L(ARRAY)-1)
	I $E(ARRAY,$L(ARRAY))="," S ARRAY=$E(ARRAY,1,$L(ARRAY)-1)
	I ARRAY'["(" S ARRAY=ARRAY_"("
	;
	I $piece(ARRAY,"(",2)="" S %START=ARRAY_""""")" S ARRAY=ARRAY_"%I)"
	E  S %START=ARRAY_","""")" S ARRAY=ARRAY_",%I)"
	;
	I $get(START)="" S %I=$order(@%START,-1)
	E  S %I=START-1
	;
	N db25rs,vos1,vos2,vos3,vos4 S db25rs=$$vOpen1()
	;
	I '$G(vos1) Q 
	;
	S STOP=0
	F  Q:'($$vFetch1())  Q:STOP  D
	.	S LINE=db25rs
	.	D LINE(LINE,.%I)
	.	Q 
	;
	Q 
	;
LINE(LINE,%I)	;
	;
	; Work with line of code
	;
	N TAG
	;
	S %I=%I+1 S TAG=""
	I LINE?1AN.e!(LINE?1"%".e) S TAG=$piece(($TR(LINE,$char(9)," "))," ",1)
	I TAG="%STOPLOD" S STOP=1
	E  D
	.	S @ARRAY=LINE
	.	I TAG'="" S XTAGS($piece(TAG,"(",1))=%I
	.	Q 
	Q 
	;
vSIG()	;
	Q "60339^35081^Dan Russell^2741" ; Signature - LTD^TIME^USER^SIZE
	;
vOpen1()	;	CODE FROM DBTBL25D WHERE %LIBS='SYSDEV' AND PROCID=:TEMPLATE ORDER BY SEQ
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(TEMPLATE) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^DBTBL("SYSDEV",25,vos2,vos3),1) I vos3="" G vL1a0
	Q
	;
vFetch1()	;
	;
	I vos1=1 D vL1a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos4=$G(^DBTBL("SYSDEV",25,vos2,vos3))
	S db25rs=$P(vos4,$C(12),1)
	;
	Q 1
