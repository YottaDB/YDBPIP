FORMI18N(topy,phrtyp,fldval1,fldval2,mldfv2)	; FORMI18N
	;
	; **** Routine compiled from DATA-QWIK Procedure FORMI18N ****
	;
	; 08/30/2007 13:48 - joynerd
	;
	;
	D START
	;
	Q 
	;
START	;
	;
	N savDEL N status
	N EXTANT N ORIGIN N vtblrtn
	;
	; Have to save it and use later
	S savDEL=$get(DELETE)
	;
	; Don't init again if called by OOE
	I (($get(I18NOOE))="") D FRMINIT
	;
	S vtblrtn="N X D VW^FORMI18N" S status=$get(STATUS)
	;
	S topy=$get(topy)
	I topy="" S topy=1
	S ORIGIN=topy_";"_LFTMAR S EXTANT=5_";"_(RHTMAR-LFTMAR-1)
	;
	D MAIN
	;
	Q 
	;
MAIN	; Run main part of program
	;
	D VRUN
	D FINISH
	;
	Q 
	;
FINISH	;
	;
	; Restore DELETE again
	S DELETE=savDEL
	;
	; Clean up the frame
	I ((($get(I18NOOE))="")),('%i18nmtra) D VREPRNT^@PGM
	;
	Q 
	;
VRUN	; Main part control
	;
	N px N py N %MAX N %PG N %PAGE
	N DATA N VO N %fkey N %TAB N zbterm
	;
	; Clear Region for OBJECT definition
	D CLRRGN^FORMFUN
	;
	; Remove status line
	I status D OFF^FORMSTAT
	;
	D SCRNPRE
	;
	D VBX D VPR D VDA D ^DBSPNT() D VTAB
	;
	Q 
	;
VPR	; Build the prompts
	;
	S VO="1||13"
	S VO(0)="0;0|"_vWID
	S VO(1)=$char(topy)_$char(17)_$char(46)_$char(2)_$char(0)_$char(0)_$char(0)_$char(0)_$char(0)_$char(0)_"01T  Master Language Dictionary Translation Utility  "
	;
	Q 
	;
VDA	; Build screen data
	;
	S fldval2=$get(fldval2)
	;
	S VO="5|2|13"
	S VO(2)=$char((topy+1))_$char(5)_$char(20)_$char(2)_$char(0)_$char(0)_$char(0)_$char(0)_$char(0)_$char(0)_"01T"_$E(($get(flddes1)),1,20)
	S VO(3)=$char((topy+2))_$char(vSTART)_$char(vINP)_$char(2)_$char(0)_$char(0)_$char(0)_$char(0)_$char(0)_$char(0)_"01T"_$E(($get(fldval1)),1,vINP)
	S VO(4)=$char((topy+3))_$char(5)_$char(20)_$char(2)_$char(0)_$char(0)_$char(0)_$char(0)_$char(0)_$char(0)_"01T"_$E(($get(flddes2)),1,20)
	S VO(5)=$char((topy+4))_$char(vSTART)_$char(vINP)_$char(2)_$char(0)_$char(0)_$char(0)_$char(0)_$char(0)_$char(0)_"00T"_$E(($get(fldval2)),1,vINP)
	;
	Q 
	;
VTAB	; Build the %TAB(array)
	;
	N OLNTB N REQ N VPB N VPT
	N DFID N DLIB N PGM
	;
	S %MAX=4 S VPT=1 S VPB=7 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="I18NMLD" S REQ=1
	S OLNTB=24001
	;
	D VTAB1
	;
	Q 
	;
VTAB1	;
	;
	D VTBL
	;
	D ^DBSCRT8
	I (status),('(($get(I18NOOE))="")) D ON^FORMSTAT
	S ZB=13
	;
	Q 
	;
VTBL	; Create %TAB(array)
	;
	; 1 2 3  4 5   6   7-9 10-11
	; DY,DX,SZ PT REQ TYPE DEL POS |NODE|ITEM NAME|TBL|FMT|PP|PRE|MIN|MAX|DEC
	;
	S %TAB(1)=$char((topy+0))_$char(4)_$char(20)_"20T|*flddes1|[*]@flddes1"
	S %TAB(2)=$char((topy+1))_$char(vSTART)_$char(vINP)_"20T|*fldval1|[*]@fldval1"
	S %TAB(3)=$char((topy+2))_$char(4)_$char(20)_"20T|*flddes2|[*]@flddes2"
	S %TAB(4)=$char((topy+3))_$char((vSTART-1))_$char(vINP)_"00T|*fldval2|[*]@fldval2|||D VP2^FORMI18N|D VP1^FORMI18N"
	;
	Q 
	;
SCRNPRE	; Screen Pre-Processor
	;
	I (phrtyp=11),(fldval2="") S fldval2=fldval1
	S vWID=1 S vINP=132 S vSTART=1
	I $L(fldval1)<80 S vINP=80
	I $L(fldval1)<70 S vINP=70 S vWID=0 S vSTART=7
	;
	Q 
	;
VSPP	; Screen Post-Processor
	;
	I ($D(phrtab(fldval2))#2) S %O=2
	;
	Q 
	;
VDEPRE	; Data Entry Pre-proc
	;
	D VPOS
	;
	Q 
	;
VPOS	; User defined post processor's
	;
	D VP1
	;
	Q 
	;
VP1	; Preproc for fldval2
	;
	I 'maxphr D CHANGE^DBSMACRO("TBL","")
	E  D CHANGE^DBSMACRO("TBL","phrtab(")
	;
	Q 
	;
VP2	; Postproc for fldval2
	;
	N i
	;
	I 'srcphr Q 
	;
	; Locking if admin set the flag
	I $get(uclflgMLD) D  Q 
	.	S RM=$$^MSG(5914)
	.	Q 
	E  D CHANGE^DBSMACRO("TBL","")
	;
	S mldfv2=X
	;
	I phrtyp=2 D
	.	N bwd N done N fwd
	.	;
	.	; translator did the work (or no space)
	.	I mldfv2["@"!(mldfv2'[" ") Q 
	.	; start at middle of message
	.	S (fwd,bwd)=$L(mldfv2)\2
	.	S done=0
	.	F  Q:done  D
	..		; found space going fwd
	..		I $E(mldfv2,fwd)=" " S done=fwd
	..		; move pointers
	..		S fwd=fwd+1 S bwd=bwd-1
	..		; found space going backwd
	..		I bwd>0,$E(mldfv2,bwd)=" " S done=bwd
	..		I done S mldfv2=$E(mldfv2,1,done-1)_"@"_$E(mldfv2,done+1,999)
	..		Q 
	.	Q 
	;
	; Phrase type 3 Screen or Report prompts with :
	I phrtyp=3 D  Q:ER 
	.	I ($E(X,$L(X))'=":") D SETERR^DBSEXECU("I18NMLD","MSG",5915) Q 
	.	S mldfv2=$translate(X,":","")
	.	Q 
	;
	; Special Handeling for Phrase type 6 = ^STBLPROMPT
	I phrtyp=6 D
	.	N e
	.	;
	.	; Must have the same number of variables as original phrase
	.	I $L(fldval1,"~")'=$L(X,"~") D SETERR^DBSEXECU("I18NMLD","MSG",5916) Q 
	.	F i=2:1:$L(X,"~") D
	..		I $E(($piece(X,"~",i)),1,2)'?1A1N D SETERR^DBSEXECU("I18NMLD","MSG",5916) Q 
	..		S e(i-1)="~"_$E(($piece(X,"~",i)),1,2)
	..		Q 
	.	F i=1:1:9 D
	..		I '($D(e(i))#2) Q 
	..		I $$vStrUC(fldval1)'[$$vStrUC(e(i)) S i=10 D SETERR^DBSEXECU("I18NMLD","MSG",5916) Q 
	..		Q 
	.	Q 
	;
	; Phrase type 11 - Mixed text and <<functions>>
	I phrtyp=11 D
	.	N edit
	.	S edit=$$CHECK(fldval1,X)
	.	I edit=0 D SETERR^DBSEXECU("I18NMLD","MSG",5917)
	.	Q 
	;
	Q 
	;
CHECK(src,trg)	; Routine called by post processor to edit ptype 11
	; making sure that source <<>> appears in target
	;
	N same
	N nte
	;
	D getnte(src,1)
	D getnte(trg,2)
	S same=1 S nte=""
	;
	N rs,vos1,vos2,vos3  N V1 S V1=$J S rs=$$vOpen1()
	F  Q:'($$vFetch1())  D
	.	I same=0 Q 
	.	S nte=rs
	.	N tmprpt2,vop1 S tmprpt2=$$vDb2($J,2,nte,.vop1)
	.	I '$G(vop1) S same=0
	.	 N V2,V3 S V2=$J,V3=nte ZWI ^TMP(V2,2,V3)
	.	Q 
	;
	N rs1,vos4,vos5,vos6  N V2 S V2=$J S rs1=$$vOpen2()
	I (same),(''$G(vos4)) S same=0
	;
	Q same
	;
getnte(p,x)	;
	;
	N i
	N nte
	;
	 N V1,V2 S V1=$j,V2=x D vDbDe1()
	;
	F i=2:1:$L(p,"<<") D
	.	S nte=$piece(($piece(p,"<<",i)),">>")
	.	N tmprpt2,vop1,vop2,vop3,vop4 S vop3=$J,vop2=x,vop1=nte,tmprpt2=$$vDb2($J,x,nte,.vop4)
	. S $P(tmprpt2,$C(126),1)=""
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^TMP(vop3,vop2,vop1)=tmprpt2 S vop4=1 Tcommit:vTp  
	.	Q 
	;
	Q 
	;
FRMINIT	; Initialise global var's used by ^FORMxxx procedures
	;
	N KBI
	N BEL N fileflag N GLDKEY N JRNL N N N NUL N TAB N zbtxt
	;
	I $get(ST8)="" S ST8="||2||||||32|1;0;2||1"
	E  S $piece(ST8,"|",12)=0
	;
	D
	.	I $get(%UID)="" S %UID=1 S %UCLS="SCA"
	.	;
	.	I '($D(YLIMIT)#2) S YLIMIT=255
	.	I '($D(XLIMIT)#2) S XLIMIT=255
	.	;
	.	S LFTMAR=1 S TOPMAR=1
	.	S BOTMAR=23 S RHTMAR=80
	.	;
	.	S zbtxt="x"
	.	;
	.	S N="" S fileflag="" S GLDKEY="" S JRNL=""
	.	S NUL=$char(0) S BEL=$char(7) S TAB=$char(9) S KBI=0
	.	;
	.	S DELETE=127
	.	S TIMEOUT=60
	.	;
	.	D VIDINIT^FORMINIT
	.	D TRMSET^FORMINIT
	.	Q 
	;
	D REST8^FORMINIT D ST8^FORMINIT
	;
	; Save screen attributes
	S DBTBL2(-5)=ST8
	;
	Q 
	;
VBX	;
	;
	D BOX^%TRMVT(ORIGIN,EXTANT)
	;
	Q 
	;
VW	;
	;
	D PUTRGN^FORMFUN(ORIGIN,EXTANT)
	D VREPRNT
	;
	Q 
	;
VREPRNT	;
	;
	D VBX D VPR D VDA D ^DBSPNT()
	;
	Q 
	;  #OPTION ResultClass ON
vSIG()	;
	Q "60472^36846^Dan Russell^8878" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM TMPRPT2 WHERE PID=:V1 AND KEY1=:V2
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4 S vRs=$$vOpen3()
	F  Q:'($$vFetch3())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^TMP(v1,v2,v3)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	;
vDb2(v1,v2,v3,v2out)	;	voXN = Db.getRecord(TMPRPT2,,1,-2)
	;
	N tmprpt2
	S tmprpt2=$G(^TMP(v1,v2,v3))
	I tmprpt2="",'$D(^TMP(v1,v2,v3))
	S v2out='$T
	;
	Q tmprpt2
	;
vOpen1()	;	KEY2 FROM TMPRPT2 WHERE PID=:V1 AND KEY1=1
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(V1) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^TMP(vos2,1,vos3),1) I vos3="" G vL1a0
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
	S rs=$S(vos3=$$BYTECHAR^SQLUTL(254):"",1:vos3)
	;
	Q 1
	;
vOpen2()	;	KEY2 FROM TMPRPT2 WHERE PID=:V2 AND KEY1=2
	;
	;
	S vos4=2
	D vL2a1
	Q ""
	;
vL2a0	S vos4=0 Q
vL2a1	S vos5=$G(V2) I vos5="" G vL2a0
	S vos6=""
vL2a3	S vos6=$O(^TMP(vos5,2,vos6),1) I vos6="" G vL2a0
	Q
	;
vFetch2()	;
	;
	;
	I vos4=1 D vL2a3
	I vos4=2 S vos4=1
	;
	I vos4=0 Q 0
	;
	S rs1=$S(vos6=$$BYTECHAR^SQLUTL(254):"",1:vos6)
	;
	Q 1
	;
vOpen3()	;	PID,KEY1,KEY2 FROM TMPRPT2 WHERE PID=:V1 AND KEY1=:V2
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(V1) I vos2="" G vL3a0
	S vos3=$G(V2) I vos3="" G vL3a0
	S vos4=""
vL3a4	S vos4=$O(^TMP(vos2,vos3,vos4),1) I vos4="" G vL3a0
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
	S vRs=vos2_$C(9)_vos3_$C(9)_$S(vos4=$$BYTECHAR^SQLUTL(254):"",1:vos4)
	;
	Q 1
