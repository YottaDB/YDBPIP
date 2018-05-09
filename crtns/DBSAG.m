DBSAG	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSAG ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	Q 
	;
MENU(OPT)	; Option - 0 = create, 1 = update
	N vpc
	;
	 S ER=0
	;
	N doCOLS N doCOMP N doCRTBL N doDELETE N doHDR N doROWS N QUIT
	N %FRAME N OLNTB
	N %NOPRMT N %READ N %TAB N AGID N VFMQ
	;
	I ($get(%DB)="") S %DB=$$GETDB
	;
	S OLNTB=6040
	S AGID=$$FIND^DBSGETID("DBTBL22",'OPT) Q:(AGID="") 
	;
	; Create new record
	I (OPT=0) D
	.	S (doCOLS,doCOMP,doCRTBL,doHDR,doROWS)=1
	.	S doDELETE=0
	.	;
	.	S %TAB("doHDR")=".AGGHC"
	.	S %TAB("doCOLS")=".AGGCC"
	.	S %TAB("doROWS")=".AGGRC"
	.	S %TAB("doCRTBL")=".AGGCR"
	.	S %TAB("doCOMP")=".AGGCMP"
	.	;
	.	S %READ="@@%FN,,doHDR,doCOLS,doROWS,doCRTBL,doCOMP"
	.	Q 
	E  D
	.	S (doCOLS,doCOMP,doCRTBL,doDELETE,doHDR,doROWS)=0
	.	;
	.	S %TAB("doHDR")=".AGGHM"
	.	S %TAB("doCOLS")=".AGGCM"
	.	S %TAB("doROWS")=".AGGRM"
	.	S %TAB("doCRTBL")=".AGGCR/XPP=I X=1 D CHKDATA^DBSAG(AGID)"
	.	S %TAB("doDELETE")=".AGGDEL"
	.	S %TAB("doCOMP")=".AGGCMP"
	.	;
	.	S %READ="@@%FN,,doHDR,doCOLS,doROWS,doCRTBL,doDELETE,doCOMP"
	.	Q 
	;
	S %NOPRMT="F"
	S %FRAME=1
	D ^UTLREAD Q:VFMQ="Q" 
	;
	S QUIT=0
	I (doHDR!(OPT=0)) D  Q:QUIT 
	.	;
	.	N ORIGDTP
	.	N ORIGGRP
	.	;
	.	N dbtbl22 S dbtbl22=$$vDb1("SYSDEV",AGID)
	.	;
	.	S ORIGDTP=$P(vobj(dbtbl22),$C(124),6)
	.	S ORIGGRP=$P(vobj(dbtbl22),$C(124),7)
	.	;
	. N vo2 N vo3 N vo4 N vo5 D DRV^USID(OPT,"DBTBL22",.dbtbl22,.vo2,.vo3,.vo4,.vo5) K vobj(+$G(vo2)) K vobj(+$G(vo3)) K vobj(+$G(vo4)) K vobj(+$G(vo5))
	.	;
	.	I ((OPT=0)&(VFMQ'="F")) S QUIT=1
	.	;
	.	I (VFMQ="F") D
	..		;
	..	 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSAG22(dbtbl22,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(dbtbl22,-100) S vobj(dbtbl22,-2)=1 Tcommit:vTp  
	..		;
	..		I (OPT=1),'doCRTBL,(($P(vobj(dbtbl22),$C(124),6)'=ORIGDTP)!($P(vobj(dbtbl22),$C(124),7)'=ORIGGRP)) D
	...			;
	...			; Table structure has changed. Use function @DBTBL22M to recreate DQA* tables.
	...			WRITE $$MSG^%TRMVT($$^MSG(5436),0,1)
	...			Q 
	..		Q 
	.	K vobj(+$G(dbtbl22)) Q 
	;
	I doCOLS D REPEAT(AGID,"COLUMNS")
	I doROWS D REPEAT(AGID,"ROWS")
	;
	I doCRTBL D  Q:ER 
	.	;
	.	N DDLOUT
	.	;
	.	D DQBLD^SQLAG(AGID,.DDLOUT)
	.	;
	.	; Use DDL file ~p1 to create table definition(s) in ~p2
	.	I '(DDLOUT="") WRITE $$MSG^%TRMVT($$^MSG(5434,DDLOUT,%DB),0,1)
	.	Q 
	;
	I doDELETE D
	.	;
	.	N DATE
	.	N %READ N %TAB N MATDTBL N MATTBL N VFMQ
	.	;
	.	N dbtbl22,vop1 S dbtbl22=$$vDb5("SYSDEV",AGID,.vop1)
	.	;
	.	S vpc=(($G(vop1)=0)) Q:vpc  ; No table definition yet
	.	;
	.	S MATTBL="DQA"_AGID
	.	;
	.	I $P(dbtbl22,$C(124),5) S MATDTBL="DQA"_AGID_"DTL"
	.	;
	.	I (+$P(dbtbl22,$C(124),6)'=+0) D
	..		;
	..		S %TAB("DATE")="["_MATTBL_"]DATE/TBL=["_MATTBL_"]DATE:DISTINCT"
	..		;
	..		S %READ="DATE"
	..		;
	..		D ^UTLREAD
	..		;
	..		Q:(VFMQ'="F") 
	..		;
	..		D DELETE^SQL(MATTBL_" WHERE DATE=:DATE")
	..		I $P(dbtbl22,$C(124),5) D DELETE^SQL(MATDTBL_" WHERE DATE=:DATE")
	..		Q 
	.	;
	.	E  D
	..		;
	..		N DEL S DEL=0
	..		;
	..		S %TAB("DEL")=".DEL1"
	..		;
	..		S %READ="DEL"
	..		;
	..		D ^UTLREAD
	..		;
	..		Q:(VFMQ'="F") 
	..		;
	..		D DELETE^SQL(MATTBL)
	..		I $P(dbtbl22,$C(124),5) D DELETE^SQL(MATDTBL)
	..		Q 
	.	Q 
	;
	I doCOMP D CREATE^SQLAG(AGID)
	;
	I doHDR,(OPT=0) D
	.	;
	.	; Aggregate table definition for ~p1 created
	.	WRITE $$MSG^%TRMVT($$^MSG(5437,AGID),0,1)
	.	Q 
	;
	Q 
	;
REPEAT(AGID,COLROW)	;
	;
	N QUIT S QUIT=0
	;
	F  D  Q:QUIT 
	.	;
	.	N DELETE S DELETE=0
	.	N VFMQ
	.	;
	.	I (COLROW="COLUMNS") D
	..		;
	..		N COL
	..		;
	..		; Get next available column for default
	..		N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen1()
	..		;
	..		I $$vFetch1() S COL=$$STRCOL^SQLAG($$NUMCOL^SQLAG(rs)+1)
	..		E  S COL="A"
	..		;
	..		N dbtbl22c S dbtbl22c=$$vDbNew1("SYSDEV",AGID,"")
	..		;
	..	 N vo6 N vo7 N vo8 N vo9 D DRV^USID(0,"DBTBL22C",.dbtbl22c,.vo6,.vo7,.vo8,.vo9) K vobj(+$G(vo6)) K vobj(+$G(vo7)) K vobj(+$G(vo8)) K vobj(+$G(vo9))
	..		;
	..		I (VFMQ="F") D
	...			;
	...			I DELETE S vobj(dbtbl22c,-2)=3 ; Mark for deletion
	...			;
	...		 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSAG22C(dbtbl22c,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(dbtbl22c,-100) S vobj(dbtbl22c,-2)=1 Tcommit:vTp  
	...			Q 
	..		K vobj(+$G(dbtbl22c)) Q 
	.	E  D
	..		;
	..		N ROW
	..		;
	..		; Get next available row for default - increment by 10
	..		N rs,vos5,vos6,vos7,vos8 S rs=$$vOpen2()
	..		;
	..		I $$vFetch2() S ROW=rs+10
	..		E  S ROW=10
	..		;
	..		N dbtbl22r S dbtbl22r=$$vDbNew2("SYSDEV",AGID,"")
	..		;
	..	 N vo10 N vo11 N vo12 N vo13 D DRV^USID(0,"DBTBL22R",.dbtbl22r,.vo10,.vo11,.vo12,.vo13) K vobj(+$G(vo10)) K vobj(+$G(vo11)) K vobj(+$G(vo12)) K vobj(+$G(vo13))
	..		;
	..		I (VFMQ="F") D
	...			;
	...			I 'DELETE N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSAG22R(dbtbl22r,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(dbtbl22r,-100) S vobj(dbtbl22r,-2)=1 Tcommit:vTp  
	...			I DELETE  N V1,V2 S V1=vobj(dbtbl22r,-4),V2=vobj(dbtbl22r,-5) ZWI ^DBTBL("SYSDEV",22,V1,"R",V2)
	...			Q 
	..		K vobj(+$G(dbtbl22r)) Q 
	.	;
	.	I (VFMQ'="F"),'$$YN^DBSMBAR("",$$^MSG(603),1) S QUIT=1
	.	Q 
	;
	Q 
	;
CHKDATA(AGID)	; Aggregate ID
	;
	N MATTBL N MATDTBL N TABLES
	;
	D AGTBLS(AGID,.MATTBL,.MATDTBL)
	;
	S TABLES=""
	;
	I $$HASDATA(MATTBL) S TABLES=MATTBL
	I $$HASDATA(MATDTBL) S TABLES=TABLES_","_MATDTBL
	;
	I '(TABLES="") D
	.	;
	.	I $E(TABLES,1)="," S TABLES=$E(TABLES,2,99)
	.	;
	.	S ER=1
	.	; Table(s) ~p1 contain data. Cannot create or change table structure. Delete data first.
	.	S RM=$$^MSG(5435,TABLES)
	.	Q 
	;
	Q 
	;
HASDATA(TABLE)	; Table to check to see if has data
	;
	I '($D(^DBTBL("SYSDEV",1,TABLE))) Q 0
	;
	; Accept dynamic select
	;  #ACCEPT Date=10/11/05; Pgm=RussellDS; CR=17418
	N rs,vos1,vos2,sqlcur,exe,sqlcur,vd,vi,vsql,vsub S rs=$$vOpen0(.exe,.vsql,"ROW",TABLE,"","","","")
	;
	I '$G(vos1) Q 0
	;
	Q 1
	;
AGTBLS(AGID,AGTBL,AGTBLDTL)	;
	;
	S AGTBL="DQA"_AGID
	S AGTBLDTL=AGTBL_"DTL"
	;
	Q 
	;
RUN	;
	;
	N OLNTB
	N AGID
	;
	S OLNTB=6040
	;
	S AGID=$$FIND^DBSGETID("DBTBL22",0) Q:(AGID="") 
	;
	D RUN^SQLAG(AGID)
	;
	Q 
	;
DELETE	;
	;
	N DTL
	N MSG
	N AGID
	;
	I ($get(%DB)="") S %DB=$$GETDB
	;
	S AGID=$$FIND^DBSGETID("DBTBL22",0) Q:(AGID="") 
	;
	; Delete Definition ?
	S MSG=$$^DBSMBAR(163) Q:(MSG'=2) 
	;
	Tstart (vobj):transactionid="CS"
	;
	N dbtbl22 S dbtbl22=$$vDb6("SYSDEV",AGID)
	;
	I '($P(dbtbl22,$C(124),4)="") D DEL^%ZRTNDEL($P(dbtbl22,$C(124),4))
	S DTL=$P(dbtbl22,$C(124),5)
	;
	D DELMAT^SQLAG(AGID)
	;
	; Delete aggregate definition tables
	D vDbDe1()
	D vDbDe2()
	D vDbDe3()
	;
	Tcommit:$Tlevel 
	;
	I (%DB'="GTM") D
	.	;
	.	N MATTBL N MATDTBL
	.	;
	.	D AGTBLS(AGID,.MATTBL,.MATDTBL)
	.	;
	.	N TABLES S TABLES=MATTBL
	.	;
	.	I DTL S TABLES=TABLES_","_MATDTBL
	.	;
	.	; Delete table definition ~p1 from ~p2
	.	WRITE $$MSG^%TRMVT($$^MSG(5433,TABLES,%DB),0,1)
	.	Q 
	;
	Q 
	;
COPY	;
	;
	N %READ N %TAB N COPYFROM N COPYTO N VFMQ
	;
	S %TAB("COPYFROM")=".COPYFROM/TBL=[DBTBL22]"
	S %TAB("COPYTO")=".COPYTO/XPP=D COPYPP^DBSAG(X)"
	;
	S %READ="@@%FN,,,COPYFROM/REQ,COPYTO/REQ"
	D ^UTLREAD Q:(VFMQ'="F") 
	;
	Tstart (vobj):transactionid="CS"
	;
	N dbtbl22 S dbtbl22=$$vDb2("SYSDEV",COPYFROM)
	;
	N dbtbl22c S dbtbl22c=$$vReCp1(dbtbl22)
	;
	S vobj(dbtbl22c,-4)=COPYTO
	S $P(vobj(dbtbl22c),$C(124),4)=""
	S vobj(dbtbl22c,-2)=0
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSAG22(dbtbl22c,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(dbtbl22c,-100) S vobj(dbtbl22c,-2)=1 Tcommit:vTp  
	;
	N dsc,vos1,vos2,vos3 S dsc=$$vOpen3()
	;
	F  Q:'($$vFetch3())  D
	.	;
	.	N dbtbl22c S dbtbl22c=$$vDb3($P(dsc,$C(9),1),$P(dsc,$C(9),2),$P(dsc,$C(9),3))
	.	;
	.	N copy S copy=$$vReCp2(dbtbl22c)
	.	;
	. S vobj(copy,-4)=COPYTO
	.	S vobj(copy,-2)=0
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSAG22C(copy,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(copy,-100) S vobj(copy,-2)=1 Tcommit:vTp  
	.	K vobj(+$G(copy)),vobj(+$G(dbtbl22c)) Q 
	;
	N dsr,vos4,vos5,vos6 S dsr=$$vOpen4()
	;
	F  Q:'($$vFetch4())  D
	.	;
	.	N dbtbl22r S dbtbl22r=$$vDb4($P(dsr,$C(9),1),$P(dsr,$C(9),2),$P(dsr,$C(9),3))
	.	;
	.	N copy S copy=$$vReCp3(dbtbl22r)
	.	;
	. S vobj(copy,-4)=COPYTO
	.	S vobj(copy,-2)=0
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSAG22R(copy,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(copy,-100) S vobj(copy,-2)=1 Tcommit:vTp  
	.	K vobj(+$G(copy)),vobj(+$G(dbtbl22r)) Q 
	;
	Tcommit:$Tlevel 
	;
	K vobj(+$G(dbtbl22)),vobj(+$G(dbtbl22c)) Q 
	;
COPYPP(TO)	;
	;
	I ($D(^DBTBL("SYSDEV",22,TO))#2) D
	.	;
	.	S ER=1
	.	; Entry already exists
	.	S RM=$$^MSG(964)
	.	Q 
	;
	Q 
	;
GETDB()	;
	;
	N DB
	;
	S DB=$$SCAU^%TRNLNM("DB")
	I (DB="") S DB="GTM"
	;
	Q DB
	;
vSIG()	;
	Q "60242^59879^RussellDS^9219" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM DBTBL22C WHERE %LIBS='SYSDEV' and AGID=:AGID
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen5()
	F  Q:'($$vFetch5())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^DBTBL(v1,22,v2,"C",v3)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe2()	; DELETE FROM DBTBL22R WHERE %LIBS='SYSDEV' and AGID=:AGID
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen6()
	F  Q:'($$vFetch6())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^DBTBL(v1,22,v2,"R",v3)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe3()	; DELETE FROM DBTBL22 WHERE %LIBS='SYSDEV' and AGID=:AGID
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2 S vRs=$$vOpen7()
	F  Q:'($$vFetch7())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^DBTBL(v1,22,v2)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(DBTBL22,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL22"
	S vobj(vOid)=$G(^DBTBL(v1,22,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,22,v2))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDb2(v1,v2)	;	vobj()=Db.getRecord(DBTBL22,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL22"
	S vobj(vOid)=$G(^DBTBL(v1,22,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,22,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL22" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDb3(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL22C,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL22C"
	S vobj(vOid)=$G(^DBTBL(v1,22,v2,"C",v3))
	I vobj(vOid)="",'$D(^DBTBL(v1,22,v2,"C",v3))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDb4(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL22R,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL22R"
	S vobj(vOid)=$G(^DBTBL(v1,22,v2,"R",v3))
	I vobj(vOid)="",'$D(^DBTBL(v1,22,v2,"R",v3))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDb5(v1,v2,v2out)	;	voXN = Db.getRecord(DBTBL22,,1,-2)
	;
	N dbtbl22
	S dbtbl22=$G(^DBTBL(v1,22,v2))
	I dbtbl22="",'$D(^DBTBL(v1,22,v2))
	S v2out='$T
	;
	Q dbtbl22
	;
vDb6(v1,v2)	;	voXN = Db.getRecord(DBTBL22,,0)
	;
	N dbtbl22
	S dbtbl22=$G(^DBTBL(v1,22,v2))
	I dbtbl22="",'$D(^DBTBL(v1,22,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL22" X $ZT
	Q dbtbl22
	;
vDbNew1(v1,v2,v3)	;	vobj()=Class.new(DBTBL22C)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL22C",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDbNew2(v1,v2,v3)	;	vobj()=Class.new(DBTBL22R)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL22R",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vOpen0(exe,vsql,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist)	;	Dynamic MDB ResultSet
	;
	set sqlcur="HASDATA.rs"
	N ER,vExpr,mode,RM,vTok S ER=0 ;=noOpti
	;
	S vExpr="SELECT "_vSelect_" FROM "_vFrom
	I vWhere'="" S vExpr=vExpr_" WHERE "_vWhere
	I vOrderby'="" S vExpr=vExpr_" ORDER BY "_vOrderby
	I vGroupby'="" S vExpr=vExpr_" GROUP BY "_vGroupby
	S vExpr=$$UNTOK^%ZS($$SQL^%ZS(vExpr,.vTok),vTok)
	;
	S sqlcur=$O(vobj(""),-1)+1
	;
	I $$FLT^SQLCACHE(vExpr,vTok,.vParlist)
	E  S vsql=$$OPEN^SQLM(.exe,vFrom,vSelect,vWhere,vOrderby,vGroupby,vParlist,,1,,sqlcur) I 'ER D SAV^SQLCACHE(vExpr,.vParlist)
	I ER S $ZS="-1,"_$ZPOS_",%PSL-E-SQLFAIL,"_$TR($G(RM),$C(10,44),$C(32,126)) X $ZT
	;
	S vos1=vsql
	Q ""
	;
vFetch0()	; MDB dynamic FETCH
	;
	; type public String exe(),sqlcur,vd,vi,vsql()
	;
	I vsql=0 Q 0
	S vsql=$$^SQLF(.exe,.vd,.vi,.sqlcur)
	S rs=vd
	S vos1=vsql
	S vos2=$G(vi)
	Q vsql
	;
vOpen1()	;	MAX(COL) FROM DBTBL22C WHERE %LIBS='SYSDEV' AND AGID=:AGID
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(AGID) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^DBTBL("SYSDEV",22,vos2,"C",vos3),1) I vos3="" G vL1a6
	I $S(vos3=$C(254):"",1:vos3)'="" S vos4=$S('$D(vos4):$S(vos3=$C(254):"",1:vos3),vos4']$S(vos3=$C(254):"",1:vos3):$S(vos3=$C(254):"",1:vos3),1:vos4)
	G vL1a3
vL1a6	I $G(vos4)="" S vd="" G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a6
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$G(vos4)
	S vos4=""
	S vos1=100
	;
	Q 1
	;
vOpen2()	;	MAX(ROW) FROM DBTBL22R WHERE %LIBS='SYSDEV' AND AGID=:AGID
	;
	;
	S vos5=2
	D vL2a1
	Q ""
	;
vL2a0	S vos5=0 Q
vL2a1	S vos6=$G(AGID) I vos6="" G vL2a0
	S vos7=""
vL2a3	S vos7=$O(^DBTBL("SYSDEV",22,vos6,"R",vos7),1) I vos7="" G vL2a6
	S vos8=$S('$D(vos8):$S(vos7=$C(254):"",1:vos7),vos8<$S(vos7=$C(254):"",1:vos7):$S(vos7=$C(254):"",1:vos7),1:vos8)
	G vL2a3
vL2a6	I $G(vos8)="" S vd="" G vL2a0
	Q
	;
vFetch2()	;
	;
	;
	I vos5=1 D vL2a6
	I vos5=2 S vos5=1
	;
	I vos5=0 Q 0
	;
	S rs=$G(vos8)
	S vos8=""
	S vos5=100
	;
	Q 1
	;
vOpen3()	;	%LIBS,AGID,COL FROM DBTBL22C WHERE %LIBS='SYSDEV' AND AGID=:COPYFROM
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(COPYFROM) I vos2="" G vL3a0
	S vos3=""
vL3a3	S vos3=$O(^DBTBL("SYSDEV",22,vos2,"C",vos3),1) I vos3="" G vL3a0
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
	S dsc="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen4()	;	%LIBS,AGID,ROW FROM DBTBL22R WHERE %LIBS='SYSDEV' AND AGID=:COPYFROM
	;
	;
	S vos4=2
	D vL4a1
	Q ""
	;
vL4a0	S vos4=0 Q
vL4a1	S vos5=$G(COPYFROM) I vos5="" G vL4a0
	S vos6=""
vL4a3	S vos6=$O(^DBTBL("SYSDEV",22,vos5,"R",vos6),1) I vos6="" G vL4a0
	Q
	;
vFetch4()	;
	;
	;
	I vos4=1 D vL4a3
	I vos4=2 S vos4=1
	;
	I vos4=0 Q 0
	;
	S dsr="SYSDEV"_$C(9)_vos5_$C(9)_$S(vos6=$C(254):"",1:vos6)
	;
	Q 1
	;
vOpen5()	;	%LIBS,AGID,COL FROM DBTBL22C WHERE %LIBS='SYSDEV' AND AGID=:AGID
	;
	;
	S vos1=2
	D vL5a1
	Q ""
	;
vL5a0	S vos1=0 Q
vL5a1	S vos2=$G(AGID) I vos2="" G vL5a0
	S vos3=""
vL5a3	S vos3=$O(^DBTBL("SYSDEV",22,vos2,"C",vos3),1) I vos3="" G vL5a0
	Q
	;
vFetch5()	;
	;
	;
	I vos1=1 D vL5a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen6()	;	%LIBS,AGID,ROW FROM DBTBL22R WHERE %LIBS='SYSDEV' AND AGID=:AGID
	;
	;
	S vos1=2
	D vL6a1
	Q ""
	;
vL6a0	S vos1=0 Q
vL6a1	S vos2=$G(AGID) I vos2="" G vL6a0
	S vos3=""
vL6a3	S vos3=$O(^DBTBL("SYSDEV",22,vos2,"R",vos3),1) I vos3="" G vL6a0
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
	S vRs="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen7()	;	%LIBS,AGID FROM DBTBL22 WHERE %LIBS='SYSDEV' AND AGID=:AGID
	;
	;
	S vos1=2
	D vL7a1
	Q ""
	;
vL7a0	S vos1=0 Q
vL7a1	S vos2=$G(AGID) I vos2="" G vL7a0
	I '($D(^DBTBL("SYSDEV",22,vos2))#2) G vL7a0
	Q
	;
vFetch7()	;
	;
	;
	;
	I vos1=0 Q 0
	;
	S vos1=100
	S vRs="SYSDEV"_$C(9)_vos2
	S vos1=0
	;
	Q 1
	;
vReCp1(v1)	;	RecordDBTBL22.copy: DBTBL22
	;
	Q $$copy^UCGMR(dbtbl22)
	;
vReCp2(v1)	;	RecordDBTBL22C.copy: DBTBL22C
	;
	Q $$copy^UCGMR(dbtbl22c)
	;
vReCp3(v1)	;	RecordDBTBL22R.copy: DBTBL22R
	;
	Q $$copy^UCGMR(dbtbl22r)
