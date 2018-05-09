V01S365(%O,fCUVAR)	; -  - SID= <CUVARX> Institution Variables
	;
	; **** Routine compiled from DATA-QWIK Screen CUVARX ****
	;
	; 11/09/2007 16:51 - chenardp
	;
	;;Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 16:51 - chenardp
	;
	N KEYS N KVAR N VFSN N VO N VODFT N VPGM N vPSL N VSID N VSNAME
	;
	; %O (0-Create  1-Modify  2-Inquiry  3-Delete  4-Print  5-Blank screen)
	;
	S:'($D(%O)#2) %O=5
	I (%O=5) D
	.	I '($D(fCUVAR)#2) K vobj(+$G(fCUVAR)) S fCUVAR=$$vDbNew1()
	.	Q 
	S KVAR="kill %TAB,VFSN,VO,VPTBL,vtab" S VSID="CUVARX" S VPGM=$T(+0) S VSNAME="Institution Variables"
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
VNEW(fCUVAR)	; Initialize arrays if %O=0
	;
	D VDEF(.fCUVAR)
	D VLOD(.fCUVAR)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
VDEF(fCUVAR)	;
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
	I $P(vobj(fCUVAR,"%ET"),$C(124),1)="" S:'$D(vobj(fCUVAR,-100,"%ET","%ET")) vobj(fCUVAR,-100,"%ET","%ET")="T001"_$P(vobj(fCUVAR,"%ET"),$C(124),1) S vobj(fCUVAR,-100,"%ET")="",$P(vobj(fCUVAR,"%ET"),$C(124),1)="ZE^UTLERR"
	I $P(vobj(fCUVAR,"%HELP"),$C(124),1)="" S:'$D(vobj(fCUVAR,-100,"%HELP","%HELP")) vobj(fCUVAR,-100,"%HELP","%HELP")="N001"_$P(vobj(fCUVAR,"%HELP"),$C(124),1) S vobj(fCUVAR,-100,"%HELP")="",$P(vobj(fCUVAR,"%HELP"),$C(124),1)=0
	I $P(vobj(fCUVAR,"%HELP"),$C(124),2)="" S:'$D(vobj(fCUVAR,-100,"%HELP","%HELPCNT")) vobj(fCUVAR,-100,"%HELP","%HELPCNT")="N002"_$P(vobj(fCUVAR,"%HELP"),$C(124),2) S vobj(fCUVAR,-100,"%HELP")="",$P(vobj(fCUVAR,"%HELP"),$C(124),2)=0
	I $P(vobj(fCUVAR,"ALCOUNT"),$C(124),1)="" S:'$D(vobj(fCUVAR,-100,"ALCOUNT","ALCOUNT")) vobj(fCUVAR,-100,"ALCOUNT","ALCOUNT")="N001"_$P(vobj(fCUVAR,"ALCOUNT"),$C(124),1) S vobj(fCUVAR,-100,"ALCOUNT")="",$P(vobj(fCUVAR,"ALCOUNT"),$C(124),1)=5
	I $P(vobj(fCUVAR,"BANNER"),$C(124),1)="" S:'$D(vobj(fCUVAR,-100,"BANNER","BANNER")) vobj(fCUVAR,-100,"BANNER","BANNER")="L001"_$P(vobj(fCUVAR,"BANNER"),$C(124),1) S vobj(fCUVAR,-100,"BANNER")="",$P(vobj(fCUVAR,"BANNER"),$C(124),1)=1
	I $P(vobj(fCUVAR,"BOBR"),$C(124),1)="" S:'$D(vobj(fCUVAR,-100,"BOBR","BOBR")) vobj(fCUVAR,-100,"BOBR","BOBR")="N001"_$P(vobj(fCUVAR,"BOBR"),$C(124),1) S vobj(fCUVAR,-100,"BOBR")="",$P(vobj(fCUVAR,"BOBR"),$C(124),1)=0
	I $P(vobj(fCUVAR,"DBS"),$C(124),3)="" S:'$D(vobj(fCUVAR,-100,"DBS","DBSPH132")) vobj(fCUVAR,-100,"DBS","DBSPH132")="T003"_$P(vobj(fCUVAR,"DBS"),$C(124),3) S vobj(fCUVAR,-100,"DBS")="",$P(vobj(fCUVAR,"DBS"),$C(124),3)="SCAU$HELP:OOE_SCA132.EXP"
	I $P(vobj(fCUVAR,"DBS"),$C(124),2)="" S:'$D(vobj(fCUVAR,-100,"DBS","DBSPH80")) vobj(fCUVAR,-100,"DBS","DBSPH80")="T002"_$P(vobj(fCUVAR,"DBS"),$C(124),2) S vobj(fCUVAR,-100,"DBS")="",$P(vobj(fCUVAR,"DBS"),$C(124),2)="SCAU$HELP:OOE_SCA80.EXP"
	I $P(vobj(fCUVAR,"DBS"),$C(124),6)="" S:'$D(vobj(fCUVAR,-100,"DBS","EDITMASK")) vobj(fCUVAR,-100,"DBS","EDITMASK")="T006"_$P(vobj(fCUVAR,"DBS"),$C(124),6) S vobj(fCUVAR,-100,"DBS")="",$P(vobj(fCUVAR,"DBS"),$C(124),6)="US"
	I $P(vobj(fCUVAR,"EUR"),$C(124),17)="" S:'$D(vobj(fCUVAR,-100,"EUR","EMURND")) vobj(fCUVAR,-100,"EUR","EMURND")="N017"_$P(vobj(fCUVAR,"EUR"),$C(124),17)_"||||||||||DESC]EMURND" S vobj(fCUVAR,-100,"EUR")="",$P(vobj(fCUVAR,"EUR"),$C(124),17)=9
	I $P(vobj(fCUVAR,"IRAHIST"),$C(124),1)="" S:'$D(vobj(fCUVAR,-100,"IRAHIST","IRAHIST")) vobj(fCUVAR,-100,"IRAHIST","IRAHIST")="N001"_$P(vobj(fCUVAR,"IRAHIST"),$C(124),1) S vobj(fCUVAR,-100,"IRAHIST")="",$P(vobj(fCUVAR,"IRAHIST"),$C(124),1)=365
	I $P(vobj(fCUVAR,"LN"),$C(124),37)="" S:'$D(vobj(fCUVAR,-100,"LN","LNCC")) vobj(fCUVAR,-100,"LN","LNCC")="N037"_$P(vobj(fCUVAR,"LN"),$C(124),37)_"||||||||||DES]MPAC" S vobj(fCUVAR,-100,"LN")="",$P(vobj(fCUVAR,"LN"),$C(124),37)=0
	I $P(vobj(fCUVAR,"LN"),$C(124),34)="" S:'$D(vobj(fCUVAR,-100,"LN","LNCFP")) vobj(fCUVAR,-100,"LN","LNCFP")="N034"_$P(vobj(fCUVAR,"LN"),$C(124),34)_"||||||||||DES]MPAC" S vobj(fCUVAR,-100,"LN")="",$P(vobj(fCUVAR,"LN"),$C(124),34)=0
	I $P(vobj(fCUVAR,"LN"),$C(124),36)="" S:'$D(vobj(fCUVAR,-100,"LN","LNCPI")) vobj(fCUVAR,-100,"LN","LNCPI")="N036"_$P(vobj(fCUVAR,"LN"),$C(124),36)_"||||||||||DES]MPAC" S vobj(fCUVAR,-100,"LN")="",$P(vobj(fCUVAR,"LN"),$C(124),36)=0
	I $P(vobj(fCUVAR,"LN"),$C(124),35)="" S:'$D(vobj(fCUVAR,-100,"LN","LNCPP")) vobj(fCUVAR,-100,"LN","LNCPP")="N035"_$P(vobj(fCUVAR,"LN"),$C(124),35)_"||||||||||DES]MPAC" S vobj(fCUVAR,-100,"LN")="",$P(vobj(fCUVAR,"LN"),$C(124),35)=0
	I $P(vobj(fCUVAR,"CIF"),$C(124),2)="" S:'$D(vobj(fCUVAR,-100,"CIF","MAXCIFL")) vobj(fCUVAR,-100,"CIF","MAXCIFL")="N002"_$P(vobj(fCUVAR,"CIF"),$C(124),2) S vobj(fCUVAR,-100,"CIF")="",$P(vobj(fCUVAR,"CIF"),$C(124),2)=12
	I $P(vobj(fCUVAR,"CIF"),$C(124),1)="" S:'$D(vobj(fCUVAR,-100,"CIF","MINCIFL")) vobj(fCUVAR,-100,"CIF","MINCIFL")="N001"_$P(vobj(fCUVAR,"CIF"),$C(124),1) S vobj(fCUVAR,-100,"CIF")="",$P(vobj(fCUVAR,"CIF"),$C(124),1)=1
	I $P(vobj(fCUVAR,"REGCC"),$C(124),11)="" S:'$D(vobj(fCUVAR,-100,"REGCC","OBDE")) vobj(fCUVAR,-100,"REGCC","OBDE")="L011"_$P(vobj(fCUVAR,"REGCC"),$C(124),11) S vobj(fCUVAR,-100,"REGCC")="",$P(vobj(fCUVAR,"REGCC"),$C(124),11)=0
	I $P(vobj(fCUVAR,"ODP"),$C(124),1)="" S:'$D(vobj(fCUVAR,-100,"ODP","ODP")) vobj(fCUVAR,-100,"ODP","ODP")="L001"_$P(vobj(fCUVAR,"ODP"),$C(124),1) S vobj(fCUVAR,-100,"ODP")="",$P(vobj(fCUVAR,"ODP"),$C(124),1)=0
	I $P(vobj(fCUVAR,"CIF"),$C(124),3)="" S:'$D(vobj(fCUVAR,-100,"CIF","ORCIFN")) vobj(fCUVAR,-100,"CIF","ORCIFN")="L003"_$P(vobj(fCUVAR,"CIF"),$C(124),3) S vobj(fCUVAR,-100,"CIF")="",$P(vobj(fCUVAR,"CIF"),$C(124),3)=1
	I $P(vobj(fCUVAR,"ODP"),$C(124),2)="" S:'$D(vobj(fCUVAR,-100,"ODP","SFEEOPT")) vobj(fCUVAR,-100,"ODP","SFEEOPT")="L002"_$P(vobj(fCUVAR,"ODP"),$C(124),2) S vobj(fCUVAR,-100,"ODP")="",$P(vobj(fCUVAR,"ODP"),$C(124),2)=0
	I $P(vobj(fCUVAR,"CIF"),$C(124),5)="" S:'$D(vobj(fCUVAR,-100,"CIF","TAXREQ")) vobj(fCUVAR,-100,"CIF","TAXREQ")="N005"_$P(vobj(fCUVAR,"CIF"),$C(124),5)_"||||||||||DSC]TAXREQ" S vobj(fCUVAR,-100,"CIF")="",$P(vobj(fCUVAR,"CIF"),$C(124),5)=1
	I $P(vobj(fCUVAR,"USERNAME"),$C(124),1)="" S:'$D(vobj(fCUVAR,-100,"USERNAME","USERNAME")) vobj(fCUVAR,-100,"USERNAME","USERNAME")="T001"_$P(vobj(fCUVAR,"USERNAME"),$C(124),1) S vobj(fCUVAR,-100,"USERNAME")="",$P(vobj(fCUVAR,"USERNAME"),$C(124),1)=0
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
VLOD(fCUVAR)	; Load data from disc - %O = (1-5)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VPR(fCUVAR)	; Display screen prompts
	S VO="8||13|0"
	S VO(0)="|0"
	S VO(1)=$C(2,28,21,0,0,0,0,0,0,0)_"01TInstitution Variables"
	S VO(2)=$C(5,1,11,0,0,0,0,0,0,0)_"01TError Trap:"
	S VO(3)=$C(6,1,23,0,0,0,0,0,0,0)_"01TSystem Processing Date:"
	S VO(4)=$C(7,1,13,0,0,0,0,0,0,0)_"01TCompany Name:"
	S VO(5)=$C(8,1,17,0,0,0,0,0,0,0)_"01TCompany Mnemonic:"
	S VO(6)=$C(9,1,23,0,0,0,0,0,0,0)_"01TProfile Version Number:"
	S VO(7)=$C(11,3,14,0,0,0,0,0,0,0)_"01TLogin Messages"
	S VO(8)=$C(17,1,14,0,0,0,0,0,0,0)_"01TDriver Message"
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VDA1(fCUVAR)	; Display screen data
	 S:'$D(vobj(fCUVAR,"%ET")) vobj(fCUVAR,"%ET")=$S(vobj(fCUVAR,-2):$G(^CUVAR("%ET")),1:"")
	 S:'$D(vobj(fCUVAR,2)) vobj(fCUVAR,2)=$S(vobj(fCUVAR,-2):$G(^CUVAR(2)),1:"")
	 S:'$D(vobj(fCUVAR,"CONAM")) vobj(fCUVAR,"CONAM")=$S(vobj(fCUVAR,-2):$G(^CUVAR("CONAM")),1:"")
	 S:'$D(vobj(fCUVAR,"CO")) vobj(fCUVAR,"CO")=$S(vobj(fCUVAR,-2):$G(^CUVAR("CO")),1:"")
	 S:'$D(vobj(fCUVAR,"%VN")) vobj(fCUVAR,"%VN")=$S(vobj(fCUVAR,-2):$G(^CUVAR("%VN")),1:"")
	 S:'$D(vobj(fCUVAR,"LOGINMSG")) vobj(fCUVAR,"LOGINMSG")=$S(vobj(fCUVAR,-2):$G(^CUVAR("LOGINMSG")),1:"")
	 S:'$D(vobj(fCUVAR,"DRVMSG")) vobj(fCUVAR,"DRVMSG")=$S(vobj(fCUVAR,-2):$G(^CUVAR("DRVMSG")),1:"")
	N V
	;
	S VO="17|9|13|0"
	S VO(9)=$C(5,13,17,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fCUVAR,"%ET"),$C(124),1)),1,17)
	S VO(10)=$C(6,25,10,2,0,0,0,0,0,0)_"00D"_$$vdat2str(($P(vobj(fCUVAR,2),$C(124),1)),"MM/DD/YEAR")
	S VO(11)=$C(7,15,40,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fCUVAR,"CONAM"),$C(124),1)),1,40)
	S VO(12)=$C(8,19,12,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fCUVAR,"CO"),$C(124),1)),1,12)
	S V=$S($P(vobj(fCUVAR,"%VN"),$C(124),1)="":"",1:$J($P(vobj(fCUVAR,"%VN"),$C(124),1),0,1)) S VO(13)=$C(9,25,3,2,0,0,0,0,0,0)_"00N"_$S($P(vobj(fCUVAR,"%VN"),$C(124),1)="":"",1:$J($P(vobj(fCUVAR,"%VN"),$C(124),1),0,1))
	S VO(14)=$C(12,1,60,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fCUVAR,"LOGINMSG"),$C(124),1)),1,60)
	S VO(15)=$C(13,1,60,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fCUVAR,"LOGINMSG"),$C(124),2)),1,60)
	S VO(16)=$C(14,1,60,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fCUVAR,"LOGINMSG"),$C(124),3)),1,60)
	S VO(17)=$C(18,1,78,2,0,0,0,0,0,0)_"00T"_$E(($P(vobj(fCUVAR,"DRVMSG"),$C(124),1)),1,78)
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTAB(fCUVAR)	;
	;
	K VSCRPP,REQ,%TAB,%MOD,%MODOFF,%MODGRP,%REPREQ,vtab
	S %MAX=9 S VPT=2 S VPB=18 S PGM=$T(+0) S DLIB="SYSDEV" S DFID="CUVAR"
	S OLNTB=18001
	;
	S VFSN("CUVAR")="zfCUVAR"
	;
	;
	S %TAB(1)=$C(4,12,17)_"00T12401|1|[CUVAR]%ET"
	S %TAB(2)=$C(5,24,10)_"00D12401|1|[CUVAR]TJD"
	S %TAB(3)=$C(6,14,40)_"00T12401|1|[CUVAR]CONAM"
	S %TAB(4)=$C(7,18,12)_"00T12401|1|[CUVAR]CO"
	S %TAB(5)=$C(8,24,3)_"00N12401|1|[CUVAR]%VN|||||||1"
	S %TAB(6)=$C(11,0,60)_"00T12401|1|[CUVAR]LOGINMSG1"
	S %TAB(7)=$C(12,0,60)_"00T12402|1|[CUVAR]LOGINMSG2"
	S %TAB(8)=$C(13,0,60)_"00T12403|1|[CUVAR]LOGINMSG3"
	S %TAB(9)=$C(17,0,78)_"00T12401|1|[CUVAR]DRVMSG"
	D VTBL(.fCUVAR)
	D ^DBSCRT8 ; data entry
	Q 
	;
