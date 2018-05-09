 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSRW ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSRW(RID,NOMSG,PGM) ; Generated program name /NOREQ/MECH=REFNAM:W
 N vTp
 ;
  S ER=0
 N N N SORTFLG
 N CODE N CMPERR N ddmap N PQINFO N PSLCODE N RPTINFO N VARLIST N WHERE
 ;
 D INIT^%ZM()
 ;
 I '($D(^DBTBL("SYSDEV",5,RID))) D  Q 
 .	S ER=1
 .	; Invalid report ~p1
 .	S RM=$$^MSG(8074,RID)
 .	Q 
 ;
 N cuvar S cuvar=$$vRCgetRecord0Opt^RecordCUVAR(0,"")
  S cuvar=$G(^CUVAR("DBS"))
 S RPTINFO("CUVAR","FLDOVF")=$P(cuvar,$C(124),1)
 ;
 N dbtbl5h S dbtbl5h=$$vRCgetRecord0^RecordDBTBL5H("SYSDEV",RID,0)
  S vobj(dbtbl5h,0)=$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),0))
 ;
 I '$get(NOMSG) WRITE !,RID,?15,$P(vobj(dbtbl5h),$C(124),1),!
 ;
 ; Get run-time program name, update report header if necessary
 S PGM=$P(vobj(dbtbl5h,0),$C(124),2)
 I PGM="" D  ; Need to assign name
 .	;
 .	N LIBNO N NEXTRPT
 .	;
 . TS (vobj):transactionid="CS"
 .	;
 .	N libno,vop1 S libno=$$vRCgetRecord1Opt^RecordDBTBL0("SYSDEV","L",0,.vop1)
 .	I ($G(vop1)=0) S LIBNO=101
 .	E  S LIBNO=100+$P(libno,$C(124),1)
 .	;
 .	N dbtbl0 S dbtbl0=$$vRCgetRecord1^RecordDBTBL0("SYSDEV","R",0)
 .	;
 .	N dbtbl5h S dbtbl5h=$$vRCgetRecord0^RecordDBTBL5H("SYSDEV",RID,0)
 .	 S vobj(dbtbl5h,0)=$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),0))
 .	;
 .	I $P(vobj(dbtbl0),$C(124),1)=""  S:'$D(vobj(dbtbl0,-100,"0*","DESC")) vobj(dbtbl0,-100,"0*","DESC")="N001"_$P(vobj(dbtbl0),$C(124),1),vobj(dbtbl0,-100,"0*")="" S $P(vobj(dbtbl0),$C(124),1)=1
 .	S NEXTRPT=$P(vobj(dbtbl0),$C(124),1)  S:'$D(vobj(dbtbl0,-100,"0*","DESC")) vobj(dbtbl0,-100,"0*","DESC")="N001"_$P(vobj(dbtbl0),$C(124),1),vobj(dbtbl0,-100,"0*")="" S $P(vobj(dbtbl0),$C(124),1)=NEXTRPT+1
 .	S PGM="R"_$E(LIBNO,2,3)_"S"
 .	I NEXTRPT<1000 S PGM=PGM_$E((1000+NEXTRPT),2,4)
 .	E  S PGM=PGM_NEXTRPT
 .  S:'$D(vobj(dbtbl5h,-100,0,"PGM")) vobj(dbtbl5h,-100,0,"PGM")="T002"_$P(vobj(dbtbl5h,0),$C(124),2),vobj(dbtbl5h,-100,0)="" S $P(vobj(dbtbl5h,0),$C(124),2)=PGM
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL5H(dbtbl5h,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbtbl5h,-100) S vobj(dbtbl5h,-2)=1 TC:vTp  
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL0(dbtbl0,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbtbl0,-100) S vobj(dbtbl0,-2)=1 TC:vTp  
 .	;
 .  TC:$TL 
 . K vobj(+$G(dbtbl0)),vobj(+$G(dbtbl5h)) Q 
 ;
 ; Re-load record after potential updates above
  K vobj(+$G(dbtbl5h)) S dbtbl5h=$$vRCgetRecord0^RecordDBTBL5H("SYSDEV",RID,0)
  S vobj(dbtbl5h,0)=$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),0))
 ;
 S RPTINFO("DISTKEY")=$P(vobj(dbtbl5h,0),$C(124),20) ; Distribution key, if any
 S RPTINFO("FIXLEN")=$P(vobj(dbtbl5h,0),$C(124),8) ; Tape format - fixed length
 S RPTINFO("RESFLG")=$P(vobj(dbtbl5h,0),$C(124),7) ; Data item protection logic option
 S RPTINFO("RSIZE")=$P(vobj(dbtbl5h,0),$C(124),5) ; Width
 S RPTINFO("DYNORDERBY")=0 ; Dynamic order by flag
 S RPTINFO("DYNWHERE")=0 ; User defined where flag
 ;
 ; Get prompt/query info
 S RM=$$^DBSRWQRY(.dbtbl5h,.PQINFO,.WHERE)
  S:'$D(vobj(dbtbl5h,0)) vobj(dbtbl5h,0)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),0)),1:"")
 I RM'="" S ER=1 K vobj(+$G(dbtbl5h)) Q  ; Query syntax error
 S RPTINFO("WHERE")=WHERE
 S RPTINFO("QUERIES")=PQINFO ; Are there any queries
 ;
 S RPTINFO("TABLES")=$P(vobj(dbtbl5h,0),$C(124),1)
 ;
 ; Turn off RESFLG if the files aren't set up for protection
 I RPTINFO("RESFLG") D
 .	N HIT S HIT=0
 .	N I
 .	N FID N PGM
 .	;
 .	F I=1:1 S FID=$piece(RPTINFO("TABLES"),",",I) Q:(FID="")  D
 ..		;
 ..		S PGM=$$PGM^UPID(FID)
 ..		I $$VALID^%ZRTNS(PGM) S HIT=1
 ..		Q 
 .	;
 .	I 'HIT S RPTINFO("RESFLG")=0
 .	Q 
 ;
 ; Construct the report code in sections
 D GETSEQBY(.dbtbl5h,.RPTINFO) ; Get sequence by info
 D GETRPPS(RID,.RPTINFO,.ddmap) K:ER vobj(+$G(dbtbl5h)) Q:ER  ; Get report pre/post-processors
 ;
 ; Initialization, report pre-process (before query), prompts
 ; and UTLREAD call
 D BLDBEGIN(.dbtbl5h,.PQINFO,.RPTINFO,.ddmap,.VARLIST)
 D BLDV0(.dbtbl5h,.RPTINFO,.ddmap,.VARLIST) ; V0 section
  S:'$D(vobj(dbtbl5h,0)) vobj(dbtbl5h,0)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),0)),1:"")
 ;
 ; If requires dynamic queries, add code to set them up
 I RPTINFO("WHERE")="",RPTINFO("QUERIES") D BLDDYNWH(RPTINFO("TABLES"),.PQINFO)
 ;
 I $P(vobj(dbtbl5h,0),$C(124),16) D BLDBANNR(.PQINFO,.RPTINFO,.dbtbl5h) ; Banner
  S:'$D(vobj(dbtbl5h,0)) vobj(dbtbl5h,0)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),0)),1:"")
 I $P(vobj(dbtbl5h,0),$C(124),17) D BLDALIGN(RID,.RPTINFO) ; Alignment
 D ^DBSRW2(.dbtbl5h,.ddmap,.RPTINFO,.PQINFO) K:ER vobj(+$G(dbtbl5h)) Q:ER  ; Part 2 of construction
 D ^DBSRW3(.dbtbl5h,.ddmap,.RPTINFO) ; Part 3 of construction
 ;
 I RPTINFO("DISTKEY")'="" D BLDVMAP(.RPTINFO) ; Build VMAP code
 ;
 ; Add typing for collected variables - make sure number of variables per line
 ; is not too great or get MAXARGCNT error
 S CODE=$$newlist^DBSRWUTL("V0",.RPTINFO,.ddmap,"CONAM,RID,RN,%TIM,vCOL,vHDG,VL,VLOF,VRF(),vrundate,VSTATS(),vsysdate","VFMQ,VPN,"_$$newlist^DBSRWUTL("MAINVARS",.RPTINFO,.ddmap))
 S N=RPTINFO("V0TYPE")
 F  D  Q:(CODE="") 
 .	D addcode^DBSRWUTL(1,"type String "_$piece(CODE,",",1,100),N)
 .	S CODE=$piece(CODE,",",101,$L(CODE))
 .	S N=N+.01
 .	Q 
 ;
 ; Build routine header
 S CODE=PGM_$char(9)_"// "_RID_" - "_$P(vobj(dbtbl5h),$C(124),1)
 D addcode^DBSRWUTL(0,CODE,0)
 D ^SCACOPYR(.CODE)
 I CODE?1" ;;".E S CODE="// "_$E(CODE,4,999)
 D addcode^DBSRWUTL(1,CODE,0.1)
 ;
 ; Call PSL compiler
 D cmpA2F^UCGM(.PSLCODE,PGM,,,,,.CMPERR,RID_"~Report")
 ;
 I +$get(CMPERR) S ER=1 ; Hard compile errors
 ;
 K vobj(+$G(dbtbl5h)) Q 
 ;
