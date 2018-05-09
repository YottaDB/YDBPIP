DBSCRTNL(fields,fmq)	;Private; DATA-QWIK data input parser
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/17/97 11:00:53 - CHIANG
	;ORIG:  FSANCHEZ - 12 OCT 1990
	;
	; ARGUMENTS:
	;
	;	. fields	Number of prompts	/TYP=N/REQ/REF=VAL
	;	. fmq		VFMQ status		/TYP=N/REQ/REF=VAL
	;
	; INPUT:
	;	. %IPMODE=argexpr[:...]
	;
	; EXAMPLE:
	;
	;   UTLREAD utility:
	;	                    S %IPMODE="NOINT:ORDER %BLK/DEL=44"
	;   Queuing system:
	;                           S %IPMODE="NOINT:ORDER var/DEL=1"
	;   FSSP/DQRT server:
	;                           S %IPMODE="NOINT:ORDER var/DEL=1/NULL=127"
	;
	;---- Revision History -------------------------------------------------
	; 07/14/06 - RussellDS - CR22121
	;	     Replaced $A references with $$BSASCII^SQLUTL to ensure
	;	     Unicode compliance.
	;
	; 02/14/06 - RussellDS - CR19065
	;	     Change reference to delimiter to use DBTBL1, not the 
	;	     obsoleted delimiter from DBTBL1D.
	;
	; 02/17/97 - Bob Chiang - 23875
	;            Modified ORDERED section to not reset input pointer if in
	;            CSIS (GUI interactive) processing mode.
	;
	; 07/03/96 - Allan Mattson - 15587
	;            Modified subroutine VDFT to correct problem related to null
	;            fields.
	;
	;            Deleted pre-1994 revision history.
	;
	; 08/01/94 - Fan Zeng - ARQ 14465
	;            Deleted command SET %MODE, deleted %MODE in exclusive 
	;	     NEW command.
	;
	; 05/11/94  Bob Chiang - 10572
	;           Modified to support special field characters <DEL> for
	;           deletion and <NUL> for no change.
	;-----------------------------------------------------------------------
	; I18N=QUIT: Excluded from I18N standards
	;
