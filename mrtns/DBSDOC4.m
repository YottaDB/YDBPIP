DBSDOC4	;; Private  DBS - U - V 5.0 Lookup Documentation Maintenance Function
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 12/22/94 09:18:19 - XUS
	;     ORG: XUS 10/31/94
	;     DESC:  Lookup table documentation Maintenance Function
	;
	;---- Revision History ------------------------------------------------
	; 09/17/04 - RussellDS - CR8102
	;	     Changed calls to GETKEY and GETDESC^DBSTBLM to local calls
	;	     since this code has been removed from DBSTBLM.
	;
	;-----------------------------------------------------------------------
	Q
	;
	;----------------------------------------------------------------------
KEYOPT 	; Post Processor for key option
	;----------------------------------------------------------------------
	;
	I X="ALL" Q
	I $$EXIST^DBSEDIT(DOCFID,X) Q
	; Invalid key option
	S ER=1,RM=$$^MSG(8315) 
	Q
	;
	;----------------------------------------------------------------------
SKIP(lin)   ; Skip the spaces and TAB in front of a line or at end of a line
	;----------------------------------------------------------------------
	; 
	N line,cnt1,cnt2
	S cnt1=0,cnt2=$L(lin)+1
	F  S cnt1=cnt1+1 Q:(cnt1>$L(lin))!(($E(lin,cnt1)'=" ")&($E(lin,cnt1)'=$C(9)))
	F  S cnt2=cnt2-1 Q:(cnt2=0)!(($E(lin,cnt2)'=" ")&($E(lin,cnt2)'=$C(9)))
	I cnt1>cnt2 Q ""
	Q $E(lin,cnt1,cnt2) 
	;
	;----------------------------------------------------------------------	
MODIFY	; Modify the lookup documentation
	;----------------------------------------------------------------------
	I '$D(%LIBS) N %LIBS S %LIBS=$$^CUVAR("%LIBS")
	N TABLENA,%READ,%TAB,%FRAME,TOPT,vtblutbl,ZTEMP,vtitle,VLIB
	N vreccnt,vglvn,vlkey,vfsn,fsn,vdd,irec,keyopt,rdes
	N cnt,ercnt,line,KEYOPT,vlkeyc,vlen,ver,vpos
	N seq,I,X,Z,y,KVAR,ER,ET,verify,GDSP,vrec,VFMQ,PGM,SLIBS,ZDOC
	; User Table
	; Common Table
	; System Table
	S TOPT("UTBL")=$$^MSG(8205),TOPT("CTBL")=$$^MSG(8188),TOPT("STBL")=$$^MSG(8200)
	; /DES=Table Type/TYP=U/LEN=4
	S %TAB("TABLENA")=".TABLENA/TBL=TOPT("
	S %READ="@@%FN,,TABLENA/REQ,"
	S %FRAME=2
	D ^UTLREAD
	I VFMQ="Q" Q
	S SLIBS=%LIBS
	D LOADFILE(TABLENA,"")
	;
MODIFY1	 ; Prompt for table name   
	;
	N DOCFID,TABLE,vhdg,mag1,mag2,msg3,gbl
	S %LIBS=SLIBS
	; Table
	; File Name
	; Description
	S msg1=$$^MSG(8229),msg2=$$^MSG(5204),msg3=$$^MSG(8350)
        S vhdg=msg1_$J(" ",14-$L(msg1))_msg2_$J(" ",20-$L(msg2))_msg3
        S %TAB("TABLE")="/DES="_TOPT(TABLENA)_"/TYP=U/LEN=12/TBL=vtblutbl("
	S %READ="@@%FN,,TABLE/REQ,"
	S %FRAME=2
     	D ^UTLREAD 
	I $D(vlkey) K @vlkey
	I VFMQ="Q" Q
        K OLNTB,vinf,vlkey,vhdg
	I '$D(vtblutbl(TABLE)) Q
	S DOCFID=$P(vtblutbl(TABLE),"|",2)
	I DOCFID="" Q
        ;
        D fsn^DBSDD(.vfsn,DOCFID)
        ; There are multiple level tables
        S vlkey=$P(vfsn(DOCFID),"|",3) 
	S gbl=$P(vfsn(DOCFID),"|",2)
	S VLIB=$P(vfsn(DOCFID),"|",11)
        N ddref,des,typ,len,z,tbl,diacc
        ;
