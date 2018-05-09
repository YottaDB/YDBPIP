SCAUTL	;
	;
	; **** Routine compiled from DATA-QWIK Procedure SCAUTL ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	;
	; I18N=QUIT
	;
	Q 
	;
NOISO	; Public; Specify NoIsolation
	;
	D NOISO^SCADRV0
	Q 
	;
TRACE(beg,max,del,zsh,dev,expr,varlist)	; Trace M code
	;
	N arg N tag
	;
	S beg=$get(beg)
	S max=$get(max)
	S del=$get(del)
	S zsh=$get(zsh)
	S dev=$get(dev)
	S expr=$get(expr)
	S varlist=$get(varlist)
	;
	I (beg="") Q 
	I ($piece(beg,"^",1)="") S $piece(beg,"^",1)=$piece(beg,"^",2)
	;
	S tag="$T("_beg_")=""""" I @tag Q 
	;
	; Defaults
	I 'del S del=1
	I (zsh="") S zsh="*"
	I expr'="" S expr=expr_" "
	;
	I (dev="") S dev=$$FILE^%TRNLNM("mtrace_"_$J_".dat","SCAU$SPOOL")
	I '$$FILE^%ZOPEN(dev,"WRITE/NEWV",2,1024) Q 
	;
	K ^TMPTRACE($J)
	K ^TMPTRACE($J)
	;
	N tmptrc,vop1,vop2 S tmptrc="",vop1="",vop2=0
	;
	S vop1=$J
	S $P(tmptrc,$C(124),1)=beg
	S $P(tmptrc,$C(124),2)=max
	S $P(tmptrc,$C(124),3)=del
	S $P(tmptrc,$C(124),4)=zsh
	S $P(tmptrc,$C(124),5)=dev
	;
	I varlist'="" D
	.	N str N var
	.	;
	. S $P(tmptrc,$C(124),6)=varlist
	.	;
	.	S str=varlist
	.	F  S var=$$var(.str) Q:(var="")  D
	..		;
	..		N tmptrcv,vop3,vop4,vop5 S tmptrcv="",vop4="",vop3="",vop5=0
	..		;
	..	 S vop4=$J
	..	 S vop3=var
	..	 S $P(tmptrcv,$C(124),1)="<Unknown>"
	..		;
	..	 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^TMPTRACE(vop4,vop3)=$$RTBAR^%ZFUNC(tmptrcv) S vop5=1 Tcommit:vTp  
	..		Q 
	.	Q 
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^TMPTRACE(vop1)=$$RTBAR^%ZFUNC(tmptrc) S vop2=1 Tcommit:vTp  
	;
	;  #ACCEPT Date=04/04/07; Pgm=RussellDS; CR=25675; Group=BYPASS
	;*** Start of code by-passed by compiler
	set $zstep=" quit:$$trace^SCAUTL($zpos)=0  zstep into"
	set arg=$$QADD^%ZS(expr_"zbreak -"_beg_$zstep)
	zbreak @(beg_":"_arg_":"_del)
	;*** End of code by-passed by compiler ***
	;
	Q 
	;
trace(%Ztag)	; Execute trace
	;
	N %Zcnt N %Zmax N %Zzlv
	N %Z N %Zdev N %Zpos N %Zref N %Zvar N %Zzio N %Zzsh
	;
	S %Zzio=$I
	S %Zref=$REFERENCE
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	;
	N tmptrc S tmptrc=$$vDb1($J)
	;
	S %Zcnt=$P(vobj(tmptrc),$C(124),8)
	S %Zdev=$P(vobj(tmptrc),$C(124),5)
	S %Zmax=$P(vobj(tmptrc),$C(124),2)
	S %Zpos=$P(vobj(tmptrc),$C(124),1)
	S %Zvar=$P(vobj(tmptrc),$C(124),6)
	S %Zzlv=$P(vobj(tmptrc),$C(124),7)
	S %Zzsh=$P(vobj(tmptrc),$C(124),4)
	;
	S %Zcnt=%Zcnt+1
	I $$zlevel<%Zzlv S $zstep="" D exit(.tmptrc) D naked(%Zref) K vobj(+$G(tmptrc)) Q 0
	I %Zmax,%Zcnt>%Zmax S $zstep="" D exit(.tmptrc) D naked(%Zref) K vobj(+$G(tmptrc)) Q 0
	;
	I %Zvar'="" D varlist(.%Zvar)
	USE %Zdev D output(%Zcnt,%Zpos,%Zvar,%Zzsh) USE %Zzio
	;
	S $P(vobj(tmptrc),$C(124),8)=%Zcnt
	S $P(vobj(tmptrc),$C(124),1)=%Ztag
	I (%Zzlv="") S $P(vobj(tmptrc),$C(124),7)=$$zlevel
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^TMPTRACE(vobj(tmptrc,-3))=$$RTBAR^%ZFUNC(vobj(tmptrc)) S vobj(tmptrc,-2)=1 Tcommit:vTp  
	;
	D naked(%Zref)
	K vobj(+$G(tmptrc)) Q 1
	;
output(%Zcnt,%Zpos,%Zvar,%Zzsh)	; Print trace information to output device
	;
	I %Zcnt=1 D zshow(%Zzsh)
	;
	;  #ACCEPT Date=04/04/07; Pgm=RussellDS; CR=25675; Group=BYPASS
	;*** Start of code by-passed by compiler
	write !,%Zcnt,$C(9),%Zpos,$C(9) zprint @%Zpos
	;*** End of code by-passed by compiler ***
	;
	I %Zvar'="" D
	.	N %Z
	.	;
	.	S %Z=""
	.	F  S %Z=$order(%Zvar(%Z)) Q:(%Z="")  WRITE $char(9),%Zvar(%Z),!
	.	Q 
	Q 
	;
zlevel()	; Return $zlevel
	;
	N zlevel
	;
	S zlevel="set zlevel=$zlevel"
	;  #ACCEPT Date=08/08/2006;PGM=Pete Chenard;CR=UNKNOWN;GROUP=XECUTE
	XECUTE "set zlevel=$zlevel"
	Q zlevel-2
	;
zshow(%Zzsh)	; ZSHOW information
	;
	;  #ACCEPT Date=07/15/2003;PGM=Allan Mattson;CR=UNKNOWN
	N %Zcnt N %Zmax
	;
	;  #ACCEPT Date=07/15/2003;PGM=Allan Mattson;CR=UNKNOWN
	N %Z N %Zdev N %Zpos N %Zvar N %Zzio N %Zzlv
	;
	;  #ACCEPT Date=04/04/07; Pgm=RussellDS; CR=25675; Group=BYPASS
	;*** Start of code by-passed by compiler
	write ! zshow %Zzsh
	;*** End of code by-passed by compiler ***
	;
	Q 
	;
varlist(%ZLIST)	; Display value of local variables
	;
	N %ZVAL N %ZVAR
	;
	S %ZVAR=""
	;
	N rstmp,vos1,vos2,vos3  N V1 S V1=$J S rstmp=$$vOpen1()
	;
	F  Q:'($$vFetch1())  D
	.	;
	.	S %ZVAR=rstmp
	.	;
	.	N tmptrcv,vop1,vop2,vop3 S vop2=$J,vop1=%ZVAR,tmptrcv=$$vDb3($J,%ZVAR,.vop3)
	.	;
	.	S %ZVAL=$get(@%ZVAR,"<Undefined>")
	.	I %ZVAL=$P(tmptrcv,$C(124),1) Q 
	. S $P(tmptrcv,$C(124),1)=%ZVAL
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^TMPTRACE(vop2,vop1)=$$RTBAR^%ZFUNC(tmptrcv) S vop3=1 Tcommit:vTp  
	.	S %ZLIST(%ZVAR)="["_%ZVAR_"="_%ZVAL_"]"
	.	Q 
	Q 
	;
var(str)	;
	;
	N v
	;
	S v=$piece(str,",",1)
	;
	I v["(" D
	.	N x S x=0
	.	F  S x=$F(str,")",x) Q:x=0  S v=$E(str,1,x-1) I $L(v,"""")#2 Q 
	.	Q 
	;
	S str=$E(str,$F(str,v)+1,1048575)
	Q v
	;
