 ; 
 ; **** Routine compiled from DATA-QWIK Filer RecordERROR9 ****
 ; 
 ; 02/24/2010 18:40 - pip
 ; 
 ;
 ; Record Class code for table ERROR9
 ;
 ; Generated by PSLRecordBuilder on 02/24/2010 at 18:40 by
 ;
vcdmNew() ; 
 N vOid
 ;  #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=BYPASS
 ;*** Start of code by-passed by compiler
 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordERROR9",vobj(vOid,-2)=0,vobj(vOid)=""
 S vobj(vOid,-3)=""
 S vobj(vOid,-4)=""
 S vobj(vOid,-5)=""
 S vobj(vOid,-6)=""
 ;*** End of code by-passed by compiler ***
 ;  #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=SCOPE
 Q vOid
 ;
vRCgetRecord0(v1,v2,v3,v4,vfromDbSet) ; 
 N vOid
 ;  #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=BYPASS
 ;*** Start of code by-passed by compiler
 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordERROR9"
 S vobj(vOid)=$G(^ERROR(v1,v2,v3,9,v4))
 I vobj(vOid)="",'($D(^ERROR(v1,v2,v3,9,v4))#2)
 S vobj(vOid,-2)=1
 I $T K vobj(vOid) S $ZE="0,"_$ZPOS_",%PSL-E-RECNOFL,,ERROR9",$EC=",U1001,"
 S vobj(vOid,-3)=v1
 S vobj(vOid,-4)=v2
 S vobj(vOid,-5)=v3
 S vobj(vOid,-6)=v4
 ;*** End of code by-passed by compiler ***
 ;  #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=SCOPE
 Q vOid
 ;
vRCgetRecord1(v1,v2,v3,v4,vfromDbSet) ; 
 N vOid
 ;  #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=BYPASS
 ;*** Start of code by-passed by compiler
 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordERROR9"
 S vobj(vOid)=$G(^ERROR(v1,v2,v3,9,v4))
 I vobj(vOid)="",'($D(^ERROR(v1,v2,v3,9,v4))#2)
 S vobj(vOid,-2)='$T
 S vobj(vOid,-3)=v1
 S vobj(vOid,-4)=v2
 S vobj(vOid,-5)=v3
 S vobj(vOid,-6)=v4
 ;*** End of code by-passed by compiler ***
 ;  #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=SCOPE
 Q vOid
 ;
vRCgetRecord0Opt(v1,v2,v3,v4,vfromDbSet,v2out) ; 
 N error9
 ;  #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=BYPASS
 ;*** Start of code by-passed by compiler
 S error9=$G(^ERROR(v1,v2,v3,9,v4))
 I error9="",'($D(^ERROR(v1,v2,v3,9,v4))#2)
 S v2out=1
 I $T S $ZE="0,"_$ZPOS_",%PSL-E-RECNOFL,,ERROR9",$EC=",U1001,"
 ;*** End of code by-passed by compiler ***
 Q error9
 ;
