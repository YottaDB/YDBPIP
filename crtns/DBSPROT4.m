 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSPROT4 ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSPROT4(FILES,DINAM,%MCODE,TYPE,VTABNO,vobjlst) ; 
 ;
 N isPSL
 N PROTSTAT
 N FID N PGM N RM
 ;
 S FID=$piece(FILES,",",1)
 ;
 S isPSL=($D(vobjlst("actual"))#2)
 ;
 ; Always return at least one line
 I isPSL S %MCODE(1)=" //"
 E  S %MCODE(1)=" ;"
 ;
 ; Check protection status - if none, we're done
 D STATUS^UPID(FID,DINAM,.PROTSTAT) Q:(PROTSTAT=0) 
 ;
 ; Get protection program name
 D ^UPID(FID,.PGM)
 ;
 I (PGM="") D  Q 
 .	;
 .	; Protection program name not set up for file ~p1
 .	I '($D(RM)#2) S RM=$$^MSG(2279,FID)
 .	;
 .	WRITE !,RM,!
 .	Q 
 ;
 ; Handle single data item
 I (DINAM'="*") D
 .	;
 .	N code
 .	;
 .	N tblrec S tblrec=$$getSchTbl^UCXDD(FID)
 .	;
 .	WRITE !," ["_FID_"]"_DINAM_" *** Data Item Protection *** "
 .	;
 .	; Option 1 (modify mode only)  option 2 (create & modify)
 .	I (%FLGPROT=1) D
 ..		;
 ..		I isPSL S code=" if %ProcessMode > 0"
 ..		E  S code=" if %O>0"
 ..		Q 
 .	E  S code=""
 .	;
 .	S code=code_" set VP("""_DINAM_""")="""""
 .	S code=code_" do %EXT^"_PGM_"("_$P(tblrec,"|",17)_",.VP)"
 .	S code=code_" set VP=VP("""_DINAM_""") kill VP("""_DINAM_""")"
 .	S code=code_" if VP set VPTBL("_VTABNO_")=VP"
 .	;
 .	S %MCODE(1)=code
 .	Q 
 ;
 ; Record level protection
 E  D
 .	;
 .	N CNT
 .	N code N LINES
 .	;
 .	WRITE !," ["_FID_"] *** Record Level Protection *** "
 .	;
 .	S CNT=1
 .	;
 .	S LINES=""
 .	S $piece(LINES,"-",68)=""
 .	I isPSL S LINES=" //"_LINES
 .	E  S LINES=" ;"_LINES
 .	;
 .	I isPSL S %MCODE(1)=" do VPROT("_vobjlst("actual")_") quit:ER  do V1("_vobjlst("actual")_") quit"
 .	E  S %MCODE(1)=" do VPROT quit:ER  goto V1"
 .	;
 .	S CNT=CNT+1
 .	S %MCODE(2)=LINES
 .	S CNT=CNT+1
 .	;
 .	I isPSL S %MCODE(3)="VPROT("_vobjlst("formal")_") // Record level protection"
 .	E  S %MCODE(3)="VPROT ; Record level protection"
 .	;
 .	S CNT=CNT+1
 .	S %MCODE(4)=LINES
 .	S CNT=CNT+1
 .	;
 .	S %MCODE(5)=" kill VPTBL set ER=1,VP=$$EXT^"_PGM_"("_$get(vobjlst("actual"))_") if VP set VFMQ=""Q"""
 .	; Record protected
 .	S %MCODE(5)=%MCODE(5)_",RM="_$$QADD^%ZS($$^MSG(2336),"""")
 .	S CNT=CNT+1
 .	;
 .	I isPSL D
 ..		;
 ..		S %MCODE(CNT)=" #ACCEPT DATE=03/22/05; PGM=Screen Compiler"
 ..		S CNT=CNT+1
 ..		S %MCODE(CNT)=" if (VP = 2), (%ProcessMode <> 0) xecute KVAR quit  // No Access"
 ..		S CNT=CNT+1
 ..		S %MCODE(CNT)=" #ACCEPT DATE=03/22/05; PGM=Screen Compiler"
 ..		S CNT=CNT+1
 ..		S %MCODE(CNT)=" if (VP = 1), (%ProcessMode = 0) xecute KVAR quit  // Display Only"
 ..		S CNT=CNT+1
 ..		S %MCODE(CNT)=" #ACCEPT DATE=03/22/05; PGM=Screen Compiler"
 ..		S CNT=CNT+1
 ..		S %MCODE(CNT)=" if (VP = 1), (%ProcessMode = 1) do VLOD("_vobjlst("actual")_"), VPR("_vobjlst("actual")_"), VDA"
 ..		S %MCODE(CNT)=%MCODE(CNT)_" set %ProcessMode = 2 do ^DBSPNT(), ^DBSCRT8A set %ProcessMode = 1 xecute KVAR set ER = 1 quit"
 ..		S CNT=CNT+1
 ..		Q 
 .	E  D
 ..		;
 ..		S %MCODE(CNT)=" if VP=2,%O'=0 xecute KVAR quit  ; No Access"
 ..		S CNT=CNT+1
 ..		S %MCODE(CNT)=" if VP=1,%O=0 xecute KVAR quit  ; Display Only"
 ..		S CNT=CNT+1
 ..		S %MCODE(CNT)=" if VP=1,%O=1 do VLOD,VPR,VDA"
 ..		S %MCODE(CNT)=%MCODE(CNT)_" set %O=2 do ^DBSPNT(),^DBSCRT8A set %O=1 xecute KVAR set ER=1 quit"
 ..		S CNT=CNT+1
 ..		Q 
 .	;
 .	S %MCODE(CNT)=" set ER=0 quit"
 .	S CNT=CNT+1
 .	S %MCODE(CNT)=LINES
 .	S CNT=CNT+1
 .	;
 .	I isPSL D
 ..		;
 ..		S %MCODE(CNT)=" //"
 ..		S CNT=CNT+1
 ..		S %MCODE(CNT)="V1("_vobjlst("formal")_") //"
 ..		Q 
 .	E  D
 ..		;
 ..		S %MCODE(CNT)=" ;"
 ..		S CNT=CNT+1
 ..		S %MCODE(CNT)="V1 ;"
 ..		Q 
 .	Q 
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60541^55254^Dan Russell^6003" ; Signature - LTD^TIME^USER^SIZE
