 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSRWUTL ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSRWUTL ; 
 ;
 Q  ; Don't call from top
 ;
addcode(TABS,LINE,LINENO) ; 
 ;
 ; Change to private once that feature works in PSL
 ;
 N ADDLINE
 ;
 I TABS'<0 D
 .	; Remove any leading tabs
 .	I $E(LINE,1)=$char(9) F  S LINE=$E(LINE,2,1048575) Q:$E(LINE,1)'=$char(9) 
 .	; Remove leading and trailing spaces
 .	S LINE=$$vStrTrim(LINE,0," ")
 .	Q 
 ;
 ; Space comments to standard location on right of line
 I TABS>0 D
 .	N I N LEN
 .	N CMT
 .	;
 .	S CMT=$piece(LINE,$char(9)_"//",2,99)
 .	S LINE=$piece(LINE,$char(9)_"//",1)
 .	S LEN=(TABS*8)+$L(LINE)
 .	;
 .	F I=1:1:TABS S LINE=$char(9)_LINE
 .	I CMT'="" D
 ..		I LEN<55 S LINE=LINE_$char(9)_$char(9)_$char(9)_$char(9)_$char(9)_$char(9)_$char(9)_$char(9)_$char(9)_$E($char(9),1,((63-LEN)\8)-1)
 ..		S LINE=LINE_$char(9)_"//"_CMT
 ..		Q 
 .	Q 
 ;
 I $get(LINENO)="" S LINENO=$order(PSLCODE(""),-1)+1
 ;
 ; If LINE is quit, check to make sure not extra in order to avoid dead code warnings from compiler
 S ADDLINE=1
 I $$ISQUIT(LINE) D
 .	N DONE N I
 .	N CODE
 .	;
 .	S DONE=0
 .	F I=LINENO-1:-1 Q:'($D(PSLCODE(I))#2)  D  Q:DONE 
 ..		S CODE=$piece(PSLCODE(I),"//",1) ; Ignore comment
 ..		Q:($translate(CODE,$char(9)_$char(32))="")  ; Ignore blank lines
 ..		I $$ISQUIT(CODE) S ADDLINE=0 ; Preceeding quit
 ..		S DONE=1
 ..		Q 
 .	Q 
 ;
 I ADDLINE S PSLCODE(LINENO)=LINE
 Q 
 ;
ISQUIT(LINE) ; Private - determine if line is a quit command
 ;
 I '(($E(LINE,1,$L($char(9)))=$char(9))!($E(LINE,1)=" ")) Q 0 ; No if has tag
 S LINE=$piece(LINE,"//",1) ; Strip comment
 S LINE=$translate(LINE,$char(9)," ") ; Replace tabs with space
 S LINE=$$vStrTrim(LINE,0," ")
 S LINE=$piece(LINE," ",1) ; Command portion
 I $ZCONVERT(LINE,"L")'="quit" Q 0 ; No -- not just quit
 Q 1
 ;
