%ZQUERUN	;Private;Run job ques on front-ends
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/04/94 22:01:26 - SYSRUSSELL
	; ORIG:  Frank R. Sanchez (2497) - 04/01/86
	;
	; KEYWORDS:	Front Ends
	;
	I $D(^%X)&('$D(%QN)) S %QN=$O(^%X("")) I %QN]"" K ^(%QN)
	Q:'$D(%QN)  Q:%QN=""
	;
	S %QS=0
	;
A	;
	K (%QN,%QS) I '($D(%QN)&$D(%QS)) G END
	;
	N $ZT
	S $ZT="ZG "_$ZL_":ZT^%ZQUERUN"
	;
	N HOSTNAME
	S HOSTNAME=$G(^%ZDDP("HOSTNAME")) I HOSTNAME="" S HOSTNAME="HOST"
	;
	S %QS=$O(^[HOSTNAME]%ZQUE(%QN,%QS)) I %QS="" G END
	;
	S %GLO="^["""_HOSTNAME_"""]%ZQUE(%QN,%QS," D ^%ZULVLOD
	;
	I $D(POP) D ^SCAIO
	S X=^[HOSTNAME]%ZQUE(%QN,%QS),XECUT=$P(X,"|",1)
	D FEPNAM S ^[HOSTNAME]%ZQUE(%QN,0,FN,%QS)=$H
	I XECUT'?.E1" ".E S XECUT="D "_XECUT
	S %EXT=1 X XECUT
	D FEPNAM S $P(^[HOSTNAME]%ZQUE(%QN,0,FN,%QS),"|",2)=$H
	G A
	;
ZT	; ERROR TRAP
	I $D(IO) C IO
	S ERROR=$$ETLOC^%ZT
	I ERROR="FILE_PROTECTION"!(ERROR="NETWORK_ERROR") O 1::0 U 1 W ERROR C 1 H
	Q:'$D(%QN)  Q:'$D(%QS)
	D FEPNAM S $P(^[HOSTNAME]%ZQUE(%QN,0,FN,%QS),"|",2)=$ZS
	G A
	;
FEPNAM	; Get the current front end name
	;
	I '$D(%DIR) D INT^%DIR
	S FN=$P(^%ZDDP("DDP",%DIR),"|",3) Q
	;
END	H
