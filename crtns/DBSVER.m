DBSVER	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSVER ****
	;
	; 11/08/2007 14:08 - chenardp
	;
	;
	; **********************************************************************
	; * IMPORTANT NOTE:                                                    *
	; * According to the rules that apply to PSL compiler upgrades,        *
	; * the generated M routine associated with this procedure must be     *
	; * checked into StarTeam and released with the procedure whenever     *
	; * changes are made to this procedure.                                *
	; *                                                                    *
	; * The mrtns version will be used during upgrades and will then be    *
	; * removed from the mrtns directory.  Therefore, other than in a      *
	; * development environment, or during an upgrade, an mrtns version of *
	; * this routine should not exist.                                     *
	; *                                                                    *
	; * Keep these comments as single line to ensure they exist in the     *
	; * generated M code.                                                  *
	; **********************************************************************
	;
	Q  ; No entry from top
	;
VAL(typ,len,req,tbl,pat,min,max,dec,noc,dinam,mode,tbldesc)	;
	;
	N ER S ER=0
	N return
	;
	I $get(req),(X=""),(typ'="L") Q $$REQERR ; Required
	;
	I (X="") Q ""
	;
	I ($get(len)>0),($L(X)>len) Q $$LENERR(len)
	;
	I ((typ="N")!(typ="$")),($get(dec)>0),($L($piece(X,".",1)))>(len-dec-1) Q $$LENERR((len-dec-1)_"."_dec)
	;
	I ((typ="T")!(typ="U")),'($get(noc)=""),($translate(X,noc,"")'=X) Q $$DELERR($ascii(noc))
	;
	I (typ="L"),'((X=1)!(X=0)) Q $$TYPERR(typ)
	;
	I (typ="F") D  Q return
	.	;
	.	N vx S vx=X
	.	;
	.	D DBSEDT^UFRE($get(dinam),$get(mode))
	.	;
	.	; Force redisplay of frequency in DBSCRT interactive mode
	.	I 'ER,(vx'=X) D
	..		;
	..		S vdsp=2 ; Re-display flag
	..		;
	..		; Poke value back into buffer
	..		I ($D(vdft(NI))#2) S $piece(vdft(NI),"|",1)=X
	..		Q 
	.	;
	.	I ER S return=$$FRQERR
	.	E  S return=""
	.	Q 
	;
	I ((typ="D")!(typ="C")),(X'?.N) Q $$TYPERR(typ)
	;
	I (typ="N"),(+$get(dec)=0),(X[".") Q $$TYPERR(typ)
	;
	I ((typ="N")!(typ="$")) D  I '(return="") Q return
	.	;
	.	S return=""
	.	;
	.	I '($translate(X,"0123456789-.","")="") S return=$$TYPERR(typ)
	.	E  I ($E(X,2,1048575)["-") S return=$$TYPERR(typ)
	.	E  I ($L(X,".")>2) S return=$$TYPERR(typ)
	.	E  I ($get(dec)>0),($L($piece(X,".",2))>dec) S return=$$DECERR(dec)
	.	Q 
	;
	I '($get(min)=""),$$vmin(X,.min,typ) Q $$MINERR($$EXT^%ZM(min,typ,dec))
	;
	I '($get(max)=""),$$vmax(X,.max,typ) Q $$MAXERR($$EXT^%ZM(max,typ,dec))
	;
	I '($get(pat)="") D  I '(return="") Q return
	.	;
	.	I '(($E(pat,1,2)="I ")!($E(pat,1,3)="if ")) S pat="if "_pat
	.	;
	.	S return=""
	.	;
	.	;          #ACCEPT Date=12/20/05; Pgm=RussellDS; CR=18400
	.	XECUTE pat
	.	E  S return=$$PATERR(pat)
	.	Q 
	;
	I '($get(tbl)="") S tbldesc=$$VER^DBSTBL(tbl,X,typ) I (tbldesc="") Q $$TBLERR(X)
	;
	Q ""
	;
vmin(X,min,typ)	;
	;
	N jrnfunc,vop1 S jrnfunc=$$vDb3(min,.vop1)
	;
	I ($G(vop1)>0) D
	.	;
	.	;   #ACCEPT Date=12/20/05; Pgm=RussellDS; CR=18400
	.	XECUTE "set min="_$P(jrnfunc,$C(124),2)
	.	Q 
	;
	I ($E(min,1,2)="<<"),($E(min,$L(min)-2+1,1048575)=">>") S min=$$var(min)
	;
	I ("DC$N"[typ),(X<min) Q 1
	;
	I ("TUFL"[typ),(min]X) Q 1
	;
	Q 0
	;
vmax(X,max,typ)	;
	;
	;----------------------------------------------------------------------
	;
	N jrnfunc,vop1 S jrnfunc=$$vDb3(max,.vop1)
	;
	I ($G(vop1)>0) D
	.	;
	.	;   #ACCEPT Date=12/20/05; Pgm=RussellDS; CR=18400
	.	XECUTE "set max="_$P(jrnfunc,$C(124),2)
	.	Q 
	;
	I ($E(max,1,2)="<<"),($E(max,$L(max)-2+1,1048575)=">>") S max=$$var(max)
	;
	I ("DC$N"[typ),(X>max) Q 1
	;
	I ("TUFL"[typ),(X]max) Q 1
	;
	Q 0
	;
var(X)	; Variable << >> syntax
	;
	N return S return=""
	;
	S X=$E(X,3,$L(X)-2) ; Strip << >>
	;
	I ((X?1A.AN)!(X?1"%".AN)) Q $get(@X) ; Local variable
	;
	I (X?1"$$"1E.E) D  Q return ; $$^routine
	.	;
	.	;   #ACCEPT Date=12/20/05; Pgm=RussellDS; CR=18400
	.	XECUTE "set return="_X
	.	Q 
	;
	I ((X?1A.AN1"("1E.E1")")!(X?1"%".AN1"("1E.E1")")) Q $get(@X) ; Local array
	;
	Q X ; Literal
	;
	; *********************************************************************
	; * NOTE:  The error message functions below are for use only by this *
	; *        procedure and are not be be called externally.             *
	; *********************************************************************
	;
DECERR(dec)	; Decimal error NN.~p1
	;
	Q $$^MSG(774,$E("NNNNNNNNNNNNNNNNNNNN",1,dec))
	;
DELERR(del)	; Invalid input, replace vertical bar character with $C(~p1)
	;
	Q $$^MSG(1380,del)
	;
FRQERR()	; Frequency error
	;
	I ($D(RM)#2) Q RM
	;
	Q $$TYPERR("F")
	;
LENERR(len)	; Field length ~p1 exceeded
	;
	Q $$^MSG(1076,len)
	;
MAXERR(X)	; Value above maximum range ~p1
	;
	Q $$^MSG(2919,X)
	;
MINERR(X)	; Value below minimum range ~p1
	;
	Q $$^MSG(2920,X)
	;
PATERR(pat)	; Invalid format ~p1
	;
	Q $$^MSG(1350,pat)
REQERR()	; Data Required
	;
	Q $$^MSG(741)
	;
TBLERR(val)	; Invalid table value ~P1
	;
	Q $$^MSG(1485,val)
	;
TYPERR(typ)	; Data type is defined as ~p1
	N vret
	;
	N dvfm S dvfm=$G(^DBCTL("SYS","DVFM",typ))
	;
	S vret=$$^MSG(742,$P(dvfm,$C(124),1)) Q vret
	;
vSIG()	;
	Q "60257^35149^Dan Russell^6819" ; Signature - LTD^TIME^USER^SIZE
	;
vDb3(v1,v2out)	;	voXN = Db.getRecord(STBLJRNFUNC,,1,-2)
	;
	N jrnfunc
	S jrnfunc=$G(^STBL("JRNFUNC",v1))
	I jrnfunc="",'$D(^STBL("JRNFUNC",v1))
	S v2out='$T
	;
	Q jrnfunc
