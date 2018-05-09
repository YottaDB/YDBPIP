 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSAG ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSAG ; 
 ;
 Q 
 ;
MENU(OPT) ; Option - 0 = create, 1 = update
 N vTp,vpc
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
 .	N dbtbl22 S dbtbl22=$$vRCgetRecord1^RecordDBTBL22("SYSDEV",AGID,0)
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
 ..	 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL22(dbtbl22,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbtbl22,-100) S vobj(dbtbl22,-2)=1 TC:vTp  
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
 .	N dbtbl22,vop1 S dbtbl22=$$vRCgetRecord1Opt^RecordDBTBL22("SYSDEV",AGID,0,.vop1)
 .	;
 . S vpc=($G(vop1)=0) Q:vpc  ; No table definition yet
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
 . Q 
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
REPEAT(AGID,COLROW) ; Columns or Rows
 N vTp
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
 ..		N rs,vos1,vos2,vos3,vos4,vos5 S rs=$$vOpen1()
 ..		;
 ..  I $$vFetch1() S COL=$$STRCOL^SQLAG($$NUMCOL^SQLAG(rs)+1)
 ..		E  S COL="A"
 ..		;
 ..		N dbtbl22c S dbtbl22c=$$vcdmNew^RecordDBTBL22C() S vobj(dbtbl22c,-3)="SYSDEV" S vobj(dbtbl22c,-4)=AGID
 ..		;
 ..	 N vo6 N vo7 N vo8 N vo9 D DRV^USID(0,"DBTBL22C",.dbtbl22c,.vo6,.vo7,.vo8,.vo9) K vobj(+$G(vo6)) K vobj(+$G(vo7)) K vobj(+$G(vo8)) K vobj(+$G(vo9))
 ..		;
 ..		I (VFMQ="F") D
 ...			;
 ...			I DELETE D
 ....				;
 ....			  ZWI ^DBTBL("SYSDEV",22,AGID,"C",COL)
 ....				Q 
 ...			;
 ...			E  S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL22C(dbtbl22c,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbtbl22c,-100) S vobj(dbtbl22c,-2)=1 TC:vTp  
 ...			Q 
 ..  K vobj(+$G(dbtbl22c)) Q 
 .	E  D
 ..		;
 ..		N ROW
 ..		;
 ..		; Get next available row for default - increment by 10
 ..		N rs,vos6,vos7,vos8,vos9,vos10 S rs=$$vOpen2()
 ..		;
 ..  I $$vFetch2() S ROW=rs+10
 ..		E  S ROW=10
 ..		;
 ..		N dbtbl22r S dbtbl22r=$$vcdmNew^RecordDBTBL22R() S vobj(dbtbl22r,-3)="SYSDEV" S vobj(dbtbl22r,-4)=AGID
 ..		;
 ..	 N vo10 N vo11 N vo12 N vo13 D DRV^USID(0,"DBTBL22R",.dbtbl22r,.vo10,.vo11,.vo12,.vo13) K vobj(+$G(vo10)) K vobj(+$G(vo11)) K vobj(+$G(vo12)) K vobj(+$G(vo13))
 ..		;
 ..		I (VFMQ="F") D
 ...			;
 ...			I 'DELETE S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL22R(dbtbl22r,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbtbl22r,-100) S vobj(dbtbl22r,-2)=1 TC:vTp  
 ...			I DELETE  N V1,V2 S V1=vobj(dbtbl22r,-4),V2=vobj(dbtbl22r,-5)  ZWI ^DBTBL("SYSDEV",22,V1,"R",V2)
 ...			Q 
 ..  K vobj(+$G(dbtbl22r)) Q 
 .	;
 .	I (VFMQ'="F"),'$$YN^DBSMBAR("",$$^MSG(603),1) S QUIT=1
 .	Q 
 ;
 Q 
 ;
CHKDATA(AGID) ; Aggregate ID
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
HASDATA(TABLE) ; Table to check to see if has data
 ;
 I '($D(^DBTBL("SYSDEV",1,TABLE))) Q 0
 ;
 ; Accept dynamic select
 ;  #ACCEPT Date=10/11/05; Pgm=RussellDS; CR=17418
 N rs,vos1,vos2,sqlcur,exe,sqlcur,vd,vi,vsql,vsub S rs=$$vOpen0(.exe,.vsql,"ROW",TABLE,"","","","",1)
 ;
 I '$G(vos1) Q 0
 ;
 Q 1
 ;
AGTBLS(AGID,AGTBL,AGTBLDTL) ; Aggregate detail table /MECH=REF:W
 ;
 S AGTBL="DQA"_AGID
 S AGTBLDTL=AGTBL_"DTL"
 ;
 Q 
 ;
RUN ; 
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
DELETE ; 
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
 TS (vobj):transactionid="CS"
 ;
 N dbtbl22 S dbtbl22=$$vRCgetRecord0Opt^RecordDBTBL22("SYSDEV",AGID,0,"")
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
  TC:$TL 
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
COPY ; 
 N vTp
 ;
 N %READ N %TAB N COPYFROM N COPYTO N VFMQ
 ;
 S %TAB("COPYFROM")=".COPYFROM/TBL=[DBTBL22]"
 S %TAB("COPYTO")=".COPYTO/XPP=D COPYPP^DBSAG(X)"
 ;
 S %READ="@@%FN,,,COPYFROM/REQ,COPYTO/REQ"
 D ^UTLREAD Q:(VFMQ'="F") 
 ;
 TS (vobj):transactionid="CS"
 ;
 N dbtbl22 S dbtbl22=$$vRCgetRecord0^RecordDBTBL22("SYSDEV",COPYFROM,0)
 ;
 N dbtbl22c S dbtbl22c=$$vReCp1(dbtbl22)
 ;
  S vobj(dbtbl22c,-4)=COPYTO
  S $P(vobj(dbtbl22c),$C(124),4)=""
 S vobj(dbtbl22c,-2)=0
 ;
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL22(dbtbl22c,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbtbl22c,-100) S vobj(dbtbl22c,-2)=1 TC:vTp  
 ;
 N dsc,vos1,vos2,vos3,vos4 S dsc=$$vOpen3()
 ;
 F  Q:'$$vFetch3()  D
 .	;
 . N dbtbl22c S dbtbl22c=$$vRCgetRecord1^RecordDBTBL22C($P(dsc,$C(9),1),$P(dsc,$C(9),2),$P(dsc,$C(9),3),1)
 .	;
 .	N copy S copy=$$vReCp2(dbtbl22c)
 .	;
 .  S vobj(copy,-4)=COPYTO
 .	S vobj(copy,-2)=0
 .	;
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL22C(copy,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(copy,-100) S vobj(copy,-2)=1 TC:vTp  
 .	K vobj(+$G(copy)),vobj(+$G(dbtbl22c)) Q 
 ;
 N dsr,vos5,vos6,vos7,vos8 S dsr=$$vOpen4()
 ;
 F  Q:'$$vFetch4()  D
 .	;
 . N dbtbl22r S dbtbl22r=$$vRCgetRecord1^RecordDBTBL22R($P(dsr,$C(9),1),$P(dsr,$C(9),2),$P(dsr,$C(9),3),1)
 .	;
 .	N copy S copy=$$vReCp3(dbtbl22r)
 .	;
 .  S vobj(copy,-4)=COPYTO
 .	S vobj(copy,-2)=0
 .	;
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL22R(copy,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(copy,-100) S vobj(copy,-2)=1 TC:vTp  
 .	K vobj(+$G(copy)),vobj(+$G(dbtbl22r)) Q 
 ;
  TC:$TL 
 ;
 K vobj(+$G(dbtbl22)),vobj(+$G(dbtbl22c)) Q 
 ;
COPYPP(TO) ; 
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
GETDB() ; 
 ;
 N DB
 ;
 S DB=$$SCAU^%TRNLNM("DB")
 I (DB="") S DB="GTM"
 ;
 Q DB
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60913^31094^Dan Russell^9366" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM DBTBL22C WHERE %LIBS='SYSDEV' and AGID=:AGID
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2 N v3
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen5()
 F  Q:'$$vFetch5()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^DBTBL(v1,22,v2,"C",v3)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe2() ; DELETE FROM DBTBL22R WHERE %LIBS='SYSDEV' and AGID=:AGID
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2 N v3
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen6()
 F  Q:'$$vFetch6()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^DBTBL(v1,22,v2,"R",v3)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe3() ; DELETE FROM DBTBL22 WHERE %LIBS='SYSDEV' and AGID=:AGID
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3 S vRs=$$vOpen7()
 F  Q:'$$vFetch7()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^DBTBL(v1,22,v2)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ;
vOpen0(exe,vsql,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist,vOff) ; Dynamic MDB ResultSet
 ;
 set sqlcur="HASDATA.rs"
 N ER,vExpr,mode,RM,vOpen,vTok S ER=0 ;=noOpti
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
 E  S vOpen=$$OPEN^SQLM(.exe,vFrom,vSelect,vWhere,vOrderby,vGroupby,vParlist,,1,,sqlcur) I 'ER D SAV^SQLCACHE(vExpr,.vParlist) s vsql=vOpen
 I ER S $ZE="0,"_$ZPOS_",%PSL-E-SQLFAIL,"_$TR($G(RM),$C(10,44),$C(32,126)),$EC=",U1001,"
 ;
 S vos1=vsql
 Q ""
 ;
vFetch0() ; MDB dynamic FETCH
 ;
 ; type public String exe(),sqlcur,vd,vi,vsql()
 ;
 I vsql=0 S rs="" Q 0
 S vsql=$$^SQLF(.exe,.vd,.vi,.sqlcur)
 S rs=vd
 S vos1=vsql
 S vos2=$G(vi)
 Q vsql
 ;
vOpen1() ; MAX(COL) FROM DBTBL22C WHERE %LIBS='SYSDEV' AND AGID=:AGID
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(AGID) I vos3="" G vL1a0
 S vos4=""
vL1a4 S vos4=$O(^DBTBL("SYSDEV",22,vos3,"C",vos4),1) I vos4="" G vL1a7
 I $S(vos4=vos2:"",1:vos4)'="" S vos5=$S($G(vos5)="":$S(vos4=vos2:"",1:vos4),vos5']$S(vos4=vos2:"",1:vos4):$S(vos4=vos2:"",1:vos4),1:vos5)
 G vL1a4
vL1a7 I $G(vos5)="" S vd="" G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a7
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$G(vos5)
 S vos1=100
 ;
 Q 1
 ;
vOpen2() ; MAX(ROW) FROM DBTBL22R WHERE %LIBS='SYSDEV' AND AGID=:AGID
 ;
 ;
 S vos6=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos6=0 Q
vL2a1 S vos7=$$BYTECHAR^SQLUTL(254)
 S vos8=$G(AGID) I vos8="" G vL2a0
 S vos9=""
vL2a4 S vos9=$O(^DBTBL("SYSDEV",22,vos8,"R",vos9),1) I vos9="" G vL2a7
 S vos10=$S($G(vos10)="":$S(vos9=vos7:"",1:vos9),vos10<$S(vos9=vos7:"",1:vos9):$S(vos9=vos7:"",1:vos9),1:vos10)
 G vL2a4
vL2a7 I $G(vos10)="" S vd="" G vL2a0
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos6=1 D vL2a7
 I vos6=2 S vos6=1
 ;
 I vos6=0 S rs="" Q 0
 ;
 S rs=$G(vos10)
 S vos6=100
 ;
 Q 1
 ;
vOpen3() ; %LIBS,AGID,COL FROM DBTBL22C WHERE %LIBS='SYSDEV' AND AGID=:COPYFROM
 ;
 ;
 S vos1=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos1=0 Q
vL3a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(COPYFROM) I vos3="" G vL3a0
 S vos4=""
vL3a4 S vos4=$O(^DBTBL("SYSDEV",22,vos3,"C",vos4),1) I vos4="" G vL3a0
 Q
 ;
vFetch3() ;
 ;
 ;
 I vos1=1 D vL3a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S dsc="" Q 0
 ;
 S dsc="SYSDEV"_$C(9)_vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen4() ; %LIBS,AGID,ROW FROM DBTBL22R WHERE %LIBS='SYSDEV' AND AGID=:COPYFROM
 ;
 ;
 S vos5=2
 D vL4a1
 Q ""
 ;
vL4a0 S vos5=0 Q
vL4a1 S vos6=$$BYTECHAR^SQLUTL(254)
 S vos7=$G(COPYFROM) I vos7="" G vL4a0
 S vos8=""
vL4a4 S vos8=$O(^DBTBL("SYSDEV",22,vos7,"R",vos8),1) I vos8="" G vL4a0
 Q
 ;
vFetch4() ;
 ;
 ;
 I vos5=1 D vL4a4
 I vos5=2 S vos5=1
 ;
 I vos5=0 S dsr="" Q 0
 ;
 S dsr="SYSDEV"_$C(9)_vos7_$C(9)_$S(vos8=vos6:"",1:vos8)
 ;
 Q 1
 ;
vOpen5() ; %LIBS,AGID,COL FROM DBTBL22C WHERE %LIBS='SYSDEV' AND AGID=:AGID
 ;
 ;
 S vos1=2
 D vL5a1
 Q ""
 ;
vL5a0 S vos1=0 Q
vL5a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(AGID) I vos3="" G vL5a0
 S vos4=""
vL5a4 S vos4=$O(^DBTBL("SYSDEV",22,vos3,"C",vos4),1) I vos4="" G vL5a0
 Q
 ;
vFetch5() ;
 ;
 ;
 I vos1=1 D vL5a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs="SYSDEV"_$C(9)_vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen6() ; %LIBS,AGID,ROW FROM DBTBL22R WHERE %LIBS='SYSDEV' AND AGID=:AGID
 ;
 ;
 S vos1=2
 D vL6a1
 Q ""
 ;
vL6a0 S vos1=0 Q
vL6a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(AGID) I vos3="" G vL6a0
 S vos4=""
vL6a4 S vos4=$O(^DBTBL("SYSDEV",22,vos3,"R",vos4),1) I vos4="" G vL6a0
 Q
 ;
vFetch6() ;
 ;
 ;
 I vos1=1 D vL6a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs="SYSDEV"_$C(9)_vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen7() ; %LIBS,AGID FROM DBTBL22 WHERE %LIBS='SYSDEV' AND AGID=:AGID
 ;
 ;
 S vos1=2
 D vL7a1
 Q ""
 ;
vL7a0 S vos1=0 Q
vL7a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(AGID) I vos3="" G vL7a0
 I '($D(^DBTBL("SYSDEV",22,vos3))#2) G vL7a0
 Q
 ;
vFetch7() ;
 ;
 ;
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vos1=100
 S vRs="SYSDEV"_$C(9)_vos3
 S vos1=0
 ;
 Q 1
 ;
vReCp1(v1) ; RecordDBTBL22.copy: DBTBL22
 ;
 Q $$copy^UCGMR(dbtbl22)
 ;
vReCp2(v1) ; RecordDBTBL22C.copy: DBTBL22C
 ;
 Q $$copy^UCGMR(dbtbl22c)
 ;
vReCp3(v1) ; RecordDBTBL22R.copy: DBTBL22R
 ;
 Q $$copy^UCGMR(dbtbl22r)
