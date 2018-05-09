DBSFILB	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSFILB ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	;I18N=OFF
	;
	Q 
	;
COPY(from,to,commands,PGMS)	;
	;
	I ($order(from(""))="") Q  ; Nothing to append
	;
	N n S n=""
	N line S line=$order(to(""),-1)
	;
	S line=line+1 S to(line)="" S line=line+1
	F  S n=$order(from(n)) Q:(n="")  S to(line)=from(n) S line=line+1
	Q 
	;
BUILDALL	; Build All Run-Time Filer Routines
	;
	N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen1()
	F  Q:'($$vFetch1())  D COMPILE(rs)
	Q 
	;
BUILD	; Build Run-Time Filer Routine
	;
	N COUNT
	N fid N RM
	;
	S COUNT=$$LIST^DBSGETID("DBTBL1") ; Interactive select
	Q:'COUNT 
	;
	N tmpdqrs,vos1,vos2,vos3  N V1 S V1=$J S tmpdqrs=$$vOpen2()
	;
	F  Q:'($$vFetch2())  D
	.	;
	.	S fid=tmpdqrs
	.	;
	.	N tblrec S tblrec=$$getSchTbl^UCXDD(fid)
	.	;
	.	; Error message only if selected a single table
	.	I ($P(tblrec,"|",6)="") D  Q 
	..		I COUNT=1 S RM=$$^MSG(3056,fid) WRITE !,$$MSG^%TRMVT(RM)
	..		Q 
	.	;
	.	D COMPILE(fid)
	.	Q 
	;
	 N V2 S V2=$J D vDbDe1()
	;
	Q 
	;
