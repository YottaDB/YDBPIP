DBSPROT	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSPROT ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	Q  ; No entry from top
	;
CREATE	;
	;
	N rebuild
	;
	F  Q:'$$SCREEN(0,.rebuild) 
	;
	I ($D(rebuild)>0) D BUILD0(.rebuild)
	;
	Q 
	;
MODIFY	;
	;
	N rebuild
	;
	F  Q:'$$SCREEN(1,.rebuild) 
	;
	I ($D(rebuild)>0) D BUILD0(.rebuild)
	;
	Q 
	;
DELETE	;
	;
	N DINAM N FID N GROUP N rebuild
	;
	F  Q:'$$SCREEN(3,.rebuild,.FID,.DINAM,.GROUP) 
	;
	I ($D(rebuild)>0) D BUILD0(.rebuild)
	;
	Q 
	;
LIST	;
	;
	N RID S RID="DBTBL14"
	;
	D DRV^URID ; Run report
	;
	Q 
	;
BUILD	;
	;
	D ^DBSPROT3
	;
	Q 
	;
BUILDALL	;
	;
	N rs,vos1,vos2 S rs=$$vOpen1()
	;
	F  Q:'($$vFetch1())  D BUILD^DBSPROT3(rs)
	;
	Q 
	;
BUILD0(rebuild)	; List of element to rebuild
	;
	N FID S FID=""
	;
	F  S FID=$order(rebuild(FID)) Q:(FID="")  D BUILD^DBSPROT3(FID)
	;
	Q 
	;
SCREEN(%O,rebuild,FID,DINAM,GROUP)	;
	;
	N %FRAME N %REPEAT N I N OLNTB N PRTOPT
	N %READ N %TAB N DIPROT N GROUPDES N PROTDI N PROTFL N VFMQ N ZMSG1
	;
	N dbtbl14q
	;
	S (DINAM,FID,GROUP)=""
	;
	S %REPEAT=12
	S PRTOPT=%O
	;
	; Read Access
	S DIPROT(1)=$$^MSG(6357)
	; No Access
	S DIPROT(2)=$$^MSG(5186)
	; ~p1Enter * for record level protection
	S ZMSG1=$$^MSG(5190,"     ")
	;
	S %TAB("FID")=".FID1/TBL=[DBTBL1]/XPP=D PP1^DBSPROT"
	S %TAB("DINAM")=".ORGDI1/TBL=[DBTBL1D]:QUERY ""[DBTBL1D]FID=<<FID>>"""
	S %TAB("GROUP")=".DQGRP1/TBL=[DBTBL14]:QUERY ""[DBTBL14]FID=<<FID>> AND [DBTBL14]DINAM=<<DINAM>>""/XPP=D PP3^DBSPROT/MIN=1/MAX=99"
	;
	I (%O=0) S %TAB("DINAM")=%TAB("DINAM")_"/XPP=D PP2^DBSPROT"
	E  D
	.	;
	.	; Create look-up table for modify/delete
	.	;
	.	N rs,vos1,vos2 S rs=$$vOpen2()
	.	;
	.	F  Q:'($$vFetch2())  D
	..		;
	..		N FID S FID=rs
	..		;
	..		N dbtbl1 S dbtbl1=$$vDb5("SYSDEV",FID)
	..		;
	..		S PROTFL(FID)=$P(dbtbl1,$C(124),1)
	..		Q 
	.	;
	.	S %TAB("FID")=%TAB("FID")_"/TBL=PROTFL("
	.	S %TAB("DINAM")=%TAB("DINAM")_"/TBL=PROTDI("
	.	Q 
	;
	S %READ="@@%FN,,FID/REQ,,DINAM/REQ,,GROUP/REQ,"
	S %FRAME=2
	;
	D ^UTLREAD I (VFMQ="Q") D vKill1("") Q 0 ; Done
	;
	I ((FID="")!(DINAM="")!(GROUP="")) D vKill1("") Q 0 ; Done
	;
	; Record Level Protection
	I (GROUP="*") S GROUPDES=$$^MSG(5188)
	E  S GROUPDES=""
	;
	N dbtbl14 S dbtbl14=$$vDb2("SYSDEV",FID,DINAM,GROUP)
	;
	F I=1:1:%REPEAT K vobj(+$G(dbtbl14q(I))) S dbtbl14q(I)=$$vDb3("SYSDEV",FID,DINAM,GROUP,I)
	;
	N vo1 N vo2 N vo3 D DRV^USID(%O,"DBTBL14",.dbtbl14q,.dbtbl14,.vo1,.vo2,.vo3) K vobj(+$G(vo1)) K vobj(+$G(vo2)) K vobj(+$G(vo3))
	;
	I (VFMQ="Q") D vKill1("") K vobj(+$G(dbtbl14)) Q 0 ; Done
	;
	S rebuild(FID)="" ; Flag to rebuild
	;
	Tstart (vobj):transactionid="CS"
	;
	I (PRTOPT=3) D  ; Delete definition
	.	;
	.	D vDbDe1()
	.	D vDbDe2()
	.	Q 
	;
	E  D  ; File data
	.	;
	.	N SEQ
	.	;
	. S $P(vobj(dbtbl14),$C(124),6)=$P($H,",",1)
	. S $P(vobj(dbtbl14),$C(124),15)=%UID
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(dbtbl14) S vobj(dbtbl14,-2)=1 Tcommit:vTp  
	.	;
	.	; Remove old queries first
	.	D vDbDe3()
	.	;
	.	S SEQ=0
	.	F I=1:1:%REPEAT I '($P(vobj(dbtbl14q(I)),$C(124),1)="") D
	..		;
	..		S SEQ=SEQ+1
	..	 S vobj(dbtbl14q(I),-7)=SEQ
	..		;
	..	 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav2(dbtbl14q(I)) S vobj(dbtbl14q(I),-2)=1 Tcommit:vTp  
	..		Q 
	.	;
	.	; Keep a single blank query, at least for report DBTBL14
	.	I (SEQ=0) N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav2(dbtbl14q(1)) S vobj(dbtbl14q(1),-2)=1 Tcommit:vTp  
	.	Q 
	;
	Tcommit:$Tlevel 
	;
	D vKill1("") K vobj(+$G(dbtbl14)) Q 1 ; Continue
	;
