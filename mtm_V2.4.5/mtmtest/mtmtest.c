#include <stdio.h>
#include <string.h>
#include <scatype.h>

extern char *optarg;
extern int optind;

static char userId[80];
static char password[80];
static char ipAddress[80];
static char token[80] = "u:p:i:";

/* connection related */
static char profileToken[80];
static int continueFlag = TRUE;

/* SQL related */
static int  customFlag;
static int  timeout = 6000;
static int  success_count = 0;
static int  error_count = 0;
static int  eos_count = 0;
static int  timeout_count = 0;
static int  other_count = 0;
static int  null_count = 0;
static char qualifier[80];
static char retry[80];
static unsigned char requestBuffer[1200];
static unsigned char replyBuffer[40000];
static char *(sampleSQL[]) = {
"SELECT ACN.ACN,ACN.CID,ACN.GRP,ACN.CLS FROM ACN,RELCIF",
"SELECT COL.COLL,COL.MAKE,COL.MODEL,COL.ID,COL.CLYR,COL.CLTYP,COL.TITLE,"\
"COL.TNUM,COL.OWNER,COL.COLVAL,COL.PRICE,COL.REVFRE FROM COL",
"SELECT DEP.CHKEURO,DEP.CHKS,DEP.STAT FROM DEP",
"SELECT ACN FROM RELCIF",
"SELECT DI FROM CIFH",
"SELECT DEP.IRN,DEP.ACR,DEP.IYTD,DEP.CID,DEP.ODT FROM DEP", 
"SELECT CHECK.CID,DEP.LNM,CHECK.CHKS,CHECK.CHKNUM,CHECK.ISSD,STBLCHKSTS.DESC "\
"FROM CHECK,DEP,STBLCHKSTS",
"SELECT NOTESCIF.ACN,NOTESCIF.NUM,NOTESCIF.DESC,NOTESCIF.EXP,NOTESCIF.LUPD,"\
"NOTESCIF.UID FROM NOTESCIF",
"SELECT ENTF FROM LN",
"SELECT TFSTRANS FROM CIF", 
"SELECT ACN.LNM,ACN.CLS FROM ACN",
"SELECT CID,TYPE,CUSHA,CUSHF,DIST1FRE,DFP,APCND,ANOFF,APCLD FROM LN", 
"SELECT CIFSIG.COUNTER FROM CIFSIG",
"SELECT DEP.TYPE,DEP.BOO,DEP.TITLE1,DEP.TITLE2,DEP.TITLE3,DEP.TITLE4,"\
"DEP.BAL,DEP.ODT,DEP.BALAVL,DEP.DTC,DEP.BALCOL,DEP.TLD FROM DEP",
"SELECT RELCIF.ACN,ACN.GRP,ACN.TYPE,ACN.ACNRELC,RELCIF.ROLE,ACN.TITLE1,"\
"ACN.TITLE2,ACN.TITLE3,ACN.TITLE4,ACN.LNM,CIF.NAM,CIF.LNM FROM ACN,CIF",
"SELECT RPASEQ,ACN FROM DEP",
"SELECT DBTBL13.PID,DBTBL13.DESC,DBTBL13.DATE,DBTBL13.UID FROM DBTBL13",
"SELECT DEPODP.ODACN,DEPODP.PRI,DEPODP.CID,DEPODP.TYPE FROM DEPODP,ACN",
"SELECT KEY,DESC FROM STBLNIMIN",
"SELECT DISTINCT ACN.CID,ACN.CLS,ACN.GRP,ACN.TYPE,ACN.CRCD,CIF.XNAME,"\
"ACN.ACCTNAME FROM ACN,CIF,RELCIF",
"SELECT CIF.NAM,CIF.ACN FROM CIF",
"SELECT PAYHIST.TSEQ,PAYHIST.EFD,PAYHIST.CDT,PAYHIST.UID,PAYHIST.BRCD,"\
"EFTPAY.AMTTYP,EFTPAY.MET,EFTPAY.SPECIFIC,EFTPAY.RECINST FROM PAYHIST,"\
"EFTPAY",
"SELECT DEP.CID,DEP.TYPE,DEP.TRM,DEP.MDT,DEP.PMEDAT,DEP.MLD,DEP.NTR,"\
"DEP.DLR,DEP.IRLM,DEP.MDTEXT,DEP.RENCD,DEP.RACN,DEP.INTAVLR FROM DEP",
"SELECT CIFPIC.COUNTER FROM CIFPIC",
"SELECT STAT FROM LN",
"SELECT DISTINCT ACN.CID,ACN.CLS,ACN.GRP,ACN.TYPE,ACN.CRCD,CIF.XNAME,"\
"ACN.ACCTNAME FROM ACN,CIF,RELCIF",
"SELECT ACR,BAL,CNTDR,CRLMT,DIST1ND,DPMT,DSEQ,LBDD,LIMIT,NPC,OSEQ,PCM,"\
"PPA,SCHSEQ,UNAPF FROM LN", 
"SELECT CIFTYP.TYPE,CIFTYP.DES,CIFTYP.CRCD FROM CIFTYP",
"SELECT TYPE FROM CIF",
"SELECT CRCD,STAT,CLS FROM DEP",
"SELECT DBTBL1.FID,DBTBL1.DES,DBTBL1.GLOBAL,DBTBL1.LTD,DBTBL1.USER "\
"FROM DBTBL1",
"SELECT CRCD,CCODE FROM DEP", 
"SELECT TYPE,DES FROM CIFTYP",
"SELECT INTO CIF (ACN,BOO,BPH,CCODE,CLS,CRCD,DEP,DOB,EMAIL,GRP,HPH,"\
"LNM,NAM,OWN,PAD1,PAD2,PCITY,PCNTRY,PERS,PID,PSTATE,PZIP,TAXID) "\
"FROM CIF",
"SELECT DEP.CID,DEP.TYPE,DEP.REGCC,DEP.REGCCEXC,DEP.REGCCEXP,"\
"DEP.ITHLDDAYS,DEP.FLTTBL,DEP.FLTP1,DEP.FLTD1,DEP.FLTP2,DEP.FLTD2 "\
"FROM DEP",
"SELECT ACN FROM CIF", 
"SELECT EFD.EFDTCMT1,EFD.EFDATE,EFD.BUFF,EFD.SEQ,EFD.CURDATE,"\
"EFD.TABLE,EFD.AKEY,EFD.TLO,EFD.UID,EFD.TJD FROM EFD",
"SELECT CIF.NAM,CIF.ACN,CIF.CRCD FROM CIF",
"SELECT ACN,CON,FAXNUM,NAM,NAM,NAM,PCITY,PCNTRY,PCNTRY,PCNTRY,"\
"SIC,SWIFTCON,TAXID,TELEX,TFSCIFID,TFSCIFID,TFSCIFID,TFSHOEXT,"\
"TFSHOEXT FROM CIF",
"SELECT ACN FROM CIF", 
"SELECT LNCOL.CID,LNCOL.COLL,LNCOL.DESC,LN.GRP FROM LNCOL,LN", 
"SELECT FEEOPT,SVCFEECID,TRB,GLSC,CC FROM DEP",
"SELECT PBKBAL FROM DEP",
"SELECT CID FROM RELCIF",
"SELECT EFTPAY.CID,EFTPAY.SEQ,EFTPAY.PROCDT,EFTPAY.EFD,EFTPAY.STATUS,"\
"EFTPAY.RELREFNO,EFTPAY.FEETYPE,EFTPAY.FEECONV,EFTPAY.CCODE FROM EFTPAY",
"SELECT CID,BAL FROM DEP",
"SELECT RELCIF.ACN FROM RELCIF,DEP,DTYPE", 
"SELECT CIFH.ACN,CIF.NAM,CIFH.SEQ,CIFH.EFD,CIFH.UID,CIFH.DI,CIFH.OLDV,"\
"CIFH.NEWV,CIFH.TJD,CIFH.DIDSC,CIFH.EFDTCMT1 FROM CIFH,CIF",
"SELECT ODLIM,ODEXP FROM DEP",
"SELECT CIF.CON,CIF.PP1,CIF.FYE,CIF.CRE,CIF.TA,CIF.NW,CIF.AS,CIF.NE,"\
"CIF.LOCALE,CIF.ACN,CIF.SIC,CIF.W8DATE,CIF.LFU,CIF.GOVT FROM CIF",
"SELECT COLCD FROM LN",
"SELECT PBI FROM DEP",
"SELECT DBTBL13.PID,DBTBL13.DESC,DBTBL13.DATE,DBTBL13.UID FROM DBTBL13",
"SELECT ACN.CID,ACN.CLS,ACN.GRP,ACN.TYPE,ACN.TITLE1,ACN.TITLE2,ACN.TITLE3,"\
"ACN.TITLE4 FROM ACN,CIF,RELCIF",
"SELECT TRTYPE.CREMFRE,RAMT.REMAMT,RAMT.REMDT,LNTRS.TRDES FROM DEP,TRTYPE,"\
"RAMT,LNTRS",
"SELECT ACN,ARUF,ATN,AUO,BAL,BOO,CCODE,CNTDR,COA,CRCD,DIST1ND,DIST1FRE,"\
"DSEQ,ENTF,LIMIT,LNM,NPC,ODD,PPA,POPT,REC,SCHSEQ,STAT,TYPE FROM CIF",
"SELECT ACN.CID FROM ACN,RELCIF,CIF",
"SELECT PLAN,DESC FROM FEEPLN",
"SELECT NEGACRPO,DESC FROM STBLNEGACRPO", 
"SELECT TREASNAM,ACN FROM CIF",
"SELECT KEY,DSC FROM STBLLNDELRM", 
"SELECT CHKEURO FROM DEP",
"SELECT LNDRBY,DESC FROM STBLLNDELRBY",
"SELECT PHLD.CID,DEP.LNM,PHLD.PHC,PHLD.TCMT,PHLD.EXPDT,PHLD.STDT,"\
"PHLD.THLDAMT,PHLD.AREF,UTBLPHC.DESC,PHLD.%UID FROM DEP,PHLD,UTBLPH",
"SELECT NOTES FROM NOTESCIF",
"SELECT DEP.ACN FROM DEP",
"SELECT BALAVL,TOTBALAVL,TOTCREAVL FROM DEP",
"SELECT ACN,BOO,BOO,CON,DAO,FAXNUM,MAD1,MAD2,MAD3,MAD4,MCSZ,NAM,PCNTRY,"\
"PCNTRY,SIC,TFSCIFID,TFSCIFID FROM CIF",
"SELECT DTYPE.SWPF FROM DEP,DTYPE",
"SELECT TYPE,CCODE,CONVDT,STAT,CRCD,ARS FROM DEP",
"SELECT CID,BAL,STAT FROM DEP",
"SELECT LNCOL.COLL,LNCOL.DESC,COL.SCOLCD FROM LNCOL,COL",
"SELECT POPT FROM DEP",
"SELECT DEP.CID,DEP.CLS,DEP.GRP,DEP.TYPE,DEP.CRCD,DEP.ACN,DEP.BAL,"\
"STBLSTAT.DESC,CIF.ATN,DEP.BALAVL,DEP.TITLE1,DEP.TITLE2,DEP.TITLE3",
"SELECT * FROM CRCD",
"SELECT BAL FROM DEP",
"SELECT COL.COLL,COL.COLVAL,COL.REVFRE,COL.AVRSL,COL.CRCD,COL.COLPCT,"\
"COL.SCOLCD,COL.COLDES,COL.COLDES2,LNCOL.CID,LNCOL.COLL FROM COL,LNCOL",
"SELECT AVLBAL FROM LN",
"SELECT IRCB,DESC FROM UTBLLNNFG",
"SELECT BAL FROM LN",
"SELECT ANLSYS,SCND FROM DEP", 
"SELECT DEP101.CID,DEP101.ICID,DEP101.DPRIO,DEP101.CPRIO FROM DEP101",
"SELECT BAL,CLAMO FROM DEP",
"SELECT BALCOL FROM DEP,CIF",
"SELECT EFD.EFDTCMT1,EFD.EFDATE,EFD.BUFF,EFD.SEQ,EFD.TABLE,EFD.AKEY,"\
"EFD.TLO,EFD.UID,EFD.CURDATE,EFD.CID,EFD.TJD FROM EFD",
"SELECT ARUF,BAL,COA,REC,UDBAL FROM LN",
"SELECT IRA FROM DEP",
"SELECT ACN.CID,ACN.GRP,ACN.TYPE FROM DEP,RELCIF,ACN",
"SELECT MAXDRCT,CNTDR,CRLMT,ODD FROM LN",
"SELECT LNCOL.CID,COL.COLL,LNCOL.COLL,LNCOL.DESC,COL.AVRSL,COL.SCOLCD,"\
"COL.COLSEQ FROM LNCOL,COL",
"SELECT ACN.CLS,ACN.GRP,ACN.TYPE,RELCIF.ACN,RELCIF.CID,ACN.BAL,ACN.CRCD,"\
"ACN.TITLE1,ACN.TITLE2,ACN.TITLE3,ACN.TITLE4,UTBLVREL.DESC FROM ACN",
"SELECT DBTBL1.FID,DBTBL1.DES,DBTBL1.GLOBAL,DBTBL1.LTD,DBTBL1.USER "\
"FROM DBTBL1",
"SELECT NAM,MAD1,MAD2,MSTATE,MCITY,MZIP,MCNTRY FROM CIF",
"SELECT PAT.SRC,PAT.ACN,PAT.BATCH,PAT.SEQ,PAT.TRNCD,PAT.CID,PAT.AMOUNT,"\
"PAT.CKNAM1,ACN.CLS,ACN.GRP,ACN.TRB,TRN.DC,TRN.PCF,DEP.IRA FROM PAT",
"SELECT ACN,LNM FROM CIF",
"SELECT ACN,NAM FROM CIF",
"SELECT RELCIF.ACN,ACN.TYPE FROM RELCIF,DEP,ACN", 
"SELECT NIPO,DESC FROM STBLNIPO",
"SELECT MAXDRCT,CRLMT FROM LN",
"SELECT TIKLCIF.ACN,TIKLCIF.TKS,TIKLCIF.RRC,TIKLCIF.FT1 FROM TIKLCIF", 
"SELECT NOTICE,DESC FROM STBLNOTICE",
"SELECT ACN,NAM FROM CIF",
"SELECT INTO CIF (ACN,CLS,CRCD,GRP,PERS,TYPE) VALUES (:ZSQL1,"\
":ZSQL2,:ZSQL3,:ZSQL4,:ZSQL5,:ZSQL6)",
"SELECT NBDC,CALDES FROM UTBLNBD",
"SELECT BAL,CRCD FROM DEP",
"SELECT BALAVL,CRCD,TYPE,LNM FROM DEP", 
"SELECT MON FROM UTBLNBD",
"SELECT BALAVL FROM DEP",
"SELECT SAT FROM UTBLNBD",
"SELECT IOPT FROM DEP",
"SELECT TUE FROM UTBLNBD", 
"SELECT * FROM CRCD",
"SELECT EFTPAY.CID,EFTPAY.SEQ,EFTPAY.RECINST,EFTPAY.AMOUNT,"\
"EFTPAY.CRCD,EFTPAY.VARIABLE,EFTPAY.CONSTANT,EFTPAY.SPECIFIC,"\
"EFTPAY.EFD FROM EFTPAY",
"SELECT ACN FROM CIF",
"SELECT LCHG FROM LN",
"SELECT EFTDEB,EFTREQ FROM LN", 
"SELECT * FROM CRCD",
"SELECT IRA FROM DEP",
"SELECT ACN,NAM,XNAME,TAXID,LNM,PREF,MCITY,MSTATE,MZIP,MCNTRY,MAD1,MAD2,"\
"ACN,NAM,XNAME,TAXID,LNM,PREF,MCITY,MSTATE,MZIP,MCNTRY,MAD1,MAD2,"\
"MAD3,MAD4,MLOC,PCITY,PSTATE,PZIP,PCNTRY,PAD1,PAD2,PAD3,PAD4,PLOC,DOB,"\
"SEX,MAR,DEP,OCC,INC,OWN,LOCALE,CIFOFF,SHHLD,EDUC,DOD,SPOUSE,SIC,FYE,"\
"TA,NW,AS,CRE,NE,CON,PP1,HPH,BPH,BPHEXT,TELEX,BOO,CC,CCODE,MF,RFLGC,"\
"BWF,TAXEXM,INTWR,W8REQ,W8DATE,W9STAT,INTWCALC,NR,DAO,LFU,FMLD,ATM,"\
"ACN,NAM,XNAME,TAXID,LNM,PREF,MCITY,MSTATE,MZIP,MCNTRY,MAD1,MAD2,"\
"MAD3,MAD4,MLOC,PCITY,PSTATE,PZIP,PCNTRY,PAD1,PAD2,PAD3,PAD4,PLOC,DOB,"\
"SDB,SBLI,CEN,PID,CONVCIF,RESCD,EMPCD,NATION,LEGAL,NOPURGE,AUD1,AUD1CF,"\
"CREDLINE,FAXNUM,INTERBANK,ISDADT,STATUSDT,SWIFTCON,SWIFTSAK,NRCNTRY,"\
"AUD1ND,AUD1LD,AUD2,AUD2CF,AUD2ND,AUD2LD,ATN,TYPE,CLS,GRP,APPS,PERS,"\
"CRCD,SECGRP,DARCOVR,SWIFTADD,TREASNAM,CUSTGRP,LOCN,DETNUM,ACTIVE,AGREEMENT,"\
"MAD3,MAD4,MLOC,PCITY,PSTATE,PZIP,PCNTRY,PAD1,PAD2,PAD3,PAD4,PLOC,DOB,"\
"CREDLINE,FAXNUM,INTERBANK,ISDADT,STATUSDT,SWIFTCON,SWIFTSAK,NRCNTRY "\
"FROM CIF",
"SELECT ACN,DOB FROM CIF WHERE ACN > 1200000000",
"SELECT acn,dob FROM CIF",
"SELECT * FROM CIF WHERE ACN > 100000000",
"SELECT * FROM CIF WHERE ABCD=13",
"SELECT * FROM CRCD"
};

