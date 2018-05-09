DBSDSMP	;;DBS - U - V4.4 -  Multiple page screen driver / VT mode only
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/30/02 13:51:23 - ANTONOVV
	; ORIG:  Frank R. Sanchez  (2497)
	; DESC:  Compiles driver section of multiple page screens
	;
	;  I18N=QUIT: Excluded from I18N standards 
	;
	;---------- Revision History ------------------------------------------- 
	; 09/28/04 - RussellDS - CR12334 
	;	     Replaced obsoleted calls to ^DBSANS1 with new procedure
	;	     DBSGETID.
	;
	; 04/06/04 - RussellDS - CR9172
	;	     Replaced call DEFAULT^DBSTRG with DEFAULT^DBSSCR4.  DEFAULT
	;	     section was removed from DBSTRG.  Added to DBSSCR4.
	;
	; 09/30/02 - ANTONOVV - 43583
	;            Removed second parameter from SCACOPYR() call.
	;
	; 12/08/97 - Chiang - 26857
	;            Modified VDEF section to include data item default logic
	;            in the run-time routines.
	;            Replaced $ZP with $O referneces.
	;
	; 09/13/96 - Bob Chiang - 20948
	;            Modified FILE section to replace variable XX with X.
	;
	; 08/23/96 - SPIER - 22638
	;	    Changed $n to $o
	;            
	; 05/10/96  Bob Chiang - 20948 
	;           Modified VDEF section to build the correct default logic 
	;           in the screen run-time routine. 
	;
	; 03/20/96 - Bob Chiang 21403
	;            Modified SEQ section to remove a bad MUMPS New command.
	;
	; 03/18/96 - Bob Chiang 21403
	;            Modified SEQ section to include data item protection logic
	;            in the data load section of the run-time routine.
	;
	; 07/31/95 - Bob Chiang - 290
	;            Added logic to validate file relationships between
	;            linked screens and master screen.
	;
	;-----------------------------------------------------------------------
