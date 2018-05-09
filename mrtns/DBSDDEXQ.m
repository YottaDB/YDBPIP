DBSDDEXQ	;
	;;Copyright(c)2002 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/10/02 14:42:12 - GARBERB
	; ORIG:	CHIANG - 10/14/94
	; DESC:	Utility to export and import data files
	;
	; KEYWORDS:	IMPORT,EXPORT
	;
	; LIBRARY:
	;		EXP	Export data files
	;		IMP	Import data files
	;
	;---------- Revision History ------------------------------------------
	; 02/20/07 - GIRIDHARANB - CR25418
	;	     Added a quit at the end of header section
	;
	; 12/05/05 - RussellDS - CR18400
	;	     Redirect addz1^DBSDD and gbl^DBSDD to ^DBSLOD.
	;
	; 10/31/05 - RussellDS - CR17834
	;	     Moved code sections from DBSINS into this routine as it is
	;	     now the only user and DBSINS has been obsoleted.  This
	;	     includes sections INS, LOCK, MAPKEY, MAPDTA, MAP, PUTSUB,
	;	     GETSUB, vinit, DEFAULT, and ERR.
	;
	;	     Modified call to DBSFILER to match changes.  Now calls
	;	     EXT.
	;
	;	     Removed old revision history.
	;
	;----------------------------------------------------------------------
EXP(file,opt,query)	;Private;Export data files
	;----------------------------------------------------------------------
	; General purpose utility to output a data file to a RMS file.
	; The first record is the file name then followed by the data item
	; names and the field values.
	;
	;   File name,Data item list (separated by a comma)
	;   C/D,field values (separated by a | delimiter)
	;
	;	UTBLCC,CCODE,DESC		; file,dinam1,dinam2,...
	;	C,1|Regular Customer		; opt,data1|data2
	;	C.2|Preferred Customer
	;	C,3|Mandatory Check Cashing
	;	C,4|Privileged Check Cashing
	;       <EOR>
	;
	; ARGUMENTS:
	;	. file	DQ file name		/TYP=T/REQ/TBL=[DBTBL1]/MECH=VAL
	;
	;	. opt   Option			/TYP=T/NOREQ/DEF=C/MECH=VAL
	;               C=Create D=Delete
	;
	;	. query Query definition	/TYP=T/NOREQ/MECH=VAL
	;
	; INPUTS:
	;	. %LIBS Library name
	;
	; RETURNS:
	;	. ER	Error flag		/TYP=N
	;	. RM    Error message		/TYP=T
	;
	; RELATED:
	;	. $$OPEN^DBSFETCH - Use this utility to open a cursor
	;       . $$FETCH^DBSFETCH - Use this utility to fetch records
	;       
	; EXAMPLE:
	;	
	;	S X=$$FILE^%ZOPEN(RMSFILE,"WRITE/NEWV",5,4096) I 'X Q
	;	U RMSFILE D EXP^DBSDDEXQ("TRN","C","[TRN]ETC=SW,DW")
	;
	;----------------------------------------------------------------------
	N list,vsql,v,vexe,i,fsn,vfsn,nod,vdd,Q,X
	I $G(opt)="" S opt="C"					; Create/Delete
	I $G(query)'="" S X=query D ^DBSQRY			; Query
	;
	I $G(%LIBS)="" N %LIBS S %LIBS=^CUVAR("%LIBS")
	I '$D(^DBTBL(%LIBS,1,file)) S ER=1,RM=$$^MSG(1337,file) Q  ; Invalid file name
	;
	I opt="D" D						; Delete option
	.	D fsn^DBSDD(.vfsn,file)				; File attributes
	.	S list=$P(vfsn(file),"|",3)			; Access keys
	E  S list=$$GETLIST^DBE(file)				; Full item list
	;
	; PAR 08/29/01 Write the header even if there is no data
	W file,",",list,!
	; I18N=OFF						; File,dinam,...
	S vsql=$$OPEN^DBSFETCH(.vexe,file,list,.Q)		; Open cursor
	; I18N=ON
	; PAR 08/29/01 If there is no data, insert an end of record(s) marker
	I 'vsql W "<EOR>",! Q					; Error
	;							; Get record
	; *** 01/31/97
	; I18N=OFF
	F  S vsql=$$FETCH^DBSFETCH(.vexe,.v) Q:'vsql  W opt,",",$TR(v,$C(9),"|"),!
	; I18N=ON
	W "<EOR>",!						; End marker
	Q
	;----------------------------------------------------------------------
