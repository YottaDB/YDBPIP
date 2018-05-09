 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSDDMAP ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
 ;
 Q 
 ;
 ;I18N=QUIT
 ;
REPORT(OPT) ; Summary only (true) or full report (false)
 ;
 N CNT
 N DI N FID N IO N IOTYP N LINE N LOW N MAPSTART N NODE N SEG N TBL
 ;
 S OPT=$get(OPT)
 S LINE=""
 S $piece(LINE,"-",79)=""
 ;
 D ^SCAIO
 ;
 Q:($get(IO)="") 
 ;
 N file S file=$$vClVobj($ST,"IO")
 ;
 S $P(vobj(file,1),"|",1)=""
 ;
 I ($get(IOTYP)="RMS") D
 .	;
 .	S $P(vobj(file,1),"|",2)=$$PARSE^%ZFUNC(IO,"DIRECTORY")
 .	S $P(vobj(file,1),"|",1)=$$PARSE^%ZFUNC(IO,"NAME")_$$PARSE^%ZFUNC(IO,"TYPE")
 .	S $P(vobj(file,1),"|",3)="WRITE/NEWV"
 .	S $P(vobj(file,1),"|",4)=5
 .	;
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 .	;
 .	D open^UCIO(file,$T(+0),"REPORT","file")
 .	Q 
 ;
 D INIT
 F FID="CUVAR","DEP","LN","PRODCTL","PRODDFTL","PRODDFTD" D PRINT(file)
 ;
 D writeIt(file,"")
 D writeIt(file,LINE)
 D writeIt(file,"")
 ;
 D close^UCIO(file)
 ;
 K vobj(+$G(file)) Q 
 ;
PRINT(file) ; Output device
 ;
 ; Print information about the split tables
 ;
 N CNT N LOW
 N DI N NODE N SEG
 ;
 D writeIt(file,"")
 D writeIt(file,LINE)
 D writeIt(file,"")
 D writeIt(file,"Table Name: "_FID)
 ;
 I 'OPT D
 .	;
 .	D writeIt(file,"")
 .	D writeIt(file,"")
 .	D writeIt(file,"Column Name         New Table Name      Node Number")
 .	D writeIt(file,"")
 .	D writeIt(file,"")
 .	Q 
 ;
 D MAP(FID,.TBL)
 ;
 S DI=""
 F  S DI=$order(TBL(FID,DI)) Q:(DI="")  D
 .	S SEG=TBL(FID,DI)
 .	I 'OPT D
 ..		;
 ..		N col S col=$$vRCgetRecord0Opt^RecordDBTBL1D("SYSDEV",FID,DI,0,"")
 ..		;
 ..		D writeIt(file,"")
 ..		D writeIt(file,DI_$J("",20-$L(DI))_SEG_$J("",20-$L(SEG))_$P(col,$C(124),1))
 ..  Q 
 .	;
 .	S CNT(SEG)=$get(CNT(SEG))+1
 .	Q 
 ;
 D writeIt(file,"")
 D writeIt(file,"")
 S LOW=1
 ;
 S NODE=""
 F  S NODE=$order(MAPSTART(FID,NODE)) Q:(NODE="")  D
 .	;
 .	D writeIt(file,"")
 .	D writeIt(file,"NODE "_LOW_"-"_NODE_" = Table "_MAPSTART(FID,NODE))
 .	S LOW=NODE+1
 .	Q 
 S SEG=""
 ;
 D writeIt(file,"")
 D writeIt(file,"")
 ;
 F  S SEG=$order(CNT(SEG)) Q:(SEG="")  D
 .	;
 .	D writeIt(file,"")
 .	D writeIt(file,"Table "_SEG_" = "_CNT(SEG))
 .	Q 
 ;
 D writeIt(file,"")
 ;
 Q 
 ;
