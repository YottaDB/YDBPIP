FORMVAR5	;; -  - V5.0 - Form system, object definition ( report writer )
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 01/02/97 09:56:26 - CHIANG
	;     ORIG:  CHIANG - 01/24/90
	;     DESC:  OOE RW editor
	;
	; I18N=QUIT	Excluded from I18N Standards
	; ---------- Revision History ------------------------------------------
	; 07/14/06 - RussellDS - CR22121
	;	     Replaced  $C with $$BTYECHAR^SQLUTL to ensure Unicode 
	;	     compliance.
	;
	; 01/02/96 - Bob Chiang - 20948
	;            Modified DINAM section to return an error message for data
	;            items contain underscore character.
	;
	; 08/15/96 - Bob Chiang - 20948
	;            Modified DIREFDFT section to default in the correct field
	;            size for memo data field.
	;
	; 08/12/96 - Bob Chiang - 21195
	;            Modified VTAB section to increase the data item field size
	;            to 450 characters to accommodate complex expression.
	;
	; 07/09/96 - Phil Chenard - 22347
	;            Replace call to ^FORMBOX w/ call to BOX^%TRMVT to resolve
	;            problems on some platforms where the carriage return,
	;            $C(10) was interpretted differently.  Now calls will be
	;            made to the generic utility in BOX^%TRMVT.
	; 
	; 08/17/95 - Phil Chenard - 13005
	;            Replaced platform specific code with generic calls to 
	;            platform specific utility.
	;
	;----------------------------------------------------------------------
START	;
	;
	N OPT,OP,VOPTR,Z,Z1,ZNEW,ZZVAR,ZREAD,vtblrtn,status
	;
	K zztblfid
	;
	S VFMQ="Q",ZNEW=0,REPAINT=-1
	S vtblrtn="N X D VW^FORMVAR5",status=$G(STATUS)
	;
	I '$D(D(py,ox)) S ZNEW=1 G NEW
	;
	S X=$P(D(py,ox),dl,1)
	;
	I X?1"["1E.E1"]"1E.AN!(X?1"<<"1E.AN1">>")!(X?1"@".E) G START1
	;
	S ZZVAR=0 I X?1"<<"1E.E1">>" S X=$E(X,3,$L(X)-2),ZZVAR=1
	; 
	W BTMPAG S X=$$^FORMREAD(X,80,"Variable/Expression: ","T",1)
	I X="" Q
	I ZZVAR S X="<<"_X_">>"
	S $P(DQP,dl,1)=X
	S ZREAD=1
	G START1
	;
NEW	;
	;
	; ========== Create new object
	;
	; Data_item,Function,Var/Expr,Computed_Items,Marker,Header,Quick Layout
	;
	S OPT=$$^DBSMBAR(102) Q:'OPT	; *** BC - menu option 102 - 10/25/93
	;
	I OPT=1 G START1
	I OPT=2 D FUNC^FORMVAR6 Q:X=""  G START1
	I OPT=3 D MUMPS^FORMVAR6 Q:X=""  G START1
	I OPT=4 D COMPUTE^FORMVAR6 Q:X=""  G START1
	I OPT=5 D MARK^FORMVAR6 S REPAINT=0 Q
	I OPT=7 D QL^FORMDQ5C(),OFF^FORMSTAT S REPAINT=0,VFMQ="Q" Q	; 06/26/93 BC
	I OPT'=6 Q
	S Z=$P(^DBTBL(%LIBS,5,RID,0),"|",5)
	S Z1=$P(^CUVAR("DBS"),"|",2) I Z>80 S Z1=$P(^("DBS"),"|",3)
	I Z1'[":" S Z1=$$SCAU^%TRNLNM("HELP","OOE_"_Z1_".EXP")		;08/17/95
	D IMPORT^FORMEXCH(Z1) Q
	;
START1	;
	;
	; ========== Clear Region for OBJECT definiition
	;
	D CLRRGN^FORMFUN S REPAINT=0
	;
	S POSX=LFTX
	;
	I STATUS D OFF^FORMSTAT ; Remove status line
	;
	N VO
	;
	S TOPY=ORIGIN+1 ; First line of data definition box
	;
	D VBX,VPR,VDA,^DBSPNT(),VTAB Q
	;
