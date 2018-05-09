SCAIO	;Public;Select IO Device
	;;Copyright(c)1995 Sanchez Computer Associates, Inc.  All Rights Reserved - 07/12/95 11:36:15 - CHENARD
	; ORIG: Dan S. Russell
	;
	; General purpose SCA device selection
	;
	;---- Revision History ------------------------------------------------
	;
	; 07/11/95 - Phil Chenard - 13005
	;            Integrated changes to accomodate multi-platform device
	;            handling.
	;
	; 02/20/95 - Dan Russell - 10174
	;            Eliminated reference to ^SPLFIL (does not exist).  Replaced
	;            with OPEN^%ISSPL.  Not used with GT.M, but would be with
	;            ISM if ever use again.
	;
	; 10/23/94 - Dan Russell - I18N
	;            Modified various $$^MSG calls.
	;
	; 09/02/94 - Jagannath Rao Chapyala - ARQ 10174
	;	     Retrofited the bugs resolved in V4.4 and earlier versions.
	;	     Also changed the %MODE to %IPMODE.
	;
	; 05/25/94 - Janet An - I18N
	;            Replaced embedded messages with a call to extrinsic 
	;            function $$^MSG(msgid,p1,p2...) for phrase independence.
	;
	; 04/19/94 - mjr (Changes from Dan Russell)
	;            Added ability to APPEND output to file using
	;            qualifier /APPEND on entry of device.
	;
	; 04/08/94 - mjr - ARQ# 12899
	;	     Update public function documentation to adhere to 
	;	     programming standards.
	;
	; 11/30/93 - RUSSELL - 10588
	;            Add redirection of IO in OPEN section, based on %OPMODE 
	;            containing OUTPUT parameter.  DQRT service class requires 
	;            output redirection to an file for batch mode process.
	;
	; 10/17/93 - Frank Prendergast - I18N#18
	;            Change call to DBSMBAR from DBSMENU
	;            Text moved to ^STBL("MBAR",32)
	;            Added call to $$^MSG("RM3572") to remove text
	;
	; 08/06/93 - Dan Russell - ARQ9403
	;            In OPEN section, IF '$D(IOTYP), called DEVICE section,
	;            which in turn called OPEN.  Fixed this nesting problem.
	;
	; 11/30/92 - Allan Mattson - I18N#7
	;            Modified return message handling with a call to extrinsic
	;            function $$^MSG(msgid,p1,p2...) for I18N development
	;            (phrase independence).
	;
	;----------------------------------------------------------------------
	;
	D ^%SCAIO 		;All processing done in ^%SCAIO
	Q
	;
	;----------------------------------------------------------------------
OPEN	;Public; Open the device - Can be called from external programs
	;
	; DESC:
	;  	IO must be defined.  Other IO* variables should be as well
	;  	If %OPMODE is defined and contains OUTPUT parameter, attempt
	;  	to redirect output to device specified.
	;  	This subroutine will 'open' device or return ER=1,RM=message.
	;
	; KEYWORDS: Device Handling
	;
	; INPUTS:
	;	. IO		I/O device name		/TYP=T/REQ
	;
	;	. %OPMODE	Output mode 		/TYP=T/NOREQ
	;			Defines redirection of output
	;			to a device other than the input
	;			device (ie. Terminal when input from
	;			a device other than the keyboard)
	;
	;	. %TO		Timeout in seconds	/TYP=N/NOREQ/DFT=60
	;
	;	. IOTYP		Device type, defined 	/TYP=T/NOREQ
	;			as part of validation or device open
	;
	;	. %IPMODE		Block mode indicator	/TYP=T/NOREQ
	;	
	;	. IOPAR		I/O parameters		/TYP=T/NOREQ
	;			List of params used on open
	;
	;----------------------------------------------------------------------
	;
	D OPEN^%SCAIO
	Q
	;
	;----------------------------------------------------------------------
CLOSE	;Public; Close device
	;----------------------------------------------------------------------
	;
	; KEYWORDS: Device Handling
	;
	; INPUTS:
	;	. %IPMODE		Block mode indicator	/TYP=T/NOREQ
	;	
	;	. IO		I/O device name		/TYP=T/REQ
	;
	;	. IOSUB		I/O subtype name	/TYP=T/NOREQ
	;			Used to handle CRADEN and OKIDATA 
	;			printer devices
	;
	;	. AUXPTR	Auxiliary printer flag	/TYP=T/NOREQ
	;			Used to identify device as another printer
	;			device and initiate send of escape sequence
	;			to the auxiliary device, if required to 
	;			'close' printer
	;
	;----------------------------------------------------------------------
	D CLOSE^%SCAIO
	Q