MAP(FID,MAP) ; Mapping definition
 ;
 N DI N MAPSTART N NODE N V
 ;
 D INIT
 I '$D(MAPSTART(FID)) Q 
 K MAP(FID)
 ;
 N ditem,vos1,vos2,vos3,vos4,vos5 S ditem=$$vOpen1()
 I '$G(vos1) Q 
 F  Q:'$$vFetch1()  D
 . S DI=$P(ditem,$C(9),1)
 . S NODE=$P(ditem,$C(9),2)
 .	;
 .	; Dummy key
 .	I ($E(DI,1)?1n) Q 
 .	I ($E(DI,1)="""") Q 
 .	;
 .	; Access key
 .	I NODE["*" S MAP(FID,DI)=1 Q 
 .	I ($E(NODE,1)?1A) S NODE=$ascii(NODE,1)
 .	;
 .	; Computed item
 .	I (NODE="") D  Q 
 ..		I FID'="LN" S MAP(FID,DI)="C1" Q 
 ..		;
 ..		; From A-J
 ..		I $E(DI,1)']]"K" S MAP(FID,DI)="C1" Q 
 ..		;
 ..		; From K-Z
 ..		S MAP(FID,DI)="C2" Q 
 ..		Q 
 .	;
 .	; Store ACN in table 1
 .	I FID="DEP"!(FID="LN") I NODE=99 S MAP(FID,DI)=1 Q 
 .	;
 .	; Get sequence
 .	S V=$order(MAPSTART(FID,NODE-1))
 .	S MAP(FID,DI)=MAPSTART(FID,V)
 .	Q 
 ;
 Q 
 ;
INIT ; By tables to split, define the nodes at which a split occurs by building the array MAPSTART
 ;
 S MAPSTART("DEP",55)=1
 S MAPSTART("DEP",103)=2
 S MAPSTART("DEP",425)=3
 S MAPSTART("DEP",441)=4
 S MAPSTART("DEP",600)=5
 S MAPSTART("DEP",700)=6
 S MAPSTART("DEP",800)=7
 S MAPSTART("DEP",899)=8
 S MAPSTART("DEP",999)=9
 S MAPSTART("DEP",2000)=97
 S MAPSTART("DEP",5000)=98
 S MAPSTART("DEP",99999)=99
 ;
 S MAPSTART("PRODDFTD",100)=1
 S MAPSTART("PRODDFTD",425)=2
 S MAPSTART("PRODDFTD",441)=3
 S MAPSTART("PRODDFTD",600)=5
 S MAPSTART("PRODDFTD",700)=6
 S MAPSTART("PRODDFTD",800)=7
 S MAPSTART("PRODDFTD",899)=8
 S MAPSTART("PRODDFTD",999)=9
 S MAPSTART("PRODDFTD",2000)=97
 S MAPSTART("PRODDFTD",5000)=98
 S MAPSTART("PRODDFTD",99999)=99
 ;
 S MAPSTART("LN",55)=1
 S MAPSTART("LN",62)=2
 S MAPSTART("LN",100)=3
 S MAPSTART("LN",441)=4
 S MAPSTART("LN",600)=5
 S MAPSTART("LN",700)=6
 S MAPSTART("LN",800)=7
 S MAPSTART("LN",900)=8
 S MAPSTART("LN",999)=9
 S MAPSTART("LN",2000)=97
 S MAPSTART("LN",5000)=98
 S MAPSTART("LN",99999)=99
 ;
 S MAPSTART("PRODDFTL",100)=2
 S MAPSTART("PRODDFTL",441)=3
 S MAPSTART("PRODDFTL",600)=5
 S MAPSTART("PRODDFTL",700)=6
 S MAPSTART("PRODDFTL",800)=7
 S MAPSTART("PRODDFTL",900)=8
 S MAPSTART("PRODDFTL",999)=9
 S MAPSTART("PRODDFTL",2000)=97
 S MAPSTART("PRODDFTL",5000)=98
 S MAPSTART("PRODDFTL",99999)=99
 ;
 S MAPSTART("PRODCTL",30)=1
 S MAPSTART("PRODCTL",99999)=2
 ;
 S MAPSTART("CUVAR",69)=1
 S MAPSTART("CUVAR",10000)=2
 ;
 Q 
 ;
XFR(FILENAME) ; Table name
 ;
 N DI N INDEX N MAP N QUOTE N STNAME N SORTFID
 ;
 I (FILENAME="") Q 
 ;
 D MAP(FILENAME,.MAP)
 I '$D(MAP(FILENAME)) Q 
 D RESORT
 S QUOTE=$char(34)
 ;
 ; Build header for the map table
 WRITE "T,",$P($H,",",1),",",$P($H,",",2),",",QUOTE,"WTBLMAP",QUOTE,",1,N,G"
 WRITE !,"F,WTNAME"
 WRITE !,"S,T"
 WRITE !,"D,D,",QUOTE,FILENAME,QUOTE,!
 ;
 ; Build information about the individual Columns
 S INDEX=""
 F  S INDEX=$order(SORTFID(INDEX)) Q:(INDEX="")  D
 .	S STNAME="W_"_FILENAME_"_"_INDEX
 .	WRITE "T,",$P($H,",",1),",",$P($H,",",2),",",QUOTE,"WTBLMAP",QUOTE,",2,N,G",!
 .	WRITE "F,WTNAME,COLNAME,STNAME",!
 .	WRITE "S,T,T,T",!
 .	S DI=""
 .	F  S DI=$order(SORTFID(INDEX,DI)) Q:(DI="")  D
 ..		;
 ..		; Duplicate keys
 ..		I INDEX'=1,(DI="CID"!(DI="TYPE")) Q 
 ..		WRITE "D,I,",QUOTE,FILENAME,QUOTE,",",QUOTE,DI,QUOTE,",",QUOTE,STNAME,QUOTE,!
 ..		Q 
 .	Q 
 Q 
 ;
RESORT ; Sort the array MAP into an array better suited to further processing
 ;
 N JI
 N FID N X N Y
 ;
 K SORTFID
 S (X,Y)=""
 ;
 N table,vop1,vop2,vop3 S vop1="SYSDEV",vop2=FILENAME,table=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",FILENAME,0,"")
  S vop3=$G(^DBTBL(vop1,1,vop2,16))
 F  S X=$order(MAP(X)) Q:(X="")  D
 .	;
 .	F  S Y=$order(MAP(X,Y)) Q:(Y="")  D
 ..		S FID=MAP(X,Y)
 ..		I FID'="" S SORTFID(FID,Y)=""
 ..		Q 
 .	Q 
 ;
 F  S X=$order(SORTFID(X)) Q:(X="")  D
 .	S SORTFID(X)=FILENAME
 .	F JI=1:1 Q:($piece($P(vop3,$C(124),1),",",JI)="")  S SORTFID(X,$piece($P(vop3,$C(124),1),",",JI))=""
 .	Q 
 ;
 Q 
 ;
writeIt(file,data) ; Data to write
 ;
 ; Write either to file or to screen
 ;
 I ($P(vobj(file,1),"|",1)="") WRITE data,!
 E  D write^UCIO(file,data)
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61006^63993^Dan Russell^9242" ; Signature - LTD^TIME^USER^SIZE
 ;
vClVobj(vSt,vCls) ; Create a new object
 ;
 N vOid
 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)=vCls_$C(9)_vSt
 Q vOid
 ;
vOpen1() ; DI,NOD FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:FID
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(FID) I vos3="" G vL1a0
 S vos4=""
vL1a4 S vos4=$O(^DBTBL("SYSDEV",1,vos3,9,vos4),1) I vos4="" G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ditem="" Q 0
 ;
 S vos5=$G(^DBTBL("SYSDEV",1,vos3,9,vos4))
 S ditem=$S(vos4=vos2:"",1:vos4)_$C(9)_$P(vos5,"|",1)
 ;
 Q 1
 ;
vCatch1 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 D close^UCIO(file)
 ;
 I '($P(error,",",3)["IOEOF") S $ZE=error,$EC=",U1001,"
 D ZX^UCGMR(voxMrk) Q 
