DBSSCR4	;DBSDS8A; -  - V5.0 - SCREEN COMPILER ( PART 2)
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/30/02 13:49:35 - ANTONOVV
	;     ORIG:  CHIANG - 1/15/86
	;     DESC:  Screen Compiler
	;
	; I18N=QUIT : Excluded from I18N standards.
	;---------- Revision History -------------------------------------------
	; 12/28/05 - Pete Chenard - 18258
	;	     $G() around ^CUVAR("DBS") reference.  This routine will
	;	     eventually be obsoleted, once all non-PSL screens have
	;	     been converted to PSL.
	;
	; 04/06/04 - RussellDS - CR9172
	;	     Replaced call DEFAULT^DBSTRG with DEFAULT section in this
	;	     routine.  DEFAULT section was removed from DBSTRG.
	;
	; 09/30/02 - ANTONOVV - 43583
	;            Removed second parameter from SCACOPYR() call.
	;
	; 07/03/01 - CHHABRIAS - 45214
	;	     Newed PSEQ variable in BLD4 to avoid compilation errors
	;	     during screen creation.
	;
	; 07/29/99 - Chiang - 34203
	;            Modified BLD4 section to add logic to include the correct
	;            run-time data loading logic.
	;
	;            Removed old revision history.
	;
	; 03/12/98 - SPIER - 26685 
	;            Modified BLD4 section, commented code which deals with 
	;            screen (pre and display) processers. The code is repeated 
	;            in BLD4A. The results was && compiled labels were duplicated. 
	;
	; 12/05/97  Chiang - 26857
	;           Modified VDFT section to include the data item default
	;           logic in the run-time routines.
	;
	; 11/18/97  Chiang - 26857
	;           Modified VDA section to break up long command line into
	;           multiple lines to avoid <REC2BIG> error.
	;
	; 11/03/97  Chiang - 26675
	;           Modified COMPILE section to include && macro logic in the
	;           run-time routine.  Replaces $ZP references with $O.
	;
	; 09/10/97  Chiang - 24933
	;           Modified VDEF section to add error checking in the screen
	;           run-time routine to skip default value setup logic if one
	;           or more access keys were not defined.
	;-----------------------------------------------------------------------
	;
	S SAVD=D,SAVC=C
	;
START	; Build Mumps program
	;
	;
BLD4	;
	;
	; User defined VLOD flag
	;
	S USERVLOD=$D(^DBTBL(%LIBS,2,SID,0,101))
	;
	S C(2)=C(2)_",PGM=$T(+0),DLIB="_Q_PLIB_Q_",DFID="_Q_PFID_Q
	;
	S DES=^DBTBL(%LIBS,2,SID),X=$P(^DBTBL(%LIBS,2,SID,0),"|",1)
	;
	; Record level protection
	;
	I '%FLGPROT S C3P(1)=" ;"
	E  D ^DBSPROT4(X,"*",.C3P)
	;
	; Data entry post processor / Required set definition ?
	;
	S Z=$O(^DBTBL(%LIBS,2,SID,0,20)) I Z>20,Z<61 S C(2)=C(2)_",VSCRPP=1"
	S APL=$P(X,"|",11),SYS=$P(X,"|",12),CNTL=$P(X,"|",10),PROJ=$P(X,"|",13)
	;
	S RPCFLG=1 I $P(^DBTBL(%LIBS,2,SID,0),"|",4)+$P(^(0),"|",7) S RPCFLG=0 ; *** BC 08/31/94
	I RPCFLG,$P($G(^CUVAR("DBS")),"|",6) S RPCFLG=0	; *** BC - Disable RPC logic
	;
	;						; [DBVAR]DBSNET flag
	I USERVLOD S RPCFLG=0
	;
	S X=60.999 K ZIPP,OM			; Added items from scr pre-proc
	F I=1:1 S X=$O(^DBTBL(%LIBS,2,SID,0,X)) Q:X=""!(X>80.99)  S ZIPP(I)=^(X)
	D
	.	N vsqltag,PSEQ			; Avoid duplicate SQL entries 07/29/99
	.	D ^DBSPARS
	S X=120.999 K ZIPP,OM			; Added items from disp pre-proc
	F I=1:1 S X=$O(^DBTBL(%LIBS,2,SID,0,X)) Q:X=""!(X>140.99)  S ZIPP(I)=^(X)
	D
	.	N vsqltag			; 07/29/99
	.	D ^DBSPARS
	;
	D ^DBSLOD("*",.SCRVLOD,"","",2,SID,RPCFLG)
	I $G(ER),$G(RM)'="" W !,RM
	;
	S Z=$O(BLD(""),-1)+1 ; Last entry
	;
	I 'USERVLOD G BLD4A
	;
	; Insert VCOM first
	;
	S X="" F  S X=$O(SCRVLOD(X)) Q:X=""  I SCRVLOD(X)?1"VCOM".E Q
	I X>0 S X=$O(SCRVLOD(X),-1) F I=1:1 S X=$O(SCRVLOD(X)) Q:X=""  S BLD(Z+I)=SCRVLOD(X) K SCRVLOD(X)
	;
	S Z=$O(BLD(""),-1)+1
	;
	S BLD(Z)=" Q",BLD(Z+1)="VLODDQ ; Original VLOD section",BLD(Z+2)=" ;",Z=Z+3
