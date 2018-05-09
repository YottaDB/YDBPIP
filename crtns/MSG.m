 ; 
 ; **** Routine compiled from DATA-QWIK Procedure MSG ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
MSG(MSGID,p1,p2,p3,p4,p5) ; 
 ;
 N v N vmsg N vret
 N vi N vofst
 ;
 N utblmsg S utblmsg=$G(^UTBL("MSG",MSGID))
 ;
 S vmsg=$P(utblmsg,$C(124),1)
 ;
 I (vmsg="") D
 .	;
 .	N stblmsg S stblmsg=$G(^STBL("MSG",MSGID))
 .	;
 .	S vmsg=$P(stblmsg,$C(124),1)
 .	;
 .	I (vmsg="") D
 ..		;
 ..		N ermsg N ET N RM N %ZTSEQ N %ZTX
 ..		;
 ..		S ET="INVLDMSG"
 ..		D ^UTLERR
 ..		S p1=MSGID
 ..		;
 ..		; Message ~p1 not found
 ..		N msg S msg=$G(^STBL("MSG",1721))
 ..		;
 ..		S vmsg=$P(msg,$C(124),1)
 ..		; I18N=OFF
 ..		I (vmsg="") S vmsg="Message "_MSGID_" not found"
 ..		; I18N=ON
 ..  Q 
 . Q 
 ;
 S vret=""
 S (vi,vofst)=0
 F  S vi=$F(vmsg,"~p",vi-vofst) Q:(vi=0)  D
 .	;
 .	S vofst=0
 .	S v=$E(vmsg,vi-1,vi)
 .	;
 .	; Accept use of indirection
 .	;   #ACCEPT Date=11/22/04; PGM=Dan Russell; CR=13365
 .	S v=$get(@v)
 .	;
 .	S $piece(vret,"|",$E(vmsg,vi))=v
 .	;
 .	I (v="") D
 ..		;
 ..		S vofst=2
 ..		;
 ..		I (vi=3),($E(vmsg,4)=" ") S vmsg=$E(vmsg,1,vi)_$E(vmsg,vi+2,1048575) Q 
 ..		;
 ..		I ($E(vmsg,vi-3)=" "),($E(vmsg,vi+1)=" ") S vmsg=$E(vmsg,1,vi)_$E(vmsg,vi+2,1048575)
 ..		Q 
 .	;
 .	S vmsg=$E(vmsg,1,vi-3)_v_$E(vmsg,vi+1,1048575)
 .	Q 
 ;
 S %MSGID=MSGID_"|"_vret
 ;
 Q vmsg
 ;
V2LV(val,fs,opt) ; Sub-field option [*]  /NOREQ/DFT=false
 ;
 N x N y
 ;
 S x=""
 I ($D(val)#2) D
 .	;
 .	N i
 .	;
 .	I ($get(fs)="") S x=$$LV(val)
 .	E  F i=1:1:$L(val,fs) S y=$piece(val,fs,i) S x=x_$$LV(y)
 .	Q 
 E  S y="" F  S y=$order(val(y)) Q:(y="")  S x=x_$$LV(val(y))
 ;
 I $get(opt) S x=$$LV(x)
 ;
 Q x
 ;
LV(val) ; Value of field/record
 ;
 N len
 N x N xarr
 ;
 ; Determine the length of 'val' in bytes + 1 for the length field
 S x=$ZLENGTH(val)+1
 ;
 I (x>255) D
 .	;
 .	N i N n
 .	;
 .	F i=1:1 S xarr(i)=x#256 S x=x\256 Q:(x=0)  S xarr(1)=xarr(1)+1
 .	F i=1:1 Q:(xarr(i)<256)  S xarr(i)=xarr(i)#256 S xarr(i+1)=$get(xarr(i+1))+1
 .	;
 .	S n=$order(xarr(""),-1)
 .	S len=$ZCHAR(0)_$ZCHAR(n)
 .	F i=n:-1:1 S len=len_$ZCHAR(xarr(i))
 .	Q 
 E  S len=$ZCHAR(x)
 ;
 Q len_val
 ;
LV2V(msg,arr,ptr,num) ; Number of fields requested /NOREQ/DFT=ALL
 ;
 N exit
 N fld N i N len N ln N n N sub N x
 ;
 ; Determine the length of 'msg' in bytes
 S len=$ZLENGTH($get(msg))
 I (len=0) Q 0
 ;
 I ($get(ptr)'>0) S ptr=1
 S num=+$get(num)
 ;
 S sub=$order(arr(""),-1)
 ;
 S fld=0
 S exit=0
 ;
 F  D  Q:exit 
 .	;
 .	I (ptr>len) S exit=1 S ptr="" Q 
 .	;
 .	I num,(fld=num) S exit=1 Q 
 .	;
 .	S ln=$ZASCII($ZEXTRACT(msg,ptr))
 .	S n=1
 .	;
 .	I (ln=0) D  Q:exit 
 ..		;
 ..		S n=$ZASCII($ZEXTRACT(msg,ptr+1))
 ..		S ptr=ptr+2
 ..		;
 ..		; Msg terminator
 ..		I (n=0) S exit=1 S ptr="" Q 
 ..		;
 ..		S x=1
 ..		F i=n-1:-1:0 S ln=($ZASCII(msg,ptr+i)*x)+ln S x=x*256
 ..		Q 
 .	;
 .	S fld=fld+1
 .	S sub=sub+1
 .	S arr(sub)=$ZEXTRACT(msg,ptr+n,ptr+ln-1)
 .	S ptr=ptr+ln
 .	Q 
 ;
 Q ptr
 ;
COLUMN(row,delim,arr) ; Output array  /NOREQ/REFARR:W
 ;
 N n N x
 N del N str
 ;
 I ($get(delim)="") S delim=44
 S del=$char(delim)
 ;
 S n=+$order(arr(""),-1)
 S str=row
 S x=0
 ;
 F  S x=$F(str,del,x) Q:(x=0)  I ($L($E(str,1,x-2),"""")#2) D
 .	;
 .	S n=n+1
 .	;
 .	S arr(n)=$$unq($E(str,1,x-2))
 .	S str=$E(str,x,1048575)
 .	S x=0
 .	Q 
 ;
 S n=n+1
 S arr(n)=str
 ;
 Q n
 ;
NXTCOL(row,delim,ptr) ; Starting pointer position /NOREQ/DFT=1/MECH=REFNAM:RW
 ;
 N x
 N del N v
 ;
 I ($get(delim)="") S delim=44
 S del=$char(delim)
 ;
 S ptr=+$get(ptr)
 S x=ptr
 ;
 F  S x=$F(row,del,x) I ($L($E(row,1,x-2),"""")#2) D  Q 
 .	;
 .	I x S v=$$unq($E(row,ptr,x-2))
 .	E  S v=$E(row,ptr,1048575)
 .	Q 
 ;
 S ptr=x
 ;
 Q v
 ;
unq(v) ; This private function "Unquotes" text.
 ;
 I ($E(v,1)=""""),($E(v,$L(v))="""") S v=$E(v,2,$L(v)-1)
 ;
 Q v
 ;
NEXTVAL ; Returns the highest key value +1
 ;
 S VNMSGID=$O(^STBL("MSG",""),-1)+1
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61403^56841^FSCW^9354" ; Signature - LTD^TIME^USER^SIZE