exit(tmptrc)	; Exit trace
	;
	N dev N zsh
	;
	S dev=$P(vobj(tmptrc),$C(124),5)
	S zsh=$P(vobj(tmptrc),$C(124),4)
	;
	K ^TMPTRACE($J)
	K ^TMPTRACE($J)
	;
	USE dev D zshow(zsh)
	CLOSE dev
	Q 
	;
naked(gblref)	; Re-set naked reference
	;
	I (gblref="") Q 
	I $piece($ZVERSION,"GT.M V",2)<4.3 Q 
	;
	;  #ACCEPT Date=08/08/2006;PGM=Pete Chenard; CR=UNKNOWN; GROUP=BYPASS
	;*** Start of code by-passed by compiler
	if $D(@$REFERENCE)
	;*** End of code by-passed by compiler ***
	Q 
	;
ZT(%Zzio,%Zref)	; Error trap
	;
	D naked(%Zref)
	S $zstep=""
	USE %Zzio
	Q 
	;
UPPER(str)	; Convert string to upper case
	;
	Q $$vStrUC(str)
	;
LOWER(str)	; Convert string to lower case
	;
	Q $$vStrLC(str,0)
	;
vSIG()	;
	Q "60739^33854^Dan Russell^8432" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ","ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ")
	; ----------------
	;  #OPTION ResultClass 0
vStrLC(vObj,v1)	; String.lowerCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	S vObj=$translate(vObj,"ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ","abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ")
	I v1 S vObj=$$vStrUC($E(vObj,1))_$E(vObj,2,1048575)
	Q vObj
	;
vDb1(v1)	;	vobj()=Db.getRecord(TMPTRACE,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordTMPTRACE"
	S vobj(vOid)=$G(^TMPTRACE(v1))
	I vobj(vOid)="",'$D(^TMPTRACE(v1))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,TMPTRACE" X $ZT
	S vobj(vOid,-3)=v1
	Q vOid
	;
vDb3(v1,v2,v2out)	;	voXN = Db.getRecord(TMPTRACEV,,0,-2)
	;
	N tmptrcv
	S tmptrcv=$G(^TMPTRACE(v1,v2))
	I tmptrcv="",'$D(^TMPTRACE(v1,v2))
	S v2out=1
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,TMPTRACEV" X $ZT
	Q tmptrcv
	;
vOpen1()	;	VAR FROM TMPTRACEV WHERE PID=:V1
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(V1) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^TMPTRACE(vos2,vos3),1) I vos3="" G vL1a0
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
	S rstmp=$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vtrap1	;	Error trap
	;
	N Error S Error=$ZS
	D ZT^SCAUTL(%Zzio,%Zref)
	Q 
