TBXRJL	;Public; Rejected element loader
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/09/02 15:44:13 - JOYCEJ
	;
	;-----------------------------------------------------------------------
	;
	; DATA QWIK elements rejected during the installation of a Service or
	; Fix Pack can be loaded individually with this function
	;
	;---------- Revision History -------------------------------------------
	; 2009-06-18, CR40964, Jaywant Khairnar
	;	* Changed the call to TBXINST labels instead of TBXSPIN labels
	;	* Changed it to support TBX autobuild
	;
	; 2009-04-28, CR39019, Jaywant Khairnar
	;	* Rewritten to support new TBXREJ global structure and for cleaner code
	;	* Removed the FOLDER parameter
	;	* ^TBXREJ(FILE,PRIORITY)
	;
	; 2008-09-30, CR34458,  Frans S.C. Witte
	;	Modified PROC() to use new signature of $$LOAD^TBXSFILE(), and
	;	to process "ini" folder rejects.
	;	
	S %LOGID=$$LOGID^SCADRV
	S %="|"
	D MAIN()
	Q
	;
	;-----------------------------------------------------------------------
MAIN()	; Function entry point
	;-----------------------------------------------------------------------
	;
	; File(enter * for ALL) - Enter or select rejected file element to be processed
	;	# Enter * to process all reject elements
	;	# Enter *.TYP (TYP is element type like PROC or M or TRIG etc) 
	;	  to process all elements of same TYP
	;
	; Build Priority(enter * for ALL) - Enter or select priority of the element to be processed	
	;	# Enter * to process selected element for it's highest available priority.
	;	# For file value as * or *.TYP the priority value will be * only.
	;
	N %TAB,%READ,ER,FOLDER,FILE,HDR,OK,RM,TYP,db,zlogf
	;
	; routine directory names default is MRTNS
	;
	S PRIO="*"
	;
        S %TAB("FILE")="/LEN=50/TYP=T/DES=File(enter * for ALL)/TBL=^TBXREJ(/XPP=D POSTP^TBXRJL()"
        S %TAB("PRIO")="/LEN=50/TYP=T/DES=Build Priority(enter * for HIGHEST)/TBL=^TBXREJ(FILE,/XPP=D POSTP^TBXRJL()"
        S HDR="Load Rejected Elements"
        ;
        S %READ="@HDR/CEN/REV,,FILE/REQ,PRIO/REQ"
        ;
        D ^UTLREAD
        I VFMQ="Q" Q
        ;
        W $$MSG^%TRMVT("You are about to overlay the selected element(s)",0,0,1,23)
        S OK=$$YN^DBSMBAR("","Do you want to continue?",1)
        ;
        I OK=0 S ER="W",RM="Installation cancelled." Q
        ;
	s zlogf=0
	Q:ER
	;
	s db=$$database^TBXINST()
        ;
        ; process all reject elements for selected priority
        ;
        I $P(FILE,".")="*" D  Q:ER
        .	S TYP=$$UPPER^UCGMR($P(FILE,"*.",2))
        .	S FILE="" 
	.	F  S FILE=$O(^TBXREJ(FILE)) Q:FILE=""  D
	..		I TYP="" D PROC(FILE,PRIO)
	..		I TYP=$$UPPER^UCGMR($P(FILE,".",2)) D PROC(FILE,PRIO)
        E  D  Q:ER
        .	; selected a single reject element to process
        .	;
        .	D PROC(FILE,PRIO)	
        ;
        ; database is oracle or DB2
        ;
        i (db'="GTM") d
        . d CRTABLE^TBXSQL,MODIFYTB^TBXSQL,UPDRDB^TBXSQL,eConstrt^TBXSQL,ALL^DBMAP(db)
        ;
        D COMPALL^TBXDQUTL(zlogf)
        Q
        ;
        ;----------------------------------------------------------------------
PROC(FILE,PRIO)    ; Load DQ element
        ;----------------------------------------------------------------------
        ;
        ; ARGUMENTS:
	; . FILE - element name.
	; . PRIO - priority of element
	;
        W FILE,!
	;
	N CODE,DATE,FILEPATH,FOLDER,INFO,LOAD,PVB,RES,REVISION,RTN,TIME,USER,X
	;
	; fetch the reject element information 
	;
	S LOAD=0
	S:PRIO="*" PRIO=$O(^TBXREJ(FILE,""))
	S INFO=$G(^TBXREJ(FILE,PRIO))
	Q:INFO=""
	S REVISION=$P(INFO,"|",1)			; Revision of element
	S USER=$P(INFO,"|",2)				; USER
	S DATE=$P(INFO,"|",3)
	S TIME=$P(INFO,"|",4)
	S PVB(PRIO,"PROJ")=$P(INFO,"|",5)		; Project
	S PVB(PRIO,"VIEW")=$P(INFO,"|",6)		; View
	S PVB(PRIO,"BLD")=$P(INFO,"|",7)		; CR number or Build
	S RTN=$P(INFO,"|",8)				; routine name
	S FILEPATH=$P(INFO,"|",13)			; file to load (complete path)
	S FOLDER=$P(FILEPATH,"/",$L(FILEPATH,"/")-1)
	;
	; read the file contents from the source file and stores it in CODE array
	;
	D GETCODE(.CODE,$P(INFO,"|",13)) I ER U 0 W !,RM,! Q
	;
	; loads the element based on their type and folder
	;
	S RES=0
	I "doc,exp,gog,help,ini,uxscrpt"[FOLDER D
	.	S X=$$LOAD^TBXSFILE(FILE,FOLDER,FILEPATH)
	.	I X=0 S RES=1
	.	S:+X=1 X=0
	.	S:RES=1 X=1
	.	S LOAD=1
	E  D
	.	I $$UPPER^UCGMR($P(FILE,".",2))="COL" S X=$$LOAD^TBXCOL(.CODE,FILE,2,USER,DATE,TIME) S LOAD=1
	.	I $$UPPER^UCGMR($P(FILE,".",2))="TBL" S X=$$LOAD^TBXTBL(.CODE,FILE,2,USER,DATE,TIME) S LOAD=1
	.	I $$UPPER^UCGMR($P(FILE,".",2))="M" S X=$$LOAD^TBXRTN(FILE,"",FILEPATH,"MRTNS",1,1) S LOAD=1
	;
	I LOAD=0 D
	.	I RTN="TBXPSLX" S CMD="S X=$$LOAD^"_RTN_"(FILEPATH)" X CMD Q
	.	I RTN'="TBXPROC" S CMD="S X=$$LOAD^"_RTN_"(.CODE,FILE,2,USER,DATE,TIME)"
	.	E  S CMD="S X=$$LOAD^"_RTN_"(.CODE,FILE,2,USER,DATE,TIME,FILEPATH)"
	.	X CMD
	; 
	; logs the error during the load
	;
	I +X=0 D  Q
	.	S ER=1
	.	S RM="Not Loaded: "_$P(X,"|",2)
	.	w !,RM,!
	.	D LOG^TBXINST(DATE,FILE,FOLDER,.PVB,PRIO,REVISION,TIME,USER,RM)
	;
	I X D LOG^TBXINST(DATE,FILE,FOLDER,.PVB,PRIO,REVISION,TIME,USER,"Loaded from reject table")
	;
	; removes the reject entry from ^TBXREJ after processing it.
	K ^TBXREJ(FILE,PRIO)
	; delete the "installed from FP indicator"
	;
	I PRIO>0 D		; service pack instllation element
	. K ^TBXFIX(FILE)
	. S ^TBXINST(FILE)=REVISION_"|"_USER_"|"_DATE_"|"_TIME_"|"_FOLDER_"|"_+$H_"|"_PVB(PRIO,"BLD")_"|"_PRIO
	E  D			; fix pack installation element
	. S ^TBXFIX(FILE)=REVISION_"|"_USER_"|"_DATE_"|"_TIME_"|"_FOLDER_"|"_+$H_"|"_PVB(PRIO,"BLD")_"|"_PRIO 
	;
	I $D(^TBXFIX(FILE)) K ^TBXFIX(FILE)
	;
	Q
	;
        ;----------------------------------------------------------------------
POSTP()	; File prompt post processor
        ;----------------------------------------------------------------------
        I $P(X,".")="*" D CHANGE^DBSMACRO("TBL","")
        Q
	;
	;---------------------------------------------------------------------
GETCODE(CODE,FPATH) ; 
	;---------------------------------------------------------------------
	;
	; ARGUMENTS:
	; . CODE -  dataqwik content into array CODE  
	; . FPATH - complete file path
	;	
	;
	N FILE,LINE,X,Z
	;
	S FILE=FPATH
	;
	;
	S Z="",ER=""
	S Z=$ZSEARCH(FILE)
	I Z="" S ER=1,RM="File "_FILE_" is not found" Q
	;
	S X=$$FILE^%ZOPEN(FILE,"READ")
	I 'X S ER=1,RM=$P(X,"|",2) Q
	F  U FILE R LINE q:$ZEOF  D
	.	I $ZEOF Q 
	. 	S CODE($O(CODE(""),-1)+1)=LINE
	C FILE
	Q
	;
	;---------------------------------------------------------------------