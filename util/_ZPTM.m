%ZPTM	;Private;Non-native transaction processing utilties
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 07/28/94 08:56:28 - SYSRUSSELL
	; ORIG:  Dan S. Russell (2417) - 01/25/89
	;
	; Various utilities functions (extrinsic and otherwise) for use in 
	; non-native interfaces.  Called by PTMPH protocol handlers
	;
	; The devices used by this process will generally be mailboxes, 
	; although for testing terminal IO or RMS files may be used.
	;
	; Basic flow is that a common device (CIO) will be used as well a 
	; specific input and output devices to allow communcations between a 
	; Transaction (TM) Manager which talks to the foreign side and the 
	; Protocol Handler (PH) which talks to the PROFILE side.
	;
	; The TM will place the name of an input and output device (IIO/OIO) 
	; into CIO.  This will be read by the PH, which will then use IIO and 
	; OIO to both get its input and to direct its output.
	;
	; All reading and writing by the PH will be handled by calls to various 
	; sections of this routine, as will the opening of the CIO.
	;
	; TM will be responsible for creation and deletion of all mailboxes.  
	; PH will just open, read, write, and close.
	;
	; General flow steps:
	;
	;   1)  TM write input message to IIO
	;   2)  TM writes name of IIO and OIO to CIO
	;   3)  PH read IIO and OIO from CIO
	;   4)  PH read input message from IIO
	;   5)  PH writes output message to OIO
	;   6)  TM reads output message from OIO
	;
	;---- Revision History ------------------------------------------------
	;
	; 07/28/94 - RUSSELL
	;            Added error trap around READ.  Receiving sporadic noname
	;            error at Bermuda.
	;            
	;----------------------------------------------------------------------
	;
	;