COMPILE(PSFILE,NLU,commands,PGMS)	;
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	;
	I '($D(^DBTBL("SYSDEV",1,PSFILE))) WRITE " Aborted - Table does not exist: ",PSFILE Q 
	WRITE !,PSFILE
	;
	 S ER=0
	;
	N %LIBS S %LIBS="SYSDEV"
	N cmperr
	;
	N hasLits N hasNegNd N vreqsec
	;
	N i N del N n N sourceH
	;
	N code N delstr N di N gbl N key N keys N keywhr N lvn N partbl N rectyp N tag N z
	N arch N archtbl N casdel N ctl N dft N jrn N keytrgs N labelmap
	N sections N vddver N vkchg N vreq N vsts N vtrg N zfkys N zindx
	N SOURCE
	;
	N file S file=PSFILE
	N tblrec S tblrec=$$getSchTbl^UCXDD(file)
	;
	N INDEXPGM S INDEXPGM=$P(tblrec,"|",6)
	I (INDEXPGM="") WRITE " Aborted - filer program is NULL" Q 
	;
	S PGMS=INDEXPGM
	;
	N isRDB S isRDB=$$rdb^UCDB(file)
	;
	N objName S objName=$$vStrLC($translate(file,"_"),0)
	;
	N rs,vos1,vos2,vos3  N V1 S V1=file S rs=$$vOpen3()
	I '$G(vos1) S hasLits=0
	E  S hasLits=1
	;
	D ADD(.SOURCE,INDEXPGM_"(Record"_file_" "_objName_", String vpar, Boolean vparNorm) // "_file_" - "_$P(tblrec,"|",31)_" Filer")
	D ^SCACOPYR(.z)
	D ADD(.SOURCE," // "_$piece(z,";;",2,$L(z)))
	D ADD(.SOURCE," // Generated from DATA-QWIK schema in: "_$$CURR^%DIR_"  by: "_$$PGMDIR($T(+0)))
	D ADD(.SOURCE,"")
	;
	S sourceH=$order(SOURCE(""),-1) ; Mark location
	;
	D ADD(.SOURCE," /*")
	D ADD(.SOURCE,"  vpar      Runtime qualifiers:      /NOREQ/MECH=REFARR:R")
	D ADD(.SOURCE,"")
	D ADD(.SOURCE,"  /[NO]CASDEL   - Cascade delete")
	D ADD(.SOURCE,"  /[NO]FRMFILER - Called from another filer")
	D ADD(.SOURCE,"  /[NO]INDEX    - Update Indexes")
	D ADD(.SOURCE,"  /[NO]JOURNAL  - Journal update")
	D ADD(.SOURCE,"  /[NO]TRIGAFT  - After update triggers")
	D ADD(.SOURCE,"  /[NO]TRIGBEF  - Before update triggers")
	D ADD(.SOURCE,"  /[NO]UPDATE   - Update primary table")
	D ADD(.SOURCE,"  /[NO]VALDD    - Validate column values")
	D ADD(.SOURCE,"  /[NO]VALFK    - Validate foreign keys")
	D ADD(.SOURCE,"  /[NO]VALREQ   - Validate not null values")
	D ADD(.SOURCE,"  /[NO]VALRI    - Validate transaction integrity")
	D ADD(.SOURCE,"  /[NO]VALST    - Validate database state")
	D ADD(.SOURCE," */")
	D ADD(.SOURCE,"")
	;
	; P01 still depends on ER and RM from the filers
	D ADD(.SOURCE," type Public Number ER = 0")
	D ADD(.SOURCE," type Public String RM")
	D ADD(.SOURCE,"")
	;
	D ADD(.SOURCE," type public String verrors()")
	D ADD(.SOURCE,"")
	;
	; Add catch block for P01 error handling of DBFILER errors - rethrow GT.M errors
	D ADD(.SOURCE," catch fERROR {")
	D ADD(.SOURCE,"  if fERROR.type=""%PSL-E-DBFILER"" do {")
	D ADD(.SOURCE,"   set ER = 1")
	D ADD(.SOURCE,"   set RM = fERROR.description")
	D ADD(.SOURCE,"  }")
	D ADD(.SOURCE,"  else  throw fERROR")
	D ADD(.SOURCE," }")
	;
	S gbl=$P(tblrec,"|",2)
	S keys=$P(tblrec,"|",3)
	S rectyp=$P(tblrec,"|",4)
	S del=$P(tblrec,"|",10)
	I 'isRDB S archtbl=$$getArchiveTable^DBARCHIVE(tblrec)
	E  S archtbl=""
	;
	; If table has negative nodes (like DBTBL2), need to remap "v" node
	; when going between vobj and global
	I ($P(tblrec,"|",15)["""v") S hasNegNd=1
	E  S hasNegNd=0
	;
	I '(del="") D
	.	;
	.	I (del<32)!(del>127) S delstr="$C("_del_")"
	.	E  S delstr=$$QADD^%ZS($char(del),"""")
	.	Q 
	;
	I isRDB S rectyp=$$RDBRCTYP(file)
	;
	S gbl=$$getGbl^UCXDD(tblrec,objName)
	; If has archive reference, remove it.  Filer does not use it and
	; vobj(,-99) is not always passed in, e.g., on a Class.new
	I $E(gbl,1,2)="^|" S gbl="^"_$piece(gbl,"|",3,$L(gbl))
	I ($E(gbl,$L(gbl))=",") S gbl=$E(gbl,1,$L(gbl)-1)
	S keywhr=$$KEYWHR(file,keys,objName,isRDB,0)
	;
	; Find the parent table of this table to support Db.isDefined() method
	; properly.  This should be fixed in isDefined itself.
	S partbl=$$PARTBL(file,tblrec) ; Top of hierarchy
	;
	D ADD(.SOURCE," type String vx(), vxins()","audit column array")
	D ADD(.SOURCE," type Number %O = "_objName_".getMode()","Processing mode")
	D ADD(.SOURCE," set vpar = vpar.get()","Initialize vpar")
	;
	D ADD(.SOURCE,"","")
	I '(archtbl="") D
	.	;
	.	D ADD(.SOURCE,"","Cannot modify records in archive file")
	.	;
	.	S code=" if (%O '= 2), (vpar '[ ""NOUPDATE""), "
	.	S code=code_$$getCHECK^DBSFILARCH(file,archtbl,objName)
	.	; fix this once get error #
	.	S code=code_" throw Class.new(""Error"",""%PSL-E-DBFILER,""_$$^MSG(6906).replace("","",""~""))"
	.	;
	.	D ADD(.SOURCE,code)
	.	D ADD(.SOURCE,"","")
	.	Q 
	;
	D ADD(.SOURCE," if %O = 0 do AUDIT^UCUTILN("_objName_",.vxins(),"_rectyp_","_delstr_")")
	S z=" if %O = 1"
	I rectyp>1 S z=z_" quit:'"_objName_".isChanged() "
	S z=z_" do AUDIT^UCUTILN("_objName_",.vx(),"_rectyp_","_delstr_")"
	D ADD(.SOURCE,z)
	D ADD(.SOURCE,"")
	;
	; Index code
	I 'isRDB D  Q:ER  ; Skip for RDB
	.	N rs,vos4,vos5,vos6,vos7  N V2 S V2=file S rs=$$vOpen4()
	.	I ''$G(vos4) D ^DBSINDXB(file,.zindx) ; Index file logic
	.	Q 
	;
	D DEFTBL^DBSTRG(PSFILE,.dft,tblrec) ; Default logic
	I dft S sections("vinit")=""
	;
	I 'isRDB D
	.	D REQUIRD^DBSTRG(PSFILE,.vreq,tblrec) ; Required logic (if GT.M)
	.	I '($order(vreq(""))="") S sections("vreq")=""
	.	Q 
	;
	D VDD^DBSTRG(PSFILE,.vddver,tblrec,isRDB) Q:ER  ; Validate data types
	I '($order(vddver(""))="") S sections("vddver")=""
	;
	D ^DBSJRNC(file,.jrn) ; Journal file logic
	I ER WRITE " Aborted - journal error - ",RM,! Q 
	;
	; Archive code
	I '(archtbl="") D  Q:ER 
	.	;
	.	I '(archtbl="") D ^DBSFILARCH(file,archtbl,.arch)
	.	I ER WRITE " Aborted - archive error - ",RM,!
	.	Q 
	;
	; Trigger definitions
	D COMPILE^DBSTRG(file,.vtrg,.vsts,.keytrgs,isRDB,tblrec,.labelmap)
	;
	I 'isRDB D FKEYS^DBSTRG(file,.zfkys,tblrec) ; Foreign key logic
	;
	D CASDEL^DBSTRG(file,.casdel,tblrec) ; Cascade delete logic
	;
	; Add statistical documentation
	D ADDDOC(.SOURCE,.sourceH,.vddver,"1D")
	D ADDDOC(.SOURCE,.sourceH,.vtrg,7)
	D ADDDOC(.SOURCE,.sourceH,.zindx,8)
	D ADDDOC(.SOURCE,.sourceH,.jrn,9)
	;
	D ADD(.SOURCE," if 'vparNorm.get() set vpar = $$initPar^UCUTILN(vpar)","Run-time qualifiers")
	;
	; Define access keys as local variables to support legacy
	I '(keys=""),'($order(vsts(""))="") D
	.	;
	.	D ADD(.SOURCE,"")
	.	D ADD(.SOURCE," // Define local variables for access keys for legacy triggers")
	.	F i=1:1:$L(keys,",") D
	..		;
	..		N di S di=$piece(keys,",",i)
	..		N var S var=$$vStrUC($translate(di,"_"))
	..		;
	..		D ADD(.SOURCE," type String "_var_" = "_objName_"."_$$vStrLC(di,0))
	..		Q 
	.	Q 
	;
	D ADD(.SOURCE,"")
	;
	N savLine S savLine=$order(SOURCE(""),-1)
	S SOURCE(savLine+100)="" ; Save 100 lines for control block
	D ADD(.SOURCE," quit")
	;
	D
	.	N keylist S keylist=""
	.	;
	.	D TAG(.SOURCE,"vlegacy(Number %ProcessMode,String vpar) // Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)")
	.	;
	.	; Define keys -- they will be public
	.	I '(keys="") D
	..		F i=1:1:$L(keys,",") D
	...			N di S di=$piece(keys,",",i)
	...			N var S var=$$vStrUC($translate(di,"_"))
	...			D ADD(.SOURCE," type public String "_var)
	...			S keylist=keylist_var_"=:"_var_","
	...			Q 
	..		Q 
	.	;
	.	S keylist=$E(keylist,1,$L(keylist)-1)
	.	D ADD(.SOURCE,"")
	.	D ADD(.SOURCE," type Record"_file_" "_objName_" = Db.getRecord("""_file_""","""_keylist_""")")
	.	D ADD(.SOURCE," if (%ProcessMode = 2) do {")
	.	D ADD(.SOURCE,"  do "_objName_".setMode(2)")
	.	D ADD(.SOURCE,"")
	.	D ADD(.SOURCE,"  do "_INDEXPGM_"("_objName_",vpar)")
	.	D ADD(.SOURCE," }")
	.	I '($order(zindx(""))="") D ADD(.SOURCE," else  do VINDEX("_objName_")")
	.	D ADD(.SOURCE,"")
	.	D ADD(.SOURCE," quit")
	.	Q 
	;
	; Add function to return indicator if table involved in literals or not
	I hasLits D
	.	D TAG(.SOURCE,"vLITCHK() quit 1 // Table has columns involved in literals")
	.	Q 
	E  D TAG(.SOURCE,"vLITCHK() quit 0 // Table does not have columns involved in literals")
	;
	D TAG(.SOURCE,"vexec // Execute transaction")
	;
	D ADD(.SOURCE," type public Number %O")
	D ADD(.SOURCE," type public String vpar,vobj(),vx(),vxins()")
	D ADD(.SOURCE,"")
	D ADD(.SOURCE," type public Record"_file_" "_objName)
	D ADD(.SOURCE,"")
	D ADD(.SOURCE," type String vERRMSG")
	D ADD(.SOURCE,"")
	;
	; 7932 = Record Not Defined; 2327 = Record already exists
	D ADD(.SOURCE," if vpar[""/VALST/"" if '(''Db.isDefined("""_partbl_""","""_keywhr_""") = ''%O) set vERRMSG = $$^MSG($select(%O:7932,1:2327)) throw Class.new(""Error"",""%PSL-E-DBFILER,""_vERRMSG.replace("","",""~""))")
	;
	I '($order(zfkys(""))="") D
	.	D ADD(.SOURCE," if vpar[""/VALFK/"" do CHKFKS","Check foreign keys")
	.	D ADD(.SOURCE," if vpar[""/VALRI/"" do VFKEYS","Foreign key definition")
	.	Q 
	;
	D ADD(.SOURCE,"")
	D ADD(.SOURCE," if vpar'[""/NOUPDATE/"" do {")
	;
	D MAIN(file,tblrec) ; Build main update code
	;
	I '($order(jrn(""))="") D
	.	N saveline
	.	D ADD(.SOURCE,"")
	.	D ADD(.SOURCE,"  if vpar[""/JOURNAL/"" do VJOURNAL(."_objName_")","Create journal files",.saveline)
	.	Q 
	;
	D ADD(.SOURCE," }")
	;
	; Always update index if requested, regardless of state of UPDATE flag
	I '($order(zindx(""))="") D
	.	N saveline
	.	D ADD(.SOURCE,"")
	.	D ADD(.SOURCE," if vpar[""/INDEX/"",'(%O = 1)!'vx("""").order().isNull() do VINDEX(."_objName_")","Update Index files",.saveline)
	.	Q 
	;
	D ADD(.SOURCE,"")
	D ADD(.SOURCE," quit")
	;
	; Add procedures to load complete record and create -100 index
	;
	I rectyp>1 D
	.	;
	.	D TAG(.SOURCE,"vload // Record Load - force loading of unloaded data")
	.	D ADD(.SOURCE," type public Record"_file_" "_objName)
	.	;
	.	I 'isRDB D
	..		N code N gblref
	..		;
	..		I $E(gbl,$L(gbl))="(" S gblref=gbl_"n)" ; CUVAR style
	..		E  S gblref=gbl_",n)"
	..		;
	..		D ADD(.SOURCE," type String n = """"")
	..		I hasNegNd D ADD(.SOURCE," type String vn")
	..		D ADD(.SOURCE,"")
	..		D ADD(.SOURCE," // Allow global reference")
	..		D ADD(.SOURCE," #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS")
	..		D ADD(.SOURCE," #BYPASS")
	..		S code=" for  set n=$order("_gblref_") quit:n=""""  "
	..		I hasNegNd S code=code_"s vn=$S(n<0:""v""_-n,1:n) if '$D(vobj("_objName_",vn)),$D("_gblref_")#2 set vobj("_objName_",vn)=^(n)"
	..		E  S code=code_"if '$D(vobj("_objName_",n)),$D("_gblref_")#2 set vobj("_objName_",n)=^(n)"
	..		D ADD(.SOURCE,code)
	..		D ADD(.SOURCE," #ENDBYPASS")
	..		D ADD(.SOURCE," quit")
	..		Q 
	.	;
	.	E  D
	..		;
	..		D ADD(.SOURCE," type String X")
	..		D ADD(.SOURCE,"")
	..		;
	..		N rs,vos8,vos9,vos10,vos11,vos12,vOid  N V2 S V2=file S rs=$$vOpen5()
	..		F  Q:'($$vFetch5())  D
	...			N rtbl S rtbl=rs
	...			;
	...			N rs2,vos13,vos14,vos15,vos16,vos17,vos18  N V3,V4 S V3=file,V4=rtbl S rs2=$$vOpen6()
	...			;
	...			I $$vFetch6() D
	....				;
	....				N column S column=rs2
	....				;
	....				D ADD(.SOURCE," set X = "_objName_"."_column)
	....				Q 
	...			Q 
	..		;
	..		D ADD(.SOURCE," quit")
	..		Q 
	.	Q 
	;
	D TAG(.SOURCE,"vdelete(Boolean vkeychg) // Record Delete")
	D ADD(.SOURCE," type public String vobj(),vpar")
	I isRDB D ADD(.SOURCE," type String vlist")
	D ADD(.SOURCE," type public Record"_file_" "_objName)
	D ADD(.SOURCE,"")
	;
	I isRDB D
	.	D ADD(.SOURCE," type Boolean vER")
	.	D ADD(.SOURCE," type String vRM")
	.	I '(keys="") D
	..		N i
	..		N code S code=""
	..		F i=1:1:$L(keys,",") S code=code_"vkey"_i_","
	..		S code=" type String "_$E(code,1,$L(code)-1)
	..		D ADD(.SOURCE,code)
	..		Q 
	.	Q 
	;
	I rectyp>1 D
	.	D ADD(.SOURCE," if 'vkeychg.get(),"_objName_".isChanged() throw Class.new(""Error"",""%PSL-E-DBFILER,Deleted object cannot be modified"")")
	.	D ADD(.SOURCE,"")
	.	Q 
	;
	I '($order(casdel(""))="") D
	.	N saveline
	.	D ADD(.SOURCE," if vpar[""/CASDEL/"" do VCASDEL","Cascade delete",.saveline)
	.	Q 
	I '($order(zindx(""))="") D
	.	N saveline
	.	D ADD(.SOURCE," if vpar[""/INDEX/"" do VINDEX(."_objName_")","Delete index entries",.saveline)
	.	Q 
	I '($order(jrn(""))="") D
	.	N saveline
	.	D ADD(.SOURCE," if vpar[""/JOURNAL/"" do VJOURNAL(."_objName_")","Create journal entries",.saveline)
	.	Q 
	I $P(tblrec,"|",16) D ADD(.SOURCE," if vpar'[""/NOLOG/"" do ^DBSLOGIT("_objName_",3)")
	;
	I 'isRDB D
	.	;
	.	S z=" kill "
	.	I rectyp<10,'(($P(tblrec,"|",5)["M")!($P(tblrec,"|",5)["B")) S z=" ZWI "
	.	I '($P(tblrec,"|",3)="") D
	..		D ADD(.SOURCE,"")
	..		D ADD(.SOURCE," // Allow global reference - Delete record")
	..		D ADD(.SOURCE," #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS")
	..		D ADD(.SOURCE," #BYPASS")
	..		D ADD(.SOURCE,z_gbl_")")
	..		D ADD(.SOURCE," #ENDBYPASS")
	..		Q 
	.	Q 
	;
	E  D  Q:ER 
	.	;
	.	N cnt
	.	N sql
	.	;
	.	I (keys="") D
	..		D ADD(.SOURCE," set vlist=""""")
	..		Q 
	.	E  D
	..		N code S code=""
	..		F i=1:1:$L(keys,",") D
	...			;
	...			N isNum S isNum=0
	...			N di S di=$piece(keys,",",i)
	...			;
	...			N rec S rec=$$getSchCln^UCXDD(file,di)
	...			;
	...			I '($P(rec,"|",6)=""),"N$L"[$P(rec,"|",6) S isNum=1
	...			;
	...			I '(code="") S code=code_"_"_delstr_"_"
	...			S code=code_objName_"."_$$vStrLC(di,0)
	...			D ADD(.SOURCE," set vkey"_i_"="_objName_"."_$$vStrLC(di,0))
	...			Q 
	..		;
	..		D ADD(.SOURCE," set vlist="_code_"_"_delstr)
	..		Q 
	.	;
	.	I (keywhr="") S sql(1)="DELETE FROM "_file
	.	E  I 'isRDB S sql(1)="DELETE FROM "_file_" WHERE "_keywhr
	.	E  D  Q:ER 
	..		;
	..		N keywhrn N nattable
	..		;
	..		S keywhrn=$$KEYWHR(file,keys,"",1,1,.nattable)
	..		;
	..		; Handle wide tables (one table split into multiple)
	..		F cnt=1:1:$L(nattable,",") S sql(cnt)="DELETE FROM "_$piece(nattable,",",cnt)_" WHERE "_keywhrn
	..		Q 
	.	;
	.	S cnt=""
	.	F  S cnt=$order(sql(cnt)) Q:(cnt="")  D
	..		D ADD(.SOURCE," set vER = $$EXECUTE^%DBAPI("""","_$S(sql(cnt)'["""":""""_sql(cnt)_"""",1:$$QADD^%ZS(sql(cnt),""""))_","_delstr_",vlist,.vRM)")
	..		D ADD(.SOURCE," if (vER<0) throw Class.new(""Error"",""%PSL-E-DBFILER,""_vRM.get().replace("","",""~""))")
	..		Q 
	.	Q 
	;
	D ADD(.SOURCE," quit")
	;
	I dft D COPY(.dft,.SOURCE,,.PGMS) ; Default section
	D COPY(.vreq,.SOURCE,,.PGMS) ; Required items
	D COPY(.zfkys,.SOURCE,,.PGMS) ; Foreign key definition
	;
	D COPY(.vtrg,.SOURCE,.commands,.PGMS) ; Trigger definition
	D COPY(.vddver,.SOURCE,.commands,.PGMS) ; Column validation
	D COPY(.jrn,.SOURCE,.commands,.PGMS) ; Journal definitions
	D COPY(.zindx,.SOURCE,.commands,.PGMS) ; Index definitions
	D COPY(.arch,.SOURCE,.commands,.PGMS) ; Archive code
	;
	S vreqsec=($D(sections("vreq"))#2)
	; Key changed logic
	D KEYCHG^DBSTRG(file,.vkchg,tblrec,.vsts,.keytrgs,vreqsec,.sections,rectyp,isRDB)
	;
	D COPY(.vkchg,.SOURCE,,.PGMS)
	;
	I '($order(casdel(""))="") D
	.	;
	.	S casdel(.1)="VCASDEL // Cascade delete logic"
	.	S casdel(.2)=""
	.	S casdel($order(casdel(""),-1)+1)=$char(9)_"quit"
	.	D COPY(.casdel,.SOURCE,.commands,.PGMS)
	.	Q 
	;
	; Generate & insert control blocks
	D CONTROL(file,.ctl,.sections,.vsts,tblrec,isRDB,partbl,keywhr,hasLits)
	;
	S n=""
	F  S n=$order(ctl(n)) Q:(n="")  S savLine=savLine+1 S SOURCE(savLine)=ctl(n)
	;
	; Add VIDXPGM function
	I '($order(zindx(""))="") D TAG(.SOURCE,"VIDXPGM()"_$char(9)_"quit """_INDEXPGM_""""_$char(9)_"// Location of index program")
	;
	; Call PSL compiler
	D cmpA2F^UCGM(.SOURCE,INDEXPGM,,,.commands,,.cmperr,file_"~Filer")
	;
	I +$get(cmperr) S ER=1
	E  D  ; Save label map
	.	;
	.	N label
	.	;
	.	D vDbDe2()
	.	;
	.	S label=""
	.	F  S label=$order(labelmap(label)) Q:(label="")  D
	..		;
	..		N dblm,vop1,vop2,vop3 S dblm="",vop2=INDEXPGM,vop1=label,vop3=0
	..		;
	..	 S $P(dblm,$C(124),1)=$piece(labelmap(label),"|",1)
	..	 S $P(dblm,$C(124),2)=$piece(labelmap(label),"|",2)
	..		;
	..	 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^DBINDX("SYSDEV","LABELMAP",vop2,vop1)=$$RTBAR^%ZFUNC(dblm) S vop3=1 Tcommit:vTp  
	..		Q 
	.	Q 
	;
	Q 
	;
CONTROL(fid,code,sections,vsts,tblrec,isRDB,partbl,keywhr,hasLits)	;
	;
	N vreqsec S vreqsec=($D(sections("vreq"))#2)
	N saveline
	N keys S keys=$P(tblrec,"|",3)
	;
	; Insert program control logic into saved position for all %O
	;
	D ADD(.code," if %O = 0 do { quit","Create record control block")
	I ($D(sections("vinit"))#2) D ADD(.code,"  do vinit","Initialize column values")
	I ($D(vsts("BI"))#2) D ADD(.code,"  if vpar[""/TRIGBEF/"" do "_vsts("BI"),"Before insert triggers")
	I 'isRDB,vreqsec D ADD(.code,"  if vpar[""/VALREQ/"" do vreqn","Check required")
	I ($D(sections("vddver"))#2) D ADD(.code,"  if vpar[""/VALDD/"" do vddver","Check values",.saveline)
	D ADD(.code,"  do vexec")
	I ($D(vsts("AI"))#2) D ADD(.code,"  if vpar[""/TRIGAFT/"" do "_vsts("AI"),"After insert triggers")
	I hasLits D ADD(.code,"  do SET^UCLREGEN("""_fid_""",""*"")","Literal references to "_fid_" exist")
	D ADD(.code," }")
	D ADD(.code,"")
	;
	D ADD(.code," if %O = 1 do { quit","Update record control block")
	;
	; Check for key change, add call to key change logic
	I '(keys="") D
	.	;
	.	N i
	.	N z
	.	;
	.	S z="  if vx("_$$QADD^%ZS($piece(keys,",",1),"""")_").exists()"
	.	F i=2:1:$L(keys,",") S z=z_"!vx("_$$QADD^%ZS($piece(keys,",",i),"""")_").exists()"
	.	S z=z_" do vkchged quit"
	.	;
	.	D ADD(.code,z,"Primary key changed")
	.	Q 
	;
	I ($D(vsts("BU"))#2) D ADD(.code,"  if vpar[""/TRIGBEF/"" do "_vsts("BU"),"Before update triggers")
	I 'isRDB,vreqsec D ADD(.code,"  if vpar[""/VALREQ/"" do vrequ","Check required")
	;
	D ADD(.code,"  if vpar[""/VALDD/"" do VDDUX^DBSFILER("""_fid_""",.vx)")
	D ADD(.code,"  set %O = 1 do vexec")
	I ($D(vsts("AU"))#2) D ADD(.code,"  if vpar[""/TRIGAFT/"" do "_vsts("AU"),"After update triggers")
	;
	I hasLits D
	.	D ADD(.code,"  do {","Check to see if updated columns involved in literal references")
	.	D ADD(.code,"   type String vcol, vlitcols()")
	.	D ADD(.code,"")
	.	D ADD(.code,"   type ResultSet rslits = Db.select(""DISTINCT COLUMN"", ""SYSMAPLITDTA"", ""TABLE='"_fid_"'"")")
	.	D ADD(.code,"   while rslits.next()  set vlitcols(rslits.getCol(""COLUMN"")) = """"")
	.	D ADD(.code,"")
	.	D ADD(.code,"   set vcol = """"")
	.	D ADD(.code,"   for  set vcol = vlitcols(vcol).order() quit:vcol.isNull()  if vx(vcol).exists() do SET^UCLREGEN("""_fid_""",vcol)")
	.	D ADD(.code,"  }")
	.	Q 
	D ADD(.code," }")
	D ADD(.code,"")
	;
	D ADD(.code," if %O = 2 do { quit","Verify record control block")
	I 'isRDB,vreqsec D ADD(.code,"  if vpar[""/VALREQ/"" do vreqn","Check required")
	I ($D(sections("vddver"))#2) D ADD(.code,"  if vpar[""/VALDD/"" do vddver","Check values",.saveline)
	D ADD(.code,"  set vpar = $$setPar^UCUTILN(vpar,""NOJOURNAL/NOUPDATE"")")
	D ADD(.code,"  do vexec")
	I ($D(vsts("AI"))#2) D ADD(.code,"  if vpar[""/TRIGAFT/"" do "_vsts("AI"),"After insert triggers")
	D ADD(.code," }")
	D ADD(.code,"")
	;
	D ADD(.code," if %O = 3 do { quit","Delete record control block")
	D ADD(.code,"  quit:'Db.isDefined("""_partbl_""","""_keywhr_""")","No record exists")
	I ($D(vsts("BD"))#2) D ADD(.code,"  if vpar[""/TRIGBEF/"" do "_vsts("BD"),"Before delete triggers")
	D ADD(.code,"  do vdelete(0)")
	I ($D(vsts("AD"))#2) D ADD(.code,"  if vpar[""/TRIGAFT/"" do "_vsts("AD"),"After delete triggers")
	I hasLits D ADD(.code,"  do SET^UCLREGEN("""_fid_""",""*"")","Literal references to "_fid_" exist")
	D ADD(.code," }")
	;
	Q 
	;
MAIN(file,tblrec)	;
	;
	N hasNegNd S hasNegNd=($P(tblrec,"|",15)["""v")
	N gblref N gblref1 N gblref2 N z
	N keys S keys=$P(tblrec,"|",3)
	N MBNodes N NegNodes
	N rectyp S rectyp=$P(tblrec,"|",4)
	N del S del=$P(tblrec,"|",10)
	;
	N objName S objName=$$vStrLC($translate(PSFILE,"_"),0)
	N gbl S gbl=$$getGbl^UCXDD(tblrec,objName)
	;
	; If has archive reference, remove it.  Filer does not use it and
	; vobj(,-99) is not always passed in, e.g., on a Class.new
	I $E(gbl,1,2)="^|" S gbl="^"_$piece(gbl,"|",3,$L(gbl))
	;
	I ($P(tblrec,"|",3)="") D  ; CUVAR style
	.	;
	.	I hasNegNd S gblref=gbl_"vn)"
	.	E  S gblref=gbl_"n)"
	.	S gblref1=$piece(gbl,"(",1)
	.	S gblref2=gbl
	.	Q 
	E  D
	.	;
	.	I hasNegNd S gblref=gbl_"vn)"
	.	E  S gblref=gbl_"n)"
	.	S gblref1=$E(gbl,1,$L(gbl)-1)_")"
	.	S gblref2=gbl
	.	Q 
	;
	N sn S sn="vobj("_objName_")"
	;
	N isRDB S isRDB=$$rdb^UCDB(PSFILE)
	N hasMB S hasMB=(($P(tblrec,"|",5)["M")!($P(tblrec,"|",5)["B"))
	;
	; Memos, blobs, and negative nodes have special handling
	S (MBNodes,NegNodes)=""
	I hasMB D
	.	;
	.	N rs,vos1,vos2,vos3,vos4,vos5  N V1 S V1=file S rs=$$vOpen7()
	.	;
	.	F  Q:'($$vFetch7())  S MBNodes=$S(((","_MBNodes_",")[(","_rs_",")):MBNodes,1:$S((MBNodes=""):rs,1:MBNodes_","_rs))
	.	Q 
	;
	; Get list of negative nodes - only need one column per node
	I hasNegNd D
	.	;
	.	N rs,vos6,vos7,vos8,vos9,vos10,vos11  N V1 S V1=file S rs=$$vOpen8()
	.	;
	.	F  Q:'($$vFetch8())  D
	..		;
	..		I ($E($P(rs,$C(9),1),1)="-") D
	...			;
	...			N colrec S colrec=$$getPslCln^UCXDD(file,$P(rs,$C(9),2))
	...			;
	...			S NegNodes=$S(((","_NegNodes_",")[(","_$$getCurNode^UCXDD(colrec,1)_",")):NegNodes,1:$S((NegNodes=""):$$getCurNode^UCXDD(colrec,1),1:NegNodes_","_$$getCurNode^UCXDD(colrec,1)))
	...			Q 
	..		Q 
	.	Q 
	;
	N sys S sys=$P(tblrec,"|",20)
	N cdate S cdate=$$LOG($P(tblrec,"|",22),sys,"D",objName)
	N ctime S ctime=$$LOG($P(tblrec,"|",23),sys,"T",objName)
	N cuser S cuser=$$LOG($P(tblrec,"|",24),sys,"U",objName)
	N udate S udate=$$LOG($P(tblrec,"|",25),sys,"D",objName)
	N utime S utime=$$LOG($P(tblrec,"|",26),sys,"T",objName)
	N uuser S uuser=$$LOG($P(tblrec,"|",27),sys,"U",objName)
	;
	D ADD(.SOURCE,"")
	;
	; If the same column us updates for new and update, promote logic
	I '(cdate=""),cdate=udate D ADD(.SOURCE," "_cdate) S (cdate,udate)=""
	I '(ctime=""),ctime=utime D ADD(.SOURCE," "_ctime) S (ctime,utime)=""
	I '(cuser=""),cuser=uuser D ADD(.SOURCE," "_cuser) S (cuser,uuser)=""
	;
	I '(cdate="") D ADD(.SOURCE,"  if %O = 0 "_cdate)
	I '(ctime="") D ADD(.SOURCE,"  if %O = 0 "_ctime)
	I '(cuser="") D ADD(.SOURCE,"  if %O = 0 "_cuser)
	I '(udate="") D ADD(.SOURCE,"  if %O = 1 "_udate)
	I '(utime="") D ADD(.SOURCE,"  if %O = 1 "_utime)
	I '(uuser="") D ADD(.SOURCE,"  if %O = 1 "_uuser)
	;
	I $P(tblrec,"|",16) D
	.	;
	.	D ADD(.SOURCE,"  if %O = 0, vpar'[""/NOLOG/"" do ^DBSLOGIT("_objName_",%O,.vxins())")
	.	D ADD(.SOURCE,"  if %O = 1, vpar'[""/NOLOG/"" do ^DBSLOGIT("_objName_",%O,.vx())")
	.	D ADD(.SOURCE,"")
	.	Q 
	;
	I isRDB D  Q 
	.	;
	.	D ADD(.SOURCE,"  type String del")
	.	D ADD(.SOURCE,"  set del = "_del_".char()")
	.	D ADD(.SOURCE,"  do VOBJ^DBSDBASE("_objName_",del)")
	.	;
	.	Q 
	;
	; ----- Remaining code is for M database updates ---------------------
	;
	I rectyp>1 D
	.	;
	.	D ADD(.SOURCE,"  type String n = -1")
	.	D ADD(.SOURCE,"  type String x")
	.	I hasNegNd D ADD(.SOURCE,"  type String vn")
	.	D ADD(.SOURCE,"")
	.	;
	.	D MSAVE(0,tblrec,objName,MBNodes,NegNodes)
	.	D MSAVE(1,tblrec,objName,MBNodes,NegNodes)
	.	;
	.	; Top level for type 11
	.	I (rectyp=11) D
	..		;
	..		D ADD(.SOURCE,"  // Allow global reference and M source code")
	..		D ADD(.SOURCE,"  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS")
	..		D ADD(.SOURCE,"  #BYPASS")
	..		D ADD(.SOURCE,"  if $D(vobj("_objName_"))"_$$getSavCode^UCXDD(tblrec,objName,"",-1))
	..		D ADD(.SOURCE,"  #ENDBYPASS")
	..		Q 
	.	Q 
	;
	I (rectyp=1) D
	.	;
	.	D ADD(.SOURCE,"  // Allow global reference and M source code")
	.	D ADD(.SOURCE,"  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS")
	.	D ADD(.SOURCE,"  #BYPASS")
	.	D ADD(.SOURCE,"  if $D(vobj("_objName_"))"_$$getSavCode^UCXDD(tblrec,objName,"",-1))
	.	D ADD(.SOURCE,"  #ENDBYPASS")
	.	;
	.	I hasMB D
	..		;
	..		N nodeRef
	..		;
	..		; Will only be a single column
	..		N colrec S colrec=$$getSchCln^UCXDD(file,$piece(MBNodes,",",1))
	..		;
	..		S nodeRef=$$getCurNode^UCXDD(colrec,1)
	..		;
	..		D ADD(.SOURCE,"   // Allow global reference and M source code")
	..		D ADD(.SOURCE,"   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS")
	..		D ADD(.SOURCE,"   #BYPASS")
	..		D ADD(.SOURCE,"   if $D(vobj("_objName_","_nodeRef_"))"_$$getSavCode^UCXDD(tblrec,objName,"*"_$piece(MBNodes,",",1),-1))
	..		D ADD(.SOURCE,"   #ENDBYPASS")
	..		Q 
	.	Q 
	;
	Q 
	;
MSAVE(MODE,tblrec,objName,MBNodes,NegNodes)	;
	;
	N I
	N col
	;
	; Code to file new type 10 or 11 record
	I (MODE=0) D ADD(.SOURCE,"  if %O = 0 for  set n = vobj("_objName_",n).order() quit:n.isNull()  do {")
	I (MODE=1) D ADD(.SOURCE,"  else  for  set n = vobj("_objName_",-100,n).order() quit:n.isNull()  do {")
	;
	; Handle memos and blobs
	F I=1:1:$S((MBNodes=""):0,1:$L(MBNodes,",")) D
	.	;
	.	N nodeRef
	.	;
	.	S col=$piece(MBNodes,",",I)
	.	;
	.	N colrec S colrec=$$getSchCln^UCXDD($P(tblrec,"|",1),col)
	.	;
	.	; Strip ,1 from CurrentNode
	.	I (MODE=0) D
	..		;
	..		S nodeRef=$$getCurNode^UCXDD(colrec,1)
	..		S nodeRef=$E(nodeRef,1,$L(nodeRef)-2)
	..		Q 
	.	E  S nodeRef=$$getOldNode^UCXDD(colrec,1)
	.	;
	.	D ADD(.SOURCE,"   if n = "_nodeRef_" do { quit")
	.	D ADD(.SOURCE,"    // Allow global reference and M source code")
	.	D ADD(.SOURCE,"    #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS")
	.	D ADD(.SOURCE,"    #BYPASS")
	.	D ADD(.SOURCE,"    "_$$getSavCode^UCXDD(tblrec,objName,"*"_col,MODE))
	.	D ADD(.SOURCE,"    #ENDBYPASS")
	.	D ADD(.SOURCE,"   }")
	.	Q 
	;
	; Handle negative nodes
	F I=1:1:$S((NegNodes=""):0,1:$L(NegNodes,",")) D
	.	;
	.	N nodeRef S nodeRef=$piece(NegNodes,",",I)
	.	;
	.	D ADD(.SOURCE,"   if n = "_nodeRef_" do { quit")
	.	D ADD(.SOURCE,"   // Allow global reference and M source code")
	.	D ADD(.SOURCE,"   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS")
	.	D ADD(.SOURCE,"   #BYPASS")
	.	D ADD(.SOURCE,"    "_$$getSavCode^UCXDD(tblrec,objName,nodeRef,MODE))
	.	D ADD(.SOURCE,"   #ENDBYPASS")
	.	D ADD(.SOURCE,"   }")
	.	Q 
	;
	; Top level or key - only need to deal with this on update when using -100
	I (MODE=1) D ADD(.SOURCE,"   quit:'$D(vobj("_objName_",n))")
	;
	; Handle "non-special" nodes
	D ADD(.SOURCE,"   // Allow global reference and M source code")
	D ADD(.SOURCE,"   #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS")
	D ADD(.SOURCE,"   #BYPASS")
	D ADD(.SOURCE,"   "_$$getSavCode^UCXDD(tblrec,objName,"n",MODE))
	D ADD(.SOURCE,"   #ENDBYPASS")
	D ADD(.SOURCE,"  }")
	;
	D ADD(.SOURCE,"")
	;
	Q 
	;
LOG(column,system,typ,objName)	;
	;
	I (column="") Q ""
	;
	N return S return=" set "_objName_"."_column_" = "
	I typ="D" S return=return_$SELECT(system="PBS":"%SystemDate",1:"%CurrentDate")
	I typ="T" S return=return_"%CurrentTime"
	I typ="U" D
	.	;
	.	S return=return_$SELECT(system="DBS":"%UserName",1:"%UserID")
	.	;
	.	; For DBS, allow change from external interfaces
	.	I (system="DBS") S return=" if '"_objName_".isChanged("""_column_""", ""USER"")"_return
	.	Q 
	;
	Q return
	;
PARTBL(table,tblrec)	;
	;
	I ($P(tblrec,"|",7)="") Q table
	F  S table=$P(tblrec,"|",7) S tblrec=$$getSchTbl^UCXDD(table) Q:($P(tblrec,"|",7)="") 
	Q table
	;
KEYWHR(table,keys,objName,isRDB,asNATIVE,nattable)	;
	;
	 S ER=0
	;
	N i
	N col N di N ret
	;
	I asNATIVE D  ; Remap table
	.	;
	.	S nattable=table
	.	D MAP^DBMAP(%DB,.nattable)
	.	Q 
	;
	I ($get(keys)="") Q ""
	;
	S ret=""
	;
	F i=1:1:$L(keys,",") D  Q:ER 
	.	;
	.	I i>1 S ret=ret_" and "
	.	S di=$$vStrLC($piece(keys,",",i),0)
	.	S col=$$vStrUC(di)
	.	;
	.	I isRDB,asNATIVE D
	..		;
	..		D MAP^DBMAP(%DB,table,.col)
	..		;
	..		I ER WRITE " Aborted - ",table,".",col," not in DBMAP",!
	..		Q 
	.	;
	.	I 'ER D
	..		I '(objName="") S ret=ret_col_" = :"_objName_"."_di
	..		E  S ret=ret_col_" =:vkey"_i
	..		Q 
	.	Q 
	;
	Q ret
	;
TAG(SOURCE,pslcode)	;
	;
	; Inset program line tags
	;
	D ADD(.SOURCE,"")
	D ADD(.SOURCE,pslcode)
	D ADD(.SOURCE,"")
	;
	Q 
	;
ADDDOC(SOURCE,sourceH,record,element)	;
	;
	I ($get(record)="") Q 
	;
	N count S count=$piece(record,$char(9),1)
	N tld S tld=$piece(record,$char(9),2)
	;
	I 'count Q 
	;
	S element="DBTBL"_element
	;
	N rec S rec=$$vDb2("SYSDEV",element)
	;
	N cmt S cmt=$E($P(rec,$C(124),1),1,35)
	S cmt=cmt_" ("_count_") "
	S cmt=$$vStrIns(cmt,$S(tld'="":$ZD(tld,"MM/DD/YEAR"),1:""),45," ",0)
	;
	S sourceH=sourceH+.1
	S SOURCE(sourceH)=$char(9)_"// "_cmt
	;
	Q 
	;
ADD(code,pslcode,comment,line)	;
	;
	; Add procedural code in the output array
	;
	I '$get(line) S line=$order(code(""),-1)+1 ; Next sequence
	;
	I '($get(comment)="") S pslcode=pslcode_$J("",55-$L(pslcode))_" // "_comment
	;
	; Replace leading spaces with tabs if not preformatted
	I pslcode'[$char(9),($E(pslcode,1)=" ") D
	.	N n
	.	;
	.	F n=1:1:$L(pslcode) Q:$E(pslcode,n)'=" " 
	.	S pslcode=$$vStrRep(pslcode," ",$char(9),n-1,0,"")
	.	Q 
	;
	S code(line)=pslcode
	Q 
	;
RDBRCTYP(file)	; Reset record type for RDB
	;
	N rectyp S rectyp=1
	;
	I $$wide^DBSDBASE(file) S rectyp=11
	;
	Q rectyp
	;
ERR(RM,expr)	;
	;
	;       Tag+Line^Routine, SCA_[System_Name], msg: RM
	;
	N msg
	;
	 zshow "S":msg
	;
	S ER=1 S RM=msg("S",2)_", SCA_"_$get(%SN)_", "_$get(RM)
	;
	I ($D(expr)#2) S expr=" // *ERR* "_RM
	USE $P WRITE !,$$MSG^%TRMVT(RM,,1)
	Q 
	;
PGMDIR(pgm)	; Return the directory location of the object file
	;
	N %ZE N %ZI N %ZR
	S %ZI(pgm)="" S %ZE=".obj"
	;
	D INT^%RSEL
	Q $get(%ZR(pgm))_pgm_".obj"
	;
SYSMAPLB(tag,comment)	;
	;
	N RETURN S RETURN=tag
	;
	I $E(tag,1)="v",(comment["Trigger") D
	.	;
	.	S RETURN=$piece($piece(comment,"Trigger",2),"-",1)
	.	S RETURN=tag_" (Trigger - "_$$vStrTrim(RETURN,0," ")_")"
	.	Q 
	;
	Q RETURN
	;
vSIG()	;
	Q "60849^55158^Dan Russell^40050" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM TMPDQ WHERE PID=:V2
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen9()
	F  Q:'($$vFetch9())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^TEMP(v1,v2)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
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
vDbDe2()	; DELETE FROM DBLABELMAP WHERE TARGET=:INDEXPGM
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen10()
	F  Q:'($$vFetch10())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^DBINDX("SYSDEV","LABELMAP",v1,v2)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vStrIns(object,p1,p2,p3,p4)	; String.insert
	;
	;  #OPTIMIZE FUNCTIONS OFF
	S p2=p2-1
	I $L(object)<p2 S object=object_$S(p3=" ":$J("",p2-$L(object)),1:$translate($J("",p2-$L(object))," ",p3))
	Q $E(object,1,p2)_p1_$E(object,$S(p4:0,1:$L(p1))+p2+1,1048575)
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
vStrTrim(object,p1,p2)	; String.trim
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I p1'<0 S object=$$RTCHR^%ZFUNC(object,p2)
	I p1'>0 F  Q:$E(object,1)'=p2  S object=$E(object,2,1048575)
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
	;
vDb2(v1,v2)	;	voXN = Db.getRecord(DBTBL1,,0)
	;
	N rec
	S rec=$G(^DBTBL(v1,1,v2))
	I rec="",'$D(^DBTBL(v1,1,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1" X $ZT
	Q rec
	;
vOpen1()	;	FID FROM DBTBL1 WHERE UDFILE IS NOT NULL
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=""
vL1a2	S vos2=$O(^XDBREF("DBTBL1.UDFILE",vos2),1) I vos2="" G vL1a0
	S vos3=""
vL1a4	S vos3=$O(^XDBREF("DBTBL1.UDFILE",vos2,vos3),1) I vos3="" G vL1a2
	I '(vos3'=$C(254)) G vL1a4
	S vos4=""
vL1a7	S vos4=$O(^XDBREF("DBTBL1.UDFILE",vos2,vos3,vos4),1) I vos4="" G vL1a4
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a7
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen10()	;	TARGET,LABEL FROM DBLABELMAP WHERE TARGET=:INDEXPGM
	;
	;
	S vos1=2
	D vL10a1
	Q ""
	;
vL10a0	S vos1=0 Q
vL10a1	S vos2=$G(INDEXPGM) I vos2="" G vL10a0
	S vos3=""
vL10a3	S vos3=$O(^DBINDX("SYSDEV","LABELMAP",vos2,vos3),1) I vos3="" G vL10a0
	Q
	;
vFetch10()	;
	;
	;
	I vos1=1 D vL10a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen2()	;	ELEMENT FROM TMPDQ WHERE PID=:V1
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(V1) I vos2="" G vL2a0
	S vos3=""
vL2a3	S vos3=$O(^TEMP(vos2,vos3),1) I vos3="" G vL2a0
	Q
	;
vFetch2()	;
	;
	;
	I vos1=1 D vL2a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S tmpdqrs=$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen3()	;	DISTINCT TABLE FROM SYSMAPLITDTA WHERE TABLE=:V1
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(V1) I vos2="" G vL3a0
	S vos3=""
vL3a3	S vos3=$O(^SYSMAP("LITDATA",vos3),1) I vos3="" G vL3a0
	I '($D(^SYSMAP("LITDATA",vos3,vos2))) G vL3a3
	Q
	;
vFetch3()	;
	;
	;
	I vos1=1 D vL3a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=vos2
	S vos1=100
	;
	Q 1
	;
vOpen4()	;	FID FROM DBTBL8 WHERE FID = :V2
	;
	;
	S vos4=2
	D vL4a1
	Q ""
	;
vL4a0	S vos4=0 Q
vL4a1	S vos5=$G(V2) I vos5="" G vL4a0
	S vos6=""
vL4a3	S vos6=$O(^DBTBL(vos6),1) I vos6="" G vL4a0
	S vos7=""
vL4a5	S vos7=$O(^DBTBL(vos6,8,vos5,vos7),1) I vos7="" G vL4a3
	Q
	;
vFetch4()	;
	;
	;
	I vos4=1 D vL4a5
	I vos4=2 S vos4=1
	;
	I vos4=0 Q 0
	;
	S rs=vos5
	;
	Q 1
	;
vOpen5()	;	DISTINCT RTBL FROM DBMAP WHERE DB=:%DB AND TBL=:V2 ORDER BY RTBL ASC
	;
	S vOid=$G(^DBTMP($J))-1,^($J)=vOid K ^DBTMP($J,vOid)
	S vos8=2
	D vL5a1
	Q ""
	;
vL5a0	S vos8=0 Q
vL5a1	S vos9=$G(%DB) I vos9="" G vL5a0
	S vos10=$G(V2) I vos10="" G vL5a0
	S vos11=""
vL5a4	S vos11=$O(^DBMAP("COLUMNS",vos9,vos10,vos11),1) I vos11="" G vL5a10
	S vos12=$G(^DBMAP("COLUMNS",vos9,vos10,vos11))
	S vd=$P(vos12,$C(9),1)
	I (vd="") G vL5a4
	S ^DBTMP($J,vOid,1,vd)=vd
	G vL5a4
vL5a10	S vos9=""
vL5a11	S vos9=$O(^DBTMP($J,vOid,1,vos9),1) I vos9="" G vL5a0
	Q
	;
vFetch5()	;
	;
	;
	I vos8=1 D vL5a11
	I vos8=2 S vos8=1
	;
	I vos8=0 K ^DBTMP($J,vOid) Q 0
	;
	S rs=^DBTMP($J,vOid,1,vos9)
	;
	Q 1
	;
vOpen6()	;	COL FROM DBMAP WHERE DB=:%DB AND TBL=:V3 AND RTBL=:V4
	;
	;
	S vos13=2
	D vL6a1
	Q ""
	;
vL6a0	S vos13=0 Q
vL6a1	S vos14=$G(%DB) I vos14="" G vL6a0
	S vos15=$G(V3) I vos15="" G vL6a0
	S vos16=$G(V4) I vos16="",'$D(V4) G vL6a0
	S vos17=""
vL6a5	S vos17=$O(^DBMAP("COLUMNS",vos14,vos15,vos17),1) I vos17="" G vL6a0
	S vos18=$G(^DBMAP("COLUMNS",vos14,vos15,vos17))
	I '($P(vos18,$C(9),1)=vos16) G vL6a5
	Q
	;
vFetch6()	;
	;
	;
	I vos13=1 D vL6a5
	I vos13=2 S vos13=1
	;
	I vos13=0 Q 0
	;
	S rs2=$S(vos17=$C(254):"",1:vos17)
	;
	Q 1
	;
vOpen7()	;	DI FROM DBTBL1D WHERE FID = :V1 AND TYP ='B' OR TYP = 'M'
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
vL7a5	S vos4=$O(^DBTBL(vos3,1,vos2,9,vos4),1) I vos4="" G vL7a3
	S vos5=$G(^DBTBL(vos3,1,vos2,9,vos4))
	I '($P(vos5,"|",9)="B"!($P(vos5,"|",9)="M")) G vL7a5
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
	S rs=$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen8()	;	NOD,DI FROM DBTBL1D WHERE FID = :V1 AND NOD<'0'
	;
	;
	S vos6=2
	D vL8a1
	Q ""
	;
vL8a0	S vos6=0 Q
vL8a1	S vos7=$G(V1) I vos7="" G vL8a0
	S vos8=""
vL8a3	S vos8=$O(^DBINDX(vos8),1) I vos8="" G vL8a0
	S vos9=""
vL8a5	S vos9=$O(^DBINDX(vos8,"STR",vos7,vos9),1) I vos9=""!("0"']]vos9) G vL8a3
	S vos10=""
vL8a7	S vos10=$O(^DBINDX(vos8,"STR",vos7,vos9,vos10),1) I vos10="" G vL8a5
	S vos11=""
vL8a9	S vos11=$O(^DBINDX(vos8,"STR",vos7,vos9,vos10,vos11),1) I vos11="" G vL8a7
	Q
	;
vFetch8()	;
	;
	;
	I vos6=1 D vL8a9
	I vos6=2 S vos6=1
	;
	I vos6=0 Q 0
	;
	S rs=$S(vos9=$C(254):"",1:vos9)_$C(9)_$S(vos11=$C(254):"",1:vos11)
	;
	Q 1
	;
vOpen9()	;	PID,ELEMENT FROM TMPDQ WHERE PID=:V2
	;
	;
	S vos1=2
	D vL9a1
	Q ""
	;
vL9a0	S vos1=0 Q
vL9a1	S vos2=$G(V2) I vos2="" G vL9a0
	S vos3=""
vL9a3	S vos3=$O(^TEMP(vos2,vos3),1) I vos3="" G vL9a0
	Q
	;
vFetch9()	;
	;
	;
	I vos1=1 D vL9a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vtrap1	;	Error trap
	;
	N ERROR S ERROR=$ZS
	;
	N ER S ER=0
	N %ZTDY S %ZTDY=0 ; Scrolled display of error
	N %ZTHANG S %ZTHANG=0 ; Don't wait for <CR> request
	;
	WRITE ?10," *** Compile error - see following error log entry",!
	;
	D ZE^UTLERR
	;
	WRITE !
	Q 
