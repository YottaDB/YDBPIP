DBSTBLL(TABLETYP)	; Table type (CTBL, STBL, or UTBL)
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSTBLL ****
	;
	; 11/08/2007 14:07 - chenardp
	;
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
	.	N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=TABLE,dbtbl1=$$vDb2("SYSDEV",TABLE)
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
	.	I (sellist="") WRITE $$MSG^%TRMVT($$^MSG(5627,TABLE),0,1) Q 
	.	;
	.	; Select the keys and the first item associated with the bottom key
	.	S btmkey=$piece(sellist,",",$L(sellist,","))
	.	;
	.	N rs,vos1,vos2,vos3,vos4,vos5  N V1 S V1=btmkey S rs=$$vOpen1()
	.	;
	.	I $$vFetch1() S sellist=sellist_","_$P(rs,$C(9),1)
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
	.	Q 
	;
	D CLOSE^SCAIO
	;
	Q 
	;
GETLIST(tables,tbllist,TABLETYP,IO)	;
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
	.	E  I (($E(X,1)="'")) K tables($E(X,2,1048575))
	.	E  I (($E(X,$L(X))="*")) D
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
LISTPP(X)	; Input value
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
	.	N dbtbl1 S dbtbl1=$$vDb2("SYSDEV",TABLE)
	.	;
	.	S RM=TABLE_"    "_$P(dbtbl1,$C(124),1)
	.	Q 
	;
	E  I (($E(X,1)="'")) D
	.	;
	.	N XTBL S XTBL=$E(X,2,1048575)
	.	;
	.	I '($D(tbllist(XTBL))#2) S ER=1
	.	Q 
	;
	E  I (($E(X,$L(X))="*")) D
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
	;
vSIG()	;
	Q "60659^41656^Dan Russell^5110" ; Signature - LTD^TIME^USER^SIZE
	;
vDb2(v1,v2)	;	voXN = Db.getRecord(DBTBL1,,0)
	;
	N dbtbl1
	S dbtbl1=$G(^DBTBL(v1,1,v2))
	I dbtbl1="",'$D(^DBTBL(v1,1,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1" X $ZT
	Q dbtbl1
	;
vOpen1()	;	DI,POS FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:TABLE AND NOD=:V1 ORDER BY POS ASC
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(TABLE) I vos2="" G vL1a0
	S vos3=$G(V1) I vos3="",'$D(V1) G vL1a0
	S vos4=""
vL1a4	S vos4=$O(^DBINDX("SYSDEV","STR",vos2,vos3,vos4),1) I vos4="" G vL1a0
	S vos5=""
vL1a6	S vos5=$O(^DBINDX("SYSDEV","STR",vos2,vos3,vos4,vos5),1) I vos5="" G vL1a4
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
	S rs=$S(vos5=$C(254):"",1:vos5)_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
