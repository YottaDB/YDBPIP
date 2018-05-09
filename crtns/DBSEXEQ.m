 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSEXEQ ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSEXEQ ; 
 ;
 ; I18N=OFF
 ;
 Q  ; No entry from top
 ;
CREATE(%O) ; 
 ;
 N QFLAG N ZQRUN
 N %PAGE N %PG N DBOPT N I N SEQ
 N BAN N DLIB N DQFUN N ID N PGM N OLDPGM N OLDSID N QRID N SID N VFMQ N VPG
 ;
 N d5q
 ;
 S ZQRUN=""
 S QFLAG=0
 ;
 I %O=0 S QRID=$$FIND^DBSGETID("DBTBL5Q",1)
 E  I %O=1 S QRID=$$FIND^DBSGETID("DBTBL5Q",0)
 ;
 Q:(QRID="") 
 ;
 S VPG(99)="" ; Disable <PREV> option
 ;
 S d5q=$$vRCgetRecord1^RecordDBTBL5Q("SYSDEV",QRID,0)
  S vobj(d5q,0)=$G(^DBTBL(vobj(d5q,-3),6,vobj(d5q,-4),0))
 ;
 I ($G(vobj(d5q,-2))=0) D
 .	;
 .  S vobj(d5q,-100,0)="" S $P(vobj(d5q,0),$C(124),15)=%UID
 .  S vobj(d5q,-100,0)="" S $P(vobj(d5q,0),$C(124),3)=$P($H,",",1)
 .  S vobj(d5q,-100,0)="" S $P(vobj(d5q,0),$C(124),4)=1
 .  S vobj(d5q,-100,0)="" S $P(vobj(d5q,0),$C(124),5)=80
 .  S vobj(d5q,-100,0)="" S $P(vobj(d5q,0),$C(124),12)=1
 .  S vobj(d5q,-100,0)="" S $P(vobj(d5q,0),$C(124),14)=1
 .	Q 
 ;
 ;  #ACCEPT Date=04/28/2008; Pgm=RussellDS; CR=33611; Group=MISMATCH
 N vo1 N vo2 N vo3 N vo4 D DRV^USID(%O,"DBTBL5Q",.d5q,.vo1,.vo2,.vo3,.vo4) K vobj(+$G(vo1)) K vobj(+$G(vo2)) K vobj(+$G(vo3)) K vobj(+$G(vo4))
  S:'$D(vobj(d5q,0)) vobj(d5q,0)=$S(vobj(d5q,-2):$G(^DBTBL(vobj(d5q,-3),6,vobj(d5q,-4),0)),1:"")
 ;
 I VFMQ="Q" K vobj(+$G(d5q)) Q 
 ;
 S DLIB="SYSDEV"
 ;
 I ($P(vobj(d5q,0),$C(124),1)="") K vobj(+$G(d5q)) Q 
 ;
 S %PG=2
 S %PAGE=2 ; Two-page definiiton
 ;
 I $P(vobj(d5q,0),$C(124),8)>0 S %PAGE=3 ; Add one for STAT definition
 ;
 S BAN=$P(vobj(d5q,0),$C(124),12)
 I '($E(BAN,1)="@") D
 .	D UPDTBL(d5q,QRID)
 .	 S:'$D(vobj(d5q,0)) vobj(d5q,0)=$G(^DBTBL(vobj(d5q,-3),6,vobj(d5q,-4),0))
 .	;
 .	I VFMQ="Q" S QFLAG=1
 .	Q 
 ;
 I 'QFLAG,'($P(vobj(d5q,0),$C(124),1)="") D
 .	;
 .	I $P(vobj(d5q,0),$C(124),8)>0 D UPDSTAT(d5q,QRID) ; Define STAT definition
 .	;
 .	I VFMQ'="Q" D BUILD(QRID) ; Compile and run report
 .	Q 
 ;
 K vobj(+$G(d5q)) Q 
 ;
