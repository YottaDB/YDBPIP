 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSDBASE ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSDBASE ; 
 ;
 ; *******************************************************************
 ; * IMPORTANT NOTE:                                                 *
 ; * According to the rules that apply to PSL compiler upgrades,     *
 ; * the generated M routine associated with this procedure must be  *
 ; * checked into StarTeam and released with the procedure whenever  *
 ; * changes are made to this procedure.                             *
 ; *                                                                 *
 ; * The mrtns version will be used during upgrades and will then be *
 ; * removed from the mrtns directory.  Therefore, other than in a   *
 ; * development environment, or during an upgrade, an mrtns version *
 ; * of this routine should not exist.                               *
 ; *                                                                 *
 ; * Keep these comments as single line to ensure they exist in the  *
 ; * generated M code.                                               *
 ; *******************************************************************
 ;
 Q  ; Do not call from top
 ;
RUNSP(expr,colnam,tabnam,cnd,hostval,RM) ; 
 N vret
 ;
 N INPUT
 ;
 S INPUT("SQL")=expr
 S INPUT("WHERE")=cnd
 S INPUT("HOSTVARS")=hostval
 ;
 S vret=$$CREATESP(tabnam,"SelectAll",.INPUT,0) Q vret
 ;
CREATESP(RTBL,METHOD,INPUT,REGEN) ; Force regeneration [*]
 N vTp
 ;
 N ER S ER=0
 N seq
 N N N procdata N RM N spname
 ;
 S (N,procdata)=""
 F  S N=$order(INPUT(N)) Q:(N="")  D
 .	;
 .	S procdata=procdata_N_"="_INPUT(N)_$char(13)_$char(10)
 .	Q 
 ;
 S spname=""
 ;
 ; See if procedure already generated and, if so, just return name
 I 'REGEN D
 .	;
 .	N rs,vos1,vos2,vos3,vos4,vos5,vos6,vos7,vos8  N V1 S V1=procdata S rs=$$vOpen1()
 .	;
 . I $$vFetch1() S spname=rs
 . Q 
 ;
 Q:'(spname="") spname
 ;
 I (METHOD="SelectAll") D
 .	;
 .	S spname="T_"_RTBL_"$SEL_ALL"
 .	S seq=0 ; Only one of these
 .	;
 .	D
 ..		;
 ..		N return
 ..		;
 ..		N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ..		;
 ..		S return=$$EXECCP^%DBAPI(0,spname,"*",RTBL,INPUT("WHERE"),INPUT("HOSTVARS"))
 ..		Q 
 .	Q 
 ;
 E  D
 .	;
 .	S ER=1
 .	S RM="Invalid method name"
 .	Q 
 ;
 I 'ER D
 .	;
 .	N dbspid S dbspid=$$vRCgetRecord1^RecordDBSPID(RTBL,METHOD,seq,0)
 .	 S vobj(dbspid,1,1)="" N von S von="" F  S von=$O(^DBSPID(vobj(dbspid,-3),vobj(dbspid,-4),vobj(dbspid,-5),von)) quit:von=""  S vobj(dbspid,1,1)=vobj(dbspid,1,1)_^DBSPID(vobj(dbspid,-3),vobj(dbspid,-4),vobj(dbspid,-5),von)
 .	;
 .	; Note that this may replace an existing, different procedure name.
 .	; This will only occur if we change our naming conventions.
 .  S $P(vobj(dbspid),$C(124),1)=spname
 .  S vobj(dbspid,1,1)=procdata
 .  S $P(vobj(dbspid),$C(124),2)=$P($H,",",1)
 .  S $P(vobj(dbspid),$C(124),3)=$P($H,",",2)
 .	;
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBSPID(dbspid,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbspid,-100) S vobj(dbspid,-2)=1 TC:vTp  
 .	K vobj(+$G(dbspid)) Q 
 ;
 I ER S $ZE="0,"_$ZPOS_","_"%DQ-E-CREATESP,"_$translate($get(RM),",","~"),$EC=",U1001,"
 ;
 Q spname
 ;
