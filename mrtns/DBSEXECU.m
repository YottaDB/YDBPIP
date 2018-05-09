DBSEXECU	;Public; Transaction executive utility
	;;Copyright(c)2003 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/01/03 12:02:00 - SPIER
	;
	; Transaction executive
	;
	; KEYWORDS:	EXECUTIVE,FILER,TP
	;
	; LIBRARY:
	;	. CASDEL   - Cascade delete foreign keys
	;	. CASUPD   - Cascade update foreign keys
	;	. DELERR   - Remove override entries
	;	. DSPERR   - Display error messages
	;	. EFD      - Create EFD entries
	;	. OVRERR   - Override processing
	;	. SETERR   - Create error indicators
	;	. VERDATA  - Verify the integrity of the local database buffer
	;	. XBAD     - Create XBAD entries
	;I18N=QUIT
	;
	;---- Revision History ------------------------------------------------
	; 02/22/06 - RussellDS - CR19065
	;	     Removed references to XBAD global by replacing with
	;	     temporary call to XBAD^DBSDI.  When this routine is
	;	     converted to PSL, remove those sections of DBSDI.
	;
	; 01/10/06 - RussellDS - CR18942
	;	     Removed references to STBL globals by replacing with
	;	     temporary calls to STBLER and STBLXBAD^DBSDI.  When this
	;	     routine is converted to PSL, remove those sections of DBSDI.
	;
	; 09/27/05 - RussellDS - CR17311
	;	     Eliminate EFD and related sections.  Code now resides in
	;	     SQLEFD.proc
	;
	;	     Removed old revision history.
	;
	; 05/05/05 - SWARNALATHAP - 13769
	;            Modified SETERR section to change the data existence check   
	;	     for the repeating screen keys from '$D(@key) to '($D(@key)#2)
	;	     since this will resolve the UNDEFINED error that was caused 
	;	     due to the name conflict between the KEY() array set up by 
	;	     the screen driver and the name of the key for the table 
	;	     UTBLREGION(UTBLREGION.KEY)
	;
	;----------------------------------------------------------------------
UX2SQL(sql,rev)	; Convert UX(fid,di) information into SQL statement
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;
	;  . sql	SQL statement			/TYP=T/REQ/MECH=REFARRY:W
	;		sql(seq)=statement
	;  . rev	Reverse old and new value	/TYP=L/NOREQ/DEF=0
	;
	; INPUTS:
	;
	;  . UX		Field changed array	/TYP=T/REQ/MECH=REFARRY:R
	;
	;		UX(fid,di)=old_value|new_value|node|pos
	; EXAMPLES:
	;
	;  CID=123  
	;  UX("DEP","BOO")="1|2"
	;  UX("DEP","LNM")="DOE|SMITH"
	;
	; D VDDEFD(.sql) returns
	;      sql(1)=UPDATE DEP SET BOO=2,LNM='SMITH' WHERE CID=123|DEP|123
	;
	; D VDDEFD(.sql,1) returns
	;      sql(1)=UPDATE DEP SET BOO=1,LNM='DOE' WHERE CID=123|DEP|123
	;
	;----------------------------------------------------------------------
	N di,fid,fsn,i,key,keys,keyval,v,val,vseq,whr
	K sql
	S fid="",di="",vseq=1
	F  S fid=$O(UX(fid)) Q:fid=""  D
	.	I ",IRATYPE,CIF,DEP,LN,ACNADDR,SADDRCIF,SADDRACN"'[(","_fid_","),($E(fid)'="Z") Q
	.	S v="UPDATE "_fid_" SET "
	.	F  S di=$O(UX(fid,di)) Q:di=""  D 
	..		I $G(UX(fid,di))="" Q		; Invalid UX format
	..		I $G(rev) S val=$P(UX(fid,di),"|",1)	; Old value
	..		E  S val=$P(UX(fid,di),"|",2)	; New value
	..		I ("FMTU"[$P(X,"|",9)) S val="'"_val_"'"   ;pc 7/17/01
	..		S v=v_di_"="_val_","		; di=val,di=val
	.	D fsn^DBSDD(.fsn,fid)			; File attributes
	.	S keys=$P(fsn(fid),"|",3)
	.	S whr="",keyval=""
	.	F i=1:1:$L(keys,",") D
	..		S key=$P(keys,",",i),whr=whr_key_"="_@key
	..		I i'=$L(keys,",") S whr=whr_" AND "	;BURNSM 11/02/01
	..		S keyval=keyval_","_@key
	.	S sql(vseq)=$E(v,1,$l(v)-1)_" WHERE "_whr_"|"_fid_"|"_$E(keyval,2,999)
	.	S vseq=vseq+1
	Q
	;
	;----------------------------------------------------------------------
SETERR(fid,errtyp,errcode,par,col,cv,av) ;
	;----------------------------------------------------------------------
	; Utility to set up verrors() array
	;
	; ARGUMENTS:
	;
	;  . fid	Filer table name	/TYP=T/REQ/TBL=[DBTBL1]/MECH=VAL
	;  . errtyp     Error type		/TYP=T/REQ/MECH=VAL
	;		XBAD, ER or MSG
	;  . errcode    Error code		/TYP=T/REQ/MECH=VAL
	;					/TBL=[STBLXBAD],[STBLER],[STBLMSG]
	;  . par	Message parameter       /TYP=T/NOREQ/MECH=VAL
	;  . col	Column name		/TYP=T/NOREQ/MECH=VAL
	;  . cv		Current value		/TYP=T/NOREQ/MECH=VAL
	;  . av		Alternate value		/TYP=T/NOREQ/MECH=VAL
	;
	; OUTUT:
	;
	;  verrors(tran_num)=table|keys|group
	;	  tran_num,seq)=fatal flag|errtyp|errcode|par|col|cv|av
	;----------------------------------------------------------------------
	;
	N er,fatal,fsn,i,key,keys,node,p,trannum,seq,vkey,I
	S ER=0,node="",vkey=""
	D fsn^DBSDD(.fsn,fid)				; File attributes
	S keys=$P(fsn(fid),"|",3)
	;
	I keys'="" F i=1:1:$L(keys,",") D		; 08/12/99
	.	S key=$P(keys,",",i)			; Access key
	.	I '($D(@key)#2) Q			; Repeating screen keys
	.	S vkey=vkey_","_@key			; Key value
	S vkey=$E(vkey,2,99)			
	S trannum=$O(verrors(""),-1)+1			; Next sequence
	S verrors(trannum)=fid_"|"_vkey			; Header information
	S fatal=1					; Fatal error indicator
	I errtyp="XBAD" D
	.	N stblxbad
	.	S stblxbad=$$STBLXBAD^DBSDI(errcode)
	.	S fatal=$P(stblxbad,"|",4) ; Error indicator
	.	S RM=$P(stblxbad,"|",1)		; Error message
	.	I $G(par)'="",$G(col)="" D
	..		I RM'["~" Q
  	..		S RM=$P(RM,"~p1",1)_$p(par,"~",1)_$P(RM,"~p1",2,99)
  	..		I RM["~p2" S RM=$P(RM,"~p2",1)_$p(par,"~",2)_$P(RM,"~p2",2,99)
  	..		I RM["~p3" S RM=$P(RM,"~p3",1)_$p(par,"~",3)_$P(RM,"~p3",2,99)
  	..		S par=""
 	;
	I errtyp="ER" D					; One or two line meg
	.	N stbler
	.	S stbler=$$STBLER^DBSDI(errcode)
	.	S RM(1)=$P(stbler,"|",1),RM(2)=$p(stbler,"|",6)
	.	F I=1,2 I $G(RM(I))["<<" D VSUB^UTLERR
	.	I RM(2)="" S RM=RM(1) K RM(1),RM(2)
	;
	I errtyp="MSG" D
	.	N ER,fsn
	.	f i=1:1:5 S p(i)=$P($G(par),"~",i) I p(i)?1A.AN S p(i)=$S($D(@p(i)):@p(i),1:p(i))
	.	I p(1)?1A.AN1"."1A.AN S p(1)=p(1)_" ("_$$DES^DBSDD(p(1))_")"
	.	S RM=$$^MSG(errcode,p(1),p(2),p(3),p(4),p(5))
	;
	S er=fatal_"|"_errtyp_"|"_errcode_"|"_$G(par)_"|"
	I errtyp="XBAD" S er=er_$G(par)_"|"_$G(col)_"|"_$G(cv)
	S $P(er,"|",8)=RM				; Error message
	;
	S seq=$O(verrors(trannum,""),-1)+1		; Next sequence
	S verrors(trannum,seq)=er
	I fatal,$G(%O)'=2 S ER=1 K verrors		; Fatal error
	Q
	;----------------------------------------------------------------------
DELERR(fid,errtyp,errcode) ;
	;----------------------------------------------------------------------
	; Utility to remove verrors() array entries
	;
	; ARGUMENTS:
	;
	;  . fid	Filer table name	/TYP=T/REQ/TBL=[DBTBL1]/MECH=VAL
	;  . errtyp     Error type		/TYP=T/REQ/MECH=VAL
	;		XBAD, ER or MSG
	;  . errcode    Error code		/TYP=T/REQ/MECH=VAL
	;
	; EXAMPLE:
	;
	; D DELERR^DBSEXECU("CIF","XBAD","CIFDOB")
	;
	;----------------------------------------------------------------------
	N seq,subseq
	S seq="",subseq=""
	F  S seq=$O(verrors(seq)) Q:seq=""  D
	.	I $P(verrors(seq),"|",1)'=fid Q		     ; table name
	.	F  S subseq=$O(verrors(seq,subseq)) Q:subseq=""  D
	..		I $P(verrors(seq,subseq),"|",2)'=errtyp Q   ; Error type
	..		I $P(verrors(seq,subseq),"|",3)'=errcode Q  ; error code
	..		K verrors(seq,subseq)		       ; Remove entry
	.	I '$O(verrors(seq,"")) K verrors(seq)	       ; delete header
	Q
	;----------------------------------------------------------------------
XBAD(error) ; Create [XBAD] entries
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;
	;  . error	Error log		/TYP=T/REQ/MECH=REFARRY:R
	;
	; INPUTS:
	;
	;  TJD		System date		/TYP=D/REQ
	;  %O		Processing mode		/TYP=N/REQ
	;
	;----------------------------------------------------------------------
	N buff,i,seq,sts,type,v,ercode,ercodseq
	;
	S buff="" F  S buff=$O(error(buff)) Q:buff=""  D
	.	S v=error(buff)				; Header information
	.	S fid=$P(v,"|",1),keys=$P(v,"|",2)	; Table and keys
	.	S seq="" F  S seq=$O(error(buff,seq)) Q:seq=""  D
	..		S v=error(buff,seq)		; Error log
	..		S $P(v,"|",9)=+v		; Fatal error
	..		; determine if the error type has occurred more 
	..		; then once for the account and update keys accordingly
	..		S ercode=$P(v,"|",3)		;
	..		S ercodseq=$G(ercodseq(fid,ercode))+1
	..		S ercodseq(fid,ercode)=ercodseq
	..		I ercodseq>1 S ercode=ercode_"-"_ercodseq
	..		;
	..		; Call XBAD^DBSDI to allow database independence
	..		; until this is converted to PSL
	..		D XBAD^DBSDI(TJD,fid,keys,ercode,$p(v,"|",5,99))
	Q
	;
	;----------------------------------------------------------------------
DSPERR(ACNNUM,IO)	; Copy verror() into temp global ^ERRORS($J) and then call rpt ACNVER
	;----------------------------------------------------------------------
	;
	; ARGUMENTS:
	;
	;	. ACNNUM  Account/customer number	/TYP=N/REQ/MECH=VAL
	;
	;----------------------------------------------------------------------
	I $G(%LIBS)="" N %LIBS S %LIBS=^CUVAR("%LIBS")
	S RID="SCA290"
	I $G(IO)="" S IO=0
	S %BLK="/,"_IO_","_TJD_",,"_ACNNUM D DRV^URID
	Q
	;----------------------------------------------------------------------
OVRERR(verrors)	; Override logic
	;----------------------------------------------------------------------
	;
	; ARGUMENTS:
	;
	;  . verrors	Error log		/TYP=T/REQ/MECH=REFARRY:R
	;
	; OUTPUTS:
	;
	;  ER		Error flag
	;----------------------------------------------------------------------
	I $G(%IPMODE)["NOINT" Q			   		; Called from client
	N buff,ercode,seq,ztbl,v,v1,vseq,%LINK,%REPEAT,ERRORS,PGM,SID,KVAR,UX
	;
	S buff="",seq="",vseq=0,ER=0,ztbl=$P($G(verrors(1)),"|",1)
	F  S buff=$O(verrors(buff)) Q:buff=""  D  Q:ER
	.	F  S seq=$O(verrors(buff,seq)) Q:seq=""  D  Q:ER
	..		S v=verrors(buff,seq)			; Build screen data
	..		S v1=$p(v,"|",3)_$p(v,"|",8)		; Error and desc 
	..		I $D(ercode(v1)) Q			; Duplicate
	..		S ercode(v1)=""				; Save error code
	..		S vseq=vseq+1
	..		S $P(ERRORS(vseq),"|",1)=$P(v,"|",3)	; Error code
	..		S $P(ERRORS(vseq),"|",2)=$P(v,"|",8)	; Description
	..		S $P(ERRORS(vseq),"|",4)="__________"	; Password
	..		S $P(ERRORS(vseq),"|",5)=$P(v,"|",1)	; Fatal flag
	..		;
	N %O S %O=1
	;
	I ztbl="CIF" S SID="OVRINTCIF"	
	E  S SID="OVRINT"					; DEP/LOAN
	D ^USID I PGM="" S ER=1 Q
	S %REPEAT=$O(ERRORS(""),-1)				; Error count
	D ^@PGM							; Override logic
	I VFMQ="Q" S ER=1 Q					; Exit screen
	I ztbl="CIF" D dayendxb(.ERRORS,ACN,ztbl) X KVAR Q
	D dayendxb(.ERRORS,CID,ztbl)				; Dayend entry
	X KVAR
	Q
	;----------------------------------------------------------------------
dayendxb(ERROR,CID,tbl) ; Create dayend override log
	;----------------------------------------------------------------------
	S tbl=$G(tbl)
	I $G(%LOGID) D STUB^PBSCLI("dayendxb^DBSEXECU(.ERROR,CID,tbl)") Q
	N ET,SEQ,UID
	S SEQ="" F  S SEQ=$O(ERROR(SEQ)) Q:SEQ=""  D
	.	S ET=$P(ERROR(SEQ),"|",1),UID=$P(ERROR(SEQ),"|",3)
	.	I tbl="CIF" S ^DAYEND(TJD,"XBADC",%UID,ACN,SEQ,ET)=UID Q
	.	S ^DAYEND(TJD,"XBAD",%UID,CID,SEQ,ET)=UID	; Override log
	Q
	;----------------------------------------------------------------------
CASUPD(fid,ov,nv) ; Cascade update
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;
	;	fid	File Name	/TYP=T/REQ/TBL=[DBTBL1]/MECH=VAL
	;	ov      Old key value	/TYP=T/REQ/MECH=VAL
	;	nv      New key value	/TYP=T/REQ/MECH=VAL
	;
	; RETURNS:
	;
	;	ER	Error flag
	;
	; EXAMPLE:
	;
	;	D CASUPD("ACN","CID",123,456)
	;
	;----------------------------------------------------------------------
	N cnt,fkfl,flist,i,key,lib,opt,set,sql,supfid,whr
	;
	S lib="SYSDEV"
	D upd(fid) Q:ER						; Main file
	S supfid=$P(^DBTBL(lib,1,fid,10),"|",4)			; Supertype file
	I supfid="" Q
	I '$D(^DBINDX(lib,"PARFID",supfid)) Q
	D upd(supfid)						; Process supertype file
	Q
upd(fid) ;
	I '$D(^DBINDX(lib,"FKPTR",fid)) Q			; Not defined
	; ---- check if new account already on file
	;
	S fkfl="",key="",ER=0
	F  S fkfl=$O(^DBINDX(lib,"FKPTR",fid,fkfl)) Q:fkfl=""  D  Q:ER
	.	F  S key=$O(^DBINDX(lib,"FKPTR",fid,fkfl,key)) Q:key=""  D  Q:ER
	..		I '$D(^DBTBL(lib,19,fkfl,key)) Q	; Bad index
	..		S opt=$P(^(key),"|",4) 			; Update option
	..		I $D(^DBINDX(lib,"PARFID",fkfl)) Q	; Supertype
	..		I 'opt D exist(ov) Q			; Restriction
	..		D cassql				; Update
	Q
cassql	; Build SQL UPDATE statement
	;
	N z
	I $D(flist(fkfl)) Q					; Already processed
	S flist(fkfl)=""					; Mark it
	S set="",whr=""
	F i=1:1:$L(key,",") D					; Build SQL UPDATE command
	.	S set=set_","_$P(key,",",i)_"='"_$P(nv,",",i)_"'"
	.	S whr=whr_" AND "_$P(key,",",i)_"='"_$P(ov,",",i)_"'"
	;
	S sql=" SET "_$E(set,2,999)_" WHERE "_$E(whr,6,999)
	;
	;W !,"UPDATE ",fkfl,sql H 1			; *** DEBUG mode
	; table SET column=old_value,... WHERE column=new_val AND ...
	;
	S z=$$^SQL("UPDATE "_fkfl_sql,"/NOFKCHK=1")		; Execute
	Q
	;----------------------------------------------------------------------
CASDEL(fid,kval) ; Cascade delete
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;
	;	fid	File Name	/TYP=T/REQ/TBL=[DBTBL1]/MECH=VAL
	;	kval    Key value	/TYP=T/REQ/MECH=VAL
	;
	; RETURNS:
	;
	;	ER	Error flag
	;
	; EXAMPLE:
	;
	;	D CASDEL("ACN","CID",123)
	;
	;----------------------------------------------------------------------
	;
	N cnt,fkfl,flisti,key,lib,opt,set,sql,supfid,whr
	;
	S ER=0
	S lib="SYSDEV"
	D del(fid) I ER K flist Q				; Main file
	;
	S supfid=$P(^DBTBL(lib,1,fid,10),"|",4)			; Supertype file
	I supfid="" Q
	I '$D(^DBINDX(lib,"PARFID",supfid)) Q
	D del(supfid)						; Process supertype file
	I ER K flist Q
	Q
del(fid) ;
	N i
	I '$D(^DBINDX(lib,"FKPTR",fid)) Q			; Not defined
	;
	S fkfl="",key="",ER=0
	F  S fkfl=$O(^DBINDX(lib,"FKPTR",fid,fkfl)) Q:fkfl=""  D  Q:ER
	.	I fkfl=fid Q					; Invalid ptr
	.	F  S key=$O(^DBINDX(lib,"FKPTR",fid,fkfl,key)) Q:key=""  D  Q:ER
	..		I '$D(^DBTBL(lib,19,fkfl,key)) Q	; Bad index
	..		S opt=$P(^(key),"|",3) 			; Delete option
	..		I 'opt D exist(kval) I ER Q		; Restriction
	..		D delsql				; delete
	..		I ER Q
	Q
delsql	;
	I $D(flist(fkfl)) Q					; Already processed
	S flist(fkfl)=""					; Mark it
	S whr=""
	I $D(^DBINDX(lib,"PARFID",fkfl)) Q  			; Supertype
	I $$keyerr(fkfl,key) Q					; Missing keys
	F i=1:1:$L(key,",") D					; Build SQL UPDATE command
	.	S whr=whr_" AND "_$P(key,",",i)_"='"_$P(kval,",",i)_"'"
	S sql="DELETE "_fkfl_" WHERE "_$E(whr,6,999)		; DELETE command
	;
	;;W !,sql							; *** DEBUG
	N fid,fkfl
 	;
	; DELETE table WHERE key_column=key_val
	;
	I $G(par("CASDEL")) S z=$$^SQL(sql,"/CASDEL=1") Q
	S z=$$^SQL(sql,"/NOFKCHK=1")				; Delete record
	Q
	;----------------------------------------------------------------------
keyerr(file,keys) ;
	;----------------------------------------------------------------------
	N fsn,i,key,pkeys,ER
	S ER=0
	D fsn^SQLDD(.fsn,file)
	S pkeys=","_$p(fsn(file),"|",3)_","
	F i=1:1:$L(keys,",") D  Q:ER
	.	S key=$P(keys,",",i)
	.	I '$D(^DBTBL(%LIBS,1,file,9,key)) S ER=1
	Q ER
	;----------------------------------------------------------------------
exist(val)	; Verify if any record exist on file
	;----------------------------------------------------------------------
	;
	N whr,cnt,sql,z
	S whr="",cnt=0
	F i=1:1:$L(key,",") S whr=whr_" AND "_$P(key,",",i)_"='"_$P(val,",",i)_"'"
	;
	S sql="SELECT "_key_" FROM "_fkfl_" WHERE "_$E(whr,6,999)
	;
	;;W !,sql							; *** DEBUG
	S z=$$^SQL(sql,,,,.cnt)
	I 'cnt Q						; No record
	S ER=1,RM=$$^MSG(906,fkfl_"."_key,fid_" "_val) Q  ; Restricted
	Q
	;----------------------------------------------------------------------
VERDATA(UX) ; Private ; Compare between local buffer and database value
	;----------------------------------------------------------------------
	; ARGUMENT:
	;
	;	. UX	Local database buffer	/TYP=T/REQ/MECH=REFARRY:R
	;		UX(fid,di)=old|new|node|position
	;
	; OUTPUT:
	;
	;	ER	Error flag
	;	RM	Error message
	;----------------------------------------------------------------------
	N di,fid,fsn,gbl,n,ov,p,sn,v
	S ER=0
	S fid="" F  S fid=$O(UX(fid)) Q:fid=""  D vux I ER Q
	Q
vux	;
	D fsn^DBSDD(.fsn,fid)	 			; File attributes
	S gbl=$P(fsn(fid),"|",2)			; Global reference
	S rectyp=$P(fsn(fid),"|",4)			; Record type
	S di="" F  S di=$O(UX(fid,di)) Q:di=""  D  I ER Q
	.	S v=UX(fid,di),ov=$P(v,"|",1),n=$P(v,"|",3),p=$P(v,"|",4)
	.	I n=""!(p="") Q				; Invalid UX structure
	.	I rectyp=1 X "S v=$G("_gbl_"))"		; Current value
	.	I rectyp>1 X "S v=$G("_gbl_",n))"	; 
	.	I $P(v,"|",p)=ov Q			; Compare with buffer
	.	;
	.	; Value of fid.di has changed.  Update terminated.
	.	;
	.	S ER=1,RM=$$^MSG(362,fid,di) Q		; Changed since last access
	Q
