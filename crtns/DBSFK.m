DBSFK	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSFK ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	N vpc
	;
	N DELETE
	N OPTION
	N FID N FKEYS N VFMQ
	;
	S FID=$$FIND^DBSGETID("DBTBL1",0) Q:(FID="") 
	;
	N tblrec S tblrec=$$getSchTbl^UCXDD(FID)
	;
	; Both parents and children in foreign key relationships must have filers
	I ($P(tblrec,"|",6)="") D  Q 
	.	;
	.	S ER=1
	.	; Create run-time filer routine first
	.	S RM=$$^MSG(645)
	.	Q 
	;
	S DELETE=0
	S FKEYS=" "
	;
	N fDBTBL1 S fDBTBL1=$$vDb1("SYSDEV",FID)
	N fDBTBL1F S fDBTBL1F=$$vDbNew1("SYSDEV",FID,"")
	;
	S OPTION=0
	;
	; Avoid warning on mismatch in number of parameters
	;  #ACCEPT Date=05/17/06;PGM=RussellDS;CR=21340
	N vo2 N vo3 N vo4 D DRV^USID(0,"DBTBL1K",.fDBTBL1F,.fDBTBL1,.vo2,.vo3,.vo4) K vobj(+$G(vo2)) K vobj(+$G(vo3)) K vobj(+$G(vo4)) S vpc=((VFMQ="Q")) K:vpc vobj(+$G(fDBTBL1)),vobj(+$G(fDBTBL1F)) Q:vpc 
	;
	I DELETE D
	.	;
	.	S vobj(fDBTBL1F,-2)=3
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSDFKF(fDBTBL1F,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(fDBTBL1F,-100) S vobj(fDBTBL1F,-2)=1 Tcommit:vTp  
	.	;
	.	; ~p1 deleted
	.	S RM=$$^MSG(3028,FKEYS)
	.	Q 
	E  I (OPTION<2) D
	.	;
	.	S vobj(fDBTBL1F,-2)=OPTION
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSDFKF(fDBTBL1F,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(fDBTBL1F,-100) S vobj(fDBTBL1F,-2)=1 Tcommit:vTp  
	.	;
	.	; ~p1 created
	.	S RM=$$^MSG(6712,FKEYS)
	.	Q 
	;
	; Rebuild indexes for DBTBL1F
	D ADD^DBSINDXZ("DBTBL1F")
	;
	K vobj(+$G(fDBTBL1)),vobj(+$G(fDBTBL1F)) Q 
	;
vSIG()	;
	Q "60402^74925^Dan Russell^1433" ; Signature - LTD^TIME^USER^SIZE
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(DBTBL1,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL1"
	S vobj(vOid)=$G(^DBTBL(v1,1,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,1,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDbNew1(v1,v2,v3)	;	vobj()=Class.new(DBTBL1F)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL1F",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
