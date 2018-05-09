EDIT(rec,pt,pb,py,px,cmd,key,par,name,help,script)	;public; Full Screen Text Editor
	;;Copyright(c)1998 Sanchez Computer Associates, Inc.  All Rights Reserved - 12/09/98 13:11:20 - CHIANG
	;     ORIG:  FSANCHEZ - 23/JUL/95
	;     DESC:  Pretty good VT Based Full Screen Text Editor
	;
	; KEYWORDS: TEXT EDITOR
	;
	; PARAMETERS:
	;
	;	.rec	Text Array			/REF=
	; 	.pt	Top Line		    	/TYP=N/NOREQ/DEF=0/REF=VAL
	; 	.pb 	Bottom Line			/TYP=N/NOREQ/DEF=21/REF=VAL
	;	.py	Current Y position in buffer
	;	.px	Current X position in buffer
	;	.cmd	Command Array
	;	.key	Function Key Map
	;	.name	Buffer Name
	;	.par	Parameter array
	;	.help	Help Reference
	;	.script	Init Script
	;
	;---- Revision History ------------------------------------------------
	; 05/17/06 - Allan Mattson - CR20048
	;            Replaced calls to $$UPPER^%ZFUNC with $$UPPER^SCAUTL.
	;
	; 12/02/98 - Chiang - 29450
	;            Modified LOADFILE section to return error message if the
	;            source file size is greater than 32K.
	;
	;            Modified INCLUDE section to change language source to M
	;            if the file included is a M routine.
	;
	; 07/14/98 - Chiang - 29413
	;            Modified EDT section to replace platform specific code
	;            with generic call to %OSSCRPT utility. 
	;
	;            Removed old revision history.
	;
	;----------------------------------------------------------------------
	; I18N=QUIT: Excluded from I18N standards. 
	;
	N ay,ax,bfrcmd,bfrdel,bfrlin,c,curfil,cy,cx,dl,end,fnd,i,save,srm,str,ovfl,tmo,rows,undo,vpan,ZB
	N awof,bot,chrins,chrdel,csi,cll,clr,cpr,cps,cuu,cud,cuf,cub,insent,lindel,linins,lock,ovfl,vrev,voff
	N fkey
	;
	S save=$$SAVATT
	;
	D OPEN
	;
	I '$D(rec)#2 S rec=""
	S dl=$C(13,10),tbs=8
	;
	I '$G(pt) S pt=1
	I '$G(pb) S pb=21
	I '$G(py) S py=1
	I '$G(px) S px=1
	;
	S bot=$$BTM^%TRMVT
	S cll=$$CLL^%TRMVT
	S csi=$$CSI^%TRMVT
	S cuu=$$CUU^%TRMVT
	S cud=$$CUD^%TRMVT
	S cub=$$CUB^%TRMVT
	S cps=$C(27)_"7"
	S cpr=$C(27)_"8"
	S vrev=$$VIDREV^%TRMVT
	S voff=$$VIDOFF^%TRMVT
	;
	S chrins=$$CHRINS^%TRMVT
	S chrdel=$$CHRDEL^%TRMVT
	S lock=$$LOCK^%TRMVT(pt,pb)
	S awof=$$SCRAWOFF^%TRMVT
	;
	S linins=$$LININS^%TRMVT
	S lindel=$$LINDEL^%TRMVT
	S insent=cll_dl_linins
	S ovfl=$$GRON^%TRMVT_$C(96)_$$GROFF^%TRMVT
	;
	I '$D(%TO) S %TO=$$TODFT^%ZREAD
	;
	I $D(%fkey)<10 N %fkey D ZBINIT^%TRMVT(.%fkey)
	;
	I '$D(%fkey("[31~")) S %fkey("[31~")="SHR"
	I '$D(%fkey("Oq")) S %fkey("Oq")="WRD"
	I '$D(%fkey("Or")) S %fkey("Or")="EOL"
	I '$D(%fkey("*Ow")) S %fkey("*Ow")="CMD"
	;
	; Map F12 to PF1-7 (cmd) 
	; Map F13 to PF4   (delete line)
	; Map F14 to PF1-2 (end of line)
	;
	S %fkey("[24~")="CMD" 	; F12
	S %fkey("[25~")="DUP"	; F13
	S %fkey("[26~")="EOL"	; F14
	;
	I $D(cmd("SET"))#2=0 S cmd("SET")="D SET^EDIT(1/REQ)"
	I $D(cmd("SAVE"))#2=0 S cmd("SAVE")="D SAVE^EDIT(1/REQ)"
	I $D(cmd("EDIT"))#2=0 S cmd("EDIT")="D EDT^EDIT(1/REQ)"
	I $D(cmd("EXIT"))#2=0 S cmd("EXIT")="D EXIT^EDIT"
	I $D(cmd("QUIT"))#2=0 S cmd("QUIT")="D EXIT^EDIT"
	I $D(cmd("HELP"))#2=0 S cmd("HELP")="D HLP^EDIT"
	I $D(cmd("UNDO"))#2=0 S cmd("UNDO")="D UNDO^EDIT"
	I $D(cmd("CLEAR"))#2=0 S cmd("CLEAR")="D CLEAR^EDIT"
	I $D(cmd("COUNT"))#2=0 S cmd("COUNT")="D COUNT^EDIT(1)"
	I $D(cmd("REPLACE"))#2=0 S cmd("REPLACE")="D REPLACE^EDIT"
	I $D(cmd("INCLUDE"))#2=0 S cmd("INCLUDE")="D INCLUDE^EDIT(1/REQ)"
	I $D(cmd("SPAWN"))#2=0 S cmd("SPAWN")="D SPAWN^EDIT"
	; 
	S ay=0,ax=0,srm=80
	S rows=pb-pt,cy=pt,cx=1,tmo=0,vpan=$J(rows*.7,0)
	S fnd="",bfrdel="",bfrlin=""
	;
	I $G(script)'="" D SCRIPT(script)
	;
	S z="",key="," F  S z=$O(key(z)) Q:z=""  S key=key_z_","
	;
	D REF
	;
	; Delete buffer if the last key used is a F11 (ESC) key *** 09/18/97
	;
	F  D READ I %fkey="ESC" Q:'$G(fkey)  K rec s rec="" Q
	;
