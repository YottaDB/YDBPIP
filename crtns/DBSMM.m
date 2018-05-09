 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSMM ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSMM ; 
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
RUN(rec) ; Compile PSL code (PF1 key)
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
TOPSL ; 
 ;
 D SYSVAR^SCADRV0()
 ;
 D cmpA2A^UCGM(.src,.msrc)
 ;
 Q 
 ;
LIST ; List object table (class, method, description, and script file name)
 ;
 N i
 N buf N last
 ; list system keywords
 ;
 S buf(1)=" Keyword                  Description"
 S buf(2)=" --------------------     -----------"
 S i=3
 ;
 N dskw,vos1,vos2,vos3 S dskw=$$vOpen1()
 ;
 F  Q:'$$vFetch1()  D
 .	;
 .	N keyword
 .	;
 . N keywd,vop1 S vop1=dskw,keywd=$$vRCgetRecord1Opt^RecordSTBLSYSKEYWD(vop1,1,"")
 .	;
 .	S keyword=vop1
 .	;
 .	S buf(i)=" "_keyword_$J("",25-$L(keyword))_$P(keywd,$C(124),1)
 .	S i=i+1
 . Q 
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
 N dsmeth,vos4,vos5,vos6,vos7 S dsmeth=$$vOpen2()
 ;
 F  Q:'$$vFetch2()  D
 .	;
 .	N des N method
 .	;
 . N objmeth,vop2,vop3 S vop3=$P(dsmeth,$C(9),1),vop2=$P(dsmeth,$C(9),2),objmeth=$$vRCgetRecord1Opt^RecordOBJECTMET(vop3,vop2,1,"")
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
 . Q 
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
 N dsprop,vos8,vos9,vos10,vos11 S dsprop=$$vOpen3()
 ;
 F  Q:'$$vFetch3()  D
 .	;
 .	N des N property
 .	;
 . N objprop,vop4,vop5 S vop5=$P(dsprop,$C(9),1),vop4=$P(dsprop,$C(9),2),objprop=$$vRCgetRecord1Opt^RecordOBJECTPROP(vop5,vop4,1,"")
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
 . Q 
 ;
 WRITE $$CLEAR^%TRMVT
 ;
 D ^DBSHLP("buf(")
 ;
 S %fkey="ENT"
 ;
 Q 
 ;
CONVERT(routine) ; Convert PSL code into a M routine
 ;
 N i N ln
 N msrc N src N z
 ;
 S routine=$ZCONVERT($piece($get(routine),".",1),"U")
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
HELP ; Display valid commands
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
command(help) ; 
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
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60233^64555^Dan Russell^6275" ; Signature - LTD^TIME^USER^SIZE
 ;
vOpen1() ; KEYWORD FROM STBLSYSKEYWD ORDER BY KEYWORD ASC
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL1a3 S vos3=$O(^STBL("SYSKEYWORDS",vos3),1) I vos3="" G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a3
 I vos1=2 S vos1=1
 ;
 I vos1=0 S dskw="" Q 0
 ;
 S dskw=$S(vos3=vos2:"",1:vos3)
 ;
 Q 1
 ;
vOpen2() ; CLASS,METHOD FROM OBJECTMET ORDER BY CLASS,METHOD ASC
 ;
 ;
 S vos4=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos4=0 Q
vL2a1 S vos5=$$BYTECHAR^SQLUTL(254)
 S vos6=""
vL2a3 S vos6=$O(^OBJECT(vos6),1) I vos6="" G vL2a0
 S vos7=""
vL2a5 S vos7=$O(^OBJECT(vos6,1,vos7),1) I vos7="" G vL2a3
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos4=1 D vL2a5
 I vos4=2 S vos4=1
 ;
 I vos4=0 S dsmeth="" Q 0
 ;
 S dsmeth=$S(vos6=vos5:"",1:vos6)_$C(9)_$S(vos7=vos5:"",1:vos7)
 ;
 Q 1
 ;
vOpen3() ; CLASS,PROPERTY FROM OBJECTPROP ORDER BY CLASS,PROPERTY ASC
 ;
 ;
 S vos8=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos8=0 Q
vL3a1 S vos9=$$BYTECHAR^SQLUTL(254)
 S vos10=""
vL3a3 S vos10=$O(^OBJECT(vos10),1) I vos10="" G vL3a0
 S vos11=""
vL3a5 S vos11=$O(^OBJECT(vos10,0,vos11),1) I vos11="" G vL3a3
 Q
 ;
vFetch3() ;
 ;
 ;
 I vos8=1 D vL3a5
 I vos8=2 S vos8=1
 ;
 I vos8=0 S dsprop="" Q 0
 ;
 S dsprop=$S(vos10=vos9:"",1:vos10)_$C(9)_$S(vos11=vos9:"",1:vos11)
 ;
 Q 1
