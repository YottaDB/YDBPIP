%ZUPGRD3	;Private;Automated Version Upgrade Project
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/05/94 09:34:38 - SYSRUSSELL
	; ORIG:  Phil Chenard (6938) - 05/01/89
	;
	; Automated PROFILE/IBS version upgrade
	;
	; Global deletions and standard loads performed here.
	; Also, conversion programs are run and post conversion
	; utilities run automatically after upgrade is complete.
	;
GBL	; Entry point for global kills and loads
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZT^%ZUPGRD3") ; log error and continue on
	;
	S LINETAG="TBLDEL^%ZUPGRD3"
	;  run pre-conversion routine before loading in new globals
	W !!,"Now running pre-conversion routine ^",CNVPRE," at " D ^%T W !
	I $P($G(^UPGRADE("CNVPRE")),"|",2) W "Pre-conversion routine already run. " D ^%T G DBTBL
	S $P(^UPGRADE("CNVPRE"),"|",1)=$H
	D ^@CNVPRE
	W !,"Pre-conversion tasks done at " D ^%T W !
	S $P(^UPGRADE("CNVPRE"),"|",2)=$H
	;
TBLDEL	; Delete globals and load in new version from RMS files. Global files
	; are ordered in the following STANDARD way. ^DBTBL in GBL1, ^SCATBL in
	; GBL2, ^STBL in GBL3, ^TRN in GBL4, and ^UTBL and misc globals in GBL5.
	;
	K FLG
DBTBL	W !,"Now deleting ^DBTBL(""SYSDEV"") at " D ^%T W !
	I $P($G(^UPGRADE("DBTBL")),"|",2) W "^DBTBL already loaded. " D ^%T G FUN
	S LINETAG="FUN^%ZUPGRD3"
	S $P(^UPGRADE("DBTBL"),"|",1)=$H
	K ^DBTBL("SYSDEV")
	W !,"Now loading in ",VER," ^DBTBL(""SYSDEV"") at " D ^%T W !
	K IO
	S IO=RMSDIR_VNM_".GBL1"
	S X=$$FILE^%ZOPEN(IO,"READ",5) I X=0 W "^DBTBL not loaded." S:'$D(FLG) FLG=1 S $P(^UPGRADE("DBTBL"),"|",3)="^DBTBL not loaded." G FUN
	D ^%ZRELGI
	C IO
	W !,"^DBTBL done at " D ^%T W !
	S $P(^UPGRADE("DBTBL"),"|",2)=$H
	;
FUN	W !,"Now deleting standard functions in ",%DIR," at " D ^%T W !
	I $P($G(^UPGRADE("SCATBL",1)),"|",2) W "Functions already loaded. " D ^%T G MENU 
	S LINETAG="MENU^%ZUPGRD3"
	S $P(^UPGRADE("SCATBL",1),"|",1)=$H
	S (X,Y)=""
	;
FUN1	S X=$O(^SCATBL(1,X)) I X=""!(X?1"Z".E) G FUN2  ; deletes functions from % to Yzzzzz
	F I=1:1 S Y=$O(^SCATBL(1,X,Y)) Q:Y=""  S ^UPGRADE("SCATBL",1,X,Y)=^SCATBL(1,X,Y)
	K ^SCATBL(1,X),^SCATBL(3,X) W "." ; deletes function documentation as well as function
	G FUN1
	;
FUN2	W !,"^SCATBL(1) deleted",!,"^SCATBL(3) deleted"
	K ^SCATBL(2) W !,"^SCATBL(2) deleted",!
	W !,"Standard functions and function documentation deleted at " D ^%T W !
	;
MENU	W !,"Now deleting standard menus at " D ^%T W !
	I $P($G(^UPGRADE("SCATBL",2)),"|",2) W !!,"Menus already loaded. " D ^%T G STBL
	S LINETAG="STBL^%ZUPGRD3"
	S MNU=""
	S $P(^UPGRADE("SCATBL",2),"|",1)=$H
	F I=1:1 S MNU=$O(^SCATBL(0,MNU)) Q:(MNU>99999)!(MNU="")  K ^SCATBL(0,MNU) W "." ; menus 1 through 99999
	W !,"Standard menus deleted at " D ^%T W !
	;
	W !,"Now loading in standard ^SCATBL at " D ^%T W !
	K IO
	S IO=RMSDIR_VNM_".GBL2"
	S X=$$FILE^%ZOPEN(IO,"READ",5) I X=0 W "^SCATBL not loaded." S:'$D(FLG) FLG=1 S ^UPGRADE("SCATBL")="^SCATBL not loaded." G STBL
	D ^%ZRELGI
	C IO
	;
