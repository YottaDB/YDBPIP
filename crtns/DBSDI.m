 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSDI ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSDI ; 
 ;
 ; **********************************************************************
 ; * IMPORTANT NOTE:                                                    *
 ; * According to the rules that apply to PSL compiler upgrades,        *
 ; * the generated M routine associated with this procedure must be     *
 ; * checked into StarTeam and released with the procedure whenever     *
 ; * changes are made to this procedure.                                *
 ; *                                                                    *
 ; * The mrtns version will be used during upgrades and will then be    *
 ; * removed from the mrtns directory.  Therefore, other than in a      *
 ; * development environment, or during an upgrade, an mrtns version of *
 ; * this routine should not exist.                                     *
 ; *                                                                    *
 ; * Keep these comments as single line to ensure they exist in the     *
 ; * generated M code.                                                  *
 ; **********************************************************************
 ;
 S (DLIB,LIB)="SYSDEV"
 I '($D(DFID)#2) S DFID=""
 I '($D(FILES)#2) S FILES=""
 ;
 S ER=0
 ;
 S DI=X
 S DINAM=""
 S FID=DFID
 ;
 I ($E(DI,1)="["),(DI["]") D
 .	;
 .	S FID=$piece($piece(DI,"]",1),"[",2)
 .	S DI=$piece(DI,"]",2)
 .	Q 
 ;
 I (FID[".") S FID=$piece(FID,".",2)
 I (FID[",") S FID=$piece(FID,",",2)
 I (FID="") S FID=DFID
 ;
 S FID=$ZCONVERT(FID,"U")
 S DI=$ZCONVERT(DI,"U")
 ;
 Q:(FID="") 
 Q:(FID["?") 
 Q:(FID["!") 
 ;
 N tableinfo
 ;
 S ER=$$getTableInfo(FID,.tableinfo)
 ;
 I ER D  Q 
 .	;
 .	; Invalid file name - ~p1
 .	S RM=$$^MSG(1337,FID)
 .	S (LIB,FID,DI)=""
 .	Q 
 ;
 I '(FILES=""),'((","_FILES_",")[(","_FID_",")) D  Q 
 .	;
 .	S ER=1
 .	; Invalid file linkage - ~p1
 .	S RM=$$^MSG(1335,FILES)
 .	S (LIB,FID,DI)=""
 .	Q 
 ;
 S DFID=FID
 ;
 Q:((DI="")!(DI["?")!(DI["!")) 
 ;
 N colinfo
 ;
 S ER=$$getColInfo(FID,DI,.colinfo)
 ;
 I ER D  Q 
 .	;
 .	; Invalid data item - ~p1
 .	S RM=$$^MSG(1298,DI)
 .	S (LIB,FID,DI)=""
 .	Q 
 ;
 S DI(1)=$P(colinfo,"|",3)
 S DI(2)=$P(colinfo,"|",7)
 S DI(3)=$P(colinfo,"|",19)
 S DI(4)=$P(colinfo,"|",20)
 S DI(5)=$P(colinfo,"|",21)
 S DI(6)=$P(colinfo,"|",22)
 S DI(7)=$P(colinfo,"|",23)
 S DI(8)=$P(colinfo,"|",24)
 S DI(9)=$P(colinfo,"|",6)
 S DI(10)=$P(colinfo,"|",25)
 S DI(11)=$P(colinfo,"|",26)
 S DI(12)=$P(colinfo,"|",27)
 S DI(13)=$P(colinfo,"|",28)
 S DI(14)=$P(colinfo,"|",8)
 S DI(15)=$P(colinfo,"|",29)
 S DI(16)=$P(colinfo,"|",14)
 S DI(17)=($P(colinfo,"|",15)>0)
 S DI(18)=$P(colinfo,"|",10)_"~"_$P(colinfo,"|",11)_"~"_$P(colinfo,"|",12)_"~"_$P(colinfo,"|",13)
 I ($translate(DI(18),"~","")="") S DI(18)=""
 S DI(19)=$P(colinfo,"|",30)
 S DI(20)=$P(tableinfo,"|",10)
 S DI(21)=$P(colinfo,"|",4)
 S DI(22)=$P(colinfo,"|",31)
 S DI(23)=$P(colinfo,"|",32)
 ;
 S DINAM="["_DLIB_","_DFID_"]"_DI
 S DILNM=DI(10)
 ;
 Q 
 ;
LIB(file,libr) ; Library  /NOREQ
 ;
 N ER
 N return
 ;
 I ($get(libr)="") S libr="SYSDEV"
 ;
 S return=""
 ;
 N tableinfo
 ;
 S ER=$$getTableInfo(file,.tableinfo)
 ;
 I 'ER S return=libr_","_file
 ;
 Q return
 ;
STBLER(KEY) ; STBLER.KEY
 N vret
 ;
 N stbler S stbler=$G(^STBL("ER",KEY))
 ;
 S vret=$P(stbler,$C(124),1)_"|||||"_$P(stbler,$C(124),6) Q vret
 ;
STBLXBAD(KEY) ; STBLXBAD.KEY
 N vret
 ;
 N stblxbad S stblxbad=$G(^STBL("XBAD",KEY))
 ;
 S vret=$P(stblxbad,$C(124),1)_"|||"_$P(stblxbad,$C(124),4) Q vret
 ;
STBLSKWD(KEYWORDS) ; Keyword list  /MECH=REFARR:W
 ;
 ;  #ACCEPT Date=10/10/2006; Pgm=RussellDS; CR=22519; Group=PSLBOOT
 N rs S rs=$$vOpen2()
 ;
 F  Q:'$$vFetch2(rs)  S KEYWORDS($P(vobj(rs),$C(9),1))=$P(vobj(rs),$C(9),2)
 ;
 K vobj(+$G(rs)) Q 
 ;
XBAD(TDATE,TABLE,AKEYS,ET,data) ; XBAD data
 N vTp
 ;
 N xbad S xbad=$$vRCgetRecord1^RecordXBAD(TDATE,TABLE,AKEYS,ET,0)
 ;
  S $P(vobj(xbad),$C(124),1)=$piece(data,"|",1)
  S $P(vobj(xbad),$C(124),2)=$piece(data,"|",2)
  S $P(vobj(xbad),$C(124),3)=$piece(data,"|",3)
  S $P(vobj(xbad),$C(124),4)=$piece(data,"|",4)
  S $P(vobj(xbad),$C(124),5)=$piece(data,"|",5)
 ;
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordXBAD(xbad,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(xbad,-100) S vobj(xbad,-2)=1 TC:vTp  
 ;
 K vobj(+$G(xbad)) Q 
 ;
getTableInfo(table,tableInfo) ; PSL Table record
 ;
 N return S return=0
 ;
 D
 .	;
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 .	;
 .	S tableInfo=$$getPslTbl^UCXDD(table,0)
 .	Q 
 ;
 Q return
 ;
getColInfo(table,column,colInfo) ; Schema column record
 ;
 N return S return=0
 ;
 D
 .	;
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch2^"_$T(+0)
 .	;
 .	S colInfo=$$getSchCln^UCXDD(table,column)
 .	Q 
 ;
 Q return
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61254^68579^Dan Russell^7147" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vOpen2() ; PSLBOOT result set for STBLSYSKEYWD
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;  #ACCEPT GROUP=BYPASS;CR=27800;PGM=Frans S.C. Witte;Date=2008-03-11
 ;*** Start of code by-passed by compiler
 IF '$DATA(pslPrsr("boot","STBLSYSKEYWD")) QUIT $$vOpen1()
 ;*** End of code by-passed by compiler ***
 N vRws S vRws=pslPrsr("boot","STBLSYSKEYWD")
 N vOid S vOid=$O(vobj(""),-1)+1
 S vobj(vOid,-1)="ResultSet"
 S vobj(vOid,-5)=2
 S vobj(vOid,-2)="$$vFetch2^"_$T(+0)
 S vobj(vOid,-3)="KEYWORD,DES"
 S vobj(vOid,-4)="T0T0"
 S vobj(vOid,0)=1
 S vobj(vRws,0)=0 
 ;  #ACCEPT GROUP=BYPASS;CR=27800;PGM=Frans S.C. Witte;Date=2008-03-11
 ;*** Start of code by-passed by compiler
 IF $$vFetch2(vOid) SET vobj(vOid,0)=2
 ;*** End of code by-passed by compiler ***
 Q vOid
 ; ----------------
 ;  #OPTION ResultClass 1
vFetch2(vOid) ; PSLBOOT fetch for STBLSYSKEYWD
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;  #ACCEPT GROUP=BYPASS;CR=27800;PGM=Frans S.C. Witte;Date=2008-03-11
 ;*** Start of code by-passed by compiler
 IF '$DATA(pslPrsr("boot","STBLSYSKEYWD")) QUIT $$vFetch1(vOid)
 ;*** End of code by-passed by compiler ***
 I vobj(vOid,0)=2 S vobj(vOid,0)=1 Q 1
 N vRws S vRws=pslPrsr("boot","STBLSYSKEYWD")
 N vR
 S vobj(vOid,0)=$$vRwsNxt(vRws)
 S vR=$S(vobj(vRws,0)>0:$G(vobj(vRws,vobj(vRws,0))),1:"")
 S vobj(vOid)=$P(vR,vobj(vRws,-3),$$vRwGC(vobj(vRws,-2),"KEYWORD"))_$char(9)_$P(vR,vobj(vRws,-3),$$vRwGC(vobj(vRws,-2),"DES"))
 S vret=vobj(vOid,0) Q vret
 ; ----------------
 ;  #OPTION ResultClass 1
vRwGC(vList,vRef) ; Dynamic column position lookup
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;
 I (vRef="") Q ""
 I +vRef>0 Q vRef
 ;
 S vList=$ZCONVERT(vList,"U") S vRef=$ZCONVERT(vRef,"U")
 N vP S vP=$F((vList_",")," "_vRef_",")
 I vP=0 S vP=$F((","_vList_","),","_vRef_",") I vP=0 Q ""
 Q $L($E(vList,1,vP-$L(vRef)),",")
 ;
vOpen1() ; KEYWORD,DES FROM STBLSYSKEYWD
 ;
 N vOid
 ;
 S vOid=$O(vobj(""),-1)+1
 S vobj(vOid,0)=2
 S vobj(vOid,-1)="ResultSet"
 S vobj(vOid,-2)="$$vFetch1^"_$T(+0)
 S vobj(vOid,-3)="KEYWORD,DES"
 S vobj(vOid,-4)="T0T0"
 D vL1a1
 Q vOid
 ;
vL1a0 S vobj(vOid,0)=0 Q
vL1a1 S vobj(vOid,1)=$$BYTECHAR^SQLUTL(254)
 S vobj(vOid,2)=""
vL1a3 S vobj(vOid,2)=$O(^STBL("SYSKEYWORDS",vobj(vOid,2)),1) I vobj(vOid,2)="" G vL1a0
 Q
 ;
vFetch1(vOid) ;
 ;
 ;
 I vobj(vOid,0)=1 D vL1a3
 I vobj(vOid,0)=2 S vobj(vOid,0)=1
 ;
 I vobj(vOid,0)=0 S vobj(vOid)="" Q 0
 ;
 S vobj(vOid,3)=$G(^STBL("SYSKEYWORDS",vobj(vOid,2)))
 S vobj(vOid)=$S(vobj(vOid,2)=vobj(vOid,1):"",1:vobj(vOid,2))_$C(9)_$P(vobj(vOid,3),"|",1)
 ;
 Q 1
 ;
vRwsNxt(vOid) ; RowSet.next
 ;
 N vLst S vLst=$O(vobj(vOid,""),-1)
 I vobj(vOid,0)'>vLst S vobj(vOid,0)=vobj(vOid,0)+1
 Q vobj(vOid,0)'>vLst
 ;
vCatch2 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 S return=1
 D ZX^UCGMR(voxMrk) Q 
 ;
vCatch1 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 S return=1
 D ZX^UCGMR(voxMrk) Q 
