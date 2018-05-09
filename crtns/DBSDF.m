 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSDF ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSDF ; 
 ;
 Q  ; No entry from top
 ;
CREATE ; 
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
MODIFY ; 
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
HEADER(%O,FID) ; Table name
 N vTp
 ;
 N VFMQ
 ;
 N fDBTBL1 S fDBTBL1=$$vRCgetRecord1^RecordDBTBL1("SYSDEV",FID,0)
  S vobj(fDBTBL1,10)=$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),10))
  S vobj(fDBTBL1,100)=$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),100))
  S vobj(fDBTBL1,12)=$G(^DBTBL(vobj(fDBTBL1,-3),1,vobj(fDBTBL1,-4),12))
 ;
 ; Set defaults for screen
 I ($G(vobj(fDBTBL1,-2))=0) D
 .	;
 .  S vobj(fDBTBL1,-100,10)="" S $P(vobj(fDBTBL1,10),$C(124),2)="PBS"
 .  S vobj(fDBTBL1,-100,10)="" S $P(vobj(fDBTBL1,10),$C(124),3)=0
 .  S vobj(fDBTBL1,-100,100)="" S $P(vobj(fDBTBL1,100),$C(124),2)=1
 .  S:'$D(vobj(fDBTBL1,-100,12,"FSN")) vobj(fDBTBL1,-100,12,"FSN")="T001"_$P(vobj(fDBTBL1,12),$C(124),1),vobj(fDBTBL1,-100,12)="" S $P(vobj(fDBTBL1,12),$C(124),1)="f"_$translate($E(FID,1,7),"_","z")
 .	Q 
 ;
 ;  #ACCEPT Date=11/02/06; Pgm=RussellDS; CR=22719; Group=MISMATCH
 N vo2 N vo3 N vo4 N vo5 D DRV^USID(%O,"DBTBL1",.fDBTBL1,.vo2,.vo3,.vo4,.vo5) K vobj(+$G(vo2)) K vobj(+$G(vo3)) K vobj(+$G(vo4)) K vobj(+$G(vo5))
 ;
 I VFMQ="Q" K vobj(+$G(fDBTBL1)) Q 0
 ;
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL1(fDBTBL1,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(fDBTBL1,-100) S vobj(fDBTBL1,-2)=1 TC:vTp  
 ;
 K vobj(+$G(fDBTBL1)) Q 1
 ;
DOC(FID) ; 
 N vpc,vTp
 ;
 N cnt N seq N WIDTH
 N DATA N MSG
 ;
 N rs,vos1,vos2,vos3,vos4,vos5 S rs=$$vOpen1()
 ;
 S WIDTH=80
 S cnt=0
 F  Q:'$$vFetch1()  D
 .	;
 .	S cnt=cnt+1
 . S DATA(cnt)=$P(rs,$C(9),2)
 .	I $L(DATA(cnt))>78 S WIDTH=132
 .	Q 
 ;
 ; ~p1~p2] - File Documentation
 S MSG=$$^MSG(7082,"[",FID)
 D ^DBSWRITE("DATA",3,22,99999,WIDTH,MSG)
 ;
 S vpc='$D(DATA) Q:vpc 
 ;
 ; Remove any old records
 D vDbDe1()
 ;
 ; Save new records
 S cnt=""
 S seq=1
 F  S cnt=$order(DATA(cnt)) Q:(cnt="")  D
 .	;
 .	N tbldoc S tbldoc=$$vcdmNew^RecordDBTBL1TBLDOC() S vobj(tbldoc,-3)="SYSDEV" S vobj(tbldoc,-4)=FID S vobj(tbldoc,-5)=seq
 .	;
 .  S $P(vobj(tbldoc),$C(124),1)=DATA(cnt)
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL1TBLDOC(tbldoc,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(tbldoc,-100) S vobj(tbldoc,-2)=1 TC:vTp  
 .	;
 .	S seq=seq+1
 .	K vobj(+$G(tbldoc)) Q 
 ;
 Q 
 ;
DELETE ; 
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
 .	N rsindex,vos1,vos2,vos3,vos4 S rsindex=$$vOpen2()
 .	N rsfkey,vos5,vos6,vos7,vos8 S rsfkey=$$vOpen3()
 .	;
 . I $$vFetch2()!$$vFetch3() D  Q 
 ..		;
 ..		S ER=1
 ..		; Index or foreign key definition exists.  Delete before continuing.
 ..		S RM=$$^MSG(744)
 ..		Q 
 .	;
 .	N rsfkey2,vos9,vos10,vos11,vos12 S rsfkey2=$$vOpen4()
 .	;
 . I $$vFetch4() D  Q 
 ..		;
 ..		S ER=1
 ..		; ~p1 foreign key definition references ~p2
 ..  S RM=$$^MSG(906,rsfkey2,FID)
 ..		Q 
 .	;
 .	N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=FID,dbtbl1=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",FID,0,"")
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
 .	N rsdata,vos13,vos14,sqlcur,exe,sqlcur,vd,vi,vsql,vsub S rsdata=$$vOpen0(.exe,.vsql,keys,FID,"","","","",1)
 .	;
 . I '$G(vos13) S deldata=0
 . E  D  Q:stop 
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
 . I (+$$^DBSMBAR(164)'=+2) Q 
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
 . Q 
 ;
 Q 
 ;
COPY ; 
 N vpc,vTp
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
 .	N fDBTBL1 S fDBTBL1=$$vRCgetRecord0^RecordDBTBL1("SYSDEV",FID,0)
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
 .	D ^UTLREAD S vpc=(VFMQ'="F") K:vpc vobj(+$G(fDBTBL1)) Q:vpc 
 .	;
 .	N dbtbl1 S dbtbl1=$$vRCgetRecord0^RecordDBTBL1("SYSDEV",FID,0)
 .	N dbtbl1c S dbtbl1c=$$vReCp1(dbtbl1)
 .	;
 .  S vobj(dbtbl1c,-4)=TOFID
 .  S:'$D(vobj(dbtbl1c,-100,10,"PARFID")) vobj(dbtbl1c,-100,10,"PARFID")="U004"_$P(vobj(dbtbl1c,10),$C(124),4),vobj(dbtbl1c,-100,10)="" S $P(vobj(dbtbl1c,10),$C(124),4)="" ; Supertype file
 .	;
 .	S vobj(dbtbl1c,-2)=0
 . S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL1(dbtbl1c,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbtbl1c,-100) S vobj(dbtbl1c,-2)=1 TC:vTp  
 .	;
 .	N ds,vos1,vos2,vos3,vos4 S ds=$$vOpen5()
 .	;
 .	F  Q:'$$vFetch5()  D
 ..		;
 ..  N dbtbl1d S dbtbl1d=$$vRCgetRecord1^RecordDBTBL1D($P(ds,$C(9),1),$P(ds,$C(9),2),$P(ds,$C(9),3),1)
 ..		N dbtbl1dc S dbtbl1dc=$$vReCp2(dbtbl1d)
 ..		;
 ..	  S vobj(dbtbl1dc,-4)=TOFID
 ..		;
 ..		; Key columns are created by DBTBL1 filer, so just update them
 ..		 N V1 S V1=vobj(dbtbl1d,-5) I '($D(^DBTBL("SYSDEV",1,TOFID,9,V1))#2) D
 ...			;
 ...			S vobj(dbtbl1dc,-2)=0
 ...			Q 
 ..		E  S vobj(dbtbl1dc,-2)=1
 ..		;
 ..	 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL1D(dbtbl1dc,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbtbl1dc,-100) S vobj(dbtbl1dc,-2)=1 TC:vTp  
 ..		K vobj(+$G(dbtbl1d)),vobj(+$G(dbtbl1dc)) Q 
 .	;
 .	N dsdoc,vos5,vos6,vos7,vos8 S dsdoc=$$vOpen6()
 .	;
 .	F  Q:'$$vFetch6()  D
 ..		;
 ..  N tbldoc S tbldoc=$$vRCgetRecord1^RecordDBTBL1TBLDOC($P(dsdoc,$C(9),1),$P(dsdoc,$C(9),2),$P(dsdoc,$C(9),3),1)
 ..		N tbldocc S tbldocc=$$vReCp3(tbldoc)
 ..		;
 ..	  S vobj(tbldocc,-4)=TOFID
 ..		;
 ..		S vobj(tbldocc,-2)=0
 ..	 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL1TBLDOC(tbldocc,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(tbldocc,-100) S vobj(tbldocc,-2)=1 TC:vTp  
 ..		K vobj(+$G(tbldoc)),vobj(+$G(tbldocc)) Q 
 . K vobj(+$G(dbtbl1)),vobj(+$G(dbtbl1c)),vobj(+$G(fDBTBL1)) Q 
 ;
 Q 
 ;
COPYPP ; Copy to prompt post-processor
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
COLUMNS(FID) ; Table name
 N vTp
 ;
 N DELETE N isDone
 N nodpos N DI N VFMQ
 ;
 S isDone=0
 ;
 N fDBTBL1 S fDBTBL1=$$vRCgetRecord0^RecordDBTBL1("SYSDEV",FID,0)
 ;
 F  D  Q:isDone 
 .	;
 .	N RM
 .	;
 .	S DELETE=0
 .	S DI=""
 .	;
 .	N fDBTBL1D S fDBTBL1D=$$vcdmNew^RecordDBTBL1D()
 .	;
 .	;   #ACCEPT Date=11/02/06; Pgm=RussellDS; CR=22719; Group=MISMATCH
 . N vo10 N vo11 N vo12 D DRV^USID(0,"DBTBL1D",.fDBTBL1D,.fDBTBL1,.vo10,.vo11,.vo12) K vobj(+$G(vo10)) K vobj(+$G(vo11)) K vobj(+$G(vo12))
 .	;
 .	I (VFMQ="F") D
 ..		;
 ..		I DELETE D
 ...			;
 ...			 N V1,V2 S V1=vobj(fDBTBL1D,-4),V2=vobj(fDBTBL1D,-5) D vDbDe4()
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
 ...		 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL1D(fDBTBL1D,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(fDBTBL1D,-100) S vobj(fDBTBL1D,-2)=1 TC:vTp  
 ...			Q 
 ..		Q 
 .	;
 .	; Continue?
 .	I '$$YN^DBSMBAR("",$$^MSG(603),1) S isDone=1
 .	K vobj(+$G(fDBTBL1D)) Q 
 ;
 K vobj(+$G(fDBTBL1)) Q 
 ;
PARCOPY(PARFID,CHILDFID) ; Child table
 N vTp
 ;
 N ds,vos1,vos2,vos3,vos4 S ds=$$vOpen7()
 ;
 F  Q:'$$vFetch7()  D
 .	;
 .	N COLNAME
 .	;
 . N dbtbl1dp S dbtbl1dp=$$vRCgetRecord1^RecordDBTBL1D($P(ds,$C(9),1),$P(ds,$C(9),2),$P(ds,$C(9),3),1)
 .	;
 .	S COLNAME=vobj(dbtbl1dp,-5)
 .	;
 .	N dbtbl1dc S dbtbl1dc=$$vRCgetRecord1^RecordDBTBL1D("SYSDEV",CHILDFID,COLNAME,0)
 .	;
 .	I ($G(vobj(dbtbl1dc,-2))=0) D
 ..		;
 ..	  K vobj(+$G(dbtbl1dc)) S dbtbl1dc=$$vReCp4(dbtbl1dp)
 ..		;
 ..	  S vobj(dbtbl1dc,-4)=CHILDFID
 ..		;
 ..		S vobj(dbtbl1dc,-2)=0
 ..	 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL1D(dbtbl1dc,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbtbl1dc,-100) S vobj(dbtbl1dc,-2)=1 TC:vTp  
 ..		Q 
 .	;
 .	E  D
 ..		;
 ..		N hit S hit=0
 ..		;
 ..		I $P(vobj(dbtbl1dc),$C(124),1)'=$P(vobj(dbtbl1dp),$C(124),1) D
 ...			;
 ...		  S:'$D(vobj(dbtbl1dc,-100,"0*","NOD")) vobj(dbtbl1dc,-100,"0*","NOD")="T001"_$P(vobj(dbtbl1dc),$C(124),1),vobj(dbtbl1dc,-100,"0*")="" S $P(vobj(dbtbl1dc),$C(124),1)=$P(vobj(dbtbl1dp),$C(124),1)
 ...			S hit=1
 ...			Q 
 ..		I $P(vobj(dbtbl1dc),$C(124),2)'=$P(vobj(dbtbl1dp),$C(124),2) D
 ...			;
 ...		  S:'$D(vobj(dbtbl1dc,-100,"0*","LEN")) vobj(dbtbl1dc,-100,"0*","LEN")="N002"_$P(vobj(dbtbl1dc),$C(124),2),vobj(dbtbl1dc,-100,"0*")="" S $P(vobj(dbtbl1dc),$C(124),2)=$P(vobj(dbtbl1dp),$C(124),2)
 ...			S hit=1
 ...			Q 
 ..		I $P(vobj(dbtbl1dc),$C(124),3)'=$P(vobj(dbtbl1dp),$C(124),3) D
 ...			;
 ...		  S:'$D(vobj(dbtbl1dc,-100,"0*","DFT")) vobj(dbtbl1dc,-100,"0*","DFT")="T003"_$P(vobj(dbtbl1dc),$C(124),3),vobj(dbtbl1dc,-100,"0*")="" S $P(vobj(dbtbl1dc),$C(124),3)=$P(vobj(dbtbl1dp),$C(124),3)
 ...			S hit=1
 ...			Q 
 ..		I $P(vobj(dbtbl1dc),$C(124),4)'=$P(vobj(dbtbl1dp),$C(124),4) D
 ...			;
 ...		  S:'$D(vobj(dbtbl1dc,-100,"0*","DOM")) vobj(dbtbl1dc,-100,"0*","DOM")="U004"_$P(vobj(dbtbl1dc),$C(124),4),vobj(dbtbl1dc,-100,"0*")="" S $P(vobj(dbtbl1dc),$C(124),4)=$P(vobj(dbtbl1dp),$C(124),4)
 ...			S hit=1
 ...			Q 
 ..		I $P(vobj(dbtbl1dc),$C(124),9)'=$P(vobj(dbtbl1dp),$C(124),9) D
 ...			;
 ...		  S:'$D(vobj(dbtbl1dc,-100,"0*","TYP")) vobj(dbtbl1dc,-100,"0*","TYP")="U009"_$P(vobj(dbtbl1dc),$C(124),9),vobj(dbtbl1dc,-100,"0*")="" S $P(vobj(dbtbl1dc),$C(124),9)=$P(vobj(dbtbl1dp),$C(124),9)
 ...			S hit=1
 ...			Q 
 ..		I $P(vobj(dbtbl1dc),$C(124),10)'=$P(vobj(dbtbl1dp),$C(124),10) D
 ...			;
 ...		  S:'$D(vobj(dbtbl1dc,-100,"0*","DES")) vobj(dbtbl1dc,-100,"0*","DES")="T010"_$P(vobj(dbtbl1dc),$C(124),10),vobj(dbtbl1dc,-100,"0*")="" S $P(vobj(dbtbl1dc),$C(124),10)=$P(vobj(dbtbl1dp),$C(124),10)
 ...			S hit=1
 ...			Q 
 ..		I $P(vobj(dbtbl1dc),$C(124),11)'=$P(vobj(dbtbl1dp),$C(124),11) D
 ...			;
 ...		  S:'$D(vobj(dbtbl1dc,-100,"0*","ITP")) vobj(dbtbl1dc,-100,"0*","ITP")="T011"_$P(vobj(dbtbl1dc),$C(124),11),vobj(dbtbl1dc,-100,"0*")="" S $P(vobj(dbtbl1dc),$C(124),11)=$P(vobj(dbtbl1dp),$C(124),11)
 ...			S hit=1
 ...			Q 
 ..		I $P(vobj(dbtbl1dc),$C(124),14)'=$P(vobj(dbtbl1dp),$C(124),14) D
 ...			;
 ...		  S:'$D(vobj(dbtbl1dc,-100,"0*","DEC")) vobj(dbtbl1dc,-100,"0*","DEC")="N014"_$P(vobj(dbtbl1dc),$C(124),14),vobj(dbtbl1dc,-100,"0*")="" S $P(vobj(dbtbl1dc),$C(124),14)=$P(vobj(dbtbl1dp),$C(124),14)
 ...			S hit=1
 ...			Q 
 ..		I $P(vobj(dbtbl1dc),$C(124),16)'=$P(vobj(dbtbl1dp),$C(124),16) D
 ...			;
 ...		  S:'$D(vobj(dbtbl1dc,-100,"0*","CMP")) vobj(dbtbl1dc,-100,"0*","CMP")="T016"_$P(vobj(dbtbl1dc),$C(124),16),vobj(dbtbl1dc,-100,"0*")="" S $P(vobj(dbtbl1dc),$C(124),16)=$P(vobj(dbtbl1dp),$C(124),16)
 ...			S hit=1
 ...			Q 
 ..		I $P(vobj(dbtbl1dc),$C(124),17)'=$P(vobj(dbtbl1dp),$C(124),17) D
 ...			;
 ...		  S:'$D(vobj(dbtbl1dc,-100,"0*","ISMASTER")) vobj(dbtbl1dc,-100,"0*","ISMASTER")="L017"_$P(vobj(dbtbl1dc),$C(124),17),vobj(dbtbl1dc,-100,"0*")="" S $P(vobj(dbtbl1dc),$C(124),17)=$P(vobj(dbtbl1dp),$C(124),17)
 ...			S hit=1
 ...			Q 
 ..		I $P(vobj(dbtbl1dc),$C(124),18)'=$P(vobj(dbtbl1dp),$C(124),18) D
 ...			;
 ...		  N vSetMf S vSetMf=$P(vobj(dbtbl1dc),$C(124),18) S:'$D(vobj(dbtbl1dc,-100,"0*","SFD1")) vobj(dbtbl1dc,-100,"0*","SFD1")="N018"_$P(vSetMf,$C(126),2)_"||~126~~2" S:'$D(vobj(dbtbl1dc,-100,"0*","SFD2")) vobj(dbtbl1dc,-100,"0*","SFD2")="N018"_$P(vSetMf,$C(126),3)_"||~126~~3" S:'$D(vobj(dbtbl1dc,-100,"0*","SFP")) vobj(dbtbl1dc,-100,"0*","SFP")="N018"_$P(vSetMf,$C(126),4)_"||~126~~4" S:'$D(vobj(dbtbl1dc,-100,"0*","SFT")) vobj(dbtbl1dc,-100,"0*","SFT")="U018"_$P(vSetMf,$C(126),1)_"||~126~~1" S $P(vobj(dbtbl1dc),$C(124),18)=$P(vobj(dbtbl1dp),$C(124),18),vobj(dbtbl1dc,-100,"0*")=""
 ...			S hit=1
 ...			Q 
 ..		I $P(vobj(dbtbl1dc),$C(124),19)'=$P(vobj(dbtbl1dp),$C(124),19) D
 ...			;
 ...		  S:'$D(vobj(dbtbl1dc,-100,"0*","SIZ")) vobj(dbtbl1dc,-100,"0*","SIZ")="N019"_$P(vobj(dbtbl1dc),$C(124),19),vobj(dbtbl1dc,-100,"0*")="" S $P(vobj(dbtbl1dc),$C(124),19)=$P(vobj(dbtbl1dp),$C(124),19)
 ...			S hit=1
 ...			Q 
 ..		I $P(vobj(dbtbl1dc),$C(124),21)'=$P(vobj(dbtbl1dp),$C(124),21) D
 ...			;
 ...		  S:'$D(vobj(dbtbl1dc,-100,"0*","POS")) vobj(dbtbl1dc,-100,"0*","POS")="N021"_$P(vobj(dbtbl1dc),$C(124),21),vobj(dbtbl1dc,-100,"0*")="" S $P(vobj(dbtbl1dc),$C(124),21)=$P(vobj(dbtbl1dp),$C(124),21)
 ...			S hit=1
 ...			Q 
 ..		I $P(vobj(dbtbl1dc),$C(124),22)'=$P(vobj(dbtbl1dp),$C(124),22) D
 ...			;
 ...		  S:'$D(vobj(dbtbl1dc,-100,"0*","RHD")) vobj(dbtbl1dc,-100,"0*","RHD")="T022"_$P(vobj(dbtbl1dc),$C(124),22),vobj(dbtbl1dc,-100,"0*")="" S $P(vobj(dbtbl1dc),$C(124),22)=$P(vobj(dbtbl1dp),$C(124),22)
 ...			S hit=1
 ...			Q 
 ..		I $P(vobj(dbtbl1dc),$C(124),23)'=$P(vobj(dbtbl1dp),$C(124),23) D
 ...			;
 ...		  S:'$D(vobj(dbtbl1dc,-100,"0*","SRL")) vobj(dbtbl1dc,-100,"0*","SRL")="L023"_$P(vobj(dbtbl1dc),$C(124),23),vobj(dbtbl1dc,-100,"0*")="" S $P(vobj(dbtbl1dc),$C(124),23)=$P(vobj(dbtbl1dp),$C(124),23)
 ...			S hit=1
 ...			Q 
 ..		I $P(vobj(dbtbl1dc),$C(124),24)'=$P(vobj(dbtbl1dp),$C(124),24) D
 ...			;
 ...		  S:'$D(vobj(dbtbl1dc,-100,"0*","CNV")) vobj(dbtbl1dc,-100,"0*","CNV")="N024"_$P(vobj(dbtbl1dc),$C(124),24),vobj(dbtbl1dc,-100,"0*")="" S $P(vobj(dbtbl1dc),$C(124),24)=$P(vobj(dbtbl1dp),$C(124),24)
 ...			S hit=1
 ...			Q 
 ..		I $P(vobj(dbtbl1dc),$C(124),25)'=$P(vobj(dbtbl1dp),$C(124),25) D
 ...			;
 ...		  S:'$D(vobj(dbtbl1dc,-100,"0*","LTD")) vobj(dbtbl1dc,-100,"0*","LTD")="D025"_$P(vobj(dbtbl1dc),$C(124),25),vobj(dbtbl1dc,-100,"0*")="" S $P(vobj(dbtbl1dc),$C(124),25)=$P(vobj(dbtbl1dp),$C(124),25)
 ...			S hit=1
 ...			Q 
 ..		I $P(vobj(dbtbl1dc),$C(124),26)'=$P(vobj(dbtbl1dp),$C(124),26) D
 ...			;
 ...		  S:'$D(vobj(dbtbl1dc,-100,"0*","USER")) vobj(dbtbl1dc,-100,"0*","USER")="T026"_$P(vobj(dbtbl1dc),$C(124),26),vobj(dbtbl1dc,-100,"0*")="" S $P(vobj(dbtbl1dc),$C(124),26)=$P(vobj(dbtbl1dp),$C(124),26)
 ...			S hit=1
 ...			Q 
 ..		I $P(vobj(dbtbl1dc),$C(124),27)'=$P(vobj(dbtbl1dp),$C(124),27) D
 ...			;
 ...		  S:'$D(vobj(dbtbl1dc,-100,"0*","MDD")) vobj(dbtbl1dc,-100,"0*","MDD")="U027"_$P(vobj(dbtbl1dc),$C(124),27),vobj(dbtbl1dc,-100,"0*")="" S $P(vobj(dbtbl1dc),$C(124),27)=$P(vobj(dbtbl1dp),$C(124),27)
 ...			S hit=1
 ...			Q 
 ..		I $P(vobj(dbtbl1dc),$C(124),28)'=$P(vobj(dbtbl1dp),$C(124),28) D
 ...			;
 ...		  S:'$D(vobj(dbtbl1dc,-100,"0*","VAL4EXT")) vobj(dbtbl1dc,-100,"0*","VAL4EXT")="L028"_$P(vobj(dbtbl1dc),$C(124),28),vobj(dbtbl1dc,-100,"0*")="" S $P(vobj(dbtbl1dc),$C(124),28)=$P(vobj(dbtbl1dp),$C(124),28)
 ...			S hit=1
 ...			Q 
 ..		;
 ..		I hit S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL1D(dbtbl1dc,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbtbl1dc,-100) S vobj(dbtbl1dc,-2)=1 TC:vTp  
 ..		Q 
 .	K vobj(+$G(dbtbl1dc)),vobj(+$G(dbtbl1dp)) Q 
 ;
 Q 
 ;
PARDEL(PARFID,CHILDFID) ; Child table
 ;
 N rs,vos1,vos2,vos3,vos4 S rs=$$vOpen8()
 ;
 F  Q:'$$vFetch8()  D
 .	;
 .	N COLNAME
 .	;
 . S COLNAME=rs
 .	;
 .	D vDbDe5()
 .	Q 
 ;
 Q 
 ;
DEDF(FID) ; 
 N vpc,vTp
 ;
 N VFMQ
 ;
 N fDBTBL1 S fDBTBL1=$$vRCgetRecord0^RecordDBTBL1("SYSDEV",FID,0)
 ;
 ;  #ACCEPT Date=11/02/06; Pgm=RussellDS; CR=22719; Group=MISMATCH
 N vo13 N vo14 N vo15 N vo16 D DRV^USID(1,"DBSDBE",.fDBTBL1,.vo13,.vo14,.vo15,.vo16) K vobj(+$G(vo13)) K vobj(+$G(vo14)) K vobj(+$G(vo15)) K vobj(+$G(vo16)) S vpc=(VFMQ="Q") K:vpc vobj(+$G(fDBTBL1)) Q:vpc 
 ;
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL1(fDBTBL1,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(fDBTBL1,-100) S vobj(fDBTBL1,-2)=1 TC:vTp  
 ;
 K vobj(+$G(fDBTBL1)) Q 
 ;
VALIDCMP(FID,DI,CMP,RM) ; Error message or null /NOREQ/MECH=REFNAM:W
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
 S CMPUC=$ZCONVERT(CMP,"U")
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
MDD(FID) ; Table name
 N vret
 ;
 N SYSSN
 ;
 N tblrec S tblrec=$$getSchTbl^UCXDD(FID)
 ;
 S SYSSN=$P(tblrec,"|",20)
 I (SYSSN="") S SYSSN="PBS"
 ;
 N scasys S scasys=$$vRCgetRecord0Opt^RecordSCASYS(SYSSN,0,"")
 ;
 S vret=$P(scasys,$C(124),7) Q vret
 ;
DSTMDD(MDDFID,MDDREF) ; MDD column name
 N vTp
 ;
 N mddrec S mddrec=$$vRCgetRecord0Opt^RecordDBTBL1D("SYSDEV",MDDFID,MDDREF,0,"")
 ;
 N rs,vos1,vos2,vos3 S rs=$$vOpen9()
 ;
 F  Q:'$$vFetch9()  D
 .	;
 .	N FID
 .	;
 . S FID=rs
 .	Q:($$MDD(FID)'=MDDFID) 
 .	;
 .	N ds,vos4,vos5,vos6,vos7,vos8 S ds=$$vOpen10()
 .	;
 .	F  Q:'$$vFetch10()  D
 ..		;
 ..		N hit S hit=0
 ..		;
 ..  N dbtbl1d S dbtbl1d=$$vRCgetRecord1^RecordDBTBL1D($P(ds,$C(9),1),$P(ds,$C(9),2),$P(ds,$C(9),3),1)
 ..		;
 ..		I $P(vobj(dbtbl1d),$C(124),2)'=$P(mddrec,$C(124),2) D
 ...			;
 ...		  S:'$D(vobj(dbtbl1d,-100,"0*","LEN")) vobj(dbtbl1d,-100,"0*","LEN")="N002"_$P(vobj(dbtbl1d),$C(124),2),vobj(dbtbl1d,-100,"0*")="" S $P(vobj(dbtbl1d),$C(124),2)=$P(mddrec,$C(124),2)
 ...			S hit=1
 ...			Q 
 ..		I $P(vobj(dbtbl1d),$C(124),4)'=$P(mddrec,$C(124),4) D
 ...			;
 ...		  S:'$D(vobj(dbtbl1d,-100,"0*","DOM")) vobj(dbtbl1d,-100,"0*","DOM")="U004"_$P(vobj(dbtbl1d),$C(124),4),vobj(dbtbl1d,-100,"0*")="" S $P(vobj(dbtbl1d),$C(124),4)=$P(mddrec,$C(124),4)
 ...			S hit=1
 ...			Q 
 ..		I $P(vobj(dbtbl1d),$C(124),9)'=$P(mddrec,$C(124),9) D
 ...			;
 ...		  S:'$D(vobj(dbtbl1d,-100,"0*","TYP")) vobj(dbtbl1d,-100,"0*","TYP")="U009"_$P(vobj(dbtbl1d),$C(124),9),vobj(dbtbl1d,-100,"0*")="" S $P(vobj(dbtbl1d),$C(124),9)=$P(mddrec,$C(124),9)
 ...			S hit=1
 ...			Q 
 ..		I $P(vobj(dbtbl1d),$C(124),10)'=$P(mddrec,$C(124),10) D
 ...			;
 ...		  S:'$D(vobj(dbtbl1d,-100,"0*","DES")) vobj(dbtbl1d,-100,"0*","DES")="T010"_$P(vobj(dbtbl1d),$C(124),10),vobj(dbtbl1d,-100,"0*")="" S $P(vobj(dbtbl1d),$C(124),10)=$P(mddrec,$C(124),10)
 ...			S hit=1
 ...			Q 
 ..		I $P(vobj(dbtbl1d),$C(124),11)'=$P(mddrec,$C(124),11) D
 ...			;
 ...		  S:'$D(vobj(dbtbl1d,-100,"0*","ITP")) vobj(dbtbl1d,-100,"0*","ITP")="T011"_$P(vobj(dbtbl1d),$C(124),11),vobj(dbtbl1d,-100,"0*")="" S $P(vobj(dbtbl1d),$C(124),11)=$P(mddrec,$C(124),11)
 ...			S hit=1
 ...			Q 
 ..		I $P(vobj(dbtbl1d),$C(124),14)'=$P(mddrec,$C(124),14) D
 ...			;
 ...		  S:'$D(vobj(dbtbl1d,-100,"0*","DEC")) vobj(dbtbl1d,-100,"0*","DEC")="N014"_$P(vobj(dbtbl1d),$C(124),14),vobj(dbtbl1d,-100,"0*")="" S $P(vobj(dbtbl1d),$C(124),14)=$P(mddrec,$C(124),14)
 ...			S hit=1
 ...			Q 
 ..		I $P(vobj(dbtbl1d),$C(124),19)'=$P(mddrec,$C(124),19) D
 ...			;
 ...		  S:'$D(vobj(dbtbl1d,-100,"0*","SIZ")) vobj(dbtbl1d,-100,"0*","SIZ")="N019"_$P(vobj(dbtbl1d),$C(124),19),vobj(dbtbl1d,-100,"0*")="" S $P(vobj(dbtbl1d),$C(124),19)=$P(mddrec,$C(124),19)
 ...			S hit=1
 ...			Q 
 ..		I $P(vobj(dbtbl1d),$C(124),22)'=$P(mddrec,$C(124),22) D
 ...			;
 ...		  S:'$D(vobj(dbtbl1d,-100,"0*","RHD")) vobj(dbtbl1d,-100,"0*","RHD")="T022"_$P(vobj(dbtbl1d),$C(124),22),vobj(dbtbl1d,-100,"0*")="" S $P(vobj(dbtbl1d),$C(124),22)=$P(mddrec,$C(124),22)
 ...			S hit=1
 ...			Q 
 ..		I $P(vobj(dbtbl1d),$C(124),28)'=$P(mddrec,$C(124),28) D
 ...			;
 ...		  S:'$D(vobj(dbtbl1d,-100,"0*","VAL4EXT")) vobj(dbtbl1d,-100,"0*","VAL4EXT")="L028"_$P(vobj(dbtbl1d),$C(124),28),vobj(dbtbl1d,-100,"0*")="" S $P(vobj(dbtbl1d),$C(124),28)=$P(mddrec,$C(124),28)
 ...			S hit=1
 ...			Q 
 ..		;
 ..		I hit S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBTBL1D(dbtbl1d,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(dbtbl1d,-100) S vobj(dbtbl1d,-2)=1 TC:vTp  
 ..		K vobj(+$G(dbtbl1d)) Q 
 . Q 
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61161^47911^Dan Russell^16932" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM DBTBL1TBLDOC WHERE %LIBS='SYSDEV' AND FID=:FID
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vDs,vos1,vos2,vos3,vos4 S vDs=$$vOpen11()
 F  Q:'$$vFetch11()  D
 . N vRec S vRec=$$vRCgetRecord1^RecordDBTBL1TBLDOC($P(vDs,$C(9),1),$P(vDs,$C(9),2),$P(vDs,$C(9),3),1)
 .	S vobj(vRec,-2)=3
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordDBTBL1TBLDOC(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	K vobj(+$G(vRec)) Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe2() ; DELETE FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:FID
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vDs,vos1,vos2,vos3,vos4 S vDs=$$vOpen12()
 F  Q:'$$vFetch12()  D
 . N vRec S vRec=$$vRCgetRecord1^RecordDBTBL1D($P(vDs,$C(9),1),$P(vDs,$C(9),2),$P(vDs,$C(9),3),1)
 .	S vobj(vRec,-2)=3
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordDBTBL1D(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	K vobj(+$G(vRec)) Q 
  TC:$TL 
 Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe3() ; DELETE FROM DBTBL1 WHERE %LIBS='SYSDEV' AND FID=:FID
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vRec S vRec=$$vRCgetRecord1^RecordDBTBL1("SYSDEV",FID,0)
 I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordDBTBL1(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 K vobj(+$G(vRec)) Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe4() ; DELETE FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:V1 AND DI=:V2
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vRec S vRec=$$vRCgetRecord1^RecordDBTBL1D("SYSDEV",V1,V2,0)
 I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordDBTBL1D(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 K vobj(+$G(vRec)) Q 
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe5() ; DELETE FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:CHILDFID AND DI=:COLNAME
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vRec S vRec=$$vRCgetRecord1^RecordDBTBL1D("SYSDEV",CHILDFID,COLNAME,0)
 I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordDBTBL1D(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 K vobj(+$G(vRec)) Q 
 ;
vOpen0(exe,vsql,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist,vOff) ; Dynamic MDB ResultSet
 ;
 set sqlcur="DELETE.rsdata"
 N ER,vExpr,mode,RM,vOpen,vTok S ER=0 ;=noOpti
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
 E  S vOpen=$$OPEN^SQLM(.exe,vFrom,vSelect,vWhere,vOrderby,vGroupby,vParlist,,1,,sqlcur) I 'ER D SAV^SQLCACHE(vExpr,.vParlist) s vsql=vOpen
 I ER S $ZE="0,"_$ZPOS_",%PSL-E-SQLFAIL,"_$TR($G(RM),$C(10,44),$C(32,126)),$EC=",U1001,"
 ;
 S vos13=vsql
 Q ""
 ;
vFetch0() ; MDB dynamic FETCH
 ;
 ; type public String exe(),sqlcur,vd,vi,vsql()
 ;
 I vsql=0 S rsdata="" Q 0
 S vsql=$$^SQLF(.exe,.vd,.vi,.sqlcur)
 S rsdata=vd
 S vos13=vsql
 S vos14=$G(vi)
 Q vsql
 ;
vOpen1() ; SEQ,DES FROM DBTBL1TBLDOC WHERE %LIBS='SYSDEV' AND FID=:FID ORDER BY SEQ ASC
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(FID) I vos3="" G vL1a0
 S vos4=""
vL1a4 S vos4=$O(^DBTBL("SYSDEV",1,vos3,0,vos4),1) I vos4="" G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos5=$G(^DBTBL("SYSDEV",1,vos3,0,vos4))
 S rs=$S(vos4=vos2:"",1:vos4)_$C(9)_$P(vos5,"|",1)
 ;
 Q 1
 ;
vOpen10() ; %LIBS,FID,DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:FID AND MDD=:MDDREF
 ;
 ;
 S vos4=2
 D vL10a1
 Q ""
 ;
vL10a0 S vos4=0 Q
vL10a1 S vos5=$$BYTECHAR^SQLUTL(254)
 S vos6=$G(FID) I vos6="" G vL10a0
 S vos7=$G(MDDREF) I vos7="",'$D(MDDREF) G vL10a0
 S vos8=""
vL10a5 S vos8=$O(^DBINDX("SYSDEV","MDD",vos7,vos6,vos8),1) I vos8="" G vL10a0
 Q
 ;
vFetch10() ;
 ;
 ;
 I vos4=1 D vL10a5
 I vos4=2 S vos4=1
 ;
 I vos4=0 S ds="" Q 0
 ;
 S ds="SYSDEV"_$C(9)_vos6_$C(9)_$S(vos8=vos5:"",1:vos8)
 ;
 Q 1
 ;
vOpen11() ; %LIBS,FID,SEQ FROM DBTBL1TBLDOC WHERE %LIBS='SYSDEV' AND FID=:FID
 ;
 ;
 S vos1=2
 D vL11a1
 Q ""
 ;
vL11a0 S vos1=0 Q
vL11a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(FID) I vos3="" G vL11a0
 S vos4=""
vL11a4 S vos4=$O(^DBTBL("SYSDEV",1,vos3,0,vos4),1) I vos4="" G vL11a0
 Q
 ;
vFetch11() ;
 ;
 ;
 I vos1=1 D vL11a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vDs="" Q 0
 ;
 S vDs="SYSDEV"_$C(9)_vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen12() ; %LIBS,FID,DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:FID
 ;
 ;
 S vos1=2
 D vL12a1
 Q ""
 ;
vL12a0 S vos1=0 Q
vL12a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(FID) I vos3="" G vL12a0
 S vos4=""
vL12a4 S vos4=$O(^DBTBL("SYSDEV",1,vos3,9,vos4),1) I vos4="" G vL12a0
 Q
 ;
vFetch12() ;
 ;
 ;
 I vos1=1 D vL12a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S vDs="" Q 0
 ;
 S vDs="SYSDEV"_$C(9)_vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen2() ; FID FROM DBTBL8 WHERE %LIBS='SYSDEV' AND FID=:FID
 ;
 ;
 S vos1=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos1=0 Q
vL2a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(FID) I vos3="" G vL2a0
 S vos4=""
vL2a4 S vos4=$O(^DBTBL("SYSDEV",8,vos3,vos4),1) I vos4="" G vL2a0
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos1=1 D vL2a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rsindex="" Q 0
 ;
 S rsindex=vos3
 ;
 Q 1
 ;
vOpen3() ; FID FROM DBTBL1F WHERE %LIBS='SYSDEV' AND FID=:FID
 ;
 ;
 S vos5=2
 D vL3a1
 Q ""
 ;
vL3a0 S vos5=0 Q
vL3a1 S vos6=$$BYTECHAR^SQLUTL(254)
 S vos7=$G(FID) I vos7="" G vL3a0
 S vos8=""
vL3a4 S vos8=$O(^DBTBL("SYSDEV",19,vos7,vos8),1) I vos8="" G vL3a0
 Q
 ;
vFetch3() ;
 ;
 ;
 I vos5=1 D vL3a4
 I vos5=2 S vos5=1
 ;
 I vos5=0 S rsfkey="" Q 0
 ;
 S rsfkey=vos7
 ;
 Q 1
 ;
vOpen4() ; DISTINCT FID FROM DBTBL1F WHERE %LIBS='SYSDEV' AND TBLREF=:FID
 ;
 ;
 S vos9=2
 D vL4a1
 Q ""
 ;
vL4a0 S vos9=0 Q
vL4a1 S vos10=$$BYTECHAR^SQLUTL(254)
 S vos11=$G(FID) I vos11="",'$D(FID) G vL4a0
 S vos12=""
vL4a4 S vos12=$O(^DBINDX("SYSDEV","FKPTR",vos11,vos12),1) I vos12="" G vL4a0
 Q
 ;
vFetch4() ;
 ;
 ;
 I vos9=1 D vL4a4
 I vos9=2 S vos9=1
 ;
 I vos9=0 S rsfkey2="" Q 0
 ;
 S rsfkey2=$S(vos12=vos10:"",1:vos12)
 ;
 Q 1
 ;
vOpen5() ; %LIBS,FID,DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:FID
 ;
 ;
 S vos1=2
 D vL5a1
 Q ""
 ;
vL5a0 S vos1=0 Q
vL5a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(FID) I vos3="" G vL5a0
 S vos4=""
vL5a4 S vos4=$O(^DBTBL("SYSDEV",1,vos3,9,vos4),1) I vos4="" G vL5a0
 Q
 ;
vFetch5() ;
 ;
 ;
 I vos1=1 D vL5a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds="" Q 0
 ;
 S ds="SYSDEV"_$C(9)_vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen6() ; %LIBS,FID,SEQ FROM DBTBL1TBLDOC WHERE %LIBS='SYSDEV' AND FID=:FID
 ;
 ;
 S vos5=2
 D vL6a1
 Q ""
 ;
vL6a0 S vos5=0 Q
vL6a1 S vos6=$$BYTECHAR^SQLUTL(254)
 S vos7=$G(FID) I vos7="" G vL6a0
 S vos8=""
vL6a4 S vos8=$O(^DBTBL("SYSDEV",1,vos7,0,vos8),1) I vos8="" G vL6a0
 Q
 ;
vFetch6() ;
 ;
 ;
 I vos5=1 D vL6a4
 I vos5=2 S vos5=1
 ;
 I vos5=0 S dsdoc="" Q 0
 ;
 S dsdoc="SYSDEV"_$C(9)_vos7_$C(9)_$S(vos8=vos6:"",1:vos8)
 ;
 Q 1
 ;
vOpen7() ; %LIBS,FID,DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:PARFID
 ;
 ;
 S vos1=2
 D vL7a1
 Q ""
 ;
vL7a0 S vos1=0 Q
vL7a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(PARFID) I vos3="" G vL7a0
 S vos4=""
vL7a4 S vos4=$O(^DBTBL("SYSDEV",1,vos3,9,vos4),1) I vos4="" G vL7a0
 Q
 ;
vFetch7() ;
 ;
 ;
 I vos1=1 D vL7a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds="" Q 0
 ;
 S ds="SYSDEV"_$C(9)_vos3_$C(9)_$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen8() ; DI FROM DBTBL1D WHERE %LIBS='SYSDEV' AND FID=:PARFID
 ;
 ;
 S vos1=2
 D vL8a1
 Q ""
 ;
vL8a0 S vos1=0 Q
vL8a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(PARFID) I vos3="" G vL8a0
 S vos4=""
vL8a4 S vos4=$O(^DBTBL("SYSDEV",1,vos3,9,vos4),1) I vos4="" G vL8a0
 Q
 ;
vFetch8() ;
 ;
 ;
 I vos1=1 D vL8a4
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos4=vos2:"",1:vos4)
 ;
 Q 1
 ;
vOpen9() ; FID FROM DBTBL1 WHERE %LIBS='SYSDEV'
 ;
 ;
 S vos1=2
 D vL9a1
 Q ""
 ;
vL9a0 S vos1=0 Q
vL9a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL9a3 S vos3=$O(^DBTBL("SYSDEV",1,vos3),1) I vos3="" G vL9a0
 Q
 ;
vFetch9() ;
 ;
 ;
 I vos1=1 D vL9a3
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S rs=$S(vos3=vos2:"",1:vos3)
 ;
 Q 1
 ;
vReCp1(v1) ; RecordDBTBL1.copy: DBTBL1
 ;
 N vNod,vOid
 I $G(vobj(v1,-2)) D
 .	F vNod=0,1,2,3,4,5,6,7,10,12,13,14,16,22,99,100,101,102 S:'$D(vobj(v1,vNod)) vobj(v1,vNod)=$G(^DBTBL(vobj(v1,-3),1,vobj(v1,-4),vNod))
 S vOid=$$copy^UCGMR(v1)
 Q vOid
 ;
vReCp2(v1) ; RecordDBTBL1D.copy: DBTBL1D
 ;
 Q $$copy^UCGMR(dbtbl1d)
 ;
vReCp3(v1) ; RecordDBTBL1TBLDOC.copy: DBTBL1TBLDOC
 ;
 Q $$copy^UCGMR(tbldoc)
 ;
vReCp4(v1) ; RecordDBTBL1D.copy: DBTBL1D
 ;
 Q $$copy^UCGMR(dbtbl1dp)