addqts(INPUT) ; 
 ;
 I $$isNum^UCGM(INPUT) Q INPUT
 ;
 Q $S(INPUT'["""":""""_INPUT_"""",1:$$QADD^%ZS(INPUT,""""))
 ;
addtomap(ITEM,ddmap) ; 
 ;
 ; Change to private once that feature works in PSL
 ;
 N SEQ
 N COLUMN
 ;
 Q:ITEM="" 
 ;
 I $E(ITEM,1)="[" D
 .	N TABLE
 .	S TABLE=$piece($piece(ITEM,"[",2),"]",1)
 .	I TABLE["," S TABLE=$piece(TABLE,",",2) ; Drop library
 .	S COLUMN=$piece(ITEM,"]",2)
 .	S ITEM=TABLE_"."_COLUMN
 .	Q 
 ;
 S COLUMN=$piece(ITEM,".",2)
 Q:'(COLUMN?1.AN!(COLUMN?1"%"1.AN))  ; Invalid or dummy
 ;
 Q:($D(ddmap(ITEM))#2)  ; Already in map
 ;
 I '$get(ddmap(0)) S ddmap(0)=1
 S SEQ=ddmap(0)
 S ddmap(0)=SEQ+1
 S ddmap(SEQ)=ITEM
 S ddmap(ITEM)="vc"_SEQ ; Assign internal name
 ;
 Q 
 ;
addvars(LIST,VAR,RPTINFO,REMOVE) ; 
 ;
 ; Change to private once that feature works in PSL
 ;
 ; Load keywords, ignoring those that are $vars or complex, e.g., $P
 I ($order(RPTINFO("SYSKEYWORDS",""))="") D
 .	N ds,vos1,vos2,vos3 S ds=$$vOpen1()
 .	F  Q:'$$vFetch1()  D
 ..  N syskeywd,vop1 S vop1=ds,syskeywd=$$vRCgetRecord1Opt^RecordSTBLSYSKEYWD(vop1,1,"")
 ..		I $P(syskeywd,$C(124),1)?1"%".AN!($P(syskeywd,$C(124),1)?1.AN) S RPTINFO("SYSKEYWORDS",vop1)=$P(syskeywd,$C(124),1)
 ..  Q 
 . Q 
 ;
 ; If a keyword, use the variable name, not keyword
 I ($D(RPTINFO("SYSKEYWORDS",VAR))#2) S VAR=RPTINFO("SYSKEYWORDS",VAR)
 ;
 I $get(REMOVE) K RPTINFO(LIST,VAR)
 E  S RPTINFO(LIST,VAR)=""
 ;
 Q 
 ;
coldefs(dbtbl5h,RPTINFO) ; 
 N vpc
 ;
 ; Change to private once that feature works in PSL
 ;
 N LVL
 N COLUMNS
 ;
 ; No page header defined for this report
 ;
  N V1 S V1=vobj(dbtbl5h,-4) I '$$vDbEx1() Q ""
 ;
 ; Look for detail definition from the lowest key level
 ;
 S COLUMNS=""
 F LVL=10:-1:1 D  Q:COLUMNS'="" 
 .	N LN N LN1 N LN2 N SEQ
 .	N KEY N REGINFO N TC
 .	;
 .	S KEY=RPTINFO("SEQBY",LVL,"COL")
 .	Q:KEY="" 
 .	;
 .	Q:'$$validtcr(KEY,.TC)  ; Ignore if dummy key
 .	;
 .	; See if detail info defined for this level
 .	N dbtbl5dg,vop1,vop2,vop3 S vop1="SYSDEV",vop2=vobj(dbtbl5h,-4),vop3=KEY,dbtbl5dg=$$vRCgetRecord1Opt^RecordDBTBL5DGC("SYSDEV",vop2,KEY,0,"")
 .	 S dbtbl5dg=$G(^DBTBL(vop1,5,vop2,vop3,0))
 .	S REGINFO=$P(dbtbl5dg,$C(124),1)
 . S vpc=REGINFO=""!($piece(REGINFO,",",2)>3) Q:vpc 
 .	;
 .	; Detail region
 .	S LN1=$piece(REGINFO,",",1)+1 S LN2=$piece(REGINFO,",",2)+LN1
 .	S LN=0
 .	;
 .	N ds,vos1,vos2,vos3,vos4,vos5  N V2 S V2=vobj(dbtbl5h,-4) S ds=$$vOpen2()
 .	F  Q:'$$vFetch2()  D  Q:$L(COLUMNS,"\")=3!($L(COLUMNS)>400) 
 ..		N LINE N TAB
 ..		N COL N X
 ..		;
 ..  N dbtbl5d S dbtbl5d=$$vRCgetRecord1Opt^RecordDBTBL5D($P(ds,$C(9),1),$P(ds,$C(9),2),$P(ds,$C(9),3),$P(ds,$C(9),4),1,"")
 ..		S LINE=$P(dbtbl5d,$C(124),1)\1000
 ..		S TAB=$P(dbtbl5d,$C(124),1)#1000
 ..  S vpc=LINE<LN1!(LINE>LN2) Q:vpc 
 ..		;
 ..		S COL=$P(dbtbl5d,$C(124),6)
 ..  S vpc=$E(COL,1)="@" Q:vpc 
 ..		;
 ..		I COL'?1"["1E.E1","1E.E1"]"1E.E S X=$P(dbtbl5d,$C(124),7) ; Function
 ..		E  S X="["_$piece(COL,",",2)
 ..		I X["," S X=$piece(X,",",1)
 ..		I X["<<" S X="var"
 ..		S X=X_"#"_TAB_"#"_(+$P(dbtbl5d,$C(124),3))
 ..		;
 ..		I LN=0 S LN=LINE
 ..		E  I LINE>LN S COLUMNS=COLUMNS_"\" S LN=LINE
 ..		;
 ..		I COLUMNS'="",$E(COLUMNS,$L(COLUMNS))'="\" S COLUMNS=COLUMNS_","
 ..		S COLUMNS=COLUMNS_X
 ..  Q 
 . Q 
 ;
 Q COLUMNS
 ;
direfs(dbtbl5h,RPTINFO,ddmap) ; 
  S:'$D(vobj(dbtbl5h,11)) vobj(dbtbl5h,11)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),11)),1:"")
  S:'$D(vobj(dbtbl5h,12)) vobj(dbtbl5h,12)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),12)),1:"")
  S:'$D(vobj(dbtbl5h,13)) vobj(dbtbl5h,13)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),13)),1:"")
  S:'$D(vobj(dbtbl5h,14)) vobj(dbtbl5h,14)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),14)),1:"")
  S:'$D(vobj(dbtbl5h,15)) vobj(dbtbl5h,15)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),15)),1:"")
  S:'$D(vobj(dbtbl5h,16)) vobj(dbtbl5h,16)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),16)),1:"")
  S:'$D(vobj(dbtbl5h,17)) vobj(dbtbl5h,17)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),17)),1:"")
  S:'$D(vobj(dbtbl5h,18)) vobj(dbtbl5h,18)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),18)),1:"")
  S:'$D(vobj(dbtbl5h,19)) vobj(dbtbl5h,19)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),19)),1:"")
  S:'$D(vobj(dbtbl5h,20)) vobj(dbtbl5h,20)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),20)),1:"")
  S:'$D(vobj(dbtbl5h,21)) vobj(dbtbl5h,21)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),21)),1:"")
  S:'$D(vobj(dbtbl5h,22)) vobj(dbtbl5h,22)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),22)),1:"")
  S:'$D(vobj(dbtbl5h,23)) vobj(dbtbl5h,23)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),23)),1:"")
  S:'$D(vobj(dbtbl5h,24)) vobj(dbtbl5h,24)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),24)),1:"")
  S:'$D(vobj(dbtbl5h,25)) vobj(dbtbl5h,25)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),25)),1:"")
  S:'$D(vobj(dbtbl5h,26)) vobj(dbtbl5h,26)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),26)),1:"")
  S:'$D(vobj(dbtbl5h,27)) vobj(dbtbl5h,27)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),27)),1:"")
  S:'$D(vobj(dbtbl5h,28)) vobj(dbtbl5h,28)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),28)),1:"")
  S:'$D(vobj(dbtbl5h,29)) vobj(dbtbl5h,29)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),29)),1:"")
  S:'$D(vobj(dbtbl5h,30)) vobj(dbtbl5h,30)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),30)),1:"")
  S:'$D(vobj(dbtbl5h,0)) vobj(dbtbl5h,0)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),0)),1:"")
 ;
 ; Change to private once that feature works in PSL
 ;
 N I
 N FILES N X
 ;
 S ddmap=RPTINFO("TABLES") ; Access files
 Q:ddmap=""  ; All variables
 F I=1:1:$L(ddmap,",") D
 .	N X
 .	S X=$piece(ddmap,",",I)
 .	I ($D(^DBTBL("SYSDEV",1,X))) S FILES(X)=""
 .	Q 
 ;
 ; Step through each table and get possible column references
 F I=1:1:10 D
 .	N TC
 .	I $$validtcr(RPTINFO("SEQBY",I,"COL"),.TC) D addtomap(TC,.ddmap)
 .	Q 
 ;
 D addtomap($P(vobj(dbtbl5h,11),$C(124),1),.ddmap) D addtomap($P(vobj(dbtbl5h,11),$C(124),4),.ddmap)
 D addtomap($P(vobj(dbtbl5h,12),$C(124),1),.ddmap) D addtomap($P(vobj(dbtbl5h,12),$C(124),4),.ddmap)
 D addtomap($P(vobj(dbtbl5h,13),$C(124),1),.ddmap) D addtomap($P(vobj(dbtbl5h,13),$C(124),4),.ddmap)
 D addtomap($P(vobj(dbtbl5h,14),$C(124),1),.ddmap) D addtomap($P(vobj(dbtbl5h,14),$C(124),4),.ddmap)
 D addtomap($P(vobj(dbtbl5h,15),$C(124),1),.ddmap) D addtomap($P(vobj(dbtbl5h,15),$C(124),4),.ddmap)
 D addtomap($P(vobj(dbtbl5h,16),$C(124),1),.ddmap) D addtomap($P(vobj(dbtbl5h,16),$C(124),4),.ddmap)
 D addtomap($P(vobj(dbtbl5h,17),$C(124),1),.ddmap) D addtomap($P(vobj(dbtbl5h,17),$C(124),4),.ddmap)
 D addtomap($P(vobj(dbtbl5h,18),$C(124),1),.ddmap) D addtomap($P(vobj(dbtbl5h,18),$C(124),4),.ddmap)
 D addtomap($P(vobj(dbtbl5h,19),$C(124),1),.ddmap) D addtomap($P(vobj(dbtbl5h,19),$C(124),4),.ddmap)
 D addtomap($P(vobj(dbtbl5h,20),$C(124),1),.ddmap) D addtomap($P(vobj(dbtbl5h,20),$C(124),4),.ddmap)
 D addtomap($P(vobj(dbtbl5h,21),$C(124),1),.ddmap) D addtomap($P(vobj(dbtbl5h,21),$C(124),4),.ddmap)
 D addtomap($P(vobj(dbtbl5h,22),$C(124),1),.ddmap) D addtomap($P(vobj(dbtbl5h,22),$C(124),4),.ddmap)
 D addtomap($P(vobj(dbtbl5h,23),$C(124),1),.ddmap) D addtomap($P(vobj(dbtbl5h,23),$C(124),4),.ddmap)
 D addtomap($P(vobj(dbtbl5h,24),$C(124),1),.ddmap) D addtomap($P(vobj(dbtbl5h,24),$C(124),4),.ddmap)
 D addtomap($P(vobj(dbtbl5h,25),$C(124),1),.ddmap) D addtomap($P(vobj(dbtbl5h,25),$C(124),4),.ddmap)
 D addtomap($P(vobj(dbtbl5h,26),$C(124),1),.ddmap) D addtomap($P(vobj(dbtbl5h,26),$C(124),4),.ddmap)
 D addtomap($P(vobj(dbtbl5h,27),$C(124),1),.ddmap) D addtomap($P(vobj(dbtbl5h,27),$C(124),4),.ddmap)
 D addtomap($P(vobj(dbtbl5h,28),$C(124),1),.ddmap) D addtomap($P(vobj(dbtbl5h,28),$C(124),4),.ddmap)
 D addtomap($P(vobj(dbtbl5h,29),$C(124),1),.ddmap) D addtomap($P(vobj(dbtbl5h,29),$C(124),4),.ddmap)
 D addtomap($P(vobj(dbtbl5h,30),$C(124),1),.ddmap) D addtomap($P(vobj(dbtbl5h,30),$C(124),4),.ddmap)
 ;
 N ds1,vos1,vos2,vos3,vos4,vos5  N V1 S V1=vobj(dbtbl5h,-4) S ds1=$$vOpen3()
 F  Q:'$$vFetch3()  D
 .	N TC
 . N dbtbl5d S dbtbl5d=$$vRCgetRecord1Opt^RecordDBTBL5D($P(ds1,$C(9),1),$P(ds1,$C(9),2),$P(ds1,$C(9),3),$P(ds1,$C(9),4),1,"")
 .	I $$validtcr($P(dbtbl5d,$C(124),6),.TC) D addtomap(TC,.ddmap)
 .	D COMPLEX($P(dbtbl5d,$C(124),7),.FILES,.ddmap)
 . Q 
 ;
 N ds2,vos6,vos7,vos8,vos9,vos10,vos11  N V2 S V2=vobj(dbtbl5h,-4) S ds2=$$vOpen4()
 F  Q:'$$vFetch4()  D
 . N dbtbl5d1 S dbtbl5d1=$$vRCgetRecord1Opt^RecordDBTBL5D1($P(ds2,$C(9),1),$P(ds2,$C(9),2),$P(ds2,$C(9),3),$P(ds2,$C(9),4),$P(ds2,$C(9),5),1,"")
 .	D COMPLEX($P(dbtbl5d1,$C(12),1),.FILES,.ddmap)
 . Q 
 ;
 ; Additional variables
 F I=1:1 S X=$piece($P(vobj(dbtbl5h,0),$C(124),19),",",I) Q:X=""  D addtomap("<<"_X_">>",.ddmap)
 Q 
 ;
COMPLEX(DATA,FILES,ddmap) ; 
 ;
 N PTR N RPTR
 N TOK
 ;
 S DATA=$$TOKEN^%ZS(DATA,.TOK) ; Tokenize to eliminate "'s
 ;
 S (PTR,RPTR)=0
 F  D  Q:'PTR!'RPTR 
 .	N COLUMN N TABLE
 .	;
 .	I $E(DATA,2,3)="//" S RPTR=0 Q  ; Comments
 .	S PTR=$F(DATA,"[",PTR) ; Find next [
 .	Q:'PTR 
 .	S RPTR=$F(DATA,"]",PTR)
 .	Q:'RPTR 
 .	S TABLE=$E(DATA,PTR,RPTR-2)
 .	I TABLE["," S TABLE=$piece(TABLE,",",2) ; Drop library
 .	; Ignore invalid tables
 .	Q:TABLE="" 
 .	Q:'($D(FILES(TABLE))#2) 
 .	; Get column - if not valid, ignore it and move on
 .	S PTR=RPTR-1
 .	S COLUMN=$$ATOM^%ZS(DATA,.PTR,"[]+-*/\#_'=><\*(),!&:?")
 .	I '(COLUMN?1.AN!(COLUMN?1"%"1.AN)) S PTR=RPTR-1 Q 
 .	D addtomap("["_TABLE_"]"_COLUMN,.ddmap)
 .	Q 
 Q 
 ;
fmtstr(LEN,TYP,DEC) ; 
 ;
 N ER S ER=0
 N RM S RM=""
 ;
 N L
 N P3
 ;
 S L=LEN
 S P3=""
 ;
 D ^DBSEXEP
 ;
 I ER S P3="V format error "_RM
 ;
 Q P3
 ;
format(dbtbl5h,RPTINFO,ddmap) ; 
 ;
 ; Change to private once that feature works in PSL
 ;
 N LVL
 N KEY N N
 ;
 ; ORDER BY information
 F LVL=1:1:10 D  Q:KEY=""!ER 
 .	S KEY=RPTINFO("SEQBY",LVL,"COL")
 .	I KEY'="" D BLDFMT(LVL,KEY,.RPTINFO,.ddmap)
 .	Q 
 Q:ER 
 ;
 S RPTINFO("FMT",0)=RPTINFO("LASTLVL")
 ;
 D BLDFMT(90,"@PH",.RPTINFO,.ddmap) Q:ER 
 D BLDFMT(91,"@PT",.RPTINFO,.ddmap) Q:ER 
 D BLDFMT(92,"@RS",.RPTINFO,.ddmap) Q:ER 
 ;
 S N=""
 F LVL=1:1 S N=$order(RPTINFO("FMT",0,N)) Q:N=""  S RPTINFO("FMT",0,N)=LVL
 S RPTINFO("FMT",0)=RPTINFO("FMT",0)_"|"_(LVL-1)
 Q 
 ;
BLDFMT(LVL,KEY,RPTINFO,ddmap) ; 
 N vpc
 ;
 N BLNKSUPR N D N H N T
 N REGINFO
 ;
 N dbtbl5dg,vop1,vop2,vop3,vop4,vop5,vop6 S vop1="SYSDEV",vop2=RPTINFO("RID"),vop3=KEY,dbtbl5dg=$$vRCgetRecord1Opt^RecordDBTBL5DGC("SYSDEV",vop2,KEY,0,.vop4)
  S dbtbl5dg=$G(^DBTBL(vop1,5,vop2,vop3,0))
  S vop5=$G(^DBTBL(vop1,5,vop2,vop3,26))
  S vop6=$G(^DBTBL(vop1,5,vop2,vop3,27))
 S vpc='$G(vop4) Q:vpc  ; This level doesn't exist
 ;
 S REGINFO=$P(dbtbl5dg,$C(124),1)
 S H=$piece(REGINFO,",",1)+1 ; Header
 S D=H+1+$piece(REGINFO,",",2) ; Detail
 S T=H+D ; Trailer
 S RPTINFO("FMT",LVL)=REGINFO
 ;
 S H=H*1000 S D=D*1000 S T=T*1000
 ;
 ; Get any blank lines to suppress (may be line numbers or ranges, A-B)
 I $P(vop5,$C(124),1) D
 .	N I N J
 .	N X
 .	F I=1:1 S X=$piece($P(vop5,$C(124),1),",",I) Q:X=""  D
 ..		I X'["-" S BLNKSUPR(X)=""
 ..		E  F J=+X:1:$piece(X,"-",2) S BLNKSUPR(J)=""
 ..		Q 
 .	Q 
 ;
 ; Get each column element
 N ds1,vos1,vos2,vos3,vos4,vos5  N V1 S V1=RPTINFO("RID") S ds1=$$vOpen5()
 F  Q:'$$vFetch5()  D  Q:ER 
 .	N LN N LNCOL N PPSEQ N PRESEQ N SIZE
 .	N BLANK N FORMAT N ORIGTAG N PP N PPID N PRE N PREV N SEC N TAG N VAR
 . N dbtbl5d,vop7,vop8,vop9 S vop9=$P(ds1,$C(9),2),vop8=$P(ds1,$C(9),3),vop7=$P(ds1,$C(9),4),dbtbl5d=$$vRCgetRecord1Opt^RecordDBTBL5D($P(ds1,$C(9),1),vop9,vop8,vop7,1,"")
 .	;
 .	S (PPSEQ,PRESEQ)=""
 .	;
 .	S LNCOL=$P(dbtbl5d,$C(124),1) S LN=LNCOL\1000
 .	S SIZE=$P(dbtbl5d,$C(124),3)
 .	S FORMAT=$P(dbtbl5d,$C(124),4) I FORMAT="" S FORMAT="T"
 .	S TAG=$P(dbtbl5d,$C(124),6)
 .	S VAR=$P(dbtbl5d,$C(124),7)
 .	S PRE=$P(dbtbl5d,$C(124),9)
 .	S PP=$P(dbtbl5d,$C(124),8)
 .	;
 .	S BLANK=""
 .	I ($D(BLNKSUPR(LN))#2) S BLANK=1 ; Suppress blank
 .	I $P(vop6,$C(124),1)=LN S BLANK=2 ; Suppress line feed
 .	S PPID=TAG
 .	I $E(PPID,1)="@" S PPID=VAR ; line indicator
 .	;
 .	; Convert <<$J(...>> to TEXT format type for report page numbers
 .	I VAR?1"<<$J(".E S FORMAT="T"
 .	;
 .	; Group sections
 .	I LNCOL'>H S SEC="H"
 .	E  I LNCOL'>D D
 ..		S SEC="D"
 ..		S LNCOL=LNCOL-H ; Line number offset
 ..		Q 
 .	E  D
 ..		S SEC="T"
 ..		S LNCOL=LNCOL-D
 ..		Q:TAG'?1"["1E.E1"]"1E.E  ; Not [lib,fid]di syntax
 ..		S VAR="<<"_$piece(TAG,"]",2)_">>" ; Convert to <<key>>
 ..		S TAG="@"
 ..		Q 
 .	;
 .	; Field pre/post-processors
 . I PRE S PRESEQ=$$GETCPPS(vop9,vop8,vop7,1,PPID,.RPTINFO,.ddmap) Q:ER 
 . I PP S PPSEQ=$$GETCPPS(vop9,vop8,vop7,21,PPID,.RPTINFO,.ddmap) Q:ER 
 .	;
 .	S ORIGTAG=TAG
 .	I $E(TAG,1)'="@" D
 ..		;
 ..		I TAG?1"["1E.E1"]"1E.E D
 ...			N ZD N ZF N ZFMT
 ...			S ZF=$piece($piece(TAG,",",2),"]",1)
 ...			S ZD=$piece(TAG,"]",2)
 ...			S ZFMT=$$TYP^DBSDD(ZF_"."_ZD)
 ...			I "UTF"[ZFMT,ZFMT'=FORMAT,"T,JR"'[FORMAT D
 ....				WRITE !,TAG," in section ",KEY," - Format Changed From (",FORMAT,") To (JR)",!
 ....				S FORMAT="JR" ; Convert to text
 ....				Q 
 ...			Q 
 ..		Q 
 .	;
 .	E  D
 ..		;
 ..		; Patch common usage in headers
 ..		I VAR="<<$G(CONAM)>>" S VAR="<<CONAM.get()>>"
 ..		;
 ..		; If single variable and doesn't contain FORMAT,SIZE, add them to allow formatting
 ..		I ($E(VAR,1,2)="<<"),($E(VAR,$L(VAR)-2+1,1048575)=">>"),'$$vStrLike(VAR,"%,"_SIZE_">>",""),(VAR'="<<#>>") S VAR=$piece(VAR,">>",1)_","_FORMAT_","_SIZE_">>"
 ..		;
 ..		S TAG=$$VAR(VAR,SEC,.RPTINFO,.ddmap)
 ..		I TAG?1"~"1A.AN D  ; User defined variable
 ...			I SEC="H",LNCOL<3000 Q  ; Skip report header
 ...			Q:PRE!PP  ; User code will init
 ...			Q:$E(TAG,1,3)="~vc"  ; Access key
 ...			Q 
 ..		Q 
 .	;
 .	S RPTINFO("FMT",LVL,SEC,LNCOL)=FORMAT_"|"_SIZE_"|"_TAG_"|"_PRESEQ_"|"_PPSEQ_"|"_BLANK
 .	;
 .	I $E(ORIGTAG,1)="@" D
 ..		N X
 ..		; Pack text string
 ..		S X=$order(RPTINFO("FMT",LVL,SEC,LNCOL),-1) ; First item
 ..		Q:X="" 
 ..		Q:X\1000'=LN  ; Different line
 ..		S PREV=RPTINFO("FMT",LVL,SEC,X) ; Last object
 ..		Q:$piece(PREV,"|",1)'="T"  ; Non-text
 ..		Q:"[@~"[$E($piece(PREV,"|",3),1)  ; DI or FUN
 ..		Q:$piece(PREV,"|",4)!$piece(PREV,"|",5)  ; Pre or Post processor
 ..		I FORMAT="T","[@~"'[$E(TAG,1),'PRESEQ,'PPSEQ D
 ...			N Z1
 ...			S Z1=LNCOL-X-$piece(PREV,"|",2)
 ...			S $piece(PREV,"|",3)=$piece(PREV,"|",3)_$J("",Z1)_TAG
 ...			S $piece(PREV,"|",2)=$L($piece(PREV,"|",3))
 ...			S RPTINFO("FMT",LVL,SEC,X)=PREV
 ...			K RPTINFO("FMT",LVL,SEC,LNCOL)
 ...			Q 
 ..		Q 
 . Q 
 Q 
 ;
GETCPPS(RID,GRP,ITMSEQ,SEQ,PPID,RPTINFO,ddmap) ; 
 N vpc
 ;
 N CNT N END N N N START N VPNUM
 N DESC N PPIN N PPOUT
 ;
 S START=SEQ-.001 S END=SEQ+20
 S CNT=1
 ;
 N rs,vos1,vos2,vos3,vos4,vos5,vos6,vos7,vos8,vos9 S rs=$$vOpen6()
 S vpc='$G(vos1) Q:vpc 0
 ;
 F  Q:'$$vFetch6()  D
 .	N DATA
 . S DATA=rs
 .	S PPIN(CNT)=DATA
 .	S CNT=CNT+1
 .	I ($E($ZCONVERT(DATA,"U"),$L(DATA)-11+1,$L(DATA))="TYPE PUBLIC") D
 ..		N I
 ..		;
 ..		S DATA=$piece($piece(DATA,"ublic ",2,999)," ",2)
 ..		I DATA'="" F I=1:1:$L(DATA,",") S RPTINFO("V0TYPE",$piece(DATA,",",I))=""
 ..		Q 
 .	Q 
 ;
 ; Translate, if necessary, pre/post-processor code
 D PPCODE^DBSRW(.PPIN,.PPOUT,0,.ddmap,.RPTINFO)
 I ER Q ""
 ;
 I SEQ=1 S DESC="Column pre-processor"
 E  S DESC="Column post-processor"
 I $E(PPID,1,2)="<<" D
 .	S PPID=$TR(PPID,"<>")
 .	S DESC=DESC_" - Variable: "_$piece(PPID,",",1)
 .	Q 
 E  S DESC=DESC_" - "_PPID
 ;
 S VPNUM=$order(RPTINFO("VPSUBS",""),-1)+1
 S RPTINFO("VPSUBS",VPNUM,0)=$char(9)_"// "_DESC
 S CNT=2 S N=""
 F  S N=$order(PPOUT(N)) Q:N=""  D
 .	S RPTINFO("VPSUBS",VPNUM,CNT)=PPOUT(N)
 .	S CNT=CNT+1
 .	Q 
 ;
 Q VPNUM
 ;
VAR(VAR,SEC,RPTINFO,ddmap) ; 
 ;
 I VAR?1"@"3A.E D  Q VAR ; @FUN(...)
 .	Q:$E(VAR,1,4)="@CNT" 
 .	I $E(VAR,1,4)="@CHR" D  ; @CHR(v,cnt)
 ..		N I N LEN
 ..		N C N X
 ..		;
 ..		S X=$piece($piece(VAR,"(",2),")",1)
 ..		S C=$piece(X,",",1)
 ..		S LEN=+$piece(X,",",2)
 ..		I 'LEN S LEN=RPTINFO("RSIZE")
 ..		S VAR=""
 ..		F I=1:1:LEN S VAR=VAR_C
 ..		Q 
 .	;
 .	; @FUN(di)   @FUN([fid]di)   @FUN(<<var>>)
 .	E  D
 ..		N I
 ..		N C N P N X
 ..		;
 ..		F I=2:1 S P=$piece(VAR,"@",I) Q:P=""  D
 ...			S X=$piece($piece(P,"(",2),")",1)
 ...			S C=$piece(X,",",1)
 ...			; Convert @FUN(di) to @FUN([fid]di)
 ...			I C?1A.AN D
 ....				N C1
 ....				WRITE !,VAR,"  --> "
 ....				S C1=$piece(ddmap,",",1) ; Primary file
 ....				D addtomap(C1_"."_C,.ddmap)
 ....				S C="["_C1_"]"_C
 ....				WRITE C,!
 ....				Q 
 ...			S RPTINFO("FMT",0,C,$E(P,1,3))=$piece(P,",",3,9)
 ...			Q 
 ..		I VAR["," S VAR=$piece(VAR,",",1,2)_")"
 ..		Q 
 .	Q 
 ;
 I VAR'["<<" Q VAR ; Constant with vc1,vc2,...
 ;
 Q "~"_$$VARS(VAR,SEC,.RPTINFO,.ddmap)
 ;
VARS(VAR,SEC,RPTINFO,ddmap) ; 
 ;
 N STR S STR=""
 ;
 Q:VAR'[">>" """"_VAR_"""" ; Pure string
 ;
 F  D  Q:VAR="" 
 .	N P1 N X
 .	;
 .	S P1=$piece(VAR,"<<",1)
 .	S X=$piece($piece(VAR,"<<",2),">>",1)
 .	I P1'="" S STR=STR_""""_P1_""""_"_" ; Text portion
 .	I X'="" D
 ..		; <<var,fmt,len>>
 ..		I X'["$E",X'["$G",X'["$P",X'["$L",X'["$$",X'["$S",X'["$J",$L(X,",")>2 S X=$$VARFMT(X,SEC,.RPTINFO,.ddmap)
 ..		E  S X=$$OTHFMT(X)
 ..		I X?1"["1E.E1"]"1E.E S X=$$VARFMT(X,SEC,.RPTINFO,.ddmap) ; [fid]di
 ..		I $E(X,1)="&" S X=$E(X,2,99)
 ..		I X?1A.AN S X=$$TOVNAME(X,SEC,.RPTINFO,.ddmap)
 ..		I X?1A.AN1"(".E1")" S X=$$TOVNAME(X,SEC,.RPTINFO,.ddmap)
 ..		S STR=STR_X_"_" ; "text"_var
 ..		Q 
 .	S VAR=$piece(VAR,">>",2,99) ; Continue process
 .	Q 
 ;
 Q $E(STR,1,$L(STR)-1) ; Remove trailing _
 ;
VARFMT(INVAR,SEC,RPTINFO,ddmap) ; 
 ;
 N CNT N DEC N LEN
 N CODE N TYP N VAR
 ;
 S VAR=$piece(INVAR,",",1)
 I VAR["(" S VAR=$piece(INVAR,")",1)_")"
 S VAR=$$TOVNAME(VAR,SEC,.RPTINFO,.ddmap) ; Map to vc or vo
 S INVAR=$piece(INVAR,VAR,2,99)
 S CNT=$L(INVAR,",")
 S LEN=$piece(INVAR,",",CNT)
 S TYP=$piece(INVAR,",",2,CNT-1)
 S DEC=0
 ;
 I $E(VAR,1)="[",LEN="",TYP="" D
 .	S TYP=$$TYP^DBSDD(VAR) ; Format Type
 .	S DEC=+$$DEC^DBSDD(VAR) ; Decimal Precision
 .	S LEN=+$$LEN^DBSDD(VAR) ; Field Length
 .	I "$N"[TYP S LEN=0 ; Pack data
 .	I TYP="N",DEC S TYP="RD"_DEC ; RDn
 .	Q 
 ;
 I TYP["$",'DEC S DEC=2 ; Currency
 I TYP["RD" S DEC=+$piece(TYP,"RD",2) ; RDn
 S CODE=$$fmtstr(LEN,TYP,DEC)
 Q $$replace(CODE,"V",VAR)
 ;
OTHFMT(VAR) ; Deal with <<var,fmt,len>> elements that aren't basic
 ;
 N isDone
 N CNT N DEC N I N LASTUSED N LEN
 N CODE N P N TYP
 ;
 I VAR'?.e1","1.N Q VAR ; No ,fmt,len
 ;
 S CNT=$L(VAR,",")
 S LEN=$piece(VAR,",",CNT) Q:LEN'?1N.N  ; Not length
 ;
 ; Find type - may be more than one element
 S TYP=""
 S isDone=0
 F I=CNT-1:-1:2 D  Q:isDone 
 .	;
 .	S P=$piece(VAR,",",I)
 .	I (P="$")!(P?1.U)!(P?1"RD".N) D
 ..		S TYP=P_","_TYP
 ..		S LASTUSED=I
 ..		Q 
 .	E  S isDone=1
 .	Q 
 S TYP=$E(TYP,1,$L(TYP)-1)
 S VAR=$piece(VAR,",",1,LASTUSED-1)
 ;
 I (TYP["$") S DEC=2
 E  I TYP["RD" S DEC=+$piece(TYP,"RD",2)
 E  S DEC=0
 ;
 S CODE=$$fmtstr(LEN,TYP,DEC)
 Q $$replace(CODE,"V",VAR)
 ;
TOVNAME(VARNAME,SEC,RPTINFO,ddmap) ; 
 ;
 N I
 N FILE N X N V
 ;
 S V=VARNAME
 ;
 ; Deal with possibility of variable format including T.C of [T]C
 I $$validtcr(VARNAME,.X) S V=$$map(X,.ddmap,1)
 ;
 E  F I=1:1 S FILE=$piece(ddmap,",",I) Q:FILE=""  D
 .	N X
 .	S X=FILE_"."_VARNAME
 .	; Save variable name for newlist, unless already in it by default
 .	I '($D(ddmap(X))#2) D
 ..		I ((VARNAME?1A.AN)!(VARNAME?1"%".AN)) D
 ...			Q:((","_"CONAM,RID,RN"_",")[(","_VARNAME_",")) 
 ...			S RPTINFO("V0TYPE",VARNAME)=""
 ...			Q 
 ..		; Otherwise, more complex "variable", e.g, (ABC+XYZ)
 ..		E  D
 ...			;
 ...			N ptr
 ...			N tok N VAR N VARSTR
 ...			;
 ...			S VARSTR=$$TOKEN^%ZS(VARNAME,.tok)
 ...			S ptr=0
 ...			F  D  Q:(ptr=0) 
 ....				;
 ....				S VAR=$$ATOM^%ZS(VARSTR,.ptr,"()+-/*#\=_.,!&@",tok)
 ....				I ((VARNAME?1A.AN)!(VARNAME?1"%".AN)) D
 .....					Q:((","_"CONAM,RID,RN"_",")[(","_VAR_",")) 
 .....					S RPTINFO("V0TYPE",VAR)=""
 .....					Q 
 ....				Q 
 ...			Q 
 ..		Q 
 .	E  S V=ddmap(X)
 .	Q 
 ;
 Q V
 ;
replace(STRING,OLD,NEW) ; Replace OLD with NEW in STRING
 ;
 N PTR S PTR=0
 ;
 F  S PTR=$F(STRING,OLD,PTR) Q:PTR=0  S STRING=$E(STRING,1,PTR-$L(OLD)-1)_NEW_$E(STRING,PTR,1048575) S PTR=PTR+$L(NEW)-$L(OLD)
 Q STRING
 ;
isdi(X) ; Return 1 if X contains a valid [fid]dinam
 ;
 ; Change to private once that feature works in PSL
 ;
 N ISDI S ISDI=0
 ;
 I X?.E1"["1A.AN1"]"1A.E S ISDI=1 ; [fid]dinam
 E  I X?.E1"["1A.AN1"]%"1A.E S ISDI=1 ; [fid]%dinam
 E  I X?.E1"["1A.AN1","1A.AN1"]"1A.E S ISDI=1 ; [lib,fid]dinam
 E  I X?.E1"["1A.AN1","1A.AN1"]%"1A.E S ISDI=1 ; [lib,fid]%dinam
 ;
 Q ISDI
 ;
map(INPUT,ddmap,REPLACE,varList) ; 
 ;
 ; Change to private once that feature works in PSL
 ;
 N PTR S PTR=0
 N ATOM N BLDTC N DELS N RETURN N STRING N TCREF N TOK
 ;
 S varList=""
 ;
 S DELS="[]+-*/\#_'=><\*(),!&:?" S (RETURN,BLDTC)=""
 S STRING=$$TOKEN^%ZS(INPUT,.TOK) ; Tokenize to eliminate "'s
 ;
 F  D  Q:PTR=0 
 .	S ATOM=$$ATOM^%ZS(STRING,.PTR,DELS,TOK,1)
 .	;
 .	; Handle pattern match operations
 .	I ATOM="?" D  Q 
 ..		N ORIGPTR
 ..		N PATTERN N Z
 ..		;
 ..		S ORIGPTR=PTR
 ..		F PTR=PTR+1:1 Q:PTR>$L(STRING)  S Z=$E(STRING,PTR) Q:'(Z?1N!(Z=".")!(Z?1A)!($ascii(Z)=0)) 
 ..		S PTR=PTR-1
 ..		S PATTERN=$E(STRING,ORIGPTR,PTR)
 ..		S RETURN=RETURN_PATTERN
 ..		Q 
 .	;
 .	; May be [LIB,TAB]COL syntax
 .	I ATOM="[" D  Q 
 ..		I BLDTC'="" S RETURN=RETURN_BLDTC ; Old wasn't []DI syntax, start new
 ..		S BLDTC=ATOM ; Restart
 ..		Q 
 .	;
 .	I ATOM="]",BLDTC'="" S BLDTC=BLDTC_ATOM Q 
 .	;
 .	; May be library, table, or column -- add to BLDTC and check
 .	I ATOM?1A.AN!(ATOM?1"%"1.AN),BLDTC'="" D  Q 
 ..		S BLDTC=BLDTC_ATOM
 ..		Q:BLDTC'["]"  ; No ] yet - not done
 ..		; Should be done - see if valid
 ..		I $$validtcr(BLDTC,.TCREF) D
 ...			D addtomap(TCREF,.ddmap)
 ...			S RETURN=RETURN_ddmap(TCREF)
 ...			S varList=$S(((","_varList_",")[(","_ddmap(TCREF)_",")):varList,1:$S((varList=""):ddmap(TCREF),1:varList_","_ddmap(TCREF)))
 ...			Q 
 ..		E  S RETURN=RETURN_BLDTC
 ..		S BLDTC=""
 ..		Q 
 .	;
 .	I ATOM=",",BLDTC'="" D  Q 
 ..		I BLDTC?1"["1A.AN!(BLDTC?1"[%"1.AN) S BLDTC=BLDTC_ATOM
 ..		E  S RETURN=RETURN_BLDTC_ATOM
 ..		Q 
 .	;
 .	; If get here with BLDTC, then it's not a potential reference
 .	I BLDTC'="" S RETURN=RETURN_BLDTC S BLDTC=""
 .	;
 .	I DELS[ATOM S RETURN=RETURN_ATOM Q 
 .	I $ascii(ATOM)=0 S RETURN=RETURN_$$UNTOK^%ZS(ATOM,TOK) Q 
 .	I $E(ATOM,1)="$" S RETURN=RETURN_ATOM Q 
 .	I $$isNum^UCGM(ATOM) S RETURN=RETURN_ATOM Q 
 .	;
 .	; Shoud be TABLE.COLUMN reference at this point.  If not leave as is.
 .	I '$$validtcr(ATOM,.TCREF) S RETURN=RETURN_ATOM Q 
 .	;
 .	; Add to ddmap
 .	D addtomap(TCREF,.ddmap)
 .	S RETURN=RETURN_ddmap(TCREF)
 .	S varList=$S(((","_varList_",")[(","_ddmap(TCREF)_",")):varList,1:$S((varList=""):ddmap(TCREF),1:varList_","_ddmap(TCREF)))
 .	Q 
 ;
 I $get(REPLACE) S RETURN=$$UNTOK^%ZS(RETURN,TOK)
 E  S RETURN=INPUT
 ;
 Q RETURN
 ;
newlist(OPT,RPTINFO,ddmap,MOREVARS,EXCLVARS) ; 
 ;
 ; Change to private once that feature works in PSL
 ;
 N I
 N LIST N N N NEWLIST
 ;
 I OPT="ALL"!(OPT="DDMAP")!(OPT="V0") D
 .	F I=1:1:ddmap(0)-1 D
 ..		N TC
 ..		S TC=ddmap(I)
 ..		S LIST(ddmap(TC))=""
 ..		Q 
 .	Q 
 ;
 ; Get variable names for V0 section
 I OPT="ALL"!(OPT="UD")!(OPT="V0") D
 .	S N=""
 .	F  S N=$order(RPTINFO("V0TYPE",N)) Q:N=""  D
 ..		I OPT'="V0" S LIST(N)=""
 ..		E  I '($D(RPTINFO("V0EXCLUDE",N))#2),'($D(RPTINFO("INCOMING",N))#2) S LIST(N)=""
 ..		Q 
 .	Q 
 ;
 ; Get protection variable names
 I OPT="ALL"!(OPT="V0") D
 .	S N=""
 .	F  S N=$order(RPTINFO("VPTYPE",N)) Q:N=""  S LIST(N)=""
 .	Q 
 ;
 ; Variables from report pre-processor (before query)
 I OPT="ALL"!(OPT="MAINVARS") D
 .	S N=""
 .	F  S N=$order(RPTINFO("MAINVARS",N)) Q:N=""  D
 ..		Q:N="IO"  ; RW variable, don't include
 ..		S LIST(N)=""
 ..		Q 
 .	Q 
 ;
 ; Incoming variables from report pre-processor (before query)
 I OPT="ALL"!(OPT="INCOMING") D
 .	S N=""
 .	F  S N=$order(RPTINFO("INCOMING",N)) Q:N=""  S LIST(N)=""
 .	Q 
 ;
 ; If more variables to add to the list (MOREVARS), add them
 I '($get(MOREVARS)="") F I=1:1:$L(MOREVARS,",") D
 .	S N=$piece(MOREVARS,",",I)
 .	I '(N="") S LIST(N)=""
 .	Q 
 ;
 ; If variables to exclude (e.g., previously typed), drop them
 I '($get(EXCLVARS)="") F I=1:1:$L(EXCLVARS,",") D
 .	S N=$piece(EXCLVARS,",",I)
 .	I '(N="") K LIST(N)
 .	Q 
 ;
 S (N,NEWLIST)=""
 F  S N=$order(LIST(N)) Q:N=""  S NEWLIST=NEWLIST_N_","
 ;
 Q $E(NEWLIST,1,$L(NEWLIST)-1)
 ;
rwopt(OPT,VALUE) ; 
 ;
 ; This code is called at run time if the .RWOPT. option is used
 ;
 I OPT="LINKRPT" D
 .	I $get(vcrt) S PN=-1 D ^DBSRWBR(2) ; End of report message
 .	Q:$get(VALUE)=""  ; No report name
 .	;
 .	N RID N VWROPT
 .	S VRWOPT("NOOPEN")=1 ; Suppress Open
 .	S VRWOPT("NOCLOSE")=1 ; Suppress Close
 .	S RID=VALUE
 .	D RPT^URID ; Run report
 .	Q 
 ;
 E  I OPT="BLKLINE" S (V,VL)="" ; Current line to blank
 E  I OPT="BLKFLD" S V="" ; Current field to blank
 E  I $get(VALUE) S VRWOPT(OPT)=VALUE
 E  S VRWOPT(OPT)=1
 ;
 Q 
 ;
RPTSEQ(RID,GRP) ; 
 ;
 N RPTSEQ
 ;
 I GRP="@PH" Q 1
 ;
 N dbtbl5h,vop1,vop2,vop3,vop4,vop5,vop6,vop7,vop8,vop9,vop10,vop11,vop12 S vop1="SYSDEV",vop2=RID,dbtbl5h=$$vRCgetRecord0Opt^RecordDBTBL5H("SYSDEV",RID,0,"")
  S vop3=$G(^DBTBL(vop1,5,vop2,1))
  S vop4=$G(^DBTBL(vop1,5,vop2,2))
  S vop5=$G(^DBTBL(vop1,5,vop2,3))
  S vop6=$G(^DBTBL(vop1,5,vop2,4))
  S vop7=$G(^DBTBL(vop1,5,vop2,5))
  S vop8=$G(^DBTBL(vop1,5,vop2,6))
  S vop9=$G(^DBTBL(vop1,5,vop2,7))
  S vop10=$G(^DBTBL(vop1,5,vop2,8))
  S vop11=$G(^DBTBL(vop1,5,vop2,9))
  S vop12=$G(^DBTBL(vop1,5,vop2,10))
 ;
 I GRP=$P(vop3,$C(124),1) Q 2
 I GRP=$P(vop4,$C(124),1) Q 3
 I GRP=$P(vop5,$C(124),1) Q 4
 I GRP=$P(vop6,$C(124),1) Q 5
 I GRP=$P(vop7,$C(124),1) Q 6
 I GRP=$P(vop8,$C(124),1) Q 7
 I GRP=$P(vop9,$C(124),1) Q 8
 I GRP=$P(vop10,$C(124),1) Q 9
 I GRP=$P(vop11,$C(124),1) Q 10
 I GRP=$P(vop12,$C(124),1) Q 11
 ;
 S RPTSEQ=99
 I GRP="@RS" D
 .	I $P(vop12,$C(124),1)'="" S RPTSEQ=12
 .	E  I $P(vop11,$C(124),1)'="" S RPTSEQ=11
 .	E  I $P(vop10,$C(124),1)'="" S RPTSEQ=10
 .	E  I $P(vop9,$C(124),1)'="" S RPTSEQ=9
 .	E  I $P(vop8,$C(124),1)'="" S RPTSEQ=8
 .	E  I $P(vop7,$C(124),1)'="" S RPTSEQ=7
 .	E  I $P(vop6,$C(124),1)'="" S RPTSEQ=6
 .	E  I $P(vop5,$C(124),1)'="" S RPTSEQ=5
 .	E  I $P(vop4,$C(124),1)'="" S RPTSEQ=4
 .	E  S RPTSEQ=3
 .	Q 
 ;
 Q RPTSEQ
 ;
SORTFLG(dbtbl5h) ; 
  S:'$D(vobj(dbtbl5h,1)) vobj(dbtbl5h,1)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),1)),1:"")
  S:'$D(vobj(dbtbl5h,2)) vobj(dbtbl5h,2)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),2)),1:"")
  S:'$D(vobj(dbtbl5h,3)) vobj(dbtbl5h,3)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),3)),1:"")
  S:'$D(vobj(dbtbl5h,4)) vobj(dbtbl5h,4)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),4)),1:"")
  S:'$D(vobj(dbtbl5h,5)) vobj(dbtbl5h,5)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),5)),1:"")
  S:'$D(vobj(dbtbl5h,6)) vobj(dbtbl5h,6)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),6)),1:"")
  S:'$D(vobj(dbtbl5h,7)) vobj(dbtbl5h,7)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),7)),1:"")
  S:'$D(vobj(dbtbl5h,8)) vobj(dbtbl5h,8)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),8)),1:"")
  S:'$D(vobj(dbtbl5h,9)) vobj(dbtbl5h,9)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),9)),1:"")
  S:'$D(vobj(dbtbl5h,10)) vobj(dbtbl5h,10)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),10)),1:"")
  S:'$D(vobj(dbtbl5h,0)) vobj(dbtbl5h,0)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),0)),1:"")
 ;
 N I N SORTFLG
 N FILEKEYS N PFID N RPTSEQ N X
 ;
 ; Get report sequence
 S RPTSEQ=$P(vobj(dbtbl5h,1),$C(124),1)_"|"_$P(vobj(dbtbl5h,2),$C(124),1)_"|"_$P(vobj(dbtbl5h,3),$C(124),1)_"|"_$P(vobj(dbtbl5h,4),$C(124),1)_"|"
 S RPTSEQ=RPTSEQ_$P(vobj(dbtbl5h,5),$C(124),1)_"|"_$P(vobj(dbtbl5h,6),$C(124),1)_"|"_$P(vobj(dbtbl5h,7),$C(124),1)_"|"
 S RPTSEQ=RPTSEQ_$P(vobj(dbtbl5h,8),$C(124),1)_"|"_$P(vobj(dbtbl5h,9),$C(124),1)_"|"_$P(vobj(dbtbl5h,10),$C(124),1)
 S RPTSEQ=$$RTCHR^%ZFUNC(RPTSEQ,$char(124))
 ;
 ; Get primary file sequence
 S PFID=$P(vobj(dbtbl5h,0),$C(124),1)
 S PFID=$piece(PFID,",",1) ; Primary file
 ;
 N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=PFID,dbtbl1=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",PFID,0,"")
  S vop3=$G(^DBTBL(vop1,1,vop2,16))
 ;
 S FILEKEYS=""
 S X=$P(vop3,$C(124),1)
 F I=1:1:$L(X,",") S FILEKEYS=FILEKEYS_"[SYSDEV,"_PFID_"]"_$piece(X,",",I)_"|"
 S FILEKEYS=$$RTCHR^%ZFUNC(FILEKEYS,$char(124))
 ;
 S SORTFLG=0 ; Same order, i.e., no sort
 ;
 ; Remove dummy keys from table then compare
 I RPTSEQ'=FILEKEYS D
 .	N TC N Z
 .	S Z=""
 .	F I=1:1:$L(FILEKEYS,"|") D
 ..		Q:'$$validtcr($piece(FILEKEYS,"|",I),.TC) 
 ..		S Z=Z_"[SYSDEV,"_$piece(TC,".",1)_"]"_$piece(TC,".",2)_"|"
 ..		Q 
 .	S Z=$$RTCHR^%ZFUNC(Z,$char(124))
 .	I RPTSEQ'=Z S SORTFLG=1 ; Difference order, i.e., sort
 .	Q 
 ;
 Q SORTFLG
 ;
stat(LVL) ; 
 ;
 N N S N=""
 ;
 ; @TOT
 F  S N=$order(VT(LVL-1,N)) Q:N=""  D
 .	S VT(LVL-1,N,1)=VT(LVL-1,N,1)+VT(LVL,N,1)
 .	S VT(LVL,N,1)=""
 .	Q 
 ;
 ; @MAX
 F  S N=$order(VT(LVL-1,N)) Q:N=""  D
 .	I VT(LVL-1,N,2)=""!(VT(LVL-1,N,2)<VT(LVL,N,2)) S VT(LVL-1,N,2)=VT(LVL,N,2)
 .	S VT(LVL,N,2)=""
 .	Q 
 ;
 ; @MIN
 F  S N=$order(VT(LVL-1,N)) Q:N=""  D
 .	I VT(LVL-1,N,3)=""!(VT(LVL-1,N,3)>VT(LVL,N,3)) S VT(LVL-1,N,3)=VT(LVL,N,3)
 .	S VT(LVL,N,3)=""
 .	Q 
 ;
 ; @CNT
 S VT(LVL-1)=VT(LVL-1)+VT(LVL)
 S VT(LVL)=0
 Q 
 ;
validtcr(TCREF,RETURN) ; 
 ;
 ; Change to private once that feature works in PSL
 ;
 N OK S OK=0
 N COLUMN N TABLE
 ;
 I $E(TCREF,1)="[" D
 .	S TABLE=$piece($piece(TCREF,"[",2),"]",1)
 .	S COLUMN=$piece(TCREF,"]",2,99)
 .	I TABLE["," S TABLE=$piece(TABLE,",",2)
 .	Q 
 E  D
 .	S TABLE=$piece(TCREF,".",1)
 .	S COLUMN=$piece(TCREF,".",2,99)
 .	Q 
 ;
 I TABLE?1A.AN&(COLUMN?1A.AN!(COLUMN?1"%"1A.AN)) D
 .	S RETURN=TABLE_"."_COLUMN
 .	S OK=1
 .	Q 
 ;
 Q OK
 ;
vstats(SEQ,SRCVAL,TRGTVAL,STATINFO,VSTATS) ; 
 ;
 N FORMAT N INC1 N INC2 N SOURCE N TARGET N X
 ;
 S SOURCE=$piece(STATINFO,"|",1)
 S FORMAT=$piece(STATINFO,"|",2)
 S TARGET=$piece(STATINFO,"|",3)
 S INC1=$piece(STATINFO,"|",4)
 S INC2=$piece(STATINFO,"|",5)
 I FORMAT="T",'INC1 S X=SRCVAL
 E  I TARGET'=SOURCE S X=SRCVAL
 E  I INC2="" S X=SRCVAL\INC1
 E  D
 .	N I
 .	N Y
 .	;
 .	F I=4:1 S Y=$piece(STATINFO,"|",I) Q:Y=""!(SRCVAL<Y) 
 .	S X=I-3
 .	Q 
 ;
 I X="" S X=" "
 ;
 I '(($D(VSTATS(SEQ))#2)!'($order(VSTATS(SEQ,""))="")) S VSTATS(SEQ)="0|0|"_SRCVAL_"|"_SRCVAL_"|"_STATINFO
 E  I FORMAT'="T" D
 .	I SRCVAL<$piece(VSTATS(SEQ),"|",3) S $piece(VSTATS(SEQ),"|",3)=SRCVAL ; Low
 .	I SRCVAL>$piece(VSTATS(SEQ),"|",4) S $piece(VSTATS(SEQ),"|",4)=SRCVAL ; High
 .	Q 
 ;
 S $piece(VSTATS(SEQ),"|",1)=$piece(VSTATS(SEQ),"|",1)+1 ; Count
 S $piece(VSTATS(SEQ),"|",2)=$piece(VSTATS(SEQ),"|",2)+TRGTVAL ; Total
 ;
 I '($D(VSTATS(SEQ,X))#2) S VSTATS(SEQ,X)=""
 S $piece(VSTATS(SEQ,X),"|",1)=$piece(VSTATS(SEQ,X),"|",1)+1
 S $piece(VSTATS(SEQ,X),"|",2)=$piece(VSTATS(SEQ,X),"|",2)+TRGTVAL
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61288^63893^Dan Russell^34682" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vStrTrim(object,p1,p2) ; String.trim
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I p1'<0 S object=$$RTCHR^%ZFUNC(object,p2)
 I p1'>0 F  Q:$E(object,1)'=p2  S object=$E(object,2,1048575)
 Q object
 ; ----------------
 ;  #OPTION ResultClass 1
vStrLike(object,p1,p2) ; String.isLike
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I (p1="") Q (object="")
 I p2 S object=$ZCONVERT(object,"U") S p1=$ZCONVERT(p1,"U")
 I ($E(p1,1)="%"),($E(p1,$L(p1))="%") Q object[$E(p1,2,$L(p1)-1)
 I ($E(p1,1)="%") Q ($E(object,$L(object)-$L($E(p1,2,1048575))+1,1048575)=$E(p1,2,1048575))
 I ($E(p1,$L(p1))="%") Q ($E(object,1,$L($E(p1,1,$L(p1)-1)))=$E(p1,1,$L(p1)-1))
 Q object=p1
 ;
vDbEx1() ; min(1): DISTINCT LIBS,RID,GRP,ITMSEQ FROM DBTBL5D WHERE LIBS='SYSDEV' AND RID=:V1 AND GRP='@PH' AND ITMSEQ='101'
 ;
 N vsql1
 S vsql1=$$BYTECHAR^SQLUTL(254)
 ;
 I '(101>100) Q 0
 I '($D(^DBTBL("SYSDEV",5,V1,"@PH",101))#2) Q 0
 Q 1
 ;
vOpen1() ; KEYWORD FROM STBLSYSKEYWD
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
 I vos1=0 S ds="" Q 0
 ;
 S ds=$S(vos3=vos2:"",1:vos3)
 ;
 Q 1
 ;
vOpen2() ; LIBS,RID,GRP,ITMSEQ FROM DBTBL5D WHERE LIBS='SYSDEV' AND RID=:V2 AND GRP=:KEY
 ;
 ;
 S vos1=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos1=0 Q
vL2a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V2) I vos3="" G vL2a0
 S vos4=$G(KEY) I vos4="" G vL2a0
 S vos5=100
vL2a5 S vos5=$O(^DBTBL("SYSDEV",5,vos3,vos4,vos5),1) I vos5="" G vL2a0
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos1=1 D vL2a5
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds="" Q 0
 ;
 S ds="SYSDEV"_$C(9)_vos3_$C(9)_vos4_$C(9)_$S(vos5=vos2:"",1:vos5)
 ;
 Q 1
 ;
vOpen3() ; LIBS,RID,GRP,ITMSEQ FROM DBTBL5D WHERE LIBS='SYSDEV' AND RID=:V1
 ;
 ;
 S vos1=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos1=0 Q
vL3a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL3a0
 S vos4=""
vL3a4 S vos4=$O(^DBTBL("SYSDEV",5,vos3,vos4),1) I vos4="" G vL3a0
 S vos5=100
vL3a6 S vos5=$O(^DBTBL("SYSDEV",5,vos3,vos4,vos5),1) I vos5="" G vL3a4
 Q
 ;
vFetch3() ;
 ;
 ;
 I vos1=1 D vL3a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds1="" Q 0
 ;
 S ds1="SYSDEV"_$C(9)_vos3_$C(9)_$S(vos4=vos2:"",1:vos4)_$C(9)_$S(vos5=vos2:"",1:vos5)
 ;
 Q 1
 ;
vOpen4() ; LIBS,RID,GRP,ITMSEQ,SEQ FROM DBTBL5D1 WHERE LIBS='SYSDEV' AND RID=:V2
 ;
 ;
 S vos6=2
 D vL4a1
 Q ""
 ;
vL4a0 S vos6=0 Q
vL4a1 S vos7=$$BYTECHAR^SQLUTL(254)
 S vos8=$G(V2) I vos8="" G vL4a0
 S vos9=""
vL4a4 S vos9=$O(^DBTBL("SYSDEV",5,vos8,vos9),1) I vos9="" G vL4a0
 S vos10=100
vL4a6 S vos10=$O(^DBTBL("SYSDEV",5,vos8,vos9,vos10),1) I vos10="" G vL4a4
 S vos11=""
vL4a8 S vos11=$O(^DBTBL("SYSDEV",5,vos8,vos9,vos10,vos11),1) I vos11="" G vL4a6
 Q
 ;
vFetch4() ;
 ;
 ;
 I vos6=1 D vL4a8
 I vos6=2 S vos6=1
 ;
 I vos6=0 S ds2="" Q 0
 ;
 S ds2="SYSDEV"_$C(9)_vos8_$C(9)_$S(vos9=vos7:"",1:vos9)_$C(9)_$S(vos10=vos7:"",1:vos10)_$C(9)_$S(vos11=vos7:"",1:vos11)
 ;
 Q 1
 ;
vOpen5() ; LIBS,RID,GRP,ITMSEQ FROM DBTBL5D WHERE LIBS='SYSDEV' AND RID=:V1 AND GRP=:KEY
 ;
 ;
 S vos1=2
 D vL5a1
 Q ""
 ;
vL5a0 S vos1=0 Q
vL5a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL5a0
 S vos4=$G(KEY) I vos4="" G vL5a0
 S vos5=100
vL5a5 S vos5=$O(^DBTBL("SYSDEV",5,vos3,vos4,vos5),1) I vos5="" G vL5a0
 Q
 ;
vFetch5() ;
 ;
 ;
 I vos1=1 D vL5a5
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds1="" Q 0
 ;
 S ds1="SYSDEV"_$C(9)_vos3_$C(9)_vos4_$C(9)_$S(vos5=vos2:"",1:vos5)
 ;
 Q 1
 ;
vOpen6() ; DATA FROM DBTBL5D1 WHERE LIBS='SYSDEV' AND RID=:RID AND GRP=:GRP AND ITMSEQ=:ITMSEQ AND SEQ>:START AND SEQ<:END ORDER BY SEQ ASC
 ;
 ;
 S vos1=2
 D vL6a1
 Q ""
 ;
vL6a0 S vos1=0 Q
vL6a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(RID) I vos3="" G vL6a0
 S vos4=$G(GRP) I vos4="" G vL6a0
 S vos5=$G(ITMSEQ)
 S vos6=$G(START)
 S vos6=+vos6
 S vos7=$G(END)
 S vos7=+vos7
 I '(vos5>100) G vL6a0
 S vos8=vos6
vL6a11 S vos8=$O(^DBTBL("SYSDEV",5,vos3,vos4,vos5,vos8),1) I vos8=""!(vos8'<vos7) G vL6a0
 Q
 ;
vFetch6() ;
 ;
 ;
 I vos1=1 D vL6a11
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos9=$G(^DBTBL("SYSDEV",5,vos3,vos4,vos5,vos8))
 S rs=$P(vos9,$C(12),1)
 ;
 Q 1
