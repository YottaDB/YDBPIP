UCLABEL	; main entry: list labels of single routine
	;
	; **** Routine compiled from DATA-QWIK Procedure UCLABEL ****
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
	N rtn N z
	N labels
	;
	;  #ACCEPT CR=21101;DATE=2006-05-18;PGM=FSCW;GROUP=READ
	USE $p READ !,"Routine: ",rtn Q:(rtn="") 
	;
	D getLabels(rtn,.labels,0)
	;
	USE $p WRITE !
	N tag S tag=""
	F  S tag=$order(labels(tag)) Q:(tag="")  WRITE !,tag,?10,$$toPSL^UCPSLLR(labels(tag))
	WRITE !
	Q 
	;
	; ---------------------------------------------------------------------
getLabels(rtn,labels,bWithRtn)	;
	N src
	N res S res=$$getSrc(rtn,.src)
	;
	I res<2 D getLblRec^UCPSLLR(.src,$S(bWithRtn:rtn,1:""),0,.labels)
	;
	Q 
	;
	; ---------------------------------------------------------------------
getDQname(sig)	; DQ signature  /REQ/MECH=VAL
	Q $piece(sig," ",3)
	;
	; ---------------------------------------------------------------------
getDQsig(line)	; line of M code  /REQ/MECH=VAL
	I '$$isDQsig(line) Q ""
	Q $E(line,$F(line,"from DATA-QWIK")-9,1048575)
	;
	; ---------------------------------------------------------------------
getDQtype(sig)	; DQ signature  /REQ/MECH=VAL
	Q $piece(sig," ",2)
	;
	; ---------------------------------------------------------------------
getSrc(rtn,src)	;
	;
	I $E(rtn,1,3)="V01" Q 1
	I $E(rtn,1,3)="R01" Q 1
	;
	N file N rec
	N lnr N ret
	N DQname
	N %ZI N %ZR
	;
	S %ZI(rtn)=""
	D INT^%RSEL
	S file=$get(%ZR(rtn)) I (file="") Q 2
	;
	; try ".psl" first
	S file=file_rtn_".psl"
	N OK S OK=$$FILE^%ZOPEN(file,"READ",,32767)
	;
	; if .psl file present, use it right away
	I OK D
	.	;   #ACCEPT CR=21101;DATE=2006-05-18;PGM=FSCW;GROUP=READ
	.	F lnr=1:1 USE file Q:$ZEOF  READ src(lnr)
	.	CLOSE file
	.	S ret=0 S OK=0 ; use OK=0 to quit
	.	Q 
	E  D  ; find out the hard way ...
	.	S file=%ZR(rtn)_$translate(rtn,"%","_")_".m"
	.	S OK=$$FILE^%ZOPEN(file,"READ",,32767)
	.	S ret=2
	.	I 'OK Q 
	.	;
	.	S rec=$$validate(file)
	.	S lnr=0 S ret=1
	.	CLOSE file
	.	;
	.	S DQname=$piece(rec,"~",2)
	.	S rec=$piece(rec,"~",3)
	.	I rec="Procedure" D
	..		N dummy S dummy=$$getSrc^UCXDT25(DQname,.src,1)
	..		Q 
	.	E  I rec="Batch" D
	..		N rs,vos1,vos2,vos3,vos4,vos5  N V1 S V1=DQname S rs=$$vOpen1()
	..		F  Q:'($$vFetch1())  S lnr=lnr+1 S src(lnr)=rs
	..		;
	..		D
	...			N voZT set voZT=$ZT
	...			N lbl S lbl=""
	...			N lbls
	...			;
	...			N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	...			D labels^DBSBCH(.lbls)
	...			F  S lbl=$order(lbls(lbl)) Q:lbl=""  D
	....				S lnr=lnr+1 S src(lnr)=$piece(lbls(lbl),$C(9),2)_" "_lbl_$piece(lbls(lbl),$C(9),1)
	....				S lnr=lnr+1 S src(lnr)=" quit"
	....				Q 
	...			Q 
	..		;
	..		Q 
	.	E  D  ; anything else, use M routine
	..		N access N code
	..		S OK=$$FILE^%ZOPEN(file,"READ",,32767)
	..		USE file
	..		F lnr=1:1 Q:$ZEOF  D
	...			;     #ACCEPT CR=21101;DATE=2006-05-18;PGM=FSCW;GROUP=READ
	...			READ src(lnr)
	...			I " "[$E($translate(src(lnr),$char(9)," "),1) Q 
	...			S access="public"
	...			I src(lnr)[";" D
	....				S code=$piece($$vStrLC($$vStrTrim($piece(src(lnr),";",2),-1," "),0)," ")
	....				I (",local,private,public,"[(","_code_",")),$piece($$vStrTrim(code,0," "),"(")'[" " S access=code
	....				Q 
	...			S src(lnr)=access_" "_src(lnr)
	...			Q 
	..		CLOSE file
	..		Q 
	.	Q  ; end if .psl else
	Q ret
	;
	; ---------------------------------------------------------------------
isDQsig(line)	; line of M code  /REQ/MECH=VAL
	I $translate(line,$char(9)," ")'?1." "1";".E Q 0 ; not comment-only
	I line[" from DATA-QWIK " Q 1 ; DQ signature
	Q ""
	;
	; ---------------------------------------------------------------------
validate(file)	; name of file    /REQ/MECH=VAL
	;
	N rec
	N OK S OK=""
	;
	;  #ACCEPT CR=21101;DATE=2006-05-18;PGM=FSCW;GROUP=READ
	F  USE file Q:$ZEOF  READ rec S OK=$$isDQsig(rec) I '(OK="") Q 
	I OK S rec=$$getDQsig(rec) Q "1~"_$$getDQname(rec)_"~"_$$getDQtype(rec)
	;
	Q 0
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
vStrLC(vObj,v1)	; String.lowerCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	S vObj=$translate(vObj,"ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖØÙÚÛÜİŞ","abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïğñòóôõöøùúûüış")
	I v1 S vObj=$$vStrUC($E(vObj,1))_$E(vObj,2,1048575)
	Q vObj
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïğñòóôõöøùúûüış","ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏĞÑÒÓÔÕÖØÙÚÛÜİŞ")
	;
vOpen1()	;	CODE FROM DBTBL33D WHERE %LIBS='SYSDEV' AND BCHID = :V1
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(V1) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^DBTBL("SYSDEV",33,vos2,vos3),1) I vos3="" G vL1a0
	S vos4=""
vL1a5	S vos4=$O(^DBTBL("SYSDEV",33,vos2,vos3,vos4),1) I vos4="" G vL1a3
	Q
	;
vFetch1()	;
	;
	I vos1=1 D vL1a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos5=$G(^DBTBL("SYSDEV",33,vos2,vos3,vos4))
	S rs=$P(vos5,$C(12),1)
	;
	Q 1
	;
vtrap1	;	Error trap
	;
	N ignore S ignore=$ZS
	I $P(ignore,",",3)'["%GTM-E-LABEL" D
	.					S $ZS=ignore X voZT
	.					Q 
	Q 
