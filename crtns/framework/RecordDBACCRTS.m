 ; 
 ; **** Routine compiled from DATA-QWIK Filer RecordDBACCRTS ****
 ; 
 ; 02/24/2010 18:39 - pip
 ; 
 ;
 ; Record Class code for table DBACCRTS
 ;
 ; Generated by PSLRecordBuilder on 02/24/2010 at 18:39 by
 ;
vcdmNew() ; 
 N vOid
 ;  #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=BYPASS
 ;*** Start of code by-passed by compiler
 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBACCRTS",vobj(vOid,-2)=0,vobj(vOid)=""
 S vobj(vOid,-3)=""
 S vobj(vOid,-4)=""
 ;*** End of code by-passed by compiler ***
 ;  #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=SCOPE
 Q vOid
 ;
vRCgetRecord0(v1,v2,vfromDbSet) ; 
 N vOid
 ;  #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=BYPASS
 ;*** Start of code by-passed by compiler
 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBACCRTS"
 S vobj(vOid)=$G(^DBACCRTS(v1,v2))
 I vobj(vOid)="",'$D(^DBACCRTS(v1,v2))
 S vobj(vOid,-2)=1
 I $T K vobj(vOid) S $ZE="0,"_$ZPOS_",%PSL-E-RECNOFL,,DBACCRTS",$EC=",U1001,"
 S vobj(vOid,-3)=v1
 S vobj(vOid,-4)=v2
 ;*** End of code by-passed by compiler ***
 ;  #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=SCOPE
 Q vOid
 ;
vRCgetRecord1(v1,v2,vfromDbSet) ; 
 N vOid
 ;  #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=BYPASS
 ;*** Start of code by-passed by compiler
 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBACCRTS"
 S vobj(vOid)=$G(^DBACCRTS(v1,v2))
 I vobj(vOid)="",'$D(^DBACCRTS(v1,v2))
 S vobj(vOid,-2)='$T
 S vobj(vOid,-3)=v1
 S vobj(vOid,-4)=v2
 ;*** End of code by-passed by compiler ***
 ;  #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=SCOPE
 Q vOid
 ;
vRCgetRecord0Opt(v1,v2,vfromDbSet,v2out) ; 
 N dbaccrts
 ;  #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=BYPASS
 ;*** Start of code by-passed by compiler
 S dbaccrts=$G(^DBACCRTS(v1,v2))
 I dbaccrts="",'$D(^DBACCRTS(v1,v2))
 S v2out=1
 I $T S $ZE="0,"_$ZPOS_",%PSL-E-RECNOFL,,DBACCRTS",$EC=",U1001,"
 ;*** End of code by-passed by compiler ***
 Q dbaccrts
 ;
