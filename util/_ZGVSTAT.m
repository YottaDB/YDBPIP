%ZGVSTAT(INIT,IO,INT,NUM)	;M Utility;Display $VIEW Statistics
	;;Copyright(c)1995 Sanchez Computer Associates, Inc.  All Rights Reserved - 07/24/95 14:36:55 - CHENARD
	; ORIG:  CHENARD - 18 OCT 1990
	;
	; This utility displays $VIEW statistics for a specific global 
	; directory in a report format.  The statistics are accumulated
	; from the last time the databases' stats had been initialized.
	;
	; KEYWORDS:	System services
	;
	; ARGUMENTS:
	;	. INIT	Initialization flag, determines whether the current
	;		$VIEW statistics are zeroed out for this report.
	;		When the value is 1, statistics are initialized.
	;					/TYP=L/REQ/MECH=VAL
	;
	;	. IO	RMS file name used to output report.  If value
	;		is null, report will display to the current device.
	;					/TYP=T/REQ/MECH=VAL
	;
	;	. INT	Time interval between report runs, in seconds.  When
	; 		displaying statistics multiple times in succession, this
	;		parameter will determine how much time lapses between
	;		reports.
	;					/TYP=N/NOREQ/MECH=VAL
	;
	;	. NUM	The total number of times the report should be run.
	;					/TYP=N/NOREQ/MECH=VAL
	;
	;   EXAMPLE:  
	;	D ^%ZGVSTAT(1,"")	;initializes the statistics
	;	D ^%ZGVSTAT(0,"")	;runs the $VIEW report once to terminal
	;	D ^%ZGVSTAT(0,"X.X")	;outputs the report to RMS file X.X
	;	D ^%ZGVSTAT(0,"",120,5) ;runs 5 times, two minutes apart 
	;
	;
	;-----Revision History--------------------------------------------------
	;
	;-----------------------------------------------------------------------
INIT	N (INIT,IO,INT,NUM)
	;
	D TERM^%ZUSE(0,"ECHO/ESCAPE/NOEDIT/NOIMAGE/WIDTH=81/TERMINATOR=$C(11,13,16,23)")
	;
	S GBLDIR=$ZGBLDIR,%EXT=0
	S:'$G(INT) INT=0 S:$G(INT) %EXT=1
	I $G(IO)="" S IO=$I
	I IO'=$I S X=$$FILE^%ZOPEN(IO,"WRITE/NEWV"),%EXT=1
	E  S X=$$TERM^%ZOPEN(IO,"WRITE")
	S NODE=$$NODENAM^%ZFUNC
	W $$GREN^%TRMVT
	D TERM^%ZUSE(IO,"WIDTH=132")
	S REGION=$V("GVFIRST")    ; get the first region in the current global directory
	I REGION="" S ER=1,RM="No regions in current global directory "_GBLDIR Q
	;
	I %EXT,INIT=0,'INT D HDR1,DSP C IO D EXIT Q
	I %EXT,INIT=0,INT S:'$G(NUM) NUM=2 S CNT=0 D TIM1 C IO D EXIT Q
	I %EXT,INIT=1 S OPT="Z" D ZERO,HDR1,DSP C IO D EXIT Q
	D HDR1,DSP
	;
OPT	W $$BTMXY^%TRMVT
	R !,"Zero statistics, (Z), Display current statistics, (D) or Display in time intervals (I)?  D=> ",OPT
	S OPT=$S(OPT="Z":"Z",OPT="z":"Z",OPT="I"!(OPT="i"):"I",1:OPT="D")
	I OPT="Z" D ZERO
	I OPT="I" D TIME
	D HDR1,DSP	
	;
	;-----------------------------------------------------------------------
EXIT	;
	;-----------------------------------------------------------------------
	I %EXT Q
	W !,$$BTMXY^%TRMVT,"End of report, Press RETURN to continue: " R X
	D TERM^%ZUSE(IO,"WIDTH=80")
	W $$SCR80^%TRMVT
	Q
	;
	;-----------------------------------------------------------------------
DSP	; display global statistics report
	;-----------------------------------------------------------------------
	N TSETS,TKILLS,TREADS,TOREAD,TZPREV,TDDATA,TQUERY,TRETRY
	N DATE,%TN,%TIM
	S (TSETS,TKILLS,TREADS,TOREAD,TZPREV,TDDATA,TQUERY,TRETRY)=0
	S DATE=$G(^%GVSTAT(GBLDIR)) I DATE="" S DATE=$H
	S %TN=$P(DATE,",",2) D ^SCATIM1 S DATE=$$DAT^%ZM($P(DATE,",",1))
	W !!,"               Global statistics for ",GBLDIR
	W ", recorded since ",%TS," on ",DATE
	W !!,"Region",?25,$J("Global Sets",15),?40,$J("Global Kills",15),?55
	W $J("Global Reads",15),?70,$J("$Orders",15),?85,$J("$ZPrevious",15)
	W ?100,$J("$Datas",15),?115,$J("$Queries",15)
	W !,$$LINE^%TRMVT(132)
	S REGION=$V("GVFIRST") D GETDATA,DSP1
	F  S REGION=$V("GVNEXT",REGION) Q:REGION=""  D GETDATA,DSP1
	W !,$$LINE^%TRMVT(132)
	W !!,"Totals:",?25,$J($FN(TSETS,","),15),?40
	W $J($FN(TKILLS,","),15),?55,$J($FN(TREADS,","),15),?70
	W $J($FN(TOREAD,","),15),?85,$J($FN(TZPREV,","),15),?100
	W $J($FN(TDDATA,","),15),?115,$J($FN(TQUERY,","),15),!
	Q
	;
	;-----------------------------------------------------------------------
