 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSTBLM ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSTBLM(TABLETYP) ; System, User, and Common Table Maintenance
 ;
 ; Compile procedure DBSTBLMA (DBSTBLMB Builder)
 ;
 ; Generated DBSTBLMB
 ;
 ; Start of main code section -----------------------------------------
 ;
 ; I18N=QUIT
 ;
 N tbllist N VFMQ
 ;
 I '($D(%FN)#2) S %FN="UTBL001"
 ;
 I ($get(%UCLS)="") D
 .	;
 .	N scau S scau=$G(^SCAU(1,%UID))
 .	;
 .	S %UCLS=$P(scau,$C(124),5)
 .	I (%UCLS="") S %UCLS="NOCLASS"
 . Q 
 ;
 I ($get(TABLETYP)="") S TABLETYP="UTBL"
 ;
 ; Please Wait ...
 WRITE $$MSG^%TRMVT($$^MSG(5624),0,0)
 ;
 ; Create look-up table
 D LOOKUP(TABLETYP,.tbllist)
 ;
 F  D  Q:VFMQ="Q" 
 .	;
 .	N OLNTB
 .	N %NOPRMT N %READ N %TAB N fid N HDG N TABLE
 .	;
 .	S ER=0
 .	S TABLE=""
 .	;
 .	;  Get table name
 .	S HDG="Table         File Name           Description"
 .	;
 .	S %NOPRMT="F"
 .	S OLNTB=30
 .	;
 .	I TABLETYP="UTBL" S %TAB("TABLE")=".TABLE3"
 .	E  I TABLETYP="STBL" S %TAB("TABLE")=".FILENAMES"
 .	E  S %TAB("TABLE")=".FILENAMEC"
 .	;
 .	S %TAB("TABLE")=%TAB("TABLE")_"/TYP=T/TBL=""tbllist(/RH="_HDG_"""/XPP=D TABLEVAL^DBSTBLM/REQ"
 .	;
 .	S %READ="@@%FN,,TABLE,"
 .	D ^UTLREAD Q:VFMQ="Q" 
 .	;
 .	S fid=$piece(tbllist(TABLE),"|",2)
 .	;
 .	D DBEENTRY(fid,0)
 .	Q 
 ;
 Q 
 ;
LOOKUP(TABLETYP,tbllist) ; 
 N vpc
 ;
 N tblcnt
 ;
 N ds,vos1,vos2,vos3,vos4,vos5,vos6,vos7,vOid S ds=$$vOpen1()
 ;
 F  Q:'$$vFetch1()  D
 .	;
 .	N desc N fid N key1
 .	;
 . N dbtbl1,vop1,vop2,vop3 S vop1=$P(ds,$C(9),1),vop2=$P(ds,$C(9),2),dbtbl1=$$vRCgetRecord1Opt^RecordDBTBL1(vop1,vop2,1,"")
 .	 S vop3=$G(^DBTBL(vop1,1,vop2,16))
 .	;
 .	S key1=$piece($P(vop3,$C(124),1),",",1)
 .	;
 . S vpc='$$isLit^UCGM(key1) Q:vpc  ; First key must be literal
 .	;
 .	S key1=$$QSUB^%ZS(key1,"""")
 .	;
 .	S fid=vop2
 .	;
 .	S desc=fid_$J(" ",(20-$L(fid)))_$P(dbtbl1,$C(124),1)_"|"_fid
 .	;
 .	I '($D(tblcnt(key1))#2) D  ; First entry
 ..		S tbllist(key1)=desc
 ..		S tblcnt(key1)=0
 ..		Q 
 .	;
 .	E  D
 ..		;
 ..		I 'tblcnt(key1) D  ; Move first entry
 ...			S tbllist(key1_"_1")=tbllist(key1)
 ...			K tbllist(key1)
 ...			S tblcnt(key1)=1
 ...			Q 
 ..		;
 ..		S tblcnt(key1)=tblcnt(key1)+1
 ..		S tbllist(key1_"_"_tblcnt(key1))=desc
 ..		Q 
 . Q 
 ;
 S tbllist=TABLETYP
 ;
 Q 
 ;
