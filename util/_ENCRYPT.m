%ENCRYPT	;Public;Password Encryption/Authentication
	;;Copyright(c)2000 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/10/00 10:10:10 - LYH
	;     ORIG:  Allan Mattson - 10/13/98
	;     DESC:  Password Encryption/Authentication
	;
	; KEYWORDS: Security
	;
	;
	;---- Revision History ------------------------------------------------
	; 03/26/02 - Xianguan Li 
	;	     Added plain blowfish cipher usage 
	;	     This includes adding following six tags plus
	;	     modification to ENCRYPT/DECRYPT to invoke the new tags 
	;
	;	     BLKEY 	- generate a key for use with BLOWFISH
	;	     BLKEYHEX 	- generate a key for use with BLOWFISH
	;			  then, hex-encode it	
	;	     BLENC 	- encrypt data with plain blowfish
	;	     BLENCHEX 	- encrypt data with plain blowfish
	;			  then, hex-encode it	
	;	     BLDEC 	- decrypt data with plain blowfish
	;	     BLDECHEX 	- decrypt hex-encoded data with 
	;			  plain blowfish
	;
	; 10/10/00 - Hien Ly -ARQ 42174
	;	     Added blowfish cipher and two new tags:
	;	     ENCRYPT - generic entry point for encryption.
	;	     DECRYPT - generic entry point for decryption.
	;	     Fixed section ASCENC to perform ASCII encoding/decoding.
	;
        ; 03/13/00 - Harsha Lakshmikantha - ARQ 34723
        ;	     Modified AUT section to return success or failure.
	; 
	; 02/24/00 - Hien Ly - ARQ 35332
	;	     Added the following functions:
	;	     KEYPAIR - generates an RSA public/private key pair.
	;	     KEYXCHG - exchanges public key with client.
	;	     ASCENC - performs RSA ASCII encode/decode operations.
	;	     RSAENC - performs RSA encrypt/decrypt using RSA digital
	;	     envelope.
	;
        ; 05/12/99 - Harsha Lakshmikantha
        ;	     Modified ENC section to return success or failure and save
	;	     the encrypted password in ENC.
	; 
	;----------------------------------------------------------------------
	;----------------------------------------------------------------------
KEY(LEN)	;Public;Generate SignOnKey
	;----------------------------------------------------------------------
	;
	; KEYWORDS: Security
	;
	; ARGUMENTS:
	;     . LEN	Length of string		/TYP=N/NOREQ/MECH=VAL
	;						/MIN=40/MAX=128
	; RETURNS:
	;     . $$	Sign-on key			/TYP=T
	;
	; EXAMPLE:
	;     S X=$$KEY^%ENCRYPT()
	;----------------------------------------------------------------------
	;
	N I,KEY
	;
	S LEN=$G(LEN) I LEN<40!(LEN>128) S LEN=$R(89)+40
	S KEY="" F I=1:1:LEN S KEY=KEY_$C($R(92)+32)
	Q KEY
	;
	;----------------------------------------------------------------------
ENC(PWD,ENC)	;Public;Encrypt user password
   	;----------------------------------------------------------------------
	;
	; KEYWORDS: Security
	;
 	; ARGUMENTS:
	;     . PWD	User password (clear)		/TYP=T/REQ
	;     . ENC     Encrypted password              /TYP=T
        ;
        ; RETURNS:
        ;     . $$      Condition value                 /TYP=L
        ;               0 = Success
        ;               1 = Encryption Error
        ;
        ; EXAMPLE:
        ;     S X=$$ENC^%ENCRYPT(PWD,.ENC)
   	;
	;----------------------------------------------------------------------
	;
	; This function calls the scamd5 external function to encrypt the
	; passed string.  This function utilize the MD5 encryption algorithm.
	;
	N enclen,encpwd,rc,outlen,opt,I
	S encpwd=""
	S outlen=128,opt="",rc=0
        F I=1:1:128 S encpwd=encpwd_" "
        D &extcall.scamd5(PWD,.encpwd,.outlen,opt,.rc)
	;
	I rc'=32 S ENC="" Q 1
	S ENC=encpwd
	Q 0
	;
	;----------------------------------------------------------------------
AUT(KEY,ENC,AUT)	;Public;Authenticate password
	;----------------------------------------------------------------------
	;
	; KEYWORDS: Security
	;
	; ARGUMENTS:
	;     . KEY	Sign-on key			/TYP=T/REQ/LEN=128
	;     . ENC	Encrypted user password		/TYP=T/REQ/LEN=128
	;     . AUT	Authentication key		/TYP=T
	;
	; RETURNS:
	;     . $$	Condition value			/TYP=L
	;		0 = Success
	;		1 = Encryption Error
	;
	; EXAMPLE:
	;     S X=$$AUT^%ENCRYPT(ENC,KEY,.AUT)
	;----------------------------------------------------------------------
	;
	N I,LEN,opt,rc
	;
	S LEN=128,opt="",rc=0
	S AUT=$G(AUT)
        F I=1:1:128 S AUT=AUT_" "
        D &extcall.scamd5(KEY_ENC,.AUT,.LEN,opt,.rc)
	I rc'=32 Q 1
	Q 0
	;
	;----------------------------------------------------------------------
