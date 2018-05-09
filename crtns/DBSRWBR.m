 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSRWBR ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSRWBR(RPOPT,HDROPT,BROPT) ; 
 ;
 N curBTM N lnoff N NOTNWHDR
 ;
 ; Output report to RMS file or PRINTER
 I RPOPT=0 D HEADER Q 
 ;
 ; Reset screen for first report page
 Q:'($D(PN)#2) 
 ;
 S curBTM=$$BTM^%TRMVT S lnoff=0
 I $get(BROPT) D
 .	N PAGE
 .	; Get highest page number
 .	S PAGE=$$LASTPAGE
 .	D TMPSET(0,0,0,PAGE)
 .	Q 
 ;
 I PN=1 D
 .	S PN=PN+1
 .	I RPOPT=1 WRITE $$CLEAR^%TRMVT
 .	Q 
 ;
 I PN=-1 D
 .	Q:'$$TMPGET(1,0,0) 
 .	I vcrt=2!(vcrt=4) S vcrt=3 S NOTNWHDR=0
 .	WRITE !
 .	D WAIT
 .	Q 
 ;
 E  D
 .	; Skip one line before prompt for option
 .	I $get(vHDG),'$get(HDROPT) D
 ..		WRITE !
 ..		D WAIT
 ..		Q 
 .	;
 .	; QWIK report format
 .	E  I RPOPT=1 D
 ..		D TMPDEL
 ..		D PNTHDR
 ..		Q 
 .	;
 .	; RW report format (PAGE BREAK OPTION)
 .	E  D
 ..		D SETHDR
 ..		D LOCKHDR(vHDG)
 ..		Q 
 .	Q 
 ;
 Q 
 ;
HEADER ; Private - Display header
 ;
 WRITE $char(12),!
 S $Y=1
 I PN'<0 D
 .	N N S N=""
 .	F  S N=$order(vHDG(N)) Q:N=""  D HEADER1(vHDG(N))
 .	S PN=PN+1
 .	Q 
 Q 
 ;
