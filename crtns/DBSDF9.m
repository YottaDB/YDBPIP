DBSDF9	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSDF9 ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	; **********************************************************************
	; * IMPORTANT NOTE:                                                    *
	; * According to the rules that apply to PSL compiler upgrades,        *
	; * the generated M routine associated with this procedure must be     *
	; * checked into StarTeam and released with the procedure whenever     *
	; * changes are made to this procedure.                                *
	; *                                                                    *
	; * The mrtns version will be used during upgrades and will then be    *
	; * removed from the mrtns directory.  Therefore, other than in a      *
	; * development environment, or during an upgrade, an mrtns version of *
	; * this routine should not exist.                                     *
	; *                                                                    *
	; * Keep these comments as single line to ensure they exist in the     *
	; * generated M code.                                                  *
	; **********************************************************************
	;
	; Prompt for list of tables
	Q:'$$LIST^DBSGETID("DBTBL1") 
	;
	N rs,vos1,vos2,vos3  N V1 S V1=$J S rs=$$vOpen1()
	;
	F  Q:'($$vFetch1())  D BLDINDX(rs)
	;
	 N V2 S V2=$J D vDbDe1()
	;
	; Done
	WRITE $$MSG^%TRMVT($$^MSG(855),"",1)
	;
	Q 
	;
BUILDALL	;
	;
	N rs,vos1,vos2 S rs=$$vOpen2()
	;
	F  Q:'($$vFetch2())  D BLDINDX(rs)
	;
	Q 
	;
