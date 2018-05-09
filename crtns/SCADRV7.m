SCADRV7	; Userclass Maintenance
	;
	; **** Routine compiled from DATA-QWIK Procedure SCADRV7 ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	;
	Q 
	;
NEW	; Userclass Creation
	;
	D INIT(0)
	;
	Q 
	;
UPD	; Userclass Maintenance
	;
	D INIT(1)
	;
	Q 
	;
INQ	; Userclass Inquiry
	;
	D INIT(2)
	;
	Q 
	;
DEL	; Userclass Deletion
	;
	D INIT(3)
	;
	Q 
	;
INIT(%O)	; Screen Control
	;
	N %OSAVE
	N UCLS N VFMQ
	;
	S %OSAVE=%O
	;
	D QUERY
	;
	I "Q"[VFMQ D END Q 
	;
	N scau0
	;
	D SCREEN(.scau0)
	;
	D FILE(.scau0)
	;
	K vobj(+$G(scau0)) Q 
	;
QUERY	; Set up query screen for Userclass selection
	;
	N %NOPRMT N %READ N %TAB
	;
	S %TAB("UCLS")=".UCLS4/HLP=[SCAU0]UCLS/XPP=D PPUCLS^SCADRV7"
	I %O S %TAB("UCLS")=%TAB("UCLS")_"/TBL=[SCAU0]"
	I %O=2 S %TAB("IO")=$$IO^SCATAB($I)
	;
	S %READ="@@%FN,,,UCLS/REQ"
	I %O=2 S %READ=%READ_",IO/REQ"
	;
	S %NOPRMT="N"
	;
	D ^UTLREAD
	;
	Q 
	;
PPUCLS	; UCLS post processor
	;
	I (X="") Q 
	;
	I %OSAVE=3 D  Q:ER 
	.	;
	.	N ds,vos1,vos2 S ds=$$vOpen1()
	.	F  Q:'($$vFetch1())  D  Q:ER 
	..		;
	..		N scau S scau=$G(^SCAU(1,ds))
	..		;
	..		; Cannot delete - User ID's are tied to Userclass ~p1
	..		I $P(scau,$C(124),5)=X D SETERR^DBSEXECU("SCAU0","MSG","8484",X) Q:ER 
	..		Q 
	.	Q 
	;
	I %OSAVE Q 
	;
	; Record already exists
	I ($D(^SCAU(0,X))#2) D SETERR^DBSEXECU("SCAU0","MSG","2327") Q:ER 
	;
	Q 
	;
SCREEN(scau0)	; Userclass screen
	;
	K vobj(+$G(scau0)) S scau0=$$vDb2(UCLS)
	;
	I %O=2 D OPEN^SCAIO
	;
	I ER S VFMQ="Q" Q 
	;
	N vo1 N vo2 N vo3 N vo4 D DRV^USID(%O,"SCAUSRC",.scau0,.vo1,.vo2,.vo3,.vo4) K vobj(+$G(vo1)) K vobj(+$G(vo2)) K vobj(+$G(vo3)) K vobj(+$G(vo4))
	;
	Q 
	;
FILE(scau0)	; File/Delete the Userclass
	;
	I %O=2!(VFMQ="Q") D END Q 
	;
	I %O=3 D  Q 
	.	 N V1 S V1=vobj(scau0,-3) D vDbDe1()
	.	D END
	.	Q 
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^SCAU0FL(scau0,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(scau0,-100) S vobj(scau0,-2)=1 Tcommit:vTp  
	;
	D END
	;
	Q 
	;
END	; Finish up
	;
	I ER!(%O=2) Q 
	;
	S UCLS=$get(UCLS)
	S ER="W"
	I VFMQ="Q" D
	.	;
	.	; Userclass ~p1 not created
	.	I %O=0 S RM=$$^MSG(2903,UCLS) Q 
	.	;
	.	; Userclass ~p1 not modified
	.	I %O=1 S RM=$$^MSG(2905,UCLS) Q 
	.	;
	.	; Userclass ~p1 not deleted
	.	I %O=3 S RM=$$^MSG(2904,UCLS) Q 
	.	Q 
	E  D
	.	;
	.	; Userclass ~p1 created
	.	I %O=0 S RM=$$^MSG(4886,UCLS) Q 
	.	;
	.	; Userclass ~p1 modified
	.	I %O=1 S RM=$$^MSG(4887,UCLS)
	.	;
	.	; Userclass ~p1 deleted
	.	I %O=3 S RM=$$^MSG(5431,UCLS) Q 
	.	Q 
	Q 
	;
vSIG()	;
	Q "60275^61883^kellytp^3253" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM SCAU0 WHERE UCLS=:V1
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Tstart (vobj):transactionid="CS"
	N vRec S vRec=$$vDb2(V1)
	I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D ^SCAU0FL(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1)
	Tcommit:$Tlevel 
	K vobj(+$G(vRec)) Q 
	;
vDb2(v1)	;	vobj()=Db.getRecord(SCAU0,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSCAU0"
	S vobj(vOid)=$G(^SCAU(0,v1))
	I vobj(vOid)="",'$D(^SCAU(0,v1))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	Q vOid
	;
vOpen1()	;	UID FROM SCAU
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=""
vL1a2	S vos2=$O(^SCAU(1,vos2),1) I vos2="" G vL1a0
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