FUNUSR	; Set up SCA [ and MGR ] userclass in all functions
	I MGR W !,"Now setting up SCA and MGR userclasses for all functions at " D ^%T W !
	E   W !,"Now setting up SCA userclass for all functions at " D ^%T W !
	S X=""
	F I=1:1 S X=$O(^SCATBL(1,X)) Q:X=""  I MGR F J="MGR","SCA" S ^SCATBL(1,X,J)="" E  S ^SCATBL(1,X,"SCA")=""
FUN3	S (X,Y)=""
	F I=1:1 S X=$O(^UPGRADE("SCATBL",1,X)) Q:X=""  I $D(^SCATBL(1,X)) F I=1:1 S Y=$O(^UPGRADE("SCATBL",1,X,Y)) Q:Y=""  S ^SCATBL(1,X,Y)=""
	;
	W !,"^SCATBL loaded at " D ^%T W !
	S $P(^UPGRADE("SCATBL",1),"|",2)=$H
	S $P(^UPGRADE("SCATBL",2),"|",2)=$H
	;
STBL	; Delete ^STBL and load in new version.  Until custom entries are moved
	; to new table, we set these entries into temp file, kill off STBL, and
	; then reload these entries back into ^STBL from the temp file.
	;
	W !,"Now deleting ^STBL, except for non-standard entries, at " D ^%T W !
	I $P($G(^UPGRADE("STBL")),"|",2) W "^STBL already loaded. " D ^%T G TRN
	S $P(^UPGRADE("STBL"),"|",1)=$H
	S LINETAG="TRN^%ZUPGRD3"
	S STBL=""
	;
STBL1	S STBL=$O(^STBL(STBL)) G:STBL="" STBLLD
	I ",FEE,NOFEPXFR,"'[(","_STBL_",") W "." G STBL1
	S:$D(^STBL(STBL))#10 ^UPGRADE("STBL",STBL)=^STBL(STBL)
	S X=""
	;
STBL2	S X=$O(^STBL(STBL,X)) G:X="" STBL1
	S:$D(^STBL(STBL,X))#10 ^UPGRADE("STBL",STBL,X)=^STBL(STBL,X)
	S Y=""
	;
STBL3	S Y=$O(^STBL(STBL,X,Y)) G:Y="" STBL2
	S:$D(^STBL(STBL,X,Y))#10 ^UPGRADE("STBL",STBL,X,Y)=^STBL(STBL,X,Y) 
	G STBL3
	;
STBLLD	W !,"^STBL deleted except for custom entries at " D ^%T W !
	; Load in the new system tables
	S Z=""
	F I=1:1 S Z=$O(^STBL(Z)) Q:(Z="")!(Z?1"Z".E)  K ^STBL(Z) W "." 
	K IO
	S IO=RMSDIR_VNM_".GBL3"
	S X=$$FILE^%ZOPEN(IO,"READ",5) I X=0 W !,"^STBL not loaded." S:'$D(FLG) FLG=1 S $P(^UPGRADE("STBL"),"|",3)="^STBL not loaded." G TRN
	D ^%ZRELGI
	C IO
	;
	F STBL="FEE","NOFEPXFR" D STBL4
	W !,"^STBL now reloaded at " D ^%T W !
	S $P(^UPGRADE("STBL"),"|",2)=$H
	G TRN
	;
STBL4	; Load back in the custom ^STBL entries.
	K ^STBL(STBL) S (X,Y)=""
	I $D(^UPGRADE("STBL",STBL))#10 S ^STBL(STBL)=^UPGRADE("STBL",STBL)
	;
STBL5	S X=$O(^UPGRADE("STBL",STBL,X)) Q:X=""
	I $D(^UPGRADE("STBL",STBL,X))#10 S ^STBL(STBL,X)=^UPGRADE("STBL",STBL,X)
	;
