/*
*       mintrpt.c
*
*       Copyright(c)2005 Fidelity Information Services
*       All Rights Reserved
*
*       UNIX:   Erik Scheetz - 24 May 2005
*
*       DESC:   M Process Interrupt Mechanism
*
*		USAGE:  mintrt {process id}
*/

#include <unistd.h>
#include <sys/types.h>
#include <signal.h>
#include <stdlib.h>
#include <errno.h>
#include <ctype.h>
#include <stdio.h>
#include <string.h>

uid_t	real_uid;
gid_t	real_gid;
uid_t	eff_uid;
gid_t	eff_gid;

void init_privs()
{
   real_uid = getuid();
   real_gid = getgid();
   eff_uid  = geteuid();
   eff_gid  = getegid();
   /* printf("%d\t\t%d\t\t%d\t%d\tinit_privs\n",
             real_uid, real_gid, eff_uid, eff_gid); */
}

void drop_privs()
{
   setregid(eff_gid, real_gid);
   if (setreuid(eff_uid, real_uid) < 0)
      printf("ERROR: Unable to setreuid(%d,%d)\n",real_uid, eff_uid);
   /* printf("%d\t\t%d\t\t%d\t%d\tdrop_privs\n",
             real_uid, real_gid, eff_uid, eff_gid); */
}

void set_privs()
{
   setregid(real_gid, eff_gid);
   if (setreuid(real_uid, eff_uid) < 0)
      printf("ERROR: Unable to setreuid(%d,%d)\n",real_uid, eff_uid);
   /* printf("%d\t\t%d\t\t%d\t%d\tset_privs\n",
             real_uid, real_gid, eff_uid, eff_gid); */
}

int main (int argc, char *argv[])
{
   int     pid,index,usable;
   char    *pgname;

   pgname = argv[0];

   if (argc < 2)
   {
      printf("%s: nothing to do\n",pgname);
      exit(0);
   }

   /* printf("Real UID\tReal GID\tEff UID\tEff GID\n"); */

   init_privs();

   set_privs();

   while (argc > 1)
   {
      usable = 1;

      for (index=0; index < strlen(argv[1]); index++)
      {
	 if (!isdigit(argv[1][index]))
         {
            usable = 0;
            break;
         }
      }

      if (usable)
      {
         pid = atoi(argv[1]);
         /* printf("pid is %d\n",pid); */
         kill(pid,SIGUSR1);
      }
      else
         printf("%s: invalid argument %s\n",pgname,argv[1]);

      argc--;
      argv++;
   }

   drop_privs();

   exit(0);
}
