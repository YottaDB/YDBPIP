DBSMM	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSMM ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	N cmd N hlp N initfl N key N par
	;
	WRITE $$CLEAR^%TRMVT
	;
	S cmd("RUN")="D RUN^DBSMM(rec),REF^EDIT" ; D key processing
	S cmd("LIST")="D LIST^DBSMM,REF^EDIT" ; List class & method
	S cmd("HELP")="D HELP^DBSMM,REF^EDIT"
	S cmd("?")="D HELP^DBSMM,REF^EDIT" ; Display valid options
	S cmd("CONVERT")="D CONVERT^DBSMM(1/REQ),REF^EDIT"
	;
	S par("DIRECTORY")=$$HOME^%TRNLNM ; Default directory
	S par("EXTENSION")="PROC" ; Default file type
	S par("SOURCE")="PSL" ; PSL mode
	S par("STATUS")="SOURCE,EXTENSION" ; status option
	;
	S key("END")="RUN"
	S initfl=$$HOME^%TRNLNM("DBSMM.INI") ; Parameter init file
	;
	S par="DIRECTORY,EXTENSION,SOURCE"
	;
	D command(.hlp)
	;
	D ^EDIT(,,,,,.cmd,.key,.par,"PSL Interactive Editor","hlp(",initfl)
	;
	Q 
	;
RUN(rec)	; Compile PSL code (PF1 key)
	;
	N i N ln N zln
	N %fkey N msrc N src
	;
	USE 0
	;
	S zln=$L(rec,$C(13,10))+1
	S ln=zln
	I (zln>12) S zln=12 ; Allocate room for error messages
	;
	WRITE $$CLRXY^%TRMVT(zln,24)
	WRITE !,"----------------------------- Error Message ------------------------------",!
	;
	F i=1:1:ln S src(i)=$piece(rec,$C(13,10),i)
	;
	D TOPSL
	;
	; disply M code
	;
	WRITE !,$$MSG^%TRMVT("Display M code",0,1),!
	;
	WRITE $$CLEAR^%TRMVT
	WRITE $$LOCK^%TRMVT
	;
	D ^DBSHLP("msrc(",,,,"Converted PSL procedural code") ; Display M code
	;
	WRITE $$MSG^%TRMVT("")
	;
	S %fkey="ENT" ; Reset F11 key
	;
	Q 
	;
TOPSL	;
	;
	D SYSVAR^SCADRV0()
	;
	D cmpA2A^UCGM(.src,.msrc)
	;
	Q 
	;
