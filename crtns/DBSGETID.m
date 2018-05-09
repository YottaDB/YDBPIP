DBSGETID	; DATA-QWIK Get ID(s)
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSGETID ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	Q  ; No entry from top
	;
FIND(DQTABLE,NEW)	;
	;
	 S ER=0
	;
	N %FRAME N OLNTB
	N %NOPRMT N %READ N %TAB N NAME N VFMQ
	;
	S %TAB("NAME")=$$TBLPRMPT(DQTABLE)_"/XPP=do PP^"_$T(+0)_"("""_DQTABLE_""","_NEW_")" I ER Q ""
	;
	S %FRAME=2
	S OLNTB=40
	S %READ="@@%FN,,NAME/REQ,"
	S %NOPRMT="F"
	;
	D ^UTLREAD I VFMQ="Q" Q ""
	;
	Q NAME
	;
PP(DQTABLE,NEW)	;
	;
	I '(X="") D
	.	I '$$VALIDKEY(X) D
	..		S ER=1
	..		; Alphanumeric format
	..		S RM=$$^MSG(248)
	..		Q 
	.	; If new, make sure doesn't already exist
	.	I NEW D
	..		;
	..		I $$ISDQELEM(X,DQTABLE) D
	...			S ER=1
	...			; Record already exists
	...			S RM=$$^MSG(2327)
	...			Q 
	..		;
	..		E  S I(3)=""
	..		Q 
	.	Q 
	;
	Q 
	;
LIST(DQTABLE,OPTION,IO,PNTDOC)	;
	;
	N %FRAME N CNT N LEN N OLNTB
	N %CTPRMT N %NOPRMT N %READ N %TAB N DESC N HELP N VFMQ N X N ZSEL
	;
	 N V1 S V1=$J D vDbDe1()
	;
	S CNT=0
	S HELP="* = All  AB* = From AB to ABz  AB-CD = From AB to CD  'AB = Not AB "
	;
	S %TAB("IO")=$$IO^SCATAB($I)
	S %TAB("ZSEL")=$$TBLPRMPT(DQTABLE)
	;
	S LEN=+$piece(%TAB("ZSEL"),"/LEN=",2)
	I 'LEN Q 0
	S LEN=LEN+(LEN\2)
	S %TAB("ZSEL")=%TAB("ZSEL")_"/LEN="_LEN
	;
	S %TAB("ZSEL")=%TAB("ZSEL")_"/XPP=D LISTPP^"_$T(+0)_"("""_DQTABLE_""")"
	;
	S DESC=$piece($piece(%TAB("ZSEL"),"/DES=",2),"/",1)
	S LEN=LEN+$L(DESC)
	;
	I LEN>39 S X="ZSEL/REP=10/NOREQ"
	E  D
	.	S OLNTB=18
	.	S %CTPRMT=2
	.	S X="ZSEL*20/NOREQ" ; Allow room to display filer executive
	.	Q 
	;
	I $get(OPTION)="Print",DQTABLE="DBTBL2" D  ; Documentation prompt for screens
	.	S %TAB("PNTDOC")=".LS1"
	.	S PNTDOC=1
	.	S %READ="@@%FN,,IO/REQ,,PNTDOC/NOREQ,,@HELP/CEN/INC,,"_X
	.	Q 
	E  I '($get(OPTION)="") D  ; List or Print
	.	S %READ="@@%FN,,IO/REQ,,@HELP/CEN/INC,,"_X
	.	Q 
	E  S %READ="@@%FN,,@HELP/CEN/INC,,"_X
	;
	S %FRAME=2
	;
	D ^UTLREAD
	;
	I VFMQ'="Q" D
	.	;
	.	N LIST N N
	.	;
	.	S N=""
	.	F  S N=$order(ZSEL(N)) Q:(N="")  I '(ZSEL(N)="") S CNT=CNT+$$LISTBLD(ZSEL(N),DQTABLE)
	.	;
	.	I '($get(OPTION)="") D OPEN^SCAIO ; List or Print
	.	Q 
	;
	Q CNT
	;
LISTPP(DQTABLE)	; DATA-QWIK table name   /REQ/MECH=VAL
	;
	Q:(X="") 
	;
	I X="*" D
	.	; All definitions
	.	S RM=$$^MSG(241)
	.	S I(3)=""
	.	Q 
	;
	E  I ($E(X,$L(X))="*") D
	.	I '$$RANGECHK(X,DQTABLE) D
	..		S ER=1
	..		; No matches found
	..		S RM=$$^MSG(1955)
	..		Q 
	.	S I(3)=""
	.	Q 
	;
	E  I (X["-") D
	.	I $piece(X,"-",1)]]$piece(X,"-",2) D
	..		S ER=1
	..		; Invalid syntax
	..		S RM=$$^MSG(1475)
	..		Q 
	.	E  D
	..		I '$$RANGECHK(X,DQTABLE) D
	...			S ER=1
	...			; No matches found
	...			S RM=$$^MSG(1955)
	...			Q 
	..		S I(3)=""
	..		Q 
	.	Q 
	;
	E  I '$$ISDQELEM(X,DQTABLE) D
	.	S ER=1
	.	; Invalid syntax/name
	.	S RM=$$^MSG(1480)
	.	Q 
	;
	Q 
	;
LISTBLD(DQID,DQTABLE)	;
	;
	N CNT
	N KEY N LIST N N N WHERE
	;
	S KEY=$$GETKEY(DQTABLE)
	;
	I DQID="*" S WHERE=""
	E  I (($E(DQID,$L(DQID))="*")) S WHERE=KEY_" LIKE '"_$translate(DQID,"*","%")_"'"
	E  I (DQID["-") S WHERE=KEY_" >= '"_$piece(DQID,"-",1)_"' AND "_KEY_" <= '"_$piece(DQID,"-",2)_"'"
	E  S WHERE=KEY_" = '"_DQID_"'"
	;
	D DYNSEL(DQTABLE,WHERE,.LIST)
	;
	S CNT=0
	S N=""
	F  S N=$order(LIST(N)) Q:(N="")  D
	.	 N V1 S V1=$J I '($D(^TEMP(V1,N))#2) D
	..		N tmpdq,vop1,vop2,vop3 S tmpdq="",vop2=$J,vop1=N,vop3=0
	..		;
	..	 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^TEMP(vop2,vop1)=tmpdq S vop3=1 Tcommit:vTp  
	..		;
	..		S CNT=CNT+1
	..		Q 
	.	Q 
	;
	Q CNT
	;
BANNER(FUNCNAME,ALTERNAT)	;
	;
	N DESC S DESC=""
	;
	; Note - can't use Db.getRecord here since optimization appears to ignore 3rd parameter
	I '(FUNCNAME="") D
	.	;
	.	N rs,vos1,vos2,vos3 S rs=$$vOpen1()
	.	;
	.	I $$vFetch1() S DESC=rs
	.	Q 
	;
	I (DESC="") S DESC=$get(ALTERNAT)
	;
	Q $$CJ^%ZTEXT(DESC,80) ; Center in 80 character field
	;
RANGECHK(X,DQTABLE)	;
	;
	N return S return=0
	N KEY N LIST N WHERE
	;
	S KEY=$$GETKEY(DQTABLE)
	;
	I (($E(X,$L(X))="*")) S WHERE=KEY_" LIKE '"_$translate(X,"*","%")_"'"
	E  I (X["-") S WHERE=KEY_" >= '"_$piece(X,"-",1)_"' AND "_KEY_" <= '"_$piece(X,"-",2)_"'"
	;
	D DYNSEL(DQTABLE,WHERE,.LIST)
	;
	I $D(LIST) S return=1
	;
	Q return
	;
TBLPRMPT(DQTABLE)	; DATA-QWIK table  /REQ/MECH=VAL
	;
	N KEY N LIB N return
	;
	S return=""
	;
	N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=DQTABLE,dbtbl1=$$vDb3("SYSDEV",DQTABLE)
	 S vop3=$G(^DBTBL(vop1,1,vop2,16))
	;
	S KEY=$P(vop3,$C(124),1)
	S LIB=$piece(KEY,",",1)
	S KEY=$piece(KEY,",",$L(KEY,","))
	;
	N dbtbl1d,vop4 S dbtbl1d=$$vDb4("SYSDEV",DQTABLE,KEY,.vop4)
	;
	I $G(vop4)=0 D
	.	S ER=1
	.	; Missing reference
	.	S RM=$$^MSG(1766)
	.	Q 
	E  D
	.	S return=return_"/DES="_$P(dbtbl1d,$C(124),10)_"/TYP=U/LEN="_+$P(dbtbl1d,$C(124),2)
	.	S return=return_"/TBL=["_DQTABLE_"]:QUERY ""["_DQTABLE_"]"_LIB_"=""""SYSDEV"""
	.	;
	.	I '($P(dbtbl1d,$C(124),7)="") S return=return_"/XPP="_$P(dbtbl1d,$C(124),7)
	.	I '($P(dbtbl1d,$C(124),8)="") S return=return_"/XPR="_$P(dbtbl1d,$C(124),8)
	.	Q 
	;
	Q return
	;
