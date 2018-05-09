DBSEXEQ	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSEXEQ ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	; I18N=OFF
	;
	Q 
	;
CREATE(%O)	;
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
	S d5q=$$vDb1("SYSDEV",QRID)
	 S vobj(d5q,0)=$G(^DBTBL(vobj(d5q,-3),6,vobj(d5q,-4),0))
	;
	I ($G(vobj(d5q,-2))=0) D
	.	;
	. S vobj(d5q,-100,0)="",$P(vobj(d5q,0),$C(124),15)=%UID
	. S vobj(d5q,-100,0)="",$P(vobj(d5q,0),$C(124),3)=$P($H,",",1)
	. S vobj(d5q,-100,0)="",$P(vobj(d5q,0),$C(124),4)=1
	. S vobj(d5q,-100,0)="",$P(vobj(d5q,0),$C(124),5)=80
	. S vobj(d5q,-100,0)="",$P(vobj(d5q,0),$C(124),12)=1
	. S vobj(d5q,-100,0)="",$P(vobj(d5q,0),$C(124),14)=1
	.	Q 
	;
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
	.	I VFMQ'="Q" D
	..		;
	..		; Delete old data item references
	..		S DBOPT=6 ; Needed by DBSUTL3
	..		S ID=QRID
	..		S DQFUN="D"
	..		;
	..		D ^DBSUTL3
	..		;
	..		; Update data item references
	..		S ID=QRID
	..		S DQFUN="A"
	..		;
	..		D ^DBSUTL3
	..		;
	..		D BUILD(QRID) ; Compile and run report
	..		Q 
	.	Q 
	;
	K vobj(+$G(d5q)) Q 
	;