vRCgetRecord1Opt(v1,v2,vfromDbSet,v2out) ; 
 N dbaccrts
 ;  #ACCEPT DATE=02/26/2008; PGM=Dan Russell; CR=30801; Group=BYPASS
 ;*** Start of code by-passed by compiler
 S dbaccrts=$G(^DBACCRTS(v1,v2))
 I dbaccrts="",'$D(^DBACCRTS(v1,v2))
 S v2out='$T
 ;*** End of code by-passed by compiler ***
 Q dbaccrts
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
 .	D AUDIT^UCUTILN(this,.vRCauditIns,11,"|")
 .	D vRCsetDefaults(this)
 .	I (("/"_vRCparams_"/")["/TRIGBEF/") D vRCbeforeInsTrigs(this,vRCparams)
 .	I (("/"_vRCparams_"/")["/VALREQ/") D vRCchkReqForInsert(this)
 .	I (("/"_vRCparams_"/")["/VALDD/") D vRCvalidateDD(this,%O)
 .	D vRCmiscValidations(this,vRCparams,%O)
 .	D vRCupdateDB(this,%O,vRCparams,.vRCaudit,.vRCauditIns)
 .	Q 
 E  I (%O=1) D
 .	Q:'$D(vobj(this,-100)) 
 .	D AUDIT^UCUTILN(this,.vRCaudit,11,"|")
 .	I ($D(vobj(this,-100,"1*","TABLENAME"))&($P($E($G(vobj(this,-100,"1*","TABLENAME")),5,9999),$C(124))'=vobj(this,-3)))!($D(vobj(this,-100,"2*","USERCLASS"))&($P($E($G(vobj(this,-100,"2*","USERCLASS")),5,9999),$C(124))'=vobj(this,-4))) D vRCkeyChanged(this,vRCparams,.vRCaudit) Q 
 .	I (("/"_vRCparams_"/")["/TRIGBEF/") D vRCbeforeUpdTrigs(this,vRCparams,.vRCaudit)
 .	I (("/"_vRCparams_"/")["/VALREQ/") D vRCchkReqForUpdate(this)
 .	I (("/"_vRCparams_"/")["/VALDD/") D vRCvalidateDD1(this)
 .	D vRCmiscValidations(this,vRCparams,%O)
 .	D vRCupdateDB(this,%O,vRCparams,.vRCaudit,.vRCauditIns)
 .	I (("/"_vRCparams_"/")["/TRIGAFT/") D vRCafterUpdTrigs(this,vRCparams)
 .	Q 
 E  I (%O=2) D
 .	I (("/"_vRCparams_"/")["/VALREQ/") D vRCchkReqForInsert(this)
 .	I (("/"_vRCparams_"/")["/VALDD/") D vRCvalidateDD(this,%O)
 .	D vRCmiscValidations(this,vRCparams,2)
 .	Q 
 E  I (%O=3) D
 .	  N V1,V2 S V1=vobj(this,-3),V2=vobj(this,-4) Q:'($D(^DBACCRTS(V1,V2))) 
 .	I (("/"_vRCparams_"/")["/TRIGBEF/") D vRCbeforeDelTrigs(this,vRCparams)
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
vselectOptmOK(userclass,dbaccrts,vkey1,vkey2) ; PUBLIC access is allowed, no restrict clause
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
 Q $$vStrRep("DELETERTS,DELRESTRICT,INSERTRTS,INSRESTRICT,SELECTRTS,SELRESTRICT,TABLENAME,UPDATERTS,UPDRESTRICT,USERCLASS",",",$char(9),0,0,"")
 ;
columnListBM() ; 
 Q ""
 ;
columnListCMP() ; 
 Q $$vStrRep("",",",$char(9),0,0,"")
 ;
getColumnMap(map) ; 
 ;
 S map(-4)="USERCLASS:T:"
 S map(-3)="TABLENAME:T:"
 S map(-1)="DELETERTS:N:3;INSERTRTS:N:1;SELECTRTS:N:4;UPDATERTS:N:2"
 S map(1)="INSRESTRICT:T:1"
 S map(2)="UPDRESTRICT:T:1"
 S map(3)="DELRESTRICT:T:1"
 S map(4)="SELRESTRICT:T:1"
 Q 
 ;
vlegacy(processMode,params) ; 
 N vTp
 I (processMode=2) D
 .	N dbaccrts S dbaccrts=$$vRCgetRecord0^RecordDBACCRTS(TABLENAME,USERCLASS,0)
 .	S vobj(dbaccrts,-2)=2
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBACCRTS(dbaccrts,$$initPar^UCUTILN(params)) K vobj(dbaccrts,-100) S vobj(dbaccrts,-2)=1 TC:vTp  
 .	K vobj(+$G(dbaccrts)) Q 
 Q 
 ;
vhasLiterals() ; 
 Q 0
 ;
vRCmiscValidations(this,vRCparams,processMode) ; 
 I (("/"_vRCparams_"/")["/VALST/")  N V1,V2 S V1=vobj(this,-3),V2=vobj(this,-4) I '(''($D(^DBACCRTS(V1,V2)))=''processMode) D
 .	N errmsg
 .	I (+processMode'=+0) S errmsg=$$^MSG(7932)
 .	E  S errmsg=$$^MSG(2327)
 .	D throwError(errmsg)
 .	Q 
 Q 
 ;
vRCupdateDB(this,processMode,vRCparams,vRCaudit,vRCauditIns) ; 
 I '(("/"_vRCparams_"/")["/NOUPDATE/") D
 .	I '(("/"_vRCparams_"/")["/NOLOG/") D
 ..		I (processMode=1) D ^DBSLOGIT(this,1,.vRCaudit) Q 
 ..		D ^DBSLOGIT(this,0,.vRCauditIns)
 ..		Q 
 .	N n
 .	S n=-1
 .	F  S n=$order(vobj(this,n)) Q:(n="")  D
 ..		Q:'($D(vobj(this,n))#2) 
 ..		;    #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
 ..		;*** Start of code by-passed by compiler
 ..		S ^DBACCRTS(vobj(this,-3),vobj(this,-4),n)=vobj(this,n)
 ..		;*** End of code by-passed by compiler ***
 ..		Q 
 .	;   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	if $D(vobj(this)) S ^DBACCRTS(vobj(this,-3),vobj(this,-4))=vobj(this)
 .	;*** End of code by-passed by compiler ***
 .	Q 
 Q 
 ;
vRCdelete(this,vRCparams,vRCaudit,isKeyChange) ; 
 I '$get(isKeyChange),$D(vobj(this,-100)) D throwError("Deleted object cannot be modified")
 I '(("/"_vRCparams_"/")["/NOLOG/") D ^DBSLOGIT(this,3)
 ;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
 ;*** Start of code by-passed by compiler
 kill ^DBACCRTS(vobj(this,-3),vobj(this,-4))
 ;*** End of code by-passed by compiler ***
 Q 
 ;
vRCsetDefaults(this) ; 
 I ($P(vobj(this),$C(124),3)="")  S vobj(this,-100,"0*")="" S $P(vobj(this),$C(124),3)=0
 I ($P(vobj(this),$C(124),1)="")  S vobj(this,-100,"0*")="" S $P(vobj(this),$C(124),1)=0
 I ($P(vobj(this),$C(124),4)="")  S vobj(this,-100,"0*")="" S $P(vobj(this),$C(124),4)=0
 I ($P(vobj(this),$C(124),2)="")  S vobj(this,-100,"0*")="" S $P(vobj(this),$C(124),2)=0
 Q 
 ;
vRCchkReqForInsert(this) ; 
 I ($P(vobj(this),$C(124),3)="") D vRCrequiredErr("DELETERTS")
 I ($P(vobj(this),$C(124),1)="") D vRCrequiredErr("INSERTRTS")
 I ($P(vobj(this),$C(124),4)="") D vRCrequiredErr("SELECTRTS")
 I (vobj(this,-3)="") D vRCrequiredErr("TABLENAME")
 I ($P(vobj(this),$C(124),2)="") D vRCrequiredErr("UPDATERTS")
 I (vobj(this,-4)="") D vRCrequiredErr("USERCLASS")
 Q 
 ;
vRCchkReqForUpdate(this) ; 
 I (vobj(this,-3)="") D vRCrequiredErr("TABLENAME")
 I (vobj(this,-4)="") D vRCrequiredErr("USERCLASS")
 I ($D(vobj(this,-100,"0*"))>9) D
 .	I ($D(vobj(this,-100,"0*","INSERTRTS"))&($P($E($G(vobj(this,-100,"0*","INSERTRTS")),5,9999),$C(124))'=$P(vobj(this),$C(124),1))),($P(vobj(this),$C(124),1)="") D vRCrequiredErr("INSERTRTS")
 .	I ($D(vobj(this,-100,"0*","UPDATERTS"))&($P($E($G(vobj(this,-100,"0*","UPDATERTS")),5,9999),$C(124))'=$P(vobj(this),$C(124),2))),($P(vobj(this),$C(124),2)="") D vRCrequiredErr("UPDATERTS")
 .	I ($D(vobj(this,-100,"0*","DELETERTS"))&($P($E($G(vobj(this,-100,"0*","DELETERTS")),5,9999),$C(124))'=$P(vobj(this),$C(124),3))),($P(vobj(this),$C(124),3)="") D vRCrequiredErr("DELETERTS")
 .	I ($D(vobj(this,-100,"0*","SELECTRTS"))&($P($E($G(vobj(this,-100,"0*","SELECTRTS")),5,9999),$C(124))'=$P(vobj(this),$C(124),4))),($P(vobj(this),$C(124),4)="") D vRCrequiredErr("SELECTRTS")
 .	Q 
 ; Node "1*" - only one required column
 I ($D(vobj(this,-100,"1*","TABLENAME"))&($P($E($G(vobj(this,-100,"1*","TABLENAME")),5,9999),$C(124))'=vobj(this,-3))),(vobj(this,-3)="") D vRCrequiredErr("TABLENAME")
 ; Node "2*" - only one required column
 I ($D(vobj(this,-100,"2*","USERCLASS"))&($P($E($G(vobj(this,-100,"2*","USERCLASS")),5,9999),$C(124))'=vobj(this,-4))),(vobj(this,-4)="") D vRCrequiredErr("USERCLASS")
 Q 
 ;
vRCrequiredErr(column) ; 
 N ER S ER=0
 N RM S RM=""
 D SETERR^DBSEXECU("DBACCRTS","MSG",1767,"DBACCRTS."_column)
 I ER D throwError($get(RM))
 Q 
 ;
vRCTrig1(this,dbaccrts,vpar) ; Trigger AU_RIGHTS - Before Update Where Columns - AU
 ;
 I (($P(vobj(this),$C(124),1)=0)&($P(vobj(this),$C(124),2)=0)&($P(vobj(this),$C(124),3)=0)&($P(vobj(this),$C(124),4)=0)) D
 .	;
 .	N rs,vos1,vos2,vos3,vos4,vos5  N V1,V2 S V1=vobj(this,-3),V2=vobj(this,-4) S rs=$$vOpen1()
 .	;
 . I $$vFetch1(),(rs=1)  N V3,V4 S V3=vobj(this,-3),V4=vobj(this,-4) D vDbDe1()
 . Q 
 ;
 Q 
 ;
vRCTrig2(this,dbaccrts,vpar) ; Trigger BEFORE_DELETE - Before Delete - BD
 ;
 N hasPriv
 N errmsg
 ;
 S hasPriv=$$HASRIGHTS(this,"delete","DBACCRTS",.errmsg)
 I 'hasPriv S hasPriv=$$HASRIGHTS(this,"update",vobj(this,-3),.errmsg)
 ;
 I 'hasPriv D throwError(errmsg)
 ;
 Q:(vobj(this,-3)'="DBACCRTS") 
 ;
 N rs1,vos1,vos2,vos3,vos4,vos5  N V1 S V1=vobj(this,-4) S rs1=$$vOpen2()
 ;
 I '$G(vos1) D
 .	;
 .	; If this is the last row, then it's OK to delete
 .	N rscnt,vos6,vos7,vos8,vos9,vos10 S rscnt=$$vOpen3()
 .	;
 .	; Revoke all other access rights and regenerate all Record Class code before deleting final GRANT entry
 . I $$vFetch3(),(rscnt>1) D throwError($$^MSG(6760))
 . Q 
 ;
 N rs2,vos11,vos12,vos13 S rs2=$$vOpen4()
 ;
 F  Q:'$$vFetch4()  D
 .	;
 .	N ckrts S ckrts=""
 . N table S table=rs2
 .	;
 .	D
 ..		N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ..		;
 ..		;    #ACCEPT Date=06/30/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 ..		;*** Start of code by-passed by compiler
 ..		X "S ckrts=$$vcheckAccessRights^Record"_table
 ..		;*** End of code by-passed by compiler ***
 ..		Q 
 .	;
 .	; Regenerate all Record Class code before deleting final GRANT entry
 .	I '(ckrts="") D throwError($$^MSG(6761))
 .	Q 
 ;
 Q 
 ;
vRCTrig3(this,dbaccrts,vpar) ; Trigger BEFORE_INSERT - Before Insert - BI
  S:'$D(vobj(this,1)) vobj(this,1)=$S(vobj(this,-2):$G(^DBACCRTS(vobj(this,-3),vobj(this,-4),1)),1:"")
 ;
 N errmsg
 ;
 ; Invalid userclass ~p1
  N V1 S V1=vobj(this,-4) I '(($D(^SCAU(0,V1))#2)!(vobj(this,-4)="PUBLIC")) D throwError($$^MSG(6755,vobj(this,-4)))
 ;
 ; Not valid for RDB Table
 I $$rdb^UCDBRT(vobj(this,-3)) D throwError($$^MSG(6762))
 ;
 N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen5()
 ;
 I '$G(vos1) D
 .	;
 .	; Initial entry to access rights table (DBACCRTS) must be ALL PRIVILEGES
 .	; with GRANT OPTION for either PUBLIC or your userclass, ~p1
 .	I (vobj(this,-3)'="DBACCRTS") D throwError($$^MSG(6758,%UCLS))
 .	E  I (+$P(vobj(this),$C(124),1)'=+2) D throwError($$^MSG(6758,%UCLS))
 .	E  I (+$P(vobj(this),$C(124),2)'=+2) D throwError($$^MSG(6758,%UCLS))
 .	E  I (+$P(vobj(this),$C(124),3)'=+2) D throwError($$^MSG(6758,%UCLS))
 .	E  I (+$P(vobj(this),$C(124),4)'=+2) D throwError($$^MSG(6758,%UCLS))
 .	E  I '((vobj(this,-4)="PUBLIC")!(vobj(this,-4)=%UCLS)) D throwError($$^MSG(6758,%UCLS))
 .	Q 
 ;
 E  D
 .	;
 .	N checkList S checkList=""
 .	;
 .	I $P(vobj(this),$C(124),1) S checkList="insert"
 .	I $P(vobj(this),$C(124),2) S checkList=$S((checkList=""):"update",1:checkList_","_"update")
 .	I $P(vobj(this),$C(124),3) S checkList=$S((checkList=""):"delete",1:checkList_","_"delete")
 .	I $P(vobj(this),$C(124),4) S checkList=$S((checkList=""):"select",1:checkList_","_"select")
 .	;
 .	I '$$HASRIGHTS(this,checkList,vobj(this,-3),.errmsg) D throwError(errmsg)
 .	 S:'$D(vobj(this,1)) vobj(this,1)=$G(^DBACCRTS(vobj(this,-3),vobj(this,-4),1))
 .	Q 
 ;
 I '($P(vobj(this,1),$C(124),1)=""),'$$VALIDRESTRICT(this,$P(vobj(this,1),$C(124),1),.errmsg) D throwError(errmsg)
  S:'$D(vobj(this,2)) vobj(this,2)=$S(vobj(this,-2):$G(^DBACCRTS(vobj(this,-3),vobj(this,-4),2)),1:"")
 I '($P(vobj(this,2),$C(124),1)=""),'$$VALIDRESTRICT(this,$P(vobj(this,2),$C(124),1),.errmsg) D throwError(errmsg)
  S:'$D(vobj(this,3)) vobj(this,3)=$S(vobj(this,-2):$G(^DBACCRTS(vobj(this,-3),vobj(this,-4),3)),1:"")
 I '($P(vobj(this,3),$C(124),1)=""),'$$VALIDRESTRICT(this,$P(vobj(this,3),$C(124),1),.errmsg) D throwError(errmsg)
  S:'$D(vobj(this,4)) vobj(this,4)=$S(vobj(this,-2):$G(^DBACCRTS(vobj(this,-3),vobj(this,-4),4)),1:"")
 I '($P(vobj(this,4),$C(124),1)=""),'$$VALIDRESTRICT(this,$P(vobj(this,4),$C(124),1),.errmsg) D throwError(errmsg)
 ;
 Q 
 ;
HASRIGHTS(this,checkList,tablename,errmsg) ; Error message  /MECH=REFNAM
 ;
 N hasRights S hasRights=1
 ;
 N dbaccrts S dbaccrts=$G(^DBACCRTS("DBACCRTS",%UCLS))
 N tblrts S tblrts=$G(^DBACCRTS(tablename,%UCLS))
 ;
 I ((","_checkList_",")[",insert,"),'(($P(vobj(this),$C(124),1)=2)!($P(tblrts,$C(124),1)=2)) S hasRights=0
 I ((","_checkList_",")[",update,"),'(($P(vobj(this),$C(124),2)=2)!($P(tblrts,$C(124),2)=2)) S hasRights=0
 I ((","_checkList_",")[",delete,"),'(($P(vobj(this),$C(124),3)=2)!($P(tblrts,$C(124),3)=2)) S hasRights=0
 I ((","_checkList_",")[",select,"),'(($P(vobj(this),$C(124),4)=2)!($P(tblrts,$C(124),4)=2)) S hasRights=0
 ;
 ; Userclass ~p1 does not have WITH GRANT OPTION for table ~p2
 I 'hasRights S errmsg=$$^MSG(6765,%UCLS,vobj(this,-3))
 ;
 Q hasRights
 ;
VALIDRESTRICT(this,restrict,errmsg) ; Error message
 ;
 N isError S isError=0
 N fsn N join N rng N vdd N whr
 ;
 S errmsg=""
 ;
 I (vobj(this,-3)="DBACCRTS") D
 .	;
 .	S isError=1
 .	; GRANT with a RESTRICT qualifier is not allowed for the access rights table (DBACCRTS)
 .	S errmsg=$$^MSG(6759)
 .	Q 
 ;
 E  D
 .	;
 .	N ER S ER=0 ; Returned by ^SQLJ/^SQLQ
 .	N RM S RM="" ; Returned by ^SQLJ/^SQLQ
 .	N from S from=vobj(this,-3)
 .	;
 .	I ($E(restrict,1,6)="[FROM ") D  Q:isError 
 ..		;
 ..		S from=$piece($piece(restrict,"[FROM ",2),"]",1)
 ..		S restrict=$$vStrTrim($piece(restrict,"]",2,$L(restrict)),0," ")
 ..		;
 ..		S from=$$^SQLJ(from,.whr,.fsn,.join,"")
 ..		;
 ..		; Invalid FROM statement ~p1
 ..		I (ER!'((","_from_",")[(","_vobj(this,-3)_","))) D
 ...			;
 ...			S isError=1
 ...			S errmsg=$$^MSG(1356,from)
 ...			Q 
 ..		Q 
 .	;
 .	D ^SQLQ(restrict,from,.whr,.rng,"","",.fsn,.vdd,"")
 .	;
 .	; Invalid WHERE statement ~p1
 .	I ER D
 ..		;
 ..		S isError=1
 ..		S errmsg=$$^MSG(1507,$get(RM))
 ..		Q 
 .	Q 
 ;
 Q isError
 ;
vRCTrig4(this,dbaccrts,vpar) ; Trigger BU_KEYS - Before Update Keys Columns - BU
 ;
 N keyname
 ;
 I ($D(vobj(this,-100,"1*","TABLENAME"))&($P($E($G(vobj(this,-100,"1*","TABLENAME")),5,9999),$C(124))'=vobj(this,-3))) S keyname="TABLENAME"
 E  I ($D(vobj(this,-100,"2*","USERCLASS"))&($P($E($G(vobj(this,-100,"2*","USERCLASS")),5,9999),$C(124))'=vobj(this,-4))) S keyname="USERCLASS"
 ;
 ; Cannot update access key ~p1
 D throwError($$^MSG(8556,keyname))
 ;
 Q 
 ;
vRCTrig5(this,dbaccrts,vpar) ; Trigger BU_RESTRICT - Before Update Restrict Columns - BU
  S:'$D(vobj(this,1)) vobj(this,1)=$S(vobj(this,-2):$G(^DBACCRTS(vobj(this,-3),vobj(this,-4),1)),1:"")
 ;
 N checkList S checkList=""
 N errmsg
 ;
 I ($D(vobj(this,-100,1,"INSRESTRICT"))&($P($E($G(vobj(this,-100,1,"INSRESTRICT")),5,9999),$C(124))'=$P(vobj(this,1),$C(124),1))) S checkList="insert"
 I ($D(vobj(this,-100,2,"UPDRESTRICT"))&($P($E($G(vobj(this,-100,2,"UPDRESTRICT")),5,9999),$C(124))'=$P(vobj(this,2),$C(124),1))) S checkList=$S((checkList=""):"update",1:checkList_","_"update")
 I ($D(vobj(this,-100,3,"DELRESTRICT"))&($P($E($G(vobj(this,-100,3,"DELRESTRICT")),5,9999),$C(124))'=$P(vobj(this,3),$C(124),1))) S checkList=$S((checkList=""):"delete",1:checkList_","_"delete")
 I ($D(vobj(this,-100,4,"SELRESTRICT"))&($P($E($G(vobj(this,-100,4,"SELRESTRICT")),5,9999),$C(124))'=$P(vobj(this,4),$C(124),1))) S checkList=$S((checkList=""):"select",1:checkList_","_"select")
 ;
 I '$$HASRIGHTS(this,checkList,vobj(this,-3),.errmsg) D throwError(errmsg)
  S:'$D(vobj(this,1)) vobj(this,1)=$G(^DBACCRTS(vobj(this,-3),vobj(this,-4),1))
 ;
 I '($P(vobj(this,1),$C(124),1)=""),'$$VALIDRESTRICT(this,$P(vobj(this,1),$C(124),1),.errmsg) D throwError(errmsg)
  S:'$D(vobj(this,2)) vobj(this,2)=$S(vobj(this,-2):$G(^DBACCRTS(vobj(this,-3),vobj(this,-4),2)),1:"")
 I '($P(vobj(this,2),$C(124),1)=""),'$$VALIDRESTRICT(this,$P(vobj(this,2),$C(124),1),.errmsg) D throwError(errmsg)
  S:'$D(vobj(this,3)) vobj(this,3)=$S(vobj(this,-2):$G(^DBACCRTS(vobj(this,-3),vobj(this,-4),3)),1:"")
 I '($P(vobj(this,3),$C(124),1)=""),'$$VALIDRESTRICT(this,$P(vobj(this,3),$C(124),1),.errmsg) D throwError(errmsg)
  S:'$D(vobj(this,4)) vobj(this,4)=$S(vobj(this,-2):$G(^DBACCRTS(vobj(this,-3),vobj(this,-4),4)),1:"")
 I '($P(vobj(this,4),$C(124),1)=""),'$$VALIDRESTRICT(this,$P(vobj(this,4),$C(124),1),.errmsg) D throwError(errmsg)
 ;
 Q 
 ;
vRCTrig6(this,dbaccrts,vpar) ; Trigger BU_RTS - Before Update Rights Columns - BU
  S:'$D(vobj(this,1)) vobj(this,1)=$S(vobj(this,-2):$G(^DBACCRTS(vobj(this,-3),vobj(this,-4),1)),1:"")
  S:'$D(vobj(this,2)) vobj(this,2)=$S(vobj(this,-2):$G(^DBACCRTS(vobj(this,-3),vobj(this,-4),2)),1:"")
  S:'$D(vobj(this,3)) vobj(this,3)=$S(vobj(this,-2):$G(^DBACCRTS(vobj(this,-3),vobj(this,-4),3)),1:"")
  S:'$D(vobj(this,4)) vobj(this,4)=$S(vobj(this,-2):$G(^DBACCRTS(vobj(this,-3),vobj(this,-4),4)),1:"")
 ;
 N checkList S checkList=""
 N errmsg
 ;
 I ($D(vobj(this,-100,"0*","INSERTRTS"))&($P($E($G(vobj(this,-100,"0*","INSERTRTS")),5,9999),$C(124))'=$P(vobj(this),$C(124),1))) D
 .	;
 .	S checkList="insert"
 .	I ($P(vobj(this),$C(124),1)=0)  S:'$D(vobj(this,-100,1,"INSRESTRICT")) vobj(this,-100,1,"INSRESTRICT")="T001"_$P(vobj(this,1),$C(124),1),vobj(this,-100,1)="" S $P(vobj(this,1),$C(124),1)=""
 .	Q 
 I ($D(vobj(this,-100,"0*","UPDATERTS"))&($P($E($G(vobj(this,-100,"0*","UPDATERTS")),5,9999),$C(124))'=$P(vobj(this),$C(124),2))) D
 .	;
 .	S checkList=$S((checkList=""):"update",1:checkList_","_"update")
 .	I ($P(vobj(this),$C(124),2)=0)  S:'$D(vobj(this,-100,2,"UPDRESTRICT")) vobj(this,-100,2,"UPDRESTRICT")="T001"_$P(vobj(this,2),$C(124),1),vobj(this,-100,2)="" S $P(vobj(this,2),$C(124),1)=""
 .	Q 
 I ($D(vobj(this,-100,"0*","DELETERTS"))&($P($E($G(vobj(this,-100,"0*","DELETERTS")),5,9999),$C(124))'=$P(vobj(this),$C(124),3))) D
 .	;
 .	S checkList=$S((checkList=""):"delete",1:checkList_","_"delete")
 .	I ($P(vobj(this),$C(124),3)=0)  S:'$D(vobj(this,-100,3,"DELRESTRICT")) vobj(this,-100,3,"DELRESTRICT")="T001"_$P(vobj(this,3),$C(124),1),vobj(this,-100,3)="" S $P(vobj(this,3),$C(124),1)=""
 .	Q 
 I ($D(vobj(this,-100,"0*","SELECTRTS"))&($P($E($G(vobj(this,-100,"0*","SELECTRTS")),5,9999),$C(124))'=$P(vobj(this),$C(124),4))) D
 .	;
 .	S checkList=$S((checkList=""):"select",1:checkList_","_"select")
 .	I ($P(vobj(this),$C(124),4)=0)  S:'$D(vobj(this,-100,4,"SELRESTRICT")) vobj(this,-100,4,"SELRESTRICT")="T001"_$P(vobj(this,4),$C(124),1),vobj(this,-100,4)="" S $P(vobj(this,4),$C(124),1)=""
 .	Q 
 ;
 I '$$HASRIGHTS(this,checkList,vobj(this,-3),.errmsg) D throwError(errmsg)
 ;
 Q:(vobj(this,-3)'="DBACCRTS") 
 ;
 N rs,vos1,vos2,vos3,vos4,vos5  N V1 S V1=vobj(this,-4) S rs=$$vOpen6()
 ;
 I '$G(vos1) D
 .	;
 .	; At least one entry to access rights table (DBACCRTS) must be ALL PRIVILEGES with GRANT OPTION
 .	I '(($P(vobj(this),$C(124),1)=2)&($P(vobj(this),$C(124),2)=2)&($P(vobj(this),$C(124),3)=2)&($P(vobj(this),$C(124),4)=2)) D throwError($$^MSG(6764))
 .	Q 
 ;
 Q 
 ;
vRCbeforeInsTrigs(this,vRCparams) ; 
 N ER S ER=0
 N vRCfire
 N RM S RM=""
 N TABLENAME S TABLENAME=vobj(this,-3)
 N USERCLASS S USERCLASS=vobj(this,-4)
 D vRCTrig3(this,this,vRCparams) I ER D throwError($get(RM))
 Q 
 ;
vRCbeforeUpdTrigs(this,vRCparams,vRCaudit) ; 
 N ER S ER=0
 N vRCfire
 N RM S RM=""
 N TABLENAME S TABLENAME=vobj(this,-3)
 N USERCLASS S USERCLASS=vobj(this,-4)
 Q:'$D(vobj(this,-100)) 
 S vRCfire=0
 I ($D(vobj(this,-100,"0*","INSERTRTS"))&($P($E($G(vobj(this,-100,"0*","INSERTRTS")),5,9999),$C(124))'=$P(vobj(this),$C(124),1))) S vRCfire=1
 E  I ($D(vobj(this,-100,"0*","UPDATERTS"))&($P($E($G(vobj(this,-100,"0*","UPDATERTS")),5,9999),$C(124))'=$P(vobj(this),$C(124),2))) S vRCfire=1
 E  I ($D(vobj(this,-100,"0*","DELETERTS"))&($P($E($G(vobj(this,-100,"0*","DELETERTS")),5,9999),$C(124))'=$P(vobj(this),$C(124),3))) S vRCfire=1
 E  I ($D(vobj(this,-100,"0*","SELECTRTS"))&($P($E($G(vobj(this,-100,"0*","SELECTRTS")),5,9999),$C(124))'=$P(vobj(this),$C(124),4))) S vRCfire=1
 I vRCfire D vRCTrig6(this,this,vRCparams) I ER D throwError($get(RM))
 S vRCfire=0
 I ($D(vobj(this,-100,1,"INSRESTRICT"))&($P($E($G(vobj(this,-100,1,"INSRESTRICT")),5,9999),$C(124))'=$P(vobj(this,1),$C(124),1))) S vRCfire=1
 E  I ($D(vobj(this,-100,2,"UPDRESTRICT"))&($P($E($G(vobj(this,-100,2,"UPDRESTRICT")),5,9999),$C(124))'=$P(vobj(this,2),$C(124),1))) S vRCfire=1
 E  I ($D(vobj(this,-100,3,"DELRESTRICT"))&($P($E($G(vobj(this,-100,3,"DELRESTRICT")),5,9999),$C(124))'=$P(vobj(this,3),$C(124),1))) S vRCfire=1
 E  I ($D(vobj(this,-100,4,"SELRESTRICT"))&($P($E($G(vobj(this,-100,4,"SELRESTRICT")),5,9999),$C(124))'=$P(vobj(this,4),$C(124),1))) S vRCfire=1
 I vRCfire D vRCTrig5(this,this,vRCparams) I ER D throwError($get(RM))
 S vRCfire=0
 I ($D(vobj(this,-100,"1*","TABLENAME"))&($P($E($G(vobj(this,-100,"1*","TABLENAME")),5,9999),$C(124))'=vobj(this,-3))) S vRCfire=1
 E  I ($D(vobj(this,-100,"2*","USERCLASS"))&($P($E($G(vobj(this,-100,"2*","USERCLASS")),5,9999),$C(124))'=vobj(this,-4))) S vRCfire=1
 I vRCfire D vRCTrig4(this,this,vRCparams) I ER D throwError($get(RM))
 D AUDIT^UCUTILN(this,.vRCaudit,10,"|")
 Q 
 ;
vRCbeforeDelTrigs(this,vRCparams) ; 
 N ER S ER=0
 N vRCfire
 N RM S RM=""
 N TABLENAME S TABLENAME=vobj(this,-3)
 N USERCLASS S USERCLASS=vobj(this,-4)
 D vRCTrig2(this,this,vRCparams) I ER D throwError($get(RM))
 Q 
 ;
vRCafterUpdTrigs(this,vRCparams) ; 
 N ER S ER=0
 N vRCfire
 N RM S RM=""
 N TABLENAME S TABLENAME=vobj(this,-3)
 N USERCLASS S USERCLASS=vobj(this,-4)
 Q:'$D(vobj(this,-100)) 
 D vRCTrig1(this,this,vRCparams) I ER D throwError($get(RM))
 Q 
 ;
vRCforceLoad(this) ; 
 N n S n=""
 ;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
 ;*** Start of code by-passed by compiler
 for  set n=$order(^DBACCRTS(vobj(this,-3),vobj(this,-4),n)) quit:n=""  if '$D(vobj(this,n)),$D(^DBACCRTS(vobj(this,-3),vobj(this,-4),n))#2 set vobj(this,n)=^(n)
 ;*** End of code by-passed by compiler ***
 Q 
 ;
vRCvalidateDD(this,processMode) ; 
 N ER S ER=0
 N RM S RM=""
 N errmsg N X
 I (processMode=2) D vRCforceLoad(this)
 I ($D(vobj(this,1))#2) D
 .	 S:'$D(vobj(this,1)) vobj(this,1)=$S(vobj(this,-2):$G(^DBACCRTS(vobj(this,-3),vobj(this,-4),1)),1:"")
 .	I ($L($P(vobj(this,1),$C(124),1))>500) D vRCvalidateDDerr("INSRESTRICT",$$^MSG(1076,500))
 .	Q 
 I ($D(vobj(this,2))#2) D
 .	 S:'$D(vobj(this,2)) vobj(this,2)=$S(vobj(this,-2):$G(^DBACCRTS(vobj(this,-3),vobj(this,-4),2)),1:"")
 .	I ($L($P(vobj(this,2),$C(124),1))>500) D vRCvalidateDDerr("UPDRESTRICT",$$^MSG(1076,500))
 .	Q 
 I ($D(vobj(this,3))#2) D
 .	 S:'$D(vobj(this,3)) vobj(this,3)=$S(vobj(this,-2):$G(^DBACCRTS(vobj(this,-3),vobj(this,-4),3)),1:"")
 .	I ($L($P(vobj(this,3),$C(124),1))>500) D vRCvalidateDDerr("DELRESTRICT",$$^MSG(1076,500))
 .	Q 
 I ($D(vobj(this,4))#2) D
 .	 S:'$D(vobj(this,4)) vobj(this,4)=$S(vobj(this,-2):$G(^DBACCRTS(vobj(this,-3),vobj(this,-4),4)),1:"")
 .	I ($L($P(vobj(this,4),$C(124),1))>500) D vRCvalidateDDerr("SELRESTRICT",$$^MSG(1076,500))
 .	Q 
 I ($L(vobj(this,-3))>25) D vRCvalidateDDerr("TABLENAME",$$^MSG(1076,25))
 I ($L(vobj(this,-4))>12) D vRCvalidateDDerr("USERCLASS",$$^MSG(1076,12))
 I ($D(vobj(this))#2)!'($order(vobj(this,""))="") D
 .	S X=$P(vobj(this),$C(124),3) I '(X=""),'$$vCaEx1() D vRCvalidateDDerr("DELETERTS",$$^MSG(1485,X))
 .	S X=$P(vobj(this),$C(124),1) I '(X=""),'$$vCaEx2() D vRCvalidateDDerr("INSERTRTS",$$^MSG(1485,X))
 .	S X=$P(vobj(this),$C(124),4) I '(X=""),'$$vCaEx3() D vRCvalidateDDerr("SELECTRTS",$$^MSG(1485,X))
 .	S X=$P(vobj(this),$C(124),2) I '(X=""),'$$vCaEx4() D vRCvalidateDDerr("UPDATERTS",$$^MSG(1485,X))
 .	Q 
 Q 
 ;
vRCvalidateDD1(this) ; 
  S:'$D(vobj(this,1)) vobj(this,1)=$S(vobj(this,-2):$G(^DBACCRTS(vobj(this,-3),vobj(this,-4),1)),1:"")
  S:'$D(vobj(this,2)) vobj(this,2)=$S(vobj(this,-2):$G(^DBACCRTS(vobj(this,-3),vobj(this,-4),2)),1:"")
  S:'$D(vobj(this,3)) vobj(this,3)=$S(vobj(this,-2):$G(^DBACCRTS(vobj(this,-3),vobj(this,-4),3)),1:"")
  S:'$D(vobj(this,4)) vobj(this,4)=$S(vobj(this,-2):$G(^DBACCRTS(vobj(this,-3),vobj(this,-4),4)),1:"")
 N ER S ER=0
 N RM S RM=""
 N errmsg N X
 I ($D(vobj(this,1))#2) D
 .	I ($D(vobj(this,-100,1,"INSRESTRICT"))&($P($E($G(vobj(this,-100,1,"INSRESTRICT")),5,9999),$C(124))'=$P(vobj(this,1),$C(124),1))) I ($L($P(vobj(this,1),$C(124),1))>500) D vRCvalidateDDerr("INSRESTRICT",$$^MSG(1076,500))
 .	Q 
 I ($D(vobj(this,2))#2) D
 .	I ($D(vobj(this,-100,2,"UPDRESTRICT"))&($P($E($G(vobj(this,-100,2,"UPDRESTRICT")),5,9999),$C(124))'=$P(vobj(this,2),$C(124),1))) I ($L($P(vobj(this,2),$C(124),1))>500) D vRCvalidateDDerr("UPDRESTRICT",$$^MSG(1076,500))
 .	Q 
 I ($D(vobj(this,3))#2) D
 .	I ($D(vobj(this,-100,3,"DELRESTRICT"))&($P($E($G(vobj(this,-100,3,"DELRESTRICT")),5,9999),$C(124))'=$P(vobj(this,3),$C(124),1))) I ($L($P(vobj(this,3),$C(124),1))>500) D vRCvalidateDDerr("DELRESTRICT",$$^MSG(1076,500))
 .	Q 
 I ($D(vobj(this,4))#2) D
 .	I ($D(vobj(this,-100,4,"SELRESTRICT"))&($P($E($G(vobj(this,-100,4,"SELRESTRICT")),5,9999),$C(124))'=$P(vobj(this,4),$C(124),1))) I ($L($P(vobj(this,4),$C(124),1))>500) D vRCvalidateDDerr("SELRESTRICT",$$^MSG(1076,500))
 .	Q 
 I ($D(vobj(this,-100,"1*","TABLENAME"))&($P($E($G(vobj(this,-100,"1*","TABLENAME")),5,9999),$C(124))'=vobj(this,-3))) I ($L(vobj(this,-3))>25) D vRCvalidateDDerr("TABLENAME",$$^MSG(1076,25))
 I ($D(vobj(this,-100,"2*","USERCLASS"))&($P($E($G(vobj(this,-100,"2*","USERCLASS")),5,9999),$C(124))'=vobj(this,-4))) I ($L(vobj(this,-4))>12) D vRCvalidateDDerr("USERCLASS",$$^MSG(1076,12))
 I ($D(vobj(this))#2)!'($order(vobj(this,""))="") D
 .	I ($D(vobj(this,-100,"0*","DELETERTS"))&($P($E($G(vobj(this,-100,"0*","DELETERTS")),5,9999),$C(124))'=$P(vobj(this),$C(124),3))) S X=$P(vobj(this),$C(124),3) I '(X=""),'$$vCaEx5() D vRCvalidateDDerr("DELETERTS",$$^MSG(1485,X))
 .	I ($D(vobj(this,-100,"0*","INSERTRTS"))&($P($E($G(vobj(this,-100,"0*","INSERTRTS")),5,9999),$C(124))'=$P(vobj(this),$C(124),1))) S X=$P(vobj(this),$C(124),1) I '(X=""),'$$vCaEx6() D vRCvalidateDDerr("INSERTRTS",$$^MSG(1485,X))
 .	I ($D(vobj(this,-100,"0*","SELECTRTS"))&($P($E($G(vobj(this,-100,"0*","SELECTRTS")),5,9999),$C(124))'=$P(vobj(this),$C(124),4))) S X=$P(vobj(this),$C(124),4) I '(X=""),'$$vCaEx7() D vRCvalidateDDerr("SELECTRTS",$$^MSG(1485,X))
 .	I ($D(vobj(this,-100,"0*","UPDATERTS"))&($P($E($G(vobj(this,-100,"0*","UPDATERTS")),5,9999),$C(124))'=$P(vobj(this),$C(124),2))) S X=$P(vobj(this),$C(124),2) I '(X=""),'$$vCaEx8() D vRCvalidateDDerr("UPDATERTS",$$^MSG(1485,X))
 .	Q 
 Q 
 ;
vRCvalidateDDerr(column,errmsg) ; 
 N ER S ER=0
 N RM S RM=""
 D SETERR^DBSEXECU("DBACCRTS","MSG",979,"DBACCRTS."_column_" "_errmsg)
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
 N oldparams S oldparams=vRCparams
 N newKey1 S newKey1=vobj(this,-3)
 N oldKey1 S oldKey1=$S($D(vobj(this,-100,"1*","TABLENAME")):$P($E(vobj(this,-100,"1*","TABLENAME"),5,9999),$C(124)),1:vobj(this,-3))
 N newKey2 S newKey2=vobj(this,-4)
 N oldKey2 S oldKey2=$S($D(vobj(this,-100,"2*","USERCLASS")):$P($E(vobj(this,-100,"2*","USERCLASS"),5,9999),$C(124)),1:vobj(this,-4))
  N V1,V2 S V1=vobj(this,-3),V2=vobj(this,-4) I ($D(^DBACCRTS(V1,V2))) D throwError($$^MSG(2327))
 S newkeys=newKey1_","_newKey2
 S oldkeys=oldKey1_","_oldKey2
  S vobj(this,-3)=oldKey1
  S vobj(this,-4)=oldKey2
 S vRCparams=$$setPar^UCUTILN(vRCparams,"NOINDEX")
 D vRCforceLoad(this)
 I (("/"_vRCparams_"/")["/VALREQ/") D vRCchkReqForInsert(this)
 I (("/"_vRCparams_"/")["/TRIGBEF/") D vRCbeforeUpdTrigs(this,vRCparams,.vRCaudit)
 I (("/"_vRCparams_"/")["/VALDD/") D vRCvalidateDD(this,1)
 D vRCmiscValidations(this,vRCparams,1)
 D vRCupdateDB(this,1,vRCparams,.vRCaudit,.vRCauditIns)
  S vobj(this,-3)=newKey1
  S vobj(this,-4)=newKey2
 N newrec S newrec=$$vReCp1(this)
 S vobj(newrec,-2)=0
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBACCRTS(newrec,$$initPar^UCUTILN($$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/"))) K vobj(newrec,-100) S vobj(newrec,-2)=1 TC:vTp  
 D
 .	N %O S %O=1
 .	N ER S ER=0
 .	N RM S RM=""
 .	;   #ACCEPT Date=10/24/2008; Pgm=RussellDS; CR=30801; Group=ACCESS
 .	D CASUPD^DBSEXECU("DBACCRTS",oldkeys,newkeys)
 .	I ER D throwError($get(RM))
 .	Q 
  S vobj(this,-3)=oldKey1
  S vobj(this,-4)=oldKey2
 S vRCparams=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
 D vRCdelete(this,vRCparams,.vRCaudit,1)
  S vobj(this,-3)=newKey1
  S vobj(this,-4)=newKey2
 S vRCparams=oldparams
 I (("/"_vRCparams_"/")["/TRIGAFT/") D vRCafterUpdTrigs(this,vRCparams)
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
vDbDe1() ; DELETE FROM DBACCRTS WHERE TABLENAME=:V3 AND USERCLASS=:V4
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vRec S vRec=$$vRCgetRecord1^RecordDBACCRTS(V3,V4,0)
 I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordDBACCRTS(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 K vobj(+$G(vRec)) Q 
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
vCaEx1() ; {Cache}%CACHE("STBLDBACCRTS").isDefined("STBLDBACCRTS","OPTION=:X")
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vRec,vop1 S vRec=$$vCa2(X,.vop1)
 S vret=$G(vop1)=1 Q vret
 ; ----------------
 ;  #OPTION ResultClass 1
vCaEx2() ; {Cache}%CACHE("STBLDBACCRTS").isDefined("STBLDBACCRTS","OPTION=:X")
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vRec,vop1 S vRec=$$vCa2(X,.vop1)
 S vret=$G(vop1)=1 Q vret
 ; ----------------
 ;  #OPTION ResultClass 1
vCaEx3() ; {Cache}%CACHE("STBLDBACCRTS").isDefined("STBLDBACCRTS","OPTION=:X")
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vRec,vop1 S vRec=$$vCa2(X,.vop1)
 S vret=$G(vop1)=1 Q vret
 ; ----------------
 ;  #OPTION ResultClass 1
vCaEx4() ; {Cache}%CACHE("STBLDBACCRTS").isDefined("STBLDBACCRTS","OPTION=:X")
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vRec,vop1 S vRec=$$vCa2(X,.vop1)
 S vret=$G(vop1)=1 Q vret
 ; ----------------
 ;  #OPTION ResultClass 1
vCaEx5() ; {Cache}%CACHE("STBLDBACCRTS").isDefined("STBLDBACCRTS","OPTION=:X")
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vRec,vop1 S vRec=$$vCa2(X,.vop1)
 S vret=$G(vop1)=1 Q vret
 ; ----------------
 ;  #OPTION ResultClass 1
vCaEx6() ; {Cache}%CACHE("STBLDBACCRTS").isDefined("STBLDBACCRTS","OPTION=:X")
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vRec,vop1 S vRec=$$vCa2(X,.vop1)
 S vret=$G(vop1)=1 Q vret
 ; ----------------
 ;  #OPTION ResultClass 1
vCaEx7() ; {Cache}%CACHE("STBLDBACCRTS").isDefined("STBLDBACCRTS","OPTION=:X")
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vRec,vop1 S vRec=$$vCa2(X,.vop1)
 S vret=$G(vop1)=1 Q vret
 ; ----------------
 ;  #OPTION ResultClass 1
vCaEx8() ; {Cache}%CACHE("STBLDBACCRTS").isDefined("STBLDBACCRTS","OPTION=:X")
 N vret
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N vRec,vop1 S vRec=$$vCa2(X,.vop1)
 S vret=$G(vop1)=1 Q vret
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
vCa2(v1,v2out) ; voXN = ({Cache}%CACHE("STBLDBACCRTS").getRecord(STBLDBACCRTS,1)
 ;
 I '$D(%CACHE("STBLDBACCRTS",v1)) D
 .  I $G(%CACHE("STBLDBACCRTS"))>100 KILL %CACHE("STBLDBACCRTS")
 .  S %CACHE("STBLDBACCRTS")=$G(%CACHE("STBLDBACCRTS"))+1
 .  S %CACHE("STBLDBACCRTS",v1)=$$vRCgetRecord1Opt^RecordSTBLDBACCRTS(v1,0,.v2out),%CACHE("STBLDBACCRTS",v1,-2)=v2out
 ;
 ;
 E  S v2out=%CACHE("STBLDBACCRTS",v1,-2)
 Q %CACHE("STBLDBACCRTS",v1)
 ;
vOpen1() ; COUNT(TABLENAME) FROM DBACCRTS WHERE TABLENAME=:V1 AND USERCLASS=:V2
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL1a0
 S vos4=$G(V2) I vos4="" G vL1a0
 I '($D(^DBACCRTS(vos3,vos4))) G vL1a7
 S vos1=100
 I vos3'="" S vos5=$G(vos5)+1
vL1a7 I $G(vos5)="" S vos5=0
 Q
 ;
vFetch1() ;
 ;
 ;
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$G(vos5)
 S vos1=100
 S vos1=0
 ;
 Q 1
 ;
vOpen2() ; USERCLASS FROM DBACCRTS WHERE TABLENAME='DBACCRTS' AND USERCLASS<>:V1 AND INSERTRTS=2 AND UPDATERTS=2 AND DELETERTS=2 AND SELECTRTS=2
 ;
 ;
 S vos1=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos1=0 Q
vL2a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="",'$D(V1) G vL2a0
 S vos4=""
vL2a4 S vos4=$O(^DBACCRTS("DBACCRTS",vos4),1) I vos4="" G vL2a0
 I '(vos4'=vos3) G vL2a4
 S vos5=$G(^DBACCRTS("DBACCRTS",vos4))
 I '(+$P(vos5,"|",1)=2) G vL2a4
 I '(+$P(vos5,"|",2)=2) G vL2a4
 I '(+$P(vos5,"|",3)=2) G vL2a4
 I '(+$P(vos5,"|",4)=2) G vL2a4
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos1=1 D vL2a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs1="" Q 0
 ;
 S vos5=$G(^DBACCRTS("DBACCRTS",vos4))
 S rs1=$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen3() ; COUNT(TABLENAME) FROM DBACCRTS
 ;
 ;
 S vos6=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos6=0 Q
vL3a1 S vos7=$$BYTECHAR^SQLUTL(254)
 S vos8=""
vL3a3 S vos8=$O(^DBACCRTS(vos8),1) I vos8="" G vL3a8
 S vos9=""
vL3a5 S vos9=$O(^DBACCRTS(vos8,vos9),1) I vos9="" G vL3a3
 I $S(vos8=vos7:"",1:vos8)'="" S vos10=$G(vos10)+1
 G vL3a5
vL3a8 I $G(vos10)="" S vos10=0
 Q
 ;
vFetch3() ;
 ;
 ;
 I vos6=1 D vL3a8
 I vos6=2 S vos6=1
 ;
 I vos6=0 S rscnt="" Q 0
 ;
 S rscnt=$G(vos10)
 S vos6=100
 ;
 Q 1
 ;
vOpen4() ; FID FROM DBTBL1 WHERE %LIBS='SYSDEV' AND FID <> 'DBACCRTS'
 ;
 ;
 S vos11=2
 D vL4a1
 Q ""
 ;
vL4a0 S vos11=0 Q
vL4a1 S vos12=$$BYTECHAR^SQLUTL(254)
 S vos13=""
vL4a3 S vos13=$O(^DBTBL("SYSDEV",1,vos13),1) I vos13="" G vL4a0
 I '(vos13'="DBACCRTS") G vL4a3
 Q
 ;
vFetch4() ;
 ;
 ;
 I vos11=1 D vL4a3
 I vos11=2 S vos11=1
 ;
 I vos11=0 S rs2="" Q 0
 ;
 S rs2=$S(vos13=vos12:"",1:vos13)
 ;
 Q 1
 ;
vOpen5() ; TABLENAME FROM DBACCRTS
 ;
 ;
 S vos1=2
 D vL5a1
 Q ""
 ;
vL5a0 S vos1=0 Q
vL5a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL5a3 S vos3=$O(^DBACCRTS(vos3),1) I vos3="" G vL5a0
 S vos4=""
vL5a5 S vos4=$O(^DBACCRTS(vos3,vos4),1) I vos4="" G vL5a3
 Q
 ;
vFetch5() ;
 ;
 ;
 I vos1=1 D vL5a5
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos3=vos2:"",1:vos3)
 ;
 Q 1
 ;
vOpen6() ; USERCLASS FROM DBACCRTS WHERE TABLENAME='DBACCRTS' AND USERCLASS<>:V1 AND INSERTRTS=2 AND UPDATERTS=2 AND DELETERTS=2 AND SELECTRTS=2
 ;
 ;
 S vos1=2
 D vL6a1
 Q ""
 ;
vL6a0 S vos1=0 Q
vL6a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="",'$D(V1) G vL6a0
 S vos4=""
vL6a4 S vos4=$O(^DBACCRTS("DBACCRTS",vos4),1) I vos4="" G vL6a0
 I '(vos4'=vos3) G vL6a4
 S vos5=$G(^DBACCRTS("DBACCRTS",vos4))
 I '(+$P(vos5,"|",1)=2) G vL6a4
 I '(+$P(vos5,"|",2)=2) G vL6a4
 I '(+$P(vos5,"|",3)=2) G vL6a4
 I '(+$P(vos5,"|",4)=2) G vL6a4
 Q
 ;
vFetch6() ;
 ;
 ;
 I vos1=1 D vL6a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos5=$G(^DBACCRTS("DBACCRTS",vos4))
 S rs=$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vReCp1(v1) ; RecordDBACCRTS.copy: DBACCRTS
 ;
 N vNod,vOid
 I $G(vobj(v1,-2)) D
 .	F vNod=1,2,3,4 S:'$D(vobj(v1,vNod)) vobj(v1,vNod)=$G(^DBACCRTS(vobj(v1,-3),vobj(v1,-4),vNod))
 S vOid=$$copy^UCGMR(v1)
 Q vOid
 ;
vCatch1 ; Error trap
 ;
 N err,$ET,$ES S err=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 S ckrts=""
 D ZX^UCGMR(voxMrk) Q 