BLD4A	;
	S X="" F I=1:1 S X=$O(SCRVLOD(X)) Q:X=""  S BLD(Z+I)=SCRVLOD(X)
	;
	; User Defined VLOD section
	;
	;
	; Build Run-time program
	;
	K XLT,SCREEN
	D ^DBSRTN("SCREEN","^TMPZ($J)","",.XLT)		; *** BC - Replace
	;						; *** ^%ZRTNLOD call
	;
	; Remove VLOD entry
	;
	S X=XLT("VLOD") K ^TMPZ($J,X)
	;
	;
	S ^TMPZ($J,1)=PGM_" ;;"_APL_" - "_SYS_" - "_$G(^DBTBL)_" - SID= <"_SID_"> "_DES
	;
	; AV - 43583
	D ^SCACOPYR(.X1)
	S ^TMPZ($J,2)=X1 K X1
	;
	; program header section
	;
	S X1=2.001
	;
	; Documentation
	;
	S I=80.999 F I1=1:1 S I=$O(^DBTBL(%LIBS,2,SID,0,I)) Q:I=""!(I>100)  S ^TMPZ($J,X1)=" ; "_^DBTBL(%LIBS,2,SID,0,I),X1=X1+.001
	;
	;---------- Screen without SCREEN PRE-PROC and DISPLAY PRE-PROC
	;
	I '$D(^DBTBL(%LIBS,2,SID,0,61)),'$D(^DBTBL(%LIBS,2,SID,0,121)) D  G BLD3
	.	;
	.	S X1=XLT("V5")+2.001
	.	S ^TMPZ($J,X1)=" I '%O D VNEW,VPR,VDA",X1=X1+.001
	.	S ^(X1)=" I %O D VLOD Q:$G(ER)  D VPR,VDA"
	;
	;---------- Screen Pre-Processor
	;
	I $D(^DBTBL(%LIBS,2,SID,0,61)) D
	.	;
	.	S tag="VSCRPRE ; Screen Pre-Processor"
	.	D PPUTIL(61,tag)
	.	;
	.	S X1=XLT("V5")+2.001
	.	S ^TMPZ($J,X1)=" S ER=0 D VSCRPRE I ER Q  ; Screen Pre-Processor"
	.	S X1=X1+.001,^(X1)=" ;"
	.	;
	I '$D(^DBTBL(%LIBS,2,SID,0,121)) D
	.	S X1=X1+.001
	.	S ^TMPZ($J,X1)=" I '%O D VNEW,VPR,VDA",X1=X1+.001
	.	S ^(X1)=" I %O D VLOD Q:$G(ER)  D VPR,VDA"
	;
	; ---------- Display Pre-Processor
	;
	I $D(^DBTBL(%LIBS,2,SID,0,121)) D
	.	;
	.	S tag="VDSPPRE ; Display Pre-Processor"
	.	D PPUTIL(121,tag)
	.	;
	.	S X1=XLT("V5")+2.005
	.	S ^TMPZ($J,X1)=" ; Display Pre-Processor",X1=X1+.001
	.	S ^(X1)=" ;",X1=X1+.001
	.	S ^(X1)=" I '%O D VNEW,VDSPPRE Q:$G(ER)  D VPR,VDA",X1=X1+.001
	.	S ^(X1)=" I %O D VLOD Q:$G(ER)  D VDSPPRE Q:$G(ER)  D VPR,VDA"
	;