VPR	; Build the prompts
	;
	N pr
	S VOPTR=7,VO="14|8|13"
	I $E(DQP)'="@" S VOPTR=5,VO="10|6|13" ; Drop last two prompts
	;
	S pr="Name:,Disp:,Size:,Pre:,Post:,Item:,Char:,Group/Report Stat:"
	S VO(1)=$$BYTECHAR^SQLUTL(TOPY)_$$BYTECHAR^SQLUTL(POSX+1)_$C(5,0,0,0,0,0,0,0)_"01T"_$p(pr,",",1)
	S VO(2)=$$BYTECHAR^SQLUTL(TOPY+1)_$$BYTECHAR^SQLUTL(POSX+1)_$C(5,0,0,0,0,0,0,0)_"01T"_$p(pr,",",2)
	S VO(3)=$$BYTECHAR^SQLUTL(TOPY+1)_$$BYTECHAR^SQLUTL(POSX+28)_$C(5,0,0,0,0,0,0,0)_"01T"_$p(pr,",",3)
	S VO(4)=$$BYTECHAR^SQLUTL(TOPY+2)_$$BYTECHAR^SQLUTL(POSX+2)_$C(4,0,0,0,0,0,0,0)_"01T"_$p(pr,",",4)
	S VO(5)=$$BYTECHAR^SQLUTL(TOPY+2)_$$BYTECHAR^SQLUTL(POSX+28)_$C(5,0,0,0,0,0,0,0)_"01T"_$p(pr,",",5)
	S VO(6)=$$BYTECHAR^SQLUTL(TOPY+3)_$$BYTECHAR^SQLUTL(POSX+1)_$C(5,0,0,0,0,0,0,0)_"01T"_$p(pr,",",6)
	I $E(DQP,1,4)="@CHR" S VO(6)=$$BYTECHAR^SQLUTL(TOPY+3)_$$BYTECHAR^SQLUTL(POSX+1)_$C(5,0,0,0,0,0,0,0)_"01T"_$p(pr,",",7)
	S VO(7)=$$BYTECHAR^SQLUTL(TOPY+4)_$$BYTECHAR^SQLUTL(POSX+1)_$C(18,0,0,0,0,0,0,0)_"01T"_$p(pr,",",8)
	I "@CHR,@TBL"'[$E(DQP,1,4) Q
	S VO(7)=$$BYTECHAR^SQLUTL(TOPY+4)_$$BYTECHAR^SQLUTL(POSX+1)_$C(1,0,0,0,0,0,0,0)_"01T "
	S $P(DQP,dl,5)=" "
	;
	Q
	;
VDA	; Print the data
	;
	N PX,PY
	;
	S PX=POSX+7,PY=TOPY
	;
	;
	; Name & format
	;
	S VO(VOPTR+1)=$$BYTECHAR^SQLUTL(PY)_$$BYTECHAR^SQLUTL(PX)_$C(26,0,0,0,0,0,0,0)_"01T"_$P(DQP,dl,1)
	S VO(VOPTR+2)=$$BYTECHAR^SQLUTL(PY+1)_$$BYTECHAR^SQLUTL(PX)_$C(20,0,0,0,0,0,0,0)_"01T"_$P(DQP,dl,2)
	S VO(VOPTR+3)=$$BYTECHAR^SQLUTL(PY+1)_$$BYTECHAR^SQLUTL(PX+27)_$C(3,0,0,0,0,0,0,0)_"01T"_$J($P(DQP,dl,3),3)
	S VO(VOPTR+4)=$$BYTECHAR^SQLUTL(PY+2)_$$BYTECHAR^SQLUTL(PX)_$C(1,0,0,0,0,0,0,0)_"01L"_$$YN(EDI(1))
	S VO(VOPTR+5)=$$BYTECHAR^SQLUTL(PY+2)_$$BYTECHAR^SQLUTL(PX+27)_$C(1,0,0,0,0,0,0,0)_"01L"_$$YN(EDI(2))
	I $E(DQP)'="@" G VDA1
	S VO(VOPTR+6)=$$BYTECHAR^SQLUTL(PY+3)_$$BYTECHAR^SQLUTL(PX)_$C(31,0,0,0,0,0,0,0)_"01T"_$P(DQP,dl,4)
	S VO(VOPTR+7)=$$BYTECHAR^SQLUTL(PY+4)_$$BYTECHAR^SQLUTL(PX+13)_$C(1,0,0,0,0,0,0,0)_"01T"_$P(DQP,dl,5)
VDA1	;
	I FILES="" Q
	;
	; ============ Displsy current Access files
	;
	W BTMPAG,FILES
	Q
	;
VW	D PUTRGN^FORMFUN(10_";"_LFTMAR,(BOTMAR-10)_";"_NUMCOL,1)
	;
	D VREPAINT Q
	;
VBX	D BOX^%TRMVT(ORIGIN,EXTANT) Q
	;
VREPRNT	D VPR,VDA,^DBSPNT() Q
	;
VREPAINT	D CLRRGN^FORMFUN,VBX,VDA,^DBSPNT() Q
	;
