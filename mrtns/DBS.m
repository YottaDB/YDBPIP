DBS	;;DBS  - 12 DEC 1992 15:04:15 - MATTSON
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/28/94 10:16:28 - CHIANG
	;     ORIG:  CHIANG 1/1/85
	;     DESC:  DBS DRIVER
	;
	; I18N=QUIT: Exculded from I18N standards.; 
	;---- Revision History--------------------------------------------------
	;
	;-----------------------------------------------------------------------
START	;
	D ^SCADRV Q
	Q
KIL	;
	K (%,%EXT,%ED,ER,%EVENT,%ID,%MENU,%NET,%SN,%UCLS,%UFN,%UID,%UNO,%USC,CONAM,DX,DY,ER,PIO,RM,TAB,TJD,TYPE,ZB,CO,%LIBS,%MENU,PGM,RID,NID,%TO,TLO)
	K ^SDB($P),^TMP($J),^DBV($P),^DBT($P)
	Q
	;
EXIT	;
	K ACC Q
	;
	;
