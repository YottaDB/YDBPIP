 ; 
 ; **** Routine compiled from DATA-QWIK Filer RecordDBTBL7 ****
 ; 
 ; 02/24/2010 18:40 - pip
 ; 
 ;
 ; Record Class code for table DBTBL7
 ;
 ; Generated by PSLRecordBuilder on 02/24/2010 at 18:40 by
 ;
vcdmNew() ; 
 N vOid
 ;  #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=BYPASS
 ;*** Start of code by-passed by compiler
 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL7",vobj(vOid,-2)=0,vobj(vOid)=""
 S vobj(vOid,-3)=""
 S vobj(vOid,-4)=""
 S vobj(vOid,-5)=""
 ;*** End of code by-passed by compiler ***
 ;  #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=SCOPE
 Q vOid
 ;
vRCgetRecord0(v1,v2,v3,vfromDbSet) ; 
 N vOid
 ;  #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=BYPASS
 ;*** Start of code by-passed by compiler
 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL7"
 S vobj(vOid)=$G(^DBTBL(v1,7,v2,v3))
 I vobj(vOid)="",'($D(^DBTBL(v1,7,v2,v3))#2)
 S vobj(vOid,-2)=1
 I $T K vobj(vOid) S $ZE="0,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL7",$EC=",U1001,"
 S vobj(vOid,-3)=v1
 S vobj(vOid,-4)=v2
 S vobj(vOid,-5)=v3
 ;*** End of code by-passed by compiler ***
 ;  #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=SCOPE
 Q vOid
 ;
vRCgetRecord1(v1,v2,v3,vfromDbSet) ; 
 N vOid
 ;  #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=BYPASS
 ;*** Start of code by-passed by compiler
 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL7"
 S vobj(vOid)=$G(^DBTBL(v1,7,v2,v3))
 I vobj(vOid)="",'($D(^DBTBL(v1,7,v2,v3))#2)
 S vobj(vOid,-2)='$T
 S vobj(vOid,-3)=v1
 S vobj(vOid,-4)=v2
 S vobj(vOid,-5)=v3
 ;*** End of code by-passed by compiler ***
 ;  #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=SCOPE
 Q vOid
 ;
vRCgetRecord0Opt(v1,v2,v3,vfromDbSet,v2out) ; 
 N dbtbl7
 ;  #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=BYPASS
 ;*** Start of code by-passed by compiler
 S dbtbl7=$G(^DBTBL(v1,7,v2,v3))
 I dbtbl7="",'($D(^DBTBL(v1,7,v2,v3))#2)
 S v2out=1
 I $T S $ZE="0,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL7",$EC=",U1001,"
 ;*** End of code by-passed by compiler ***
 Q dbtbl7
 ;
vRCgetRecord1Opt(v1,v2,v3,vfromDbSet,v2out) ; 
 N dbtbl7
 ;  #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=BYPASS
 ;*** Start of code by-passed by compiler
 S dbtbl7=$G(^DBTBL(v1,7,v2,v3))
 I dbtbl7="",'($D(^DBTBL(v1,7,v2,v3))#2)
 S v2out='$T
 ;*** End of code by-passed by compiler ***
 Q dbtbl7
 ;
vBypassSave(this) ; 
 D vSave(this,"/NOJOURNAL/NOTRIGAFT/NOTRIGBEF/NOVALDD/NOVALREQ/NOVALRI/NOVALST",0)
 Q 
 ;
