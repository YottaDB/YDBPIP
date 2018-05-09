DBSDEUTB	; General Purpose Screen Driver
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSDEUTB ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	; I18N=OFF
	;
	N pgm N sid N sidarray
	N ID S ID=0
	N i
	N ds,vos1,vos2,vos3 S ds=$$vOpen1()
	;
	F  Q:'($$vFetch1())  D
	.	N scatbl S scatbl=$G(^SCATBL(1,ds))
	.	S pgm=$P(scatbl,$C(124),4)
	.	S sid=$piece($piece(pgm,",",2),")",1)
	.	S sid=$$QSUB^%ZS(sid,"""")
	.	I (sid="") Q 
	.	 N V1 S V1=sid I '($D(^DBTBL("SYSDEV",2,V1))) Q 
	.	S sidarray(sid)=""
	.	Q 
	;
	S sidarray("DBTBL25")="" ; DQ Procedure Screen
	;
	 S ER=0
	 S RM=""
	;
	N CMPERR N CODE N FILES N pfid N pslcode N TAB N TBLLIST
	;
	S ID=1
	S TAB=$char(9)
	;
	D addcode(0,"private DBSDEUTA(String SID, Number ProcMode, String KEY(),String FPRE)"_TAB_"// Generic Screen Driver")
	D addcode(1,"// Last compiled:  "_$$vdat2str($P($H,",",1),"MM/DD/YEAR")_" "_$$TIM^%ZM_" - "_$$USERNAM^%ZFUNC)
	D addcode(0,"")
	D addcode(1,"// THIS IS A COMPILED ROUTINE.  Compiled by procedure DBSDEUTB")
	D addcode(0,"")
	D addcode(1,"// See DBSDEUTB for argument definitions")
	D addcode(0,"")
	;
	D addcode(1,"type String ERMSG, SCREEN, TABLE")
	D addcode(1,"set FPRE = FPRE.get()")
	D addcode(0,"")
	D addcode(0,"")
	;
	; Assign IDs and build call section
	S sid=""
	S ID=0
	F  S sid=$order(sidarray(sid)) Q:(sid="")  D
	.	;
	.	S ID=ID+1
	.	S CODE="if SID = """_sid_""" quit $$gf"_ID_"(ProcMode, .KEY(), FPRE)"
	.	I (ID>1) S CODE="else  "_CODE
	.	D addcode(1,CODE)
	.	Q 
	;
	D addcode(0,"")
	D addcode(1,"quit ""Screen ""_SID_"" not permitted to run via this function""")
	D addcode(0,"")
	D addcode(1,"// Generic Functions for each screen")
	;
	; Build section for each screen.
	;
	S ID=0
	S sid=""
	F  S sid=$order(sidarray(sid)) Q:(sid="")  D
	.	;
	.	N I N KEYCNT
	.	N ACCKEYS N fid N KEYLIST N KEYLISTA N KEYLISTG N objects N objparms N TABLE
	.	;
	.	D addcode(0,"")
	.	D addcode(0,"")
	.	;
	.	N dbtbl2,vop1,vop2,vop3 S vop1="SYSDEV",vop2=sid,dbtbl2=$$vDb4("SYSDEV",sid)
	.	 S vop3=$G(^DBTBL(vop1,2,vop2,0))
	.	S ID=ID+1
	.	;
	.	D addcode(0,"")
	.	D addcode(0,"")
	.	D addcode(0,"gf"_ID_"(ProcMode, String KEY(), String FPRE)  // "_sid_" - "_$P(vop3,$C(124),9))
	.	D addcode(0,"")
	.	D addcode(1,"type Public String VFMQ")
	.	D addcode(0,"")
	.	D addcode(1,"type Number ER = 0")
	.	D addcode(1,"type String ERMSG, RM")
	.	D addcode(0,"")
	.	D addcode(1,"set (ERMSG, RM, VFMQ) = """"")
	.	D addcode(0,"")
	.	;
	.	S pfid=$piece($P(vop3,$C(124),1),",",1) ; primary file def
	.	 N V1 S V1=pfid I '($D(^DBTBL("SYSDEV",1,V1))) D  Q 
	..		D addcode(1,"set ER=1")
	..		D addcode(1,"quit ""Invalid Table: "_pfid_"""")
	..		Q 
	.	;
	.	N dbtbl1,vop4,vop5,vop6,vop7 S vop4="SYSDEV",vop5=pfid,dbtbl1=$$vDb5("SYSDEV",pfid)
	.	 S vop7=$G(^DBTBL(vop4,1,vop5,16))
	.	 S vop6=$G(^DBTBL(vop4,1,vop5,12))
	.	;
	.	; Build access key list
	.	S KEYCNT=$$KEYINFO($P(vop7,$C(124),1),"","",.KEYLIST)
	.	S KEYLISTG=$$vStrRep(KEYLIST," AND",", ",0,0,"")
	.	;
	.	D addcode(1,"type RecordDBTBL2 dbtbl2 = Db.getRecord(""DBTBL2"",""LIBS='SYSDEV',SID='"_sid_"'"",1)")
	.	D addcode(1,"if 'dbtbl2.getMode() set ER = 1,ERMSG=""Invalid Screen Name"" quit ERMSG")
	.	D addcode(1,"if 'dbtbl2.cscmp set ER = 1, ERMSG = ""Screen must be converted to PSL"" quit ERMSG")
	.	;
	.	S FILES=$P(vop3,$C(124),1)
	.	S objects=""
	.	;
	.	S objects=objects_",."_$P(vop6,$C(124),1)
	.	S objparms=objects
	.	D addcode(1,"type Record"_pfid_" "_$P(vop6,$C(124),1)_" = Db.getRecord("""_pfid_""","""_KEYLISTG_""",1)")
	.	;
	.	I $L(FILES,",")>1 D  ; instantiate descending level tables
	..		;
	..		D addcode(1,"type Number i")
	..		;
	..		F i=2:1:$L(FILES,",") D
	...			;
	...			N keylista N X
	...			;
	...			S fid=$piece(FILES,",",i)
	...			N dbtbl1a,vop8,vop9,vop10,vop11 S vop8="SYSDEV",vop9=fid,dbtbl1a=$$vDb5("SYSDEV",fid)
	...			 S vop10=$G(^DBTBL(vop8,1,vop9,12))
	...			 S vop11=$G(^DBTBL(vop8,1,vop9,16))
	...			S objects=objects_",."_$P(vop10,$C(124),1)
	...			S objparms=objparms_",."_$P(vop10,$C(124),1)_"()"
	...			S X=$$KEYINFO($P(vop11,$C(124),1),"","",.keylista)
	...			S KEYLISTA(fid)=$piece(keylista," AND ",1,KEYCNT)
	...			D addcode(1,"type Record"_fid_" "_$P(vop10,$C(124),1)_"()")
	...			D addcode(1,"set i = 0")
	...			D addcode(1,"type DbSet ds"_i_" = Db.selectDbSet("""_fid_""","""_KEYLISTA(fid)_""")")
	...			D addcode(1,"while ds"_i_".next() do {")
	...			D addcode(2,"set i = i + 1")
	...			D addcode(2,"set "_$P(vop10,$C(124),1)_"(i) = ds"_i_".getRecord()")
	...			D addcode(1,"}")
	...			Q 
	..		Q 
	.	;
	.	I $E(objects,1)="," D
	..		S objects=$E(objects,2,9999)
	..		S objparms=$E(objparms,2,9999)
	..		Q 
	.	;
	.	D addcode(1,"#ACCEPT Date=03/04/07; Pgm=RussellDS; CR=25558; Group=MISMATCH")
	.	D addcode(1,"do DRV^USID(ProcMode, """_sid_""", "_objparms_")")
	.	D addcode(0,"")
	.	D addcode(1,"if 'ER, (VFMQ '= ""Q"") do {")
	.	D addcode(0,"")
	.	D addcode(2,"#ACCEPT Date=01/20/05;PGM=Screen Compiler;CR=14146")
	.	D addcode(2,"if 'FPRE.isNull() xecute FPRE if ER quit")
	.	D addcode(0,"")
	.	N objptr
	.	S objptr=$E($piece(objects,",",1),2,9999)
	.	D addcode(2,"if ProcMode < 2,"_objptr_".isChanged() do "_objptr_".save()")
	.	D addcode(2,"if ProcMode = 3 do Db.delete("""_$piece(FILES,",",1)_""","""_KEYLIST_""")")
	.	;
	.	; Now save all repeat region objects to disk
	.	F i=2:1:$L(objects,",") D
	..		;
	..		N bkey N fid N keys N objptr
	..		;
	..		I (i=2) D addcode(2,"type Number done")
	..		;
	..		S fid=$piece(FILES,",",i)
	..		D fsn^DBSDD(.fsn,fid)
	..		S keys=$piece(fsn(fid),"|",3)
	..		S bkey=$piece(keys,",",$L(keys,",")) ;bottom level key
	..		;
	..		S objptr=$E($piece(objects,",",i),2,9999)
	..		; delete all rows first, then refresh database from object array
	..		D addcode(2,"do Db.delete("""_$piece(FILES,",",i)_""","""_KEYLISTA($piece(FILES,",",i))_""")")
	..		D addcode(2,"set done = 0")
	..		D addcode(2,"set i = """"")
	..		D addcode(2,"for  set i = "_objptr_"(i).order() quit:i.isNull()  do {")
	..		D addcode(3,"if "_objptr_"(i)."_$$vStrLC(bkey,0)_" = """" quit")
	..		D addcode(3,"if ProcMode < 2 do "_objptr_"(i).setMode(0) do "_objptr_"(i).save()")
	..		D addcode(3,"if ProcMode = 3 do Db.delete("""_$piece(FILES,",",i)_""","""_KEYLISTA($piece(FILES,",",i))_""")")
	..		D addcode(2,"}")
	..		Q 
	.	;
	.	D addcode(1,"}")
	.	D addcode(0,"")
	.	D addcode(1,"if ER set ERMSG = RM.get()")
	.	D addcode(0,"")
	.	D addcode(1,"quit ERMSG")
	.	Q 
	;
	D BUILDRTN^UCGM(.pslcode,"DBSDEUTA",.CMPERR)
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
	Q "60694^72958^Dan Russell^10582" ; Signature - LTD^TIME^USER^SIZE
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
vStrLC(vObj,v1)	; String.lowerCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	S vObj=$translate(vObj,"ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ","abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ")
	I v1 S vObj=$$vStrUC($E(vObj,1))_$E(vObj,2,1048575)
	Q vObj
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
vDb4(v1,v2)	;	voXN = Db.getRecord(DBTBL2,,0)
	;
	N dbtbl2
	S dbtbl2=$G(^DBTBL(v1,2,v2))
	I dbtbl2="",'$D(^DBTBL(v1,2,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL2" X $ZT
	Q dbtbl2
	;
vDb5(v1,v2)	;	voXN = Db.getRecord(DBTBL1,,0)
	;
	N dbtbl1
	S dbtbl1=$G(^DBTBL(v1,1,v2))
	I dbtbl1="",'$D(^DBTBL(v1,1,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1" X $ZT
	Q dbtbl1
	;
vOpen1()	;	FN FROM SCATBL WHERE PGM LIKE '%DBSDEUTL%'
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=""
vL1a2	S vos2=$O(^SCATBL(1,vos2),1) I vos2="" G vL1a0
	S vos3=$G(^SCATBL(1,vos2))
	I '($P(vos3,"|",4)["DBSDEUTL") G vL1a2
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a2
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds=$S(vos2=$C(254):"",1:vos2)
	;
	Q 1
