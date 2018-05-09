DBSTSINP	;; -  - V4.3 - 
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/17/94 11:31:02 - XUS
	;     ORIG:  FSANCHEZ - 12 OCT 1990
	;     DESC:  
	; I18N=QUIT: Exculded from I18N standards. 
	;
	;---- Revision History ------------------------------------------------
	; 02/14/06 - RussellDS - CR19065
	;	     Change reference to delimiter to use DBTBL1, not the 
	;	     obsoleted delimiter from DBTBL1D.
	;
	; 08/04/94 - Fan Zeng - ARQ 10174
	;            Replaced "Q ;" with "Q  ;".
	;     
	; 07/26/94 - Steve Canfield - I18N
	;	     Converted msgid from DQnnnn to nnnn.
	;
	; 12/12/92 - Allan Mattson - I18N#7
	;
	;            Modified return message handling with a call to extrinsic
	;            function $$^MSG(msgid,p1,p2...) for I18N development
	;            (phrase independence).
	;
	N CMD,CPTR,IPMODE,LIB,VDB,VTAB,N
	;
	I '$D(NI) N NI S NI=1
	I '$D(vactive) N vactive S vactive='(%IPMODE["NOINT")
	;
	S IPMODE=":"_%IPMODE,LIB="SYSDEV",ER=0
	;
	S CPTR=0 F  S CMD=$$STRIP Q:CMD=""  D COMMAND
	Q
	;
	;----------------------------------------------------------------------
COMMAND	; Execute appropiate subroutine based upon input command
	;----------------------------------------------------------------------
	;
	I "NA"=CMD D NAMED Q
	I "NU"=CMD D NUMBERED Q
	I "DA"=CMD D DATABASE Q
	I "OR"=CMD D ORDERED Q
	Q	
	;
	;----------------------------------------------------------------------
NAMED	; Named list
	;----------------------------------------------------------------------
	;
	N AR,ARTYP,I,N,X
	;
	S AR=$$EXPR(.CPTR,"=") I AR="" Q
	;
	I '$D(VTAB) D VTAB ;			Build table cross reference
	;
NAMEA	;
	;
	D ARSYN I ER Q
	;
	I ARTYP="A" F  S N=$O(VTAB(N)) Q:N=""  D:$D(@AR) VDFT(VTAB(N),@AR)
	E  F I=1:2 S N=$P(X,"|",I) Q:N=""  D:$D(VTAB(N)) VDFT(VTAB(N),$P(X,"|",I+1))
	;
	S AR=$$SUBEXPR I AR'="" G NAMEA
	Q
	;
	;----------------------------------------------------------------------
NUMBERED	; Numbered list
	;----------------------------------------------------------------------
	;
	N AR,ARTYP,I,N,X
	;
	S AR=$$EXPR(.CPTR,"=") I AR="" Q
	;
NUMBA	;
	;
	D ARSYN I ER Q
	;
	I ARTYP="A" F  S N=$O(@AR) Q:N=""  D VDFT(N,@AR)
	E  F I=1:2 S N=$P(X,"|",I) Q:N=""  D VDFT(N,$P(X,"|",I+1))
	;
	S AR=$$SUBEXPR I AR'="" G NUMBA
	Q
	;
	;----------------------------------------------------------------------
ORDERED	; Ordered list
	;----------------------------------------------------------------------
	;
	S X=$$EXPR(.CPTR,"=") I X="" Q
	;
ORDERA	;
	;
	;
	S AR=$$SUBEXPR I AR'="" G ORDERA
	Q
	;
	;----------------------------------------------------------------------
DATABASE	; Database list
	;----------------------------------------------------------------------
	;
	N ARRAY,FID,KEYS,N,X,Y
	;
	S X=$$EXPR(.CPTR,"=") I X="" Q
	;
	I '$D(VTAB) D VTAB ;			Build table cross reference
	;
DATAA	;
	;
	S FID=$P(X,"(",1),KEYS=$P(X,"(",2),ARRAY=$$ARRAY(KEYS)
	I ARRAY="" Q
	;
	I '$D(@("^"_ARRAY_")")) D ERROR("Undefined database record "_ARRAY) Q
	;
	S N="" F  S N=$O(VTAB(N)) Q:N=""  D BLDNL
	;
	S X=$$SUBEXPR I X'="" G DATAA
	Q
	;
	;----------------------------------------------------------------------
BLDNL	; Add a value to the DATA(Named_List) array if not defined
	;----------------------------------------------------------------------
	;
	I $P(N,".",1)'=FID Q  ;	 		Not current table
	;
	N AR,DL,PC,X
	;
	S X=$G(^DBTBL(LIB,1,$P(N,".",1),9,$P(N,".",2))) I X="" Q
	S AR=$P(X,"|",1),PC=$P(X,"|",21)
	S DL=$P($G(^DBTBL(LIB,1,$P(N,",",1),10)),"|",1)
	;
	I AR=LASTKEY S AR=ARRAY_")" ;		Data on bottom key
	E  S AR=ARRAY_","_AR_")" ;		Data on node level
	;
	I '$D(VDB(AR)) S X=$G(@("^"_AR)),VDB(AR)=X ;	Load from global
	E  S X=VDB(AR)
	;
	I DL S X=$P(X,$C(DL),PC) ;Position within record
	;
	D VDFT(VTAB(N),X) Q
	;
	;----------------------------------------------------------------------
ARRAY(KEYS)	; Build global reference & insert keys 
	;----------------------------------------------------------------------
	;
	N Y,X
	;
	S X=$G(^DBTBL(LIB,1,FID,0)) I X="" Q "" ; 	Invalid reference
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
REF(NI)	; Build the TABLE.COLUMN reference for this %TAB(NI)
	;----------------------------------------------------------------------
	;
	N TBL,COL,X
	;
	S X=%TAB(NI) I X="" S X=$$TAB^DBSCRT8(NI)
	;
	I $E($P(X,"|",2))="*" Q $E($P(X,"|",2),2,999) ; Local variable
	;
	S TBL=$P($P(X,"|",3),"]",1),COL=$P($P(X,"|",3),"]",2) I COL="" Q
	I $E(TBL)="[" S TBL=$E(TBL,2,999) 
	I TBL["," S TBL=$P(TBL,",",2) ;	Library syntax included
	I TBL="" S TBL=DFID ;		Default table syntax
	I %MODOFF,NI>%MODOFF S COL=COL_"("_$P(X,"|",2)_")"
	Q TBL_"."_COL
	;
	;----------------------------------------------------------------------
STRIP()	; Strip the next command from %IPMODE
	;----------------------------------------------------------------------
	;
	N Y
	;
	S Y($F(IPMODE,":NA",CPTR))="NA"
	S Y($F(IPMODE,":NU",CPTR))="NU"
	S Y($F(IPMODE,":DA",CPTR))="DA"
	S Y($F(IPMODE,":OR",CPTR))="OR"
	;
	S CPTR=$O(Y(0)) I CPTR="" Q "" ;		No more operations
	Q Y(CPTR)
	;
	;----------------------------------------------------------------------
EXPR(CPTR,T)	; Return command expression 
	;----------------------------------------------------------------------
	;
	N Y,X
	;
	I T="=" S CPTR=$F(IPMODE,"=",CPTR)
	E  S CPTR=CPTR+1
	;
	S Y=$F(IPMODE,"(",CPTR)
	I Y,$E(IPMODE,CPTR,Y)'[",",$E(IPMODE,CPTR,Y)'[":" S Y=$F(IPMODE,")",Y) I Y,$E(IPMODE,CPTR,Y-1)'[":" S X=$E(IPMODE,CPTR,Y-2),CPTR=Y Q X
	;
	S Y=$F(IPMODE,",",CPTR)
	I Y,$E(IPMODE,CPTR,Y)'[":" S X=$E(IPMODE,CPTR,Y-2),CPTR=Y-1 Q X
	;
	S Y=$F(IPMODE,":",CPTR)
	I Y S X=$E(IPMODE,CPTR,Y-2),CPTR=Y-1 Q X
	;
	S X=$E(IPMODE,CPTR,$L(IPMODE)) I X'="" Q X
	D ERROR("Invalid expression"_$E(IPMODE,CPTR-4,$L(IPMODE)))
	Q ""
	;
	;----------------------------------------------------------------------
SUBEXPR()	; Return command subexpression
	;----------------------------------------------------------------------
	;
	I $E(IPMODE,CPTR)'="," Q "" ;		No sub expressions
	Q $$EXPR(.CPTR,",")
	;
	;----------------------------------------------------------------------
VTAB	; Create TAB cross reference VTAB(Table.Column)=NI
	;----------------------------------------------------------------------
	;
	N X,N
	;
	S N=NI-1 
	F  S N=$O(%TAB(N)) Q:N=""  S X=$$REF(N) I X'="" S VTAB(X)=N
	Q
	;
	;----------------------------------------------------------------------
VDFT(N,DEF)	; Add value to vdft(array) if different than original
	;----------------------------------------------------------------------
	;
	I N<NI Q
	I '$D(%TAB(N)) Q
	;
	N AR,DATA,I,E5,E67,E8,E9,E12,X,vhdr
	;
	D RESET^DBSCRT8(N)
	;
	I 1 S DEF=$$VARIABLE^DBSCRT8(DEF,E8,I(9)) ; Format default to external
	I X=DEF Q
	;
	I '$D(vdft(N)) S vdft(N)=DEF
	E  S vdft(N)=DEF_"|"_vdft(N)
	;
	I vactive W $$PNTFMT^DBSCRT(DEF,E67,E8,$A(vhdr),$A(vhdr,2))
	Q
	;
	;----------------------------------------------------------------------
ARSYN	; Array syntax validation
	;----------------------------------------------------------------------
	;
	I $P(AR,"(",1)="" D ERROR("Variable name syntax "_AR) Q
	I '$D(@($P(AR,"(",1))) D ERROR("Not defined "_AR) Q
	;
	I $E(AR,$L(AR))="#" S ARTYP="A",AR=$E(AR,1,$L(AR)-1)_"N)",N="" Q
	S:AR["(" AR=AR_")" S ARTYP="N",X=$G(@AR) Q
	;
	;----------------------------------------------------------------------
ERROR(RM)	; Display errors in processing
	;----------------------------------------------------------------------
	;
	S ER=1
	Q
	;
	;----------------------------------------------------------------------
RECALL(OX)	; 		Copy data from previous (same) function
	;----------------------------------------------------------------------
	;
	I $D(%fkey)#10 S %fkey=""
	;
	I '$D(%UID)!'$D(%FN)!'$D(%PG) Q OX
	;
	I '$D(NI) N NI S NI=1 ;			Default to first fieid
	I '$D(%ID) N %ID F %ID=+$ZP(^SYSLOG(+$H,"")):-1:0 Q:$P(^(%ID),"|",1)=%UID
	I +%ID=0 Q OX
	;
	N AR,ARTYP,CPTR,EXPR,I,IPMODE,N,X
	;
	F N=(%ID-1):-1:0 S X=$G(^SYSLOG(+$H,N)) I $P(X,"|",1)=%UID,$P(X,"|",3)=%FN Q
	I N=0 S RM=$$^MSG(2220,%FN) Q OX
	;
	S EXPR=$P($G(^SYSLOG(+$H,N,%PG)),"|",2,999) 
	I EXPR="" S RM=$$^MSG(1583) Q OX
	;
	S AR="EXPR",CPTR=0,IPMODE="" D NUMBA
	I $D(vdft(NI)) Q $P(vdft(NI),"|",1)
	Q OX