STBL6	S Y=$O(^UPGRADE("STBL",STBL,X,Y)) G:Y="" STBL5
	I $D(^UPGRADE("STBL",STBL,X,Y))#10 S ^STBL(STBL,X,Y)=^UPGRADE("STBL",STBL,X,Y)
	G STBL6
	;
TRN	; Transaction codes
	W !,"Loading transaction codes at " D ^%T W !
	I $P($G(^UPGRADE("TRN")),"|",2) W "Tran codes already loaded. " D ^%T G UTBL
	S LINETAG="UTBL^%ZUPGRD3"
	S $P(^UPGRADE("TRN"),"|",1)=$H
	I +VER<4 S X="" F I=1:1 S X=$O(^TRN(X)) Q:X=""  F Y=0,1,2,3 S ^UPGRADE("TRN",X,Y)=$G(^TRN(X,Y)) W "."
	I +VER<4 W !,"^TRN copied to temporary file for retention at " D ^%T W !
	;
	K IO
	S IO=RMSDIR_VNM_".GBL4"
	S X=$$FILE^%ZOPEN(IO,"READ",5) I X=0 W "^TRN not loaded." S:'$D(FLG) FLG=1 S $P(^UPGRADE("TRN"),"|",3)="^TRN not loaded." G UTBL
	D ^%ZRELGI
	C IO
	W !,"Tran codes loaded at " D ^%T W !
	; Run the tran code conversion to put back custom fields and
	; flags in transaction codes (nodes 0,1,2)
	;
	I +VER>3.6 S $P(^UPGRADE("TRN"),"|",2)=$H G UTBL
