DBSPROC	; Procedure definition
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSPROC ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	; I18N=QUIT
	;
	Q 
	;
EXT(%O)	;
	;
	N SEQ N vER
	N DBTBL N filstr N KEYS N PROCID N TAB N VFMQ
	;
	D ^DBSDEUTL(%O,"DBTBL25")
	;
	Q:VFMQ="Q" 
	;
	S PROCID=$get(KEYS(2)) ; KEYS array defined in DBSDEUTL.
	;
	I (PROCID="") Q 
	;
	S DBTBL("SYSDEV",25,PROCID)="" ; Prevent warning on lock
	LOCK +DBTBL("SYSDEV",25,PROCID):2
	E  D  Q 
	.	S ER=1
	.	S RM=$$^MSG(7354,"Procedure")
	.	Q 
	;
	I %O=3 D  Q  ; Delete old definition
	.	D vDbDe1()
	. ZWI ^DBTBL("SYSDEV",25,PROCID)
	.	;
	.	LOCK -DBTBL("SYSDEV",25,PROCID)
	.	Q 
	;
	N ds,vos1,vos2,vos3 S ds=$$vOpen1()
	;
	I '$G(vos1) D  ; New procedure
	.	;
	.	S TAB=$char(9)
	.	;
	.	;Header information
	.	S filstr(1)=TAB_"/*" ; All is in PSL format
	.	S filstr(2)=TAB_" ORIG: "_%UID_" - "_$S(TJD'="":$ZD(TJD,"MM/DD/YEAR"),1:"") ; Developer , date
	.	S filstr(3)=TAB_" DESC: " ; Description
	.	S filstr(4)=TAB
	.	S filstr(5)=TAB_" ---- Comments --------------------------------------------------------"
	.	S filstr(6)=TAB
	.	S filstr(7)=TAB_" ---- Revision History ------------------------------------------------"
	.	S filstr(8)=TAB
	.	S filstr(9)=TAB_" ****** Consider using setAuditFlag for all objects in this procedure"
	.	S filstr(10)=TAB_"   example :do dep.setAuditFlag(1)"
	.	S filstr(11)=TAB
	.	S filstr(12)=TAB_"*/"
	.	Q 
	E  F  Q:'($$vFetch1())  D
	.	N dbtbl25d,vop1 S vop1=$P(ds,$C(9),3),dbtbl25d=$G(^DBTBL($P(ds,$C(9),1),25,$P(ds,$C(9),2),vop1))
	.	S filstr(vop1)=$P(dbtbl25d,$C(12),1)
	.	Q 
	;
	D ^DBSWRITE("filstr") ; Access editor
	;
	I VFMQ="Q" D  Q  ; <F11> exit
	.	LOCK -DBTBL("SYSDEV",25,PROCID)
	.	I %O=1 S RM=$$^MSG(6710,PROCID) ; Not Modified
	.	Q 
	;
	D vDbDe2() ; Delete existing records
	;
	I '$order(filstr(1)),(filstr(1)="") LOCK -DBTBL("SYSDEV",25,PROCID) Q  ; if everything is deleted from the editor
	;
	S SEQ=0
	F  S SEQ=$order(filstr(SEQ)) Q:(SEQ="")  D
	.	N dbtbl25d,vop2,vop3,vop4,vop5 S dbtbl25d="",vop4="SYSDEV",vop3=PROCID,vop2=SEQ,vop5=0
	. S $P(dbtbl25d,$C(12),1)=filstr(SEQ)
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^DBTBL(vop4,25,vop3,vop2)=dbtbl25d S vop5=1 Tcommit:vTp  
	.	Q 
	;
	; Update audit information and the Time
	N dbtbl25 S dbtbl25=$$vDb2("SYSDEV",PROCID)
	S $P(vobj(dbtbl25),$C(124),4)=%UID
	S $P(vobj(dbtbl25),$C(124),5)=$P($H,",",2)
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBTBL25F(dbtbl25,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(dbtbl25,-100) S vobj(dbtbl25,-2)=1 Tcommit:vTp  
	;
	LOCK -DBTBL("SYSDEV",25,PROCID)
	;
	K vobj(+$G(dbtbl25)) Q 
	;
PP	; Post processor to check duplicate name
	;
	I (X="") Q 
	;
	I ($D(^DBTBL("SYSDEV",25,X))#2) D
	.	S ER=1
	.	S RM=$$^MSG(253)
	.	Q 
	;
	Q 
	;
COPY	; Copy definition (Called by function DBSPROCCO)
	;
	N %FRAME N SEQ
	N PROCIDF N PROCIDT N %TAB N %READ N VFMQ
	;
	S %TAB("PROCIDF")="/DES=From Procedure Name/LE=12/TYP=U/TBL=[DBTBL25]PROCID"
	S %TAB("PROCIDT")="/DES=To Procedure Name/LE=12/TYP=U/TBL=[DBTBL25]PROCID:NOVAL/XPP=D PP^DBSPROC"
	S %READ="@@%FN,,PROCIDF/REQ,PROCIDT/REQ,"
	S %FRAME=2
	;
	D ^UTLREAD
	;
	Q:VFMQ="Q" 
	;
	N dbtbl25f S dbtbl25f=$$vDb3("SYSDEV",PROCIDF)
	N dbtbl25t S dbtbl25t=$$vReCp1(dbtbl25f) ; Copy header
	;
	S vobj(dbtbl25t,-4)=PROCIDT
	S $P(vobj(dbtbl25t),$C(124),2)="" ; Remove Old name
	S vobj(dbtbl25t,-2)=0
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBTBL25F(dbtbl25t,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(dbtbl25t,-100) S vobj(dbtbl25t,-2)=1 Tcommit:vTp  
	;
	N ds,vos1,vos2,vos3 S ds=$$vOpen2()
	;
	; Copy detail
	F  Q:'($$vFetch2())  D
	.	N dfrom,vop1 S vop1=$P(ds,$C(9),3),dfrom=$G(^DBTBL($P(ds,$C(9),1),25,$P(ds,$C(9),2),vop1))
	.	S SEQ=vop1
	.	;
	.	N dto,vop2,vop3,vop4,vop5 S dto="",vop4="SYSDEV",vop3=PROCIDT,vop2=SEQ,vop5=0
	. S $P(dto,$C(12),1)=$P(dfrom,$C(12),1)
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^DBTBL(vop4,25,vop3,vop2)=dto S vop5=1 Tcommit:vTp  
	.	Q 
	;
	K vobj(+$G(dbtbl25f)),vobj(+$G(dbtbl25t)) Q 
	;
BUILDALL	; Build all procedure routines (called) by FILER.COM)
	;
	N rs,vos1,vos2 S rs=$$vOpen3()
	F  Q:'($$vFetch3())  D COMPILE(rs)
	;
	Q 
	;
BUILD	; Build run-time routine (Called by function DBSPROCB)
	;
	N CNT
	;
	 N V1 S V1=$J D vDbDe3()
	;
	S CNT=$$LIST^DBSGETID("DBTBL25") ; Select procedure ID(s)
	Q:(+CNT=0) 
	;
	N ds,vos1,vos2,vos3  N V2 S V2=$J S ds=$$vOpen4()
	F  Q:'($$vFetch4())  D
	.	N tmpdq,vop1 S vop1=$P(ds,$C(9),2),tmpdq=$G(^TEMP($P(ds,$C(9),1),vop1))
	.	D COMPILE(vop1)
	.	Q 
	;
	 N V3 S V3=$J D vDbDe4()
	;
	; "Press any key" message and pause
	WRITE $$MSG^%TRMVT("",,1)
	;
	Q 
	;
COMPILE(PROCID,PGM)	;
	;
	N LTD
	N count N FCOUNT N increm N SIZE
	N %LIBS N code N desc N line N m2src N q N SIG
	N TIME N TPGM N USER N vpgm N zvar N zpgm
	;
	S ER=0
	S RM=""
	S q=""""
	S count=0
	S line=""
	S $piece(line,"-",70)=""
	S line=" ;"_line
	;
	S %LIBS="SYSDEV"
	;
	; Invalid Procedure name
	I '$$vDbEx2() D  Q 
	.	S ER=1
	.	S RM=$$^MSG(1408,PROCID)
	.	Q 
	;
	WRITE !,PROCID,?15
	;
	N dbtbl25 S dbtbl25=$$vDb6(%LIBS,PROCID)
	N dbtbl25d S dbtbl25d=$$vDb7(%LIBS,PROCID,1)
	;
	I ($P(dbtbl25,$C(124),2)="") D  Q 
	.	S RM=$$^MSG(3056,PROCID)
	.	WRITE $$MSG^%TRMVT(RM)
	.	HANG 2
	.	Q 
	;
	S desc=$P(dbtbl25,$C(124),1) ; Description
	S PGM=$P(dbtbl25,$C(124),2) ; Routine name
	S vpgm=""
	S zpgm=""
	;
	N ds,vos1,vos2,vos3 S ds=$$vOpen5()
	I $$vFetch5() D
	.	N d25d S d25d=$G(^DBTBL($P(ds,$C(9),1),25,$P(ds,$C(9),2),$P(ds,$C(9),3)))
	.	S vpgm=$P(d25d,$C(12),1) ; First line
	.	Q 
	;
	S TPGM=PGM ; Parameter defined?
	;
	I $E(vpgm,1,$L(PGM))=PGM D  ; Use user-defined tag
	.	S TPGM=vpgm
	.	Q 
	E  D
	.	I $$vStrUC($E(vpgm,1,6))="PUBLIC",$E(vpgm,8,7+$L(PGM))=PGM D
	..		S TPGM=vpgm
	..		Q 
	.	E  D
	..		I $$vStrUC($E(vpgm,1,7))="PRIVATE",$E(vpgm,9,8+$L(PGM))=PGM D
	...			S TPGM=vpgm
	...			Q 
	..		E  D
	...			S TPGM=TPGM_$char(9)_vpgm
	...			Q 
	..		Q 
	.	Q 
	;
	D add(TPGM,.count)
	;
	D SYSVAR^SCADRV0()
	;
	; Gather signature data
	S LTD=$P(dbtbl25,$C(124),3) ; Date last modified
	S TIME=$P(dbtbl25,$C(124),5) ; Time last updated
	S USER=$P(dbtbl25,$C(124),4) ; User who last modified
	S SIZE=0
	;
	F  Q:'($$vFetch5())  D
	.	N d25d,vop1 S vop1=$P(ds,$C(9),3),d25d=$G(^DBTBL($P(ds,$C(9),1),25,$P(ds,$C(9),2),vop1))
	.	S FCOUNT=vop1+count
	.	S m2src(FCOUNT)=$P(d25d,$C(12),1)
	.	S SIZE=SIZE+$L($P(d25d,$C(12),1))
	.	Q 
	;
	; Add signature tag
	S SIG=LTD_"^"_TIME_"^"_USER_"^"_SIZE
	S m2src(FCOUNT+1)=""
	S m2src(FCOUNT+2)="vSIG()"_$char(9)_"quit """_SIG_""""_$char(9)_"// Signature - LTD^TIME^USER^SIZE"
	;
	; Check for ^MPLUSTAG to be added
	; I $D(^MPLUSTAG)
	;
	; do MARKER^UCUTIL(.m2src) // add PSL marker for line  coverage check
	;
	D cmpA2F^UCGM(.m2src,$translate(PGM,"%","_"),,,,,,PROCID_"~Procedure~"_SIG)
	;
	Q 
	;
add(data,count)	; Insert procedural code into buffer
	;
	S count=count+1
	S m2src(count)=data
	;
	Q 
	;
ERR	;
	;
	WRITE !,RM
	HANG 2
	Q 
	;
vSIG()	;
	Q "60606^33920^Frans S.C. Witte^9252" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM DBTBL25D WHERE %LIBS='SYSDEV' AND PROCID=:PROCID
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen6()
	F  Q:'($$vFetch6())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^DBTBL(v1,25,v2,v3)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe2()	; DELETE FROM DBTBL25D WHERE %LIBS='SYSDEV' AND PROCID=:PROCID
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen7()
	F  Q:'($$vFetch7())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^DBTBL(v1,25,v2,v3)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe3()	; DELETE FROM TMPDQ WHERE PID=:V1
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen8()
	F  Q:'($$vFetch8())  D
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
vDbDe4()	; DELETE FROM TMPDQ WHERE PID=:V3
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen9()
	F  Q:'($$vFetch9())  D
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
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
	;
vDb2(v1,v2)	;	vobj()=Db.getRecord(DBTBL25,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL25"
	S vobj(vOid)=$G(^DBTBL(v1,25,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,25,v2))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDb3(v1,v2)	;	vobj()=Db.getRecord(DBTBL25,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL25"
	S vobj(vOid)=$G(^DBTBL(v1,25,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,25,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL25" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDb6(v1,v2)	;	voXN = Db.getRecord(DBTBL25,,0)
	;
	N dbtbl25
	S dbtbl25=$G(^DBTBL(v1,25,v2))
	I dbtbl25="",'$D(^DBTBL(v1,25,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL25" X $ZT
	Q dbtbl25
	;
vDb7(v1,v2,v3)	;	voXN = Db.getRecord(DBTBL25D,,0)
	;
	N dbtbl25d
	S dbtbl25d=$G(^DBTBL(v1,25,v2,v3))
	I dbtbl25d="",'$D(^DBTBL(v1,25,v2,v3))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL25D" X $ZT
	Q dbtbl25d
	;
vDbEx2()	;	min(1): DISTINCT %LIBS,PROCID FROM DBTBL25 WHERE %LIBS=:%LIBS AND PROCID=:PROCID
	;
	N vsql1
	S vsql1=$G(%LIBS) I vsql1="" Q 0
	;
	I '($D(^DBTBL(vsql1,25,PROCID))#2) Q 0
	Q 1
	;
vOpen1()	;	%LIBS,PROCID,SEQ FROM DBTBL25D WHERE %LIBS='SYSDEV' AND PROCID=:PROCID ORDER BY SEQ ASC
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(PROCID) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^DBTBL("SYSDEV",25,vos2,vos3),1) I vos3="" G vL1a0
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
	S ds="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen2()	;	%LIBS,PROCID,SEQ FROM DBTBL25D WHERE %LIBS='SYSDEV' AND PROCID=:PROCIDF ORDER BY SEQ ASC
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(PROCIDF) I vos2="" G vL2a0
	S vos3=""
vL2a3	S vos3=$O(^DBTBL("SYSDEV",25,vos2,vos3),1) I vos3="" G vL2a0
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
	S ds="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen3()	;	PROCID FROM DBTBL25 WHERE %LIBS='SYSDEV' ORDER BY PROCID ASC
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=""
vL3a2	S vos2=$O(^DBTBL("SYSDEV",25,vos2),1) I vos2="" G vL3a0
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
vOpen4()	;	PID,ELEMENT FROM TMPDQ WHERE PID=:V2 ORDER BY ELEMENT ASC
	;
	;
	S vos1=2
	D vL4a1
	Q ""
	;
vL4a0	S vos1=0 Q
vL4a1	S vos2=$G(V2) I vos2="" G vL4a0
	S vos3=""
vL4a3	S vos3=$O(^TEMP(vos2,vos3),1) I vos3="" G vL4a0
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
	S ds=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen5()	;	%LIBS,PROCID,SEQ FROM DBTBL25D WHERE %LIBS='SYSDEV' AND PROCID=:PROCID ORDER BY SEQ
	;
	;
	S vos1=2
	D vL5a1
	Q ""
	;
vL5a0	S vos1=0 Q
vL5a1	S vos2=$G(PROCID) I vos2="" G vL5a0
	S vos3=""
vL5a3	S vos3=$O(^DBTBL("SYSDEV",25,vos2,vos3),1) I vos3="" G vL5a0
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
	S ds="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen6()	;	%LIBS,PROCID,SEQ FROM DBTBL25D WHERE %LIBS='SYSDEV' AND PROCID=:PROCID
	;
	;
	S vos1=2
	D vL6a1
	Q ""
	;
vL6a0	S vos1=0 Q
vL6a1	S vos2=$G(PROCID) I vos2="" G vL6a0
	S vos3=""
vL6a3	S vos3=$O(^DBTBL("SYSDEV",25,vos2,vos3),1) I vos3="" G vL6a0
	Q
	;
vFetch6()	;
	;
	;
	I vos1=1 D vL6a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen7()	;	%LIBS,PROCID,SEQ FROM DBTBL25D WHERE %LIBS='SYSDEV' AND PROCID=:PROCID
	;
	;
	S vos1=2
	D vL7a1
	Q ""
	;
vL7a0	S vos1=0 Q
vL7a1	S vos2=$G(PROCID) I vos2="" G vL7a0
	S vos3=""
vL7a3	S vos3=$O(^DBTBL("SYSDEV",25,vos2,vos3),1) I vos3="" G vL7a0
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
	S vRs="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen8()	;	PID,ELEMENT FROM TMPDQ WHERE PID=:V1
	;
	;
	S vos1=2
	D vL8a1
	Q ""
	;
vL8a0	S vos1=0 Q
vL8a1	S vos2=$G(V1) I vos2="" G vL8a0
	S vos3=""
vL8a3	S vos3=$O(^TEMP(vos2,vos3),1) I vos3="" G vL8a0
	Q
	;
vFetch8()	;
	;
	;
	I vos1=1 D vL8a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen9()	;	PID,ELEMENT FROM TMPDQ WHERE PID=:V3
	;
	;
	S vos1=2
	D vL9a1
	Q ""
	;
vL9a0	S vos1=0 Q
vL9a1	S vos2=$G(V3) I vos2="" G vL9a0
	S vos3=""
vL9a3	S vos3=$O(^TEMP(vos2,vos3),1) I vos3="" G vL9a0
	Q
	;
vFetch9()	;
	;
	;
	I vos1=1 D vL9a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vReCp1(v1)	;	RecordDBTBL25.copy: DBTBL25
	;
	Q $$copy^UCGMR(dbtbl25f)
