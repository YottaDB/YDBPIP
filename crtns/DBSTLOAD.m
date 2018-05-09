 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSTLOAD ****
 ; 
 ; 02/09/2009 03:13 - pip
 ; 
 ;
 ;Private;To load the data from a table to a RMS file for transfer to a client
 ;
 Q 
 ;
BLDRMS(TBLNAME,OPT,Q,QITEM,WIDEFILE,SPLIT,FK) ; DBTBL1F.FKEYS   /NOREQ
 ;
 N CNT N I N TRECWRT
 N ACCVAL N ACKEYS N COLUMN N FILETYP N fsn N LIB N LOGCHG N KEYS N NETLOC N REC2 N RECORD N QUOTE N TREC
 ;
 S QUOTE=$char(34)
 ;
 S QITEM=$get(QITEM)
 S WIDEFILE=$get(WIDEFILE)
 S SPLIT=$get(SPLIT)
 S LIB="SYSDEV"
 ;
 N dbtbl1,vop1,vop2,vop3,vop4,vop5 S vop1="SYSDEV",vop2=TBLNAME,dbtbl1=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",TBLNAME,0,"")
  S vop4=$G(^DBTBL(vop1,1,vop2,16))
  S vop3=$G(^DBTBL(vop1,1,vop2,10))
  S vop5=$G(^DBTBL(vop1,1,vop2,100))
 ;
 S KEYS=$P(vop4,$C(124),1)
 S ACKEYS=""
 F I=1:1:$L(KEYS,",") I ($E($piece(KEYS,",",I),1)'=""""),(+$piece(KEYS,",",I)'=$piece(KEYS,",",I)) S ACKEYS=ACKEYS_","_$piece(KEYS,",",I)
 I '(ACKEYS="") S ACKEYS=$E(ACKEYS,2,100)
 S NETLOC=$P(vop3,$C(124),3)
 S LOGCHG=$P(vop5,$C(124),5)
 ;
 ; define file type to determine if it should be loaded on gui/mumps clients
 ;
 I ($get(FILENAME)="") S FILETYP=""
 E  D
 .	;
 .	N dbtbl1,vop6,vop7,vop8 S vop6="SYSDEV",vop7=FILENAME,dbtbl1=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",FILENAME,0,"")
 .	 S vop8=$G(^DBTBL(vop6,1,vop7,10))
 .	S FILETYP=$P(vop8,$C(124),12)
 .	Q 
 S ACCVAL=""
 ;
 ;Opt=3 is delete option
 I (OPT=3),'(QITEM="") D
 .	;
 .	I (TBLNAME["DBTBL") D
 ..		;
 ..		F I=1:1:$L(ACKEYS,",") D
 ...			;
 ...			S COLUMN=$piece(ACKEYS,",",I)
 ...			I (COLUMN="%LIBS") S ACCVAL=QUOTE_"SYSDEV"_QUOTE Q 
 ...			I (I=2) S ACCVAL=ACCVAL_","_QUOTE_QITEM_QUOTE Q 
 ...			I (TBLNAME="DBTBL1F"),'(WIDEFILE="") S ACCVAL=ACCVAL_","_QUOTE_WIDEFILE_QUOTE Q 
 ...			I (I>2) S ACCVAL=ACCVAL_","_"*"
 ...			Q 
 ..		Q 
 .	E  D
 ..		;
 ..		S ACCVAL=""
 ..		I '(ACKEYS="") F I=1:1:$L(ACKEYS,",") D
 ...			;
 ...			I (I=1) S ACCVAL=QUOTE_QITEM_QUOTE
 ...			E  I (I>1) S ACCVAL=ACCVAL_","_"*"
 ...			Q 
 ..		Q 
 .	Q 
 ;
 I $E(ACCVAL,1)="," S ACCVAL=$E(ACCVAL,2,1048575)
 ;
 S TREC="T"
 ;
 S TREC=TREC_","_$P($H,",",1)_","_$P($H,",",2)_","_QUOTE_TBLNAME_QUOTE_","_$S((ACKEYS=""):0,1:$L(ACKEYS,","))
 I (ACCVAL="") S ACCVAL="*"
 S REC2=$S((TBLNAME["DBTBL"):"D",'($piece(ACCVAL,",",1)["*"):"D",1:"T")
 ;
 I (OPT=3),$get(FK),$D(SORTFID),'($get(SPLIT)="") D SPLITDEL^HSYNCSPT Q 
 ;
 I (OPT=3) D  Q 
 .	;
 .	I '($piece(ACCVAL,",",1)["*"),(ACCVAL["*") D
 ..		;
 ..		; adjust the key CNT so GUI will not deal with any * values.
 ..		S $piece(TREC,",",5)=$L($E(ACCVAL,1,$F(ACCVAL,"*")),",")-1
 ..		Q 
 .	; SORTFID  is an array containing a split of the widefiles sent to the client
 .	;
 .	I '$D(SORTFID),$D(IOLIST) D
 ..		;
 ..		N SREC N WRTREC
 ..		;
 ..		S RECTYPE=$$SETREC(.SORTFID,FILETYP)
 ..		I (RECTYPE="C"),'($D(IOLIST("N"))#2) Q 
 ..		S WRTREC=TREC_",N,"_RECTYPE_$char(9)_"F"
 ..		;
 ..		; Columns named with % can not be inserted into Oracle, they are converted to _
 ..		S SREC="S"
 ..		I '(ACKEYS="") D
 ...			;
 ...			S WRTREC=WRTREC_","_$translate(ACKEYS,"%","_")
 ...			I '(ACKEYS="") F I=1:1:$L(ACKEYS,",") S SREC=SREC_","_$$TYP^DBSDD(TBLNAME_"."_$piece(ACKEYS,",",I))
 ...			Q 
 ..		I ('$E(REC2,1)="T") S WRTREC=WRTREC_$char(9)_SREC_$char(9)
 ..		; occurs on truncate record
 ..		E  S WRTREC=WRTREC_$char(9)
 ..		S WRTREC=WRTREC_"D,"_REC2_","_ACCVAL
 ..		D IOWRITE^HSYNCWRT(WRTREC)
 ..		Q 
 .	E  D SPLITDEL^HSYNCSPT
 .	Q 
 S TRECWRT=0
 D BUILD(TBLNAME,.Q)
 ;
 Q 
 ;
CHKVER(VER) ; Check Version, determine if PFW has multiple builds
 ;
 I '($order(NEWFILE(FILENAME,VER))="") Q 1
 ;
 Q 0
 ;
BUILD(FID,Q) ; Query string built in other routines  /NOREQ
 N vpc
 ;
 N FOUND N SPLITFLG
 N KEYCNT N vzdec N vzdes N vzdft N vzmax N vzmin
 N COLUMN N DI N DILIST N DITYPE N DREC N DV N DVLIST N EXE N NODE N FREC N QDV N TESTVAL
 N VER N VZNOD N VZREQ N VZTYPE N VZCMP N VZLEN N WRTARRAY
 ;
 N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="N voxEr S voxEr=$ZE D:'+voxEr LOG^UCGMR(""LOGERR^UTLERR"",.voxEr) S $ZE=voxEr D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ;
 S FREC="F"
 S QDV=""
 S DILIST=ACKEYS
 S KEYCNT=$L(DILIST,",")
 ;
 ; Allocate position for keys within DITYPE string
 S DITYPE=""
 S $piece(DITYPE,",",KEYCNT)=""
 S SPLITFLG=0
 ;
 N collist S collist=$$vOpen1()
 S vpc='$G(vobj(collist,0)) K:vpc vobj(+$G(collist)) Q:vpc 
 F  Q:'$$vFetch1(collist)  D  Q:($get(ER)="W") 
 .	;
 .	; can not send memo or binary data item
 .	I (($P(vobj(collist),$C(9),2)="B")!($P(vobj(collist),$C(9),2)="M")) S ER="W" Q 
 .	; computed are not sent
 .	Q:'($P(vobj(collist),$C(9),4)="") 
 .	S COLUMN=$P(vobj(collist),$C(9),3)
 .	; literal numerics or strings will not be sent to a client
 .	I ((COLUMN?1.N)!($E(COLUMN,1)["""")) Q 
 .	;
 .	I ($P(vobj(collist),$C(9),$$vRsGetCol(collist,NOD))["*") D  Q 
 ..		;
 ..		; once non key keys are removed, we need to adjust the position in the type variable
 ..		; to account for them not being sent
 ..		;
 ..		S NODE=0
 ..		;
 ..		N I
 ..		F I=1:1:$L(ACKEYS,",") I $piece(ACKEYS,",",I)=COLUMN S NODE=I Q 
 ..		;
 ..		S $piece(DITYPE,",",NODE)=$P(vobj(collist),$C(9),2)
 ..		;
 ..		I ($D(DITYPE)>1) D
 ...			;
 ...			S VER=""
 ...			F  S VER=$order(DITYPE(VER)) Q:(VER="")  S $piece(DITYPE(VER),",",NODE)=$P(vobj(collist),$C(9),2)
 ...			Q 
 ..		Q 
 .	;
 .	S DILIST=DILIST_","_COLUMN
 .	;
 .	I $E(DILIST,1)="," S DILIST=$E(DILIST,2,999999)
 .	;
 .	S DITYPE=DITYPE_","_$P(vobj(collist),$C(9),2)
 .	I ($D(DITYPE)>1) D
 ..		;
 ..		S VER=""
 ..		F  S VER=$order(DITYPE(VER)) Q:(VER="")  S DITYPE(VER)=DITYPE(VER)_","_$P(vobj(collist),$C(9),2)
 ..		Q 
 .	;
 .	I (FID="DBTBL1D") D
 ..		;
 ..		I COLUMN="REQ" S VZREQ=$L(DILIST,",")
 ..		I COLUMN="NOD" S VZNOD=$L(DILIST,",")
 ..		I COLUMN="TYP" S VZTYPE=$L(DILIST,",")
 ..		I COLUMN="LEN" S VZLEN=$L(DILIST,",")
 ..		I COLUMN="CMP" S VZCMP=$L(DILIST,",")
 ..		I COLUMN="DEC" S vzdec=$L(DILIST,",")
 ..		I COLUMN="DES" S vzdes=$L(DILIST,",")
 ..		I COLUMN="DFT" S vzdft=$L(DILIST,",")
 ..		I COLUMN="MAX" S vzmax=$L(DILIST,",")
 ..		I COLUMN="MIN" S vzmin=$L(DILIST,",")
 ..		Q 
 .	;
 .	Q:'$D(COLLIST(COLUMN,"TYP")) 
 .	;
 .	S VER=""
 .	F  S VER=$order(CLIENT(VER)) Q:(VER="")  D
 ..		;
 ..		S TESTVAL=$order(COLLIST(COLUMN,"TYP",VER))
 ..		I (TESTVAL="") Q 
 ..		I '($D(DITYPE(VER))#2) S DITYPE(VER)=DITYPE
 ..		S DITYPE(VER)=$piece(DITYPE(VER),",",1,$L(DITYPE(VER),",")-1)_","_$piece(COLLIST(COLUMN,"TYP",TESTVAL),"|",1)
 ..		Q 
 .	Q 
 ;
 I ($get(ER)="W") S ER="" K vobj(+$G(collist)) Q 
 ;
 I '(ACKEYS="") S FREC=FREC_","_DILIST
 I (TBLNAME["DBTBL"),$get(SPLIT)'=$get(WIDEFILE),'(WIDEFILE["DBTBL") D SPLITTBL^HSYNCSPT K vobj(+$G(collist)) Q 
 ;
 ;  #ACCEPT DATE=07/28/06;PGM=KELLYP;CR=unknown
 N rs,exe,sqlcur,vd,vi,vsql,vsub S rs=$$vOpen0(.exe,.vsql,DILIST,FID,$get(Q),"","","",1)
 S vpc='$G(vobj(rs,0)) K:vpc vobj(+$G(collist)),vobj(+$G(rs)) Q:vpc 
 ;
 S $piece(TREC,",",6)=$S($D(SORTFID):"W",1:"N")
 S $piece(TREC,",",7)=$$SETREC(.SORTFID,FILETYP)
 ;
 I '$D(SORTFID) D
 .	;
 .	S WRTARRAY(1)=TREC
 .	S WRTARRAY(2)=$translate(FREC,"%","_")
 .	S WRTARRAY(3)="S,"_DITYPE
 .	I $D(DITYPE)>1 D
 ..		;
 ..		S VER=""
 ..		F  S VER=$order(DITYPE(VER)) Q:(VER="")  S WRTARRAY(3,VER)="S,"_DITYPE(VER)
 ..		Q 
 .	S FOUND=1
 .	D FETCH(.rs)
 .	Q 
 ;
 I '(TBLNAME["DBTBL"),$get(SPLIT)'=$get(WIDEFILE) D
 .	;
 .	S SPLIT=""
 .	S WIDEFILE=TBLNAME
 .	F  S SPLIT=$order(SORTFID(SPLIT)) Q:(SPLIT="")  D SPLITTBL^HSYNCSPT
 .	Q 
 ;
 K vobj(+$G(collist)),vobj(+$G(rs)) Q 
 ;
FETCH(rs) ; retrieve data records and write them to the file
 ;
 N I N FFIDWIDE N NOCOLUMN N OK N RECORD
 N DATATYPE N DREC N DVLIST N QDV N PKEYS
 ;
 S RECORD=0
 S FFIDWIDE=0
 ;
 ;  exe array created in the calling function
 F  Q:'$$vFetch(rs)  D
 .	;
 .	S DVLIST=vobj(rs)
 .	S DVLIST=$translate(DVLIST,$char(9),"|")
 .	;
 .	;Change key to required field
 .	I FID="DBTBL1D",$piece(DVLIST,"|",VZNOD)?1N1"*" S $piece(DVLIST,"|",VZREQ)=1
 .	;
 .	S DREC="D"_","_"I"
 .	S QDV=""
 .	;
 .	S NOCOLUMN=1
 .	S DATATYPE=DITYPE
 .	F I=1:1:$L(DILIST,",") D DIVAL(.QDV,I) Q:(NOCOLUMN=0) 
 .	I NOCOLUMN=0 Q 
 .	;
 .	I ($D(COLLIST)>1) S VER="" F  S VER=$order(CLIENT(VER)) Q:(VER="")  D
 ..		;
 ..		N QDV
 ..		S QDV=""
 ..		S DATATYPE=DITYPE
 ..		I ($D(DITYPE(VER))#2) S DATATYPE=DITYPE(VER)
 ..		F I=1:1:$L(DILIST,",") D DIVAL(.QDV,I,VER) Q:(NOCOLUMN=0) 
 ..		S DREC(VER)="D"_","_"I"_QDV
 ..		Q 
 .	;
 .	I $D(WRTARRAY) D
 ..		;
 ..		S WRTREC=WRTARRAY(1)_$char(9)_WRTARRAY(2)
 ..		D IOWRITE^HSYNCWRT(WRTREC,,1)
 ..		I ($D(WRTARRAY(3))#2) D IOWRITE^HSYNCWRT(WRTARRAY(3)) K WRTARRAY Q 
 ..		;
 ..		D IOWRITE^HSYNCWRT(WRTARRAY(3),CLIENT)
 ..		S VER=""
 ..		F  S VER=$order(WRTARRAY(3,VER)) Q:(VER="")  D IOWRITE^HSYNCWRT(WRTARRAY(3,VER),VER)
 ..		K WRTARRAY
 ..		Q 
 .	I (FOUND=0) D
 ..		;
 ..		I '(TBLNAME["DBTBL") S $piece(TREC,",",4)=QUOTE_"W_"_SORTFID(SPLIT)_"_"_SPLIT_QUOTE
 ..		S $piece(TREC,",",6,7)="S,G"
 ..		S RECTYPE="G"
 ..		S WRTREC=TREC_$char(9)_$translate(FREC,"%","_")
 ..		D IOWRITE^HSYNCWRT(WRTREC,,1)
 ..		I ($D(DITYPE)#2) D IOWRITE^HSYNCWRT("S,"_DITYPE)
 ..		I ($D(DITYPE)>1) D
 ...			;
 ...			D IOWRITE^HSYNCWRT("S,"_DITYPE,CLIENT)
 ...			S VER=""
 ...			F  S VER=$order(DITYPE(VER)) Q:(VER="")  D IOWRITE^HSYNCWRT("S,"_DITYPE(VER),VER)
 ...			Q 
 ..		S FOUND=1
 ..		S RECORD=1
 ..		Q 
 .	S QDV=$E(QDV,2,1048575)
 .	S DREC=DREC_","_QDV
 .	I FFIDWIDE D
 ..		;
 ..		S TRECWRT=1
 ..		S WRTREC=TREC_$char(9)_FREC
 ..		D IOWRITE^HSYNCWRT(WRTREC,,1)
 ..		I ($D(SREC)#2) D IOWRITE^HSYNCWRT(SREC) Q 
 ..		;
 ..		I ($D(SREC)>1) D
 ...			;
 ...			D IOWRITE^HSYNCWRT(SREC,CLIENT)
 ...			S VER=""
 ...			F  S VER=$order(SREC(VER)) Q:(VER="")  D IOWRITE^HSYNCWRT(SREC(VER),VER)
 ...			Q 
 ..		Q 
 .	I ($D(DREC)#2) D IOWRITE^HSYNCWRT(DREC)
 .	S VER=""
 .	F  S VER=$order(DREC(VER)) Q:(VER="")  D IOWRITE^HSYNCWRT(DREC(VER),VER)
 .	K DREC
 .	I FFIDWIDE D
 ..		;
 ..		N J
 ..		N FILENAME N I N PKEYS N RECTYPE N SORTFID N WIDEFILE
 ..		;
 ..		S $piece(TREC,",",6,7)="S,G"
 ..		S FILENAME=$piece(DVLIST,"|",FFIDWIDE)
 ..		D MAP^DBSDDMAP(FILENAME,.WIDEFILE)
 ..		D RESORT^DDPXFR1(.WIDEFILE,.SORTFID,FILENAME)
 ..		Q:'$D(SORTFID) 
 ..		;
 ..		S I=$L($piece(DILIST,"PKEYS",1),",")
 ..		S PKEYS=$piece(DVLIST,"|",I)
 ..		S I=""
 ..		F  S I=$order(SORTFID(I)) Q:($D(SORTFID(I,$piece(PKEYS,",",1)))#2) 
 ..		S $piece(DREC,",",FFIDWIDE+2)=QUOTE_"W_"_FILENAME_"_"_I_QUOTE
 ..		S OK=1
 ..		F J=1:1:$L(PKEYS,",") Q:($piece(PKEYS,",",J)="")  I '($D(SORTFID(I,$piece(PKEYS,",",J)))#2) S OK=0 Q 
 ..		Q:'OK 
 ..		S TRECWRT=1
 ..		;
 ..		S RECTYPE="G"
 ..		S WRTREC=TREC_$char(9)_FREC
 ..		D IOWRITE^HSYNCWRT(WRTREC,,1)
 ..		I ($D(SREC)#2) D IOWRITE^HSYNCWRT(SREC) Q 
 ..		I ($D(SREC)>1) D
 ...			;
 ...			D IOWRITE^HSYNCWRT(SREC,CLIENT)
 ...			S VER=""
 ...			F  S VER=$order(SREC(VER)) Q:(VER="")  D IOWRITE^HSYNCWRT(SREC(VER),VER)
 ...			Q 
 ..		Q 
 .	Q 
 Q 
 ;
DIVAL(QDV,PTR,VER) ; Host Profile Version
 ;
 N DV N DVDATA N RETURNDV N TESTVAR
 ;
 I SPLITFLG,'$$SPLITDI^HSYNCSPT($piece(DVLIST,"|",LOC+1),TBLNAME,DILIST,ACKEYS,SPLIT,PTR) S NOCOLUMN=0 Q 
 ;
 ;DVDATA will be modified to contain the older released version of the format of a column
 ;
 S DVDATA=DVLIST
 S VER=$get(VER)
 ;
 I TBLNAME="DBTBL1D",$D(COLLIST($piece(DVLIST,"|",3))),'(VER="") D
 .	I PTR=VZREQ,'($order(COLLIST($piece(DVLIST,"|",3),"REQ",VER))="") D CHGDVDTA("REQ",VER)
 .	I PTR=VZTYPE,'($order(COLLIST($piece(DVLIST,"|",3),"TYP",VER))="") D CHGDVDTA("TYP",VER)
 .	I PTR=VZLEN,'($order(COLLIST($piece(DVLIST,"|",3),"LEN",VER))="") D CHGDVDTA("LEN",VER)
 .	I PTR=VZCMP,'($order(COLLIST($piece(DVLIST,"|",3),"CMP",VER))="") D CHGDVDTA("CMP",VER)
 .	I PTR=vzdec,'($order(COLLIST($piece(DVLIST,"|",3),"DEC",VER))="") D CHGDVDTA("DEC",VER)
 .	I PTR=vzdes,'($order(COLLIST($piece(DVLIST,"|",3),"DES",VER))="") D CHGDVDTA("DES",VER)
 .	I PTR=vzdft,'($order(COLLIST($piece(DVLIST,"|",3),"DFT",VER))="") D CHGDVDTA("DFT",VER)
 .	I PTR=vzmin,'($order(COLLIST($piece(DVLIST,"|",3),"MIN",VER))="") D CHGDVDTA("MIN",VER)
 .	I PTR=vzmax,'($order(COLLIST($piece(DVLIST,"|",3),"MAX",VER))="") D CHGDVDTA("MAX",VER)
 .	Q 
 S TESTVAR=$piece(DATATYPE,",",PTR)
 I "N$"[TESTVAR S QDV=QDV_","_$piece(DVDATA,"|",PTR) Q 
 I "L"[TESTVAR S QDV=QDV_","_(+$piece(DVDATA,"|",PTR)) Q 
 I "D"[TESTVAR S QDV=QDV_","_$$INT^%ZM($piece(DVDATA,"|",PTR),"D") Q 
 I "C"[TESTVAR S QDV=QDV_","_$$INT^%ZM($piece(DVDATA,"|",PTR),"C") Q 
 ;
 S DV=$piece(DVDATA,"|",PTR)
 I SPLITFLG,(PTR=LOC),(TBLNAME["DBTBL"),$D(SORTFID) S DV="W_"_SORTFID(SPLIT)_"_"_SPLIT
 ;
 I ($piece(DILIST,",",PTR)="TBLREF"),'(SPLITFLG!('(QITEM=""))),'$D(SORTFID) D
 .	;
 .	S RETURNDV=""
 .	D TESTFFID
 .	S NOCOLUMN=$$LOGGING(DV)
 .	S DV=RETURNDV
 .	Q 
 ;
 S QDV=QDV_","_$S(DV'["""":""""_DV_"""",1:$$QADD^%ZS(DV,""""))
 Q 
 ;
CHGDVDTA(ATTRIB,VER) ; Version of changed column
 ;
 I (I=VZREQ),(FID="DBTBL1D"),$piece(DVLIST,"|",VZNOD)?1N1"*" S $piece(DVDATA,"|",VZREQ)=1
 E  D
 .	;
 .	S VER=$order(COLLIST($piece(DVLIST,"|",3),ATTRIB,VER))
 .	S $piece(DVDATA,"|",I)=$piece(COLLIST($piece(DVLIST,"|",3),ATTRIB,VER),"|",1)
 .	Q 
 ;
 Q 
 ;
SETREC(SORTFID,FILETYP) ; Table type
 ;
 I $D(SORTFID) Q "C"
 I $get(CHARBASE) Q "C"
 I (FILETYP=7) Q "G"
 I ($get(FILENAME)="") Q "B"
 I ($D(^STBL("NOGUI",FILENAME))#2) Q "C"
 Q "B"
 ;
LOGGING(FID) ; Table Name
 ;
 N dbtbl1,vop1,vop2,vop3,vop4 S vop1="SYSDEV",vop2=FID,dbtbl1=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",FID,0,"")
  S vop3=$G(^DBTBL(vop1,1,vop2,10))
  S vop4=$G(^DBTBL(vop1,1,vop2,100))
 ;
 I ((+$P(vop3,$C(124),3)=0)!(+$P(vop4,$C(124),5)=0)) Q 0
 ;
 Q 1
 ;
TESTFFID ; 
 ;
 N FILENAME N PKEYS N N N OK N SAVEI N SORTFID N WIDEFILE
 ;
 Q:(TBLNAME'="DBTBL1F") 
 ;
 S SAVEI=I
 ;
 S (RETURNDV,FILENAME)=DV
 D MAP^DBSDDMAP(FILENAME,.WIDEFILE)
 I '$D(WIDEFILE) D  Q 
 .	;
 .	I $D(WRTARRAY) S $piece(WRTARRAY(1),",",6,7)="N,B" Q 
 .	S WRTARRAY(1)=TREC
 .	S $piece(WRTARRAY(1),",",6,7)="N,B"
 .	S WRTARRAY(2)=FREC
 .	I ($D(SREC)#2) S WRTARRAY(3)=SREC
 .	S VER=""
 .	F  S VER=$order(SREC(VER)) Q:(VER="")  S WRTARRAY(3,VER)=SREC(VER)
 .	Q 
 ;
 D RESORT^DDPXFR1(.WIDEFILE,.SORTFID,FILENAME)
 I $D(WRTARRAY) S $piece(WRTARRAY(1),",",6)="W"
 E  S $piece(TREC,",",6)="W"
 S N=$order(SORTFID(""))
 S RETURNDV="W_"_DV_"_"_N
 S FFIDWIDE=SAVEI
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61282^64310^Dan Russell^18054" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vRsGetCol(object,column) ; Runtime ResultSet.getCol()
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;
 I (column="") Q ""
 I column Q column
 ;
 N select S select=$piece(vobj(object,-3)," FROM ")
 N pos S pos=$L($piece((","_select_","),","_column_",",1),",")
 Q pos
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
vOpen1() ; NOD,TYP,DI,CMP FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:FID AND NOD IS NOT NULL AND CMP IS NULL
 ;
 N vOid
 ;
 S vOid=$O(vobj(""),-1)+1
 S vobj(vOid,0)=2
 S vobj(vOid,-1)="ResultSet"
 S vobj(vOid,-2)="$$vFetch1^"_$T(+0)
 S vobj(vOid,-3)="NOD,TYP,DI,CMP"
 S vobj(vOid,-4)="T0U0U0T0"
 D vL1a1
 Q vOid
 ;
vL1a0 S vobj(vOid,0)=0 Q
vL1a1 S vobj(vOid,1)=$G(FID) I vobj(vOid,1)="" G vL1a0
 S vobj(vOid,2)=""
vL1a3 S vobj(vOid,2)=$O(^DBINDX("SYSDEV","STR",vobj(vOid,1),vobj(vOid,2)),1) I vobj(vOid,2)="" G vL1a0
 I '(vobj(vOid,2)'=$ZCH(254)) G vL1a3
 S vobj(vOid,3)=""
vL1a6 S vobj(vOid,3)=$O(^DBINDX("SYSDEV","STR",vobj(vOid,1),vobj(vOid,2),vobj(vOid,3)),1) I vobj(vOid,3)="" G vL1a3
 S vobj(vOid,4)=""
vL1a8 S vobj(vOid,4)=$O(^DBINDX("SYSDEV","STR",vobj(vOid,1),vobj(vOid,2),vobj(vOid,3),vobj(vOid,4)),1) I vobj(vOid,4)="" G vL1a6
 S vobj(vOid,5)=$G(^DBTBL("SYSDEV",1,vobj(vOid,1),9,vobj(vOid,4)))
 I '($P(vobj(vOid,5),"|",16)="") G vL1a8
 Q
 ;
vFetch1(vOid) ;
 ;
 ;
 I vobj(vOid,0)=1 D vL1a8
 I vobj(vOid,0)=2 S vobj(vOid,0)=1
 ;
 I vobj(vOid,0)=0 S vobj(vOid)="" Q 0
 ;
 S vobj(vOid)=$S(vobj(vOid,2)=$ZCH(254):"",1:vobj(vOid,2))_$C(9)_$P(vobj(vOid,5),"|",9)_$C(9)_$S(vobj(vOid,4)=$ZCH(254):"",1:vobj(vOid,4))_$C(9)_$P(vobj(vOid,5),"|",16)
 ;
 Q 1
 ;
vCatch1 ; Error trap
 ;
 N ERROR,$ET,$ES S ERROR=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 S ER=1
 S RM=$P(ERROR,",",3)_","_$P(ERROR,",",2)_","_$P($P(ERROR,",",3),"-",1)_","_$P(ERROR,",",4)_","_$P($P(ERROR,",",3),"-",3)
 D ZX^UCGMR(voxMrk) Q 
