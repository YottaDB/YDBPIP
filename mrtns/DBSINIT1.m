DBSINIT1	;;DBS - U - V4.4 - INIT DQ CONTROL TABLES ( PART II)
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 03/27/97 18:14:41 - CHIANG
	;     ORIG:   CHIANG - 1/1/85
	;     DESC:  INIT ^DBCTL("SYS") TABLE
	;
	; GLOBALS -  ^DBCTL
	;     READ:
	;      SET:  ^SCAFUN
	;
	;    INPUT:
	;   OUTPUT:
	;
	; PART 2 OF DBSINIT
	;
        ; I18N=QUIT: Exclude from I18N standards
	;---- Revision History -------------------------------------------------
	;
	; 03/27/97 - Chiang - 24316
	;            Modified to reference CUAAR (institution variables) file
	;            for the current format edit mask information.
	;
	; 06/28/96 - SPIER - 22281
	;            Removed the hard coded initialization of country codes
	;	     US,CZ and PT into label CNTRY. This will allow changes
	;	     made in DBSFMT function to remain in the system.  This
	;	     is now possible due to ability of trackware to release
	;	     the DBCTL global.  
	;	     Removed Text warp(not supported) and changed RND# to RNDn
	;-----------------------------------------------------------------------
	;
START	;
	I $P($T(INIT+1),"\",2,9)="" Q	; *** BC - Skip if routine source not available
	;
	;---------- days and months default
	;
	K ^DBCTL("SYS","RFMT"),^("QWIKFUN")
	F I=1:1 S X=$P($T(INIT+I),"\",2,9) Q:X=""  S P1=$P(X,",",1),P2=$P(X,",",2),P3=$P(X,",",3,99)  S ^DBCTL("SYS",P1,P2)=P3
	;
	;
	;========== Init 4th level tables
	;
	F I=1:1 S X=$P($T(INIT2+I),"\",2,9) Q:X=""  S P1=$P(X,",",1),P2=$P(X,",",2),P3=$P(X,",",3),P4=$P(X,",",4,99)  S ^DBCTL("SYS",P1,P2,P3)=P4
	;
	; ---------- Replace default table with user defined table
	;
	; *** 03/27/97
	;
	S MASKOPT=$P(^CUVAR("DBS"),"|",6) I MASKOPT="" S MASKOPT="US"
	;
	I '$D(^DBCTL("SYS","*DVFM",MASKOPT)) Q
	;
	F TYP="DVFM","RFMT" S X="" F  S X=$O(^DBCTL("SYS","*"_TYP,MASKOPT,X)) Q:X=""  DO
	.	;
	.	F J=2,4,6,9 S $P(^DBCTL("SYS",TYP,X),"|",J)=$P(^DBCTL("SYS","*"_TYP,MASKOPT,X),"|",J)
	.	;
	.	I X'="D" Q
	.	F I="MS","ML","DS","DL" D
	..	S ^DBCTL("SYS",TYP,X,I)=^DBCTL("SYS","*"_TYP,MASKOPT,X,I)
	S ^DBCTL("SYS","DVFM")=MASKOPT 			; *** 03/27/97
	Q
CNTRY	;
	K ^DBCTL("SYS","*RFMT","PT")
	;
	N CNTRY,ML,MS,DL,DS
	S MS="Jan,Feb,Mar,Apr,May,Jun,Jul,Aug,Sep,Oct,Nov,Dec"
	S ML="January,February,March,April,May,June,July,August,September"
	S ML=ML_",October,November,December"
	S DS="Sun,Mon,Tue,Wed,Thu,Fri,Sat"
	S DL="Sunday,Monday,Tuesday,Wednesday,Thursday,Friday,Saturday"
	;
	S ^DBCTL("SYS","*RFMT","US")="United States"
	S ^DBCTL("SYS","*RFMT","PT")="Portugal"
	;	
	;========== Init format table for country code PT
	;
	F I=1:1 S X=$P($T(INIT3+I),"\",2,9) Q:X=""  S P1=$P(X,",",1),P2=$P(X,",",2),P3=$P(X,",",3),P4=$P(X,",",4,99)  S ^DBCTL("SYS",P1,P2,P3)=P4
	;
	;---------- Defaults for PT --------------------------------------------
	;
	S DL="Domingo,Lunes,Martes,Miercoles,Jueves,Viernes,Sabado"
	S DS="Dom,Lun,Mar,Mie,Jue,Vie,Sab"
	S ML="Enero,Febrero,Marzo,Abril,Mayo,Junio,Julio,Agosto,Septiembre,Octubre,Noviembre,Diciembre"
	S MS="Ene,Feb,Mar,Abr,May,Jun,Jul,Ago,Sep,Oct,Nov,Dic"
	;
	F I="MS","ML","DS","DL" D
	. S ^DBCTL("SYS","*DVFM","PT","D",I)=@I
	. S ^DBCTL("SYS","*RFMT","PT","D",I)=@I
	;
	;-----------------------------------------------------------------------
	S DL="Nedele,Pondeli,Utery,Streda,Ctvrtek,Patek,Sobota"
	S DS="Ned,Pon,Ute,Str,Ctv,Pat,Sob"
	S ML="Leden,Unor,Brezen,Duben,Kveten,Cerven,Cervenec,Srpen,Zari,Rijen,Ilstopad,Prosinec"
	S MS="Led,Uno,Bre,Dub,Kve,Cer,Cerc,Srp,Zar,Rij,Iis,Pro"
	;
	F I="MS","ML","DS","DL" D
	. S ^DBCTL("SYS","*DVFM","CZ","D",I)=@I
	. S ^DBCTL("SYS","*RFMT","CZ","D",I)=@I
	;
	;-----------------------------------------------------------------------

	;
	; ---------- Set up format table for US
	;
	S X="" F  S X=$O(^DBCTL("SYS","DVFM",X)) Q:X=""  DO
	.	;
	.	S ^DBCTL("SYS","*DVFM","US",X)=^(X) Q:X'="D"
	.	F I="MS","ML","DS","DL" D
	..	S ^DBCTL("SYS","*DVFM","US",X,I)=^DBCTL("SYS","DVFM",X,I)
	.	;
	F I="$","C","D","E","L","N","T","U" DO
	.	;
	.	S ^DBCTL("SYS","*RFMT","US",I)=^DBCTL("SYS","RFMT",I)
	.	Q:I'="D"  F X="MS","ML","DS","DL" D
	..	S ^DBCTL("SYS","*RFMT","US",I,X)=^DBCTL("SYS","RFMT",I,X)
	;
	Q
INIT	;
	;;\RESFLG,0,No data item protection
	;;\RESFLG,1,Apply to modify or inquiry only
	;;\RESFLG,2,Apply to create/modify/inquiry"
	;;\DBSLIST,0,List Maintenance By User Id
	;;\DBSLIST,1,List Maintenance By User Class
	;;\DBSLIST,2,List Maintenance By Single System Id
	;;\RMFLG,0,No Restriction
	;;\RMFLG,1,Restriction - Batch Mode Only
	;;\RMFLG,2,Restriction - Batch Mode and On-Line
	;;\%HELP,0,Do not restrict HELP or SELECT access
	;;\%HELP,1,Restrict SELECT access only (table list)
	;;\%HELP,2,Restrict HELP access only (Documentaion)
	;;\%HELP,3,Restrict both SELECT and HELP access
	;;\%HELPCNT,0,Do Not Update Counter
	;;\%HELPCNT,1,Update SELECT counter
	;;\%HELPCNT,2,Update HELP counter
	;;\%HELPCNT,3,Update both HELP & SELECT counters
	;;\DVFM,T,Text|$E(glvn,1,len)||40|||||40
	;;\DVFM,N,Numeric|$S(glvn="":"",1:$J(glvn,0,dec))||12|||||12
	;;\DVFM,D,Date|$$DAT^%ZM(glvn)||10|||||10
	;;\DVFM,$,Currency|$S(glvn="":"",1:$J(glvn,0,dec))||12|||||12
	;;\DVFM,C,Clock Time|$$TIM^%ZM(glvn)||10|||||10
	;;\DVFM,F,Frequency|$E(glvn,1,len)||20|||||20
	;;\DVFM,L,Logical|$S(glvn:"Y",1:"N")||1|||||1
	;;\DVFM,U,Upper Case|$E(glvn,1,len)||40|||||40
	;;\DEVTYP,TRM,Terminal
	;;\DEVTYP,PTR,Printer
	;;\DEVTYP,SPL,Spooler
	;;\DEVTYP,MT,Magtape
	;;\DEVTYP,PNTQ,Print Queue
	;;\SUBTYP,CIE,CIE Printer
	;;\SUBTYP,LN03,Laser Printer
	;;\SUBTYP,VT220,VT220 Terminal
	;;\SUBTYP,VT100,VT100 Terminal
	;;\SUBTYP,OK82A,Okidata 82A Printer
	;;\RFMT,ZS,Zero suppress
	;;\RFMT,RK,Round thousand
	;;\RFMT,RH,Round hundred
	;;\RFMT,RM,Round million
	;;\RFMT,RT,Round ten
	;;\RFMT,RI,Round integer
	;;\RFMT,RDn,Round decimal (n)
	;;\RFMT,EM,Edit mask (RW only)
	;;\RFMT,IN,Numeric image format NNNN
	;;\RFMT,INS,IN format with sign NNNs
	;;\RFMT,I$,$ image format $$$CC
	;;\RFMT,I$S,$ image format with sign $$$Cs
	;;\RFMT,ID,Date image format MMDDYY|$$^%ZD(glvn,"MM")_$$^%ZD(glvn,"DD")_$$^%ZD(glvn,"YY")
	;;\RFMT,DAY,Date Of the week
	;;\RFMT,MON,Month
	;;\RFMT,YEAR,Year
	;;\RFMT,DD-MON-YY,Date
	;;\RFMT,DD-MON-YEAR,Date
	;;\RFMT,MM/DD/YEAR,Date
	;;\RFMT,ML,Month of the year (long name)
	;;\RFMT,MS,Month of the year (short name)
	;;\RFMT,DL,Date of the week (long name)
	;;\RFMT,DS,Date of the week (short name)
	;;\RFMT,NP,Negative (NNN)|$FN(glvn,"P",dec)||R
	;;\RFMT,NR,Negative  NNN-|$FN(glvn,"T",dec)||R
	;;\RFMT,NC,Negative  NNN CR|$S(V<0:$J(-glvn,0,+dec)_" CR",1:$J(glvn,0,+dec)_"   ")||R
	;;\RFMT,ND,Negative  NNN DR|$S(V<0:$J(-glvn,0,+dec)_" DR",1:$J(glvn,0,+dec)_"   ")||R
	;;\RFMT,N,Numeric|glvn|1|R
	;;\RFMT,$,Currency|glvn||R
	;;\RFMT,D,Date|$$DAT^%ZM(glvn)|1|R
	;;\RFMT,C,Clock time|$$TIM^%ZM(glvn)|1|R
	;;\RFMT,L,Logical|$S(glvn:"Y",1:"N")||*
	;;\RFMT,E,Edit comma|$FN(glvn,",",dec)||R
	;;\RFMT,T,Text|$E(glvn,1,len)
	;;\RFMT,U,Upper case|$E(glvn,1,len)
	;;\RFMT,JL,Left justified
	;;\RFMT,JR,Right justified
	;;\RFMT,JC,Center justified
	;;\RFMT,DRCR,DR/CR sign
	;;\QWIKFUN,SUM,Column Total
	;;\QWIKFUN,CNT,Record Count
	;;\DELIM,9,<TAB>
	;;\DELIM,35,#
	;;\DELIM,94,^
	;;\DELIM,44,,
	;;\DELIM,124,SCA Delimiter
	;;\DELIM,126,~
	;;
INIT2	;; ;
	;;\SGR,0,LN03,[0m
	;;\SGR,0,VT220,[0m
	;;\SGR,1,LN03,[1m
	;;\SGR,1,VT220,[1m
	;;\SGR,2,LN03,[1m
	;;\SGR,2,VT220,[7m
	;;\SGR,3,VT220,[4m
	;;\SGR,4,VT220,[5m
	;;\SGR,5,LN03,[1m
	;;\SGR,5,VT220,#6
	;;\SGR,6,VT220,#3
	;;\SGR,7,VT220,#4
	;;
INIT3	;; ;
	;;\*DVFM,PT,T,Text|$E(glvn,1,len)
	;;\*DVFM,PT,N,Numeric|$S(glvn="":"",1:$$NUM^%ZM(glvn,dec,%MSKN))||||.
	;;\*DVFM,PT,D,Date|$$DAT^%ZM(glvn,%MSKD)||||YY/MM/DD
	;;\*DVFM,PT,$,Currency|$S(glvn="":"",1:$$NUM^%ZM(glvn,dec,%MSKE))||||$
	;;\*DVFM,PT,C,Clock Time|$$TIM^%ZM(glvn,%MSKC)||||24:60
	;;\*DVFM,PT,F,Frequency|$E(glvn,1,len)
	;;\*DVFM,PT,L,Logical|$$LOG^%ZM(glvn,%MSKL)||||NSNYFT
	;;\*DVFM,PT,U,Upper Case|$E(glvn,1,len)
	;;\*RFMT,PT,N,Numeric|$$NUM^%ZM(glvn,dec,".")|1|R
	;;\*RFMT,PT,$,Currency|$$NUM^%ZM(glvn,dec,"$")||R
	;;\*RFMT,PT,D,Date|$$DAT^%ZM(glvn,"YY/MM/DD")|1|R
	;;\*RFMT,PT,C,Clock time|$$TIM^%ZM(glvn,"24:60")||L
	;;\*RFMT,PT,L,Logical|$$LOG^%ZM(glvn,"NS")||*
	;;\*RFMT,PT,E,Edit Format|$$NUM^%ZM(glvn,dec,"$.")||R
	;;\*RFMT,PT,T,Text|$E(glvn,1,len)
	;;\*RFMT,PT,U,Upper case|$E(glvn,1,len)
	;;
