DBSSPAWN	;;DBS - U - V4.0 - Sub-process driver
	;;Copyright(c)2000 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/10/00 10:50:27 - DOUGANM
	;     ORIG: FSANCHEZ - 09/21/90
	;CALLED BY:  ^DBSCRT,^SCADRV2
	;    CALLS:  
	; PROJ #'S:
	;     DESC:  Allow creation of and attaching to sessions (sub-processes)
	;            from the driver and from DATA-QWIK screens.
	;
	;            All new process creation is done through the top process.
	;
	; GLOBALS -  
	;     READ:
	;      SET:  ^TMP("SUBPROC",$I)=top pid|calling pid|choice|top_cnct
	;                           $I,0)=input
	;                             ,pid,0)=PID of calling process
	;                                 ,1)=name|function
	;
	;            where top pid is the main process PID
	;                  calling pid is the current PID making a call
	;                  choice is the function being called (menu if null)
	;                  top_cnct is indicator for top process' control of
	;                              new spawning and re-connection:
	;                               "" = do nothing
	;                                0 = Spawn new process
	;                              pid = Re-connect to pid
	;                  input is optional input string
	;                  function is current function location of process
	;
	;    INPUT:
	;   OUTPUT:
	;
	;---- Revision History ------------------------------------------------
	;
	; 08/10/00 - DOUGANM- 39582 
	;            To improve the performance of error handling, cleaned up 
	;            call to $$NEW^%ZT, and removed use of indirection. 
	;
	; 06/15/00 - CARROLLJ - 40624
	;	     Modified and ATTACH section to not take save the TMP
	;	     global and corrected %FN from being undefined.
	;
	; 03/10/00 - CARROLLJ - 37458
	;	     Modified the ATTACH section to replace the setting of %FN
	;	     equal to ^TMP(0,$J) and call GETTMP^SCADRV0.  Also saved
	;	     saved the TMP globabl by calling SAVTMP^SCADRV0.
	;
	; 07/19/94 - Steve Canfield - I18N
	;            Replaced embedded messages with a call to extrinsic 
	;            function $$^MSG(msgid,p1,p2...) for phrase independence.
	;	     Also converted msgid from RMnnnn to nnnn.
	;
	; 10/16/93  Frank Prendergast - I18N#18
	;
	; 	    Change call to DBSMBAR from DBSMENU
	;	    Text moved to ^STBL("MBAR",25)
	;	    Added $$^MSG("DQ519"-521)
	;
	; 12/12/92 - Allan Mattson - I18N#7
	;
	;            Modified return message handling with a call to extrinsic
	;            function $$^MSG(msgid,p1,p2...) for I18N development
	;            (phrase independence).
	;----------------------------------------------------------------------
	;
	N $ZT
	S X=$P($G(^CUVAR("%ET")),"|",1) I X="" S X="ZE^UTLERR"
	S $ZT=$$SETZT^%ZT(X)
	;
LOOP	;
	S X=$G(^TMP("SUBPROC",$I)) Q:X=""  ; 		No request to process
	;
	S NAME=$$GETNAME ;				Get process ID
	;
	S CPID=$P(X,"|",2),CHOICE=$P(X,"|",3)
	S INPUT=$G(^TMP("SUBPROC",$I,0))
	;
	S ^TMP("SUBPROC",$I,$J,0)=CPID ;		Save return PID address
	S ^TMP("SUBPROC",$I,$J,1)=NAME_"|"_CHOICE ;	ID this process
	;
LOOP1	I CHOICE="New_Menu" S CHOICE="" ;		Call menu system
	D ATTACH^SCADRV(CPID,CHOICE,INPUT) ; 		Call driver
	;
	S TOPPID=$P($G(^TMP("SUBPROC",$I)),"|",1)
	I TOPPID="" D NOTOPMSG Q  ;			Top process is gone
	;
	S CPID=^TMP("SUBPROC",$I,$J,0) ;		Get calling process
	S NAME=$P(^(1),"|",1)
	;
	; Allow deletion or suspension.
	; If deleting, return through top to caller.
	; If suspending, return directly to caller.
	; If caller doesn't exist, return to top.
	; 
	K OP
	I $$PRCNAM(CPID)="" S CPID=TOPPID ;		Caller is gone
	S X=^TMP("SUBPROC",$I,CPID,1)
	; Returning to ~p1.  Delete ~p2.
	S MSG=$$^MSG(2420,$$FMTOP(X),NAME)
	S OP=$$^DBSMBAR(1)
	;
	I OP="" G LOOP1
	I OP=1 K ^TMP("SUBPROC",$I,$J) ;		Leaving, delete it
	I  S $P(^TMP("SUBPROC",$I),"|",4)=CPID ;	Inidicate caller to top
	I  H  ;						Delete this process
	;
	S ^TMP("SUBPROC",$I,$J,1)=NAME_"|*" ;		Suspend this process
	S X=$$CONNECT(CPID) ;				Re-connect to caller
	;
	G LOOP ; 					Loop back to the top
	;
	;----------------------------------------------------------------------
