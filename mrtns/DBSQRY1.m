DBSQRY1	;;DBS - U - V5.0 - SET UP DQ QUERY DEFINITIONS
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/30/94 09:14:31 - XUS
	;     ORIG:  BOB CHIANG (8447) - 08/26/86
	;     DESC:  QUERY DEFINITIONS
	;      SET:  ^DBTBL(%LIBS,4,RID)
	;
	;---------- Revision History -------------------------------------------
	; 03/03/06 - RussellDS - CR19065
	;	     Modified to use QRY array for repeating region.
	;
	; 09/28/04 - RussellDS - CR12334
	;	     Replaced obsoleted calls to ^DBSANS with new procedure
	;	     DBSGETID.
	;
	;	     Added parameters to COPY^DBSUTL and DEL^DBSUTL.
	;
	; 09/28/94 - Shaodong Tony Xu - 10174
	;            Modified the routines.
	;
	; 05/16/94 - Bob Chiang - I18N#7
	;
	;            Modified return message handling with a call to extrinsic
	;            function $$^MSG(msgid,p1,p2...) for I18N development
	;            (phrase independence).
	;
	; 09/10/93  Bob Chiang (SCA)
	;
	;           Modified to remove print logic from LIST section 
	;           (replaced with DQ report).
	;
	; 02/24/93  Bob Chiang
	;
	;           Modified to replace $D(%TAB) references with VFMQ="Q" after
	;           calling a screen to verify the user action.
	;-----------------------------------------------------------------------
CREATE	;
	;
	; Create new definitions
	;
	S QID=$$FIND^DBSGETID("DBTBL4",1) Q:QID=""
	S %O=0 S SID="DBTBL4" D ^USID D ^@PGM I VFMQ="Q" G CREATE
	D FILE
	S DBOPT=4,ID=QID,DQFUN="A" D ^DBSUTL3 ; Create new index
	;
	G CREATE
	;
MODIFY	;
	;
	; Modify definitions
	;
	S QID=$$FIND^DBSGETID("DBTBL4",0) Q:QID=""
	S %O=1 S SID="DBTBL4" D ^USID D ^@PGM I VFMQ="Q" G MODIFY
	S DBOPT=4,ID=QID,DQFUN="D" D ^DBSUTL3 ; Remove old index
	K ^DBTBL(%LIBS,4,QID)
	D FILE
	S ID=QID,DQFUN="A" D ^DBSUTL3 ; Create new index
	G MODIFY
	;
FILE	;
	;
	; File data
	;
	K ^DBTBL(%LIBS,4,QID)
	;
	S ^DBTBL(%LIBS,4,QID)=%A
	;
	S $P(%A(0),"|",15)=$$USERNAM^%ZFUNC ; User Id
	;
	S $P(%A(0),"|",3)=+$H,^(QID,0)=%A(0)
	S SEQ=1 F I=1:1 Q:'$D(QRY(I))  I QRY(I)'="" S ^DBTBL(%LIBS,4,QID,SEQ)=QRY(I),SEQ=SEQ+1
	X KVAR Q
	;
	; data item post-processor (FILES) on screen (DBTBL4)
	;
	;
	; Delete Definitions
	;
DELETE	;
	;
	D INIT,DEL^DBSUTL("DBTBL4") Q
	;
COPY	;
	;
	D INIT,COPY^DBSUTL("DBTBL4") Q
	;
LIST	;
	;
	D INIT
	N CNT,IO
	S CNT=$$LIST^DBSGETID("DBTBL4","List",.IO) Q:'CNT
	D OPEN^SCAIO
	;
	S %BLK="/,"_IO S RID="DBSQRYLST" D DRV^URID
	Q
	;
INIT	;
	; Query Definition
	S RN=$$^MSG("5191"),DBOPT=4
	S SID="DBTBL4" D ^USID S DQSCR="^"_PGM
	Q
