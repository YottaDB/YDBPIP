 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCXCUVAR ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
 ;  #PACKAGE framework.psl.upgrade
 ;  #OPTION  ResultClass ON
 ;
UCXCUVAR(COL) ; Return Institution Variable Run-time Value
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
 N rs,exe,sqlcur,vd,vi,vsql,vsub S rs=$$vOpen1(COL,1)
 ;
 ; call rs.next() twice to ensure ResultSet will be closed by API
 N val
 N ignore
 I $$vFetch1(rs) S val=$P(vobj(rs),$C(9),1) S ignore=$$vFetch1(rs) K vobj(+$G(rs)) Q val
 K vobj(+$G(rs)) Q ""
 ;
 ; ---------------------------------------------------------------------
tbl2dat(dir) ; create CUVAR.DAT based on current values
 ;
 N hdr S hdr=""
 N dat S dat=""
 N col
 ;
 N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen2()
 F  Q:'$$vFetch2()  S col=rs S hdr=hdr_$C(9)_col S dat=dat_$C(9)_$$UCXCUVAR(col)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 I ($get(dir)="") S dir=$$SCAU^%TRNLNM("DIR")
 ;
 N io S io=$$vClVobj($ST,"IO")
 S $P(vobj(io,1),"|",2)=dir
 S $P(vobj(io,1),"|",1)="CUVAR.DAT"
 S $P(vobj(io,1),"|",3)="NEWV"
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 D write^UCIO(io,$E(hdr,2,1048575))
 D write^UCIO(io,$E(dat,2,1048575))
 D close^UCIO(io)
 K vobj(+$G(io)) Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61058^29766^Frans S.C. Witte^5746" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vOpen1(vSelect,vOff) ; PSLBOOT result set for CUVAR
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;  #ACCEPT GROUP=BYPASS;CR=27800;PGM=Frans S.C. Witte;Date=2008-03-11
 ;*** Start of code by-passed by compiler
 IF '$DATA(pslPrsr("boot","CUVAR")) QUIT $$vOpen0(.exe,.vsql,vSelect,"CUVAR","","","","/PSLBOOT",vOff+1)
 ;*** End of code by-passed by compiler ***
 N vRws S vRws=pslPrsr("boot","CUVAR")
 N vOid S vOid=$O(vobj(""),-1)+1
 S vobj(vOid,-1)="ResultSet"
 S vobj(vOid,-5)=2
 S vobj(vOid,-2)="$$vFetch1^"_$T(+0)
 S vobj(vOid,-3)=vSelect
 S vobj(vOid,-4)=""
 S vobj(vOid,0)=1
 S vobj(vRws,0)=0 
 ;  #ACCEPT GROUP=BYPASS;CR=27800;PGM=Frans S.C. Witte;Date=2008-03-11
 ;*** Start of code by-passed by compiler
 IF $$vFetch1(vOid) SET vobj(vOid,0)=2
 ;*** End of code by-passed by compiler ***
 Q vOid
 ; ----------------
 ;  #OPTION ResultClass 1
vFetch1(vOid) ; PSLBOOT fetch for CUVAR
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;  #ACCEPT GROUP=BYPASS;CR=27800;PGM=Frans S.C. Witte;Date=2008-03-11
 ;*** Start of code by-passed by compiler
 IF '$DATA(pslPrsr("boot","CUVAR")) QUIT $$vFetch0(vOid)
 ;*** End of code by-passed by compiler ***
 I vobj(vOid,0)=2 S vobj(vOid,0)=1 Q 1
 N vRws S vRws=pslPrsr("boot","CUVAR")
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
vOpen2() ; DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID='CUVAR' AND DI<>'*' AND CMP IS NULL
 ;
 ;
 S vos1=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos1=0 Q
vL2a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL2a3 S vos3=$O(^DBTBL("SYSDEV",1,"CUVAR",9,vos3),1) I vos3="" G vL2a0
 I '(vos3'="""*""") G vL2a3
 S vos4=$G(^DBTBL("SYSDEV",1,"CUVAR",9,vos3))
 I '($P(vos4,"|",16)="") G vL2a3
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos1=1 D vL2a3
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos4=$G(^DBTBL("SYSDEV",1,"CUVAR",9,vos3))
 S rs=$S(vos3=vos2:"",1:vos3)
 ;
 Q 1
 ;
vRwsNxt(vOid) ; RowSet.next
 ;
 N vLst S vLst=$O(vobj(vOid,""),-1)
 I vobj(vOid,0)'>vLst S vobj(vOid,0)=vobj(vOid,0)+1
 Q vobj(vOid,0)'>vLst
 ;
vCatch1 ; Error trap
 ;
 N xIo,$ET,$ES S xIo=$ZE,$EC="",$ET="Q",$ZE=""
 I '($P($P(xIo,",",3),"-",3)["OPEN") D close^UCIO(io)
 I '($E($P($P(xIo,",",3),"-",3),1,2)="IO") S $ZE=xIo,$EC=",U1001,"
 D ZX^UCGMR(voxMrk) Q 