ATTACH(ref,input)	; Connect or re-connect to main process or a sub-process 
	;----------------------------------------------------------------------
	; Called by ^DBSCRT and ^SCADRV2
	;
	N PID,TOPPID
	I $G(%FN)="" S %FN=$P($$GETTMP^SCADRV0(),"|",6)
	;
	I %FN="" S %FN="Menu"
	;
	; Set up top level if this is the first call off
	U 0
	I $G(^TMP("SUBPROC",$I))="" S ^TMP("SUBPROC",$I)=$J
	I  S ^TMP("SUBPROC",$I,$J,1)="TOP"
	S TOPPID=$P(^TMP("SUBPROC",$I),"|",1)
	;
	S $P(^TMP("SUBPROC",$I,$J,1),"|",2)=%FN ;	Current function
	;
	S PID=$$OPTION ;				Get connect option
	I PID="" Q "" ;					Quit if none
	;
	S PID=$$NEWPRC ;				Set up new process
	;
	; If connecting to existing process, can do that from any other.
	; If spawning new process, do it from the top only
	;
	I 'PID,TOPPID'=$J Q $$ATTACH^%ZFUNC($$PRCNAM(TOPPID)) ; Re-attach top
	S X=$$CONNECT(PID)
	I TOPPID'=$J Q X ;				Not top process
	;
ATTACH1	; Top process loops here to spawn new process or re-connect
	S PID=$P(^TMP("SUBPROC",$I),"|",4)
	I PID="" Q X ;					No new request
	S $P(^TMP("SUBPROC",$I),"|",4)="" ;		Clear request flag
	I PID=$J Q X ;					Already at top
	I PID=0 S PID="" ;				New process
	S X=$$CONNECT(PID) ;				Spawn new or re-connect
	G ATTACH1
	;
