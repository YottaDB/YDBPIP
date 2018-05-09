 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSFVER ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSFVER ; 
 ;
 S ER=$$VALIDATE(FILES,.RM)
 ;
 Q 
 ;
VALIDATE(TABLES,RM) ; Error message /MECH=REFNAM:W
 ;
  ; Screen look-up table
 ;
 N ER
 N J
 N LOOP N PRMRYTBL
 ;
 S ER=0
 S (PRMRYTBL,RM)=""
 ;
 I (TABLES="") Q 0
 ;
 I (TABLES[",") S I(3)=""
 ;
 S PRMRYTBL=$piece(TABLES,",",1)
 ;
 F J=1:1:$L(TABLES,",") D  Q:ER 
 .	;
 .	N K
 .	N keys N TBL
 .	;
 .	S TBL=$piece(TABLES,",",J)
 .	;
 .	I (TBL="") D  Q 
 ..		;
 ..		S ER=1
 ..		; Invalid syntax - ~p1
 ..		S RM=$$^MSG(1477,TABLES)
 ..		Q 
 .	;
 .	I '$$isTable^UCXDD(TBL) D  Q 
 ..		;
 ..		S ER=1
 ..		; Invalid file - ~p1
 ..		S RM=$$^MSG(1334,TBL)
 ..		Q 
 .	Q 
 ;
 I ER Q 1
 ;
 I ($L(TABLES,",")=1) Q 0 ; Single table
 ;
 S ER=$$VALIDATE^DBSREL(TABLES,.LOOP,.RM) I ER D
 .	;
 .	; Invalid files relationship - ~p1
 .	S RM=$$^MSG(1346,TABLES)
 .	Q 
 ;
 E  I ($get(LOOP(-2,1))'=PRMRYTBL) D
 .	;
 .	S ER=1
 .	; Select ~p1 for primary file ID
 .	S RM=$$^MSG(2470,LOOP(-2,1))
 .	Q 
 ;
 Q ER
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60425^2727^Dan Russell^1929" ; Signature - LTD^TIME^USER^SIZE
