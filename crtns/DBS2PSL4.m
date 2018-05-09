 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBS2PSL4 ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBS2PSL4(dbtbl2) ; DBS2PSL4; - V7.0 - PSL Screen compiler
 ;
 N CN N DE N DF N file N i N I N K N KEYNM N LL N N N OM N P N PMT N SAVC N SAVD N SCRVLOD N sn N TT N X N XY N Y N z N Z
 ;
 S SAVD=D
 S SAVC=C
 ;
 ; check for user-defined vlod section
 S USERVLOD=$$vDbEx1()
 S C(2)=C(2)_",PGM=$T(+0),DLIB="_Q_"SYSDEV"_Q_",DFID="_Q_PFID_Q
 ;
 ; Record level protection
  S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
 I '$P(vobj(dbtbl2,0),$C(124),16) S C3P(1)=" //"
 E  D ^DBSPROT4($P(vobj(dbtbl2,0),$C(124),1),"*",.C3P,,,.vobjlst)
 ;
 ; Data entry post proc
 I $$vDbEx2() S C(2)=C(2)_",VSCRPP=1"
 I $$vDbEx3()!$$vDbEx4() S C(2)=C(2)_",VSCRPP=1"
 ;
 S RPCFLG=1 I ($P(vobj(dbtbl2,0),$C(124),4)+$P(vobj(dbtbl2,0),$C(124),7)) S RPCFLG=0
 I RPCFLG,"US" ;* if RPCFLG,CUVAR.editmask set RPCFLG=0
 I USERVLOD S RPCFLG=0
 ;
 ; Screen Pre-processor
 K OM
 N ds,vos1,vos2,vos3,vos4 S ds=$$vOpen1()
 F  Q:'$$vFetch1()  D
 .	N code N pseq
 . N dbtbl2pp,vop1 S vop1=$P(ds,$C(9),4),dbtbl2pp=$$vRCgetRecord1Opt^RecordDBTBL2PP($P(ds,$C(9),1),$P(ds,$C(9),2),$P(ds,$C(9),3),vop1,1,"")
 .	S pseq=vop1
 .	S code=$P(dbtbl2pp,$C(12),1)
 .	S OM(pseq)=code
 . Q  ; whi le ...
 ;
 D
 .	N vsqltag N PSEQ
 .	D PPLIB(.OM) ; parse for PP Libs
 .	Q 
 ;
 ; Display rep-processor
 K OM
 N rs1,vos5,vos6,vos7,vos8 S rs1=$$vOpen2()
 F  Q:'$$vFetch2()  D
 .	N code N pseq
 . N dbtbl2pp,vop2 S vop2=$P(rs1,$C(9),4),dbtbl2pp=$$vRCgetRecord1Opt^RecordDBTBL2PP($P(rs1,$C(9),1),$P(rs1,$C(9),2),$P(rs1,$C(9),3),vop2,1,"")
 .	S pseq=vop2
 .	S code=$P(dbtbl2pp,$C(12),1)
 .	S OM(pseq)=code
 . Q  ; while ...
 ;
 D
 .	N vsqltag N PSEQ
 .	D PPLIB(.OM) ; parse for PP Libs
 .	Q 
 ;
 I $get(ER),$get(RM)'="" WRITE !,RM
 K VNEW ; patch
 ;
 ; user-defined VLOD section
 I USERVLOD D
 .	; Insert VCOM first
 .	N I N X
 .	S X="" F  S X=$order(SCRVLOD(X)) Q:X=""  I SCRVLOD(X)?1"VCOM".E Q 
 .	I X>0 D
 ..		S X=$order(SCRVLOD(X),-1)
 ..		F I=1:1 S X=$order(SCRVLOD(X)) Q:X=""  S BLD(Z+I)=SCRVLOD(X) K SCRVLOD(X)
 ..		Q 
 .	;
 .	N Z
 .	S Z=$order(BLD(""),-1)+1
 .	S BLD(Z)=" #ACCEPT date=11/05/03;pgm=Screen compiler;CR=UNKNOWN;GROUP=SYNTAX"
 .	S BLD(Z+1)=" quit"
 .	S BLD(Z+2)="VLODDQ("_vobjlst("formal")_") //Original VLOD section"
 .	S BLD(Z+3)=" "
 .	S Z=Z+4
 .	Q 
 ;
 S X=""
 F I=1:1 S X=$order(SCRVLOD(X)) Q:X=""  S BLD(Z+I)=SCRVLOD(X)
 ;
 ; Build Run-time program
 K XLT,SCREEN
 D ^ULODTMPL("DBS2PSLT","TMPZ") ;load template procedure
 S N=""
 F  S N=$order(TMPZ(N)) Q:N=""  D
 .	Q:$E(TMPZ(N),1)=" "!($E(TMPZ(N),1)=$char(9))!(TMPZ(N)="") 
 .	S TMPZ(N)=$TR(TMPZ(N),$char(9)," ")
 .	S XLT($piece(TMPZ(N)," ",1))=N
 .	Q 
 ; Remove VLOD entry
 S X=XLT("VLOD") K TMPZ(X)
 I '(vobjlst("formal")="") S TMPZ(1)=PGM_"(Number %ProcessMode,"_vobjlst("formal")_")   //"_$P(vobj(dbtbl2,0),$C(124),11)_" - "_$P(vobj(dbtbl2,0),$C(124),12)_" - SID= <"_SID_"> "_$P(vobj(dbtbl2,0),$C(124),9)
 E  S TMPZ(1)=PGM_"(Number %ProcessMode)   //"_$P(vobj(dbtbl2,0),$C(124),11)_" - "_$P(vobj(dbtbl2,0),$C(124),12)_" - SID= <"_SID_"> "_$P(vobj(dbtbl2,0),$C(124),9)
 D ^SCACOPYR(.X1)
 S TMPZ(2)=X1
 K X1
 ;
 ; program header section
 S X1=2.001
 ; Documentation
 K OM
 N rs2,vos9,vos10,vos11,vos12 S rs2=$$vOpen3()
 F  Q:'$$vFetch3()  D
 .	N code,pseq
 . N dbtbl2pp,vop3 S vop3=$P(rs2,$C(9),4),dbtbl2pp=$$vRCgetRecord1Opt^RecordDBTBL2PP($P(rs2,$C(9),1),$P(rs2,$C(9),2),$P(rs2,$C(9),3),vop3,1,"")
 .	S pseq=vop3
 .	S code=$P(dbtbl2pp,$C(12),1)
 .	S TMPZ(X1)=" // "_code
 .	S X1=X1+.01
 . Q  ; while ...
 ;
 N ppre,ppro
 S ppre=$$vDbEx5() ;Screen Pre-proc
 S ppro=$$vDbEx6() ;Screen display pre-proc
 S X1=XLT("V5")
 S TMPZ(X1)="" S X1=X1+1
 S TMPZ(X1)=" if %ProcessMode=5 do VPR("_vobjlst("actual")_"),VDA1("_vobjlst("actual")_"),^DBSPNT() quit"
 I '(ppre!ppro) D
 .	S X1=XLT("V5")+2.001
 .	S TMPZ(X1)=" if '%ProcessMode do VNEW("_vobjlst("actual")_"),VPR("_vobjlst("actual")_"),VDA1("_vobjlst("actual")_")"
 .	S X1=X1+.001
 .	S TMPZ(X1)=" if %ProcessMode do VLOD("_vobjlst("actual")_") quit:$G(ER)  do VPR("_vobjlst("actual")_"),VDA1("_vobjlst("actual")_")"
 .	Q 
 ;
 ;---------- Screen Pre-Processor
 E  D
 .	I ppre D
 ..		S tag="VSCRPRE("_vobjlst("formal")_")  // Screen Pre-Processor"
 ..		D PPUTIL(61,tag)
 ..		S X1=XLT("V5")+2.001
 ..		S TMPZ(X1)=" set ER=0 do VSCRPRE("_vobjlst("actual")_") if ER quit  // Screen Pre-Processor"
 ..		S X1=X1+.001
 ..		S TMPZ(X1)=" "
 ..		Q  ; if ppre
 .	;
 .	I 'ppro D
 ..		S X1=X1+.001
 ..		S TMPZ(X1)=" if '%ProcessMode do VNEW("_vobjlst("actual")_"),VPR("_vobjlst("actual")_"),VDA1("_vobjlst("actual")_")"
 ..		S X1=X1+.001
 ..		S TMPZ(X1)=" if %ProcessMode do VLOD("_vobjlst("actual")_") quit:$G(ER)  do VPR("_vobjlst("actual")_"),VDA1("_vobjlst("actual")_")"
 ..		Q  ; if ' ppro
 .	;
 .	; ---------- Display Pre-Processor
 .	I ppro D
 ..		S tag="VDSPPRE("_vobjlst("formal")_")  // Display Pre-Processor"
 ..		D PPUTIL(121,tag)
 ..		S X1=XLT("V5")
 ..		S TMPZ(X1)=""
 ..		S X1=X1+2.005
 ..		S TMPZ(X1)=" // Display Pre-Processor" S X1=X1+.001
 ..		S TMPZ(X1)=" //" S X1=X1+.001
 ..		S TMPZ(X1)=" if '%ProcessMode do VNEW("_vobjlst("actual")_"),VDSPPRE("_vobjlst("actual")_") quit:$G(ER)  do VPR("_vobjlst("actual")_"),VDA1("_vobjlst("actual")_")"
 ..		S X1=X1+.001
 ..		S TMPZ(X1)=" if %ProcessMode do VLOD("_vobjlst("actual")_") quit:$G(ER)  do VDSPPRE("_vobjlst("actual")_") quit:$G(ER)  do VPR("_vobjlst("actual")_"),VDA1("_vobjlst("actual")_")"
 ..		Q  ; if ppro
 .	Q  ; else do ..
 ;
 S VFSN="" S file=""
 F  S file=$order(fsn(file)) Q:file=""  D
 .	S sn=$piece(fsn(file),"|",1)
 .	I $E(sn,$L(sn))'=")" S sn=$piece(sn,"(",1)
 .	S VFSN=VFSN_",VFSN("""_file_""")=""z"_$TR(sn,"%")_""""
 .	Q  ; for ..
 ;
 I VFSN'="" S VFSN=" set "_$E(VFSN,2,1048575)
 ;
 S X1=XLT("VSTART")
 S TMPZ(X1)=" #WARN SCOPE OFF"
 S X1=XLT("V0")
 ;
 S TMPZ(X1)="" S X1=X1+1.5
 ; If printing blank screen will not get objects, so instantiate empty ones
 S TMPZ(X1)=" if (%ProcessMode = 5) do {" S X1=X1+.001
 ;
 F i=1:1:$L(vobjlst("formal"),",") D
 .	;
 .	N NAME N RECORD N X
 .	;
 .	S X=$piece(vobjlst("formal"),",",i)
 .	S RECORD=$piece(X," ",1)
 .	S NAME=$piece(X," ",2)
 .	I (NAME="") Q 
 .	I ($E(NAME,$L(NAME)-2+1,1048575)="()") S NAME=$piece(NAME,"()",1)_"(1)"
 .	S TMPZ(X1)="  if '"_NAME_".exists() set "_NAME_" = Class.new("""_RECORD_""")"
 .	S X1=X1+.001
 .	Q 
 ;
 S TMPZ(X1)=" }" S X1=X1+.001
 S TMPZ(X1)=" set KVAR="""_KVAR_""",VSID="""_$S($E(SID,1)="z":$E(SID,2,10),1:SID)_""",VPGM=$T(+0),VSNAME="""_$P(vobj(dbtbl2,0),$C(124),9)_""""
 S X1=X1+.001
 I VFSN'="" S TMPZ(X1)=VFSN
 S X1=X1+.001
 S TMPZ(X1)=" set vPSL=1"
 S X1=X1+.001
 ;
 D setkeys(.dbtbl2,.KEYS) ; set up KEYS array used in VRDA section
 ;
 S X1=X1+.001
 ;
 ; Record level protection
 F I=1:1 Q:'($D(C3P(I))#2)  S TMPZ(X1)=C3P(I) S X1=X1+.001
 ;
 ;
  S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
 I $P(vobj(dbtbl2,0),$C(124),7) D
 .	S X1=XLT("V5")+1
 .	S I=23-$P(vobj(dbtbl2,0),$C(124),7) I $get(%MODGRP)>1000 S I=(I+1)\(%MODGRP\1000)
 .	S TMPZ(X1)=" if %ProcessMode=5 set %MODS=1,%REPEAT="_I_" do VPR("_vobjlst("actual")_"),VDA1("_vobjlst("actual")_"),V5^DBSPNT quit"
 .	Q  ;if dbtbl2.repeat
 ;
 ; print prompts
 S X1=XLT("VPR")
 S TMPZ(X1)="VPR("_vobjlst("formal")_") // Display screen prompts"
 S X1=XLT("VPR")+.001
 F I=1:1 S X=$get(TMPC(I)) Q:X=""  S TMPZ(X1)=X S X1=X1+.001
 ;
 ; display data
 S X1=XLT("VDA")
 S TMPZ(X1)="VDA1("_vobjlst("formal")_")  // Display screen data"
 ;
 I $D(lvns) D
 .	N n N new N new5 N set
 .	S n="" S new="" S new5="" S set=""
 .	;
 .	F  S n=$order(lvns(n)) Q:n=""  D
 ..		S lvn=lvns(n)
 ..		I lvn="%O" Q 
 ..		I lvn="%ProcessMode" Q 
 ..		I '((lvn?1A.AN)!(lvn?1"%".AN)) Q 
 ..		S new5=new5_","_lvn
 ..		I $E(lvn,1)="v" S new=new_","_lvn S set=set_","_lvn_"=$G("_n_")" Q 
 ..		S set=set_","_lvn_"=$G("_n_")" Q 
 ..		Q  ; for ...
 .	;
 .	S new5=$E(new5,2,1048575) I new5="" Q 
 .	S TMPD(.1)=" if %ProcessMode=5 new "_new5
 .	S TMPD(.2)=" if  set ("_new5_")="""""
 .	I new'="" S TMPD(.3)=" else  new "_$E(new,2,1048575)
 .	I set'="" D
 ..		S set=$E(set,2,1048575)
 ..		I $L(set)<500 S TMPD(.4)=" else  set "_set Q 
 ..		; Split the list
 ..		S z=$L(set,",")\2
 ..		; in half
 ..		S TMPD(.4)=" else  set "_$piece(set,",",1,z)
 ..		S TMPD(.41)=" else  set "_$piece(set,",",z+1,9999)
 ..		Q 
 .	;
 .	S TMPD(.5)=" "
 .	Q  ; if $D(lvns)
 ;
 I $D(rptlvns) D
 .	;
 .	N n N new N new5 N set N set1 N set2
 .	S n="" S new="" S new5="" S set="" S set1="" S set2=""
 .	S RPTDA=RPTDA-1
 .	;
 .	F  S n=$order(rptlvns(n)) Q:n=""  D
 ..		S lvn=rptlvns(n)
 ..		I lvn="%O" Q 
 ..		; Not valid
 ..		I '((lvn?1A.AN)!(lvn?1"%".AN)) Q 
 ..		S new5=new5_","_lvn
 ..		I $E(lvn,1)="v" S new=new_","_lvn
 ..		; Overflow line
 ..		I $L(set1)>440 S set2=set2_",("_lvn_","_n_")=$G("_n_")" Q 
 ..		; Overflow line
 ..		I $L(set)>440 S set1=set1_",("_lvn_","_n_")=$G("_n_")" Q 
 ..		S set=set_",("_lvn_","_n_")=$G("_n_")" Q 
 ..		Q 
 .	;
 .	S new5=$E(new5,2,1048575) I new5="" Q 
 .	S TMPD(RPTDA+.1)=" if %ProcessMode=5 new "_new5
 .	S TMPD(RPTDA+.2)=" if  set ("_new5_")="""""
 .	I new'="" S TMPD(RPTDA+.3)=" else  new "_$E(new,2,1048575)
 .	I set'="" S TMPD(RPTDA+.4)=" else  set "_$E(set,2,1048575)
 .	; Overflow line
 .	I set1'="" S TMPD(RPTDA+.41)=" else  set "_$E(set1,2,1048575)
 .	; Overflow line
 .	I set2'="" S TMPD(RPTDA+.42)=" else  set "_$E(set2,2,1048575)
 .	S TMPD(RPTDA+.5)=" "
 .	Q 
 ;
 ; Init user-defined variables
 S X1=$order(TMPD(1),-1)+.0001 S N=""
 F  S N=$order(VARLIST(N)) Q:N=""  D
 .	N var
 .	S var="" F  S var=$order(fsn(var)) Q:var=""  Q:$E($piece(fsn(var),"|",1),1,$L(N))=N 
 .	I var'="" Q 
 .	S TMPD(X1)=" s "_N_"=$G("_N_")" S X1=X1+.001
 .	Q 
 S TMPD(X1)=" //"
 S X1=XLT("VDA") S N=""
 S X1=X1+.001 S TMPZ(X1)=" new V" ; *** 08/03/94 BC
 ;
 F  S N=$order(TMPD(N)) Q:N=""  S X1=X1+.001 S TMPZ(X1)=TMPD(N)
 ;
 S X1=XLT("VDA1")
 ;mas
 ;set TMPZ(X1)="VDA("_vobjlst("formal")_")"
 S TMPZ(X1)="VDA"
 ;
 ; CR10182 - GHODKEY
 I FILES'="" D
 .	F i=1:1:$L(FILES,",") D
 ..		N file N sn
 ..		S file=$piece(FILES,",",i)
 ..		S sn=$piece(vobjlst(i),"|",1)
 ..		I $E(sn,$L(sn))="(" S sn=$E(sn,1,$L(sn)-1)
 ..		S X1=X1+.001
 ..		S TMPZ(X1)=" type Public Record"_file_" "_sn_$S(($D(vFID(file))#2):"()",1:"")
 ..		Q 
 .	Q 
 S X1=X1+.001 S TMPZ(X1)=" do VDA1("_vobjlst("actual")_")"
 S X1=X1+.001 S TMPZ(X1)=" quit"
 S X1=X1+.001 S TMPZ(X1)=""
 ;
 S X1=XLT("VREPRNT")
 S TMPZ(X1)="VREPRNT"
 ;
 I FILES'="" D
 .	F i=1:1:$L(FILES,",") D
 ..		N file N sn
 ..		S file=$piece(FILES,",",i)
 ..		S sn=$piece(vobjlst(i),"|",1)
 ..		I $E(sn,$L(sn))="(" S sn=$E(sn,1,$L(sn)-1)
 ..		S X1=X1+.001
 ..		S TMPZ(X1)=" type Public Record"_file_" "_sn_$S(($D(vFID(file))#2):"()",1:"")
 ..		Q 
 .	Q 
 ; Add protection logic
 I $order(C3P(1))>0 D
 .	S X1=X1+.001
 .	S TMPZ(X1)=" do VPROT("_vobjlst("actual")_") quit:ER"
 .	Q 
 ;
 S X1=X1+.001 S TMPZ(X1)=" do VPR("_vobjlst("actual")_")"
 S X1=X1+.001 S TMPZ(X1)=" do VDA1("_vobjlst("actual")_")"
 S X1=X1+.001 S TMPZ(X1)=" do ^DBSPNT()"
 S X1=X1+.001 S TMPZ(X1)=" quit"
 S X1=X1+.001 S TMPZ(X1)=""
 ;
 S X1=XLT("VW")
 S TMPZ(X1)="VW("_vobjlst("formal")_")"
 S TMPZ(X1+.001)=" do VDA1("_vobjlst("actual")_")"
 S TMPZ(X1+.002)=" do ^DBSPNT(10)"
 S TMPZ(X1+.003)=" quit"
 S TMPZ(X1+.004)=""
 ;
 S X1=XLT("VDAPNT")
 S TMPZ(X1)="VDAPNT("_vobjlst("formal")_")"
 S TMPZ(X1+.002)=" do VDA1("_vobjlst("actual")_")"
 S TMPZ(X1+.003)=" do ^DBSPNT(0,2)"
 S TMPZ(X1+.004)=" quit"
 S TMPZ(X1+.005)=""
 ;
 S X1=XLT("vTBL")
 S TMPZ(X1)=" if %ProcessMode<2 do VTAB("_vobjlst("actual")_")"
 ;
 I $P(vobj(dbtbl2,0),$C(124),7) D
 .	N bkey N keys N fid N sn
 .	S fid=""
 .	F  S fid=$order(vFID(fid)) Q:(fid="")  D
 ..		D fsn^SQLDD(.fsn,fid)
 ..		S keys=$piece(fsn(fid),"|",3)
 ..		S bkey=$piece(keys,",",$L(keys,","))
 ..		I bkey?.N Q  ;ignore literal key
 ..		S sn=vFID(fid)
 ..		S X1=X1+.01
 ..		S TMPZ(X1)=" type Number ptr" S X1=X1+.01
 ..		S TMPZ(X1)=" set ptr=""""" S X1=X1+.01
 ..		S TMPZ(X1)=" for  set ptr = "_sn_"(ptr).order() quit:ptr.isNull()  do {" S X1=X1+.01
 ..		S TMPZ(X1)="     if "_sn_"(ptr)."_bkey_"="""" kill "_sn_"(ptr)" S X1=X1+.01
 ..		S TMPZ(X1)="     }" S X1=X1+.01
 ..		Q 
 .	Q 
 ;
 I '$D(TAB) F I="VPOS","VPRE" D DELETE(I)
 S X1=XLT("VTAB")
 S TMPZ(X1)="VTAB("_vobjlst("formal")_")"
 ;
 ; Build %TAB
 S X1=XLT("VTAB")+0.001 S TMPZ(X1)=" " S X1=X1+.001
 ;
 ; K REQ,%TAB ...
 S TMPZ(X1)=C(1) S X1=X1+.001
 ;
 ; S %MAX=...
 S TMPZ(X1)=C(2) S X1=X1+.001
 ;
 ; S OLNTB=...
 S TMPZ(X1)=C(3) S X1=X1+.001 S TMPZ(X1)=" " S X1=X1+.001
 I VFSN'="" D
 .	S TMPZ(X1)=VFSN S X1=X1+.001
 .	S TMPZ(X1)=" //" S X1=X1+.001
 .	Q 
 ;
 S X=""
 F  S X=$order(FX(X)) Q:X=""  S TMPZ(X1)=FX(X) S X1=X1+.001
 S X1=X1+.001
 ;
 K FX
 ;
 S TMPZ(XLT("VTBL"))="VTBL("_vobjlst("formal")_") //Create %TAB(array)"
 I $D(TAB) D
 .	S TMPZ(X1)=X41
 .	S X1=X1+2.001
 .	S N=""
 .	F  S N=$order(TAB(N)) Q:N=""  S TMPZ(X1)=TAB(N) S X1=X1+.001
 .	;
 .	I $D(VPTBL) D
 ..		; ========== data item protection logic
 ..		S TMPZ(X1)=" " S X1=X1+.001
 ..		S TMPZ(X1)=" // Data item protection" S TMPZ(X1+.001)=" //"
 ..		S TMPZ(X1)=" set z=0 for  set z=$O(VPTBL(z)) quit:z="_""""""_"  set %TAB(z)=$E(%TAB(z),1,3)_(VPTBL(z)+2)_$E(%TAB(z),5,999)"
 ..		S X1=X1+.001
 ..		Q 
 .	Q 
 ;
 ; Data entry pre-processor
 N vspre
 S vspre=$$vDbEx7()
 ;set X1=XLT("VTAB1")
 S TMPZ(X1)=" do VTBL("_vobjlst("actual")_")"
 I vspre D
 .	;set X=XLT("VTAB1")
 .	S TMPZ(X1)=" do VTBL("_vobjlst("actual")_"),VDEPRE("_vobjlst("actual")_") if $G(ER) quit"
 .	Q 
 ;
 ; Required data item set definitions
 N vspp
 S vspp=$$vDbEx8()
 I vspp D
 .	S VZSEQ=40 S X=""
 .	N pproc,vos13,vos14,vos15,vos16 S pproc=$$vOpen4()
 .	F  Q:'$$vFetch4()  D
 ..		N code,pseq
 ..  N dbtbl2pp,vop4 S vop4=$P(pproc,$C(9),4),dbtbl2pp=$$vRCgetRecord1Opt^RecordDBTBL2PP($P(pproc,$C(9),1),$P(pproc,$C(9),2),$P(pproc,$C(9),3),vop4,1,"")
 ..		S pseq=vop4
 ..		S code=$P(dbtbl2pp,$C(12),1)
 ..		S diset(pseq)=code
 ..  Q  ; while ...
 .	;
 .	S VZSEQ=""
 .	F  S VZSEQ=$order(diset(VZSEQ)) Q:VZSEQ=""  D
 ..		S X=diset(VZSEQ) I X?." " Q 
 ..		I X'[";" D ^DBS2PSL5 Q:ER  Q 
 ..		; (DI,DI...)  OR (...) OR ;
 ..		;
 ..		S X=$piece(X,";",1)
 ..		F  S VZSEQ=$order(diset(VZSEQ)) Q:VZSEQ=""  S X=X_diset(VZSEQ) Q:X'[";"  S X=$piece(X,";",1)
 ..		;
 ..		; Process set definitions
 ..		D ^DBS2PSL5 Q:ER  Q 
 ..		Q  ;for loop
 . Q  ; if vspp ...
 ;
 ; Data entry post processor
 S X1=XLT("VSPP")
 S TMPZ(X1)="VSPP  // Post Processor"
 S vspp=$$vDbEx9()
 I 'vspp D
 .	D DELETE("VSPP")
 .	Q 
 E  D
 .	;
 .	S X1=XLT("VSPP")
 .	S TMPZ(X1)="VSPP   // screen post proc"
 .	S X1=X1+.001
 .	;
 .	I FILES'="" D
 ..		F i=1:1:$L(FILES,",") D
 ...			N file N sn
 ...			S file=$piece(FILES,",",i)
 ...			S sn=$piece(vobjlst(i),"|",1)
 ...			I $E(sn,$L(sn))="(" S sn=$E(sn,1,$L(sn)-1)
 ...			S TMPZ(X1)=" type Public Record"_file_" "_sn_$S(($D(vFID(file))#2):"()",1:"")
 ...			S X1=X1+.001
 ...			Q 
 ..		Q 
 .	S TMPZ(X1)=" do VSPP1("_vobjlst("actual")_")"
 .	S X1=X1+.001
 .	S TMPZ(X1)=" #ACCEPT Date=11/05/03; pgm=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX"
 .	S X1=X1+.001
 .	S TMPZ(X1)=" quit"
 .	S X1=X1+.001
 .	S TMPZ(X1)="VSPP1("_vobjlst("formal")_")"
 .	S X1=X1+.001
 .	;
 .	S vspp=$$vDbEx10()
 .	I vspp D
 ..		S X1=X1+.001 S TMPZ(X1)=" D VSPPREQ("_vobjlst("actual")_") I ER Q" S X1=X1+.001
 ..		S TMPZ(X1)=" ;" S X1=X1+.001
 ..		Q 
 .	;
 .	S X=""
 .	F  S X=$order(TMP(999,X)) Q:X=""  S TMPZ(X1)=TMP(999,X) S X1=X1+.001
 .	S TMPZ(X1)=" #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX"
 .	S X1=X1+.001
 .	S TMPZ(X1)=" quit"
 .	S X1=X1+.001
 .	Q  ; else ...
 ;
 S X=""
 F  S X=$order(TMP(1000,X)) Q:X=""  D
 .	S TMPZ(X1)=TMP(1000,X)
 .	S X1=X1+.001
 .	Q 
 ;
 S X=""
 F  S X=$order(TMP(998,X)) Q:X=""  D
 .	S TMPZ(X1)=TMP(998,X)
 .	S X1=X1+.001
 .	Q 
 ;
 S X1=XLT("VNEW")
 S TMPZ(X1)="VNEW("_vobjlst("formal")_") // Initialize arrays if %O=0"
 S X1=XLT("VNEW")+.001
 S TMPZ(X1)=" "
 S X1=X1+.001
 ;set VNEW(1)=" do VLOD("_vobjlst("actual")_")"
 ;set X1=X1+.001
 ;
 ; user defined VLOD
 I USERVLOD D
 .	; split VNEW into two sections
 .	S VNEW(1)=" do VLOD("_vobjlst("actual")_")"
 .	S X=0
 .	F I=1:1 S X=$order(VNEW(X)) Q:X=""!(+X>99)  D
 ..		S TMPZ(X1)=VNEW(X)
 ..		S X1=X1+.001 K VNEW(X)
 ..		Q 
 .	Q  ; do
 ;
 E  D  ; Set up VNEW section
 .	S X=""
 .	F  S X=$order(VNEW(X)) Q:X=""  D
 ..		S TMPZ(X1)=VNEW(X)
 ..		S X1=X1+.001
 ..		Q 
 .	K VNEW
 .	Q 
 S TMPZ(X1)=" do VDEF("_vobjlst("actual")_")"
 S X1=X1+.001
 S TMPZ(X1)=" do VLOD("_vobjlst("actual")_")"
 S X1=X1+.001
 S TMPZ(X1)=" #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX"
 S X1=X1+.001
 S TMPZ(X1)=" quit"
 ;
 S X1=XLT("vSET")
 S TMPZ(X1)="vSET(sn,di,X)"
 S X1=X1+.001
 ;
 I FILES'="" D
 .	F i=1:1:$L(FILES,",") D
 ..		N file,sn
 ..		S file=$piece(FILES,",",i)
 ..		Q:file="" 
 ..		S X1=X1+.001
 ..		S sn=$piece(vobjlst(i),"|",1)
 ..		I $E(sn,$L(sn))="(" S sn=$E(sn,1,$L(sn)-1)
 ..		S TMPZ(X1)=" type Public Record"_file_" "_sn_$S(($D(vFID(file))#2):"()",1:"")
 ..		S X1=X1+.001
 ..		I ($D(vFID(file))#2) S TMPZ(X1)=" if sn="""_file_""" do vSET"_i_"("_sn_"(I(1)),di,X)"
 ..		E  S TMPZ(X1)=" if sn="""_file_""" do vSET"_i_"(."_sn_",di,X)"
 ..		Q 
 .	Q 
 S X1=X1+.001
 S TMPZ(X1)=" #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX"
 S X1=X1+.001
 S TMPZ(X1)=" quit"
 ;
 I FILES'="" D
 .	F i=1:1:$L(FILES,",") D
 ..		S file=$piece(FILES,",",i)
 ..		Q:file="" 
 ..		S sn=$piece(vobjlst(i),"|",1)
 ..		I $E(sn,$L(sn))="(" S sn=$E(sn,1,$L(sn)-1)
 ..		S X1=X1+.001
 ..		S TMPZ(X1)="vSET"_i_"(Record"_file_" "_sn_",di,X)"
 ..		S X1=X1+.001
 ..		S TMPZ(X1)=" do "_sn_".setAuditFlag(1)"
 ..		S X1=X1+.001
 ..		S TMPZ(X1)=" set "_sn_".@di=X"
 ..		S X1=X1+.001
 ..		S TMPZ(X1)=" #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX"
 ..		S X1=X1+.001
 ..		S TMPZ(X1)=" quit"
 ..		Q 
 .	Q 
 ;
 S X1=XLT("vREAD")
 S TMPZ(X1)="vREAD(fid,di)"
 S X1=X1+.001
 ;
 I FILES'="" D
 .	F i=1:1:$L(FILES,",") D
 ..		N file,sn
 ..		S file=$piece(FILES,",",i)
 ..		Q:file="" 
 ..		S X1=X1+.001
 ..		S sn=$piece(vobjlst(i),"|",1)
 ..		I $E(sn,$L(sn))="(" S sn=$E(sn,1,$L(sn)-1)
 ..		S TMPZ(X1)=" type Public Record"_file_" "_sn_$S(($D(vFID(file))#2):"()",1:"")
 ..		S X1=X1+.001
 ..		I ($D(vFID(file))#2) S TMPZ(X1)=" if fid="""_file_""" quit $$vREAD"_i_"("_sn_"(I(1)),di)"
 ..		E  S TMPZ(X1)=" if fid="""_file_""" quit $$vREAD"_i_"(."_sn_",di)"
 ..		Q 
 .	Q 
 S X1=X1+.001
 S TMPZ(X1)=" quit """""
 ;
 I FILES'="" D
 .	F i=1:1:$L(FILES,",") D
 ..		S file=$piece(FILES,",",i)
 ..		Q:file="" 
 ..		S sn=$piece(vobjlst(i),"|",1)
 ..		I $E(sn,$L(sn))="(" S sn=$E(sn,1,$L(sn)-1)
 ..		S X1=X1+.001
 ..		S TMPZ(X1)="vREAD"_i_"(Record"_file_" "_sn_",di)"
 ..		S X1=X1+.001
 ..		S TMPZ(X1)=" if "_sn_".get().isNull() quit """""
 ..		S TMPZ(X1)=" quit "_sn_".@di"
 ..		Q 
 .	Q 
 ;
 ; Default values
 S X1=XLT("VDEF")
 S TMPZ(X1)="VDEF("_vobjlst("formal")_")"
 S X1=X1+.001
 N zdft
 I '(FILES="") D DEFAULT($piece(FILES,",",1),.zdft)
 S i=""
 F  S i=$order(zdft(i)) Q:i=""  S TMPZ(X1)=zdft(i) S X1=X1+.001
 S TMPZ(X1)=" #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX"
 S X1=X1+.001
 S TMPZ(X1)=" quit" ; temp patch until default section of filer works
 S X1=X1+.001
 ;
 I USERVLOD D
 .	S TMPZ(X1)=" #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX"
 .	S X1=X1+.001
 .	S TMPZ(X1)=" quit"
 .	S TMPZ(X1+.001)="VNEWDQ("_vobjlst("formal")_") // Original VNEW section"
 .	S TMPZ(X1+.002)=" " S X1=X1+.003
 .	S X="" F  S X=$order(VNEW(X)) Q:X=""  S TMPZ(X1)=VNEW(X) S X1=X1+.001
 .	S TMPZ(X1)=" #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX"
 .	S X1=X1+.001
 .	S TMPZ(X1)=" quit" S X1=X1+.001
 .	K VNEW
 .	Q  ; if USERVLOD
 ;
 S X=""
 F  S X=$order(BLD(X)) Q:X=""  S TMPZ(X1)=BLD(X) S X1=X1+.001
 K BLD
 K C,C1,C2,C3,Z,NL,NS,OS,P,PMT,PO,PRO,REQ,TT,Y,XY,SEQ,LF,BLD,DFV,FX
 K LL,LINE,AR,CN,DE,DEC,DF,DI,DILNM,DINAM,FMT,ER,I,LEN,VNEW,TMPX
 ;
 ; Data item pre/post processor
 I '$D(TMP("PO")) D
 .	D DELETE("VPOS")
 .	Q 
 E  D
 .	S X1=XLT("VPOS")
 .	S TMPZ(X1)="  //user-defined post procs"
 .	S X1=X1+.001
 .	S TMPZ(X1)=" //" S X1=X1+.001
 .	S X="" F  S X=$order(TMP("PO",X)) Q:X=""  S TMPZ(X1)=TMP("PO",X) S X1=X1+.0001
 .	Q 
 ;
 K %FDBL,%XDB,%XDBL,AKEY,CT,DB,DFT,FMT,K,KEYNM,KVAR,LEN,LN,PP,REF,TBL,LOOP,MAX,MIN,SFC,%DBL,CTL
 ;
 D COMPILE(.TMPZ,PGM,SID)
 Q 
 ;
DELETE(SUB) ; Delete a Subroutine and any following lines
 N N N X
 ;
 I '($D(XLT(SUB))#2) Q 
 S N=XLT(SUB) K XLT(SUB),TMPZ(N)
 F  S N=$order(TMPZ(N)) Q:N=""  S X=TMPZ(N) Q:$piece(X," ",1)'=""  K TMPZ(N)
 Q 
 ;
 ; Change every " to ""
DOUBLE(X) ; 
 N XL
 ;
 S XL=0
 F  S XL=$F(X,Q,XL) Q:XL<1  S X=$E(X,1,XL-2)_Q_Q_$E(X,XL,999) S XL=XL+1
 Q X
 ;
PPUTIL(node,tag) ; PP Label   /REQ/MECH=VAL
 ;
 N I N OM N X N X1 N X2
 ;
 S X=node-.001
 S X2=X+20
 ;
 N rs,vos1,vos2,vos3,vos4,vos5,vos6 S rs=$$vOpen5()
 F  Q:'$$vFetch5()  D
 .	N code N pseq
 . N dbtbl2pp,vop1 S vop1=$P(rs,$C(9),4),dbtbl2pp=$$vRCgetRecord1Opt^RecordDBTBL2PP($P(rs,$C(9),1),$P(rs,$C(9),2),$P(rs,$C(9),3),vop1,1,"")
 .	S pseq=vop1
 .	S code=$P(dbtbl2pp,$C(12),1)
 .	S OM(pseq)=code
 . Q  ; while ...
 ;
 D PPLIB(.OM) ; parse for PP Libs
 ;
 S X1=$order(TMPZ(""),-1)+100 S TMPZ(X1)=" //" S X1=X1+.001
 S TMPZ(X1)=tag S X1=X1+.001
 S TMPZ(X1)=" new %TAB,vtab // Disable .MACRO. references to %TAB()" S X1=X1+.001
 S TMPZ(X1)=" //" S X1=X1+.001
 ;
 S X="" F I=1:1 S X=$order(OM(X)) Q:X=""  S TMPZ(X1)=OM(X) S X1=X1+.001
 S TMPZ(X1)=" #ACCEPT date=11/05/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX"
 S X1=X1+.001
 S TMPZ(X1)=" quit"
 Q 
 ;
PPLIB(PP) ; Post Processor Library Array  /REQ/MECH=REF
 ;
 N code N end N i N ppnam N ptr
 ;set pseq=0
 S i=""
 S end=$order(PP(""),-1)+10 ; init pointer to last line of code +10
 ; that's where the PP code will be inserted.
 F  S i=$order(PP(i)) Q:i=""  D
 .	S code=PP(i)
 .	S code=$$REPEATCK(code) ;check if this DI is in a repeat region
 .	S PP(i)=code
 .	;
 .	I $piece(code,"//",1)'["@[" Q  ; not pre/post processor library, so quit
 .	S ptr=0
 .	F  S ptr=$F(code,"@[",ptr) Q:ptr=0  I $L($E(code,1,ptr),"""")#2 D
 ..		N ptrz
 ..		S ptrz=$F(code,"]",ptr) I ptrz=0 Q 
 ..		S ppnam=$E(code,ptr-1,ptrz-1) S ptr=ptrz
 ..		;if DINAM?1"[^"1E.E1"]" D MPGM Q
 ..		I ppnam?1"["1E.E1"]" S ZNQ=$S(code["/NQ":"NQ",1:"") D PPLIB1(ppnam,.code,i)
 ..		Q 
 .	S PP(i)=code ; stick modified code back into PP array.
 .	Q  ;$O(PP(i))
 ;
 Q 
 ;
PPLIB1(ppnam,code,i) ; Sequence Pointer  /REQ/MECH=VAL
 ;
 N line N linenum N xpp
 ;
 ; insert pp lib code into post processor array
 S linenum=0
 I ($D(PSEQ(ppnam))#2) S code=$piece(code,"@"_ppnam,1)_"VPO"_PSEQ(ppnam)_"("_vobjlst("actual")_")"_$piece(code,"@"_ppnam,2,99) Q 
 S xpp=$E(ppnam,2,$L(ppnam)-1) ; strip off [ ]
  N V1 S V1=xpp I '$$vDbEx11() S ER=1 S RM=$$^MSG(1425,xpp) Q  ; invalid library name
 S vpseq=$get(vpseq)+1
 ;
 I ZNQ="" S PP(end+1)="VPO"_vpseq_"("_vobjlst("formal")_")  // user library "_xpp S end=end+1 ; add tag for pp code
 ;
 ;open result set to read code from DBTBL13D
 N ds,vos1,vos2,vos3,vos4  N V2 S V2=xpp S ds=$$vOpen6()
 F  Q:'$$vFetch6()  D
 . N dbtbl13d S dbtbl13d=$$vRCgetRecord1Opt^RecordDBTBL13D($P(ds,$C(9),1),$P(ds,$C(9),2),$P(ds,$C(9),3),1,"")
 .	S line=$P(dbtbl13d,$C(12),1)
 .	S linenum=linenum+1
 .	D SET(line,linenum,end)
 . Q 
 S linenum=linenum+1
 D SET(" #ACCEPT DATE=11/05/03;pgm=screen compiler;CR=UNKNOWN;GROUP=SYNTAX",linenum,end)
 S linenum=linenum+1
 D SET(" quit",linenum,end)
 I ZNQ="" D SUBNAME(.code) S PP(i)=code ;substitute pp name with VPOseq name
 ;
 Q 
 ;
SET(line,linenum,end) ; PP Library Ending Line Num /REQ/MECH=VAL
 ;
 I line="" Q 
 S PP(linenum+end)=line I line?1" //".E Q 
 I PP(linenum+end)?.E1"["1E.E1"]".E S XOM(linenum+end)="" ; [FID]DI SYNTAX
 I PP(linenum+end)?.E1"."4U.U1"."1E.E,PP(linenum+end)'?1" //".E S XOM(linenum+end)="" ; MACRO COMMAND
 I line'?.E1" //".E S FLG=1
 ;
 ; Warning - line tag error - ~p1
 I $E(line,1)="V" S RM=$$^MSG(2967,line)
 Q 
 ;
SUBNAME(code) ; 
 ;
 S PP(linenum+end+.999)=" #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX"
 S PP(linenum+end+1)=" quit" S end=end+linenum+10
 S OM(194.99)=" #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX"
 S OM(195)=" quit"
 ;
 S code=$piece(code,"@"_ppnam,1)_"VPO"_vpseq_"("_vobjlst("actual")_")"_$piece(code,"@"_ppnam,2,99)
 S PSEQ(ppnam)=vpseq
 S vpseq=vpseq+1
 Q 
 ;
REPEATCK(X) ; 
 N di N dinam N ptr
 ;
 S ptr=0
 F  S di=$$FINDINAM^DBSDD(X,.ptr) Q:di=""  D
 .	I """(|"[$E(X,ptr) Q 
 .	S DILIST(di)=""
 .	S dinam=di
 .	I $$vREPEAT(di,$get(P(5))) S dinam=$piece(di,".",1)_"(I(1))."_$piece(di,".",2)
 .	;if $D(REPEAT($$UPPER^%ZFUNC(di)))!$$vREPEAT(P(5).get()) set dinam=$P(di,".",1)_"(I(1))."_$P(di,".",2) // add row subscript
 .	S X=$piece(X,di,1)_dinam_$piece(X,di,2,99)
 .	Q 
 Q X
vREPEAT(di,field) ; field on the screen where the post processor
 ;
 I ($D(REPEAT($ZCONVERT(di,"U")))#2) Q 1 ; referenced column is in repeat region
 ;
 N fid
 I di["." S fid=$piece(di,".",1) Q ($D(vSN(fid))#2) ; not on screen but part of repeat region file
 ;
 I ($get(field)="") Q 0 ; not a field post processor
 S fid=$E($piece(field,"]",1),2,9999)
 S fid=$piece(fid,",",2)
 Q ($D(vFID(fid))#2)
 ;
setkeys(dbtbl2,KEYS) ; KEYS array   /REQ/MECH=REF
  S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
 ;
 N acckeys N fid N key N pfid N sn
 N count N i
 ;
 S pfid=$P(vobj(dbtbl2,0),$C(124),1)
 Q:pfid="" 
 S pfid=$$Primary(pfid) ; find master file
 ;
 S count=0
 ;
 N file,vop1,vop2,vop3,vop4 S vop1="SYSDEV",vop2=pfid,file=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",pfid,0,"")
  S vop4=$G(^DBTBL(vop1,1,vop2,16))
  S vop3=$G(^DBTBL(vop1,1,vop2,12))
 S acckeys=$P(vop4,$C(124),1)
 S sn=$P(vop3,$C(124),1)
 F i=1:1:$L(acckeys,",") D
 .	S key=$piece(acckeys,",",i)
 .	Q:$$isLit^UCGM(key) 
 .	S count=count+1
 .	; if it's an array of objects, use 1st element.
 .	I '($D(vFID(pfid))#2) S TMPZ(X1)=" set KEYS("_count_")="_sn_"."_key
 .	E  S TMPZ(X1)=" set KEYS("_count_")="_sn_"(1)."_key_".get()"
 .	S X1=X1+.001
 .	Q 
 ;
 Q 
 ;
Primary(pfid) ; File list from screen control page /REQ/MECH=VAL
 ;
 N fid N keys N keylen N mfid N pkeylen
 N i
 ;
 I $L(pfid,",")=1 Q pfid
 ;
 S pkeylen=99999
 ;
 F i=1:1:$L(pfid,",") D
 .	S fid=$piece(pfid,",",i)
 .	N f,vop1,vop2,vop3 S vop1="SYSDEV",vop2=fid,f=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",fid,0,"")
 .	 S vop3=$G(^DBTBL(vop1,1,vop2,16))
 .	S keys=$P(vop3,$C(124),1)
 .	S keylen=$L(keys,",")
 .	I keylen<pkeylen D
 ..		S pkeylen=keylen
 ..		S mfid=fid
 ..		Q 
 . Q 
 ;
 Q mfid
 ;
COMPILE(TMPZ,PGM,SID) ; Screen Name  /REQ/MECH=VAL
 ;
 N I N mcode N src
 ;
 F I="VNEWDQ","VLODDQ" D DELETE(I)
 F I="F","D","C" I '$D(TB(I)) D DELETE("V"_I)
 S I="" F  S I=$order(TMPZ(I)) Q:I=""  S src(I)=TMPZ(I)
 ;
 D cmpA2F^UCGM(.src,PGM,,,,,,SID_"~Screen")
 Q 
 ;
DEFAULT(fid,code) ; Code Array
 ;
 ;N (%DB,fid,code,mode,%LIBS)
 N i N key N keys N N N NS N obj N q N sn N typ N v
 K code
 N dbtbl1,vop1,vop2,vop3,vop4,vop5 S vop1="SYSDEV",vop2=fid,dbtbl1=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",fid,0,"")
  S vop5=$G(^DBTBL(vop1,1,vop2,101))
  S vop3=$G(^DBTBL(vop1,1,vop2,12))
  S vop4=$G(^DBTBL(vop1,1,vop2,16))
 I ($P(vop5,$C(124),1)="") Q  ; No defaut data
 S keys=""
 S sn=$P(vop3,$C(124),1) ; Object name
 S obj=sn ; Object name
 S key=$P(vop4,$C(124),1) ; Access keys
 F i=1:1:$L(key,",") D
 .	Q:($E($piece(key,",",i),1)="""")!($piece(key,",",i)?.N)  ; ignore literal keys
 .	S keys=keys_","_$piece(key,",",i)
 .	Q 
 I $E(keys,1)="," S keys=$E(keys,2,999)
 I keys="" S code(1)=" if Db.isDefined("""_vop2_""","""_keys_""") S ER=1,RM=$$^MSG(2327) Q"
 E  D  ; Record defined?
 .	N where S where=""
 .	S code(0)=" quit:"
 .	S N=""
 .	I ($D(vFID(fid))#2) S sn=sn_"(I)" ; Repeat region
 .	F i=1:1:$L(keys,",") D
 ..		S N=N_"!("_sn_"."_$piece(keys,",",i)_"="""")"
 ..		S where=where_" AND "_fid_"."_$piece(keys,",",i)_"=:"_sn_"."_$piece(keys,",",i)
 ..		S code(0)=code(0)_sn_"."_$piece(keys,",",i)_".isNull() ! "
 ..		Q 
 .	S code(0)=$E(code(0),1,($L(code(0))-2))
 .	S where=$E(where,6,999)
 .	S code(1)=" quit:%ProcessMode  set ER=0 if "_$E(N,2,99999)
 .	S code(1)=code(1)_" set ER=1,RM=$$^MSG(1767,"_""""_keys_""""_") Q"
 .	S code(2)=" if Db.isDefined("""_vop2_""","""_where_""") S ER=1,RM=$$^MSG(2327) Q"
 .	Q 
 ;
 S q=""""
 S code(3)=" do "_sn_".setAuditFlag(1)" ; turn on audit flag
 ;
 F i=1:1:$L($P(vop5,$C(124),1),",") D
 .	N dinam N item N v
 .	I ($piece($P(vop5,$C(124),1),",",i)="") Q 
 .	S dinam=$piece($P(vop5,$C(124),1),",",i)
 .	S v=$$DFT^DBSDD(fid_"."_dinam,.item) ; Default value
 .	I (v="") Q 
 .	S typ=$$TYP^DBSDD(fid_"."_dinam,.item)
 .	S v=$$value(v,typ) ; Internal format
 .	S code(i+10)=" if "_sn_"."_dinam_"="_q_q_" set "_sn_"."_dinam_"="_v
 .	Q 
 ;
 Q 
 ;
value(v,typ,var) ; Convert internal to external format
 ;----------------------------------------------------------------------
 ;
 N q
 S q=""""
 S v=$$value^DBSFILER(v,typ)
 I $get(var),v?1A.AN!(v?1"%".AN) S v=q_"<<"_v_">>"_q ; <<variavle>>
 Q v
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61569^11634^Sha H Mirza^34637" ; Signature - LTD^TIME^USER^SIZE
 ;
vDbEx1() ; min(1): DISTINCT LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS=:%LIBS AND SID=:SID AND SEQ=0 AND PSEQ=101
 ;
 N vsql1,vsql2
 S vsql1=$$BYTECHAR^SQLUTL(254)
 S vsql2=$G(%LIBS) I vsql2="" Q 0
 ;
 I '($D(^DBTBL(vsql2,2,SID,0,101))#2) Q 0
 Q 1
 ;
vDbEx10() ; min(1): DISTINCT LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS=:%LIBS AND SID=:SID AND SEQ=0 AND PSEQ=41
 ;
 N vsql1,vsql2
 S vsql1=$$BYTECHAR^SQLUTL(254)
 S vsql2=$G(%LIBS) I vsql2="" Q 0
 ;
 I '($D(^DBTBL(vsql2,2,SID,0,41))#2) Q 0
 Q 1
 ;
vDbEx11() ; min(1): DISTINCT LIBS,PID FROM DBTBL13 WHERE LIBS=:%LIBS AND PID=:V1
 ;
 N vsql1,vsql2
 S vsql1=$$BYTECHAR^SQLUTL(254)
 S vsql2=$G(%LIBS) I vsql2="" Q 0
 ;
 I '($D(^DBTBL(vsql2,13,V1))) Q 0
 Q 1
 ;
vDbEx2() ; min(1): DISTINCT LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS=:%LIBS AND SID=:SID AND SEQ=0 AND PSEQ=21
 ;
 N vsql1,vsql2
 S vsql1=$$BYTECHAR^SQLUTL(254)
 S vsql2=$G(%LIBS) I vsql2="" Q 0
 ;
 I '($D(^DBTBL(vsql2,2,SID,0,21))#2) Q 0
 Q 1
 ;
vDbEx3() ; min(1): DISTINCT LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS=:%LIBS AND SID=:SID AND SEQ=0 AND PSEQ=21
 ;
 N vsql1,vsql2
 S vsql1=$$BYTECHAR^SQLUTL(254)
 S vsql2=$G(%LIBS) I vsql2="" Q 0
 ;
 I '($D(^DBTBL(vsql2,2,SID,0,21))#2) Q 0
 Q 1
 ;
vDbEx4() ; min(1): DISTINCT LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS=:%LIBS AND SID=:SID AND SEQ=0 AND PSEQ=41
 ;
 N vsql1,vsql2
 S vsql1=$$BYTECHAR^SQLUTL(254)
 S vsql2=$G(%LIBS) I vsql2="" Q 0
 ;
 I '($D(^DBTBL(vsql2,2,SID,0,41))#2) Q 0
 Q 1
 ;
vDbEx5() ; min(1): DISTINCT LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS=:%LIBS AND SID=:SID AND SEQ=0 AND PSEQ=61
 ;
 N vsql1,vsql2
 S vsql1=$$BYTECHAR^SQLUTL(254)
 S vsql2=$G(%LIBS) I vsql2="" Q 0
 ;
 I '($D(^DBTBL(vsql2,2,SID,0,61))#2) Q 0
 Q 1
 ;
vDbEx6() ; min(1): DISTINCT LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS=:%LIBS AND SID=:SID AND SEQ=0 AND PSEQ=121
 ;
 N vsql1,vsql2
 S vsql1=$$BYTECHAR^SQLUTL(254)
 S vsql2=$G(%LIBS) I vsql2="" Q 0
 ;
 I '($D(^DBTBL(vsql2,2,SID,0,121))#2) Q 0
 Q 1
 ;
vDbEx7() ; min(1): DISTINCT LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS=:%LIBS AND SID=:SID AND SEQ=0 AND PSEQ=1
 ;
 N vsql1,vsql2
 S vsql1=$$BYTECHAR^SQLUTL(254)
 S vsql2=$G(%LIBS) I vsql2="" Q 0
 ;
 I '($D(^DBTBL(vsql2,2,SID,0,1))#2) Q 0
 Q 1
 ;
vDbEx8() ; min(1): DISTINCT LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS=:%LIBS AND SID=:SID AND SEQ=0 AND PSEQ=41
 ;
 N vsql1,vsql2
 S vsql1=$$BYTECHAR^SQLUTL(254)
 S vsql2=$G(%LIBS) I vsql2="" Q 0
 ;
 I '($D(^DBTBL(vsql2,2,SID,0,41))#2) Q 0
 Q 1
 ;
vDbEx9() ; min(1): DISTINCT LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS=:%LIBS AND SID=:SID AND SEQ=0 AND PSEQ=21
 ;
 N vsql1,vsql2
 S vsql1=$$BYTECHAR^SQLUTL(254)
 S vsql2=$G(%LIBS) I vsql2="" Q 0
 ;
 I '($D(^DBTBL(vsql2,2,SID,0,21))#2) Q 0
 Q 1
 ;
vOpen1() ; LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS='SYSDEV' AND SID=:SID AND SEQ=0 AND PSEQ BETWEEN 69.999 AND 80.999
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(SID) I vos3="" G vL1a0
 S vos4=69.999
 I $D(^DBTBL("SYSDEV",2,vos3,0,vos4)),'(vos4>80.999) G vL1a6
vL1a5 S vos4=$O(^DBTBL("SYSDEV",2,vos3,0,vos4),1) I vos4=""!(vos4>80.999) G vL1a0
vL1a6 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a5
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds="" Q 0
 ;
 S ds="SYSDEV"_$C(9)_vos3_$C(9)_0_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen2() ; LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS='SYSDEV' AND SID=:SID AND SEQ=0 AND PSEQ BETWEEN 120.999 AND 140.999
 ;
 ;
 S vos5=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos5=0 Q
vL2a1 S vos6=$$BYTECHAR^SQLUTL(254)
 S vos7=$G(SID) I vos7="" G vL2a0
 S vos8=120.999
 I $D(^DBTBL("SYSDEV",2,vos7,0,vos8)),'(vos8>140.999) G vL2a6
vL2a5 S vos8=$O(^DBTBL("SYSDEV",2,vos7,0,vos8),1) I vos8=""!(vos8>140.999) G vL2a0
vL2a6 Q
 ;
vFetch2() ;
 ;
 ;
 I vos5=1 D vL2a5
 I vos5=2 S vos5=1
 ;
 I vos5=0 S rs1="" Q 0
 ;
 S rs1="SYSDEV"_$C(9)_vos7_$C(9)_0_$C(9)_$S(vos8=vos6:"",1:vos8)
 ;
 Q 1
 ;
vOpen3() ; LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS='SYSDEV' AND SID=:SID AND SEQ=0 AND PSEQ BETWEEN 80.999 AND 100.999
 ;
 ;
 S vos9=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos9=0 Q
vL3a1 S vos10=$$BYTECHAR^SQLUTL(254)
 S vos11=$G(SID) I vos11="" G vL3a0
 S vos12=80.999
 I $D(^DBTBL("SYSDEV",2,vos11,0,vos12)),'(vos12>100.999) G vL3a6
vL3a5 S vos12=$O(^DBTBL("SYSDEV",2,vos11,0,vos12),1) I vos12=""!(vos12>100.999) G vL3a0
vL3a6 Q
 ;
vFetch3() ;
 ;
 ;
 I vos9=1 D vL3a5
 I vos9=2 S vos9=1
 ;
 I vos9=0 S rs2="" Q 0
 ;
 S rs2="SYSDEV"_$C(9)_vos11_$C(9)_0_$C(9)_$S(vos12=vos10:"",1:vos12)
 ;
 Q 1
 ;
vOpen4() ; LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS='SYSDEV' AND SID=:SID AND SEQ=0 AND PSEQ BETWEEN 41 AND 60
 ;
 ;
 S vos13=2
 D vL4a1
 Q ""
 ;
vL4a0 S vos13=0 Q
vL4a1 S vos14=$$BYTECHAR^SQLUTL(254)
 S vos15=$G(SID) I vos15="" G vL4a0
 S vos16=41
 I $D(^DBTBL("SYSDEV",2,vos15,0,vos16)),'(vos16>60) G vL4a6
vL4a5 S vos16=$O(^DBTBL("SYSDEV",2,vos15,0,vos16),1) I vos16=""!(vos16>60) G vL4a0
vL4a6 Q
 ;
vFetch4() ;
 ;
 ;
 I vos13=1 D vL4a5
 I vos13=2 S vos13=1
 ;
 I vos13=0 S pproc="" Q 0
 ;
 S pproc="SYSDEV"_$C(9)_vos15_$C(9)_0_$C(9)_$S(vos16=vos14:"",1:vos16)
 ;
 Q 1
 ;
vOpen5() ; LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS='SYSDEV' AND SID=:SID AND SEQ=0 AND PSEQ BETWEEN :X AND :X2
 ;
 ;
 S vos1=2
 D vL5a1
 Q ""
 ;
vL5a0 S vos1=0 Q
vL5a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(SID) I vos3="" G vL5a0
 S vos4=$G(X)
 S vos5=$G(X2)
 S vos6=vos4
 I $D(^DBTBL("SYSDEV",2,vos3,0,vos6)),'(vos6>vos5) G vL5a8
vL5a7 S vos6=$O(^DBTBL("SYSDEV",2,vos3,0,vos6),1) I vos6=""!(vos6>vos5) G vL5a0
vL5a8 Q
 ;
vFetch5() ;
 ;
 ;
 I vos1=1 D vL5a7
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs="SYSDEV"_$C(9)_vos3_$C(9)_0_$C(9)_$S(vos6=vos2:"",1:vos6)
 ;
 Q 1
 ;
vOpen6() ; LIBS,PID,SEQ FROM DBTBL13D WHERE LIBS='SYSDEV' AND PID=:V2 AND SEQ>0
 ;
 ;
 S vos1=2
 D vL6a1
 Q ""
 ;
vL6a0 S vos1=0 Q
vL6a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V2) I vos3="" G vL6a0
 S vos4=0
vL6a4 S vos4=$O(^DBTBL("SYSDEV",13,vos3,vos4),1) I vos4="" G vL6a0
 Q
 ;
vFetch6() ;
 ;
 ;
 I vos1=1 D vL6a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds="" Q 0
 ;
 S ds="SYSDEV"_$C(9)_vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
