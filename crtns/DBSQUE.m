DBSQUE	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSQUE ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	Q  ; Can't call from top
	;
REP(RID,OPT,PROMPTS)	;
	N vpc
	;
	 S ER=0
	;
	N CNT N SEQ
	N PQINFO
	;
	N dbtbl5h S dbtbl5h=$$vDb1("SYSDEV",RID)
	;
	S vpc=('$G(vobj(dbtbl5h,-2))) K:vpc vobj(+$G(dbtbl5h)) Q:vpc  ; Report does not exist
	;
	S RM=$$^DBSRWQRY(.dbtbl5h,.PQINFO) ; Get query info
	I RM'="" S ER=1 K vobj(+$G(dbtbl5h)) Q  ; Query syntax error
	;
	; * Device
	S PROMPTS(1)=$$^MSG(8047) ; Device prompt
	;
	S SEQ=""
	F CNT=2:1 S SEQ=$order(PQINFO(SEQ)) Q:SEQ=""  D
	.	;
	.	N PROMPT
	.	;
	.	I ($D(PQINFO(SEQ,1))#2) D
	..		;
	..		S PROMPT=$piece(PQINFO(SEQ,1),"|",10)
	..		; Required
	..		I $piece(PQINFO(SEQ,1),"|",11) S PROMPT="* "_PROMPT
	..		S PROMPTS(CNT)=PROMPT
	..		Q 
	.	Q 
	;
	K vobj(+$G(dbtbl5h)) Q 
	;
FUN(FN,OPT,PROMPTS)	;
	N vpc
	;
	N RID
	;
	N scatbl,vop1 S scatbl=$$vDb3(FN,.vop1)
	;
	S vpc=('$G(vop1)) Q:vpc  ; Invalid function
	S vpc=($P(scatbl,$C(124),4)'["^URID") Q:vpc  ; Not a report function
	S vpc=($P(scatbl,$C(124),2)'["RID=") Q:vpc  ; Invalid pre-processor
	;
	;  #ACCEPT DATE=01/13/03;PGM=Dan Russell;CR=Mark Spier
	XECUTE $P(scatbl,$C(124),2) ; Get report name
	;
	D REP(RID,0,.PROMPTS)
	Q 
	;
QA	; Private - Test all reports
	;
	N IO
	;
	D ^SCAIO
	;
	USE IO
	;
	N rs,vos1,vos2 S rs=$$vOpen1()
	;
	F  Q:'($$vFetch1())  D
	.	N N
	.	N PROMPTS N RID
	.	;
	.	S RID=rs
	.	D REP(RID,0,.PROMPTS)
	.	WRITE !,RID,!
	.	S N=""
	.	F  S N=$order(PROMPTS(N)) Q:N=""  WRITE ?20,PROMPTS(N),!
	.	WRITE !
	.	Q 
	;
	CLOSE IO
	;
	Q 
	;
vSIG()	;
	Q "60148^65610^Dan Russell^3191" ; Signature - LTD^TIME^USER^SIZE
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(DBTBL5H,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL5H"
	S vobj(vOid)=$G(^DBTBL(v1,5,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,5,v2))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDb3(v1,v2out)	;	voXN = Db.getRecord(SCATBL,,1,-2)
	;
	N scatbl
	S scatbl=$G(^SCATBL(1,v1))
	I scatbl="",'$D(^SCATBL(1,v1))
	S v2out='$T
	;
	Q scatbl
	;
vOpen1()	;	RID FROM DBTBL5H WHERE LIBS='SYSDEV' ORDER BY RID ASC
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=""
vL1a2	S vos2=$O(^DBTBL("SYSDEV",5,vos2),1) I vos2="" G vL1a0
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
	S rs=$S(vos2=$C(254):"",1:vos2)
	;
	Q 1
