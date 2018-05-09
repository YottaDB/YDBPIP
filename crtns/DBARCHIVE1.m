DBARCHIVE1	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBARCHIVE1 ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	;
	N pslcode
	;
	D addcode(.pslcode,"private DBARCHIVE2(String ARCHDIR, Number ARCHNUM, Date THRUDATE, String ARCHTBL, String KEYVALS())"_$char(9)_"// Call ARCHIVE^filerPgm to archive data")
	D addcode(.pslcode," // Last compiled:  "_$$vdat2str($P($H,",",1),"MM/DD/YEAR")_" "_$$TIM^%ZM_" - "_$$USERNAM^%ZFUNC)
	D addcode(.pslcode,"")
	D addcode(.pslcode," // THIS IS A COMPILED ROUTINE.  Compiled by procedure DBARCHIVE1")
	D addcode(.pslcode,"")
	D addcode(.pslcode," // See DBARCHIVE1 for argument definitions")
	D addcode(.pslcode,"")
	;
	N rs,vos1,vos2 S rs=$$vOpen1()
	;
	F  Q:'($$vFetch1())  D
	.	;
	.	N i N KEYCNT
	.	N ARCHTBL N code
	.	;
	.	S ARCHTBL=rs
	.	;
	.	N tblDes S tblDes=$$getPslTbl^UCXDD(ARCHTBL,1)
	.	;
	.	S KEYCNT=$$getArchiveKey^DBARCHIVE(tblDes,0)
	.	;
	.	; If archive key is first key, KEYVALS will not be passed as it
	.	; is not used
	.	S code="quit $$ARCHIVE^"_$P(tblDes,"|",6)_"(ARCHDIR, ARCHNUM, THRUDATE"
	.	F i=1:1:KEYCNT-1 S code=code_", KEYVALS("_i_")"
	.	S code=code_")"
	.	;
	.	D addcode(.pslcode," if (ARCHTBL = """_ARCHTBL_""") "_code)
	.	Q 
	;
	D addcode(.pslcode,"")
	D addcode(.pslcode," quit 0")
	;
	; Build compiled routine
	D cmpA2F^UCGM(.pslcode,"DBARCHIVE2")
	;
	Q 
	;
addcode(pslcode,code)	;
	;
	N LINENO
	;
	I ($E(code,1)=" ") S code=$char(9)_$E(code,2,1048575)
	;
	S LINENO=$order(pslcode(""),-1)+1 ; Add to end
	S pslcode(LINENO)=code
	;
	Q 
	;
vSIG()	;
	Q "60729^59303^Dan Russell^2123" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vdat2str(object,mask)	; Date.toString
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I (object="") Q ""
	I (mask="") S mask="MM/DD/YEAR"
	N cc N lday N lmon
	I mask="DL"!(mask="DS") D  ; Long or short weekday
	.	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
	.	I (cc="") S cc="US"
	.	S lday=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
	.	S mask="DAY" ; Day of the week
	.	Q 
	I mask="ML"!(mask="MS") D  ; Long or short month
	.	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
	.	I (cc="") S cc="US"
	.	S lmon=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
	.	S mask="MON" ; Month of the year
	.	Q 
	Q $ZD(object,mask,$get(lmon),$get(lday))
	;
vOpen1()	;	ARCHTBL FROM DBUTARCHIVE ORDER BY ARCHTBL ASC
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=""
vL1a2	S vos2=$O(^UTBL("DBARCHIVE",vos2),1) I vos2="" G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a2
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos2=$C(254):"",1:vos2)
	;
	Q 1
