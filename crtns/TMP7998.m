TMP7998	; DBSEDIT temporary filer compiled program
	;
	; 11/08/2007 12:16 - chenardp
	;
	; Last compiled:  11/08/2007 12:16 PM - chenardp
	;
	; THIS IS A COMPILED ROUTINE.  Compiled by procedure DBSEDIT
	;
	Q:($J'=7998) 
	N rec S rec=$$vDb1("V72FRAM")
	S:'$D(vobj(rec,-100,"0*","DESC")) vobj(rec,-100,"0*","DESC")="T001"_$P(vobj(rec),$C(124),1) S vobj(rec,-100,"0*")="",$P(vobj(rec),$C(124),1)="v72 Framework MTM"
	S:'$D(vobj(rec,-100,"0*","STARTUP")) vobj(rec,-100,"0*","STARTUP")="T002"_$P(vobj(rec),$C(124),2) S vobj(rec,-100,"0*")="",$P(vobj(rec),$C(124),2)="/v72framework_gtmlx/mtm/V72FRAM"
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(rec) K vobj(rec,-100) S vobj(rec,-2)=1 Tcommit:vTp  
	K vobj(+$G(rec)) Q 
	;
vDb1(v1)	;	vobj()=Db.getRecord(CTBLMTM,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordCTBLMTM"
	S vobj(vOid)=$G(^CTBL("MTM",v1))
	I vobj(vOid)="",'$D(^CTBL("MTM",v1))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	Q vOid
	;
vReSav1(rec)	;	RecordCTBLMTM saveNoFiler(LOG)
	;
	D ^DBSLOGIT(rec,vobj(rec,-2))
	S ^CTBL("MTM",vobj(rec,-3))=$$RTBAR^%ZFUNC($G(vobj(rec)))
	Q