BLD3	;
	; *** 09/08/95 (Added file short names to the KVAR list)
	S VFSN="",file=""
	F  S file=$O(fsn(file)) Q:file=""  D
	.	;
	.	S sn=$P(fsn(file),"|",1)
	.	I $E(sn,$L(sn))'=")" S sn=$P(sn,"(",1)
	.	S VFSN=VFSN_",VFSN("""_file_""")="""_sn_""""
	.	S KVAR=KVAR_","_sn
	;
	I VFSN'="" S VFSN=" S "_$E(VFSN,2,$l(VFSN))
	;
	S X1=XLT("V0")+1.5
	; *** 09/08/95 (changes 22,10 to 2,10 $Extract error)
	S ^TMPZ($J,X1)=" S KVAR="""_KVAR_""",VSID="""_$S($E(SID)="z":$E(SID,2,10),1:SID)_""",VPGM=$T(+0),VSNAME="""_DES_""""
	S X1=X1+.001
	I VFSN'="" S ^TMPZ($J,X1)=VFSN
	S X1=X1+.001
	;
	; Record level protection
	;
	F I=1:1 Q:'$D(C3P(I))  S ^TMPZ($J,X1)=C3P(I),X1=X1+.001
	;
V5	; I %O=5 S %MODS=1,%REPEAT=? D VPR,VDA,^DBSPNT() Q
	;
	I '%LOOP G VPR
	;
	S X1=XLT("V5")
	S I=23-%LOOP I $G(%MODGRP)>1000 S I=I+1\(%MODGRP\1000)
	S ^TMPZ($J,X1)=" I %O=5 S %MODS=1,%REPEAT="_I_" D VPR,VDA,V5^DBSPNT Q"
	;
VPR	; print prompts
	;
	S X1=XLT("VPR")+1.001
	F I=1:1 S X=$G(TMPC(I)) Q:X=""  S ^TMPZ($J,X1)=X,X1=X1+.001
	;
VDA	; display data
	;
	I $D(lvns) D
	.	N n,new,new5,set
	.	S n="",new="",new5="",set=""
	.	;
	.	F  S n=$O(lvns(n)) Q:n=""  D
	..		S lvn=lvns(n)
	..		I lvn="%O" Q		; System variable (RC 2/10/93)
	..	 	I '((lvn?1A.AN)!(lvn?1"%".AN)) Q	; Not valid
	..		S new5=new5_","_lvn			; variable syntax
	..		;					: *** 12/19/94 BC
	..		I $E(lvn)="v" S new=new_","_lvn,set=set_","_lvn_"=$G("_n_")" Q
	..		S set=set_","_lvn_"=$G("_n_")" Q
	.	;
	.	S new5=$E(new5,2,$L(new5)) I new5="" Q
	.	S TMPD(.1)=" I %O=5 N "_new5
	.	S TMPD(.2)=" I  S ("_new5_")="""""
	.	I new'="" S TMPD(.3)=" E  N "_$E(new,2,$L(new))
	.	I set'="" D					; *** 11/14/94 BC
	..		S set=$e(set,2,$L(set))
	..		I $L(set)<500 S TMPD(.4)=" E  S "_set Q
	..		S z=$L(set,",")\2			; Split the list
	..		S TMPD(.4)=" E  S "_$P(set,",",1,z)	; in half
	..		S TMPD(.41)=" E  S "_$P(set,",",z+1,9999)
	.	S TMPD(.5)=" ;"					; ***
	;
	I $D(rptlvns) D
	.	;
	.	N n,new,new5,set,set1,set2
	.	S n="",new="",new5="",set="",set1="",set2=""
	.	S RPTDA=RPTDA-1
	.	;
	.	F  S n=$O(rptlvns(n)) Q:n=""  D
	..		S lvn=rptlvns(n)
	..		I lvn="%O" Q		; System variable (RC 2/10/93)
	..		I '((lvn?1A.AN)!(lvn?1"%".AN)) Q	; Not valid
	..		S new5=new5_","_lvn
	..		I $E(lvn)="v" S new=new_","_lvn
	..		; *** BC - 05/18/94 - init variables to correct <UNDEF> error
	..		I $L(set1)>440 S set2=set2_",("_lvn_","_n_")=$G("_n_")" Q	; Overflow line
	..		I $L(set)>440 S set1=set1_",("_lvn_","_n_")=$G("_n_")" Q	; Overflow line
	..		S set=set_",("_lvn_","_n_")=$G("_n_")" Q	
	.	;
	.	S new5=$E(new5,2,$L(new5)) I new5="" Q
	.	S TMPD(RPTDA+.1)=" I %O=5 N "_new5
	.	S TMPD(RPTDA+.2)=" I  S ("_new5_")="""""
	.	I new'="" S TMPD(RPTDA+.3)=" E  N "_$E(new,2,$L(new))
	.	I set'="" S TMPD(RPTDA+.4)=" E  S "_$E(set,2,$L(set))
	.	I set1'="" S TMPD(RPTDA+.41)=" E  S "_$E(set1,2,$L(set1))		; Overflow line
	.	I set2'="" S TMPD(RPTDA+.42)=" E  S "_$E(set2,2,$L(set2))		; Overflow line
	.	S TMPD(RPTDA+.5)=" ;"
	;
	S X1=$O(TMPD(1),-1)+.0001,N=""		; Init user-defined variables
	F  S N=$O(VARLIST(N)) Q:N=""  S TMPD(X1)=" S "_N_"=$G("_N_")",X1=X1+.001
	S TMPD(X1)=" ;"
	S X1=XLT("VDA"),N=""
	S X1=X1+.001,^TMPZ($J,X1)=" N V"		; *** 08/03/94 BC
	;
	F  S N=$O(TMPD(N)) Q:N=""  S X1=X1+.001,^TMPZ($J,X1)=TMPD(N)
	;
	; RECORD LEVEL PROTECTION FOR LINKED SCREENS
	;
	;VREPRNT ;
	; D VPROT Q:ER
	; D VPR,VDA
	;
	I $O(C3P(1))>0 S X1=XLT("VREPRNT")+.001
	I  S ^TMPZ($J,X1)=" D VPROT Q:ER"
	;
VTAB	;
	I '$D(TAB) F I="VPOS","VPRE" D DELETE(I)
	;
	; Build %TAB
	;
	S X1=XLT("VTAB")+0.001,^TMPZ($J,X1)=" ;",X1=X1+.001
	;
	; K REQ,%TAB ...
	;
	S ^TMPZ($J,X1)=C(1),X1=X1+.001
	;
	; S %MAX=...
	;
	S ^TMPZ($J,X1)=C(2),X1=X1+.001
	;
	; S OLNTB=...
	;
	S ^TMPZ($J,X1)=C(3),X1=X1+.001,^TMPZ($J,X1)=" ;",X1=X1+.001
	;
	I VFSN'="" D
	.	; 
	.	S ^TMPZ($J,X1)=VFSN,X1=X1+.001
	.	S ^TMPZ($J,X1)=" ;",X1=X1+.001
	;
	; S vfiles(file)=short name|global reference
	;
	S X="" F  S X=$O(FX(X)) Q:X=""  S ^TMPZ($J,X1)=FX(X),X1=X1+.001
	K FX
	I '$D(TAB) G VSPRE
	;
	;
	; X41   F I=N:1:%MAX S %TAB(I)=""
	;
	S ^TMPZ($J,X1)=X41,X1=X1+.001
	;
	; S %TAB()...
	;
	S X1=XLT("VTBL")+5.001,N=""
	F  S N=$O(TAB(N)) Q:N=""  S ^TMPZ($J,X1)=TAB(N),X1=X1+.001
	;
	I '$D(VPTBL) G VSPRE
	;
	; ========== data item protection logic
	;
	S ^(X1)=" ;",X1=X1+.001
	S ^(X1)=" ; Data item protection",^(X1+.001)=" ;"
	S ^(X1)=" S z=0 F  S z=$O(VPTBL(z)) Q:z="_$C(34,34)_"  S %TAB(z)=$E(%TAB(z),1,3)_(VPTBL(z)+2)_$E(%TAB(z),5,999)"
	S X1=X1+.001
	;
VSPRE	; Data entry pre-processor
	;
	I $D(^DBTBL(%LIBS,2,SID,0,1)) S X=XLT("VTAB1"),^TMPZ($J,X)=" D VTBL,VDEPRE I $G(ER) Q"
	;
	;
	; Required set definitions
	;
	I '$D(^DBTBL(%LIBS,2,SID,0,41)) G VSPP
	S VZSEQ=40,X=""
NVREQ	;
	S VZSEQ=$O(^DBTBL(%LIBS,2,SID,0,VZSEQ)) I VZSEQ=""!(VZSEQ>60) G VSPP
	;
	S X=^(VZSEQ) I X?." " G NVREQ
	I X'[";" D ^DBSSCR5 Q:ER  G NVREQ
	;
	; (DI,DI...)  OR (...) OR ;
	;
	S X=$P(X,";",1)
	F  S VZSEQ=$O(^(VZSEQ)) Q:VZSEQ=""  S X=X_^(VZSEQ) Q:X'[";"  S X=$P(X,";",1)
	;
	; Process set definitions
	;
	D ^DBSSCR5 Q:ER  G NVREQ
	;
VSPP	; Data entry post processor
	;
	S X1=XLT("VSPP")
	;
	I '$D(^DBTBL(%LIBS,2,SID,0,21)) D DELETE("VSPP") G BLD41
	;
	S X1=XLT("VSPP")+.001,^TMPZ($J,X1)=" ;",X1=X1+.001
	;
	; required set definitions ?
	;
	I $D(^DBTBL(%LIBS,2,SID,0,41))
	;
	I  S ^TMPZ($J,X1)=" D VSPPREQ I ER Q",X1=X1+.001,^TMPZ($J,X1)=" ;",X1=X1+.001
	;
	S X="" F  S X=$O(^TMP($J,999,X)) Q:X=""  S ^TMPZ($J,X1)=^TMP($J,999,X),X1=X1+.001
	S ^TMPZ($J,X1)=" Q",X1=X1+.001
	;
BLD41	;
	S X="" F  S X=$O(^TMP($J,1000,X)) Q:X=""  S ^TMPZ($J,X1)=^TMP($J,1000,X),X1=X1+.001
	;
	S X="" F  S X=$O(^TMP($J,998,X)) Q:X=""  S ^TMPZ($J,X1)=^TMP($J,998,X),X1=X1+.001
	;
VNEW	; VNEW section
	;
	S X1=XLT("VNEW")+.001,^TMPZ($J,X1)=" ;",X1=X1+.001
	;
	; user defined VLOD ?
	;
	I 'USERVLOD G BLD41A
	;
	; split VNEW into two sections
	;
	S VNEW(1)=" D VLOD"
	S X=0 F I=1:1 S X=$O(VNEW(X)) Q:X=""!(+X>99)  S ^TMPZ($J,X1)=VNEW(X),X1=X1+.001 K VNEW(X)
	;
	G VDEF
	;
BLD41A	;
	;
	S X="" F  S X=$O(VNEW(X)) Q:X=""  S ^TMPZ($J,X1)=VNEW(X),X1=X1+.001
	;
	K VNEW
	;
VDEF	; Default values
	;
	S X1=XLT("VDEF")+.001				; *** 10/14/94 BC
	I FILES'="" F i=1:1:$L(FILES,",") D		; ***
	I FILES'="" D
	.	S zfid=$P(FILES,",",1)			; *** 05/16/96
	.	;
	.	I $G(^DBTBL(%LIBS,1,zfid,101))="" Q	; No default def
	.	I '$D(fsn(zfid)) D fsn^DBSDD(.fsn,zfid)
	.	;
	.	N keys,i,z,z1,zdft
	.	;
	.	S ^TMPZ($J,X1)=" ;",X1=X1+.001
	.	;
	.	S keys=$P(fsn(zfid),"|",3) I keys="" Q  ; Access keys 09/10/97
	.	S z1="" F i=1:1:$L(keys,",") D
	..		S z1=z1_"!($G("_$P(keys,",",i)_")="""")"
	.	S z1=" I "_$E(z1,2,999)_" Q"
	.	S ^TMPZ($J,X1)=z1,X1=X1+.001		; Check missing key value
	.	; Default logic				; *** 12/05/97
	.	D DEFAULT(zfid,.zdft,2)
	.	S i=1
	.	F  S i=$O(zdft(i)) Q:i=""  S ^TMPZ($J,X1)=zdft(i),X1=X1+.001
	;
	S ^TMPZ($J,X1)=" Q",X1=X1+.001			; *** 
	;
