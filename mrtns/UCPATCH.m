	; I18N=QUIT
	;
	; **** Routine compiled from DATA-QWIK Procedure UCPATCH ****
	;
	; 09/10/2007 17:31 - chenardp
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
	; * of the upgrade process.  Therefore, other than during an        *
	; * upgrade an mrtns version of this routine should not exist.      *
	; *                                                                 *
	; * Keep these comments as single line to ensure they exist in the  *
	; * generated M code.                                               *
	; *******************************************************************
	;
	N optFlag S optFlag=$get(commands("OPTIMIZE","OBJECTS"),0)
	N subRou S subRou=""
	;
	F  S subRou=$order(patch(0,subRou)) Q:(subRou="")  D procOrd(subRou,optFlag)
	Q 
	;
	; ---------------------------------------------------------------------
getPar(expr,pos)	;
	N ER N lits ; ER returned by $$TOKEN^%ZS()
	S expr=$$TOKEN^%ZS(expr,.lits)
	S expr=$piece(expr,"(",2,999) ; strip call name and (
	S expr=$E(expr,1,$L(expr)-1) ; strip )
	;
	Q $$vStrTrim($$UNTOK^%ZS($piece(expr,",",pos),lits),0," ")
	;
	; ---------------------------------------------------------------------
getSym(subRou,prefix)	;
	;
	N i
	N lvn
	;
	F i=1:1 S lvn=prefix_i Q:'$D(patch(-1,subRou,lvn)) 
	S patch(-1,subRou,lvn)=""
	;
	Q lvn
	;
	; ---------------------------------------------------------------------
