V01S327	;; -  - 5.3 - SID= <DBTBL9> Journal File Definition
	;;Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/14/2007 10:49 - chenardp
	;
VSTART	; 
	K VO,VODFT
	;
V0	; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
	;
	S KVAR="K %A,%TAB,VFSN,UX,VO,VPTBL,vtab,Finan,Maint,Convt,Insert,Update,Delete,nonefd,efd,fDBTBL9",VSID="DBTBL9",VPGM=$T(+0),VSNAME="Journal File Definition"
	S VFSN("DBTBL9")="fDBTBL9"
	;
	S:'$D(%O) %O=5
	;
	; ==================== Display blank screen         (%O=5)
	;
V5	I %O=5 D VPR,VDA,V5^DBSPNT Q
	; ==================== Initialize file short names  (%O=0)
	;
	; Display Pre-Processor
	;
	I '%O D VNEW,VDSPPRE Q:$G(ER)  D VPR,VDA
	I %O D VLOD Q:$G(ER)  D VDSPPRE Q:$G(ER)  D VPR,VDA
	;
	; ====================  Display Form
	;
	D ^DBSPNT()
	;
	I %O=2!(%O=3) D ^DBSCRT8A X:'$D(%PAGE) KVAR Q  ; Inquiry/Delete
	;
	; ====================  Set up data entry control table
	;
vTBL	I %O<2 D VTAB
	Q
	;
VNEW	; Initialize arrays if %O=0
	;
	;
	S fDBTBL9=$G(fDBTBL9)
	;
VDEF	;
	;
	I ($G(%LIBS)="")!($G(PRITABLE)="")!($G(JRNID)="") Q
	I $G(^DBTBL(%LIBS,9,PRITABLE,JRNID))'="" Q  ; Already created
	S fDBTBL9=$G(fDBTBL9)
	I $P(fDBTBL9,"|",8)="" S $P(fDBTBL9,"|",8)=1   ; DBTBL9.SEQ
	Q
	;
VLOD	; Load data from disc - %O = (1-5)
	;
	I $G(%LOGID) D  Q
	. ;
	. D STUB^DBSCLI("VLOD^V01S327",65,,%LIBS_$C(28)_PRITABLE_$C(28)_JRNID,,"v") I ER K %RPC Q
	. I '$$ONLINE^DBSCLI() D VNEW Q   ;  init if offline
	. S fDBTBL9=$P(v,$C(28),1)
	;
	I $D(%RPC) S %LIBS=$P(%RPC,$C(28),1),PRITABLE=$P(%RPC,$C(28),2),JRNID=$P(%RPC,$C(28),3),%RPC="65,fDBTBL9"
	;
	S fDBTBL9=^DBTBL(%LIBS,9,PRITABLE,JRNID)
	Q
