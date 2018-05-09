ZUCTLST()	; PSL Test Set, class List, all methods
	;
	; **** Routine compiled from DATA-QWIK Procedure ZUCTLST ****
	;
	; 11/08/2007 14:08 - chenardp
	;
	D add() ; List.add( String expr, String delimiter,
	;           Boolean allowDuplicate, Boolean inOrder)
	Q 
	;
	; =====================================================================
add()	; Validate List.add(String,String,Booelan,Boolean)
	N R0
	N R1 N R2
	N R3 N R4
	D add00()
	F R0="","aap,mies,noot","aap:mies:noot","aap!?mies!?noot" D
	.	D add01(R0)
	.	F R1="","new","mies" D
	..		I (R0="") D add02(R1)
	..		D add06(R0,R1)
	..		F R2="",",",":","!?" D
	...			I (R0=""),(R1="") D add03(R2)
	...			I (R1="") D add07(R0,R2)
	...			I (R0="") D add10(R1,R2)
	...			D add16(R0,R1,R2)
	...			F R3=0,1 D
	....				I (R0=""),(R1=""),(R2="") D add04(R3)
	....				I (R1=""),(R2="") D add08(R0,R3)
	....				I (R0=""),(R2="") D add11(R1,R3)
	....				I (R0=""),(R1="") D add13(R2,R3)
	....				I (R2="") D add17(R0,R1,R3)
	....				I (R1="") D add19(R0,R2,R3)
	....				I (R0="") D add22(R1,R2,R3)
	....				D add26(R0,R1,R2,R3)
	....				F R4=0,1 D
	.....					I (R0=""),(R1=""),(R2=""),R3=0 D add05(R4)
	.....					I (R1=""),(R2=""),R3=0 D add09(R0,R4)
	.....					I (R0=""),(R2=""),R3=0 D add12(R1,R4)
	.....					I (R0=""),(R1=""),R3=0 D add14(R2,R4)
	.....					I (R0=""),(R1=""),(R2="") D add15(R3,R4)
	.....					I (R2=""),R3=0 D add18(R0,R1,R4)
	.....					I (R1=""),R3=0 D add20(R0,R2,R4)
	.....					I (R1=""),(R2="") D add21(R0,R3,R4)
	.....					I (R0=""),R3=0 D add23(R1,R2,R4)
	.....					I (R0=""),(R2="") D add24(R1,R3,R4)
	.....					I (R0=""),(R1="") D add25(R2,R3,R4)
	.....					I R3=0 D add27(R0,R1,R2,R4)
	.....					I (R2="") D add28(R0,R1,R3,R4)
	.....					I (R1="") D add29(R0,R2,R3,R4)
	.....					I (R0="") D add30(R1,R2,R3,R4)
	.....					D add31(R0,R1,R2,R3,R4)
	.....					Q 
	....				Q 
	...			Q 
	..		Q 
	.	Q 
	;
	Q 
	;
	; =====================================================================
	;validate ({List}C0).add(C1,C2,C3,C4)