VDEFA	I 'USERVLOD G VLOD
	;
	S ^TMPZ($J,X1)=" Q",^(X1+.001)="VNEWDQ ; Original VNEW section"
	S ^(X1+.002)=" ;",X1=X1+.003
	S X="" F  S X=$O(VNEW(X)) Q:X=""  S ^TMPZ($J,X1)=VNEW(X),X1=X1+.001
	S ^TMPZ($J,X1)=" Q",X1=X1+.001
	K VNEW
	;
VLOD	;
	;
	; BLD ??
	;
	S X="" F  S X=$O(BLD(X)) Q:X=""  S ^TMPZ($J,X1)=BLD(X),X1=X1+.001
	K BLD
	;
	;
	K C,C1,C2,C3,Z,NL,NS,OS,P,PMT,PO,PRO,REQ,TT,Y,XY,SEQ,LF,BLD,DFV,FX
	K LL,LINE,AR,CN,DE,DEC,DF,DI,DILNM,DINAM,FMT,ER,I,LEN,VNEW,^TMPX($J)
	;
	;
	; Data item pre/post processor
	;
	I '$D(^TMP($J,"PO")) D DELETE("VPOS") G VSAV
	S X1=XLT("VPOS")+.001
	S ^TMPZ($J,X1)=" ;",X1=X1+.001
	S X="" F  S X=$O(^TMP($J,"PO",X)) Q:X=""  S ^TMPZ($J,X1)=^TMP($J,"PO",X),X1=X1+.0001
	;
