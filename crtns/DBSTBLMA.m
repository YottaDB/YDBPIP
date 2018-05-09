DBSTBLMA	; C-S-UTBL Table Maintenance Code Generator
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSTBLMA ****
	;
	; 11/08/2007 14:08 - chenardp
	;
	;
	; I18N=OFF
	;
	 S ER=0
	 S RM=""
	;
	N ID
	N CMPERR N CODE N pslcode N TAB N TBLLIST
	;
	S ID=1
	S TAB=$char(9)
	;
	D addcode(0,"DBSTBLMB(Number %ProcessMode, RecordDBTBL1 dbtbl1, String KEY())"_TAB_"// C-S-UTBL Table Maintenance Compiled Program")
	D addcode(1,"// Last compiled:  "_$$vdat2str($P($H,",",1),"MM/DD/YEAR")_" "_$$TIM^%ZM_" - "_$$USERNAM^%ZFUNC)
	D addcode(0,"")
	D addcode(1,"// THIS IS A COMPILED ROUTINE.  Compiled by procedure DBSTBLMA")
	D addcode(0,"")
	D addcode(1,"// See DBSTBLMA for argument definitions")
	D addcode(0,"")
	;
	; Get all appropriate tables and assign ID numbers
	N ds,vos1,vos3,vos2,vos4,vos6,vos5 S ds=$$vOpen1()
	;
	; If there are no results, just build in error return
	I '$G(vos1) D  Q 
	.	D addcode(1,"// No C-S-UTBL maintenance screens defined")
	.	D addcode(0,"")
	.	D addcode(1,"quit $$^MSG(7609)"_TAB_TAB_"// Invalid value")
	.	Q 
	;
	; Start building
	;
	D addcode(1,"type String ERMSG, SCREEN, TABLE")
	D addcode(0,"")
	;
	D addcode(1,"set SCREEN = dbtbl1.screen")
	D addcode(1,"set TABLE = dbtbl1.fid")
	D addcode(0,"")
	;
	; Assign IDs and build call section
	F  Q:'($$vFetch1())  D
	.	;
	.	N dbtbl1,vop1 S vop1=$P(ds,$C(9),2),dbtbl1=$G(^DBTBL($P(ds,$C(9),1),1,vop1))
	.	;
	.	S TBLLIST(ID)=vop1
	.	S CODE="if TABLE = """_vop1_""" set ERMSG = $$tm"_ID_"(%ProcessMode, .KEY(), SCREEN)"
	.	I ID>1 S CODE="else  "_CODE
	.	D addcode(1,CODE)
	.	S ID=ID+1
	.	Q 
	;
	D addcode(0,"")
	D addcode(1,"quit ERMSG")
	;
	; Build section for each table.
	;
	S ID=0
	F  S ID=$order(TBLLIST(ID)) Q:(ID="")  D
	.	;
	.	N I N KEYCNT
	.	N ACCKEYS N KEYLIST N KEYLISTG N TABLE
	.	;
	.	S TABLE=TBLLIST(ID)
	.	;
	.	N dbtbl1,vop2,vop3,vop4,vop5 S vop2="SYSDEV",vop3=TABLE,dbtbl1=$$vDb3("SYSDEV",TABLE)
	.	 S vop5=$G(^DBTBL(vop2,1,vop3,16))
	.	 S vop4=$G(^DBTBL(vop2,1,vop3,12))
	.	;
	.	D addcode(0,"")
	.	D addcode(0,"")
	.	D addcode(0,"tm"_ID_"(ProcMode, String KEY(), String SCREEN)  // "_TABLE_" - "_$P(dbtbl1,$C(124),1))
	.	D addcode(0,"")
	.	D addcode(1,"type Public String VFMQ")
	.	D addcode(0,"")
	.	D addcode(1,"type Number ER = 0")
	.	D addcode(1,"type String ERMSG, RM")
	.	D addcode(0,"")
	.	D addcode(1,"set (ERMSG, VFMQ) = """"")
	.	D addcode(0,"")
	.	;
	.	; Build access key list
	.	S KEYCNT=$$KEYINFO($P(vop5,$C(124),1),"","",.KEYLIST)
	.	S KEYLISTG=$$vStrRep(KEYLIST," AND",", ",0,0,"")
	.	;
	.	D addcode(1,"type Record"_TABLE_" "_$P(vop4,$C(124),1)_" = Db.getRecord("""_TABLE_""","""_KEYLISTG_""",1)")
	.	D addcode(0,"")
	.	D addcode(1,"#ACCEPT Date=03/04/07; Pgm=RussellDS; CR=25558; Group=MISMATCH")
	.	D addcode(1,"do DRV^USID(ProcMode, SCREEN, ."_$P(vop4,$C(124),1)_")")
	.	D addcode(1,"if 'ER, (VFMQ '= ""Q"") do {")
	.	D addcode(0,"")
	.	;
	.	D addcode(2,"if ProcMode < 2 do "_$P(vop4,$C(124),1)_".save()")
	.	D addcode(2,"if ProcMode = 3 do Db.delete("""_TABLE_""","""_KEYLIST_""")")
	.	D addcode(1,"}")
	.	D addcode(0,"")
	.	D addcode(1,"if ER set ERMSG = RM.get()")
	.	D addcode(0,"")
	.	D addcode(1,"quit ERMSG")
	.	Q 
	;
	D BLDLOWER(.pslcode)
	;
	; Build compiled routine
	D BUILDRTN^UCGM(.pslcode,"DBSTBLMB",.CMPERR)
	I $D(CMPERR) D
	.	;
	.	N N S N=""
	.	;
	.	F  S N=$order(CMPERR(N)) Q:N=""  D
	..		I 'ER S ER=1 S RM=CMPERR(N)
	..		WRITE CMPERR(N),!
	..		Q 
	.	Q 
	;
	;Completed at ~p1
	I 'ER S ER="W" S RM=$$^MSG(591,$$TIM^%ZM($P($H,",",2)))
	;
	Q 
	;
BLDLOWER(pslcode)	; Build lower level check section
	N vpc
	;
	N ID N keycnt
	N acckeys N CODE N fid N FID2 N key1 N SORT N SORT2 N TAB
	;
	S TAB=$char(9)
	;
	D addcode(0,"")
	D addcode(0,"")
	D addcode(0,"LOWERLVL(String fid, String KEY())  // Check tables at lower level")
	;
	N ds,vos1,vos3,vos2,vos4,vos5,vos6 S ds=$$vOpen2()
	;
	F  Q:'($$vFetch2())  D
	.	N dbtbl1,vop1,vop2,vop3,vop4 S vop1=$P(ds,$C(9),1),vop2=$P(ds,$C(9),2),dbtbl1=$G(^DBTBL(vop1,1,vop2))
	.	 S vop4=$G(^DBTBL(vop1,1,vop2,16))
	.	 S vop3=$G(^DBTBL(vop1,1,vop2,0))
	.	;
	.	S acckeys=$P(vop4,$C(124),1)
	.	S key1=$piece(acckeys,",",1)
	.	;
	.	S vpc=('$$isLit^UCGM(key1)) Q:vpc 
	.	S vpc=($L(acckeys,",")'>1) Q:vpc  ; Ignore single level entries
	.	;
	.	S key1=$P(vop3,$C(124),1)_"_"_key1
	.	S SORT(key1)=$get(SORT(key1))+1
	.	S SORT(key1,$L(acckeys,",")-1,vop2)=$piece(acckeys,",",2,99)
	.	Q 
	;
	; Ignore any *TBL tables that only have a single table associated with them
	; For the others, determine if there's a lower level overlap
	S (key1,keycnt)=""
	F  S key1=$order(SORT(key1)) Q:(key1="")  I SORT(key1)>1 D
	.	F  S keycnt=$order(SORT(key1,keycnt)) Q:(keycnt="")  D
	..		;
	..		N N
	..		;
	..		Q:($order(SORT(key1,keycnt))="")  ; No greater keys
	..		;
	..		S fid=""
	..		F  S fid=$order(SORT(key1,keycnt,fid)) Q:(fid="")  D
	...			;
	...			S acckeys=SORT(key1,keycnt,fid)
	...			;
	...			; Step through each higher key count table to see if key overlap
	...			S N=keycnt
	...			F  S N=$order(SORT(key1,N)) Q:(N="")  D
	....				;
	....				S FID2=""
	....				;
	....				F  S FID2=$order(SORT(key1,N,FID2)) Q:(FID2="")  D
	.....					;
	.....					N hit
	.....					N I
	.....					N ACCKEYS2
	.....					;
	.....					S ACCKEYS2=SORT(key1,N,FID2)
	.....					;
	.....					; If any literal keys, they need to be the same, otherwise,
	.....					; not part of same *TBL
	.....					;
	.....					S hit=1
	.....					F I=1:1:$L(acckeys,",") D  Q:'hit 
	......						;
	......						N X S X=$piece(acckeys,",",I)
	......						;
	......						; Mismatch on literal in fid
	......						I $$isLit^UCGM(X),$piece(ACCKEYS2,",",I)'=X S hit=0
	......						;
	......						; Mismatch on literal in FID2
	......						S X=$piece(ACCKEYS2,",",I)
	......						I $$isLit^UCGM(X),$piece(acckeys,",",I)'=X S hit=0
	......						Q 
	.....					;
	.....					I hit S SORT2(fid,FID2)="" ; FID2 is lower level of fid
	.....					Q 
	....				Q 
	...			Q 
	..		Q 
	.	Q 
	;
	; No lower level entries (unlikely, but ...)
	I '$D(SORT2) D  Q 
	.	D addcode(1,"// No tables with lower level tables defined")
	.	D addcode(0,"")
	.	D addcode(1,"quit 0")
	.	Q 
	;
	; Pass SORT2 and build code to perform test for data at lower level
	;
	D addcode(1,"type Boolean RETURN = 0")
	D addcode(0,"")
	;
	; Build call section
	S ID=1
	S fid=""
	F  S fid=$order(SORT2(fid)) Q:(fid="")  D
	.	;
	.	S CODE="if fid = """_fid_""" set RETURN = $$LL"_ID_"(.KEY())"
	.	I ID>1 S CODE="else  "_CODE
	.	D addcode(1,CODE)
	.	S SORT2(fid)=ID
	.	S ID=ID+1
	.	Q 
	;
	D addcode(0,"")
	D addcode(1,"quit RETURN")
	;
	; Build common select section -- need to use dymanic select to avoid
	; an excess of vFetch tags exceeding the limit
	D addcode(0,"")
	D addcode(0,"")
	D addcode(0,"LLSELECT(String SELECT, String FROM, String WHERE)")
	D addcode(0,"")
	D addcode(1,"type Public String KEY1, KEY2, KEY3, KEY4, KEY5, KEY6, KEY7, KEY8")
	D addcode(1,"#ACCEPT Date=09/21/04; PGM=Dan Russell; CR=unknown")
	D addcode(1,"type ResultSet rs = Db.select(SELECT, FROM, WHERE)")
	D addcode(0,"")
	D addcode(1,"if rs.next() quit 1")
	D addcode(0,"")
	D addcode(1,"quit 0")
	;
	; Build section for each table.
	S (fid,FID2)=""
	F  S fid=$order(SORT2(fid)) Q:(fid="")  D
	.	;
	.	N I
	.	;
	.	D addcode(0,"")
	.	D addcode(0,"")
	.	D addcode(0,"LL"_SORT2(fid)_"(String KEY())  // "_fid)
	.	D addcode(0,"")
	.	;
	.	N dbtblf1,vop5,vop6,vop7 S vop5="SYSDEV",vop6=fid,dbtblf1=$$vDb3("SYSDEV",fid)
	.	 S vop7=$G(^DBTBL(vop5,1,vop6,16))
	.	;
	.	S keycnt=$$KEYINFO($P(vop7,$C(124),1),fid)
	.	;
	.	F I=1:1:keycnt D addcode(1,"type String KEY"_I_" = KEY("_I_")")
	.	;
	.	F  S FID2=$order(SORT2(fid,FID2)) Q:(FID2="")  D
	..		;
	..		N X
	..		N select N where
	..		;
	..		N dbtblf2,vop8,vop9,vop10 S vop8="SYSDEV",vop9=FID2,dbtblf2=$$vDb3("SYSDEV",FID2)
	..		 S vop10=$G(^DBTBL(vop8,1,vop9,16))
	..		;
	..		S X=$$KEYINFO($P(vop10,$C(124),1),FID2,.select,.where)
	..		;
	..		; Just go for a match on the higher level table keys
	..		S select=$piece(select,",",1,keycnt)
	..		S where=$piece(where," AND ",1,keycnt)
	..		;
	..		; Replace KEY() array references with KEYn references
	..		F I=1:1:keycnt S where=$$vStrRep(where,"KEY("_I_")","KEY"_I,0,0,"")
	..		;
	..		D addcode(1,"if $$LLSELECT("""_select_""", """_FID2_""", """_where_""") quit 1")
	..		D addcode(0,"")
	..		Q 
	.	;
	.	D addcode(1,"quit 0")
	.	Q 
	;
	Q 
	;
KEYINFO(acckeys,fid,select,where)	;
	;
	N I N keycnt
	N key
	;
	I '($get(fid)="") S fid=fid_"."
	;
	S keycnt=0
	S (select,where)=""
	;
	S acckeys=$$TOKEN^%ZS(acckeys)
	F I=1:1:$L(acckeys,",") D
	.	;
	.	S key=$piece(acckeys,",",I)
	.	Q:key?1.N  ; Ignore numeric keys
	.	Q:$E(key,1)=$char(0)  ; Ignore literal strings
	.	;
	.	S keycnt=keycnt+1
	.	;
	.	; Note:  Append fid to avoid problems with column names,
	.	;   e.g., STBLIRSTAPE2.GROUOP
	.	S select=select_fid_key_","
	.	S where=where_fid_key_" = :KEY("_keycnt_") AND "
	.	Q 
	;
	S select=$E(select,1,$L(select)-1)
	S where=$E(where,1,$L(where)-5)
	;
	Q keycnt
	;
addcode(TABS,CODE)	;
	;
	N I N LINENO
	;
	S LINENO=$order(pslcode(""),-1)+1 ; Add to end
	;
	I TABS F I=1:1:TABS S CODE=$char(9)_CODE
	;
	S pslcode(LINENO)=CODE
	;
	Q 
	;
vSIG()	;
	Q "60694^72907^Dan Russell^11442" ; Signature - LTD^TIME^USER^SIZE
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
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ","ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ")
	;
vDb3(v1,v2)	;	voXN = Db.getRecord(DBTBL1,,0)
	;
	N dbtbl1
	S dbtbl1=$G(^DBTBL(v1,1,v2))
	I dbtbl1="",'$D(^DBTBL(v1,1,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1" X $ZT
	Q dbtbl1
	;
vOpen1()	;	%LIBS,FID FROM DBTBL1 WHERE %LIBS = 'SYSDEV' AND (GLOBAL = 'CTBL' OR GLOBAL = 'STBL' OR GLOBAL = 'UTBL') AND SCREEN IS NOT NULL AND FILETYP <> 5
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=0
vL1a2	S v=vos2,vos3=$$NPC^%ZS("CTBL,STBL,UTBL",.v,1),vos2=v I v=0 G vL1a0
	S vos4=""
vL1a4	S vos4=$O(^XDBREF("DBTBL1.GLOBAL","SYSDEV",vos3,vos4),1) I vos4="" G vL1a2
	S vos5=$G(^DBTBL("SYSDEV",1,vos4,10))
	S vos6=$G(^DBTBL("SYSDEV",1,vos4,22))
	I '($P(vos6,"|",8)'="") G vL1a4
	I '(+$P(vos5,"|",12)'=5) G vL1a4
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a4
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds="SYSDEV"_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen2()	;	%LIBS,FID FROM DBTBL1 WHERE %LIBS = 'SYSDEV' AND (GLOBAL = 'CTBL' OR GLOBAL = 'STBL' OR GLOBAL = 'UTBL') AND FILETYP <> 5 AND DFLAG <> 1
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=0
vL2a2	S v=vos2,vos3=$$NPC^%ZS("CTBL,STBL,UTBL",.v,1),vos2=v I v=0 G vL2a0
	S vos4=""
vL2a4	S vos4=$O(^XDBREF("DBTBL1.GLOBAL","SYSDEV",vos3,vos4),1) I vos4="" G vL2a2
	S vos5=$G(^DBTBL("SYSDEV",1,vos4,10))
	S vos6=$G(^DBTBL("SYSDEV",1,vos4,22))
	I '(+$P(vos5,"|",12)'=5) G vL2a4
	I '(+$P(vos6,"|",10)'=1) G vL2a4
	Q
	;
vFetch2()	;
	;
	;
	I vos1=1 D vL2a4
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds="SYSDEV"_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
