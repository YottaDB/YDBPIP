 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UTLREAD ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
UTLREAD ; 
 ;
 S %OSAVE=+$get(%O) S %O=0 D START Q 
 ;
 ;--------------------------------------------------------------------
INQ ; Inquiry mode
 ;--------------------------------------------------------------------
 ;
 S %OSAVE=$get(%O) S %O=$S($get(%O)=4:4,1:2)
 D START Q 
 ;
 ;--------------------------------------------------------------------
DEL ; Delete mode
 ;--------------------------------------------------------------------
 ;
 S %OSAVE=$get(%O) S %O=3
 ;
 D START
 Q 
 ;
START ; 
 ;
 I '$D(%READ) Q 
 ;
 N vdes N vdl N vdxprmt N vexpr N vl N vnam
 N valu N vctprmt N vcx N vcy N vdec N vlen N vlm N vmax N vmin N VSIZ
 N vlvn N vnum N vod N vop N vprot N vptn N vptr N vrepeat N vreq N vsec
 N parmlist N vm N VPGM N vrm N vtbl N vtyp N vxpp N vxpr
 N %MAX N %VERSN N I N N N PFID N REQ N V N VO N vofl N x N z N Z
 N %IPMODE N KVAR
 ;
 S VPGM="UTLREAD"
 ;
 K VSCRPP
 ;
 I '$D(DFID) S DFID=""
 I $D(%CTPRMT) S vctprmt=0 S vdxprmt=$piece(%CTPRMT,"|",2) S:'vdxprmt vdxprmt=(80\%CTPRMT)
 ;
 ; I18N=OFF
 I $D(%BLK) S %IPMODE="NOINT:ORDER %BLK/DELIM="_$ZASCII(%BLK,2)
 I   S %BLK=$E(%BLK,3,9999) I '$D(%OPMODE) N %OPMODE S %OPMODE="NOOUTPUT"
 ;
 I '$D(OLNTB) S OLNTB=30
 I (OLNTB#1000)=0 S OLNTB=OLNTB+30 ; Default to column 30
 ;
 S vdl="," S vm=0 ; Default delimiter, high mark
 S (vop,vptr)=0
 ;
 I '$D(%FRAME) S vrm=80 S vlm=1
 E  S vrm=79 S vlm=2
 ;
 I $E(%READ,1)'?1A,""",.<@%["'[$E(%READ,1) S vdl=$E(%READ,1) S %READ=$E(%READ,2,999)
 ;
 S vod=$$vod(%READ,vdl) ; Data pointer
 ;
 S PFID=DFID S KVAR=",%VERSN" S %MAX=1
 S vcy=OLNTB\1000 S ER=0
 S VO(0)=vcy+1 ; Clear from position
 ;
 I $get(%FRAME) S vcy=vcy+1 ; Add one line
 ;
 S vptr=0
 F vnum=1:1 S vexpr=$$NPC(%READ,.vptr,vdl) D  Q:'vptr!ER 
 .	I $get(%OPMODE)["PB",$get(%IPMODE)["NOINT",$$IO($piece(vexpr,"/",1)) S IO=$I S vexpr=""
 .	D BUILD(vexpr,vnum)
 .	Q 
 I ER S VFMQ="Q" D END Q 
 ;
 S VO=vod_"|"_(vop+1)_"|"_(OLNTB\1000)_"|"_vcy_"|"_$get(%FRAME)
 S %VERSN=4 S PGM="UTLREAD" S OLNTB=((vcy+$D(%FRAME))*1000)+vcx S %MAX=%MAX-1
 I '(KVAR="") S KVAR="K "_$E(KVAR,2,999)
 ;
 D ^DBSPNT() ; Output form and data
 ;
 I '($get(RM)="") WRITE $$MSG^%TRMVT(RM)
 ;
 D ^DBSCRT8 ; Input manager
 D END
 Q 
 ;
 ;----------------------------------------------------------------------
BUILD(P,vnum) ; Build screen by parsing %TAB or [FID]DI syntax
 ;----------------------------------------------------------------------
 ;
 N I N ptr
 N ZDI
 ;
 I (P="") S vcy=vcy+1 S vop=vop+1 S vctprmt=0 S VO(vop)="" Q 
 ;
 I $E(P,1,2)="<<" S P=$E(P,3,$L(P)-2)
 I """@"[$E(P,1) D TEXTONLY Q  ; Text string
 ;
 S ptr=0 S vsiz=0 S vsec=0 S vprot=0 S vrepeat=1 S parmlist="" S y=0
 ;
 F  S y=$F(P,"#",y) Q:y=0  I $L($E(P,1,y-2),"""")#2,P'["/TB" D DECOD($E(P,y,1048575)) S P=$E(P,1,y-2)
 F  S y=$F(P,"*",y) Q:y=0  I $L($E(P,1,y-2),"""")#2 S vrepeat=+$E(P,y,1048575) S P=$E(P,1,y-2)
 ;
 I P["/" S parmlist=$piece(P,"/",2,999) S P=$piece(P,"/",1)
 S vlvn=P S vpos="" S X=""
 ;
 I P'="",$D(%TAB(P)) D  I ER Q 
 .	N y
 .	;
 .	S X=%TAB(P) I $E(X,1)="|" Q  ; Old Syntax ||
 .	S y=$piece(X,"/",2,99) S P=$piece(X,"/",1) S X=""
 .	I y'="" S parmlist=y_"/"_parmlist
 .	Q 
 ;
 I $E(P,1)="." D  ; ^STBL("PROMPT"
 .	S P=$E(P,2,1048575)
 .	I vlvn="" S vlvn=P
 .	;
 .	I '($D(^STBL("PROMPT",P))#2) D  Q 
 ..		N rs,vos1,vos2,vos3 S rs=$$vOpen1()
 ..  I $$vFetch1() S parmlist=rs_P_"/"_parmlist
 ..  Q 
 .	N rs,vos4,vos5,vos6,vos7 S rs=$$vOpen2()
 . I $$vFetch2() S parmlist=rs_"/"_parmlist
 . Q 
 ;
 I $E(P,1)="[",P?1E.E1"]".E D  Q:$get(ER)  ; [FID]DI syntax
 .	S ZDI=$$DI^DBSDD(.P,"",.vdd)
 .	S X=$piece(ZDI,"|",1,15) Q:ER 
 .	S vlvn=$piece(P,".",3) ; Local Variable
 .	S $piece(X,"|",4)="["_$piece(P,".",2)_"]"_vlvn ; Help
 .	Q 
 ;
 I $D(%RECORD) S vlvn=%RECORD S vpos=vnum ; Local Variable
 ;
 I '(parmlist="") D MODPARM(parmlist)
 ;
 S vlen=$piece(X,"|",2) ; Field length
 S vnam=$piece(X,"|",4) ; Help table
 S vtbl=$piece(X,"|",5) ; Table lookup
 S vptn=$piece(X,"|",6) ; Pattern
 S vxpp=$piece(X,"|",7) ; Post Processor
 S vxpr=$piece(X,"|",8) ; Pre Processor
 S vtyp=$piece(X,"|",9) ; Data type
 S vdes=$piece(X,"|",10) ; Prompt
 S vmin=$piece(X,"|",12) ; Minimum range
 S vmax=$piece(X,"|",13) ; Maximum range
 S vdec=$piece(X,"|",14) ; Decimal Prec
 S vreq=$piece(X,"|",15) ; Required
 I $piece(X,"|",21) S vpos=$piece(X,"|",21) ; Field Position
 ;
 ; Default attributes
 I (vtyp="") S vtyp="T"
 I $E(vptn,1)="X" S vptn="I "_vptn
 I vlen="" S vlen=$S("N$"[vtyp:12,"DC"[vtyp:10,vtyp="L":1,1:255)
 ;
 I 'vsiz S vsiz=vlen
 I vdes'="" S vdes=vdes_":"
 I vreq,vdes'="",$E(vdes,1)'=" " S vdes=" "_vdes ;    Pad for reverse video
 ;
 I ","_KVAR_","'[(","_vlvn_",") S KVAR=KVAR_","_vlvn
 ;
 I vrepeat<2 D BLDVO(0) Q 
 S I=0
 F I=1:1:vrepeat D BLDVO(I)
 Q 
 ;
 ;----------------------------------------------------------------------
BLDVO(vrepeat) ; Build VO(array) and %TAB(array)
 ;----------------------------------------------------------------------
 ;
 N vlvn1
 ;
 ; Get cursor address
 D GETCA()
 ;
 I vrepeat S vlvn=$piece(vlvn,"(",1)_"("_vrepeat_")" ; Subscript
 S valu=$get(@vlvn) ; Default value
 I vpos S valu=$piece(valu,"|",vpos) ; Position
 I valu="",$D(%DUP(vlvn)) S valu=%DUP(vlvn) ; Save Buffer
 I vtyp="L",valu="" S valu=0 ; Logical default to N
 ;
 I vpos D
 .	S vlvn1=@vlvn
 .	S $piece(vlvn1,"|",vpos)=valu
 .	S @vlvn=vlvn1
 .	Q 
 E  S @vlvn=valu
 ;
 I valu="" S V=""
 E  S V=$$EXT^%ZM(valu,vtyp,vdec) S:"$N"[vtyp V=$J(V,vlen)
 ;
 S N=vcx-vl I N=1,$D(%FRAME) S N=2
 S vop=vop+1 S VO(vop)=$ZCHAR(vcy)_$ZCHAR(N)_$ZCHAR(vl)_$ZCHAR(vreq)_"00000001T"_vdes
 ;
 I vl S vcx=vcx+1
 S vm=vcx+vsiz S vl=vsiz
 I vm>vrm S vl=vrm-vcx-$D(%FRAME)
 ;
 S vod=vod+1
 S VO(vod)=$ZCHAR(vcy)_$ZCHAR(vcx)_$ZCHAR(vl)_$ZCHAR(0)_"00000000"_vtyp_$S(vsec:"",1:V)
 ;
 I vpos S vpos=124_vpos ; Force Delimiter
 S %TAB(%MAX)=$ZCHAR((vcy-1))_$ZCHAR((vcx-1))_$ZCHAR(vl)_$S($get(vprot):2,1:vsec)_+vreq_vtyp_vpos_"|*"_vlvn_"|"_$S(vnam="":"[*]@"_vlvn,1:vnam)_"|"_vtbl_"|"_vptn_"|"_vxpp_"|"_vxpr_"|"_vmin_"|"_vmax_"|"_vdec_"||"_vlen
 S %MAX=%MAX+1
 Q 
 ;
 ; I18N=ON
VREPRNT ; 
 D VDA D ^DBSPNT()
 Q 
 ;
 ;----------------------------------------------------------------------
GETCA() ; Return right justified cursor address
 ;----------------------------------------------------------------------
 ;
 S vl=$L(vdes)
 S vcy=vcy+1 S vcx=OLNTB#1000 ; Y,X Coordinates
 I vl>vcx S vcx=vl+2 ; Prompt is too long
 ;
 I '$D(%CTPRMT) S:'vl&(vcx+vlen>vrm) vcx=vrm-vlen S:vcx<vlm vcx=vlm Q 
 S vctprmt=vctprmt+1
 I vctprmt>%CTPRMT S vctprmt=1 Q 
 I vctprmt'=1 S vcx=((vctprmt-1)*vdxprmt)+vcx S vcy=vcy-1
 I (vm<(vcx-vl))!(%MAX=1) Q 
 ;
 S tab=%MAX-1 S z=%TAB(tab) S vm=0
 ;
 I ($ascii(z,1)+1)'=vcy Q  ; Not on the same line
 S vlen=$get(vofl(tab)) I vlen="" S vlen=$ascii(z,3)
 S V=$E(VO(vod),14,999)
 ;
 S vlen=vcx-vl-$ascii(z,2)-2
 S %TAB(tab)=$E(z,1,2)_$ZCHAR(vlen)_$E(z,4,999)
 S VO(vod)=$E(VO(vod),1,2)_$ZCHAR(vlen)_$E(VO(vod),4,999)
 Q 
 ;
 ;----------------------------------------------------------------------
TEXTONLY ; Message (Protected field)
 ;----------------------------------------------------------------------
 ;
 N I N L N vcen N vreq N x N y N Z N Z1
 N P1
 ;
 S vreq=0 S vcen=0
 S P1="||REV|INC|CEN"
 I P["#" S vreq=$E($piece(P,"#",2),1) S P=$piece(P,"#",1)
 I P["/" D  Q:$get(ER)  S P=$piece(P,"/",1)
 .	S L=$L(P,"/")
 .	F I=2:1:L D  Q:$get(ER) 
 ..		S Z1=$piece(P,"/",I)
 ..		S Z=$L($piece(P1,"|"_Z1,1),"|")
 ..		;
 ..		; Invalid qualifier /~p1
 ..		I Z>4 S ER=1 S RM=$$^MSG("1430",Z1) Q 
 ..		I Z=4 S vcen=1 Q 
 ..		S vreq=Z-1
 ..		Q 
 .	Q 
 ;
 I $E(P,1)="@" S P=$E(P,2,99) I $E(P,1,4)="@%FN" D
 .	;
 .	; Format standard heading
 .	I ($get(%FN)="") S P="" ; blank banner
 .	E  D
 ..		N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen3()
 ..  I $$vFetch3() S P=rs
 ..  Q 
 .	S P=$char(34)_P_$char(34)
 .	S (vcen,vreq)=1
 .	Q 
 ;
 I $E(P,1)="""" S P=$E(P,2,$L(P)-1) ; String constant
 E  S P=@P
 ;
 S P=$J("",(80-$L(P))\2)_P S P=P_$J("",80-$L(P))
 ;
 S vcy=vcy+1 S vcx=OLNTB#1000 ; Cursor position
 S z=28 I $L(P)>48 S z=vcx-1 ; Length > 48, left justify
 ;
 I '$D(%CTPRMT) S vctprmt=0 ; Multiple prompts/line
 E  D
 .	I z=28 S z=0 ; Calculate new cursor position
 .	S vctprmt=vctprmt+1 I vctprmt>%CTPRMT S vctprmt=1
 .	I vctprmt'=1 S vcx=((vctprmt-1)*vdxprmt)+vcx S vcy=vcy-1
 .	I vcx+$L(P)+vdxprmt>80 S vctprmt=0
 .	Q 
 ;
 I vnum=1,$get(%FRAME)=2 S P=$E(P,1,80) S y=vcy-1 S x=1
 E  S P=$E(P,1,vrm-vlm+1) S y=vcy S x=vcx-z I $D(%FRAME) S x=x+1
 ;
 S vop=vop+1 S VO(vop)=$ZCHAR(y)_$ZCHAR(x)_$ZCHAR($L(P))_$ZCHAR(vreq)_"00000001T"_P
 Q 
 ;
 ;----------------------------------------------------------------------
DECOD(z) ; Decode procedures defined after # (P2 = req, P3 = mode (S=secret)
 ;----------------------------------------------------------------------
 ;
 S parmlist=parmlist_$S($E(z,1):"/REQ",1:"/NOREQ")
 S vsec=$E($piece(z,"#",2),1)="S" ; Secret mode
 S vprot=$E($piece(z,"#",2),1)="P" ; Protected
 Q 
 ;
 ;----------------------------------------------------------------------
vod(X,D) ; Return the starting address for data
 ;----------------------------------------------------------------------
 N y
 ;
 S vod=1 S y=0
 F  S y=$F(X,D,y) Q:'y  I $L($E(X,1,y-2),"""")#2 S vod=vod+1
 F  S y=$F(X,"*",y) Q:'y  I $L($E(X,1,y-2),"""")#2 S vod=vod+$E(X,y,1048575)-1
 Q vod
 ;
 ;----------------------------------------------------------------------
VDA ; Refresh data in VO(array) for screen redraw
 ;----------------------------------------------------------------------
 ;
 N I N V N Y
 N X
 ;
 S I=+VO S Y=1
 F I=1:1:VO I '$E(VO(I),12),'(VO(I)="") D VDA1 ; data
 Q 
 ;
VDA1 ; 
 N TMP
 ;
 S X=%TAB(Y)
 ;
 ; Suppress Option (secret mode) #S (v4.2)
 I $E(X,4)=1 S V=""
 E  D
 .	S TMP=$E($piece(X,"|",2),2,999)
 .	S V=$get(@TMP)
 .	;
 .	I $E(X,10,11),($E(X,7)'="|") S V=$piece(V,"|",$E(X,10,11))
 .	I ('(V=""))!($E(X,6)="L") S V=$$EXT^%ZM(V,$E(X,6),$piece(X,"|",10))
 .	Q 
 S VO(I)=$E(VO(I),1,13)_V S Y=Y+1
 Q 
 ;
 ;----------------------------------------------------------------------
MODPARM(parmlist) ; Modify table parameters
 ;----------------------------------------------------------------------
 ;
 N neg N ptr
 N VAR2 N expr N qfy N v N Z
 ;
 I $E(parmlist,1)="/" S parmlist=$E(parmlist,2,1048575)
 S VAR2="||LEN||HLP|TBL|PAT|XPP|XPR|TYP|DES||MIN|MAX|DEC|REQ|PROT|SEC|REP|SIZ|VAR|POS"
 ;
 S ptr=0
 F  S expr=$$NPC(parmlist,.ptr,"/") D  I 'ptr!ER Q 
 .	;
 .	S v=$piece(expr,"=",2,999) S qfy=$piece(expr,"=",1) I qfy="" Q 
 .	I $E(v,1)="""" S v=$$SUBQWT(v)
 .	;
 .	I $E(qfy,1,2)="NO" S qfy=$E(qfy,3,999) S v="" S neg=1
 .	S Z=$L($piece(VAR2,"|"_qfy,1),"|")
 .	;
 .	; Invalid Qualifier ~p1
 .	I Z=22 S ER=1 S RM=$$^MSG("1430",qfy) Q 
 .	;
 .	I Z<15!(Z=21) S $piece(X,"|",Z)=v Q 
 .	I Z=15 S $piece(X,"|",15)='$get(neg) Q 
 .	I Z=16 S vprot='$get(neg) Q  ; /PRO   Protected
 .	I Z=17 S vsec='$get(neg) Q  ; /SEC   Secret Mode
 .	I Z=18 S vrepeat=v D PUSH(v-1) ; /REP   Repeat Group
 .	I Z=20 S vlvn=v Q  ; /VAR   Variable name
 .	I Z=19,v S vsiz=v ; /SIZ   Field Size
 .	Q 
 ;
 Q 
 ;
PUSH(v) ; Push Data Structure v elements out
 ;
 N z
 ;
 S vod=vod+v
 S z=""
 F  S z=$order(VO(z),-1) Q:(z'>vop)  S VO(z+v)=VO(z)
 Q 
 ;
END ; 
 ;
 S DFID=PFID S %O=%OSAVE
 K OLNTB,%OSAVE,%CTPRMT,%VPP,%VPRE,%FRAME,%TAB
 Q 
 ;
 ;-----------------------------------------------------------------------
BANNER(FN,SIZE) ; Public // Function Description
 ;
 N X
 ;
 I ($get(FN)="") Q ""
 I ($get(SIZE)="") S SIZE=80
 ;
 N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen4()
 I $$vFetch4() S X=rs
 ;
 S X=$J("",(SIZE-$L(X))\2)_X
 Q X_$J("",SIZE-$L(X))
 ;
 ;----------------------------------------------------------------------
SUBQWT(v) ; Remove a layer of qoutes from a string
 ;----------------------------------------------------------------------
 ;
 N y
 ;
 I ($E(v,1)="""") S v=$E(v,2,1048575)
 I ($E(v,$L(v))="""") S v=$E(v,1,$L(v)-1)
 S y=0
 ;
 F  S y=$F(v,"""",y) Q:'y  S v=$E(v,1,y-2)_$E(v,y,1048575)
 Q v
 ;
 ;----------------------------------------------------------------------
NPC(v,ptr,del) ; private// Return Next Unquoted Piece (Use new utility %ZS)
 ;----------------------------------------------------------------------
 ;
 N y
 ;
 I $get(del)="" S del=","
 ;
 S y=$F(v,del,ptr)
 I y=0 S v=$E(v,ptr,1048575) S ptr=0 Q v
 I $L($E(v,ptr,y-1),"""")#2 S v=$E(v,ptr,y-2) S ptr=y Q v
 F  S y=$F(v,del,y) Q:'y  I $L($E(v,ptr,y-1),"""")#2 Q 
 S v=$E(v,ptr,$S(y:y-2,1:$L(v))) S ptr=y
 Q v
 ;
 ;----------------------------------------------------------------------
IO(prompt) ; Private//Is prompt for output device?
 ;----------------------------------------------------------------------
 ;
 I "|IO|IO1|IO2|IO3|IO4|"[("|"_prompt_"|") Q 1
 Q 0
 ;
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60764^48607^Sudanthiran S. Kumar^20279" ; Signature - LTD^TIME^USER^SIZE
 ;
vOpen1() ; PROMPT FROM STBLPROMPT WHERE PROMPTID='MISSING'
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 I '($D(^STBL("PROMPT","MISSING"))#2) G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos1=100
 S vos3=$G(^STBL("PROMPT","MISSING"))
 S rs=$P(vos3,"|",1)
 S vos1=0
 ;
 Q 1
 ;
vOpen2() ; PROMPT FROM STBLPROMPT WHERE PROMPTID=:P
 ;
 ;
 S vos4=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos4=0 Q
vL2a1 S vos5=$$BYTECHAR^SQLUTL(254)
 S vos6=$G(P) I vos6="" G vL2a0
 I '($D(^STBL("PROMPT",vos6))#2) G vL2a0
 Q
 ;
vFetch2() ;
 ;
 ;
 ;
 I vos4=0 S rs="" Q 0
 ;
 S vos4=100
 S vos7=$G(^STBL("PROMPT",vos6))
 S rs=$P(vos7,"|",1)
 S vos4=0
 ;
 Q 1
 ;
vOpen3() ; DESC FROM SCATBL WHERE FN=:%FN
 ;
 ;
 S vos1=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos1=0 Q
vL3a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(%FN) I vos3="" G vL3a0
 I '($D(^SCATBL(1,vos3))#2) G vL3a0
 Q
 ;
vFetch3() ;
 ;
 ;
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos1=100
 S vos4=$G(^SCATBL(1,vos3))
 S rs=$P(vos4,"|",1)
 S vos1=0
 ;
 Q 1
 ;
vOpen4() ; DESC FROM SCATBL WHERE FN=:FN
 ;
 ;
 S vos1=2
 D vL4a1
 Q ""
 ;
vL4a0 S vos1=0 Q
vL4a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(FN) I vos3="" G vL4a0
 I '($D(^SCATBL(1,vos3))#2) G vL4a0
 Q
 ;
vFetch4() ;
 ;
 ;
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos1=100
 S vos4=$G(^SCATBL(1,vos3))
 S rs=$P(vos4,"|",1)
 S vos1=0
 ;
 Q 1