HEADER1(DATA) ; Private - Display header with page number
 ;
 N X
 ;
 ; Page ~p1
 S X=$$^MSG(2125)
 S X=$E(X,1,$L(X)-1) ; Report page number
 I DATA[X WRITE $piece(DATA,X,1)_X_":"_$J(PN,4),!
 E  WRITE DATA,!
 Q 
 ;
PNTHDR ; Private - Print out screen page header
 ;
 N CNT N N
 ;
 ; Clear screen and switch to 132 column mode
 I IORM=132 WRITE $$SCR132^%TRMVT
 E  WRITE $$SCR80^%TRMVT
 ;
 S $X=0 S $Y=0
 D TERM^%ZUSE($I,"WIDTH="_(IORM+1)_"/ECHO")
 S N=""
 F CNT=1:1 S N=$order(vHDG(N)) Q:N=""  WRITE vHDG(N),!
 S vHDG=CNT
 D LOCKHDR(CNT)
 Q 
 ;
SETHDR ; Private - Copy current RW page header information into vHDG() array
 N vTp
 ;
 N J N K N LINENO N PGNO
 N DATA
 ;
 K vHDG
 ;
 N rs,vos1,vos2,vos3,vos4,vos5  N V1 S V1=$J S rs=$$vOpen1()
 I '$G(vos1) S (J,PGNO)=1
 E  I $$vFetch1() D
 . S PGNO=$P(rs,$C(9),1)
 . S J=+$P(rs,$C(9),2)
 .	Q 
 ;
 N rs2,vos6,vos7,vos8,vos9,vos10,vos11  N V2 S V2=$J S rs2=$$vOpen2()
 ;
 S K=1
 F  Q:'$$vFetch2()  D
 . S vHDG(K)=$P(rs2,$C(9),2)
 .	S K=K+1
 .	S vlc=vlc-1
 . S LINENO=$P(rs2,$C(9),1)
 .  K ^TMPRPTBR($J,LINENO)
 .	Q 
 S vHDG=K_"|"_PGNO
 ;
 N tmprptbr,vop1,vop2,vop3,vop4,vop5 S vop4=$J,vop3=0,vop2=PGNO,vop1=0,tmprptbr=$$vRCgetRecord1Opt^RecordTMPRPTBR($J,0,PGNO,0,0,.vop5)
 S DATA=$P(tmprptbr,$C(12),1)
 S $piece(DATA,"|",2)=PGNO
  S $P(tmprptbr,$C(12),1)=DATA
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^TMPRPTBR(vop4,vop3,vop2,vop1)=tmprptbr S vop5=1 TC:vTp  
 ;
 F J=1:1 Q:'($D(vHDG(J))#2)  D TMPSET(0,PGNO,J,vHDG(J))
 ;
 Q 
 ;
LOCKHDR(LN) ; Private - Lock page header region
 ;
 Q:LN>23  ; Avoid ST420 error
 ;
 WRITE $$LOCK^%TRMVT(LN+0,24),$$CUP^%TRMVT(1,LN-1),!
 S $Y=LN-1 S $X=0
 Q 
 ;
WAIT ; Private - Option Selection
 ;
 N ACCESS N PGNO
 ;
 S ACCESS=0
 ;
 I '$$TMPGET(0,1,0) S PGNO=1
 E  S PGNO=$$LASTPAGE
 ;
 F  Q:$$OPTS 
 ;
 Q 
 ;
OPTS() ; 
 ;
 N I N QUIT N SEQ N ZPGNO
 N fkterm N MASK N OP N RM N VAR N X
 ;
 S QUIT=""
 ;
 S ZPGNO=$$LASTPAGE
 I 'ZPGNO S ZPGNO=1
 ;
 I PN>0,vcrt=4 D FIND1
 I PN<0,vcrt=4 S vcrt=1
 I vcrt=3 D ENDPAGE S vcrt=1
 ;
 ;  Page ~p1  Press any key to stop operation
 I vcrt=2!(vcrt=4) D  I '(QUIT="") Q QUIT
 .	WRITE $$CUOFF^%TRMVT,curBTM,$$^MSG("20",PGNO)
 .	;   #ACCEPT Date=02/08/05; PGM=Dan Russell; CR=13807
 .	R *X:0
 .	I X=-1 WRITE $$CUU^%TRMVT D
 ..		D INDEX(1)
 ..		I VFMQ!(PN<0) S QUIT=0
 ..		E  S QUIT=1
 ..		Q 
 .	Q 
 ;
 I vcrt>1 D PREV S vcrt=1
 ;
 I ($order(%fkey(""))="") D ZBINIT^%TRMVT()
 ;
 S fkterm="ENT,SES,DSP,PRN"
 ;
 F I=1:1:10 S (MASK(I),VAR(I))=""
 S SEQ=1
 ;
 ; PAUSE option on last page only
 I PN<0,ZPGNO=PGNO D
 .	S OP(1)="PAUSE"
 .	S SEQ=SEQ+1
 .	K MASK(1)
 .	Q 
 ;
 ; NEXT option not avaliable on last page
 I '((PN<0)&(ZPGNO=PGNO)) S OP(2)="NEXT" K MASK(2) D ADD^DBSMBAR("PDN",.SEQ)
 ;
 ; PREV & TOP options not available on first page
 I PGNO'=1 S OP(3)="PREV" K MASK(3) D ADD^DBSMBAR("PUP",.SEQ)
 ;
 I PGNO'=1 S OP(4)="TOP" K MASK(4) D ADD^DBSMBAR("TOP",.SEQ)
 ;
 ; BOTTOM option not available on last page
 I '((PN<0)&(ZPGNO=PGNO)) S OP(5)="BOTTOM" K MASK(5) D ADD^DBSMBAR("BOT",.SEQ)
 ;
 ; RESUME option not available on last page
 I PN>0,PGNO'=ZPGNO D
 .	S OP(6)="RESUME"
 .	S VAR(6)=ZPGNO
 .	S SEQ=SEQ+1
 .	K MASK(6)
 .	Q 
 ;
 ; Skip option for labels or notices
 I $D(vHDG) S OP(7)="FIND" K MASK(7) D ADD^DBSMBAR("FND",.SEQ)
 ;
 S OP(8)="PNTSCR" K MASK(8) D ADD^DBSMBAR("PRN",.SEQ)
 ;
 ; Check column definition and BROWSE status flag
 I ($D(vCOL)#2) D
 .	N X N Y
 .	;
 .	S Y=$$TMPGET(0,0,0,.X)
 .	I X=""!(PGNO<X) D
 ..		S OP(9)="BROWSE"
 ..		S SEQ=SEQ+1
 ..		K MASK(9)
 ..		Q 
 .	Q 
 ;
 S OP(10)="QUIT" K MASK(10) D ADD^DBSMBAR("ESC",.SEQ)
 ;
 ; Last Page (~p1)
 I PGNO=ZPGNO&(PN<0) S RM=$$^MSG(1594,PGNO)
 ; Page ~p1
 E  S RM=$$^MSG(2125,PGNO)
 S OP=$$^DBSMBAR(34,fkterm,.MASK,"",.VAR)
 ;
 I %fkey="DSP" D REFRESH Q 0
 ;
 I OP="" D  Q 1
 .	D QUIT
 .	D EXIT
 .	Q 
 ;
 WRITE $char(13),$$LINDEL^%TRMVT,$$CUP^%TRMVT(1,23)
 ;
 S ACCESS=0
 S OP=OP(OP)
 D @OP
 ;
 I VFMQ D EXIT Q 1
 ;
 I ACCESS D  Q QUIT
 .	D INDEX(1)
 .	I VFMQ!(PN<0) S QUIT=0
 .	E  S QUIT=1
 .	Q 
 ;
 I vcrt=1 Q 0
 ;
 Q 1
 ;
INDEX(OPT) ; Private - Create page /line index file
 ;
 N Y
 N X
 ;
 S $X=0 S $Y=vHDG-1
 ;
 S Y=$$TMPGET(0,1,0,.X)
 I X="" D
 .	D TMPSET(0,1,0,"1|1")
 .	D TMPSET(0,2,0,$get(vlc)+1)
 .	Q 
 E  I OPT D
 .	N PAGE
 .	;
 .	S PAGE=$$LASTPAGE+1
 .	D TMPSET(0,PAGE,0,($get(vlc)+1)_"|"_$piece(vHDG,"|",2))
 .	Q 
 ;
 ; Save default page header information if not already saved
 I '$$TMPGET(0,1,1) D
 .	N I
 .	;
 .	F I=1:1 Q:'($D(vHDG(I))#2)  D TMPSET(0,1,I,vHDG(I))
 .	Q 
 ;
 Q 
 ;
EXIT ; Private - Clean up
 ;
 ; Unlock region
 D TERM^%ZUSE(0,"FLUSH")
 ;
 ; Unlock region, clear screen, switch to 80 colmn mode
 WRITE $$LOCK^%TRMVT,$$CLEAR^%TRMVT,$$SCR80^%TRMVT
 D TERM^%ZUSE($I,"ECHO/ESCAPE")
 ;
 D TMPDEL
 Q 
 ;
PREV ; Private - Previous Page
 ;
 N LN1 N LN2
 ;
 Q:PGNO=1 
 ;
 S lnoff=0 S PGNO=PGNO-1
 D GETLINE(.LN1,.LN2)
 D PRINT(LN1,LN2)
 Q 
 ;
NEXT ; Private - Next Page
 ;
 N LN1 N LN2 N X
 ;
 I PN<0,$$LASTPAGE=PGNO Q 
 ;
 S X=PGNO+1
 I '$$TMPGET(0,X,0) S ACCESS=1 Q 
 ;
 S lnoff=0 S PGNO=X
 D GETLINE(.LN1,.LN2)
 D PRINT(LN1,LN2)
 Q 
 ;
TOP ; Private - First Page
 ;
 N LN1 N LN2
 ;
 Q:PGNO=1 
 ;
 S PGNO=1 S lnoff=0
 D GETLINE(.LN1,.LN2)
 D PRINT(LN1,LN2)
 Q 
 ;
RESUME ; Private - Return to current page
 ;
 N LASTPAGE N LN1 N LN2
 ;
 S LASTPAGE=$$LASTPAGE
 Q:LASTPAGE=PGNO 
 ;
 I LASTPAGE'>1 S LASTPAGE=1
 ;
 S PGNO=LASTPAGE S lnoff=0
 D GETLINE(.LN1,.LN2)
 D PRINT(LN1,LN2)
 Q 
 ;
BOTTOM ; Private - Last Page
 ;
 I PN<0 D
 .	S PGNO=$$LASTPAGE
 .	D ENDPAGE
 .	Q 
 E  D
 .	I '$$TMPGET(0,1,0) D
 ..		D TMPSET(0,1,0,"1|1")
 ..		D TMPSET(0,2,0,$get(vlc)+1)
 ..		Q 
 .	E  D  ; Copy header status
 ..		N PAGE N X
 ..		N DATA
 ..		;
 ..		; Get last page with a header
 ..		N rs,vos1,vos2,vos3,vos4  N V1 S V1=$J S rs=$$vOpen3()
 ..		;
 ..  I '$G(vos1) S PAGE=1
 ..  E  I $$vFetch3() S PAGE=rs
 ..		;
 ..		S X=$$TMPGET(0,PAGE,0,.DATA)
 ..		S PAGE=$$LASTPAGE+1
 ..		D TMPSET(0,PAGE,0,($get(vlc)+1)_"|"_$piece(DATA,"|",2))
 ..  Q 
 .	S $X=0 S $Y=vHDG-1
 .	S vcrt=2
 .	Q 
 ;
 Q 
 ;
PAUSE ; Private - Pause option
 ;
 Q 
 ;
QUIT ; Private - Quit option
 ;
 D TMPDEL
 S VFMQ=1
 Q 
 ;
ENDPAGE ; Private
 ;
 N LN1 N LN2
 ;
 D GETLINE(.LN1,.LN2)
 D PRINT(LN1,LN2)
 Q 
 ;
PRINT(LN1,LN2) ; 
 ;
 ; Change to private once that feature works in PSL
 ;
 N I
 ;
 S $Y=+vHDG
 WRITE $$CUP^%TRMVT(1,+vHDG)
 WRITE $$CLP^%TRMVT
 ;
 F I=LN1:1:LN2 D
 .	N HILIGHT N X N Y
 .	N DATA
 .	;
 .	S HILIGHT=0
 .	S Y=$$TMPGET(I,0,0,.X)
 .	;   #ACCEPT DATE=01/02/03;PGM=Dan Russell;CR=Mark Spier
 .	I vcrt=4 XECUTE vfind I   S HILIGHT=1
 .	;
 .	I HILIGHT D
 ..		WRITE $$VIDREV^%TRMVT
 ..		WRITE X,!
 ..		WRITE $$VIDOFF^%TRMVT
 ..		Q 
 .	E  WRITE X,!
 .	Q 
 Q 
 ;
PNTSCR ; Private - Print Screen
 ;
 N I N IORM N IOSL N LN1 N LN2 N NOTNWHDR N OP N PN N VLC N Y N ZZLN1 N ZZLN2
 N HIDX N IO N VAR N X
 ;
 I PGNO=1 S OP=1
 E  S VAR(2)=PGNO S OP=$$^DBSMBAR(35,"","","",.VAR)
 Q:'OP 
 ;
 I OP=1 D
 .	S NOTNWHDR=1
 .	D GETLINE(.LN1,.LN2)
 .	Q 
 E  I OP=2 D PNTALL(.LN1,.LN2)
 ;
 D  Q:IO="" 
 .	N PGM
 .	;
 .	D ^DBSIO
 .	Q 
 ;
 S IORM=80
 S Y=$$TMPGET(1,0,0,.X) I $L(X)>80 S IORM=132
 ;
 S PN=1 S IOSL=IOSL-1
 USE IO D RWHDR
 ;
 S ZZLN1=LN1 S ZZLN2=LN2
 S ZZLN1=ZZLN1-lnoff
 I PGNO'=ZPGNO S ZZLN2=ZZLN2-lnoff
 I ZZLN1<1 S ZZLN1=1
 F I=ZZLN1:1:ZZLN2 D
 .	N X
 .	N DATA
 .	;
 .	I ($D(HIDX(I))#2) D
 ..		D NEWHDR(I)
 ..		D RWHDR
 ..		Q 
 .	E  I VLC>IOSL D RWHDR
 .	;
 .	S X=$$TMPGET(I,0,0,.DATA)
 .	WRITE DATA,!
 .	S VLC=VLC+1
 .	Q 
 ;
 D CLOSE^SCAIO
 ;
 WRITE curBTM,"Done"
 HANG 2
 Q 
 ;
RWHDR ; Private
 ;
 N N
 ;
 WRITE #
 F N=1:1 Q:'($D(vHDG(N))#2)  D HEADER1(vHDG(N))
 S VLC=N-1 S PN=PN+1
 Q 
 ;
NEWHDR(PAGE) ; Private - Switch to new header
 ;
 N I S I=1
 ;
 K vHDG
 ;
 N rs,vos1,vos2,vos3,vos4,vos5,vos6  N V1 S V1=$J S rs=$$vOpen4()
 F  Q:'$$vFetch4()  D
 . S vHDG(I)=rs
 .	S I=I+1
 .	Q 
 Q 
 ;
PNTALL(LN1,LN2) ; 
 ;
 N X
 N DATA
 ;
 S LN1=1
 S X=$$TMPGET(0,PGNO+1,0,.DATA)
 I X S LN2=DATA-1
 E  S LN2=$$LASTLINE
 ;
 ; Save unique page header index information
 N rs,vos1,vos2,vos3,vos4  N V1 S V1=$J S rs=$$vOpen5()
 F  Q:'$$vFetch5()  D
 . N PAGE S PAGE=rs
 .	;
 .	; Get index info for this header
 .	N tmprptbr S tmprptbr=$G(^TMPRPTBR($J,0,PAGE,0))
 .	S HIDX(+$P(tmprptbr,$C(12),1))=PAGE
 . Q 
 ;
 I ($D(HIDX(1))#2) D
 .	D NEWHDR(1)
 .	K HIDX(1)
 .	Q 
 Q 
 ;
BROWSE ; Private - Browse function
 ;
 D ^DBSRWBR2
 Q 
 ;
FIND ; Private - Find string
 ;
 N exists
 N QUIT S QUIT=0
 N FIELD N line N Z
 ;
 ; If haven't set up for next page yet, do it
 S exists=$$TMPGET(0,$$LASTPAGE,0,.line)
 S line=$piece(line,"|",1)
 I (line="") S line=1
 I $$TMPGET(line,0,0) D INDEX(1)
 ;
 F  D  Q:QUIT 
 .	; Find?
 .	WRITE curBTM,$$^MSG(1111)
 .	;   #ACCEPT Date=02/08/05; PGM=Dan Russell; CR=13807
 .	R vfind I (vfind="") S QUIT=1 Q 
 .	;
 .	; Select Column ... Return NULL, "ALL" or "S X=$E(X,n,m)"
 .	S FIELD="ALL"
 .	I ($D(vCOL)#2) S FIELD=$$SELCOL(vCOL) Q:FIELD="" 
 .	S Z="XX"
 .	I FIELD="ALL" S Z="X"
 .	;
 .	S vfind=$$WILDCARD^DBSTBL(vfind,Z)
 .	;
 .	I FIELD'="ALL" S vfind=FIELD_" "_vfind
 .	S vcrt=4
 .	D FIND1
 .	S QUIT=1
 .	Q 
 Q 
 ;
FIND1 ; Private
 ;
 N LN1 N LN2 N HDRPTR N HIT N NOTNWHDR N QUIT
 ;
 F  D  Q:QUIT 
 .	;
 .	S (HIT,QUIT)=0
 .	;
 .	D GETLINE(.LN1,.LN2)
 .	I LN1>lnoff S LN1=LN1-lnoff
 .	;
 .	; Search current buffer
 .	N rs,vos1,vos2,vos3,vos4,vos5,vos6,vos7  N V1 S V1=$J S rs=$$vOpen6()
 .	F  Q:'$$vFetch6()  D  Q:HIT 
 ..		N X
 ..  S X=rs
 ..		;    #ACCEPT DATE=01/02/03;PGM=Dan Russell;CR=Mark Spier
 ..		XECUTE vfind
 ..		I   S HIT=1
 ..		Q 
 .	;
 . I HIT D  Q:QUIT 
 ..		;
 ..		N OP
 ..		;
 ..		K HDRPTR,LN1,NOTNWHDR
 ..		;
 ..		D FINDHDR(.LN1,.LN2)
 ..		D PRINT(LN1,LN2)
 ..		I PGNO=ZPGNO,PN'>0 D  ; Last page
 ...			S vcrt=1
 ...			S QUIT=1
 ...			Q 
 ..		E  D
 ...			; Page ~p1 Continue
 ...			S OP=$$YN^DBSMBAR("",$$^MSG("2126",PGNO),1)
 ...			I 'OP D  ; No
 ....				;
 ....				N exists
 ....				N lastpage
 ....				N line
 ....				;
 ....				S vcrt=1
 ....				S QUIT=1
 ....				;
 ....				; Clean up possible incomplete index before leaving here
 ....				S lastpage=$$LASTPAGE
 ....				S exists=$$TMPGET(0,lastpage,0,.line)
 ....				S line=$piece(line,"|",1)
 ....				I (line="") S line=1
 ....				I '$$TMPGET(line,0,0)  N V2,V3 S V2=$J,V3=lastpage  ZWI ^TMPRPTBR(V2,0,V3,0)
 ....				;
 ....				Q 
 ...			;
 ...			E  I '$$TMPGET(0,PGNO+1,0) D INDEX(0)
 ...			Q 
 ..		Q 
 .	;
 .	; Continue search thru report buffer
 .	I $$TMPGET(0,PGNO+1,0) D
 ..		;
 ..		; Page ~p1
 ..		WRITE curBTM,$$^MSG("2125",PGNO)
 ..		S PGNO=PGNO+1 S NOTNWHDR=1
 ..		Q 
 .	;
 .	; End of report buffer but not end of report
 .	E  I PN>0 D
 ..		S NOTNWHDR=1
 ..		D INDEX(0)
 ..		S QUIT=1
 ..		Q 
 .	;
 .	; End of report ... display last page then quit
 .	E  D
 ..		S vcrt=1
 ..		D PRINT(LN1,LN2)
 ..		S QUIT=1
 ..		Q 
 . Q 
 Q 
 ;
SELCOL(vCOL) ; Private
 ;
 N I N S
 N FROM N OP N TO N VAR N X N Z
 ;
 ; Any_Column
 S S=2 S VAR(1)=$$^MSG("299")
 ;
 F I=1:1 S X=$piece(vCOL,",",I) Q:X=""  D
 .	S Z=$piece(X,"#",1)
 .	I $E(Z,1)="[" S Z=$piece(Z,"]",2) S VAR(S)=Z S S=S+1
 .	Q 
 ;
 S OP=$$^DBSMBAR(36,"","","",.VAR)
 I 'OP Q ""
 I OP=1 Q "ALL"
 ;
 S FROM=$piece($piece(vCOL,",",OP-1),"#",2)
 S TO=$piece($piece(vCOL,",",OP),"#",2)-1
 I TO<FROM S TO=132
 ;
 ; ~p1~p2,~p3 )
 Q "S XX=$E(X,"_FROM_","_TO_")"
 ;
GETLINE(LN1,LN2) ; 
 ;
 N HDRPTR,X,N
 ;
 I '$$TMPGET(0,1,0) D
 .	S LN1=1
 .	S LN2=$$LASTLINE
 .	Q 
 E  D FINDHDR(.LN1,.LN2)
 Q 
 ;
FINDHDR(LN1,LN2) ; 
 ;
 N X
 N DATA
 ;
 S X=$$TMPGET(0,PGNO,0,.LN1)
 S HDRPTR=$piece(LN1,"|",2) S LN1=+LN1 ; Header status
 I LN1=0 S LN1=1
 ;
 I 'HDRPTR D  ; Check current page
 .	S X=$$TMPGET(0,PGNO+1,0,.DATA)
 .	I $piece(DATA,"|",2) D
 ..		; Find prev page header
 ..		N rs,vos1,vos2,vos3,vos4,vos5  N V1 S V1=$J S rs=$$vOpen7()
 ..  I '$G(vos1) S HDRPTR=1
 ..  E  I $$vFetch7() S HDRPTR=rs
 ..  Q 
 .	Q 
 ;
 ; Display new header ?
 ;
 I HDRPTR,'$get(NOTNWHDR) D GETHDR
 ;
 S X=$$TMPGET(0,PGNO+1,0,.DATA)
 I X S LN2=DATA-1
 E  S LN2=$$LASTLINE
 Q 
 ;
GETHDR ; Private - Load header
 ;
 N N
 ;
 Q:'HDRPTR 
 ;
 I $get(vcrt)=1,$piece(vHDG,"|",2)="" Q  ; Skip header
 I $get(vcrt)=1,$piece(vHDG,"|",2)=HDRPTR Q  ; same header
 I '$$TMPGET(0,HDRPTR,1) Q  ; No header
 ;
 WRITE $$CLRXY^%TRMVT
 ;
 D NEWHDR(HDRPTR)
 ;
 F N=1:1 Q:'($D(vHDG(N))#2)  WRITE vHDG(N),!
 ;
 S vHDG=N_"|"_HDRPTR
 ;
 D LOCKHDR(vHDG)
 ;
 Q 
 ;
REFRESH ; Private - Refresh screen
 ;
 N LN1 N LN2
 ;
 D PNTHDR
 D GETLINE(.LN1,.LN2)
 D PRINT(LN1,LN2)
 ;
 Q 
 ;
TMPGET(LINE,PAGE,SEQ,DATA) ; 
 N vret
 ;
 ; Change to private once that feature works in PSL
 ;
 N tmprptbr,vop1 S tmprptbr=$$vRCgetRecord1Opt^RecordTMPRPTBR($J,LINE,PAGE,SEQ,0,.vop1)
 ;
 S DATA=$P(tmprptbr,$C(12),1)
 S vret=$G(vop1) Q vret ; Return whether exists or not
 ;
TMPSET(LINE,PAGE,SEQ,DATA) ; 
 N vTp
 ;
 N tmprptbr,vop1,vop2,vop3,vop4,vop5 S vop4=$J,vop3=LINE,vop2=PAGE,vop1=SEQ,tmprptbr=$$vRCgetRecord1Opt^RecordTMPRPTBR($J,LINE,PAGE,SEQ,0,.vop5)
 ;
  S $P(tmprptbr,$C(12),1)=DATA
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" S ^TMPRPTBR(vop4,vop3,vop2,vop1)=tmprptbr S vop5=1 TC:vTp  
 Q 
 ;
TMPDEL ; Private - Delete report browser table
 ;
  K ^TMPRPTBR($J)
 Q 
 ;
LASTPAGE() ; Private - Return highest page number
 ;
 N PAGE S PAGE=0
 ;
 N rs,vos1,vos2,vos3,vos4,vos5  N V1 S V1=$J S rs=$$vOpen8()
 ;
 I $$vFetch8() S PAGE=rs
 ;
 Q PAGE
 ;
LASTLINE() ; Return highest line number
 ;
 ; Change to private once that feature works in PSL
 ;
 ; Note - also called by DBSRWSTS
 ;
 N LINE S LINE=1
 ;
 N rs,vos1,vos2,vos3,vos4,vos5,vos6  N V1 S V1=$J S rs=$$vOpen9()
 ;
 I $$vFetch9() S LINE=rs
 ;
 Q LINE
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60842^35326^Dan Russell^18235" ; Signature - LTD^TIME^USER^SIZE
 ;
vOpen1() ; PAGENO,DATA FROM TMPRPTBR WHERE JOBNO=:V1 AND LINENO=0 AND SEQ=0 ORDER BY PAGENO DESC
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1)
 S vos4=""
vL1a4 S vos4=$O(^TMPRPTBR(vos3,0,vos4),-1) I vos4="" G vL1a0
 I '($D(^TMPRPTBR(vos3,0,vos4,0))#2) G vL1a4
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos5=$G(^TMPRPTBR(vos3,0,vos4,0))
 S rs=$S(vos4=vos2:"",1:vos4)_$C(9)_$P(vos5,$C(12),1)
 ;
 Q 1
 ;
vOpen2() ; LINENO,DATA FROM TMPRPTBR WHERE JOBNO=:V2 AND LINENO >= :J AND PAGENO=0 AND SEQ=0 ORDER BY LINENO ASC
 ;
 ;
 S vos6=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos6=0 Q
vL2a1 S vos7=$$BYTECHAR^SQLUTL(254)
 S vos8=$G(V2)
 S vos9=$G(J)
 S vos10=vos9
 I $D(^TMPRPTBR(vos8,vos10)) G vL2a7
vL2a6 S vos10=$O(^TMPRPTBR(vos8,vos10),1) I vos10="" G vL2a0
vL2a7 I '($D(^TMPRPTBR(vos8,vos10,0,0))#2) G vL2a6
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos6=1 D vL2a6
 I vos6=2 S vos6=1
 ;
 I vos6=0 S rs2="" Q 0
 ;
 S vos11=$G(^TMPRPTBR(vos8,vos10,0,0))
 S rs2=$S(vos10=vos7:"",1:vos10)_$C(9)_$P(vos11,$C(12),1)
 ;
 Q 1
 ;
vOpen3() ; PAGENO FROM TMPRPTBR WHERE JOBNO=:V1 AND LINENO=0 AND SEQ=1 ORDER BY PAGENO DESC
 ;
 ;
 S vos1=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos1=0 Q
vL3a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1)
 S vos4=""
vL3a4 S vos4=$O(^TMPRPTBR(vos3,0,vos4),-1) I vos4="" G vL3a0
 I '($D(^TMPRPTBR(vos3,0,vos4,1))#2) G vL3a4
 Q
 ;
vFetch3() ;
 ;
 ;
 I vos1=1 D vL3a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen4() ; DATA FROM TMPRPTBR WHERE JOBNO=:V1 AND LINENO=0 AND PAGENO=:PAGE AND SEQ>0 ORDER BY SEQ ASC
 ;
 ;
 S vos1=2
 D vL4a1
 Q ""
 ;
vL4a0 S vos1=0 Q
vL4a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1)
 S vos4=$G(PAGE)
 S vos5=0
vL4a5 S vos5=$O(^TMPRPTBR(vos3,0,vos4,vos5),1) I vos5="" G vL4a0
 Q
 ;
vFetch4() ;
 ;
 ;
 I vos1=1 D vL4a5
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos6=$G(^TMPRPTBR(vos3,0,vos4,vos5))
 S rs=$P(vos6,$C(12),1)
 ;
 Q 1
 ;
vOpen5() ; PAGENO FROM TMPRPTBR WHERE JOBNO=:V1 AND LINENO=0 AND SEQ=1
 ;
 ;
 S vos1=2
 D vL5a1
 Q ""
 ;
vL5a0 S vos1=0 Q
vL5a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1)
 S vos4=""
