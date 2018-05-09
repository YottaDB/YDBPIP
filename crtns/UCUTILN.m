UCUTILN	;
	;
	; **** Routine compiled from DATA-QWIK Procedure UCUTILN ****
	;
	; 11/08/2007 14:08 - chenardp
	;
	; I18N=QUIT
	; *******************************************************************
	; * IMPORTANT NOTE:                                                 *
	; * According to the rules that apply to PSL compiler upgrades,     *
	; * the generated M routine associated with this procedure must be  *
	; * checked into StarTeam and released with the procedure whenever  *
	; * changes are made to this procedure.                             *
	; *                                                                 *
	; * The M routine will be loaded to the mrtns directory during      *
	; * upgrades and will then be removed from that directory as part   *
	; * of the upgrade process.  Therefore, other than during an        *
	; * upgrade an mrtns version of this routine should not exist.      *
	; *                                                                 *
	; * Keep these comments as single line to ensure they exist in the  *
	; * generated M code.                                               *
	; *******************************************************************
	Q 
	;
AUDIT(obj,audit,rectyp,dlm)	;
	;
	N fmtable N nvl N ovl N pos N sfd N typ N v
	N nod S nod="" N di S di=""
	N is400 S is400=($D(vobj(obj,-400))#2)
	;
	F  S nod=$order(vobj(obj,-100,nod)) Q:(nod="")  D
	.	;
	.	I $get(vobj(obj,-100,nod))=1 Q  ; not changed
	.	S vobj(obj,-100,nod)=1 ; set build flag
	.	;
	.	F  S di=$order(vobj(obj,-100,nod,di)) Q:(di="")  D
	..		;
	..		S v=vobj(obj,-100,nod,di) ; old value data
	..		S typ=$E(v,1) ; data type
	..		S pos=$E(v,2,4) ; position
	..		S ovl=$piece($E(v,5,1048575),dlm) ; old value
	..		S sfd=$piece(v,dlm,3) ; subfield data
	..		;
	..		I nod="0*" S nvl=vobj(obj)
	..		E  I nod["*" S nvl=vobj(obj,-2-nod) S pos=0
	..		E  I "BM"[typ D  ; blob or memo
	...			S nvl=vobj(obj,$piece(nod,","),$piece(nod,",",2))
	...			S pos=0 ; no position
	...			Q 
	..		E  S nvl=vobj(obj,nod)
	..		;
	..		; if pos>0,(nod'["*")!(nod="0*") set new = new.piece(del,pos)
	..		I pos>0 S nvl=$piece(nvl,dlm,pos)
	..		I '(sfd="") D
	...			N d2 S d2=$S(dlm="~":";",1:"~")
	...			S nvl=$$getSf^UCCOLSF(nvl,$piece(sfd,d2),$piece(sfd,d2,2),$piece(sfd,d2,3),$piece(sfd,d2,4))
	...			Q 
	..		;
	..		I ovl=nvl Q  ; Don't set up
	..		;
	..		S audit(di)=ovl_dlm_nvl_dlm_dlm_typ_dlm
	..		;
	..		I is400,$get(vobj(obj,-400,di))=0 S $piece(audit(di),dlm,3)=1
	..		;
	..		I '($piece(v,dlm,11)="") S $piece(audit(di),dlm,11)=$piece(v,dlm,11)_dlm
	..		Q 
	.	Q 
	;
	Q 
	;
	; ---------------------------------------------------------------------
initPar(insert)	; filer parameters to insert into default list
	Q $$setPar("/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",$get(insert))
	;
	; ---------------------------------------------------------------------
setPar(parList,insert)	;
	;
	N c N i
	N z
	;
	I ($get(parList)="") S parList=""
	;
	I '($E(parList,1)="/") S parList="/"_parList
	I ($E(parList,$L(parList))="/") S parList=$E(parList,1,$L(parList)-1)
	;
	I ("/"_insert_"/")["/NOVAL/" S insert=$piece(("/"_insert_"/"),"/NOVAL/",1)_"/NOVALDD/NOVALFK/NOVALREQ/NOVALRI/NOVALST/"_$piece(("/"_insert_"/"),"/NOVAL/",2)
	;
	F i=1:1:$L(insert,"/") D
	.	S z=$piece(insert,"/",i)
	.	I (z="") Q 
	.	;
	.	S c=1
	.	I z["=" S c=$piece(z,"=",2) S z=$piece(z,"=",1)
	.	;
	.	I ($E(z,1,2)="NO") S c='c S z=$E(z,3,1048575)
	.	;
	.	I z["FKCHK" S z="VALFK" ; Legacy
	.	;
	.	I 'c S parList=$piece(parList,"/"_z,1)_"/NO"_z_$piece(parList,"/"_z,2)
	.	E  S parList=$piece(parList,"/NO"_z,1)_"/"_z_$piece(parList,"/NO"_z,2)
	.	;
	.	Q 
	;
	I '(parList=""),'($E(parList,$L(parList))="/") S parList=parList_"/"
	;
	Q parList
	;
vSIG()	;
	Q "60736^67228^Dan Russell^9162" ; Signature - LTD^TIME^USER^SIZE
