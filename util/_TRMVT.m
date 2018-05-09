%TRMVT	;Library;VTnnn Screen Control Functions
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/15/97 11:53:18 - CHIANG
	; ORIG:  RUSSELL - 24 OCT 1989
	;
	; Various extrinsic functions for VTnnn control
	;
	; Cursor positioning is based on top of screen = 1,1, not 
	; MUMPS $X,$Y which is 0,0
	;
	; Most of the functions which move the cursor do not adjust the value of
	; $X or $Y to match their new locations.  If the application requires
	; the updating of $X and $Y, the following functions with names ending
	; in XY are provided for a handful of the basic functions.  These 
	; functions work the same as their counterparts above, with the 
	; exception that they DO NOT return a re-usable value from the 
	; extrinsic call, so should be used as: W $$func^%TRMVT.
	;
	; KEYWORDS:	Screen handling, Device handling
	; LIBRARY:
	;
	;	---- Cursor Movement Functions ---------------------------------
	;
	;	. $$CUP(X,Y)				Cursor to X,Y
	;	. $$CUPXY(X,Y)				 & update $X, $Y
	;	. $$CUB(NUM)				Cursor back NUM columns
	;	. $$CUD(NUM)				Cursor down NUM rows
	;	. $$CUF(NUM)				Cursor forward NUM cols
	;	. $$CUU(NUM)				Cursor up NUM rows
	;	. $$BTM					Bottom left, clear line
	;	. $$BTMXY				 & update $X, $Y
	;
	;	Cursor Control Functions ---------------------------------------
	;
	;	. $$CPR					Restore cursor position
	;	. $$CPS					Save cursor position
	;	. $$CUON				Cursor on
	;	. $$CUOFF				Cursor off
	;	. CPOS(X,Y)				Return current position
	;
	;	---- Display Attributes ----------------------------------------
	;
	;	. $$VIDOFF				Video attributes off
	;	. $$VIDBLK				Blinking on
	;	. $$VIDINC				Increased intensity on
	;	. $$VIDREV				Reverse video on
	;	. $$VIDUDL				Underline on
	;	. $$VIDERR				Error message
	;	. $$VIDMSG				Messages
	;	. $$VIDOOE				OOE/DQ scr video format
	; 
	;	---- Insert and Delete Functions -------------------------------
	;
	;	. $$CHRINS(NUM)				Insert NUM characters
	;	. $$CHRDEL(NUM)				Delete NUM characters
	;	. $$LININS(NUM)				Insert NUM lines
	;	. $$LINDEL(NUM)				Delete NUM lines
	;	. $$INSMON				Set terminal to insert
	;	. $$INSMOFF				Turn insert mode off
	;
	;	---- Screen Clear Functions ------------------------------------
	;
	;	. $$CLEAR				Clear screen and home
	;	. $$CLEARXY				 & update $X, $Y
	;	. $$CLR(TOP,BTM)			Clear region/move to top
	;	. $$CLRXY(TOP,BTM)			 & update $X, $Y
	;	. $$CLL					Clear to end of line
	;	. $$CLN(NUM)				Clear next NUM chars
	;	. $$CLP					Clear to end of page
	; 	. $$CLW(PL,PT,PR,PB)			Clear window
	;
	;	---- Screen Control Functions ----------------------------------
	;
	;	. $$SCRAWON				Auto wrap on
	;	. $$SCRAWOFF				Auto wrap off
	;	. $$SCR80				Set screen 80 columns
	;	. $$SCR80XY				 & update $X, $Y
	;	. $$SCR132				Set screen 132 columns
	;	. $$SCR132XY				 & update $X, $Y
	;
	;	---- Region Lock Functions -------------------------------------
	;
	;	. $$LOCK(TOP,BTM)			Lock region
	;
	;	---- Display and Graphics Functions ----------------------------
	;
	;	. $$DBLH(TEXT)				Double high text
	;	. $$DBLW(TEXT)				Double wide text
	;	. $$GREN				Enable graphics
	;	. $$GRON				Graphics on
	;	. $$GROFF				Graphics off
	;	. $$CROSS(X,Y)				Draw a graphic cross 
	;	. $$LINE(LENGTH,X,Y)			Draw graphics line
	;	. $$UPLINE(X,Y)				Draw a graphic upbar
	;	. BOX(ORIGIN,EXTANT)			Draw box
	;	. $$MSG(MSG,OPT,PWZ,CUX,CUY,TIM,TOF)	Display error message
	;	. $$SHOWKEY(ar,pf,beg,end)		Display key usage line
	;
	;	---- Slave Printer Functions -----------------------------------
	;
	;	. $$PRNTRDY				Return printer ready
	;	. $$PRNTON				Turn on slave printer
	;	. $$PRNTOFF				Turn off slave printer
	;       . $$PRNTFF				Form feed
	;
	;	---- Terminal Definition Functions -----------------------------
	;
	;	. $$CSI					$C(27,91) or $C(155)
	;	. ZBINIT				Init function key array
	;
	;
	;-----Revision History-------------------------------------------------
	; 04/18/06 - Allan Mattson - CR35492
	;            Modified function $$CSI to return $C(27,91) instead of
	;            $C(155) and replaced all occurences of $C(155) with $$CSI
	;            in order to resolve problems with terminal emulation in a
	;            Unicode environment.
	;
	;            Replaced naked global reference with full global reference
	;            to conform to programming standards.
	;
	; 04/09/97 - Chiang - 24416
	;            Added new section PRNTFF to control the form feed of slave
	;            printer.
	;
	; 07/09/96 - Phil Chenard 	
	;            Modified BOX section to replace the use of $C(10) with
	;            a cursor down control character.  This change is to 
	;            resolve a problem where some platforms interpret the use
	;            of the carriage return differently, for instance adding a
	;            line feed as well.
	;
	;-----------------------------------------------------------------------
	;***********************************************************************
	;********** Cursor Movement Functions **********************************
	;***********************************************************************
	;
	;----------------------------------------------------------------------
