SQLFMT(exe)
	;;Copyright(c)2001 Sanchez Computer Associates, Inc.  All Rights Reserved - 02/21/01 13:05:45 - CHENARDP
	; ORIG:	SPIER - 12/04/95
	; DESC:	Format DI from results table of SQL select
	;
	; KEYWORDS:	SQL
	;
	; PARAMETER:
	;
	;	. exe	Procedural code		/TYP=T/REQ/MECH=REFARR:RW
	;
	;---------- Revision History ------------------------------------------
	; 2009-22-06, Sha Mirza  CR 40255
	;	     Modified  section bldhdg to call D CONAGGR^SQLODBC(...)			
	;	     which calculate TYP, LEN, and DEC for aggregate or functions.
	;
	; 09/24/07 - Giridharanb - CR28353
	;	     Modified section HEADING to call COLLIST^DBSDD to resolve "*"
	;
	; 07/10/06 - RussellDS - CR22121
	;	     Modified maximum length checking to use byte string method
	;	     by calling BSL^SQLUTL to make Unicode compliant.
	;
	; 01/06/04 - Pete Chenard - 13875
	;	     Added support for result sets up to 1Mb.
	;
	; 04/20/04 - Meena Kadam - 9459
	;	     Modified the "bldhdg" section to return values of aggregate
	;	     functions where the size of the value returned is greater 
	;	     than the size of column being aggregated in the query.
	;
	; 11/15/00 - Pete Chenard - 43811
	;	     Modified to provide support for aggregate functions
	;	     including the clauses HAVING and GROUP BY.
	;
	; 07/09/97 - Chiang - 25100
	;            Modified HEADING section to limit column heading size to
	;            32000 characters.
	;
	; 06/10/97 - Chiang - 24835
	;            Modified 'fmt' section to access format definition from
	;            STBLTFMT file.
	;
	; 03/12/97 - Chiang - 24149
	;            Modified fmt section to define row delimiter variable.
	;
	; 02/03/97 - Bob Chiang - 23630
	;            Modified fmt section to support /DATE and /DEC qualifiers
	;----------------------------------------------------------------------
	; I18N=QUIT
	;----------------------------------------------------------------------
	q:$d(vsql("fmt"))'>1			; format array not defined
	i $g(par("FORMAT"))="" Q		; output format not defined
	i vsql("fmt")="IMAGE" Q			; do not build IMAGE exe code
	n colind,totlen,len,oexpr,exp,typ,lstring,fdelim,rdelim,msk
	s colind=""
	d fmt
	s exe=exe+1
	s fmt=vsql("fmt")
	f  s colind=$o(vsql("fmt",colind)) q:colind=""  d colfmt
	;
	i $g(exe(exe))="" s exe=exe-1
	i fdelim'=9,fdelim'="" s exe=exe+1 s exe(exe)="s vd=$tr(vd,$c(9),$c("_fdelim_"))"
	q 
	;
	;----------------------------------------------------------------------
fmt	; Retrieve format qualifiers from [STBLTFMT]
	;----------------------------------------------------------------------
	N fmt  						; *** 06/10/97
	S fmt=vsql("fmt")  				; Get format type
	S fmt=$G(^STBL("TFMT",fmt))  			; Format definition
	S lstring=$p(fmt,"|",2)  			; Quote string data
	i lstring'="" s lstring="$C("_lstring_")"
	S fdelim=$p(fmt,"|",3)  			; Column delimiter
	S rdelim=$p(fmt,"|",4)  			; Row delimiter
        ;
        S msk=$P(fmt,"|",7,11)  			; Display edit mask
        ;
        I msk'="" F I=1:1:5 D
        .       ;
        .       S z=$P(msk,"|",I)
        .       I z="*" S z=$G(@$P("%MSKD,%MSKL,%MSKC,%MSKE,%MSKN",",",I)) I z="" S z=$P("MM/DD/YY,NY,12:60 AM,.",",",I)
        .       S $P(msk,"|",I)=z
	;
	; *** 02/03/97
	I $G(par("DATE"))'="" S $p(msk,"|",1)=par("DATE")
	I $G(par("DEC"))'="" S $p(msk,"|",4)=par("DEC")
	I $G(par("DEC"))'="" S $p(msk,"|",5)=par("DEC")
        ;
 	Q
	;----------------------------------------------------------------------
