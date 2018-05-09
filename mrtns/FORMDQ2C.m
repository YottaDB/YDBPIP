FORMDQ2C(SID)	;
	;
	; **** Routine compiled from DATA-QWIK Procedure FORMDQ2C ****
	;
	; 08/30/2007 13:48 - joynerd
	;
	;
	N OP N pgm
	;
	S OP(1)="CTL_Page|CTL^FORMDQ2C(SID)"
	S OP(2)="Scr_Pre|SCRPRE^DBSDS(SID)"
	S OP(3)="VLOD|SCRVLOD^DBSDS(SID)"
	S OP(4)="DSP_Pre|MODDSP^DBSDS(SID)"
	S OP(5)="Entry_Pre|MODPRE^DBSDS(SID)"
	S OP(6)="Scr_Post|MODPP^DBSDS(SID)"
	S OP(7)="Doc|MODDOC^DBSDS(SID)"
	S OP(8)="Item_set|MODREQ^DBSDS(SID)"
	;
	; CTL_Page,Scr_Pre,VLOD/Query,DSP_pre,Entry_Pre,Scr_Post,Doc,Item_Set
	S OP=$$^DBSMBAR(107) Q:(+OP=0) 
	;
	S pgm=$piece(OP(OP),"|",2)
	D @pgm
	;
	D PUTRGN^FORMFUN()
	;
	Q 
	;