LOADTA(TABLETYP) ; Load lookup info into temporary table
 N vpc,vTp
 ;
  K ^TMP($J)
 ;
 N ds,vos1,vos2,vos3,vos4,vos5 S ds=$$vOpen2()
 ;
 F  Q:'$$vFetch2()  D
 .	;
 .	N key1
 .	;
 . N dbtbl1,vop1,vop2,vop3 S vop1=$P(ds,$C(9),1),vop2=$P(ds,$C(9),2),dbtbl1=$$vRCgetRecord1Opt^RecordDBTBL1(vop1,vop2,1,"")
 .	 S vop3=$G(^DBTBL(vop1,1,vop2,16))
 .	;
 .	S key1=$piece($P(vop3,$C(124),1),",",1)
 .	;
 . S vpc='$$isLit^UCGM(key1) Q:vpc  ; First key must be literal
 .	;
 .	S key1=$$QSUB^%ZS(key1,"""")
 .	;
 .	 N V1,V2 S V1=$J,V2=key1 I '($D(^TMP(V1,V2))#2) D
 ..		;
 ..		N tlookup S tlookup=$$vcdmNew^RecordTLOOKUP() S vobj(tlookup,-3)=$J S vobj(tlookup,-4)=key1
 ..		;
 ..	  S $P(vobj(tlookup),$C(124),1)=vop2_$J(" ",(20-$L(vop2)))_$P(dbtbl1,$C(124),1)
 ..	  S $P(vobj(tlookup),$C(124),2)=vop2
 ..		;
 ..	 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordTLOOKUP(tlookup,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(tlookup,-100) S vobj(tlookup,-2)=1 TC:vTp  
 ..		K vobj(+$G(tlookup)) Q 
 . Q 
 ;
 Q 
 ;
DBEENTRY(fid,fromFunc) ; 
 ;
  S ER=0
  S RM=""
 ;
 N screen
 ;
 N dbtbl1 S dbtbl1=$$vRCgetRecord0^RecordDBTBL1("SYSDEV",fid,0)
  S vobj(dbtbl1,16)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),16))
  S vobj(dbtbl1,22)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),22))
 ;
 I fromFunc D TABLEVER(fid) K:ER vobj(+$G(dbtbl1)) Q:ER 
 ;
 I ($P(vobj(dbtbl1,16),$C(124),1)="") D  K vobj(+$G(dbtbl1)) Q 
 .	S ER=1
 .	; Invalid file structure
 .	S RM=$$^MSG(5531)
 .	Q 
 ;
 S screen=$P(vobj(dbtbl1,22),$C(124),8)
 ;
 I screen="INDEX" D  K vobj(+$G(dbtbl1)) Q 
 .	S ER=1
 .	; This is an index file
 .	S RM=$$^MSG(3753)
 .	Q 
 ;
 I '(screen="") F  Q:'$$SCREEN(.dbtbl1) 
 E  D ^DBSEDIT("",fid)
 ;
 K vobj(+$G(dbtbl1)) Q 
 ;
TABLEVAL ; Table name Post-Processor
 ;
 N fid
 ;
 S fid=$piece($get(tbllist(X)),"|",2)
 ;
 D TABLEVER(fid,tbllist,X)
 ;
 Q 
 ;
TABLEVER(fid,TABLETYP,INPUT) ; 
 ;
 N P1
 ;
 ; Invalid table name - ~p1
 I fid="" S ER=1 S RM=$$^MSG(1484,INPUT) Q 
 ;
 N dbtbl1 S dbtbl1=$$vRCgetRecord0^RecordDBTBL1("SYSDEV",fid,0)
  S vobj(dbtbl1,0)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),0))
  S vobj(dbtbl1,16)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),16))
 ;
 I '($D(TABLETYP)#2) S TABLETYP=$P(vobj(dbtbl1,0),$C(124),1)
 ;
 ; Validate file name ( user, system, common table)
 I '((","_"CTBL,STBL,UTBL"_",")[(","_TABLETYP_",")) D  K vobj(+$G(dbtbl1)) Q 
 .	S ER=1
 .	; Invalid table value ~p1
 .	S RM=$$^MSG(1485,fid)
 .	Q 
 ;
 I $P(vobj(dbtbl1,0),$C(124),1)'=TABLETYP D  K vobj(+$G(dbtbl1)) Q 
 .	S ER=1
 .	; Invalid table value ~p1
 .	S RM=$$^MSG(1485,fid)
 .	Q 
 ;
 S P1=$piece($P(vobj(dbtbl1,16),$C(124),1),",",1)
 ;
 I '$$isLit^UCGM(P1) D  K vobj(+$G(dbtbl1)) Q 
 .	S ER=1
 .	; User is not allowed access to this table [not literal key]
 .	S RM=$$^MSG(2859)
 .	Q 
 ;
 D CHKACCES(TABLETYP,.dbtbl1,0) K:ER vobj(+$G(dbtbl1)) Q:ER 
  S:'$D(vobj(dbtbl1,22)) vobj(dbtbl1,22)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),22)),1:"")
 ;
 ; If data entry pre-processor, execute it
 ;  #ACCEPT DATE=05/27/04; PGM=Dan Russell; CR=unknown
 I '($P(vobj(dbtbl1,22),$C(124),5)="") XECUTE $P(vobj(dbtbl1,22),$C(124),5)
 ;
 K vobj(+$G(dbtbl1)) Q 
 ;
SCREEN(dbtbl1) ; Call defined screen to maintain this table
 N vpc
 ;
  S ER=0
 ;
 N I N keycnt N OLNTB N vmode
 N %NOPRMT N %READ N %TAB N acckeys N fid N KEY N keys N MSG N msghdr N screen N VFMQ
 ;
 ; If screen has not been converted to PSL, won't work in non-GT.M db
  S:'$D(vobj(dbtbl1,22)) vobj(dbtbl1,22)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),22)),1:"")
 S screen=$P(vobj(dbtbl1,22),$C(124),8)
 ;
 N dbtbl2,vop1,vop2,vop3 S vop1="SYSDEV",vop2=screen,dbtbl2=$$vRCgetRecord0Opt^RecordDBTBL2("SYSDEV",screen,0,"")
  S vop3=$G(^DBTBL(vop1,2,vop2,0))
 ;
 I '$P(vop3,$C(124),22),$$rdb^UCDB D  Q 0
 .	S ER=1
 .	S RM="Screen "_screen_" must be converted to PSL to work for table maintenance"
 .	Q 
 ;
 S fid=vobj(dbtbl1,-4)
 ;
 ; File ~p1 is restricted
 I $P(vobj(dbtbl1,22),$C(124),9) S ER=1 S RM=$$^MSG(5634,fid)
 ;
 ; Get access keys
 S keys=""
  S:'$D(vobj(dbtbl1,16)) vobj(dbtbl1,16)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),16)),1:"")
 S keycnt=$$GETKEYS($P(vobj(dbtbl1,16),$C(124),1),.keys)
 ;
 ; Build UTLREAD info - prompt for primary keys
 S msghdr="["_fid_"] "_$P(vobj(dbtbl1),$C(124),1)
 ;
 S %READ="@msghdr/REV/CEN,,"
 ;
 F I=1:1:keycnt D
 .	;
 .	N size
 .	N key N lookup N X
 .	;
 .	S key=keys(I)
 .	;
 .	N dbtbl1d S dbtbl1d=$$vRCgetRecord0Opt^RecordDBTBL1D("SYSDEV",fid,key,0,"")
 .	;
 .	S size=$P(dbtbl1d,$C(124),19)
 .	I (size="") S size=$P(dbtbl1d,$C(124),2)
 .	;
 .	S X="/DES="_$$QADD^%ZS($P(dbtbl1d,$C(124),10),"""")_"/TYP="_$P(dbtbl1d,$C(124),9)_"/LEN="_$P(dbtbl1d,$C(124),2)
 .	S X=X_"/SIZ="_size
 .	;
 .	I I=keycnt S X=X_"/XPP=do LSTKEYPP^DBSTBLM("""_fid_""")"
 .	E  D
 ..		S X=X_"/XPP=set KEY"_I_"=X,"_key_"=X"
 ..		I '($P(dbtbl1d,$C(124),30)="") S X=X_" "_$P(dbtbl1d,$C(124),30)
 ..		Q 
 .	;
 .	I '($P(dbtbl1d,$C(124),29)="") S X=X_"/XPR="_$P(dbtbl1d,$C(124),29)
 .	;
 .	S lookup=$P(dbtbl1d,$C(124),5)
 .	;
 .	; Build lookup syntax
 .	I (lookup="") D
 ..		;
 ..		N J
 ..		N QRY S QRY=":QU """
 ..		;
 ..		S X=X_"/TBL=["_fid_"]"
 ..		;
 ..		F J=1:1:I-1 D
 ...			S QRY=QRY_"["_fid_"]"_keys(J)_"=<<KEY"_J_">>"
 ...			I J'=(I-1) S QRY=QRY_" AND "
 ...			Q 
 ..		;
 ..		S X=X_QRY_""":NOVAL"
 ..		Q 
 .	E  D
 ..		S X=X_"/TBL="_lookup
 ..		I $$vStrLike(lookup,"%["_fid_"]%","") S X=X_":NOVAL"
 ..		Q 
 .	;
 .	I '($P(dbtbl1d,$C(124),12)="") S X=X_"/MIN="_$P(dbtbl1d,$C(124),12)
 .	I '($P(dbtbl1d,$C(124),13)="") S X=X_"/MAX="_$P(dbtbl1d,$C(124),13)
 .	I '($P(dbtbl1d,$C(124),14)="") S X=X_"/DEC="_$P(dbtbl1d,$C(124),14)
 .	I '($P(dbtbl1d,$C(124),6)="") S X=X_"/PAT="_$P(dbtbl1d,$C(124),6)
 .	;
 .	S X=X_"/REQ"
 .	;
 .	S %TAB("KEY("_I_")")=X
 .	S KEY(I)=""
 .	S %READ=%READ_"KEY("_I_"),"
 . Q 
 ;
 ; Delete prompt
 S %TAB("vmode")=".FUN34/NOREQ/XPP=D VPOST1^DBSTBLM("""_fid_""")"
 ;
 S %READ=%READ_",vmode,"
 S %NOPRMT="F"
 S vmode=0
 S OLNTB=30
 ;
 D ^UTLREAD S vpc=VFMQ="Q" Q:vpc 0
 ;
 ; Set process mode
 I vmode D  Q:ER 0
 .	;
 .	; Deletion is restricted
 .	I $P(vobj(dbtbl1,22),$C(124),10) S ER=1 S RM=$$^MSG(806)
 .	E  S %O=3
 .	Q 
 E  D
 .	N I
 .	N collist N where
 .	;
 .	S collist=""
 .	S where=""
 .	;
 .	F I=1:1:keycnt D
 ..		S collist=collist_keys(I)_","
 ..		S where=where_keys(I)_"='"_KEY(I)_"' AND "
 ..		Q 
 .	S collist=$E(collist,1,$L(collist)-1)
 .	S where=$E(where,1,$L(where)-5)
 .	;
 .	I $$DYNSEL(collist,fid,where,.KEY) S %O=1 ; Modify
 .	E  S %O=0 ; Create
 .	Q 
 ;
 ; Otherwise, need to deal with old screens via fsn
 ; REMOVE THIS CODE ONCE ALL *TBL SCREENS CONVERTED TO PSL
 I '$P(vop3,$C(124),22) D
 .	;
 .	N %PAGE N %PG N I
 .	N fsn N PGM N SID N UX N VFSN
 .	;
 .	 S:'$D(vobj(dbtbl1,12)) vobj(dbtbl1,12)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),12)),1:"")
 .	S fsn=$P(vobj(dbtbl1,12),$C(124),1)
 .	;
 .	;   #ACCEPT DATE=09/21/04; PGM=Dan Russell; CR=unknown
 .	N @fsn
 .	;
 .	; Protect key names and set values
 .	;   #ACCEPT DATE=09/21/04; PGM=Dan Russell; CR=unknown
 .	;*** Start of code by-passed by compiler
 .	for I=1:1:keycnt new @keys(I) set @keys(I)=KEY(I)
 .	;*** End of code by-passed by compiler ***
 .	;
 .	S SID=screen ; Required by USID
 .	;
 .	D ^USID
 .	;   #ACCEPT DATE=05/27/04; PGM=Dan Russell; CR=unknown
 .	D ^@PGM ; Screen will load data
 .	Q:ER!(VFMQ="Q") 
 .	;
 .	D EXT^DBSFILER(fid,%O) ; Save data
 .	Q 
 ;
 ; Call ^DBSTBLMB for screens converted to PSL
 E  D
 .	;
 .	S RM=$$^DBSTBLMB(%O,.dbtbl1,.KEY)
 .	I '(RM="") S ER=1
 .	Q 
 ;
 Q:ER 0
 ;
 ; Generate bottom of screen prompt to continue or not
 ;
 ; Created,Modified,Displayed,Deleted,Printed
 I VFMQ'="Q" S MSG=$$^MSG(648)
 ; not Created,not Modified,not Displayed,not Deleted,not Printed
 E  S MSG=$$^MSG(8259)
 ;
 S MSG=$piece(MSG,",",%O+1)
 ; 5652 = Record ~p1.  ~p2 -- 603 = Continue?
 S MSG=$$^MSG(5652,MSG,$$^MSG(603))
 ;
 ; Display result and prompt to continue
 Q $$YN^DBSMBAR(" ",MSG,1)
 ;
LSTKEYPP(fid) ; Last Key Post-Processor
 N vpc
 ;
 N exists
 N keycnt
 N global N keys N SAVX N select N where
 ;
 Q:(X="")!(X="?") 
 ;
 S ER=0
 S RM=""
 ;
 N dbtbl1 S dbtbl1=$$vRCgetRecord0^RecordDBTBL1("SYSDEV",fid,0)
  S vobj(dbtbl1,0)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),0))
 ;
 S global=$P(vobj(dbtbl1,0),$C(124),1)
 ;
 S vpc='((","_"CTBL,STBL,UTBL"_",")[(","_global_",")) K:vpc vobj(+$G(dbtbl1)) Q:vpc 
 ;
 D CHKACCES(global,.dbtbl1,0) K:ER vobj(+$G(dbtbl1)) Q:ER 
  S:'$D(vobj(dbtbl1,16)) vobj(dbtbl1,16)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),16)),1:"")
 ;
 I global'="STBL" D  K:ER vobj(+$G(dbtbl1)) Q:ER 
 .	;
 .	N lastkey
 .	;
 .	S lastkey=$piece($P(vobj(dbtbl1,16),$C(124),1),",",$L($P(vobj(dbtbl1,16),$C(124),1),","))
 .	;
 .	N dbtbl1d S dbtbl1d=$$vRCgetRecord0Opt^RecordDBTBL1D("SYSDEV",fid,lastkey,0,"")
 .	;
 .	I '($P(dbtbl1d,$C(124),30)="") D
 ..		;
 ..		; execute post-processor in data item definition
 ..		;    #ACCEPT Date=09/21/04; PGM=Dan Russell; CR=unknown
 ..		XECUTE $P(dbtbl1d,$C(124),30)
 ..		Q 
 . Q 
 ;
 ; Check against look-up table first
 I '(I(3)=""),$$VER^DBSTBL(I(3),X,"T")="" D  K vobj(+$G(dbtbl1)) Q 
 .	S ER=1
 .	; Invalid table value ~p1
 .	S RM=$$^MSG(1485,X)
 .	Q 
 ;
 ; Determine whether record already exists, or not
 S keycnt=$$GETKEYS($P(vobj(dbtbl1,16),$C(124),1),.keys,.select,.where)
 ;
 ; Replace last key with X (input to screen)
 S where=$$vStrRep(where,":KEY("_keycnt_")",":X",0,0,"")
 ;
 ;  #ACCEPT Date=09/21/04; PGM=Dan Russell; CR=unknown
 S exists=$$DYNSEL(select,fid,where,.KEY)
 ;
 S SAVX=X ; Protect X from DBSMACRO
 ;
 I 'exists D  ; Record does not exist
 .	;
 .	N create
 .	;
 .	D PROTECT^DBSMACRO("@vmode") ; Protect delete prompt
 .	;
 .	; Create new record
 .	S create=$$YN^DBSMBAR("",$$^MSG(5518),1)
 .	I 'create S ER=1
 .	Q 
 ;
 E  D UNPROT^DBSMACRO("@vmode") ; Unprotect delete prompt
 ;
 S X=SAVX
 ;
 K vobj(+$G(dbtbl1)) Q 
 ;
VPOST1(fid) ; Post processor for operating mode
 ;
 Q:'X 
 ;
 N dbtbl1 S dbtbl1=$$vRCgetRecord0^RecordDBTBL1("SYSDEV",fid,0)
  S vobj(dbtbl1,22)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),22))
  S vobj(dbtbl1,0)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),0))
 ;
 I $P(vobj(dbtbl1,22),$C(124),10) D  K vobj(+$G(dbtbl1)) Q 
 .	S ER=1
 .	; Deletion is restricted
 .	S RM=$$^MSG(806)
 .	Q 
 ;
 D CHKACCES($P(vobj(dbtbl1,0),$C(124),1),.dbtbl1,3) K:ER vobj(+$G(dbtbl1)) Q:ER  ; Check access rights for delete
 ;
 I $$LOWERLVL^DBSTBLMB(fid,.KEY) D
 .	S ER=1
 .	; Delete Lower Level Data Entries First
 .	S RM=$$^MSG(8425)
 .	Q 
 ;
 K vobj(+$G(dbtbl1)) Q 
 ;
INTGRE ; Table Integrate Check
 N vTp
 ;
 ; Called by function TBLINT to find C-S-UTBL tables with same global,
 ; same first key, and same number of access keys
 ;
 N RID N TABLETYP N TMP
 ;
  K ^TMP($J)
 ;
 ; Please Wait ...
 WRITE $$MSG^%TRMVT($$^MSG(5624),0,0)
 ;
 ; load the global to local variable
 F TABLETYP="CTBL","STBL","UTBL" D
 .	;
 .	N CNT S CNT=0
 .	;
 .	N rs,vos1,vos2,vos3,vos4,vos5 S rs=$$vOpen3()
 .	;
 .	F  Q:'$$vFetch3()  D
 ..		;
 ..		N keycnt
 ..		N fid N acckeys N key1
 ..		;
 ..  S fid=$P(rs,$C(9),1)
 ..  S acckeys=$P(rs,$C(9),2)
 ..		;
 ..		S key1=$piece(acckeys,",",1)
 ..		Q:'$$isLit^UCGM(key1)  ; Only care about literals
 ..		;
 ..		S key1=TABLETYP_"_"_key1
 ..  S fid=$P(rs,$C(9),1)
 ..  S acckeys=$P(rs,$C(9),2)
 ..		S keycnt=$L(acckeys,",")
 ..		;
 ..		I '$D(TMP(key1,keycnt)) S TMP(key1,keycnt,fid)=acckeys
 ..		E  D
 ...			;
 ...			N match
 ...			N I
 ...			N acckeys2 N fid2 N keyf1 N keyf2
 ...			;
 ...			S fid2=""
 ...			;
 ...			F  S fid2=$order(TMP(key1,keycnt,fid2)) Q:(fid2="")  D
 ....				;
 ....				S acckeys2=TMP(key1,keycnt,fid2)
 ....				S match=1
 ....				;
 ....				F I=2:1:keycnt D  Q:'match 
 .....					S keyf1=$piece(acckeys,",",I)
 .....					S keyf2=$piece(acckeys2,",",I)
 .....					;
 .....					; If both literal and different, then not a match
 .....					I $$isLit^UCGM(keyf1),$$isLit^UCGM(keyf2),keyf1'=keyf2 S match=0
 .....					Q 
 ....				;
 ....				I match D
 .....					;
 .....					S CNT=CNT+1
 .....					N tblint S tblint=$$vcdmNew^RecordTBLINT() S vobj(tblint,-3)=$J S vobj(tblint,-4)=CNT
 .....				  S $P(vobj(tblint),$C(124),1)=fid2
 .....				  S $P(vobj(tblint),$C(124),2)=acckeys2
 .....				  S $P(vobj(tblint),$C(124),3)=fid
 .....				  S $P(vobj(tblint),$C(124),4)=acckeys
 .....				 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordTBLINT(tblint,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(tblint,-100) S vobj(tblint,-2)=1 TC:vTp  
 .....					K vobj(+$G(tblint)) Q 
 ....				Q 
 ...			Q 
 ..		Q 
 . Q 
 ;
 S RID="TBLINT"
 D DRV^URID
 ;
  K ^TMP($J)
 ;
 Q 
 ;
FUNENTRY(TABLE) ; Function entry point
 ;
 N key1
 ;
 N dbtbl1,vop1,vop2,vop3,vop4 S vop1="SYSDEV",vop2=TABLE,dbtbl1=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",TABLE,0,"")
  S vop3=$G(^DBTBL(vop1,1,vop2,0))
  S vop4=$G(^DBTBL(vop1,1,vop2,16))
 ;
 I '((","_"CTBL,STBL,UTBL"_",")[(","_$P(vop3,$C(124),1)_",")) D
 .	S ER=1
 .	; Invalid table value ~p1
 .	S RM=$$^MSG(1485,TABLE)
 .	Q 
 ;
 S key1=$piece($P(vop4,$C(124),1),",",1)
 ;
 I '$$isLit^UCGM(key1) D  Q  ; First key must be literal
 .	S ER=1
 .	; Invalid table name ~p`
 .	S RM=$$^MSG(1484,TABLE)
 .	Q 
 ;
 D DBEENTRY(TABLE,1)
 ;
 Q 
 ;
CHKACCES(TABLETYP,dbtbl1,mode) ; 
  S:'$D(vobj(dbtbl1,16)) vobj(dbtbl1,16)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),16)),1:"")
  S:'$D(vobj(dbtbl1,22)) vobj(dbtbl1,22)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),22)),1:"")
 ;
 N ACCRGHTS N key1
 ;
 S key1=$$QSUB^%ZS($piece($P(vobj(dbtbl1,16),$C(124),1),",",1),"""")
 ;
 S ACCRGHTS=""
 ;
 ; Only SCA userclass can maintain STBL
 I TABLETYP="STBL" D  Q 
 .	;
 .	; User does not have write access
 .	I %UCLS'="SCA" S ER=1 S RM=$$^MSG(2846)
 .	Q 
 ;
 ; Get userclass access rights
 I TABLETYP="UTBL" D
 .	;
 .	 N V1 S V1=key1 I '$$vDbEx2() Q 
 .	;
 .	N utblutbl S utblutbl=$G(^UTBL("UTBL",key1,%UCLS))
 .	;
 .	S ACCRGHTS=$P(utblutbl,$C(124),1)
 . Q 
 ;
 E  D  ; CTBL
 .	;
 .	 N V1 S V1=key1 I '$$vDbEx3() Q 
 .	;
 .	N ctblutbl S ctblutbl=$G(^CTBL("CTBL",key1,%UCLS))
 .	;
 .	S ACCRGHTS=$P(ctblutbl,$C(124),1)
 . Q 
 ;
 ; Default access rights only if there are no entries for this table
 I (ACCRGHTS="") D
 .	;
 .	N ANY S ANY=0
 .	;
 .	I TABLETYP="UTBL" D
 ..		;
 ..		N rs,vos1,vos2,vos3,vos4  N V1 S V1=key1 S rs=$$vOpen4()
 ..		I $$vFetch4() S ANY=1
 ..  Q 
 .	E  D  ; CTBL
 ..		;
 ..		N rs,vos5,vos6,vos7,vos8  N V1 S V1=key1 S rs=$$vOpen5()
 ..		I $$vFetch5() S ANY=1
 ..  Q 
 .	;
 .	I 'ANY D
 ..		;
 ..		I %UCLS="SCA" S ACCRGHTS="RWD"
 ..		E  I %UCLS="MGR" S ACCRGHTS="RWD"
 ..		E  S ACCRGHTS="R"
 ..		Q 
 .	Q 
 ;
 I mode=0 D
 .	;
 .	I ACCRGHTS'["W" D
 ..		S ER=1
 ..		; User does not have write access to table
 ..		S RM=$$^MSG(2846)
 ..		Q 
 .	;
 .	E  I $P(vobj(dbtbl1,22),$C(124),9) D
 ..		S ER=1
 ..		; This table maintenance is restricted
 ..		S RM=$$^MSG(5638)
 ..		Q 
 .	Q 
 E  D
 .	;
 .	I ACCRGHTS'["D" D
 ..		S ER=1
 ..		; User is not allowed to delete table entry
 ..		S RM=$$^MSG(2860)
 ..		Q 
 .	Q 
 ;
 Q 
 ;
GETKEYS(acckeys,keys,select,where) ; 
 ;
 N I N keycnt
 N key
 ;
 S keycnt=0
 S (select,where)=""
 ;
 S acckeys=$$TOKEN^%ZS(acckeys)
 F I=1:1:$L(acckeys,",") D
 .	;
 .	S key=$piece(acckeys,",",I)
 .	Q:key?1.N  ; Ignore numeric keys
 .	Q:$E(key,1)=$char(0)  ; Ignore literal strings
 .	;
 .	S keycnt=keycnt+1
 .	S keys(keycnt)=key
 .	;
 .	S select=select_key_","
 .	S where=where_key_"= :KEY("_keycnt_") AND "
 .	Q 
 ;
 S select=$E(select,1,$L(select)-1)
 S where=$E(where,1,$L(where)-5)
 ;
 Q keycnt
 ;
DYNSEL(SELECT,FROM,WHERE,KEY) ; 
 ;
 ; Since SQL doesn't like host variables as array elements, substitute
 N KEY1 N KEY2 N KEY3 N KEY4 N KEY5 N KEY6 N KEY7 N KEY8
 ;
 ; Set to null to avoid unreferenced variable warning
 S (KEY1,KEY2,KEY3,KEY4,KEY5,KEY6,KEY7,KEY8)=""
 ;
 I (WHERE["KEY(") D
 .	;
 .	N I
 .	N X
 .	;
 .	F I=1:1:8 Q:'($D(KEY(I))#2)  D
 ..		S X="KEY"_I
 ..		S @X=KEY(I)
 ..		S WHERE=$$vStrRep(WHERE,"KEY("_I_")","KEY"_I,0,0,"")
 ..		Q 
 .	Q 
 ;
 ;  #ACCEPT Date=09/21/04; PGM=Dan Russell; CR=unknown
 N rs,vos1,vos2,sqlcur,exe,sqlcur,vd,vi,vsql,vsub S rs=$$vOpen0(.exe,.vsql,SELECT,FROM,WHERE,"","","",1)
 ;
 I $$vFetch0() Q 1
 ;
 Q 0
 ;
ACCESS ; Post processor for access mode
 ;
 N I
 N ACC1 N ACC2 N TMP
 ;
 S ACC1=""
 S ACC2=""
 ;
 F I=1:1:$L(X) D  Q:ER 
 .	S TMP=$E(X,I)
 .	;
 .	; input must be ""RWD""
 .	I "RWD"'[TMP D SETERR^DBSEXECU("DBTBL1D","MSG","5635") Q:ER 
 .	;
 .	; Must have read access if write access is specified
 .	I TMP="W" S ACC1="RW"
 .	;
 .	; Must have write access if delete access is specified
 .	I TMP="D" S ACC2="RWD"
 .	Q 
 ;
 I '(ACC1="") S X=ACC1
 I '(ACC2="") S X=ACC2
 ;
 Q 
 ;
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61219^67049^Dan Russell^20298" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vStrLike(object,p1,p2) ; String.isLike
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I (p1="") Q (object="")
 I p2 S object=$ZCONVERT(object,"U") S p1=$ZCONVERT(p1,"U")
 I ($E(p1,1)="%"),($E(p1,$L(p1))="%") Q object[$E(p1,2,$L(p1)-1)
 I ($E(p1,1)="%") Q ($E(object,$L(object)-$L($E(p1,2,1048575))+1,1048575)=$E(p1,2,1048575))
 I ($E(p1,$L(p1))="%") Q ($E(object,1,$L($E(p1,1,$L(p1)-1)))=$E(p1,1,$L(p1)-1))
 Q object=p1
 ; ----------------
 ;  #OPTION ResultClass 1
vStrRep(object,p1,p2,p3,p4,qt) ; String.replace
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;
 I p3<0 Q object
 I $L(p1)=1,$L(p2)<2,'p3,'p4,(qt="") Q $translate(object,p1,p2)
 ;
 N y S y=0
 F  S y=$$vStrFnd(object,p1,y,p4,qt) Q:y=0  D
 .	S object=$E(object,1,y-$L(p1)-1)_p2_$E(object,y,1048575)
 .	S y=y+$L(p2)-$L(p1)
 .	I p3 S p3=p3-1 I p3=0 S y=$L(object)+1
 .	Q 
 Q object
 ; ----------------
 ;  #OPTION ResultClass 1
vStrFnd(object,p1,p2,p3,qt) ; String.find
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;
 I (p1="") Q $S(p2<1:1,1:+p2)
 I p3 S object=$ZCONVERT(object,"U") S p1=$ZCONVERT(p1,"U")
 S p2=$F(object,p1,p2)
 I '(qt=""),$L($E(object,1,p2-1),qt)#2=0 D
 .	F  S p2=$F(object,p1,p2) Q:p2=0!($L($E(object,1,p2-1),qt)#2) 
 .	Q 
 Q p2
 ;
vDbEx2() ; min(1): DISTINCT TBL,KEY FROM UTBLUTBL WHERE TBL=:V1 AND KEY=:%UCLS
 ;
 N vsql1,vsql3
 S vsql1=$$BYTECHAR^SQLUTL(254)
 ;
 S vsql3=$G(%UCLS) I vsql3="" Q 0
 I '($D(^UTBL("UTBL",V1,vsql3))#2) Q 0
 Q 1
 ;
vDbEx3() ; min(1): DISTINCT TBL,UCLS FROM CTBLUTBLF WHERE TBL=:V1 AND UCLS=:%UCLS
 ;
 N vsql1,vsql3
 S vsql1=$$BYTECHAR^SQLUTL(254)
 ;
 S vsql3=$G(%UCLS) I vsql3="" Q 0
 I '($D(^CTBL("CTBL",V1,vsql3))#2) Q 0
 Q 1
 ;
vOpen0(exe,vsql,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist,vOff) ; Dynamic MDB ResultSet
 ;
 set sqlcur="DYNSEL.rs"
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
 S vos1=vsql
 Q ""
 ;
vFetch0() ; MDB dynamic FETCH
 ;
 ; type public String exe(),sqlcur,vd,vi,vsql()
 ;
 I vsql=0 S rs="" Q 0
 S vsql=$$^SQLF(.exe,.vd,.vi,.sqlcur)
 S rs=vd
 S vos1=vsql
 S vos2=$G(vi)
 Q vsql
 ;
vOpen1() ; %LIBS,FID FROM DBTBL1 WHERE %LIBS = 'SYSDEV' AND GLOBAL = :TABLETYP AND FILETYP <> 5 ORDER BY ACCKEYS
 ;
 ;
 S vOid=$G(^DBTMP($J))-1,^($J)=vOid K ^DBTMP($J,vOid)
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(TABLETYP) I vos3="",'$D(TABLETYP) G vL1a0
 S vos4=""
vL1a4 S vos4=$O(^XDBREF("DBTBL1.GLOBAL","SYSDEV",vos3,vos4),1) I vos4="" G vL1a12
 S vos5=$G(^DBTBL("SYSDEV",1,vos4,10))
 I '(+$P(vos5,"|",12)'=5) G vL1a4
 S vos5=$G(^DBTBL("SYSDEV",1,vos4,10))
 S vd="SYSDEV"_$C(9)_$S(vos4=vos2:"",1:vos4)
 S vos6=$G(^DBTBL("SYSDEV",1,vos4,16))
 S vos7=$P(vos6,"|",1) S:vos7="" vos7=vos2 S ^DBTMP($J,vOid,1,vos7,vos4)=vd
 G vL1a4
vL1a12 S vos2=""
vL1a13 S vos2=$O(^DBTMP($J,vOid,1,vos2),1) I vos2="" G vL1a0
 S vos3=""
vL1a15 S vos3=$O(^DBTMP($J,vOid,1,vos2,vos3),1) I vos3="" G vL1a13
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a15
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds="" K ^DBTMP($J,vOid) Q 0
 ;
 S ds=^DBTMP($J,vOid,1,vos2,vos3)
 ;
 Q 1
 ;
vOpen2() ; %LIBS,FID FROM DBTBL1 WHERE %LIBS = 'SYSDEV' AND GLOBAL = :TABLETYP AND FILETYP <> 5
 ;
 ;
 S vos1=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos1=0 Q
vL2a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(TABLETYP) I vos3="",'$D(TABLETYP) G vL2a0
 S vos4=""
vL2a4 S vos4=$O(^XDBREF("DBTBL1.GLOBAL","SYSDEV",vos3,vos4),1) I vos4="" G vL2a0
 S vos5=$G(^DBTBL("SYSDEV",1,vos4,10))
 I '(+$P(vos5,"|",12)'=5) G vL2a4
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
 S vos5=$G(^DBTBL("SYSDEV",1,vos4,10))
 S ds="SYSDEV"_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen3() ; FID,ACCKEYS FROM DBTBL1 WHERE %LIBS='SYSDEV' AND GLOBAL = :TABLETYP ORDER BY FID
 ;
 ;
 S vos1=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos1=0 Q
vL3a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(TABLETYP) I vos3="",'$D(TABLETYP) G vL3a0
 S vos4=""
vL3a4 S vos4=$O(^XDBREF("DBTBL1.GLOBAL","SYSDEV",vos3,vos4),1) I vos4="" G vL3a0
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
 S vos5=$G(^DBTBL("SYSDEV",1,vos4,16))
 S rs=$S(vos4=vos2:"",1:vos4)_$C(9)_$P(vos5,"|",1)
 ;
 Q 1
 ;
vOpen4() ; KEY FROM UTBLUTBL WHERE TBL = :V1
 ;
 ;
 S vos1=2
 D vL4a1
 Q ""
 ;
vL4a0 S vos1=0 Q
vL4a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL4a0
 S vos4=""
vL4a4 S vos4=$O(^UTBL("UTBL",vos3,vos4),1) I vos4="" G vL4a0
 Q
 ;
vFetch4() ;
 ;
 ;
 I vos1=1 D vL4a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen5() ; UCLS FROM CTBLUTBLF WHERE TBL = :V1
 ;
 ;
 S vos5=2
 D vL5a1
 Q ""
 ;
vL5a0 S vos5=0 Q
vL5a1 S vos6=$$BYTECHAR^SQLUTL(254)
 S vos7=$G(V1) I vos7="" G vL5a0
 S vos8=""
vL5a4 S vos8=$O(^CTBL("CTBL",vos7,vos8),1) I vos8="" G vL5a0
 Q
 ;
vFetch5() ;
 ;
 ;
 I vos5=1 D vL5a4
 I vos5=2 S vos5=1
 ;
 I vos5=0 S rs="" Q 0
 ;
 S rs=$S(vos8=vos6:"",1:vos8)
 ;
 Q 1