RSAENC(STR,CONV,KEY,CFLAG)	 ; RSA ENCRYPT/DECRYPT Utility - UNIX platform 
	;-----------------------------------------------------------------------
	; DESC: This routine will perform the RSA digital envelope encryption/
	;	decryption algorithm.
	;
	; ARGUMENTS:
	;
	;	. STR	String to be encrypted/decrypted	/TYP=T/REQ
	;	. CONV	Operation           			/TYP=N/REQ
	;		0 - ENCRYPT
	;		1 - DECRYPT
	;	. KEY   Ascii encoded public/private key string	/TYP=T/REQ
	;	. CFLAG	Target machine component flag		/TYP=T/REQ
	;		0 - Microsoft Crypto API
	;		1 - RSA Crypto API
	;
	; RETURNS:
	;
	;	. $$	Translated String			/TYP=T
	;       
	;-----------------------------------------------------------------------
	;
	N OUT,RC
	S OUT=$J("",$L(STR)+512)
	S RC=0
	I CONV=0 d &security.rsaenc(.STR,.OUT,.KEY,CFLAG,.RC)
	I CONV=1 d &security.rsadec(.OUT,.STR,.KEY,CFLAG,.RC)
	I RC=0 Q ""
	Q OUT
	;
	;----------------------------------------------------------------------
KEYPAIR(STR,PUBKEY,PRIKEY)	; RSA Public/Private Key Generation Utility
	;-----------------------------------------------------------------------
	; DESC: This routine will generate an ASCII encoded RSA public/private 
	;	key pair.
	;
	; ARGUMENTS:
	;
	;	. STR		A pass phrase			/TYP=T/REQ
	;	. PUBKEY	Public key string		/TYP=T/REQ
	;	. PRIKEY	Private key string		/TYP=T/REQ
	;
	; RETURNS:
	;
	;	. $$	Null or error message			/TYP=T
	;       
	;-----------------------------------------------------------------------
	;
	N OUT1,OUT2,RC
	S OUT1=$J("",512)
	S OUT2=$J("",1024)
	S RC=0
	D &security.rsakey(.STR,.OUT1,.OUT2,.RC)
	I RC=0 Q "Error with RSA key generation"
	S PUBKEY=OUT1,PRIKEY=OUT2
	Q ""
	;
	;----------------------------------------------------------------------
KEYXCHG(STR,PUBKEY,OPCODE,CFLAG)	; RSA Public Key Exchange Utility
	;-----------------------------------------------------------------------
	; DESC: This routine will import/export a public key.
	;
	; ARGUMENTS:
	;
	;	. STR		A file name			/TYP=T/REQ
	;	. PUBKEY	ASCII encoded public key string	/TYP=T/REQ
	;	. OPCODE	Operation to perform		/TYP=T/REQ
	;			"import" - import the key from file
	;			"export" - export the key to file
	;	. CFLAG		Target machine component flag	/TYP=N/REQ
	;			0 - MS Crypto API
	;			1 - RSA Crypto API
	;
	; RETURNS:
	;
	;	. $$	MUMPS_SUCCESS (1) or MUMPS_FAILURE (0)	/TYP=N
	;       
	;-----------------------------------------------------------------------
	;
	N OUT,RC
	S OUT=$J("",512)
	S RC=0
	I OPCODE="import" D &security.rsaimp(.STR,.OUT,CFLAG,.RC)
	I OPCODE="export" D &security.rsaexp(.STR,.PUBKEY,CFLAG,.RC)
	I OPCODE="import",RC=1 S PUBKEY=OUT
	Q RC
	;
	;----------------------------------------------------------------------
ASCENC(STR,OPCODE)	; RSA ASCII Encode/Decode Utility
	;-----------------------------------------------------------------------
	; DESC: This routine performs the RSA ASCII encoding/decoding alg.
	;
	; ARGUMENTS:
	;
	;	. STR		Input string			/TYP=T/REQ
	;	. OPCODE	Operation to perform		/TYP=T/REQ
	;			"encode" - encode the input string
	;			"decode" - decode the input string
	;
	; RETURNS:
	;
	;	. $$	The translated string			/TYP=T
	;       
	;-----------------------------------------------------------------------
	;
	N OUT,RC
	S OUT=$J("",$L(STR)*2)
	S RC=0
	I OPCODE="encode" D &security.ascenc(.OUT,.STR,.RC)
	I OPCODE="decode" D &security.ascdec(.STR,.OUT,.RC)
	I RC=0 Q ""
	Q OUT
	;
	;----------------------------------------------------------------------
