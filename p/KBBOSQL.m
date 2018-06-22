KBBOSQL ; YDB/CJE - SQL Mapper ;2018-05-31
 ;;1.0;KBBOSQL;**1**;May 31, 2018;Build 1
MAPFM(FILE,DEBUG)
 S DEBUG=$G(DEBUG)
 I $$CREATEMAP(FILE,DEBUG) W "Errors creating File header",! QUIT
 D MAPFIELDS(FILE,DEBUG)
 QUIT
 ;
 ;
 ; This maps Fields in a given FileMan File/SubFile
MAPFIELDS(FILE,DEBUG)
 S DEBUG=$G(DEBUG)
 N FIELD,QUOTE,TYPE,SQLFIELDNAME,SUBSCRIPT,PIECE,FILENAME
 ; For convience of printing SET command
 S QUOTE=""""
 ; Get a SQL compatible Table Name for the File
 S FILENAME=$$FNB^DMSQU(FILE)
 ; Fields are after the "0" subscript
 S FIELD=0
 F  S FIELD=$O(^DD(FILE,FIELD)) Q:FIELD=""  Q:FIELD'=+FIELD  D
 . ; Figure out if it is a Sub-File and map it separately
 . ; Subfiles begin with a number in the Type field
 . S TYPE=$P(^DD(FILE,FIELD,0),"^",2)
 . I ('+TYPE)&(TYPE'["C") D
 . . ; This isn't a SQL compatible Field name
 . . S FIELDNAME=$P(^DD(FILE,FIELD,0),"^",1)
 . . ; Get a SQL compatible Column Name for the Field
 . . S SQLFIELDNAME=$$SQLK^DMSQU(FIELDNAME,30)
 . . S SUBSCRIPT=$P($P(^DD(FILE,FIELD,0),"^",4),";",1)
 . . S PIECE=$P($P(^DD(FILE,FIELD,0),"^",4),";",2)
 . . ;
 . . W:DEBUG "Field Name: "_FIELDNAME,!
 . . W:DEBUG "SQL Compatible Field Name: "_SQLFIELDNAME,!
 . . W:DEBUG "FileMan Type: "_TYPE,!
 . . W:DEBUG "Subscript: "_SUBSCRIPT,!
 . . W:DEBUG "Piece: "_PIECE,!
 . . W:DEBUG "SQL Map Command: "_"S ^DBTBL("_QUOTE_"SYSDEV"_QUOTE_",1,"_QUOTE_FILENAME_QUOTE_",9,"_QUOTE_SQLFIELDNAME_QUOTE_")="_QUOTE_SUBSCRIPT_"|40|||||||T|"_SQLFIELDNAME_"|S||||0||0||||"_PIECE_"|"_SQLFIELDNAME_"|0||64786|vehu||0|||0"_QUOTE,!
 . . S ^DBTBL("SYSDEV",1,FILENAME,9,SQLFIELDNAME)=SUBSCRIPT_"|40|||||||T|"_SQLFIELDNAME_"|S||||0||0||||"_PIECE_"|"_SQLFIELDNAME_"|0||64786|vehu||0|||0"
 . E  I +TYPE D
 . . ; Subfiles have to be unravled from the parent file as they aren't standalone files with definitions in ^DIC
 . . ; UP^DIDG gave the information to unravel this.
 . . ; The chain works like the following:
 . . ; * Identify that we are a subfile with +TYPE
 . . ; * Take the number from +TYPE and S X=$ORDER(^DD(FILE,"SB",+TYPE,""))
 . . ; * Take the result of the $ORDER and get the field definition from ^DD(FILE,X,0) - This follows the normal field definition
 . . ;   in that the definition in that piece 4 of the 0 subscript contains the subscript and piece of the data.
 . . W:DEBUG "Subfile: "_+TYPE_" found!",!
 . . W:DEBUG "Attempting to map Sub-File",!
 . . I $$CREATEMAP(+TYPE,DEBUG) W "Errors creating Sub-File header.",!,"File: ",FILE,!,"SubFile: ",+TYPE,! Q
 . . ; Recursively call ourselves as SubFiles can now be treated like regular files (and can have SubFiles of their own)
 . . ; Get a SQL compatible Table Name for the SubFile
 . . D MAPFIELDS(+TYPE,DEBUG)
 . ; Computed Fields need to be handled
 . E  I TYPE["C" D
 . . W "Skipping Computed Field: "_$P(^DD(FILE,FIELD,0),"^",1)_" (#"_FIELD_")",! Q
 QUIT
 ;
 ;
 ; This creates a file header in PIP for a given FileMan FILE or SUB-FILE
 ; No checking if the parent of a SUB-FILE is mapped
 ; If a SUB-FILE is passed it is assumed that the intention is to ONLY map
 ; the SUB-FILE.
 ; FILE is always required as SUB-FILE mapping requires data from the parent
 ; FILE.
CREATEMAP(FILE,DEBUG)
 S DEBUG=$G(DEBUG)
 ; This requires a FILE Number (No names)
 ; Files need to be numeric and exist in ^DIC or ^DD (Due to SubFile support)
 I (FILE'=+FILE)&(('$D(^DIC(FILE)))!('$D(^DD(FILE)))) W "Invalid File passed: ",FILE,! QUIT 1
 ;
 N SQLFILENAME,GLOBAL,SEPARATOR,KEYS,KEY,I,SB,QUIT,PARENT
 ;
 ; Figure out if we are given a SubFile and make sure we can get to the parent File
 I '$D(^DIC(FILE)) D  ; SubFiles don't exist in ^DIC
 . S PARENT=$G(^DD(FILE,0,"UP"))
 . I '$L(PARENT) W "Can't Find Parent File of SubFile: ",FILE,! S QUIT=1 Q
 . S SB=$QS($Q(^DD(PARENT,"SB",FILE)),4)
 . W:DEBUG "SUBFILE NUMBER: "_SB,!
 . I ('$D(^DD(PARENT,SB)))!(+$P(^DD(PARENT,SB,0),"^",2)'=FILE) W "Invalid SubFile passed - Link to Parent File broken",!,"File: ",PARENT,!,"SubFile: ",FILE,! S QUIT=1
 QUIT:QUIT
 ;
 ;
 ; Get a SQL compatible Table name for the (Sub)File
 S SQLFILENAME=$$FNB^DMSQU(FILE)
 W:DEBUG "Table Name: "_SQLFILENAME,!
 ;
 ; The global reference includes the "^" and subscripts
 ; We have to strip the subscripts (they become keys) and the "^"
 ; For subfiles we need to append data in ^DD(FILE,SUBFILE,0) Piece 4 to KEYS
 ; We need to recursively get the parent of the SubFile to get the global location
 S PARENT=$$GETPARENTS(FILE)
 I PARENT="" S (GLOBAL,KEYS)=$G(^DIC(FILE,0,"GL"))
 E  S (GLOBAL,KEYS)=$G(^DIC($P(PARENT,"^",$L(PARENT,"^")),0,"GL"))
 I GLOBAL="" W "No Global node found",! QUIT 1
 S GLOBAL=$E(GLOBAL,2,$F(GLOBAL,"(")-2)
 ;
 ;
 ; Setup the KEYS to access the file
 ; IEN is always assumed to be the last subscript
 S KEYS=$E(KEYS,$F(KEYS,"("),$L(KEYS))_"IEN"
 I PARENT'="" D
 . ; Loop through all parents to get all of the keys
 . F IEN=1:1:$L(PARENT,"^") D
 . . S SUBPARENT=$P(PARENT,"^",IEN)
 . . S SB=$QS($Q(^DD(SUBPARENT,"SB",FILE)),4)
 . . W:DEBUG "PARENT: "_SUBPARENT,!
 . . W:DEBUG "SB: "_SB,!
 . . W:DEBUG "Zero node: "_^DD(SUBPARENT,SB,0),!
 . . S KEYS=KEYS_","_$P($P(^DD(SUBPARENT,SB,0),"^",4),";",1)_",IEN"_IEN
 W:DEBUG "KEYS: "_KEYS,!
 F KEY=1:1:$L(KEYS,",") D
 . S KEYS(KEY)=$P(KEYS,",",KEY)
 W:DEBUG "PARSED KEYS: ",! ZWRITE:DEBUG KEYS
 ;
 ; All variables setup and now common between subfiles and files (in ignore relationship mode)
 ;
 ; FileMan Files by definition uses "^" as the separator
 ; There are some FileMan Files that stuff more data into a field that will need manual mapping
 S SEPARATOR=$A("^")
 ;
 ;
 ; Kill off the old mapping
 K ^DBTBL("SYSDEV",1,SQLFILENAME)
 ; This series of sets is based on manual mapping of the global and translating
 ; to be an automated function
 ;
 ; This is the description
 ; TODO: Add the SubFile name to the File name if a SubFile is passed
 S ^DBTBL("SYSDEV",1,SQLFILENAME)="VistA "_$P(^DIC(FILE,0),"^",1)_" File "_FILE
 ;
 ; This is the GLOBAL location (no keys or "^")
 S ^DBTBL("SYSDEV",1,SQLFILENAME,0)=GLOBAL
 S ^DBTBL("SYSDEV",1,SQLFILENAME,1)=""
 S ^DBTBL("SYSDEV",1,SQLFILENAME,2)=""
 S ^DBTBL("SYSDEV",1,SQLFILENAME,3)=""
 S ^DBTBL("SYSDEV",1,SQLFILENAME,4)=""
 S ^DBTBL("SYSDEV",1,SQLFILENAME,5)=""
 S ^DBTBL("SYSDEV",1,SQLFILENAME,6)=""
 S ^DBTBL("SYSDEV",1,SQLFILENAME,7)=""
 ;
 ; This is the SEPARATOR|SYSTEM NAME|NETWORK LOCATION||||?|||DATE MODIFIED (+$HOROLOG)|USERNAME|FILE TYPE||?
 ;
 ; NETWORK LOCATION   VALUE
 ; ================   =====
 ; SERVER ONLY        0
 ; CLIENT ONLY        1
 ; BOTH               2
 ;
 ; FILE TYPE          VALUE
 ; =========          =====
 ; ENTITY             1
 ; RELATIONSHIP       2
 ; DOMAIN             3
 ; INDEX              4
 ; DUMMY              5
 ; JOURNAL            6
 ; TEMPORARY          7
 ;
 S ^DBTBL("SYSDEV",1,SQLFILENAME,10)=SEPARATOR_"|PBS|0||||0|||"_+$H_"|FileManMapper|1||0"
 ;
 ; This is the local array name
 S ^DBTBL("SYSDEV",1,SQLFILENAME,12)=SQLFILENAME
 ;
 ; This is the documentation table name
 S ^DBTBL("SYSDEV",1,SQLFILENAME,13)=SQLFILENAME
 S ^DBTBL("SYSDEV",1,SQLFILENAME,14)=""
 ;
 ; This is the primary key(s)
 S ^DBTBL("SYSDEV",1,SQLFILENAME,16)=KEYS
 S ^DBTBL("SYSDEV",1,SQLFILENAME,22)="0||||||||0|0"
 S ^DBTBL("SYSDEV",1,SQLFILENAME,99)=""
 ;
 ; This is GLOBAL LOCATION WITH KEYS [^VA(200,IEN]|RECORD TYPE|||LOGGING
 ;
 ; RECORD TYPE        VALUES
 ; ===========        ======
 ; NONE               0
 ; UNSEGMENTED        1
 ; NODE (SEGMENTED)   10
 ; MIXED TYPE 1 & 10  11
 ; 
 S ^DBTBL("SYSDEV",1,SQLFILENAME,100)="^"_GLOBAL_"("_KEYS_"|10|||0"
 S ^DBTBL("SYSDEV",1,SQLFILENAME,101)=""
 ;
 ; I have no idea what this is
 S ^DBTBL("SYSDEV",1,SQLFILENAME,102)="IEN"
 ;
 ; Add the Key fields
 S KEY=""
 F I=1:1 S KEY=$O(KEYS(KEY)) Q:KEY=""  D
 .  S ^DBTBL("SYSDEV",1,SQLFILENAME,9,KEYS(KEY))=I_"*|12|||||||N|"_KEYS(KEY)_"|S||||1||0|||||"_KEYS(KEY)_"|0||"_+$H_"|FileManMapper||0|||0"
 ;
 QUIT 0
 ;
 ; Recurse a given SubFile to get all of its parents
GETPARENTS(FILE,PARENT)
 I '$L($G(^DD(FILE,0,"UP"))) QUIT PARENT
 S PARENT=$S($G(PARENT)'="":PARENT_"^",1:"")_$G(^DD(FILE,0,"UP"))
 S PARENT=$$GETPARENTS(^DD(FILE,0,"UP"),PARENT)
 QUIT PARENT