IMP	;Private;Import data files
	;----------------------------------------------------------------------
	; General purpose loader to read in a data file (created with the
	; EXP routine) and update the database.
	;
	; INPUTS:
	;	. %LIBS Library name
	;	. IO    RMS file name
	;
	; RETURNS:
	;	. ER	Error flag		/TYP=N
	;	. RM    Error message		/TYP=T
	;
	; EXAMPLE:
	;
	; 	S X=$$FILE^%ZOPEN(IO,"READ",5) I 'X Q
	;	U IO D IMP^DBSDDEXQ
	;----------------------------------------------------------------------
	N end,file,keys,keyl,list,map,type,data,vdd,x,value,vfsn
	;
	I $G(%LIBS)="" N %LIBS S %LIBS=^CUVAR("%LIBS")
	S end=0
	; I18N=OFF
	F  U IO R x Q:x="<BOF>"				; Search for header
	R x D header					; First file header
	
	F  U IO R x D  Q:end
	.	I x'="<EOR>" D exec Q 			; Insert record
	.	K map,vdd,vfsn				; End of one file
	.	R x
	.	I x'="<EOF>" D header Q 		; Next file header
	.	S end=1 Q				; End of input
	; I18N=ON
	Q
	;----------------------------------------------------------------------
exec	;	
	S type=$P(x,",",1),data=$P(x,",",2,999)		; Record
	;
	I file="TRNAUT",$P(data,"|",2)="*" S ^TRN($P(data,"|",1),2,$P(data,"|",2))="" Q
	;
	I type="D" D INS(file,list,data,3) Q		; Delete record
	I type="C" D
	.	S value=$P(data,"|",1,keyl)		; Key values
	.	D INS(file,keys,value,3)		; Delete record first
	.	I file="TRN" N par S par="/NOVALDD"     ; BLG - 09/09/02 - 50825
	.	D INS(file,list,data,0,.map)  		; Create new record
	Q
	;----------------------------------------------------------------------
header	; file name,dinam1,dinam2,...
	;----------------------------------------------------------------------
	S file=$P(x,",",1)				; File name
	S list=$P(x,",",2,9999)				; Data item list
	D fsn^DBSDD(.vfsn,file)				; File attributes
	S keys=$P(vfsn(file),"|",3)			; Access keys
	S keyl=$L(keys,",")				; Number of keys
	Q
	;----------------------------------------------------------------------
INS(fid,sel,rec,opt,map,fsn,vdd,ver,jrn)	;Private; Insert record into a MUMPS database
	;----------------------------------------------------------------------
	; Inserts records into a MUMPS database record based on 
	; the mapping of the select list to the underlying
	; physical structure. Key fields are mapped to their local
	; variable names. See $$MAP for the definition of the map
	; parameter.  Data type conversion (See CVT) and field
	; validaton (See $$VAL). 
	;
	; KEYWORDS: Database
	;
	; ARGUMENTS:
	;	. fid	File List		/REQ/MECH=VAL/TBL=[DBTBL1]
	;	. sel	Select list		/REQ/MECH=VAL
	;	. rec	Record Data		/REQ/MECH=REFARRY:R
	;	. opt	Update Option (0,1,3)	/MECH=VAL
	;		0=create 1=modify 3=delete
	;	. map	Record Map (see $$MAP)	/MECH=REFNAM:RW
	;	. fsn	File Information	/MECH=REFNAM:RW
	;	. vdd	Dictionary Attributes	/MECH=REFNAM:RW
	;	. ver	Verification list	/NOREQ/MECH=VAL
	;               (Original value)
	;	. jrn	Journal history(Y/N)	/NOREQ/MECH=VAL
	; RETURNS:
	;
	;	. ER	Fatal Error Indicator		/TYP=N
	;	. RM	Return Message			/COND
	;
	; EXAMPLE:
	;
	;	D INS("UTBLBRCD","BRCD,DESC","999|TEST BRANCH",0)
	;	D INS("DEP","CID,BOO,LNM","2|5|JOHN DOE",1)
	;       D INS("DEP","CID,BOO","12345|1",1,,,,"12345|2")
	;	D INS("UTBLBRCD","BRCD","123",3)
	;----------------------------------------------------------------------
	S ER=0
	;
	N acc,gbl,loc,lockgbl,new,ptr,v,z,UX,map,typsave
	;
	S lockgbl=1
	I $G(%LIBS)="" N %LIBS S %LIBS=^CUVAR("%LIBS")
	I '$D(fsn(fid)) D fsn^DBSDD(.fsn,fid) Q:ER
	S z=fsn(fid),new=$P(z,"|",1),acc=$P(z,"|",3),loc=$P(z,"|",5)
	;
	I $G(map)="" S map=$$MAP(fid,sel,.fsn,.vdd,.typsave) Q:ER	;1/29/96
	;
	I $E(new,$L(new))="(" S new=$E(new,1,$L(new)-1)
	I acc'="" S new=$S(new'="":new_","_acc,1:acc)	; *** 11/14/94 BC
	;
	N @new						; New lvn and access keys
	;						; Store data in array
	I $D(rec)=1 S ptr=1 F z=1:1  Q:'ptr  S rec(z)=$$NPC(rec,.ptr,"|")
	D MAPKEY(.rec,map,acc) I ER Q			; Load keys from rec
	D LOCK(fid,.opt,.gbl,.fsn) I ER Q		; Lock record
	D MAPDTA(fid,sel,.rec,opt,map,.fsn,.ver,typsave,.jrn)	; Load data from rec 1/29/96
	I ER K UX					; Data changed, terminate
	;						; update operation
	I opt=1,'$D(UX) Q				; Nothing Changed
	;
	D EXT^DBSFILER(fid,opt,.par)			; File record
	;
	Q
	;
	;----------------------------------------------------------------------
