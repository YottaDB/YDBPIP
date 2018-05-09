SCATIM	;
	;
	; **** Routine compiled from DATA-QWIK Procedure SCATIM ****
	;
	; 12/06/2007 16:14 - chenardp
	;
	;
	D START
	Q 
	;
START	;
	;
	; Entry exceeds 24 hours
	I %TS?1N.N S:%TS>86400 ER=1 S:%TS>86400 RM=$$^MSG(966) S %TN=%TS Q 
	;
	I %TS="T"!(%TS="C") S %TN=$P($H,",",2) Q 
	S %TS=$translate(%TS," ")
	I %TS="12:00A"!(%TS="12:00AM") S %TN=1 Q 
	;
	; convert if format is military time  00:00:00 to 24:59:59
	I (%TS?1N.N1":"1N.N!(%TS?1N.N1":"1N.N1":".N)),%TS<24 S %TN=((($piece(%TS,":",1)*60)+$piece(%TS,":",2))*60)+$piece(%TS,":",3) Q 
	D AMPM
	Q 
	;
AMPM	;  Convert if standard format (time with AM or PM)
	N %M N %S N %X N %Y N %Z
	;
	S %M=0 S %S=0
	I %TS?4N D CNVHHMM Q 
	S %X=$piece(%TS,":",1) S %Y=$piece(%TS,":",2) S %Z=$piece(%TS,":",3,99)
	;
	I %Z]]"" D SEC Q 
	I %Y]]"" D MIN Q 
	D HRS
	Q 
	;
CNVHHMM	;  Hours and Seconds in HHMM (no semicolon)
	;
	S %H=$E(%TS,1,2) S %M=$E(%TS,3,4)
	I %H>23!(%M>60) S %TN=-1 Q 
	;
	S %TN=(%H*3600)+(%M*60)
	Q 
	;
SEC	;  Convert Format in Hours, Minutes, Seconds  (12:00:00AM to 11:59:59PM)
	;
	I %X?1N!(%X?2N),%X<13,%X>0 S %H=%X+0
	E  S %TN=-1 Q 
	I %H>12!(%H<1) S %TN=-1 Q 
	I %Y?2N,%Y<60 S %M=%Y+0
	E  S %TN=-1 Q 
	S %S=%Z+0 I %S<0!(%S>59) S %TN=-1 Q 
	I %Z?2N1U.U S %Z=$E(%Z,3,99) D CALC Q 
	I %Z?2N1" "1U.U S %Z=$E(%Z,4,99) D CALC Q 
	S %TN=-1
	Q 
	;
MIN	;  Convert Format in Hours, Minutes (12:00AM to 11:59PM)
	;
	I %X?1N!(%X?2N),%X<13,%X>0 S %H=%X+0
	E  S %TN=-1 Q 
	I %H>12!(%H<1) S %TN=-1 Q 
	S %M=%Y+0 I %M<0!(%M>59) S %TN=-1 Q 
	I %Y?2N1U.U S %Z=$E(%Y,3,99) D CALC Q 
	I %Y?2N1" "1U.U S %Z=$E(%Y,4,99) D CALC Q 
	S %TN=-1
	Q 
	;
HRS	;  Convert Hours  (12AM to 11PM)
	;
	I %X?1N.N1" "1U.U S %H=%X+0 S %Z=$piece(%X," ",2)
	E  I %X?1N1U.U S %H=%X+0 S %Z=$E(%X,2,99)
	E  I %X?2N1U.U S %H=%X+0 S %Z=$E(%X,3,99)
	E  S %TN=-1 Q 
	I %H>12!(%H<1) S %TN=-1 Q 
	D CALC
	Q 
	;
CALC	; compute final time
	;
	I %Z="P"!(%Z="PM") S:%H<12 %H=%H+12
	E  I %Z="N"!(%Z="NOON"),%H=12,%M=0,%S=0 S %TN=43200 Q 
	E  I %Z="M"!(%Z?1"MID".E),%H=12,%M=0,%S=0 S %TN=86400 Q 
	E  I %Z="A"!(%Z="AM") S:%H=12 %H=0
	E  S %TN=-1 Q 
	;
	S %TN=(%H*3600)+(%M*60)+%S
	;
	Q 
	;
	;-----------------------------------------------------------------------
NS	;
	;
	N %H N %M N %S
	;
	I %TN="" S ER=1 Q 
	;
	; Entry exceeds 24 hours
	I %TN>86400 S ER=1 S RM=$$^MSG(966) Q 
	;
	S %H=(%TN\3600)+100 S %M=((%TN#3600)\60)+100 S %S=(%TN#60)+100
	I %H>112 S %H=%H-12
	I %H=100 S %H="112"
	S %TS=$E(%H,2,3)_":"_$E(%M,2,3)
	I %TN=0!(%TN=86400) S %TS=%TS_" M" Q 
	I %TN<43200 S %TS=%TS_"AM" Q 
	I %TN=43200 S %TS=%TS_" N" Q 
	S %TS=%TS_"PM"
	Q 
	;
vSIG()	;
	Q "60178^29149^Sanjay Chhrabria^4342" ; Signature - LTD^TIME^USER^SIZE