ENCRYPT(CALG,DATA,KEY)
	;----------------------------------------------------------------------
	; DESC: This function will act as a "master" encryption entry point.
	; Based on the input crypto algorithm, it will direct the call to the
	; appropriate function in %ENCRYPT.
	;
	; ARGUMENTS:
	;
	;	. CALG	Crypto algorithm 			/TYP=T/REQ
	;		Supported cryptographic algorithms:
	;		"RSA"	RSA digital envelope triple des cbc cipher for 
	;			UNIX to UNIX
	;		"RSAMS"	RSA digital envelope triple des cbc cipher for 
	;			UNIX to Windows
	;		"RSABF"	RSA digital envelope blowfish cipher 
	;		"BF"	Plain blowfish encryption
	;		"BFHEX"	Plain blowfish encryption + hex encoding the
	;			the encrypted string
	;	. DATA	String to be encrypted  		/TYP=T/REQ
	;	. KEY   Public/Private/Secret key string	/TYP=T/REQ
	;
	; RETURNS:
	;
	;	. $$	Encrypted string			/TYP=T
	;		NULL if error or unsupported crypto algorithm.
	;       
	;----------------------------------------------------------------------
	;
	I CALG="RSA" Q $$RSAENC(DATA,0,KEY,1)
	I CALG="RSAMS" Q $$RSAENC(DATA,0,KEY,0)
	I CALG="RSABF" Q $$RSAENC(DATA,0,KEY,2)
	I CALG="BF" Q $$BFENC(DATA,KEY)
	I CALG="BFHEX" Q $$BFENCHEX(DATA,KEY)
	;
	; Other crypto algorithms are not supported at this time
	;
	Q ""
	;
	;----------------------------------------------------------------------
DECRYPT(CALG,DATA,KEY)
	;----------------------------------------------------------------------
	; DESC: This function will act as a "master" decryption entry point.
	; Based on the input crypto algorithm, it will direct the call to the
	; appropriate function in %ENCRYPT.
	;
	; ARGUMENTS:
	;
	;	. CALG	Crypto algorithm 			/TYP=T/REQ
	;		Supported cryptographic algorithms:
	;		"RSA"	RSA digital envelope triple des cbc cipher for 
	;			UNIX to UNIX
	;		"RSAMS"	RSA digital envelope triple des cbc cipher for 
	;			UNIX to Windows
	;		"RSABF"	RSA digital envelope blowfish cipher 
	;		"BF"	Plain blowfish decryption
	;		"BFHEX"	Hex decoding + Plain blowfish decryption 
	;	. DATA 	String to be decrypted  		/TYP=T/REQ
	;	. KEY   Public/Private/Secret key string	/TYP=T/REQ
	;
	; RETURNS:
	;
	;	. $$	Decrypted string			/TYP=T
	;		NULL if error or unsupported crypto algorithm.
	;       
	;----------------------------------------------------------------------
	;
	I CALG="RSA" Q $$RSAENC(DATA,1,KEY,1)
	I CALG="RSAMS" Q $$RSAENC(DATA,1,KEY,0)
	I CALG="RSABF" Q $$RSAENC(DATA,1,KEY,2)
	I CALG="BF" Q $$BFDEC(DATA,KEY)
	I CALG="BFHEX" Q $$BFDECHEX(DATA,KEY)
	;
	; Other crypto algorithms are not supported at this time
	;
	Q ""
	;
	;----------------------------------------------------------------------
BFKEY()	;	;Public;Generate Secret Key for blowfish
	;----------------------------------------------------------------------
	;
	; KEYWORDS: Security
	;
	; ARGUMENTS:
	; RETURNS:
	;     . $$	Secret key			/TYP=T
	;
	; EXAMPLE:
	;     S X=$$BFKEY^%ENCRYPT()
	;----------------------------------------------------------------------
	;
	N KEY,RC
	;
	S KEY=$J("",57),RC=0
	D &security.blfkey(.KEY,.RC)
	Q KEY
	;
	;----------------------------------------------------------------------
BFKEYHEX()	;Public;Generate Secret Key for blowfish and encrypt it to hex
	;----------------------------------------------------------------------
	;
	; KEYWORDS: Security
	;
	; ARGUMENTS:
	; RETURNS:
	;     . $$	Secret key in hex	      /TYP=T
	;
	; EXAMPLE:
	;     S X=$$BFKEYHEX^%ENCRYPT()
	;----------------------------------------------------------------------
	;
	N ORIKEY,HEXKEY
	;
	S ORIKEY=$$BFKEY()
	S HEXKEY=$$TOHEX(ORIKEY)
	Q HEXKEY
	;
	;----------------------------------------------------------------------
