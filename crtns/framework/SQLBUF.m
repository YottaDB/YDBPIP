 ; 
 ; **** Routine compiled from DATA-QWIK Procedure SQLBUF ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
 ;  #PACKAGE framework
SQLBUF(expr,par,sqlsta,sqldta,sqlcnt,sqlind,tok) ; 
 N vTp
 ;
 N arg N i N rec
 N name
 ;
 S ER=0
 S rec=0
 ;
 I ($get(%TOKEN)="") S %TOKEN=$J
 S arg=$piece(expr," ",1) ; Buffer keyword
 ;
 ; Default to ADD if not included
 I $$CONTAIN("NEW,ADD,COMMIT,DELETE,ROLLBACK",arg) S name=$piece(expr," ",2) S expr=$piece(expr," ",3,9999)
 E  S name=arg S arg="ADD" S expr=$piece(expr," ",2,9999)
 ;
 ;Convert back to raw input
 I (name[$char(1)) S name=$$UNTOK^%ZS(name,.tok)
 ;
 I (name="") S ER=1 S RM=$$^MSG(8552) Q  ; Missing buffer name
 ;
 ; Buffer existed status
 N dbbuf S dbbuf=$$vRCgetRecord1^RecordDBBUF(%TOKEN,name,0)
 S rec=$P(vobj(dbbuf),$C(124),1)
 ;
 ; BUFFER ROLLBACK
 I arg="ROLLBACK" D clearBuffer(%TOKEN,name)
 ;
 I rec=0,arg="DELETE" K vobj(+$G(dbbuf)) Q  ; Buffer not on file
 I rec=0,(arg="COMMIT") S ER=1 S RM=$$^MSG(8555,name) K vobj(+$G(dbbuf)) Q  ; Buffer empty
 ;
 I arg="COMMIT" D COMMIT(name,.tok,.par,.sqldta) K vobj(+$G(dbbuf)) Q  ; Process buffer
 ;
 I $$CONTAIN("DELETE,NEW",arg) D  ; Clear buffer on new / delete
 .	;
 .	D clearBuffer(%TOKEN,name)
 .	S vobj(dbbuf,-2)=0 ; Reset mode on dbbuf object
 .	S rec=0 ; to trigger an insert on new.
 .	Q 
 ;
 I $$CONTAIN("ADD,NEW",arg) D
 .	N auth N rest N savexpr
 .	;
 .	S rec=rec+1
 .	S expr=$$UNTOK^%ZS(expr,.tok)
 .	;
 .	I expr="" Q  ; NEW without SQL statement
 .	;
 .  S $P(vobj(dbbuf),$C(124),1)=rec
 .	;
 .	I '($get(par("EFD"))="")  S $P(vobj(dbbuf),$C(124),2)=$$FDAT^%ZM(par("EFD"))
 .	;
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBBUF(dbbuf,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbbuf,-100) S vobj(dbbuf,-2)=1 TC:vTp  
 .	;
 .	S (auth,rest)=""
 .	F  S rest=$order(vsupv(1,rest)) Q:(rest="")  D
 ..		I '(auth="") S auth=auth_"##"
 ..		S auth=auth_rest_"|"_vsupv(1,rest)
 ..		Q 
 .	S savexpr(1)=auth
 .	S savexpr(2)=$$PARLIST(.par) ; Qualifiers
 .	S savexpr(3)=expr
 .	;
 .	N dbbufcom S dbbufcom=$$vcdmNew^RecordDBBUFCOM()
 .	 S vobj(dbbufcom,1,1)=""
 .  S vobj(dbbufcom,-3)=%TOKEN
 .  S vobj(dbbufcom,-4)=name
 .  S vobj(dbbufcom,-5)=rec
 .  S vobj(dbbufcom,1,1)=$$V2LV^MSG(.savexpr)
 .	;
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBBUFCOM(dbbufcom,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbbufcom,-100) S vobj(dbbufcom,-2)=1 TC:vTp  
 .	K vobj(+$G(dbbufcom)) Q 
 ;
 ; BUFFER ~p1 Contains ~p2 Records
 S sqldta=$$^MSG(8554,name,rec) ; Return message
 S sqlcnt=1
 K vobj(+$G(dbbuf)) Q 
 ;
COMMIT(name,tok,par,sqldta) ; Process a buffer for commit
 ;
 N bufcount N efd N i N vseq
 N sql N vcurval N vfkey N vsupv N zpar
 N rdb
 ;
 ; RDB flag
 S rdb=$$rdb^UCDBRT()
 ;
 ; kill override array
 K vrflg
 ;
 S ER=0
 ;
 I ($D(par("EFD"))#2) D
 .	N EFD
 .	S EFD=$$FDAT^%ZM(par("EFD")) Q:ER 
 .	Q 
 ;
 I ($get(TJD)="") D  ;Instantiate cuvar
 .	N TJD
 .	N cuvar S cuvar=$$vRCgetRecord0Opt^RecordCUVAR(0,"")
 .	 S cuvar=$G(^CUVAR(2))
 .	S TJD=$P(cuvar,$C(124),1)
 . Q 
 I ($D(par("EFD"))#2),EFD=TJD K EFD
 ;
 N dbbuf S dbbuf=$$vRCgetRecord0Opt^RecordDBBUF(%TOKEN,name,0,"")
 ;
 S bufcount=$P(dbbuf,$C(124),1)
 I '($P(dbbuf,$C(124),2)="") S EFD=$P(dbbuf,$C(124),2)
 ;
 F vseq=1:1:bufcount D
 .	;
 .	N ptr
 .	N savedexpr
 .	;
 .	S zpar(vseq)=""
 .	;
 .	N dbbufcom,vop1,vop2,vop3,vop4 S vop1=%TOKEN,vop2=name,vop3=vseq,dbbufcom=$$vRCgetRecord0Opt^RecordDBBUFCOM(%TOKEN,name,vseq,0,"")
 .	 S vop4="" N von S von="" F  S von=$O(^DBBUF(vop1,vop2,vop3,von)) quit:von=""  S vop4=vop4_^DBBUF(vop1,vop2,vop3,von)
 .	;
 .	S ptr=$$LV2V^MSG(vop4,.savedexpr)
 .	;
 .	I '(savedexpr(1)="") D
 ..		;
 ..		N auth S auth=savedexpr(1)
 ..		;
 ..		F i=1:1:$L(auth,"##") D
 ...			;
 ...			N tmp S tmp=$piece(auth,"##",i)
 ...			S vsupv(vseq,$piece(tmp,"|",1))=$piece(tmp,"|",2)
 ...			Q 
 ..		Q 
 .	;
 .	S zpar(vseq)=savedexpr(2)_"/NOFKCHK=1" ; Qualifiers
 .	S sql(vseq)=savedexpr(3) ; Expression
 . Q 
 ;
 I '$D(sql) Q  ; empty buffer
 ;
 S efd=0 I $get(EFD)>TJD S efd=1 ; Effective Dated?
 I efd D ^SQLEFD(EFD,.sql) D clearBuffer(%TOKEN,name) Q  ; Save it in EFD file
 ;
 TS (vobj):transactionid="CS"
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="N voxEr S voxEr=$ZE D:'+voxEr LOG^UCGMR(""LOGERR^"_$T(+0)_""",.voxEr) S $ZE=voxEr D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)  ; Define error trap
 ;
 N flist N spec
 S vseq="" ; Process SQL buffer
 F  S vseq=$order(sql(vseq)) Q:vseq=""  D  Q:ER 
 .	N s1 N s2 N verrors
 .	;
 .	I $get(%STFHOST),'$$VALID^PBSMSQL(sql(vseq),"",.spec) S ER=1 S RM=$$^MSG(7912) Q 
 .	I $get(spec)=1 D
 ..		N TJD
 ..		S TJD=$$TTL^RCHK()+1
 ..		S ER=$$^SQL(sql(vseq),zpar(vseq))
 ..		Q 
 .	E  S ER=$$^SQL(sql(vseq),zpar(vseq))
 .	K flist
 .	;
 .	S (s1,s2)=""
 .	F  S s1=$order(verrors(s1)) Q:(s1="")  D
 ..		S vrflg(vseq,s1)=verrors(s1)
 ..		F  S s2=$order(verrors(s1,s2)) Q:(s2="")  D
 ...			S vrflg(vseq,s1,s2)=verrors(s1,s2)
 ...			Q 
 ..		Q 
 .	Q 
 ;
 I rdb,$get(vER)<0 S ER=vER S RM=vRM
 ;
 I ER D ERROR Q  ; Exit
 ;
 D vfkey ; Verify foreign keys
 ;
 I ER D ERROR Q  ; Exit
 ;
 ;Apply override logic
 I $D(vrflg),$D(vsupv) D SPVOVR^PBSMSQL(.vrflg,.vsupv)
 I $D(vrflg) D ERROR Q 
 ;
 ;  #ACCEPT Date=11/30/2008; Pgm=RussellDS; CR=36725; Group=BYPASS
 ;*** Start of code by-passed by compiler
 if '$Tlevel set ER=1 do ERROR quit    ; TP error
 ;*** End of code by-passed by compiler ***
 ;
  TC:$TL  ; Commit transaction
 ;
 D clearBuffer(%TOKEN,name) ; clear buffer
 ;
 S sqldta=$$^MSG(8553,name) ; Return message
 ;
 Q 
 ;
clearBuffer(tkn,bufName) ; 
 ;
  K ^DBBUF(tkn,bufName)
 ;
  K ^DBBUF(tkn,bufName)
 ;
 Q 
 ;
ERROR ; 
 ;
  TRO:$TL>0  ; Rollback transactions
 ;
 D clearBuffer(%TOKEN,name) ; Clear buffer on error
 ;
 I '($get(RM)="") S sqldta=RM Q 
 I '($get(ET)="") S sqldta=ET Q 
 ;
 S sqldta=$$^MSG(646,name)
 ;
 Q 
 ;
CONTAIN(A,B) ; Return status 1 if string A contains string B
 ;
 Q ((","_A_",")[(","_B_","))
 ;
vfkey ; Referential integrity check (missing foreign key record)
 N desc1 N desc2 N msg N v N v1
 S v=""
 ;
 F  S v=$order(vfkey(v)) Q:(v="")  I $D(@v)#10=0 D  Q 
 .	;
 .	S v1=vfkey(v) S desc1=$piece(v1,"(",1) S desc2=$piece(v1,"-> ",2)
 .	;
 .	I '(desc1="") D  ; table description
 ..		;
 ..		N dbtbl1 S dbtbl1=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",desc1,0,"")
 ..		S desc1=$P(dbtbl1,$C(124),1)
 ..		;
 ..  Q 
 .	I '(desc2="") D  ; table description
 ..		;
 ..		N dbtbl2 S dbtbl2=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",desc2,0,"")
 ..		S desc2=$P(dbtbl2,$C(124),1)
 ..  Q 
 .	;
 .	S msg=desc1_" -> "_desc2_" "_$piece($piece(v,"(",2),")",1) ; foreign key
 .	;
 .	S ER=1 S RM=$$^MSG(8563,msg) Q 
 .	;
 .	Q 
 ;
 Q 
 ;
PARLIST(par) ; Pack qualifiers into a single string
 ;
 N p N str N val
 ;
 I '($get(par)="") Q par ; No need to convert
 I ($order(par(""))="") Q "" ; Qualifier not defined
 ;
 S p="" S str=""
 ;
 F  S p=$order(par(p)) Q:(p="")  D
 .	;
 .	S val=par(p)
 .	I (val["/"),'(val["'") S val="'"_val_"'" ; 'DD/DD/YEAR' format
 .	;
 .	I '(val["=") S str=str_"/"_p_"="_val Q 
 .	S str=str_"/"_p_"=("_val_")" ; USING qualifier
 .	Q 
 ;
 Q str
 ;
LOGERR(err) ; Error handler
 ;
 D LOGERR^UTLERR(err)
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61347^84830^Gordon Joyner^9677" ; Signature - LTD^TIME^USER^SIZE
 ;
vCatch1 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 S ER=1
 D ZX^UCGMR(voxMrk) Q 