PP1	; FID post processor
	;
	Q:(X="") 
	;
	I ($$PGM^UPID(X)="") D  Q 
	.	;
	.	S ER=1
	.	; Set up protection program name first (file definition control page)
	.	S RM=$$^MSG(2506)
	.	Q 
	;
	; Setup look-up table
	K PROTDI
	;
	N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen3()
	;
	F  Q:'($$vFetch3())  D
	.	;
	.	N DINAM S DINAM=rs
	.	;
	.	; Record Protection
	.	I (DINAM="*") S PROTDI(DINAM)=$$^MSG(5189)
	.	E  D
	..		;
	..		N dbtbl1d S dbtbl1d=$$vDb6("SYSDEV",X,DINAM)
	..		;
	..		S PROTDI(DINAM)=$P(dbtbl1d,$C(124),10)
	..		Q 
	.	Q 
	;
	Q 
	;
PP2	; DINAM post processor
	;
	I (X="") D
	.	;
	.	S NI=0
	.	S %NOPRMT="Q"
	.	Q 
	E  I (X="*") D
	.	;
	.	; Record level protection
	.	S RM=$$^MSG(5188)
	.	S I(3)=""
	.	Q 
	;
	E  I ($D(^DBTBL("SYSDEV",1,FID,9,X))#2) S I(3)=""
	;
	Q 
	;
PP3	; GROUP post processor
	;
	Q:(X="") 
	Q:(PRTOPT>0) 
	;
	S I(3)=""
	;
	Q:'($D(^DBTBL("SYSDEV",14,FID,DINAM,X))#2) 
	;
	S ER=1
	; Protection definition already created
	S RM=$$^MSG("2278")
	;
	Q 
	;
vSIG()	;
	Q "60257^34875^Dan Russell^5726" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM DBTBL14Q WHERE PLIBS='SYSDEV' AND FID=:FID AND DINAM=:DINAM AND GROUP=:GROUP
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3 N v4 N v5
	Tstart (vobj):transactionid="CS"
	N vRec S vRec=$$vDbNew1("","","","","")
	S vobj(vRec,-2)=3
	N vRs,vos1,vos2,vos3,vos4,vos5 S vRs=$$vOpen4()
	F  Q:'($$vFetch4())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3) S v4=$P(vRs,$C(9),4) S v5=$P(vRs,$C(9),5)
	. S vobj(vRec,-3)=v1 S vobj(vRec,-4)=v2 S vobj(vRec,-5)=v3 S vobj(vRec,-6)=v4 S vobj(vRec,-7)=v5
	.	;     #ACCEPT CR=21101;DATE=2006-05-11;PGM=FSCW;GROUP=DEPRECATED
	.	D ^DBSLOGIT($G(vRec),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^DBTBL(v1,14,v2,v3,v4,v5)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	K vobj(+$G(vRec)) Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe2()	; DELETE FROM DBTBL14 WHERE PLIBS='SYSDEV' AND FID=:FID AND DINAM=:DINAM AND GROUP=:GROUP
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3 N v4
	Tstart (vobj):transactionid="CS"
	N vRec S vRec=$$vDbNew2("","","","")
	S vobj(vRec,-2)=3
	N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen5()
	F  Q:'($$vFetch5())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3) S v4=$P(vRs,$C(9),4)
	. S vobj(vRec,-3)=v1 S vobj(vRec,-4)=v2 S vobj(vRec,-5)=v3 S vobj(vRec,-6)=v4
	.	;     #ACCEPT CR=21101;DATE=2006-05-11;PGM=FSCW;GROUP=DEPRECATED
	.	D ^DBSLOGIT($G(vRec),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^DBTBL(v1,14,v2,v3,v4)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	K vobj(+$G(vRec)) Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe3()	; DELETE FROM DBTBL14Q WHERE PLIBS='SYSDEV' AND FID=:FID AND DINAM=:DINAM AND GROUP=:GROUP
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3 N v4 N v5
	Tstart (vobj):transactionid="CS"
	N vRec S vRec=$$vDbNew1("","","","","")
	S vobj(vRec,-2)=3
	N vRs,vos1,vos2,vos3,vos4,vos5 S vRs=$$vOpen6()
	F  Q:'($$vFetch6())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3) S v4=$P(vRs,$C(9),4) S v5=$P(vRs,$C(9),5)
	. S vobj(vRec,-3)=v1 S vobj(vRec,-4)=v2 S vobj(vRec,-5)=v3 S vobj(vRec,-6)=v4 S vobj(vRec,-7)=v5
	.	;     #ACCEPT CR=21101;DATE=2006-05-11;PGM=FSCW;GROUP=DEPRECATED
	.	D ^DBSLOGIT($G(vRec),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^DBTBL(v1,14,v2,v3,v4,v5)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	K vobj(+$G(vRec)) Q 
	;
vDb2(v1,v2,v3,v4)	;	vobj()=Db.getRecord(DBTBL14,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL14"
	S vobj(vOid)=$G(^DBTBL(v1,14,v2,v3,v4))
	I vobj(vOid)="",'$D(^DBTBL(v1,14,v2,v3,v4))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	S vobj(vOid,-6)=v4
	Q vOid
	;
vDb3(v1,v2,v3,v4,v5)	;	vobj()=Db.getRecord(DBTBL14Q,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL14Q"
	S vobj(vOid)=$G(^DBTBL(v1,14,v2,v3,v4,v5))
	I vobj(vOid)="",'$D(^DBTBL(v1,14,v2,v3,v4,v5))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	S vobj(vOid,-6)=v4
	S vobj(vOid,-7)=v5
	Q vOid
	;
vDb5(v1,v2)	;	voXN = Db.getRecord(DBTBL1,,0)
	;
	N dbtbl1
	S dbtbl1=$G(^DBTBL(v1,1,v2))
	I dbtbl1="",'$D(^DBTBL(v1,1,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1" X $ZT
	Q dbtbl1
	;
vDb6(v1,v2,v3)	;	voXN = Db.getRecord(DBTBL1D,,0)
	;
	N dbtbl1d
	S dbtbl1d=$G(^DBTBL(v1,1,v2,9,v3))
	I dbtbl1d="",'$D(^DBTBL(v1,1,v2,9,v3))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1D" X $ZT
	Q dbtbl1d
	;
vDbNew1(v1,v2,v3,v4,v5)	;	vobj()=Class.new(DBTBL14Q)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL14Q",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	S vobj(vOid,-6)=v4
	S vobj(vOid,-7)=v5
	Q vOid
	;
vDbNew2(v1,v2,v3,v4)	;	vobj()=Class.new(DBTBL14)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL14",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	S vobj(vOid,-6)=v4
	Q vOid
	;
vKill1(ex1)	;	Delete objects dbtbl14q()
	;
	N n1 S (n1)=""
	F  S n1=$O(dbtbl14q(n1)) Q:n1=""  K:'((n1=ex1)) vobj(dbtbl14q(n1))
	Q
	;
vOpen1()	;	DISTINCT FID FROM DBTBL14 WHERE PLIBS='SYSDEV'
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=""
vL1a2	S vos2=$O(^DBTBL("SYSDEV",14,vos2),1) I vos2="" G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a2
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos2=$C(254):"",1:vos2)
	;
	Q 1
	;
vOpen2()	;	DISTINCT FID FROM DBTBL14 WHERE PLIBS='SYSDEV'
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=""
vL2a2	S vos2=$O(^DBTBL("SYSDEV",14,vos2),1) I vos2="" G vL2a0
	Q
	;
vFetch2()	;
	;
	;
	I vos1=1 D vL2a2
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos2=$C(254):"",1:vos2)
	;
	Q 1
	;
vOpen3()	;	DINAM FROM DBTBL14 WHERE PLIBS='SYSDEV' AND FID=:X
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(X) I vos2="" G vL3a0
	S vos3=""
vL3a3	S vos3=$O(^DBTBL("SYSDEV",14,vos2,vos3),1) I vos3="" G vL3a0
	S vos4=""
vL3a5	S vos4=$O(^DBTBL("SYSDEV",14,vos2,vos3,vos4),1) I vos4="" G vL3a3
	Q
	;
vFetch3()	;
	;
	;
	I vos1=1 D vL3a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen4()	;	PLIBS,FID,DINAM,GROUP,QUERY FROM DBTBL14Q WHERE PLIBS='SYSDEV' AND FID=:FID AND DINAM=:DINAM AND GROUP=:GROUP
	;
	;
	S vos1=2
	D vL4a1
	Q ""
	;
vL4a0	S vos1=0 Q
vL4a1	S vos2=$G(FID) I vos2="" G vL4a0
	S vos3=$G(DINAM) I vos3="" G vL4a0
	S vos4=$G(GROUP) I vos4="" G vL4a0
	S vos5=""
vL4a5	S vos5=$O(^DBTBL("SYSDEV",14,vos2,vos3,vos4,vos5),1) I vos5="" G vL4a0
	Q
	;
vFetch4()	;
	;
	;
	I vos1=1 D vL4a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs="SYSDEV"_$C(9)_vos2_$C(9)_vos3_$C(9)_vos4_$C(9)_$S(vos5=$C(254):"",1:vos5)
	;
	Q 1
	;
vOpen5()	;	PLIBS,FID,DINAM,GROUP FROM DBTBL14 WHERE PLIBS='SYSDEV' AND FID=:FID AND DINAM=:DINAM AND GROUP=:GROUP
	;
	;
	S vos1=2
	D vL5a1
	Q ""
	;
vL5a0	S vos1=0 Q
vL5a1	S vos2=$G(FID) I vos2="" G vL5a0
	S vos3=$G(DINAM) I vos3="" G vL5a0
	S vos4=$G(GROUP) I vos4="" G vL5a0
	I '($D(^DBTBL("SYSDEV",14,vos2,vos3,vos4))#2) G vL5a0
	Q
	;
vFetch5()	;
	;
	;
	;
	I vos1=0 Q 0
	;
	S vos1=100
	S vRs="SYSDEV"_$C(9)_vos2_$C(9)_vos3_$C(9)_vos4
	S vos1=0
	;
	Q 1
	;
vOpen6()	;	PLIBS,FID,DINAM,GROUP,QUERY FROM DBTBL14Q WHERE PLIBS='SYSDEV' AND FID=:FID AND DINAM=:DINAM AND GROUP=:GROUP
	;
	;
	S vos1=2
	D vL6a1
	Q ""
	;
vL6a0	S vos1=0 Q
vL6a1	S vos2=$G(FID) I vos2="" G vL6a0
	S vos3=$G(DINAM) I vos3="" G vL6a0
	S vos4=$G(GROUP) I vos4="" G vL6a0
	S vos5=""
vL6a5	S vos5=$O(^DBTBL("SYSDEV",14,vos2,vos3,vos4,vos5),1) I vos5="" G vL6a0
	Q
	;
vFetch6()	;
	;
	;
	I vos1=1 D vL6a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs="SYSDEV"_$C(9)_vos2_$C(9)_vos3_$C(9)_vos4_$C(9)_$S(vos5=$C(254):"",1:vos5)
	;
	Q 1
	;
vReSav1(dbtbl14)	;	RecordDBTBL14 saveNoFiler(LOG)
	;
	D ^DBSLOGIT(dbtbl14,vobj(dbtbl14,-2))
	S ^DBTBL(vobj(dbtbl14,-3),14,vobj(dbtbl14,-4),vobj(dbtbl14,-5),vobj(dbtbl14,-6))=$$RTBAR^%ZFUNC($G(vobj(dbtbl14)))
	Q
	;
vReSav2(vOid)	;	RecordDBTBL14Q saveNoFiler(LOG)
	;
	D ^DBSLOGIT(vOid,vobj(vOid,-2))
	S ^DBTBL(vobj(vOid,-3),14,vobj(vOid,-4),vobj(vOid,-5),vobj(vOid,-6),vobj(vOid,-7))=$$RTBAR^%ZFUNC($G(vobj(vOid)))
	Q
