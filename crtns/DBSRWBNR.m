DBSRWBNR(IO,BNRINFO)	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSRWBNR ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	N N
	N ALLEQLS N DESC N LINE N RID N TABLOC
	;
	S DESC=$get(BNRINFO("DESC"))
	;
	S ALLEQLS=""
	S $piece(ALLEQLS,"=",$L(DESC)+1)="" ; ===== line
	S TABLOC=(75-$L(DESC))\2 ; Tab location
	S LINE=""
	S $piece(LINE,"-",71)="" ; ----- line
	;
	; Description
	USE IO WRITE !,?TABLOC,ALLEQLS,!,?TABLOC,DESC,!,?TABLOC,ALLEQLS,!!!
	;
	; Documentation
	I $order(BNRINFO("DOC","")) D
	.	N I N N
	.	;
	.	S N=""
	.	WRITE !?5,LINE
	.	F I=1:1 S N=$order(BNRINFO("DOC",N)) Q:(N="")  WRITE !?5,BNRINFO("DOC",N)
	.	WRITE !?5,LINE,!
	.	I I>21 WRITE $char(12),! ; New page
	.	Q 
	;
	WRITE !,"              User: ",%UID
	WRITE ?45,"Run: ",$$vdat2str($P($H,",",1),"MM/DD/YEAR"),"  ",$$TIM^%ZM,!
	I $get(TJD) WRITE ?42,"System: ",$S(TJD'="":$ZD(TJD,"MM/DD/YEAR"),1:""),!
	WRITE !
	;
	S RID=BNRINFO("RID")
	I $E(RID,1,5)="QWIK_" D  ; QWIK report
	.	WRITE "       QWIK Report: "
	.	WRITE $E(RID,6,1048575)
	.	Q 
	E  WRITE "            Report: ",RID
	;
	WRITE ?41,"Program: ",$get(BNRINFO("PGM"))
	;
	; File(s):
	WRITE !!,$J($$^MSG(3479),20),$get(BNRINFO("TABLES"))
	;
	WRITE !!,"          Order By: "
	D
	.	N N S N=""
	.	N X
	.	;
	.	F  S N=$order(BNRINFO("ORDERBY",N)) Q:(N="")  D
	..		S X=BNRINFO("ORDERBY",N)
	..		WRITE ?20,$$DES^DBSDD(X),!
	..		Q 
	.	Q 
	;
	I $D(BNRINFO("PROMPTS")) D
	.	N N S N=""
	.	N X
	.	;
	.	WRITE !!,"             Input: "
	.	F  S N=$order(BNRINFO("PROMPTS",N)) Q:(N="")  D
	..		S X=BNRINFO("PROMPTS",N)
	..		WRITE ?20,$piece(X,"|",2)," "
	..		WRITE $piece(X,"|",4,99),!
	..		Q 
	.	Q 
	;
	; Break WHERE clause into 60 character chunks to pring
	WRITE !!,?5,$E(LINE,1,31)," WHERE ",$E(LINE,1,32),!!
	I '($get(BNRINFO("WHERE"))="") D
	.	N I
	.	N X
	.	;
	.	S X=BNRINFO("WHERE")
	.	F  D  Q:(X="") 
	..		I $L(X)<60 D
	...			WRITE ?10,X,!
	...			S X=""
	...			Q 
	..		E  D
	...			F I=60:-1:1 Q:$E(X,I)=" " 
	...			WRITE ?10,$E(X,1,I),!
	...			S X=$E(X,I+1,1048575)
	...			Q 
	..		Q 
	.	Q 
	E  WRITE ?32,"No WHERE clause",!
	;
	WRITE !,?5,LINE,!!
	;
	Q 
	;
vSIG()	;
	Q "59939^40012^Dan Russell^2775" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vdat2str(object,mask)	; Date.toString
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I (object="") Q ""
	I (mask="") S mask="MM/DD/YEAR"
	N cc N lday N lmon
	I mask="DL"!(mask="DS") D  ; Long or short weekday
	.	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
	.	I (cc="") S cc="US"
	.	S lday=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
	.	S mask="DAY" ; Day of the week
	.	Q 
	I mask="ML"!(mask="MS") D  ; Long or short month
	.	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
	.	I (cc="") S cc="US"
	.	S lmon=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
	.	S mask="MON" ; Month of the year
	.	Q 
	Q $ZD(object,mask,$get(lmon),$get(lday))