void getarg();
void parse(int argc,char *argv[]);
void processOption();
void display_scr21();
void display_scr31();
void singleSQL();
void multipleSQL();
void customSQL();
void clearProfileToken();
void doNMSP(char *);
int display_scr1();
int getUserReponse();
int getProfileToken();
int doClientConnect();
int doClientExhange(STR_DESCRIPTOR *, STR_DESCRIPTOR *);
int doClientDisconnect();
void doFormatRequest(STR_DESCRIPTOR *, char *);
void doParseReply(STR_DESCRIPTOR *);

void main(int argc, char *argv[])
{
   int option;
   /* user's input */ 
   if (argc < 4)
   {
      /* no argument was passed in, go get it */
      getarg(argc,argv);
   }
   else
   {
      /* parse the passed in argument */
      parse(argc,argv);
   }
   /* verification purpose */
   printf("\nuserId is %s\n",userId);
   printf("password is %s\n",password);
   printf("ipAddress is %s\n",ipAddress);

   /* logging */
   /* ProfileLogging("/tmp/lyh.log",400000,1); */

   /* loop until user decides to break */
   while (continueFlag)
   {
       option = display_scr1();
       processOption(option);
   }
}

/* side effect: modifies userId, password, ipAddress */
void getarg()
{
   printf("\nPlease enter PROFILE user id [1] : ");
   gets(userId);
   if (strlen(userId) == 0)
      sprintf(userId,"%s","1");
   printf("\nPlease enter password [xxx] : ");
   gets(password);
   if (strlen(password) == 0)
      sprintf(password,"%s","xxx");
   printf("\nPlease enter IP address [140.140.1.203/18015] : ");
   gets(ipAddress);
   if (strlen(ipAddress) == 0)
      sprintf(ipAddress,"%s","140.140.1.203/18015");
   return;
}

