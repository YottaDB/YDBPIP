 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSTBLL ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSTBLL(TABLETYP) ; Table type (CTBL, STBL, or UTBL)
 ;
 N append
 N %BLK N N N RPTIO N tables N tbllist
 ;
 WRITE $$MSG^%TRMVT($$^MSG(5624),0,0) ; Please wait ...
 ;
 D LOOKUP^DBSTBLM(TABLETYP,.tbllist) ; Get list of tables
 ;
 D GETLIST(.tables,.tbllist,TABLETYP,.RPTIO)
 Q:'($D(tbllist)#2) 
 ;
 S append=0
 S N=""
 F  S N=$order(tables(N)) Q:(N="")  D
 .	;
 .	N I
 .	N acckeys N btmkey N desc N sellist N TABLE
 .	;
 .	S TABLE=$piece(tbllist(N)," ",1)
 .	;
 .	N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=TABLE,dbtbl1=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",TABLE,0,"")
 .	 S vop3=$G(^DBTBL(vop1,1,vop2,16))
 .	;
 .	S acckeys=$P(vop3,$C(124),1)
 .	S sellist=""
 .	F I=1:1:$L(acckeys,",") D
 ..		;
 ..		N key S key=$piece(acckeys,",",I)
 ..		;
 ..		I '$$isLit^UCGM(key) S sellist=sellist_key_","
 ..		Q 
 .	;
 .	S sellist=$E(sellist,1,$L(sellist)-1)
 .	;
 .	; Table ~p1 can not be listed
 . I (sellist="") WRITE $$MSG^%TRMVT($$^MSG(5627,TABLE),0,1) Q 
 .	;
 .	; Select the keys and the first item associated with the bottom key
 .	S btmkey=$piece(sellist,",",$L(sellist,","))
 .	;
 .	N rs,vos1,vos2,vos3,vos4,vos5,vos6  N V1 S V1=btmkey S rs=$$vOpen1()
 .	;
 . I $$vFetch1() S sellist=sellist_","_$P(rs,$C(9),1)
 .	;
 .	; Table List ~p1
 .	S desc=$$^MSG(5626,TABLE)_"  "_$P(dbtbl1,$C(124),1)
 .	;
 .	; Don't append on first call since want to open new file,
 .	; but append on all subsequent calls
 .	S %BLK="/,"_RPTIO_$$IODEL^%ZFUNC()
 .	I append S %BLK=%BLK_"APPEND"
 .	E  S append=1
 .	;
 .	D ^DBSRPT(TABLE,sellist,"","",desc)
 . Q 
 ;
 D CLOSE^SCAIO
 ;
 Q 
 ;
