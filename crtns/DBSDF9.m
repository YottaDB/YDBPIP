 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSDF9 ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSDF9 ; 
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
 ; Prompt for list of tables
 Q:'$$LIST^DBSGETID("DBTBL1") 
 ;
 N rs,vos1,vos2,vos3,vos4  N V1 S V1=$J S rs=$$vOpen1()
 ;
 F  Q:'$$vFetch1()  D BLDINDX(rs)
 ;
  N V2 S V2=$J D vDbDe1()
 ;
 ; Done
 ;  #ACCEPT DATE=03/11/2008; PGM=Dan Russell; CR=30801; Group=ACCESS
 WRITE $$MSG^%TRMVT($$^MSG(855),"",1)
 ;
 Q 
 ;
BUILDALL ; 
 ;
 N rs,vos1,vos2,vos3 S rs=$$vOpen2()
 ;
 F  Q:'$$vFetch2()  D BLDINDX(rs)
 ;
 Q 
 ;
BLDINDX(TABLE) ; Table name
 ;
 N %O
 N LISTDFT N LISTREQ N nullChar
 ;
 S %O=0
 S (LISTDFT,LISTREQ)=""
 S nullChar=$$BYTECHAR^SQLUTL(254)
 ;
 ; Rebuild indexes if not relational database
 I '$$rdb^UCDBRT("DBTBL1") D
 .	;
 .	;   #ACCEPT Date=06/11/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	N N,TYPE
 .	;
 .	; Delete existing entries before rebuild
 .	; ^XDBREF entries
 .	F TYPE="DBTBL1.FSN","DBTBL1.GLOBAL" D
 .	. S N=""
 .	. F  S N=$O(^XDBREF(TYPE,"SYSDEV",N)) Q:N=""  K ^XDBREF(TYPE,"SYSDEV",N,TABLE)
 .	; ^DBINDX entries
 .	F TYPE="FKPTR","MDD","PARFID" D
 .	. S N=""
 .	. F  S N=$O(^DBINDX("SYSDEV",TYPE,N)) Q:N=""  K ^DBINDX("SYSDEV",TYPE,N,TABLE)
 .	S N=""
 .	F  S N=$O(^DBINDX("SYSDEV","DOM","PBS",N)) Q:N=""  K ^DBINDX("SYSDEV","DOM","PBS",N,TABLE)
 .	K ^DBINDX("SYSDEV","STR",TABLE)
 .	;
 .	; Rebuild DBTBL1 indexes - refer to dbtbl1.rebuildIndexes("*")
 .	; FSN
 .	N FSN S FSN=$P($G(^DBTBL("SYSDEV",1,TABLE,12)),"|",1)
 .	I FSN="" S FSN=nullChar
 .	S ^XDBREF("DBTBL1.FSN","SYSDEV",FSN,TABLE)=""
 .	; GLOBAL
 .	N GLOBAL S GLOBAL=$P($G(^DBTBL("SYSDEV",1,TABLE,0)),"|",1)
 .	I GLOBAL="" S GLOBAL=nullChar
 .	S ^XDBREF("DBTBL1.GLOBAL","SYSDEV",GLOBAL,TABLE)=""
 .	; PARFID
 .	N PARFID S PARFID=$P($G(^DBTBL("SYSDEV",1,TABLE,10)),"|",4)
 .	I PARFID="" S PARFID=nullChar
 .	S ^DBINDX("SYSDEV","PARFID",PARFID,TABLE)=""
 .	;
 .	; Rebuild DBTBL1D indexes, and create DFT and REQ lists
 .	N DI S DI=""
 .	F  S DI=$O(^DBTBL("SYSDEV",1,TABLE,9,DI)) Q:DI=""  D
 .	. N DBTBL1D S DBTBL1D=$G(^DBTBL("SYSDEV",1,TABLE,9,DI))
 .	. ; DOMAIN
 .	. N DOM S DOM=$P(DBTBL1D,"|",4)
 .	. I DOM="" S DOM=nullChar
 .	. S ^DBINDX("SYSDEV","DOM","PBS",DOM,TABLE,DI)=""
 .	. ; MDD
 .	. N MDD S MDD=$P(DBTBL1D,"|",27)
 .	. I MDD="" S MDD=nullChar
 .	. S ^DBINDX("SYSDEV","MDD",MDD,TABLE,DI)=""
 .	. ; NODEPOS
 .	. N NOD S NOD=$P(DBTBL1D,"|",1)
 .	. I NOD="" S NOD=nullChar
 .	. N POS S POS=$P(DBTBL1D,"|",21)
 .	. I POS="" S POS=nullChar
 .	. S ^DBINDX("SYSDEV","STR",TABLE,NOD,POS,DI)=""  
 .	. ;
 .	. ; If not literal or computed, add to required and default lists, if appropriate
 .	. I '$$isLit^UCGM(DI),$TR($P(DBTBL1D,"|",16)," ")="" D
 .	..  I $P(DBTBL1D,"|",15) S LISTREQ=LISTREQ_DI_","
 .	..  E  I (NOD'=nullChar),(NOD["*") S LISTREQ=LISTREQ_DI_","
 .	..  I $P(DBTBL1D,"|",3)'="" S LISTDFT=LISTDFT_DI_","
 .	;  
 .	; Rebuild DBTBL1F indexes
 .	N FKEYS S FKEYS=""
 .	F  S FKEYS=$O(^DBTBL("SYSDEV",19,TABLE,FKEYS)) Q:FKEYS=""  D
 .	. ; FKPTR
 .	. N TBLREF S TBLREF=$P($G(^DBTBL("SYSDEV",19,TABLE,FKEYS)),"|",5)
 .	. I TBLREF="" S RBLREF=nullChar
 .	. S ^DBINDX("SYSDEV","FKPTR",TBLREF,TABLE,FKEYS)=""
 .	;
 .	; Update LISTREQ and LISTDEF
 .	S $P(^DBTBL("SYSDEV",1,TABLE,101),"|",1)=$E(LISTDFT,1,$L(LISTDFT)-1)
 .	S $P(^DBTBL("SYSDEV",1,TABLE,102),"|",1)=$E(LISTREQ,1,$L(LISTREQ)-1)
 .	;*** End of code by-passed by compiler ***
 .	Q 
 ;
 ; If DBTBL is in RDB, then just build LISTDFT and LISTREQ
 E  D
 .	;
 .	N rs,vos1,vos2,vos3,vos4,vos5 S rs=$$vOpen3()
 .	;
 .	F  Q:'$$vFetch3()  D
 ..		;
 ..  I '$$isLit^UCGM($P(rs,$C(9),1)) D
 ...			;
 ...   I $P(rs,$C(9),4)!($P(rs,$C(9),3)["*") S LISTREQ=LISTREQ_$P(rs,$C(9),1)_","
 ...   I '($P(rs,$C(9),2)="") S LISTDFT=LISTDFT_$P(rs,$C(9),1)_","
 ...			Q 
 ..		Q 
 .	;
 .	S LISTDFT=$E(LISTDFT,1,$L(LISTDFT)-1)
 .	S LISTREQ=$E(LISTREQ,1,$L(LISTREQ)-1)
 .	;
 .	; Only save if changed to avoid always having filer reset last user and date
 .	N rs2,vos6,vos7,vos8,vos9,vos10 S rs2=$$vOpen4()
 .	;
 .	I $$vFetch4() D
 ..		;
 ..  I ($P(rs2,$C(9),1)'=LISTDFT) D
 ...			;
 ...			;     #ACCEPT Date=06/11/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 ...			;*** Start of code by-passed by compiler
 ...			N ret
 ...			S ret=$$EXECUTESQL^%DBAPI(0,"UPDATE DBTBL1 SET LISTDFT=:HV1 WHERE S_LIBS=:V1 AND FID=:V2",$C(124),LISTDFT_$C(124)_"'SYSDEV'"_$C(124)_TABLE_$C(124))
 ...			I ($TL=0) D commit^vRuntime(0)
 ...			;*** End of code by-passed by compiler ***
 ...			Q 
 ..		;
 ..  I ($P(rs2,$C(9),2)'=LISTREQ) D
 ...			;
 ...			;     #ACCEPT Date=06/11/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 ...			;*** Start of code by-passed by compiler
 ...			N ret
 ...			S ret=$$EXECUTESQL^%DBAPI(0,"UPDATE DBTBL1 SET LISTREQ=:HV1 WHERE S_LIBS=:V1 AND FID=:V2",$C(124),LISTREQ_$C(124)_"'SYSDEV'"_$C(124)_TABLE_$C(124))
 ...			I ($TL=0) D commit^vRuntime(0)
 ...			;*** End of code by-passed by compiler ***
 ...			Q 
 ..		Q 
 . Q 
 ;
 Q 
 ;
DBSUTL9 ; 
 ;
 ; No Yes
 ;  #ACCEPT DATE=03/11/2008; PGM=Dan Russell; CR=30801; Group=ACCESS
 Q:(+$$^DBSMBAR(166)'=+2) 
 ;
 D %EXT
 ;
 Q 
 ;
%EXT ; 
 N vTp
 ;
 ; Rebuild field ID index file
 WRITE !!,$$^MSG("3221"),!!
 WRITE $$vdat2str($P($H,",",1),"MM/DD/YEAR"),"  ",$$vtim2str($P($H,",",2),"24:60:SS"),!!
 ;
 N ds,vos1,vos2,vos3 S ds=$$vOpen5()
 ;
 F  Q:'$$vFetch5()  D
 .	;
 .	N glref
 .	;
 . N dbtbl1 S dbtbl1=$$vRCgetRecord1^RecordDBTBL1($P(ds,$C(9),1),$P(ds,$C(9),2),1)
 .	 S vobj(dbtbl1,0)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),0))
 .	 S vobj(dbtbl1,16)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),16))
 .	 S vobj(dbtbl1,100)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),100))
 .	;
 .	I ($P(vobj(dbtbl1,0),$C(124),1)="") S glref=""
 .	;
 .	E  S glref="^"_$P(vobj(dbtbl1,0),$C(124),1)_"("_$P(vobj(dbtbl1,16),$C(124),1)
 .	;
 .	I ($P(vobj(dbtbl1,100),$C(124),1)'=glref) D
 ..		;
 ..	  S vobj(dbtbl1,-100,100)="" S $P(vobj(dbtbl1,100),$C(124),1)=glref
 ..		;
 ..	 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL1(dbtbl1,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbtbl1,-100) S vobj(dbtbl1,-2)=1 TC:vTp  
 ..		Q 
 .	K vobj(+$G(dbtbl1)) Q 
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61413^60987^Dan Russell^7797" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM TMPDQ WHERE PID=:V2
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen6()
 F  Q:'$$vFetch6()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^TEMP(v1,v2)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vdat2str(vo,mask) ; Date.toString
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I (vo="") Q ""
 I (mask="") S mask="MM/DD/YEAR"
 N cc N lday N lmon
 I mask="DL"!(mask="DS") D  ; Long or short weekday
 .	;    #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL
 .	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
 .	I (cc="") S cc="US"
 .	;    #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL
 .	S lday=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
 .	S mask="DAY" ; Day of the week
 .	Q 
 I mask="ML"!(mask="MS") D  ; Long or short month
 .	;    #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL
 .	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
 .	I (cc="") S cc="US"
 .	;    #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL
 .	S lmon=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
 .	S mask="MON" ; Month of the year
 .	Q 
 ;  #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=BYPASS
 ;*** Start of code by-passed by compiler
 set cc=$ZD(vo,mask,$G(lmon),$G(lday))
 ;*** End of code by-passed by compiler ***
 Q cc
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
vOpen1() ; ELEMENT FROM TMPDQ WHERE PID=:V1 ORDER BY ELEMENT ASC
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1)
 S vos4=""
