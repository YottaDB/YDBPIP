DBSTEST6	;Private;DBSFETCH DEMO/QA UTILITY
	;;Copyright(c)1997 Sanchez Computer Associates, Inc.  All Rights Reserved - 08/12/97 15:00:23 - NIB
	; ORIG:	CHIANG - 11/08/93
	; DESC:	DBSFETCH DEMO/QA UTILITY
	;
	; I18N=QUIT: Exculded from I18N standards. 
	;------------ Revision History ---------------------------------------
	;
	; 08/12/97 - Betty Ndi - 25653
	;            Replace follows operator "]" with a "]]". 
	;
	; 08/23/94 - Shaodong Tony Xu - ARQ 14621
	;            Modified the variables %READ and %TAB.
	K
	I $G(%LIBS)="" S %LIBS=^CUVAR("%LIBS")
	;
	D INIT
	S $P(%READ,",",3)="TESTQR/TYP=L/REQ/DES=Test QWIK Report Logic"
	S $P(%READ,",",4)="TESTRW/TYP=L/REQ/DES=Test RW Report Logic"
	S $P(%READ,",",5)="TESTFL/TYP=L/REQ/DES=Test File Collating Logic"
	D ^UTLREAD I VFMQ="Q" Q
	;
	s $p(line,"-",81)=""
	;
	I TESTQR D TESTQR
	I TESTRW D TESTRW
	I TESTFL D TESTFL
	Q
	;
TESTQR	;
	D INIT
	S $p(%READ,",",4)="FILEA/REQ/LEN=12/TY=U/DES=From QWIK Report"
	S $P(%READ,",",5)="FILEB/REQ/LEN=12/TY=U/DES=To QWIK Report"
	D ^UTLREAD I VFMQ="Q" Q
	;
	D OPEN^SCAIO
	s vcrt=(IOTYP="TRM")
	;
	S QRID=$ZP(^DBTBL(%LIBS,6,FILEA))
	f  S QRID=$O(^DBTBL(%LIBS,6,QRID)) Q:QRID=""!(QRID]]FILEB)  D
	.	S Z=^(QRID,0),sel=^(12)
	.	S files=$P(Z,"|",1),file=$p(files,",",1)
	.	s order=$P(Z,"|",10)
	.	s global=$P($G(^DBTBL(%LIBS,1,file,100)),"(",1)
	.	i order="" s order=^DBTBL(%LIBS,1,file,16)
	.	S order=$$PACKEY(order)
	.	K Q
	.	S FILES=files
	.	F NI=1:1:9 S X=$G(^DBTBL(%LIBS,6,QRID,NI)) I X'="" D ^DBSQRY
	.	;
	.	D ACCESS
	Q
TESTRW	;
	D INIT
	S $p(%READ,",",4)="FILEA/REQ/LEN=12/TY=U/DES=From Report"
	S $P(%READ,",",5)="FILEB/REQ/LEN=12/TY=U/DES=To Report"
	D ^UTLREAD I VFMQ="Q" Q
	;
	D OPEN^SCAIO
	s vcrt=(IOTYP="TRM")
	;
	S RID=$ZP(^DBTBL(%LIBS,5,FILEA))
	f  S RID=$O(^DBTBL(%LIBS,5,RID)) Q:RID=""!(RID]]FILEB)  D
	.	S Z=^(RID,0)
	.	S files=$P(Z,"|",1),file=$p(files,",",1)
	.	s order=""
	.	F I=1:1:10 S X=$G(^(I)) q:X=""  D
	..		S X=$P(X,"|",1),X="["_$P(X,",",2)
	..		S order=order_X_","
	.	S order=$E(order,1,$l(order)-1)
	.	s global=$P($G(^DBTBL(%LIBS,1,file,100)),"(",1)
	.	i order="" s order=^DBTBL(%LIBS,1,file,16)
	.	S sel=order
	.	D ACCESS
	Q
	Q
TESTFL	;
	D INIT
	S $p(%READ,",",4)="FILEA/REQ/LEN=12/TY=U/DES=From File"
	S $P(%READ,",",5)="FILEB/REQ/LEN=12/TY=U/DES=To File"
	D ^UTLREAD I VFMQ="Q" Q
	;
	D OPEN^SCAIO
	s vcrt=(IOTYP="TRM")
	s file=$ZP(^DBTBL(%LIBS,1,FILEA))
	f  s file=$o(^DBTBL(%LIBS,1,file)) q:file=""!(file]]FILEB)  d
	.	K code,key
	.	s order=$G(^(file,16))
	.	s global=$P($G(^(100)),"(",1)
	.	s sel=order,files=file
	.	D ACCESS
	Q
ACCESS	;	
	U IO W !!,line,!
	I $D(QRID) W !,"QWIK Report: ",QRID,!
	;
	S order=$$PACKEY(order)		; Remove dummy data items
	s sel=$$PACKEY(sel)		; Remove dummy data items
	s sel=$$CHGDI(sel)		; Change [fid]di to fid.di
	s order=$$CHGDI(order)		; Change [fid]di to fid.di
	;
	W !,"  file=",files,?25,"global=",global
	W !," Order=",order
	i order'=sel w !,"Select=",sel
	I $D(query) w ! zwr q
	w !
	;
	i order="" q
	i 'vcrt u 0 w !,file,?20,$p($H,",",2) U IO	; Run time
	s vsql=$$OPEN^DBSFETCH(.code,files,sel,.Q,order)	; Open cursor
	I $D(code) W !! ZWR code			; Collating code
	I 'vsql q					; EOF
	;						; Fetch 5 records
	f i=1:1:5 s vsql=$$FETCH^DBSFETCH(.code,.key) q:'vsql  W !,key
	Q
PACKEY(X)	;
	; ---------- Remove dummy keys
	;
	N L,I,K
	S L=$L(X,","),Z=""
	F I=1:1:L S K=$P(X,",",I) I '((K?1N.N)!($E(K)="""")) S Z=Z_K_","
	Q $E(Z,1,$L(Z)-1)
	;
CHGDI(X)	; 
	; ---------- Convert [fid]di syntax to fid.di
	;
	S X=$TR(X,"[","")
	S X=$TR(X,"]",".")
	Q X
INIT	;
	X $P(^SCATBL(2,"PBS"),"|",2)
	U 0 S IO=$I,%FN="DBSTEST6"	
	S %TAB("IO")=$$IO^SCATAB
	S %READ=""
	S $P(%READ,",",1)="@@%FN"
	S $P(%READ,",",3)="IO/REQ"
	S %FRAME=3
	Q