CHANGE ; Status of screen changes
 ;
 ; If any changes, signals need to recompile
 I '($D(UX("DBTBL6F"))#2) Q 1 ; Layout changed
 I '($D(UX("DBTBL5SQ"))#2) Q 1 ; Stat def changed
 I ($D(UX("DBTBL5Q",""))#2) Q 0 ; Nothing changed
 ;
 Q 1
 ;
LIST ; 
 ;
 N CNT
 N %BLK N IO N RID N RN
 ;
 S CNT=$$LIST^DBSGETID("DBTBL5Q","List",.IO) Q:(CNT'>0) 
 ;
 ; QUICK REPORT DEFINITIONS
 S RN=$$^MSG(7980)
 S RID="DBSQRPLST"
 S %BLK="/,"_IO
 ;
 D DRV^URID
 ;
 Q 
 ;
DELETE ; QWIK REPORT DEFINITION
 ;
 N DBOPT
 N %NOPRMT N DQTABLE N QRID
 ;
 S DQTABLE="DBTBL5Q" S DBOPT=6
 S QRID=$$FIND^DBSGETID("DBTBL5Q",0) Q:(QRID="") 
 ;
 S %NOPRMT="Q"
 ;
 N d5q S d5q=$$vRCgetRecord0^RecordDBTBL5Q("SYSDEV",QRID,0)
 ;
 ;  #ACCEPT Date=04/30/2008; Pgm=RussellDS; CR=33322; Group=MISMATCH
 N vo5 N vo6 N vo7 N vo8 D DRV^USID(3,"DBTBL5Q",.d5q,.vo5,.vo6,.vo7,.vo8) K vobj(+$G(vo5)) K vobj(+$G(vo6)) K vobj(+$G(vo7)) K vobj(+$G(vo8))
  S:'$D(vobj(d5q,0)) vobj(d5q,0)=$S(vobj(d5q,-2):$G(^DBTBL(vobj(d5q,-3),6,vobj(d5q,-4),0)),1:"")
 ;
 ; PROMPT - ARE YOU SURE
 I $$^DBSMBAR(163)'=2 K vobj(+$G(d5q)) Q 
 ;
 ; DELETE FORMAT INFORMATION
 D vDbDe1()
 ;
 ; DELETE STATISTICS PAGE DATA
 D vDbDe2()
 ;
  K ^DBTBL("SYSDEV",6,QRID)
 ;
 ; DELETE RUN TIME CODE
 I '($P(vobj(d5q,0),$C(124),2)="") D DEL^%ZRTNDEL($P(vobj(d5q,0),$C(124),2))
 ;
 ; Write done
 WRITE !,"QWIK REPORT "_QRID_" DELETED"
 ;
 ; hang for a sec
 HANG 1
 ;
 K vobj(+$G(d5q)) Q 
 ;
COPY ; 
 ;
 N DQSCR N QRSCREEN N RN N SID
 ;
 D INIT(.QRSCREEN)
 ;
 S RN=$$^MSG(7978)
 S DQSCR="^"_QRSCREEN
 ;
 D COPY^DBSUTLQR(DQSCR)
 Q 
 ;
RUN ; Run QWIK Report (Function DBSQRR)
 ;
 N ZQRUN
 N %PAGE N %PG
 N LIB N PGM N QRID
 ;
 S LIB="SYSDEV"
 ;
 S QRID=$$FIND^DBSGETID("DBTBL5Q",0)
 Q:(QRID="") 
 ;
 N d5q S d5q=$$vRCgetRecord0^RecordDBTBL5Q("SYSDEV",QRID,0)
 ;
 S %PAGE=2
 S %PG=1
 ;
 ; Protect ACCESS FILES and DATA ITEMS prompts
 S %O=2
 S ZQRUN=1
 ;
 ;  #ACCEPT Date=04/28/2008; Pgm=RussellDS; CR=33611; Group=MISMATCH
 N vo9 N vo10 N vo11 N vo12 D DRV^USID(2,"DBTBL5Q",.d5q,.vo9,.vo10,.vo11,.vo12) K vobj(+$G(vo9)) K vobj(+$G(vo10)) K vobj(+$G(vo11)) K vobj(+$G(vo12))
  S:'$D(vobj(d5q,0)) vobj(d5q,0)=$S(vobj(d5q,-2):$G(^DBTBL(vobj(d5q,-3),6,vobj(d5q,-4),0)),1:"")
 ;
 I '$$YN^DBSMBAR("",$$^MSG(2445),1) K vobj(+$G(d5q)) Q  ; Run report YES/NO ?
 ;
 S PGM=$P(vobj(d5q,0),$C(124),2) ; Get run-time name
 ;
 I '(PGM="") D ^@PGM K vobj(+$G(d5q)) Q  ; Already compiled
 ;
 D BUILD(QRID)
 ;
 K vobj(+$G(d5q)) Q 
 ;
BUILD(QRID) ; 
 ;
 N X
 ;
 S X=""
 ;
 D COMPILE(QRID)
 ;
 I $$YN^DBSMBAR("",$$^MSG(2445),1)=0 Q 
 ;
 D SYSVAR^SCADRV0()
 D QRPT^URID ; Run report
 ;
 Q 
 ;
COMPILE(QRID) ; Compile QWIK report
 N vTp
 ;
 N ER N seq N lseq
 N pgm N zrid
 ;
 S zrid="QWIK_"_QRID ; Temp report name
 D EXT^DBSRWQR(QRID,.zrid) ; Convert to RW format
 ;
 N dbtbl5q S dbtbl5q=$$vRCgetRecord0^RecordDBTBL5Q("SYSDEV",QRID,0)
  S vobj(dbtbl5q,0)=$G(^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),0))
 S pgm=$P(vobj(dbtbl5q,0),$C(124),2) ; Run-time routine name
 ;
 I (pgm="") D  ; Get next sequence number
 .	;
 .	N DBTBL
 .	;
 .	S DBTBL("SYSDEV",0,"Q")=""
 .	L +DBTBL("SYSDEV",0,"Q"):10
 .	;
 .	N dbtbl0 S dbtbl0=$$vRCgetRecord1^RecordDBTBL0("SYSDEV","Q",0)
 .	S seq=$P(vobj(dbtbl0),$C(124),1)+1
 .  S $P(vobj(dbtbl0),$C(124),1)=seq
 .	S seq=seq+10000
 .	;
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL0(dbtbl0,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbtbl0,-100) S vobj(dbtbl0,-2)=1 TC:vTp  
 .	;
 .	L -DBTBL("SYSDEV",0,"Q") ; R01Qnnnn format
 .	;
 .  K vobj(+$G(dbtbl0)) S dbtbl0=$$vRCgetRecord1^RecordDBTBL0("SYSDEV","L",0)
 .	S lseq=$P(vobj(dbtbl0),$C(124),1)+100
 .	S pgm="R"_$E(lseq,2,3)_"Q"_$E(seq,2,5)
 .	K vobj(+$G(dbtbl0)) Q 
 ;
 N dbtbl5h S dbtbl5h=$$vRCgetRecord1^RecordDBTBL5H("SYSDEV",zrid,0)
  S vobj(dbtbl5h,0)=$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),0))
  S vobj(dbtbl5h,-100,0)="" S $P(vobj(dbtbl5h,0),$C(124),2)=pgm
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL5H(dbtbl5h,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbtbl5h,-100) S vobj(dbtbl5h,-2)=1 TC:vTp  
 ;
 D ^DBSRW(zrid,0) ; Compile report
 I $get(ER)>0 K vobj(+$G(dbtbl5h)),vobj(+$G(dbtbl5q)) Q  ; Query error flag
 ;
  K vobj(+$G(dbtbl5h)) S dbtbl5h=$$vRCgetRecord0^RecordDBTBL5H("SYSDEV",zrid,0)
  S vobj(dbtbl5h,0)=$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),0))
 ;
  K vobj(+$G(dbtbl5q)) S dbtbl5q=$$vRCgetRecord0^RecordDBTBL5Q("SYSDEV",QRID,0)
  S vobj(dbtbl5q,0)=$G(^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),0))
 ;
  S vobj(dbtbl5q,-100,0)="" S $P(vobj(dbtbl5q,0),$C(124),2)=$P(vobj(dbtbl5h,0),$C(124),2) ; Save into QWIK report definition
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL5Q(dbtbl5q,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbtbl5q,-100) S vobj(dbtbl5q,-2)=1 TC:vTp  
 ;
  N V1 S V1=zrid  K ^DBTBL("SYSDEV",5,V1) ; Delete report definition
 ;
 K vobj(+$G(dbtbl5h)),vobj(+$G(dbtbl5q)) Q 
 ;
