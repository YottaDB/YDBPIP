SQLF(exe,vd,vi,sqlcur)	;public; Fetch Next Row in Results table
	;;Copyright(c)1999 Sanchez Computer Associates, Inc.  All Rights Reserved - 05/13/99 09:13:17 - CHIANG
	;
	; Fetch the next record in the results table.
	;
	; KEYWORDS: database
	;
	; RELATED: $$OPEN^SQLM,$$CLOSE^SQLM
	;
	; ARGUMENTS:
	;	. exe(line)	Executable code		/MECH=REFNAM:R
	;	. vd		Data Record		/MECH=REFNAM:W
	;	. vi		Column Indicators	/MECH=REFNAM:W
	;	. sqlcur	Cursor Name		/MECH=VAL
	; 
	;   INPUT:
	;	. vsql(sym)    Cursor Symbol Table	/MECH=REFNAM:RW
	;
	; RETURNS:
	;	. $$		Success code		/TYP=N
	;			0 = End of Table
	;			1-n Success
	;------ Revision History ----------------------------------------------
	; 07/10/06 - RussellDS - CR22121
	;	     Modified maximum length checking to use byte string method
	;	     by calling BSL^SQLUTL to make Unicode compliant.
	;
	; 08/30/05 - Giridharanb - 16791
	;	     Removed section RFETCH (see associated change to SQLM.m)
	;
	; 01/06/05 - Pete Chenard - 13875
	;	     Modified to support 1Mb strings.
	;
	; 11/12/04 - GIRIDHARANB - CR13163
	;	     Modified call to Rfetch to check for rdb indicator vsql("RDB")
	;	     See associated change in OPEN^SQLM to set up vsql("RDB")
	;
	; 09/13/04 - GIRIDHARANB - CR11860
	;	     Minor change to correct an undefined error on variable "FROM"
	;
	; 09/01/04 - Giridharanb - CR11003
	;	     Added section Rfetch to support fetching a result set from 
	;	     Relational database. 
	;
	; 05/13/99 - Chiang - 32656
	;            Modified FETCHBLK section to return protection indicators
	;            based on PROTECTION qualifier.
	;
	; 10/01/97 - Chiang - 26294
	;            Modified FORMAT section to not format NULL data for $
	;            (Currency) and N (Numeric) data types.
	;----------------------------------------------------------------------
	;
	I '$D(sqlcur) S sqlcur=0
	;
	I vsql(0)=100 S vd="" Q 0
	;
	F  X exe(vsql) S vsql=vsql+1 Q:vsql=0!(vsql>exe)
	I vsql=0 S vsql(0)=100,vd="" Q 0
	I $D(vsql("F")) S vd=$$FORMAT(vd)
	Q vsql(0)
	;
	;--------------------------------------------------------------------
FETCHBLK(sqlcur,exe,vsql,sqldta,sqlcnt,sqlind,rows)	; Fetch a block of records
	;--------------------------------------------------------------------
	;
	S sqlind=""
	S sqlcnt=0,vsql=$$SQLF(.exe,.sqldta,.sqlind,.sqlcur)
	I vsql=0!sqlcnt Q
	;
	S sqlcnt=1 I $G(rows)<2!(vsql(0)=100) Q
	;
	N vd,vi,vr
	S ER=0
	S vr=$P($G(vsql("F")),"|",8)
	I vr="" S vr=$C(13,10)						; Row delimiter
	E  S vr=$S($L(vr,",")=1:$C(vr),1:$C($P(vr,",",1),$P(vr,",",2)))
	; 04/30/99
	F sqlcnt=2:1:rows S vsql=$$SQLF(.exe,.vd,.vi,.sqlcur) Q:vsql=0  D  Q:ER
	.	I $$BSL^SQLUTL(sqldta)+$$BSL^SQLUTL(vr)+$$BSL^SQLUTL(vd)>1024000 S ER=1,RM=$$^MSG(2079) Q	; Buffer overflow
	.	S sqldta=sqldta_vr_vd
	.	I $G(par("PROTECTION")) S sqlind=sqlind_vr_$g(vi)	; Protection indicator
	;
	I ER,$G(RM)="" S RM="?"						; Required by service class
	I vsql=0 S sqlcnt=sqlcnt-1,vsql(100)=0
	Q
	;
	;--------------------------------------------------------------------
FORMAT(vd)	; Format record based on vsql("F") 
	;--------------------------------------------------------------------
	; des | litdel | flddel | recsep | eofdel | header | mskd | mskl | mskc
	; msk$ | mskn
	;
	N litdel,flddel,fmt,mskd,mske,mskl,mskn,mskc,typ,y
	;
	S fmt=$G(vsql("F")) I fmt="" Q vd
	S typ=$G(vsql("D")) I typ="" Q vd
	;
	S litdel=$p(fmt,"|",1)			  ; Quote string data
	S flddel=$p(fmt,"|",2)			  ; Column delimiter
	;
	S mskd=$P(fmt,"|",3)
	S mskl=$P(fmt,"|",4)
	S mskc=$P(fmt,"|",5)
	S mske=$P(fmt,"|",6)
	S mskn=$P(fmt,"|",7)
	;
	S y=0
	F  S y=$F(typ,"D",y) Q:y=0  S $P(vd,$C(9),y/2)=$$DAT^%ZM($P(vd,$C(9),y/2),mskd)
	F  S y=$F(typ,"C",y) Q:y=0  D
	.	I mskc'["DATE" S $P(vd,$C(9),y/2)=$$TIM^%ZM($P(vd,$C(9),y/2),mskc) Q
	.	; 21550= 01/01/1900 DATE0 format (ORACLE datetime format)
	.	I mskc["DATE0" S $P(vd,$C(9),y/2)=$$DAT^%ZM(21550,mskd)_$$TIM^%ZM($P(vd,$C(9),y/2),$P(mskc,"DATE0",2)) Q
	.	S $P(vd,$C(9),y/2)=$$DAT^%ZM(+$H,mskd)_$$TIM^%ZM($P(vd,$C(9),y/2),$P(mskc,"DATE",2)) Q
	F  S y=$F(typ,"L",y) Q:y=0  S $P(vd,$C(9),y/2)=$$LOG^%ZM($P(vd,$C(9),y/2),mskl)
	F  S y=$F(typ,"$",y) Q:y=0  I $P(vd,$C(9),y/2)'="" S $P(vd,$C(9),y/2)=$$NUM^%ZM($P(vd,$C(9),y/2),$E(typ,y),mske)
	F  S y=$F(typ,"N",y) Q:y=0  I $P(vd,$C(9),y/2)'="" S $P(vd,$C(9),y/2)=$$NUM^%ZM($P(vd,$C(9),y/2),$E(typ,y),mskn)
	;
	I litdel'="" D
	.	;
	.	S litdel=$C(litdel)
	.	F  S y=$F(typ,"T",y) Q:y=0  S $P(vd,$C(9),y/2)=$$QADD^%ZS($P(vd,$C(9),y/2),litdel)
	.	F  S y=$F(typ,"U",y) Q:y=0  S $P(vd,$C(9),y/2)=$$QADD^%ZS($P(vd,$C(9),y/2),litdel)
	.	F  S y=$F(typ,"F",y) Q:y=0  S $P(vd,$C(9),y/2)=$$QADD^%ZS($P(vd,$C(9),y/2),litdel)
	;
	I flddel,$F(typ,"M") S flddel=""
	I flddel,$F(typ,"B") S flddel=""
	;
	I flddel'=9,flddel S vd=$TR(vd,$C(9),$C(flddel))
	Q vd