vL5a4 S vos4=$O(^TMPRPTBR(vos3,0,vos4),1) I vos4="" G vL5a0
 I '($D(^TMPRPTBR(vos3,0,vos4,1))#2) G vL5a4
 Q
 ;
vFetch5() ;
 ;
 ;
 I vos1=1 D vL5a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen6() ; DATA FROM TMPRPTBR WHERE JOBNO=:V1 AND LINENO >= :LN1 AND LINENO <= :LN2 AND PAGENO=0 AND SEQ=0
 ;
 ;
 S vos1=2
 D vL6a1
 Q ""
 ;
vL6a0 S vos1=0 Q
vL6a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1)
 S vos4=$G(LN1)
 S vos5=$G(LN2)
 S vos6=vos4
 I $D(^TMPRPTBR(vos3,vos6)),'(vos6>vos5) G vL6a8
vL6a7 S vos6=$O(^TMPRPTBR(vos3,vos6),1) I vos6=""!(vos6>vos5) G vL6a0
vL6a8 I '($D(^TMPRPTBR(vos3,vos6,0,0))#2) G vL6a7
 Q
 ;
vFetch6() ;
 ;
 ;
 I vos1=1 D vL6a7
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos7=$G(^TMPRPTBR(vos3,vos6,0,0))
 S rs=$P(vos7,$C(12),1)
 ;
 Q 1
 ;
