DBSFILER	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSFILER ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	Q  ; Do not call from top
	;
EXT(fid,%O,par)	;
	;
	; vfkey() is public array used by SQL for buffered commits in
	; order to perform foreign key checking at end.
	;
	N vtp
	N vtjd
	N I
	N vgbl N vkeys N vkeysx N vlvn N vpgm N vreftim N vreftld N vrefuid N vsysnm N vuid
	;
	S ER=0
	;
	I $$rdb^UCDB(fid) D  Q 
	.	;
	.	S ER=1
	.	S RM="^DBSFILER is not valid for RDB tables.  Rewrite caller to PSL using save methods."
	.	Q 
	;
	N dbtbl1 S dbtbl1=$$vDb1("SYSDEV",fid)
	 S vobj(dbtbl1,12)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),12))
	 S vobj(dbtbl1,100)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),100))
	 S vobj(dbtbl1,16)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),16))
	 S vobj(dbtbl1,99)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),99))
	 S vobj(dbtbl1,10)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),10))
	 S vobj(dbtbl1,102)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),102))
	;
	S vlvn=$P(vobj(dbtbl1,12),$C(124),1)
	I '($E(vlvn,$L(vlvn))="(") S vlvn=vlvn_"("
	S vgbl=$P(vobj(dbtbl1,100),$C(124),1)
	S vkeysx=$P(vobj(dbtbl1,16),$C(124),1)
	S vkeys=""
	F I=1:1:$L(vkeysx,",") D
	.	;
	.	N key
	.	;
	.	S key=$piece(vkeysx,",",I)
	.	;
	.	I '$$isLit^UCGM(key) S vkeys=vkeys_key_","
	.	Q 
	S vkeys=$E(vkeys,1,$L(vkeys)-1) ; No literals
	;
	S vpgm=$P(vobj(dbtbl1,99),$C(124),2) ; Filer
	S vreftld=$P(vobj(dbtbl1,100),$C(124),4)
	S vrefuid=$P(vobj(dbtbl1,100),$C(124),3)
	S vreftim=$P(vobj(dbtbl1,100),$C(124),8)
	S vsysnm=$P(vobj(dbtbl1,10),$C(124),2)
	;
	S vtp=$Tlevel ; Is TP already on?
	;
	I 'vtp Tstart *:transactionid="CS"
	;
	; If there's a filer, use it
	I '(vpgm="") D
	.	;
	.	I (%O=2) D  ; Integrity check
	..		;
	..		N vpgmx
	..		;
	..		S vpgmx="vlegacy^"_vpgm_"(%ProcessMode,$G(par))"
	..		;
	..		D @vpgmx
	..		Q 
	.	E  D
	..		;
	..		N obj
	..		N vpgmx N vobj
	..		;
	..		S obj=$$SN2OBJ^UCUTIL(fid) ; Convert to object format
	..		;
	..		S vpgmx="^"_vpgm_"(obj,$G(par))"
	..		;
	..		D @vpgmx ; Call filer
	..		Q 
	.	Q 
	E  D  ; No filer
	.	;
	.	N sn
	.	;
	.	; Skip CUVAR (vkeys.isNull()), but shouldn't be here anyway
	.	; since it has a filer
	.	I (%O<2),'(vkeys="") D  Q:ER 
	..		;
	..		N REQLIST N REQMISNG N vfsn
	..		;
	..		; Check require fields
	..		S REQLIST=$P(vobj(dbtbl1,102),$C(124),1)
	..		S REQMISNG=""
	..		;
	..		F I=1:1:$L(REQLIST,",") D
	...			;
	...			N COL N VAL
	...			;
	...			S COL=$piece(REQLIST,",",I)
	...			;
	...			; Get field value, either local or on disk
	...			S VAL=$$RETVAL^DBSDB(fid_"."_COL,,,,.vfsn)
	...			;
	...			I (VAL="") S REQMISNG=REQMISNG_COL_","
	...			Q 
	..		;
	..		S REQMISNG=$E(REQMISNG,1,$L(REQMISNG)-1)
	..		;
	..		I '(REQMISNG="") D  Q:ER 
	...			;
	...			S ER=1
	...			; Data Required
	...			S RM=$$^MSG(741)_", "_REQMISNG
	...			Q 
	..		;
	..		; Don't allow key updates
	..		I (%O>0) D  Q:ER 
	...			;
	...			F I=1:1:$L(vkeys,",") D  Q:ER 
	....				;
	....				N key
	....				;
	....				S key=$piece(vkeys,",",I)
	....				;
	....				I ($D(UX(fid,key))#2) D
	.....					;
	.....					S ER=1
	.....					; Cannot update access key ~p1
	.....					S RM=$$^MSG(8556,$piece(vkeys,",",I))
	.....					Q 
	....				Q 
	...			Q 
	..		Q 
	.	;
	.	; Check delete restriction
	.	E  I (%O=3) D  Q:ER 
	..		;
	..		S ER=1
	..		S RM="^DBSFILER is not valid for tables requiring cascade deletes.  Rewrite caller to PSL using save methods."
	..		Q 
	.	;
	.	S vuid=$get(%UID)
	.	I (vuid="") S vuid=$$USERNAM^%ZFUNC
	.	;
	.	S vtjd=$get(TJD)
	.	I (vtjd="") D
	..		;
	..		N cuvar S cuvar=$$vDb7()
	..		 S cuvar=$G(^CUVAR(2))
	..		;
	..		S vtjd=$P(cuvar,$C(124),1)
	..		Q 
	.	;
	.	; Use different values for DATA-QWIK
	.	I (vsysnm="DBS") D
	..		;
	..		S vuid=$$USERNAM^%ZFUNC
	..		S vtjd=$P($H,",",1)
	..		Q 
	.	;
	.	; Update date/time/user if required
	.	I '(vreftld="") D
	..		;
	..		D SETVAL^DBSDD(fid_"."_vreftld,vtjd)
	..		K UX(fid,vreftld)
	..		Q 
	.	I '(vreftim="") D
	..		;
	..		D SETVAL^DBSDD(fid_"."_vreftim,$P($H,",",2))
	..		K UX(fid,vreftim)
	..		Q 
	.	I '(vrefuid="") D
	..		;
	..		D SETVAL^DBSDD(fid_"."_vrefuid,vuid)
	..		K UX(fid,vrefuid)
	..		Q 
	.	;
	.	S ER=$$INDEX(fid,.RM) Q:ER  ; Update Indices
	.	;
	.	S sn=$piece(vlvn,"(",1)
	.	;
	.	S RM=$$FILE(%O,.dbtbl1,.@sn,vgbl,vkeys)
	.	;
	.	I '(RM="") S ER=1
	.	Q 
	;
	K:vtp vobj(+$G(dbtbl1)) Q:vtp  ; Let calling routine to manage TP
	;
	K vfkey ; Don't return if not under TP
	;
	I '$Tlevel S ER=1 K vobj(+$G(dbtbl1)) Q  ; TP restart error?
	;
	I ER Trollback:$Tlevel  K vobj(+$G(dbtbl1)) Q 
	;
	Tcommit:$Tlevel 
	;
	K vobj(+$G(dbtbl1)) Q 
	;
INDEX(fid,RM)	;
	N vpc
	;
	N ER S ER=0
	;
	N ds,vos1,vos2,vos3  N V1 S V1=fid S ds=$$vOpen1()
	;
	F  Q:'($$vFetch1())  D  Q:ER 
	.	;
	.	N add N del N isChangd
	.	N I
	.	N gbl N newkeys N oldkeys N ordby N ordval N vfsn
	.	;
	.	N dbtbl8,vop1 S vop1=$P(ds,$C(9),3),dbtbl8=$G(^DBTBL($P(ds,$C(9),1),8,$P(ds,$C(9),2),vop1))
	.	;
	.	S ordby=$P(dbtbl8,$C(124),3)
	.	S ordval=$piece(ordby,"=",2)
	.	S ordby=$piece(ordby,"=",1)
	.	;
	.	; If update and no change to index, don't continue
	.	I (%O=1) D  S vpc=('isChangd) Q:vpc 
	..		;
	..		S isChangd=0
	..		F I=1:1:$L(ordby,",") I ($D(UX(fid,$piece(ordby,",",I)))#2) S isChangd=1
	..		Q 
	.	;
	.	S gbl=$P(dbtbl8,$C(124),2)
	.	I (gbl="") D
	..		;
	..		S gbl="XDBREF"
	..		S ordby=""""_fid_"."_vop1_""","_ordby
	..		Q 
	.	;
	.	S gbl="^"_gbl_"("
	.	;
	.	S newkeys=ordby
	.	S oldkeys=ordby
	.	S (add,del)=1
	.	;
	.	F I=1:1:$L(ordby,",") D  Q:ER 
	..		;
	..		N key N nv N ov
	..		;
	..		S key=$piece(ordby,",",I)
	..		Q:(key="") 
	..		Q:$$isLit^UCGM(key) 
	..		Q:($E(key,1)="$") 
	..		;
	..		I ($E(key,1,2)="<<") D  Q 
	...			;
	...			S nv=$piece($piece(key,"<<",2),">>",1)
	...			S nv=$get(@nv)
	...			S $piece(newkeys,",",I)=nv
	...			S $piece(newkeys,",",I)=nv
	...			Q 
	..		;
	..		S nv=$$RETVAL^DBSDB(fid_"."_key,,,,.vfsn) Q:ER 
	..		;
	..		I ($D(UX(fid,key))#2) S ov=$piece(UX(fid,key),"|",1)
	..		E  S ov=nv
	..		;
	..		I $P(dbtbl8,$C(124),14) D
	...			;
	...			S nv=$$vStrUC(nv)
	...			S ov=$$vStrUC(ov)
	...			Q 
	..		;
	..		I (nv="") S add=0 ; Don't add this index
	..		I (ov="") S del=0 ; Don't delete this index
	..		;
	..		I add S $piece(newkeys,",",I)=""""_nv_""""
	..		I del S $piece(oldkeys,",",I)=""""_ov_""""
	..		Q 
	.	;
	.	I (ordval?1A.AN) S ordval=$$RETVAL^DBSDB(fid_"."_ordval,,,,.vfsn) Q:ER 
	.	E  I ($E(ordval,1,2)="<<"),($E(ordval,$L(ordval)-2+1,1048575)=">>") D
	..		;
	..		S ordval=$E(ordval,3,$L(ordval)-3)
	..		S ordval=$get(@ordval)
	..		Q 
	.	;
	.	; Set new index
	.	I add,(%O<3) D
	..		;
	..		N x
	..		;
	..		S x=gbl_newkeys_")"
	..		;
	..		S @x=ordval
	..		Q 
	.	;
	.	; Delete old index
	.	I del,(+%O'=+0) D
	..		;
	..		N x
	..		;
	..		S x=gbl_oldkeys_")"
	..		;
	..		;    #ACCEPT Date=10/31/05; Pgm=RussellDS; CR=17834
	..		K @x
	..		Q 
	.	Q 
	;
	Q ER
	;
FILE(%O,dbtbl1,sn,gbl,keys)	;
	 S:'$D(vobj(dbtbl1,100)) vobj(dbtbl1,100)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),100)),1:"")
	 S:'$D(vobj(dbtbl1,10)) vobj(dbtbl1,10)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),10)),1:"")
	;
	N del N rectyp
	N fid N RM
	;
	S RM=""
	;
	S fid=vobj(dbtbl1,-4)
	S rectyp=$P(vobj(dbtbl1,100),$C(124),2)
	;
	I $P(vobj(dbtbl1,100),$C(124),5) D ^DBSLOG(fid,%O,.UX) ; Update log file
	;
	; Process delete
	I (%O=3) D
	.	;
	.	N gblx
	.	;
	.	S gblx=gbl_")"
	.	;
	.	I (rectyp>1) D
	..		;
	..		;    #ACCEPT Date=10/31/05;Pgm=RussellDS;CR=17834
	..		K @gblx
	..		Q 
	.	E  ZWITHDRAW @gblx
	.	;
	.	Q 
	;
	E  D  ; GT.M database
	.	;
	.	N fnode N node
	.	;
	.	S del=$P(vobj(dbtbl1,10),$C(124),1)
	.	;
	.	I (rectyp=1) D  I '(RM="") Q RM
	..		;
	..		N zgbl
	..		;
	..		S zgbl=gbl_")"
	..		;
	..		I (%O=0),($D(@zgbl)#10) D
	...			;
	...			; Already on file
	...			S RM=$$^MSG(2327)
	...			Q 
	..		;
	..		E  I (%O=1),(($D(@zgbl)#10)=0) D
	...			;
	...			; Not on file
	...			S RM=$$^MSG(7932)
	...			Q 
	..		;
	..		E  I (del=124) S @zgbl=$$vStrTrim($get(sn),-1,"|")
	..		;
	..		E  S @zgbl=$get(sn)
	..		Q 
	.	;
	.	D  Q:'($D(fnode)#2)  ; Get list of nodes to deal with
	..		;
	..		N N
	..		;
	..		S N=""
	..		;
	..		I (%O=0) D
	...			;
	...			N N S N=""
	...			;
	...			I ($D(sn)#2) S fnode=""
	...			;
	...			F  S N=$order(sn(N)) Q:(N="")  S fnode(N)=""
	...			Q 
	..		;
	..		E  I ($D(sn)=1) S fnode="" ; No lower level
	..		;
	..		E  D
	...			;
	...			N N S N=""
	...			;
	...			F  S N=$order(UX(fid,N)) Q:(N="")  D
	....				;
	....				N PIECE
	....				N NODE
	....				;
	....				S NODE=$piece(UX(fid,N),"|",3)
	....				S PIECE=$piece(UX(fid,N),"|",4)
	....				;
	....				Q:(PIECE="*")  ; Access key
	....				;
	....				I (NODE=""),(PIECE="") S NODE=$$NOD^DBSDD(fid_"."_N)
	....				;
	....				I NODE=$piece(keys,"|",$L(keys,",")) S NODE=""
	....				;
	....				I '((NODE="")!(NODE=" ")) S fnode(NODE)=""
	....				Q 
	...			Q 
	..		Q 
	.	;
	.	I (+(rectyp#10)'=+0),(+($D(fnode)#2)'=+0) D
	..		;
	..		N gblx N z
	..		;
	..		I (del=124) S z=$$vStrTrim($get(sn),-1,"|")
	..		E  S z=sn
	..		;
	..		S gblx=gbl_")"
	..		;
	..		S @gblx=z
	..		Q 
	.	;
	.	Q:rectyp=1  ; Unsegmented
	.	Q:($D(fnode)<10)  ; No lower levels
	.	;
	.	S node=""
	.	;
	.	; Global without access keys, e.g, CUVAR
	.	I ($piece(gbl,"(",2)="") S gbl=gbl_"node)"
	.	E  S gbl=gbl_",node)"
	.	;
	.	F  S node=$order(fnode(node)) Q:(node="")  D
	..		;
	..		N z
	..		;
	..		I (del=124) S @z=$$vStrTrim(sn(node),-1,"|")
	..		E  S z=sn(node)
	..		;
	..		I (z="") ZWITHDRAW @gbl
	..		E  S @gbl=z
	..		Q 
	.	Q 
	;
	Q RM
	;
VDDUX(fid,vx)	;
	N vpc
	;
	N col N delim N vRM
	;
	N tblrec S tblrec=$$getSchTbl^UCXDD(fid)
	;
	S delim=$char($P(tblrec,"|",10))
	;
	S (col,vRM)=""
	;
	F  S col=$order(vx(col)) Q:(col="")  D  Q:'(vRM="") 
	.	;
	.	N max N min N tbl N typ N X
	.	;
	.	N dbtbl1d,vop1 S vop1=col,dbtbl1d=$$vDb8("SYSDEV",fid,col)
	.	;
	.	S vpc=(($P(dbtbl1d,$C(124),1)?1N1"*")) Q:vpc  ; No need to check keys
	.	;
	.	S tbl=$P(dbtbl1d,$C(124),5)
	.	;
	.	I '(tbl="") D  ; Table look-up
	..		;
	..		N I N keycnt
	..		N acckeys N tblfid
	..		;
	..		; No validation
	..		I ($E(tbl,1)="@") S tbl="" Q 
	..		;
	..		; No validation
	..		I (tbl[":NOVAL") S tbl="" Q 
	..		;
	..		; Not table reference
	..		I (tbl'?1"{".E1"]".E) S tbl="" Q 
	..		;
	..		; Check for too many keys
	..		S tblfid=$piece($piece(tbl,"[",2),"]",1)
	..		;
	..		N dbtbl1,vop2,vop3,vop4,vop5 S vop2="SYSDEV",vop3=tblfid,dbtbl1=$$vDb9("SYSDEV",tblfid,.vop4)
	..		 S vop5=$G(^DBTBL(vop2,1,vop3,16))
	..		;
	..		; Not valid table
	..		I ($G(vop4)=0) S tbl="" Q 
	..		;
	..		S acckeys=$P(vop5,$C(124),1)
	..		S keycnt=0
	..		F I=1:1:$L(acckeys,",") I '$$isLit^UCGM($piece(acckeys,",",I)) S keycnt=keycnt+1
	..		;
	..		; Too many keys
	..		I (+keycnt'=+1) S tbl=""
	..		Q 
	.	;
	.	S typ=$P(dbtbl1d,$C(124),9)
	.	S min=$P(dbtbl1d,$C(124),12)
	.	I '(min="") S min=$$valuea(min,typ)
	.	S max=$P(dbtbl1d,$C(124),13)
	.	I '(max="") S max=$$valuea(max,typ)
	.	;
	.	; Get current value - needed by VAL^DBSVER
	.	S X=$piece(vx(col),delim,2)
	.	;
	.	S vRM=$$VAL^DBSVER(typ,+$P(dbtbl1d,$C(124),2),+$P(dbtbl1d,$C(124),15),tbl,$P(dbtbl1d,$C(124),6),min,max,+$P(dbtbl1d,$C(124),14),,"["_fid_"]"_col,0)
	.	;
	.	I '(vRM="") S vRM=fid_"."_vop1_" "_vRM
	.	Q 
	;
	I '(vRM="") S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	;
	Q 
	;
valuea(v,typ)	;
	;
	S v=$$value(v,typ)
	I ((v?1A.AN)!(v?1"%".AN)) S v="<<"_v_">>" ; <<variable>>
	;
	Q v
	;
value(v,typ)	;
	;
	N RETURN
	;
	I (v="") S RETURN=""
	E   N V1 S V1=v I ($D(^STBL("JRNFUNC",V1))#2) D  ; System keyword
	.	;
	.	N jrnfunc S jrnfunc=$$vDb10(v)
	.	;
	.	S RETURN=$P(jrnfunc,$C(124),2)
	.	Q 
	E  I (v=+v) S RETURN=v
	E  I ($E(v,1,2)="<<"),($E(v,$L(v)-2+1,1048575)=">>") S RETURN=$piece($piece(v,"<<",2),">>",1) ; <<Variable>>
	;
	E  I (typ="D") D
	.	;
	.	I (v="T") S RETURN="TJD" ; System Date
	.	E  I (v="C") S RETURN="+$H" ; Calendar Date
	.	E  S RETURN=""
	.	Q 
	E  I (typ="C") D
	.	;
	.	I (v="C") S RETURN="$P($H,"","",2)" ; Current time
	.	E  S RETURN=""
	.	Q 
	E  I (typ="L") D  ; Logical
	.	;
	.	I (v="Y") S RETURN=1
	.	E  S RETURN=0
	.	Q 
	E  I (v="""") S RETURN="""""""""" ; String delimiter
	E  S RETURN=""""_v_"""" ; Text
	;
	Q RETURN
	;
tbl(tbl)	; [table] reference
	;
	Q ""
	;
vSIG()	;
	Q "60877^68877^Dan Russell^15496" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
	; ----------------
	;  #OPTION ResultClass 0
vStrTrim(object,p1,p2)	; String.trim
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I p1'<0 S object=$$RTCHR^%ZFUNC(object,p2)
	I p1'>0 F  Q:$E(object,1)'=p2  S object=$E(object,2,1048575)
	Q object
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(DBTBL1,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL1"
	S vobj(vOid)=$G(^DBTBL(v1,1,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,1,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDb10(v1)	;	voXN = Db.getRecord(STBLJRNFUNC,,0)
	;
	N jrnfunc
	S jrnfunc=$G(^STBL("JRNFUNC",v1))
	I jrnfunc="",'$D(^STBL("JRNFUNC",v1))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,STBLJRNFUNC" X $ZT
	Q jrnfunc
	;
vDb7()	;	voXN = Db.getRecord(CUVAR,,0)
	;
	I '$D(^CUVAR)
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,CUVAR" X $ZT
	Q ""
	;
vDb8(v1,v2,v3)	;	voXN = Db.getRecord(DBTBL1D,,0)
	;
	N dbtbl1d
	S dbtbl1d=$G(^DBTBL(v1,1,v2,9,v3))
	I dbtbl1d="",'$D(^DBTBL(v1,1,v2,9,v3))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1D" X $ZT
	Q dbtbl1d
	;
vDb9(v1,v2,v2out)	;	voXN = Db.getRecord(DBTBL1,,1,-2)
	;
	N dbtbl1
	S dbtbl1=$G(^DBTBL(v1,1,v2))
	I dbtbl1="",'$D(^DBTBL(v1,1,v2))
	S v2out='$T
	;
	Q dbtbl1
	;
vOpen1()	;	%LIBS,FID,INDEXNM FROM DBTBL8 WHERE %LIBS='SYSDEV' AND FID=:V1
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(V1) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^DBTBL("SYSDEV",8,vos2,vos3),1) I vos3="" G vL1a0
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
	S ds="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
