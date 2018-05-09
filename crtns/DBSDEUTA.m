DBSDEUTA(SID,ProcMode,KEY,FPRE)	; Generic Screen Driver
	;
	; 11/08/2007 14:07 - chenardp
	;
	; Last compiled:  11/08/2007 02:07 PM - chenardp
	;
	; THIS IS A COMPILED ROUTINE.  Compiled by procedure DBSDEUTB
	;
	; See DBSDEUTB for argument definitions
	;
	N ERMSG N SCREEN N TABLE
	S FPRE=$get(FPRE)
	;
	I SID="DBTBL25" Q $$gf1(ProcMode,.KEY,FPRE)
	E  I SID="DBTBL7" Q $$gf2(ProcMode,.KEY,FPRE)
	E  I SID="DBTBL9" Q $$gf3(ProcMode,.KEY,FPRE)
	;
	Q "Screen "_SID_" not permitted to run via this function"
	;
	; Generic Functions for each screen
	;
gf1(ProcMode,KEY,FPRE)	; DBTBL25 - Procedure Definition
	;
	N ER S ER=0
	N ERMSG N RM
	;
	S (ERMSG,RM,VFMQ)=""
	;
	N dbtbl2,vop1,vop2,vop3,vop4 S vop1="SYSDEV",vop2="DBTBL25",dbtbl2=$$vDb5("SYSDEV","DBTBL25",.vop3)
	 S vop4=$G(^DBTBL(vop1,2,vop2,0))
	I '$G(vop3) S ER=1 S ERMSG="Invalid Screen Name" Q ERMSG
	I '$P(vop4,$C(124),22) S ER=1 S ERMSG="Screen must be converted to PSL" Q ERMSG
	N fDBTBL25 S fDBTBL25=$$vDb2(KEY(1),KEY(2))
	;  #ACCEPT Date=03/04/07; Pgm=RussellDS; CR=25558; Group=MISMATCH
	N vo1 N vo2 N vo3 N vo4 D DRV^USID(ProcMode,"DBTBL25",.fDBTBL25,.vo1,.vo2,.vo3,.vo4) K vobj(+$G(vo1)) K vobj(+$G(vo2)) K vobj(+$G(vo3)) K vobj(+$G(vo4))
	;
	I 'ER,(VFMQ'="Q") D
	.	;
	.	;   #ACCEPT Date=01/20/05;PGM=Screen Compiler;CR=14146
	.	I '(FPRE="") XECUTE FPRE I ER Q 
	.	;
	.	I ProcMode<2,$D(vobj(fDBTBL25,-100)) N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBTBL25F(fDBTBL25,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(fDBTBL25,-100) S vobj(fDBTBL25,-2)=1 Tcommit:vTp  
	.	I ProcMode=3  N V1,V2 S V1=KEY(1),V2=KEY(2) ZWI ^DBTBL(V1,25,V2)
	.	Q 
	;
	I ER S ERMSG=$get(RM)
	;
	K vobj(+$G(fDBTBL25)) Q ERMSG
	;
gf2(ProcMode,KEY,FPRE)	; DBTBL7 - Trigger Definition
	;
	N ER S ER=0
	N ERMSG N RM
	;
	S (ERMSG,RM,VFMQ)=""
	;
	N dbtbl2,vop1,vop2,vop3,vop4 S vop1="SYSDEV",vop2="DBTBL7",dbtbl2=$$vDb5("SYSDEV","DBTBL7",.vop3)
	 S vop4=$G(^DBTBL(vop1,2,vop2,0))
	I '$G(vop3) S ER=1 S ERMSG="Invalid Screen Name" Q ERMSG
	I '$P(vop4,$C(124),22) S ER=1 S ERMSG="Screen must be converted to PSL" Q ERMSG
	N fDBTBL7 S fDBTBL7=$$vDb3(KEY(1),KEY(2),KEY(3))
	;  #ACCEPT Date=03/04/07; Pgm=RussellDS; CR=25558; Group=MISMATCH
	N vo5 N vo6 N vo7 N vo8 D DRV^USID(ProcMode,"DBTBL7",.fDBTBL7,.vo5,.vo6,.vo7,.vo8) K vobj(+$G(vo5)) K vobj(+$G(vo6)) K vobj(+$G(vo7)) K vobj(+$G(vo8))
	;
	I 'ER,(VFMQ'="Q") D
	.	;
	.	;   #ACCEPT Date=01/20/05;PGM=Screen Compiler;CR=14146
	.	I '(FPRE="") XECUTE FPRE I ER Q 
	.	;
	.	I ProcMode<2,$D(vobj(fDBTBL7,-100)) N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBTBL7FL(fDBTBL7,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(fDBTBL7,-100) S vobj(fDBTBL7,-2)=1 Tcommit:vTp  
	.	I ProcMode=3  N V1,V2,V3 S V1=KEY(1),V2=KEY(2),V3=KEY(3) D vDbDe1()
	.	Q 
	;
	I ER S ERMSG=$get(RM)
	;
	K vobj(+$G(fDBTBL7)) Q ERMSG
	;
gf3(ProcMode,KEY,FPRE)	; DBTBL9 - Journal File Definition
	;
	N ER S ER=0
	N ERMSG N RM
	;
	S (ERMSG,RM,VFMQ)=""
	;
	N dbtbl2,vop1,vop2,vop3,vop4 S vop1="SYSDEV",vop2="DBTBL9",dbtbl2=$$vDb5("SYSDEV","DBTBL9",.vop3)
	 S vop4=$G(^DBTBL(vop1,2,vop2,0))
	I '$G(vop3) S ER=1 S ERMSG="Invalid Screen Name" Q ERMSG
	I '$P(vop4,$C(124),22) S ER=1 S ERMSG="Screen must be converted to PSL" Q ERMSG
	N fDBTBL9 S fDBTBL9=$$vDb4(KEY(1),KEY(2),KEY(3))
	;  #ACCEPT Date=03/04/07; Pgm=RussellDS; CR=25558; Group=MISMATCH
	N vo9 N vo10 N vo11 N vo12 D DRV^USID(ProcMode,"DBTBL9",.fDBTBL9,.vo9,.vo10,.vo11,.vo12) K vobj(+$G(vo9)) K vobj(+$G(vo10)) K vobj(+$G(vo11)) K vobj(+$G(vo12))
	;
	I 'ER,(VFMQ'="Q") D
	.	;
	.	;   #ACCEPT Date=01/20/05;PGM=Screen Compiler;CR=14146
	.	I '(FPRE="") XECUTE FPRE I ER Q 
	.	;
	.	I ProcMode<2,$D(vobj(fDBTBL9,-100)) N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBTBL9FL(fDBTBL9,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(fDBTBL9,-100) S vobj(fDBTBL9,-2)=1 Tcommit:vTp  
	.	I ProcMode=3  N V1,V2,V3 S V1=KEY(1),V2=KEY(2),V3=KEY(3) ZWI ^DBTBL(V1,9,V2,V3)
	.	Q 
	;
	I ER S ERMSG=$get(RM)
	;
	K vobj(+$G(fDBTBL9)) Q ERMSG
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM DBTBL7 WHERE %LIBS = :V1 AND TABLE = :V2 AND TRGID = :V3
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Tstart (vobj):transactionid="CS"
	N vRec S vRec=$$vDb3(V1,V2,V3)
	I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D ^DBTBL7FL(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1)
	Tcommit:$Tlevel 
	K vobj(+$G(vRec)) Q 
	;
vDb2(v1,v2)	;	vobj()=Db.getRecord(DBTBL25,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL25"
	S vobj(vOid)=$G(^DBTBL(v1,25,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,25,v2))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDb3(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL7,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL7"
	S vobj(vOid)=$G(^DBTBL(v1,7,v2,v3))
	I vobj(vOid)="",'$D(^DBTBL(v1,7,v2,v3))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDb4(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL9,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL9"
	S vobj(vOid)=$G(^DBTBL(v1,9,v2,v3))
	I vobj(vOid)="",'$D(^DBTBL(v1,9,v2,v3))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDb5(v1,v2,v2out)	;	voXN = Db.getRecord(DBTBL2,,1,-2)
	;
	N dbtbl2
	S dbtbl2=$G(^DBTBL(v1,2,v2))
	I dbtbl2="",'$D(^DBTBL(v1,2,v2))
	S v2out='$T
	;
	Q dbtbl2
