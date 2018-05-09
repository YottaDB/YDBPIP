%MPRCMON	;;Private;PROFILE MUMPS Process Monitoring Routine
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/06/97 11:21:35 - CHENARD
	; ORIG:	CHENARD
	; DESC:	Process Status Monitoring Routine 
	;	This monitoring routine will monitor the following varibles:
	;	1. Process ID
	;	2. State
	;	3. CPU Time
	;	4. Disk I/Os to pages not loaded in core
	;	5. The real memory size of the process
	;	6. The virtual size of the data section of the process
	;	7. Percentage time in CPU
	;	8. Percentage time in Memory
	;	
	;	9. There is a timeout period for each cycle of data display.
	;
	; Keywords: System
	;	
	; UNIX - Specific Version
	;
	;
        ;---- Revision History ------------------------------------------------
	;
	; 11/06/01 - Harsha Lakshmikantha - 46174
	;	     Modified MAIN section to use the "-efw" option for the "ps"
	;	     command on Linux platforms. The "-w" option produces wide
	;	     output so that the command is not truncated.
	;
	;----------------------------------------------------------------------
	;	
MAIN	;----------------------------------------------------------------------
	; Main routine, infinite loop, Crl/Z to stop the loop and quit.
	; need to unlock screen before quit this routine
	;----------------------------------------------------------------------
	;
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZT^%MPRCMON")
	;
	;
	N CMD,IO,PIDS,SYS
	N CPUPRCNT,CPUPRCNT1,CPUTIME,CPUTIME1,PGIN,PGIN1,PID,PID1
	;
	S IO=$$HOME^%TRNLNM("PIDLIST.OUT")
	S CMD="ps -ef | grep mumps >"_IO
	S SYS=$$^%ZSYS
	I SYS="LINUX" S CMD="ps -efw | grep mumps >"_IO
	ZSY CMD
	S x=$$FILE^%ZOPEN(IO,"READ") Q:'x
	;
	N done,pid,name
	F  S X=$$^%ZREAD(IO,.ET) Q:+ET  D
	.	S done=0
   	.   	F I=1:1 Q:done  D
	..		I $E(X,I)'=" " S done=1 Q
	.	S X=$E(X,I-1,$L(X))
	.	S X=$TR(X," ","|")
	.	S name=$P(X,"|",1),pid=$P(X,"|",2)
	.	Q:pid=$J		;Don't include current process
	.	S PIDS(pid)=name
	.	;
	C IO
	;
	S %TAB("PID")="/DES=Process ID/TYP=T/LEN=12/TBL=PIDS("
	S %READ="@@%FN,,,PID/REQ"
	D ^UTLREAD Q:VFMQ="Q"
	I PID="" Q
	;
	W $$CUOFF^%TRMVT
	;
	D INIT
	;
	F  R *X:2 Q:X=17  D  Q:ER	;only when entry is Ctrl/Q (17).
	.	D DATAREC
	.	D CALC Q:ER
	.	I X=23 D INIT 	;Ctrl/W(23) to refresh the screen
	.	I PID1'=PID D DISPLAY^DBSMACRO("@PID",$J(PID,10))
	.	I STATE1'=STATE D DISPLAY^DBSMACRO("@STATE",$J(STATE,10))
	.	I CPUTIME1'=CPUTIME D DISPLAY^DBSMACRO("@CPUTIME",CPUTIME)
	.	I PGIN1'=PGIN D DISPLAY^DBSMACRO("@PGIN",$J(PGIN,10))
	.	I SIZE1'=SIZE D DISPLAY^DBSMACRO("@SIZE",$J(SIZE,10))
	.	I RSS1'=RSS D DISPLAY^DBSMACRO("@RSS",$J(RSS,10))
	.	I LIM1'=LIM D DISPLAY^DBSMACRO("@LIM",$J(LIM,21))
	.	I TSIZ1'=TSIZ D DISPLAY^DBSMACRO("@TSIZ",$J(TSIZ,10))
	.	I TRS1'=TRS D DISPLAY^DBSMACRO("@TRS",$J(TRS,10))
	.	I CPUPRCNT1'=CPUPRCNT D DISPLAY^DBSMACRO("@CPUPRCNT",$J(CPUPRCNT,10))
	.	I MEMPRCNT1'=MEMPRCNT D DISPLAY^DBSMACRO("@MEMPRCNT",$J(MEMPRCNT,10))
	.	I DATE1'=DATE D DISPLAY^DBSMACRO("@DATE",$J(DATE,8))
	.	D DISPLAY^DBSMACRO("@TIME",$J(TIME,10))	   ;always display 
	;
	W $$CLEAR^%TRMVT
	W $$CUON^%TRMVT
	;
	I 'ER S RM="Monitor Stopped"
	S ER="W"
	Q
	;
	;
