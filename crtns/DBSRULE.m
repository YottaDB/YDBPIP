DBSRULE(skipmsg)	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSRULE ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	N vpc
	;
	N CODE N PGMNAME N TAB
	;
	S ER=0
	;
	S PGMNAME="VRULES"
	;
	S TAB=$char(9)
	;
	S CODE(1)="public "_PGMNAME_TAB_"// Validate rules "_$$vdat2str($P($H,",",1),"MM/DD/YEAR")_" "_$$TIM^%ZM_" - "_$get(%UID)
	S CODE(2)=TAB_"// Product rules routine compiled by DBSRULE from table UTBLPRODRL"
	S CODE(3)=TAB_"// Run routine DBSRULE or build DEP/LN filer to re-create this routine"
	S CODE(4)=""
	S CODE(5)=TAB_"quit"_TAB_"// No entry from top"
	;
	N ds,vos1,vos2 S ds=$$vOpen1()
	;
	S vpc=('$G(vos1)) Q:vpc  ; No rules defined
	;
	F  Q:'($$vFetch1())  D  Q:ER 
	.	;
	.	N N N RULEID
	.	N FILES N INPUT N JOINFILS N PRIMARY N QRYS
	.	;
	.	N prodrl,vop1 S vop1=ds,prodrl=$G(^UTBL("PRODRL",vop1))
	.	;
	.	S RULEID=vop1
	.	S FILES=$P(prodrl,$C(124),4)
	.	;
	.	I ((","_FILES_",")[",DEP,") S PRIMARY="DEP"
	.	E  I ((","_FILES_",")[",LN,") S PRIMARY="LN"
	.	E  S PRIMARY="ACN"
	.	;
	.	; Entry tag
	.	D ADDCODE("",.CODE)
	.	;
	.	S CODE="public vr"_RULEID_"(Record"_PRIMARY_" "_PRIMARY_")"
	.	S CODE=CODE_TAB_"// Rule - "_RULEID_"  "_$P(prodrl,$C(124),1)
	.	D ADDCODE(CODE,.CODE)
	.	D ADDCODE("",.CODE)
	.	;
	.	; Get rule tests
	.	N rs,vos3,vos4,vos5,vos6 S rs=$$vOpen2()
	.	;
	.	F  Q:'($$vFetch2())  D
	..		;
	..		N TEST
	..		;
	..		S TEST=$P(rs,$C(9),2)
	..		;
	..		Q:(TEST="") 
	..		;
	..		S QRYS($P(rs,$C(9),1))=TEST
	..		;
	..		D ADDCODE(TAB_"// "_$P(rs,$C(9),1)_"  "_TEST,.CODE)
	..		Q 
	.	;
	.	D ADDCODE("",.CODE)
	.	;
	.	; If FILES is null, build it from the tables used in the queries
	.	I (FILES="") D  Q:ER 
	..		;
	..		N PSLOBJ N PSLQRY N WHERE
	..		;
	..		S (N,WHERE)=""
	..		F  S N=$order(QRYS(N)) Q:(N="")  D
	...			;
	...			I '(WHERE="") S WHERE=WHERE_" OR "
	...			S WHERE=WHERE_"("_QRYS(N)_")"
	...			Q 
	..		;
	..		S INPUT("FROM")=""
	..		S INPUT("WHERE")=WHERE
	..		;
	..		D ^UCQRYBLD(.INPUT,"ACN=ACN",.FILES,.PSLOBJ,.PSLQRY)
	..		;
	..		I (FILES="") D
	...			;
	...			S ER=1
	...			; Invalid rule ID ~p1 - Invalid Table Value
	...			S RM=$$^MSG(3683,RULEID)_" - "_$$^MSG(7194)
	...			Q 
	..		E  I ER D
	...			;
	...			; Invalid rule ID ~p1
	...			S RM=$$^MSG(3683,RULEID)_" - "_RM
	...			Q 
	..		Q 
	.	;
	.	S JOINFILS=FILES
	.	I (PRIMARY="ACN"),'((","_FILES_",")[",ACN,") S JOINFILS="ACN,"_FILES
	.	;
	.	S INPUT("FROM")=$$DQJOIN^SQLCONV(JOINFILS) ; For UCQRYBLD
	.	;
	.	; If more than just the primary file, add loading code
	.	I ((FILES[",")!'(",DEP,LN,"[(","_PRIMARY_","))) D
	..		;
	..		N I N J
	..		N PSLOBJ N PSLQRY N TABLES
	..		;
	..		S INPUT("WHERE")=""
	..		;
	..		D ^UCQRYBLD(.INPUT,PRIMARY_"="_PRIMARY,.TABLES,.PSLOBJ,.PSLQRY)
	..		;
	..		S (I,J)=""
	..		F  S I=$order(PSLOBJ(I)) Q:(I="")  D
	...			;
	...			F  S J=$order(PSLOBJ(I,J)) Q:(J="")  D ADDCODE(TAB_PSLOBJ(I,J),.CODE)
	...			Q 
	..		;
	..		D ADDCODE("",.CODE)
	..		Q 
	.	;
	.	; Set up each query, to return rule number (DECISION) if successful
	.	S N=""
	.	F  S N=$order(QRYS(N)) Q:(N="")  D
	..		;
	..		N I
	..		N PSLOBJ N PSLQRY N TABLES
	..		;
	..		S INPUT("WHERE")=QRYS(N)
	..		;
	..		D ^UCQRYBLD(.INPUT,PRIMARY_"="_PRIMARY,.TABLES,.PSLOBJ,.PSLQRY)
	..		;
	..		S (CODE,I)=""
	..		F  S I=$order(PSLQRY(I)) Q:(I="")  D
	...			;
	...			I '(CODE="") S CODE=CODE_" & "
	...			;
	...			S CODE=CODE_"("_PSLQRY(I)_")"
	...			Q 
	..		;
	..		D ADDCODE(TAB_"if "_CODE_" quit "_N,.CODE)
	..		Q 
	.	;
	.	; Add return for failure of all tests
	.	D ADDCODE(TAB_"quit 0",.CODE)
	.	Q 
	;
	I ER D  Q 
	.	;
	.	I '$get(skipmsg) D
	..		;
	..		; Compilation error - ~p1
	..		WRITE !,$$^MSG(587,RM)
	..		Q 
	.	Q 
	;
	I '$get(skipmsg) D
	.	;
	.	; ~p1 - compile run-time routine ~p2 ...
	.	WRITE !,$$^MSG(3005,"",PGMNAME)," ",$$TIM^%ZM
	.	Q 
	;
	D cmpA2F^UCGM(.CODE,PGMNAME)
	;
	Q 
	;
ADDCODE(LINE,CODE)	;
	;
	N SEQ
	;
	S SEQ=$order(CODE(""),-1)+1
	;
	S CODE(SEQ)=LINE
	;
	Q 
	;
RTCNT(COLUMN,RESULTID)	;
	N vret
	;
	N rs,vos1,vos2,vos3,vos4,vos5 S rs=$$vOpen3()
	;
	I $$vFetch3() S vret=+rs Q vret
	;
	Q 0
	;
RUCNT(RULEID)	; Rule Set ID
	N vret
	;
	N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen4()
	;
	I $$vFetch4() S vret=+rs Q vret
	;
	Q 0
	;
vSIG()	;
	Q "60444^50878^Dan Russell^4961" ; Signature - LTD^TIME^USER^SIZE
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
	;
vOpen1()	;	RULEID FROM UTBLPRODRL ORDER BY RULEID ASC
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=""
vL1a2	S vos2=$O(^UTBL("PRODRL",vos2),1) I vos2="" G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a2
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds=$S(vos2=$C(254):"",1:vos2)
	;
	Q 1
	;
vOpen2()	;	DECISION,TEST FROM UTBLPRODRLDT WHERE RULEID=:RULEID ORDER BY DECISION ASC
	;
	;
	S vos3=2
	D vL2a1
	Q ""
	;
vL2a0	S vos3=0 Q
vL2a1	S vos4=$G(RULEID) I vos4="" G vL2a0
	S vos5=""
vL2a3	S vos5=$O(^UTBL("PRODRL",vos4,vos5),1) I vos5="" G vL2a0
	Q
	;
vFetch2()	;
	;
	I vos3=1 D vL2a3
	I vos3=2 S vos3=1
	;
	I vos3=0 Q 0
	;
	S vos6=$G(^UTBL("PRODRL",vos4,vos5))
	S rs=$S(vos5=$C(254):"",1:vos5)_$C(9)_$P(vos6,"|",1)
	;
	Q 1
	;
vOpen3()	;	COUNT(DECISION) FROM UTBLPRODRTDT WHERE COLNAME=:COLUMN AND RESULTSID=:RESULTID
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(COLUMN) I vos2="" G vL3a0
	S vos3=$G(RESULTID) I vos3="" G vL3a0
	S vos4=""
vL3a4	S vos4=$O(^UTBL("PRODRT",vos2,vos3,vos4),1) I vos4="" G vL3a7
	S vos5=$G(vos5)+1
	G vL3a4
vL3a7	I $G(vos5)="" S vd="" G vL3a0
	Q
	;
vFetch3()	;
	;
	;
	I vos1=1 D vL3a7
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$G(vos5)
	S vos5=""
	S vos1=100
	;
	Q 1
	;
vOpen4()	;	COUNT(DECISION) FROM UTBLPRODRLDT WHERE RULEID=:RULEID
	;
	;
	S vos1=2
	D vL4a1
	Q ""
	;
vL4a0	S vos1=0 Q
vL4a1	S vos2=$G(RULEID) I vos2="" G vL4a0
	S vos3=""
vL4a3	S vos3=$O(^UTBL("PRODRL",vos2,vos3),1) I vos3="" G vL4a6
	S vos4=$G(vos4)+1
	G vL4a3
vL4a6	I $G(vos4)="" S vd="" G vL4a0
	Q
	;
vFetch4()	;
	;
	;
	I vos1=1 D vL4a6
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$G(vos4)
	S vos4=""
	S vos1=100
	;
	Q 1