VPR	; Display screen prompts
	;
	S VO="67||13|0"
	S VO(0)="|0"
	S VO(1)=$C(2,1,80,0,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
	S VO(2)=$C(3,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(3)=$C(3,8,14,0,0,0,0,0,0,0)_"01TPrimary Table:"
	S VO(4)=$C(3,45,13,0,0,0,0,0,0,0)_"01TLast Updated:"
	S VO(5)=$C(3,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(6)=$C(4,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(7)=$C(4,9,13,0,0,0,0,0,0,0)_"01TJournal Name:"
	S VO(8)=$C(4,50,8,0,0,0,0,0,0,0)_"01TBy User:"
	S VO(9)=$C(4,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(10)=$C(5,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(11)=$C(5,43,15,0,0,0,0,0,0,0)_"01TSupertype File:"
	S VO(12)=$C(5,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(13)=$C(6,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(14)=$C(6,2,20,1,0,0,0,0,0,0)_"01T Journal Table Name:"
	S VO(15)=$C(6,48,10,1,0,0,0,0,0,0)_"01T Priority:"
	S VO(16)=$C(6,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(17)=$C(7,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(18)=$C(7,9,13,1,0,0,0,0,0,0)_"01T Description:"
	S VO(19)=$C(7,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(20)=$C(8,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(21)=$C(8,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(22)=$C(9,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(23)=$C(9,4,75,0,0,0,0,0,0,0)_"01T------------- Create journal entry under following condition --------------"
	S VO(24)=$C(9,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(25)=$C(10,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(26)=$C(10,10,16,2,0,0,0,0,0,0)_"01TTransaction Type"
	S VO(27)=$C(10,34,10,0,0,0,0,0,0,0)_"01TFinancial:"
	S VO(28)=$C(10,54,7,0,0,0,0,0,0,0)_"01TOnline:"
	S VO(29)=$C(10,71,6,0,0,0,0,0,0,0)_"01TBatch:"
	S VO(30)=$C(10,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(31)=$C(11,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(32)=$C(11,11,15,2,0,0,0,0,0,0)_"01TProcessing Mode"
	S VO(33)=$C(11,37,7,0,0,0,0,0,0,0)_"01TInsert:"
	S VO(34)=$C(11,54,7,0,0,0,0,0,0,0)_"01TUpdate:"
	S VO(35)=$C(11,70,7,0,0,0,0,0,0,0)_"01TDelete:"
	S VO(36)=$C(11,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(37)=$C(12,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(38)=$C(12,4,22,2,0,0,0,0,0,0)_"01TEffective Dated Option"
	S VO(39)=$C(12,36,8,0,0,0,0,0,0,0)_"01TNon-EFD:"
	S VO(40)=$C(12,57,4,0,0,0,0,0,0,0)_"01TEFD:"
	S VO(41)=$C(12,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(42)=$C(13,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(43)=$C(13,15,54,0,0,0,0,0,0,0)_"01TCreate journal only if the following condition is true"
	S VO(44)=$C(13,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(45)=$C(14,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(46)=$C(14,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(47)=$C(15,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(48)=$C(15,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(49)=$C(16,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(50)=$C(16,4,75,0,0,0,0,0,0,0)_"01T----------------------------- In Update Mode ------------------------------"
	S VO(51)=$C(16,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(52)=$C(17,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(53)=$C(17,5,24,0,0,0,0,0,0,0)_"01TOnly If Columns Changed:"
	S VO(54)=$C(17,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(55)=$C(18,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(56)=$C(18,3,26,0,0,0,0,0,0,0)_"01TExclude Following Columns:"
	S VO(57)=$C(18,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(58)=$C(19,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(59)=$C(19,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(60)=$C(20,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(61)=$C(20,32,16,0,0,0,0,0,0,0)_"01TQuery  Condition"
	S VO(62)=$C(20,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(63)=$C(21,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(64)=$C(21,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(65)=$C(22,1,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(66)=$C(22,80,1,0,0,0,0,0,0,0)_"11Tx"
	S VO(67)=$C(23,1,80,0,0,0,0,0,0,0)_"11Tmqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqj"
	Q
VDA	; Display screen data
	N V
	I %O=5 N JRNID,PRITABLE,fDBTBL9
	I  S (JRNID,PRITABLE,fDBTBL9)=""
	E  S JRNID=$G(JRNID),PRITABLE=$G(PRITABLE),fDBTBL9=$G(fDBTBL9)
	;
	S Convt=$G(Convt)
	S Delete=$G(Delete)
	S Finan=$G(Finan)
	S Insert=$G(Insert)
	S Maint=$G(Maint)
	S Update=$G(Update)
	S efd=$G(efd)
	S nonefd=$G(nonefd)
	;
	S VO="90|68|13|0"
	S VO(68)=$C(1,2,79,1,0,0,0,0,0,0)_"01T"_$S(%O=5:"",1:$$BANNER^UTLREAD($G(%FN)))
	S VO(69)=$C(3,23,12,2,0,0,0,0,0,0)_"01T"_PRITABLE
	S VO(70)=$C(3,59,10,2,0,0,0,0,0,0)_"01D"_$$DAT^%ZM($P(fDBTBL9,"|",9))
	S VO(71)=$C(3,70,10,2,0,0,0,0,0,0)_"01C"_$$TIM^%ZM($P(fDBTBL9,"|",14))
	S VO(72)=$C(4,23,20,2,0,0,0,0,0,0)_"01T"_JRNID
	S VO(73)=$C(4,59,18,2,0,0,0,0,0,0)_"01T"_$P(fDBTBL9,"|",10)
	S VO(74)=$C(5,59,12,2,0,0,0,0,0,0)_"01T"_$P(fDBTBL9,"|",13)
	S VO(75)=$C(6,23,12,2,0,0,0,0,0,0)_"00U"_$P(fDBTBL9,"|",2)
	S VO(76)=$C(6,59,2,2,0,0,0,0,0,0)_"00N"_$P(fDBTBL9,"|",8)
	S VO(77)=$C(7,23,40,2,0,0,0,0,0,0)_"00T"_$P(fDBTBL9,"|",1)
	S VO(78)=$C(10,45,1,2,0,0,0,0,0,0)_"00L"_$S($G(Finan):"Y",1:"N")
	S VO(79)=$C(10,62,1,2,0,0,0,0,0,0)_"00L"_$S($G(Maint):"Y",1:"N")
	S VO(80)=$C(10,78,1,2,0,0,0,0,0,0)_"00L"_$S($G(Convt):"Y",1:"N")
	S VO(81)=$C(11,45,1,2,0,0,0,0,0,0)_"00L"_$S($G(Insert):"Y",1:"N")
	S VO(82)=$C(11,62,1,2,0,0,0,0,0,0)_"00L"_$S($G(Update):"Y",1:"N")
	S VO(83)=$C(11,78,1,2,0,0,0,0,0,0)_"00L"_$S($G(Delete):"Y",1:"N")
	S VO(84)=$C(12,45,1,2,0,0,0,0,0,0)_"00L"_$S($G(nonefd):"Y",1:"N")
	S VO(85)=$C(12,62,1,2,0,0,0,0,0,0)_"00L"_$S($G(efd):"Y",1:"N")
	S VO(86)=$C(14,4,76,2,0,0,0,0,0,0)_"00T"_$P(fDBTBL9,"|",15)
	S VO(87)=$C(17,30,51,2,0,0,0,0,0,0)_"00U"_$P(fDBTBL9,"|",7)
	S VO(88)=$C(18,30,51,2,0,0,0,0,0,0)_"00U"_$P(fDBTBL9,"|",6)
	S VO(89)=$C(21,4,76,2,0,0,0,0,0,0)_"00T"_$P(fDBTBL9,"|",11)
	S VO(90)=$C(22,4,76,2,0,0,0,0,0,0)_"00T"_$P(fDBTBL9,"|",12)
	Q
	;
VTAB	; Data Entry Control Table %TAB(NI
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
	S %MAX=22,VPT=1,VPB=23,PGM=$T(+0),DLIB="SYSDEV",DFID="DBTBL9",VSCRPP=1
	S OLNTB=23001
	;
	S VFSN("DBTBL9")="fDBTBL9"
	;
	; 
	;
	;
	; ===============  Set up entry/error checking control table
	;
	D VTBL,VDEPRE I $G(ER) Q
	;
	D ^DBSCRT8 Q  ; data entry
	;
	Q
VREQ	; Create REQ() array
	;
	;
	Q
	;
VTBL	; Create %TAB(array)
	;
	; 1 2 3  4 5   6   7-9 10-11
	;
	; DY,DX,SZ PT REQ TYPE DEL POS |NODE|ITEM NAME|TBL|FMT|PP|PRE|MIN|MAX|DEC
	;
	S %TAB(1)=$C(2,22,12)_"20U12402|3*|[DBTBL9]PRITABLE|||||||||25"
	S %TAB(2)=$C(2,58,10)_"20D12409||[DBTBL9]TLD"
	S %TAB(3)=$C(2,69,10)_"20C12414||[DBTBL9]TIME"
	S %TAB(4)=$C(3,22,20)_"20T12403|4*|[DBTBL9]JRNID"
	S %TAB(5)=$C(3,58,18)_"20T12410||[DBTBL9]USER|||||||||20"
	S %TAB(6)=$C(4,58,12)_"20T12413||[DBTBL9]PARFID"
	S %TAB(7)=$C(5,22,12)_"01U12402||[DBTBL9]SUBTABLE|[DBTBL1]FID,DES:QU ""[DBTBL1]FILETYP=6"""
	S %TAB(8)=$C(5,58,2)_"01N12408||[DBTBL9]SEQ|||||1|99"
	S %TAB(9)=$C(6,22,40)_"01T12401||[DBTBL9]DES"
	S %TAB(10)=$C(9,44,1)_"00L|*Finan|[*]@Finan"
	S %TAB(11)=$C(9,61,1)_"00L|*Maint|[*]@Maint"
	S %TAB(12)=$C(9,77,1)_"00L|*Convt|[*]@CONVT|||D VP1^V01S327"
	S %TAB(13)=$C(10,44,1)_"00L|*Insert|[*]@INSERT|||D VP2^V01S327"
	S %TAB(14)=$C(10,61,1)_"00L|*Update|[*]@UPDATE|||D VP3^V01S327"
	S %TAB(15)=$C(10,77,1)_"00L|*Delete|[*]@DELETE|||D VP4^V01S327"
	S %TAB(16)=$C(11,44,1)_"00L|*nonefd|[*]@nonefd"
	S %TAB(17)=$C(11,61,1)_"00L|*efd|[*]@EFD|||D VP5^V01S327"
	S %TAB(18)=$C(13,3,76)_"00T12415||[DBTBL9]IFCOND|||||||||255"
	S %TAB(19)=$C(16,29,51)_"00U12407||[DBTBL9]INCOLUMN|[DBTBL1D]DI,DES:LIST:QU ""[DBTBL1D]FID=<<PRITABLE>>""||D VP6^V01S327||||||250"
	S %TAB(20)=$C(17,29,51)_"00U12406||[DBTBL9]EXCOLUMN|[DBTBL1D]DI,DES:LIST:QU ""[DBTBL1D]FID=<<PRITABLE>>""||||||||250"
	S %TAB(21)=$C(20,3,76)_"00T12411||[DBTBL9]QUERY1|||D VP7^V01S327||||||100"
	S %TAB(22)=$C(21,3,76)_"00T12412||[DBTBL9]QUERY2|||D VP8^V01S327||||||100"
	;
	Q
	;
	;
VSPP	; Screen Post-Processor
	;
	;
	; Convert variables into Transaction Type code
	;
	N access,mode,efdopt
	S access=""
	I Finan S access=access_",F"                         ; Financial
	I Maint S access=access_",O"                         ; Maintenance - online
	I Convt S access=access_",B"                         ; Conversion - batch
	S $P(fDBTBL9,"|",4)=$E(access,2,99)                   ; Access Type
	;
	; Convert variables into Processing Mode
	;
	S mode=""
	I Insert S mode=mode_",I"                            ; Insert
	I Update S mode=mode_",U"                            ; Update
	I Delete S mode=mode_",D"                            ; Delete
	S $P(fDBTBL9,"|",5)=$E(mode,2,99)                         ; Processing Mode
	;
	; Convert EFD option
	;
	S efdopt=""
	I nonefd S efdopt=efdopt_",N"                        ; Non-EFD
	I efd S efdopt=efdopt_",E"                           ; EFD
	S $P(fDBTBL9,"|",3)=$E(efdopt,2,99)                        ; EFD option
	;
	K Finan,Maint,Convt,Insert,Update,Delete,nonefd,efd
	Q
	Q
VDEPRE	; Data Entry Pre-processor
	;
	I $P(fDBTBL9,"|",13)="" Q
	K UX
	D PROTECT^DBSMACRO("ALL")
	Q
	Q
	;
VPOS	; User defined post processor's
	;
VP1	;
	; I18N=OFF
	I 'X,'Finan,'Maint S ER=1,RM="Transaction Type required" Q
	Q
VP2	;
	I 'X Q
	; Make sure column information is null
	I $P(fDBTBL9,"|",7)'=""!($P(fDBTBL9,"|",6)'="") S ER=1,RM=$$^MSG(4913) Q
	Q
VP3	;
	I X Q
	; remove column definition if Update mode changed to N
	;
	D DELETE^DBSMACRO("[DBTBL9]INCOLUMN","1","0")
	D DELETE^DBSMACRO("[DBTBL9]EXCOLUMN","1","0")
	Q
VP4	;
	; I18N=OFF
	;
	; Make sure column information is null
	I X I ($P(fDBTBL9,"|",7)'="")!($P(fDBTBL9,"|",6)'="") S ER=1,RM=$$^MSG(4913) Q
	I 'X,'Insert,'Update S ER=1,RM="Processing Mode required" Q
	Q
VP5	;
	; I18N=OFF
	I 'X,'nonefd S ER=1,RM="Effective Dated Option required" Q
	; Skip columns and query prompts if not in update mode
	I Update,'Insert,'Delete Q
	D DELETE^DBSMACRO("[DBTBL9]INCOLUMN","1","0")
	D DELETE^DBSMACRO("[DBTBL9]EXCOLUMN","1","0")
	D GOTO^DBSMACRO("[DBTBL9]QUERY1") Q
	Q
VP6	;
	I X="" Q
	D DELETE^DBSMACRO("[DBTBL9]EXCOLUMN","1","0")
	D GOTO^DBSMACRO("NEXT") Q
	Q
VP7	;
	I X="" Q
	D ^DBSQRY                             ; Check query syntax
	Q
VP8	;
	I X="" Q
	D ^DBSQRY                                   ; Check query syntax
	Q
VRV(V,L)	Q V_$J("",L-$L(V))
	;
VREPRNT	D VPR,VDA,^DBSPNT() Q  ; Called by Linked screen driver
VW	D VDA,^DBSPNT(10) Q  ; Reprint from line 10
VDAPNT	D VDA,^DBSPNT(0,2) Q  ; Print data only
VDA1	
	
vSET	
	
vREAD	
	;
VDSPPRE	; Display Pre-Processor
	N %TAB,vtab ; Disable .MACRO. references to %TAB()
	;
	S ER=0
	N access,mode
	S (Finan,Maint,Convt,Insert,Update,Delete,nonefd,efd)=0
	;
	; Convert Transcation Type
	;
	S access=$P(fDBTBL9,"|",4)                            ; Access Type
	I access["F" S Finan=1                               ; Financial
	I access["O" S Maint=1                               ; Maintenance - online
	I access["B" S Convt=1                               ; Batch
	;
	; Convert Processing Mode
	;
	S mode=$P(fDBTBL9,"|",5)                                  ; Processing Mode
	I mode["I" S Insert=1                                ; Insert
	I mode["U" S Update=1                                ; Update
	I mode["D" S Delete=1                                ; Delete
	;
	; Convert EFD option
	;
	I $P(fDBTBL9,"|",3)["N" S nonefd=1                         ; Non-EFD
	I $P(fDBTBL9,"|",3)["E" S efd=1                            ; EFD
	Q
	Q