CUP(X,Y)	;System;Move to X,Y
	;----------------------------------------------------------------------
	;
	; Move cursor to location specified by X,Y.  Default is top left corner
	;
	; KEYWORDS:	Screen handling
	;
	; ARGUMENTS:
	;	. X		X coordinate		/TYP=N/DEF=1
	;
	;	. Y		Y coordinate		/TYP=N/DEF=1
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S MOVE=$$CUP^%TRMVT(5,10)
	;
	Q $$CSI_$G(Y)_";"_$G(X)_"H"
	;
	;----------------------------------------------------------------------
CUB(NUM)	;System;Move back NUM spaces
	;----------------------------------------------------------------------
	;
	; Move cursor back NUM spaces.  Default = 1
	;
	; KEYWORDS:	Screen handling
	;
	; ARGUMENTS:
	;	. NUM		Number of spaces	/TYP=N/DEF=1
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S BACK=$$CUB^%TRMVT(5)
	;
	Q $$CSI_$G(NUM)_"D"
	;
	;----------------------------------------------------------------------
CUD(NUM)	;System;Move down NUM spaces
	;----------------------------------------------------------------------
	;
	; Move cursor down NUM spaces.  Default = 1
	;
	; KEYWORDS:	Screen handling
	;
	; ARGUMENTS:
	;	. NUM		Number of spaces	/TYP=N/DEF=1
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S DOWN=$$CUD^%TRMVT(5)
	;
	Q $$CSI_$G(NUM)_"B"
	;
	;----------------------------------------------------------------------
CUF(NUM)	;System;Move forward NUM spaces
	;----------------------------------------------------------------------
	;
	; Move cursor forward NUM spaces.  Default = 1
	;
	; KEYWORDS:	Screen handling
	;
	; ARGUMENTS:
	;	. NUM		Number of spaces	/TYP=N/DEF=1
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S FORWARD=$$CUF^%TRMVT(5)
	;
	Q $$CSI_$G(NUM)_"C"
	;
	;----------------------------------------------------------------------
CUU(NUM)	;System;Move up NUM spaces
	;----------------------------------------------------------------------
	;
	; Move cursor up NUM spaces.  Default = 1
	;
	; KEYWORDS:	Screen handling
	;
	; ARGUMENTS:
	;	. NUM		Number of spaces	/TYP=N/DEF=1
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S UP=$$CUU^%TRMVT(5)
	;
	Q $$CSI_$G(NUM)_"A"
	;
	;----------------------------------------------------------------------
BTM()	;System;Move to bottom left of screen, clear line
	;----------------------------------------------------------------------
	;
	; Move to bottom left of screen and clear the bottom line
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S BOTTOM=$$BTM^%TRMVT
	;
	Q $$CUP(1,24)_$$CLL
	;
	;----------------------------------------------------------------------
CUPXY(X,Y)	;System;Move to X,Y, save new $X and $Y
	;----------------------------------------------------------------------
	;
	; Move cursor to location specified by X,Y.  Default is top left corner.
	; Save new location in $X and $Y
	;
	; KEYWORDS:	Screen handling
	;
	; ARGUMENTS:
	;	. X		X coordinate		/TYP=N/DEF=1
	;
	;	. Y		Y coordinate		/TYP=N/DEF=1
	;
	; RETURNS:
	;	. $$		Null			/TYP=T
	;
	; EXAMPLE:
	;	W $$CUPXY^%TRMVT(5,10)
	;
	S X=$G(X),Y=$G(Y)
	I 'X S X=1
	I 'Y S Y=1
	W $$CUP(X,Y)
	S $X=X-1,$Y=Y-1
	Q ""
	;
	;----------------------------------------------------------------------