REGENSP(RTBL,PROCLIST) ; Procedures regenerated [*] /MECH=REFARR:W
 ;
 N REGENER
 N CRLF
 ;
 S REGENER=0
 S CRLF=$char(13)_$char(10)
 ;
 N ds,vos1,vos2,vos3,vos4,vos5 S ds=$$vOpen2()
 ;
 F  Q:'$$vFetch2()  D
 .	;
 .	N I
 .	N input N procdata N spname N X
 .	;
 . N dbspid,vop1,vop2,vop3,vop4 S vop1=$P(ds,$C(9),1),vop2=$P(ds,$C(9),2),vop3=$P(ds,$C(9),3),dbspid=$$vRCgetRecord1Opt^RecordDBSPID(vop1,vop2,vop3,1,"")
 .	 S vop4="" N von S von="" F  S von=$O(^DBSPID(vop1,vop2,vop3,von)) quit:von=""  S vop4=vop4_^DBSPID(vop1,vop2,vop3,von)
 .	;
 .	S procdata=vop4
 .	;
 .	F I=1:1:$L(procdata,CRLF)-1 D
 ..		;
 ..		S X=$piece(procdata,CRLF,I)
 ..		S input($piece(X,"=",1))=$piece(X,"=",2,$L(X))
 ..		Q 
 .	;
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch2^"_$T(+0)
 .	;
 .	S spname=$$CREATESP(RTBL,vop2,.input,1)
 .	;
 .	S PROCLIST(spname,vop2)=""
 . Q 
 ;
 Q REGENER
 ;
wide(dqtable) ; DATA-QWIK table name
 N vret
 ;
 N dbmapt S dbmapt=$G(^DBMAP("TABLES",%DB,dqtable))
 ;
 S vret=+$P(dbmapt,$C(9),2) Q vret
 ;
LIST(table) ; returns ordered list of columns for a specified table.
 ;
 N list S list=""
 N col
 N rs,vos1,vos2,vos3,vos4,vos5,vos6,vos7,vOid  N V1 S V1=table S rs=$$vOpen3()
 F  Q:'$$vFetch3()  D
 . S col=$P(rs,$C(9),1)
 .	Q:$$isLit^UCGM(col) 
 . S list=list_","_$P(rs,$C(9),1)
 .	Q 
 S list=$E(list,2,9999)
 Q list
 ;
BUILD ; Build Stored procedures for all tables in the DB
 ;
 N CNT N i N vEr
 N dbid N rfid N SPLIST
 ;
 S dbid=$$TRNLNM^%ZFUNC("SCAU_DB")
 ;
  N V1 S V1=$J D vDbDe1()
 ;
 S CNT=$$LIST^DBSGETID("DBTBL1") ; Select table names
 Q:(+CNT=0) 
 ;
 I dbid="GTM" WRITE $$MSG^%TRMVT("",,1) Q 
 ;
 N ds,vos1,vos2,vos3,vos4  N V2 S V2=$J S ds=$$vOpen4()
 F  Q:'$$vFetch4()  D
 . N tmpdq,vop1 S vop1=$P(ds,$C(9),2),tmpdq=$$vRCgetRecord1Opt^RecordTMPDQ($P(ds,$C(9),1),vop1,1,"")
 .	S rfid=vop1
 .	D MAP^DBMAP(dbid,.rfid)
 .	I $L(rfid,",")>1 F i=1:1:$L(rfid,",") D
 ..		S vEr=$$REGENSP($piece(rfid,",",i),.SPLIST)
 ..		Q 
 .	E  S vEr=$$REGENSP(rfid,.SPLIST)
 .	;
 .	I vEr D
 ..		;
 ..		N ERDESC N N N SP
 ..		;
 ..		; Errors: ~p1
 ..		WRITE !!,$$^MSG(6819)
 ..		;
 ..		S (N,SP)=""
 ..		F  S SP=$order(SPLIST(SP)) Q:(SP="")  D
 ...			;
 ...			F  S N=$order(SPLIST(SP,N)) Q:(N="")  D
 ....				;
 ....				S ERDESC=SPLIST(SP,N)
 ....				;
 ....				I '(ERDESC="") WRITE ?10,SP," - ",N,":  ",ERDESC,!
 ....				Q 
 ...			Q 
 ..		Q 
 . Q 
 ;
  N V3 S V3=$J D vDbDe2()
 ;
 ; Press any key message and pause
 WRITE $$MSG^%TRMVT("",,1)
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60955^55454^Dan Russell^9830" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM TMPDQ WHERE PID=:V1
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen5()
 F  Q:'$$vFetch5()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^TEMP(v1,v2)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe2() ; DELETE FROM TMPDQ WHERE PID=:V3
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen6()
 F  Q:'$$vFetch6()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^TEMP(v1,v2)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ;
vOpen1() ; SPNAME FROM DBSPID WHERE RTBL=:RTBL AND METHOD=:METHOD AND PROCDATA=:V1
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(RTBL) I vos3="" G vL1a0
 S vos4=$G(METHOD) I vos4="" G vL1a0
 S vos5=$G(V1)
 S vos6=""
