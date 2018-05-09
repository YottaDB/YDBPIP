%LNM	
	;;Copyright(c)1992 Sanchez Computer Associates, Inc.  All Rights Reserved  
	;     	ORIG:  		Sara Walters 6/06/95
	;
	;		DESC:		Translation of logical to absolute value
	;    	INPUT: 		KEYWORD for LNM
	;   	OUTPUT: 	absolute value
	;
	;----------------------------------------------------------------------
HOME(FILENAME)	;Get the absolute value of the user's login directory
	;----------------------------------------------------------------------
	N PATH
	S PATH=$$TRNLNM^%ZFUNC("HOME","")
	I $D(FILENAME) S PATH=$$BUILDPATH(PATH,FILENAME)	;Get/create the absolute path 
	Q PATH
	;
	;----------------------------------------------------------------------
CRTNS(FILENAME)	;Get the absolute value of the defined CRTNS directory
	;----------------------------------------------------------------------
	N PATH
	S PATH=$$TRNLNM^%ZFUNC("SCAU_CRTNS","")
	I $D(FILENAME) S PATH=$$BUILDPATH(PATH,FILENAME)	;Get/create the absolute path 
	Q PATH	
	;
	;----------------------------------------------------------------------
COBJ(FILENAME)	;Get the absolute value of the defined COBJ directory
	;----------------------------------------------------------------------
	N PATH
	S PATH=$$TRNLNM^%ZFUNC("SCAU_COBJ","")
	I $D(FILENAME) S PATH=$$BUILDPATH(PATH,FILENAME)	;Get/create the absolute path 
	Q PATH
	;----------------------------------------------------------------------
MRTNS(FILENAME)	;Get the absolute value of the defined MRTNS directory
	;----------------------------------------------------------------------
	N PATH
	S PATH=$$TRNLNM^%ZFUNC("SCAU_MRTNS","")
	I $D(FILENAME) S PATH=$$BUILDPATH(PATH,FILENAME)	;Get/create the absolute path 
	Q PATH	
	;
	;----------------------------------------------------------------------
MOBJ(FILENAME)	;Get the absolute value of the defined MOBJ directory
	;----------------------------------------------------------------------
	N PATH
	S PATH=$$TRNLNM^%ZFUNC("SCAU_MOBJ","")
	I $D(FILENAME) S PATH=$$BUILDPATH(PATH,FILENAME)	;Get/create the absolute path 
	Q PATH	
	;----------------------------------------------------------------------
RTNS(FILENAME)	;Get the absolute value of the defined RTNS directory
	;----------------------------------------------------------------------
	N PATH
	S PATH=$$TRNLNM^%ZFUNC("SCAU_RTNS","")
	I $D(FILENAME) S PATH=$$BUILDPATH(PATH,FILENAME)	;Get/create the absolute path 
	Q PATH	
	;
	;----------------------------------------------------------------------
SRTNS(FILENAME)	;Get the absolute value of the defined SRTNS directory
	;----------------------------------------------------------------------
	N PATH
	S PATH=$$TRNLNM^%ZFUNC("SCAU_SRTNS","")
	I $D(FILENAME) S PATH=$$BUILDPATH(PATH,FILENAME)	;Get/create the absolute path 
	Q PATH	
	;
	;----------------------------------------------------------------------
PRTNS(FILENAME)	;Get the absolute value of the defined PRTNS directory
	;----------------------------------------------------------------------
	N PATH
	S PATH=$$TRNLNM^%ZFUNC("SCAU_PRTNS","")
	I $D(FILENAME) S PATH=$$BUILDPATH(PATH,FILENAME)	;Get/create the absolute path 
	Q PATH	
	;
	;----------------------------------------------------------------------
SAVRTNS()	;Get the absolute value of the defined SAVRTNS directory
	;----------------------------------------------------------------------
	N PATH
	S PATH=$$TRNLNM^%ZFUNC("SCAU_SAVRTNS","")
	Q PATH	
	;
	;----------------------------------------------------------------------
GBLS(FILENAME)	;Get the absolute value of the defined GBLS directory
	;----------------------------------------------------------------------
	N PATH
	S PATH=$$TRNLNM^%ZFUNC("SCAU_GBLS","")
	I $D(FILENAME) S PATH=$$BUILDPATH(PATH,FILENAME)	;Get/create the absolute path 
	Q PATH	
	;
	;----------------------------------------------------------------------
EXP(FILENAME)	;Get the absolute value of the defined Export directory
	;----------------------------------------------------------------------
	N PATH
	S PATH=$$TRNLNM^%ZFUNC("SCAU_EXP","")
	I $D(FILENAME) S PATH=$$BUILDPATH(PATH,FILENAME)	;Get/create the absolute path 
	Q PATH	
	;
	;----------------------------------------------------------------------
