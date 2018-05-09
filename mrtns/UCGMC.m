UCGMC(cmd,m2src,lptr,str,ptr,tok)	;
	;
	; **** Routine compiled from DATA-QWIK Procedure UCGMC ****
	;
	; 09/10/2007 17:32 - chenardp
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
	;
	S cmd=$E(cmd,2,1048575)
	;
	I cmd="ACCEPT" Q $$ACCEPT(.m2src,lptr,str,.ptr,tok)
	I cmd="BREAK" Q $$BREAK(str,.ptr,tok)
	I cmd="BYPASS" Q $$BYPASS(.m2src,.lptr,.ptr)
	I cmd="IF" Q $$IF(.m2src,.lptr,str,.ptr,tok)
	I cmd="ELSE",fCompile>0 Q $$ELSE(.m2src,.lptr,.ptr)
	I cmd="END",fCompile>0 Q $$END(.ptr)
	I cmd="ENDIF",fCompile>0 Q $$END(.ptr)
	I cmd="OPTIMIZE" Q $$OPTIMIZE(str,.ptr,tok)
	I cmd="OPTION" Q $$OPTION(str,.ptr,tok)
	I cmd="WARN" Q $$WARN(str,.ptr,tok)
	I cmd="INFO" Q $$INFO(str,.ptr,tok)
	I cmd="WHILE" Q $$WHILE(.m2src,.lptr,str,.ptr,tok)
	I cmd="XECUTE" Q $$XECUTE(str,.ptr,tok)
	;
	D ERROR^UCGM("Unexpected compiler command: "_cmd)
	S ptr=0
	Q "; "_str
	;
	; ---------------------------------------------------------------------
ACCEPT(m2src,lptr,str,ptr,tok)	;
	;
	N atom S atom="" N kwd N return
	N val
	N elm N llptr S llptr=$order(m2src(lptr))
	;
	F  S return=$$getExpr(str,.ptr,tok,"") Q:(return="")  S atom=atom_return Q:ptr=0 
	;
	F kwd="DATE","PGM" D
	.	S val=$piece($piece($piece((";"_atom),";"_kwd_"=",2),";",1),"=",1)
	.	I (val="") D warnGroup^UCGM("SYNTAX","Accept requires "_kwd_" field")
	.	Q 
	;
	I %VN'<7 D
	.	S val=$piece($piece($piece((";"_atom),";CR=",2),";",1),"=",1)
	.	I (val="") D
	..		N dat S dat=$piece($piece($piece((";"_atom),";DATE=",2),";",1),"=",1)
	..		I dat?.E1P4N S dat=$E(dat,$L(dat)-3,1048575)
	..		E  I dat?4N1P.E S dat=$E(dat,1,4)
	..		I dat?4N,+dat<2005 Q 
	..		;
	..		D warnGroup^UCGM("SYNTAX","Accept requires CR field")
	..		Q 
	.	Q 
	;
	S ptr=0
	S val=$$vStrUC($piece($piece($piece((";"_atom),";GROUP=",2),";",1),"=",1))
	I (val="") S commands("ACCEPT",llptr)=""
	E  F elm=1:1:$S((val=""):0,1:$L(val,",")) S commands("ACCEPT",llptr,$piece(val,",",elm))=""
	;
	Q "; "_str
	;
	; ---------------------------------------------------------------------
BREAK(str,ptr,tok)	;
	N $ZT S $ZT="B"
	;
	I '$$ask(.str,.ptr,tok) Q ""
	I str="" BREAK  Q ""
	;
	;  #ACCEPT DATE=2006-03-14;PGM=FSCW;CR=20280;GROUP=XECUTE
	XECUTE "ZB "_str
	;
	Q ""
	;
	; ---------------------------------------------------------------------