vSave(this,vRCparams,vauditLogSeq) ; 
 N vRCaudit N vRCauditIns
 N %O S %O=$G(vobj(this,-2))
 I ($get(vRCparams)="") S vRCparams="/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/"
 I (%O=0) D
 .	D AUDIT^UCUTILN(this,.vRCauditIns,1,"|")
 .	D vRCsetDefaults(this)
 .	I (("/"_vRCparams_"/")["/TRIGBEF/") D vRCbeforeInsTrigs(this,vRCparams)
 .	I (("/"_vRCparams_"/")["/VALREQ/") D vRCchkReqForInsert(this)
 .	I (("/"_vRCparams_"/")["/VALDD/") D vRCvalidateDD(this,%O)
 .	D vRCmiscValidations(this,vRCparams,%O)
 .	D vRCupdateDB(this,%O,vRCparams,.vRCaudit,.vRCauditIns)
 .	Q 
 E  I (%O=1) D
 .	D AUDIT^UCUTILN(this,.vRCaudit,1,"|")
 .	I ($D(vobj(this,-100,"1*","%LIBS"))&($P($E($G(vobj(this,-100,"1*","%LIBS")),5,9999),$C(124))'=vobj(this,-3)))!($D(vobj(this,-100,"2*","TABLE"))&($P($E($G(vobj(this,-100,"2*","TABLE")),5,9999),$C(124))'=vobj(this,-4)))!($D(vobj(this,-100,"3*","TRGID"))&($P($E($G(vobj(this,-100,"3*","TRGID")),5,9999),$C(124))'=vobj(this,-5))) D vRCkeyChanged(this,vRCparams,.vRCaudit) Q 
 .	I (("/"_vRCparams_"/")["/TRIGBEF/") D vRCbeforeUpdTrigs(this,vRCparams,.vRCaudit)
 .	I (("/"_vRCparams_"/")["/VALREQ/") D vRCchkReqForUpdate(this)
 .	I (("/"_vRCparams_"/")["/VALDD/") D vRCvalidateDD1(this)
 .	D vRCmiscValidations(this,vRCparams,%O)
 .	D vRCupdateDB(this,%O,vRCparams,.vRCaudit,.vRCauditIns)
 .	Q 
 E  I (%O=2) D
 .	I (("/"_vRCparams_"/")["/VALREQ/") D vRCchkReqForInsert(this)
 .	I (("/"_vRCparams_"/")["/VALDD/") D vRCvalidateDD(this,%O)
 .	D vRCmiscValidations(this,vRCparams,2)
 .	Q 
 E  I (%O=3) D
 .	  N V1,V2,V3 S V1=vobj(this,-3),V2=vobj(this,-4),V3=vobj(this,-5) Q:'($D(^DBTBL(V1,7,V2,V3))#2) 
 .	D vRCdelete(this,vRCparams,.vRCaudit,0)
 .	Q 
 Q 
 ;
vcheckAccessRights() ; 
 Q ""
 ;
vinsertAccess(userclass) ; 
 Q 1
 ;
vinsertOK(this,userclass) ; PUBLIC access is allowed, no restrict clause
 Q 1
 ;
vupdateAccess(userclass) ; 
 Q 1
 ;
vupdateOK(this,userclass) ; PUBLIC access is allowed, no restrict clause
 Q 1
 ;
vdeleteAccess(userclass) ; 
 Q 1
 ;
vdeleteOK(this,userclass) ; PUBLIC access is allowed, no restrict clause
 Q 1
 ;
vselectAccess(userclass,restrict,from) ; 
 S (restrict,from)=""
 Q 1
 ;
vselectOK(this,userclass) ; PUBLIC access is allowed, no restrict clause
 Q 1
 ;
vselectOptmOK(userclass,dbtbl7,vkey1,vkey2,vkey3) ; PUBLIC access is allowed, no restrict clause
 Q 1
 ;
vgetLogging() ; 
 Q "0"
 ;
logUserclass(operation) ; 
 I (operation="INSERT") Q 0
 E  I (operation="UPDATE") Q 0
 E  I (operation="DELETE") Q 0
 E  I (operation="SELECT") Q 0
 Q 0
 ;
vlogSelect(statement,using) ; 
 Q 0
 ;
columnList() ; 
 Q $$vStrRep("%LIBS,ACTAD,ACTAI,ACTAU,ACTBD,ACTBI,ACTBU,COLUMNS,DES,IFCOND,PROCMODE,TABLE,TIME,TLD,TRGID,USER",",",$char(9),0,0,"")
 ;
columnListBM() ; 
 Q ""
 ;
columnListCMP() ; 
 Q $$vStrRep("",",",$char(9),0,0,"")
 ;
getColumnMap(map) ; 
 ;
 S map(-5)="TRGID:T:"
 S map(-4)="TABLE:U:"
 S map(-3)="%LIBS:T:"
 S map(-1)="ACTAD:L:7;ACTAI:L:5;ACTAU:L:6;ACTBD:L:4;ACTBI:L:2;ACTBU:L:3;COLUMNS:U:8;DES:T:1;IFCOND:T:12;PROCMODE:T:13;TIME:C:11;TLD:D:9;USER:T:10"
 Q 
 ;
vlegacy(processMode,params) ; 
 N vTp
 I (processMode=2) D
 .	N dbtbl7 S dbtbl7=$$vRCgetRecord0^RecordDBTBL7(%LIBS,TABLE,TRGID,0)
 .	S vobj(dbtbl7,-2)=2
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL7(dbtbl7,$$initPar^UCUTILN(params)) K vobj(dbtbl7,-100) S vobj(dbtbl7,-2)=1 TC:vTp  
 .	K vobj(+$G(dbtbl7)) Q 
 Q 
 ;
vhasLiterals() ; 
 Q 0
 ;
vRCmiscValidations(this,vRCparams,processMode) ; 
 I (("/"_vRCparams_"/")["/VALST/")  N V1,V2,V3 S V1=vobj(this,-3),V2=vobj(this,-4),V3=vobj(this,-5) I '(''($D(^DBTBL(V1,7,V2,V3))#2)=''processMode) D
 .	N errmsg
 .	I (+processMode'=+0) S errmsg=$$^MSG(7932)
 .	E  S errmsg=$$^MSG(2327)
 .	D throwError(errmsg)
 .	Q 
 I (("/"_vRCparams_"/")["/VALFK/") D vRCcheckForeignKeys(this)
 I (("/"_vRCparams_"/")["/VALRI/") D vRCsetForeignKeys(this)
 Q 
 ;
vRCupdateDB(this,processMode,vRCparams,vRCaudit,vRCauditIns) ; 
 I '(("/"_vRCparams_"/")["/NOUPDATE/") D
 .  S $P(vobj(this),$C(124),9)=$P($H,",",1)
 .  S $P(vobj(this),$C(124),11)=$P($H,",",2)
 .	I '(+$P($G(vobj(this,-100,"0*","USER")),$C(124),2)&($P($E($G(vobj(this,-100,"0*","USER")),5,9999),$C(124))'=$P(vobj(this),$C(124),10)))  S $P(vobj(this),$C(124),10)=$E($$USERNAM^%ZFUNC,1,20)
 .	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	if $D(vobj(this)) S ^DBTBL(vobj(this,-3),7,vobj(this,-4),vobj(this,-5))=vobj(this)
 .	;*** End of code by-passed by compiler ***
 .	Q 
 Q 
 ;
vRCdelete(this,vRCparams,vRCaudit,isKeyChange) ; 
 I (("/"_vRCparams_"/")["/CASDEL/") D vRCcascadeDelete(this,vRCparams)
 ;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
 ;*** Start of code by-passed by compiler
 ZWI ^DBTBL(vobj(this,-3),7,vobj(this,-4),vobj(this,-5))
 ;*** End of code by-passed by compiler ***
 Q 
 ;
vRCsetDefaults(this) ; 
 I ($P(vobj(this),$C(124),7)="")  S $P(vobj(this),$C(124),7)=0
 I ($P(vobj(this),$C(124),5)="")  S $P(vobj(this),$C(124),5)=0
 I ($P(vobj(this),$C(124),6)="")  S $P(vobj(this),$C(124),6)=0
 I ($P(vobj(this),$C(124),4)="")  S $P(vobj(this),$C(124),4)=0
 I ($P(vobj(this),$C(124),2)="")  S $P(vobj(this),$C(124),2)=0
 I ($P(vobj(this),$C(124),3)="")  S $P(vobj(this),$C(124),3)=0
 Q 
 ;
vRCchkReqForInsert(this) ; 
 I (vobj(this,-3)="") D vRCrequiredErr("%LIBS")
 I ($P(vobj(this),$C(124),7)="") D vRCrequiredErr("ACTAD")
 I ($P(vobj(this),$C(124),5)="") D vRCrequiredErr("ACTAI")
 I ($P(vobj(this),$C(124),6)="") D vRCrequiredErr("ACTAU")
 I ($P(vobj(this),$C(124),4)="") D vRCrequiredErr("ACTBD")
 I ($P(vobj(this),$C(124),2)="") D vRCrequiredErr("ACTBI")
 I ($P(vobj(this),$C(124),3)="") D vRCrequiredErr("ACTBU")
 I ($P(vobj(this),$C(124),1)="") D vRCrequiredErr("DES")
 I (vobj(this,-4)="") D vRCrequiredErr("TABLE")
 I (vobj(this,-5)="") D vRCrequiredErr("TRGID")
 Q 
 ;
vRCchkReqForUpdate(this) ; 
 I (vobj(this,-3)="") D vRCrequiredErr("%LIBS")
 I (vobj(this,-4)="") D vRCrequiredErr("TABLE")
 I (vobj(this,-5)="") D vRCrequiredErr("TRGID")
 I ($D(vobj(this,-100,"0*","ACTAD"))&($P($E($G(vobj(this,-100,"0*","ACTAD")),5,9999),$C(124))'=$P(vobj(this),$C(124),7))),($P(vobj(this),$C(124),7)="") D vRCrequiredErr("ACTAD")
 I ($D(vobj(this,-100,"0*","ACTAI"))&($P($E($G(vobj(this,-100,"0*","ACTAI")),5,9999),$C(124))'=$P(vobj(this),$C(124),5))),($P(vobj(this),$C(124),5)="") D vRCrequiredErr("ACTAI")
 I ($D(vobj(this,-100,"0*","ACTAU"))&($P($E($G(vobj(this,-100,"0*","ACTAU")),5,9999),$C(124))'=$P(vobj(this),$C(124),6))),($P(vobj(this),$C(124),6)="") D vRCrequiredErr("ACTAU")
 I ($D(vobj(this,-100,"0*","ACTBD"))&($P($E($G(vobj(this,-100,"0*","ACTBD")),5,9999),$C(124))'=$P(vobj(this),$C(124),4))),($P(vobj(this),$C(124),4)="") D vRCrequiredErr("ACTBD")
 I ($D(vobj(this,-100,"0*","ACTBI"))&($P($E($G(vobj(this,-100,"0*","ACTBI")),5,9999),$C(124))'=$P(vobj(this),$C(124),2))),($P(vobj(this),$C(124),2)="") D vRCrequiredErr("ACTBI")
 I ($D(vobj(this,-100,"0*","ACTBU"))&($P($E($G(vobj(this,-100,"0*","ACTBU")),5,9999),$C(124))'=$P(vobj(this),$C(124),3))),($P(vobj(this),$C(124),3)="") D vRCrequiredErr("ACTBU")
 I ($D(vobj(this,-100,"0*","DES"))&($P($E($G(vobj(this,-100,"0*","DES")),5,9999),$C(124))'=$P(vobj(this),$C(124),1))),($P(vobj(this),$C(124),1)="") D vRCrequiredErr("DES")
 Q 
 ;
vRCrequiredErr(column) ; 
 N ER S ER=0
 N RM S RM=""
 D SETERR^DBSEXECU("DBTBL7","MSG",1767,"DBTBL7."_column)
 I ER D throwError($get(RM))
 Q 
 ;
vRCsetForeignKeys(this) ; 
 I '(vobj(this,-4)="") S vfkey("^DBTBL("_""""_vobj(this,-3)_""""_","_1_","_""""_vobj(this,-4)_""""_")")="DBTBL7(%LIBS,TABLE) -> DBTBL1"
 Q 
 ;
vRCcheckForeignKeys(this) ; 
  N V1,V2 S V1=vobj(this,-3),V2=vobj(this,-4) I '($D(^DBTBL(V1,1,V2))) D throwError($$^MSG(8563,"DBTBL7(%LIBS,TABLE) -> DBTBL1"))
 Q 
 ;
vRCTrig1(this,dbtbl7,vpar) ; Trigger BEFORE_UPD_INS - Before Update or Insert - BI BU
 ;
 N columns S columns=$P(vobj(this),$C(124),8)
 ;
 Q:'($P(vobj(this),$C(124),3)!$P(vobj(this),$C(124),6))  ; Not an update trigger
 Q:($E(vobj(this,-5),1)="Z")  ; Z-named OK
 ;
 N ds,vos1,vos2,vos3,vos4,vos5,vos6  N V1,V2 S V1=vobj(this,-4),V2=vobj(this,-5) S ds=$$vOpen1()
 ;
 F  Q:'$$vFetch1()  D
 .	;
 .	N i
 .	N othercols
 .	;
 . N othertrig,vop1 S vop1=$P(ds,$C(9),3),othertrig=$$vRCgetRecord1Opt^RecordDBTBL7($P(ds,$C(9),1),$P(ds,$C(9),2),vop1,1,"")
 .	;
 .	S othercols=$P(othertrig,$C(124),8)
 .	;
 .	F i=1:1:$S((columns=""):0,1:$L(columns,",")) I ((","_othercols_",")[(","_$piece(columns,",",i)_",")) D
 ..		;
 ..		N errmsg S errmsg="Column "_$piece(columns,",",i)_" already defined by trigger "_vop1
 ..		;
 ..		I $P(vobj(this),$C(124),3),$P(othertrig,$C(124),3) D throwError(errmsg)
 ..		I $P(vobj(this),$C(124),6),$P(othertrig,$C(124),6) D throwError(errmsg)
 ..		Q 
 . Q 
 ;
 Q 
 ;
vRCbeforeInsTrigs(this,vRCparams) ; 
 N ER S ER=0
 N vRCfire
 N RM S RM=""
 N %LIBS S %LIBS=vobj(this,-3)
 N TABLE S TABLE=vobj(this,-4)
 N TRGID S TRGID=vobj(this,-5)
 D vRCTrig1(this,this,vRCparams) I ER D throwError($get(RM))
 Q 
 ;
vRCbeforeUpdTrigs(this,vRCparams,vRCaudit) ; 
 N ER S ER=0
 N vRCfire
 N RM S RM=""
 N %LIBS S %LIBS=vobj(this,-3)
 N TABLE S TABLE=vobj(this,-4)
 N TRGID S TRGID=vobj(this,-5)
 Q:'$D(vobj(this,-100)) 
 S vRCfire=0
 I ($D(vobj(this,-100,"0*","COLUMNS"))&($P($E($G(vobj(this,-100,"0*","COLUMNS")),5,9999),$C(124))'=$P(vobj(this),$C(124),8))) S vRCfire=1
 I vRCfire D vRCTrig1(this,this,vRCparams) I ER D throwError($get(RM))
 D AUDIT^UCUTILN(this,.vRCaudit,10,"|")
 Q 
 ;
vRCvalidateDD(this,processMode) ; 
 N ER S ER=0
 N RM S RM=""
 N errmsg N X
 I ($L(vobj(this,-3))>12) D vRCvalidateDDerr("%LIBS",$$^MSG(1076,12))
 I (vobj(this,-4)'=$ZCONVERT(vobj(this,-4),"U")) D vRCvalidateDDerr("TABLE",$$^MSG(1476))
 I ($L(vobj(this,-4))>25) D vRCvalidateDDerr("TABLE",$$^MSG(1076,25))
 I ($L(vobj(this,-5))>20) D vRCvalidateDDerr("TRGID",$$^MSG(1076,20))
 I '(($P(vobj(this),$C(124),7)=1)!($P(vobj(this),$C(124),7)=0)) D vRCvalidateDDerr("ACTAD",$$^MSG(742,"L"))
 I '(($P(vobj(this),$C(124),5)=1)!($P(vobj(this),$C(124),5)=0)) D vRCvalidateDDerr("ACTAI",$$^MSG(742,"L"))
 I '(($P(vobj(this),$C(124),6)=1)!($P(vobj(this),$C(124),6)=0)) D vRCvalidateDDerr("ACTAU",$$^MSG(742,"L"))
 I '(($P(vobj(this),$C(124),4)=1)!($P(vobj(this),$C(124),4)=0)) D vRCvalidateDDerr("ACTBD",$$^MSG(742,"L"))
 I '(($P(vobj(this),$C(124),2)=1)!($P(vobj(this),$C(124),2)=0)) D vRCvalidateDDerr("ACTBI",$$^MSG(742,"L"))
 I '(($P(vobj(this),$C(124),3)=1)!($P(vobj(this),$C(124),3)=0)) D vRCvalidateDDerr("ACTBU",$$^MSG(742,"L"))
 I ($P(vobj(this),$C(124),8)'=$ZCONVERT($P(vobj(this),$C(124),8),"U")) D vRCvalidateDDerr("COLUMNS",$$^MSG(1476))
 I ($L($P(vobj(this),$C(124),8))>255) D vRCvalidateDDerr("COLUMNS",$$^MSG(1076,255))
 I ($L($P(vobj(this),$C(124),1))>40) D vRCvalidateDDerr("DES",$$^MSG(1076,40))
 I ($L($P(vobj(this),$C(124),12))>255) D vRCvalidateDDerr("IFCOND",$$^MSG(1076,255))
 I ($L($P(vobj(this),$C(124),13))>10) D vRCvalidateDDerr("PROCMODE",$$^MSG(1076,10))
 S X=$P(vobj(this),$C(124),11) I '(X=""),(X'?1.5N) D vRCvalidateDDerr("TIME",$$^MSG(742,"C"))
 S X=$P(vobj(this),$C(124),9) I '(X=""),(X'?1.5N) D vRCvalidateDDerr("TLD",$$^MSG(742,"D"))
 I ($L($P(vobj(this),$C(124),10))>20) D vRCvalidateDDerr("USER",$$^MSG(1076,20))
 Q 
 ;
vRCvalidateDD1(this) ; 
 N ER S ER=0
 N RM S RM=""
 N errmsg N X
 I ($D(vobj(this,-100,"1*","%LIBS"))&($P($E($G(vobj(this,-100,"1*","%LIBS")),5,9999),$C(124))'=vobj(this,-3))) I ($L(vobj(this,-3))>12) D vRCvalidateDDerr("%LIBS",$$^MSG(1076,12))
 I (vobj(this,-4)'=$ZCONVERT(vobj(this,-4),"U")) D vRCvalidateDDerr("TABLE",$$^MSG(1476))
 I ($D(vobj(this,-100,"2*","TABLE"))&($P($E($G(vobj(this,-100,"2*","TABLE")),5,9999),$C(124))'=vobj(this,-4))) I ($L(vobj(this,-4))>25) D vRCvalidateDDerr("TABLE",$$^MSG(1076,25))
 I ($D(vobj(this,-100,"3*","TRGID"))&($P($E($G(vobj(this,-100,"3*","TRGID")),5,9999),$C(124))'=vobj(this,-5))) I ($L(vobj(this,-5))>20) D vRCvalidateDDerr("TRGID",$$^MSG(1076,20))
 I ($D(vobj(this,-100,"0*","ACTAD"))&($P($E($G(vobj(this,-100,"0*","ACTAD")),5,9999),$C(124))'=$P(vobj(this),$C(124),7))) I '(($P(vobj(this),$C(124),7)=1)!($P(vobj(this),$C(124),7)=0)) D vRCvalidateDDerr("ACTAD",$$^MSG(742,"L"))
 I ($D(vobj(this,-100,"0*","ACTAI"))&($P($E($G(vobj(this,-100,"0*","ACTAI")),5,9999),$C(124))'=$P(vobj(this),$C(124),5))) I '(($P(vobj(this),$C(124),5)=1)!($P(vobj(this),$C(124),5)=0)) D vRCvalidateDDerr("ACTAI",$$^MSG(742,"L"))
 I ($D(vobj(this,-100,"0*","ACTAU"))&($P($E($G(vobj(this,-100,"0*","ACTAU")),5,9999),$C(124))'=$P(vobj(this),$C(124),6))) I '(($P(vobj(this),$C(124),6)=1)!($P(vobj(this),$C(124),6)=0)) D vRCvalidateDDerr("ACTAU",$$^MSG(742,"L"))
 I ($D(vobj(this,-100,"0*","ACTBD"))&($P($E($G(vobj(this,-100,"0*","ACTBD")),5,9999),$C(124))'=$P(vobj(this),$C(124),4))) I '(($P(vobj(this),$C(124),4)=1)!($P(vobj(this),$C(124),4)=0)) D vRCvalidateDDerr("ACTBD",$$^MSG(742,"L"))
 I ($D(vobj(this,-100,"0*","ACTBI"))&($P($E($G(vobj(this,-100,"0*","ACTBI")),5,9999),$C(124))'=$P(vobj(this),$C(124),2))) I '(($P(vobj(this),$C(124),2)=1)!($P(vobj(this),$C(124),2)=0)) D vRCvalidateDDerr("ACTBI",$$^MSG(742,"L"))
 I ($D(vobj(this,-100,"0*","ACTBU"))&($P($E($G(vobj(this,-100,"0*","ACTBU")),5,9999),$C(124))'=$P(vobj(this),$C(124),3))) I '(($P(vobj(this),$C(124),3)=1)!($P(vobj(this),$C(124),3)=0)) D vRCvalidateDDerr("ACTBU",$$^MSG(742,"L"))
 I ($P(vobj(this),$C(124),8)'=$ZCONVERT($P(vobj(this),$C(124),8),"U")) D vRCvalidateDDerr("COLUMNS",$$^MSG(1476))
 I ($D(vobj(this,-100,"0*","COLUMNS"))&($P($E($G(vobj(this,-100,"0*","COLUMNS")),5,9999),$C(124))'=$P(vobj(this),$C(124),8))) I ($L($P(vobj(this),$C(124),8))>255) D vRCvalidateDDerr("COLUMNS",$$^MSG(1076,255))
 I ($D(vobj(this,-100,"0*","DES"))&($P($E($G(vobj(this,-100,"0*","DES")),5,9999),$C(124))'=$P(vobj(this),$C(124),1))) I ($L($P(vobj(this),$C(124),1))>40) D vRCvalidateDDerr("DES",$$^MSG(1076,40))
 I ($D(vobj(this,-100,"0*","IFCOND"))&($P($E($G(vobj(this,-100,"0*","IFCOND")),5,9999),$C(124))'=$P(vobj(this),$C(124),12))) I ($L($P(vobj(this),$C(124),12))>255) D vRCvalidateDDerr("IFCOND",$$^MSG(1076,255))
 I ($D(vobj(this,-100,"0*","PROCMODE"))&($P($E($G(vobj(this,-100,"0*","PROCMODE")),5,9999),$C(124))'=$P(vobj(this),$C(124),13))) I ($L($P(vobj(this),$C(124),13))>10) D vRCvalidateDDerr("PROCMODE",$$^MSG(1076,10))
 I ($D(vobj(this,-100,"0*","TIME"))&($P($E($G(vobj(this,-100,"0*","TIME")),5,9999),$C(124))'=$P(vobj(this),$C(124),11))) S X=$P(vobj(this),$C(124),11) I '(X=""),(X'?1.5N) D vRCvalidateDDerr("TIME",$$^MSG(742,"C"))
 I ($D(vobj(this,-100,"0*","TLD"))&($P($E($G(vobj(this,-100,"0*","TLD")),5,9999),$C(124))'=$P(vobj(this),$C(124),9))) S X=$P(vobj(this),$C(124),9) I '(X=""),(X'?1.5N) D vRCvalidateDDerr("TLD",$$^MSG(742,"D"))
 I ($D(vobj(this,-100,"0*","USER"))&($P($E($G(vobj(this,-100,"0*","USER")),5,9999),$C(124))'=$P(vobj(this),$C(124),10))) I ($L($P(vobj(this),$C(124),10))>20) D vRCvalidateDDerr("USER",$$^MSG(1076,20))
 Q 
 ;
vRCvalidateDDerr(column,errmsg) ; 
 N ER S ER=0
 N RM S RM=""
 D SETERR^DBSEXECU("DBTBL7","MSG",979,"DBTBL7."_column_" "_errmsg)
 I ER D throwError($get(RM))
 Q 
 ;
vRCtrimNumber(str) ; 
 I ($E(str,1)="0") S str=$$vStrTrim(str,-1,"0") I (str="") S str="0"
 I (str["."),($E(str,$L(str))="0") S str=$$RTCHR^%ZFUNC(str,"0") I ($E(str,$L(str))=".") S str=$E(str,1,$L(str)-1) I (str="") S str="0"
 Q str
 ;
vRCkeyChanged(this,vRCparams,vRCaudit) ; 
 N vTp
 N newkeys N oldkeys N vRCauditIns
 N newKey1 S newKey1=vobj(this,-3)
 N oldKey1 S oldKey1=$S($D(vobj(this,-100,"1*","%LIBS")):$P($E(vobj(this,-100,"1*","%LIBS"),5,9999),$C(124)),1:vobj(this,-3))
 N newKey2 S newKey2=vobj(this,-4)
 N oldKey2 S oldKey2=$S($D(vobj(this,-100,"2*","TABLE")):$P($E(vobj(this,-100,"2*","TABLE"),5,9999),$C(124)),1:vobj(this,-4))
 N newKey3 S newKey3=vobj(this,-5)
 N oldKey3 S oldKey3=$S($D(vobj(this,-100,"3*","TRGID")):$P($E(vobj(this,-100,"3*","TRGID"),5,9999),$C(124)),1:vobj(this,-5))
  N V1,V2,V3 S V1=vobj(this,-3),V2=vobj(this,-4),V3=vobj(this,-5) I ($D(^DBTBL(V1,7,V2,V3))#2) D throwError($$^MSG(2327))
 S newkeys=newKey1_","_newKey2_","_newKey3
 S oldkeys=oldKey1_","_oldKey2_","_oldKey3
  S vobj(this,-3)=oldKey1
  S vobj(this,-4)=oldKey2
  S vobj(this,-5)=oldKey3
 S vRCparams=$$setPar^UCUTILN(vRCparams,"NOINDEX")
 I (("/"_vRCparams_"/")["/VALREQ/") D vRCchkReqForInsert(this)
 I (("/"_vRCparams_"/")["/TRIGBEF/") D vRCbeforeUpdTrigs(this,vRCparams,.vRCaudit)
 I (("/"_vRCparams_"/")["/VALDD/") D vRCvalidateDD(this,1)
 D vRCmiscValidations(this,vRCparams,1)
 D vRCupdateDB(this,1,vRCparams,.vRCaudit,.vRCauditIns)
  S vobj(this,-3)=newKey1
  S vobj(this,-4)=newKey2
  S vobj(this,-5)=newKey3
 N newrec S newrec=$$vReCp1(this)
 S vobj(newrec,-2)=0
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL7(newrec,$$initPar^UCUTILN($$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/"))) K vobj(newrec,-100) S vobj(newrec,-2)=1 TC:vTp  
 D
 .	N %O S %O=1
 .	N ER S ER=0
 .	N RM S RM=""
 .	;   #ACCEPT Date=10/24/2008; Pgm=RussellDS; CR=30801; Group=ACCESS
 .	D CASUPD^DBSEXECU("DBTBL7",oldkeys,newkeys)
 .	I ER D throwError($get(RM))
 .	Q 
  S vobj(this,-3)=oldKey1
  S vobj(this,-4)=oldKey2
  S vobj(this,-5)=oldKey3
 S vRCparams=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
 D vRCdelete(this,vRCparams,.vRCaudit,1)
  S vobj(this,-3)=newKey1
  S vobj(this,-4)=newKey2
  S vobj(this,-5)=newKey3
 K vobj(+$G(newrec)) Q 
 ;
vRCcascadeDelete(this,vRCparams) ; 
  N V1,V2,V3 S V1=vobj(this,-3),V2=vobj(this,-4),V3=vobj(this,-5) D vDbDe1()
 Q 
 ;
throwError(MSG) ; 
 S $ZE="0,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(MSG,",","~"),$EC=",U1001,"
 Q 
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
vStrTrim(object,p1,p2) ; String.trim
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I p1'<0 S object=$$RTCHR^%ZFUNC(object,p2)
 I p1'>0 F  Q:$E(object,1)'=p2  S object=$E(object,2,1048575)
 Q object
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM DBTBL7D WHERE %LIBS=:V1 AND TABLE=:V2 AND TRGID=:V3
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2 N v3 N v4
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4,vos5,vos6 S vRs=$$vOpen2()
 F  Q:'$$vFetch2()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3) S v4=$P(vRs,$C(9),4)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^DBTBL(v1,7,v2,v3,v4)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
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
vOpen1() ; %LIBS,TABLE,TRGID FROM DBTBL7 WHERE %LIBS='SYSDEV' AND TABLE=:V1 AND TRGID<>:V2 AND TRGID NOT LIKE 'Z%' AND (ACTBU=1 OR ACTAU=1)
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL1a0
 S vos4=$G(V2) I vos4="",'$D(V2) G vL1a0
 S vos5=""
vL1a5 S vos5=$O(^DBTBL("SYSDEV",7,vos3,vos5),1) I vos5="" G vL1a0
 I '(vos5'=vos4) G vL1a5
 I '(vos5'?1"Z".E) G vL1a5
 S vos6=$G(^DBTBL("SYSDEV",7,vos3,vos5))
 I '((+$P(vos6,"|",3)=1!(+$P(vos6,"|",6)=1))) G vL1a5
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a5
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds="" Q 0
 ;
 S vos6=$G(^DBTBL("SYSDEV",7,vos3,vos5))
 S ds="SYSDEV"_$C(9)_vos3_$C(9)_$S(vos5=vos2:"",1:vos5)
 ;
 Q 1
 ;
vOpen2() ; %LIBS,TABLE,TRGID,SEQ FROM DBTBL7D WHERE %LIBS=:V1 AND TABLE=:V2 AND TRGID=:V3
 ;
 ;
 S vos1=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos1=0 Q
vL2a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL2a0
 S vos4=$G(V2) I vos4="" G vL2a0
 S vos5=$G(V3) I vos5="" G vL2a0
 S vos6=""
vL2a6 S vos6=$O(^DBTBL(vos3,7,vos4,vos5,vos6),1) I vos6="" G vL2a0
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos1=1 D vL2a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=vos3_$C(9)_vos4_$C(9)_vos5_$C(9)_$S(vos6=vos2:"",1:vos6)
 ;
 Q 1
 ;
vReCp1(v1) ; RecordDBTBL7.copy: DBTBL7
 ;
 Q $$copy^UCGMR(this)
