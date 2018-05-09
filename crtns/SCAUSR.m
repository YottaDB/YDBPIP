SCAUSR	; Set up new Employee/User
	;
	; **** Routine compiled from DATA-QWIK Procedure SCAUSR ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	;
	Q 
	;
NEW	; User Creation
	;
	D INIT(0)
	Q 
	;
UPD	; User Modification
	;
	D INIT(1)
	Q 
	;
INQ	; User Inquiry
	;
	D INIT(2)
	Q 
	;
DEL	; User Deletion
	;
	; Function disabled
	D SETERR^DBSEXECU("SCAU","MSG","1129") Q:ER 
	;
	Q 
	;
INIT(%O)	;
	;
	N CIFNAM N IO N RELCIF N UID N VFMQ
	;
	D QUERY
	;
	I VFMQ="Q" Q 
	;
	N scau
	;
	D SCREEN(.scau)
	;
	D VER(.scau)
	;
	K vobj(+$G(scau)) Q 
	;
QUERY	; Query for User ID
	;
	N %READ N %TAB
	;
	S %TAB("UID")=".UID1/HLP=[SCAU]UID/XPP=D PPUID^SCAUSR"
	I %O S %TAB("UID")=%TAB("UID")_"/TBL=[SCAU]"
	;
	S %READ="@@%FN,,,UID/REQ"
	;
	I %O=2 D
	.	S %TAB("IO")=$$IO^SCATAB($I)
	.	S %READ=%READ_",IO"
	.	Q 
	;
	D ^UTLREAD
	;
	Q 
	;