hasPatch(data)	; arbitrary data
	;
	I data[$C(6),$L(data,$C(6))#2=1 Q 1
	Q 0
	;
	; ---------------------------------------------------------------------
isPatch(data)	; arbitrary data
	;
	I $E(data,1)=$C(6),($E(data,$L(data)-$L($C(6))+1,1048575)=$C(6)),$E(data,2,$L(data)-1)?1.N Q 1
	Q 0
	;
	; ---------------------------------------------------------------------
patchTkn(code,oVal,nVal)	;
	F  Q:code'[oVal  S code=$piece(code,oVal)_nVal_$piece(code,oVal,2,$L(code))
	Q code
	;
	; ---------------------------------------------------------------------
procOrd(subRou,optFlag)	;
	;
	N var S var=""
	N newPtr S newPtr=""
	N order
	;
	; Step 1: re-order
	F  S var=$order(patch(0,subRou,var)) Q:(var="")  D
	.	F  S newPtr=$O(patch(0,subRou,var,newPtr)) Q:(newPtr="")  S order(+newPtr,var)=""
	.	Q 
	;
	; Step 2: Process variables in the order in which they are declared
	S newPtr=""
	F  S newPtr=$order(order(newPtr)) Q:(newPtr="")  D
	.	F  S var=$order(order(newPtr,var)) Q:(var="")  D procPtr(subRou,var,newPtr,optFlag)
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
tokenPop(code,count)	;
	;
	N top S top=$order(pslToken(""),-1)
	;
	F top=top:-1:top-count+1 D
	.	S code=$$varSub(code,"vtkn"_top,pslToken(top))
	.	K pslToken(top),type(level,"vtkn"_top)
	.	Q 
	Q code
	;
	; ---------------------------------------------------------------------
tokenPush(expr,class)	; intermediate expressions
	;
	N top S top=$order(pslToken(""),-1)+1
	;
	S pslToken(top)=expr
	;
	I $$isVar^UCGM(expr) Q expr
	I $$isLit^UCGM(expr) Q expr
	;
	N lvn S lvn="vtkn"_top
	;
	D setScope^UCGM(lvn,"","","NEW",$get(class,"String"))
	D setInst^UCGM(lvn,"",expr)
	;
	Q lvn
	;
	; ---------------------------------------------------------------------
varSub(str,oVar,nVar)	;
	N dels S dels=" +-*/\#_'=><[]()!&,?@:"
	N lit
	N y
	S str=$$TOKEN^%ZS(str,.lit) S y=0
	;
	F  S y=$F(str,oVar,y) Q:y=0  D
	.	I dels'[$E(str,y-$L(oVar)-1)!(dels'[$E(str,y)) Q 
	.	S str=$E(str,1,y-$L(oVar)-1)_nVar_$E(str,y,1048575)
	.	S y=y+$L(nVar)-$L(oVar)
	.	Q 
	;
	Q $$UNTOK^%ZS(str,.lit)
	;
	; ---------------------------------------------------------------------
procPtr(subRou,var,newPtr,optFlag)	;local void; Proces this variable pointer
	;
	N class,code,expr,flag,lptr,record,token,x,z
	;
	S z=$G(patch(0,subRou,var,newPtr))
	S class=$P(z,tab,1)
	;
	S flag='optFlag ; Global
	I 'flag S flag=$P(z,tab,10) ; Optimize flag
	I 'flag,$P(z,tab,3)'="NEW" S flag=1 ; Only optimize new scope
	;
	I class="ResultSet" D ResultSet(subRou,var,newPtr,flag) Q 
	I class="DbSet" D ResultSet(subRou,var,newPtr,flag) Q 
	I 'flag,$$isRecord^UCGM(class) S flag=$$paNeedVobj^UCREC4OP(subRou,var,newPtr)
	;
	S token=""
	F  S token=$O(patch(0,subRou,var,newPtr,token)) Q:token=""  D
	.	S x=patch(token) S lptr=$P(x,$C(6),1) S expr=$P(x,$C(6),2,999)
	.	S z=$C(6)_token_$C(6) S code=msrc(lptr)
	.	I '(code[z) Q  ; *** Find out why this can occur (FRS)
	.	I flag S code=$P(code,z,1)_expr_$P(code,z,2,$L(code))
	.	E  S code=$$patchparse(code,expr,var,newPtr)
	.	S msrc(lptr)=code
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
patchparse(code,expr,var,newPtr)	; parse and patch code
	;
	N i,x,y,z
	S z=$C(6)_token_$C(6)
	;
	; Treat vClose() redirection separately
	I expr=("vClose(+$G("_var_"))") D  Q code
	.	;
	.	; If this ResultSet happens to be against M tables, remove call
	.	I '$P(struct("s",subRou,newPtr,var),tab,8) D  Q 
	..		S x="D "_z_" "
	..		I code[x S code=$P(code,x,1)_$P(code,x,2) Q 
	..		S x=z_","
	..		I code[x S code=$P(code,x,1)_$P(code,x,2) Q 
	..		S x=","_z
	..		I code[x S code=$P(code,x,1)_$P(code,x,2) Q 
	..		I code["D:" S i=0 F  S i=$F(code,"D:",i) Q:i=0  D
	...			S x="D:"_$P($E(code,i,1000)," ",1)_" "_z
	...			I code[x S code=$P(code,x,1)_$E($P(code,x,2),2,$L(code))
	...			Q 
	..		Q 
	.	;
	.	; add the vCloseR() subroutine if needed
	.	N label,p0,p1
	.	S label=$$XvCloseC^UCDBR()
	.	;
	.	; Replace by returned label.
	.	S p0=patch(-3,subRou,var,newPtr,0) ; state = vobj(,0)
	.	S p1=patch(-3,subRou,var,newPtr,1) ; curId = vobj(,1)
	.	S code=$P(code,z)_label_"(."_p0_","_p1_")"_$P(code,z,2)
	.	Q 
	;
	S y=oLvn_"("
	I expr'[y Q $$patchTkn(code,z,expr)
	;
	I '(expr["-150") S x=$P($P(expr,y,2,3),")",1)
	E  S x=$P($P(expr,y,3,4),")",1)
	;
	I x=("+$G("_var) D  ; Kill syntax
	.	S x="K "_z_" "
	.	I code[x S code=$P(code,x,1)_$P(code,x,2) Q 
	.	S x=z_","
	.	I code[x S code=$P(code,x,1)_$P(code,x,2) Q 
	.	S x=","_z
	.	I code[x S code=$P(code,x,1)_$P(code,x,2) Q 
	.	I code["K:" S i=0 F  S i=$F(code,"K:",i) Q:i=0  D
	..		S x="K:"_$P($E(code,i,1000)," ",1)_" "_z
	..		I code[x S code=$P(code,x,1)_$E($P(code,x,2),2,$L(code))
	..		Q 
	.	Q 
	E  D
	.	N lvn,nod
	.	;
	.	S nod=$P(x,",",2,999)
	.	;
	.	I nod="" S lvn=var
	.	;
	.	E  D
	..		;;if nod=.1,'$D(patch(-3,subRou,var,newPtr,nod)) set patch(-3,subRou,var,newPtr,nod)=$$getSym(subRou,"vos")
	..		I '($D(patch(-3,subRou,var,newPtr,nod))#2) S patch(-3,subRou,var,newPtr,nod)=$$getSym(subRou,"vos")
	..		S lvn=patch(-3,subRou,var,newPtr,nod)
	..		Q 
	.	;
	.	S x=oLvn_"("_x_")"
	.	;
	.	I expr[x S expr=$P(expr,x,1)_lvn_$P(expr,x,2)
	.	S code=$$patchTkn(code,z,expr)
	.	Q 
	Q code
	;
	; ---------------------------------------------------------------------
patchNew(var,new,newPtr)	; private void; Patch list new command line
	;
	I var["(" BREAK 
	N f,z
	S z=msrc(newPtr) S f="N "_var ; N var syntax
	;
	I '(z["N ") D  Q 
	.	S f="S "_var
	.	S z=$P(z,f,1)_"N "_$E(new,2,$L(new))_f_$P(z,f,2,99)
	.	S msrc(newPtr)=z
	.	Q 
	I '(z[f) D  ; N x,var syntax instead
	.	S f=","_var
	.	I '(z[f) S new=" N "_$E(new,2,$L(new))
	.	Q 
	S z=$P(z,f,1)_f_new_$P(z,f,2,999)
	S msrc(newPtr)=z
	Q 
	;
	; ---------------------------------------------------------------------
patch(subRou,var,newLevel,expr)	; Patch msrc for 'potential' object reduction
	;
	I var["(" Q expr ; Array
	;
	N class
	N newPtr
	S newPtr=$$getNew^UCGM(var,.newLevel) I newPtr="" Q expr
	;
	N noOpti S noOpti=+$$getOpti^UCGM(var,.newLevel)
	I noOpti>msrc D  ; protect $TEST
	.	D setOpti^UCGM(var,.newLevel,0)
	.	Q 
	E  I noOpti'=0 Q expr
	;
	N n
	S n=$G(patch)+1 S patch=n
	S patch(n)=(msrc+1)_$C(6)_expr
	S patch(0,subRou,var,newPtr,n)=""
	Q $C(6)_n_$C(6)
	;
	; ---------------------------------------------------------------------
ResultSet(subRou,var,newPtr,flag)	;
	;
	N code N expr N fexpr N new N test N x N y
	N col N lptr N n N token
	;
	N z S z=$get(struct("s",subRou,newPtr,var))
	;
	N instLine S instLine=$piece(z,tab)
	N seq S seq=$piece(z,tab,2)
	;
	N f S f=0 N sort S sort=0
	N label S label="vOpen"_seq
	;
	I $piece(z,tab,5)=1 S flag=1 ; ResultSet from Record.compare()
	I seq="" S flag=1 ; Public or multiple open's
	N rdb S rdb=$$rtIsRdb^UCXDD()
	;
	I $E(seq,1)=0 D
	.	I 'flag S flag=rdb!$$rsDynFlag()
	.	;
	.	Q:'rdb  Q:seq'=0 
	.	S n=3
	.	F  S n=$order(append(label,n)) Q:(n="")  D
	..		S code=$translate(append(label,n),tab," ")
	..		F fexpr="M","P","R" D
	...			I code[("vOpen0"_fexpr),'$D(append("vOpen0"_fexpr)) K append(label,n) Q 
	...			I code[("vFetch0"_fexpr),'$D(append("vOpen0"_fexpr)) K append(label,n) Q 
	...			Q 
	..		Q 
	.	Q 
	;
	I 'flag D
	.	; ResultSet access can be optimized.
	.	; Rewrite the vOpen and vFetch section for this instance
	.	S test=oLvn_"(vOid"
	.	S n=3
	.	F  S n=$order(append(label,n)) Q:(n="")  D
	..		S code=$translate(append(label,n),tab," ")
	..		;
	..		I $E(code,1,3)=" N ",(code'[";=noOpti") K append(label,n) Q 
	..		;
	..		I code["S vOid=" K append(label,n) Q 
	..		;
	..		I 'rdb,code=" Q vOid" S (code,append(label,n))=" Q """""
	..		E  I rdb,code=" Q vOid" S (code,append(label,n))=" Q $G("_var_")"
	..		I code[" Q vOid" S (code,append(label,n))=$piece(code," Q vOid")_" Q """""_$piece(code," Q vOid",2)
	..		I code[" Q:vEr=100 vOid" S (code,append(label,n))=$piece(code," Q:vEr=100 vOid")_" Q:vEr=100 """""_$piece(code," Q:vEr=100 vOid",2)
	..		;
	..		I code["vsql" S code=$$rplcvsql(code,subRou,var,newPtr) S append(label,n)=code D warnGroup^UCGM("INTERNAL","vsql references found and replaced in "_label)
	..		;
	..		I sort=0,code["K ^DBTMP($J,vOid)" S sort=n
	..		;
	..		I code["vFetch",code["(vOid)" S append(label,n)=$piece(code,"(vOid)")_"()"_$piece(code,"(vOid)",2) Q 
	..		;
	..		S y=$F(code,test) I y=0 Q 
	..		;
	..		I $E(code,y,y+1)=",-" K append(label,n) Q 
	..		;
	..		S code=$$change(code,test,subRou,var,newPtr)
	..		I sort=0,code[("S "_var_"=") ; set f=n
	..		S append(label,n)=code
	..		Q 
	.	Q 
	;
	I f>0 D  ; Parse record into column expressions
	.	S code=append(label,f)
	.	S code=$piece(code,"S "_var_"=",2,999)
	.	F col=1:1:$L(code,"_$C(9)_") S col(col)=$piece(code,"_$C(9)_",col)
	.	Q 
	;
	S fexpr="$$vFetch"_seq_"("_var_")"
	;
	; Replace all patch tokens for this ResultSet
	S token=""
	F  S token=$order(patch(0,subRou,var,newPtr,token)) Q:(token="")  D
	.	S x=patch(token) S lptr=$piece(x,$C(6)) S expr=$piece(x,$C(6),2,999)
	.	S z=$C(6)_token_$C(6) S code=msrc(lptr)
	.	I '(code[z) Q  ;*** Find out why this can occur (FRS)
	.	;
	.	I flag S msrc(lptr)=$$patchTkn(code,z,expr) Q 
	.	;
	.	I expr=fexpr S expr=$piece(expr,"(",1)_"()" S msrc(lptr)=$$patchTkn(code,z,expr) Q 
	.	;
	.	I f D
	..		N ptr S ptr=0
	..		I col=1,expr=(oLvn_"("_var_")") S ptr=1
	..		I col>1,expr=(oLvn_"("_var_")") S f=0 ; getRow
	..		I expr[",$C(9)," S ptr=$P($P(expr,",$C(9),",2),")",1)
	..		I ptr,$D(col(ptr)) S code=$$patchTkn(code,z,col(ptr))
	..		E  S code=$$patchparse(code,expr,var,newPtr)
	..		Q 
	.	E  S code=$$patchparse(code,expr,var,newPtr)
	.	S msrc(lptr)=code
	.	Q 
	;
	I f K append(label,f) ; Delete row set
	;
	S n="" S new=""
	F  S n=$O(patch(-3,subRou,var,newPtr,n)) Q:n=""  S new=new_","_patch(-3,subRou,var,newPtr,n)
	;
	I 'flag,sort>1 D
	.	S new=new_",vOid"
	.	S append(label,sort)=tab_"S vOid=$G(^DBTMP($J))-1,^($J)=vOid K ^DBTMP($J,vOid)"
	.	Q 
	I 'flag,(seq=0) D
	.	S new=new_",sqlcur"
	.	S append(label,3.1)=tab_"set sqlcur="""_subRou_"."_var_""""
	.	Q 
	I new'="" D patchNew(var,new,newPtr)
	Q 
	;
	; ---------------------------------------------------------------------
rsDynFlag()	;local Boolean; Return 'flag' value in case of dynamic selects
	;
	N flag,subRou,newPtr,var
	S flag=0 S (subRou,newPtr,var)=""
	F  S subRou=$O(struct("s",subRou)) Q:subRou=""  D  Q:flag>1 
	.	F  S newPtr=$O(struct("s",subRou,newPtr)) Q:newPtr=""  D  Q:flag>1 
	..		F  S var=$O(struct("s",subRou,newPtr,var)) Q:var=""  D  Q:flag>1 
	...			I $P(struct("s",subRou,newPtr,var),tab,2)=0 S flag=flag+1
	...			Q 
	..		Q 
	.	Q 
	;
	Q flag>1
	;
	; ---------------------------------------------------------------------
rplcvsql(code,subRou,var,newPtr)	; Replace vsql lvns
	;
	N atom,lvn,y,yz
	;
	S y=0
	F  S y=$F(code,"vsql",y) Q:y=0  D
	.	F yz=y:1 Q:$E(code,yz)'?1N 
	.	S atom=$E(code,y-4,yz-1) I atom="vsql" Q  ; FRS - 06/13/03
	.	S lvn=$G(patch(-3,subRou,var,newPtr,atom))
	.	I lvn="" S lvn=$$getSym(subRou,"vos") S patch(-3,subRou,var,newPtr,atom)=lvn
	.	S code=$E(code,1,y-5)_lvn_$E(code,yz,$L(code))
	.	Q 
	Q code
	;
	; ---------------------------------------------------------------------
change(code,test,subRou,var,newPtr)	; Change resultSet generate code
	;
	N char,lvn,nod,y
	;
	F  S y=$F(code,test) Q:y=0  D
	.	S char=$E(code,y)
	.	I char=")" S code=$E(code,1,y-$L(test)-1)_var_$E(code,y+1,$L(code)) Q 
	.	I char'="," BREAK 
	.	S nod=$P($E(code,y+1,$L(code)),")",1)
	.	S lvn=$G(patch(-3,subRou,var,newPtr,nod))
	.	I lvn="" S lvn=$$getSym(subRou,"vos") S patch(-3,subRou,var,newPtr,nod)=lvn
	.	S code=$E(code,1,y-$L(test)-1)_lvn_$E(code,y+2+$L(nod),$L(code)) Q 
	.	Q 
	Q code
	; ----------------
	;  #OPTION ResultClass 0
vStrTrim(object,p1,p2)	; String.trim
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I p1'<0 S object=$$RTCHR^%ZFUNC(object,p2)
	I p1'>0 F  Q:$E(object,1)'=p2  S object=$E(object,2,1048575)
	Q object
