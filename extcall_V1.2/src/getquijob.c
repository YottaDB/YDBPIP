#define FOUND 1
#define NOT_FOUND 0
#define QUEUE_SEARCH_NUM 2  /*  Total Amount of Queues to search through */
#define DEFAULT_BATCH "SCA$BATCH"      /* Default Batch Name */
#define MAX_TARGET_STRING_SIZE 124*32  /* MAX 124 execution queues * 32 bytes for que name. */
#define OK 1
#define NO_MORE_QUEUES 0

#include <ssdef>
#include <stdlib>
#include <stdio>
#include <starlet>
#include <signal>
#include <lib$routines>
#include <iodef>
#include <descrip>
#include <quidef>
#include <ctype>
#include <jbcmsgdef>
#include <string>

 typedef struct {
     short int buflen;
     short int itmcod;
     char *    bufadr;
     short int  *    retadr;
     } ITEM_LIST;

 typedef struct {
     int iostat;
     int unused;
     } IOSTAT_BLOCK;

void get_next_que_name (char *, char *);
void fill_item_list(ITEM_LIST *, short int, short int, char *, short int *);

/*****************************************************************************/
/*                                GETQUIJOB                                  */
/*                                                                           */
/*        $ZC("GETQUIJOB","JOBNAME")                                         */
/*                                                                           */
/*        This function will receive a Jobname from the calling mumps        */
/*      program, it will then search the queue SCA$BATCH for the jobname's   */
/*      existence on the queue.                                              */
/*                                                                           */
/*        If not found, the program will check the SCA$BATCH queue for the   */
/*      type of queue it is, { Generic, or Executable }.                     */
/*                                                                           */
/*       If SCA$BATCH is an executable batch, no more checking is required,  */
/*      and the program will check for the existance of the jobname,         */
/*      but if it is a Generic queue, the program will ask and receive       */
/*      from the system, a list of valid execution Queues that SCA$BATCH     */
/*      could send Jobs to for execution, and check these one by one until   */
/*      the jobname is found, or until the list of queue names returned      */
/*      have been exhausted.                                                 */
/*                                                                           */
/*        If the jobname is found this function will return a 1, if not      */
/*      found a 0 will be returned.                                          */
/*                                                                           */
/*----------   Revision History   -------------------------------------------*/
/*                                                                           */
/*    9/9/92 - Ray Kane  -  Created.                                         */
/*              Convert Assembly Language Program GETQUIJOB.MAR              */
/*              to "C".                                                      */
/*                                                                           */
/*   6/21/93 - Ray Kane  -  Modified                                         */
/*              Changed functionality, to check for the jobname in the       */
/*              SCA$BATCH Queue, and if necessary the valid queues that it   */
/*              send jobs to, instead of blindly checking each queue for     */
/*              the existence of the jobname sent in.                        */
/*****************************************************************************/



  getquijob(data_in, dst)
    struct dsc$descriptor *data_in;
    long                  *dst;
    {
     ITEM_LIST queue_list[6], job_list[6];
     char buf[512], que_name[40], scratch[80], scratch1[80];
     char que_wild_que_name[80], target_string[MAX_TARGET_STRING_SIZE];
     char *target_offset;
     char jobname[132], generic_flag;
     int  job, x;
     struct queue_flags que_flags;
     long int status_q, status_j;
     short int qname_len, jobname_len;
     IOSTAT_BLOCK qiosb,jiosb, iosb;
     int search_flags[] = { 
                     (QUI$M_SEARCH_WILDCARD|   /*  Search the Batch Queue.  */
                      QUI$M_SEARCH_BATCH   |
                      QUI$M_SEARCH_ALL_JOBS)};

     target_offset = target_string;
     strcpy(que_wild_que_name, DEFAULT_BATCH);

     job = NOT_FOUND;               /*  set job flag to NOT_FOUND.         */
                                    /*  this will be tested each time      */
                                    /*  through the search loop.           */

     *dst = NOT_FOUND;

     /*************************************************************************
     ** Initialize Item List - QUEUE LIST                                    **
     **                                                                      **
     ** This item list allows the system service routine to return the       **
     **     information requested.                                           **
     **                                                                      **
     ** A). The first Item list is the queue list.  This list tells the      **
     **        systems service function to return;                           **
     **                                                                      **
     **                1. the description of the Sca$Batch Queue to begin    **
     **                   with, and if the program warrants it,a description ** 
     **                   of any other queue sent to it.                     **
     **                                                                      **
     ** B). The second Item list is the job list.  This list tells the       **
     **       systems service function to return the name of the job.        **
     **                                                                      **
     **       There are more items that could be returned from this          **
     **       function, such as, the job's PID, Job retention time,          **
     **       Job Status, or Job Size.  But at this time the fact that       **
     **       a job is present or missing is all that is important.          **
     *************************************************************************/

     fill_item_list( &queue_list[0], (short int) strlen(que_wild_que_name),
               (short int) QUI$_SEARCH_NAME, que_wild_que_name, NULL );

     fill_item_list( &queue_list[1], (short int) sizeof(int),
               (short int) QUI$_SEARCH_FLAGS, (char *) &search_flags[0], NULL );
                               
     fill_item_list( &queue_list[2], (short int) sizeof(que_name),
               (short int) QUI$_QUEUE_NAME, que_name, &qname_len);

     fill_item_list( &queue_list[3], (short int) sizeof(que_flags),
               (short int) QUI$_QUEUE_FLAGS, (char *) &que_flags, NULL );

     fill_item_list( &queue_list[4], (short int) sizeof(target_string),
               (short int) QUI$_GENERIC_TARGET, target_string, NULL);

     memset(&queue_list[5], 0, sizeof(ITEM_LIST));
         
     fill_item_list( &job_list[0], (short int) sizeof(int),
               (short int) QUI$_SEARCH_FLAGS, (char *) &search_flags[0], NULL);

     fill_item_list( &job_list[1], (short int) sizeof(jobname),
               (short int) QUI$_JOB_NAME, jobname, &jobname_len);
 
    
     memset(&job_list[2], 0, sizeof(ITEM_LIST));
         
     /*****************************************************************
     **  Since we're working in Wildcard Mode.  We must cancel prior **
     **  operation, if there was one.                                **
     *****************************************************************/
     status_q = sys$getquiw (NULL, QUI$_CANCEL_OPERATION,
                                       NULL, NULL, &iosb, NULL, NULL);

     if (status_q != SS$_NORMAL)     /* check status of prior operation.    */
            lib$signal(status_q);    /*  Log an error if anything except OK */
         
     do
        {

         /******************************************************************
         **  get the queue description from System Services Function      **
         **  "sys$getquiw", the return value will be a JBC$_NORMAL=1 if   **
         **  successful.                                                  **
         ******************************************************************/
         status_q = sys$getquiw (NULL, QUI$_DISPLAY_QUEUE, NULL,
                                           queue_list, &qiosb, NULL, NULL);
             
         if (status_q != SS$_NORMAL)
             lib$signal(status_q);     /*  Log an error if anything except OK */
                
         if (qiosb.iostat == JBC$_NORMAL)  /* check status of prior operation.*/
           {
            do
               {
                memset (jobname, 0, sizeof(jobname));  /* init jobname to null.

                /*****************************************  
                ** get the jobname from System Services **
                *****************************************/

                status_j = sys$getquiw ( NULL, QUI$_DISPLAY_JOB, NULL,
                                                job_list, &jiosb, NULL, NULL);
                 
                /**************************************************************
                **  1st compare the length of the Jobname passed in to the   **
                **      length of the jobname found in the queue.            **
                **                                                           **
                **  2nd compare the string value of the jobname passed in to **
                **      the string value of the jobname found in the queue.  **
                **************************************************************/

                if(data_in->dsc$w_length == jobname_len &&
                   memcmp(data_in->dsc$a_pointer, jobname, jobname_len) == 0)
                  {
                   *dst = FOUND;   /* set return value. */
                   job = FOUND;           /* set test value.   */
                  }
               } while (jiosb.iostat == JBC$_NORMAL);    /* Keep goin, until done  */

            /***************************************************************
            **   Check SCA$BATCH queue's type for generic, {true/false}.  **
            **  or if the generic_flag is turned on, and the job is not   **
            **  found.                                                    **
            **                                                            **
            **   If these conditions are met, take the list of executable **
            **  queues and process them 1 by 1.                           **
            **                                                            **
            **   Each call to get_next_que_name will return the next      **
            **  queue name in the list, until the last queue has been     **
            **  processed from the list.  In this case it will retun an   **
            **  NULL value in the return variable.                        **
            ***************************************************************/
            if ((que_flags.qui$v_queue_generic==1 || generic_flag == TRUE)
                                                          && job != FOUND)
               {
                generic_flag=TRUE;    /* Check the Generic Flag to TRUE. */

                memset(que_wild_que_name, 0, sizeof(que_wild_que_name));
                get_next_que_name(que_wild_que_name, target_offset);

                queue_list[0].buflen = (short int) strlen(que_wild_que_name); 
                queue_list[0].bufadr = que_wild_que_name;

                /*  Setup for next operation by canceling previous. */
                status_q = sys$getquiw (NULL, QUI$_CANCEL_OPERATION,
                                       NULL, NULL, &iosb, NULL, NULL);
                  
                if (status_q != SS$_NORMAL)
                         lib$signal(status_q);   /*  Log an error if anything except OK */
               }
           }
              
        } while ( qiosb.iostat == JBC$_NORMAL &&
                  job != FOUND && 
                  strlen(que_wild_que_name) >0 );

     return ((long) 1);
    }




/****************************************************************************/
/*                            Get_Next_Que_Name                             */
/*                                                                          */
/*      This function will pull out a queue name from the list pointed to   */
/*    by the offset pointere (ptr_in).  Each time this is called, the       */
/*    offset pointer will be updated with the next postion of the next      */
/*    que_name in the list.                                                 */
/****************************************************************************/

void get_next_que_name(char *string_out, char *ptr_in)
   {
    while (*ptr_in != '\0' && *ptr_in != ',')
      {
       /* Create a queue name from queue name string. */
       *string_out++ = *ptr_in++;   
      }
   }


/*****************************************************************************/
/*                            fill_item_list                                 */
/*                                                                           */
/*    Fill ITEM Structure to send to System Service Call.                    */
/*                                                                           */
/*****************************************************************************/

void fill_item_list(ITEM_LIST *list, short int buflen, 
                    short int itmcod, char *bufaddr, short int *retadr)
     {
      list->buflen = buflen;
      list->itmcod = itmcod;
      list->bufadr = bufaddr;
      list->retadr = retadr;
     }
