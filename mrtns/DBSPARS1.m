DBSPARS1	;DBSPARS1;DBS - U - V4.4 - POST PROCESSOR MACRO COMMAND
	;;Copyright(c)2003 Sanchez Computer Associates, Inc.  All Rights Reserved - 03/26/03 10:16:46 - CHENARDP
	;     ORIG: BOB CHIANG  01/08/1992
	;     DESC: Screen Macro command Parser
	;
	; GLOBALS -  ^CUVAR,^DBTBL,^^"
	;     READ:
	;      SET:
	;
	;    INPUT: X      - INPUT STRING DATA
	;           PSEQ() - PRE/POST PROCESSOR LINE TAG SEQUENCE #
	;           EXTSID - SCREEN ID
	;   OUTPUT: LOOP() - FILE & DATA ITEM INFORMATION
	;           OM()   - DECODED OUTPUT
	;           RM     - ERROR MESSAGE
	;           ER     - ERROR FLAG
	;
        ; I18N=QUIT: Exculded from I18N standards.
	;---- Revision History ------------------------------------------------
	; 08/30/06 - RussellDS - CR22720
	;	     Replaced call to $$UPPER^SCAUTL with $$UPPER^UCGMR to
	;	     avoid bootstrap issues.
	;
	; 05/17/06 - Allan Mattson - CR20048
	;            Replaced calls to $$UPPER^%ZFUNC with $$UPPER^SCAUTL.
	;
	;            Deleted pre-2003 revision history.
	;
	; 03/26/03 - Pete Chenard - 49451
	;	     Added new label CNV which is called from the M->PSL
	;	     conversion utility.
	;----------------------------------------------------------------------
	;