CMPALL ; Mass recompile QWIK report (function DBSQRB)
 ;
 N CNT
 N QRID
 ;
  N V1 S V1=$J D vDbDe3()
 ;
 S CNT=$$LIST^DBSGETID("DBTBL5Q")
 Q:'CNT 
 ;
 N ds,vos1,vos2,vos3,vos4  N V2 S V2=$J S ds=$$vOpen1()
 ;
 F  Q:'$$vFetch1()  D
 . N tmpdq,vop1 S vop1=$P(ds,$C(9),2),tmpdq=$$vRCgetRecord1Opt^RecordTMPDQ($P(ds,$C(9),1),vop1,1,"")
 .	D COMPILE(vop1)
 . Q 
 ;
  N V3 S V3=$J D vDbDe4()
 ;
 Q 
 ;
PREDI ; PRE-PP FOR DI CHECK
 ;
 S I(3)="@SELDI^DBSFUN(FILES,.X)"
 Q 
 ;
PPDI(X,FID,FILES,I,RM,ER) ; PP FOR DI CHECK
 ;
 N X1 N X2
 ;
 S X=$$vStrTrim(X,0," ")
 ;
 S I(3)=""
 I X'?1"@WPS("1E.E1")" D PPDI2(.X,.RM,FID,FILES,.ER) Q 
 ;
 S X1=$piece(X,"(",2)
 S X1=$piece(X1,")",1)
 S X1=$piece(X1,",",1)
 ;
 ; Invalid document name - ~p1
 CLOSE X1
 S X2=$$FILE^%ZOPEN(X1,"READ",2)
 I '(X2="") D  Q 
 .	S RM=$$^MSG(1317)_" "_X1
 .	S ER=1
 .	Q 
 ;
 CLOSE X1
 ;
 S RM=$$^MSG(8217)_" "_X1 ;  Export completed
 ;
 Q 
 ;
