V01S375(%O,fSCAU)	;SCA - SCA - SID= <SCAUSR> PROFILE User Set-Up (Tables/ G/L Link)
	;
	; **** Routine compiled from DATA-QWIK Screen SCAUSR ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	;;Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 12/06/2007 16:14 - chenardp
	;
	N KEYS N KVAR N VFSN N VO N VODFT N VPGM N vPSL N VSID N VSNAME
	;
	; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
	;
	S:'($D(%O)#2) %O=5
	I (%O=5) D
	.	I '($D(fSCAU)#2) K vobj(+$G(fSCAU)) S fSCAU=$$vDbNew1("")
	.	Q 
	S KVAR="kill %TAB,VFSN,VO,VPTBL,vtab" S VSID="SCAUSR" S VPGM=$T(+0) S VSNAME="PROFILE User Set-Up (Tables/ G/L Link)"
	S VFSN("SCAU")="zfSCAU"
	S vPSL=1
	S KEYS(1)=vobj(fSCAU,-3)
	;
	; ==================== Display blank screen         (%O=5)
	;
	I %O=5 D VPR(.fSCAU) D VDA1(.fSCAU) D ^DBSPNT() Q 
	;
	I '%O D VNEW(.fSCAU) D VPR(.fSCAU) D VDA1(.fSCAU)
	I %O D VLOD(.fSCAU) Q:$get(ER)  D VPR(.fSCAU) D VDA1(.fSCAU)
	;
	; ====================  Display Form
	D ^DBSPNT()
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=XECUTE
	I %O=2!(%O=3) D ^DBSCRT8A XECUTE:'$D(%PAGE) KVAR Q  ; Inquiry/Delete
	; ====================  Set up data entry control table
	;
	I %O<2 D VTAB(.fSCAU)
	Q 
	;