BTMXY()	;System;Move to bottom left of screen, clear line, save $X and $Y
	;----------------------------------------------------------------------
	;
	; Move to bottom left of screen and clearn the bottom line.  Save new
	; position of $X and $Y
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Null			/TYP=T
	;
	; EXAMPLE:
	;	w $$BTMXY^%TRMVT
	;
	W $$BTM
	S $X=0,$Y=23
	Q ""
	;
	;***********************************************************************
	;********** Cursor Control Functions ***********************************
	;***********************************************************************
	;
	;----------------------------------------------------------------------
CUON()	;System;Turn cursor on (display cursor)
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S ON=$$CUON^%TRMVT
	;
	Q $$CSI_"?25h"
	;
	;----------------------------------------------------------------------
CUOFF()	;System;Turn cursor off (hide cursor)
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S OFF=$$CUOFF^%TRMVT
	;
	Q $$CSI_"?25l"
	;
	;----------------------------------------------------------------------
CPS()	;System;Save cursor position
	;----------------------------------------------------------------------
	;
	; Instructs terminal to save cursors position.  May be restored with
	; $$CPR^%TRMVT
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S SAVE=$$CPS^%TRMVT
	;
	Q $C(27)_7
	;
	;----------------------------------------------------------------------
CPR()	;System;Restore cursor position
	;----------------------------------------------------------------------
	;
	; Restores cursor position to that saved by CPS^%TRMVT
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S RESTORE=$$CPR^%TRMVT
	;
	Q $C(27)_8
	;
	;----------------------------------------------------------------------
CPOS(X,Y)	;System;Returns current cursor position
	;----------------------------------------------------------------------
	;
	; Returns current cursor position in arguments passed by reference
	;
	; KEYWORDS:	Screen handling
	;
	; ARGUMENTS:
	;	. X		X coordinate		/TYP=N/MECH=REFNAM:W
	;
	;	. Y		Y coordinate		/TYP=N/MECH=REFNAM:W
	;
	; EXAMPLE:
	;	D CPOS^%TRMVT(.XPOS,.YPOS)
	;
	N Z,ZB
	W $$CSI_"6n"
	R Z:1 S ZB=$ZB
	S ZB=$E(ZB,3,9)
	S Y=+ZB,X=+$P(ZB,";",2)
	Q
	;
	;***********************************************************************
	;********** Display Attributes *****************************************
	;***********************************************************************
	;
	;----------------------------------------------------------------------
VIDOFF()	;System;Turn video attributes off
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$VIDOFF^%TRMVT
	;
	Q $$CSI_"m"
	;
	;----------------------------------------------------------------------
VIDINC()	;System;Turn increased intensity on
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$VIDINC^%TRMVT
	;
	Q $$CSI_";1m"
	;
	;----------------------------------------------------------------------
VIDREV()	;System;Turn reverse video on
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$VIDREV^%TRMVT
	;
	Q $$CSI_";7m"
	;
	;----------------------------------------------------------------------
VIDUDL()	;System;Turn underline on
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$VIDUDL^%TRMVT
	;
	Q $$CSI_";4m"
	;
	;----------------------------------------------------------------------
VIDBLK()	;System;Turn blinking on
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$VIDBLK^%TRMVT
	;
	Q $$CSI_";5m"
	;
	;----------------------------------------------------------------------
VIDERR()	;System;Turn error display (reverse video) on
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$VIDERR^%TRMVT
	;
	Q $$CSI_";7m"
	;
	;----------------------------------------------------------------------
VIDMSG()	;System;Turn message display (increased intensity) on
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$VIDMSG^%TRMVT
	;
	Q $$CSI_";1m"
	;
	;----------------------------------------------------------------------
VIDOOE(V1)	;System;Return composite code for multiple video attributes
	;----------------------------------------------------------------------
	;
	; Return composite code that includes reverse, highlighted, underscore,
	; and blinking, if requested.  Used by OOE for object display attribute
	; handling.
	;
	; KEYWORDS:	Screen handling
	;
	; ARGUMENTS:
	;	. V1		Attribute request	/TYP=N
	;			Binary format, with lowest order
	;			four bits representing attributes
	;			shown, if on
	;
	;			 Bit 0 = reverse
	;			 Bit 1 = highlight
	;			 Bit 2 = underscore
	;			 Bit 3 = blinking
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$VIDOOE^%TRMVT(3)
	;
	N V
	;
	S V=""
	I V1#2 S V=V_";7" ; Reverse
	I V1\2#2 S V=V_";1" ; Highlight
	I V1\4#2 S V=V_";4" ; Underscore
	I V1\8#2 S V=V_";5" ; Blinking
	Q $$CSI_V_"m"
	;
	;***********************************************************************
	;********** Insert and Delete Functions ********************************
	;***********************************************************************
	;
	;----------------------------------------------------------------------
