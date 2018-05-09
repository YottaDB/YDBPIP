%ZBREAK()	;Public;Enable/disable BREAK - Return break status
	;;Copyright(c) Sanchez Computer Associates, Inc.  All Rights Reserved - // - 
	; ORIG:  Dan S. Russell (2417) - 11/11/88
	;
	; Return break status and, if break enabled, action to execute.
	;
	;            $$^%ZBREAK=1|execute string -  if break enabled
	;                      =0 if break not enabled
	;
	; The execute string is the contents of $ZT.  This provides
	; the ability for the calling program (e.g., DATA-QWIK) to
	; perform this action instead of simply breaking since the
	; user should be put at a GT.M level only if their $ZT
	; value is "Break".  By returning $ZT, if $ZT is "B",
	; a break will occur, otherwise, the $ZT action will
	; occur, which generally would ignore the interrupt and
	; ZGOTO a higher stack level.
	;
	; The values 1 and 0 are being retained for backwards
	; compatibility.
	;
	; Enable or Disable BREAKS in GT.M
	; M/VX version also exists.
	;
	; KEYWORDS: System services
	;
	; LIBRARY:
	;     . ENABLE^%ZBREAK	- Enable break
	;     . DISABLE^%ZBREAK	- Disable break
	;
	;____ Revision History -------------------------------------------------
	; 10/12/92 -	Dan Russell
	;		Added return of $ZT if breaks are enabled.  Will provide
	;		executable string for application to use to either
	;		break or execute error trap contents.
	;-----------------------------------------------------------------------
	;
	N N,X
	;
	ZSH "D":X
	;
	S N=""
	F  S N=$O(X("D",N)) Q:N=""  I $P(X("D",N)," ",1)=$P,X("D",N)'["NOCENE" Q
	I N="" Q 0				; Break disabled
	Q "1|"_$ZT				; Break enabled
	;
	;----------------------------------------------------------------------
ENABLE	;Public;Enable breaks
	;----------------------------------------------------------------------
	;
	; KEYWORDS: System services
	;----------------------------------------------------------------------
	;
	U 0:(CENABLE:CTRAP=$C(3))
	Q
	;
	;----------------------------------------------------------------------
DISABLE	;Public;Disable breaks
	;----------------------------------------------------------------------
	;
	; KEYWORDS: System services
	;----------------------------------------------------------------------
	;
	U 0:(NOCENABLE:CTRAP="")
	Q