VSAV	;
	K %FDBL,%XDB,%XDBL,AKEY,CT,DB,DFT,FMT,K,KEYNM,KVAR,LEN,LN,PP,REF,TBL,LOOP,MAX,MIN,SFC,%DBL,CTL
	;
COMPILE	; Compile into source module
	;
	F I="VNEWDQ","VLODDQ" D DELETE(I)
	F I="F","D","C" I '$D(TB(I)) D DELETE("V"_I)
	;
	I $D(vsqltag) D macro				; *** 10/31/97
	;
	D ^DBSCMP(PGM,"^TMPZ($J",$G(NOLINK))
	K ^TMPZ($J)
	Q
macro	;
	; Parse &&sql macro commands and insert logic at the end of the routine
	;
	N code,i,seq
	D COMPILE^SQLCMP(.vsqltag,.code)
	S seq=$O(^TMPZ($J,""),-1)+1			; Last entry
	S i="" F  S i=$O(code(i)) Q:i=""  S ^TMPZ($J,seq)=code(i),seq=seq+1
	Q
	;
DELETE(SUB)	; Delete a Subroutine and any following lines
	;
	I '$D(XLT(SUB)) Q
	;
	S N=XLT(SUB) K XLT(SUB),^TMPZ($J,N)
	;
	F  S N=$O(^TMPZ($J,N)) Q:N=""  S X=^(N) Q:$P(X," ",1)'=""  K ^(N)
	Q
	;
