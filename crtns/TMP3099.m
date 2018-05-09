TMP3099	; DBSEDIT temporary filer compiled program
	;
	; 01/17/2008 15:29 - pip
	;
	; Last compiled:  01/17/2008 03:29 PM - pip
	;
	; THIS IS A COMPILED ROUTINE.  Compiled by procedure DBSEDIT
	;
	Q:($J'=3099) 
	N rec S rec=$$vDb1("PIPV01")
	S:'$D(vobj(rec,-100,"0*","DESC")) vobj(rec,-100,"0*","DESC")="T001"_$P(vobj(rec),$C(124),1) S vobj(rec,-100,"0*")="",$P(vobj(rec),$C(124),1)="PIP MTM"
	S:'$D(vobj(rec,-100,"0*","STARTUP")) vobj(rec,-100,"0*","STARTUP")="T002"_$P(vobj(rec),$C(124),2) S vobj(rec,-100,"0*")="",$P(vobj(rec),$C(124),2)="/opt/pip_V01/mtm/PIPV01"
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