add00()	;
	;
	Q 
	;
	; =====================================================================
	; validate ({ListR0}.add(C1,C2,C3,C4)
add01(sLst)	;
	N sRes
	;
	S sRes=sLst ; C1 Empty, all others absent
	WRITE "add01(R0):<"_sLst_">.add("""")="_sRes,!
	;
	S sRes=$S((sLst=""):"new",1:sLst_","_"new") ; C1="new", all others absent
	WRITE "add01(R0):<"_sLst_">.add(""new"")="_sRes,!
	;
	S sRes=$S((sLst=""):"mies",1:sLst_","_"mies") ; C1="mies", all others absent
	WRITE "add01(R0):<"_sLst_">.add(""mies"")="_sRes,!
	;
	S sRes=sLst ; C1 Empty, C2=","
	WRITE "add01(R0):<"_sLst_">.add("""","","")="_sRes,!
	;
	S sRes=$S((sLst=""):"new",1:sLst_","_"new") ; C1="new", C2=","
	WRITE "add01(R0):<"_sLst_">.add(""new"","","")="_sRes,!
	;
	S sRes=$S((sLst=""):"mies",1:sLst_","_"mies") ; C1="mies", C2=","
	WRITE "add01(R0):<"_sLst_">.add(""mies"","","")="_sRes,!
	;
	S sRes=sLst ; C1 Empty, C2=":"
	WRITE "add01(R0):<"_sLst_">.add("""","":"")="_sRes,!
	;
	S sRes=$S((sLst=""):"new",1:sLst_":"_"new") ; C1="new", C2=":"
	WRITE "add01(R0):<"_sLst_">.add(""new"","":"")="_sRes,!
	;
	S sRes=$S((sLst=""):"mies",1:sLst_":"_"mies") ; C1="mies", C2=":"
	WRITE "add01(R0):<"_sLst_">.add(""mies"","":"")="_sRes,!
	;
	S sRes=sLst ; C1 Empty, C2="!?"
	WRITE "add01(R0):<"_sLst_">.add("""",""!?"")="_sRes,!
	;
	S sRes=$S((sLst=""):"new",1:sLst_"!?"_"new") ; C1="new", C2="!?"
	WRITE "add01(R0):<"_sLst_">.add(""new"",""!?"")="_sRes,!
	;
	S sRes=$S((sLst=""):"mies",1:sLst_"!?"_"mies") ; C1="mies", C2="!?"
	WRITE "add01(R0):<"_sLst_">.add(""mies"",""!?"")="_sRes,!
	;
	S sRes=sLst ; C1 Empty, C2=",", C3=0
	WRITE "add01(R0):<"_sLst_">.add("""","","",0)="_sRes,!
	;
	S sRes=$S(((","_sLst_",")[",new,"):sLst,1:$S((sLst=""):"new",1:sLst_","_"new")) ; C1="new", C2=",", C3=0
	WRITE "add01(R0):<"_sLst_">.add(""new"","","",0)="_sRes,!
	;
	S sRes=$S(((","_sLst_",")[",mies,"):sLst,1:$S((sLst=""):"mies",1:sLst_","_"mies")) ; C1="mies", C2=",", C3=0
	WRITE "add01(R0):<"_sLst_">.add(""mies"","","",0)="_sRes,!
	;
	S sRes=sLst ; C1 Empty, C2=":", C3=0
	WRITE "add01(R0):<"_sLst_">.add("""","":"",0)="_sRes,!
	;
	S sRes=$S(((":"_sLst_":")[":new:"):sLst,1:$S((sLst=""):"new",1:sLst_":"_"new")) ; C1="new", C2=":", C3=0
	WRITE "add01(R0):<"_sLst_">.add(""new"","":"",0)="_sRes,!
	;
	S sRes=$S(((":"_sLst_":")[":mies:"):sLst,1:$S((sLst=""):"mies",1:sLst_":"_"mies")) ; C1="mies", C2=":", C3=0
	WRITE "add01(R0):<"_sLst_">.add(""mies"","":"",0)="_sRes,!
	;
	S sRes=sLst ; C1 Empty, C2="!?", C3=0
	WRITE "add01(R0):<"_sLst_">.add("""",""!?"",0)="_sRes,!
	;
	S sRes=$S((("!?"_sLst_"!?")["!?new!?"):sLst,1:$S((sLst=""):"new",1:sLst_"!?"_"new")) ; C1="new", C2="!?", C3=0
	WRITE "add01(R0):<"_sLst_">.add(""new"",""!?"",0)="_sRes,!
	;
	S sRes=$S((("!?"_sLst_"!?")["!?mies!?"):sLst,1:$S((sLst=""):"mies",1:sLst_"!?"_"mies")) ; C1="mies", C2="!?", C3=0
	WRITE "add01(R0):<"_sLst_">.add(""mies"",""!?"",0)="_sRes,!
	;
	S sRes=sLst ; C1 Empty, C2=",", C3=1
	WRITE "add01(R0):<"_sLst_">.add("""","","",1)="_sRes,!
	;
	S sRes=$S((sLst=""):"new",1:sLst_","_"new") ; C1="new", C2=",", C3=1
	WRITE "add01(R0):<"_sLst_">.add(""new"","","",1)="_sRes,!
	;
	S sRes=$S((sLst=""):"mies",1:sLst_","_"mies") ; C1="mies", C2=",", C3=1
	WRITE "add01(R0):<"_sLst_">.add(""mies"","","",1)="_sRes,!
	;
	S sRes=sLst ; C1 Empty, C2=":", C3=1
	WRITE "add01(R0):<"_sLst_">.add("""","":"",1)="_sRes,!
	;
	S sRes=$S((sLst=""):"new",1:sLst_":"_"new") ; C1="new", C2=":", C3=1
	WRITE "add01(R0):<"_sLst_">.add(""new"","":"",1)="_sRes,!
	;
	S sRes=$S((sLst=""):"mies",1:sLst_":"_"mies") ; C1="mies", C2=":", C3=1
	WRITE "add01(R0):<"_sLst_">.add(""mies"","":"",1)="_sRes,!
	;
	S sRes=sLst ; C1 Empty, C2="!?", C3=1
	WRITE "add01(R0):<"_sLst_">.add("""",""!?"",1)="_sRes,!
	;
	S sRes=$S((sLst=""):"new",1:sLst_"!?"_"new") ; C1="new", C2="!?", C3=1
	WRITE "add01(R0):<"_sLst_">.add(""new"",""!?"",1)="_sRes,!
	;
	S sRes=$S((sLst=""):"mies",1:sLst_"!?"_"mies") ; C1="mies", C2="!?", C3=1
	WRITE "add01(R0):<"_sLst_">.add(""mies"",""!?"",1)="_sRes,!
	;
	S sRes=sLst ; C1 Empty, C2=",", C3=0, C4=0
	WRITE "add01(R0):<"_sLst_">.add("""","","",0,0)="_sRes,!
	;
	S sRes=$S(((","_sLst_",")[",new,"):sLst,1:$S((sLst=""):"new",1:sLst_","_"new")) ; C1="new", C2=",", C3=0, C4=0
	WRITE "add01(R0):<"_sLst_">.add(""new"","","",0,0)="_sRes,!
	;
	S sRes=$S(((","_sLst_",")[",mies,"):sLst,1:$S((sLst=""):"mies",1:sLst_","_"mies")) ; C1="mies", C2=",", C3=0, C4=0
	WRITE "add01(R0):<"_sLst_">.add(""mies"","","",0,0)="_sRes,!
	;
	S sRes=sLst ; C1 Empty, C2=":", C3=0, C4=0
	WRITE "add01(R0):<"_sLst_">.add("""","":"",0,0)="_sRes,!
	;
	S sRes=$S(((":"_sLst_":")[":new:"):sLst,1:$S((sLst=""):"new",1:sLst_":"_"new")) ; C1="new", C2=":", C3=0, C4=0
	WRITE "add01(R0):<"_sLst_">.add(""new"","":"",0,0)="_sRes,!
	;
	S sRes=$S(((":"_sLst_":")[":mies:"):sLst,1:$S((sLst=""):"mies",1:sLst_":"_"mies")) ; C1="mies", C2=":", C3=0, C4=0
	WRITE "add01(R0):<"_sLst_">.add(""mies"","":"",0,0)="_sRes,!
	;
	S sRes=sLst ; C1 Empty, C2="!?", C3=0, C4=0
	WRITE "add01(R0):<"_sLst_">.add("""",""!?"",0,0)="_sRes,!
	;
	S sRes=$S((("!?"_sLst_"!?")["!?new!?"):sLst,1:$S((sLst=""):"new",1:sLst_"!?"_"new")) ; C1="new", C2="!?", C3=0, C4=0
	WRITE "add01(R0):<"_sLst_">.add(""new"",""!?"",0,0)="_sRes,!
	;
	S sRes=$S((("!?"_sLst_"!?")["!?mies!?"):sLst,1:$S((sLst=""):"mies",1:sLst_"!?"_"mies")) ; C1="mies", C2="!?", C3=0, C4=0
	WRITE "add01(R0):<"_sLst_">.add(""mies"",""!?"",0,0)="_sRes,!
	;
	S sRes=sLst ; C1 Empty, C2=",", C3=1, C4=0
	WRITE "add01(R0):<"_sLst_">.add("""","","",1,0)="_sRes,!
	;
	S sRes=$S((sLst=""):"new",1:sLst_","_"new") ; C1="new", C2=",", C3=1, C4=0
	WRITE "add01(R0):<"_sLst_">.add(""new"","","",1,0)="_sRes,!
	;
	S sRes=$S((sLst=""):"mies",1:sLst_","_"mies") ; C1="mies", C2=",", C3=1, C4=0
	WRITE "add01(R0):<"_sLst_">.add(""mies"","","",1,0)="_sRes,!
	;
	S sRes=sLst ; C1 Empty, C2=":", C3=1, C4=0
	WRITE "add01(R0):<"_sLst_">.add("""","":"",1,0)="_sRes,!
	;
	S sRes=$S((sLst=""):"new",1:sLst_":"_"new") ; C1="new", C2=":", C3=1, C4=0
	WRITE "add01(R0):<"_sLst_">.add(""new"","":"",1,0)="_sRes,!
	;
	S sRes=$S((sLst=""):"mies",1:sLst_":"_"mies") ; C1="mies", C2=":", C3=1, C4=0
	WRITE "add01(R0):<"_sLst_">.add(""mies"","":"",1,0)="_sRes,!
	;
	S sRes=sLst ; C1 Empty, C2="!?", C3=1, C4=0
	WRITE "add01(R0):<"_sLst_">.add("""",""!?"",1,0)="_sRes,!
	;
	S sRes=$S((sLst=""):"new",1:sLst_"!?"_"new") ; C1="new", C2="!?", C3=1, C4=0
	WRITE "add01(R0):<"_sLst_">.add(""new"",""!?"",1,0)="_sRes,!
	;
	S sRes=$S((sLst=""):"mies",1:sLst_"!?"_"mies") ; C1="mies", C2="!?", C3=1, C4=0
	WRITE "add01(R0):<"_sLst_">.add(""mies"",""!?"",1,0)="_sRes,!
	;
	S sRes=sLst ; C1 Empty, C2=",", C3=0, C4=1`
	WRITE "add01(R0):<"_sLst_">.add("""","","",0,1)="_sRes,!
	;
	S sRes=$$vLstAdd(sLst,"new",",",0,1) ; C1="new", C2=",", C3=0, C4=1
	WRITE "add01(R0):<"_sLst_">.add(""new"","","",0,1)="_sRes,!
	;
	S sRes=$$vLstAdd(sLst,"mies",",",0,1) ; C1="mies", C2=",", C3=0, C4=1
	WRITE "add01(R0):<"_sLst_">.add(""mies"","","",0,1)="_sRes,!
	;
	S sRes=sLst ; C1 Empty, C2=":", C3=0, C4=1
	WRITE "add01(R0):<"_sLst_">.add("""","":"",0,1)="_sRes,!
	;
	S sRes=$$vLstAdd(sLst,"new",":",0,1) ; C1="new", C2=":", C3=0, C4=1
	WRITE "add01(R0):<"_sLst_">.add(""new"","":"",0,1)="_sRes,!
	;
	S sRes=$$vLstAdd(sLst,"mies",":",0,1) ; C1="mies", C2=":", C3=0, C4=1
	WRITE "add01(R0):<"_sLst_">.add(""mies"","":"",0,1)="_sRes,!
	;
	S sRes=sLst ; C1 Empty, C2="!?", C3=0, C4=1
	WRITE "add01(R0):<"_sLst_">.add("""",""!?"",0,1)="_sRes,!
	;
	S sRes=$$vLstAdd(sLst,"new","!?",0,1) ; C1="new", C2="!?", C3=0, C4=1
	WRITE "add01(R0):<"_sLst_">.add(""new"",""!?"",0,1)="_sRes,!
	;
	S sRes=$$vLstAdd(sLst,"mies","!?",0,1) ; C1="mies", C2="!?", C3=0, C4=1
	WRITE "add01(R0):<"_sLst_">.add(""mies"",""!?"",0,1)="_sRes,!
	;
	S sRes=sLst ; C1 Empty, C2=",", C3=1, C4=1
	WRITE "add01(R0):<"_sLst_">.add("""","","",1,1)="_sRes,!
	;
	S sRes=$$vLstAdd(sLst,"new",",",1,1) ; C1="new", C2=",", C3=1, C4=1
	WRITE "add01(R0):<"_sLst_">.add(""new"","","",1,1)="_sRes,!
	;
	S sRes=$$vLstAdd(sLst,"mies",",",1,1) ; C1="mies", C2=",", C3=1, C4=1
	WRITE "add01(R0):<"_sLst_">.add(""mies"","","",1,1)="_sRes,!
	;
	S sRes=sLst ; C1 Empty, C2=":", C3=1, C4=1
	WRITE "add01(R0):<"_sLst_">.add("""","":"",1,1)="_sRes,!
	;
	S sRes=$$vLstAdd(sLst,"new",":",1,1) ; C1="new", C2=":", C3=1, C4=1
	WRITE "add01(R0):<"_sLst_">.add(""new"","":"",1,1)="_sRes,!
	;
	S sRes=$$vLstAdd(sLst,"mies",":",1,1) ; C1="mies", C2=":", C3=1, C4=1
	WRITE "add01(R0):<"_sLst_">.add(""mies"","":"",1,1)="_sRes,!
	;
	S sRes=sLst ; C1 Empty, C2="!?", C3=1, C4=1
	WRITE "add01(R0):<"_sLst_">.add("""",""!?"",1,1)="_sRes,!
	;
	S sRes=$$vLstAdd(sLst,"new","!?",1,1) ; C1="new", C2="!?", C3=1, C4=1
	WRITE "add01(R0):<"_sLst_">.add(""new"",""!?"",1,1)="_sRes,!
	;
	S sRes=$$vLstAdd(sLst,"mies","!?",1,1) ; C1="mies", C2="!?", C3=1, C4=1
	WRITE "add01(R0):<"_sLst_">.add(""mies"",""!?"",1,1)="_sRes,!
	;
	Q 
	;
	; =====================================================================
	; validate C0.add(R1,C2,C3,C4)
add02(sElm)	;
	N sRes
	;
	; C0 = constant, all others absent
	S sRes=sElm
	WRITE "add02(R1):"""".add(<"_sElm_">)="_sRes,!
	;
	S sRes="aap,mies,noot,"_sElm
	WRITE "add02(R1):""aap,mies,noot"".add(<"_sElm_">)="_sRes,!
	;
	S sRes="aap:mies:noot,"_sElm
	WRITE "add02(R1):""aap:mies:noot"".add(<"_sElm_">)="_sRes,!
	;
	S sRes="aap!?mies!?noot,"_sElm
	WRITE "add02(R1):""aap!?mies!?noot"">.add(<"_sElm_">)="_sRes,!
	;
	; C0 = constant, C2 matches delimiter in C0, C3 and C4 absent
	S sRes=sElm
	WRITE "add02(R1):"""".add(<"_sElm_">,"""")="_sRes,!
	;
	S sRes="aap,mies,noot,"_sElm
	WRITE "add02(R1):""aap,mies,noot"".add(<"_sElm_">,"","")="_sRes,!
	;
	S sRes="aap:mies:noot:"_sElm
	WRITE "add02(R1):""aap:mies:noot"".add(<"_sElm_">,"":"")="_sRes,!
	;
	S sRes="aap!?mies!?noot!?"_sElm
	WRITE "add02(R1):""aap!?mies!?noot"".add(<"_sElm_">,""!?"")="_sRes,!
	;
	; C0 = constant, C2 matches delimiter in C0, C3=0, C4 absent
	S sRes=sElm
	WRITE "add02(R1):"""".add(<"_sElm_">,"""",0)="_sRes,!
	;
	S sRes=$S((",aap,mies,noot,"[(","_sElm_",")):"aap,mies,noot",1:"aap,mies,noot,"_sElm)
	WRITE "add02(R1):""aap,mies,noot"".add(<"_sElm_">,"","",0)="_sRes,!
	;
	S sRes=$S((":aap:mies:noot:"[(":"_sElm_":")):"aap:mies:noot",1:"aap:mies:noot:"_sElm)
	WRITE "add02(R1):""aap:mies:noot"".add(<"_sElm_">,"":"",0)="_sRes,!
	;
	S sRes=$S(("!?aap!?mies!?noot!?"[("!?"_sElm_"!?")):"aap!?mies!?noot",1:"aap!?mies!?noot!?"_sElm)
	WRITE "add02(R1):""aap!?mies!?noot"".add(<"_sElm_">,""!?"",0)="_sRes,!
	;
	; C0 = constant, C2 matches delimiter in C0, C3=1, C4 absent
	S sRes=sElm
	WRITE "add02(R1):"""".add(<"_sElm_">,"""",1)="_sRes,!
	;
	S sRes="aap,mies,noot,"_sElm
	WRITE "add02(R1):""aap,mies,noot"".add(<"_sElm_">,"","",1)="_sRes,!
	;
	S sRes="aap:mies:noot:"_sElm
	WRITE "add02(R1):""aap:mies:noot"".add(<"_sElm_">,"":"",1)="_sRes,!
	;
	S sRes="aap!?mies!?noot!?"_sElm
	WRITE "add02(R1):""aap!?mies!?noot"".add(<"_sElm_">,""!?"",1)="_sRes,!
	;
	; C0 = constant, C2 matches delimiter in C0, C3=1, C4=0
	S sRes=sElm
	WRITE "add02(R1):"""".add(<"_sElm_">,"""",1,0)="_sRes,!
	;
	S sRes="aap,mies,noot,"_sElm
	WRITE "add02(R1):""aap,mies,noot"".add(<"_sElm_">,"","",1,0)="_sRes,!
	;
	S sRes="aap:mies:noot:"_sElm
	WRITE "add02(R1):""aap:mies:noot"".add(<"_sElm_">,"":"",1,0)="_sRes,!
	;
	S sRes="aap!?mies!?noot!?"_sElm
	WRITE "add02(R1):""aap!?mies!?noot"".add(<"_sElm_">,""!?"",1,0)="_sRes,!
	;
	; C0 = constant, C2 matches delimiter in C0, C3=1, C4=1
	S sRes=$$vLstAdd("",sElm,",",1,1)
	WRITE "add02(R1):"""".add(<"_sElm_">,"""",1,1)="_sRes,!
	;
	S sRes=$$vLstAdd("aap,mies,noot",sElm,",",1,1)
	WRITE "add02(R1):""aap,mies,noot"".add(<"_sElm_">,"","",1,1)="_sRes,!
	;
	S sRes=$$vLstAdd("aap:mies:noot",sElm,":",1,1)
	WRITE "add02(R1):""aap:mies:noot"".add(<"_sElm_">,"":"",1,1)="_sRes,!
	;
	S sRes=$$vLstAdd("aap!?mies!?noot",sElm,"!?",1,1)
	WRITE "add02(R1):""aap!?mies!?noot"".add(<"_sElm_">,""!?"",1,1)="_sRes,!
	;
	Q 
	;
	; =====================================================================
	; validate C0.add(C1,R2,C3,C4)
add03(sDlm)	;
	;
	Q 
	;
	; =====================================================================
	; validate C0.add(C1,C2,R3,C4)
add04(bDup)	;
	;
	Q 
	;
	; =====================================================================
	; validate C0.add(C1,C2,C3,R4)
add05(bSrt)	;
	;
	Q 
	;
	; ====================================================================
	; validate R0.add(R1,C2,C3,C4)
add06(sLst,sElm)	;
	;
	Q 
	;
	; =====================================================================
	; validate R0.add(C1,R2,C3,C4)
add07(sLst,sDlm)	;
	;
	Q 
	;
	; =====================================================================
	; validate R0.add(C1,C2,R3,C4)
add08(sLst,bDup)	;
	;
	Q 
	;
	; =====================================================================
	; validate R0.add(C1,C2,C3,R4)
add09(sLst,bSrt)	;
	;
	Q 
	;
	; =====================================================================
	; validate C0.add(R1,R2,C3,C4)
add10(sElm,sDlm)	;
	;
	Q 
	;
	; =====================================================================
	; validate C0.add(R1,C2, Boolean bDup,C4)
add11(sElm,bDup)	;
	;
	Q 
	;
	; =====================================================================
	; validate C0.add(R1,C2,C3,R4)
add12(sElm,bSrt)	;
	N sRes
	;
	; List = "", all delimiters
	S sRes=$$vLstAdd("",sElm,",",0,bSrt)
	WRITE "add12(R1,R4):"""".add(<"_sElm_">,"""",0,<"_bSrt_">)="_sRes,!
	;
	S sRes=$$vLstAdd("",sElm,",",1,bSrt)
	WRITE "add12(R1,R4):"""".add(<"_sElm_">,"""",1,<"_bSrt_">)="_sRes,!
	;
	S sRes=$$vLstAdd("",sElm,",",0,bSrt)
	WRITE "add12(R1,R4):"""".add(<"_sElm_">,"","",0,<"_bSrt_">)="_sRes,!
	;
	S sRes=$$vLstAdd("",sElm,",",1,bSrt)
	WRITE "add12(R1,R4):"""".add(<"_sElm_">,"","",1,<"_bSrt_">)="_sRes,!
	;
	S sRes=$$vLstAdd("",sElm,":",0,bSrt)
	WRITE "add12(R1,R4):"""".add(<"_sElm_">,"":"",0,<"_bSrt_">)="_sRes,!
	;
	S sRes=$$vLstAdd("",sElm,":",1,bSrt)
	WRITE "add12(R1,R4):"""".add(<"_sElm_">,"":"",1,<"_bSrt_">)="_sRes,!
	;
	S sRes=$$vLstAdd("",sElm,"!?",0,bSrt)
	WRITE "add12(R1,R4):"""".add(<"_sElm_">,""!?"",0,<"_bSrt_">)="_sRes,!
	;
	S sRes=$$vLstAdd("",sElm,"!?",1,bSrt)
	WRITE "add12(R1,R4):"""".add(<"_sElm_">,""!?"",1,<"_bSrt_">)="_sRes,!
	;
	; List = "aap,mies,noot", delimiter = "" or ","
	S sRes=$$vLstAdd("aap,mies,noot",sElm,",",0,bSrt)
	WRITE "add12(R1,R4):""aap,mies,noot"".add(<"_sElm_">,"""""",0,<"_bSrt_">)="_sRes,!
	;
	S sRes=$$vLstAdd("aap,mies,noot",sElm,",",1,bSrt)
	WRITE "add12(R1,R4):""aap,mies,noot"".add(<"_sElm_">,"""",1,<"_bSrt_">)="_sRes,!
	;
	S sRes=$$vLstAdd("aap,mies,noot",sElm,",",0,bSrt)
	WRITE "add12(R1,R4):""aap,mies,noot"".add(<"_sElm_">,"","",0,<"_bSrt_">)="_sRes,!
	;
	S sRes=$$vLstAdd("aap,mies,noot",sElm,",",1,bSrt)
	WRITE "add12(R1,R4):""aap,mies,noot"".add(<"_sElm_">,"","",1,<"_bSrt_">)="_sRes,!
	;
	; List = "aap:mies:noot", delimiter = ":"
	S sRes=$$vLstAdd("aap:mies:noot",sElm,":",0,bSrt)
	WRITE "add12(R1,R4):""aap:mies:noot"".add(<"_sElm_">,"":"",0,<"_bSrt_">)="_sRes,!
	;
	S sRes=$$vLstAdd("aap:mies:noot",sElm,":",1,bSrt)
	WRITE "add12(R1,R4):""aap:mies:noot"".add(<"_sElm_">,"":"",1,<"_bSrt_">)="_sRes,!
	;
	; List = "aap!?mies!?noot", delimiter = "!?"
	S sRes=$$vLstAdd("aap!?mies!?noot",sElm,"!?",0,bSrt)
	WRITE "add12(R1,R4):""aap!?mies!?noot"".add(<"_sElm_">,""!?"",0,<"_bSrt_">)="_sRes,!
	;
	S sRes=$$vLstAdd("aap!?mies!?noot",sElm,"!?",1,bSrt)
	WRITE "add12(R1,R4):""aap!?mies!?noot"".add(<"_sElm_">,""!?"",1,<"_bSrt_">)="_sRes,!
	;
	Q 
	;
	; =====================================================================
	; validate C0.add(C1,R2,R3,C4)
add13(sDlm,bDup)	;
	;
	Q 
	;
	; =====================================================================
	; validate C0.add(C1,R2,C3,R4)
add14(sDlm,bSrt)	;
	;
	Q 
	;
	; =====================================================================
	; validate C0.add(C1,C2,R3,R4)
add15(bDup,bSrt)	;
	;
	Q 
	;
	; =====================================================================
	; validate R0.add(R1,R2,C3,C4)
add16(sLst,sElm,sDlm)	;
	;
	Q 
	;
	; =====================================================================
	; validate R0.add(R1,C2,R3,C4)
add17(sLst,sElm,bDup)	;
	;
	Q 
	;
	; =====================================================================
	; validate R0.add(R1,C2,C3,R4)
add18(sLst,sElm,bSrt)	;
	;
	Q 
	;
	; =====================================================================
	; validate R0.add(C1,R2,R3,C4)
add19(sLst,sDlm,bDup)	;
	;
	Q 
	;
	; =====================================================================
	; validate R0.add(C1,R2,C3,R4)
add20(sLst,sDlm,bSrt)	;
	;
	Q 
	;
	; =====================================================================
	; validate R0.add(C1,C2,R3,R4)
add21(sLst,bDup,bSrt)	;
	;
	Q 
	;
	; =====================================================================
	; validate C0.add(R1,R2,R3,C4)
add22(sElm,sDlm,bDup)	;
	;
	Q 
	;
	; =====================================================================
	; validate C0.add(R1,R2,C3,R4)
add23(sElm,sDlm,bSrt)	;
	;
	Q 
	;
	; =====================================================================
	; validate C0.add(R1,C2,R3,R4)
add24(sElm,bDup,bSrt)	;
	;
	Q 
	;
	; =====================================================================
	; validate R0.add(C1,R2,R3,R4)
add25(sDlm,bDup,bSrt)	;
	;
	Q 
	;
	; =====================================================================
	; validate R0.add(R1,R2,R3,C4)
add26(sLst,sElm,sDlm,bDup)	;
	N sRes
	;
	; exclude trivial combinations where sLst does not contain sDlm
	I sLst?1.ANP,sLst'[sDlm WRITE "add26(R0,R1,R2,R3):<"_sLst_"> does not contain <"_sDlm_">",! Q 
	;
	S sRes=$$vLstAdd(sLst,sElm,sDlm,bDup,0)
	WRITE "add26(R0,R1,R2,R3):<"_sLst_">.add(<"_sElm_">,<"_sDlm_">,<"_bDup_">,0)="_sRes,!
	;
	S sRes=$$vLstAdd(sLst,sElm,sDlm,bDup,1)
	WRITE "add26(R0,R1,R2,R3):<"_sLst_">.add(<"_sElm_">,<"_sDlm_">,<"_bDup_">,1)="_sRes,!
	;
	Q 
	;
	; =====================================================================
	; validate R0.add(R1,R2,C3,R4)
add27(sLst,sElm,sDlm,bSrt)	;
	N sRes
	;
	; exclude trivial combinations where sLst does not contain sDlm
	I sLst?1.ANP,sLst'[sDlm WRITE "add27(R0,R1,R2,R4):<"_sLst_"> does not contain <"_sDlm_">",! Q 
	;
	S sRes=$$vLstAdd(sLst,sElm,sDlm,0,bSrt)
	WRITE "add27(R0,R1,R2,R4):<"_sLst_">.add(<"_sElm_">,<"_sDlm_">,0,<"_bSrt_">)="_sRes,!
	;
	S sRes=$$vLstAdd(sLst,sElm,sDlm,1,bSrt)
	WRITE "add27(R0,R1,R2,R4):<"_sLst_">.add(<"_sElm_">,<"_sDlm_">,1,<"_bSrt_">)="_sRes,!
	;
	Q 
	;
	; =====================================================================
	; validate R0.add(R1,C2,R3,R4)
add28(sLst,sElm,bDup,bSrt)	;
	N sRes
	;
	S sRes=$$vLstAdd(sLst,sElm,",",bDup,bSrt)
	WRITE "add28(R0,R1,R3,R4):<"_sLst_">.add(<"_sElm_">,"""",<"_bDup_">,<"_bSrt_">)="_sRes,!
	;
	; exclude trivial combinations where sLst does not contain delimiter
	I (sLst[",")!(sLst="") D
	.	S sRes=$$vLstAdd(sLst,sElm,",",bDup,bSrt)
	.	WRITE "add28(R0,R1,R3,R4):<"_sLst_">.add(<"_sElm_">,"","",<"_bDup_">,<"_bSrt_">)="_sRes,!
	.	Q 
	;
	I (sLst[":")!(sLst="") D
	.	S sRes=$$vLstAdd(sLst,sElm,":",bDup,bSrt)
	.	WRITE "add28(R0,R1,R3,R4):<"_sLst_">.add(<"_sElm_">,"":"",<"_bDup_">,<"_bSrt_">)="_sRes,!
	.	;
	.	Q 
	;
	I (sLst["!?")!(sLst="") D
	.	S sRes=$$vLstAdd(sLst,sElm,"!?",bDup,bSrt)
	.	WRITE "add28(R0,R1,R3,R4):<"_sLst_">.add(<"_sElm_">,""!?"",<"_bDup_">,<"_bSrt_">)="_sRes,!
	.	Q 
	Q 
	;
	; =====================================================================
	; validate R0.add(C1,R2,R3,R4)
add29(sLst,sDlm,bDup,bSrt)	;
	N sRes
	;
	; exclude trivial combinations where sLst does not contain sDlm
	I sLst?1.ANP,sLst'[sDlm WRITE "add29(R0,R2,R3,R4):<"_sLst_"> does not contain <"_sDlm_">",! Q 
	;
	S sRes=sLst
	WRITE "add29(R0,R2,R3,R4):<"_sLst_">.add("""",<"_sDlm_">,<"_bDup_">,<"_bSrt_">)="_sRes,!
	;
	S sRes=$$vLstAdd(sLst,"new",sDlm,bDup,bSrt)
	WRITE "add29(R0,R2,R3,R4):<"_sLst_">.add(""new"",<"_sDlm_">,<"_bDup_">,<"_bSrt_">)="_sRes,!
	;
	S sRes=$$vLstAdd(sLst,"mies",sDlm,bDup,bSrt)
	WRITE "add29(R0,R2,R3,R4):<"_sLst_">.add(""mies"",<"_sDlm_">,<"_bDup_">,<"_bSrt_">)="_sRes,!
	;
	Q 
	;
	; =====================================================================
	; validate C0.add(R1,R2,R3,R4)
add30(sElm,sDlm,bDup,bSrt)	;
	N sRes
	;
	S sRes=$$vLstAdd("",sElm,sDlm,bDup,bSrt)
	WRITE "add30(R1,R2,R3,R4):"""".add(<"_sElm_">,<"_sDlm_">,<"_bDup_">,<"_bSrt_">)="_sRes,!
	;
	; exclude trivial combinations where sDlm neither a comma nor empty
	I ","[sDlm D
	.	S sRes=$$vLstAdd("aap,mies,noot",sElm,sDlm,bDup,bSrt)
	.	WRITE "add30(R1,R2,R3,R4):""aap,mies,noot"".add(<"_sElm_">,<"_sDlm_">,<"_bDup_">,<"_bSrt_">)="_sRes,!
	.	Q 
	;
	; exclude trivial combinations where sDlm neither a colon nor empty
	I ":"[sDlm D
	.	S sRes=$$vLstAdd("aap:mies:noot",sElm,sDlm,bDup,bSrt)
	.	WRITE "add30(R1,R2,R3,R4):""aap:mies:noot"".add(<"_sElm_">,<"_sDlm_">,<"_bDup_">,<"_bSrt_">)="_sRes,!
	.	Q 
	;
	; exclude trivial combinations where sDlm completely different
	I "!?"[sDlm D
	.	S sRes=$$vLstAdd("aap!?mies!?noot",sElm,sDlm,bDup,bSrt)
	.	WRITE "add30(R1,R2,R3,R4):""aap!?mies!?noot"".add(<"_sElm_">,<"_sDlm_">,<"_bDup_">,<"_bSrt_">)="_sRes,!
	.	Q 
	Q 
	;
	; =====================================================================
	; validate R0.add(R1,R2,R3,R4)
add31(sLst,sElm,sDlm,bDup,bSrt)	;
	N sRes
	;
	S sRes=$$vLstAdd(sLst,sElm,sDlm,bDup,bSrt)
	WRITE "add31(R0,R1,R2,R3,R4):<"_sLst_">.add(<"_sElm_">,<"_sDlm_">,<"_bDup_">,<"_bSrt_">)="_sRes,!
	;
	Q 
	;
vSIG()	;
	Q "60023^57487^wittefs^26388" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vLstAdd(object,p1,p2,p3,p4)	; List.add
	;
	;  #OPTIMIZE FUNCTIONS OFF
	I (object="") Q p1
	I (p2="") S p2=","
	I 'p3,'(p3=""),((p2_object_p2)[(p2_p1_p2)) Q object
	I 'p4 Q object_p2_p1
	;
	I $piece(object,p2,1)]]p1 Q p1_p2_object
	I p1]]$piece(object,p2,$L(object,p2)) Q object_p2_p1
	;
	N i
	F i=1:1:$L(object,p2) I $piece(object,p2,i)]]p1 Q 
	Q $piece(object,p2,1,i-1)_p2_p1_p2_$piece(object,p2,i,$L(object))
