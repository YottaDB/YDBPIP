DBSRWQR	;;DBS - UTL - V5.0 - QWIK REPORT CONVERSION
	;;Copyright(c)2003 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/13/03 14:08:48 - RUSSELL
	;     ORIG:  CHIANG - 26 OCT 1992
	;     DESC:  Convert QWIK report definition into RW format
	;
        ; I18N=QUIT: Exculded from I18N standards.
        ;---------- Revision History -------------------------------------------
        ; 12/04/2008 - Russell DS - CRs 35741/36952
        ;	* Modified calls to ^DBSITEM to function calls.
        ;
        ; 10/06/2008 - RussellDS - CRs 27817/35918
        ;	Modified call to ^DBSITEM for new signature.
        ;
        ; 06/06/2008 - RussellDS - CR30801
        ;	Fix RAW section to correct handling of di name. (v27 CR34006)
        ;
        ;	Modified section RAW to modify the data item list to a 
        ;	PSL result set format.  (v27 CR32918)
        ;
        ;	Removed old revision history.
	;
	;-----------------------------------------------------------------------
CONV	; Private ; Batch mode (input from keyboard)
	;-----------------------------------------------------------------------
	; Prompt for QWIK report name and the RW Report Name
	;
	N MSG,%READ,%FRAME
	;
	; From QWIK Report
	; To RW Report
	;
	S %TAB("QRID")=".DBSRWQR1"
	S %TAB("RID")=".DBSRWQR2"
	S %READ="@@%FN,,QRID/REQ,RID/REQ,"
	S %FRAME=2
	D ^UTLREAD I VFMQ="Q" Q
	D EXT(QRID,RID)				; Convert to RW format
	; Done
	W $$MSG^%TRMVT($$^MSG(855),"",1)
	Q
PP	; ---------- Post-Processor for Report Name prompt
	I X="" Q
	; Already exists
	I $D(^DBTBL(%LIBS,5,X)) S ER=1,RM=$$^MSG(253) Q
	Q
	;-----------------------------------------------------------------------
	;
EXT(QRID,RID)	; Private ; QWIK report to RW conversion 
	;-----------------------------------------------------------------------
	;
	; ARGUMENTS:
	;
	;  . QRID   QWIK Report Name		/TYP=T/REQ/LEN=12/MECH=VAL
	;
	;  . RID    Report Writer Report Name   /TYP=T/REQ/LEN=12/MECH=VAL
	;
	; INPUTS:
	;
	;  . %LIBS  Current DQ Library Name
	;
	; EXAMPLE:
	;
	;  D EXT^DBSRWQR("ABC","XYZ")
	;
	;-----------------------------------------------------------------------
	;
	N (%LIBS,QRID,RID)
	I $G(RID)="" S RID="QR_"_QRID		; Default to "QR_"_QRID
	;
	I $G(%LIBS)="" S %LIBS="SYSDEV"
	;
	I '$D(^DBTBL(%LIBS,6,QRID)) S ET="INVQR" D ^UTLERR Q
	;
	S input=$G(^DBTBL(%LIBS,6,QRID))	; Description
	;					; Copy into local array
	S X="" F  S X=$O(^DBTBL(%LIBS,6,QRID,X)) Q:X=""  S input(X)=^(X)
	;
	D EXEC(.input,RID)			; Build RW definition
	;
	Q
	;-----------------------------------------------------------------------