CHANGE	; Status of screen changes
	;
	; If any changes, signals need to recompile
	I '($D(UX("DBTBL6F"))#2) Q 1 ; Layout changed
	I '($D(UX("DBTBL5SQ"))#2) Q 1 ; Stat def changed
	I ($D(UX("DBTBL5Q",""))#2) Q 0 ; Nothing changed
	;
	Q 1
	;
LIST	;
	D LIST^DBSEXEQ4
	Q 
	;
DELETE	; QWIK REPORT DEFINITION
	;
	N DQSCR N RN
	;
	D INIT(.QRSCREEN)
	;
	S RN=$$^MSG(7978)
	S DQSCR="^"_QRSCREEN
	;
	D DEL^DBSUTLQR(DQSCR)
	;
	Q 
	;
COPY	;
	;
	N DQSCR N RN N SID
	;
	D INIT(.QRSCREEN)
	;
	S RN=$$^MSG(7978)
	S DQSCR="^"_QRSCREEN
	;
	D COPY^DBSUTLQR(DQSCR)
	Q 
	;
RUN	; Run QWIK Report (Function DBSQRR)
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
	N d5q S d5q=$$vDb2("SYSDEV",QRID)
	;
	S %PAGE=2
	S %PG=1
	;
	; Protect ACCESS FILES and DATA ITEMS prompts
	S %O=2
	S ZQRUN=1
	;
	N vo7 N vo8 N vo9 N vo10 D DRV^USID(2,"DBTBL5Q",.d5q,.vo7,.vo8,.vo9,.vo10) K vobj(+$G(vo7)) K vobj(+$G(vo8)) K vobj(+$G(vo9)) K vobj(+$G(vo10))
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
BUILD(QRID)	;
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
COMPILE(QRID)	; Compile QWIK report
	;
	N ER N seq N lseq
	N pgm N zrid
	;
	S zrid="QWIK_"_QRID ; Temp report name
	D EXT^DBSRWQR(QRID,.zrid) ; Convert to RW format
	;
	N dbtbl5q S dbtbl5q=$$vDb2("SYSDEV",QRID)
	 S vobj(dbtbl5q,0)=$G(^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),0))
	S pgm=$P(vobj(dbtbl5q,0),$C(124),2) ; Run-time routine name
	;
	I (pgm="") D  ; Get next sequence number
	.	LOCK +DBTBL("SYSDEV",0,"Q"):10
	.	;
	.	N dbtbl0,vop1,vop2,vop3 S vop2="SYSDEV",vop1="Q",dbtbl0=$$vDb7("SYSDEV","Q",.vop3)
	.	S seq=$P(dbtbl0,$C(124),1)+1
	. S $P(dbtbl0,$C(124),1)=seq
	.	S seq=seq+10000
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^DBTBL(vop2,0,vop1)=$$RTBAR^%ZFUNC(dbtbl0) S vop3=1 Tcommit:vTp  
	.	;
	.	LOCK -DBTBL("SYSDEV",0,"Q") ; R01Qnnnn format
	.	;
	. S vop2="SYSDEV",vop1="L",dbtbl0=$$vDb7("SYSDEV","L",.vop3)
	.	S lseq=$P(dbtbl0,$C(124),1)+100
	.	S pgm="R"_$E($J(lseq,0,""),2,3)_"Q"_$E($J(seq,0,""),2,5)
	.	Q 
	;
	N dbtbl5h S dbtbl5h=$$vDb4("SYSDEV",zrid)
	 S vobj(dbtbl5h,0)=$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),0))
	S vobj(dbtbl5h,-100,0)="",$P(vobj(dbtbl5h,0),$C(124),2)=pgm
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(dbtbl5h) K vobj(dbtbl5h,-100) S vobj(dbtbl5h,-2)=1 Tcommit:vTp  
	;
	D ^DBSRW(zrid,0) ; Compile report
	I $get(ER)>0 K vobj(+$G(dbtbl5h)),vobj(+$G(dbtbl5q)) Q  ; Query error flag
	;
	K vobj(+$G(dbtbl5h)) S dbtbl5h=$$vDb5("SYSDEV",zrid)
	 S vobj(dbtbl5h,0)=$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),0))
	;
	K vobj(+$G(dbtbl5q)) S dbtbl5q=$$vDb2("SYSDEV",QRID)
	 S vobj(dbtbl5q,0)=$G(^DBTBL(vobj(dbtbl5q,-3),6,vobj(dbtbl5q,-4),0))
	;
	S vobj(dbtbl5q,-100,0)="",$P(vobj(dbtbl5q,0),$C(124),2)=$P(vobj(dbtbl5h,0),$C(124),2) ; Save into QWIK report definition
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBTBL5QL(dbtbl5q,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(dbtbl5q,-100) S vobj(dbtbl5q,-2)=1 Tcommit:vTp  
	;
	 N V1 S V1=zrid K ^DBTBL("SYSDEV",5,V1) ; Delete report definition
	;
	K vobj(+$G(dbtbl5h)),vobj(+$G(dbtbl5q)) Q 
	;
CMPALL	; Mass recompile QWIK report (function DBSQRB)
	;
	N CNT
	N QRID
	;
	 N V1 S V1=$J D vDbDe1()
	;
	S CNT=$$LIST^DBSGETID("DBTBL5Q")
	Q:'CNT 
	;
	N ds,vos1,vos2,vos3  N V2 S V2=$J S ds=$$vOpen1()
	;
	F  Q:'($$vFetch1())  D
	.	N tmpdq,vop1 S vop1=$P(ds,$C(9),2),tmpdq=$G(^TEMP($P(ds,$C(9),1),vop1))
	.	D COMPILE(vop1)
	.	Q 
	;
	 N V3 S V3=$J D vDbDe2()
	;
	Q 
	;
PREDI	; PRE-PP FOR DI CHECK
	;
	S I(3)="@SELDI^DBSFUN(FILES,.X)"
	Q 
	;
PPDI(X,FID,FILES,I,RM,ER)	;
	;
	N X1 N X2
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
PPDI2(X,RM,FID,FILES,ER)	;
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
DFID(X,RM,FID,NEWX,FILES,ER)	;
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
DFID1(STR,FILES,NEWX,ER,RM)	;
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
	.	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	.	;
	.	;   #ACCEPT Date=11/20/05; Pgm= Vinayak Teli; CR=17903
	.	XECUTE "set Z="_TEST
	.	Q 
	;
	Q 
	;
ERR	;
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
UPDTBL(d5q,QRID)	;
	;
	N I N SEQ
	N D6F N FILES N ITEMS N REPTYPE
	;
	N DBTBL6F
	;
	 S:'$D(vobj(d5q,0)) vobj(d5q,0)=$S(vobj(d5q,-2):$G(^DBTBL(vobj(d5q,-3),6,vobj(d5q,-4),0)),1:"")
	S FILES=$P(vobj(d5q,0),$C(124),1)
	S REPTYPE=$P(vobj(d5q,0),$C(124),20)
	;
	I %O=1 D vDbDe3()
	;
	 S:'$D(vobj(d5q,12)) vobj(d5q,12)=$S(vobj(d5q,-2):$G(^DBTBL(vobj(d5q,-3),6,vobj(d5q,-4),12)),1:"")
	I '($P(vobj(d5q,12),$C(124),1)="") D ^DBSITEM(FILES,$P(vobj(d5q,12),$C(124),1),.D6F,0,REPTYPE)
	 S:'$D(vobj(d5q,13)) vobj(d5q,13)=$S(vobj(d5q,-2):$G(^DBTBL(vobj(d5q,-3),6,vobj(d5q,-4),13)),1:"")
	I '($P(vobj(d5q,13),$C(124),1)="") D ^DBSITEM(FILES,$P(vobj(d5q,13),$C(124),1),.D6F,0,REPTYPE)
	 S:'$D(vobj(d5q,14)) vobj(d5q,14)=$S(vobj(d5q,-2):$G(^DBTBL(vobj(d5q,-3),6,vobj(d5q,-4),14)),1:"")
	I '($P(vobj(d5q,14),$C(124),1)="") D ^DBSITEM(FILES,$P(vobj(d5q,14),$C(124),1),.D6F,0,REPTYPE)
	 S:'$D(vobj(d5q,15)) vobj(d5q,15)=$S(vobj(d5q,-2):$G(^DBTBL(vobj(d5q,-3),6,vobj(d5q,-4),15)),1:"")
	I '($P(vobj(d5q,15),$C(124),1)="") D ^DBSITEM(FILES,$P(vobj(d5q,15),$C(124),1),.D6F,0,REPTYPE)
	 S:'$D(vobj(d5q,16)) vobj(d5q,16)=$S(vobj(d5q,-2):$G(^DBTBL(vobj(d5q,-3),6,vobj(d5q,-4),16)),1:"")
	I '($P(vobj(d5q,16),$C(124),1)="") D ^DBSITEM(FILES,$P(vobj(d5q,16),$C(124),1),.D6F,0,REPTYPE)
	 S:'$D(vobj(d5q,17)) vobj(d5q,17)=$S(vobj(d5q,-2):$G(^DBTBL(vobj(d5q,-3),6,vobj(d5q,-4),17)),1:"")
	I '($P(vobj(d5q,17),$C(124),1)="") D ^DBSITEM(FILES,$P(vobj(d5q,17),$C(124),1),.D6F,0,REPTYPE)
	;
	D vDbDe4()
	;
	S I=0
	;
	F  Q:'($order(D6F(I)))  D
	.	S I=I+1
	.	;
	. K vobj(+$G(DBTBL6F(I))) S DBTBL6F(I)=$$vDbNew1("SYSDEV",QRID,I)
	.	;
	. S $P(vobj(DBTBL6F(I)),$C(124),1)=$piece(D6F(I),"|",1)
	. S $P(vobj(DBTBL6F(I)),$C(124),2)=$piece(D6F(I),"|",2)
	. S $P(vobj(DBTBL6F(I)),$C(124),3)=$piece(D6F(I),"|",3)
	. S $P(vobj(DBTBL6F(I)),$C(124),4)=$piece(D6F(I),"|",4)
	. S $P(vobj(DBTBL6F(I)),$C(124),5)=$piece(D6F(I),"|",5)
	. S $P(vobj(DBTBL6F(I)),$C(124),6)=$piece(D6F(I),"|",6)
	. S $P(vobj(DBTBL6F(I)),$C(124),7)=$piece(D6F(I),"|",7)
	.	Q 
	;
	I I<20 D
	.	S %REPEAT=I
	. N vo21 N vo22 N vo23 N vo24 D DRV^USID(0,"DBTBL6F",.DBTBL6F,.vo21,.vo22,.vo23,.vo24) K vobj(+$G(vo21)) K vobj(+$G(vo22)) K vobj(+$G(vo23)) K vobj(+$G(vo24))
	.	Q 
	E  D
	.	;
	.	S UX=1
	.	S %PAGE=%PAGE+1
	.	S %REPEAT=19
	.	;
	. N vo25 N vo26 N vo27 N vo28 D DRV^USID(0,"DBTBL6F",.DBTBL6F,.vo25,.vo26,.vo27,.vo28) K vobj(+$G(vo25)) K vobj(+$G(vo26)) K vobj(+$G(vo27)) K vobj(+$G(vo28))
	.	Q 
	;
	I VFMQ="Q" D vKill1("") Q 
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBTBL5QL(d5q,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(d5q,-100) S vobj(d5q,-2)=1 Tcommit:vTp   ; Save Main Screen data
	;
	S I=""
	F  S I=$order(DBTBL6F(I)) Q:(I="")  D  ; Save Second Screen data
	. S vobj(DBTBL6F(I),-5)=vobj(DBTBL6F(I),-5)+100
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBTBL6FL(DBTBL6F(I),"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(DBTBL6F(I),-100) S vobj(DBTBL6F(I),-2)=1 Tcommit:vTp  
	.	Q 
	;
	D vKill1("") Q 
	;
UPDSTAT(d5q,QRID)	;
	;
	N I
	;
	N D6S
	;
	D vDbDe5()
	;
	F I=1:1:20 K vobj(+$G(D6S(I))) S D6S(I)=$$vDbNew2("SYSDEV",QRID,I)
	;
	S %PG=%PAGE
	S %REPEAT=I
	N vo29 N vo30 N vo31 N vo32 D DRV^USID(0,"DBTBL6S",.D6S,.vo29,.vo30,.vo31,.vo32) K vobj(+$G(vo29)) K vobj(+$G(vo30)) K vobj(+$G(vo31)) K vobj(+$G(vo32))
	;
	I VFMQ="Q" D vKill2("") Q 
	;
	F I=1:1:20 I '($P(vobj(D6S(I)),$C(124),4)="") D
	. S vobj(D6S(I),-5)=vobj(D6S(I),-5)+20
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DTBL6SQL(D6S(I),"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(D6S(I),-100) S vobj(D6S(I),-2)=1 Tcommit:vTp  
	.	Q 
	;
	D vKill2("") Q 
	;
PPQ(fDBTBL5Q,FILES,PFID,X,RM,ER)	;
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
INIT(QRSCREEN)	;initialize the screen objects - call Usid
	;
	N PGM N SID
	;
	S SID="DBTBL5Q"
	D ^USID
	S QRSCREEN=PGM_"(%O,.d5q)"
	Q 
	;
vSIG()	;
	Q "60774^60277^Badrinath Giridharan^12413" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM TMPDQ WHERE PID=:V1
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen2()
	F  Q:'($$vFetch2())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^TEMP(v1,v2)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe2()	; DELETE FROM TMPDQ WHERE PID=:V3
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen3()
	F  Q:'($$vFetch3())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^TEMP(v1,v2)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe3()	; DELETE FROM DBTBL6F WHERE LIBS='SYSDEV' AND QRID=:QRID
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen4()
	F  Q:'($$vFetch4())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^DBTBL(v1,6,v2,v3)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe4()	; DELETE FROM DBTBL6F WHERE LIBS='SYSDEV' AND QRID=:QRID
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen5()
	F  Q:'($$vFetch5())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^DBTBL(v1,6,v2,v3)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe5()	; DELETE FROM DBTBL6SQ WHERE LIBS='SYSDEV' AND QID=:QRID
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen6()
	F  Q:'($$vFetch6())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^DBTBL(v1,6,v2,v3)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(DBTBL5Q,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL5Q"
	S vobj(vOid)=$G(^DBTBL(v1,6,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,6,v2))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDb2(v1,v2)	;	vobj()=Db.getRecord(DBTBL5Q,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL5Q"
	S vobj(vOid)=$G(^DBTBL(v1,6,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,6,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL5Q" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDb4(v1,v2)	;	vobj()=Db.getRecord(DBTBL5H,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL5H"
	S vobj(vOid)=$G(^DBTBL(v1,5,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,5,v2))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDb5(v1,v2)	;	vobj()=Db.getRecord(DBTBL5H,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL5H"
	S vobj(vOid)=$G(^DBTBL(v1,5,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,5,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL5H" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDb7(v1,v2,v2out)	;	voXN = Db.getRecord(DBTBL0,,0,-2)
	;
	N dbtbl0
	S dbtbl0=$G(^DBTBL(v1,0,v2))
	I dbtbl0="",'$D(^DBTBL(v1,0,v2))
	S v2out=1
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL0" X $ZT
	Q dbtbl0
	;
vDbNew1(v1,v2,v3)	;	vobj()=Class.new(DBTBL6F)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL6F",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDbNew2(v1,v2,v3)	;	vobj()=Class.new(DBTBL6SQ)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL6SQ",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vKill1(ex1)	;	Delete objects DBTBL6F()
	;
	N n1 S (n1)=""
	F  S n1=$O(DBTBL6F(n1)) Q:n1=""  K:'((n1=ex1)) vobj(DBTBL6F(n1))
	Q
	;
vKill2(ex1)	;	Delete objects D6S()
	;
	N n1 S (n1)=""
	F  S n1=$O(D6S(n1)) Q:n1=""  K:'((n1=ex1)) vobj(D6S(n1))
	Q
	;
vOpen1()	;	PID,ELEMENT FROM TMPDQ WHERE PID=:V2 ORDER BY ELEMENT ASC
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(V2) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^TEMP(vos2,vos3),1) I vos3="" G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen2()	;	PID,ELEMENT FROM TMPDQ WHERE PID=:V1
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(V1) I vos2="" G vL2a0
	S vos3=""
vL2a3	S vos3=$O(^TEMP(vos2,vos3),1) I vos3="" G vL2a0
	Q
	;
vFetch2()	;
	;
	;
	I vos1=1 D vL2a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen3()	;	PID,ELEMENT FROM TMPDQ WHERE PID=:V3
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(V3) I vos2="" G vL3a0
	S vos3=""
vL3a3	S vos3=$O(^TEMP(vos2,vos3),1) I vos3="" G vL3a0
	Q
	;
vFetch3()	;
	;
	;
	I vos1=1 D vL3a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen4()	;	LIBS,QRID,SEQ FROM DBTBL6F WHERE LIBS='SYSDEV' AND QRID=:QRID
	;
	;
	S vos1=2
	D vL4a1
	Q ""
	;
vL4a0	S vos1=0 Q
vL4a1	S vos2=$G(QRID) I vos2="" G vL4a0
	S vos3=100
vL4a3	S vos3=$O(^DBTBL("SYSDEV",6,vos2,vos3),1) I vos3="" G vL4a0
	Q
	;
vFetch4()	;
	;
	;
	I vos1=1 D vL4a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen5()	;	LIBS,QRID,SEQ FROM DBTBL6F WHERE LIBS='SYSDEV' AND QRID=:QRID
	;
	;
	S vos1=2
	D vL5a1
	Q ""
	;
vL5a0	S vos1=0 Q
vL5a1	S vos2=$G(QRID) I vos2="" G vL5a0
	S vos3=100
vL5a3	S vos3=$O(^DBTBL("SYSDEV",6,vos2,vos3),1) I vos3="" G vL5a0
	Q
	;
vFetch5()	;
	;
	;
	I vos1=1 D vL5a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen6()	;	LIBS,QID,SEQ FROM DBTBL6SQ WHERE LIBS='SYSDEV' AND QID=:QRID
	;
	;
	S vos1=2
	D vL6a1
	Q ""
	;
vL6a0	S vos1=0 Q
vL6a1	S vos2=$G(QRID) I vos2="" G vL6a0
	S vos3=20
vL6a3	S vos3=$O(^DBTBL("SYSDEV",6,vos2,vos3),1) I vos3=""!(vos3'<41) G vL6a0
	Q
	;
vFetch6()	;
	;
	;
	I vos1=1 D vL6a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vReSav1(dbtbl5h)	;	RecordDBTBL5H saveNoFiler()
	;
	S ^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4))=$$RTBAR^%ZFUNC($G(vobj(dbtbl5h)))
	N vD,vN S vN=-1
	I '$G(vobj(dbtbl5h,-2)) F  S vN=$O(vobj(dbtbl5h,vN)) Q:vN=""  S vD=$$RTBAR^%ZFUNC(vobj(dbtbl5h,vN)) S:vD'="" ^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),vN)=vD
	E  F  S vN=$O(vobj(dbtbl5h,-100,vN)) Q:vN=""  I $D(vobj(dbtbl5h,vN))#2 S vD=$$RTBAR^%ZFUNC(vobj(dbtbl5h,vN)) S:vD'="" ^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),vN)=vD I vD="" ZWI ^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),vN)
	Q
	;
vtrap1	;	Error trap
	;
	N error S error=$ZS
	;
	S ER=1
	;
	; Invalid format ~p1
	S RM=$$^MSG(1350,STR)
	Q 
