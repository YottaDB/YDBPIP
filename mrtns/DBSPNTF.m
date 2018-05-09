DBSPNTF	;; Format print routine for Foreign Client Interface
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 06/06/94 08:48:15 - CHENARD
	;     ORIG:  CHENARD
	;
	; This DATA-QWIK print program is used when the link to the
	; host PROFILE system is originated at a PC or similar 
	; processor.  It will construct a record containing the 
	; data fields comprised in the DATA-QWIK screen(s).  This
	; print program is called by DATA-QWIK when %OPMODE
	; indicates that the device to direct output is a foreign
	; client.
	;
	;  RETURNS:
	;            %MSGS - this variable is returned if an inquiry has 
	;                    been made, %O=2.  This variable is protected 
	;                    in the exclusive kill performed in the driver.
	;
	;------Revision History------------------------------------------------
	;
	;----------------------------------------------------------------------
BLDMSG	; Package screen data and put into system variable %MSGS.
	; Collate through the VO array and construct a single record of the
	; data elements contained in the array.
	;-----------------------------------------------------------------------
	I %O'=2 Q			;only print for inquiries
	I '$D(VO) Q
	N i,voend,voseq,vobeg
	I $G(PGM)="UTLREAD" Q		;don't include the UTLREAD screen
	I '$D(%MSGS) S %MSGS=""
	S voend=$P(VO,"|",1)
	S vobeg=$P(VO,"|",2),voseq=vobeg-1
	F i=1:1 S voseq=$o(VO(voseq)) q:voseq=""!(voseq>voend)  d  
	.	N data,x
	.	S x=VO(voseq)
	.	S data=$E(x,14,$L(x))
	.	S %MSGS=%MSGS_"|"_data
	I $E(%MSGS)="|" S %MSGS=$E(%MSGS,2,$L(%MSGS))
	Q
