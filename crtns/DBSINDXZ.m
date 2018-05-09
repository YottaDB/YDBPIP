DBSINDXZ	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSINDXZ ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	Q  ; No entry from top
	;
ADD(file,list,REBUILD)	;
	N vpc
	;
	N filer
	;
	Q:$$rdb^UCDBRT(file)  ; Don't do it if in RDB
	;
	N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=file,dbtbl1=$$vDb5("SYSDEV",file)
	 S vop3=$G(^DBTBL(vop1,1,vop2,99))
	;
	S filer=$P(vop3,$C(124),2)
	;
	S vpc=((filer="")) Q:vpc  ; Filer required if indexes
	;
	I ($get(REBUILD)="") S REBUILD=1
	;
	I '($D(list)#2) S list=""
	;
	I ((list="")) S list=$$allidxs(file) ; All indexes
	;
	D DROP(file,list,REBUILD) ; Delete existing index files
	;
	;  #ACCEPT Date=12/16/05; Pgm=RussellDS; CR=18400
	XECUTE (" D VIDXBLD^"_filer_"("_""""_list_""""_")") ; Build index files
	;
	Q 
	;
DROP(fid,list,REBUILD)	;
	N vpc
	;
	N I
	;
	I (list="") S list=$$allidxs(fid)
	;
	F I=1:1:$S((list=""):0,1:$L(list,",")) D
	.	;
	.	N indexnm N v
	.	;
	.	S indexnm=$piece(list,",",I)
	.	;
	.	N dbtbl8 S dbtbl8=$$vDb6("SYSDEV",fid,indexnm)
	.	;
	.	S vpc=('($P(dbtbl8,$C(124),15)="")) Q:vpc  ; Supertype linkage
	.	;
	.	; Delete the entire index prior to rebuild
	.	I (REBUILD=1) S v=$$massdel(fid,indexnm)
	.	;
	.	; Delete record-by-record if no longer valid index entry
	.	I (REBUILD=2) S v=$$recdel(fid,indexnm)
	.	;
	.	;   #ACCEPT Date=12/16/05; Pgm=RussellDS; CR=18400
	.	I '(v="") XECUTE v ; Delete the index file
	.	Q 
	;
	Q 
	;
allidxs(fid)	; Table name
	;
	N return S return=""
	;
	N rs,vos1,vos2,vos3  N V1 S V1=fid S rs=$$vOpen1()
	;
	F  Q:'($$vFetch1())  D
	.	;
	.	N indexnm S indexnm=rs
	.	;
	.	S return=$S((return=""):indexnm,1:return_","_indexnm)
	.	Q 
	;
	Q return
	;
massdel(fid,indexnm)	;
	;
	N firstvar N I N lastlit
	N global N keys N return
	;
	N dbtbl8 S dbtbl8=$$vDb6("SYSDEV",fid,indexnm)
	;
	S global="^"_$P(dbtbl8,$C(124),2)
	S keys=$P(dbtbl8,$C(124),3)
	;
	; Find first variable and last literal
	S (firstvar,lastlit)=0
	F I=1:1:$L(keys,",") D
	.	;
	.	N key S key=$piece(keys,",",I)
	.	;
	.	I $$isLit^UCGM(key) S lastlit=I
	.	E  I (firstvar=0) S firstvar=I
	.	Q 
	;
	; If no literals, kill entire global
	I (lastlit=0) S return=" kill "_global
	; If leading literals, kill up to literals
	E  I (firstvar>lastlit) S return=" kill "_global_"("_$piece(keys,",",1,firstvar-1)_")"
	; otherwise, kill up to last literal
	E  D
	.	;
	.	N noLits S noLits=0
	.	;
	.	I (lastlit=0) D
	..		;
	..		S noLits=1
	..		S lastlit=$L(keys,",")
	..		Q 
	.	;
	.	S global=global_"("
	.	S return=" new i,vx"
	.	;
	.	F I=1:1:lastlit D
	..		;
	..		N key S key=$piece(keys,",",I)
	..		;
	..		I $$isLit^UCGM(key) S global=global_key_","
	..		E  D
	...			;
	...			S return=return_" set i("_I_")="""" for  set i("_I_")=$order("_global_"i("_I_"))) quit:i("_I_")=""""  "
	...			S global=global_"i("_I_"),"
	...			Q 
	..		Q 
	.	;
	.	S global=$E(global,1,$L(global)-1)_")"
	.	;
	.	S return=return_"set vx=$G("_global_") "
	.	S return=return_"kill "_global
	.	S return=return_" set:vx'="""" "_global_"=vx"
	.	Q 
	;
	Q return
	;
recdel(fid,indexnm)	;
	;
	N fidkeys
	N I
	N fsn N global N keys N newkeys N notkeys N qry N return
	;
	D fsn^DBSDD(.fsn,fid)
	;
	N dbtbl8 S dbtbl8=$$vDb6("SYSDEV",fid,indexnm)
	;
	S global="^"_$P(dbtbl8,$C(124),2)_"("
	S keys=$P(dbtbl8,$C(124),3)
	;
	S fidkeys=$piece(fsn(fid),"|",3)
	;
	F I=1:1:$L(keys,",") D
	.	;
	.	N key S key=$piece(keys,",",I)
	.	;
	.	I '$$isLit^UCGM(key),'((","_fidkeys_",")[(","_key_",")) S notkeys(I)=key_","_$$DI^SQLDD(key,fid)
	.	Q 
	;
	S (newkeys,return)=""
	;
	F I=1:1:$L(keys,",") D
	.	;
	.	N key S key=$piece(keys,",",I)
	.	;
	.	I (I=1) S global=global_key
	.	E  S global=global_","_key
	.	;
	.	I '$$isLit^UCGM(key) D
	..		;
	..		S newkeys=newkeys_key_","
	..		S return=return_" set "_key_"="""" for  set "_key_"=$O("_global_")) Q:"_key_"="""" "
	..		Q 
	.	Q 
	;
	S return="new "_$E(newkeys,1,$L(newkeys)-1)_return
	;
	S (I,qry)=""
	F  S I=$order(notkeys(I)) Q:(I="")  D
	.	;
	.	N notkey S notkey=$piece(notkeys(I),",",1)
	.	;
	.	N dbtbl1d S dbtbl1d=$$vDb7("SYSDEV",fid,notkey)
	.	;
	.	I ($piece(fsn(fid),"|",4)=1) D
	..		;
	..		S qry=qry_" kill:$piece($get("_$piece(fsn(fid),"|",2)_")),"
	..		S qry=qry_"""|"","_$P(dbtbl1d,$C(124),21)_")'="_notkey_" "_global_") "
	..		Q 
	.	;
	.	E  I ($piece(fsn(fid),"|",4)=10) D
	..		;
	..		S qry=qry_" kill:$piece($get("_$piece(fsn(fid),"|",2)_","
	..		S qry=qry_$P(dbtbl1d,$C(124),1)_")),""|"","_$P(dbtbl1d,$C(124),21)_")'="_notkey_" "_global_") "
	..		Q 
	.	Q 
	;
	S return=return_qry
	;
	Q return
	;