INIT	;----------------------------------------------------------------------
	;Set up parameters 
	;-----------------------------------------------------------------------
	S TJD=^CUVAR(2)
	S SID="MPRCMON"  ;Set up SID for monitoring screen name and PGM
	D ^USID			;Get PGM
	S %O=2			;Set up %O=2 for display only
	;
	D CALC		; calculate the values before display
	D VPR^@PGM	; get the text (label) for the screen
	D VDA^@PGM	; get the data for  the screen
	D VTBL^@PGM
	D ^DBSPNT()	; display both test and data on the screen
	;
	S %MAX=$ZP(%TAB(""))	;totoal prompt numbers
	;
	Q
	;
CALC	;-----------------------------------------------------------------------
	; Calculate the data for the monitoring screen.
 	; There are total 10 screen data items:
	;-----------------------------------------------------------------------
	N CMD,cmd,cnt,et,io,rec,x,y
	S (TTY,STATE,CPUTIME,PGIN,SIZE,RSS,LIM,TSIZ,TRS,CPUPRCNT,MEMPRCNT)=0
	S COMMAND=""
	S cnt=0
	;
	; date and time
	S TIME=$$TIM^%ZM($P($H,",",2),"24:60:SS")	;time format 15:34:26
	S DATE=$$DAT^%ZM
	;
	S io=$$HOME^%TRNLNM("mprcmon.out")
	S CMD="ps vw "_PID_" >"_io
	S x=$$SYS^%ZFUNC(CMD) I x S ER=1,RM="Non-existent process" Q
	;
	S x=$$FILE^%ZOPEN(io,"READ") Q:'x
	S x=$$^%ZREAD(io,.et) Q:+et		;1st read - header
	S rec=$$^%ZREAD(io,.et) Q:+et		;2nd read - data
	C io
	S CMD="rm -r "_io
	S x=$$SYS^%ZFUNC(CMD)
	;
	S y=$TR(rec," ","|")
	F i=1:1:$L(y,"|") Q:$G(cnt)>12  S z=$P(y,"|",i) I z'="" D
	.	S cnt=$G(cnt)+1
	.	I cnt=13 S COMMAND=$E($TR($P(y,"|",i,99),"|"),1,60) Q
	.	S $P(fMPRCMON,"|",cnt)=z
 	S fMPRCMON=fMPRCMON_"|"_COMMAND
	S TTY=$P(fMPRCMON,"|",2)
	S STATE=$P(fMPRCMON,"|",3)
	S CPUTIME=$P(fMPRCMON,"|",4)
	S PGIN=$P(fMPRCMON,"|",5)
	S SIZE=$P(fMPRCMON,"|",6)
	S RSS=$P(fMPRCMON,"|",7)
	S LIM=$P(fMPRCMON,"|",8)
	S TSIZ=$P(fMPRCMON,"|",9)
	S TRS=$P(fMPRCMON,"|",10)
	S CPUPRCNT=$P(fMPRCMON,"|",11)
	S MEMPRCNT=$P(fMPRCMON,"|",12)
	;
	S CPUTIME=$ZGETJPI(PID,"CPUTIM")
	Q
	;
DATAREC	;---------------------------------------------------------------------
	; Record the current data value to old_value before the recalculaton.
	; put 1 on the original value as the old value,total 13 items
	; This subroutine is made for repaint screen. 
	;---------------------------------------------------------------------
	S PID1=$G(PID)
	S TTY1=$G(TTY)
	S STATE1=$G(STATE)
	S CPUTIME1=$G(CPUTIME)
	S PGIN1=$G(PGIN)
	S SIZE1=$G(SIZE)
	S RSS1=$G(RSS)
	S LIM1=$G(LIM)
	S TSIZ1=$G(TSIZ)
	S TRS1=$G(TRS)
	S CPUPRCNT1=$G(CPUPRCNT)
	S MEMPRCNT1=$G(MEMPRCNT)
	S COMMAND1=$G(COMMAND)
	S DATE1=$G(DATE)
	Q
	;
	;---------------------------------------------------------------------
ZT	; Log errors
	;---------------------------------------------------------------------
	S ER=1
	D ZE^UTLERR
	Q