VNEW(fSCAU)	; Initialize arrays if %O=0
	;
	D VDEF(.fSCAU)
	D VLOD(.fSCAU)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VDEF(fSCAU)	;
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
VLOD(fSCAU)	; Load data from disc - %O = (1-5)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VPR(fSCAU)	; Display screen prompts
	S VO="36||13|0"
	S VO(0)="|0"
	S VO(1)=$C(1,19,1,1,0,0,0,0,0,0)_"01T "
	S VO(2)=$C(1,20,35,1,0,0,0,0,0,0)_"01TUser Set-Up (Tables/ G/L Linkages) "
	S VO(3)=$C(3,13,9,0,0,0,0,0,0,0)_"01T User ID:"
	S VO(4)=$C(3,49,15,1,0,0,0,0,0,0)_"01T PMing Allowed:"
	S VO(5)=$C(4,6,16,1,0,0,0,0,0,0)_"01T User Full Name:"
	S VO(6)=$C(5,11,11,1,0,0,0,0,0,0)_"01T Userclass:"
	S VO(7)=$C(5,55,9,1,0,0,0,0,0,0)_"01TPassword:"
	S VO(8)=$C(6,2,20,1,0,0,0,0,0,0)_"01T Tran Suspense (DR):"
	S VO(9)=$C(6,44,20,1,0,0,0,0,0,0)_"01T Tran Suspense (CR):"
	S VO(10)=$C(7,9,13,0,0,0,0,0,0,0)_"01T Branch Code:"
	S VO(11)=$C(7,50,14,0,0,0,0,0,0,0)_"01TUser Language:"
	S VO(12)=$C(8,4,18,0,0,0,0,0,0,0)_"01TAuto Menu Enabled:"
	S VO(13)=$C(8,48,16,0,0,0,0,0,0,0)_"01TCustomer Number:"
	S VO(14)=$C(9,2,20,0,0,0,0,0,0,0)_"01TPosting Environment:"
	S VO(15)=$C(9,39,25,0,0,0,0,0,0,0)_"01T DATA-QWIK Editor Option:"
	S VO(16)=$C(10,9,13,0,0,0,0,0,0,0)_"01TLimit to EMU:"
	S VO(17)=$C(10,50,14,0,0,0,0,0,0,0)_"01TEmail Address:"
	S VO(18)=$C(11,2,20,0,0,0,0,0,0,0)_"01TPassword Expiration:"
	S VO(19)=$C(11,37,27,0,0,0,0,0,0,0)_"01TFunction Key Default Table:"
	S VO(20)=$C(12,7,15,0,0,0,0,0,0,0)_"01TMarket Segment:"
	S VO(21)=$C(12,53,11,0,0,0,0,0,0,0)_"01TSegment ID:"
	S VO(22)=$C(14,18,43,1,0,0,0,0,0,0)_"01T Complete this section for on-line tellers "
	S VO(23)=$C(15,4,19,0,0,0,0,0,0,0)_"01TCash Over G/L Acct:"
	S VO(24)=$C(15,44,20,0,0,0,0,0,0,0)_"01TCash Short G/L Acct:"
	S VO(25)=$C(16,6,17,0,0,0,0,0,0,0)_"01TOverall Cash Max:"
	S VO(26)=$C(16,47,17,0,0,0,0,0,0,0)_"01TOverall Cash Min:"
	S VO(27)=$C(18,15,49,1,0,0,0,0,0,0)_"01T Complete this section for batch process tellers "
	S VO(28)=$C(19,4,18,0,0,0,0,0,0,0)_"01TReconciling Debit:"
	S VO(29)=$C(19,45,19,0,0,0,0,0,0,0)_"01TReconciling Credit:"
	S VO(30)=$C(20,1,21,0,0,0,0,0,0,0)_"01TOverdraft Protection:"
	S VO(31)=$C(20,27,16,0,0,0,0,0,0,0)_"01TReject Handling:"
	S VO(32)=$C(20,51,13,0,0,0,0,0,0,0)_"01TRetry Teller:"
	S VO(33)=$C(21,10,12,0,0,0,0,0,0,0)_"01TMax Retries:"
	S VO(34)=$C(21,28,15,0,0,0,0,0,0,0)_"01TSame Day Retry:"
	S VO(35)=$C(21,52,12,0,0,0,0,0,0,0)_"01TO/D Retries:"
	S VO(36)=$C(22,19,24,0,0,0,0,0,0,0)_"01TTransaction Sort Option:"
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VDA1(fSCAU)	; Display screen data
	N V
	;
	S VO="68|37|13|0"
	S VO(37)=$C(3,23,20,2,0,0,0,0,0,0)_"01T"_$E((vobj(fSCAU,-3)),1,20)
	S VO(38)=$C(3,65,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fSCAU),$C(124),18):"Y",1:"N")
	S VO(39)=$C(4,23,40,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fSCAU),$C(124),1)),1,40)
	S VO(40)=$C(5,23,12,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fSCAU),$C(124),5)),1,12)
	S V="" S VO(41)=$C(5,65,12,2,0,0,0,0,0,0)_"00T"_""
	S VO(42)=$C(6,23,12,2,0,0,0,0,0,0)_"00N"_$P(vobj(fSCAU),$C(124),9)
	S VO(43)=$C(6,65,12,2,0,0,0,0,0,0)_"00N"_$P(vobj(fSCAU),$C(124),10)
	S VO(44)=$C(7,23,6,2,0,0,0,0,0,0)_"00N"_$P(vobj(fSCAU),$C(124),22)
	S VO(45)=$C(7,65,12,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fSCAU),$C(124),3)),1,12)
	S VO(46)=$C(8,23,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fSCAU),$C(124),2):"Y",1:"N")
	S VO(47)=$C(8,65,12,2,0,0,0,0,0,0)_"00N"_$P(vobj(fSCAU),$C(124),14)
	S VO(48)=$C(9,23,1,2,0,0,0,0,0,0)_"00N"_$P(vobj(fSCAU),$C(124),29)
	S VO(49)=$C(9,65,3,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fSCAU),$C(124),21)),1,3)
	S VO(50)=$C(10,23,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fSCAU),$C(124),36):"Y",1:"N")
	S VO(51)=$C(10,65,16,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fSCAU),$C(124),48)),1,55)
	S VO(52)=$C(11,23,10,2,0,0,0,0,0,0)_"01D"_$$vdat2str(($P(vobj(fSCAU),$C(124),7)),"MM/DD/YEAR")
	S VO(53)=$C(11,65,12,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fSCAU),$C(124),27)),1,12)
	S VO(54)=$C(12,23,12,2,0,0,0,0,0,0)_"00N"_$P(vobj(fSCAU),$C(124),37)
	S VO(55)=$C(12,65,12,2,0,0,0,0,0,0)_"00N"_$P(vobj(fSCAU),$C(124),38)
	S VO(56)=$C(15,24,12,2,0,0,0,0,0,0)_"00N"_$P(vobj(fSCAU),$C(124),11)
	S VO(57)=$C(15,65,12,2,0,0,0,0,0,0)_"00N"_$P(vobj(fSCAU),$C(124),12)
	S V=$S($P(vobj(fSCAU),$C(124),34)="":"",1:$J($P(vobj(fSCAU),$C(124),34),0,2)) S VO(58)=$C(16,24,12,2,0,0,0,0,0,0)_"00$"_$S($P(vobj(fSCAU),$C(124),34)="":"",1:$J($P(vobj(fSCAU),$C(124),34),0,2))
	S V=$S($P(vobj(fSCAU),$C(124),35)="":"",1:$J($P(vobj(fSCAU),$C(124),35),0,2)) S VO(59)=$C(16,65,12,2,0,0,0,0,0,0)_"00$"_$S($P(vobj(fSCAU),$C(124),35)="":"",1:$J($P(vobj(fSCAU),$C(124),35),0,2))
	S VO(60)=$C(19,23,12,2,0,0,0,0,0,0)_"00N"_$P(vobj(fSCAU),$C(124),15)
	S VO(61)=$C(19,65,12,2,0,0,0,0,0,0)_"00N"_$P(vobj(fSCAU),$C(124),16)
	S VO(62)=$C(20,23,1,2,0,0,0,0,0,0)_"00N"_$P(vobj(fSCAU),$C(124),32)
	S VO(63)=$C(20,44,1,2,0,0,0,0,0,0)_"00N"_$P(vobj(fSCAU),$C(124),17)
	S VO(64)=$C(20,65,12,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fSCAU),$C(124),19)),1,12)
	S VO(65)=$C(21,23,2,2,0,0,0,0,0,0)_"00N"_$P(vobj(fSCAU),$C(124),20)
	S VO(66)=$C(21,44,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fSCAU),$C(124),31):"Y",1:"N")
	S VO(67)=$C(21,65,2,2,0,0,0,0,0,0)_"00N"_$P(vobj(fSCAU),$C(124),33)
	S VO(68)=$C(22,44,1,2,0,0,0,0,0,0)_"00N"_$P(vobj(fSCAU),$C(124),47)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTAB(fSCAU)	;
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
	S %MAX=32 S VPT=1 S VPB=22 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="SCAU"
	S OLNTB=22044
	;
	S VFSN("SCAU")="zfSCAU"
	;
	;
	S %TAB(1)=$C(2,22,20)_"21T12401|1|[SCAU]UID"
	S %TAB(2)=$C(2,64,1)_"00L12418|1|[SCAU]TPM"
	S %TAB(3)=$C(3,22,40)_"01T12401|1|[SCAU]%UFN||||do VP1^V01S375(.fSCAU)"
	S %TAB(4)=$C(4,22,12)_"01T12405|1|[SCAU]%UCLS|[SCAU0]||do VP2^V01S375(.fSCAU)"
	S %TAB(5)=$C(4,64,12)_"10T12406|1|[SCAU]PSWD|||do VP3^V01S375(.fSCAU)"
	S %TAB(6)=$C(5,22,12)_"01N12409|1|[SCAU]TSDR|[GLAD]"
	S %TAB(7)=$C(5,64,12)_"01N12410|1|[SCAU]TSCR|[GLAD]"
	S %TAB(8)=$C(6,22,6)_"00N12422|1|[SCAU]BRCD|[UTBLBRCD]"
	S %TAB(9)=$C(6,64,12)_"00T12403|1|[SCAU]LANG|[UTBLLANG]"
	S %TAB(10)=$C(7,22,1)_"00L12402|1|[SCAU]AUTOMENU"
	S %TAB(11)=$C(7,64,12)_"00N12414|1|[SCAU]ACN|||do VP4^V01S375(.fSCAU)"
	S %TAB(12)=$C(8,22,1)_"00N12429|1|[SCAU]CURRENV|[STBLCURRENV]||do VP5^V01S375(.fSCAU)"
	S %TAB(13)=$C(8,64,3)_"00T12421|1|[SCAU]EDITOR|[DBCTL]CODE:QU ""[DBCTL]NAME=""""EDITOR"""""""
	S %TAB(14)=$C(9,22,1)_"00L12436|1|[SCAU]EMULIM|||do VP6^V01S375(.fSCAU)|do VP7^V01S375(.fSCAU)"
	S %TAB(15)=$C(9,64,16)_"00T12448|1|[SCAU]EADDR|||||||||55"
	S %TAB(16)=$C(10,22,10)_"21D12407|1|[SCAU]PEXPR"
	S %TAB(17)=$C(10,64,12)_"00T12427|1|[SCAU]TFKDEF"
	S %TAB(18)=$C(11,22,12)_"00N12437|1|[SCAU]MARSEG|[UTBLMARSEG]"
	S %TAB(19)=$C(11,64,12)_"00N12438|1|[SCAU]SEGID||||do VP8^V01S375(.fSCAU)"
	S %TAB(20)=$C(14,23,12)_"00N12411|1|[SCAU]CSOVR|[GLAD]"
	S %TAB(21)=$C(14,64,12)_"00N12412|1|[SCAU]CSSHRT|[GLAD]"
	S %TAB(22)=$C(15,23,12)_"00$12434|1|[SCAU]OACMAX|||do VP9^V01S375(.fSCAU)||||2"
	S %TAB(23)=$C(15,64,12)_"00$12435|1|[SCAU]OACMIN|||do VP10^V01S375(.fSCAU)||||2"
	S %TAB(24)=$C(18,22,12)_"00N12415|1|[SCAU]RODR|[GLAD]"
	S %TAB(25)=$C(18,64,12)_"00N12416|1|[SCAU]ROCR|[GLAD]"
	S %TAB(26)=$C(19,22,1)_"00N12432|1|[SCAU]ODP|[STBLPATODP]"
	S %TAB(27)=$C(19,43,1)_"00N12417|1|[SCAU]BATREJ|[STBLBATREJ]"
	S %TAB(28)=$C(19,64,12)_"00T12419|1|[SCAU]RTUID|[SCAU]||||||||20"
	S %TAB(29)=$C(20,22,2)_"00N12420|1|[SCAU]MARTY|||||0"
	S %TAB(30)=$C(20,43,1)_"00L12431|1|[SCAU]SDRTY|||do VP11^V01S375(.fSCAU)"
	S %TAB(31)=$C(20,64,2)_"00N12433|1|[SCAU]ODPRET|||do VP12^V01S375(.fSCAU)"
	S %TAB(32)=$C(21,43,1)_"00N12447|1|[SCAU]TRNSRT|[STBLTRNSRT]"
	D VTBL(.fSCAU) D VDEPRE(.fSCAU) I $get(ER) Q 
	D ^DBSCRT8 ; data entry
	Q 
	;
VREQ	; Create REQ() array
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTBL(fSCAU)	;Create %TAB(array)
	; 1 2 3  4 5   6   7-9 10-11
	; DY,DX,SZ PT REQ TYPE DEL POS |NODE|ITEM NAME|TBL|FMT|PP|PRE|MIN|MAX|DEC
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VDEPRE(fSCAU)	; Data Entry Pre-processor
	;
	I "" ;* if CUVAR.CURRENV quit
	D DELETE^DBSMACRO("SCAU.CURRENV","1","0")
	D PROTECT^DBSMACRO("SCAU.CURRENV")
	;
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
	;user-defined post procs
	;
VP1(fSCAU)	;
	I ($P(vobj(fSCAU),$C(124),1)=""),$P(vobj(fSCAU),$C(124),14) D
	.	N cif S cif=$G(^CIF($P(vobj(fSCAU),$C(124),14),1))
	.	D DEFAULT^DBSMACRO("SCAU.%ufn",$P(cif,$C(124),1),"1","0","0")
	.	Q 
	Q 
	;
VP2(fSCAU)	;
	;
	I (X="") Q 
	;
	N scaucls0,vop1 S scaucls0=$$vDb4(X,.vop1)
	I $G(vop1)=0 Q 
	;
	; Secure user class may set up anyone
	N scaucls1 S scaucls1=$$vDb5(%UCLS)
	I +$P(scaucls1,$C(124),6) Q 
	;
	; Anyone can set up to non-secure user class
	I '$P(scaucls0,$C(124),6) Q 
	;
	; Userclass ~p1 cannot add users to a secure userclass
	D SETERR^DBSEXECU("SCAU0","MSG",2895,%UCLS) Q 
	;
VP3(fSCAU)	;
	;
	; Data required
	I (X=""),(V="") D SETERR^DBSEXECU("SCAU","MSG",741) Q 
	;
	I X=V Q 
	I (X="") S X=V Q 
	;
	N scaucls0 S scaucls0=$$vDb5($P(vobj(fSCAU),$C(124),5))
	;
	; Password length must be at least ~p1 characters
	I $L(X)<$P(scaucls0,$C(124),3) D SETERR^DBSEXECU("SCAU","MSG",2139,$P(scaucls0,$C(124),3)) Q 
	;
	N PSWDAUT N SAVEX
	N ENC
	;
	S SAVEX=X
	D PWD^SCADRV1(.fSCAU,.ENC,.PSWDAUT)
	S X=SAVEX
	I $get(ER) Q 
	;
	S X=$$ENC^SCAENC(X)
	;
	; Also update SCAU.PSWDAUT if changes to SCAU.PSWD are filed.
	N pswdaut
	S ER=$$ENC^%ENCRYPT(SAVEX,.pswdaut)
	D DEFAULT^DBSMACRO("SCAU.PSWDAUT",$get(pswdaut),"1","0","0")
	;
	Q 
	;
VP4(fSCAU)	;
	;
	I (X="") Q 
	;
	D CUS^UACN1
	;
	Q 
	;
VP5(fSCAU)	;
	;
	I X=0 D DEFAULT^DBSMACRO("SCAU.EMULIM",0,"1","0","0")
	;
	Q 
	;
VP6(fSCAU)	;
	;
	I ""=0!($P(vobj(fSCAU),$C(124),29)=0) S X=0
	;
	Q 
	;
VP7(fSCAU)	;
	I 0 ;* if CUVAR.EMU = 0 do DEFAULT^DBSMACRO("SCAU.EMULIM",0,"1","0","0")
	;
	Q 
	;
VP8(fSCAU)	;
	;
	N zv
	;
	S zv="[UTBLMARSEGDT]SEGID:QU ""[UTBLMARSEGDT]MARSEG="_$P(vobj(fSCAU),$C(124),37)_""""
	;
	D CHANGE^DBSMACRO("TBL",zv)
	;
	Q 
	;