LOCK(fid,opt,gbl,fsn)	;Private; Lock Global
	;----------------------------------------------------------------------
	; Locks global reference.  Returns error if lock failed due to
	; timeout.  Will also return error if update mismatch occurs,
	; ie: attempt to modify a non-existant record or add a new
	; record that already exists.
	;
	; *** Access keys must be defined or undefined error will result ***
	;
	; fid parameter is not required if gbl parameter is provided.
	;
	; KEYWORDS: Database
	;
	; ARGUMENTS:
	;	. fid	File List		/REQ/MECH=VAL/TBL=[DBTBL1]
	;	. gbl	Full Global Syntax	/NOREQ/MECH=VAL
	;	. opt	Update Option (0,1,3)	/NOREQ/MECH=VAL
	;	. fsn	File Information	/MECH=REFNAM:RW
	;
	; RETURNS:
	;
	;	. ER	Fatal Error Indicator		/TYP=N
	;	. RM	Return Message			/COND
	;
	;----------------------------------------------------------------------
	;
	S ER=0
	;
	N i,rectyp,nod,z,zgbl,zkeys				; *** 09/19/96
	;
	I '$D(fsn(fid)) D fsn^DBSDD(.fsn,fid) I ER Q
	;							; *** 09/19/96 
	S zkeys=$P(fsn(fid),"|",3)				; *** check null value
	I zkeys'="" F i=1:1:$L(zkeys,",") D  I ER Q		; ***
	.	S z=$P(zkeys,",",i)
	.	I @z="" S ER=1,RM=$$^MSG(1767,z) Q		; ***
	S rectyp=$P(fsn(fid),"|",4),nod=$P(fsn(fid),"|",12)	; *** 05/13/96
	;
	I $G(gbl)="" D  I ER Q
	.	;
	.	S gbl=$P(fsn(fid),"|",2)
	.	I $E(gbl,$L(gbl))="(" S gbl=$E(gbl,1,$L(gbl)-1) Q
	.	I $E(gbl,$L(gbl))'=")" S gbl=gbl_")"
	;
	I 'rectyp S ER=1,RM=$$^MSG(1348,"0 - "_fid) Q		; *** 12/27/94 BC
	N defined
	;
	I rectyp=1 S defined=($D(@gbl)#10)>0		; *** 10/19/94 BC
	I rectyp>1 D
	.	I nod="" S defined=($D(@gbl))>0	Q	; *** 05/13/96
	.	S zgbl=$E(gbl,1,$L(gbl)-1)_","_nod_")"	; *** Check specified node
	.	S defined=($D(@zgbl))>0			; ***
	I $G(opt)="" S opt=defined
	E  I opt=0,defined S ER=1,RM=fid_" "_$$^MSG(2327) L:'$G(%NOLOCK) -@gbl Q
	E  I opt,opt'=3,'defined S ER=1,RM=fid_" "_$$^MSG(7932) L:'$G(%NOLOCK) -@gbl Q
	Q
	;
	;----------------------------------------------------------------------
MAPKEY(rec,map,acc)	;Private; Map Access Keys from rec to lvn's
	;----------------------------------------------------------------------
	; Maps access keys out of the rec parameter based on the record
	; map definition (See $$MAP).  Access keys are defined as local
	; variables as identified in the acc parameter.
	;
	; *** Access keys not contained in the record will not be defined ***
	; *** by this subroutine.  Could be supplied externally.          ***
	;
	; KEYWORDS: Database
	;
	;  RELATED: MAPDTA
	;
	; ARGUMENTS:
	;	. rec	Record Data		/REQ/MECH=REFARRY:R
	;	. map	Record Map (see $$MAP)	/REQ/MECH=VAL
	;	. acc	Access key list		/REQ/MECH=VAL
	;
	N akeys,i,v
	;
	S akeys=$L(acc,",")				; *** 05/17/96
	F i=1:1:akeys D
	.	;
	.	S v=+$P(map,"*.",i+1) I 'v Q
	.	S @$P(acc,",",v)=rec($L($P(map,"*.",1,i),","))	; *** 08/07/96
	.	S $P(acc,",",v)=""
	;
	I $TR(acc,",")'="" S ER=1,RM=$$^MSG(48,acc)		;1/29/96 mas
	Q
	;
	;----------------------------------------------------------------------
MAPDTA(fid,sel,rec,opt,map,fsn,ver,typsave,jrn)	;Private; Map Data from rec to fsn
	;----------------------------------------------------------------------
	; Maps data keys out of the rec parameter based on the record
	; map definition (See $$MAP).  Data is mapped into the file
	; short names as defined by the file header
	;
	; KEYWORDS: Database
	;
	;  RELATED: MAPKEY
	;
	; ARGUMENTS:
	;	. fid	File List		/REQ/MECH=VAL/TBL=[DBTBL1]
	;	. sel	Select list		/REQ/MECH=VAL
	;	. rec	Record Data		/REQ/MECH=REFARRY:R
	;	. opt	Update Option (0,1,3)	/MECH=VAL
	;	. map	Record Map (see $$MAP)	/MECH=REFNAM:RW
	;	. fsn	File Information	/MECH=REFNAM:RW
	;
	;----------------------------------------------------------------------
	S ER=0
	;
	N V,X,ZV,i,gvn,keys,nod,pos,sf,sn,v,zn,z,zdel,ztyp,typ
	;
	; *** 06/10/98 BC
	I opt=0,$p(fsn(fid),"|",6)="" D vinit(fid)	; Initialize defaults
	;
	S ver=$G(ver)
	S jrn=$G(jrn)				; JMH - 02/15/99
	S gvn=$P(fsn(fid),"|",2),keys=$P(fsn(fid),"|",3) ; Global reference and access keys
	S zdel=$P(fsn(fid),"|",10)  			; Field delimiter
	I zdel="" S zdel=124				; *** 03/11/97
	;
	S sf="",zn=""
	F i=1:1:$L(map,",") D  Q:ER			; Map Data
	.	;					;
	.	S X=$G(rec(i))				; New data
	.	I X=$C(0) Q				; Skip Indicator
	.	;
	.	S v=$P(map,",",i) I v="" Q		; Computed or protected
	.
	.	I v=$C(0) S UX=1 D  Q			; Memo field
	..		N sn
	..		I '$D(fsn(fid)) N fsn D fsn^DBSDD(.fsn,fid)
	.. 	S sn=$P(fsn(fid),"|",1)_"seq)"
	.. 	D BUF^DBSMEMO(fid,x,.sn)
	.	S pos=$P(v,".",1),nod=$P(v,".",2)
	.	;
	.       I pos="*" D  Q 			; *** 07/11/96
	..              I i'>$L(keys,",") Q             ; Skip keys 
	..              ;                               ; Allow Key changes 
	..              S UX(fid,$P(sel,",",i))=rec(nod)_"|"_X_"|"_nod_"|"_pos_"||"_$P(jrn,"|",i) ; JMH - 02/15/99
	.	;
	.	I pos["~" S sf=$P(pos,"~",2,99),pos=$P(pos,"~",1)
	.	I nod="" S nod=" "
	.	I zn'=nod D
	..		;
	..		S sn=$P($G(fsn(fid,nod)),"|",1),zn=nod
	..		S ztyp=$P(fsn(fid),"|",4)		; Record type
	..		I sn="" D lodnod^DBSDD(fid,nod,.fsn) S sn=$P(fsn(fid,nod),"|",1)
	..		I opt I ('$D(@sn))!(($D(@sn)#10=0)&(ztyp#10=1)) D   ;7/31/97 MAS
	...		   D addz1^DBSLOD(fid,nod,.v,.fsn,,,gvn) F z=1:1:v X v(z)
	.	;
	.	S V=$G(@sn) I pos S V=$P(V,"|",pos)		; *** 06/27/96
	.	I sf'="" S ZV=V,V=$$GETSUB(V,sf)		; Subfield
	.	;
	.	S typ=$P($G(typsave),",",i)				;1/29/96
	.	I typ="$",opt,ver'="",+$P(ver,"|",i)'=+V S ER=1		;1/29/96 mas
	.	I typ'="$",opt,ver'="",$P(ver,"|",i)'=V S ER=1
	.	I ER S RM=$$^MSG(362,fid,$p(sel,",",i)) Q		;1/29/96 mas
	.	;						; *** 05/17/96
	.	I opt,X'=V D					; Create UX()
	..		I V="",pos="*" Q			; Access key
	..		I $E(nod)="""" S nod=$E(nod,2,$L(nod)-1) 
	..		; *** BC 08/30/96 (Avoid delimiter error)
	..		I "BM"[typ S pos="",UX(fid,$P(sel,",",i))="||"_nod_"|"_pos Q
	..		S UX(fid,$P(sel,",",i))=V_"|"_X_"|"_nod_"|"_pos_"||"_$P(jrn,"|",i)	; JMH - 02/15/99
	.	;
	.	I sf'="" S X=$$PUTSUB(X,ZV,sf),sf=""		; *** 06/27/96
	.	I pos S $P(@sn,$c(zdel),pos)=X Q		; *** 03/11/97
	.	S @sn=X
	Q
	;
	;----------------------------------------------------------------------
MAP(fid,sel,fsn,vdd,typsave)	;Private; Return Record Map Definition
	;----------------------------------------------------------------------
	; This utility returns a local array map that corresponds to
	; the array names, nodes, and field positions of the data
	; items identified in the sel parameter
	;
	; KEYWORDS: Database
	;
	; ARGUMENTS:
	;	. fid	File List		/REQ/MECH=VAL/TBL=[DBTBL1]
	;	. sel	Select list		/REQ/MECH=VAL
	;	. fsn	File Information	/MECH=REFNAM:RW
	;	. vdd	Dictionary Attributes	/MECH=REFNAM:RW
	;
	; RETURNS:
	;
	;	. ER	Fatal Error Indicator		/TYP=N
	;	. RM	Return RM			/COND
	;
	; EXAMPLE:
	;
	; W $$MAP("DEP","CID,BAL,LNM")
	; "*.1,1.50,6.50"
	;      ^  ^
	;      |  |
	;    Pos  node 
	;----------------------------------------------------------------------
	;
	I $G(fid)="" Q ""
	;
	S ER=0
	N I,acc,bkey,ddref,map,nod,pos,z
	;
	I '$D(fsn(fid)) D fsn^DBSDD(.fsn,fid) I ER Q ""
	;
	S z=fsn(fid)
	S acc=$P(z,"|",3),bkey=$P(acc,",",$L(acc,","))
	;
	S map=""
	;
	F I=1:1:$L(sel,",") D  I ER S map="" Q
	.	;
	.	S ddref=$P(sel,",",I)
	.	S z=$$DI^DBSDD(.ddref,fid,.vdd) Q:ER
	.	S $P(typsave,",",I)=$P(z,"|",9)
	.	I fid'=$P(ddref,".",2) S ER=1,RM=$$^MSG(363) Q	;1/29/96 MAS
	.	;						; *** M08/07/96
	.	I $P(z,"|",9)="M" S $P(map,",",I)=$C(0) Q	; Memo
	.	;
	.	S nod=$P(z,"|",1),pos=$P(z,"|",21)
	.	I $P(z,"|",9)="B" S pos=1			; *** BLOB
	.	I nod="" Q					; Computed  item *** 10/07/96
	.	I nod["*" S pos="*",nod=$L($P((","_acc_","),(","_$P(ddref,".",3)_","),1),",")
	.	I $P(z,"|",18)'="" S pos=pos_"~"_$P(z,"|",18)
	.	I nod=bkey S nod=""			; No Subscript
	.	E  S:nod'=+nod nod=""""_nod_"""" S nod="."_nod
	.	;
	.	S $P(map,",",I)=pos_nod
	;
	Q map
	;
	;----------------------------------------------------------------------
PUTSUB(X,V,sf)	; Put subfield definition
	;----------------------------------------------------------------------
	;
	N sft,sfd1,fd2,sfp
	S sft=$P(sf,"~",1),sfd1=$P(sf,"~",2),sfd2=$P(sf,"~",3),sfp=$P(sf,"~",4)
	S:sfd1 sfd1=$C(sfd1) S:sfd2 sfd2=$C(sfd2)
	Q $$PUT^USUB(V,X,sft,sfd1,sfd2,sfp)
	;
	;----------------------------------------------------------------------
GETSUB(V,sf)	; Get subfield value
	;----------------------------------------------------------------------
	;
	N sft,sfd1,fd2,sfp
	S sft=$P(sf,"~",1),sfd1=$P(sf,"~",2),sfd2=$P(sf,"~",3),sfp=$P(sf,"~",4)
	S:sfd1 sfd1=$C(sfd1) S:sfd2 sfd2=$C(sfd2)
	Q $$GET^USUB(V,sft,sfd1,sfd2,sfp)
	;
	;----------------------------------------------------------------------
vinit(fid)	;Private; Initialize Master files (default value) if no filer
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;
	;  . fid	File name	/TYP=T/REQ/MECH=VAL/TBL=[DBTBL1]
	;
	; INPUTS:
	;
	;   Access keys
	;
	; RETURNS:
	;
	;    Internal file short name array
	;
	; Example:
	;
	;  S ACN=12345 D vinit("CIF")
	;
	;  CIF(14)=56699
	;  CIF(50)="|*|CIF"
	;----------------------------------------------------------------------
	;
	N z,zcode,ER
	;
	; djh 04/30/97   Exclude if dummy file definition
	I $G(%LIBS)="" N %LIBS S %LIBS=^CUVAR("%LIBS")
	I $P($G(^DBTBL(%LIBS,1,fid,10)),"|",12)=5 Q     ; Dummy file definition
	;
	D DEFAULT(fid,.zcode,1)				; Build exec code 12/09/99
	I '$D(zcode) Q					; Not defined
	S z="" F  S z=$O(zcode(z)) Q:z=""  X zcode(z) I $G(ER) Q  ; Set up defaults
	Q
	;
	;---------------------------------------------------------------------- 
DEFAULT(fid,code,mode)	; Return procedural code to create defaults in create mode 
	;---------------------------------------------------------------------- 
	; 
	N (fid,code,mode,%LIBS) 
	I $G(fid)="" Q                          ; Invalid file name 
	I $G(%LIBS)="" N %LIBS S %LIBS=^CUVAR("%LIBS") 
	D fsn^DBSDD(.fsn,fid) I $G(ER) Q        ; Invalid name 
	; 
	K code 
	S req=$G(^DBTBL(%LIBS,1,fid,101))       ; Items with default value 
	S node=$P(fsn(fid),"|",12)              ; Record exist indicator 
	S gbl=$P(fsn(fid),"|",2)                ; Global reference 
	I node="" S gbl=gbl_")"                 ; ^gbl(key1,key2,,,) 
	E  S gbl=gbl_","_node_")"               ; ^gbl(key1,node) 
	; 
	S sn=$P($P(fsn(fid),"|",1),"(",1)       ; Internal storage name 
	S rectyp=$P(fsn(fid),"|",4)             ; Record type 
	S keys=$P(fsn(fid),"|",3)               ; Access keys 
	S bkey=$P(keys,",",$L(keys,","))        ; Last key 
	I keys'="" D                            ; Record defined? 
	.       S N="" 
	.       F I=1:1:$L(keys,",") S N=N_"!($G("_$P(keys,",",I)_")="_""""""_")" 
	.       S code(1)=" Q:$G(%O)  S ER=0 I "_$E(N,2,999) 
	.       S code(1)=code(1)_" S ER=1,RM=$$^MSG(1767,"_""""_keys_""""_") Q" 
	.       S code(2)=" I $D("_gbl_")" 
	.       I rectyp=1 S code(2)=" I $G("_gbl_")'="_""""""     ; *** 02/24/98 BC 
	.       I $G(mode)'=2 S code(2)=code(2)_" S ER=1,RM=$$^MSG(2327)" ; *** 12/05/97 
	.       S code(2)=code(2)_" Q  ; Already created" 
	I req="" Q 
	S q="""" 
	F i=1:1:$L(req,",") D 
	.       I $P(req,",",i)="" Q 
	.       S dinam=fid_"."_$P(req,",",i) 
	.       K item 
	.       D PARSE^DBSDD(dinam,.item)              ; Get internal format 
	.       I ER D ERR Q                            ; Item deleted? 
	.       I rectyp>1 D 
	..              S nod=$$NOD^DBSDD(dinam,.item) ; Node number 
	..              I nod=bkey Q                    ; Skip 
	..              S node(nod)=""                  ; Save node number 
	.       S v=$$DFT^DBSDD(dinam,.item)            ; Default value 
	.       I v="" Q 
	.       S typ=$$TYP^DBSDD(dinam,.item)          ; Type 
	.       S len=$$LEN^DBSDD(dinam,.item)          ; Length 
	.       S v=$$value(v,typ)                      ; Internal format 
	.       S code(10+i)=" I "_NS_"="_q_q_" S "_NS_"="_v_"   ; "_dinam 
	; 
	I rectyp#2=1 S code(3)=" S "_sn_"=$G("_sn_")"   ; Init array 
	I rectyp=1!'$D(node) Q 
	; 
	S node="",n="" 
	F  S n=$O(node(n)) Q:n=""  D 
	.       S i=n I i'=+i S i=""""_i_""""           ; "name" 
	.       S node=node_","_sn_"("_i_")=$G("_sn_"("_i_"))" 
	I node'="" S code(4)=" S "_$E(node,2,999) 
	Q 
	; 
	;----------------------------------------------------------------------
NPC(v,ptr,del,qwt)	;private; Return Next Unquoted Piece
	;----------------------------------------------------------------------
	;
	I $G(del)="" S del=","
	I $G(qwt)="" S qwt=""""
	;
	N y
	S y=$F(v,del,ptr) I y=0 S v=$E(v,ptr,$L(v)),ptr=0 Q v
	I $L($E(v,ptr,y-1),qwt)#2 S v=$E(v,ptr,y-2),ptr=y Q v
	F  S y=$F(v,del,y) Q:'y  I $L($E(v,ptr,y-1),qwt)#2 Q
	S v=$E(v,ptr,$S(y:y-2,1:$L(v))),ptr=y Q v
	; 
value(v,typ)	; Convert internal to external format 
	;---------------------------------------------------------------------- 
	; EXAMPLES:     External            Internal      Type 
	; 
	;              SystemDate           TJD            D 
	;              CurrentDate          +$H            D 
	;              123                  123 
	;              XYZ                  "XYZ" 
	;              <<ABCDE>>            ABCDE 
	;              T                    TJD            D 
	;              C                    +$H            D 
	;              Y                     1             L 
	;              N                     0             L 
	; 
	I v="" Q "" 
	I $D(^STBL("JRNFUNC",v)) Q $P(^(v),"|",2)       ; System keyword 
	I v?1n.n!(v?1n.n1".".n) Q v                     ; Numeric 
	I v?1"<<"1e.e1">>" Q $P($P(v,"<<",2),">>",1)    ; <<variavle>> 
	I typ="D" Q $S(v="T":"TJD",v="C":"+$H",1:"")    ; System date/Today 
	I typ="C",v="C" Q "$P($H,"","",2)"              ; Current time 
	I typ="L" Q $S(v="Y":1,1:0)                     ; Logical 
	I v="""" Q """"""""""                           ; string delimitor 10/18/96 mas 
	Q """"_v_""""                         	; "text"
	; 
	;----------------------------------------------------------------------
ERR	; Display error message 
	;---------------------------------------------------------------------- 
	W !,$$MSG^%TRMVT($G(RM)),! H 2 
	Q 
