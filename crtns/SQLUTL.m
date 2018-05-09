SQLUTL	;
	;
	; **** Routine compiled from DATA-QWIK Procedure SQLUTL ****
	;
	; 11/08/2007 14:08 - chenardp
	;
	;
	Q 
	;
ROWS(str)	;
	;
	N del N row N rows
	N i N size
	;
	S del=$char(255)
	S size=0
	;
	F i=1:1:$L(str,del)-1 D
	.	S row=$piece(str,del,i)
	.	S size=size+($ascii(row,8)*256)
	.	S size=size+($ascii(row,9))+2
	.	Q 
	;
	S rows=(1022000-$L(str))\(size+2)
	I rows<1 S rows=1
	;
	Q rows
	;
SQLDTA(str,sqlcur,sqldta)	;
	;
	N v
	N len
	N del
	;
	S del=$char(255)
	;
	S v=sqlcur_del_str
	S len=$L(v)
	S sqldta=$char((len\256))_$char((len#256))_v_sqldta
	;
	Q sqldta
	;
LVU(str,ptr)	;
	;
	N z
	N len
	;
	I '($D(ptr)#2) S ptr=0
	S len=$ascii(str,ptr+1)*256
	S len=len+$ascii(str,ptr+2)
	;
	S ptr=ptr+len
	S z=$E(str,ptr-len+3,ptr)
	I ptr=$L(str)!(len<0) S ptr=0
	;
	Q z
	;
LVW(str)	;
	;
	N len
	;
	S len=$L(str)+2
	I len<256 Q $char(0)_$char(len)_str
	Q $char((len\256))_$char((len#256))_str
	;
BSL(str)	;
	Q $L(str)
	;
BSASCII(INSTRING,POS)	;
	;
	Q $ascii(INSTRING,POS)
	;
BYTECHAR(INNUM,INNUM2,INNUM3,INNUM4,INNUM5,INNUM6,INNUM7,INNUM8,INNUM9,INNUM10,INNUM11,INNUM12)	;
	;
	N str
	;
	S str=$char(INNUM)
	I ($D(INNUM2)#2) S str=str_$char(INNUM2)
	I ($D(INNUM3)#2) S str=str_$char(INNUM3)
	I ($D(INNUM4)#2) S str=str_$char(INNUM4)
	I ($D(INNUM5)#2) S str=str_$char(INNUM5)
	I ($D(INNUM6)#2) S str=str_$char(INNUM6)
	I ($D(INNUM7)#2) S str=str_$char(INNUM7)
	I ($D(INNUM8)#2) S str=str_$char(INNUM8)
	I ($D(INNUM9)#2) S str=str_$char(INNUM9)
	I ($D(INNUM10)#2) S str=str_$char(INNUM10)
	I ($D(INNUM11)#2) S str=str_$char(INNUM11)
	I ($D(INNUM12)#2) S str=str_$char(INNUM12)
	Q str
	;
BSE(str,start,end)	;
	Q $E(str,start,end)
	;
BSP(str,del,pos,endpos)	;
	I '($get(endpos)="") Q $piece(str,del,pos,endpos)
	Q $piece(str,del,pos)
	;
vSIG()	;
	Q "60838^37433^Pete Chenard^4795" ; Signature - LTD^TIME^USER^SIZE
