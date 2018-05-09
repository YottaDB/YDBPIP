 ; 
 ; **** Routine compiled from DATA-QWIK Procedure %DBAPI ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
 ;
 ; *******************************************************************
 ; * IMPORTANT NOTE:                                                 *
 ; * According to the rules that apply to PSL compiler upgrades,     *
 ; * the generated M routine associated with this procedure must be  *
 ; * checked into StarTeam and released with the procedure whenever  *
 ; * changes are made to this procedure.  The M routine from the     *
 ; * crtns directory should be used for this purpose.                *
 ; *                                                                 *
 ; * The M routine will be loaded to the mrtns directory during      *
 ; * upgrades and will then be removed from that directory as part   *
 ; * of the upgrade process.  Therefore, other during an upgrade,    *
 ; * an mrtns version of this routine should not exist.              *
 ; *                                                                 *
 ; * Keep these comments as single line to ensure they exist in the  *
 ; * generated M code.                                               *
 ; *******************************************************************
 ;
 ;  #PACKAGE framework
 ;  #OPTION ResultClass ON
 ;
 Q  ; No calls from top
 ;
DBCNCT(inipath,index,ermsg) ; Return message
 ;
 N status S status=0
 ;
 I ($get(index)="") S index=0
 ;
 ;  #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &libdbapi.connect(inipath,index,.ermsg,.status)
 ;*** End of code by-passed by compiler ***
 ;
 Q status
 ;
DBCONNECT(inipath,index) ; DBhandles index  /NONULL
 ;
 N status S status=0
 N ermsg S ermsg=""
 ;
 ;  #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &libdbapi.connect(inipath,index,.ermsg,.status)
 ;*** End of code by-passed by compiler ***
 ;
 I (status<0) S $ZE="0,"_$ZPOS_","_"%PSL-E-DBAPIFAIL,"_$$transermsg(ermsg),$EC=",U1001,"
 ;
 Q ""
 ;
DBDSCNCT(index,ermsg) ; Return message
 ;
 N status S status=0
 ;
 ;  #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &libdbapi.disconnect(index,.ermsg,.status)
 ;*** End of code by-passed by compiler ***
 ;
 Q status
 ;
DBDISCONNECT(index) ; DBhandles index /NONULL
 ;
 N status S status=0
 N ermsg S ermsg=""
 ;
 ;  #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &libdbapi.disconnect(index,.ermsg,.status)
 ;*** End of code by-passed by compiler ***
 ;
 I (status<0) S $ZE="0,"_$ZPOS_","_"%PSL-E-DBAPIFAIL,"_$$transermsg(ermsg),$EC=",U1001,"
 ;
 Q ""
 ;
EXECUTE(index,sqlmsg,del,list,ermsg) ; Return message
 ;
 N status S status=0
 ;
 I ($get(index)="") S index=0
 I ($get(del)="") S del=$char(124)
 ;
 ;  #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &libdbapi.execute(index,sqlmsg,del,$G(list),.ermsg,.status)
 ;*** End of code by-passed by compiler ***
 ;
 Q status
 ;
EXECUTESQL(index,sqlmsg,del,list) ; Bind variable list
 ;
 N status S status=0
 N ermsg S ermsg=""
 ;
 ;  #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &libdbapi.execute(index,sqlmsg,del,list,.ermsg,.status)
 ;*** End of code by-passed by compiler ***
 ;
 I (status<0) S $ZE="0,"_$ZPOS_","_"%PSL-E-DBAPIFAIL,"_$$transermsg(ermsg),$EC=",U1001,"
 ;
 Q ""
 ;
LOBUPDATE(index,rdbtable,lobcol,where,lobval,del,list) ; WHERE clause bind variable list /NONULL
 ;
 N status S status=0
 N ermsg S ermsg=""
 ;
 ;  #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &libdbapi.lobupdate(index,rdbtable,lobcol,where,lobval,del,list,.ermsg,.status)
 ;*** End of code by-passed by compiler ***
 ;
 I (status<0) S $ZE="0,"_$ZPOS_","_"%PSL-E-DBAPIFAIL,"_$$transermsg(ermsg),$EC=",U1001,"
 ;
 Q ""
 ;
ROLLBACK(index) ; DBhandles index /NONULL
 ;
 N status S status=0
 N ermsg S ermsg=""
 ;
 ;  #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &libdbapi.rollback(index,.ermsg,.status)
 ;*** End of code by-passed by compiler ***
 ;
 I (status<0) S $ZE="0,"_$ZPOS_","_"%PSL-E-DBAPIFAIL,"_$$transermsg(ermsg),$EC=",U1001,"
 ;
 Q ""
 ;
