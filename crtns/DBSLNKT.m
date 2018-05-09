DBSLNKT	;DBS - U - V7.0 - Multiple page screens base program
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSSCRTMP ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
V0	;
V1	;
	S:'($D(%PG)#2) %PG=1 S %PGSV=%PG S MULSCR=""
	;
VNEW	; Initailize new record
	Q 
	;
VPG	;
	;
VPG0	;
	;
VPAGE	;
	;
VBTM	;
	I %O=4,IO'=$P Q 
	D ^DBSCRT8A
	Q 
	;
vSIG()	;
	Q "60680^50161^Pete Chenard^761" ; Signature - LTD^TIME^USER^SIZE
