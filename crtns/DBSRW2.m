 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSRW2 ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSRW2(dbtbl5h,ddmap,RPTINFO,PQINFO) ; 
 ;
 N LVL
 N RID N TABCHR N vclist
 ;
 S TABCHR=$char(9)
 S RID=vobj(dbtbl5h,-4)
 ;
 ; Repeat Field Definition (from|to|size|count)
 ; Only a single repeat region definition will exist for a report
 ;
 N rs,vos1,vos2,vos3,vos4,vos5 S rs=$$vOpen1()
 I '$G(vos1) D
 .	S RPTINFO("LINECNT")=0
 .	S RPTINFO("REPEATSIZE")=0
 .	S RPTINFO("REPEATGRP")=""
 .	S RPTINFO("REPEATCNT")=0
 .	Q 
 E  F  Q:'$$vFetch1()  D  Q 
 . S RPTINFO("LINECNT")=$P(rs,$C(9),3)-$P(rs,$C(9),2)+1
 . S RPTINFO("REPEATSIZE")=$P(rs,$C(9),4)
 . S RPTINFO("REPEATGRP")=$P(rs,$C(9),1)
 . S RPTINFO("REPEATCNT")=$P(rs,$C(9),5)
 .	Q 
 ;
 S RPTINFO("RID")=RID
  S:'$D(vobj(dbtbl5h,0)) vobj(dbtbl5h,0)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),0)),1:"")
 S RPTINFO("PAGESIZE")=$P(vobj(dbtbl5h,0),$C(124),6)
 ;
 ; Get last key level
 D
 .	 S:'$D(vobj(dbtbl5h,10)) vobj(dbtbl5h,10)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),10)),1:"")
 .	I $P(vobj(dbtbl5h,10),$C(124),1)'="" D
 ..		S RPTINFO("LASTLVL")=10
 ..		I RPTINFO("REPEATGRP")=$P(vobj(dbtbl5h,10),$C(124),1) S RPTINFO("REPEATGRPLVL")=10
 ..		Q 
 .	 S:'$D(vobj(dbtbl5h,9)) vobj(dbtbl5h,9)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),9)),1:"")
 .	E  I $P(vobj(dbtbl5h,9),$C(124),1)'="" D
 ..		S RPTINFO("LASTLVL")=9
 ..		I RPTINFO("REPEATGRP")=$P(vobj(dbtbl5h,9),$C(124),1) S RPTINFO("REPEATGRPLVL")=9
 ..		Q 
 .	 S:'$D(vobj(dbtbl5h,8)) vobj(dbtbl5h,8)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),8)),1:"")
 .	E  I $P(vobj(dbtbl5h,8),$C(124),1)'="" D
 ..		S RPTINFO("LASTLVL")=8
 ..		I RPTINFO("REPEATGRP")=$P(vobj(dbtbl5h,8),$C(124),1) S RPTINFO("REPEATGRPLVL")=8
 ..		Q 
 .	 S:'$D(vobj(dbtbl5h,7)) vobj(dbtbl5h,7)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),7)),1:"")
 .	E  I $P(vobj(dbtbl5h,7),$C(124),1)'="" D
 ..		S RPTINFO("LASTLVL")=7
 ..		I RPTINFO("REPEATGRP")=$P(vobj(dbtbl5h,7),$C(124),1) S RPTINFO("REPEATGRPLVL")=7
 ..		Q 
 .	 S:'$D(vobj(dbtbl5h,6)) vobj(dbtbl5h,6)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),6)),1:"")
 .	E  I $P(vobj(dbtbl5h,6),$C(124),1)'="" D
 ..		S RPTINFO("LASTLVL")=6
 ..		I RPTINFO("REPEATGRP")=$P(vobj(dbtbl5h,6),$C(124),1) S RPTINFO("REPEATGRPLVL")=6
 ..		Q 
 .	 S:'$D(vobj(dbtbl5h,5)) vobj(dbtbl5h,5)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),5)),1:"")
 .	E  I $P(vobj(dbtbl5h,5),$C(124),1)'="" D
 ..		S RPTINFO("LASTLVL")=5
 ..		I RPTINFO("REPEATGRP")=$P(vobj(dbtbl5h,5),$C(124),1) S RPTINFO("REPEATGRPLVL")=5
 ..		Q 
 .	 S:'$D(vobj(dbtbl5h,4)) vobj(dbtbl5h,4)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),4)),1:"")
 .	E  I $P(vobj(dbtbl5h,4),$C(124),1)'="" D
 ..		S RPTINFO("LASTLVL")=4
 ..		I RPTINFO("REPEATGRP")=$P(vobj(dbtbl5h,4),$C(124),1) S RPTINFO("REPEATGRPLVL")=4
 ..		Q 
 .	 S:'$D(vobj(dbtbl5h,3)) vobj(dbtbl5h,3)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),3)),1:"")
 .	E  I $P(vobj(dbtbl5h,3),$C(124),1)'="" D
 ..		S RPTINFO("LASTLVL")=3
 ..		I RPTINFO("REPEATGRP")=$P(vobj(dbtbl5h,3),$C(124),1) S RPTINFO("REPEATGRPLVL")=3
 ..		Q 
 .	 S:'$D(vobj(dbtbl5h,2)) vobj(dbtbl5h,2)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),2)),1:"")
 .	E  I $P(vobj(dbtbl5h,2),$C(124),1)'="" D
 ..		S RPTINFO("LASTLVL")=2
 ..		I RPTINFO("REPEATGRP")=$P(vobj(dbtbl5h,2),$C(124),1) S RPTINFO("REPEATGRPLVL")=2
 ..		Q 
 .	E  D
 ..		S RPTINFO("LASTLVL")=1
 ..		 S:'$D(vobj(dbtbl5h,1)) vobj(dbtbl5h,1)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),1)),1:"")
 ..		I RPTINFO("REPEATGRP")=$P(vobj(dbtbl5h,1),$C(124),1) S RPTINFO("REPEATGRPLVL")=1
 ..		Q 
 .	Q 
 ;
 D direfs^DBSRWUTL(.dbtbl5h,.RPTINFO,.ddmap) ; Map columns to variables
 ;
 ; Define report statistics
 ;   RPTINFO("STAT",SEQ)=Source|fmt|Target|Increments
 D SETSTATS(.dbtbl5h,.RPTINFO)
 ;
 D format^DBSRWUTL(.dbtbl5h,.RPTINFO,.ddmap) Q:ER  ; Format logic
 ;
 ; Are there summary sections?
 S RPTINFO("SUM")=0
 F LVL=RPTINFO("LASTLVL"):-1:2 I ($D(RPTINFO("FMT",LVL,"T"))>0) S RPTINFO("SUM")=1 Q 
 ;
 I RPTINFO("SUM") D
 .	;
 .	N I
 .	N TC
 .	;
 .	S vclist=""
 .	F I=1:1:ddmap(0)-1 D
 ..		;
 ..		S TC=ddmap(I)
 ..		D addvars^DBSRWUTL("V0TYPE","vo"_ddmap(TC),.RPTINFO)
 ..		S vclist=vclist_ddmap(TC)_","
 ..		Q 
 .	;
 .	S vclist=$E(vclist,1,$L(vclist)-1)
 .	Q 
 ;
 D CONV(.RPTINFO,.ddmap) ; Convert to print format
 ;
 ; Add code to initialize variables
 D
 .	N I
 .	N CODE
 .	;
 .	D addcode^DBSRWUTL(1,"// Initialize variables")
 .	;
 .	; Initialize column data (vcn variables) and protection flags,
 .	; if they exist(vpn variables) to null
 .	S CODE=""
 .	F I=1:1:ddmap(0)-1 D
 ..		;
 ..		S CODE=CODE_ddmap(ddmap(I))_","
 ..		I ($D(RPTINFO("VPTYPE","vp"_I))#2) S CODE=CODE_"vp"_I_","
 ..		Q 
 .	S CODE=$E(CODE,1,$L(CODE)-1)
 .	F  D  Q:(CODE="") 
 ..		D addcode^DBSRWUTL(1,"set ("_$piece(CODE,",",1,100)_")=""""")
 ..		S CODE=$piece(CODE,",",101,$L(CODE))
 ..		Q 
 .	;
 .	D addcode^DBSRWUTL(1,"set (VFMQ,vlc,VLC,VOFFLG,VPN,VRG)=0")
 .	I '($order(RPTINFO("SUBS","FPOST",""))="") D addcode^DBSRWUTL(1,"set VHIT = 0")
 .	D addcode^DBSRWUTL(1,"set VNEWHDR=1")
 .	D addcode^DBSRWUTL(1,"set VLOF=""""")
 .	D addcode^DBSRWUTL(1,"set %TIM=$$TIM^%ZM")
 .	D addcode^DBSRWUTL(1,"set vrundate=%CurrentDate.toString(),vsysdate=%SystemDate.toString()")
 .	D addcode^DBSRWUTL(0,"")
 .	;
 .	D addcode^DBSRWUTL(1,"do {")
 .	D addcode^DBSRWUTL(2,"type Number I,J,K")
 .	D addcode^DBSRWUTL(2,"for I=0:1:"_(+$piece(RPTINFO("FMT",0),"|",1))_" do {")
 .	D addcode^DBSRWUTL(3,"set (vh(I),VD(I))=0,vs(I)=1"_$char(9)_"// Group break flags")
 .	D addcode^DBSRWUTL(3,"set VT(I)=0"_$char(9)_"// Group count")
 .	D addcode^DBSRWUTL(3,"for J=1:1:"_(+$piece(RPTINFO("FMT",0),"|",2))_" do {")
 .	D addcode^DBSRWUTL(4,"for K=1:1:3 set VT(I,J,K)="""""_$char(9)_"// Initialize function stats")
 .	D addcode^DBSRWUTL(4,"}")
 .	D addcode^DBSRWUTL(3,"}")
 .	D addcode^DBSRWUTL(2,"}")
 .	D addcode^DBSRWUTL(0,"")
 .	;
 .	I RPTINFO("LINECNT") D
 ..		I RPTINFO("LINECNT")=1 D addcode^DBSRWUTL(1,"set VRF=""""")
 ..		D addcode^DBSRWUTL(1,"set (VR,VRG)=""""")
 ..		D addcode^DBSRWUTL(1,"for vI=1:1:"_(+RPTINFO("LINECNT"))_" set VRF(vI)="""""_$char(9)_"// Initialize print buffers")
 ..		Q 
 .	Q 
 ;
 ; Report browser data
 D addcode^DBSRWUTL(1,"do Db.delete(""TMPRPTBR"",""JOBNO=:%ProcessID"")"_$char(9)_"// Report browser data")
 ;
 ; Report Pre-processor (after query)
 I '($order(RPTINFO("SUBS","PREAQ",""))="") D
 .	N CODE
 .	S CODE="if VDISTKEY.get()="""" do { quit:VFMQ"
 .	S CODE=CODE_TABCHR_"// Report Pre-processor (after query)"
 .	D addcode^DBSRWUTL(1,CODE)
 .	D addcode^DBSRWUTL(2,"do VPREAQ")
 .	; If flagged to exit, don't print header
 .	D addcode^DBSRWUTL(2,"if VFMQ set vh(0)=1 do VEXIT(0)")
 .	D addcode^DBSRWUTL(2,"}")
 .	D addcode^DBSRWUTL(0,"")
 .	Q 
 ;
 D addcode^DBSRWUTL(1,"set vh(0)=0")
 D addcode^DBSRWUTL(0,"")
 ;
 I RPTINFO("DISTKEY")'="" D
 .	;
 .	N CODE
 .	;
 .	; Make sure distribution key is selected
 .	D addtomap^DBSRWUTL(RPTINFO("DISTKEY"),.ddmap)
 .	;
 .	D addcode^DBSRWUTL(1,"// Create report table")
 .	D addcode^DBSRWUTL(1,"if VTBLNAM.exists() do {")
 .	D addcode^DBSRWUTL(2,"type Number VSEQ=0")
 .	D addcode^DBSRWUTL(2,"type String V,VDIST,VI")
 .	D BLDSELCT(.ddmap,.RPTINFO,2) ; Add Db.select
 .	D addcode^DBSRWUTL(2,"if rwrs.isEmpty() do {")
 .	D addcode^DBSRWUTL(3,"do VEXIT(1)")
 .	D addcode^DBSRWUTL(3,"}")
 .	D addcode^DBSRWUTL(2,"else  while rwrs.next() do { quit:VFMQ")
 .	I '($order(RPTINFO("SUBS","FPRE",""))="") D addcode^DBSRWUTL(3,"do VFPRE quit:VFMQ")
 .	D addcode^DBSRWUTL(3,"set VDIST=rwrs.getCol("""_RPTINFO("DISTKEY")_""")")
 .	D addcode^DBSRWUTL(3,"quit:VDIST=""""")
 .	D addcode^DBSRWUTL(3,"set V=rwrs.getRow().toString()")
 .	D addcode^DBSRWUTL(3,"set VSEQ=VSEQ+1")
 .	D addcode^DBSRWUTL(3,"type RecordTMPRPTDS tmprptds=Class.new(""RecordTMPRPTDS"")")
 .	D addcode^DBSRWUTL(3,"set tmprptds.jobno=%ProcessID")
 .	D addcode^DBSRWUTL(3,"set tmprptds.distkey=VDIST")
 .	D addcode^DBSRWUTL(3,"set tmprptds.seq=VSEQ")
 .	D addcode^DBSRWUTL(3,"set tmprptds.data=V")
 .	I RPTINFO("RESFLG") D addcode^DBSRWUTL(3,"set tmprptds.protmask=rwrs.getRowProt()")
 .	D addcode^DBSRWUTL(3,"do tmprptds.bypassSave()")
 .	D addcode^DBSRWUTL(3,"}")
 .	D addcode^DBSRWUTL(2,"}")
 .	D addcode^DBSRWUTL(0,"")
 .	;
 .	; Set up code to run report from report table
 .	;
 .	D addcode^DBSRWUTL(1,"// Run report - input from report table")
 .	D addcode^DBSRWUTL(1,"else  if VDISTKEY.get()'="""" do {")
 .	I '($order(RPTINFO("SUBS","FPOST",""))="") D addcode^DBSRWUTL(2,"type Boolean VSKIPREC = 0")
 .	D addcode^DBSRWUTL(2,"type String V,VI")
 .	D addcode^DBSRWUTL(2,"do VINILAST")
 .	D addcode^DBSRWUTL(2,"type DbSet ds=Db.selectDbSet(""TMPRPTDS"",""DISTKEY=:VDISTKEY"")")
 .	D addcode^DBSRWUTL(2,"while ds.next() do { quit:VFMQ")
 .	D addcode^DBSRWUTL(3,"set V=ds.getRecord().data")
 .	I RPTINFO("RESFLG") D
 ..		D addcode^DBSRWUTL(3,"set VI=ds.getRecord().protmask")
 ..		Q 
 .	E  D addcode^DBSRWUTL(3,"set VI=""""")
 .	D addcode^DBSRWUTL(3,"do VGETDATA(V,VI)")
 .	I '($order(RPTINFO("SUBS","FPOST",""))="") D addcode^DBSRWUTL(3,"do VFPOST quit:(VFMQ ! VSKIPREC)  set VHIT = 1")
 .	D addcode^DBSRWUTL(3,"do VPRINT quit:VFMQ")
 .	D addcode^DBSRWUTL(3,"do VSAVLAST")
 .	D addcode^DBSRWUTL(3,"}")
 .	;
 .	I '($order(RPTINFO("SUBS","FPOST",""))="") D
 ..		D addcode^DBSRWUTL(2,"do VEXIT('VHIT)")
 ..		Q 
 .	E  D addcode^DBSRWUTL(2,"do VEXIT(0)")
 .	D addcode^DBSRWUTL(2,"}")
 .	D addcode^DBSRWUTL(0,"")
 .	Q 
 ;
 ; Set up code to run report directly.  If this in only code, no need for else
 D
 .	N TABLVL
 .	N CODE
 .	;
 .	D addcode^DBSRWUTL(1,"// Run report directly")
 .	;
 .	I RPTINFO("DISTKEY")="" S TABLVL=0
 .	E  S TABLVL=1
 .	;
 .	I TABLVL D addcode^DBSRWUTL(1,"else  do {")
 .	D addcode^DBSRWUTL(TABLVL+1,"do VINILAST")
 .	D BLDSELCT(.ddmap,.RPTINFO,TABLVL+1) ; Add Db.select
 .	D addcode^DBSRWUTL(TABLVL+1,"if rwrs.isEmpty() do VEXIT(1) quit")
 .	D addcode^DBSRWUTL(TABLVL+1,"while rwrs.next() do { quit:VFMQ")
 .	I '($order(RPTINFO("SUBS","FPOST",""))="") D addcode^DBSRWUTL(TABLVL+1,"type Boolean VSKIPREC = 0")
 .	D addcode^DBSRWUTL(TABLVL+2,"type String V,VI")
 .	I '($order(RPTINFO("SUBS","FPRE",""))="") D addcode^DBSRWUTL(TABLVL+2,"do VFPRE quit:VFMQ")
 .	D addcode^DBSRWUTL(TABLVL+2,"set V=rwrs.getRow().toString()")
 .	I RPTINFO("RESFLG") S CODE="set VI=rwrs.getRowProt()"_$char(9)_"// Data item protection"
 .	E  S CODE="set VI="""""
 .	D addcode^DBSRWUTL(TABLVL+2,CODE)
 .	D addcode^DBSRWUTL(TABLVL+2,"do VGETDATA(V,VI)")
 .	I '($order(RPTINFO("SUBS","FPOST",""))="") D addcode^DBSRWUTL(TABLVL+2,"do VFPOST quit:(VFMQ ! VSKIPREC)  set VHIT = 1")
 .	D addcode^DBSRWUTL(TABLVL+2,"do VPRINT quit:VFMQ")
 .	D addcode^DBSRWUTL(TABLVL+2,"do VSAVLAST")
 .	D addcode^DBSRWUTL(TABLVL+2,"}")
 .	;
 .	I '($order(RPTINFO("SUBS","FPOST",""))="") D
 ..		D addcode^DBSRWUTL(TABLVL+1,"do VEXIT('VHIT)")
 ..		Q 
 .	E  D addcode^DBSRWUTL(TABLVL+1,"do VEXIT(0)")
 .	I TABLVL D addcode^DBSRWUTL(2,"}")
 .	D addcode^DBSRWUTL(0,"")
 .	Q 
 ;
 D addcode^DBSRWUTL(1,"quit")
 D addcode^DBSRWUTL(0,"")
 ;
 ; Set up code to save last access keys values -- used for key breaks
 D
 .	N CODE1 N CODE2 N X
 .	;
 .	S (CODE1,CODE2)=""
 .	 S:'$D(vobj(dbtbl5h,1)) vobj(dbtbl5h,1)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),1)),1:"")
 .	D BLDLOAD($P(vobj(dbtbl5h,1),$C(124),1),.CODE1,.CODE2,.RPTINFO,.ddmap)
 .	 S:'$D(vobj(dbtbl5h,2)) vobj(dbtbl5h,2)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),2)),1:"")
 .	D BLDLOAD($P(vobj(dbtbl5h,2),$C(124),1),.CODE1,.CODE2,.RPTINFO,.ddmap)
 .	 S:'$D(vobj(dbtbl5h,3)) vobj(dbtbl5h,3)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),3)),1:"")
 .	D BLDLOAD($P(vobj(dbtbl5h,3),$C(124),1),.CODE1,.CODE2,.RPTINFO,.ddmap)
 .	 S:'$D(vobj(dbtbl5h,4)) vobj(dbtbl5h,4)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),4)),1:"")
 .	D BLDLOAD($P(vobj(dbtbl5h,4),$C(124),1),.CODE1,.CODE2,.RPTINFO,.ddmap)
 .	 S:'$D(vobj(dbtbl5h,5)) vobj(dbtbl5h,5)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),5)),1:"")
 .	D BLDLOAD($P(vobj(dbtbl5h,5),$C(124),1),.CODE1,.CODE2,.RPTINFO,.ddmap)
 .	 S:'$D(vobj(dbtbl5h,6)) vobj(dbtbl5h,6)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),6)),1:"")
 .	D BLDLOAD($P(vobj(dbtbl5h,6),$C(124),1),.CODE1,.CODE2,.RPTINFO,.ddmap)
 .	 S:'$D(vobj(dbtbl5h,7)) vobj(dbtbl5h,7)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),7)),1:"")
 .	D BLDLOAD($P(vobj(dbtbl5h,7),$C(124),1),.CODE1,.CODE2,.RPTINFO,.ddmap)
 .	 S:'$D(vobj(dbtbl5h,8)) vobj(dbtbl5h,8)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),8)),1:"")
 .	D BLDLOAD($P(vobj(dbtbl5h,8),$C(124),1),.CODE1,.CODE2,.RPTINFO,.ddmap)
 .	 S:'$D(vobj(dbtbl5h,9)) vobj(dbtbl5h,9)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),9)),1:"")
 .	D BLDLOAD($P(vobj(dbtbl5h,9),$C(124),1),.CODE1,.CODE2,.RPTINFO,.ddmap)
 .	 S:'$D(vobj(dbtbl5h,10)) vobj(dbtbl5h,10)=$S(vobj(dbtbl5h,-2):$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),10)),1:"")
 .	D BLDLOAD($P(vobj(dbtbl5h,10),$C(124),1),.CODE1,.CODE2,.RPTINFO,.ddmap)
 .	;
 .	I 'RPTINFO("SUM") D
 ..		;
 ..		D addcode^DBSRWUTL(0,"")
 ..		D addcode^DBSRWUTL(0,"VINILAST"_TABCHR_"// Initialize last access key values")
 ..		S X=$E(CODE1,2,1048575)
 ..		D addcode^DBSRWUTL(1,"type public String "_$translate(X,"="""))
 ..		D addcode^DBSRWUTL(1,"set "_X)
 ..		D addcode^DBSRWUTL(1,"quit")
 ..		D addcode^DBSRWUTL(0,"")
 ..		D addcode^DBSRWUTL(0,"VSAVLAST"_TABCHR_"// Save last access keys values")
 ..		S X=$E(CODE2,2,1048575)
 ..		D addcode^DBSRWUTL(1,"type public String "_$translate(X,"=",","))
 ..		D addcode^DBSRWUTL(1,"set "_X)
 ..		D addcode^DBSRWUTL(1,"quit")
 ..		D addcode^DBSRWUTL(0,"")
 ..		Q 
 .	E  D
 ..		;
 ..		N I
 ..		;
 ..		S (CODE1,CODE2)=""
 ..		;
 ..		F I=1:1:$L(vclist,",") D
 ...			;
 ...			S CODE1=CODE1_"vo"_$piece(vclist,",",I)_"="""","
 ...			S CODE2=CODE2_"vo"_$piece(vclist,",",I)_"="_$piece(vclist,",",I)_","
 ...			Q 
 ..		S CODE1=$E(CODE1,1,$L(CODE1)-1)
 ..		S CODE2=$E(CODE2,1,$L(CODE2)-1)
 ..		;
 ..		D addcode^DBSRWUTL(0,"")
 ..		D addcode^DBSRWUTL(0,"VINILAST"_TABCHR_"// Initialize old values")
 ..		;
 ..		F  Q:'('(CODE1=""))  D
 ...			;
 ...			D addcode^DBSRWUTL(1,"type public String "_$piece(CODE1,",",1,100))
 ...			S CODE1=$piece(CODE1,",",101,$L(CODE1))
 ...			Q 
 ..		D addcode^DBSRWUTL(1,"quit")
 ..		D addcode^DBSRWUTL(0,"")
 ..		;
 ..		D addcode^DBSRWUTL(0,"VSAVLAST"_TABCHR_"// Save old values")
 ..		S X=vclist
 ..		;
 ..		F  Q:'('(X=""))  D
 ...			;
 ...			D addcode^DBSRWUTL(1,"type public String "_$piece(X,",",1,100))
 ...			D addcode^DBSRWUTL(1,"type public String "_$$vStrRep($piece(X,",",1,100),"vc","vovc",0,0,""))
 ...			S X=$piece(X,",",101,$L(X))
 ...			Q 
 ..		F  Q:'('(CODE2=""))  D
 ...			;
 ...			D addcode^DBSRWUTL(1,"set "_$piece(CODE2,",",1,50))
 ...			S CODE2=$piece(CODE2,",",51,$L(CODE2))
 ...			Q 
 ..		D addcode^DBSRWUTL(1,"quit")
 ..		D addcode^DBSRWUTL(0,"")
 ..		Q 
 .	Q 
 ;
 D addcode^DBSRWUTL(0,"")
 ;
 ; Set up to data load retrieved into variables
 D BLDGETD(.ddmap,.RPTINFO)
 ;
 ; Set up user-defined pre/post-processor code
 I '($order(RPTINFO("SUBS",""))="") D
 .	N SUB S SUB=""
 .	;
 .	D addcode^DBSRWUTL(1,"// User-defined pre/post-processor code")
 .	D addcode^DBSRWUTL(0,"")
 .	;
 .	F  S SUB=$order(RPTINFO("SUBS",SUB)) Q:SUB=""  D
 ..		N N S N=1
 ..		;
 ..		D addcode^DBSRWUTL(-1,"V"_SUB_$char(9)_RPTINFO("SUBS",SUB,1))
 ..		F  S N=$order(RPTINFO("SUBS",SUB,N)) Q:N=""  D addcode^DBSRWUTL(-1,RPTINFO("SUBS",SUB,N))
 ..		D addcode^DBSRWUTL(1,"quit")
 ..		D addcode^DBSRWUTL(0,"")
 ..		Q 
 .	Q 
 ;
 ; Set up pre/post-processor library
 I '($order(RPTINFO("PPLIBS",""))="") D
 .	N LIB S LIB=""
 .	;
 .	D addcode^DBSRWUTL(1,"// Pre/post-processor library code")
 .	D addcode^DBSRWUTL(0,"")
 .	;
 .	F  S LIB=$order(RPTINFO("PPLIBS",LIB)) Q:LIB=""  D
 ..		N N S N=1
 ..		;
 ..		D addcode^DBSRWUTL(0,RPTINFO("PPLIBS",LIB,1))
 ..		F  S N=$order(RPTINFO("PPLIBS",LIB,N)) Q:N=""  D addcode^DBSRWUTL(1,RPTINFO("PPLIBS",LIB,N))
 ..		D addcode^DBSRWUTL(1,"quit")
 ..		D addcode^DBSRWUTL(0,"")
 ..		Q 
 .	Q 
 ;
 ; Set up code to save data to print buffer for report browser
 D
 .	D addcode^DBSRWUTL(0,"VBRSAVE(Number LINE,String DATA)"_TABCHR_"// Save for report browser")
 .	D addcode^DBSRWUTL(1,"type RecordTMPRPTBR tmprptbr=Class.new(""RecordTMPRPTBR"")")
 .	D addcode^DBSRWUTL(1,"set tmprptbr.jobno=%ProcessID")
 .	D addcode^DBSRWUTL(1,"set tmprptbr.lineno=LINE")
 .	D addcode^DBSRWUTL(1,"set tmprptbr.pageno=0")
 .	D addcode^DBSRWUTL(1,"set tmprptbr.seq=0")
 .	D addcode^DBSRWUTL(1,"set tmprptbr.data=DATA")
 .	D addcode^DBSRWUTL(1,"do tmprptbr.bypassSave()")
 .	D addcode^DBSRWUTL(1,"quit")
 .	Q 
 ;
 D addcode^DBSRWUTL(0,"")
 ;
 ; Set up code to print memo fields, if any on report
 I $get(RPTINFO("MEMOS")) D MEMO
 ;
 ; Set up code to handle exit
 D
 .	N I
 .	N CODE
 .	;
 .	S CODE="set "
 .	F I=1:1:RPTINFO("LASTLVL")-1 S CODE=CODE_"vs("_I_")=0,"
 .	S CODE=CODE_"vs("_RPTINFO("LASTLVL")_")=0"
 .	D addcode^DBSRWUTL(0,"VEXIT(NOINFO)"_TABCHR_"// Exit from report")
 .	D addcode^DBSRWUTL(1,"type public Number IOSL,vcrt,VFMQ,vh(),VLC,VPN,VRWOPT,VSTATS()")
 .	D addcode^DBSRWUTL(1,"type public String IO,VTBLNAM")
 .	D addcode^DBSRWUTL(1,"type Number I,PN,vs(),z")
 .	D addcode^DBSRWUTL(1,"type String VL=""""")
 .	; Flush print bufer
 .	I RPTINFO("REPEATCNT") D addcode^DBSRWUTL(1,"if 'VFMQ do VOM2")
 .	; Reset group summary
 .	D addcode^DBSRWUTL(1,CODE)
 .	;
 .	I RPTINFO("LASTLVL")>1 D addcode^DBSRWUTL(1,"if 'VFMQ do VSUM")
 .	;
 .	I '($order(RPTINFO("DSP",92,"H",""))="") S CODE="if 'VFMQ do VRSUM" ; Report summary
 .	E  S CODE="if 'vh(0) do VHDG0" ; Last Page
 .	D addcode^DBSRWUTL(1,CODE)
 .	;
 .	D addcode^DBSRWUTL(1,"if 'VFMQ do {")
 .	; NOINFO=1 indicates there was no data and displays message to that effect
 .	D addcode^DBSRWUTL(2,"// No information available to display")
 .	D addcode^DBSRWUTL(2,"if NOINFO=1 set VL=$$^MSG(4655) do VOM")
 .	;
 .	; Final page trailer
 .	I '($order(RPTINFO("DSP",90,"T",""))="") D addcode^DBSRWUTL(2,"do VTRL0")
 .	;
 .	D addcode^DBSRWUTL(2,"if vcrt set VL="""" for z=VLC+1:1:IOSL do VOM")
 .	D addcode^DBSRWUTL(0,"")
 .	I '($order(RPTINFO("STAT",""))="") D
 ..		D addcode^DBSRWUTL(2,"set PN=VPN")
 ..		D addcode^DBSRWUTL(2,"do ^DBSRWSTS(VSTATS())"_TABCHR_"// Print statistics")
 ..		D addcode^DBSRWUTL(2,"quit:VFMQ")
 ..		D addcode^DBSRWUTL(0,"")
 ..		Q 
 .	D addcode^DBSRWUTL(2,"if 'VTBLNAM.exists() do {")
 .	D addcode^DBSRWUTL(3,"set vs(2)=0")
 .	; If sorted
 .	I $$SORTFLG^DBSRWUTL(dbtbl5h) D addcode^DBSRWUTL(3,"do VBREAK,stat^DBSRWUTL(2)")
 .	; Report Post-processor
 .	I $D(RPTINFO("SUBS","RPOST")) D addcode^DBSRWUTL(3,"do VRPOST"_TABCHR_"// Report Post-Processor")
 .	D addcode^DBSRWUTL(3,"}")
 .	D addcode^DBSRWUTL(2,"}")
 .	;
 .	D addcode^DBSRWUTL(0,"")
 .	;
 .	D addcode^DBSRWUTL(1,"if 'VFMQ,vcrt set PN=-1 do ^DBSRWBR(2)")
 .	D addcode^DBSRWUTL(1,"if 'VRWOPT(""NOCLOSE"").get() do CLOSE^SCAIO")
 .	D addcode^DBSRWUTL(1,"do Db.delete(""TMPRPTBR"",""JOBNO=:%ProcessID"")"_$char(9)_"// Report browser data")
 .	;
 .	D addcode^DBSRWUTL(0,"")
 .	;
 .	D addcode^DBSRWUTL(1,"quit")
 .	D addcode^DBSRWUTL(0,"")
 .	;
 .	Q 
 ;
 ; Set up code for print section
 D
 .	N I
 .	N CODE N SEC
 .	;
 .	S CODE=""
 .	F I=1:1:10 I $D(RPTINFO("FMT",I)) S CODE=CODE_",vskp("_I_")=1"
 .	D addcode^DBSRWUTL(0,"VPRINT"_TABCHR_"// Print section")
 .	D addcode^DBSRWUTL(1,"type public Number VD(),VFMQ,VH0,vh(),VNEWHDR,VR,VRG,VRWOPT,VSEQ")
 .	;
 .	D addcode^DBSRWUTL(1,"type Number vskp()")
 .	D addcode^DBSRWUTL(0,"")
 .	I CODE'="" D addcode^DBSRWUTL(1,"if VRWOPT(""NODTL"").get() set "_$E(CODE,2,1048575)_TABCHR_"// Skip detail")
 .	D addcode^DBSRWUTL(1,"do VBREAK")
 .	I RPTINFO("LASTLVL")>1 D addcode^DBSRWUTL(1,"do VSUM quit:VFMQ")
 .	D addcode^DBSRWUTL(0,"")
 .	;
 .	; PRINT Pre-Processor
 .	I $D(RPTINFO("SUBS","PRNT")) D addcode^DBSRWUTL(1,"do VPRNT quit:VFMQ"_TABCHR_"// Print pre-processor")
 .	;
 .	D addcode^DBSRWUTL(1,"if VH0.get() set vh(0)=0,VNEWHDR=1 kill VH0"_TABCHR_"// Page Break")
 .	D addcode^DBSRWUTL(1,"if 'vh(0) do VHDG0 quit:VFMQ")
 .	;
 .	F I=1:1:RPTINFO("LASTLVL") F SEC="H","D" I $D(RPTINFO("DSP",I,SEC)) D
 ..		I SEC="H" D  ; VHDGn
 ...			D addcode^DBSRWUTL(1,"do VHDG"_I_" quit:VFMQ")
 ...			Q 
 ..		E  D
 ...			; VDTLn
 ...			I RPTINFO("REPEATSIZE"),(RPTINFO("REPEATGRPLVL")=I) D addcode^DBSRWUTL(1,"set VR=VR+1,(VRG,VSEQ)=1"_TABCHR_"// Repeat field")
 ...			D addcode^DBSRWUTL(1,"if 'vskp("_I_").get() do VDTL"_I_" quit:VFMQ")
 ...			Q 
 ..		Q 
 .	;
 .	D addcode^DBSRWUTL(1,"do VSTAT")
 .	;
 .	D addcode^DBSRWUTL(1,"quit")
 .	D addcode^DBSRWUTL(0,"")
 .	Q 
 ;
 Q 
 ;
CONV(RPTINFO,ddmap) ; 
 ;
 N LINE
 N LVL N SEC
 ;
 S (LINE,LVL,SEC)="" S LVL=0
 F  S LVL=$order(RPTINFO("FMT",LVL)) Q:LVL=""  D
 .	S RPTINFO("DSP",LVL)=RPTINFO("FMT",LVL)
 .	F  S SEC=$order(RPTINFO("FMT",LVL,SEC)) Q:SEC=""  D
 ..		F  S LINE=$order(RPTINFO("FMT",LVL,SEC,LINE)) Q:LINE=""  D
 ...			N DECIMALS N ISCONST N ISDINAM N LN N POST N PREP N TAB
 ...			N CODE N FMAT N REF N SIZE N VAR N VAR1 N X N Z
 ...			S LN=LINE\1000 S TAB=LINE#1000
 ...			S X=RPTINFO("FMT",LVL,SEC,LINE)
 ...			S FMAT=$piece(X,"|",1)
 ...			S SIZE=$piece(X,"|",2)
 ...			S VAR=$translate($piece(X,"|",3),$char(128),"|") ; Restore "|"
 ...			S PREP=$piece(X,"|",4)
 ...			S POST=$piece(X,"|",5)
 ...			;
 ...			I FMAT="M" S RPTINFO("MEMOS")=1
 ...			;
 ...			S ISDINAM=$$isdi^DBSRWUTL(VAR)
 ...			S VAR1=$E(VAR,1)
 ...			;
 ...			; ~ = variable  @ = function  [ = data item
 ...			S ISCONST=1
 ...			I "+-"[VAR1,VAR?.E1"["1A.AN1"]"1E.E S ISCONST=0
 ...			I VAR1="[",ISDINAM S ISCONST=0 ; dinam
 ...			E  I VAR1="@" D  ; @function
 ....				S (ISCONST,ISDINAM)=0
 ....				S REF="V"
 ....				Q 
 ...			E  I VAR1="~" D  ; ~variable
 ....				S (ISCONST,ISDINAM)=0
 ....				S REF=$E(VAR,2,1048575)
 ....				I REF'?.E1"_["1E.E1"]"1E.E Q  ; ~variable
 ....				S REF=$$MIXED(REF,.ddmap) ; convert [FID]DI
 ....				Q 
 ...			I ISDINAM S REF=$$map^DBSRWUTL(VAR,.ddmap,1) ; [fid]di -> vn
 ...			;
 ...			S DECIMALS=""
 ...			I FMAT="$" S DECIMALS=2
 ...			;
 ...			I ISCONST D  ; String data
 ....				S CODE=""""_VAR_""""
 ....				S REF=CODE
 ....				Q 
 ...			E  D
 ....				I '$$ISVAR(VAR),FMAT'="M" S CODE=REF
 ....				E  S CODE=$$FMT(FMAT,SIZE,LINE,DECIMALS,REF)
 ....				Q 
 ...			I $E(CODE,1)="~" S CODE=$E(CODE,2,$L(Z))
 ...			S Z=CODE ; Formatted reference
 ...			I PREP!POST D  ; Save value in V and VO
 ....				S Z=""
 ....				I REF?1"vc".E D
 .....					S Z="set V="_REF_",VO=V "
 .....					; Formatted reference to V
 .....					S CODE=$piece(CODE,REF,1)_"V"_$piece(CODE,REF,2,9)
 .....					Q 
 ....				I PREP S Z=Z_"do VP"_PREP_" quit:VFMQ!verror.get()  "
 ....				; Data item protection
 ....				I RPTINFO("RESFLG") S CODE=$$PROT(VAR,SIZE,CODE,.RPTINFO,.ddmap)
 ....				S Z=Z_"set V="_CODE_" " ; Formatted value
 ....				I POST S Z=Z_"do VP"_POST_" quit:VFMQ!verror.get()  "
 ....				Q 
 ...			; Data item protection, if no pre/post-processor
 ...			E  I RPTINFO("RESFLG") S Z=$$PROT(VAR,SIZE,Z,.RPTINFO,.ddmap)
 ...			S RPTINFO("DSP",LVL,SEC,LN,TAB)=Z
 ...			Q 
 ..		Q 
 .	Q 
 Q 
 ;
PROT(DINAM,LENGTH,CODE,RPTINFO,ddmap) ; 
 ;
 N ASTRSKS N TC N VARNAM N X
 ;
 S ASTRSKS="" S $piece(ASTRSKS,"*",LENGTH+1)="" ; Display ******
 I '$$validtcr^DBSRWUTL(DINAM,.TC) Q CODE ; Leave it alone if not data
 D STATUS^UPID($piece(TC,".",1),$piece(TC,".",2),.X) ; Check protection status
 I 'X Q CODE ; No protection on this data
 S VARNAM="vp"_$E(ddmap(TC),3,8) ; Variable name for protection flag
 D addvars^DBSRWUTL("VPTYPE",VARNAM,.RPTINFO)
 S X="$S("_VARNAM_"=3:"_""""_$E(ASTRSKS,1,LENGTH)_""""_",1:"_CODE_")"
 ;
 Q X
 ;
FMT(TYP,L,LINE,DEC,VAL) ; 
 ;
 N CODE
 ;
 I TYP="M" Q "$$MEMO("_VAL_","_LINE_","_L_")"
 ;
 I TYP["$",'$get(DEC) S DEC=2
 S CODE=$$fmtstr^DBSRWUTL(L,TYP,DEC)
 Q $$replace^DBSRWUTL(CODE,"V",VAL) ; Replace V with VAL
 ;
MEMO ; Private - Set up code to print memo - break across lines if necessary
 ;
 N CODE N TABCHR
 ;
 S TABCHR=$char(9)
 ;
 S CODE="MEMO(String MEMO,Number LINE,Number SIZE)"
 S CODE=CODE_TABCHR_"// Print all lines of memo, except last - return it in V"
 ;
 D addcode^DBSRWUTL(0,CODE)
 ;
 D addcode^DBSRWUTL(0,"")
 ;
 D addcode^DBSRWUTL(1,"type public Number IOSL,VFMQ,VLC")
 D addcode^DBSRWUTL(1,"type public String VL")
 D addcode^DBSRWUTL(1,"type Number I,TAB,VLLEN")
 D addcode^DBSRWUTL(1,"type String X")
 ;
 D addcode^DBSRWUTL(0,"")
 ;
 D addcode^DBSRWUTL(1,"set TAB=(LINE#1000)-1"_TABCHR_"// Location")
 ;
 D addcode^DBSRWUTL(1,"set MEMO=MEMO.trim()")
 ;
 ; If fits as is, just return it
 D addcode^DBSRWUTL(0,"")
 D addcode^DBSRWUTL(1,"if MEMO.length()'>SIZE quit MEMO")
 D addcode^DBSRWUTL(0,"")
 ;
 ; Otherwise, break into SIZE pieces, at spaces -- return last part
 ; VLLEN ensure correct leading padding for returned value
 D addcode^DBSRWUTL(2,"set VLLEN = VL.length()")
 ;
 D addcode^DBSRWUTL(1,"for  do { quit:VFMQ!(MEMO="""")")
 D addcode^DBSRWUTL(2,"set X=MEMO.extract(1,SIZE)")
 D addcode^DBSRWUTL(2,"if X["" "" do {")
 D addcode^DBSRWUTL(3,"for I=SIZE:-1:1 quit:X.extract(I)="" """)
 D addcode^DBSRWUTL(3,"set X=X.extract(1,I-1)")
 D addcode^DBSRWUTL(2,"}")
 D addcode^DBSRWUTL(2,"set MEMO=MEMO.extract(X.length()+1,MEMO.length())")
 D addcode^DBSRWUTL(2,"set X=X.trim()")
 D addcode^DBSRWUTL(2,"set MEMO=MEMO.trim() quit:MEMO.isNull()")
 D addcode^DBSRWUTL(2,"// Print this portion")
 D addcode^DBSRWUTL(2,"if VLC+1>IOSL do VHDG0 if VFMQ set VFMQ=1 quit")
 D addcode^DBSRWUTL(2,"set VL=VL_"""".justify(TAB-VL.length())_X do VOM")
 D addcode^DBSRWUTL(2,"set VL="""".justify(TAB)")
 D addcode^DBSRWUTL(1,"}")
 D addcode^DBSRWUTL(1,"set VL="""".justify(VLLEN)")
 D addcode^DBSRWUTL(1,"quit X")
 ;
 D addcode^DBSRWUTL(0,"")
 ;
 Q 
 ;
SETSTATS(dbtbl5h,RPTINFO) ; 
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
 ;
 N trgt
 ;
 S trgt=$P(vobj(dbtbl5h,11),$C(124),4) Q:trgt="" 
 D SETSTAT(1,$P(vobj(dbtbl5h,11),$C(124),1),trgt,$P(vobj(dbtbl5h,11),$C(124),5),.RPTINFO)
 S trgt=$P(vobj(dbtbl5h,12),$C(124),4) Q:trgt="" 
 D SETSTAT(2,$P(vobj(dbtbl5h,12),$C(124),1),trgt,$P(vobj(dbtbl5h,12),$C(124),5),.RPTINFO)
 S trgt=$P(vobj(dbtbl5h,13),$C(124),4) Q:trgt="" 
 D SETSTAT(3,$P(vobj(dbtbl5h,13),$C(124),1),trgt,$P(vobj(dbtbl5h,13),$C(124),5),.RPTINFO)
 S trgt=$P(vobj(dbtbl5h,14),$C(124),4) Q:trgt="" 
 D SETSTAT(4,$P(vobj(dbtbl5h,14),$C(124),1),trgt,$P(vobj(dbtbl5h,14),$C(124),5),.RPTINFO)
 S trgt=$P(vobj(dbtbl5h,15),$C(124),4) Q:trgt="" 
 D SETSTAT(5,$P(vobj(dbtbl5h,15),$C(124),1),trgt,$P(vobj(dbtbl5h,15),$C(124),5),.RPTINFO)
 S trgt=$P(vobj(dbtbl5h,16),$C(124),4) Q:trgt="" 
 D SETSTAT(6,$P(vobj(dbtbl5h,16),$C(124),1),trgt,$P(vobj(dbtbl5h,16),$C(124),5),.RPTINFO)
 S trgt=$P(vobj(dbtbl5h,17),$C(124),4) Q:trgt="" 
 D SETSTAT(7,$P(vobj(dbtbl5h,17),$C(124),1),trgt,$P(vobj(dbtbl5h,17),$C(124),5),.RPTINFO)
 S trgt=$P(vobj(dbtbl5h,18),$C(124),4) Q:trgt="" 
 D SETSTAT(8,$P(vobj(dbtbl5h,18),$C(124),1),trgt,$P(vobj(dbtbl5h,18),$C(124),5),.RPTINFO)
 S trgt=$P(vobj(dbtbl5h,19),$C(124),4) Q:trgt="" 
 D SETSTAT(9,$P(vobj(dbtbl5h,19),$C(124),1),trgt,$P(vobj(dbtbl5h,19),$C(124),5),.RPTINFO)
 S trgt=$P(vobj(dbtbl5h,20),$C(124),4) Q:trgt="" 
 D SETSTAT(10,$P(vobj(dbtbl5h,20),$C(124),1),trgt,$P(vobj(dbtbl5h,20),$C(124),5),.RPTINFO)
 S trgt=$P(vobj(dbtbl5h,21),$C(124),4) Q:trgt="" 
 D SETSTAT(11,$P(vobj(dbtbl5h,21),$C(124),1),trgt,$P(vobj(dbtbl5h,21),$C(124),5),.RPTINFO)
 S trgt=$P(vobj(dbtbl5h,22),$C(124),4) Q:trgt="" 
 D SETSTAT(12,$P(vobj(dbtbl5h,22),$C(124),1),trgt,$P(vobj(dbtbl5h,22),$C(124),5),.RPTINFO)
 S trgt=$P(vobj(dbtbl5h,23),$C(124),4) Q:trgt="" 
 D SETSTAT(13,$P(vobj(dbtbl5h,23),$C(124),1),trgt,$P(vobj(dbtbl5h,23),$C(124),5),.RPTINFO)
 S trgt=$P(vobj(dbtbl5h,24),$C(124),4) Q:trgt="" 
 D SETSTAT(14,$P(vobj(dbtbl5h,24),$C(124),1),trgt,$P(vobj(dbtbl5h,24),$C(124),5),.RPTINFO)
 S trgt=$P(vobj(dbtbl5h,25),$C(124),4) Q:trgt="" 
 D SETSTAT(15,$P(vobj(dbtbl5h,25),$C(124),1),trgt,$P(vobj(dbtbl5h,25),$C(124),5),.RPTINFO)
 S trgt=$P(vobj(dbtbl5h,26),$C(124),4) Q:trgt="" 
 D SETSTAT(16,$P(vobj(dbtbl5h,26),$C(124),1),trgt,$P(vobj(dbtbl5h,26),$C(124),5),.RPTINFO)
 S trgt=$P(vobj(dbtbl5h,27),$C(124),4) Q:trgt="" 
 D SETSTAT(17,$P(vobj(dbtbl5h,27),$C(124),1),trgt,$P(vobj(dbtbl5h,27),$C(124),5),.RPTINFO)
 S trgt=$P(vobj(dbtbl5h,28),$C(124),4) Q:trgt="" 
 D SETSTAT(18,$P(vobj(dbtbl5h,28),$C(124),1),trgt,$P(vobj(dbtbl5h,28),$C(124),5),.RPTINFO)
 S trgt=$P(vobj(dbtbl5h,29),$C(124),4) Q:trgt="" 
 D SETSTAT(19,$P(vobj(dbtbl5h,29),$C(124),1),trgt,$P(vobj(dbtbl5h,29),$C(124),5),.RPTINFO)
 S trgt=$P(vobj(dbtbl5h,30),$C(124),4) Q:trgt="" 
 D SETSTAT(20,$P(vobj(dbtbl5h,30),$C(124),1),trgt,$P(vobj(dbtbl5h,30),$C(124),5),.RPTINFO)
 Q 
 ;
SETSTAT(SEQ,SRC,TRGT,INC,RPTINFO) ; 
 ;
 ; Returns STAT(SEQ) = Source | Format | Target | Increments
 ;
 N DATA S DATA=""
 ;
 Q:TRGT="" 
 ;
 S $piece(DATA,"|",1)="["_$piece(SRC,",",2) ; Remove library
 S $piece(DATA,"|",2)=$$TYP^DBSDD(SRC) ; Get format
 S $piece(DATA,"|",3)="["_$piece(TRGT,",",2)
 S $piece(DATA,"|",4)=$translate(INC,",","|")
 S RPTINFO("STAT",SEQ)=DATA
 ;
 Q 
 ;
MIXED(INPUT,ddmap) ; data item map
 ;
 N I N LEN
 N FMT N REF N RETURN N TYPE N X
 ;
 S RETURN=""
 F I=1:1:$L(INPUT,"_") D
 .	S X=$piece(INPUT,"_",I) Q:X="" 
 .	S FMT=$piece(X,",",3,$L(X)) S X=$piece(X,",",1)
 .	I '$$validtcr^DBSRWUTL(X) S RETURN=RETURN_X ; String
 .	E  D
 ..		S REF=$$map^DBSRWUTL(X,.ddmap,1)
 ..		I FMT'="" D
 ...			S TYPE=$piece(X,",",2)
 ...			S LEN=$piece(X,",",3)
 ...			S REF=$$FMT(TYPE,LEN,"","",X)
 ...			Q 
 ..		S RETURN=RETURN_REF
 ..		Q 
 .	S RETURN=RETURN_"_"
 .	Q 
 ;
 Q $E(RETURN,1,$L(RETURN)-1)
 ;
BLDGETD(ddmap,RPTINFO) ; 
 ;
 ; Creates code to load data for a single row into mapped variables
 ;
 N I N LINENO
 N CODE N TC N TYPE N VARNAME N X
 ;
 D addcode^DBSRWUTL(0,"VGETDATA(String V,String VI)"_$char(9)_"//")
 ;
 D addcode^DBSRWUTL(1,"// Placeholder for type public",.LINENO)
 S TYPE=""
 ;
 F I=1:1:ddmap(0)-1 D
 .	S TC=ddmap(I)
 .	S VARNAME=ddmap(TC)
 .	S TYPE=TYPE_VARNAME_","
 .	S CODE="set "_VARNAME_"=V.piece(9.char(),"_I_")"_$char(9)_"// "_TC
 .	D addcode^DBSRWUTL(1,CODE)
 .	; If protection logic on, set protection indicator variables
 .	I RPTINFO("RESFLG") D
 ..		; Check protection status for this column
 ..		D STATUS^UPID($piece(TC,".",1),$piece(TC,".",2),.X)
 ..		I X D
 ...			S VARNAME="vp"_$E(VARNAME,3,8)
 ...			S TYPE=TYPE_VARNAME_","
 ...			D addvars^DBSRWUTL("VPTYPE",VARNAME,.RPTINFO)
 ...			S CODE="set "_VARNAME_"=VI.extract("_I_")"_$char(9)_"// Protection indicator"
 ...			D addcode^DBSRWUTL(1,CODE)
 ...			Q 
 ..		Q 
 .	Q 
 ;
 D addcode^DBSRWUTL(1,"quit")
 D addcode^DBSRWUTL(0,"")
 ;
 S CODE=$E(TYPE,1,$L(TYPE)-1)
 F  D  Q:(CODE="") 
 .	D addcode^DBSRWUTL(1,"type public String "_$piece(CODE,",",1,100),LINENO)
 .	S CODE=$piece(CODE,",",101,$L(CODE))
 .	S LINENO=LINENO+.01
 .	Q 
 ;
 Q 
 ;
BLDLOAD(TCREF,CODE1,CODE2,RPTINFO,ddmap) ; 
 ;
 N TC
 ;
 Q:TCREF="" 
 Q:'$$validtcr^DBSRWUTL(TCREF,.TC) 
 Q:'($D(ddmap(TC))#2) 
 S CODE1=CODE1_",vo"_ddmap(TC)_"=""""" ; voc = v "old"
 S CODE2=CODE2_",vo"_ddmap(TC)_"="_ddmap(TC)
 D addvars^DBSRWUTL("V0TYPE","vo"_ddmap(TC),.RPTINFO)
 Q 
 ;
BLDSELCT(ddmap,RPTINFO,TABLVL) ; 
 ;
 N DYNWHERE N I
 N CODE N FILES N FROM N ORDER N PARAMS N SELECT N WHERE
 ;
 F I=1:1:$L(RPTINFO("TABLES"),",") S FILES($piece(RPTINFO("TABLES"),",",I))=""
 ;
 ; Build order by
 S ORDER=""
 F I=1:1:RPTINFO("LASTLVL") D
 .	N COLUMN N TABLE N TC N X
 .	;
 .	S X=RPTINFO("SEQBY",I,"COL")
 .	Q:'$$validtcr^DBSRWUTL(X,.TC) 
 .	S ORDER=ORDER_","_TC
 .	I RPTINFO("SEQBY",I,"SORTORD")="D" S ORDER=ORDER_" DESC"
 .	Q 
 ;
 S RPTINFO("ORDERBY")=$E(ORDER,2,1048575)
 ;
 S SELECT=""
 F I=1:1 Q:'($D(ddmap(I))#2)  D
 .	N TC
 .	S TC=ddmap(I)
 .	I '$D(FILES($piece(TC,".",1))) WRITE !,"Invalid column: ",ddmap(I)
 .	S SELECT=SELECT_TC_","
 .	Q 
 S SELECT=$E(SELECT,1,$L(SELECT)-1)
 S RPTINFO("SELECT")=SELECT
 ;
 S FROM=$S(ddmap'["""":""""_ddmap_"""",1:$$QADD^%ZS(ddmap,""""))
 ;
 ; WHERE="" => dynamic query, i.e., will construct at run-time
 S WHERE=RPTINFO("WHERE")
 ;
 S CODE="type ResultSet rwrs=Db.select("
 ; dynamic SQL
 I ((WHERE="")&RPTINFO("QUERIES"))!RPTINFO("DYNORDERBY")!RPTINFO("DYNWHERE") D
 .	S CODE=CODE_"VSELECT,"_FROM_",VWHERE,"
 .	S DYNWHERE=1
 .	Q 
 E  D
 .	S CODE=CODE_""""_SELECT_""","_FROM_","_$S(WHERE'["""":""""_WHERE_"""",1:$$QADD^%ZS(WHERE,""""))_","
 .	S DYNWHERE=0
 .	Q 
 ;
 I 'RPTINFO("DYNORDERBY") S CODE=CODE_""""_RPTINFO("ORDERBY")_""""
 E  S CODE=CODE_"vorder"
 ;
 S PARAMS="DQMODE=1" ; Handle joins
 ; Data item protection
 I RPTINFO("RESFLG") S PARAMS=PARAMS_"/PROTECTION="_RPTINFO("RESFLG")
 ;
 S CODE=CODE_","""","""_PARAMS_""")"
 ;
 ; Open pre-processor
 I '($order(RPTINFO("SUBS","OPRE",""))="") D addcode^DBSRWUTL(TABLVL,"do VOPRE if VFMQ do VEXIT(0) quit")
 ;
 ; If generating dynamic SQL set up SELECT list at run time to avoid line
 ; getting too long in routine.
 ;
 I DYNWHERE D
 .	N VSELECT S VSELECT=SELECT
 .	;
 .	D addcode^DBSRWUTL(0,"")
 .	;
 .	I $L(VSELECT)'>50 D addcode^DBSRWUTL(TABLVL,"set VSELECT="_$S(VSELECT'["""":""""_VSELECT_"""",1:$$QADD^%ZS(VSELECT,"""")))
 .	E  D
 ..		D addcode^DBSRWUTL(TABLVL,"set VSELECT=""""")
 ..		F  D  Q:VSELECT="" 
 ...			D addcode^DBSRWUTL(TABLVL,"set VSELECT=VSELECT_"_$$QADD^%ZS($E(VSELECT,1,50),""""))
 ...			S VSELECT=$E(VSELECT,51,1048575)
 ...			Q 
 ..		Q 
 .	D addcode^DBSRWUTL(0,"")
 .	Q 
 ;
 ; If dynamic order by or user input where clause, set up default WHERE clause
 ; and make sure vorder is defined
 I RPTINFO("DYNORDERBY")!RPTINFO("DYNWHERE") D
 .	N WHERE S WHERE=RPTINFO("WHERE")
 .	;
 .	I $L(WHERE)'>50 D addcode^DBSRWUTL(TABLVL,"set VWHERE="_$S(WHERE'["""":""""_WHERE_"""",1:$$QADD^%ZS(WHERE,"""")))
 .	E  D
 ..		D addcode^DBSRWUTL(TABLVL,"set VWHERE=""""")
 ..		F  D  Q:WHERE="" 
 ...			D addcode^DBSRWUTL(TABLVL,"set VWHERE=VWHERE_"_$$QADD^%ZS($E(WHERE,1,50),""""))
 ...			S WHERE=$E(WHERE,51,1048575)
 ...			Q 
 ..		Q 
 .	I RPTINFO("DYNORDERBY") D addcode^DBSRWUTL(TABLVL,"if 'vorder.exists() set vorder="""_RPTINFO("ORDERBY")_"""")
 .	I RPTINFO("DYNWHERE") D addcode^DBSRWUTL(TABLVL,"if vudwhere.exists() set VWHERE=vudwhere")
 .	Q 
 ;
 ; Add accept to avoid compiler warning on dynamic where clause
 I DYNWHERE D addcode^DBSRWUTL(TABLVL,"#ACCEPT DATE="_$$vdat2str($P($H,",",1),"MM/DD/YEAR")_";PGM=Report Writer Generator;CR=20967")
 ;
 D addcode^DBSRWUTL(TABLVL,CODE)
 D addcode^DBSRWUTL(TABLVL,"#ACCEPT Date=10/13/2008;Pgm=RussellDS;CR=35741;Group=READ")
 D addcode^DBSRWUTL(TABLVL,"if ER.get() use 0 write $$MSG^%TRMVT(RM.get(),"""",1)"_$char(9)_"// Debug Mode")
 ; Open post-processor
 I '($order(RPTINFO("SUBS","OPOST",""))="") D addcode^DBSRWUTL(TABLVL,"do VOPOST if VFMQ do VEXIT(0) quit")
 Q 
 ;
ISVAR(X) ; Private - Return 1 if X is a valid variable name
 ;
 N OK S OK=0
 ;
 I $E(X,1)'="~" S OK=1
 E  D
 .	I X["(",X[")",X'["$" S X=$piece(X,"(",1)
 .	I X?1"~"1AN.AN!(X?1"~%".AN) S OK=1
 .	Q 
 Q OK
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61431^64028^Dan Russell^34906" ; Signature - LTD^TIME^USER^SIZE
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
vdat2str(vo,mask) ; Date.toString
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I (vo="") Q ""
 I (mask="") S mask="MM/DD/YEAR"
 N cc N lday N lmon
 I mask="DL"!(mask="DS") D  ; Long or short weekday
 .	;    #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL
 .	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
 .	I (cc="") S cc="US"
 .	;    #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL
 .	S lday=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
 .	S mask="DAY" ; Day of the week
 .	Q 
 I mask="ML"!(mask="MS") D  ; Long or short month
 .	;    #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL
 .	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
 .	I (cc="") S cc="US"
 .	;    #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL
 .	S lmon=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
 .	S mask="MON" ; Month of the year
 .	Q 
 ;  #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=BYPASS
 ;*** Start of code by-passed by compiler
 set cc=$ZD(vo,mask,$G(lmon),$G(lday))
 ;*** End of code by-passed by compiler ***
 Q cc
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
vOpen1() ; GRP,RPTFROM,RPTTO,RPTSIZE,RPTCNT FROM DBTBL5DGC WHERE LIBS='SYSDEV' AND RID=:RID AND RPTSIZE > 0
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(RID) I vos3="" G vL1a0
 S vos4="@"
vL1a4 S vos4=$O(^DBTBL("SYSDEV",5,vos3,vos4),1) I vos4="" G vL1a0
 S vos5=$G(^DBTBL("SYSDEV",5,vos3,vos4,25))
 I '($P(vos5,"|",3)>0) G vL1a4
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
 S vos5=$G(^DBTBL("SYSDEV",5,vos3,vos4,25))
 S rs=$S(vos4=vos2:"",1:vos4)_$C(9)_$P(vos5,"|",1)_$C(9)_$P(vos5,"|",2)_$C(9)_$P(vos5,"|",3)_$C(9)_$P(vos5,"|",4)
 ;
 Q 1
