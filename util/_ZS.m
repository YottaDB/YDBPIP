%ZS	;LIBRARY;String Manipulation functions
	;;Copyright(c)1998 Sanchez Computer Associates, Inc.  All Rights Reserved - 07/01/98 11:00:33 - SYSCHENARD
	; ORIG: FSANCHEZ   07 - NOV - 1991
	;
	; Library of String manipulation functions
	;
	; LIBRARY:
	;     	. NPC		Next Piece skipping delimited strings
	;	. LTRIM		Trim Left blank spaces
	;	. RTRIM		Trim Right blank spaces
	;	. TRIM		Trim left and right spaces
	;	. TOKEN		Tokenize a string
	;	. UNTOK		Untokenize a string
	;	. ATOM		Return next expression atom
	;	. PXP		Return Logical Paranthesis string
	;	. SQL		Tokenize a string using SQL syntax
	;	. QADD		Add a layer of quotes to a string
	;	. QSUB		Remove a layer of quoted from a string
	;	. QSWP		Swap Quote Characters
	;	. MERGE		Merge string lists
	;
	;
	;-----Revision History-------------------------------------------------
	;
	; 07/01/98 - Frank Sanchez
	;            Changes made to support the M++ compiler.
	;
	; 08/13/96 - Frank Sanchez - 20948
	;            Modified TOKEN and UNTOK sections to support binary and
	;            memo data types.
	;
	; 06/11/96 - Frank Sanchez - 21736
	;            Modified to support scaler functions.
	;
        ; 06/03/96 - Bob Chiang - 20948
        ;            Modified ATOM section to allow maximum of 35 user-defined
        ;            delimiters.
	;
	; 01/16/96 - SPIER - 17591
	;            Added "'" to items which to call TOKEN in parspar section.
	;	     This allows EFD='12/12/95' to be treated correctly.
	;
	; 01/14/96 - Frank Sanchez - 17591
	;            Modified QSUB section to convert '' SQL syntax into MUMPS
	;            "" syntax.
	;
	; 11/20/95 - Frank Sanchez
	;            New function, NPC added.  Modified TRIM.
	;
	;----------------------------------------------------------------------