/* side effect: modifies userId, password, ipAddress */
void parse(int argc, char *argv[])
{
   int option;
   while ((option = getopt(argc,argv,token)) != EOF)
   {
      switch (option)
      {
        case 'u':
                  sprintf(userId,"%s",optarg);
                  break;
        case 'p':
                  sprintf(password,"%s",optarg);
                  break;
        case 'i':
                  sprintf(ipAddress,"%s",optarg);
                  break;
      }
   }
   return;
}

int display_scr1()
{
   int option = 99;
   printf("\n1) ProfileConnect\n");
   printf("2) SQL\n");
   printf("3) NMSP99\n");
   printf("4) ProfileDisconnect\n");
   printf("5) Exit\n");
   while ((option < 1) || (option > 5))
   {
     option = getUserResponse();
   }
   return (option);
}

int getUserResponse()
{
   char userResponse[80];
   int option;
   printf("\nPlease enter a number to indicate your choice: ");
   gets(userResponse);
   option = atoi(userResponse);
   return (option);
}

/* side effect: modifies replyBuffer, profileToken, continueFlag */
void processOption(option)
{
   switch (option)
   {
      case 1:
		clearProfileToken();
                getProfileToken();
		break;
      case 2:
                display_scr21();
		break;
      case 3:
		display_scr31();
		break;
      case 4:
		clearProfileToken();
		break;
      case 5:
		clearProfileToken();
		continueFlag = FALSE;
		printf("Success count: %d\n",success_count);
		printf("Error count:   %d\n",error_count);
		printf("Timeout count: %d\n",timeout_count);
		printf("EOS count:     %d\n",eos_count);
		printf("Other error:   %d\n",other_count);
		printf("Null count:    %d\n",null_count);
		break;
   }
   return;
}

