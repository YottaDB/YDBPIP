DBSTBLMB(%O,dbtbl1,KEY)	; C-S-UTBL Table Maintenance Compiled Program
	;
	; 11/08/2007 14:07 - chenardp
	;
	 S:'$D(vobj(dbtbl1,22)) vobj(dbtbl1,22)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),22)),1:"")
	; Last compiled:  11/08/2007 02:07 PM - chenardp
	;
	; THIS IS A COMPILED ROUTINE.  Compiled by procedure DBSTBLMA
	;
	; See DBSTBLMA for argument definitions
	;
	N ERMSG N SCREEN N TABLE
	;
	S SCREEN=$P(vobj(dbtbl1,22),$C(124),8)
	S TABLE=vobj(dbtbl1,-4)
	;
	I TABLE="STBLER" S ERMSG=$$tm1(%O,.KEY,SCREEN)
	;
	Q ERMSG
	;
tm1(ProcMode,KEY,SCREEN)	; STBLER - Error Table
	;
	N ER S ER=0
	N ERMSG N RM
	;
	S (ERMSG,VFMQ)=""
	;
	N UTBL S UTBL=$$vDb1(KEY(1))
	;
	;  #ACCEPT Date=03/04/07; Pgm=RussellDS; CR=25558; Group=MISMATCH
	N vo1 N vo2 N vo3 N vo4 D DRV^USID(ProcMode,SCREEN,.UTBL,.vo1,.vo2,.vo3,.vo4) K vobj(+$G(vo1)) K vobj(+$G(vo2)) K vobj(+$G(vo3)) K vobj(+$G(vo4))
	I 'ER,(VFMQ'="Q") D
	.	;
	.	I ProcMode<2 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(UTBL) S vobj(UTBL,-2)=1 Tcommit:vTp  
	.	I ProcMode=3  N V1 S V1=KEY(1) D vDbDe1()
	.	Q 
	;
	I ER S ERMSG=$get(RM)
	;
	K vobj(+$G(UTBL)) Q ERMSG
	;
LOWERLVL(fid,KEY)	; Check tables at lower level
	N RETURN S RETURN=0
	;
	I fid="UTBLNBD" S RETURN=$$LL1(.KEY)
	E  I fid="UTBLPRODRL" S RETURN=$$LL2(.KEY)
	E  I fid="UTBLPRODRT" S RETURN=$$LL3(.KEY)
	;
	Q RETURN
	;
LLSELECT(SELECT,FROM,WHERE)	;
	;
	;  #ACCEPT Date=09/21/04; PGM=Dan Russell; CR=unknown
	N rs,vos1,vos2,sqlcur,exe,sqlcur,vd,vi,vsql,vsub S rs=$$vOpen0(.exe,.vsql,SELECT,FROM,WHERE,"","","")
	;
	I $$vFetch0() Q 1
	;
	Q 0
	;
LL1(KEY)	; UTBLNBD
	;
	N KEY1 S KEY1=KEY(1)
	I $$LLSELECT("UTBLNBD1.NBDC","UTBLNBD1","UTBLNBD1.NBDC = :KEY1") Q 1
	;
	Q 0
	;
LL2(KEY)	; UTBLPRODRL
	;
	N KEY1 S KEY1=KEY(1)
	I $$LLSELECT("UTBLPRODRLDT.RULEID","UTBLPRODRLDT","UTBLPRODRLDT.RULEID = :KEY1") Q 1
	;
	Q 0
	;
LL3(KEY)	; UTBLPRODRT
	;
	N KEY1 S KEY1=KEY(1)
	N KEY2 S KEY2=KEY(2)
	I $$LLSELECT("UTBLPRODRTDT.COLNAME,UTBLPRODRTDT.RESULTSID","UTBLPRODRTDT","UTBLPRODRTDT.COLNAME = :KEY1 AND UTBLPRODRTDT.RESULTSID = :KEY2") Q 1
	;
	Q 0
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM STBLER WHERE KEY = :V1
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1
	Tstart (vobj):transactionid="CS"
	N vRec S vRec=$$vDbNew1("")
	S vobj(vRec,-2)=3
	N vRs,vos1,vos2 S vRs=$$vOpen1()
	F  Q:'($$vFetch1())  D
	.	S v1=vRs
	. S vobj(vRec,-3)=v1
	.	;     #ACCEPT CR=21101;DATE=2006-05-11;PGM=FSCW;GROUP=DEPRECATED
	.	D ^DBSLOGIT($G(vRec),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^STBL("ER",v1)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	K vobj(+$G(vRec)) Q 
	;
vDb1(v1)	;	vobj()=Db.getRecord(STBLER,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSTBLER"
	S vobj(vOid)=$G(^STBL("ER",v1))
	I vobj(vOid)="",'$D(^STBL("ER",v1))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	Q vOid
	;
vDbNew1(v1)	;	vobj()=Class.new(STBLER)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSTBLER",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	Q vOid
	;
vOpen0(exe,vsql,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist)	;	Dynamic MDB ResultSet
	;
	set sqlcur="LLSELECT.rs"
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
vOpen1()	;	KEY FROM STBLER WHERE KEY = :V1
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(V1) I vos2="" G vL1a0
	I '($D(^STBL("ER",vos2))#2) G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	;
	I vos1=0 Q 0
	;
	S vos1=100
	S vRs=vos2
	S vos1=0
	;
	Q 1
	;
vReSav1(UTBL)	;	RecordSTBLER saveNoFiler(LOG)
	;
	D ^DBSLOGIT(UTBL,vobj(UTBL,-2))
	S ^STBL("ER",vobj(UTBL,-3))=$$RTBAR^%ZFUNC($G(vobj(UTBL)))
	Q
