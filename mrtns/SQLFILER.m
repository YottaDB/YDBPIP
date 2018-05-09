SQLFILER(fid,obj) ; Database filer utility
	;;Copyright(c)2000 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/10/00 10:39:34 - SPIER
	;
        ; ORIG: CHIANG - 10/05/1999
        ; DESC: General purpose database filer utility to handle SQL
	;       INSERT/UPDATE/DELETE statements
	;
	; ARGUMENTS:
	;
	; . fid		Table name	/TYP=T/REQ/MECH=VAL
	; . obj		Object name	/TYP=N/REQ/MECH=REFARRY:R
	;
	; OUTPUT:
	;
	; . ER		Error flag	/TYP=N
	; . RM		Error message	/TYP=T
	;
	; EXAMPLE:
	;
	;  S vobj(1)=new data			; data
	;  S vobj(1,-100,"DESC")=old data	; audit information
	;  S vobj(1,-3)=200			; access key
	;  S vobj(1,-2)=1			; processing mode
	;
	; D SQLFILER("UTBLCC",.vobj)
	;----------------------------------------------------------------------
	; I18N=QUIT
	;----------------------------------------------------------------------
	;---- Revision History ------------------------------------------------
	; 06/21/2008 - RussellDS - CR30801
	;	Moved KEYWHR code here from DBSFILB.  This is only remaining
	;	user.
	;
	; 09/29/07 - RussellDS - CR29295
	;	     Modified RDBFILE section to remove obsolete call to
	;	     VOBJ^DBSDBASE and replace with call to rdbSaveC^UCDBRT.
	;
	; 02/22/07 - GIRIDHARANB - CR25217
	;	     Modified section LOG to call AUDIT^UCUTILN.
	;
	; 01/15/07 - RussellDS - CRs: 24840 / 24860
	;	     Modified delete code in RDBFILE section that constructs
	;	     bind variable list to no longer add single quotes.
	;
	; 08/31/06 - RussellDS - CRs: 22719 / 20613
	;	     Modified RDBFILE section for call to VOBJ^DBSDBASE for
	;	     new parameters.
	;
	;	     Replaced call to AUDIT^UCUTIL with current call to
	;	     AUDIT^UCUTILN.
	;
	; 12/28/05 - GIRIDHARANB - CR18258
	;	     Modified section RDBFILE to correct table name parameter 
	;	     passed into TYP^SQLDD.
	;
	; 03/25/05 - GIRIDHARANB/RussellDS - CR15133
	;	     Added support for rdb inserts,updates and deletes.
	;
	; 08/10/00 - SPIER - 41471/37925
	;            Change n=.001 to n=-1 to allow filing of rec type 10/11
	;	     that use node 0.
	;
	; 02/07/00 - Chiang - 31126
	;            Modified to log user/system table changes.
	;
	;            Modified to add $D logic to avoid <UNDEF> error for type
	;            11 records.
	;
	;----------------------------------------------------------------------
	N %O,expr,fsn,isRdb,keys,log,n,rtyp,ref,sn
	;
	S ER=0
	I '$D(fsn(fid)) D fsn^SQLDD(.fsn,fid)		; Table attributes
	I $G(ER) Q
	S sn=$P($P(fsn(fid),"|",1),"(",1)		; Internal array name
	I sn'="" N @sn
	S rtyp=$P(fsn(fid),"|",4)			; Record type
	S log=$P(fsn(fid),"|",7)			; Log option
	S ref=$$GBLREF(fid,obj)				; Global reference
	S keys=$P(fsn(fid),"|",3)			; Access keys
	S %O=$G(vobj(obj,-2))+0				; Processing mode
	S isRdb=$$rdb^UCDB(fid)
	I isRdb do RDBFILE(fid,obj) quit
	I %O=3 X "ZWI "_ref Q				; Delete record
	;
	I rtyp=1!(rtyp=11) X "S "_ref_"=$G(vobj("_obj_"))"
	I rtyp=10!(rtyp=11) D  X expr
	.	S ref=$E(ref,1,$l(ref)-1)_",n)"
	.	I '%O S expr="S n=-1 f  S n=$O(vobj("_obj_",n)) q:n=""""  S "_ref_"=vobj("_obj_",n)" Q
	.	S expr="S n="""" f  S n=$O(vobj("_obj_",-100,n)) q:n=""""  I $D(vobj("_obj_",n)) S "_ref_"=vobj("_obj_",n)"
	I log D LOG
        Q
	;----------------------------------------------------------------------
