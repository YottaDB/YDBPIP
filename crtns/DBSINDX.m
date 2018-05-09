 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSINDX ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSINDX ; Index File Definition
 ;
 Q 
 ;
CREATE ; Create Index File Definition
 ;
 N FID N VFMQ
 ;
 S FID=""
 S VFMQ=""
 ;
 D PFILES(0,.FID,.VFMQ)
 ;
 I VFMQ="Q" Q 
 I ER Q 
 ;
 D MODIFY1(FID)
 ;
 Q 
 ;
MODIFY ; Modify Index File Definition
 ;
 N FID N VFMQ
 ;
 S FID=""
 S VFMQ=""
 ;
 D PFILES(1,.FID,.VFMQ)
 ;
 I VFMQ="Q" Q 
 I ER Q 
 ;
 D MODIFY1(FID)
 ;
 Q 
 ;
MODIFY1(FID) ; 
 N vTp
 ;
 N DELFLG
 N INDEXNM N VFMQ
 ;
 S %O=1
 S INDEXNM=" "
 S DELFLG=0
 ;
 N DBTBL1 S DBTBL1=$$vRCgetRecord0^RecordDBTBL1("SYSDEV",FID,0)
 N DBTBL8 S DBTBL8=$$vcdmNew^RecordDBTBL8()
 ;
  S vobj(DBTBL8,-3)="SYSDEV"
  S vobj(DBTBL8,-4)=FID
 ;
 N vo1 N vo2 N vo3 D DRV^USID(0,"DBTBL8",.DBTBL8,.DBTBL1,.vo1,.vo2,.vo3) K vobj(+$G(vo1)) K vobj(+$G(vo2)) K vobj(+$G(vo3))
 ;
 I VFMQ="Q" K vobj(+$G(DBTBL1)),vobj(+$G(DBTBL8)) Q 
 ;
 I DELFLG D
 .	;
 .	 N V1,V2 S V1=vobj(DBTBL8,-4),V2=vobj(DBTBL8,-5) D vDbDe1()
 .	Q 
 E  S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL8(DBTBL8,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(DBTBL8,-100) S vobj(DBTBL8,-2)=1 TC:vTp   ; Call filer to update record
 ;
 ; Index name ~p1 filed ... Continue?
 I '$$YN^DBSMBAR("",$$^MSG(1218,INDEXNM),1) K vobj(+$G(DBTBL1)),vobj(+$G(DBTBL8)) Q 
 ;
 D MODIFY1(FID)
 ;
 K vobj(+$G(DBTBL1)),vobj(+$G(DBTBL8)) Q 
 ;
MODE ; Determine processing mode
 ;
 I DELFLG S %O=3 Q  ; Delete mode
 ;
 I ($D(^DBTBL("SYSDEV",8,FID,INDEXNM))#2) S %O=1 Q  ; Modify mode
 ;
 S %O=0 ; Create mode
 ;
 Q 
 ;
PFILES(IOPT,FID,VFMQ) ; Select primary file name
 ;
 N IEXIST
 N srclib
 ;
 S FID=$$FIND^DBSGETID("DBTBL1",0)
 ;
 I FID="" S VFMQ="Q" Q 
 ;
 S VFMQ="F"
 ;
 N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen1()
 I '$G(vos1) S IEXIST=0
 E  S IEXIST=1
 ;
 ; Index file definition already exists
 I 'IOPT,IEXIST S ER=1 S RM=$$^MSG(1214) Q 
 ;
 ; Index file definition not available
 I IOPT,'IEXIST S ER=1 S RM=$$^MSG(1215) Q 
 ;
 Q 
 ;
COPY ; Copy Index File Definition
 N vTp
 ;
 N %TAB N %READ N %NOPRMT N FID N INDEXNM N PSFILE N VFMQ
 ;
 S ER=0
 S RM=""
 ;
 S %TAB("PSFILE")=".PSFILE1/TBL=[DBTBL1]"
 S %TAB("FID")=".POFILE1/TBL=[DBTBL1]/XPP=D COPYPP^DBSINDX"
 ;
 S %READ="@@%FN,,,PSFILE/REQ,FID/REQ" S %NOPRMT="F"
 ;
 D ^UTLREAD
 ;
 I VFMQ="Q" Q 
 ;
 N ds,vos1,vos2,vos3,vos4 S ds=$$vOpen2()
 F  Q:'$$vFetch2()  D
 .	;
 . N FD8 S FD8=$$vRCgetRecord1^RecordDBTBL8($P(ds,$C(9),1),$P(ds,$C(9),2),$P(ds,$C(9),3),1)
 .	N TD8 S TD8=$$vcdmNew^RecordDBTBL8()
 .	;
 .  K vobj(+$G(TD8)) S TD8=$$vReCp1(FD8)
 .  S vobj(TD8,-4)=FID
 .	;
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL8(TD8,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(TD8,-100) S vobj(TD8,-2)=1 TC:vTp  
 .	;
 .	K vobj(+$G(FD8)),vobj(+$G(TD8)) Q 
 ;
 WRITE $$MSG^%TRMVT($$^MSG(855),"",1)
 ;
 Q 
 ;
COPYPP ; -------- Post-Processor
 ;
 Q:(X="") 
 ;
 N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen3()
 ;
 ; Already created
 I ''$G(vos1) S ER=1 S RM=$$^MSG(252)
 ;
 Q 
 ;
DELETE ; Delete Index File Definition
 ;
 N FID N VFMQ
 ;
 S ER=0
 S FID=""
 S VFMQ=""
 ;
 D PFILES(1,.FID,.VFMQ)
 ;
 Q:VFMQ="Q" 
 Q:ER 
 ;
 ; Are you sure?
 I '$$YN^DBSMBAR("",$$^MSG(307)) Q 
 ;
 D vDbDe2()
 ;
 WRITE $$MSG^%TRMVT($$^MSG(855),"",1)
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61247^57696^Dan Russell^3802" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM DBTBL8 WHERE %LIBS='SYSDEV' AND FID=:V1 AND INDEXNM=:V2
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vRec S vRec=$$vRCgetRecord1^RecordDBTBL8("SYSDEV",V1,V2,0)
 I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordDBTBL8(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 K vobj(+$G(vRec)) Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe2() ; DELETE FROM DBTBL8 WHERE %LIBS='SYSDEV' AND FID=:FID
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vDs,vos1,vos2,vos3,vos4 S vDs=$$vOpen4()
 F  Q:'$$vFetch4()  D
 . N vRec S vRec=$$vRCgetRecord1^RecordDBTBL8($P(vDs,$C(9),1),$P(vDs,$C(9),2),$P(vDs,$C(9),3),1)
 .	S vobj(vRec,-2)=3
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordDBTBL8(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	K vobj(+$G(vRec)) Q 
  TC:$TL 
 Q 
 ;
vOpen1() ; INDEXNM FROM DBTBL8 WHERE %LIBS='SYSDEV' AND FID=:FID
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(FID) I vos3="" G vL1a0
 S vos4=""
vL1a4 S vos4=$O(^DBTBL("SYSDEV",8,vos3,vos4),1) I vos4="" G vL1a0
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
vOpen2() ; %LIBS,FID,INDEXNM FROM DBTBL8 WHERE %LIBS='SYSDEV' AND FID=:PSFILE
 ;
 ;
 S vos1=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos1=0 Q
vL2a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(PSFILE) I vos3="" G vL2a0
 S vos4=""
vL2a4 S vos4=$O(^DBTBL("SYSDEV",8,vos3,vos4),1) I vos4="" G vL2a0
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos1=1 D vL2a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds="" Q 0
 ;
 S ds="SYSDEV"_$C(9)_vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen3() ; INDEXNM FROM DBTBL8 WHERE %LIBS='SYSDEV' AND FID=:X
 ;
 ;
 S vos1=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos1=0 Q
vL3a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(X) I vos3="" G vL3a0
 S vos4=""
vL3a4 S vos4=$O(^DBTBL("SYSDEV",8,vos3,vos4),1) I vos4="" G vL3a0
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
 S rs=$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen4() ; %LIBS,FID,INDEXNM FROM DBTBL8 WHERE %LIBS='SYSDEV' AND FID=:FID
 ;
 ;
 S vos1=2
 D vL4a1
 Q ""
 ;
vL4a0 S vos1=0 Q
vL4a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(FID) I vos3="" G vL4a0
 S vos4=""
vL4a4 S vos4=$O(^DBTBL("SYSDEV",8,vos3,vos4),1) I vos4="" G vL4a0
 Q
 ;
vFetch4() ;
 ;
 ;
 I vos1=1 D vL4a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vDs="" Q 0
 ;
 S vDs="SYSDEV"_$C(9)_vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vReCp1(v1) ; RecordDBTBL8.copy: DBTBL8
 ;
 Q $$copy^UCGMR(FD8)
