	G:$P($ZCMDLINE," ",1)["^" TIED U 0:(CEN:CTRAP=$C(3,25)) S $ZT="B" F  B  ; Direct mode
	;
SCADMOD	;SCA direct mode driver - invokes direct mode, then breaks
	;NOTE:  Leave break at line 1 to provide +1^SCADMOD message
	;Link with [SCAMGR.ZCALL]SCAZCALL to allow access to $ZCall functions
	;  from direct mode
	;
	; If modifying, be sure to leave direct mode on top line so that
	; direct mode break occurs at +1^SCADMOD
	;
TIED	; Provide ability to run a "tied" program through command line input
	; See SCA$RTNS:TIED_PGM.COM
	;
	U 0:(CTRAP=$C(3,25))
	S $ZT=""
	D @$ZCMDLINE ; Format for command line is ^rtn or tag^rtn
	Q