CTL(SID)	;
	N vpc
	;
	N VFMQ
	;
	I STATUS WRITE $$LOCK^%TRMVT ; Remove status line first
	;
	N DBTBL2 S DBTBL2=$$vDb1("SYSDEV",SID)
	;
	; Accept for warning on parameter mismatch
	;  #ACCEPT Date=07/26/06; Pgm=RussellDS; CR=22121; Group=MISMATCH
	N vo1 N vo2 N vo3 N vo4 D DRV^USID(1,"DBTBL2",.DBTBL2,.vo1,.vo2,.vo3,.vo4) K vobj(+$G(vo1)) K vobj(+$G(vo2)) K vobj(+$G(vo3)) K vobj(+$G(vo4)) S vpc=((VFMQ="Q")) K:vpc vobj(+$G(DBTBL2)) Q:vpc 
	 S:'$D(vobj(DBTBL2,0)) vobj(DBTBL2,0)=$S(vobj(DBTBL2,-2):$G(^DBTBL(vobj(DBTBL2,-3),2,vobj(DBTBL2,-4),0)),1:"")
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBTBL2FL(DBTBL2,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(DBTBL2,-100) S vobj(DBTBL2,-2)=1 Tcommit:vTp  
	;
	I ($P(vobj(DBTBL2,0),$C(124),1)'[LASTFID) S LASTFID=""
	;
	K vobj(+$G(DBTBL2)) Q 
	;
QL(X)	;
	;
	N Z N Z1
	N FF N FILE N ITEMS N VIDEO N Y
	;
	S ITEMS=$get(X)
	;
	I ($get(FILES)="") D  Q:(FILES="") 
	.	;
	.	N isDone S isDone=0
	.	;
	.	F  D  Q:isDone 
	..		;
	..		S FILES=$$^FORMREAD("",60,"Access Files(s): ",1)
	..		;
	..		I (FILES="") S isDone=1 Q 
	..		;
	..		I $$VALIDATE^DBSFVER(FILES) S isDone=1
	..		E  WRITE $$MSG^FORM("Invalid file relationships",1)
	..		Q 
	.	Q 
	;
	K %TAB,ER,RM,VO
	;
	S OLNTB=22000+$L(FILES)+2
	;
	; Right justify
	I (+$piece($get(FORMHDG),":",2)=0) S FORMHDG="9;1;"_PY_";"_PX
	;
	I RULER S FORMHDG=$piece(FORMHDG,";",1,2)_";"_(PY+1)_";"_(PX-2)
	;
	I (ITEMS="") D  Q:(ITEMS="") 
	.	;
	.	S ITEMS=$$^FORMREAD("",60,FILES_":","U",1)
	.	Q 
	;
	F Z=1:1 S X=$piece(FILES,",",Z) Q:(X="")  S FILE(Z)=X_"|SYSDEV"
	;
	S Z1=1
	F Z=1:1 S Y=$piece(ITEMS,",",Z) Q:(Y="")  D
	.	;
	.	N MATCH
	.	N I
	.	N fid
	.	;
	.	S fid=""
	.	S MATCH=0
	.	;
	.	I (Y?1"["1E.E1"]"1E.E) D
	..		;
	..		N col
	..		;
	..		S fid=$E($piece(Y,"]",1),2,99) Q:'$$vStrLike(FILES,"%"_fid_"%","") 
	..		;
	..		S col=$piece(Y,"]",2)
	..		;
	..		I $$isColumn^UCXDD(fid,col) D
	...			;
	...			S MATCH=1
	...			S Y=col
	...			Q 
	..		Q 
	.	;
	.	E  D
	..		;
	..		F I=1:1:$L(FILES,",") D  Q:MATCH 
	...			;
	...			S fid=$piece(FILE(I),"|",1)
	...			;
	...			I $$isColumn^UCXDD(fid,Y) S MATCH=1
	...			Q 
	..		Q 
	.	;
	.	I 'MATCH WRITE $$MSG^FORM("Invalid data item - "_Y,1)
	.	E  D
	..		;
	..		S X="["_fid_"]"_Y
	..		;
	..		S FF(Z1)=$$DIREFDFT(fid,Y)
	..		;
	..		S Z1=Z1+1
	..		Q 
	.	Q 
	;
	S FF=$order(FF(""),-1)
	;
	S VIDEO=VIDRV ; Reverse Image
	;
	D PUT^FORMFILL
	;
	Q 
	;
DIREFDFT(fid,di)	;
	;
	N PROT N Z2
	N Z1 N Z3
	N Z
	;
	N tblrec S tblrec=$$getSchTbl^UCXDD(fid)
	N colrec S colrec=$$getSchCln^UCXDD(fid,di)
	;
	I ((($P(colrec,"|",3)="")&($P(colrec,"|",14)=""))!($E($P(colrec,"|",3),1)="[")) S PROT=1
	E  S PROT=0
	;
	S RM(1)=$$YN(PROT)_"|2" ; Protect flag
	I ($P(colrec,"|",3)["*") S RM(1)=$$YN(1)_"|2" ; Access key
	S RM(2)=$$YN($P(colrec,"|",28))_"|3" ; Required flag
	S RM(3)=$P(colrec,"|",6)_"            |4" ; Display format
	I ($P(colrec,"|",29)>0) S RM(4)=$P(colrec,"|",29)
	E  S RM(4)=$P(colrec,"|",7)
	S RM(4)=RM(4)_"|5" ; Length
	;
	I '($P(colrec,"|",23)="") D  ; Pre-proc
	.	;
	.	S EDI(1)=1
	.	S RM(5)=$$YN(1)_"|6"
	.	;
	.	S Z3=$order(PP(""),-1)+1
	.	S PP(Z3,1)=" "_$P(colrec,"|",23)
	.	;
	.	Q 
	E  S RM(5)=$$YN(0)_"|6"
	;
	I '($P(colrec,"|",22)="") D  ; Post proc
	.	;
	.	S EDI(2)=1
	.	S RM(6)=$$YN(1)_"|7"
	.	;
	.	S Z1=$order(PP(""),-1)+1
	.	S PP(Z1,1)=" "_$P(colrec,"|",22)
	.	Q 
	E  S RM(6)=$$YN(0)_"|7"
	;
	S RM(7)=$P(colrec,"|",24)
	;
	S Z2=PROT
	I ($P(colrec,"|",3)["*") S Z2=1 ; Protect access keys
	;
	S Z=X_dl_$P(colrec,"|",3)_dl_$P(colrec,"|",7)_dl_$P(colrec,"|",8)
	S Z=Z_dl_$P(colrec,"|",6)_dl_$P(colrec,"|",20)_dl_dl_Z2
	S Z=Z_dl_$P(colrec,"|",21)_dl_$P(colrec,"|",26)_dl_$P(colrec,"|",27)
	;
	S $piece(Z,dl,7)=$P(colrec,"|",28)
	S $piece(Z,dl,18)=$P(colrec,"|",6)
	;
	I '($P(colrec,"|",22)="") S $piece(Z,dl,14)=Z1
	I '($P(colrec,"|",23)="") S $piece(Z,dl,13)=Z3
	;
	I '($P(colrec,"|",4)="") D
	.	;
	.	S $piece(Z,dl,17)=$P(colrec,"|",4)
	.	S $piece(Z,dl,16)=$P(tblrec,"|",10)
	.	Q 
	;
	S $piece(Z,dl,19)=$P(colrec,"|",29)
	;
	Q Z
	;
FUNC(SID)	; Screen ID
	;
	N MASK N OP N pgm
	;
	S OP(1)="Save|SAVE^FORMDQ2C(SID)"
	S OP(2)="Compile|COMPILE^FORMDQ2C(SID),PUTRGN^FORMFUN()"
	S OP(3)=""
	S OP(4)=""
	S OP(5)="Print|PRINT^FORMDQ2C(SID)"
	S OP(6)="List|LIST^FORMDQ2C(SID)"
	S OP(7)="OOE_Exit|EXIT^FORMDQ2C(SID)"
	S OP(8)="Import|IMPORT^FORMEXCH()"
	S OP(9)="Export|EXPORT^FORMEXCH()"
	;
	; Suppress Run and Execute prompts (3 & 4 in MBAR 109)
	S MASK(3)=""
	S MASK(4)=""
	;
	; "Save,Compile,Print,,,List,OOE_Exit,Import,Export"
	S OP=$$^DBSMBAR(109,"",.MASK) Q:(+OP=0) 
	;
	I ($D(P)>0) D SELOFF^FORMSEL(1)
	;
	S pgm=$piece(OP(OP),"|",2)
	D @pgm
	;
	Q 
	;
COMPILE(SID)	; Screen ID
	;
	D FILE^FORMDQ2(SID,SID)
	;
	WRITE $$CLEAR^%TRMVT
	WRITE $$CUP^%TRMVT(1,1)
	;
	D ^DBS2PSL(SID)
	;
	WRITE $$MSG^FORM("Done",1)
	;
	Q 
	;
PRINT(SID)	; Screen ID
	;
	N COPIES
	N IO
	;
	S IO=$$IOSEL Q:(IO="") 
	;
	S COPIES=1
	D IMAGE^FORMPNT
	;
	Q 
	;
LIST(SID)	; Screen ID
	;
	N VRWOPT
	N CONAM N IO N RID N PGM N vudwhere
	;
	D FILE^FORMDQ2(SID,SID)
	;
	S IO=$$IOSEL Q:(IO="") 
	;
	S CONAM="V72QA_GTMLX"
	;
	S RID="DBSSCRLST"
	D ^URID Q:($get(PGM)="") 
	;
	S vudwhere="LIBS='SYSDEV' AND SID=:SID"
	;
	S VRWOPT("NOOPEN")=1
	S VRWOPT("NOCLOSE")=1
	;
	D @("V0^"_PGM)
	;
	D CLOSE^SCAIO
	;
	D PUTRGN^FORMFUN()
	;
	I (IO'=$I) WRITE $$MSG^FORM(SID_" listing completed")
	;
	Q 
	;
IOSEL()	;
	;
	N ER N QUIT
	N IO N POP
	;
	USE 0
	WRITE BTMPAG
	;
	S IO=$$^FORMREAD("",60,"Device: ","U")
	;
	I (IO="") D
	.	;
	.	S IO=$I
	.	WRITE $$REGION^FORMINIT
	.	WRITE $$CLEAR^%TRMVT
	.	Q 
	;
	S (ER,QUIT)=0
	S POP=IO
	D ^SCAIO
	;
	I ER D
	.	;
	.	WRITE $$MSG^FORM("Cannot open "_IO)
	.	;
	.	S IO=""
	.	Q 
	;
	Q IO
	;
BACKUP(SID)	; Screen ID
	;
	D FILE^FORMDQ2(SID,SID)
	;
	Q 
	;
SAVE(SID)	; Screen ID
	;
	N X
	;
	S X=$$SAVE^FORMDQ2()
	;
	Q 
	;
EXIT(SID)	; Screen ID
	;
	I '$$SAVE^FORMDQ2(1) S ZB=13
	E  D
	.	;
	.	N OPGM N OSID N ZPGM
	.	;
	.	N zdbtbl2,vop1,vop2,vop3 S vop1="SYSDEV",vop2=SID,zdbtbl2=$$vDb2("SYSDEV",SID)
	.	 S vop3=$G(^DBTBL(vop1,2,vop2,0))
	.	;
	.	S ZPGM=$P(vop3,$C(124),2)
	.	;
	.	S OSID=$E(SID,2,1048575)
	.	;
	.	N dbtbl2,vop4,vop5,vop6 S vop4="SYSDEV",vop5=OSID,dbtbl2=$$vDb2("SYSDEV",OSID)
	.	 S vop6=$G(^DBTBL(vop4,2,vop5,0))
	.	;
	.	S OPGM=$P(vop6,$C(124),2)
	.	;
	.	; Delete the temporary copy
	. K ^DBTBL("SYSDEV",2,SID)
	.	;
	.	; Delete the screen routine (V program name)
	.	I '(ZPGM=""),(ZPGM'=OPGM) D DEL^%ZRTNDEL(ZPGM)
	.	;
	.	S ZB=""
	.	Q 
	;
	LOCK 
	;
	Q 
	;
YN(X)	;
	;
	I X Q "Y"
	;
	Q "N"
	;  #OPTION ResultClass ON
vSIG()	;
	Q "60472^58614^Dan Russell^7875" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vStrLike(object,p1,p2)	; String.isLike
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I (p1="") Q (object="")
	I p2 S object=$$vStrUC(object) S p1=$$vStrUC(p1)
	I ($E(p1,1)="%"),($E(p1,$L(p1))="%") Q object[$E(p1,2,$L(p1)-1)
	I ($E(p1,1)="%") Q ($E(object,$L(object)-$L($E(p1,2,1048575))+1,1048575)=$E(p1,2,1048575))
	I ($E(p1,$L(p1))="%") Q ($E(object,1,$L(($E(p1,1,$L(p1)-1))))=($E(p1,1,$L(p1)-1)))
	Q object=p1
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(DBTBL2,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL2"
	S vobj(vOid)=$G(^DBTBL(v1,2,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,2,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL2" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDb2(v1,v2)	;	voXN = Db.getRecord(DBTBL2,,0)
	;
	N zdbtbl2
	S zdbtbl2=$G(^DBTBL(v1,2,v2))
	I zdbtbl2="",'$D(^DBTBL(v1,2,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL2" X $ZT
	Q zdbtbl2
