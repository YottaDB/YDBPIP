SQLO(frm,sel,oby,all,vsql,rng,par,tok,fsn,vdd)	;;;SQL - V5.0 -  Optimize Database Access
	;;Copyright(c)1999 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/26/99 08:35:33 - CHIANG
	;     ORIG:  Frank R. Sanchez (2497) - 07/03/93
	;     DESC: This routine searches available indices for the files
	;	    contained in the frm parameter and determines the
	;	    optimal access method.
	;
	;    INPUT:
	;	.frm	File list			/TBL=DBTBL1/REQ
	;	.sel	Select List			/TBL=DBTBL1/REQ
	;	.oby	Orderby		 		/MECH=REF:RW/REQ
	;	.all	all(1)/distinct(0) 		/MECH=REF:RW/REQ
	;	.vsql	Return data section		/MECH=REF:RW/REQ
	;	.rng	Range Array			/MECH=REF:RW/REQ
	;		rng(dinam)=Datatype
	;		rng(dinam,oprelat)=Value
	;	.par	Parameters			/MECH=REFNAM:R
	;		INDEX=index Name		
	;		PLAN				/DEF=0
	;	.fsn	File Header Array		/MECH=REF:RW/NOREQ
	;	.vdd	Dictionary Buffer
	;
	;  RETURNS:
	;	.vsql("G")=Access_File[,...]
	;	.vsql("G",n)=gblref
	;	.vsql("C")="||"_dist_"|"_ixcost_"|"_ixref_"|"_joincost
	;
	;	eg:  >S rng("SYSDEV.DEP.CLS","=")="""D"""
	;	     >S rng("SYSDEV.DEP.GRP","=")="""DDA"""
	;	     >S oby="SYSDEV.DEP.CID"
	;
	;D ^SQLO("CIF,DEP",.oby,.rng,.vsql,.fsn)
	;
	;vsql("C")="||1*1*12*1000|12000|XCLS|1"
	;vsql("G")="DEP,CIF"
	;vsql("G",1)="^XCLS($C(1)_"SYSDEV.DEP.CLS"_$C(1),$C(1)_"SYSDEV.DEP.GRP
	;"_$C(1),$C(1)_"SYSDEV.DEP.TYPE"_$C(1),$C(1)_"SYSDEV.DEP.CID"_$C(1)
	;vsql("G",2)="^CIF($C(1)_"SYSDEV.CIF.ACN"_$C(1)
	;
	; I18N=QUIT: Exculded from I18N standards. 
	;----------------------------------------------------------------------
	;---------- Revision History ------------------------------------------
	; 07/10/07 - Pete Chenard - CR28171
	;	     Replaced references to $C(255) with $$BYTECHAR^SQLUTL
	;	     for unicode compliance.
	;
	; 05/09/07 - GIRIDHARANB - 26847
	;	     Modified section INDEX to include null information 
	;	     in the index arry.
	;
	; 02/24/03 - Pete Chenard - 8571
	;	     Modified RETRY section to not try to reprocess an index
	;	     if it's already included in the access plan.
	;
	; 11/04/03 - Pete Chenard - CR6917
	;            Modified indxqry section to not consider indexes
	;            have have the Null flag turned off.
	;            Corrects a problem where the an index with the Null
	;            flag turned off was chosen for a Select statement
	;            but it did not return all expected rows in the result
	;            set.
	; 10/26/99 - Chiang - 35540
	;            Modified to protect variable 'i' at sections JOINCOST,
	;            OPTIMIZE, DISTINCT, and DISTINI.
	;
	; 09/28/99 - Frank Sanchez - 35105
	;            Major redesign to eliminate ^DBINDX and prevent 
	;	     overpruning on indices with keys matching views.
	;	    
	; 08/12/97 - Betty Ni - 25653
	;            Replaced follows operator "]" with a "]]". 
	;
	; 06/10/97 - Chiang - 24835
	;            Modified OPTIMIZE section to not use partial index files
	;            to optimize DISTINCT statement.
	;----------------------------------------------------------------------
	;
	S ER=0
	;   
	I $D(oby)#2=0 S oby=""
	;
	N alias,buf,cost,dindxs,dse,fnum
	N gblexpr,index,lowcost,mincost,plan,winner
	;
	S dse=""
	;
	I $G(all)="" S all=1
	E  I all=0 D DISTINI Q:ER 
	;
	S mincost=$S(mode=1:10,1:1)
	S plan=$G(par("PLAN"))
	;
	I $G(par("OPTIMIZE"))=0 S par("INDEX")=frm
	I $G(par("INDEX"))'="" D EXTERNAL Q		; User supplied
	;
	I frm'["," D  Q
	.	;
	.	S winner=$$OPTIMIZE(frm,.fsn,.index,plan) I ER Q
	.	S vsql("I")=frm
	.	S vsql("I",frm)=index(winner)
	.	I 'all S all=$P(index(winner),"|",6)
	.	I plan D PLAN(.index,.vsql)
	;
	F fnum=1:1:$L(frm,",") D  Q:ER			; Check each file
	.	;
	.	S alias=$P(frm,",",fnum)
	.	S winner(alias)=$$OPTIMIZE(alias,.fsn,.index,plan) I ER Q
	;
