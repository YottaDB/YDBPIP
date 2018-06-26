KBBOSQLT ; YDB/CJE - SQL Mapping Tests ;2018-05-31
 ;;1.0;KBBOSQL;**1**;May 31, 2018;Build 1
TEST
 I $T(^%ut)="" QUIT
 D EN^%ut($t(+0),3)
 QUIT
 ;
 ; Patient File Tests
PATIENT ; @TEST
 ;D TESTSQL(2,1)
 D VERIFY(2,1)
 QUIT
 ;
 ; Person File Tests
PERSON ; @TEST
 ;D TESTSQL(200,5)
 D VERIFY(200,5)
 QUIT
 ;
 ;
 ; All SQL Tests follow the same order of operations - so this method can
 ; test any FileMan mapped SQL table.
TESTSQL(FILE,IEN)
 N SQLPAR,ERROR,ROWS,SQL,FILENAME,QUERY
 N %DB,%LIBS,%TOKEN,%MSGID,ER,I,J,pslTbl,fsn,vobj,RM
 S SQLPAR("ROWS")=1
 S FILENAME=$$FNB^DMSQU(FILE)
 S QUERY="SELECT "_$$LIST^SQLDD(FILENAME)_" FROM "_FILENAME
 I IEN S QUERY=QUERY_" WHERE IEN="_IEN
 S ERROR=$$^SQL(QUERY,.SQLPAR,,.ROWS)
 D ASSERT(0,ERROR,"Error status code set from $$^SQL")
 D ASSERT(1,$D(ROWS),"No rows returned from query")
 D ARRAYSQL(.SQL,ROWS)
 D ASSERT(SQLPAR("ROWS"),$O(SQL(""),-1),"Too many rows returned")
 D VERIFYSQL(FILE,.SQL)
 QUIT
 ; Converts ROWS returned by a SQL Query to an array format for easy checking
 ; RETURNS: RETURN(#)=ROW
ARRAYSQL(RETURN,ROWS)
 N ROW
 F ROW=1:1:$L(ROWS,$C(13,10)) D
 . S RETURN(ROW)=$P(ROWS,$C(13,10),ROW)
 QUIT
 ;
VERIFYSQL(FILE,SQL,SUBFILE)
 N ROW,ERROR,FIELD,FILENAME,SQLFIELDNAME,FM,SQLIENS,SQLMAP,FIELDNAME,COLUMNS
 N DIC,FMFILE
 ;
 S ROW=0 ; Skip the first SQL row as that is the 0 node which is invalid
 F  S ROW=$O(SQL(ROW)) Q:ROW=""  D
 . K FM,ERROR,SQLIENS
 . S SQLIENS=$P(SQL(ROW),$C(9),1)_","
 . D GETS^DIQ(FILE,SQLIENS,"**","I","FM","ERROR")
 . D ASSERT(0,$D(ERROR),"FileMan error occurred")
 . I $D(ERROR) W "FileMan Error: ",! ZWRITE ERROR QUIT
 . S FMFILE=""
 . S FILENAME=$$FNB^DMSQU(FILE)
 . D GETCOLUMNS(FILENAME)
 . W !
 . F  S FMFILE=$O(FM(FMFILE)) Q:FMFILE=""  D
 . . W "FMFILE: "_FMFILE,!
 . . S FIELD=""
 . . F  S FIELD=$O(FM(FMFILE,SQLIENS,FIELD)) Q:FIELD=""  D
 . . . K SQLMAP,FIELDNAME,SQLFIELDNAME
 . . . ; have to cross walk Fileman and SQL mapping to get field number to piece translation
 . . . ; Get a SQL compatible Column Name for the Field
 . . . S SQLFIELDNAME=$$SQLK^DMSQU($P(^DD(FMFILE,FIELD,0),"^",1),30)
 . . . ; Skip computed fields
 . . . I $P(^DD(FMFILE,FIELD,0),"^",2)["C" Q
 . . . ;
 . . . D ASSERT(FM(FMFILE,SQLIENS,FIELD,"I"),$P(SQL(ROW),$C(9),COLUMNS(SQLFIELDNAME)),"data mismatch between FileMan File: "_FILENAME_" (#"_FMFILE_") Field: "_$P(^DD(FILE,FIELD,0),"^",1)_" (#"_FIELD_") and SQL "_SQLFIELDNAME)
 QUIT
 ;
VERIFY(FILE,IEN)
 N ROW,ERROR,FIELD,FILENAME,SQLFIELDNAME,FM,SQLMAP,FIELDNAME,COLUMNS
 N DIC,FMFILE,SIEN,SQLIENS,X1,FLAG
 N SQLPAR,ERROR,ROWS,SQL,FILENAME,QUERY
 N %DB,%LIBS,%TOKEN,%MSGID,ER,I,J,pslTbl,fsn,vobj,RM
 ;
 ; Start with getting all of the results for the given IEN from FileMan
 D GETS^DIQ(FILE,IEN_",","**","I","FM","ERROR")
 D ASSERT(0,$D(ERROR),"FileMan error occurred")
 I $D(ERROR) W "FileMan Error: ",! ZWRITE ERROR QUIT
 S FMFILE=""
 W !
 F  S FMFILE=$O(FM(FMFILE)) Q:FMFILE=""  D
 . W "FMFILE: "_FMFILE,!
 . S FILENAME=$$FNB^DMSQU(FMFILE)
 . D GETCOLUMNS(FILENAME)
 . S SQLIENS=""
 . F  S SQLIENS=$O(FM(FMFILE,SQLIENS)) Q:SQLIENS=""  D
 . . ; Run a SQL query to get the data to compare to the FileMan data
 . . K SQLPAR,ERROR,ROWS,SQL,QUERY,FLAG
 . . K %DB,%LIBS,%TOKEN,%MSGID,ER,I,J,pslTbl,fsn,vobj,RM
 . . S SQLPAR("ROWS")=1
 . . S QUERY="SELECT "_$$LIST^SQLDD(FILENAME)_" FROM "_FILENAME
 . . S FLAG=0
 . . F SIEN=$L(SQLIENS,","):-1:1 D
 . . . I $P(SQLIENS,",",SIEN)="" Q
 . . . I 'FLAG S QUERY=QUERY_" WHERE IEN="_$P(SQLIENS,",",SIEN),FLAG=1
 . . . E  I FILENAME="PATIENT_APPOINTMENT" S QUERY=QUERY_" AND APPOINTMENT_DATE_TIME="_$P(SQLIENS,",",SIEN)
 . . . E  S QUERY=QUERY_" AND IEN"_SIEN_"="_$P(SQLIENS,",",SIEN)
 . . W "QUERY: "_QUERY,!
 . . S ERROR=$$^SQL(QUERY,.SQLPAR,,.ROWS)
 . . D ASSERT(0,ERROR,"Error status code set from $$^SQL")
 . . D ASSERT(1,$D(ROWS),"No rows returned from query")
 . . D ARRAYSQL(.SQL,ROWS)
 . . D ASSERT(SQLPAR("ROWS"),$O(SQL(""),-1),"Too many rows returned")
 . . ; Now check the fields/columns returned
 . . S FIELD=""
 . . F  S FIELD=$O(FM(FMFILE,SQLIENS,FIELD)) Q:FIELD=""  D
 . . . K SQLMAP,FIELDNAME,SQLFIELDNAME
 . . . ; have to cross walk Fileman and SQL mapping to get field number to piece translation
 . . . ; Get a SQL compatible Column Name for the Field
 . . . S SQLFIELDNAME=$$SQLK^DMSQU($P(^DD(FMFILE,FIELD,0),"^",1),30)
 . . . ; Skip computed fields
 . . . I $P(^DD(FMFILE,FIELD,0),"^",2)["C" Q
 . . . ;
 . . . S ROW=1
 . . . D ASSERT(FM(FMFILE,SQLIENS,FIELD,"I"),$P(SQL(ROW),$C(9),COLUMNS(SQLFIELDNAME)),"data mismatch between FileMan File: "_FILENAME_" (#"_FMFILE_") Field: "_$P(^DD(FMFILE,FIELD,0),"^",1)_" (#"_FIELD_") and SQL "_SQLFIELDNAME)
 QUIT
 ;
GETCOLUMNS(FILE)
 N SQLFIELDNAME,POSITION,LIST
 S SQLFIELDNAME=""
 S LIST=$$LIST^SQLDD(FILE)
 F POSITION=1:1:$L(LIST,",") D
 . S COLUMNS($P(LIST,",",POSITION))=POSITION
 QUIT
 ;
 ; Convience method
ASSERT(EXPECT,ACTUAL,MSG)
 D CHKEQ^%ut($G(EXPECT),$G(ACTUAL),$G(MSG))
 QUIT