PPUID	; User ID Post-Processor
	;
	I (X="") Q 
	I %OSAVE Q 
	;
	S X=$$vStrUC(X)
	;
	; Record already on file
	I ($D(^SCAU(1,X))#2) D SETERR^DBSEXECU("SCAU","ER","RECOF") Q:ER 
	;
	Q 
	;
SCREEN(fSCAU)	; Call screen driver
	;
	N %MODS N %REPEAT
	;
	S %MODS=1
	S %REPEAT=16
	;
	K vobj(+$G(fSCAU)) S fSCAU=$$vDb1(UID)
	;
	I %O D LOADRA
	I %O=2,IO'=$I D OPEN^SCAIO Q:ER 
	;
	N vo1 N vo2 N vo3 N vo4 D DRV^USID(%O,"SCAUSR1",.fSCAU,.vo1,.vo2,.vo3,.vo4) K vobj(+$G(vo1)) K vobj(+$G(vo2)) K vobj(+$G(vo3)) K vobj(+$G(vo4))
	;
	Q 
	;
LOADRA	; Load related account customer #'s and names
	;
	N I
	;
	S I=1
	;
	N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen1()
	F  Q:'($$vFetch1())  D  Q:I>16 
	.	S RELCIF(I)=$P(rs,$C(9),1)
	.	S CIFNAM(I)=$P(rs,$C(9),2)
	.	S I=I+1
	.	Q 
	;
	Q 
	;
VER(scau)	; Verify screen status and file
	;
	I %O=2!(%O=4)!(VFMQ="Q") D END Q 
	;
	D FILE(.scau)
	;
	D END
	;
	Q 
	;
FILE(scau)	; File data
	;
	N RECIF
	;
	I (%O=0)!(%O=1) N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^SCAUFILE(scau,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(scau,-100) S vobj(scau,-2)=1 Tcommit:vTp  
	;
	I ER Q 
	;
	; Delete any existing SCAUR1 entries
	D vDbDe1()
	;
	S RECIF=""
	; Add SCAUR1 entries from the screen
	F  S RECIF=$order(RELCIF(RECIF)) Q:(RECIF="")  D
	.	;
	.	I (RELCIF(RECIF)="") Q 
	.	;
	.	N scaur1,vop1,vop2,vop3 S scaur1="",vop2="",vop1="",vop3=0
	. S vop2=UID
	. S vop1=RELCIF(RECIF)
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^SCAU(1,vop2,vop1)=$$RTBAR^%ZFUNC(scaur1) S vop3=1 Tcommit:vTp  
	.	Q 
	;
	Q 
	;
END	; End of processing
	;
	I ER!(%O=2)!(%O=4) Q 
	;
	I VFMQ="Q" D
	.	; User ~p1 not created
	.	I %O=0 S RM=$$^MSG(2873,UID)
	.	;
	.	; User ~p1 not modified
	.	E  I %O=1 S RM=$$^MSG(2875,UID)
	.	Q 
	E  D
	.	; User ~p1 created
	.	I %O=0 S RM=$$^MSG(2868,UID) Q 
	.	;
	.	; User ~p1 modified
	.	E  I %O=1 S RM=$$^MSG(2872,UID) Q 
	.	Q 
	;
	S ER="W"
	;
	Q 
	;
RESET	; Reset user's manual revoke status
	;
	N %READ N %TAB N UID N VFMQ
	;
	S %TAB("UID")=".UID1/HLP=[SCAU]UID/TBL=[SCAU]"
	S %READ="@@%FN,,,UID/REQ"
	;
	D ^UTLREAD
	;
	I VFMQ="Q" Q 
	;
	N scau S scau=$$vDb2(UID)
	;
	; Only save the SCAU record STATUS isn't already ACTIVE
	I $$STATUS^SCAUCDI($P(vobj(scau),$C(124),5),$P(vobj(scau),$C(124),8),$P(vobj(scau),$C(124),44),$P(vobj(scau),$C(124),43))'=1 D
	.	;
	. S $P(vobj(scau),$C(124),43)=0
	. S $P(vobj(scau),$C(124),8)=$P($H,",",1)
	. S $P(vobj(scau),$C(124),44)=0
	. S $P(vobj(scau),$C(124),45)=""
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^SCAUFILE(scau,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(scau,-100) S vobj(scau,-2)=1 Tcommit:vTp  
	.	Q 
	;
	; User ~p1 not modified
	I ER S RM=$$^MSG(2875,UID) K vobj(+$G(scau)) Q 
	;
	; User ~p1 modified
	E  S RM=$$^MSG(2872,UID)
	;
	S ER="W"
	;
	K vobj(+$G(scau)) Q 
	;
vSIG()	;
	Q "60604^26252^SSethy^4045" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM SCAUR1 WHERE UID=:UID
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen2()
	F  Q:'($$vFetch2())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^SCAU(1,v1,v2)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	;
vDb1(v1)	;	vobj()=Db.getRecord(SCAU,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSCAU"
	S vobj(vOid)=$G(^SCAU(1,v1))
	I vobj(vOid)="",'$D(^SCAU(1,v1))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	Q vOid
	;
vDb2(v1)	;	vobj()=Db.getRecord(SCAU,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSCAU"
	S vobj(vOid)=$G(^SCAU(1,v1))
	I vobj(vOid)="",'$D(^SCAU(1,v1))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,SCAU" X $ZT
	S vobj(vOid,-3)=v1
	Q vOid
	;
vOpen1()	;	SCAUR1.RECIF,CIF.NAM FROM SCAUR1,CIF WHERE CIF.ACN=SCAUR1.RECIF AND SCAUR1.UID=:UID
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(UID) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^SCAU(1,vos2,vos3),1) I vos3="" G vL1a0
	I '($D(^CIF(vos3,1))) G vL1a3
	Q
	;
vFetch1()	;
	;
	I vos1=1 D vL1a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos4=$G(^CIF(vos3,1))
	S rs=$S(vos3=$C(254):"",1:vos3)_$C(9)_$P(vos4,"|",1)
	;
	Q 1
	;
vOpen2()	;	UID,RECIF FROM SCAUR1 WHERE UID=:UID
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(UID) I vos2="" G vL2a0
	S vos3=""
vL2a3	S vos3=$O(^SCAU(1,vos2,vos3),1) I vos3="" G vL2a0
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
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
