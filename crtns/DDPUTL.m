 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DDPUTL ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
 ;
 Q 
 ;
GBLDIR(DIR) ; Return the global directory reference
 ;
 N GBLDIR,NODNAM
 ;
 S NODNAM=$$DEVICE^%TRNLNM(DIR,"NODE")
 I NODNAM'="" S GBLDIR=$$SCAU^%TRNLNM(NODNAM_"_"_DIR_"_GBLDIR")
 E  S GBLDIR=$$TRNLNM^%ZFUNC(DIR_"_GBLDIR")
 Q GBLDIR
 ;
NODNAM(DIR) ; Return the node name the directory sits on
 ;
 N NODNAM
 S NODNAM=$$DEVICE^%TRNLNM(DIR,"NODE")
 I NODNAM="" S NODNAM=$$NODENAM^%ZFUNC
 Q NODNAM
 ;
FULNAM(DIR) ; Return the full directory reference of DIR
 ;
 Q $$TRNLNM^%ZFUNC(DIR)
 ;
INIT(DIR) ; Define all values
 ;
 N STR
 K DDPDIR,FULNAM,GBLDIR,NODNAM
 ;
 S FULNAM=$$TRNLNM^%ZFUNC(DIR) Q:FULNAM="" 
 ;
 S NODNAM=$$DEVICE^%TRNLNM(DIR,"NODE")
 ;
 S DDPDIR=$$SCAU^%TRNLNM("DDPLOG")
 I NODNAM'="" S GBLDIR=$$SCAU^%TRNLNM(NODNAM_"_"_DIR_"_GBLDIR")
 E  S GBLDIR=$$TRNLNM^%ZFUNC(DIR_"_GBLDIR")
 I NODNAM="" S NODNAM=$$NODENAM^%ZFUNC
 Q 
 ;
DDPDIR(DIR) ; Return the DDP directory name
 ;
 Q $$SCAU^%TRNLNM("DDP")
 ;
%EXT(DIR,NODNAM,FULNAM,GBLDIR) ; Return all values for DIR
 ;
 D INIT(DIR)
 Q 
 ;
DIR() ; Return directory logical name used for DDP processing
 ;
 Q $$SCAU^%TRNLNM("DDPLOG")
 ;
HOSTLOG() ; Return Logical name for the host directory
 ;
 Q $$SCAU^%TRNLNM("DIR")
 ;
SPOOL(DIR) ; Return the spool directory
 ;
 Q $$SUBDIR^%TRNLNM(DIR,"SPOOL")
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60269^49577^kellytp^5843" ; Signature - LTD^TIME^USER^SIZE
