 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSFILER ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSFILER ; 
 ;
 Q  ; Do not call from top
 ;
EXT(fid,%O,par) ; Parameters  /NOREQ
 ;
 ; vfkey() is public array used by SQL for buffered commits in
 ; order to perform foreign key checking at end.
 ;
 N vtp
 N vtjd
 N I
 N vpgm
 ;
 S ER=0
 ;
 I $$rdb^UCDB(fid) D  Q 
 .	;
 .	S ER=1
 .	S RM="^DBSFILER is not valid for RDB tables.  Rewrite caller to PSL using save methods."
 .	Q 
 ;
 S vpgm="Record"_fid
 ;
 ;  #ACCEPT Date=06/14/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 ;*** Start of code by-passed by compiler
 S vtp=$Tlevel    ; Is TP already on?
 ;*** End of code by-passed by compiler ***
 ;
 I 'vtp TS *:transactionid="CS"
 ;
 I (%O=2) D  ; Integrity check
 .	;
 .	N vpgmx
 .	;
 .	S vpgmx="vlegacy^"_vpgm_"(%ProcessMode,$G(par))"
 .	;
 .	D @vpgmx
 .	Q 
 E  D
 .	;
 .	N obj
 .	N vpgmx N vobj
 .	;
 .	S obj=$$SN2OBJ^UCUTIL(fid) ; Convert to object format
 .	;
 .	S vpgmx="vSave^"_vpgm_"(obj,$G(par))"
 .	;
 .	D @vpgmx ; Call filer
 .	Q 
 ;
 Q:vtp  ; Let calling routine to manage TP
 ;
 K vfkey ; Don't return if not under TP
 ;
 ;  #ACCEPT Date=06/14/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 ;*** Start of code by-passed by compiler
 I '$Tlevel S ER=1 Q  ; TP restart error?
 ;*** End of code by-passed by compiler ***
 ;
 I ER  TRO:$TL>0  Q 
 ;
  TC:$TL 
 ;
 Q 
 ;