EXEC(input,RID)	; Private ; Main conversion routine
	;-----------------------------------------------------------------------
	;
	; ARGUMENTS:
	;
	;  . input    QWIK report definition		/TYP=T/REQ/REF=VAL
	;
	;             0        Contraol Page
	;             1-10     Queries
	;             12-17    Data Items
	;             21-40    Statistics
	;             101-199  Layout definiiton 
	;                      (dinam|heading|space|size|format|function|skip)
	;
	;  . RID      Report Name                       /TYP=T/REQ/REF=VAL
	;
	;-----------------------------------------------------------------------
	;
	N (%LIBS,QRID,RID,input)
	;
	S $P(input(0),"|",2)=$P($G(^DBTBL(%LIBS,5,RID,0)),"|",2) ; Save old pgm
	K ^DBTBL(%LIBS,5,RID)					; name
	;
	S rsseq=102,ln3="",WPS=0				; @RS sequence #
	S $P(line,"-",133)="",ITEMS=""				; --- Page Hdr
	S $P(line2,"=",133)=""					; === Summary
	S FILES=$P(input(0),"|",1)				; File Name
	S FMTOPT=$P(input(0),"|",20)				; Report Type
	I $G(FMTOPT)="" S FMTOPT="REPORT"			; Default format
	S DTL=1
	S QRDTL=$P(input(0),"|",4)				; Print Detail
	S BRK=$P(input(0),"|",11)				; Key Break
	S LABOPT=$P(input(0),"|",9)				; Label Option
	I 'LABOPT S LABOPT=1
	S BRKOPT=$P(BRK,"/",2,99),BRK=$P(BRK,"/",1)		; BREAK Options
	;							; *** 07/25/96
	I BRKOPT'="" S BRKOPT="/"_BRKOPT			; /qualifier
	;
	S zbrk=$P(BRK,"]",2)					; Item Name
	;
	I $G(input(12))?1"@WPS("1E.E1")" DO			; Mail/Merge
	.	S WPS=1,FMTOPT="LABEL"
	.	S WPS=WPS+$P(input(12),",",2)			; Form feed opt
	;
	F I=12:1:17 I $G(input(I))'="" S ITEMS=ITEMS_input(I)_","	; Data Items
	;
	S HDR=FILES_"|"_$P(input(0),"|",2)			; files,pgm
	S $P(HDR,"|",3)=+$H					; Date
	S RSIZE=$P(input(0),"|",5)
	S $P(HDR,"|",5)=$S(RSIZE<1:80,1:RSIZE)			; Report Width
	S $P(HDR,"|",6)=$S(FMTOPT="REPORT":60,1:99999999)	; Page size
	S $P(HDR,"|",7)=2					; Protection on *** 10/13/95 BC
	S $P(HDR,"|",10)=$G(^DBTBL)				; Version #
	;S $P(HDR,"|",13)=""					; *** V5.0 only ***
    	S $P(HDR,"|",13)=$P(input(0),"|",13)                    ; MSQL syntax (V5.1)
	S $P(HDR,"|",15)=$$USERNAM^%ZFUNC			; User Name
	I FMTOPT="REPORT" S $P(HDR,"|",16)=1			; Report Banner
	E  S $P(HDR,"|",9)=1					; Disable Browser
	I FMTOPT="FIXED" S $P(HDR,"|",8)=1			; Fixed length
	I FMTOPT="LABEL",WPS S $P(HDR,"|",17)=1			; Alignment Opt
	;
	S $P(HDR,"|",18)=1					; Use new compiler
	;
	S ^DBTBL(%LIBS,5,RID)=$G(input)		                ; Report Desc
	S ^DBTBL(%LIBS,5,RID,0)=HDR				; Control page
	;
	S fid=$P(FILES,",",1)					; Primary File
	I '$D(^DBTBL(%LIBS,1,fid)) S ER=1,RM=$$^MSG(1334,fid) Q	 ; Invalid file
	S keys=$P(input(0),"|",10),zkeys=keys			; Order By
	I keys'="" S keys=$$ORDERBY(keys),zkeys=keys		; *** 01/18/96
	E  S keys=^DBTBL(%LIBS,1,fid,16),zkeys=keys		; Access Keys
	S lastkey=$P(keys,",",$L(keys,","))			; Last key level
	I lastkey["[" S lastkey=$p(lastkey,"]",2)		; *** 07/25/96
	;
	I zbrk'="" D
	.	I keys["""" S zbrk=","_zbrk_","			; *** 03/28/95
	.	E  S zbrk=","_$P(keys,zbrk,1)_zbrk_","		; Display keys
	S rwkey="["_%LIBS_","_fid_"]"_$P(lastkey,"/",1)		; on grp header
	;
	S grpkey="" I HDR'="" D
      	.       F I=1:1:7 D                                     ; *** 05/10/96
        ..              S z=$P(keys,",",I) I z'["[" S z="["_fid_"]"_z
        ..              I z=BRK S grpkey=$P(keys,",",I+1) Q     ; *** match grp^
        I grpkey'="" D
        .       I grpkey["[" S grpkey="["_%LIBS_","_$P(grpkey,"[",2) Q
        .       S grpkey="["_%LIBS_","_fid_"]"_grpkey
        E  S grpkey=rwkey
	;-----------------------------------------------------------------------
	; Report Queries
	;-----------------------------------------------------------------------
	S SEQ=31 F I=1:1:10 I $G(input(I))'="" DO		; Queries
	. I input(I)?1A.E1"<<*".E S input(I)="["_fid_"]"_input(I)
	. S ^DBTBL(%LIBS,5,RID,SEQ)=input(I),SEQ=SEQ+1
	;							; Insert default
	I SEQ=31 DO
	.	Q						; queries (disable
	.	S n=$L(zkeys,",")				; <<**>> option
	.	F i=1:1:n S x=$P(zkeys,",",i) D
	..		I x'["[" s x="["_fid_"]"_x
	..		I x["""" Q				; Dummy keys
	..		I $P(x,"]",2)?1N.E Q			; *** 10/20/94 BC
	..		S ^DBTBL(%LIBS,5,RID,SEQ)=x_" <<**>>"	; [fid]di <<**>>
	..		S SEQ=SEQ+1
	;
	S scrsz=0,tab=0,ln=3001,(unln,ln1,ln2)="",Q="""",lnoff=0
	;
	;-----------------------------------------------------------------------
	; Statistics
	;-----------------------------------------------------------------------
	S Z=11 F I=21:1:40 I $P($G(input(I)),"|",1)'="" DO
	.	S ^DBTBL(%LIBS,5,RID,Z)=input(I),Z=Z+1
	;-----------------------------------------------------------------------
	; Report Sequence
	;-----------------------------------------------------------------------
	;
	S nkey=$L(zkeys,","),SEQ=1
	F I=1:1:nkey DO
	.	;
	.	S z=$P(zkeys,",",I)
	.	I z'["[" S node="["_%LIBS_","_fid_"]"_z	; di -> [lib,fid]di
	.	E  S node="["_%LIBS_","_$E(z,2,99)	; [fid]di -> [lib,fid]di
	.	S z=$P(node,"/",1),za="A" I $P(node,"/",2)="DESC" S za="D"
	.	S zpage=0 I $P(BRK,"]",2)=$P(z,"]",2),BRKOPT["/PAGE" S zpage=1
	.	I WPS=1 S zpage=1			; Form feed between doc
	.	S ^DBTBL(%LIBS,5,RID,SEQ)=z_"|"_zpage_"||*|"_za
	.	S SEQ=SEQ+1
	;
	I ITEMS="" S ^DBTBL(%LIBS,5,RID,rwkey,0)="1,1,1" Q
	;
	;-----------------------------------------------------------------------
	; @WPS(RMS) ; Mail/Merge Option
	;-----------------------------------------------------------------------
        I WPS D  Q
        .       N CHARSET,ET,PARAMS,RMS,X,dtl,pos,seq,size                     ; *** 02/29/96
        .       S RMS=$P($P(ITEMS,"(",2),")",1),RMS=$P(RMS,",",1)
        .	S CHARSET=""
	.	I $$VALID^%ZRTNS("UCIOENCD") S CHARSET=$$^UCIOENCD("Routine","DBSRWQR","*","*")
	.	I CHARSET="" S PARAMS="READ"
	.	E  S PARAMS="READ/ICHSET="_CHARSET
        .       S X=$$FILE^%ZOPEN(RMS,PARAMS,5)
	.	; File error
	.	I 'X S ER=1,RM=$$^MSG(8071) Q
        .       S pos=2001,seq=101
        .       F  S X=$$^%ZREAD(RMS,.ET) Q:ET  DO              ; End of File
	..		S X=$TR(X,$C(9)," ")			; Remove TABs
        ..              S pos=pos+1000,size=$L(X)
        ..              ;                                       ; *** 10/20 BC
        ..              I 'size Q                               ; Blank line
        ..              S dtl=pos_"|@|"_size_"|T||@|"_X
        ..              I X="" S X=" "
        ..              S ^DBTBL(%LIBS,5,RID,rwkey,seq)=dtl,seq=seq+1
        .       C RMS                                           ; *** 02/29/96
        .       S size=pos\1000-2                               ; Region size
        .       S ^DBTBL(%LIBS,5,RID,rwkey,0)="1,"_size_",1"    ;
        .       I WPS=1 S $P(^DBTBL(%LIBS,5,RID,0),"|",6)=size  ; Form length
        ;                                                       ; ***
	;----------------------------------------------------------------------
	; Output Raw data
	;-----------------------------------------------------------------------
	;
	I $G(input(11))'="" DO  Q			; Raw data format
	.	S ITEMS=$$FULLREF(FILES,ITEMS)		; [fid]di,...
	.	D RAW(input(11),ITEMS)
	;
	;-----------------------------------------------------------------------
	; Build Default Report Layout
	;-----------------------------------------------------------------------
	;
	I '$D(input(101)),ITEMS'="" DO				; Build Default
	.	N errmsg
	.	S errmsg=$$^DBSITEM(FILES,ITEMS,.LAYOUT)	; layout
	.	S X=0 F  S X=$O(LAYOUT(X)) Q:X=""  S input(100+X)=LAYOUT(X)
	;
	;-----------------------------------------------------------------------
	; Convert to RW layout definition
	;-----------------------------------------------------------------------
	;
	S ITEMS=$$FULLREF(FILES,ITEMS)				; [fid]di,...
	;
	S seq=101,tskip=1					; *** 12/13/95
	F I=101:1 Q:'$D(input(I))  DO				; Report Layout
	.	S x=input(I),dinam=$P(ITEMS,",",I-100)		; Data Item
	.	S zfid=$E($P(dinam,"]",1),2,99)
	.	;
	.	S di=$P(x,"|",1)				; data item
	.	S hdr=$P(x,"|",2),tb=$P(x,"|",3)		; Heading,tab
	.	S size=$P(x,"|",4),fmt=$P(x,"|",5)		; Size & Fmt
	.	S fun=$P(x,"|",6),skip=$P(x,"|",7)		; function,skips
	.	S hd1=$P(hdr,"@",1),hd2=$P(hdr,"@",2)
	.	S hd1=$E(hd1,1,size),hd2=$E(hd2,1,size)
	.	D HEADING
	.	S pos=ln+tab+tb,tab=tab+tb+size			; Position
	.	I tab>scrsz S scrsz=tab				; Report width
	.       ; Keep track total number of lines skipped      ; *** 12/13/95 BC
        .       S tskip=tskip+skip                              ; Lines skipped
	.	I skip S ln=skip*1000+ln,tab=0,lnoff=1		; New line
	.	;
	.	I fmt="L" S size=1				; Logical
	.	I '((di?1A.AN)!(di?1"%".AN)) DO
	..		I di[Q S dtl=pos_"|@|"_size_"|T||@|"_$P(di,Q,2) Q
	..		I $E(dinam)="[" S dtl=pos_"|@|"_size_"|"_fmt_"||@|"_dinam Q
	..		S dtl=pos_"|@|"_size_"|"_fmt_"||@|+"_dinam Q
	.	E  S dtl=pos_"|"_di_"|"_size_"|"_fmt_"||["_%LIBS_","_zfid_"]"_di
	.	;
	.	; --------- Key Break option (move keys to group header)
	.	;
	.	I DTL DO
      	..		S zzbrk=zbrk I zbrk'="",zbrk["[" S zzbrk=","_$P(zbrk,"]",2)
        ..		I zzbrk'="",zzbrk[(","_di_","),BRKOPT'["/DUP" D
	...			S dtl=dtl-2000_"|"_$P(dtl,"|",2,99)
	...			S n=$$SEQ(grpkey)
	...			S ^DBTBL(%LIBS,5,RID,grpkey,n)=dtl
	..		;	
	..	        E  S n=$$SEQ(rwkey),^DBTBL(%LIBS,5,RID,rwkey,n)=dtl
	.	;
	.	; ---------- Report Function SUM or CNT
	.	;
	.	I fun'="",FMTOPT="REPORT" DO
	..		S x=$$FUNCTION(dtl,fun) Q:x=""		; CNT,SUM
	..		S ^DBTBL(%LIBS,5,RID,"@RS",rsseq)=x,rsseq=rsseq+1
	..		S ^(0)="5,1,1"
	..		S pos1=+x#1000-1
	..		I $L(ln3)>pos1 Q			; New line
	..		S ln3=ln3_$J("",pos1-$L(ln3))_$E(line,1,size)
	;
	; Reset report detail region *** 12/13/95 BC
        S $P(^DBTBL(%LIBS,5,RID,rwkey,0),",",2)=tskip
	I FMTOPT="LABEL" S scrsz=LABOPT*42
	;
	; *** BC - Modified to convert 80/132 column QWIK report into same column width RW report 
	;
	S $P(^DBTBL(%LIBS,5,RID,0),"|",5)=$S(scrsz<81:80,scrsz<133:132,1:scrsz)
	;-----------------------------------------------------------------------
GRPSUM	; Group Summary
	;-----------------------------------------------------------------------
	;
	I FMTOPT'="REPORT" DO  Q
	.	S z=$O(^DBTBL(%LIBS,5,RID,rwkey,""),-1) Q:z=""
	.	S z=^(z)\1000-2
	.	I FMTOPT="LABEL",z<6 s z=6		; 6-line label
	.	S ^DBTBL(%LIBS,5,RID,rwkey,0)="1,"_z_",1"
	.	I FMTOPT="FIXED" Q
	.	S ^(25)="3|"_(z+2)_"|42|"_LABOPT	; Repeat Count 1 X 42
	.	S ^(26)="3-"_(z+2)			; Suppress Blank Lines
	;
	S offset=2000
	I rsseq>102,FMTOPT="REPORT" DO			; Key Break Option
	.	F I=1:1 Q:$E(ln3,I)'=" "
	.	S ln3=$E(ln3,I,999)			; Remove leading blanks
	.	S ^DBTBL(%LIBS,5,RID,"@RS",101)=1000+I_"|@|"_$L(ln3)_"|T||@|"_ln3
	.	I nkey<2 Q				; Single key
	.	I BRK="" Q				; Skip group summary
	.	;					; group total
	.	D PACKFLD(RID)
	.	S seq=$O(^DBTBL(%LIBS,5,RID,rwkey,999),-1)
	.	I 'seq Q
	.	S offset=^(seq)\1000+1*1000,seq=seq+1
	.	I BRKOPT["/TEXT=" D			; BREAK ON KEY/TEXT=...
	..		S TEXT=$P(BRKOPT,"TEXT=",2)
	..		S TEXT=$P(TEXT,"/",1)		; *** 07/25/96
	..		S ^DBTBL(%LIBS,5,RID,grpkey,seq)=offset+2001_"|@|20|T||@|"_TEXT
	..		S seq=seq+1
	.	;-------------------------------------------------
	.	; Copy report summary functions into group summary
	.	;-------------------------------------------------
	.       S seq=$$SEQ(grpkey)
        .       F I=101:1 Q:'$D(^DBTBL(%LIBS,5,RID,"@RS",I))  D
        ..              ; *** 12/13/95 BC
        ..              S sum=(tskip-1*1000+^(I)+offset)_"|"_$P(^(I),"|",2,99)
        ..              S ^DBTBL(%LIBS,5,RID,grpkey,seq)=sum,seq=seq+1
        ; *** 12/13/95  BC
        s ln=ln-(tskip-1*1000)                          ; Region of subtotal line
        S ^DBTBL(%LIBS,5,RID,grpkey,0)="1,"_tskip_","_(offset\1000-1)
	;
	I BRKOPT["SKIP=" D				; /SKIP=n
	.	S $P(^(0),",",3)=$P(^(0),",",3)+$P(BRKOPT,"SKIP=",2)-1
	;
        I 'QRDTL DO                                     ; Remove detail def
        .       S ZMIN=3000,ZMAX=$P(^(0),",",2)*1000+ZMIN
        .       K z
        .       F I=101:1 Q:'$D(^DBTBL(%LIBS,5,RID,rwkey,I))  D
        ..              I ^(I)<ZMIN!(^(I)>ZMAX) Q
        ..              K ^(I) I '$D(z) S z=I           ; *** 04/05/96
        .       S ^DBTBL(%LIBS,5,RID,rwkey,26)=3        ; Suppress blank line
        .       S ^(z)="3001|@|1|T||@|<<zzz>>||1"       ;
        .       S ^(z,1)=" S zzz="_""""""               ; Suppress line
        .       ;                                       ; *** End of changes
	;
	D PACKFLD(RID)			; Place items in line/column order
	;				; Replace - with = for report summary line
	I BRK'="",$D(^DBTBL(%LIBS,5,RID,"@RS",101)) D		; *** 03/28/95 BC
	.	S ^DBTBL(%LIBS,5,RID,"@RS",101)=$TR(^DBTBL(%LIBS,5,RID,"@RS",101),"-","=")
	;
	;-----------------------------------------------------------------------
RPTHDR	; Copy Standard Page Header SCA80 or SCA132
	;-----------------------------------------------------------------------
	;
	N LIB,ZRID,zln,tb,z
	S ZRID="SCA80" I scrsz>80 S ZRID="SCA132"
	I '$D(^DBTBL(%LIBS,5,ZRID)) Q			; Skip Header
	S x="" F  S x=$O(^DBTBL(%LIBS,5,ZRID,"@PH",x)) Q:x=""  DO
	.	S z=^(x)				; Skip temp RID info
	.	I RID?1"TMP"1N.N,z["<<RID>>" S z=$P(z,">>",1)_">>"
	.	S ^DBTBL(%LIBS,5,RID,"@PH",x)=z,ln=x
        ;                                               ; *** 12/13/95 BC
        S maxhdr=$O(header(""),-1)                      ; Number of header lines
        S lncnt=^DBTBL(%LIBS,5,RID,"@PH",0)+maxhdr,$P(^(0),",",1)=lncnt+maxhdr
	;
	S ln=ln+1,zln=lncnt*1000			; Column heading line 1
	;                                               ; *** 12/13/95
        F i=1:1:6 D COLHDR                              ; Create column heading
	S tb="",z="" F  S tb=$O(unln(tb)) Q:tb=""  D
	.	I z,z>tb Q
	.	S ^(ln)=(zln+tb)_"|@|"_$L(unln(tb))_"|T||@|"_unln(tb)
	.	S ln=ln+1,z=tb+$L(unln(tb))
	;                                               ; *** 12/13/95
        S $P(^DBTBL(%LIBS,5,RID,"@PH",0),",",1)=zln\1000 ; Size of header region
	Q
COLHDR  ; *** 12/13/95 BC
        ; Create column heading definition
        ;
        I '$D(header(i)) Q
        S tb="" F  S tb=$O(header(i,tb)) Q:tb=""  D
        .       S ^(ln)=(zln+tb)_"|@|"_$L(header(i,tb))_"|T||@|"_header(i,tb)
        .       S ln=ln+1
        S zln=zln+1000
        Q
	;-----------------------------------------------------------------------
HEADING	; Private ; Format column headings
	;-----------------------------------------------------------------------
	;
	N loc1,loc2
	S loc1=tab+tb+1,loc2=loc1
	S unln(loc1)=$E(line,1,size)			; Column Marker ---
	;
	I "TUF"'[fmt DO					; Heading format
	.	S loc1=loc1+size-$L(hd1)		; Right justified
	.	I hd2'="" S loc2=loc2+size-$L(hd2)
	;
	I hd1="",hd2="" Q				; No Column Heading
	I hd2'="" D HDRSET(1,loc1,hd1),HDRSET(2,loc2,hd2) ; Two-line heading
	E  D HDRSET(2,loc1,hd1)				; Move down one line
	Q
	;
HDRSET(ln,loc,hdr)					; *** 12/13/95 BC
	n z                                             ; Check overflow condition
        F  S z=$O(header(ln,""),-1) Q:z=""  Q:loc'<(z+$L(header(ln,z)))  s ln=ln+1
        s header(ln,loc)=hdr
	Q
	;-----------------------------------------------------------------------
FULLREF(FILES,ITEMS)	; Private ; Convert data item name to full reference [fid]dinam
	;-----------------------------------------------------------------------
	;
	; ARGUMENTS:
	;
	; . FILES       Access Files (primary,file..)	/TYP=T/REQ/REF=VAL
	; . ITEMS	Item names (item1,items,...)	/TYP=T/REQ/REF=VAL
	;
	; INPUTS:
	;
	; . %LIBS       Current DQ library		/TYP=T/REQ/REF=VAL
	;
	; RETURNS:
	;
	; . $$          New item names ([fid]di,...)	/TYP=T
	;-----------------------------------------------------------------------
	;
	N I,X,nfile,ref,di,OK,J,count,ptr
	;
	S ref="",count=$L(ITEMS,",")			; Total number of items
	S nfile=$L(FILES,",")				; Number of files
	F I=1:1:count DO
	.	S item=$P(ITEMS,",",I)
	.	I item="" Q				; NULL value
	.	I $E(item)="""" S ref=ref_item_"," Q	; "text"
	.	I $E(item)="[" S ref=ref_item_"," Q	; No need to convert
	.	I '((item?1A.AN)!(item?1"%".AN)) DO  Q
	..		S ref=ref_$$COMP(FILES,item)_"," ; Computed Operation
	.	;
	.	S OK=0 F J=1:1:nfile DO  Q:OK
	..		S di=$P(FILES,",",J)_"."_item	; [fid]di
	..		I '$$VER^DBSDD(di) Q		; Invalid file ref
	..		S OK=1,ref=ref_"["_$P(di,".",1)_"]"_$P(di,".",2)_"," Q
	;
	Q $E(ref,1,$L(ref)-1)
	;
	;-----------------------------------------------------------------------
COMP(FILES,EXP)	; Private ; Computed operation (covert variables to [fid]di syntax) 
	;-----------------------------------------------------------------------
	;
	; ARGUMENTS:
	;     . FILES   Access Files (file,file,...)	/TYP=T/REQ/MECH=VAL
	;     . EXP	Expression			/TYP=T/REQ/MECH=VAL
	;     
	;   RETURNS:
	;
	;     . $$      Data item expression		/TYP=T/MECH=VAL
	;
	;   EXAMPLE:    $$COMP("DEP","BAL*IRN")  returns [DEP]BAL*[DEP]IRN
	;-----------------------------------------------------------------------
	N ptr,x,str,fid,i,ok
	;
	S ptr=0,str=""
	F  S x=$$PARSE^DBSQRY(EXP,.ptr) Q:x=""  DO		; Next word
	.	I '((x?1A.AN)!(x?1"%".AN)) S str=str_x Q	; special
	.	S ok=0
	.	F i=1:1 S fid=$P(FILES,",",i) Q:fid=""  DO  Q:ok  ; Check all
	..		I '$$VER^DBSDD(fid_"."_x) Q		; Which file ?
	..		S str=str_"["_fid_"]"_x,ok=1
	.	I 'ok S ER=1,RM=$$^MSG(1300,x)		; Invalid data item name ~p1
	Q str							
	;-----------------------------------------------------------------------
FUNCTION(def,fun)	; Private ; Column functions SUM or CNT 
	;-----------------------------------------------------------------------
	N x,dinam,ln,col
	S x=def						; Detail definition
	;						; *** 01/18/96 BC
	S $P(x,"|",1)=$$LOC(x)				; Field location
	S $P(x,"|",2)="@",$P(x,"|",6)="@"
	I fun="CNT" D  Q x
	.	I +x<2000 S x=x+2000_"|"_$P(x,"|",2,99)
	.	S $P(x,"|",4)="N"				; Numeric format
	.	S $P(x,"|",7)="@CNT(,N,"_$P(x,"|",3)_")"	; @CNT function
	;
	I $P(def,"|",6)?1"@".E S dinam="<<"_$P(def,"|",7)_">>" ; @TOT(<<exp>>,...)
	E  S dinam="["_$P($P(def,"|",6),",",2)
	I fun="SUM" DO  Q x
	. S $P(x,"|",7)="@TOT("_dinam_",,"_$P(x,"|",4)_","_$P(x,"|",3)_")"
	Q ""
	;-----------------------------------------------------------------------
LOC(def) ; Calculate field position based on the location of thhe last object	
	;-----------------------------------------------------------------------
	N col,ln,pos,seq,x
	S seq=$O(^DBTBL(%LIBS,5,RID,"@RS",""),-1)	; Last sequence
	I seq<100 Q (def#1000)+2000  			; First object on line 2
	S x=^(seq),ln=x\1000,pos=x#1000+$P(x,"|",3)	; Attributes of last object
	S col=def#1000					; Current position
	I col>pos Q ln*1000+col				; Enough room on the same line
	Q ln+1*1000+col					; Place it on the next line
	;----------------------------------------------------------------------
RAW(OPT,LIST)	; Private ; Raw data format
	;-----------------------------------------------------------------------
	;
	; ARGUMENTS:
	;
	;  . OPT        Export Option (ASCII/LOTUS)	/TYP=T/REQ/MECH=VAL
	;  . LIST	Data items (di,di,...)		/TYP=T/REQ/MECH=VAL
	;-----------------------------------------------------------------------
	;
	N n,x,cnt,di,post,I,P,zfld,Q,code,fmt,string,len,ndi,nfid
	N nitem,nlist,seqfs,rs,eof,chr,hdr,header,dfmt,lfmt,cfmt,zfmt
	;
	I LIST["]" S cnt=$L(LIST,","),nfid="",ndi="",nitem="",nlist="" ; DQ FORMAT
	F I=1:1:cnt DO
	.	S nitem=$P(LIST,",",I)
	.	S nfid=$P(nitem,"]",1),ndi=$P(nitem,"]",2)
	.	S nfid=$E(nfid,2,$l(nfid))
	.	S nlist=nlist_","_"rwrs.getCol("""_nfid_"."_ndi_""")" ; PSL result set
	I nlist'="" S LIST=$E(nlist,2,$L(nlist))
	;
	;---------- Export definition
	;
	S $P(^DBTBL("SYSDEV",5,RID,0),"|",6)=99999999	; Remove page break logic 03/15/99 BC
	;
	S x=^STBL("TFMT",OPT)  				; *** 03/28/97
	S fs=$P(x,"|",3),rs=$P(x,"|",4),eof=$P(x,"|",5),chr=$P(x,"|",2)
	S hdr=$P(x,"|",6),dfmt=$P(x,"|",7),lfmt=$P(x,"|",8),cfmt=$P(x,"|",9)
	S fs="$C("_fs_")"
	S dfmt=$P(",MM/DD/YEAR,DD-MON-YY,DD-MON-YEAR",",",dfmt)
	S dfmt=""""_dfmt_""""					; Date format
	S cfmt=""""_$P(",24:60:SS",",",cfmt)_""""		; time format
	S Q="",seq=1 I chr'="" S Q="$C("_chr_")"
	F I=1:1:10 S header(I)=""				; *** 02/16/95
	;
	S n=$L(LIST,","),zfld="",string=" S zfld=",len=0
	F I=1:1:n DO
	.	N diname
	.	S di=$P(LIST,",",I) I di="" Q
	.	I di?1"rwrs.getCol".E S diname=$E(di,14,$L(di)-2)
	.	E  S diname=di
	.       S fmt=0,zfmt="T"
	.	I $E(di)="""" S fmt=1,len=len+$L(di)+1
	.	E  S len=len+$$LEN^DBSDD(diname)+1,zfmt=$$TYP^DBSDD(diname) I "TFU"[zfmt S fmt=1
	.	I di["*"!(di["/")!(di["+")!(di["-") s fmt=0
	.       I fmt,Q'="" S code=" S f"_I_"="_Q_"_("_di_")_"_Q,len=len+2 ; "Text"
	.	E  DO
	..		S z=di
	..		I zfmt="D" S z="$$DAT^%ZM("_di_","_dfmt_")"
	..		I zfmt="L",lfmt=1 S z="$$LOG^%ZM("_di_",$G(%MSKL))"
	..		I zfmt="C" S z="$$TIM^%ZM("_di_","_cfmt_")"
	..		S code=" S f"_I_"="_z
	.	S ^DBTBL(%LIBS,5,RID,rwkey,101,I-1/1000+1)=code	; Pre-Processor
	.	S string=string_"f"_I_"_"_fs_"_"
	.	I 'hdr Q
	.	S x=$P(diname,".",2) ;S x=$P(di,"]",2)
	.	S x=""""_$S(hdr=1:x,1:$$DES^DBSDD(diname))_""""	; Column Header
	.	I $L(header(seq))+$L(x)<240 S header(seq)=header(seq)_x_"_"_fs_"_" Q	; *** 02/16/95
	.	S seq=seq+1
	.	S header(seq)=x_"_"_fs_"_"
	;
	F I=1:1:10 I header(I)'="" D				; *** 02/16/95
	.	S header(I)=$P(header(I),fs,1,n)
	.	S header(I)=$E(header(I),1,$L(header(I))-1)
	S string=$P(string,fs,1,n),string=$E(string,1,$L(string)-1)
	S ^DBTBL(%LIBS,5,RID,rwkey,101,2)=string		; var=...
	S ^DBTBL(%LIBS,5,RID,rwkey,0)="1,1,1"			; Single line
	S ^(101)="3001|@|"_len_"|T||@|<<zfld>>||1"		; <<zfld>>
	S len=$S(len<81:80,len<133:132,1:len)			; Report width
	S $P(^DBTBL(%LIBS,5,RID,0),"|",5)=len,$P(^(0),"|",16)=0 ; Skip banner
	;
	; ---------- File Header
	;
	I header(1)'="" DO	
	.	S string="1001|@|"_$L(header(1))_"|T||@|<<zhdr>>||1"
	.	S ^DBTBL(%LIBS,5,RID,"@PH",0)="1,1,1"
	.	S ^(101)=string
	.	S ^(101,1)=" S zhdr="_header(1) 		; *** 02/16/95 BC
	.	F I=2:1:10 I header(I)'="" S ^(I)=" S zhdr=zhdr_"_header(I)
	;
	; ---------- End of file marker
	;
	I eof'="" DO
	.	S string="1001|@|"_$L(eof,",")_"|T||@|<<zeof>>||1"
	.	S ^DBTBL(%LIBS,5,RID,"@RS",0)="1,1,1"
	.	S ^(101)=string,^(101,1)=" S zeof=$C("_eof_")"
	Q
FORMAT(FMT)	; 
	I FMT="N" Q "IN"					; IN
	I FMT?1"RD"1N.N Q "I$"_$E(FMT,3,4)			; I$n
	I FMT="$" Q "I$S"					; I$S
	I FMT="E" Q "I$2"
	I FMT="D" Q "ID"					; ID
	I FMT="U"!(FMT="F") S FMT="T" Q FMT			;
	Q "T"
	;
	;-----------------------------------------------------------------------
SEQ(lev)	; Private ; Return next sequence number for this level 
	;-----------------------------------------------------------------------
	I $G(^DBTBL(%LIBS,5,RID,lev,0))="" S ^(0)="1,1,1"
	I '$D(^(101)) Q 101
	E  Q $O(^(999),-1)+1
	;
	;-----------------------------------------------------------------------
PACKFLD(RID)	; Private ; Pack report details in line/column order
	;-----------------------------------------------------------------------
	N i,key,pp,seq,DATA,n,ord
	I '$D(^DBTBL(%LIBS,5,RID)) Q
	; *** 7/25/96  Modified to pack every key level
	F i=1:1:10 I $D(^DBTBL(%LIBS,5,RID,i)) S key=^(i) D pack
	Q
pack	;
	S key=$P(key,"|",1)
	I '$D(^DBTBL(%LIBS,5,RID,key)) Q	; Sort fields in line/column order
	;
	S seq=100,ord=0
	F  S seq=$O(^DBTBL(%LIBS,5,RID,key,seq)) Q:seq=""  D
	.	I 'ord,seq'=101,^(seq)<n S ord=1
	.	S n=+^(seq)			; LLCCC (line,column)
	.	S data(n)=^(seq)
	.	S pp="" F  S pp=$O(^DBTBL(%LIBS,5,RID,key,seq,pp)) Q:pp=""  S data(n,pp)=^(pp)
	.	K ^DBTBL(%LIBS,5,RID,key,seq)
	S seq=101				; Copy it back
	S n="" F  S n=$O(data(n)) Q:n=""  D
	.	S ^DBTBL(%LIBS,5,RID,key,seq)=data(n)
	.	S pp="" F  S pp=$O(data(n,pp)) Q:pp=""  S ^DBTBL(%LIBS,5,RID,key,seq,pp)=data(n,pp)
	. 	S seq=seq+1			; Next sequence
	K data
	I ord k ^DBTBL(%LIBS,5,RID,key,27)	; Remove LF suppress option
	Q
	;-----------------------------------------------------------------------
ORDERBY(ord) ; Remove [fid] references and dummy keys
	;----------------------------------------------------------------------
	; Example:  [FEE]FEETYP,[FEE]CID,[FEE]75 returns 75,FEETYP,CID
	;----------------------------------------------------------------------
    	N di,dinam,i,keys,lit,n,zfid
        S n=$L(ord,","),keys="",lit=""                  ; *** 01/18/96
        F i=1:1:n D
        .       S dinam=$P(ord,",",i)                   ; *** 03/18/96
        .       S zfid=$E($P(dinam,"]",1),2,99)         ; File name
        .       I zfid'="",zfid'=fid S keys=keys_dinam_"," Q    ; Keep orig name
        .       S di=$P(dinam,"]",2)                    ; data item name
        .       I '((di?1A.AN)!($E(di)="%")) S lit=lit_di_"," Q  ; Save all dum
        .       S keys=keys_di_","
        S keys=lit_keys                                 ; Place dummy keys first
	Q $E(keys,1,$L(keys)-1)
	;-----------------------------------------------------------------------
QA	; Private ; convert QWIK report into RW format (Batch Mode)
	;-----------------------------------------------------------------------
	I $G(%LIBS)="" S %LIBS="SYSDEV"
  	D ^SCAIO U IO
        S QRID="" F  S QRID=$O(^DBTBL(%LIBS,6,QRID)) Q:QRID=""!(QRID]]"ZZZ")  D
        .       U 0 W !,QRID
        .       U IO W !,QRID,!
        .       K ^DBTBL(%LIBS,5,"Z")                           ; Delete old definition
        .       D EXT(QRID,"Z")                                 ; Convert to RW
        .       ZWR ^DBTBL(%LIBS,5,"Z",*)                       ; Global dump
        W !!
        C IO
        Q
	;----------------------------------------------------------------------
SQLRW(sqlexpr,RID,rtype) ;
	;----------------------------------------------------------------------
	; Convert MSQL SELECT command into a Report Writer report
	;
	; Example:  
	;	D SQLRW("CID,BAL,LNM,BOO FROM DEP WHERE CID<100","SCA999",5)
	;----------------------------------------------------------------------
	;
	N (%LIBS,sqlexpr,ER,RM,RID,rtype)
	;
	I $G(%LIBS)="" N %LIBS S %LIBS="SYSDEV"
	;
	I $G(RID)="" Q
	I $D(^DBTBL(%LIBS,rtype,RID)),'$$YN^DBSMBAR("","Overwrite existing report definition?",0) S ER=1 Q
	S ER=0
	S z=$$UPPER^SCAUTL(sqlexpr)
	I $E(z,1,7)'="SELECT " S ER=1,RM="Invalid SELECT statement" Q
	;
	S sqlexpr=$E(sqlexpr,8,999)				; Remove SELECT
	S z=$E(z,8,999)
	I $E(z,1,4)="ALL " S sqlexpr=$E(sqlexpr,5,999)		; Remove ALL
	I $E(z,1,9)="DISTINCT " S sqlexpr=$E(sqlexpr,10,999)	; Remove DISTINCT
	;
	; ----- Parse SELECT statement
	;
	S SELECT=$$TOK^SQL(sqlexpr,"INTO,FROM,WHERE,ORDER,GROUP",.tok)
	;
	; SELECT clause is required
	I $G(SELECT)="" S ER=1,RM=$$^MSG(8569) Q
	; FROM clause is required
	I $G(FROM)="" S ER=1,RM=$$^MSG(8561) Q
	;
	S SELECT=$$CONVQ(SELECT),SELECT=$$CONVDI(SELECT)
	S FROM=$$CONVQ(FROM)
	;
	S WHERE=$$UNTOK^%ZS($G(WHERE),.tok)
	;
	I $G(ORDER)'="" D
	.	;
	.	S ORDER=$P(ORDER,"BY ",2,999) 
	.	I ORDER[$C(0) S ORDER=$$UNTOK^%ZS(ORDER,.tok)
	.	I ORDER["""" S ORDER=$$QSUB^%ZS(ORDER)
	.	I ORDER[" DESC" S ORDER=$P(ORDER," DESC",1)_"/DESC"_$P(ORDER," DESC",2,99)
	.	S pfile=$P(FROM,",",1)			; Primary file
	.	D fsn^DBSDD(.vfsn,pfile)		; File attributes
	.	S order=""
	.	F i=1:1:$L(ORDER,",") D
	..		S key=$P(ORDER,",",i)
	..		S order(key)=""
	..		S order=order_",["_pfile_"]"_key
	.	S zkey=$P(vfsn(pfile),"|",3)		; Access keys
	.	F i=1:1:$L(zkey,",") D
	..		S key=$P(zkey,",",i)		; Add missing keys
	..		I '$D(order(key)) S order=order_",["_pfile_"]"_key
	.	S ORDER=$E(order,2,99)
	;
	; ----- Create default column definitions
	;
	S errmsg=$$^DBSITEM(FROM,SELECT,.COLUMN)
	F i=1:1:20 I $G(COLUMN(i))'="" S rw(100+i)=COLUMN(i)
	;
	S rw="MSQL report"				; Build report
	S rw(0)=FROM_"||"_+$H_"|1"			; Access files,date,dtl
	S $P(rw(0),"|",13)=1				; MSQL query
	S $P(rw(0),"|",15)=$$USERNAM^%ZFUNC		; User ID
	S rw(12)=SELECT					; Data items
	S rw(1)=$G(WHERE)				; Query
	S $P(rw(0),"|",10)=$G(ORDER)			; Order
	;
	I rtype=6 D  Q
	.	K ^DBTBL(%LIBS,6,RID)
	.	S ^DBTBL(%LIBS,6,RID)=rw
	.	S z="" F  S z=$O(rw(z)) Q:z=""  S ^DBTBL(%LIBS,6,RID,z)=rw(z)
	;
	D EXEC(.rw,RID)					; Create RW definition
	Q
	;----------------------------------------------------------------------
CONVQ(x) ; Remove double quotes and replace single quotes with double quotes
	;----------------------------------------------------------------------
	S x=$$UNTOK^%ZS(x,.tok)
	S x=$TR(x,$C(34),"")				; Remove double quotes
	S x=$TR(x,$C(39),$C(34))			; Change ' to ""
	Q x
	;----------------------------------------------------------------------
CONVDI(x) ; Convert FID.DI to [FID]DI
	;----------------------------------------------------------------------
	N di,i,v
	I x'["." Q x
	S v=""
	F i=1:1:$L(x,",") D
	.	S di=$P(x,",",i)
	.	I di'["." S v=v_","_di Q
	.	S v=v_",["_$P(di,".",1)_"]"_$P(di,".",2)
	Q $E(v,2,999)
	;
	;----------------------------------------------------------------------
QUERY(RID,type) ; Return report query syntax
	;----------------------------------------------------------------------
	N qry,i,MSQL,NI
	S qry=""
	I '$G(type) S type=6
	I '$D(^DBTBL(%LIBS,type,RID,0)) Q qry		; Invalid report  ;dmw 10/9/96 arq21547
	S MSQL=$P(^(0),"|",13)				; MSQL syntax ?
	I type=6 D  Q qry
	.	I MSQL D  Q				; MSQL
	..		F i=1:1:10 I $G(^(i))'="" S qry=qry_" "_^(i)
	.	F NI=1:1:10 D				; Regular DQ query
	..		S X=$G(^DBTBL(%LIBS,6,RID,NI))
	..		I X'="" D ^DBSQRY
	I type=5 D  Q qry
	.	I '$D(^DBTBL(%LIBS,5,RID,0)) Q
	.	S i=30.99
	.	F  S i=$O(^(i)) Q:i>50!(i?.E1A.E)  S qry=qry_" "_^(i)
	Q qry