void clearProfileToken()
{
   if (strlen(profileToken) != 0)
   {
      memset(replyBuffer,0,sizeof(replyBuffer));
      ProfileDisconnect(profileToken,replyBuffer);
      memset(profileToken,0,sizeof(profileToken));
   }
   return;
}

/* side effect: modifies profileToken */
int getProfileToken()
{
   int rval;

   rval = ProfileConnect(userId,password,ipAddress,profileToken,"pts8");
   if (rval != 0)
   {
     /* an error has been recorded */
     printf("Error received during call to ProfileConnect\n");
     printf("Return code: %d\n",rval);
     printf("Return message: %s\n",profileToken);
     memset(profileToken,0,sizeof(profileToken));
   }
   else
   {
     printf("ProfileConnect is ok. Token is %s\n",profileToken);
   }
   return (rval);
}

void display_scr21()
{
   int option = 99;

   printf("1) Single SQL request\n");
   printf("2) Multiple SQLs request\n");
   printf("3) Custom SQL request\n");
   printf("4) Back\n");       

   while ((option < 1) || (option > 4)) 
   {
       option = getUserResponse();
   }

   switch (option)
   {
         case 1:
		singleSQL();
		break;
         case 2:
		multipleSQL();
		break;
         case 3:
		customSQL();
		break;
         case 4:
		return;
   }
   return;
}

