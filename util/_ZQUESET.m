%ZQUESET	;Private;Utility to set up front-end processing queues
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/04/94 21:58:46 - SYSRUSSELL
	; ORIG: Frank R. Sanchez  (2497)
	; 
	; This is a general purpose utility that loads the global
	;   %GLO(KEY1, KEY2, etc.. to a local array
	;
	; KEYWORDS:	Front Ends
	;
	; INPUTS:
	;	. DH		Date & time to start the que
	;	. FEPNAM	If called at linetag FEP
	;	. FEPDIR	If called at linetag FEP
	;	. ROU		Routine name to call
	;	. %V		Variables to save
	;
FEPALL	; Update all FEP's listed in ^%ZDDP("DDP",%DIR
	;
	D SAVE,INT^%DIR S (N,M)=""
	;
	F I=0:0 S N=$O(^%ZDDP("DDP",%DIR,N)) Q:N=""  F I=0:0 S M=$O(^%ZDDP("DDP",%DIR,N,M)) Q:M=""  S ^%ZQUE(0,N,DH,%QN)=M
	Q
	;
FEP	; Set up job que on FEP from HOST processor
	;
	D SAVE S ^%ZQUE(0,FEPNAM,DH,%QN)=FEPDIR Q
	;
SAVE	;
	;
	S %QN=$S($D(^%ZQUE):^%ZQUE,1:0)+1,^%ZQUE=%QN
	S ^%ZQUE(%QN,1)=ROU_"|"_$H
	S %GLO="^%ZQUE(%QN,1," D ^%ZULVSAV Q
