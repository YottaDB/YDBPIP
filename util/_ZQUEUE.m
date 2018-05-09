%ZQUEUE	;Library;Handling for VMS print queues
	;;Copyright(c)1996 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/10/96 08:27:53 - CHENARD
	; ORIG:  Dan S. Russell (2417) - 10/31/91
	;
	; Handle VMS print queue requirements.  Used by ^SCAIOQ for print
	; queue control through PROFILE.
	;
	; KEYWORDS:	Device handling
	;
	; LIBRARY:
	;
	;	. SETPARAMS	Returns list of valid queue parameters with 
	;			characteristics to be used by ^SCAIOQ
	;
	;	. $$SEND	Sends RMS file IO to print queue QUEUE
	;
	;----------------------------------------------------------------------
SEND(IO,QUEUE,PARAMS,DELETE)	;System;Dispatch RMS file to print queue
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Device handling
	;
	; ARGUMENTS:
	;	. QUEUE		Print queue name	/TYP=T/NOREQ/
	;						/DEF=stdprint
	;
	;	. PARAMS	Valid options		/TYP=CMDLIN
	;			Passed in as "/" separated 
	;			list.  Invalid parameters are 
	;			ignored.  Takes first match, so
	;			minimum of 4 characters should 
	;			be used.  See VMS documentation
	;			for parameter info.  Parameters:
	;
	;			  COPIES		DEF=1
	;			  FORM
	;			  CHARACTERISTICS
	;			  NAME			DEF=USERNAME_%FN
	;			  NOTE
	;			  SETUP		
	;			  HOLD			DEF=0
	;			  OPERATOR	
	;			  NOTIFY		DEF=0
	;			  PRIORITY
	;			  RESTART		DEF=1
	;
	;	. DELETE	Delete IO on completion	/TYP=L/NOREQ/DEF=0
	;
	; RETURNS:
	;	. $$		Success indicator	/TYP=L
	;			  1 => success
	;			  0 => failure
	;
	; EXAMPLE:
	;	S X=$$SEND^%ZQUEUE(RMS,"SYS$PRINT","FORM=123/NAME=TEST",1)
	;
	;----------------------------------------------------------------------
	N X
	I $G(IO)="" Q "0|No RMS file specified"
	I $G(QUEUE)="" Q "0|No printer specified"
	S DELETE=+$G(DELETE)
	S PARAMS=$$PARAMS(PARAMS)
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ERROR^%ZQUEUE")
	S CMD="$SCA_RTNS/uxprint "_QUEUE_" "_IO_" "_PARAMS
	I DELETE S CMD=CMD_" ;rm "_IO
	S X=$$SYS^%ZFUNC(CMD)
	Q 1 ;						Success
	;
	;----------------------------------------------------------------------
ERROR	; Trap for error on close
	;----------------------------------------------------------------------
	Q "0|"_$$ETLOC^%ZT ;				Failure
	;
	;----------------------------------------------------------------------
PARAMS(PARAMS)	; Create GT.M parameter string
	;----------------------------------------------------------------------
	; Ignores invalid parameters
	N INFO,I,OUTPARAM,P,P1,P2,PP,N
	S OUTPARAM=""
	D SETPARAMS(.INFO)
	F I=1:1:$L(PARAMS,"/") S P=$P(PARAMS,"/",I) Q:P=""  D
	. 	S P1=$P(P,"=",1),P2=$P(P,"=",2),N=""
	.	I P1["COPIES" S OUTPARAM=OUTPARAM_P2 Q
	.	I P1["NOTIFY" S OUTPARAM=OUTPARAM_" NOTIFY"
	Q OUTPARAM
	;
	;----------------------------------------------------------------------
CHAR	; CHARACTERISTICS parameter must be specified as individual entries
	;----------------------------------------------------------------------
	N I,X
	S P1=""
	F I=1:1 S X=$P(P2,",",I) Q:X=""  S P1=P1_"CHAR="_X_":"
	S P1=$E(P1,1,$L(P1)-1),P2=""
	Q
	;
	;----------------------------------------------------------------------
QUOTES	; Place quotes around parameters expecting an expression
	;----------------------------------------------------------------------
	I $E(P2)'=$C(34) S P2=$C(34)_P2
	I $E(P2,$L(P2))'=$C(34) S P2=P2_$C(34)
	Q
	;
	;----------------------------------------------------------------------
SETPARAMS(X)	;System;Return valid print queue parameters and their characteristics
	;----------------------------------------------------------------------
	;
	; Returns valid print queue parameters, characteristics, and defaults
	; for use by ^SCAIOQ
	;
	; Set up array with necessary info for all parameters
	; Allows validation, %TAB for UTLREAD, and defaulting
	; Data item name for %TAB is always [SCAIOQ]_$E(name,1,8)
	;
	; This information is set up in this manner so that it is in one
	; place in this routine and can be easily changed or added to for
	; other queue characteristics related to other systems, if ever needed
	;
	; KEYWORDS:	Device handling
	;
	; ARGUMENTS:
	;	. X(seq		Sequence number		/TYP=N/MECH:REF:W
	;
	;	. X(seq)	Parameter info		/TYP=T
	;			 = name|length|type|default|
	;			   required|prompt|post_proc|close_code
	;
	S X(1)="COPIES|3|N|1|1|Number of Copies"
	S X(2)="FORM|5|N|||Form Type"
	S X(3)="CHARACTERISTICS|40|T|||Characteristics|D PPCHAR^%ZQUEUE|D CHAR"
	S X(4)="NAME|39|T|$$JOBNAME^%ZQUEUE|1|Job Name||D QUOTES"
	S X(5)="NOTE|40|T|||Note||D QUOTES"
	S X(6)="SETUP|40|T|||Setup Modules|D PPSET^%ZQUEUE|D QUOTES"
	S X(7)="HOLD|1|L|||Hold Print Job"
	S X(8)="OPERATOR|40|T|||Operator Message||D QUOTES"
	S X(9)="NOTIFY|1|L|||Notify on Completion"
	S X(10)="PRIORITY|2|N|||Priority"
	S X(11)="RESTART|1|L|1||Automatic Restart"
	Q
	;
	; -------------- Post Processors --------------------------------------
PPCHAR	; Characteristics - check for numbers 0-127
	;----------------------------------------------------------------------
	Q:X=""
	N I,C
	F I=1:1:$L(X,",") S C=$P(X,",",I) D  Q:ER
	. I C?1.3N,C<128 Q
	. S ER=1,RM="Characteristics must be 0-127"
	Q
	;
	;----------------------------------------------------------------------
PPSET	; Setup - cannot contain spaces
	;----------------------------------------------------------------------
	I X[" " S ER=1,RM="May not contain spaces"
	Q
	;
	; -------------- Default Values ----------------------------------------
JOBNAME()	; Return job name
	;----------------------------------------------------------------------
	N X
	S X=$$USERNAM^%ZFUNC
	I $G(%FN)'="" S X=X_"_"_$G(%FN)
	Q X