GBLREF(fid,obj) ; Public
	;----------------------------------------------------------------------
	; ARGUMENT:
	;
	; . fid		Table name		/TYP=T/REQ/REF=VAL
	; . obj		Object name		/TYP=N/REQ/REF=VAL
	;
	; RETURN:
	;
	; $$		Global reference (in object format)
	;
	; EXAMPLE:
	;
	; W $$GBLREF("UTBLCC")
	;
	; ^UTBL("CC",vobj(utblcc,-3))
	;----------------------------------------------------------------------
	N gbl,gblref,i,j,key,keys,v
	S obj=$G(obj)+0					; object name
	I '$D(fsn(fid)) D fsn^SQLDD(.fsn,fid)		; Table attributes
	I $G(ER) Q ""
	S gblref=$p(fsn(fid),"|",2)			; Global reference
	S gbl=$P(gblref,"(",1)				; Global name
	S keys=$P(gblref,"(",2)				; access keys
	S v="",j=1
	F i=1:1:$L(keys,",") D
	.	S key=$P(keys,",",i)			; Key
	.	I $e(key)=""""!($E(key)?1N) S v=v_","_key Q	; dummy
	.	S v=v_",vobj("_obj_",-"_(2+j)_")",j=j+1
	Q gbl_"("_$E(v,2,9999)_")"
	;
	;----------------------------------------------------------------------
LOG	; Log user/system table changes
	;----------------------------------------------------------------------
	N i,key,vx
	I keys'="" N @keys
	F i=1:1:$L(keys,",") D
	.	S key=$P(keys,",",i)
	.	S @key=vobj(obj,-i-2)			; Key value
	I %O=1 D AUDIT^UCUTILN(obj,.vx,rtyp,$C($P(fsn(fid),"|",10)))		; convert -100 level into vx() array
	D PSL(fid,%O,obj,.vx)				; Log changes
	Q
        ;----------------------------------------------------------------------
PSL(fid,%O,obj,vx) ; Called by filer to convert vx() structure into UX(FID,DI) format
        ;----------------------------------------------------------------------
	; ARGUMENTS:
	;
	; . fid		Table name		/TYP=T/REQ/MECH=VAL
	; . %O		Processing mode		/TYP=N/REQ/MECH=VAL
	; . obj		Object name		/TYP=N/REQ/MECH=VAL
	; . vx		Column changed status	/TYP=T/REQ/MECH=REFARRY:R
	;
	;----------------------------------------------------------------------
        N UX,di,i
	I '%O D PSL0 Q					; Create mode
        S di="" F  S di=$O(vx(di)) Q:di=""  S UX(fid,di)=vx(di)
        D ^DBSLOG(fid,%O,.UX)				; Modify mode
        Q
PSL0	;
	N fsn,rtyp,sn
	D fsn^SQLDD(.fsn,fid)				; Table attributes
	I $G(ER) Q
	S sn=$P($P(fsn(fid),"|",1),"(",1)		; Internal array name
	I sn'="" N @sn
	S rtyp=$P(fsn(fid),"|",4)			; Record type
	S keys=$P(fsn(fid),"|",3)			; Access keys
	I rtyp=1!(rtyp=11) S @sn=$G(vobj(obj))		; copy into short name
	I rtyp=10!(rtyp=11) D				; copy into short name array
	.	S sn=sn_"(n)"
	.	S n=-1 f  S n=$O(vobj(obj,n)) q:n=""  S @sn=vobj(obj,n)
	D ^DBSLOG(fid,%O)
	Q
	;--------------------------------------------------------------------
RDBFILE(fid,obj); files to the relational database.
	;---------------------------------------------------------------------
	N del,I,keys,natfid,objName,sql,tblrec,typ,vER,vRM,vList
	S vER=0
	S tblrec=$$getSchTbl^UCXDD(fid)
	S keys=$P(tblrec,"|",3),objName=$$LOWER^UCGMR(fid)
	S del=$C($P(tblrec,"|",10))
	S keywhr=$$KEYWHR(fid,keys,isRdb,.natfid)
	I keywhr'="" set keywhr=" WHERE "_keywhr
	I %O=3 D
	.	S sql(1)="DELETE FROM "_natfid_keywhr
	.	S vList(1)=""
	.	F J=1:1:$L(keys,",") D
	..		S typ=$$TYP^SQLDD(fid_"."_$P(keys,",",J))
	..		S vList(1)=vList(1)_vobj(obj,-J-2)_del
	.		S I="" F  S I=$order(sql(I)) Q:(I="")  S vER=$$EXECUTE^%DBAPI("",sql(I),del,vList(I),.vRM) I vER<0 Q
	; Although rdbSaveS can be called for one node tables, just call
	; rdbSaveC since it will work in all cases and is probably not that much
	; more expensive than figuring out if this table could use rdbSaveS
	E  D rdbSaveC^UCDBRT(obj,del,keywhr)
	; Shouldn't we pass some message back here ??
	I vER<0 S ER=1 Q
	Q
	;
KEYWHR(table,keys,isRDB,nattable)
	;
	S ER=0
	;
	N col,di,i,ret
	;
	S nattable=table
	D MAP^DBMAP(%DB,.nattable)
	;
	I keys="" Q ""
	;
	S ret=""
	F i=1:1:$L(keys,",") D  Q:ER
	.	I i>1 S ret=ret_" and "
	.	S di=$$LOWER^SCAUTL($piece(keys,",",i),0)
	.	S col=$$UPPER^SCAUTL(di)
	.	;
	.	I isRDB D
	..		D MAP^DBMAP(%DB,table,.col)
	..	I ER WRITE " Aborted - ",table,".",col," not in DBMAP",!
	.	;
	.	I 'ER S ret=ret_col_" =:vkey"_i
	;
	Q ret