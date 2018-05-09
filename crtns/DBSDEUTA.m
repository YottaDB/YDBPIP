 ; 
 ; **** Routine compiled from unknown source ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSDEUTA(SID,ProcMode,KEY,FPRE) ; Generic Screen Driver
 ; Last compiled:  02/24/2010 18:21:19 - pip
 ;
 ; THIS IS A COMPILED ROUTINE.  Compiled by procedure DBSDEUTB
 ;
 ; See DBSDEUTB for argument definitions
 ;
 N ERMSG N SCREEN N TABLE
 S FPRE=$get(FPRE)
 ;
 I SID="DBTBL25" Q $$gf1(ProcMode,.KEY,FPRE)
 E  I SID="DBTBL7" Q $$gf2(ProcMode,.KEY,FPRE)
 E  I SID="DBTBL9" Q $$gf3(ProcMode,.KEY,FPRE)
 ;
 Q "Screen "_SID_" not permitted to run via this function"
 ;
 ; Generic Functions for each screen
 ;
gf1(ProcMode,KEY,FPRE) ; DBTBL25 - Procedure Definition
 N vTp
 ;
 N ER S ER=0
 N ERMSG N RM
 ;
 S (ERMSG,RM,VFMQ)=""
 ;
 N dbtbl2,vop1,vop2,vop3,vop4 S vop1="SYSDEV",vop2="DBTBL25",dbtbl2=$$vRCgetRecord1Opt^RecordDBTBL2("SYSDEV","DBTBL25",0,.vop3)
  S vop4=$G(^DBTBL(vop1,2,vop2,0))
 I '$G(vop3) S ER=1 S ERMSG="Invalid Screen Name" Q ERMSG
 I '$P(vop4,$C(124),22) S ER=1 S ERMSG="Screen must be converted to PSL" Q ERMSG
 N fDBTBL25 S fDBTBL25=$$vRCgetRecord1^RecordDBTBL25(KEY(1),KEY(2),0)
 ;  #ACCEPT Date=03/04/07; Pgm=RussellDS; CR=25558; Group=MISMATCH
 N vo1 N vo2 N vo3 N vo4 D DRV^USID(ProcMode,"DBTBL25",.fDBTBL25,.vo1,.vo2,.vo3,.vo4) K vobj(+$G(vo1)) K vobj(+$G(vo2)) K vobj(+$G(vo3)) K vobj(+$G(vo4))
 ;
 I 'ER,(VFMQ'="Q") D
 .	;
 .	;   #ACCEPT Date=01/20/05;PGM=Screen Compiler;CR=14146
 .	I '(FPRE="") XECUTE FPRE I ER Q 
 .	;
 .	I ProcMode<2,$D(vobj(fDBTBL25,-100)) S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL25(fDBTBL25,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(fDBTBL25,-100) S vobj(fDBTBL25,-2)=1 TC:vTp  
 .	I ProcMode=3  N V1,V2 S V1=KEY(1),V2=KEY(2)  ZWI ^DBTBL(V1,25,V2)
 .	Q 
 ;
 I ER S ERMSG=$get(RM)
 ;
 K vobj(+$G(fDBTBL25)) Q ERMSG
 ;
gf2(ProcMode,KEY,FPRE) ; DBTBL7 - Trigger Definition
 N vTp
 ;
 N ER S ER=0
 N ERMSG N RM
 ;
 S (ERMSG,RM,VFMQ)=""
 ;
 N dbtbl2,vop1,vop2,vop3,vop4 S vop1="SYSDEV",vop2="DBTBL7",dbtbl2=$$vRCgetRecord1Opt^RecordDBTBL2("SYSDEV","DBTBL7",0,.vop3)
  S vop4=$G(^DBTBL(vop1,2,vop2,0))
 I '$G(vop3) S ER=1 S ERMSG="Invalid Screen Name" Q ERMSG
 I '$P(vop4,$C(124),22) S ER=1 S ERMSG="Screen must be converted to PSL" Q ERMSG
 N fDBTBL7 S fDBTBL7=$$vRCgetRecord1^RecordDBTBL7(KEY(1),KEY(2),KEY(3),0)
 ;  #ACCEPT Date=03/04/07; Pgm=RussellDS; CR=25558; Group=MISMATCH
 N vo5 N vo6 N vo7 N vo8 D DRV^USID(ProcMode,"DBTBL7",.fDBTBL7,.vo5,.vo6,.vo7,.vo8) K vobj(+$G(vo5)) K vobj(+$G(vo6)) K vobj(+$G(vo7)) K vobj(+$G(vo8))
 ;
 I 'ER,(VFMQ'="Q") D
 .	;
 .	;   #ACCEPT Date=01/20/05;PGM=Screen Compiler;CR=14146
 .	I '(FPRE="") XECUTE FPRE I ER Q 
 .	;
 .	I ProcMode<2,$D(vobj(fDBTBL7,-100)) S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL7(fDBTBL7,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(fDBTBL7,-100) S vobj(fDBTBL7,-2)=1 TC:vTp  
 .	I ProcMode=3  N V1,V2,V3 S V1=KEY(1),V2=KEY(2),V3=KEY(3) D vDbDe1()
 .	Q 
 ;
 I ER S ERMSG=$get(RM)
 ;
 K vobj(+$G(fDBTBL7)) Q ERMSG
 ;
gf3(ProcMode,KEY,FPRE) ; DBTBL9 - Journal File Definition
 N vTp
 ;
 N ER S ER=0
 N ERMSG N RM
 ;
 S (ERMSG,RM,VFMQ)=""
 ;
 N dbtbl2,vop1,vop2,vop3,vop4 S vop1="SYSDEV",vop2="DBTBL9",dbtbl2=$$vRCgetRecord1Opt^RecordDBTBL2("SYSDEV","DBTBL9",0,.vop3)
  S vop4=$G(^DBTBL(vop1,2,vop2,0))
 I '$G(vop3) S ER=1 S ERMSG="Invalid Screen Name" Q ERMSG
 I '$P(vop4,$C(124),22) S ER=1 S ERMSG="Screen must be converted to PSL" Q ERMSG
 N fDBTBL9 S fDBTBL9=$$vRCgetRecord1^RecordDBTBL9(KEY(1),KEY(2),KEY(3),0)
 ;  #ACCEPT Date=03/04/07; Pgm=RussellDS; CR=25558; Group=MISMATCH
 N vo9 N vo10 N vo11 N vo12 D DRV^USID(ProcMode,"DBTBL9",.fDBTBL9,.vo9,.vo10,.vo11,.vo12) K vobj(+$G(vo9)) K vobj(+$G(vo10)) K vobj(+$G(vo11)) K vobj(+$G(vo12))
 ;
 I 'ER,(VFMQ'="Q") D
 .	;
 .	;   #ACCEPT Date=01/20/05;PGM=Screen Compiler;CR=14146
 .	I '(FPRE="") XECUTE FPRE I ER Q 
 .	;
 .	I ProcMode<2,$D(vobj(fDBTBL9,-100)) S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL9(fDBTBL9,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(fDBTBL9,-100) S vobj(fDBTBL9,-2)=1 TC:vTp  
 .	I ProcMode=3  N V1,V2,V3 S V1=KEY(1),V2=KEY(2),V3=KEY(3)  ZWI ^DBTBL(V1,9,V2,V3)
 .	Q 
 ;
 I ER S ERMSG=$get(RM)
 ;
 K vobj(+$G(fDBTBL9)) Q ERMSG
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM DBTBL7 WHERE %LIBS = :V1 AND TABLE = :V2 AND TRGID = :V3
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vRec S vRec=$$vRCgetRecord1^RecordDBTBL7(V1,V2,V3,0)
 I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordDBTBL7(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 K vobj(+$G(vRec)) Q 
