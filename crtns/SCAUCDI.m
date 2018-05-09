SCAUCDI	;
	;
	; **** Routine compiled from DATA-QWIK Procedure SCAUCDI ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	Q 
	;
STATUS(UCLS,LSGN,MRSTAT,PWDFAIL)	;
	s ^KBBO("UCLS")=$G(UCLS)
	s ^KBBO("LSGN")=$G(LSGN)
	s ^KBBO("MRSTAT")=$G(MRSTAT)
	s ^KBBO("PWFAIL")=$G(PWDFAIL)	
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
SREASON(UCLS,LSGN,MRSTAT,PWDFAIL)	;
	;
	I $$PWDFAIL(UCLS,PWDFAIL) Q 1
	I $$EXPIRED(UCLS,LSGN) Q 2
	I MRSTAT Q 3
	;
	Q ""
	;
PWDFAIL(UCLS,PWDFAIL)	;
	;
	I (UCLS="") Q 0
	;
	N scau0 S scau0=$$vDb2(UCLS)
	;
	; Status checking turned off
	I '$P(scau0,$C(124),5) Q 0
	;
	I PWDFAIL'<$P(scau0,$C(124),5) Q 1
	Q 0
	;
EXPIRED(UCLS,LSGN)	;
	;
	N IDLE
	;
	; Quit if no User Class is set up or LSGN not populated (New User).
	I UCLS=""!(LSGN="") Q 0
	;
	N scau0 S scau0=$$vDb2(UCLS)
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
	;
vSIG()	;
	Q "60107^24453^sviji^3092" ; Signature - LTD^TIME^USER^SIZE
	;
vDb2(v1)	;	voXN = Db.getRecord(SCAU0,,0)
	;
	N scau0
	S scau0=$G(^SCAU(0,v1))
	I scau0="",'$D(^SCAU(0,v1))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,SCAU0" X $ZT
	s ^KBBO("SCAU0")=$G(v1)
	s ^KBBO("SCAU0-1")=$G(scau0)	
	Q scau0