NPC(str,ptr,subq)	;Public; Get next piece after pointer
	;----------------------------------------------------------------------
	;
	I '$D(ptr) S ptr=0
	;
	N z
	S z=ptr
	F  S ptr=$F(str,",",ptr) Q:ptr=0!($L($E(str,z,ptr-2),"""")#2)
	;
	I ptr=0,z'>$L(str) S ptr=$L(str)+2
	S str=$E(str,z,ptr-2)
	;
	I $G(subq),str["""" S str=$$QSUB(str)
	Q str
	;
	;----------------------------------------------------------------------
LTRIM(str)	;Public; Trim whitespace from front of string
	;----------------------------------------------------------------------
	;
	I $E(str)=" " F  S str=$E(str,2,$L(str)) Q:$E(str)'=" "
	Q str
	;
	;----------------------------------------------------------------------
TRIM(str)	;Public; Trim whitespace (blanks) from string
	;----------------------------------------------------------------------
	;
	I $E(str)=" " F  S str=$E(str,2,$L(str)) Q:$E(str)'=" "
	I $E(str,$L(str))=" " F  S str=$E(str,1,$L(str)-1) Q:$E(str,$L(str))'=" "
	;
	Q str
	;
	;----------------------------------------------------------------------
RTRIM(str)	;Public; Trim whitespace from back of string
	;----------------------------------------------------------------------
	;
	I $E(str,$L(str))=" " F  S str=$E(str,1,$L(str)-1) Q:$E(str,$L(str))'=" "
	Q str
	;
	;----------------------------------------------------------------------
QSWP(str,qa,qb)	; Replace occurrances of qa with qb and double qb's
	;----------------------------------------------------------------------
	;
	I $E(str)=qa Q $$QADD($$QSUB(str,.qa),.qb)		; Nested
	Q $TR(str,qa,qb)
	;
	;----------------------------------------------------------------------
QSUB(str,q)	; Remove a layer of qoutes from a string
	;----------------------------------------------------------------------
	;
	I $G(q)="" S q=""""
	;
	I $E(str)=q,$E(str,$L(str))=q S str=$E(str,2,$L(str)-1) ; *** 01/14/95 
	I str[q=0 Q str
	; 
	N y
	S y=0
	;
	F  S y=$F(str,q,y) Q:'y  S str=$E(str,1,y-2)_$E(str,y,$L(str))
	Q str
	;
	;----------------------------------------------------------------------
QADD(str,q)	; Add a layer of quotes to a string
	;----------------------------------------------------------------------
	;
	I $G(q)="" S q=""""
	;
 	N y
	S y=0
	;
	F  S y=$F(str,q,y) Q:'y  S str=$E(str,1,y-1)_q_$E(str,y,$L(str)),y=y+1
	Q q_str_q
	;
	;----------------------------------------------------------------------
UNTOK(str,tok)	; Replace token with original string
	;----------------------------------------------------------------------
	;
	N v,y,z
	;
	S y=0
	F  S y=$F(str,$C(0),y) Q:y=0  S z=$F(str,$C(0),y) Q:z=0  S v=$E(str,y,z-2),v=$S($E(v)="+":$G(tok($E(v,2,$L(v)))),1:$P(tok,$C(1),v)),str=$E(str,1,y-2)_v_$E(str,z,$L(str)),y=y+$L(v)
	Q str
	;
	;----------------------------------------------------------------------
TOKEN(str,tok,dl)	; Tokenize delimited strings
	;----------------------------------------------------------------------
	;
	S ER=0
	;
	I $G(dl)="" S dl=""""
	;
	N d,n,y,z
	;
	F  S y=$F(str,dl) Q:y=0  D  I ER Q
	.	;
	.	S z=$F(str,dl,y)
	.	F  Q:$E(str,z)'=dl&($L($E(str,y,z),dl)#2=0)  S z=$F(str,dl,z) Q:z=0
	.	I z=0 D ERROR(dl_" Expected") Q
	.	;
	.	S d=$E(str,y-1,z-1)
	.	I d[$C(1) S n=$O(tok(""),-1)+1,tok(n)=d,n="+"_n
	.	E  I $G(tok)="" S tok=d,n=1
	.	E  I $C(1)_tok_$C(1)[($C(1)_d_$C(1)) S n=$L($P($C(1)_tok_$C(1),$C(1)_$E(str,y-1,z-1)_$C(1)),$C(1))
	.	E  S tok=tok_$C(1)_d,n=$L(tok,$C(1))
	.	S str=$E(str,1,y-2)_$C(0)_n_$C(0)_$E(str,z,$L(str))
	;
	I $G(tok)="" S tok=$C(1)			; Force
	Q str
	;
	;-----------------------------------------------------------------------
ATOM(str,ptr,tbl,tok,cvt)	;Public; Return next delimiter position from array
	;-----------------------------------------------------------------------
	;
	N y,z
	;
	F ptr=ptr+1:1 Q:$E(str,ptr)'=" "
	;
	S y=$F(str," ",ptr) 
	S y=$S(y=0:$L(str),1:y-2)
	;
	I y=ptr S:y=$L(str) ptr=0 S z=$E(str,y) S:z="("&(tbl'["(") z=$$PXP(str,.ptr) Q z
	;
        S z=$TR($E(str,ptr,y),tbl,"                                   ")
	I z'[" " S z=$E(str,ptr,y),ptr=$S(y<$L(str):y,1:0)
	;
	E  D
	.	S y=$F(z," ")
	.	I y=2 S z=$E(str,ptr) Q
	.	S y=y-3,z=$E(str,ptr,ptr+y),ptr=ptr+y
	;
	I z["(",tbl'["(",'($L(z,"(")=$L(z,")")),ptr D
	.	;
	.	S ptr=ptr-$L(z)+1
	.	S z=$$PXP(str,.ptr)
	.	I ptr,'(tbl_" "[$E(str,ptr+1)) S z=z_$$ATOM(str,.ptr,tbl,.tok)
	;
	I $A(z)=0,'$G(cvt) S z=$$UNTOK(z,.tok)		; Convert to string
	Q z
	;
	;----------------------------------------------------------------------
PXP(str,ptr,pop)	;Public; Return logical paranthesis expression from a tokenized string
	;----------------------------------------------------------------------
	;
	I $G(ptr)="" S ptr=0
	;
	N d,y
	S y=$F(str,")",ptr)
  	F  S d=$E(str,ptr,y-1) Q:$L(d,"(")=$L(d,")")  S y=$F(str,")",y) Q:y=0
	S ptr=$S(y<$L(str):y-1,1:0)
 	;
	I y=0 S ptr=0 D ERROR(") expected") Q ""
	Q d
	;
	;----------------------------------------------------------------------
POP(str)	;Public; Pop a parenthesis level and remove redundants
	;----------------------------------------------------------------------
	;
	N y 
	S y=1,str=$$TRIM(str)
	F  Q:$E(str)'="("  S y=$F(str,")",y) Q:y=0  I $L($E(str,1,y-1),"(")=$L($E(str,1,y-1),")") Q:y'>$L(str)  S str=$$TRIM($E(str,2,$L(str)-1)),y=1
	Q $$TRIM(str)
	;
	;--------------------------------------------------------------------
PARSPAR(str,ar,dl)	; Parse parameter string into array
	;--------------------------------------------------------------------
	;
	I $G(str)="" Q
	I $G(dl)="" S dl="/"
	;
	N tok,i,v,z
	;
	I str["'" S str=$$TOKEN(str,.tok,"'")
	I str["""" S str=$$TOKEN(str,.tok)
	;
	F i=1:1:$L(str,dl) D
	.	;
	.	S z=$P(str,dl,i),v=$P(z,"=",2,999),z=$P(z,"=",1) I z="" Q
	.	I v="" S v='($E(z,1,2)="NO") S:v=0 z=$E(z,3,$L(z))
	.	I $E(v)="(" S v=$E(v,2,$L(v)-1)
	.	I v[$C(0) S v=$$UNTOK(v,.tok) I "'"""[$E(v) S v=$$QSUB(v,$E(v))
	.	;
   	.	S ar(z)=v
	Q
	;
	;--------------------------------------------------------------------
SQL(str,tok)	; Tokenize input string from SQL source
	;--------------------------------------------------------------------
	;
	N y
	S y=0
	;
	S ER=0
	S str=$$TOKEN(.str,.tok,"'") I ER Q ""		; Tokenize Literals
	S str=$$TOKEN(.str,.tok,"""") I ER Q ""		; Tokenize Data Items
	S str=$TR(str,$C(9,13,10),"   ")		; Replace tabs,CR,LF/space
	;
        F  S y=$F(str,"  ",y) Q:y=0  S str=$E(str,1,y-2)_$E(str,y,$L(str)),y=y-2
        F  S y=$F(str,", ",y) Q:y=0  S str=$E(str,1,y-2)_$E(str,y,$L(str)),y=y-2
        F  S y=$F(str," ,",y) Q:y=0  S str=$E(str,1,y-3)_$E(str,y-1,$L(str)),y=y-2
	;
	I $E(str)=" " S str=$E(str,2,$L(str))
	I $E(str,$L(str))=" " S str=$E(str,1,$L(str)-1)
	;
	Q $TR(str,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
	;
	;
	;--------------------------------------------------------------------
MERGE(s1,s2,dl)	; Merge lists s1 and s2
	;--------------------------------------------------------------------
	;
	I $G(s2)="" Q s1
	I $G(s1)="" Q s2
	I $G(dl)="" S dl=","
	;
	N i
	F i=1:1:$L(s2,dl) I '$$CONTAIN(s1,$P(s2,dl,i)) S s1=s1_dl_$P(s2,dl,i)
	Q s1
	;
CONTAIN(A,B)	Q (","_A_",")[(","_B_",")
	;
ERROR(str)	;
	;
	S ER=1,RM=$G(str)
	Q
