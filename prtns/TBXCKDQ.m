TBXCKDQ	;Private;Validate PROFILE standard
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 06/13/02 11:49:40 - SPIER
	; ORIG:	SPIER -13-FEB-2002
	; DESC:	Automated code review utility
	;	This routine contains callable utilities used by the automated code review process
	;	initiated by the CodeWright Java interface.
	;
	; KEYWORDS:	Star Team, DATA-QWIK , I18N
	;
	; LIBRARY:
	;
	; I18N=QUIT;
	;
	;
	;--------- Revision History -----------------------------------------	
	;09/29/03 - Spier
	;	Additional change to EXT3 to deal with sql in psl code generating program.
	;03/28/03 - Spier
	;	Changed EXT3 section to not report errors on $ZD for psl elements when I18N is quit
	;
	D RELREV($zcmdline)
	Q
	;
RELREV(MFOLDER)	;
	;
	; need to open file and get contents, based on DQ call code below
	N arq,CHKRTN,CODECHEK,coderv,errcnt,external,ER,EOT,FATAL,FILE,FOLDER,i
	N I,IO,LINE,LOCFILE,j,J,OBJID,RETURN,RM
	S FILE=$$FILE^%TRNLNM("CR_contents.txt",MFOLDER)
	C FILE
	O FILE:READ
	S CODECHEK(1)=0
	S CODECHEK(2)=""
	S CODECHEK(3)=""
	S CODECHEK(4)=""
	S external=1
	F  S LINE=$$^%ZREAD(FILE,.EOT) Q:EOT  D
	.	N coderv
	.	I $E(LINE)="#" S arq=+$P(LINE,"|",3) Q
	.	S LOCFILE=$P(LINE,"|",1)
	.	S subfold=$P(LINE,"|",2)
	.	S CONTINUE=0
	.	if subfold="batch"!(subfold="trigger")!(subfold="procedure") do
	..		I $ZV["VMS" S FOLDER=$E(MFOLDER,1,$L(MFOLDER)-1)_".dataqwik."_subfold_"]"
	..		E  S FOLDER=MFOLDER_"/dataqwik/"_subfold
	..		set CONTINUE=1
	.	if subfold="routine" do
	..		I $ZV["VMS" S FOLDER=$E(MFOLDER,1,$L(MFOLDER)-1)_"."_subfold_"]"
	..		E  S FOLDER=MFOLDER_"/"_subfold
	..		set CONTINUE=1
	.	if subfold="percent_routine" do
	..		I $ZV["VMS" S FOLDER=$E(MFOLDER,1,$L(MFOLDER)-1)_"."_subfold_"]"
	..		E  S FOLDER=MFOLDER_"/"_subfold
	..		set CONTINUE=1
	.	if subfold="unix"!(subfold="vms") do
	..		I $ZV["VMS" S FOLDER=$E(MFOLDER,1,$L(MFOLDER)-1)_".percent_routine."_subfold_"]"
	..		E  S FOLDER=MFOLDER_"/percent_routine/"_subfold
	..		set CONTINUE=1
	.	I 'CONTINUE Q
	.	S CHKRTN=$$FILE^%TRNLNM(LOCFILE,FOLDER)
	.	S RETURN=$$EXECREV(LOCFILE,CHKRTN,.coderv)
	.	I $G(FATAL) S CODECHEK(1)=1
	.	S J=$O(CODECHEK(""),-1)+1
	.	S I=""
	.	F  S I=$O(coderv(I)) Q:I=""  S CODECHEK(J)=coderv(I),J=J+1
	S CODECHEK(2)="Code Review Completed - "_(+$G(FATAL))_" Fatal error(s)"
	S CODECHEK(3)="                      - "_($G(errcnt)-$G(FATAL))_" Non-fatal error(s)"
	S IO=$$FILE^%TRNLNM("CR_contents.REVIEW",MFOLDER)
	O IO:NEWV
	U IO
	S J=""
	F  S J=$O(CODECHEK(J)) Q:J=""  W CODECHEK(J),!
	C IO
	Q
	;
	;
EXECREV(LOCFILE,FILE,coderv)	; Execute code Review 
	;-----------------------------------------------------------------------
	;
	N X,CODE,PSLSRC,OUTFILE,CMDARY,CMPERR,SRCFLG,OBJTYPE,MSEC,SEQ,RET
	N $ZT,desc,tdir,hist,i18n,comment,LEVEL,v,v1,id,x,external 
	S $ZT="ZG "_$ZL_":ZTA^TBXCKDQ" 
	;
	; 
	S ER=0
	S SRCFLG=0
	S LOCFILE=$$UPPER^%ZFUNC(LOCFILE)
	;
	S OBJTYPE=$P(LOCFILE,".",2)
	S OBJID=$P(LOCFILE,".",1)
	C FILE
	O FILE:READ
	F I=1:1 S LINE=$$^%ZREAD(FILE,.EOT) Q:EOT  S CODE(I)=LINE
	C FILE
	;
	I ($E(OBJTYPE,1,4)="PROC") Q $$REVCODE(OBJID,.CODE,25)
	I ($E(OBJTYPE,1,4)="TRIG") Q $$REVCODE(OBJID,.CODE,7)
	I OBJTYPE="BATCH" Q $$REVCODE(OBJID,.CODE,33)
	I OBJTYPE="M" D EXT^TBXCKRTN(.CODE,FILE,.I18N) Q 1
	Q "Invalid element type"
	;
	;
	;-----------------------------------------------------------------------
REVCODE(OBJID,CODE,LEVEL)	
	;-----------------------------------------------------------------------
	;
	N SEQ,DBATYPE,RET
	;
	I LEVEL=7 S DBATYPE=7
	I LEVEL=33 S DBATYPE=7
	I LEVEL=25 S DBATYPE=3
	;
	S SEQ=""
	;
	S RET=OBJID_" code reviewed at "_$$TIME^%ZD()_" on " 
	S RET=RET_$$^%ZD()_" in "_$$^CUVAR("CONAM")_$C(13,10)
	I DBATYPE=3 D SETUP3^TBXCKDQ
	I DBATYPE=7 D SETUP7^TBXCKDQ
	;
	F  S SEQ=$O(CODE(SEQ)) Q:SEQ=""  D
	.	I DBATYPE=3 D EXT3^TBXCKDQ(CODE(SEQ),LEVEL,OBJID,SEQ,+$g(external))
	.	I DBATYPE=7 D EXT7^TBXCKDQ(CODE(SEQ),LEVEL,OBJID,SEQ,+$G(external))
	.		;
	N ERSEQ
	S ERSEQ=""
	F  S ERSEQ=$O(coderv(ERSEQ),1) Q:ERSEQ=""  D
	.	I $L(RET)>30000 Q
	.	S RET=RET_coderv(ERSEQ)_$C(13,10)
	;
	I ER Q 1
	S ER=0
	;
	Q RET
	; 
	;
	;---------------------------------------------------------------------        ;
ZTA	; 
	;---------------------------------------------------------------------        ;
	S ER=0
	I $G(RM)="" S RM=$ZS
	Q RM 
	;
	;
SETUP3	;
	S desc(3)="Executive",desc(25)="Procedure"
	S tdir=$G(tdir)
	S hist=0,i18n=1
	S comment=0
	quit
EXT3(v,lev,id,x,external)	
	S v1=$$UPPER^%ZFUNC(v)
	D Y2K(v,v1,lev,id)
	I v["$ZD("!(v["^%ZD("),$G(i18n)=0,$E(id,1,2)'="UC" D ERR(lev,id,v1,5)
	I v1["SELECT^SQL(",v1'["_",v1["""",$P(v1,"SELECT^SQL",1)'[";",$E(id,1,2)'="UC"  d ERR(lev,id_" "_x,v,5.3) Q  ; 12/11/98 BC
	I v1["I18N=ON" S i18n=1 Q
	I v1["I18N=OFF" S i18n=0 Q
	I v1["I18N=QUIT" S i18n=0 Q	; Disable checking
	I '$G(external),v1["REVISION HISTORY",$G(arq)>0 D	; Search for ARQ number
	.	S j=x F i=1:1:20 S j=$O(CODE(j)) Q:j=""  I CODE(j)[arq S hist=1 Q
	.	i 'hist D ERR(lev,id,v1,5.1)
	I lev=25,v1["$$^CUVAR(",v1["""" d ERR(lev,id_" line "_x,v,5.36) Q	; 04/18/00 tmd
	I lev=25,((v1["$$LOCK^TTXP2")!(v1["UNLOCK^TTXP2")) D ERR(lev,id_" line "_x,v,20)
	I 'i18n S DD=1 Q	
	D I18N(v,lev)				; I18N checking
	I '$$SQL(v) Q				; not ^SQL call
	D ERR(lev,id_" "_x,v,4.3)		; Use &&SQL syntax v6.0 and +
	quit
SQL(v)	;
	;;I v["&&SQL" Q 1
	I v["$$^SQL",$P(v,"$$^SQL",1)'[";" Q 1
	I v["$$SELECT^SQL" Q 1
	I v["$$INSERT^SQL" Q 1
	I v["$$UPDATE^SQL" Q 1
	I v["$$DELETE^SQL" Q 1
	Q 0
SETUP7	;
	S desc(7)="Trigger",desc(33)="Batch"
	S tdir=$G(tdir)
	S hist=0,i18n=1
	S comment=0
	Q
EXT7(y,lev,id,x,external)	
	S v1=$$UPPER^%ZFUNC(v)
	I '(lev=33&(x="REVHIST")) D Y2K(v,v1,lev,id)
	I v["$ZD("!(v["^%ZD(") D ERR(lev,id,v1,5)
	I lev=7,$E(x)="Z" Q
	I lev=7,v1["SELECT^SQL(",v1'["_",v1["""" d ERR(lev,id_" line "_x,v,5.3) Q
	I lev=33,v1["SELECT^SQL(",v1["""" d ERR(lev,id_" line "_x,v,5.35) Q
	I lev=7,v1["$$^CUVAR(",v1["""" d ERR(lev,id_" line "_x,v,5.36) Q
	I lev=33,v1["$$^CUVAR(",v1["""" d ERR(lev,id_" line "_x,v,5.36) Q
	I v1["I18N=ON" S i18n=1 Q
	I v1["I18N=OFF" S i18n=0 Q
	I v1["I18N=QUIT" S i18n=0 Q	; Disable checking
	I v1[" D ^UCIF" D ERR(lev,id,v,11.7)
	I v1[" D ^UACN" D ERR(lev,id,v,11.8)
	I '$g(external),v1["REVISION HISTORY",$G(arq)>0 D     ; Search for ARQ number
	.	S j=x F i=1:1:20 S j=$O(CODE(j)) Q:j=""  I CODE(j)[arq S hist=1 Q
	I lev=33,((v1["$$LOCK^TTXP2")!(v1["UNLOCK^TTXP2")) D ERR(lev,id_" line "_x,v,20)
	I lev=33 Q			; Batch definition
	I i18n=0 Q			; Checking disabled
	D I18N(v,lev)			; Check I18N standard
	I '$$SQL(v) Q
	I lev=33 D ERR(lev,id_" line "_x,v,4.93) Q	; Batch (fatal error)
	D ERR(lev,id_" "_x,v,4.3)		; Use &&SQL syntax v6.0 and +
	Q
I18N(v,lev)	;
	;
	n err,i,sql,z
	S sql=0
	F i="DB.","&&","SQL","SELECT","FROM","WHERE","ORDER","SET","INSERT","DELETE" I v1[i S sql=1 Q
	I sql Q
	;
	I ((lev=33)!(lev=7)!(lev=25)),(v["/*") s comment=1 Q	; PSL comment line
	I ((lev=33)!(lev=7)!(lev=25)),((v["*/")) s comment=0 Q	; PSL comment line
	I comment q
	I ((lev=33)!(lev=7)!(lev=25)),(v["//") Q		; PSL comment line
	I v["[",v["]" Q					; DQ expression
	S z=$$DBA5^TBXCKRTN(v,.err,,,,,1)
	I '$D(err) Q
	I err(1)["***" D ERR(lev,id,v,5.2) Q		; Fatal I18N error
	D ERR(lev,id,v,4.5)
	Q
Y2K(v,v1,lev,id)	;
	N expr,sts
	S sts=$$ZMCHK(v)
	I 'sts Q
	I sts=1 D ERR(lev,$G(id),v1,4.51) Q
	I sts=2 D ERR(lev,$G(id),v1,18) Q
	I sts=3 D ERR(lev,$G(id),v1,19)		; 02/24/99 BC
	Q
ZMCHK(v)	;
	I $TR(v,$C(9)," ")?." "1";".E Q 0	; comment line
	I v["$$DAT^%ZM",v'["$$DAT^%ZM(",v'["//" Q 3	; need argument
	I v["^SCADAT1" Q 1			; verify %DS
	I v'["$E($$DAT^%ZM(" Q 0		; no match
	S expr=$P(v,"$E($$DAT^%ZM(",2)	  ; get expression
	S expr=$P(expr,")",1)
	I expr[",",expr["""" Q 1		; Mask included
	Q 2
	Q
	;----------------------------------------------------------------------
ERR(lev,id,v,msg)	; 
	;----------------------------------------------------------------------
	;
	I $G(errmsg)'="",msg'=errmsg Q		; Display one error type
	I $g(fopt)="Y",msg<5 Q			; Display fatal errors only
	n z
	S errcnt=$g(errcnt)+1
	;
	S z="Routine"
	I lev=1 S z="File"
	I lev="1D" S z="Data Item"
	I lev=2 S z="Screen"
	I lev=3 S z="Exec"
	I lev=5 S z="Report"
	I lev=7 S z="Trigger"
	I lev=25 S z="Procedure"
	I lev=33 S z="batch"
	d write("------------------------------------------------------------------")
	d write($g(version)_" ("_z_") "_id),write("")
	I $G(v)'="" D write(" "_$TR(v,$C(9)," "))
	I $G(fopt)="Y" d write(msg_"  ==>")
	;
	I msg>4.99 S ER=1,RM="Fatal code review error(s)",FATAL=$G(FATAL)+1
	;
	I msg=1.1 D write("-W- Invalid file type 5 (should be 1 or 3)") Q
	I msg=2 D write("-I- Lookup table syntax error (use [FID] syntax)") Q
	I msg=3 D write("-I- Global reference error (use filer or &&SQL to update this global)") Q
	I msg=4 D write("-W- Missing ER checking logic (UFRE utility)") Q
	I msg=4.01 D write("-W- Call to $$NEW^%ZT is no longer necessary") Q
	I msg=4.02 D write("-W- S @$$SET^%ZT should be replaced with S $ZT=$$SETZT^%ZT to improve performance") Q
	I msg=4.03 D write("-W- Call to ^SCADAT should pass second parameter of 1") Q
	I msg=4.1 D write("-W- ^ADDR, ^MLT or ^LNOLC invalid references (V5.2+)") Q
	I msg=4.16 D write("-W- Field size for frequency data type should be 12") 
	I msg=4.2 D write("-W- Invalid expression (host variable referenced)") Q
	I msg=4.3 D write("-I- ^SQL call should be replaced with &&SQL macro command to improve performance") Q
	I msg=4.31 D write("-W- SELECT^SQL is not as efficient as global access") Q
	I msg=4.4 D write("-W- Invalid default value expression (Use $$ function or system variables)") Q
	I msg=4.5 D write("-W- I18n error - "_$G(err(1))) Q
	I msg=4.51 D write("-I- Please review Y2K standard") Q
	I msg=4.6 D write("-W- Missing file definition") Q
	I msg=4.8 D write("-W- Invalid field display attribute (bold)") Q
	I msg=4.9 D write("-W- Screen size should be 80 and not 132") Q
	I msg=4.91 D write("-W- It should not be used in versions v6.1 and above") Q
	I msg=4.93 D write("-W- Replace ^SQL calls with PSL Db.getRecord/select/update/delete methods") Q
	I msg=4.94 D write("-I- Record type should be 1") Q
	I msg=4.95 D write("-W- Total record size > 8000") Q
	I msg=4.96 D write("-W- Invalid data item "_id_" (Z name)") Q
	I msg=4.97 D write("-W- Field size for currency data type should be 12 or 18") Q
	I msg=4.98 D write("-W- Z-named file definitions should be released under a custom sub-system") Q
	;
	; Fatal error (5-20)
	;
	I msg=5 D write("-F- Invalid $ZD or ^%ZD reference --- use $$DAT^%ZM(date,mask) or $$func^SCADAT(date) functions") Q
	I msg=5.1 D write("-F- Missing revision history for ARQ "_$G(arq)) Q
	I msg=5.2 D write("-F- I18n error - "_$G(err(1))) Q
	I msg=5.3 D write("-F- SELECT^SQL call should be replaced with &&SQLSELECT") q
	I msg=5.35 D write("-F- SELECT^SQL should be replaced with Dbb.select method (V6.0+)") Q
	I msg=5.36 D write("-F- $$^CUVAR should be replaced with Db.ggetRecord method (PSL) or &&SQLSELECT (non-PSL)") Q
	I msg=5.99 D write("-F- OS specific command - use ^%OSSCRPT utility")
	I msg=6 D write("-F- Invalid ^%T reference (use $$TIM^%ZM function)") Q
	I msg=7 D write("-F- Length error on date field (should be 10)") Q
	I msg=8 D write("-F- $N reference (use $O syntax)") Q
	I msg=8.1 D write("-F- $ZP reference (use $O(^gbl(...),-1) syntax)") Q
	I msg=9 D write("-F- ZA or ZD reference (use L+ or L- syntax)") Q
	I msg=10.1 D write("-F- Invalid network location (should be 2)") Q
	I msg=10.2 D write("-F- Invalid logging option (should be 1)") Q
	I msg=10.3 D write("-F- Missing Supertype information (should be ACN)") Q
	I msg=10.4 D write("-F- Invalid data item ") Q
	;;I msg=10.41 D write("-F- Invalid data item "_id_" (Z name)") Q
	I msg=10.42 D write("-F- Invalid data item "_id_" (node>999)") Q
	I msg=10.43 D write("-F- Invalid computed expression (nested call)") Q
	I msg=10.5 D write("-F- Invalid computed expression ($D referenced)") Q
	I msg=10.6 D write("-F- Invalid computed expression (global referenced)") Q
	I msg=10.7 D write("-F- Invalid computed expression (foreign table(s) referenced)") Q
	I msg=10.8 D write("-F- Invalid node/computed expression") Q
	I msg=10.9 D write("-F- Invalid data item "_id) Q
	I msg=11.1 D write("-F- Missing access keys") Q
	I msg=11.11 D write("-F- Missing File description") Q
	I msg=11.2 D write("-F- Access key "_id_" should be a required field") Q
	I msg=11.3 D write("-F- "_id_" is in supertype file ACN but missing from DEP file") Q
	I msg=11.4 D write("-F- "_id_" is in supertype file ACN but missing from LN file") Q
	I msg=11.5 D write("-F- "_id_" is in supertype file ACN but missing from DTYPE file") Q
	I msg=11.6 D write("-F- "_id_" is in supertype file ACN but missing from LTYPE file") Q
	I msg=11.7 D write("-F- "_id_" Invalid reference to routine UCIF") Q
	I msg=11.8 D write("-F- "_id_" Invalid reference to routine UACN") Q
	I msg=11.9 D write("-F- Invalid global SET command in DQ screen") Q
	I msg=12 D write("-F- Data item name is a blank field") Q
	I msg=13 D write("-F- Replace ^SQL calls with &&sql macro command") Q
	I msg=13.1 D write("-F- Reference to vobj not allowed") Q
	I msg=14 D write("-F- Use $$NJD^UFRE(JD,FRE,AF,CTL) syntax") Q
	I msg=15 D write("-F- Lookup table syntax error (use [FID] syntax)") Q
	I msg=16 D write("-F- Field size for frequency data type should be 12") Q
	I msg=16.1 D write("-F- Field size for Text data type should be less than 510") Q
	I msg=17 D write("-F- $$^DI^SCATAB should be replaced with prompt table entry") Q
	I msg=18 D write("-F- Invalid Y2K date standard --- use $$func^SCADAT(date) or $$DAT^%ZM(data,mask) utility") Q
	I msg=19 D write("-F- Missing parameter --- use $$DAT^%ZM(+$H) or $$DAT^%ZM(^CUVAR(2))") Q
	I msg=20 D write("-F- Please remove $$LOCK^TTXP2 and UNLOCK^TTXP2 logic") Q
	Q
write(str)	; 
	N seq
	;;W !,str,!
	S seq=$O(coderv(""),-1)+1
	S coderv(seq)=str
	Q