DOUBLE(X)	; Change every " to ""
	S XL=0
	F  S XL=$F(X,Q,XL) Q:XL<1  S X=$E(X,1,XL-2)_Q_Q_$E(X,XL,999),XL=XL+1
	Q X
PPUTIL(node,tag)	; 
	;
	N ZIPP,OM,X,X1,X2,I
	;
	S X=node-.001,X2=X+20
	F I=1:1 S X=$O(^DBTBL(%LIBS,2,SID,0,X)) Q:X=""!(X>X2)  S ZIPP(I)=^(X)
	D ^DBSPARS
	; ;
	S X1=$O(^TMPZ($J,""),-1)+100,^TMPZ($J,X1)=" ;",X1=X1+.001
	S ^TMPZ($J,X1)=tag,X1=X1+.001
	S ^(X1)=" N %TAB,vtab ; Disable .MACRO. references to %TAB()",X1=X1+.001
	S ^(X1)=" ;",X1=X1+.001
	;
	S X="" F I=1:1 S X=$O(OM(X)) Q:X=""  S ^TMPZ($J,X1)=OM(X),X1=X1+.001
	S ^TMPZ($J,X1)=" Q"
	Q
	;
	;---------------------------------------------------------------------- 
DEFAULT(fid,code,mode)	; Return procedural code to create defaults in create mode
	;----------------------------------------------------------------------
	;
	N (%DB,fid,code,mode,%LIBS)
	S mode=$g(mode)
	I $G(fid)="" Q				; Invalid file name
	I $G(%LIBS)="" N %LIBS S %LIBS=^CUVAR("%LIBS")
	I $G(mode)=2 D fsn^SQLDD(.fsn,fid) I $G(ER) Q
	I $G(mode)'=2 D fsn^UCUTIL(.fsn,fid) I $G(ER) Q	; Invalid name
	;
	K code
	S obj=$$OBJNAME^UCUTIL(fid)		; Object name
	S req=$G(^DBTBL(%LIBS,1,fid,101))	; Items with default value
	S node=$P(fsn(fid),"|",12)		; Record exist indicator
	S gbl=$P(fsn(fid),"|",2) 		; Global reference
	I mode'=2 S gbl=$$OBJGBL^UCUTIL(gbl,obj)
	;
	I node="" S gbl=gbl_")"			; ^gbl(key1,key2,,,)
	E  S gbl=gbl_","_node_")"		; ^gbl(key1,node)
	;
	S sn=$P($P(fsn(fid),"|",1),"(",1)	; Internal storage name
	S rectyp=$P(fsn(fid),"|",4)		; Record type
	S keys=$P(fsn(fid),"|",3) 		; Access keys
	S bkey=$P(keys,",",$L(keys,","))	; Last key
	I keys="" S code(1)=" I $D("_$p(gbl,"(",1)_") S ER=1,RM=$$^MSG(2327) Q"
	I keys'="" D                            ; Record defined? 
	.       S N=""
	.       F I=1:1:$L(keys,",") S N=N_"!($G(vobj("_obj_",-"_(I+2)_"))="_""""""_")"
	.	S code(1)=" Q:$G(%O)  S ER=0 I "_$E(N,2,999)
	.	S code(1)=code(1)_" S ER=1,RM=$$^MSG(1767,"_""""_keys_""""_") Q"
	.	I '$$rdb^UCDB(fid) D
	..		S code(2)=" I $D("_gbl_")"
	..		I rectyp=1 S code(2)=" I $G("_gbl_")'="_""""""
	..		I $G(mode)'=2 S code(2)=code(2)_" S ER=1,RM=$$^MSG(2327)"
	..		S code(2)=code(2)_" Q  ; Already created"
	I req="" Q
	S q=""""
	F i=1:1:$L(req,",") D
	.	I $P(req,",",i)="" Q
	.	S dinam=fid_"."_$P(req,",",i)
	.	K item
	.	I mode=2 D PARSE^DBSDD(dinam,.item)	; Get internal format
	.	I mode'=2 S NS=$$PARSE^UCUTIL(dinam,1)	;
	.	I ER W !,$$MSG^%TRMVT($G(RM)),! H 2 Q	; Item deleted?
	.	I rectyp>1 D
	..		S nod=$$NOD^DBSDD(dinam,.item) ; Node number
	..		I nod=bkey Q			; Skip
	..		S node(nod)=""			; Save node number
	.	S v=$$DFT^DBSDD(dinam,.item)		; Default value
	.	I v="" Q
	.	S typ=$$TYP^DBSDD(dinam,.item)		; Type
	.	S len=$$LEN^DBSDD(dinam,.item)		; Length
	.	S v=$$value(v,typ)			; Internal format
	.	S code(10+i)=" I "_NS_"="_q_q_" S "_NS_"="_v_"   ; "_dinam
	;
	I mode=2 D SCR Q					; short name format
	I rectyp#2=1 S code(3)=" S "_sn_"("_obj_")=$G("_sn_"("_obj_"))" 	; Init array 01/07/00
	;
	I rectyp=1!'$D(node) Q
	;
	S n=""
	F j=1:1 S n=$O(node(n)) Q:n=""  D
	.	S i=n I i'=+i S i=""""_i_""""		; "name"
	.	I $G(mode)=2 S node=sn_"("_i_")=$G("_sn_"("_i_"))"
	.	E  S node=sn_"("_obj_","_i_")=$G("_sn_"("_obj_","_i_"))"
	.	S code(j/100+4)=" S "_node
	Q
	;
SCR	;
	I rectyp#2=1 S code(3)=" S "_sn_"=$G("_sn_")"   ; Init array 
	I rectyp=1!'$D(node) Q 
	; 
	S node="",n="" 
	F  S n=$O(node(n)) Q:n=""  D 
	.       S i=n I i'=+i S i=""""_i_""""           ; "name" 
	.       S node=node_","_sn_"("_i_")=$G("_sn_"("_i_"))" 
	I node'="" S code(4)=" S "_$E(node,2,999) 
	Q 
	;
	;----------------------------------------------------------------------
value(v,typ,var)	; Convert internal to external format
	;----------------------------------------------------------------------
	;
	N q
	S q=""""
	S v=$$value^DBSFILER(v,typ)
	I $G(var),v?1A.AN!(v?1"%".AN) S v=q_"<<"_v_">>"_q	; <<variavle>>
	Q v
