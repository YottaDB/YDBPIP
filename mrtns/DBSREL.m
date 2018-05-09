DBSREL	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSREL ****
	;
	; 09/10/2007 17:32 - chenardp
	;
	;
	; *******************************************************************
	; * IMPORTANT NOTE:                                                 *
	; * According to the rules that apply to PSL compiler upgrades,     *
	; * the generated M routine associated with this procedure must be  *
	; * checked into StarTeam and released with the procedure whenever  *
	; * changes are made to this procedure.  The M routine from the     *
	; * crtns directory should be used for this purpose.                *
	; *                                                                 *
	; * The M routine will be loaded to the mrtns directory during      *
	; * upgrades and will then be removed from that directory as part   *
	; * of the upgrade process.  Therefore, other during an upgrade,    *
	; * an mrtns version of this routine should not exist.              *
	; *                                                                 *
	; * Keep these comments as single line to ensure they exist in the  *
	; * generated M code.                                               *
	; *******************************************************************
	;
	S ER=$$VALIDATE($get(FILES),.LOOP,.RM)
	;
	Q 
	;
VALIDATE(TABLES,LOOP,RM)	;
	;
	N ER N isDone N isValid
	N CNT N I N J
	N COMBO N PKEYS N REL N RM1 N TBLS N TBLSX N VALIDREL
	;
	S ER=0
	S RM=""
	S CNT=0
	;
	I (TABLES="") Q 0
	;
	; Define LOOP(-1, TABLE) array and remove duplicates
	; Build TBLS(n) array of tables
	F I=1:1:$L(TABLES,",") D  Q:ER 
	.	;
	.	N TBL S TBL=$piece(TABLES,",",I)
	.	;
	.	Q:($D(TBLSX(TBL))#2)  ; Duplicate
	.	;
	.	S CNT=CNT+1
	.	S TBLS(CNT)=TBL ; CNT = 1 = Primary table
	.	S TBLSX(TBL)=CNT
	.	;
	.	I '($D(LOOP(-1,TBL))#2) D
	..		;
	..		N dbtbl1,vop1,vop2,vop3,vop4,vop5 S vop1="SYSDEV",vop2=TBL,dbtbl1=$$vDb2("SYSDEV",TBL,.vop3)
	..		 S vop4=$G(^DBTBL(vop1,1,vop2,12))
	..		 S vop5=$G(^DBTBL(vop1,1,vop2,16))
	..		;
	..		I ($G(vop3)=0) D
	...			;
	...			S ER=1
	...			; Invalid file name - ~p1
	...			S RM=$$^MSG(1337,TBL)
	...			Q 
	..		;
	..		E  D
	...			;
	...			S LOOP(-1,TBL)=$P(vop4,$C(124),1)
	...			S LOOP($P(vop4,$C(124),1))=$translate($P(vop5,$C(124),1),",","|")
	...			Q 
	..		Q 
	.	Q 
	;
	I ER Q 1
	;
	N tblrecp S tblrecp=$$getSchTbl^UCXDD(TBLS(1))
	;
	S PKEYS=$P(tblrecp,"|",3)
	;
	; Only a single table
	I (CNT=1) S LOOP(-2,1)=TBLS(1) Q 0
	;
	; Two files - easy  A->B or B->A
	I (CNT=2) D  Q ER
	.	;
	.	N A N B
	.	;
	.	S A=$order(LOOP(-1,0))
	.	S B=$order(LOOP(-1,A))
	.	;
	.	I (TBLS(1)'=A) D  ; Switch
	..		;
	..		N X S X=A
	..		;
	..		S A=B
	..		S B=X
	..		Q 
	.	;
	.	S isValid=$$REL(A,B)
	.	;
	.	I isValid D  ; A -> B
	..		;
	..		S LOOP(-2,1)=A
	..		S LOOP(-2,2)=B
	..		;
	..		D LINK(A,B,1,.LOOP,PKEYS)
	..		Q 
	.	;
	.	; Try the other direction
	.	E  S isValid=$$REL(B,A,.RM) I isValid D
	..		;
	..		S LOOP(-2,1)=B ; B -> A
	..		S LOOP(-2,2)=A
	..		;
	..		D LINK(B,A,1,.LOOP,PKEYS)
	..		Q 
	.	;
	.	I 'isValid S ER=1
	.	Q 
	;
	; Build all possible relationship pairs
	F I=1:1:CNT F J=1:1:CNT I (+I'=+J) S REL(TBLS(I),TBLS(J))=$$REL(TBLS(I),TBLS(J))
	;
	; Check primary to each individual table
	S isValid=1
	F I=2:1:CNT I 'REL(TBLS(1),TBLS(I)) S isValid=0
	;
	; Primary is related to each => relationship is valid
	I isValid D  Q 0
	.	;
	.	; build LOOP info
	.	F I=1:1:CNT S LOOP(-2,I)=TBLS(I)
	.	;
	.	; build LINK info for each primary -> table
	.	F I=2:1:CNT D LINK(TBLS(1),TBLS(I),1,.LOOP,PKEYS)
	.	Q 
	;
	; Check the input combination first
	S COMBO=""
	F I=2:1:CNT S COMBO=COMBO_I_","
	S COMBO=$E(COMBO,1,$L(COMBO)-1)
	;
	S isValid=$$CHKCOMBO(COMBO,.TBLS,.RM1)
	;
	I isValid S VALIDREL=COMBO
	;
	; Otherwise, check all combinations, with primary first.  If find one
	; that is valid, we're done
	E  D
	.	;
	.	S (COMBO,VALIDREL)=""
	.	D COMBOS(CNT-1,CNT,.COMBO,.VALIDREL,.TBLS)
	.	Q 
	;
	I '(VALIDREL="") D
	.	;
	.	S VALIDREL="1,"_VALIDREL ; Add primary table
	.	;
	.	; build LOOP info
	.	F I=1:1:CNT S LOOP(-2,I)=TBLS($piece(VALIDREL,",",I))
	.	;
	.	; build LINK info for each link A->B, B->C, etc.
	.	F I=1:1:CNT-1 D
	..		;
	..		N TBLA N TBLB
	..		;
	..		S TBLA=TBLS($piece(VALIDREL,",",I))
	..		S TBLB=TBLS($piece(VALIDREL,",",I+1))
	..		;
	..		D LINK(TBLA,TBLB,I,.LOOP,PKEYS)
	..		Q 
	.	Q 
	;
	; Nothing worked
	E  D
	.	;
	.	S ER=1
	.	; Use error message associated with input order
	.	S RM=RM1
	.	Q 
	;
	Q ER
	;
COMBOS(POS,CNT,COMBO,VALIDREL,TBLS)	;
	;
	N I
	;
	; Start from 2 since we're building combinations of tables 2 through
	; CNT since the primary table, TBLS(1), will always be first
	F I=2:1:CNT D  Q:'(VALIDREL="") 
	.	;
	.	I (POS=CNT) S COMBO="" ; Start a new one
	.	;
	.	Q:((","_COMBO_",")[(","_I_","))  ; Each table in combo only once
	.	;
	.	I (COMBO="") S COMBO=I
	.	E  S COMBO=COMBO_","_I
	.	;
	.	; If we've got combination built, check it.  Done if good.
	.	I (POS-1=0) D
	..		;
	..		I $$CHKCOMBO(COMBO,.TBLS) S VALIDREL=COMBO
	..		Q 
	.	E  D COMBOS(POS-1,CNT,.COMBO,.VALIDREL,.TBLS)
	.	;
	.	S COMBO=$piece(COMBO,",",1,$L(COMBO,",")-1)
	.	Q 
	;
	Q 
	;
CHKCOMBO(COMBO,TBLS,RM)	;
	;
	N isValid S isValid=1
	N I
	;
	; Add primary table
	S COMBO="1,"_COMBO
	;
	F I=1:1:$L(COMBO,",")-1 D  Q:'isValid 
	.	;
	.	N TBL1 N TBL2
	.	;
	.	S TBL1=TBLS($piece(COMBO,",",I))
	.	S TBL2=TBLS($piece(COMBO,",",I+1))
	.	;
	.	S isValid=$$REL(TBL1,TBL2,.RM)
	.	Q 
	;
	Q isValid
	;
REL(TBLA,TBLB,RM)	;
	;
	N isValid S isValid=1
	N I
	N BKEYS
	;
	N tblrecb S tblrecb=$$getSchTbl^UCXDD(TBLB)
	;
	S BKEYS=$P(tblrecb,"|",3)
	F I=1:1:$L(BKEYS,",") D  Q:'isValid 
	.	;
	.	N key S key=$piece(BKEYS,",",I)
	.	;
	.	; Null key (CUVAR) is OK
	.	; If column in A points to this key in B then OK
	.	I '(key=""),'$$isColumn^UCXDD(TBLA,key) D
	..		;
	..		S isValid=0
	..		; Invalid file relationship between ~p1 and ~p2
	..		S RM=$$^MSG(1340,TBLA,TBLB)
	..		Q 
	.	Q 
	;
	Q isValid
	;
LINK(TBLA,TBLB,LEVA,LOOP,PKEYS)	;
	;
	N I
	N AKEYS N BKEYS
	;
	N tblreca S tblreca=$$getSchTbl^UCXDD(TBLA)
	N tblrecb S tblrecb=$$getSchTbl^UCXDD(TBLB)
	;
	S AKEYS=$P(tblreca,"|",3)
	S BKEYS=$P(tblrecb,"|",3)
	;
	Q:(BKEYS="") 
	;
	F I=1:1:$L(BKEYS,",") D
	.	;
	.	N key
	.	;
	.	S key=$piece(BKEYS,",",I)
	.	;
	.	; If key in primary table, don't need to save access
	.	Q:((","_PKEYS_",")[(","_key_",")) 
	.	;
	.	; If key in TBLA, don't need to save access
	.	Q:((","_AKEYS_",")[(","_key_",")) 
	.	;
	.	N colreca S colreca=$$getSchCln^UCXDD(TBLA,key)
	.	;
	.	I '($P(colreca,"|",14)="") S LOOP(-2,LEVA,key)=$P(colreca,"|",14)
	.	;
	.	; Otherwise, call PARSE^DBSDD to get NS, which is the M access expression
	.	; Goes away once get all this in PSL
	.	E  D
	..		;
	..		N cmp N NS
	..		;
	..		D PARSE^DBSDD(TBLA_"."_key,"",.cmp)
	..		;
	..		I '(NS="") S LOOP(-2,LEVA,key)=NS
	..		Q 
	.	Q 
	;
	Q 
	;
TBLORD(TABLES)	; List of tables to validate and order
	;
	N ER
	N LOOP N TBLORD
	;
	S TBLORD=""
	;
	S ER=$$VALIDATE(TABLES,.LOOP)
	;
	I 'ER D
	.	;
	.	N N S N=""
	.	;
	.	F  S N=$order(LOOP(-2,N)) Q:(N="")  S TBLORD=TBLORD_LOOP(-2,N)_","
	.	;
	.	S TBLORD=$E(TBLORD,1,$L(TBLORD)-1)
	.	Q 
	;
	Q TBLORD
	;
vDb2(v1,v2,v2out)	;	voXN = Db.getRecord(DBTBL1,,1,-2)
	;
	N dbtbl1
	S dbtbl1=$G(^DBTBL(v1,1,v2))
	I dbtbl1="",'$D(^DBTBL(v1,1,v2))
	S v2out='$T
	;
	Q dbtbl1
