DBSDDMAP	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSDDMAP ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	Q 
	;I18N=QUIT
	;
REPORT(OPT)	; Public; Report wide to split table mapping
	;
	N CNT,DI,IO,LINE,LOW,MAPSTART,NODE,SEG,TBL
	S OPT=$get(OPT)
	S LINE=""
	S $piece(LINE,"-",79)=""
	D ^SCAIO
	USE IO
	D INIT
	F FID="CUVAR","DEP","LN","PRODCTL","PRODDFTL","PRODDFTD" D PRINT
	WRITE !,LINE,!
	CLOSE IO
	Q 
	;
PRINT	; Private;   Print information about the split tables
	;
	N CNT,DI,LOW,NODE,SEG
	;
	WRITE !,LINE,!,"Table Name: ",FID
	I 'OPT WRITE !!,"Column Name",?20,"New Table Name",?40,"Node Number",!!
	D MAP(FID,.TBL)
	;
	S DI=""
	F  S DI=$order(TBL(FID,DI)) Q:DI=""  D
	.	S SEG=TBL(FID,DI)
	.	I 'OPT D
	..		WRITE !,DI,?20,SEG
	..		N col S col=$$vDb3("SYSDEV",FID,DI)
	..		WRITE ?40,$P(col,$C(124),1)
	..		Q 
	.	S CNT(SEG)=$get(CNT(SEG))+1
	.	Q 
	;
	WRITE !!
	S LOW=1
	;
	S NODE=""
	F  S NODE=$order(MAPSTART(FID,NODE)) Q:NODE=""  D
	.	I $X>50 WRITE !
	.	WRITE "NODE ",LOW,"-",NODE," = Table ",MAPSTART(FID,NODE),"  " S LOW=NODE+1
	.	Q 
	S SEG=""
	WRITE !!
	F  S SEG=$order(CNT(SEG)) Q:SEG=""  D
	.	I $X>60 WRITE !
	.	WRITE "Table ",SEG," = ",CNT(SEG),"   "
	.	Q 
	WRITE !
	Q 
	;
MAP(FID,MAP)	; Public; Produce a map of the columns and the split file in which they are mapped
	;
	N DI,MAPSTART,NODE,V
	;
	D INIT
	I '$D(MAPSTART(FID)) Q 
	K MAP(FID)
	;
	N ditem,vos1,vos2,vos3,vos4 S ditem=$$vOpen1()
	I '$G(vos1) Q 
	F  Q:'($$vFetch1())  D
	.	S DI=$P(ditem,$C(9),1)
	.	S NODE=$P(ditem,$C(9),2)
	.	;
	.	; Dummy key
	.	I $E(DI,1)?1n Q 
	.	I $E(DI,1)="""" Q 
	.	;
	.	; Access key
	.	I NODE["*" S MAP(FID,DI)=1 Q 
	.	I $E(NODE,1)?1A S NODE=$ascii(($E(NODE,1)))
	.	;
	.	; Computed item
	.	I NODE="" D  Q 
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
INIT	;Private, By tables to split, define the nodes at which a split occurs by building the array MAPSTART
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
	Q 
	;
XFR(FILENAME)	; Public; Build a entry for transfer to PFW client of the table WTBLMAP
	;
	N DI,INDEX,QUOTE,STNAME,SORTFID
	I FILENAME="" Q 
	K MAP
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
	F  S INDEX=$order(SORTFID(INDEX)) Q:INDEX=""  D
	.	S STNAME="W_"_FILENAME_"_"_INDEX
	.	WRITE "T,",$P($H,",",1),",",$P($H,",",2),",",QUOTE,"WTBLMAP",QUOTE,",2,N,G",!
	.	WRITE "F,WTNAME,COLNAME,STNAME",!
	.	WRITE "S,T,T,T",!
	.	S DI=""
	.	F  S DI=$order(SORTFID(INDEX,DI)) Q:DI=""  D
	..		;
	..		; Duplicate keys
	..		I INDEX'=1,(DI="CID"!(DI="TYPE")) Q 
	..		WRITE "D,I,",QUOTE,FILENAME,QUOTE,",",QUOTE,DI,QUOTE,",",QUOTE,STNAME,QUOTE,!
	..		Q 
	.	Q 
	Q 
	;
RESORT	; Public; Sort the array MAP into an array better suited to further processing
	;
	N FID,JI,X,Y
	;
	K SORTFID
	S (X,Y)=""
	;
	N table,vop1,vop2,vop3 S vop1="SYSDEV",vop2=FILENAME,table=$$vDb4("SYSDEV",FILENAME)
	 S vop3=$G(^DBTBL(vop1,1,vop2,16))
	F  S X=$order(MAP(X)) Q:X=""!($D(voerr))  D
	.	F  S Y=$order(MAP(X,Y)) Q:Y=""  D
	..		S FID=MAP(X,Y)
	..		I FID'="" S SORTFID(FID,Y)=""
	..		Q 
	.	Q 
	;
	F  S X=$order(SORTFID(X)) Q:X=""  D
	.	S SORTFID(X)=FILENAME
	.	F JI=1:1 Q:$piece(($P(vop3,$C(124),1)),",",JI)=""  S SORTFID(X,$piece(($P(vop3,$C(124),1)),",",JI))=""
	.	Q 
	Q 
	;
vSIG()	;
	Q "59514^39350^Mark Spier^7442" ; Signature - LTD^TIME^USER^SIZE
	;
vDb3(v1,v2,v3)	;	voXN = Db.getRecord(DBTBL1D,,0)
	;
	N col
	S col=$G(^DBTBL(v1,1,v2,9,v3))
	I col="",'$D(^DBTBL(v1,1,v2,9,v3))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1D" X $ZT
	Q col
	;
vDb4(v1,v2)	;	voXN = Db.getRecord(DBTBL1,,0)
	;
	N table
	S table=$G(^DBTBL(v1,1,v2))
	I table="",'$D(^DBTBL(v1,1,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1" X $ZT
	Q table
	;
vOpen1()	;	DI,NOD FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:FID
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(FID) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^DBTBL("SYSDEV",1,vos2,9,vos3),1) I vos3="" G vL1a0
	Q
	;
vFetch1()	;
	;
	I vos1=1 D vL1a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos4=$G(^DBTBL("SYSDEV",1,vos2,9,vos3))
	S ditem=$S(vos3=$C(254):"",1:vos3)_$C(9)_$P(vos4,"|",1)
	;
	Q 1
