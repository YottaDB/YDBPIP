SQLEFD(EFDATE,sqlbuff)	;
	;
	; **** Routine compiled from DATA-QWIK Procedure SQLEFD ****
	;
	; 11/08/2007 14:08 - chenardp
	;
	;
	N BUFF N N N SEQ
	N newbuff
	;
	S ER=$$SQLPARSE(.sqlbuff,.newbuff,.RM) Q:ER 
	;
	F  D  Q:'(BUFF="") 
	.	;
	.	S BUFF=$$GETSEQ^SQLDD
	.	I ($D(^EFD(EFDATE,BUFF,1))#2) D
	..		S BUFF=""
	..		HANG 1
	..		Q 
	.	Q 
	;
	S SEQ=0
	S N=""
	F  S N=$order(newbuff(N)) Q:(N="")  D
	.	;
	.	S SEQ=SEQ+1
	.	;
	.	N efd S efd=$$vDbNew1(EFDATE,BUFF,SEQ)
	.	 S vobj(efd,1,1)=""
	.	;
	. S $P(vobj(efd),$C(124),2)=$piece(newbuff(N),"|",2)
	. S $P(vobj(efd),$C(124),3)=$piece(newbuff(N),"|",3)
	. S vobj(efd,1,1)=$piece(newbuff(N),"|",1)
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^EFDFILE(efd,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(efd,-100) S vobj(efd,-2)=1 Tcommit:vTp  
	.	K vobj(+$G(efd)) Q 
	;
	Q 
	;
SQLPARSE(sqlbuff,newbuff,RM)	;
	;
	N ER
	N N
	N cmd N fsn N pkey N sql N table N val
	;
	S ER=0
	S N=""
	F  S N=$order(sqlbuff(N)) Q:(N="")  D  Q:ER 
	.	;
	.	S sql=$$vStrUC(sqlbuff(N))
	.	S cmd=$piece(sql," ",1)
	.	S table=$piece(sql," ",2)
	.	;
	.	I ((table="INTO")!(table="FROM")) S table=$piece(sql," ",3)
	.	;
	.	I '(",,IRATYPE,CIF,DEP,LN,ACNADDR,SADDRCIF,SADDRACN,,"[(","_table_",")),$E(table,1)'="Z" D  Q 
	..		S ER=1
	..		; Future-dated maintenance capability is enabled for CIF, DEP,
	..		; LN, ACNADDR, IRATYPE, SADDRCIF, and SADDRACN tables only
	..		S RM=$$^MSG(3478)
	..		Q 
	.	;
	.	D fsn^DBSDD(.fsn,table)
	.	;
	.	S pkey=$piece($piece(fsn(table),"|",3),",",1)
	.	;
	.	S newbuff(N)=$$hostvar(sqlbuff(N),.ER,.RM) Q:ER 
	.	S val=""
	.	I (cmd="INSERT") D  ; Get primary key value
	..		;
	..		N i
	..		N column N tok N value N z
	..		;
	..		S column=$piece($piece(sql,"(",2),")",1) ; Column list
	..		S value=$piece($piece(newbuff(N),"(",3),")",1) ; Value list
	..		;
	..		; Match key name
	..		F i=1:1:$L(column,",") Q:$piece(column,",",i)=pkey 
	..		;
	..		S z=$$TOKEN^%ZS(value,.tok,"'") ; In token format
	..		S val=$piece(z,",",i) ; Key value
	..		Q 
	.	E  I ((cmd="UPDATE")!(cmd="DELETE")) D
	..		;
	..		N i
	..		N where N z
	..		;
	..		S where=$piece(sql,"WHERE ",2) ; WHERE clause
	..		;
	..		F i=1:1:$L(where," AND ") D
	...			;
	...			S z=$piece(where," AND ",i)
	...			I ($$vStrTrim($piece(z,"=",1),0," ")=pkey) S val=$$vStrTrim($piece(z,"=",2),0," ")
	...			Q 
	..		Q 
	.	E  D  Q 
	..		S ER=1
	..		; Invalid SQL Command ~p1
	..		S RM=$$^MSG(8564,sqlbuff(N))
	..		Q 
	.	;
	.	S val=$translate(val,"' ","") ; Remove ' and blanks
	.	I (val="") D  Q 
	..		S ER=1
	..		; Access key ~p1 is not defined
	..		S RM=$$^MSG(48,pkey)
	..		Q 
	.	;
	.	S newbuff(N)=newbuff(N)_"|"_table_"|"_val
	.	Q 
	;
	Q ER
	;
hostvar(expr,ER,RM)	;
	;
	N i
	N del N str1 N str2 N var
	;
	S ER=0
	;
	F  Q:'(expr[":")  D  Q:ER 
	.	;
	.	S str1=$piece(expr,":",1)
	.	S str2=$piece(expr,":",2,99)
	.	;
	.	F i=1:1:$L(str2) S del=$E(str2,i) Q:((del=" ")!(del=",")!(del=")")) 
	.	I ((del=" ")!(del=",")) D
	..		S var=$piece(str2,del,1)
	..		S str2=$piece(str2,del,2,99)
	..		Q 
	.	E  D  ; Last :var
	..		I (del'=")") S del=""
	..		S var=str2
	..		S str2=""
	..		Q 
	.	;
	.	;   #ACCEPT Date=09/27/07;PGM=RussellDS;CR=17311
	.	I '$D(@var) D  Q 
	..		S ER=1
	..		; Undefined Host Variable ~p1
	..		S RM=$$^MSG(8592,var)
	..		Q 
	.	;
	.	S var=@var
	.	I '(var=+var) S var="'"_var_"'"
	.	S expr=str1_var_del_str2
	.	Q 
	;
	Q expr
	;
vSIG()	;
	Q "60172^39223^Dan Russell^4431" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
	; ----------------
	;  #OPTION ResultClass 0
vStrTrim(object,p1,p2)	; String.trim
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I p1'<0 S object=$$RTCHR^%ZFUNC(object,p2)
	I p1'>0 F  Q:$E(object,1)'=p2  S object=$E(object,2,1048575)
	Q object
	;
vDbNew1(v1,v2,v3)	;	vobj()=Class.new(EFD)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordEFD",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