VP9(fSCAU)	;
	;
	I (X="") Q 
	;
	; Minimum must be less than or equal to maximum
	I X<+$P(vobj(fSCAU),$C(124),35) D SETERR^DBSEXECU("SCAU","MSG",1737) Q 
	;
	Q 
	;
VP10(fSCAU)	;
	;
	I (X="") Q 
	;
	; Minimum must be less than or equal to maximum
	I '($P(vobj(fSCAU),$C(124),34)=""),X>$P(vobj(fSCAU),$C(124),34) D SETERR^DBSEXECU("SCAU","MSG",1737) Q 
	;
	Q 
	;
VP11(fSCAU)	;
	;
	I 'X Q 
	;
	; Invalid, Same Day Retry requires Retry Teller.
	I ($P(vobj(fSCAU),$C(124),19)="") D SETERR^DBSEXECU("SCAU","MSG",1526) Q 
	;
	; Invalid, Same Day Retry requires Maximum Retries.
	I '$P(vobj(fSCAU),$C(124),20) D SETERR^DBSEXECU("SCAU","MSG",1525) Q 
	;
	; Retry Tellers cannot use Same Day Retry
	I $P(vobj(fSCAU),$C(124),19)=UID D SETERR^DBSEXECU("SCAU","MSG",2418) Q 
	;
	; Same Day Retry cannot use Overdraft Protection
	I $P(vobj(fSCAU),$C(124),32) D SETERR^DBSEXECU("SCAU","MSG",1524) Q 
	;
	Q 
