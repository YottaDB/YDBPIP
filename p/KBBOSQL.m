MAPFM(FILE)
 N FIELD,QUOTE,TYPE,SQLFIELDNAME,SUBSCRIPT,PIECE,FILENAME
 I $$CREATEMAP(FILE) W "Errors creating File header",! QUIT
 ; Fields are after the "0" subscript
 S FIELD=0
 ; For convience of printing SET command
 S QUOTE=""""
 ; Get a SQL compatible Table Name for the File
 S FILENAME=$$FNB^DMSQU(FILE)
 ; Loop through each field number
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
 . . W:SQLFIELDNAME="CLAIM_FOLDER_LOCATION" "Standalone Field: "_FIELDNAME,!
 . . W:SQLFIELDNAME="CLAIM_FOLDER_LOCATION" "SQLI Field: "_SQLFIELDNAME,!
 . . W:SQLFIELDNAME="CLAIM_FOLDER_LOCATION" "Type: "_TYPE,!
 . . W:SQLFIELDNAME="CLAIM_FOLDER_LOCATION" "Subscript: "_SUBSCRIPT,!
 . . W:SQLFIELDNAME="CLAIM_FOLDER_LOCATION" "Piece: "_PIECE,!
 . . ;W "SET Command: "_"S ^DBTBL("_QUOTE_"SYSDEV"_QUOTE_",1,"_QUOTE_FILENAME_QUOTE_",9,"_QUOTE_SQLFIELDNAME_QUOTE_")="_QUOTE_SUBSCRIPT_"|40|||||||T|"_SQLFIELDNAME_"|S||||0||0||||"_PIECE_"|"_SQLFIELDNAME_"|0||64786|vehu||0|||0"_QUOTE,!
 . . S ^DBTBL("SYSDEV",1,FILENAME,9,SQLFIELDNAME)=SUBSCRIPT_"|40|||||||T|"_SQLFIELDNAME_"|S||||0||0||||"_PIECE_"|"_SQLFIELDNAME_"|0||64786|vehu||0|||0"
 . I +TYPE D
 . . ; Subfiles have to be unravled from the parent file as they aren't standalone files with definitions in ^DIC
 . . ; UP^DIDG gave the information to unravel this.
 . . ; The chain works like the following:
 . . ; * Identify that we are a subfile with +TYPE
 . . ; * Take the number from +TYPE and S X=$ORDER(^DD(FILE,"SB",+TYPE,""))
 . . ; * Take the result of the $ORDER and get the field definition from ^DD(FILE,X,0) - This follows the normal field definition
 . . ;   in that the definition in that piece 4 of the 0 subscript contains the subscript and piece of the data.
 . . W "Subfile: "_+TYPE_" found!",!
 . . W "Attempting to map Sub-File",!
 . . I $$CREATEMAP(FILE,+TYPE) W "Errors creating Sub-File header",! Q
 . . ; Get a SQL compatible Table Name for the SubFile
 . . S SUBFILENAME=$$FNB^DMSQU(+TYPE)
 . . W "Attempting to map fields in Sub-File",!
 . . ;
 . . ; Loop through SubFile Fields
 . . S SUBFILEFIELD=0
 . . F  S SUBFILEFIELD=$O(^DD(+TYPE,SUBFILEFIELD)) Q:SUBFILEFIELD=""  Q:SUBFILEFIELD'=+SUBFILEFIELD  D
 . . . ; This isn't a SQL compatible Field name
 . . . S FIELDNAME=$P(^DD(+TYPE,SUBFILEFIELD,0),"^",1)
 . . . ; Get a SQL compatible Column Name for the Field
 . . . S SQLFIELDNAME=$$SQLK^DMSQU(FIELDNAME,30)
 . . . S SUBSCRIPT=$P($P(^DD(+TYPE,SUBFILEFIELD,0),"^",4),";",1)
 . . . S PIECE=$P($P(^DD(+TYPE,SUBFILEFIELD,0),"^",4),";",2)
 . . . S SUBTYPE=$P(^DD(+TYPE,SUBFILEFIELD,0),"^",2)
 . . . ;
 . . . W "SubFile SQLI Name: "_SUBFILENAME,!
 . . . W "Field: "_FIELDNAME,!
 . . . W "SQLI Field: "_SQLFIELDNAME,!
 . . . W "SubType: "_SUBTYPE,!
 . . . W "Subscript: "_SUBSCRIPT,!
 . . . W "Piece: "_PIECE,!
 . . . W "SET Command: "_"S ^DBTBL("_QUOTE_"SYSDEV"_QUOTE_",1,"_QUOTE_SUBFILENAME_QUOTE_",9,"_QUOTE_SQLFIELDNAME_QUOTE_")="_QUOTE_SUBSCRIPT_"|40|||||||T|"_SQLFIELDNAME_"|S||||0||0||||"_PIECE_"|"_SQLFIELDNAME_"|0||64786|vehu||0|||0"_QUOTE,!
 . . . S ^DBTBL("SYSDEV",1,SUBFILENAME,9,SQLFIELDNAME)=SUBSCRIPT_"|40|||||||T|"_SQLFIELDNAME_"|S||||0||0||||"_PIECE_"|"_SQLFIELDNAME_"|0||64786|vehu||0|||0"
 QUIT
 ;
 ;
 ; This creates a file header in PIP for a given FileMan FILE or SUB-FILE
 ; No checking if the parent of a SUB-FILE is mapped
 ; If a SUB-FILE is passed it is assumed that the intention is to ONLY map
 ; the SUB-FILE.
 ; FILE is always required as SUB-FILE mapping requires data from the parent
 ; FILE.
CREATEMAP(FILE,SUBFILE)
 S SUBFILE=$G(SUBFILE)
 ; This requires a FILE Number (No names)
 ; Files need to be numeric and exist in ^DIC or ^DD
 I (FILE'=+FILE)!('$D(^DIC(FILE))) W "Invalid File passed",! QUIT 1
 ;
 N SQLFILENAME,GLOBAL,SEPARATOR,KEYS,KEY,I,SB,QUIT
 ;
 ; Figure out if we are given a true sub-file number or the field number
 ; and validate it
 I $L(SUBFILE) D
 . I '$D(^DD(SUBFILE)) W "Invalid Sub-File passed - Can't find in ^DD",! S QUIT=1
 . S SB=$O(^DD(FILE,"SB",SUBFILE,""))
 . W "SB: "_SB,!
 . I ('$D(^DD(FILE,SB)))!(+$P(^DD(FILE,SB,0),"^",2)'=SUBFILE) W "Invalid Sub-File passed - Link to Parent File broken",! S QUIT=1
 QUIT:QUIT
 ;
 ;
 ; Get a SQL compatible Table name for the (SUB)FILE
 I $L(SUBFILE) D
 . S SQLFILENAME=$$FNB^DMSQU(SUBFILE)
 E  D
 . S SQLFILENAME=$$FNB^DMSQU(FILE)
 W "Table Name: "_SQLFILENAME,!
 ;
 ; The global reference includes the "^" and subscripts
 ; We have to strip the subscripts (they become keys) and the "^"
 ; For subfiles we need to append data in ^DD(FILE,SUBFILE,0) Piece 4 to KEYS
 S (GLOBAL,KEYS)=$G(^DIC(FILE,0,"GL"))
 I GLOBAL="" W "No Global node found",! QUIT 1
 S GLOBAL=$E(GLOBAL,2,$F(GLOBAL,"(")-2)
 ;
 ;
 ; Setup the KEYS to access the file
 ; IEN is always assumed and is the last subscript
 ; 99% of the time the 1st key will be the file number
 S KEYS=$E(KEYS,$F(KEYS,"("),$L(KEYS))_"IEN"
 I $L(SUBFILE) D
 . S KEYS=KEYS_","_$P($P(^DD(FILE,SB,0),"^",4),";",1)_",IEN1"
 W "KEYS: "_KEYS,!
 F KEY=1:1:$L(KEYS,",") D
 . S KEYS(KEY)=$P(KEYS,",",KEY)
 W "PARSED KEYS: ",! ZWR KEYS
 ;
 ;QUIT 1
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
 ; TODO: fix the file name for subfiles
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
