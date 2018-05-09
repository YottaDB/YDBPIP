/*
	This program illustrates how to use the library file libsql.a . It sends
	sql select commands to Profile/Anyware .
*/

#include <stdio.h>
#include <stdlib.h>
#include <time.h>

/* THESE ARE THE SQL COMMANDS TO SEND AND THE QUALIFIER */

char *sqlcommand[]={"select * from prodctl",'\0'};
char *sqlcommand1[]={"UPDATE DEP SET ACCTNAME='xyz' where acn =1",'\0'};
char *sqlcommand2[]={"insert into ach (coid,desc) values (1112223334,'UNIX')",'\0'};
char *sqlcommand5[]={"update ach  set desc = 'Test' where coid = 1112223334",'\0'};
char *sqlcommand3[]={"select \t\r\n* from ztest", '\0'};
char *sqlcommand4[]={"execute $$list^sqldd(\"dep\",1)", '\0'};
/*char sqlqual[]="FORMAT=PB4/ROWS=10/ICODE=1";*/
char sqlqual[]="ROWS=10";
char *command;

main (argc, argv)
int  argc;
char **argv;
{
	char token[30];		/*USED TO HOLD THE TOKEN RETURNED BY LIBSQL*/
	char buffer2[40000];	/*USED TO HOLD THE RETURN VALUES*/
	int time_out=60;	/*HOW LONG TO WAIT BEFORE DECLARING A TIMEOUT*/
	char retry[100];	/*USED TO INDICATE IF A RETRY SHOULD BE ATTEMPTED, NORMALLY SET TO 0*/

	int ii, jj, kk, return_value; /*COUNTERS AND RETURN VALUES*/
	struct tm *today; 
	time_t	ltime;

	/*LOG INTO PROFILE USING VALUES ARE
	USERNAME,
	PASSWORD,
	IP ADDRESS AND PORT NUMBER,
	ARRAY TO HOLD TOKEN SENT BY PROFILE,
	CURRENT LOCATION*/
	printf ("\nProfileConnect ");
	return_value = ProfileConnect("1","xxx","140.140.1.215/18326",token,"pts8");
	if (return_value != 0)
	{
		printf ("\nNumeric Value of return code: %d", return_value);
		printf ("\nString  Value of return code: %s\n", token);
		exit (1); /*COULD NOT LOG IN, SO MIGHT AS WELL EXIT*/
	}

	/*SEND THE SAME SET OF COMMANDS SEVERAL TIMES*/
	for (kk=0;kk<2;kk++) {
		printf
		("\n==========================Iteration %d ================================",kk);
		/*--------------------------------------*/

		/*CLEAR BUFFER AND RETRY*/
		memset (buffer2,0,sizeof(buffer2));
		retry[0]=0;

		/*ACTUALLY SEND AN SQL COMMAND. ARGUMENTS ARE
		THE TOKEN PASSED BACK IN LOGIN,
		THE SQL COMMAND ITSELF,
		THE SQL QUALIFIER,
		THE BUFFER TO HOLD PROFILE'S REPLY,
		WHETHER THIS IS A RETRY OR NOT. NORMALLY IT IS NOT A RETRY,
		THE TIME TO WAIT BEFORE DECLARING A TIMEOUT
		*/

		command = sqlcommand[kk%2]; 
		ii = ProfileSQL (token,command,sqlqual,buffer2,retry,time_out);

		/*PRINT ERROR CODE AND RETURN VALUES*/
		printf ("\nreturn code: %d", ii);
		printf ("\nValues: %s\n", buffer2);
		
		} /*FOR LOOP ENDS*/
		ProfileDisconnect(token,buffer2);

} /*MAIN ENDS*/