SPL(FILENAME)	;Get the absolute value of the defined Spool directory
	;----------------------------------------------------------------------
	N PATH
	S PATH=$$TRNLNM^%ZFUNC("SCAU_SPL","")
	I $D(FILENAME) S PATH=$$BUILDPATH(PATH,FILENAME)	;Get/create the absolute path 
	Q PATH	
	;
	;----------------------------------------------------------------------
DDP(FILENAME)	;Get the absolute value of the defined DDP directory
	;----------------------------------------------------------------------
	N PATH
	S PATH=$$TRNLNM^%ZFUNC("SCAU_DDP","")
	I $D(FILENAME) S PATH=$$BUILDPATH(PATH,FILENAME)	;Get/create the absolute path 
	Q PATH	
	;
	;----------------------------------------------------------------------
DDPLOG(FILENAME)	;Get the absolute value of the defined DDP Log directory
	;----------------------------------------------------------------------
	N PATH
	S PATH=$$TRNLNM^%ZFUNC("SCAU_DDPLOG","")
	I $D(FILENAME) S PATH=$$BUILDPATH(PATH,FILENAME)	;Get/create the absolute path 
	Q PATH	
	;
	;----------------------------------------------------------------------
NODNAM(FILENAME)	;Get the absolute value of the defined Node name
	;----------------------------------------------------------------------
	N PATH
	S PATH=$$TRNLNM^%ZFUNC("SCAU_NODNAM","")
	I $D(FILENAME) S PATH=$$BUILDPATH(PATH,FILENAME)	;Get/create the absolute path 
	Q PATH	
	;
	;----------------------------------------------------------------------
HELP(FILENAME)	;Get the absolute value of the defined HELP directory
	;----------------------------------------------------------------------
	N PATH
	S PATH=$$TRNLNM^%ZFUNC("SCAU_HELP","")
	I $D(FILENAME) S PATH=$$BUILDPATH(PATH,FILENAME)	;Get/create the absolute path 
	Q PATH	
	;----------------------------------------------------------------------
	;
	;----------------------------------------------------------------------
BATCH(FILENAME)	;Get the absolute value of the defined BATCH directory
	;----------------------------------------------------------------------
	N PATH
	S PATH=$$TRNLNM^%ZFUNC("SCAU_BATCH","")
	I $D(FILENAME) S PATH=$$BUILDPATH(PATH,FILENAME)	;Get/create the absolute path 
	Q PATH	
	;
	;----------------------------------------------------------------------
PRINT(FILENAME)	;Get the absolute value of the defined PRINT directory
	;----------------------------------------------------------------------
	N PATH
	S PATH=$$TRNLNM^%ZFUNC("SCAU_PRINT","")
	I $D(FILENAME) S PATH=$$BUILDPATH(PATH,FILENAME)	;Get/create the absolute path 
	Q PATH	
	;
	;----------------------------------------------------------------------
IBSUPDATE()	;Get the absolute value of the defined IBS UPDATE directory
	;----------------------------------------------------------------------
	N PATH
	S PATH=$$TRNLNM^%ZFUNC("SCAU_IBS_UPDATE","")
	Q PATH	
	;
CDIR(FILENAME)	;Get the absolute value of the defined current directory
	;----------------------------------------------------------------------
	N ERRNO,PWD,I
    	S ERRNO=1
	S PWD=" "
	F I=1:1:24 S PWD=PWD_" "
    	D &extcall.pwd(.PWD,.ERRNO)
    	I ERRNO=0 S PWD=ERRNO
	I $D(FILENAME) S PWD=$$BUILDPATH(PWD,FILENAME)	;Get/create the absolute path 
    Q PWD
	;
	;----------------------------------------------------------------------
BUILDPATH(PATH,FILENAME)	;Get/create the absolute path 
	;----------------------------------------------------------------------
	I PATH'="" D
	.	I FILENAME="PATH" S PATH=PATH_"/"
	.	E  S PATH=PATH_"/"_FILENAME
	Q PATH	
	;
	;----------------------------------------------------------------------
FILE(LNM,FILENAME)	;Get/create the absolute path of a file
	;----------------------------------------------------------------------
	N PATH
	I LNM["$" S LNM=$P(LNM,"$",1)_"_"_$P(LNM,"$"_2)
	S PATH=$$TRNLNM^%ZFUNC(LNM,"")
	I PATH="" Q ""
	Q PATH_"/"_FILENAME
