 ; 
 ; **** Routine compiled from DATA-QWIK Filer RecordDBIMPORTD ****
 ; 
 ; 02/24/2010 18:39 - pip
 ; 
 ;
 ; Record Class code for table DBIMPORTD
 ;
 ; Generated by PSLRecordBuilder on 02/24/2010 at 18:39 by
 ;
vcdmNew() ; 
 N vOid
 ;  #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=BYPASS
 ;*** Start of code by-passed by compiler
 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBIMPORTD",vobj(vOid,-2)=0
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
 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBIMPORTD"
 I '$D(^DBIMPORT(v1,v2,v3))
 S vobj(vOid,-2)=1
 I $T K vobj(vOid) S $ZE="0,"_$ZPOS_",%PSL-E-RECNOFL,,DBIMPORTD",$EC=",U1001,"
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
 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBIMPORTD"
 I '$D(^DBIMPORT(v1,v2,v3))
 S vobj(vOid,-2)='$T
 S vobj(vOid,-3)=v1
 S vobj(vOid,-4)=v2
 S vobj(vOid,-5)=v3
 ;*** End of code by-passed by compiler ***
 ;  #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=SCOPE
 Q vOid
 ;
vRCgetRecord0Opt(v1,v2,v3,vfromDbSet,v2out) ; 
 ;  #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=BYPASS
 ;*** Start of code by-passed by compiler
 I '$D(^DBIMPORT(v1,v2,v3))
 S v2out=1
 I $T S $ZE="0,"_$ZPOS_",%PSL-E-RECNOFL,,DBIMPORTD",$EC=",U1001,"
 ;*** End of code by-passed by compiler ***
 Q ""
 ;
