UCXCUVAR(COL)	; Institution Variable Run-time Value
	;
	; **** Routine compiled from DATA-QWIK Procedure UCXCUVAR ****
	;
	; 09/10/2007 17:31 - chenardp
	;
	N vret
	; I18N=QUIT
	; *******************************************************************
	; * IMPORTANT NOTE:                                                 *
	; * According to the rules that apply to PSL compiler upgrades,     *
	; * the generated M routine associated with this procedure must be  *
	; * checked into StarTeam and released with the procedure whenever  *
	; * changes are made to this procedure.                             *
	; *                                                                 *
	; * The M routine will be loaded to the mrtns directory during      *
	; * upgrades and will then be removed from that directory as part   *
	; * of the upgrade process.  Therefore, other than during an        *
	; * upgrade an mrtns version of this routine should not exist.      *
	; *                                                                 *
	; * Keep these comments as single line to ensure they exist in the  *
	; * generated M code.                                               *
	; *******************************************************************
	;
	I COL="%LIBS" Q "SYSDEV" ; Library Name
	;
	;  #ACCEPT CR=18247;DATE=2005-11-14;PGM=FSCW;REASON=Dynamic Select
	N rs,exe,sqlcur,vd,vi,vsql,vsub S rs=$$vOpen1(COL)
	;
	I $$vFetch1(rs) S vret=$P(vobj(rs),$C(9),1) K vobj(+$G(rs)) Q vret
	K vobj(+$G(rs)) Q ""
	;
	; ---------------------------------------------------------------------
tbl2dat(dir)	; create CUVAR.DAT based on current values
	;
	N hdr S hdr=""
	N dat S dat=""
	N col
	;
	N rs,vos1,vos2,vos3 S rs=$$vOpen2()
	F  Q:'($$vFetch2())  S col=rs S hdr=hdr_$C(9)_col S dat=dat_$C(9)_$$UCXCUVAR(col)
	;
	I ($get(dir)="") S dir=$$SCAU^%TRNLNM("DIR")
	;
	N IO S IO=$$FILE^%TRNLNM("CUVAR.DAT",dir)
	I $$FILE^%ZOPEN(IO,"NEWVERSION",0,32767) D
	.	USE IO
	.	WRITE $E(hdr,2,1048575),!
	.	WRITE $E(dat,2,1048575),!
	.	CLOSE IO
	.	Q 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vOpen1(vSelect)	; PSLBOOT result set for CUVAR
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I '($D(commands("boot","CUVAR"))#2) Q $$vOpen0(.exe,.vsql,vSelect,"CUVAR","","","","/PSLBOOT")
	N vRws S vRws=commands("boot","CUVAR")
	N vOid S vOid=$O(vobj(""),-1)+1
	S vobj(vOid,-1)="ResultSet"
	S vobj(vOid,-5)=2
	S vobj(vOid,-2)="$$vFetch1^"_$T(+0)
	S vobj(vOid,-3)=vSelect
	S vobj(vOid,-4)=""
	S vobj(vOid,0)=1
	S vobj(vRws,0)=0 
	I $$vFetch1(vOid) S vobj(vOid,0)=2
	Q vOid
	; ----------------
	;  #OPTION ResultClass 0
vFetch1(vOid)	; PSLBOOT fetch for CUVAR
	N vret
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I '($D(commands("boot","CUVAR"))#2) Q $$vFetch0(vOid)
	N vRws S vRws=commands("boot","CUVAR")
	I vobj(vOid,0)=2 S vobj(vOid,0)=1 Q 1
	N vR
	S vobj(vOid,0)=$$vRwsNxt(vRws)
	S vR=$S(vobj(vRws,0)>0:$G(vobj(vRws,vobj(vRws,0))),1:"")
	N vS S vS=vR
	N vD S vD=vobj(vRws,-3)
	N vH S vH=vobj(vRws,-2)
	N vL S vL="" N vP1 N vP2 N vC
	F vP1=1:1:$L(COL,",") S vC=$piece(COL,",",vP1) S vP2=$L($piece((","_vH_","),","_vC_",",1),",") S vL=vL_$char(9)_$piece(vS,vD,vP2)
	S vobj(vOid)=$E(vL,2,1048575)
	S vret=vobj(vOid,0) Q vret
	;
vOpen0(exe,vsql,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist)	;	Dynamic MDB ResultSet
	;
	N vOid
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
	S vOid=sqlcur
	S vobj(vOid,0)=vsql
	S vobj(vOid,-1)="ResultSet"
	S vobj(vOid,-2)="$$vFetch0^"_$T(+0)
	S vobj(vOid,-3)=$$RsSelList^UCDBRT(vSelect)
	S vobj(vOid,-4)=$G(vsql("D"))
	S vobj(vOid,-5)=0
	Q vOid
	;
vFetch0(vOid)	; MDB dynamic FETCH
	;
	; type public String exe(),sqlcur,vd,vi,vsql()
	;
	I vsql=0 Q 0
	S vsql=$$^SQLF(.exe,.vd,.vi,.sqlcur)
	S vobj(vOid)=vd
	S vobj(vOid,0)=vsql
	S vobj(vOid,.1)=$G(vi)
	Q vsql
	;
vOpen2()	;	DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID='CUVAR' AND DI<>'*' AND CMP IS NULL
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=""
vL2a2	S vos2=$O(^DBTBL("SYSDEV",1,"CUVAR",9,vos2),1) I vos2="" G vL2a0
	I '(vos2'="""*""") G vL2a2
	S vos3=$G(^DBTBL("SYSDEV",1,"CUVAR",9,vos2))
	I '($P(vos3,"|",16)="") G vL2a2
	Q
	;
vFetch2()	;
	;
	;
	I vos1=1 D vL2a2
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos2=$$BYTECHAR^SQLUTL(254):"",1:vos2)
	;
	Q 1
	;
vRwsNxt(vOid)	;	RowSet.next
	;
	N vLst S vLst=$O(vobj(vOid,""),-1)
	I vobj(vOid,0)'>vLst S vobj(vOid,0)=vobj(vOid,0)+1
	Q vobj(vOid,0)'>vLst
