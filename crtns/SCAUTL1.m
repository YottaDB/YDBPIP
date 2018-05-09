 ; 
 ; **** Routine compiled from DATA-QWIK Procedure SCAUTL1 ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
 ;
 Q 
 ;
BLDNOISO ; 
 ;
 N GBLS
 ;
 D GETGBLS(.GBLS)
 D COMPILE(.GBLS)
 Q 
 ;
GETGBLS(GBLS,GLOBAL) ; 
 ;
 N KEYNUM N NOISO
 N ACCKEYS N FID N KEY
 ;
 ; Table Definition
 N ds1,vos1,vos2,vos3 S ds1=$$vOpen1()
 ;
 F  Q:'$$vFetch1()  D
 . N dbtbl1,vop1,vop2,vop3,vop4,vop5 S vop1=$P(ds1,$C(9),1),vop2=$P(ds1,$C(9),2),dbtbl1=$$vRCgetRecord1Opt^RecordDBTBL1(vop1,vop2,1,"")
 .	 S vop3=$G(^DBTBL(vop1,1,vop2,0))
 .	 S vop5=$G(^DBTBL(vop1,1,vop2,16))
 .	 S vop4=$G(^DBTBL(vop1,1,vop2,10))
 .	;
 .	S FID=vop2
 .	S GLOBAL=$P(vop3,$C(124),1)
 .	S ACCKEYS=$P(vop5,$C(124),1)
 .	;
 . I $P(vop4,$C(124),3)=1 Q 
 . I (GLOBAL="") Q 
 .	;
 .	S NOISO=0
 .	;
 .	; Indeces improperly defined as tables
 .	I GLOBAL="XCLS" S NOISO=1
 .	E  I GLOBAL="XIRA" S NOISO=1
 .	E  I GLOBAL="XREF" S NOISO=1
 .	E  I GLOBAL="XCRCD" S NOISO=1
 .	;
 .	; Temporary tables
 .	E  I $E(GLOBAL,1,3)="TMP" S NOISO=1
 .	E  I $E(GLOBAL,1,4)="TEMP" S NOISO=1
 .	;
 .	; "Process-specific" tables
 .	E  F KEYNUM=1:1:$L(ACCKEYS,",") D  Q:NOISO 
 ..		S KEY=$piece(ACCKEYS,",",KEYNUM)
 ..		;
 ..		I KEY="$J" S NOISO=1 Q 
 ..		I KEY="PID" S NOISO=1 Q 
 ..		I KEY="JOB" S NOISO=1 Q 
 ..		I KEY="JOBNO" S NOISO=1 Q 
 ..		;
 ..		Q 
 .	;
 .	I $get(GLOBAL(GLOBAL))'=0 S GLOBAL(GLOBAL)=NOISO
 .	S GLOBAL(GLOBAL,1,FID)=ACCKEYS
 . Q 
 ;
 ; Index Definition
 N ds2,vos4,vos5,vos6,vos7 S ds2=$$vOpen2()
 ;
 F  Q:'$$vFetch2()  D
 . N dbtbl8,vop6,vop7 S vop7=$P(ds2,$C(9),2),vop6=$P(ds2,$C(9),3),dbtbl8=$$vRCgetRecord1Opt^RecordDBTBL8($P(ds2,$C(9),1),vop7,vop6,1,"")
 .	;
 .	S FID=vop7
 .	S GLOBAL=$P(dbtbl8,$C(124),2)
 .	;
 .	I $get(GLOBAL(GLOBAL))'=0 S GLOBAL(GLOBAL)=1
 .	S GLOBAL(GLOBAL,8,FID,vop6)=$P(dbtbl8,$C(124),3)
 . Q 
 ;
 ; Build list of globals (variable GBLS) that qualify for NOISO
 ;
 S (GBLS,GLOBAL)=""
 F  S GLOBAL=$order(GLOBAL(GLOBAL)) Q:(GLOBAL="")  D
 .	I GLOBAL(GLOBAL) S GBLS=GBLS_"^"_GLOBAL_","
 .	Q 
 ;
 S GBLS=$E(GBLS,1,$L(GBLS)-1)
 Q 
 ;
COMPILE(GBLS) ; 
 ;
 N PSL
 N LEN N X N Y
 ;
 S PSL($order(PSL(""),-1)+1)="NOISO // NoIsolation (Compiled by procedure SCAUTL1)"
 S PSL($order(PSL(""),-1)+1)=" #IF $ZVERSION.piece(""GT.M V"",2)'<4.2"
 ;
 S PSL($order(PSL(""),-1)+1)=" #ACCEPT Date=01/04/06; Pgm=SCAUTL1.PROC"
 S PSL($order(PSL(""),-1)+1)=" #BYPASS"
 ;
 S X=1
 S LEN=$L(GBLS)
 ;
 F  D  I X>LEN Q 
 .	S Y=$F(GBLS,",",X+999)
 .	I 'Y S Y=LEN+2
 .	;
 .	S PSL($order(PSL(""),-1)+1)=" view ""NOISOLATION"":""+"_$E(GBLS,X,Y-2)_""""
 .	S X=Y
 .	Q 
 ;
 S PSL($order(PSL(""),-1)+1)=" #ENDBYPASS"
 ;
 S PSL($order(PSL(""),-1)+1)=" #ENDIF"
 S PSL($order(PSL(""),-1)+1)=" quit"
 ;
 ; Compile routine NOISO
 D BUILDRTN^UCGM(.PSL,"NOISO")
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60269^47694^Dan Russell^5067" ; Signature - LTD^TIME^USER^SIZE
 ;
vOpen1() ; %LIBS,FID FROM DBTBL1 WHERE %LIBS='SYSDEV'
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=""
vL1a3 S vos3=$O(^DBTBL("SYSDEV",1,vos3),1) I vos3="" G vL1a0
 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a3
 I vos1=2 S vos1=1
 ;
 I vos1=0 S ds1="" Q 0
 ;
 S ds1="SYSDEV"_$C(9)_$S(vos3=vos2:"",1:vos3)
 ;
 Q 1
 ;
vOpen2() ; %LIBS,FID,INDEXNM FROM DBTBL8 WHERE %LIBS='SYSDEV'
 ;
 ;
 S vos4=2
 D vL2a1
 Q ""
 ;
vL2a0 S vos4=0 Q
vL2a1 S vos5=$$BYTECHAR^SQLUTL(254)
 S vos6=""
vL2a3 S vos6=$O(^DBTBL("SYSDEV",8,vos6),1) I vos6="" G vL2a0
 S vos7=""
vL2a5 S vos7=$O(^DBTBL("SYSDEV",8,vos6,vos7),1) I vos7="" G vL2a3
 Q
 ;
vFetch2() ;
 ;
 ;
 I vos4=1 D vL2a5
 I vos4=2 S vos4=1
 ;
 I vos4=0 S ds2="" Q 0
 ;
 S ds2="SYSDEV"_$C(9)_$S(vos6=vos5:"",1:vos6)_$C(9)_$S(vos7=vos5:"",1:vos7)
 ;
 Q 1
