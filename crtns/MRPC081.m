 ; 
 ; **** Routine compiled from DATA-QWIK Procedure MRPC081 ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
 ;  #OPTION ResultClass ON
 ;
MRPC081(RETURN,versn,TABLE,elements) ; Elements to compile
 ;
 N i
 N ET N name
 ;
 ; Version number of client message is not compatible with server
 I (+versn'=+1) Q $$ERRMSG^PBSUTL($$^MSG(2951))
 ;
 ; Missing parameter
 I ((TABLE="")!(elements="")) Q $$ERRMSG^PBSUTL($$^MSG(8607))
 ;
 S ER=0
 ;
 F i=1:1:$S((elements=""):0,1:$L(elements,",")) D  Q:ER 
 .	;
 .	S name=$piece(elements,",",i)
 .	;
 .	; Protect variables
 .	N i
 .	N elements
 .	N pgm S pgm=""
 .	;
 .	D COMPILE(TABLE,name,.pgm)
 .	;
 .	I 'ER,'((TABLE="DBTBL1")&((name="DEP")!(name="LN"))) D RELINK(pgm)
 .	Q 
 ;
 I ER Q $$ERRMSG^PBSUTL($get(RM),$get(ET))
 ;
 S RETURN=$$V2LV^MSG("")
 ;
 Q ""
 ;
COMPILE(TABLE,NAME,pgm) ; Program compiled
 ;
 ; Build filer
 I (TABLE="DBTBL1") D
 .	;
 .	I ((NAME="DEP")!(NAME="LN")) D
 ..		;
 ..		N PARM N PTMDIRID N X
 ..		;
 ..		S PTMDIRID=""
 ..		;
 ..		S PARM="DEPLN^MRPC081("""_NAME_""")"
 ..		;
 ..		S X=$$^%ZJOB(PARM,"PRO=",1)
 ..		Q 
 .	E  D
 ..		;
 ..		D COMPILE^DBSFILB(NAME)
 ..		;
 ..		I 'ER S pgm="Record"_NAME
 ..		;
 ..		Q 
 .	Q 
 ;
 ; Build Data Item Protection program
 E  I (TABLE="DBTBL14") D
 .	;
 .	D BUILD^DBSPROT3(NAME)
 .	;
 .	I 'ER D ^UPID(NAME,.pgm)
 .	Q 
 ;
 ; Build procedure
 E  I (TABLE="DBTBL25") D
 .	;
 .	D COMPILE^DBSPROC(NAME,.pgm)
 .	Q 
 ;
 ; Build batch
 E  I (TABLE="DBTBL33") D
 .	;
 .	N cmpflg
 .	;
 .	D COMPILE^DBSBCH(NAME,.cmpflg,.pgm)
 .	Q 
 ;
 E  D
 .	;
 .	S ER=1
 .	; Invalid table name - ~p1
 .	S RM=$$^MSG(1484,TABLE)
 .	Q 
 ;
 Q 
 ;
RELINK(pgm) ; Routine to re-link to server
 ;
 I '(pgm="") D CTRLMSG^PBSUTL("EXEC ZL """_pgm_"""")
 ;
 Q 
 ;
DEPLN(NAME) ; "DEP" or "LN" to compile
 ;
 N ER S ER=0
 ;
 D COMPILE^DBSFILB(NAME)
 ;
 I 'ER D RELINK("Record"_NAME)
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61237^74513^Dan Russell^3652" ; Signature - LTD^TIME^USER^SIZE