/* side effect: modifies requestBuffer, qualifier, customFlag, replyBuffer,
                         profileToken, success_count, error_count, eos_count,
                         timeout_count, other_count
*/
void singleSQL()
{
   int rval,index;
   unsigned char *requestptr,*replyptr;
   requestptr = requestBuffer;
   replyptr = replyBuffer;

   if (strlen(profileToken) == 0)
   {
       if (getProfileToken() != 0)
       {
          printf("Message not sent due to server connection failure\n");
          return;
       }
   }
   printf("profileToken = %s\n",profileToken);

   /* clear retry - because we want to generate new message id each time */
   retry[0] = 0;

   if (!customFlag)
   {
       memset(requestBuffer,0,sizeof(requestBuffer));
       index = random()%124; /* 118;i*/ /* random()%124; */
       printf("index = %d\n",index);
       sprintf(requestBuffer,"%s",sampleSQL[index]);
       memset(qualifier,0,sizeof(qualifier));
       sprintf(qualifier,"ROWS=10/PROTECTION=0/NOOPTIMIZE/NOCACHE");
   }
   else
   {
       customFlag = FALSE;
   }

   printf("Sending SQL statement:\n%s %s\n",requestptr,qualifier);
   memset(replyBuffer,0,sizeof(replyBuffer));
   rval = ProfileSQL(profileToken,requestptr,qualifier,
                     replyptr,retry,timeout);
   switch (rval)
   {
     case 0:
             success_count++;
             break;
     case 1:
             error_count++;
             break;
     case 1500:
             eos_count++;
             break;
     case 4:
             /* MTM??? */
             timeout_count++;
     case 2033:
             /* MQM */
             timeout_count++;
     default:
             other_count++;
   }

   printf("Server Response:\n");
   printf("%s\n",replyBuffer);
   if (strlen(replyBuffer) == 0)
   {
      printf("Reply message is null\n");
      null_count++;
   }
   return;
}