MODIFY2 ;  Prompt for key option
	;
        I $L(vlkey,",")>1 G MULTIKEYS
	S ddref=VLIB_"."_DOCFID_"."_vlkey        ; format data item name
        S X=$G(vdd(ddref)) I X="" S X=$$DI^DBSDD(ddref,"",.vdd) I ER Q  ; Get i^
        ;
        S des=$P(X,"|",10),typ=$P(X,"|",9),len=$P(X,"|",2)
	I len<4 S len=4   
        S %TAB("KEYOPT")="/DES="_des_"/LEN="_len_"/TYP=T"_"/TBL=["_DOCFID_"]:NOVAL/XPP=D KEYOPT^DBSDOC4"       ;      /XPR=D KEYOPT1^DBSDOC4"
        ;
        S %READ="@@%FN,,KEYOPT/REQ,"
        S %FRAME=2,KEYOPT="ALL"
        D ^UTLREAD I VFMQ="Q" G MODIFY1
	K ZDOC
	N acnt,X,Q,v,exe,vdel
	;
	S keyopt="",acnt=1
        I KEYOPT="ALL" D
	.	S RM=$$^MRPC007(.vrec,1,DOCFID)
	.	I $G(RM)'="" Q
	.	S vreccnt=$L(vrec,"|")
	.	F irec=1:1:vreccnt D
	..		S keyopt=$P(vrec,"|",irec) I keyopt="" Q
	..		S rdes=$P(keyopt,$C(9),2)
	..		S keyopt=$P(keyopt,$C(9),1)
	..		S ZDOC(acnt)="",acnt=acnt+1
	..		S ZDOC(acnt)="["_DOCFID_"]  ["_keyopt_"]"_$C(9)_rdes,acnt=acnt+1
	..		S ZDOC(acnt)="",acnt=acnt+1
        ..              S aline=""
        ..              I $O(^DBTBL(%LIBS,12,DOCFID,keyopt,aline))="" S ZDOC(acnt)="",acnt=acnt+1 Q
        ..              F  S aline=$O(^DBTBL(%LIBS,12,DOCFID,keyopt,aline)) Q:aline=""  D
        ...                     S ZDOC(acnt)=^DBTBL(%LIBS,12,DOCFID,keyopt,aline),acnt=acnt+1
	..		;  K X,Q,vsql,exe,v
	..		;  S X="[DBTBL12]%LIBS="_%LIBS_" AND "_"[DBTBL12]FID="_DOCFID_" AND "_"[DBTBL12]CODE="_keyopt
	..		;  D ^DBSQRY
	..		;   S vsql=$$OPEN^DBSFETCH(.exe,"DBTBL12","SEQ,DOC",.Q) I vsql=0 Q
	..		;  F  S vsql=$$FETCH^DBSFETCH(.exe,.v) Q:vsql=0  D
	...		; 	S ZDOC(acnt)=$P(v,"|",2),acnt=acnt+1
        I KEYOPT'="ALL" D
	.	S ZDOC(acnt)="",acnt=acnt+1
        .       S RM=$$^MRPC007(.vrec,1,DOCFID)
        .       I $G(RM)'="" Q
	.	S vrec="|"_vrec
	.	S vdel="|"_KEYOPT_$C(9)
	.	S rdes=$P(vrec,vdel,2),rdes=$P(rdes,"|",1)
	.	S ZDOC(acnt)="["_DOCFID_"]  ["_KEYOPT_"]"_$C(9)_$P(rdes,"|",1),acnt=acnt+1
        .       S ZDOC(acnt)="",acnt=acnt+1
        .       S aline=""
        .       I $O(^DBTBL(%LIBS,12,DOCFID,KEYOPT,aline))="" S ZDOC(acnt)="",acnt=acnt+1 Q
        .       F  S aline=$O(^DBTBL(%LIBS,12,DOCFID,KEYOPT,aline)) Q:aline=""  D
        ..              S ZDOC(acnt)=^DBTBL(%LIBS,12,DOCFID,KEYOPT,aline),acnt=acnt+1
	.	;  K X,Q,vsql,exe,v
	.	;  S X="[DBTBL12]%LIBS="_%LIBS_" AND "_"[DBTBL12]FID="_DOCFID_" AND "_"[DBTBL12]CODE="_KEYOPT
	.	;  D ^DBSQRY
	.	;  S vsql=$$OPEN^DBSFETCH(.exe,"DBTBL12","SEQ,DOC",.Q) I vsql=0 Q
	.	;  F  S vsql=$$FETCH^DBSFETCH(.exe,.v) Q:vsql=0  D
	..		;  S ZDOC(acnt)=$P(v,"|",2),acnt=acnt+1
        ;