BYPASS(m2src,lptr,ptr)	;
	; Bypass the M++ compiler
	N init
	N mcode
	N stop S stop=0
	;
	D warnGroup^UCGM("BYPASS","Embedded M code bypassing compiler")
	;
	S init=$$initLine^UCGM(level)
	;
	D ADD^UCGM(init_";*** Start of code by-passed by compiler")
	;
	F  Q:'('stop)  S lptr=$order(m2src(lptr)) Q:lptr=""  D
	.	;
	.	S mcode=m2src(lptr)
	.	I $$vStrUC(mcode)["#ENDBYPASS" S stop=1 Q 
	.	S mcode=init_$$vStrTrim($translate(mcode,$char(9)," "),-1," ")
	.	D ADD^UCGM(mcode)
	.	Q 
	;
	D resetType^UCGM() ; Invalidate assignments to Primitives
	;
	S ptr=0
	Q ";*** End of code by-passed by compiler ***"
	;
	; ---------------------------------------------------------------------
DEFINE(str,ptr,tok)	;
	;
	N name S name=$$ATOM^%ZS(str,.ptr,"",tok)
	I '$$isVar^UCGM(name) D ERROR^UCGM("Variable name expected")
	;
	N expr S expr=""
	N atom
	F  Q:'(ptr>0)  D
	.	S atom=$$ATOM^%ZS(str,.ptr,"'+-*/\#_!&()",tok)
	.	I "'+-*/\#_!&()"[atom S expr=expr_atom Q 
	.	I $$isLit^UCGM(atom) S expr=expr_atom Q 
	.	I '($D(commands("DEFINE",atom))#2) D ERROR^UCGM("Invalid experession element: "_atom) S ptr=0 Q 
	.	S expr=expr_commands("DEFINE",atom)
	.	Q 
	;
	;  #ACCEPT Date=2006-04-25; PGM=FSCW; CR=20280; Group=XECUTE
	XECUTE "set commands(""DEFINE"",name)="_expr
	;
	Q "; "_str
	;
	; ---------------------------------------------------------------------
IF(m2src,lptr,str,ptr,tok)	;
	;
	N atom N cmdDel
	N cmdNum
	N isTrue
	;
	S atom=$$ATOM^%ZS(str,.ptr,";",tok)
	;
	; Find any extrinsic functions ($$) used in #IF
	I atom["$$" D
	.	N fatom N func
	.	N fptr
	.	;
	.	S fptr=0
	.	F  D  Q:fptr=0 
	..		S fatom=$$ATOM^%ZS(atom,.fptr,"+-*/\#_'=><[]&!?",tok,1)
	..		Q:$E(fatom,1,2)'="$$" 
	..		S func=$piece(fatom,"(",1)
	..		S func=$E(func,3,1048575)
	..		S sysmap("#IF","FUNC",func)=""
	..		Q 
	.	Q 
	S cmdDel=$S(ptr:$E(str,ptr+1),1:"") S cmdNum=0
	;
	S atom=$$condBool^UCGM(atom) I ER Q ""
	;
	D
	.	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	.	;
	.	;   #ACCEPT DATE=20060314;PGM=FSCW;CR=20280;GROUP=XECUTE
	.	XECUTE ("I "_atom) S isTrue=$T
	.	;
	.	I 'isTrue S ptr=0 ; Don't process the rest of the line
	.	;
	.	I isTrue S struct(7,subRou)=lptr
	.	I '(cmdDel=" ") D  ; #IF/#END[IF] block
	..		;
	..		S fCompile=fCompile+1
	..		S fCompile(fCompile)=isTrue_$char(9)_lptr
	..		;
	..		I 'isTrue D skip(.m2src,.lptr,"#IF")
	..		Q 
	.	Q 
	;
	Q ""
	;
	; ---------------------------------------------------------------------
INFO(str,ptr,tok)	;
	;
	N all S all=$$allWARN
	N atom S atom=$$getExpr(str,.ptr,tok,$$allWARN)
	N switch S switch=$$getSwitch(str,.ptr,tok,1)
	;
	D setCmds("INFO",atom,switch,all,.commands)
	;
	S ptr=0
	Q ""
	;
	; ---------------------------------------------------------------------
ELSE(m2src,lptr,ptr)	;
	;
	I $piece(fCompile(fCompile),$char(9)) D skip(.m2src,.lptr,"#ELSE")
	;
	Q ""
	;
	; ---------------------------------------------------------------------
END(ptr)	; Process #END or #ENDIF
	;
	K fCompile(fCompile)
	;
	S fCompile=fCompile-1
	S ptr=0
	;
	Q ""
	;
	; ---------------------------------------------------------------------
OPTIMIZE(str,ptr,tok)	;
	;
	N all S all=$$allOPTIMIZE
	N atom S atom=$$getExpr(str,.ptr,tok,all)
	N switch S switch=$$getSwitch(str,.ptr,tok,1)
	;
	D setCmds("OPTIMIZE",atom,switch,all,.commands)
	;
	S ptr=0
	Q "; "_str
	;
	; ---------------------------------------------------------------------
OPTION(str,ptr,tok)	;
	;
	N all S all=$$allOptions
	N atom S atom=$$getExpr(str,.ptr,tok,all)
	N switch S switch=$$getSwitch(str,.ptr,tok,1)
	;
	D setCmds("Options",atom,switch,all,.commands)
	;
	S ptr=0
	Q "; "_str
	;
	; ---------------------------------------------------------------------
WARN(str,ptr,tok)	;
	;
	N all S all=$$allWARN
	N atom S atom=$$getExpr(str,.ptr,tok,$$allWARN)
	N switch S switch=$$getSwitch(str,.ptr,tok,1)
	;
	D setCmds("WARN",atom,switch,all,.commands)
	;
	S ptr=0
	Q ""
	;
	; ---------------------------------------------------------------------
WHILE(m2src,lptr,str,ptr,tok)	;
	;
	N expr
	N ER N i N lptrb N lptre
	;
	; condition as PSL expression, and
	N atom S atom=$$ATOM^%ZS(str,.ptr,";",tok)
	N cmdDel S cmdDel=$S(ptr:$E(str,ptr+1),1:"")
	N cmdNum S cmdNum=0
	;
	S (lptrb,lptre)=lptr
	;
	I cmdDel="" S fCompile=fCompile+1 D skip(.m2src,.lptre,"#WHILE")
	;
	N bQuit S bQuit=0
	;
	F i=1:1:1000 D  I bQuit Q 
	.	;
	.	S ER=0
	.	S expr=$$condBool^UCGM(atom) I ER S bQuit=1 Q 
	.	;
	.	D
	..		N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap2^"_$T(+0)_""")"
	..		;    #ACCEPT DATE=20060314;PGM=FSCW;CR=20280;GROUP=XECUTE
	..		XECUTE "I "_expr
	..		E  S bQuit=1 Q 
	..		;
	..		S lptr=lptrb
	..		;
	..		I (lptr=lptre) D line^UCGM($E(m2src(lptr),ptr+1,1980)) Q 
	..		;
	..		F  S lptr=$order(m2src(lptr)) Q:(lptr'<lptre)  D line^UCGM(m2src(lptr)) I ER Q 
	..		Q 
	.	Q 
	S lptr=lptre
	;
	S ptr=0
	Q ""
	;
	; ---------------------------------------------------------------------
XECUTE(str,ptr,tok)	;
	;
	I $get(commands("boot","restrictionlevel"))>0 S ptr=0 Q ""
	I '$$ask(.str,.ptr,tok) Q ""
	;
	;  #ACCEPT DATE=2006-03-14;PGM=FSCW;CR=20280;GROUP=XECUTE
	I '(str="") XECUTE str
	;
	Q ""
	;
	; ---------------------------------------------------------------------
allOPTIMIZE()	; return list of all possible OPTIMIZE options
	Q "FUNCTIONS,OBJECTS"
	;
	; ---------------------------------------------------------------------
allOptions()	; return list of all possible Option options
	Q "$GetEFD,AllowGOTO,AutoPublicERRM,ResultClass"
	;
	; ---------------------------------------------------------------------
allWARN()	; return list of all possible WARN options
	Q "ACCESS,BYPASS,DATABASE,DEAD,DEPRECATED,DYNAMIC,FUNCTION,GLOBAL,LENGTH,MISMATCH,PRECEDENCE,PSLBOOT,READ,RECEXISTS,SCOPE,SYNTAX,SYSVAR,XECUTE"
	;
	; ---------------------------------------------------------------------
decode(line,commands)	; decompose a line
	;
	; declare and hide PUBLIC vars of all #command implementations
	N fCompile N RM N struct N sysmap
	N ER
	;
	N ptr S ptr=0
	N tok
	S line=$$TOKEN^%ZS(line,.tok)
	;
	N cmd S cmd=$$vStrUC($$ATOM^%ZS(line,.ptr,";"))
	;
	I $$isComment(cmd) Q 
	I (",#INFO,#OPTIMIZE,#OPTION,#WARN,"[(","_cmd_",")) S cmd=$$UCGMC(cmd,,0,line,ptr,tok) Q 
	;
	I cmd="#DEFINE" S cmd=$$DEFINE(line,ptr,tok) Q 
	;
	Q 
	;
	; ---------------------------------------------------------------------
decodeFile(sDir,sFil,cmds)	; decompose a file
	N rIO S rIO=$$vClNew("IO")
	S $P(vobj(rIO,1),"|",2)=sDir
	S $P(vobj(rIO,1),"|",1)=sFil
	S $P(vobj(rIO,1),"|",3)="READ"
	;
	N subRou S subRou=$P(vobj(rIO,1),"|",6) ; subRou for PSL.error()
	N lptr ; line pointer for PSL.error()
	D
	.	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap3^"_$T(+0)_""")"
	.	D open^UCIO(rIO,$T(+0),"decodeFile","rIO")
	.	F lptr=1:1 D decode($translate($$read^UCIO(rIO),$char(9)," "),.cmds)
	.	Q 
	K vobj(+$G(rIO)) Q 
	;
	; ---------------------------------------------------------------------
defOPTIMIZE()	; return list of default OPTIMIZE options
	Q $$allOPTIMIZE()
	;
	; ---------------------------------------------------------------------
defWARN()	; return list of default WARN options
	;
	N grp
	N wrn S wrn=$$allWARN()
	;
	F grp="FUNCTION,","READ," S wrn=$piece(wrn,grp)_$piece(wrn,grp,2)
	I %VN'>6.4 F grp="ACCESS,","DEPRECATED,","SCOPE," S wrn=$piece(wrn,grp)_$piece(wrn,grp,2)
	;
	Q wrn
	;
	; ---------------------------------------------------------------------
newTable	; deprecated method Schema.createTable()
	I $$rtIsRdb^UCXDD() D ERROR^UCGM("Schema.createTable() not supported for RDB") Q 
	D warnGroup^UCGM("DEPRECATED","Schema.createTable() - use predefined tables")
	;
	N table S table=$piece(actual(1),"""",2)
	;
	N keys S keys=actual(2)
	I $E(keys)="""" S keys=$E(keys,2,$L(keys)-1) ; Remove "
	S keys=$$QSUB^%ZS(keys,"""")
	;
	N columns S columns=actual(3)
	I $E(columns)="""" S columns=$E(columns,2,$L(columns)-1)
	;
	N global S global=actual(4)
	I $E(global)="""" S global=$E(global,2,$L(global)-1)
	I global="" S global="ZBCHTMP"
	I $L(global)>8 D ERROR^UCGM("Global name cannot exceed 8 characters") Q 
	;
	;  #ACCEPT DATE=2006-03-14;PGM=FSCW;CR=20280;GROUP=BYPASS
	;*** Start of code by-passed by compiler
	if $D(^DBTBL("SYSDEV",1,table)) D  I ER Q
	. N USER
	. S USER=$P(^DBTBL("SYSDEV",1,table,10),"|",11)
	. I USER=""!(USER="ZZZZZZ") Q
	. S RM="Invalid table name "_table
	. S ER=1 Q
	K ^DBTBL("SYSDEV",1,table)
	S ^DBTBL("SYSDEV",1,table,0)=global ; Global
	S ^(10)="124|PBS|0||||||||ZZZZZZ|5"
	S ^(12)="f"_table   ; File short name
	S ^(13)="",^(22)="",^(99)=""
	S ^(16)=keys    ; Access keys
	S ^(100)="^"_global_"("_keys_"|1||0" ; Global refenence, record type
	S ^(102)=keys
	;
	S lastkey=$P(keys,",",$L(keys,","))
	F i=1:1:$L(keys,",") D   ; Access keys
	. S di=$P(keys,",",i)
	. S ^DBTBL("SYSDEV",1,table,9,di)=i_"*|20|||||||T||S|||2|0|||||124|"
	I columns'="" F i=1:1:$L(columns,",") D  ; 12/16/98 BC
	. S di=$P(columns,",",i)
	. S ^DBTBL("SYSDEV",1,table,9,di)=lastkey_"|20|||||||T||S|||2|0|||||124|"_i
	;*** End of code by-passed by compiler ***
	;
	Q 
	;
	; ---------------------------------------------------------------------
delTable	; method Schema.deleteTable()
	I $$rtIsRdb^UCXDD() D ERROR^UCGM("Schema.deleteTable() not supported for RDB") Q 
	D warnGroup^UCGM("DEPRECATED","Schema.deleteTable() - use predefined tables")
	N table S table=$piece(actual(1),"""",2)
	I (table="") Q 
	;
	N sts
	;
	;  #ACCEPT DATE=2006-03-14;PGM=FSCW;CR=20280;GROUP=BYPASS
	;*** Start of code by-passed by compiler
	S sts=$G(^DBTBL("SYSDEV",1,table,10))
	;
	; Dummy file without audit information (created by createTable method)
	I $P(sts,"|",10)=""&($P(sts,"|",11)=""!($P(sts,"|",11)="ZZZZZZ"))&($P(sts,"|",12)=5) K ^DBTBL("SYSDEV",1,table) Q
	;*** End of code by-passed by compiler ***
	;
	D ERROR^UCGM("Invalid table name")
	Q 
	;
	; ---------------------------------------------------------------------
SetLit(mcode,atom,expr)	;
	N $ZT S $ZT="D XERROR^UCGMC(""LITERAL assignment"") ZG "_($ZL-1)
	;
	S cmdNum=cmdNum-1
	;
	I '($L((expr))+7'>1980) S expr=$$bigExpr(expr)
	;  #ACCEPT DATE=20060314;PGM=FSCW;CR=20280;GROUP=XECUTE
	E  XECUTE ("S expr="_expr)
	;
	D setInst^UCGM(atom,"",$$vBtsPslE(expr))
	;
	Q $E(mcode,1,$L(mcode)-2)
	;
	; ---------------------------------------------------------------------
splitCode(expr,extra,at,split)	;
	N y
	;
	F  D  Q:(expr="") 
	.	S y=$L($$vStrBLS(expr,1,1980-extra))
	.	;
	.	I '(at=""),y<$L(expr) F y=y:-1:247 Q:at[$E(expr,y) 
	.	;
	.	S split($order(split(""),-1)+1)=$E(expr,1,y)
	.	S expr=$E(expr,y+1,1048575)
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
XERROR(msg)	;
	D ERROR^UCGM($G(msg)_": "_$P($ZS,",",3,999))
	Q 
	;
	; ---------------------------------------------------------------------
ask(str,ptr,tok)	;
	;
	N atom
	N timeout S timeout=$get(%TO,60)
	N yn S yn=1
	;
	I ptr=0 S atom=""
	E  S atom=$E(str,ptr+2,1048575)
	;
	I $$vStrUC($piece(atom," "))="ASK" D
	.	;
	.	USE $P
	.	WRITE !,$$UNTOK^%ZS(str,tok)_" : "
	.	READ yn:timeout E  S yn=0
	.	;
	.	S atom=$piece(atom," ",2,$L(atom))
	.	S yn=$$vStrUC(yn)
	.	;
	.	I (yn="Y")!(yn="YES") S yn=1
	.	E  S yn=0
	.	;
	.	Q 
	S str=$$UNTOK^%ZS(atom,tok) S ptr=0
	Q yn
	;
	; ---------------------------------------------------------------------
bigExpr(expr)	; Execute an expression that's bigger than the M line length !!
	N tok N vox
	N sub
	;
	S expr=$$TOKEN^%ZS(expr,.tok)
	F  Q:'(expr[$char(0))  D
	.	S sub=$order(vox(""),-1)+1
	.	S vox(sub)=$$UNTOK^%ZS($char(0)_$piece(expr,$char(0),2)_$char(0),tok)
	.	S vox(sub)=$$QSUB^%ZS(vox(sub),"""")
	.	S expr=$piece(expr,$char(0),1)_"vox("_sub_")"_$piece(expr,$char(0),3,9999)
	.	Q 
	;
	;  #ACCEPT DATE=2006-03-14;PGM=FSCW;CR=20280;GROUP=XECUTE
	XECUTE ("S expr="_expr)
	;
	Q expr
	;
	; ---------------------------------------------------------------------
getExpr(str,ptr,tok,dft)	;
	I ptr=0 Q dft ; Default expression
	;
	N atom
	S atom=$$vStrUC($$ATOM^%ZS(str,.ptr,"",tok))
	;
	I $$isComment(atom) D  ; Hit a comment, use default
	.	;
	.	I ptr=0 S ptr=$L(str)
	.	S ptr=ptr-$L(atom)-1
	.	S atom=dft
	.	Q 
	Q atom
	;
	; ---------------------------------------------------------------------
getSwitch(str,ptr,tok,dft)	;
	N atom S atom=$$getExpr(str,.ptr,tok,dft)
	;
	I atom=0!(atom=1)
	E  I atom="ON" S atom=1
	E  I atom="OFF" S atom=0
	E  D ERROR^UCGM("Unknown Compiler Switch: "_atom)
	;
	Q atom
	;
	; ---------------------------------------------------------------------
isComment(expr)	;
	Q (expr=";")!(expr="//")!(expr="/*")
	;
	; ---------------------------------------------------------------------
setCmds(cls,vals,switch,valid,cmds)	;
	N elm N pos
	N val
	;
	I vals="*" S vals=valid
	;
	F elm=1:1:$S((vals=""):0,1:$L(vals,",")) D
	.	S val=$piece(vals,",",elm)
	.	S pos=$$vlstPos(valid,val,",",1)
	.	I pos>0 S cmds(cls,$piece(valid,",",pos))=switch
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
skip(m2src,lptr,cmd)	;
	;
	N atom N rec N tok
	N ptr N stop S stop=fCompile
	;
	F  S lptr=$order(m2src(lptr)) Q:lptr=""  D  I (fCompile<stop)!(stop=0) Q 
	.	;
	.	S ptr=1
	.	S rec=$$TOKEN^%ZS($translate(m2src(lptr),$char(9)," "),.tok)
	.	S atom=$$vStrUC($$ATOM^%ZS(rec,.ptr,";",.tok))
	.	;
	.	I atom="#END" S atom=$$END(.ptr) Q  ; #END
	.	I atom="#ENDIF" S atom=$$END(.ptr) Q  ; #ENDIF
	.	I atom="#ELSE",fCompile=stop S stop=0 Q 
	.	I atom="#IF" D  ; Nested #IF
	..		S atom=$$ATOM^%ZS(rec,.ptr,";",tok)
	..		I ptr=0!($E(rec,ptr+1)'=" ") S fCompile=fCompile+1
	..		Q 
	.	Q 
	;
	I (lptr="") S lptr=$order(m2src(""),-1) D ERROR^UCGM("Missing #END")
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ","ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ")
	; ----------------
	;  #OPTION ResultClass 0
vStrTrim(object,p1,p2)	; String.trim
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I p1'<0 S object=$$RTCHR^%ZFUNC(object,p2)
	I p1'>0 F  Q:$E(object,1)'=p2  S object=$E(object,2,1048575)
	Q object
	; ----------------
	;  #OPTION ResultClass 0
vBtsPslE(vVal)	; ByteString.toPSLExpression
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N bValid S bValid=0
	D
	.	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap4^"_$T(+0)_""")"  ; catch and ignore %GTM-E-BADCHAR exception
	.	S bValid=(vVal)?.ANP
	.	Q 
	I bValid,$$vStrIsNum((vVal)) Q vVal
	I bValid Q $$QADD^%ZS((vVal),"""")
	N vC
	N vE S vE="$C("_$ascii(vVal)
	F vC=2:1:$L(vVal) S vE=vE_","_$ascii(vVal,vC)
	Q vE_")"
	; ----------------
	;  #OPTION ResultClass 0
vStrBLS(vVal,vStart,vMax)	; String.byteLimitSubstring
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I '($D(vMax)#2) Q $E(vVal,vStart,1048575)
	Q $E(vVal,vStart,vStart+vMax-1)
	; ----------------
	;  #OPTION ResultClass 0
vlstPos(object,p1,p2,p3)	; List.position
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I p3 S object=$$vStrUC(object) S p1=$$vStrUC(p1)
	S object=p2_object_p2 S p1=p2_p1_p2
	I object'[p1 Q 0
	Q $L($piece(object,p1,1),p2)
	;
vClNew(vCls)	;	Create a new object
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)=vCls
	Q vOid
	;
vStrIsNum(vStr)	;	String.isNumber
	;
	Q vStr=+vStr
	;
vtrap1	;	Error trap
	;
	N ifEx S ifEx=$ZS
	D ERROR^UCGM(" Runtime exception in #IF: "_ifEx)
	Q 
	;
vtrap2	;	Error trap
	;
	N whileEx S whileEx=$ZS
	D ERROR^UCGM("Runtime exception in #WHILE: "_whileEx)
	S bQuit=1
	Q 
	;
vtrap3	;	Error trap
	;
	N xIO S xIO=$ZS
	I $P(xIO,",",3)'["OPEN" D close^UCIO(rIO)
	Q 
	;
vtrap4	;	Error trap
	;
	N vEx S vEx=$ZS
	Q 
