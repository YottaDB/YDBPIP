UCHTML	;Library; Library of HTML methods
	;;Copyright(c)2004 Sanchez Computer Associates, Inc.  All Rights Reserved - 01/29/04 19:28:00 - RUSSELL
	; ORIG: FSANCHEZ - 03/15/2000
	; DESC: Library of HTML methods 
	;	addAttrib		// Adds <! Attributes elementName  attribute >
	;	addCol			// Adds a column from the results set
	;	addElement		// Adds <! ELEMENT elementName (attributes)>
	;	addList			// Adds multiple <columnName>value</columnName> based on list of columns and values
	;	addProp			// Adds <columnName>value</columnName>
	;	addRow			// Adds <columnName>value</columnName>... for entire row
	;	addString		// Adds <tag>String</tag>, or String if no tag)
	;	addTitle		// adds <XML> <!doctype  doc [  ]>
	;
	; 
	; KEYWORDS:     DATABASE 
	;
	;---------- Revision History ------------------------------------------
	; 04/20/05 - SIGDAE / Frans S.C. Witte - CRs: 17056 / 18164
	;	* Added section escape to escape XML special characters.
	;	* Modified section addSingle to call section escape to escape XML
	;	  characters contained in data. This fixes an issue where a
	;	  hacker could inject XML into an XML message.
	;	* Labels passed to $$newLabel^UCGM() will no longer exceed five
	;	  characters, leaving room for 2 additional digits:
	;		AddRow -> AddRw
	;		AddLst -> AddLs
	;
	; 05/12/04 - RussellDS - CR9676
	;	     Move Profile04 version to Profile01 to support single code
	;	     base for PSL.
	;
	; 01/30/04 - RussellDS - CR8092
	;	     Fixed addRow and addCol methods to deal with new 
	;	     structures used by compiler -- struct() vs. type()
	;
	; 04/26/00 - SPIER - 37158
	;            Modified addAttrib and addTitle sections to make
	;	     the output acceptable to ms explorer reader.
	;
	; 04/11/00 - SPIER - 37246
	;            Added Currency to attributes. Also provided ability to
	;	     split a return line when addRow and AddList have a 
	;	     large number of columns.
	;
	; 03/24/00 - SPIER - 35208
	;            Added Currency to attributes available
	;-----------------------------------------------------------------------
	; I18N=QUIT
	quit
	;
	;-----------------------------------------------------------------------
addAttrib;	method HTML.addAttrib // Adds <! ELEMENT elementName  attribute >
	;-----------------------------------------------------------------------
	; Pass record name and (column=date or boolean), columns can be
	; comma delimited to specify multiple formats
	n mcode s mcode=""
	S stringname=setVar
	S element=$G(actual(1)) if element="" set return="" quit
	S attrib=$g(actual(2))
	S label="vAddAttr"
	I '$D(labels(label)) D
	.	S labels(label)=""
	.	D addSubr^UCGM(label,"(element,attribut)","Add element to XML header")
	.	N level S level=0
	.	S code="N attr,col,data,n,trailer" D append(tab_code,label)
	.	S code="S data=$P($G("_stringname_"),""]>"",1)" D append(tab_code,label)
	.	S code="S trailer=$P($G("_stringname_"),""]>"",2)" D append(tab_code,label)
	.;	S code="S "_stringname_"=data_""<!ATTLIST ""_element_$C(13,10)" D append(tab_code,label) 
	.	S code="S "_stringname_"=data_$C(13,10)" D append(tab_code,label) 
	.	S code="S n=""""" D append(tab_code,label)
	.	;
	.	; start structure do block structure
	.	S code="F n=1:1:$L(attribut,"","")  D" D append(tab_code,label)
	.	D initBlock^UCGM
	.	;
	.	; add attributes code for date and boolean
	.	S code="S col=$P($P(attribut,"","",n),""="",1),attr=$P($P(attribut,"","",n),""="",2)"
	.	D append($$initLine^UCGM(level)_code,label)
	.	;
	.	S code="I $G(attr)="""" S "_stringname_"="_stringname_"_""<!ELEMENT ""_col_"" (CDATA)>""_$C(13,10) Q"
	.	D append($$initLine^UCGM(level)_code,label)
	.	S code="E  S "_stringname_"="_stringname_"_""<!ELEMENT ""_col_"" (#PCDATA)>""_$C(13,10)"
	.	D append($$initLine^UCGM(level)_code,label)
	.	;
	.	S code="I $G(attr)=""DATE"" S "_stringname_"="_stringname_"_""<!ATTLIST ""_col_"" STARTDATE CDATA #FIXED '1/1/1841'>""_$C(13,10)"
	.	D append($$initLine^UCGM(level)_code,label)  
	.	;
	.	S code="E  I $G(attr)=""BOOLEAN"" S "_stringname_"="_stringname_"_""<!ATTLIST ""_col_"" BOOLEAN CDATA FORMAT #FIXED '0/1'>""_$C(13,10)"
	.	D append($$initLine^UCGM(level)_code,label)  
	.	;
	.	S code="E  I $G(attr)=""CURRENCY"" S "_stringname_"="_stringname_"_""<!ATTLIST ""_col_"" CURRENCY CDATA #FIXED 'CURRENCY'>""_$C(13,10)"
	.	D append($$initLine^UCGM(level)_code,label)  
	.	S code="E  S "_stringname_"="_stringname_"_$C(9)_col_"" CDATA #REQUIRED""_$C(13,10)" 
	.	D append($$initLine^UCGM(level)_code,label)
	.	;
	.	; end structured do block structure
	.	D endBlock^UCGM
	.	; 
	.	S code="S "_stringname_"="_stringname_"_$C(13,10)_""]>""_trailer" D append(tab_code,label)
	.	S code="Q "_stringname D append(tab_code,label)
	S return="$$vAddAttr("_element_","_attrib_")"
	Q
	;
	;-----------------------------------------------------------------------