vL1a4 S vos4=$O(^TEMP(vos3,vos4),1) I vos4="" G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen2() ; FID FROM DBTBL1 WHERE %LIBS='SYSDEV' ORDER BY FID ASC
 ;
 ;
 S vos1=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos1=0 Q
vL2a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL2a3 S vos3=$O(^DBTBL("SYSDEV",1,vos3),1) I vos3="" G vL2a0
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
 S rs=$S(vos3=vos2:"",1:vos3)
 ;
 Q 1
 ;
vOpen3() ; DI,DFT,NOD,REQ FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:TABLE ORDER BY DI ASC
 ;
 ;
 S vos1=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos1=0 Q
vL3a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(TABLE) I vos3="" G vL3a0
 S vos4=""
vL3a4 S vos4=$O(^DBTBL("SYSDEV",1,vos3,9,vos4),1) I vos4="" G vL3a0
 Q
 ;
vFetch3() ;
 ;
 ;
 I vos1=1 D vL3a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos5=$G(^DBTBL("SYSDEV",1,vos3,9,vos4))
 S rs=$S(vos4=vos2:"",1:vos4)_$C(9)_$P(vos5,"|",3)_$C(9)_$P(vos5,"|",1)_$C(9)_$P(vos5,"|",15)
 ;
 Q 1
 ;
