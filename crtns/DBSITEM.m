 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSITEM ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSITEM(TABLES,ITEMS,DBSATT) ; Attribute array [*] /MECH=REFARR:RW
 ;
 N isCNTFUN
 N i N j N pos N userind
 N return
 ;
 S return=""
 ;
 I ($S((ITEMS=""):0,1:$L(ITEMS,","))=0) Q ""
 ;
 I ($E($piece(ITEMS,",",1),1)="@") Q ""
 ;
 I ($S((TABLES=""):0,1:$L(TABLES,","))=0) D  Q return
 .	;
 .	; Invalid file name - ~p1
 .	S return=$$^MSG(1337)
 .	Q 
 ;
 F i=1:1:$S((TABLES=""):0,1:$L(TABLES,",")) D  Q:'(return="") 
 .	;
 .	N table S table=$piece(TABLES,",",i)
 .	;
 .	 N V1 S V1=table I '($D(^DBTBL("SYSDEV",1,V1))) D
 ..		;
 ..		; Invalid file name - ~p1
 ..		S return=$$^MSG(1337,table)
 ..		Q 
 .	Q 
 ;
 Q:'(return="") return
 ;
 S pos=1
 S isCNTFUN=0
 S userind=0
 ;
 ; Note - even if get an error on an item, keep going, just ignore it
 ; but return message in return (matches old code)
 F i=1:1:$S((ITEMS=""):0,1:$L(ITEMS,",")) D
 .	;
 .	N isER
 .	N dec N indent N len N seq
 .	N column N fmt N fun N hdr N item N table N userhdr
 .	;
 .	S item=$piece(ITEMS,",",i)
 .	;
 .	Q:(item=+item) 
 .	;
 .	S seq=$order(DBSATT(""),-1)+1
 .	S isER=0
 .	S (column,fun,hdr)=""
 .	;
 .	; Allow ,, for spacing
 .	I (item="") D  Q 
 ..		;
 ..		S userind=userind+2
 ..		Q 
 .	;
 .	; Text
 .	I ($E(item,1)=""""),($E(item,$L(item))="""") D  Q 
 ..		;
 ..		N indent N len
 ..		;
 ..		S len=$L(item)-1
 ..		;
 ..		I (seq=1) S indent=0
 ..		E  S indent=2
 ..		;
 ..		S DBSATT(seq)=item_"||"_indent_"|"_len_"|T"
 ..		S pos=pos+2+len
 ..		Q 
 .	;
 .	; item@user_heading is valid syntax
 .	I (item?1E.E1"@"1E.E) D
 ..		;
 ..		S userhdr=$piece(item,"@",2)
 ..		S item=$piece(item,"@",1)
 ..		Q 
 .	;
 .	I (item?1"["1E.E1"]"1E.E) D
 ..		;
 ..		S table=$piece($piece(item,"[",2),"]",1)
 ..		S column=$piece(item,"]",2)
 ..		I ($E(column,$L(column))="-") S column=$E(column,1,$L(column)-1)
 ..		Q 
 .	E  D  Q:isER 
 ..		;
 ..		N isFOUND S isFOUND=0
 ..		N I
 ..		;
 ..		F I=1:1:$S((TABLES=""):0,1:$L(TABLES,",")) D  Q:isFOUND 
 ...			;
 ...			S table=$piece(TABLES,",",I)
 ...			;
 ...			N rs,vos1,vos2,vos3,vos4  N V1,V2 S V1=table,V2=item S rs=$$vOpen1()
 ...			;
 ...			I $$vFetch1() D
 ....				;
 ....				S isFOUND=1
 ....				S column=item
 ....				Q 
 ...   Q 
 ..		;
 ..		I 'isFOUND D
 ...			;
 ...			I ((item?1"%".AN)!(item?1A.AN)) D
 ....				;
 ....				; Invalid data item - ~p1
 ....				S return=return_"; "_$$^MSG(1298,item)
 ....				S isER=1
 ....				Q 
 ...			; Expression, not column
 ...			E  D
 ....				;
 ....				N retval
 ....				;
 ....				S retval=$$FIXFMT^DBSEXEQ(item,TABLES,.len,.dec,.fmt)
 ....				;
 ....				I (retval="") D
 .....					;
 .....					S len=1
 .....					S dec=0
 .....					S fmt="T"
 .....					; Invalid data item
 .....					S userhdr=$$^MSG(1298)
 .....					Q 
 ....				Q 
 ...			Q 
 ..		Q 
 .	;
 .	I '(column="") D
 ..		;
 ..		N rs,vos5,vos6,vos7,vos8,vos9  N V1,V2 S V1=table,V2=column S rs=$$vOpen2()
 ..		;
 ..		I $$vFetch2() D
 ...   S len=$P(rs,$C(9),1)
 ...   I (len>132),($P(rs,$C(9),4)>0) S len=$P(rs,$C(9),4)
 ...   S dec=$P(rs,$C(9),3)
 ...   S fmt=$P(rs,$C(9),2)
 ...   S hdr=$P(rs,$C(9),6)
 ...   I (hdr="") S hdr=$P(rs,$C(9),5)
 ...			Q 
 ..  Q 
 .	;
 .	I ($D(userhdr)#2) S hdr=userhdr
 .	;
 .	I ((fmt="U")!(fmt="F")) S fmt="T"
 .	;
 .	I (fmt="$") D
 ..		;
 ..		S fmt="E"
 ..		S len=len+2
 ..		S fun="SUM"
 ..		Q 
 .	E  I (fmt="N"),(dec>0) S fmt="RD"_dec
 .	;
 .	S indent=2
 .	I (userind>0) D
 ..		;
 ..		S indent=indent+userind
 ..		S userind=0
 ..		Q 
 .	;
 .	S hdr=$E(hdr,1,35)
 .	;
 .	I (seq=1),(indent=2) S indent=0
 .	;
 .	; Set field length to max of field or header
 .	F j=1:1:$L(hdr,"@") I ($L($piece(hdr,"@",j))>len) S len=$L($piece(hdr,"@",j))
 .	;
 .	I (fun=""),(",T,U,F,D,C,"[(","_fmt_",")),'isCNTFUN D
 ..		;
 ..		S fun="CNT"
 ..		S isCNTFUN=1
 ..		Q 
 .	;
 .	I (indent<0) S indent=0
 .	;
 .	S DBSATT(seq)=item_"|"_hdr_"|"_indent_"|"_len_"|"_fmt_"|"_fun
 .	;
 .	S pos=pos+indent+len
 .	Q 
 ;
 I ($E(return,1,2)="; ") S return=$E(return,3,1048575)
 ;
 Q return
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61276^62572^Dan Russell^4951" ; Signature - LTD^TIME^USER^SIZE
 ;
vOpen1() ; DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1 AND DI=:V2
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL1a0
 S vos4=$G(V2) I vos4="" G vL1a0
 I '($D(^DBTBL("SYSDEV",1,vos3,9,vos4))#2) G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos1=100
 S rs=vos4
 S vos1=0
 ;
 Q 1
 ;
vOpen2() ; LEN,TYP,DEC,SIZ,DES,RHD FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1 AND DI=:V2
 ;
 ;
 S vos5=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos5=0 Q
vL2a1 S vos6=$$BYTECHAR^SQLUTL(254)
 S vos7=$G(V1) I vos7="" G vL2a0
 S vos8=$G(V2) I vos8="" G vL2a0
 I '($D(^DBTBL("SYSDEV",1,vos7,9,vos8))#2) G vL2a0
 Q
 ;
vFetch2() ;
 ;
 ;
 ;
 I vos5=0 S rs="" Q 0
 ;
 S vos5=100
 S vos9=$G(^DBTBL("SYSDEV",1,vos7,9,vos8))
 S rs=$P(vos9,"|",2)_$C(9)_$P(vos9,"|",9)_$C(9)_$P(vos9,"|",14)_$C(9)_$P(vos9,"|",19)_$C(9)_$P(vos9,"|",10)_$C(9)_$P(vos9,"|",22)
 S vos5=0
 ;
 Q 1
