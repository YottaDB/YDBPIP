DBSCDI	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSCDI ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	Q 
	;
DIDESC(FID,DI)	; DATA-QWIK data item description
	N desc
	S desc=$$vvRow1()
	Q desc
	;
FLDESC(FID)	; DATA-QWIK File description
	N desc
	S desc=$$vvRow2()
	Q desc
	;
OBJDESC(LEV,NAME)	; DATA-QWIK object description
	N desc
	S desc=$$vvRow3()
	Q desc
	;
LEVDESC(LEV)	; DATA-QWIK level description
	N desc
	S desc=$$vvRow4()
	Q desc
	;
PROTPGM(FID)	; Data item protection run-time routine
	N rtn
	S rtn=$$vvRow5()
	I rtn="" Q ""
	Q "VP01"_rtn
	;
REQFLD(FID)	; Required data items for a DQ file
	N list
	S FID=$piece(FID,",",1) ; Primary file
	S list=$$vvRow6()
	Q list
	;
EXPDESC(EXPID)	; Export file Description
	N desc
	S desc=$$vvRow7()
	Q desc
	;
DOMDESC(SYSSN,DOM)	; Domain description
	N desc
	S desc=$$vvRow8()
	Q desc
	;
DOMTYPE(SYSSN,DOM)	; Domain format type
	N type
	S type=$$vvRow9()
	Q type
	;
DOMLEN(SYSSN,DOM)	; Domain field length
	N len
	S len=$$vvRow10()
	Q len
	;
VALPGM(pgm)	; Validate routine name syntax and also not in MRTNS directory
	I pgm="" Q 0
	I pgm'?1A.AN S RM=$$^MSG(1454) Q 1 ; Invalid format
	I $L(pgm)>8 S RM=$$^MSG(1454) Q 1 ; Invalid format
	;
	; Check duplicate name in MRTNS directory
	;
	N %ZI,%ZR
	S %ZI(pgm)="" D INT^%RSEL ; Search routine name
	; Duplicate name in MRTNS
	I $$vStrUC(($get(%ZR(pgm))))["MRTNS" S RM=$$^MSG(871)_""_%ZR(pgm)_pgm_".m" Q 1
	; Duplicate name in CRTNS
	I $$vStrUC(($get(%ZR(pgm))))["CRTNS" S RM=$$^MSG(871)_""_%ZR(pgm)_pgm_".m" Q 1
	Q 0
	;
vSIG()	;
	Q "59495^75511^Lik Kwan^4784" ; Signature - LTD^TIME^USER^SIZE
	;  #OPTION ResultClass 0
vvRow1()	;
	N getRow S getRow=$G(^DBTBL("SYSDEV",1,FID,9,DI))
	N data S data=""
	S data=data_$char(9)_$P(getRow,$C(124),10)
	Q $E(data,2,1048575)
	;  #OPTION ResultClass 0
vvRow2()	;
	N getRow S getRow=$G(^DBTBL("SYSDEV",1,FID))
	N data S data=""
	S data=data_$char(9)_$P(getRow,$C(124),1)
	Q $E(data,2,1048575)
	;  #OPTION ResultClass 0
vvRow3()	;
	N getRow S getRow=$G(^DBTBL("SYSDEV",LEV,NAME))
	N data S data=""
	S data=data_$char(9)_$P(getRow,$C(124),1)
	Q $E(data,2,1048575)
	;  #OPTION ResultClass 0
vvRow4()	;
	N getRow S getRow=$G(^DBCTL("SYS","DBOPT",LEV))
	N data S data=""
	S data=data_$char(9)_$P(getRow,$C(124),1)
	Q $E(data,2,1048575)
	;  #OPTION ResultClass 0
vvRow5()	;
	N getRow,vop1,vop2,vop3 S vop1="SYSDEV",vop2=FID,getRow=$$vDb7("SYSDEV",FID)
	 S vop3=$G(^DBTBL(vop1,1,vop2,99))
	N data S data=""
	S data=data_$char(9)_$P(vop3,$C(124),3)
	Q $E(data,2,1048575)
	;  #OPTION ResultClass 0
vvRow6()	;
	N getRow,vop1,vop2,vop3 S vop1="SYSDEV",vop2=FID,getRow=$$vDb7("SYSDEV",FID)
	 S vop3=$G(^DBTBL(vop1,1,vop2,102))
	N data S data=""
	S data=data_$char(9)_$P(vop3,$C(124),1)
	Q $E(data,2,1048575)
	;  #OPTION ResultClass 0
vvRow7()	;
	N getRow S getRow=$G(^DBTBL("SYSDEV",17,EXPID))
	N data S data=""
	S data=data_$char(9)_$P(getRow,$C(124),1)
	Q $E(data,2,1048575)
	;  #OPTION ResultClass 0
vvRow8()	;
	N getRow,vop1,vop2 S vop1=SYSSN,vop2=DOM,getRow=$$vDb8(SYSSN,DOM)
	 S getRow=$G(^DBCTL("SYS","DOM",vop1,vop2,0))
	N data S data=""
	S data=data_$char(9)_$P(getRow,$C(124),1)
	Q $E(data,2,1048575)
	;  #OPTION ResultClass 0
vvRow9()	;
	N getRow,vop1,vop2 S vop1=SYSSN,vop2=DOM,getRow=$$vDb8(SYSSN,DOM)
	 S getRow=$G(^DBCTL("SYS","DOM",vop1,vop2,0))
	N data S data=""
	S data=data_$char(9)_$P(getRow,$C(124),2)
	Q $E(data,2,1048575)
	;  #OPTION ResultClass 0
vvRow10()	;
	N getRow,vop1,vop2 S vop1=SYSSN,vop2=DOM,getRow=$$vDb8(SYSSN,DOM)
	 S getRow=$G(^DBCTL("SYS","DOM",vop1,vop2,0))
	N data S data=""
	S data=data_$char(9)_$P(getRow,$C(124),3)
	Q $E(data,2,1048575)
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
	;
vDb7(v1,v2)	;	voXN = Db.getRecord(DBTBL1,,1)
	;
	N getRow
	S getRow=$G(^DBTBL(v1,1,v2))
	I getRow="",'$D(^DBTBL(v1,1,v2))
	;
	Q getRow
	;
vDb8(v1,v2)	;	voXN = Db.getRecord(DBSDOM,,1)
	;
	I '$D(^DBCTL("SYS","DOM",v1,v2))
	;
	Q ""