START	;
	;
	N ZCMD,Z,OM1,ER,RM,POM1,POM2,data,code
	;
	I '$D(zmac) D INIT ;		Set up command table
	S Z="",data=OM(Z20)
	F  S Z=$O(smac(Z)) Q:Z=""  I data[("."_Z_".") D PARSE Q
	Q
PARSE	;
	S ZCMD=OX,ER=0,RM="",code="."_Z_"."
	N Z
	;
	; ---------- Original and converted command line
	;
	S Z=$$COM(OX) I Z S OX=$E(OX,1,Z-2) 		;Remove comments
	S Z=$$COM(data) I Z S data=$E(data,1,Z-2)
	;
	S OM1=$P(OX,code,1),ZCMD=code_$P(OX,code,2)
	;	
	S POM1=$P(data,code,1),POM2=$P(data,code,2)
	;
	; ---------- command keyword = [fid]di syntax
	;            replace the expression with variable "zv"
	;            Example:  .DEFAULT. [DEP]IRN=[DEP]BAL/1000
	;                      s zv=[DEP]BAL/1000 .DEFAULT. [DEP]IRN=zv
	;
	S Z=$P(ZCMD,"=",2,99)
	I Z?.E1"["1E.E1"]"1E.E!(Z["|")!(Z["/") DO
	.	S ZCMD=$P(ZCMD,"=",1)_"=zv"
	.	S POM1=POM1_"S zv="_$P(POM2,"=",2,99)_" "
	;
	; ---------- Convert macro to ^DBSMACRO calls
	;
	S Z=$$CMD(ZCMD)
	I POM1'=" " S Z=POM1_Z
	I 'ER,OX[".GOTO." S Z=Z_" Q"
	;
	; ---------- If error, keep original input
	;
	I ER DO
	.	;S OM(Z20)=" ; ??? "_OX,ER=0 K RM Q
	.	;
	.	N I F I=1:1 Q:'$D(RM(I))  W !,RM(I) H 1
	;
	; ---------- Special logic for .COMPUTE. and .LOAD. macros
	;
	I Z["COMPUTE^DBSMACRO" D COMPUTE Q
	I Z["LOAD^DBSMACRO" D LOAD Q
	;
	I $E(Z)'=" " S Z=" "_Z
	S OM(Z20)=Z
	Q
	;
LOAD	;  ========== Access data from disk for one or all items (v 3.6)
	;
	;            .LOAD. [FID]                  Items from single file (4.2)
	;            .LOAD. ALL                    all itmes
	;
	S OM2=$P(ZCMD,".LOAD.",2)
	I OM2?1" ALL"." " S X="D VLOD" D SET Q
	;
	I '$D(BLD) Q  ; only valid in screen pre-processor .LOAD. [FID]
	;
	I OM2'?1" ["1E.AN1"]".E Q
	;
	N X,load,I
	;
	S X=$P($P(OM2,"[",2),"]",1)
	D LOAD1(X,.load)
	;
	D SET
	;
	S X="" F I=0:.01 S X=$O(load(X)) Q:X=""  S OM(I+Z20)=load(X)
	;
	Q
	;----------------------------------------------------------------------
LOAD1(FID,LOAD)	; .LOAD. [FID]
	;----------------------------------------------------------------------
	;
	N DLIB,DFID,FSN,S,X,KEYS
	K LOAD
	;
	S DLIB=$G(%LIBS) I DLIB="" S DLIB=^CUVAR("%LIBS")
	S DFID=FID
	S X=$P(^DBTBL(DLIB,1,DFID,10),"|",5)
	I X'="" S DFID=$P($P(X,",",2),"]",1) ; Implicit
	;
	S FSN=" "_^(12)_"("
	;
	; ---------- Scan BLD() for load commands
	;
	S SEQ=0,S=1
	;
	; ---------- Access keys LOOP(FID)=k1|k2|...
	;
	S X=$P($G(LOOP(^(12))),"|",1) I X="" Q
	S KEYS=" S "_X_"="
NLOAD	S SEQ=$O(BLD(SEQ)) I SEQ="" G NCOMP
	I BLD(SEQ)?." "1".".E G NLOAD
	I BLD(SEQ)?1"VCOM ;".E S SEQ="" G NCOMP
	I $E(BLD(SEQ),1,$L(KEYS))=KEYS S LOAD(S)=" I $G("_X_")="_""""""_BLD(SEQ),S=S+1 G NLOAD
	I BLD(SEQ)'[FSN G NLOAD
	S LOAD(S)=BLD(SEQ),S=S+1	
	G NLOAD
	;
	; ---------- Include computed data items from COMP()
	;
NCOMP	;
	S SEQ=$O(COMP(SEQ)) I SEQ="" Q
	I '$D(^DBTBL(DLIB,1,DFID,9,SEQ)) G NCOMP
	I COMP(SEQ)?1"D ".E S LOAD(S)=" "_COMP(SEQ)
	       E  S LOAD(S+100)=" S "_SEQ_"="_COMP(SEQ) 
	S S=S+1 G NCOMP
	;
	;
	;
COMPUTE	; ========== Recalc one or all computed items on the screen (v 3.6)
	;
	;            .COMPUTE. [FID]DI             single data item
	;            .COMPUTE. ALL                 all computed items on screen
	;
	N ddref,NS,X,z,comp
	;
	S ddref=$TR($P(ZCMD,".COMPUTE.",2)," ","")
	I $$UPPER^UCGMR(ddref)="ALL" S X="D VCOM" D SET Q
	;
	; Invalid COMPUTE syntax - ~p1
	I $$CMP^DBSDD(.ddref,.z,.vdd)="" S RM=$$^MSG(1290,OX) Q
	;
	N comp,fid,di
	D PARSE^DBSDD(.ddref,.z,.comp,.fsn,"",.vdd)
	;
	S fid=$P(ddref,".",2),di=$P(ddref,".",3)
	I $D(comp(fid,di)) S NS=comp(fid,di)
	;
	I NS'?1"D ".E1"^"1E.AN.E,$E(NS,1,2)'="S " S NS="S "_di_"="_NS
	S X=NS D SET
	Q
SET	;
	;
	I OM1="" S OM(Z20)=" "_X
	E  S OM(Z20)=OM1_X
	S OM(Z20-1+0.8)=" ;",OM(Z20-1+0.81)=" ; ----- "_OX,OM(Z20-1+0.83)=" ;"
	Q
	;
	;
CMD(str)	;
	n tree,pre,cmd,arg,val,ln
	I '$D(smac) D INIT
	;
	S cmd=$P(str,".",2),arg=$p(str,".",3,99)
	S val=$P(arg,"=",2,9),arg=$P(arg,"=",1)
	I $E(arg)=" " s arg=$p(arg," ",2)
	;I arg[" " s arg=$p(arg," ",1)
	S ln=cmd_" "_arg I val'="" s ln=ln_" "_val
	;
	D ^DBSINT(ln,"smac(",0,"",""," ","/","")
	;
	I ER Q ""
	;
	DO chkarg I ER Q ""
	;
	Q "D "_$g(tree(1))
	;
chkarg	; ---------- Check valid syntax
	;
	N cmd,arg,z,z1
	S cmd=$P(tree(1),"^",1),arg=$P(tree(1),$C(34),2) ; command^pgm(...
	S ER=0
	I arg?1"["1E.E1"]"1E.E,sarg(cmd)["di" Q  ;	[fid]di
	I arg?1"@"1E.E,sarg(cmd)["di" Q  ;		@di
	I arg?1"["1E.E1"]",sarg(cmd)["file" Q  ;	[fid]
	I arg?1A.E1"."1A.E,sarg(cmd)["di" Q		;	fid.di
	I sarg(cmd)[(","_arg_",") Q
	S ER=1,z=$O(RM(""),-1)+1,RM(z)=str,z1="."_$P(str,".",2)_".",z1=$F(str,z1)
	; Invalid keyword - ~p1
	S RM(z+1)=$$^MSG(1385,$J("",z1))
	;
	Q
	;
	;
INIT	; Initialize Screen Macro Commands
	;----------------------------------------------------------------------
	;
	N z
	S z("CHANGE")="CHANGE^DBSMACRO(1/REQ/TYP=U,2/NOQWT)|,MIN,MAX,TBL,PAT,DEC,REQ,"
	S z("COMPUTE")="COMPUTE^DBSMACRO(1/REQ/TYP=U)|,ALL,di"
	S z("DEFAULT")="DEFAULT^DBSMACRO(1/REQ/TYP=U,2/NOQWT,UX/NEG/DEF=1,NULLONLY/NEG/DEF=0,CHGONLY/NEG/DEF=0)|di"
	S z("DELETE")="DELETE^DBSMACRO(1/REQ/TYP=U,UX/NEG/DEF=1,CHGONLY/NEG/DEF=0)|,ALL,di"
	S z("DISPLAY")="DISPLAY^DBSMACRO(1/REQ/TYP=U,2/NOQWT,CHGONLY/NEG/DEF=0)|,ALL,di"
	S z("GOTO")="GOTO^DBSMACRO(1/REQ/TYP=U)|,NEXT,END,di"
	S z("LOAD")="LOAD^DBSMACRO(1/REQ/TYP=U)|,ALL,file"
	S z("PROTECT")="PROTECT^DBSMACRO(1/REQ/TYPE=U)|,ALL,di"
	S z("UNPROT")="UNPROT^DBSMACRO(1/REQ/TYPE=U|,ALL,di"
	; *** - BC - 12/09/93
	S z("RWOPT")="RWOPT^DBSRWEXE(1/REQ/TYP=U,2/QWT)|,NODTL,NOHDR,NOSTAT,NOALIGN,NOCLOSE,NOOPEN,LINKRPT,BLKFLD,BLKLINE,"
	;
	S z="" F  S z=$O(z(z)) Q:z=""  S smac(z)=$P(z(z),"|",1),sarg(z)=$P(z(z),"|",2)
	;
	Q
TEST	;
	;
	; Input String: 
	F  W !,$$^MSG(8020)  R str Q:str=""  DO
	.	;
	.	B  s x=$$CMD(str)
	.	I ER W !!,RM,!! Q
	.	W !!,x,! Q
	Q
COM(X)	;
	N Y
	S Y=0 F  S Y=$F(X," ;",Y) Q:Y=0  I $L($E(X,1,Y-2),"""")#2 Q
	Q Y
	Q
	;
CNV(str)	;	convert 1 line 
	N OM,OX,Z20,sarg,smac
	S Z20=1
	S (OM(1),OX)=str
	D ^DBSPARS1
	Q OM(1)
	