vOpen4() ; LISTDFT,LISTREQ FROM DBTBL1 WHERE %LIBS='SYSDEV' AND FID=:TABLE
 ;
 ;
 S vos6=2
 D vL4a1
 Q ""
 ;
vL4a0 S vos6=0 Q
vL4a1 S vos7=$$BYTECHAR^SQLUTL(254)
 S vos8=$G(TABLE) I vos8="" G vL4a0
 I '($D(^DBTBL("SYSDEV",1,vos8))) G vL4a0
 Q
 ;
vFetch4() ;
 ;
 ;
 ;
 I vos6=0 S rs2="" Q 0
 ;
 S vos6=100
 S vos9=$G(^DBTBL("SYSDEV",1,vos8,101))
 S vos10=$G(^DBTBL("SYSDEV",1,vos8,102))
 S rs2=$P(vos9,"|",1)_$C(9)_$P(vos10,"|",1)
 S vos6=0
 ;
 Q 1
 ;
vOpen5() ; %LIBS,FID FROM DBTBL1 WHERE %LIBS='SYSDEV' ORDER BY FID ASC
 ;
 ;
 S vos1=2
 D vL5a1
 Q ""
 ;
vL5a0 S vos1=0 Q
vL5a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL5a3 S vos3=$O(^DBTBL("SYSDEV",1,vos3),1) I vos3="" G vL5a0
 Q
 ;
vFetch5() ;
 ;
 ;
 I vos1=1 D vL5a3
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds="" Q 0
 ;
 S ds="SYSDEV"_$C(9)_$S(vos3=vos2:"",1:vos3)
 ;
 Q 1
 ;
vOpen6() ; PID,ELEMENT FROM TMPDQ WHERE PID=:V2
 ;
 ;
 S vos1=2
 D vL6a1
 Q ""
 ;
vL6a0 S vos1=0 Q
vL6a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V2)
 S vos4=""
vL6a4 S vos4=$O(^TEMP(vos3,vos4),1) I vos4="" G vL6a0
 Q
 ;
vFetch6() ;
 ;
 ;
 I vos1=1 D vL6a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
