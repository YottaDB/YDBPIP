DBSUTL9	;; -  - V5.0 - REBUILD DATA-QWIK INTERNAL X-REF FILES
	;;Copyright(c)1996 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/23/96 13:37:06 - CHIANG
	;     ORIG:  BOB CHIANG (8447) - 05/09/89
	;     DESC: Build DATA-QWIK index files
	;
	;----------------------------------------------------------------------
	; 10/23/96 - Bob Chiang - 20948
	;            Modified to remove file implicit logic.
	;
	; 10/28/94 - Bob Chiang - ARA 18
	;            Reolaced $$^MSG calls with $$^DBSMBAR.
	;----------------------------------------------------------------------
START	;
	I $$^DBSMBAR(166)'=2 Q			; *** 10/28/94 BC
	;
	; External interface
	;
	;
%EXT	;
	N (%LIBS)
	;
	I $G(%LIBS)="" S %LIBS=$G(^CUVAR("%LIBS"))
	;
	; *** 10/23/96 removed implicit logic
	;
	; =======  Data Item X-REF file
	;
	; Create Data Item X-REF File
	U 0 W !!,$$^MSG("5198"),!!
	;
	D %EXT^DBSUTL3
	;
	; =======  File Field Id Index File
	;
	; Create File Field Id Index File
	U 0 W !!,$$^MSG("5199"),!!
	;
	D %EXT^DBSDF9
	;
	; =======  Post-Proc X-REF file
	;
	; Create Pre/Post Processor Index File
	U 0 W !!,$$^MSG("5201"),!!
	;
	D %EXT^DBSPP
	Q
