 ; 
 ; **** Routine compiled from DATA-QWIK Procedure TBXBLDCK ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
 ;  #PACKAGE framework.tbx
 ;
 ;  #OPTION ResultClass ON
 ;
 ; =====================================================================
check(bldDir) ; build directory
 N files
 ;
 D checkDir(bldDir,.files)
 Q 
 ;
 ; =====================================================================
checkDir(srcDir,files) ; files found so far
 N all N elem N zsea S zsea=srcDir_"/*"
 ;
 ;  #ACCEPT DATE=2007-02-20;PGM=Frans S.C. Witte;CR=none;GROUP=BYPASS
 ;*** Start of code by-passed by compiler
 FOR  SET elem=$ZSEARCH(zsea) QUIT:elem=""  SET all($ZPARSE(elem,"NAME")_$ZPARSE(elem,"TYPE"))=$ZPARSE(elem,"DIR")
 ;*** End of code by-passed by compiler ***
 ;
 S elem=""
 F  S elem=$order(all(elem)) Q:(elem="")  D
 .	; no dot, must be folder. Check recursively.
 .	I elem'["." D checkDir(srcDir_"/"_elem,.files) Q 
 .	;
 .	; first occurrence of this element name, remember its directory
 .	I '($D(files(elem))#2) S files(elem)=all(elem) Q 
 .	;
 .	; duplicate file name, report on standard out
 .	WRITE "duplicate element name "_elem,!
 .	WRITE "found in "_files(elem),!
 .	WRITE "and in   "_all(elem),!
 .	WRITE !
 .	Q 
 Q 
 ;
 ; =====================================================================
latest(prio) ; 
 N bld,vop1 S bld=$$vRCgetRecord1Opt^RecordTBXBUILD(prio,0,.vop1)
 I $G(vop1)=0 WRITE "No build with prioritry "_prio,! Q 
 I ($P(bld,$C(124),4)="") WRITE "No build has been installed for priority "_prio,! Q 
 ;
 N files
 N dir S dir="/profile_release/"
 ;
 I prio=0 D
 .	S dir=dir_"fp/Fp_"_$P(bld,$C(124),3)_"_CR"_$P(bld,$C(124),4)
 .	Q 
 E  D
 .	S dir=dir_"sp/SP_"_$P(bld,$C(124),3)_"_"_$P(bld,$C(124),4)
 .	Q 
 ;
 WRITE "checking "_dir,!
 WRITE "installed on "_$S($P(bld,$C(124),6)'="":$ZD($P(bld,$C(124),6),"MM/DD/YEAR"),1:"")_" by "_$P(bld,$C(124),5),!
 ;
 D checkDir(dir,.files)
 ;
 WRITE "done!",!
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61446^29875^Frans S.C. Witte^2839" ; Signature - LTD^TIME^USER^SIZE
