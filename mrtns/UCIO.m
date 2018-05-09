	; I18N=QUIT
	;
	; **** Routine compiled from DATA-QWIK Procedure UCIO ****
	;
	; 09/10/2007 17:31 - chenardp
	;
	; *******************************************************************
	; * IMPORTANT NOTE:                                                 *
	; * According to the rules that apply to PSL compiler upgrades,     *
	; * the generated M routine associated with this procedure must be  *
	; * checked into StarTeam and released with the procedure whenever  *
	; * changes are made to this procedure.                             *
	; *                                                                 *
	; * The M routine will be loaded to the mrtns directory during      *
	; * upgrades and will then be removed from that directory as part   *
	; * of the upgrade process.  Therefore, other than during an        *
	; * upgrade an mrtns version of this routine should not exist.      *
	; *                                                                 *
	; * Keep these comments as single line to ensure they exist in the  *
	; * generated M code.                                               *
	; *******************************************************************
	;  #OPTION ResultClass ON
	Q 
	;
	; ---------------------------------------------------------------------
close(vOid)	; Object
	N vIo S vIo=$P(vobj(vOid,1),"|",6)
	;
	;  #ACCEPT CR=22273; DATE=2006-07-10; PGM=Frans S.C. Witte; GROUP=DEPRECATED
	S $piece(vobj($G(vOid),1),"|",6)=""
	;
	CLOSE vIo
	Q 
	;
	; ---------------------------------------------------------------------
open(vOid,vRtn,vSrn,vOnm)	;
	N vF S vF=$P(vobj(vOid,1),"|",1)
	I (vF="") S $ZS="-1,"_$ZPOS_","_"%PSL-E-IOOPEN,"_$$^MSG(1087) X $ZT
	I '($P(vobj(vOid,1),"|",6)="") S $ZS="-1,"_$ZPOS_","_"%PSL-E-IOOPEN,device already open" X $ZT
	;
	N vD S vD=$P(vobj(vOid,1),"|",2)
	I (vD="") S vD=$$^UCXCUVAR("SPLDIR")
	;
	N vP S vP=$P(vobj(vOid,1),"|",3)
	N vC S vC=$P(vobj(vOid,1),"|",7)
	;
	I (vC="") D  ; no IO.charsetName specified, derive it
	.	N vT S vT=$P(vobj(vOid,1),"|",9)
	.	N vN S vN=$P(vobj(vOid,1),"|",8)
	.	;
	.	I (vT="") S vT="Routine" S vN=vRtn
	.	D
	..		N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	..		S vC=$$^UCIOENCD(vT,vN,vSrn,vOnm)
	..		S $P(vobj(vOid,1),"|",7)=vC
	..		Q 
	.	Q 
	;
	; Independent of call to $$^UCIOENCD(): if characterset, then add it (quoted)
	;if 'vC.isNull() set vP = vP_ "/ICHSET="_ vC_ "/OCHSET="_ vC
	I '(vC="") S vP=vP_"/CHSET="""_vC_""""
	;
	;  #ACCEPT CR=22273; DATE=2006-07-10; PGM=Frans S.C. Witte; GROUP=DEPRECATED
	S $piece(vobj($G(vOid),1),"|",6)=$$FILE^%TRNLNM(vF,vD)
	;
	N vR S vR=$$FILE^%ZOPEN($P(vobj(vOid,1),"|",6),vP,$P(vobj(vOid,1),"|",4),$P(vobj(vOid,1),"|",5))
	I +vR=0 S $ZS="-1,"_$ZPOS_","_"%PSL-E-IOOPEN,"_$P(vR,"|",2) X $ZT
	;
	Q 
	;
	; ---------------------------------------------------------------------
read(vOid)	; Object
	N vEr
	N vIo S vIo=$I ; save current device
	N vRd S vRd=$$^%ZREAD($P(vobj(vOid,1),"|",6),.vEr)
	;
	I vIo'=$I USE vIo ; restore previous device if needed
	;
	I +vEr'=0 N vo2 S vo2="%PSL-E-IO"_$piece("EOF,NOTOPEN,OTHER",",",vEr)_","_$piece(vEr,"|",2),$ZS=($L($P(vo2,","),"-")=3*-1)_","_$ZPOS_","_vo2 X $ZT
	Q vRd
	;
	; ---------------------------------------------------------------------
write(vOid,vStr,vEol)	;
	N vIo S vIo=$I ; save current device
	;
	I '($D(vEol)#2) USE $P(vobj(vOid,1),"|",6) WRITE vStr,!
	E  USE $P(vobj(vOid,1),"|",6) WRITE vStr,vEol S $X=0
	;
	I vIo'=$I USE vIo ; restore previous device if needed
	;
	Q 
	;
vtrap1	;	Error trap
	;
	N vX S vX=$ZS
	; ignore exceptions thrown due to $$^UCIOENCD()
	Q 