colfmt	; Build executable commands to format the data based upon defined format
	;
	;----------------------------------------------------------------------
	;
	S (expr,len)=""
	s typ=$p(vsql("fmt",colind),"|",1)
	s dec=$p(vsql("fmt",colind),"|",2)
	;
	I msk="" Q
	E  D  I "DLC$N"[typ,z="",fmt'="IMAGE" Q
	.	;
	.	S z=$P(msk,"|",$F("DLC$N",typ)-1) 
	.	I "DLC$N"[typ,z="",fmt'="IMAGE" q       ;Format is raw data
	.	s (oexpr,expr)="$p(vd,$C(9),"_colind_")"
	.	;
	.	I "N$"[typ S expr="$$NUM^%ZM("_expr_","_dec_","""_z_""")" Q
	.	I typ="L" S expr="$$LOG^%ZM("_expr_","""_z_""")" Q
	.	I typ="D" S expr="$$DAT^%ZM("_expr_","""_z_""")" Q
	.	I typ="C" S expr="$$TIM^%ZM("_expr_","""_z_""")" Q
	.	I "TUF"[typ,lstring'="" S expr=lstring_"_"_expr_"_"_lstring Q
	;
	I len="" S len=$L(expr)
	I len=0 Q
	I vsql("fmt")="IMAGE" D IMAGEBLD Q
	i oexpr=expr Q				;formatting will not be changed
  	;
	I $g(exe(exe))="" S exe(exe)="S "_oexpr_"="_expr Q
	I $L(exe(exe))<230 S exe(exe)=exe(exe)_","_oexpr_"="_expr Q
 	S exe=exe+1,exe(exe)="S "_oexpr_"="_expr
	;
	Q
	;
	;----------------------------------------------------------------------
IMAGE(exe)	;Public;Create Image formatted display
	;----------------------------------------------------------------------
	;
	; Given the format of individual DI in a select list, build the 
	; executable commands needed to output the data in IMAGE format.
	;
	; KEYWORDS:	
	;
	; ARGUMENTS:
	;	. exe	array of executable commands which will build
	;		the image outputt		/TYP=T/REQ/MECH=VAL
	;
	; INPUTS:
	;	. System	
	;
	;	. Data	[ddfile]di
	;
	;	. vsql("fmt"	desc of variable	/TYP=T
	;
	; RETURNS:
	;	. exe	array of mumps executable commands	/TYP=T
	;
	;
	n colind,totlen,len,oexpr,exp,typ,lstring,fdelim,rdelim,msk
	s exe=$g(exe)+1
	s colind=""
	i $G(vsql("fmt"))'="IMAGE" Q
	i $d(vsql("fmt"))'>1 Q		;nothing to format
	d fmt
	s exe(exe)="s vl=""""",exe=exe+1,totlen=0
	f  s colind=$o(vsql("fmt",colind)) q:colind=""  d colfmt
	i vsql("fmt")="IMAGE" s exe=exe+1,exe(exe)="s vd=vl"
	Q
	;
	;----------------------------------------------------------------------
IMAGEBLD	;Private;Create exe to build IMAGE mode output
	;----------------------------------------------------------------------
	;
	; Create the formated output executable commands and append to "exe"
	; array.
	;
	; KEYWORDS:	
	;
	; INPUTS:
	;	. System	
	;	. Data	[ddfile]di
	;
	;
	; RETURNS:
	;	. XX	desc of return		/TYP=T
	;
	; RELATED:
	;	. $$func^rtn - description of how related
	;
	; EXAMPLE:
	;
	S len=$p(vsql("fmt",colind),"|",3)
	S totlen=totlen+len+2
	I "N$"[typ S expr="$J("_oexpr_","_len_","_(+dec)_")"
	I "N$L"'[typ D 
	.	S expr=$s($E(expr,1,3)="$E(":expr,1:"$E("_expr_",1,"_len_")")
	.	I typ="D" S expr=expr_"_$S($l("_oexpr_")>0:"""",1:$J("""","_len_"))" Q
	.	S expr=expr_"_$J("""","_len_"-$l("_oexpr_"))"
	;
 	I $G(exe(exe))="" S exe(exe)="S vl="_expr Q
	I $L(exe(exe))<230 S exe(exe)=exe(exe)_"_""  ""_"_expr Q
	S exe=exe+1
	S exe(exe)="S vl=vl_""  ""_"_expr
	Q
	;
	;----------------------------------------------------------------------
HEADING(frm,sel,fmt,col,xcol,tok,fsn,vdd)	;public;	Build Heading array
	;----------------------------------------------------------------------
	; Returns a formatted heading string based on the heading option
	; and the format option.  Will also return a data array of column
	; information in the form:
	;
	;  col(colnum)=length|type|Decimal|Header|Justify|Spaces|Math
	;
	; KEYWORDS: database
	;
	; ARGUMENTS:
	;	. frm		File list		/REQ/DEL=44/MECH=VAL
	;	. sel		Data Item list		/DEL=44/MECH=VAL
	;	. fmt		Record Format		/NOREQ/TBL=DBTBL6E
	;	. col		Column data array	/MECH=REF:W
	;	. xcol		Column override attr	/NOREQ
	;	. tok		String Token
	;	. fsn(file)	File Attributes Record	/NOREQ/MECH=REF:RW
	;
	; RETURNS:
	;	$$ 		Heading string
	;	. ER		Error Flag
	;	. RM		Error message
        ; I18N=OFF: Excluded from I18N standards.
	S ER=0
	;
	I '$D(tok) S sel=$$SQL^%ZS(sel,.tok) I ER Q ""
	;
	S frm=$$^SQLJ(frm,,.fsn,,.tok) I ER Q ""
	;
	N I,X,cptr,dec,del,hdg,jus,len,opt,ptr,rhd,str,spa,typ,l,vsql,x,y,z
	;
 	I $G(fmt)="" S fmt="|||||3"
	E  I $E(fmt)'="|" S fmt=$G(^STBL("TFMT",fmt))  	; *** 06/10/97
        ;
	I $E(sel,1,9)="DISTINCT " S sel=$E(sel,10,$L(sel))
	E  I $E(sel,1,4)="ALL " S sel=$E(sel,5,$L(sel))
 	;
	I $E(sel)="*" S sel=$$COLLIST^DBSDD(frm,0,1,0) I ER Q ""
	;
	S del=$P(fmt,"|",3),opt=$P(fmt,"|",6)
	I del S del=$C(del)
	;
	S cptr=0,ptr=0
        ;
        F col=1:1 S str=$$GETCOL^SQLCOL(sel,.ptr) D bldhdg Q:ptr>$L(sel)!ER
	;
	I ER Q ""
	;
	S z=$O(hdg("")) I z="" Q ""
	S hdg=hdg(z) F  S z=$O(hdg(z)) Q:z=""  D  I ER Q	; Column heading
	.	I $$BSL^SQLUTL(hdg)+$$BSL^SQLUTL(hdg(z))>1024000 S ER=1,RM=$$^MSG(8566) Q
	.	S hdg=hdg_$C(13,10)_hdg(z)
	I ER Q ""
	Q hdg
	;
	;----------------------------------------------------------------------
bldhdg	;private; Build heading strings
	;----------------------------------------------------------------------
	;
	N aggfun
	S (len,typ,dec,aggfun)=""
	;
	; Fix 40255 check for str for any aggregates and call CONAGGR to 
	; set/calculate TYP, LEN, and DEC 
	I str?1A.E1"("1E.E1")" s aggfun=$p($p(str,"(",2),")",1)_"@"_$p(str,"(",1) D CONAGGR^SQLODBC(str,frm,.typ,.len,.dec)
	E  S str=$$MCOL^SQLCOL(str,frm,.len,.typ,.dec,.fsn,,,.tok,.vdd,1)
	I ER Q
	;
	;
	; aggregate functions COUNT and SUM can return a value that is
	; larger than the length of the data item being counted or summed.
	; In these cases, make the length the max for numeric fields (18).
	if aggfun'="","/COUNT/SUM/"[$P(aggfun,"@",2) set len=18
	;
	I len="" S len=$L(str)
	I typ="" S typ=$S(str=+str:"N",1:"T")
	S rhd=$S(str[$C(1):$$RHD^SQLDD($P(str,$C(1),2),,.vdd),1:"")
	S jus=$S("N$"[typ:"R",1:"L")
	S spa=2
	I aggfun'="" S rhd=aggfun
	;
	S z=$G(xcol(col))
     	;
	I $P(z,"|",1)'="" S len=$P(z,"|",1)
	I $P(z,"|",2)'="" S typ=$P(z,"|",2)
	I $P(z,"|",3)'="" S dec=$P(z,"|",3)
	I $P(z,"|",5)'="" S rhd=$P(z,"|",5)
	I $P(z,"|",6)'="" S jus=$P(z,"|",6)
	I $P(z,"|",7)'="" S spa=$P(z,"|",7)
	;If "_" occurs,concatenation was requested, change format to text
	I str["_" S typ="T" F i=1:1 q:$p(str,"_",i)=""  D
	.	I $p(str,"_",i)["""" S len=len+$L($TR(str,"""",""))
	;
	S cptr=cptr+len+spa
	S col(col)=len_"|"_typ_"|"_dec_"||"_rhd_"|"_jus_"|"_spa
	;
	I opt=5 S opt=1
	I opt=1 S z=$P(sel,",",col)			; Column Name
	E  I opt=2 S z=$TR(rhd,"@"," ")			; Description
	E  I opt=3 S z=rhd				; Heading
	E  Q
	;
	I del'="" S $P(hdg(1),del,col)=z Q
	;
	S z=z_"@"_$TR($J("",len)," ","-")		; Add Undeline
	;
	S l=11
	F I=$L(z,"@"):-1:1 D
	.	;
	.	S x=$P(z,"@",I),l=l-1
	.	I jus="R" S x=$J(x,len)
	.	E  I jus="C" S x=$J("",len\2)_x
	.	;
	.	I '$D(hdg(l)) S hdg(l)=$J("",cptr-len-spa)_$E(x,1,len)
	.	E  S hdg(l)=hdg(l)_$J("",cptr-len-spa-$L(hdg(l)))_$E(x,1,len)
	Q
	;
	;---------------------------------------------------------------------
	;
TEST	;Test utility to verify changes.
	;
        ; I18N=OFF: Excluded from I18N standards.
	N 
	S MSG="SQL Format test Utility"
	S z1=0,z2=1,z5="IMAGE"
	S z2(1)="SELECT CID,BAL,TLD,ODT,IPND,LNM,IPF FROM DEP WHERE CID<100"
	s z2(2)="SELECT * FROM UTBLBRCD"
	S %TAB("z1")="/DES=Cache/TYP=L"
	S %TAB("z2")="/DES=Select Command Option/TYP=N/TBL=z2("
	;S %TAB("z2")="/DES=Select Command Option/TYP=N"
	S %TAB("z5")="/DES=Output Format/TYP=T" ;/TBL=[DBTBL6E]"
	S %READ="@MSG/CEN/REV,,,z1,z5,z2"
	S %FRAME=2,%NOPRMT="F"
	D ^UTLREAD I VFMQ="Q" Q
  	N (z1,z2,z5)
	;
	S %UCLS="SCA"
	S (sqlsta,sqldta,sqlcnt,sqlind,tok)=""
	S mypar("OPTIMIZE")=1
	S mypar("PROTECTION")=2
	S mypar("ROWS")=3
	S mypar("CACHE")=z1
	S mypar("FORMAT")=z5
        I z2=1 s from="DEP",select="CID,BAL,TLD,ODT,IPND,LNM,IPF",qry="CID<100"
        E  S from="UTBLBRCD",select="*",qry=""
        s format=z5
        D ^DBSRPT(from,select,qry,,format,"Sqlfmt test utility",3)
        W $$SCR80^%TRMVT()
 	Q
        ; I18N=ON: Excluded from I18N standards.