BLDINDX(TABLE)	; Table name
	;
	N %O
	N LISTDFT N LISTREQ
	;
	S %O=0
	S (LISTDFT,LISTREQ)=""
	;
	N dbtbl1 S dbtbl1=$$vDb1("SYSDEV",TABLE)
	 S vobj(dbtbl1,101)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),101))
	 S vobj(dbtbl1,102)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),102))
	;
	; Rebuild indexes if not relational database
	I '$$rdb^UCDBRT("DBTBL1") D
	.	;
	.	N N N TYPE
	.	;
	.	; Delete existing entries before rebuild
	.	;
	.	; ^XDBREF entries
	.	F TYPE="DBTBL1.FSN","DBTBL1.GLOBAL","DBTBL1.UDFILE" D
	..		;
	..		S N=""
	..		; Allow global references
	..		;    #ACCEPT Date=11/17/05; Pgm=RussellDS; CR=18065
	..		F  S N=$order(^XDBREF(TYPE,"SYSDEV",N)) Q:(N="")  K ^XDBREF(TYPE,"SYSDEV",N,TABLE)
	..		Q 
	.	;
	.	; ^DBINDX entries
	.	F TYPE="FKPTR","MDD","PARFID" D
	..		;
	..		S N=""
	..		; Allow global references
	..		;    #ACCEPT Date=11/17/05; Pgm=RussellDS; CR=18065
	..		F  S N=$order(^DBINDX("SYSDEV",TYPE,N)) Q:(N="")  K ^DBINDX("SYSDEV",TYPE,N,TABLE)
	..		Q 
	.	;
	.	S N=""
	.	; Allow global references
	.	;   #ACCEPT Date=11/17/05; Pgm=RussellDS; CR=18065
	.	F  S N=$order(^DBINDX("SYSDEV","DOM","PBS",N)) Q:(N="")  K ^DBINDX("SYSDEV","DOM","PBS",N,TABLE)
	.	;
	.	; Allow global references
	.	;   #ACCEPT Date=11/17/05; Pgm=RussellDS; CR=18065
	.	K ^DBINDX("SYSDEV","STR",TABLE)
	.	;
	.	; Rebuild - DBTBL1
	.	D VINDEX^DBSDF1F(dbtbl1)
	.	 S:'$D(vobj(dbtbl1,101)) vobj(dbtbl1,101)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),101))
	.	 S:'$D(vobj(dbtbl1,102)) vobj(dbtbl1,102)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),102))
	.	;
	.	; Rebuild - DBTBL1D, and create DFT and REQ lists
	.	N ds,vos1,vos2,vos3 S ds=$$vOpen3()
	.	;
	.	F  Q:'($$vFetch3())  D
	..		;
	..		N dbtbl1d S dbtbl1d=$$vDb2($P(ds,$C(9),1),$P(ds,$C(9),2),$P(ds,$C(9),3))
	..		;
	..		D VINDEX^DBSDFF(dbtbl1d)
	..		;
	..		I '$$isLit^UCGM(vobj(dbtbl1d,-5)) D
	...			;
	...			I $P(vobj(dbtbl1d),$C(124),15)!($P(vobj(dbtbl1d),$C(124),1)["*") S LISTREQ=LISTREQ_vobj(dbtbl1d,-5)_","
	...			I '($P(vobj(dbtbl1d),$C(124),3)="") S LISTDFT=LISTDFT_vobj(dbtbl1d,-5)_","
	...			Q 
	..		K vobj(+$G(dbtbl1d)) Q 
	.	;
	.	; Rebuilt - DBTBL1F
	.	N dsfk,vos4,vos5,vos6 S dsfk=$$vOpen4()
	.	;
	.	F  Q:'($$vFetch4())  D
	..		;
	..		N dbtbl1f S dbtbl1f=$$vDb3($P(dsfk,$C(9),1),$P(dsfk,$C(9),2),$P(dsfk,$C(9),3))
	..		;
	..		D VINDEX^DBSDFKF(dbtbl1f)
	..		K vobj(+$G(dbtbl1f)) Q 
	.	Q 
	;
	; Just build LISTDFT and LISTREQ
	E  D
	.	;
	.	N ds,vos7,vos8,vos9 S ds=$$vOpen5()
	.	;
	.	F  Q:'($$vFetch5())  D
	..		;
	..		N dbtbl1d,vop1 S vop1=$P(ds,$C(9),3),dbtbl1d=$G(^DBTBL($P(ds,$C(9),1),1,$P(ds,$C(9),2),9,vop1))
	..		;
	..		I '$$isLit^UCGM(vop1) D
	...			;
	...			I $P(dbtbl1d,$C(124),15)!($P(dbtbl1d,$C(124),1)["*") S LISTREQ=LISTREQ_vop1_","
	...			I '($P(dbtbl1d,$C(124),3)="") S LISTDFT=LISTDFT_vop1_","
	...			Q 
	..		Q 
	.	Q 
	;
	S LISTDFT=$E(LISTDFT,1,$L(LISTDFT)-1)
	S LISTREQ=$E(LISTREQ,1,$L(LISTREQ)-1)
	;
	; Only save if change to avoid always having filer reset last user and date
	I (($P(vobj(dbtbl1,101),$C(124),1)'=LISTDFT)!($P(vobj(dbtbl1,102),$C(124),1)'=LISTREQ)) D
	.	;
	.	I ($P(vobj(dbtbl1,101),$C(124),1)'=LISTDFT) S vobj(dbtbl1,-100,101)="",$P(vobj(dbtbl1,101),$C(124),1)=LISTDFT
	.	I ($P(vobj(dbtbl1,102),$C(124),1)'=LISTREQ) S vobj(dbtbl1,-100,102)="",$P(vobj(dbtbl1,102),$C(124),1)=LISTREQ
	.	;
	.	; Use /NOLOG to prevent problems with clean install.  There is
	.	; no reason to log these changes anyway.
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSDF1F(dbtbl1,"/CASDEL/INDEX/JOURNAL/NOLOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(dbtbl1,-100) S vobj(dbtbl1,-2)=1 Tcommit:vTp  
	.	Q 
	;
	K vobj(+$G(dbtbl1)) Q 
	;
%EXT	;
	;
	; Rebuild field ID index file
	WRITE !!,$$^MSG("3221"),!!
	WRITE $$vdat2str($P($H,",",1),"MM/DD/YEAR"),"  ",$$TIM^%ZM,!!
	;
	N ds,vos1,vos2 S ds=$$vOpen6()
	;
	F  Q:'($$vFetch6())  D
	.	;
	.	N glref
	.	;
	.	N dbtbl1 S dbtbl1=$$vDb4($P(ds,$C(9),1),$P(ds,$C(9),2))
	.	 S vobj(dbtbl1,0)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),0))
	.	 S vobj(dbtbl1,16)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),16))
	.	 S vobj(dbtbl1,100)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),100))
	.	;
	.	I ($P(vobj(dbtbl1,0),$C(124),1)="") S glref=""
	.	;
	.	E  S glref="^"_$P(vobj(dbtbl1,0),$C(124),1)_"("_$P(vobj(dbtbl1,16),$C(124),1)
	.	;
	.	I ($P(vobj(dbtbl1,100),$C(124),1)'=glref) D
	..		;
	..	 S vobj(dbtbl1,-100,100)="",$P(vobj(dbtbl1,100),$C(124),1)=glref
	..		;
	..	 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSDF1F(dbtbl1,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(dbtbl1,-100) S vobj(dbtbl1,-2)=1 Tcommit:vTp  
	..		Q 
	.	K vobj(+$G(dbtbl1)) Q 
	;
	Q 
	;
vSIG()	;
	Q "60415^62354^Dan Russell^5766" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM TMPDQ WHERE PID=:V2
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen7()
	F  Q:'($$vFetch7())  D
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
vdat2str(object,mask)	; Date.toString
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I (object="") Q ""
	I (mask="") S mask="MM/DD/YEAR"
	N cc N lday N lmon
	I mask="DL"!(mask="DS") D  ; Long or short weekday
	.	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
	.	I (cc="") S cc="US"
	.	S lday=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
	.	S mask="DAY" ; Day of the week
	.	Q 
	I mask="ML"!(mask="MS") D  ; Long or short month
	.	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
	.	I (cc="") S cc="US"
	.	S lmon=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
	.	S mask="MON" ; Month of the year
	.	Q 
	Q $ZD(object,mask,$get(lmon),$get(lday))
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(DBTBL1,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL1"
	S vobj(vOid)=$G(^DBTBL(v1,1,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,1,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDb2(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL1D,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL1D"
	S vobj(vOid)=$G(^DBTBL(v1,1,v2,9,v3))
	I vobj(vOid)="",'$D(^DBTBL(v1,1,v2,9,v3))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDb3(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL1F,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL1F"
	S vobj(vOid)=$G(^DBTBL(v1,19,v2,v3))
	I vobj(vOid)="",'$D(^DBTBL(v1,19,v2,v3))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDb4(v1,v2)	;	vobj()=Db.getRecord(DBTBL1,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL1"
	S vobj(vOid)=$G(^DBTBL(v1,1,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,1,v2))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vOpen1()	;	ELEMENT FROM TMPDQ WHERE PID=:V1 ORDER BY ELEMENT ASC
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(V1) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^TEMP(vos2,vos3),1) I vos3="" G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen2()	;	FID FROM DBTBL1 WHERE %LIBS='SYSDEV' ORDER BY FID ASC
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=""
vL2a2	S vos2=$O(^DBTBL("SYSDEV",1,vos2),1) I vos2="" G vL2a0
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
vOpen3()	;	%LIBS,FID,DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:TABLE ORDER BY DI ASC
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(TABLE) I vos2="" G vL3a0
	S vos3=""
vL3a3	S vos3=$O(^DBTBL("SYSDEV",1,vos2,9,vos3),1) I vos3="" G vL3a0
	Q
	;
vFetch3()	;
	;
	;
	I vos1=1 D vL3a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen4()	;	%LIBS,FID,FKEYS FROM DBTBL1F WHERE %LIBS='SYSDEV' AND FID=:TABLE
	;
	;
	S vos4=2
	D vL4a1
	Q ""
	;
vL4a0	S vos4=0 Q
vL4a1	S vos5=$G(TABLE) I vos5="" G vL4a0
	S vos6=""
vL4a3	S vos6=$O(^DBTBL("SYSDEV",19,vos5,vos6),1) I vos6="" G vL4a0
	Q
	;
vFetch4()	;
	;
	;
	I vos4=1 D vL4a3
	I vos4=2 S vos4=1
	;
	I vos4=0 Q 0
	;
	S dsfk="SYSDEV"_$C(9)_vos5_$C(9)_$S(vos6=$C(254):"",1:vos6)
	;
	Q 1
	;
vOpen5()	;	%LIBS,FID,DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:TABLE ORDER BY DI ASC
	;
	;
	S vos7=2
	D vL5a1
	Q ""
	;
vL5a0	S vos7=0 Q
vL5a1	S vos8=$G(TABLE) I vos8="" G vL5a0
	S vos9=""
vL5a3	S vos9=$O(^DBTBL("SYSDEV",1,vos8,9,vos9),1) I vos9="" G vL5a0
	Q
	;
vFetch5()	;
	;
	;
	I vos7=1 D vL5a3
	I vos7=2 S vos7=1
	;
	I vos7=0 Q 0
	;
	S ds="SYSDEV"_$C(9)_vos8_$C(9)_$S(vos9=$C(254):"",1:vos9)
	;
	Q 1
	;
vOpen6()	;	%LIBS,FID FROM DBTBL1 WHERE %LIBS='SYSDEV' ORDER BY FID ASC
	;
	;
	S vos1=2
	D vL6a1
	Q ""
	;
vL6a0	S vos1=0 Q
vL6a1	S vos2=""
vL6a2	S vos2=$O(^DBTBL("SYSDEV",1,vos2),1) I vos2="" G vL6a0
	Q
	;
vFetch6()	;
	;
	;
	I vos1=1 D vL6a2
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S ds="SYSDEV"_$C(9)_$S(vos2=$C(254):"",1:vos2)
	;
	Q 1
	;
vOpen7()	;	PID,ELEMENT FROM TMPDQ WHERE PID=:V2
	;
	;
	S vos1=2
	D vL7a1
	Q ""
	;
vL7a0	S vos1=0 Q
vL7a1	S vos2=$G(V2) I vos2="" G vL7a0
	S vos3=""
vL7a3	S vos3=$O(^TEMP(vos2,vos3),1) I vos3="" G vL7a0
	Q
	;
vFetch7()	;
	;
	;
	I vos1=1 D vL7a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
