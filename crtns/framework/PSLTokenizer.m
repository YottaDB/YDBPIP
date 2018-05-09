 ; 
 ; **** Routine compiled from DATA-QWIK Procedure PSLTokenizer ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
 ;  #PACKAGE  framework.psl
 ;
 ;  #CLASSDEF extends=Primitive public delimiter=9
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF charComment class=List public node="charComment"
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF charEscape  class=String public node="charEscape"
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF charQuote  class=String public node="charQuote"
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF charSymbol  class=String public node="charSymbol"
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF srcChar  class=Number public readonly node="srcChar"
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF srcFile  class=String public readonly node="srcFile"
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF srcLast  class=Number public readonly node="srcLast"
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF srcLine  class=Number public readonly node="srcLine"
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF srcCode()  class=String public readonly node="srcCode"
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF tknIgnCMT  class=Number public node="tknIgnCMT"
 ;   #PROPERTYDEF tknIgnCMTALL   = 2  public literal
 ;   #PROPERTYDEF tknIgnCMTBLOCK = 1  public literal
 ;   #PROPERTYDEF tknIgnCMTNONE  = 0  public literal
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF tknIgnEOL  class=Boolean public node="tknIgnEOL"
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF tknPushBack class=Boolean public readonly node="tknPushBack"
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF tknTree()  class=String public readonly node="tknTree"
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF tknType  class=Number public readonly node="tknType"
 ;   #PROPERTYDEF tknTypeCMT = 59 public literal
 ;   #PROPERTYDEF tknTypeEOF = -1 public literal
 ;   #PROPERTYDEF tknTypeEOL = 10 public literal
 ;   #PROPERTYDEF tknTypeMTD = -4 public literal
 ;   #PROPERTYDEF tknTypeNUM = -2 public literal
 ;   #PROPERTYDEF tknTypeSTR = 34 public literal
 ;   #PROPERTYDEF tknTypeWRD = -3 public literal
 ;   #PROPERTYDEF tknTypeWSP = 32 public literal
 ;   #PROPERTYDEF tknTypeXRL = -9 public literal
 ;
 ; ---------------------------------------------------------------------
 ;  #PROPERTYDEF tknValue  class=String public readonly node="tknValue"
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
 ;
 ; ---------------------------------------------------------------------
initialize(this,initObj) ; constructor
 D reset(.this)
 ;
 N rSrc S rSrc=initObj
 N ln S ln=1
 ;
 S $P(vobj(rSrc,1),"|",3)="READ"
 S $P(vobj(rSrc,1),"|",5)=1048575
 D
 .	N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 .	D open^UCIO(rSrc,$T(+0),"initialize","rSrc")
 .	S this("srcFile")=$P(vobj(rSrc,1),"|",6)
 .	F ln=1:1 S this("srcCode",ln)=$translate($$read^UCIO(rSrc),$char(9)_$char(10)_$char(13),"   ")
 .	Q 
 S this("srcLast")=ln-1
 Q 
 ;
 ; ---------------------------------------------------------------------
