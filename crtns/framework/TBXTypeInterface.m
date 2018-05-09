 ; 
 ; **** Routine compiled from DATA-QWIK Procedure TBXTypeInterface ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
 ;  #PACKAGE framework.tbx
 ;  #CLASSDEF extends=Primitive
 ;
 ;  #PROPERTYDEF returnSUCCESS = "1" class=String protected literal
 ;  #PROPERTYDEF returnFAILURE = "0" class=String protected literal
 ;  #PROPERTYDEF returnDELIM   = "|" class=String protected literal
 ;
 ;  #PROPERTYDEF element  class=String public readonly position=2
 ;
 ;  #PROPERTYDEF elemType  class=String public readonly position=3
 ;
 ;  #PROPERTYDEF elemTypeAGR   = "AGR"   class=String protected literal
 ;  #PROPERTYDEF elemTypeBATCH = "BATCH" class=String protected literal
 ;  #PROPERTYDEF elemTypeCOL   = "COL"   class=String protected literal
 ;  #PROPERTYDEF elemTypeDAT   = "DAT"   class=String protected literal
 ;  #PROPERTYDEF elemTypeFKY   = "FKY"   class=String protected literal
 ;  #PROPERTYDEF elemTypeG     = "G"     class=String protected literal
 ;  #PROPERTYDEF elemTypeIDX   = "IDX"   class=String protected literal
 ;  #PROPERTYDEF elemTypeJDF   = "JFD"   class=String protected literal
 ;  #PROPERTYDEF elemTypeLUD   = "LUD"   class=String protected literal
 ;  #PROPERTYDEF elemTypeM     = "m"     class=String protected literal
 ;  #PROPERTYDEF elemTypePPL   = "PPL"   class=String protected literal
 ;  #PROPERTYDEF elemTypePROC  = "PROC"  class=String protected literal
 ;  #PROPERTYDEF elemTypePSL   = "psl"   class=String protected literal
 ;  #PROPERTYDEF elemTypePSLX  = "pslx"  class=String protected literal
 ;  #PROPERTYDEF elemTypeQRY   = "QRY"   class=String protected literal
 ;  #PROPERTYDEF elemTypeRPT   = "RPT"   class=String protected literal
 ;  #PROPERTYDEF elemTypeSCR   = "SCR"   class=String protected literal
 ;  #PROPERTYDEF elemTypeTBL   = "TBL"   class=String protected literal
 ;  #PROPERTYDEF elemTypeTRIG  = "TRIG"  class=String protected literal
 ;
 ;  #PROPERTYDEF elemTypeUNKNOWN = "N-N" class=String protected literal
 ;
 ;  #PROPERTYDEF elemName  class=String public readonly position=4
 ;
 ;  #PROPERTYDEF elemNameAGR   = "Aggregate"    class=String protected literal
 ;  #PROPERTYDEF elemNameBATCH = "Batch"        class=String protected literal
 ;  #PROPERTYDEF elemNameCOL   = "Column"       class=String protected literal
 ;  #PROPERTYDEF elemNameDAT   = "Data"         class=String protected literal
 ;  #PROPERTYDEF elemNameFKY   = "Foreign Key"  class=String protected literal
 ;  #PROPERTYDEF elemNameG     = "Global"       class=String protected literal
 ;  #PROPERTYDEF elemNameIDX   = "Index"        class=String protected literal
 ;  #PROPERTYDEF elemNameJDF   = "Journal"      class=String protected literal
 ;  #PROPERTYDEF elemNameLUD   = "Lookup Doc"   class=String protected literal
 ;  #PROPERTYDEF elemNameM     = "M routine"    class=String protected literal
 ;  #PROPERTYDEF elemNamePPL   = "Pre Post Lib" class=String protected literal
 ;  #PROPERTYDEF elemNamePROC  = "Procedure"    class=String protected literal
 ;  #PROPERTYDEF elemNamePSL   = "psl File"     class=String protected literal
 ;  #PROPERTYDEF elemNamePSLX  = "pslx File"    class=String protected literal
 ;  #PROPERTYDEF elemNameQRY   = "Query"        class=String protected literal
 ;  #PROPERTYDEF elemNameRPT   = "Report"       class=String protected literal
 ;  #PROPERTYDEF elemNameSCR   = "Screen"       class=String protected literal
 ;  #PROPERTYDEF elemNameTBL   = "Table"        class=String protected literal
 ;  #PROPERTYDEF elemNameTRIG  = "Trigger"      class=String protected literal
 ;
 ;  #PROPERTYDEF elemNameUNKNOWN = "Unknown Type" class=String protected literal
 ;
 ;  #PROPERTYDEF elemTypeList  = "AGR,BATCH,COL,DAT,FKY,G,IDX,JDF,LUD,PPL,PROC,psl,pslx,QRY,RPT,SCR,TBL,TRIG"  class=List protected literal
 ;  #PROPERTYDEF elemNameList  = "Aggregate,Batch,Column,Data,Foreign Key,Global,Index,Journal,Lookup Doc,Pre Post Lib,Procedure,psl file,pslx file,Query,Report,Screen,Table,Trigger"  class=List protected literal
 ;
 ;  #PROPERTYDEF elemModeNEW    = 0 class=Integer protected literal
 ;  #PROPERTYDEF elemModeEXISTS = 1 class=Integer protected literal
 ;
 ;  #PROPERTYDEF tbxTypeINST = 1 class=Integer protected literal
 ;  #PROPERTYDEF tbxTypeMRPC = 3 class=Integer protected literal
 ;
 ; ---------------------------------------------------------------------
