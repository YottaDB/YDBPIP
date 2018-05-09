SCADRV8	;
	;
	; **** Routine compiled from DATA-QWIK Procedure SCADRV8 ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	;
	Q 
	;
NEW	;
	S %O=0 D INIT Q 
	;
UPD	;
	S %O=1 D INIT Q 
	;
DEL	;
	S %O=3 D INIT Q 
	;
INIT	;
	;
	K OLNTB
	;
	S %TAB("MENU")=".MENU1/TBL=[SCAMENU0]/XPP=D PPMENU^SCADRV8"
	S %READ="@@%FN,,,MENU/REQ" S %NOPRMT="F"
	;
	D ^UTLREAD
	;
	; No changes made
	I VFMQ="Q"!'$D(MENU) S ER="W" S RM=$$^MSG(1905) Q 
	;
	D VPG1
	Q 
	;
VPG1	;
	;
	N HDG N HDG2
	;
	S (DESC,PROMPT)=""
	;
	; Menu Number ~p1
	S HDG=$$^MSG(5484,MENU) S HDG=$J("",(80-($L(HDG)))\2)_HDG
	;
	; Enter ~p1 function
	S %TAB("DESC")=".DESC2/XPP=if PROMPT="""" set PROMPT=$$^MSG(8370,X),RM=PROMPT_%_(NI+1)"
	S %TAB("PROMPT")=".PROMPT1"
	;
	N scamenu0,vop1 S scamenu0=$$vDb2(MENU,.vop1)
	I $G(vop1) S DESC=$P(scamenu0,$C(124),1) S PROMPT=$P(scamenu0,$C(124),2)
	;
	S DEL=0
	;
	S %READ="@@%FN,,,DESC/REQ,PROMPT/REQ"
	;
	; Description: ~p1
	I %O=3 S %TAB("DEL")=".DEL1" S HDG2=$$^MSG(8233,DESC) S %READ="@HDG,,@HDG2,DEL/REQ" S DEL=1 S %NOPRMT="F"
	D ^UTLREAD
	;
	I %O=3,'DEL S VFMQ="Q"
	;
	D VER
	Q 
	;
VER	;
	;
	I VFMQ="Q" D END Q 
	D FILE
	;
	I %O=0 D EXT^SCADRV5
	;
	D END
	Q 
	;
FILE	;
	;
	I %O=3 D vDbDe1() Q 
	;
	N scamenu0 S scamenu0=$$vDb1(MENU)
	S $P(vobj(scamenu0),$C(124),1)=DESC
	S $P(vobj(scamenu0),$C(124),2)=PROMPT
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(scamenu0) S vobj(scamenu0,-2)=1 Tcommit:vTp  
	K vobj(+$G(scamenu0)) Q 
	;
END	;
	;
	I VFMQ="Q" D
	.	;
	.	; Menu ~p1 not created
	.	I %O=0 S RM=$$^MSG(1711,MENU) Q 
	.	;
	.	; Menu ~p1 not modified
	.	I %O=1 S RM=$$^MSG(1713,MENU) Q 
	.	;
	.	; Menu ~p1 not deleted
	.	S RM=$$^MSG(1712,MENU)
	.	Q 
	;
	E  D
	.	;
	.	; Menu ~p1 created
	.	I %O=0 S RM=$$^MSG(1708,MENU) Q 
	.	;
	.	; Menu ~p1 modified
	.	I %O=1 S RM=$$^MSG(1710,MENU) Q 
	.	;
	.	; Menu ~p1 deleted
	.	S RM=$$^MSG(1709,MENU)
	.	Q 
	;
	S ER="W"
	Q 
	;
PPMENU	;
	N FMENU N M N N N SUBM
	;
	; MENU post processor
	I '%OSAVE S I(3)=""
	;
	N rs,vos1,vos2 S rs=$$vOpen1()
	;
	; Record already exists
	I '%OSAVE,'(X=""),''$G(vos1) S ER=1 S RM=$$^MSG(2327)
	;
	I %OSAVE'=3 Q 
	;
	N rs1,vos3,vos4,vos5 S rs1=$$vOpen2()
	;
	; Menu not empty
	I '(X=""),''$G(vos3) S ER=1 S RM=$$^MSG(1705) Q 
	;
	; Check other menus and sub-menus
	S (N,M)=""
	S ER=0
	;
	N rs2,vos6,vos7 S rs2=$$vOpen3()
	F  Q:'($$vFetch3())  D
	.	S N=rs2
	.	N rs3,vos8,vos9,vos10,vos11 S rs3=$$vOpen4()
	.	F  Q:'($$vFetch4())  D
	..		S M=$P(rs3,$C(9),1)
	..		S FMENU=$P(rs3,$C(9),2)
	..		I FMENU'=X Q 
	..		;
	..		; Menu is linked to menu #~p1
	..		S ER=1 S RM=$$^MSG(1704,N)
	..		Q 
	.	Q 
	Q:ER 
	;
	N rs4,vos12,vos13,vos14 S rs4=$$vOpen5()
	F  Q:'($$vFetch5())  D
	.	S N=rs4
	.	N rs5,vos15,vos16,vos17,vos18 S rs5=$$vOpen6()
	.	F  Q:'($$vFetch6())  D
	..		S M=$P(rs5,$C(9),1)
	..		S SUBM=$P(rs5,$C(9),2)
	..		I $translate(SUBM,"@")'=X Q 
	..		Q 
	.	Q 
	Q 
	;
vSIG()	;
	Q "60218^26329^Sanjay Chhrabria^3547" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM SCAMENU0 WHERE MENU=:MENU
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1
	Tstart (vobj):transactionid="CS"
	N vRec S vRec=$$vDbNew1("")
	S vobj(vRec,-2)=3
	N vRs,vos1,vos2 S vRs=$$vOpen7()
	F  Q:'($$vFetch7())  D
	.	S v1=vRs
	. S vobj(vRec,-3)=v1
	.	;     #ACCEPT CR=21101;DATE=2006-05-11;PGM=FSCW;GROUP=DEPRECATED
	.	D ^DBSLOGIT($G(vRec),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^SCATBL(0,v1)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	K vobj(+$G(vRec)) Q 
	;
vDb1(v1)	;	vobj()=Db.getRecord(SCAMENU0,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSCAMENU0"
	S vobj(vOid)=$G(^SCATBL(0,v1))
	I vobj(vOid)="",'$D(^SCATBL(0,v1))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	Q vOid
	;
vDb2(v1,v2out)	;	voXN = Db.getRecord(SCAMENU0,,1,-2)
	;
	N scamenu0
	S scamenu0=$G(^SCATBL(0,v1))
	I scamenu0="",'$D(^SCATBL(0,v1))
	S v2out='$T
	;
	Q scamenu0
	;
vDbNew1(v1)	;	vobj()=Class.new(SCAMENU0)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSCAMENU0",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	Q vOid
	;
vOpen1()	;	MENU FROM SCAMENU0 WHERE MENU=:X
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(X) I vos2="" G vL1a0
	I '($D(^SCATBL(0,vos2))#2) G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	;
	I vos1=0 Q 0
	;
	S vos1=100
	S rs=vos2
	S vos1=0
	;
	Q 1
	;
vOpen2()	;	SNUMB FROM SCAMENU WHERE MNUMB=:X
	;
	;
	S vos3=2
	D vL2a1
	Q ""
	;
vL2a0	S vos3=0 Q
vL2a1	S vos4=$G(X) I vos4="" G vL2a0
	S vos5=""
vL2a3	S vos5=$O(^SCATBL(0,vos4,vos5),1) I vos5="" G vL2a0
	Q
	;
vFetch2()	;
	;
	;
	I vos3=1 D vL2a3
	I vos3=2 S vos3=1
	;
	I vos3=0 Q 0
	;
	S rs1=$S(vos5=$C(254):"",1:vos5)
	;
	Q 1
	;
vOpen3()	;	MENU FROM SCAMENU0
	;
	;
	S vos6=2
	D vL3a1
	Q ""
	;
vL3a0	S vos6=0 Q
vL3a1	S vos7=""
vL3a2	S vos7=$O(^SCATBL(0,vos7),1) I vos7="" G vL3a0
	Q
	;
vFetch3()	;
	;
	;
	I vos6=1 D vL3a2
	I vos6=2 S vos6=1
	;
	I vos6=0 Q 0
	;
	S rs2=$S(vos7=$C(254):"",1:vos7)
	;
	Q 1
	;
vOpen4()	;	SNUMB,FUNMENU FROM SCAMENU WHERE MNUMB=:N
	;
	;
	S vos8=2
	D vL4a1
	Q ""
	;
vL4a0	S vos8=0 Q
vL4a1	S vos9=$G(N) I vos9="" G vL4a0
	S vos10=""
vL4a3	S vos10=$O(^SCATBL(0,vos9,vos10),1) I vos10="" G vL4a0
	Q
	;
vFetch4()	;
	;
	I vos8=1 D vL4a3
	I vos8=2 S vos8=1
	;
	I vos8=0 Q 0
	;
	S vos11=$G(^SCATBL(0,vos9,vos10))
	S rs3=$S(vos10=$C(254):"",1:vos10)_$C(9)_$P(vos11,"|",2)
	;
	Q 1
	;
vOpen5()	;	FN FROM SCATBL4
	;
	;
	S vos12=2
	D vL5a1
	Q ""
	;
vL5a0	S vos12=0 Q
vL5a1	S vos13=""
vL5a2	S vos13=$O(^SCATBL(4,vos13),1) I vos13="" G vL5a0
	S vos14=""
vL5a4	S vos14=$O(^SCATBL(4,vos13,vos14),1) I vos14="" G vL5a2
	Q
	;
vFetch5()	;
	;
	;
	I vos12=1 D vL5a4
	I vos12=2 S vos12=1
	;
	I vos12=0 Q 0
	;
	S rs4=$S(vos13=$C(254):"",1:vos13)
	;
	Q 1
	;
vOpen6()	;	SEQ,SUB FROM SCATBL4 WHERE FN=:N
	;
	;
	S vos15=2
	D vL6a1
	Q ""
	;
vL6a0	S vos15=0 Q
vL6a1	S vos16=$G(N) I vos16="" G vL6a0
	S vos17=""
vL6a3	S vos17=$O(^SCATBL(4,vos16,vos17),1) I vos17="" G vL6a0
	Q
	;
vFetch6()	;
	;
	I vos15=1 D vL6a3
	I vos15=2 S vos15=1
	;
	I vos15=0 Q 0
	;
	S vos18=$G(^SCATBL(4,vos16,vos17))
	S rs5=$S(vos17=$C(254):"",1:vos17)_$C(9)_$P(vos18,"|",2)
	;
	Q 1
	;
vOpen7()	;	MENU FROM SCAMENU0 WHERE MENU=:MENU
	;
	;
	S vos1=2
	D vL7a1
	Q ""
	;
vL7a0	S vos1=0 Q
vL7a1	S vos2=$G(MENU) I vos2="" G vL7a0
	I '($D(^SCATBL(0,vos2))#2) G vL7a0
	Q
	;
vFetch7()	;
	;
	;
	;
	I vos1=0 Q 0
	;
	S vos1=100
	S vRs=vos2
	S vos1=0
	;
	Q 1
	;
vReSav1(scamenu0)	;	RecordSCAMENU0 saveNoFiler(LOG)
	;
	D ^DBSLOGIT(scamenu0,vobj(scamenu0,-2))
	S ^SCATBL(0,vobj(scamenu0,-3))=$$RTBAR^%ZFUNC($G(vobj(scamenu0)))
	Q
