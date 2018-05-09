SQLBUF(expr,par,sqlsta,sqldta,sqlcnt,sqlind,tok)	;private; Parse MSQL Bu^ 
	;;Copyright(c)2001 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/04/01 15:27:31 - SCHEETZE
	;--------------------------------------------------------------------
	; ORIG:	
	; DESC:	SQL BUFFER command
	;
	; KEYWORDS:	SQL , DATABASE
	;
	; ARGUMENTS:
	;
	;       . expr  SQL expression 
	;       . par  Input Parameter Array            /MECH=REFNAM:R/NOREQ 
	; 
	;       ROWS=Fetch Array Count                  /DEF=1 
	;       FORMAT=Format                           /TBL=[DBTBL6E] 
	;       TIMEOUT=Seconds 
	;       MINCOST=Lowcost Threshold               /DEF=10 
	;       OPTIMIZE=Index Optimization flag        /DEF=1/TYP=L 
	;       PLAN=Save Optimization Plan             /DEF=0/TYP=L 
	; 
	;       .sqlsta SQL Code                        /MECH=REF:W 
	;       .sqldta SQL return data                 /MECH=REF:W 
	;       .sqlcnt SQL record count                /MECH=REF:W 
	;       .sqlind SQL column indicators           /MECH=REF:W 
	;       .tok    Token string                    /NOREQ 
	;
	; OUTPUTS:
	;
	;	. ER	Error indicator		/TYP=N
	;       . RM    Error message		/TYP=T
	;
	; RELATED:
	;	. $$^SQL - Call SQL parser to execute each SQL statment in
	;                  the buffer
	;
	; BUFFER [NEW | ADD | COMMIT | DELETE] buffer_name
	;        INSERT | UPDATE | PROCEDURE procedure
	;
	; BUFFER NEW buffer_name		Create new SQL buffer
	; BUFFER [ADD] buffer_name		Add SQL statement to buffer
	; BUFFER COMMIT buffer_name             Commit transactions
	; BUFFER DELETE buffer_name             Delete SQL buffer
	;
	; EXAMPLES:
	;
	;    BUFFER NEW cifnew
	;    BUFFER ADD cifnew INSERT CIF (ACN,DOB,PAD1,...) VALUES (123,...)
	;    BUFFER ADD cifnew INSERT CMBPRI (ACN,SFRE,SNDT,ADDR) VALUES (...)
	;    BUFFER COMMIT cifnew
	;
	;          or
	;
	;    BUFFER NEW cifnew INSERT CIF (ACN,DOB,PAD1,...) VALUES (123,...)
	;    BUFFER cifnew INSERT CMBPRI (ACN,SFRE,SNDT,ADDR) VALUES (...)
	;    BUFFER COMMIT cifnew
	;
	;---------- Revision History ------------------------------------------
	;
	; 12/19/06 - Shriram - CR24547
	;	     Delete section SPVOVR and call section SPVOVR^PBSMSQL in 
	;	     place of SPVOVR.		
	;	
	; 09/27/05 - RussellDS - CR17311
	;	     Eliminated call to EFD^DBSEXECU and replaced with call
	;	     to new PSL module SQLEFD
	;
	; 05/24/05 - RussellDS - CR16071
	;	     Added "CS" transaction ID to tstart.
	;		   
	;	     Removed old revision history.
	;
	; 05/11/05 - RussellDS - CR15943
	;	     Added commit and rollback calls for RDBs.
	;
	;----------------------------------------------------------------------
	N arg,i,name,rec,z
	;	
	S ER=0
	;
	I $G(%TOKEN)="" S %TOKEN=$J		; Token name
	;
	S arg=$P(expr," ",1)			; Buffer keyword
	;					; Default to ADD if not included
	I $$CONTAIN("NEW,ADD,COMMIT,DELETE,ROLLBACK",arg) S name=$P(expr," ",2),expr=$P(expr," ",3,9999)
	E  S name=arg,arg="ADD",expr=$P(expr," ",2,9999)
	;					; Convert back to raw input
	I name[$C(1) S name=$$UNTOK^%ZS(name,.tok)
	; 
	I name="" S ER=1,RM=$$^MSG(8552) Q	; Missing buffer name
	;
	S rec=+$G(^DBBUF(%TOKEN,name))		; Buffer existed status
	I arg="ROLLBACK" K ^DBBUF(%TOKEN,name) Q  ; BUFFER ROLLBACK
	;
	I rec=0,arg="DELETE" Q  		; Buffer not on file
	I rec=0,(arg="COMMIT") S ER=1,RM=$$^MSG(8555,name) Q  ; Buffer empty
	;
	I arg="COMMIT" D COMMIT(name,.tok) Q	; Process buffer
	;
	I $$CONTAIN("DELETE,NEW",arg) K ^DBBUF(%TOKEN,name) S rec=0
	I $$CONTAIN("ADD,NEW",arg) D
	.	;
	.	S rec=rec+1
	.	S expr=$$UNTOK^%ZS(expr,.tok)
	.	I expr="" Q			; NEW without SQL statement
	.	S z=$$PARLIST(.par) 		; Qualifiers
	.	S ^DBBUF(%TOKEN,name)=rec	; Store SQL statement by name
	.	F i=1:400:$L(z) S ^DBBUF(%TOKEN,name,rec,i\400/10)=$E(z,i,i+399) 	; Qualifiers 01/17/2000
	.	I $G(par("EFD"))'="" S ^(-1)=$$FDAT^%ZM(par("EFD"))	; Effective date
	.	F i=1:400:$L(expr) S ^DBBUF(%TOKEN,name,rec,i\400+1)=$E(expr,i,i+399)	; 01/17/2000
	;
	; BUFFER ~p1 Contains ~p2 Records
	S sqldta=$$^MSG(8554,name,rec)		; Return message
	S sqlcnt=1
	Q
	;
	;--------------------------------------------------------------------
COMMIT(name,tok)	;private; Process a buffer for commit
	;--------------------------------------------------------------------
	N efd,expr,i,sql,vcurval,vseq,vfkey,zpar
	K verrors 					; Override array
	S ER=0
	I $D(par("EFD")) N EFD S EFD=$$FDAT^%ZM(par("EFD")) Q:ER 
	;
	I $G(TJD)="" N TJD S TJD=^CUVAR(2)		; System date
	I $D(par("EFD")),EFD=TJD K EFD
	;
	S vseq="" F  S vseq=$O(^DBBUF(%TOKEN,name,vseq)) Q:vseq=""  D  I ER Q
	.	S i=0,expr="",zpar(vseq)=""		; Get each SQL statement
	.	F i=0:.1 Q:'$d(^DBBUF(%TOKEN,name,vseq,i))  S zpar(vseq)=zpar(vseq)_^(i)	; Qualifier 01/17/2000
	.	S zpar(vseq)=zpar(vseq)_"/NOFKCHK=1"
	.	I $G(^DBBUF(%TOKEN,name,vseq,-1)) S EFD=^(-1)			; Effective date
	.	I zpar(vseq)="" S zpar(vseq)=$G(par)	; Get it from the COMMIT statement
	.	S i=0.99 F  S i=$O(^DBBUF(%TOKEN,name,vseq,i)) Q:i=""  S expr=expr_$G(^DBBUF(%TOKEN,name,vseq,i))
	.	S sql(vseq)=expr			; Save SQL statement
	I '$D(sql) Q					; Buffer empty
	;						; 
	S efd=0 I $G(EFD)>TJD S efd=1			; Effective Dated?
	I efd D ^SQLEFD(EFD,.sql) K ^DBBUF(%TOKEN,name) Q		; Save it in EFD file
	;
	;-------------------------------------------------------------------
	TStart *:transactionid="CS" 	        ; Start TP
	;						; removed tstart logic
	;
	I $$NEW^%ZT() N $ZT 			;
	S @$$SET^%ZT("ZT^SQLBUF") 		; Define error trap
	;
	N flist,spec
	S vseq="" 					; Process SQL buffer
	F  S vseq=$O(sql(vseq)) Q:vseq=""  D  Q:ER
	.	I $G(%STFHOST),'$$VALID^PBSMSQL(sql(vseq),"",.spec) S ER=1,RM=$$^MSG(7912) Q
	.	I $G(spec)=1 N TJD S TJD=$$TTL^RCHK()+1
	.	S ER=$$^SQL(sql(vseq),zpar(vseq))
	.	K flist
	;
	I ER D ERROR Q 				; Exit
	;
	D vfkey						; Verify foreign keys
	I ER D ERROR Q 				; Exit
	;
	; Apply override logic
	;
	I $D(verrors),$G(par("SPVOVR")) D SPVOVR^PBSMSQL(.verrors) I $D(verrors) D ERROR Q
	;
	I '$Tlevel S ER=1 D ERROR Q  			; TP error
	;
	TCommit:$Tlevel 				; Commit transaction
	I '$Tlevel D  Q:ER 
	. I '$D(%DB) S %DB=$$TRNLNM^%ZFUNC("SCAU_DB")
	. Q:((%DB="")!(%DB="GTM"))
	. N vER,vRM
	. S vER=$$COMMIT^%DBAPI("",.vRM)
	. I vER D
	.. 	S ER=vER
	.. 	S RM=vRM
	.. 	S sqldta=$$^MSG(646,name)
	;
	K ^DBBUF(%TOKEN,name) 				; Remove buffer
	S sqldta=$$^MSG(8553,name)			; Return message
	Q
ERROR	;
	I $Tlevel D					; Rollback transactions
	.       TRollback 
	. I '$D(%DB) S %DB=$$TRNLNM^%ZFUNC("SCAU_DB")
	. Q:((%DB="")!(%DB="GTM"))
	. N vER,vRM
	. S vER=$$EXECUTE^%DBAPI("","ROLLBACK WORK",$C(124),"",.vRM)
	. I vER S ER=vER,RM=vRM_"|"_RM
	I $G(RM)'="" S sqldta=RM Q  			; Original error message
	I $G(ET)'="" S sqldta=ET Q			; a gtm error?
	S sqldta=$$^MSG(646,name)			; Transaction rolled back
	Q
	;---------------------------------------------------------------------- 
CONTAIN(A,B)	; Return status 1 if string A contains string B 
	;----------------------------------------------------------------------
	Q (","_A_",")[(","_B_",")
	;----------------------------------------------------------------------
	Q
	;---------------------------------------------------------------------
vfkey	; Referential integrity check (missing foreign key record)
	;---------------------------------------------------------------------
	N desc1,desc2,msg,v,v1
	S v="" F  S v=$O(vfkey(v)) Q:v=""  I $D(@v)#10=0 D  Q
	.	S v1=vfkey(v),desc1=$P(v1,"(",1),desc2=$P(v1,"-> ",2)
	.	I desc1'="" S desc1=$G(^DBTBL("SYSDEV",1,desc1)) ; table desc
	.	I desc2'="" S desc2=$G(^DBTBL("SYSDEV",1,desc2)) ; table desc
	.	S msg=desc1_" -> "_desc2_" "_$P($P(v,"(",2),")",1) ; foreign key
	.	S ER=1,RM=$$^MSG(8563,msg) Q
	Q
	;----------------------------------------------------------------------
PARLIST(par)	; Pack qualifiers into a single string 
	;----------------------------------------------------------------------
	; Example:  par("DQMODE")=1,par("USING")="CID=1,BOO=2"
	;           $$PARLIST(.par) returns /DQMODE=1/USING=(CID=1,BOO=2)
	;
	;----------------------------------------------------------------------
	N p,str,val
	I $G(par)'="" Q par				; No need to convert
	I $O(par(""))="" Q ""				; Qualifier not defined
	S p="",str=""
	F  S p=$O(par(p)) Q:p=""  D
	.	S val=par(p)
	.	I val["/",val'["'" S val="'"_val_"'"	; 'DD/DD/YEAR' format
	.	I val'["=" S str=str_"/"_p_"="_val Q
	.	S str=str_"/"_p_"=("_val_")"	; USING qualifier
	Q str
	;--------------------------------------------------------------------- 
ZT	; Error handler 
	;--------------------------------------------------------------------- 
	S ER=1 
	D ZE^UTLERR 
	Q 
