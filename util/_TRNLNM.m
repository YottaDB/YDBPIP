%TRNLNM	;;Library; Translate logical names for device references
	;;Copyright(c)1995 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/19/95 17:04:00 - CHENARD
	;     	ORIG:  		Phil Chenard - 08/15/95
	;
	; 
	; DESC:		Translation of logical to absolute value - 
	;		UNIX platform
	; 
	; INPUT: 	KEYWORD for LNM
	; OUTPUT: 	absolute value
	;
	; KEYWORD:	System Utilities
	;
	; LIBRARY:
	;	. $$BLDPATH	- Constructs the path name of the directory
	;                         and the file name
	;	. $$CDIR	- Return the physical path name of current
	;			  directory
	;	. $$DEVICE	- Return aspect of device based on directory
	;			  name and keyword (NODE, DEVICE, DIRECTORY)
	;	. $$FILE	- Return the physical location of the file
	;                         name that is passed to this utility.
	;	. $$GENERIC	- Generic translator for logical names using
	;			  a syntax that does not fit one of the above,
	;			  for instance "DQRT$BATCH".
	;	. $$HOME	- Return user's home directory
	;	. $$SCA		- Return translated references to logical
	; 			  names beginning w/ "SCA$"
	;	. $$SCAU	- Return translated references to logical
	;			  names beginning w/ "SCAU$"
	; 	. $$SUBDIR	- Construct full name of sub-directory, based
	;			  on keyword passed
	;	. $$SYS		- Return translated references to logical
	;                         names beginning w/ "SYS$"
	;	
	;-----Revision History-------------------------------------------------
	;
	; 05/29/97 - Phil Chenard
        ;            Modified $$FILE section to accomodate situations when
        ;            a directory is included in the file name.
 	;
	; 08/07/95 - Phil Chenard - 13005
	;            Introduce changes to make calls more generic.  The use of
	;            a KEY name passed ot the appropriate function will allow
	;            multiple calls to the same function.
	;
	;----------------------------------------------------------------------
BLDPATH(PATH,FILE)	;Private; Get/create the absolute path 
	;----------------------------------------------------------------------
	I $E(PATH,$L(PATH))="/" S PATH=$E(PATH,1,$L(PATH)-1)
	I '$D(FILE) Q PATH
 	Q PATH_"/"_FILE
	;
	;----------------------------------------------------------------------
CDIR(FILE)	;Public; Get the absolute value of the defined current directory
	;----------------------------------------------------------------------
	; This function will return the absolute value of the directory name 
	; where a process is currently located.
	;
	; ARGUMENTS:
	;	. FILE	- File name, if included will be appended to the
	;                 directory path.		/TYP=T/NOREQ/MECH=VAL
	;
	;----------------------------------------------------------------------
	N ERRNO,PWD,I
	S ERRNO=1
	S PWD=" "
	F I=1:1:24 S PWD=PWD_" "
	D &extcall.pwd(.PWD,.ERRNO)
	I ERRNO=0 S PWD=ERRNO Q PWD
	S PWD=$P(PWD,$C(0),1)
	I $D(FILE) S PWD=$$BLDPATH(PWD,FILE)  ;Get/create the absolut^
 	Q PWD
	;
	;----------------------------------------------------------------------
DEVICE(DIR,KEY)	;Public; Get the absolute value of the defined current directory
	;----------------------------------------------------------------------
	; This function will return the absolute value of the directory name 
	; where a process is currently located.
	;
	; ARGUMENTS:
	;	. DIR	- Directory name to be parsed	/TYP=T/NOREQ/MECH=VAL
	;
	;	. KEY	- Keyword to be used in parsing the directory
	;		  name.				/TYP=T/REQ/MECH=VAL
	;
	; RETURNS:
	;
	;----------------------------------------------------------------------
	N PTH
	I '$D(KEY) Q ""
	I $G(DIR)="" S DIR=$$SCAU("DIR")
	S PTH=$$TRNLNM^%ZFUNC(DIR)
	I KEY="NODE"  Q $P($$PARSE^%ZFUNC(DIR,"NODE"),"::",1)
	Q $$PARSE^%ZFUNC(DIR,KEY)
	;
	;----------------------------------------------------------------------