CHRINS(NUM)	;System;Insert NUM characters
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; ARGUMENTS:
	;	. NUM		Number of characters	/TYP=N/DEF=1
	;			to insert
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$CHRINS^%TRMVT(5)
	;
	Q $$CSI_$G(NUM)_"@"
	;
	;----------------------------------------------------------------------
CHRDEL(NUM)	;System;Delete NUM characters
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; ARGUMENTS:
	;	. NUM		Number of characters	/TYP=N/DEF=1
	;			to delete
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$CHRDEL^%TRMVT(5)
	;
	Q $$CSI_$G(NUM)_"P"
	;
	;----------------------------------------------------------------------
LININS(NUM)	;System;Insert NUM lines
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; ARGUMENTS:
	;	. NUM		Number of lines		/TYP=N/DEF=1
	;			to insert
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$LININS^%TRMVT(5)
	;
	Q $$CSI_$G(NUM)_"L"
	;
	;----------------------------------------------------------------------
LINDEL(NUM)	;System;Delete NUM lines
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; ARGUMENTS:
	;	. NUM		Number of lines 	/TYP=N/DEF=1
	;			to delete
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$LINDEL^%TRMVT(5)
	;
	Q $$CSI_$G(NUM)_"M"
	;
	;----------------------------------------------------------------------
INSMON()	;System;Turn insert mode on
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$INSMON^%TRMVT
	;
	Q $$CSI_"4h"
	;
	;----------------------------------------------------------------------
INSMOFF()	;System;Turn insert mode off
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$INSMOFF^%TRMVT
	;
	Q $$CSI_"4l"
	;
	;***********************************************************************
	;********** Screen Clear Functions *************************************
	;***********************************************************************
	;
	;----------------------------------------------------------------------
CLEAR()	;System;Clear screen and return to home (top left corner)
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$CLEAR^%TRMVT
	;
	Q $$VIDOFF_$$CSI_"2J"_$$CUP(1,1)
	;
	;----------------------------------------------------------------------
CLL()	;System;Clear to end of line, return to starting point
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$CLL^%TRMVT
	;
	Q $$CSI_"K"
	;
	;----------------------------------------------------------------------
CLP()	;System;Clear to end of page, return to starting point
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$CLP^%TRMVT
	;
	Q $$CSI_"J"
	;
	;----------------------------------------------------------------------
CLN(NUM)	;System;Clear NUM characters, return to starting point
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; ARGUMENTS:
	;	. NUM		Number characters	/TYP=N/DEF=1
	;			to clear
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$CLN^%TRMVT(5)
	;
	Q $$CSI_$G(NUM)_"X"
	;
	;----------------------------------------------------------------------
CLR(TOP,BTM)	;System;Clear region, return to top left
	;----------------------------------------------------------------------
	;
	; Clear region specified, return to top left of region.  Default is to
	; clear entire screen.
	;
	; If BTM<TOP or BTM beyond end of screen, clear entire page.
	;
	; KEYWORDS:	Screen handling
	;
	; ARGUMENTS:
	;	. TOP		Top line position	/TYP=N/DEF=1
	;
	;	. BTM		Bottom line  position	/TYP=N/DEF=24
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$CLR^%TRMVT(5,10)
	;
	I '$G(TOP) Q $$CLEAR
	I '$G(BTM) S BTM=24
	;
	I BTM<TOP!(BTM>23) Q $$CUP(1,TOP)_$$CLP_$$CUP(1,TOP)
	Q $$CLW(1,TOP,80,BTM)
	;
	;----------------------------------------------------------------------
CLW(PL,PT,PR,PB)	;System;Clear window
	;----------------------------------------------------------------------
	;
	; Clear window specified, return to top left of region.  Default is to
	; clear entire 80 column screen.
	;
	; If BTM<TOP or BTM beyond end of screen, clear entire page.
	;
	; KEYWORDS:	Screen handling
	;
	; ARGUMENTS:
	;	. PL		Left X coordinate	/TYP=N/DEF=1
	;
	;	. PT		Top Y coordinate	/TYP=N/DEF=1
	;
	;	. PR		Right X coordinate	/TYP=N/DEF=80
	;
	;	. PB		Bottom Y coordinate	/TYP=N/DEF=24
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$CLW^%TRMVT(5,10,30,15)
	;----------------------------------------------------------------------
	;
	I '$G(PL) S PL=1
	I '$G(PT) S PT=1
	I '$G(PR) S PR=80
	I '$G(PB) S PB=24
	;
	I PB<PT!(PB>23) Q $$CLR(PT)
	N x,z,pt
	;
	S x=PR-PL+1,z=$$CUP(PL,PT)_$$CLN(x)
	F pt=PT+1:1:PB S z=z_$$CUD_$$CLN(x)
	Q z_$$CUP(PL,PT)
	;
	;----------------------------------------------------------------------