VREQ	; Create REQ() array
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	Q 
	;
VTBL(fCUVAR)	;Create %TAB(array)
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
VRV(V,L)	;
	Q V_$J("",L-$L(V))
VREPRNT	;
	D VPR(.fCUVAR)
	D VDA1(.fCUVAR)
	D ^DBSPNT()
	Q 
	;
VW(fCUVAR)	;
	D VDA1(.fCUVAR)
	D ^DBSPNT(10)
	Q 
	;
VDAPNT(fCUVAR)	;
	D VDA1(.fCUVAR)
	D ^DBSPNT(0,2)
	Q 
	;
VDA	;
	D VDA1(.fCUVAR)
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
	;
vSET(sn,di,X)	;
	I sn="CUVAR" D vSET1(.fCUVAR,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
vSET1(fCUVAR,di,X)	;
	D vCoInd1(fCUVAR,di,X)
	;  #ACCEPT Date=11/5/03;PGM=Screen Compiler;CR=UNKNOWN;GROUP=SYNTAX
	Q 
	;
	;  #ACCEPT DATE=11/05/03; PGM=Screen Compiler;CR=UNKNOWN;GROUP=DEAD
vREAD(fid,di)	;
	I fid="CUVAR" Q $$vREAD1(.fCUVAR,di)
	Q ""
vREAD1(fCUVAR,di)	;
	Q $$vCoInd2(fCUVAR,di)
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
vCoInd1(vOid,vCol,vVal)	; RecordCUVAR.setColumn(1,0)
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("CUVAR",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	N vTyp S vTyp=$P(vP,"|",6)
	;
	N vCmp S vCmp=$P(vP,"|",14)
	I vCmp'="" S $ZS="-1,"_$ZPOS_","_"%PSL-E-INVALIDREF" X $ZT
	;
	S vPos=$P(vP,"|",4)
	I '$D(vobj(vOid,vNod)) S vobj(vOid,vNod)=$get(^CUVAR(vNod))
	N vOldNod S vOldNod=$$getOldNode^UCXDD(vP,0)
	I '$D(vobj(vOid,-100,vOldNod,vCol)) S vobj(vOid,-100,vOldNod,vCol)=vTyp_$E(1000+vPos,2,4)_$piece(vobj(vOid,vNod),"|",vPos)
	S vobj(vOid,-100,vOldNod)=""
	S $piece(vobj(vOid,vNod),"|",vPos)=vVal
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vCoInd2(vOid,vCol)	; RecordCUVAR.getColumn()
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vP S vP=$$getPslCln^UCXDD("CUVAR",$$vStrUC(vCol))
	N vNod S vNod=$P(vP,"|",3)
	N vPos
	;
	N vCmp S vCmp=$P(vP,"|",14)
	I vCmp'="" D  Q @vCmp
	.	N vpt
	.	D parseCmp^UCXDD(vCmp,.vpt)
	.	N vCnt S vCnt=$order(vpt(""),-1)
	.	N vVal
	.	N vElm
	.	S vCmp=""
	.	F vElm=2:2:vCnt S vCmp=vCmp_vpt(vElm-1)_$$QADD^%ZS(($$vCoInd2(vOid,vpt(vElm))),"""")
	.	S vCmp=vCmp_vpt(vCnt)
	.	Q 
	;
	S vPos=$P(vP,"|",4)
	I '$D(vobj(vOid,vNod)) S vobj(vOid,vNod)=$get(^CUVAR(vNod))
	N vRet
	S vRet=vobj(vOid,vNod)
	S vRet=$piece(vRet,"|",vPos)
	Q vRet
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±³µ¶¹º»¼¾¿àáâãäåæçèéêëìíîïðñòóôõöøùúûüýþ","ABCDEFGHIJKLMNOPQRSTUVWXYZ¡£¥¦©ª«¬®¯ÀÁÂÃÄÅÆÇÈÉÊËÌÍÎÏÐÑÒÓÔÕÖØÙÚÛÜÝÞ")
	;
vDbNew1()	;	vobj()=Class.new(CUVAR)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordCUVAR",vobj(vOid,-2)=0
	Q vOid
