DBSINDX	; Index File Definition
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSINDX ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	Q 
	;
CREATE	; Create Index File Definition
	;
	N ER
	N FID N VFMQ
	;
	S FID=""
	S VFMQ=""
	;
	D PFILES(0,.FID,.VFMQ)
	;
	I VFMQ="Q" Q 
	I ER Q 
	;
	D MODIFY1(FID)
	;
	Q 
	;
MODIFY	; Modify Index File Definition
	;
	N ER
	N FID N VFMQ
	;
	S FID=""
	S VFMQ=""
	;
	D PFILES(1,.FID,.VFMQ)
	;
	I VFMQ="Q" Q 
	I ER Q 
	;
	D MODIFY1(FID)
	;
	Q 
	;
MODIFY1(FID)	;
	;
	N DELFLG
	N INDEXNM N VFMQ
	;
	S %O=1
	S INDEXNM=" "
	S DELFLG=0
	;
	N DBTBL1 S DBTBL1=$$vDb1("SYSDEV",FID)
	N DBTBL8 S DBTBL8=$$vDbNew1("","","")
	;
	S vobj(DBTBL8,-3)="SYSDEV"
	S vobj(DBTBL8,-4)=FID
	;
	N vo1 N vo2 N vo3 D DRV^USID(0,"DBTBL8",.DBTBL8,.DBTBL1,.vo1,.vo2,.vo3) K vobj(+$G(vo1)) K vobj(+$G(vo2)) K vobj(+$G(vo3))
	;
	I VFMQ="Q" K vobj(+$G(DBTBL1)),vobj(+$G(DBTBL8)) Q 
	;
	I DELFLG S vobj(DBTBL8,-2)=3
	;
	; do MODE
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSINDXF(DBTBL8,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(DBTBL8,-100) S vobj(DBTBL8,-2)=1 Tcommit:vTp   ; Call filer to update record
	;
	; Index name ~p1 filed ... Continue?
	I '$$YN^DBSMBAR("",$$^MSG(1218,INDEXNM),1) K vobj(+$G(DBTBL1)),vobj(+$G(DBTBL8)) Q 
	;
	D MODIFY1(FID)
	;
	K vobj(+$G(DBTBL1)),vobj(+$G(DBTBL8)) Q 
	;
MODE	; Determine processing mode
	;
	I DELFLG S %O=3 Q  ; Delete mode
	;
	I ($D(^DBTBL("SYSDEV",8,FID,INDEXNM))#2) S %O=1 Q  ; Modify mode
	;
	S %O=0 ; Create mode
	;
	Q 
	;
PFILES(IOPT,FID,VFMQ)	;
	;
	N IEXIST
	N srclib
	;
	S FID=$$FIND^DBSGETID("DBTBL1",0)
	;
	I FID="" S VFMQ="Q" Q 
	;
	S VFMQ="F"
	;
	N rs,vos1,vos2,vos3 S rs=$$vOpen1()
	I '$G(vos1) S IEXIST=0
	E  S IEXIST=1
	;
	; Index file definition already exists
	I 'IOPT,IEXIST S ER=1 S RM=$$^MSG(1214) Q 
	;
	; Index file definition not available
	I IOPT,'IEXIST S ER=1 S RM=$$^MSG(1215) Q 
	;
	N DBTBL1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=FID,DBTBL1=$$vDb3("SYSDEV",FID)
	 S vop3=$G(^DBTBL(vop1,1,vop2,99))
	S pgm=$P(vop3,$C(124),2)
	;
	Q 
	;
COPY	; Copy Index File Definition
	;
	N ER
	N %TAB N %READ N %NOPRMT N FID N INDEXNM N PSFILE N RM N VFMQ
	;
	S ER=0
	S RM=""
	;
	S %TAB("PSFILE")=".PSFILE1/TBL=[DBTBL1]"
	S %TAB("FID")=".POFILE1/TBL=[DBTBL1]/XPP=D COPYPP^DBSINDX"
	;
	S %READ="@@%FN,,,PSFILE/REQ,FID/REQ" S %NOPRMT="F"
	;
	D ^UTLREAD
	;
	I VFMQ="Q" Q 
	;
	N ds,vos1,vos2,vos3 S ds=$$vOpen2()
	F  Q:'($$vFetch2())  D
	.	;
	.	N FD8 S FD8=$$vDb2($P(ds,$C(9),1),$P(ds,$C(9),2),$P(ds,$C(9),3))
	.	N TD8 S TD8=$$vDbNew1("","","")
	.	;
	. K vobj(+$G(TD8)) S TD8=$$vReCp1(FD8)
	. S vobj(TD8,-4)=FID
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSINDXF(TD8,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(TD8,-100) S vobj(TD8,-2)=1 Tcommit:vTp  
	.	;
	.	K vobj(+$G(FD8)),vobj(+$G(TD8)) Q 
	;
	WRITE $$MSG^%TRMVT($$^MSG(855),"",1)
	;
	Q 
	;
COPYPP	; -------- Post-Processor
	;
	Q:(X="") 
	;
	N rs,vos1,vos2,vos3 S rs=$$vOpen3()
	;
	; Already created
	I ''$G(vos1) S ER=1 S RM=$$^MSG(252)
	;
	Q 
	;
DELETE	; Delete Index File Definition
	;
	N ER
	N FID N VFMQ
	;
	S ER=0
	S FID=""
	S VFMQ=""
	;
	D PFILES(1,.FID,.VFMQ)
	;
	Q:VFMQ="Q" 
	Q:ER 
	;
	; Are you sure?
	I '$$YN^DBSMBAR("",$$^MSG(307)) Q 
	;
	D vDbDe1()
	;
	WRITE $$MSG^%TRMVT($$^MSG(855),"",1)
	;
	Q 
	;
vSIG()	;
	Q "60842^35292^Dan Russell^3514" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM DBTBL8 WHERE %LIBS='SYSDEV' AND FID=:FID
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Tstart (vobj):transactionid="CS"
	N vDs,vos1,vos2,vos3 S vDs=$$vOpen4()
	F  Q:'($$vFetch4())  D
	.	N vRec S vRec=$$vDb2($P(vDs,$C(9),1),$P(vDs,$C(9),2),$P(vDs,$C(9),3))
	.	S vobj(vRec,-2)=3
	.	D ^DBSINDXF(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1)
	.	K vobj(+$G(vRec)) Q 
	Tcommit:$Tlevel 
	Q 
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
vDb2(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL8,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL8"
	S vobj(vOid)=$G(^DBTBL(v1,8,v2,v3))
	I vobj(vOid)="",'$D(^DBTBL(v1,8,v2,v3))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDb3(v1,v2)	;	voXN = Db.getRecord(DBTBL1,,0)
	;
	N DBTBL1
	S DBTBL1=$G(^DBTBL(v1,1,v2))
	I DBTBL1="",'$D(^DBTBL(v1,1,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1" X $ZT
	Q DBTBL1
	;
vDbNew1(v1,v2,v3)	;	vobj()=Class.new(DBTBL8)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL8",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vOpen1()	;	INDEXNM FROM DBTBL8 WHERE %LIBS='SYSDEV' AND FID=:FID
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(FID) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^DBTBL("SYSDEV",8,vos2,vos3),1) I vos3="" G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen2()	;	%LIBS,FID,INDEXNM FROM DBTBL8 WHERE %LIBS='SYSDEV' AND FID=:PSFILE
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(PSFILE) I vos2="" G vL2a0
	S vos3=""
vL2a3	S vos3=$O(^DBTBL("SYSDEV",8,vos2,vos3),1) I vos3="" G vL2a0
	Q
	;
vFetch2()	;
	;
	;
	I vos1=1 D vL2a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen3()	;	INDEXNM FROM DBTBL8 WHERE %LIBS='SYSDEV' AND FID=:X
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(X) I vos2="" G vL3a0
	S vos3=""
vL3a3	S vos3=$O(^DBTBL("SYSDEV",8,vos2,vos3),1) I vos3="" G vL3a0
	Q
	;
vFetch3()	;
	;
	;
	I vos1=1 D vL3a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen4()	;	%LIBS,FID,INDEXNM FROM DBTBL8 WHERE %LIBS='SYSDEV' AND FID=:FID
	;
	;
	S vos1=2
	D vL4a1
	Q ""
	;
vL4a0	S vos1=0 Q
vL4a1	S vos2=$G(FID) I vos2="" G vL4a0
	S vos3=""
vL4a3	S vos3=$O(^DBTBL("SYSDEV",8,vos2,vos3),1) I vos3="" G vL4a0
	Q
	;
vFetch4()	;
	;
	;
	I vos1=1 D vL4a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vDs="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vReCp1(v1)	;	RecordDBTBL8.copy: DBTBL8
	;
	Q $$copy^UCGMR(FD8)
