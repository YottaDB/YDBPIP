 ; 
 ; **** Routine compiled from DATA-QWIK Procedure ULODTMPL ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
ULODTMPL(TEMPLATE,ARRAY,START,XTAGS) ; 
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
 N db25rs,vos1,vos2,vos3,vos4,vos5 S db25rs=$$vOpen1()
 ;
 I '$G(vos1) Q 
 ;
 S STOP=0
 F  Q:'$$vFetch1()  Q:STOP  D
 . S LINE=db25rs
 .	D LINE(LINE,.%I)
 .	Q 
 ;
 Q 
 ;
LINE(LINE,%I) ; 
 ;
 ; Work with line of code
 ;
 N TAG
 ;
 S %I=%I+1 S TAG=""
 I LINE?1AN.e!(LINE?1"%".e) S TAG=$piece($TR(LINE,$char(9)," ")," ",1)
 I TAG="%STOPLOD" S STOP=1
 E  D
 .	S @ARRAY=LINE
 .	I TAG'="" S XTAGS($piece(TAG,"(",1))=%I
 .	Q 
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60339^35081^Dan Russell^2814" ; Signature - LTD^TIME^USER^SIZE
 ;
vOpen1() ; CODE FROM DBTBL25D WHERE %LIBS='SYSDEV' AND PROCID=:TEMPLATE ORDER BY SEQ
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(TEMPLATE) I vos3="" G vL1a0
 S vos4=""
vL1a4 S vos4=$O(^DBTBL("SYSDEV",25,vos3,vos4),1) I vos4="" G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S db25rs="" Q 0
 ;
 S vos5=$G(^DBTBL("SYSDEV",25,vos3,vos4))
 S db25rs=$P(vos5,$C(12),1)
 ;
 Q 1
