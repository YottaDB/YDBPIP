UCLREGEN	;
	;
	; **** Routine compiled from DATA-QWIK Procedure UCLREGEN ****
	;
	; 11/08/2007 14:08 - chenardp
	;
	;
	Q  ; No entry at top
	;
	; ---------------------------------------------------------------------
PURGE	;
	;
	; Consider adding MSG - This function will delete all UCLREGEN records on and prior to the date entered
	;
	N PURGEDT
	N %READ N %TAB N VFMQ
	;
	S %TAB("PURGEDT")=".DATE1"
	S PURGEDT=$P($H,",",1)
	S %READ="@@%FN,,PURGEDT/REQ"
	;
	D ^UTLREAD I VFMQ="Q" Q 
	;
	D vDbDe1()
	;
	Q 
	;
	; ---------------------------------------------------------------------
SET(table,column,func)	;
	;
	N SEQ
	;
	Tstart (vobj):transactionid="CS"
	;
	N rs,vos1,vos2 S rs=$$vOpen1()
	I $$vFetch1() S SEQ=rs+1
	E  S SEQ=1
	;
	N uclregen,vop1,vop2 S uclregen="",vop1=SEQ,vop2=0
	S $P(uclregen,$C(124),1)=$get(table)
	S $P(uclregen,$C(124),2)=$get(column)
	S $P(uclregen,$C(124),3)=$get(func)
	S $P(uclregen,$C(124),4)=$P($H,",",1)
	S $P(uclregen,$C(124),5)=$P($H,",",2)
	S $P(uclregen,$C(124),6)=$get(%UID)
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^UCLREGEN(vop1)=$$RTBAR^%ZFUNC(uclregen) S vop2=1 Tcommit:vTp  
	;
	Tcommit:$Tlevel 
	;
	Q 
	;
	; ---------------------------------------------------------------------
SETRTN(RTN)	; name of routine
	N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen2()
	;
	F  Q:'($$vFetch2())  D SET("","",rs_"^"_RTN)
	;
	Q 
	;
	; ---------------------------------------------------------------------
