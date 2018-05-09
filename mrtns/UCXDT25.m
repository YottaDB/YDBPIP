	; I18N=QUIT
	;
	; **** Routine compiled from DATA-QWIK Procedure UCXDT25 ****
	;
	; 09/10/2007 17:32 - chenardp
	;
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
	; ---------------------------------------------------------------------
cmpStamp()	;
	Q ($$vdat2str($P($H,",",1),"MM/DD/YEAR"))_" "_($ZD(","_$P($H,",",2),"24:60"))_" - "_$$USERNAM^%ZFUNC
	;
	; ---------------------------------------------------------------------
copyright()	;
	N line S line=" //;Copyright(c)"_($$vdat2str($P($H,",",1),"YEAR"))
	S line=line_" Fidelity National Information Services, Inc.  All Rights Reserved"
	;
	Q line_" - "_$$cmpStamp()
	;
	; ---------------------------------------------------------------------
getSrc(proc,src,level)	;
	;
	N ret S ret=""
	S proc=$$vStrUC(proc)
	;
	D
	.	N voZT set voZT=$ZT
	.	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	.	;
	.	N rec S rec=$$vDb2("SYSDEV",proc)
	.	S ret=$P(rec,$C(124),2)
	.	;
	.	N rs,vos1,vos2,vos3,vos4  N V1 S V1=proc S rs=$$vOpen1()
	.	N ln S ln=1
	.	;
	.	I level>0,$$vFetch1() D
	..		N code S code=$translate(rs,$C(9)," ")
	..		N bOk S bOk=$$isLabel(code,ret)
	..		I bOk S src(1)=code
	..		E  S src(1)=ret_" // DQ Procedure "_proc_" - "_$P(rec,$C(124),1)
	..		;
	..		I level>1,$L(src(1),"(")=$L(src(1),")") S ln=ln+1 S src(ln)=$$copyright()
	..		;
	..		I 'bOk S ln=ln+1 S src(ln)=code
	..		Q  
	.	;
	.	F  Q:'($$vFetch1())  S ln=ln+1 S src(ln)=$translate(rs,$C(9)," ")
	.	Q  
	;
	Q ret
	;
	; ---------------------------------------------------------------------
isLabel(cod,lbl)	;
	I (cod="") Q 0
	I $E(cod,1)=" " Q 0
	;
	N p0 S p0=$piece(cod," ")
	N p1 S p1=$$vStrLC(p0,0)
	I p1="private" Q $$isLabel($E(cod,9,1048575),lbl)
	I p1="public" Q $$isLabel($E(cod,8,1048575),lbl)
	I p1="local" Q $$isLabel($E(cod,7,1048575),lbl)
	;
	Q $piece(p0,"(")=lbl
	;
	; ---------------------------------------------------------------------
isProc(UNIT)	; name of unit
	;
	N V1 S V1=$$vStrUC(UNIT) Q ($D(^DBTBL("SYSDEV",25,V1))#2)
	; ----------------
	;  #OPTION ResultClass 0
vdat2str(object,mask)	; Date.toString
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I (object="") Q ""
	I (mask="") S mask="MM/DD/YEAR"
	N cc N lday N lmon
	I mask="DL"!(mask="DS") D  ; Long or short weekday
	.	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
	.	I (cc="") S cc="US"
	.	S lday=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
	.	S mask="DAY" ; Day of the week
	.	Q 
	I mask="ML"!(mask="MS") D  ; Long or short month
	.	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
	.	I (cc="") S cc="US"
	.	S lmon=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
	.	S mask="MON" ; Month of the year
	.	Q 
	Q $ZD(object,mask,$get(lmon),$get(lday))
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïğñòóôõöøùúûüış","ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖØÙÚÛÜİŞ")
	; ----------------
	;  #OPTION ResultClass 0
vStrLC(vObj,v1)	; String.lowerCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	S vObj=$translate(vObj,"ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖØÙÚÛÜİŞ","abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïğñòóôõöøùúûüış")
	I v1 S vObj=$$vStrUC($E(vObj,1))_$E(vObj,2,1048575)
	Q vObj
	;
vDb2(v1,v2)	;	voXN = Db.getRecord(DBTBL25,,0)
	;
	N rec
	S rec=$G(^DBTBL(v1,25,v2))
	I rec="",'$D(^DBTBL(v1,25,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL25" X $ZT
	Q rec
	;
vOpen1()	;	CODE FROM DBTBL25D WHERE %LIBS='SYSDEV' AND PROCID = :V1
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(V1) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^DBTBL("SYSDEV",25,vos2,vos3),1) I vos3="" G vL1a0
	Q
	;
vFetch1()	;
	;
	I vos1=1 D vL1a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos4=$G(^DBTBL("SYSDEV",25,vos2,vos3))
	S rs=$P(vos4,$C(12),1)
	;
	Q 1
	;
vtrap1	;	Error trap
	;
	N xcpt S xcpt=$ZS
	I $P(xcpt,",",3)["%PSL-E-RECNOFL" Q 
	S $ZS=xcpt X voZT
	Q 
