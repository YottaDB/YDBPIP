 ; 
 ; **** Routine compiled from DATA-QWIK Procedure SQLUTL ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
 ;  #PACKAGE framework.sql
 ;  #OPTION ResultClass ON
 ;
 Q 
 ;
ROWS(str) ; 
 ;
 N del N row
 N i N size N rows
 ;
 S del=$ZCHAR(255)
 S size=0
 ;
 F i=1:1:$ZLENGTH(str,del)-1 D
 .	S row=$ZPIECE(str,del,i)
 .	S size=size+($ZASCII(row,8)*256)
 .	S size=size+$ZASCII(row,9)+2
 .	Q 
 ;
 S rows=(1022000-$ZLENGTH(str))\(size+2)
 I rows<1 S rows=1
 ;
 Q rows
 ;
SQLDTA(str,sqlcur,sqldta) ; 
 ;
 N v
 N len
 N del
 ;
 S del=$ZCHAR(255)
 ;
 S v=sqlcur_del_str
 S len=$ZLENGTH(v)
 S sqldta=$ZCHAR((len\256))_$ZCHAR((len#256))_v_sqldta
 ;
 Q sqldta
 ;
LVU(str,ptr) ; 
 ;
 N z
 N len
 ;
 I '($D(ptr)#2) S ptr=0
 S len=$ZASCII(str,ptr+1)*256
 S len=len+$ZASCII(str,ptr+2)
 ;
 S ptr=ptr+len
 S z=$ZEXTRACT(str,ptr-len+3,ptr)
 I ptr=$ZLENGTH(str)!(len<0) S ptr=0
 ;
 Q z
 ;
LVW(str) ; 
 ;
 N len
 ;
 S len=$ZLENGTH(str)+2
 I len<256 Q $ZCHAR(0)_$ZCHAR(len)_str
 Q $ZCHAR((len\256))_$ZCHAR((len#256))_str
 ;
BSL(str) ; 
 Q $ZLENGTH(str)
 ;
BSASCII(INSTRING,POS) ; Position
 ;
 Q $ZASCII(INSTRING,POS)
 ;
BYTECHAR(INNUM,INNUM2,INNUM3,INNUM4,INNUM5,INNUM6,INNUM7,INNUM8,INNUM9,INNUM10,INNUM11,INNUM12) ; 
 ;
 N str
 ;
 S str=$ZCHAR(INNUM)
 I ($D(INNUM2)#2) S str=str_$ZCHAR(INNUM2)
 I ($D(INNUM3)#2) S str=str_$ZCHAR(INNUM3)
 I ($D(INNUM4)#2) S str=str_$ZCHAR(INNUM4)
 I ($D(INNUM5)#2) S str=str_$ZCHAR(INNUM5)
 I ($D(INNUM6)#2) S str=str_$ZCHAR(INNUM6)
 I ($D(INNUM7)#2) S str=str_$ZCHAR(INNUM7)
 I ($D(INNUM8)#2) S str=str_$ZCHAR(INNUM8)
 I ($D(INNUM9)#2) S str=str_$ZCHAR(INNUM9)
 I ($D(INNUM10)#2) S str=str_$ZCHAR(INNUM10)
 I ($D(INNUM11)#2) S str=str_$ZCHAR(INNUM11)
 I ($D(INNUM12)#2) S str=str_$ZCHAR(INNUM12)
 Q str
 ;
BYTECODE(INNUM) ; Input number
 N CHAR S CHAR=$S($ZCHSET="M":"$C(",1:"$ZCH(")
 ;
 S CHAR=CHAR_INNUM_")"
 Q CHAR
 ;
BSE(str,start,end) ; 
 Q $ZEXTRACT(str,start,end)
 ;
BSP(str,del,pos,endpos) ; 
 I '($get(endpos)="") Q $ZPIECE(str,del,pos,endpos)
 Q $ZPIECE(str,del,pos)
 ;
SAVE(name,vsql,exe) ; 
 N vTp
 ;
 I '($D(vsql("K"))#2) Q 
 ;
 N z
 ;  #ACCEPT GROUP=ACCESS;CR=38852;DATE=2009-04-10;PGM=Frans S.C. Witte
 S z=$char(0)_$char(2)_$char(0)_$char(2)_$$PACK^SQLCACHE(.vsql,.exe)
 ;
 N sqlcur S sqlcur=$$vRCgetRecord1^RecordSQLCUR(%TOKEN,name,0)
  S vobj(sqlcur,1,1)="" N von S von="" F  S von=$O(^SQLCUR(vobj(sqlcur,-3),vobj(sqlcur,-4),von)) quit:von=""  S vobj(sqlcur,1,1)=vobj(sqlcur,1,1)_^SQLCUR(vobj(sqlcur,-3),vobj(sqlcur,-4),von)
  S vobj(sqlcur,1,1)=z
 ;
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSQLCUR(sqlcur,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(sqlcur,-100) S vobj(sqlcur,-2)=1 TC:vTp  
 K vobj(+$G(sqlcur)) Q 
 ;
RESTORE(name,vsql,exe) ; 
 ;
 N i N z
 ;
 N sqlcur,vop1,vop2,vop3,vop4 S vop1=%TOKEN,vop2=name,sqlcur=$$vRCgetRecord1Opt^RecordSQLCUR(%TOKEN,name,0,.vop3)
  S vop4="" N von S von="" F  S von=$O(^SQLCUR(vop1,vop2,von)) quit:von=""  S vop4=vop4_^SQLCUR(vop1,vop2,von)
 I $G(vop3)=0 S ER=1 S RM="Cursor "_name_" is not OPEN" S sqlcnt=0 S sqldta="" Q 
 ;
 S z=vop4
 ;  #ACCEPT GROUP=ACCESS;CR=38852;DATE=2009-04-10;PGM=Frans S.C. Witte
 D UNPACK^SQLCACHE(z,.vsql,.exe)
 ;
 Q 
 ;
CLOSE(token,name) ; 
 ;
 ; Delete sqlcur entries on a close cursor
  K ^SQLCUR(token,name)
 ;
 Q 
 ;
SCATBL5A(RPCID,userClass) ; 
 ;
 N scatbl5a,vop1 S scatbl5a=$$vRCgetRecord1Opt^RecordSCATBL5A(RPCID,userClass,0,.vop1)
 ;
 I ($G(vop1)=0) Q ""
 I $P(scatbl5a,$C(124),1) Q 1
 Q 0
 ;
VALID24X7(ROUTINE) ; 
 N vret
 ;
 N utblrtns S utblrtns=$G(^UTBL("RTNS",ROUTINE))
 ;
 S vret=$P(utblrtns,$C(124),1) Q vret
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61461^41316^Frans S.C. Witte^8156" ; Signature - LTD^TIME^USER^SIZE