VALIDKEY(X)	; Value to validate  /REQ/MECH=VAL
	;
	N char1 S char1=$E(X,1)
	;
	I '(char1="%"!(char1="$")!(char1?1U)) Q 0
	I (($E(X,$L(X))="_")) Q 0
	;
	S X=$E(X,2,1048575)
	I $translate(X," `~!@#$%^&*()-+={}[]:;|\,.?/<>vx","")=X Q 1 ; OK
	;
	Q 0
	;
ISDQELEM(DQID,DQTABLE)	;
	;
	N return S return=0
	N LIST N WHERE
	;
	S WHERE=$$GETKEY(DQTABLE)_"='"_DQID_"'"
	;
	D DYNSEL(DQTABLE,WHERE,.LIST)
	;
	I $D(LIST) S return=1
	;
	Q return
	;
GETKEY(DQTABLE)	; DATA-QWIK table name   /REQ/MECH=VAL
	;
	N ACCKEYS
	;
	N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=DQTABLE,dbtbl1=$$vDb3("SYSDEV",DQTABLE)
	 S vop3=$G(^DBTBL(vop1,1,vop2,16))
	;
	S ACCKEYS=$P(vop3,$C(124),1)
	;
	Q $piece(ACCKEYS,",",$L(ACCKEYS,","))
	;
