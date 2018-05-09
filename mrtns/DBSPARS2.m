DBSPARS2(vfid,vin,vout,vdi,vspmsg,vnoux)	;Public; Data item parser for filer definitions
	;;Copyright(c)2001 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/07/01 14:12:51 - CHENARDP
	;
	; Convert filer procedural code into MUMPS procedural code
	;
	; KEYWORDS:	DATA-QWIK
	;
	; ARGUMENTS:
	;
	;  . vfid  	Primary file			/TYP=T/REQ/MECH=VAL
	;  . vin	Input procedural code		/TYP=T/REQ/MECH=REFARR:R
	;               vin=1 if the source is PSL
	;  . vout 	Converted procedural code	/TYP=T/REQ/MECH=REFARR:W
	;  . vdi   	A list of data items referenced /TYP=T/MECH=REFARR:RW
	;  . vspmsg	Suppress error message		/TYP=L/NOREQ/DEF=0
	;  . vnoux      Suppress UX logic when using	/TYP=L/NOREQ/DEF=0
	;               SET command or from INSERT triggers
	;
	; RETURNS:
	;	. RM	Error message			/TYP=T
	;	. ER    Error flag			/TYP=N
	;
	; Valid syntax:
	;
	;      table.column		Data item format
	;	OLD.column		Old value
	;       NEW.column		New value
	;       SystemDate		Reserved keyword ([STBLJRNFUNC])
	;
	; EXAMPLES:
	;	    S in(1)=" I DEP.IRN>12 S DEP.BOO=1"
	;	    S in(2)=" I DEP.ODT=SysdateDate Q"
	;           S in(3)=" I OLD.BOO=123 Q
	;           D ^DBSPARS2("DEP",.in,.out,.item)
	;    Returns:   
	;           out(1)= I $P(DEP(57),"|",1)>12 S $P(DEP(52),"|",1)=1
	;           out(2)= I $P(DEP(52),"|",1)=TJD Q
	;           out(3)= I $P(UX("DEP","BOO"),"|",1)=123 Q
	;
	;           itrm("DEP.BOO")=""
	;           item("DEP.IRN")=""
	;
	; I18N=QUIT: Exculded from I18N standards. 
	;
	;---- Revision History ------------------------------------------------
	; 08/30/06 - RussellDS - CR22720
	;	     Replaced call to $$UPPER^SCAUTL with $$UPPER^UCGMR to
	;	     avoid bootstrap issues.
	;
	; 05/17/06 - Allan Mattson - CR20048
	;            Replaced calls to $$UPPER^%ZFUNC with $$UPPER^SCAUTL.
	;
	; 10/31/05 - RussellDS - CR17834
	;	     Removed reference to macro INSERTB, which is no longer
	;	     used.  Eliminates calls to obsolete DBSINS.
	;
	; 05/24/05 - RussellDS - CR16071
	;	     Added "CS" transaction ID to tstart.
	;		   
	;	     Removed old revision history.
	;----------------------------------------------------------------------
	;
	N arg,blk,btmkey,buff,cmd,cnt,code,com,def,dots,fid,file,fsn,ftype,gbl
	N i,k,key,keymap,keys,keywd,nod,nv,opt,optr,ox
	N p1,p2,p3,pos,ptr,pv,q,qtok,rectyp,routine,set,switch
	N v,vfsn,vkeys,vmap,x,y,z,NS,NS1
	;
	I $G(%LIBS)="" N %LIBS S %LIBS=^CUVAR("%LIBS")
	;
	S q="""",ER=0,vfsn="",cnt=0
	;
	I vfid'="" D  I $G(ER) Q			; *** 10/08/97
	.	D fsn^DBSDD(.fsn,vfid) I $G(ER) Q	; File attributes
	.	S vfsn=$P($P(fsn(vfid),"|",1),"(",1)	; File short name
	;						; Load in keyword table
	S i="" F  S i=$O(^STBL("JRNFUNC",i)) Q:i=""  S keywd(i)=$P(^(i),"|",2)
	;
	S k="" F  S k=$O(vin(k)) Q:k=""  D
	.	S v=vin(k)				; Replace && with $c(1,1)
	.	I v["$$^CUVAR(2)" W !,v,!!,"  -F- Replace $$^CUVAR function with SystemDate keyword",!!
	.	I v[";",$C(9)_$J("",8)[$p(v,";",1) S vout(k)=$c(9)_$$convtab(";"_$P(v,";",2,999)) q  ; Comment line
	.	F  Q:v'["&&"  S v=$P(v,"&&",1)_$C(1,1)_$P(v,"&&",2,99)
	.	S z=$$CONV(v,vfid)
	.	I $L(z)>500,z'[$c(0) D  Q		; *** 03/14/97
	..		W !,vin(k),!!,z,!!,$$^MSG(2338),! H 1
	..		S vout(k)=vin(k)
	.	I z'[$C(0) S vout(k)=z Q		; Simple command
	.	I z[$C(0,0) D  Q
	..		F i=1:1:$L(z,$C(0,0)) S vout(i/100+k)=$P(z,$c(0,0),i)
	.	S y=$P(z,$C(0),1)			; IF statement
	.	S vout(k)=y_"D  Q:ER"			; Structured DO
	.	S y=$P(y," ",2),y=$P(y,$C(9),1)
	.	S dots=$S($E(y)'=".":"",1:y)_". "_$C(9)
	.	F i=2:1:$L(z,$C(0)) S vout(i/100+k)=" "_dots_$P(z,$c(0),i)
	Q
	;----------------------------------------------------------------------
CONV(x,vfid)	; Convert each input line
	;----------------------------------------------------------------------
	S ptr=0,optr=0,nv="",pv="",ER=0,cnt=0,ox=x,set=0
	F i=1:1 S v=$$ATOM^%ZS(x,.ptr,$C(9)_"!;:,'()=+-*<>/_#[]~?&") D  Q:ER  Q:'ptr  S pv=v
	.	I 'ptr S blk=$J("",$L(x)-optr-$L(v))	; New pointer
	.	E  S blk=$J("",ptr-optr-$L(v))		; Gaps between items
	.	S optr=ptr				; Reset pointer
	.       D                                       ; 09/29/99 
	..              I $L(nv,"""")#2=0 Q             ; in quotes 
	..              I v["^SQL" S v=$$sql(x) Q       ; SQL command 
	..              S v=$$replace(v)                ; new value 
	.	I $E(v,1,2)=$c(1,1) D macro Q		; .MACRO. command
	.	;
	.	I $E(v,1,2)="S:" D  			; Remove , or S command
	..		I nv?.E1C1"S" S nv=$e(nv,1,$L(nv)-2) Q
	..		I nv?.E1" S" S nv=$e(nv,1,$L(nv)-2) Q
	..		I nv?.E1"," S nv=$e(nv,1,$L(nv)-1)_" "
	.	S nv=nv_blk_v			        ; New string
	.	I v=";" D comment			; comment line
	.	I v="("!(v["f") D chksn 		; Check short name
	.	;;;I $E(v,1,3)="^DB" Q			; Skip error message
	.	I $E(v)="^" D global Q			; Global or routine?
	I ER Q x					; Keep original input
	;I nv["NJD^UFRE",nv'["ER" D error("Missing ER checking logic")
	Q nv
	;----------------------------------------------------------------------
convtab(x)	; Replace tab with spaces 
	;----------------------------------------------------------------------
	I x'[$C(9) Q x
	N loc,p1,sp
	F  S loc=$F(x,$c(9)) Q:'loc  D
	.	S p1=$E(x,1,loc-2)			; First part
	.	S sp=8-($L(p1)#8)			; Next tab location
	.	S x=p1_$J("",sp)_$E(x,loc,9999)		; Replace it with spaces
	Q x
	;----------------------------------------------------------------------
comment	; Process comments 
	;----------------------------------------------------------------------
	I $L(nv,"""")#2=0 Q				; In quotes, continue
	I 'ptr Q
	S nv=nv_$E(x,ptr+1,999),ptr=0			; Stop here
	Q
sql(x)	;
	N sql,vtest
	S sql=$E(x,ptr+1,999)
	S sql=$p(sql,"""",1,2),ptr=ptr+$L(sql)
	S vtest=$P(sql,v,1)
	I $E(vtest,$l(vtest)-1,$l(vtest))'="D " S sql=v_sql,optr=ptr
	E  S optr=ptr Q v
	Q sql
	;----------------------------------------------------------------------
replace(x)	; Substitution 
	;----------------------------------------------------------------------
	N NS,setcode,sql
	I $D(keywd(x)) Q keywd(x)			; System keyword
	;
	I '((x?1A.AN1"."1A.AN)!(x?1A.AN1".%"1A.AN)) Q x
	I $P(x,".",2)="CURRVAL" Q $$curval(x)	  	; CURVAL.column
	I $P(x,".",2)="NEXTVAL" Q $$nexval(x)	  	; NEXTVAL.column
	I $P(x,".",1)="OLD" Q $$old(x)			; OLD.column
	I $P(x,".",1)="NEW" S x=$$new(x)		; NEW.column
	D PARSE^DBSDD(x)				; table.column
	I ER D error(RM) Q ""				; Invalid name
	S vdi(x)=""					; Save fid.di list
	S setcode=$$setcol(x)				; Set column logic
	I setcode=x Q NS
	Q setcode
	;						; User_defined variable
	;----------------------------------------------------------------------
setcol(x)	; convert S tbl.col=nv to S UX(tbl,col)=ov|nv,tbl,col=nv 
	;----------------------------------------------------------------------
	N del,del1,fun,i,if,newv,nod,nojrn,np,noux,pos,setcmd,setsf,str,NS,ux,z
	S nojrn="",fun=0,noux=$G(vnoux)		; S tbl.col/NOJOURNAL=...
	;					; S tbl.col/COMMENT(var)=...
	;                                       ; S tbl.col/NEW=...
	I $E(ox,ptr+1)="/",$E(ox,ptr+2,ptr+10)="NOJOURNAL" S ptr=ptr+10,nojrn=1
	I $E(ox,ptr+1)="/",$E(ox,ptr+2,ptr+4)="NEW" S ptr=ptr+4,noux=1
	;
	I $E(ox,ptr+1)'="=" S set=0 Q x			; Not a = operation
	S setcmd=$E(nv,$L(nv)-1,$L(nv))			; Last command
	I 'set,'((setcmd=" S")!(setcmd=($C(9)_"S"))) S set=0 Q x	; Not a SET command
	F i=ptr+2:1:$L(ox)+1 I (", "_$c(9))[$E(ox,i) Q		; Search for , or blk
	S str=$E(ox,ptr+2,i-1)				; New value
	I (str?1"$"1A1"(".E)!($E(str,1,2)="$$") D	; *** 10/09/97
	.	S z=0					; $$func(...) or
	.	F i=ptr+2:1:$L(ox)+1 s:$E(ox,i)="(" z=z+1 I $E(ox,i)=")" S z=z-1 Q:'z   ; $E,$P,$L
	.	S str=$E(ox,ptr+2,i)			; New value
	.	S np=$L(str,"(")-$L(str,")")		; Matched paren?
	.	I np S str=str_$E(ox,i+1,i+np)		; Add extra )
	.	S i=i+1+np				; Move pointer
	.	S fun=1					; Function indicator
	S ptr=i-1					; New pointer
	I $E(ox,i)="," S set=1				; Set indicator
	S newv=$$macro2(str)				; Internal format
	;
	S optr=ptr					; Reset pointer
	D PARSE^DBSDD(x)				; Internal format
	I noux D  Q NS
	.	I NS'["$$GET^USUB" S NS=NS_"="_newv Q
	.	S NS=$$subfld(NS)  			; Subfield definition
	;
	S nod=$$NOD^DBSDD(x)				; Node
	S pos=$$POS^DBSDD(x)				; Position
	I $$CMP^DBSDD(x)'="" W !,$G(vin(k)),!!,"  -F-  Cannot modify computed data item "_x,!!
	S del=q_"|"_q					; piece 5 = system created
	S del1=q_"|"_nod_"|"_pos_"|1|"_nojrn_"|"_q	; piece 6 to skip
	S str=""
	I fun S str="v="_newv_" ",newv="v"		; value substitution
	S ux="UX("_q_$P(x,".",1)_q_","_q_$P(x,".",2)_q_")"
	;
	S setsf="",if=""
	I NS["$$GET^USUB" D  				; Sub-field definition
	.	S setsf=$$subfld(NS)
	.	S if="v="_NS_" "
	.	S NS="v"
	S if=if_"S:("_NS_")'="_newv                     ; *** 03/14/97
	S str=str_if_" "_ux_"="_NS			; ***
	S str=str_"_"_del_"_"_newv_"_"_del1
	I setsf'="" Q str_","_setsf
	Q str_","_NS_"="_newv
	;
subfld(v)	; Sub-field definition                        ; *** 03/17/97 
	N sn,z
	S sn=$P($P(v,"(",2,99),")",1)_")"
	S z=$P(v,sn,2),z="$P(v,"_$P(z,",",3)_","_$p(z,",",5)_"="_newv
	S v="v="_sn_","_z_","_sn_"=v"
	Q v
	;
	;----------------------------------------------------------------------
curval(x)	; Convert CURVAL.table to $ZP(^gbl(""))
	;----------------------------------------------------------------------
	I ox["sql" Q x
	S fid=$P(x,".",1)				; Table name
	Q "vcurval("_q_fid_q_")"			; Local array
	;
	D fsn^DBSDD(.fsn,fid) I ER Q x			; Return orig value
	S gbl=$P($P(fsn(fid),"|",2),"(",1)		; Global reference
	Q "$O("_gbl_"("_q_q_"),-1)"			; $O(^gbl(""),-1)
	;----------------------------------------------------------------------
nexval(x)	; Convert NEXTVAL.tabel to $ZP(^gbl(""))+1
	;----------------------------------------------------------------------
	I ox["sql" Q x
	S fid=$P(x,".",1)				; Table name
	D fsn^DBSDD(.fsn,fid) I ER Q x			; Return orig value
	S gbl=$P($P(fsn(fid),"|",2),"(",1)		; Global reference
	Q "$O("_gbl_"("_q_q_"),-1)+1"			; $O(^gbl(""),-1)+1
	;----------------------------------------------------------------------
old(x)	; Convert to UX(fid)=old_value|new_value format
	;----------------------------------------------------------------------
	S x=vfid_"."_$P(x,".",2)			; Replace OLD with fid
	S vdi(x)=""					; Add it to item list
	D PARSE^DBSDD(x) I ER d error(RM) Q ""		; exit *** 09/23/97
	;
	S x="UX("_q_vfid_q_","_q_$P(x,".",2)_q_")"
	Q "$S($D("_x_"):$P("_x_","_q_"|"_q_",1),1:"_NS_")"
	;
	;----------------------------------------------------------------------
new(x)	; Convert to fid.di format
	;----------------------------------------------------------------------
	Q vfid_"."_$P(x,".",2)				; Replace it with fid
	;----------------------------------------------------------------------
chksn	; Check short name syntax
	;--------------------------------------------------------------------- -
	I pv="" Q
	I v["fDB"!(pv["fDB") q
	;
	I v?1"f"1U.UN!(pv=vfsn)!(pv="REL")!(pv="DEP")!(pv="LN")!(pv="CIF") D  Q
	.	I $G(vspmsg) Q				; Skip error message
	.	D error("File short name referenced") Q  ; Check short name
	I pv="UX" D error("Invalid array name - Fatal error") Q	 ; UX(...)
	Q
	;----------------------------------------------------------------------
global	; Verify D ^routine syntax
	;----------------------------------------------------------------------
	I pv="D"!(pv=",") Q				; Routine reference
	D error("Global reference - Fatal error")
	Q
	;----------------------------------------------------------------------
macro	; &&macro(table) command   &&INSERT  &&UPDATE  &&VERIFY &&DELETE
	;----------------------------------------------------------------------
	K fsn
	S cmd=$P(x,$C(1,1),2+cnt)			; &&cmd(arg,...)
	S cnt=cnt+1
	S com=$P(cmd,")",2,99)				; comments
	S arg=$P($P(cmd,"(",2),")",1)			; arg,...
	I arg["""",$L(arg,"""")#2=0 S arg=""""_$p(cmd,"""",2)_"""" ; *** 09/16/97
	S cmd=$P(cmd,"(",1)				; cmd
	S cmd=$$UPPER^UCGMR(cmd)			; Convert to uppercase
	S opt=""
	;
	I cmd="SQLINSERT" D sqlins(ox) Q
	I cmd="SQLUPDATE" D sqlupd(ox) Q
	I cmd="SQLDELETE" D sqldel(ox) Q
	I cmd="SQLSELECT" D sqlsel(arg) Q
	I cmd="SQLOPEN" D sqlopen(arg) Q
	I cmd="SQLFETCH" D sqlfet(arg) Q
	I cmd="CHARSET" D charset Q
	I $E(cmd,1,6)="TSTART" D tstart Q
	I $E(cmd,1,7)="TCOMMIT" D tcommit Q
	I $E(cmd,1,9)="TROLLBACK" D trollback Q
	;
	I $E(cmd,1,3)="SET" D  Q
	.	D seterr 
	.	I vin(k)'[" Q" D error("Missing Q:ER logic")
	;
	I cmd="DELERRXBAD" D seterr Q			; ******
	;
	I cmd="INSERT"!(cmd="INSERTM") S opt=0		; Processing mode
	I cmd="UPDATE" S opt=1
	I cmd="VERIFY" S opt=2
	I cmd="DELETE"!(cmd="DELETEM") S opt=3 
	;
	D macrop(arg,.file,.buff,.keymap,.switch)	; parse argument
	I opt="" D macro1 D:$G(ER) error(RM) Q		; Other macro commands
	I file="" Q					; Missing name
	D fsn^DBSDD(.fsn,file)				; File attributes
	;
	I ER D error(RM) Q				; Invalid name
	S fsn=$P($P(fsn(file),"|",1),"(",1)		; File short name
	S rectyp=$P(fsn(file),"|",4)			; Record type
	S keys=$p(fsn(file),"|",3)			; Access keys
	S routine=$p(fsn(file),"|",6)			; Filer name
	S z=opt I $g(switch)'="" S z=z_","_q_switch_q
	; 2/25/2000 (MAS) commented out next 2 lines and added code to always
	; 	    call EXT^DBSFILER 
	;I routine="" S code="D EXT^DBSFILER("_q_file_q_","_z_") Q:ER  " ; DQ filer
	;E  S code="D ^"_routine_"("_z_") Q:ER  "	; Real filer
	S code="D EXT^DBSFILER("_q_file_q_","_z_") Q:ER  " ; DQ filer
	I opt'=2,keymap'="" S code=$C(0)_keymap_$C(0)_code	; key mapping logic
	S def="I $D("_fsn_")"				; Check fsn first
	I opt=1 S cmd=def_",$D(UX("_q_file_q_")) "_code	; Also UX array for UPDATE
	I opt=2 S cmd=$$mverify(arg)_code		; VERIFY
	I opt=3,cmd'="DELETEM" S cmd=code		; DELETE
	I cmd="INSERT" S cmd=def_" "_code		; INSERT
	I cmd="INSERTM"!(cmd="DELETEM") S cmd=$$insertm(rectyp)	; INSERTM or DELETEM
	S nv=nv_blk_cmd					; new line
	S nv=$$comt(nv,com)
	S ptr=0						; stop parser
	Q
	;----------------------------------------------------------------------
sqlins(arg)	; Compile SQL INSERT statement &&SQLinsert("expr") to $$vinnn() 
	;----------------------------------------------------------------------
	N expr,par,rem,tag,v
	;						; Don't convert if in PSL format
	I '$G(vin) S arg=$$UPPER(arg) I ER Q		; 04/28/99
	S arg=$P(arg,"SQLINSERT",2,99)
	S ptr=ptr+$L(arg)
	S expr=$p(arg,"""",2)				; expr and variable name
	S par=$p(arg,"""",4)  				; parameters
	S tag=$G(vsqltag)+1,vsqltag=tag
	I expr="" D synerr(ox) Q
	I par'="" S expr=expr_$C(9)_par_"/NOFKCHK=1"	; Foreign key checks must wait until entire process is complete.
	S vsqltag("I",tag)=expr_$C(9)_"/NOFKCHK=1"	; Save expression
	I expr["..." S v=" ;"_expr			; Continue
	E  S v=" do vi"_$E(1000+tag,2,4)		; SQL tag name
	S nv=nv_v
	I par="" S rem=$P(arg,expr,2,99),ptr=ptr-$L(rem)+2,optr=ptr Q
	S rem=$P(arg,par,2,99),ptr=ptr-$L(rem)+2,optr=ptr
	Q
	;----------------------------------------------------------------------
sqlupd(arg)	; Compile SQL UPDATE statement &&SQLUPDATE("expr") to $$vunnn(.vc) 
	;----------------------------------------------------------------------
	N expr,par,tag,v,i
	;
	S arg=$$UPPER(arg) I ER Q
	S arg=$P(arg,"SQLUPDATE",2,99)
	S ptr=ptr+$L(arg)
	S expr=$p(arg,"""",2)				; expr and variable name
	S par=$P(arg,"""",4)				; Parameters
	S tag=$G(vsqltag)+1,vsqltag=tag
	I expr="" D synerr(ox) Q
	I par'="" S expr=expr_$C(9)_par_"/NOFKCHK=1"	; Foreign key checks must wait until entire process is complete.
	S vsqltag("U",tag)=expr_$C(9)_"/NOFKCHK=1"	; Save expression
	I expr["..." S v=" ;"_expr			; Continue
	E  S v=" D vu"_$E(1000+tag,2,4)			; SQL tag name  2/25/00 (remove parameter pass)
	; 2/25/2000 (MAS) added next 3 lines in order to remove extrinic return value.
	for i=$l(nv):-1:1 q:($e(nv,i)=","!($$UPPER^UCGMR($e(nv,i,i+1))="S "))
	I nv=$e(nv,i)="," S nv=$e(nv,1,i-1)_" "
	E  S nv=$E(nv,1,i-1)
	S nv=nv_v
	I par="" S rem=$P(arg,expr,2,99),ptr=ptr-$L(rem)+2,optr=ptr Q
	S rem=$P(arg,par,2,99),ptr=ptr-$L(rem)+2,optr=ptr
	Q
	;----------------------------------------------------------------------
sqldel(arg)	; Compile SQL DELETE statement &&SQLnDELETE("expr") to $$vdnnn(.vc) 
	;----------------------------------------------------------------------
	N expr,par,tag,v
	;
	S arg=$$UPPER(arg) I ER Q
	S arg=$P(arg,"SQLDELETE",2,99)
	S ptr=ptr+$L(arg)
	S expr=$p(arg,"""",2)				; expr and variable name
	S par=$p(arg,"""",4)  				; parameters
	S tag=$G(vsqltag)+1,vsqltag=tag
	I expr="" D synerr(ox) Q
	I par'="" S expr=expr_$C(9)_par
	S vsqltag("D",tag)=expr				; Save expression
	I expr["..." S v=" ;"_expr			; Continue
	E  S v=" do vd"_$E(1000+tag,2,4)		; SQL tag name
	S nv=nv_v
	I par="" S rem=$P(arg,expr,2,99),ptr=ptr-$L(rem)+2,optr=ptr Q
	S rem=$P(arg,par,2,99),ptr=ptr-$L(rem)+2,optr=ptr
	Q
	;----------------------------------------------------------------------
sqlsel(arg)	; Compile SQL SELECT statement &&SQLselect("expr") to $$vnnn(.vc) 
	;----------------------------------------------------------------------
	N expr,tag,v
	S expr=$p(arg,"""",2)				; expr and variable name
	S v=$$UPPER(expr) I ER Q
	I $E(expr)="*" D synerr(expr) Q			; SELECT * syntax
	S tag=$G(vsqltag)+1,vsqltag=tag
	I expr="" D synerr(ox) Q
	S vsqltag("S",tag)=expr				; Save expression
	I expr["..." S v=" ;"_expr			; Continue
	E  S v="$$vf"_$E(1000+tag,2,4)_"(.vc)"		; SQL tag name
	S nv=nv_v
	S ptr=ptr+$L(arg)+2,optr=ptr
	Q
	;----------------------------------------------------------------------
sqlopen(arg)	; Compile SQL SELECT statement &&SQLselect("expr") to $$vnnn(.vc) 
	;----------------------------------------------------------------------
	N expr,i,tag,v,v1
	S expr=$p(arg,"""",2)				; expr and variable name
	S v=$$UPPER(expr) I ER Q
	S tag=$g(vsqltag)+1,vsqltag=tag
	I expr="" D synerr(ox) Q
	S vsqltag("O",tag)=expr				; Save expression
	I expr["..." S v=" ;"_expr			; Continue ...
	E  D						; N save_list S v=$$sql
	.	S v1=""					; Save list *** 07/27/98
	.	F i=0:1:7 S v1=v1_",v"_$e(1000+tag,2,4)_i
	.	S v="$$vo"_$E(1000+tag,2,4)_"()"	; SQL tag name
	.	F i=$L(nv):-1:1 Q:$E(nv,i)=" "		; Locate the SET command
	.	S nv=$e(nv,1,i-2)_"N "_$E(v1,2,99)_" "_$E(nv,i-1,999)
	S nv=nv_v
	S ptr=ptr+$L(arg)+2,optr=ptr
	Q
	;----------------------------------------------------------------------
sqlfet(arg)	; Compile SQL SELECT statement &&SQLselect("expr") to $$vnnn(.vc) 
	;----------------------------------------------------------------------
	N tag,v
	S tag=$O(vsqltag("O",""),-1)			; Match last OPEN
	S v="$$vf"_$E(1000+tag,2,4)			; SQL FETCH tag name
	S nv=nv_v
	Q
	;----------------------------------------------------------------------
seterr	; &&SetErrXBAD   &&SetErrSTBLER   &&SetErrMsg
	;----------------------------------------------------------------------
	S nv=nv_" "
	I cmd="SETCOMMENT" D  Q
	.	N arg1,narg,x,ux			; fid.di syntax
	.	S x=$P(arg,q,2) I x'?1e.e1"."1e.e D synerr(ox) Q
	.	S arg1=$P(arg,q,4)			; comment
	.	I arg1="" D synerr(ox) Q		; Missing comment field
	.	S ux="UX("_q_$P(x,".",1)_q_","_q_$P(x,".",2)_q_")"
	.	S narg=$$macro2(arg1)			; parse comment field
	.	S nv=nv_"S:$D("_ux_") $P("_ux_","_q_"|"_q_",7)="_narg
	.	S ptr=ptr+$L(arg)+2,optr=ptr
	.	;
	I cmd="SETERRXBAD"!(cmd="DELERRXBAD") D  Q	; 06/02/99 BC
	.	N narg
	.	S narg=$$macro2($p(arg,",",2,99))
	.	D  I ER Q
	..		N z
	..		S z=$P(arg,",",1)
	..		I $E(z)?1A!($E(z)="%") Q
	..		I $E(z)="""" S z=$P(z,$C(34),2)
	..		I z="" Q
	..		I '$D(^STBL("XBAD",z)) D error("Invalid XBAD entry")
	.	;					; 06/02/99 BC
	.	I vfid="" D error("Missing file name - please check control page")
	.	I $E(cmd,1,3)="SET" S nv=nv_"D SETERR^DBSEXECU("_q_vfid_q_","_q_"XBAD"_q_","
	.	I  S nv=nv_$P(arg,",",1)_",,"_narg_")"
	.       E  S nv=nv_"D DELERR^DBSEXECU("_q_vfid_q_","_q_"XBAD"_q_","_$P(arg,",",1)_")"
	.	S ptr=ptr+$L(arg)+2,optr=ptr
	;
	I cmd="SETERRSTBLER" D  Q			; *** 02/24/97 BC
	.	I $E(arg)=""""!($E(arg)?1N) D  I ER Q
	..		N z
	..		S z=arg
	..		I $E(z)="""" S z=$P(z,$c(34),2)
	..		I '$D(^STBL("ER",z)) d error("Invalid ER entry") Q
	.	S nv=nv_"D SETERR^DBSEXECU("_q_vfid_q_","_q_"ER"_q_","_arg_")"
	. S ptr=ptr+$L(arg)+2,optr=ptr
	;
	I cmd="SETERRMSG" D  Q
	.	N narg,arg1,arg2,arg3
	.	S arg1=$p(arg,",",1),arg2=$P(arg,",",2),arg3=$P(arg,",",3) ; Message and parameter
	.	S narg=$$macro2(arg2) I narg["~" S narg=""""_narg_""""
	.	I narg="" S narg=arg1
	.	E  S narg=arg1_","_narg I arg3'="" S narg=narg_","_arg3
	.	D  I ER Q
	..		N z
	..		S z=$p(narg,",",1)
	..		I '$D(^STBL("MSG",z)) D error("Invalid MSG entry") Q
	.	S nv=nv_"D SETERR^DBSEXECU("_q_vfid_q_","_q_"MSG"_q_","_narg_")"
	.	;;I $L(arg,",")>2 D error("Too many parameters in &&setErrMsg")	; 09/29/99
	.	S ptr=ptr+$L(arg)+2,optr=ptr
	q
	;----------------------------------------------------------------------
macrop(arg,file,buff,keymap,switch)	; 
	;----------------------------------------------------------------------
	N akey,i,keys,newkey,var,ER
	K file,buff,keymap
	S keymap="",newkey="",switch="",ER=0
	S file=$P(arg,q,2)				; Table name
	I cmd="INSERTM"!(cmd="DELETEM") D  Q
	.	S buff=$P(arg,q,4),btmkey=$P(arg,q,6)	; Buffer name
	.	S switch=$P(arg,q,8)			; Filer qualifier
	.	I btmkey="" S ER=1,RM=$$^MSG(8607)
	;
	S keys=$P(arg,q,4)				; Access keys
	S switch=$P(arg,q,6)				; Run-time switch
	I cmd="SQLINSERT"!(cmd="SQLUPDATE") S switch=switch_"/NOFKCHK=1"
	I keys="" Q					; No need to continue
	F i=1:1:$L(keys,",") S key=$P(keys,",",i) D  Q:ER
	.	S akey=$P(key,"=",1),var=$P(key,"=",2)
	.	S keymap(akey)=""
	.	S var=$$macro2(var)			; Convert to internal
	.	I akey=var Q				; Same name
	.	I var="",arg["=" S ER=1 D error("Invalid access key value") Q
	.	S keymap=keymap_","_akey_"="_var	; key map
	.	S newkey=newkey_","_akey		; Save key variables
	I keymap="" Q
	S keymap="S "_$E(keymap,2,999)
	I newkey'="" S keymap="N "_$E(newkey,2,999)_" "_keymap
	Q
	;----------------------------------------------------------------------
insertm(rectyp)	; &&INSERTM("table","buffer","key") 
	;----------------------------------------------------------------------
	N cmd
	I buff="" S ER=1,RM="Missing buffer name" Q
	S cmd="I $D("_buff_") "_$C(0)
	I rectyp>1 D  Q cmd				; Type 10 record
	.	S cmd=cmd_" N i,"_fsn_","_btmkey_" S "_btmkey_"="_q_q_" F  S "_btmkey_"=$O("_buff_"("_btmkey_")) Q:"_btmkey_"="_q_q_"  "
	.	S cmd=cmd_" K "_fsn_" S i="_q_q_" F  S i=$O("_buff_"("_btmkey_",i)) Q:i="_q_q_"  "
	.	S cmd=cmd_" S "_fsn_"("_btmkey_",i)="_buff_"("_btmkey_",i) "_code
	S cmd=cmd_" N "_fsn_","_btmkey_" S "_btmkey_"="_q_q_" F  S "_btmkey_"=$O("_buff_"("_btmkey_")) Q:"_btmkey_"="_q_q_"  "
	S cmd=cmd_"S "_fsn_"="_buff_"("_btmkey_") "_code
	Q cmd
	;----------------------------------------------------------------------
macro1	; 
	; &&CHANGED("table.column")
	; &&CHANGED("table.column","SYSTEM")
	; &&EXIST(table,key1,key2,...)
	; &&LOAD(table,key1=val,key2=...)
	;----------------------------------------------------------------------
	I cmd="CHANGED" D  Q				; &&CHANGED("table.column")
	.	I arg'[q D  Q				; &&CHANGED(var) 11/05/99
	..       	S ptr=ptr+$L(arg)+2,optr=ptr 
	..		S nv=nv_blk_"$D(UX($P("_arg_","_q_"."_q_",1),$P("_arg_","_q_"."_q_",2)))"
	.	S p1=$P(arg,q,2),p2=$P(arg,q,4)
	.	I p1="" D synerr(arg) Q  		; Missing quotes
	.	I '$$VER^DBSDD(p1) S ER=1,RM=$$^MSG(1298,p1) Q  ; 09/29/99
	.	S p3=q_$P(p1,".",1)_q_","_q_$P(p1,".",2)_q	; "fid","di"
	.	I p2'="",p2'="SYSTEM" S ER=1,RM=$$^MSG(1397) D error(RM) Q
	.	I p2="" S nv=nv_blk_"$D(UX("_p3_"))"
	.	E  S nv=nv_blk_"$P($G(UX("_p3_")),"_q_"|"_q_",5)"
	.	S ptr=ptr+$L(arg)+2,optr=ptr
	;
	I cmd="EXIST" D  Q				; Convert to $D(^gbl...)
	.       S fid=$P(arg,q,2),vkeys=$P(arg,q,4,8) ; file name and keys
	.	I $E(vkeys,$L(vkeys))="""" S vkeys=$e(vkeys,1,$L(vkeys)-1)
	.	I fid="" D synerr(arg) Q		; Missing file name
	.       D fsn^DBSDD(.fsn,fid) I ER Q 		; File attributes
	.       S gbl=$P(fsn(fid),"|",2) 	; Global reference
	.	S rectyp=$P(fsn(fid),"|",4),nod=$P(fsn(fid),"|",12) ; Indicator
	.       S gbl=$$keys(vkeys,gbl)                 ; Convert fid.di syntax 
	.       I rectyp=10,nod'="" S nv=nv_blk_"$D("_gbl_","_nod_"))" 
	.       E  S nv=nv_blk_"$D("_gbl_"))" 
	.       S ptr=ptr+$L(arg)+2,optr=ptr 
	;
	I cmd="LOAD" D  Q				; Convert to $D(^gbl...)
	.       S fid=$P(arg,q,2),vkeys=$P(arg,q,4) 
	.	D fsn^DBSDD(.fsn,fid) I $G(ER) Q
	.	S gbl=$P(fsn(fid),"|",2)		; Global name
	.	S fsn=$P($P(fsn(fid),"|",1),"(",1)	; File short name
	.	S ftype=$P(fsn(fid),"|",4)		; File type
	.	S gbl=$$keys(vkeys,gbl)			; Convert fid.di syntax
	.	I ftype=1 S v="S "_fsn_"=$G("_gbl_"))"
	.	E  S v="N i K "_fsn_" S i="_q_q_" F  S i=$o("_gbl_",i)) Q:i="_q_q_"  S "_fsn_"(i)=$G(^(i))"
	.	S nv=nv_blk_v
	.	S ptr=ptr+$L(arg)+2,optr=ptr
	.	;
	;
	D error("Invalid macro command "_cmd)
	Q
	;----------------------------------------------------------------------
mverify(arg)	; Convert &&VERIFY("table","key1=var1,key2=var2,...") 
	;----------------------------------------------------------------------
	;
	N dinam,fsn,gbl,i,index,key,keys,newval,sn,v,z,NS
	S v="",newval=""
	D fsn^DBSDD(.fsn,file)				; File attributes
	;
	S gbl=$p(fsn(file),"|",2),keys=$p(gbl,"(",2)	; *** 11/19/97
	S key=$P(keys,",",1)				; Top level key
	I key?1a.an,'$D(keymap(key)) D			; Use index files if available
	.	S i="" F  S i=$O(^DBTBL(%LIBS,8,file,i)) Q:i=""  D
	..		S z=^(i)
	..		S index=$p(z,"|",3)		; Index order by info
	..		I '$D(keymap($P(index,",",1))) Q
	..		S keys=index
	..		S gbl="^"_$P(z,"|",2)_"("_index ; Switch to new access
	;
	F i=1:1:$L(keys,",") D
	.	S key=$P(keys,",",i)			; Access key
	.	I $e(key)=""""!($e(key)?1n) Q	; *** 11/19/97
	.	I $D(keymap(key)) Q			; Already defined
	.	S v=v_"S "_key_"="""""			; Initialize to null
	.	S newval=newval_","_key			; Save list
	.	S v=v_" F  S "_key_"=$O("_$P(gbl,",",1,i)_")) Q:"_key_"="""""_"  "  ;05/29/01
	I newval'="" S v="N "_$E(newval,2,999)_" "_v
	I keymap'="" S v=keymap_" "_v
	Q v
	;----------------------------------------------------------------------
KEY(keys)	; Remove dummy keys 
	;----------------------------------------------------------------------
	N i,k,key
	S k=""
	F i=1:1:$L(keys) D
	.	S key=$P(keys,",",i)
	.	I $E(key)?1A!($E(key)="%") S k=k_","_key
	Q $E(k,2,9999)
	;----------------------------------------------------------------------
macro2(str)	; Convert string to internal format 
	;----------------------------------------------------------------------
	N i,zi,zo
	I $E(str)="'" Q $TR(str,"'",q)			  ; Change ' to ""
	S zi(1)=str D DBSPARS2(vfid,.zi,.zo,.vdi) I $G(ER) Q str
	S str=zo(1)
	F i="+","-","*","/" I str[i S str="("_str_")" Q	  ; add () to protect
	Q str						  ; math operation
	;----------------------------------------------------------------------
keys(key,gbl)	; Convert fi,di syntax to internal format 
	;----------------------------------------------------------------------
	N akey,gblkey,i,lev,v,z
	S z="",ER=0
	S gblkey=$P($P(gbl,"(",2),")",1)		; Access keys
	S gbl=$P(gbl,"(",1)				; Global name
	S gblkey=$TR(gblkey,",",$C(0))			; Replace , with $C(0)
	F i=1:1:$L(gblkey,$c(0)) D
	.	S z=$P(gblkey,$c(0),i)			; Key
	.	I '(z?1a.an!(z?1"%".an)) Q		; Dummy key
	.	S gblkey(z)=i				; Level number
	F i=1:1:$L(key,",") D  I ER Q			; Parse each key
	.	S v=$P(key,",",i)			; Convert fid.di
	.	S akey=$P(v,"=",1),v=$P(v,"=",2)	; col=val
	.	I $E(v,1,2)="""""" S v=$E(v,2,99)	; extra quotes
	.	I akey="" D synerr(key) Q		; Invalid syntax
	.	I '$D(gblkey(akey)) S ER=1,RM=$$^MSG(1298,akey) D error(RM) Q
	.	S lev=gblkey(akey)			; key level
	.	I $E(v)="'" S v=$TR(v,"'",q)		; Convert ' to ""
	.	S v=$$macro2(v)				; Internal format
	.	S $p(gblkey,$c(0),lev)=v		; Replace key value
	I ER Q key					; Original value
	Q gbl_"("_$TR(gblkey,$c(0),",")			; Change delimiter
	;----------------------------------------------------------------------
dinam(x)	; Convert table.col to short name reference 
	;----------------------------------------------------------------------
	I $P(x,".",1)="OLD" Q $$old(x)
	I $P(x,".",1)="NEW" S x=$$new(x)
	D PARSE^DBSDD(x) I ER Q x
	Q NS
	;----------------------------------------------------------------------
comt(nv,com)	; Build command line with comments 
	;----------------------------------------------------------------------
	Q nv_" "_com
	;;;Q nv_$J("",40-$L(nv))_" "_com
	;
	;----------------------------------------------------------------------
COLLAT(fid)	; Return collating procedural code for a single file 
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;
	;	. fid	File name		/TYP=T/REQ/TBL=[DBTBL1]/MECH=VAL
	;
	; RETURNS:
	;
	;	$$	Collating procedural code
	;
	; EXAMPLE:
	;
	;  $$COLLAT("DEP")
	;
	;  N CID S CID="" F  S CID=$O(^ACN(CID)) Q:CID=""
	;
	;----------------------------------------------------------------------
	N fsn,gbl,i,k,key,keys,ref,v
	D fsn^DBSDD(.fsn,fid)			; File attributes
	S gbl=$P(fsn(fid),"|",2)		; Full reference
	S keys=$P(gbl,"(",2),gbl=$p(gbl,"(",1)	; Global name and access keys
	;
	S k=0
	F i=1:1:$L(keys,",") D			; Validate each key
	.	S key=$P(keys,",",i)		; Skip dummy keys
	.	I '((key?1A.A)!(key?1"%".AN)) Q
	.	S k=k+1,ref(k)=$P(keys,",",1,i) ; Each level
	I '$D(ref) Q ""				; Dummy file or CUVAR type file
	;
	S ref="" F i=1:1:k D			; Build collating code
	.	S v=ref(i),key=$P(v,",",$L(v,","))
	.	S ref=ref_" S "_key_"="""""_" F  S "_key_"=$O("_gbl_"("_v_"))"
	.	S ref=ref_" Q:"_key_"="""""_" "
	S ref="N "_$P(fsn(fid),"|",3)_ref_" "	; New key variables
	Q ref
	;----------------------------------------------------------------------
UPPER(str)	; Convert string (SQL command) to uppercase 
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;	str	Input string		/TYP=T/REQ/MECH=VAL
	;
	; RETURN:
	;
	;	$$      Converted string in uppercase
	;
	; EXAMPLE:
	;
	;   UPDATE dep set lnm='John Doe' where cid=:xcid
	;
	;   Returns:  UPDATE DEP SET LNM='John Doe' WHERE CID=:XCID
	;
	;----------------------------------------------------------------------
	N tok
	S ER=0
	I str'["'" D  Q str
	.	S ER=$$HOSTVAR(str) I ER Q
	.	S str=$$UPPER^UCGMR(str)       ; 
	S str=$$TOKEN^%ZS(str,.tok,"'")  	; Protect date in 'string'
	I str[":" S ER=$$HOSTVAR(str) 		; Invalid host variable name
	I 'ER S str=$$UPPER^UCGMR(str)   	; Convert to uppercase
	Q $$UNTOK^%ZS(str,.tok)  		; Restore original string
	;
	;----------------------------------------------------------------------
HOSTVAR(str)	; Validate host variable syntax 
	;----------------------------------------------------------------------
	N i,var,ER
	S ER=0
	F i=2:1:$L(str,":") D  I ER Q
	.	S var=$P(str,":",i)
	.	S var=$p(var," ",1)
	.	S var=$p(var,")",1)
	.	S var=$P(var,"""",1)	
	.	S var=$P(var,",",1)
	.	S var=$P(var,"...",1) 		; remove ...
	.	I var?1"%".UN Q  		; %NAME
	.	I var?1U.UN Q  			; Uppercase name
	.	I $G(vin),var?1A.AN Q		; 04/28/99 allow lowercase name
	.	S ER=1 D error("Only uppercase host variable name allowed - "_var)
	Q ER
	;----------------------------------------------------------------------
charset	;Retrieve all upper and lower characters to build a collating array
	;----------------------------------------------------------------------
	;
	N char,i,v,v1,var
	S nv=$G(nv)
	I nv["," S var=$P(nv,",",$L(nv,","))	; S var1=...,var2=&&charset
	E  S var=$P(nv," ",$L(nv," "))		; S var1=&&charset
	S var=$P(var,"=",1)			; Get variable name
	S v=$$LC^%CHARSET_$$UC^%CHARSET_"/0123456789@[\]^_`%!~$#&*()-+={}<>?:." 
	F i=1:1:$L(v) S char($E(v,i))="" ; Sort it in order
	S i="",v="",v1=""
	F  S i=$O(char(i)) Q:i=""  S v=v_","_$A(i) I $L(v)>450 S v1=v,v=""
	S ptr=999,optr=999
	I v1="" S nv=nv_"$C("_$E(v,2,999)_")" Q		; First 450 char
	S nv=nv_"$C("_$E(v1,2,999)_")"
	I v'="" S nv=nv_$C(0,0)_" S "_var_"="_var_"_$C("_$E(v,2,999)_")"
	Q
	;----------------------------------------------------------------------
tstart	; Start transaction
	;----------------------------------------------------------------------
	S nv=" N vtp S vtp=0 I '$Tlevel S vtp=$S($P(^CUVAR(""DBS""),""|"",7):0,1:1)"
	S nv=nv_$c(0,0)_" I vtp Tstart *:transactionid=""CS""  ; Start transaction"
	S ptr=999,optr=999
	Q
	;----------------------------------------------------------------------
tcommit	; Commit transaction 
	;----------------------------------------------------------------------
	S nv=nv_" Tcommit:vtp "
	Q
	;----------------------------------------------------------------------
trollback	; Roll back transaction 
	;----------------------------------------------------------------------
	S nv=nv_" Trollback:vtp "
	Q
	;---------------------------------------------------------------------
error(msg)	; Display error message
	;----------------------------------------------------------------------
	U 0 W !,x,!,?ptr-1,"^--- ",msg,!			; Error message
	h 3
	Q
	;----------------------------------------------------------------------
synerr(par)	; 
	;----------------------------------------------------------------------
	S ER=1,RM=$$^MSG(1477,par)			; Invalid syntax
	D error(RM)
	Q
TEST	;
	F  K (vatg) R !,"Input: ",x(1) Q:x(1)=""  D DBSPARS2("DEP",.x,.out) W ! ZWR
	Q