isLogEOL(tkn) ; 
 ;
 Q (",59,-1,10,"[(","_tkn_","))
 ;
 ; ---------------------------------------------------------------------
tokenType(tkn) ; 
 ;
 I tkn<-9 Q "rule"_tkn
 I tkn=59 Q "comment"
 I tkn=-1 Q "end-of-file"
 I tkn=10 Q "end-of-line"
 I tkn=-4 Q "method declaration"
 I tkn=-2 Q "number"
 I tkn=34 Q "string"
 I tkn=-3 Q "word"
 I tkn=32 Q "whitespace"
 Q "symbol '"_$char(tkn)_"'"
 ;
 ; ---------------------------------------------------------------------
appendSrc(this,src) ; 
 N lp S lp=this("srcLast") N sp S sp=""
 F lp=lp+1:1 S sp=$order(src(sp)) Q:sp=""  S this("srcCode",lp)=$translate(src(sp),$char(9)_$char(10)_$char(13),"   ")
 S this("srcLast")=lp-1
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
appendLine(this,line) ; 
 N lp S lp=this("srcLast")+1
 S this("srcLast")=lp S this("srcCode",lp)=$translate(line,$char(9)_$char(10)_$char(13),"   ")
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
chkEOL(this) ; 
 ;
 N ign N tkn S tkn=this("tknType")
 F  Q:'(tkn=32)  S tkn=$$nextToken(.this)
 I tkn=59 S tkn=$$nextToken(.this)
 I tkn'=10,tkn'=-1 S ign=$$skip2EOL(.this) S $ZE="0,"_$ZPOS_","_"%PSL-E-SYNTAX,invalid "_$$tokenType(tkn)_" before end-of-line",$EC=",U1001,"
 Q tkn
 ;
 ; ---------------------------------------------------------------------
nextLine(this) ; Return the next line from the token stream or "" for EOF
 N cp S cp=this("srcChar") N lp S lp=this("srcLine") N tkn
 ;
 ; skip leading whitespace
 I cp=0 S cp=1 S lp=lp+1 I '($D(this("srcCode",lp))#2) D saveSrc(.this,0,lp) S tkn=$$saveTkn(.this,-1,"") Q ""
 N code S code=this("srcCode",lp)
 ;
 I this("tknIgnEOL"),$E(code,cp,1048575)?." " D  I code?." " D saveSrc(.this,0,lp+1) S tkn=$$saveTkn(.this,-1,"") Q ""
 .	S cp=1
 .	F lp=lp+1:1:$order(this("srcCode",""),-1) S code=this("srcCode",lp) Q:code'?." " 
 .	Q 
 ;
 ; Comment
 N cc S cc=cp
 I $E(code,cc)=" " F cc=cc+1:1 Q:$E(code,cc)'=" " 
 S cc=$$nextCmt(.this,cc,lp) I cc>0 Q $$nextLine(.this)
 ;
 D saveSrc(.this,0,lp)
 S tkn=$$saveTkn(.this,10,lp)
 ;
 I cp=1 Q code
 Q $E(code,cp,1048575)
 ;
 ; ---------------------------------------------------------------------
nextToken(this) ; 
 ;
 ; if token has been pushed back, turn off pushback indicator, return
 ; what we have now
 I this("tknPushBack") S this("tknPushBack")=0 Q this("tknType")
 ;
 N cp S cp=this("srcChar") N lp S lp=this("srcLine")
 ;
 ; skip leading whitespace
 I cp=0 S cp=1 S lp=lp+1 I '($D(this("srcCode",lp))#2) D saveSrc(.this,0,lp) Q $$saveTkn(.this,-1,"")
 N code S code=this("srcCode",lp)
 ;
 I this("tknIgnEOL"),$E(code,cp,1048575)?." " D  I code?." " D saveSrc(.this,0,lp+1) Q $$saveTkn(.this,-1,"")
 .	S cp=1
 .	F lp=lp+1:1:$order(this("srcCode",""),-1) S code=this("srcCode",lp) Q:code'?." " 
 .	Q 
 ;
 I $E(code,cp)=" " F cp=cp+1:1 Q:$E(code,cp)'=" " 
 ;
 S code=$E(code,cp,1048575)
 ;
 ; code now starts with the first relevant character.
 N c S c=$E(code,1)
 ;
 I (c="") D saveSrc(.this,0,lp) Q $$saveTkn(.this,10,lp)
 ;
 ; Comment
 N ce S ce=$$nextCmt(.this,cp,lp)
 I ce>0 Q $S(ce'>this("tknIgnCMT"):$$nextToken(.this),ce=2:59,1:32)
 ;if $$isComment(this(,), cp, lp) quit this.tknTypeCMT
 ;
 ; numbers AND single '-' shall be handled by $$nextNumlit(), except
 ; when in first position (numeric label)
 I "-+.0123456789"[c,cp>1 Q $$nextNumlit(.this,code,cp,lp)
 ;
 ; strlit shall be handled be $$nextStrlit()
 I c=this("charQuote") Q $$nextStrlit(.this,code,cp,lp)
 ;
 ; symbols
 N s S s=this("charSymbol")
 I s[c D saveSrc(.this,cp+1,lp) Q $$saveTkn(.this,$ascii(c),c)
 ;
 ; word (delimited by SPace, symbol, or quote character)
 S s=$translate(code,s_this("charQuote"),$J("",($L(s)+1)))
 S ce=$F(s," ")-2
 ;
 I ce<0 S ce=$L(code)
 ;
 ;if code.extract(1, ce).length("""")#2=0 for  set ce=s.find(" ",ce) set:ce=0 ce=s.length()+2 if code.extract(1, ce-2).length("""")#2=1 set ce=ce-2 quit
 ;
 D saveSrc(.this,cp+ce,lp)
 ;
 Q $$saveTkn(.this,$S(cp=1:-4,1:-3),$E(code,1,ce))
 ;
 ; ---------------------------------------------------------------------
nextWhitespace(this) ; 
 N cp S cp=this("srcChar")
 ;
 I cp=0 Q "" ; at end-of-line there is no whitespace
 ;
 N code S code=this("srcCode",this("srcLine"))
 N cp1
 F cp1=cp:1 Q:$E(code,cp1)'=" " 
 ;
 Q $E(code,cp,cp1-1)
 ;
 ; ---------------------------------------------------------------------
preParse(this) ; 
 ;
 N ign N tt
 ;
 D saveSrc(.this,0,0)
 S this("tknIgnEOL")=0
 K this("tknTree")
 ;
 F  S tt=$$nextToken(.this) S ign=$$treeAdd(.this,this("tknType"),this("tknValue")) Q:tt=-1 
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
pushBack(this) ; 
 S this("tknPushBack")=1
 Q 
 ;
 ; ---------------------------------------------------------------------
rewind(this) ; reset source code pointer
 S this("srcChar")=0
 S this("srcLine")=0
 Q 
 ;
 ; ---------------------------------------------------------------------
showSrc(this) ; 
 ;
 N tt
 D saveSrc(.this,0,0)
 S this("tknIgnEOL")=0
 ;
 F  D  Q:tt=-1 
 .	S tt=$$nextToken(.this)
 .	I tt=-4 WRITE "*** START OF METHOD ***",!
 .	;
 .	I (tt=10) WRITE "*EOL*",!?8
 .	E  I tt=34 WRITE $$QADD^%ZS(this("tknValue"),"""")," "
 .	E  I tt=32 WRITE "/* "_this("tknValue")_" */ "
 .	E  I tt=59 WRITE "// "_this("tknValue")
 .	E  WRITE this("tknValue")," "
 .	Q 
 WRITE "*EOF*"
 Q 
 ;
 ; ---------------------------------------------------------------------
skip2EOL(this) ; 
 D saveSrc(.this,0,this("srcLine"))
 Q $$saveTkn(.this,10,this("srcLine"))
 ;
 ; ---------------------------------------------------------------------
skip2SYM(this,sym) ; 
 N tkn
 ;
 F  S tkn=$$nextToken(.this) Q:tkn=10&'this("tknIgnEOL")!(tkn=-1)!(tkn=sym) 
 Q tkn
 ;
 ; ---------------------------------------------------------------------
skip2WRD(this,words,ignCase) ; 
 N tkn
 ;
 F  S tkn=$$nextToken(.this) Q:tkn=10&'this("tknIgnEOL")!(tkn=-1)  I tkn=-3,$S(ignCase:$ZCONVERT((","_words_","),"U")[$ZCONVERT((","_this("tknValue")_","),"U"),1:(","_words_","))[(","_this("tknValue")_",") Q 
 Q tkn
 ;
 ; ---------------------------------------------------------------------
addQuotes(this,str) ; 
 N ce S ce=this("charEscape")
 N cq S cq=this("charQuote")
 ;
 I (ce="") Q $S(str'[cq:cq_str_cq,1:$$QADD^%ZS(str,cq))
 ;
 S str=$$vStrRep(str,ce,ce_ce,0,0,"")
 S str=$$vStrRep(str,$char(8),ce_"b",0,0,"")
 S str=$$vStrRep(str,$char(9),ce_"t",0,0,"")
 S str=$$vStrRep(str,$char(10),ce_"n",0,0,"")
 S str=$$vStrRep(str,$char(12),ce_"f",0,0,"")
 S str=$$vStrRep(str,$char(13),ce_"r",0,0,"")
 S str=$$vStrRep(str,cq,ce_cq,0,0,"")
 Q cq_str_cq
 ;
 ; ---------------------------------------------------------------------
treeAdd(this,rule,branch) ; 
 N root S root=+$order(this("tknTree",""),-1)+1
 S this("tknTree",root)=rule_$char(9)_branch
 Q root
 ;
 ; ---------------------------------------------------------------------
treeRemove(this,at) ; remove tree entry at specified node
 N sub S sub=$S(at>0:at,at=0:+$order(this("tknTree",""),-1),1:+$order(this("tknTree",""),-1)+at)
 K this("tknTree",sub)
 Q 
 ;
 ; ---------------------------------------------------------------------
treeRoot(this) ; 
 Q +$order(this("tknTree",""),-1)
 ;
 ; ---------------------------------------------------------------------
treeType(this,at) ; (*1)
 Q +this("tknTree",$S(at>0:at,at=0:+$order(this("tknTree",""),-1),1:+$order(this("tknTree",""),-1)+at))
 ;
 ; ---------------------------------------------------------------------
treeValue(this,at) ; (*1)
 Q $piece(this("tknTree",$S(at>0:at,at=0:+$order(this("tknTree",""),-1),1:+$order(this("tknTree",""),-1)+at)),$char(9),2,1048575)
 ;
 ; ---------------------------------------------------------------------
nextCmt(this,cp,lp) ; 
 N elm S elm=0
 N cmtPairs S cmtPairs=this("charComment")
 N cmt N cmtBgn S cmtBgn="" N cmtEnd S cmtEnd=""
 N code S code=$E(this("srcCode",lp),cp,1048575)
 ;
 F elm=1:1:$S((cmtPairs=""):0,1:$L(cmtPairs,",")) S cmt=$piece($piece(cmtPairs,",",elm),":") I ($E(code,1,$L(cmt))=cmt) S cmtBgn=cmt S cmtEnd=$piece($piece(cmtPairs,",",elm),":",2) Q 
 ;
 I (cmtBgn="") Q 0
 ;
 I (cmtEnd="") D saveSrc(.this,0,lp) S elm=$$saveTkn(.this,59,$E(code,$L(cmtBgn)+1,1048575)) Q 2
 ;
 N pos S pos=$F(code,cmtEnd)
 I pos>0 D saveSrc(.this,cp+pos,lp) S elm=$$saveTkn(.this,59,$E(code,$L(cmtBgn)+1,pos-$L(cmtEnd)-1)) Q 1
 ;
 S cmt=$E(code,$L(cmtBgn)+1,1048575)
 F lp=lp+1:1:this("srcLast") D  Q:pos>0 
 .	S code=this("srcCode",lp) S pos=$F(code,cmtEnd)
 .	I 'pos S cmt=cmt_$char(10)_code Q 
 .	S cmt=cmt_$char(10)_$E(code,1,pos-1-$L(cmtEnd))
 .	Q 
 D saveSrc(.this,pos,lp) S elm=$$saveTkn(.this,59,cmt)
 Q 1
 ;
 ; ---------------------------------------------------------------------
nextNumlit(this,code,cp,lp) ; 
 ;
 N num S num=$E(code,1)
 I num="-"!(num="+"),".0123456789"'[$E(code,2) D saveSrc(.this,cp+1,lp) Q $$saveTkn(.this,$ascii(num),num)
 I num=".","0123456789"'[$E(code,2) D saveSrc(.this,cp+1,lp) Q $$saveTkn(.this,46,".")
 ;
 N ce
 ;
 ; integer part (including leading "-"
 F ce=2:1 Q:$E(code,ce)'?1N 
 ;
 ; fraction (only if dot followed by at least one digit)
 I $E(code,ce)=".",$E(code,ce+1)?1N F ce=ce+1:1 Q:$E(code,ce)'?1N 
 ;
 ; exponent
 I $E(code,ce)="E" D
 .	N ce1 S ce1=ce+1
 .	I $E(code,ce1)="+"!($E(code,ce1)="-") S ce1=ce1+1
 .	I $E(code,ce1)?1N F ce=ce1+1:1 Q:$E(code,ce)'?1N 
 .	Q 
 S ce=ce-1
 D saveSrc(.this,cp+ce,lp)
 Q $$saveTkn(.this,-2,+$E(code,1,ce))
 ;
 ; ---------------------------------------------------------------------
nextStrD(this,code,cp,lp) ; 
 ;
 N ce S ce=2
 N qt S qt=this("charQuote")
 F  S ce=$F(code,qt,ce) Q:$E(code,ce)'=qt 
 S ce=ce-1 I ce<0 S ce=$$saveTkn(.this,34,code_qt) D saveSrc(.this,0,lp) S $ZE="0,"_$ZPOS_","_"%PSL-E-SYNTAX,missing quote",$EC=",U1001,"
 D saveSrc(.this,cp+ce,lp)
 Q $$saveTkn(.this,34,$$QSUB^%ZS($E(code,1,ce),qt))
 ;
 ; ---------------------------------------------------------------------
nextStrJ(this,code,cp,lp) ; 
 ;
 N ce S ce=2
 N qt S qt=this("charQuote")
 N es S es=this("charEscape")
 N c S c=""
 ;
 F  S ce=$F(code,qt,ce) Q:$E(code,ce-2)'=es 
 I ce=0 S ce=$$saveTkn(.this,34,code_es_qt) D saveSrc(.this,0,lp) S $ZE="0,"_$ZPOS_","_"%PSL-E-SYNTAX,missing quote",$EC=",U1001,"
 D saveSrc(.this,cp+ce-1,lp)
 ;
 N res S res=$E(code,2,ce-2)
 S ce=1
 ;
 F  S ce=$F(res,es,ce) Q:ce=0  D
 .	S c=$E(res,ce)
 .	I c="u" D
 ..		; to come: replace \uxxxx by its Unicode character
 ..		N d S d=0 N i S i=0
 ..		F i=1:1:4 S d=d*16+$F("0123456789abcdef",$ZCONVERT($E(res,ce+i),"L"))-2
 ..		S res=$E(res,1,ce-2)_$char(d)_$E(res,ce+5,1048575)
 ..		Q 
 .	E  I """\/bfnrt"[c S res=$E(res,1,ce-2)_$translate(c,"""\/bfnrt",$C(34,92,47,8,12,10,13,9))_$E(res,ce+1,1048575) Q 
 .	Q 
 ;
 Q $$saveTkn(.this,34,res)
 ;
 ; ---------------------------------------------------------------------
nextStrlit(this,code,cp,lp) ; 
 I (this("charEscape")="") Q $$nextStrD(.this,code,cp,lp)
 Q $$nextStrJ(.this,code,cp,lp)
 ;
 ; ---------------------------------------------------------------------
reset(this) ; reset all pointers
 ;
 S this("charEscape")=""
 S this("charComment")=";,//,/*:*/"
 S this("charQuote")=""""
 S this("charSymbol")="_+-*/\#=<>&!?'@()[]{},.;:"
 ;
 S this("srcChar")=0
 S this("srcFile")=""
 S this("srcLast")=0
 S this("srcLine")=0
 K this("srcCode")
 ;
 S this("tknIgnCMT")=1 ; ignore block-comment
 S this("tknIgnEOL")=0 ; do not ignore EOL
 S this("tknPushBack")=0
 S this("tknType")=10
 S this("tknValue")=""
 K this("tknTree")
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
saveSrc(this,cp,lp) ; 
 S this("srcChar")=cp S this("srcLine")=lp
 Q 
 ;
 ; ---------------------------------------------------------------------
saveTkn(this,typ,val) ; 
 ;type Number leaf = this.tknTree("").order(-1).toNumber() + 1
 ;set this.tknTree( leaf) = typ_ 9.char()_ val
 S this("tknType")=typ S this("tknValue")=val
 Q typ
 ;  #OPTION ResultClass ON
vSIG(this) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(9))
 I $D(vPslPoly(vC,"vSIG")) Q $$v0vSIG^@vPslPoly(vC,"vSIG")(.this)
 Q $$v0vSIG(.this)
v0vSIG(this) ; 
 Q "61461^42883^Frans S.C. Witte^38936" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vStrRep(object,p1,p2,p3,p4,qt) ; String.replace
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;
 I p3<0 Q object
 I $L(p1)=1,$L(p2)<2,'p3,'p4,(qt="") Q $translate(object,p1,p2)
 ;
 N y S y=0
 F  S y=$$vStrFnd(object,p1,y,p4,qt) Q:y=0  D
 .	S object=$E(object,1,y-$L(p1)-1)_p2_$E(object,y,1048575)
 .	S y=y+$L(p2)-$L(p1)
 .	I p3 S p3=p3-1 I p3=0 S y=$L(object)+1
 .	Q 
 Q object
 ; ----------------
 ;  #OPTION ResultClass 1
vStrFnd(object,p1,p2,p3,qt) ; String.find
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;
 I (p1="") Q $S(p2<1:1,1:+p2)
 I p3 S object=$ZCONVERT(object,"U") S p1=$ZCONVERT(p1,"U")
 S p2=$F(object,p1,p2)
 I '(qt=""),$L($E(object,1,p2-1),qt)#2=0 D
 .	F  S p2=$F(object,p1,p2) Q:p2=0!($L($E(object,1,p2-1),qt)#2) 
 .	Q 
 Q p2
 ;
vCatch1 ; Error trap
 ;
 N rEx,$ET,$ES S rEx=$ZE,$EC="",$ET="Q",$ZE=""
 D close^UCIO(rSrc)
 I $P(rEx,",",3)'["%PSL-E-IO" S $ZE=rEx,$EC=",U1001,"
 D ZX^UCGMR(voxMrk) Q 
vcdmNew(this,vC,vInitObj) ; Constructor, called for Class.new()
 N vT S vT=$T
 S this=vC
 D initialize(.this,.vInitObj)
 I vT
 Q