DYNSEL(DQTABLE,WHERE,LIST)	;
	;
	N KEY S KEY=$$GETKEY(DQTABLE)
	;
	;  #ACCEPT Date=09/27/04; PGM=Dan Russell; CR=12334
	N rs,vos1,vos2,sqlcur,exe,sqlcur,vd,vi,vsql,vsub S rs=$$vOpen0(.exe,.vsql,KEY,DQTABLE,$get(WHERE),"","","")
	;
	F  Q:'($$vFetch0())  S LIST($P(rs,$C(9),1))=""
	;
	Q 
	;
vSIG()	;
	Q "60556^43586^Dan Russell^10322" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM TMPDQ WHERE PID = :V1
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen2()
	F  Q:'($$vFetch2())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^TEMP(v1,v2)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	;
vDb3(v1,v2)	;	voXN = Db.getRecord(DBTBL1,,0)
	;
	N dbtbl1
	S dbtbl1=$G(^DBTBL(v1,1,v2))
	I dbtbl1="",'$D(^DBTBL(v1,1,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1" X $ZT
	Q dbtbl1
	;
vDb4(v1,v2,v3,v2out)	;	voXN = Db.getRecord(DBTBL1D,,1,-2)
	;
	N dbtbl1d
	S dbtbl1d=$G(^DBTBL(v1,1,v2,9,v3))
	I dbtbl1d="",'$D(^DBTBL(v1,1,v2,9,v3))
	S v2out='$T
	;
	Q dbtbl1d
	;
vOpen0(exe,vsql,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist)	;	Dynamic MDB ResultSet
	;
	set sqlcur="DYNSEL.rs"
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
vOpen1()	;	DESC FROM SCATBL WHERE FN = :FUNCNAME
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(FUNCNAME) I vos2="" G vL1a0
	I '($D(^SCATBL(1,vos2))#2) G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	I vos1=0 Q 0
	;
	S vos1=100
	S vos3=$G(^SCATBL(1,vos2))
	S rs=$P(vos3,"|",1)
	S vos1=0
	;
	Q 1
	;
vOpen2()	;	PID,ELEMENT FROM TMPDQ WHERE PID = :V1
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
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