CLEARXY()	;System;Clear screen, return to top left corner, save new $X,$Y
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Null			/TYP=T
	;
	; EXAMPLE:
	;	W $$CLEARXY^%TRMVT
	;
	W $$CLEAR
	S $X=0,$Y=0
	Q ""
	;
	;----------------------------------------------------------------------
CLRXY(TOP,BTM)	;System;Clear region, return to top left, save new $X, $Y
	;----------------------------------------------------------------------
	;
	; Clear region specified, return to top left of region.  Default is to
	; clear entire screen.  Save new values for $X and $Y
	;
	; If BTM<TOP or BTM beyond end of screen, clear entire page.
	;
	; KEYWORDS:	Screen handling
	;
	; ARGUMENTS:
	;	. TOP		Top line position	/TYP=N/DEF=1
	;
	;	. BTM		Bottom line  position	/TYP=N/DEF=24
	;
	; RETURNS:
	;	. $$		Null			/TYP=T
	;
	; EXAMPLE:
	;	W $$CLRXY^%TRMVT(5,10)
	;
	I '$G(TOP) Q $$CLEARXY
	W $$CLR(TOP,$G(BTM))
	S $X=0,$Y=TOP
	Q ""
	;
	;***********************************************************************
	;********** Keypad Functions *******************************************
	;***********************************************************************
	;
	;----------------------------------------------------------------------
KPAPP()	;System;Turn application keypad on
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Device handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$KPAPP^%TRMVT
	;
	Q $C(27)_"="
	;
	;----------------------------------------------------------------------
KPNUM()	;System;Turn numeric keypad on
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Device handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$KPNUM^%TRMVT
	;
	Q $C(27)_">"
	;
	;***********************************************************************
	;********** Region Lock Functions **************************************
	;***********************************************************************
	;
	;----------------------------------------------------------------------
LOCK(TOP,BTM)	;System;Lock region specified
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; ARGUMENTS:
	;	. TOP		Top line position	/TYP=N/DEF=1
	;
	;	. BTM		Bottom line position	/TYP=N/DEF=24
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$LOCK^%TRMVT(5,10)
	;
	Q $$CSI_$G(TOP)_";"_$G(BTM)_"r"
	;
	;***********************************************************************
	;********** Display and Graphics Functions *****************************
	;***********************************************************************
	;
	;----------------------------------------------------------------------
DBLH(TEXT)	;System;Display double high TEXT
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; ARGUMENTS:
	;	. TEXT		Text to display		/TYP=T
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$DBLH^%TRMVT("Tall text")
	;
	Q $C(27)_"#3"_TEXT_$$CUB($L(TEXT))_$$CUD_$C(27)_"#4"_TEXT
	;
	;----------------------------------------------------------------------
DBLW(TEXT)	;System;Display double wide TEXT
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; ARGUMENTS:
	;	. TEXT		Text to display		/TYP=T
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$DBLW^%TRMVT("Wide text")
	;
	Q $C(27)_"#6"_TEXT
	;
	;----------------------------------------------------------------------
GREN()	;System;Set terminal to handle business graphics display
	;----------------------------------------------------------------------
	;
	; Designates G0 ($$SO) as ASCII mode and G1 ($$SI) as graphics mode.
	; Must call once prior to performing using graphics.
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	W $$GREN^%TRMVT
	;
	Q $C(27)_"(B"_$C(27)_")0"
	;
	;----------------------------------------------------------------------
GRON()	;System;Turn graphics on
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$GRON^%TRMVT
	;
	Q $C(14)
	;
	;----------------------------------------------------------------------
GROFF()	;System;Turn graphics off
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$GROFF^%TRMVT
	;
	Q $C(15)
	;
	;----------------------------------------------------------------------
CROSS(X,Y)	;System;Draw a graphic cross (+) at X,Y
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; ARGUMENTS:
	;	. X		X coordinate		/TYP=N/DEF=$X
	;			Default to current location
	;
	;	. Y		Y coordinate		/TYP=N/DEF=$Y
	;			Default to current location
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$CROSS^%TRMVT(5,10)
	;
	Q $S($D(X):$$CUP(X,Y),1:"")_$$GRON_"n"_$$GROFF
	;
	;----------------------------------------------------------------------