LIST	; List object table (class, method, description, and script file name)
	;
	N i
	N buf N last
	; list system keywords
	;
	S buf(1)=" Keyword                  Description"
	S buf(2)=" --------------------     -----------"
	S i=3
	;
	N dskw,vos1,vos2 S dskw=$$vOpen1()
	;
	F  Q:'($$vFetch1())  D
	.	;
	.	N keyword
	.	;
	.	N keywd,vop1 S vop1=dskw,keywd=$G(^STBL("SYSKEYWORDS",vop1))
	.	;
	.	S keyword=vop1
	.	;
	.	S buf(i)=" "_keyword_$J("",25-$L(keyword))_$P(keywd,$C(124),1)
	.	S i=i+1
	.	Q 
	;
	WRITE $$CLEAR^%TRMVT
	;
	D ^DBSHLP("buf(")
	;
	S %fkey="ENT"
	;
	; list class, method, and script file information
	K buf
	;
	S buf(1)=" Class      Method         Description                             Script File"
	S buf(2)=" -----      ------         -----------                             ------------"
	S i=3
	S last=""
	;
	N dsmeth,vos3,vos4,vos5 S dsmeth=$$vOpen2()
	;
	F  Q:'($$vFetch2())  D
	.	;
	.	N des N method
	.	;
	.	N objmeth,vop2,vop3 S vop3=$P(dsmeth,$C(9),1),vop2=$P(dsmeth,$C(9),2),objmeth=$G(^OBJECT(vop3,1,vop2))
	.	;
	.	I (last'=vop3) D
	..		;
	..		S buf(i)=" "_vop3
	..		S i=i+1
	..		S last=vop3
	..		Q 
	.	;
	.	S method=vop2
	.	S des=$P(objmeth,$C(124),4)
	.	;
	.	S buf(i)="            "_method_$J("",15-$L(method))_des_$J("",40-$L(des))_$P(objmeth,$C(124),7)
	.	S i=i+1
	.	Q 
	;
	D ^DBSHLP("buf(")
	;
	S %fkey="ENT"
	;
	; list property
	K buf
	;
	S buf(1)=" Class      Property       Description                              Script File"
	S buf(2)=" -----      --------       -----------                              -----------"
	S i=3
	S last=""
	;
	N dsprop,vos6,vos7,vos8 S dsprop=$$vOpen3()
	;
	F  Q:'($$vFetch3())  D
	.	;
	.	N des N property
	.	;
	.	N objprop,vop4,vop5 S vop5=$P(dsprop,$C(9),1),vop4=$P(dsprop,$C(9),2),objprop=$G(^OBJECT(vop5,0,vop4))
	.	;
	.	I (last'=vop5) D
	..		;
	..		S buf(i)=" "_vop5
	..		S i=i+1
	..		S last=vop5
	..		Q 
	.	;
	.	S property=vop4
	.	S des=$P(objprop,$C(124),4)
	.	;
	.	S buf(i)="            "_property_$J("",15-$L(property))_des_$J("",40-$L(des))_$P(objprop,$C(124),5)
	.	S i=i+1
	.	Q 
	;
	WRITE $$CLEAR^%TRMVT
	;
	D ^DBSHLP("buf(")
	;
	S %fkey="ENT"
	;
	Q 
	;
CONVERT(routine)	; Convert PSL code into a M routine
	;
	N i N ln
	N msrc N src N z
	;
	S routine=$$vStrUC($piece($get(routine),".",1))
	I (routine="") S routine="Z"
	;
	S ln=$L(rec,$C(13,10))-1
	;
	F i=1:1:ln S src(i)=$piece(rec,$C(13,10),i)
	;
	WRITE $$CLRXY^%TRMVT(12,24)
	WRITE !,"----------------------------- Error Message ------------------------------",!
	D TOPSL
	;
	; Add routine name
	I ($E(msrc(1),1,$L(routine))'=routine) D
	.	;
	.	S msrc(.1)=routine_" ; PSL conversion"
	.	D ^SCACOPYR(.z) ; Copyright messaqge
	.	S msrc(.2)=z
	.	Q 
	;
	S msrc(.25)=" ;------ PSL source code -------"
	S msrc(.3)=" ;"
	S z=""
	F i=1:1 S z=$order(src(z)) Q:(z="")  D
	.	;
	.	S msrc((i/1000)+.3)=" ; "_src(z)
	.	Q 
	S msrc(((i+1)/1000)+.3)=" ;"
	S msrc(((i+2)/1000)+.3)=" ;------ Compiled M code ------"
	S msrc(((i+3)/1000)+.3)=" ;"
	;
	WRITE $$MSG^%TRMVT("Routine "_routine_".M created",,1)
	;
	D ^%ZRTNCMP(routine,"msrc",0,"")
	;
	Q 
	;
HELP	; Display valid commands
	;
	N buf
	;
	D command(.buf)
	;
	D ^DBSHLP("buf(")
	;
	S %fkey="ENT" ; Reset F11 key
	;
	Q 
	;
command(help)	;
	;
	S help(1)="      *** Press <GOLD><7> keys to access command line ***"
	S help(2)=""
	S help(3)=" Command                                               Syntax"
	S help(4)=" -------                                               ---------------"
	S help(5)=""
	S help(6)=" CLEAR     Clears the contents of the buffer           [CL]EAR"
	S help(7)=""
	S help(8)=" CONVERT   Convert PSL statements into a M routine     [CON]VERT Z_routine_name"
	S help(9)=""
	S help(10)=" EDIT      Edit a PSL script file                      [ED]IT filename"
	S help(11)=""
	S help(12)=" INCLUDE   Append a file to the current buffer         [IN]CLUDE filename"
	S help(13)=""
	S help(14)=" LIST      List classes, methods, and keywords         [LI]ST"
	S help(15)=""
	S help(16)=" SAVE      Save the current buffer into a script file  [SA]VE filename"
	S help(17)=""
	;
	Q 
	;
vSIG()	;
	Q "60233^64544^Dan Russell^6269" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
	;
vOpen1()	;	KEYWORD FROM STBLSYSKEYWD ORDER BY KEYWORD ASC
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=""
vL1a2	S vos2=$O(^STBL("SYSKEYWORDS",vos2),1) I vos2="" G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a2
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S dskw=$S(vos2=$C(254):"",1:vos2)
	;
	Q 1
	;
vOpen2()	;	CLASS,METHOD FROM OBJECTMET ORDER BY CLASS,METHOD ASC
	;
	;
	S vos3=2
	D vL2a1
	Q ""
	;
vL2a0	S vos3=0 Q
vL2a1	S vos4=""
vL2a2	S vos4=$O(^OBJECT(vos4),1) I vos4="" G vL2a0
	S vos5=""
vL2a4	S vos5=$O(^OBJECT(vos4,1,vos5),1) I vos5="" G vL2a2
	Q
	;
vFetch2()	;
	;
	;
	I vos3=1 D vL2a4
	I vos3=2 S vos3=1
	;
	I vos3=0 Q 0
	;
	S dsmeth=$S(vos4=$C(254):"",1:vos4)_$C(9)_$S(vos5=$C(254):"",1:vos5)
	;
	Q 1
	;
vOpen3()	;	CLASS,PROPERTY FROM OBJECTPROP ORDER BY CLASS,PROPERTY ASC
	;
	;
	S vos6=2
	D vL3a1
	Q ""
	;
vL3a0	S vos6=0 Q
vL3a1	S vos7=""
vL3a2	S vos7=$O(^OBJECT(vos7),1) I vos7="" G vL3a0
	S vos8=""
vL3a4	S vos8=$O(^OBJECT(vos7,0,vos8),1) I vos8="" G vL3a2
	Q
	;
vFetch3()	;
	;
	;
	I vos6=1 D vL3a4
	I vos6=2 S vos6=1
	;
	I vos6=0 Q 0
	;
	S dsprop=$S(vos7=$C(254):"",1:vos7)_$C(9)_$S(vos8=$C(254):"",1:vos8)
	;
	Q 1
