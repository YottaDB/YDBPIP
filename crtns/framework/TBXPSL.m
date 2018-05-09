 ; 
 ; **** Routine compiled from DATA-QWIK Procedure TBXPSL ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
 ;  #CLASSDEF extends=TBXTypeInterface
 ;  #PACKAGE framework.tbx
 ;
 ; ---------------------------------------------------------------------
elemDrop(this) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"elemDrop")) Q $$v0elemDrop^@vPslPoly(vC,"elemDrop")(.this)
 Q $$v0elemDrop(.this)
v0elemDrop(this) ; drop this element
 N full S full=$$getFullPath(.this)
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=?;DATE=2009-01-15;PGM=Frans S.C. Witte
 N ign S ign=$$DELETE^%OSSCRPT(full_","_full_"x")
 Q "1"
 ;
 ; ---------------------------------------------------------------------
elemGet(this,path,file) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"elemGet")) Q $$v0elemGet^@vPslPoly(vC,"elemGet")(.this,.path,.file)
 Q $$v0elemGet(.this,.path,.file)
v0elemGet(this,path,file) ; write the element's data into path/file
 ;  #ACCEPT GROUP=ACCESS;CR=?;DATE=2009-01-15;PGM=Frans S.C. Witte
 N ign S ign=$$COPYFIL^%OSSCRPT($$getFullPath(.this),path_"/"_file)
 Q "1"
 ;
 ; ---------------------------------------------------------------------
elemPut(this,path,file,reltype,lmu,lmd,lmt) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"elemPut")) Q $$v0elemPut^@vPslPoly(vC,"elemPut")(.this,.path,.file,.reltype,.lmu,.lmd,.lmt)
 Q $$v0elemPut(.this,.path,.file,.reltype,.lmu,.lmd,.lmt)
v0elemPut(this,path,file,reltype,lmu,lmd,lmt) ; read contents of element from path/file
 ;  #ACCEPT GROUP=ACCESS;CR=?;DATE=2009-01-15;PGM=Frans S.C. Witte
 N ign S ign=$$COPYFIL^%OSSCRPT(path_"/"_file,$$getFullPath(.this))
 Q "1"
 ;
 ; ---------------------------------------------------------------------
getLastMod(this,lmu,lmd,lmt) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"getLastMod")) D v0getLastMod^@vPslPoly(vC,"getLastMod")(.this,.lmu,.lmd,.lmt) Q
 D v0getLastMod(.this,.lmu,.lmd,.lmt) Q
v0getLastMod(this,lmu,lmd,lmt) ; return the user, date, and time of last modification
 S lmu="N.N."
 ;
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N filmod S filmod=$$FILE^%ZFUNC($$getFullPath(.this),"CDT")
 ;
 S lmd=+$piece(filmod,",")
 S lmt=+$piece(filmod,",",2)
 Q 
 ;
 ; ---------------------------------------------------------------------
getMode(this) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"getMode")) Q $$v0getMode^@vPslPoly(vC,"getMode")(.this)
 Q $$v0getMode(.this)
v0getMode(this) ; Return mode of element
 N full S full=$$getFullPath(.this)
 N bExists
 ;
 ;  #ACCEPT GROUP=BYPASS;CR=?;DATE=2009-01-15;PGM=Frans S.C. Witte
 ;*** Start of code by-passed by compiler
 SET bExists=$ZSEARCH(full,0)]""
 ;*** End of code by-passed by compiler ***
 ;
 Q $S(bExists:1,1:0)
 ;
 ; =====================================================================
 ; local support methods
 ; =====================================================================
 ;
 ; ---------------------------------------------------------------------
getFullPath(this) ; return the complete full path name of the element
 Q $$pslRoot^PSLC()_"/"_$P(this,"|",2)_"."_$P(this,"|",3)
 ;  #OPTION ResultClass ON
vSIG(this) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"vSIG")) Q $$v0vSIG^@vPslPoly(vC,"vSIG")(.this)
 Q $$v0vSIG(.this)
v0vSIG(this) ; 
 Q "61495^37535^e0101572^5616" ; Signature - LTD^TIME^USER^SIZE
vcdmNew(vC,vInitObj) ; Constructor, called for Class.new()
 N this
 S this=$$vcdmNew^TBXTypeInterface(vC,vInitObj)
 I '$D(vPslPoly("TBXPSL")) D
 . M vPslPoly("TBXPSL")=vPslPoly("TBXTypeInterface")
 . S vPslPoly("TBXPSL","elemDrop")="TBXPSL"
 . S vPslPoly("TBXPSL","elemGet")="TBXPSL"
 . S vPslPoly("TBXPSL","elemPut")="TBXPSL"
 . S vPslPoly("TBXPSL","getLastMod")="TBXPSL"
 . S vPslPoly("TBXPSL","getMode")="TBXPSL"
 . S vPslPoly("TBXPSL","vSIG")="TBXPSL"
 Q this