LINE(LENGTH,X,Y)	;System;Draw a graphic line, length LINE at X,Y
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; ARGUMENTS:
	;	. LENGTH	Line length		/TYP=N/DEF=1
	;
	;	. X		X coordinate		/TYP=N/DEF=$X
	;			Default to current location
	;
	;	. Y		Y coordinate		/TYP=N/DEF=$Y
	;			Default to current location
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$LINE^%TRMVT(80,1,10)
	;
	N z
	S z="",$P(z,"q",$G(LENGTH)+1)=""
	Q $S($D(X):$$CUP(X,Y),1:"")_$$GRON_z_$$GROFF
	;
	;----------------------------------------------------------------------
UPLINE(X,Y)	;System;Draw a graphic upbar (|) at X,Y
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; ARGUMENTS:
	;	. X		X coordinate		/TYP=N/DEF=$X
	;			Default to current location
	;
	;	. Y		Y coordinate		/TYP=N/DEF=$Y
	;			Default to current location
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$UPLINE^%TRMVT(5,10)
	;
	Q $S($D(X):$$CUP(X,Y),1:"")_$$GRON_"x"_$$GROFF
	;
	;----------------------------------------------------------------------
BOX(ORIGIN,EXTANT)	;System;Draw a using given coordinates
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; ARGUMENTS:
	;	. ORIGIN	Top left corner		/TYP=T/DEF="1;1"
	;			Format is Y;X
	;
	;	. EXTANT	Bottom right corner	/TYP=T/DEF="23;79"
	;			Format is Y;X
	;
	; EXAMPLE:
	;	D BOX^%TRMVT("5;5","20;60")
	;
	N BOX,EX,EY,OX,OY,VL,HL,LINE
	;
	I '$D(ORIGIN) S ORIGIN="1;1"
	I '$D(EXTANT) S EXTANT="23;79"
	;
	S OY=+ORIGIN,OX=+$P(ORIGIN,";",2),EY=EXTANT-1,EX=+$P(EXTANT,";",2)
	;
	S BOX="lkmjxq"
	S HL="q",$P(HL,HL,EX)=""
	;
	W $$CUOFF,$C(14) 		; Toggle on graphics
	W $$VIDOFF			; Turn off video
	W $$CUP(OX,OY),$$CPS 		; Move cursor to origin and save
	W "l",HL,"k"			; Top left, Line, Top right
	I OX+EX=80 S LINE=$$CUD_"x"
	E  S LINE=$C(8)_$$CUD_"x"
	S $P(LINE,LINE,EY+1)=""
	W LINE,$$CPR 			; Right side vertical line, move back to origin
	S LINE=$$CUD_"x"_$C(8),$P(LINE,LINE,EY+1)=""
	S $X=0 
	W LINE				; Left side vertical line
	S $X=0 
	W $$CUD,"m",HL,"j"		; Bottom Left, Line, bottom right
	W $C(15) 			; Toggle graphics off
	W $$CUON
	Q
	;
	;----------------------------------------------------------------------