GETLIST(tables,tbllist,TABLETYP,IO) ; Output device /MECH=REF:W
 ;
 N %FRAME N N
 N %READ N %TAB N DESC N HELP N VFMQ N vhdg N ZSEL N ZZSEL
 ;
 K tables
 ;
 S HELP=" * = All  AB* = From AB to ABz  AB-CD = From AB to CD  'AB = Not AB "
 ;
 S %TAB("IO")=$$IO^SCATAB($I)
 ;
 I TABLETYP="UTBL" S DESC=$$^MSG(8205) ; User Table
 E  I TABLETYP="STBL" S DESC=$$^MSG(8200) ; System Table
 E  S DESC=$$^MSG(8188) ; Common Table
 ;
 S %TAB("ZSEL")="/DES="_DESC_"/TYP=T/LEN=256/TBL=tbllist(:NOVAL/XPP=D LISTPP^DBSTBLL(X)"
 ;
 S ZZSEL="ZSEL/REP=10/NOREQ"
 ;
 S vhdg="Table         File Name           Description"
 S %READ="@@%FN,,IO,,@HELP/CEN/INC,,"_ZZSEL
 ;
 S %FRAME=2
 ;
 D ^UTLREAD
 Q:VFMQ="Q" 
 ;
 S N=""
 F  S N=$order(ZSEL(N)) Q:(N="")  I '(ZSEL(N)="") D
 .	;
 .	N X S X=ZSEL(N)
 .	;
 .	I (X="*") D
 ..		;
 ..		N M S M=""
 ..		;
 ..		F  S M=$order(tbllist(M)) Q:(M="")  S tables(M)=""
 ..		Q 
 .	E  I ($D(tbllist(X))#2) S tables(X)=""
 .	E  I ($E(X,1)="'") K tables($E(X,2,1048575))
 .	E  I ($E(X,$L(X))="*") D
 ..		;
 ..		N len
 ..		N MATCH N XTBL
 ..		;
 ..		S XTBL=$E(X,1,$L(X)-1)
 ..		S MATCH=XTBL
 ..		;
 ..		I ($D(tbllist(XTBL))#2) S tables(XTBL)=""
 ..		;
 ..		S len=$L(XTBL)
 ..		F  S XTBL=$order(tbllist(XTBL)) Q:((XTBL="")!($E(XTBL,1,len)'=MATCH))  S tables(XTBL)=""
 ..		Q 
 .	E  I (X["-") D
 ..		;
 ..		N END N START
 ..		;
 ..		S START=$piece(X,"-",1)
 ..		S END=$piece(X,"-",2)
 ..		;
 ..		I ($D(tbllist(START))#2) S tables(START)=""
 ..		F  S START=$order(tbllist(START)) Q:((START="")!(START]]END))  S tables(START)=""
 ..		Q 
 .	Q 
 ;
 Q 
 ;
LISTPP(X) ; Input value
 ;
  S ER=0
 ;
 Q:(X="") 
 ;
 I (X="*") S RM=$$^MSG(241) ; All definitions
 ;
 E  I ($D(tbllist(X))#2) D
 .	;
 .	N TABLE
 .	;
 .	S TABLE=$piece(tbllist(X)," ",1)
 .	;
 .	N dbtbl1 S dbtbl1=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",TABLE,0,"")
 .	;
 .	S RM=TABLE_"    "_$P(dbtbl1,$C(124),1)
 . Q 
 ;
 E  I ($E(X,1)="'") D
 .	;
 .	N XTBL S XTBL=$E(X,2,1048575)
 .	;
 .	I '($D(tbllist(XTBL))#2) S ER=1
 .	Q 
 ;
 E  I ($E(X,$L(X))="*") D
 .	;
 .	N len
 .	N XTBL S XTBL=$E(X,1,$L(X)-1)
 .	;
 .	Q:($D(tbllist(XTBL))#2) 
 .	;
 .	S len=$L(XTBL)
 .	S XTBL=$order(tbllist(XTBL))
 .	;
 .	Q:$E(XTBL,1,len)=$E(X,1,$L(X)-1) 
 .	;
 .	S ER=1
 .	Q 
 ;
 E  I (X["-") D
 .	;
 .	N END N START N XTBL
 .	;
 .	S START=$piece(X,"-",1)
 .	S END=$piece(X,"-",2)
 .	;
 .	I (START]]END) D
 ..		;
 ..		S ER=1
 ..		;
 ..		S RM=$$^MSG(1475)
 ..		Q 
 .	;
 .	Q:($D(tbllist(START))#2) 
 .	Q:($D(tbllist(END))#2) 
 .	;
 .	S XTBL=$order(tbllist(START))
 .	Q:(XTBL']]END) 
 .	;
 .	S ER=1
 .	Q 
 ;
 E  S ER=1
 ;
 I ER S RM=$$^MSG(1480) ; Invalid syntax/name
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60659^41656^Dan Russell^5170" ; Signature - LTD^TIME^USER^SIZE
 ;
vOpen1() ; DI,POS FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:TABLE AND NOD=:V1 ORDER BY POS ASC
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(TABLE) I vos3="" G vL1a0
 S vos4=$G(V1) I vos4="",'$D(V1) G vL1a0
 S vos5=""
vL1a5 S vos5=$O(^DBINDX("SYSDEV","STR",vos3,vos4,vos5),1) I vos5="" G vL1a0
 S vos6=""
vL1a7 S vos6=$O(^DBINDX("SYSDEV","STR",vos3,vos4,vos5,vos6),1) I vos6="" G vL1a5
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
 S rs=$S(vos6=vos2:"",1:vos6)_$C(9)_$S(vos5=vos2:"",1:vos5)
 ;
 Q 1