UPDATE	;  Involve VMS editor to edit documentation
	;
	D ^DBSWRITE("ZDOC",3,22,99999,"","DOCUMENT")
	I VFMQ="Q" G MODIFY2
	N cont,defined,linep,linen
        S cnt="",ver=0,ercnt=0,ER=0,cont=0
        s vtitle="["_DOCFID_"]",vlen=$L(vtitle),seq=1
        F  S cnt=$O(ZDOC(cnt)) Q:cnt=""  D  Q:cont
        .       S line=$$SKIP(ZDOC(cnt))
	.	S linep=$$SKIP($G(ZDOC(cnt-1)))
	.	S linen=$$SKIP($G(ZDOC(cnt+1)))
        .       I (line=""),(linep="") Q
	.	I (line=""),$E(linep,1,$L(vtitle))=vtitle Q
        .       I (line=""),(linen="") Q
        .       I (line=""),$E(linen,1,$L(vtitle))=vtitle Q
	.	S line=ZDOC(cnt)
        .       I $E(line,1,$L(vtitle))=vtitle D  Q
	..		S ER=0,RM=""
	..		S vlkeyc=$P(line,"[",3),vlkeyc=$P(vlkeyc,"]",1),seq=1 
	..		S defined=$$EXIST^DBSEDIT(DOCFID,vlkeyc,95,.vfsn)
        ..	        ; Invalid ~p1 - ~p2
        ..	        I 'defined S ER=1,ercnt=ercnt+1,RM(ercnt)=$$^MSG(8316,des,vlkeyc)
	..		; Invalid ~p1 - ~p2. Modify it?
	..		I ER S cont=1 W $$MSG^%TRMVT($$^MSG(8317,des,vlkeyc),0,1) 
	..		I 'ER  D
	...			;  I vlkeyc="*" K ^DBTBL(%LIBS,12,DOCFID,vlkeyc) Q
	...			;  K X,Q
	...			;  S X="[DBTBL12]%LIBS="_%LIBS_" AND "_"[DBTBL12]FID="_DOCFID_" AND "_"[DBTBL12]CODE="_vlkeyc
	...			;  D ^DBSQRY
	...			;  D DELALL^DBSINS("DBTBL12",.Q)
	...			K ^DBTBL(%LIBS,12,DOCFID,vlkeyc)
        .        I 'ER D
	..		;  S VREC=%LIBS_"|"_DOCFID_"|"_vlkeyc_"|"_seq_"|"_line
	..		;  D INS^DBSINS("DBTBL12","%LIBS,FID,CODE,SEQ,DOC",VREC,0,,.vsfn,.vdd)
	..		S ^DBTBL(%LIBS,12,DOCFID,vlkeyc,seq)=line
	..		S seq=seq+1	
	I cont K RM G UPDATE 
	G MODIFY2
	Q
	;
	;--------------------------------------------------------------------
FDESC(%LIBS,FID)	;  Get file description
	;-------------------------------------------------------------------
	N VAR
	S VAR=$$VER^DBSTBL("[DBTBL1]",FID,"T")
	S VAR=$P(VAR," ",2,$L(VAR))
	Q VAR
	;
	;-------------------------------------------------------------------
RECDESC(%LIBS,FID,CODE)   ; Get record description
	;------------------------------------------------------------------
	N VAR,acckeys
	D fsn^DBSDD(.fsn,FID)
	S acckeys=$P(fsn(FID),"|",3)
	I $L(acckeys,",")>1 D MULDESC Q VAR
	S VAR=$$VER^DBSTBL("["_FID_"]",CODE,"T")
	S VAR=$P(VAR," ",2,$L(VAR))
        Q VAR
	;
        ;-------------------------------------------------------------------
