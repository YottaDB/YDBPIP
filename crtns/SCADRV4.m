SCADRV4	;;Function maintenance
	;
	; **** Routine compiled from DATA-QWIK Procedure SCADRV4 ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	;
NEW	;
	;
	D INIT(0)
	Q 
	;
UPD	;
	;
	D INIT(1)
	Q 
	;
INQ	;
	;
	D INIT(2)
	Q 
	;
DEL	;
	;
	D INIT(3)
	Q 
	;
INIT(%O)	;
	;
	N OLNTB,VFMQ
	S %PG=0
	S %PAGE=1
	I %O<2,$get(%IPMODE)'["NOINT" S %PAGE=2
	K FN
	N fSCATBL
	D VPG(.fSCATBL)
	K vobj(+$G(fSCATBL)) Q 
	;
VPG(fSCATBL)	; Page control
	;
	N FINISH
	S FINISH=0
	F  D  Q:FINISH 
	.	I %PG=0 D VPG00 I ER S FINISH=1 Q 
	.	I %PG=1 D VPG01(.fSCATBL) I "DFQ"[VFMQ D VER(.fSCATBL) S FINISH=1 Q 
	.	I %PG=2,$get(%IPMODE)'["NOINT" D VPG02(.fSCATBL) I ER S FINISH=1 Q 
	.	I "DFQ"[VFMQ D VER(.fSCATBL) S FINISH=1 Q 
	.	S %PG=%PG+1
	.	Q 
	Q 
	;
VPG00	; Set up
	;
	S %TAB("FN")=".FN2/TBL=[SCATBL]/XPP=D PPFUN^SCADRV4"
	I %O=2 S %TAB("IO")=$$IO^SCATAB($I)
	;
	S %READ="@@%FN,,,FN/REQ" S %NOPRMT="N"
	I %O=2 S %READ=%READ_",IO/REQ"
	;
	D ^UTLREAD
	;
	I VFMQ="Q" S ER=1
	Q 
	;
PPFUN	;UID post processor
	;
	I '%OSAVE S I(3)=""
	;
	I '%OSAVE,X'="",($D(^SCATBL(1,X))#2) S ET="RECOF" D ERR Q 
	I %OSAVE=3 D DELCHK
	I ER Q 
	;
	; SCA can modify anything
	I %UCLS="SCA" Q 
	;
	; Z's can be modified
	I $E(X,1)="Z" Q 
	;
	; Inquiry OK
	I %OSAVE=2 Q 
	;
	; Userclass ~p1 must use function name starting with ""Z""
	S ER=1
	S RM=$$^MSG(2897,%UCLS)
	Q 
	;
DELCHK	; Ensure cannot delete if linked in a menu or sub-menu
	;
	S (N,M)=""
	S ER=0
	;
	N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen1()
	F  Q:'($$vFetch1())  D
	.	N scamenu,vop1,vop2 S vop2=$P(rs,$C(9),1),vop1=$P(rs,$C(9),2),scamenu=$G(^SCATBL(0,vop2,vop1))
	.	S N=vop2
	.	I N="" Q 
	.	S M=vop1
	.	I M="" Q 
	.	I $P(scamenu,$C(124),2)=X S ER=1 S RM=$$^MSG(1134,N) Q 
	.	Q 
	I ER Q 
	;
	N rs,vos5,vos6,vos7,vos8 S rs=$$vOpen2()
	F  Q:'($$vFetch2())  D
	.	N scatbl4,vop3,vop4 S vop4=$P(rs,$C(9),1),vop3=$P(rs,$C(9),2),scatbl4=$G(^SCATBL(4,vop4,vop3))
	.	S N=vop4
	.	I N="" Q 
	.	S M=vop3
	.	I M="" Q 
	.	;
	.	; Function is linked on a sub-menu for function ~p1
	.	I $TR($P(scatbl4,$C(124),2),"@")=X S ER=1 S RM=$$^MSG(1133,N) Q 
	.	Q 
	Q 
	;
VPG01(fSCATBL)	; Function screen
	;
	K vobj(+$G(fSCATBL)) S fSCATBL=$$vDb3(FN)
	I %O=2,IO'=$I D OPEN^SCAIO I ER S VFMQ="Q" Q 
	;
	N vo1 N vo2 N vo3 N vo4 D DRV^USID(%O,"SCATBL",.fSCATBL,.vo1,.vo2,.vo3,.vo4) K vobj(+$G(vo1)) K vobj(+$G(vo2)) K vobj(+$G(vo3)) K vobj(+$G(vo4))
	;
	Q 
	;
VPG02(fSCATBL)	; Documentation screen
	;
	S %OSAV=%O
	S %SN="FUNDOC"
	S PG=FN
	K DOC
	S N=""
	;
	N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen3()
	F  Q:'($$vFetch3())  D
	.	N scatbld S scatbld=$$vDb4($P(rs,$C(9),1),$P(rs,$C(9),2))
	.	S DOC(vobj(scatbld,-4))=$P(vobj(scatbld),$C(124),1)
	.	K vobj(+$G(scatbld)) Q 
	;
	; Turn I18N checking off, phrases OK (I18N=OFF)
	I '$D(DOC) D
	.	S DOC(1)="Function Name:  "_FN
	.	;
	.	; Function Description
	.	S DOC(2)="  Description:  "_$P(vobj(fSCATBL),$C(124),1)
	.	;
	.	; Program Name
	.	S DOC(3)="      Routine:  "_$P(vobj(fSCATBL),$C(124),4)
	.	S DOC(4)=" "
	.	Q 
	;
	; Turn I18N checking back on (I18N=ON)
	S (END,DX,FPF,OVFL,LM,OPT,REGION)=0
	S ARM=71
	S SRM=80
	S PIO=$I
	S %TB=$char(9)
	S JOB=$J
	S (DTAB,MR)=5
	;
	; Function Documentation
	D ^DBSWRITE("DOC",3,22,99999,"",$$^MSG(3248))
	;
	S %O=%OSAV
	Q 
	;
VER(fSCATBL)	;
	;
	I %O=2!(%O=4)!(VFMQ="Q") D END Q 
	;
	D FILE(.fSCATBL)
	;
	D END
	;
	Q 
	;
FILE(fSCATBL)	;
	;
	N option,seq,TEMP,user
	;
	S option=%O
	S (user,seq)=""
	;
	I VFMQ="F",$D(DOC) D
	.	;
	.	D vDbDe1()
	.	;
	.	S X1=""
	.	F I=1:1 D  Q:X1="" 
	..		S X1=$order(DOC(X1))
	..		I X1="" Q 
	..		N scatbld S scatbld=$$vDb4(FN,X1)
	..	 S $P(vobj(scatbld),$C(124),1)=DOC(X1)
	..	 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(scatbld) S vobj(scatbld,-2)=1 Tcommit:vTp  
	..		K vobj(+$G(scatbld)) Q 
	.	Q 
	;
	S %O=option
	K X
	;
	I %O'=3 D
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^SCATBLFL(fSCATBL,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(fSCATBL,-100) S vobj(fSCATBL,-2)=1 Tcommit:vTp  
	.	N scatbl3 S scatbl3=$$vDb5(FN,"SCA")
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav2(scatbl3) S vobj(scatbl3,-2)=1 Tcommit:vTp  
	.	K vobj(+$G(scatbl3)) N scatbl3 S scatbl3=$$vDb5(FN,%UCLS)
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav2(scatbl3) S vobj(scatbl3,-2)=1 Tcommit:vTp  
	.	K vobj(+$G(scatbl3)) Q 
	E  I VFMQ="D" D
	.	D vDbDe2()
	.	D vDbDe3()
	.	Q 
	;
END	;
	;
	I ER!(%O=2)!(%O=4) Q 
	;
	I VFMQ="Q" D
	.	;
	.	; Function ~p1 not created
	.	I %O=0 S RM=$$^MSG(1148,FN) Q 
	.	;
	.	; Function ~p1 not modified
	.	I %O=1 S RM=$$^MSG(1150,FN) Q 
	.	;
	.	; Function ~p1 not deleted
	.	S RM=$$^MSG(1149,FN)
	.	Q 
	E  D
	.	;
	.	; Function ~p1 created
	.	I %O=0 S RM=$$^MSG(1144,FN) Q 
	.	;
	.	; Function ~p1 modified
	.	I %O=1 S RM=$$^MSG(1147,FN) Q 
	.	;
	.	; Function ~p1 deleted
	.	S RM=$$^MSG(1145,FN)
	.	Q 
	S ER="W"
	Q 
	;
PROG	; Check validity of program name
	;
	N Z
	I X="" Q 
	S Z=X
	;
	; Program name must contain the ^ symbol
	I Z'["^" D  Q 
	.	S ER=1
	.	S RM=$$^MSG(2273)
	.	Q 
	;
	; Strip off parameter passing
	S Z=$piece(Z,"(",1)
	;
	; Program ~p1 does not exist
	I '$$VALID^%ZRTNS($piece(Z,"^",2)) D
	.	S ER=1
	.	S RM=$$^MSG(2275,Z)
	.	Q 
	Q 
	;
ERR	;
	;
	S ER=1
	;
	D ^UTLERR
	S VFMQ="Q"
	Q 
	;
vSIG()	;
	Q "59553^73403^Dan Russell^5259" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM SCATBLDOC WHERE FN=:FN
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRec S vRec=$$vDbNew1("","")
	S vobj(vRec,-2)=3
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen4()
	F  Q:'($$vFetch4())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
	. S vobj(vRec,-3)=v1 S vobj(vRec,-4)=v2
	.	;     #ACCEPT CR=21101;DATE=2006-05-11;PGM=FSCW;GROUP=DEPRECATED
	.	D ^DBSLOGIT($G(vRec),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^SCATBL(3,v1,v2)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	K vobj(+$G(vRec)) Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe2()	; DELETE FROM SCATBL WHERE FN=:FN
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Tstart (vobj):transactionid="CS"
	N vRec S vRec=$$vDb3(FN)
	I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D ^SCATBLFL(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1)
	Tcommit:$Tlevel 
	K vobj(+$G(vRec)) Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe3()	; DELETE FROM SCATBLDOC WHERE FN=:FN
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRec S vRec=$$vDbNew1("","")
	S vobj(vRec,-2)=3
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen5()
	F  Q:'($$vFetch5())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
	. S vobj(vRec,-3)=v1 S vobj(vRec,-4)=v2
	.	;     #ACCEPT CR=21101;DATE=2006-05-11;PGM=FSCW;GROUP=DEPRECATED
	.	D ^DBSLOGIT($G(vRec),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^SCATBL(3,v1,v2)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	K vobj(+$G(vRec)) Q 
	;
vDb3(v1)	;	vobj()=Db.getRecord(SCATBL,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSCATBL"
	S vobj(vOid)=$G(^SCATBL(1,v1))
	I vobj(vOid)="",'$D(^SCATBL(1,v1))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	Q vOid
	;
vDb4(v1,v2)	;	vobj()=Db.getRecord(SCATBLDOC,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSCATBLDOC"
	S vobj(vOid)=$G(^SCATBL(3,v1,v2))
	I vobj(vOid)="",'$D(^SCATBL(3,v1,v2))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDb5(v1,v2)	;	vobj()=Db.getRecord(SCATBL3,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSCATBL3"
	S vobj(vOid)=$G(^SCATBL(1,v1,v2))
	I vobj(vOid)="",'$D(^SCATBL(1,v1,v2))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDbNew1(v1,v2)	;	vobj()=Class.new(SCATBLDOC)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSCATBLDOC",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vOpen1()	;	MNUMB,SNUMB FROM SCAMENU WHERE MNUMB>:N
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(N) I vos2="",'$D(N) G vL1a0
	S vos3=vos2
vL1a3	S vos3=$O(^SCATBL(0,vos3),1) I vos3="" G vL1a0
	S vos4=""
vL1a5	S vos4=$O(^SCATBL(0,vos3,vos4),1) I vos4="" G vL1a3
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen2()	;	FN,SEQ FROM SCATBL4 WHERE FN>:N
	;
	;
	S vos5=2
	D vL2a1
	Q ""
	;
vL2a0	S vos5=0 Q
vL2a1	S vos6=$G(N) I vos6="",'$D(N) G vL2a0
	S vos7=vos6
vL2a3	S vos7=$O(^SCATBL(4,vos7),1) I vos7="" G vL2a0
	S vos8=""
vL2a5	S vos8=$O(^SCATBL(4,vos7,vos8),1) I vos8="" G vL2a3
	Q
	;
vFetch2()	;
	;
	;
	I vos5=1 D vL2a5
	I vos5=2 S vos5=1
	;
	I vos5=0 Q 0
	;
	S rs=$S(vos7=$C(254):"",1:vos7)_$C(9)_$S(vos8=$C(254):"",1:vos8)
	;
	Q 1
	;
vOpen3()	;	FN,SEQ FROM SCATBLDOC WHERE FN=:FN AND SEQ>:N
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(FN) I vos2="" G vL3a0
	S vos3=$G(N) I vos3="",'$D(N) G vL3a0
	S vos4=vos3
vL3a4	S vos4=$O(^SCATBL(3,vos2,vos4),1) I vos4="" G vL3a0
	Q
	;
vFetch3()	;
	;
	;
	I vos1=1 D vL3a4
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=vos2_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen4()	;	FN,SEQ FROM SCATBLDOC WHERE FN=:FN
	;
	;
	S vos1=2
	D vL4a1
	Q ""
	;
vL4a0	S vos1=0 Q
vL4a1	S vos2=$G(FN) I vos2="" G vL4a0
	S vos3=""
vL4a3	S vos3=$O(^SCATBL(3,vos2,vos3),1) I vos3="" G vL4a0
	Q
	;
vFetch4()	;
	;
	;
	I vos1=1 D vL4a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen5()	;	FN,SEQ FROM SCATBLDOC WHERE FN=:FN
	;
	;
	S vos1=2
	D vL5a1
	Q ""
	;
vL5a0	S vos1=0 Q
vL5a1	S vos2=$G(FN) I vos2="" G vL5a0
	S vos3=""
vL5a3	S vos3=$O(^SCATBL(3,vos2,vos3),1) I vos3="" G vL5a0
	Q
	;
vFetch5()	;
	;
	;
	I vos1=1 D vL5a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vReSav1(scatbld)	;	RecordSCATBLDOC saveNoFiler(LOG)
	;
	D ^DBSLOGIT(scatbld,vobj(scatbld,-2))
	S ^SCATBL(3,vobj(scatbld,-3),vobj(scatbld,-4))=$$RTBAR^%ZFUNC($G(vobj(scatbld)))
	Q
	;
vReSav2(scatbl3)	;	RecordSCATBL3 saveNoFiler(LOG)
	;
	D ^DBSLOGIT(scatbl3,vobj(scatbl3,-2))
	S ^SCATBL(1,vobj(scatbl3,-3),vobj(scatbl3,-4))=$$RTBAR^%ZFUNC($G(vobj(scatbl3)))
	Q
