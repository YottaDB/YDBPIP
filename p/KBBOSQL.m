KBBOSQL ; YDB/CJE - SQL Mapper ;2018-05-31
 ;;1.0;KBBOSQL;**1**;May 31, 2018;Build 1
MAPALL(VERIFY,DEBUG)
 S DEBUG=$G(DEBUG)
 S VERIFY=$G(VERIFY)
 N FILE
 S FILE=1
 ; Use ^DIC instead of ^DD as ^DIC only contains Root Files
 F  S FILE=$O(^DIC(FILE)) Q:FILE=""  Q:FILE'=+FILE  D
 . W "Mapping File "_$P(^DIC(FILE,0),"^",1)_" (#"_FILE_")",!
 . D MAPFM(FILE,DEBUG)
 . W:VERIFY "Verifying File "_$P(^DIC(FILE,0),"^",1)_" (#"_FILE_")",!
 . D:VERIFY VERIFY^KBBOSQLT(FILE,1)
 . W "Done Mapping File "_$P(^DIC(FILE,0),"^",1)_" (#"_FILE_")",!
 . W "--------------------------------------------------------------------------------",!
 QUIT
MAPFM(FILE,DEBUG)
 S DEBUG=$G(DEBUG)
 I $$CREATEMAP(FILE,DEBUG) W "Error: Unable to create SQL table header for File (#"_FILE_")",! QUIT
 D MAPFIELDS(FILE,DEBUG)
 QUIT
 ;
 ;
 ; This maps Fields in a given FileMan File/SubFile
