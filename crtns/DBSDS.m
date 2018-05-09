DBSDS	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSDS ****
	;
	; 09/14/2007 10:46 - chenardp
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
	Q  ; No entry from top
	;
CREATE	;
	N vpc
	;
	N SID N VFMQ
	;
	S SID=$$FIND^DBSGETID("DBTBL2",1) Q:(SID="") 
	;
	I $$YN^DBSMBAR("","Create screen linkage procedure") D PROCDUR(0,SID) Q 
	;
	N DBTBL2 S DBTBL2=$$vDbNew1("SYSDEV",SID)
	 S vobj(DBTBL2,0)=""
	;
	S vobj(DBTBL2,-100,0)="",$P(vobj(DBTBL2,0),$C(124),22)=1
	S vobj(DBTBL2,-100,0)="",$P(vobj(DBTBL2,0),$C(124),16)=0
	S vobj(DBTBL2,-100,0)="",$P(vobj(DBTBL2,0),$C(124),18)=0
	S vobj(DBTBL2,-100,0)="",$P(vobj(DBTBL2,0),$C(124),7)=0
	S vobj(DBTBL2,-100,0)="",$P(vobj(DBTBL2,0),$C(124),5)=0
	S vobj(DBTBL2,-100,0)="",$P(vobj(DBTBL2,0),$C(124),8)=1
	S vobj(DBTBL2,-100,0)="",$P(vobj(DBTBL2,0),$C(124),6)=0
	;
	; Accept for parameter mismatch warning
	;  #ACCEPT Date=07/05/06; PGM=RussellDS; CR=20967; GROUP=MISMATCH
	N vo1 N vo2 N vo3 N vo4 D DRV^USID(0,"DBTBL2",.DBTBL2,.vo1,.vo2,.vo3,.vo4) K vobj(+$G(vo1)) K vobj(+$G(vo2)) K vobj(+$G(vo3)) K vobj(+$G(vo4)) S vpc=((VFMQ="Q")) K:vpc vobj(+$G(DBTBL2)) Q:vpc 
	 S:'$D(vobj(DBTBL2,0)) vobj(DBTBL2,0)=$S(vobj(DBTBL2,-2):$G(^DBTBL(vobj(DBTBL2,-3),2,vobj(DBTBL2,-4),0)),1:"")
	;
	S vobj(DBTBL2,-100,"0*")="",$P(vobj(DBTBL2),$C(124),1)=$P(vobj(DBTBL2,0),$C(124),9)
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBTBL2FL(DBTBL2,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(DBTBL2,-100) S vobj(DBTBL2,-2)=1 Tcommit:vTp  
	;
	D ^FORMDQ2(SID)
	;
	K vobj(+$G(DBTBL2)) Q 
	;
MODIFY	;
	;
	N SID N VFMQ
	;
	S SID=$$FIND^DBSGETID("DBTBL2",0) Q:(SID="") 
	;
	N DBTBL2,vop1,vop2,vop3 S vop1="SYSDEV",vop2=SID,DBTBL2=$$vDb6("SYSDEV",SID)
	 S vop3=$G(^DBTBL(vop1,2,vop2,-1))
	;
	; Linked screen
	I '($P(vop3,$C(124),1)="") D
	.	;
	.	D MODLINK(SID)
	.	Q 
	E  D ^FORMDQ2(SID)
	;
	Q 
	;
LIST	;
	;
	 S ER=0
	;
	N CNT N TEMP N VRWOPT
	N IO N PGM N PGMLNK N RID
	;
	Q:'$$LIST^DBSGETID("DBTBL2","List",.IO) 
	;
	S RID="DBSSCRLSTLNK"
	D ^URID Q:($get(PGM)="") 
	S PGMLNK=PGM
	;
	S RID="DBSSCRLST"
	D ^URID Q:($get(PGM)="") 
	;
	D OPEN^SCAIO Q:ER 
	;
	N tmpdqrs,vos1,vos2,vos3  N V1 S V1=$J S tmpdqrs=$$vOpen1()
	;
	S CNT=0
	F  Q:'($$vFetch1())  D  Q:ER 
	.	;
	.	N SID N vudwhere
	.	;
	.	; If interactive, prompt to continue
	.	I CNT,(IO=$P) D  Q:ER 
	..		;
	..		N MSG
	..		;
	..		S MSG=""
	..		I ($$^DBSMBAR(161)'=1) S ER=1 S RM=""
	..		Q 
	.	;
	.	S SID=tmpdqrs
	.	S VRWOPT("NOOPEN")=1
	.	S VRWOPT("NOCLOSE")=1
	.	;
	.	N dbtbl2,vop1,vop2,vop3 S vop1="SYSDEV",vop2=SID,dbtbl2=$$vDb6("SYSDEV",SID)
	.	 S vop3=$G(^DBTBL(vop1,2,vop2,-1))
	.	;
	.	I $P(vop3,$C(124),1)="" D  ; Not linked screen
	..		;
	..		S vudwhere="LIBS='SYSDEV' AND SID=:SID AND SEQ>0"
	..		D @("V0^"_PGM)
	..		Q 
	.	;
	.	E  D  ; Linked screen
	..		;
	..		S vudwhere="LIBS='SYSDEV' AND SID=:SID"
	..		D @("V0^"_PGMLNK)
	..		Q 
	.	;
	.	S CNT=CNT+1
	.	Q 
	;
	D CLOSE^SCAIO
	;
	 N V2 S V2=$J D vDbDe1()
	;
	Q 
	;
PRINT	;
	;
	N printDoc
	N CNT
	N IO
	;
	S CNT=$$LIST^DBSGETID("DBTBL2","Print",.IO,.printDoc) Q:(CNT'>0) 
	;
	; IO opened by DBSGETID
	USE IO
	;
	N rs,vos1,vos2,vos3  N V1 S V1=$J S rs=$$vOpen2()
	;
	F  Q:'($$vFetch2())  D
	.	;
	.	N SID
	.	;
	.	S SID=rs
	.	;
	.	N dbtbl2,vop1,vop2,vop3 S vop1="SYSDEV",vop2=SID,dbtbl2=$$vDb6("SYSDEV",SID)
	.	 S vop3=$G(^DBTBL(vop1,2,vop2,-1))
	.	;
	.	I ($P(vop3,$C(124),1)="") D
	..		;
	..		D PRINTSID(SID,printDoc)
	..		Q 
	.	E  D
	..		;
	..		D PRINTSID($P(vop3,$C(124),1),0) ; Skip documentaton for linked screens
	..		I '($P(vop3,$C(124),2)="") D PRINTSID($P(vop3,$C(124),2),0)
	..		I '($P(vop3,$C(124),3)="") D PRINTSID($P(vop3,$C(124),3),0)
	..		I '($P(vop3,$C(124),4)="") D PRINTSID($P(vop3,$C(124),4),0)
	..		I '($P(vop3,$C(124),5)="") D PRINTSID($P(vop3,$C(124),5),0)
	..		I '($P(vop3,$C(124),6)="") D PRINTSID($P(vop3,$C(124),6),0)
	..		I '($P(vop3,$C(124),7)="") D PRINTSID($P(vop3,$C(124),7),0)
	..		I '($P(vop3,$C(124),8)="") D PRINTSID($P(vop3,$C(124),8),0)
	..		I '($P(vop3,$C(124),9)="") D PRINTSID($P(vop3,$C(124),9),0)
	..		I '($P(vop3,$C(124),10)="") D PRINTSID($P(vop3,$C(124),10),0)
	..		I '($P(vop3,$C(124),11)="") D PRINTSID($P(vop3,$C(124),11),0)
	..		I '($P(vop3,$C(124),12)="") D PRINTSID($P(vop3,$C(124),12),0)
	..		I '($P(vop3,$C(124),13)="") D PRINTSID($P(vop3,$C(124),13),0)
	..		I '($P(vop3,$C(124),14)="") D PRINTSID($P(vop3,$C(124),14),0)
	..		I '($P(vop3,$C(124),15)="") D PRINTSID($P(vop3,$C(124),15),0)
	..		I '($P(vop3,$C(124),16)="") D PRINTSID($P(vop3,$C(124),16),0)
	..		I '($P(vop3,$C(124),17)="") D PRINTSID($P(vop3,$C(124),17),0)
	..		I '($P(vop3,$C(124),18)="") D PRINTSID($P(vop3,$C(124),18),0)
	..		I '($P(vop3,$C(124),19)="") D PRINTSID($P(vop3,$C(124),19),0)
	..		I '($P(vop3,$C(124),20)="") D PRINTSID($P(vop3,$C(124),20),0)
	..		I '($P(vop3,$C(124),21)="") D PRINTSID($P(vop3,$C(124),21),0)
	..		I '($P(vop3,$C(124),22)="") D PRINTSID($P(vop3,$C(124),22),0)
	..		I '($P(vop3,$C(124),23)="") D PRINTSID($P(vop3,$C(124),23),0)
	..		I '($P(vop3,$C(124),24)="") D PRINTSID($P(vop3,$C(124),24),0)
	..		I '($P(vop3,$C(124),25)="") D PRINTSID($P(vop3,$C(124),25),0)
	..		I '($P(vop3,$C(124),26)="") D PRINTSID($P(vop3,$C(124),26),0)
	..		I '($P(vop3,$C(124),27)="") D PRINTSID($P(vop3,$C(124),27),0)
	..		I '($P(vop3,$C(124),28)="") D PRINTSID($P(vop3,$C(124),28),0)
	..		Q 
	.	Q 
	;
	D CLOSE^SCAIO
	;
	 N V2 S V2=$J D vDbDe2()
	;
	Q 
	;
PRINTSID(SID,printDoc)	;
	;
	N %NOCLOSE S %NOCLOSE=1
	;
	; Accept for parameter mismatch warning
	;  #ACCEPT Date=07/05/06; PGM=RussellDS; CR=20967; GROUP=MISMATCH
	N vo36 N vo37 N vo38 N vo39 N vo40 D DRV^USID(5,SID,.vo36,.vo37,.vo38,.vo39,.vo40) K vobj(+$G(vo36)) K vobj(+$G(vo37)) K vobj(+$G(vo38)) K vobj(+$G(vo39)) K vobj(+$G(vo40))
	;
	WRITE !
	;
	I printDoc D
	.	;
	.	N XCOPY S XCOPY=1
	.	;
	.	N DLIB S DLIB="SYSDEV"
	.	;
	.	D ENTRY^DBSDOC1
	.	Q 
	;
	Q 
	;
COPY	;
	N vpc
	;
	N isDone S isDone=0
	;
	F  D  Q:isDone 
	.	;
	.	N OLNTB
	.	N %NOPRMT N %READ N SID N TOSID N VFMQ
	.	;
	.	S SID=$$FIND^DBSGETID("DBTBL2",0)
	.	I (SID="") S isDone=1 Q 
	.	;
	.	N DBTBL2 S DBTBL2=$$vDb1("SYSDEV",SID)
	.	;
	.	S %NOPRMT="Q"
	.	; Accept for parameter mismatch warning
	.	;   #ACCEPT Date=07/05/06; PGM=RussellDS; CR=20967; GROUP=MISMATCH
	. N vo41 N vo42 N vo43 N vo44 D DRV^USID(2,"DBTBL2",.DBTBL2,.vo41,.vo42,.vo43,.vo44) K vobj(+$G(vo41)) K vobj(+$G(vo42)) K vobj(+$G(vo43)) K vobj(+$G(vo44))
	.	;
	.	S %READ="TOSID/TBL=[DBTBL2]:NOVAL/XPP=D COPYPP^DBSDS"
	.	S %READ=%READ_"/TYP=U/DES=To Screen Definition Name"
	.	;
	.	S %NOPRMT="F"
	.	S OLNTB=22020 ; Display below DBTBL2 screen
	.	D ^UTLREAD S vpc=((VFMQ'="F")) K:vpc vobj(+$G(DBTBL2)) Q:vpc 
	.	;
	.	D COPYSID(SID,TOSID,1)
	.	K vobj(+$G(DBTBL2)) Q 
	;
	Q 
	;
COPYSID(FROMSID,TOSID,nullPGM)	;
	;
	N dbtbl2 S dbtbl2=$$vDb1("SYSDEV",FROMSID)
	N dbtbl2c S dbtbl2c=$$vReCp1(dbtbl2)
	;
	S vobj(dbtbl2c,-4)=TOSID
	I nullPGM S vobj(dbtbl2c,-100,0)="",$P(vobj(dbtbl2c,0),$C(124),2)=""
	;
	S vobj(dbtbl2c,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBTBL2FL(dbtbl2c,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/NOVALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(dbtbl2c,-100) S vobj(dbtbl2c,-2)=1 Tcommit:vTp   ; Avoid problems with existing wrong values, e.g. DBTBL2.SYS
	;
	N ds,vos1,vos2,vos3 S ds=$$vOpen3()
	;
	F  Q:'($$vFetch3())  D
	.	;
	.	N dbtbl2d S dbtbl2d=$$vDb2($P(ds,$C(9),1),$P(ds,$C(9),2),$P(ds,$C(9),3))
	.	N dbtbl2dc S dbtbl2dc=$$vReCp2(dbtbl2d)
	.	;
	. S vobj(dbtbl2dc,-4)=TOSID
	.	;
	.	S vobj(dbtbl2dc,-2)=1
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^DBTBL(vobj(dbtbl2dc,-3),2,vobj(dbtbl2dc,-4),vobj(dbtbl2dc,-5))=$$RTBAR^%ZFUNC(vobj(dbtbl2dc)) S vobj(dbtbl2dc,-2)=1 Tcommit:vTp  
	.	K vobj(+$G(dbtbl2d)),vobj(+$G(dbtbl2dc)) Q 
	;
	N ds2,vos4,vos5,vos6,vos7 S ds2=$$vOpen4()
	;
	F  Q:'($$vFetch4())  D
	.	;
	.	N tbl2pp S tbl2pp=$$vDb3($P(ds2,$C(9),1),$P(ds2,$C(9),2),$P(ds2,$C(9),3),$P(ds2,$C(9),4))
	.	N tbl2ppc S tbl2ppc=$$vReCp3(tbl2pp)
	.	;
	. S vobj(tbl2ppc,-4)=TOSID
	.	;
	.	S vobj(tbl2ppc,-2)=1
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^DBTBL(vobj(tbl2ppc,-3),2,vobj(tbl2ppc,-4),vobj(tbl2ppc,-5),vobj(tbl2ppc,-6))=vobj(tbl2ppc) S vobj(tbl2ppc,-2)=1 Tcommit:vTp  
	.	K vobj(+$G(tbl2pp)),vobj(+$G(tbl2ppc)) Q 
	;
	K vobj(+$G(dbtbl2)),vobj(+$G(dbtbl2c)) Q 
	;
COPYPP	; Copy to prompt post-processor
	;
	Q:(X="") 
	;
	I '$$VALIDKEY^DBSGETID(X) D
	.	;
	.	S ER=1
	.	; // Alphanumeric format only
	.	S RM=$$^MSG(248)
	.	Q 
	;
	E  I ($D(^DBTBL("SYSDEV",2,X))) D
	.	;
	.	S ER=1
	.	; Already created
	.	S RM=$$^MSG(252)
	.	Q 
	;
	Q 
	;
DELETE	;
	;
	N isDone S isDone=0
	;
	F  D  Q:isDone 
	.	;
	.	N I
	.	N SID N p1
	.	;
	.	S SID=$$FIND^DBSGETID("DBTBL2",0)
	.	I (SID="") S isDone=1 Q 
	.	;
	.	S p1=SID
	.	; Delete <<p1>> ... No Yes
	.	I (+$$^DBSMBAR(164)'=+2) Q 
	.	;
	.	D DELSID(SID)
	.	;
	.	; Done
	.	WRITE $$MSG^%TRMVT($$^MSG(855),"",1)
	.	Q 
	;
	Q 
	;
DELSID(SID)	; Screen ID
	;
	D vDbDe3()
	D vDbDe4()
	K ^DBTBL("SYSDEV",2,SID)
	;
	Q 
	;
GTPGM	;
	;
	N DBTBL N libno N scrnno
	;
	; Avoid warning on lock
	S DBTBL("SYSDEV",0)=""
	;
	LOCK +DBTBL("SYSDEV",0)
	;
	N lib S lib=$G(^DBTBL("SYSDEV",0,"L"))
	N screen,vop1,vop2,vop3 S vop2="SYSDEV",vop1="S",screen=$$vDb7("SYSDEV","S",.vop3)
	;
	S $P(screen,$C(124),1)=$P(screen,$C(124),1)+1
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^DBTBL(vop2,0,vop1)=$$RTBAR^%ZFUNC(screen) S vop3=1 Tcommit:vTp  
	;
	LOCK -DBTBL("SYSDEV",0)
	;
	S libno=($P(lib,$C(124),1))
	S libno=$translate($J("",2-$L(libno))," ","0")_libno
	;
	I ($P(screen,$C(124),1)<1000) D
	.	;
	.	S scrnno=($P(screen,$C(124),1))
	.	S scrnno=$translate($J("",3-$L(scrnno))," ","0")_scrnno
	.	Q 
	E  S scrnno=($P(screen,$C(124),1))
	;
	S PGM="V"_libno_"*"_scrnno
	;
	Q 
	;
PROCDUR(%O,SID)	;
	N vpc
	;
	N VFMQ
	;
	N DBTBL2 S DBTBL2=$$vDb5("SYSDEV",SID)
	 S vobj(DBTBL2,0)=$G(^DBTBL(vobj(DBTBL2,-3),2,vobj(DBTBL2,-4),0))
	;
	I (%O=0) D
	.	;
	.	N PGM
	.	;
	.	D GTPGM
	.	;
	. S vobj(DBTBL2,-100,0)="",$P(vobj(DBTBL2,0),$C(124),2)=PGM
	. S vobj(DBTBL2,-100,0)="",$P(vobj(DBTBL2,0),$C(124),22)=1 ; Default to PSL compiler
	.	Q 
	;
	; Accept for parameter mismatch warning
	;  #ACCEPT Date=07/05/06; PGM=RussellDS; CR=20967; GROUP=MISMATCH
	N vo45 N vo46 N vo47 N vo48 D DRV^USID(%O,"DBSDSMP",.DBTBL2,.vo45,.vo46,.vo47,.vo48) K vobj(+$G(vo45)) K vobj(+$G(vo46)) K vobj(+$G(vo47)) K vobj(+$G(vo48)) S vpc=((VFMQ="Q")) K:vpc vobj(+$G(DBTBL2)) Q:vpc 
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBTBL2FL(DBTBL2,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(DBTBL2,-100) S vobj(DBTBL2,-2)=1 Tcommit:vTp  
	;
	; Compile run-time routine?
	I ($$^DBSMBAR(167)=1) D
	.	;
	.	D ^DBSDSMP
	.	;
	.	WRITE "Done"
	.	Q 
	;
	K vobj(+$G(DBTBL2)) Q 
	;
MODLINK(SID)	;
	;
	N %A2 N %A7 N %A8 N %A9 N %A10
	N %FRAME N OLNTB
	N %READ N %TAB N MSG N VFMQ
	;
	S (%A2,%A8,%A9,%A10)=0
	S %A7=1
	;
	; Modify Linked Screen Definitions~
	S MSG=$$^MSG(3345)
	;
	S %READ="@MSG/CEN/REV,,%A2/NOREQ" ; Screen Control Page
	;
	D bldRead(.%READ,"%A8",61) ; Screen Pre-Processor
	D bldRead(.%READ,"%A9",101) ; User-Defined VLOD Section
	D bldRead(.%READ,"%A10",121) ; Screen Display Pre-Processor
	;
	S %READ=%READ_",%A7/NOREQ," ; Build Run-Time Program
	;
	S %TAB("%A2")=".%A8"
	S %TAB("%A7")=".%A16"
	S %TAB("%A8")=".%A9"
	S %TAB("%A9")=".%A10"
	S %TAB("%A10")=".%A28"
	;
	S OLNTB=40
	S %FRAME=2
	;
	D ^UTLREAD Q:(VFMQ'="F") 
	;
	I %A8 D SCRPRE(SID)
	I %A9 D SCRVLOD(SID)
	I %A10 D MODDSP(SID)
	;
	I %A7,'%A2 D
	.	;
	.	WRITE $$BTM^%TRMVT
	.	D ^DBS2PSL(SID,1) ; Compile screen
	.	Q 
	;
	I %A2 D PROCDUR(1,SID) ; Control page & compile
	;
	Q 
	;
bldRead(%READ,%ASTR,PSEQ)	;
	;
	N REQ
	;
	S %READ=%READ_","_%ASTR_"/"
	;
	I $$vDbEx2() S REQ="REQ"
	E  S REQ="NOREQ"
	;
	S %READ=%READ_REQ
	;
	Q 
	;
MODPRE(SID)	; Screen ID
	;
	; Data Entry Pre-Processor
	D EDT(SID,1,$$^MSG(3339))
	;
	Q 
	;
MODPP(SID)	; Screen ID
	;
	; Data entry post-processor
	D EDT(SID,21,$$^MSG(3338))
	;
	Q 
	;
MODREQ(SID)	; Screen ID
	;
	; Required Data Item Set Definition
	D EDT(SID,41,$$^MSG(6952))
	;
	Q 
	;
MODDOC(SID)	; Screen ID
	;
	; Screen Documentation
	D EDT(SID,81,$$^MSG(3342))
	;
	Q 
	;
SCRPRE(SID)	; Screen ID
	;
	; Screen Pre-Processor
	D EDT(SID,61,$$^MSG(3343))
	;
	Q 
	;
SCRVLOD(SID)	; Screen ID
	;
	; Screen VLOD section
	D EDT(SID,101,$$^MSG(3344))
	;
	Q 
	;
MODDSP(SID)	; Screen ID
	;
	; Screen Display Pre-Processor
	D EDT(SID,121,$$^MSG(3341))
	;
	Q 
	;
EDT(SID,START,MESSAGE)	;
	N vpc
	;
	N END N PSEQ N SEQ N WIDTH
	N DATA
	;
	S END=START+20
	;
	N ds,vos1,vos2,vos3,vos4,vos5 S ds=$$vOpen5()
	;
	S WIDTH=80
	S SEQ=0
	F  Q:'($$vFetch5())  D
	.	;
	.	N rec S rec=$G(^DBTBL($P(ds,$C(9),1),2,$P(ds,$C(9),2),$P(ds,$C(9),3),$P(ds,$C(9),4)))
	.	;
	.	S SEQ=SEQ+1
	.	S DATA(SEQ)=$P(rec,$C(12),1)
	.	I $L(DATA(SEQ))>78 S WIDTH=132
	.	Q 
	;
	D ^DBSWRITE("DATA",3,22,99999,WIDTH,SID_" - "_MESSAGE)
	;
	S vpc=('$D(DATA)) Q:vpc 
	;
	; Delete existing data
	D vDbDe5()
	;
	; Add new data
	S PSEQ=START
	S SEQ=""
	F  S SEQ=$order(DATA(SEQ)) Q:(SEQ="")  D
	.	;
	.	N rec,vop1,vop2,vop3,vop4,vop5 S rec="",vop4="SYSDEV",vop3=SID,vop2=0,vop1=PSEQ,vop5=0
	.	;
	. S $P(rec,$C(12),1)=DATA(SEQ)
	.	S PSEQ=PSEQ+.001
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^DBTBL(vop4,2,vop3,vop2,vop1)=rec S vop5=1 Tcommit:vTp  
	.	Q 
	;
	; Update Date and username field
	N dbtbl2 S dbtbl2=$$vDb1("SYSDEV",SID)
	 S vobj(dbtbl2,0)=$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0))
	;
	S vobj(dbtbl2,-100,0)="",$P(vobj(dbtbl2,0),$C(124),3)=$P($H,",",1)
	S vobj(dbtbl2,-100,0)="",$P(vobj(dbtbl2,0),$C(124),15)=$$USERNAM^%ZFUNC
	;
	K vobj(+$G(dbtbl2)) Q 
	;  #OPTION ResultClass ON
vSIG()	;
	Q "60571^43593^Dan Russell^14036" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM TMPDQ WHERE PID=:V2
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen6()
	F  Q:'($$vFetch6())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^TEMP(v1,v2)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe2()	; DELETE FROM TMPDQ WHERE PID=:V2
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen7()
	F  Q:'($$vFetch7())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^TEMP(v1,v2)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe3()	; DELETE FROM DBTBL2PP WHERE LIBS='SYSDEV' AND SID=:SID
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3 N v4
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen8()
	F  Q:'($$vFetch8())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3) S v4=$P(vRs,$C(9),4)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^DBTBL(v1,2,v2,v3,v4)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe4()	; DELETE FROM DBTBL2D WHERE LIBS='SYSDEV' AND SID=:SID
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen9()
	F  Q:'($$vFetch9())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^DBTBL(v1,2,v2,v3)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe5()	; DELETE FROM DBTBL2PP WHERE LIBS='SYSDEV' AND SID=:SID AND SEQ=0 AND PSEQ>=:START AND PSEQ<:END
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3 N v4
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4,vos5 S vRs=$$vOpen10()
	F  Q:'($$vFetch10())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3) S v4=$P(vRs,$C(9),4)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^DBTBL(v1,2,v2,v3,v4)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(DBTBL2,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL2"
	S vobj(vOid)=$G(^DBTBL(v1,2,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,2,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL2" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDb2(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL2D,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL2D"
	S vobj(vOid)=$G(^DBTBL(v1,2,v2,v3))
	I '(v3>0)
	E  I vobj(vOid)="",'$D(^DBTBL(v1,2,v2,v3))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDb3(v1,v2,v3,v4)	;	vobj()=Db.getRecord(DBTBL2PP,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL2PP"
	S vobj(vOid)=$G(^DBTBL(v1,2,v2,v3,v4))
	I vobj(vOid)="",'$D(^DBTBL(v1,2,v2,v3,v4))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	S vobj(vOid,-6)=v4
	Q vOid
	;
vDb5(v1,v2)	;	vobj()=Db.getRecord(DBTBL2,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL2"
	S vobj(vOid)=$G(^DBTBL(v1,2,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,2,v2))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDb6(v1,v2)	;	voXN = Db.getRecord(DBTBL2,,0)
	;
	N DBTBL2
	S DBTBL2=$G(^DBTBL(v1,2,v2))
	I DBTBL2="",'$D(^DBTBL(v1,2,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL2" X $ZT
	Q DBTBL2
	;
vDb7(v1,v2,v2out)	;	voXN = Db.getRecord(DBTBL0,,1,-2)
	;
	N screen
	S screen=$G(^DBTBL(v1,0,v2))
	I screen="",'$D(^DBTBL(v1,0,v2))
	S v2out='$T
	;
	Q screen
	;
vDbEx2()	;	min(1): DISTINCT LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS='SYSDEV' AND SID=:SID AND SEQ=0 AND PSEQ=:PSEQ
	;
	; No vsql* lvns needed
	;
	;
	S PSEQ=+PSEQ
	I '($D(^DBTBL("SYSDEV",2,SID,0,PSEQ))#2) Q 0
	Q 1
	;
vDbNew1(v1,v2)	;	vobj()=Class.new(DBTBL2)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL2",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vOpen1()	;	ELEMENT FROM TMPDQ WHERE PID=:V1
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(V1) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^TEMP(vos2,vos3),1) I vos3="" G vL1a0
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
	S tmpdqrs=$S(vos3=$$BYTECHAR^SQLUTL(254):"",1:vos3)
	;
	Q 1
	;
vOpen10()	;	LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS='SYSDEV' AND SID=:SID AND SEQ=0 AND PSEQ>=:START AND PSEQ<:END
	;
	;
	S vos1=2
	D vL10a1
	Q ""
	;
vL10a0	S vos1=0 Q
vL10a1	S vos2=$G(SID) I vos2="" G vL10a0
	S vos3=$G(START) I vos3="",'$D(START) G vL10a0
	S vos3=+vos3
	S vos4=$G(END) I vos4="",'$D(END) G vL10a0
	S vos4=+vos4
	S vos5=vos3
	I $D(^DBTBL("SYSDEV",2,vos2,0,vos5)),'(vos5'<vos4) G vL10a9
vL10a8	S vos5=$O(^DBTBL("SYSDEV",2,vos2,0,vos5),1) I vos5=""!(vos5'<vos4) G vL10a0
vL10a9	Q
	;
vFetch10()	;
	;
	;
	I vos1=1 D vL10a8
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs="SYSDEV"_$C(9)_vos2_$C(9)_0_$C(9)_$S(vos5=$$BYTECHAR^SQLUTL(254):"",1:vos5)
	;
	Q 1
	;
vOpen2()	;	ELEMENT FROM TMPDQ WHERE PID=:V1 ORDER BY ELEMENT ASC
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(V1) I vos2="" G vL2a0
	S vos3=""
vL2a3	S vos3=$O(^TEMP(vos2,vos3),1) I vos3="" G vL2a0
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
	S rs=$S(vos3=$$BYTECHAR^SQLUTL(254):"",1:vos3)
	;
	Q 1
	;
vOpen3()	;	LIBS,SID,SEQ FROM DBTBL2D WHERE LIBS='SYSDEV' AND SID=:FROMSID
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(FROMSID) I vos2="" G vL3a0
	S vos3=0
vL3a3	S vos3=$O(^DBTBL("SYSDEV",2,vos2,vos3),1) I vos3="" G vL3a0
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
	S ds="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$$BYTECHAR^SQLUTL(254):"",1:vos3)
	;
	Q 1
	;
vOpen4()	;	LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS='SYSDEV' AND SID=:FROMSID
	;
	;
	S vos4=2
	D vL4a1
	Q ""
	;
vL4a0	S vos4=0 Q
vL4a1	S vos5=$G(FROMSID) I vos5="" G vL4a0
	S vos6=""
vL4a3	S vos6=$O(^DBTBL("SYSDEV",2,vos5,vos6),1) I vos6="" G vL4a0
	S vos7=""
vL4a5	S vos7=$O(^DBTBL("SYSDEV",2,vos5,vos6,vos7),1) I vos7="" G vL4a3
	Q
	;
vFetch4()	;
	;
	;
	I vos4=1 D vL4a5
	I vos4=2 S vos4=1
	;
	I vos4=0 Q 0
	;
	S ds2="SYSDEV"_$C(9)_vos5_$C(9)_$S(vos6=$$BYTECHAR^SQLUTL(254):"",1:vos6)_$C(9)_$S(vos7=$$BYTECHAR^SQLUTL(254):"",1:vos7)
	;
	Q 1
	;
vOpen5()	;	LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS='SYSDEV' AND SID=:SID AND SEQ=0 AND PSEQ>=:START AND PSEQ<:END ORDER BY PSEQ ASC
	;
	;
	S vos1=2
	D vL5a1
	Q ""
	;
vL5a0	S vos1=0 Q
vL5a1	S vos2=$G(SID) I vos2="" G vL5a0
	S vos3=$G(START) I vos3="",'$D(START) G vL5a0
	S vos3=+vos3
	S vos4=$G(END) I vos4="",'$D(END) G vL5a0
	S vos4=+vos4
	S vos5=vos3
	I $D(^DBTBL("SYSDEV",2,vos2,0,vos5)),'(vos5'<vos4) G vL5a9
vL5a8	S vos5=$O(^DBTBL("SYSDEV",2,vos2,0,vos5),1) I vos5=""!(vos5'<vos4) G vL5a0
vL5a9	Q
	;
vFetch5()	;
	;
	;
	I vos1=1 D vL5a8
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds="SYSDEV"_$C(9)_vos2_$C(9)_0_$C(9)_$S(vos5=$$BYTECHAR^SQLUTL(254):"",1:vos5)
	;
	Q 1
	;
vOpen6()	;	PID,ELEMENT FROM TMPDQ WHERE PID=:V2
	;
	;
	S vos1=2
	D vL6a1
	Q ""
	;
vL6a0	S vos1=0 Q
vL6a1	S vos2=$G(V2) I vos2="" G vL6a0
	S vos3=""
vL6a3	S vos3=$O(^TEMP(vos2,vos3),1) I vos3="" G vL6a0
	Q
	;
vFetch6()	;
	;
	;
	I vos1=1 D vL6a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$$BYTECHAR^SQLUTL(254):"",1:vos3)
	;
	Q 1
	;
vOpen7()	;	PID,ELEMENT FROM TMPDQ WHERE PID=:V2
	;
	;
	S vos1=2
	D vL7a1
	Q ""
	;
vL7a0	S vos1=0 Q
vL7a1	S vos2=$G(V2) I vos2="" G vL7a0
	S vos3=""
vL7a3	S vos3=$O(^TEMP(vos2,vos3),1) I vos3="" G vL7a0
	Q
	;
vFetch7()	;
	;
	;
	I vos1=1 D vL7a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$$BYTECHAR^SQLUTL(254):"",1:vos3)
	;
	Q 1
	;
vOpen8()	;	LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS='SYSDEV' AND SID=:SID
	;
	;
	S vos1=2
	D vL8a1
	Q ""
	;
vL8a0	S vos1=0 Q
vL8a1	S vos2=$G(SID) I vos2="" G vL8a0
	S vos3=""
vL8a3	S vos3=$O(^DBTBL("SYSDEV",2,vos2,vos3),1) I vos3="" G vL8a0
	S vos4=""
vL8a5	S vos4=$O(^DBTBL("SYSDEV",2,vos2,vos3,vos4),1) I vos4="" G vL8a3
	Q
	;
vFetch8()	;
	;
	;
	I vos1=1 D vL8a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$$BYTECHAR^SQLUTL(254):"",1:vos3)_$C(9)_$S(vos4=$$BYTECHAR^SQLUTL(254):"",1:vos4)
	;
	Q 1
	;
vOpen9()	;	LIBS,SID,SEQ FROM DBTBL2D WHERE LIBS='SYSDEV' AND SID=:SID
	;
	;
	S vos1=2
	D vL9a1
	Q ""
	;
vL9a0	S vos1=0 Q
vL9a1	S vos2=$G(SID) I vos2="" G vL9a0
	S vos3=0
vL9a3	S vos3=$O(^DBTBL("SYSDEV",2,vos2,vos3),1) I vos3="" G vL9a0
	Q
	;
vFetch9()	;
	;
	;
	I vos1=1 D vL9a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$$BYTECHAR^SQLUTL(254):"",1:vos3)
	;
	Q 1
	;
vReCp1(v1)	;	RecordDBTBL2.copy: DBTBL2
	;
	N vNod,vOid
	I $G(vobj(v1,-2)) D
	. S:'$D(vobj(v1,"v1")) vobj(v1,"v1")=$G(^DBTBL(vobj(v1,-3),2,vobj(v1,-4),-1))
	. S:'$D(vobj(v1,"v5")) vobj(v1,"v5")=$G(^DBTBL(vobj(v1,-3),2,vobj(v1,-4),-5))
	.	F vNod=0 S:'$D(vobj(v1,vNod)) vobj(v1,vNod)=$G(^DBTBL(vobj(v1,-3),2,vobj(v1,-4),vNod))
	S vOid=$$copy^UCGMR(v1)
	Q vOid
	;
vReCp2(v1)	;	RecordDBTBL2D.copy: DBTBL2D
	;
	Q $$copy^UCGMR(dbtbl2d)
	;
vReCp3(v1)	;	RecordDBTBL2PP.copy: DBTBL2PP
	;
	Q $$copy^UCGMR(tbl2pp)