VTAB	; Build the %TAB(array)
	;
	N PX,PY,ZB
	;
	S PX=POSX+6,PY=TOPY-1
	;
	K REQ,UX,%TAB,%MOD S %MAX=7,OLNTB=24001,PGM=$T(+0)
	;
	S DLIB="SYSDEV",DFID="DBTBL2D",VFSN("DBTBL2D")="DQP",%VERSN=4
	;
	; Define look-up table
	;
	K ZGRP S ZGRP("G")="Group Statistics",ZGRP("R")="Report Statistics"
	;
	 S %TAB(1)=$$BYTECHAR^SQLUTL(PY)_$$BYTECHAR^SQLUTL(PX)_$C(26)_"01T00001|*DQP|[]NAME|||D DINAM^FORMVAR5|D DINAMPRE^FORMVAR5"
	S %TAB(2)=$$BYTECHAR^SQLUTL(PY+1)_$$BYTECHAR^SQLUTL(PX)_$C(20)_"01T00002|*DQP|[]DISP|^DBCTL(""SYS"",""RFMT"",||D PFMT^FORMVAR5"
	S %TAB(3)=$$BYTECHAR^SQLUTL(PY+1)_$$BYTECHAR^SQLUTL(PX+27)_$C(3)_"01N00003|*DQP|[]LGTH|||||0|510" I $P(DQP,dl,3)="" S REQ(3)=""
	S %TAB(4)=$$BYTECHAR^SQLUTL(PY+2)_$$BYTECHAR^SQLUTL(PX)_$C(1)_"01L|*EDI(1)|[]EDI(1)|||"
	S %TAB(5)=$$BYTECHAR^SQLUTL(PY+2)_$$BYTECHAR^SQLUTL(PX+27)_$C(1)_"01L|*EDI(2)|[]POST|||D POST^FORMVAR5"
	S %TAB(6)=$$BYTECHAR^SQLUTL(PY+3)_$$BYTECHAR^SQLUTL(PX)_$C(31)_"01T00004|*DQP|[]ZITEM|||D ITEM^FORMVAR5||||||450"	; *** BC 08/12/96
	S %TAB(7)=$$BYTECHAR^SQLUTL(PY+4)_$$BYTECHAR^SQLUTL(PX+13)_$C(1)_"01T00005|*DQP|[]ZGROUP|ZGRP(||D GRP^FORMVAR5"
	;
	S %O=$S($E(DQP)="#":2,1:1) I %O=2 K %TAB
	;
	; ========== Protect NAME field in update mode
	;
	I EDI(1)+EDI(2)>0 S UX=1
	I $P(DQP,dl,1)?1"@".E!$G(ZREAD) K %TAB(1) S UX=1
	I ZNEW,$P(DQP,dl,1)'="" K %TAB(1) S UX=1
	;
	I $E(DQP)'="@" K %TAB(6),%TAB(7) ; Skip ITEM & GROUP prompt
	I $E(DQP,1,4)="@CHR"!($E(DQP,1,4)="@TBL") K %TAB(7)
	;
	D ^DBSCRT8
	;
	I status D ON^FORMSTAT
	;
	Q
	;
POST	;
	;
	I $E(DQP)="[" S NI=99 Q
	I $P(DQP,dl,1)="@CNT" S NI=NI+1 Q  ; Skip ITEM prompt
	I $P(DQP,dl,1)?1"@".E1"(".E S NI=NI+2
	Q
ITEM	; PP for Function Item Name
	;
	N ZLIB,ZFID,ZDI,ZTBL,Z
	;
	I $E(DQP,1,4)="@CHR" Q
	;
	S ZTBL=""
	I X?1"["1A.AN1"]"1A.E D ITEM1 I ER Q
	;
	I $E(DQP,1,4)="@TBL" S:ZTBL="" ER=1,RM="Invalid look-up table reference" Q
	;
	I X?1"<<"1A.AN1">>"!(X?1"<<%".AN1">>") Q  ; <<var>> or <<%var>>
	I X?1"["1A.AN1"]"1A.E Q
	I X?1"<<"1E.E1">>" Q  ; <<computed operation>>
	; 
	S ER=1,RM="Valid format is [FID]DI or <<variable>>" Q
	;
	Q
ITEM1	; Verify data item name
	;
	S ZLIB=%LIBS,ZFID=$E($P(X,"]",1),2,99),ZDI=$P(X,"]",2)
	I '$D(^DBTBL(%LIBS,1,ZFID)) S ER=1,RM="Invalid file name" Q
	D ITEM2
	I $D(^DBTBL(ZLIB,1,ZFID,9,ZDI)) S ZTBL=$P(^(ZDI),"|",5) Q
	S ER=1,RM="Invalid data item" Q
	;
ITEM2	; Implicit Mode
	S Z=$P(^DBTBL(%LIBS,1,ZFID,10),"|",5) I Z="" Q
	S ZLIB=$E($P(Z,",",1),2,99)
	Q
