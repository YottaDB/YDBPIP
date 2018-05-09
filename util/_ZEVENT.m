%ZEVENT	;Private;Utility to manage process interrupt messages for PROFILE
	;;Copyright(c)1995 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/20/95 17:55:30 - SYSRUSSELL
	; ORIG:  Frank R. Sanchez (2497) - 06/07/87
	;
	;***********************************************************************
	; NOTE:  This utility is no longer used in versions 5.0 and beyond.
	;        The routine must be retained for backwards compatibility.
	;***********************************************************************
	;
	; Sets global ^EVENT(EVENT,E1) = EVENTNAM
	;                         ,E1, FUN/UID/LOC) = ""
	;
	;           where E1 = 1-Functions, 2-Users, 3-Locations
	;
	; INPUTS:
	;	. EVENTDIR	Event directory or 'All' or @LOGICAL or A|B|C
	;	. EVENTFUN	Event function or 'All' or @LOGICAL or A|B|C
	;	. EVENTUID	Event userid or 'All' or @LOGICAL or A|B|C
	;	. EVENTLOC	Event location or 'All' or @LOGICAL or A|B|C
	;	. EVENTNAM	Event name:
	;                         NETWORK   - Change in network status
	;                         MAIL      - Mail
	;                         BROADCAST - Broascast message|message
	;                         SPECIAL   - Special function|(Xecute)
	;
	I '$D(EVENTNAM) S ER=1,ET="UNDEF" D ^UTLERR Q
	I '$D(EVENTDIR) D INT^%DIR S EVENTDIR=%DIR
	S EVENTNAM=$TR($E(EVENTNAM),"nmbs","NMBS")_$S($D(%UID):%UID,1:"System")_"|"_$P(EVENTNAM,"|",2,999)
	I "NMBS"[$E(EVENTNAM)=0 S ER=1,ET="EVENTERR" D ^UTLERR Q
	I '$D(EVENTFUN),'$D(EVENTUID),'$D(EVENTLOC) S ER=1,ET="EVENTERR" D ^UTLERR Q
	;
	N E,I,N,M
	S E=EVENTDIR,E1=0,(N,M)="" D EVENTDIR Q:'$D(E)
	I $E(EVENTNAM)="N" D NETWORK Q:'$D(E)
	;
	ZA ^EVENT S EVENT=$G(^EVENT)+1,^EVENT=EVENT ZD ^EVENT
	;
	I $D(EVENTFUN) S E=EVENTFUN,E1=1 D LOAD
	I $D(EVENTUID) S E=EVENTUID,E1=2 D LOAD
	I $D(EVENTLOC) S E=EVENTLOC,E1=3 D LOAD
	;
	K EVENTFUN,EVENTUID,EVENTLOC,EVENTNAM,EVENTDIR
	;
EVENTDIR	; Load the directory array E(0)
	;
	I E="ALL" S E="" F  S E=$O(^%ZDDP("DDP",E)) Q:E=""  S E(E)=""
	I  D FEPSTOO Q
	F I=1:1 S X=$P(E,"|",I) Q:X=""  D EVENTDA
	Q
EVENTDA	;
	;
	I $E(X)="@"=0 S E(X)="" Q
	S X=$E(X,2,999) F  S N=$O(^UTBL("EVENT",0,X,N)) Q:N=""  S E(N)=""
	Q
	;
FEPSTOO	; Load in FEP directories also
	;
	Q
LOAD	; 1=Functions, 2=Users, 3=Locations
	S E=$$UPPER^%ZFUNC(E) F  S N=$O(E(N)) Q:N=""  D SET
	Q
	;
SET	; Set event entries into each directory
	N Z S Z=$$GBLDIR^DDPUTL(N)
	S ^[Z]EVENT(EVENT,E1)=EVENTNAM I E="ALL" Q
	F I=1:1 S X=$P(E,"|",I) Q:X=""  D SETA
	Q
	;
SETA	;
	I $E(X)="@"=0 S ^[Z]EVENT(EVENT,E1,X)="" Q
	S X=$E(X,2,999)
	F  S M=$O(^UTBL("EVENT",E1,X,M)) Q:M=""  S ^[Z]EVENT(EVENT,E1,M)=""
	Q
	;
NETWORK	; Test the network status and toggle if appropriate
	I ^%ZDDP("DDP")="HOST" K E Q
	;
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZTNET^%ZEVENT")
	;
	I ^[$$GBLDIR^DDPUTL("HOSTIBS")]%ZDDP("%NET")
	S ^%ZDDP("%NET")=1
	Q
	;
ZTNET	; Network error encountered tryiny to read ^%ZDDP
	I ^%ZDDP("%NET")=0 K E ; Network is already marked offline
	S %NET=0,^%ZDDP("%NET")=0
	Q