OPENQT(QT,RECSIZ,TMID,PH)	; Open mailbox for queue type specified by QT.
	;
	; Parameters:     QT - Queue type (req'd)
	;             RECSIZ - Message record size (default = 2561)
	;               TMID - Transaction manager ID (req'd if QT="VT")
	;                 PH - Protocol Handler Number (req'd if QT="VT")
	;
	; If the QT is virtual (i.e., QT="VT"), a common mailbox is
	; not opened.  In this case, messages are delivered directly
	; to the in mailbox associated with a particular PH.  If the
	; QT is other than virtual, a common mailbox will be opened.
	;
	; For queue types other than virtual:
	;
	; Will return variable CIO which will contain channel of the common
	; mailbox.  This variable will not be used by PH, but must be
	; protected as it will be used by the READ and WRITE sections
	; of this routine.
	;
	; Mailbox logical will be MBX$'QT'_COMMON_'DIRID', where QT is queue 
	; type and DIRID is directory ID from ^CUVAR("PTMDIRID"), e.g.
	; MBX$DS_COMMON_PRD for Datasaab in the production directory.
	;
	; For virtual queue types:
	;
	; Will return variables IIO and OIO which will contain channel of
	; the in (IIO) and out (OIO) mailboxes.  These variables will not
	; be used by PH, but must be protected as it will be used by the
	; READVT and WRITE sections of this routine.
	;
	; Mailbox logical will be MBX$IN_'DIRID'_'TMID'_'n', where TMID is
	; the transaction manager ID and n is the number of the in mailbox,
	; e.g. MBX$IN_PRD_ISC_0 for an ISC transaction manager.
	;
	; Call by:  S X=$$OPENQT^%ZPTM("DS") I 'X device didn't open
	;      or   I '$$OPENQT^%ZPTM("DS") device didn't open
	;
	N X
	;
	; Open permanent mailbox, channel=CIO, max message length=2561
	N DIRID S DIRID=$$DIRID^PTMUTLS I DIRID="" Q 0
	I '$G(RECSIZ) S RECSIZ=2561
	;
	; Virtual TM
	I QT="VT" DO  Q X
	.I $G(TMID)=""!($G(PH)="") S X=0 Q
	.S X=DIRID_"_"_TMID_"_"_PH,IIO="MBX$IN_"_X,OIO="MBX$OUT_"_X
	.S X=$$OPEN^%ZMBX(IIO,"PRMMBX/RECORD="_RECSIZ) I X?1"0|".E S X=0 Q
	.S X=$$OPEN^%ZMBX(OIO,"PRMMBX/RECORD="_RECSIZ) I X?1"0|".E S X=0 Q
	.S X=1
	;
	; Non-virtual TM
	S CIO="MBX$"_QT_"_COMMON_"_DIRID
	S X=$$OPEN^%ZMBX(CIO,"PRMMBX/RECORD="_RECSIZ)
	I X?1"0|".E Q 0 ; Did not open
	Q 1 ; Success
	;
READ(RECSIZ)	; Read input message (non-virtual queue type)
	; 1)  Read IIO and OIO channels from common mailbox CIO.  Format is
	;     logical name of IIO|logical name of OIO
	;
	;     - OR -
	;
	;     Contents may be stop command for PH, in which case format is
	;     *Stop requested by user uid.  * in front is required to signal
	;     that this is a command and no in/out pair will be used.  In
	;     this case the message in common mailbox is passed, as is, to
	;     the PH.
	;
	; 2)  Open both input and output mailboxes.  Process must keep
	;     out box open until done since Transaction Manager may need
	;     to see if process still active based on out box being opened
	;
	; 3)  Read input message from IIO.
	;
	; NOTE:  Under GT.M channels are not used, only names are used.
	;        All PTM mailbox reads are synchronous reads.
	;
	; Call by:  D READ^%ZPTM(RECSIZ)
	;   Input:  CIO - must be open
	;  Output:  IIO             - logical name for input mailbox
	;           OIO|channel     - logical name & channel for out box
	;           IM              - text string containing input message
	;           ER = 1          - unable to open input mailbox
	;              = 2          - unable to open output mailbox
	;
	S ER=0
	N $ZT S $ZT="G READER"
	N X U CIO R X
	I X="" S IM="" Q  ; No input message
	I $E(X)="*" S IM=X,(IIO,OIO)="" Q  ; Command message to PH
	;
	I '$G(RECSIZ) S RECSIZ=2561
	S IIO=$P(X,"|",1),OIO=$P(X,"|",2)
	S X="IIO:(PRMMBX:BLOCKSIZE="_RECSIZ_"):2" O @X E  S ER=1 Q
	;
	U IIO R IM:1
	C IIO:DELETE
	S X="OIO:(PRMMBX:BLOCKSIZE="_RECSIZ_"):2" O @X E  S ER=2 Q
	Q
	;
READER	; If error on read, return as if no input, but log info
	S IM=""
        S ^PTMPHDS(+$H,$P($H,",",2),$J)=$ZS
	D ZE^UTLERR
	Q
	;
WRITE	; Write output contained in OM to OIO (non-virtual queue type)
	;
	; Call by:  D WRITE^%ZPTM
	;   Input:  OIO         - logical name for output mailbox
	;           OM or OM(n) - output message
	;
	;  Output:  ER = 1      - OIO not defined or OPEN failed
	;              = 2      - Write to mailbox failed
	;
	I '$D(OIO) S ER=1 Q
	;
	N $ZT S $ZT="D ZE^UTLERR S ER=1 G CLOSE"
	U OIO W $G(OM)
	;
CLOSE	I ER S ER=2
	C OIO:DELETE
	Q
	;
READVT	; Read input message (virtual queue type)
	; Re-direct subsequent I/O to NULL device
	U IIO R IM O "NL:" U "NL:"
	Q
	;
WRITVT	; Read input message (virtual queue type)
	; Re-direct subsequent I/O to NULL device
	U OIO W OM O "NL:" U "NL:"
	Q
	;
CLOSVT(IIO,OIO)	; Close input/output maibox(es), mark for deletion
	I $G(IIO)'="" C IIO:DELETE
	I $G(OIO)'="" C OIO:DELETE
	Q