MULDESC	; Get record description
        ;------------------------------------------------------------------
	N gbl,i,key1
	S gbl=$P(fsn(FID),"|",2)_")"
	F i=1:1:$L(acckeys,",") D
	.	S key1=$P(acckeys,",",i)
	.	S @key1=$P(CODE,"_",i)
	S VAR=$P($G(@gbl),"|",1)
        Q 
	;------------------------------------------------------------------
PROMPT(%LIBS,fid)   ; Get description for last access key
	;------------------------------------------------------------------
	N vlkey,acckeys
        D fsn^DBSDD(.fsn,fid)
        S acckeys=$P(fsn(fid),"|",3),vlkey=$P(acckeys,",",$L(acckeys,","))
        N ddref,DES
        ;
        S ddref=%LIBS_"."_fid_"."_vlkey        ; format data item name
        S DES=$G(vdd(ddref)) I DES="" S DES=$$DI^DBSDD(ddref,"",.vdd) I ER Q
        ;
        S DES=$P(DES,"|",10)
	I $L(acckeys,",")=1 Q DES
	N i,DES1,keynum
	S keynum=$L(acckeys,",")	
	F i=1:1:keynum-1 D
	.	S vlkey=$P(acckeys,",",keynum-i)
	.        ;
        .	S ddref=%LIBS_"."_fid_"."_vlkey        ; format data item name
        .	S DES1=$G(vdd(ddref)) I DES1="" S DES1=$$DI^DBSDD(ddref,"",.vdd) I ER Q
        .	S DES=$P(DES1,"|",10)_"_"_DES
	Q DES
	;
	;------------------------------------------------------------------
LOADFILE(TABLENA,vsig)  ; load lookup global into a local variable
        ;------------------------------------------------------------------
        ;
        n vtblfile,vindex,vsucee,i,keys
        S vtblfile=""
        F  D  Q:vtblfile=""
        .       S vtblfile=$O(^XDBREF("DBTBL1.GLOBAL",%LIBS,TABLENA,vtblfile))
        .       I vtblfile="" Q
        .       S vindex=$$GETKEY(vtblfile)
        .       S vindex=$P(vindex,",",1)
        .       I vindex'["""" Q
	.	D fsn^DBSDD(.fsn,vtblfile) I ER Q
	.	S keys=$P(fsn(vtblfile),"|",3)       ;     I $L(keys,",")>1 Q
        .       S vindex=$E(vindex,2,$L(vindex)-1)
        .       I $G(vsig)="" D
        ..              I $G(vtblutbl(vindex))="",$G(vtblutbl(vindex_"_1"))="" S vtblutbl(vindex)=vtblfile_$J(" ",20-$L(vtblfile))_$$GETDESC(vtblfile)_"|"_vtblfile Q
        ..              I $G(vtblutbl(vindex))'="" S vtblutbl(vindex_"_1")=vtblutbl(vindex)
        ..              K vtblutbl(vindex)
        ..              F i=2:1 S vsucee=$$SETLOCAL(vindex,vtblfile,i) Q:vsucee
        .       I $G(vsig)=1 D
        ..              I $G(vtblutbl(vindex))="" S vtblutbl(vindex)=vtblfile_$J(" ",20-$L(vtblfile))_$$GETDESC(vtblfile)_"|"_vtblfile Q
        Q
        ;--------------------------------------------------------------------
SETLOCAL(vindex,vtblfile,i) ; Assign value to local variable
        ;--------------------------------------------------------------------
        ;
        I $G(vtblutbl(vindex_"_"_i))="" S vtblutbl(vindex_"_"_i)=vtblfile_$J(" ",20-$L(vtblfile))_$$GETDESC(vtblfile)_"|"_vtblfile,vsucee=1
        E  S vsucee=0
        Q vsucee
	;
	;--------------------------------------------------------------------
