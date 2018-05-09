 ; 
 ; **** Routine compiled from DATA-QWIK Screen DBSVAR ****
 ; 
 ; 02/24/2010 18:33 - pip
 ; 
V00S052(%O,fCUVAR) ; -  - SID= <DBSVAR> DATA-QWIK Control Table Maintenance
 ;;Copyright(c)2010 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/24/2010 18:33 - pip
 ;
 N KEYS N KVAR N VFSN N VO N VODFT N VPGM N vPSL N VSID N VSNAME
 ;
 ; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
 ;
 S:'($D(%O)#2) %O=5
 I (%O=5) D
 .	I '($D(fCUVAR)#2)  K vobj(+$G(fCUVAR)) S fCUVAR=$$vcdmNew^RecordCUVAR()
 .	Q 
 S KVAR="kill %TAB,VFSN,VO,VPTBL,vtab,ZMSKOPT" S VSID="DBSVAR" S VPGM=$T(+0) S VSNAME="DATA-QWIK Control Table Maintenance"
 S VFSN("CUVAR")="zfCUVAR"
 S vPSL=1
 ;
 ; ==================== Display blank screen         (%O=5)
 ;
 I %O=5 D VPR(.fCUVAR) D VDA1(.fCUVAR) D ^DBSPNT() Q 
 ;
 I '%O D VNEW(.fCUVAR) D VPR(.fCUVAR) D VDA1(.fCUVAR)
 I %O D VLOD(.fCUVAR) Q:$get(ER)  D VPR(.fCUVAR) D VDA1(.fCUVAR)
 ;
 ; ====================  Display Form
 D ^DBSPNT()
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=XECUTE
 I %O=2!(%O=3) D ^DBSCRT8A XECUTE:'$D(%PAGE) KVAR Q  ; Inquiry/Delete
 ; ====================  Set up data entry control table
 ;
 I %O<2 D VTAB(.fCUVAR)
 Q 
 ;
VNEW(fCUVAR) ; Initialize arrays if %O=0
 ;
 D VDEF(.fCUVAR)
 D VLOD(.fCUVAR)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