SELECT(index,sqlmsg,del,list,data,ermsg) ; Return message
 ;
 N status S status=0
 ;
 I ($get(index)="") S index=0
 ;
 ;  #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &libdbapi.select(index,sqlmsg,del,$G(list),.data,.ermsg,.status)
 ;*** End of code by-passed by compiler ***
 ;
 Q status
 ;
SELECTDATA(index,sqlmsg,del,list) ; Bind variable list
 ;
 N status S status=0
 N data
 N ermsg S ermsg=""
 ;
 ;  #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &libdbapi.select(index,sqlmsg,del,list,.data,.ermsg,.status)
 ;*** End of code by-passed by compiler ***
 ;
 I (status<0) S $ZE="0,"_$ZPOS_","_"%PSL-E-DBAPIFAIL,"_$$transermsg(ermsg),$EC=",U1001,"
 ;
 Q data
 ;
OPENCUR(index,sqlmsg,del,list,cid,data,ermsg) ; Return message
 ;
 N status S status=0
 ;
 I ($get(index)="") S index=0
 ;
 ;  #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &libdbapi.opencursor(index,sqlmsg,del,list,.cid,.data,.ermsg,.status)
 ;*** End of code by-passed by compiler ***
 ;
 Q status
 ;
OPENCURSOR(index,sqlmsg,del,list,cid) ; Cursor ID
 ;
 N status S status=0
 N data
 N ermsg S ermsg=""
 ;
 ;  #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &libdbapi.opencursor(index,sqlmsg,del,list,.cid,.data,.ermsg,.status)
 ;*** End of code by-passed by compiler ***
 ;
 I (status<0) S $ZE="0,"_$ZPOS_","_"%PSL-E-DBAPIFAIL,"_$$transermsg(ermsg),$EC=",U1001,"
 ;
 Q data
 ;
CLOSECUR(index,cid,ermsg) ; Return message
 ;
 N status S status=0
 ;
 I ($get(index)="") S index=0
 ;
 ;  #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &libdbapi.closecursor(index,cid,.ermsg,.status)
 ;*** End of code by-passed by compiler ***
 ;
 Q status
 ;
CLOSECURSOR(index,cid) ; Cursor ID
 ;
 N status S status=0
 N ermsg
 ;
 ;  #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &libdbapi.closecursor(index,cid,.ermsg,.status)
 ;*** End of code by-passed by compiler ***
 ;
 I (status<0) S $ZE="0,"_$ZPOS_","_"%PSL-E-DBAPIFAIL,"_$$transermsg(ermsg),$EC=",U1001,"
 ;
 Q ""
 ;
FETCH(index,cid,rows,del,data,ermsg) ; Return message
 ;
 N status S status=0
 ;
 I ($get(index)="") S index=0
 ;
 ;  #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &libdbapi.fetch(index,cid,.rows,del,.data,.ermsg,.status)
 ;*** End of code by-passed by compiler ***
 ;
 Q status
 ;
FETCHDATA(index,cid,rows,del) ; Host variable list delimiter /NONULL
 ;
 N status S status=0
 N data
 N ermsg S ermsg=""
 ;
 ;  #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &libdbapi.fetch(index,cid,.rows,del,.data,.ermsg,.status)
 ;*** End of code by-passed by compiler ***
 ;
 I (status<0) S $ZE="0,"_$ZPOS_","_"%PSL-E-DBAPIFAIL,"_$$transermsg(ermsg),$EC=",U1001,"
 ;
 Q data
 ;
COMMIT(index,ermsg) ; Return message
 ;
 N status S status=0
 ;
 I ($get(index)="") S index=0
 ;
 ;  #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &libdbapi.commit(index,.ermsg,.status)
 ;*** End of code by-passed by compiler ***
 ;
 Q status
 ;
COMMITTRAN(index) ; DBhandles index  /NONULL
 ;
 N status S status=0
 N ermsg S ermsg=""
 ;
 ;  #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &libdbapi.commit(index,.ermsg,.status)
 ;*** End of code by-passed by compiler ***
 ;
 I (status<0) S $ZE="0,"_$ZPOS_","_"%PSL-E-DBAPIFAIL,"_$$transermsg(ermsg),$EC=",U1001,"
 ;
 Q ""
 ;
EXECSP(index,procname,colval,nocols,del,data,ermsg) ; Return message
 ;
 N status S status=0
 ;
 I ($get(index)="") S index=0
 ;
 ;  #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &libdbapi.storedproc(index,procname,$G(colval),nocols,$G(del),.data,.ermsg,.status)
 ;*** End of code by-passed by compiler ***
 ;
 Q status
 ;
