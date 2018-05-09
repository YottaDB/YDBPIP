DBSDF	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSDF ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	Q  ; No entry from top
	;
CREATE	;
	;
	N FID
	;
	S FID=$$FIND^DBSGETID("DBTBL1",1) Q:(FID="") 
	;
	I '($E(FID,1)="Z"),($D(^STBL("RESERVED",FID))#2) D  Q 
	.	;
	.	S ER=1
	.	; SQL reserved word - not permitted for use
	.	S RM=$$^MSG(5259)
	.	Q 
	;
	Q:'$$HEADER(0,FID)  ; Table control page
	;
	D COLUMNS(FID) ; Column definition
	;
	Q 
	;
MODIFY	;
	;
	N isDone S isDone=0
	;
	F  D  Q:isDone 
	.	;
	.	N %A1 N %A2 N %A3 N %FRAME N DEDF
	.	N OLNTB
	.	N %NOPRMT N %READ N %TAB N FID N VFMQ N X
	.	;
	.	S FID=$$FIND^DBSGETID("DBTBL1",0)
	.	I (FID="") S isDone=1 Q 
	.	;
	.	S (%A1,%A3,DEDF)=0
	.	S %A2=1
	.	S OLNTB=6040
	.	;
	.	S %TAB("%A1")=".%A2"
	.	S %TAB("%A2")=".%A3"
	.	S %TAB("%A3")=".%A4"
	.	S %TAB("DEDF")=".DEDF"
	.	;
	.	S %READ="%A1,%A2,%A3,DEDF"
	.	S %NOPRMT="F"
	.	S %FRAME=1
	.	;
	.	D ^UTLREAD Q:VFMQ="Q" 
	.	;
	.	I %A1 S X=$$HEADER(1,FID) ; File header
	.	I %A2 D COLUMNS(FID) ; Columns
	.	I %A3 D DOC(FID) ; Documentation
	.	I DEDF D DEDF(FID) ; Data entry definition
	.	Q 
	;
	Q 
	;
