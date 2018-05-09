DBSINDXB(fid,pslcode)	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSINDXB ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	N vpc
	;
	;I18N=OFF
	;
	 S ER=0
	;
	N i N idxseq
	N idxlist N OBJNAME N v
	;
	Q:($get(fid)="") 
	;
	N rs,vos1,vos2,vos3,vos4  N V1 S V1=fid S rs=$$vOpen1()
	S vpc=('$G(vos1)) Q:vpc 
	;
	N tblrec S tblrec=$$getSchTbl^UCXDD(fid)
	;
	S OBJNAME=$$vStrLC(fid,0) ; Primary table object name
	;
	S idxseq=0
	;
	; Beginning of the section
	D TAG("public VINDEX(Record"_fid_" "_OBJNAME_") // Update index entries")
	;
	D ADD(" ",,100) ; Reserve area for header
	;
	D INDEX(fid,OBJNAME,.idxseq,.idxlist,.tblrec) ; Build index logic
	Q:ER 
	D EXEC(fid,OBJNAME,idxseq,.idxlist) ; Rebuild index logic
	D IDXOPT(OBJNAME,idxseq,.idxlist) ; Index optimization
	;
	F i=1:1:idxseq D ADDH(" do vi"_i_"(."_OBJNAME_")")
	;
	D ADDH("")
	D ADDH(" quit")
	;
	Q 
	;
INDEX(fid,OBJNAME,idxseq,idxlist,tblrec)	;
	;
	N fidkeys
	;
	S fidkeys=","_$P(tblrec,"|",3)_","
	;
	N ds,vos1,vos2,vos3  N V1 S V1=fid S ds=$$vOpen2()
	;
	; Build code for next index
	F  Q:'($$vFetch2())  D  Q:ER 
	.	S idxseq=idxseq+1 ; Index sequence number
	.	;
	.	N hasNonky
	.	N i N saveline
	.	N code N gbl N global N nulllist N objgbl N ord N orderby
	.	;
	.	N dbtbl8,vop1 S vop1=$P(ds,$C(9),3),dbtbl8=$G(^DBTBL($P(ds,$C(9),1),8,$P(ds,$C(9),2),vop1))
	.	;
	.	S gbl=$P(dbtbl8,$C(124),2)
	.	S orderby=$P(dbtbl8,$C(124),3)
	.	;
	.	S hasNonky=0
	.	S nulllist=""
	.	;
	.	I orderby["=" D  Q 
	..		S ER=1
	..		WRITE " Aborted - Index "_vop1_" has assignment to a value - not valid",!
	..		Q 
	.	;
	.	; Map index to vi tag
	.	D TAG("vi"_idxseq_"(Record"_fid_" "_OBJNAME_") // Maintain "_vop1_" index entries ("_$P(dbtbl8,$C(124),5)_")")
	.	;
	.	D ADD(" type Public String vx()")
	.	;
	.	D ADD(" type Boolean vdelete = 0")
	.	;
	.	F i=1:1:$L(orderby,",") D  Q:ER 
	..		;
	..		N key N var
	..		;
	..		S key=$piece(orderby,",",i)
	..		;
	..		I key?1"<<".E D  Q 
	...			S ER=1
	...			WRITE " Aborted - Index "_vop1_" contains variable insertion (<< >>) - not valid",!
	...			Q 
	..		;
	..		; Dummy key (literal) - no need to do assignment
	..		I $$isLit^UCGM(key) S ord(i)="1|"_key
	..		;
	..		E  D  Q:ER 
	...			;
	...			N isKey
	...			N datatyp N obj
	...			;
	...			N dbtbl1d S dbtbl1d=$$vDb4("SYSDEV",fid,key)
	...			S datatyp=$P(dbtbl1d,$C(124),9)
	...			;
	...			S obj=OBJNAME_"."_$$vStrLC(key,0)
	...			;
	...			; Key to primary table
	...			I (","_fidkeys_",")[(","_key_",") S ord(i)="2" S isKey=1
	...			E  S ord(i)="3" S isKey=0 S hasNonky=1
	...			;
	...			S ord(i)=ord(i)_"|"_key_"|"_obj_"|"_datatyp
	...			;
	...			D ASSIGN("v"_i,isKey,obj,datatyp,$P(dbtbl8,$C(124),14),$P(dbtbl1d,$C(124),31))
	...			Q 
	..		;
	..		; Remap order by for use in global reference
	..		I $piece(ord(i),"|",1)=1 S var=$piece(ord(i),"|",2)
	..		E  S var="v"_i
	..		S $piece(orderby,",",i)=var
	..		Q 
	.	;
	.	Q:ER 
	.	;
	.	; Define global name
	.	I gbl="" S global="^XDBREF("""_fid_"."_vop1_""","_orderby_")"
	.	E  S global="^"_gbl_"("_orderby_")"
	.	;
	.	S nulllist=$E(nulllist,1,$L(nulllist)-1) ; Remove trailing comma
	.	;
	.	; Add proceesing code
	.	;
	.	D ADD("")
	.	D ADD(" if %ProcessMode=2 do { quit") ; Integrity check code
	.	;
	.	; Get primary table global reference using object references to nodes
	.	S objgbl=$$getGbl^UCXDD(tblrec,OBJNAME)
	.	I ($E(objgbl,$L(objgbl))=",") S objgbl=$E(objgbl,1,$L(objgbl)-1)
	.	;
	.	I '(nulllist="") S code="  if "_nulllist_" "
	.	E  S code="  "
	.	;
	.	; If record type is 1 then assure that tables with
	.	; more nodes using this global do not cause integrity errors.
	.	D ADD("")
	.	D ADD("  // Allow global reference")
	.	D ADD("  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS")
	.	D ADD("  #BYPASS")
	.	I $P(tblrec,"|",4)'=1 S code=code_"if '$D("_global_") "
	.	E  S code=code_"if $D("_objgbl_"))#2,'$D("_global_") "
	.	;
	.	; Code for date checking on dayend
	.	I $P(tblrec,"|",2)["DAYEND" D
	..		N utblkill,vop2 S utblkill=$$vDb5("DAYEND",.vop2)
	..		;
	..		I $G(vop2) D
	...			N key1
	...			;
	...			S key1=$piece($piece(global,"(",2),",",1)
	...			;
	...			S code=code_"if (TJD-"_key1_")<"_$P(utblkill,$C(124),2)_" "
	...			Q 
	..		Q 
	.	;
	.	S code=code_"do vidxerr("_""""_vop1_""""_")"
	.	;
	.	D ADD(code)
	.	D ADD("  #ENDBYPASS")
	.	D ADD("  }")
	.	D ADD("")
	.	;
	.	D ADD(" // Allow global reference")
	.	D ADD(" #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS")
	.	D ADD(" #BYPASS")
	.	;
	.	I '(nulllist="") S code=" if "_nulllist_" "
	.	E  S code=" "
	.	;
	.	S code=code_"if %O<2 "_"set "_global_"="""" "
	.	;
	.	I 'hasNonky S code=code_"quit" ; No non-key columns
	.	;
	.	D ADD(code)
	.	;
	.	D ADD(" #ENDBYPASS")
	.	D ADD(" quit:%ProcessMode=0")
	.	D ADD("")
	.	D ADD(" if %ProcessMode=3 set vdelete=1")
	.	;
	.	; ========== Access vx() array for old data
	.	S i=""
	.	F  S i=$order(ord(i)) Q:i=""  I $piece(ord(i),"|",1)=3 D
	..		N var N vx
	..		;
	..		S var="v"_i
	..		S vx="vx("""_$piece(ord(i),"|",2)_""")"
	..		S code=" if "_vx_".exists() "
	..		S code=code_"set "_var_"="_vx_".piece(""|"",1)"
	..		I $P(dbtbl8,$C(124),14) S code=code_".upperCase() "
	..		;
	..		S code=code_" set:"_var_".isNull() "_var_"=(PSL.maxCharValue-1).char()"
	..		I $P(dbtbl8,$C(124),14) S code=code_" set:"_var_"'="_vx_".piece(""|"",2).upperCase() vdelete=1"
	..		;
	..		D ADD(code)
	..		Q 
	.	;
	.	I $P(dbtbl8,$C(124),14) D ADD(" quit:'vdelete","Only case has changed")
	.	;
	.	D ADD("")
	.	D ADD(" // Allow global reference")
	.	D ADD(" #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS")
	.	D ADD(" #BYPASS")
	.	D ADD(" kill "_global)
	.	;
	.	D ADD(" #ENDBYPASS")
	.	D ADD(" quit")
	.	;
	.	; Create idxlist of non-key columns for optimization in IDXOPT
	.	S (i,idxlist(idxseq))=""
	.	F  S i=$order(ord(i)) Q:i=""  I $piece(ord(i),"|",1)=3 D
	..		S idxlist(idxseq)=idxlist(idxseq)_$piece(ord(i),"|",2)_","
	..		Q 
	.	S idxlist(idxseq)=vop1_"|"_$E(idxlist(idxseq),1,$L(idxlist(idxseq))-1)
	.	Q 
	;
	Q 
	;
ASSIGN(var,isKey,obj,datatyp,upcase,nullind)	;
	;
	N code
	;
	S code=" type String "_var_" = "
	I datatyp="L" S code=code_"+" ; Eliminate null logicals
	I "$N"[datatyp,nullind S code=code_"+"
	S code=code_obj
	I upcase,"FT"[datatyp S code=code_".upperCase()"
	;
	D ADD(code)
	;
	; Assign default value for non-key columns that are null
	I 'isKey D ADD(" if "_var_".isNull() set "_var_"=(PSL.maxCharValue-1).char()")
	;
	Q 
	;
EXEC(file,OBJNAME,idxseq,idxlist)	;
	;
	N i
	;
	D TAG("public VIDXBLD(List vlist) // Rebuild index files (External call)")
	;
	D ADD("")
	;
	D ADD(" type Number %ProcessMode=0","Create mode")
	D ADD(" type Number i")
	D ADD("")
	;
	D ADD(" if vlist.get().isNull() set vlist=""VINDEX""","Build all")
	D ADD("")
	;
	D ADD(" type DbSet ds=Db.selectDbSet("""_file_""")")
	D ADD("")
	D ADD(" while ds.next() do {")
	D ADD("  type Record"_file_" "_OBJNAME_"=ds.getRecord("""_file_""")")
	D ADD("  if vlist.contains(""VINDEX"") do VINDEX(."_OBJNAME_") quit")
	;
	; Avoid indirection, handle each index individually
	F i=1:1:idxseq D ADD("  if vlist.contains("""_$piece(idxlist(i),"|",1)_""") do vi"_i_"(."_OBJNAME_")")
	D ADD(" }")
	;
	D ADD("")
	D ADD(" quit")
	D ADD("")
	;
	D TAG("public VIDXBLD1(Record"_file_" "_OBJNAME_", List vlist) // Rebuild index files for one record (External call)")
	;
	D ADD("")
	;
	D ADD(" type Number i")
	D ADD("")
	;
	D ADD(" if vlist.contains(""VINDEX"") do VINDEX(."_OBJNAME_") quit")
	;
	; Avoid indirection, handle each index individually
	F i=1:1:idxseq D ADD(" if vlist.contains("""_$piece(idxlist(i),"|",1)_""") do vi"_i_"(."_OBJNAME_")")
	;
	D ADD("")
	D ADD(" quit")
	D ADD("")
	;
	; Add index error message
	D TAG("vidxerr(di) // Error message")
	D ADD(" D SETERR^DBSEXECU("_""""_file_""""_","_""""_"MSG"_""""_",1225,"_""""_file_"."_""""_"_"_"di)")
	D ADD("")
	D ADD(" quit")
	;
	Q 
	;
IDXOPT(OBJNAME,idxseq,idxlist)	;
	;
	; This sub-routine optimizes updates to table indeces (%O=1).
	;
	N i
	N code N x
	;
	D ADDH("  type Public String vx()")
	D ADDH("")
	;
	D ADDH(" if %ProcessMode=1 do { quit")
	;
	I idxseq<10 D  Q 
	.	N j
	.	;
	.	F i=1:1:idxseq D
	..		S x=$piece(idxlist(i),"|",2)
	..		Q:(x="") 
	..		;
	..		S code=""
	..		;
	..		F j=1:1:$L(x,",") S code=code_"vx("""_$piece(x,",",j)_""").exists()!"
	..		S code="  if "_$E(code,1,$L(code)-1)_" do vi"_i_"(."_OBJNAME_")"
	..		D ADDH(code)
	..		Q 
	.	D ADDH(" }")
	.	Q 
	;
	D ADDH("  type String vf,vi,viMap,vxn")
	;
	S x=""
	F i=1:1:idxseq S x=x_","_$piece(idxlist(i),"|",2)_",~"_i_"~|"
	F i=1:400:$L(x) D ADDH("  set viMap="_$S(i=1:"""",1:"viMap_""")_$E(x,i,i+399)_"""")
	;
	D ADDH("  set vf=0")
	D ADDH("  set vxn=""""")
	D ADDH("  for  set vxn=vx(vxn).order() quit:vxn=""""  do {")
	D ADDH("   for  set vf=$F(viMap,("",""_vxn_"",""),vf) quit:vf=0  do {")
	D ADDH("    set vi=viMap.extract(vf,999).piece(""~"",2)")
	;
	D ADDH("    set viMap.piece(""|"",vi)=""""")
	;
	; Dispatch to applicable sub-routine (v1-vn).
	D ADDH("    do @(""vi""_vi_""(."_OBJNAME_")"")")
	;
	D ADDH("   }")
	D ADDH("  }")
	D ADDH(" }")
	;
	Q 
	;
ADD(code,comment,line)	;
	;
	I '$get(line) S line=$order(pslcode(""),-1)+1 ; Next seqence
	;
	I '($get(comment)="") S code=code_$J("",55-$L(code))_" // "_comment
	;
	; Replace leading spaces with tabs if not preformatted
	I code'[$char(9),($E(code,1)=" ") D
	.	N n
	.	;
	.	F n=1:1:$L(code) Q:$E(code,n)'=" " 
	.	S code=$$vStrRep(code," ",$char(9),n-1,0,"")
	.	Q 
	;
	S pslcode(line)=code
	;
	Q 
	;
ADDH(code,comment)	;
	;
	N line
	;
	S line=$order(pslcode(100),-1)+1
	;
	D ADD(code,$get(comment),line)
	;
	Q 
	;
TAG(tag)	; Routine tag
	;
	D ADD("")
	D ADD(tag)
	D ADD("")
	;
	Q 
	;
vSIG()	;
	Q "60849^55184^Dan Russell^12827" ; Signature - LTD^TIME^USER^SIZE
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
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ","ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ")
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
vDb4(v1,v2,v3)	;	voXN = Db.getRecord(DBTBL1D,,0)
	;
	N dbtbl1d
	S dbtbl1d=$G(^DBTBL(v1,1,v2,9,v3))
	I dbtbl1d="",'$D(^DBTBL(v1,1,v2,9,v3))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1D" X $ZT
	Q dbtbl1d
	;
vDb5(v1,v2out)	;	voXN = Db.getRecord(UTBLKILL,,1,-2)
	;
	N utblkill
	S utblkill=$G(^UTBL("KILL",v1))
	I utblkill="",'$D(^UTBL("KILL",v1))
	S v2out='$T
	;
	Q utblkill
	;
vOpen1()	;	FID FROM DBTBL8 WHERE FID = :V1
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
vL1a5	S vos4=$O(^DBTBL(vos3,8,vos2,vos4),1) I vos4="" G vL1a3
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=vos2
	;
	Q 1
	;
vOpen2()	;	%LIBS,FID,INDEXNM FROM DBTBL8 WHERE %LIBS='SYSDEV' AND FID=:V1
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(V1) I vos2="" G vL2a0
	S vos3=""
vL2a3	S vos3=$O(^DBTBL("SYSDEV",8,vos2,vos3),1) I vos3="" G vL2a0
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
	S ds="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