MULTIKEYS	;  Multiple Accessing Keys
	;--------------------------------------------------------------------
	;
	;
	K %READ,%TAB,KEYOPT
	S %READ="@@%FN,,"
	F i=1:1:$L(vlkey,",") D
	.	S diacc=$P(vlkey,",",i)
	.	S ddref=VLIB_"."_DOCFID_"."_diacc        ; format data item name
        .	S X=$G(vdd(ddref)) I X="" S X=$$DI^DBSDD(ddref,"",.vdd) I ER Q  ; Get i^
        .	;
        .	S des=$P(X,"|",10),typ=$P(X,"|",9),len=$P(X,"|",2)
	.	I len<4 S len=4   
        .	S z=$e($P((","_$P(gbl,"(",2)_","),(","_diacc_","),1),2,9999)
        .	I z'="" S z=z_","
        .	S tbl=$$DBLQ^DBSEDIT($P(gbl,"(",1)_"("_z)
	.	I i=$L(vlkey,",") S tbl="["_DOCFID_"]"
        .	S %TAB("KEYOPT("_i_")")="/DES="_des_"/LEN="_len_"/TYP=T"_"/TBL="_tbl_"/XPP=S "_diacc_"=X"       ;      /XPR=D KEYOPT1^DBSDOC4"
        .	S %READ=%READ_"KEYOPT("_i_")/REQ,"
        S %FRAME=2
        D ^UTLREAD I VFMQ="Q" G MODIFY1
	K ZDOC
	S KEYOPT=KEYOPT(1)
	F i=2:1 Q:'$D(KEYOPT(i))  S KEYOPT=KEYOPT_"_"_KEYOPT(i)
	S vgbl=gbl_")"
	S rdes=@vgbl,rdes=$P(rdes,"|",1)
	S acnt=1
	S ZDOC(acnt)="",acnt=acnt+1
	S ZDOC(acnt)="["_DOCFID_"]  ["_KEYOPT_"]"_$C(9)_$P(rdes,"|",1),acnt=acnt+1
        S ZDOC(acnt)="",acnt=acnt+1
        S aline=""
        I $O(^DBTBL(%LIBS,12,DOCFID,KEYOPT,aline))="" S ZDOC(acnt)="",acnt=acnt+1 G UPDATE
        F  S aline=$O(^DBTBL(%LIBS,12,DOCFID,KEYOPT,aline)) Q:aline=""  D
        .	S ZDOC(acnt)=^DBTBL(%LIBS,12,DOCFID,KEYOPT,aline),acnt=acnt+1	
	G UPDATE
	Q
PPOST	
	;	
	;  S DOCFID="STBLPCM2"
	;  d fsn^DBSDD(.fsn,DOCFID)
	;  S acckeys=$P(fsn(DOCFID),"|",3)
	N gbl1,keyopt,zkeynum,i,gbl,ackey
	S gbl1=$P(fsn(DOCFID),"|",2)_","
	S zkeynum=$L(acckeys,",")
	F i=1:1:zkeynum D
	.	S ackey(i)=$P(acckeys,",",i)
	.	S gbl(i)=$P(gbl1,","_ackey(i)_",",1)_","_ackey(i)_")"
	S @ackey(1)="",ii=1
	F  S @ackey(1)=$O(@gbl(1)) Q:@ackey(1)=""  D
	.	S keyopt(ii)=@ackey(1)
	.	I zkeynum=1 s keyopt1(ii)=keyopt(ii),ii=ii+1 Q
	.	E  D KEYOPTG(2)
	Q
KEYOPTG(i)
	S @ackey(i)=""
	F  S @ackey(i)=$O(@gbl(i)) Q:@ackey(i)=""  D
	.	I '$D(keyopt(ii)) S keyopt(ii)=$P(keyopt(ii-1),"_",1,i-1)
	.	S keyopt(ii)=keyopt(ii)_"_"_@ackey(i)
	.	I zkeynum=i S keyopt1(ii)=keyopt(ii),ii=ii+1 Q
	.	E  D KEYOPTG(i+1)
	Q
	;
	;---------------------------------------------------------------
GETDESC(fid) ; get file description  
	;---------------------------------------------------------------
	Q $G(^DBTBL(%LIBS,1,fid))
	;
	;---------------------------------------------------------------
GETKEY(fid) ; get accessing keys 
	;--------------------------------------------------------------
	Q $G(^DBTBL(%LIBS,1,fid,16))