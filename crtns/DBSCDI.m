 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSCDI ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
 ;
 Q 
 ;
DIDESC(FID,DI) ; DATA-QWIK data item description
 N desc
 S desc=$$vDbRow1()
 Q desc
 ;
FLDESC(FID) ; DATA-QWIK File description
 N desc
 S desc=$$vDbRow2()
 Q desc
 ;
OBJDESC(LEV,NAME) ; DATA-QWIK object description
 N desc
 S desc=$$vDbRow3()
 Q desc
 ;
LEVDESC(LEV) ; DATA-QWIK level description
 N desc
 S desc=$$vDbRow4()
 Q desc
 ;
PROTPGM(FID) ; Data item protection run-time routine
 N rtn
 S rtn=$$vDbRow5()
 I rtn="" Q ""
 Q "VP01"_rtn
 ;
REQFLD(FID) ; Required data items for a DQ file
 N list
 S FID=$piece(FID,",",1) ; Primary file
 S list=$$vDbRow6()
 Q list
 ;
EXPDESC(EXPID) ; Export file Description
 N desc
 S desc=$$vDbRow7()
 Q desc
 ;
DOMDESC(SYSSN,DOM) ; Domain description
 N desc
 S desc=$$vDbRow8()
 Q desc
 ;
DOMTYPE(SYSSN,DOM) ; Domain format type
 N type
 S type=$$vDbRow9()
 Q type
 ;
DOMLEN(SYSSN,DOM) ; Domain field length
 N len
 S len=$$vDbRow10()
 Q len
 ;
VALPGM(pgm) ; Validate routine name syntax and also not in MRTNS directory
 I pgm="" Q 0
 I pgm'?1A.AN S RM=$$^MSG(1454) Q 1 ; Invalid format
 I $L(pgm)>8 S RM=$$^MSG(1454) Q 1 ; Invalid format
 ;
 ; Check duplicate name in MRTNS directory
 ;
 N %ZI,%ZR
 S %ZI(pgm)="" D INT^%RSEL ; Search routine name
 ; Duplicate name in MRTNS
 I '($D(%ZR(pgm))#2) Q 0
 N pgmStr S pgmStr=%ZR(pgm)
 S pgmStr=$ZCONVERT(pgmStr,"U")
 I pgmStr["MRTNS" S RM=$$^MSG(871)_""_%ZR(pgm)_pgm_".m" Q 1
 ; Duplicate name in CRTNS
 I pgmStr["CRTNS" S RM=$$^MSG(871)_""_%ZR(pgm)_pgm_".m" Q 1
 Q 0
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61569^11635^Sha H Mirza^4832" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vDbRow1() ; Db.GetOneRow( "DES", "DBTBL1D", "'SYSDEV',FID,DI", 9)
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vRec S vRec=$G(^DBTBL("SYSDEV",1,FID,9,DI))
 S vret=$P(vRec,$C(124),10) Q vret
 ; ----------------
 ;  #OPTION ResultClass 1
vDbRow2() ; Db.GetOneRow( "DES", "DBTBL1", "'SYSDEV',FID", 9)
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vRec S vRec=$G(^DBTBL("SYSDEV",1,FID))
 S vret=$P(vRec,$C(124),1) Q vret
 ; ----------------
 ;  #OPTION ResultClass 1
vDbRow3() ; Db.GetOneRow( "DESC", "DBTBL", "'SYSDEV',LEV,NAME", 9)
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vRec S vRec=$G(^DBTBL("SYSDEV",LEV,NAME))
 S vret=$P(vRec,$C(124),1) Q vret
 ; ----------------
 ;  #OPTION ResultClass 1
vDbRow4() ; Db.GetOneRow( "DESC", "DBCTL", "'DBOPT',LEV", 9)
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vRec S vRec=$G(^DBCTL("SYS","DBOPT",LEV))
 S vret=$P(vRec,$C(124),1) Q vret
 ; ----------------
 ;  #OPTION ResultClass 1
vDbRow5() ; Db.GetOneRow( "FPN", "DBTBL1", "'SYSDEV',FID", 9)
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vRec,vop1,vop2,vop3 S vop1="SYSDEV",vop2=FID,vRec=$$vRCgetRecord1Opt^RecordDBTBL1("SYSDEV",FID,0,"")
  S vop3=$G(^DBTBL(vop1,1,vop2,99))
 S vret=$P(vop3,$C(124),3) Q vret
 ; ----------------
 ;  #OPTION ResultClass 1
vDbRow6() ; Db.GetOneRow( "LISTREQ", "DBTBL1", "'SYSDEV',FID", 9)
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vRec,vop1,vop2,vop3 S vop1="SYSDEV",vop2=FID,vRec=$$vRCgetRecord1Opt^RecordDBTBL1("SYSDEV",FID,0,"")
  S vop3=$G(^DBTBL(vop1,1,vop2,102))
 S vret=$P(vop3,$C(124),1) Q vret
 ; ----------------
 ;  #OPTION ResultClass 1
vDbRow7() ; Db.GetOneRow( "DESC", "DBTBL17H", "'SYSDEV',EXPID", 9)
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vRec S vRec=$G(^DBTBL("SYSDEV",17,EXPID))
 S vret=$P(vRec,$C(124),1) Q vret
 ; ----------------
 ;  #OPTION ResultClass 1
vDbRow8() ; Db.GetOneRow( "DES", "DBSDOM", "SYSSN,DOM", 9)
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vRec,vop1,vop2 S vop1=SYSSN,vop2=DOM,vRec=$$vRCgetRecord1Opt^RecordDBSDOM(SYSSN,DOM,0,"")
  S vRec=$G(^DBCTL("SYS","DOM",vop1,vop2,0))
 S vret=$P(vRec,$C(124),1) Q vret
 ; ----------------
 ;  #OPTION ResultClass 1
vDbRow9() ; Db.GetOneRow( "TYP", "DBSDOM", "SYSSN,DOM", 9)
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vRec,vop1,vop2 S vop1=SYSSN,vop2=DOM,vRec=$$vRCgetRecord1Opt^RecordDBSDOM(SYSSN,DOM,0,"")
  S vRec=$G(^DBCTL("SYS","DOM",vop1,vop2,0))
 S vret=$P(vRec,$C(124),2) Q vret
 ; ----------------
 ;  #OPTION ResultClass 1
vDbRow10() ; Db.GetOneRow( "LEN", "DBSDOM", "SYSSN,DOM", 9)
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vRec,vop1,vop2 S vop1=SYSSN,vop2=DOM,vRec=$$vRCgetRecord1Opt^RecordDBSDOM(SYSSN,DOM,0,"")
  S vRec=$G(^DBCTL("SYS","DOM",vop1,vop2,0))
 S vret=$P(vRec,$C(124),3) Q vret
