DBSTRG	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSTRG ****
	;
	; 11/08/2007 14:08 - chenardp
	;
	;
	;I18N=OFF
	;
	Q 
	;
COMPILE(fid,code,vsts,keytrgs,isRDB,tblrec,labelmap)	;
	;
	N f
	N tld S tld=""
	N count S count=0
	N seq
	N i N j N trgid N tag N tagseq N v N vtag N z
	;
	N del S del=$P(tblrec,"|",10)
	N delstr
	N rectyp S rectyp=$P(tblrec,"|",4)
	;
	I '(del="") D
	.	;
	.	I (del<32)!(del>127) S delstr="$C("_del_")"
	.	E  S delstr=$$QADD^%ZS($char(del),"""")
	.	Q 
	;
	N objName S objName=$translate($$vStrLC(fid,0),"_") ; Object name
	;
	D ADD^DBSFILB(.code,"",,500) ; Reserve slots for dispatch logic
	S tag(1)="vbi"
	S tag(2)="vbu"
	S tag(3)="vbd"
	S tag(4)="vai"
	S tag(5)="vau"
	S tag(6)="vad"
	;
	F i=1:1:6 S tagseq(i)=1
	;
	; Triggers applicable to key changes only
	S keytrgs("vbu")=0
	S keytrgs("vau")=0
	;
	N rs,vos1,vos2,vos3,vos4,vos5  N V1 S V1=fid S rs=$$vOpen1()
	;
	F  Q:'($$vFetch1())  D
	.	S trgid=$P(rs,$C(9),1)
	.	I $P(rs,$C(9),2)>tld S tld=$P(rs,$C(9),2)
	.	I $$build(fid,trgid,.code,.tag,.tagseq,.vtag,.vsts,.keytrgs,isRDB,tblrec,.labelmap) S count=count+1
	.	Q 
	;
	S code=count_$char(9)_tld
	;
	I ($order(vtag(""))="") Q  ; No triggers
	;
	S seq=2
	;
	S i=""
	F  S i=$order(vtag(i)) Q:(i="")  D
	.	;
	.	S tag=$$vStrUC(i)
	.	D ADD^DBSFILB(.code,"",,seq)
	.	S seq=seq+1
	.	D ADD^DBSFILB(.code,tag_" //",,seq)
	.	S seq=seq+1
	.	D ADD^DBSFILB(.code," type public Number ER = 0",,seq)
	.	S seq=seq+1
	.	D ADD^DBSFILB(.code," type public String vx(),RM",,seq)
	.	S seq=seq+1
	.	I tag="VBU" D ADD^DBSFILB(.code," type public Record"_fid_" "_objName,,seq)
	.	S seq=seq+1
	.	;
	.	S f=0
	.	S j=""
	.	F  S j=$order(vtag(i,j)) Q:(j="")  D
	..		; Quit out of trigger before column based triggers if no changes
	..		I 'f,'(j=+j) D
	...			S v=" if vx("""").order().isNull()"
	...			I tag="VBU" S v=v_" do AUDIT^UCUTILN("_objName_",.vx(),"_rectyp_","_delstr_")"
	...			S v=v_" quit"
	...			D ADD^DBSFILB(.code,v,,seq)
	...			S f=1 S seq=seq+1
	...			Q 
	..		;
	..		D ADD^DBSFILB(.code,vtag(i,j),,seq)
	..		S seq=seq+1
	..		;
	..		; Code for multiple triggers on same column
	..		I ($D(vtag(i,j,1))#2) D
	...			;
	...			N tseq
	...			;
	...			F tseq=1:1 Q:'($D(vtag(i,j,tseq))#2)  D
	....				;
	....				D ADD^DBSFILB(.code,vtag(i,j,tseq),,seq)
	....				S seq=seq+1
	....				Q 
	...			;
	...			D ADD^DBSFILB(.code," }",,seq)
	...			S seq=seq+1
	...			Q 
	..		Q 
	.	;
	.	; Since before update triggers can update other columns, vx() may need to be updated
	.	;
	.	I tag="VBU" D
	..		S z=" do AUDIT^UCUTILN("_objName_",.vx(),"_rectyp_","_delstr_")"
	..		D ADD^DBSFILB(.code,z,,seq) S seq=seq+1
	..		Q 
	.	;
	.	D ADD^DBSFILB(.code," quit",,seq) S seq=seq+1
	.	Q 
	;
	Q 
	;
build(fid,trgid,code,tag,tagseq,vtag,vsts,keytrgs,isRDB,tblrec,labelmap)	;
	;
	N onlyKeys
	N i N lasttag N seq
	N columns N des N sts N tags N z
	;
	N objName S objName=$translate($$vStrLC(fid,0),"_")
	;
	N rs,vos1,vos2,vos3,vos4,vos5,vos6  N V1,V2 S V1=fid,V2=trgid S rs=$$vOpen2()
	I '$G(vos1) Q 0 ; No trigger code
	;
	N dbtbl7 S dbtbl7=$$vDb3("SYSDEV",fid,trgid)
	;
	S code=$P(dbtbl7,$C(124),12)
	I '(code=""),'$$ifComp(code) Q 0 ; Conditionally include trigger
	;
	S des=$P(dbtbl7,$C(124),1)
	S sts=$P(dbtbl7,$C(124),2)
	S $piece(sts,"|",2)=$P(dbtbl7,$C(124),3)
	S $piece(sts,"|",3)=$P(dbtbl7,$C(124),4)
	S $piece(sts,"|",4)=$P(dbtbl7,$C(124),5)
	S $piece(sts,"|",5)=$P(dbtbl7,$C(124),6)
	S $piece(sts,"|",6)=$P(dbtbl7,$C(124),7)
	S columns=$P(dbtbl7,$C(124),8) ; Column triggers
	;
	F i=1:1:6 S onlyKeys(i)=0
	I 'isRDB,$P(dbtbl7,$C(124),3)!$P(dbtbl7,$C(124),6),'($P(dbtbl7,$C(124),8)="") D
	.	N onlyPrim S onlyPrim=1
	.	N i
	.	N primkeys S primkeys=","_$P(tblrec,"|",3)_","
	.	N columns S columns=$P(dbtbl7,$C(124),8)
	.	;
	.	F i=1:1:$L(columns,",") I primkeys'[(","_$piece(columns,",",i)_",") S onlyPrim=0 Q 
	.	;
	.	I onlyPrim D
	..		I $P(dbtbl7,$C(124),3) S onlyKeys(2)=1
	..		I $P(dbtbl7,$C(124),6) S onlyKeys(5)=1
	..		Q 
	.	Q 
	;
	; Update status indicators for entire trigger set (must be after IFCOND)
	I $P(dbtbl7,$C(124),2) S vsts("BI")="VBI"
	I $P(dbtbl7,$C(124),3),'onlyKeys(2) S vsts("BU")="VBU"
	I $P(dbtbl7,$C(124),4) S vsts("BD")="VBD"
	I $P(dbtbl7,$C(124),5) S vsts("AI")="VAI"
	I $P(dbtbl7,$C(124),6),'onlyKeys(5) S vsts("AU")="VAU"
	I $P(dbtbl7,$C(124),7) S vsts("AD")="VAD"
	;
	F i=1:1:6 I $piece(sts,"|",i) D
	.	;
	.	S seq=tagseq(i)
	.	S tagseq(i)=tagseq(i)+1
	.	S tag=tag(i)_seq
	.	S tags(i)=tag
	.	S lasttag=i
	.	Q 
	;
	S i=""
	F  S i=$order(tags(i)) Q:(i="")  D
	.	;
	.	S tag=tags(i)
	.	;
	.	; Order non-column based triggers first, then accumulate
	.	; within triggers within column tests
	.	I (columns="") S vtag(tag(i),seq)=" do "_tag_" if ER throw Class.new(""Error"",""%PSL-E-DBFILER,""_RM.get().replace("","",""~""))"
	.	E  D
	..		;
	..		N tseq S tseq=0
	..		;
	..		S z=$get(vtag(tag(i),columns))
	..		;
	..		; Handle situation of more than one trigger on same column(s)
	..		I (z="") S z=$$colvx(columns)
	..		E  D
	...			;
	...			S tseq=$order(vtag(tag(i),columns,""),-1)+1
	...			;
	...			; Second trigger, split to structured do
	...			I (tseq=1) D
	....				S vtag(tag(i),columns,1)="  do "_$piece(z," do ",2)
	....				S vtag(tag(i),columns)=$piece(z," do ",1)_" do {"
	....				S tseq=2
	....				Q 
	...			;
	...			S z=" "
	...			Q 
	..		;
	..		S z=z_" do "_tag
	..		I onlyKeys(i) D
	...			S keytrgs(tag(i),columns)=z
	...			S keytrgs(tag(i))=keytrgs(tag(i))+1
	...			Q 
	..		E  D
	...			;
	...			S z=z_" if ER throw Class.new(""Error"",""%PSL-E-DBFILER,""_RM.get().replace("","",""~""))"
	...			I (tseq=0) S vtag(tag(i),columns)=z
	...			E  S vtag(tag(i),columns,tseq)=z
	...			Q 
	..		Q 
	.	;
	.	D TAG^DBSFILB(.code,tag_" // Trigger "_trgid_" - "_des)
	.	S labelmap(tag)="Trigger|"_fid_"-"_trgid
	.	;
	.	I (i'=lasttag) D
	..		;
	..		D ADD^DBSFILB(.code," do "_tags(lasttag))
	..		D ADD^DBSFILB(.code,"")
	..		D ADD^DBSFILB(.code," quit")
	..		Q 
	.	Q 
	;
	D ADD^DBSFILB(.code," type public Record"_fid_" "_objName)
	;
	I $P(dbtbl7,$C(124),3) D ADD^DBSFILB(.code," do "_objName_".setAuditFlag(1)")
	;
	F  Q:'($$vFetch2())  D ADD^DBSFILB(.code,rs)
	;
	; Get the last line
	N line S line=$order(code(""),-1)
	;
	F  Q:'($translate(code(line),$C(9,32))="")  S line=$order(code(line),-1) I (line="") Q 
	;
	N isQuit S isQuit=$$vStrUC($$vStrTrim($translate(code(line),$char(9)," "),0," "))="QUIT"
	;
	; To avoid dead code warning, only add a quit if the procedure doesn't have one
	;
	I 'isQuit D ADD^DBSFILB(.code," quit")
	;
	Q 1
	;
colvx(col)	; Convert column list to vx(column).exists() logic
	;
	N i
	N di
	N list S list=""
	;
	F i=1:1:$L(col,",") D
	.	;
	.	S di=$piece(col,",",i)
	.	S list=list_"!vx("_$S(di'["""":""""_di_"""",1:$$QADD^%ZS(di,""""))_").exists()"
	.	Q 
	;
	Q " if "_$E(list,2,1048575)
	;
REQUIRD(fid,code,tblrec)	;
	;
	N req S req=$P(tblrec,"|",30)
	I (req="") Q 
	;
	N reqnokys S reqnokys=""
	N sort
	N objName S objName=$translate($$vStrLC(fid,0),"_")
	N rectyp S rectyp=$P(tblrec,"|",4)
	N keys S keys=$P(tblrec,"|",3)
	;
	D TAG^DBSFILB(.code,"vreqn // Validate required data items")
	;
	D ADD^DBSFILB(.code," type public Record"_fid_" "_objName)
	D ADD^DBSFILB(.code,"")
	;
	N i
	F i=1:1:$L(req,",") D
	.	;
	.	N di S di=$piece(req,",",i)
	.	I $$isLit^UCGM(di) Q  ; Legacy literal keys
	.	I ((","_keys_",")[(","_di_",")) Q  ; Key
	.	;
	.	S reqnokys=$S((reqnokys=""):di,1:reqnokys_","_di)
	.	;
	.	; for multi-node global, build array sorted by node
	.	;
	.	N rec S rec=$$getSchCln^UCXDD(fid,di)
	.	;
	.	D ADD^DBSFILB(.code," if "_objName_"."_$$vStrLC(di,0)_".isNull() do vreqerr("_$S(di'["""":""""_di_"""",1:$$QADD^%ZS(di,""""))_") quit")
	.	I rectyp=1 Q  ; No node-level check
	.	;
	.	N pos S pos=+$P(rec,"|",4)
	.	I '($P(rec,"|",10)="") S pos=pos_"~"_$P(rec,"|",10)
	.	S sort($$getOldNode^UCXDD(rec,1),pos)=di
	.	Q 
	;
	D ADD^DBSFILB(.code," quit")
	;
	D TAG^DBSFILB(.code,"vrequ // Valid required columns on update")
	D ADD^DBSFILB(.code,"")
	;
	D ADD^DBSFILB(.code," type public String vx()")
	D ADD^DBSFILB(.code," type public Record"_fid_" "_objName)
	D ADD^DBSFILB(.code,"")
	;
	; First check the primary keys
	; Note keys may be null for CUVAR-like tables
	I '(keys="") F i=1:1:$L(keys,",") D
	.	;
	.	N di S di=$piece(keys,",",i)
	.	D ADD^DBSFILB(.code," if "_objName_"."_$$vStrLC(di,0)_".isNull() do vreqerr("_$S(di'["""":""""_di_"""",1:$$QADD^%ZS(di,""""))_") quit")
	.	Q 
	;
	D ADD^DBSFILB(.code,"")
	;
	; If multi-node table, optimize by checking if any changes on a node
	N nod S nod="" N pos S pos=""
	F  S nod=$order(sort(nod)) Q:(nod="")  D
	.	;
	.	D ADD^DBSFILB(.code," if 'vobj("_objName_",-100,"_nod_","""").order().isNull() do {")
	.	;
	.	F  S pos=$order(sort(nod,pos)) Q:(pos="")  D
	..		N di S di=sort(nod,pos)
	..		D ADD^DBSFILB(.code,"  if vx("""_di_""").exists(),"_objName_"."_$$vStrLC(di,0)_".isNull() do vreqerr("_$S(di'["""":""""_di_"""",1:$$QADD^%ZS(di,""""))_") quit")
	..		Q 
	.	;
	.	D ADD^DBSFILB(.code," }")
	.	Q 
	; Type 1 record
	F i=1:1:$S((reqnokys=""):0,1:$L(reqnokys,",")) D
	.	;
	.	N di S di=$piece(reqnokys,",",i)
	.	;
	.	D ADD^DBSFILB(.code,"  if vx("""_di_""").exists(),"_objName_"."_$$vStrLC(di,0)_".isNull() do vreqerr("_$S(di'["""":""""_di_"""",1:$$QADD^%ZS(di,""""))_") quit")
	.	Q 
	;
	D ADD^DBSFILB(.code," quit")
	;
	D TAG^DBSFILB(.code,"vreqerr(di) // Required error")
	D ADD^DBSFILB(.code," type public Boolean ER = 0")
	D ADD^DBSFILB(.code," type public String RM")
	D ADD^DBSFILB(.code," do SETERR^DBSEXECU("_$S(fid'["""":""""_fid_"""",1:$$QADD^%ZS(fid,""""))_",""MSG"",1767,"""_fid_".""_di)")
	D ADD^DBSFILB(.code," if ER throw Class.new(""Error"",""%PSL-E-DBFILER,""_RM.get().replace("","",""~""))")
	D ADD^DBSFILB(.code," quit")
	;
	Q 
	;
DEFTBL(fid,code,tblrec)	;
	;
	N count N i
	;
	N objName S objName=$translate($$vStrLC(fid,0),"_") ; Object name
	N dftList S dftList=$P(tblrec,"|",29)
	N acckeys S acckeys=$P(tblrec,"|",3)
	;
	D TAG^DBSFILB(.code,"vinit // Initialize default values")
	D ADD^DBSFILB(.code," type public Record"_fid_" "_objName)
	;
	; Define access keys as local variables to support use in defaults
	I '(acckeys="") D
	.	;
	.	D ADD^DBSFILB(.code,"")
	.	D ADD^DBSFILB(.code," // Type local variables for access keys for defaults")
	.	F i=1:1:$L(acckeys,",") D
	..		;
	..		N di S di=$piece(acckeys,",",i)
	..		N var S var=$$vStrUC($translate(di,"_"))
	..		;
	..		D ADD^DBSFILB(.code," type public String "_var)
	..		Q 
	.	Q 
	;
	D ADD^DBSFILB(.code,"")
	;
	S count=0
	;
	I '(dftList="") F i=1:1:$L(dftList,",") D
	.	;
	.	N di S di=$piece(dftList,",",i)
	.	;
	.	N rec S rec=$$getSchCln^UCXDD(fid,di)
	.	;
	.	Q:($P(rec,"|",18)="") 
	.	Q:'($P(rec,"|",14)="")  ; Computeds can't have default values
	.	;
	.	N v S v=$$value^DBSFILER($P(rec,"|",18),$P(rec,"|",6))
	.	;
	.	S di=$$vStrLC(di,0)
	.	;
	.	I (v?1A.AN)!(v?1"%".AN) D ADD^DBSFILB(.code," type public String "_v)
	.	D ADD^DBSFILB(.code," if "_objName_"."_di_".isNull() set "_objName_"."_di_" = "_v,di)
	.	;
	.	S count=count+1
	.	Q 
	;
	D ADD^DBSFILB(.code," quit")
	;
	S code=count
	;
	Q 
	;
ACNVAL(fid,code)	;
	;
	N i
	N dilist N dinam N list
	;
	; Hard coded references to DEP/LN not good (FRS)
	I '((fid="DEP")!(fid="LN")) Q  ; Support LN and DEP only
	;
	N rs1,vos1,vos2,vos3 S rs1=$$vOpen3()
	N rs2,vos4,vos5,vos6 S rs2=$$vOpen4()
	;
	; Reference to UX() needs to be checked (FRS)
	;
	D TAG^DBSFILB(.code,"VACNVAL // Rule based default logic")
	D ADD^DBSFILB(.code," type public String value(),UX()")
	D ADD^DBSFILB(.code," type public Number %O,CID")
	;
	I '$G(vos1),'$G(vos4) D ADD^DBSFILB(.code," quit") Q 
	;
	; Get a list of referenced columns used in the queries
	;
	F  Q:'($$vFetch3())  D
	.	;
	.	N colnames
	.	;
	.	S colnames=$P(rs1,$C(9),1)
	.	F i=1:1:$L(colnames,",") D
	..		S dinam=$piece(colnames,",",i)
	..		I $piece(dinam,".",1)=fid S list(dinam)=""
	..		Q 
	.	Q 
	;
	; Get a list of column names from results definition
	;
	F  Q:'($$vFetch4())  D
	.	S dinam=$P(rs2,$C(9),1)
	.	I $piece(dinam,".",1)=fid S list(dinam)=""
	.	Q 
	;
	S dilist="" S i=""
	F  S i=$order(list(i)) Q:(i="")  S dilist=dilist_","_($piece(i,".",2))
	;
	; Not sure what this is about (FRS)
	F i="ACN","TYPE","BOO" S list(fid_"."_i)=""
	;
	D ADD^DBSFILB(.code," if %O=1,'$$CHANGED^PROC1DB("_$S(fid'["""":""""_fid_"""",1:$$QADD^%ZS(fid,""""))_",.UX,"_$$QADD^%ZS($E(dilist,2,1048575),"""")_") quit")
	D ADD^DBSFILB(.code,"")
	D ADD^DBSFILB(.code," // new value")
	;
	F  S i=$order(list(i)) Q:(i="")  D
	.	D ADD^DBSFILB(.code," set value("_$$QADD^%ZS(($piece(i,".",2)),"""")_") = "_i)
	.	Q 
	;
	D ADD^DBSFILB(.code,"do RESULTS^PROC1DB(%O,CID,.value,.UX)")
	D ADD^DBSFILB(.code," quit")
	Q 
	;
VDD(fid,code,tblrec,isRDB)	;
	;
	N tld
	N count N hit N pos
	N di N gbl N lastkey N nod N rectyp N xnod N ws N v N z
	N objName S objName=$translate($$vStrLC(fid,0),"_")
	;
	N dilist
	;
	S tld=""
	S (count,hit)=0
	;
	S xnod=""
	S gbl=$piece($P(tblrec,"|",2),"(",1) ; Global name
	S rectyp=$P(tblrec,"|",4)
	I isRDB S rectyp=$$RDBRCTYP^DBSFILB(fid)
	I rectyp=11 S lastkey=$piece($P(tblrec,"|",3),",",$L($P(tblrec,"|",3),","))
	;
	D TAG^DBSFILB(.code,"vddver // Validate data dictionary attributes")
	D ADD^DBSFILB(.code," type public Number %O")
	D ADD^DBSFILB(.code," type public String vpar,vx()")
	D ADD^DBSFILB(.code,"")
	D ADD^DBSFILB(.code," type String vRM,X")
	D ADD^DBSFILB(.code," type public Record"_fid_" "_objName)
	D ADD^DBSFILB(.code,"")
	;
	I rectyp>1 D ADD^DBSFILB(.code," if (%O = 2) do vload")
	;
	; Build list of elements sorted by node (appropriate to the
	; target database)
	N rs,vos1,vos2,vos3,vos4,vos5  N V1 S V1=fid S rs=$$vOpen5()
	;
	F  Q:'($$vFetch5())  D
	.	;
	.	S di=rs
	.	;
	.	I '$$isLit^UCGM(di),((di?1A.AN)!(di?1"%".AN)!(di?.A."_".E)) D
	..		;
	..		N rec S rec=$$getSchCln^UCXDD(fid,di)
	..		;
	..		S dilist($P(rec,"|",3),di)=rec
	..		Q 
	.	Q 
	;
	S (nod,di)=""
	F  S nod=$order(dilist(nod)) Q:(nod="")  D  Q:ER 
	.	;
	.	F  S di=$order(dilist(nod,di)) Q:(di="")  D  Q:ER 
	..		;
	..		N max N min
	..		N ptn N tbl N typ
	..		;
	..		N rec S rec=dilist(nod,di)
	..		;
	..		S tbl=$P(rec,"|",20)
	..		S typ=$P(rec,"|",6)
	..		S min=$P(rec,"|",26)
	..		S max=$P(rec,"|",27)
	..		S ptn=$P(rec,"|",21)
	..		;
	..		S count=count+1
	..		I ($P(rec,"|",33)>tld) S tld=$P(rec,"|",33)
	..		;
	..		I '(tbl="") D  Q:ER 
	...			;
	...			I (tbl[":NOVAL") S tbl="" Q 
	...			;
	...			I ($E(tbl,1)="["),(tbl?1"["1A.AN1"]".E)!(tbl?1"[%".AN1"]".E) D  Q 
	....				N QRY S QRY=""
	....				;
	....				I tbl[":QU" S QRY=$piece($piece(tbl,":QU",2)," ",2,99)
	....				;
	....				S tbl=$piece($piece(tbl,"[",2),"]",1)
	....				;
	....				I tbl=fid!(tbl=$P(tblrec,"|",7)) S tbl="" Q 
	....				;
	....				 N V2 S V2=tbl I '($D(^DBTBL("SYSDEV",1,V2))) D  Q 
	.....					S ER=1
	.....					WRITE " Aborted - invalid table linkage for column ",di
	.....					Q 
	....				;
	....				N z S z=$$getSchTbl^UCXDD(tbl)
	....				;
	....				; If more than a single key, try to use query info
	....				I $L($P(z,"|",3),",")>1 D
	.....					;
	.....					N i
	.....					N key N keyname N keys N TOK N x
	.....					;
	.....					I (QRY="") S tbl="" Q 
	.....					S QRY=$$QSUB^%ZS(QRY,"""")
	.....					S QRY=$$TOKEN^%ZS(QRY,.TOK)
	.....					S keys=""
	.....					;
	.....					F i=1:1:$L($P(z,"|",3),",")-1 D  Q:tbl="" 
	......						S keyname=$piece($P(z,"|",3),",",i)
	......						S key="["_tbl_"]"_keyname_"="
	......						I QRY'[key S tbl="" Q 
	......						S x=$piece(QRY,key,2)
	......						S x=$$ATOM^%ZS(x,0,",:&",TOK,0)
	......						I (x="") S tbl="" Q 
	......						I '((x=+x)!(x?1"""".e1"""")) S tbl="" Q 
	......						S keys=keys_keyname_"="_x_","
	......						Q 
	.....					;
	.....					Q:tbl="" 
	.....					;
	.....					S keyname=$piece($P(z,"|",3),",",$L($P(z,"|",3),","))
	.....					S keys=keys_keyname_"=:X"
	.....					S tbl="Db.isDefined("_$S(tbl'["""":""""_tbl_"""",1:$$QADD^%ZS(tbl,""""))_","_$S(keys'["""":""""_keys_"""",1:$$QADD^%ZS(keys,""""))_")"
	.....					;
	.....					Q 
	....				E  S tbl="Db.isDefined("_$S(tbl'["""":""""_tbl_"""",1:$$QADD^%ZS(tbl,""""))_",""X"")"
	....				Q 
	...			;
	...			; Don't check indirection or local arrays
	...			I ($E(tbl,1)="@") S tbl=""
	...			E  I tbl?1A.AN1"(" S tbl=""
	...			;
	...			; Picklist
	...			I ($E(tbl,1)=",") D
	....				;
	....				N I
	....				N LIST N tbltok N tok
	....				;
	....				S tbltok=$$TOKEN^%ZS(tbl,.tok)
	....				S LIST=""
	....				;
	....				F I=2:1:$L(tbltok,",") S LIST=LIST_$piece($piece(tbltok,",",I),"#",1)_","
	....				;
	....				S tbl=$$UNTOK^%ZS($E(LIST,1,$L(LIST)-1),tok)
	....				;
	....				S tbl="{List}"_$S(tbl'["""":""""_tbl_"""",1:$$QADD^%ZS(tbl,""""))_".contains(X)"
	....				Q 
	...			;
	...			; Allow table linkage to globals in versions prior to 7.0
	...			I ($E(tbl,1)="^") D
	....				;
	....				I tbl=(gbl_"(") S tbl=""
	....				E  D
	.....					;
	.....					I $L(tbl,"#")=2,tbl?.E1"#".N.E S tbl=$piece(tbl,"#",1)
	.....					S tbl=tbl_"X).data()"
	.....					Q 
	....				Q 
	...			;
	...			I (""""""[tbl) S tbl=""
	...			Q 
	..		;
	..		S z="set X = "_objName_"."_$$vStrLC(di,0)_" if 'X.isNull()"
	..		;
	..		I '(tbl="") D
	...			; The following preamble may be globally relevant
	...			; set z = "if '(%O = 1)!vx("""_di_""").exists() "_z
	...			S z=z_",'"_tbl_" set vRM = $$^MSG(1485,X) do vdderr("""_di_""", vRM) quit"
	...			Q 
	..		;
	..		E  I typ="F" D
	...			;
	...			S z=z_" set vRM = """" do DBSEDT^UFRE(""["_fid_"]"_di_""",0)"
	...			S z=z_" if 'vRM.get().isNull() do vdderr("""_di_""", vRM) quit"
	...			Q 
	..		;
	..		E  D
	...			I '(min="") S min=$$value^DBSFILER(min,typ)
	...			I '(max="") S max=$$value^DBSFILER(max,typ)
	...			;
	...			; Build a parameter string 'v' to pass to DBSVER
	...			;
	...			S v=$S(typ'["""":""""_typ_"""",1:$$QADD^%ZS(typ,""""))
	...			S $piece(v,",",2)=+$P(rec,"|",7)
	...			S $piece(v,",",3)=+$P(rec,"|",28)
	...			I '(ptn="") S $piece(v,",",5)=$S(ptn'["""":""""_ptn_"""",1:$$QADD^%ZS(ptn,""""))
	...			S $piece(v,",",6)=min
	...			S $piece(v,",",7)=max
	...			S $piece(v,",",8)=+$P(rec,"|",8)
	...			;
	...			; Don't need to perform length checks if not GTM database
	...			I "UT"[typ,(min=""),(max=""),(ptn="") D
	....				I 'isRDB S z="if "_objName_"."_$$vStrLC(di,0)_".length()>"_$P(rec,"|",7)_" set vRM = $$^MSG(1076,"_$P(rec,"|",7)_") do vdderr("""_di_""", vRM) quit"
	....				E  S z=""
	....				Q 
	...			E  I "$N"[typ,'$P(rec,"|",8) D
	....				I $P(rec,"|",7)=1 S z=z_",X'?1N set vRM=$$^MSG(742,""N"") do vdderr("""_di_""", vRM) quit"
	....				E  S z=z_",X'?1."_(+$P(rec,"|",7))_"N,X'?1""-""1."_($P(rec,"|",7)-1)_"N set vRM=$$^MSG(742,""N"") do vdderr("""_di_""", vRM) quit"
	....				Q 
	...			;
	...			E  I "BM"[typ D
	....				I 'isRDB S z="if "_objName_"."_di_".length()>"_$P(rec,"|",7)_" set vRM = $$^MSG(1076,"_$P(rec,"|",7)_") do vdderr("""_di_""", vRM) quit"
	....				E  S z=""
	....				Q 
	...			;
	...			E  I typ="D" S z=z_",X'?1.5N set vRM=$$^MSG(742,""D"") do vdderr("""_di_""", vRM) quit"
	...			E  I typ="C" S z=z_",X'?1.5N set vRM=$$^MSG(742,""C"") do vdderr("""_di_""", vRM) quit"
	...			E  I typ="L" S z="if '(""01""["_objName_"."_di_") set vRM=$$^MSG(742,""L"") do vdderr("""_di_""", vRM) quit"
	...			;
	...			E  S z=z_" set vRM = $$VAL^DBSVER("_v_") if 'vRM.isNull() set vRM = $$^MSG(979,"""_fid_"."_di_"""_"" ""_vRM) throw Class.new(""Error"",""%PSL-E-DBFILER,""_vRM.replace("","",""~""))"
	...			Q 
	..		;
	..		Q:z=""  ; Nothing to check since RDB
	..		;
	..		S hit=1
	..		;
	..		S ws=" "
	..		;
	..		I rectyp>1,'(nod=xnod) D  ; Conditional check
	...			;
	...			N zz
	...			;
	...			I '(xnod="") D ADD^DBSFILB(.code," }")
	...			I nod["*" S xnod="" Q  ; Access key
	...			S xnod=nod
	...			I rectyp=11,nod=lastkey S zz="if vobj("_objName_").exists() ! 'vobj("_objName_","""").order().isNull() do {"
	...			E  D
	....				N x
	....				;
	....				I (nod=+nod) S x=nod
	....				E  S x=""""_nod_""""
	....				;
	....				S zz="if vobj("_objName_","_x_").exists() do {"
	....				Q 
	...			D ADD^DBSFILB(.code,"") D ADD^DBSFILB(.code,ws_zz) D ADD^DBSFILB(.code,"")
	...			Q 
	..		;
	..		I '(xnod="") S ws="  "
	..		;
	..		D ADD^DBSFILB(.code,ws_z)
	..		Q 
	.	Q 
	;
	Q:ER 
	;
	S ws=" "
	;
	I '(xnod="") D ADD^DBSFILB(.code," }")
	;
	D ADD^DBSFILB(.code,ws_"quit")
	;
	D TAG^DBSFILB(.code,"vdderr(di, vRM) // Column attribute error")
	D ADD^DBSFILB(.code,ws_"type public Boolean ER = 0")
	D ADD^DBSFILB(.code,ws_"type public String RM")
	D ADD^DBSFILB(.code,ws_"do SETERR^DBSEXECU("""_fid_""",""MSG"",979,"""_fid_".""_di_"" ""_vRM)")
	D ADD^DBSFILB(.code,ws_"if ER throw Class.new(""Error"",""%PSL-E-DBFILER,""_RM.get().replace("","",""~""))")
	D ADD^DBSFILB(.code,ws_"quit")
	;
	S code=count_$char(9)_tld
	;
	I 'hit K code ; No validation
	;
	Q 
	;
FKEYS(fid,code,tblrec)	;
	;
	 S ER=0
	;
	N i N p
	N fkeys N forfid N forgbl N forkeys N gbl N lastKey N z
	N fk
	;
	N exist S exist=$P(tblrec,"|",12)
	;
	N objName S objName=$translate($$vStrLC(fid,0),"_")
	;
	; load all the foreign key definitions for this table and it's ancestors into the fk() array
	;
	N TABLE S TABLE=fid
	;
	F  D  I (TABLE="") Q 
	.	;
	.	N rs,vos1,vos2,vos3,vos4,vos5 S rs=$$vOpen6()
	.	F  Q:'($$vFetch6())  S fk($P(rs,$C(9),1))=$P(rs,$C(9),2)
	.	;
	.	I $P(tblrec,"|",1)=TABLE S TABLE=$P(tblrec,"|",7)
	.	E  D
	..		N tblrec S tblrec=$$getSchTbl^UCXDD(TABLE)
	..		S TABLE=$P(tblrec,"|",7)
	..		Q 
	.	Q 
	;
	; The following throws an invalid warning about fk being undefined.  Use accept
	; until that error is resolved in PSL.
	;  #ACCEPT DATE=03/29/04; PGM=Dan Russell; CR=20602
	I ($order(fk(""))="") Q  ; No foreign keys
	;
	D TAG^DBSFILB(.code,"VFKEYS // Foreign keys")
	;
	D ADD^DBSFILB(.code," type public String vfkey(),vpar")
	D ADD^DBSFILB(.code,"")
	D ADD^DBSFILB(.code," type public Record"_fid_" "_objName)
	;
	S fkeys=""
	;
	F  S fkeys=$order(fk(fkeys)) Q:(fkeys="")  D
	.	;
	.	S forfid=fk(fkeys)
	.	N tblrec S tblrec=$$getSchTbl^UCXDD(forfid)
	.	;
	.	N exist S exist=$P(tblrec,"|",12)
	.	N gbl S gbl=$P(tblrec,"|",2)
	.	N forgbl S forgbl=$piece(gbl,"(",1) ; Global name
	.	N forkeys S forkeys=$piece(gbl,"(",2,999) ; Access keys
	.	N v
	.	;
	.	S p=1
	.	;
	.	I '(exist="") S forkeys=forkeys_","_exist ; Add node checking logic
	.	S forkeys=$translate(forkeys,",",$char(0)) ; Replace , with $C(0)
	.	;
	.	F i=1:1:$L(forkeys,$char(0)) D  ; Map each key
	..		;
	..		N key
	..		;
	..		S key=$piece(forkeys,$char(0),i) ; Access key
	..		I key=+key Q  ; Numeric key
	..		I ($E(key,1)="""") S $piece(forkeys,$char(0),i)=$S(key'["""":""""_key_"""",1:$$QADD^%ZS(key,"""")) Q 
	..		S key=$piece(fkeys,",",p) S p=p+1 ; foreign key
	..		S lastKey=key
	..		S $piece(forkeys,$char(0),i)="""""""""_"_objName_"."_$$vStrLC(key,0)_"_"""""""""
	..		Q 
	.	;
	.	S v=""
	.	F i=1:1:$L(forkeys,$char(0)) S v=v_$piece(forkeys,$char(0),i)_"_"",""_"
	.	S v=$E(v,1,$L(v)-5)
	.	;
	.	S forkeys=$translate(v,$char(0),",") ; Insert , character
	.	;
	.	S v=" if '"_objName_"."_$$vStrLC(lastKey,0)_".isNull()"
	.	S v=v_" set vfkey("""_forgbl_"(""_"_forkeys_"_"")"")="
	.	S v=v_""""_fid_"("_fkeys_") -> "_forfid_""""
	.	D ADD^DBSFILB(.code,v)
	.	Q 
	;
	D ADD^DBSFILB(.code," quit")
	;
	D CHKFKEYS(fid,.code,tblrec)
	Q 
	;
KEYCHG(fid,code,tblrec,vsts,keytrgs,vreqsec,sections,rectyp,isRDB)	;
	;
	N gbl N key N keyq N numkeys N objName N v N vreqtag N z
	N i N saveline
	;
	N hasIndex S hasIndex=$$hasIndex(fid)
	N hasMB S hasMB=(($P(tblrec,"|",5)["M")!($P(tblrec,"|",5)["B"))
	;
	S objName=$translate($$vStrLC(fid,0),"_")
	;
	N keys S keys=$P(tblrec,"|",3)
	;
	S numkeys=$L(keys,",")
	S gbl=$$getGbl^UCXDD(tblrec,objName) ; Global reference
	;
	D TAG^DBSFILB(.code,"vkchged // Access key changed")
	;
	D ADD^DBSFILB(.code," type public Record"_fid_" "_objName)
	D ADD^DBSFILB(.code,"")
	D ADD^DBSFILB(.code," type public Boolean ER = 0")
	D ADD^DBSFILB(.code," type public String RM,vpar,vx()")
	D ADD^DBSFILB(.code,"")
	D ADD^DBSFILB(.code," type Number %O = 1")
	D ADD^DBSFILB(.code," type String vnewkey,voldkey,vux")
	;
	; If there is an after update trigger, save vpar
	I ($D(vsts("AU"))#2)!keytrgs("vau") D ADD^DBSFILB(.code," type String voldpar = vpar.get()","Save filer switches")
	;
	D ADD^DBSFILB(.code,"")
	;
	; Copy keys into vux or vux array to save them
	S v=""
	I numkeys=1 D ADD^DBSFILB(.code," set vux = vx("""_keys_""")")
	E  F i=1:1:numkeys D
	.	;
	.	S key=$piece(keys,",",i)
	.	I i>1 S v=v_"_"",""_"
	.	S v=v_objName_"."_$$vStrLC(key,0)
	.	S z=" if vx("""_key_""").exists() set vux("""_key_""") = vx("""_key_""")"
	.	D ADD^DBSFILB(.code,z)
	.	Q 
	;
	I numkeys=1 S z=" set voldkey = vux.piece(""|"",1),vobj("_objName_",-3) = voldkey"
	E  S z=" do vkey(1) set voldkey = "_v
	;
	D ADD^DBSFILB(.code,z,"Copy old keys into object")
	D ADD^DBSFILB(.code,"")
	;
	I 'isRDB D ADD^DBSFILB(.code," set vpar = $$setPar^UCUTILN(vpar,""NOINDEX"")","Switch Index off")
	;
	; Data needs to be loaded to support VALDD and prior to deletion
	I rectyp>1 D ADD^DBSFILB(.code," do vload","Make sure all data is loaded locally")
	;
	I 'isRDB,vreqsec D
	.	S vreqtag="vrequ"
	.	D ADD^DBSFILB(.code," if vpar[""/VALREQ/"" do vrequ")
	.	Q 
	;
	; If before update triggers (non-key or key columns), handle
	I ($D(vsts("BU"))#2)!keytrgs("vbu") D
	.	N n N xcode
	.	;
	.	I 'keytrgs("vbu") D ADD^DBSFILB(.code," if vpar[""/TRIGBEF/"" do "_vsts("BU"))
	.	E  I '($D(vsts("BU"))#2),keytrgs("vbu")=1 D  ; just one
	..		S n=$order(keytrgs("vbu",""))
	..		S xcode=keytrgs("vbu",n)
	..		S xcode=xcode_" if ER throw Class.new(""Error"",""%PSL-E-DBFILER,""_RM.get().replace("","",""~""))"
	..		D ADD^DBSFILB(.code," if vpar[""/TRIGBEF/"""_xcode)
	..		Q 
	.	E  D
	..		D ADD^DBSFILB(.code," if vpar[""/TRIGBEF/"" do { quit:ER")
	..		I ($D(vsts("BU"))#2) D ADD^DBSFILB(.code,"  do "_vsts("BU"))
	..		S n=""
	..		F  S n=$order(keytrgs("vbu",n)) Q:n=""  D
	...			S xcode=keytrgs("vbu",n)
	...			S xcode=xcode_" if ER throw Class.new(""Error"",""%PSL-E-DBFILER,""_RM.get().replace("","",""~""))"
	...			D ADD^DBSFILB(.code," "_xcode)
	...			Q 
	..		D ADD^DBSFILB(.code," }")
	..		Q 
	.	Q 
	;
	I ($D(sections("vddver"))#2) D ADD^DBSFILB(.code," if vpar[""/VALDD/"" do vddver",,.saveline)
	;
	D ADD^DBSFILB(.code," do vexec")
	;
	D ADD^DBSFILB(.code,"")
	;
	I numkeys=1 S z=" set vnewkey = vux.piece(""|"",2),vobj("_objName_",-3) = vnewkey"
	E  S z=" do vkey(2) set vnewkey = "_v
	D ADD^DBSFILB(.code,z,"Copy new keys into object")
	;
	; Create new copy to insert
	D ADD^DBSFILB(.code," type Record"_fid_" vnewrec = "_objName_".copy()")
	D ADD^DBSFILB(.code," do vnewrec.setMode(0)")
	D ADD^DBSFILB(.code," do vnewrec.save(""/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/"")")
	;
	D ADD^DBSFILB(.code,"")
	S z=" set %O = 1 do CASUPD^DBSEXECU("_$S(fid'["""":""""_fid_"""",1:$$QADD^%ZS(fid,""""))_",voldkey,vnewkey) if ER throw Class.new(""Error"",""%PSL-E-DBFILER,""_RM.get().replace("","",""~""))"
	D ADD^DBSFILB(.code,z,"Cascade update")
	;
	; If after update triggers (non-key or key columns), handle
	I ($D(vsts("AU"))#2)!keytrgs("vau") D
	.	N n N xcode
	.	;
	.	D ADD^DBSFILB(.code," set vpar = voldpar")
	.	;
	.	I 'keytrgs("vau") D ADD^DBSFILB(.code," if vpar[""/TRIGAFT/"" do "_vsts("AU"))
	.	E  I '($D(vsts("AU"))#2),keytrgs("vau")=1 D  ; just one
	..		S n=$order(keytrgs("vau",""))
	..		S xcode=keytrgs("vau",n)
	..		D ADD^DBSFILB(.code," if vpar[""/TRIGAFT/"""_xcode)
	..		Q 
	.	E  D
	..		D ADD^DBSFILB(.code," if vpar[""/TRIGAFT/"" do {")
	..		D ADD^DBSFILB(.code,"  do "_vsts("AU"))
	..		S n=""
	..		F  S n=$order(keytrgs("vau",n)) Q:n=""  D
	...			S xcode=keytrgs("vau",n)
	...			S xcode=xcode_" if ER throw Class.new(""Error"",""%PSL-E-DBFILER,""_RM.get().replace("","",""~""))"
	...			D ADD^DBSFILB(.code," "_xcode)
	...			Q 
	..		D ADD^DBSFILB(.code," }")
	..		Q 
	.	Q 
	;
	D ADD^DBSFILB(.code,"")
	;
	; Delete the old record
	I numkeys=1 S z=" set vobj("_objName_",-3) = vux.piece(""|"",1)"
	E  S z=" do vkey(1)"
	D ADD^DBSFILB(.code,z,"Reset key for delete")
	D ADD^DBSFILB(.code," set vpar = $$initPar^UCUTILN(""/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/"")")
	D ADD^DBSFILB(.code," set %O = 3 do vdelete(1)","Delete old record")
	;
	D ADD^DBSFILB(.code,"")
	;
	D ADD^DBSFILB(.code," quit")
	;
	I numkeys>1 D
	.	;
	.	D TAG^DBSFILB(.code,"vkey(Number i) // Restore access keys")
	.	;
	.	D ADD^DBSFILB(.code," type public String vux()")
	.	D ADD^DBSFILB(.code," type public Record"_fid_" "_objName)
	.	D ADD^DBSFILB(.code,"")
	.	;
	.	F i=1:1:numkeys D
	..		;
	..		S key=$piece(keys,",",i)
	..		D ADD^DBSFILB(.code," if vux("""_key_""").exists() set "_objName_"."_$$vStrLC(key,0)_" = vux("""_key_""").piece(""|"",i)")
	..		Q 
	.	;
	.	D ADD^DBSFILB(.code," quit")
	.	Q 
	;
	Q 
	;
hasIndex(fid)	; Return whether fid has an index
	N vret
	;
	N rs,vos1,vos2,vos3,vos4  N V1 S V1=fid S rs=$$vOpen7()
	S vret=''$G(vos1) Q vret
	;
CHKFKEYS(fid,code,tblrec)	;
	;
	N i
	N di N errmsg N fkeys N forfid N objref N z N z1 N z2
	;
	N fk
	N table S table=fid
	;
	N objName S objName=$translate($$vStrLC(fid,0),"_")
	;
	N req S req=$P(tblrec,"|",30)
	N exist S exist=$P(tblrec,"|",12)
	;
	F  D  I (table="") Q 
	.	;
	.	N rs,vos1,vos2,vos3,vos4,vos5  N V1 S V1=table S rs=$$vOpen8()
	.	F  Q:'($$vFetch8())  S fk($P(rs,$C(9),1))=$P(rs,$C(9),2)
	.	;
	.	I $P(tblrec,"|",1)=table S table=$P(tblrec,"|",7)
	.	E  D
	..		N tblrec S tblrec=$$getSchTbl^UCXDD(table)
	..		S table=$P(tblrec,"|",7)
	..		Q 
	.	Q 
	;
	D TAG^DBSFILB(.code,"CHKFKS   // Check foreign keys when not under buffer")
	;
	I ($order(fk(""))="") D ADD^DBSFILB(.code," quit") Q  ; No foreign keys
	;
	D ADD^DBSFILB(.code,"")
	D ADD^DBSFILB(.code," type public Record"_fid_" "_objName)
	D ADD^DBSFILB(.code," type public Number %O")
	D ADD^DBSFILB(.code," type String vERRMSG")
	D ADD^DBSFILB(.code,"")
	;
	S fkeys=""
	;
	F  S fkeys=$order(fk(fkeys)) Q:(fkeys="")  D
	.	;
	.	S forfid=fk(fkeys)
	.	;
	.	S z1="" S z2=""
	.	F i=1:1:$L(fkeys,",") D
	..		;
	..		I '(z2="") S z2=z2_","
	..		;
	..		S di=$piece(fkeys,",",i)
	..		;
	..		I ($E(di,1)="""")!(di=+di) S z2=z2_di Q 
	..		S objref=objName_"."_$$vStrLC(di,0)
	..		S z2=z2_":"_objref
	..		;
	..		I '((","_req_",")[(","_di_",")) D
	...			I '(z1="") S z1=z1_","
	...			S z1=z1_"'"_objref_".isNull()"
	...			Q 
	..		Q 
	.	;
	.	S errmsg=$$^MSG(8563,fid_"("_fkeys_") -> "_forfid)
	.	S errmsg=$translate(errmsg,",","~")
	.	;
	.	S z=" if 'Db.isDefined("""_forfid_""","""_z2_""")"
	.	S z=z_" set vERRMSG = $$^MSG(8563,"""_fid_"("_fkeys_") -> "_forfid_""")"
	.	S z=z_" throw Class.new(""Error"",""%PSL-E-DBFILER,""_vERRMSG.replace("","",""~""))"
	.	I '(z1="") S z=" if "_z1_z
	.	;
	.	D ADD^DBSFILB(.code,z)
	.	Q 
	;
	D ADD^DBSFILB(.code," quit")
	Q 
	;
CASDEL(fid,code,tblrec)	;
	N vpc
	;
	N hasDel
	N n
	N acckeys N list N OBJNAME
	;
	D CASDELST(fid,.list)
	I (fid="LN")!(fid="DEP") D CASDELST(fid,.list) ; Supertype logic
	;
	Q:($order(list(""))="") 
	;
	S acckeys=$P(tblrec,"|",3)
	Q:(acckeys="") 
	;
	S acckeys=$$vStrLC(acckeys,0)
	;
	S OBJNAME=$$vStrLC(fid,0) ; Primary table object name
	;
	D ADD^DBSFILB(.code," type public Record"_fid_" "_OBJNAME)
	D ADD^DBSFILB(.code," type public String vpar")
	D ADD^DBSFILB(.code,"")
	;
	S n=""
	S hasDel=1
	F  S n=$order(list(n)) Q:(n="")  I '$piece(list(n),"|",3) S hasDel=0 Q 
	I 'hasDel D
	.	D ADD^DBSFILB(.code," type String vERRMSG")
	.	D ADD^DBSFILB(.code,"")
	.	Q 
	;
	S n=""
	F  S n=$order(list(n)) Q:n=""  D
	.	N i
	.	N del N fkeys N fkfid N ftblkeys N where N xcode
	.	;
	.	S fkfid=$piece(list(n),"|",1)
	.	S fkeys=$piece(list(n),"|",2)
	.	S del=$piece(list(n),"|",3)
	.	;
	.	N dbtbl1,vop1,vop2,vop3,vop4 S vop1="SYSDEV",vop2=fkfid,dbtbl1=$$vDb4("SYSDEV",fkfid,.vop3)
	.	 S vop4=$G(^DBTBL(vop1,1,vop2,16))
	.	S vpc=('$G(vop3)) Q:vpc  ; Invalid table
	.	;
	.	S ftblkeys=$$KEYS^SQLDD("",$P(vop4,$C(124),1))
	.	;
	.	S where=""
	.	F i=1:1:$L(fkeys,",") S where=where_$piece(fkeys,",",i)_"=:"_OBJNAME_"."_$piece(acckeys,",",i)_" AND "
	.	S where=$E(where,1,$L(where)-5)
	.	;
	.	I 'del D  ; Restriction
	..		N ERMSG
	..		;
	..		; Record on file - delete restriction
	..		S ERMSG="$$^MSG(8563,"""_fkfid_"("_fkeys_") -> "_fid_"("_$$vStrUC(acckeys)_")"")"
	..		;
	..		; If number of keys match, can use Db.isDefined
	..		I $L(ftblkeys,",")=$L(acckeys,",") D
	...			S xcode=" if Db.isDefined("""_fkfid_""","""_where_""")"
	...			S xcode=xcode_" set vERRMSG = "_ERMSG
	...			S xcode=xcode_" throw Class.new(""Error"",""%PSL-E-DBFILER,""_vERRMSG.replace("","",""~""))"
	...			D ADD^DBSFILB(.code,xcode,"Restriction on delete")
	...			Q 
	..		;
	..		; Otherwise, need to do select
	..		E  D
	...			S xcode=" type ResultSet rs"_n_"=Db.select("""_fkeys_""","
	...			S xcode=xcode_""""_fkfid_""","""_where_""")"
	...			D ADD^DBSFILB(.code,xcode,"Restriction on delete")
	...			S xcode=" if 'rs"_n_".isEmpty()"
	...			S xcode=xcode_" set vERRMSG = "_ERMSG
	...			S xcode=xcode_" throw Class.new(""Error"",""%PSL-E-DBFILER,""_vERRMSG.replace("","",""~""))"
	...			D ADD^DBSFILB(.code,xcode)
	...			Q 
	..		Q 
	.	;
	.	E  D  ; Cascade
	..		S xcode=" do Db.delete("""_fkfid_""","""_where_""",vpar)"
	..		D ADD^DBSFILB(.code,xcode,"Cascade delete")
	..		;
	..		I ",ACN,DEP,LN,CIF,"[(","_fkfid_",") D
	...			WRITE !!?15," ** Warning ** Review cascade delete definition"
	...			WRITE !?15,xcode,!
	...			Q 
	..		Q 
	.	;
	.	D ADD^DBSFILB(.code,"")
	.	Q 
	;
	Q 
	;
CASDELST(fid,list)	;
	;
	N n S n=""
	;
	S n=$order(list(""),-1)+1
	;
	N rs,vos1,vos2,vos3,vos4,vos5  N V1 S V1=fid S rs=$$vOpen9()
	;
	F  Q:'($$vFetch9())  D
	.	S list(n)=$P(rs,$C(9),1)_"|"_$P(rs,$C(9),2)_"|"_$P(rs,$C(9),3)
	.	S n=n+1
	.	Q 
	;
	Q 
	;
ifComp(code)	; xecute DBTBL7.IFCOMP and return truth
	;
	N isTrue S isTrue=0
	D ifCompx(code,.isTrue)
	Q isTrue
	;
ifCompx(code,isTrue)	;
	;
	N cnt N seq
	N cmperr N m N psl
	;
	S psl(1)=" if "_code
	D cmpA2A^UCGM(.psl,.m,,,,,.cmperr) I $get(cmperr) D  Q 
	.	S ER=1
	.	S RM="Trigger condition compile error: "_code
	.	Q 
	;
	S cnt=0
	S seq=""
	F  S seq=$order(m(seq)) Q:(seq="")  S cnt=cnt+1
	I cnt>2 D  Q 
	.	S ER=1
	.	S RM="Invalid trigger condition - multi-line generated code: "_code
	.	Q 
	;
	N $ZT
	S $ZT="S ER=1,RM=""Invalid trigger condition: ""_code ZG "_($ZL-1)
	S cnt=$order(m("")) ; Get code to execute
	;  #ACCEPT DATE=11/11/03; PGM=Frank Sanchez; CR=Frank Sanchez
	XECUTE m(cnt)
	;
	S isTrue=$T
	;
	Q 
	;
vSIG()	;
	Q "60877^68879^Dan Russell^39664" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vStrLC(vObj,v1)	; String.lowerCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	S vObj=$translate(vObj,"ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ","abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛")
	I v1 S vObj=$$vStrUC($E(vObj,1))_$E(vObj,2,1048575)
	Q vObj
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
	; ----------------
	;  #OPTION ResultClass 0
vStrTrim(object,p1,p2)	; String.trim
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I p1'<0 S object=$$RTCHR^%ZFUNC(object,p2)
	I p1'>0 F  Q:$E(object,1)'=p2  S object=$E(object,2,1048575)
	Q object
	;
vDb3(v1,v2,v3)	;	voXN = Db.getRecord(DBTBL7,,0)
	;
	N dbtbl7
	S dbtbl7=$G(^DBTBL(v1,7,v2,v3))
	I dbtbl7="",'$D(^DBTBL(v1,7,v2,v3))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL7" X $ZT
	Q dbtbl7
	;
vDb4(v1,v2,v2out)	;	voXN = Db.getRecord(DBTBL1,,1,-2)
	;
	N dbtbl1
	S dbtbl1=$G(^DBTBL(v1,1,v2))
	I dbtbl1="",'$D(^DBTBL(v1,1,v2))
	S v2out='$T
	;
	Q dbtbl1
	;
vOpen1()	;	TRGID,TLD FROM DBTBL7 WHERE TABLE = :V1
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(V1) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^DBTBL(vos3),1) I vos3="" G vL1a0
	S vos4=""
vL1a5	S vos4=$O(^DBTBL(vos3,7,vos2,vos4),1) I vos4="" G vL1a3
	Q
	;
vFetch1()	;
	;
	I vos1=1 D vL1a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos5=$G(^DBTBL(vos3,7,vos2,vos4))
	S rs=$S(vos4=$C(254):"",1:vos4)_$C(9)_$P(vos5,"|",9)
	;
	Q 1
	;
vOpen2()	;	CODE FROM DBTBL7D WHERE TABLE = :V1 AND TRGID = :V2
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(V1) I vos2="" G vL2a0
	S vos3=$G(V2) I vos3="" G vL2a0
	S vos4=""
vL2a4	S vos4=$O(^DBTBL(vos4),1) I vos4="" G vL2a0
	S vos5=""
vL2a6	S vos5=$O(^DBTBL(vos4,7,vos2,vos3,vos5),1) I vos5="" G vL2a4
	Q
	;
vFetch2()	;
	;
	I vos1=1 D vL2a6
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos6=$G(^DBTBL(vos4,7,vos2,vos3,vos5))
	S rs=$P(vos6,$C(1),1)
	;
	Q 1
	;
vOpen3()	;	COLNAMES FROM UTBLPRODRL
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=""
vL3a2	S vos2=$O(^UTBL("PRODRL",vos2),1) I vos2="" G vL3a0
	Q
	;
vFetch3()	;
	;
	I vos1=1 D vL3a2
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos3=$G(^UTBL("PRODRL",vos2))
	S rs1=$P(vos3,"|",5)
	;
	Q 1
	;
vOpen4()	;	COLNAME FROM UTBLPRODRT
	;
	;
	S vos4=2
	D vL4a1
	Q ""
	;
vL4a0	S vos4=0 Q
vL4a1	S vos5=""
vL4a2	S vos5=$O(^UTBL("PRODRT",vos5),1) I vos5="" G vL4a0
	S vos6=""
vL4a4	S vos6=$O(^UTBL("PRODRT",vos5,vos6),1) I vos6="" G vL4a2
	Q
	;
vFetch4()	;
	;
	;
	I vos4=1 D vL4a4
	I vos4=2 S vos4=1
	;
	I vos4=0 Q 0
	;
	S rs2=$S(vos5=$C(254):"",1:vos5)
	;
	Q 1
	;
vOpen5()	;	DI FROM DBTBL1D WHERE FID = :V1 AND CMP IS NULL AND TYP NOT IN ('M','B')
	;
	;
	S vos1=2
	D vL5a1
	Q ""
	;
vL5a0	S vos1=0 Q
vL5a1	S vos2=$G(V1) I vos2="" G vL5a0
	S vos3=""
vL5a3	S vos3=$O(^DBTBL(vos3),1) I vos3="" G vL5a0
	S vos4=""
vL5a5	S vos4=$O(^DBTBL(vos3,1,vos2,9,vos4),1) I vos4="" G vL5a3
	S vos5=$G(^DBTBL(vos3,1,vos2,9,vos4))
	I '($P(vos5,"|",16)="") G vL5a5
	I '($P(vos5,"|",9)'="M"&($P(vos5,"|",9)'="B")) G vL5a5
	Q
	;
vFetch5()	;
	;
	;
	I vos1=1 D vL5a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen6()	;	FKEYS,TBLREF FROM DBTBL1F WHERE FID = :TABLE AND TBLREF IS NOT NULL
	;
	;
	S vos1=2
	D vL6a1
	Q ""
	;
vL6a0	S vos1=0 Q
vL6a1	S vos2=$G(TABLE) I vos2="" G vL6a0
	S vos3=""
vL6a3	S vos3=$O(^DBINDX(vos3),1) I vos3="" G vL6a0
	S vos4=""
vL6a5	S vos4=$O(^DBINDX(vos3,"FKPTR",vos4),1) I vos4="" G vL6a3
	I '(vos4'=$C(254)) G vL6a5
	S vos5=""
vL6a8	S vos5=$O(^DBINDX(vos3,"FKPTR",vos4,vos2,vos5),1) I vos5="" G vL6a5
	Q
	;
vFetch6()	;
	;
	;
	I vos1=1 D vL6a8
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos5=$C(254):"",1:vos5)_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen7()	;	FID FROM DBTBL8 WHERE FID = :V1
	;
	;
	S vos1=2
	D vL7a1
	Q ""
	;
vL7a0	S vos1=0 Q
vL7a1	S vos2=$G(V1) I vos2="" G vL7a0
	S vos3=""
vL7a3	S vos3=$O(^DBTBL(vos3),1) I vos3="" G vL7a0
	S vos4=""
vL7a5	S vos4=$O(^DBTBL(vos3,8,vos2,vos4),1) I vos4="" G vL7a3
	Q
	;
vFetch7()	;
	;
	;
	I vos1=1 D vL7a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=vos2
	;
	Q 1
	;
vOpen8()	;	FKEYS,TBLREF FROM DBTBL1F WHERE FID = :V1 AND TBLREF IS NOT NULL
	;
	;
	S vos1=2
	D vL8a1
	Q ""
	;
vL8a0	S vos1=0 Q
vL8a1	S vos2=$G(V1) I vos2="" G vL8a0
	S vos3=""
vL8a3	S vos3=$O(^DBINDX(vos3),1) I vos3="" G vL8a0
	S vos4=""
vL8a5	S vos4=$O(^DBINDX(vos3,"FKPTR",vos4),1) I vos4="" G vL8a3
	I '(vos4'=$C(254)) G vL8a5
	S vos5=""
vL8a8	S vos5=$O(^DBINDX(vos3,"FKPTR",vos4,vos2,vos5),1) I vos5="" G vL8a5
	Q
	;
vFetch8()	;
	;
	;
	I vos1=1 D vL8a8
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos5=$C(254):"",1:vos5)_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen9()	;	FID,FKEYS,DEL FROM DBTBL1F WHERE %LIBS='SYSDEV' AND TBLREF=:V1
	;
	;
	S vos1=2
	D vL9a1
	Q ""
	;
vL9a0	S vos1=0 Q
vL9a1	S vos2=$G(V1) I vos2="",'$D(V1) G vL9a0
	S vos3=""
vL9a3	S vos3=$O(^DBINDX("SYSDEV","FKPTR",vos2,vos3),1) I vos3="" G vL9a0
	S vos4=""
vL9a5	S vos4=$O(^DBINDX("SYSDEV","FKPTR",vos2,vos3,vos4),1) I vos4="" G vL9a3
	Q
	;
vFetch9()	;
	;
	I vos1=1 D vL9a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos5=$G(^DBTBL("SYSDEV",19,vos3,vos4))
	S rs=$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)_$C(9)_$P(vos5,"|",3)
	;
	Q 1