PPDI2(X,RM,FID,FILES,ER) ; 
 ;
 N INCR
 N DFID N NEWX N PFID N SAVX
 ;
 S SAVX=X
 S NEWX=""
 ;
 S PFID=$piece(FILES,",",1)
 S DFID=PFID
 ;
 F INCR=1:1 S X=$piece(SAVX,",",INCR) Q:$piece(SAVX,",",INCR,99)=""  D DFID(.X,.RM,FID,.NEWX,FILES,.ER) Q:ER 
 ;
 ; Invalid data item name or syntax error - ~p1
 I ER D  Q 
 .	S X=SAVX
 .	I ($get(RM)="") S RM=$$^MSG(1301,$piece(SAVX,",",INCR))
 .	Q 
 ;
 S X=$E(NEWX,1,$L(NEWX)-1)
 ;
 Q 
 ;
DFID(X,RM,FID,NEWX,FILES,ER) ; 
 ;
 N ZFLG
 ;
 I ($E(X,1)=""""),($E(X,$L(X))="""") S NEWX=NEWX_X_"," Q  ; "Text"
 ;
 ; Modified the call to DBFID1.
 I '((X?1A.AN)!(X?1"%".AN)!(X["?")) D DFID1(.X,FILES,.NEWX,.ER,.RM) Q 
 ;
 S X=$$^FORMDIPP(X,FILES,.ZFLG)
 ;
 Q:ER 
 ;
 I (X="") S ER=1 Q 
 ;
 I 'ZFLG S X=$piece(X,"]",2) ; Remove [FID] reference
 ;
 D DFID1(.X,FID,.NEWX,.ER,.RM)
 ;
 Q 
 ;
DFID1(STR,FILES,NEWX,ER,RM) ; Error message, if ER = 1   /MECH=REF:W
 ;
 N ptr
 N OPRS N TEST
 ;
 S ER=0
 S NEWX=NEWX_STR_","
 ;
 Q:$$isLit^UCGM(STR)  ; Quoted string or number is OK
 ;
 ; Find and validate all column references.  Build test to validate formulas
 ;
 S TEST=""
 S OPRS="()+-/*#\=_,!&@"
 S ptr=0
 ;
 F  D  Q:(ER!(ptr=0)) 
 .	;
 .	N X
 .	;
 .	S X=$$ATOM^%ZS(STR,.ptr,OPRS)
 .	;
 .	; Column reference
 .	I '((($L(X)=1)&(OPRS[X))!$$isLit^UCGM(X)) D
 ..		;
 ..		N COL N TABLE
 ..		;
 ..		; Reference includes table name ([FID]DI)
 ..		I $E(X,1)="[" D
 ...			S TABLE=$piece($piece(X,"[",2),"]",1)
 ...			S COL=$piece(X,"]",2)
 ...			;
 ...			I '((","_FILES_",")[(","_TABLE_",")) D
 ....				S ER=1
 ....				;
 ....				; Invalid table name - ~p1
 ....				S RM=$$^MSG(1484)
 ....				Q 
 ...			E  I '($D(^DBTBL("SYSDEV",1,TABLE,9,COL))#2) D
 ....				;
 ....				S ER=1
 ....				;
 ....				; Invalid data item ~p1
 ....				S RM=$$^MSG(1298,X)
 ....				Q 
 ...			Q 
 ..		;
 ..		; Otherwise, find which table
 ..		E  D
 ...			N I
 ...			;
 ...			S TABLE=""
 ...			F I=1:1:$L(FILES,",") D  Q:'(TABLE="") 
 ....				N T S T=$piece(FILES,",",I)
 ....				;
 ....				I ($D(^DBTBL("SYSDEV",1,T,9,X))#2) D
 .....					S TABLE=T
 .....					S COL=X
 .....					Q 
 ....				Q 
 ...			;
 ...			I (TABLE="") D
 ....				S ER=1
 ....				;
 ....				; Invalid data item ~p1
 ....				S RM=$$^MSG(1298,X)
 ....				Q 
 ...			Q 
 ..		;
 ..		I 'ER D
 ...			S X="["_TABLE_"]"_COL
 ...			;
 ...			; Replace column references with literal 1 for test
 ...			S TEST=TEST_1
 ...			Q 
 ..		E  S TEST=TEST_X ; Add operator
 ..		Q 
 .	Q 
 ;
 ; Execute TEST string to see if any errors in formula
 I 'ER D
 .	N Z
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 .	;
 .	;   #ACCEPT Date=11/20/05; Pgm= Vinayak Teli; CR=17903
 .	XECUTE "set Z="_TEST
 .	Q 
 ;
 Q 
 ;
ERR ; 
 ;
 N ET
 ;
 D ET^%ZT(.ET)
 ;
 I ET="UNDEFINED" S ER=0 Q 
 S ER=1
 ;
 Q 
 ;
UPDTBL(d5q,QRID) ; 
 N vTp
 ;
 N I N SEQ
 N D6F N FILES N ITEMS N msg
 ;
 N DBTBL6F
 N D6FOLD
 ;
 ; Get any existing field first
 N ds,vos1,vos2,vos3,vos4 S ds=$$vOpen2()
 ;
 S I=0
 F  Q:'$$vFetch2()  D
 .	;
 .	S I=I+1
 .  K vobj(+$G(D6FOLD(I))) S D6FOLD(I)=$$vRCgetRecord1^RecordDBTBL6F($P(ds,$C(9),1),$P(ds,$C(9),2),$P(ds,$C(9),3),1)
 .	Q 
 ;
 ; Get all new fields and merge old if they match
 ;
  S:'$D(vobj(d5q,0)) vobj(d5q,0)=$S(vobj(d5q,-2):$G(^DBTBL(vobj(d5q,-3),6,vobj(d5q,-4),0)),1:"")
 S FILES=$P(vobj(d5q,0),$C(124),1)
 ;
  S:'$D(vobj(d5q,12)) vobj(d5q,12)=$S(vobj(d5q,-2):$G(^DBTBL(vobj(d5q,-3),6,vobj(d5q,-4),12)),1:"")
 I '($P(vobj(d5q,12),$C(124),1)="") S msg=$$^DBSITEM(FILES,$P(vobj(d5q,12),$C(124),1),.D6F)
  S:'$D(vobj(d5q,13)) vobj(d5q,13)=$S(vobj(d5q,-2):$G(^DBTBL(vobj(d5q,-3),6,vobj(d5q,-4),13)),1:"")
 I '($P(vobj(d5q,13),$C(124),1)="") S msg=$$^DBSITEM(FILES,$P(vobj(d5q,13),$C(124),1),.D6F)
  S:'$D(vobj(d5q,14)) vobj(d5q,14)=$S(vobj(d5q,-2):$G(^DBTBL(vobj(d5q,-3),6,vobj(d5q,-4),14)),1:"")
 I '($P(vobj(d5q,14),$C(124),1)="") S msg=$$^DBSITEM(FILES,$P(vobj(d5q,14),$C(124),1),.D6F)
  S:'$D(vobj(d5q,15)) vobj(d5q,15)=$S(vobj(d5q,-2):$G(^DBTBL(vobj(d5q,-3),6,vobj(d5q,-4),15)),1:"")
 I '($P(vobj(d5q,15),$C(124),1)="") S msg=$$^DBSITEM(FILES,$P(vobj(d5q,15),$C(124),1),.D6F)
  S:'$D(vobj(d5q,16)) vobj(d5q,16)=$S(vobj(d5q,-2):$G(^DBTBL(vobj(d5q,-3),6,vobj(d5q,-4),16)),1:"")
 I '($P(vobj(d5q,16),$C(124),1)="") S msg=$$^DBSITEM(FILES,$P(vobj(d5q,16),$C(124),1),.D6F)
  S:'$D(vobj(d5q,17)) vobj(d5q,17)=$S(vobj(d5q,-2):$G(^DBTBL(vobj(d5q,-3),6,vobj(d5q,-4),17)),1:"")
 I '($P(vobj(d5q,17),$C(124),1)="") S msg=$$^DBSITEM(FILES,$P(vobj(d5q,17),$C(124),1),.D6F)
 ;
 S I=0
 S SEQ=""
 F  S SEQ=$order(D6F(SEQ)) Q:(SEQ="")  D
 .	;
 .	S I=I+1
 .  K vobj(+$G(DBTBL6F(I))) S DBTBL6F(I)=$$vcdmNew^RecordDBTBL6F() S vobj(DBTBL6F(I),-3)="SYSDEV" S vobj(DBTBL6F(I),-4)=QRID
 .	;
 .	; Merge old
 .	;   #ACCEPT Date=04/28/2008; Pgm=RussellDS; CR=33611; Group=SCOPE
 .	I ($D(D6FOLD(I))#2),$P(vobj(D6FOLD(I)),$C(124),1)=$piece(D6F(I),"|",1)  K vobj(+$G(DBTBL6F(I))) S DBTBL6F(I)=$$vReCp1(D6FOLD(I))
 .	; New
 .	E  D
 ..		;
 ..	  S $P(vobj(DBTBL6F(I)),$C(124),1)=$piece(D6F(I),"|",1)
 ..	  S $P(vobj(DBTBL6F(I)),$C(124),2)=$piece(D6F(I),"|",2)
 ..	  S $P(vobj(DBTBL6F(I)),$C(124),3)=$piece(D6F(I),"|",3)
 ..	  S $P(vobj(DBTBL6F(I)),$C(124),4)=$piece(D6F(I),"|",4)
 ..	  S $P(vobj(DBTBL6F(I)),$C(124),5)=$piece(D6F(I),"|",5)
 ..	  S $P(vobj(DBTBL6F(I)),$C(124),6)=$piece(D6F(I),"|",6)
 ..	  S $P(vobj(DBTBL6F(I)),$C(124),7)=$piece(D6F(I),"|",7)
 ..		Q 
 .	;
 .  S vobj(DBTBL6F(I),-5)=100+I
 .	; All are new records since will delete old ones
 .	S vobj(DBTBL6F(I),-2)=0
 .	Q 
 ;
 I I<20 D
 .	S %REPEAT=I
 .	;   #ACCEPT Date=04/28/2008; Pgm=RussellDS; CR=33611; Group=MISMATCH
 . N vo17 N vo18 N vo19 N vo20 D DRV^USID(0,"DBTBL6F",.DBTBL6F,.vo17,.vo18,.vo19,.vo20) K vobj(+$G(vo17)) K vobj(+$G(vo18)) K vobj(+$G(vo19)) K vobj(+$G(vo20))
 .	Q 
 E  D
 .	;
 .	S UX=1
 .	S %PAGE=%PAGE+1
 .	S %REPEAT=19
 .	;
 .	;   #ACCEPT Date=04/28/2008; Pgm=RussellDS; CR=33611; Group=MISMATCH
 . N vo21 N vo22 N vo23 N vo24 D DRV^USID(0,"DBTBL6F",.DBTBL6F,.vo21,.vo22,.vo23,.vo24) K vobj(+$G(vo21)) K vobj(+$G(vo22)) K vobj(+$G(vo23)) K vobj(+$G(vo24))
 .	Q 
 ;
 I VFMQ="Q" D vKill1(""),vKill2("") Q 
 ;
 ; Save Main Screen data
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL5Q(d5q,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(d5q,-100) S vobj(d5q,-2)=1 TC:vTp  
 ;
 ; Save Second Screen data - delete old record first
 D vDbDe5()
 S I=""
 F  S I=$order(DBTBL6F(I)) Q:(I="")  S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL6F(DBTBL6F(I),"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(DBTBL6F(I),-100) S vobj(DBTBL6F(I),-2)=1 TC:vTp  
 ;
 D vKill1(""),vKill2("") Q 
 ;
UPDSTAT(d5q,QRID) ; 
 N vTp
 ;
 N I
 ;
 N D6S
 ;
 F I=21:1:40  K vobj(+$G(D6S(I-20))) S D6S(I-20)=$$vRCgetRecord1^RecordDBTBL6SQ("SYSDEV",QRID,I,0)
 ;
 S %PG=%PAGE
 S %REPEAT=20
 ;
 ;  #ACCEPT Date=04/30/2008; Pgm=RussellDS; CR=33611; Group=MISMATCH
 N vo25 N vo26 N vo27 N vo28 D DRV^USID(0,"DBTBL6S",.D6S,.vo25,.vo26,.vo27,.vo28) K vobj(+$G(vo25)) K vobj(+$G(vo26)) K vobj(+$G(vo27)) K vobj(+$G(vo28))
 ;
 I VFMQ="Q" D vKill3("") Q 
 ;
 ; Delete existing entries
 D vDbDe6()
 ;
 ; Avoid scope warning on D6S() may not have been instantiated
 ;  #ACCEPT Date=04/30/2008; Pgm=RussellDS; CR=33611; Group=SCOPE
 F I=1:1:20 I '($P(vobj(D6S(I)),$C(124),4)="") D
 .	;
 .	S vobj(D6S(I),-2)=0
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL6SQ(D6S(I),"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(D6S(I),-100) S vobj(D6S(I),-2)=1 TC:vTp  
 .	Q 
 ;
 D vKill3("") Q 
 ;
PPQ(fDBTBL5Q,FILES,PFID,X,RM,ER) ; Post Processor for Query Lines in Screen DBTBL5Q
  S:'$D(vobj(fDBTBL5Q,0)) vobj(fDBTBL5Q,0)=$S(vobj(fDBTBL5Q,-2):$G(^DBTBL(vobj(fDBTBL5Q,-3),6,vobj(fDBTBL5Q,-4),0)),1:"")
  S:'$D(vobj(fDBTBL5Q,2)) vobj(fDBTBL5Q,2)=$S(vobj(fDBTBL5Q,-2):$G(^DBTBL(vobj(fDBTBL5Q,-3),6,vobj(fDBTBL5Q,-4),2)),1:"")
 ;
 N ZX
 ;
 I $P(vobj(fDBTBL5Q,0),$C(124),13) D  Q  ; MSQL query syntax
 .	;
 .	; Check SQL syntax
 .	I '($P(vobj(fDBTBL5Q,2),$C(124),1)="") D ^SQLQ($P(vobj(fDBTBL5Q,2),$C(124),1),$P(vobj(fDBTBL5Q,0),$C(124),1))
 .	I ER,(RM="") S RM="Invalid MSQL query syntax"
 .	Q 
 ;
 ; DATA-QWIK query syntax
 ;
 I X="" Q 
 ;
 S FILES=$P(vobj(fDBTBL5Q,0),$C(124),1)
 S PFID=$piece(FILES,",",1)
 ;
 S ZX=X
 ;
 D ^DBSQRY
 ;
 S X=ZX
 ;
 Q 
 ;
INIT(QRSCREEN) ; initialize the screen objects - call Usid
 ;
 N PGM N SID
 ;
 S SID="DBTBL5Q"
 D ^USID
 S QRSCREEN=PGM_"(%O,.d5q)"
 Q 
 ;
FIXFMT(INPUT,TABLES,NLEN,NDEC,NFMT) ; Format  /NOREQ/MECH=REFNAM:W
 ;
 N ptr
 N atom N in N return N tok
 ;
 S return=""
 ;
 S (NLEN,NDEC)=0
 S NFMT=""
 ;
 S in=$$TOKEN^%ZS(INPUT,.tok,"""")
 ;
 S ptr=0
 F  S atom=$$ATOM^%ZS(in,.ptr,"=_<>()+-*#\/",tok,1) D  Q:(ptr=0) 
 .	;
 .	I (",=,_,<,>,(,),+,-,*,#,\,/,"[(","_atom_",")) S return=return_atom
 .	E  I (atom=+atom) S return=return_atom
 .	; Tokenized string
 .	E  I ($E(atom,1,$L($char(0)))=$char(0)) S return=return_atom
 .	; Already in right form
 .	E  I (atom?1"["1AP.AN1"]"1AP.AN) S return=return_atom
 .	; Intrinsic or extrinsic function call
 .	E  I ($E(atom,1)="$") S return=return_atom
 .	; See if in one of the tables and replace
 .	E  D
 ..		;
 ..		N isFOUND S isFOUND=0
 ..		N i
 ..		N table
 ..		;
 ..		F i=1:1:$S((TABLES=""):0,1:$L(TABLES,",")) D
 ...			;
 ...			S table=$piece(TABLES,",",i)
 ...			;
 ...			N rs,vos1,vos2,vos3,vos4,vos5  N V1,V2 S V1=table,V2=atom S rs=$$vOpen3()
 ...			;
 ...			I $$vFetch3() D
 ....				;
 ....				S isFOUND=1
 ....				S return=return_"["_table_"]"_atom
 ....				;
 ....    I (NFMT="") S NFMT=$P(rs,$C(9),2)
 ....    I ($P(rs,$C(9),1)>NLEN) S NLEN=$P(rs,$C(9),1)
 ....    I ($P(rs,$C(9),3)>NDEC) S NDEC=$P(rs,$C(9),3)
 ....    I ($P(rs,$C(9),2)="$") S NFMT="$"
 ....				Q 
 ...   Q 
 ..		;
 ..		I 'isFOUND D
 ...			;
 ...			S return=""
 ...			S ptr=0
 ...			Q 
 ..		Q 
 .	Q 
 ;
 I '(return="") S return=$$UNTOK^%ZS(return,tok)
 ;
 Q return
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61453^45871^Dan Russell^16715" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM DBTBL6F WHERE QRID=:QRID
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2 N v3
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4,vos5 S vRs=$$vOpen4()
 F  Q:'$$vFetch4()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^DBTBL(v1,6,v2,v3)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe2() ; DELETE FROM DBTBL6SQ WHERE QID=:QRID
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2 N v3
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4,vos5 S vRs=$$vOpen5()
 F  Q:'$$vFetch5()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^DBTBL(v1,6,v2,v3)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe3() ; DELETE FROM TMPDQ WHERE PID=:V1
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
vDbDe4() ; DELETE FROM TMPDQ WHERE PID=:V3
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen7()
 F  Q:'$$vFetch7()  D
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
vStrTrim(object,p1,p2) ; String.trim
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I p1'<0 S object=$$RTCHR^%ZFUNC(object,p2)
 I p1'>0 F  Q:$E(object,1)'=p2  S object=$E(object,2,1048575)
 Q object
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe5() ; DELETE FROM DBTBL6F WHERE LIBS='SYSDEV' AND QRID=:QRID
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2 N v3
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen8()
 F  Q:'$$vFetch8()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^DBTBL(v1,6,v2,v3)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe6() ; DELETE FROM DBTBL6SQ WHERE LIBS='SYSDEV' AND QID=:QRID
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2 N v3
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen9()
 F  Q:'$$vFetch9()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^DBTBL(v1,6,v2,v3)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
 ;
vKill1(ex1) ; Delete objects D6FOLD()
 ;
 N n1 S (n1)=""
 F  S n1=$O(D6FOLD(n1)) Q:n1=""  K:'((n1=ex1)) vobj(D6FOLD(n1))
 Q
 ;
vKill2(ex1) ; Delete objects DBTBL6F()
 ;
 N n1 S (n1)=""
 F  S n1=$O(DBTBL6F(n1)) Q:n1=""  K:'((n1=ex1)) vobj(DBTBL6F(n1))
 Q
 ;
vKill3(ex1) ; Delete objects D6S()
 ;
 N n1 S (n1)=""
 F  S n1=$O(D6S(n1)) Q:n1=""  K:'((n1=ex1)) vobj(D6S(n1))
 Q
 ;
vOpen1() ; PID,ELEMENT FROM TMPDQ WHERE PID=:V2 ORDER BY ELEMENT ASC
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V2)
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
 I vos1=0 S ds="" Q 0
 ;
 S ds=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen2() ; LIBS,QRID,SEQ FROM DBTBL6F WHERE LIBS='SYSDEV' AND QRID=:QRID ORDER BY SEQ ASC
 ;
 ;
 S vos1=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos1=0 Q
vL2a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(QRID) I vos3="" G vL2a0
 S vos4=100
vL2a4 S vos4=$O(^DBTBL("SYSDEV",6,vos3,vos4),1) I vos4="" G vL2a0
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
vOpen3() ; LEN,TYP,DEC FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1 AND DI=:V2
 ;
 ;
 S vos1=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos1=0 Q
vL3a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL3a0
 S vos4=$G(V2) I vos4="" G vL3a0
 I '($D(^DBTBL("SYSDEV",1,vos3,9,vos4))#2) G vL3a0
 Q
 ;
vFetch3() ;
 ;
 ;
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos1=100
 S vos5=$G(^DBTBL("SYSDEV",1,vos3,9,vos4))
 S rs=$P(vos5,"|",2)_$C(9)_$P(vos5,"|",9)_$C(9)_$P(vos5,"|",14)
 S vos1=0
 ;
 Q 1
 ;
vOpen4() ; LIBS,QRID,SEQ FROM DBTBL6F WHERE QRID=:QRID
 ;
 ;
 S vos1=2
 D vL4a1
 Q ""
 ;
vL4a0 S vos1=0 Q
vL4a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(QRID) I vos3="" G vL4a0
 S vos4=""
vL4a4 S vos4=$O(^DBTBL(vos4),1) I vos4="" G vL4a0
 S vos5=100
vL4a6 S vos5=$O(^DBTBL(vos4,6,vos3,vos5),1) I vos5="" G vL4a4
 Q
 ;
vFetch4() ;
 ;
 ;
 I vos1=1 D vL4a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=$S(vos4=vos2:"",1:vos4)_$C(9)_vos3_$C(9)_$S(vos5=vos2:"",1:vos5)
 ;
 Q 1
 ;
vOpen5() ; LIBS,QID,SEQ FROM DBTBL6SQ WHERE QID=:QRID
 ;
 ;
 S vos1=2
 D vL5a1
 Q ""
 ;
vL5a0 S vos1=0 Q
vL5a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(QRID) I vos3="" G vL5a0
 S vos4=""
vL5a4 S vos4=$O(^DBTBL(vos4),1) I vos4="" G vL5a0
 S vos5=20
vL5a6 S vos5=$O(^DBTBL(vos4,6,vos3,vos5),1) I vos5=""!(vos5'<41) G vL5a4
 Q
 ;
vFetch5() ;
 ;
 ;
 I vos1=1 D vL5a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=$S(vos4=vos2:"",1:vos4)_$C(9)_vos3_$C(9)_$S(vos5=vos2:"",1:vos5)
 ;
 Q 1
 ;
vOpen6() ; PID,ELEMENT FROM TMPDQ WHERE PID=:V1
 ;
 ;
 S vos1=2
 D vL6a1
 Q ""
 ;
vL6a0 S vos1=0 Q
vL6a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1)
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
 ;
vOpen7() ; PID,ELEMENT FROM TMPDQ WHERE PID=:V3
 ;
 ;
 S vos1=2
 D vL7a1
 Q ""
 ;
vL7a0 S vos1=0 Q
vL7a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V3)
 S vos4=""
vL7a4 S vos4=$O(^TEMP(vos3,vos4),1) I vos4="" G vL7a0
 Q
 ;
vFetch7() ;
 ;
 ;
 I vos1=1 D vL7a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen8() ; LIBS,QRID,SEQ FROM DBTBL6F WHERE LIBS='SYSDEV' AND QRID=:QRID
 ;
 ;
 S vos1=2
 D vL8a1
 Q ""
 ;
vL8a0 S vos1=0 Q
vL8a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(QRID) I vos3="" G vL8a0
 S vos4=100
vL8a4 S vos4=$O(^DBTBL("SYSDEV",6,vos3,vos4),1) I vos4="" G vL8a0
 Q
 ;
vFetch8() ;
 ;
 ;
 I vos1=1 D vL8a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs="SYSDEV"_$C(9)_vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen9() ; LIBS,QID,SEQ FROM DBTBL6SQ WHERE LIBS='SYSDEV' AND QID=:QRID
 ;
 ;
 S vos1=2
 D vL9a1
 Q ""
 ;
vL9a0 S vos1=0 Q
vL9a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(QRID) I vos3="" G vL9a0
 S vos4=20
vL9a4 S vos4=$O(^DBTBL("SYSDEV",6,vos3,vos4),1) I vos4=""!(vos4'<41) G vL9a0
 Q
 ;
vFetch9() ;
 ;
 ;
 I vos1=1 D vL9a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs="SYSDEV"_$C(9)_vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vReCp1(v1) ; RecordDBTBL6F.copy: DBTBL6F
 ;
 Q $$copy^UCGMR(D6FOLD(I))
 ;
vCatch1 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 S ER=1
 ;
 ; Invalid format ~p1
 S RM=$$^MSG(1350,STR)
 D ZX^UCGMR(voxMrk) Q 
