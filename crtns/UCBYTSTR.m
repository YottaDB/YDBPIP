UCBYTSTR	;
	;
	; **** Routine compiled from DATA-QWIK Procedure UCBYTSTR ****
	;
	; 11/08/2007 14:08 - chenardp
	;
	; I18N=QUIT
	; *******************************************************************
	; * IMPORTANT NOTE:                                                 *
	; * According to the rules that apply to PSL compiler upgrades,     *
	; * the generated M routine associated with this procedure must be  *
	; * checked into StarTeam and released with the procedure whenever  *
	; * changes are made to this procedure.                             *
	; *                                                                 *
	; * The M routine will be loaded to the mrtns directory during      *
	; * upgrades and will then be removed from that directory as part   *
	; * of the upgrade process.  Therefore, other than during an        *
	; * upgrade an mrtns version of this routine should not exist.      *
	; *                                                                 *
	; * Keep these comments as single line to ensure they exist in the  *
	; * generated M code.                                               *
	; *******************************************************************
	Q 
	;
	; ---------------------------------------------------------------------
rtChset()	; Return current character set at runtime
	I '($$getPSLSetting^UCGM("boot","charsetlevel")="") Q $$getPSLSetting^UCGM("boot","charsetlevel")
	;
	I '$$gtmLevel^UCGM(5.2) Q "M"
	;
	N chset
	;
	;  #ACCEPT CR=22270; DATE=2006-07-28; PGM=Frans S.C. Witte; GROUP=XECUTE
	XECUTE "SET chset=$ZCHSET"
	;
	Q chset
	;
	; ---------------------------------------------------------------------
ascii	; Method: ByteString.ascii(Number position)
	;
	N dummy S dummy=$$omGet^UCXOBJ(.pslMtd,"String","ascii",0)
	;
	I $$rtChset()="M" D  ; Environment does not use Unicode, ...
	.	D psl2m^UCPRIM(0,1) ; ... so generate $ascii()
	.	Q 
	E  D psl2m(0,1) ; Generate code that supports Unicode
	Q 
	;
	; ---------------------------------------------------------------------
extract	; method: String.extract(Number start,Number end)
	;
	N dummy S dummy=$$omGet^UCXOBJ(.pslMtd,"String","extract",0)
	;
	I $$rtChset()="M" D  ; Environment does not use Unicode, ...
	.	D extract^UCSTRING
	.	Q 
	E  D  ; Generate code that supports Unicode
	.	I (actual(1)="") S actual(1)=1 ; Default to position 1
	.	I (actual(2)="") S actual(2)=actual(1) ; Default to 1st parameter
	.	;
	.	; Optimize this syntax by replacing with the maximum string length
	.	E  I actual(2)=("$ZLENGTH("_objectName_")") S actual(2)=1048575
	.	;
	.	I actual(1)=actual(2) S return="$ZEXTRACT("_objectName_","_actual(1)_")"
	.	E  S return="$ZEXTRACT("_objectName_","_actual(1)_","_actual(2)_")"
	.	;
	.	I $$isLit^UCGM(objectName) S return=$$toLit^UCSTRING(return)
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
find	; Method: ByteString.find(ByteString string,Number start)
	;
	N dummy S dummy=$$omGet^UCXOBJ(.pslMtd,"String","find",0)
	;
	I $$rtChset()="M" D  ; Environment does not use Unicode, ...
	.	S actual(3)="" S actual(4)=""
	.	D find^UCSTRING
	.	Q 
	E  D psl2m(1,2) ; Generate code that supports Unicode
	Q 
	;
	; ---------------------------------------------------------------------