RESET	;
	D TERM^%ZUSE(0,"ECHO/ESCAPE/NOIMAGE"_$G(save))
	W $$LOCK^%TRMVT
	W $$CLEAR^%TRMVT
	W $$KPNUM^%TRMVT
	Q
	;
READ	;
	S str=$P(rec,dl,py),px=$$ALEN(str,cx)
	I px>($L(str)+1) S px=$L(str)+1,cx=$$DLEN(str,px)
	;
	W $$CUP(cy,cx)
	U "":NOECHO
	;
RC	; Read character z into str
	;
	;W bot,cy," ",cx," ",py," ",px,$$CUP(cy,cx)
	;
	I str="" D
	.	;
	.	U "":ECHO
	.	R str#255:%TO E  S tmo=1
	.	U "":NOECHO 
	.	S px=$L(str)+1,z=""
	.	S cx=$$DLEN(str,px)
	;
	E  R *z:%TO E  S tmo=1
	I tmo U "":ECHO D TIMEOUT^%ZREAD() U "":NOECHO S tmo=0 Q
	;
ZB	I z>31&(z'=127)!(z=9) S ZB="" 		;Character entered
	E  S ZB=$S($L($ZB)=1:$A($ZB),$L($ZB)>1:$E($ZB,2,9),1:z),z=""
	;
	I ZB=3 b  g RC
	;
	I z'="" D  G RC  			;Insert Character
	.	;
	.	I z=9 S cx=cx+tbs\tbs*tbs+1
	.	E  S cx=cx+1
	.	;
	.	S str=$E(str,1,px-1)_$C(z)_$E(str,px,$L(str)),px=px+1
	.	I $E(str,px-1,$L(str))[$C(9) W cll,$C(z),cps,$E(str,px,$L(str)),cpr
	.	E  W:$L(str)+1>px chrins W $C(z)
	.	Q
	;
	I ZB=127 D  G RC 			;Rubout Character
	.	;
	.	I px=1 D  Q			; Drag Line up
	..		;
	..		I py=1 W $C(7) Q	; First Line
	..		S py=py-1
	..		I cy'<pt S cy=cy-1
	..		S px=$L($P(rec,dl,py))+1
	..		S str=$P(rec,dl,py)_str,cx=$$DLEN(str,px)
	..		S $P(rec,dl,py,py+1)=""
	..		W lindel,cuu,$C(13),str
	..		D DSP(pb,pb)
	..		W $$CUP(cy,cx)
	.	;
	.	S px=px-1
	.	I $A(str,px)=9 S cx=$$DLEN(str,px-1)+1
	.	E  S cx=cx-1
	.	;
	.	I $E(str,px,$L(str))[$C(9) W $$CUP(cy,cx),cll,cps,$E(str,px+1,$L(str)),cll,cpr
	.	E  S cx=cx-1 W $C(8),chrdel
	.	S str=$E(str,1,px-1)_$E(str,px+1,$L(str))
	.	Q
	;
	D ZB^%ZREAD
	;
	I key[%fkey D  Q
	.	;
	.	I %fkey="" D MSG("Unmapped key") Q
	.	S $P(rec,dl,py)=str
	.	D PROCCMD(key(%fkey))
	.	I $D(RM) D MSG(.RM)
	;
	I %fkey="END" D SAVE(name),EXIT Q
	I %fkey="ENT" D  G RC
	.	;
	.	S $P(rec,dl,py)=$E(str,1,px-1)_dl_$E(str,px,$L(str))
	.	S py=py+1,str=$P(rec,dl,py)
	.	I cy<pb S cy=cy+1
	.	S px=1,cx=1
	.	W insent,str,$C(13)
	;
	I %fkey="KYB" D KYB
	I %fkey="CUF" D CUF G RC:%fkey="CUF"
	I %fkey="CUB" D CUB G RC:%fkey="CUB"
	I %fkey="WRD" D WRD G RC:%fkey="WRD"
	I %fkey="EOL" D EOL G RC:%fkey="EOL"
	;
	S $P(rec,dl,py)=str
	;
	I %fkey="CUU" D CUU Q
	I %fkey="CUD" D CUD Q
	I %fkey="SEL" D SEL Q
	I %fkey="REM" D REM Q
	I %fkey="INS" D INS(bfrdel,.rec) Q
	I %fkey="CMD" D CMD Q
	I %fkey="PUP" D PUP Q
	I %fkey="PDN" D PDN Q
	I %fkey="FND" D FND(.fnd,1) Q
	I %fkey="MNU" D FND(.fnd,0) Q
	I %fkey="SHR" S px=px+40,cx=cx+40 Q			; for now
	I %fkey="PRN" D PRN Q
	I %fkey="DSP" D REF Q
	I %fkey="HLP" D HLP Q
	I %fkey="ESC" S RM="Exiting editor..." D EXIT S fkey=1 Q
	I %fkey="TOP" S py=1,px=1,cx=1,cy=pt D DSP()
	I %fkey="BOT" D BOT Q
	I %fkey="DUP" D DEL Q
	I %fkey="RCL" D INS(.bfrlin,.rec) Q
	Q
	;
	;----------------------------------------------------------------------
DSP(t,b)	; Print a window
	;----------------------------------------------------------------------
	;
	I $G(t)="" S t=pt
	I $G(b)="" S b=pb
	;
	N c,z
	S z=py-cy
	S c=$C(10)_cll,$P(c,c,b-t+2)="",c=csi_t_"H"_$E(c,2,$L(c))_csi_t_"H"
	;
	W c,$P($G(rec),dl,z+t,z+b)
	Q
	;
	;----------------------------------------------------------------------
REF	; Refresh the display
	;----------------------------------------------------------------------
	W lock,awof
	D DSP(),STATUS(pb,.name,.par)
	Q
	;
	;----------------------------------------------------------------------
PDN	; Page Down
	;----------------------------------------------------------------------
	;
	S z=vpan
	I py+z>$L(rec,dl) S z=$L(rec,dl)-py
	S py=py+z,cy=cy+z,(px,cx)=1
	I cy>pb S cy=pb D DSP()
	Q
	;
	;----------------------------------------------------------------------
PUP	; Page up
	;----------------------------------------------------------------------
	;
	S z=vpan
	I py-z<1 S z=py-1
	S py=py-z,cy=cy-z,(px,cx)=1
	I cy<pt S cy=pt D DSP()
	Q
	;
	;----------------------------------------------------------------------
CUU	; Insert 1 line at the top of the window
	;----------------------------------------------------------------------
	;
	I py=1 Q
	S py=py-1,str=$P(rec,dl,py)
	;I px>$L(str)+1 S px=$L(str)+1
	;I cx>px S cx=px
	I cy>pt S cy=cy-1 W cuu Q
	;
	W linins,str
	Q         
	;
	;----------------------------------------------------------------------
CUD	; Insert 1 line at the bottom of the window
	;----------------------------------------------------------------------
	;
	I py+1>$L(rec,dl) Q
	S py=py+1,str=$P(rec,dl,py)
	I cy<pb S cy=cy+1 W cud Q
	S cy=pb W dl,str
	Q
	;
	;----------------------------------------------------------------------
CUF	; Move cursor forward one position
	;----------------------------------------------------------------------
	;
	I px>$L(str) S cx=1,px=1,%fkey="CUD" W $C(13) Q
	;
	I $E(str,px)'=$C(9) W $E(str,px) S cx=cx+1,px=px+1 Q
	S cx=$$DLEN(str,px)+1,px=px+1 W $$CUP(cy,cx)
	Q
	;
	;----------------------------------------------------------------------
CUB	; Insert 1 line at the bottom of the window
	;----------------------------------------------------------------------
	;
	I px=1 S:py>1 (px,cx)=9999,%fkey="CUU" Q
	S px=px-1 I $E(str,px)'=$C(9) S cx=cx-1 W cub Q
	;
	S cx=$$DLEN(str,px-1)+1 W $$CUP(cy,cx)
	Q
	;
	;----------------------------------------------------------------------
EOL	; Move Cursor to EOL
	;----------------------------------------------------------------------
	;
	I px>$L(str),$P(rec,dl,py+1,py+2)'="" S (px,cx)=9999,%fkey="CUD" Q
	S px=$L(str)+1,cx=$$DLEN(str,px)
	W $$CUP(cy,cx)
	Q
	;
	;----------------------------------------------------------------------
WRD	; Skip over white space
	;----------------------------------------------------------------------
	;
	S z=$F(str,$C(9),px)
	S px=$F(str," ",px)
	;
	I z,z<px!'px S px=z					; Found TAB
	;
	I 'px S %fkey="CUD",(px,cx)=1 Q
	I $C(9,32)[$E(str,px) F px=px+1:1 Q:$C(9,32)'[$E(str,px)
	S cx=$$DLEN(str,px)
	W $$CUP(cy,cx)
	Q
	;
	;----------------------------------------------------------------------
BOT	; Bottom of buffer  
	;----------------------------------------------------------------------
	;
	S z=$L(rec,dl)-py
	S py=py+z,cy=cy+z,(px,cx)=1
	I cy>pb S cy=pb D DSP()
	Q
	;
	;----------------------------------------------------------------------
FND(fnd,prompt)	; Find a string in the array
	;----------------------------------------------------------------------
	;
	I prompt!(fnd="") S fnd=$$PROMPT("Find: ",.fnd) I fnd="" Q
	;
	S y=$L($P(rec,dl,1,py-1))+px+1 I py>1 S y=y+2
	S y=$F($$UPPER^SCAUTL(rec),$$UPPER^SCAUTL(fnd),y)
	I y=0 W $$MSG^%TRMVT($$^MSG(2042),0,1) Q
	;
	S z=$L($E(rec,1,y-1),dl)-py
	S py=py+z,cy=cy+z I cy+1>pb S cy=pb-1 D DSP()
	S px=y-$L($P(rec,dl,1,py-1))-$L(fnd) I py>1 S px=px-$L(dl)
	S cx=$$DLEN($P(rec,dl,py),px)
	Q
	;
	;----------------------------------------------------------------------
REPLACE	; Replace occurrances of a string
	;----------------------------------------------------------------------
	;
	N I,X,new,c,y,z
	;
	S fnd=$$PROMPT("Old String: ",.fnd) I fnd="" Q
	S new=$$PROMPT("New String: ")
	;
	S y=$L($P(rec,dl,1,py-1))+px+1 I py>1 S y=y+2
	S X=""
	;	
	S c=0,undo=rec
	;
	F  S y=$F(rec,fnd,y) Q:'y  D
	.	;
	.	I X'="A" D  
	..		;
	..		S z=$L($E(rec,1,y-1),dl)-py
	..		S py=py+z,cy=cy+z I cy+1>pb S cy=pb-1 D DSP()
	..		S px=y-$L($P(rec,dl,1,py-1))-$L(fnd) I py>1 S px=px-$L(dl)
	..		S cx=$$DLEN($P(rec,dl,py),px)
	..		W $$CUP(cy,cx),vrev,fnd,voff
	..		S X=$$UPPER^SCAUTL($E($$PROMPT("Yes, No, All, Last or Quit: ")))
	..		I X="" S X="Y"
	.	;
	.	I "LAY"[X S c=c+1,rec=$E(rec,1,y-$L(fnd)-1)_new_$E(rec,y,$L(rec))
	.	I "LYN"[X W $$CUP(cy,1),cll,$P(rec,dl,$L($E(rec,1,y-1),dl))
	.	I "QL"[X S y=$L(rec)+1 Q
	.	S y=y+$L(new)-$L(fnd)
	;
	I X="A" D DSP(cy,pb)
	;
	S RM="Replaced "_c_" Occurrances"
	Q
	;
	;----------------------------------------------------------------------
UNDO	; Undo a massive change
	;----------------------------------------------------------------------
	;
	I $G(undo)="" D MSG("Undo Buffer is Empty") Q
	S z=rec,rec=undo,undo=z
	D DSP()
	Q
	;
	;----------------------------------------------------------------------
PRN	; Print documentation to a device
	;----------------------------------------------------------------------
	;
	N IO
	D ^DBSIO I $G(IO)="" Q				; Select Device
	U IO F I=1:1:$L(rec,dl) W $P(rec,dl,I),! I $Y>IOSL W #,!
	D CLOSE^SCAIO
	W $$MSG^%TRMVT($$^MSG(855),"",1)
	Q
	;
	;----------------------------------------------------------------------
DEL	; Delete to end of Line
	;----------------------------------------------------------------------
	;
	S bfrlin=$E(str,px,$L(str))_dl,str=$E(str,1,px-1)
	;
	I py=1 S rec=str_$P(rec,dl,py+1,$L(rec))
	E  S rec=$P(rec,dl,1,py-1)_dl_str_$P(rec,dl,py+1,$L(rec))
	;
	S str=$P(rec,dl,py)
	;W cll,$E(str,cx,$L(str))
	W lindel,cll,str
	D DSP(pb,pb)
	Q
	;
	;----------------------------------------------------------------------
REM	; Remove Marked Text
	;----------------------------------------------------------------------
	;
	I 'ay D MSG("No Selection Active") Q
	;
	N bx,by,ex,ey
	;
	I ay=py D  Q
	.	;
	.	I ax>px S px=px+1,ex=ax+1,bx=px
	.	E  S bx=ax,ex=px,px=bx,cx=cx+ex-bx
	.	;
	.	S str=$P(rec,dl,py),ay=0
	.	S bfrdel=$E(str,bx,ex-1)
	.	S str=$E(str,1,bx-1)_$E(str,ex,$L(str))
	.	S $P(rec,dl,py)=str
	.	W $C(13),str,cll
	;
	I ay'>py S by=ay,ey=py,bx=ax,ex=px,cx=cx+bx-ex,cy=cy+by-ey
	E  S by=py,ey=ay,bx=px,ex=ax
	;
	S px=px+bx-ex
	S py=py+by-ey
	;
	S str=$P(rec,dl,by),ay=0
	;
	S bfrdel=$E($P(rec,dl,by,ey-1),bx,$L(rec))_dl_$E($P(rec,dl,ey),1,ex-1)
	;
	I by=1 S rec=$E($P(rec,dl,by),1,bx-1)_$E($P(rec,dl,ey,$L(rec)),ex,$L(rec))
	E  S rec=$P(rec,dl,1,by-1)_dl_$E($P(rec,dl,by),1,bx-1)_$E($P(rec,dl,ey,$L(rec)),ex,$L(rec))
	;
	I cy<pt S cy=pt
	;
	D DSP()
	D MSG("Remove Completed")
	Q
	;
	;----------------------------------------------------------------------
INS(bfr,rec,ff)	; Insert a buffer at the current position
	;----------------------------------------------------------------------
	;
	I $G(bfr)="" D MSG("Buffer is Empty") Q
	;
	N str
	S str=$P(rec,dl,py),undo=rec
	;
	I py=1 S rec=$E(str,1,px-1)_bfr_$E($P(rec,dl,py,$L(rec)),px,$L(rec))
	E  S rec=$P(rec,dl,1,py-1)_dl_$E(str,1,px-1)_bfr_$E($P(rec,dl,py,$L(rec)),px,$L(rec))
	;
	I $G(ff) Q
	;
	S z=$L(bfr,dl)-1
	I cy+z>pb S z=pb-cy
	;
	I z W dl F i=1:1:z w linins
	D DSP(cy,cy+z)
	Q
	;----------------------------------------------------------------------
SEL	; Selection Toggle
	;----------------------------------------------------------------------
	;
	I 'ay S ay=py,ax=px D MSG("Move the cursor to selected desired text") Q
	D MSG("selection Cancelled") S ay=0,ax=0 Q
	Q
	;
CUP(Y,X)	Q csi_Y_";"_X_"H"
	;
	;----------------------------------------------------------------------
KYB	; Display keyboard menu and choose option
	;----------------------------------------------------------------------
	;
	S ZB=$$EMULATE^DBSMBAR I ZB="" S ZB=13,%fkey="ENT" Q
	S %fkey=%fkey(ZB) 
	Q
	;
	;----------------------------------------------------------------------
EXIT	; Exit function - Erase table display - redisplay original form
	;----------------------------------------------------------------------
	;
	S %fkey="ESC"
	Q
	;
	;----------------------------------------------------------------------
STATUS(line,buffer,par)	; Display a status
	;----------------------------------------------------------------------
	;
	N i,list,nam,typ,v,z
	;
	S list=$G(par("STATUS")) I list="",$G(buffer)="" Q
	;
	S z=""
	F i=1:1:$L(list,",") D
	.	;
	.	S nam=$P(list,",",i)
	.	S v=$P($P($G(par),","_nam,2),",",1)
	.	;
	.	S typ=$E(v,$F(v,"/TYP="))
	.	;
	.	S v=$G(par(nam))
	.	I typ="L" S v=$S(v:"",1:"NO")_nam
	.	E  S v=nam_"="_v
	.	S $P(z," | ",i)=v
	; 
	S z=$E($G(buffer)_$J("",srm-$L($G(buffer))-$L(z))_z,1,srm)
	;
	W $$CUP(line+1,1),vrev,z,voff
	W $c(13,10),cll
	Q
	;
	;----------------------------------------------------------------------
CMD	; Command prefix used 
	;----------------------------------------------------------------------
	;
	S ER=0
	;
	N cmdnum,cmdptr,RM,X
	S cmdnum=$O(bfrcmd(""),-1)+1,cmdptr=cmdnum
	;
CREAD	;
	S X=$G(bfrcmd(cmdptr))
	W $$CUP(pb+2,1),"Command: ",cll
	I $G(X)'="" W X,$$CUB^%TRMVT($L(X))
	;
	S X=$$TERM^%ZREAD($G(X))
	;
	I %fkey="ESC" S %fkey="" Q
	I %fkey="CUU" S cmdptr=+$O(bfrcmd(cmdptr),-1) G CREAD
	I %fkey="CUD" S cmdptr=$O(bfrcmd(cmdptr)) S:cmdptr="" cmdptr=cmdnum+1 G CREAD
	I X="" Q
	;
	S cmdptr=cmdnum
	I X'=$G(bfrcmd(cmdnum-1)) S bfrcmd(cmdnum)=X
	;
	D PROCCMD(X),MSG(.RM)
	I ER G CREAD
	W $$CUP(pb+2,1),cll
	Q
	;
	;----------------------------------------------------------------------
PROCCMD(X)	; Process command
	;----------------------------------------------------------------------
	;
	N expr
	;
	S ER=0
	S cmd=$$UPPER^SCAUTL($P(X," ",1))
	I cmd="" S ER=1,RM="Command is NULL" Q
	;
	I $D(cmd(cmd)) S expr=cmd(cmd)
	;
	E  D  I ER Q
	.	;
	.	N zcmd,cmmds,I
	.	S zcmd=cmd_$C(255)
	.	F I=1:1 S cmd=$O(cmd(cmd)) Q:cmd=""!(cmd]]zcmd)  S $P(cmmds,",",I)=cmd
	.	I '$D(cmmds) S ER=1,RM="Invalid Command" Q
	.	I $L(cmmds,",")>1 S RM=$$^MSG(8595) S ER=1 Q
	.	S cmd=cmmds,expr=cmd(cmd)
	;
	S X=$$TRIM^%ZS(X)
	;S X=$$QSUB^%ZS($P(X," ",2,999))
	S X=$P(X," ",2,999)
	;
	I expr["(1" D  Q:ER
	.	;
	.	S z=$S(expr["(1/REQ":"(1/REQ",1:"(1")
	.	;
	.	S X=$$QADD^%ZS(X)
	.	S expr=$P(expr,z,1)_"("_X_$P(expr,z,2,999)
	X expr
	Q
	;
	;----------------------------------------------------------------------
COUNT(X)	; Count Buffer Statistics
	;----------------------------------------------------------------------
	;
	S RM="Buffer Contains "
	I X'="" S RM=RM_($L(rec,X)-1)_" '"_X_"' Strings" Q
	;
	S RM=RM_($L(rec,$C(13)))_" Lines, "_$L(rec)_" Characters"
	Q
	;
	;----------------------------------------------------------------------
HLP	; Help
	;----------------------------------------------------------------------
	;
	I $D(help)>1 d  		; Let the user choose
	.	S help=$$^DBSMBAR(29,"","","",.help)
	.	I $D(SQLIHLP(help)) s help=SQLIHLP(help) q
	.	S help=$g(help(help))
	I help="" Q
	;
	D ^DBSHLP(help),REF
	S %fkey=""
	Q
	;
	;----------------------------------------------------------------------
INCLUDE(X)	; Load an RMS file into the current buffer
	;----------------------------------------------------------------------
	;
	I $G(X)="" D MSG("Filename Required") Q
	I $$UPPER^SCAUTL(X)?1E.E1".M" S par("SOURCE")="M" D REF	; ***
	;
	N bfr,ff
	S ff=$G(rec)="" I ff S ff=pb-pt
	;
	S bfr=$$LOADFILE(X,ff) Q:ER
	D INS(bfr,.rec,ff)
	S curfil=X
	Q
	;
	;----------------------------------------------------------------------
LOADFILE(X,ff)	; Return an RMS file as a string
	;----------------------------------------------------------------------
	;
	I X="" S ER=1,RM=$$^MSG(8601) Q
	; *** check missing extension first
	I $G(par("EXTENSION"))'="",$P(X,".",2)="" S X=X_"."_par("EXTENSION")
	I $G(par("DIRECTORY"))'="" S X=$$FILE^%TRNLNM(X,par("DIRECTORY"))
	;
	S ER=0
	;
	N l,ok,z,x
	S ok=$$FILE^%ZOPEN(.X,"READ")
	I 'ok S ER=1,RM=$P(ok,"|",2) Q ""
	;
	U X
	;
	R z S l=$L(z) 
	;
	I $G(ff) D
	.	;
	.	N rec
	.	F ff=ff:-1:1 Q:$ZEOF  R x S l=l+$L(x)+2,z=z_dl_x
	.	S rec=z 
	.	U 0 D DSP() U X
	;
	F  Q:$ZEOF  R x S l=l+$L(x)+2 I l<32600 S z=z_dl_x
	;
	C X
	;
	I l>$L(z) S ER=1,RM="Input file size is greater than 32K"
	Q z
	;
	;----------------------------------------------------------------------
EDT(X)	; Edit an RMS file with a VMS Editor
	;----------------------------------------------------------------------
	;
	I X="" S ER=1,RM=$$^MSG(8601) Q
	;
	I $G(par("DIRECTORY"))'="" S X=$$FILE^%TRNLNM(X,par("DIRECTORY"))
	I $G(par("EXTENSION"))'="",$P(X,".",2)="" S X=X_"."_par("EXTENSION")
	;
	S ER=$$EDTOPT^%OSSCRPT("EDT",X,"")	; *** 07/14/98
	D OPEN,REF
	Q 
	;
	;----------------------------------------------------------------------
CLEAR	; Clear the current buffer
	;----------------------------------------------------------------------
	;
	S rec="",cy=1,py=1,px=1
	D DSP()
	Q 
	;
	;----------------------------------------------------------------------
SAVE(X)	; Save a buffer to an RMS file
	;----------------------------------------------------------------------
	;
	I X="" S X=$G(curfil) I X="" S ER=1,RM=$$^MSG(8601) Q
	;
	I $G(par("EXTENSION"))'="",$P(X,".",2)="" S X=X_"."_par("EXTENSION")
	I $G(par("DIRECTORY"))'="" S X=$$FILE^%TRNLNM(X,par("DIRECTORY"))
	;
	S ER=0
	;
	N i,ok
	;
	; Buffer is empty
	I rec="" S RM=$$^MSG(8598) Q
	;
	S ok=$$FILE^%ZOPEN(.X,"WRITE/NEWV")
	I 'ok S ER=1,RM=$P(ok,"|",2) Q
	;
	U X 
	W $P(rec,dl,1)
	F i=2:1:$L(rec,dl) W !,$P(rec,dl,i)
	C X
	;
	; Buffer saved to ~p1
	S RM=$$^MSG(8599,X)
	Q
	;
	;----------------------------------------------------------------------
SET(X)	; Define Variables
	;----------------------------------------------------------------------
	;
	I $G(par)="" D MSG("SET Variables are not defined") Q
	I $G(X)="" D MSG(par) Q
	;
	N opt,params
	S params=""
	S opt=$P(X," ",1) S X=$$QSUB^%ZS($P(X," ",2,999))
	;
	I $E(opt)=":" D  Q				; *** 06/14/96
	.	N var					; SET :var val
	.	S var=$E(opt,2,$L(opt))			; Remove :
	.	I '((var?1A.AN)!(var?1"%".AN)) S RM=$$^MSG(8602,opt) Q  ; Invalid syntax
	.	S @var=X				; Define variable
	;
	S opt=$$UPPER^SCAUTL(opt)
	I $E(opt,1,2)="NO",X="" S X=0,opt=$E(opt,3,$L(opt))
	;
	I ","_par[(","_opt) D  D STATUS(pb,.name,.par) Q
	.	;
	.	S opt=opt_$P($E(","_par_",",$F(","_par,","_opt),9999),",",1)
	.	I opt["/" S params=$P(opt,"/",2,999),opt=$P(opt,"/",1)
	.	;
	.	I X="" S:params["TYP=L" X=1
	.	E  I opt'="OUTPUT" S X=$$UPPER^SCAUTL(X)
	.	;
	.	S par(opt)=X
	.	;
	.	I opt'="STATUS",'$$CONTAIN($G(par("STATUS")),opt) D MSG(opt_"="_X) Q
	;
	; Invalid Parameter ~p1
	S RM=$$^MSG(8602,opt)
	Q
	;
	;----------------------------------------------------------------------
DCL(X)	; Shell to DCL
	;----------------------------------------------------------------------
	;
	D RESET H 1
	S X=$$SYS^%ZFUNC(X)
	W $$MSG^%TRMVT("Return from DCL",0,1)
	D OPEN,REF
	Q
	;
	;----------------------------------------------------------------------
SPAWN	; Shell to DCL
	;----------------------------------------------------------------------
	;
	D RESET H 1
	D DCL^%VMS
	W $$MSG^%TRMVT("Return from Spawned Process",0,1)
	D OPEN,REF
	Q
	;
	;----------------------------------------------------------------------
PROMPT(P,X)	; Prompt for inpit
	;----------------------------------------------------------------------
	;
	W $$CUP(pb+2,1),P,cll
	I $G(X)'="" W X,$$CUB^%TRMVT($L(X))
	Q $$TERM^%ZREAD($G(X))
	;
	;----------------------------------------------------------------------
SCRIPT(file)	; Run the initialization script
	;----------------------------------------------------------------------
	;
	N ER,RM
	S ER=0
	;
	N ok
	S ok=$$FILE^%ZOPEN(file,"READ")
	I 'ok Q
	;
	W $$MSG^%TRMVT("Execute Script") H 1
	S %fkey="ENT"
	;
	F  U file Q:$ZEOF  R X S X=$TR(X,$C(9)," ") I X'="" U 0 D PROCCMD(X) I ER D MSG(.RM) S ER=0
	C file
	;D STATUS(pb,.name,.par)
	Q
	;
	;----------------------------------------------------------------------
ALEN(str,cx)	; internal length of string at external position
	;----------------------------------------------------------------------
	;
	N y
	S y=$F($E(str,1,cx-1),$C(9))
	I 'y Q cx
	;
	; Needs to be optimized ****
	F px=y:1:$L(str)+2 I $$DLEN(str,px-1)+1=cx Q
	Q px
	;
	;----------------------------------------------------------------------
DLEN(str,px)	; External length of string at internal position
	;----------------------------------------------------------------------
	;
	N y
	S y=$F($E(str,1,px),$C(9))
	I 'y Q px
	;
	N cx,zy
	S cx=y-1+tbs\tbs*tbs,zy=y
	;
	F  S y=$F($E(str,1,px),$C(9),y) Q:'y  S cx=cx+y-zy+tbs\tbs*tbs,zy=y
	Q cx+px-zy+1
	;
MSG(M)	W bot,$G(M) K M Q
	;
OPEN	;
	D TERM^%ZUSE(0,"ECHO/IMAGE/ESCAPE/TERMINATOR=$C(3,11,13,16,21,23,127)/TTSYNC/WIDTH=81")
	W $$INSMOFF^%TRMVT			; Turn off insert mode
	W $$KPAPP^%TRMVT			; Application Keypad
	Q
SAVATT()	; Save Terminal Attributes
	;
	N i,z
	ZSH "D":z
	;
	F i=1:1 Q:'$D(z("D",i))  I z("D",i)["TERM=" S z="/TERMINATOR="_$P($P(z("D",i),"TERM=",2),")",1)_")" Q
	Q $G(z)
	;
CONTAIN(A,B)	Q ","_A_","[(","_B_",")
	;
KEY	;
	;
	N PGM,SID,%O,%NORPMT,GOLD
	S %O=2,%NOPRMT="",GOLD=0
	S SID="FORMHLP"
	D ^USID I PGM="" Q
	D ^@PGM
	Q
