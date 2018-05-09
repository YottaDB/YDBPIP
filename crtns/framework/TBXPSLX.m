 ; 
 ; **** Routine compiled from DATA-QWIK Procedure TBXPSLX ****
 ; 
 ; 02/12/2010 14:41 - kbhaskar
 ; 
 ;  #CLASSDEF extends=TBXTypeInterface
 ;  #PACKAGE framework.tbx
 ;
 ; =====================================================================
 ; Static INSTALL interface (CHECK(), LOAD(), OBS()
 ; =====================================================================
 ;
 ; ---------------------------------------------------------------------
CHECK(file,lmu,lmd,lmt) ; 
 Q "1"
 ;
 ; ---------------------------------------------------------------------
LOAD(srcfile) ; Old TBX install LOAD interface
 N len S len=$L(srcfile,"/")
 N dir S dir=$piece(srcfile,"/",1,len-2)
 N file S file=$E(srcfile,$L(dir)+2,1048575)
 ;
 I $piece(file,"/")="dataqwik" S dir=dir_"/dataqwik" S file=$piece(file,"/",2)
 ;
 N tbx S tbx=$$vcdmNew^TBXPSLX("TBXPSLX",$$toElement(file))
 Q $$elemPut(.tbx,dir,file_"."_$P(tbx,"|",3),1,"",0,0)
 ;
 ; ---------------------------------------------------------------------
OBSDQW(file) ; 
 S file=$$toElement(file)
 ;
 N tbx S tbx=$$vcdmNew^TBXPSLX("TBXPSLX",file)
 Q $$elemDrop(.tbx)
 ;
 ; =====================================================================
 ; Other static methods
 ; =====================================================================
 ;
 ; ---------------------------------------------------------------------
file2Element(file) ; 
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N mod S mod=$$PARSE^%ZFUNC(file,"NAME")
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N dir S dir=$$PARSE^%ZFUNC(file,"DIRECTORY")
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 N pslx  D vcdmNew^PSLX(.pslx,"PSLX",$$FILE^%TRNLNM(mod,dir))
 ;
 D classOnly^PSLX(.pslx)
 ;
 N ocd S ocd=$$getPSLClass^PSLCC(.pslx,mod)
 N elem S elem=$$getPackageRoot^PSLClass(.ocd)_"/"_mod
 Q elem
 ;
 ; ---------------------------------------------------------------------
toElement(elem) ; 
 I $L(elem,"/")=1 Q "framework/"_$piece(elem,".")
 I $piece(elem,"/")="pslx" S $piece(elem,"/")="framework"
 Q $piece(elem,".")
 ;
 ; =====================================================================
 ; Instance interface
 ; =====================================================================
 ;
 ; ---------------------------------------------------------------------
elemDrop(this) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"elemDrop")) Q $$v0elemDrop^@vPslPoly(vC,"elemDrop")(.this)
 Q $$v0elemDrop(.this)
v0elemDrop(this) ; drop this element
 ;  #ACCEPT GROUP=ACCESS;CR=?;DATE=2009-01-15;PGM=Frans S.C. Witte
 N ign S ign=$$DELETE^%OSSCRPT($$getFullPath(.this))
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
 Q "61492^80137^e0101572^7822" ; Signature - LTD^TIME^USER^SIZE
vcdmNew(vC,vInitObj) ; Constructor, called for Class.new()
 N this
 S this=$$vcdmNew^TBXTypeInterface(vC,vInitObj)
 I '$D(vPslPoly("TBXPSLX")) D
 . M vPslPoly("TBXPSLX")=vPslPoly("TBXTypeInterface")
 . S vPslPoly("TBXPSLX","elemDrop")="TBXPSLX"
 . S vPslPoly("TBXPSLX","elemGet")="TBXPSLX"
 . S vPslPoly("TBXPSLX","elemPut")="TBXPSLX"
 . S vPslPoly("TBXPSLX","getLastMod")="TBXPSLX"
 . S vPslPoly("TBXPSLX","getMode")="TBXPSLX"
 . S vPslPoly("TBXPSLX","vSIG")="TBXPSLX"
 Q this