addCol	; method HTML.addCol // 
	;-----------------------------------------------------------------------
	;
	new class,col,record,var,varPtr,z
	set var=$G(actual(1)) if var="" set return="" quit
	set col=$G(actual(2)) if col="" set return="" quit
	;
	if $E(var)="." set var=$E(var,2,$L(var))
	;
	set class=$$getClass^UCGM(var,.newLevel)
	if class'="ResultSet" do ERROR^UCGM("ResultSet Expected: "_var) quit
	set varPtr=$$getAtt^UCGM(var,objectLevel,2)
	set record=$G(struct("s",subRou,varPtr,var))
	set z=$P(record,tab,4)
	set return="$G("_setVar_")"
	if z'="" do
	.	;
	.	new cols
	.	set cols=$P(z," FROM ",1)
	.	set cols=$$QSUB^%ZS(cols,"""")
	.	do addSingle($P(cols,",",col),"$P(vobj("_var_"),$C(9),"_col_")")
	Q
	;
	;-----------------------------------------------------------------------
addElement	; method HTML.addElement // Adds <! ELEMENT elementName (attributes)>
	;-----------------------------------------------------------------------
	;
	new element,attributes,stringname
	S stringname=setVar
	S element=$G(actual(1)) if element="" set return="" quit
	;
	; attributes can be null
	S attrib=$g(actual(2))
	S label="vAddElement"
	;
	; Create one and only one label to process the information, this label
	; will be used by all calls to add a element list
	;
	I '$D(labels(label)) D
	.	;
	.	S labels(label)=""
	.	D addSubr^UCGM(label,"(element,attribut)","Add element to XML header")
	.	S code="N data,trailer" D append(tab_code,label)
	.	S code="S data=$P($G("_stringname_"),""]>"",1)" D append(tab_code,label)
	.	S code="S trailer=$P($G("_stringname_"),""]>"",2)" D append(tab_code,label)
	.	S code="S "_stringname_"=data_""<!ELEMENT ""_element" D append(tab_code,label) 
	.	S code="I $G(attribut)'="""" S "_stringname_"="_stringname_"_"" (""_attribut_"")*""" D append(tab_code,label)  
	.	S code="S "_stringname_"="_stringname_"_"" >""_$C(13,10)_""]>""_trailer" D append(tab_code,label)
	.	S code="Q "_stringname D append(tab_code,label)
	S return="$$vAddElement("_element_","_attrib_")"
	Q
	;
	;
	;-----------------------------------------------------------------------
addRow	;method; HTML.addRow() Adds <columnName>value</columnName>... for entire row
	;-----------------------------------------------------------------------
	;
	N class,col,cols,i,newLevel,record,var,varPtr
	S element=$G(actual(1)) I element="" set return="" quit
	S element=$$QSUB^%ZS(element)
	set var=$G(actual(2)) if var="" set return="" quit
	;
	if $E(var)="." set var=$E(var,2,$L(var))
	;
	set class=$$getClass^UCGM(var,.newLevel)
	if class'="ResultSet" do ERROR^UCGM("ResultSet Expected: "_var) quit
	;
	set return="$G("_setVar_")_$C(13,10)_""<"_element_">"""
	;
	set varPtr=$$getAtt^UCGM(var,objectLevel,2)
	set record=$G(struct("s",subRou,varPtr,var))
	set z=$P(record,tab,4)
	if z'="" do
	.	;
	.	set cols=$P(z," FROM ",1)
	.	set cols=$$QSUB^%ZS(cols,"""")
	.	for i=1:1:$L(cols,",") do
	..		;
	..		set col=$P(cols,",",i)
	..		do addSingle(col,"$P(vobj("_var_"),$C(9),"_i_")")
	set return=return_"_$C(13,10)_""</"_element_">"""
	if $L(return)>450 d
	.	N str,label,substr,i
	.	S label=$$newLabel^UCGM("AddRw",.labels)	; Get next label
	.	S label=label_"()"
	.	D Splitret
	.	S return="$$"_label
	;
	quit
	;
Splitret;	
	; Split the return field into multiple lines of code. This is done to
	; prevent compile time errors.
	D addSubr^UCGM(label,"","; ")   	; header
	do append(" n X",label)
	do append(" S X=""""",label)
	for i=1:7 D  Q:return=""
	.	S str=$P(return,"</",1,7)
	.	S return=$p(return,"</",7,1000)
	.	if return'="" do
	..		S substr=$p($p(return,"</",2),">",1)
	..		S return=$P(return,">",4,1000)
	..		I substr="" Q
	..		S str=str_"</"_substr_">"""
	.	I i>1 s str=$e(str,3,10000)
	.	d append^UCGM(" S X=X_"_str,label)
	do append(" Q X",label)
	Q
	;-----------------------------------------------------------------------
addList;	method HTML.addList Adds Muliple <columnName>value</columnName>
	;-----------------------------------------------------------------------
	n col,collist,delimitr,element,stringname,var,varlist,I
	S element=$G(actual(1)) I element="" set return="" quit
	S element=$$QSUB^%ZS(element)
	;
	S collist=$G(actual(2)) I collist="" set return="" quit
	S collist=$$QSUB^%ZS(collist)
	;
	S varlist=$G(actual(3)) if varlist="" set return="" quit
	S delimitr=$G(actual(4)) I $$QSUB^%ZS(delimitr)="" set delimitr="$C(9)"
	;
	set return="$G("_setVar_")_$C(13,10)_""<"_element_">"""
	F I=1:1:$L(collist,",")  S col=$p(collist,",",I),var="$P("_varlist_","_delimitr_","_I_")" D addSingle(col,var)
	set return=return_"_$C(13,10)_""</"_element_">"""
	if $L(return)>450 d
	.	N str,label,substr,i
	.	S label=$$newLabel^UCGM("AddLs",.labels)	; Get next label
	.	S label=label_"()"
	.	D Splitret
	.	S return="$$"_label
	Q
	;
addObj	;
	N element,objnam,setVar,x
	S element=$G(actual(1))
	S element=$$QSUB^%ZS(element)
	S objnam=$g(actual(2))
	S objnam=$P(objnam,".",2)			; object name
	S setVar=$p(actual(3),".",2)
	S file=$$getClass^UCGM(objnam,objectLevel),file=$P(file,"Record",2)	; table name
	set list=$$LIST^SQLDD(file,1)
	S di="" F  S di=$O(^DBTBL("SYSDEV",1,file,9,di)) Q:di=""  D
	S x=" set "_setVar_"=$G("_setVar_")_$C(13,10)_""<"_element_">"""
	D line^UCGM(x)
	F I=1:1 S di=$P(list,",",I) Q:di=""  D
	.	S diattrib=$$DI^SQLDD(di,file,,.fsn)
	.	S z=$P(diattrib,"|",1)			; column attributes (node number)
	.	S col=$$LOWER^%ZFUNC(di)		; Lower case item name
	.	S filecol=objnam_"."_col
	.	;I18N=OFF 
	.	S mcode=$$initLine^UCGM(level)
	.	S x=" set "_setVar_"="_setVar_"_$C(13,10,9)_""<"_di_">""_"_filecol_"_""</"_di_">"""
	.	D line^UCGM(x)
	S x=" set "_setVar_"="_setVar_"_$C(13,10)_""</"_element_">"""
	D line^UCGM(x)
	S (mcode,return)=""
	Q
	;-----------------------------------------------------------------------
addProp;	method HTML.addProp Adds <columnName>value</columnName>
	;-----------------------------------------------------------------------
	n col,var
	S col=$G(actual(1)) I col="" set return="" quit
	S col=$$QSUB^%ZS(col)
	set var=$G(actual(2)) if var="" set return="" quit
	set return="$G("_setVar_")"
	do addSingle(col,var)
	Q
addSingle(col,var);	Private; add single <columnname>value</columnname>  
	set return=return_"_$C(13,10,9)_""<"_col_">""_$$escape^UCHTML("_var_")_""</"_col_">"""
	Q
	;-----------------------------------------------------------------------
addString;	method; HTML.addString() Adds <tag>String</tag>, or String if no tag) 
	;-----------------------------------------------------------------------
	new string,sstring
	set string=$G(actual(1)) if string="" set return="" quit
	set sstring=$$QSUB^%ZS(string)
	set close=$G(actual(2))
	S stringname=setVar
	S return="$G("_stringname_")_$C(13,10)_"
	I close S return=return_"""</"
	E  S return=return_"""<"
	I sstring=string S return=return_"""_"_string_"_"">"""
	E  S return=return_sstring_">"""
	Q
	;-----------------------------------------------------------------------
addTitle;	method; HTML.addTitle() adds <XML> <!doctype  doc[  ]> 
	;-----------------------------------------------------------------------
	new title,stitle
	;
	; need an error here
	set title=$G(actual(1)) if title="" set return="" quit
	S stitle=$$QSUB^%ZS(title)
	;
	I stitle=title set return="""<?xml  version='1.0'?>""_$C(13,10)_""<!DOCTYPE ""_"_title_"_"" [""_$C(13,10)_""]>"""
	E  set return="""<?xml  version='1.0'?>""_$C(13,10)_""<!DOCTYPE "_stitle_" [""_$C(13,10)_""]>"""
	quit
	;
	;-----------------------------------------------------------------------
new	; Class.new
	;-----------------------------------------------------------------------
	;
	set return=""""""
	quit
	;
	;-----------------------------------------------------------------------
append(code,label)	; Add code to the append
	;-----------------------------------------------------------------------
	;
	D append^UCGM(code,label) 
	Q
	;
	;-----------------------------------------------------------------------
escape(data)	;public String; Escape XML special characters
	;-----------------------------------------------------------------------
	; This function will be called at runtime to escape characters in the data
	; that are not allowed in XML CDATA.
	;
	; The ampersand character (&) and the left angle bracket (<) MUST NOT 
	; appear in their literal form, except when used as markup delimiters, 
	; or within a comment, a processing instruction, or a CDATA section. 
	; If they are needed elsewhere, they MUST be escaped using either 
	; numeric character references or the strings "&amp;" and "&lt;" 
	; respectively. The right angle bracket (>) MAY be represented using 
	; the string "&gt;", and MUST, for compatibility, be escaped using 
	; either "&gt;" or a character reference when it appears in the string 
	; "]]>" in content, when that string is not marking the end of a CDATA 
	; section.
	;
	; In the content of elements, character data is any string of characters 
	; which does not contain the start-delimiter of any markup and does not 
	; include the CDATA-section-close delimiter, "]]>". In a CDATA section, 
	; character data is any string of characters not including the 
	; CDATA-section-close delimiter, "]]>".
	;
	; To allow attribute values to contain both single and double quotes, 
	; the apostrophe or single-quote character (') MAY be represented as 
	; "&apos;", and the double-quote character (") as "&quot;".
	;-----------------------------------------------------------------------
	;
	I data["&" S data=$$replace(data,"&","&amp;")
	I data["<" S data=$$replace(data,"<","&lt;")
	I data[">" S data=$$replace(data,">","&gt;")
	I data["'" S data=$$replace(data,"'","&apos;")
	I data["""" S data=$$replace(data,"""","&quot;")
	Q data
	;
	;-----------------------------------------------------------------------
replace(data,chr,expr)	;local String; replace 1 character by (escape) string
	;-----------------------------------------------------------------------
	; Note that the code in the FOR-loop explicitly uses the fact that chr
	; is a single character, and that expr will not contain chr.
	;
	new p
	;
	S p=0
	F  S p=$F(data,chr,p) Q:p=0  s data=$E(data,1,p-2)_expr_$E(data,p,$L(data))
	Q data
