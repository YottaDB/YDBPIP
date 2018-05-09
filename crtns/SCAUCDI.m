 ; 
 ; **** Routine compiled from DATA-QWIK Procedure SCAUCDI ****
 ; 
 ; 02/24/2010 18:22 - pip
 ; 
 Q 
 ;
STATUS(UCLS,LSGN,MRSTAT,PWDFAIL) ; 
 ;
 N IDLE
 ;
 I MRSTAT Q 3 ; Manually Revoked
 ;
 I $$PWDFAIL(UCLS,PWDFAIL) Q 3 ; Revoked due to Password Failure
 ;
 S IDLE=$$EXPIRED(UCLS,LSGN)
 I IDLE=2 Q 3 ; Revoked due to Inactivity
 I IDLE Q 2 ; Set Status to Inactive
 ;
 Q 1 ; Active Status
 ;
SREASON(UCLS,LSGN,MRSTAT,PWDFAIL) ; 
 ;
 I $$PWDFAIL(UCLS,PWDFAIL) Q 1
 I $$EXPIRED(UCLS,LSGN) Q 2
 I MRSTAT Q 3
 ;
 Q ""
 ;
PWDFAIL(UCLS,PWDFAIL) ; 
 ;
 I (UCLS="") Q 0
 ;
 N scau0 S scau0=$$vRCgetRecord0Opt^RecordSCAU0(UCLS,0,"")
 ;
 ; Status checking turned off
 I '$P(scau0,$C(124),5) Q 0
 ;
 I PWDFAIL'<$P(scau0,$C(124),5) Q 1
 Q 0
 ;
EXPIRED(UCLS,LSGN) ; 
 ;
 N IDLE
 ;
 ; Quit if no User Class is set up or LSGN not populated (New User).
 I UCLS=""!(LSGN="") Q 0
 ;
 N scau0 S scau0=$$vRCgetRecord0Opt^RecordSCAU0(UCLS,0,"")
 ;
 I '$P(scau0,$C(124),27)!('$P(scau0,$C(124),26)) Q 0
 ;
 S IDLE=$P($H,",",1)-LSGN
 ;
 ; Revoked
 I IDLE'<$P(scau0,$C(124),27) Q 2
 ;
 ; Inactive
 I IDLE'<$P(scau0,$C(124),26) Q 1
 ;
 ; Active
 Q 0
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60107^24453^sviji^3096" ; Signature - LTD^TIME^USER^SIZE
