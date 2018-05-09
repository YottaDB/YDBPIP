DBSLOD(INPUT,OUTPUT,LODFLG,LVNLIST,DBOPT,NAME,RPCFLG,LODMSK,PROT)	;
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 12/23/97 08:01:26 - CHIANG
	; ORIG:  Frank R. Sanchez (2497) 09/18/92
	;
	; *********************************************************************
	; * THIS ROUTINE WILL EVENTUALLY BE OBSOLETED.  DO NOT ADD ANY NEW    *
	; * CALLS TO IT.                                                      *
	; *********************************************************************
	;
	; I18N=QUIT : Excluded from I18N standards.             
	; Utility to build MUMPS code for loading data of single record
	;
	; ARGUMENTS:
	;    . INPUT	Input data item name		/TYP=T/MECH=REFNAM:R
	;    . OUTPUT	Output record load array name	/TYP=T/REQ/MECH=REFNAM:W
	;    . LODFLG	$D checking of load expression	/TYP=N/MECH=VAL
	;               1 = Add $D checking on nodes
	;               2 = Add $D checking on computed data items
	;               11= option 1 and also save short name in a list
	;		12= option 2 and also save short name in a list
	;
	;    . LVNLIST	Local variable list		/TYP=T/MECH=REFNAM:RW
	;    . DBOPT	DATA-QWIK option		/TYP=N/MECH=VAL
	;		2=Screen,5=Report
	;    . NAME	DBTBL file Name		        /TYP=T/MECH=VAL
	;    . RPCFLG	Include RPC logic		/TYP=L/MECH=VAL
	;    . LODMSK	Array of previously loaded data	/TYP=T/MECH=REFNAM:RW
	;    . PROT     A list of data item names       /TYP=T/MECH=REFNAM:R
	;               PROT(FID,DI)=""
	;
	; INPUTS:
	;
	;     %LIBS 	Library Name			/TYP=T/REQ/MECH=VAL
	;     FILES 	Access files (PFID,FID ...)	/TYP=T/REQ/MECH=VAL
	;     LOOP  	Information from data item 	/TYP=T/NOREQ/MECH=REFNAM
	;		definitions
	;
	; RETURNS:
	;
	;     VNEW  	Screen VNEW init section		/TYP=T
	;
	;   Example #1: with $D option
	;
	;           S %LIBS="SYSDEV",FILES="DEP"
	;           S A("[DEP]BAL")="",A("[DEP]IRN")=""
	;           D ^DBSLOD(.A,.B,1)
	;
	; Output:    
	;
	;          B(100) = S:$D(DEP(51))#2=0 DEP(51)=$G(^ACN(CID,51))
	;                   S:$D(DEP(57))#2=0 DEP(57)=$G(^ACN(CID,57))
	;
	;   Example #2: without $D option
	;
	;           S %LIBS="SYSDEV",FILES="DEP"
	;           S A("DEP.BAL")="",A("DEP.IRN")="",A("DEP.BALAVL")=""
	;           D ^DBSLOD(.A,.XYZ,0)
	;
	; Output:
	;
	;          XYZ(101) = S DEP(51)=$G(^ACN(CID,51)),DEP(57)=$G(^(57))
	;          XYZ(102) = S BALAVL=$P(DEP(51),"|",1)-$P(DEP(51),"|",8)-$P(DEP(51),"|",9)
	;
	;   Example #3: delete short name array
	;
	;           S %LIBS="SYSDEV",FILES="DEP"
	;           S A("DEP.BAL")=""
	;           D ^DBSLOD(.A,.ABC,11)
	;
	; Output:
	;
	;          ABC(100)= S:$D(DEP(51))#2=0 DEP(51)=$G(^ACN(CID,51)),vzkil=$G(vzkil)_",DEP(51)"
	;
	;---------- Revision History -------------------------------------------
	; 04/06/07 - RussellDS - CR26386
	;	     Removed code dealing with euro conversion and UHFETCH call.
	;	     Will need to deal with euro in different manner in future.
	;
	; 12/05/05 - RussellDS - CR18400
	;	     Moved LOAD section and supporting sub-routines here from
	;	     DBSDD.  This code will eventually be obsoleted, so this
	;	     avoid rewriting to PSL in DBSDD.
	;
	;	     Moved gbl^DBSDD code in for same reason.
	;
	; 03/21/05 - RussellDS - CR14908
	;	     Modified PROTSERV section to call %EXT^protpgm with () since
	;	     now accepts object parameter.  This won't pass an object, so
	;	     %EXT will load it.  Also, pass VP as new second parameter to
	;	     clean up code.
	;
	; 12/17/97 - Chiang - 27185
	;            Modified to add new options 11 and 12 to parameter LOADFLG.
	;            If the flag is greater than 10, then the short name
	;            reference will be included in a variable "vzkil".  The
	;            variable will be used by the filer to clean up variables
	;            before existing from the routine.
	;
	; 10/20/97 - Chiang - 25624
	;            Modified EXEC section to load memo data ahead of regular
	;            computed items.
	;
	; 10/08/97 - Chiang 26390
	;            Modified EXEC section to return the correct error message.
	;            Replaced $ZP references with $O.
	;            Removed old revision history.
	;
	; 12/24/96 - JIAQ - 21692
	;            Retrofit 23209 (v5.0) to v5.2
	; 
	; 12/03/96 - watsond - 23209 
	;            Modified the RPC linetag to set OUTPUT(rpcline+.5)=" 
	;            Previously it was setting + .1 which then caused the 
	;            Balavl variable to get overriden in the routine DEPCDI. 
	;
	; 10/08/96 - Bob Chiang - 20948
	;            Add load option 2 (LODFLG parameter) to load computed
	;            data item only if it's being referenced the first time.
	;
	;-----------------------------------------------------------------------
	;
	I $G(%LIBS)="" N %LIBS S %LIBS=^CUVAR("%LIBS")
	S DBOPT=+$G(DBOPT)
	S LODFLG=+$G(LODFLG)
	S LODMSK=+$G(LODMSK)
	S KILFLG=+$G(KILFLG)
	S RPCFLG=+$G(RPCFLG)
	;
	I '$D(LVNLIST) S LVNLIST=""
	;
	I $G(INPUT)'="*" N fsn,comp				; 11/24/92  FRS
	;
	N L,MPLCT,USERVLOD,Z
	S L=$O(OUTPUT(""),-1)+1
	;
	S USERVLOD=0 
	I DBOPT=2,$G(NAME)'="",$G(^DBTBL(%LIBS,2,NAME,0,101))'="" S USERVLOD=1
	;
	D EXEC
	I $D(PROT) D PROTSRV
	;
	I $E(LVNLIST)="," S LVNLIST=$E(LVNLIST,2,$L(LVNLIST))
	;
	I 'LODMSK Q
	;
	S LODMSK=LODMSK+1
	;
	N file,node
	S file="",node=""
	;
	F  S file=$O(fsn(file)) Q:file=""  F  S node=$O(fsn(file,node)) Q:node=""  S LODMSK(file,node)=fsn(file,node)
	Q
	;
