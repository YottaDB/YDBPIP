FORMDQ5A	;; Save OOE Report Definition 
	;;Copyright(c)2003 Sanchez Computer Associates, Inc.  All Rights Reserved - 03/18/03 13:34:53 - RUSSELL
	;     ORIG:  CHIANG - 1/31/90
	;CALLED BY:  ^FORMDQ5
	;    CALLS:  
	;     DESC:  OOE REPORT WRITER FILER ROUTINE
	;
	; GLOBALS -  ^DBTBL
	;     READ:  
	;      SET:  
	;
	;    INPUT:  IMAGE(SEC,GRP,SEQ)=DATA
	;   OUTPUT:  ^DBTBL(%LIBS,5,RID,...
	;
	; ---------- Revision History ----------------------------------------
	; 07/14/06 - RussellDS - CR20048
	;	     Replaced $C(128) references with $$BYTECHAR^SQLUTL to ensure
	;	     Unicode compliance.
	;
	; 01/29/03 - Dan Russell - 51351
	;	     Modify to save blank lines in pre/post-processor code
	;
	; ---------------------------------------------------------------------
	;
START	;
	;
	N (%LIBS,RID,D,M,FILES,DBTBL5,PP,zrf,zsbl,zslf)
	;
	; First OBJECT on screen
	;
	S PY=$O(M("")) I PY="" Q  ; Blank screen
	S PX=$O(M(PY,""))
	I $P($G(D(PY,PX)),$C(0),1)'="#PAGE-HEADER" S D="#PAGE-HEADER",PY=0 D FILESEC
	;
	;
	S PY="",PX="",F=0,N="",XSEQ=1,OFFSET=0
	;
FILEY	S PY=$O(M(PY)) I PY="" D CREATE Q
FILEX	S PX=$O(M(PY,PX)) I PX="" G FILEY
	;
	;
	S D=$TR($G(D(PY,PX)),$C(124),$$BYTECHAR^SQLUTL(128)) ;	Convert | to $C(128)
	S M=$E(M(PY,PX),7,999),A=$E(M(PY,PX),1,6)
	S M=$TR(M,$C(124),$$BYTECHAR^SQLUTL(128))
	S D=$TR(D,$C(0),"|")
	;
	; ==========  Section Break ( #@PAGE  #@RS  #BAL )
	;
	I D?1"#".E D FILESEC G FILEX
	;
	F I=1:1:14 S F(I)=$P(D,"|",I)
	;
	S LOC=PY-OFFSET*1000+PX
	;
	S DINAM=F(1),DESC="",SN=$P(DINAM,"]",2)
	;
	I DINAM?1"["1E.E1","1E.E1"]"1E.E S DINAM="["_%LIBS_","_$P(DINAM,",",2) G REG
	I DINAM?1"["1E.E1"]"1E.AN,$P(DINAM,"]",2)?1E.AN,DINAM'[","
	I  S DINAM="["_%LIBS_","_$E(DINAM,2,99) G REG
	;
	I DINAM["[" S DESC=DINAM G FILE2
	;
	; ========== Text
	;
	I D="" S DESC=M,F(2)="T",F(3)=$L(M) G FILE2
	;
	; ========= <<var>>
	;
	I F(1)?1"<<"1E.E1">>",F(1)["," S DESC=F(1) G FILE2
	I $E(F(1),1,2)="<<",F(2)="T" S DESC=F(1) G FILE2
	I $E(F(1),1,2)="<<",F(2)'="T" S DESC=$P(F(1),">>",1)_","_F(2)_","_F(3)_">>" G FILE2
	;
	; ========== @FUN ( ITEM , GRP , FMT , SIZE )
	;
	I D?1"@CHR".E S DESC=F(1)_"("_F(4)_","_F(3)_")" G FILE2
	I D?1"@TBL".E S DESC=F(1)_"("_F(4)_")" G FILE2
	;
	I SEC["SUMMARY" S F(5)=0
	E  S F(5)=$S(F(5)="R":0,1:"")
	;
	; @CNT(grp,fmt,size)    @FUN(item,grp,fmt,size)
	;
	I F(1)="@CNT" S DESC=F(1)_"("_F(5)_","_F(2)_","_F(3)_")" G FILE2
	;
	; ??  Text data with PRE/POST PROC ?
	;
	S Z1=0 F Z="+","-","/","\","*" I F(1)[Z S Z1=1 ; Computed Operation
	I F(1)'?1"@"3A.E!Z1 S DESC=F(1)
	;
	E  S DESC=F(1)_"("_F(4)_","_F(5)_","_F(2)_","_F(3)_")"
FILE2	;
	S DINAM="@"_XSEQ,XSEQ=XSEQ+1,SN=DINAM
REG	;
	; loc | node | size | fmt | | [fid]di/@xxx | desc/<<var>>/@fun
	;
	S SEQ=$O(IMAGE(SEC,RGN,""),-1)+1
	;
	S IMAGE(SEC,RGN,SEQ)=LOC_"|"_SN_"|"_F(3)_"|"_F(2)_"||"_DINAM_"|"_DESC
	;
	; Pre/Post processor
	;
	I F(14) S $P(IMAGE(SEC,RGN,SEQ),"|",8)=F(14) ; POST
	I F(13) S $P(IMAGE(SEC,RGN,SEQ),"|",9)=F(13) ; PRE
	;	
	;
	S SEQ=SEQ+1
	;
	G FILEX
	;
	;
FILESEC	;
	;
	; Region size    IMAGE(SEC,RGN)=SIZE
	;                              SEQ)=DATA
	;
	S Z=$E($P(D,"|",1),2,999)
	;
	I Z'["[" G FILESEC0
	;
	F I=1:1:11 I ("["_$P($P($G(DBTBL5(I)),"|",1),",",2))=$P(Z,"-",1) Q
	I I=11 Q  ; Invalid marker
	;
FILESEC0	;
	I $G(OLDSEC)'="" S IMAGE(OLDSEC,OLDRGN)=PY-OLDPY-1
	;
	S SEC=$P(Z,"-",1),RGN=$E($P(Z,"-",2))
	;
	S RGN=$E(RGN,1),OFFSET=PY
	I RGN'="" G FILESEC1
	;
	I SEC="SUMMARY" S RGN="H"
	E  S RGN="D"
	;
FILESEC1	;
	; Save last marker definition
	;
	S OLDSEC=SEC,OLDRGN=RGN,OLDPY=PY
	Q
	;
	;
	; =========== Create Report Definition
CREATE	;
	S IMAGE(OLDSEC,OLDRGN)=$O(M(""),-1)-OLDPY
	;
	; ========== Delete key level definitions
	;
	K ^DBTBL(%LIBS,5,RID)
	;
	S PFID=$P(FILES,",",1)
	;
	S ^DBTBL(%LIBS,5,RID)=DBTBL5
	;
	; Sequence   Query   Stat   Report Pre/Post Processors
	;
	S Z="",Z1=""
	F  S Z=$O(DBTBL5(Z)) Q:Z=""  S:$D(DBTBL5(Z))#10 ^DBTBL(%LIBS,5,RID,Z)=DBTBL5(Z) F  S Z1=$O(DBTBL5(Z,Z1)) Q:Z1=""  S ^DBTBL(%LIBS,5,RID,Z,Z1)=DBTBL5(Z,Z1)
	;
	S KEY=""
	;
NKEY	;
	S KEY=$O(IMAGE(KEY)) I KEY="" Q
	;
	S LEV=KEY
	;
	I LEV="PAGE" S LEV="@PH"
	I LEV="SUMMARY" S LEV="@RS"
	I LEV?1"@"1E.E G NKEY1
	;
	I LEV'["[" S LEV="["_%LIBS_","_PFID_"]"_LEV
	I LEV'["," S LEV="["_%LIBS_","_$E(LEV,2,99)
NKEY1	;
	;
	;
	F I="H","D","T" I '$G(IMAGE(KEY,I)) S IMAGE(KEY,I)=1
	;
	S ZKEY=KEY_"-H"
	S ^DBTBL(%LIBS,5,RID,LEV,0)=IMAGE(KEY,"H")_","_IMAGE(KEY,"D")_","_IMAGE(KEY,"T")
	;
	; Suppress LF option
	;
	I $D(zslf(ZKEY)),$O(IMAGE(KEY,"H",""))
	I   S ^DBTBL(%LIBS,5,RID,LEV,27)=$P(zslf(ZKEY),",",2)-zslf(ZKEY)
	;
	; Repeat Field Option
	;
	I '$D(zrf(KEY)) G NSEQ0
	I '$D(IMAGE(KEY,"D",1)) G NSEQ0
	;
	; From detail line ... To detail line
	;
	S Z1=IMAGE(KEY,"H")+2,Z2=Z1+IMAGE(KEY,"D")-1
	;
	; ---------- Repeat field definition
	;
	S ^DBTBL(%LIBS,5,RID,LEV,25)=Z1_"|"_Z2_"|"_zrf(KEY)
	;
NSEQ0	;
	; Merge SBL definitions from H,D,T sections
	;
	D SBL("H")
	D SBL("")
	D SBL("T")
	;
	S SEQ=101
	F I="H","D","T" D CREATE1
	G NKEY
	;
CREATE1	;
	I I="H" S PY=0
	I I="D" S PY=IMAGE(KEY,"H")+1
	I I="T" S PY=IMAGE(KEY,"H")+IMAGE(KEY,"D")+2
	;
	;
	S N=""
NSEQ	;
	S N=$O(IMAGE(KEY,I,N)) I N="" Q
	;
	S D=IMAGE(KEY,I,N),D=PY*1000+D_"|"_$P(D,"|",2,99)
	;
	; This section has been inserted to file pre & post processors
	;
	I $P(D,"|",8) D FILEPP(20,$P(D,"|",8)) S $P(D,"|",8)=1 ; Post proc
	I $P(D,"|",9) D FILEPP(0,$P(D,"|",9)) S $P(D,"|",9)=1 ; Pre proc
	;
	S ^DBTBL(%LIBS,5,RID,LEV,SEQ)=D,SEQ=SEQ+1
	;
	G NSEQ
	;
SBL(SEC)	;
	;
	N ZOFS,S1,S2,X,Y,ZKEY,CODE
	;
	S ZKEY=KEY
	I SEC'="",ZKEY'="SUMMARY" S ZKEY=ZKEY_"-"_SEC
	I ZKEY="PAGE-H" S ZKEY="PAGE-HEADER"
	I ZKEY="PAGE-T" S ZKEY="PAGE-TRAILER"
	;
	S CODE=$G(zsbl(ZKEY)) I CODE="" Q
	;
	;
	I SEC="H" S ZOFS=+CODE
	I SEC="" S ZOFS=CODE-^DBTBL(%LIBS,5,RID,LEV,0)-1
	I SEC="T" S ZOFS=CODE-^DBTBL(%LIBS,5,RID,LEV,0)-$P(^(0),",",2)-2
	;
	S S1=$L(CODE,",")
	S Y="" F S2=2:1:S1 D SLLF1
	I Y="" Q
	I $E(Y,$L(Y))="," S Y=$E(Y,1,$L(Y)-1)
	I '$D(^DBTBL(%LIBS,5,RID,LEV,26)) S ^DBTBL(%LIBS,5,RID,LEV,26)=Y
	E  S ^(26)=^(26)_","_Y
	Q
SLLF1	;
	S X=$P(CODE,",",S2)
	S Y=Y_(X-ZOFS)
	I X["-" S Y=Y_"-"_($P(X,"-",2)-ZOFS)
	S Y=Y_","
	Q
	;
FILEPP(OPT,KEY)	; File pre & post processors
	;
	N N,X,Y,Z
	S Y=1,Z=1 I $O(PP(KEY,""),-1)>20 S Z=0.001
	S N=""
	F  S N=$O(PP(KEY,N)) Q:N=""  S ^DBTBL(%LIBS,5,RID,LEV,SEQ,OPT+Y)=PP(KEY,N),Y=Y+Z
	Q