SHOWKEY(ar,pf,beg,end,novideo)	;System;Key display on bottom of screen
	;----------------------------------------------------------------------
	;
	; Displays function keys available on bottom screen line
	;
	; KEYWORDS:	Screen handling
	;
	; ARGUMENTS:
	;     . ar(term  	Function key terminator	/TYP=T
	;
	;     . ar(term)	Function key name	/TYP=T/MECH=REFARR:R
	;
	;     . pf		Display line prefix	/TYP=T/DEF=""
	;
	;     . beg		Starting column		/TYP=N/DEF=1
	;
	;     . end		Ending columns		/TYP=N/DEF=80
	;
	;     . novideo		Video attributes	/TYP=L/DEF=0
	;
	; EXAMPLE:
	;	D SHOWKEY^%TRMVT(.%fkey,"Keys")
	;
	N KBD,KBL,KBP,LEN,N
	;
	S KBD=$$KBD,KBL=$$KBL,KBP=$$KBP
	S pf=$G(pf) S:pf'="" pf=pf_"  "
	I '$G(beg) S beg=1
	I '$G(end) S end=80
	S LEN=end-beg+1
	;
	S N=""
	F  S N=$O(ar(N)) Q:N=""  S pf=pf_$$FKDES(ar(N))_"  "
	;
	S pf=$E(pf,1,LEN)_$J("",LEN-$L(pf)) I $G(novideo) Q pf
	Q $S(LEN<80:$$CUP(beg,24)_$$CLN(LEN),1:$$BTM)_$$VIDREV_pf_$$VIDOFF
	;
FKDES(X)	;Private;Build display string based on logical keyname
	;
	N KEY,DES,ALT
	S KEY=$P(X,"|",1),DES=$P(X,"|",2)
	S X=$P($P(KBL,(KEY_"|"),2),"|",1)
	S ALT="" I $E(X)="*" S X=$E(X,2,999),ALT=$P($$FKDES("ALT"),"=",1)
	I X="" S X=KEY
	E  S X=$P(KBP,"|",$L($P(KBP,("|"_X),1),"|"))
	S:DES="" DES=$P($P(KBD,(KEY_"|"),2),"|",1) I DES=X S DES=""
	Q ALT_"["_X_"]"_$S(DES="":"",1:"="_DES)
	;
	;----------------------------------------------------------------------
MSG(MSG,OPT,PWZ,CUX,CUY,TIM,TOF)	;Publi; Warning/error message display
	;----------------------------------------------------------------------
	;
	; Display warning and error messages to terminal
	;
	; KEYWORDS:	Screen handling
	;
	; ARGUMENTS:
	;	. MSG	Message to display		/TYP=T
	;
	;	. OPT	Error indicator			/TYP=L/DEF=0
	;		If 0, message, otherwise error
	;		Errors are highlighted
	;
	;	. PWZ	Pause until keyboard activity	/TYP=L/DEF=0
	;		Then clear display
	;		0 => no pause, 1 => pause
	;
	;	. CUX	Starting column			/TYP=N/DEF=1
	;
	;	. CUY	Starting row			/TYP=N/DEF=24
	;
	;	. TIM	Read timeout if pausing		/TYP=N
	;		Only applies if PWZ'=0		/DEF=$$TODFT^%ZREAD
	;
	;	. TOF	Return timeout to application	/TYP=L/DEF=0
	;		0 => handle timeout here
	;		1 => return to application on timeout
	;		     with %fkey="TIM"
	;		Only applies if PWZ'=0
	;
	; INPUTS:
	;	. %fkey(term  	Function key terminator	/TYP=T
	;
	;	. %fkey(term)	Function key name	/TYP=T/MECH=REFARR:R
	;
	; RETURNS:
	;	. %fkey		Return key		/TYP=T/COND
	;			Only returned if PWZ'=0 and TOF=1
	;
	; EXAMPLE:
	;	W $$MSG^%TRMVT("error text",1)
	;
	I '$$INTRACT^%ZFUNC() Q MSG	; *** 10/09/95 BC  Non-interactive mode
	I $G(OPT) S MSG=$$VIDERR_$C(7)_" "_MSG_" "
	E  S MSG=$$VIDMSG_MSG
	S MSG=$$CUP($G(CUX),$S($D(CUY):CUY,1:24))_MSG_$$VIDOFF_$$CLL
	I '$G(PWZ) Q MSG
	;
	I '$G(TIM) S TIM=$$TODFT^%ZREAD
	W MSG," ... Press any key to continue "
	N X R *X:TIM E  D TIMEOUT^%ZREAD($G(TOF))
	W $C(13),$$CLL
	Q ""
	;
	;***********************************************************************
	;********** Screen Control Functions ***********************************
	;***********************************************************************
	;
	;----------------------------------------------------------------------
SCRAWON()	;System;Turn autowrap on
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$SCRAWON^%TRMVT
	;
	Q $$CSI_"?7h"
	;
	;----------------------------------------------------------------------
SCRAWOFF()	;System;Turn autowrap off
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$SCRAWOFF^%TRMVT
	;
	Q $$CSI_"?7l"
	;
	;----------------------------------------------------------------------
SCR80()	;System;Set screen to 80 column display
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$SCR80^%TRMVT
	;
	Q $$CSI_"?3l"
	;
	;----------------------------------------------------------------------
SCR132()	;System;Set screen to 132 column display
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$SCR132^%TRMVT
	;
	Q $$CSI_"?3h"
	;
	;----------------------------------------------------------------------
SCR80XY()	;System;Set screen to 80 column display, reset $X,$Y to zero
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Null			/TYP=T
	;
	; EXAMPLE:
	;	W $$SCR80XY^%TRMVT
	;
	W $$SCR80
	S $X=0,$Y=0
	Q ""
	;
	;----------------------------------------------------------------------
SCR132XY()	;System;Set screen to 132 column display, reset $X, $Y to zero
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Null			/TYP=T
	;
	; EXAMPLE:
	;	S X=$$SCR132XY^%TRMVT
	;
	W $$SCR132
	S $X=0,$Y=0
	Q ""
	;
	;***********************************************************************
	;********** Slave Printer Functions ************************************
	;***********************************************************************
	;
	;----------------------------------------------------------------------
PRNTRDY()	;System;Inquire if printer is ready
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Ready			/TYP=L
	;			Returns 1 if ready,
	;			otherwise 0
	;
	; EXAMPLE:
	;	S READY=$$PRNTRDY^%TRMVT
	;
	N X
	U 0 W $$CSI_"?15n"
	R X:5 E  Q 0 ;					Timeout
	I $E($ZB,4,5)=10 Q 1 ;				Ready
	Q 0 ;						Not ready
	;
	;----------------------------------------------------------------------
PRNTON()	;System;Turn slave printer on
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$PRNTON^%TRMVT
	;
	Q $$CSI_"5i"
	;
	;----------------------------------------------------------------------
PRNTOFF()	;System;Turn slave printer off
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$PRNTOFF^%TRMVT
	;
	Q $$CSI_"4i"
	;----------------------------------------------------------------------
PRNTFF()	;System; Form feed
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	Printer handling
	;
	; RETURNS:
	;	. $$		Escape sequence		/TYP=T
	;
	; EXAMPLE:
	;	S X=$$PRNTFF^%TRMVT
	;
	Q $C(27,12)
	;
	;***********************************************************************
	;********** Terminal Definition Functions ******************************
	;***********************************************************************
	;
	;----------------------------------------------------------------------
CSI()	;System;Return CSI Value
	;----------------------------------------------------------------------
	;
	; Return CSI value ASCII 155, for an eight-bit environment.
	;
	; If differs by terminal, replace this routine with a custom routine
	; with the following change -- disable the first line of code in this
	; function and allow execution of the following lines.
	;
	; KEYWORDS:	Screen handling
	;
	; RETURNS:
	;	. $$		$C(155)			/TYP=T
	;
	; EXAMPLE:
	;	S CSI=$$CSI^%TRMVT
	;
	Q $C(27,91)
	; Q $C(155)
	;
	;----------------------------------------------------------------------
ZBINIT(OPT)	;System;Initialize function array
	;----------------------------------------------------------------------
	;
	; Initializes function key array to map function keys to input escape
	; sequences
	;
	; KEYWORDS:	Device handling
	;	
	; ARGUMENTS:
	;	. OPT		Keyboard map		/TYP=T/NOREQ
	;			Will use VT keyboard map
	;			if not defined
	;
	; RETURNS:
	;	. %fkey(term  	Function key terminator	/TYP=T
	;
	;	. %fkey(term)	Function key name	/TYP=T/MECH=REFARR:W
	;
	; EXAMPLE:
	;	D ZBINIT^%TRMVT
	;
	N X,Y,I
	S OPT=$$KBL($G(OPT))
	F I=2:2 S X=$P(OPT,"|",I) Q:X=""  S %fkey(X)=$P(OPT,"|",I-1)
	Q
	;
KBL(O)	;Private; Return string of VT escape sequences for VT keyboard for use
	; by ZBINIT.
	;
	I $G(O)'="",$D(^DBCTL("SYS","%KBUIM",O)) Q ^DBCTL("SYS","%KBUIM",O)
	;
	Q "CUU|[A|CUD|[B|CUF|[C|CUB|[D|ALT|OP|SES|OQ|MNU|OR|DUP|OS|HLP|[28~|END|[29~|FND|[1~|INS|[2~|REM|[3~|SEL|[4~|PUP|[5~|PDN|[6~|ESC|[23~|BUF|*[3~|TOP|*[5~|BOT|*[6~|RCL|*OS|ENT|13|CLR|21|DSP|23|PRN|16|KYB|11"
KBD()	Q "CUU|Up_Arrow|CUD|Down_Arrow|CUF|Right_Arrow|CUB|Left_Arrow|ALT|GOLD|MNU|Menu|DUP|Duplicate|HLP|Help|END|End|FND|Find|INS|Insert|REM|Remove|SEL|Select|PUP|Prev_Screen|PDN|Next_Screen|ESC|Escape|SES|Session|TOP|Top|BOT|Bottom|BUF|Buffer|RCL|Recall|ENT|Enter|DSP|Refresh_Screen|PRN|Print|KYB|Keypad_Emulate"
KBP()	Q " ^ |[A| v |[B| -> |[C| <- |[D|PF1|OP|PF2|OQ|PF3|OR|PF4|OS|Help|[28~|Do|[29~|Find|[1~|Insert|[2~|Remove|[3~|Select|[4~|Prev_Screen|[5~|Next_Screen|[6~|F6|[17~|F7|[18~|F8|[19~|F9|[20~|F10|[21~|F11|[23~|F12|[24~|F13|[25~|F14|[26~|F17|[31~|F18|[32~|F19|[33~|F20|[34~|Return|13|CTRL/P|16|CTRL/W|23|CRTL/K|11||"