getMrpcDir() ; 
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 Q $$TRNLNM^%ZFUNC("SCAU_SPOOL")_"/"
 ;
 ; ---------------------------------------------------------------------
MRPCTERM() ; 
 Q $C(13,10)
 ;
 ; ---------------------------------------------------------------------
name4type(elemType) ; 
 N pos S pos=$$vlstPos("AGR,BATCH,COL,DAT,FKY,G,IDX,JDF,LUD,PPL,PROC,psl,pslx,QRY,RPT,SCR,TBL,TRIG",elemType,",",1)
 I pos=0 Q "Unknown Type"
 ;
 Q $piece("Aggregate,Batch,Column,Data,Foreign Key,Global,Index,Journal,Lookup Doc,Pre Post Lib,Procedure,psl file,pslx file,Query,Report,Screen,Table,Trigger",",",pos)
 ;
 ; ---------------------------------------------------------------------
newInstance(file) ; return a new instance based on the supplied file
 I $L(file,".")'=2!($L(file,"/")>2) S $ZE="0,"_$ZPOS_","_"%TBX-E-TYPE,Invalid filename '"_file_"'",$EC=",U1001,"
 ;
 N ext S ext=$ZCONVERT($piece(file,".",2),"U")
 N elem S elem=$piece(file,".")
 ;
 N tti
 ;
 I 0 ;* if false  // more to come
 E  I ext="PSL" S tti=$$vcdmNew^TBXPSL("TBXPSL",elem) S $P(tti,"|",3)="psl"
 E  I ext="PSLX" S tti=$$vcdmNew^TBXPSLX("TBXPSLX",elem) S $P(tti,"|",3)="pslx"
 E  S tti=$$vcdmNew^TBXTypeInterface("TBXTypeInterface",elem) S $P(tti,"|",3)="N-N"
 ;
 S $P(tti,"|",4)=$$name4type(ext)
 Q tti
 ;
 ; ---------------------------------------------------------------------
newInstance4name(name,elem) ; return a new instance based on the supplied name and element
 ;type static TBXTypeInterface
 N elemType S elemType=$$type4name(name,elem)
 Q $$newInstance(elem_"."_elemType)
 ;
 ; ---------------------------------------------------------------------
type4name(name,elem) ; 
 ;type static TBXDATA  // needed for ".DAT" versus ".G"
 N pos S pos=$$vlstPos("Aggregate,Batch,Column,Data,Foreign Key,Global,Index,Journal,Lookup Doc,Pre Post Lib,Procedure,psl file,pslx file,Query,Report,Screen,Table,Trigger",name,",",1)
 I pos=0 Q "N-N"
 ;
 N elemType S elemType=$piece("AGR,BATCH,COL,DAT,FKY,G,IDX,JDF,LUD,PPL,PROC,psl,pslx,QRY,RPT,SCR,TBL,TRIG",",",pos)
 ;if elemType = TBXTypeInterface.elemTypeDATA quit TBXTDATA.type4elem( elem)
 Q elemType
 ;
 ; ---------------------------------------------------------------------
initialize(this,initObj) ; 
 S $P(this,"|",2)=initObj
 Q 
 ;
 ; ---------------------------------------------------------------------
elemDrop(this) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"elemDrop")) Q $$v0elemDrop^@vPslPoly(vC,"elemDrop")(.this)
 Q $$v0elemDrop(.this)
v0elemDrop(this) ; Drop an obsolete element
 Q $$failure(.this,"not implemented")
 ;
 ; ---------------------------------------------------------------------
elemGet(this,path,file) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"elemGet")) Q $$v0elemGet^@vPslPoly(vC,"elemGet")(.this,.path,.file)
 Q $$v0elemGet(.this,.path,.file)
v0elemGet(this,path,file) ; write the element's data into path/file
 Q $$failure(.this,"not implemented")
 ;
 ; ---------------------------------------------------------------------
elemPut(this,path,file,reltype,lmu,lmd,lmt) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"elemPut")) Q $$v0elemPut^@vPslPoly(vC,"elemPut")(.this,.path,.file,.reltype,.lmu,.lmd,.lmt)
 Q $$v0elemPut(.this,.path,.file,.reltype,.lmu,.lmd,.lmt)
v0elemPut(this,path,file,reltype,lmu,lmd,lmt) ; read contents of element from path/file
 Q $$failure(.this,"not implemented")
 ;
 ; ---------------------------------------------------------------------
failure(this,msg) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"failure")) Q $$v0failure^@vPslPoly(vC,"failure")(.this,.msg)
 Q $$v0failure(.this,.msg)
v0failure(this,msg) ; Create a return string for a failure
 I (msg="") Q "0"
 Q "0"_"|"_msg
 ;
 ; ---------------------------------------------------------------------
