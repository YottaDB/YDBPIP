 ; 
 ; **** Routine compiled from DATA-QWIK Procedure SCAER ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
 ; Leave this line until new DBSPROC doesn't replace it (see CR27800)
 ;  #OPTION ResultClass ON
 ; Error log report
 ;
 ; These two variables will not survive loading symbol table
 N %ZTX
 N %ZTLoad
 ;
 D PROC(.%ZTLoad)
 ;
 I $D(%ZTLoad) D
 .	;
 .	; Remove all variables and reset symbol table from %ZTLoad array
 .	;
 .	;   #ACCEPT Date=10/06/05; Pgm=RussellDS; CR=17397; Group=Bypass
 .	;*** Start of code by-passed by compiler
 .	kill (%ZTLoad)
 .	;*** End of code by-passed by compiler ***
 .	;
 .	S %ZTX=""
 .	F  S %ZTX=$order(%ZTLoad(%ZTX)) Q:(%ZTX="")  I '($E(%ZTLoad(%ZTX),1,4)="%ZTX") D
 ..		;
 ..		I ($L(%ZTLoad(%ZTX))>2048) D
 ...			;
 ...			I ($L(%ZTLoad(%ZTX),"=")=2) S @$piece(%ZTLoad(%ZTX),"=",1)=$$QSUB^%ZS($piece(%ZTLoad(%ZTX),"=",2),"""")
 ...			;
 ...			E  WRITE !!,%ZTLoad(%ZTX),!!,"Variable above is too long to load",!
 ...			Q 
 ..		E  D
 ...			;
 ...			;     #ACCEPT Date=12/19/2007; Pgm=RussellDS; CR=31014; Group=Bypass
 ...			;*** Start of code by-passed by compiler
 ...			set @%ZTLoad(%ZTX)
 ...			;*** End of code by-passed by compiler ***
 ...			Q 
 ..		Q 
 .	Q 
 ;
 Q 
 ;
PROC(%ZTLoad) ; Main processing
 N vpc
 ;
 N DATE
 N exit
 N ET N %NOBANNER N %NOPRMT N %READ
 N %TAB N TMP N VFMQ N X
 N ERSEQ N OLNTB N SEQ
 ;
 S DATE=$P($H,",",1)
 ;
 S %TAB("DATE")=".TJD4/HLP=[ERROR]DATE/TBL=[ERROR]DATE:DISTINCT/XPP=D DATEPP^SCAER"
 S %TAB("SEQ")=".SEQ2/TBL=""TMP(/RH=Seq     Error ID         Description""/XPR=D SEQPRE^SCAER"
 ;
 S %READ="@@%FN,,DATE/REQ,SEQ/REQ"
 S %NOPRMT="F"
 ;
 D ^UTLREAD
 ;
 ; Reset terminal attributes
 D CLOSE^SCADRV
 ;
 Q:(VFMQ="Q") 
 ;
 S ERSEQ=$piece(TMP(SEQ)," ",1)
 S ET=$piece(TMP(SEQ),"|",2)
 ;
 N errrec,vop1,vop2,vop3 S vop1=DATE,vop2=ET,vop3=ERSEQ,errrec=$$vRCgetRecord0Opt^RecordERROR(DATE,ET,ERSEQ,0,"")
  S errrec=$G(^ERROR(vop1,vop2,vop3,1))
 ;
 WRITE !!,"Error information -",!!
 WRITE ?5,"Date:  ",$S(vop1'="":$ZD(vop1,"MM/DD/YEAR"),1:"")," at ",$$vtim2str($P(errrec,$C(124),2),"24:60:SS"),!
 WRITE ?5,"Sequence:  ",vop3,!
 WRITE ?5,"Directory:  ",$P(errrec,$C(124),9),!
 WRITE ?5,"User:  ",$P(errrec,$C(124),1),!
 WRITE ?5,"Job:  ",$P(errrec,$C(124),4),!
 WRITE ?5,"Device:  ",$P(errrec,$C(124),3),!
 WRITE ?5,"Error:  ",$P(errrec,$C(124),5),!!
 ;
 S exit=0
 ;
 ; Prompt for and handle options
 F  Q:'('exit)  D
 .	;
 .	N file S file=$$vClVobj($ST,"IO")
 .	;
 .	S $P(vobj(file,1),"|",1)=""
 .	;
 .	WRITE !,"Variable to display, '?' for other options, RETURN to quit:  "
 .	;   #ACCEPT Date=12/20/2007; Pgm=RussellDS; CR=31014; Group=Read
 .	R X
 .	WRITE !!
 .	;
 .	I (X="") S exit=1 K vobj(+$G(file)) Q 
 .	;
 .	; For single variable display, will only display first 400 bytes for long values
 .	I (X'="?") D  K vobj(+$G(file)) Q 
 ..		;
 ..		N where S where="DATE=:DATE AND ET=:ET AND SEQ=:ERSEQ AND VAR LIKE '#VAR%' AND "
 ..		;
 ..		I '($E(X,$L(X))="(") S where=where_"VALUE LIKE '"_X_"=%'"
 ..		E  S where=where_"VALUE LIKE '"_X_"%'"
 ..		;
 ..		;    #ACCEPT Date=12/20/2007; Pgm=RussellDS; CR=31014; Group=Dynamic
 ..		N rs,exe,sqlcur,vd,vi,vsql,vsub S rs=$$vOpen0(.exe,.vsql,"VALUE","ERROR9",where,"","","",1)
 ..		;
 ..		F  Q:'$$vFetch0(rs)  WRITE vobj(rs),!
 ..		K vobj(+$G(rs)) Q 
 .	;
 .	WRITE !!,"(L)oad, (O)utput, show (A)ll, (V)ariables, or (N)on-variable info:  "
 .	;   #ACCEPT Date=12/20/2007; Pgm=RussellDS; CR=31014; Group=Read
 .	R X
 .	;
 .	S vpc=(X="") K:vpc vobj(+$G(file)) Q:vpc 
 .	;
 .	S X=$ZCONVERT(X,"U")
 .	;
 .	I (X="L") D
 ..		;
 ..		N seqno
 ..		;
 ..		N ds,vos1,vos2,vos3,vos4,vos5,vos6 S ds=$$vOpen1()
 ..		;
 ..		F  Q:'$$vFetch1()  D
 ...			;
 ...   N error9,vop4 S vop4=$P(ds,$C(9),4),error9=$$vRCgetRecord1Opt^RecordERROR9($P(ds,$C(9),1),$P(ds,$C(9),2),$P(ds,$C(9),3),vop4,1,"")
 ...			;
 ...			S seqno=+$E(vop4,5,$L(vop4))
 ...			;
 ...			I ((seqno#1)=0) S %ZTLoad(seqno)=$P(error9,$C(12),1)
 ...			E  S %ZTLoad(seqno\1)=%ZTLoad(seqno\1)_$P(error9,$C(12),1)
 ...   Q 
 ..		;
 ..		S exit=1
 ..  Q 
 .	;
 .	E  I (",A,V,N,"[(","_X_",")) D
 ..		;
 ..		N where S where="DATE=:DATE AND ET=:ET AND SEQ=:ERSEQ"
 ..		;
 ..		I (X="V") S where=where_" AND VAR LIKE '#VAR%'"
 ..		E  I (X="N") S where=where_" AND VAR NOT LIKE '#VAR%'"
 ..		;
 ..		;    #ACCEPT Date=12/20/2007; Pgm=RussellDS; CR=31014 ; Group=Dynamic
 ..		N ds,exe,sqlcur,vd,vi,vsql,vsub S ds=$$vOpen0(.exe,.vsql,"DATE,ET,SEQ,VAR","ERROR9",where,"SEQ ASC","","",1)
 ..		;
 ..		F  Q:'$$vFetch0(ds)  D
 ...			;
 ...			N error9,vop5 S vop5=$P(vobj(ds),$C(9),4),error9=$$vRCgetRecord1Opt^RecordERROR9($P(vobj(ds),$C(9),1),$P(vobj(ds),$C(9),2),$P(vobj(ds),$C(9),3),vop5,1,"")
 ...			;
 ...			D writeInfo(file,vop5,$P(error9,$C(12),1))
 ...   Q 
 ..		;
 ..		S exit=1
 ..		K vobj(+$G(ds)) Q 
 .	;
 .	E  I (X="O") D
 ..		;
 ..		N IO N IOTYP
 ..		;
 ..		D ^SCAIO
 ..		;
 ..		Q:($get(IO)="") 
 ..		;
 ..		I ($get(IOTYP)="RMS") D
 ...			;
 ...			S $P(vobj(file,1),"|",2)=$$PARSE^%ZFUNC(IO,"DIRECTORY")
 ...			S $P(vobj(file,1),"|",1)=$$PARSE^%ZFUNC(IO,"NAME")_$$PARSE^%ZFUNC(IO,"TYPE")
 ...			S $P(vobj(file,1),"|",3)="WRITE/NEWV"
 ...			S $P(vobj(file,1),"|",4)=5
 ...			;
 ...			N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ...			;
 ...			D open^UCIO(file,$T(+0),"PROC","file")
 ...			Q 
 ..		;
 ..		D writeIt(file,"PIP Version 0.2")
 ..		D writeIt(file,"Profile Error on "_$S(vop1'="":$ZD(vop1,"MM/DD/YEAR"),1:"")_" at "_$$vtim2str($P(errrec,$C(124),2),"24:60:SS")_" Sequence "_vop3)
 ..		D writeIt(file,$P(errrec,$C(124),5))
 ..		D writeIt(file,"Directory: "_$P(errrec,$C(124),9)_"  User: "_$P(errrec,$C(124),1)_"  Job: "_$P(errrec,$C(124),4)_"  Device: "_$P(errrec,$C(124),3))
 ..		;
 ..		N ds,vos7,vos8,vos9,vos10,vos11,vos12 S ds=$$vOpen2()
 ..		;
 ..		F  Q:'$$vFetch2()  D
 ...			;
 ...   N error9,vop6 S vop6=$P(ds,$C(9),4),error9=$$vRCgetRecord1Opt^RecordERROR9($P(ds,$C(9),1),$P(ds,$C(9),2),$P(ds,$C(9),3),vop6,1,"")
 ...			;
 ...			D writeInfo(file,vop6,$P(error9,$C(12),1))
 ...   Q 
 ..		;
 ..		I '($P(vobj(file,1),"|",1)="") D close^UCIO(file)
 ..		S exit=1
 ..  Q 
 .	K vobj(+$G(file)) Q 
 ;
 Q 
 ;
writeInfo(file,VAR,VALUE) ; ERROR9.VALUE value
 ;
 I ($E(VAR,$L(VAR)-3+1,1048575)="001"),'(VAR[".") D
 .	;
 .	N desc S desc=""
 .	;
 .	D writeIt(file,"")
 .	D writeIt(file,"")
 .	I ($E(VAR,1,7)="#DEVICE") S desc="Device info:"
 .	E  I ($E(VAR,1,10)="#INTRINSIC") S desc="Intrinsic info:"
 .	E  I ($E(VAR,1,6)="#STACK") S desc="Stack info:"
 .	E  I ($E(VAR,1,4)="#VAR") S desc="Variable info:"
 .	;
 .	D writeIt(file,"--------------------------------------------------------------------------------")
 .	D writeIt(file,desc)
 .	D writeIt(file,"")
 .	Q 
 ;
 D writeIt(file,VALUE)
 ;
 Q 
 ;
writeIt(file,data) ; Data to write
 ;
 ; Write either to file or to screen
 ;
 I ($P(vobj(file,1),"|",1)="") WRITE data,!
 E  D write^UCIO(file,data)
 ;
 Q 
 ;
RPT ; Call full report
 ;
 N RID
 ;
 S RID="SCAER"
 ;
 D DRV^URID
 ;
 Q 
 ;
DATEPP ; Date post processor
 ;
 N ERCNT
 N DATE1
 ;
 Q:(X="") 
 ;
 S DATE1=$$^SCAJD(X)
 ;
 N rs,vos1,vos2,vos3,vos4,vos5,vos6 S rs=$$vOpen3()
 ;
 I $$vFetch3() S ERCNT=rs
 E  S ERCNT=0
 ;
 ; No errors logged on ~p1
 I (ERCNT=0) D
 .	;
 .	S ER=1
 .	S RM=$$^MSG(1931,$S(DATE1'="":$ZD(DATE1,"MM/DD/YEAR"),1:""))
 .	Q 
 ;
 ; ~p1 errors logged
 E  S RM=$$^MSG(3036,ERCNT)
 ;
 Q 
 ;
SEQPRE ; Sequence pre-processor
 ;
 N CNT
 N ZE
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch2^"_$T(+0)
 ;
 N rs,vos1,vos2,vos3,vos4,vos5,vos6,vOid S rs=$$vOpen4()
 ;
 S CNT=1
 ;
 F  Q:'$$vFetch4()  D
 .	;
 .	N SEQ
 .	;
 . S ZE=$P(rs,$C(9),3)
 . I (ZE="") S ZE=$P(rs,$C(9),1)
 .	E  S ZE=$piece(ZE,",",1,2)_","_$piece(ZE,",",4)
 .	;
 .	; Remove control characters that affect screen display
 .	S ZE=$translate(ZE,$char(10)_$char(11)_$char(12)_$char(13),"    ")
 .	;
 . S SEQ=$P(rs,$C(9),2)
 .	S SEQ=SEQ_$J("",15-$L(SEQ))
 .	;
 . S TMP(CNT)=SEQ_"  "_$E(ZE,1,55)_"|"_$P(rs,$C(9),1)
 .	;
 .	S CNT=CNT+1
 .	Q 
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60998^46954^Dan Russell^8255" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vtim2str(vo,vm) ; Time.toString
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I (vo="") Q ""
 I (vm="") S vm="24:60:SS"
 N cc
 ;  #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=BYPASS
 ;*** Start of code by-passed by compiler
 SET cc=$ZDATE(","_vo,vm)
 ;*** End of code by-passed by compiler ***
 Q cc
 ;
vClVobj(vSt,vCls) ; Create a new object
 ;
 N vOid
 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)=vCls_$C(9)_vSt
 Q vOid
 ;
vOpen0(exe,vsql,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist,vOff) ; Dynamic MDB ResultSet
 ;
 N vOid
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
 S vOid=sqlcur
 S vobj(vOid,0)=vsql
 S vobj(vOid,-1)="ResultSet"
 S vobj(vOid,-2)="$$vFetch0^"_$T(+0)
 S vobj(vOid,-3)=$$RsSelList^UCDBRT(vSelect)
 S vobj(vOid,-4)=$G(vsql("D"))
 S vobj(vOid,-5)=0
 Q vOid
 ;
vFetch0(vOid) ; MDB dynamic FETCH
 ;
 ; type public String exe(),sqlcur,vd,vi,vsql()
 ;
 I vsql=0 S vobj(vOid)="" Q 0
 S vsql=$$^SQLF(.exe,.vd,.vi,.sqlcur)
 S vobj(vOid)=vd
 S vobj(vOid,0)=vsql
 S vobj(vOid,.1)=$G(vi)
 Q vsql
 ;
vOpen1() ; DATE,ET,SEQ,VAR FROM ERROR9 WHERE DATE=:DATE AND ET=:ET AND SEQ=:ERSEQ AND VAR LIKE '#VAR%'
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(DATE)
 ;
 S vos4=$G(ET) I vos4="" G vL1a0
 S vos5=$G(ERSEQ)
 S vos6="#VAR"
 I $D(^ERROR(vos3,vos4,vos5,9,vos6)),'(vos6]]("#VAR"_$C(1114109))) G vL1a9
vL1a8 S vos6=$O(^ERROR(vos3,vos4,vos5,9,vos6),1) I vos6=""!(vos6]]("#VAR"_$C(1114109))) G vL1a0
vL1a9 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a8
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds="" Q 0
 ;
 S ds=vos3_$C(9)_vos4_$C(9)_vos5_$C(9)_$S(vos6=vos2:"",1:vos6)
 ;
 Q 1
 ;
vOpen2() ; DATE,ET,SEQ,VAR FROM ERROR9 WHERE DATE=:DATE AND ET=:ET AND SEQ=:ERSEQ ORDER BY SEQ ASC
 ;
 ;
 S vos7=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos7=0 Q
vL2a1 S vos8=$$BYTECHAR^SQLUTL(254)
 S vos9=$G(DATE)
 ;
 S vos10=$G(ET) I vos10="" G vL2a0
 S vos11=$G(ERSEQ)
 S vos12=""
vL2a7 S vos12=$O(^ERROR(vos9,vos10,vos11,9,vos12),1) I vos12="" G vL2a0
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos7=1 D vL2a7
 I vos7=2 S vos7=1
 ;
 I vos7=0 S ds="" Q 0
 ;
 S ds=vos9_$C(9)_vos10_$C(9)_vos11_$C(9)_$S(vos12=vos8:"",1:vos12)
 ;
 Q 1
 ;
vOpen3() ; COUNT(SEQ) FROM ERROR WHERE DATE=:DATE1
 ;
 ;
 S vos1=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos1=0 Q
vL3a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(DATE1)
 ;
 S vos4=""
vL3a5 S vos4=$O(^ERROR(vos3,vos4),1) I vos4="" G vL3a10
 S vos5=""
vL3a7 S vos5=$O(^ERROR(vos3,vos4,vos5),1) I vos5="" G vL3a5
 S vos6=$G(vos6)+1
 G vL3a7
vL3a10 I $G(vos6)="" S vos6=0
 Q
 ;
vFetch3() ;
 ;
 ;
 I vos1=1 D vL3a10
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$G(vos6)
 S vos1=100
 ;
 Q 1
 ;
vOpen4() ; ET,SEQ,MUMPSZE FROM ERROR WHERE DATE=:DATE ORDER BY SEQ ASC
 ;
 ;
 S vOid=$G(^DBTMP($J))-1,^($J)=vOid K ^DBTMP($J,vOid)
 S vos1=2
 D vL4a1
 Q ""
 ;
vL4a0 S vos1=0 Q
vL4a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(DATE)
 ;
 S vos4=""
vL4a5 S vos4=$O(^ERROR(vos3,vos4),1) I vos4="" G vL4a12
 S vos5=""
vL4a7 S vos5=$O(^ERROR(vos3,vos4,vos5),1) I vos5="" G vL4a5
 S vos6=$G(^ERROR(vos3,vos4,vos5,1))
 S vd=$S(vos4=vos2:"",1:vos4)_$C(9)_$S(vos5=vos2:"",1:vos5)_$C(9)_$P(vos6,"|",5)
 S ^DBTMP($J,vOid,1,vos5,vos4)=vd
 G vL4a7
vL4a12 S vos2=""
vL4a13 S vos2=$O(^DBTMP($J,vOid,1,vos2),1) I vos2="" G vL4a0
 S vos3=""
vL4a15 S vos3=$O(^DBTMP($J,vOid,1,vos2,vos3),1) I vos3="" G vL4a13
 Q
 ;
vFetch4() ;
 ;
 ;
 I vos1=1 D vL4a15
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" K ^DBTMP($J,vOid) Q 0
 ;
 S rs=^DBTMP($J,vOid,1,vos2,vos3)
 ;
 Q 1
 ;
vCatch2 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 S ER=1
 ;
 ; System error
 S RM=error_" ... "_$$^MSG(7061)
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch1 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 D close^UCIO(file)
 ;
 I '($P(error,",",3)["IOEOF") S $ZE=error,$EC=",U1001,"
 D ZX^UCGMR(voxMrk) Q 