TRNCNV	W !,"Custom fields and flags being reinstated into ^TRN at " D ^%T W !!
	; Collate through the temp global ^UPGRADE("TRN" to put back custom
	; fields and flags
	S ETC=""
	F I=1:1 S ETC=$O(^UPGRADE("TRN",ETC)) Q:ETC=""  D ETC
	W !,"Custom fields and flags now reinstated in ^TRN."
	W !,"^TRN completed at " D ^%T W !
	S $P(^UPGRADE("TRN"),"|",2)=$H
	G UTBL
	;
ETC	S CLS=$P(^TRN(ETC,0),"|",3)
	F J=0:1:3 D NODE
	Q
	;
NODE	S A(J)=$G(^UPGRADE("TRN",ETC,J))
	S B(J)=^TRN(ETC,J)
	I J=0 D NOD0
	I J=1 D NOD1
	I J=2 D NOD2
	I J=3 Q
	Q
	;
NOD0	; set custom pieces back into ^TRN
	S $P(B(0),"|",6)=$P(A(0),"|",6)
	S $P(B(0),"|",7)=$P(A(0),"|",7)
	S $P(B(0),"|",10)=$P(A(0),"|",10)
	S $P(B(0),"|",11)=$P(A(0),"|",11)
	S $P(B(0),"|",12)=$P(A(0),"|",12)
	S $P(B(0),"|",13)=$P(A(0),"|",13)
	S $P(B(0),"|",16)=$P(A(0),"|",16)
	S $P(B(0),"|",18)=$P(A(0),"|",18)
	S $P(B(0),"|",19)=$P(A(0),"|",19)
	S $P(B(0),"|",20)=$P(A(0),"|",20)
	S $P(B(0),"|",22)=$P(A(0),"|",22)
	S $P(B(0),"|",24)=$P(A(0),"|",24)
	;
	I CLS="*"!(CLS="M") D SET0
	;
	S ZERO="000000000000000000000000000000"
	S STND=$P(B(0),"|",23),CUST=$P(A(0),"|",23)
	S X=STND_$E(ZERO,1,30-$L(STND))
	S Y=CUST_$E(ZERO,1,30-$L(CUST))
	I CLS="D" F P=2,3 D POKE
	I CLS="L" F P=2,3,20 D POKE
	F I=$L(X):-1:1 Q:$E(X,I)'=0  S X=$E(X,1,I-1)  ; strips off zeroes
	S $P(B(J),"|",23)=X
	;
SET0	S ^TRN(ETC,0)=B(0)
	Q
	;
NOD1	S $P(B(1),"|",1)=$P(A(1),"|",1)
	S $P(B(1),"|",3)=$P(A(1),"|",3)
	S $P(B(1),"|",4)=$P(A(1),"|",4)
	S $P(B(1),"|",5)=$P(A(1),"|",5)
	S $P(B(1),"|",6)=$P(A(1),"|",6)
	S $P(B(1),"|",14)=$P(A(1),"|",14)
	S $P(B(1),"|",15)=$P(A(1),"|",15)
	S ^TRN(ETC,1)=B(1)
	Q
	;
NOD2	S $P(B(2),"|",4)=$P(A(2),"|",4)
	S $P(B(2),"|",5)=$P(A(2),"|",5)
	S $P(B(2),"|",6)=$P(A(2),"|",6)
	S $P(B(2),"|",7)=$P(A(2),"|",7)
	S ^TRN(ETC,2)=B(2)
	Q
	;
POKE	; poke back in custom flags for piece 23 node 0
	S X=$E(X,1,P-1)_$E(Y,P)_$E(X,P+1,999)
	Q
	;
	;
UTBL	W !,"Now loading top level of ^UTBL and other misc. globals at " D ^%T W !
	I $P($G(^UPGRADE("MISC")),"|",2) W "User tables and miscellaneous globals already loaded. " D ^%T G CUS0
	S LINETAG=""
	S $P(^UPGRADE("MISC"),"|",1)=$H 
UTBLLD	; Load in miscellaneous globals
	K IO
	S IO=RMSDIR_VNM_".GBL5"
	S X=$$FILE^%ZOPEN(IO,"READ",5) I X=0 W "Misc. globals not loaded." S:'$D(FLG) FLG=1 S $P(^UPGRADE("MISC"),"|",3)="Misc globals not loaded." Q
	D ^%ZRELGI
	C IO
	S UTBL=""
	F I=1:1 S UTBL=$O(^UTBL("UTBL",UTBL)) Q:UTBL=""  I $D(MGR) F J="MGR","SCA" S ^UTBL("UTBL",UTBL,J)="RWD" E  S ^UTBL("UTBL",UTBL,"SCA")="RWD"
	W !,"^UTBL and misc. globals loaded at " D ^%T W !
	S $P(^UPGRADE("MISC"),"|",2)=$H
	;
CUS0	I $D(FLG) W !,"One or more files were not loaded in.  Process halted.  Check the conversion table ^UPGRADE to determine which file was not loaded." G EXIT
	;
	; FLG will be set if there was a problem trying to open an RMS file 
	; and load in the routines or globals; also, it will be set if error
	; trap is called.
	;
	W !,"Deletions and standard release load complete at " D ^%T W !
	S G=0  ; initialize custom global input and direct control to 
	;               the custom load section
	;
CUSGI	; Re-install custom globals
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZT^%ZUPGRD3")
	S LINETAG=""
	I $P($G(^UPGRADE("CUSGI")),"|",2) W !!,"Custom globals already loaded. Moving on to backup at " D ^%T G STATUS
	S T(1)=" Custom globals can now be loaded in from RMS file(s).      "
	S T(2)=" Enter 'Y' for Yes if custom global loads will be performed."
	S %TAB("CUST")="|1|||||||L|Custom Global RMS files",CUST=0
	S %READ=",,@T(1),@T(2),,CUST",%NOPRMT="C"
	D ^UTLREAD 
	I CUST=0 S $P(^UPGRADE("CUSGI"),"|",2)="Custom globals not loaded." G STATUS
	S $P(^UPGRADE("CUSGI"),"|",1)=$H
	S G=G+1
	W !
	S HDG="  Load in Custom Globals from RMS files. If RMS files are in a"
	S HDG1=" directory other than the upgrade directory, enter it here."
	S %TAB("DIR")="|15|||||||T|Directory ",DIR=%DIR
	S %TAB("CUSGI")="|18|||||||T|Global RMS file ",CUSGI="CUS."_VNM_"GBL"_G
	S %READ="@HDG,@HDG1,,DIR#0,CUSGI"
	D ^UTLREAD I VFMQ="Q" Q
	K IO
	S IO=DIR_CUSGI
	S X=$$FILE^%ZOPEN(IO,"READ",5) I X=0 W "No globals loaded." S:'$D(FLG) FLG=1
	D ^%ZRELGI
	C IO
	W !,"Custom globals loaded at " D ^%T W ! H 5
	S %TAB("MORE")="|1|||||||L|More ",MORE=0
	S %READ="@HDG,@HDG1,,MORE"
	D ^UTLREAD I VFMQ="Q" S $P(^UPGRADE("CUSGI"),"|",2)=$H G STATUS
	K %TAB I MORE=1 G CUSGI
	S $P(^UPGRADE("CUSGI"),"|",2)=$H
	G STATUS
	;
STATUS	; Set ^CUVAR("%VN") to indicate upgrade status.
	S $P(^CUVAR("%VN"),"|",3)=1
	D BACKUP,CONV
	I '$D(VNM) S VNM=^UPGRADE("VNM")
	I '$D(VER) S VER=^UPGRADE("VER")
	I $G(ER)=1 W !,"Upgrade to version ",VNM," unsuccessful. Check error log." G EXIT
	S ^CUVAR("%VN")=VER
	S $P(^UPGRADE(VNM),"|",2)=$H
	W !,"***done***"
	W !!!,"Upgrade to ",VER," completed at " D ^%T W !
	Q
	; Upgrade will end here
	;
BACKUP	;Pause the upgrade process here to allow for a backup
	S %UID=1,TLO=$I,ER=0
	S HDG="   BACKUP"
	S T(1)=" Prior to continuing with the upgrade, it is recommended"
	S T(2)=" that a backup is performed here.  This process will"
	S T(3)=" wait until a backup is performed and customer indicates"
	S T(4)="it is time to continue."
	S %READ="@HDG,,,@T(1),@T(2),@T(3),@T(4)"
	S %NOPRMT="C"
	D ^UTLREAD H 4 I VFMQ="Q" S ER=1 Q
	K T
	D INT^%T
	S STARTD=+$H,STARTT=$P($H,",",2)
	ZA ^SYSLOG(STARTD):5
	I $D(^SYSLOG(STARTD))#10=0 S ^SYSLOG(STARTD)=0
	S SEQ=^SYSLOG(STARTD),^(STARTD)=SEQ+1
	ZD ^SYSLOG(STARTD)
	S ^SYSLOG(STARTD,SEQ)=$S($D(%UID):%UID,1:"")_"|"_TLO_"|BACKUP|"_STARTT_"|"
	;
	S H1="This process allows you to suspend the upgrade and perform a backup."
	S H2="When you have completed the backup, the upgrade will continue.      "
	;
	S H3="Pausing at "_%TIM_" "_$$^%ZD($H)
	;
REDO	;
	S %TAB("CONT")="|1|||||||L|Are you ready to continue?",CONT="N"
	S %READ="@H1,@H2,,,,@H3,,,,<<CONT#1>>"
	K OLNTB D ^UTLREAD
	I VFMQ="Q" G REDO
	I 'CONT G REDO
	;
	S $P(^SYSLOG(STARTD,SEQ),"|",5)=$P($H,",",2)
	K STARTD,STARTT,SEQ,H1,H2,H3
	;
	;
	W !!,"Ready to continue with upgrade.",!
	Q
	;
CONV	;
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZT^%ZUPGRD3")
	I $P($G(^UPGRADE("CONV")),"|",2) W "Conversion programs already run. Moving on to Data Qwik upgrade at " D ^%T G DQ
	; Control will now be transferred to the conversion master
	; driver programs
	; Set ^CUVAR("%VN") to indicate upgrade status
	S $P(^CUVAR("%VN"),"|",3)="*2" ; indicates beginning pre conversion tasks
	W !!,"Now running conversion programs for upgrade to version ",VER," at " D ^%T W !
	S $P(^UPGRADE("CONV"),"|",1)=$H
	D ^@CNVDRV
	S $P(^UPGRADE("CONV"),"|",2)=$H
	W !,"Application conversion programs completed at " D ^%T
	;
DQ	I $P($G(^UPGRADE("DBS")),"|",2) W !!,"DATA-QWIK upgrade already completed. Moving on to post-conversion steps at " D ^%T G PPOST
	W !!,"Now running DATA-QWIK control table build and recreating X-reference files at " D ^%T W !
	S $P(^UPGRADE("DBS"),"|",1)=$H,%LIBS="SYSDEV"
	D START1^DBSINIT,^@DBSCNV S %LIBS="SYSDEV" D %EXT^DBSUTL9
	S $P(^UPGRADE("DBS"),"|",2)=$H
	;
PPOST	;
	W !!,"Now beginning post-conversion tasks at " D ^%T W !
	D POST,POST1,POST2,POST3,POST4,POST5,POST6
	Q
	;
POST	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZT^%ZUPGRD3")
	;
	I $P($G(^UPGRADE("POST")),"|",2) W !!,"Accrual programs already compiled. Moving on to compiling service fee programs at " D ^%T Q
	; Accrual program recompiles
	S $P(^UPGRADE("POST"),"|",1)=$H
	W !!,"Recompiling accrual programs.  Check error log for compile problems. ..." D ^%T W !
	; init new customer variables for version 3.5
	S %MCP=$G(^CUVAR("%MCP")),%CRCD=$G(^CUVAR("%CRCD"))  ; 3.5 Upgrade only
	S TYPE=1
	F I=0:0 S TYPE=$O(^MLT(TYPE)) Q:TYPE=""  D CMPMLT
	S $P(^UPGRADE("POST"),"|",2)=$H
	Q
	;
CMPMLT	S ER=0
	D BTTCMP^BTTCMP(TYPE)
	I 'ER W !,TYPE," compiled - routine "_PGM_" at " D ^%T W !
	E  W !,TYPE," NOT COMPILED -",RM,!
	Q
	;
POST1	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZT^%ZUPGRD3")
	;
	I $P($G(^UPGRADE("POST1")),"|",2) W !!,"Service fee programs already compiled. Moving on to the cross-reference builder at " D ^%T Q
	; Compile service fee programs
	W !!!,"Compiling service fee plan programs at " D ^%T W !
	S $P(^UPGRADE("POST1"),"|",1)=$H
	S FEEPLN="",%UID=1,%LIBS="PRD"
	F I=0:0 S FEEPLN=$O(^UTBL("FEEPLN",FEEPLN)) Q:FEEPLN=""  D POSFEE
	W !,"Service fee plans compiled at " D ^%T W !
	S $P(^UPGRADE("POST1"),"|",2)=$H
	Q
	;
POSFEE	D ^SRVCMP W !,FEEPLN," compiled - routine "_PGM_" at " D ^%T W !
	Q
	;
POST2	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZT^%ZUPGRD3")
	;
	I $P($G(^UPGRADE("POST2")),"|",2) W !!,"Cross-references already built. Moving on to billing charge program compiles at " D ^%T Q
	; Rebuild cross references
	N
	S %MCP=$G(^CUVAR("%MCP"))
	W !!,"Now running cross-reference file builder at " D ^%T W !
	S $P(^UPGRADE("POST2"),"|",1)=$H
	D %EXT^XREF
	W !!,"Cross-reference files built at " D ^%T W !!
	S $P(^UPGRADE("POST2"),"|",2)=$H
	Q
	;
POST3	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZT^%ZUPGRD3")
	;
	I $P($G(^UPGRADE("POST3")),"|",2) W !!,"Billing charge programs already compiled. Moving on to compiling data-item protection programs at " D ^%T Q
	; Rebuild loan bill charge compiled progerams
	S $P(^UPGRADE("POST3"),"|",1)=$H
	W !,"Now compiling billing charge programs at " D ^%T W !
	D ^LNBCHG3
	W !,"Billing charge programs compiled at " D ^%T W !!
	S $P(^UPGRADE("POST3"),"|",2)=$H
	Q
	;
POST4	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZT^%ZUPGRD3")
	;
	I $P($G(^UPGRADE("POST4")),"|",2) W !!,"Data-protection programs already compiled. Moving on to recompiling screens and reports in ",%LIBS," library at " D ^%T Q
	; Rebuild data item protection compiled programs.
	W !!,"Now compiling data-item protection programs at " D ^%T W !
	I '$D(^DBTBL("SYSDEV",14))&('$D(^DBTBL("PRD",14))) W !,"No programs compiled" Q
	S $P(^UPGRADE("POST4"),"|",1)=$H
	F I="PRD","SYSDEV" S ZFID="" F J=1:1 S ZFID=$O(^DBTBL(I,14,ZFID)) Q:ZFID=""  D BUILD^DBSPROT3(ZFID)
	S $P(^UPGRADE("POST4"),"|",2)=$H
	W !,"Data Item Protection programs compiled at " D ^%T W !
	Q
	;