EXECUTESP(index,procname,colval,nocols,del) ; Host variable list delimiter /NONULL
 ;
 N status S status=0
 N data
 N ermsg S ermsg=""
 ;
 ;  #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &libdbapi.storedproc(index,procname,colval,nocols,del,.data,.ermsg,.status)
 ;*** End of code by-passed by compiler ***
 ;
 I (status<0) S $ZE="0,"_$ZPOS_","_"%PSL-E-DBAPIFAIL,"_$$transermsg(ermsg),$EC=",U1001,"
 ;
 Q data
 ;
EXECCP(index,procname,collist,tablenam,cond,hostval) ; Host variable values
 ;
 N status S status=0
 N ermsg S ermsg=""
 ;
 ;  #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &libdbapi.createproc(index,procname,collist,tablenam,cond,hostval,.ermsg,.status)
 ;*** End of code by-passed by compiler ***
 ;
 I (status<0) S $ZE="0,"_$ZPOS_","_"%PSL-E-DBAPIFAIL,"_$$transermsg(ermsg),$EC=",U1001,"
 ;
 Q ""
 ;
CQSTART() ; 
 ;
 N errnum S errnum=0
 N ermsg S ermsg=""
 N return S return=""
 ;
 ;  #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &srvapi.CurQStart(.errnum)
 if (errnum'=0),(errnum'=-39) set ermsg=$ZM(errnum)
 ;*** End of code by-passed by compiler ***
 ;
 I (errnum=-39) S return="CS_CQEXISTS"
 E  I (+errnum'=+0) S return="CS_ERROR|"_ermsg
 ;
 Q return
 ;
CQSTOP() ; 
 ;
 N errnum S errnum=0
 N ermsg S ermsg=""
 N return S return=""
 ;
 ;  #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &srvapi.CurQStop(.errnum)
 if (errnum'=0),(errnum'=-40) set ermsg=$ZM(errnum)
 ;*** End of code by-passed by compiler ***
 ;
 I (errnum=-40) S return="CS_CQNOEXISTS"
 E  I (+errnum'=+0) S return="CS_ERROR|"_ermsg
 ;
 Q return
 ;
SVXCHMSG(msgtyp,svid,msg,reply,timeout) ; Timeout interval [*]  /NONULL
 ;
  ; See comments, above
 ;
 N isDone S isDone=0
 N errnum N start N timeleft
 N return S return=""
 ;
 S errnum=0
 S start=($P($H,",",1)*100000)+$P($H,",",2)
 S timeleft=timeout
 ;
 ;  #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &srvapi.SrvExchMsg(msgtyp,svid,.msg,.reply,timeout,.errnum)
 if (errnum<0),(errnum'=-10) set RM=$ZM(errnum)
 ;*** End of code by-passed by compiler ***
 ;
 ; If error, exit with error return
 I (errnum=-10) Q "CS_TIMEOUT"
 I (errnum<0) Q "CS_ERROR"
 ;
 ; If the message headers match (bytes 1-10), return to caller.
 I ($E(reply,1,10)=$E(msg,1,10)) Q ""
 ;
 F  D  Q:isDone 
 .	;
 .	S timeleft=timeout-((($P($H,",",1)*100000)+$P($H,",",2))-start)
 .	I (timeleft<0) D  Q 
 ..		;
 ..		S return="CS_TIMEOUT"
 ..		S isDone=1
 ..		Q 
 .	;
 .	;   #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 .	;*** Start of code by-passed by compiler
 .	do &srvapi.SrvGetReply(msgtyp,.reply,timeleft,.errnum)
 .	if (errnum<0),(errnum'=-10) set RM=$ZM(errnum)
 .	;*** End of code by-passed by compiler ***
 .	;
 .	; If error, set return and exit
 .	I (errnum=-10) D  Q 
 ..		;
 ..		S return="CS_TIMEOUT"
 ..		S isDone=1
 ..		Q 
 .	I (errnum<0) D
 ..		;
 ..		S return="CS_ERROR"
 ..		S isDone=1
 ..		Q 
 .	;
 .	; If the message headers match (bytes 1-10), return to caller.
 .	I ($E(reply,1,10)=$E(msg,1,10)) S isDone=1
 .	Q 
 ;
 Q return
 ;
CPCNCT() ; 
 ;
  ; See comments in SVXCHMSG
 ;
 N errnum S errnum=0
 N ermsg S ermsg=""
 N return S return=""
 ;
 ;  #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &curapi.CurConnect(.errnum)
 if (errnum'=0),(errnum'=-41) set RM=$ZM(errnum)
 ;*** End of code by-passed by compiler ***
 ;
 I (errnum=-41) D
 .	;
 .	S return="CS_DUPLCNCT"
 .	S RM="Already connected"
 .	Q 
 E  I (+errnum'=+0) S return="CS_ERROR"
 ;
 Q return
 ;
CPDSCNCT() ; 
 ;
 ;  #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &curapi.CurDisconnect()
 ;*** End of code by-passed by compiler ***
 ;
 Q ""
 ;
CPGETMSG(msgtyp,msg,timeout) ; Timeout interval [*] /NONULL
 ;
  ; See comments in SVXCHMSG
 ;
 N errnum S errnum=0
 N return S return=""
 ;
 S msg=""
 ;
 ;  #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &curapi.CurGetMsg(msgtyp,.msg,timeout,.errnum)
 if (errnum<0),(errnum'=-10),(errnum'=-42) set RM=$ZM(errnum)
 ;*** End of code by-passed by compiler ***
 ;
 I (errnum=-42) D
 .	;
 .	S RM="Not Connected"
 .	S return="CS_NOCNCT"
 .	Q 
 E  I (errnum=-10) D
 .	;
 .	S RM="Timed Out"
 .	S return="CS_TIMEOUT"
 .	Q 
 E  I (errnum<0) S return="CS_ERROR"
 ;
 Q return
 ;
CPREPLY(msgtyp,reply) ; Reply message to server
 ;
  ; See comments in SVXCHMSG
 ;
 N errnum S errnum=0
 N return S return=""
 ;
 ;  #ACCEPT Date=09/10/2007; Pgm=RussellDS; CR=29295; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &curapi.CurReply(msgtyp,.reply,.errnum)
 if (errnum<0),(errnum'=-42) set RM=$ZM(errnum)
 ;*** End of code by-passed by compiler ***
 ;
 I (errnum=-42) D
 .	;
 .	S RM="Not Connected"
 .	S return="CS_NOCNCT"
 .	Q 
 E  I (errnum<0) S return="CS_ERROR"
 ;
 Q return
 ;
ROWINS(index,sqlmsg,del,list) ; host variable values (*1)
 ;
 N status S status=0
 N ermsg S ermsg=""
 ;
 ;  #ACCEPT Date=10/06/2008; Pgm=RussellDS; CR=29132; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &libdbapi.execute(index,sqlmsg,del,list,.ermsg,.status)
 ;*** End of code by-passed by compiler ***
 ;
 I (status<0) D
 .	; Deal with the ORA-00001 error, provided $TRESTART<3
 .	;   #ACCEPT Date=10/06/2008; Pgm=RussellDS; CR=29132; Group=Bypass
 .	;*** Start of code by-passed by compiler
 .	IF $PIECE(ermsg,":")["ORA-00001",$TRESTART<3 TRESTART
 .	;*** End of code by-passed by compiler ***
 .	;
 .	; Other error, or too many restarts
 .	S $ZE="0,"_$ZPOS_","_"%PSL-E-RDBSAVEFAIL,"_$translate(ermsg,$char(10)_","," ~"),$EC=",U1001,"
 .	Q 
 ;
 Q 
 ;
ROWUPD(index,sqlmsg,del,list) ; host variable values
 ;
 N status S status=0
 N ermsg S ermsg=""
 ;
 ;  #ACCEPT Date=10/06/2008; Pgm=RussellDS; CR=29132; Group=Bypass
 ;*** Start of code by-passed by compiler
 do &libdbapi.execute(index,sqlmsg,del,list,.ermsg,.status)
 ;*** End of code by-passed by compiler ***
 ;
 Q:(status>0) 
 ;
 I (status=0) D  ; no rows updated !
 .	N retry
 .	;   #ACCEPT Date=10/06/2008; Pgm=RussellDS; CR=29132; Group=Bypass
 .	;*** Start of code by-passed by compiler
 .	SET retry=$TRESTART IF $TRESTART<3 TRESTART
 .	;*** End of code by-passed by compiler ***
 .	S $ZE="0,"_$ZPOS_","_"%PSL-E-RDBSAVEFAIL,Update failed after "_retry_" tries,"_$translate(sqlmsg,",","~"),$EC=",U1001,"
 .	Q 
 ;
 ; Deal with the ORA-00060 error, provided $TRESTART<3
 ;  #ACCEPT Date=10/06/2008; Pgm=RussellDS; CR=29132; Group=Bypass
 ;*** Start of code by-passed by compiler
 IF $PIECE(ermsg,":")["ORA-00060",$TRESTART<3 TRESTART
 ;*** End of code by-passed by compiler ***
 ;
 ; Other error, or too many restarts
 S $ZE="0,"_$ZPOS_","_"%PSL-E-RDBSAVEFAIL,"_$translate($get(ermsg),$char(10)_","," ~"),$EC=",U1001,"
 Q 
 ;
transermsg(ermsg) ; Error message
 ;
 Q $translate(ermsg,$char(10)_$char(44),$char(32)_$char(126))
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61298^36638^Dan Russell^27312" ; Signature - LTD^TIME^USER^SIZE