void multipleSQL()
{
   int index,numSQL;
   char numSQLString[80];
   printf("You will run a number of random SQL statements. Some contain\n");
   printf("bad syntax and will fail on purpose.\n");
   printf("How many SQL statements do you want to run? ");
   gets(numSQLString);
   numSQL = atoi(numSQLString);
   if (numSQL == 0)
   {
      return;
   }
   for (index = 1; index <= numSQL; index++)
   {
       printf("Iteration %d :\n",index);
       singleSQL();
   }
   return;
}

/* side effect: modifies qualifer, requestBuffer, customFlag */
void customSQL()
{
   char selectString[80];
   char fromString[80];
   char whereString[80];
   char limitString[80];
   char finalString[512];
   char confirmString[80];
   int  index,confirm;  
   printf("\nPlease enter an SQL inquiry statement as you are prompted...");
   printf("\nSELECT (columns): ");
   gets(selectString);
   printf("\nFROM (tables): ");
   gets(fromString);
   printf("\nWHERE (conditions): ");
   gets(whereString);
   printf("\nLIMIT (number of rows): ");
   gets(limitString);

   if (strlen(selectString) == 0)
   {
      printf("SELECT clause is null. This probably won't work.");
      return;
   }
   if (strlen(fromString) == 0)
   { 
      printf("FROM clause is null. This probably won't work.");
      return;
   }
   if (strlen(whereString) == 0)
   {
         sprintf(finalString,"SELECT %s FROM %s",
                 selectString,fromString,limitString);
   }
   else
   {
         sprintf(finalString,"SELECT %s FROM %s WHERE %s",
                 selectString,fromString,whereString);
   }
   printf("\nVerification:\n");
   printf("%s",finalString);
   if (strlen(limitString) != 0)
   {
      printf(" LIMIT TO %s ROWS",limitString);
   }
   printf("\nPlease enter the number of times to run the above SQL: ");
   gets(confirmString);
   confirm = atoi(confirmString);
   for (index = 1; index <= confirm; index++)
   {
      printf("Iteration %d :\n",index);
      memset(requestBuffer,0,sizeof(requestBuffer));
      memset(qualifier,0,sizeof(qualifier));
      sprintf(requestBuffer,"%s",finalString);
      if (strlen(limitString) != 0)
      {
         sprintf(qualifier,"ROWS=%s/PROTECTION=0/NOOPTIMIZE/NOCACHE",limitString);
      }
      customFlag = TRUE; 
      singleSQL();
   }
   return;
}

