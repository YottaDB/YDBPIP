DBSSCR6	; DBS - U - V4.0 - Screen compiler, Index file logic
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/17/94 10:33:14 - XUS
	;     ORIG:  Bob (8447) - 09/25/89
	;     DESC: CREATE SCREEN INDEX FILE MAINTENANCE LOGIC
        ; I18N=QUIT: Exculded from I18N standards.
	;
	; GLOBALS -  ^DBTBL,^TMP
	;     READ:
	;      SET:  
	;
	;    INPUT:         
	;           
	;      SET:  %INDEX(DINAM)=INDEX OPT | PROT FLAG | KEYS | NS
	;
	;   OUTPUT:
	;
START	;
	;
BUILD	;
	; Convert to run-time MUMPS code
	;
	;   Protected field    ---  create %NEW() for %O=0
	;
	;          S:'%O %NEW(DI)=NS S %INDEX(DI)=^GBL(....)
	;
	;   Data Entry field   ---  create %OLD() for %O=1 or 3
	;
	;          S:(%O=1)!(%O=3) %OLD(DI)=NS S %INDEX(DI)=^GBL(...)
	;
	N (%INDEX,ZINDEX)
	S Q=$C(34),QQ=Q_Q
	;
	S SEQ=1,DINAM=""
	S ZINDEX(1)=" I %O=2!(%O>3) Q  ; Inquiry , Print screen"
NX	;
	;
	S DINAM=$O(%INDEX(DINAM)) I DINAM="" Q
	S X=%INDEX(DINAM)
	S INDEX=$P(X,"|",1),PRO=$P(X,"|",2),KEYS=$P(X,"|",3),NS=$P(X,"|",4,99)
	S FID=$P($P(DINAM,",",2),"]",1),DI=$P(DINAM,"]",2)
	S FID=QQ_FID_QQ,DI=Q_DI_Q,DIQ=Q_DI_Q
	;
	I PRO S Y=" S:%O=0 %NEW("_DI_")="_NS
	;
	E  S Y=" S:%O=1!(%O=3) %OLD("_DI_")="_NS
	;
	; If INDEX="Y" use standard DQ index global name ^XDB
	;
	I INDEX="Y" S Z=" S %INDEX("_DI_")="_Q_"^XDB("_FID_","_DIQ_",X,"_KEYS_")"_Q
	E  S Z=" S %INDEX("_DI_")="_Q_"^"_INDEX_"(X,"_KEYS_")"_Q
	;
	S SEQ=SEQ+1,ZINDEX(SEQ)=" ;",SEQ=SEQ+1,ZINDEX(SEQ)=Y_Z
	G NX
	S SEQ=SEQ+1,ZINDEX(SEQ)=Y,SEQ=SEQ+1,ZINDEX(SEQ)=Z
	G NX
