DBSLOG(file,%O,UX)	;Public ; Log the file changes
	;;Copyright(c)2001 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/07/01 17:13:16 - MATTSON
	; ORIG:	CHAPYALAJ - 04/06/94
	;
	; Files the changes to any of the files to the ^LOG table.
	;
	; ARGUMETS:
	;     . file    Name of the file being updated or created /TYPE=T/
	;
	;     . %O      Option (Create,Modify,Delete) 		  /TYPE=N/
	;		Required if %O=0 OR %O=3
	;
	;     . UX      Update array 				  /TYPE=T/
	;
	;
	; INPUTS:
	;     .fsn      Returns file header information.
	;	
	; RETURNS:
	;     .ER       Error flag 				 /TYPE=N/COND
	;     .RM       Error message				 /TYPE=T/COND
	;
	;---- Revision History ------------------------------------------------
	; 08/30/06 - RussellDS - CR22720
	;	     Replaced call to $$LOWER^SCAUTL with $$LOWER^UCGMR to
	;	     avoid bootstrap issues.
	;
	; 05/11/06 - Allan Mattson - CR20048
	;            Replaced occurrences of $C(255) with the value returned
	;            from $$getPslValue^UCOPTS("maxCharValue").
	;
	;            Replaced calls to $$LOWER^%ZFUNC with $$LOWER^SCAUTL.
	;
	;            Deleted pre-2001 revision history.
	;
	; 01/09/06 - RussellDS - CR18906
	;	     Modify LOG.SEQ change to increase size to 18 to match
	;	     additional change to DBSLOGIT.
	;
	; 01/05/06 - RussellDS - CR18400
	;	     Modified LOG.SEQ to be unique number to correspond to new
	;	     code in DBSLOGIT.PROC.
	;
	; 01/16/01 - Allan Mattson - 43694 (IPB#624)
	;            Modified to record the old value(s) of data items that
	;            have been modified (%O=1).
	;
	;            Eliminated subroutine IMPLIB and references to DATA-QWIK
	;            libraries (%LIBS, DLIB, etc.).
	;
	;            General clean-up.
	;
	;----------------------------------------------------------------------
INIT	;Private
	;----------------------------------------------------------------------
	;
	; Missing file name parameter
	I $G(file)="" S ER=1,RM=$$^MSG(1760) Q
	;
	N ackeys,ditem,filetyp,fsn,I,key,key1,maxCharV,type
	N vcurval,vkeys
	S ER=0
	;
	I '$D(%LOGID) N %LOGID S %LOGID=$$LOGID^SCADRV
	I %LOGID Q
	;
	S maxCharV=$$getPslValue^UCOPTS("maxCharValue")
	;
	I '$D(%O) N %O S %O=$D(UX)#10
	;
	I '$D(fsn(file)) D fsn^DBSDD(.fsn,file)	
	S ackeys=$P($G(fsn(file)),"|",3)
	S filetyp=$P($G(fsn(file)),"|",4)
	;
	new object
	S object=$TR($$LOWER^UCGMR(file),"_","")
	S object=$S('$D(@object):0,1:@object)
	;
	S vkeys=""
	F I=1:1:$L(ackeys,",") D
	.	S key=$P(ackeys,",",I),type=""
	.	I key'="" S type=$$TYP^DBSDD(file_"."_key)
	.	I key'=+key!(key'="") S key1=key
	.	I key1="" S key1=$C(maxCharV)
	.	I key'="" D
	..		I $D(vobj(object)) S key=vobj(object,-2-I) Q
	..		S key=@key
	..		;
	.	I "TUF"[type S key=""""_key_""""
	.	I "DC"[type S key=$$EXT^%ZM(key,type)
	.	S vkeys=vkeys_","_key	
	;
	S vkeys=$E(vkeys,2,$L(vkeys))
	I %O=1 D UX Q
	;
	;----------------------------------------------------------------------
LOG	;Private ;Log occurances of file updates if %O=0 (create mode) 
	;----------------------------------------------------------------------
	;
	N ov,nv,piece,diname,data,sname,flist,dlist,fullfile
	;
	S sname=$P($G(fsn(file)),"(",1)
	S (diname,ditem,ov,nv)=""
	S piece=0
	;
	I %O=0,filetyp=1 D
	.	X "S data=$G("_sname_")"
	.	F  S piece=$O(^DBINDX("SYSDEV","STR",file,key1,piece))  Q:piece=""  D
	..		F   S diname=$O(^DBINDX("SYSDEV","STR",file,key1,piece,diname))  Q:diname=""  D
	...			I ^DBINDX("SYSDEV","STR",file,key1,piece,diname)="" D
	....				S fullfile=file_"."_diname
	....				I $$OFS^DBSDD(fullfile)="" S $P(ditem,",",piece)=diname
	.	D BUILD
	;
	I %O=0,filetyp'=1 D
	.	S (data,LAST,ditem,DVAL,DILIST,DVALLIST)="" 
	.	F  S ditem=$O(^DBTBL("SYSDEV",1,file,9,ditem))  Q:ditem=""  D
	..		S VALUE=^DBTBL("SYSDEV",1,file,9,ditem)
	..		S NOD=$P(VALUE,"|",1) Q:NOD["*"
	..		S POS=$P(VALUE,"|",21)
	..		I NOD="",POS="" Q
	..		;
	..		S sname=$P($G(fsn(file)),"(",1)
	..		S DILIST=DILIST_","_ditem
	..		;
	..		I NOD?1N.N X "S sname=$G("_sname_"("_NOD_"))"
	..		E  X "S sname=$G("_sname_")"
	..		;
	..		I NOD=0,POS="" S POS=1
	..		S DVAL=$P(sname,"|",POS)
	..		S DVALLIST=DVALLIST_"|"_DVAL
	..		;
	.	S ditem=$E(DILIST,2,$L(DILIST))
	.	S data=$E(DVALLIST,2,$L(DVALLIST))
	.	D BUILD
	;
	D FILE
	Q    
	;
	;----------------------------------------------------------------------
BUILD	;Private ;Builds data item and value list without null fields if %O=0
	;----------------------------------------------------------------------
	;
	N di,dv,val
	;
	S (flist,dlist)=""
	F I=1:1:$L(ditem,",") D
	.	S di=$P(ditem,",",I)
	.	S dv=$P(data,"|",I)
	.	;
	.	I di'="",dv'="" D
	..		S dv=$$QUOTE(dv)
	..		S val=file_"."_di
	..		S type=$$TYP^DBSDD(val)
	..		I "TUF"[type S dv=""""_dv_""""
	..		I "C"[type S dv=$$EXT^%ZM(dv,type)
	..		S flist=flist_","_di,dlist=dlist_"|"_dv
	;
	S flist=$E(flist,2,$L(flist))
	S dlist=$E(dlist,2,$L(dlist))
	S ditem=flist,nv=$TR(dlist,"|",$C(1))
	Q
	;
	;----------------------------------------------------------------------
UX	;Private ; Update individual entries if %O=1 (update mode)
	;----------------------------------------------------------------------
	;
	N ditem,type,nv,ov,val,X
	;
	S ditem=""
	F  S ditem=$O(UX(file,ditem))  Q:ditem=""  D
	.	S val=file_"."_ditem
	.	S type=$$TYP^DBSDD(val)
	.	S X=UX(file,ditem)
	.	S ov=$P(X,"|",1)
	.	S nv=$P(X,"|",2)
	.	S ov=$$QUOTE(ov)
	.	S nv=$$QUOTE(nv)
	.	I "TUF"[type S nv=""""_nv_"""",ov=""""_ov_""""
	.	D FILE
	Q
	;
	;----------------------------------------------------------------------
FILE	;Private ; Files the data to the Log file	
	;----------------------------------------------------------------------
	;
	N date,flag,idi,inv,iov,seq,subseq,tmpdi,tmpnv,tempov,time
	;
	S date=$H
	S time=$P(date,",",2)
	S date=$P(date,",",1)
	;
	F  D  Q:(seq>0)
	.	S seq=$$GETSEQ^SQLDD("LOG")*100
	.	I $D(^LOG(date,seq)) H 1 S seq=0 Q
	.	S ^LOG(date,seq)=file_"|"_ackeys_"|"_vkeys_"|"_%O_"|"_$G(%UID)_"|"_$G(TLO)_"|SYSDEV|"_time
	;
	I $L(ditem)+$L(nv)+$L(ov)'>255 S ^LOG(date,seq,1)=ditem_"|"_nv_"|"_ov Q
	;
	S (tmpdi,tmpnv,tmpov)=""
	S flag=0,subseq=1
	;
	F I=1:1:$L(ditem,",") D
	.	S idi=$P(ditem,",",I)
	.	S inv=$P(nv,$C(1),I)
	.	S iov=$P(ov,$C(1),I)
	.	;
	.	I $L(tmpdi)+$L(tmpnv)+$L(idi)+$L(inv)+$L(iov)>255 D
	..		I 'flag S ^LOG(date,seq,subseq)=$E(tmpdi,2,$L(tmpdi))_"|"_$E(tmpnv,2,$L(tmpnv))_"|"_$E(tmpov,2,$L(tmpov))
	..		I flag S ^LOG(date,seq,subseq)=tmpdi_"|"_tmpnv_"|"_tmpov
	..		S flag=1,subseq=subseq+1
	..		S tmpdi=idi
	..		S tmpnv=inv
	..		S tmpov=iov
	..		;
	.	E  D
	..		S tmpdi=tmpdi_","_idi
	..		S tmpnv=tmpnv_$C(1)_inv
	..		S tmpov=tmpov_$C(1)_iov
	;
	I tmpdi'="",tmpnv'=tmpov S ^LOG(date,seq,subseq)=tmpdi_"|"_tmpnv_"|"_tmpov
	Q
	;
	;----------------------------------------------------------------------
QUOTE(dv);Add	quotes to data item if the data already has quotes. 
	;----------------------------------------------------------------------- 
	N I,char,qdata 
	S qdata="" 
	;
	F I=1:1:$L(dv) D 
	.       S char=$E(dv,I) 
	.       I char="""" S char=$C(34)_char 
	.       S qdata=qdata_char 
	.       ; 
	S dv=qdata 
	Q dv 