TOHEX(STR)	;Public;Encode a string into its hex representation 
	;----------------------------------------------------------------------
	;
	; KEYWORDS: Security
	;
	; ARGUMENTS:
	;	. STR	String to be encrypted to hex  		/TYP=T/REQ
	; RETURNS:
	; 	. $$	Hex string representation		/TYP=T
	;
	; EXAMPLE:
	;     S X=$$TOHEX^%ENCRYPT(STR)
	;----------------------------------------------------------------------
	;
	N I,HEX
	S HEX=""
	F I=1:1:$L(STR)  S HEX=HEX_$$FUNC^%DH($A($E(STR,I)),2)
	Q HEX
	;
	;----------------------------------------------------------------------
FROMHEX(HEX)	;Public;Decode a hex-encoded string  
	;----------------------------------------------------------------------
	;
	; KEYWORDS: Security
	;
	; ARGUMENTS:
	;	. HEX	String to be decrypted from hex 	/TYP=T/REQ
	; RETURNS:
	; 	. $$	Original string 			/TYP=T
	;
	; EXAMPLE:
	;     S X=$$FROMHEX^%ENCRYPT(HEX)
	;----------------------------------------------------------------------
	;
	N I,STR
	S STR=""
	F I=1:2:$L(HEX)  S STR=STR_$C($$FUNC^%HD($E(HEX,I))*16+$$FUNC^%HD($E(HEX,I+1)))
	Q STR
	;
	;----------------------------------------------------------------------
BFENC(DATA,KEY)	;Public;Encode a string with plain blowfish
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;
	;	. DATA 	String to be encrypted  		/TYP=T/REQ
	;	. KEY   Secret key string			/TYP=T/REQ
	;
	; RETURNS:
	;
	;	. $$	Encrypted string			/TYP=T
	;
	; EXAMPLE:
	;	S X=$$BFENC^%ENCRYPT(DATA,KEY)
	;       
	;----------------------------------------------------------------------
	;
	N CIPHER,RC
	;
	S CIPHER=$J("",$L(DATA)+8),RC=0
	D &security.blfenc(.DATA,.CIPHER,.KEY,.RC) 
	Q CIPHER
	;
	;----------------------------------------------------------------------
BFENCHEX(DATA,KEY)	;Public;Encode a string with plain blowfish then hex it
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;
	;	. DATA 	String to be encrypted  		/TYP=T/REQ
	;	. KEY   Secret key string			/TYP=T/REQ
	;
	; RETURNS:
	;
	;	. $$	Hex-ed Encrypted string			/TYP=T
	;       
	; EXAMPLE:
	;	S X=$$BFENCHEX^%ENCRYPT(DATA,KEY)
	;       
	;----------------------------------------------------------------------
	;
	N BINCIFR,HEXCIFR
	;
	S BINCIFR=$$BFENC(DATA,KEY)
	S HEXCIFR=$$TOHEX(BINCIFR)
	Q HEXCIFR
	;
	;----------------------------------------------------------------------
BFDEC(DATA,KEY)		;Public;Decode a string with plain blowfish
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;
	;	. DATA 	Encrypted string			/TYP=T/REQ
	;	. KEY   Secret key string			/TYP=T/REQ
	;
	; RETURNS:
	;
	;	. $$	Decrypted string			/TYP=T
	;       
	; EXAMPLE:
	;	S X=$$BFDEC^%ENCRYPT(DATA,KEY)
	;       
	;----------------------------------------------------------------------
	;
	N ORI,RC
	;
	S ORI=$J("",$L(DATA)),RC=0
	D &security.blfdec(.ORI,.DATA,.KEY,.RC)
	Q ORI
	;
	;----------------------------------------------------------------------
BFDECHEX(DATA,KEY)	;Public;Decode a hex-ed string with plain blowfish
	;----------------------------------------------------------------------
	; ARGUMENTS:
	;
	;	. DATA 	Hex-ed Encrypted string			/TYP=T/REQ
	;	. KEY   Secret key string			/TYP=T/REQ
	;
	; RETURNS:
	;
	;	. $$	Decrypted string			/TYP=T
	;       
	; EXAMPLE:
	;	S X=$$BFDECHEX^%ENCRYPT(DATA,KEY)
	;       
	;----------------------------------------------------------------------
	;
	N BINCIFR,MYORI
	;
	S BINCIFR=$$FROMHEX(DATA)
	S MYORI=$$BFDEC(BINCIFR,KEY)
	Q MYORI
	;
