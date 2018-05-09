DBSTLOAD	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSTLOAD ****
	;
	; 11/08/2007 14:08 - chenardp
	;
	;Private;To load the data from a table to a RMS file for transfer to a client
	;
	Q 
	;
BLDRMS(TBLNAME,OPT,Q,QITEM,WIDEFILE,SPLIT,FK)	; Public; Build output file for full transfer of a table type
	;
	N ACCVAL,ACKEYS,CNT,COLUMN,FILETYP,fsn,LIB,%LIBS,LOGCHG,KEYS,NETLOC,RECORD,QUOTE,TREC
	S QUOTE=$char(34)
	;
	S QITEM=$get(QITEM)
	S WIDEFILE=$get(WIDEFILE)
	S SPLIT=$get(SPLIT)
	S (%LIBS,LIB)="SYSDEV"
	N dbtbl1,vop1,vop2,vop3,vop4,vop5 S vop1="SYSDEV",vop2=TBLNAME,dbtbl1=$$vDb2("SYSDEV",TBLNAME)
	 S vop4=$G(^DBTBL(vop1,1,vop2,16))
	 S vop3=$G(^DBTBL(vop1,1,vop2,10))
	 S vop5=$G(^DBTBL(vop1,1,vop2,100))
	S KEYS=$P(vop4,$C(124),1)
	S ACKEYS=""
	F I=1:1:$L(KEYS,",") I $E(($piece(KEYS,",",I)),1)'="""",+$piece(KEYS,",",I)'=$piece(KEYS,",",I) S ACKEYS=ACKEYS_","_$piece(KEYS,",",I)
	I ACKEYS'="" S ACKEYS=$E(ACKEYS,2,100)
	S NETLOC=$P(vop3,$C(124),3)
	S LOGCHG=$P(vop5,$C(124),5)
	;
	; define file type to determine if it should be loaded on gui/mumps clients
	;
	I $get(FILENAME)="" S FILETYP=""
	E  D
	.	N schema,vop6,vop7,vop8 S vop6="SYSDEV",vop7=FILENAME,schema=$$vDb2("SYSDEV",FILENAME)
	.	 S vop8=$G(^DBTBL(vop6,1,vop7,10))
	.	S FILETYP=$P(vop8,$C(124),12)
	.	Q 
	S ACCVAL=""
	;
	;Opt=3 is delete option
	I OPT=3,TBLNAME["DBTBL",QITEM'="" D
	.	F I=1:1:$L(ACKEYS,",") D
	..		S COLUMN=$piece(ACKEYS,",",I)
	..		I COLUMN="%LIBS" S ACCVAL=QUOTE_%LIBS_QUOTE Q 
	..		I I=2 S ACCVAL=ACCVAL_","_QUOTE_QITEM_QUOTE Q 
	..		I TBLNAME="DBTBL1F",WIDEFILE'="" S ACCVAL=ACCVAL_","_QUOTE_WIDEFILE_QUOTE Q 
	..		I I>2 S ACCVAL=ACCVAL_","_"*"
	..		Q 
	.	Q 
	;
	I OPT=3,TBLNAME'["DBTBL",QITEM'="" D
	.	S ACCVAL=""
	.	I ACKEYS'="" F I=1:1:$L(ACKEYS,",") D
	..		I I=1 S ACCVAL=QUOTE_QITEM_QUOTE
	..		I I>1 S ACCVAL=ACCVAL_","_"*"
	..		Q 
	.	Q 
	;
	I $E(ACCVAL,1)="," S ACCVAL=$E(ACCVAL,2,1048575)
	;
	S TREC="T"
	;
	S TREC=TREC_","_$P($H,",",1)_","_$P($H,",",2)_","_QUOTE_TBLNAME_QUOTE_","_$S(ACKEYS="":0,1:$L(ACKEYS,","))
	I ACCVAL="" S ACCVAL="*"
	S REC2=$S(TBLNAME["DBTBL":"D",$piece(ACCVAL,",",1)'["*":"D",1:"T")
	;
	I OPT=3,$get(FK),$D(SORTFID),$get(SPLIT)'="" D SPLITDEL^HSYNCSPT Q 
	;
	I OPT=3 D  Q 
	.	I $piece(ACCVAL,",",1)'["*",ACCVAL["*" D
	..		; adjust the key CNT so GUI will not deal with any * values.
	..		;
	..		S $piece(TREC,",",5)=$L(($E(ACCVAL,1,$F(ACCVAL,"*"))),",")-1
	..		Q 
	.	; SORTFID  is an array containing a split of the widefiles sent to the client
	.	;
	.	I '$D(SORTFID) D
	..		I '$D(IOLIST) Q 
	..		S RECTYPE=$$SETREC(.SORTFID,FILETYP)
	..		I RECTYPE="C",'$D(IOLIST("N")) Q 
	..		S WRTREC=TREC_",N,"_RECTYPE_$char(9)_"F"
	..		;
	..		; Columns named with % can not be inserted into Oracle, they are converted to _
	..		S SREC="S"
	..		I ACKEYS'="" D
	...			S WRTREC=WRTREC_","_$TR(ACKEYS,"%","_")
	...			I ACKEYS'="" F I=1:1:$L(ACKEYS,",") S SREC=SREC_","_$$TYP^DBSDD(TBLNAME_"."_$piece(ACKEYS,",",I))
	...			Q 
	..		I $E(REC2,1)'="T" S WRTREC=WRTREC_$char(9)_SREC_$char(9)
	..		; occurs on truncate record
	..		E  S WRTREC=WRTREC_$char(9)
	..		S WRTREC=WRTREC_"D,"_REC2_","_ACCVAL
	..		D IOWRITE^HSYNCWRT(WRTREC)
	..		Q 
	.	E  D SPLITDEL^HSYNCSPT
	.	Q 
	S TRECWRT=0
	D BUILD(TBLNAME,.Q)
	Q 
	;
CHKVER(VER)	; Private,Check Version, determine if PFW has multiple builds
	;
	I $order(NEWFILE(FILENAME,VER))'="" Q 1
	Q 0
	;
BUILD(FID,Q)	; Private, Build the data item list of the file and fetch the data from the table
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	;
	N COLUMN,DI,DILIST,DITYPE,DREC,DV,DVLIST,EXE,NODE,FREC,QDV,TESTVAL,VZNOD,VZREQ,VZTYPE,VZCMP,VZLEN
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
	N collist,vos1,vos2,vos3,vos4,vos5,vos6 S collist=$$vOpen1()
	I '$G(vos1) Q 
	F  Q:'($$vFetch1())  D  Q:$get(ER)="W" 
	.	;
	.	; can not send memo or binary data item
	.	I $P(collist,$C(9),2)="B"!($P(collist,$C(9),2)="M") S ER="W" Q 
	.	; computed are not sent
	.	I $P(collist,$C(9),4)'="" Q 
	.	S COLUMN=$P(collist,$C(9),3)
	.	; literal numerics or strings will not be sent to a client
	.	I (COLUMN?1.N)!($E(COLUMN,1)["""") Q 
	.	;
	.	I $P(collist,$C(9),1)["*" D  Q 
	..		;
	..		; once non key keys are removed, we need to adjust the position in the type variable
	..		; to account for them not being sent
	..		;
	..		S NODE=0
	..		;
	..		N I
	..		F I=1:1:$L(ACKEYS,",") I $piece(ACKEYS,",",I)=COLUMN S NODE=I Q 
	..		;
	..		S $piece(DITYPE,",",NODE)=$P(collist,$C(9),2)
	..		;
	..		I $D(DITYPE)>1 D
	...			S VER=""
	...			F  S VER=$order(DITYPE(VER)) Q:VER=""  S $piece(DITYPE(VER),",",NODE)=$P(collist,$C(9),2)
	...			Q 
	..		Q 
	.	;
	.	S DILIST=DILIST_","_COLUMN
	.	;
	.	I $E(DILIST,1)="," S DILIST=$E(DILIST,2,999999)
	.	;
	.	S DITYPE=DITYPE_","_$P(collist,$C(9),2)
	.	I $D(DITYPE)>1 D
	..		S VER=""
	..		F  S VER=$order(DITYPE(VER)) Q:VER=""  S DITYPE(VER)=DITYPE(VER)_","_$P(collist,$C(9),2)
	..		Q 
	.	;
	.	I FID="DBTBL1D" D
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
	.	I '$D(COLLIST(COLUMN,"TYP")) Q 
	.	;
	.	S VER=""
	.	F  S VER=$order(CLIENT(VER)) Q:VER=""  D
	..		S TESTVAL=$order(COLLIST(COLUMN,"TYP",VER))
	..		I TESTVAL="" Q 
	..		I '$D(DITYPE(VER)) S DITYPE(VER)=DITYPE
	..		S DITYPE(VER)=$piece(DITYPE(VER),",",1,$L(DITYPE(VER),",")-1)_","_$piece(COLLIST(COLUMN,"TYP",TESTVAL),"|",1)
	..		Q 
	.	Q 
	;
	I $get(ER)="W" S ER="" Q 
	;
	I ACKEYS'="" S FREC=FREC_","_DILIST
	I TBLNAME["DBTBL",$get(SPLIT)'=$get(WIDEFILE),WIDEFILE'["DBTBL" D SPLITTBL^HSYNCSPT Q 
	;
	;  #ACCEPT DATE=07/28/06;PGM=KELLYP;CR=unknown
	N rs,exe,sqlcur,vd,vi,vsql,vsub S rs=$$vOpen0(.exe,.vsql,DILIST,FID,$get(Q),"","","")
	I '$G(vobj(rs,0)) K vobj(+$G(rs)) Q 
	;
	S $piece(TREC,",",6)=$S($D(SORTFID):"W",1:"N")
	S $piece(TREC,",",7)=$$SETREC(.SORTFID,FILETYP)
	;
	I '$D(SORTFID) D
	.	S WRTARRAY(1)=TREC
	.	S WRTARRAY(2)=$TR(FREC,"%","_")
	.	S WRTARRAY(3)="S,"_DITYPE
	.	I $D(DITYPE)>1 D
	..		S VER=""
	..		F  S VER=$order(DITYPE(VER)) Q:VER=""  S WRTARRAY(3,VER)="S,"_DITYPE(VER)
	..		Q 
	.	S FOUND=1
	.	D FETCH(.rs)
	.	Q 
	;
	I TBLNAME'["DBTBL",$get(SPLIT)'=$get(WIDEFILE) D
	.	S SPLIT=""
	.	S WIDEFILE=TBLNAME
	.	F  S SPLIT=$order(SORTFID(SPLIT)) Q:SPLIT=""  D SPLITTBL^HSYNCSPT
	.	Q 
	;
	K vobj(+$G(rs)) Q 
	;
FETCH(rs)	;  retrieve data records and write them to the file
	;
	N DATATYPE,DREC,DVLIST,FFIDWIDE,I,NOCOLUMN,OK,QDV,PKEYS,RECORD
	S RECORD=0
	S FFIDWIDE=0
	;
	;  exe array created in the calling function
	F  Q:'($$vFetch(rs))  D
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
	.	F I=1:1:$L(DILIST,",") D DIVAL(.QDV,I) Q:NOCOLUMN=0 
	.	I NOCOLUMN=0 Q 
	.	;
	.	I $D(COLLIST)>1 S VER="" F  S VER=$order(CLIENT(VER)) Q:VER=""  D
	..		N QDV
	..		S QDV=""
	..		S DATATYPE=DITYPE
	..		I $D(DITYPE(VER)) S DATATYPE=DITYPE(VER)
	..		F I=1:1:$L(DILIST,",") D DIVAL(.QDV,I,VER) Q:NOCOLUMN=0 
	..		S DREC(VER)="D"_","_"I"_QDV
	..		Q 
	.	;
	.	I $D(WRTARRAY) D
	..		S WRTREC=WRTARRAY(1)_$char(9)_WRTARRAY(2)
	..		D IOWRITE^HSYNCWRT(WRTREC,,1)
	..		I $D(WRTARRAY(3))=1 D IOWRITE^HSYNCWRT(WRTARRAY(3)) K WRTARRAY Q 
	..		;
	..		D IOWRITE^HSYNCWRT(WRTARRAY(3),CLIENT)
	..		S VER=""
	..		F  S VER=$order(WRTARRAY(3,VER)) Q:VER=""  D IOWRITE^HSYNCWRT(WRTARRAY(3,VER),VER)
	..		K WRTARRAY
	..		Q 
	.	I FOUND=0 D
	..		I TBLNAME'["DBTBL" S $piece(TREC,",",4)=QUOTE_"W_"_SORTFID(SPLIT)_"_"_SPLIT_QUOTE
	..		S $piece(TREC,",",6,7)="S,G"
	..		S RECTYPE="G"
	..		S WRTREC=TREC_$char(9)_$TR(FREC,"%","_")
	..		D IOWRITE^HSYNCWRT(WRTREC,,1)
	..		I $D(DITYPE)=1 D IOWRITE^HSYNCWRT("S,"_DITYPE)
	..		I $D(DITYPE)>1 D
	...			D IOWRITE^HSYNCWRT("S,"_DITYPE,CLIENT)
	...			S VER=""
	...			F  S VER=$order(DITYPE(VER)) Q:VER=""  D IOWRITE^HSYNCWRT("S,"_DITYPE(VER),VER)
	...			Q 
	..		S FOUND=1
	..		S RECORD=1
	..		Q 
	.	S QDV=$E(QDV,2,1048575)
	.	S DREC=DREC_","_QDV
	.	I FFIDWIDE D
	..		S TRECWRT=1
	..		S WRTREC=TREC_$char(9)_FREC
	..		D IOWRITE^HSYNCWRT(WRTREC,,1)
	..		I $D(SREC)=1 D IOWRITE^HSYNCWRT(SREC) Q 
	..		;
	..		I $D(SREC)>1 D
	...			D IOWRITE^HSYNCWRT(SREC,CLIENT)
	...			S VER=""
	...			F  S VER=$order(SREC(VER)) Q:VER=""  D IOWRITE^HSYNCWRT(SREC(VER),VER)
	...			Q 
	..		Q 
	.	I $D(DREC)=1 D IOWRITE^HSYNCWRT(DREC)
	.	S VER=""
	.	F  S VER=$order(DREC(VER)) Q:VER=""  D IOWRITE^HSYNCWRT(DREC(VER),VER)
	.	K DREC
	.	I FFIDWIDE D
	..		S $piece(TREC,",",6,7)="S,G"
	..		N FILENAME,I,PKEYS,SORTFID,WIDEFILE
	..		S FILENAME=$piece(DVLIST,"|",FFIDWIDE)
	..		D MAP^DBSDDMAP(FILENAME,.WIDEFILE)
	..		D RESORT^DDPXFR1(.WIDEFILE,.SORTFID,FILENAME)
	..		I '$D(SORTFID) Q 
	..		;
	..		S I=$L(($piece(DILIST,"PKEYS",1)),",")
	..		S PKEYS=$piece(DVLIST,"|",I)
	..		S I=""
	..		F  S I=$order(SORTFID(I)) Q:$D(SORTFID(I,$piece(PKEYS,",",1))) 
	..		S $piece(DREC,",",FFIDWIDE+2)=QUOTE_"W_"_FILENAME_"_"_I_QUOTE
	..		S OK=1
	..		F J=1:1:$L(PKEYS,",") Q:$piece(PKEYS,",",J)=""  I '$D(SORTFID(I,$piece(PKEYS,",",J))) S OK=0 Q 
	..		I 'OK Q 
	..		S TRECWRT=1
	..		N RECTYPE
	..		S RECTYPE="G"
	..		S WRTREC=TREC_$char(9)_FREC
	..		D IOWRITE^HSYNCWRT(WRTREC,,1)
	..		I $D(SREC)=1 D IOWRITE^HSYNCWRT(SREC) Q 
	..		I $D(SREC)>1 D
	...			D IOWRITE^HSYNCWRT(SREC,CLIENT)
	...			S VER=""
	...			F  S VER=$order(SREC(VER)) Q:VER=""  D IOWRITE^HSYNCWRT(SREC(VER),VER)
	...			Q 
	..		Q 
	.	Q 
	Q 
	;
DIVAL(QDV,PTR,VER)	; Column data formatter
	;
	N DV,DVDATA,RETURNDV,TESTVAR
	;
	I SPLITFLG,'$$SPLITDI^HSYNCSPT($piece(DVLIST,"|",LOC+1),TBLNAME,DILIST,ACKEYS,SPLIT,PTR) S NOCOLUMN=0 Q 
	;
	;DVDATA will be modified to contain the older released version of the format of a column
	;
	S DVDATA=DVLIST
	S VER=$get(VER)
	;
	I TBLNAME="DBTBL1D",$D(COLLIST($piece(DVLIST,"|",3))),VER'="" D
	.	I PTR=VZREQ,$order(COLLIST($piece(DVLIST,"|",3),"REQ",VER))'="" D CHGDVDTA("REQ",VER)
	.	I PTR=VZTYPE,$order(COLLIST($piece(DVLIST,"|",3),"TYP",VER))'="" D CHGDVDTA("TYP",VER)
	.	I PTR=VZLEN,$order(COLLIST($piece(DVLIST,"|",3),"LEN",VER))'="" D CHGDVDTA("LEN",VER)
	.	I PTR=VZCMP,$order(COLLIST($piece(DVLIST,"|",3),"CMP",VER))'="" D CHGDVDTA("CMP",VER)
	.	I PTR=vzdec,$order(COLLIST($piece(DVLIST,"|",3),"DEC",VER))'="" D CHGDVDTA("DEC",VER)
	.	I PTR=vzdes,$order(COLLIST($piece(DVLIST,"|",3),"DES",VER))'="" D CHGDVDTA("DES",VER)
	.	I PTR=vzdft,$order(COLLIST($piece(DVLIST,"|",3),"DFT",VER))'="" D CHGDVDTA("DFT",VER)
	.	I PTR=vzmin,$order(COLLIST($piece(DVLIST,"|",3),"MIN",VER))'="" D CHGDVDTA("MIN",VER)
	.	I PTR=vzmax,$order(COLLIST($piece(DVLIST,"|",3),"MAX",VER))'="" D CHGDVDTA("MAX",VER)
	.	Q 
	S TESTVAR=$piece(DATATYPE,",",PTR)
	I "N$"[TESTVAR S QDV=QDV_","_($piece(DVDATA,"|",PTR)) Q 
	I "L"[TESTVAR S QDV=QDV_","_(+$piece(DVDATA,"|",PTR)) Q 
	I "D"[TESTVAR S QDV=QDV_","_$$INT^%ZM($piece(DVDATA,"|",PTR),"D") Q 
	I "C"[TESTVAR S QDV=QDV_","_$$INT^%ZM($piece(DVDATA,"|",PTR),"C") Q 
	;
	S DV=$piece(DVDATA,"|",PTR)
	I SPLITFLG,PTR=LOC,TBLNAME["DBTBL",$D(SORTFID) S DV="W_"_SORTFID(SPLIT)_"_"_SPLIT
	;
	I $piece(DILIST,",",PTR)="TBLREF",'(SPLITFLG!(QITEM'="")),'$D(SORTFID) D
	.	S RETURNDV=""
	.	D TESTFFID
	.	S NOCOLUMN=$$LOGGING(DV)
	.	S DV=RETURNDV
	.	Q 
	;
	S DV=$$QUOTE^DBSTLOAD(DV)
	S QDV=QDV_","_QUOTE_DV_QUOTE
	Q 
	;
CHGDVDTA(ATTRIB,VER)	; account for schema change between version release
	;
	I I=VZREQ,FID="DBTBL1D",$piece(DVLIST,"|",VZNOD)?1N1"*" S $piece(DVDATA,"|",VZREQ)=1 Q 
	;
	S VER=$order(COLLIST($piece(DVLIST,"|",3),ATTRIB,VER))
	S $piece(DVDATA,"|",I)=$piece(COLLIST($piece(DVLIST,"|",3),ATTRIB,VER),"|",1)
	Q 
	;
SETREC(SORTFID,FILETYP)	; Determine the type of record being transferred
	;
	I $D(SORTFID) Q "C"
	I $get(CHARBASE) Q "C"
	I FILETYP=7 Q "G"
	I $get(FILENAME)="" Q "B"
	I ($D(^STBL("NOGUI",FILENAME))#2) Q "C"
	Q "B"
	;
LOGGING(FID)	;
	;
	N dbtbl1,vop1,vop2,vop3,vop4 S vop1="SYSDEV",vop2=FID,dbtbl1=$$vDb2("SYSDEV",FID)
	 S vop3=$G(^DBTBL(vop1,1,vop2,10))
	 S vop4=$G(^DBTBL(vop1,1,vop2,100))
	I +$P(vop3,$C(124),3)=0!(+$P(vop4,$C(124),5)=0) Q 0
	Q 1
	;
TESTFFID	;Private
	;
	I TBLNAME'="DBTBL1F" Q 
	;
	N SAVEI
	S SAVEI=I
	N FILENAME,I,J,PKEYS,OK,SORTFID,WIDEFILE
	S (RETURNDV,FILENAME)=DV
	D MAP^DBSDDMAP(FILENAME,.WIDEFILE)
	I '$D(WIDEFILE) D  Q 
	.	I $D(WRTARRAY) S $piece(WRTARRAY(1),",",6,7)="N,B" Q 
	.	S WRTARRAY(1)=TREC
	.	S $piece(WRTARRAY(1),",",6,7)="N,B"
	.	S WRTARRAY(2)=FREC
	.	I $D(SREC) S WRTARRAY(3)=SREC
	.	S VER=""
	.	F  S VER=$order(SREC(VER)) Q:VER=""  S WRTARRAY(3,VER)=SREC(VER)
	.	Q 
	;
	D RESORT^DDPXFR1(.WIDEFILE,.SORTFID,FILENAME)
	I $D(WRTARRAY) S $piece(WRTARRAY(1),",",6)="W"
	I '$D(WRTARRAY) S $piece(TREC,",",6)="W"
	S I=$order(SORTFID(""))
	S RETURNDV="W_"_DV_"_"_I
	S FFIDWIDE=SAVEI
	Q 
	;
QUOTE(DV)	;Private; Add quotes to data item if the data already has quotes.
	;
	N I,QUOTE
	S QUOTE=""""
	S I=0
	F  S I=$F(DV,QUOTE,I) Q:'I  S DV=$E(DV,1,I-1)_QUOTE_$E(DV,I,1048575) S I=I+1
	;
	Q DV
	;
vSIG()	;
	Q "60477^65444^Pat Kelly^16460" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vRsRowGC(vNms,vTps)	; Runtime ResultSet.getRow().getColumns()
	;
	;  #OPTIMIZE FUNCTIONS OFF
	;
	N vL S vL="" N vN N vO N vT
	F vO=1:1:$S((vNms=""):0,1:$L(vNms,",")) D
	.	S vN=$piece(vNms,",",vO)
	.	S vT=$E(vTps,(vO-1)*2+1)
	.	I "TUF"[vT S vT="String"
	.	E  S vT=$piece("Blob,Boolean,Date,Memo,Number,Number,Time",",",$F("BLDMN$C",vT)-1)
	.	S $PIECE(vL,",",v0)=vT_" "_vN
	.	Q 
	Q vL
	;
vDb2(v1,v2)	;	voXN = Db.getRecord(DBTBL1,,0)
	;
	N dbtbl1
	S dbtbl1=$G(^DBTBL(v1,1,v2))
	I dbtbl1="",'$D(^DBTBL(v1,1,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1" X $ZT
	Q dbtbl1
	;
vFetch(vRs)	;	Runtime fetch
	;
	new vPgm,vTag
	set vPgm=$TEXT(+0),vTag=vobj(vRs,-2)
	xecute "set vTag="_vTag_"(vRs)"
	quit vTag
	;
vOpen0(exe,vsql,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist)	;	Dynamic MDB ResultSet
	;
	N vOid
	N ER,vExpr,mode,RM,vTok S ER=0 ;=noOpti
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
	E  S vsql=$$OPEN^SQLM(.exe,vFrom,vSelect,vWhere,vOrderby,vGroupby,vParlist,,1,,sqlcur) I 'ER D SAV^SQLCACHE(vExpr,.vParlist)
	I ER S $ZS="-1,"_$ZPOS_",%PSL-E-SQLFAIL,"_$TR($G(RM),$C(10,44),$C(32,126)) X $ZT
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
vFetch0(vOid)	; MDB dynamic FETCH
	;
	; type public String exe(),sqlcur,vd,vi,vsql()
	;
	I vsql=0 Q 0
	S vsql=$$^SQLF(.exe,.vd,.vi,.sqlcur)
	S vobj(vOid)=vd
	S vobj(vOid,0)=vsql
	S vobj(vOid,.1)=$G(vi)
	Q vsql
	;
vOpen1()	;	NOD,TYP,DI,CMP FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:FID AND NOD IS NOT NULL AND CMP IS NULL
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(FID) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^DBINDX("SYSDEV","STR",vos2,vos3),1) I vos3="" G vL1a0
	I '(vos3'=$C(254)) G vL1a3
	S vos4=""
vL1a6	S vos4=$O(^DBINDX("SYSDEV","STR",vos2,vos3,vos4),1) I vos4="" G vL1a3
	S vos5=""
vL1a8	S vos5=$O(^DBINDX("SYSDEV","STR",vos2,vos3,vos4,vos5),1) I vos5="" G vL1a6
	S vos6=$G(^DBTBL("SYSDEV",1,vos2,9,vos5))
	I '($P(vos6,"|",16)="") G vL1a8
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a8
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S collist=$S(vos3=$C(254):"",1:vos3)_$C(9)_$P(vos6,"|",9)_$C(9)_$S(vos5=$C(254):"",1:vos5)_$C(9)_$P(vos6,"|",16)
	;
	Q 1
	;
vtrap1	;	Error trap
	;
	N ERROR S ERROR=$ZS
	USE 0
	; Log error
	D ZE^UTLERR
	S ER=1 S RM=$$ETLOC^%ZT
	Q 
