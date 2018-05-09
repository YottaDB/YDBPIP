DBE	;;DBS - UTL - V5.0 - Direct Mode Database Editor
	;;Copyright(c)1995 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/02/95 10:37:00 - ZENGF
	;     ORIG:  FSANCHEZ - 28 DEC 1992
	;    CALLS:  ^DBSEDIT,SCADRV,UTLO,UTLREAD
	;     DESC:  This utility is used to view or modify a DATA-QWIK
	;	     database in direct mode.
	;
	; *** NOTE ***
	; This procedure will be obsoleted in FW4.0 ... do not add any more
	; uses of it.
	; ************	
	;
	;---- Revision History ------------------------------------------------
	; 02/12/2009 - RussellDS - CR38215/35741
	;	* Removed majority of code, since no longer used
	;	* Fixed use of ^DBINDX to handle null for unicode
	;	* Removed old revision history
	;
	;-----------------------------------------------------------------------
	;
	Q
	;
	;----------------------------------------------------------------------
GETLIST(file,expr,comp)	; Generate a list base on wildcard input and qualifiers
	;----------------------------------------------------------------------
	;
	S ER=0
	;
	N req,nodes,except,I,qfy,val
	N libr,maxCharV,nullChar,sel,nod,pos,di,z
	;
	S maxCharV=$$getPslValue^UCOPTS("maxCharValue")
	S nullChar=$$BYTECHAR^SQLUTL(254)
	;
	S nodes="",except="",req="",sel=""
	S expr=$$UPPER^SCAUTL($G(expr))
	;
	F I=1:1:$L(expr,"/") D
	.	;
	.	S z=$P(expr,"/",I) I z="" Q
	.	S qfy=$P(expr,"=",1),val=$P(expr,"=",2,99)
	.	;
	.	I $E("REQ",1,$L(qfy))=qfy S req=1 Q
	.	I $E("NODES",1,$L(qfy))=qfy S nodes=val Q
	.	I $E("EXCEPT",1,$L(qfy))=qfy S except=val Q
	.	; Unrecognized Qualifier ~p1
	.	I qfy'="" S ER=1,RM=$$^MSG("5517",qfy) Q
	;
	I ER Q ""
	;
	S z=$$LIB^DBSDD(file,"","",.vdd)		; Resolve Implicit
	S libr=$P(z,".",1),file=$P(z,".",2) I file="" Q ""
	;
	I '$D(vfsn(file)) D fsn^DBSDD(.vfsn,file) Q:ER
	;
	S sel=$P(vfsn(file),"|",3)			; Access keys
	;
	I nodes="" D
	.	;
	.	I req S sel=$G(^DBTBL(libr,1,file,102)) Q
	.	S z="" 
	.	F  S z=$O(^DBINDX(libr,"STR",file,z)) Q:z=""  I z'=nullChar S nodes=nodes_z_","
	;
	I (expr="*")!(expr="") D
	.	N sel1 S sel1=$G(^DBTBL(libr,1,file,102))
	.	F I=1:1:$L(sel1,",") D
	..		I '$$CONTAIN(sel,$P(sel1,",",I)) S sel=sel_","_$P(sel1,",",I) 
	S pos="",di=""
	;
	F I=1:1 S nod=$P(nodes,",",I),pos="" Q:nod=""  D
	.	F  S pos=$O(^DBINDX(libr,"STR",file,nod,pos)),di="" Q:pos=""  I pos'=nullChar,pos?1N.N  D
	..		F  S di=$O(^DBINDX(libr,"STR",file,nod,pos,di)) Q:(di="")!(di=$C(maxCharV))  D
	...			I '$G(comp),$$CMP^DBSDD(file_"."_di)'="" Q
	...			I '$$CONTAIN(sel,di) S sel=sel_","_di
	;
	I except'="" F I=1:1:$L(except,",") S di=$P(except,",",I) I di="" I $$CONTAIN(sel,di) S sel=$$SUBLIST(sel,di)
	;
	F  Q:$E(sel)'=","  S sel=$E(sel,2,$L(sel))
	Q sel
	;
        ;-----------------------------------------------------------------------
SUBLIST(LIST,DI)        ; Subtract a Data Item from a list
        ;-----------------------------------------------------------------------
	;
	N I,z
	F I=1:1:$L(LIST,",") I $P(LIST,",",I)=DI D  Q
	.	S z=$P(LIST,",",I+1,999)
	.	S LIST=$P(LIST,",",1,I-1)
	.	I LIST'="",z'="" S LIST=LIST_","
	.	S LIST=LIST_z
	;
	Q LIST
	;
CONTAIN(A,B)	Q (","_A_",")[(","_B_",")
	;
	;
	;--------------------------------------------------------------------
FILEPP	; File Name Post processor
	;-------------------------------------------------------------------
	; Only called by RUN^SRVSUM.  No longer has any purpose.  Once that
	; call is removed, remove this section.
	Q