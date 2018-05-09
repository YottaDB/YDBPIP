 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSDRV1 ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSDRV1 ; 
 ;
 ; Call from top to create function to access DQ generated screens
 ;
 N OPT N VFMQ
 ;
 ; Add a new record
 S OPT("A")=$$^MSG("3328")
 ; Update an existing record
 S OPT("U")=$$^MSG("3332")
 ; Display a record to the terminal
 S OPT("D")=$$^MSG("3329")
 ; Print a record to a hard copy device
 S OPT("P")=$$^MSG("3330")
 ; Remove an existing record
 S OPT("R")=$$^MSG("3331")
 ;
 S VFMQ=""
 ;
 F  D  Q:(VFMQ="Q") 
 .	;
 .	N %FRAME N OPTION
 .	N %READ N %TAB N ZDES N ZFUN N ZOPT N ZSID
 .	;
 .	S %TAB("ZSID")=".SID1/TBL=[DBTBL2]SID,DESC"
 .	S %TAB("ZOPT")=".ZOPT1/TBL=OPT("
 .	S %TAB("ZFUN")=".FUN1/TBL=[SCATBL]/XPP=D PP^DBSDRV1"
 .	S %TAB("ZDES")=".ZDES1"
 .	;
 .	S %FRAME=2
 .	;
 .	S %READ="@@%FN,,ZSID/REQ,ZOPT/REQ,ZFUN/REQ,ZDES/REQ,"
 .	;
 .	D ^UTLREAD Q:(VFMQ="Q") 
 .	;
 .	S OPTION=$F("AUDRP",ZOPT)-2
 .	;
 .	D SET(ZFUN,ZDES,"","^DBSDEUTL("_OPTION_","_""""_ZSID_""""_")",0)
 .	Q 
 ;
 Q 
 ;
REPORT ; 
 ;
 N VFMQ S VFMQ=""
 ;
 F  D  Q:(VFMQ="Q") 
 .	;
 .	N %FRAME
 .	N %READ N %TAB N ZDES N ZFUN N ZRID
 .	;
 .	S %TAB("ZRID")=".RID2/TBL=[DBTBL5H]RID,DESC"
 .	S %TAB("ZFUN")=".FUN1/TBL=^SCATBL(1,/XPP=D PP^DBSDRV1"
 .	S %TAB("ZDES")=".ZDES1"
 .	;
 .	S %FRAME=2
 .	;
 .	S %READ="@@%FN,,ZRID/REQ,ZFUN/REQ,ZDES/REQ,"
 .	;
 .	D ^UTLREAD Q:(VFMQ="Q") 
 .	;
 .	D SET(ZFUN,ZDES,"S RID="""_ZRID_"""","RPT^URID",1)
 .	Q 
 ;
 Q 
 ;
RDIST ; 
 ;
 N VFMQ S VFMQ=""
 ;
 F  D  Q:(VFMQ="Q") 
 .	;
 .	N %FRAME N ZMOD
 .	N %READ N %TAB N ZDES N ZFUN N ZRID
 .	;
 .	S %TAB("ZRID")=".RID2/TBL=[DBTBL5H]RID,DESC:QU ""[DBTBL5H]DISTKEY'="""""""""""
 .	S %TAB("ZFUN")=".FUN1/TBL=[SCATBL]/XPP=D PP^DBSDRV1"
 .	S %TAB("ZDES")=".ZDES1"
 .	S %TAB("ZMOD")=".TABFMT"
 .	;
 .	S %FRAME=2
 .	;
 .	S %READ="@@%FN,,ZRID/REQ,ZFUN/REQ,ZDES/REQ,ZMOD/REQ"
 .	;
 .	D ^UTLREAD Q:(VFMQ="Q") 
 .	;
 .	D SET(ZFUN,ZDES,"S RID="""_ZRID_""",VMODE="_ZMOD,"EXT^DBSRWDST(RID,VMODE)",1)
 .	Q 
 ;
 Q 
 ;
QWIKRPT ; 
 ;
 N VFMQ S VFMQ=""
 ;
 F  D  Q:(VFMQ="Q") 
 .	;
 .	N %FRAME
 .	N %READ N %TAB N ZDES N ZFUN N ZQRID
 .	;
 .	S %TAB("ZQRID")=".ZQRID1/TBL=[DBTBL5Q]QRID,DESC"
 .	S %TAB("ZFUN")=".FUN1/TBL=[SCATBL]/XPP=D PP^DBSDRV1"
 .	S %TAB("ZDES")=".ZDES1"
 .	;
 .	S %FRAME=2
 .	;
 .	S %READ="@@%FN,,ZQRID/REQ,ZFUN/REQ,ZDES/REQ,"
 .	;
 .	D ^UTLREAD Q:(VFMQ="Q") 
 .	;
 .	D SET(ZFUN,ZDES,"S QRID="""_ZQRID_"""","QRPT^URID",1)
 .	Q 
 ;
 Q 
 ;
PP ; Post processor on ZFUN
 ;
 Q:(X="") 
 ;
 I (X=+X) D  Q 
 .	;
 .	S ER=1
 .	; Invalid format
 .	S RM=$$^MSG(1350)
 .	Q 
 ;
 I ($D(^SCATBL(1,X))#2) D  Q 
 .	;
 .	S ER=1
 .	; Already exists
 .	S RM=$$^MSG(253)
 .	Q 
 ;
 S I(3)=""
 ;
 Q 
 ;
SET(FN,DESC,PRP,PGM,QUEUE) ; 
 N vTp
 ;
 N scatbl S scatbl=$$vcdmNew^RecordSCATBL() S vobj(scatbl,-3)=FN
 ;
  S $P(vobj(scatbl),$C(124),1)=DESC
  S $P(vobj(scatbl),$C(124),2)=PRP
  S $P(vobj(scatbl),$C(124),4)=PGM
  S $P(vobj(scatbl),$C(124),18)=QUEUE
 ;
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSCATBL(scatbl,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(scatbl,-100) S vobj(scatbl,-2)=1 TC:vTp  
 ;
 I '($get(%UCLS)="") D
 .	;
 .	N scatbl3 S scatbl3=$$vcdmNew^RecordSCATBL3() S vobj(scatbl3,-3)=FN S vobj(scatbl3,-4)=%UCLS
 .	;
 .  S $P(vobj(scatbl3),$C(124),1)=""
 .	;
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordSCATBL3(scatbl3,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(scatbl3,-100) S vobj(scatbl3,-2)=1 TC:vTp  
 .	K vobj(+$G(scatbl3)) Q 
 ;
 ; Function ~p1 created
 WRITE $$MSG^%TRMVT($$^MSG("1144",FN),"",1)
 ;
 K vobj(+$G(scatbl)) Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60425^2579^Dan Russell^3676" ; Signature - LTD^TIME^USER^SIZE
