DBSLINK(dbtbl2)	;;DBS - U - v7.0 - PSL Linked Screen Compiler
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSLINK ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	N % N %TAB N BLD N CMD N D N DEF N DES N DLIB N EXTSID N FA N FB N FILE N FILER N FILES N FLAG N HELP N HV N i N I N IDXX N ISEQ N KVAR N LOOP N MAXLN N MPLCT N N N NEW N NI N NOLINK N NS N NUL N OD N OK N OL
	N P15 N P2 N P8 N P9 N PFID N PGM N PON N Q N Q2 N REL N RPCFLG N S N SAVPGM N SCRER N SCRNUM
	N SEQ N SVLSVSID N SVSID N SYS N T N TB N TEMP N TMP N USERVLOD N Vprot N X N X1 N X2 N XCOMP N XLINK N XNEW N VPG N ZSID N ZZ
	N comp N expr N fid N l N lvn N mcode N n N newLevel N optFlag N pprocs N return N sidArray
	N vdd N vFID N vobjlst
	;
	S Q=$char(34)
	S %="|"
	S NUL=Q_Q
	S Q2=NUL
	S FLAG=0
	S (PON,ISEQ)=0
	S MAXLN=1
	S (T,D,CMD)=0
	S (OL,OD)=""
	;
	D VALID(.dbtbl2,SID,.SCRNUM) I ER WRITE !,RM Q 
	 S:'$D(vobj(dbtbl2,"v1")) vobj(dbtbl2,"v1")=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),-1)),1:"")
	I $P(vobj(dbtbl2,"v1"),$C(124),1)="" S ER=0 S RM=$$^MSG(2019) Q 
	;
	; Disable LOOP
	S LOOP="NOLOOP"
	;
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	S PGM=$P(vobj(dbtbl2,0),$C(124),2)
	S FILES=$P(vobj(dbtbl2,0),$C(124),1)
	S PFID=$piece(FILES,",",1)
	I (PGM="") D
	.	D GTPGM^DBSDS
	.	I PGM["*" S PGM=$E(PGM,1,3)_"S"_$E(PGM,5,9)
	. S vobj(dbtbl2,-100,0)="",$P(vobj(dbtbl2,0),$C(124),2)=PGM N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBTBL2FL(dbtbl2,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(dbtbl2,-100) S vobj(dbtbl2,-2)=1 Tcommit:vTp  
	.	Q 
	;
	S SAVPGM=PGM
	S SVSID=SID
	D PARLIST^DBS2PSL0(.dbtbl2,.vobjlst,FILES,.vFID) ; build formal and actual parameter lists
	S SCRER=0
	;
	N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen1()
	I '$$vFetch1() Q 
	S i=""
	F SCRNUM=1:1 S SID=$get(sidArray(SCRNUM)) Q:SID=""  D BUILD(SID,SCRNUM) Q:ER 
	I SCRER Q 
	D FILE(SCRNUM)
	Q 
	;
BUILD(SID,SCRNUM)	; Build multiple screen program
	N vo2
	;
	N DFID N DLIB N DT N EXTSID N FILES N LIB N parlst N PFID N PGM N SCRER N SEQ N vFID N Vprot N X N Z
	N ds S ds=$$vOpen2()
	N dbtbl2d
	N pproc
	N dbtblpp
	;
	I ($get(%LIBS)="") S %LIBS="SYSDEV"
	I $E(SID,1)="@" D APPEND S SCRNUM=SCRNUM-1 D vKill1(""),vKill2("") K vobj(+$G(ds)) Q 
	I SID["[" S X=$piece(SID,"]",1) S %LIBS=$piece(X,"[",2) S SID=$piece(SID,"]",2)
	;
	;  Invalid screen name
	I '$$vDbEx1() WRITE ?20,$$^MSG(1458,SID) S SCRER=1 D vKill1(""),vKill2("") K vobj(+$G(ds)) Q  ; Invalid screen name ~p1
	;
	K DT
	N dbtbl2 S dbtbl2=$$vDb1(%LIBS,SID)
	 S vobj(dbtbl2,0)=$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0))
	S FILES=$P(vobj(dbtbl2,0),$C(124),1)
	;
	; set up parameter list for this screen only (not the main screen)
	D PARLIST^DBS2PSL0(.dbtbl2,.parlst,FILES,.vFID)
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	;
	S PFID=$piece(FILES,",",1)
	S PGM=$P(vobj(dbtbl2,0),$C(124),2)
	I (PGM="") D
	.	D GTPGM^DBSDS
	.	I PGM["*" S PGM=$E(PGM,1,3)_"S"_$E(PGM,5,9)
	. S vobj(dbtbl2,-100,0)="",$P(vobj(dbtbl2,0),$C(124),2)=PGM
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBTBL2FL(dbtbl2,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(dbtbl2,-100) S vobj(dbtbl2,-2)=1 Tcommit:vTp  
	.	Q 
	S EXTSID=SID WRITE !,?20,SID,?40,PGM
	S VPG(SCRNUM)=$P(vobj(dbtbl2,0),$C(124),9)_"|"_SID
	D LOAD(.dbtbl2,.ds,.dbtbl2d,.pproc,.dbtblpp)
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	S SEQ=0
	S CMD=CMD+1 S TMP(CMD)="VPG"_SCRNUM_"("_vobjlst("formal")_")  // "_$P(vobj(dbtbl2,0),$C(124),9)
	S CMD=CMD+1 S TMP(CMD)=" type Public String %MODS,%REPEAT,ET,SID,VPGM,VPTBL"
	S CMD=CMD+1 S TMP(CMD)=" type String DFID,PGM"
	S CMD=CMD+1 S TMP(CMD)=" set SID="""_SID_""",DFID="""_DFID_""""
	S CMD=CMD+1 S TMP(CMD)=" do ^USID if PGM="""" set ET=""INVLDSCR"" do ^UTLERR Q"
	;
	D REPEAT(.dbtbl2) ; check for repeating screen
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	S CMD=CMD+1
	;
	S Vprot=0 ; check for protetion flag
	S Z="" I $P(vobj(dbtbl2,0),$C(124),16) D
	.	S Vprot=1
	.	D STATUS^UPID(PFID,"*",.Z)
	.	I Z S Z="set Z=""do VPROT^""_PGM_""("_parlst("actual")_")"" quit:ER  "
	.	E  S Z=""
	.	Q 
	;
	; Display pre-proc
	I $$vDbEx2() D
	.	S TMP(CMD)=" do VDSPPRE^"_PGM_"("_parlst("actual")_")"
	.	Q 
	;
	S TMP(CMD)=" kill VPTBL"
	S CMD=CMD+1 S TMP(CMD)=" set VPGM=PGM"
	I Z'="" S CMD=CMD+1 S TMP(CMD)=" x Z"
	;
	;jambotka CR10072
	S CMD=CMD+1 S TMP(CMD)=" do VREPRNT^"_PGM
	S CMD=CMD+1 S TMP(CMD)=" if %ProcessMode>1 quit" ; ***XUS
	S CMD=CMD+1 S TMP(CMD)=" do VTAB^"_PGM_"("_parlst("actual")_")"
	S CMD=CMD+1 S TMP(CMD)=" quit"
	S CMD=CMD+1 S TMP(CMD)=" "
	;
	S SEQ=""
	F  S SEQ=$order(dbtbl2d(SEQ)) Q:SEQ=""  S vo2=$G(dbtbl2d(SEQ)) D SEQ(.vo2) S dbtbl2d(SEQ)=vo2
	D vKill1(""),vKill2("") K vobj(+$G(dbtbl2)),vobj(+$G(ds)),vobj(+$G(pproc)) Q 
	;
SEQ(dbtbl2d)	;
	;
	N comp N di N DINAM N fid N P2 N P8 N P9 N P15 N vp N VP N X
	;
	S P2=$P(vobj(dbtbl2d),$C(124),2) ; display type
	S P15=$P(vobj(dbtbl2d),$C(124),15) ; decimal precision
	S P8=$P(vobj(dbtbl2d),$C(124),8) ; post processor flag
	S P9=$P(vobj(dbtbl2d),$C(124),9) ; pre-processor flag
	S DINAM=$P(vobj(dbtbl2d),$C(124),5) ; data item name
	I DINAM'?1"[".E1"]".E Q 
	;set X=vdd(DINAM).get()
	;do PARSE^DBSDD(.DINAM,.X,.comp,.fsn,"",.vdd) quit:ER
	;if ER="" write !,$$MSG^%TRMVT($$^MSG(587,DINAM),0,0)
	;
	I 'Vprot Q 
	;set fid=$P(DINAM,".",2) set di=$P(DINAM,".",3)
	S di=$piece(DINAM,"]",2)
	S fid=$piece($piece(DINAM,"]",1),",",2)
	D STATUS^UPID(fid,di,.VP) ; protection status
	I VP S vp(fid,di)=""
	Q 
	;
LOAD(dbtbl2,ds,dbtbl2d,pprocs,dbtbl2pp)	;
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	;
	N i N pseq
	N %LINS N LIB N SEQ N X
	; IMPLICIT SCREEN
	S LIB="SYSDEV"
	S DFID=$piece(($P(vobj(dbtbl2,0),$C(124),1)),",",1)
	S SEQ=0
	;
	; Load all screen pre and post processor code
	K vobj(+$G(pprocs)) S pprocs=$$vOpen3()
	F  Q:'($$vFetch3(pprocs))  D
	.	N dbtbl2pp S dbtbl2pp=$G(^DBTBL($P(vobj(pprocs),$C(9),1),2,$P(vobj(pprocs),$C(9),2),$P(vobj(pprocs),$C(9),3),$P(vobj(pprocs),$C(9),4)))
	.	S X=$P(dbtbl2pp,$C(12),1)
	.	;do ^DBSPARS
	.	Q  ; while ...
	;
	; Load all screen elements into the DT array
	K vobj(+$G(ds)) S ds=$$vOpen4()
	S i=0
	F  Q:'($$vFetch4(ds))  D
	.	S i=i+1
	. K vobj(+$G(dbtbl2d(i))) S dbtbl2d(i)=$$vDb3($P(vobj(ds),$C(9),1),$P(vobj(ds),$C(9),2),$P(vobj(ds),$C(9),3))
	.	D setSeq(dbtbl2d(i),i)
	.	;set SEQ=dbtbl2d(i).seq
	.	;
	.	;load column pre/post procs
	.	N ds2,vos1,vos2,vos3,vos4,vos5 S ds2=$$vOpen5()
	.	F  Q:'($$vFetch5())  D
	..		N dbtbl2pp S dbtbl2pp=$G(^DBTBL($P(ds2,$C(9),1),2,$P(ds2,$C(9),2),$P(ds2,$C(9),3),$P(ds2,$C(9),4)))
	..		S X=$P(dbtbl2pp,$C(12),1)
	..		;do ^DBSPARS
	..		Q  ; while ...
	.	Q 
	Q 
	;
setSeq(scr,i)	;
	S SEQ=vobj(scr,-5)
	Q 
	;
FILE(SCRNUM)	;
	;
	N AR N bld N COMVAR N DFV N DT N FID N fsn N KVAR N L N LOOP N N N NEW N OM N PGM N REPORT N VNEW N X N X1 N XLT N Z
	N USERVLOD
	N I N RPCFLG
	;
	S SID=SVSID
	S PGM=SAVPGM
	D ^DBSREL
	I ER D ERR^DBSBLD I X="Q" Q 
	S L=0
	S FID=PFID
	S SCREEN=1
	D FLD^DBSBLD
	K SCREEN
	;
	N dbtbl1,vop1,vop2,vop3 S vop1=%LIBS,vop2=FID,dbtbl1=$$vDb5(%LIBS,FID)
	 S vop3=$G(^DBTBL(vop1,1,vop2,101))
	N dbtbl2,vop4,vop5,vop6 S vop4=%LIBS,vop5=SID,dbtbl2=$$vDb6(%LIBS,SID)
	 S vop6=$G(^DBTBL(vop4,2,vop5,0))
	;type RecordCUVAR cuvar=Db.getRecord("CUVAR")
	S USERVLOD=$$vDbEx3()
	;
	S RPCFLG=1
	;
	I 1,"US" ;* if RPCFLG,CUVAR.editmask set RPCFLG=0
	I USERVLOD S RPCFLG=0
	;
	S Z=$order(BLD(""),-1)+1
	I USERVLOD D USRVLOD
	S X="" F I=1:1 S X=$order(SCRVLOD(X)) Q:X=""  S BLD(Z+I)=SCRVLOD(X)
	S AR=""
	F  S AR=$order(FILE(AR)) Q:AR=""  D BLD1(AR)
	;
	K FILE
	S SID=SVSID
	S PGM=SAVPGM
	S (N,COMVAR,KVAR)=""
	S SCRNUM=SCRNUM-1
	I ($D(BLD(2))#2),$piece(BLD(2)," ;",1)="EXEC" S BLD(2)="VLOD // Load data from disc - %O = (1-5)"
	;
	I USERVLOD D  ; user defined vlod section
	.	N OM
	.	N i
	.	S X=100.99
	.	N ds,vos1,vos2,vos3,vos4 S ds=$$vOpen6()
	.	S i=0
	.	F  Q:'($$vFetch6())  D
	..		N dbtblpp S dbtblpp=$G(^DBTBL($P(ds,$C(9),1),2,$P(ds,$C(9),2),$P(ds,$C(9),3),$P(ds,$C(9),4)))
	..		S i=i+1
	..		S OM(i)=$P(dbtblpp,$C(12),1)
	..		Q 
	.	Q 
	;
	S BLD(2)="VLOD("_vobjlst("formal")_")  // User defined access section"
	S X=0 F I=1:1 S X=$order(OM(X)) Q:X=""  S BLD(I/1000+2)=OM(X)
	K OM
	;
	S KVAR="kill %A,%TAB,vtab,VFSN,%OLD,%NEW,%FILE,%INDEX,%PAGE,%PG,UX,MULSCR"
	N fid S fid=""
	F  S fid=$order(LOOP(-1,fid)) Q:fid=""  D LOOP(fid)
	;
	D ^ULODTMPL("DBSSCRTMP","REPORT") ; Load linked screen template
	S N=""
	F  S N=$order(REPORT(N)) Q:N=""  D
	.	Q:$E(REPORT(N),1)=" "!(REPORT(N)="") 
	.	S XLT($piece(REPORT(N)," ",1))=N
	.	Q 
	;
	; Program Id & Copyright Message
	D ^SCACOPYR(.X1)
	S REPORT(1)=PGM_"( Number %ProcessMode,"_vobjlst("formal")_")   //"_$P(vop6,$C(124),11)_" - "_$P(vop6,$C(124),12)_" - SID= <"_$get(SID)_"> "_$P(vop6,$C(124),9)
	S REPORT(2)=X1 K X1
	S REPORT(2.001)=" #WARN ACCESS,MISMATCH OFF"
	;
	S X1=XLT("VPAGE")+.001
	S REPORT(X1)=" " S X1=X1+.001
	F I=1:1:CMD S REPORT(X1)=TMP(I) S X1=X1+.001
	;
	; build VPG section
	S X1=XLT("VPG")
	S REPORT(X1)="VPG("_vobjlst("formal")_")" S X1=X1+.001
	S REPORT(X1)=" type Public Number %PG,%PGSV" S X1=X1+.001
	S REPORT(X1)=" type Number vDONE" S X1=X1+.001
	S REPORT(X1)=" set vDONE=0" S X1=X1+.001
	S REPORT(X1)=" for  do { quit:vDONE" S X1=X1+.001
	F I=1:1:SCRNUM D
	.	S REPORT(X1)="  if %PG=(%PGSV+"_(I-1)_") do VPG"_I_"("_vobjlst("actual")_"),VPG0("_vobjlst("actual")_") quit:vDONE"
	.	S X1=X1+.001
	.	Q 
	S REPORT(X1)="  }" S X1=X1+.001
	S REPORT(X1)=" quit"
	;
	; build VPG0 section
	S X1=XLT("VPG0")
	S REPORT(X1)="VPG0("_vobjlst("formal")_")" S X1=X1+.001
	S REPORT(X1)=" type Public String vDONE,VFMQ,VPG()" S X1=X1+.001
	S REPORT(X1)=" type Public Number %PAG,%PAGE,%PG,%PGSV" S X1=X1+.001
	S REPORT(X1)=" type String %LINK" S X1=X1+.001
	S REPORT(X1)=" set %LINK=""""" S X1=X1+.001
	S REPORT(X1)=" if %ProcessMode=2!(%ProcessMode=3)!(%ProcessMode=4) do VBTM("_vobjlst("actual")_") if VFMQ.get()=""D"" set vDONE=1 quit"
	S X1=X1+.001
	S REPORT(X1)=" if '%PAGE.exists() set vDONE=1 quit" S X1=X1+.001
	S REPORT(X1)=" if %PG'<%PAG kill %PAG,%PGSV,VPG set vDONE=1 quit" S X1=X1+.001
	S REPORT(X1)=" set %PG=%PG+1" S X1=X1+.001
	S REPORT(X1)=" quit" S X1=X1+.001
	;
	; build VNEW section
	S X1=XLT("VNEW")
	S REPORT(X1)="VNEW("_vobjlst("formal")_")" S X1=X1+.001
	S REPORT(X1)=" " S X1=X1+.001
	;
	I USERVLOD D
	.	S REPORT(X1)=" do VLOD("_vobjlst("actual")_")"
	.	S REPORT(X1+.001)=" quit"
	.	S REPORT(X1+.002)="VNEWDQ("_vobjlst("formal")_") // Original VNEW section"
	.	S REPORT(X1+.003)=" "
	.	S X1=X1+.005
	.	Q 
	;
	S X="" F  S X=$order(VNEW(X)) Q:X=""  S REPORT(X1)=VNEW(X) S X1=X1+.001
	;
	; Default values
	I PFID'="" D
	.	I '($D(fsn(PFID))#2) D fsn^DBSDD(.fsn,PFID)
	.	I $P(vop3,$C(124),1)="" Q  ; no defaults
	.	S X1=X1+.001
	.	Q 
	;
	; TAG BUILD SECTION
	S REPORT(X1)=" quit" S X1=X1+.001
	S REPORT(X1)=" //" S X1=X1+.001
	S X=""
	F  S X=$order(BLD(X)) Q:X=""  S REPORT(X1)=BLD(X) S X1=X1+.001
	;
	; Screen pre-processor ( level 0 ... 61-80)
	S X1=XLT("V1") K REPORT(X1)
	S X1=X1+1.001
	;
	; ---------- Without Display Pre-processor
	I '$$vDbEx4() D
	.	S REPORT(X1)=" if '%ProcessMode do VNEW("_vobjlst("actual")_")" S X1=X1+.001
	.	S REPORT(X1)=" if %ProcessMode do VLOD("_vobjlst("actual")_") if $G(ER) set VFMQ=""Q"" quit" S X1=X1+.001
	.	S REPORT(X1)=" do VPG("_vobjlst("actual")_")" S X1=X1+.001
	.	S REPORT(X1)=" quit" S X1=X1+.001
	.	Q 
	;
	; ---------- With screen display pre-processor
	E  D
	.	N tag
	.	S tag="VDSPPRE("_vobjlst("formal")_") // Screen Display Pre-Processor"
	.	D PPUTIL(121,tag)
	.	S X1=X1+.001
	.	S REPORT(X1)=" "
	.	S REPORT(X1)=" if '%ProcessMode do VNEW("_vobjlst("actual")_")  // Screen Display Pre-Processor" S X1=X1+.001
	.	S REPORT(X1)=" if %ProcessMode do VLOD("_vobjlst("actual")_") if $G(ER) set VFMQ=""Q"" quit" S X1=X1+.001
	.	S REPORT(X1)=" do VDSPPRE("_vobjlst("actual")_") if $G(ER) set VFMQ=""Q"" quit" S X1=X1+.001
	.	S REPORT(X1)=" do VPG("_vobjlst("actual")_")" S X1=X1+.001
	.	S REPORT(X1)=" quit"
	.	Q 
	;
	S X1=XLT("VBTM")
	S REPORT(X1)="VBTM("_vobjlst("formal")_")"
	;
	; Computed variables
	S X1=XLT("V0")+.001 K REPORT(XLT("V0"))
	;
	; ---------- With screen pre-processor
	I $$vDbEx5() D
	.	N tag
	.	S tag="VSCRPRE("_vobjlst("formal")_") // Screen Pre-Processor"
	.	D PPUTIL(61,tag)
	.	S REPORT(X1)=" set ER=0 do VSCRPRE("_vobjlst("actual")_") if ER quit  // Screen Pre-Processor"
	.	S X1=X1+.001 S REPORT(X1)=" //" S X1=X1+.001
	.	Q 
	;
	S REPORT(X1)=" type Public Number ER" S X1=X1+.001
	S REPORT(X1)=" type Public String %PAG,%PAGE,%PG,%PGSV,MULSCR,RM,VFMQ" S X1=X1+.001
	S REPORT(X1)=" type String KVAR,VPG(),vPSL,VSID" S X1=X1+.001
	S REPORT(X1)=" set VSID="_Q_SID_Q S X1=X1+.001
	I COMVAR'="" S REPORT(X1)=" set ("_$E(COMVAR,1,$L(COMVAR)-1)_")="_Q_Q
	;
	S X1=X1+.001 S REPORT(X1)=" set KVAR="_Q_KVAR_Q S X1=X1+.001
	S REPORT(X1)=" set:'%PG.exists() %PG=1 set %PAG=%PG+"_(SCRNUM-1)_" set %PAGE=$S(%PAGE.exists():%PAGE-1,1:0)+"_SCRNUM
	S X1=X1+.001 S REPORT(X1)=" set vPSL=1  //compiled for PSL"
	S X1=X1+.001 S REPORT(X1)=" //" S X1=X1+.001
	F I=1:1:SCRNUM S REPORT(X1)=" set VPG(%PG+"_(I-1)_")="_Q_VPG(I)_Q S X1=X1+.001
	S X1=XLT("VPAGE") K REPORT(X1)
	K XLT,BLD,VNEW,DFV,COMVAR,VPG,OM,NEW,LOOP
	;
	D BUILDRTN^UCGM(.REPORT,PGM,,SID_"~Screen")
	Q 
	;
DOUBLE(X)	;
	N I N L S L=0
	F I=1:1 S L=$F(X,Q,L) Q:L<1  S X=$E(X,1,L-2)_Q_Q_$E(X,L,999) S L=L+1
	D LOOP(N)
	Q 
	;
LOOP(fid)	; Build appropiate arrays from LOOP(array) // Build appropiate arrays from LOOP(array)
	;
	Q 
	;
REPEAT(dbtbl2)	;
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	;
	N Z N Z1
	;
	Q:'$P(vobj(dbtbl2,0),$C(124),7) 
	I ($D(ZZREPSCR(SID))#2) S Z1=ZZREPSCR(SID) S Z=" set %MODS="_(Z1+1)_",%REPEAT=zzREPEAT#"_Z1
	E  S Z=" set %MODS=1 I '%REPEAT.exists() set %REPEAT="_(23-$P(vobj(dbtbl2,0),$C(124),7))
	S ZZREPSCR(SID)=23-$P(vobj(dbtbl2,0),$C(124),7)
	S CMD=CMD+1 S TMP(CMD)=Z
	Q 
	;
PPUTIL(node,tag)	;
	;
	N I N OM N X N X1 N X2 N Z
	S X=node-.001 S X2=X+20
	;
	N ds,vos1,vos2,vos3,vos4,vos5,vos6 S ds=$$vOpen7()
	S I=0
	F  Q:'($$vFetch7())  D
	.	N code
	.	N dbtbl2pp S dbtbl2pp=$G(^DBTBL($P(ds,$C(9),1),2,$P(ds,$C(9),2),$P(ds,$C(9),3),$P(ds,$C(9),4)))
	.	S code=$P(dbtbl2pp,$C(12),1)
	.	I $piece(code," //",2)?.E1"["1A.AN1"]"1A.AN S code=$piece(code," //",1)
	.	E  I $piece(code," ;",2)?.E1"["1A.AN1"]"1A.AN S code=$piece(code," ;",1)
	.	S I=I+1
	.	S OM(I)=code
	.	Q 
	;
	; end of program
	S X1=$order(REPORT(""),-1)+100
	S REPORT(X1)=tag S X1=X1+.001
	S REPORT(X1)=" new %TAB,vtab  // Disable .MACRO. references to %TAB()" S X1=X1+.001
	S REPORT(X1)=" //" S X1=X1+.001
	;
	S Z="" F  S Z=$order(OM(Z)) Q:Z=""  S REPORT(X1)=OM(Z) S X1=X1+.001
	S REPORT(X1)=" quit"
	Q 
	;
VALID(dbtbl2,SID,scrnum)	; Validate screen linkage file relationships
	 S:'$D(vobj(dbtbl2,"v1")) vobj(dbtbl2,"v1")=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),-1)),1:"")
	 S:'$D(vobj(dbtbl2,0)) vobj(dbtbl2,0)=$S(vobj(dbtbl2,-2):$G(^DBTBL(vobj(dbtbl2,-3),2,vobj(dbtbl2,-4),0)),1:"")
	;
	N file N i N j N mfile N SF N sid N z N zfile
	S ER=0
	S scrnum=0
	I $P(vobj(dbtbl2,"v1"),$C(124),1)="" Q  ; not a linked screen
	;
	; Acccess files (master screen)
	S mfile=","_$P(vobj(dbtbl2,0),$C(124),1)_","
	; Check each screen
	;
	N rs S rs=$$vOpen8()
	I '$$vFetch8(rs) K vobj(+$G(rs)) Q 
	F i=1:1:28 D  Q:ER 
	.	S sid=$P(vobj(rs),$C(9),$$vRsGetCol(rs,i))
	.	Q:sid="" 
	.	 N V1 S V1=sid I '$$vDbEx6() S ER=1 S RM=$$^MSG(1458,sid) Q 
	.	S sidArray(i)=sid
	.	S scrnum=scrnum+1
	.	I $E(sid,1)="@" Q  ; @[lib]sid
	.	;
	.	N scr,vop1,vop2,vop3 S vop1=%LIBS,vop2=sid,scr=$$vDb6(%LIBS,sid)
	.	 S vop3=$G(^DBTBL(vop1,2,vop2,0))
	.	S file=$P(vop3,$C(124),1)
	.	;
	.	F j=1:1:$L(file,",") D  I ER Q 
	..		S zfile=","_$piece(file,",",j)_","
	..		; Valid relationships?
	..		I mfile[zfile Q 
	..		; Invalid file relationship between ~p1 and ~p2
	..		S ER=1 S RM=$$^MSG(1340,sid,SID)
	..		Q 
	.	Q 
	K vobj(+$G(rs)) Q 
	;
USRVLOD	; User defined VLOD section
	; Insert VCOM first
	;
	N X
	N I
	;
	S X="" F  S X=$order(SCRVLOD(X)) Q:X=""  I SCRVLOD(X)?1"VCOM".E Q 
	I X'="" S X=$order(SCRVLOD(X),-1) F I=1:1 S X=$order(SCRVLOD(X)) Q:X=""  S BLD(Z+I)=SCRVLOD(X) K SCRVLOD(X)
	;
	S Z=$order(BLD(""),-1)+1
	;
	S BLD(Z)=" quit" S BLD(Z+1)="VLODDQ("_vobjlst("formal")_") // Original VLOD section" S BLD(Z+2)=" ;" S Z=Z+3
	Q 
	;
BLD1(AR)	;
	;
	I $E(FILE(AR),1)'="*" D BLX1 Q 
	I '($D(FILER(AR))#2) Q 
	;
	N fid N keys N lastkey N X
	;
	S fid=""
	F  S fid=$order(LOOP(-1,fid)) Q:fid=""!(LOOP(-1,fid)=AR) 
	N dbtbl1,vop1,vop2,vop3 S vop1=%LIBS,vop2=fid,dbtbl1=$$vDb5(%LIBS,fid)
	 S vop3=$G(^DBTBL(vop1,1,vop2,16))
	S keys=$P(vop3,$C(124),1)
	S lastkey=$piece(keys,",",$L(keys,",")) ; get last key
	S X="set "_$E(FILE(AR),2,99)_"="_AR_"("_Q_lastkey_Q_")" D DOUBLE(X)
	S FX(AR)=" set %FILE("_Q_AR_Q_")="_Q_X_Q
	Q 
	;
BLX1	;
	N X
	S X="set X=-"""" for  set X="_AR_"(X).order() quit:X=""  set "_$piece(FILE(AR),")",1)_",X)="_AR_"(X)" D DOUBLE(X)
	S FX(AR)=" set %FILE("_Q_AR_Q_")="_Q_X_Q
	Q 
	;
APPEND	; Append screens, if defined (syntax = @[Library]SID)
	Q 
	;
APPSID	;
	I LIB'=%LIBS S SID="["_LIB_"]"_SID
	Q 
	;
END	;
	Q 
	;
vSIG()	;
	Q "60869^51740^Pete Chenard^18345" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vRsGetCol(object,column)	; Runtime ResultSet.getCol()
	;
	;  #OPTIMIZE FUNCTIONS OFF
	;
	I (column="") Q ""
	I column Q column
	;
	N select S select=($piece(vobj(object,-3)," FROM "))
	N pos S pos=$L($piece((","_select_","),","_column_",",1),",")
	Q pos
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(DBTBL2,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL2"
	S vobj(vOid)=$G(^DBTBL(v1,2,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,2,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL2" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDb3(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL2D,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL2D"
	S vobj(vOid)=$G(^DBTBL(v1,2,v2,v3))
	I '(v3>0)
	E  I vobj(vOid)="",'$D(^DBTBL(v1,2,v2,v3))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDb5(v1,v2)	;	voXN = Db.getRecord(DBTBL1,,0)
	;
	N dbtbl1
	S dbtbl1=$G(^DBTBL(v1,1,v2))
	I dbtbl1="",'$D(^DBTBL(v1,1,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1" X $ZT
	Q dbtbl1
	;
vDb6(v1,v2)	;	voXN = Db.getRecord(DBTBL2,,0)
	;
	N dbtbl2
	S dbtbl2=$G(^DBTBL(v1,2,v2))
	I dbtbl2="",'$D(^DBTBL(v1,2,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL2" X $ZT
	Q dbtbl2
	;
vDbEx1()	;	min(1): DISTINCT LIBS,SID FROM DBTBL2 WHERE LIBS=:%LIBS AND SID=:SID
	;
	N vsql1
	S vsql1=$G(%LIBS) I vsql1="" Q 0
	;
	I '($D(^DBTBL(vsql1,2,SID))) Q 0
	Q 1
	;
vDbEx2()	;	min(1): DISTINCT LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS=:%LIBS AND SID=:SID AND SEQ=0 AND PSEQ=121
	;
	N vsql1
	S vsql1=$G(%LIBS) I vsql1="" Q 0
	;
	I '($D(^DBTBL(vsql1,2,SID,0,121))#2) Q 0
	Q 1
	;
vDbEx3()	;	min(1): DISTINCT LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS=:%LIBS AND SID=:SID AND SEQ=0 AND PSEQ=101
	;
	N vsql1
	S vsql1=$G(%LIBS) I vsql1="" Q 0
	;
	I '($D(^DBTBL(vsql1,2,SID,0,101))#2) Q 0
	Q 1
	;
vDbEx4()	;	min(1): DISTINCT LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS=:%LIBS AND SID=:SID AND SEQ=0 AND PSEQ=121
	;
	N vsql1
	S vsql1=$G(%LIBS) I vsql1="" Q 0
	;
	I '($D(^DBTBL(vsql1,2,SID,0,121))#2) Q 0
	Q 1
	;
vDbEx5()	;	min(1): DISTINCT LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS=:%LIBS AND SID=:SID AND SEQ=0 AND PSEQ=61
	;
	N vsql1
	S vsql1=$G(%LIBS) I vsql1="" Q 0
	;
	I '($D(^DBTBL(vsql1,2,SID,0,61))#2) Q 0
	Q 1
	;
vDbEx6()	;	min(1): DISTINCT LIBS,SID FROM DBTBL2 WHERE LIBS=:%LIBS AND SID=:V1
	;
	N vsql1
	S vsql1=$G(%LIBS) I vsql1="" Q 0
	;
	I '($D(^DBTBL(vsql1,2,V1))) Q 0
	Q 1
	;
vKill1(ex1)	;	Delete objects dbtbl2d()
	;
	N n1 S (n1)=""
	F  S n1=$O(dbtbl2d(n1)) Q:n1=""  K:'((n1=ex1)) vobj(dbtbl2d(n1))
	Q
	;
vKill2(ex1)	;	Delete objects dbtblpp()
	;
	N n1 S (n1)=""
	F  S n1=$O(dbtblpp(n1)) Q:n1=""  K:'((n1=ex1)) vobj(dbtblpp(n1))
	Q
	;
vOpen1()	;	LNK1,LNK2,LNK3,LNK4,LNK5,LNK6,LNK7,LNK8,LNK9,LNK10,LNK11,LNK12,LNK13,LNK14,LNK15,LNK16,LNK17,LNK18,LNK19,LNK20,LNK21,LNK22,LNK23,LNK24,LNK25,LNK26,LNK27,LNK28 FROM DBTBL2 WHERE LIBS=:%LIBS AND SID=:SID
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(%LIBS) I vos2="" G vL1a0
	S vos3=$G(SID) I vos3="" G vL1a0
	I '($D(^DBTBL(vos2,2,vos3))) G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	I vos1=0 Q 0
	;
	S vos1=100
	S vos4=$G(^DBTBL(vos2,2,vos3,-1))
	S rs=$P(vos4,"|",1)_$C(9)_$P(vos4,"|",2)_$C(9)_$P(vos4,"|",3)_$C(9)_$P(vos4,"|",4)_$C(9)_$P(vos4,"|",5)_$C(9)_$P(vos4,"|",6)_$C(9)_$P(vos4,"|",7)_$C(9)_$P(vos4,"|",8)_$C(9)_$P(vos4,"|",9)_$C(9)_$P(vos4,"|",10)
	S rs=rs_$C(9)_$P(vos4,"|",11)_$C(9)_$P(vos4,"|",12)_$C(9)_$P(vos4,"|",13)_$C(9)_$P(vos4,"|",14)_$C(9)_$P(vos4,"|",15)_$C(9)_$P(vos4,"|",16)_$C(9)_$P(vos4,"|",17)_$C(9)_$P(vos4,"|",18)_$C(9)_$P(vos4,"|",19)_$C(9)_$P(vos4,"|",20)
	S rs=rs_$C(9)_$P(vos4,"|",21)_$C(9)_$P(vos4,"|",22)_$C(9)_$P(vos4,"|",23)_$C(9)_$P(vos4,"|",24)_$C(9)_$P(vos4,"|",25)_$C(9)_$P(vos4,"|",26)_$C(9)_$P(vos4,"|",27)_$C(9)_$P(vos4,"|",28)
	S vos1=0
	;
	Q 1
	;
vOpen2()	;	LIBS,SID,SEQ FROM DBTBL2D WHERE LIBS=:%LIBS AND SID=:SID AND SEQ>0
	;
	N vOid
	;
	S vOid=$O(vobj(""),-1)+1
	S vobj(vOid,0)=2
	S vobj(vOid,-1)="ResultSet"
	S vobj(vOid,-2)="$$vFetch2^"_$T(+0)
	S vobj(vOid,-3)="LIBS,SID,SEQ"
	S vobj(vOid,-4)="T0T0N0"
	D vL2a1
	Q vOid
	;
vL2a0	S vobj(vOid,0)=0 Q
vL2a1	S vobj(vOid,1)=$G(%LIBS) I vobj(vOid,1)="" G vL2a0
	S vobj(vOid,2)=$G(SID) I vobj(vOid,2)="" G vL2a0
	S vobj(vOid,3)=0
vL2a4	S vobj(vOid,3)=$O(^DBTBL(vobj(vOid,1),2,vobj(vOid,2),vobj(vOid,3)),1) I vobj(vOid,3)="" G vL2a0
	Q
	;
vFetch2(vOid)	;
	;
	;
	I vobj(vOid,0)=1 D vL2a4
	I vobj(vOid,0)=2 S vobj(vOid,0)=1
	;
	I vobj(vOid,0)=0 Q 0
	;
	S vobj(vOid)=vobj(vOid,1)_$C(9)_vobj(vOid,2)_$C(9)_$S(vobj(vOid,3)=$C(254):"",1:vobj(vOid,3))
	;
	Q 1
	;
vOpen3()	;	LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS='SYSDEV' AND SID=:SID AND SEQ=0
	;
	N vOid
	;
	S vOid=$O(vobj(""),-1)+1
	S vobj(vOid,0)=2
	S vobj(vOid,-1)="ResultSet"
	S vobj(vOid,-2)="$$vFetch3^"_$T(+0)
	S vobj(vOid,-3)="LIBS,SID,SEQ,PSEQ"
	S vobj(vOid,-4)="T0T0N3N3"
	D vL3a1
	Q vOid
	;
vL3a0	S vobj(vOid,0)=0 Q
vL3a1	S vobj(vOid,1)=$G(SID) I vobj(vOid,1)="" G vL3a0
	S vobj(vOid,2)=""
vL3a3	S vobj(vOid,2)=$O(^DBTBL("SYSDEV",2,vobj(vOid,1),0,vobj(vOid,2)),1) I vobj(vOid,2)="" G vL3a0
	Q
	;
vFetch3(vOid)	;
	;
	;
	I vobj(vOid,0)=1 D vL3a3
	I vobj(vOid,0)=2 S vobj(vOid,0)=1
	;
	I vobj(vOid,0)=0 Q 0
	;
	S vobj(vOid)="SYSDEV"_$C(9)_vobj(vOid,1)_$C(9)_0_$C(9)_$S(vobj(vOid,2)=$C(254):"",1:vobj(vOid,2))
	;
	Q 1
	;
vOpen4()	;	LIBS,SID,SEQ FROM DBTBL2D WHERE LIBS='SYSDEV' AND SID=:SID AND SEQ>0
	;
	N vOid
	;
	S vOid=$O(vobj(""),-1)+1
	S vobj(vOid,0)=2
	S vobj(vOid,-1)="ResultSet"
	S vobj(vOid,-2)="$$vFetch4^"_$T(+0)
	S vobj(vOid,-3)="LIBS,SID,SEQ"
	S vobj(vOid,-4)="T0T0N0"
	D vL4a1
	Q vOid
	;
vL4a0	S vobj(vOid,0)=0 Q
vL4a1	S vobj(vOid,1)=$G(SID) I vobj(vOid,1)="" G vL4a0
	S vobj(vOid,2)=0
vL4a3	S vobj(vOid,2)=$O(^DBTBL("SYSDEV",2,vobj(vOid,1),vobj(vOid,2)),1) I vobj(vOid,2)="" G vL4a0
	Q
	;
vFetch4(vOid)	;
	;
	;
	I vobj(vOid,0)=1 D vL4a3
	I vobj(vOid,0)=2 S vobj(vOid,0)=1
	;
	I vobj(vOid,0)=0 Q 0
	;
	S vobj(vOid)="SYSDEV"_$C(9)_vobj(vOid,1)_$C(9)_$S(vobj(vOid,2)=$C(254):"",1:vobj(vOid,2))
	;
	Q 1
	;
vOpen5()	;	LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS=:%LIBS AND SID=:SID AND SEQ=:SEQ
	;
	;
	S vos1=2
	D vL5a1
	Q ""
	;
vL5a0	S vos1=0 Q
vL5a1	S vos2=$G(%LIBS) I vos2="" G vL5a0
	S vos3=$G(SID) I vos3="" G vL5a0
	S vos4=$G(SEQ) I vos4="" G vL5a0
	S vos4=+vos4
	S vos5=""
vL5a6	S vos5=$O(^DBTBL(vos2,2,vos3,vos4,vos5),1) I vos5="" G vL5a0
	Q
	;
vFetch5()	;
	;
	;
	I vos1=1 D vL5a6
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds2=vos2_$C(9)_vos3_$C(9)_vos4_$C(9)_$S(vos5=$C(254):"",1:vos5)
	;
	Q 1
	;
vOpen6()	;	LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS=:%LIBS AND SID=:SID AND SEQ=0 AND PSEQ BETWEEN 101 AND 120
	;
	;
	S vos1=2
	D vL6a1
	Q ""
	;
vL6a0	S vos1=0 Q
vL6a1	S vos2=$G(%LIBS) I vos2="" G vL6a0
	S vos3=$G(SID) I vos3="" G vL6a0
	S vos4=101
	I $D(^DBTBL(vos2,2,vos3,0,vos4)),'(vos4>120) G vL6a6
vL6a5	S vos4=$O(^DBTBL(vos2,2,vos3,0,vos4),1) I vos4=""!(vos4>120) G vL6a0
vL6a6	Q
	;
vFetch6()	;
	;
	;
	I vos1=1 D vL6a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds=vos2_$C(9)_vos3_$C(9)_0_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen7()	;	LIBS,SID,SEQ,PSEQ FROM DBTBL2PP WHERE LIBS=:%LIBS AND SID=:SID AND SEQ=0 AND PSEQ BETWEEN :X AND :X2
	;
	;
	S vos1=2
	D vL7a1
	Q ""
	;
vL7a0	S vos1=0 Q
vL7a1	S vos2=$G(%LIBS) I vos2="" G vL7a0
	S vos3=$G(SID) I vos3="" G vL7a0
	S vos4=$G(X) I vos4="",'$D(X) G vL7a0
	S vos5=$G(X2) I vos5="",'$D(X2) G vL7a0
	S vos6=vos4
	I $D(^DBTBL(vos2,2,vos3,0,vos6)),'(vos6>vos5) G vL7a8
vL7a7	S vos6=$O(^DBTBL(vos2,2,vos3,0,vos6),1) I vos6=""!(vos6>vos5) G vL7a0
vL7a8	Q
	;
vFetch7()	;
	;
	;
	I vos1=1 D vL7a7
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds=vos2_$C(9)_vos3_$C(9)_0_$C(9)_$S(vos6=$C(254):"",1:vos6)
	;
	Q 1
	;
vOpen8()	;	LNK1,LNK2,LNK3,LNK4,LNK5,LNK6,LNK7,LNK8,LNK9,LNK10,LNK11,LNK12,LNK13,LNK14,LNK15,LNK16,LNK17,LNK18,LNK19,LNK20,LNK21,LNK22,LNK23,LNK24,LNK25,LNK26,LNK27,LNK28 FROM DBTBL2 WHERE LIBS=:%LIBS AND SID=:SID
	;
	N vOid
	;
	S vOid=$O(vobj(""),-1)+1
	S vobj(vOid,0)=2
	S vobj(vOid,-1)="ResultSet"
	S vobj(vOid,-2)="$$vFetch8^"_$T(+0)
	S vobj(vOid,-3)="LNK1,LNK2,LNK3,LNK4,LNK5,LNK6,LNK7,LNK8,LNK9,LNK10,LNK11,LNK12,LNK13,LNK14,LNK15,LNK16,LNK17,LNK18,LNK19,LNK20,LNK21,LNK22,LNK23,LNK24,LNK25,LNK26,LNK27,LNK28"
	S vobj(vOid,-4)="U0U0U0U0U0U0U0U0U0U0U0U0U0U0U0U0U0U0U0U0U0U0U0U0U0U0U0U0"
	D vL8a1
	Q vOid
	;
vL8a0	S vobj(vOid,0)=0 Q
vL8a1	S vobj(vOid,1)=$G(%LIBS) I vobj(vOid,1)="" G vL8a0
	S vobj(vOid,2)=$G(SID) I vobj(vOid,2)="" G vL8a0
	I '($D(^DBTBL(vobj(vOid,1),2,vobj(vOid,2)))) G vL8a0
	Q
	;
vFetch8(vOid)	;
	;
	N vsql3
	;
	I vobj(vOid,0)=0 Q 0
	;
	S vobj(vOid,0)=100
	S vsql3=$G(^DBTBL(vobj(vOid,1),2,vobj(vOid,2),-1))
	S vobj(vOid)=$P(vsql3,"|",1)_$C(9)_$P(vsql3,"|",2)_$C(9)_$P(vsql3,"|",3)_$C(9)_$P(vsql3,"|",4)_$C(9)_$P(vsql3,"|",5)_$C(9)_$P(vsql3,"|",6)_$C(9)_$P(vsql3,"|",7)_$C(9)_$P(vsql3,"|",8)_$C(9)_$P(vsql3,"|",9)_$C(9)_$P(vsql3,"|",10)
	S vobj(vOid)=vobj(vOid)_$C(9)_$P(vsql3,"|",11)_$C(9)_$P(vsql3,"|",12)_$C(9)_$P(vsql3,"|",13)_$C(9)_$P(vsql3,"|",14)_$C(9)_$P(vsql3,"|",15)_$C(9)_$P(vsql3,"|",16)_$C(9)_$P(vsql3,"|",17)_$C(9)_$P(vsql3,"|",18)_$C(9)_$P(vsql3,"|",19)_$C(9)_$P(vsql3,"|",20)
	S vobj(vOid)=vobj(vOid)_$C(9)_$P(vsql3,"|",21)_$C(9)_$P(vsql3,"|",22)_$C(9)_$P(vsql3,"|",23)_$C(9)_$P(vsql3,"|",24)_$C(9)_$P(vsql3,"|",25)_$C(9)_$P(vsql3,"|",26)_$C(9)_$P(vsql3,"|",27)_$C(9)_$P(vsql3,"|",28)
	S vobj(vOid,0)=0
	;
	Q 1
