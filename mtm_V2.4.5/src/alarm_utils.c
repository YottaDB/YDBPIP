/*
*	alarm_utils
*
*	Utility to perform alarm functions
*
*	ORIG: Hien T. Ly
*
* $Id:$
*
* $Log:	alarm_utils.c,v $
 * Revision 1.3  04/01/29  thoniyilmk
 * strtoul() is used instead of atoi, in sca_AlarmSetup()
 *
 * Revision 1.2  00/03/23  10:28:55  10:28:55  lyh ()
 * Correct placement of break statement in cancel timer
 * 
 * Revision 1.1  00/03/03  15:19:52  15:19:52  lyh ()
 * Initial revision
 * 
*
* $Revision: 1.2 $
*
*/
#include <stdio.h>
#include <stdlib.h>
#include <sys/time.h>
#include <sys/signal.h>

/*
*	Definitions
*/
#define ENV_VAR		"GTM_CALLIN_START"
#define UNK_TIMER	0
#define SCA_TIMER	1
#define GTM_TIMER	2

/*
*	Timer related functions
*/
void (*setup_timer)  ();
void (*cancel_timer) ();
void **functable;

/*
*	Static variables
*/
static int alarmSetupFlag = UNK_TIMER;

/*
*	Type definitions
*/
typedef void	Sigfunc(int);

typedef struct {
	int	value;
	int	type;
	int	flag;
} st_timeout;

/*
*	External calls
*/
extern Sigfunc *mtm_signal_intr(int, Sigfunc *);




/*
*	sca_AlarmSetup
*
*	If we are calling from M, we have to use the GTM timer functions
*	to set/cancel timeout. The environment variable GTM_CALLIN_START
*	is only available at run time. We translate this variable to get
*	the address of "exposed" GTM functions. Here, we refer to it as
*	a function table. The timer set function is at index 2, and the
*	timer cancel function is at index 3.
*	If the run time environment variable is not defined, we must be
*	calling from another C program. We then proceed with the old
*	code of setting up UNIX signals for timeout purpose. Otherwise,
*	we would end up with two different versions of client.c: one for
*	building mtmapi.o, and one for testing/simulation.
*
*	Returns:	SCA_TIMER - use the old UNIX signal for timeout
*			GTM_TIMER - use GTM timer for timeout
*       Revision History:
*       thoniyilmk - 01/29/04
*         When GT.M is passing in a very high address value.
*         This is converted using atoi, an overflow happens and so
*         LONG_MAX is returned, instead of the actual value. To solve this
*         problem, I'm converting to an unsigned long (using strtoul()),
*	  instead of signed long.
*/
int sca_AlarmSetup(int flag)
{
	unsigned long  lAddress;
	char *pcAddress;

	if (alarmSetupFlag != UNK_TIMER)
	{
		/*
		*	Already ran this function, return previous result.
		*/
		return(alarmSetupFlag);
	}

	/*
	*	Check flag to see where we are coming in from
	*/
	if (flag == 0)
	{
		alarmSetupFlag = SCA_TIMER;
		return(SCA_TIMER);
	}
	
	/*
	*	Translate run time environment variable
	*/
	pcAddress = getenv(ENV_VAR);
	if (pcAddress == NULL)
	{
#ifdef DEBUG
		fprintf(stdout, "\nsca_AlarmSetup: Failed to get environment variable %s.\n", ENV_VAR);
		fprintf(stdout, "Continue with old timeout logic\n");
		fflush(stdout);
#endif
		alarmSetupFlag = SCA_TIMER;
		return(SCA_TIMER);
	}

	/*
	*	Convert pcAddress to a numeric value
	*/
	lAddress = -1;
        lAddress = strtoul(pcAddress,NULL,10);
	if (lAddress == -1)
	{
#ifdef DEBUG
		fprintf(stdout, "\nsca_AlarmSetup: Failed to convert %s to a valid address.", pcAddress);
		fprintf(stdout, "Continue with old timeout logic\n");
		fflush(stdout);
#endif
		alarmSetupFlag = SCA_TIMER;
		return(SCA_TIMER);
	}

	/*
	*	Setup the timer functions
	*/
	functable = (void *)lAddress;
	setup_timer  = (void(*)()) functable[2];
	cancel_timer = (void(*)()) functable[3];
	alarmSetupFlag = GTM_TIMER;
#ifdef DEBUG
	fprintf(stdout,"sca_AlarmSetup: process will run with GTM_TIMER\n");
	fflush(stdout);
#endif
	return(GTM_TIMER);
}




/*
*	sca_SetupTimer
*
*	A wrapper function to set the timeout alarm.
*
*/
void sca_SetupTimer(void *callingFunction,st_timeout *timeout,void *catchingFunction)
{
#ifdef DEBUG
	fprintf(stdout,"sca_SetupTimer: setting up a timer for %d seconds\n",timeout->value);
	fprintf(stdout,"\tcalling function address: %x\n",callingFunction);
	fflush(stdout);
#endif
	switch(timeout->type)
	{
		case SCA_TIMER:
			(void)mtm_signal_intr(SIGALRM,(Sigfunc *)catchingFunction);
			alarm(timeout->value);
			break;
		case GTM_TIMER:
			setup_timer(callingFunction,timeout->value*1000,catchingFunction,0,NULL);
			break;
		default:
			break;
	}

	timeout->flag = 0;

	return;
}




/*
*	sca_CancelTimer
*
*	A wrapper function to cancel the timeout alarm.
*
*/
void sca_CancelTimer(void *callingFunction, st_timeout *timeout)
{
#ifdef DEBUG
	fprintf(stdout,"sca_CancelTimer: cancel a timer previously set\n");
	fprintf(stdout,"\tcalling function address: %x\n",callingFunction);
	fflush(stdout);
#endif
	switch(timeout->type)
	{
		case SCA_TIMER:
			(void)mtm_signal_intr(SIGALRM,SIG_IGN);
			alarm(0);
			break;
		case GTM_TIMER:
        		cancel_timer(callingFunction);
			break;
		default:
			break;
	}

	return;
}