POST5	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZT^%ZUPGRD3")
	;
	I $P($G(^UPGRADE("POST5")),"|",2) W !!,"Screens and reports already compiled. Moving on to application integrities at " D ^%T Q
	; Recompile screens and reports in PRD library
	N ER,%LIBS,%UID,%TO,SID,RID
	S ER=0
	S $P(^UPGRADE("POST5"),"|",1)=$H
	W !!,"Now recompiling screens and reports in PRD library at " D ^%T W !
	W !,"Screens:",!
	K ^TEMP($J)
	S %LIBS="PRD",%UID=1,%TO=99 S ^DBTBL("PRD",0,"L")=2
	S SID="" F I=1:1 S SID=$O(^DBTBL(%LIBS,2,SID)) Q:SID=""  S:'$D(^DBTBL(%LIBS,2,SID,-3)) ^TEMP($J,SID)=""
	D EXT^DBSDSMC
	W !!,"Screens completed at " D ^%T W !
	;
	W !!,"Reports:",!
	K ^TEMP($J)
	S ER=0
	S RID="" F I=1:1 S RID=$O(^DBTBL(%LIBS,5,RID)) Q:RID=""  S:'$D(^DBTBL(%LIBS,5,RID,-3)) ^TEMP($J,RID)=""
	D EXT^DBSEXE
	W !,"Reports completed at " D ^%T W !
	S $P(^UPGRADE("POST5"),"|",2)=$H
	Q
	;