justify	; Method: ByteString.justify(Number fieldLength)
	;
	N dummy S dummy=$$omGet^UCXOBJ(.pslMtd,"String","justify",0)
	;
	I $$rtChset()="M" D  ; Environment does not use Unicode, ...
	.	S actual(2)="" S actual(3)="" S actual(4)=""
	.	D justify^UCSTRING
	.	Q 
	E  D  ; Generate code that supports Unicode
	.	I (""""""[actual(1)) S return=objectName Q 
	.	;
	.	D psl2m(1,1)
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
length	; Method: String.length(String delimiter)
	;
	N dummy S dummy=$$omGet^UCXOBJ(.pslMtd,"String","length",0)
	;
	I $$rtChset()="M" D  ; Environment does not use Unicode, ...
	.	D length^UCSTRING
	.	Q 
	E  D  ; Generate code that supports Unicode
	.	N char S char=actual(1)
	.	;
	.	I (char="") D
	..		;
	..		S return="$ZLENGTH("_objectName_")"
	..		Q 
	.	;
	.	E  S return="$ZLENGTH("_objectName_","_char_")"
	.	;
	.	I $$isLit^UCGM(objectName) S return=$$toLit^UCSTRING(return)
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
piece	; method: ByteString.piece(ByteString delimiter,Number start,Number end)
	;
	N dummy S dummy=$$omGet^UCXOBJ(.pslMtd,"String","piece",0)
	;
	I $$rtChset()="M" D  ; Environment does not use Unicode, ...
	.	S actual(4)=""
	.	D piece^UCSTRING
	.	Q 
	E  D psl2m(1,3) ; Generate code that supports Unicode
	Q 
	;
	; ---------------------------------------------------------------------
toPSLExpr	; Method: ByteString.toPSLExpression()
	;
	N CHAR S CHAR=$S($$rtChset()="M":"C",1:"ZCH")
	;
	I '$D(labels("vBtsPslE")) D
	.	N buf S buf=$$vopenBuf("(ByteString vVal)","ByteString.toPSLExpression")
	.	;
	.	D vaddBuff(buf,"type Boolean bValid = 0")
	.	D vaddBuff(buf,"do {")
	.	D vaddBuff(buf,"    catch vEx { // catch and ignore %GTM-E-BADCHAR exception")
	.	D vaddBuff(buf,"    }")
	.	D vaddBuff(buf,"    set bValid = ({String}vVal)?.ANP")
	.	D vaddBuff(buf,"}")
	.	;
	.	D vaddBuff(buf,"if bValid,({String}vVal).isNumber() quit vVal")
	.	D vaddBuff(buf,"if bValid quit ({String}vVal).addQuotes()")
	.	;
	.	D vaddBuff(buf,"type Number vC")
	.	D vaddBuff(buf,"type Number vE = ""$"_CHAR_"(""_ vVal.ascii()")
	.	D vaddBuff(buf,"for vC=2:1:vVal.length() set vE=vE_"",""_vVal.ascii(vC)")
	.	D vaddBuff(buf,"quit vE_"")""")
	.	;
	.	D INSERT^UCMETHOD(buf,"vBtsPslE","")
	.	K vobj(+$G(buf)) Q 
	;
	S return="$$"_"vBtsPslE"_"("_objectName_")"
	Q 
	;
	; ---------------------------------------------------------------------
translate	; Method: ByteString.translate(ByteString expr1,ByteString expr2)
	;
	N dummy S dummy=$$omGet^UCXOBJ(.pslMtd,"String","translate",0)
	;
	I $$rtChset()="M" D  ; Environment does not use Unicode, ...
	.	D psl2m^UCPRIM(1,2) ; will generate $TRANSLATE()
	.	Q 
	E  D psl2m(1,2) ; Generate code that supports Unicode
	Q 
	;
	; ---------------------------------------------------------------------
byte	; Method: Number.byte()
	;
	N dummy S dummy=$$omGet^UCXOBJ(.pslMtd,"Number","char",0)
	;
	S method="char"
	;
	I $$rtChset()="M" D  ; Environment does not use Unicode, ...
	.	D psl2m^UCPRIM(0,0) ; will generate $char()
	.	Q 
	E  D psl2m(0,0) ; Generate code that supports Unicode
	Q 
	;
	; ---------------------------------------------------------------------
chrsetEnc	; Property: Runtime.charsetEncoding
	I $$rtChset()="M" D  ; Environment does not use Unicode, ...
	.	D
	..		N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	..		S return=$$ENCODING^%CHARSET()
	..		Q 
	.	Q 
	E  S return=$$rtChset() ; Return whatever is the runtime set
	S return=$$QADD^%ZS(return,"""")
	Q 
	;
	; ---------------------------------------------------------------------
chrsetNm	; Property: Runtime.charsetName
	I $$gtmLevel^UCGM(5.2) S return="$ZCHSET"
	E  S return="""M"""
	Q 
	;
	; ---------------------------------------------------------------------
bytLimSub	; Method: String.byteLimitSubstring ( start, maxBytes)
	N ZSUBSTR S ZSUBSTR=$S($$rtChset()="M":$$mSubstr(),1:"$ZSUBSTR(")
	;
	; Generate code for all variations
	N start S start=actual(1)
	N maxBt S maxBt=actual(2)
	N isLit S isLit=0
	;
	I (maxBt="") D
	.	;if PSL.objectName.isLiteral(),start.isLiteral() set PSL.return = PSL.objectName.byteLimitSubstring( start.stripQuotes()).addQuotes() quit
	.	S return=ZSUBSTR_objectName_","_start_")"
	.	Q 
	E  D
	.	;if PSL.objectName.isLiteral(),start.isLiteral(),maxBt.isLiteral() set PSL.return = PSL.objectName.byteLimitSubstring( start.stripQuotes(), maxBt.stripQuotes()).addQuotes() quit
	.	S return=ZSUBSTR_objectName_","_start_","_maxBt_")"
	.	Q 
	;
	Q 
	;
	; ---------------------------------------------------------------------
loCase	; Method: String.lowerCase(Boolean capitalizeFirstChar)
	;
	I $$hasPSLSetting^UCGM("boot","charsetlevel"),$$getPSLSetting^UCGM("boot","charsetlevel")="" D
	.	S return="$TR("_objectName_",""ABCDEFGHIJKLMNOPQRSTUVWXYZ"""_",""abcdefghijklmnopqrstuvwxyz"""_")"
	.	Q 
	E  I $$rtChset()="M" D  ; Environment does not use Unicode, ...
	.	D loCase^UCSTRING
	.	Q 
	E  D  ; Generate code that supports Unicode
	.	N option S option=actual(1)
	.	I (""""""[option) S option=0 ; Default to 0
	.	;
	.	I $$isLit^UCGM(option) S return="$ZCONVERT("_objectName_","_$$QADD^%ZS($S(option:"T",1:"L"),"""")_")"
	.	E  S return="$ZCONVERT("_objectName_",$S("_option_":""T"",1:""L""))"
	.	I $$isLit^UCGM(objectName) S return=$$toLit^UCSTRING(return)
	.	;
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
toByteString	; Method: String.toByteString
	S return=objectName
	Q 
	;
	; ---------------------------------------------------------------------
upCase	; Method: String.upCase  Returns an upper case string
	;
	I $$hasPSLSetting^UCGM("boot","charsetlevel"),$$getPSLSetting^UCGM("boot","charsetlevel")="" D
	.	S return="$TR("_objectName_",""abcdefghijklmnopqrstuvwxyz"""_",""ABCDEFGHIJKLMNOPQRSTUVWXYZ"""_")"
	.	Q 
	E  I $$rtChset()="M" D  ; Environment does not use Unicode, ...
	.	D upCase^UCSTRING
	.	Q 
	E  D  ; Generate code that supports Unicode
	.	S return="$ZCONVERT("_objectName_",""U"")"
	.	I $$isLit^UCGM(objectName) S return=$$toLit^UCSTRING(return)
	.	Q 
	Q 
	;
	; ---------------------------------------------------------------------
mSubstr()	; generate M code for String.byteLimitSubstring()
	;
	I '$D(labels("vStrBLS")) D
	.	;
	.	N buf S buf=$$vopenBuf("(String vVal, Number vStart, Number vMax)","String.byteLimitSubstring")
	.	;
	.	D vaddBuff(buf,"if 'vMax.exists() quit vVal.extract( vStart, PSL.maxStringLength)")
	.	D vaddBuff(buf,"quit vVal.extract( vStart, vStart+vMax-1)")
	.	;
	.	D INSERT^UCMETHOD(buf,"vStrBLS","")
	.	K vobj(+$G(buf)) Q 
	Q "$$vStrBLS("
	;
	; ---------------------------------------------------------------------
psl2m(minArg,maxArg)	;
	 ; pslMtd(class,method) = data
	;
	N zmethod S zmethod="Z"_$$vStrUC(method)
	;
	S pslMtd(mclass,zmethod)=pslMtd(mclass,method)
	S method=zmethod
	D psl2m^UCPRIM(minArg,maxArg)
	K pslMtd(mclass,zmethod)
	Q 
	;
vSIG()	;
	Q "60690^58444^Frans S.C. Witte^24121" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vopenBuf(v1,v2)	; PSL.openBuffer
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N vOid
	S vOid=$order(vobj(""),-1)+1
	I $E(v1,1)'="(",'(v1="") S v1="("_v1_")"
	S vobj(vOid,-1)=v1
	S vobj(vOid,-2)=v2
	S vobj(vOid,1)=v1_" // "_v2
	Q vOid
	; ----------------
	;  #OPTION ResultClass 0
vaddBuff(object,p1)	; PSLBuffer.add
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N line
	S line=$order(vobj(object,""),-1)+1
	S vobj(object,line)=" "_p1
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vStrUC(vObj)	; String.upperCase
	;
	;  #OPTIMIZE FUNCTIONS OFF
	Q $translate(vObj,"abcdefghijklmnopqrstuvwxyz±≥µ∂π∫ªºæø‡·‚„‰ÂÊÁËÈÍÎÏÌÓÔÒÚÛÙıˆ¯˘˙˚¸˝˛","ABCDEFGHIJKLMNOPQRSTUVWXYZ°£•¶©™´¨ÆØ¿¡¬√ƒ≈∆«»… ÀÃÕŒœ–—“”‘’÷ÿŸ⁄€‹›ﬁ")
	;
vtrap1	;	Error trap
	;
	N vEx S vEx=$ZS
	; no $$ENCODING^%CHARSET, try to guess one from
	; ISO-8859-1, ISO-8859-2, ISO-8859-15 and
	; DEC-MULTINATIONAL
	N lc S lc=$$LC^%CHARSET()
	I lc[$char(168) S return="ISO-8859-15"
	E  I lc[$char(177) S return="ISO-8859-2"
	E  I lc[$char(247) S return="DEC-MULTINATIONAL"
	E  S return="ISO-8859-1"
	Q 