START	;
	N (%LIBS,SID,NOLINK,%LOGID)
	;
	W $J("",10),"..."
	;
	N comp,fsn
	;
	K X,S,DEF,NEW,BLD,LOOP,DEF,XNEW,HELP,FILE,FX,FILER,HV,TB,TMP,VPG
	K IDXX,XCOMP,XLINK,%TAB,^TMP($J),NS
	S Q=$C(34),%="|",NUL=Q_Q,Q2=NUL,FLAG=0
	S (PON,ISEQ)=0,MAXLN=1,(T,D,CMD)=0,(OL,OD)=""
	;
	I '$D(SID) S SID=$$FIND^DBSGETID("DBTBL2",0) Q:SID=""
	;
	D VALID(SID) I ER W !,RM h 5 Q		; *** 07/31/95 BC
	; Not a linked screen procedure
	I '$D(^DBTBL(%LIBS,2,SID,-1)) S ER=0,RM=$$^MSG(2019) Q
	;
	S LOOP="NOLOOP"					; Disable LOOP
	;
	S SCREENS=^(-1) Q:SCREENS=""
	S X=^(0),PGM=$P(X,"|",2),FILES=$P(X,"|",1)
	;
	I PGM="" D GTPGM^DBSDS
	I PGM["*" S PGM=$E(PGM,1,3)_"S"_$E(PGM,5,9)
	;
	S SAVPGM=PGM,SVSID=SID,$P(^DBTBL(%LIBS,2,SID,0),"|",2)=PGM
	;
	S SCRER=0
	;
	F SCRNUM=1:1 S SID=$P(SCREENS,"|",SCRNUM) Q:SID=""  D BUILD
	I SCRER Q
	D FILE
	Q
	;
BUILD	; Build multiple screen program
	S EXTSID=SID W !,?20,SID
	I $E(SID)="@" D APPEND S SCRNUM=SCRNUM-1 Q
	I SID["[" N %LIBS S X=$P(SID,"]",1),%LIBS=$P(X,"[",2),SID=$P(SID,"]",2)
	;  Invalid screen name
	I $G(^DBTBL(%LIBS,2,SID))="" W ?20,$$^MSG(1458,SID) S SCRER=1 Q
	;
	K DT
	S DES=^DBTBL(%LIBS,2,SID),STS=^(SID,0)
	I $L($P(STS,"|",1))>$L($G(FILES)) S FILES=$P(STS,"|",1)
	S PFID=$P($P(STS,"|",1),",",1),PGM=$P(STS,"|",2),CNTL=$P(STS,"|",10)
	;
	I PGM["*" S PGM=$E(PGM,1,3)_"S"_$E(PGM,5,9)
	;
	S VPG(SCRNUM)=DES_"|"_SID
	;
	D LOAD S SEQ=0
	;
	S CMD=CMD+1,^TMP($J,CMD)="VPG"_SCRNUM_" ; "_DES
	S CMD=CMD+1,^TMP($J,CMD)=" ;"
	S CMD=CMD+1,^TMP($J,CMD)=" S SID="""_SID_""",DFID="""_DFID_""""
	S CMD=CMD+1,^TMP($J,CMD)=" D ^USID I PGM="""" S ET=""INVLDSCR"" D ^UTLERR Q"
	;
	; REPEATING SCREEN ?
	;
	D REPEAT
	;
	S CMD=CMD+1
	;
	; ---------- Protection flag on ?
	;
	S Vprot=0					; *** 03/18/96
	S Z="" I $P(^DBTBL(%LIBS,2,SID,0),"|",16) D
	.	S Vprot=1				; Protection flag
	.	D STATUS^UPID(PFID,"*",.Z)		; Revord level prot
	.	I Z S Z="D VPROT^@PGM Q:ER  "
	.	E  S Z=""
	;
	I $D(^DBTBL(%LIBS,2,SID,0,121)) D		; Display pre-proc
	.	S ^TMP($J,CMD)=" D VDSPPRE^@PGM ; Display Pre-Processor"
	.	S CMD=CMD+1				; 04/13/93 BC
	;
	S ^TMP($J,CMD)=" K VPTBL S VPGM=PGM "_Z_"D VREPRNT^@PGM I %O>1 Q" ;***XUS
	;
	S CMD=CMD+1,^TMP($J,CMD)=" D VTAB^@PGM Q"
	S CMD=CMD+1,^TMP($J,CMD)=" ;"
	;
SEQ	S SEQ=$O(DT(SEQ)) Q:SEQ=""  S X=DT(SEQ)
	;
	S P2=$P(X,"|",2),P7=$P(X,"|",7),P15=$P(X,"|",15)
	S P8=$P(X,"|",8),P9=$P(X,"|",9)
	S DINAM=$P(X,"|",5)
	;
	I DINAM'?1"[".E1"]".E G SEQ
	D PARSE^DBSDD(.DINAM,"",.comp,.fsn,"",.vdd) Q:ER
	; Compilation error - ~p1
	I ER="" W !,$$MSG^%TRMVT($$^MSG(587,DINAM),0,1)
	I 'Vprot G SEQ
	;						; *** 03/18/96
	S fid=$P(DINAM,".",2),di=$P(DINAM,".",3)	; File and data item
	D STATUS^UPID(fid,di,.VP)			; Check protection status
	I VP S vp(fid,di)=""				; Save status
	G SEQ
	;
APPEND	; Append screens, if defined (syntax = @[Library]SID)
	S SCREENS=$P(SCREENS,"|",1,SCRNUM-1)_"|"_$P(SCREENS,"|",SCRNUM+1,99)
	I $E(SCREENS)="|" S SCREENS=$P(SCREENS,"|",2,99)
	;
	N LIB S LIB=%LIBS,SID=$E(SID,2,99)
	I SID["[" S LIB=$P(SID,"]",1),LIB=$P(LIB,"[",2),SID=$P(SID,"]",2)
	;
	I '$D(^DBTBL(LIB,2,SID)) Q
	N N S N=SCRNUM I '$D(^DBTBL(LIB,2,SID,-1)) D APPSID Q
	N I,X S X=^(-1) F I=1:1 Q:$P(X,"|",I)=""  S SID=$P(X,"|",I) D APPSID
	Q
	;
APPSID	I LIB'=%LIBS S SID="["_LIB_"]"_SID
	S $P(SCREENS,"|",N)=SID_"|"_$P(SCREENS,"|",N),N=N+1
	Q
	;
LOAD	; LOAD ^DBTBL(LIB,2,SID,SEQ into DT(SEQ
	S LIB=%LIBS I $D(^DBTBL(%LIBS,2,SID,-3)) S LIB=^(-3) ; IMPLICIT SCREEN
	S DFID=$P($P(^(0),"|",1),",",1)
	;
	S SEQ=0 K DT
	;
	; DECODE SCREEN PRE/POST PROCESSOR FOR [FID]DI REFERENCE
	;
	;
	S Z11="" F Z12=1:1 S Z11=$O(^DBTBL(LIB,2,SID,0,Z11)) Q:Z11=""  S X=^(Z11) D ^DBSPARS
	;
	F  S SEQ=$O(^DBTBL(LIB,2,SID,SEQ)) Q:SEQ=""  S DT(SEQ)=^(SEQ) D LOAD1
	Q
LOAD1	;
	;
	S Z11="" F Z12=1:1 S Z11=$O(^DBTBL(LIB,2,SID,SEQ,Z11)) Q:Z11=""  S X=^(Z11) D ^DBSPARS
	Q
	;
END	; Go to build program
	Q
	;
FILE	;
	;
	K DT,NEW
	S SID=SVSID,PGM=SAVPGM D ^DBSREL I ER D ERR^DBSBLD I X="Q" Q
	S L=0,FID=PFID,SCREEN=1 D FLD^DBSBLD K SCREEN
	;
	S STS=^DBTBL(%LIBS,2,SID,0),FILES=$p(STS,"|",1),PFID=$p(FILES,",",1)
	S USERVLOD=$D(^DBTBL(%LIBS,2,SID,0,101))
	S RPCFLG=1 I $P(STS,"|",4) S RPCFLG=0
	I RPCFLG,$P(^CUVAR("DBS"),"|",6) S RPCFLG=0	; *** BC - Disable RPC logic
	;						; [DBVAR]DBSNET flag
	I USERVLOD S RPCFLG=0
	;
	D ^DBSLOD("*",.SCRVLOD,"","",2,SID,RPCFLG,,.vp)
	;
	;
	S Z=$O(BLD(""),-1)+1
	;
	I 'USERVLOD G BLD4A
	;
	; Insert VCOM first
	;
	S X="" F  S X=$O(SCRVLOD(X)) Q:X=""  I SCRVLOD(X)?1"VCOM".E Q
	I X'="" S X=$O(SCRVLOD(X),-1) F I=1:1 S X=$O(SCRVLOD(X)) Q:X=""  S BLD(Z+I)=SCRVLOD(X) K SCRVLOD(X)
	;
	S Z=$O(BLD(""),-1)+1
	;
	S BLD(Z)=" Q",BLD(Z+1)="VLODDQ ; Original VLOD section",BLD(Z+2)=" ;",Z=Z+3
BLD4A	;
	;
	;
	S X="" F I=1:1 S X=$O(SCRVLOD(X)) Q:X=""  S BLD(Z+I)=SCRVLOD(X)
	;
	S AR=""
BLD1	S AR=$O(FILE(AR)) I AR="" G BLD2
	I '$D(FILER(AR)) G BLD1
	I $E(FILE(AR),1)'="*" G BLDX
	S X="" F  S X=$O(LOOP(-1,X)) Q:X=""  I LOOP(-1,X)=AR Q
	F NKEY=1:1 S Z=^DBTBL(%LIBS,1,X,NKEY) I Z="" Q
	S Z=^(NKEY-1)
	S X="S "_$E(FILE(AR),2,99)_"="_AR_"("_Q_Z_Q_")" D DOUBLE
	S FX(AR)=" S %FILE("_Q_AR_Q_")="_Q_X_Q
	G BLD1
	;
BLDX	;
	S X="S X=-"""" F  S X=$O("_AR_"(X)) Q:X=""  S "_$P(FILE(AR),")",1)_",X)="_AR_"(X)" D DOUBLE
	S FX(AR)=" S %FILE("_Q_AR_Q_")="_Q_X_Q
	G BLD1
BLD2	;
	K FILE
	;
	S SID=SVSID,PGM=SAVPGM,DES=^DBTBL(%LIBS,2,SID),X=^DBTBL(%LIBS,2,SID,0)
	S APL=$P(X,"|",11),SYS=$P(X,"|",12),CNTL=$P(X,"|",10),PROJ=$P(X,"|",13)
	;
	S (N,COMVAR,KVAR)="",SCRNUM=SCRNUM-1
	I $D(BLD(2)),$P(BLD(2)," ;",1)="EXEC" S BLD(2)="VLOD ; Load data from disc - %O = (1-5)"
	;
	I 'USERVLOD G BLD2A
	;
	; user defined VLOD sectin
	;
	K ZIPP,OM
	S X=100.99 F I=1:1 S X=$O(^DBTBL(%LIBS,2,SID,0,X)) Q:X=""  S ZIPP(I)=^(X)
	D ^DBSPARS
	;
	S BLD(2)="VLOD ; User defined access section"
	S X=0 F I=1:1 S X=$O(OM(X)) Q:X=""  S BLD(I/1000+2)=OM(X)
	K OM
	;
BLD2A	;
	S KVAR="K %A,%TAB,vtab,VFSN,%OLD,%NEW,%FILE,%INDEX,%PAGE,%PG,UX,MULSCR"
	S N="" F  S N=$O(LOOP(-1,N)) Q:N=""  D LOOP
	;
	; Load base program "DBSCMP2M"
	;
	K XLT,REPORT
	;
	D ^DBSRTN("SCRLNK","REPORT","",.XLT)		; *** BC - Replace
	;						; *** ^%ZRTNLOD call
	;
	; Program Id & Copyright Message
	;
	D ^SCACOPYR(.X1)
	;
	S REPORT(1)=PGM_" ;;"_APL_" - "_SYS_" - "_$G(^DBTBL)_" - SID= <"_$G(SID)_"> "_DES
	S REPORT(2)=X1 K X1
	S %TIM=$$TIM^%ZM			; 04/30/03 BC
	;
	; TAG  VPAGE
	;
	S X1=XLT("VPAGE")+.001,REPORT(X1)=" ;",X1=X1+.001
	F I=1:1:CMD S REPORT(X1)=^TMP($J,I),X1=X1+.001
	;
	; TAG VPG
	;
	S X1=XLT("VPG")+.001,REPORT(X1)=" ;",X1=X1+.001
	F I=1:1:SCRNUM S REPORT(X1)=" I %PG=(%PGSV+"_(I-1)_") D VPG"_I_" G VPG0",X1=X1+.001
	;
	; TAG VNEW
	;
	S X1=XLT("VNEW")+.001,REPORT(X1)=" ;",X1=X1+.001
	;
	I USERVLOD S REPORT(X1)=" D VLOD",REPORT(X1+.001)=" Q"
	I  S REPORT(X1+.002)="VNEWDQ ; Original VNEW section",REPORT(X1+.003)=" ;",X1=X1+.005
	;
	S X="" F  S X=$O(VNEW(X)) Q:X=""  S REPORT(X1)=VNEW(X),X1=X1+.001
	;
	;
VDEF	; Default values
	;
	I PFID'="" D 
	.       ; 					; *** 12/05/97
	.       I '$D(fsn(PFID)) D fsn^DBSDD(.fsn,PFID) 
	.       I $G(^DBTBL(%LIBS,1,PFID,101))="" Q	; No defualts
	.       N i,zdft
	.       ; 
	.       S X1=X1+.001
	.	D DEFAULT^DBSSCR4(PFID,.zdft,2)		; Get info
	.	S i=2 F  S i=$O(zdft(i)) Q:i=""  S REPORT(X1)=zdft(i),X1=X1+.001 
	;
	; TAG BUILD SECTION
	;
	S REPORT(X1)=" Q",X1=X1+.001,REPORT(X1)=" ;",X1=X1+.001
	S X="" F  S X=$O(BLD(X)) Q:X=""  S REPORT(X1)=BLD(X),X1=X1+.001
	;
	; Screem pre-processor ( level 0 ... 61-80)   V 3.6
	;
	S X1=XLT("V1") K REPORT(X1)
	S X1=X1+1.001
	;
	; ---------- Without Display Pre-processor
	;
	I '$D(^DBTBL(%LIBS,2,SID,0,121)) D  G BLD3
	.	;
	.	S REPORT(X1)=" I '%O D VNEW G VPG"
	.	S X1=X1+.001
	.	S REPORT(X1)=" D VLOD I $G(ER) S VFMQ=""Q"" Q"
	.	S X1=X1+.001
	.	S REPORT(X1)=" G VPG"
	.	S X1=X1+.001
	;
	; ---------- With screen display pre-processor
	;
	S tag="VDSPPRE ; Screen Display Pre-Processor"
	D PPUTIL(121,tag)
	S REPORT(X1)=" I '%O D VNEW,VDSPPRE Q:$G(ER)  G VPG ; Screen Display Pre-Processor"
	S X1=X1+.001
	S REPORT(X1)=" D VLOD I $G(ER) S VFMQ=""Q"" Q"
	S X1=X1+.001
	S REPORT(X1)=" D VDSPPRE I $G(ER) S VFMQ=""Q"" Q"
	S X1=X1+.001
	S REPORT(X1)=" G VPG"
	S X1=X1+.001
	;
BLD3	;
	; Computed variables
	;
	S X1=XLT("V0")+.001
	;
	; ---------- With screen pre-processor
	;
	I $D(^DBTBL(%LIBS,2,SID,0,61)) D
	.	;
	.	S tag="VSCRPRE ; Screen Pre-Processor"
	.	D PPUTIL(61,tag)
	.	S REPORT(X1)=" S ER=0 D VSCRPRE I ER Q  ; Screen Pre-Processor"
	.	S X1=X1+.001 S REPORT(X1)=" ;" S X1=X1+.001
	.	;
	;
	; Computed variables
	;
	S REPORT(X1)=" S VSID="_Q_SID_Q,X1=X1+.001
	I COMVAR'="" S REPORT(X1)=" S ("_$E(COMVAR,1,$L(COMVAR)-1)_")="_Q_Q
	;
	; KVAR
	;
	S X1=X1+.001,REPORT(X1)=" S KVAR="_Q_KVAR_Q,X1=X1+.001
	;
	S REPORT(X1)=" S:'$D(%PG) %PG=1 S %PAG=%PG+"_(SCRNUM-1)_" S %PAGE=$S($D(%PAGE):%PAGE-1,1:0)+"_SCRNUM
	;
	S X1=X1+.001,REPORT(X1)=" ;",X1=X1+.001
	;
	F I=1:1:SCRNUM S REPORT(X1)=" S VPG(%PG+"_(I-1)_")="_Q_VPG(I)_Q,X1=X1+.001
	;
	S X1=XLT("VPAGE") K REPORT(X1)
	;
	K XLT,BLD,VNEW,DFV,COMVAR,VPG,OM,NEW,LOOP
	;
	D ^DBSCMP(SAVPGM,"REPORT",$G(NOLINK))
	;
	K REPORT
	Q
	;
DOUBLE	;
	;
	S L=0
	F I=1:1 S L=$F(X,Q,L) Q:L<1  S X=$E(X,1,L-2)_Q_Q_$E(X,L,999),L=L+1
	;
LOOP	; Build appropiate arrays from LOOP(array)
	;
	N X,LIB
	;
	S KVAR=KVAR_","_LOOP(-1,N)
	;
	; Create variable save list for BPS mode
	;
	I '$D(^DBTBL(%LIBS,1,N)) Q
	;
	; Implicit mode ?
	;
	S X=$P($G(^DBTBL(%LIBS,1,N,10)),"|",5),LIB=%LIBS
	I X'="" S LIB=$E($P(X,",",1),2,99)
	;
	Q
	;
REPEAT	;
	;
	N Z
	I '$P(STS,"|",7) Q
	;
	I $D(ZZREPSCR(SID)) S Z1=ZZREPSCR(SID),Z=" S %MODS="_(Z1+1)_",%REPEAT=zzREPEAT#"_Z1
	E  S Z=" S %MODS=1 I '$D(%REPEAT) S %REPEAT="_(23-$P(STS,"|",7))
	S ZZREPSCR(SID)=23-$P(STS,"|",7)
	S CMD=CMD+1,^TMP($J,CMD)=Z
	Q
	;
	; Entry point for mass recompile option for linked screens only
	;
LINKSCR	;
	;
	I $G(%LIBS)="" Q
	K ^TEMP($J)
	S SID="" F I=1:1 S SID=$O(^DBTBL(%LIBS,2,SID)) Q:SID=""  I $D(^(SID,-1)) S ^TEMP($J,SID)="" W !,?30,SID
	;
	D EXT^DBSDSMC
	Q
	
PPUTIL(node,tag)	; 
	;
	N X,X1,X2,I,ZIPP,OM
	;
	S X=node-.001,X2=X+20
	;
	F I=1:1 S X=$O(^DBTBL(%LIBS,2,SID,0,X)) Q:X=""!(X>X2)  DO
	.	S Z=^(X) I $P(Z," ;",2)?.E1"["1A.AN1"]"1A.AN S Z=$P(Z," ;",1)
	.	S ZIPP(I)=Z
	D ^DBSPARS
	;
	S X1=$O(REPORT(""),-1)+100 ; end of program
	S REPORT(X1)=tag,X1=X1+.001
	S REPORT(X1)=" N %TAB,vtab ; Disable .MACRO. references to %TAB()",X1=X1+.001
	;
	S REPORT(X1)=" ;",X1=X1+.001
	;
	S Z="" F  S Z=$O(OM(Z)) Q:Z=""  S REPORT(X1)=OM(Z),X1=X1+.001
	S REPORT(X1)=" Q"
	Q
	;
	;----------------------------------------------------------------------
VALID(SID)	; Validate screen linkage file relationships
	;----------------------------------------------------------------------
	; Verify that the file names defined in the linked screens are included
	; in the master screen
	;
	; ARGUMENT:	SID	Scrren Name	/TYP=T/REQ/REF=VAL
	;
	; RETURNS:	ER	Error Flag	/TYP=N
	;		RM	Error Message	/TYP=T
	;
	; EXAMPLE:      D VALID^DBSDSMP("DEP001")
	;----------------------------------------------------------------------
	N file,i,j,mfile,sid,z,zfile,SF
	I $G(%LIBS)="" N %LIBS S %LIBS=^CUVAR("%LIBS")
	S ER=0
	I $G(^DBTBL(%LIBS,2,SID,-1))="" Q	; Not a linked screen
	S z=^(-1)				; Definition
	s mfile=","_$P(^(0),"|",1)_","		; Acccess files (master screen)
	F i=1:1:$L(z,"|") D  I ER Q		; Check each screen
	.	S sid=$P(z,"|",i)
	.	I sid="" Q			; Valid screen name?
	.	I $E(sid)="@" Q			; @[lib]sid
	.	I '$D(^DBTBL(%LIBS,2,sid)) S ER=1,RM=$$^MSG(1458,sid) Q
	.	S file=$P(^DBTBL(%LIBS,2,sid,0),"|",1)	; Access files
	.	F j=1:1:$L(file,",") D  I ER Q
	..		S zfile=","_$P(file,",",j)_","
	..		I mfile[zfile Q		; Valid relationships?
	..		S ER=1,RM=$$^MSG(1340,sid,SID)
	Q
	;----------------------------------------------------------------------
QA	; Valid file relationships for each link screen
	;----------------------------------------------------------------------
	N ER,RM,SID
	I $G(%LIBS)="" N %LIBS S %LIBS=^CUVAR("%LIBS")
	S SID="" F  S SID=$O(^DBTBL(%LIBS,2,SID)) Q:SID=""  D
	.	I $G(^DBTBL(%LIBS,2,SID,-1))="" Q
	.	D VALID(SID)
	.	I ER W !,RM
	Q
