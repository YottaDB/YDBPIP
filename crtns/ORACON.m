 ; 
 ; **** Routine compiled from DATA-QWIK Procedure ORACON ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
ORACON ; Connects to oracle database
 ;
 Q 
 ;
C ; Connect
 ;
 N index
 N inipath
 ;
 S inipath=$$TRNLNM^%ZFUNC("SCAU_DB_INI")
 I inipath="" Q 
 S index=0
 S ER=$$DBCNCT^%DBAPI(inipath,0,.RM)
 ;
 F  BREAK 
 ;
 Q 
 ;
D ; Disconnect
 ;
 I $get(index)="" S index=0
 S ER=$$DBDSCNCT^%DBAPI(index,.RM)
 ;
 Q 
 ;
RUNC ; Connect with no break
 ;
 N index
 N inipath
 ;
 S inipath=$$TRNLNM^%ZFUNC("SCAU_DB_INI")
 I inipath="" Q 
 S index=0
 S ER=$$DBCNCT^%DBAPI(inipath,0,.RM)
 ;
 Q 
 ;
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60092^50707^Badrinath Giridharan^1469" ; Signature - LTD^TIME^USER^SIZE