MAPFIELDS(FILE,DEBUG)
 S DEBUG=$G(DEBUG)
 N FIELD,QUOTE,TYPE,SQLFIELDNAME,SUBSCRIPT,PIECE,FILENAME,FIELDNAME,%DB
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
 . . I FIELD=.001 W "Info: Skipping NUMBER (#.001) Virtual Field",! Q
 . . ; If we don't have a piece and subscript the field shouldn't be mapped
 . . I ((SUBSCRIPT="")!(SUBSCRIPT=" "))&(PIECE="") D  Q
 . . . W "Field Error: No Piece or Subscript could be found for Field "_FIELDNAME
 . . . W " (#"_FIELD_") in File "_FILENAME_" (#"_FILE_")",!
 . . ;
 . . W:DEBUG "SQL Map Command: "_"S ^DBTBL("_QUOTE_"SYSDEV"_QUOTE_",1,"_QUOTE_FILENAME_QUOTE_",9,"_QUOTE_SQLFIELDNAME_QUOTE_")="_QUOTE_SUBSCRIPT_"|40|||||||T|"_SQLFIELDNAME_"|S||||0||0||||"_PIECE_"|"_SQLFIELDNAME_"|0||64786|vehu||0|||0"_QUOTE,!
 . . S ^DBTBL("SYSDEV",1,FILENAME,9,SQLFIELDNAME)=SUBSCRIPT_"|40|||||||T|"_SQLFIELDNAME_"|S||||0||0||||"_PIECE_"|"_SQLFIELDNAME_"|0||64786|vehu||0|||0"
 . E  I +TYPE D
 . . ; Subfiles have to be unravled from the parent file as they aren't standalone files
 . . ; with definitions in ^DIC
 . . ; UP^DIDG gave the information to unravel this.
 . . ; The chain works like the following:
 . . ; * Identify that we are a subfile with +TYPE
 . . ; * Take the number from +TYPE and S X=$ORDER(^DD(FILE,"SB",+TYPE,""))
 . . ; * Take the result of the $ORDER and get the field definition from ^DD(FILE,X,0)
 . . ;   - This follows the normal field definition in that the definition in that
 . . ;   piece 4 of the 0 subscript contains the subscript and piece of the data.
 . . W:DEBUG "Subfile: "_+TYPE_" found!",!
 . . W:DEBUG "Attempting to map Sub-File",!
 . . I $$CREATEMAP(+TYPE,DEBUG) D  Q
 . . . W "Error: Unable to create SQL table header for File (#"_FILE_") SubFile (#"_+TYPE_")",!
 . . ; Recursively call ourselves as SubFiles can now be treated like regular files
 . . ; (and can have SubFiles of their own)
 . . D MAPFIELDS(+TYPE,DEBUG)
 . ; TODO: Computed Fields need to be handled by DATA-QWIK as FileMan stores no data
 . ; in globals for these fields
 . E  I TYPE["C" D
 . . W "Info: Skipping Computed Field: "_$P(^DD(FILE,FIELD,0),"^",1)_" (#"_FIELD_")",! Q
 ;
 ; Rebuild Data Item Control Files
 D BLDINDX^DBSDF9(FILENAME)
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
 I (FILE'=+FILE)&(('$D(^DIC(FILE)))!('$D(^DD(FILE)))) W "Error: Invalid File passed: ",FILE,! QUIT 1
 ;
 N SQLFILENAME,GLOBAL,SEPARATOR,KEYS,KEY,I,SB,QUIT,PARENT,PREVPARENT,IEN,SUBPARENT,QUOTE
 S QUOTE=""""
 ;
 ; Figure out if we are given a SubFile and make sure we can get to the parent File
 I '$D(^DIC(FILE)) D  ; SubFiles don't exist in ^DIC
 . S PARENT=$G(^DD(FILE,0,"UP"))
 . I '$L(PARENT) W "Error: Can't Find Parent File of SubFile: ",FILE,! S QUIT=1 Q
 . ; This is just to get the SubFile Number in the Parent file.
 . S SB=$O(^DD(PARENT,"SB",FILE,""))
 . W:DEBUG "SUBFILE NUMBER: "_SB,!
 . I ('$D(^DD(PARENT,SB)))!(+$P(^DD(PARENT,SB,0),"^",2)'=FILE) D
 . . W "Error: Invalid SubFile passed - Link to Parent File broken File (#"
 . . W PARENT_") SubFile (#"_FILE_")",! S QUIT=1
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
 ; Last parent is the root File
 E  S (GLOBAL,KEYS)=$G(^DIC($P(PARENT,"^",$L(PARENT,"^")),0,"GL"))
 I GLOBAL="" D  QUIT 1
 . W "Error: No Global node for File (#"_$S(PARENT'="":$P(PARENT,"^",$L(PARENT,"^")),1:FILE)_")",!
 S GLOBAL=$E(GLOBAL,2,$F(GLOBAL,"(")-2)
 ;
 ;
 ; Setup the KEYS to access the file
 ; IEN is always assumed to be the last subscript
 S KEYS=$E(KEYS,$F(KEYS,"("),$L(KEYS))_"IEN"
 ; PARENT is not "" when we have a SubFile
 I PARENT'="" D
 . ; Add the File we are working with to the list of parents
 . S PARENT=FILE_"^"_PARENT
 . ; Loop through all parents to get all of the keys
 . F IEN=1:1:$L(PARENT,"^")-1 D
 . . S SUBPARENT=$P(PARENT,"^",IEN)
 . . S PREVPARENT=$P(PARENT,"^",IEN+1)
 . . S SB=$O(^DD(^DD(SUBPARENT,0,"UP"),"SB",SUBPARENT,""))
 . . W:DEBUG "---------------------------",!
 . . W:DEBUG "FILE: "_FILE,!
 . . W:DEBUG "PREVPARENT: "_PREVPARENT,!
 . . W:DEBUG "PARENT: "_PARENT,!
 . . W:DEBUG "SUBPARENT: "_SUBPARENT,!
 . . W:DEBUG "SB: "_SB,!
 . . ;
 . . I SB="" D  Q
 . . . W "Error: Unable to get SubFile number (#"_SUBPARENT_") in Parent File (#"_PREVPARENT_")",!
 . . ;
 . . W:DEBUG "SUBSCRIPTS: "_$P($P(^DD(PREVPARENT,SB,0),"^",4),";",1),!
 . . W:DEBUG "Zero node: "_^DD(SUBPARENT,SB,0),!
 . . W:DEBUG "Renamed .001 Field: "_$D(^DD(SUBPARENT,.001,0)),!
 . . W:DEBUG ".001 node: "_$G(^DD(SUBPARENT,.001,0)),!
 . . S KEYS=KEYS_","_QUOTE_$P($P(^DD(PREVPARENT,SB,0),"^",4),";",1)_QUOTE
 . . ; $SELECT here to either get the name of the .001 field or fill in the default IEN
 . . S KEYS=KEYS_$S($D(^DD(FILE,.001,0)):","_$$SQLK^DMSQU($P(^DD(FILE,.001,0),"^",1),30),1:",IEN"_IEN)
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
 ; Format:
 ; SEPARATOR|SYSTEM NAME|NETWORK LOCATION||||?|||DATE MODIFIED (+$HOROLOG)|USERNAME|FILE TYPE||?
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
 ; Format:
 ; GLOBAL LOCATION WITH KEYS [^VA(200,IEN]|RECORD TYPE|||LOGGING
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
 .  S ^DBTBL("SYSDEV",1,SQLFILENAME,9,KEYS(KEY))=I_"*|12|||||||T|"_KEYS(KEY)_"|S||||1||0|||||"_KEYS(KEY)_"|0||"_+$H_"|FileManMapper||0|||0"
 ;
 QUIT 0
 ;
 ; Recurse a given SubFile to get all of its parents
GETPARENTS(FILE,PARENT)
 I '$L($G(^DD(FILE,0,"UP"))) QUIT PARENT
 S PARENT=$S($G(PARENT)'="":PARENT_"^",1:"")_$G(^DD(FILE,0,"UP"))
 S PARENT=$$GETPARENTS(^DD(FILE,0,"UP"),PARENT)
 QUIT PARENT
