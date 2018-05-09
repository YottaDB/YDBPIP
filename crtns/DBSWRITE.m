 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSWRITE ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
DBSWRITE(ARRAY,TOPMARGN,BTMMARGN,MAXLINES,SOURCE,HEAD) ; Header info   /NOREQ
 ;
 N EDTOPT N N N varray N ZTEMP
 ;
 I ($get(TOPMARGN)="") S TOPMARGN=1
 I ($get(BTMMARGN)="") S BTMMARGN=24
 I ($get(MAXLINES)="") S MAXLINES=9999999
 I ($get(SOURCE)="") S SOURCE=80
 S HEAD=$get(HEAD)
 ;
 I (SOURCE>80) D
 .	;
 .	WRITE $$SCR132^%TRMVT
 .	D TERM^%ZUSE($I,"WIDTH=132")
 .	Q 
 ;
 ; Header information
 I ($piece(HEAD,"_",2)["""") D
 .	;
 .	S $piece(HEAD,"-",2)=$translate($piece(HEAD,"-",2),"""","")
 .	Q 
 ;
 ; Get editor option - Unix or VMS
 S EDTOPT="EDT" ; Default
 I '($get(%UID)="") D
 .	;
 .	N scau S scau=$G(^SCAU(1,%UID))
 .	;
 .	I '($P(scau,$C(124),21)="") S EDTOPT=$P(scau,$C(124),21)
 .	;
 .	I (EDTOPT="DBS") S EDTOPT="EDT"
 . Q 
 ;
 ; Move ARRAY into ZTEMP to allow proper pass to DBSEDT
 S varray=ARRAY_"(N)"
 S N=""
 F  S N=$order(@varray) Q:(N="")  S ZTEMP(N)=@varray
 ;
 ; Allow indirection and avoid warning on unscope variable
 ;  #ACCEPT Date=04/27/06; Pgm=RussellDS; CR=20967
 K @ARRAY
 ;
 D ^DBSEDT(.ZTEMP,EDTOPT,HEAD)
 ;
 S N=""
 F  S N=$order(ZTEMP(N)) Q:(N="")  S @varray=ZTEMP(N)
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60425^2982^Dan Russell^1895" ; Signature - LTD^TIME^USER^SIZE