VP12(fSCAU)	;
	;
	; Num of o/d retries invalid. O/D protection not established.
	I $P(vobj(fSCAU),$C(124),32)'=2,'(X="") D SETERR^DBSEXECU("SCAU","MSG",2159) Q 
	;
	; Num of o/d retries must be less than or equal to the maximum retries allowed
	I $P(vobj(fSCAU),$C(124),20)<X D SETERR^DBSEXECU("SCAU","MSG",2155) Q 
	;
	; Data required
	I $P(vobj(fSCAU),$C(124),32)=2,(X="") D SETERR^DBSEXECU("SCAU","MSG",741) Q 
	;
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VRV(V,L)	;
	Q V_$J("",L-$L(V))
VREPRNT	;
	D VPR(.fSCAU)
	D VDA1(.fSCAU)
	D ^DBSPNT()
	Q 
	;
VW(fSCAU)	;
	D VDA1(.fSCAU)
	D ^DBSPNT(10)
	Q 
	;
VDAPNT(fSCAU)	;
	D VDA1(.fSCAU)
	D ^DBSPNT(0,2)
	Q 
	;
VDA	;
	D VDA1(.fSCAU)
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
vSET(sn,di,X)	;
	I sn="SCAU" D vSET1(.fSCAU,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
vSET1(fSCAU,di,X)	;
	D vCoInd1(fSCAU,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di)	;
	I fid="SCAU" Q $$vREAD1(.fSCAU,di)
	Q ""
vREAD1(fSCAU,di)	;
	Q $$vCoInd2(fSCAU,di)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	; ----------------
	;  #OPTION ResultClass 0
vdat2str(object,mask)	; Date.toString
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I (object="") Q ""
	I (mask="") S mask="MM/DD/YEAR"
	N cc N lday N lmon
	I mask="DL"!(mask="DS") D  ; Long or short weekday
	.	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
	.	I (cc="") S cc="US"
	.	S lday=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
	.	S mask="DAY" ; Day of the week
	.	Q 
	I mask="ML"!(mask="MS") D  ; Long or short month
	.	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
	.	I (cc="") S cc="US"
	.	S lmon=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
	.	S mask="MON" ; Month of the year
	.	Q 
	Q $ZD(object,mask,$get(lmon),$get(lday))
	; ----------------
	;  #OPTION ResultClass 0
vCoInd1(vOid,vCol,vVal)	; RecordSCAU.setColumn(1,0)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("SCAU",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	N vTyp S vTyp=$P(vP,"|",6)
	I vNod["*" S vPos=-3 S:'($D(vobj(vOid,-100,$P(vP,"|",4)_"*",vCol))#2) vobj(vOid,-100,$P(vP,"|",4)_"*",vCol)=vTyp_"000"_vobj(vOid,vPos) S vobj(vOid,vPos)=vVal Q 
	;
	N vCmp S vCmp=$P(vP,"|",14)
	I vCmp'="" S $ZS="-1,"_$ZPOS_","_"%PSL-E-INVALIDREF" X $ZT
	;
	S vPos=$P(vP,"|",4)
	N vOldNod S vOldNod=$$getOldNode^UCXDD(vP,0)
	I '$D(vobj(vOid,-100,vOldNod,vCol)) S vobj(vOid,-100,vOldNod,vCol)=vTyp_$E(1000+vPos,2,4)_$piece(vobj(vOid),"|",vPos)
	S $piece(vobj(vOid),"|",vPos)=vVal
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoInd2(vOid,vCol)	; RecordSCAU.getColumn()
	N vret
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("SCAU",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	I vNod["*" S vret=$get(vobj(vOid,-3)) Q vret
	;
	N vCmp S vCmp=$P(vP,"|",14)
	I vCmp'="" S vCmp=$$getCurExpr^UCXDD(vP,"vOid",0) Q @vCmp
	;
	S vPos=$P(vP,"|",4)
	N vRet
	S vRet=vobj(vOid)
	S vRet=$piece(vRet,"|",vPos)
	Q vRet
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ","ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ")
	;
vDb4(v1,v2out)	;	voXN = Db.getRecord(SCAU0,,1,-2)
	;
	N scaucls0
	S scaucls0=$G(^SCAU(0,v1))
	I scaucls0="",'$D(^SCAU(0,v1))
	S v2out='$T
	;
	Q scaucls0
	;
vDb5(v1)	;	voXN = Db.getRecord(SCAU0,,0)
	;
	N scaucls1
	S scaucls1=$G(^SCAU(0,v1))
	I scaucls1="",'$D(^SCAU(0,v1))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,SCAU0" X $ZT
	Q scaucls1
	;
vDbNew1(v1)	;	vobj()=Class.new(SCAU)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordSCAU",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	Q vOid