START	N CMD,EXPR,LIB,VTAB,N,tree
	;
	S ER=0,LIB="SYSDEV"
	I '$D(NI) N NI S NI=1
	S fmq=$S($G(fmq):fields,1:0)
	D INIT,^DBSINT(%IPMODE,"CMD(") I ER Q
	F EXPR=1:1 S CMD=$G(tree(EXPR)) Q:CMD=""  D @CMD Q:ER
	;
	I ER Q
	I $G(%IPMODE)["NOINT" Q
	I $G(%OPMODE)["NOOUT" Q
	S N="" F  S N=$O(vdft(N)) Q:N=""  I vdft(N)="?" D  Q
	.	D RESET^DBSCRT8(N) S X=$$^DBSTBL(I(3),"",E8)
	Q
	;
	;----------------------------------------------------------------------
NAMED(AR,DEL,XTNL,FIXED,NULL)	; Named list
	;----------------------------------------------------------------------
	;
	I FIXED D NOOP Q
	N ARTYP,I,N,X,REF
	;
	I '$D(VTAB) D VTAB ;           Build table cross reference
	D ARSYN I ER Q
	;
	I '$D(%NOPRMT) S %NOPRMT="N"
	;
	I ARTYP="A" F  S N=$O(VTAB(N)) Q:N=""  D:$D(@AR) VDFT(VTAB(N),@AR)
	I ARTYP="A" Q
	;
	S DEL=$S(DEL="":"|",1:$C(DEL))
	;
	F N=1:1 S REF=$P(X,DEL,N) Q:REF=""  D
	.	S N=N+1
	.	S V=$P(X,DEL,N)
	.	I $E(V)="""" D QUOTE
	.	I $D(VTAB(REF)) D VDFT(VTAB(REF),V)
	Q
	;
	;----------------------------------------------------------------------
ADDRESSED(AR,DEL,XTNL,FIXED,NULL,PTR)	; Addressed list
	;----------------------------------------------------------------------
	;
	I FIXED D NOOP Q
	;
	N ARTYP,I,N,X,NI,ZNI
	D ARSYN I ER Q
	;
	I ARTYP="A" D NOOP Q  ;F  S N=$O(@AR) Q:N=""  D VDFT(N,@AR)
	;
	S N=PTR+1,ZNI=1
	S DEL=$S(DEL="":"|",1:$C(DEL))
	F N=N:1 S NI=$P(X,DEL,N) Q:NI>fields!(NI<ZNI)  S ZNI=NI,N=N+1,V=$P(X,DEL,N) D:$E(V)="""" QUOTE D VDFT(NI,V)
	;
	I NI<ZNI D INSPTR(N-1) Q  ;            New page or EOF
	I NI=fmq S N=N+1 D VFMQ($P(X,DEL,N)) ;         <FMQ> response
	D INSPTR(N)
	Q
	;
	;----------------------------------------------------------------------
ORDERED(AR,DEL,XTNL,FIXED,NULL,PTR)	; Ordered list
	;----------------------------------------------------------------------
	;
	N ARTYP,I,N,X
	D ARSYN I ER Q
	;
	S N=PTR+1
	I FIXED N LEN,Z G ORDFB
	I ARTYP="A" F N=N:1 Q:N>fields  D VDFT(N,$G(@AR))	; "Text"
	I ARTYP="A" D VFMQ($G(@AR)):(NI=fmq),INSPTR(N) Q	; "Text"
	;
	S DEL=$S(DEL="":"|",1:$C(DEL))
	;
	F N=N:1 Q:NI>fields  D
	.	S V=$P(X,DEL,N)
	.	I $E(V)="""" D QUOTE
	.	D VDFT(NI,V)
	.	S NI=NI+1
	;
	I NI'=fmq S N=N-1
	E  D VFMQ($P(X,DEL,N))
	I $G(%OPMODE)["PB" Q					; CSIS mode
	D INSPTR(N)						; Reset input data pointer
	Q
	;
	;----------------------------------------------------------------------
ORDFB	; Fixed block ordered list
	;----------------------------------------------------------------------
	;
	S ER=0
	;
	I '$D(vblksiz) N vblksiz S vblksiz=$$BLKSIZ D  I ER G ORDFB
	.	I $L(X)<vblksiz,$G(%OPMODE)["DEVICE BU" D  Q
	..		; Transmit from XMT
	..		D ERROR($$^MSG("2760"))
	..		D ERROR^DBSPNTB S X=MSG
	..		K vblksiz
	.	I $L(X)>vblksiz S X=$E(X,$L(X)-vblksiz+1,$L(X))
	.	I fmq,$E(X,$L(X)-1)="Q" S NI=fmq,N=$L(X)-1
	;
	I NI>fields G ORDFC
	;
	S Z=$$TAB^DBSCRT8(NI),LEN=$$BSASCII^SQLUTL(Z,3)
	I $E(Z,4)=2 S NI=NI+1 G ORDFB
	S V=$E(X,N,N+LEN-1),N=N+LEN
	I "N$"[$E(Z,6),'V S V=$TR(V," ")
	E  S V=$$RTB^%ZFUNC(V)
	D VDFT(NI,V)
	S NI=NI+1
	G ORDFB
	;
ORDFC	I NI=fmq S V=$$RTB^%ZFUNC($E(X,N,N+1)),N=N+2 D VFMQ(V)
	D INSPTR(N-1)
	Q
	;
	;----------------------------------------------------------------------
BLKSIZ()	; Return Block size for this %TAB array
	;----------------------------------------------------------------------
	;
	N vblksiz,I,Z
	S vblksiz=2
	F I=1:1:fields S Z=$$TAB^DBSCRT8(I) I $E(Z,4)'=2 S vblksiz=vblksiz+$$BSASCII^SQLUTL(Z,3)
	Q vblksiz
	;
	;----------------------------------------------------------------------
DATABASE(AR)	; Database list
	;----------------------------------------------------------------------
	;
	N ARRAY,FID,KEYS,N,VDB
	;
	I '$D(VTAB) D VTAB ;           Build table cross reference
	;
	S FID=$P(AR,"(",1),KEYS=$P($E(AR,1,$L(AR)-1),"(",2),ARRAY=$$ARRAY(KEYS)
	I ARRAY="" Q
	;
	; Undefined database record ~p1
	I '$D(@("^"_ARRAY_")")) D ERROR($$^MSG("2811",ARRAY)) Q
	;
	S N="" F  S N=$O(VTAB(N)) Q:N=""  D BLDNL
	Q
	;
	;----------------------------------------------------------------------
BLDNL	; Add a value to the DATA(Named_List) array if not defined
	;----------------------------------------------------------------------
	;
	I $P(N,".",1)'=FID Q  ;                        Not current table
	N AR,DL,PC,X
	;
	S X=$G(^DBTBL(LIB,1,$P(N,".",1),9,$P(N,".",2))) I X="" Q
	S AR=$P(X,"|",1),PC=$P(X,"|",21)
	S DL=$P($G(^DBTBL(LIB,1,$P(N,".",1),10)),"|",1)
	;
	I AR=LASTKEY S AR=ARRAY_")" ;          Data on bottom key
	E  S AR=ARRAY_","_AR_")" ;             Data on node level
	;
	I '$D(VDB(AR)) S X=$G(@("^"_AR)),VDB(AR)=X ; Load from global
	E  S X=VDB(AR)
	;
	I DL S X=$P(X,$C(DL),PC) ;             Position within record
	D VDFT(VTAB(N),X)
	Q
	;
	;----------------------------------------------------------------------
ARRAY(KEYS)	; Build global reference & insert keys
	;----------------------------------------------------------------------
	;
	N Y,X
	;
	S X=$G(^DBTBL(LIB,1,FID,0)) I X="" Q "" ;  Invalid reference
	S X=$P(X,"|",1)_"("
	F I=1:1 S Y=$G(^(I)) Q:Y=""  S X=X_$$CONSTANT(Y)_",",LASTKEY=Y
	Q $E(X,1,$L(X)-1)
	;
	;----------------------------------------------------------------------
CONSTANT(Y)	
	;----------------------------------------------------------------------
	;
	I Y=+Y Q Y
	I $E(Y)="""",$E(Y,$L(Y))="""" Q Y
	S Y=$P(KEYS,",",1),KEYS=$P(KEYS,",",2,99) Q Y
	;
	;----------------------------------------------------------------------
VTAB	; Build table cross reference
	;----------------------------------------------------------------------
	;
	I '$D(%TAB) Q
	;
	N ni,tbl,col,X
	;
	F ni=1:1:fields D
	.	;
	.	S X=%TAB(ni) I X="" S X=$$TAB^DBSCRT8(ni)
	.	;
	.	S tbl=$P($P(X,"|",3),"]",1),col=$P($P(X,"|",3),"]",2) I col="" Q
	.	I $E(tbl)="[" S tbl=$E(tbl,2,999)
	.	I $E(tbl)="*" S tbl=""
	.	I tbl["," S tbl=$P(tbl,",",2) ;      Library syntax included
	.	I %MODOFF'="",ni>%MODOFF S col=col_"("_$P($P(X,"|",2),"(",2)
	.	I tbl'="" S VTAB(tbl_"."_col)=ni Q
	.	S VTAB(col)=ni
	Q
	;
	;----------------------------------------------------------------------
VDFT(N,DEF)	; Add value to vdft(array) if different than original
	;----------------------------------------------------------------------
	;
	I '$D(%TAB(N)) S vdft(N)=DEF Q
	N AR,DATA,I,E5,E67,E8,E9,E12,X,vhdr
	;
	D RESET^DBSCRT8(N) ;                   Get header info %TAB(
	;
	; *** - BC - 04/12/94 - Convert client field input to DQ internal format
	I NULL D
	.	I DEF="" S DEF=V		; Get original value
	.	I DEF=$C(NULL) S DEF=""		; Change <del> to null value
	;
	I 'XTNL S DEF=$$EXTYP^DBSCRT8(DEF,E8,I(9)) ; Convert to Extyp
	;
	I '$D(vdft(N)) S vdft(N)=DEF
	E  S vdft(N)=DEF_"|"_vdft(N)
	Q
	;
	;----------------------------------------------------------------------
ARSYN	; Array syntax validation
	;----------------------------------------------------------------------
	;
	I $E(AR)="""" S ARTYP="N",X=$E(AR,2,$L(AR)-1) Q  ;  Literal
	;
	; Variable name syntax ~p1
	I $P(AR,"(",1)="" D ERROR($$^MSG("2930",AR)) Q		; Name syntax error
	; Not defined ~p1
	I '$D(@($P(AR,"(",1))) D ERROR($$^MSG("2038",AR)) Q	; Not defined
	;
	I $E(AR,$L(AR)-1,$L(AR))="#)" S ARTYP="A",AR=$E(AR,1,$L(AR)-2)_"N)",N="" Q
	S ARTYP="N",X=$G(@AR)
	Q
	;
	;----------------------------------------------------------------------
QUOTE	; Quoted string, reduce quoted and check for delimeter in string
	;----------------------------------------------------------------------
	;
	N Y
	F  Q:$L(V,"""")#2  S N=N+1,V=V_DEL_$P(X,DEL,N)
	;
	S Y=0
	F  S Y=$F(V,"""",Y) Q:'Y  S V=$E(V,1,Y-2)_$E(V,Y,$L(V))
	Q
	;
	;----------------------------------------------------------------------
VFMQ(X)	; Build <F>ile, <M>odify or <Q>uit strings
	;----------------------------------------------------------------------
	S %NOPRMT="N" Q			; *** 03/14/94 - BC - Continue
	;
	;----------------------------------------------------------------------
INSPTR(PTR)	; Poke a block pointer back into %IPMODE .../POINTER=position
	;----------------------------------------------------------------------
	;
	N X1,X2,X3,Y
	;
	S X1=$S(EXPR=1:1,1:$$FIND(%IPMODE,":",EXPR))
	S X2=$$FIND(%IPMODE,":",EXPR)
	I X2=0 S X2=$L(%IPMODE)+2
	S STR=$E(%IPMODE,X1-1,X2-2)
	;
	S Y=$$FIND(STR,"/P",1)
	I Y S X3=$P($E(STR,Y,$L(STR)),"=",2,999),STR=$E(STR,1,Y-3)_"/POINTER="_PTR_$E(X3,1+$L(+X3),$L(STR))
	E  S STR=STR_"/POINTER="_PTR
	S %IPMODE=$E(%IPMODE,1,X1-2)_STR_$E(%IPMODE,X2-1,$L(%IPMODE))
	Q
	;
	;----------------------------------------------------------------------
FIND(X,D,P)	; Return the position (P)th out of quotes occurrance of (D) in X
	;----------------------------------------------------------------------
	;
	N C,Y
	;
	S C=0,Y=0
	F  S Y=$F(X,D,Y) Q:'Y  I $L($E(X,1,Y-1),"""")#2 S C=C+1 I C=P Q
	I C=P Q Y
	Q 0
	;
	;----------------------------------------------------------------------
ERROR(X)	; Display errors in processing
	;----------------------------------------------------------------------
	;
	S ER=1,RM=X
	Q
	;
	;----------------------------------------------------------------------
RECALL(OX)	;    Copy data from previous (same) function
	;----------------------------------------------------------------------
	;
	; Recall option is not enabled
	W $$MSG^%TRMVT($$^MSG("2322"))
	Q
	;
	;----------------------------------------------------------------------
SYSLOG	; Run through ^SYSLOG and test for date
	;----------------------------------------------------------------------
	;
	N %INP,%LIBS,%SN,TJD,JOB,SEQ,VFMQ,X,USER,FUN
	S %LIBS="SYSDEV"
	;
	S %TAB("TJD")=".TJD6/TBL=[SYSLOG]"
	S %TAB("USER")=".UID1"
	S %TAB("FUN")=".FUN3/TBL=[SCATBL]"
	;
	S %READ="TJD/REQ,USER/NOREQ,FUN",%NOPRMT="F"
	D ^UTLREAD I VFMQ="Q" Q
	S (NOD,JOB,SEQ)=""
	K %TAB
	;
SYSNOD	S NOD=$O(^SYSLOG(TJD,NOD)) I NOD="" Q
SYSJOB	S JOB=$O(^SYSLOG(TJD,NOD,JOB)) I JOB="" G SYSNOD
	S %SN=""
	;
SYSSEQ	S SEQ=$O(^SYSLOG(TJD,NOD,JOB,SEQ)) I SEQ="" G SYSJOB
	S X=^SYSLOG(TJD,NOD,JOB,SEQ)
	;
	S %INP=$G(^SYSLOG(TJD,NOD,JOB,SEQ,1))
	I %INP="" G SYSSEQ
	;
	I FUN'="",$P(X,"|",3)'=FUN G SYSSEQ
	I USER'="",$P(X,"|",7)'=USER G SYSSEQ
	I '$$CONT G SYSSEQ
	;
	F I=2:1 S X=$G(^SYSLOG(TJD,NOD,JOB,SEQ,I)) Q:X=""  S %INP=%INP_"|"_X
	I $E(%INP,$L(%INP)-1,$L(%INP))="|F" S %INP=$E(%INP,1,$L(%INP)-1)_"X"
	D FUNCTION(TJD,NOD,JOB,SEQ)
	G SYSSEQ
	;
FUNCTION(TJD,NOD,JOB,SEQ)	;
	;
	N (TJD,NOD,JOB,SEQ,%SN,%INP)
	S %IPMODE="NOINT:ORD %INP/EX=0",%LIBS="SYSDEV"
	S %OPMODE="NOOUT"
	S X=^SYSLOG(TJD,NOD,JOB,SEQ)
	S %UID=$P(X,"|",1),TLO=$P(X,"|",2),%FN=$P(X,"|",3),%="|" Q:%FN=""
	D EXT^SCADRV0(%UID,%FN)
	Q
	;
CONT()	;
	N OP,RM
	; Run ~p1
	S RM=$$^MSG("2446",$P(X,"|",3))
	S OP=$$^DBSMBAR(16)
	I OP=1 Q 1
	I OP=""!(OP=4) S TJD=99999 Q 0
	I OP=3 Q 0
	;
	W !,%INP,!
	F I=2:1 Q:'$D(^SYSLOG(TJD,JOB,SEQ,I))  W ^(I),!
	W ! S SEQ=$ZP(^SYSLOG(TJD,JOB,SEQ))
	Q 0
	;
	; Not enabled
NOOP	S ER=1,RM=$$^MSG("2039") Q
NOINT	S (vkeyb,vdsp)=0 Q
NOVAL	S validate=0 Q
INIT	;
	S CMD("NOINTERACTIVE")="NOINT"
	S CMD("NOVALIDATE")="NOVAL"
	S CMD("DATABASE")="(1/REQ)"
	S CMD("NAMED")="(1/REQ,DELIMETER/TYP=N/MAX=255,EXTERNAL/NEG/TYP=L,FIXED/NEG/TYP=L/DEF=0,NULL/TYP=N/MAX=255"
	S CMD("ORDERED")="(1/REQ,DELIMETER/TYP=N/MAX=255,EXTERNAL/NEG/TYP=L,FIXED/NEG/TYP=L/DEF=0,NULL/TYP=N/MAX=255,POINTER/TYP=N"
	S CMD("ADDRESSED")="(1/REQ,DELIMETER/TYP=N/MAX=255,EXTERNAL/NEG/TYP=L,FIXED/NEG/TYPE=L/DEF=0,NULL/TYP=N/MAX=255,POINTER/TYP=N"
	Q