NEWPRC()	; Set up for new process if necessary
	;
	; If re-attaching to New_Menu process, treat as new process
	I PID,$P($G(^TMP("SUBPROC",$I,PID,1)),"|",2)'="*" Q PID ; Re-attaching
	;
	N TOPCNCT
	S TOPCNCT=$S(TOPPID'=$J:0,1:"")
	S $P(^TMP("SUBPROC",$I),"|",2,4)=$J_"|New_Menu|"_TOPCNCT
	S ^TMP("SUBPROC",$I,0)=$G(input)
	Q $S(PID:PID,1:"")
	;
	;----------------------------------------------------------------------
OPTION()	;  Get choice of process to attach to or create
	;----------------------------------------------------------------------
	;
	N OP,PID,X,NEWMEN,CT,I,VAR,MASK
	;
	S NEWMEN=0,CT=1 F I=2:1:20 S (VAR(I),MASK(I))=""
	S X=^TMP("SUBPROC",$I,$J,1)
	; ~p1(current)
	S VAR(1)=$$^MSG(3099,$P(X,"|",1)) ;	Current proc first
	;
	I ref'="" D HYPERFUN(ref) ;			Linked functions
	;
	; Add open sub-processes to the menu list
	S PID=0
	F  S PID=$O(^TMP("SUBPROC",$I,PID)) Q:PID=""  D OPTADD
	;
	I 'NEWMEN S CT=CT+1,(VAR(CT),OP(CT))="NEW_MENU" K MASK(CT) ;	Add new menu if not one
	;
	S OP=$$^DBSMBAR(25,"",.MASK,"",.VAR) I 'OP Q ""
	S OP(1)=""     ;  *** XUS 12/13/94
	Q OP(OP)
	;
OPTADD	; Add option to list
	Q:PID=$J
	N X
	S X=$G(^TMP("SUBPROC",$I,PID,1)) Q:X=""
	I $P(X,"|",2)="*" S NEWMEN=1,$P(X,"|",2)="NEW_MENU"
	S CT=CT+1,VAR(CT)=$$FMTOP(X),OP(CT)=PID K MASK(CT)
	Q
	;
FMTOP(opt)	; Format option
	; opt = name|function
	Q $P(opt,"|",1)_$S($P(opt,"|",2)="":"",1:"_at_"_$P(opt,"|",2))
	;
	;----------------------------------------------------------------------
HYPERFUN(ref)	; Hyper-Inquiry for FILE.FIELD
	;----------------------------------------------------------------------
	;
	I $G(%FN)="" Q
	;  
	N X,I
	S ref=$$DINAM(ref)
	F I=1:1 S X=$G(^SCATBL(5,%FN,ref,I)) Q:X=""  S CT=CT+1,VAR(CT)=X
	Q
	;
	;----------------------------------------------------------------------
CONNECT(pid)	; Connect to process
	;----------------------------------------------------------------------
	; Returns 1 if successful, message if fails
	; The symbol GM must be defined
	N RM,PRCNAM,CMD
	;
	I pid=$J Q 1 ;				     This process, don't attach
	;
	I pid="" S CMD=$G(^CUVAR("IMAGESYMBL")) ;    Image spawner symbol
	I  Q $$SPAWN^%ZFUNC("^DBSSPAWN",CMD) ;	     Create new process
	;
	S PRCNAM=$$PRCNAM(pid)
	I PRCNAM="" K ^TMP("SUBPROC",$I,pid) Q RM ;  Invalid process
	;
	;W $$CLEAR^%TRMVT
	Q $$ATTACH^%ZFUNC(PRCNAM) ;		     Attach to existing proc
	;
	;----------------------------------------------------------------------
PRCNAM(x)	; Return the process name that corresponds to the process number 
	;----------------------------------------------------------------------
	;
	N $ZT
	S $ZT=$$SETZT^%ZT("PRCERR^DBSSPAWN")
	;
	Q $$GETJPI^%ZFUNC($G(x),"PRCNAM")
	;
PRCERR	; Error finding process name, nonexistent process
	;
	; Nonexistent session
	S RM=$$^MSG(2014)
	Q ""
	;
	;----------------------------------------------------------------------
GETNAME()	; Get name for this process
	;----------------------------------------------------------------------
	N MSG,NAME,NAMES,N
	S N=0
	F  S N=$O(^TMP("SUBPROC",$I,N)) Q:N=""  S NAMES($P(^(N,1),"|",1))=""
	; Enter new session ID:  
	S MSG=$$^MSG(7218)
	S NAME=$P($G(^TMP("SUBPROC",$I,$J,1)),"|",1)
	I NAME'="" K NAMES(NAME)
	E  S NAME=$$PRCNAM^%ZFUNC
GETLP	W $$BTM^%TRMVT,MSG,$$CPS^%TRMVT,NAME,$$CPR^%TRMVT
	S NAME=$$TERM^%ZREAD(NAME,15,""," ",$G(%TO),1)
	I NAME="" S NAME=$$PRCNAM^%ZFUNC
	; Duplicate ID.  Enter session ID:  
	I $D(NAMES(NAME)) S MSG=$$^MSG(7217) G GETLP
	Q NAME
	;
	;----------------------------------------------------------------------
NOTOPMSG	; Handle notification that there is no top process
	;----------------------------------------------------------------------
	N MSG,N
	; this session
	S N=$S($G(NAME)="":$$^MSG(7220),1:NAME)_"."
	; No TOP session.  Deleting ~p1
	S MSG=$$^MSG(7219,N)
	W $$MSG^%TRMVT(MSG,1,1,1,24,$G(%TO),1)
	Q
	;
	;----------------------------------------------------------------------
DINAM(x)	; Parse and normalize data item name syntax 
	;----------------------------------------------------------------------
	;
	I x?1"["1E.E1"]".E S:$P(x,"]",1)["," x="["_$P(x,",",2,99) Q $E($P(x,"]",1),2,999)_"."_$P(x,"]",2,99)
	I x?1"[]"1E.E Q $G(DFID)_"."_$E(x,3,999)
	Q x