EXEC	;
	;
	N PFID,FID,di,defkeys,file,filelist,dosub,lcomp,lvn,node,svcomp,clcomp,yesrpc,norpc,reskeys
	N z,z1,z2,z3,I,X,NS
	;
	I '$D(FILES) N FILES S z=$O(INPUT("")),FILES=$P(z,".",1)	; File name
	S (PFID,FID)=$P(FILES,",",1)
	;
	I $D(INPUT)<10,$D(fsn)<10,$D(LOOP) D FSN	; Make fsn(array) from LOOP(array)
	I $G(INPUT)'="",INPUT'="*" F I=1:1:$L(INPUT,",") D PARSE^DBSDD($P(INPUT,",",I),"",.comp,.fsn,"",.vdd)
	I $D(INPUT)>1 S z="" F  S z=$O(INPUT(z)) Q:z=""  D PARSE^DBSDD(z,"",.comp,.fsn,"",.vdd)
	;
	D BLDLOOP(.LOOP,.COMP,.fsn,.comp) 	; Build LOOP
	D ^DBSREL				; File relationship logic
	;
	I USERVLOD=1 S ER=0
	E  I ER S:$G(RM)="" RM=$$^MSG(1093,FILES) Q	; *** 10/08/97
	;
	; *** BC - 05/18/94 BC - reset variable filelist
	S filelist=$G(LOOP(-2,1)) I filelist="" S filelist=FILES
	F I=2:1 Q:'$D(LOOP(-2,I))  S filelist=filelist_","_LOOP(-2,I)
	;
	I DBOPT=2 D VNEW			; Build VNEW() array
	;
	;
	S file="",di=""
	F  S file=$O(comp(file)) Q:file=""  D
	.	F  S di=$O(comp(file,di)) Q:di=""  D
	..		S z=comp(file,di)
	..		; Move memo field ahead of regular computed items *** 10/20/97
	..		I z["$$READ^DBSMEMO" S comp(file,"A00"_di)=comp(file,di) K comp(file,di)
	..		I ($E(z,1,2)'="S ")!(z["^")!(z["$$") Q
	..		S lcomp(file,di)=comp(file,di) K comp(file,di)
	;
	S norpc="",yesrpc="",clcomp="",svcomp=""
	;
	I RPCFLG=1,LODFLG=0 D RPC		; RPC Logic
	;	
	S dosub=(yesrpc'=""&(norpc'=""))	; Structure load as subr's
	S defkeys=$$KEYS($P(filelist,",",1),1)	; External access keys
	S reskeys=""				; Reserve join keys
	;
	F I=1:1:$L(filelist,",") D
	.	;
	.	S file=$P(filelist,",",I),node=""
	.	;
	.	F  S node=$O(fsn(file,node)) Q:node=""  D
	..		;
	..		S lvn=$P(fsn(file,node),"|",1)
	..		I '$$CONTAIN(LVNLIST,lvn) S LVNLIST=LVNLIST_","_lvn Q
	..		S LODMSK(file,node)=fsn(file,node) ; LVN Already loaded
	.	;
	.	I 'dosub D BUILD(file,I) Q
	.	I $$CONTAIN(yesrpc,file) D BUILD(file,I) Q
	.	D INS($$NAMSUB(file,"VLCL"," I '$D(%RPC) D "))
	.	;
	.	S lvn="" F  S lvn=$O(LOOP(-2,I,lvn)) Q:lvn=""  S reskeys=reskeys_","_lvn
	;
	S reskeys=""
	;
	S z=" D VCOM" I $D(PROT) S z=z_",VPROTDI"
	S z=z_" Q"
	I dosub D INS($S($D(COMP):z,1:" Q")) F I=1:1:$L(norpc,",") D
	.	;
	.	S file=$P(norpc,",",I)
	.	D INS()
	.	D INS($$NAMSUB(file,"VLCL",""," ; "_file_" - Client Load"))
	.	D INS()
	.	;
	.	D BUILD(file,$$CONTAIN(filelist,file))
	.	D INS(" Q")
	;
	I '$D(COMP) Q
	;
	D INS()
	D INS($$NAMSUB("","VCOM",""," ; Computed"))
	;
	I dosub D
	.	;
	.	I svcomp'="" D INS($$NAMSUB(svcomp,"VCSV"," D "))
	.	I clcomp'="" D INS($$NAMSUB(clcomp,"VCCL"," I '$D(%RPC) D "))
	.	I $D(lcomp) D INS(" D VCOML")
	.	D INS(" Q")
	;
	S file="",lvn=""
	;
	F  S file=$O(comp(file)) Q:file=""  D
	.	;
	.	I dosub D
	..		N prefix
	..		S prefix=$S($$CONTAIN(clcomp,file):"VCCL",1:"VCSV")
	..		D INS(),INS($$NAMSUB(file,prefix,""," ; "_file_" - Computed"))
	.	;
	.	F  S lvn=$O(comp(file,lvn)) Q:lvn=""  D		; *** 10/08/96
	..		I LODFLG#10'=2 D INS(" "_comp(file,lvn)) Q
	..		S z1=lvn I $E(z1,1,3)="A00" S z1=$E(z1,4,999)	; Remove dummy name (memo field)
	..		D INS(" I '$D("_z1_") "_comp(file,lvn))
	.	;
	.	I dosub D INS(" Q")
	;
	I '$D(lcomp) Q
	;
	I $G(RPCFLG) D INS(),INS("VCOML I $D(%RPC) Q  ; Don't execute on server"),INS() ; *** 07/25/94 BC
	;
	F  S file=$O(lcomp(file)) Q:file=""  D
	.	;
	.	F  S lvn=$O(lcomp(file,lvn)) Q:lvn=""  D INS(" "_lcomp(file,lvn))
	;
	Q
	;
	;-----------------------------------------------------------------------
BLDLOOP(LOOP,COMP,fsn,comp)	; Convert new structure to old 
	;
	; Build LOOP() & COMP() from fsn() and comp() for reverse compatibility
	;
	; 	fsn(file)=lvn( | glvn | filetyp | filer_program
	;	fsn(file,node)=lvn | inherit_flag_ddref | inherit_file | node
	;	comp(file,dinam)=expr
	;
	;	eg: fsn("DEP")="DEP(|^ACN(CID|10|^DEPFILE(%O)"
	;	    fsn("DEP",49)="DEP(49)|DFT|DTYP|49"
	;
	;       LOOP(-1,file)=lvn
	;	LOOP(lvn)=key1|...keyn
	;	LOOP(lvn,node)=def1|...defn (obselete default(s))
	;	COMP(dinam)=expr
	;
	;	eg:  LOOP(-1,"DEP")="DEP"
	;	     LOOP("DEP")="CID|"
	;	     LOOP("DEP",49)="|||||...
	;-----------------------------------------------------------------------
	;
	N di,file,node,lvn,keys,z
	;
	S file="",di="",node=""
	;
	F  S file=$O(comp(file)) Q:file=""  D
	.	F  S di=$O(comp(file,di)) Q:di=""  D
	..		S z=comp(file,di) I $E(z,1,2)="S " S z=$P(z,"=",2,99)
	..		I '$D(COMP(di)) S COMP(di)=z
	;
	F  S file=$O(fsn(file)) Q:file=""  D
	.	;
	.	S z=fsn(file),lvn=$P(z,"|",1)
	.	I $E(lvn,$L(lvn))="(" S lvn=$E(lvn,1,$L(lvn)-1)
	.	S keys=$TR($P($P(z,"|",2),"(",2),",","|")_"|"
	.	S LOOP(-1,file)=lvn
	.	S LOOP(lvn)=keys
	.	F  S node=$O(fsn(file,node)) Q:node=""  D
	..		S z=node I z=" " S z=$P(keys,"|",$L(keys,"|")-1)
	..		S LOOP(lvn,z)=""
	;
	Q
	;
	;-----------------------------------------------------------------------
FSN	; Make fsn(array) out of LOOP(array) - Reverse of subroutine LOOP
	;-----------------------------------------------------------------------
	;
	N I,file,node,lvn,lvns,keys,bkey,ddref
	;
	S file="",node="",lvns=""
	;
	F  S file=$O(LOOP(-1,file)) Q:file=""  D
	.	;
	.	S lvn=LOOP(-1,file),bkey=$P(LOOP(lvn),"|",$L(LOOP(lvn),"|")-1)
	.       F  S node=$O(LOOP(lvn,node)) Q:node=""  D 
	..              I node=+node!($E(node)="""") S ref=node 
	..              E  I node=bkey S ref=" " 
	..              E  S ref=""""_node_"""" 
	..              I $$CONTAIN(lvns,lvn_"("_ref_")") Q 
	..              D lodnod^DBSDD(file,ref,.fsn) 
	..              S lvns=lvns_","_lvn_"("_ref_")" 
	;
	I '$D(COMP) Q  					; Computed's in correct form
	;
	N ER,RM						; Throw errors away
	;
	S lvn="",file=""
	;
	F  S lvn=$O(COMP(lvn)) Q:lvn=""  D
	.	;
	.	S file=""
	.	F  S file=$O(LOOP(-1,file)) Q:file=""  S ddref=file_"."_lvn I $$CMP^DBSDD(ddref,"",.vdd)'="" D  Q
	..		;
	..		D PARSE^DBSDD(.ddref,"",.comp,.fsn,"",.vdd)
	..		S file=$P(ddref,".",2),di=$P(ddref,".",3)
	..		I '$D(comp(file,di)) D
	...			S NS="S "_lvn_"="_NS
	...			I NS["^"!(NS["$$") S comp(file,di)=NS Q
	...			S lcomp(file,di)=NS
	Q
	;
	;-----------------------------------------------------------------------
BUILD(file,filenum)	; Build access logic for each file
	;-----------------------------------------------------------------------
	;
	N array,keys,key,lvn,node,q,v,z,I
	;
	I $D(fsn(file))<10 Q				; Nothing to Load
	;
	D LOAD(file,.fsn,.array,'LODFLG,.LODMSK)
	S q=""""
	I $D(array) D				;  *** XUS 2/14/95
	.	F I=1:1:array D
	..		S v=array(I)
	..		I LODFLG<10 D INS(" "_v) Q
	..		S z=$P($P(v,"=0 ",2),"=",1)
	..		I z[q S z=$$QADD^%ZS(z),z=$E(z,2,$L(z)-1)
	..		S v=v_",vzkil("_q_z_q_")="_q_q
	..		D INS(" "_v)
	;
	S lvn=""
	;
	F  S lvn=$O(LOOP(-2,filenum,lvn)) Q:lvn=""  D
	.	;
	.	I $$CONTAIN(defkeys,lvn) Q
	.	I $$CONTAIN(reskeys,lvn) Q
	.	S defkeys=defkeys_","_lvn
	.	S expr=LOOP(-2,filenum,lvn)
	.	;
	.	I $E(expr,1,2)'="S " s expr="S "_lvn_"="_expr ; RC 02/05/93
	.	D INS(" "_expr_" I "_lvn_"="""" S "_lvn_"=0")
	;
	Q
	;
	;-----------------------------------------------------------------------
RPC	; Build remote procedure database load logic
	;-----------------------------------------------------------------------
	;
	; Check if there are any server based files in the list filelist
	;
	I filelist="" Q					; Skip RPC logic
	F I=1:1:$L(filelist,",") I '$$NETOPT($P(filelist,",",I)) Q
	E  Q
	;
	N cnt,crc,expr,file,keys,key,lvn,map,header,node
	N getkey,keynum,defkeys,retlvns,sndlvns
	;
	D INS()
	D INS(" I $G(%LOGID) D  Q")
	D INS(" . ;")
	;
	S norpc="",yesrpc="",cnt=0,retlvns=""
	;
	S lvns=$$KEYS($P(filelist,",",1),1)
	S sndlvns=lvns					; Join Keys for RPC
	;
	F I=1:1:$L(filelist,",") D RPCLOD(filelist,I)
	;						; *** 03/15/96
	I $D(PROT) D PROTCLI				; Client logic
	;
	S getkey="",expr="",cnt=0
	I sndlvns'="" F I=1:1:$L(sndlvns,",") D
	.	S lvn=$P(sndlvns,",",I),cnt=cnt+1
	.	I expr="" S expr=lvn
	.	E  S expr=expr_"_$C(28)_"_lvn
	.	S getkey=getkey_","_lvn_"=$P(%RPC,$C(28),"_cnt_")"
	;
	I expr="" S expr=""""""
	I svcomp'="" S svcomp=$E(svcomp,2,999)
	I clcomp'="" S clcomp=$E(clcomp,2,999) D INS($$NAMSUB(clcomp,"VCCL"," . D "))
	;
	I $D(lcomp),'$G(USERVLOD) D INS(" . D VCOML")
	;
	S crc="",z=""
	F  s z=$O(OUTPUT(z)) Q:z=""  S crc=crc_$C($$XOR^%ZFUNC(OUTPUT(z)))
	S crc=$$XOR^%ZFUNC(crc)
	;
	S OUTPUT(rpcline)=" . D STUB^DBSCLI(""VLOD^"_PGM_""","_crc_",,"_expr_",,""v"") I ER K %RPC Q"
	S OUTPUT(rpcline+.5)=" . I '$$ONLINE^DBSCLI() D VNEW Q   ;  init if offline"
	;
	S header=" I $D(%RPC) S "
	I getkey'="" S header=header_$E(getkey,2,$L(getkey))_","
	S header=header_"%RPC="""_crc
	;
	D INS()
	I $D(retlvns)=1 D  Q				; *** 03/13/96
	.	S z=header_retlvns			; Variable list
	.	I $D(PROT) S z=z_",VPIND"		; protection indicator
	.	S z=z_""""
	.	D INS(z),INS() Q
	;
	D INS(),INS(header_retlvns(1)_""" D")
	F I=2:1 Q:'$D(retlvns(I))  D INS(" . S %RPC=%RPC_"""_retlvns(I)_"""")
	D INS(" . S %RPC=%RPC_"""_retlvns_"""")
	I $D(PROT) D INS(" . S %RPC=%RPC_"""_",VPIND"_"""")	; 03/13/96
	D INS()
	Q
	;
	;----------------------------------------------------------------------
PROTCLI	; Unpack protection bitmap
	;----------------------------------------------------------------------
	N di,fid,i,q,v
	D INS(" . K vp ; data item protection logic")
	D INS(" . S vp=$P(v,$C(28),"_(cnt+1)_")")		; Protection indicator
	S i=1,fid="",di="",q="""",v=""
	F  S fid=$O(PROT(fid)) Q:fid=""  F  S di=$O(PROT(fid,di)) Q:di=""  D
	.	S v=v_",vp("_q_fid_q_","_q_di_q_")=$E(vp,"_i_")"	; Load bitmap into VP()
	.	S i=i+1
	.	I $L(v)>200 D INS(" . S "_$E(v,2,999)) S v=""	; Need new line
	I v'="" D INS(" . S "_$E(v,2,999))
	Q
	;-----------------------------------------------------------------------
RPCLOD(filelist,filenum)	; Build RPC Load Code
	;-----------------------------------------------------------------------
	;
	N file,map,lvn,I,maxrec
	;
	S maxrec=$$MAXREC
	S file=$P(filelist,",",filenum)
	S node="",map="",lvn=""
	;
	I $$NETOPT(file) D  Q
	.	;
	.	D INS($$NAMSUB(file,"VLCL"," . D "))
	.	I $D(comp(file)) S clcomp=clcomp_","_file
	.	I norpc="" S norpc=file Q
	.	S norpc=norpc_","_file
	;
	I yesrpc="" D
	.	; 
	.	S rpcline=$O(OUTPUT(""),-1)+1,L=rpcline
	.	S yesrpc=file
	.	;
	.	F I=1:1:(filenum-1) F  S lvn=$O(LOOP(-2,I,lvn)) Q:lvn=""  D
	..		;
	..		I $$CONTAIN(sndlvns,lvn) Q
	..		S sndlvns=sndlvns_","_lvn
	;
	E  S yesrpc=yesrpc_","_file
	;
	I $D(comp(file)) S svcomp=svcomp_","_file
	;
	F  S lvn=$O(LOOP(-2,filenum,lvn)) Q:lvn=""  D		; Join Keys
	.	;
	.	I $$CONTAIN(lvns,lvn) Q
	.	I $$CONTAIN(sndlvns,lvn) Q
	.	S lvns=lvns_","_lvn
	.	D ADDMAP(lvn)
	;
	F  S lvn=$O(comp(file,lvn)) Q:lvn=""  D			; Computeds
	.	;
	.	I $$CONTAIN(lvns,lvn) Q
	.	I $$CONTAIN(sndlvns,lvn) Q
	.	S lvns=lvns_","_lvn
	.	D ADDMAP(lvn)
	;
	F  S node=$O(fsn(file,node)) Q:node=""  D ADDMAP($P(fsn(file,node),"|",1))
	;
	I map'="" D INS(" . S "_$E(map,2,$L(map)))
	Q
	;
	;----------------------------------------------------------------------
ADDMAP(lvn)	; Add variable to mapped record
	;----------------------------------------------------------------------
	;
	S cnt=cnt+1
	I $L(map)+$L(lvn)>maxrec D INS(" . S "_$E(map,2,$L(map))) S map=""
	S map=map_","_lvn_"=$P(v,$C(28),"_cnt_")"
	I lvn["""" S lvn=$$DBLQ(lvn)
	;
	I $L(retlvns)+$L(lvn)>maxrec S retlvns($O(retlvns(""),-1)+1)=retlvns,retlvns=""
	S retlvns=retlvns_","_lvn
	Q
	;
	;----------------------------------------------------------------------
INS(expr)	; Insert a MUMPS expression into the next source code line
	;----------------------------------------------------------------------
	;
	I $g(expr)="" S expr=" ;"
	S L=L+1,OUTPUT(L)=expr
	Q
	;
	;----------------------------------------------------------------------
LVN(file)	; Return Local variable array for file
	;----------------------------------------------------------------------
	;
	Q $P($P(fsn(file),"|",1),"(",1)
	;
	;----------------------------------------------------------------------
CONTAIN(P1,P2)	; Returns position of string P2 in P1
	;----------------------------------------------------------------------
	;
	S P1=","_P1_",",P2=","_P2_","
	I P1[P2 Q $L($P(P1,P2,1),",")
	Q 0
	;
	;----------------------------------------------------------------------
KEYS(file,nolit)	; Return file access keys
	;----------------------------------------------------------------------
	;
	N z
	I file="" S z=""
	E  D
	.	N x
	.	S x=$P($G(^DBTBL("SYSDEV",1,file,100)),"|",1)
	.	I $P(x,"(",2)="""*""" S x=$P(x,"(",1)_"("
	.	S z=$p($P(x,"|",1),"(",2,99)
	I '$G(nolit) Q z
	;
	N I,keys,key
	;
	S keys=""
	F I=1:1:$L(z,",") I $L($P(z,",",1,I),"""")#2 D
	.	;
	.	S key=$P(z,",",I)
	.	I key=+key!("$"""[$E(key)) Q
	.	S keys=keys_","_key
	;
	Q $E(keys,2,$L(keys))
	;
	;----------------------------------------------------------------------
NAMSUB(files,prefix,preamble,postamble)	; Build Subroutine Names by convention
	;----------------------------------------------------------------------
	;
	N secnum
	S secnum=LODMSK I secnum<2 S secnum=""		; Don't number 1st iter
	;
	I files="" Q $G(preamble)_prefix_secnum_$G(postamble)
	I files'["," Q $G(preamble)_prefix_secnum_$$CONTAIN(filelist,files)_$G(postamble)
	;
	N I,file,z
	;
	S z=""
	F I=1:1:$L(files,",") D
	.	;
	.	S file=$P(files,",",I)
	.	S z=z_","_prefix_secnum_$$CONTAIN(filelist,file)
	;
	Q $G(preamble)_$E(z,2,$L(z))_$G(postamble)	
	;
	;----------------------------------------------------------------------
NETOPT(file)	; Returns File distributed network option
	;
	;	  0 - Server only
	;	  1 - Shared, Server maintained, deferred client update
	;	  2 - Shared, Client/Server realtime synchronization
	;	  3 - Client only
	;----------------------------------------------------------------------
	;
	I file="" Q 0				; Dummy file definition
	Q +$P($G(^DBTBL(%LIBS,1,file,10)),"|",3)
	;
	;----------------------------------------------------------------------
VNEW	; build New Record initialization section
	;----------------------------------------------------------------------
	;
	;
	N z,file,lvn,node,maxrec,cnt,I
	;
	S maxrec=$$MAXREC
	S z="",lvn="",node="",cnt=99
	;
	F  S lvn=$O(COMP(lvn)) Q:lvn=""  S z=z_","""_lvn_""""
	I z="" S VNEW(cnt)=" ;"
	E  S VNEW(cnt)=" F I="_$E(z,2,$L(z))_" I '$D(@I) S @I="""""
	;
	F I=1:1:$L(filelist,",") D
	.	;
	.	S file=$P(filelist,",",I),z="",cnt=cnt+1
	.	F  S node=$O(fsn(file,node)) Q:node=""  D
	..		S lvn=$P(fsn(file,node),"|",1)
	..		I $L(z)+$L(lvn)+9>maxrec S VNEW(cnt)=" S "_$E(z,2,$L(z)),z="",cnt=cnt+1
	..		S z=z_","_lvn_"=$G("_lvn_")"
	.	;
	.	I z'="" S VNEW(cnt)=" S "_$E(z,2,$L(z))
	;
	Q
	;
MAXREC()	Q 70					; Maximum Record
	;
	;----------------------------------------------------------------------
DBLQ(expr)	; Replace quotes with double quotes
	;----------------------------------------------------------------------
	;
	N y
	S y=0
	F  S y=$F(expr,"""",y) Q:y=0  S expr=$E(expr,1,y-1)_""""_$E(expr,y,$L(expr)),y=y+1
	Q expr
	;
	;----------------------------------------------------------------------
MOVE(INPUT,OUTPUT)	; Create Input list from Dictionary List
	;----------------------------------------------------------------------
	;
	N ddref
	S ddref="" 
	F  S ddref=$O(INPUT(ddref)) Q:ddref=""  I $L(ddref,".")=3 S OUTPUT(ddref)=""
	Q
	;---------------------------------------------------------------------- 
PROTSRV	; Insert protection logic after the VCOMP section 
	;---------------------------------------------------------------------- 
	N di,fid,i,pgm,q,v,v1,z 
	S fid="",di="",q="""" 
	;;D INS(" Q")
	D INS("VPROTDI ; Data item protection") 	; Section tag
	D INS(" N i,VP")
	D INS(" K vp S VPIND="_q_q)                    ; Init VP indicator
	F  S fid=$O(vp(fid)) Q:fid=""  D 
	.       S v="",v1="" 
	.       D ^UPID(fid,.pgm)                       ; Run-time routine name 
	.       I pgm="" Q 
	.       F  S di=$O(vp(fid,di)) Q:di=""  D       ; S VP(di)="",... 
	..              S v=v_","_q_di_q 
	..              S v1=v1_"_+VP("_q_di_q_")" 
	.       D INS(" K VP F i="_$E(v,2,999)_" S VP(i)="_q_q)
	.       D INS(" D %EXT^"_pgm_"(,.VP) ; Prot status")
	.       D INS(" F i="_$E(v,2,999)_" S VPIND=VPIND_+VP(i),vp("_q_fid_q_",i)=VP(i) ; Pack prot indicator")
	Q
	;
	;----------------------------------------------------------------------
LOAD(file,fsn,array,nlv,fma,frm,vsub,cmp,new)	;private; Generate Database Load Executable Code
	;----------------------------------------------------------------------
	; Builds MUMPS executable code used to load records from the physical
	; MUMPS database and store them in local variables and arrays.
	;
	; NOTE:  DO NOT ADD ANY ADDITIONAL CALLS TO THIS SECTION.  DBSLOD WILL
	;	 EVENTUALLY BE OBSOLETED.
	;
	; ARGUMENTS:
	;	. file		File Name		/REQ/MECH=REF:R
	;	. fsn(file)	File Attributes Record	/REQ/MECH=REF:R
	;	. fsn(file,nod)	Nodes to load		/REQ/MECH=REF:R
	;			The nod level in this array is automatically
	;			accumulated by calling PARSE^DBSDD
	;
	;	. array		Last Sequence #		/MECH=REF:RW
	;	. array(array)	MUMPS Code Returned	/MECH=REF:W
	;			This sequential array contains the
	;			MUMPS code that, when executed, loads
	;			database records into local arrays
	;
	;	. nlv		Ignore Local Array 	/NOREQ/TYP=L/DFT=N
	;			I nlv=1 S code="S var=$G(^GBL(key))"
	;			E  code="I $D(loc(1))#2=0 S loc(1)=$G(..."
	;
	;	. fma(asg)	Mask Previous Assig	/NOREQ/MECH=REF:RW
	;			This array is used to store previous
	;			assignments to prevent duplicate loading
	;
	;	. frm		File list		/NOREQ/DEL=44/MECH=VAL
	;			The global name defaults from the file
	;			header in fsn(file) if it is not provided
	;
	;	. vsub(ddref	Library.file.di
	;	. vsub(ddref)	Literal Substitution	/NOREQ/MECH=REF:R
	;			If an access key has a literal value as
	;			defined in this array, the literal value
	;			will replace the key variable.
	;
	;	. cmp(file,di)	Computed Expressions	/NOREQ/MECH=REF:R
	;	. new		List of named variables	/NOREQ/MECH=REF:RW
	;
	;
	; EXAMPLES:
	;
	; fsn("DEP")="DEP(|^ACN(CID|CID|10|0|^DEPFILE(%O)||||124|SYSDEV"
	; fsn("DEP",50)="DEP(50)"
	; fsn("DEP",51)="DEP(51)"
	; D LOAD^DBSLOD("DEP",.fsn,.array)
	; ZWR array
	; array=2
	; array(1)="I $D(DEP(50))#2=0 S DEP(50)=$G(^ACN(CID,50))"
	; array(2)="I $D(DEP(51))#2=0 S DEP(51)=$G(^ACN(CID,51))"
	;----------------------------------------------------------------------
	;
	I '$D(fsn(file)) Q
	;
	N di,expr,gbl,ifflg,ifset,lvn,nod
	;
	S gbl=$P(fsn(file),"|",2)
	I $D(vsub) S gbl=$P(gbl,"(",1)_"("_$$LITKEY($P(gbl,"(",2,99),.vsub)
	;
	S ifflg=$S($G(frm)="":0,$P(frm,",",1)=file:0,1:1),ifset=""
	I ifflg,$P(fsn(file),"|",3)="" s ifflg=0	; File without access keys
	I ifflg D IFNUL(file,$P(frm,",",1),.fsn,.vsub,.ifflg)
	;
	S di="",ifset="",nod=""
	;
	F  S nod=$O(fsn(file,nod)) Q:nod=""  D addz1(file,nod,.array,.fsn,.nlv,.fma,gbl,.new,ifflg,.ifset)
	;
	F  S di=$O(cmp(file,di)) Q:di=""  D	; Cmputed's
	.	;
	.	S expr=cmp(file,di),lvn=$P(expr,"=",1),expr=$P(expr,"=",2,99)
	.	I $E(lvn,1,2)="S " S lvn=$E(lvn,3,$L(lvn))
	.	D addz2
	;
	I ifflg D
	.	;
	.	I array=ifflg K array(ifflg) S array=array-1
	.	E  I ifset'="" S array(ifflg)=array(ifflg)_" "_ifset
	Q
	;
	;----------------------------------------------------------------------
addz1(file,nod,array,fsn,nlv,fma,gbl,new,ifflg,ifset)	; Add this nod to the loadable executable string
	;----------------------------------------------------------------------
	;
	N expr,lvn,lex,z
	;
	S lvn=$P(fsn(file,nod),"|",1)			; Local storage
	S lex=$P(fsn(file,nod),"|",2)			; Opt. Load expression
	;
	I lex="" D					; Normal Global Load
	.	;
	.	S expr=gbl
	.	I nod=" " S expr=expr_")" Q		; Data on Bottom key
	.	I $P(expr,"(",2)'="" S expr=expr_","
	.	S expr=expr_nod_")"
	;
	E  Q:$G(fma(lex))=lvn  D			; *** 01/16/96
	.	;					; Already loaded
	.	N I,bk,cnod,ddref,dilist
	.	;
	.	S fma(lex)=lvn
	.	S cnod=nod
	.	S expr=$$PCODE(lex,.dilist,.cmp,.fsn,.vsub,.vdd)
	.	F  Q:expr'["flvn"  S expr=$P(expr,"flvn",1)_lvn_$P(expr,"flvn",2,999)
	.	;
	.	F I=1:1:$L(dilist,",") D
	..		;
	..		S ddref=$P(dilist,",",I)
	..		S nod=$P(vdd(ddref),"|",1) I nod["*" Q
	..		S bk=$P(fsn(file),"|",3),bk=$P(bk,",",$L(bk,","))
	..		I nod=bk S nod=" "
	..		I nod=cnod Q
	..		D addz1(file,nod,.array,.fsn,.nlv,.fma,gbl,.new,.ifflg,.ifset)
	;
addz2	;
	I $G(fma(expr))=lvn Q				; Load previous assg
	I $D(fma(expr)) S expr=fma(expr)		; Ditto	
	E  S fma(expr)=lvn
	;
	S expr="S "_lvn_"="_expr			; Assign to local
	I $G(ifflg) S expr="E  "_expr,ifset=$S($G(ifset)="":"S ",1:ifset_",")_lvn_"="""""
	I '$G(nlv) S expr="S:$D("_lvn_")#2=0 "_$E(expr,3,$L(expr))
	;
	I $G(new)="" S new=$P(lvn,"(",1)
	E  I '$$CONTAINS(new,$P(lvn,"(",1)) S new=new_","_$P(lvn,"(",1)
	;
	S array=$O(array(""),-1)+1
	S array(array)=expr
	Q
	;
	;----------------------------------------------------------------------
IFNUL(file,pfile,fsn,vsub,ifflg)	;private; Build checking for join keys
	;----------------------------------------------------------------------
	;
	N I,expr,key,keys1,keys2
	S keys1=$P(fsn(pfile),"|",3),keys2=$P(fsn(file),"|",3),expr=""
	;
	F I=1:1:$L(keys2,",") D
	.	;
	.	S key=$P(keys2,",",I)
	.	S key=$$LITKEY(key,.vsub)		; *** 06/12/96
	.	I key=+key!($E(key)="""") Q		; Literal key
	.	I key="""""" S expr=1,I=1E18 Q		; Null key literal
	.	; Simple name match joins for now, improve later !!
	.	I $$CONTAINS(keys1,key) Q
	.	I expr="" S expr=key_"=""""" Q
	.	S expr=expr_"!("_key_"="""")"
	;
	I expr="" S ifflg=0 Q
	;
	S array=$O(array(""),-1)+1
	S array(array)="I "_expr
	S ifflg=array
	Q
	;
	;----------------------------------------------------------------------
LITKEY(keys,vsub)	; Substitute literal keys for variables
	;----------------------------------------------------------------------
	;
	N I,zdinam,comma
	;
	S comma=0
	S zdinam=$P(fsn(file),"|",11)_"."_file_"."
	;
	F I=1:1:$L(keys,",") D
	.	;
	.	S z=zdinam_$P(keys,",",I+comma)			; *** 02/08/96
	.	I $D(vsub(z))#2=0 Q
	.	S $P(keys,",",I+comma)=vsub(z)			; ***
	.	I vsub(z)["," S comma=comma+$L(vsub(z),",")-1	; Extra comma
	;
	Q keys
	;
	;----------------------------------------------------------------------
CONTAINS(list,entry)	; See if entry is contained in list
	;----------------------------------------------------------------------
	;
	Q (","_list_",")[(","_entry_",")
	;
	;----------------------------------------------------------------------
PCODE(X,dilist,cmp,fsn,vsub,vdd)	;private; Parse Code for macro {} substitution
	;----------------------------------------------------------------------
	; Parses input string for the sentinal characters {fid.di} and replaces
	; inbedded contents with parsed dictionary expression.
	;
	;
	; ARGUMENTS:
	;	. X		String to Parse		/REQ/MECH=VAL
	;	. dilist	List of Found Data Items
	;	. cmp(file,di)	Computed Expressions	/NOREQ/MECH=REF:R
	;	. cmp		Computed Data Expressions
	;	. fsn(file)	File Headers
	;	. vsub(ddref	Library.file.di
	;	. vsub(ddref)	Literal Substitution	/NOREQ/MECH=REF:R
	;	. vdd(ddref	LIB.FID.DI Reference  
	;	. vdd(ddref)	Dictionary Record	/NOREQ/MECH=REF:RW
	;
	; RETURNS:
	;	. $$		Parsed String with replacement
	;	. ER		(0,1) Error Flag
	;	. RM		Error message message (If ER=1)
	;
	; EXAMPLES:
	; W $$PCODE^DBSDD("I {DEP.BAL}>100")
	; I $P(DEP(51),"|",1)>100
	;
	N Y,Yz,NS,ddref,lvn
	S Y=0,Yz=0,dilist=""
	;
	F  S Y=$F(X,"{",Y) Q:Y=0  I $L($E(X,1,Y-1),"""")#2 DO
	.	F  S Yz=$F(X,"}",Y) Q:Yz=0  I $L($E(X,1,Yz-1),"""")#2 Q
	.	I Yz=0 Q
	.	S ddref=$E(X,Y,Yz-2),lvn=""
	.	I ddref[":" S lvn=$P(ddref,":",2),ddref=$P(ddref,":",1)
	.	D PARSE^DBSDD(.ddref,"",.cmp,.fsn,"",.vdd,lvn,.vsub) Q:ER
	.	S X=$E(X,1,Y-2)_NS_$E(X,Yz,9999),Y=Y+$L(NS)
	.	S dilist=dilist_","_ddref
	;
	S dilist=$E(dilist,2,$L(dilist))
	I ER Q ""
	Q X