BLDBEGIN(dbtbl5h,PQINFO,RPTINFO,ddmap,VARLIST) ; 
 ;
 N MAXPRMPT
 N CODE N READ N SEQ N SUPP N TAB N TYPE N X
 ;
 S (READ,SEQ)="" S MAXPRMPT=0
 ;
 ; IO info
 S TAB("IO")="$$IO^SCATAB"
 ;
 F  S SEQ=$order(PQINFO(SEQ)) Q:SEQ=""  D
 .	N DT N PQTYPE N PROMPT N REQ N TABINFO N TYPNAM N VAR
 .	;
 .	S VAR=$piece(PQINFO(SEQ),"|",1)
 .	Q:VAR="" 
 .	;
 .	S PQTYPE=$piece(PQINFO(SEQ),"|",2)
 .	S TABINFO=$get(PQINFO(SEQ,1))
 .	;
 .	; Build typing and default info
 .	S DT=$piece(TABINFO,"|",9)
 .	I DT="" S DT="T"
 .	I "N$L"[DT S TYPNAM="Number"
 .	E  I DT="D" S TYPNAM="Date"
 .	E  S TYPNAM="String"
 .	S TYPE(VAR)="type "_TYPNAM_" "_VAR
 .	S VARLIST(TYPNAM)=$get(VARLIST(TYPNAM))_VAR_","
 .	; Add to variables to exclude from V0 list
 .	D addvars^DBSRWUTL("V0EXCLUDE",VAR,.RPTINFO)
 .	; Set default, if there is one
 .	I $piece(TABINFO,"|",3)'="" D
 ..		N DEFAULT
 ..		;
 ..		S DEFAULT=$piece(TABINFO,"|",3)
 ..		S TYPE(VAR)=TYPE(VAR)_"="_DEFAULT
 ..		; If variable, not literal, add .get() and treat as an incoming variable
 ..		I DEFAULT?1A.AN D
 ...			S TYPE(VAR)=TYPE(VAR)_".get()"
 ...			D addvars^DBSRWUTL("INCOMING",DEFAULT,.RPTINFO)
 ...			Q 
 ..		Q 
 .	;
 .	; Build %READ
 .	S READ=READ_VAR_"#"
 .	S REQ=+$piece(TABINFO,"|",11) ; 1 = required
 .	S READ=READ_REQ_","
 .	;
 .	; Pull code to suppress prompts -- only valid for user variables
 .	I $piece(TABINFO,"|",15)'="",PQTYPE="UV" S SUPP(VAR)=REQ_"|"_$piece(TABINFO,"|",15)
 .	;
 .	; Update tab info
 .	S $piece(TABINFO,"|",3)="" ; Remove default
 .	S $piece(TABINFO,"|",11)="" ; Remove required
 .	S $piece(TABINFO,"|",15)="" ; Suppress code
 .	S PROMPT=$piece(TABINFO,"|",10)
 .	I $L(PROMPT)>37 D
 ..		S $piece(TABINFO,"|",10)=$E(PROMPT,1,37)
 ..		S MAXPRMPT=37
 ..		Q 
 .	E  I $L(PROMPT)>MAXPRMPT S MAXPRMPT=$L(PROMPT)
 .	;
 .	; Save %TAB info - add quotes
 .	S TAB(VAR)=$S(TABINFO'["""":""""_TABINFO_"""",1:$$QADD^%ZS(TABINFO,""""))
 .	Q 
 ;
 D addcode^DBSRWUTL(0,"")
 ;
 ; Type standard report variables
 D addcode^DBSRWUTL(1,"type public Number ER=0")
 D addcode^DBSRWUTL(1,"type public Number vbatchq")
 S CODE="type public String IO,RM,VRWOPT()"
 I RPTINFO("DISTKEY")'="" S CODE=CODE_",VTBLNAM"
 D addcode^DBSRWUTL(1,CODE)
 ;
 S RPTINFO("MAINEXCLUDE")="%READ,%TAB,ER,OLNTB,IO,RID,RN,RM,vbatchq,VFMQ,VRWOPT"
 S CODE=$$newlist^DBSRWUTL("INCOMING",.RPTINFO,.ddmap)
 I CODE'="" D addcode^DBSRWUTL(1,"type public String "_CODE)
 S CODE=$$newlist^DBSRWUTL("MAINVARS",.RPTINFO,.ddmap,"",RPTINFO("MAINEXCLUDE")_","_$get(VARLIST("String")))
 I CODE'="" D addcode^DBSRWUTL(1,"type String "_CODE)
 ;
 D addcode^DBSRWUTL(1,"type Number OLNTB")
 D addcode^DBSRWUTL(1,"type String %READ,RID,RN,%TAB,VFMQ")
 ;
 ; Add typing and initialization data
 S SEQ=""
 F  S SEQ=$order(TYPE(SEQ)) Q:SEQ=""  D addcode^DBSRWUTL(1,TYPE(SEQ))
 ;
 D addcode^DBSRWUTL(0,"")
 ;
 ; Define standard variables
 D addcode^DBSRWUTL(1,"set RID="""_vobj(dbtbl5h,-4)_"""")
 D addcode^DBSRWUTL(1,"set RN="""_$P(vobj(dbtbl5h),$C(124),1)_"""")
 D addcode^DBSRWUTL(1,"if IO.get()="""" set IO=$I")
 ;
 D addcode^DBSRWUTL(0,"")
 ;
 D addcode^DBSRWUTL(1,"do INIT^%ZM()")
 ;
 D addcode^DBSRWUTL(0,"")
 ;
 ; If pre-processor (before query) insert call
 I '($order(RPTINFO("SUBS","PREBQ",""))="") D
 .	D addcode^DBSRWUTL(1,"do VPREBQ quit:VFMQ.get()"_$char(9)_"// Pre-processor (before query)")
 .	D addcode^DBSRWUTL(0,"")
 .	Q 
 ;
 ; Add %TAB sets
 F  S SEQ=$order(TAB(SEQ)) Q:SEQ=""  D
 .	;
 .	N tabcode
 .	;
 .	; Handle possibility of MIN or MAX being variable insertion
 .	S tabcode=TAB(SEQ)
 .	;
 .	I ($E($piece(tabcode,"|",12),1,2)="<<") D
 ..		;
 ..		N min S min=$piece(tabcode,"|",12)
 ..		;
 ..		S min=$E(min,3,$L(min)-2) ; Strip << >>
 ..		;
 ..		S tabcode=$piece(tabcode,"|",1,11)_"|""_("_min_")_""|"_$piece(tabcode,"|",13,999)
 ..		Q 
 .	;
 .	I ($E($piece(tabcode,"|",13),1,2)="<<") D
 ..		;
 ..		N max S max=$piece(tabcode,"|",13)
 ..		;
 ..		S max=$E(max,3,$L(max)-2) ; Strip << >>
 ..		;
 ..		S tabcode=$piece(tabcode,"|",1,12)_"|""_("_max_")_""|"_$piece(tabcode,"|",14,999)
 ..		Q 
 .	;
 .	D addcode^DBSRWUTL(1,"set %TAB("""_SEQ_""")="_tabcode)
 .	Q 
 ;
 D addcode^DBSRWUTL(0,"")
 ;
 ; Set up %READ
 D addcode^DBSRWUTL(1,"set %READ=""IO/REQ,"_READ_"""")
 D addcode^DBSRWUTL(0,"")
 D addcode^DBSRWUTL(1,"// Skip device prompt option")
 D addcode^DBSRWUTL(1,"if VRWOPT(""NOOPEN"").get() set %READ=%READ.piece("","",2,99)")
 ;
 D addcode^DBSRWUTL(0,"")
 ;
 ; Add code to conditionally suppress prompts
 F  S SEQ=$order(SUPP(SEQ)) Q:SEQ=""  D
 .	N CODE N FIND N REQ
 .	S REQ=$piece(SUPP(SEQ),"|",1)
 .	S CODE=$piece(SUPP(SEQ),"|",2,999)
 .	S FIND=","_SEQ_"#"_REQ_","
 .	D addcode^DBSRWUTL(1,"// Conditionally suppress prompt for "_SEQ)
 .	D addcode^DBSRWUTL(1,CODE_" do {")
 .	D addcode^DBSRWUTL(2,"set %READ="",""_%READ")
 .	D addcode^DBSRWUTL(2,"set %READ=%READ.piece("""_FIND_""",1)_"",""_%READ.piece("""_FIND_""",2)")
 .	D addcode^DBSRWUTL(2,"set %READ=%READ.piece("","",2,99)")
 .	D addcode^DBSRWUTL(2,"}")
 .	D addcode^DBSRWUTL(0,"")
 .	Q 
 ;
 ; Set up call to UTLREAD
 I MAXPRMPT<27 S MAXPRMPT=30
 E  S MAXPRMPT=MAXPRMPT+3
 ;
 ; Add report name to %READ at runtime if any prompts remain
 D addcode^DBSRWUTL(1,"set VFMQ=""""")
 D addcode^DBSRWUTL(1,"if %READ'="""" do { quit:VFMQ.get()=""Q""")
 D addcode^DBSRWUTL(2,"set OLNTB="_MAXPRMPT)
 D addcode^DBSRWUTL(2,"set %READ=""@RN/CEN#1,,""_%READ")
 D addcode^DBSRWUTL(2,"do ^UTLREAD")
 D addcode^DBSRWUTL(2,"}")
 ;
 D addcode^DBSRWUTL(0,"")
 ;
 ; If batch mode query prompts, don't continue
 D addcode^DBSRWUTL(1,"if 'vbatchq.get() do V0")
 D addcode^DBSRWUTL(1,"quit")
 D addcode^DBSRWUTL(0,"")
 ;
 Q 
 ;
BLDV0(dbtbl5h,RPTINFO,ddmap,VARLIST) ; 
 ;
 ; Build V0 section, which is external entry point
 ;
 N I
 N CODE N DT N NONZRID N X
 ;
 ; Access report through job queue at V0 entry point
 D addcode^DBSRWUTL(0,"V0"_$C(9)_"// External report entry point") ; job queue
 D addcode^DBSRWUTL(0,"")
 ;
 ; Keep list of public and internal variables to avoid typing them as part of V0TYPE
 F I=1:1 D  Q:X="" 
 .	S X=$piece("AUXPTR,ER,VTBLNAM,IO,IOPAR,IOSL,IOTYP,%MSDK,RM,VDISTKEY,VPN,VRWOPT",",",I)
 .	I X'="" D addvars^DBSRWUTL("V0EXCLUDE",X,.RPTINFO)
 .	Q 
 ;
 I '($order(RPTINFO("SUBS","FPOST",""))="") D addcode^DBSRWUTL(1,"type Boolean VHIT")
 ;
 D addcode^DBSRWUTL(1,"type public Number AUXPTR,ER,VTBLNAM")
 D addcode^DBSRWUTL(1,"type public String IO,IOPAR,IOSL,IOTYP,%MSKD,RM,VDISTKEY,VRWOPT()")
 ;
 ; Public typing for variables from report pre-processor (before query)
 S CODE=$$newlist^DBSRWUTL("INCOMING",.RPTINFO,.ddmap)
 I CODE'="" D addcode^DBSRWUTL(1,"type public String "_CODE)
 S CODE=$$newlist^DBSRWUTL("MAINVARS",.RPTINFO,.ddmap,"",RPTINFO("MAINEXCLUDE")_","_$get(VARLIST("String")))
 I CODE'="" D addcode^DBSRWUTL(1,"type public String "_CODE)
 ;
 ; Add public typing for other variables defined in UTLREAD section
 S DT=""
 F  S DT=$order(VARLIST(DT)) Q:DT=""  D
 .	N CODE
 .	S CODE="type public "_DT_" "_VARLIST(DT)
 .	S CODE=$E(CODE,1,$L(CODE)-1)
 .	D addcode^DBSRWUTL(1,CODE)
 .	Q 
 ;
 ; Add typing for other variables used
 D addcode^DBSRWUTL(1,"type Number vcrt,VD(),VFMQ,vh(),vI,vlc,VLC,VNEWHDR,VOFFLG,VPN,VR,VRG,vs(),VSEQ,VT()")
 ;
 I (RPTINFO("WHERE")="")!RPTINFO("DYNORDERBY")!RPTINFO("DYNWHERE") D addcode^DBSRWUTL(1,"type String VWHERE")
 I (RPTINFO("WHERE")="")!RPTINFO("DYNORDERBY")!RPTINFO("DYNWHERE") D addcode^DBSRWUTL(1,"type Literal String VSELECT")
 ;
 D
 .	N LINENO S LINENO=""
 .	D addcode^DBSRWUTL(1,"// Placeholder for other variable typing",.LINENO)
 .	S RPTINFO("V0TYPE")=LINENO
 .	Q 
 ;
 ; Remove leading z, if any, from report ID
 S NONZRID=vobj(dbtbl5h,-4)
 I $E(NONZRID,1)="z" S NONZRID=$E(NONZRID,2,99)
 ;
 D addcode^DBSRWUTL(0,"")
 ;
 ; Only need to instantiate CUVAR if using run-time info from it for banner
 ; or alignment
  S:'$D(vobj(dbtbl5h,0)) vobj(dbtbl5h,0)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),0)),1:"")
 I $P(vobj(dbtbl5h,0),$C(124),16)!$P(vobj(dbtbl5h,0),$C(124),17) D
 .	D addcode^DBSRWUTL(1,"type RecordCUVAR cuvar=Db.getRecord(""CUVAR"")")
 .	D addcode^DBSRWUTL(0,"")
 .	Q 
 ;
 D addcode^DBSRWUTL(1,"set CONAM=CUVAR.conam")
 D addcode^DBSRWUTL(1,"set ER=0,RID="""_NONZRID_""",RN="""_$P(vobj(dbtbl5h),$C(124),1)_"""")
 D addcode^DBSRWUTL(1,"set VL=""""")
 D addcode^DBSRWUTL(0,"")
 ;
 D addcode^DBSRWUTL(1,"use 0 if 'VRWOPT(""NOOPEN"").get() do { quit:ER")
 D addcode^DBSRWUTL(2,"if 'VRWOPT(""IOPAR"").get().isNull() set IOPAR = VRWOPT(""IOPAR"")")
 D addcode^DBSRWUTL(2,"else  if ((IOTYP.get()=""RMS"")!(IOTYP.get()=""PNTQ"")),('IOPAR.get().isLike(""%/OCHSET=%"")),$$VALID^%ZRTNS(""UCIOENCD"") do {")
 D addcode^DBSRWUTL(3,"// Accept warning if ^UCIOENCD does not exist")
 D addcode^DBSRWUTL(3,"#ACCEPT Date=07/26/06; Pgm=RussellDS; CR=22121; Group=ACCESS")
 D addcode^DBSRWUTL(3,"type String CHRSET=$$^UCIOENCD(""Report"","""_NONZRID_""",""V0"",""*"")")
 D addcode^DBSRWUTL(3,"if 'CHRSET.isNull() set IOPAR = IOPAR_""/OCHSET=""_CHRSET")
 D addcode^DBSRWUTL(2,"}")
 I (RPTINFO("RSIZE")>512) D addcode^DBSRWUTL(2,"if IOPAR'[""RECORDSIZE"" set IOPAR=IOPAR_""/RECORDSIZE="_RPTINFO("RSIZE")_"""")
 D addcode^DBSRWUTL(2,"do OPEN^SCAIO")
 D addcode^DBSRWUTL(1,"}")
 ;
 D addcode^DBSRWUTL(1,"set vcrt=(IOTYP=""TRM"")")
 D addcode^DBSRWUTL(1,"if 'vcrt set IOSL="_$P(vobj(dbtbl5h,0),$C(124),6)_$C(9)_"// Non-interactive")
 D addcode^DBSRWUTL(1,"else  do {"_$C(9)_"// Interactive")
 D addcode^DBSRWUTL(2,"do TERM^%ZUSE(IO,""WIDTH="_(RPTINFO("RSIZE")+1)_""")")
 D addcode^DBSRWUTL(2,"#ACCEPT Date=10/13/2008;Pgm=RussellDS;CR=35741;Group=READ")
 D addcode^DBSRWUTL(2,"write $$CLEARXY^%TRMVT")
 I RPTINFO("RSIZE")>80 D
 .	;
 .	D addcode^DBSRWUTL(2,"#ACCEPT Date=10/13/2008;Pgm=RussellDS;CR=35741;Group=READ")
 .	D addcode^DBSRWUTL(2,"write $$SCR132^%TRMVT"_$C(9)_"// Switch to 132 col mode")
 .	Q 
 D addcode^DBSRWUTL(2,"}")
 ;
 D addcode^DBSRWUTL(0,"")
 ;
 D addcode^DBSRWUTL(1,"do INIT^%ZM()")
 ;
 D addcode^DBSRWUTL(0,"")
 ;
 ; Define columns for report browser capabilities
 S X=$$coldefs^DBSRWUTL(.dbtbl5h,.RPTINFO)
 I X'="" D addcode^DBSRWUTL(1,"set vCOL="""_X_"""")
 D addcode^DBSRWUTL(0,"")
 ;
 Q 
 ;
BLDDYNWH(TABLES,PQINFO) ; 
 ;
 N N N SEQ
 ;
 D addcode^DBSRWUTL(1,"// Build WHERE clause to use for dynamic query")
 D addcode^DBSRWUTL(1,"do {")
 D addcode^DBSRWUTL(2,"type Number SEQ=1")
 D addcode^DBSRWUTL(2,"type String DQQRY(),FROM")
 ;
 ; Build query array to pass to SQLCONV
 ;
 S N=""
 F  S N=$order(PQINFO(N)) Q:N=""  D
 .	N QTYPE
 .	;
 .	S QTYPE=$piece(PQINFO(N),"|",2)
 .	; If fixed query, use as is
 .	I QTYPE="F" D
 ..		D addcode^DBSRWUTL(2,"set DQQRY(SEQ)="_$S(PQINFO(N,2)'["""":""""_PQINFO(N,2)_"""",1:$$QADD^%ZS(PQINFO(N,2),""""))_",SEQ=SEQ+1")
 ..		Q 
 .	; Single wild card
 .	E  I QTYPE="WC1" D
 ..		N VAR N X
 ..		S X=$piece(PQINFO(N),"|",3)_" " ; DI
 ..		S X=X_PQINFO(N,2)_" ""_" ; Operator
 ..		S VAR=$piece(PQINFO(N),"|",1) ; Variable
 ..		S X=X_"$$addqts^DBSRWUTL("_VAR_")"
 ..		D addcode^DBSRWUTL(2,"set DQQRY(SEQ)="""_X_",SEQ=SEQ+1")
 ..		Q 
 .	; Double wild card
 .	E  I QTYPE="WC2" D
 ..		N VAR N X
 ..		S X=$piece(PQINFO(N),"|",3)_" " ; DI
 ..		S VAR=$piece(PQINFO(N),"|",1) ; Variable input
 ..		; If not defined, i.e., report called at V0, default to "ALL"
 ..		D addcode^DBSRWUTL(2,"if "_VAR_".get()="""" set "_VAR_"=""ALL""")
 ..		S X=""""_X_"""_"_VAR
 ..		D addcode^DBSRWUTL(2,"if "_VAR_"'=""ALL"" set DQQRY(SEQ)="_X_",SEQ=SEQ+1")
 ..		Q 
 .	Q 
 ;
 D addcode^DBSRWUTL(2,"set FROM=$$DQJOIN^SQLCONV("""_TABLES_""") quit:ER")
 D addcode^DBSRWUTL(2,"set VWHERE=$$WHERE^SQLCONV(.DQQRY,"""")")
 ;
 D addcode^DBSRWUTL(2,"}")
 D addcode^DBSRWUTL(0,"")
 ;
 Q 
 ;
BLDBANNR(PQINFO,RPTINFO,dbtbl5h) ; 
  S:'$D(vobj(dbtbl5h,0)) vobj(dbtbl5h,0)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),0)),1:"")
 ;
 N AREVARS N SEQ
 N CODE N PROMPT N VALUE N VAR N X
 ;
 D addcode^DBSRWUTL(1,"// Print Report Banner Page")
 ;
 ; Run-time suppress banner page option (AUXPTR=slave printer)
 D addcode^DBSRWUTL(1,"if cuvar.banner,'VRWOPT(""NOBANNER"").get(),IOTYP'=""TRM"",'AUXPTR.get() do {")
 ;
 S CODE="type String VBNRINFO(,)"
 I RPTINFO("WHERE")'="" S CODE=CODE_",VWHERE"
 D addcode^DBSRWUTL(2,CODE)
 D addcode^DBSRWUTL(0,"")
 ;
 S AREVARS=0 S SEQ=""
 F  S SEQ=$order(PQINFO(SEQ)) Q:SEQ=""  D
 .	N PTYP S PTYP=$piece(PQINFO(SEQ),"|",2)
 .	;
 .	; Only care about wild-cards since they have run-time input
 .	Q:PTYP'?1"WC"1N 
 .	;
 .	; Save prompt to VBNRINFO("PROMPTS",SEQ) and get value at run-time
 .	S PROMPT=$E($piece(PQINFO(SEQ,1),"|",10),1,37)
 .	S VAR=$piece(PQINFO(SEQ),"|",1)
 .	S VALUE=VAR_".get()"
 .	S AREVARS=1
 .	; If date data type, format date
 .	I $piece(PQINFO(SEQ,1),"|",9)="D" S VALUE="$$DAT^%ZM("_VALUE_",%MSKD)"
 .	S CODE="set VBNRINFO(""PROMPTS"","_SEQ_")="""_PTYP_"|""_"
 .	S CODE=CODE_$S(PROMPT'["""":""""_PROMPT_"""",1:$$QADD^%ZS(PROMPT,""""))_"_""|"
 .	S CODE=CODE_VAR_"|""_"_VALUE
 .	D addcode^DBSRWUTL(2,CODE)
 .	Q 
 ;
 D addcode^DBSRWUTL(0,"")
 ;
 ; Save WHERE clause for printing on banner page.  If dynamic SQL,
 ; VWHERE will already be around
 I RPTINFO("WHERE")'="" D
 .	N WHERE S WHERE=RPTINFO("WHERE")
 .	;
 .	I $L(WHERE)'>50 D addcode^DBSRWUTL(2,"set VWHERE="""_WHERE_"""")
 .	E  D
 ..		D addcode^DBSRWUTL(2,"set VWHERE=""""")
 ..		F  D  Q:WHERE="" 
 ...			D addcode^DBSRWUTL(2,"set VWHERE=VWHERE_"""_$E(WHERE,1,50)_"""")
 ...			S WHERE=$E(WHERE,51,1048575)
 ...			Q 
 ..		Q 
 .	Q 
 ;
 ; Substitute user-defined where clause, if defined
 I RPTINFO("DYNWHERE") D addcode^DBSRWUTL(2,"if vudwhere.exists() set VWHERE=vudwhere")
 ;
 ; Substitute variable values into WHERE clause for banner display
 ;
 I AREVARS D
 .	D addcode^DBSRWUTL(0,"")
 .	D addcode^DBSRWUTL(2,"do {")
 .	D addcode^DBSRWUTL(3,"type Number SEQ")
 .	D addcode^DBSRWUTL(3,"type String VALUE,VAR,X")
 .	D addcode^DBSRWUTL(3,"set X=VWHERE")
 .	D addcode^DBSRWUTL(3,"set SEQ=""""")
 .	D addcode^DBSRWUTL(3,"for  set SEQ=VBNRINFO(""PROMPTS"",SEQ).order() quit:SEQ=""""  do {")
 .	D addcode^DBSRWUTL(4,"set VAR=VBNRINFO(""PROMPTS"",SEQ).piece(""|"",3))")
 .	D addcode^DBSRWUTL(4,"set VALUE=VBNRINFO(""PROMPTS"",SEQ).piece(""|"",4,99)")
 .	D addcode^DBSRWUTL(4,"set X=$$replace^DBSRWUTL(X,"":""_VAR,""'""_VALUE_""'"")")
 .	D addcode^DBSRWUTL(4,"}")
 .	D addcode^DBSRWUTL(3,"set VBNRINFO(""WHERE"")=X")
 .	D addcode^DBSRWUTL(3,"}")
 .	Q 
 E  I RPTINFO("WHERE")'="" D addcode^DBSRWUTL(2,"set VBNRINFO(""WHERE"")=VWHERE")
 ;
 D addcode^DBSRWUTL(0,"")
 ;
 ; Save other information for banner printing
 D addcode^DBSRWUTL(2,"set VBNRINFO(""DESC"")="_$$QADD^%ZS($P(vobj(dbtbl5h),$C(124),1),""""))
 D addcode^DBSRWUTL(2,"set VBNRINFO(""PGM"")="""_$P(vobj(dbtbl5h,0),$C(124),2)_"""")
 D addcode^DBSRWUTL(2,"set VBNRINFO(""RID"")="""_vobj(dbtbl5h,-4)_"""")
 D addcode^DBSRWUTL(2,"set VBNRINFO(""TABLES"")="""_$P(vobj(dbtbl5h,0),$C(124),1)_"""")
 D addcode^DBSRWUTL(0,"")
 ;
 F SEQ=1:1:10 D  Q:X="" 
 .	S X=RPTINFO("SEQBY",SEQ,"COL")
 .	I X'="" D addcode^DBSRWUTL(2,"set VBNRINFO(""ORDERBY"","_SEQ_")="_$S(X'["""":""""_X_"""",1:$$QADD^%ZS(X,"""")))
 .	Q 
 ;
 D addcode^DBSRWUTL(0,"")
 ;
 N docrs,vos1,vos2,vos3,vos4,vos5  N V1 S V1=vobj(dbtbl5h,-4) S docrs=$$vOpen1()
 S SEQ=1
 F  Q:'$$vFetch1()  D
 . D addcode^DBSRWUTL(2,"set VBNRINFO(""DOC"","_SEQ_")="_$$QADD^%ZS(docrs,""""))
 .	S SEQ=SEQ+1
 .	Q 
 ;
 D addcode^DBSRWUTL(0,"")
 ;
 D addcode^DBSRWUTL(2,"do ^DBSRWBNR(IO,.VBNRINFO(,))"_$char(9)_"// Print banner")
 ;
 D addcode^DBSRWUTL(2,"}")
 D addcode^DBSRWUTL(0,"")
 ;
 Q 
 ;
BLDALIGN(RID,RPTINFO) ; 
 ;
 D addcode^DBSRWUTL(0,"")
 D addcode^DBSRWUTL(1,"// Alignment pattern")
 D addcode^DBSRWUTL(1,"if cuvar.alcount,IOTYP'=""TRM"",'VRWOPT(""NOALIGN"").get() do ^DBSRWALN(RID,IO,cuvar.alcount)")
 D addcode^DBSRWUTL(0,"")
 Q 
 ;
BLDVMAP(RPTINFO) ; Private - Build VMAP code for distribution
 ;
 N I
 N CODE N SELECT
 ;
 D addcode^DBSRWUTL(0,"")
 D addcode^DBSRWUTL(0,"VMAP()"_$char(9)_"// Private - Return SELECT list to DBSRWDST")
 D addcode^DBSRWUTL(1,"type String MAP=")
 ;
 S SELECT=RPTINFO("SELECT")
 F I=1:1 D  Q:SELECT="" 
 .	I I=1 S CODE="set MAP="""
 .	E  S CODE="set MAP=MAP_"""
 .	S CODE=CODE_$E(SELECT,1,50)_""""
 .	S SELECT=$E(SELECT,51,1048575)
 .	D addcode^DBSRWUTL(1,CODE)
 .	Q 
 D addcode^DBSRWUTL(1,"quit MAP")
 D addcode^DBSRWUTL(0,"")
 ;
 Q 
 ;
EXT ; 
 ;
 N STOP S STOP=0
 N PID N RID
 ;
 S PID=$J
 ;
 N tmpdqrs,vos1,vos2,vos3,vos4 S tmpdqrs=$$vOpen2()
 ;
 F  Q:'$$vFetch2()  D  Q:STOP 
 .	; If error, keep going, unless interrupt
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 . S RID=tmpdqrs
 .	D DBSRW(RID,1)
 .	Q 
 ;
 Q 
 ;
CMPALL ; Private - Mass compile client/server reports
 N vTp
 ;
 N RID
 ;
 D vDbDe1()
 ;
 N rptrs,vos1,vos2,vos3 S rptrs=$$vOpen3()
 ;
 F  Q:'$$vFetch3()  D
 .	N RID
 . S RID=rptrs
 .	N tmpdq S tmpdq=$$vcdmNew^RecordTMPDQ() S vobj(tmpdq,-3)=$J S vobj(tmpdq,-4)=RID
 .	;
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordTMPDQ(tmpdq,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(tmpdq,-100) S vobj(tmpdq,-2)=1 TC:vTp  
 .	K vobj(+$G(tmpdq)) Q 
 ;
 D EXT
 Q 
 ;
GETSEQBY(dbtbl5h,RPTINFO) ; 
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
 ;
 N I N PGBK N PHDR
 N PRNG N SEQBY N SORTORD
 ;
 S SEQBY(1)=$P(vobj(dbtbl5h,1),$C(124),1) S PGBK(1)=$P(vobj(dbtbl5h,1),$C(124),2) S PHDR(1)=$P(vobj(dbtbl5h,1),$C(124),3)
 S PRNG(1)=$P(vobj(dbtbl5h,1),$C(124),4) S SORTORD(1)=$P(vobj(dbtbl5h,1),$C(124),5)
 S SEQBY(2)=$P(vobj(dbtbl5h,2),$C(124),1) S PGBK(2)=$P(vobj(dbtbl5h,2),$C(124),2) S PHDR(2)=$P(vobj(dbtbl5h,2),$C(124),3)
 S PRNG(2)=$P(vobj(dbtbl5h,2),$C(124),4) S SORTORD(2)=$P(vobj(dbtbl5h,2),$C(124),5)
 S SEQBY(3)=$P(vobj(dbtbl5h,3),$C(124),1) S PGBK(3)=$P(vobj(dbtbl5h,3),$C(124),2) S PHDR(3)=$P(vobj(dbtbl5h,3),$C(124),3)
 S PRNG(3)=$P(vobj(dbtbl5h,3),$C(124),4) S SORTORD(3)=$P(vobj(dbtbl5h,3),$C(124),5)
 S SEQBY(4)=$P(vobj(dbtbl5h,4),$C(124),1) S PGBK(4)=$P(vobj(dbtbl5h,4),$C(124),2) S PHDR(4)=$P(vobj(dbtbl5h,4),$C(124),3)
 S PRNG(4)=$P(vobj(dbtbl5h,4),$C(124),4) S SORTORD(4)=$P(vobj(dbtbl5h,4),$C(124),5)
 S SEQBY(5)=$P(vobj(dbtbl5h,5),$C(124),1) S PGBK(5)=$P(vobj(dbtbl5h,5),$C(124),2) S PHDR(5)=$P(vobj(dbtbl5h,5),$C(124),3)
 S PRNG(5)=$P(vobj(dbtbl5h,5),$C(124),4) S SORTORD(5)=$P(vobj(dbtbl5h,5),$C(124),5)
 S SEQBY(6)=$P(vobj(dbtbl5h,6),$C(124),1) S PGBK(6)=$P(vobj(dbtbl5h,6),$C(124),2) S PHDR(6)=$P(vobj(dbtbl5h,6),$C(124),3)
 S PRNG(6)=$P(vobj(dbtbl5h,6),$C(124),4) S SORTORD(6)=$P(vobj(dbtbl5h,6),$C(124),5)
 S SEQBY(7)=$P(vobj(dbtbl5h,7),$C(124),1) S PGBK(7)=$P(vobj(dbtbl5h,7),$C(124),2) S PHDR(7)=$P(vobj(dbtbl5h,7),$C(124),3)
 S PRNG(7)=$P(vobj(dbtbl5h,7),$C(124),4) S SORTORD(7)=$P(vobj(dbtbl5h,7),$C(124),5)
 S SEQBY(8)=$P(vobj(dbtbl5h,8),$C(124),1) S PGBK(8)=$P(vobj(dbtbl5h,8),$C(124),2) S PHDR(8)=$P(vobj(dbtbl5h,8),$C(124),3)
 S PRNG(8)=$P(vobj(dbtbl5h,8),$C(124),4) S SORTORD(8)=$P(vobj(dbtbl5h,8),$C(124),5)
 S SEQBY(9)=$P(vobj(dbtbl5h,9),$C(124),1) S PGBK(9)=$P(vobj(dbtbl5h,9),$C(124),2) S PHDR(9)=$P(vobj(dbtbl5h,9),$C(124),3)
 S PRNG(9)=$P(vobj(dbtbl5h,9),$C(124),4) S SORTORD(9)=$P(vobj(dbtbl5h,9),$C(124),5)
 S SEQBY(10)=$P(vobj(dbtbl5h,10),$C(124),1) S PGBK(10)=$P(vobj(dbtbl5h,10),$C(124),2) S PHDR(10)=$P(vobj(dbtbl5h,10),$C(124),3)
 S PRNG(10)=$P(vobj(dbtbl5h,10),$C(124),4) S SORTORD(10)=$P(vobj(dbtbl5h,10),$C(124),5)
 ;
 F I=1:1:10 D
 .	S RPTINFO("SEQBY",I,"COL")=SEQBY(I)
 .	S RPTINFO("SEQBY",I,"PAGEBRK")=PGBK(I)
 .	S RPTINFO("SEQBY",I,"PNTHDR")=PHDR(I)
 .	S RPTINFO("SEQBY",I,"MINPNT")=PRNG(I)
 .	S RPTINFO("SEQBY",I,"SORTORD")=SORTORD(I)
 .	Q 
 ;
 Q 
 ;
GETRPPS(RID,RPTINFO,ddmap) ; 
 N vpc
 ;
  S ER=0
 ;
 N SEQ
 ;
 F SEQ=51,71,111,201:20:281 D  Q:ER 
 .	N CNT N END N N N START
 .	N DESC N KEY N PPIN N PPOUT
 .	;
 .	S START=SEQ-.001 S END=SEQ+20
 .	S CNT=1
 .	;
 .	N rs,vos1,vos2,vos3,vos4,vos5,vos6,vos7 S rs=$$vOpen4()
 .	;
 . S vpc='$G(vos1) Q:vpc 
 .	;
 .	F  Q:'$$vFetch4()  D
 ..		N I
 ..		N DATA N VAR
 ..  S DATA=rs
 ..		S PPIN(CNT)=DATA
 ..		S CNT=CNT+1
 ..		;
 ..		; Get variables public to the report
 ..		I SEQ=111,(DATA["//Incoming=") D
 ...			S DATA=$piece(DATA,"Incoming=",2)
 ...			I DATA'="" F I=1:1:$L(DATA,",") D
 ....				S VAR=$$vStrTrim($piece(DATA,",",I),0," ")
 ....				D addvars^DBSRWUTL("INCOMING",VAR,.RPTINFO)
 ....				D addvars^DBSRWUTL("MAINVARS",VAR,.RPTINFO,1) ; Kill from MAINVARS list
 ....				Q 
 ...			Q 
 ..		;
 ..		; Get other variables to type
 ..		E  I ($ZCONVERT(DATA,"U")["TYPE PUBLIC ") D
 ...			S DATA=$$vStrRep(DATA,$char(9)," ",0,0,"")
 ...			S DATA=$$vStrTrim(DATA,0," ") ; Remove trailing and leading spaces
 ...			S DATA=$piece(DATA," ",4,9999) ; Variable list
 ...			S DATA=$translate(DATA," ","") ; Remove spaces
 ...			I DATA'="" F I=1:1:$L(DATA,",") D
 ....				S VAR=$piece(DATA,",",I)
 ....				I SEQ=111 D
 .....					I '($D(RPTINFO("INCOMING",VAR))#2) D addvars^DBSRWUTL("MAINVARS",VAR,.RPTINFO)
 .....					Q 
 ....				E  D addvars^DBSRWUTL("V0TYPE",VAR,.RPTINFO)
 ....				Q 
 ...			Q 
 ..		Q 
 .	;
 .	; Translate, if necessary, pre/post-processor code
 . D PPCODE(.PPIN,.PPOUT,SEQ,.ddmap,.RPTINFO) Q:ER 
 .	;
 .	I SEQ=51 S KEY="PREAQ" S DESC="Pre-processor (after query)"
 .	E  I SEQ=71 S KEY="RPOST" S DESC="Report post-processor"
 .	E  I SEQ=111 S KEY="PREBQ" S DESC="Pre-processor (before query)"
 .	E  I SEQ=201 S KEY="OPRE" S DESC="OPEN pre-processor"
 .	E  I SEQ=221 S KEY="OPOST" S DESC="OPEN post-processor"
 .	E  I SEQ=241 S KEY="FPRE" S DESC="FETCH pre-processor"
 .	E  I SEQ=261 S KEY="FPOST" S DESC="FETCH post-processor"
 .	E  I SEQ=281 S KEY="PRNT" S DESC="PRINT pre-processor"
 .	;
 .	S RPTINFO("SUBS",KEY,1)="// "_DESC
 .	S RPTINFO("SUBS",KEY,2)=""
 .	S CNT=3 S N=""
 .	F  S N=$order(PPOUT(N)) Q:N=""  D
 ..		S RPTINFO("SUBS",KEY,CNT)=PPOUT(N)
 ..		S CNT=CNT+1
 ..		Q 
 . Q 
 ;
 Q 
 ;
PPCODE(IN,OUT,SEQ,ddmap,RPTINFO) ; 
 ;
  S ER=0
 N INSEQ N OUTSEQ
 N NEWLIST S NEWLIST=""
 ;
 S INSEQ="" S OUTSEQ=2
 ;
 F  S INSEQ=$order(IN(INSEQ)) Q:INSEQ=""  D  Q:ER 
 .	N X
 .	S X=IN(INSEQ)
 .	; Pre/post-processor library
 .	I $E(X,2,999)?1"do @["1A.ANP1"]".E D  Q 
 ..		N DATA N PPID
 ..		;
 ..		S PPID=$piece($piece(X,"[",2),"]",1)
 ..		Q:PPID=""  ; Ignore null lib reference
 ..		;
 ..		; If library not yet used, assign number and set it up
 ..		I ($order(RPTINFO("PPLIBS",PPID,""))="") D  Q:ER 
 ...			N NUM N LIBSEQ
 ...			S NUM=$get(RPTINFO("PPLIBS"))+1
 ...			S RPTINFO("PPLIBS")=NUM
 ...			S RPTINFO("PPLIBS",PPID)=NUM
 ...			S RPTINFO("PPLIBS",PPID,1)="VLIB"_NUM_$char(9)_"// User library - "_PPID
 ...			S LIBSEQ=3
 ...			;
 ...			N rs,vos1,vos2,vos3,vos4,vos5 S rs=$$vOpen5()
 ...   I '$G(vos1) D  Q 
 ....				S ER=1
 ....				; Invalid pre/post-processor library name - ~p1
 ....				S RM=$$^MSG(1425,PPID)
 ....				Q 
 ...			;
 ...			F  Q:'$$vFetch5()  D  Q:ER 
 ....				N I
 ....    S DATA=rs
 ....				I DATA["rwrs.getCol(" D  Q:ER 
 .....					I (SEQ=0)!(SEQ=261)!(SEQ=281) S DATA=$$GETRWRS(DATA,.NEWLIST,.ddmap)
 .....					E  D RWRSER(SEQ)
 .....					Q 
 ....				S RPTINFO("PPLIBS",PPID,LIBSEQ)=DATA
 ....				S LIBSEQ=LIBSEQ+1
 ....				I ($ZCONVERT(DATA,"U")["TYPE PUBLIC") D
 .....					S DATA=$piece($piece(DATA,"ublic ",2,999)," ",2)
 .....					F I=1:1:$L(DATA,",") D addvars^DBSRWUTL("V0TYPE",$piece(DATA,",",I),.RPTINFO)
 .....					Q 
 ....				Q 
 ...			;
 ...			I '(NEWLIST="") S RPTINFO("PPLIBS",PPID,2)="type public String "_NEWLIST
 ...   Q 
 ..		;
 ..		; Add call to pre/post-processor library code
 ..		S DATA=$char(9)_"do VLIB"_RPTINFO("PPLIBS",PPID)
 ..		S DATA=DATA_$char(9)_"// User library - "_PPID
 ..		S OUT(OUTSEQ)=DATA
 ..		S OUTSEQ=OUTSEQ+1
 ..		Q 
 .	;
 .	; Substitute RW option call for .RWOPT.
 .	I X[".RWOPT." D
 ..		N DATA N OPT N VALUE
 ..		;
 ..		S OPT=$piece(X,".RWOPT.",2)
 ..		S OPT=$$vStrTrim(OPT,0," ")
 ..		S VALUE=$piece(OPT,"=",2) S OPT=$piece(OPT,"=",1)
 ..		S DATA="do rwopt^DBSRWUTL("""_OPT_""","""_VALUE_""")"
 ..		S X=$piece(X,".RWOPT.",1)_DATA
 ..		Q 
 .	;
 .	I X["rwrs.getCol(" D  Q:ER 
 ..		I (SEQ=0)!(SEQ=261)!(SEQ=281) S X=$$GETRWRS(X,.NEWLIST,.ddmap)
 ..		E  D RWRSER(SEQ)
 ..		Q 
 .	;
 .	I X["set vorder=",SEQ=51!(SEQ=111)!(SEQ=201) S RPTINFO("DYNORDERBY")=1
 .	I X["set vudwhere=",SEQ=51!(SEQ=111)!(SEQ=201) S RPTINFO("DYNWHERE")=1
 .	;
 .	S OUT(OUTSEQ)=X
 .	S OUTSEQ=OUTSEQ+1
 .	Q 
 ;
 I NEWLIST'="" S OUT(1)=$char(9)_"type public String "_NEWLIST
 ;
 Q 
 ;
RWRSER(SEQ) ; Private - Error in use of rwrs.getCol syntax
 ;
 N DESC
 ;
 S ER=1
 S RM="rwrs.getCol syntax only valid for Fetch post-processor, Print pre-processor, or column processors"
 ;
 I SEQ=51 S DESC="Pre-processor (after query)"
 E  I SEQ=71 S DESC="Report post-processor"
 E  I SEQ=111 S DESC="Post-processor (before query)"
 E  I SEQ=201 S DESC="OPEN pre-processor"
 E  I SEQ=221 S DESC="OPEN post-processor"
 E  I SEQ=241 S DESC="FETCH pre-processor"
 E  S DESC=""
 ;
 I DESC'="" S RM=RM_" - not in "_DESC
 ;
 Q 
 ;
GETRWRS(INPUT,VARS,ddmap) ; 
 ;
 N VNUM
 N P1 N P2 N TC
 ;
 I VARS'="" S VARS=VARS_","
 ;
 F  Q:INPUT'["rwrs.getCol("  D  Q:ER 
 .	S P1=$piece(INPUT,"rwrs.getCol(""",1)
 .	S P2=$piece(INPUT,"rwrs.getCol(""",2,999)
 .	S TC=$piece(P2,""")",1)
 .	S P2=$piece(P2,""")",2,999)
 .	D addtomap^DBSRWUTL(TC,.ddmap)
 .	I '($D(ddmap(TC))#2) D
 ..		S ER=1
 ..		S RM="Invalid rwrs.getCol(""TABLE.COLUMN"") reference - rwrs.getcol("""_TC_""")"
 ..		Q 
 .	E  D
 ..		S INPUT=P1_ddmap(TC)_P2
 ..		I (","_VARS)'[(","_ddmap(TC)_",") S VARS=VARS_ddmap(TC)_","
 ..		Q 
 .	Q 
 ;
 S VARS=$E(VARS,1,$L(VARS)-1)
 ;
 Q INPUT
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61288^63984^Dan Russell^36982" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM TMPDQ WHERE PID=:PID
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 N v1 N v2
 TS (vobj):transactionid="CS"
 N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen6()
 F  Q:'$$vFetch6()  D
 . S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
 .	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
 .	;*** Start of code by-passed by compiler
 .	ZWI ^TEMP(v1,v2)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 Q 
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
vStrRep(object,p1,p2,p3,p4,qt) ; String.replace
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;
 I p3<0 Q object
 I $L(p1)=1,$L(p2)<2,'p3,'p4,(qt="") Q $translate(object,p1,p2)
 ;
 N y S y=0
 F  S y=$$vStrFnd(object,p1,y,p4,qt) Q:y=0  D
 .	S object=$E(object,1,y-$L(p1)-1)_p2_$E(object,y,1048575)
 .	S y=y+$L(p2)-$L(p1)
 .	I p3 S p3=p3-1 I p3=0 S y=$L(object)+1
 .	Q 
 Q object
 ; ----------------
 ;  #OPTION ResultClass 1
vStrFnd(object,p1,p2,p3,qt) ; String.find
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;
 I (p1="") Q $S(p2<1:1,1:+p2)
 I p3 S object=$ZCONVERT(object,"U") S p1=$ZCONVERT(p1,"U")
 S p2=$F(object,p1,p2)
 I '(qt=""),$L($E(object,1,p2-1),qt)#2=0 D
 .	F  S p2=$F(object,p1,p2) Q:p2=0!($L($E(object,1,p2-1),qt)#2) 
 .	Q 
 Q p2
 ;
vOpen1() ; DATA FROM DBTBL5PR WHERE LIBS='SYSDEV' AND RID=:V1 AND SEQ>90.999 AND SEQ<111 ORDER BY SEQ ASC
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(V1) I vos3="" G vL1a0
 S vos4=30.999
vL1a4 S vos4=$O(^DBTBL("SYSDEV",5,vos3,vos4),1) I vos4=""!(111']]vos4) G vL1a0
 I '(vos4]]90.999) G vL1a4
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S docrs="" Q 0
 ;
 S vos5=$G(^DBTBL("SYSDEV",5,vos3,vos4))
 S docrs=$P(vos5,$C(12),1)
 ;
 Q 1
 ;
vOpen2() ; ELEMENT FROM TMPDQ WHERE PID=:PID
 ;
 ;
 S vos1=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos1=0 Q
vL2a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(PID)
 S vos4=""
vL2a4 S vos4=$O(^TEMP(vos3,vos4),1) I vos4="" G vL2a0
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos1=1 D vL2a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S tmpdqrs="" Q 0
 ;
 S tmpdqrs=$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen3() ; RID FROM DBTBL5H WHERE LIBS='SYSDEV' AND RID NOT LIKE 'Z%' AND RID NOT LIKE 'z%'
 ;
 ;
 S vos1=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos1=0 Q
vL3a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL3a3 S vos3=$O(^DBTBL("SYSDEV",5,vos3),1) I vos3="" G vL3a0
 I '(vos3'?1"Z".E) G vL3a3
 I '(vos3'?1"z".E) G vL3a3
 Q
 ;
vFetch3() ;
 ;
 ;
 I vos1=1 D vL3a3
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rptrs="" Q 0
 ;
 S rptrs=$S(vos3=vos2:"",1:vos3)
 ;
 Q 1
 ;
vOpen4() ; DATA FROM DBTBL5PR WHERE LIBS='SYSDEV' AND RID=:RID AND SEQ>:START AND SEQ<:END ORDER BY SEQ ASC
 ;
 ;
 S vos1=2
 D vL4a1
 Q ""
 ;
vL4a0 S vos1=0 Q
vL4a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(RID) I vos3="" G vL4a0
 S vos4=$G(START) I vos4="",'$D(START) G vL4a0
 S vos5=$G(END) I vos5="",'$D(END) G vL4a0
 S vos6=30.999
vL4a6 S vos6=$O(^DBTBL("SYSDEV",5,vos3,vos6),1) I vos6=""!(vos5']]vos6) G vL4a0
 I '(vos6]]vos4) G vL4a6
 Q
 ;
vFetch4() ;
 ;
 ;
 I vos1=1 D vL4a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos7=$G(^DBTBL("SYSDEV",5,vos3,vos6))
 S rs=$P(vos7,$C(12),1)
 ;
 Q 1
 ;
vOpen5() ; DATA FROM DBTBL13D WHERE LIBS='SYSDEV' AND PID=:PPID ORDER BY SEQ ASC
 ;
 ;
 S vos1=2
 D vL5a1
 Q ""
 ;
vL5a0 S vos1=0 Q
vL5a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(PPID) I vos3="" G vL5a0
 S vos4=0
vL5a4 S vos4=$O(^DBTBL("SYSDEV",13,vos3,vos4),1) I vos4="" G vL5a0
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
 S vos5=$G(^DBTBL("SYSDEV",13,vos3,vos4))
 S rs=$P(vos5,$C(12),1)
 ;
 Q 1
 ;
vOpen6() ; PID,ELEMENT FROM TMPDQ WHERE PID=:PID
 ;
 ;
 S vos1=2
 D vL6a1
 Q ""
 ;
vL6a0 S vos1=0 Q
vL6a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(PID)
 S vos4=""
vL6a4 S vos4=$O(^TEMP(vos3,vos4),1) I vos4="" G vL6a0
 Q
 ;
vFetch6() ;
 ;
 ;
 I vos1=1 D vL6a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vRs="" Q 0
 ;
 S vRs=vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vCatch1 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 N ET
 D ET^%ZT(.ET)
 I ET="INTERRUPT" S STOP=1
 E  WRITE !!,RID,?15,$P(error,",",2),",",$P(error,",",3),",",$P(error,",",4),!
 D ZX^UCGMR(voxMrk) Q 