VDEF(fCUVAR) ; 
  S:'$D(vobj(fCUVAR,"%ET")) vobj(fCUVAR,"%ET")=$S(vobj(fCUVAR,-2):$G(^CUVAR("%ET")),1:"")
  S:'$D(vobj(fCUVAR,"%HELP")) vobj(fCUVAR,"%HELP")=$S(vobj(fCUVAR,-2):$G(^CUVAR("%HELP")),1:"")
  S:'$D(vobj(fCUVAR,"ALCOUNT")) vobj(fCUVAR,"ALCOUNT")=$S(vobj(fCUVAR,-2):$G(^CUVAR("ALCOUNT")),1:"")
  S:'$D(vobj(fCUVAR,"BANNER")) vobj(fCUVAR,"BANNER")=$S(vobj(fCUVAR,-2):$G(^CUVAR("BANNER")),1:"")
  S:'$D(vobj(fCUVAR,"BOBR")) vobj(fCUVAR,"BOBR")=$S(vobj(fCUVAR,-2):$G(^CUVAR("BOBR")),1:"")
  S:'$D(vobj(fCUVAR,"DBS")) vobj(fCUVAR,"DBS")=$S(vobj(fCUVAR,-2):$G(^CUVAR("DBS")),1:"")
  S:'$D(vobj(fCUVAR,"EUR")) vobj(fCUVAR,"EUR")=$S(vobj(fCUVAR,-2):$G(^CUVAR("EUR")),1:"")
  S:'$D(vobj(fCUVAR,"IRAHIST")) vobj(fCUVAR,"IRAHIST")=$S(vobj(fCUVAR,-2):$G(^CUVAR("IRAHIST")),1:"")
  S:'$D(vobj(fCUVAR,"LN")) vobj(fCUVAR,"LN")=$S(vobj(fCUVAR,-2):$G(^CUVAR("LN")),1:"")
  S:'$D(vobj(fCUVAR,"CIF")) vobj(fCUVAR,"CIF")=$S(vobj(fCUVAR,-2):$G(^CUVAR("CIF")),1:"")
  S:'$D(vobj(fCUVAR,"REGCC")) vobj(fCUVAR,"REGCC")=$S(vobj(fCUVAR,-2):$G(^CUVAR("REGCC")),1:"")
  S:'$D(vobj(fCUVAR,"ODP")) vobj(fCUVAR,"ODP")=$S(vobj(fCUVAR,-2):$G(^CUVAR("ODP")),1:"")
  S:'$D(vobj(fCUVAR,"USERNAME")) vobj(fCUVAR,"USERNAME")=$S(vobj(fCUVAR,-2):$G(^CUVAR("USERNAME")),1:"")
 I $D(^CUVAR) S ER=1 S RM=$$^MSG(2327) Q 
 I $P(vobj(fCUVAR,"%ET"),$C(124),1)=""  S:'$D(vobj(fCUVAR,-100,"%ET","%ET")) vobj(fCUVAR,-100,"%ET","%ET")="T001"_$P(vobj(fCUVAR,"%ET"),$C(124),1),vobj(fCUVAR,-100,"%ET")="" S $P(vobj(fCUVAR,"%ET"),$C(124),1)="ZE^UTLERR"
 I $P(vobj(fCUVAR,"%HELP"),$C(124),1)=""  S:'$D(vobj(fCUVAR,-100,"%HELP","%HELP")) vobj(fCUVAR,-100,"%HELP","%HELP")="N001"_$P(vobj(fCUVAR,"%HELP"),$C(124),1),vobj(fCUVAR,-100,"%HELP")="" S $P(vobj(fCUVAR,"%HELP"),$C(124),1)=0
 I $P(vobj(fCUVAR,"%HELP"),$C(124),2)=""  S:'$D(vobj(fCUVAR,-100,"%HELP","%HELPCNT")) vobj(fCUVAR,-100,"%HELP","%HELPCNT")="N002"_$P(vobj(fCUVAR,"%HELP"),$C(124),2),vobj(fCUVAR,-100,"%HELP")="" S $P(vobj(fCUVAR,"%HELP"),$C(124),2)=0
 I $P(vobj(fCUVAR,"ALCOUNT"),$C(124),1)=""  S:'$D(vobj(fCUVAR,-100,"ALCOUNT","ALCOUNT")) vobj(fCUVAR,-100,"ALCOUNT","ALCOUNT")="N001"_$P(vobj(fCUVAR,"ALCOUNT"),$C(124),1),vobj(fCUVAR,-100,"ALCOUNT")="" S $P(vobj(fCUVAR,"ALCOUNT"),$C(124),1)=5
 I $P(vobj(fCUVAR,"BANNER"),$C(124),1)=""  S:'$D(vobj(fCUVAR,-100,"BANNER","BANNER")) vobj(fCUVAR,-100,"BANNER","BANNER")="L001"_$P(vobj(fCUVAR,"BANNER"),$C(124),1),vobj(fCUVAR,-100,"BANNER")="" S $P(vobj(fCUVAR,"BANNER"),$C(124),1)=1
 I $P(vobj(fCUVAR,"BOBR"),$C(124),1)=""  S:'$D(vobj(fCUVAR,-100,"BOBR","BOBR")) vobj(fCUVAR,-100,"BOBR","BOBR")="N001"_$P(vobj(fCUVAR,"BOBR"),$C(124),1),vobj(fCUVAR,-100,"BOBR")="" S $P(vobj(fCUVAR,"BOBR"),$C(124),1)=0
 I $P(vobj(fCUVAR,"DBS"),$C(124),3)=""  S:'$D(vobj(fCUVAR,-100,"DBS","DBSPH132")) vobj(fCUVAR,-100,"DBS","DBSPH132")="T003"_$P(vobj(fCUVAR,"DBS"),$C(124),3),vobj(fCUVAR,-100,"DBS")="" S $P(vobj(fCUVAR,"DBS"),$C(124),3)="SCAU$HELP:OOE_SCA132.EXP"
 I $P(vobj(fCUVAR,"DBS"),$C(124),2)=""  S:'$D(vobj(fCUVAR,-100,"DBS","DBSPH80")) vobj(fCUVAR,-100,"DBS","DBSPH80")="T002"_$P(vobj(fCUVAR,"DBS"),$C(124),2),vobj(fCUVAR,-100,"DBS")="" S $P(vobj(fCUVAR,"DBS"),$C(124),2)="SCAU$HELP:OOE_SCA80.EXP"
 I $P(vobj(fCUVAR,"DBS"),$C(124),6)=""  S:'$D(vobj(fCUVAR,-100,"DBS","EDITMASK")) vobj(fCUVAR,-100,"DBS","EDITMASK")="T006"_$P(vobj(fCUVAR,"DBS"),$C(124),6),vobj(fCUVAR,-100,"DBS")="" S $P(vobj(fCUVAR,"DBS"),$C(124),6)="US"
 I $P(vobj(fCUVAR,"EUR"),$C(124),17)=""  S:'$D(vobj(fCUVAR,-100,"EUR","EMURND")) vobj(fCUVAR,-100,"EUR","EMURND")="N017"_$P(vobj(fCUVAR,"EUR"),$C(124),17)_"||||||||||[STBLEMURND]EMURND",vobj(fCUVAR,-100,"EUR")="" S $P(vobj(fCUVAR,"EUR"),$C(124),17)=9
 I $P(vobj(fCUVAR,"IRAHIST"),$C(124),1)=""  S:'$D(vobj(fCUVAR,-100,"IRAHIST","IRAHIST")) vobj(fCUVAR,-100,"IRAHIST","IRAHIST")="N001"_$P(vobj(fCUVAR,"IRAHIST"),$C(124),1),vobj(fCUVAR,-100,"IRAHIST")="" S $P(vobj(fCUVAR,"IRAHIST"),$C(124),1)=365
 I $P(vobj(fCUVAR,"LN"),$C(124),37)=""  S:'$D(vobj(fCUVAR,-100,"LN","LNCC")) vobj(fCUVAR,-100,"LN","LNCC")="N037"_$P(vobj(fCUVAR,"LN"),$C(124),37)_"||||||||||[STBLMPA]MPAC",vobj(fCUVAR,-100,"LN")="" S $P(vobj(fCUVAR,"LN"),$C(124),37)=0
 I $P(vobj(fCUVAR,"LN"),$C(124),34)=""  S:'$D(vobj(fCUVAR,-100,"LN","LNCFP")) vobj(fCUVAR,-100,"LN","LNCFP")="N034"_$P(vobj(fCUVAR,"LN"),$C(124),34)_"||||||||||[STBLMPA]MPAC",vobj(fCUVAR,-100,"LN")="" S $P(vobj(fCUVAR,"LN"),$C(124),34)=0
 I $P(vobj(fCUVAR,"LN"),$C(124),36)=""  S:'$D(vobj(fCUVAR,-100,"LN","LNCPI")) vobj(fCUVAR,-100,"LN","LNCPI")="N036"_$P(vobj(fCUVAR,"LN"),$C(124),36)_"||||||||||[STBLMPA]MPAC",vobj(fCUVAR,-100,"LN")="" S $P(vobj(fCUVAR,"LN"),$C(124),36)=0
 I $P(vobj(fCUVAR,"LN"),$C(124),35)=""  S:'$D(vobj(fCUVAR,-100,"LN","LNCPP")) vobj(fCUVAR,-100,"LN","LNCPP")="N035"_$P(vobj(fCUVAR,"LN"),$C(124),35)_"||||||||||[STBLMPA]MPAC",vobj(fCUVAR,-100,"LN")="" S $P(vobj(fCUVAR,"LN"),$C(124),35)=0
 I $P(vobj(fCUVAR,"CIF"),$C(124),2)=""  S:'$D(vobj(fCUVAR,-100,"CIF","MAXCIFL")) vobj(fCUVAR,-100,"CIF","MAXCIFL")="N002"_$P(vobj(fCUVAR,"CIF"),$C(124),2),vobj(fCUVAR,-100,"CIF")="" S $P(vobj(fCUVAR,"CIF"),$C(124),2)=12
 I $P(vobj(fCUVAR,"CIF"),$C(124),1)=""  S:'$D(vobj(fCUVAR,-100,"CIF","MINCIFL")) vobj(fCUVAR,-100,"CIF","MINCIFL")="N001"_$P(vobj(fCUVAR,"CIF"),$C(124),1),vobj(fCUVAR,-100,"CIF")="" S $P(vobj(fCUVAR,"CIF"),$C(124),1)=1
 I $P(vobj(fCUVAR,"REGCC"),$C(124),11)=""  S:'$D(vobj(fCUVAR,-100,"REGCC","OBDE")) vobj(fCUVAR,-100,"REGCC","OBDE")="L011"_$P(vobj(fCUVAR,"REGCC"),$C(124),11),vobj(fCUVAR,-100,"REGCC")="" S $P(vobj(fCUVAR,"REGCC"),$C(124),11)=0
 I $P(vobj(fCUVAR,"ODP"),$C(124),1)=""  S:'$D(vobj(fCUVAR,-100,"ODP","ODP")) vobj(fCUVAR,-100,"ODP","ODP")="L001"_$P(vobj(fCUVAR,"ODP"),$C(124),1),vobj(fCUVAR,-100,"ODP")="" S $P(vobj(fCUVAR,"ODP"),$C(124),1)=0
 I $P(vobj(fCUVAR,"CIF"),$C(124),3)=""  S:'$D(vobj(fCUVAR,-100,"CIF","ORCIFN")) vobj(fCUVAR,-100,"CIF","ORCIFN")="L003"_$P(vobj(fCUVAR,"CIF"),$C(124),3),vobj(fCUVAR,-100,"CIF")="" S $P(vobj(fCUVAR,"CIF"),$C(124),3)=1
 I $P(vobj(fCUVAR,"ODP"),$C(124),2)=""  S:'$D(vobj(fCUVAR,-100,"ODP","SFEEOPT")) vobj(fCUVAR,-100,"ODP","SFEEOPT")="L002"_$P(vobj(fCUVAR,"ODP"),$C(124),2),vobj(fCUVAR,-100,"ODP")="" S $P(vobj(fCUVAR,"ODP"),$C(124),2)=0
 I $P(vobj(fCUVAR,"CIF"),$C(124),5)=""  S:'$D(vobj(fCUVAR,-100,"CIF","TAXREQ")) vobj(fCUVAR,-100,"CIF","TAXREQ")="N005"_$P(vobj(fCUVAR,"CIF"),$C(124),5)_"||||||||||[STBLTAXREQ]TAXREQ",vobj(fCUVAR,-100,"CIF")="" S $P(vobj(fCUVAR,"CIF"),$C(124),5)=1
 I $P(vobj(fCUVAR,"USERNAME"),$C(124),1)=""  S:'$D(vobj(fCUVAR,-100,"USERNAME","USERNAME")) vobj(fCUVAR,-100,"USERNAME","USERNAME")="T001"_$P(vobj(fCUVAR,"USERNAME"),$C(124),1),vobj(fCUVAR,-100,"USERNAME")="" S $P(vobj(fCUVAR,"USERNAME"),$C(124),1)=0
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;
VLOD(fCUVAR) ; Load data from disc - %O = (1-5)
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VPR(fCUVAR) ; Display screen prompts
 S VO="52||13|"
 S VO(0)="|0"
 S VO(1)=$C(1,1,80,0,0,0,0,0,0,0)_"11Tlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqk"
 S VO(2)=$C(2,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(3)=$C(2,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(4)=$C(3,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(5)=$C(3,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(6)=$C(4,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(7)=$C(4,15,14,1,0,0,0,0,0,0)_"01T Company Name:"
 S VO(8)=$C(4,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(9)=$C(5,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(10)=$C(5,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(11)=$C(6,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(12)=$C(6,7,25,0,0,0,0,0,0,0)_"01TDirect VMS Access Option:"
 S VO(13)=$C(6,47,19,1,0,0,0,0,0,0)_"01T Format Table Name:"
 S VO(14)=$C(6,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(15)=$C(7,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(16)=$C(7,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(17)=$C(8,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(18)=$C(8,2,17,1,0,0,0,0,0,0)_"01T Login Message(s)"
 S VO(19)=$C(8,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(20)=$C(9,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(21)=$C(9,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(22)=$C(10,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(23)=$C(10,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(24)=$C(11,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(25)=$C(11,36,16,1,0,0,0,0,0,0)_"01T Driver Message "
 S VO(26)=$C(11,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(27)=$C(12,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(28)=$C(12,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(29)=$C(13,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(30)=$C(13,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(31)=$C(14,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(32)=$C(14,15,22,0,0,0,0,0,0,0)_"01TAlignment Print Count:"
 S VO(33)=$C(14,64,1,0,0,0,0,0,0,0)_"01Tx"
 S VO(34)=$C(14,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(35)=$C(15,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(36)=$C(15,17,20,0,0,0,0,0,0,0)_"01TDisplay Banner Page:"
 S VO(37)=$C(15,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(38)=$C(16,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(39)=$C(16,15,22,0,0,0,0,0,0,0)_"01TField Overflow Option:"
 S VO(40)=$C(16,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(41)=$C(17,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(42)=$C(17,13,24,0,0,0,0,0,0,0)_"01T80 Column Report Header:"
 S VO(43)=$C(17,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(44)=$C(18,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(45)=$C(18,12,25,0,0,0,0,0,0,0)_"01T132 Column Report Header:"
 S VO(46)=$C(18,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(47)=$C(19,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(48)=$C(19,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(49)=$C(20,1,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(50)=$C(20,2,35,0,0,0,0,0,0,0)_"01TScreen Header Name (CTRL/P option):"
 S VO(51)=$C(20,80,1,0,0,0,0,0,0,0)_"11Tx"
 S VO(52)=$C(21,1,80,0,0,0,0,0,0,0)_"11Tmqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqj"
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VDA1(fCUVAR) ; Display screen data
  S:'$D(vobj(fCUVAR,"CONAM")) vobj(fCUVAR,"CONAM")=$S(vobj(fCUVAR,-2):$G(^CUVAR("CONAM")),1:"")
  S:'$D(vobj(fCUVAR,"USERNAME")) vobj(fCUVAR,"USERNAME")=$S(vobj(fCUVAR,-2):$G(^CUVAR("USERNAME")),1:"")
  S:'$D(vobj(fCUVAR,"LOGINMSG")) vobj(fCUVAR,"LOGINMSG")=$S(vobj(fCUVAR,-2):$G(^CUVAR("LOGINMSG")),1:"")
  S:'$D(vobj(fCUVAR,"DRVMSG")) vobj(fCUVAR,"DRVMSG")=$S(vobj(fCUVAR,-2):$G(^CUVAR("DRVMSG")),1:"")
  S:'$D(vobj(fCUVAR,"ALCOUNT")) vobj(fCUVAR,"ALCOUNT")=$S(vobj(fCUVAR,-2):$G(^CUVAR("ALCOUNT")),1:"")
  S:'$D(vobj(fCUVAR,"BANNER")) vobj(fCUVAR,"BANNER")=$S(vobj(fCUVAR,-2):$G(^CUVAR("BANNER")),1:"")
  S:'$D(vobj(fCUVAR,"DBS")) vobj(fCUVAR,"DBS")=$S(vobj(fCUVAR,-2):$G(^CUVAR("DBS")),1:"")
 N V
 I %O=5 N ZMSKOPT
 I   S (ZMSKOPT)=""
 E  S ZMSKOPT=$get(ZMSKOPT)
 ;
 S ZMSKOPT=$get(ZMSKOPT)
 ;
 S VO="66|53|13|"
 S VO(53)=$C(2,2,79,1,0,0,0,0,0,0)_"01T"_$S(%O=5:"",1:$$BANNER^DBSGETID($get(%FN)))
 S VO(54)=$C(4,30,40,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fCUVAR,"CONAM"),$C(124),1),1,40)
 S VO(55)=$C(6,33,7,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fCUVAR,"USERNAME"),$C(124),1),1,7)
 S VO(56)=$C(6,67,10,2,0,0,0,0,0,0)_"00T"_$get(ZMSKOPT)
 S VO(57)=$C(8,20,60,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fCUVAR,"LOGINMSG"),$C(124),1),1,60)
 S VO(58)=$C(9,20,60,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fCUVAR,"LOGINMSG"),$C(124),2),1,60)
 S VO(59)=$C(10,20,60,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fCUVAR,"LOGINMSG"),$C(124),3),1,60)
 S VO(60)=$C(12,2,78,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fCUVAR,"DRVMSG"),$C(124),1),1,78)
 S VO(61)=$C(14,38,2,2,0,0,0,0,0,0)_"00N"_$P(vobj(fCUVAR,"ALCOUNT"),$C(124),1)
 S VO(62)=$C(15,38,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fCUVAR,"BANNER"),$C(124),1):"Y",1:"N")
 S VO(63)=$C(16,38,1,2,0,0,0,0,0,0)_"00L"_$S($P(vobj(fCUVAR,"DBS"),$C(124),1):"Y",1:"N")
 S VO(64)=$C(17,38,40,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fCUVAR,"DBS"),$C(124),2),1,40)
 S VO(65)=$C(18,38,40,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fCUVAR,"DBS"),$C(124),3),1,40)
 S VO(66)=$C(20,38,12,2,0,0,0,0,0,0)_"00T"_$E($P(vobj(fCUVAR,"DBS"),$C(124),5),1,12)
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VTAB(fCUVAR) ; 
 ;
 K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
 S %MAX=13 S VPT=1 S VPB=21 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="CUVAR"
 S OLNTB=21001
 ;
 S VFSN("CUVAR")="zfCUVAR"
 ;
 ;
 S %TAB(1)=$C(3,29,40)_"01T12401|1|[CUVAR]CONAM"
 S %TAB(2)=$C(5,32,7)_"00T12401|1|[CUVAR]USERNAME"
 S %TAB(3)=$C(5,66,10)_"01T|*ZMSKOPT|[*]@ZMSKOPT|^DBCTL(""SYS"",""*RFMT"","
 S %TAB(4)=$C(7,19,60)_"00T12401|1|[CUVAR]LOGINMSG1"
 S %TAB(5)=$C(8,19,60)_"00T12402|1|[CUVAR]LOGINMSG2"
 S %TAB(6)=$C(9,19,60)_"00T12403|1|[CUVAR]LOGINMSG3"
 S %TAB(7)=$C(11,1,78)_"00T12401|1|[CUVAR]DRVMSG"
 S %TAB(8)=$C(13,37,2)_"00N12401|1|[CUVAR]ALCOUNT|||||1|20"
 S %TAB(9)=$C(14,37,1)_"00L12401|1|[CUVAR]BANNER"
 S %TAB(10)=$C(15,37,1)_"00L12401|1|[CUVAR]FLDOVF"
 S %TAB(11)=$C(16,37,40)_"00T12402|1|[CUVAR]DBSPH80"
 S %TAB(12)=$C(17,37,40)_"00T12403|1|[CUVAR]DBSPH132"
 S %TAB(13)=$C(19,37,12)_"00T12405|1|[CUVAR]DBSHDR|[DBTBL2]"
 D VTBL(.fCUVAR)
 D ^DBSCRT8 ; data entry
 Q 
 ;
VREQ ; Create REQ() array
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
VTBL(fCUVAR) ; Create %TAB(array)
 ; 1 2 3  4 5   6   7-9 10-11
 ; DY,DX,SZ PT REQ TYPE DEL POS |NODE|ITEM NAME|TBL|FMT|PP|PRE|MIN|MAX|DEC
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
VRV(V,L) ; 
 Q V_$J("",L-$L(V))
VREPRNT ; 
 D VPR(.fCUVAR)
 D VDA1(.fCUVAR)
 D ^DBSPNT()
 Q 
 ;
VW(fCUVAR) ; 
 D VDA1(.fCUVAR)
 D ^DBSPNT(10)
 Q 
 ;
VDAPNT(fCUVAR) ; 
 D VDA1(.fCUVAR)
 D ^DBSPNT(0,2)
 Q 
 ;
VDA ; 
 D VDA1(.fCUVAR)
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
 ;
vSET(sn,di,X) ; 
 I sn="CUVAR" D vSET1(.fCUVAR,di,X)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
vSET1(fCUVAR,di,X) ; 
  D propSet^DBSDYNRA(fCUVAR,di,X,1,0)
 ;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
 Q 
 ;
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di) ; 
 I fid="CUVAR" Q $$vREAD1(.fCUVAR,di)
 Q ""
vREAD1(fCUVAR,di) ; 
 Q $$propGet^DBSDYNRA(fCUVAR,di)
 ;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
