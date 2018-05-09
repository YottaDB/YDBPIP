DBSSCR3	; DBS - U - V4.4 - Screen compiler, page #2
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/17/94 10:31:11 - XUS
	;     ORIG:  CHIANG - 1/15/86
	;     DESC:  CHECK VALID SCREEN ID
        ; I18N=QUIT: Exculded from I18N standards.
	;
	;---------- Revision History -------------------------------------------
	;
	; 04/30/93  Bob Chiang - IB
	;
	;           Modified to replace INT^%T time utility with $$TIM^%ZM.
	;
	; 01/04/93  Bob Chiang - FMSQA
	;          
	;           Modified to include vtab() in the KVAR list.
	;
	; 07/14/92  Robert Chiang  QA3163
	;
	;           Modified to replace screen post-processor flag REQ variable
	;           with a DQ reserved variable VSCRPP
	;-----------------------------------------------------------------------
	;
	S SAVD=D,SAVC=C
	;
START	; Build Mumps program
	;
	;
BLD	K BLD,^TMP($J,998),^(999)
	;
	S EXTSID=SID
	;
	; Data entry pre/post processor
	;
	I '$D(^DBTBL(%LIBS,2,SID,0,1)) G SKIP1 ; PRE-PROCESSOR
	K ON,ZIPP S X=0.99 
	F I=1:1 S X=$O(^DBTBL(%LIBS,2,SID,0,X)) Q:X=""!(X>20)  S ZIPP(I)=^(X)
	D ^DBSPARS
	S ^TMP($J,998,1)="VDEPRE ; Data Entry Pre-processor",^(2)=" ;"
	;
	S X="" F I=3:1 S X=$O(OM(X)) Q:X=""  S ^TMP($J,998,I)=OM(X)
	S ^(I+1)=" Q"
	;
	;
SKIP1	K OM,ZIPP
	I '$D(^DBTBL(%LIBS,2,SID,0,21)) G SKIP2 ; POST-PROCESSOR
	;
	S X=20.99
	F I=1:1 S X=$O(^DBTBL(%LIBS,2,SID,0,X)) Q:X=""!(X>40)  S ZIPP(I)=^(X)
	D ^DBSPARS
	S X="" F I=1:1 S X=$O(OM(X)) Q:X=""  S ^TMP($J,999,I)=OM(X)
SKIP2	K OM
	;
	;
	;
	; User Defined VLOD section ??
	;
	I $D(^DBTBL(%LIBS,2,SID,0,101)) D SUBVLOD G BLD2A
	;
	D ^DBSREL I ER D ERR^DBSBLD I ER Q
	;
	S L=0,FID=PFID D FLD^DBSBLD
	S AR=""
	;
BLD2A	; Entry tag if user has defined access section VLOD
	;      %FILE(array) does not get defined
	;
	I %LOOP S VNEW(1)=" D VLOD" ; Skip VNEW section for repeat region
	;
	S %TIM=$$TIM^%ZM			; 04/30/93 BC
	S C=" ;",QUIT=" Q"
	I '%LOOP G REG
	S X41=" ;" I SAVT S X41=" F I="_(SAVT+1)_":1:%MAX S %TAB(I)="_Q_Q
	S C1=" K VSCRPP,REQ,%TAB,vtab,%MOD,%MODOFF S %MODOFF="_%OFF
	G BLD3
	;
REG	S X41=" ; "
	;
BLD3	;
	I $D(BLD(2)),$P(BLD(2)," ;",1)="EXEC" S BLD(2)="VLOD ; Load data from disc - %O = (1-5)"
	I %LOOP S BLD(2.5)=" I '$D(%REPEAT) S %REPEAT="_(23-%LOOP)
	I %LOOP S BLD(2.55)=" I '$D(%MODS) S %MODS=1",VSAV(1,"%MODS")="",VSAV(1,"%REPEAT")=""
	G ^DBSSCR4
	;
SUBVLOD	; Substitute VLOD with user defined access section
	;
	K BLD S BLD(1)="VLOD ; User defined access section",BLD(1.1)=" ;"
	;
	K ZIPP,OM
	S X=100.99 F I=1:1 S X=$O(^(X)) Q:X=""!(X>120)  S ZIPP(I)=^(X)
	D ^DBSPARS
	;
	S X="" F I=3:.001 S X=$O(OM(X)) Q:X=""  S BLD(I)=OM(X)
	K OM
	;
	I '%LOOP S VNEW(100)=" D VLOD"
	;
	Q
