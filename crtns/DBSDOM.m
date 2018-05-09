DBSDOM	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSDOM ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	Q  ; No entry from top
	;
CREATE	;
	;
	N isDone
	N SYSSN
	;
	S SYSSN=""
	;
	S isDone=0
	F  D  Q:isDone 
	.	;
	.	N DELETE
	.	N DOM N MSG N VFMQ
	.	;
	.	S DOM=""
	.	S DELETE=0
	.	;
	.	N fDBSDOM S fDBSDOM=$$vDbNew1("","")
	.	;
	. N vo1 N vo2 N vo3 N vo4 D DRV^USID(0,"DBSDOM",.fDBSDOM,.vo1,.vo2,.vo3,.vo4) K vobj(+$G(vo1)) K vobj(+$G(vo2)) K vobj(+$G(vo3)) K vobj(+$G(vo4))
	.	;
	.	I VFMQ="F" D
	..		;
	..		I DELETE D
	...			;
	...			S vobj(fDBSDOM,-2)=3
	...			;
	...			; Domain ~p1 deleted
	...			S MSG=$$^MSG(853,vobj(fDBSDOM,-4))
	...			Q 
	..		; Domain ~p1 created
	..		E  I ($G(vobj(fDBSDOM,-2))=0) S MSG=$$^MSG(852,vobj(fDBSDOM,-4))
	..		; Domain ~p1 modified
	..		E  S MSG=$$^MSG(854,vobj(fDBSDOM,-4))
	..		;
	..	 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSDOMF(fDBSDOM,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(fDBSDOM,-100) S vobj(fDBSDOM,-2)=1 Tcommit:vTp  
	..		;
	..		; ~p1 ... Continue?
	..		S MSG=$$^MSG(3008,MSG)
	..		Q 
	.	; Continue?
	.	E  S MSG=$$^MSG(603)
	.	;
	.	I '$$YN^DBSMBAR("",MSG,1) S isDone=1
	.	K vobj(+$G(fDBSDOM)) Q 
	;
	Q 
	;
vSIG()	;
	Q "60425^2525^Dan Russell^1317" ; Signature - LTD^TIME^USER^SIZE
	;
vDbNew1(v1,v2)	;	vobj()=Class.new(DBSDOM)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBSDOM",vobj(vOid,-2)=0
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