vRCgetRecord1Opt(v1,v2,v3,v4,vfromDbSet,v2out) ; 
 N error9
 ;  #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=BYPASS
 ;*** Start of code by-passed by compiler
 S error9=$G(^ERROR(v1,v2,v3,9,v4))
 I error9="",'($D(^ERROR(v1,v2,v3,9,v4))#2)
 S v2out='$T
 ;*** End of code by-passed by compiler ***
 Q error9
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
 .	D AUDIT^UCUTILN(this,.vRCauditIns,1,$char(12))
 .	I (("/"_vRCparams_"/")["/VALREQ/") D vRCchkReqForInsert(this)
 .	I (("/"_vRCparams_"/")["/VALDD/") D vRCvalidateDD(this,%O)
 .	D vRCmiscValidations(this,vRCparams,%O)
 .	D vRCupdateDB(this,%O,vRCparams,.vRCaudit,.vRCauditIns)
 .	Q 
 E  I (%O=1) D
 .	D AUDIT^UCUTILN(this,.vRCaudit,1,$char(12))
 .	I ($D(vobj(this,-100,"1*","DATE"))&($P($E($G(vobj(this,-100,"1*","DATE")),5,9999),$C(12))'=vobj(this,-3)))!($D(vobj(this,-100,"2*","ET"))&($P($E($G(vobj(this,-100,"2*","ET")),5,9999),$C(12))'=vobj(this,-4)))!($D(vobj(this,-100,"3*","SEQ"))&($P($E($G(vobj(this,-100,"3*","SEQ")),5,9999),$C(12))'=vobj(this,-5)))!($D(vobj(this,-100,"4*","VAR"))&($P($E($G(vobj(this,-100,"4*","VAR")),5,9999),$C(12))'=vobj(this,-6))) D vRCkeyChanged(this,vRCparams,.vRCaudit) Q 
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
 .	  N V1,V2,V3,V4 S V1=vobj(this,-3),V2=vobj(this,-4),V3=vobj(this,-5),V4=vobj(this,-6) Q:'($D(^ERROR(V1,V2,V3,9,V4))#2) 
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
vselectOptmOK(userclass,error9,vkey1,vkey2,vkey3,vkey4) ; PUBLIC access is allowed, no restrict clause
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
 Q $$vStrRep("DATE,ET,SEQ,VALUE,VAR",",",$char(9),0,0,"")
 ;
columnListBM() ; 
 Q ""
 ;
columnListCMP() ; 
 Q $$vStrRep("",",",$char(9),0,0,"")
 ;
getColumnMap(map) ; 
 ;
 S map(-6)="VAR:T:"
 S map(-5)="SEQ:N:"
 S map(-4)="ET:T:"
 S map(-3)="DATE:D:"
 S map(-1)="VALUE:T:1"
 Q 
 ;
vlegacy(processMode,params) ; 
 N vTp
 I (processMode=2) D
 .	N error9 S error9=$$vRCgetRecord0^RecordERROR9(DATE,ET,SEQ,VAR,0)
 .	S vobj(error9,-2)=2
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordERROR9(error9,$$initPar^UCUTILN(params)) K vobj(error9,-100) S vobj(error9,-2)=1 TC:vTp  
 .	K vobj(+$G(error9)) Q 
 Q 
 ;
vhasLiterals() ; 
 Q 0
 ;
vRCmiscValidations(this,vRCparams,processMode) ; 
 I (("/"_vRCparams_"/")["/VALST/")  N V1,V2,V3,V4 S V1=vobj(this,-3),V2=vobj(this,-4),V3=vobj(this,-5),V4=vobj(this,-6) I '(''($D(^ERROR(V1,V2,V3,9,V4))#2)=''processMode) D
 .	N errmsg
 .	I (+processMode'=+0) S errmsg=$$^MSG(7932)
 .	E  S errmsg=$$^MSG(2327)
 .	D throwError(errmsg)
 .	Q 
 Q 
 ;
vRCupdateDB(this,processMode,vRCparams,vRCaudit,vRCauditIns) ; 
 I '(("/"_vRCparams_"/")["/NOUPDATE/") D
 .	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	if $D(vobj(this)) S ^ERROR(vobj(this,-3),vobj(this,-4),vobj(this,-5),9,vobj(this,-6))=vobj(this)
 .	;*** End of code by-passed by compiler ***
 .	Q 
 Q 
 ;
vRCdelete(this,vRCparams,vRCaudit,isKeyChange) ; 
 ;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
 ;*** Start of code by-passed by compiler
 ZWI ^ERROR(vobj(this,-3),vobj(this,-4),vobj(this,-5),9,vobj(this,-6))
 ;*** End of code by-passed by compiler ***
 Q 
 ;
vRCchkReqForInsert(this) ; 
 I (vobj(this,-3)="") D vRCrequiredErr("DATE")
 I (vobj(this,-4)="") D vRCrequiredErr("ET")
 I (vobj(this,-5)="") D vRCrequiredErr("SEQ")
 I (vobj(this,-6)="") D vRCrequiredErr("VAR")
 Q 
 ;
vRCchkReqForUpdate(this) ; 
 I (vobj(this,-3)="") D vRCrequiredErr("DATE")
 I (vobj(this,-4)="") D vRCrequiredErr("ET")
 I (vobj(this,-5)="") D vRCrequiredErr("SEQ")
 I (vobj(this,-6)="") D vRCrequiredErr("VAR")
 Q 
 ;
vRCrequiredErr(column) ; 
 N ER S ER=0
 N RM S RM=""
 D SETERR^DBSEXECU("ERROR9","MSG",1767,"ERROR9."_column)
 I ER D throwError($get(RM))
 Q 
 ;
vRCvalidateDD(this,processMode) ; 
 N ER S ER=0
 N RM S RM=""
 N errmsg N X
 S X=vobj(this,-3) I '(X=""),(X'?1.5N) D vRCvalidateDDerr("DATE",$$^MSG(742,"D"))
 I ($L(vobj(this,-4))>60) D vRCvalidateDDerr("ET",$$^MSG(1076,60))
 I '(vobj(this,-5)=""),'(+vobj(this,-5)=vobj(this,-5))  S vobj(this,-5)=$$vRCtrimNumber(vobj(this,-5))
 S X=vobj(this,-5) I '(X=""),(X'?1.20N),(X'?1"-"1.19N) D vRCvalidateDDerr("SEQ",$$^MSG(742,"N"))
 I ($L(vobj(this,-6))>50) D vRCvalidateDDerr("VAR",$$^MSG(1076,50))
 I ($L($P(vobj(this),$C(12),1))>400) D vRCvalidateDDerr("VALUE",$$^MSG(1076,400))
 Q 
 ;
vRCvalidateDD1(this) ; 
 N ER S ER=0
 N RM S RM=""
 N errmsg N X
 I ($D(vobj(this,-100,"1*","DATE"))&($P($E($G(vobj(this,-100,"1*","DATE")),5,9999),$C(12))'=vobj(this,-3))) S X=vobj(this,-3) I '(X=""),(X'?1.5N) D vRCvalidateDDerr("DATE",$$^MSG(742,"D"))
 I ($D(vobj(this,-100,"2*","ET"))&($P($E($G(vobj(this,-100,"2*","ET")),5,9999),$C(12))'=vobj(this,-4))) I ($L(vobj(this,-4))>60) D vRCvalidateDDerr("ET",$$^MSG(1076,60))
 I ($D(vobj(this,-100,"3*","SEQ"))&($P($E($G(vobj(this,-100,"3*","SEQ")),5,9999),$C(12))'=vobj(this,-5))),'(vobj(this,-5)=""),'(+vobj(this,-5)=vobj(this,-5))  S vobj(this,-5)=$$vRCtrimNumber(vobj(this,-5))
 I ($D(vobj(this,-100,"3*","SEQ"))&($P($E($G(vobj(this,-100,"3*","SEQ")),5,9999),$C(12))'=vobj(this,-5))) S X=vobj(this,-5) I '(X=""),(X'?1.20N),(X'?1"-"1.19N) D vRCvalidateDDerr("SEQ",$$^MSG(742,"N"))
 I ($D(vobj(this,-100,"4*","VAR"))&($P($E($G(vobj(this,-100,"4*","VAR")),5,9999),$C(12))'=vobj(this,-6))) I ($L(vobj(this,-6))>50) D vRCvalidateDDerr("VAR",$$^MSG(1076,50))
 I ($D(vobj(this,-100,"0*","VALUE"))&($P($E($G(vobj(this,-100,"0*","VALUE")),5,9999),$C(12))'=$P(vobj(this),$C(12),1))) I ($L($P(vobj(this),$C(12),1))>400) D vRCvalidateDDerr("VALUE",$$^MSG(1076,400))
 Q 
 ;
vRCvalidateDDerr(column,errmsg) ; 
 N ER S ER=0
 N RM S RM=""
 D SETERR^DBSEXECU("ERROR9","MSG",979,"ERROR9."_column_" "_errmsg)
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
 N oldKey1 S oldKey1=$S($D(vobj(this,-100,"1*","DATE")):$P($E(vobj(this,-100,"1*","DATE"),5,9999),$C(12)),1:vobj(this,-3))
 N newKey2 S newKey2=vobj(this,-4)
 N oldKey2 S oldKey2=$S($D(vobj(this,-100,"2*","ET")):$P($E(vobj(this,-100,"2*","ET"),5,9999),$C(12)),1:vobj(this,-4))
 N newKey3 S newKey3=vobj(this,-5)
 N oldKey3 S oldKey3=$S($D(vobj(this,-100,"3*","SEQ")):$P($E(vobj(this,-100,"3*","SEQ"),5,9999),$C(12)),1:vobj(this,-5))
 N newKey4 S newKey4=vobj(this,-6)
 N oldKey4 S oldKey4=$S($D(vobj(this,-100,"4*","VAR")):$P($E(vobj(this,-100,"4*","VAR"),5,9999),$C(12)),1:vobj(this,-6))
  N V1,V2,V3,V4 S V1=vobj(this,-3),V2=vobj(this,-4),V3=vobj(this,-5),V4=vobj(this,-6) I ($D(^ERROR(V1,V2,V3,9,V4))#2) D throwError($$^MSG(2327))
 S newkeys=newKey1_","_newKey2_","_newKey3_","_newKey4
 S oldkeys=oldKey1_","_oldKey2_","_oldKey3_","_oldKey4
  S vobj(this,-3)=oldKey1
  S vobj(this,-4)=oldKey2
  S vobj(this,-5)=oldKey3
  S vobj(this,-6)=oldKey4
 S vRCparams=$$setPar^UCUTILN(vRCparams,"NOINDEX")
 I (("/"_vRCparams_"/")["/VALREQ/") D vRCchkReqForInsert(this)
 I (("/"_vRCparams_"/")["/VALDD/") D vRCvalidateDD(this,1)
 D vRCmiscValidations(this,vRCparams,1)
 D vRCupdateDB(this,1,vRCparams,.vRCaudit,.vRCauditIns)
  S vobj(this,-3)=newKey1
  S vobj(this,-4)=newKey2
  S vobj(this,-5)=newKey3
  S vobj(this,-6)=newKey4
 N newrec S newrec=$$vReCp1(this)
 S vobj(newrec,-2)=0
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordERROR9(newrec,$$initPar^UCUTILN($$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/"))) K vobj(newrec,-100) S vobj(newrec,-2)=1 TC:vTp  
 D
 .	N %O S %O=1
 .	N ER S ER=0
 .	N RM S RM=""
 .	;   #ACCEPT Date=10/24/2008; Pgm=RussellDS; CR=30801; Group=ACCESS
 .	D CASUPD^DBSEXECU("ERROR9",oldkeys,newkeys)
 .	I ER D throwError($get(RM))
 .	Q 
  S vobj(this,-3)=oldKey1
  S vobj(this,-4)=oldKey2
  S vobj(this,-5)=oldKey3
  S vobj(this,-6)=oldKey4
 S vRCparams=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
 D vRCdelete(this,vRCparams,.vRCaudit,1)
  S vobj(this,-3)=newKey1
  S vobj(this,-4)=newKey2
  S vobj(this,-5)=newKey3
  S vobj(this,-6)=newKey4
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
vReCp1(v1) ; RecordERROR9.copy: ERROR9
 ;
 Q $$copy^UCGMR(this)
