CUVARFIL(cuvar,vpar,vparNorm)	; CUVAR - Institution Variables Filer
	;
	; **** Routine compiled from DATA-QWIK Filer CUVAR ****
	;
	; 11/09/2007 15:13 - chenardp
	;
	; Copyright(c)2007 Sanchez Computer Associates, Inc.  All Rights Reserved - 11/09/2007 15:13 - chenardp
	; Generated from DATA-QWIK schema in: /profile/v72framework_gtm  by: /v72framework_gtmlx/crtns/DBSFILB.obj
	;
	; Data Dictionary Data Items (511)            05/28/2007
	;
	N voZT set voZT=$ZT
	 S ER=0
	;
	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	N vx N vxins ; audit column array
	N %O S %O=$G(vobj(cuvar,-2)) ; Processing mode
	S vpar=$get(vpar) ; Initialize vpar
	;
	I %O=0 D AUDIT^UCUTILN(cuvar,.vxins,10,"|")
	I %O=1 Q:'$D(vobj(cuvar,-100))  D AUDIT^UCUTILN(cuvar,.vx,10,"|")
	;
	I '$get(vparNorm) S vpar=$$initPar^UCUTILN(vpar) ; Run-time qualifiers
	;
	I %O=0 D  Q  ; Create record control block
	.	D vinit ; Initialize column values
	.	I vpar["/VALREQ/" D vreqn ; Check required
	.	I vpar["/VALDD/" D vddver ; Check values
	.	D vexec
	.	D SET^UCLREGEN("CUVAR","*") ; Literal references to CUVAR exist
	.	Q 
	;
	I %O=1 D  Q  ; Update record control block
	.	I vpar["/VALREQ/" D vrequ ; Check required
	.	I vpar["/VALDD/" D VDDUX^DBSFILER("CUVAR",.vx)
	.	S %O=1 D vexec
	.	D  ; Check to see if updated columns involved in literal references
	..		N vcol N vlitcols
	..		;
	..		N rslits,vos1,vos2,vos3,vOid S rslits=$$vOpen1()
	..		F  Q:'($$vFetch1())  S vlitcols(rslits)=""
	..		;
	..		S vcol=""
	..		F  S vcol=$order(vlitcols(vcol)) Q:(vcol="")  I ($D(vx(vcol))#2) D SET^UCLREGEN("CUVAR",vcol)
	..		Q 
	.	Q 
	;
	I %O=2 D  Q  ; Verify record control block
	.	I vpar["/VALREQ/" D vreqn ; Check required
	.	S vpar=$$setPar^UCUTILN(vpar,"NOJOURNAL/NOUPDATE")
	.	D vexec
	.	Q 
	;
	I %O=3 D  Q  ; Delete record control block
	.	Q:'$D(^CUVAR)  ; No record exists
	.	D vdelete(0)
	.	D SET^UCLREGEN("CUVAR","*") ; Literal references to CUVAR exist
	.	Q 
	;
	Q 
	;
vlegacy(%O,vpar)	; Legacy interface (^DBSDF9 for %O=0, EXT^DBSFILER for %O = 2)
	;
	N cuvar S cuvar=$$vDb1()
	I (%O=2) D
	.	S vobj(cuvar,-2)=2
	.	;
	.	D CUVARFIL(cuvar,vpar)
	.	Q 
	;
	K vobj(+$G(cuvar)) Q 
	;
vLITCHK()	;
	Q 1 ; Table has columns involved in literals
	;
vexec	; Execute transaction
	;
	N vERRMSG
	;
	I vpar["/VALST/" I '(''$D(^CUVAR)=''%O) S vERRMSG=$$^MSG($SELECT(%O:7932,1:2327)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vERRMSG,",","~") X $ZT
	;
	I vpar'["/NOUPDATE/" D
	.	;
	.	I %O=0,vpar'["/NOLOG/" D ^DBSLOGIT(cuvar,%O,.vxins)
	.	I %O=1,vpar'["/NOLOG/" D ^DBSLOGIT(cuvar,%O,.vx)
	.	;
	.	N n S n=-1
	.	N x
	.	;
	.	I %O=0 F  S n=$order(vobj(cuvar,n)) Q:(n="")  D
	..		; Allow global reference and M source code
	..		;    #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	..		;*** Start of code by-passed by compiler
	..		S ^CUVAR(n)=vobj(cuvar,n)
	..		;*** End of code by-passed by compiler ***
	..		Q 
	.	;
	.	E  F  S n=$order(vobj(cuvar,-100,n)) Q:(n="")  D
	..		Q:'$D(vobj(cuvar,n)) 
	..		; Allow global reference and M source code
	..		;    #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; GROUP=BYPASS
	..		;*** Start of code by-passed by compiler
	..		S ^CUVAR(n)=vobj(cuvar,n)
	..		;*** End of code by-passed by compiler ***
	..		Q 
	.	;
	.	Q 
	;
	Q 
	;
vload	; Record Load - force loading of unloaded data
	;
	N n S n=""
	;
	; Allow global reference
	;  #ACCEPT DATE=04/22/04; PGM=Dan Russell; CR=20602; Group=BYPASS
	;*** Start of code by-passed by compiler
	for  set n=$order(^CUVAR(n)) quit:n=""  if '$D(vobj(cuvar,n)),$D(^CUVAR(n))#2 set vobj(cuvar,n)=^(n)
	;*** End of code by-passed by compiler ***
	Q 
	;
vdelete(vkeychg)	; Record Delete
	;
	I '$get(vkeychg),$D(vobj(cuvar,-100)) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,Deleted object cannot be modified" X $ZT
	;
	I vpar'["/NOLOG/" D ^DBSLOGIT(cuvar,3)
	Q 
	;
vinit	; Initialize default values
	;
	 S:'$D(vobj(cuvar,"%ET")) vobj(cuvar,"%ET")=$S(vobj(cuvar,-2):$G(^CUVAR("%ET")),1:"")
	I ($P(vobj(cuvar,"%ET"),$C(124),1)="") S vobj(cuvar,-100,"%ET")="",$P(vobj(cuvar,"%ET"),$C(124),1)="ZE^UTLERR" ; %et
	 S:'$D(vobj(cuvar,"%HELP")) vobj(cuvar,"%HELP")=$S(vobj(cuvar,-2):$G(^CUVAR("%HELP")),1:"")
	I ($P(vobj(cuvar,"%HELP"),$C(124),1)="") S vobj(cuvar,-100,"%HELP")="",$P(vobj(cuvar,"%HELP"),$C(124),1)=0 ; %help
	I ($P(vobj(cuvar,"%HELP"),$C(124),2)="") S vobj(cuvar,-100,"%HELP")="",$P(vobj(cuvar,"%HELP"),$C(124),2)=0 ; %helpcnt
	 S:'$D(vobj(cuvar,"%KEYS")) vobj(cuvar,"%KEYS")=$S(vobj(cuvar,-2):$G(^CUVAR("%KEYS")),1:"")
	I ($P(vobj(cuvar,"%KEYS"),$C(124),1)="") S vobj(cuvar,-100,"%KEYS")="",$P(vobj(cuvar,"%KEYS"),$C(124),1)=0 ; %keys
	 S:'$D(vobj(cuvar,"%MCP")) vobj(cuvar,"%MCP")=$S(vobj(cuvar,-2):$G(^CUVAR("%MCP")),1:"")
	I ($P(vobj(cuvar,"%MCP"),$C(124),1)="") S vobj(cuvar,-100,"%MCP")="",$P(vobj(cuvar,"%MCP"),$C(124),1)=0 ; %mcp
	 S:'$D(vobj(cuvar,"ALCOUNT")) vobj(cuvar,"ALCOUNT")=$S(vobj(cuvar,-2):$G(^CUVAR("ALCOUNT")),1:"")
	I ($P(vobj(cuvar,"ALCOUNT"),$C(124),1)="") S vobj(cuvar,-100,"ALCOUNT")="",$P(vobj(cuvar,"ALCOUNT"),$C(124),1)=5 ; alcount
	 S:'$D(vobj(cuvar,"ALP")) vobj(cuvar,"ALP")=$S(vobj(cuvar,-2):$G(^CUVAR("ALP")),1:"")
	I ($P(vobj(cuvar,"ALP"),$C(124),1)="") S vobj(cuvar,-100,"ALP")="",$P(vobj(cuvar,"ALP"),$C(124),1)=0 ; alphi
	 S:'$D(vobj(cuvar,"%CRCD")) vobj(cuvar,"%CRCD")=$S(vobj(cuvar,-2):$G(^CUVAR("%CRCD")),1:"")
	I ($P(vobj(cuvar,"%CRCD"),$C(124),13)="") S vobj(cuvar,-100,"%CRCD")="",$P(vobj(cuvar,"%CRCD"),$C(124),13)=0 ; bamtmod
	 S:'$D(vobj(cuvar,"BANNER")) vobj(cuvar,"BANNER")=$S(vobj(cuvar,-2):$G(^CUVAR("BANNER")),1:"")
	I ($P(vobj(cuvar,"BANNER"),$C(124),1)="") S vobj(cuvar,-100,"BANNER")="",$P(vobj(cuvar,"BANNER"),$C(124),1)=1 ; banner
	 S:'$D(vobj(cuvar,"BINDEF")) vobj(cuvar,"BINDEF")=$S(vobj(cuvar,-2):$G(^CUVAR("BINDEF")),1:"")
	I ($P(vobj(cuvar,"BINDEF"),$C(124),1)="") S vobj(cuvar,-100,"BINDEF")="",$P(vobj(cuvar,"BINDEF"),$C(124),1)=0 ; bindef
	 S:'$D(vobj(cuvar,"BOBR")) vobj(cuvar,"BOBR")=$S(vobj(cuvar,-2):$G(^CUVAR("BOBR")),1:"")
	I ($P(vobj(cuvar,"BOBR"),$C(124),1)="") S vobj(cuvar,-100,"BOBR")="",$P(vobj(cuvar,"BOBR"),$C(124),1)=0 ; bobr
	I ($P(vobj(cuvar,"%CRCD"),$C(124),11)="") S vobj(cuvar,-100,"%CRCD")="",$P(vobj(cuvar,"%CRCD"),$C(124),11)=0 ; bsemod
	 S:'$D(vobj(cuvar,"CNTRY")) vobj(cuvar,"CNTRY")=$S(vobj(cuvar,-2):$G(^CUVAR("CNTRY")),1:"")
	I ($P(vobj(cuvar,"CNTRY"),$C(124),2)="") S vobj(cuvar,-100,"CNTRY")="",$P(vobj(cuvar,"CNTRY"),$C(124),2)=0 ; catsup
	I ($P(vobj(cuvar,"%CRCD"),$C(124),12)="") S vobj(cuvar,-100,"%CRCD")="",$P(vobj(cuvar,"%CRCD"),$C(124),12)=0 ; ccmod
	 S:'$D(vobj(cuvar,"CHK")) vobj(cuvar,"CHK")=$S(vobj(cuvar,-2):$G(^CUVAR("CHK")),1:"")
	I ($P(vobj(cuvar,"CHK"),$C(124),1)="") S vobj(cuvar,-100,"CHK")="",$P(vobj(cuvar,"CHK"),$C(124),1)=0 ; chkimg
	 S:'$D(vobj(cuvar,"CIF")) vobj(cuvar,"CIF")=$S(vobj(cuvar,-2):$G(^CUVAR("CIF")),1:"")
	I ($P(vobj(cuvar,"CIF"),$C(124),13)="") S vobj(cuvar,-100,"CIF")="",$P(vobj(cuvar,"CIF"),$C(124),13)=0 ; cifalloc
	 S:'$D(vobj(cuvar,"MFUND")) vobj(cuvar,"MFUND")=$S(vobj(cuvar,-2):$G(^CUVAR("MFUND")),1:"")
	I ($P(vobj(cuvar,"MFUND"),$C(124),5)="") S vobj(cuvar,-100,"MFUND")="",$P(vobj(cuvar,"MFUND"),$C(124),5)=0 ; cifexti
	 S:'$D(vobj(cuvar,"DEP")) vobj(cuvar,"DEP")=$S(vobj(cuvar,-2):$G(^CUVAR("DEP")),1:"")
	I ($P(vobj(cuvar,"DEP"),$C(124),17)="") S vobj(cuvar,-100,"DEP")="",$P(vobj(cuvar,"DEP"),$C(124),17)=0 ; cmsacopt
	 S:'$D(vobj(cuvar,"CRTDSP")) vobj(cuvar,"CRTDSP")=$S(vobj(cuvar,-2):$G(^CUVAR("CRTDSP")),1:"")
	I ($P(vobj(cuvar,"CRTDSP"),$C(124),1)="") S vobj(cuvar,-100,"CRTDSP")="",$P(vobj(cuvar,"CRTDSP"),$C(124),1)=0 ; crtdsp
	 S:'$D(vobj(cuvar,1099)) vobj(cuvar,1099)=$S(vobj(cuvar,-2):$G(^CUVAR(1099)),1:"")
	I ($P(vobj(cuvar,1099),$C(124),8)="") S vobj(cuvar,-100,1099)="",$P(vobj(cuvar,1099),$C(124),8)=0 ; ctof1098
	I ($P(vobj(cuvar,1099),$C(124),9)="") S vobj(cuvar,-100,1099)="",$P(vobj(cuvar,1099),$C(124),9)=0 ; ctof1099
	 S:'$D(vobj(cuvar,"CURRENV")) vobj(cuvar,"CURRENV")=$S(vobj(cuvar,-2):$G(^CUVAR("CURRENV")),1:"")
	I ($P(vobj(cuvar,"CURRENV"),$C(124),1)="") S vobj(cuvar,-100,"CURRENV")="",$P(vobj(cuvar,"CURRENV"),$C(124),1)=0 ; currenv
	 S:'$D(vobj(cuvar,"LN")) vobj(cuvar,"LN")=$S(vobj(cuvar,-2):$G(^CUVAR("LN")),1:"")
	I ($P(vobj(cuvar,"LN"),$C(124),31)="") S vobj(cuvar,-100,"LN")="",$P(vobj(cuvar,"LN"),$C(124),31)=0 ; darcdflg
	 S:'$D(vobj(cuvar,"DBS")) vobj(cuvar,"DBS")=$S(vobj(cuvar,-2):$G(^CUVAR("DBS")),1:"")
	I ($P(vobj(cuvar,"DBS"),$C(124),3)="") S vobj(cuvar,-100,"DBS")="",$P(vobj(cuvar,"DBS"),$C(124),3)="SCAU$HELP:OOE_SCA132.EXP" ; dbsph132
	I ($P(vobj(cuvar,"DBS"),$C(124),2)="") S vobj(cuvar,-100,"DBS")="",$P(vobj(cuvar,"DBS"),$C(124),2)="SCAU$HELP:OOE_SCA80.EXP" ; dbsph80
	 S:'$D(vobj(cuvar,"EFTPAY")) vobj(cuvar,"EFTPAY")=$S(vobj(cuvar,-2):$G(^CUVAR("EFTPAY")),1:"")
	I ($P(vobj(cuvar,"EFTPAY"),$C(124),16)="") S vobj(cuvar,-100,"EFTPAY")="",$P(vobj(cuvar,"EFTPAY"),$C(124),16)=0 ; debaut
	 S:'$D(vobj(cuvar,"%IO")) vobj(cuvar,"%IO")=$S(vobj(cuvar,-2):$G(^CUVAR("%IO")),1:"")
	I ($P(vobj(cuvar,"%IO"),$C(124),2)="") S vobj(cuvar,-100,"%IO")="",$P(vobj(cuvar,"%IO"),$C(124),2)=0 ; devptr
	 S:'$D(vobj(cuvar,"EUR")) vobj(cuvar,"EUR")=$S(vobj(cuvar,-2):$G(^CUVAR("EUR")),1:"")
	I ($P(vobj(cuvar,"EUR"),$C(124),6)="") S vobj(cuvar,-100,"EUR")="",$P(vobj(cuvar,"EUR"),$C(124),6)=0 ; dftthrc
	I ($P(vobj(cuvar,"EUR"),$C(124),7)="") S vobj(cuvar,-100,"EUR")="",$P(vobj(cuvar,"EUR"),$C(124),7)=0 ; dftthrr
	I ($P(vobj(cuvar,"CIF"),$C(124),23)="") S vobj(cuvar,-100,"CIF")="",$P(vobj(cuvar,"CIF"),$C(124),23)=0 ; duptin
	I ($P(vobj(cuvar,"DBS"),$C(124),6)="") S vobj(cuvar,-100,"DBS")="",$P(vobj(cuvar,"DBS"),$C(124),6)="US" ; editmask
	 S:'$D(vobj(cuvar,"EFD")) vobj(cuvar,"EFD")=$S(vobj(cuvar,-2):$G(^CUVAR("EFD")),1:"")
	I ($P(vobj(cuvar,"EFD"),$C(124),1)="") S vobj(cuvar,-100,"EFD")="",$P(vobj(cuvar,"EFD"),$C(124),1)=0 ; efd
	I ($P(vobj(cuvar,"EFD"),$C(124),2)="") S vobj(cuvar,-100,"EFD")="",$P(vobj(cuvar,"EFD"),$C(124),2)=0 ; efdftflg
	I ($P(vobj(cuvar,"EFTPAY"),$C(124),19)="") S vobj(cuvar,-100,"EFTPAY")="",$P(vobj(cuvar,"EFTPAY"),$C(124),19)=0 ; eftmemo
	I ($P(vobj(cuvar,"EFTPAY"),$C(124),15)="") S vobj(cuvar,-100,"EFTPAY")="",$P(vobj(cuvar,"EFTPAY"),$C(124),15)=0 ; eftrefno
	I ($P(vobj(cuvar,"EFTPAY"),$C(124),11)="") S vobj(cuvar,-100,"EFTPAY")="",$P(vobj(cuvar,"EFTPAY"),$C(124),11)=0 ; eftrico
	I ($P(vobj(cuvar,"EUR"),$C(124),1)="") S vobj(cuvar,-100,"EUR")="",$P(vobj(cuvar,"EUR"),$C(124),1)=0 ; emu
	I ($P(vobj(cuvar,"EUR"),$C(124),17)="") S vobj(cuvar,-100,"EUR")="",$P(vobj(cuvar,"EUR"),$C(124),17)=9 ; emurnd
	I ($P(vobj(cuvar,"%ET"),$C(124),2)="") S vobj(cuvar,-100,"%ET")="",$P(vobj(cuvar,"%ET"),$C(124),2)=0 ; errmdft
	I ($P(vobj(cuvar,"EUR"),$C(124),18)="") S vobj(cuvar,-100,"EUR")="",$P(vobj(cuvar,"EUR"),$C(124),18)=0 ; eurinteg
	 S:'$D(vobj(cuvar,"SWIFT")) vobj(cuvar,"SWIFT")=$S(vobj(cuvar,-2):$G(^CUVAR("SWIFT")),1:"")
	I ($P(vobj(cuvar,"SWIFT"),$C(124),5)="") S vobj(cuvar,-100,"SWIFT")="",$P(vobj(cuvar,"SWIFT"),$C(124),5)=0 ; extrem
	I ($P(vobj(cuvar,"CIF"),$C(124),25)="") S vobj(cuvar,-100,"CIF")="",$P(vobj(cuvar,"CIF"),$C(124),25)=0 ; extval
	 S:'$D(vobj(cuvar,"%BATCH")) vobj(cuvar,"%BATCH")=$S(vobj(cuvar,-2):$G(^CUVAR("%BATCH")),1:"")
	I ($P(vobj(cuvar,"%BATCH"),$C(124),2)="") S vobj(cuvar,-100,"%BATCH")="",$P(vobj(cuvar,"%BATCH"),$C(124),2)=0 ; failwait
	 S:'$D(vobj(cuvar,"FCVMEMO")) vobj(cuvar,"FCVMEMO")=$S(vobj(cuvar,-2):$G(^CUVAR("FCVMEMO")),1:"")
	I ($P(vobj(cuvar,"FCVMEMO"),$C(124),1)="") S vobj(cuvar,-100,"FCVMEMO")="",$P(vobj(cuvar,"FCVMEMO"),$C(124),1)=0 ; fcvmemo
	 S:'$D(vobj(cuvar,"FEPXALL")) vobj(cuvar,"FEPXALL")=$S(vobj(cuvar,-2):$G(^CUVAR("FEPXALL")),1:"")
	I ($P(vobj(cuvar,"FEPXALL"),$C(124),1)="") S vobj(cuvar,-100,"FEPXALL")="",$P(vobj(cuvar,"FEPXALL"),$C(124),1)=0 ; fepxall
	I ($P(vobj(cuvar,"DBS"),$C(124),1)="") S vobj(cuvar,-100,"DBS")="",$P(vobj(cuvar,"DBS"),$C(124),1)=0 ; fldovf
	I ($P(vobj(cuvar,"EUR"),$C(124),2)="") S vobj(cuvar,-100,"EUR")="",$P(vobj(cuvar,"EUR"),$C(124),2)=0 ; fncrate
	I ($P(vobj(cuvar,"EFTPAY"),$C(124),17)="") S vobj(cuvar,-100,"EFTPAY")="",$P(vobj(cuvar,"EFTPAY"),$C(124),17)=0 ; futbld
	I ($P(vobj(cuvar,"%CRCD"),$C(124),24)="") S vobj(cuvar,-100,"%CRCD")="",$P(vobj(cuvar,"%CRCD"),$C(124),24)=0 ; fx
	 S:'$D(vobj(cuvar,"GLEFD")) vobj(cuvar,"GLEFD")=$S(vobj(cuvar,-2):$G(^CUVAR("GLEFD")),1:"")
	I ($P(vobj(cuvar,"GLEFD"),$C(124),1)="") S vobj(cuvar,-100,"GLEFD")="",$P(vobj(cuvar,"GLEFD"),$C(124),1)=0 ; glefdbch
	 S:'$D(vobj(cuvar,"INCK")) vobj(cuvar,"INCK")=$S(vobj(cuvar,-2):$G(^CUVAR("INCK")),1:"")
	I ($P(vobj(cuvar,"INCK"),$C(124),23)="") S vobj(cuvar,-100,"INCK")="",$P(vobj(cuvar,"INCK"),$C(124),23)=0 ; iccff
	I ($P(vobj(cuvar,"INCK"),$C(124),24)="") S vobj(cuvar,-100,"INCK")="",$P(vobj(cuvar,"INCK"),$C(124),24)=0 ; iccnf
	I ($P(vobj(cuvar,"INCK"),$C(124),5)="") S vobj(cuvar,-100,"INCK")="",$P(vobj(cuvar,"INCK"),$C(124),5)=0 ; icdff
	I ($P(vobj(cuvar,"INCK"),$C(124),6)="") S vobj(cuvar,-100,"INCK")="",$P(vobj(cuvar,"INCK"),$C(124),6)=0 ; icdnf
	I ($P(vobj(cuvar,"INCK"),$C(124),7)="") S vobj(cuvar,-100,"INCK")="",$P(vobj(cuvar,"INCK"),$C(124),7)=0 ; icdrf
	I ($P(vobj(cuvar,"INCK"),$C(124),4)="") S vobj(cuvar,-100,"INCK")="",$P(vobj(cuvar,"INCK"),$C(124),4)=0 ; icdtf
	I ($P(vobj(cuvar,"INCK"),$C(124),14)="") S vobj(cuvar,-100,"INCK")="",$P(vobj(cuvar,"INCK"),$C(124),14)=0 ; iclff
	I ($P(vobj(cuvar,"INCK"),$C(124),15)="") S vobj(cuvar,-100,"INCK")="",$P(vobj(cuvar,"INCK"),$C(124),15)=0 ; iclnf
	I ($P(vobj(cuvar,"INCK"),$C(124),16)="") S vobj(cuvar,-100,"INCK")="",$P(vobj(cuvar,"INCK"),$C(124),16)=0 ; iclrf
	I ($P(vobj(cuvar,"INCK"),$C(124),13)="") S vobj(cuvar,-100,"INCK")="",$P(vobj(cuvar,"INCK"),$C(124),13)=0 ; icltf
	 S:'$D(vobj(cuvar,"IMAGE")) vobj(cuvar,"IMAGE")=$S(vobj(cuvar,-2):$G(^CUVAR("IMAGE")),1:"")
	I ($P(vobj(cuvar,"IMAGE"),$C(124),1)="") S vobj(cuvar,-100,"IMAGE")="",$P(vobj(cuvar,"IMAGE"),$C(124),1)=0 ; image
	 S:'$D(vobj(cuvar,"IPD")) vobj(cuvar,"IPD")=$S(vobj(cuvar,-2):$G(^CUVAR("IPD")),1:"")
	I ($P(vobj(cuvar,"IPD"),$C(124),1)="") S vobj(cuvar,-100,"IPD")="",$P(vobj(cuvar,"IPD"),$C(124),1)=0 ; ipd
	 S:'$D(vobj(cuvar,"IRAHIST")) vobj(cuvar,"IRAHIST")=$S(vobj(cuvar,-2):$G(^CUVAR("IRAHIST")),1:"")
	I ($P(vobj(cuvar,"IRAHIST"),$C(124),1)="") S vobj(cuvar,-100,"IRAHIST")="",$P(vobj(cuvar,"IRAHIST"),$C(124),1)=365 ; irahist
	 S:'$D(vobj(cuvar,"DRMT")) vobj(cuvar,"DRMT")=$S(vobj(cuvar,-2):$G(^CUVAR("DRMT")),1:"")
	I ($P(vobj(cuvar,"DRMT"),$C(124),4)="") S vobj(cuvar,-100,"DRMT")="",$P(vobj(cuvar,"DRMT"),$C(124),4)=0 ; lccadr
	I ($P(vobj(cuvar,"DRMT"),$C(124),6)="") S vobj(cuvar,-100,"DRMT")="",$P(vobj(cuvar,"DRMT"),$C(124),6)=0 ; lccpu
	I ($P(vobj(cuvar,"DRMT"),$C(124),5)="") S vobj(cuvar,-100,"DRMT")="",$P(vobj(cuvar,"DRMT"),$C(124),5)=0 ; lcctit
	 S:'$D(vobj(cuvar,"LETTER")) vobj(cuvar,"LETTER")=$S(vobj(cuvar,-2):$G(^CUVAR("LETTER")),1:"")
	I ($P(vobj(cuvar,"LETTER"),$C(124),1)="") S vobj(cuvar,-100,"LETTER")="",$P(vobj(cuvar,"LETTER"),$C(124),1)=0 ; letfix
	I ($P(vobj(cuvar,"CIF"),$C(124),16)="") S vobj(cuvar,-100,"CIF")="",$P(vobj(cuvar,"CIF"),$C(124),16)=0 ; limpro
	I ($P(vobj(cuvar,"LN"),$C(124),37)="") S vobj(cuvar,-100,"LN")="",$P(vobj(cuvar,"LN"),$C(124),37)=0 ; lncc
	I ($P(vobj(cuvar,"LN"),$C(124),34)="") S vobj(cuvar,-100,"LN")="",$P(vobj(cuvar,"LN"),$C(124),34)=0 ; lncfp
	I ($P(vobj(cuvar,"LN"),$C(124),36)="") S vobj(cuvar,-100,"LN")="",$P(vobj(cuvar,"LN"),$C(124),36)=0 ; lncpi
	I ($P(vobj(cuvar,"LN"),$C(124),35)="") S vobj(cuvar,-100,"LN")="",$P(vobj(cuvar,"LN"),$C(124),35)=0 ; lncpp
	I ($P(vobj(cuvar,"LN"),$C(124),32)="") S vobj(cuvar,-100,"LN")="",$P(vobj(cuvar,"LN"),$C(124),32)=0 ; lnrendel
	I ($P(vobj(cuvar,"CIF"),$C(124),2)="") S vobj(cuvar,-100,"CIF")="",$P(vobj(cuvar,"CIF"),$C(124),2)=12 ; maxcifl
	I ($P(vobj(cuvar,"CIF"),$C(124),1)="") S vobj(cuvar,-100,"CIF")="",$P(vobj(cuvar,"CIF"),$C(124),1)=1 ; mincifl
	I ($P(vobj(cuvar,"LN"),$C(124),33)="") S vobj(cuvar,-100,"LN")="",$P(vobj(cuvar,"LN"),$C(124),33)=0 ; mrpt
	 S:'$D(vobj(cuvar,"MULTIITSID")) vobj(cuvar,"MULTIITSID")=$S(vobj(cuvar,-2):$G(^CUVAR("MULTIITSID")),1:"")
	I ($P(vobj(cuvar,"MULTIITSID"),$C(124),1)="") S vobj(cuvar,-100,"MULTIITSID")="",$P(vobj(cuvar,"MULTIITSID"),$C(124),1)=0 ; multiitsid
	 S:'$D(vobj(cuvar,"MXTRLM")) vobj(cuvar,"MXTRLM")=$S(vobj(cuvar,-2):$G(^CUVAR("MXTRLM")),1:"")
	I ($P(vobj(cuvar,"MXTRLM"),$C(124),1)="") S vobj(cuvar,-100,"MXTRLM")="",$P(vobj(cuvar,"MXTRLM"),$C(124),1)=0 ; mxtrlm
	 S:'$D(vobj(cuvar,"NOREGD")) vobj(cuvar,"NOREGD")=$S(vobj(cuvar,-2):$G(^CUVAR("NOREGD")),1:"")
	I ($P(vobj(cuvar,"NOREGD"),$C(124),1)="") S vobj(cuvar,-100,"NOREGD")="",$P(vobj(cuvar,"NOREGD"),$C(124),1)=0 ; noregd
	 S:'$D(vobj(cuvar,"OPTIMIZE")) vobj(cuvar,"OPTIMIZE")=$S(vobj(cuvar,-2):$G(^CUVAR("OPTIMIZE")),1:"")
	I ($P(vobj(cuvar,"OPTIMIZE"),$C(124),1)="") S vobj(cuvar,-100,"OPTIMIZE")="",$P(vobj(cuvar,"OPTIMIZE"),$C(124),1)=0 ; nosegments
	I ($P(vobj(cuvar,"DBS"),$C(124),7)="") S vobj(cuvar,-100,"DBS")="",$P(vobj(cuvar,"DBS"),$C(124),7)=0 ; notp
	 S:'$D(vobj(cuvar,"REGCC")) vobj(cuvar,"REGCC")=$S(vobj(cuvar,-2):$G(^CUVAR("REGCC")),1:"")
	I ($P(vobj(cuvar,"REGCC"),$C(124),11)="") S vobj(cuvar,-100,"REGCC")="",$P(vobj(cuvar,"REGCC"),$C(124),11)=0 ; obde
	 S:'$D(vobj(cuvar,"ODP")) vobj(cuvar,"ODP")=$S(vobj(cuvar,-2):$G(^CUVAR("ODP")),1:"")
	I ($P(vobj(cuvar,"ODP"),$C(124),1)="") S vobj(cuvar,-100,"ODP")="",$P(vobj(cuvar,"ODP"),$C(124),1)=0 ; odp
	 S:'$D(vobj(cuvar,"ODPE")) vobj(cuvar,"ODPE")=$S(vobj(cuvar,-2):$G(^CUVAR("ODPE")),1:"")
	I ($P(vobj(cuvar,"ODPE"),$C(124),1)="") S vobj(cuvar,-100,"ODPE")="",$P(vobj(cuvar,"ODPE"),$C(124),1)=0 ; odpe
	I ($P(vobj(cuvar,"CIF"),$C(124),3)="") S vobj(cuvar,-100,"CIF")="",$P(vobj(cuvar,"CIF"),$C(124),3)=1 ; orcifn
	I ($P(vobj(cuvar,"%CRCD"),$C(124),23)="") S vobj(cuvar,-100,"%CRCD")="",$P(vobj(cuvar,"%CRCD"),$C(124),23)=0 ; otc
	 S:'$D(vobj(cuvar,"PUBLISH")) vobj(cuvar,"PUBLISH")=$S(vobj(cuvar,-2):$G(^CUVAR("PUBLISH")),1:"")
	I ($P(vobj(cuvar,"PUBLISH"),$C(124),1)="") S vobj(cuvar,-100,"PUBLISH")="",$P(vobj(cuvar,"PUBLISH"),$C(124),1)=0 ; publish
	I ($P(vobj(cuvar,"REGCC"),$C(124),7)="") S vobj(cuvar,-100,"REGCC")="",$P(vobj(cuvar,"REGCC"),$C(124),7)=0 ; regccopt
	 S:'$D(vobj(cuvar,"REGFLG")) vobj(cuvar,"REGFLG")=$S(vobj(cuvar,-2):$G(^CUVAR("REGFLG")),1:"")
	I ($P(vobj(cuvar,"REGFLG"),$C(124),1)="") S vobj(cuvar,-100,"REGFLG")="",$P(vobj(cuvar,"REGFLG"),$C(124),1)=0 ; regflg
	 S:'$D(vobj(cuvar,"DEAL")) vobj(cuvar,"DEAL")=$S(vobj(cuvar,-2):$G(^CUVAR("DEAL")),1:"")
	I ($P(vobj(cuvar,"DEAL"),$C(124),1)="") S vobj(cuvar,-100,"DEAL")="",$P(vobj(cuvar,"DEAL"),$C(124),1)=0 ; rekey
	 S:'$D(vobj(cuvar,"RESPROC")) vobj(cuvar,"RESPROC")=$S(vobj(cuvar,-2):$G(^CUVAR("RESPROC")),1:"")
	I ($P(vobj(cuvar,"RESPROC"),$C(124),1)="") S vobj(cuvar,-100,"RESPROC")="",$P(vobj(cuvar,"RESPROC"),$C(124),1)=0 ; resproc
	 S:'$D(vobj(cuvar,"RESTRICT")) vobj(cuvar,"RESTRICT")=$S(vobj(cuvar,-2):$G(^CUVAR("RESTRICT")),1:"")
	I ($P(vobj(cuvar,"RESTRICT"),$C(124),1)="") S vobj(cuvar,-100,"RESTRICT")="",$P(vobj(cuvar,"RESTRICT"),$C(124),1)=0 ; restrict
	I ($P(vobj(cuvar,"DEP"),$C(124),11)="") S vobj(cuvar,-100,"DEP")="",$P(vobj(cuvar,"DEP"),$C(124),11)=0 ; rpanet
	 S:'$D(vobj(cuvar,"SCAUREL")) vobj(cuvar,"SCAUREL")=$S(vobj(cuvar,-2):$G(^CUVAR("SCAUREL")),1:"")
	I ($P(vobj(cuvar,"SCAUREL"),$C(124),1)="") S vobj(cuvar,-100,"SCAUREL")="",$P(vobj(cuvar,"SCAUREL"),$C(124),1)=0 ; scaurel
	 S:'$D(vobj(cuvar,"SCHRC")) vobj(cuvar,"SCHRC")=$S(vobj(cuvar,-2):$G(^CUVAR("SCHRC")),1:"")
	I ($P(vobj(cuvar,"SCHRC"),$C(124),1)="") S vobj(cuvar,-100,"SCHRC")="",$P(vobj(cuvar,"SCHRC"),$C(124),1)=0 ; schrcc
	I ($P(vobj(cuvar,"SCHRC"),$C(124),7)="") S vobj(cuvar,-100,"SCHRC")="",$P(vobj(cuvar,"SCHRC"),$C(124),7)=0 ; schrce
	I ($P(vobj(cuvar,"SCHRC"),$C(124),2)="") S vobj(cuvar,-100,"SCHRC")="",$P(vobj(cuvar,"SCHRC"),$C(124),2)=0 ; schrcj
	I ($P(vobj(cuvar,"SCHRC"),$C(124),3)="") S vobj(cuvar,-100,"SCHRC")="",$P(vobj(cuvar,"SCHRC"),$C(124),3)=0 ; schrck
	I ($P(vobj(cuvar,"SCHRC"),$C(124),4)="") S vobj(cuvar,-100,"SCHRC")="",$P(vobj(cuvar,"SCHRC"),$C(124),4)=0 ; schrcl
	I ($P(vobj(cuvar,"SCHRC"),$C(124),5)="") S vobj(cuvar,-100,"SCHRC")="",$P(vobj(cuvar,"SCHRC"),$C(124),5)=0 ; schrcn
	I ($P(vobj(cuvar,"SCHRC"),$C(124),6)="") S vobj(cuvar,-100,"SCHRC")="",$P(vobj(cuvar,"SCHRC"),$C(124),6)=0 ; schri
	I ($P(vobj(cuvar,"EUR"),$C(124),15)="") S vobj(cuvar,-100,"EUR")="",$P(vobj(cuvar,"EUR"),$C(124),15)=0 ; scovr
	I ($P(vobj(cuvar,"ODP"),$C(124),2)="") S vobj(cuvar,-100,"ODP")="",$P(vobj(cuvar,"ODP"),$C(124),2)=0 ; sfeeopt
	 S:'$D(vobj(cuvar,"SPLITDAY")) vobj(cuvar,"SPLITDAY")=$S(vobj(cuvar,-2):$G(^CUVAR("SPLITDAY")),1:"")
	I ($P(vobj(cuvar,"SPLITDAY"),$C(124),1)="") S vobj(cuvar,-100,"SPLITDAY")="",$P(vobj(cuvar,"SPLITDAY"),$C(124),1)=0 ; splitday
	I ($P(vobj(cuvar,"DRMT"),$C(124),3)="") S vobj(cuvar,-100,"DRMT")="",$P(vobj(cuvar,"DRMT"),$C(124),3)=0 ; stmlcc
	 S:'$D(vobj(cuvar,"STMTSRT")) vobj(cuvar,"STMTSRT")=$S(vobj(cuvar,-2):$G(^CUVAR("STMTSRT")),1:"")
	I ($P(vobj(cuvar,"STMTSRT"),$C(124),3)="") S vobj(cuvar,-100,"STMTSRT")="",$P(vobj(cuvar,"STMTSRT"),$C(124),3)=0 ; stmtcdskip
	I ($P(vobj(cuvar,"STMTSRT"),$C(124),6)="") S vobj(cuvar,-100,"STMTSRT")="",$P(vobj(cuvar,"STMTSRT"),$C(124),6)=0 ; stmtcumul
	I ($P(vobj(cuvar,"STMTSRT"),$C(124),4)="") S vobj(cuvar,-100,"STMTSRT")="",$P(vobj(cuvar,"STMTSRT"),$C(124),4)=0 ; stmtintrtc
	I ($P(vobj(cuvar,"STMTSRT"),$C(124),5)="") S vobj(cuvar,-100,"STMTSRT")="",$P(vobj(cuvar,"STMTSRT"),$C(124),5)=0 ; stmtlnskip
	I ($P(vobj(cuvar,"CIF"),$C(124),5)="") S vobj(cuvar,-100,"CIF")="",$P(vobj(cuvar,"CIF"),$C(124),5)=1 ; taxreq
	I ($P(vobj(cuvar,"%CRCD"),$C(124),25)="") S vobj(cuvar,-100,"%CRCD")="",$P(vobj(cuvar,"%CRCD"),$C(124),25)=0 ; tfs
	I ($P(vobj(cuvar,"CIF"),$C(124),24)="") S vobj(cuvar,-100,"CIF")="",$P(vobj(cuvar,"CIF"),$C(124),24)=0 ; tinco
	 S:'$D(vobj(cuvar,"CRT")) vobj(cuvar,"CRT")=$S(vobj(cuvar,-2):$G(^CUVAR("CRT")),1:"")
	I ($P(vobj(cuvar,"CRT"),$C(124),7)="") S vobj(cuvar,-100,"CRT")="",$P(vobj(cuvar,"CRT"),$C(124),7)=0 ; tref
	 S:'$D(vobj(cuvar,"USERNAME")) vobj(cuvar,"USERNAME")=$S(vobj(cuvar,-2):$G(^CUVAR("USERNAME")),1:"")
	I ($P(vobj(cuvar,"USERNAME"),$C(124),1)="") S vobj(cuvar,-100,"USERNAME")="",$P(vobj(cuvar,"USERNAME"),$C(124),1)=0 ; username
	 S:'$D(vobj(cuvar,"USRESTAT")) vobj(cuvar,"USRESTAT")=$S(vobj(cuvar,-2):$G(^CUVAR("USRESTAT")),1:"")
	I ($P(vobj(cuvar,"USRESTAT"),$C(124),1)="") S vobj(cuvar,-100,"USRESTAT")="",$P(vobj(cuvar,"USRESTAT"),$C(124),1)=0 ; usrestat
	Q 
	;
vreqn	; Validate required data items
	;
	 S:'$D(vobj(cuvar,"%KEYS")) vobj(cuvar,"%KEYS")=$S(vobj(cuvar,-2):$G(^CUVAR("%KEYS")),1:"")
	I ($P(vobj(cuvar,"%KEYS"),$C(124),1)="") D vreqerr("%KEYS") Q 
	 S:'$D(vobj(cuvar,"%MCP")) vobj(cuvar,"%MCP")=$S(vobj(cuvar,-2):$G(^CUVAR("%MCP")),1:"")
	I ($P(vobj(cuvar,"%MCP"),$C(124),1)="") D vreqerr("%MCP") Q 
	 S:'$D(vobj(cuvar,"ALP")) vobj(cuvar,"ALP")=$S(vobj(cuvar,-2):$G(^CUVAR("ALP")),1:"")
	I ($P(vobj(cuvar,"ALP"),$C(124),1)="") D vreqerr("ALPHI") Q 
	 S:'$D(vobj(cuvar,"%CRCD")) vobj(cuvar,"%CRCD")=$S(vobj(cuvar,-2):$G(^CUVAR("%CRCD")),1:"")
	I ($P(vobj(cuvar,"%CRCD"),$C(124),13)="") D vreqerr("BAMTMOD") Q 
	 S:'$D(vobj(cuvar,"BANNER")) vobj(cuvar,"BANNER")=$S(vobj(cuvar,-2):$G(^CUVAR("BANNER")),1:"")
	I ($P(vobj(cuvar,"BANNER"),$C(124),1)="") D vreqerr("BANNER") Q 
	 S:'$D(vobj(cuvar,"BINDEF")) vobj(cuvar,"BINDEF")=$S(vobj(cuvar,-2):$G(^CUVAR("BINDEF")),1:"")
	I ($P(vobj(cuvar,"BINDEF"),$C(124),1)="") D vreqerr("BINDEF") Q 
	 S:'$D(vobj(cuvar,"BOBR")) vobj(cuvar,"BOBR")=$S(vobj(cuvar,-2):$G(^CUVAR("BOBR")),1:"")
	I ($P(vobj(cuvar,"BOBR"),$C(124),1)="") D vreqerr("BOBR") Q 
	I ($P(vobj(cuvar,"%CRCD"),$C(124),11)="") D vreqerr("BSEMOD") Q 
	 S:'$D(vobj(cuvar,"CNTRY")) vobj(cuvar,"CNTRY")=$S(vobj(cuvar,-2):$G(^CUVAR("CNTRY")),1:"")
	I ($P(vobj(cuvar,"CNTRY"),$C(124),2)="") D vreqerr("CATSUP") Q 
	I ($P(vobj(cuvar,"%CRCD"),$C(124),12)="") D vreqerr("CCMOD") Q 
	 S:'$D(vobj(cuvar,"CHK")) vobj(cuvar,"CHK")=$S(vobj(cuvar,-2):$G(^CUVAR("CHK")),1:"")
	I ($P(vobj(cuvar,"CHK"),$C(124),1)="") D vreqerr("CHKIMG") Q 
	 S:'$D(vobj(cuvar,"CIF")) vobj(cuvar,"CIF")=$S(vobj(cuvar,-2):$G(^CUVAR("CIF")),1:"")
	I ($P(vobj(cuvar,"CIF"),$C(124),13)="") D vreqerr("CIFALLOC") Q 
	 S:'$D(vobj(cuvar,"MFUND")) vobj(cuvar,"MFUND")=$S(vobj(cuvar,-2):$G(^CUVAR("MFUND")),1:"")
	I ($P(vobj(cuvar,"MFUND"),$C(124),5)="") D vreqerr("CIFEXTI") Q 
	 S:'$D(vobj(cuvar,"DEP")) vobj(cuvar,"DEP")=$S(vobj(cuvar,-2):$G(^CUVAR("DEP")),1:"")
	I ($P(vobj(cuvar,"DEP"),$C(124),17)="") D vreqerr("CMSACOPT") Q 
	 S:'$D(vobj(cuvar,"CRTDSP")) vobj(cuvar,"CRTDSP")=$S(vobj(cuvar,-2):$G(^CUVAR("CRTDSP")),1:"")
	I ($P(vobj(cuvar,"CRTDSP"),$C(124),1)="") D vreqerr("CRTDSP") Q 
	 S:'$D(vobj(cuvar,1099)) vobj(cuvar,1099)=$S(vobj(cuvar,-2):$G(^CUVAR(1099)),1:"")
	I ($P(vobj(cuvar,1099),$C(124),8)="") D vreqerr("CTOF1098") Q 
	I ($P(vobj(cuvar,1099),$C(124),9)="") D vreqerr("CTOF1099") Q 
	 S:'$D(vobj(cuvar,"CURRENV")) vobj(cuvar,"CURRENV")=$S(vobj(cuvar,-2):$G(^CUVAR("CURRENV")),1:"")
	I ($P(vobj(cuvar,"CURRENV"),$C(124),1)="") D vreqerr("CURRENV") Q 
	 S:'$D(vobj(cuvar,"LN")) vobj(cuvar,"LN")=$S(vobj(cuvar,-2):$G(^CUVAR("LN")),1:"")
	I ($P(vobj(cuvar,"LN"),$C(124),31)="") D vreqerr("DARCDFLG") Q 
	 S:'$D(vobj(cuvar,"EFTPAY")) vobj(cuvar,"EFTPAY")=$S(vobj(cuvar,-2):$G(^CUVAR("EFTPAY")),1:"")
	I ($P(vobj(cuvar,"EFTPAY"),$C(124),16)="") D vreqerr("DEBAUT") Q 
	 S:'$D(vobj(cuvar,"%IO")) vobj(cuvar,"%IO")=$S(vobj(cuvar,-2):$G(^CUVAR("%IO")),1:"")
	I ($P(vobj(cuvar,"%IO"),$C(124),2)="") D vreqerr("DEVPTR") Q 
	 S:'$D(vobj(cuvar,"EUR")) vobj(cuvar,"EUR")=$S(vobj(cuvar,-2):$G(^CUVAR("EUR")),1:"")
	I ($P(vobj(cuvar,"EUR"),$C(124),6)="") D vreqerr("DFTTHRC") Q 
	I ($P(vobj(cuvar,"EUR"),$C(124),7)="") D vreqerr("DFTTHRR") Q 
	I ($P(vobj(cuvar,"CIF"),$C(124),23)="") D vreqerr("DUPTIN") Q 
	 S:'$D(vobj(cuvar,"EFD")) vobj(cuvar,"EFD")=$S(vobj(cuvar,-2):$G(^CUVAR("EFD")),1:"")
	I ($P(vobj(cuvar,"EFD"),$C(124),1)="") D vreqerr("EFD") Q 
	I ($P(vobj(cuvar,"EFD"),$C(124),2)="") D vreqerr("EFDFTFLG") Q 
	I ($P(vobj(cuvar,"EFTPAY"),$C(124),19)="") D vreqerr("EFTMEMO") Q 
	I ($P(vobj(cuvar,"EFTPAY"),$C(124),15)="") D vreqerr("EFTREFNO") Q 
	I ($P(vobj(cuvar,"EFTPAY"),$C(124),11)="") D vreqerr("EFTRICO") Q 
	I ($P(vobj(cuvar,"EUR"),$C(124),1)="") D vreqerr("EMU") Q 
	 S:'$D(vobj(cuvar,"%ET")) vobj(cuvar,"%ET")=$S(vobj(cuvar,-2):$G(^CUVAR("%ET")),1:"")
	I ($P(vobj(cuvar,"%ET"),$C(124),2)="") D vreqerr("ERRMDFT") Q 
	I ($P(vobj(cuvar,"EUR"),$C(124),18)="") D vreqerr("EURINTEG") Q 
	 S:'$D(vobj(cuvar,"SWIFT")) vobj(cuvar,"SWIFT")=$S(vobj(cuvar,-2):$G(^CUVAR("SWIFT")),1:"")
	I ($P(vobj(cuvar,"SWIFT"),$C(124),5)="") D vreqerr("EXTREM") Q 
	I ($P(vobj(cuvar,"CIF"),$C(124),25)="") D vreqerr("EXTVAL") Q 
	 S:'$D(vobj(cuvar,"%BATCH")) vobj(cuvar,"%BATCH")=$S(vobj(cuvar,-2):$G(^CUVAR("%BATCH")),1:"")
	I ($P(vobj(cuvar,"%BATCH"),$C(124),2)="") D vreqerr("FAILWAIT") Q 
	 S:'$D(vobj(cuvar,"FCVMEMO")) vobj(cuvar,"FCVMEMO")=$S(vobj(cuvar,-2):$G(^CUVAR("FCVMEMO")),1:"")
	I ($P(vobj(cuvar,"FCVMEMO"),$C(124),1)="") D vreqerr("FCVMEMO") Q 
	 S:'$D(vobj(cuvar,"FEPXALL")) vobj(cuvar,"FEPXALL")=$S(vobj(cuvar,-2):$G(^CUVAR("FEPXALL")),1:"")
	I ($P(vobj(cuvar,"FEPXALL"),$C(124),1)="") D vreqerr("FEPXALL") Q 
	 S:'$D(vobj(cuvar,"DAYEND")) vobj(cuvar,"DAYEND")=$S(vobj(cuvar,-2):$G(^CUVAR("DAYEND")),1:"")
	I ($P(vobj(cuvar,"DAYEND"),$C(124),8)="") D vreqerr("FINYE") Q 
	 S:'$D(vobj(cuvar,"DBS")) vobj(cuvar,"DBS")=$S(vobj(cuvar,-2):$G(^CUVAR("DBS")),1:"")
	I ($P(vobj(cuvar,"DBS"),$C(124),1)="") D vreqerr("FLDOVF") Q 
	I ($P(vobj(cuvar,"EUR"),$C(124),2)="") D vreqerr("FNCRATE") Q 
	I ($P(vobj(cuvar,"EFTPAY"),$C(124),17)="") D vreqerr("FUTBLD") Q 
	I ($P(vobj(cuvar,"%CRCD"),$C(124),24)="") D vreqerr("FX") Q 
	 S:'$D(vobj(cuvar,"GLEFD")) vobj(cuvar,"GLEFD")=$S(vobj(cuvar,-2):$G(^CUVAR("GLEFD")),1:"")
	I ($P(vobj(cuvar,"GLEFD"),$C(124),1)="") D vreqerr("GLEFDBCH") Q 
	 S:'$D(vobj(cuvar,"INCK")) vobj(cuvar,"INCK")=$S(vobj(cuvar,-2):$G(^CUVAR("INCK")),1:"")
	I ($P(vobj(cuvar,"INCK"),$C(124),23)="") D vreqerr("ICCFF") Q 
	I ($P(vobj(cuvar,"INCK"),$C(124),24)="") D vreqerr("ICCNF") Q 
	I ($P(vobj(cuvar,"INCK"),$C(124),5)="") D vreqerr("ICDFF") Q 
	I ($P(vobj(cuvar,"INCK"),$C(124),6)="") D vreqerr("ICDNF") Q 
	I ($P(vobj(cuvar,"INCK"),$C(124),7)="") D vreqerr("ICDRF") Q 
	I ($P(vobj(cuvar,"INCK"),$C(124),4)="") D vreqerr("ICDTF") Q 
	I ($P(vobj(cuvar,"INCK"),$C(124),14)="") D vreqerr("ICLFF") Q 
	I ($P(vobj(cuvar,"INCK"),$C(124),15)="") D vreqerr("ICLNF") Q 
	I ($P(vobj(cuvar,"INCK"),$C(124),16)="") D vreqerr("ICLRF") Q 
	I ($P(vobj(cuvar,"INCK"),$C(124),13)="") D vreqerr("ICLTF") Q 
	 S:'$D(vobj(cuvar,"IMAGE")) vobj(cuvar,"IMAGE")=$S(vobj(cuvar,-2):$G(^CUVAR("IMAGE")),1:"")
	I ($P(vobj(cuvar,"IMAGE"),$C(124),1)="") D vreqerr("IMAGE") Q 
	 S:'$D(vobj(cuvar,"IPD")) vobj(cuvar,"IPD")=$S(vobj(cuvar,-2):$G(^CUVAR("IPD")),1:"")
	I ($P(vobj(cuvar,"IPD"),$C(124),1)="") D vreqerr("IPD") Q 
	 S:'$D(vobj(cuvar,"DRMT")) vobj(cuvar,"DRMT")=$S(vobj(cuvar,-2):$G(^CUVAR("DRMT")),1:"")
	I ($P(vobj(cuvar,"DRMT"),$C(124),4)="") D vreqerr("LCCADR") Q 
	I ($P(vobj(cuvar,"DRMT"),$C(124),6)="") D vreqerr("LCCPU") Q 
	I ($P(vobj(cuvar,"DRMT"),$C(124),5)="") D vreqerr("LCCTIT") Q 
	 S:'$D(vobj(cuvar,"LETTER")) vobj(cuvar,"LETTER")=$S(vobj(cuvar,-2):$G(^CUVAR("LETTER")),1:"")
	I ($P(vobj(cuvar,"LETTER"),$C(124),1)="") D vreqerr("LETFIX") Q 
	I ($P(vobj(cuvar,"CIF"),$C(124),16)="") D vreqerr("LIMPRO") Q 
	I ($P(vobj(cuvar,"LN"),$C(124),32)="") D vreqerr("LNRENDEL") Q 
	I ($P(vobj(cuvar,"LN"),$C(124),33)="") D vreqerr("MRPT") Q 
	 S:'$D(vobj(cuvar,"MULTIITSID")) vobj(cuvar,"MULTIITSID")=$S(vobj(cuvar,-2):$G(^CUVAR("MULTIITSID")),1:"")
	I ($P(vobj(cuvar,"MULTIITSID"),$C(124),1)="") D vreqerr("MULTIITSID") Q 
	 S:'$D(vobj(cuvar,"MXTRLM")) vobj(cuvar,"MXTRLM")=$S(vobj(cuvar,-2):$G(^CUVAR("MXTRLM")),1:"")
	I ($P(vobj(cuvar,"MXTRLM"),$C(124),1)="") D vreqerr("MXTRLM") Q 
	 S:'$D(vobj(cuvar,"NOREGD")) vobj(cuvar,"NOREGD")=$S(vobj(cuvar,-2):$G(^CUVAR("NOREGD")),1:"")
	I ($P(vobj(cuvar,"NOREGD"),$C(124),1)="") D vreqerr("NOREGD") Q 
	 S:'$D(vobj(cuvar,"OPTIMIZE")) vobj(cuvar,"OPTIMIZE")=$S(vobj(cuvar,-2):$G(^CUVAR("OPTIMIZE")),1:"")
	I ($P(vobj(cuvar,"OPTIMIZE"),$C(124),1)="") D vreqerr("NOSEGMENTS") Q 
	I ($P(vobj(cuvar,"DBS"),$C(124),7)="") D vreqerr("NOTP") Q 
	 S:'$D(vobj(cuvar,"REGCC")) vobj(cuvar,"REGCC")=$S(vobj(cuvar,-2):$G(^CUVAR("REGCC")),1:"")
	I ($P(vobj(cuvar,"REGCC"),$C(124),11)="") D vreqerr("OBDE") Q 
	 S:'$D(vobj(cuvar,"ODP")) vobj(cuvar,"ODP")=$S(vobj(cuvar,-2):$G(^CUVAR("ODP")),1:"")
	I ($P(vobj(cuvar,"ODP"),$C(124),1)="") D vreqerr("ODP") Q 
	 S:'$D(vobj(cuvar,"ODPE")) vobj(cuvar,"ODPE")=$S(vobj(cuvar,-2):$G(^CUVAR("ODPE")),1:"")
	I ($P(vobj(cuvar,"ODPE"),$C(124),1)="") D vreqerr("ODPE") Q 
	I ($P(vobj(cuvar,"CIF"),$C(124),3)="") D vreqerr("ORCIFN") Q 
	I ($P(vobj(cuvar,"%CRCD"),$C(124),23)="") D vreqerr("OTC") Q 
	 S:'$D(vobj(cuvar,"PUBLISH")) vobj(cuvar,"PUBLISH")=$S(vobj(cuvar,-2):$G(^CUVAR("PUBLISH")),1:"")
	I ($P(vobj(cuvar,"PUBLISH"),$C(124),1)="") D vreqerr("PUBLISH") Q 
	I ($P(vobj(cuvar,"REGCC"),$C(124),7)="") D vreqerr("REGCCOPT") Q 
	 S:'$D(vobj(cuvar,"REGFLG")) vobj(cuvar,"REGFLG")=$S(vobj(cuvar,-2):$G(^CUVAR("REGFLG")),1:"")
	I ($P(vobj(cuvar,"REGFLG"),$C(124),1)="") D vreqerr("REGFLG") Q 
	 S:'$D(vobj(cuvar,"DEAL")) vobj(cuvar,"DEAL")=$S(vobj(cuvar,-2):$G(^CUVAR("DEAL")),1:"")
	I ($P(vobj(cuvar,"DEAL"),$C(124),1)="") D vreqerr("REKEY") Q 
	 S:'$D(vobj(cuvar,"RESPROC")) vobj(cuvar,"RESPROC")=$S(vobj(cuvar,-2):$G(^CUVAR("RESPROC")),1:"")
	I ($P(vobj(cuvar,"RESPROC"),$C(124),1)="") D vreqerr("RESPROC") Q 
	 S:'$D(vobj(cuvar,"RESTRICT")) vobj(cuvar,"RESTRICT")=$S(vobj(cuvar,-2):$G(^CUVAR("RESTRICT")),1:"")
	I ($P(vobj(cuvar,"RESTRICT"),$C(124),1)="") D vreqerr("RESTRICT") Q 
	I ($P(vobj(cuvar,"DEP"),$C(124),11)="") D vreqerr("RPANET") Q 
	 S:'$D(vobj(cuvar,"SCAUREL")) vobj(cuvar,"SCAUREL")=$S(vobj(cuvar,-2):$G(^CUVAR("SCAUREL")),1:"")
	I ($P(vobj(cuvar,"SCAUREL"),$C(124),1)="") D vreqerr("SCAUREL") Q 
	 S:'$D(vobj(cuvar,"SCHRC")) vobj(cuvar,"SCHRC")=$S(vobj(cuvar,-2):$G(^CUVAR("SCHRC")),1:"")
	I ($P(vobj(cuvar,"SCHRC"),$C(124),1)="") D vreqerr("SCHRCC") Q 
	I ($P(vobj(cuvar,"SCHRC"),$C(124),7)="") D vreqerr("SCHRCE") Q 
	I ($P(vobj(cuvar,"SCHRC"),$C(124),2)="") D vreqerr("SCHRCJ") Q 
	I ($P(vobj(cuvar,"SCHRC"),$C(124),3)="") D vreqerr("SCHRCK") Q 
	I ($P(vobj(cuvar,"SCHRC"),$C(124),4)="") D vreqerr("SCHRCL") Q 
	I ($P(vobj(cuvar,"SCHRC"),$C(124),5)="") D vreqerr("SCHRCN") Q 
	I ($P(vobj(cuvar,"SCHRC"),$C(124),6)="") D vreqerr("SCHRI") Q 
	I ($P(vobj(cuvar,"EUR"),$C(124),15)="") D vreqerr("SCOVR") Q 
	I ($P(vobj(cuvar,"ODP"),$C(124),2)="") D vreqerr("SFEEOPT") Q 
	 S:'$D(vobj(cuvar,"SPLITDAY")) vobj(cuvar,"SPLITDAY")=$S(vobj(cuvar,-2):$G(^CUVAR("SPLITDAY")),1:"")
	I ($P(vobj(cuvar,"SPLITDAY"),$C(124),1)="") D vreqerr("SPLITDAY") Q 
	I ($P(vobj(cuvar,"DRMT"),$C(124),3)="") D vreqerr("STMLCC") Q 
	 S:'$D(vobj(cuvar,"STMTSRT")) vobj(cuvar,"STMTSRT")=$S(vobj(cuvar,-2):$G(^CUVAR("STMTSRT")),1:"")
	I ($P(vobj(cuvar,"STMTSRT"),$C(124),3)="") D vreqerr("STMTCDSKIP") Q 
	I ($P(vobj(cuvar,"STMTSRT"),$C(124),6)="") D vreqerr("STMTCUMUL") Q 
	I ($P(vobj(cuvar,"STMTSRT"),$C(124),4)="") D vreqerr("STMTINTRTC") Q 
	I ($P(vobj(cuvar,"STMTSRT"),$C(124),5)="") D vreqerr("STMTLNSKIP") Q 
	I ($P(vobj(cuvar,"DAYEND"),$C(124),9)="") D vreqerr("TAXYE") Q 
	I ($P(vobj(cuvar,"%CRCD"),$C(124),25)="") D vreqerr("TFS") Q 
	I ($P(vobj(cuvar,"CIF"),$C(124),24)="") D vreqerr("TINCO") Q 
	 S:'$D(vobj(cuvar,"CRT")) vobj(cuvar,"CRT")=$S(vobj(cuvar,-2):$G(^CUVAR("CRT")),1:"")
	I ($P(vobj(cuvar,"CRT"),$C(124),7)="") D vreqerr("TREF") Q 
	 S:'$D(vobj(cuvar,"UACNL1F")) vobj(cuvar,"UACNL1F")=$S(vobj(cuvar,-2):$G(^CUVAR("UACNL1F")),1:"")
	I ($P(vobj(cuvar,"UACNL1F"),$C(124),1)="") D vreqerr("UACNL1F") Q 
	 S:'$D(vobj(cuvar,"USRESTAT")) vobj(cuvar,"USRESTAT")=$S(vobj(cuvar,-2):$G(^CUVAR("USRESTAT")),1:"")
	I ($P(vobj(cuvar,"USRESTAT"),$C(124),1)="") D vreqerr("USRESTAT") Q 
	Q 
	;
vrequ	; Valid required columns on update
	;
	I '($order(vobj(cuvar,-100,1099,""))="") D
	.	 S:'$D(vobj(cuvar,1099)) vobj(cuvar,1099)=$S(vobj(cuvar,-2):$G(^CUVAR(1099)),1:"")
	.	I ($D(vx("CTOF1098"))#2),($P(vobj(cuvar,1099),$C(124),8)="") D vreqerr("CTOF1098") Q 
	.	I ($D(vx("CTOF1099"))#2),($P(vobj(cuvar,1099),$C(124),9)="") D vreqerr("CTOF1099") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"%BATCH",""))="") D
	.	 S:'$D(vobj(cuvar,"%BATCH")) vobj(cuvar,"%BATCH")=$S(vobj(cuvar,-2):$G(^CUVAR("%BATCH")),1:"")
	.	I ($D(vx("FAILWAIT"))#2),($P(vobj(cuvar,"%BATCH"),$C(124),2)="") D vreqerr("FAILWAIT") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"%CRCD",""))="") D
	.	 S:'$D(vobj(cuvar,"%CRCD")) vobj(cuvar,"%CRCD")=$S(vobj(cuvar,-2):$G(^CUVAR("%CRCD")),1:"")
	.	I ($D(vx("BSEMOD"))#2),($P(vobj(cuvar,"%CRCD"),$C(124),11)="") D vreqerr("BSEMOD") Q 
	.	I ($D(vx("CCMOD"))#2),($P(vobj(cuvar,"%CRCD"),$C(124),12)="") D vreqerr("CCMOD") Q 
	.	I ($D(vx("BAMTMOD"))#2),($P(vobj(cuvar,"%CRCD"),$C(124),13)="") D vreqerr("BAMTMOD") Q 
	.	I ($D(vx("OTC"))#2),($P(vobj(cuvar,"%CRCD"),$C(124),23)="") D vreqerr("OTC") Q 
	.	I ($D(vx("FX"))#2),($P(vobj(cuvar,"%CRCD"),$C(124),24)="") D vreqerr("FX") Q 
	.	I ($D(vx("TFS"))#2),($P(vobj(cuvar,"%CRCD"),$C(124),25)="") D vreqerr("TFS") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"%ET",""))="") D
	.	 S:'$D(vobj(cuvar,"%ET")) vobj(cuvar,"%ET")=$S(vobj(cuvar,-2):$G(^CUVAR("%ET")),1:"")
	.	I ($D(vx("ERRMDFT"))#2),($P(vobj(cuvar,"%ET"),$C(124),2)="") D vreqerr("ERRMDFT") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"%IO",""))="") D
	.	 S:'$D(vobj(cuvar,"%IO")) vobj(cuvar,"%IO")=$S(vobj(cuvar,-2):$G(^CUVAR("%IO")),1:"")
	.	I ($D(vx("DEVPTR"))#2),($P(vobj(cuvar,"%IO"),$C(124),2)="") D vreqerr("DEVPTR") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"%KEYS",""))="") D
	.	 S:'$D(vobj(cuvar,"%KEYS")) vobj(cuvar,"%KEYS")=$S(vobj(cuvar,-2):$G(^CUVAR("%KEYS")),1:"")
	.	I ($D(vx("%KEYS"))#2),($P(vobj(cuvar,"%KEYS"),$C(124),1)="") D vreqerr("%KEYS") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"%MCP",""))="") D
	.	 S:'$D(vobj(cuvar,"%MCP")) vobj(cuvar,"%MCP")=$S(vobj(cuvar,-2):$G(^CUVAR("%MCP")),1:"")
	.	I ($D(vx("%MCP"))#2),($P(vobj(cuvar,"%MCP"),$C(124),1)="") D vreqerr("%MCP") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"ALP",""))="") D
	.	 S:'$D(vobj(cuvar,"ALP")) vobj(cuvar,"ALP")=$S(vobj(cuvar,-2):$G(^CUVAR("ALP")),1:"")
	.	I ($D(vx("ALPHI"))#2),($P(vobj(cuvar,"ALP"),$C(124),1)="") D vreqerr("ALPHI") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"BANNER",""))="") D
	.	 S:'$D(vobj(cuvar,"BANNER")) vobj(cuvar,"BANNER")=$S(vobj(cuvar,-2):$G(^CUVAR("BANNER")),1:"")
	.	I ($D(vx("BANNER"))#2),($P(vobj(cuvar,"BANNER"),$C(124),1)="") D vreqerr("BANNER") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"BINDEF",""))="") D
	.	 S:'$D(vobj(cuvar,"BINDEF")) vobj(cuvar,"BINDEF")=$S(vobj(cuvar,-2):$G(^CUVAR("BINDEF")),1:"")
	.	I ($D(vx("BINDEF"))#2),($P(vobj(cuvar,"BINDEF"),$C(124),1)="") D vreqerr("BINDEF") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"BOBR",""))="") D
	.	 S:'$D(vobj(cuvar,"BOBR")) vobj(cuvar,"BOBR")=$S(vobj(cuvar,-2):$G(^CUVAR("BOBR")),1:"")
	.	I ($D(vx("BOBR"))#2),($P(vobj(cuvar,"BOBR"),$C(124),1)="") D vreqerr("BOBR") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"CHK",""))="") D
	.	 S:'$D(vobj(cuvar,"CHK")) vobj(cuvar,"CHK")=$S(vobj(cuvar,-2):$G(^CUVAR("CHK")),1:"")
	.	I ($D(vx("CHKIMG"))#2),($P(vobj(cuvar,"CHK"),$C(124),1)="") D vreqerr("CHKIMG") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"CIF",""))="") D
	.	 S:'$D(vobj(cuvar,"CIF")) vobj(cuvar,"CIF")=$S(vobj(cuvar,-2):$G(^CUVAR("CIF")),1:"")
	.	I ($D(vx("ORCIFN"))#2),($P(vobj(cuvar,"CIF"),$C(124),3)="") D vreqerr("ORCIFN") Q 
	.	I ($D(vx("CIFALLOC"))#2),($P(vobj(cuvar,"CIF"),$C(124),13)="") D vreqerr("CIFALLOC") Q 
	.	I ($D(vx("LIMPRO"))#2),($P(vobj(cuvar,"CIF"),$C(124),16)="") D vreqerr("LIMPRO") Q 
	.	I ($D(vx("DUPTIN"))#2),($P(vobj(cuvar,"CIF"),$C(124),23)="") D vreqerr("DUPTIN") Q 
	.	I ($D(vx("TINCO"))#2),($P(vobj(cuvar,"CIF"),$C(124),24)="") D vreqerr("TINCO") Q 
	.	I ($D(vx("EXTVAL"))#2),($P(vobj(cuvar,"CIF"),$C(124),25)="") D vreqerr("EXTVAL") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"CNTRY",""))="") D
	.	 S:'$D(vobj(cuvar,"CNTRY")) vobj(cuvar,"CNTRY")=$S(vobj(cuvar,-2):$G(^CUVAR("CNTRY")),1:"")
	.	I ($D(vx("CATSUP"))#2),($P(vobj(cuvar,"CNTRY"),$C(124),2)="") D vreqerr("CATSUP") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"CRT",""))="") D
	.	 S:'$D(vobj(cuvar,"CRT")) vobj(cuvar,"CRT")=$S(vobj(cuvar,-2):$G(^CUVAR("CRT")),1:"")
	.	I ($D(vx("TREF"))#2),($P(vobj(cuvar,"CRT"),$C(124),7)="") D vreqerr("TREF") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"CRTDSP",""))="") D
	.	 S:'$D(vobj(cuvar,"CRTDSP")) vobj(cuvar,"CRTDSP")=$S(vobj(cuvar,-2):$G(^CUVAR("CRTDSP")),1:"")
	.	I ($D(vx("CRTDSP"))#2),($P(vobj(cuvar,"CRTDSP"),$C(124),1)="") D vreqerr("CRTDSP") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"CURRENV",""))="") D
	.	 S:'$D(vobj(cuvar,"CURRENV")) vobj(cuvar,"CURRENV")=$S(vobj(cuvar,-2):$G(^CUVAR("CURRENV")),1:"")
	.	I ($D(vx("CURRENV"))#2),($P(vobj(cuvar,"CURRENV"),$C(124),1)="") D vreqerr("CURRENV") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"DAYEND",""))="") D
	.	 S:'$D(vobj(cuvar,"DAYEND")) vobj(cuvar,"DAYEND")=$S(vobj(cuvar,-2):$G(^CUVAR("DAYEND")),1:"")
	.	I ($D(vx("FINYE"))#2),($P(vobj(cuvar,"DAYEND"),$C(124),8)="") D vreqerr("FINYE") Q 
	.	I ($D(vx("TAXYE"))#2),($P(vobj(cuvar,"DAYEND"),$C(124),9)="") D vreqerr("TAXYE") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"DBS",""))="") D
	.	 S:'$D(vobj(cuvar,"DBS")) vobj(cuvar,"DBS")=$S(vobj(cuvar,-2):$G(^CUVAR("DBS")),1:"")
	.	I ($D(vx("FLDOVF"))#2),($P(vobj(cuvar,"DBS"),$C(124),1)="") D vreqerr("FLDOVF") Q 
	.	I ($D(vx("NOTP"))#2),($P(vobj(cuvar,"DBS"),$C(124),7)="") D vreqerr("NOTP") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"DEAL",""))="") D
	.	 S:'$D(vobj(cuvar,"DEAL")) vobj(cuvar,"DEAL")=$S(vobj(cuvar,-2):$G(^CUVAR("DEAL")),1:"")
	.	I ($D(vx("REKEY"))#2),($P(vobj(cuvar,"DEAL"),$C(124),1)="") D vreqerr("REKEY") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"DEP",""))="") D
	.	 S:'$D(vobj(cuvar,"DEP")) vobj(cuvar,"DEP")=$S(vobj(cuvar,-2):$G(^CUVAR("DEP")),1:"")
	.	I ($D(vx("RPANET"))#2),($P(vobj(cuvar,"DEP"),$C(124),11)="") D vreqerr("RPANET") Q 
	.	I ($D(vx("CMSACOPT"))#2),($P(vobj(cuvar,"DEP"),$C(124),17)="") D vreqerr("CMSACOPT") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"DRMT",""))="") D
	.	 S:'$D(vobj(cuvar,"DRMT")) vobj(cuvar,"DRMT")=$S(vobj(cuvar,-2):$G(^CUVAR("DRMT")),1:"")
	.	I ($D(vx("STMLCC"))#2),($P(vobj(cuvar,"DRMT"),$C(124),3)="") D vreqerr("STMLCC") Q 
	.	I ($D(vx("LCCADR"))#2),($P(vobj(cuvar,"DRMT"),$C(124),4)="") D vreqerr("LCCADR") Q 
	.	I ($D(vx("LCCTIT"))#2),($P(vobj(cuvar,"DRMT"),$C(124),5)="") D vreqerr("LCCTIT") Q 
	.	I ($D(vx("LCCPU"))#2),($P(vobj(cuvar,"DRMT"),$C(124),6)="") D vreqerr("LCCPU") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"EFD",""))="") D
	.	 S:'$D(vobj(cuvar,"EFD")) vobj(cuvar,"EFD")=$S(vobj(cuvar,-2):$G(^CUVAR("EFD")),1:"")
	.	I ($D(vx("EFD"))#2),($P(vobj(cuvar,"EFD"),$C(124),1)="") D vreqerr("EFD") Q 
	.	I ($D(vx("EFDFTFLG"))#2),($P(vobj(cuvar,"EFD"),$C(124),2)="") D vreqerr("EFDFTFLG") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"EFTPAY",""))="") D
	.	 S:'$D(vobj(cuvar,"EFTPAY")) vobj(cuvar,"EFTPAY")=$S(vobj(cuvar,-2):$G(^CUVAR("EFTPAY")),1:"")
	.	I ($D(vx("EFTRICO"))#2),($P(vobj(cuvar,"EFTPAY"),$C(124),11)="") D vreqerr("EFTRICO") Q 
	.	I ($D(vx("EFTREFNO"))#2),($P(vobj(cuvar,"EFTPAY"),$C(124),15)="") D vreqerr("EFTREFNO") Q 
	.	I ($D(vx("DEBAUT"))#2),($P(vobj(cuvar,"EFTPAY"),$C(124),16)="") D vreqerr("DEBAUT") Q 
	.	I ($D(vx("FUTBLD"))#2),($P(vobj(cuvar,"EFTPAY"),$C(124),17)="") D vreqerr("FUTBLD") Q 
	.	I ($D(vx("EFTMEMO"))#2),($P(vobj(cuvar,"EFTPAY"),$C(124),19)="") D vreqerr("EFTMEMO") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"EUR",""))="") D
	.	 S:'$D(vobj(cuvar,"EUR")) vobj(cuvar,"EUR")=$S(vobj(cuvar,-2):$G(^CUVAR("EUR")),1:"")
	.	I ($D(vx("EMU"))#2),($P(vobj(cuvar,"EUR"),$C(124),1)="") D vreqerr("EMU") Q 
	.	I ($D(vx("FNCRATE"))#2),($P(vobj(cuvar,"EUR"),$C(124),2)="") D vreqerr("FNCRATE") Q 
	.	I ($D(vx("DFTTHRC"))#2),($P(vobj(cuvar,"EUR"),$C(124),6)="") D vreqerr("DFTTHRC") Q 
	.	I ($D(vx("DFTTHRR"))#2),($P(vobj(cuvar,"EUR"),$C(124),7)="") D vreqerr("DFTTHRR") Q 
	.	I ($D(vx("SCOVR"))#2),($P(vobj(cuvar,"EUR"),$C(124),15)="") D vreqerr("SCOVR") Q 
	.	I ($D(vx("EURINTEG"))#2),($P(vobj(cuvar,"EUR"),$C(124),18)="") D vreqerr("EURINTEG") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"FCVMEMO",""))="") D
	.	 S:'$D(vobj(cuvar,"FCVMEMO")) vobj(cuvar,"FCVMEMO")=$S(vobj(cuvar,-2):$G(^CUVAR("FCVMEMO")),1:"")
	.	I ($D(vx("FCVMEMO"))#2),($P(vobj(cuvar,"FCVMEMO"),$C(124),1)="") D vreqerr("FCVMEMO") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"FEPXALL",""))="") D
	.	 S:'$D(vobj(cuvar,"FEPXALL")) vobj(cuvar,"FEPXALL")=$S(vobj(cuvar,-2):$G(^CUVAR("FEPXALL")),1:"")
	.	I ($D(vx("FEPXALL"))#2),($P(vobj(cuvar,"FEPXALL"),$C(124),1)="") D vreqerr("FEPXALL") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"GLEFD",""))="") D
	.	 S:'$D(vobj(cuvar,"GLEFD")) vobj(cuvar,"GLEFD")=$S(vobj(cuvar,-2):$G(^CUVAR("GLEFD")),1:"")
	.	I ($D(vx("GLEFDBCH"))#2),($P(vobj(cuvar,"GLEFD"),$C(124),1)="") D vreqerr("GLEFDBCH") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"IMAGE",""))="") D
	.	 S:'$D(vobj(cuvar,"IMAGE")) vobj(cuvar,"IMAGE")=$S(vobj(cuvar,-2):$G(^CUVAR("IMAGE")),1:"")
	.	I ($D(vx("IMAGE"))#2),($P(vobj(cuvar,"IMAGE"),$C(124),1)="") D vreqerr("IMAGE") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"INCK",""))="") D
	.	 S:'$D(vobj(cuvar,"INCK")) vobj(cuvar,"INCK")=$S(vobj(cuvar,-2):$G(^CUVAR("INCK")),1:"")
	.	I ($D(vx("ICDTF"))#2),($P(vobj(cuvar,"INCK"),$C(124),4)="") D vreqerr("ICDTF") Q 
	.	I ($D(vx("ICDFF"))#2),($P(vobj(cuvar,"INCK"),$C(124),5)="") D vreqerr("ICDFF") Q 
	.	I ($D(vx("ICDNF"))#2),($P(vobj(cuvar,"INCK"),$C(124),6)="") D vreqerr("ICDNF") Q 
	.	I ($D(vx("ICDRF"))#2),($P(vobj(cuvar,"INCK"),$C(124),7)="") D vreqerr("ICDRF") Q 
	.	I ($D(vx("ICLTF"))#2),($P(vobj(cuvar,"INCK"),$C(124),13)="") D vreqerr("ICLTF") Q 
	.	I ($D(vx("ICLFF"))#2),($P(vobj(cuvar,"INCK"),$C(124),14)="") D vreqerr("ICLFF") Q 
	.	I ($D(vx("ICLNF"))#2),($P(vobj(cuvar,"INCK"),$C(124),15)="") D vreqerr("ICLNF") Q 
	.	I ($D(vx("ICLRF"))#2),($P(vobj(cuvar,"INCK"),$C(124),16)="") D vreqerr("ICLRF") Q 
	.	I ($D(vx("ICCFF"))#2),($P(vobj(cuvar,"INCK"),$C(124),23)="") D vreqerr("ICCFF") Q 
	.	I ($D(vx("ICCNF"))#2),($P(vobj(cuvar,"INCK"),$C(124),24)="") D vreqerr("ICCNF") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"IPD",""))="") D
	.	 S:'$D(vobj(cuvar,"IPD")) vobj(cuvar,"IPD")=$S(vobj(cuvar,-2):$G(^CUVAR("IPD")),1:"")
	.	I ($D(vx("IPD"))#2),($P(vobj(cuvar,"IPD"),$C(124),1)="") D vreqerr("IPD") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"LETTER",""))="") D
	.	 S:'$D(vobj(cuvar,"LETTER")) vobj(cuvar,"LETTER")=$S(vobj(cuvar,-2):$G(^CUVAR("LETTER")),1:"")
	.	I ($D(vx("LETFIX"))#2),($P(vobj(cuvar,"LETTER"),$C(124),1)="") D vreqerr("LETFIX") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"LN",""))="") D
	.	 S:'$D(vobj(cuvar,"LN")) vobj(cuvar,"LN")=$S(vobj(cuvar,-2):$G(^CUVAR("LN")),1:"")
	.	I ($D(vx("DARCDFLG"))#2),($P(vobj(cuvar,"LN"),$C(124),31)="") D vreqerr("DARCDFLG") Q 
	.	I ($D(vx("LNRENDEL"))#2),($P(vobj(cuvar,"LN"),$C(124),32)="") D vreqerr("LNRENDEL") Q 
	.	I ($D(vx("MRPT"))#2),($P(vobj(cuvar,"LN"),$C(124),33)="") D vreqerr("MRPT") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"MFUND",""))="") D
	.	 S:'$D(vobj(cuvar,"MFUND")) vobj(cuvar,"MFUND")=$S(vobj(cuvar,-2):$G(^CUVAR("MFUND")),1:"")
	.	I ($D(vx("CIFEXTI"))#2),($P(vobj(cuvar,"MFUND"),$C(124),5)="") D vreqerr("CIFEXTI") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"MULTIITSID",""))="") D
	.	 S:'$D(vobj(cuvar,"MULTIITSID")) vobj(cuvar,"MULTIITSID")=$S(vobj(cuvar,-2):$G(^CUVAR("MULTIITSID")),1:"")
	.	I ($D(vx("MULTIITSID"))#2),($P(vobj(cuvar,"MULTIITSID"),$C(124),1)="") D vreqerr("MULTIITSID") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"MXTRLM",""))="") D
	.	 S:'$D(vobj(cuvar,"MXTRLM")) vobj(cuvar,"MXTRLM")=$S(vobj(cuvar,-2):$G(^CUVAR("MXTRLM")),1:"")
	.	I ($D(vx("MXTRLM"))#2),($P(vobj(cuvar,"MXTRLM"),$C(124),1)="") D vreqerr("MXTRLM") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"NOREGD",""))="") D
	.	 S:'$D(vobj(cuvar,"NOREGD")) vobj(cuvar,"NOREGD")=$S(vobj(cuvar,-2):$G(^CUVAR("NOREGD")),1:"")
	.	I ($D(vx("NOREGD"))#2),($P(vobj(cuvar,"NOREGD"),$C(124),1)="") D vreqerr("NOREGD") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"ODP",""))="") D
	.	 S:'$D(vobj(cuvar,"ODP")) vobj(cuvar,"ODP")=$S(vobj(cuvar,-2):$G(^CUVAR("ODP")),1:"")
	.	I ($D(vx("ODP"))#2),($P(vobj(cuvar,"ODP"),$C(124),1)="") D vreqerr("ODP") Q 
	.	I ($D(vx("SFEEOPT"))#2),($P(vobj(cuvar,"ODP"),$C(124),2)="") D vreqerr("SFEEOPT") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"ODPE",""))="") D
	.	 S:'$D(vobj(cuvar,"ODPE")) vobj(cuvar,"ODPE")=$S(vobj(cuvar,-2):$G(^CUVAR("ODPE")),1:"")
	.	I ($D(vx("ODPE"))#2),($P(vobj(cuvar,"ODPE"),$C(124),1)="") D vreqerr("ODPE") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"OPTIMIZE",""))="") D
	.	 S:'$D(vobj(cuvar,"OPTIMIZE")) vobj(cuvar,"OPTIMIZE")=$S(vobj(cuvar,-2):$G(^CUVAR("OPTIMIZE")),1:"")
	.	I ($D(vx("NOSEGMENTS"))#2),($P(vobj(cuvar,"OPTIMIZE"),$C(124),1)="") D vreqerr("NOSEGMENTS") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"PUBLISH",""))="") D
	.	 S:'$D(vobj(cuvar,"PUBLISH")) vobj(cuvar,"PUBLISH")=$S(vobj(cuvar,-2):$G(^CUVAR("PUBLISH")),1:"")
	.	I ($D(vx("PUBLISH"))#2),($P(vobj(cuvar,"PUBLISH"),$C(124),1)="") D vreqerr("PUBLISH") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"REGCC",""))="") D
	.	 S:'$D(vobj(cuvar,"REGCC")) vobj(cuvar,"REGCC")=$S(vobj(cuvar,-2):$G(^CUVAR("REGCC")),1:"")
	.	I ($D(vx("REGCCOPT"))#2),($P(vobj(cuvar,"REGCC"),$C(124),7)="") D vreqerr("REGCCOPT") Q 
	.	I ($D(vx("OBDE"))#2),($P(vobj(cuvar,"REGCC"),$C(124),11)="") D vreqerr("OBDE") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"REGFLG",""))="") D
	.	 S:'$D(vobj(cuvar,"REGFLG")) vobj(cuvar,"REGFLG")=$S(vobj(cuvar,-2):$G(^CUVAR("REGFLG")),1:"")
	.	I ($D(vx("REGFLG"))#2),($P(vobj(cuvar,"REGFLG"),$C(124),1)="") D vreqerr("REGFLG") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"RESPROC",""))="") D
	.	 S:'$D(vobj(cuvar,"RESPROC")) vobj(cuvar,"RESPROC")=$S(vobj(cuvar,-2):$G(^CUVAR("RESPROC")),1:"")
	.	I ($D(vx("RESPROC"))#2),($P(vobj(cuvar,"RESPROC"),$C(124),1)="") D vreqerr("RESPROC") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"RESTRICT",""))="") D
	.	 S:'$D(vobj(cuvar,"RESTRICT")) vobj(cuvar,"RESTRICT")=$S(vobj(cuvar,-2):$G(^CUVAR("RESTRICT")),1:"")
	.	I ($D(vx("RESTRICT"))#2),($P(vobj(cuvar,"RESTRICT"),$C(124),1)="") D vreqerr("RESTRICT") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"SCAUREL",""))="") D
	.	 S:'$D(vobj(cuvar,"SCAUREL")) vobj(cuvar,"SCAUREL")=$S(vobj(cuvar,-2):$G(^CUVAR("SCAUREL")),1:"")
	.	I ($D(vx("SCAUREL"))#2),($P(vobj(cuvar,"SCAUREL"),$C(124),1)="") D vreqerr("SCAUREL") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"SCHRC",""))="") D
	.	 S:'$D(vobj(cuvar,"SCHRC")) vobj(cuvar,"SCHRC")=$S(vobj(cuvar,-2):$G(^CUVAR("SCHRC")),1:"")
	.	I ($D(vx("SCHRCC"))#2),($P(vobj(cuvar,"SCHRC"),$C(124),1)="") D vreqerr("SCHRCC") Q 
	.	I ($D(vx("SCHRCJ"))#2),($P(vobj(cuvar,"SCHRC"),$C(124),2)="") D vreqerr("SCHRCJ") Q 
	.	I ($D(vx("SCHRCK"))#2),($P(vobj(cuvar,"SCHRC"),$C(124),3)="") D vreqerr("SCHRCK") Q 
	.	I ($D(vx("SCHRCL"))#2),($P(vobj(cuvar,"SCHRC"),$C(124),4)="") D vreqerr("SCHRCL") Q 
	.	I ($D(vx("SCHRCN"))#2),($P(vobj(cuvar,"SCHRC"),$C(124),5)="") D vreqerr("SCHRCN") Q 
	.	I ($D(vx("SCHRI"))#2),($P(vobj(cuvar,"SCHRC"),$C(124),6)="") D vreqerr("SCHRI") Q 
	.	I ($D(vx("SCHRCE"))#2),($P(vobj(cuvar,"SCHRC"),$C(124),7)="") D vreqerr("SCHRCE") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"SPLITDAY",""))="") D
	.	 S:'$D(vobj(cuvar,"SPLITDAY")) vobj(cuvar,"SPLITDAY")=$S(vobj(cuvar,-2):$G(^CUVAR("SPLITDAY")),1:"")
	.	I ($D(vx("SPLITDAY"))#2),($P(vobj(cuvar,"SPLITDAY"),$C(124),1)="") D vreqerr("SPLITDAY") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"STMTSRT",""))="") D
	.	 S:'$D(vobj(cuvar,"STMTSRT")) vobj(cuvar,"STMTSRT")=$S(vobj(cuvar,-2):$G(^CUVAR("STMTSRT")),1:"")
	.	I ($D(vx("STMTCDSKIP"))#2),($P(vobj(cuvar,"STMTSRT"),$C(124),3)="") D vreqerr("STMTCDSKIP") Q 
	.	I ($D(vx("STMTINTRTC"))#2),($P(vobj(cuvar,"STMTSRT"),$C(124),4)="") D vreqerr("STMTINTRTC") Q 
	.	I ($D(vx("STMTLNSKIP"))#2),($P(vobj(cuvar,"STMTSRT"),$C(124),5)="") D vreqerr("STMTLNSKIP") Q 
	.	I ($D(vx("STMTCUMUL"))#2),($P(vobj(cuvar,"STMTSRT"),$C(124),6)="") D vreqerr("STMTCUMUL") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"SWIFT",""))="") D
	.	 S:'$D(vobj(cuvar,"SWIFT")) vobj(cuvar,"SWIFT")=$S(vobj(cuvar,-2):$G(^CUVAR("SWIFT")),1:"")
	.	I ($D(vx("EXTREM"))#2),($P(vobj(cuvar,"SWIFT"),$C(124),5)="") D vreqerr("EXTREM") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"UACNL1F",""))="") D
	.	 S:'$D(vobj(cuvar,"UACNL1F")) vobj(cuvar,"UACNL1F")=$S(vobj(cuvar,-2):$G(^CUVAR("UACNL1F")),1:"")
	.	I ($D(vx("UACNL1F"))#2),($P(vobj(cuvar,"UACNL1F"),$C(124),1)="") D vreqerr("UACNL1F") Q 
	.	Q 
	I '($order(vobj(cuvar,-100,"USRESTAT",""))="") D
	.	 S:'$D(vobj(cuvar,"USRESTAT")) vobj(cuvar,"USRESTAT")=$S(vobj(cuvar,-2):$G(^CUVAR("USRESTAT")),1:"")
	.	I ($D(vx("USRESTAT"))#2),($P(vobj(cuvar,"USRESTAT"),$C(124),1)="") D vreqerr("USRESTAT") Q 
	.	Q 
	 S:'$D(vobj(cuvar,"%KEYS")) vobj(cuvar,"%KEYS")=$S(vobj(cuvar,-2):$G(^CUVAR("%KEYS")),1:"")
	I ($D(vx("%KEYS"))#2),($P(vobj(cuvar,"%KEYS"),$C(124),1)="") D vreqerr("%KEYS") Q 
	 S:'$D(vobj(cuvar,"%MCP")) vobj(cuvar,"%MCP")=$S(vobj(cuvar,-2):$G(^CUVAR("%MCP")),1:"")
	I ($D(vx("%MCP"))#2),($P(vobj(cuvar,"%MCP"),$C(124),1)="") D vreqerr("%MCP") Q 
	 S:'$D(vobj(cuvar,"ALP")) vobj(cuvar,"ALP")=$S(vobj(cuvar,-2):$G(^CUVAR("ALP")),1:"")
	I ($D(vx("ALPHI"))#2),($P(vobj(cuvar,"ALP"),$C(124),1)="") D vreqerr("ALPHI") Q 
	 S:'$D(vobj(cuvar,"%CRCD")) vobj(cuvar,"%CRCD")=$S(vobj(cuvar,-2):$G(^CUVAR("%CRCD")),1:"")
	I ($D(vx("BAMTMOD"))#2),($P(vobj(cuvar,"%CRCD"),$C(124),13)="") D vreqerr("BAMTMOD") Q 
	 S:'$D(vobj(cuvar,"BANNER")) vobj(cuvar,"BANNER")=$S(vobj(cuvar,-2):$G(^CUVAR("BANNER")),1:"")
	I ($D(vx("BANNER"))#2),($P(vobj(cuvar,"BANNER"),$C(124),1)="") D vreqerr("BANNER") Q 
	 S:'$D(vobj(cuvar,"BINDEF")) vobj(cuvar,"BINDEF")=$S(vobj(cuvar,-2):$G(^CUVAR("BINDEF")),1:"")
	I ($D(vx("BINDEF"))#2),($P(vobj(cuvar,"BINDEF"),$C(124),1)="") D vreqerr("BINDEF") Q 
	 S:'$D(vobj(cuvar,"BOBR")) vobj(cuvar,"BOBR")=$S(vobj(cuvar,-2):$G(^CUVAR("BOBR")),1:"")
	I ($D(vx("BOBR"))#2),($P(vobj(cuvar,"BOBR"),$C(124),1)="") D vreqerr("BOBR") Q 
	I ($D(vx("BSEMOD"))#2),($P(vobj(cuvar,"%CRCD"),$C(124),11)="") D vreqerr("BSEMOD") Q 
	 S:'$D(vobj(cuvar,"CNTRY")) vobj(cuvar,"CNTRY")=$S(vobj(cuvar,-2):$G(^CUVAR("CNTRY")),1:"")
	I ($D(vx("CATSUP"))#2),($P(vobj(cuvar,"CNTRY"),$C(124),2)="") D vreqerr("CATSUP") Q 
	I ($D(vx("CCMOD"))#2),($P(vobj(cuvar,"%CRCD"),$C(124),12)="") D vreqerr("CCMOD") Q 
	 S:'$D(vobj(cuvar,"CHK")) vobj(cuvar,"CHK")=$S(vobj(cuvar,-2):$G(^CUVAR("CHK")),1:"")
	I ($D(vx("CHKIMG"))#2),($P(vobj(cuvar,"CHK"),$C(124),1)="") D vreqerr("CHKIMG") Q 
	 S:'$D(vobj(cuvar,"CIF")) vobj(cuvar,"CIF")=$S(vobj(cuvar,-2):$G(^CUVAR("CIF")),1:"")
	I ($D(vx("CIFALLOC"))#2),($P(vobj(cuvar,"CIF"),$C(124),13)="") D vreqerr("CIFALLOC") Q 
	 S:'$D(vobj(cuvar,"MFUND")) vobj(cuvar,"MFUND")=$S(vobj(cuvar,-2):$G(^CUVAR("MFUND")),1:"")
	I ($D(vx("CIFEXTI"))#2),($P(vobj(cuvar,"MFUND"),$C(124),5)="") D vreqerr("CIFEXTI") Q 
	 S:'$D(vobj(cuvar,"DEP")) vobj(cuvar,"DEP")=$S(vobj(cuvar,-2):$G(^CUVAR("DEP")),1:"")
	I ($D(vx("CMSACOPT"))#2),($P(vobj(cuvar,"DEP"),$C(124),17)="") D vreqerr("CMSACOPT") Q 
	 S:'$D(vobj(cuvar,"CRTDSP")) vobj(cuvar,"CRTDSP")=$S(vobj(cuvar,-2):$G(^CUVAR("CRTDSP")),1:"")
	I ($D(vx("CRTDSP"))#2),($P(vobj(cuvar,"CRTDSP"),$C(124),1)="") D vreqerr("CRTDSP") Q 
	 S:'$D(vobj(cuvar,1099)) vobj(cuvar,1099)=$S(vobj(cuvar,-2):$G(^CUVAR(1099)),1:"")
	I ($D(vx("CTOF1098"))#2),($P(vobj(cuvar,1099),$C(124),8)="") D vreqerr("CTOF1098") Q 
	I ($D(vx("CTOF1099"))#2),($P(vobj(cuvar,1099),$C(124),9)="") D vreqerr("CTOF1099") Q 
	 S:'$D(vobj(cuvar,"CURRENV")) vobj(cuvar,"CURRENV")=$S(vobj(cuvar,-2):$G(^CUVAR("CURRENV")),1:"")
	I ($D(vx("CURRENV"))#2),($P(vobj(cuvar,"CURRENV"),$C(124),1)="") D vreqerr("CURRENV") Q 
	 S:'$D(vobj(cuvar,"LN")) vobj(cuvar,"LN")=$S(vobj(cuvar,-2):$G(^CUVAR("LN")),1:"")
	I ($D(vx("DARCDFLG"))#2),($P(vobj(cuvar,"LN"),$C(124),31)="") D vreqerr("DARCDFLG") Q 
	 S:'$D(vobj(cuvar,"EFTPAY")) vobj(cuvar,"EFTPAY")=$S(vobj(cuvar,-2):$G(^CUVAR("EFTPAY")),1:"")
	I ($D(vx("DEBAUT"))#2),($P(vobj(cuvar,"EFTPAY"),$C(124),16)="") D vreqerr("DEBAUT") Q 
	 S:'$D(vobj(cuvar,"%IO")) vobj(cuvar,"%IO")=$S(vobj(cuvar,-2):$G(^CUVAR("%IO")),1:"")
	I ($D(vx("DEVPTR"))#2),($P(vobj(cuvar,"%IO"),$C(124),2)="") D vreqerr("DEVPTR") Q 
	 S:'$D(vobj(cuvar,"EUR")) vobj(cuvar,"EUR")=$S(vobj(cuvar,-2):$G(^CUVAR("EUR")),1:"")
	I ($D(vx("DFTTHRC"))#2),($P(vobj(cuvar,"EUR"),$C(124),6)="") D vreqerr("DFTTHRC") Q 
	I ($D(vx("DFTTHRR"))#2),($P(vobj(cuvar,"EUR"),$C(124),7)="") D vreqerr("DFTTHRR") Q 
	I ($D(vx("DUPTIN"))#2),($P(vobj(cuvar,"CIF"),$C(124),23)="") D vreqerr("DUPTIN") Q 
	 S:'$D(vobj(cuvar,"EFD")) vobj(cuvar,"EFD")=$S(vobj(cuvar,-2):$G(^CUVAR("EFD")),1:"")
	I ($D(vx("EFD"))#2),($P(vobj(cuvar,"EFD"),$C(124),1)="") D vreqerr("EFD") Q 
	I ($D(vx("EFDFTFLG"))#2),($P(vobj(cuvar,"EFD"),$C(124),2)="") D vreqerr("EFDFTFLG") Q 
	I ($D(vx("EFTMEMO"))#2),($P(vobj(cuvar,"EFTPAY"),$C(124),19)="") D vreqerr("EFTMEMO") Q 
	I ($D(vx("EFTREFNO"))#2),($P(vobj(cuvar,"EFTPAY"),$C(124),15)="") D vreqerr("EFTREFNO") Q 
	I ($D(vx("EFTRICO"))#2),($P(vobj(cuvar,"EFTPAY"),$C(124),11)="") D vreqerr("EFTRICO") Q 
	I ($D(vx("EMU"))#2),($P(vobj(cuvar,"EUR"),$C(124),1)="") D vreqerr("EMU") Q 
	 S:'$D(vobj(cuvar,"%ET")) vobj(cuvar,"%ET")=$S(vobj(cuvar,-2):$G(^CUVAR("%ET")),1:"")
	I ($D(vx("ERRMDFT"))#2),($P(vobj(cuvar,"%ET"),$C(124),2)="") D vreqerr("ERRMDFT") Q 
	I ($D(vx("EURINTEG"))#2),($P(vobj(cuvar,"EUR"),$C(124),18)="") D vreqerr("EURINTEG") Q 
	 S:'$D(vobj(cuvar,"SWIFT")) vobj(cuvar,"SWIFT")=$S(vobj(cuvar,-2):$G(^CUVAR("SWIFT")),1:"")
	I ($D(vx("EXTREM"))#2),($P(vobj(cuvar,"SWIFT"),$C(124),5)="") D vreqerr("EXTREM") Q 
	I ($D(vx("EXTVAL"))#2),($P(vobj(cuvar,"CIF"),$C(124),25)="") D vreqerr("EXTVAL") Q 
	 S:'$D(vobj(cuvar,"%BATCH")) vobj(cuvar,"%BATCH")=$S(vobj(cuvar,-2):$G(^CUVAR("%BATCH")),1:"")
	I ($D(vx("FAILWAIT"))#2),($P(vobj(cuvar,"%BATCH"),$C(124),2)="") D vreqerr("FAILWAIT") Q 
	 S:'$D(vobj(cuvar,"FCVMEMO")) vobj(cuvar,"FCVMEMO")=$S(vobj(cuvar,-2):$G(^CUVAR("FCVMEMO")),1:"")
	I ($D(vx("FCVMEMO"))#2),($P(vobj(cuvar,"FCVMEMO"),$C(124),1)="") D vreqerr("FCVMEMO") Q 
	 S:'$D(vobj(cuvar,"FEPXALL")) vobj(cuvar,"FEPXALL")=$S(vobj(cuvar,-2):$G(^CUVAR("FEPXALL")),1:"")
	I ($D(vx("FEPXALL"))#2),($P(vobj(cuvar,"FEPXALL"),$C(124),1)="") D vreqerr("FEPXALL") Q 
	 S:'$D(vobj(cuvar,"DAYEND")) vobj(cuvar,"DAYEND")=$S(vobj(cuvar,-2):$G(^CUVAR("DAYEND")),1:"")
	I ($D(vx("FINYE"))#2),($P(vobj(cuvar,"DAYEND"),$C(124),8)="") D vreqerr("FINYE") Q 
	 S:'$D(vobj(cuvar,"DBS")) vobj(cuvar,"DBS")=$S(vobj(cuvar,-2):$G(^CUVAR("DBS")),1:"")
	I ($D(vx("FLDOVF"))#2),($P(vobj(cuvar,"DBS"),$C(124),1)="") D vreqerr("FLDOVF") Q 
	I ($D(vx("FNCRATE"))#2),($P(vobj(cuvar,"EUR"),$C(124),2)="") D vreqerr("FNCRATE") Q 
	I ($D(vx("FUTBLD"))#2),($P(vobj(cuvar,"EFTPAY"),$C(124),17)="") D vreqerr("FUTBLD") Q 
	I ($D(vx("FX"))#2),($P(vobj(cuvar,"%CRCD"),$C(124),24)="") D vreqerr("FX") Q 
	 S:'$D(vobj(cuvar,"GLEFD")) vobj(cuvar,"GLEFD")=$S(vobj(cuvar,-2):$G(^CUVAR("GLEFD")),1:"")
	I ($D(vx("GLEFDBCH"))#2),($P(vobj(cuvar,"GLEFD"),$C(124),1)="") D vreqerr("GLEFDBCH") Q 
	 S:'$D(vobj(cuvar,"INCK")) vobj(cuvar,"INCK")=$S(vobj(cuvar,-2):$G(^CUVAR("INCK")),1:"")
	I ($D(vx("ICCFF"))#2),($P(vobj(cuvar,"INCK"),$C(124),23)="") D vreqerr("ICCFF") Q 
	I ($D(vx("ICCNF"))#2),($P(vobj(cuvar,"INCK"),$C(124),24)="") D vreqerr("ICCNF") Q 
	I ($D(vx("ICDFF"))#2),($P(vobj(cuvar,"INCK"),$C(124),5)="") D vreqerr("ICDFF") Q 
	I ($D(vx("ICDNF"))#2),($P(vobj(cuvar,"INCK"),$C(124),6)="") D vreqerr("ICDNF") Q 
	I ($D(vx("ICDRF"))#2),($P(vobj(cuvar,"INCK"),$C(124),7)="") D vreqerr("ICDRF") Q 
	I ($D(vx("ICDTF"))#2),($P(vobj(cuvar,"INCK"),$C(124),4)="") D vreqerr("ICDTF") Q 
	I ($D(vx("ICLFF"))#2),($P(vobj(cuvar,"INCK"),$C(124),14)="") D vreqerr("ICLFF") Q 
	I ($D(vx("ICLNF"))#2),($P(vobj(cuvar,"INCK"),$C(124),15)="") D vreqerr("ICLNF") Q 
	I ($D(vx("ICLRF"))#2),($P(vobj(cuvar,"INCK"),$C(124),16)="") D vreqerr("ICLRF") Q 
	I ($D(vx("ICLTF"))#2),($P(vobj(cuvar,"INCK"),$C(124),13)="") D vreqerr("ICLTF") Q 
	 S:'$D(vobj(cuvar,"IMAGE")) vobj(cuvar,"IMAGE")=$S(vobj(cuvar,-2):$G(^CUVAR("IMAGE")),1:"")
	I ($D(vx("IMAGE"))#2),($P(vobj(cuvar,"IMAGE"),$C(124),1)="") D vreqerr("IMAGE") Q 
	 S:'$D(vobj(cuvar,"IPD")) vobj(cuvar,"IPD")=$S(vobj(cuvar,-2):$G(^CUVAR("IPD")),1:"")
	I ($D(vx("IPD"))#2),($P(vobj(cuvar,"IPD"),$C(124),1)="") D vreqerr("IPD") Q 
	 S:'$D(vobj(cuvar,"DRMT")) vobj(cuvar,"DRMT")=$S(vobj(cuvar,-2):$G(^CUVAR("DRMT")),1:"")
	I ($D(vx("LCCADR"))#2),($P(vobj(cuvar,"DRMT"),$C(124),4)="") D vreqerr("LCCADR") Q 
	I ($D(vx("LCCPU"))#2),($P(vobj(cuvar,"DRMT"),$C(124),6)="") D vreqerr("LCCPU") Q 
	I ($D(vx("LCCTIT"))#2),($P(vobj(cuvar,"DRMT"),$C(124),5)="") D vreqerr("LCCTIT") Q 
	 S:'$D(vobj(cuvar,"LETTER")) vobj(cuvar,"LETTER")=$S(vobj(cuvar,-2):$G(^CUVAR("LETTER")),1:"")
	I ($D(vx("LETFIX"))#2),($P(vobj(cuvar,"LETTER"),$C(124),1)="") D vreqerr("LETFIX") Q 
	I ($D(vx("LIMPRO"))#2),($P(vobj(cuvar,"CIF"),$C(124),16)="") D vreqerr("LIMPRO") Q 
	I ($D(vx("LNRENDEL"))#2),($P(vobj(cuvar,"LN"),$C(124),32)="") D vreqerr("LNRENDEL") Q 
	I ($D(vx("MRPT"))#2),($P(vobj(cuvar,"LN"),$C(124),33)="") D vreqerr("MRPT") Q 
	 S:'$D(vobj(cuvar,"MULTIITSID")) vobj(cuvar,"MULTIITSID")=$S(vobj(cuvar,-2):$G(^CUVAR("MULTIITSID")),1:"")
	I ($D(vx("MULTIITSID"))#2),($P(vobj(cuvar,"MULTIITSID"),$C(124),1)="") D vreqerr("MULTIITSID") Q 
	 S:'$D(vobj(cuvar,"MXTRLM")) vobj(cuvar,"MXTRLM")=$S(vobj(cuvar,-2):$G(^CUVAR("MXTRLM")),1:"")
	I ($D(vx("MXTRLM"))#2),($P(vobj(cuvar,"MXTRLM"),$C(124),1)="") D vreqerr("MXTRLM") Q 
	 S:'$D(vobj(cuvar,"NOREGD")) vobj(cuvar,"NOREGD")=$S(vobj(cuvar,-2):$G(^CUVAR("NOREGD")),1:"")
	I ($D(vx("NOREGD"))#2),($P(vobj(cuvar,"NOREGD"),$C(124),1)="") D vreqerr("NOREGD") Q 
	 S:'$D(vobj(cuvar,"OPTIMIZE")) vobj(cuvar,"OPTIMIZE")=$S(vobj(cuvar,-2):$G(^CUVAR("OPTIMIZE")),1:"")
	I ($D(vx("NOSEGMENTS"))#2),($P(vobj(cuvar,"OPTIMIZE"),$C(124),1)="") D vreqerr("NOSEGMENTS") Q 
	I ($D(vx("NOTP"))#2),($P(vobj(cuvar,"DBS"),$C(124),7)="") D vreqerr("NOTP") Q 
	 S:'$D(vobj(cuvar,"REGCC")) vobj(cuvar,"REGCC")=$S(vobj(cuvar,-2):$G(^CUVAR("REGCC")),1:"")
	I ($D(vx("OBDE"))#2),($P(vobj(cuvar,"REGCC"),$C(124),11)="") D vreqerr("OBDE") Q 
	 S:'$D(vobj(cuvar,"ODP")) vobj(cuvar,"ODP")=$S(vobj(cuvar,-2):$G(^CUVAR("ODP")),1:"")
	I ($D(vx("ODP"))#2),($P(vobj(cuvar,"ODP"),$C(124),1)="") D vreqerr("ODP") Q 
	 S:'$D(vobj(cuvar,"ODPE")) vobj(cuvar,"ODPE")=$S(vobj(cuvar,-2):$G(^CUVAR("ODPE")),1:"")
	I ($D(vx("ODPE"))#2),($P(vobj(cuvar,"ODPE"),$C(124),1)="") D vreqerr("ODPE") Q 
	I ($D(vx("ORCIFN"))#2),($P(vobj(cuvar,"CIF"),$C(124),3)="") D vreqerr("ORCIFN") Q 
	I ($D(vx("OTC"))#2),($P(vobj(cuvar,"%CRCD"),$C(124),23)="") D vreqerr("OTC") Q 
	 S:'$D(vobj(cuvar,"PUBLISH")) vobj(cuvar,"PUBLISH")=$S(vobj(cuvar,-2):$G(^CUVAR("PUBLISH")),1:"")
	I ($D(vx("PUBLISH"))#2),($P(vobj(cuvar,"PUBLISH"),$C(124),1)="") D vreqerr("PUBLISH") Q 
	I ($D(vx("REGCCOPT"))#2),($P(vobj(cuvar,"REGCC"),$C(124),7)="") D vreqerr("REGCCOPT") Q 
	 S:'$D(vobj(cuvar,"REGFLG")) vobj(cuvar,"REGFLG")=$S(vobj(cuvar,-2):$G(^CUVAR("REGFLG")),1:"")
	I ($D(vx("REGFLG"))#2),($P(vobj(cuvar,"REGFLG"),$C(124),1)="") D vreqerr("REGFLG") Q 
	 S:'$D(vobj(cuvar,"DEAL")) vobj(cuvar,"DEAL")=$S(vobj(cuvar,-2):$G(^CUVAR("DEAL")),1:"")
	I ($D(vx("REKEY"))#2),($P(vobj(cuvar,"DEAL"),$C(124),1)="") D vreqerr("REKEY") Q 
	 S:'$D(vobj(cuvar,"RESPROC")) vobj(cuvar,"RESPROC")=$S(vobj(cuvar,-2):$G(^CUVAR("RESPROC")),1:"")
	I ($D(vx("RESPROC"))#2),($P(vobj(cuvar,"RESPROC"),$C(124),1)="") D vreqerr("RESPROC") Q 
	 S:'$D(vobj(cuvar,"RESTRICT")) vobj(cuvar,"RESTRICT")=$S(vobj(cuvar,-2):$G(^CUVAR("RESTRICT")),1:"")
	I ($D(vx("RESTRICT"))#2),($P(vobj(cuvar,"RESTRICT"),$C(124),1)="") D vreqerr("RESTRICT") Q 
	I ($D(vx("RPANET"))#2),($P(vobj(cuvar,"DEP"),$C(124),11)="") D vreqerr("RPANET") Q 
	 S:'$D(vobj(cuvar,"SCAUREL")) vobj(cuvar,"SCAUREL")=$S(vobj(cuvar,-2):$G(^CUVAR("SCAUREL")),1:"")
	I ($D(vx("SCAUREL"))#2),($P(vobj(cuvar,"SCAUREL"),$C(124),1)="") D vreqerr("SCAUREL") Q 
	 S:'$D(vobj(cuvar,"SCHRC")) vobj(cuvar,"SCHRC")=$S(vobj(cuvar,-2):$G(^CUVAR("SCHRC")),1:"")
	I ($D(vx("SCHRCC"))#2),($P(vobj(cuvar,"SCHRC"),$C(124),1)="") D vreqerr("SCHRCC") Q 
	I ($D(vx("SCHRCE"))#2),($P(vobj(cuvar,"SCHRC"),$C(124),7)="") D vreqerr("SCHRCE") Q 
	I ($D(vx("SCHRCJ"))#2),($P(vobj(cuvar,"SCHRC"),$C(124),2)="") D vreqerr("SCHRCJ") Q 
	I ($D(vx("SCHRCK"))#2),($P(vobj(cuvar,"SCHRC"),$C(124),3)="") D vreqerr("SCHRCK") Q 
	I ($D(vx("SCHRCL"))#2),($P(vobj(cuvar,"SCHRC"),$C(124),4)="") D vreqerr("SCHRCL") Q 
	I ($D(vx("SCHRCN"))#2),($P(vobj(cuvar,"SCHRC"),$C(124),5)="") D vreqerr("SCHRCN") Q 
	I ($D(vx("SCHRI"))#2),($P(vobj(cuvar,"SCHRC"),$C(124),6)="") D vreqerr("SCHRI") Q 
	I ($D(vx("SCOVR"))#2),($P(vobj(cuvar,"EUR"),$C(124),15)="") D vreqerr("SCOVR") Q 
	I ($D(vx("SFEEOPT"))#2),($P(vobj(cuvar,"ODP"),$C(124),2)="") D vreqerr("SFEEOPT") Q 
	 S:'$D(vobj(cuvar,"SPLITDAY")) vobj(cuvar,"SPLITDAY")=$S(vobj(cuvar,-2):$G(^CUVAR("SPLITDAY")),1:"")
	I ($D(vx("SPLITDAY"))#2),($P(vobj(cuvar,"SPLITDAY"),$C(124),1)="") D vreqerr("SPLITDAY") Q 
	I ($D(vx("STMLCC"))#2),($P(vobj(cuvar,"DRMT"),$C(124),3)="") D vreqerr("STMLCC") Q 
	 S:'$D(vobj(cuvar,"STMTSRT")) vobj(cuvar,"STMTSRT")=$S(vobj(cuvar,-2):$G(^CUVAR("STMTSRT")),1:"")
	I ($D(vx("STMTCDSKIP"))#2),($P(vobj(cuvar,"STMTSRT"),$C(124),3)="") D vreqerr("STMTCDSKIP") Q 
	I ($D(vx("STMTCUMUL"))#2),($P(vobj(cuvar,"STMTSRT"),$C(124),6)="") D vreqerr("STMTCUMUL") Q 
	I ($D(vx("STMTINTRTC"))#2),($P(vobj(cuvar,"STMTSRT"),$C(124),4)="") D vreqerr("STMTINTRTC") Q 
	I ($D(vx("STMTLNSKIP"))#2),($P(vobj(cuvar,"STMTSRT"),$C(124),5)="") D vreqerr("STMTLNSKIP") Q 
	I ($D(vx("TAXYE"))#2),($P(vobj(cuvar,"DAYEND"),$C(124),9)="") D vreqerr("TAXYE") Q 
	I ($D(vx("TFS"))#2),($P(vobj(cuvar,"%CRCD"),$C(124),25)="") D vreqerr("TFS") Q 
	I ($D(vx("TINCO"))#2),($P(vobj(cuvar,"CIF"),$C(124),24)="") D vreqerr("TINCO") Q 
	 S:'$D(vobj(cuvar,"CRT")) vobj(cuvar,"CRT")=$S(vobj(cuvar,-2):$G(^CUVAR("CRT")),1:"")
	I ($D(vx("TREF"))#2),($P(vobj(cuvar,"CRT"),$C(124),7)="") D vreqerr("TREF") Q 
	 S:'$D(vobj(cuvar,"UACNL1F")) vobj(cuvar,"UACNL1F")=$S(vobj(cuvar,-2):$G(^CUVAR("UACNL1F")),1:"")
	I ($D(vx("UACNL1F"))#2),($P(vobj(cuvar,"UACNL1F"),$C(124),1)="") D vreqerr("UACNL1F") Q 
	 S:'$D(vobj(cuvar,"USRESTAT")) vobj(cuvar,"USRESTAT")=$S(vobj(cuvar,-2):$G(^CUVAR("USRESTAT")),1:"")
	I ($D(vx("USRESTAT"))#2),($P(vobj(cuvar,"USRESTAT"),$C(124),1)="") D vreqerr("USRESTAT") Q 
	Q 
	;
vreqerr(di)	; Required error
	;
	 S ER=0
	D SETERR^DBSEXECU("CUVAR","MSG",1767,"CUVAR."_di)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vddver	; Validate data dictionary attributes
	;
	N vRM N X
	;
	I (%O=2) D vload
	;
	I ($D(vobj(cuvar,2))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,2)) vobj(cuvar,2)=$S(vobj(cuvar,-2):$G(^CUVAR(2)),1:"")
	.	S X=$P(vobj(cuvar,2),$C(124),1) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("TJD",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,1099))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,1099)) vobj(cuvar,1099)=$S(vobj(cuvar,-2):$G(^CUVAR(1099)),1:"")
	.	S X=$P(vobj(cuvar,1099),$C(124),14) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("CAC",vRM) Q 
	.	I $L($P(vobj(cuvar,1099),$C(124),17))>50 S vRM=$$^MSG(1076,50) D vdderr("CEMAIL",vRM) Q 
	.	I $L($P(vobj(cuvar,1099),$C(124),13))>20 S vRM=$$^MSG(1076,20) D vdderr("CONTACT",vRM) Q 
	.	S X=$P(vobj(cuvar,1099),$C(124),16) I '(X=""),X'?1.8N,X'?1"-"1.7N S vRM=$$^MSG(742,"N") D vdderr("CORPID",vRM) Q 
	.	S X=$P(vobj(cuvar,1099),$C(124),15) I '(X=""),X'?1.7N,X'?1"-"1.6N S vRM=$$^MSG(742,"N") D vdderr("CTELE",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,1099),$C(124),8)) S vRM=$$^MSG(742,"L") D vdderr("CTOF1098",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,1099),$C(124),9)) S vRM=$$^MSG(742,"L") D vdderr("CTOF1099",vRM) Q 
	.	I $L($P(vobj(cuvar,1099),$C(124),4))>30 S vRM=$$^MSG(1076,30) D vdderr("IAD1",vRM) Q 
	.	I $L($P(vobj(cuvar,1099),$C(124),5))>30 S vRM=$$^MSG(1076,30) D vdderr("IAD2",vRM) Q 
	.	I $L($P(vobj(cuvar,1099),$C(124),6))>30 S vRM=$$^MSG(1076,30) D vdderr("IAD3",vRM) Q 
	.	I $L($P(vobj(cuvar,1099),$C(124),1))>40 S vRM=$$^MSG(1076,40) D vdderr("ICITY",vRM) Q 
	.	S X=$P(vobj(cuvar,1099),$C(124),12) I '(X=""),'($D(^STBL("CNTRY",X))#2) S vRM=$$^MSG(1485,X) D vdderr("ICNTRY",vRM) Q 
	.	I $L($P(vobj(cuvar,1099),$C(124),7))>30 S vRM=$$^MSG(1076,30) D vdderr("INAME",vRM) Q 
	.	I $L($P(vobj(cuvar,1099),$C(124),11))>30 S vRM=$$^MSG(1076,30) D vdderr("INAME2",vRM) Q 
	.	S X=$P(vobj(cuvar,1099),$C(124),2) I '(X=""),'($D(^STBL("CNTRY","US",X))#2) S vRM=$$^MSG(1485,X) D vdderr("ISTATE",vRM) Q 
	.	I $L($P(vobj(cuvar,1099),$C(124),3))>10 S vRM=$$^MSG(1076,10) D vdderr("IZIP",vRM) Q 
	.	S X=$P(vobj(cuvar,1099),$C(124),10) I '(X=""),X'?1N S vRM=$$^MSG(742,"N") D vdderr("SBI",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"%ATM"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"%ATM")) vobj(cuvar,"%ATM")=$S(vobj(cuvar,-2):$G(^CUVAR("%ATM")),1:"")
	.	I $L($P(vobj(cuvar,"%ATM"),$C(124),1))>12 S vRM=$$^MSG(1076,12) D vdderr("%ATM",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"%BATCH"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"%BATCH")) vobj(cuvar,"%BATCH")=$S(vobj(cuvar,-2):$G(^CUVAR("%BATCH")),1:"")
	.	S X=$P(vobj(cuvar,"%BATCH"),$C(124),1) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("BATRESTART",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"%BATCH"),$C(124),2)) S vRM=$$^MSG(742,"L") D vdderr("FAILWAIT",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"%BWPCT"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"%BWPCT")) vobj(cuvar,"%BWPCT")=$S(vobj(cuvar,-2):$G(^CUVAR("%BWPCT")),1:"")
	.	S X=$P(vobj(cuvar,"%BWPCT"),$C(124),1) I '(X="") S vRM=$$VAL^DBSVER("N",9,0,,,,,5) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.%BWPCT"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	Q 
	;
	I ($D(vobj(cuvar,"%CC"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"%CC")) vobj(cuvar,"%CC")=$S(vobj(cuvar,-2):$G(^CUVAR("%CC")),1:"")
	.	S X=$P(vobj(cuvar,"%CC"),$C(124),1) I '(X="") S vRM=$$VAL^DBSVER("$",12,0,,,,,2) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.%CC"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	Q 
	;
	I ($D(vobj(cuvar,"%CRCD"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"%CRCD")) vobj(cuvar,"%CRCD")=$S(vobj(cuvar,-2):$G(^CUVAR("%CRCD")),1:"")
	.	I $L($P(vobj(cuvar,"%CRCD"),$C(124),1))>3 S vRM=$$^MSG(1076,3) D vdderr("%CRCD",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"%CRCD"),$C(124),13)) S vRM=$$^MSG(742,"L") D vdderr("BAMTMOD",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"%CRCD"),$C(124),11)) S vRM=$$^MSG(742,"L") D vdderr("BSEMOD",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"%CRCD"),$C(124),12)) S vRM=$$^MSG(742,"L") D vdderr("CCMOD",vRM) Q 
	.	S X=$P(vobj(cuvar,"%CRCD"),$C(124),3) I '(X=""),'($D(^TRN(X))>9) S vRM=$$^MSG(1485,X) D vdderr("CECR",vRM) Q 
	.	S X=$P(vobj(cuvar,"%CRCD"),$C(124),2) I '(X=""),'($D(^TRN(X))>9) S vRM=$$^MSG(1485,X) D vdderr("CEDR",vRM) Q 
	.	I $L($P(vobj(cuvar,"%CRCD"),$C(124),6))>9 S vRM=$$^MSG(1076,9) D vdderr("CERTN",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"%CRCD"),$C(124),24)) S vRM=$$^MSG(742,"L") D vdderr("FX",vRM) Q 
	.	S X=$P(vobj(cuvar,"%CRCD"),$C(124),18) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("FXLOSS",vRM) Q 
	.	S X=$P(vobj(cuvar,"%CRCD"),$C(124),16) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("FXPOSL",vRM) Q 
	.	S X=$P(vobj(cuvar,"%CRCD"),$C(124),15) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("FXPOSPL",vRM) Q 
	.	S X=$P(vobj(cuvar,"%CRCD"),$C(124),14) I '(X=""),'($D(^STBL("FXPOSRT",X))#2) S vRM=$$^MSG(1485,X) D vdderr("FXPOSRT",vRM) Q 
	.	S X=$P(vobj(cuvar,"%CRCD"),$C(124),17) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("FXPROFIT",vRM) Q 
	.	S X=$P(vobj(cuvar,"%CRCD"),$C(124),19) I '(X=""),'($D(^STBL("FXPOSRT",X))#2) S vRM=$$^MSG(1485,X) D vdderr("ITSPOSPL",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"%CRCD"),$C(124),23)) S vRM=$$^MSG(742,"L") D vdderr("OTC",vRM) Q 
	.	S X=$P(vobj(cuvar,"%CRCD"),$C(124),5) I '(X=""),'($D(^TRN(X))>9) S vRM=$$^MSG(1485,X) D vdderr("TCECR",vRM) Q 
	.	S X=$P(vobj(cuvar,"%CRCD"),$C(124),4) I '(X=""),'($D(^TRN(X))>9) S vRM=$$^MSG(1485,X) D vdderr("TCEDR",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"%CRCD"),$C(124),25)) S vRM=$$^MSG(742,"L") D vdderr("TFS",vRM) Q 
	.	S X=$P(vobj(cuvar,"%CRCD"),$C(124),22) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("TFSL",vRM) Q 
	.	S X=$P(vobj(cuvar,"%CRCD"),$C(124),21) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("TFSP",vRM) Q 
	.	S X=$P(vobj(cuvar,"%CRCD"),$C(124),20) I '(X=""),'($D(^STBL("FXPOSRT",X))#2) S vRM=$$^MSG(1485,X) D vdderr("TFSPOSPL",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"%ET"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"%ET")) vobj(cuvar,"%ET")=$S(vobj(cuvar,-2):$G(^CUVAR("%ET")),1:"")
	.	I $L($P(vobj(cuvar,"%ET"),$C(124),1))>17 S vRM=$$^MSG(1076,17) D vdderr("%ET",vRM) Q 
	.	I $L($P(vobj(cuvar,"%ET"),$C(124),3))>40 S vRM=$$^MSG(1076,40) D vdderr("ERRMAIL",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"%ET"),$C(124),2)) S vRM=$$^MSG(742,"L") D vdderr("ERRMDFT",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"%HELP"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"%HELP")) vobj(cuvar,"%HELP")=$S(vobj(cuvar,-2):$G(^CUVAR("%HELP")),1:"")
	.	S X=$P(vobj(cuvar,"%HELP"),$C(124),1) I '(X=""),X'?1N S vRM=$$^MSG(742,"N") D vdderr("%HELP",vRM) Q 
	.	S X=$P(vobj(cuvar,"%HELP"),$C(124),2) I '(X=""),X'?1N S vRM=$$^MSG(742,"N") D vdderr("%HELPCNT",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"%IO"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"%IO")) vobj(cuvar,"%IO")=$S(vobj(cuvar,-2):$G(^CUVAR("%IO")),1:"")
	.	I $L($P(vobj(cuvar,"%IO"),$C(124),1))>9 S vRM=$$^MSG(1076,9) D vdderr("DEVIO",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"%IO"),$C(124),2)) S vRM=$$^MSG(742,"L") D vdderr("DEVPTR",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"%KEYS"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"%KEYS")) vobj(cuvar,"%KEYS")=$S(vobj(cuvar,-2):$G(^CUVAR("%KEYS")),1:"")
	.	I '("01"[$P(vobj(cuvar,"%KEYS"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("%KEYS",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"%LIBS"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"%LIBS")) vobj(cuvar,"%LIBS")=$S(vobj(cuvar,-2):$G(^CUVAR("%LIBS")),1:"")
	.	I $L($P(vobj(cuvar,"%LIBS"),$C(124),1))>8 S vRM=$$^MSG(1076,8) D vdderr("%LIBS",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"%MCP"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"%MCP")) vobj(cuvar,"%MCP")=$S(vobj(cuvar,-2):$G(^CUVAR("%MCP")),1:"")
	.	I '("01"[$P(vobj(cuvar,"%MCP"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("%MCP",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"%TBLS"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"%TBLS")) vobj(cuvar,"%TBLS")=$S(vobj(cuvar,-2):$G(^CUVAR("%TBLS")),1:"")
	.	I $L($P(vobj(cuvar,"%TBLS"),$C(124),1))>500 S vRM=$$^MSG(1076,500) D vdderr("TBLS",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"%TO"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"%TO")) vobj(cuvar,"%TO")=$S(vobj(cuvar,-2):$G(^CUVAR("%TO")),1:"")
	.	S X=$P(vobj(cuvar,"%TO"),$C(124),1) I '(X=""),X'?1.5N,X'?1"-"1.4N S vRM=$$^MSG(742,"N") D vdderr("%TO",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"%TOHALT"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"%TOHALT")) vobj(cuvar,"%TOHALT")=$S(vobj(cuvar,-2):$G(^CUVAR("%TOHALT")),1:"")
	.	S X=$P(vobj(cuvar,"%TOHALT"),$C(124),1) I '(X=""),X'?1.5N,X'?1"-"1.4N S vRM=$$^MSG(742,"N") D vdderr("%TOHALT",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"%VN"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"%VN")) vobj(cuvar,"%VN")=$S(vobj(cuvar,-2):$G(^CUVAR("%VN")),1:"")
	.	S X=$P(vobj(cuvar,"%VN"),$C(124),1) I '(X="") S vRM=$$VAL^DBSVER("N",3,0,,,,,1) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.%VN"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	Q 
	;
	I ($D(vobj(cuvar,"ACHORIG"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"ACHORIG")) vobj(cuvar,"ACHORIG")=$S(vobj(cuvar,-2):$G(^CUVAR("ACHORIG")),1:"")
	.	S X=$P(vobj(cuvar,"ACHORIG"),$C(124),3) I '(X=""),'($D(^UTBL("ACHRT",X))#2) S vRM=$$^MSG(1485,X) D vdderr("BORIG",vRM) Q 
	.	S X=$P(vobj(cuvar,"ACHORIG"),$C(124),2) I '(X=""),'($D(^UTBL("ACHRT",X))#2) S vRM=$$^MSG(1485,X) D vdderr("FDEST",vRM) Q 
	.	S X=$P(vobj(cuvar,"ACHORIG"),$C(124),1) I '(X=""),'($D(^UTBL("ACHRT",X))#2) S vRM=$$^MSG(1485,X) D vdderr("FORIG",vRM) Q 
	.	S X=$P(vobj(cuvar,"ACHORIG"),$C(124),4) I '(X=""),X'?1N S vRM=$$^MSG(742,"N") D vdderr("LEAD",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"ACNMRPC"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"ACNMRPC")) vobj(cuvar,"ACNMRPC")=$S(vobj(cuvar,-2):$G(^CUVAR("ACNMRPC")),1:"")
	.	I $L($P(vobj(cuvar,"ACNMRPC"),$C(124),1))>20 S vRM=$$^MSG(1076,20) D vdderr("ACNMRPC",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"ADDR"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"ADDR")) vobj(cuvar,"ADDR")=$S(vobj(cuvar,-2):$G(^CUVAR("ADDR")),1:"")
	.	I $L($P(vobj(cuvar,"ADDR"),$C(124),4))>40 S vRM=$$^MSG(1076,40) D vdderr("CAD1",vRM) Q 
	.	I $L($P(vobj(cuvar,"ADDR"),$C(124),5))>40 S vRM=$$^MSG(1076,40) D vdderr("CAD2",vRM) Q 
	.	I $L($P(vobj(cuvar,"ADDR"),$C(124),6))>40 S vRM=$$^MSG(1076,40) D vdderr("CAD3",vRM) Q 
	.	I $L($P(vobj(cuvar,"ADDR"),$C(124),1))>40 S vRM=$$^MSG(1076,40) D vdderr("CCITY",vRM) Q 
	.	S X=$P(vobj(cuvar,"ADDR"),$C(124),8) I '(X=""),'($D(^STBL("CNTRY",X))#2) S vRM=$$^MSG(1485,X) D vdderr("CCNTRY",vRM) Q 
	.	I $L($P(vobj(cuvar,"ADDR"),$C(124),7))>40 S vRM=$$^MSG(1076,40) D vdderr("CNAME",vRM) Q 
	.	I $L($P(vobj(cuvar,"ADDR"),$C(124),2))>2 S vRM=$$^MSG(1076,2) D vdderr("CSTATE",vRM) Q 
	.	I $L($P(vobj(cuvar,"ADDR"),$C(124),3))>10 S vRM=$$^MSG(1076,10) D vdderr("CZIP",vRM) Q 
	.	I $L($P(vobj(cuvar,"ADDR"),$C(124),9))>15 S vRM=$$^MSG(1076,15) D vdderr("TELEPHONE",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"ADSCR"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"ADSCR")) vobj(cuvar,"ADSCR")=$S(vobj(cuvar,-2):$G(^CUVAR("ADSCR")),1:"")
	.	I $L($P(vobj(cuvar,"ADSCR"),$C(124),1))>12 S vRM=$$^MSG(1076,12) D vdderr("ADRSCR",vRM) Q 
	.	I $L($P(vobj(cuvar,"ADSCR"),$C(124),3))>12 S vRM=$$^MSG(1076,12) D vdderr("ADRSCRI",vRM) Q 
	.	I $L($P(vobj(cuvar,"ADSCR"),$C(124),2))>12 S vRM=$$^MSG(1076,12) D vdderr("ADRSCRM",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"AGEMS"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"AGEMS")) vobj(cuvar,"AGEMS")=$S(vobj(cuvar,-2):$G(^CUVAR("AGEMS")),1:"")
	.	S X=$P(vobj(cuvar,"AGEMS"),$C(124),34) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("AGE1",vRM) Q 
	.	S X=$P(vobj(cuvar,"AGEMS"),$C(124),35) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("AGE2",vRM) Q 
	.	S X=$P(vobj(cuvar,"AGEMS"),$C(124),36) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("AGE3",vRM) Q 
	.	S X=$P(vobj(cuvar,"AGEMS"),$C(124),37) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("AGE4",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"ALCOUNT"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"ALCOUNT")) vobj(cuvar,"ALCOUNT")=$S(vobj(cuvar,-2):$G(^CUVAR("ALCOUNT")),1:"")
	.	S X=$P(vobj(cuvar,"ALCOUNT"),$C(124),1) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("ALCOUNT",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"ALP"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"ALP")) vobj(cuvar,"ALP")=$S(vobj(cuvar,-2):$G(^CUVAR("ALP")),1:"")
	.	I '("01"[$P(vobj(cuvar,"ALP"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("ALPHI",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"ANAOFF"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"ANAOFF")) vobj(cuvar,"ANAOFF")=$S(vobj(cuvar,-2):$G(^CUVAR("ANAOFF")),1:"")
	.	S X=$P(vobj(cuvar,"ANAOFF"),$C(124),1) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("ANAOFF",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"AUTOAUTH"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"AUTOAUTH")) vobj(cuvar,"AUTOAUTH")=$S(vobj(cuvar,-2):$G(^CUVAR("AUTOAUTH")),1:"")
	.	S X=$P(vobj(cuvar,"AUTOAUTH"),$C(124),1) I '(X=""),'($D(^STBL("AUTOAUTH",X))#2) S vRM=$$^MSG(1485,X) D vdderr("AUTOAUTH",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"BANNER"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"BANNER")) vobj(cuvar,"BANNER")=$S(vobj(cuvar,-2):$G(^CUVAR("BANNER")),1:"")
	.	I '("01"[$P(vobj(cuvar,"BANNER"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("BANNER",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"BINDEF"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"BINDEF")) vobj(cuvar,"BINDEF")=$S(vobj(cuvar,-2):$G(^CUVAR("BINDEF")),1:"")
	.	I '("01"[$P(vobj(cuvar,"BINDEF"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("BINDEF",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"BOBR"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"BOBR")) vobj(cuvar,"BOBR")=$S(vobj(cuvar,-2):$G(^CUVAR("BOBR")),1:"")
	.	S X=$P(vobj(cuvar,"BOBR"),$C(124),1) I '(X=""),X'?1.6N,X'?1"-"1.5N S vRM=$$^MSG(742,"N") D vdderr("BOBR",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"BSA"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"BSA")) vobj(cuvar,"BSA")=$S(vobj(cuvar,-2):$G(^CUVAR("BSA")),1:"")
	.	S X=$P(vobj(cuvar,"BSA"),$C(124),1) I '(X=""),'($D(^STBL("BSA",X))#2) S vRM=$$^MSG(1485,X) D vdderr("BSA",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"BTTJOB"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"BTTJOB")) vobj(cuvar,"BTTJOB")=$S(vobj(cuvar,-2):$G(^CUVAR("BTTJOB")),1:"")
	.	S X=$P(vobj(cuvar,"BTTJOB"),$C(124),1) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("BTTJOB",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"BWAPGM"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"BWAPGM")) vobj(cuvar,"BWAPGM")=$S(vobj(cuvar,-2):$G(^CUVAR("BWAPGM")),1:"")
	.	I $L($P(vobj(cuvar,"BWAPGM"),$C(124),1))>17 S vRM=$$^MSG(1076,17) D vdderr("BWAPGM",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"BWO"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"BWO")) vobj(cuvar,"BWO")=$S(vobj(cuvar,-2):$G(^CUVAR("BWO")),1:"")
	.	S X=$P(vobj(cuvar,"BWO"),$C(124),1) I '(X=""),'($D(^STBL("BWO",X))#2) S vRM=$$^MSG(1485,X) D vdderr("BWO",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"CHK"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"CHK")) vobj(cuvar,"CHK")=$S(vobj(cuvar,-2):$G(^CUVAR("CHK")),1:"")
	.	I '("01"[$P(vobj(cuvar,"CHK"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("CHKIMG",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"CHKHLDRTN"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"CHKHLDRTN")) vobj(cuvar,"CHKHLDRTN")=$S(vobj(cuvar,-2):$G(^CUVAR("CHKHLDRTN")),1:"")
	.	I $L($P(vobj(cuvar,"CHKHLDRTN"),$C(124),1))>9 S vRM=$$^MSG(1076,9) D vdderr("CHKHLDRTN",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"CHKPNT"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"CHKPNT")) vobj(cuvar,"CHKPNT")=$S(vobj(cuvar,-2):$G(^CUVAR("CHKPNT")),1:"")
	.	I $L($P(vobj(cuvar,"CHKPNT"),$C(124),1))>9 S vRM=$$^MSG(1076,9) D vdderr("CHKPNT",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"CIDBLK"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"CIDBLK")) vobj(cuvar,"CIDBLK")=$S(vobj(cuvar,-2):$G(^CUVAR("CIDBLK")),1:"")
	.	S X=$P(vobj(cuvar,"CIDBLK"),$C(124),1) I '(X=""),X'?1.12N,X'?1"-"1.11N S vRM=$$^MSG(742,"N") D vdderr("CIDBLK",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"CIDLOWLM"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"CIDLOWLM")) vobj(cuvar,"CIDLOWLM")=$S(vobj(cuvar,-2):$G(^CUVAR("CIDLOWLM")),1:"")
	.	S X=$P(vobj(cuvar,"CIDLOWLM"),$C(124),1) I '(X=""),X'?1.12N,X'?1"-"1.11N S vRM=$$^MSG(742,"N") D vdderr("CIDLOWLM",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"CIF"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"CIF")) vobj(cuvar,"CIF")=$S(vobj(cuvar,-2):$G(^CUVAR("CIF")),1:"")
	.	I '("01"[$P(vobj(cuvar,"CIF"),$C(124),13)) S vRM=$$^MSG(742,"L") D vdderr("CIFALLOC",vRM) Q 
	.	S X=$P(vobj(cuvar,"CIF"),$C(124),4) I '(X=""),X'?1.4N,X'?1"-"1.3N S vRM=$$^MSG(742,"N") D vdderr("CIFPRGD",vRM) Q 
	.	I $L($P(vobj(cuvar,"CIF"),$C(124),14))>2 S vRM=$$^MSG(1076,2) D vdderr("DEFDREL",vRM) Q 
	.	I $L($P(vobj(cuvar,"CIF"),$C(124),15))>2 S vRM=$$^MSG(1076,2) D vdderr("DEFLREL",vRM) Q 
	.	I $L($P(vobj(cuvar,"CIF"),$C(124),22))>6 S vRM=$$^MSG(1076,6) D vdderr("DISBRST",vRM) Q 
	.	I $L($P(vobj(cuvar,"CIF"),$C(124),21))>6 S vRM=$$^MSG(1076,6) D vdderr("DODRST",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"CIF"),$C(124),23)) S vRM=$$^MSG(742,"L") D vdderr("DUPTIN",vRM) Q 
	.	S X=$P(vobj(cuvar,"CIF"),$C(124),20) I '(X=""),'(",0,1,"[(","_X_",")) S vRM=$$^MSG(1485,X) D vdderr("EXPREP",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"CIF"),$C(124),25)) S vRM=$$^MSG(742,"L") D vdderr("EXTVAL",vRM) Q 
	.	S X=$P(vobj(cuvar,"CIF"),$C(124),26) I '(X=""),'($D(^STBL("HBT",X))#2) S vRM=$$^MSG(1485,X) D vdderr("HBTYPE",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"CIF"),$C(124),16)) S vRM=$$^MSG(742,"L") D vdderr("LIMPRO",vRM) Q 
	.	S X=$P(vobj(cuvar,"CIF"),$C(124),2) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("MAXCIFL",vRM) Q 
	.	S X=$P(vobj(cuvar,"CIF"),$C(124),7) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("MAXEXT",vRM) Q 
	.	S X=$P(vobj(cuvar,"CIF"),$C(124),1) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("MINCIFL",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"CIF"),$C(124),3)) S vRM=$$^MSG(742,"L") D vdderr("ORCIFN",vRM) Q 
	.	S X=$P(vobj(cuvar,"CIF"),$C(124),18) I '(X="") S vRM=$$VAL^DBSVER("N",5,0,,,,,2) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.PCTCAP"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	S X=$P(vobj(cuvar,"CIF"),$C(124),5) I '(X=""),'($D(^STBL("TAXREQ",X))#2) S vRM=$$^MSG(1485,X) D vdderr("TAXREQ",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"CIF"),$C(124),24)) S vRM=$$^MSG(742,"L") D vdderr("TINCO",vRM) Q 
	.	S X=$P(vobj(cuvar,"CIF"),$C(124),19) I '(X="") S vRM=$$VAL^DBSVER("$",15,0,,,,,2) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.TOTASS"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	S X=$P(vobj(cuvar,"CIF"),$C(124),17) I '(X="") S vRM=$$VAL^DBSVER("$",15,0,,,,,2) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.TOTCAP"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	Q 
	;
	I ($D(vobj(cuvar,"CIFMRPC"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"CIFMRPC")) vobj(cuvar,"CIFMRPC")=$S(vobj(cuvar,-2):$G(^CUVAR("CIFMRPC")),1:"")
	.	I $L($P(vobj(cuvar,"CIFMRPC"),$C(124),1))>20 S vRM=$$^MSG(1076,20) D vdderr("CIFMRPC",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"CIFVER"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"CIFVER")) vobj(cuvar,"CIFVER")=$S(vobj(cuvar,-2):$G(^CUVAR("CIFVER")),1:"")
	.	S X=$P(vobj(cuvar,"CIFVER"),$C(124),1) I '(X=""),X'?1.5N,X'?1"-"1.4N S vRM=$$^MSG(742,"N") D vdderr("CIFVER",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"CNTRY"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"CNTRY")) vobj(cuvar,"CNTRY")=$S(vobj(cuvar,-2):$G(^CUVAR("CNTRY")),1:"")
	.	I '("01"[$P(vobj(cuvar,"CNTRY"),$C(124),2)) S vRM=$$^MSG(742,"L") D vdderr("CATSUP",vRM) Q 
	.	S X=$P(vobj(cuvar,"CNTRY"),$C(124),1) I '(X=""),'($D(^STBL("CNTRY",X))#2) S vRM=$$^MSG(1485,X) D vdderr("CNTRY",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"CO"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"CO")) vobj(cuvar,"CO")=$S(vobj(cuvar,-2):$G(^CUVAR("CO")),1:"")
	.	I $L($P(vobj(cuvar,"CO"),$C(124),1))>12 S vRM=$$^MSG(1076,12) D vdderr("CO",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"COM"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"COM")) vobj(cuvar,"COM")=$S(vobj(cuvar,-2):$G(^CUVAR("COM")),1:"")
	.	S X=$P(vobj(cuvar,"COM"),$C(124),1) I '(X="") S vRM=$$VAL^DBSVER("$",18,0,,,,,2) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.MINCMAMT"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	Q 
	;
	I ($D(vobj(cuvar,"CONAM"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"CONAM")) vobj(cuvar,"CONAM")=$S(vobj(cuvar,-2):$G(^CUVAR("CONAM")),1:"")
	.	I $L($P(vobj(cuvar,"CONAM"),$C(124),1))>40 S vRM=$$^MSG(1076,40) D vdderr("CONAM",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"COPY"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"COPY")) vobj(cuvar,"COPY")=$S(vobj(cuvar,-2):$G(^CUVAR("COPY")),1:"")
	.	I $L($P(vobj(cuvar,"COPY"),$C(124),1))>80 S vRM=$$^MSG(1076,80) D vdderr("CPRTLN1",vRM) Q 
	.	I $L($P(vobj(cuvar,"COPY"),$C(124),2))>80 S vRM=$$^MSG(1076,80) D vdderr("CPRTLN2",vRM) Q 
	.	I $L($P(vobj(cuvar,"COPY"),$C(124),3))>80 S vRM=$$^MSG(1076,80) D vdderr("CPRTLN3",vRM) Q 
	.	I $L($P(vobj(cuvar,"COPY"),$C(124),4))>80 S vRM=$$^MSG(1076,80) D vdderr("CPRTLN4",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"COURTMSG"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"COURTMSG")) vobj(cuvar,"COURTMSG")=$S(vobj(cuvar,-2):$G(^CUVAR("COURTMSG")),1:"")
	.	I $L($P(vobj(cuvar,"COURTMSG"),$C(124),1))>50 S vRM=$$^MSG(1076,50) D vdderr("COURTMSG",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"CRCDTHR"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"CRCDTHR")) vobj(cuvar,"CRCDTHR")=$S(vobj(cuvar,-2):$G(^CUVAR("CRCDTHR")),1:"")
	.	S X=$P(vobj(cuvar,"CRCDTHR"),$C(124),1) I '(X="") S vRM=$$VAL^DBSVER("$",18,0,,,,,2) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.CRCDTHR"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	Q 
	;
	I ($D(vobj(cuvar,"CRT"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"CRT")) vobj(cuvar,"CRT")=$S(vobj(cuvar,-2):$G(^CUVAR("CRT")),1:"")
	.	I $L($P(vobj(cuvar,"CRT"),$C(124),8))>3 S vRM=$$^MSG(1076,3) D vdderr("DCCRCD",vRM) Q 
	.	S X=$P(vobj(cuvar,"CRT"),$C(124),4) I '(X=""),'($D(^TRN(X))>9) S vRM=$$^MSG(1485,X) D vdderr("DFTCHTRN",vRM) Q 
	.	S X=$P(vobj(cuvar,"CRT"),$C(124),5) I '(X=""),'($D(^TRN(X))>9) S vRM=$$^MSG(1485,X) D vdderr("DFTCI",vRM) Q 
	.	S X=$P(vobj(cuvar,"CRT"),$C(124),3) I '(X=""),'($D(^TRN(X))>9) S vRM=$$^MSG(1485,X) D vdderr("DFTCKTRN",vRM) Q 
	.	S X=$P(vobj(cuvar,"CRT"),$C(124),6) I '(X=""),'($D(^TRN(X))>9) S vRM=$$^MSG(1485,X) D vdderr("DFTCO",vRM) Q 
	.	S X=$P(vobj(cuvar,"CRT"),$C(124),1) I '(X=""),'($D(^SCAU(0,X))#2) S vRM=$$^MSG(1485,X) D vdderr("DFTSPVUCLS",vRM) Q 
	.	S X=$P(vobj(cuvar,"CRT"),$C(124),2) I '(X=""),'($D(^SCAU(0,X))#2) S vRM=$$^MSG(1485,X) D vdderr("DFTSTFUCLS",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"CRT"),$C(124),7)) S vRM=$$^MSG(742,"L") D vdderr("TREF",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"CRTDSP"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"CRTDSP")) vobj(cuvar,"CRTDSP")=$S(vobj(cuvar,-2):$G(^CUVAR("CRTDSP")),1:"")
	.	I '("01"[$P(vobj(cuvar,"CRTDSP"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("CRTDSP",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"CRTMSGD"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"CRTMSGD")) vobj(cuvar,"CRTMSGD")=$S(vobj(cuvar,-2):$G(^CUVAR("CRTMSGD")),1:"")
	.	I $L($P(vobj(cuvar,"CRTMSGD"),$C(124),1))>12 S vRM=$$^MSG(1076,12) D vdderr("CRTMSGD",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"CRTMSGL"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"CRTMSGL")) vobj(cuvar,"CRTMSGL")=$S(vobj(cuvar,-2):$G(^CUVAR("CRTMSGL")),1:"")
	.	I $L($P(vobj(cuvar,"CRTMSGL"),$C(124),1))>12 S vRM=$$^MSG(1076,12) D vdderr("CRTMSGL",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"CRTRW"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"CRTRW")) vobj(cuvar,"CRTRW")=$S(vobj(cuvar,-2):$G(^CUVAR("CRTRW")),1:"")
	.	I $L($P(vobj(cuvar,"CRTRW"),$C(124),3))>5 S vRM=$$^MSG(1076,5) D vdderr("CRCTRL",vRM) Q 
	.	S X=$P(vobj(cuvar,"CRTRW"),$C(124),5) I '(X=""),X'?1.7N,X'?1"-"1.6N S vRM=$$^MSG(742,"N") D vdderr("CRID",vRM) Q 
	.	S X=$P(vobj(cuvar,"CRTRW"),$C(124),6) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("CRLRD",vRM) Q 
	.	S X=$P(vobj(cuvar,"CRTRW"),$C(124),1) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("CRNTAP",vRM) Q 
	.	I $L($P(vobj(cuvar,"CRTRW"),$C(124),7))>12 S vRM=$$^MSG(1076,12) D vdderr("CRREP",vRM) Q 
	.	I $L($P(vobj(cuvar,"CRTRW"),$C(124),2))>2 S vRM=$$^MSG(1076,2) D vdderr("CRSHRT",vRM) Q 
	.	S X=$P(vobj(cuvar,"CRTRW"),$C(124),4) I '(X=""),X'?1.4N,X'?1"-"1.3N S vRM=$$^MSG(742,"N") D vdderr("CRSTUD",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"CSTFMTRTN"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"CSTFMTRTN")) vobj(cuvar,"CSTFMTRTN")=$S(vobj(cuvar,-2):$G(^CUVAR("CSTFMTRTN")),1:"")
	.	I $L($P(vobj(cuvar,"CSTFMTRTN"),$C(124),1))>12 S vRM=$$^MSG(1076,12) D vdderr("CSTFMTRTN",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"CURRENV"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"CURRENV")) vobj(cuvar,"CURRENV")=$S(vobj(cuvar,-2):$G(^CUVAR("CURRENV")),1:"")
	.	I '("01"[$P(vobj(cuvar,"CURRENV"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("CURRENV",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"CUSPGM"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"CUSPGM")) vobj(cuvar,"CUSPGM")=$S(vobj(cuvar,-2):$G(^CUVAR("CUSPGM")),1:"")
	.	I $L($P(vobj(cuvar,"CUSPGM"),$C(124),2))>15 S vRM=$$^MSG(1076,15) D vdderr("LRNCPGM",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"DAYEND"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"DAYEND")) vobj(cuvar,"DAYEND")=$S(vobj(cuvar,-2):$G(^CUVAR("DAYEND")),1:"")
	.	S X=$P(vobj(cuvar,"DAYEND"),$C(124),6) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("AROFF",vRM) Q 
	.	I $L($P(vobj(cuvar,"DAYEND"),$C(124),2))>40 S vRM=$$^MSG(1076,40) D vdderr("DAYEND2",vRM) Q 
	.	S X=$P(vobj(cuvar,"DAYEND"),$C(124),4) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("DAYEND4",vRM) Q 
	.	S X=$P(vobj(cuvar,"DAYEND"),$C(124),5) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("DAYEND5",vRM) Q 
	.	S X=$P(vobj(cuvar,"DAYEND"),$C(124),8) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("FINYE",vRM) Q 
	.	S X=$P(vobj(cuvar,"DAYEND"),$C(124),12) I '(X="") S vRM="" D DBSEDT^UFRE("[CUVAR]FINYEFREQ",0) I '($get(vRM)="") D vdderr("FINYEFREQ",vRM) Q 
	.	S X=$P(vobj(cuvar,"DAYEND"),$C(124),11) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("FINYEL",vRM) Q 
	.	S X=$P(vobj(cuvar,"DAYEND"),$C(124),3) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("MDO",vRM) Q 
	.	S X=$P(vobj(cuvar,"DAYEND"),$C(124),9) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("TAXYE",vRM) Q 
	.	S X=$P(vobj(cuvar,"DAYEND"),$C(124),10) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("TAXYEOFF",vRM) Q 
	.	S X=$P(vobj(cuvar,"DAYEND"),$C(124),7) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("YEOFF",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"DBS"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"DBS")) vobj(cuvar,"DBS")=$S(vobj(cuvar,-2):$G(^CUVAR("DBS")),1:"")
	.	I $L($P(vobj(cuvar,"DBS"),$C(124),5))>12 S vRM=$$^MSG(1076,12) D vdderr("DBSHDR",vRM) Q 
	.	S X=$P(vobj(cuvar,"DBS"),$C(124),4) I '(X=""),X'?1N S vRM=$$^MSG(742,"N") D vdderr("DBSLIST",vRM) Q 
	.	I $L($P(vobj(cuvar,"DBS"),$C(124),3))>40 S vRM=$$^MSG(1076,40) D vdderr("DBSPH132",vRM) Q 
	.	I $L($P(vobj(cuvar,"DBS"),$C(124),2))>40 S vRM=$$^MSG(1076,40) D vdderr("DBSPH80",vRM) Q 
	.	S X=$P(vobj(cuvar,"DBS"),$C(124),6) I '(X=""),'($D(^DBCTL("SYS","*RFMT",X))#2) S vRM=$$^MSG(1485,X) D vdderr("EDITMASK",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"DBS"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("FLDOVF",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"DBS"),$C(124),7)) S vRM=$$^MSG(742,"L") D vdderr("NOTP",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"DBSLSTEXP"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"DBSLSTEXP")) vobj(cuvar,"DBSLSTEXP")=$S(vobj(cuvar,-2):$G(^CUVAR("DBSLSTEXP")),1:"")
	.	S X=$P(vobj(cuvar,"DBSLSTEXP"),$C(124),1) I '(X=""),X'?1.5N,X'?1"-"1.4N S vRM=$$^MSG(742,"N") D vdderr("DBSLSTEXP",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"DEAL"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"DEAL")) vobj(cuvar,"DEAL")=$S(vobj(cuvar,-2):$G(^CUVAR("DEAL")),1:"")
	.	S X=$P(vobj(cuvar,"DEAL"),$C(124),2) I '(X=""),X'?1.4N,X'?1"-"1.3N S vRM=$$^MSG(742,"N") D vdderr("DEALPURG",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"DEAL"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("REKEY",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"DELDIS"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"DELDIS")) vobj(cuvar,"DELDIS")=$S(vobj(cuvar,-2):$G(^CUVAR("DELDIS")),1:"")
	.	S X=$P(vobj(cuvar,"DELDIS"),$C(124),1) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("DELDIS",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"DELQ"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"DELQ")) vobj(cuvar,"DELQ")=$S(vobj(cuvar,-2):$G(^CUVAR("DELQ")),1:"")
	.	S X=$P(vobj(cuvar,"DELQ"),$C(124),6) I '(X="") S vRM=$$VAL^DBSVER("T",7,0,,"X?1N.N!(X?1N.N1""-""1N.N)",,,0) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.DRC1"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	S X=$P(vobj(cuvar,"DELQ"),$C(124),15) I '(X="") S vRM=$$VAL^DBSVER("T",7,0,,"X?1N.N!(X?1N.N1""-""1N.N)",,,0) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.DRC10"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	S X=$P(vobj(cuvar,"DELQ"),$C(124),16) I '(X="") S vRM=$$VAL^DBSVER("T",7,0,,"X?1N.N!(X?1N.N1""-""1N.N)",,,0) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.DRC11"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	S X=$P(vobj(cuvar,"DELQ"),$C(124),17) I '(X="") S vRM=$$VAL^DBSVER("T",7,0,,"X?1N.N!(X?1N.N1""-""1N.N)",,,0) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.DRC12"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	S X=$P(vobj(cuvar,"DELQ"),$C(124),18) I '(X="") S vRM=$$VAL^DBSVER("T",7,0,,"X?1N.N!(X?1N.N1""-""1N.N)",,,0) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.DRC13"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	S X=$P(vobj(cuvar,"DELQ"),$C(124),19) I '(X="") S vRM=$$VAL^DBSVER("T",7,0,,"X?1N.N!(X?1N.N1""-""1N.N)",,,0) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.DRC14"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	S X=$P(vobj(cuvar,"DELQ"),$C(124),20) I '(X="") S vRM=$$VAL^DBSVER("T",7,0,,"X?1N.N!(X?1N.N1""-""1N.N)",,,0) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.DRC15"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	S X=$P(vobj(cuvar,"DELQ"),$C(124),21) I '(X="") S vRM=$$VAL^DBSVER("T",7,0,,"X?1N.N!(X?1N.N1""-""1N.N)",,,0) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.DRC16"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	S X=$P(vobj(cuvar,"DELQ"),$C(124),22) I '(X="") S vRM=$$VAL^DBSVER("T",7,0,,"X?1N.N!(X?1N.N1""-""1N.N)",,,0) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.DRC17"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	S X=$P(vobj(cuvar,"DELQ"),$C(124),23) I '(X="") S vRM=$$VAL^DBSVER("T",7,0,,"X?1N.N!(X?1N.N1""-""1N.N)",,,0) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.DRC18"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	S X=$P(vobj(cuvar,"DELQ"),$C(124),24) I '(X="") S vRM=$$VAL^DBSVER("T",7,0,,"X?1N.N!(X?1N.N1""-""1N.N)",,,0) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.DRC19"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	S X=$P(vobj(cuvar,"DELQ"),$C(124),7) I '(X="") S vRM=$$VAL^DBSVER("T",7,0,,"X?1N.N!(X?1N.N1""-""1N.N)",,,0) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.DRC2"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	S X=$P(vobj(cuvar,"DELQ"),$C(124),25) I '(X="") S vRM=$$VAL^DBSVER("T",7,0,,"X?1N.N!(X?1N.N1""-""1N.N)",,,0) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.DRC20"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	S X=$P(vobj(cuvar,"DELQ"),$C(124),8) I '(X="") S vRM=$$VAL^DBSVER("T",7,0,,"X?1N.N!(X?1N.N1""-""1N.N)",,,0) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.DRC3"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	S X=$P(vobj(cuvar,"DELQ"),$C(124),9) I '(X="") S vRM=$$VAL^DBSVER("T",7,0,,"X?1N.N!(X?1N.N1""-""1N.N)",,,0) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.DRC4"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	S X=$P(vobj(cuvar,"DELQ"),$C(124),10) I '(X="") S vRM=$$VAL^DBSVER("T",7,0,,"X?1N.N!(X?1N.N1""-""1N.N)",,,0) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.DRC5"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	S X=$P(vobj(cuvar,"DELQ"),$C(124),11) I '(X="") S vRM=$$VAL^DBSVER("T",7,0,,"X?1N.N!(X?1N.N1""-""1N.N)",,,0) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.DRC6"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	S X=$P(vobj(cuvar,"DELQ"),$C(124),12) I '(X="") S vRM=$$VAL^DBSVER("T",7,0,,"X?1N.N!(X?1N.N1""-""1N.N)",,,0) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.DRC7"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	S X=$P(vobj(cuvar,"DELQ"),$C(124),13) I '(X="") S vRM=$$VAL^DBSVER("T",7,0,,"X?1N.N!(X?1N.N1""-""1N.N)",,,0) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.DRC8"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	S X=$P(vobj(cuvar,"DELQ"),$C(124),14) I '(X="") S vRM=$$VAL^DBSVER("T",7,0,,"X?1N.N!(X?1N.N1""-""1N.N)",,,0) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.DRC9"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	S X=$P(vobj(cuvar,"DELQ"),$C(124),1) I '(X=""),'($D(^STBL("LNDELRBY",X))#2) S vRM=$$^MSG(1485,X) D vdderr("LNDRBY",vRM) Q 
	.	S X=$P(vobj(cuvar,"DELQ"),$C(124),2) I '(X=""),'($D(^STBL("LNDELRM",X))#2) S vRM=$$^MSG(1485,X) D vdderr("LNDRM",vRM) Q 
	.	S X=$P(vobj(cuvar,"DELQ"),$C(124),4) I '(X="") S vRM=$$VAL^DBSVER("$",12,0,,,,,2) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.MINAMT"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	I $L($P(vobj(cuvar,"DELQ"),$C(124),3))>12 S vRM=$$^MSG(1076,12) D vdderr("RPTNAM",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"DENFLG"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"DENFLG")) vobj(cuvar,"DENFLG")=$S(vobj(cuvar,-2):$G(^CUVAR("DENFLG")),1:"")
	.	S X=$P(vobj(cuvar,"DENFLG"),$C(124),1) I '(X=""),'($D(^STBL("DENFLG",X))#2) S vRM=$$^MSG(1485,X) D vdderr("DENFLG",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"DEP"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"DEP")) vobj(cuvar,"DEP")=$S(vobj(cuvar,-2):$G(^CUVAR("DEP")),1:"")
	.	S X=$P(vobj(cuvar,"DEP"),$C(124),10) I '(X=""),'($D(^STBL("ATMOPT",X))#2) S vRM=$$^MSG(1485,X) D vdderr("ATMOPT",vRM) Q 
	.	S X=$P(vobj(cuvar,"DEP"),$C(124),23) I '(X=""),'($D(^STBL("BALAVLCD",X))#2) S vRM=$$^MSG(1485,X) D vdderr("BALAVLCODE",vRM) Q 
	.	I $L($P(vobj(cuvar,"DEP"),$C(124),24))>12 S vRM=$$^MSG(1076,12) D vdderr("BALAVLPGM",vRM) Q 
	.	I $L($P(vobj(cuvar,"DEP"),$C(124),20))>12 S vRM=$$^MSG(1076,12) D vdderr("BALCCLC",vRM) Q 
	.	I $L($P(vobj(cuvar,"DEP"),$C(124),19))>12 S vRM=$$^MSG(1076,12) D vdderr("BALCLGC",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"DEP"),$C(124),17)) S vRM=$$^MSG(742,"L") D vdderr("CMSACOPT",vRM) Q 
	.	I $L($P(vobj(cuvar,"DEP"),$C(124),18))>10 S vRM=$$^MSG(1076,10) D vdderr("CMSAVALR",vRM) Q 
	.	S X=$P(vobj(cuvar,"DEP"),$C(124),14) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("INVPCTMIN",vRM) Q 
	.	S X=$P(vobj(cuvar,"DEP"),$C(124),12) I '(X=""),'($D(^STBL("IPYADJ",X))#2) S vRM=$$^MSG(1485,X) D vdderr("IPYADJ",vRM) Q 
	.	S X=$P(vobj(cuvar,"DEP"),$C(124),8) I '(X=""),'($D(^UTBL("IRADIS",X))#2) S vRM=$$^MSG(1485,X) D vdderr("IRAAUT",vRM) Q 
	.	S X=$P(vobj(cuvar,"DEP"),$C(124),2) I '(X=""),'($D(^UTBL("IRACON",X))#2) S vRM=$$^MSG(1485,X) D vdderr("IRACON",vRM) Q 
	.	S X=$P(vobj(cuvar,"DEP"),$C(124),3) I '(X=""),'($D(^UTBL("IRADIS",X))#2) S vRM=$$^MSG(1485,X) D vdderr("IRADIS",vRM) Q 
	.	S X=$P(vobj(cuvar,"DEP"),$C(124),4) I '(X=""),'($D(^UTBL("IRACON",X))#2) S vRM=$$^MSG(1485,X) D vdderr("IRAINT",vRM) Q 
	.	S X=$P(vobj(cuvar,"DEP"),$C(124),7) I '(X=""),'($D(^UTBL("IRADIS",X))#2) S vRM=$$^MSG(1485,X) D vdderr("IRAIPO",vRM) Q 
	.	S X=$P(vobj(cuvar,"DEP"),$C(124),6) I '(X=""),'($D(^UTBL("IRADIS",X))#2) S vRM=$$^MSG(1485,X) D vdderr("IRAIWH",vRM) Q 
	.	S X=$P(vobj(cuvar,"DEP"),$C(124),5) I '(X=""),'($D(^UTBL("IRADIS",X))#2) S vRM=$$^MSG(1485,X) D vdderr("IRAPEN",vRM) Q 
	.	S X=$P(vobj(cuvar,"DEP"),$C(124),21) I '(X=""),X'?1.4N,X'?1"-"1.3N S vRM=$$^MSG(742,"N") D vdderr("IRAPRGD",vRM) Q 
	.	S X=$P(vobj(cuvar,"DEP"),$C(124),22) I '(X=""),'($D(^STBL("MPSCERT",X))#2) S vRM=$$^MSG(1485,X) D vdderr("MPSCERT",vRM) Q 
	.	S X=$P(vobj(cuvar,"DEP"),$C(124),16) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("PRYRBKD",vRM) Q 
	.	S X=$P(vobj(cuvar,"DEP"),$C(124),9) I '(X=""),'($D(^STBL("RETOPT",X))#2) S vRM=$$^MSG(1485,X) D vdderr("RETOPT",vRM) Q 
	.	S X=$P(vobj(cuvar,"DEP"),$C(124),13) I '(X=""),'($D(^UTBL("IRADIS",X))#2) S vRM=$$^MSG(1485,X) D vdderr("RPAFEE",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"DEP"),$C(124),11)) S vRM=$$^MSG(742,"L") D vdderr("RPANET",vRM) Q 
	.	S X=$P(vobj(cuvar,"DEP"),$C(124),1) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("STPOF",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"DEPVER"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"DEPVER")) vobj(cuvar,"DEPVER")=$S(vobj(cuvar,-2):$G(^CUVAR("DEPVER")),1:"")
	.	S X=$P(vobj(cuvar,"DEPVER"),$C(124),1) I '(X=""),X'?1.5N,X'?1"-"1.4N S vRM=$$^MSG(742,"N") D vdderr("DEPVER",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"DFTENV"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"DFTENV")) vobj(cuvar,"DFTENV")=$S(vobj(cuvar,-2):$G(^CUVAR("DFTENV")),1:"")
	.	S X=$P(vobj(cuvar,"DFTENV"),$C(124),1) I '(X=""),'($D(^STBL("ENVDFT",X))#2) S vRM=$$^MSG(1485,X) D vdderr("DFTENV",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"DRMT"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"DRMT")) vobj(cuvar,"DRMT")=$S(vobj(cuvar,-2):$G(^CUVAR("DRMT")),1:"")
	.	S X=$P(vobj(cuvar,"DRMT"),$C(124),7) I '(X=""),X'?1.4N,X'?1"-"1.3N S vRM=$$^MSG(742,"N") D vdderr("DIN",vRM) Q 
	.	S X=$P(vobj(cuvar,"DRMT"),$C(124),1) I '(X=""),X'?1.4N,X'?1"-"1.3N S vRM=$$^MSG(742,"N") D vdderr("DRMT",vRM) Q 
	.	S X=$P(vobj(cuvar,"DRMT"),$C(124),2) I '(X=""),X'?1.5N,X'?1"-"1.4N S vRM=$$^MSG(742,"N") D vdderr("ESCH",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"DRMT"),$C(124),4)) S vRM=$$^MSG(742,"L") D vdderr("LCCADR",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"DRMT"),$C(124),6)) S vRM=$$^MSG(742,"L") D vdderr("LCCPU",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"DRMT"),$C(124),5)) S vRM=$$^MSG(742,"L") D vdderr("LCCTIT",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"DRMT"),$C(124),3)) S vRM=$$^MSG(742,"L") D vdderr("STMLCC",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"DRVMSG"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"DRVMSG")) vobj(cuvar,"DRVMSG")=$S(vobj(cuvar,-2):$G(^CUVAR("DRVMSG")),1:"")
	.	I $L($P(vobj(cuvar,"DRVMSG"),$C(124),1))>78 S vRM=$$^MSG(1076,78) D vdderr("DRVMSG",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"ECOMM"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"ECOMM")) vobj(cuvar,"ECOMM")=$S(vobj(cuvar,-2):$G(^CUVAR("ECOMM")),1:"")
	.	S X=$P(vobj(cuvar,"ECOMM"),$C(124),1) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("MAXLOGFAILS",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"EFD"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"EFD")) vobj(cuvar,"EFD")=$S(vobj(cuvar,-2):$G(^CUVAR("EFD")),1:"")
	.	I '("01"[$P(vobj(cuvar,"EFD"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("EFD",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"EFD"),$C(124),2)) S vRM=$$^MSG(742,"L") D vdderr("EFDFTFLG",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"EFTPAY"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"EFTPAY")) vobj(cuvar,"EFTPAY")=$S(vobj(cuvar,-2):$G(^CUVAR("EFTPAY")),1:"")
	.	I '("01"[$P(vobj(cuvar,"EFTPAY"),$C(124),16)) S vRM=$$^MSG(742,"L") D vdderr("DEBAUT",vRM) Q 
	.	I $L($P(vobj(cuvar,"EFTPAY"),$C(124),14))>40 S vRM=$$^MSG(1076,40) D vdderr("EFTARCDIR",vRM) Q 
	.	I $L($P(vobj(cuvar,"EFTPAY"),$C(124),12))>40 S vRM=$$^MSG(1076,40) D vdderr("EFTCCIN",vRM) Q 
	.	I $L($P(vobj(cuvar,"EFTPAY"),$C(124),13))>40 S vRM=$$^MSG(1076,40) D vdderr("EFTCCOUT",vRM) Q 
	.	S X=$P(vobj(cuvar,"EFTPAY"),$C(124),8) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("EFTCOM",vRM) Q 
	.	S X=$P(vobj(cuvar,"EFTPAY"),$C(124),7) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("EFTDEL",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"EFTPAY"),$C(124),19)) S vRM=$$^MSG(742,"L") D vdderr("EFTMEMO",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"EFTPAY"),$C(124),15)) S vRM=$$^MSG(742,"L") D vdderr("EFTREFNO",vRM) Q 
	.	S X=$P(vobj(cuvar,"EFTPAY"),$C(124),10) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("EFTREJ",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"EFTPAY"),$C(124),11)) S vRM=$$^MSG(742,"L") D vdderr("EFTRICO",vRM) Q 
	.	S X=$P(vobj(cuvar,"EFTPAY"),$C(124),20) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("EFTSUP",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"EFTPAY"),$C(124),17)) S vRM=$$^MSG(742,"L") D vdderr("FUTBLD",vRM) Q 
	.	S X=$P(vobj(cuvar,"EFTPAY"),$C(124),5) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("MAXCOL",vRM) Q 
	.	S X=$P(vobj(cuvar,"EFTPAY"),$C(124),2) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("MAXPAY",vRM) Q 
	.	S X=$P(vobj(cuvar,"EFTPAY"),$C(124),4) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("MINCOL",vRM) Q 
	.	S X=$P(vobj(cuvar,"EFTPAY"),$C(124),1) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("MINPAY",vRM) Q 
	.	S X=$P(vobj(cuvar,"EFTPAY"),$C(124),18) I '(X=""),'($D(^UTBL("CC",X))#2) S vRM=$$^MSG(1485,X) D vdderr("UDRC",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"EFTPRI"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"EFTPRI")) vobj(cuvar,"EFTPRI")=$S(vobj(cuvar,-2):$G(^CUVAR("EFTPRI")),1:"")
	.	S X=$P(vobj(cuvar,"EFTPRI"),$C(124),5) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("PENREVGL",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"EIN"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"EIN")) vobj(cuvar,"EIN")=$S(vobj(cuvar,-2):$G(^CUVAR("EIN")),1:"")
	.	I $L($P(vobj(cuvar,"EIN"),$C(124),1))>20 S vRM=$$^MSG(1076,20) D vdderr("EIN",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"ERBRES"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"ERBRES")) vobj(cuvar,"ERBRES")=$S(vobj(cuvar,-2):$G(^CUVAR("ERBRES")),1:"")
	.	I $L($P(vobj(cuvar,"ERBRES"),$C(124),1))>40 S vRM=$$^MSG(1076,40) D vdderr("ERBRES1",vRM) Q 
	.	I $L($P(vobj(cuvar,"ERBRES"),$C(124),2))>40 S vRM=$$^MSG(1076,40) D vdderr("ERBRES2",vRM) Q 
	.	I $L($P(vobj(cuvar,"ERBRES"),$C(124),3))>40 S vRM=$$^MSG(1076,40) D vdderr("ERBRES3",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"ESCHEAT"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"ESCHEAT")) vobj(cuvar,"ESCHEAT")=$S(vobj(cuvar,-2):$G(^CUVAR("ESCHEAT")),1:"")
	.	I $L($P(vobj(cuvar,"ESCHEAT"),$C(124),1))>12 S vRM=$$^MSG(1076,12) D vdderr("ESCHEAT",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"ESCROW"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"ESCROW")) vobj(cuvar,"ESCROW")=$S(vobj(cuvar,-2):$G(^CUVAR("ESCROW")),1:"")
	.	I $L($P(vobj(cuvar,"ESCROW"),$C(124),4))>8 S vRM=$$^MSG(1076,8) D vdderr("EADHS",vRM) Q 
	.	I $L($P(vobj(cuvar,"ESCROW"),$C(124),2))>8 S vRM=$$^MSG(1076,8) D vdderr("EAPPS",vRM) Q 
	.	I $L($P(vobj(cuvar,"ESCROW"),$C(124),1))>8 S vRM=$$^MSG(1076,8) D vdderr("EAPS",vRM) Q 
	.	I $L($P(vobj(cuvar,"ESCROW"),$C(124),3))>8 S vRM=$$^MSG(1076,8) D vdderr("EHDS",vRM) Q 
	.	I $L($P(vobj(cuvar,"ESCROW"),$C(124),5))>8 S vRM=$$^MSG(1076,8) D vdderr("IEDS",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"EUR"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"EUR")) vobj(cuvar,"EUR")=$S(vobj(cuvar,-2):$G(^CUVAR("EUR")),1:"")
	.	I '("01"[$P(vobj(cuvar,"EUR"),$C(124),6)) S vRM=$$^MSG(742,"L") D vdderr("DFTTHRC",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"EUR"),$C(124),7)) S vRM=$$^MSG(742,"L") D vdderr("DFTTHRR",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"EUR"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("EMU",vRM) Q 
	.	I $L($P(vobj(cuvar,"EUR"),$C(124),16))>3 S vRM=$$^MSG(1076,3) D vdderr("EMUCRCD",vRM) Q 
	.	S X=$P(vobj(cuvar,"EUR"),$C(124),17) I '(X=""),'($D(^STBL("EMURND",X))#2) S vRM=$$^MSG(1485,X) D vdderr("EMURND",vRM) Q 
	.	S X=$P(vobj(cuvar,"EUR"),$C(124),3) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("EURBAL",vRM) Q 
	.	S X=$P(vobj(cuvar,"EUR"),$C(124),13) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("EURCNVDT",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"EUR"),$C(124),18)) S vRM=$$^MSG(742,"L") D vdderr("EURINTEG",vRM) Q 
	.	S X=$P(vobj(cuvar,"EUR"),$C(124),4) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("EURRNDCR",vRM) Q 
	.	S X=$P(vobj(cuvar,"EUR"),$C(124),5) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("EURRNDDR",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"EUR"),$C(124),2)) S vRM=$$^MSG(742,"L") D vdderr("FNCRATE",vRM) Q 
	.	I $L($P(vobj(cuvar,"EUR"),$C(124),12))>3 S vRM=$$^MSG(1076,3) D vdderr("ORIGCRCD",vRM) Q 
	.	S X=$P(vobj(cuvar,"EUR"),$C(124),10) I '(X=""),X'?1.5N,X'?1"-"1.4N S vRM=$$^MSG(742,"N") D vdderr("RFC",vRM) Q 
	.	S X=$P(vobj(cuvar,"EUR"),$C(124),11) I '(X=""),X'?1.5N,X'?1"-"1.4N S vRM=$$^MSG(742,"N") D vdderr("RFR",vRM) Q 
	.	S X=$P(vobj(cuvar,"EUR"),$C(124),8) I '(X=""),'($D(^STBL("EURRM",X))#2) S vRM=$$^MSG(1485,X) D vdderr("RMC",vRM) Q 
	.	S X=$P(vobj(cuvar,"EUR"),$C(124),9) I '(X=""),'($D(^STBL("EURRM",X))#2) S vRM=$$^MSG(1485,X) D vdderr("RMR",vRM) Q 
	.	S X=$P(vobj(cuvar,"EUR"),$C(124),14) I '(X=""),'($D(^STBL("EURSC",X))#2) S vRM=$$^MSG(1485,X) D vdderr("SCDFT",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"EUR"),$C(124),15)) S vRM=$$^MSG(742,"L") D vdderr("SCOVR",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"EXTVAL"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"EXTVAL")) vobj(cuvar,"EXTVAL")=$S(vobj(cuvar,-2):$G(^CUVAR("EXTVAL")),1:"")
	.	S X=$P(vobj(cuvar,"EXTVAL"),$C(124),7) I '(X=""),'($D(^UTBL("CCNTR",X))#2) S vRM=$$^MSG(1485,X) D vdderr("EXTVALCC",vRM) Q 
	.	S X=$P(vobj(cuvar,"EXTVAL"),$C(124),5) I '(X=""),X'?1.12N,X'?1"-"1.11N S vRM=$$^MSG(742,"N") D vdderr("EXTVALCID",vRM) Q 
	.	S X=$P(vobj(cuvar,"EXTVAL"),$C(124),1) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("EXTVALCNT",vRM) Q 
	.	S X=$P(vobj(cuvar,"EXTVAL"),$C(124),4) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("EXTVALFAIL",vRM) Q 
	.	S X=$P(vobj(cuvar,"EXTVAL"),$C(124),2) I '(X="") S vRM=$$VAL^DBSVER("$",18,0,,,,,2) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.EXTVALMAXAMT"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	S X=$P(vobj(cuvar,"EXTVAL"),$C(124),3) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("EXTVALMAXDAY",vRM) Q 
	.	S X=$P(vobj(cuvar,"EXTVAL"),$C(124),6) I '(X=""),'($D(^UTBL("EXTYP",X))#2) S vRM=$$^MSG(1485,X) D vdderr("EXTVALTYPE",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"FCVMEMO"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"FCVMEMO")) vobj(cuvar,"FCVMEMO")=$S(vobj(cuvar,-2):$G(^CUVAR("FCVMEMO")),1:"")
	.	I '("01"[$P(vobj(cuvar,"FCVMEMO"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("FCVMEMO",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"FEPXALL"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"FEPXALL")) vobj(cuvar,"FEPXALL")=$S(vobj(cuvar,-2):$G(^CUVAR("FEPXALL")),1:"")
	.	I '("01"[$P(vobj(cuvar,"FEPXALL"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("FEPXALL",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"FTPTIME"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"FTPTIME")) vobj(cuvar,"FTPTIME")=$S(vobj(cuvar,-2):$G(^CUVAR("FTPTIME")),1:"")
	.	S X=$P(vobj(cuvar,"FTPTIME"),$C(124),1) I '(X=""),X'?1.4N,X'?1"-"1.3N S vRM=$$^MSG(742,"N") D vdderr("FTPTIME",vRM) Q 
	.	S X=$P(vobj(cuvar,"FTPTIME"),$C(124),2) I '(X=""),'($D(^STBL("TCPVER",X))#2) S vRM=$$^MSG(1485,X) D vdderr("TCPVER",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"FXRATEDF"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"FXRATEDF")) vobj(cuvar,"FXRATEDF")=$S(vobj(cuvar,-2):$G(^CUVAR("FXRATEDF")),1:"")
	.	S X=$P(vobj(cuvar,"FXRATEDF"),$C(124),1) I '(X=""),'($D(^STBL("FXRATEDF",X))#2) S vRM=$$^MSG(1485,X) D vdderr("FXRATEDF",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"GLACN"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"GLACN")) vobj(cuvar,"GLACN")=$S(vobj(cuvar,-2):$G(^CUVAR("GLACN")),1:"")
	.	S X=$P(vobj(cuvar,"GLACN"),$C(124),1) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("IPCID",vRM) Q 
	.	S X=$P(vobj(cuvar,"GLACN"),$C(124),2) I '(X=""),'($D(^TRN(X))>9) S vRM=$$^MSG(1485,X) D vdderr("IPETC",vRM) Q 
	.	S X=$P(vobj(cuvar,"GLACN"),$C(124),3) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("RLCID",vRM) Q 
	.	S X=$P(vobj(cuvar,"GLACN"),$C(124),4) I '(X=""),'($D(^TRN(X))>9) S vRM=$$^MSG(1485,X) D vdderr("RLETC",vRM) Q 
	.	S X=$P(vobj(cuvar,"GLACN"),$C(124),5) I '(X=""),'($D(^TRN(X))>9) S vRM=$$^MSG(1485,X) D vdderr("SLDGLTC",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"GLCC"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"GLCC")) vobj(cuvar,"GLCC")=$S(vobj(cuvar,-2):$G(^CUVAR("GLCC")),1:"")
	.	S X=$P(vobj(cuvar,"GLCC"),$C(124),2) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("GLCCRO",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"GLEFD"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"GLEFD")) vobj(cuvar,"GLEFD")=$S(vobj(cuvar,-2):$G(^CUVAR("GLEFD")),1:"")
	.	I '("01"[$P(vobj(cuvar,"GLEFD"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("GLEFDBCH",vRM) Q 
	.	S X=$P(vobj(cuvar,"GLEFD"),$C(124),3) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("GLEFDCR",vRM) Q 
	.	S X=$P(vobj(cuvar,"GLEFD"),$C(124),2) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("GLEFDDR",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"GLS"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"GLS")) vobj(cuvar,"GLS")=$S(vobj(cuvar,-2):$G(^CUVAR("GLS")),1:"")
	.	I $L($P(vobj(cuvar,"GLS"),$C(124),1))>12 S vRM=$$^MSG(1076,12) D vdderr("GLS",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"GLSBO"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"GLSBO")) vobj(cuvar,"GLSBO")=$S(vobj(cuvar,-2):$G(^CUVAR("GLSBO")),1:"")
	.	S X=$P(vobj(cuvar,"GLSBO"),$C(124),1) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("GLSBO",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"GLSETPGM"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"GLSETPGM")) vobj(cuvar,"GLSETPGM")=$S(vobj(cuvar,-2):$G(^CUVAR("GLSETPGM")),1:"")
	.	I $L($P(vobj(cuvar,"GLSETPGM"),$C(124),1))>9 S vRM=$$^MSG(1076,9) D vdderr("GLPGM",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"GLTS"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"GLTS")) vobj(cuvar,"GLTS")=$S(vobj(cuvar,-2):$G(^CUVAR("GLTS")),1:"")
	.	S X=$P(vobj(cuvar,"GLTS"),$C(124),1) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("GLTS",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"GLTSFP"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"GLTSFP")) vobj(cuvar,"GLTSFP")=$S(vobj(cuvar,-2):$G(^CUVAR("GLTSFP")),1:"")
	.	S X=$P(vobj(cuvar,"GLTSFP"),$C(124),1) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("GLTSFP",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"GLTSTO"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"GLTSTO")) vobj(cuvar,"GLTSTO")=$S(vobj(cuvar,-2):$G(^CUVAR("GLTSTO")),1:"")
	.	S X=$P(vobj(cuvar,"GLTSTO"),$C(124),1) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("GLTSTO",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"GLTSTS"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"GLTSTS")) vobj(cuvar,"GLTSTS")=$S(vobj(cuvar,-2):$G(^CUVAR("GLTSTS")),1:"")
	.	S X=$P(vobj(cuvar,"GLTSTS"),$C(124),1) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("GLTSTS",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"GLXFR"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"GLXFR")) vobj(cuvar,"GLXFR")=$S(vobj(cuvar,-2):$G(^CUVAR("GLXFR")),1:"")
	.	S X=$P(vobj(cuvar,"GLXFR"),$C(124),1) I '(X=""),'($D(^STBL("GLXFR",X))#2) S vRM=$$^MSG(1485,X) D vdderr("GLXFR",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"GRACE"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"GRACE")) vobj(cuvar,"GRACE")=$S(vobj(cuvar,-2):$G(^CUVAR("GRACE")),1:"")
	.	S X=$P(vobj(cuvar,"GRACE"),$C(124),1) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("GRACE",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"HANG"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"HANG")) vobj(cuvar,"HANG")=$S(vobj(cuvar,-2):$G(^CUVAR("HANG")),1:"")
	.	S X=$P(vobj(cuvar,"HANG"),$C(124),1) I '(X=""),X'?1N S vRM=$$^MSG(742,"N") D vdderr("HANG",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"HISTRPT"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"HISTRPT")) vobj(cuvar,"HISTRPT")=$S(vobj(cuvar,-2):$G(^CUVAR("HISTRPT")),1:"")
	.	I $L($P(vobj(cuvar,"HISTRPT"),$C(124),1))>15 S vRM=$$^MSG(1076,15) D vdderr("HISTRPT",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"HOTLIN"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"HOTLIN")) vobj(cuvar,"HOTLIN")=$S(vobj(cuvar,-2):$G(^CUVAR("HOTLIN")),1:"")
	.	I $L($P(vobj(cuvar,"HOTLIN"),$C(124),1))>12 S vRM=$$^MSG(1076,12) D vdderr("HOTLIN",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"IAMGESYMBL"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"IAMGESYMBL")) vobj(cuvar,"IAMGESYMBL")=$S(vobj(cuvar,-2):$G(^CUVAR("IAMGESYMBL")),1:"")
	.	I $L($P(vobj(cuvar,"IAMGESYMBL"),$C(124),1))>10 S vRM=$$^MSG(1076,10) D vdderr("IMAGESYMBL",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"IMAGE"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"IMAGE")) vobj(cuvar,"IMAGE")=$S(vobj(cuvar,-2):$G(^CUVAR("IMAGE")),1:"")
	.	I '("01"[$P(vobj(cuvar,"IMAGE"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("IMAGE",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"INCK"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"INCK")) vobj(cuvar,"INCK")=$S(vobj(cuvar,-2):$G(^CUVAR("INCK")),1:"")
	.	I '("01"[$P(vobj(cuvar,"INCK"),$C(124),23)) S vRM=$$^MSG(742,"L") D vdderr("ICCFF",vRM) Q 
	.	S X=$P(vobj(cuvar,"INCK"),$C(124),20) I '(X="") S vRM="" D DBSEDT^UFRE("[CUVAR]ICCFR",0) I '($get(vRM)="") D vdderr("ICCFR",vRM) Q 
	.	S X=$P(vobj(cuvar,"INCK"),$C(124),22) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("ICCLD",vRM) Q 
	.	S X=$P(vobj(cuvar,"INCK"),$C(124),21) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("ICCND",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"INCK"),$C(124),24)) S vRM=$$^MSG(742,"L") D vdderr("ICCNF",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"INCK"),$C(124),5)) S vRM=$$^MSG(742,"L") D vdderr("ICDFF",vRM) Q 
	.	S X=$P(vobj(cuvar,"INCK"),$C(124),1) I '(X="") S vRM="" D DBSEDT^UFRE("[CUVAR]ICDFR",0) I '($get(vRM)="") D vdderr("ICDFR",vRM) Q 
	.	S X=$P(vobj(cuvar,"INCK"),$C(124),3) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("ICDLD",vRM) Q 
	.	S X=$P(vobj(cuvar,"INCK"),$C(124),2) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("ICDND",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"INCK"),$C(124),6)) S vRM=$$^MSG(742,"L") D vdderr("ICDNF",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"INCK"),$C(124),7)) S vRM=$$^MSG(742,"L") D vdderr("ICDRF",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"INCK"),$C(124),4)) S vRM=$$^MSG(742,"L") D vdderr("ICDTF",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"INCK"),$C(124),14)) S vRM=$$^MSG(742,"L") D vdderr("ICLFF",vRM) Q 
	.	S X=$P(vobj(cuvar,"INCK"),$C(124),10) I '(X="") S vRM="" D DBSEDT^UFRE("[CUVAR]ICLFR",0) I '($get(vRM)="") D vdderr("ICLFR",vRM) Q 
	.	S X=$P(vobj(cuvar,"INCK"),$C(124),12) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("ICLLD",vRM) Q 
	.	S X=$P(vobj(cuvar,"INCK"),$C(124),11) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("ICLND",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"INCK"),$C(124),15)) S vRM=$$^MSG(742,"L") D vdderr("ICLNF",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"INCK"),$C(124),16)) S vRM=$$^MSG(742,"L") D vdderr("ICLRF",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"INCK"),$C(124),13)) S vRM=$$^MSG(742,"L") D vdderr("ICLTF",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"INQBAL"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"INQBAL")) vobj(cuvar,"INQBAL")=$S(vobj(cuvar,-2):$G(^CUVAR("INQBAL")),1:"")
	.	I $L($P(vobj(cuvar,"INQBAL"),$C(124),3))>12 S vRM=$$^MSG(1076,12) D vdderr("DDPACND",vRM) Q 
	.	I $L($P(vobj(cuvar,"INQBAL"),$C(124),4))>12 S vRM=$$^MSG(1076,12) D vdderr("DDPACNL",vRM) Q 
	.	I $L($P(vobj(cuvar,"INQBAL"),$C(124),1))>12 S vRM=$$^MSG(1076,12) D vdderr("INQBAL",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"INS"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"INS")) vobj(cuvar,"INS")=$S(vobj(cuvar,-2):$G(^CUVAR("INS")),1:"")
	.	S X=$P(vobj(cuvar,"INS"),$C(124),3) I '(X="") S vRM=$$VAL^DBSVER("$",18,0,,,,,2) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.DBIMBAL"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	S X=$P(vobj(cuvar,"INS"),$C(124),1) I '(X="") S vRM=$$VAL^DBSVER("$",18,0,,,,,2) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.DCL"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	S X=$P(vobj(cuvar,"INS"),$C(124),2) I '(X="") S vRM=$$VAL^DBSVER("$",18,0,,,,,2) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.LCL"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	I $L($P(vobj(cuvar,"INS"),$C(124),4))>8 S vRM=$$^MSG(1076,8) D vdderr("LTCL",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"INTPGM"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"INTPGM")) vobj(cuvar,"INTPGM")=$S(vobj(cuvar,-2):$G(^CUVAR("INTPGM")),1:"")
	.	I $L($P(vobj(cuvar,"INTPGM"),$C(124),1))>9 S vRM=$$^MSG(1076,9) D vdderr("INTPGM",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"INTPOS"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"INTPOS")) vobj(cuvar,"INTPOS")=$S(vobj(cuvar,-2):$G(^CUVAR("INTPOS")),1:"")
	.	S X=$P(vobj(cuvar,"INTPOS"),$C(124),1) I '(X=""),'($D(^STBL("POSOPT",X))#2) S vRM=$$^MSG(1485,X) D vdderr("INTPOS",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"INV"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"INV")) vobj(cuvar,"INV")=$S(vobj(cuvar,-2):$G(^CUVAR("INV")),1:"")
	.	S X=$P(vobj(cuvar,"INV"),$C(124),1) I '(X=""),'($D(^UTBL("NBD",X))#2) S vRM=$$^MSG(1485,X) D vdderr("BRKNBDC",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"IPD"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"IPD")) vobj(cuvar,"IPD")=$S(vobj(cuvar,-2):$G(^CUVAR("IPD")),1:"")
	.	I '("01"[$P(vobj(cuvar,"IPD"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("IPD",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"IRAHIST"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"IRAHIST")) vobj(cuvar,"IRAHIST")=$S(vobj(cuvar,-2):$G(^CUVAR("IRAHIST")),1:"")
	.	S X=$P(vobj(cuvar,"IRAHIST"),$C(124),1) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("IRAHIST",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"ISO"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"ISO")) vobj(cuvar,"ISO")=$S(vobj(cuvar,-2):$G(^CUVAR("ISO")),1:"")
	.	S X=$P(vobj(cuvar,"ISO"),$C(124),1) I '(X=""),X'?1.6N,X'?1"-"1.5N S vRM=$$^MSG(742,"N") D vdderr("ISO",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"LCNBDC"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"LCNBDC")) vobj(cuvar,"LCNBDC")=$S(vobj(cuvar,-2):$G(^CUVAR("LCNBDC")),1:"")
	.	S X=$P(vobj(cuvar,"LCNBDC"),$C(124),1) I '(X=""),'($D(^UTBL("NBD",X))#2) S vRM=$$^MSG(1485,X) D vdderr("LCNBDC",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"LETTER"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"LETTER")) vobj(cuvar,"LETTER")=$S(vobj(cuvar,-2):$G(^CUVAR("LETTER")),1:"")
	.	S X=$P(vobj(cuvar,"LETTER"),$C(124),2) I '(X=""),'($D(^DBCTL("SYS","DELIM",X))#2) S vRM=$$^MSG(1485,X) D vdderr("LETDEL",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"LETTER"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("LETFIX",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"LN"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"LN")) vobj(cuvar,"LN")=$S(vobj(cuvar,-2):$G(^CUVAR("LN")),1:"")
	.	S X=$P(vobj(cuvar,"LN"),$C(124),3) I '(X="") S vRM="" D DBSEDT^UFRE("[CUVAR]AAF",0) I '($get(vRM)="") D vdderr("AAF",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),2) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("AALD",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),1) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("AAND",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),38) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("CONTRA",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),28) I '(X=""),'($D(^STBL("DEL",X))#2) S vRM=$$^MSG(1485,X) D vdderr("DARCDEL",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"LN"),$C(124),31)) S vRM=$$^MSG(742,"L") D vdderr("DARCDFLG",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),24) I '(X="") S vRM="" D DBSEDT^UFRE("[CUVAR]DARCFREQ",0) I '($get(vRM)="") D vdderr("DARCFREQ",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),27) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("DARCLPDT",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),25) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("DARCNPDT",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),26) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("DARCOFF",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),40) I '(X=""),'($D(^STBL("DCCUP",X))#2) S vRM=$$^MSG(1485,X) D vdderr("DCCUP",vRM) Q 
	.	I $L($P(vobj(cuvar,"LN"),$C(124),4))>12 S vRM=$$^MSG(1076,12) D vdderr("DLQNT",vRM) Q 
	.	I $L($P(vobj(cuvar,"LN"),$C(124),16))>6 S vRM=$$^MSG(1076,6) D vdderr("ESCCHK",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),17) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("ESCGL",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),12) I '(X=""),'($D(^TRN(X))>9) S vRM=$$^MSG(1485,X) D vdderr("FEEICRTC",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),13) I '(X=""),'($D(^TRN(X))>9) S vRM=$$^MSG(1485,X) D vdderr("FEEIDRTC",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),14) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("IBILFF",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),10) I '(X=""),'($D(^TRN(X))>9) S vRM=$$^MSG(1485,X) D vdderr("IWUOCC",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),11) I '(X=""),'($D(^TRN(X))>9) S vRM=$$^MSG(1485,X) D vdderr("IWUODC",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),37) I '(X=""),'($D(^STBL("MPA",X))#2) S vRM=$$^MSG(1485,X) D vdderr("LNCC",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),34) I '(X=""),'($D(^STBL("MPA",X))#2) S vRM=$$^MSG(1485,X) D vdderr("LNCFP",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),36) I '(X=""),'($D(^STBL("MPA",X))#2) S vRM=$$^MSG(1485,X) D vdderr("LNCPI",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),35) I '(X=""),'($D(^STBL("MPA",X))#2) S vRM=$$^MSG(1485,X) D vdderr("LNCPP",vRM) Q 
	.	I $L($P(vobj(cuvar,"LN"),$C(124),39))>12 S vRM=$$^MSG(1076,12) D vdderr("LNPROJREP",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"LN"),$C(124),32)) S vRM=$$^MSG(742,"L") D vdderr("LNRENDEL",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),29) I '(X="") S vRM=$$VAL^DBSVER("T",50,0,,"X?.E1""^"".E",,,0) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.LNSUSEXT"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	S X=$P(vobj(cuvar,"LN"),$C(124),30) I '(X="") S vRM=$$VAL^DBSVER("N",9,0,,,0,100,5) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.LNSUSTP"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	S X=$P(vobj(cuvar,"LN"),$C(124),9) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("LPCO",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),6) I '(X="") S vRM="" D DBSEDT^UFRE("[CUVAR]LPFRE",0) I '($get(vRM)="") D vdderr("LPFRE",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),8) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("LPLD",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),7) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("LPND",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"LN"),$C(124),33)) S vRM=$$^MSG(742,"L") D vdderr("MRPT",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),18) I '(X="") S vRM="" D DBSEDT^UFRE("[CUVAR]PROVFREQ",0) I '($get(vRM)="") D vdderr("PROVFREQ",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),23) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("PROVLPDT",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),19) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("PROVNPDT",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),20) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("PROVOFF",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),21) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("PROVRCDT",vRM) Q 
	.	S X=$P(vobj(cuvar,"LN"),$C(124),22) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("PROVRPDT",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"LNCNV"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"LNCNV")) vobj(cuvar,"LNCNV")=$S(vobj(cuvar,-2):$G(^CUVAR("LNCNV")),1:"")
	.	I $L($P(vobj(cuvar,"LNCNV"),$C(124),1))>12 S vRM=$$^MSG(1076,12) D vdderr("CVSCR1",vRM) Q 
	.	I $L($P(vobj(cuvar,"LNCNV"),$C(124),2))>12 S vRM=$$^MSG(1076,12) D vdderr("CVSCR2",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"LNCON"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"LNCON")) vobj(cuvar,"LNCON")=$S(vobj(cuvar,-2):$G(^CUVAR("LNCON")),1:"")
	.	I $L($P(vobj(cuvar,"LNCON"),$C(124),6))>12 S vRM=$$^MSG(1076,12) D vdderr("LNCSCBL",vRM) Q 
	.	I $L($P(vobj(cuvar,"LNCON"),$C(124),1))>12 S vRM=$$^MSG(1076,12) D vdderr("LNCSCOM",vRM) Q 
	.	I $L($P(vobj(cuvar,"LNCON"),$C(124),5))>12 S vRM=$$^MSG(1076,12) D vdderr("LNCSDM",vRM) Q 
	.	I $L($P(vobj(cuvar,"LNCON"),$C(124),3))>12 S vRM=$$^MSG(1076,12) D vdderr("LNCSLN",vRM) Q 
	.	I $L($P(vobj(cuvar,"LNCON"),$C(124),2))>12 S vRM=$$^MSG(1076,12) D vdderr("LNCSMTG",vRM) Q 
	.	I $L($P(vobj(cuvar,"LNCON"),$C(124),4))>12 S vRM=$$^MSG(1076,12) D vdderr("LNCSRC",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"LOGINMSG"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"LOGINMSG")) vobj(cuvar,"LOGINMSG")=$S(vobj(cuvar,-2):$G(^CUVAR("LOGINMSG")),1:"")
	.	I $L($P(vobj(cuvar,"LOGINMSG"),$C(124),1))>60 S vRM=$$^MSG(1076,60) D vdderr("LOGINMSG1",vRM) Q 
	.	I $L($P(vobj(cuvar,"LOGINMSG"),$C(124),2))>60 S vRM=$$^MSG(1076,60) D vdderr("LOGINMSG2",vRM) Q 
	.	I $L($P(vobj(cuvar,"LOGINMSG"),$C(124),3))>60 S vRM=$$^MSG(1076,60) D vdderr("LOGINMSG3",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"LSP"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"LSP")) vobj(cuvar,"LSP")=$S(vobj(cuvar,-2):$G(^CUVAR("LSP")),1:"")
	.	S X=$P(vobj(cuvar,"LSP"),$C(124),1) I '(X=""),'($D(^STBL("LSP",X))#2) S vRM=$$^MSG(1485,X) D vdderr("LSP",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"MAXPM"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"MAXPM")) vobj(cuvar,"MAXPM")=$S(vobj(cuvar,-2):$G(^CUVAR("MAXPM")),1:"")
	.	S X=$P(vobj(cuvar,"MAXPM"),$C(124),1) I '(X=""),X'?1N S vRM=$$^MSG(742,"N") D vdderr("MAXPM",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"MFUND"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"MFUND")) vobj(cuvar,"MFUND")=$S(vobj(cuvar,-2):$G(^CUVAR("MFUND")),1:"")
	.	I '("01"[$P(vobj(cuvar,"MFUND"),$C(124),5)) S vRM=$$^MSG(742,"L") D vdderr("CIFEXTI",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"MICR"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"MICR")) vobj(cuvar,"MICR")=$S(vobj(cuvar,-2):$G(^CUVAR("MICR")),1:"")
	.	S X=$P(vobj(cuvar,"MICR"),$C(124),1) I '(X=""),X'?1.20N,X'?1"-"1.19N S vRM=$$^MSG(742,"N") D vdderr("MICR",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"MULTIITSID"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"MULTIITSID")) vobj(cuvar,"MULTIITSID")=$S(vobj(cuvar,-2):$G(^CUVAR("MULTIITSID")),1:"")
	.	I '("01"[$P(vobj(cuvar,"MULTIITSID"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("MULTIITSID",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"MXTRLM"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"MXTRLM")) vobj(cuvar,"MXTRLM")=$S(vobj(cuvar,-2):$G(^CUVAR("MXTRLM")),1:"")
	.	I '("01"[$P(vobj(cuvar,"MXTRLM"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("MXTRLM",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"NOREGD"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"NOREGD")) vobj(cuvar,"NOREGD")=$S(vobj(cuvar,-2):$G(^CUVAR("NOREGD")),1:"")
	.	I '("01"[$P(vobj(cuvar,"NOREGD"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("NOREGD",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"NOSTPURG"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"NOSTPURG")) vobj(cuvar,"NOSTPURG")=$S(vobj(cuvar,-2):$G(^CUVAR("NOSTPURG")),1:"")
	.	S X=$P(vobj(cuvar,"NOSTPURG"),$C(124),1) I '(X=""),X'?1.4N,X'?1"-"1.3N S vRM=$$^MSG(742,"N") D vdderr("NOSTPURG",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"ODP"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"ODP")) vobj(cuvar,"ODP")=$S(vobj(cuvar,-2):$G(^CUVAR("ODP")),1:"")
	.	I '("01"[$P(vobj(cuvar,"ODP"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("ODP",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"ODP"),$C(124),2)) S vRM=$$^MSG(742,"L") D vdderr("SFEEOPT",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"ODPE"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"ODPE")) vobj(cuvar,"ODPE")=$S(vobj(cuvar,-2):$G(^CUVAR("ODPE")),1:"")
	.	I '("01"[$P(vobj(cuvar,"ODPE"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("ODPE",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"OPTIMIZE"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"OPTIMIZE")) vobj(cuvar,"OPTIMIZE")=$S(vobj(cuvar,-2):$G(^CUVAR("OPTIMIZE")),1:"")
	.	I '("01"[$P(vobj(cuvar,"OPTIMIZE"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("NOSEGMENTS",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"PAYERNAM"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"PAYERNAM")) vobj(cuvar,"PAYERNAM")=$S(vobj(cuvar,-2):$G(^CUVAR("PAYERNAM")),1:"")
	.	I $L($P(vobj(cuvar,"PAYERNAM"),$C(124),1))>4 S vRM=$$^MSG(1076,4) D vdderr("PAYERNAM",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"PBALRTN"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"PBALRTN")) vobj(cuvar,"PBALRTN")=$S(vobj(cuvar,-2):$G(^CUVAR("PBALRTN")),1:"")
	.	I $L($P(vobj(cuvar,"PBALRTN"),$C(124),1))>9 S vRM=$$^MSG(1076,9) D vdderr("PBALRTN",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"PBKIRN"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"PBKIRN")) vobj(cuvar,"PBKIRN")=$S(vobj(cuvar,-2):$G(^CUVAR("PBKIRN")),1:"")
	.	S X=$P(vobj(cuvar,"PBKIRN"),$C(124),1) I '(X="") S vRM=$$VAL^DBSVER("N",8,0,,,,,4) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.PBKIRN"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	Q 
	;
	I ($D(vobj(cuvar,"PLACN"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"PLACN")) vobj(cuvar,"PLACN")=$S(vobj(cuvar,-2):$G(^CUVAR("PLACN")),1:"")
	.	S X=$P(vobj(cuvar,"PLACN"),$C(124),1) I '(X=""),'($D(^CIF(X,1))) S vRM=$$^MSG(1485,X) D vdderr("PLACN",vRM) Q 
	.	S X=$P(vobj(cuvar,"PLACN"),$C(124),2) I '(X=""),'($D(^UTBL("LNFEE",X))#2) S vRM=$$^MSG(1485,X) D vdderr("PLFEE",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"POINST"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"POINST")) vobj(cuvar,"POINST")=$S(vobj(cuvar,-2):$G(^CUVAR("POINST")),1:"")
	.	I $L($P(vobj(cuvar,"POINST"),$C(124),1))>34 S vRM=$$^MSG(1076,34) D vdderr("POINST",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"PRELID"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"PRELID")) vobj(cuvar,"PRELID")=$S(vobj(cuvar,-2):$G(^CUVAR("PRELID")),1:"")
	.	S X=$P(vobj(cuvar,"PRELID"),$C(124),2) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("DPREL",vRM) Q 
	.	I $L($P(vobj(cuvar,"PRELID"),$C(124),1))>8 S vRM=$$^MSG(1076,8) D vdderr("PRELID",vRM) Q 
	.	I $L($P(vobj(cuvar,"PRELID"),$C(124),5))>12 S vRM=$$^MSG(1076,12) D vdderr("TLOPRE",vRM) Q 
	.	S X=$P(vobj(cuvar,"PRELID"),$C(124),3) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"C") D vdderr("TPREL",vRM) Q 
	.	I $L($P(vobj(cuvar,"PRELID"),$C(124),4))>12 S vRM=$$^MSG(1076,12) D vdderr("USERPREL",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"PSWDH"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"PSWDH")) vobj(cuvar,"PSWDH")=$S(vobj(cuvar,-2):$G(^CUVAR("PSWDH")),1:"")
	.	S X=$P(vobj(cuvar,"PSWDH"),$C(124),1) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("PSWDH",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"PTMDIRID"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"PTMDIRID")) vobj(cuvar,"PTMDIRID")=$S(vobj(cuvar,-2):$G(^CUVAR("PTMDIRID")),1:"")
	.	I $L($P(vobj(cuvar,"PTMDIRID"),$C(124),1))>4 S vRM=$$^MSG(1076,4) D vdderr("PTMDIRID",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"PUBLISH"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"PUBLISH")) vobj(cuvar,"PUBLISH")=$S(vobj(cuvar,-2):$G(^CUVAR("PUBLISH")),1:"")
	.	I '("01"[$P(vobj(cuvar,"PUBLISH"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("PUBLISH",vRM) Q 
	.	I $L($P(vobj(cuvar,"PUBLISH"),$C(124),2))>40 S vRM=$$^MSG(1076,40) D vdderr("UCSSERV",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"RECPT"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"RECPT")) vobj(cuvar,"RECPT")=$S(vobj(cuvar,-2):$G(^CUVAR("RECPT")),1:"")
	.	I $L($P(vobj(cuvar,"RECPT"),$C(124),2))>12 S vRM=$$^MSG(1076,12) D vdderr("RECEIPT",vRM) Q 
	.	I $L($P(vobj(cuvar,"RECPT"),$C(124),1))>9 S vRM=$$^MSG(1076,9) D vdderr("RECPT",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"REGCC"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"REGCC")) vobj(cuvar,"REGCC")=$S(vobj(cuvar,-2):$G(^CUVAR("REGCC")),1:"")
	.	I '("01"[$P(vobj(cuvar,"REGCC"),$C(124),11)) S vRM=$$^MSG(742,"L") D vdderr("OBDE",vRM) Q 
	.	S X=$P(vobj(cuvar,"REGCC"),$C(124),1) I '(X=""),X'?1N S vRM=$$^MSG(742,"N") D vdderr("REGCC1",vRM) Q 
	.	S X=$P(vobj(cuvar,"REGCC"),$C(124),2) I '(X=""),X'?1N S vRM=$$^MSG(742,"N") D vdderr("REGCC2",vRM) Q 
	.	S X=$P(vobj(cuvar,"REGCC"),$C(124),3) I '(X=""),X'?1N S vRM=$$^MSG(742,"N") D vdderr("REGCC3",vRM) Q 
	.	S X=$P(vobj(cuvar,"REGCC"),$C(124),4) I '(X=""),X'?1N S vRM=$$^MSG(742,"N") D vdderr("REGCC4",vRM) Q 
	.	S X=$P(vobj(cuvar,"REGCC"),$C(124),5) I '(X=""),X'?1N S vRM=$$^MSG(742,"N") D vdderr("REGCC5",vRM) Q 
	.	S X=$P(vobj(cuvar,"REGCC"),$C(124),6) I '(X=""),X'?1N S vRM=$$^MSG(742,"N") D vdderr("REGCC6",vRM) Q 
	.	S X=$P(vobj(cuvar,"REGCC"),$C(124),10) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("REGCC7",vRM) Q 
	.	S X=$P(vobj(cuvar,"REGCC"),$C(124),9) I '(X=""),X'?1N S vRM=$$^MSG(742,"N") D vdderr("REGCCNAM",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"REGCC"),$C(124),7)) S vRM=$$^MSG(742,"L") D vdderr("REGCCOPT",vRM) Q 
	.	S X=$P(vobj(cuvar,"REGCC"),$C(124),8) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("REGCCRO",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"REGFLG"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"REGFLG")) vobj(cuvar,"REGFLG")=$S(vobj(cuvar,-2):$G(^CUVAR("REGFLG")),1:"")
	.	I '("01"[$P(vobj(cuvar,"REGFLG"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("REGFLG",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"RELID"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"RELID")) vobj(cuvar,"RELID")=$S(vobj(cuvar,-2):$G(^CUVAR("RELID")),1:"")
	.	S X=$P(vobj(cuvar,"RELID"),$C(124),2) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("DREL",vRM) Q 
	.	I $L($P(vobj(cuvar,"RELID"),$C(124),1))>8 S vRM=$$^MSG(1076,8) D vdderr("RELID",vRM) Q 
	.	I $L($P(vobj(cuvar,"RELID"),$C(124),5))>12 S vRM=$$^MSG(1076,12) D vdderr("TLOREL",vRM) Q 
	.	S X=$P(vobj(cuvar,"RELID"),$C(124),3) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"C") D vdderr("TREL",vRM) Q 
	.	I $L($P(vobj(cuvar,"RELID"),$C(124),4))>12 S vRM=$$^MSG(1076,12) D vdderr("USERREL",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"REPLY"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"REPLY")) vobj(cuvar,"REPLY")=$S(vobj(cuvar,-2):$G(^CUVAR("REPLY")),1:"")
	.	I $L($P(vobj(cuvar,"REPLY"),$C(124),1))>50 S vRM=$$^MSG(1076,50) D vdderr("REPLY",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"RESPROC"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"RESPROC")) vobj(cuvar,"RESPROC")=$S(vobj(cuvar,-2):$G(^CUVAR("RESPROC")),1:"")
	.	I '("01"[$P(vobj(cuvar,"RESPROC"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("RESPROC",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"RESTRICT"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"RESTRICT")) vobj(cuvar,"RESTRICT")=$S(vobj(cuvar,-2):$G(^CUVAR("RESTRICT")),1:"")
	.	I '("01"[$P(vobj(cuvar,"RESTRICT"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("RESTRICT",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"RSPPLID"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"RSPPLID")) vobj(cuvar,"RSPPLID")=$S(vobj(cuvar,-2):$G(^CUVAR("RSPPLID")),1:"")
	.	I $L($P(vobj(cuvar,"RSPPLID"),$C(124),1))>17 S vRM=$$^MSG(1076,17) D vdderr("RSPPLID",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"RT"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"RT")) vobj(cuvar,"RT")=$S(vobj(cuvar,-2):$G(^CUVAR("RT")),1:"")
	.	I $L($P(vobj(cuvar,"RT"),$C(124),1))>9 S vRM=$$^MSG(1076,9) D vdderr("RT",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"RTNFPGL"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"RTNFPGL")) vobj(cuvar,"RTNFPGL")=$S(vobj(cuvar,-2):$G(^CUVAR("RTNFPGL")),1:"")
	.	S X=$P(vobj(cuvar,"RTNFPGL"),$C(124),1) I '(X=""),'($D(^GLAD(X))#2) S vRM=$$^MSG(1485,X) D vdderr("RTNFPGL",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"SBINSTNO"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"SBINSTNO")) vobj(cuvar,"SBINSTNO")=$S(vobj(cuvar,-2):$G(^CUVAR("SBINSTNO")),1:"")
	.	S X=$P(vobj(cuvar,"SBINSTNO"),$C(124),1) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("SBINSTNO",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"SBN"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"SBN")) vobj(cuvar,"SBN")=$S(vobj(cuvar,-2):$G(^CUVAR("SBN")),1:"")
	.	S X=$P(vobj(cuvar,"SBN"),$C(124),3) I '(X=""),X'?1.5N,X'?1"-"1.4N S vRM=$$^MSG(742,"N") D vdderr("SBACQTO",vRM) Q 
	.	S X=$P(vobj(cuvar,"SBN"),$C(124),1) I '(X=""),X'?1.5N S vRM=$$^MSG(742,"D") D vdderr("SBSTDT",vRM) Q 
	.	S X=$P(vobj(cuvar,"SBN"),$C(124),2) I '(X=""),X'?1.10N,X'?1"-"1.9N S vRM=$$^MSG(742,"N") D vdderr("TMSRSND",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"SCA"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"SCA")) vobj(cuvar,"SCA")=$S(vobj(cuvar,-2):$G(^CUVAR("SCA")),1:"")
	.	I $L($P(vobj(cuvar,"SCA"),$C(124),1))>80 S vRM=$$^MSG(1076,80) D vdderr("PROWNR",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"SCAUREL"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"SCAUREL")) vobj(cuvar,"SCAUREL")=$S(vobj(cuvar,-2):$G(^CUVAR("SCAUREL")),1:"")
	.	I '("01"[$P(vobj(cuvar,"SCAUREL"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("SCAUREL",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"SCHRC"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"SCHRC")) vobj(cuvar,"SCHRC")=$S(vobj(cuvar,-2):$G(^CUVAR("SCHRC")),1:"")
	.	I '("01"[$P(vobj(cuvar,"SCHRC"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("SCHRCC",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"SCHRC"),$C(124),7)) S vRM=$$^MSG(742,"L") D vdderr("SCHRCE",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"SCHRC"),$C(124),2)) S vRM=$$^MSG(742,"L") D vdderr("SCHRCJ",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"SCHRC"),$C(124),3)) S vRM=$$^MSG(742,"L") D vdderr("SCHRCK",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"SCHRC"),$C(124),4)) S vRM=$$^MSG(742,"L") D vdderr("SCHRCL",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"SCHRC"),$C(124),5)) S vRM=$$^MSG(742,"L") D vdderr("SCHRCN",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"SCHRC"),$C(124),6)) S vRM=$$^MSG(742,"L") D vdderr("SCHRI",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"SEC"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"SEC")) vobj(cuvar,"SEC")=$S(vobj(cuvar,-2):$G(^CUVAR("SEC")),1:"")
	.	I $L($P(vobj(cuvar,"SEC"),$C(124),15))>32 S vRM=$$^MSG(1076,32) D vdderr("PSWAUT",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"SPLDIR"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"SPLDIR")) vobj(cuvar,"SPLDIR")=$S(vobj(cuvar,-2):$G(^CUVAR("SPLDIR")),1:"")
	.	I $L($P(vobj(cuvar,"SPLDIR"),$C(124),1))>40 S vRM=$$^MSG(1076,40) D vdderr("SPLDIR",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"SPLITDAY"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"SPLITDAY")) vobj(cuvar,"SPLITDAY")=$S(vobj(cuvar,-2):$G(^CUVAR("SPLITDAY")),1:"")
	.	I '("01"[$P(vobj(cuvar,"SPLITDAY"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("SPLITDAY",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"STFREJ"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"STFREJ")) vobj(cuvar,"STFREJ")=$S(vobj(cuvar,-2):$G(^CUVAR("STFREJ")),1:"")
	.	S X=$P(vobj(cuvar,"STFREJ"),$C(124),1) I '(X=""),'($D(^STBL("BATREJ",X))#2) S vRM=$$^MSG(1485,X) D vdderr("STFREJ",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"STMTSRT"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"STMTSRT")) vobj(cuvar,"STMTSRT")=$S(vobj(cuvar,-2):$G(^CUVAR("STMTSRT")),1:"")
	.	I '("01"[$P(vobj(cuvar,"STMTSRT"),$C(124),3)) S vRM=$$^MSG(742,"L") D vdderr("STMTCDSKIP",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"STMTSRT"),$C(124),6)) S vRM=$$^MSG(742,"L") D vdderr("STMTCUMUL",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"STMTSRT"),$C(124),4)) S vRM=$$^MSG(742,"L") D vdderr("STMTINTRTC",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"STMTSRT"),$C(124),5)) S vRM=$$^MSG(742,"L") D vdderr("STMTLNSKIP",vRM) Q 
	.	S X=$P(vobj(cuvar,"STMTSRT"),$C(124),1) I '(X=""),'($D(^STBL("STMTSRT",X))#2) S vRM=$$^MSG(1485,X) D vdderr("STMTSRTD",vRM) Q 
	.	S X=$P(vobj(cuvar,"STMTSRT"),$C(124),2) I '(X=""),'($D(^STBL("STMTSRT",X))#2) S vRM=$$^MSG(1485,X) D vdderr("STMTSRTL",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"SWIFT"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"SWIFT")) vobj(cuvar,"SWIFT")=$S(vobj(cuvar,-2):$G(^CUVAR("SWIFT")),1:"")
	.	S X=$P(vobj(cuvar,"SWIFT"),$C(124),2) I '(X=""),X'?1.4N,X'?1"-"1.3N S vRM=$$^MSG(742,"N") D vdderr("CNFRMHIS",vRM) Q 
	.	I '("01"[$P(vobj(cuvar,"SWIFT"),$C(124),5)) S vRM=$$^MSG(742,"L") D vdderr("EXTREM",vRM) Q 
	.	S X=$P(vobj(cuvar,"SWIFT"),$C(124),3) I '(X=""),X'?1.4N,X'?1"-"1.3N S vRM=$$^MSG(742,"N") D vdderr("MT900INT",vRM) Q 
	.	S X=$P(vobj(cuvar,"SWIFT"),$C(124),4) I '(X=""),X'?1.4N,X'?1"-"1.3N S vRM=$$^MSG(742,"N") D vdderr("MT910INT",vRM) Q 
	.	S X=$P(vobj(cuvar,"SWIFT"),$C(124),1) I '(X=""),X'?1.4N,X'?1"-"1.3N S vRM=$$^MSG(742,"N") D vdderr("PMTHIS",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"SWIFTADD"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"SWIFTADD")) vobj(cuvar,"SWIFTADD")=$S(vobj(cuvar,-2):$G(^CUVAR("SWIFTADD")),1:"")
	.	I $L($P(vobj(cuvar,"SWIFTADD"),$C(124),1))>15 S vRM=$$^MSG(1076,15) D vdderr("SWIFTADD",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"SYSDRV"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"SYSDRV")) vobj(cuvar,"SYSDRV")=$S(vobj(cuvar,-2):$G(^CUVAR("SYSDRV")),1:"")
	.	I $L($P(vobj(cuvar,"SYSDRV"),$C(124),2))>40 S vRM=$$^MSG(1076,40) D vdderr("DISTNAM",vRM) Q 
	.	I $L($P(vobj(cuvar,"SYSDRV"),$C(124),1))>3 S vRM=$$^MSG(1076,3) D vdderr("SYSABR",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"TAXCA"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"TAXCA")) vobj(cuvar,"TAXCA")=$S(vobj(cuvar,-2):$G(^CUVAR("TAXCA")),1:"")
	.	S X=$P(vobj(cuvar,"TAXCA"),$C(124),4) I '(X="") S vRM=$$VAL^DBSVER("$",12,0,,,,,2) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.NR4BRAMT"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	I $L($P(vobj(cuvar,"TAXCA"),$C(124),8))>15 S vRM=$$^MSG(1076,15) D vdderr("SDRIFTRN",vRM) Q 
	.	I $L($P(vobj(cuvar,"TAXCA"),$C(124),7))>15 S vRM=$$^MSG(1076,15) D vdderr("SDRSPTRN",vRM) Q 
	.	I $L($P(vobj(cuvar,"TAXCA"),$C(124),2))>15 S vRM=$$^MSG(1076,15) D vdderr("T4RIFTRN",vRM) Q 
	.	I $L($P(vobj(cuvar,"TAXCA"),$C(124),1))>15 S vRM=$$^MSG(1076,15) D vdderr("T4RSPTRN",vRM) Q 
	.	I $L($P(vobj(cuvar,"TAXCA"),$C(124),5))>9 S vRM=$$^MSG(1076,9) D vdderr("T5FID",vRM) Q 
	.	S X=$P(vobj(cuvar,"TAXCA"),$C(124),3) I '(X="") S vRM=$$VAL^DBSVER("$",12,0,,,,,2) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.T5RAMT"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	I $L($P(vobj(cuvar,"TAXCA"),$C(124),6))>15 S vRM=$$^MSG(1076,15) D vdderr("T5TRN",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"TCC"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"TCC")) vobj(cuvar,"TCC")=$S(vobj(cuvar,-2):$G(^CUVAR("TCC")),1:"")
	.	I $L($P(vobj(cuvar,"TCC"),$C(124),3))>11 S vRM=$$^MSG(1076,11) D vdderr("IEIN",vRM) Q 
	.	S X=$P(vobj(cuvar,"TCC"),$C(124),2) I '(X=""),'($D(^STBL("CNTRY",X))#2) S vRM=$$^MSG(1485,X) D vdderr("MAGCTRY",vRM) Q 
	.	I $L($P(vobj(cuvar,"TCC"),$C(124),1))>8 S vRM=$$^MSG(1076,8) D vdderr("TCC",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"UACND1F"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"UACND1F")) vobj(cuvar,"UACND1F")=$S(vobj(cuvar,-2):$G(^CUVAR("UACND1F")),1:"")
	.	I $L($P(vobj(cuvar,"UACND1F"),$C(124),1))>130 S vRM=$$^MSG(1076,130) D vdderr("UACND1F",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"UACNL1F"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"UACNL1F")) vobj(cuvar,"UACNL1F")=$S(vobj(cuvar,-2):$G(^CUVAR("UACNL1F")),1:"")
	.	I $L($P(vobj(cuvar,"UACNL1F"),$C(124),1))>130 S vRM=$$^MSG(1076,130) D vdderr("UACNL1F",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"UCID"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"UCID")) vobj(cuvar,"UCID")=$S(vobj(cuvar,-2):$G(^CUVAR("UCID")),1:"")
	.	I $L($P(vobj(cuvar,"UCID"),$C(124),1))>9 S vRM=$$^MSG(1076,9) D vdderr("UCID",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"UCIF1F"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"UCIF1F")) vobj(cuvar,"UCIF1F")=$S(vobj(cuvar,-2):$G(^CUVAR("UCIF1F")),1:"")
	.	I $L($P(vobj(cuvar,"UCIF1F"),$C(124),1))>130 S vRM=$$^MSG(1076,130) D vdderr("UCIF1F",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"USEGOPT"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"USEGOPT")) vobj(cuvar,"USEGOPT")=$S(vobj(cuvar,-2):$G(^CUVAR("USEGOPT")),1:"")
	.	S X=$P(vobj(cuvar,"USEGOPT"),$C(124),1) I '(X=""),'($D(^STBL("USEGOPT",X))#2) S vRM=$$^MSG(1485,X) D vdderr("USEGOPT",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"USERNAME"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"USERNAME")) vobj(cuvar,"USERNAME")=$S(vobj(cuvar,-2):$G(^CUVAR("USERNAME")),1:"")
	.	I $L($P(vobj(cuvar,"USERNAME"),$C(124),1))>7 S vRM=$$^MSG(1076,7) D vdderr("USERNAME",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"USRESTAT"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"USRESTAT")) vobj(cuvar,"USRESTAT")=$S(vobj(cuvar,-2):$G(^CUVAR("USRESTAT")),1:"")
	.	I '("01"[$P(vobj(cuvar,"USRESTAT"),$C(124),1)) S vRM=$$^MSG(742,"L") D vdderr("USRESTAT",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"VAT"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"VAT")) vobj(cuvar,"VAT")=$S(vobj(cuvar,-2):$G(^CUVAR("VAT")),1:"")
	.	S X=$P(vobj(cuvar,"VAT"),$C(124),1) I '(X="") S vRM=$$VAL^DBSVER("N",9,0,,,,,5) I '(vRM="") S vRM=$$^MSG(979,"CUVAR.VAT"_" "_vRM) S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate(vRM,",","~") X $ZT
	.	Q 
	;
	I ($D(vobj(cuvar,"VDT"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"VDT")) vobj(cuvar,"VDT")=$S(vobj(cuvar,-2):$G(^CUVAR("VDT")),1:"")
	.	S X=$P(vobj(cuvar,"VDT"),$C(124),1) I '(X=""),X'?1N S vRM=$$^MSG(742,"N") D vdderr("VDT",vRM) Q 
	.	S X=$P(vobj(cuvar,"VDT"),$C(124),2) I '(X=""),X'?1.2N,X'?1"-"1.1N S vRM=$$^MSG(742,"N") D vdderr("VDTFWD",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"VNDR"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"VNDR")) vobj(cuvar,"VNDR")=$S(vobj(cuvar,-2):$G(^CUVAR("VNDR")),1:"")
	.	I $L($P(vobj(cuvar,"VNDR"),$C(124),2))>40 S vRM=$$^MSG(1076,40) D vdderr("VADDR",vRM) Q 
	.	S X=$P(vobj(cuvar,"VNDR"),$C(124),7) I '(X=""),X'?1.3N,X'?1"-"1.2N S vRM=$$^MSG(742,"N") D vdderr("VCCODE",vRM) Q 
	.	I $L($P(vobj(cuvar,"VNDR"),$C(124),3))>40 S vRM=$$^MSG(1076,40) D vdderr("VCITY",vRM) Q 
	.	I $L($P(vobj(cuvar,"VNDR"),$C(124),6))>40 S vRM=$$^MSG(1076,40) D vdderr("VCNAME",vRM) Q 
	.	I $L($P(vobj(cuvar,"VNDR"),$C(124),9))>35 S vRM=$$^MSG(1076,35) D vdderr("VEMAIL",vRM) Q 
	.	I $L($P(vobj(cuvar,"VNDR"),$C(124),1))>40 S vRM=$$^MSG(1076,40) D vdderr("VNAME",vRM) Q 
	.	S X=$P(vobj(cuvar,"VNDR"),$C(124),8) I '(X=""),X'?1.7N,X'?1"-"1.6N S vRM=$$^MSG(742,"N") D vdderr("VPHONE",vRM) Q 
	.	I $L($P(vobj(cuvar,"VNDR"),$C(124),4))>2 S vRM=$$^MSG(1076,2) D vdderr("VSTATE",vRM) Q 
	.	I $L($P(vobj(cuvar,"VNDR"),$C(124),5))>9 S vRM=$$^MSG(1076,9) D vdderr("VZIP",vRM) Q 
	.	Q 
	;
	I ($D(vobj(cuvar,"XACN"))#2) D
	.	;
	.	 S:'$D(vobj(cuvar,"XACN")) vobj(cuvar,"XACN")=$S(vobj(cuvar,-2):$G(^CUVAR("XACN")),1:"")
	.	I $L($P(vobj(cuvar,"XACN"),$C(124),1))>12 S vRM=$$^MSG(1076,12) D vdderr("XACN",vRM) Q 
	.	Q 
	Q 
	;
vdderr(di,vRM)	; Column attribute error
	;
	 S ER=0
	D SETERR^DBSEXECU("CUVAR","MSG",979,"CUVAR."_di_" "_vRM)
	I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT
	Q 
	;
vkchged	; Access key changed
	;
	 S ER=0
	;
	N %O S %O=1
	N vnewkey N voldkey N vux
	;
	S vux=vx("")
	S voldkey=$piece(vux,"|",1) S vobj(cuvar,-3)=voldkey ; Copy old keys into object
	;
	S vpar=$$setPar^UCUTILN(vpar,"NOINDEX") ; Switch Index off
	D vload ; Make sure all data is loaded locally
	I vpar["/VALREQ/" D vrequ
	I vpar["/VALDD/" D vddver
	D vexec
	;
	S vnewkey=$piece(vux,"|",2) S vobj(cuvar,-3)=vnewkey ; Copy new keys into object
	N vnewrec S vnewrec=$$vReCp1(cuvar)
	S vobj(vnewrec,-2)=0
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(vnewrec) K vobj(vnewrec,-100) S vobj(vnewrec,-2)=1 Tcommit:vTp  
	;
	S %O=1 D CASUPD^DBSEXECU("CUVAR",voldkey,vnewkey) I ER S $ZS="-1,"_$ZPOS_","_"%PSL-E-DBFILER,"_$translate($get(RM),",","~") X $ZT ; Cascade update
	;
	S vobj(cuvar,-3)=$piece(vux,"|",1) ; Reset key for delete
	S vpar=$$initPar^UCUTILN("/NOVAL/NOCASDEL/NOJOURNAL/NOTRIGBEF/NOTRIGAFT/")
	S %O=3 D vdelete(1) ; Delete old record
	;
	K vobj(+$G(vnewrec)) Q 
	;
vDb1()	;	vobj()=Db.getRecord(CUVAR,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordCUVAR"
	I '$D(^CUVAR)
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,CUVAR" X $ZT
	Q vOid
	;
vOpen1()	;	DISTINCT COLUMN FROM SYSMAPLITDTA WHERE TABLE='CUVAR'
	;
	S vOid=$G(^DBTMP($J))-1,^($J)=vOid K ^DBTMP($J,vOid)
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=""
vL1a2	S vos2=$O(^SYSMAP("LITDATA",vos2),1) I vos2="" G vL1a8
	S vos3=""
vL1a4	S vos3=$O(^SYSMAP("LITDATA",vos2,"CUVAR",vos3),1) I vos3="" G vL1a2
	S vd=$S(vos3=$C(254):"",1:vos3)
	S ^DBTMP($J,vOid,1,vd)=vd
	G vL1a4
vL1a8	S vos2=""
vL1a9	S vos2=$O(^DBTMP($J,vOid,1,vos2),1) I vos2="" G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a9
	I vos1=2 S vos1=1
	;
	I vos1=0 K ^DBTMP($J,vOid) Q 0
	;
	S rslits=^DBTMP($J,vOid,1,vos2)
	;
	Q 1
	;
vReCp1(v1)	;	RecordCUVAR.copy: CUVAR
	;
	N vNod,vOid
	I $G(vobj(v1,-2)) D
	.	F vNod=2,1099,"%ATM","%BATCH","%BWPCT","%CC","%CRCD","%ET","%HELP","%IO","%KEYS","%LIBS","%MCP","%TBLS","%TO","%TOHALT","%VN","ACHORIG","ACNMRPC","ADDR","ADSCR","AGEMS","ALCOUNT","ALP","ANAOFF","AUTOAUTH","BANNER","BINDEF","BOBR","BSA","BTTJOB","BWAPGM","BWO","CHK","CHKHLDRTN","CHKPNT","CIDBLK","CIDLOWLM","CIF","CIFMRPC","CIFVER","CNTRY","CO","COM","CONAM","COPY","COURTMSG","CRCDTHR","CRT","CRTDSP","CRTMSGD","CRTMSGL","CRTRW","CSTFMTRTN","CURRENV","CUSPGM","DAYEND","DBS","DBSLSTEXP","DEAL","DELDIS","DELQ","DENFLG","DEP","DEPVER","DFTENV","DRMT","DRVMSG","ECOMM","EFD","EFTPAY","EFTPRI","EIN","ERBRES","ESCHEAT","ESCROW","EUR","EXTVAL","FCVMEMO","FEPXALL","FTPTIME","FXRATEDF","GLACN","GLCC","GLEFD","GLS","GLSBO","GLSETPGM","GLTS","GLTSFP","GLTSTO","GLTSTS","GLXFR","GRACE","HANG","HISTRPT","HOTLIN","IAMGESYMBL","IMAGE","INCK","INQBAL","INS","INTPGM","INTPOS","INV","IPD","IRAHIST","ISO","LCNBDC","LETTER","LN","LNCNV","LNCON","LOGINMSG","LSP","MAXPM","MFUND","MICR","MULTIITSID","MXTRLM","NOREGD","NOSTPURG","ODP","ODPE","OPTIMIZE","PAYERNAM","PBALRTN" S:'$D(vobj(v1,vNod)) vobj(v1,vNod)=$G(^CUVAR(vNod))
	.	F vNod="PBKIRN","PLACN","POINST","PRELID","PSWDH","PTMDIRID","PUBLISH","RECPT","REGCC","REGFLG","RELID","REPLY","RESPROC","RESTRICT","RSPPLID","RT","RTNFPGL","SBINSTNO","SBN","SCA","SCAUREL","SCHRC","SEC","SPLDIR","SPLITDAY","STFREJ","STMTSRT","SWIFT","SWIFTADD","SYSDRV","TAXCA","TCC","UACND1F","UACNL1F","UCID","UCIF1F","USEGOPT","USERNAME","USRESTAT","VAT","VDT","VNDR","XACN" S:'$D(vobj(v1,vNod)) vobj(v1,vNod)=$G(^CUVAR(vNod))
	S vOid=$$copy^UCGMR(v1)
	Q vOid
	;
vReSav1(vnewrec)	;	RecordCUVAR saveNoFiler(LOG)
	;
	D ^DBSLOGIT(vnewrec,vobj(vnewrec,-2))
	N vD,vN S vN=-1
	I '$G(vobj(vnewrec,-2)) F  S vN=$O(vobj(vnewrec,vN)) Q:vN=""  S vD=$$RTBAR^%ZFUNC(vobj(vnewrec,vN)) S:vD'="" ^CUVAR(vN)=vD
	E  F  S vN=$O(vobj(vnewrec,-100,vN)) Q:vN=""  S vD=$$RTBAR^%ZFUNC(vobj(vnewrec,vN)) S:vD'="" ^CUVAR(vN)=vD I vD="" ZWI ^CUVAR(vN)
	Q
	;
vtrap1	;	Error trap
	;
	N fERROR S fERROR=$ZS
	I $P(fERROR,",",3)="%PSL-E-DBFILER" D
	.		S ER=1
	.		S RM=$P(fERROR,",",4)
	.		Q 
	E  S $ZS=fERROR X voZT
	Q 