ALL(sys)	; System name   /NOREQ/DFT="PBS"
	;
	N I
	N fid N index
	;
	I ($get(sys)="") S sys="PBS"
	;
	D SYSVAR^SCADRV0(sys) ; Init system variables
	;
	S %O=0
	;
	I (sys="PBS") D
	.	;
	.	D RUNLOG("ACN") ; Process ACN, DEP, LN first
	.	;
	.	F I="ACN","DEP","LN" S index(I)="*" ; index files first
	.	D onerun(.index,1)
	.	Q 
	;
	N rs,vos1,vos2 S rs=$$vOpen2()
	;
	F  Q:'($$vFetch2())  D
	.	;
	.	S fid=rs
	.	;
	.	N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=fid,dbtbl1=$$vDb5("SYSDEV",fid)
	.	 S vop3=$G(^DBTBL(vop1,1,vop2,10))
	.	;
	.	I ($P(vop3,$C(124),2)=sys) D
	..		;
	..		D RUNLOG(fid)
	..		;
	..		D ADD(fid,"",1)
	..		Q 
	.	Q 
	;
	Q 
	;
BUILD(opt)	; Display DQ index files /NOREQ
	;
	N REBUILD
	N %READ N %TAB N ARRAY N fid N index N line N VFMQ
	;
	D select(.index,$get(opt)) ; Select files
	Q:'$D(index) 
	;
	S $piece(line,"-",80)=""
	;
	WRITE !,line
	;
	S fid=""
	F  S fid=$order(index(fid)) Q:(fid="")  D
	.	;
	.	WRITE !,fid,?20,index(fid)
	.	Q 
	;
	; Fast rebuild
	S ARRAY(1)=$$^MSG(4566)
	; Records processed individually (24x7 mode)
	S ARRAY(2)=$$^MSG(4567)
	;
	S %TAB("REBUILD")=".REBUILDOPT/REQ/TBL=ARRAY("
	S %READ="REBUILD"
	;
	D ^UTLREAD Q:(VFMQ="Q") 
	;
	; Combine ACN,DEP,LN files into one proceesing logic
	;
	S %O=0
	;
	I (($get(index("DEP"))="*")!($get(index("LN"))="*")) S index("ACN")="*"
	;
	I (($D(index("DEP"))#2)!($D(index("LN"))#2)!($D(index("ACN"))#2)) D onerun(.index,REBUILD)
	;
	; Dispatch other files to standard ADD (index build) function
	S fid=""
	F  S fid=$order(index(fid)) Q:(fid="")  D
	.	;
	.	N list
	.	;
	.	S list=index(fid) ; Index file list
	.	I (list="*") S list="" ; All Index files
	.	;
	.	D ADD(fid,list,REBUILD) ; delete and rebuild
	.	Q 
	;
	Q 
	;
select(index,opt)	;
	N vpc
	;
	N INDEX
	N %PAGE N %PG N BLOCK N BREAK N I N LENGTH N PAGE
	N %READ N %TAB N FID N INDEXFL N VFMQ N zread N ztab
	;
	S %READ=""
	S zread="@@%FN/REV/CEN"
	;
	; Display major files first
	;
	F FID="ACN","CIF","DEP","LN","COL","ACNADDR","RELCIF","CIFHH","TRN" D
	.	;
	.	N rs,vos1,vos2,vos3 S rs=$$vOpen3()
	.	;
	.	I ''$G(vos1) D buildtab(FID,.INDEX,.INDEXFL,.%READ,.%TAB)
	.	Q 
	;
	N rs2,vos4,vos5 S rs2=$$vOpen4()
	;
	F  Q:'($$vFetch4())  D
	.	;
	.	S FID=rs2
	.	;
	.	Q:(",ACN,DEP,LN,CIF,COL,ACNADDR,RELCIF,CIFHH,TRN,"[(","_FID_",")) 
	.	;
	.	N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=FID,dbtbl1=$$vDb5("SYSDEV",FID)
	.	 S vop3=$G(^DBTBL(vop1,1,vop2,10))
	.	;
	.	I 'opt,$P(vop3,$C(124),2)="DBS" Q 
	.	;
	.	S vpc=(($P(vop3,$C(124),12)=7)) Q:vpc 
	.	;
	.	N rs3,vos6,vos7,vos8,vos9 S rs3=$$vOpen5()
	.	;
	.	I ''$G(vos6) D buildtab(FID,.INDEX,.INDEXFL,.%READ,.%TAB)
	.	Q 
	;
	S %READ=$E(%READ,1,$L(%READ)-1) ; Remove trailing comma
	;
	S vpc=((%READ="")) Q:vpc  ; No selections
	;
	S BLOCK=40
	S BREAK=0
	S %PAGE=0
	S LENGTH=$L(%READ,",")
	;
	; Break up into pages
	F  D  Q:(LENGTH'>0) 
	.	;
	.	S %PAGE=%PAGE+1
	.	S zread(%PAGE)=zread_","_$piece(%READ,",",BREAK+1,BREAK+BLOCK)
	.	S BREAK=BREAK+BLOCK
	.	S LENGTH=LENGTH-BLOCK
	.	Q 
	;
	S (%PG,PAGE)=1
	S VFMQ=""
	;
	F  Q:'('((VFMQ="Q")!(VFMQ="F")))  D
	.	;
	.	N %FRAME N OLNTB
	.	N %CTPRMT N N
	.	;
	.	S %READ=zread(%PG)
	.	;
	.	; Save and restore %TAB (destroyed by ^UTLREAD)
	.	S N=""
	.	F  S N=$order(%TAB(N)) Q:(N="")  S ztab(N)=%TAB(N)
	.	;
	.	S %O=1
	.	S OLNTB=34
	.	S %CTPRMT="2|38"
	.	S %FRAME=2
	.	D ^UTLREAD
	.	;
	.	S N=""
	.	F  S N=$order(ztab(N)) Q:(N="")  S %TAB(N)=ztab(N)
	.	;
	.	S %PG=VFMQ+1
	.	Q 
	;
	S vpc=((VFMQ="Q")) Q:vpc 
	;
	F I=1:1 Q:'($D(INDEX(I))#2)  I INDEX(I) D
	.	;
	.	S FID=INDEXFL(I) ; Files selected
	.	I (INDEX(I)=2) S index(FID)="*" ; Select all
	.	E  D
	..		;
	..		N list
	..		;
	..		S list=$$partial(FID) ; Partial
	..		I '(list="") S index(FID)=list
	..		Q 
	.	Q 
	;
	Q 
	;
onerun(index,REBUILD)	;
	;
	N code N fid
	;
	Q:$$rdb^UCDBRT("ACN")  ; Don't do it if in RDB
	;
	F fid="ACN","DEP","LN" I ($D(index(fid))#2) D
	.	;
	.	N filer N fsn N list
	.	;
	.	D fsn^DBSDD(.fsn,fid)
	.	;
	.	S filer=$piece(fsn(fid),"|",6)
	.	;
	.	; Possibly remapped index section
	.	S code="set filer=$$VIDXPGM^"_filer
	.	;
	.	;   #ACCEPT Date=12/16/05; Pgm=RussellDS; CR=18400
	.	XECUTE code
	.	;
	.	S list=index(fid) ; Index names
	.	I (list="*") S list="" ; All index files
	.	D DROP(fid,list,REBUILD) ; Delete it first
	.	;
	.	I (fid'="ACN"),(list="") D
	..		;
	..		N rs,vos1,vos2,vos3,vos4  N V1 S V1=fid S rs=$$vOpen6()
	..		;
	..		F  Q:'($$vFetch6())  S list=list_rs_","
	..		;
	..		S list=$E(list,1,$L(list)-1)
	..		Q 
	.	;
	.	I (list="") S list="VINDEX"
	.	;
	.	S code(fid)="VIDXBLD1^"_filer_"(.acn,"""_list_""")"
	.	;
	.	K index(fid)
	.	Q 
	;
	; NOTE that this used knowledge of the PSL object structure
	S code="new acn,CID,vcls,vobj set CID="""" for  set CID=$order(^ACN(CID)) quit:CID=""""  kill acn,vobj"
	I (($D(code("DEP"))#2)!($D(code("LN"))#2)) S code=code_" set vcls=$piece($get(^ACN(CID,50)),""|"",2) "
	S code=code_" set acn=1,vobj(1,-3)=CID,vobj(1,-2)=1"
	S code=code_",vobj(1,50)=$get(^ACN(CID,50))" ; Load defined node
	I ($D(code("ACN"))#2) S code=code_" do "_code("ACN")
	I ($D(code("DEP"))#2) S code=code_" do:vcls=""D"" "_code("DEP")
	I ($D(code("LN"))#2) S code=code_" do:vcls=""L"" "_code("LN")
	;
	;  #ACCEPT Date=12/16/05; Pgm=RussellDS; CR=18400
	XECUTE code
	;
	Q 
	;
partial(FID)	; Table name
	;
	N return
	N zindex
	N %FRAME N OLNTB N SEQ
	N %CTPRMT N %READ N %TAB N IDXNAM N msg N VFMQ
	;
	S %READ="@msg/REV/CEN"
	;
	N dbtbl1 S dbtbl1=$$vDb5("SYSDEV",FID)
	;
	; Select Index Option
	S msg=$P(dbtbl1,$C(124),1)_" - "_$$^MSG(7999)
	;
	S SEQ=0
	;
	N ds,vos1,vos2,vos3,vos4 S ds=$$vOpen7()
	;
	F  Q:'($$vFetch7())  D
	.	;
	.	N desc N indexnm
	.	;
	.	N dbtbl8,vop1 S vop1=$P(ds,$C(9),3),dbtbl8=$G(^DBTBL($P(ds,$C(9),1),8,$P(ds,$C(9),2),vop1))
	.	;
	.	S indexnm=vop1
	.	S desc=$P(dbtbl8,$C(124),5)
	.	;
	.	I (desc["/") S desc=$S(desc'["""":""""_desc_"""",1:$$QADD^%ZS(desc,""""))
	.	;
	.	S SEQ=SEQ+1
	.	S zindex(SEQ)=0
	.	S %TAB("zindex("_SEQ_")")="/DES="_desc_"/TYP=L/LEN=1"
	.	S %READ=%READ_",zindex("_SEQ_")/NOREQ"
	.	S IDXNAM(SEQ)=indexnm
	.	Q 
	;
	S %O=1
	S OLNTB=34
	S %CTPRMT="2|38"
	S %FRAME=2
	;
	D ^UTLREAD
	;
	S return=""
	;
	I (VFMQ'="Q") D
	.	;
	.	F SEQ=1:1 Q:'($D(zindex(SEQ))#2)  D
	..		;
	..		I zindex(SEQ) S return=$S((return=""):IDXNAM(SEQ),1:return_","_IDXNAM(SEQ))
	..		Q 
	.	Q 
	;
	Q return
	;
buildtab(FID,INDEX,INDEXFL,%READ,%TAB)	;
	;
	N SEQ
	N desc
	;
	N dbtbl1 S dbtbl1=$$vDb5("SYSDEV",FID)
	;
	S desc=$E($P(dbtbl1,$C(124),1),1,31)
	I (desc["/") S desc=$S(desc'["""":""""_desc_"""",1:$$QADD^%ZS(desc,""""))
	;
	S SEQ=$order(INDEX(""),-1)+1 ; Next entry
	S %TAB("INDEX("_SEQ_")")="/DES="_desc_"/TYP=N/LEN=1/TBL=[STBLIDXRB]"
	;
	S INDEX(SEQ)=0
	S INDEXFL(SEQ)=FID
	;
	S %READ=%READ_"INDEX("_SEQ_")/NOREQ,"
	;
	Q 
	;
RUNLOG(fid)	; Table name
	;
	I '$$rdb^UCDBRT(fid) D
	.	;
	.	USE $P
	.	WRITE !,fid,?20,$$TIM^%ZM($P($H,",",2))
	.	Q 
	;
	Q 
	;
EXT(files)	; Files list
	;
	N I
	;
	F I=1:1:$S((files=""):0,1:$L(files,",")) D
	.	;
	.	N fid S fid=$piece(files,",",I)
	.	;
	.	D RUNLOG(fid)
	.	D ADD(fid,"",1)
	.	Q 
	;
	Q 
	;
vSIG()	;
	Q "60849^55185^Dan Russell^14817" ; Signature - LTD^TIME^USER^SIZE
	;
vDb5(v1,v2)	;	voXN = Db.getRecord(DBTBL1,,0)
	;
	N dbtbl1
	S dbtbl1=$G(^DBTBL(v1,1,v2))
	I dbtbl1="",'$D(^DBTBL(v1,1,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1" X $ZT
	Q dbtbl1
	;
vDb6(v1,v2,v3)	;	voXN = Db.getRecord(DBTBL8,,0)
	;
	N dbtbl8
	S dbtbl8=$G(^DBTBL(v1,8,v2,v3))
	I dbtbl8="",'$D(^DBTBL(v1,8,v2,v3))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL8" X $ZT
	Q dbtbl8
	;
vDb7(v1,v2,v3)	;	voXN = Db.getRecord(DBTBL1D,,0)
	;
	N dbtbl1d
	S dbtbl1d=$G(^DBTBL(v1,1,v2,9,v3))
	I dbtbl1d="",'$D(^DBTBL(v1,1,v2,9,v3))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1D" X $ZT
	Q dbtbl1d
	;
vOpen1()	;	INDEXNM FROM DBTBL8 WHERE %LIBS='SYSDEV' AND FID=:V1
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(V1) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^DBTBL("SYSDEV",8,vos2,vos3),1) I vos3="" G vL1a0
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
	S rs=$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen2()	;	DISTINCT FID FROM DBTBL8 WHERE %LIBS='SYSDEV' AND NOT (FID='ACN' OR FID='DEP' OR FID='LN')
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=""
vL2a2	S vos2=$O(^DBTBL("SYSDEV",8,vos2),1) I vos2="" G vL2a0
	I '(vos2'="ACN"&(vos2'="DEP")&(vos2'="LN")) G vL2a2
	Q
	;
vFetch2()	;
	;
	;
	I vos1=1 D vL2a2
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos2=$C(254):"",1:vos2)
	;
	Q 1
	;
vOpen3()	;	INDEXNM FROM DBTBL8 WHERE %LIBS='SYSDEV' AND FID=:FID
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(FID) I vos2="" G vL3a0
	S vos3=""
vL3a3	S vos3=$O(^DBTBL("SYSDEV",8,vos2,vos3),1) I vos3="" G vL3a0
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
	S rs=$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen4()	;	DISTINCT FID FROM DBTBL8 WHERE %LIBS='SYSDEV'
	;
	;
	S vos4=2
	D vL4a1
	Q ""
	;
vL4a0	S vos4=0 Q
vL4a1	S vos5=""
vL4a2	S vos5=$O(^DBTBL("SYSDEV",8,vos5),1) I vos5="" G vL4a0
	Q
	;
vFetch4()	;
	;
	;
	I vos4=1 D vL4a2
	I vos4=2 S vos4=1
	;
	I vos4=0 Q 0
	;
	S rs2=$S(vos5=$C(254):"",1:vos5)
	;
	Q 1
	;
vOpen5()	;	INDEXNM FROM DBTBL8 WHERE %LIBS='SYSDEV' AND FID=:FID AND PARFID IS NULL
	;
	;
	S vos6=2
	D vL5a1
	Q ""
	;
vL5a0	S vos6=0 Q
vL5a1	S vos7=$G(FID) I vos7="" G vL5a0
	S vos8=""
vL5a3	S vos8=$O(^DBTBL("SYSDEV",8,vos7,vos8),1) I vos8="" G vL5a0
	S vos9=$G(^DBTBL("SYSDEV",8,vos7,vos8))
	I '($P(vos9,"|",15)="") G vL5a3
	Q
	;
vFetch5()	;
	;
	;
	I vos6=1 D vL5a3
	I vos6=2 S vos6=1
	;
	I vos6=0 Q 0
	;
	S rs3=$S(vos8=$C(254):"",1:vos8)
	;
	Q 1
	;
vOpen6()	;	INDEXNM FROM DBTBL8 WHERE %LIBS='SYSDEV' AND FID=:V1 AND PARFID IS NULL ORDER BY INDEXNM ASC
	;
	;
	S vos1=2
	D vL6a1
	Q ""
	;
vL6a0	S vos1=0 Q
vL6a1	S vos2=$G(V1) I vos2="" G vL6a0
	S vos3=""
vL6a3	S vos3=$O(^DBTBL("SYSDEV",8,vos2,vos3),1) I vos3="" G vL6a0
	S vos4=$G(^DBTBL("SYSDEV",8,vos2,vos3))
	I '($P(vos4,"|",15)="") G vL6a3
	Q
	;
vFetch6()	;
	;
	;
	I vos1=1 D vL6a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen7()	;	%LIBS,FID,INDEXNM FROM DBTBL8 WHERE %LIBS='SYSDEV' AND FID=:FID AND PARFID IS NULL ORDER BY INDEXNM ASC
	;
	;
	S vos1=2
	D vL7a1
	Q ""
	;
vL7a0	S vos1=0 Q
vL7a1	S vos2=$G(FID) I vos2="" G vL7a0
	S vos3=""
vL7a3	S vos3=$O(^DBTBL("SYSDEV",8,vos2,vos3),1) I vos3="" G vL7a0
	S vos4=$G(^DBTBL("SYSDEV",8,vos2,vos3))
	I '($P(vos4,"|",15)="") G vL7a3
	Q
	;
vFetch7()	;
	;
	;
	I vos1=1 D vL7a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