DSP1	;
	;-----------------------------------------------------------------------
	I REMOTE Q
	S DSP="W !,REGION,?25,$J($FN(SETS,"",""),15),?40"
	S DSP=DSP_",$J($FN(KILLS,"",""),15),?55,$J($FN(READS,"",""),15),?70"
	S DSP=DSP_",$J($FN(OREAD,"",""),15),?85,$J($FN(ZPREV,"",""),15),?100"
	S DSP=DSP_",$J($FN(DDATA,"",""),15),?115,$J($FN(QUERY,"",""),15)"
	X DSP
	Q
	;
	;-----------------------------------------------------------------------
GETDATA	; retrieve global data per region
	;-----------------------------------------------------------------------
	D REGCK I REMOTE Q
	S DATA1=$G(^%GVSTAT(GBLDIR,REGION))
	S SETS1=$P(DATA1,",",1),SETS1=$P(SETS1,":",2)
	S KILLS1=$P(DATA1,",",2),KILLS1=$P(KILLS1,":",2)
	S READS1=$P(DATA1,",",3),READS1=$P(READS1,":",2)
	S OREAD1=$P(DATA1,",",4),OREAD1=$P(OREAD1,":",2)
	S QUERY1=$P(DATA1,",",5),QUERY1=$P(QUERY1,":",2)
	S ZPREV1=$P(DATA1,",",6),ZPREV1=$P(ZPREV1,":",2)
	S DDATA1=$P(DATA1,",",7),DDATA1=$P(DDATA1,":",2)
	S RETRY1=$P(DATA1,",",8),RETRY1=$P(RETRY1,":",2)
	;
	S DATA2=$V("GVSTAT",REGION)
	S SETS2=$P(DATA2,",",1),SETS2=$P(SETS2,":",2)
	S KILLS2=$P(DATA2,",",2),KILLS2=$P(KILLS2,":",2)
	S READS2=$P(DATA2,",",3),READS2=$P(READS2,":",2)
	S OREAD2=$P(DATA2,",",4),OREAD2=$P(OREAD2,":",2)
	S QUERY2=$P(DATA2,",",5),QUERY2=$P(QUERY2,":",2)
	S ZPREV2=$P(DATA2,",",6),ZPREV2=$P(ZPREV2,":",2)
	S DDATA2=$P(DATA2,",",7),DDATA2=$P(DDATA2,":",2)
	S RETRY2=$P(DATA2,",",8),RETRY2=$P(RETRY2,":",2)
	;
TOTAL	S SETS=SETS2-SETS1,TSETS=TSETS+SETS
	S KILLS=KILLS2-KILLS1,TKILLS=TKILLS+KILLS
	S READS=READS2-READS1,TREADS=TREADS+READS
	S OREAD=OREAD2-OREAD1,TOREAD=TOREAD+OREAD
	S DDATA=DDATA2-DDATA1,TDDATA=TDDATA+DDATA
	S ZPREV=ZPREV2-ZPREV1,TZPREV=TZPREV+ZPREV
	S QUERY=QUERY2-QUERY1,TQUERY=TQUERY+QUERY
	S RETRY=RETRY2-RETRY1,TRETRY=TRETRY+RETRY
	;
	Q
	;-----------------------------------------------------------------------
ZERO	; Reset GVSTAT numbers to current values
	;-----------------------------------------------------------------------
	K ^%GVSTAT(GBLDIR)
	S ^%GVSTAT(GBLDIR)=$H
	S REGION=$V("GVFIRST") D REGCK
	I 'REMOTE S ^%GVSTAT(GBLDIR,REGION)=$V("GVSTAT",REGION)
	F I=1:1 S REGION=$V("GVNEXT",REGION) Q:REGION=""  D
	.	D REGCK 
	.	Q:REMOTE
	.	S ^%GVSTAT(GBLDIR,REGION)=$V("GVSTAT",REGION)
	Q
	;
	;-----------------------------------------------------------------------
REGCK	; check for remote regions
	;-----------------------------------------------------------------------
	S REMOTE=0
	S FILE=$V("GVFILE",REGION),FILE=$P($ZPARSE(FILE),";",1)
	S REMOTE=FILE["::"
	I REMOTE S DSP="W !,REGION,"" is on remote node.""" 
	Q
	;
	;-----------------------------------------------------------------------
HDR1	;
	;-----------------------------------------------------------------------
	W $$CLEAR^%TRMVT
	W $$SCR132^%TRMVT
	S X="                 *** Global Statistic Information for "_$P($ZPARSE(GBLDIR),";",1)_$S(NODE'="":" on node "_NODE,1:" ")_" ***" 
	W !!,X
	W !,$$LINE^%TRMVT(132)
	Q
	;
	;-----------------------------------------------------------------------
TIME	; determine time interval between reports
	;-----------------------------------------------------------------------
	N INT,NUM,CNT
	S CNT=0
	R !,"Enter time interval in seconds between reports: ",INT
	R !,"How many reports do you wish to display before quitting? ",NUM
	S NUM=NUM-1
TIM1	F  S CNT=CNT+1 D HDR1,DSP H INT Q:CNT=NUM
	Q

