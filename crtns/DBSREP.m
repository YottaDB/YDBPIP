 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSREP ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
 Q 
 ;
KEY(tbl,init,order,fmt) ; Return first or last key value in table
 N fsn,key1,keys,par,sqldta,sqlsta
 S order=$get(order)
 S init=$get(init)
 S fmt=$get(fmt)
 S ER=0 S RM=""
 ;
 D fsn^DBSDD(.fsn,tbl)
 I ER Q ""
 S keys=$piece(fsn(tbl),"|",3)
 S key1=$piece(keys,",",1)
 S ER=$$^SQL("SELECT "_key1_" FROM "_tbl_" ORDER BY "_key1_" "_$S(order:"DESC",1:"ASC"),.par,.sqlsta,.sqldta)
 I ER Q ""
 ;
 I fmt="D" Q $S(sqldta'="":$ZD(sqldta,"MM/DD/YEAR"),1:"")
 Q sqldta
 ;
EXISTS(tbl,key) ; Returns indicator of whether the record exists
 N fsn,key1,keys,par,sqldta,sqlsta
 S ER=0 S RM=""
 ;
 D fsn^DBSDD(.fsn,tbl)
 I ER Q ""
 S keys=$piece(fsn(tbl),"|",3)
 S key1=$piece(keys,",",1)
 S ER=$$^SQL("SELECT "_key1_" FROM "_tbl_" WHERE "_key1_"="_key,.par,.sqlsta,.sqldta)
 I sqldta'="" Q 1
 Q 0
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60264^15442^P.R. Swarnalatha^2216" ; Signature - LTD^TIME^USER^SIZE