vRCgetRecord1Opt(v1,v2,v3,vfromDbSet,v2out) ; 
 ;  #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=BYPASS
 ;*** Start of code by-passed by compiler
 I '$D(^DBIMPORT(v1,v2,v3))
 S v2out='$T
 ;*** End of code by-passed by compiler ***
 Q ""
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
 .	D AUDIT^UCUTILN(this,.vRCauditIns,10,"|")
 .	D vRCsetDefaults(this)
 .	I (("/"_vRCparams_"/")["/VALREQ/") D vRCchkReqForInsert(this)
 .	I (("/"_vRCparams_"/")["/VALDD/") D vRCvalidateDD(this,%O)
 .	D vRCmiscValidations(this,vRCparams,%O)
 .	D vRCupdateDB(this,%O,vRCparams,.vRCaudit,.vRCauditIns)
 .	Q 
 E  I (%O=1) D
 .	Q:'$D(vobj(this,-100)) 
 .	D AUDIT^UCUTILN(this,.vRCaudit,10,"|")
 .	I ($D(vobj(this,-100,"1*","IDATE"))&($P($E($G(vobj(this,-100,"1*","IDATE")),5,9999),$C(124))'=vobj(this,-3)))!($D(vobj(this,-100,"2*","FNAME"))&($P($E($G(vobj(this,-100,"2*","FNAME")),5,9999),$C(124))'=vobj(this,-4)))!($D(vobj(this,-100,"3*","SEQ"))&($P($E($G(vobj(this,-100,"3*","SEQ")),5,9999),$C(124))'=vobj(this,-5))) D vRCkeyChanged(this,vRCparams,.vRCaudit) Q 
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
 .	  N V1,V2,V3 S V1=vobj(this,-3),V2=vobj(this,-4),V3=vobj(this,-5) Q:'($D(^DBIMPORT(V1,V2,V3))>9) 
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
vselectOptmOK(userclass,dbimportd,vkey1,vkey2,vkey3) ; PUBLIC access is allowed, no restrict clause
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
 Q $$vStrRep("CDTFMTD,CDTS,DELFLAG,ELEMNAME,ELEMTYPE,FNAME,IDATE,SEQ",",",$char(9),0,0,"")
 ;
columnListBM() ; 
 Q ""
 ;
columnListCMP() ; 
 Q $$vStrRep("",",",$char(9),0,0,"")
 ;
getColumnMap(map) ; 
 ;
 S map(-5)="SEQ:N:"
 S map(-4)="FNAME:U:"
 S map(-3)="IDATE:D:"
 S map("SEQ")="CDTFMTD:T:5;CDTS:T:4;DELFLAG:L:3;ELEMNAME:T:2;ELEMTYPE:T:1"
 Q 
 ;
vlegacy(processMode,params) ; 
 N vTp
 I (processMode=2) D
 .	N dbimportd S dbimportd=$$vRCgetRecord0^RecordDBIMPORTD(IDATE,FNAME,SEQ,0)
 .	S vobj(dbimportd,-2)=2
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBIMPORTD(dbimportd,$$initPar^UCUTILN(params)) K vobj(dbimportd,-100) S vobj(dbimportd,-2)=1 TC:vTp  
 .	K vobj(+$G(dbimportd)) Q 
 Q 
 ;
vhasLiterals() ; 
 Q 0
 ;
vRCmiscValidations(this,vRCparams,processMode) ; 
 I (("/"_vRCparams_"/")["/VALST/")  N V1,V2,V3 S V1=vobj(this,-3),V2=vobj(this,-4),V3=vobj(this,-5) I '(''($D(^DBIMPORT(V1,V2,V3))>9)=''processMode) D
 .	N errmsg
 .	I (+processMode'=+0) S errmsg=$$^MSG(7932)
 .	E  S errmsg=$$^MSG(2327)
 .	D throwError(errmsg)
 .	Q 
 Q 
 ;
vRCupdateDB(this,processMode,vRCparams,vRCaudit,vRCauditIns) ; 
 I '(("/"_vRCparams_"/")["/NOUPDATE/") D
 .	N n
 .	S n=-1
 .	F  S n=$order(vobj(this,n)) Q:(n="")  D
 ..		Q:'($D(vobj(this,n))#2) 
 ..		;    #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
 ..		;*** Start of code by-passed by compiler
 ..		S ^DBIMPORT(vobj(this,-3),vobj(this,-4),vobj(this,-5),n)=vobj(this,n)
 ..		;*** End of code by-passed by compiler ***
 ..		Q 
 .	Q 
 Q 
 ;
vRCdelete(this,vRCparams,vRCaudit,isKeyChange) ; 
 I '$get(isKeyChange),$D(vobj(this,-100)) D throwError("Deleted object cannot be modified")
 ;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
 ;*** Start of code by-passed by compiler
 kill ^DBIMPORT(vobj(this,-3),vobj(this,-4),vobj(this,-5))
 ;*** End of code by-passed by compiler ***
 Q 
 ;
vRCsetDefaults(this) ; 
  S:'$D(vobj(this,"SEQ")) vobj(this,"SEQ")=$S(vobj(this,-2):$G(^DBIMPORT(vobj(this,-3),vobj(this,-4),vobj(this,-5),"SEQ")),1:"")
 I ($P(vobj(this,"SEQ"),$C(124),3)="")  S vobj(this,-100,"SEQ")="" S $P(vobj(this,"SEQ"),$C(124),3)=0
 Q 
 ;
vRCchkReqForInsert(this) ; 
  S:'$D(vobj(this,"SEQ")) vobj(this,"SEQ")=$S(vobj(this,-2):$G(^DBIMPORT(vobj(this,-3),vobj(this,-4),vobj(this,-5),"SEQ")),1:"")
 I ($P(vobj(this,"SEQ"),$C(124),3)="") D vRCrequiredErr("DELFLAG")
 I (vobj(this,-4)="") D vRCrequiredErr("FNAME")
 I (vobj(this,-3)="") D vRCrequiredErr("IDATE")
 I (vobj(this,-5)="") D vRCrequiredErr("SEQ")
 Q 
 ;
vRCchkReqForUpdate(this) ; 
  S:'$D(vobj(this,"SEQ")) vobj(this,"SEQ")=$S(vobj(this,-2):$G(^DBIMPORT(vobj(this,-3),vobj(this,-4),vobj(this,-5),"SEQ")),1:"")
 I (vobj(this,-3)="") D vRCrequiredErr("IDATE")
 I (vobj(this,-4)="") D vRCrequiredErr("FNAME")
 I (vobj(this,-5)="") D vRCrequiredErr("SEQ")
 ; Node "1*" - only one required column
 I ($D(vobj(this,-100,"1*","IDATE"))&($P($E($G(vobj(this,-100,"1*","IDATE")),5,9999),$C(124))'=vobj(this,-3))),(vobj(this,-3)="") D vRCrequiredErr("IDATE")
 ; Node "2*" - only one required column
 I ($D(vobj(this,-100,"2*","FNAME"))&($P($E($G(vobj(this,-100,"2*","FNAME")),5,9999),$C(124))'=vobj(this,-4))),(vobj(this,-4)="") D vRCrequiredErr("FNAME")
 ; Node "3*" - only one required column
 I ($D(vobj(this,-100,"3*","SEQ"))&($P($E($G(vobj(this,-100,"3*","SEQ")),5,9999),$C(124))'=vobj(this,-5))),(vobj(this,-5)="") D vRCrequiredErr("SEQ")
 ; Node "SEQ" - only one required column
 I ($D(vobj(this,-100,"SEQ","DELFLAG"))&($P($E($G(vobj(this,-100,"SEQ","DELFLAG")),5,9999),$C(124))'=$P(vobj(this,"SEQ"),$C(124),3))),($P(vobj(this,"SEQ"),$C(124),3)="") D vRCrequiredErr("DELFLAG")
 Q 
 ;
vRCrequiredErr(column) ; 
 N ER S ER=0
 N RM S RM=""
 D SETERR^DBSEXECU("DBIMPORTD","MSG",1767,"DBIMPORTD."_column)
 I ER D throwError($get(RM))
 Q 
 ;
vRCforceLoad(this) ; 
 N n S n=""
 ;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
 ;*** Start of code by-passed by compiler
 for  set n=$order(^DBIMPORT(vobj(this,-3),vobj(this,-4),vobj(this,-5),n)) quit:n=""  if '$D(vobj(this,n)),$D(^DBIMPORT(vobj(this,-3),vobj(this,-4),vobj(this,-5),n))#2 set vobj(this,n)=^(n)
 ;*** End of code by-passed by compiler ***
 Q 
 ;
vRCvalidateDD(this,processMode) ; 
 N ER S ER=0
 N RM S RM=""
 N errmsg N X
 I (processMode=2) D vRCforceLoad(this)
 S X=vobj(this,-3) I '(X=""),(X'?1.5N) D vRCvalidateDDerr("IDATE",$$^MSG(742,"D"))
 I (vobj(this,-4)'=$ZCONVERT(vobj(this,-4),"U")) D vRCvalidateDDerr("FNAME",$$^MSG(1476))
 I ($L(vobj(this,-4))>80) D vRCvalidateDDerr("FNAME",$$^MSG(1076,80))
 I '(vobj(this,-5)=""),'(+vobj(this,-5)=vobj(this,-5))  S vobj(this,-5)=$$vRCtrimNumber(vobj(this,-5))
 S X=vobj(this,-5) I '(X=""),(X'?1.5N),(X'?1"-"1.4N) D vRCvalidateDDerr("SEQ",$$^MSG(742,"N"))
 I ($D(vobj(this,"SEQ"))#2) D
 .	 S:'$D(vobj(this,"SEQ")) vobj(this,"SEQ")=$S(vobj(this,-2):$G(^DBIMPORT(vobj(this,-3),vobj(this,-4),vobj(this,-5),"SEQ")),1:"")
 .	I ($L($P(vobj(this,"SEQ"),$C(124),5))>10) D vRCvalidateDDerr("CDTFMTD",$$^MSG(1076,10))
 .	I ($L($P(vobj(this,"SEQ"),$C(124),4))>11) D vRCvalidateDDerr("CDTS",$$^MSG(1076,11))
 .	I '(($P(vobj(this,"SEQ"),$C(124),3)=1)!($P(vobj(this,"SEQ"),$C(124),3)=0)) D vRCvalidateDDerr("DELFLAG",$$^MSG(742,"L"))
 .	I ($L($P(vobj(this,"SEQ"),$C(124),2))>40) D vRCvalidateDDerr("ELEMNAME",$$^MSG(1076,40))
 .	I ($L($P(vobj(this,"SEQ"),$C(124),1))>20) D vRCvalidateDDerr("ELEMTYPE",$$^MSG(1076,20))
 .	Q 
 Q 
 ;
vRCvalidateDD1(this) ; 
  S:'$D(vobj(this,"SEQ")) vobj(this,"SEQ")=$S(vobj(this,-2):$G(^DBIMPORT(vobj(this,-3),vobj(this,-4),vobj(this,-5),"SEQ")),1:"")
 N ER S ER=0
 N RM S RM=""
 N errmsg N X
 I ($D(vobj(this,-100,"1*","IDATE"))&($P($E($G(vobj(this,-100,"1*","IDATE")),5,9999),$C(124))'=vobj(this,-3))) S X=vobj(this,-3) I '(X=""),(X'?1.5N) D vRCvalidateDDerr("IDATE",$$^MSG(742,"D"))
 I (vobj(this,-4)'=$ZCONVERT(vobj(this,-4),"U")) D vRCvalidateDDerr("FNAME",$$^MSG(1476))
 I ($D(vobj(this,-100,"2*","FNAME"))&($P($E($G(vobj(this,-100,"2*","FNAME")),5,9999),$C(124))'=vobj(this,-4))) I ($L(vobj(this,-4))>80) D vRCvalidateDDerr("FNAME",$$^MSG(1076,80))
 I ($D(vobj(this,-100,"3*","SEQ"))&($P($E($G(vobj(this,-100,"3*","SEQ")),5,9999),$C(124))'=vobj(this,-5))),'(vobj(this,-5)=""),'(+vobj(this,-5)=vobj(this,-5))  S vobj(this,-5)=$$vRCtrimNumber(vobj(this,-5))
 I ($D(vobj(this,-100,"3*","SEQ"))&($P($E($G(vobj(this,-100,"3*","SEQ")),5,9999),$C(124))'=vobj(this,-5))) S X=vobj(this,-5) I '(X=""),(X'?1.5N),(X'?1"-"1.4N) D vRCvalidateDDerr("SEQ",$$^MSG(742,"N"))
 I ($D(vobj(this,"SEQ"))#2) D
 .	I ($D(vobj(this,-100,"SEQ","CDTFMTD"))&($P($E($G(vobj(this,-100,"SEQ","CDTFMTD")),5,9999),$C(124))'=$P(vobj(this,"SEQ"),$C(124),5))) I ($L($P(vobj(this,"SEQ"),$C(124),5))>10) D vRCvalidateDDerr("CDTFMTD",$$^MSG(1076,10))
 .	I ($D(vobj(this,-100,"SEQ","CDTS"))&($P($E($G(vobj(this,-100,"SEQ","CDTS")),5,9999),$C(124))'=$P(vobj(this,"SEQ"),$C(124),4))) I ($L($P(vobj(this,"SEQ"),$C(124),4))>11) D vRCvalidateDDerr("CDTS",$$^MSG(1076,11))
 .	I ($D(vobj(this,-100,"SEQ","DELFLAG"))&($P($E($G(vobj(this,-100,"SEQ","DELFLAG")),5,9999),$C(124))'=$P(vobj(this,"SEQ"),$C(124),3))) I '(($P(vobj(this,"SEQ"),$C(124),3)=1)!($P(vobj(this,"SEQ"),$C(124),3)=0)) D vRCvalidateDDerr("DELFLAG",$$^MSG(742,"L"))
 .	I ($D(vobj(this,-100,"SEQ","ELEMNAME"))&($P($E($G(vobj(this,-100,"SEQ","ELEMNAME")),5,9999),$C(124))'=$P(vobj(this,"SEQ"),$C(124),2))) I ($L($P(vobj(this,"SEQ"),$C(124),2))>40) D vRCvalidateDDerr("ELEMNAME",$$^MSG(1076,40))
 .	I ($D(vobj(this,-100,"SEQ","ELEMTYPE"))&($P($E($G(vobj(this,-100,"SEQ","ELEMTYPE")),5,9999),$C(124))'=$P(vobj(this,"SEQ"),$C(124),1))) I ($L($P(vobj(this,"SEQ"),$C(124),1))>20) D vRCvalidateDDerr("ELEMTYPE",$$^MSG(1076,20))
 .	Q 
 Q 
 ;
vRCvalidateDDerr(column,errmsg) ; 
 N ER S ER=0
 N RM S RM=""
 D SETERR^DBSEXECU("DBIMPORTD","MSG",979,"DBIMPORTD."_column_" "_errmsg)
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
 N oldKey1 S oldKey1=$S($D(vobj(this,-100,"1*","IDATE")):$P($E(vobj(this,-100,"1*","IDATE"),5,9999),$C(124)),1:vobj(this,-3))
 N newKey2 S newKey2=vobj(this,-4)
 N oldKey2 S oldKey2=$S($D(vobj(this,-100,"2*","FNAME")):$P($E(vobj(this,-100,"2*","FNAME"),5,9999),$C(124)),1:vobj(this,-4))
 N newKey3 S newKey3=vobj(this,-5)
 N oldKey3 S oldKey3=$S($D(vobj(this,-100,"3*","SEQ")):$P($E(vobj(this,-100,"3*","SEQ"),5,9999),$C(124)),1:vobj(this,-5))
  N V1,V2,V3 S V1=vobj(this,-3),V2=vobj(this,-4),V3=vobj(this,-5) I ($D(^DBIMPORT(V1,V2,V3))>9) D throwError($$^MSG(2327))
 S newkeys=newKey1_","_newKey2_","_newKey3
 S oldkeys=oldKey1_","_oldKey2_","_oldKey3
  S vobj(this,-3)=oldKey1
  S vobj(this,-4)=oldKey2
  S vobj(this,-5)=oldKey3
 S vRCparams=$$setPar^UCUTILN(vRCparams,"NOINDEX")
 D vRCforceLoad(this)
 I (("/"_vRCparams_"/")["/VALREQ/") D vRCchkReqForInsert(this)
 I (("/"_vRCparams_"/")["/VALDD/") D vRCvalidateDD(this,1)
 D vRCmiscValidations(this,vRCparams,1)
 D vRCupdateDB(this,1,vRCparams,.vRCaudit,.vRCauditIns)
  S vobj(this,-3)=newKey1
  S vobj(this,-4)=newKey2
  S vobj(this,-5)=newKey3
 N newrec S newrec=$$vReCp1(this)
 S vobj(newrec,-2)=0
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBIMPORTD(newrec,$$initPar^UCUTILN($$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/"))) K vobj(newrec,-100) S vobj(newrec,-2)=1 TC:vTp  
 D
 .	N %O S %O=1
 .	N ER S ER=0
 .	N RM S RM=""
 .	;   #ACCEPT Date=10/24/2008; Pgm=RussellDS; CR=30801; Group=ACCESS
 .	D CASUPD^DBSEXECU("DBIMPORTD",oldkeys,newkeys)
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
vReCp1(v1) ; RecordDBIMPORTD.copy: DBIMPORTD
 ;
 N vNod,vOid
 I $G(vobj(v1,-2)) D
 .	F vNod="SEQ" S:'$D(vobj(v1,vNod)) vobj(v1,vNod)=$G(^DBIMPORT(vobj(v1,-3),vobj(v1,-4),vobj(v1,-5),vNod))
 S vOid=$$copy^UCGMR(v1)
 Q vOid