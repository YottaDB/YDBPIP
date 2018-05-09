 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSTBL ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSTBL(vREF,vSTR,vFMT,vMIN,vMAX,vPT,vPB,vHLP,vHDG,vUFK) ; 
 ;
 ; I18N=OFF
 ;
 N vINFO N value
 ;
 I (vREF="") Q ""
 ;
 ; Change data item with date format type <<**>> to D
 I ($get(vFMT)="T"),($get(I(5))["D EXT^DBSQRY"),($E($get(I(1)),1,3)="*QI") S vFMT=$$TYP^DBSDD(I(2))
 ;
 I ($get(vFMT)="") S vFMT="T" ; Default value
 ;
 I +$get(vPT)=0 D
 .	I ($D(OLNTB)#2) S vPT=(OLNTB\1000)+1
 .	E  S vPT=10
 .	Q 
 I vPT>16 S vPT=10
 ;
 I +$get(vPB)=0 S vPB=23
 ;
 S vINFO("STR")=$get(vSTR)
 S vINFO("FMT")=vFMT
 S vINFO("MIN")=$get(vMIN)
 S vINFO("MAX")=$get(vMAX)
 S vINFO("HLP")=$get(vHLP)
 S vINFO("UFK")=$get(vUFK)
 ;
 I '($get(vHDG)="") S vINFO("HDG")=vHDG
 E  S vINFO("HDG")=$get(vhdg)
 ;
 S value=$$MAIN(vREF,.vINFO,vPT,vPB)
 ;
 Q value
 ;
MAIN(vREF,vINFO,vPT,vPB) ; Page bottom
 ;
  S ER=0
 ;
 N visDone
 N vreccnt N vredisp N vkeylen
 N vFROM N vORDERBY N vSELECT N value N vSTR N vWHERE
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ;
 S vreccnt=0
 S value=""
 S vSTR=vINFO("STR")
 ;
 I ($order(%fkey(""))="") D
 .	D ZBINIT^%TRMVT(.%fkey)
 .	S %fkey="SEL"
 .	Q 
 ;
 I '($D(%O)#2) S %O=0
 ;
 D SETUP(vREF,.vINFO) I ER Q ""
 ;
 S vSELECT=$get(vINFO("SELECT"))
 S vFROM=$get(vINFO("TABLES"))
 S vWHERE=$get(vINFO("WHERE"))
 S vORDERBY=$get(vINFO("ORDERBY"))
 ;
 I vINFO("TYPE")="Array" S vINFO("V")=vINFO("START") ; Starting point
 ;
 I (%fkey="FND") D  I ($get(vINFO("FND"))="") D RESMODE Q ""
 .	S vINFO("FND")=vSTR
 .	D FND(.vINFO)
 .	Q 
 ;
 I %fkey="SEL" D
 .	S vINFO("SEL")=" if $E($P(vdata,$C(9),1),1,"_$L(vSTR)_")="
 .	I (vSTR=+vSTR) S vINFO("SEL")=vINFO("SEL")_vSTR
 .	E  S vINFO("SEL")=vINFO("SEL")_""""_vSTR_""""
 .	Q 
 ;
 S vkeylen=$piece(vINFO("COL",1),$char(9),3)
 ;
 S vINFO("CUB")=$$VIDOFF^%TRMVT_$$CUB^%TRMVT(vkeylen)
 ;
 S visDone=0
 F  D  Q:visDone 
 .	;
 .	N visDone2
 .	N voffset N vpagenum N vrdsp N vreccnt N vrecs N vrownum N vrows N vrptr N vrr
 .	N vr
 .	;
 .	N vrs,exe,sqlcur,vd,vi,vsql,vsub
 .	;
 .	;   #ACCEPT Date=11/29/04;PGM=RussellDS;CR=13258
 .	I vINFO("TYPE")="Select" S vrs=$$vOpen0(.exe,.vsql,vSELECT,vFROM,vWHERE,vORDERBY,"","/DQMODE=1",1)
 .	;
 .	S (vpagenum,vrptr)=1
 .	S (visDone2,vpagenum(1),vreccnt,vrecs,vrdsp)=0
 .	;
 .	F  D  Q:visDone2 
 ..		;
 ..		D DSP(.vrs,.vINFO,.vr)
 ..		;
 ..		I ($order(vr(""))="") D  Q 
 ...			S ER=1
 ...			; No matches found
 ...			S RM=$$^MSG(1955)
 ...			S (visDone,visDone2)=1
 ...			Q 
 ..		;
 ..		S vrownum=vpagenum(vpagenum)
 ..		S voffset=vPT-vrownum
 ..		S vrr=vrownum+vrows
 ..		S vrownum=vrownum+1
 ..		;
 ..		I %O=99 D  Q 
 ...			S %fkey="ESC"
 ...			S (visDone,visDone2)=1
 ...			Q 
 ..		;
 ..		D PICK(.vrs,.vINFO,.vr,vREF,.value)
 ..		;
 ..		I $$vStrLike(vINFO("UFK"),"%"_%fkey_"%","") S (visDone,visDone2)=1 Q 
 ..		;
 ..		I %fkey="KYB" D KYB
 ..		I %fkey="PDN" S vpagenum=vpagenum+1
 ..		E  I %fkey="PUP" S vpagenum=vpagenum-1
 ..		E  I %fkey="END" S (visDone,visDone2)=1
 ..		E  I %fkey="FND" S visDone2=1
 ..		E  S (visDone,visDone2)=1
 ..		Q 
 .	K vobj(+$G(vrs)) Q 
 ;
 S vPT=$get(vredisp)
 D RESMODE
 ;
 I (%fkey="ESC") S value=""
 ;
 I ('($get(vINFO("LIST"))="")) S value=vINFO("LIST")
 ;
 Q value
 ;
KYB ; Display keyboard menu and choose option
 ;
 N ZB
 ;
 S ZB=$$EMULATE^DBSMBAR
 I (ZB="") D
 .	S ZB=13
 .	S %fkey="ENT"
 .	Q 
 E  S %fkey=%fkey(ZB)
 ;
 Q 
 ;
DSP(vrs,vINFO,vr) ; Rows already loaded
 ;
 N vadjrows N voverflw
 N vI
 ;
 S vrdsp=vpagenum(vpagenum)
 S vrecs=vPB-vPT
 ;
 I ($get(vINFO("LISTLEN"))>0) S vrecs=vrecs-1
 ;
 D FETCH(.vrs,vrdsp,vrecs+1,.vINFO,.vr) Q:($order(vr(""))="")  ; First column
 ;
 S voverflw=$$OVERFLOW(vrdsp+1,vrecs,.vINFO,.vr)
 ;
 I 'voverflw D FETCH(.vrs,vrdsp+vrecs+1,vrecs,.vINFO,.vr) ; Second column
 ;
 ; Calculate number of vrecs to display (1up or 2up)
 S vadjrows=0
 S vrows=vrecs+1
 I 'voverflw,vrecs>1,'$$OVERFLOW(vrdsp+vrecs+1,vrecs,.vINFO,.vr) D
 .	S vrecs=vrecs*2
 .	S vadjrows=1
 .	Q 
 I ((vrdsp+vrecs)>$order(vr(""),-1)) D
 .	S vrecs=$order(vr(""),-1)-vrdsp
 .	S vrows=vrecs+1
 .	Q 
 I vadjrows S vrows=((vrecs/2)+1.5)\1
 ;
 I vpagenum>1 D
 .	D SETMODE
 .	WRITE $$CLR^%TRMVT(vPT+1,vPB+1),$$CUP^%TRMVT
 .	Q 
 I vpagenum=1 D HEADING(.vINFO)
 ;
 WRITE $$CUP^%TRMVT(1,vPT)
 ;
 F vI=1:1:(vrows-1) D DSPREC(0,.vINFO,.vr)
 ;
 I (vrecs'<vrows) D
 .	WRITE $$CUP^%TRMVT(1,vPT)
 .	F vI=1:1:(vrecs+1-vrows) D DSPREC(1,.vINFO,.vr)
 .	Q 
 ;
 I ($order(vr(vrdsp))>0) S vpagenum(vpagenum+1)=vrdsp
 ;
 I ($get(vINFO("LISTLEN"))>0) D LISTDSP(.vINFO)
 ;
 D KEYS(.vINFO)
 ;
 Q 
 ;
KEYS(vINFO) ; vINFO array
 ;
 N I
 N OPTS
 ;
 I ($get(vINFO("LISTLEN"))>0) S OPTS="INS,REM"
 E  S OPTS="HLP,FND"
 ;
 I %O<2 S OPTS=OPTS_",END|Select"
 ;
 S OPTS=OPTS_",ESC"
 ;
 I vpagenum>1 S OPTS=OPTS_",PUP"
 I $order(vpagenum(vpagenum))>0 S OPTS=OPTS_",PDN"
 ;
 I '(vINFO("UFK")="") F I=1:1:$L(vINFO("UFK"),",") I '$$vStrLike(OPTS,"%"_$piece(vINFO("UFK"),",",I)_"%","") S OPTS=OPTS_","_$piece(vINFO("UFK"),",",I)
 ;
 F I=1:1:$L(OPTS,",") S OPTS(I)=$piece(OPTS,",",I)
 ;
 WRITE $$SHOWKEY^%TRMVT(.OPTS)
 ;
 Q 
 ;
DSPREC(dispTwo,vINFO,vr) ; Rows already loaded
 ;
 N COL
 N REC
 ;
 WRITE $char(13),$char(10)
 I dispTwo WRITE $$CUF^%TRMVT(40)
 ;
 S vrdsp=vrdsp+1
 S REC=vr(vrdsp)
 ;
 ; Justify and display columns
 F COL=1:1:vINFO("COLCNT") D
 .	;
 .	N length
 .	N DISPLAY N format
 .	;
 .	S DISPLAY=$piece(REC,$char(9),COL)
 .	;
 .	S length=$piece(vINFO("COL",COL),$char(9),3)
 .	I length>0 S DISPLAY=$E(DISPLAY,1,length)
 .	;
 .	S format=$piece(vINFO("COL",COL),$char(9),2)
 .	I ((format="N")!(format="$")),'(DISPLAY="") D
 ..		WRITE $J(DISPLAY,length)
 ..		I +COL'=+vINFO("COLCNT") WRITE "  "
 ..		Q 
 .	E  D
 ..		WRITE DISPLAY
 ..		I +COL'=+vINFO("COLCNT") WRITE $$CUF^%TRMVT(length-$L(DISPLAY)+2)
 ..		Q 
 .	Q 
 ;
 Q 
 ;
OVERFLOW(ptr,num,vINFO,vr) ; Rows already loaded
 ;
 N I N length N width
 ;
 I ($L(vINFO("HDG"))>40) Q 1 ; Heading overflow
 ;
 S width=0
 F I=1:1:vINFO("COLCNT") D
 .	;
 .	S length=$piece(vINFO("COL",I),$char(9),3)
 .	S width=width+length+2
 .	I (+length=0) D
 ..		;
 ..		S width=42-width ; Maximum to fit
 ..		S num=ptr+num
 ..		I '($D(vr(num))#2) S num=$order(vr(""),-1) ; End of range
 ..		F ptr=ptr:1:num I $L($piece(vr(ptr),$char(9),I))>width S width=999 Q 
 ..		Q 
 .	Q 
 ;
 Q (width>41)
 ;
FETCH(vrs,vptr,vnum,vINFO,vr) ; Rows already loaded
 ;
 N vreof
 ;
 Q:(vrptr=0) 
 ;
 S vreof=vptr+vnum
 ;
 Q:(vreof<vrptr) 
 ;
 ; Retrieve records (from either ResultSet or Array)
 F  D  Q:((vrptr=0)!(vrptr>vreof)) 
 .	;
 .	N vbypass S vbypass=0
 .	N vI
 .	N vdata N V
 .	;
 .	I vINFO("TYPE")="Select" D
 ..		;
 ..		I $$vFetch(vrs) S vdata=vobj(vrs)
 ..		E  S vrptr=0
 ..		Q 
 .	E  D
 ..		;
 ..		S V=vINFO("V") ; Last key value
 ..		;    #ACCEPT Date=11/29/04;PGM=RussellDS;CR=13258
 ..		XECUTE "set "_vINFO("COLLATE") ; Get next key
 ..		S vINFO("V")=V ; Save key
 ..		;
 ..		I (V="") S vrptr=0
 ..		E  I '(vINFO("STOP")="") D
 ...			;
 ...			I '($D(vINFO("DESCENDING"))#2) D
 ....				I V>vINFO("STOP") S vrptr=0
 ....				Q 
 ...			E  I V<vINFO("STOP") S vrptr=0
 ...			Q 
 ..		;
 ..		I (+vrptr'=+0) D
 ...			;
 ...			S vdata=$get(@vINFO("ARRAY"))
 ...			S vdata=V_$char(9)_$piece(vdata,"|",vINFO("PIECE"))
 ...			Q 
 ..		Q 
 .	;
 .	Q:(vrptr=0) 
 .	;
 .	; Format elements of vdata
 .	F vI=1:1:vINFO("COLCNT") D
 ..		;
 ..		N dec
 ..		N fmt
 ..		;
 ..		S fmt=$piece(vINFO("COL",vI),$char(9),2)
 ..		;
 ..		I '((fmt="T")!(fmt="U")!(fmt="F")) D
 ...			;
 ...			S dec=$piece(vINFO("COL",vI),$char(9),4)
 ...			;
 ...			I (fmt="$"),(dec="") S dec=2
 ...			;
 ...			S $piece(vdata,$char(9),vI)=$$EXT^%ZM($piece(vdata,$char(9),vI),fmt,dec)
 ...			Q 
 ..		Q 
 .	;
 .	; If query defined, execute it
 .	I ('($get(vINFO("FNDX"))="")!'($get(vINFO("SEL"))="")) D
 ..		;
 ..		S vreccnt=vreccnt+1
 ..		I ((vreccnt#20)=0) D  ; Keyboard interrupt
 ...			;
 ...			N vin N zb
 ...			;
 ...			WRITE $$BTM^%TRMVT
 ...			; ~p1 of ~p2 found ... Press any key to stop
 ...			WRITE $$^MSG(3062,vrptr-1,vreccnt)
 ...			;
 ...			;     #ACCEPT Date=01/12/2008; Pgm=RussellDS; CR=27800; Group=READ,DEPRECATED
 ...			R vin#1:0
 ...			;
 ...			;     #ACCEPT Date=01/12/2008; Pgm=RussellDS; CR=27800; Group=Bypass
 ...			;*** Start of code by-passed by compiler
 ...			set zb=$ZB
 ...			;*** End of code by-passed by compiler ***
 ...			;
 ...			I ($L(vin)+$L(zb)>0) D
 ....				;
 ....				S vrptr=0
 ....				S vbypass=1
 ....				Q 
 ...			Q 
 ..		;
 ..		;    #ACCEPT Date=11/29/04;PGM=RussellDS;CR=13258
 ..		I 'vbypass,'($get(vINFO("FNDX"))="") XECUTE vINFO("FNDX") E  S vbypass=1
 ..		;
 ..		;    #ACCEPT Date=11/29/04;PGM=RussellDS;CR=13258
 ..		I 'vbypass,'($get(vINFO("SEL"))="") XECUTE vINFO("SEL") E  S vbypass=1
 ..		;
 ..		Q 
 .	;
 .	I 'vbypass D
 ..		;
 ..		S vr(vrptr)=vdata ; Add string to screen display
 ..		S vrptr=vrptr+1
 ..		Q 
 .	Q 
 ;
 Q 
 ;
PICK(vrs,vINFO,vr,vREF,value) ; Selected value  /MECH=REFNAM:W
 ;
 N visDone S visDone=0
 N vcharin
 N vchar N vfmt N vkey N vkeyfmt N vkeylen
 ;
 S vfmt=$piece(vINFO("COL",1),$char(9),2)
 S vkeylen=$piece(vINFO("COL",1),$char(9),3)
 ;
 F  D  Q:visDone 
 .	;
 .	I (vrownum<vrr) WRITE $$CUP^%TRMVT(1,voffset+vrownum)
 .	E  WRITE $$CUP^%TRMVT(41,voffset+1+vrownum-vrows)
 .	;
 .	S vkey=$piece(vr(vrownum),$char(9),1)
 .	;
 .	I ((vfmt="N")!(vfmt="$")) S vkeyfmt=$J(vkey,vkeylen)
 .	E  S vkeyfmt=$E(vkey,1,vkeylen)_$J("",vkeylen-$L($E(vkey,1,vkeylen)))
 .	;
 .	WRITE $$VIDREV^%TRMVT,vkeyfmt,vINFO("CUB") ; Display highlighted
 .	;
 .	;   #ACCEPT Date=11/29/04;PGM=RussellDS;CR=13258
 .	I ($D(%TO)'>0) S %TO=300
 .	;
 .	;   #ACCEPT Date=01/12/2008; Pgm=RussellDS; CR=27800; Group=READ,DEPRECATED
 .	R *vcharin:%TO
 .	I (vcharin<32) S vchar=""
 .	E  S vchar=$char(vcharin)
 .	;
 .	WRITE vkeyfmt
 .	D ZB^%ZREAD ; Read terminator
 .	;
 .	; Find the next occurrance of character vchar
 .	I '(vchar="") D  Q 
 ..		;
 ..		N hit S hit=0
 ..		N I
 ..		;
 ..		; See if on current page
 ..		I (vrownum<vrdsp) D  Q:hit 
 ...			;
 ...			F I=vrownum+1:1:vrdsp D  Q:hit 
 ....				I ($ZCONVERT($E(vr(I),1),"U")=vchar) S hit=1
 ....				Q 
 ...			I hit S vrownum=I
 ...			Q 
 ..		;
 ..		; Check other pages
 ..		F I=vpagenum(vpagenum)+1:1:vrownum D  Q:hit 
 ...			I ($ZCONVERT($E(vr(I),1),"U")=vchar) S hit=1
 ...			Q 
 ..		I hit S vrownum=I
 ..		Q 
 .	I $$vStrLike(vINFO("UFK"),"%"_%fkey_"%","") S visDone=1 Q 
 .	;
 .	I (%fkey="KBY") D KYB
 .	I (%fkey="CUU") D
 ..		S vrownum=vrownum-1
 ..		I (vrownum=vpagenum(vpagenum)) S vrownum=vrdsp
 ..		Q 
 .	E  I (%fkey="CUD") D
 ..		S vrownum=vrownum+1
 ..		I (vrownum>vrdsp) S vrownum=vpagenum(vpagenum)+1
 ..		Q 
 .	E  I ((%fkey="CUB")!(%fkey="CUF")) D
 ..		I (vrecs'<vrows) D
 ...			I (vrownum<vrr) S vrownum=vrownum+vrows-1
 ...			E  S vrownum=vrownum-vrows+1
 ...			Q 
 ..		I (vrownum>vrdsp) S vrownum=vrownum-vrows+1
 ..		Q 
 .	E  I (%fkey="ENT"),(%O'=2) D
 ..		S value=vkey
 ..		S visDone=1
 ..		Q 
 .	E  I (%fkey="FND") D
 ..		D FND(.vINFO)
 ..		I (%fkey'="ESC") S visDone=1
 ..		Q 
 .	E  I (%fkey="ESC") S visDone=1
 .	E  I (%fkey="PDN"),($order(vpagenum(vpagenum))>0) S visDone=1
 .	E  I (%fkey="PUP"),(vpagenum>1) S visDone=1
 .	E  I (%fkey="HLP") D
 ..		D HLP(.vrs,.vINFO,.vr,vREF)
 ..		Q 
 .	E  I (%fkey="DSP") D
 ..		D DSP(.vrs,.vINFO,.vr)
 ..		Q 
 .	E  I (%fkey="PRN") D
 ..		D PRN
 ..		Q 
 .	E  I (%fkey="INS"),($get(vINFO("LISTLEN"))>0) D
 ..		D LISTADD(vkey,.vINFO)
 ..		Q 
 .	E  I (%fkey="REM"),($get(vINFO("LISTLEN"))>0) D
 ..		D LISTREM(vkey,.vINFO)
 ..		Q 
 .	Q 
 ;
 Q 
 ;
HLP(vrs,vINFO,vr,vREF) ; Lookup reference
 ;
 ; Note that help info must now be in the form of [table] references, not global
 ;
 N CNT
 N desc N HLP N HLPTBL N key
 ;
 Q:($get(vrownum)="")  ; Invalid entry
 ;
 I '(vINFO("HLP")="") S HLPTBL=vINFO("HLP")
 E  I (vREF?1"["1E.E1"]".E) S HLPTBL=$piece($piece(vREF,"]",1),"[",2)
 E  Q  ; Invalid table ref
 ;
 S key=$get(vr(vrownum)) ; Field selected
 S desc=$piece(key,$char(9),2) ; key_TAB_desc
 S key=$piece(key,$char(9),1)
 Q:(key="")  ; Invalid
 ;
 N rs,vos1,vos2,vos3,vos4,vos5,vos6  N V1 S V1=key S rs=$$vOpen1()
 ;
 I '$G(vos1) D  Q 
 .	; Global is not defined
 .	WRITE $$MSG^%TRMVT($$^MSG(1928,key),1,1)
 .	D KEYS(.vINFO)
 .	Q 
 ;
 S HLP(1)=$piece(vINFO("COL",1),$char(9),5)_" "_key_" - "_desc
 S HLP(2)=""
 S CNT=3
 ;
 F  Q:'$$vFetch1()  D
 . S HLP(CNT)=$P(rs,$C(9),2)
 .	S CNT=CNT+1
 .	Q 
 ;
 WRITE $$CUON^%TRMVT
 ;
 D ^DBSHLP("HLP(",.vPT,.vPB) ; Access HELP utility
 ;
 WRITE $$CUOFF^%TRMVT
 ;
 I (+vPT=0) S vPT=vredisp
 I (vPT>vredisp) S vPT=vredisp ; Redisply table
 ;
 D HEADING(.vINFO) D DSP(.vrs,.vINFO,.vr)
 ;
 S voffset=vPT-vpagenum(vpagenum)
 ;
 Q 
 ;
PRN ; Print window to other device
 ;
 D RESMODE
 D ^DBSTBL1
 D SETMODE
 ;
 Q 
 ;
LISTADD(key,vINFO) ; vINFO array
 ;
 ; Maximum selections = ~p1
 I ($L(vINFO("LIST"),",")>vINFO("LISTLEN")) WRITE $$MSG^%TRMVT($$^MSG(1694,vINFO("LISTLEN")))
 E  D
 .	;
 .	; Only add if not already in list
 .	I '((","_vINFO("LIST")_",")[(","_key_",")) D
 ..		I (vINFO("LIST")="") S vINFO("LIST")=key
 ..		E  S vINFO("LIST")=vINFO("LIST")_","_key
 ..		Q 
 .	;
 .	D LISTDSP(.vINFO)
 .	Q 
 ;
 Q 
 ;
LISTREM(key,vINFO) ; vINFO array
 ;
 N I
 N NEWLIST N ELEMENT
 ;
 S NEWLIST=""
 ;
 F I=1:1:$L(vINFO("LIST"),",") D
 .	S ELEMENT=$piece(vINFO("LIST"),",",I)
 .	I (ELEMENT'=key) S NEWLIST=NEWLIST_ELEMENT_","
 .	Q 
 ;
 S vINFO("LIST")=$E(NEWLIST,1,$L(NEWLIST)-1)
 ;
 D LISTDSP(.vINFO)
 ;
 Q 
 ;
LISTDSP(vINFO) ; vINFO array
 ;
 WRITE $$MSG^%TRMVT(vINFO("LIST"),"","",1,vPB)
 ;
 Q 
 ;
HEADING(vINFO) ; vINFO array
 ;
 N vhdg
 ;
 S vhdg=$get(vINFO("HDG"))
 S vredisp=vPT
 ;
 D SETMODE
 ;
 WRITE $$LOCK^%TRMVT,$$CLR^%TRMVT(vPT,vPB+1)
 ;
 I (vhdg="") WRITE $$VIDOFF^%TRMVT,$$LINE^%TRMVT(80)
 E  D
 .	;
 .	WRITE $$VIDREV^%TRMVT
 .	;
 .	I vrecs'<vrows WRITE vhdg_$J("",40-$L(vhdg))
 .	I vrecs<vrows WRITE vhdg_$J("",80-$L(vhdg))
 .	E  WRITE vhdg_$J("",40-$L(vhdg))
 .	;
 .	WRITE $$VIDOFF^%TRMVT
 .	Q 
 ;
 Q 
 ;
VER(vREF,vSTR,vFMT) ; Data Type - TUFLDC$  /NOREQ/DFT="T"
 ;
 Q $$^DBSTBLA(vREF,vSTR,$get(vFMT))
 ;
VALUE(vREF,vSTR,vFMT) ; Data Type - TUFLDC$  /NOREQ/DFT="T"
 ;
 I ($get(vREF)="") Q ""
 I ($get(vSTR)="") Q ""
 ;
 I ($get(vFMT)="") S vFMT="T"
 ;
 Q $$VER(vREF,vSTR,vFMT)
 ;
WILDCARD(X,V) ; Variable that will contain search string
 ;
 I (X="") Q ""
 I $ascii(X)<32 Q ""
 ;
 I X?.A D
 .	S X=$ZCONVERT(X,"U")
 .	S V="$$UPPER^UCGMR("_V_")"
 .	Q 
 ;
 Q "if "_V_"["_$S(X'["""":""""_X_"""",1:$$QADD^%ZS(X,""""))
 ;
FND(vINFO) ; vINFO array
 ;
 N I N OP
 N VAR N X
 ;
 ; Find?
 S X=$$PROMPT($get(vINFO("FND")),$$^MSG(1111)) ; Find? message
 ;
 I ((%fkey="ESC")!(X="")) D  Q 
 .	I ($D(vpagenum)#2) D KEYS(.vINFO)
 .	S %fkey="ESC"
 .	Q 
 ;
 S vINFO("FND")=X
 S %fkey="FND"
 ;
 I ($get(vINFO("FND"))="") S vINFO("FNDX")="" Q 
 ;
 S vINFO("FNDX")=$$WILDCARD(vINFO("FND"),"vdata")
 ;
 ; Any_Column
 S VAR(1)=$$^MSG(299)
 ;
 F I=1:1:vINFO("COLCNT") S VAR(I+1)=$translate($piece(vINFO("COL",I),$char(9),5)," ","_")
 ;
 S OP=$$^DBSMBAR(26,"","","",.VAR)
 D SETMODE
 ;
 I (OP="") D
 .	S vINFO("FNDX")=""
 .	S %fkey="ESC"
 .	Q 
 E  D
 .	S %fkey="FND"
 .	;
 .	I (OP'=1) S vINFO("FNDX")=$piece(vINFO("FNDX"),"vdata",1)_"($P(vdata,$C(9),"_(OP-1)_"))"_$piece(vINFO("FNDX"),"vdata",2,99)
 .	Q 
 ;
 Q 
 ;
PROMPT(DEFAULT,PROMPT) ; 
 ;
 N RETURN
 ;
 D RESMODE
 ;
 WRITE $$BTM^%TRMVT,PROMPT,DEFAULT
 I '(DEFAULT="") WRITE $$CUB^%TRMVT($L(DEFAULT))
 ;
 S RETURN=$$TERM^%ZREAD(DEFAULT)
 I %fkey="ESC" S RETURN=""
 ;
 D SETMODE
 ;
 Q RETURN
 ;
SETMODE ; Set terminal settings
 ;
 ;  #ACCEPT Date=01/12/2008; Pgm=RussellDS; CR=27800; Group=BYPASS
 ;*** Start of code by-passed by compiler
 write $$CUOFF^%TRMVT
 use 0:(NOECHO:WIDTH=81:NOWRAP)
 ;*** End of code by-passed by compiler ***
 ;
 Q 
 ;
RESMODE ; Restore terminal settings
 ;
 ;  #ACCEPT Date=01/12/2008; Pgm=RussellDS; CR=27800; Group=BYPASS
 ;*** Start of code by-passed by compiler
 write $$CUON^%TRMVT
 use 0:(ECHO:WIDTH=81:NOWRAP)
 ;*** End of code by-passed by compiler ***
 ;
 Q 
 ;
SETUP(vREF,vINFO) ; Information needed to process lookup  /MECH=REFARR:RW
 ;
  S ER=0
 ;
 N vcol
 N vtype N vd
 ;
 S vREF=$$vStrTrim(vREF,0," ")
 S vtype=$E(vREF,1)
 S vcol=1
 ;
 I vINFO("FMT")="U" S vINFO("STR")=$ZCONVERT(vINFO("STR"),"U")
 ;
 I (vtype="@") D  Q:ER!(vREF="") 
 .	S ER=$$CALLBACK(.vREF,.vINFO)
 .	I 'ER,'(vREF="") S vtype=$E(vREF,1)
 .	Q 
 ;
 I (vtype=",") S ER=$$PICKLIST(vREF,.vINFO) Q 
 ;
 ; Continue to support global look-ups until all are removed
 I (vtype="^") S ER=$$ARRAY(vREF,.vINFO) Q  ; Global
 ;
 I (vtype="[") S ER=$$DINAM(vREF,.vINFO) Q  ; [FID]DI reference
 ;
 I (vREF[".") S ER=$$DINAM(vREF,.vINFO) Q  ; FID.DI
 ;
 I ((vtype?1A)!(vtype="%")) S ER=$$ARRAY(vREF,.vINFO) Q  ; Local array
 ;
 S ER=1
 S RM=$$^MSG(1396) ; Invalid look-up table syntax
 ;
 Q 
 ;
DINAM(vREF,vINFO) ; Information need to process lookup /MECH=REFARR:RW
 ;
 N distinct N ER
 N I N SEQ
 N BTMKEY N COLUMNS N HDG N LASTTBL N params N select N TABLE N TABLES N vWHERE N X
 ;
 S (distinct,ER)=0
 S (params,select)=""
 ;
 I (vREF[":") D
 .	S params=$piece(vREF,":",2,99)
 .	S vREF=$piece(vREF,":",1)
 .	Q 
 ;
 I ($E(vREF,1)="[") D
 .	S TABLE=$piece($piece(vREF,"[",2),"]",1)
 .	S COLUMNS=$piece(vREF,"]",2,999)
 .	Q 
 E  D
 .	S TABLE=$piece(vREF,".",1)
 .	S COLUMNS=$piece(vREF,".",2,999)
 .	Q 
 ;
 ; Remove library reference, if it exists
 I (TABLE[",") S TABLE=$piece(TABLE,",",2)
 ;
 S (TABLES,LASTTBL)=TABLE
 ;
 ; If only file, get default display from DBTBL1
 I (COLUMNS="") D
 .	;
 .	N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=TABLE,dbtbl1=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",TABLE,0,"")
 .	 S vop3=$G(^DBTBL(vop1,1,vop2,10))
 .	;
 .	S COLUMNS=$P(vop3,$C(124),6)
 .	I '(COLUMNS=""),'($P(vop3,$C(124),9)="") D
 ..		;
 ..		I ($E(COLUMNS,$L(COLUMNS))'=",") S COLUMNS=COLUMNS_","
 ..		S COLUMNS=COLUMNS_$P(vop3,$C(124),9)
 ..		Q 
 .	; Only use parameters from table if no other ones already
 .	I (COLUMNS[":") D
 ..		I (params="") S params=$piece(COLUMNS,":",2,999)
 ..		S COLUMNS=$piece(COLUMNS,":",1)
 ..		Q 
 .	;
 . Q 
 ;
 ; Get bottom key
 D
 .	N acckeys N fsn
 .	;
 .	D fsn^DBSDD(.fsn,TABLE)
 .	;
 .	S acckeys=$piece(fsn(TABLE),"|",3)
 .	S BTMKEY=$piece(acckeys,",",$L(acckeys,","))
 .	;
 .	S vINFO("ORDERBY")=acckeys
 .	S vINFO("BTMKEY")=BTMKEY
 .	Q 
 ;
 ; If not distinct parameter and bottom key not present, add it to the beginning
 S distinct=0
 F I=1:1:$L(params,":") I $$isCMD("DISTINCT",$piece(params,":",I)) S distinct=1
 ;
 I 'distinct D
 .	;
 .	N missing S missing=1
 .	N col
 .	;
 .	F I=1:1:$L(COLUMNS,",") D  Q:'missing 
 ..		S col=$piece($piece(COLUMNS,",",I),"/",1)
 ..		I col=BTMKEY S missing=0
 ..		Q 
 .	;
 .	I missing D
 ..		I (COLUMNS="") S COLUMNS=BTMKEY
 ..		E  S COLUMNS=BTMKEY_","_COLUMNS
 ..		Q 
 .	Q 
 ;
 I '(params="") D PARSE(params,"",.vINFO)
 ;
 S vINFO("TYPE")="Select"
 ;
 S HDG=""
 S vINFO("COLCNT")=$L(COLUMNS,",")
 F SEQ=1:1:$L(COLUMNS,",") D
 .	;
 .	N dec N len
 .	N COLPARMS N fmt N NAME N rhd N TAB N TABLEREF
 .	;
 .	S TAB=$char(9)
 .	;
 .	S NAME=$piece(COLUMNS,",",SEQ)
 .	I (NAME["/") D
 ..		S COLPARMS=$piece(NAME,"/",2,999)
 ..		S NAME=$piece(NAME,"/",1)
 ..		Q 
 .	E  S COLPARMS=""
 .	;
 .	I $$isLit^UCGM(NAME) D
 ..		S fmt="T"
 ..		S dec=""
 ..		S rhd=""
 ..		S len=$L(NAME)
 ..		S TABLEREF=""
 ..		Q 
 .	E  D
 ..		;
 ..		I ($E(NAME,1)="[") S NAME=$translate($E(NAME,2,1048575),"]",".")
 ..		;
 ..		I (NAME[".") D
 ...			S TABLEREF=$piece(NAME,".",1)
 ...			S NAME=$piece(NAME,".",2)
 ...			Q 
 ..		E  S TABLEREF=LASTTBL
 ..		;
 ..		S LASTTBL=TABLEREF
 ..		;
 ..		N dbtbl1d S dbtbl1d=$$vRCgetRecord0Opt^RecordDBTBL1D("SYSDEV",TABLEREF,NAME,0,"")
 ..		;
 ..		S fmt=$P(dbtbl1d,$C(124),9) ; Type
 ..		S dec=$P(dbtbl1d,$C(124),14) ; Decimals
 ..		S rhd=$P(dbtbl1d,$C(124),22) ; Header
 ..		S len=$P(dbtbl1d,$C(124),19) ; Length
 ..		I (+len=0) S len=$P(dbtbl1d,$C(124),2)
 ..		;
 ..		I '(COLPARMS="") D  ; Override data dictionary values
 ...			;
 ...			S COLPARMS="/"_COLPARMS
 ...			I (COLPARMS["/LE") S len=$piece($piece($piece(COLPARMS,"/LE",2),"=",2),"/",1)
 ...			I (COLPARMS["/RH") S rhd=$piece($piece($piece(COLPARMS,"/RH",2),"=",2),"/",1)
 ...			I (COLPARMS["/FM") S fmt=$piece($piece($piece(COLPARMS,"/FM",2),"=",2),"/",1)
 ...			Q 
 ..  Q 
 .	;
 .	I '((","_TABLES_",")[(","_TABLEREF_",")) S TABLES=TABLES_","_TABLEREF
 .	;
 .	I (TABLEREF="") D  ; literal
 ..		S vINFO("COL",SEQ)=NAME
 ..		S select=select_$S(NAME'["""":""""_NAME_"""",1:$$QADD^%ZS(NAME,""""))_","
 ..		Q 
 .	E  D
 ..		S vINFO("COL",SEQ)=TABLEREF_"."_NAME
 ..		S select=select_TABLEREF_"."_NAME_","
 ..		Q 
 .	;
 .	S rhd=$E(rhd,1,len) ; Truncate heading
 .	S rhd=$translate(rhd,"@"," ") ; Remove DQ line break indicator
 .	;
 .	S vINFO("COL",SEQ)=vINFO("COL",SEQ)_TAB_fmt_TAB_len_TAB_dec_TAB_rhd
 .	;
 .	; Build heading
 .	I ((fmt="$")!(fmt="N")) S HDG=HDG_$J(rhd,len)_"  " ; right
 .	E  S HDG=HDG_rhd_$J("",len-$L(rhd))_"  " ; left
 .	Q 
 ;
 I (vINFO("HDG")="") S vINFO("HDG")=$E(HDG,1,$L(HDG)-2)
 ;
 ; If distinct, Oracle does not allow items not in select list as part of sort
 I distinct D
 .	S vINFO("ORDERBY")=$E(select,1,$L(select)-1)
 .	S select="DISTINCT "_select
 .	Q 
 ;
 S vINFO("SELECT")=$E(select,1,$L(select)-1)
 S vINFO("TABLES")=TABLES
 ;
 ; Build WHERE clause
 S vWHERE=""
 I '(vINFO("STR")="") D
 .	;
 .	N MATCH N X
 .	;
 .	S X=vINFO("STR")
 .	;
 .	I 'distinct S MATCH=BTMKEY
 .	E  S MATCH=$piece($piece(select," ",2),",",1)
 .	;
 .	I %fkey="SEL" D
 ..		;
 ..		S X="'"_X_"%'"
 ..		S vWHERE=vWHERE_MATCH_" LIKE "_X
 ..		Q 
 .	Q 
 ;
 I '(vINFO("MIN")="") D
 .	;
 .	I '(vWHERE="") S vWHERE=vWHERE_" AND "
 .	;
 .	S vWHERE=vWHERE_BTMKEY_">="_vINFO("MIN")_" "
 .	Q 
 ;
 I '(vINFO("MAX")="") D
 .	;
 .	I '(vWHERE="") S vWHERE=vWHERE_" AND "
 .	;
 .	S vWHERE=vWHERE_BTMKEY_"<="_vINFO("MAX")_" "
 .	Q 
 ;
 ; Handle queries
 I '($get(vINFO("QUERY"))="") D
 .	;
 .	N I
 .	N DQQRY N XWHERE
 .	;
 .	F I=1:1:$L(vINFO("QUERY"),$char(1)) S DQQRY(I)=$piece(vINFO("QUERY"),$char(1),I)
 .	;
 .	S XWHERE=$$WHERE^SQLCONV(.DQQRY,TABLES)
 .	;
 .	I (vWHERE="") S vWHERE=XWHERE
 .	E  S vWHERE=vWHERE_" AND "_XWHERE
 .	Q 
 ;
 S vINFO("WHERE")=vWHERE
 ;
 I $D(vINFO("DESCENDING")) S vINFO("ORDERBY")=vINFO("ORDERBY")_" DESC"
 E  S vINFO("ORDERBY")=vINFO("ORDERBY")_" ASC"
 ;
 Q ER
 ;
PICKLIST(vREF,vINFO) ; Information need to process lookup  /MECH=REFARR:W
 ;
 N ER S ER=0
 N I
 N delim1 N delim2 N desc N key N params N V
 ;
 S params=""
 I (vREF[":") D
 .	N tok
 .	;
 .	S vREF=$$TOKEN^%ZS(vREF,.tok)
 .	I (vREF[":") D
 ..		S params=$piece(vREF,":",2,99)
 ..		S params=$$UNTOK^%ZS(params,tok)
 ..		S vREF=$piece(vREF,":",1)
 ..		Q 
 .	S vREF=$$UNTOK^%ZS(vREF,tok)
 .	Q 
 ;
 S delim1="," ; Default delimiters
 S delim2="#"
 ;
 I $E(vREF,2)'?1AN D  ; Alternate delimiters
 .	S delim1=$E(vREF,1)
 .	S delim2=$E(vREF,2)
 .	S vREF=$E(vREF,3,1048575)
 .	Q 
 ;
 K vlist
 ;
 F I=1:1:$L(vREF,delim1) D
 .	;
 .	S V=$piece(vREF,delim1,I)
 .	I '(V="") D
 ..		;
 ..		S key=$piece(V,delim2,1)
 ..		S desc=$piece(V,delim2,2)
 ..		S vlist(key)=desc
 ..		Q 
 .	Q 
 ;
 S vREF="vlist("
 I '(params="") S vREF=vREF_":"_params
 ;
 S ER=$$ARRAY(vREF,.vINFO)
 ;
 Q ER
 ;
CALLBACK(vREF,vINFO) ; Information need to process lookup [*] /MECH=REFARR:W
 ;
 N ER S ER=0
 N params N X N XSTRING
 ;
 I (vREF[":") D  I ER Q 1
 .	S params=$piece(vREF,":",2,99)
 .	S vREF=$piece(vREF,":",1)
 .	D PARSE(params,"DESCENDING,LIST,NOVALIDATE",.vINFO)
 .	Q 
 ;
 S X=$get(vINFO("STR")) ; Input value (may be null)
 ;
 S XSTRING="do "_$E(vREF,2,999)
 ;  #ACCEPT Date=11/29/04;PGM=RussellDS;CR=13258
 XECUTE XSTRING ; Execute the program
 ;
 Q ER
 ;
ARRAY(vREF,vINFO) ; Information need to process lookup  /MECH=REFARR:W
 ;
  ; From DATA-QWIK
 ;
 N ER S ER=0
 N vdscpce N vkeylen
 N vfmt N vTAB
 ;
 S vfmt="T"
 S vTAB=$char(9)
 ;
 I (($get(E67)>0)&($get(E67)<13)) S vkeylen=E67
 E  S vkeylen=12
 ;
 I (vREF[":") D  I ER Q 1
 .	;
 .	N vqualifs S vqualifs=$piece(vREF,":",2,99)
 .	;
 .	S vREF=$piece(vREF,":",1)
 .	D PARSE(vqualifs,"DESCENDING,LIST,NOVALIDATE",.vINFO)
 .	Q 
 ;
 I (vREF["/") D
 .	;
 .	N vparams S vparams="/"_$piece(vREF,"/",2,99)
 .	;
 .	S vREF=$piece(vREF,"/",1)
 .	;
 .	I '(vparams="") D
 ..		;
 ..		I (vparams["/LE") S vkeylen=$piece($piece($piece(vparams,"/LE",2),"=",2),"/",1)
 ..		I (vparams["/RH") S vINFO("HDG")=$piece($piece($piece(vparams,"/RH",2),"=",2),"/",1)
 ..		I (vparams["/FM") S vfmt=$piece($piece($piece(vparams,"/FM",2),"=",2),"/",1)
 ..		Q 
 .	Q 
 ;
 ; Piece of node to extract for description
 S vdscpce=1
 I (vREF["#") D
 .	S vdscpce=$piece(vREF,"#",2)
 .	S vREF=$piece(vREF,"#",1)
 .	Q 
 S vINFO("PIECE")=vdscpce
 ;
 S vREF=vREF_"V)" ; Add bottom, collating key
 ;
 S vINFO("TYPE")="Array"
 S vINFO("ARRAY")=vREF
 I ($D(vINFO("DESCENDING"))#2) D
 .	S vINFO("COLLATE")="V=$O("_vREF_",-1)"
 .	;
 .	I (vINFO("MAX")="") S vINFO("START")=""
 .	E  D
 ..		;
 ..		N V S V=vINFO("MAX")
 ..		;
 ..		;    #ACCEPT Date=11/29/04;PGM=RussellDS;CR=13258
 ..		S vINFO("START")=$order(@vREF)
 ..		Q 
 .	;
 .	S vINFO("STOP")=vINFO("MIN")
 .	Q 
 E  D
 .	S vINFO("COLLATE")="V=$O("_vREF_")"
 .	;
 .	I (vINFO("MIN")="") S vINFO("START")=""
 .	E  D
 ..		;
 ..		N V S V=vINFO("MIN")
 ..		;
 ..		S vINFO("START")=$order(@vREF,-1)
 ..		Q 
 .	;
 .	S vINFO("STOP")=vINFO("MAX")
 .	Q 
 ;
 S vINFO("COLCNT")=2
 S vINFO("COL",1)="KEY"_vTAB_vfmt_vTAB_vkeylen_vTAB_""_vTAB_"Key"
 S vINFO("COL",2)="DESCRIPTION"_vTAB_"T"_vTAB_"0"_vTAB_""_vTAB_"Description"
 ;
 Q 0
 ;
PARSE(params,VALCMDS,vINFO) ; vINFO array     /MECH=REFARR:W
 ;
 N I
 N CMDSTRING N NAME N EXPR N tok
 ;
 ; If null, use all valid commands
 I (VALCMDS="") S VALCMDS="DESCENDING,DISTINCT,LIST,NOVALIDATE,QUERY"
 ;
 S params=$$TOKEN^%ZS(params,.tok)
 ;
 F I=1:1:$L(params,":") D
 .	;
 .	S CMDSTRING=$piece(params,":",I)
 .	S NAME=$ZCONVERT($piece(CMDSTRING," ",1),"U")
 .	S EXPR=$$UNTOK^%ZS($piece(CMDSTRING," ",2,99),tok)
 .	;
 .	I $$isCMD("LIST",NAME) D
 ..		I (EXPR="") S EXPR=9999
 ..		S vINFO("LISTLEN")=EXPR
 ..		S vINFO("LIST")=""
 ..		Q 
 .	E  I $$isCMD("NOVALIDATE",NAME) S vINFO("NOVALIDATE")=""
 .	E  I $$isCMD("DESCENDING",NAME) S vINFO("DESCENDING")=""
 .	E  I $$isCMD("QUERY",NAME) D
 ..		S EXPR=$$QSUB^%ZS(EXPR,"""")
 ..		;
 ..		; If multiple queries with "," or ":" separators, replace with &
 ..		I (EXPR[",") S EXPR=$$vStrRep(EXPR,","," & ",0,0,"")
 ..		I (EXPR[":") S EXPR=$$vStrRep(EXPR,":"," & ",0,0,"")
 ..		;
 ..		I ($D(vINFO("QUERY"))#2) S vINFO("QUERY")=vINFO("QUERY")_$char(1)_EXPR
 ..		E  S vINFO("QUERY")=EXPR
 ..		Q 
 .	E  I $$isCMD("DISTINCT",NAME) ; Legal command, but already handled
 .	E  D
 ..		;
 ..		N error S error=""
 ..		;
 ..		S $P(error,",",3)="%DQ-E-INVLDTBLLOOKUP"
 ..		; Invalid command ~p1
 ..		S $P(error,",",4)=$$^MSG(1287,NAME)
 ..		S $ZE=error,$EC=",U1001,"
 ..		Q 
 .	Q 
 ;
 Q 
 ;
isCMD(CMD,TEST) ; TEST if this is the command
 ;
 I (TEST="") Q 0
 ;
 Q ($E(CMD,1,$L(TEST))=TEST)
 ;
UACN(REF,SELECT,TABLES,COLS,HDG) ; Heading   /MECH=REFNAM:W
 ;
 N I
 N vINFO
 ;
 S vINFO("STR")=""
 S vINFO("FMT")="N"
 S vINFO("MIN")=""
 S vINFO("MAX")=""
 S vINFO("HDG")=""
 S vINFO("UFK")=""
 ;
 S ER=$$DINAM(REF,.vINFO) Q:ER 
 ;
 S HDG=vINFO("HDG")
 S SELECT=vINFO("SELECT")
 S TABLES=vINFO("TABLES")
 ;
 F I=1:1:vINFO("COLCNT") S COLS(I)=vINFO("COL",I)
 ;
 Q 
 ;
LOOKUPPP(FORMAT,FILES,ARRAY) ; Converted column headings [*] /MECH=REFARR:W
 ;
  S ER=0
 ;
 N I
 N vINFO N TABLE
 ;
 S vINFO("STR")=""
 S vINFO("FMT")=""
 S vINFO("MIN")=""
 S vINFO("MAX")=""
 S vINFO("HLP")=""
 S vINFO("UFK")=""
 ;
 ;if 'vHDG.get().isNull() set vINFO("HDG") = vHDG
 ;else  set vINFO("HDG") = vhdg.get()
 ;
 S vINFO("HDG")=""
 ;
 D SETUP(FORMAT,.vINFO) Q:ER 
 ;
 I '($D(vINFO("HDG"))#2) D  Q 
 .	S ER=1
 .	; Invalid syntax
 .	S RM=$$^MSG(1475)
 .	Q 
 ;
 I $L(vINFO("HDG"))>80 D  Q 
 .	S ER=1
 .	; Field length greater than 80
 .	S RM=$$^MSG(1077)
 .	Q 
 ;
 S ARRAY(1)=vINFO("HDG")_$J("",79-$L(vINFO("HDG")))
 S ARRAY(2)="                                                                               "
 ;
 F I=1:1:$L(ARRAY(1)) I $E(ARRAY(1),I)'=" " S $E(ARRAY(2),I)="-"
 ;
 ; The first column must be the primary key of the first table
 ;
 S TABLE=$piece(FILES,",",1)
 ;
 I TABLE="CIF",$piece(vINFO("COL",1),$char(9),1)'="CIF.ACN" S ER=1 S RM="CIF.ACN"
 E  I TABLE="DEP",$piece(vINFO("COL",1),$char(9),1)'="DEP.CID" S ER=1 S RM="DEP.CID"
 E  I TABLE="LN",$piece(vINFO("COL",1),$char(9),1)'="LN.CID" S ER=1 S RM="LN.CID"
 ; First display column must be the account number ~p1
 I ER S RM=$$^MSG(1115,RM)
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61565^25470^Sha H Mirza^41454" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vStrLike(object,p1,p2) ; String.isLike
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I (p1="") Q (object="")
 I p2 S object=$ZCONVERT(object,"U") S p1=$ZCONVERT(p1,"U")
 I ($E(p1,1)="%"),($E(p1,$L(p1))="%") Q object[$E(p1,2,$L(p1)-1)
 I ($E(p1,1)="%") Q ($E(object,$L(object)-$L($E(p1,2,1048575))+1,1048575)=$E(p1,2,1048575))
 I ($E(p1,$L(p1))="%") Q ($E(object,1,$L($E(p1,1,$L(p1)-1)))=$E(p1,1,$L(p1)-1))
 Q object=p1
 ; ----------------
 ;  #OPTION ResultClass 1
vRsRowGC(vNms,vTps) ; Runtime ResultSet.getRow().getColumns()
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;
 N vL S vL="" N vN N vT N vO
 F vO=1:1:$S((vNms=""):0,1:$L(vNms,",")) D
 .	S vN=$piece(vNms,",",vO)
 .	S vT=$E(vTps,(vO-1)*2+1)
 .	I "TUF"[vT S vT="String"
 .	E  S vT=$piece("ByteString,Boolean,Date,Memo,Number,Number,Time",",",$F("BLDMN$C",vT)-1)
 .	S $piece(vL,",",v0)=vT_" "_vN
 .	Q 
 Q vL
 ; ----------------
 ;  #OPTION ResultClass 1
vStrTrim(object,p1,p2) ; String.trim
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I p1'<0 S object=$$RTCHR^%ZFUNC(object,p2)
 I p1'>0 F  Q:$E(object,1)'=p2  S object=$E(object,2,1048575)
 Q object
 ; ----------------
 ;  #OPTION ResultClass 1
vStrRep(object,p1,p2,p3,p4,qt) ; String.replace
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
 ;  #OPTION ResultClass 1
vStrFnd(object,p1,p2,p3,qt) ; String.find
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;
 I (p1="") Q $S(p2<1:1,1:+p2)
 I p3 S object=$ZCONVERT(object,"U") S p1=$ZCONVERT(p1,"U")
 S p2=$F(object,p1,p2)
 I '(qt=""),$L($E(object,1,p2-1),qt)#2=0 D
 .	F  S p2=$F(object,p1,p2) Q:p2=0!($L($E(object,1,p2-1),qt)#2) 
 .	Q 
 Q p2
 ;
vFetch(vRs) ; Runtime fetch
 ;
 N vPgm,vTag
 S vPgm=$TEXT(+0),vTag=vobj(vRs,-2)
 X "set vTag="_vTag_"(vRs)"
 Q vTag
 ;
vOpen0(exe,vsql,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist,vOff) ; Dynamic MDB ResultSet
 ;
 N vOid
 N ER,vExpr,mode,RM,vOpen,vTok S ER=0 ;=noOpti
 ;
 S vExpr="SELECT "_vSelect_" FROM "_vFrom
 I vWhere'="" S vExpr=vExpr_" WHERE "_vWhere
 I vOrderby'="" S vExpr=vExpr_" ORDER BY "_vOrderby
 I vGroupby'="" S vExpr=vExpr_" GROUP BY "_vGroupby
 S vExpr=$$UNTOK^%ZS($$SQL^%ZS(vExpr,.vTok),vTok)
 ;
 S sqlcur=$O(vobj(""),-1)+1
 ;
 I $$FLT^SQLCACHE(vExpr,vTok,.vParlist)
 E  S vOpen=$$OPEN^SQLM(.exe,vFrom,vSelect,vWhere,vOrderby,vGroupby,vParlist,,1,,sqlcur) I 'ER D SAV^SQLCACHE(vExpr,.vParlist) s vsql=vOpen
 I ER S $ZE="0,"_$ZPOS_",%PSL-E-SQLFAIL,"_$TR($G(RM),$C(10,44),$C(32,126)),$EC=",U1001,"
 ;
 S vOid=sqlcur
 S vobj(vOid,0)=vsql
 S vobj(vOid,-1)="ResultSet"
 S vobj(vOid,-2)="$$vFetch0^"_$T(+0)
 S vobj(vOid,-3)=$$RsSelList^UCDBRT(vSelect)
 S vobj(vOid,-4)=$G(vsql("D"))
 S vobj(vOid,-5)=0
 Q vOid
 ;
vFetch0(vOid) ; MDB dynamic FETCH
 ;
 ; type public String exe(),sqlcur,vd,vi,vsql()
 ;
 I vsql=0 S vobj(vOid)="" Q 0
 S vsql=$$^SQLF(.exe,.vd,.vi,.sqlcur)
 S vobj(vOid)=vd
 S vobj(vOid,0)=vsql
 S vobj(vOid,.1)=$G(vi)
 Q vsql
 ;
vOpen1() ; SEQ,DOC FROM DBTBL12 WHERE %LIBS='SYSDEV' AND FID=:HLPTBL AND CODE=:V1 ORDER BY SEQ ASC
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(HLPTBL) I vos3="" G vL1a0
 S vos4=$G(V1) I vos4="" G vL1a0
 S vos5=""
vL1a5 S vos5=$O(^DBTBL("SYSDEV",12,vos3,vos4,vos5),1) I vos5="" G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a5
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos6=$G(^DBTBL("SYSDEV",12,vos3,vos4,vos5))
 S rs=$S(vos5=vos2:"",1:vos5)_$C(9)_$P(vos6,"|",1)
 ;
 Q 1
 ;
vCatch1 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 S ER=1
 S RM=$P(error,",",3)_", "_$get(vREF)_" ("_$get(vINFO("STR"))_")"
 S value=""
 ;
 I ($P(error,",",3)["%GTM") S $ZE=error,$EC=",U1001,"
 D ZX^UCGMR(voxMrk) Q 