vL1a6 S vos6=$O(^DBSPID(vos3,vos4,vos6),1) I vos6="" G vL1a0
 S vos7=$$READ^DBSMEMO("^DBSPID("_$c(34)_vos3_$c(34)_","_$c(34)_vos4_$c(34)_","_vos6_")")
 I '(vos7=vos5) G vL1a6
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos8=$G(^DBSPID(vos3,vos4,vos6))
 S rs=$P(vos8,"|",1)
 ;
 Q 1
 ;
vOpen2() ; RTBL,METHOD,SEQ FROM DBSPID WHERE RTBL=:RTBL
 ;
 ;
 S vos1=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos1=0 Q
vL2a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(RTBL) I vos3="" G vL2a0
 S vos4=""
vL2a4 S vos4=$O(^DBSPID(vos3,vos4),1) I vos4="" G vL2a0
 S vos5=""
vL2a6 S vos5=$O(^DBSPID(vos3,vos4,vos5),1) I vos5="" G vL2a4
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos1=1 D vL2a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds="" Q 0
 ;
 S ds=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)_$C(9)_$S(vos5=vos2:"",1:vos5)
 ;
 Q 1
 ;
vOpen3() ; COL,POS FROM DBMAP WHERE TBL=:V1 ORDER BY POS ASC
 ;
 ;
 S vOid=$G(^DBTMP($J))-1,^($J)=vOid K ^DBTMP($J,vOid)
 S vos1=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos1=0 Q
vL3a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL3a0
 S vos4=""
vL3a4 S vos4=$O(^DBMAP("COLUMNS",vos4),1) I vos4="" G vL3a11
 S vos5=""
vL3a6 S vos5=$O(^DBMAP("COLUMNS",vos4,vos3,vos5),1) I vos5="" G vL3a4
 S vos6=$G(^DBMAP("COLUMNS",vos4,vos3,vos5))
 S vd=$S(vos5=vos2:"",1:vos5)_$C(9)_$P(vos6,$C(9),3)
 S vos7=$P(vos6,$C(9),3) S:vos7="" vos7=vos2 S ^DBTMP($J,vOid,1,vos7,vos4,vos5)=vd
 G vL3a6
vL3a11 S vos2=""
vL3a12 S vos2=$O(^DBTMP($J,vOid,1,vos2),1) I vos2="" G vL3a0
 S vos3=""
vL3a14 S vos3=$O(^DBTMP($J,vOid,1,vos2,vos3),1) I vos3="" G vL3a12
 S vos4=""
vL3a16 S vos4=$O(^DBTMP($J,vOid,1,vos2,vos3,vos4),1) I vos4="" G vL3a14
 Q
 ;
vFetch3() ;
 ;
 ;
 I vos1=1 D vL3a16
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" K ^DBTMP($J,vOid) Q 0
 ;
 S rs=^DBTMP($J,vOid,1,vos2,vos3,vos4)
 ;
 Q 1
 ;
vOpen4() ; PID,ELEMENT FROM TMPDQ WHERE PID=:V2 ORDER BY ELEMENT ASC
 ;
 ;
 S vos1=2
 D vL4a1
 Q ""
 ;
vL4a0 S vos1=0 Q
vL4a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V2)
 S vos4=""
vL4a4 S vos4=$O(^TEMP(vos3,vos4),1) I vos4="" G vL4a0
 Q
 ;
vFetch4() ;
 ;
 ;
 I vos1=1 D vL4a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds="" Q 0
 ;
 S ds=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen5() ; PID,ELEMENT FROM TMPDQ WHERE PID=:V1
 ;
 ;
 S vos1=2
 D vL5a1
 Q ""
 ;
vL5a0 S vos1=0 Q
vL5a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1)
 S vos4=""
vL5a4 S vos4=$O(^TEMP(vos3,vos4),1) I vos4="" G vL5a0
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
 S vRs=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen6() ; PID,ELEMENT FROM TMPDQ WHERE PID=:V3
 ;
 ;
 S vos1=2
 D vL6a1
 Q ""
 ;
vL6a0 S vos1=0 Q
vL6a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V3)
 S vos4=""
vL6a4 S vos4=$O(^TEMP(vos3,vos4),1) I vos4="" G vL6a0
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
 S vRs=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vCatch2 ; Error trap
 ;
 N regenerr,$ET,$ES S regenerr=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 S REGENER=REGENER+1
 S PROCLIST($P(dbspid,$C(124),1),vop2)=$P(regenerr,",",4)
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch1 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 S ER=1
 S RM=$P(error,",",4)
 D ZX^UCGMR(voxMrk) Q 