FILE(FILE,DIR)	;Public; Get/create the absolute path of a file
	;----------------------------------------------------------------------
	; This function will translate the logical name for a directory path
	; and append it to the file name, returning the complete path name for
	; the file.
	;
	; ARGUMENTS:	
	;	. FILE	- File name			/TYP=T/REQ/MECH=VAL
	;
	;	. DIR	- Directory name, expressed as a logical name or as
	;  		  the complete path name.	/TYP=T/REQ/MECH=VAL
	;
	;----------------------------------------------------------------------
	I '$D(FILE) Q ""
	N PATH
	;
        I FILE["/"!(FILE["$") D
        .       S DIR=$$PARSE^%ZFUNC(FILE,"DIRECTORY")
        .       S FILE=$$PARSE^%ZFUNC(FILE,"NAME")_$$PARSE^%ZFUNC(FILE,"TYPE")
 	;
	I $D(DIR) D
	.	I $E(DIR)="$" S DIR=$E(DIR,2,99) 
	.	S PATH=$$TRNLNM^%ZFUNC(DIR,"")
	.	I PATH="" S PATH=DIR
	E  S PATH=$$CDIR		;Default to current directory
	I $E(PATH,$L(PATH))'="/" S PATH=PATH_"/"
	Q PATH_FILE
	;
	;----------------------------------------------------------------------
GENERIC(LOG,KEY,FILE)	;Public; Based on LOG and KEY, return translation 
 	;---------------------------------------------------------------------
	; This function call will return the absolute value of the logical 
	; reference, based on the log and key that is passed.  If a filename 
	; is also included, it will be appended to the full directory extension.
	; 
	; ARGUMENTS:
	;	. LOG	- Generic logical string, used as the first part of 
	;                 the complete logical name, separated by "$".
	;					/TYP=T/REQ/MECH=VAL
	;	. KEY	- Literal string name, identifying the associated 
	;                 logical name, as part of the string LOG_"$"_KEY
	;					/TYP=T/REQ/MECH=VAL
	;
	; 	. FILE	- A file name, if included, will be returned as part of
	;                 the complete directory reference/path for the file.
	;					/TYP=T/NOREQ/MECH=VAL
	;
	; RETURNS:
	;	. path	- Translated physical path name for the logical reference
	;                 with the file name, if included as an argument.
	;
 	;---------------------------------------------------------------------
	I '$D(LOG) Q ""
	I '$D(KEY) Q ""
	N PATH
	S PATH=$$TRNLNM^%ZFUNC(LOG_"_"_KEY)
	I $D(FILE) S PATH=$$BLDPATH(PATH,FILE)
	Q PATH 
	;
	;----------------------------------------------------------------------
HOME(FILE)	;Get the absolute value of the user's login directory
	;----------------------------------------------------------------------
	; Return the user's home directory path, including file name if passed
	;
	; ARGUMENTS:
	;	. FILE	- File name to be attached to the directory string
	;					/TYP=T/NOREQ/MECH=VAL
	;
	; EXAMPLE:
	;
	;	S IO=$$HOME^%TRNLNM("LOGIN.COM") ==>
	;			"USER$DISK:[USER.PROFILE]LOGIN.COM"
	;
	;----------------------------------------------------------------------
	N PATH
	S PATH=$$TRNLNM^%ZFUNC("HOME","")
	I $D(FILE) S PATH=$$BLDPATH(PATH,FILE)	;Get/create the absolute path 
	Q PATH
	;
	;----------------------------------------------------------------------
SCA(KEY,FILE)	;Public; Based on KEY, return translation for "SCA$"*
	;----------------------------------------------------------------------
	; This function call will return the absolute value of the logical 
	; reference, based on the key that is passed.  If a filename is also
	; included, it will be appended to the full directory extension.
	; 
	; ARGUMENTS:	
	;	. KEY	- Literal string name, identifying the associated 
	;                 logical name, as part of the string "SCA$"_KEY
	;					/TYP=T/REQ/MECH=VAL
	;
	; 	. FILE	- A file name, if included, will be returned as part of
	;                 the complete directory reference/path for the file.
	;					/TYP=T/NOREQ/MECH=VAL
	;
	; RETURNS:
	;	. path	- Translated physical path name for the logical reference
	;                 with the file name, if included as an argument.
	;
	;----------------------------------------------------------------------
	I '$D(KEY) Q ""
	N PATH
	S PATH=$$TRNLNM^%ZFUNC("SCA_"_KEY)
	I $D(FILE) S PATH=$$BLDPATH(PATH,FILE)	;Get/create the absolute path 
	Q PATH	
	;
	;----------------------------------------------------------------------
SCAU(KEY,FILE)	;Public; Based on KEY, return translation for "SCAU$"*
 	;---------------------------------------------------------------------
	; This function call will return the absolute value of the logical 
	; reference, based on the key that is passed.  If a filename is also
	; included, it will be appended to the full directory extension.
	; 
	; ARGUMENTS:	
	;	. KEY	- Literal string name, identifying the associated 
	;                 logical name, as part of the string "SCAU$"_KEY
	;					/TYP=T/REQ/MECH=VAL
	;
	; 	. FILE	- A file name, if included, will be returned as part of
	;                 the complete directory reference/path for the file.
	;					/TYP=T/NOREQ/MECH=VAL
	;
	; RETURNS:
	;	. path	- Translated physical path name for the logical reference
	;                 with the file name, if included as an argument.
	;
 	;---------------------------------------------------------------------
	I '$D(KEY) Q ""
	N PATH
	S PATH=$$TRNLNM^%ZFUNC("SCAU_"_KEY)
	I $D(FILE) S PATH=$$BLDPATH(PATH,FILE)
	Q PATH 
	;
	;----------------------------------------------------------------------
SUBDIR(DIR,SUB)	;Public; Build directory path for the sub-directory name
	;----------------------------------------------------------------------
	; This function will construct the appropriate path name for a sub-
	; directory of the primary directory, as passed as the first argument.
	;
	; ARGUMENTS:	
	;	. DIR	- Primary directory name for which 
	;		  the subdirectory will be included
	;						/TYP=T/REQ/MECH=VAL
	;
	;	. SUB	- String to be used to name the sub-
	;		  directory.			/TYP=T/REQ/MECH=VAL
	;
	; RETURNS:
	;	. $$	- Full path name for the sub-directory name passed
	;
	;----------------------------------------------------------------------
	; This function will construct the path name for a sub-directory of the 
	; primary directory name passed.  
	;
	I '$D(DIR) Q ""
	I '$D(SUB) Q $$TRNLNM^%ZFUNC(DIR)
	;
	N PTH
	S PTH=$$TRNLNM^%ZFUNC(DIR,1)
	I PTH="" S PTH=DIR
	I $E(PTH,$L(PTH))="/" S PTH=$E(PTH,1,$L(PTH)-1)
	Q PTH_"/"_SUB
	;
	;----------------------------------------------------------------------
SYS(KEY,FILE)	;Public; Based on KEY, return translation for "SCA$"*
	;----------------------------------------------------------------------
	; This function call will return the absolute value of the logical 
	; reference, based on the key that is passed.  If a filename is also
	; included, it will be appended to the full directory extension.
	; 
	; ARGUMENTS:	
	;	. KEY	- Literal string name, identifying the associated 
	;                 logical name, as part of the string "SYS_"_KEY
	;					/TYP=T/REQ/MECH=VAL
	;
	; 	. FILE	- A file name, if included, will be returned as part of
	;                 the complete directory reference/path for the file.
	;					/TYP=T/NOREQ/MECH=VAL
	;
	; RETURNS:
	;	. path	- Translated physical path name for the logical reference
	;                 with the file name, if included as an argument.
	;
	;----------------------------------------------------------------------
	I '$D(KEY) Q ""
	N PATH
	S PATH=$$TRNLNM^%ZFUNC("SYS_"_KEY)
	I $D(FILE) S PATH=$$BLDPATH(PATH,FILE)	;Get/create the absolute path 
	Q PATH	
	;
