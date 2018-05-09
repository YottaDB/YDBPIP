DBSDBASE	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSDBASE ****
	;
	; 11/08/2007 14:07 - chenardp
	;
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
VOBJ(recobj,del)	;
	;
	N isBM
	N bindnum N corder N obj N plusind N position N procmode N vER
	N bmcol N col N inscols N insvals N node N rdbtbl
	N sql N type N value N vlist N vRM N WHERE N X
	;
	; Remove this when we eventually can deal with the proper passing
	; of an object and use of the object pointer
	;  #ACCEPT Date=09/01/2006; Pgm=RussellDSR; CR=22719; Group=DEPRECATED
	S obj=$G(recobj)
	;
	S isBM=0
	S value=""
	S bindnum=1
	S procmode=vobj(obj,-2)
	;
	; No -151 node if no keys, e.g., CUVAR, or if in insert mode
	S WHERE=$get(vobj(obj,-151))
	;
	I (procmode=0) S corder=1
	E  S corder=-1
	;
	S (col,node)=""
	F  S node=$order(vobj(obj,-150,node),corder) Q:(node="")  D
	.	;
	.	S (inscols,insvals,sql,vlist)=""
	.	;
	.	; Is this a blob/memo node?
	.	I (node[",") S isBM=1
	.	E  S isBM=0
	.	;
	.	F  S col=$order(vobj(obj,-150,node,col)) Q:(col="")  D
	..		;
	..		; X = position | plusind | rdbtbl
	..		S X=vobj(obj,-150,node,col)
	..		;
	..		S position=$piece(X,"|",1)
	..		S plusind=$piece(X,"|",2)
	..		S rdbtbl=$piece(X,"|",3)
	..		;
	..		I position<0 S value=vobj(obj,position) ; Key
	..		E  I (node="0*") S value=$piece(vobj(obj),del,position)
	..		E  I 'isBM S value=$piece(vobj(obj,node),del,position)
	..		E  S value=vobj(obj,position,1)
	..		;
	..		I (plusind=2) S value=+value
	..		E  I (plusind=1),'(value="") S value=+value
	..		;
	..		; Blob/memo - NOTE: only 1 blob/memo per node
	..		I isBM S bmcol=col
	..		;
	..		; Update mode - non-blob/memo
	..		E  I (procmode>0) D
	...			;
	...			S sql=sql_","_col_"=:VB"_bindnum
	...			S bindnum=bindnum+1
	...			S vlist=vlist_value_del
	...			Q 
	..		; Insert mode
	..		E  D
	...			;
	...			S inscols=inscols_","_col
	...			S insvals=insvals_",:VB"_bindnum
	...			S bindnum=bindnum+1
	...			S vlist=vlist_value_del
	...			Q 
	..		Q 
	.	;
	.	; Do the update
	.	I isBM D
	..		;
	..		N BMWHERE S BMWHERE=WHERE
	..		;
	..		; Strip leading WHERE from where clause
	..		I ($E(BMWHERE,1,7)=" WHERE ") S BMWHERE=$E(BMWHERE,8,1048575)
	..		;
	..		; On insert, won't have a where clause, so need to build it.  Don't do this
	..		; earlier, since most of the time we don't need it
	..		I (BMWHERE="") D
	...			;
	...			N col N node
	...			;
	...			S node=""
	...			F  S node=$order(vobj(obj,-150,node)) Q:(node="")  D
	....				;
	....				S col=""
	....				F  S col=$order(vobj(obj,-150,node,col)) Q:(col="")  D
	.....					;
	.....					S X=vobj(obj,-150,node,col)
	.....					;
	.....					S position=$piece(X,"|",1)
	.....					;
	.....					; If it's a key
	.....					I (position<0) S BMWHERE=BMWHERE_col_"='"_vobj(obj,position)_"' AND "
	.....					Q 
	....				Q 
	...			;
	...			S BMWHERE=$E(BMWHERE,1,$L(BMWHERE)-5)
	...			Q 
	..		;
	..		S vER=$$LOBUPDT^%DBAPI(0,rdbtbl,bmcol,BMWHERE,value,del,vlist,.vRM)
	..		Q 
	.	E  D
	..		;
	..		I (procmode>0) S sql="UPDATE "_rdbtbl_" SET "_$E(sql,2,1048575)_" "_WHERE
	..		E  S sql="INSERT INTO "_rdbtbl_" ("_$E(inscols,2,1048575)_") VALUES ("_$E(insvals,2,1048575)_")"
	..		;
	..		S vER=$$EXECUTE^%DBAPI(0,sql,del,vlist,.vRM)
	..		Q 
	.	;
	.	I (vER<0) S $ZS="-1,"_$ZPOS_","_"%PSL-E-RDBSAVEFAIL,"_$translate($get(vRM),$C(10,44)," ~") X $ZT
	.	Q 
	;
	K vobj(obj,-150)
	;
	Q 
	;
BIND(expr,array)	;
	;
	 ; Data types
	;
	N I
	N code N var
	;
	Q:'(expr[":")  ; No variables to bind
	;
	S code="S vList="
	;
	F I=2:1:$L(expr,":") D
	.	;
	.	S var=$piece($piece(expr,":",I)," ",1)
	.	;
	.	I '(var="") D
	..		;
	..		I '($get(var1(I-1))=""),("N$L"[var1(I-1)) S code=code_"+"_var_"_$C(9)_"
	..		E  S code=code_"""'""_"_var_"_""'""_$C(9)_"
	..		Q 
	.	Q 
	;
	S code=$E(code,1,$L(code)-7) ; Strip trailing _$C(9)_
	;
	S array=$get(array)+1
	S array(array)=code
	;
	Q 
	;
RUNSP(expr,colnam,tabnam,cnd,hostval,RM)	;
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
CREATESP(RTBL,METHOD,INPUT,REGEN)	;
	;
	N ER
	N seq
	N N N procdata N RM N spname
	;
	; Protect from incorrect scoping in %DBAPI - remove once %DBAPI fixed
	N del S del=""
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
	.	N rs,vos1,vos2,vos3,vos4,vos5,vos6,vos7  N V1 S V1=procdata S rs=$$vOpen1()
	.	;
	.	I $$vFetch1() S spname=rs
	.	Q 
	;
	Q:'(spname="") spname
	;
	I (METHOD="SelectAll") D
	.	;
	.	S spname="T_"_RTBL_"$SEL_ALL"
	.	S seq=0 ; Only one of these
	.	;
	.	S ER=$$EXECCP^%DBAPI(0,spname,"*",RTBL,INPUT("WHERE"),INPUT("HOSTVARS"),.RM)
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
	.	N dbspid S dbspid=$$vDb1(RTBL,METHOD,seq)
	.	 S vobj(dbspid,1,1)="" N von S von="" F  S von=$O(^DBSPID(vobj(dbspid,-3),vobj(dbspid,-4),vobj(dbspid,-5),von)) quit:von=""  S vobj(dbspid,1,1)=vobj(dbspid,1,1)_^DBSPID(vobj(dbspid,-3),vobj(dbspid,-4),vobj(dbspid,-5),von)
	.	;
	.	; Note that this may replace an existing, different procedure name.
	.	; This will only occur if we change our naming conventions.
	. S $P(vobj(dbspid),$C(124),1)=spname
	. S vobj(dbspid,1,1)=procdata
	. S $P(vobj(dbspid),$C(124),2)=$P($H,",",1)
	. S $P(vobj(dbspid),$C(124),3)=$P($H,",",2)
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(dbspid) S vobj(dbspid,-2)=1 Tcommit:vTp  
	.	K vobj(+$G(dbspid)) Q 
	;
	I ER S $ZS="-1,"_$ZPOS_","_"%DQ-E-CREATESP,"_$translate($get(RM),",","~") X $ZT
	;
	Q spname
	;
REGENSP(RTBL,PROCLIST)	;
	;
	N REGENER
	N CRLF
	;
	S REGENER=0
	S CRLF=$char(13)_$char(10)
	;
	N ds,vos1,vos2,vos3,vos4 S ds=$$vOpen2()
	;
	F  Q:'($$vFetch2())  D
	.	;
	.	N I
	.	N input N procdata N spname N X
	.	;
	.	N dbspid,vop1,vop2,vop3,vop4 S vop1=$P(ds,$C(9),1),vop2=$P(ds,$C(9),2),vop3=$P(ds,$C(9),3),dbspid=$G(^DBSPID(vop1,vop2,vop3))
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
	.	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	.	;
	.	S spname=$$CREATESP(RTBL,vop2,.input,1)
	.	;
	.	S PROCLIST(spname,vop2)=""
	.	Q 
	;
	Q REGENER
	;
wide(dqtable)	; DATA-QWIK table name
	N vret
	;
	N dbmapt S dbmapt=$G(^DBMAP("TABLES",%DB,dqtable))
	;
	S vret=+$P(dbmapt,$C(9),2) Q vret
	;
LIST(table)	; returns ordered list of columns for a specified table.
	;
	N list S list=""
	N col
	N rs,vos1,vos2,vos3,vos4,vos5,vos6,vOid  N V1 S V1=table S rs=$$vOpen3()
	F  Q:'($$vFetch3())  D
	.	S col=$P(rs,$C(9),1)
	.	Q:$$isLit^UCGM(col) 
	.	S list=list_","_$P(rs,$C(9),1)
	.	Q 
	S list=$E(list,2,9999)
	Q list
	;
BUILD	; Build Stored procedures for all tables in the DB
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
	N ds,vos1,vos2,vos3  N V2 S V2=$J S ds=$$vOpen4()
	F  Q:'($$vFetch4())  D
	.	N tmpdq,vop1 S vop1=$P(ds,$C(9),2),tmpdq=$G(^TEMP($P(ds,$C(9),1),vop1))
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
	.	Q 
	;
	 N V3 S V3=$J D vDbDe2()
	;
	; Press any key message and pause
	WRITE $$MSG^%TRMVT("",,1)
	;
	Q 
	;
vSIG()	;
	Q "60880^40045^Dan Russell^16018" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM TMPDQ WHERE PID=:V1
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen5()
	F  Q:'($$vFetch5())  D
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
vDbDe2()	; DELETE FROM TMPDQ WHERE PID=:V3
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
	;
vDb1(v1,v2,v3)	;	vobj()=Db.getRecord(DBSPID,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBSPID"
	S vobj(vOid)=$G(^DBSPID(v1,v2,v3))
	I vobj(vOid)="",'$D(^DBSPID(v1,v2,v3))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vOpen1()	;	SPNAME FROM DBSPID WHERE RTBL=:RTBL AND METHOD=:METHOD AND PROCDATA=:V1
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(RTBL) I vos2="" G vL1a0
	S vos3=$G(METHOD) I vos3="" G vL1a0
	S vos4=$G(V1) I vos4="",'$D(V1) G vL1a0
	S vos5=""
vL1a5	S vos5=$O(^DBSPID(vos2,vos3,vos5),1) I vos5="" G vL1a0
	S vos6=$$READ^DBSMEMO("^DBSPID("_$c(34)_vos2_$c(34)_","_$c(34)_vos3_$c(34)_","_vos5_")")
	I '(vos6=vos4) G vL1a5
	Q
	;
vFetch1()	;
	;
	I vos1=1 D vL1a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos7=$G(^DBSPID(vos2,vos3,vos5))
	S rs=$P(vos7,"|",1)
	;
	Q 1
	;
vOpen2()	;	RTBL,METHOD,SEQ FROM DBSPID WHERE RTBL=:RTBL
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(RTBL) I vos2="" G vL2a0
	S vos3=""
vL2a3	S vos3=$O(^DBSPID(vos2,vos3),1) I vos3="" G vL2a0
	S vos4=""
vL2a5	S vos4=$O(^DBSPID(vos2,vos3,vos4),1) I vos4="" G vL2a3
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
	S ds=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen3()	;	COL,POS FROM DBMAP WHERE TBL=:V1 ORDER BY POS ASC
	;
	S vOid=$G(^DBTMP($J))-1,^($J)=vOid K ^DBTMP($J,vOid)
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(V1) I vos2="" G vL3a0
	S vos3=""
vL3a3	S vos3=$O(^DBMAP("COLUMNS",vos3),1) I vos3="" G vL3a10
	S vos4=""
vL3a5	S vos4=$O(^DBMAP("COLUMNS",vos3,vos2,vos4),1) I vos4="" G vL3a3
	S vos5=$G(^DBMAP("COLUMNS",vos3,vos2,vos4))
	S vd=$S(vos4=$C(254):"",1:vos4)_$C(9)_$P(vos5,$C(9),3)
	S vos6=$P(vos5,$C(9),3) S:vos6="" vos6=$$BYTECHAR^SQLUTL(254) S ^DBTMP($J,vOid,1,vos6,vos3,vos4)=vd
	G vL3a5
vL3a10	S vos2=""
vL3a11	S vos2=$O(^DBTMP($J,vOid,1,vos2),1) I vos2="" G vL3a0
	S vos3=""
vL3a13	S vos3=$O(^DBTMP($J,vOid,1,vos2,vos3),1) I vos3="" G vL3a11
	S vos4=""
vL3a15	S vos4=$O(^DBTMP($J,vOid,1,vos2,vos3,vos4),1) I vos4="" G vL3a13
	Q
	;
vFetch3()	;
	;
	;
	I vos1=1 D vL3a15
	I vos1=2 S vos1=1
	;
	I vos1=0 K ^DBTMP($J,vOid) Q 0
	;
	S rs=^DBTMP($J,vOid,1,vos2,vos3,vos4)
	;
	Q 1
	;
vOpen4()	;	PID,ELEMENT FROM TMPDQ WHERE PID=:V2 ORDER BY ELEMENT ASC
	;
	;
	S vos1=2
	D vL4a1
	Q ""
	;
vL4a0	S vos1=0 Q
vL4a1	S vos2=$G(V2) I vos2="" G vL4a0
	S vos3=""
vL4a3	S vos3=$O(^TEMP(vos2,vos3),1) I vos3="" G vL4a0
	Q
	;
vFetch4()	;
	;
	;
	I vos1=1 D vL4a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen5()	;	PID,ELEMENT FROM TMPDQ WHERE PID=:V1
	;
	;
	S vos1=2
	D vL5a1
	Q ""
	;
vL5a0	S vos1=0 Q
vL5a1	S vos2=$G(V1) I vos2="" G vL5a0
	S vos3=""
vL5a3	S vos3=$O(^TEMP(vos2,vos3),1) I vos3="" G vL5a0
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
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen6()	;	PID,ELEMENT FROM TMPDQ WHERE PID=:V3
	;
	;
	S vos1=2
	D vL6a1
	Q ""
	;
vL6a0	S vos1=0 Q
vL6a1	S vos2=$G(V3) I vos2="" G vL6a0
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
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vReSav1(dbspid)	;	RecordDBSPID saveNoFiler()
	;
	S ^DBSPID(vobj(dbspid,-3),vobj(dbspid,-4),vobj(dbspid,-5))=$$RTBAR^%ZFUNC($G(vobj(dbspid)))
	N vC,vS s vS=0
	F vC=1:450:$L($G(vobj(dbspid,1,1))) S vS=vS+1,^DBSPID(vobj(dbspid,-3),vobj(dbspid,-4),vobj(dbspid,-5),vS)=$E(vobj(dbspid,1,1),vC,vC+449)
	Q
	;
vtrap1	;	Error trap
	;
	N regenerr S regenerr=$ZS
	;
	S REGENER=REGENER+1
	S PROCLIST($P(dbspid,$C(124),1),vop2)=$P(regenerr,",",4)
	Q 