VDDUX(fid,vx) ; Data buffer [*] /MECH=REFARR:R
 N vpc
 ;
 N col N delim N vRM
 ;
 N tblrec S tblrec=$$getPslTbl^UCXDD(fid,0)
 ;
 S delim=$char($P(tblrec,"|",10))
 ;
 S (col,vRM)=""
 ;
 F  S col=$order(vx(col)) Q:(col="")  D  Q:'(vRM="") 
 .	;
 .	N max N min N tbl N typ N X
 .	;
 .	N dbtbl1d,vop1 S vop1=col,dbtbl1d=$$vRCgetRecord0Opt^RecordDBTBL1D("SYSDEV",fid,col,0,"")
 .	;
 . S vpc=($P(dbtbl1d,$C(124),1)?1N1"*") Q:vpc  ; No need to check keys
 .	;
 .	S tbl=$P(dbtbl1d,$C(124),5)
 .	;
 .	I '(tbl="") D  ; Table look-up
 ..		;
 ..		N I N keycnt
 ..		N acckeys N tblfid
 ..		;
 ..		; No validation
 ..		I ($E(tbl,1)="@") S tbl="" Q 
 ..		;
 ..		; No validation
 ..		I (tbl[":NOVAL") S tbl="" Q 
 ..		;
 ..		; Not table reference
 ..		I (tbl'?1"[".E1"]".E) S tbl="" Q 
 ..		;
 ..		; Check for too many keys
 ..		S tblfid=$piece($piece(tbl,"[",2),"]",1)
 ..		;
 ..		N dbtbl1,vop2,vop3,vop4,vop5 S vop2="SYSDEV",vop3=tblfid,dbtbl1=$$vRCgetRecord1Opt^RecordDBTBL1("SYSDEV",tblfid,0,.vop4)
 ..		 S vop5=$G(^DBTBL(vop2,1,vop3,16))
 ..		;
 ..		; Not valid table
 ..  I ($G(vop4)=0) S tbl="" Q 
 ..		;
 ..		S acckeys=$P(vop5,$C(124),1)
 ..		S keycnt=0
 ..		F I=1:1:$L(acckeys,",") I '$$isLit^UCGM($piece(acckeys,",",I)) S keycnt=keycnt+1
 ..		;
 ..		I (keycnt=1) S tbl=$piece(tbl,":QU",1) ; Remove QUERY if only one key
 ..		E  I '(tbl[":QU") D
 ...			;
 ...			N key N keyname N keyval N TOK
 ...			;
 ...			N qry S qry=$piece($piece(tbl,":QU",2)," ",2,1048575)
 ...			;
 ...			I (qry="") S tbl="" Q 
 ...			;
 ...			S qry=$$QSUB^%ZS(qry,"""")
 ...			;     #ACCEPT DATE=11/09/2008; PGM=Dan Russell; CR=36588; Group=ACCESS
 ...			S qry=$$TOKEN^%ZS(qry,.TOK)
 ...			;
 ...			F I=1:1:$L(acckeys,",")-1 D  Q:(tbl="") 
 ....				;
 ....				S keyname=$piece(acckeys,",",I)
 ....				Q:$$isLit^UCGM(keyname) 
 ....				S key="["_tbl_"]"_keyname_"="
 ....				;
 ....				I (qry'[key) S tbl=""
 ....				E  D
 .....					;
 .....					S keyval=$piece(qry,key,2)
 .....					;       #ACCEPT DATE=11/09/2008; PGM=Dan Russell; CR=36588; Group=ACCESS
 .....					S keyval=$$ATOM^%ZS(keyval,0,",:&",TOK,0)
 .....					I (keyval="") S tbl=""
 .....					E  I '((keyval=+keyval)!(keyval?1"""".E1"""")) S tbl=""
 .....					Q 
 ....				Q 
 ...			;
 ...			Q 
 ..		E  S tbl=""
 ..  Q 
 .	;
 .	S typ=$P(dbtbl1d,$C(124),9)
 .	S min=$P(dbtbl1d,$C(124),12)
 .	I '(min="") S min=$$valuea(min,typ)
 .	S max=$P(dbtbl1d,$C(124),13)
 .	I '(max="") S max=$$valuea(max,typ)
 .	;
 .	; Get current value - needed by VAL^DBSVER
 .	S X=$piece(vx(col),delim,2)
 .	;
 .	S vRM=$$VAL^DBSVER(typ,+$P(dbtbl1d,$C(124),2),+$P(dbtbl1d,$C(124),15),tbl,$P(dbtbl1d,$C(124),6),min,max,+$P(dbtbl1d,$C(124),14),,"["_fid_"]"_col,0)
 .	;
 .	I '(vRM="") S vRM=fid_"."_vop1_" "_vRM
 . Q 
 ;
 I '(vRM="") S $ZE="0,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~"),$EC=",U1001,"
 ;
 Q 
 ;
valuea(v,typ) ; Data type
 ;
 S v=$$value(v,typ)
 I ((v?1A.AN)!(v?1"%".AN)) S v="<<"_v_">>" ; <<variable>>
 ;
 Q v
 ;
value(v,typ) ; Data type
 ;
 N RETURN
 ;
 I (v="") S RETURN=""
 E   N V1 S V1=v I ($D(^STBL("JRNFUNC",V1))#2) D  ; System keyword
 .	;
 .	N jrnfunc S jrnfunc=$$vRCgetRecord0Opt^RecordSTBLJRNFUNC(v,0,"")
 .	;
 .	S RETURN=$P(jrnfunc,$C(124),2)
 . Q 
 E  I (v=+v) S RETURN=v
 E  I ($E(v,1,2)="<<"),($E(v,$L(v)-2+1,1048575)=">>") S RETURN=$piece($piece(v,"<<",2),">>",1) ; <<Variable>>
 ;
 E  I (typ="D") D
 .	;
 .	I (v="T") S RETURN="TJD" ; System Date
 .	E  I (v="C") S RETURN="+$H" ; Calendar Date
 .	E  S RETURN=""
 .	Q 
 E  I (typ="C") D
 .	;
 .	I (v="C") S RETURN="$P($H,"","",2)" ; Current time
 .	E  S RETURN=""
 .	Q 
 E  I (typ="L") D  ; Logical
 .	;
 .	I (v="Y") S RETURN=1
 .	E  S RETURN=0
 .	Q 
 E  I (v="""") S RETURN="""""""""" ; String delimiter
 E  S RETURN=""""_v_"""" ; Text
 ;
 Q RETURN
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61311^54316^Dan Russell^8131" ; Signature - LTD^TIME^USER^SIZE
