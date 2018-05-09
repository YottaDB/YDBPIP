DBSBAT	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSBAT ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	Q  ; No entry from top
	;
CREATE	;
	;
	D exec(0)
	;
	Q 
	;
MODIFY	;
	;
	D exec(1)
	;
	Q 
	;
DELETE	;
	;
	D exec(3)
	;
	Q 
	;
COPY	;
	;
	N %FRAME N OLNTB
	N %READ N %TAB N BCHFROM N BCHTO N VFMQ
	;
	S %TAB("BCHFROM")="/DES=From Batch Name/LE=12/TYP=U/TBL=[DBTBL33]"
	S %TAB("BCHTO")="/DES=To Batch Name/LE=12/TYP=U/TBL=[DBTBL33]:NOVAL/XPP=D pp^DBSBAT"
	S %READ="@@%FN,,BCHFROM/REQ,BCHTO/REQ,"
	S %FRAME=2
	;
	D ^UTLREAD Q:(VFMQ="Q") 
	;
	Tstart (vobj):transactionid="CS"
	;
	; Copy header
	N bchfrom S bchfrom=$$vDb1("SYSDEV",BCHFROM)
	N bchto S bchto=$$vReCp1(bchfrom)
	;
	S vobj(bchto,-4)=BCHTO
	S $P(vobj(bchto),$C(124),2)="" ; Remove program name
	;
	S vobj(bchto,-2)=0
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBS33FIL(bchto,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(bchto,-100) S vobj(bchto,-2)=1 Tcommit:vTp  
	;
	; Copy code
	N ds,vos1,vos2,vos3,vos4 S ds=$$vOpen1()
	;
	F  Q:'($$vFetch1())  D
	.	;
	.	N codefrom S codefrom=$$vDb2($P(ds,$C(9),1),$P(ds,$C(9),2),$P(ds,$C(9),3),$P(ds,$C(9),4))
	.	N codeto S codeto=$$vReCp2(codefrom)
	.	;
	. S vobj(codeto,-4)=BCHTO
	.	;
	.	S vobj(codeto,-2)=0
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBS33FL(codeto,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(codeto,-100) S vobj(codeto,-2)=1 Tcommit:vTp  
	.	K vobj(+$G(codefrom)),vobj(+$G(codeto)) Q 
	;
	Tcommit:$Tlevel 
	;
	K vobj(+$G(bchfrom)),vobj(+$G(bchto)) Q 
	;
BUILD	;
	;
	Q:'$$LIST^DBSGETID("DBTBL33")  ; Select names
	;
	N rs,vos1,vos2,vos3  N V1 S V1=$J S rs=$$vOpen2()
	;
	F  Q:'($$vFetch2())  D COMPILE(rs)
	;
	 N V2 S V2=$J D vDbDe1()
	;
	Q 
	;
BUILDALL	;
	;
	N rs,vos1,vos2 S rs=$$vOpen3()
	;
	F  Q:'($$vFetch3())  D COMPILE(rs)
	;
	Q 
	;
COMPILE(BCHID)	;
	;
	WRITE !,BCHID,?15
	;
	D COMPILE^DBSBCH(BCHID)
	;
	Q 
	;
exec(%O)	;
	;
	N zproc
	N %READ N %TAB N BCHID N DBTBL N VFMQ
	;
	I (%O=0) S %TAB("BCHID")="[DBTBL33]BCHID/TBL=[DBTBL33]:NOVAL/XPP=D pp^DBSBAT"
	E  S %TAB("BCHID")="[DBTBL33]BCHID/TBL=[DBTBL33]"
	;
	S %READ="@@%FN/CEN/REV,,BCHID/REQ"
	;
	D ^UTLREAD Q:(VFMQ="Q") 
	;
	S DBTBL("SYSDEV",33,BCHID)="" ; Avoid lock warning
	LOCK +DBTBL("SYSDEV",33,BCHID):2
	E  D  Q 
	.	;
	.	S ER=1
	.	; ~p1 record locked by another user
	.	S RM=$$^MSG(7354,"Batch")
	.	Q 
	;
	N fDBTBL33 S fDBTBL33=$$vDb3("SYSDEV",BCHID)
	;
	; Set default values for create
	I ($G(vobj(fDBTBL33,-2))=0) D
	.	;
	. S $P(vobj(fDBTBL33),$C(124),23)=0
	. S $P(vobj(fDBTBL33),$C(124),11)=100
	. S $P(vobj(fDBTBL33),$C(124),12)=32000
	. S $P(vobj(fDBTBL33),$C(124),14)=0
	. S $P(vobj(fDBTBL33),$C(124),17)=10
	. S $P(vobj(fDBTBL33),$C(124),18)=10
	.	Q 
	;
	N vo1 N vo2 N vo3 N vo4 D DRV^USID(%O,"DBTBL33L",.fDBTBL33,.vo1,.vo2,.vo3,.vo4) K vobj(+$G(vo1)) K vobj(+$G(vo2)) K vobj(+$G(vo3)) K vobj(+$G(vo4))
	;
	I (VFMQ="Q") D  K vobj(+$G(fDBTBL33)) Q 
	.	;
	.	LOCK -DBTBL("SYSDEV",33,BCHID)
	.	Q 
	;
	Tstart (vobj):transactionid="CS"
	;
	I (%O=3) D
	.	;
	.	N pgm S pgm=$P(vobj(fDBTBL33),$C(124),2)
	.	;
	.	I '(pgm="") D DEL^%ZRTNDEL(pgm) ; Delete routine
	.	;
	.	S vobj(fDBTBL33,-2)=3
	.	Q 
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBS33FIL(fDBTBL33,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(fDBTBL33,-100) S vobj(fDBTBL33,-2)=1 Tcommit:vTp  
	;
	; Edit code
	;
	I zproc D
	.	;
	.	N seq
	.	N buf N sec
	.	;
	.	S seq=1
	.	F sec="REVHIST","OPEN","SCHINIT","SCHEXEC","SCHPOST","SCHEXIT","THRINIT","THREXEC","EXEC","THREXIT" D
	..		;
	..		S buf(seq)="---------- "_sec_$J("",8-$L(sec))_"------ Section marker"
	..		S seq=seq+1
	..		S buf(seq)=""
	..		S seq=seq+1
	..		;
	..		N ds,vos1,vos2,vos3,vos4  N V1 S V1=sec S ds=$$vOpen4()
	..		;
	..		F  Q:'($$vFetch4())  D
	...			;
	...			N dbtbl33d S dbtbl33d=$G(^DBTBL($P(ds,$C(9),1),33,$P(ds,$C(9),2),$P(ds,$C(9),3),$P(ds,$C(9),4)))
	...			;
	...			S buf(seq)=$P(dbtbl33d,$C(12),1)
	...			S seq=seq+1
	...			Q 
	..		Q 
	.	;
	.	D ^DBSWRITE("buf")
	.	;
	.	I (VFMQ'="Q") D
	..		;
	..		N isNewSec N isSecTop
	..		N secseq
	..		N x
	..		;
	..		D vDbDe2()
	..		;
	..		S isSecTop=0
	..		S (sec,seq)=""
	..		F  S seq=$order(buf(seq)) Q:(seq="")  D
	...			;
	...			S isNewSec=0
	...			S x=buf(seq)
	...			;
	...			; See if section name, set up new section flags
	...			I $E(x,1,11)="---------- " D
	....				;
	....				N tag
	....				;
	....				S tag=$piece($E(x,12,20)," ",1)
	....				;
	....				I '(tag="") D
	.....					;
	.....					S sec=tag
	.....					S secseq=1
	.....					S isNewSec=1
	.....					S isSecTop=1
	.....					Q 
	....				Q 
	...			;
	...			I 'isNewSec,'(sec="") D
	....				;
	....				; Ignore blank lines at section top
	....				I (x=""),isSecTop Q 
	....				;
	....				S isSecTop=0
	....				;
	....				N dbtbl33d S dbtbl33d=$$vDbNew1("SYSDEV",BCHID,sec,secseq)
	....				;
	....			 S $P(vobj(dbtbl33d),$C(12),1)=x
	....				;
	....			 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBS33FL(dbtbl33d,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(dbtbl33d,-100) S vobj(dbtbl33d,-2)=1 Tcommit:vTp  
	....				;
	....				S secseq=secseq+1
	....				K vobj(+$G(dbtbl33d)) Q 
	...			Q 
	..		Q 
	.	;
	. S $P(vobj(fDBTBL33),$C(124),5)=$P($H,",",2)
	.	;
	.	S vobj(fDBTBL33,-2)=1
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBS33FIL(fDBTBL33,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(fDBTBL33,-100) S vobj(fDBTBL33,-2)=1 Tcommit:vTp  
	.	Q 
	;
	Tcommit:$Tlevel 
	;
	LOCK -DBTBL("SYSDEV",33,BCHID)
	;
	K vobj(+$G(fDBTBL33)) Q 
	;
pp	; UTLREAD post processor to check duplicate name
	;
	Q:(X="") 
	;
	I ($D(^DBTBL("SYSDEV",33,X))#2) D
	.	;
	.	S ER=1
	.	; Already exists
	.	S RM=$$^MSG(253)
	.	Q 
	;
	Q 
	;
vSIG()	;
	Q "60425^2376^Dan Russell^5573" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM TMPDQ WHERE PID = :V2
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen5()
	F  Q:'($$vFetch5())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^TEMP(v1,v2)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe2()	; DELETE FROM DBTBL33D WHERE %LIBS='SYSDEV' AND BCHID=:BCHID
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Tstart (vobj):transactionid="CS"
	N vDs,vos1,vos2,vos3,vos4 S vDs=$$vOpen6()
	F  Q:'($$vFetch6())  D
	.	N vRec S vRec=$$vDb2($P(vDs,$C(9),1),$P(vDs,$C(9),2),$P(vDs,$C(9),3),$P(vDs,$C(9),4))
	.	S vobj(vRec,-2)=3
	.	D ^DBS33FL(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1)
	.	K vobj(+$G(vRec)) Q 
	Tcommit:$Tlevel 
	Q 
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(DBTBL33,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL33"
	S vobj(vOid)=$G(^DBTBL(v1,33,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,33,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL33" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDb2(v1,v2,v3,v4)	;	vobj()=Db.getRecord(DBTBL33D,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL33D"
	S vobj(vOid)=$G(^DBTBL(v1,33,v2,v3,v4))
	I vobj(vOid)="",'$D(^DBTBL(v1,33,v2,v3,v4))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	S vobj(vOid,-6)=v4
	Q vOid
	;
vDb3(v1,v2)	;	vobj()=Db.getRecord(DBTBL33,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL33"
	S vobj(vOid)=$G(^DBTBL(v1,33,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,33,v2))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDbNew1(v1,v2,v3,v4)	;	vobj()=Class.new(DBTBL33D)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL33D",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	S vobj(vOid,-6)=v4
	Q vOid
	;
vOpen1()	;	%LIBS,BCHID,LABEL,SEQ FROM DBTBL33D WHERE %LIBS='SYSDEV' AND BCHID=:BCHFROM
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(BCHFROM) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^DBTBL("SYSDEV",33,vos2,vos3),1) I vos3="" G vL1a0
	S vos4=""
vL1a5	S vos4=$O(^DBTBL("SYSDEV",33,vos2,vos3,vos4),1) I vos4="" G vL1a3
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
	S ds="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen2()	;	ELEMENT FROM TMPDQ WHERE PID=:V1 ORDER BY ELEMENT ASC
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(V1) I vos2="" G vL2a0
	S vos3=""
vL2a3	S vos3=$O(^TEMP(vos2,vos3),1) I vos3="" G vL2a0
	Q
	;
vFetch2()	;
	;
	;
	I vos1=1 D vL2a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen3()	;	BCHID FROM DBTBL33 WHERE %LIBS='SYSDEV' ORDER BY BCHID ASC
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=""
vL3a2	S vos2=$O(^DBTBL("SYSDEV",33,vos2),1) I vos2="" G vL3a0
	Q
	;
vFetch3()	;
	;
	;
	I vos1=1 D vL3a2
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos2=$C(254):"",1:vos2)
	;
	Q 1
	;
vOpen4()	;	%LIBS,BCHID,LABEL,SEQ FROM DBTBL33D WHERE %LIBS='SYSDEV' AND BCHID=:BCHID AND LABEL=:V1 ORDER BY SEQ ASC
	;
	;
	S vos1=2
	D vL4a1
	Q ""
	;
vL4a0	S vos1=0 Q
vL4a1	S vos2=$G(BCHID) I vos2="" G vL4a0
	S vos3=$G(V1) I vos3="" G vL4a0
	S vos4=""
vL4a4	S vos4=$O(^DBTBL("SYSDEV",33,vos2,vos3,vos4),1) I vos4="" G vL4a0
	Q
	;
vFetch4()	;
	;
	;
	I vos1=1 D vL4a4
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds="SYSDEV"_$C(9)_vos2_$C(9)_vos3_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vOpen5()	;	PID,ELEMENT FROM TMPDQ WHERE PID = :V2
	;
	;
	S vos1=2
	D vL5a1
	Q ""
	;
vL5a0	S vos1=0 Q
vL5a1	S vos2=$G(V2) I vos2="" G vL5a0
	S vos3=""
vL5a3	S vos3=$O(^TEMP(vos2,vos3),1) I vos3="" G vL5a0
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
vOpen6()	;	%LIBS,BCHID,LABEL,SEQ FROM DBTBL33D WHERE %LIBS='SYSDEV' AND BCHID=:BCHID
	;
	;
	S vos1=2
	D vL6a1
	Q ""
	;
vL6a0	S vos1=0 Q
vL6a1	S vos2=$G(BCHID) I vos2="" G vL6a0
	S vos3=""
vL6a3	S vos3=$O(^DBTBL("SYSDEV",33,vos2,vos3),1) I vos3="" G vL6a0
	S vos4=""
vL6a5	S vos4=$O(^DBTBL("SYSDEV",33,vos2,vos3,vos4),1) I vos4="" G vL6a3
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
	S vDs="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)_$C(9)_$S(vos4=$C(254):"",1:vos4)
	;
	Q 1
	;
vReCp1(v1)	;	RecordDBTBL33.copy: DBTBL33
	;
	Q $$copy^UCGMR(bchfrom)
	;
vReCp2(v1)	;	RecordDBTBL33D.copy: DBTBL33D
	;
	Q $$copy^UCGMR(codefrom)