JOIN	;
	S alias=$P(frm,",",1),winner=alias
	S lowcost=$$FRMCOST(.rng,.index,.whr,.winner,.fsn,alias,frm)
	;
	F fnum=2:1:$L(frm,",") D
	.	;
	.	S alias=$P(frm,",",fnum)
	.	S cost=$$FRMCOST(.rng,.index,.whr,.winner,.fsn,alias,frm)
	.	I cost="" Q
	.	I cost<lowcost!(lowcost="") S lowcost=cost,winner=alias
	;
	; 2-Way Outer Joins Are not Supported
	I lowcost="" S ER=1,RM=$$^MSG(8612) Q
	;
	I 'all S all=$P(index(winner(winner)),"|",6)
	;
	F I=1:1:$L(plan(winner),",") D  Q:ER
	.	;
	.	S index=$P(plan(winner),",",I),alias=$P(index,".",1)
	.	I I=1 S vsql("I")=alias
	.	E  S vsql("I")=vsql("I")_","_alias
	.	S vsql("I",alias)=index(index)
	.	I index[".." D DYNDXS(alias)
	;
	I plan D PLAN(.index,.vsql)
	Q
	;
	;----------------------------------------------------------------------
FRMCOST(rng,index,whr,winner,fsn,tbl1,frm)	; Total join cost using tbl1
	;----------------------------------------------------------------------
	;
	N cost,dist,fnum,jcost,keys,retry,tbl2,tcost
	;
	S index=winner(tbl1)
	;
	S dist=$P(index(index),"|",3)
	S keys=$P(fsn(tbl1),"|",3)
	S plan(tbl1)=index
	;
	S retry=""
	S cost=$$IXCOST(dist),tcost=cost
	;
	F fnum=1:1:$L(frm,",") D
	.	;
	.	S tbl2=$P(frm,",",fnum) I tbl2=tbl1 Q
	.	;
	.	S jcost=$$JOINCOST(tbl1,tbl2,keys,dist,cost,.index,.rng,.fsn,.join,.retry)
	.	I jcost="" S tcost="",fnum=9999 Q	; Join error
	.	S tcost=tcost+jcost
	;
	I tcost="" Q tcost
	;
	I retry'="" S tcost=tcost+$$RETRY(tbl1,retry)+1		; Fix later with distribution
	I oby'="" S keys=$P(index(index),"|",2),tcost=$$ORDERBY(tbl1,keys,oby,tcost)
	;
	;W !!,tbl1,"  ",tcost
	Q tcost
	;
	;----------------------------------------------------------------------
JOINCOST(tbl1,tbl2,pkeys,pdist,pcost,index,rng,fsn,join,retry)	; Return cost of joining tbl2 to tbl1
	;----------------------------------------------------------------------
	;
	N cost,i,jcost,jdist,jkeys,jindex,jprmry,record
	;
	S jprmry=tbl2_".*",record=index(jprmry)
	S jkeys=$P(record,"|",2),jdist=$P(record,"|",3)
	;
	I $G(join(tbl1))=tbl2,$$OUTER(tbl1,tbl2,.join,jkeys) Q ""
	I $G(join(tbl2))'="",join(tbl2)'=tbl1 S retry=$$ADDVAL(.retry,tbl2) Q -1
	;
	S jindex=winner(tbl2)
	;
	I jindex'=jprmry D
	.	;
	.	N i,ikeys,key
	.	S ikeys=$P(index(jindex),"|",2)
	.	F i=1:1:$L(ikeys,",") S key=$P(ikeys,",",i) I '$D(rng(tbl2_"."_key,"=")),'$$CONTAIN(jkeys,key) Q
	.	I  S jindex=jprmry
	.	E  S jkeys=ikeys
	;
	S jcost=$$IXCOST($P(index(jindex),"|",3))
	;
	I jcost=1,$G(join(tbl2))="" S plan(tbl1)=$$ADDVAL(jindex,plan(tbl1)) Q pcost
	;
	S cost=$$JIDXCOST(tbl1,tbl2,pkeys,jkeys,pdist,jdist)
	;
	I cost<0 D  Q cost				; Incomplete Join
	.	;
	.	S cost=jcost
	.	I pcost=1 S plan(tbl1)=$$ADDVAL(plan(tbl1),jindex) Q
	.	I $L(frm,",")>2 S retry=$$ADDVAL(.retry,tbl2),cost=0 Q
	.	;
	.	I '$$ISJOIN(tbl1,tbl2) D  Q		; Cartesian Product
	..		;
	..		S plan(tbl1)=$$ADDVAL(plan(tbl1),jindex)
	..		S cost=cost*pcost
	.	;
	.	S cost=3*cost				; Read/Write/Read
	.	S z=index(jindex),jindex=tbl2_"..",index(jindex)=z
	.	S plan(tbl1)=$$ADDVAL(plan(tbl1),jindex)
	;
	I $E(pkeys,1,$L(jkeys))=jkeys D			; Common Structure
	.	;
	.	I $G(join(tbl2))=tbl1,$$OUTER(tbl2,tbl1,.join,pkeys) Q
	.	;
	.	N ratio1,ratio2
	.	S ratio1=$P(index(tbl1_".*"),"|",4)/pcost
	.	S ratio2=$P(index(tbl2_".*"),"|",4)/jcost
	.	I ratio2>ratio1 D
	..		;
	..		S cost=jcost+$$IXCOST($P(pdist,"*",$L(jdist,"*")+1,999))
	..		S jindex=$$ADDVAL(jindex,plan(tbl1))
	..		S plan(tbl1)=""
	;
	I cost>1,jindex'=jprmry,jcost>$P(record,"|",4) S jindex=jprmry ;,jcost=$$IXCOST(jdist)
	S plan(tbl1)=$$ADDVAL(plan(tbl1),jindex)
	Q cost
	;
	;----------------------------------------------------------------------
JIDXCOST(tbl1,tbl2,pkeys,jkeys,pdist,jdist)	; # IO's in tbl2 per record in tbl1 
	;----------------------------------------------------------------------
	;
	N ddref,keynum,ok,I,J
	;
	S ok=1
	S keynum=$L(jkeys,",")
	;
	F I=1:1:keynum D  Q:'ok
	.	;
	.	S ddref=tbl2_"."_$P(jkeys,",",I)
	.	I $D(rng(ddref,"=")) Q			; Constant
	.	I '(","_$G(join(ddref))[(","_tbl1_".")) S ok=0
	;
	I ok Q 1					; one IO per primary
	;
	S keynum=$L(pkeys,","),ok=1
	;
	F J=1:1:keynum D  Q:'ok
	.	;
	.	S ddref=tbl1_"."_$P(jkeys,",",J)
	.	I $D(rng(ddref,"=")) Q			; Constant
	.	I '(","_$G(join(ddref))[(","_tbl2_".")) S ok=0
	;
	I ok=0 Q -1
	;
	F J=1:1:I-1 S jdist=$$PRUNE(jdist,$p(pdist,"*",J),J)
	Q $$IXCOST(jdist)
	;
	;----------------------------------------------------------------------
RETRY(frm,retry)	; See if tbl1 --> tbl3 --> tbl2 join can be done
	;----------------------------------------------------------------------
	;
	N ddref,jcost,jindex,jcost,jkeys,keynum,ok,tbl2,tbl3,tcost,I,J,K
	;
	S tcost=1
	;
	F I=1:1:$L(retry,",") S tbl2=$P(retry,",",I) Q:tbl2=""  D
	.	;
	.	S jindex=winner(tbl2)
	.	I (","_plan(tbl1)_",")[(","_jindex_",") Q   ;already in plan
	.	S jkeys=$P(index(jindex),"|",2)
	.	S jcost=$$IXCOST($P(index(jindex),"|",3))
	.	;
	.	S keynum=$L(jkeys,",")
	.	;
	.	S ok=1
	.	F J=1:1:keynum D  Q:'ok
	..		;
	..		S ddref=tbl2_"."_$P(jkeys,",",J)
	..		I $D(rng(ddref,"=")) Q			; Constant
	..		;
	..		F K=1:1:$L(plan(tbl1),",") S tbl3=$P($P(plan(tbl1),",",K),".",1) I (","_$G(join(ddref))[(","_tbl3_".")) Q
	..		E  S ok=0
	.	;
	.	I ok S tcost=tcost+1,retry=$$SUBVAL^SQLM(retry,tbl2),I=0
	.	E  S tcost=tcost*jcost
	.	;
	.	S plan(tbl1)=$$ADDVAL(plan(tbl1),winner(tbl2))
	;
	Q tcost
	;
	;----------------------------------------------------------------------
OPTIMIZE(alias,fsn,index,plan)	; Find optimal access path for file
	;----------------------------------------------------------------------
	;
	S ER=0
	;
	N file,alli,buf,cost,defined,dinam,dist,gvn,i,ixref,keylvl,keylvl
	N keys,ixcost,lib,null,numkeys,dist,pkeys,sok,sort,vals,vptr,z,zddref
	;
	S z=fsn(alias),gvn=$P(z,"|",2),pkeys=$P(z,"|",3),lib=$P(z,"|",11)
	S file=alias
	;
	I pkeys="" S index(alias_".*")=gvn_"|"_pkeys_"|1|1||1" Q alias_".*"
	;
	S vptr=$G(join(0,alias))			; View Pointer
	;
	S zddref=alias_"."
	S numkeys=$L(pkeys,",")
	;
	F keylvl=1:1:numkeys I '$D(rng(zddref_$P(pkeys,",",keylvl),"=")) Q
	E  S index(alias_".*")=gvn_"|"_pkeys_"|1|1||1" Q alias_".*"
	;
	S index="*",ixref=alias_"."_index,null=1
	;
	set dist=$$dist(numkeys)
	;
	for i=1:1:numkeys-1 do			; Check for foreign keys
	.	;
	.	set dinam=$P(pkeys,",",i)
	.	if $D(^DBTBL(%LIBS,19,file,dinam)) set $P(dist,"*",i)=1E6
	.	else  if vptr set $P(dist,"*",i)=$P(dist,"*",i)*2
	;
	if vptr set $P(dist,"*",numkeys)=$P(dist,"*",numkeys)*2
	;
	F i=1:1:numkeys D
	.	;
	.	S dinam=zddref_$P(pkeys,",",i)
	.	D KEYCOST(dinam,.rng,.dist,i,vptr)
	;
	S ixcost=$$IXCOST(dist),alli=all
	;
	I dse'="" S alli=$$DISTINCT(pkeys)
	I oby'="" S ixcost=$$ORDERBY(alias,pkeys,oby,ixcost)
	;
	S index(ixref)=gvn_"|"_pkeys_"|"_dist_"|"_ixcost_"|*|"_alli
	;
	I ixcost<mincost Q ixref
	I oby="",'$D(rng),dse="" Q ixref
	;
	S lowcost=ixcost,winner=ixref			; Start with primary
	;
	S index=""
	F  S index=$O(^DBTBL(lib,8,file,index)) Q:index=""  D  I mincost=0,plan=0 Q
	.	;                                       ; DISTINCT can't use
Z	.	I 'all,'^(index) Q  			; partial index file
	.	S ixcost=$$INDEX(alias,file,.index,.rng,plan,vptr)
	.	I ixcost<0 Q				; Don't consider
	.	I ixcost<mincost S mincost=0
	;
	Q winner
	;
	;----------------------------------------------------------------------
ACKEYS(file,index,fsn)	; Returns access keys list
	;----------------------------------------------------------------------
	; 
	N I,gblexpr,gblkeys,j,key,z,zddref
	;
	S gblexpr=$P(index(file),"|",1),file=$P(file,".",1)
	S zddref=file_"."
	;
	S gblkeys=$P(gblexpr,"(",2,999)
	S gblexpr=$P(gblexpr,"(",1)_"("
	;
	I gblkeys="" S gblexpr=$P(gblexpr,"(",1)
	;
	E  F I=1:1:$L(gblkeys,",") D
	.	;
	.	I I>1 S gblexpr=gblexpr_","
	.	;
	.	S key=$P(gblkeys,",",I)
	.	I key=+key!("""$"[$E(key))!(key="%TOKEN")!(key="sqlcur")!(key["vsql(") S gblexpr=gblexpr_key Q
	.	I $L(gblkeys,"""")#2=0 S gblexpr=gblexpr_key Q
	.	;
	.	S key=zddref_key
	.	;
	.	S gblexpr=gblexpr_$C(1)_key_$C(1)
	;
	Q gblexpr
	;
	;----------------------------------------------------------------------
LODINDX	;private; Load an Index, called by INDEX
	;----------------------------------------------------------------------
	;
	N bk,pdist,qry,i,z
	;
	set z=$G(^DBTBL(lib,8,file,index))
	;
	set null=$P(z,"|",1),gvn=$P(z,"|",2),keys=$P(z,"|",3),sok=$P(z,"|",11)
	set qry=$P(z,"|",7,8)
	;
	;
	I gvn="" S gvn="XDBREF",keys=""""_file_"."_index_""","_keys
	S gvn="^"_gvn_"("_keys
	;
	S z=keys,keys="",numkeys=0
	;
	for i=1:1:$L(z,",") do
	.	;
	.	set key=$P(z,",",i)
	.	I key=+key!("""$"[$E(key)) Q
	.	S numkeys=numkeys+1
	.	S $P(keys,",",numkeys)=key
	;
	set dist=$$dist(numkeys)
	;
	; For inverted indices, if a key is the same as a primary table key,
	; poke in the number of primary keys at that level
	;
	set bk=$P(pkeys,",",$L(pkeys,",")),pdist=$$dist($L(pkeys,","))
	;
	for i=1:1:numkeys-1 if $P(keys,",",i)=bk set $P(dist,"*",i)=$P(pdist,"*",$L(pdist,"*"))
	;
	; If the index has a query, use it if it matches a where condition
	;
	I $TR(qry,"|")'="" do indxqry(qry,file,.whr,.rng,.dist)
	quit
	;
	;----------------------------------------------------------------------
indxqry(qry,file,whr,rng,dist)	;private; There's a query on the index, see if it can be used
	;----------------------------------------------------------------------
	;
	new exe,exprlft,exprght,oprelat,irng,iwhr,join,vsql,ER,z,i
	;
	set ER=0
	;
	if 'null set dist="" quit
	;
	set qry=$P(qry,"|",1)_$S($P(qry,"|",2)="":"",1:" AND "_$P(qry,"|",2))
	;
	set qry=$$WHERE^SQLCONV(qry,file) if ER set dist="" quit
	do ^SQLQ(qry,file,.iwhr,.irng,1,"",.fsn,.vdd,0)
	if $G(irng)'=1!$D(exe)!ER set dist="" quit
	;
	set z=$G(iwhr(1))
	set exprlft=$P(z,$C(9),1),exprght=$P(z,$C(9),2),oprelat=$P(z,$C(9),3)
	;
	if $L(exprlft,$C(1))'=3 set dist="" quit	; Compound subject
	set exprlft=$P(exprlft,$C(1),2)
	;
	; For now, 'cause it's easy -- allow exact match on operator only
	if '$D(rng(exprlft,oprelat)) set dist="" quit	; No match
	if $P(whr(rng(exprlft,oprelat)),$C(9),2)'=exprght set dist="" quit
	;
	; Made it !!!  Cut this index in half
	;
	for i=1:1:$L(dist,"*") set $P(dist,"*",i)=$P(dist,"*",i)*.5
	set null=1					; Has to be true
	Q
	;
	;----------------------------------------------------------------------
KEYCOST(dinam,rng,dist,keylvl,vptr,vpoke)	;	Return the cost of this key
	;----------------------------------------------------------------------
	;
	;I index["NAME" b
	new oprelat,cntkeys
	;
	set oprelat=""
	set cntkeys=$P(dist,"*",keylvl)
	;
	for  set oprelat=$O(rng(dinam,oprelat)) quit:oprelat=""  do  quit:cntkeys=1
	.	;
	.	if rng(dinam,oprelat)=vptr set vpoke=keylvl quit
	.	;
	.	if oprelat="=" set cntkeys=$S(keylvl=1:1,1:$P(dist,"*",keylvl-1)) quit
	.	;
	.	if oprelat="J" quit
	.	if oprelat="E" quit
	.	;
	.	new factor
	.	if oprelat="<"!(oprelat="'>") set factor=.7
	.	else  if oprelat=">"!(oprelat="'<") set factor=.7
	.	else  if oprelat="I" set factor=.2
	.	else  if oprelat="'=" set factor=.9
	.	else  if oprelat="'I" set factor=.9
	.	else  set factor=$P($P("?.4,'?.6,[.4,'[.6",oprelat,2),",",1)
	.	;
	.	set cntkeys=cntkeys*factor
	.	if '(cntkeys>1) set cntkeys=2
	;
	set dist=$$PRUNE(dist,cntkeys,keylvl)
	quit
	;
	;----------------------------------------------------------------------
PRUNE(dist,numkeys,keylvl)	; Prune key distribution
	;----------------------------------------------------------------------
	;
	I 'numkeys s numkeys=1
	;
	N curval,factor,i,z
	S curval=$P(dist,"*",keylvl)
	;
	I '(curval>numkeys) Q dist				; No change
	;
	set factor=numkeys/curval
	for i=keylvl:1:$L(dist,"*") set $P(dist,"*",i)=$J($P(dist,"*",i)*factor+.49,0,0)
	;
	quit dist
	;
	;----------------------------------------------------------------------
IXCOST(dist)	; Return Current Index Cost
	;----------------------------------------------------------------------
	;
	I dist'["*" Q dist
	;
	N i,return
	S return=$P(dist,"*",1)
	F i=2:1:$L(dist,"*") S return=return+$P(dist,"*",i)
	Q return
	;
	;----------------------------------------------------------------------
INDEX(alias,file,index,rng,plan,vptr)	; Load the index definitions for file
	;----------------------------------------------------------------------
	;
	N alli,consider,dist,gvn,i,ixcost,ixref,key,keys,null,vpoke
	;
	S ixref=alias_"."_index
	;
	do LODINDX if dist="" quit -5
	;
	S consider="",ixcost=0,vpoke=0,alli=all
	;
	F keylvl=1:1:$L(keys,",") D  I plan=0,consider<0 Q
	.	;
	.	set key=$P(keys,",",keylvl),dinam=alias_"."_key
	.	;
	.	I 'null Q:consider<0  D  Q:consider<0
	..		;
	..		I $D(rng(dinam,"=")) S consider=$S($$VALUE(.dinam,"=")="""""":-2,1:1) Q
	..		I $D(rng(dinam,"'=")) S consider=$S($$VALUE(.dinam,"'=")="""""":2,1:-2) Q
	..		I $D(rng(dinam,">")) S consider=1 Q
	..		I $D(rng(dinam,"'<")) S consider=1 Q
	..		I $D(rng(dinam,"I")) S consider=1 Q
	..		I $D(rng(dinam,"[")) S consider=1 Q
	..		S consider=$S($$CONTAIN(pkeys,key):1,1:-3) Q
	.	;
	.	D KEYCOST(dinam,.rng,.dist,.keylvl,vptr,.vpoke)
	.	if vpoke set $P(dist,"*",vpoke)=$S(vpoke=1:1,1:$P(dist,"*",vpoke-1))
	;
	if consider<0 quit consider
	;
	S ixcost=$$IXCOST(dist)
	;
	I dse'="" S alli=$$DISTINCT(keys)
	I oby'="" S ixcost=$$ORDERBY(file,keys,oby,ixcost)
	;
	; Null means that it contains pointers to all records, including null.
	; 
	S index(ixref)=gvn_"|"_keys_"|"_dist_"|"_ixcost_"|"_consider_"|"_alli_"|"_sok_"|"_null
	;
	I ixcost'<lowcost Q ixcost
	;
	I consider<0 Q consider
	I consider="",'null Q -2			; No matching range
	;
	S lowcost=ixcost,winner=ixref
	Q ixcost
	;
	;----------------------------------------------------------------------
DISTINCT(keys)	; Check keys for distinct optimization
	;----------------------------------------------------------------------
	;
	N i
	F i=1:1:$L(dse,",") D  Q:'consider
	.	;
	.	S exprcol=$P(dse,",",i)
	.	I $P(exprcol,".",1)'=alias S consider=0 Q
	.	S consider=$$CONTAIN(keys,$P(exprcol,".",2))
	;
	I 'consider S ixcost=ixcost*2 Q 0
	;
	F i=$L(keys,","):-1:1 Q:$$CONTAIN(dse,alias_"."_$P(keys,",",i))
	I i<$L(keys,",") D
	. 	;
	.	S gvn=$P(gvn,(","_$P(keys,",",i+1)),1)
	.	S dist=$P(dist,"*",1,i),ixcost=$$IXCOST(dist)
	.	S keys=$P(keys,",",1,i)
	;
	S alli=1 F i=1:1:$L(keys,",") D  Q:'alli
	.	;
	.	I $P(dist,"*",i)=1 Q			; 1 value
	.	I $$CONTAIN(dse,alias_"."_$P(keys,",",i)) Q
	.	S alli=0				; Not unique
	;
	I alli=0 S ixcost=ixcost*1.5
	Q alli
	;
	;----------------------------------------------------------------------
DISTINI	; Initialize SELECT expression for distinct
	;----------------------------------------------------------------------
	;
	N i
	S all=1
	;
	I "*"[sel Q
	;
	N alias,exprcol,i,keys
	;
	F i=1:1:$L(sel,",") D  Q:ER
	.	;
	.	S exprcol=$P(sel,",",i)
	.	I exprcol[$C(0) S exprcol=$$UNTOK^%ZS(exprcol,.tok)
	.	S exprcol=$$CVTREF^SQLDD(exprcol,frm,.fsn,.vdd) I ER Q
	.	S $P(sel,",",i)=exprcol
	;
	I ER Q
	;
	; If all of the primary file keys are in the select clause, each
	; record must already be distinct.  No need then to sort.
	;
	S alias=$P(frm,",",1)
	S keys=$P(fsn(alias),"|",3)
	F j=1:1:$L(keys,",") D  Q:all=0
	.	;
	.	S z=alias_"."_$P(keys,",",j)
	.	I '$D(rng(z,"=")),'$$CONTAIN(sel,z) S all=0
	;
	I all Q
	;
	S dse=sel,i=0
	;
	F  S i=$O(whr(i)) Q:i=""  D
	.	;
	.	S z=$P($P(whr(i),$C(9),1),$C(1),2)
	.	I '$$CONTAIN(dse,z) S dse=dse_","_z ;sel=sel_","_z
	Q
	;
	;----------------------------------------------------------------------
ORDERBY(file,keys,oby,cost)	; Check orderby for access optimization
	;----------------------------------------------------------------------
	;
	N dinam,key,zdinam
	;
	S zdinam=file_"."
	;
	F I=1:1:$L(oby,",") D
	.	;
	.	S dinam=$P($P(oby,",",I)," ",1)
	.	I $D(rng(dinam,"=")) Q			; Only one entry
	.	;
	.	S key=zdinam_$P(keys,",",1),keys=$P(keys,",",2,999)
	.	I $D(rng(key,"=")) S I=I-1 Q		; Only one entry
	.	;
	.	I dinam=key Q
	.	S cost=cost*2+1				; Add sort Penalty
	.	S I=$L(oby,",")+1			; STOP
	;
	Q cost
	;
	;----------------------------------------------------------------------
CONTAIN(A,B)	; Returns A contains B
	;----------------------------------------------------------------------
	;
	Q (","_A_",")[(","_B_",")
	;
	;
	;----------------------------------------------------------------------
ISJOIN(tbl1,tbl2)	; Is thers a join defined between tbl1 and tbl2
	;----------------------------------------------------------------------
	;
	N ddref,zddref
	;
	I 0						; Initialize $T
	;
	S ddref=tbl2_".",zddref=ddref_$$BYTECHAR^SQLUTL(255)
	F  S ddref=$O(join(ddref)) Q:ddref=""!(ddref]]zddref)  I (","_join(ddref))[(","_tbl1_".") Q
	Q $T
	;
	;----------------------------------------------------------------------
OUTER(tbl1,tbl2,join,jkeys)	; Remove outer join if possible
	;----------------------------------------------------------------------	
	; If tbl1 has foreign keys pointing to tbl2 or share the same 'M'
	; global structure and there is an outer join between tbl2 and
	; remove it if the join keys are the access keys.
	;
	; And set join(*,tbl1)=tbl2 to avoid unnessary $D checking in SQLM
	;
	N file1,file2,gbl1,gbl2,lib1,lib2,keys,I
	;
	S lib1=$P(fsn(tbl1),"|",11)
	I lib1["." S file1=$P(lib1,".",2),lib1=$P(lib1,".",1)
	E  S file1=tbl1
	;
	S lib2=$P(fsn(tbl2),"|",11)
	I lib2["." S file2=$P(lib2,".",2),lib2=$P(lib2,".",1)
	E  S file2=tbl2
	;
	S gbl1=$P(fsn(tbl1),"|",2),gbl2=$P(fsn(tbl2),"|",2)
	;
	I $E(gbl2,1,$L(gbl1))'=gbl1 Q 1
	;
	S keys=$P(fsn(tbl1),"|",3),tbl1=tbl1_".",tbl2=tbl2_"."
	;
	F I=1:1:$L(keys,",") I '$$CONTAIN($G(join(tbl1_$P(keys,",",I))),tbl2_$P(jkeys,",",I)) Q
	I  Q 1
	;
	I $E($O(rng(tbl1)),1,$L(tbl1))'=tbl1 S join("*",tbl1)=tbl2 K join(tbl1)
	Q '$T
	;
	;----------------------------------------------------------------------
VALUE(ddref,oprelat)	; Return value from the whr array
	;----------------------------------------------------------------------
	;
	N ptr						; *** 09/04/96
	S ptr=$G(rng(ddref,oprelat)) I ptr="" Q ""
	;
	Q $P($G(whr(ptr)),$C(9),2)
	;
	;----------------------------------------------------------------------
PLAN(index,vsql)	; Copy index into vsql("P"
	;----------------------------------------------------------------------
	;
	N z
	S z="" F  S z=$O(index(z)) Q:z=""  S vsql("P",z)=index(z)
	Q
	;
	;----------------------------------------------------------------------
DYNDXS(file)	; Generate code to build dynamic indices
	;----------------------------------------------------------------------
	;
	I $G(par("DYNAMIC"))=0 S ER=1,RM="/NODYNAMIC Qualifier set" Q
	;
	N I
	N bexe,eexe,fma,gbref,goto,igbref,jkeys,key,keys,sok,vsub,z
	;
	S z=fsn(file)
	N fsn						; Goofy M scoping!!
	;
	S fsn="vsql("
	S fsn(file)=z
	;
	S bexe=$G(exe)+1
	;
	D
	.	;
	.	N join,jfiles
	.	S jfiles=""
	.	D ACCESS^SQLM(file,"")
	;
	S eexe=$G(exe)
	;
	S gbref=$$TMPTBL^SQLM
	;
	S igbref=gbref,ikeys=""
	;
	S ddref=file_".",zddref=ddref_$$BYTECHAR^SQLUTL(255)
	;
	F  S ddref=$O(join(ddref)) Q:ddref=""!(ddref]]zddref)  D  Q:ER
	.	;
	.	S igbref=igbref_","_$P(ddref,".",2)
	.	I $D(vsub(ddref)) S gbref=gbref_","_vsub(ddref) Q
	.	;
	.	S NS=$$PARSE^SQLDD(.ddref,,.cmp,.fsn,.frm,.vdd,,.vsub) I ER Q
	.	S ikeys=ikeys_$S(ikeys="":"",1:",")_$P(ddref,".",2)
	.	D LOAD^SQLM
	.	S v0="vsql("_$$NXTSYM^SQLM_")",vsub(ddref)=v0
	.	S z="S "_v0_"="_NS_" I "_v0_"="""" S "_v0_"=$$BYTECHAR^SQLUTL(254)"
	.	S gbref=gbref_","_v0
	.	S exe=exe+1,exe(exe)=z
	;
	I ER Q
	I ikeys="" S ER=1,RM="Dynamic Index Join Error" Q
	;
	S keys=$P(fsn(file),"|",3)
	;
	F I=1:1:$L(keys,",") D
	.	;
	.	S key=$P(keys,",",I)
	.	I $$CONTAIN(igbref,key) Q
	.	S igbref=igbref_","_key,ikeys=ikeys_","_key
	.	S gbref=gbref_","_vsub(file_"."_key)
	;
	S exe=exe+1,exe(exe)="S "_gbref_")="""" S vsql="_vxp
	S vxp=-1
	;
	S index=file_".."
	S index(index)=igbref_"|"_ikeys
	S vsql("I",alias)=index(index)
	;
	S goto="S vsql=-1"
	F bexe=bexe+1:1:eexe D
	.	;
	.	S z=exe(bexe)
	.	I z[goto S exe(bexe)=$P(exe(bexe),goto,1)_"S vsql="_exe
	Q
	;
	;-------------------------------------------------------------------- 
ADDVAL(str,val)	; Add Value to String 
	;--------------------------------------------------------------------
	;
	I $G(str)=""!($G(val)="") Q $G(str)_$G(val)
	Q str_","_val
	;
	;----------------------------------------------------------------------
EXTERNAL	; User supplied index optimization externally
	;----------------------------------------------------------------------
	;
	N all,gvn,i,index,indexes,ixref,keys,plan
	;
	S ER=0
	;
	S all=1,plan=0
	;
	S indexes=$g(par("INDEX"))
	;
	F i=1:1:$L(frm,",") I ","_indexes'[(","_$P(frm,",",i)_".") S indexes=indexes_","_$P(frm,",",i)
	;
	F i=1:1:$L(indexes,",") D  Q:ER
	.	;
	.	S ixref=$P(indexes,",",i),file=$P(ixref,".",1)
	.	I '$D(fsn(file)) D fsn^SQLDD(.fsn,file) Q:ER
	.	S index=$P(ixref,".",2)
	.	I index="" S index="*",ixref=file_".*"
	.	S winner(file)=ixref
	.	S gvn=$P(fsn(file),"|",2),keys=$P(fsn(file),"|",3),lib=$P(fsn(file),"|",11)
	.	I index'="*" D
	..		;
	..		S index(file_".*")=gvn_"|"_keys_"|1|1|*|1"
	..		D LODINDX
	.	;
	.	S index(ixref)=gvn_"|"_keys_"|1|1|*|1"
	;
	I 'ER D JOIN
	quit
	;
	;----------------------------------------------------------------------
dist(numkeys)	; Return normal distributionzzz
	;----------------------------------------------------------------------
	;
	new return
	set return="10*100*1000*10000*100000*1000000"
	;
	if numkeys=1 set return=$P(return,"*",$L(return,"*"))
	else  set return=$P(return,"*",1,numkeys-1)_"*"_$P(return,"*",$L(return,"*"))
	quit return
