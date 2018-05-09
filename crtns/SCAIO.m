SCAIO	; Select IO Device
	;
	; **** Routine compiled from DATA-QWIK Procedure SCAIO ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	;
	; Entry point for WN default on files
	;
	N READDEF
	;
	D START
	;
	Q 
	;
READ	; Entry point for READ default on files
	;
	N READDEF
	;
	S READDEF=1
	;
	D START
	;
	Q 
	;
START	;
	;
	N IOINPUT N QPARAMS N SAVIO
	;
	S ER=0
	;
	I '$get(%TO) D
	.	;
	.	;   #ACCEPT DATE=12/29/03;PGM=John Carroll;CR=unknown
	.	S %TO=999
	.	;   #ACCEPT DATE=12/29/03;PGM=John Carroll;CR=unknown
	.	I '%TO S %TO=60
	.	Q 
	;
	I ($D(POP)#2) D  Q 
	.	;
	.	S (IO,IOINPUT)=POP
	.	D DEVICE
	.	I '$get(%EXT) D OPEN
	.	Q 
	;
	I '$get(%EXT) D  Q 
	.	;
	.	N killfkey N PROMPT
	.	;
	.	S killfkey=0
	.	S PROMPT=1
	.	;
	.	I '$D(%fkey) D
	..		;
	..		S killfkey=1
	..		D ZBINIT^%TRMVT()
	..		Q 
	.	;
	.	F  Q:'(PROMPT)  D PROMPT
	.	;
	.	I killfkey K %fkey
	.	Q 
	;
	; %EXT=1, call from screen, X=answer to screen prompt for device
	S SAVIO=$get(IO)
	S (IO,IOINPUT)=X
	;
	D DEVICE
	I '$get(%EXT) D OPEN
	;
	I 'ER S X=IO
	E  S IO=SAVIO
	;
	Q 
	;
PROMPT	; Prompt for device
	;
	N IOINPUT N X
	;
	S PROMPT=0
	;
	USE 0
	;
	; Device:
	WRITE !,$$^MSG(829)
	;
	S X=$$TERM^%ZREAD("",70,"","",%TO,1)
	;
	; Timeout, continue with current device
	I (%fkey="TIM") S X=""
	;
	I (%fkey="HLP") D  Q 
	.	;
	.	; Enter a ? or press the Select key for a list of valid options
	.	WRITE $$^MSG(911)
	.	;
	.	S PROMPT=1
	.	Q 
	;
	I ((%fkey="SEL")!(X["?")) D  I (X="") S PROMPT=1 Q 
	.	;
	.	N HDG N TBL
	.	;
	.	S TBL="[DEVICE]"
	.	S X=$$^DBSTBL("[DEVICE]","","T")
	.	;
	.	WRITE $$LOCK^%TRMVT,$$CLEAR^%TRMVT,$$SCR80^%TRMVT
	.	Q 
	;
	I (X="") D
	.	;
	.	S X=$I
	.	;
	.	WRITE X
	.	Q 
	;
	I (X=0) D
	.	;
	.	S X=$I
	.	;
	.	WRITE $$CUB^%TRMVT,X
	.	Q 
	;
	S (IO,IOINPUT)=X
	;
	D DEVICE
	I '$get(%EXT) D OPEN
	;
	I ER D  Q 
	.	;
	.	I '($get(RM)="") WRITE !,"        ",$$VIDERR^%TRMVT," ",RM," ",$$VIDOFF^%TRMVT
	.	;
	.	S RM=""
	.	S ER=0
	.	;
	.	S PROMPT=1
	.	Q 
	;
	Q 
	;
DEVICE	; Validate device and load device parameters
	;
	N DEV N IODEL N N0 N QUAL
	;
	I (IO=0) S IO=$I
	I (IO="") D  Q 
	.	;
	.	N ET
	.	;
	.	S ER=1
	.	S ET="INVLDIO"
	.	D ^UTLERR
	.	Q 
	;
	; Platform specific device delimiter
	S IODEL=$$IODEL^%ZFUNC()
	;
	; Default delimiter for qualifiers
	I (IODEL="") S IODEL="/"
	;
	; IO device qualifiers
	S QUAL=$piece(IO,IODEL,2,99)
	;
	I ($piece(IO,IODEL,1)="") D  Q 
	.	;
	.	N ET
	.	;
	.	S ER=1
	.	S ET="INVLDIO"
	.	D ^UTLERR
	.	Q 
	;
	; Strip off qualifiers
	S IO=$piece(IO,IODEL,1)
	;
	; Load node 0
	N device,vop1,vop2 S vop1=IO,device=$$vDb5(IO,.vop2)
	 S device=$G(^%SYSVAR(3,vop1,0))
	;
	I ($G(vop2)=0) S N0=""
	E  S N0=$P(device,$C(124),1)_"|"_$P(device,$C(124),2)_"|"_$P(device,$C(124),3)_"|"_$P(device,$C(124),4)_"|"_$P(device,$C(124),5)_"|"_$P(device,$C(124),6)_"|"_$P(device,$C(124),7)_"|"_$P(device,$C(124),8)_"|"_$P(device,$C(124),9)
	;
	; Initialize device type
	S IOTYP=$piece(N0,"|",2)
	;
	; No entry in table, determine
	I (N0="") D  Q:ER 
	.	;
	.	; device type  (TRM,FILE,MT)
	.	S IOTYP=$$DEVTYP^%ZFUNC(IO)
	.	;
	.	I (IOTYP="") D
	..		;
	..		N ET
	..		;
	..		S ER=1
	..		S ET="INVLDIO"
	..		D ^UTLERR
	..		Q 
	.	Q 
	; Get actual device from table
	E  S IO=$piece(N0,"|",1)
	;
	I (IOTYP="TRM") D
	.	;
	.	S N0=$I_"|TRM"
	.	;
	.	Q 
	;
	I (IOTYP="FILE") D
	.	;
	.	; Must include an extension
	.	I '(IO[".") S IOTYP="" Q 
	.	;
	.	; Ensure full path is included
	.	S IO=$$FULLIO^%ZFUNC(.IO)
	.	S N0=IO_"|RMS"
	.	Q 
	;
	; If not a terminal or file, must be pre-defined in the table
	I (IOTYP="") D  Q 
	.	;
	.	N ET
	.	;
	.	S ER=1
	.	S ET="INVLDIO"
	.	D ^UTLERR
	.	Q 
	;
	I $piece(N0,"|",9),$$NOAUTH D  Q 
	.	;
	.	N ET
	.	;
	.	S ER=1
	.	S ET="UNAUTIO"
	.	D ^UTLERR
	.	Q 
	;
	S IOSUB=$piece(N0,"|",3)
	S IOPAR=$piece(N0,"|",8)
	S IORM=132
	S AUXPTR=0
	;
	; Slave printer prompt
	I (IOTYP="PTR") S AUXPTR=$$AUXPTR Q:ER 
	;
	; Slave printer prompt
	I '($piece(N0,"|",4)="") S AUXPTR=$$AUXPTR Q:ER 
	;
	; Type specific params
	D @IOTYP Q:ER 
	;
	K POP
	;
	Q 
	;
	; IO-Type Specific Parameters
	;
TRM	; Output to terminal
	;
	S IOSL=22
	S IOHDG="^SCAV100"
	S IORM=80
	;
	Q 
	;
PTR	; Slave printer
	;
	S IOSL=60
	S IOHDG="^SCAHDG"
	;
	Q 
	;
MT	; Output to tape
	;
	N OP
	N MSG
	;
	S IOHDG="^SCAHDG"
	S IOSL=60
	;
	D PAR
	;
	; Rewind tape?
	S MSG=$$^MSG(2424)
	S OP=$$^DBSMBAR(2,"","",1)
	;
	I (OP=2) D
	.	;
	.	I (IOPAR="") S IOPAR="REWIND"
	.	E  S IOPAR=IOPAR_"/REWIND"
	.	Q 
	;
	Q 
	;
PNTQ	; Output to print queue
	;
	N PROMPT
	;
	; Ask for prompt screen
	I ($get(QUAL)="*") D
	.	;
	.	S PROMPT=1
	.	S QUAL=""
	.	;
	.	; Use prior input
	.	I ($D(IOQPARAM)#2) S QUAL=IOQPARAM
	.	Q 
	;
	; Get parameters
	S IOQPARAM=$$^SCAIOQ($get(QUAL),$get(PROMPT)) Q:ER 
	;
	S IOSL=60
	S IOHDG="^SCAHDG"
	S IOTYP="PNTQ"
	S IOPAR="WRITE/NEWV"
	; Retain input
	S IOQ=IO
	I $get(IOINPUT) S IO=IOINPUT
	;
	Q 
	;
FILE	; Disk file
	;
	N CHSET
	;
	I '(QUAL="") D RMSQUAL(QUAL,.CHSET)
	;
	S IOSL=60
	S IOHDG="^SCAHDG"
	S IOTYP="RMS"
	I $get(READDEF) S IOPAR="R"
	E  I $get(APPEND) S IOPAR="WA"
	E  S IOPAR="WN"
	;
	D PAR
	;
	; Translate "short-hand" parameters to full parameters
	I ($L(IOPAR)<4) D
	.	;
	.	N X
	.	;
	.	S X=""
	.	;
	.	I (IOPAR["R") S X="READ/"
	.	I (IOPAR["W") S X=X_"WRITE/"
	.	I (IOPAR["N") S X=X_"NEWV/"
	.	I (IOPAR["A") S X=X_"APPEND/"
	.	;
	.	I ($E(X,$L(X))="/") S X=$E(X,1,$L(X)-1)
	.	S IOPAR=X
	.	Q 
	;
	I '($get(CHSET)="") S IOPAR=IOPAR_"/CHSET="_$S(CHSET'["""":""""_CHSET_"""",1:$$QADD^%ZS(CHSET,""""))
	;
	I ($E(IOPAR,1)="/") S IOPAR=$E(IOPAR,2,1048575)
	;
	Q 
	;
RMSQUAL(QUAL,CHSET)	;
	;
	N haveUser
	N I N OFF N recsiz
	N date N P1 N P2 N Q N QTR N X N user
	;
	S haveUser=0
	;
	F I=1:1 S Q=$piece(QUAL,"/",I) Q:(Q="")  D
	.	;
	.	; Character sets
	.	I ($get(CHSET)=""),($E($$vStrUC(Q),1,6)="CHSET=") D  Q 
	..		;
	..		N val S val=$$QSUB^%ZS($$vStrUC($piece(Q,"=",2)),"""")
	..		;
	..		I (",M,UTF-8,UTF-16,UTF-32,UTF-16BE,UTF-16LE,"[(","_val_",")) S CHSET=val
	..		Q 
	.	;
	.	; User ID
	.	I Q=$E("USER",1,$L(Q)) D  Q 
	..		;
	..		; Only get the first use
	..		I 'haveUser D
	...			;
	...			I '($get(%UID)="") S IO=IO_"_"_%UID
	...			E  S IO=IO_"_"_$$USERNAM^%ZFUNC
	...			;
	...			S haveUser=1
	...			Q 
	..		Q 
	.	;
	.	S QTR=$translate(Q,"+-","==")
	.	S P1=$piece(QTR,"=",1)
	.	S P2=$piece(QTR,"=",2)
	.	;
	.	; Date
	.	I (P1=$E("DATE",1,$L(P1))) D  Q 
	..		;
	..		; Subsequent occurence
	..		Q:($D(date)#2) 
	..		;
	..		N cuvar S cuvar=$$vDb6()
	..		 S cuvar=$G(^CUVAR(2))
	..		;
	..		I (Q["+") S OFF=P2
	..		E  I (Q["-") S OFF=-2
	..		E  S OFF=0
	..		;
	..		S IO=IO_"_"_$$DAT^%ZM($P(cuvar,$C(124),1)+OFF,"DDMONYEAR")
	..		S date=Q
	..		Q 
	.	;
	.	; Record size
	.	I (P1=$E("RECSIZ",1,$L(P1))) D  Q 
	..		;
	..		; Subsequent occurence
	..		Q:($D(recsiz)#2) 
	..		;
	..		I (P2>512) S RECSIZ=P2
	..		S recsiz=Q
	..		Q 
	.	;
	.	I (P1=$E("APPEND",1,$L(P1))) S APPEND=1
	.	I (P1=$E("RDIST",1,$L(P1))) S IO=IO_"_RDIST_"_P2
	.	Q 
	;
	Q 
	;
SPL	; Output to spool file
	;
	; Valid for this MUMPS?
	D VALID^%ISSPL Q:ER 
	;
	S IOSL=60
	S IOHDG="^SCAHDG"
	;
	I ($piece(N0,"|",3)="") D  Q 
	.	;
	.	D CLOSE^%ISSPL
	.	D ^%ISSPL
	.	Q 
	;
	D OPEN^%ISSPL
	;
	Q 
	;
PAR	; Prompt for open parameters if interactive
	;
	N X
	;
	Q:(($D(POP)#2)!($D(%EXT)#2)) 
	;
	; Enter open parameters
	WRITE "  ",$$^MSG(4820),":  "
	;
	I '(IOPAR="") D
	.	;
	.	WRITE " ",IOPAR,"=> "
	.	;
	.	S X=$$TERM^%ZREAD("",70,"","",%TO,1)
	.	Q 
	;
	I (X="") S X=IOPAR
	;
	S IOPAR=X
	;
	Q 
	;
OPEN	; Open the device - Can be called from external programs
	;
	N Z
	N ET
	;
	I ($D(%OPMODE)#2) D REDIRECT Q:ER 
	;
	I '$get(%TO) D
	.	;
	.	;   #ACCEPT DATE=12/29/03;PGM=John Carroll;CR=unknown
	.	S %TO=999
	.	;   #ACCEPT DATE=12/29/03;PGM=John Carroll;CR=unknown
	.	I '%TO S %TO=60
	.	Q 
	;
	; Don't open for SPL
	Q:($get(IOTYP)="SPL") 
	;
	; Block mode, no access
	Q:($get(%IPMODE)["NOINT") 
	;
	; Own device
	I (IO=$P) D  Q 
	.	;
	.	I '($D(IOTYP)#2) D
	..		;
	..		S IOTYP="TRM"
	..		D TRM
	..		Q 
	.	;
	.	; OPEN aux port
	.	I $get(AUXPTR) D
	..		WRITE $$PRNTON^%TRMVT
	..		D TERM^%ZUSE(IO,"WIDTH=133")
	..		Q 
	.	Q 
	;
	I '($D(IOTYP)#2) D  Q:ER 
	.	;
	.	N %EXT
	.	;
	.	S %EXT=1
	.	;
	.	D DEVICE
	.	Q 
	;
	; Don't open for SPL
	Q:(IOTYP="SPL") 
	;
	S IOPAR=$get(IOPAR)
	;
	; Save queue characteristics and change to FILE
	I (IOTYP="PNTQ") D QSET
	;
	I ((IOTYP="RMS")!(IOTYP="PNTQ")) D
	.	;
	.	S Z=$$FILE^%ZOPEN(IO,IOPAR,10,$get(RECSIZ))
	.	Q 
	E  I (IOTYP="MT") D
	.	;
	.	S Z=$$TAPE^%ZOPEN(IO,IOPAR,10)
	.	Q 
	E  S Z=$$TERM^%ZOPEN(IO,10)
	;
	; Open succeeded
	I Z,(IO'=$I) S %O=4 Q 
	;
	; Device currently in use
	I ((IOTYP="PTR")!(IOTYP="TRM")) D SETERR^DBSEXECU("DEP","MSG",822) Q 
	;
	S ER=1
	S ET="NOTOPEN"
	D ^UTLERR
	;
	Q 
	;
QSET	;
	;
	N DATE
	N TIME
	;
	S DATE=$$vdat2str((+$P($H,",",1)),"DDMONYEAR")
	S TIME=$P($H,",",2)
	S IO=$$FILE^%TRNLNM(DATE_"_"_TIME_"_"_($J#100000)_".TMP_PNTQ",$$SPLDIR)
	;
	N tmppntq,vop1,vop2,vop3 S tmppntq="",vop2="",vop1="",vop3=0
	;
	S vop2=$J
	S vop1=IO
	S $P(tmppntq,$C(124),1)=IOQ
	S $P(tmppntq,$C(124),2)=$get(IOQPARAM)
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^TMPPNTQ(vop2,vop1)=$$RTBAR^%ZFUNC(tmppntq) S vop3=1 Tcommit:vTp  
	;
	Q 
	;
REDIRECT	; Redirect output device based on %OPMODE
	;
	N EXPR
	N CMD N OUTPUT N tree
	;
	D INIT^DBSPNT
	D ^DBSINT(%OPMODE,"CMD(")
	;
	Q:ER 
	;
	F EXPR=1:1 Q:'($D(tree(EXPR))#2)  D
	.	;
	.	N X
	.	;
	.	S X=$piece(tree(EXPR),"(",1)
	.	;
	.	I (X="OUTPUT") S OUTPUT=tree(EXPR)
	.	Q 
	;
	; Redirect
	I '($get(OUTPUT)="") D @OUTPUT
	;
	Q 
	;
OUTPUT(DEVICE)	; Assign IO
	;
	S IO=DEVICE
	;
	K IOTYP
	;
	Q 
	;
CLOSE	; Close device
	;
	N QUIT
	;
	; Don't do for block mode
	Q:($get(%IPMODE)["NOINT") 
	;
	; Assume own device
	Q:'($D(IO)#2) 
	;
	S QUIT=0
	;
	D
	.	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	.	;
	.	USE IO
	.	Q 
	;
	Q:QUIT 
	;
	; Reset printer
	I '($get(IOSUB)=""),(",OKD,CRADEN,"[(","_IOSUB_",")) D @IOSUB
	;
	I $get(AUXPTR) D
	.	;
	.	; Form feed
	.	WRITE $$PRNTFF^%TRMVT()
	.	;
	.	; Close aux port
	.	WRITE $$PRNTOFF^%TRMVT()
	.	;
	.	D TERM^%ZUSE(IO,"WIDTH=81")
	.	Q 
	;
	; Not own device
	I (IO'=$P) D CLOSEIT
	;
	USE 0
	;
	Q 
	;
CLOSEIT	; If not own terminal, handle final form feed, queueing routing, and close device
	;
	; Write form feed
	D
	.	; No FF for RMS or PNTQ
	.	Q:(",RMS,PNTQ,"[(","_$get(IOTYP)_",")) 
	.	;
	.	; FILE or PNTQ
	.	Q:(IO[".") 
	.	;
	.	WRITE #
	.	Q 
	;
	; Dispatch to queue
	I ('($get(IOQ)="")!($get(IOTYP)="PNTQ")) D CLOSEQ
	;
	CLOSE IO
	;
	Q 
	;
CLOSEQ	; If queued job, dispatch to proper print queue
	N vpc
	;
	N X
	;
	; Not right IO file
	Q:'(IO[".TMP_PNTQ") 
	;
	N tmppntq,vop1 S tmppntq=$$vDb7($J,IO,.vop1)
	;
	; No queue information
	S vpc=(($G(vop1)=0)) Q:vpc 
	;
	; Delete tmp info
	K ^TMPPNTQ($J,IO)
	;
	; Send to queue
	S X=$$SEND^%ZQUEUE(IO,$P(tmppntq,$C(124),1),$P(tmppntq,$C(124),2),1)
	;
	I 'X D
	.	S ER=1
	.	;
	.	; Output failed in dispatch to print queue
	.	S RM(1)=$$^MSG(2116)
	.	;
	.	; Error ~p1
	.	S RM(2)=$$^MSG(979,$P(tmppntq,$C(124),2))
	.	;
	.	; Output remains in file:  ~p1
	.	S RM(3)=$$^MSG(2118,IO)
	.	;
	.	; Print using operating system capabilities
	.	S RM(4)=$$^MSG(2227)
	.	;
	.	S RM(5)=""
	.	Q 
	;
	Q 
	;
	; Reset Printer Parameters
	;
CRADEN	; Craden printer
	;
	; Completed
	WRITE $char(19),$$^MSG(3267),$char(12)
	;
	Q 
	;
OKD	; OKIDATA printer
	;
	; 10 <acters per inch
	WRITE $char(30)
	;
	; 6 Lines per inch
	WRITE $char(27)_6
	;
	; 66 Lines per page
	WRITE $char(27)_"F66"
	;
	Q 
	;
SPLDIR()	; Return spool directory
	;
	N SPL
	;
	; Directory specific, logically defined
	S SPL=$$SCAU^%TRNLNM("SPOOL")
	;
	; System specific spooler
	I (SPL="") S SPL=$$SYS^%TRNLNM("SPOOL")
	;
	Q SPL
	;
NOAUTH()	; Check device authorization
	;
	; Return 0 if OK, 1 if not
	;
	N INST N UTLO
	;
	; No user id, no authorization checking
	I ($get(%UID)="") Q 0
	;
	N scau S scau=$$vDb8(%UID)
	;
	Q 1
	;
AUXPTR()	; Prompt for slave printer
	;
	N OP
	;
	; Not principal device
	I (IO'=$I) Q 0
	;
	; Defaulted device
	I ($D(POP)#2) Q 0
	;
	; In Block Mode?
	I ($E($piece($get(%IPMODE),":",1),1,5)="NOINT") Q 0
	;
	S OP=$$^DBSMBAR(32,"","",1)
	;
	; To terminal
	I (OP=1) Q 0
	;
	; Printer is not ready
	I '$$PRNTRDY^%TRMVT D SETERR^DBSEXECU("DEP","MSG",2231) Q 0
	;
	S IOTYP=$piece(N0,"|",4)
	S IOSUB=$piece(N0,"|",5)
	;
	Q 1
	;
vSIG()	;
	Q "60603^44096^Dan Russell^16835" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ","ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ")
	; ----------------
	;  #OPTION ResultClass 0
vdat2str(object,mask)	; Date.toString
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I (object="") Q ""
	I (mask="") S mask="MM/DD/YEAR"
	N cc N lday N lmon
	I mask="DL"!(mask="DS") D  ; Long or short weekday
	.	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
	.	I (cc="") S cc="US"
	.	S lday=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
	.	S mask="DAY" ; Day of the week
	.	Q 
	I mask="ML"!(mask="MS") D  ; Long or short month
	.	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
	.	I (cc="") S cc="US"
	.	S lmon=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
	.	S mask="MON" ; Month of the year
	.	Q 
	Q $ZD(object,mask,$get(lmon),$get(lday))
	;
vDb5(v1,v2out)	;	voXN = Db.getRecord(DEVICE,,1,-2)
	;
	I '$D(^%SYSVAR(3,v1))
	S v2out='$T
	;
	Q ""
	;
vDb6()	;	voXN = Db.getRecord(CUVAR,,0)
	;
	I '$D(^CUVAR)
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,CUVAR" X $ZT
	Q ""
	;
vDb7(v1,v2,v2out)	;	voXN = Db.getRecord(TMPPNTQ,,1,-2)
	;
	N tmppntq
	S tmppntq=$G(^TMPPNTQ(v1,v2))
	I tmppntq="",'$D(^TMPPNTQ(v1,v2))
	S v2out='$T
	;
	Q tmppntq
	;
vDb8(v1)	;	voXN = Db.getRecord(SCAU,,0)
	;
	N scau
	S scau=$G(^SCAU(1,v1))
	I scau="",'$D(^SCAU(1,v1))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,SCAU" X $ZT
	Q scau
	;
vtrap1	;	Error trap
	;
	N error S error=$ZS
	;
	S QUIT=1
	Q 
