KBBOSQLT ; YDB/CJE - SQL Mapping Tests ;2018-05-31
 ;;1.0;KBBOSQL;**1**;May 31, 2018;Build 1
TEST
 I $T(^%ut)="" QUIT
 D EN^%ut($t(+0),3)
 QUIT
 ;
 ; Patient File Tests
PATIENT ; @TEST
 D TESTSQL(2)
 QUIT
 ;
 ;Person File Tests
PERSON ; @TEST
 D TESTSQL(200)
 QUIT
 ;
 ; All SQL Tests follow the same order of operations - so this method can
 ; test any FileMan mapped SQL table.
TESTSQL(FILE)
 N SQLPAR,ERROR,ROWS,SQL,FILENAME
 N %DB,%LIBS,%TOKEN,ER,I,J,pslTbl,fsn,RM
 S SQLPAR("ROWS")=2
 S FILENAME=$$FNB^DMSQU(FILE)
 S ERROR=$$^SQL("SELECT "_$$LIST^SQLDD(FILENAME)_" FROM "_FILENAME,.SQLPAR,,.ROWS)
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
VERIFYSQL(FILE,SQL)
 N ROW,ERROR,FIELD,FILENAME,SQLFIELDNAME,FM,SQLIENS,SQLMAP,FIELDNAME,COLUMNS
 N DIC
 S FILENAME=$$FNB^DMSQU(FILE)
 D GETCOLUMNS(FILENAME)
 ;
 S ROW=1 ; SKIP THE FIRST SQL ROW AS THAT IS THE 0 NODE WHICH IS INVALID
 F  S ROW=$O(SQL(ROW)) Q:ROW=""  D
 . K FM,ERROR,SQLIENS
 . S SQLIENS=$P(SQL(ROW),$C(9),1)_","
 . D GETS^DIQ(FILE,SQLIENS,"*","I","FM","ERROR")
 . D ASSERT(0,$D(ERROR),"FileMan error occurred")
 . S FIELD=""
 . F  S FIELD=$O(FM(FILE,SQLIENS,FIELD)) Q:FIELD=""  D
 . . K SQLMAP,FIELDNAME,SQLFIELDNAME
 . . ; have to cross walk Fileman and SQL mapping to get field number to piece translation
 . . ; Get a SQL compatible Column Name for the Field
 . . S SQLFIELDNAME=$$SQLK^DMSQU($P(^DD(FILE,FIELD,0),"^",1),30)
 . . ; Skip computed fields
 . . I $P(^DD(FILE,FIELD,0),"^",2)["C" Q
 . . ;
 . . D ASSERT(FM(FILE,SQLIENS,FIELD,"I"),$P(SQL(ROW),$C(9),COLUMNS(SQLFIELDNAME)),"data mismatch between FileMan "_$P(^DD(FILE,FIELD,0),"^",1)_" (#"_FIELD_") and SQL "_SQLFIELDNAME)
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