void display_scr31()
{

   char lineTag[80];

   printf("\nPlease enter a line tag: ");
   gets(lineTag);
   if (strlen(lineTag) == 0)
   {
      printf("\nLine tag is null. This won't work\n");
      return;
   }
   /* do we need to get parameters? */
   doNMSP(lineTag);   
}

void doNMSP(char *lineTag)
{
   char requestMsg[512], replyMsg[512];
   STR_DESCRIPTOR request, reply;
   int rc;

   memset(requestMsg, 0, sizeof(requestMsg));
   memset(replyMsg, 0, sizeof(replyMsg));
   request.str = requestMsg;
   request.length = sizeof(requestMsg);
   reply.str = replyMsg;
   reply.length = sizeof(replyMsg);

   doFormatRequest(&request, lineTag);

   do
   {
       rc = doClientConnect();
       if (rc == -1)
       {
          printf("\nFailed to connect\n");
          break;
       }

       rc = doClientExchange(&request,&reply);
       if (rc == -1)
       {
	  reply.str[reply.length]='\0';
	  reply.str[reply.length+1]='\0';
	  printf("\nFailed to exchange client message\n");
	  printf("Return code: %c\n",reply.str[0]);
	  printf("Return message: %s\n",&reply.str[1]);
       }
       else
	  doParseReply(&reply);

       rc = doClientDisconnect();
       if (rc == -1)
       {
          printf("\nFailed to disconnect\n");
          break;
       }

   } while (0);

   return;
}