START(interval)	; Seconds to hibernate between cycles /NOREQ/DFT=600
	;
	N isRUNING S isRUNING=0
	N I
	N outfile N params N procname N UCLREGEN
	;
	S UCLREGEN=""
	;
	LOCK +UCLREGEN:2
	E  D  Q 
	.	S ER=1
	.	; Monitor is already running
	.	S RM=$$^MSG(8364)
	.	Q 
	;
	I ($get(interval)'>0) S interval=600 ; Set default
	;
	; Set process name
	S procname="UCLREGEN_"_$$^UCXCUVAR("PTMDIRID")
	S outfile=procname_"_"_$P($H,",",1)_"_"_$P($H,",",2)_".log"
	S params=$$JOBPARAM^%OSSCRPT(procname,,,,outfile)
	;
	S ER='$$^%ZJOB("DAEMON^UCLREGEN("_interval_")",params,0)
	;
	LOCK -UCLREGEN ; Free lock to let daemon have it
	;
	; ~p1 not submitted
	I ER S RM=$$^MSG(6799,procname) Q 
	;
	; Try for up to 10 seconds to determine if the job started
	F I=1:1:10 D  Q:isRUNING 
	.	;
	.	HANG 1
	.	LOCK +UCLREGEN:0
	.	I   LOCK -UCLREGEN
	.	E  S isRUNING=1
	.	Q 
	;
	I isRUNING D
	.	S ER="W"
	.	; ~p1 monitor started
	.	S RM=$$^MSG(5534,"UCLREGEN")
	.	Q 
	E  D
	.	S ER=1
	.	; ~p1 monitor did not start
	.	S RM=$$^MSG(5536,"UCLREGEN")
	.	Q 
	;
	Q 
	;
	; ---------------------------------------------------------------------
DAEMON(interval)	; Seconds to hibernate between cycles /NOREQ/DFT=600
	;
	 ; To avoid warning on lock
	;
	 ; Stop check interval in seconds
	;
	N isSTOP S isSTOP=0
	N hangfor N hangtill N now N runtime N stoptime
	;
	I ($get(interval)'>0) S interval=600 ; Set default
	;
	LOCK +UCLREGEN:10
	E  Q  ; Cannot obtain lock, don't run
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"  ; Log errors, then exit
	;
	; Clear stop indicator
	ZWI ^UCLREGEN(0)
	;
	S stoptime=$$SETTIME(60)
	S runtime=$$SETTIME(interval)
	;
	F  D  Q:isSTOP 
	.	;
	.	; Hibernate until earliest of stoptime or runtime
	.	I (stoptime<runtime) S hangtill=stoptime
	.	E  S hangtill=runtime
	.	;
	.	S hangfor=hangtill-$$SETTIME(0)
	.	;
	.	I (hangfor>0) HANG hangfor
	.	;
	.	S now=$$SETTIME(0)
	.	;
	.	; Process stop first
	.	I (+now'<+stoptime) D  Q:isSTOP 
	..		;
	..		N uclregen,vop1 S uclregen=$$vDb4(0,.vop1)
	..		;
	..		I ($G(vop1)>0) S isSTOP=1
	..		;
	..		E  S stoptime=$$SETTIME(60) ; Reset stop time
	..		Q 
	.	;
	.	I (+now'<+runtime) D
	..		;
	..		D REGEN
	..		;
	..		S runtime=$$SETTIME(interval) ; Reset run time
	..		Q 
	.	Q 
	;
	; Clear stop indicator
	ZWI ^UCLREGEN(0)
	;
	LOCK -UCLREGEN
	;
	Q 
	;
	; ---------------------------------------------------------------------
RUN	;
	;
	D TERMSET^SCADRV ; Reset terminal for compile messages
	WRITE !
	;
	D REGEN
	;
	S ER="W"
	; Done
	S RM=$$^MSG(855)
	;
	Q 
	;
	; ---------------------------------------------------------------------
REGEN	;
	N vpc
	;
	N LASTSEQ
	N element N elemtype N relink N SORT
	;
	N ds,vos1,vos2 S ds=$$vOpen3()
	;
	S vpc=('$G(vos1)) Q:vpc 
	;
	; Sort into element list - ensures only single entry per element
	F  Q:'($$vFetch3())  D
	.	;
	.	N COLNAME N FUNC N TABLENAM N WHERE
	.	;
	.	N uclregen,vop1 S vop1=ds,uclregen=$G(^UCLREGEN(vop1))
	.	;
	.	S LASTSEQ=vop1 ; High water mark for delete
	.	;
	.	S TABLENAM=$P(uclregen,$C(124),1)
	.	S COLNAME=$P(uclregen,$C(124),2)
	.	S FUNC=$P(uclregen,$C(124),3)
	.	;
	.	I '(TABLENAM="") D
	..		;
	..		I (COLNAME="*") S WHERE="TABLE=:TABLENAM"
	..		E  S WHERE="TABLE=:TABLENAM AND COLUMN=:COLNAME"
	..		Q 
	.	E  S WHERE="FUNC=:FUNC"
	.	;
	.	;   #ACCEPT Date=05/06/05; PGM=Dan Russell; CR=15379
	.	N rs,vos3,vos4,sqlcur,exe,sqlcur,vd,vi,vsql,vsub S rs=$$vOpen0(.exe,.vsql,"TARGET","SYSMAPLITDTA",WHERE,"","","")
	.	;
	.	F  Q:'($$vFetch0())  D
	..		;
	..		N TARGET S TARGET=rs
	..		;
	..		N smaprtns S smaprtns=$G(^SYSMAP("RTN2ELEM",TARGET))
	..		;
	..		I '(($P(smaprtns,$C(124),2)="")!($P(smaprtns,$C(124),1)="")) S SORT($P(smaprtns,$C(124),1),$P(smaprtns,$C(124),2))=""
	..		Q 
	.	Q 
	;
	; Now have list of all elements to regenerate
	;
	S (elemtype,element)=""
	F  S elemtype=$order(SORT(elemtype)) Q:(elemtype="")  D
	.	F  S element=$order(SORT(elemtype,element)) Q:(element="")  D
	..		;
	..		N PGM S PGM=""
	..		;
	..		I (elemtype="Batch") D
	...			;
	...			 N V1 S V1=element I ($D(^DBTBL("SYSDEV",33,V1))#2) D
	....				;
	....				D COMPILE^DBSBCH(element,,.PGM)
	....				I '(PGM="") S relink(PGM)=""
	....				Q 
	...			Q 
	..		;
	..		E  I (elemtype="Filer") D
	...			;
	...			 N V1 S V1=element I ($D(^DBTBL("SYSDEV",1,V1))) D
	....				;
	....				N I
	....				;
	....				D COMPILE^DBSFILB(element,,,.PGM)
	....				;
	....				; Filers may generate more than a single routine
	....				I '(PGM="") F I=1:1:$L(PGM,",") S relink($piece(PGM,",",I))=""
	....				Q 
	...			Q 
	..		;
	..		E  I (elemtype="Procedure") D
	...			;
	...			 N V1 S V1=element I ($D(^DBTBL("SYSDEV",25,V1))#2) D
	....				;
	....				D COMPILE^DBSPROC(element,.PGM)
	....				I '(PGM="") S relink(PGM)=""
	....				Q 
	...			;
	...			Q 
	..		;
	..		E  I (elemtype="Report") D
	...			;
	...			 N V1 S V1=element I ($D(^DBTBL("SYSDEV",5,V1))) D
	....				;
	....				D ^DBSRW(element,,.PGM)
	....				I '(PGM="") S relink(PGM)=""
	....				Q 
	...			Q 
	..		;
	..		E  I (elemtype="Screen") D
	...			;
	...			I '($E(element,1)="z")  N V1 S V1=element I ($D(^DBTBL("SYSDEV",2,V1))) D
	....				;
	....				N FILES N SCRPGM
	....				;
	....				N dbtbl2,vop2,vop3,vop4 S vop2="SYSDEV",vop3=element,dbtbl2=$$vDb5("SYSDEV",element)
	....				 S vop4=$G(^DBTBL(vop2,2,vop3,0))
	....				;
	....				S FILES=$P(vop4,$C(124),1) ; Needed by DBS2PSL
	....				S SCRPGM=$P(vop4,$C(124),2)
	....				;
	....				D ^DBS2PSL(element)
	....				;
	....				; Reload if there was no routine to start
	....				I (SCRPGM="") D
	.....					;
	.....					N dbtbl2x,vop5,vop6,vop7 S vop5="SYSDEV",vop6=element,dbtbl2x=$$vDb5("SYSDEV",element)
	.....					 S vop7=$G(^DBTBL(vop5,2,vop6,0))
	.....					;
	.....					S SCRPGM=$P(vop7,$C(124),2)
	.....					Q 
	....				;
	....				I '(SCRPGM="") S relink(SCRPGM)=""
	....				Q 
	...			Q 
	..		Q 
	.	Q 
	;
	; Delete rows used from UCLREGEN
	D vDbDe2()
	;
	; Signal servers to relink the regenerated routines
	;
	; Go through all active server types
	N rs,vos5,vos6 S rs=$$vOpen4()
	F  Q:'($$vFetch4())  D
	.	;
	.	N pgm N svtyp
	.	;
	.	S svtyp=rs
	.	;
	.	S pgm=""
	.	F  S pgm=$order(relink(pgm)) Q:(pgm="")  D LINK^PBSUTL(svtyp,pgm)
	.	Q 
	;
	Q 
	;
	; ---------------------------------------------------------------------
SETTIME(offset)	; Offset from now
	;
	N date S date=$P($H,",",1)
	N seconds S seconds=$P($H,",",2)+offset
	;
	I (seconds>86400) D
	.	S date=date+1
	.	S seconds=seconds-86400
	.	Q 
	;
	Q date_$E(((100000+seconds)),2,6)
	;
	; ---------------------------------------------------------------------
STOP	;
	;
	 ; To avoid warning on lock
	;
	LOCK +UCLREGEN:0
	I   D  Q 
	.	S ER=1
	.	; Monitor is not running
	.	S RM=$$^MSG(8366)
	.	LOCK -UCLREGEN
	.	Q 
	;
	N uclregen,vop1,vop2 S vop1=0,uclregen=$$vDb4(0,.vop2)
	;
	S $P(uclregen,$C(124),1)="UCLREGEN"
	S $P(uclregen,$C(124),2)="SEQ"
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^UCLREGEN(vop1)=$$RTBAR^%ZFUNC(uclregen) S vop2=1 Tcommit:vTp  
	;
	WRITE $$MSG^%TRMVT("Signal sent to monitor ... waiting for stop",0,0,0,23)
	;
	LOCK +UCLREGEN:70
	I   D
	.	S ER="W"
	.	; ~p1 monitor stopped
	.	S RM=$$^MSG(5535,"UCLREGEN")
	.	LOCK -UCLREGEN
	.	Q 
	E  D
	.	S ER=1
	.	; ~p1 monitor did not stop
	.	S RM=$$^MSG(5537,"UCLREGEN")
	.	Q 
	;
	Q 
	;
vSIG()	;
	Q "60652^58850^Dan Russell^12907" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM UCLREGEN WHERE CHGDATE <= :PURGEDT
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen5()
	F  Q:'($$vFetch5())  D
	.	S v1=vRs
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^UCLREGEN(v1)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe2()	; DELETE FROM UCLREGEN WHERE SEQ > 0 AND SEQ <= :LASTSEQ
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen6()
	F  Q:'($$vFetch6())  D
	.	S v1=vRs
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^UCLREGEN(v1)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	;
vDb4(v1,v2out)	;	voXN = Db.getRecord(UCLREGEN,,1,-2)
	;
	N uclregen
	S uclregen=$G(^UCLREGEN(v1))
	I uclregen="",'$D(^UCLREGEN(v1))
	S v2out='$T
	;
	Q uclregen
	;
vDb5(v1,v2)	;	voXN = Db.getRecord(DBTBL2,,0)
	;
	N dbtbl2
	S dbtbl2=$G(^DBTBL(v1,2,v2))
	I dbtbl2="",'$D(^DBTBL(v1,2,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL2" X $ZT
	Q dbtbl2
	;
vOpen0(exe,vsql,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist)	;	Dynamic MDB ResultSet
	;
	set sqlcur="REGEN.rs"
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
	S vos3=vsql
	Q ""
	;
vFetch0()	; MDB dynamic FETCH
	;
	; type public String exe(),sqlcur,vd,vi,vsql()
	;
	I vsql=0 Q 0
	S vsql=$$^SQLF(.exe,.vd,.vi,.sqlcur)
	S rs=vd
	S vos3=vsql
	S vos4=$G(vi)
	Q vsql
	;
vOpen1()	;	SEQ FROM UCLREGEN ORDER BY SEQ DESC
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=""
vL1a2	S vos2=$O(^UCLREGEN(vos2),-1) I vos2="" G vL1a0
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
	S rs=$S(vos2=$C(254):"",1:vos2)
	;
	Q 1
	;
vOpen2()	;	LABEL FROM SYSMAPLITFNC WHERE FUNCFILE=:RTN
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(RTN) I vos2="" G vL2a0
	S vos3=""
vL2a3	S vos3=$O(^SYSMAP("LITFUNC",vos2,vos3),1) I vos3="" G vL2a0
	S vos4=""
vL2a5	S vos4=$O(^SYSMAP("LITFUNC",vos2,vos3,vos4),1) I vos4="" G vL2a3
	Q
	;
vFetch2()	;
	;
	;
	I vos1=1 D vL2a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen3()	;	SEQ FROM UCLREGEN WHERE SEQ > 0 ORDER BY SEQ ASC
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=0
vL3a2	S vos2=$O(^UCLREGEN(vos2),1) I vos2="" G vL3a0
	Q
	;
vFetch3()	;
	;
	;
	I vos1=1 D vL3a2
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds=$S(vos2=$C(254):"",1:vos2)
	;
	Q 1
	;
vOpen4()	;	DISTINCT SVTYP FROM SVCTRLT
	;
	;
	S vos5=2
	D vL4a1
	Q ""
	;
vL4a0	S vos5=0 Q
vL4a1	S vos6=""
vL4a2	S vos6=$O(^SVCTRL(vos6),1) I vos6="" G vL4a0
	Q
	;
vFetch4()	;
	;
	;
	I vos5=1 D vL4a2
	I vos5=2 S vos5=1
	;
	I vos5=0 Q 0
	;
	S rs=$S(vos6=$C(254):"",1:vos6)
	;
	Q 1
	;
vOpen5()	;	SEQ FROM UCLREGEN WHERE CHGDATE <= :PURGEDT
	;
	;
	S vos1=2
	D vL5a1
	Q ""
	;
vL5a0	S vos1=0 Q
vL5a1	S vos2=$G(PURGEDT) I vos2="",'$D(PURGEDT) G vL5a0
	;
	S vos3=""
vL5a4	S vos3=$O(^UCLREGEN(vos3),1) I vos3="" G vL5a0
	S vos4=$G(^UCLREGEN(vos3))
	I '($P(vos4,"|",4)'>vos2&($P(vos4,"|",4)'="")) G vL5a4
	Q
	;
vFetch5()	;
	;
	;
	I vos1=1 D vL5a4
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen6()	;	SEQ FROM UCLREGEN WHERE SEQ > 0 AND SEQ <= :LASTSEQ
	;
	;
	S vos1=2
	D vL6a1
	Q ""
	;
vL6a0	S vos1=0 Q
vL6a1	S vos2=$G(LASTSEQ) I vos2="",'$D(LASTSEQ) G vL6a0
	S vos3=0
vL6a3	S vos3=$O(^UCLREGEN(vos3),1) I vos3=""!(vos3>vos2) G vL6a0
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
	S vRs=$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vtrap1	;	Error trap
	;
	N error S error=$ZS
	;
	D ZE^UTLERR
	Q 
