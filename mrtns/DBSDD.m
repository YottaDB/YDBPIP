DBSDD	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSDD ****
	;
	; 09/10/2007 17:31 - chenardp
	;
	;
	; *******************************************************************
	; * IMPORTANT NOTE:                                                 *
	; * According to the rules that apply to PSL compiler upgrades,     *
	; * the generated M routine associated with this procedure must be  *
	; * checked into StarTeam and released with the procedure whenever  *
	; * changes are made to this procedure.  The M routine from the     *
	; * crtns directory should be used for this purpose.                *
	; *                                                                 *
	; * The M routine will be loaded to the mrtns directory during      *
	; * upgrades and will then be removed from that directory as part   *
	; * of the upgrade process.  Therefore, other during an upgrade,    *
	; * an mrtns version of this routine should not exist.              *
	; *                                                                 *
	; * Keep these comments as single line to ensure they exist in the  *
	; * generated M code.                                               *
	; *******************************************************************
	;
	Q  ; No access from top
	;
PARSE(ddexpr,X,cmp,fsn,frm,vdd,lvn,vsub)	;
	;
	N del N fld
	N di N file N nod N sfd N typ
	;
	S ER=0
	;
	I ($get(X)="") S X=$$DI(.ddexpr,.frm,.vdd,.fsn)
	E  S ddexpr=$$CVTREF(ddexpr,.frm)
	;
	I ER S NS="" Q 
	;
	I ($D(vsub(ddexpr))#2) S NS=vsub(ddexpr) Q 
	;
	S file=$piece(ddexpr,".",2)
	S di=$piece(ddexpr,".",3)
	;
	I '($D(fsn(file))#2) D fsn(.fsn,file)
	;
	I '($get(frm)=""),'((","_frm_",")[(","_file_",")) S frm=frm_","_file
	;
	S del=$piece(fsn(file),"|",10)
	S nod=$piece(X,"|",1)
	S fld=$piece(X,"|",21)
	S sfd=$piece(X,"|",18)
	S typ=$piece(X,"|",11)
	;
	I (nod="") S del="" ; Needed for computed data items
	;
	; Return memo field internal expression
	I ($piece(X,"|",9)="M") D
	.	;
	.	N z
	.	;
	.	S z=$$PARSE^DBSMEMO(file)
	.	; Remove [TABLE] syntax
	.	S $piece(X,"|",16)=$$vStrRep(z,"["_file_"]","",0,0,"")
	.	Q 
	;
	I '($piece(X,"|",16)="") D  Q 
	.	;
	.	I ($D(cmp(file,di))#2) S NS=$piece(cmp(file,di),"=",1) I ($E(NS,1,2)="S ") S NS=$E(NS,3,999) Q 
	.	S NS=$$CMPUTED($piece(X,"|",16))
	.	Q 
	;
	I ($piece(X,"|",1)["*") D  Q  ; Access keys
	.	;
	.	I ($get(lvn)="") S NS=di
	.	E  S NS=lvn
	.	Q 
	;
	I '$$isLit^UCGM(nod) D
	.	;
	.	I ($piece(fsn(file),"|",4)=1) S nod=" " ; Type 1
	.	E  D
	..		;
	..		N z
	..		;
	..		S z=$piece(fsn(file),"|",3)
	..		S z=$piece(z,",",$L(z,","))
	..		I (z=nod) S nod=" "
	..		E  S nod=""""_nod_""""
	..		Q 
	.	Q 
	;
	S NS=$piece($get(fsn(file,nod)),"|",1)
	;
	I (NS="") D
	.	;
	.	D lodnod(file,nod,.fsn)
	.	S NS=$piece(fsn(file,nod),"|",1)
	.	Q 
	;
	; Apply MUMPS functions to array reference
	;
	I del S NS="$P("_NS_","_$S(del<32:"$C("_del_")",1:""""_$C(del)_"""")_","_$S(fld:fld,1:1)_")"
	;
	I '(sfd=""),'($translate(sfd,"~0")="") D
	.	;
	.	N sft N sfd1 N sfd2 N sfp
	.	;
	.	S sft=$piece(sfd,"~",1)
	.	S sfd1=$piece(sfd,"~",2)
	.	S sfd2=$piece(sfd,"~",3)
	.	S sfp=$piece(sfd,"~",4)
	.	;
	.	I sfd1 S sfd1=$char(sfd1)
	.	I sfd2 S sfd2=$char(sfd2)
	.	;
	.	S NS="$$GET^USUB("_NS_","""_sft_""","""_sfd1_""","""_sfd2_""","_+sfp_")"
	.	Q 
	;
	I ($E(typ,1)="B") S NS="$A("_NS_")\"_$P("1/2/4/8/16/32/64/128","/",$E(typ,2))_"#2"
	;
	I (NS="") S NS=""""""
	;
	Q 
	;
CMPUTED(cmpin)	; Computed expression
	;
	N ptr
	N atom N cmpinuc N cmputed N dels N NS N return N tok
	;
	I ($D(cmp(file,di))#2) D  Q return
	.	;
	.	S return=$piece(cmp(file,di),"=",1)
	.	I ($E(return,1,2)="S ") S return=$E(return,3,999)
	.	Q 
	;
	; Do not allow set or do in computed
	S cmpinuc=$$UPPER^%ZFUNC(cmpin)
	I (($E(cmpinuc,1,2)="S ")!($E(cmpinuc,1,2)="D ")) D  Q ""
	.	;
	.	S ER=1
	.	; Invalid computed data item = 'di'
	.	S RM=$$^MSG(8316,$$^MSG(595),file_"."_di)
	.	Q 
	;
	S cmputed=$$TOKEN^%ZS(cmpin,.tok)
	S return=""
	S (ER,ptr)=0
	S dels="[]+-*/\#_'=><\*(),!&:?"
	;
	; Build the M expression
	F  D  Q:('ptr!ER) 
	.	;
	.	N ddref
	.	;
	.	S atom=$$ATOM^%ZS(cmputed,.ptr,dels,tok,1) Q:ER 
	.	;
	.	; Handle pattern match operations
	.	I (atom="?") S return=return_"?"_$$ATOM^%ZS(cmputed,.ptr,dels,tok,1) Q 
	.	;
	.	I (dels[atom) S return=return_atom Q 
	.	I ($E(atom,1)="%") D  Q 
	..		;
	..		;    #ACCEPT Date=05/04/06; PGM=RussellDS; CR=20967
	..		N rs  N V1 S V1=atom S rs=$$vOpen2()
	..		;
	..		I $$vFetch2(rs) S return=return_$P(vobj(rs),$C(9),1)
	..		K vobj(+$G(rs)) Q 
	.	;
	.	I ($A(atom)=0) S return=return_$$UNTOK^%ZS(atom,tok) Q 
	.	I ($E(atom,1)="$") S return=return_atom Q 
	.	I (atom=+atom) S return=return_atom Q 
	.	;
	.	; Should be column reference at this point
	.	I '$$isColumn^UCXDD(file,atom) D  Q 
	..		;
	..		; Invalid Table Value
	..		S RM=$$^MSG(7194)
	..		Q 
	.	;
	.	; Parse the column
	.	S ddref=file_"."_atom
	.	D PARSE(.ddref,"",.cmp,.fsn,.frm,.vdd,.lvn,.vsub) Q:ER 
	.	S return=return_NS
	.	;
	.	I $$SIMPLFUN(NS) Q 
	.	;
	.	I ($get(cmp(file))="") S cmp(file)=atom Q 
	.	;
	.	I '((","_(cmp(file))_",")[(","_atom_",")) S cmp(file)=atom_","_cmp(file)
	.	Q 
	;
	I ER Q ""
	;
	S return=$$UNTOK^%ZS(return,tok)
	;
	I $$SIMPLFUN(return) Q return
	;
	I (($E($$vStrUC(return),1,2)="D ")!($E($$vStrUC(return),1,3)="DO ")) S cmp(file,atom)=return Q di
	;
	S lvn=di
	;
	S cmp(file,di)="S "_lvn_"="_return
	;
	Q lvn
	;
FINDINAM(X,ptr)	;
	;
	; chrldr = valid first characters for file and data item names
	; chrtbl = valid other characters for file and data item names
	;
	N isDone
	N ptrz N s1 N s2 N y
	N ddref N return
	;
	; Check for comment field
	S y=0
	F  S y=$F(X,";",y) Q:(y="")  Q:$L($E(X,1,y-2),"""")#2 
	;
	I y S X=$E(X,1,y-2)
	;
	I '$get(ptr) S ptr=1
	;
	S (s1,s2)=ptr
	S return=""
	S isDone=0
	;
	; Return linetag if found item is not legal
	F  Q:'('isDone)  D
	.	;
	.	F  S s1=$F(X,"[",s1) Q:$L($E(X,1,s1-1),"""")#2 
	.	F  S s2=$F(X,".",s2) Q:$L($E(X,1,s2-1),"""")#2 
	.	;
	.	I (s1=0),(s2=0) D  Q 
	..		;
	..		S ptr=$L(X)
	..		S return=""
	..		S isDone=1
	..		Q 
	.	;
	.	I (+s1'=+0) S ddref="" D  Q:isDone 
	..		;
	..		N ptrz
	..		;
	..		D
	...			Q:("%ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"'[$E(X,s1))  ; Invalid char
	...			;
	...			F ptrz=s1:1:$L(X) Q:("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"'[$E(X,ptrz))  ; Scan for ,]
	...			I ($E(X,ptrz)=",") F ptrz=ptrz+1:1:$L(X) Q:("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"'[$E(X,ptrz)) 
	...			Q:(($E(X,ptrz)'="]")!(ptrz=$L(X))) 
	...			Q:("%ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"'[$E(X,ptrz+1))  ; Invalid dinam
	...			F ptrz=ptrz+2:1:$L(X)+1 Q:("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"'[$E(X,ptrz)) 
	...			S s1=s1-1
	...			S ddref=$E(X,s1,ptrz-1)
	...			Q 
	..		;
	..		I '(ddref="") D
	...			;
	...			S ptr=ptrz-1
	...			;
	...			I ((s1<s2)!(s2=0)) D
	....				;
	....				S return=ddref
	....				S isDone=1
	....				Q 
	...			Q 
	..		Q 
	.	;
	.	I (+s2'=+0) D
	..		;
	..		S ddref=""
	..		;
	..		Q:(s2'<$L(X)) 
	..		Q:("%ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"'[$E(X,s2))  ; Invalid Dinam
	..		Q:("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"'[$E(X,s2-2))  ; Invalid file
	..		;
	..		S ptrz=s2-3
	..		F s2=s2+1:1:$L(X)+1 Q:("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"'[$E(X,s2)) 
	..		F ptrz=ptrz:-1:0 Q:("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"'[$E(X,ptrz)) 
	..		S ptr=s2-1
	..		Q:("%ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"'[$E(X,ptrz+1))  ; Invalid 1st
	..		I (+ptrz'=+0),(".?"[$E(X,ptrz)) Q  ; Pattern Match
	..		S ddref=$E(X,ptrz+1,s2-1)
	..		;
	..		I '(ddref="") D
	...			;
	...			S return=ddref
	...			S isDone=1
	...			Q 
	..		Q 
	.	;
	.	I (s1=0) S s1=$L(X)
	.	I (s2=0) S s2=$L(X)
	.	Q 
	;
	Q return
	;
SIMPLFUN(X)	; Reference to check
	;
	I ($E(X,1,2)="$$") Q 0
	I ($translate(X," ^","")'=X) Q 0
	;
	Q 1
	;
LIB(file,libr,fsn,vdd)	;
	;
	S ER=0
	;
	N X
	;
	I ($get(file)="") D  Q ""
	.	;
	.	S ER=1
	.	; Null file
	.	S RM=$$^MSG(2075)
	.	Q 
	;
	S X="SYSDEV,"_file
	;
	I ($D(vdd(X))#2) Q vdd(X)
	;
	I '($D(fsn(file))#2) D fsn(.fsn,file) I ER Q ""
	;
	S vdd(X)="SYSDEV."_file
	;
	Q vdd(X)
	;
DI(ddexpr,frm,vdd,fsn)	;
	;
	S ER=0
	;
	N delim
	N di N fid N return N sfd
	;
	S ddexpr=$$CVTREF(ddexpr,.frm,.fsn,.vdd) I ER Q ""
	;
	I ($D(vdd(ddexpr))#2) Q vdd(ddexpr)
	;
	S fid=$piece(ddexpr,".",2)
	;
	I '($D(fsn(fid))#2) D fsn(.fsn,fid,.vdd) I ER Q ""
	;
	S di=$piece(ddexpr,".",3)
	;
	S ddexpr="SYSDEV."_fid_"."_di
	;
	I ($D(vdd(ddexpr))#2) Q vdd(ddexpr)
	;
	N tableinfo
	;
	S ER='$$getTableInfo(fid,.tableinfo)
	;
	I ER S delim=""
	E  S delim=$P(tableinfo,"|",10)
	;
	N colinfo
	;
	S ER='$$getColInfo(fid,di,.colinfo)
	;
	I ER D  Q ""
	.	;
	.	; Invalid data item - ~p1
	.	S RM=$$^MSG(1300,ddexpr)
	.	Q 
	;
	S sfd=$P(colinfo,"|",10)_"~"_$P(colinfo,"|",11)_"~"_$P(colinfo,"|",12)_"~"_$P(colinfo,"|",13)
	I (($translate(sfd,"~","")="")) S sfd=""
	;
	S return=$P(colinfo,"|",3)_"|"_$P(colinfo,"|",7)_"|"_$P(colinfo,"|",18)_"|"_$P(colinfo,"|",19)
	S return=return_"|"_$P(colinfo,"|",20)_"|"_$P(colinfo,"|",21)_"|"_$P(colinfo,"|",22)_"|"_$P(colinfo,"|",23)
	S return=return_"|"_$P(colinfo,"|",6)_"|"_$P(colinfo,"|",24)_"|"_$P(colinfo,"|",25)
	S return=return_"|"_$P(colinfo,"|",26)_"|"_$P(colinfo,"|",27)_"|"_$P(colinfo,"|",8)_"|"_$P(colinfo,"|",28)
	S return=return_"|"_$P(colinfo,"|",14)_"|"_($P(colinfo,"|",15)>0)_"|"_sfd_"|"_$P(colinfo,"|",29)
	S return=return_"|"_delim_"|"_$P(colinfo,"|",4)_"|"_$P(colinfo,"|",30)_"|"_$P(colinfo,"|",31)
	S return=return_"|"_$P(colinfo,"|",32)_"|"_$P(colinfo,"|",33)_"|"_$P(colinfo,"|",34)_"|"_$P(colinfo,"|",35)
	S return=return_"|"_$P(colinfo,"|",36)_"|"_$P(colinfo,"|",37)_"|"_$P(colinfo,"|",38)_"|"_$P(colinfo,"|",9)
	;
	S vdd("SYSDEV,"_fid)="SYSDEV."_fid ; Retain backward compatibility
	S vdd(ddexpr)=return
	;
	Q return
	;
CVTREF(ddref,frm,fsn,vdd)	;
	;
	S ER=0
	;
	S ddref=$$QSUB^%ZS(ddref,"""")
	;
	I ($E(ddref,1)="[") D  I ER Q ""
	.	;
	.	I '(ddref["]") D
	..		;
	..		S ER=1
	..		; Invalid data item name - ~p1
	..		S RM=$$^MSG(1300,ddref)
	..		Q 
	.	;
	.	S ddref=$translate($E(ddref,2,999),"],","..")
	.	Q 
	;
	I ($L(ddref,".")=1) D
	.	;
	.	N I
	.	N fid
	.	;
	.	I ($L($get(frm),",")=1) S ddref=$get(frm)_"."_ddref Q 
	.	;
	.	F I=1:1:$L(frm,",") D
	..		;
	..		S fid=$piece(frm,",",I) Q:(fid="") 
	..		I '($D(fsn(fid))#2) D fsn(.fsn,fid)
	..		;
	..		I '$$isColumn^UCXDD(fid,ddref) D
	...			;
	...			S ddref="SYSDEV."_fid_"."_ddref
	...			S I=$L(frm)
	...			Q 
	..		Q 
	.	;
	.	I '(ddref[".") D
	..		;
	..		S ER=1
	..		; Invalid data item name - ~p1
	..		S RM=$$^MSG(1300,ddref)
	..		Q 
	.	Q 
	;
	I ($L(ddref,".")=2) D
	.	;
	.	N fid
	.	;
	.	S fid=$piece(ddref,".",1)
	.	;
	.	I +fid D  Q:ER 
	..		;
	..		S fid=$piece($get(frm),",",fid)
	..		I (fid="") D
	...			;
	...			S ER=1
	...			; Invalid file name ~p1
	...			S RM=$$^MSG(1337,ddref)
	...			Q 
	..		Q 
	.	E  I (fid="") D  Q 
	..		;
	..		S ER=1
	..		; Invalid data item name - ~p1
	..		S RM=$$^MSG(1300,ddref)
	..		Q 
	.	;
	.	I '($get(frm)=""),'((","_frm_",")[(","_fid_",")) D  Q 
	..		;
	..		S ER=1
	..		; Invalid file name ~p1
	..		S RM=$$^MSG(1337,ddref)
	..		Q 
	.	;
	.	I '($D(fsn(fid))#2) D fsn(.fsn,fid) Q:ER 
	.	;
	.	S ddref=$piece(fsn(fid),"|",11)_"."_fid_"."_$piece(ddref,".",2)
	.	Q 
	;
	I ER Q ""
	;
	I '$$VER(ddref,.vdd,.fsn) D  Q ""
	.	;
	.	S ER=1
	.	; Invalid data item name - ~p1
	.	S RM=$$^MSG(1300,ddref)
	.	Q 
	;
	Q ddref
	;
SETVAL(ddexpr,value,x,fsn,vdd,ux,scrseq)	;
	;
	D SETVAL^DBSDB(ddexpr,value,.x,.fsn,.vdd,.ux,.scrseq)
	;
	Q 
	;
RETREC(frm,sel,acc,ext,del,qwt,fsn,vdd)	;
	;
	Q $$RETREC^DBSDB(frm,sel,.acc,.ext,.del,.qwt,.fsn,.vdd)
	;
RETVAL(ddexpr,acc,buf,vfy,fsn,x,vdd)	;
	;
	Q $$RETVAL^DBSDB(ddexpr,.acc,.buf,.vfy,.fsn,.x,.vdd)
	;
VER(ddexpr,vdd,fsn)	;
	;
	N return
	N di N file
	;
	I ($E(ddexpr,1)="[") S ddexpr=$translate($E(ddexpr,2,999),"],","..")
	;
	I ($L(ddexpr,".")<3) S ddexpr="SYSDEV."_ddexpr
	;
	S file=$piece(ddexpr,".",2)
	S di=$piece(ddexpr,".",3)
	;
	I ((file="")!(di="")) S return=0
	E  S return=$$isColumn^UCXDD(file,di)
	;
	Q return
	;
fsn(fsn,file,vdd)	;
	;
	N I
	N acckeys N glref N keys N lvn N X
	;
	I ($get(file)="") D  Q 
	.	;
	.	S ER=1
	.	; Invalid NULL parameter for File
	.	S RM=$$^MSG(8615)
	.	Q 
	;
	N tableinfo
	;
	S ER='$$getTableInfo(file,.tableinfo)
	;
	I ER S RM=$$^MSG(1337,file) Q  ; Invalid file name ~p1
	;
	S acckeys=$P(tableinfo,"|",3)
	S keys=""
	F I=1:1:$L(acckeys,",") D
	.	;
	.	N key S key=$piece(acckeys,",",I)
	.	;
	.	I '($$isLit^UCGM(key)!($E(key,1)="$")) S keys=keys_key_","
	.	Q 
	S keys=$E(keys,1,$L(keys)-1)
	;
	I ($get(fsn)="") D
	.	;
	.	S lvn=$P(tableinfo,"|",17)
	.	I '(lvn["(") S lvn=lvn_"("
	.	Q 
	E  S lvn=""
	;
	S glref=$P(tableinfo,"|",2)
	I ($piece(glref,"(",2)="""*""") S glref=$piece(glref,"(",1)_"(" ; CUVAR
	;
	S X=lvn_"|"_glref_"|"_keys_"|"_$P(tableinfo,"|",4)_"|"_$P(tableinfo,"|",21)
	S X=X_"|"_$P(tableinfo,"|",6)_"|"_$P(tableinfo,"|",16)_"|"_$P(tableinfo,"|",22)_"|"_$P(tableinfo,"|",24)
	S X=X_"|"_$P(tableinfo,"|",10)_"|SYSDEV|"_$P(tableinfo,"|",12)_"|"_$P(tableinfo,"|",23)_"|"_$P(tableinfo,"|",20)
	;
	S fsn(file)=X
	;
	Q 
	;
lodnod(file,nod,fsn)	;
	;
	N rectyp
	N lvn
	;
	I '($D(fsn(file))#2) D fsn(.fsn,file)
	;
	S lvn=$piece(fsn(file),"|",1)
	S rectyp=$piece(fsn(file),"|",4)
	;
	I ((rectyp'=1)!('(lvn[")"))) D
	.	;
	.	I (nod=" ") S lvn=$E(lvn,1,$L(lvn)-1)
	.	E  I ($E(lvn,$L(lvn))="(") S lvn=lvn_nod_")"
	.	E  S lvn=lvn_nod
	.	Q 
	;
	S fsn(file,nod)=lvn
	;
	Q 
	;
MASK()	;
	Q "NOD,LEN,D,DOM,,,,,TYP,DES,ITP,,,DEC,,CMP,FCR,OFS,SIZ,DEL,POS,RHD,MNT,CNV,LTD,USER,MDD,VAL4EXT"
	;
LIST(file,opt)	;
	;
	N I
	N fsn N keys N return
	;
	D fsn(.fsn,file) I $get(ER) Q ""
	;
	S keys=$piece(fsn(file),"|",3)_","
	F I=1:1:$L(keys,",") D
	.	;
	.	N di
	.	;
	.	S di=$piece(keys,",",I)
	.	;
	.	I ($E(di,1)="%") S $piece(keys,",",I)=$S(di'["""":""""_di_"""",1:$$QADD^%ZS(di,""""))
	.	Q 
	;
	S return=""
	;
	N rs,vos1,vos2,vos3,vos4,vos5,vos6  N V1 S V1=file S rs=$$vOpen3()
	;
	F  Q:'($$vFetch3())  D
	.	;
	.	N di S di=$P(rs,$C(9),1)
	.	;
	.	N colinfo
	.	;
	.	Q:'$$getColInfo(file,di,.colinfo) 
	.	;
	.	I '$get(opt),'($P(colinfo,"|",14)=""),($P(colinfo,"|",14)'=" ") Q  ; Don't include computeds
	.	;
	.	I ($E(di,1)="%") S di=$S(di'["""":""""_di_"""",1:$$QADD^%ZS(di,"""")) ; Non-SQL syntax
	.	;
	.	S return=return_di_","
	.	Q 
	;
	I (return="") S return=$E(keys,1,$L(keys)-1)
	E  D
	.	;
	.	I (keys=",") S keys=""
	.	S return=keys_$E(return,1,$L(return)-1)
	.	Q 
	;
	Q return
	;
getTableInfo(table,tableInfo)	;
	;
	N return S return=1
	;
	D
	.	;
	.	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	.	;
	.	S tableInfo=$$getSchTbl^UCXDD(table)
	.	Q 
	;
	Q return
	;
getColInfo(table,column,colInfo)	;
	;
	N return S return=1
	;
	D
	.	;
	.	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap2^"_$T(+0)_""")"
	.	;
	.	S colInfo=$$getSchCln^UCXDD(table,column)
	.	Q 
	;
	Q return
	;
COLLIST(table,noMaster,noBlbMem,noCmputd,keys)	;
	;
	N ER
	N I
	N acckeys N return
	;
	N tableinfo
	;
	S ER='$$getTableInfo(table,.tableinfo)
	;
	I ER Q ""
	;
	S (keys,return)=""
	;
	S acckeys=$P(tableinfo,"|",3)
	S keys=""
	F I=1:1:$L(acckeys,",") D
	.	;
	.	N key S key=$piece(acckeys,",",I)
	.	;
	.	I '$$isLit^UCGM(key) S keys=keys_key_","
	.	Q 
	;
	S keys=$E(keys,1,$L(keys)-1)
	;
	N rs,vos1,vos2,vos3,vos4  N V1 S V1=table S rs=$$vOpen4()
	;
	F  Q:'($$vFetch4())  D
	.	;
	.	N di S di=rs
	.	;
	.	N colinfo
	.	;
	.	Q:'$$getColInfo(table,di,.colinfo) 
	.	;
	.	I $get(noMaster),($P(colinfo,"|",15)>0) Q  ; Exclude master fields
	.	I $get(noBlbMem),(($P(colinfo,"|",6)="B")!($P(colinfo,"|",6)="M")) Q  ; Exclude blobs and memos
	.	I $get(noCmputd),'($P(colinfo,"|",14)=""),($P(colinfo,"|",14)'=" ") Q  ; Exclude computeds
	.	;
	.	S return=return_di_","
	.	Q 
	;
	S return=$E(return,1,$L(return)-1)
	;
	I '(keys="") S return=keys_","_return
	;
	Q return
	;
NOD(ddexpr,x,vdd)	;
	Q $$FIELD(ddexpr,1,.x,.vdd) ; Array Node
LEN(ddexpr,x,vdd)	;
	Q $$FIELD(ddexpr,2,.x,.vdd) ; Field Length
DFT(ddexpr,x,vdd)	;
	Q $$FIELD(ddexpr,3,.x,.vdd) ; Default expression
TBL(ddexpr,x,vdd)	;
	Q $$FIELD(ddexpr,5,.x,.vdd) ; Table lookup
TYP(ddexpr,x,vdd)	;
	Q $$FIELD(ddexpr,9,.x,.vdd) ; Data Type
DES(ddexpr,x,vdd)	;
	Q $$FIELD(ddexpr,10,.x,.vdd) ; Description
DEC(ddexpr,x,vdd)	;
	Q $$FIELD(ddexpr,14,.x,.vdd) ; Decimal Precision
REQ(ddexpr,x,vdd)	;
	Q $$FIELD(ddexpr,15,.x,.vdd) ; Required Flag
CMP(ddexpr,x,vdd)	;
	Q $$FIELD(ddexpr,16,.x,.vdd) ; Cmputed MUMPS Express
OFS(ddexpr,x,vdd)	;
	Q $$FIELD(ddexpr,18,.x,.vdd) ; Offset Pointer
POS(ddexpr,x,vdd)	;
	Q $$FIELD(ddexpr,21,.x,.vdd) ; Field Position
MDD(ddexpr,x,vdd)	;
	Q $$FIELD(ddexpr,27,.x,.vdd) ; Master Dictionary
	;
FIELD(ddexpr,loc,x,vdd)	;
	;
	I ($get(x)="") S x=$$DI(ddexpr,"",.vdd,.fsn) I (x="") Q ""
	;
	Q $piece(x,"|",loc)
	; ----------------
	;  #OPTION ResultClass 0
vStrRep(object,p1,p2,p3,p4,qt)	; String.replace
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
	;  #OPTION ResultClass 0
vOpen2()	; PSLBOOT result set for STBLSYSKEYWD
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I '($D(commands("boot","STBLSYSKEYWD"))#2) Q $$vOpen1()
	N vRws S vRws=commands("boot","STBLSYSKEYWD")
	N vOid S vOid=$O(vobj(""),-1)+1
	S vobj(vOid,-1)="ResultSet"
	S vobj(vOid,-5)=2
	S vobj(vOid,-2)="$$vFetch2^"_$T(+0)
	S vobj(vOid,-3)="DES"
	S vobj(vOid,-4)="T0"
	S vobj(vOid,0)=1
	S vobj(vOid,1)=$G(ATOM) I vobj(vOid,1)="" Q 
	S vobj(vRws,0)=0 
	I $$vFetch2(vOid) S vobj(vOid,0)=2
	Q vOid
	; ----------------
	;  #OPTION ResultClass 0
vFetch2(vOid)	; PSLBOOT fetch for STBLSYSKEYWD
	N vret
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I '($D(commands("boot","STBLSYSKEYWD"))#2) Q $$vFetch1(vOid)
	N vRws S vRws=commands("boot","STBLSYSKEYWD")
	I vobj(vOid,0)=2 S vobj(vOid,0)=1 Q 1
	N vR
	N vFnd S vFnd=0
	F  Q:'('vFnd)  D
	.	I '$$vRwsNxt(vRws) S vFnd=1 S vobj(vOid,0)=0 Q 
	.	S vR=$S(vobj(vRws,0)>0:$G(vobj(vRws,vobj(vRws,0))),1:"")
	.	I '($P(vR,vobj(vRws,-3),$$vRwGC(vobj(vRws,-2),"KEYWORD"))=vobj(vOid,1)) Q 
	.	S vFnd=1
	.	Q 
	S vR=$S(vobj(vRws,0)>0:$G(vobj(vRws,vobj(vRws,0))),1:"")
	S vobj(vOid)=$P(vR,vobj(vRws,-3),$$vRwGC(vobj(vRws,-2),"DES"))
	S vret=vobj(vOid,0) Q vret
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
	; ----------------
	;  #OPTION ResultClass 0
vStrFnd(object,p1,p2,p3,qt)	; String.find
	;
	;  #OPTIMIZE FUNCTIONS OFF
	;
	I (p1="") Q $SELECT(p2<1:1,1:+p2)
	I p3 S object=$$vStrUC(object) S p1=$$vStrUC(p1)
	S p2=$F(object,p1,p2)
	I '(qt=""),$L($E(object,1,p2-1),qt)#2=0 D
	.	F  S p2=$F(object,p1,p2) Q:p2=0!($L($E(object,1,p2-1),qt)#2) 
	.	Q 
	Q p2
	; ----------------
	;  #OPTION ResultClass 0
vRwGC(vList,vRef)	; Dynamic column position lookup
	;
	;  #OPTIMIZE FUNCTIONS OFF
	;
	I (vRef="") Q ""
	I +vRef>0 Q vRef
	;
	S vList=$$vStrUC(vList) S vRef=$$vStrUC(vRef)
	N vP S vP=$F((vList_",")," "_vRef_",")
	I vP=0 S vP=$F((","_vList_","),","_vRef_",") I vP=0 Q ""
	Q $L($E(vList,1,vP-$L(vRef)),",")
	;
vOpen1()	;	DES FROM STBLSYSKEYWD WHERE KEYWORD=:V1
	;
	N vOid
	;
	S vOid=$O(vobj(""),-1)+1
	S vobj(vOid,0)=2
	S vobj(vOid,-1)="ResultSet"
	S vobj(vOid,-2)="$$vFetch1^"_$T(+0)
	S vobj(vOid,-3)="DES"
	S vobj(vOid,-4)="T0"
	D vL1a1
	Q vOid
	;
vL1a0	S vobj(vOid,0)=0 Q
vL1a1	S vobj(vOid,1)=$G(V1) I vobj(vOid,1)="" G vL1a0
	I '($D(^STBL("SYSKEYWORDS",vobj(vOid,1)))#2) G vL1a0
	Q
	;
vFetch1(vOid)	;
	;
	N vsql2
	;
	I vobj(vOid,0)=0 Q 0
	;
	S vobj(vOid,0)=100
	S vsql2=$G(^STBL("SYSKEYWORDS",vobj(vOid,1)))
	S vobj(vOid)=$P(vsql2,"|",1)
	S vobj(vOid,0)=0
	;
	Q 1
	;
vOpen3()	;	DI,NOD,POS FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1 AND (NOT NOD LIKE '%*') AND SFD IS NULL ORDER BY NOD,POS,DI ASC
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(V1) I vos2="" G vL3a0
	S vos3=""
vL3a3	S vos3=$O(^DBINDX("SYSDEV","STR",vos2,vos3),1) I vos3="" G vL3a0
	I '(vos3'?1"".E1"*") G vL3a3
	S vos4=""
vL3a6	S vos4=$O(^DBINDX("SYSDEV","STR",vos2,vos3,vos4),1) I vos4="" G vL3a3
	S vos5=""
vL3a8	S vos5=$O(^DBINDX("SYSDEV","STR",vos2,vos3,vos4,vos5),1) I vos5="" G vL3a6
	S vos6=$G(^DBTBL("SYSDEV",1,vos2,9,vos5))
	I '($P(vos6,"|",18)="") G vL3a8
	Q
	;
vFetch3()	;
	;
	;
	I vos1=1 D vL3a8
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos5=$$BYTECHAR^SQLUTL(254):"",1:vos5)_$C(9)_$S(vos3=$$BYTECHAR^SQLUTL(254):"",1:vos3)_$C(9)_$S(vos4=$$BYTECHAR^SQLUTL(254):"",1:vos4)
	;
	Q 1
	;
vOpen4()	;	DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1 AND (NOT NOD LIKE '%*') ORDER BY DI ASC
	;
	;
	S vos1=2
	D vL4a1
	Q ""
	;
vL4a0	S vos1=0 Q
vL4a1	S vos2=$G(V1) I vos2="" G vL4a0
	S vos3=""
vL4a3	S vos3=$O(^DBTBL("SYSDEV",1,vos2,9,vos3),1) I vos3="" G vL4a0
	S vos4=$G(^DBTBL("SYSDEV",1,vos2,9,vos3))
	I '($P(vos4,"|",1)'?1"".E1"*") G vL4a3
	Q
	;
vFetch4()	;
	;
	;
	I vos1=1 D vL4a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos3=$$BYTECHAR^SQLUTL(254):"",1:vos3)
	;
	Q 1
	;
vRwsNxt(vOid)	;	RowSet.next
	;
	N vLst S vLst=$O(vobj(vOid,""),-1)
	I vobj(vOid,0)'>vLst S vobj(vOid,0)=vobj(vOid,0)+1
	Q vobj(vOid,0)'>vLst
	;
vtrap1	;	Error trap
	;
	N error S error=$ZS
	;
	S return=0
	Q 
	;
vtrap2	;	Error trap
	;
	N error S error=$ZS
	;
	S return=0
	Q 