vOpen7() ; PAGENO FROM TMPRPTBR WHERE JOBNO=:V1 AND LINENO=0 AND PAGENO <= :PGNO AND SEQ=1 ORDER BY PAGENO DESC
 ;
 ;
 S vos1=2
 D vL7a1
 Q ""
 ;
vL7a0 S vos1=0 Q
vL7a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1)
 S vos4=$G(PGNO)
 S vos5=vos4
 I $D(^TMPRPTBR(vos3,0,vos5)) G vL7a7
vL7a6 S vos5=$O(^TMPRPTBR(vos3,0,vos5),-1) I vos5="" G vL7a0
vL7a7 I '($D(^TMPRPTBR(vos3,0,vos5,1))#2) G vL7a6
 Q
 ;
vFetch7() ;
 ;
 ;
 I vos1=1 D vL7a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos5=vos2:"",1:vos5)
 ;
 Q 1
 ;
vOpen8() ; PAGENO FROM TMPRPTBR WHERE JOBNO=:V1 AND LINENO=0 ORDER BY PAGENO DESC
 ;
 ;
 S vos1=2
 D vL8a1
 Q ""
 ;
vL8a0 S vos1=0 Q
vL8a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1)
 S vos4=""
vL8a4 S vos4=$O(^TMPRPTBR(vos3,0,vos4),-1) I vos4="" G vL8a0
 S vos5=""
vL8a6 S vos5=$O(^TMPRPTBR(vos3,0,vos4,vos5),1) I vos5="" G vL8a4
 Q
 ;
vFetch8() ;
 ;
 ;
 I vos1=1 D vL8a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen9() ; LINENO FROM TMPRPTBR WHERE JOBNO=:V1 ORDER BY LINENO DESC
 ;
 ;
 S vos1=2
 D vL9a1
 Q ""
 ;
vL9a0 S vos1=0 Q
vL9a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1)
 S vos4=""
vL9a4 S vos4=$O(^TMPRPTBR(vos3,vos4),-1) I vos4="" G vL9a0
 S vos5=""
vL9a6 S vos5=$O(^TMPRPTBR(vos3,vos4,vos5),1) I vos5="" G vL9a4
 S vos6=""
vL9a8 S vos6=$O(^TMPRPTBR(vos3,vos4,vos5,vos6),1) I vos6="" G vL9a6
 Q
 ;
vFetch9() ;
 ;
 ;
 I vos1=1 D vL9a8
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