GRP	;
	I X'="" Q
	I $P(DQP,dl,4)'="",$P(DQP,dl,1)'="@CNT" S ER=1,RM="Required" Q
	Q
DINAMPRE	;
	;
	S I(3)="@SELDI^DBSFUN(FILES,.X)"
	Q
DINAM	; Check for valid data item syntax
	;
	I X["_" S ER=1,RM=$$^MSG(1303,X) Q	; *** 01/02/96 invalid data item
	I X'="",X'["[",$G(zztblfid)'="" S X="["_zztblfid_"]"_X
	S I(3)=""
	;
	I V?1"<<"1E.E1">>",X?1"<<"1E.E1">>" Q
	;
	S ZVAR=0,UX=1
	S X=$$^FORMDIPP(X,FILES)
	;
	I %fkey="SEL"!(%fkey="FND") D VW
	S ZB=""
	I X="" Q
	I X?1"[".E1"]".E D DIREF Q
	;
	S ER=1,RM="Invalid format"
	Q
	;
	; NAME  or  [FID]NAME  or [LIB,FID]NAME
	;
DIREF	; Build a data item reference
	;
	S DI=$P(X,"]",2),FID=$E($P(X,"]",1),2,999)
	S LIB=$P(FID,",",1),FID=$P(FID,",",2)
	I FID="" S FID=LIB,LIB=$$LIBRARY^FORMVAR
	S LIB=$$IMPLIT(LIB,FID),NEWFID=FID
	;
	I $F((","_FILES_","),(","_FID_","))=0 S FILES=$$FILES(FILES,FID) I ER Q
	;
	I LIB=""!(FID="")!(DI="") S ER=1,RM="Invalid data item syntax "_X Q
	I '$D(^DBTBL(LIB,1,FID,9,DI)) S ER=1,RM="Invalid reference "_X Q
	;
	I $P(DQP,dl,1)'=X D DIREFDFT
	;
	S RM(2)=$P(DQP,dl,2)_$J("",20-$L($P(DQP,dl,2)))_"|2"
	S RM(3)=$J($P(DQP,dl,3),3)_"|3"
	;
	S TABLE=$P(DQP,dl,6)'=""
	S PTRN=$P(DQP,dl,9)'=""
	Q
	;
DIREFDFT	; Load attributes from the DD
	;
	N P S P=^(DI) F I=1:1:19 S P(I)=$P(P,"|",I)	; *** 08/15/96
	;
	I P(9)="$",P(14)=2 S P(9)="E" ; change to E format (BAL)
	I P(9)="N",P(14) S P(9)="RD"_P(14) ; change to RDn (IRN)
	I "UF"[P(9) S P(9)="T" ; change F & U to T format
	;
	I P(2)>132,P(19) S P(2)=P(19)			; Display size
	S DQP=X_dl_P(9)_dl_P(2)
	;
	I $P(DQP,dl,3) K REQ(3)
	S ER="W",RM=P(10) Q
	;
FILES(FILIST,FID)	; Add FID to FILIST after checking relationship
	;
	N (%LIBS,ER,FILIST,FID,RM)
	;
	S FILES=FID I FILIST'="" S FILES=FILIST_","_FID
	D ^DBSFVER
	I ER Q FILIST
	Q FILES
	;
IMPLIT(LIB,FID)	;
	;
	N Z,X
	I FID="" Q LIB
	S Z=LIB,X=$P($G(^DBTBL(LIB,1,FID,10)),"|",5)
	I X'="" S Z=$E($P(X,",",1),2,99)
	Q Z
	
	;
DIHELP	; provide data item help
	;
	W $$MSG^FORM("Data item lookup is not enabled",1) Q	
	;
PFMT	; Post processor for print format
	;
	D PP^DBSEXEP
	Q
CHK	;
	;
	S I=I+1
	I $P(X,",",I)="" Q
	S X(I)=$P(X,",",I)
	I X(I)?1"@"1E.E S X(I)=$E(X(I),2,99) ; Accumulation type
	;
	I $E(X(I),1,2)="RD" S RM=RM_", round decimal "_$E(X(I),3,99) G CHK
	I $E(X(I),1,2)="EM" S RM=RM_", format mask "_$E(X(I),3,99),I=999 G CHK
	I $E(X(I),1,2)="IN"!($E(X(I),1,2)="ID")!(X(I)?1"I$".N) S RM=RM_" , fixed length field" G CHK
	I '$D(^DBCTL("SYS","RFMT",X(I))) S ER=1,RM="Invalid print option "_X(I) Q
	S RM=RM_", "_$P(^(X(I)),"|",1)
	G CHK
	;
YN(X)	Q $$LOG^%ZM(X,%MSKL)