POST6	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZT^%ZUPGRD3")
	N ER,H,INTEG
	S ER=0
	;
	I $P($G(^UPGRADE("POST6")),"|",2) W !!,"Application integrities already run." Q
	; Run application integrities
	S H(1)="             Application Integrity                          "
	S H(2)="Integrity reports should be run for CIF, Deposits, and Loans"
	S H(3)="after upgrade has completed.  Continue here to run them now."
	S %TAB("INTEG")="|1|||||||L|Run Integrity",INTEG=1
	S %READ=",@H(1)#2,,@H(2)#0,@H(3),,,INTEG"
	D ^UTLREAD I VFMQ="Q" S INTEG=0
	I INTEG=0 S ^UPGRADE("POST6")="Integrities not run during upgrade."
	Q:INTEG=0 
	I VFMQ="Q" Q
	;
JOB	W !!,"      APPLICATION INTEGRITIES",!!
	S $P(^UPGRADE("POST6"),"|",1)=$H
	K ^XBAD
	W !,"Now running loan integrity at " D ^%T W !
	D ^LNIC1 ; loan integrity for all loan accounts
	W "Loan integrity done at " D ^%T W !
	W !,"Now running deposit integrity at " D ^%T W !
	S %EXT=1 D XCLS^DEPVER ; deposit integrity
	W "Deposit integrity done at " D ^%T W !
	W !,"Now running CIF integrity at " D ^%T W !
	S %EXT=1 D XCLS^CIFVER ; CIF integrity
	W "CIF integrity done at " D ^%T W !
	S $P(^UPGRADE("POST6"),"|",2)=$H
	W !,"Account integrity problems now logged in ^XBAD."
	S Z=^CUVAR(2),ZZ=$$^%ZD(Z)
	W !,"Be sure to run the verification report for "_ZZ_" immediately after upgrade." 
	Q
	;
EXIT	; Exit from program due to error
	S ER=1,RM="Upgrade aborted." 
	W !,"Upgrade aborted at " D ^%T
	S $P(^UPGRADE(VNM),"|",3)="Upgrade aborted"_"|"_$H
	Q
ZT	; error trap to log the error and continue upgrade program
	D ZE^UTLERR ; log the error
	S FLG=1,ER=1
	I $L($G(LINETAG)) G @LINETAG
	Q
ZTQ	; error trap to log error and abort the upgrade
	K LINETAG
	D ZT ; log the error
	W ! G EXIT
	;
RESTART	; entry for restarting upgrade process.
	; variables will be re-initialized and process will begin
	; with routine deletions. $P(^UPGRADE(process step),"|",2) will be
	; checked for completion before executing the subroutine. If
	; it has already been set, restart willmove on to next step, and
	; so on until it finds one which has not been completed.
	;
	S RESTART=1,ER=0,FLG=""
	I $$NEW^%ZT N $ZT
	S @$$SET^%ZT("ZTQ^%ZUPGRD3")
	G ^%UPGRD0
	Q