getLastMod(this,lmu,lmd,lmt) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"getLastMod")) D v0getLastMod^@vPslPoly(vC,"getLastMod")(.this,.lmu,.lmd,.lmt) Q
 D v0getLastMod(.this,.lmu,.lmd,.lmt) Q
v0getLastMod(this,lmu,lmd,lmt) ; return the user, date and time of last modification
 S lmu=%UID
 S lmd=$P($H,",",1)
 S lmt=$P($H,",",2)
 Q 
 ;
 ; ---------------------------------------------------------------------
getMode(this) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"getMode")) Q $$v0getMode^@vPslPoly(vC,"getMode")(.this)
 Q $$v0getMode(.this)
v0getMode(this) ; Return mode of element
 Q 0
 ;
 ; ---------------------------------------------------------------------
mrpcGet(this,token,fileName) ; Get element contents
 S fileName=$P(this,"|",2)_"."_$P(this,"|",3)
 N retval S retval=$$elemGet(.this,$$getMrpcDir(),token)
 Q $$vStrRep(retval,"|",$$MRPCTERM(),0,0,"")
 ;
 ; ---------------------------------------------------------------------
mrpcLastMod(this) ; return the user, date and time of last modification
 N retval S retval=$P(this,"|",4)_": "_$P(this,"|",2)
 ;
 I $$getMode(.this)=0 D
 .	S retval="Create new "_retval
 .	Q 
 E  D
 .	N lmu
 .	N lmd
 .	N lmt
 .	D getLastMod(.this,.lmu,.lmd,.lmt)
 .	S retval="Update "_retval_" Modified by "_lmu_" on "_$S(lmd'="":$ZD(lmd,"MM/DD/YEAR"),1:"")_" at "_$$vtim2str(lmt,"24:60:SS")
 .	Q 
 ;  #ACCEPT GROUP=ACCESS;CR=27800;DATE=2008-02-27;PGM=Frans S.C. Witte
 Q "1"_$$MRPCTERM()_retval_" in "_$$SCAU^%TRNLNM("DDPLOG")
 ;
 ; ---------------------------------------------------------------------
mrpcPut(this,tmpfile,lmu) ; 
 N retval S retval=$$elemPut(.this,$$getMrpcDir(),tmpfile,3,lmu,$P($H,",",1),$P($H,",",2))
 Q $$vStrRep(retval,"|",$$MRPCTERM(),0,0,"")
 ;
 ; ---------------------------------------------------------------------
openRead(this,dir,file) ; 
 N retval S retval=$$vClVobj($ST,"IO")
 S $P(vobj(retval,1),"|",2)=dir
 S $P(vobj(retval,1),"|",1)=file
 S $P(vobj(retval,1),"|",3)="READ"
 S $P(vobj(retval,1),"|",5)=1048575
 ;
 D open^UCIO(retval,$T(+0),"openRead","retval")
 Q retval
 ;
 ; ---------------------------------------------------------------------
openWrite(this,dir,file) ; 
 N retval S retval=$$vClVobj($ST,"IO")
 S $P(vobj(retval,1),"|",2)=dir
 S $P(vobj(retval,1),"|",1)=file
 S $P(vobj(retval,1),"|",3)="NEWV"
 S $P(vobj(retval,1),"|",5)=1048575
 ;
 D open^UCIO(retval,$T(+0),"openWrite","retval")
 Q retval
 ;
 ; ---------------------------------------------------------------------
success(this,msg) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"success")) Q $$v0success^@vPslPoly(vC,"success")(.this,.msg)
 Q $$v0success(.this,.msg)
v0success(this,msg) ; Create a return string for success
 I (msg="") Q "1"
 Q "1"_"|"_msg
 ;  #OPTION ResultClass ON
vSIG(this) ; polymorphism dispatch
 N vC S vC=$P($G(this),$C(124))
 I $D(vPslPoly(vC,"vSIG")) Q $$v0vSIG^@vPslPoly(vC,"vSIG")(.this)
 Q $$v0vSIG(.this)
v0vSIG(this) ; 
 Q "61495^37421^e0101572^17984" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vlstPos(object,p1,p2,p3) ; List.position
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I p3 S object=$ZCONVERT(object,"U") S p1=$ZCONVERT(p1,"U")
 S object=p2_object_p2 S p1=p2_p1_p2
 I object'[p1 Q 0
 Q $L($piece(object,p1,1),p2)
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
vtim2str(vo,vm) ; Time.toString
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I (vo="") Q ""
 I (vm="") S vm="24:60:SS"
 N cc
 ;  #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=BYPASS
 ;*** Start of code by-passed by compiler
 SET cc=$ZDATE(","_vo,vm)
 ;*** End of code by-passed by compiler ***
 Q cc
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
vClVobj(vSt,vCls) ; Create a new object
 ;
 N vOid
 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)=vCls_$C(9)_vSt
 Q vOid
vcdmNew(vC,vInitObj) ; Constructor, called for Class.new()
 N this
 S this=vC
 D initialize(.this,.vInitObj)
 Q this