int doClientConnect()
{
   int return_code = 0;

   ClConnect(2,ipAddress,&return_code);

   if (return_code != 0)
	return(-1);
   else
        return(0);
}

int doClientExchange(STR_DESCRIPTOR *request, STR_DESCRIPTOR *reply)
{
   int return_code = 0;
   int timeout = 15;

   ClExchmsg(4, request, reply, timeout, &return_code);

   if (return_code != 0)
	return(-1);
   else
        return(0);
}

int doClientDisconnect()
{
   int return_code = 0;

   ClDisconnect(1,&return_code);

   if (return_code != 0)
	return(-1);
   else
        return(0);
}

void doFormatRequest(STR_DESCRIPTOR *request, char *lineTag)
{
   char mtext[64];
   int  tagLength;
   int  tempLength;
 
   tagLength = strlen(lineTag);
   memset(mtext,0,sizeof(mtext));
   sprintf(mtext,"SCA$IBS");			/* server type */
   tempLength = tagLength - 1;
   mtext[tempLength++] = 0x1C;			/* <FS> character */
   /* Record 1 */
   mtext[tempLength++] = 0x09;			/* Length of record 1 */
   mtext[tempLength++] = 0x02;			/* server class 0 */
   mtext[tempLength++] = '0';
   mtext[tempLength++] = 0x01;			/* empty token */
   mtext[tempLength++] = 0x02;			/* fake message id */
   mtext[tempLength++] = '1';
   mtext[tempLength++] = 0x02;			/* SF flag */
   mtext[tempLength++] = '0';
   mtext[tempLength++] = 0x01;			/* empty group id */
   /* Record 2 */
   mtext[tempLength++] = 0xFF & (6+tagLength);	/* Length of message body */
   mtext[tempLength++] = 0x03;			/* Length of service class */
   mtext[tempLength++] = '9';			/* 99 = System services */
   mtext[tempLength++] = '9';
   mtext[tempLength++] = 0xFF & (1+tagLength);	/* Length of line tag */ 
   sprintf(&mtext[tempLength],"%s",lineTag);	/* Line tag */
   tempLength += strlen(lineTag);
   mtext[tempLength++] = 0x01;			/* No params passed in */
   /* Terminator */
   mtext[tempLength++] = 0x00;
   mtext[tempLength++] = 0x00;
   request->length = tempLength;		/* Total length of message */
   memcpy(request->str,mtext,request->length);
   /* hexdmp(request->str, request->length); */
}

void doParseReply(STR_DESCRIPTOR *reply)
{
   char replyCode, ch;
   int i,offset,len;
   char *ptr;

   printf("\nReply received for NMSP99 message:\n");
   
   offset = 0xFF & reply->str[1];

   ptr = &reply->str[offset+1];
   len = reply->length - offset;
   if (len > 0)
   {
      /* dump the reply, one character at a time */
      for (i = 0; i < len; i++)
      {
          ch = ptr[i];
          /* replace unprintable character with space */
          if ((ch < 32) || (ch > 126))
          {
             ch = ' ';
          }
          printf("%c",ch);
      }
      printf("\n");
   }
   else
      printf("Generic error - invalid reply format\n");
}