HEADER(%O,FID)	;
	;
	N VFMQ
	;
	N fDBTBL1 S fDBTBL1=$$vDb1("SYSDEV",FID)
	 S vobj(fDBTBL1,10)=$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),10))
	 S vobj(fDBTBL1,100)=$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),100))
	 S vobj(fDBTBL1,12)=$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),12))
	;
	; Set defaults for screen
	I ($G(vobj(fDBTBL1,-2))=0) D
	.	;
	. S vobj(fDBTBL1,-100,10)="",$P(vobj(fDBTBL1,10),$C(124),2)="PBS"
	. S vobj(fDBTBL1,-100,10)="",$P(vobj(fDBTBL1,10),$C(124),3)=0
	. S vobj(fDBTBL1,-100,100)="",$P(vobj(fDBTBL1,100),$C(124),2)=1
	. S:'$D(vobj(fDBTBL1,-100,12,"FSN")) vobj(fDBTBL1,-100,12,"FSN")="T001"_$P(vobj(fDBTBL1,12),$C(124),1) S vobj(fDBTBL1,-100,12)="",$P(vobj(fDBTBL1,12),$C(124),1)="f"_$translate($E(FID,1,7),"_","z")
	.	Q 
	;
	;  #ACCEPT Date=11/02/06; Pgm=RussellDS; CR=22719; Group=MISMATCH
	N vo2 N vo3 N vo4 N vo5 D DRV^USID(%O,"DBTBL1",.fDBTBL1,.vo2,.vo3,.vo4,.vo5) K vobj(+$G(vo2)) K vobj(+$G(vo3)) K vobj(+$G(vo4)) K vobj(+$G(vo5))
	;
	I VFMQ="Q" K vobj(+$G(fDBTBL1)) Q 0
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSDF1F(fDBTBL1,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(fDBTBL1,-100) S vobj(fDBTBL1,-2)=1 Tcommit:vTp  
	;
	K vobj(+$G(fDBTBL1)) Q 1
	;
DOC(FID)	;
	N vpc
	;
	N cnt N seq N WIDTH
	N DATA N MSG
	;
	N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen1()
	;
	S WIDTH=80
	S cnt=0
	F  Q:'($$vFetch1())  D
	.	;
	.	S cnt=cnt+1
	.	S DATA(cnt)=$P(rs,$C(9),2)
	.	I $L(DATA(cnt))>78 S WIDTH=132
	.	Q 
	;
	; ~p1~p2] - File Documentation
	S MSG=$$^MSG(7082,"[",FID)
	D ^DBSWRITE("DATA",3,22,99999,WIDTH,MSG)
	;
	S vpc=('$D(DATA)) Q:vpc 
	;
	; Remove any old records
	D vDbDe1()
	;
	; Save new records
	S cnt=""
	S seq=1
	F  S cnt=$order(DATA(cnt)) Q:(cnt="")  D
	.	;
	.	N tbldoc S tbldoc=$$vDbNew1("SYSDEV",FID,seq)
	.	;
	. S $P(vobj(tbldoc),$C(124),1)=DATA(cnt)
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^TBLDOCFL(tbldoc,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(tbldoc,-100) S vobj(tbldoc,-2)=1 Tcommit:vTp  
	.	;
	.	S seq=seq+1
	.	K vobj(+$G(tbldoc)) Q 
	;
	Q 
	;
DELETE	;
	;
	N isDone S isDone=0
	;
	F  D  Q:isDone 
	.	;
	.	N I
	.	N acckeys N FID N keys N p1
	.	;
	.	S FID=$$FIND^DBSGETID("DBTBL1",0)
	.	I (FID="") S isDone=1 Q 
	.	;
	.	N rsindex,vos1,vos2,vos3 S rsindex=$$vOpen2()
	.	N rsfkey,vos4,vos5,vos6 S rsfkey=$$vOpen3()
	.	;
	.	I $$vFetch2()!$$vFetch3() D  Q 
	..		;
	..		S ER=1
	..		; Index or foreign key definition exists.  Delete before continuing.
	..		S RM=$$^MSG(744)
	..		Q 
	.	;
	.	N rsfkey2,vos7,vos8,vos9 S rsfkey2=$$vOpen4()
	.	;
	.	I $$vFetch4() D  Q 
	..		;
	..		S ER=1
	..		; ~p1 foreign key definition references ~p2
	..		S RM=$$^MSG(906,rsfkey2,FID)
	..		Q 
	.	;
	.	N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=FID,dbtbl1=$$vDb7("SYSDEV",FID)
	.	 S vop3=$G(^DBTBL(vop1,1,vop2,16))
	.	;
	.	S acckeys=$P(vop3,$C(124),1)
	.	S keys=""
	.	F I=1:1:$L(acckeys,",") D
	..		;
	..		N key S key=$piece(acckeys,",",I)
	..		;
	..		I '($$isLit^UCGM(key)!($E(key,1)="$")) S keys=keys_key_","
	..		Q 
	.	S keys=$E(keys,1,$L(keys)-1)
	.	;
	.	;   #ACCEPT Date=04/11/06; Pgm=RussellDS; CR=20967
	.	N rsdata,vos10,vos11,sqlcur,exe,sqlcur,vd,vi,vsql,vsub S rsdata=$$vOpen0(.exe,.vsql,keys,FID,"","","","")
	.	;
	.	I '$G(vos10) S deldata=0
	.	E  D  Q:stop 
	..		;
	..		N MSG
	..		;
	..		S deldata=1
	..		S stop=0
	..		;
	..		; Table ~p1 contains data.  Deleting the table will also delete the data.  Continue?
	..		S MSG=$$^MSG(5735,FID)
	..		;
	..		I (+$$^DBSMBAR(2)'=+2) S stop=1
	..		Q 
	.	;
	.	S p1=FID
	.	; Delete <<p1>> ... No Yes
	.	I (+$$^DBSMBAR(164)'=+2) Q 
	.	;
	.	; Use SQL until we have a dynamic delete
	.	I deldata D
	..		;
	..		N X
	..		;
	..		S X=$$^SQL("DELETE "_FID)
	..		Q 
	.	;
	.	D vDbDe2()
	.	D vDbDe3()
	.	;
	.	; Drop table from RDB
	.	I $$rdb^UCDBRT(FID) D
	..		;
	..		N vER
	..		N vRM
	..		;
	..		S vER=$$EXECUTE^%DBAPI("","DROP TABLE "_FID,$char(9),"",.vRM)
	..		;
	..		I (vER=0) S vER=$$COMMIT^%DBAPI("",.vRM)
	..		;
	..		I (+vER'=+0) D
	...			;
	...			S ER=1
	...			S RM=vRM
	...			Q 
	..		Q 
	.	;
	.	; Done
	.	I 'ER WRITE $$MSG^%TRMVT($$^MSG(855),"",1)
	.	Q 
	;
	Q 
	;
COPY	;
	N vpc
	;
	N isDone S isDone=0
	;
	F  D  Q:isDone 
	.	;
	.	N OLNTB
	.	N %NOPRMT N %READ N FID N TOFID N VFMQ
	.	;
	.	S FID=$$FIND^DBSGETID("DBTBL1",0)
	.	I (FID="") S isDone=1 Q 
	.	;
	.	N fDBTBL1 S fDBTBL1=$$vDb2("SYSDEV",FID)
	.	;
	.	S %NOPRMT="Q"
	.	;   #ACCEPT Date=11/02/06; Pgm=RussellDS; CR=22719; Group=MISMATCH
	. N vo6 N vo7 N vo8 N vo9 D DRV^USID(2,"DBTBL1",.fDBTBL1,.vo6,.vo7,.vo8,.vo9) K vobj(+$G(vo6)) K vobj(+$G(vo7)) K vobj(+$G(vo8)) K vobj(+$G(vo9))
	.	;
	.	S %READ="TOFID/TBL=[DBTBL1]:NOVAL/XPP=D COPYPP^DBSDF"
	.	S %READ=%READ_"/TYP=U/DES=To File Definition Name"
	.	;
	.	S %NOPRMT="F"
	.	S OLNTB=22020 ; Display below DBTBL1 screen
	.	D ^UTLREAD S vpc=((VFMQ'="F")) K:vpc vobj(+$G(fDBTBL1)) Q:vpc 
	.	;
	.	N dbtbl1 S dbtbl1=$$vDb2("SYSDEV",FID)
	.	N dbtbl1c S dbtbl1c=$$vReCp1(dbtbl1)
	.	;
	. S vobj(dbtbl1c,-4)=TOFID
	. S:'$D(vobj(dbtbl1c,-100,10,"PARFID")) vobj(dbtbl1c,-100,10,"PARFID")="U004"_$P(vobj(dbtbl1c,10),$C(124),4) S vobj(dbtbl1c,-100,10)="",$P(vobj(dbtbl1c,10),$C(124),4)="" ; Supertype file
	. S:'$D(vobj(dbtbl1c,-100,99,"UDFILE")) vobj(dbtbl1c,-100,99,"UDFILE")="U002"_$P(vobj(dbtbl1c,99),$C(124),2) S vobj(dbtbl1c,-100,99)="",$P(vobj(dbtbl1c,99),$C(124),2)="" ; Filer
	.	;
	.	S vobj(dbtbl1c,-2)=0
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSDF1F(dbtbl1c,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(dbtbl1c,-100) S vobj(dbtbl1c,-2)=1 Tcommit:vTp  
	.	;
	.	N ds,vos1,vos2,vos3 S ds=$$vOpen5()
	.	;
	.	F  Q:'($$vFetch5())  D
	..		;
	..		N dbtbl1d S dbtbl1d=$$vDb3($P(ds,$C(9),1),$P(ds,$C(9),2),$P(ds,$C(9),3))
	..		N dbtbl1dc S dbtbl1dc=$$vReCp2(dbtbl1d)
	..		;
	..	 S vobj(dbtbl1dc,-4)=TOFID
	..		;
	..		; Key columns are created by DBTBL1 filer, so just update them
	..		 N V1 S V1=vobj(dbtbl1d,-5) I '($D(^DBTBL("SYSDEV",1,TOFID,9,V1))#2) D
	...			;
	...			S vobj(dbtbl1dc,-2)=0
	...			Q 
	..		E  S vobj(dbtbl1dc,-2)=1
	..		;
	..	 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSDFF(dbtbl1dc,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(dbtbl1dc,-100) S vobj(dbtbl1dc,-2)=1 Tcommit:vTp  
	..		K vobj(+$G(dbtbl1d)),vobj(+$G(dbtbl1dc)) Q 
	.	;
	.	N dsdoc,vos4,vos5,vos6 S dsdoc=$$vOpen6()
	.	;
	.	F  Q:'($$vFetch6())  D
	..		;
	..		N tbldoc S tbldoc=$$vDb4($P(dsdoc,$C(9),1),$P(dsdoc,$C(9),2),$P(dsdoc,$C(9),3))
	..		N tbldocc S tbldocc=$$vReCp3(tbldoc)
	..		;
	..	 S vobj(tbldocc,-4)=TOFID
	..		;
	..		S vobj(tbldocc,-2)=0
	..	 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^TBLDOCFL(tbldocc,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(tbldocc,-100) S vobj(tbldocc,-2)=1 Tcommit:vTp  
	..		K vobj(+$G(tbldoc)),vobj(+$G(tbldocc)) Q 
	.	K vobj(+$G(dbtbl1)),vobj(+$G(dbtbl1c)),vobj(+$G(fDBTBL1)) Q 
	;
	Q 
	;
COPYPP	; Copy to prompt post-processor
	;
	Q:(X="") 
	;
	I '$$VALIDKEY^DBSGETID(X) D
	.	;
	.	S ER=1
	.	; // Alphanumeric format only
	.	S RM=$$^MSG(248)
	.	Q 
	;
	E  I ($D(^DBTBL("SYSDEV",1,X))) D
	.	;
	.	S ER=1
	.	; Already created
	.	S RM=$$^MSG(252)
	.	Q 
	;
	E  I '($E(X,1)="Z"),($D(^STBL("RESERVED",X))#2) D
	.	;
	.	S ER=1
	.	; SQL reserved word - not permitted for use
	.	S RM=$$^MSG(5259)
	.	Q 
	;
	Q 
	;
COLUMNS(FID)	; Table name
	;
	N DELETE N isDone
	N nodpos N DI N VFMQ
	;
	S isDone=0
	;
	N fDBTBL1 S fDBTBL1=$$vDb2("SYSDEV",FID)
	;
	F  D  Q:isDone 
	.	;
	.	N RM
	.	;
	.	S DELETE=0
	.	S DI=""
	.	;
	.	N fDBTBL1D S fDBTBL1D=$$vDbNew2("","","")
	.	;
	.	;   #ACCEPT Date=11/02/06; Pgm=RussellDS; CR=22719; Group=MISMATCH
	. N vo10 N vo11 N vo12 D DRV^USID(0,"DBTBL1D",.fDBTBL1D,.fDBTBL1,.vo10,.vo11,.vo12) K vobj(+$G(vo10)) K vobj(+$G(vo11)) K vobj(+$G(vo12))
	.	;
	.	I (VFMQ="F") D
	..		;
	..		I DELETE D
	...			;
	...			S vobj(fDBTBL1D,-2)=3
	...		 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSDFF(fDBTBL1D,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(fDBTBL1D,-100) S vobj(fDBTBL1D,-2)=1 Tcommit:vTp  
	...			Q 
	..		;
	..		E  D
	...			;
	...			 N V1,V2 S V1=vobj(fDBTBL1D,-4),V2=vobj(fDBTBL1D,-5) I ($D(^DBTBL("SYSDEV",1,V1,9,V2))#2) D
	....				;
	....				S vobj(fDBTBL1D,-2)=1
	....				Q 
	...			E  S vobj(fDBTBL1D,-2)=0
	...			;
	...		 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSDFF(fDBTBL1D,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(fDBTBL1D,-100) S vobj(fDBTBL1D,-2)=1 Tcommit:vTp  
	...			Q 
	..		Q 
	.	;
	.	; Continue?
	.	I '$$YN^DBSMBAR("",$$^MSG(603),1) S isDone=1
	.	K vobj(+$G(fDBTBL1D)) Q 
	;
	K vobj(+$G(fDBTBL1)) Q 
	;
PARCOPY(PARFID,CHILDFID)	;
	;
	N ds,vos1,vos2,vos3 S ds=$$vOpen7()
	;
	F  Q:'($$vFetch7())  D
	.	;
	.	N COLNAME
	.	;
	.	N dbtbl1dp S dbtbl1dp=$$vDb3($P(ds,$C(9),1),$P(ds,$C(9),2),$P(ds,$C(9),3))
	.	;
	.	S COLNAME=vobj(dbtbl1dp,-5)
	.	;
	.	N dbtbl1dc S dbtbl1dc=$$vDb3("SYSDEV",CHILDFID,COLNAME)
	.	;
	.	I ($G(vobj(dbtbl1dc,-2))=0) D
	..		;
	..	 K vobj(+$G(dbtbl1dc)) S dbtbl1dc=$$vReCp4(dbtbl1dp)
	..		;
	..	 S vobj(dbtbl1dc,-4)=CHILDFID
	..		;
	..		S vobj(dbtbl1dc,-2)=0
	..	 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSDFF(dbtbl1dc,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(dbtbl1dc,-100) S vobj(dbtbl1dc,-2)=1 Tcommit:vTp  
	..		Q 
	.	;
	.	E  D
	..		;
	..		N hit S hit=0
	..		;
	..		I $P(vobj(dbtbl1dc),$C(124),1)'=$P(vobj(dbtbl1dp),$C(124),1) D
	...			;
	...		 S:'$D(vobj(dbtbl1dc,-100,"0*","NOD")) vobj(dbtbl1dc,-100,"0*","NOD")="T001"_$P(vobj(dbtbl1dc),$C(124),1) S vobj(dbtbl1dc,-100,"0*")="",$P(vobj(dbtbl1dc),$C(124),1)=$P(vobj(dbtbl1dp),$C(124),1)
	...			S hit=1
	...			Q 
	..		I $P(vobj(dbtbl1dc),$C(124),2)'=$P(vobj(dbtbl1dp),$C(124),2) D
	...			;
	...		 S:'$D(vobj(dbtbl1dc,-100,"0*","LEN")) vobj(dbtbl1dc,-100,"0*","LEN")="N002"_$P(vobj(dbtbl1dc),$C(124),2) S vobj(dbtbl1dc,-100,"0*")="",$P(vobj(dbtbl1dc),$C(124),2)=$P(vobj(dbtbl1dp),$C(124),2)
	...			S hit=1
	...			Q 
	..		I $P(vobj(dbtbl1dc),$C(124),3)'=$P(vobj(dbtbl1dp),$C(124),3) D
	...			;
	...		 S:'$D(vobj(dbtbl1dc,-100,"0*","DFT")) vobj(dbtbl1dc,-100,"0*","DFT")="T003"_$P(vobj(dbtbl1dc),$C(124),3) S vobj(dbtbl1dc,-100,"0*")="",$P(vobj(dbtbl1dc),$C(124),3)=$P(vobj(dbtbl1dp),$C(124),3)
	...			S hit=1
	...			Q 
	..		I $P(vobj(dbtbl1dc),$C(124),4)'=$P(vobj(dbtbl1dp),$C(124),4) D
	...			;
	...		 S:'$D(vobj(dbtbl1dc,-100,"0*","DOM")) vobj(dbtbl1dc,-100,"0*","DOM")="U004"_$P(vobj(dbtbl1dc),$C(124),4) S vobj(dbtbl1dc,-100,"0*")="",$P(vobj(dbtbl1dc),$C(124),4)=$P(vobj(dbtbl1dp),$C(124),4)
	...			S hit=1
	...			Q 
	..		I $P(vobj(dbtbl1dc),$C(124),9)'=$P(vobj(dbtbl1dp),$C(124),9) D
	...			;
	...		 S:'$D(vobj(dbtbl1dc,-100,"0*","TYP")) vobj(dbtbl1dc,-100,"0*","TYP")="U009"_$P(vobj(dbtbl1dc),$C(124),9) S vobj(dbtbl1dc,-100,"0*")="",$P(vobj(dbtbl1dc),$C(124),9)=$P(vobj(dbtbl1dp),$C(124),9)
	...			S hit=1
	...			Q 
	..		I $P(vobj(dbtbl1dc),$C(124),10)'=$P(vobj(dbtbl1dp),$C(124),10) D
	...			;
	...		 S:'$D(vobj(dbtbl1dc,-100,"0*","DES")) vobj(dbtbl1dc,-100,"0*","DES")="T010"_$P(vobj(dbtbl1dc),$C(124),10) S vobj(dbtbl1dc,-100,"0*")="",$P(vobj(dbtbl1dc),$C(124),10)=$P(vobj(dbtbl1dp),$C(124),10)
	...			S hit=1
	...			Q 
	..		I $P(vobj(dbtbl1dc),$C(124),11)'=$P(vobj(dbtbl1dp),$C(124),11) D
	...			;
	...		 S:'$D(vobj(dbtbl1dc,-100,"0*","ITP")) vobj(dbtbl1dc,-100,"0*","ITP")="T011"_$P(vobj(dbtbl1dc),$C(124),11) S vobj(dbtbl1dc,-100,"0*")="",$P(vobj(dbtbl1dc),$C(124),11)=$P(vobj(dbtbl1dp),$C(124),11)
	...			S hit=1
	...			Q 
	..		I $P(vobj(dbtbl1dc),$C(124),14)'=$P(vobj(dbtbl1dp),$C(124),14) D
	...			;
	...		 S:'$D(vobj(dbtbl1dc,-100,"0*","DEC")) vobj(dbtbl1dc,-100,"0*","DEC")="N014"_$P(vobj(dbtbl1dc),$C(124),14) S vobj(dbtbl1dc,-100,"0*")="",$P(vobj(dbtbl1dc),$C(124),14)=$P(vobj(dbtbl1dp),$C(124),14)
	...			S hit=1
	...			Q 
	..		I $P(vobj(dbtbl1dc),$C(124),16)'=$P(vobj(dbtbl1dp),$C(124),16) D
	...			;
	...		 S:'$D(vobj(dbtbl1dc,-100,"0*","CMP")) vobj(dbtbl1dc,-100,"0*","CMP")="T016"_$P(vobj(dbtbl1dc),$C(124),16) S vobj(dbtbl1dc,-100,"0*")="",$P(vobj(dbtbl1dc),$C(124),16)=$P(vobj(dbtbl1dp),$C(124),16)
	...			S hit=1
	...			Q 
	..		I $P(vobj(dbtbl1dc),$C(124),17)'=$P(vobj(dbtbl1dp),$C(124),17) D
	...			;
	...		 S:'$D(vobj(dbtbl1dc,-100,"0*","ISMASTER")) vobj(dbtbl1dc,-100,"0*","ISMASTER")="L017"_$P(vobj(dbtbl1dc),$C(124),17) S vobj(dbtbl1dc,-100,"0*")="",$P(vobj(dbtbl1dc),$C(124),17)=$P(vobj(dbtbl1dp),$C(124),17)
	...			S hit=1
	...			Q 
	..		I $P(vobj(dbtbl1dc),$C(124),18)'=$P(vobj(dbtbl1dp),$C(124),18) D
	...			;
	...		 N vSetMf S vSetMf=$P(vobj(dbtbl1dc),$C(124),18) S:'$D(vobj(dbtbl1dc,-100,"0*","SFD1")) vobj(dbtbl1dc,-100,"0*","SFD1")="N018"_$P(vSetMf,$C(126),2)_"||~126~~2" S:'$D(vobj(dbtbl1dc,-100,"0*","SFD2")) vobj(dbtbl1dc,-100,"0*","SFD2")="N018"_$P(vSetMf,$C(126),3)_"||~126~~3" S:'$D(vobj(dbtbl1dc,-100,"0*","SFP")) vobj(dbtbl1dc,-100,"0*","SFP")="N018"_$P(vSetMf,$C(126),4)_"||~126~~4" S:'$D(vobj(dbtbl1dc,-100,"0*","SFT")) vobj(dbtbl1dc,-100,"0*","SFT")="U018"_$P(vSetMf,$C(126),1)_"||~126~~1" S $P(vobj(dbtbl1dc),$C(124),18)=$P(vobj(dbtbl1dp),$C(124),18),vobj(dbtbl1dc,-100,"0*")=""
	...			S hit=1
	...			Q 
	..		I $P(vobj(dbtbl1dc),$C(124),19)'=$P(vobj(dbtbl1dp),$C(124),19) D
	...			;
	...		 S:'$D(vobj(dbtbl1dc,-100,"0*","SIZ")) vobj(dbtbl1dc,-100,"0*","SIZ")="N019"_$P(vobj(dbtbl1dc),$C(124),19) S vobj(dbtbl1dc,-100,"0*")="",$P(vobj(dbtbl1dc),$C(124),19)=$P(vobj(dbtbl1dp),$C(124),19)
	...			S hit=1
	...			Q 
	..		I $P(vobj(dbtbl1dc),$C(124),21)'=$P(vobj(dbtbl1dp),$C(124),21) D
	...			;
	...		 S:'$D(vobj(dbtbl1dc,-100,"0*","POS")) vobj(dbtbl1dc,-100,"0*","POS")="N021"_$P(vobj(dbtbl1dc),$C(124),21) S vobj(dbtbl1dc,-100,"0*")="",$P(vobj(dbtbl1dc),$C(124),21)=$P(vobj(dbtbl1dp),$C(124),21)
	...			S hit=1
	...			Q 
	..		I $P(vobj(dbtbl1dc),$C(124),22)'=$P(vobj(dbtbl1dp),$C(124),22) D
	...			;
	...		 S:'$D(vobj(dbtbl1dc,-100,"0*","RHD")) vobj(dbtbl1dc,-100,"0*","RHD")="T022"_$P(vobj(dbtbl1dc),$C(124),22) S vobj(dbtbl1dc,-100,"0*")="",$P(vobj(dbtbl1dc),$C(124),22)=$P(vobj(dbtbl1dp),$C(124),22)
	...			S hit=1
	...			Q 
	..		I $P(vobj(dbtbl1dc),$C(124),23)'=$P(vobj(dbtbl1dp),$C(124),23) D
	...			;
	...		 S:'$D(vobj(dbtbl1dc,-100,"0*","SRL")) vobj(dbtbl1dc,-100,"0*","SRL")="L023"_$P(vobj(dbtbl1dc),$C(124),23) S vobj(dbtbl1dc,-100,"0*")="",$P(vobj(dbtbl1dc),$C(124),23)=$P(vobj(dbtbl1dp),$C(124),23)
	...			S hit=1
	...			Q 
	..		I $P(vobj(dbtbl1dc),$C(124),24)'=$P(vobj(dbtbl1dp),$C(124),24) D
	...			;
	...		 S:'$D(vobj(dbtbl1dc,-100,"0*","CNV")) vobj(dbtbl1dc,-100,"0*","CNV")="N024"_$P(vobj(dbtbl1dc),$C(124),24) S vobj(dbtbl1dc,-100,"0*")="",$P(vobj(dbtbl1dc),$C(124),24)=$P(vobj(dbtbl1dp),$C(124),24)
	...			S hit=1
	...			Q 
	..		I $P(vobj(dbtbl1dc),$C(124),25)'=$P(vobj(dbtbl1dp),$C(124),25) D
	...			;
	...		 S:'$D(vobj(dbtbl1dc,-100,"0*","LTD")) vobj(dbtbl1dc,-100,"0*","LTD")="D025"_$P(vobj(dbtbl1dc),$C(124),25) S vobj(dbtbl1dc,-100,"0*")="",$P(vobj(dbtbl1dc),$C(124),25)=$P(vobj(dbtbl1dp),$C(124),25)
	...			S hit=1
	...			Q 
	..		I $P(vobj(dbtbl1dc),$C(124),26)'=$P(vobj(dbtbl1dp),$C(124),26) D
	...			;
	...		 S:'$D(vobj(dbtbl1dc,-100,"0*","USER")) vobj(dbtbl1dc,-100,"0*","USER")="T026"_$P(vobj(dbtbl1dc),$C(124),26) S vobj(dbtbl1dc,-100,"0*")="",$P(vobj(dbtbl1dc),$C(124),26)=$P(vobj(dbtbl1dp),$C(124),26)
	...			S hit=1
	...			Q 
	..		I $P(vobj(dbtbl1dc),$C(124),27)'=$P(vobj(dbtbl1dp),$C(124),27) D
	...			;
	...		 S:'$D(vobj(dbtbl1dc,-100,"0*","MDD")) vobj(dbtbl1dc,-100,"0*","MDD")="U027"_$P(vobj(dbtbl1dc),$C(124),27) S vobj(dbtbl1dc,-100,"0*")="",$P(vobj(dbtbl1dc),$C(124),27)=$P(vobj(dbtbl1dp),$C(124),27)
	...			S hit=1
	...			Q 
	..		I $P(vobj(dbtbl1dc),$C(124),28)'=$P(vobj(dbtbl1dp),$C(124),28) D
	...			;
	...		 S:'$D(vobj(dbtbl1dc,-100,"0*","VAL4EXT")) vobj(dbtbl1dc,-100,"0*","VAL4EXT")="L028"_$P(vobj(dbtbl1dc),$C(124),28) S vobj(dbtbl1dc,-100,"0*")="",$P(vobj(dbtbl1dc),$C(124),28)=$P(vobj(dbtbl1dp),$C(124),28)
	...			S hit=1
	...			Q 
	..		;
	..		I hit N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSDFF(dbtbl1dc,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(dbtbl1dc,-100) S vobj(dbtbl1dc,-2)=1 Tcommit:vTp  
	..		Q 
	.	K vobj(+$G(dbtbl1dc)),vobj(+$G(dbtbl1dp)) Q 
	;
	Q 
	;
PARDEL(PARFID,CHILDFID)	;
	;
	N rs,vos1,vos2,vos3 S rs=$$vOpen8()
	;
	F  Q:'($$vFetch8())  D
	.	;
	.	N COLNAME
	.	;
	.	S COLNAME=rs
	.	;
	.	D vDbDe4()
	.	Q 
	;
	Q 
	;
DEDF(FID)	;
	N vpc
	;
	N VFMQ
	;
	N fDBTBL1 S fDBTBL1=$$vDb2("SYSDEV",FID)
	;
	;  #ACCEPT Date=11/02/06; Pgm=RussellDS; CR=22719; Group=MISMATCH
	N vo13 N vo14 N vo15 N vo16 D DRV^USID(1,"DBSDBE",.fDBTBL1,.vo13,.vo14,.vo15,.vo16) K vobj(+$G(vo13)) K vobj(+$G(vo14)) K vobj(+$G(vo15)) K vobj(+$G(vo16)) S vpc=((VFMQ="Q")) K:vpc vobj(+$G(fDBTBL1)) Q:vpc 
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSDF1F(fDBTBL1,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(fDBTBL1,-100) S vobj(fDBTBL1,-2)=1 Tcommit:vTp  
	;
	K vobj(+$G(fDBTBL1)) Q 
	;
VALIDCMP(FID,DI,CMP,RM)	;
	;
	N ER
	N ptr
	N dels N CMPTOK N CMPUC N tok N v
	;
	S ER=0
	S RM=""
	;
	I (CMP="") Q 0
	;
	I (CMP["^"),'(CMP["$$"),'(CMP["""^""") D  Q ER
	.	;
	.	S ER=1
	.	; Invalid expression
	.	S RM=$$^MSG(8045)
	.	Q 
	;
	S ptr=0
	F  S ptr=$F(CMP," ",ptr) Q:(ptr=0)  I ($L($E(CMP,1,ptr-1),"""")#2=1) D  Q 
	.	;
	.	S ER=1
	.	; Warning - invalid M expression (V 5.0)
	.	S RM=$$^MSG(2965)
	.	Q 
	;
	I ER Q ER
	;
	; Add () around computed if necessary
	I '(($E(CMP,1)="(")&($E(CMP,$L(CMP))=")")),($translate(CMP,"+-*/\_#=><","")'=CMP) S CMP="("_CMP_")"
	;
	I (CMP=",%%,") D  Q 1
	.	;
	.	; Change the % sign into $C(124)
	.	S RM=$$^MSG(7022)
	.	Q 
	;
	I (CMP?1A.A1" "." "1A.A) D  Q 1
	.	;
	.	; Can't have a space in the middle
	.	S RM=$$^MSG(7021)
	.	Q 
	;
	I (+$L(CMP,"(")'=+$L(CMP,")")) D  Q 1
	.	;
	.	; Missing Parenthesis
	.	S RM=$$^MSG(7079)
	.	Q 
	;
	I (CMP["$D"),'(CMP["$$D") D  Q 1
	.	;
	.	; Invalid expression ~p1
	.	S RM=$$^MSG(8045," - $D")
	.	Q 
	;
	; Do not allow set or do in computed
	S CMPUC=$$vStrUC(CMP)
	I (($E(CMPUC,1,2)="S ")!($E(CMPUC,1,4)="SET ")!($E(CMPUC,1,2)="D ")!($E(CMPUC,1,3)="DO ")) D  Q 1
	.	;
	.	; Invalid computed data item - 'di'
	.	S RM=$$^MSG(8316,$$^MSG(595),FID_"."_DI)
	.	Q 
	;
	S CMPTOK=$$TOKEN^%ZS(CMP,.tok)
	S ptr=0
	S dels="[]+-*/\#_'=><(),!&:?"
	F  S v=$$ATOM^%ZS(CMPTOK,.ptr,dels,tok,1) D  Q:(ER!(ptr=0)) 
	.	;
	.	I (v="?") S v=$$ATOM^%ZS(CMPTOK,.ptr,dels,tok,1) Q 
	.	;
	.	Q:(dels[v) 
	.	;
	.	; System keyword
	.	I ($E(v,1)="%")  N V1 S V1=v I ($D(^STBL("SYSKEYWORDS",V1))#2) Q 
	.	;
	.	Q:($ascii(v)=0)  ; Tokenized literal
	.	Q:($E(v,1)="$") 
	.	Q:(v=+v) 
	.	;
	.	; Should be a valid column name at this point
	.	;
	.	I (v=DI) D  Q 
	..		;
	..		S ER=1
	..		; Invalid expression ~p1
	..		S RM=$$^MSG(8045,v)
	..		Q 
	.	;
	.	 N V2 S V2=v I '($D(^DBTBL("SYSDEV",1,FID,9,V2))#2) D
	..		;
	..		S ER=1
	..		; Invalid expression ~p1
	..		S RM=$$^MSG(8045)
	..		Q 
	.	Q 
	;
	Q ER
	;
MDD(FID)	; Table name
	N vret
	;
	N SYSSN
	;
	N tblrec S tblrec=$$getSchTbl^UCXDD(FID)
	;
	S SYSSN=$P(tblrec,"|",20)
	I (SYSSN="") S SYSSN="PBS"
	;
	N scasys S scasys=$$vDb8(SYSSN)
	;
	S vret=$P(scasys,$C(124),7) Q vret
	;
DSTMDD(MDDFID,MDDREF)	;
	;
	N mddrec S mddrec=$$vDb9("SYSDEV",MDDFID,MDDREF)
	;
	N rs,vos1,vos2 S rs=$$vOpen9()
	;
	F  Q:'($$vFetch9())  D
	.	;
	.	N FID
	.	;
	.	S FID=rs
	.	Q:($$MDD(FID)'=MDDFID) 
	.	;
	.	N ds,vos3,vos4,vos5,vos6 S ds=$$vOpen10()
	.	;
	.	F  Q:'($$vFetch10())  D
	..		;
	..		N hit S hit=0
	..		;
	..		N dbtbl1d S dbtbl1d=$$vDb3($P(ds,$C(9),1),$P(ds,$C(9),2),$P(ds,$C(9),3))
	..		;
	..		I $P(vobj(dbtbl1d),$C(124),2)'=$P(mddrec,$C(124),2) D
	...			;
	...		 S:'$D(vobj(dbtbl1d,-100,"0*","LEN")) vobj(dbtbl1d,-100,"0*","LEN")="N002"_$P(vobj(dbtbl1d),$C(124),2) S vobj(dbtbl1d,-100,"0*")="",$P(vobj(dbtbl1d),$C(124),2)=$P(mddrec,$C(124),2)
	...			S hit=1
	...			Q 
	..		I $P(vobj(dbtbl1d),$C(124),4)'=$P(mddrec,$C(124),4) D
	...			;
	...		 S:'$D(vobj(dbtbl1d,-100,"0*","DOM")) vobj(dbtbl1d,-100,"0*","DOM")="U004"_$P(vobj(dbtbl1d),$C(124),4) S vobj(dbtbl1d,-100,"0*")="",$P(vobj(dbtbl1d),$C(124),4)=$P(mddrec,$C(124),4)
	...			S hit=1
	...			Q 
	..		I $P(vobj(dbtbl1d),$C(124),9)'=$P(mddrec,$C(124),9) D
	...			;
	...		 S:'$D(vobj(dbtbl1d,-100,"0*","TYP")) vobj(dbtbl1d,-100,"0*","TYP")="U009"_$P(vobj(dbtbl1d),$C(124),9) S vobj(dbtbl1d,-100,"0*")="",$P(vobj(dbtbl1d),$C(124),9)=$P(mddrec,$C(124),9)
	...			S hit=1
	...			Q 
	..		I $P(vobj(dbtbl1d),$C(124),10)'=$P(mddrec,$C(124),10) D
	...			;
	...		 S:'$D(vobj(dbtbl1d,-100,"0*","DES")) vobj(dbtbl1d,-100,"0*","DES")="T010"_$P(vobj(dbtbl1d),$C(124),10) S vobj(dbtbl1d,-100,"0*")="",$P(vobj(dbtbl1d),$C(124),10)=$P(mddrec,$C(124),10)
	...			S hit=1
	...			Q 
	..		I $P(vobj(dbtbl1d),$C(124),11)'=$P(mddrec,$C(124),11) D
	...			;
	...		 S:'$D(vobj(dbtbl1d,-100,"0*","ITP")) vobj(dbtbl1d,-100,"0*","ITP")="T011"_$P(vobj(dbtbl1d),$C(124),11) S vobj(dbtbl1d,-100,"0*")="",$P(vobj(dbtbl1d),$C(124),11)=$P(mddrec,$C(124),11)
	...			S hit=1
	...			Q 
	..		I $P(vobj(dbtbl1d),$C(124),14)'=$P(mddrec,$C(124),14) D
	...			;
	...		 S:'$D(vobj(dbtbl1d,-100,"0*","DEC")) vobj(dbtbl1d,-100,"0*","DEC")="N014"_$P(vobj(dbtbl1d),$C(124),14) S vobj(dbtbl1d,-100,"0*")="",$P(vobj(dbtbl1d),$C(124),14)=$P(mddrec,$C(124),14)
	...			S hit=1
	...			Q 
	..		I $P(vobj(dbtbl1d),$C(124),19)'=$P(mddrec,$C(124),19) D
	...			;
	...		 S:'$D(vobj(dbtbl1d,-100,"0*","SIZ")) vobj(dbtbl1d,-100,"0*","SIZ")="N019"_$P(vobj(dbtbl1d),$C(124),19) S vobj(dbtbl1d,-100,"0*")="",$P(vobj(dbtbl1d),$C(124),19)=$P(mddrec,$C(124),19)
	...			S hit=1
	...			Q 
	..		I $P(vobj(dbtbl1d),$C(124),22)'=$P(mddrec,$C(124),22) D
	...			;
	...		 S:'$D(vobj(dbtbl1d,-100,"0*","RHD")) vobj(dbtbl1d,-100,"0*","RHD")="T022"_$P(vobj(dbtbl1d),$C(124),22) S vobj(dbtbl1d,-100,"0*")="",$P(vobj(dbtbl1d),$C(124),22)=$P(mddrec,$C(124),22)
	...			S hit=1
	...			Q 
	..		I $P(vobj(dbtbl1d),$C(124),28)'=$P(mddrec,$C(124),28) D
	...			;
	...		 S:'$D(vobj(dbtbl1d,-100,"0*","VAL4EXT")) vobj(dbtbl1d,-100,"0*","VAL4EXT")="L028"_$P(vobj(dbtbl1d),$C(124),28) S vobj(dbtbl1d,-100,"0*")="",$P(vobj(dbtbl1d),$C(124),28)=$P(mddrec,$C(124),28)
	...			S hit=1
	...			Q 
	..		;
	..		I hit N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^DBSDFF(dbtbl1d,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(dbtbl1d,-100) S vobj(dbtbl1d,-2)=1 Tcommit:vTp  
	..		K vobj(+$G(dbtbl1d)) Q 
	.	Q 
	;
	Q 
	;
vSIG()	;
	Q "60751^54656^Badrinath Giridharan^16760" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM DBTBL1TBLDOC WHERE %LIBS='SYSDEV' AND FID=:FID
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Tstart (vobj):transactionid="CS"
	N vDs,vos1,vos2,vos3 S vDs=$$vOpen11()
	F  Q:'($$vFetch11())  D
	.	N vRec S vRec=$$vDb4($P(vDs,$C(9),1),$P(vDs,$C(9),2),$P(vDs,$C(9),3))
	.	S vobj(vRec,-2)=3
	.	D ^TBLDOCFL(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1)
	.	K vobj(+$G(vRec)) Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe2()	; DELETE FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:FID
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Tstart (vobj):transactionid="CS"
	N vDs,vos1,vos2,vos3 S vDs=$$vOpen12()
	F  Q:'($$vFetch12())  D
	.	N vRec S vRec=$$vDb3($P(vDs,$C(9),1),$P(vDs,$C(9),2),$P(vDs,$C(9),3))
	.	S vobj(vRec,-2)=3
	.	D ^DBSDFF(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1)
	.	K vobj(+$G(vRec)) Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe3()	; DELETE FROM DBTBL1 WHERE %LIBS='SYSDEV' AND FID=:FID
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Tstart (vobj):transactionid="CS"
	N vRec S vRec=$$vDb1("SYSDEV",FID)
	I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D ^DBSDF1F(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1)
	Tcommit:$Tlevel 
	K vobj(+$G(vRec)) Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe4()	; DELETE FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:CHILDFID AND DI=:COLNAME
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Tstart (vobj):transactionid="CS"
	N vRec S vRec=$$vDb3("SYSDEV",CHILDFID,COLNAME)
	I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D ^DBSDFF(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1)
	Tcommit:$Tlevel 
	K vobj(+$G(vRec)) Q 
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ","ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ")
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(DBTBL1,,1)
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
vDb2(v1,v2)	;	vobj()=Db.getRecord(DBTBL1,,0)
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
vDb3(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL1D,,1)
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
vDb4(v1,v2,v3)	;	vobj()=Db.getRecord(DBTBL1TBLDOC,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL1TBLDOC"
	S vobj(vOid)=$G(^DBTBL(v1,1,v2,0,v3))
	I vobj(vOid)="",'$D(^DBTBL(v1,1,v2,0,v3))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDb7(v1,v2)	;	voXN = Db.getRecord(DBTBL1,,0)
	;
	N dbtbl1
	S dbtbl1=$G(^DBTBL(v1,1,v2))
	I dbtbl1="",'$D(^DBTBL(v1,1,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1" X $ZT
	Q dbtbl1
	;
vDb8(v1)	;	voXN = Db.getRecord(SCASYS,,0)
	;
	N scasys
	S scasys=$G(^SCATBL(2,v1))
	I scasys="",'$D(^SCATBL(2,v1))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,SCASYS" X $ZT
	Q scasys
	;
vDb9(v1,v2,v3)	;	voXN = Db.getRecord(DBTBL1D,,0)
	;
	N mddrec
	S mddrec=$G(^DBTBL(v1,1,v2,9,v3))
	I mddrec="",'$D(^DBTBL(v1,1,v2,9,v3))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1D" X $ZT
	Q mddrec
	;
vDbNew1(v1,v2,v3)	;	vobj()=Class.new(DBTBL1TBLDOC)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL1TBLDOC",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vDbNew2(v1,v2,v3)	;	vobj()=Class.new(DBTBL1D)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL1D",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	S vobj(vOid,-5)=v3
	Q vOid
	;
vOpen0(exe,vsql,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist)	;	Dynamic MDB ResultSet
	;
	set sqlcur="DELETE.rsdata"
	N ER,vExpr,mode,RM,vTok S ER=0 ;=noOpti
	;
	S vExpr="SELECT "_vSelect_" FROM "_vFrom
	I vWhere'="" S vExpr=vExpr_" WHERE "_vWhere
	I vOrderby'="" S vExpr=vExpr_" ORDER BY "_vOrderby
	I vGroupby'="" S vExpr=vExpr_" GROUP BY "_vGroupby
	S vExpr=$$UNTOK^%ZS($$SQL^%ZS(vExpr,.vTok),vTok)
	;
	S sqlcur=$O(vobj(""),-1)+1
	;
	I $$FLT^SQLCACHE(vExpr,vTok,.vParlist)
	E  S vsql=$$OPEN^SQLM(.exe,vFrom,vSelect,vWhere,vOrderby,vGroupby,vParlist,,1,,sqlcur) I 'ER D SAV^SQLCACHE(vExpr,.vParlist)
	I ER S $ZS="-1,"_$ZPOS_",%PSL-E-SQLFAIL,"_$TR($G(RM),$C(10,44),$C(32,126)) X $ZT
	;
	S vos10=vsql
	Q ""
	;
vFetch0()	; MDB dynamic FETCH
	;
	; type public String exe(),sqlcur,vd,vi,vsql()
	;
	I vsql=0 Q 0
	S vsql=$$^SQLF(.exe,.vd,.vi,.sqlcur)
	S rsdata=vd
	S vos10=vsql
	S vos11=$G(vi)
	Q vsql
	;
vOpen1()	;	SEQ,DES FROM DBTBL1TBLDOC WHERE %LIBS='SYSDEV' AND FID=:FID ORDER BY SEQ ASC
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=$G(FID) I vos2="" G vL1a0
	S vos3=""
vL1a3	S vos3=$O(^DBTBL("SYSDEV",1,vos2,0,vos3),1) I vos3="" G vL1a0
	Q
	;
vFetch1()	;
	;
	I vos1=1 D vL1a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos4=$G(^DBTBL("SYSDEV",1,vos2,0,vos3))
	S rs=$S(vos3=$C(254):"",1:vos3)_$C(9)_$P(vos4,"|",1)
	;
	Q 1
	;
vOpen10()	;	%LIBS,FID,DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:FID AND MDD=:MDDREF
	;
	;
	S vos3=2
	D vL10a1
	Q ""
	;
vL10a0	S vos3=0 Q
vL10a1	S vos4=$G(FID) I vos4="" G vL10a0
	S vos5=$G(MDDREF) I vos5="",'$D(MDDREF) G vL10a0
	S vos6=""
vL10a4	S vos6=$O(^DBINDX("SYSDEV","MDD",vos5,vos4,vos6),1) I vos6="" G vL10a0
	Q
	;
vFetch10()	;
	;
	;
	I vos3=1 D vL10a4
	I vos3=2 S vos3=1
	;
	I vos3=0 Q 0
	;
	S ds="SYSDEV"_$C(9)_vos4_$C(9)_$S(vos6=$C(254):"",1:vos6)
	;
	Q 1
	;
vOpen11()	;	%LIBS,FID,SEQ FROM DBTBL1TBLDOC WHERE %LIBS='SYSDEV' AND FID=:FID
	;
	;
	S vos1=2
	D vL11a1
	Q ""
	;
vL11a0	S vos1=0 Q
vL11a1	S vos2=$G(FID) I vos2="" G vL11a0
	S vos3=""
vL11a3	S vos3=$O(^DBTBL("SYSDEV",1,vos2,0,vos3),1) I vos3="" G vL11a0
	Q
	;
vFetch11()	;
	;
	;
	I vos1=1 D vL11a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vDs="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen12()	;	%LIBS,FID,DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:FID
	;
	;
	S vos1=2
	D vL12a1
	Q ""
	;
vL12a0	S vos1=0 Q
vL12a1	S vos2=$G(FID) I vos2="" G vL12a0
	S vos3=""
vL12a3	S vos3=$O(^DBTBL("SYSDEV",1,vos2,9,vos3),1) I vos3="" G vL12a0
	Q
	;
vFetch12()	;
	;
	;
	I vos1=1 D vL12a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vDs="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen2()	;	FID FROM DBTBL8 WHERE %LIBS='SYSDEV' AND FID=:FID
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(FID) I vos2="" G vL2a0
	S vos3=""
vL2a3	S vos3=$O(^DBTBL("SYSDEV",8,vos2,vos3),1) I vos3="" G vL2a0
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
	S rsindex=vos2
	;
	Q 1
	;
vOpen3()	;	FID FROM DBTBL1F WHERE %LIBS='SYSDEV' AND FID=:FID
	;
	;
	S vos4=2
	D vL3a1
	Q ""
	;
vL3a0	S vos4=0 Q
vL3a1	S vos5=$G(FID) I vos5="" G vL3a0
	S vos6=""
vL3a3	S vos6=$O(^DBTBL("SYSDEV",19,vos5,vos6),1) I vos6="" G vL3a0
	Q
	;
vFetch3()	;
	;
	;
	I vos4=1 D vL3a3
	I vos4=2 S vos4=1
	;
	I vos4=0 Q 0
	;
	S rsfkey=vos5
	;
	Q 1
	;
vOpen4()	;	DISTINCT FID FROM DBTBL1F WHERE %LIBS='SYSDEV' AND TBLREF=:FID
	;
	;
	S vos7=2
	D vL4a1
	Q ""
	;
vL4a0	S vos7=0 Q
vL4a1	S vos8=$G(FID) I vos8="",'$D(FID) G vL4a0
	S vos9=""
vL4a3	S vos9=$O(^DBINDX("SYSDEV","FKPTR",vos8,vos9),1) I vos9="" G vL4a0
	Q
	;
vFetch4()	;
	;
	;
	I vos7=1 D vL4a3
	I vos7=2 S vos7=1
	;
	I vos7=0 Q 0
	;
	S rsfkey2=$S(vos9=$C(254):"",1:vos9)
	;
	Q 1
	;
vOpen5()	;	%LIBS,FID,DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:FID
	;
	;
	S vos1=2
	D vL5a1
	Q ""
	;
vL5a0	S vos1=0 Q
vL5a1	S vos2=$G(FID) I vos2="" G vL5a0
	S vos3=""
vL5a3	S vos3=$O(^DBTBL("SYSDEV",1,vos2,9,vos3),1) I vos3="" G vL5a0
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
vOpen6()	;	%LIBS,FID,SEQ FROM DBTBL1TBLDOC WHERE %LIBS='SYSDEV' AND FID=:FID
	;
	;
	S vos4=2
	D vL6a1
	Q ""
	;
vL6a0	S vos4=0 Q
vL6a1	S vos5=$G(FID) I vos5="" G vL6a0
	S vos6=""
vL6a3	S vos6=$O(^DBTBL("SYSDEV",1,vos5,0,vos6),1) I vos6="" G vL6a0
	Q
	;
vFetch6()	;
	;
	;
	I vos4=1 D vL6a3
	I vos4=2 S vos4=1
	;
	I vos4=0 Q 0
	;
	S dsdoc="SYSDEV"_$C(9)_vos5_$C(9)_$S(vos6=$C(254):"",1:vos6)
	;
	Q 1
	;
vOpen7()	;	%LIBS,FID,DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:PARFID
	;
	;
	S vos1=2
	D vL7a1
	Q ""
	;
vL7a0	S vos1=0 Q
vL7a1	S vos2=$G(PARFID) I vos2="" G vL7a0
	S vos3=""
vL7a3	S vos3=$O(^DBTBL("SYSDEV",1,vos2,9,vos3),1) I vos3="" G vL7a0
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
	S ds="SYSDEV"_$C(9)_vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen8()	;	DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:PARFID
	;
	;
	S vos1=2
	D vL8a1
	Q ""
	;
vL8a0	S vos1=0 Q
vL8a1	S vos2=$G(PARFID) I vos2="" G vL8a0
	S vos3=""
vL8a3	S vos3=$O(^DBTBL("SYSDEV",1,vos2,9,vos3),1) I vos3="" G vL8a0
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
	S rs=$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen9()	;	FID FROM DBTBL1 WHERE %LIBS='SYSDEV'
	;
	;
	S vos1=2
	D vL9a1
	Q ""
	;
vL9a0	S vos1=0 Q
vL9a1	S vos2=""
vL9a2	S vos2=$O(^DBTBL("SYSDEV",1,vos2),1) I vos2="" G vL9a0
	Q
	;
vFetch9()	;
	;
	;
	I vos1=1 D vL9a2
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos2=$C(254):"",1:vos2)
	;
	Q 1
	;
vReCp1(v1)	;	RecordDBTBL1.copy: DBTBL1
	;
	N vNod,vOid
	I $G(vobj(v1,-2)) D
	.	F vNod=0,1,2,3,4,5,6,7,10,12,13,14,16,22,99,100,101,102 S:'$D(vobj(v1,vNod)) vobj(v1,vNod)=$G(^DBTBL(vobj(v1,-3),1,vobj(v1,-4),vNod))
	S vOid=$$copy^UCGMR(v1)
	Q vOid
	;
vReCp2(v1)	;	RecordDBTBL1D.copy: DBTBL1D
	;
	Q $$copy^UCGMR(dbtbl1d)
	;
vReCp3(v1)	;	RecordDBTBL1TBLDOC.copy: DBTBL1TBLDOC
	;
	Q $$copy^UCGMR(tbldoc)
	;
vReCp4(v1)	;	RecordDBTBL1D.copy: DBTBL1D
	;
	Q $$copy^UCGMR(dbtbl1dp)
