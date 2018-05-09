DBSTBLA(vREF,vSTR,vFMT)	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSTBLA ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	N vINFO N vRETURN
	;
	I ($get(vFMT)="") S vFMT="T"
	;
	S vINFO("STR")=""
	S vINFO("FMT")=vFMT
	S vINFO("MIN")=""
	S vINFO("MAX")=""
	S vINFO("HDG")=""
	;
	D SETUP^DBSTBL(vREF,.vINFO) I ER Q ""
	;
	I ($D(vINFO("NOVALIDATE"))#2) Q vSTR
	;
	S vRETURN=""
	;
	; Array (includes picklist) -- array lookup is in form of vlist(X)
	; or similar array reference to X
	I vINFO("TYPE")="Array" D
	.	;
	.	N isList
	.	N vCNT N vDSCPCE N vI
	.	;
	.	S vDSCPCE=1
	.	I ($get(vINFO("PIECE"))>1) S vDSCPCE=vINFO("PIECE")
	.	;
	.	I ($get(vINFO("LISTLEN"))>0) D
	..		;
	..		S isList=1
	..		S vCNT=$L(vSTR,",")
	..		Q 
	.	E  D
	..		;
	..		S isList=0
	..		S vCNT=1
	..		Q 
	.	;
	.	F vI=1:1:vCNT D  Q:(vRETURN="") 
	..		;
	..		N vDATA
	..		N V N VALUE N vSTRING
	..		;
	..		I isList S V=$piece(vSTR,",",vI)
	..		E  S V=vSTR
	..		;
	..		S vSTRING="set vDATA=$D("_vINFO("ARRAY")_")"
	..		;    #ACCEPT Date=11/29/04;PGM=RussellDS;CR=13258
	..		XECUTE vSTRING
	..		;
	..		I (vDATA'>0) S vRETURN=""
	..		E  D
	...			;
	...			S vSTRING="set VALUE=$G("_vINFO("ARRAY")_")"
	...			;     #ACCEPT Date=11/29/04;PGM=RussellDS;CR=13258
	...			XECUTE vSTRING
	...			;
	...			S $piece(vRETURN,", ",vI)=V_" "_$piece(VALUE,"|",vDSCPCE)
	...			Q 
	..		Q 
	.	Q 
	;
	; Table
	E  D
	.	;
	.	N isList
	.	N CNT N DSCCOL N I
	.	N FROM N MATCH N SELECT N WHERE
	.	;
	.	S SELECT=vINFO("SELECT")
	.	S FROM=vINFO("TABLES")
	.	S WHERE=$get(vINFO("WHERE"))
	.	;
	.	S DSCCOL=2 ; Description column
	.	S MATCH=vINFO("BTMKEY")
	.	I (($E(SELECT,1,9)="DISTINCT ")) D
	..		S MATCH=$piece($piece(SELECT," ",2),",",1)
	..		S DSCCOL=1
	..		Q 
	.	E  I (vINFO("COLCNT")=1) S DSCCOL=1
	.	;
	.	I (vSTR[",") S vINFO("LISTLEN")=1
	.	;
	.	I ($get(vINFO("LISTLEN"))>0) D
	..		;
	..		S isList=1
	..		S CNT=$L(vSTR,",")
	..		Q 
	.	E  D
	..		;
	..		S isList=0
	..		S CNT=1
	..		Q 
	.	;
	.	F I=1:1:CNT D  Q:(vRETURN="") 
	..		;
	..		N X N XWHERE
	..		;
	..		I isList S X=$piece(vSTR,",",I)
	..		E  S X=vSTR
	..		;
	..		; MODIFIED TO HANDLE EMBEDDED QUOTE CHARACTER.
	..		S X=$S(X'["'":"'"_X_"'",1:$$QADD^%ZS(X,"'"))
	..		;
	..		; ALL LITERALS QUOTED ABOVE.
	..		I (WHERE="") S XWHERE=MATCH_"="_X
	..		E  S XWHERE="("_WHERE_") AND "_MATCH_"="_X
	..		;
	..		;    #ACCEPT Date=11/29/04;PGM=RussellDS;CR=13258
	..		N rs,vos1,vos2,sqlcur,exe,sqlcur,vd,vi,vsql,vsub S rs=$$vOpen0(.exe,.vsql,SELECT,FROM,XWHERE,"","","/DQMODE=1")
	..		;
	..		I '$G(vos1) S vRETURN=""
	..		E  I $$vFetch0() D
	...			I DSCCOL=1 S $piece(vRETURN,", ",I)=$P(rs,$C(9),1)
	...			E  S $piece(vRETURN,", ",I)=$P(rs,$C(9),1)_" "_$P(rs,$C(9),2)
	...			Q 
	..		Q 
	.	Q 
	;
	Q $E(vRETURN,1,80)
	;
vSIG()	;
	Q "60579^13625^Badrinath Giridharan^4074" ; Signature - LTD^TIME^USER^SIZE
	;
vOpen0(exe,vsql,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist)	;	Dynamic MDB ResultSet
	;
	set sqlcur="DBSTBLA.rs"
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
