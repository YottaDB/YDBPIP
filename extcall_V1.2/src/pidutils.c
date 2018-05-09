/*
*	pidutils.c 
*
*	Copyright(c)1992 Sanchez Computer Associates, Inc.
*	All Rights Reserved
*
*	UNIX:	Sara G. Walters - 09 May 1995
*
*	DESC:	This routine performs the associated UNIX service calls
*			to provide the functionality as provided by the GT.M
*			call $ZGETJPI on VMS.
*
*   $Id$
*   $Log:	pidutils.c,v $
 * Revision 1.1  95/07/24  11:25:54  11:25:54  rcs ()
 * Initial revision
 * 
*   $Revision
*
*/
#include <sys/types.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <errno.h>
#include <pwd.h>
#include <grp.h>
#include <unistd.h>
/* #include <sys/pstat.h> */
#include "extcall.h"

#define	PST_MAX_PROCS	32

PROCESSDATA pid_list[PST_MAX_PROCS];
PROCESSDATA	*next_pid = (PROCESSDATA *)NULL;

void 
getgroup(int count,SLONG *pid,SLONG *return_code)
{
	RETURNSTATUS	rc = SUCCESS;
	register int 	i = 0;
	struct passwd	*pwd_entry = (struct passwd *)NULL;

	create_pid_list(return_code);
	if(*return_code != MUMPS_SUCCESS)
		return;

#ifdef DEBUG
	(void)fprintf(stdout,"getgroup:pid = %d\n",*pid);
	(void)fflush(stdout);
#endif

	if(*pid == (SLONG)NULL)
		*pid = getpid();

	for(i=0;i<PST_MAX_PROCS;i++)
	{
		if(*pid == pid_list[i].pid)
		{
#ifdef DEBUG
	(void)fprintf(stdout,"getgroup:pid_list[%d].pid = %d\n",i,pid_list[i]);
	(void)fprintf(stdout,"getgroup:pid_list[%d].login = %s\n",i,pid_list[i].login);
	(void)fflush(stdout);
#endif
			for(;;)
			{
				pwd_entry = getpwent();	
				if((rc = strcmp(pwd_entry->pw_name,pid_list[i].login)) == 0)
				{
					*return_code = pwd_entry->pw_gid;
#ifdef DEBUG
	(void)fprintf(stdout,"getgroup:Group Id = %d\n",*return_code);
	(void)fflush(stdout);
#endif
					break;
				}
			}
			endpwent();
		}
	}

	if((i == PST_MAX_PROCS) && (*return_code == MUMPS_SUCCESS))
		*return_code = PST_MAX_PROCS;

	return;
}

void 
getusername(int count,char *response,SLONG *return_code)
{

  /*	char	buf[L_cuserid]; -- deleted per discussion with Manoj.  - Bhaskar 20100212 */
	struct passwd   *pwd_entry = (struct passwd *)NULL;

	pwd_entry = getpwuid(geteuid());
	(void)strcpy(response,pwd_entry->pw_name);
	return;

}

void 
ttgetusername(int count,STR_DESCRIPTOR *response,SLONG *return_code)
{

	(void)strcpy(response->str,(char *)getlogin());
	response->length=strlen(response->str);
	return;

}

void 
tgetusername(int count,STR_DESCRIPTOR *response,SLONG *return_code)
{
	register int 	i = 0;
	SLONG			pid = 0;

	create_pid_list(return_code);
	if(*return_code != MUMPS_SUCCESS)
		return;

	pid = getpid();
	for(i=0;i<PST_MAX_PROCS;i++)
	{
		if(pid == pid_list[i].pid)
		{
			(void)strcpy(response->str,pid_list[i].login);
			response->length=strlen(response->str);
			break;
		}
	}

	if(i == PST_MAX_PROCS)
		*return_code = PST_MAX_PROCS;

	return;

}

void 
geterminal(int count,SLONG *pid,STR_DESCRIPTOR *response,SLONG *return_code)
{
	register int i = 0;

#ifdef DEBUG
	(void)fprintf(stdout,"geterminal");
	(void)fflush(stdout);
#endif
#ifdef DEBUG
	(void)fprintf(stdout,"geterminal:pid = %d\n",*pid);
	(void)fflush(stdout);
#endif

	create_pid_list(return_code);
	if(*return_code != MUMPS_SUCCESS)
		return;

	if(*pid == (SLONG)NULL)
		*pid = getpid();

	for(i=0;i<PST_MAX_PROCS;i++)
	{
		if(*pid == pid_list[i].pid)
		{
			(void)strcpy(response->str,pid_list[i].tty);
			response->length=strlen(response->str);
#ifdef DEBUG
	(void)fprintf(stdout,"geterminal: TTY Id = %s\n",response->str);
	(void)fflush(stdout);
#endif
			break;
		}
	}

	if(i == PST_MAX_PROCS)
		*return_code = PST_MAX_PROCS;

	return;
}

void 
getmember(int count,SLONG *pid,STR_DESCRIPTOR *response,SLONG *return_code)
{
	RETURNSTATUS	rc = SUCCESS;
	register int 	i = 0;
	struct passwd	*pwd_entry = (struct passwd *)NULL;
	struct group	*grp_entry = (struct group *)NULL;

	create_pid_list(return_code);
	if(*return_code != MUMPS_SUCCESS)
		return;

	if(*pid == (SLONG)NULL)
		*pid = getpid();

#ifdef DEBUG
	(void)fprintf(stdout,"getmember:pid = %d\n",*pid);
	(void)fflush(stdout);
#endif

	for(i=0;i<PST_MAX_PROCS;i++)
	{
		if(*pid == pid_list[i].pid)
		{
			for(;;)
			{
				pwd_entry = getpwent();	
#ifdef DEBUG
	(void)fprintf(stdout,"getmember:login = %s\n",pid_list[i].login);
	(void)fflush(stdout);
#endif
				if((rc = strcmp(pwd_entry->pw_name,pid_list[i].login)) == 0)
				{
					grp_entry = getgrgid(pwd_entry->pw_gid);
					(void)strcpy(response->str,grp_entry->gr_name);
					response->length=strlen(response->str);
					break;
				}
			}
			endpwent();
		}
	}

	if(i == PST_MAX_PROCS)
		*return_code = PST_MAX_PROCS;

	return;

}

void 
getprocid(int count,SLONG *pid,STR_DESCRIPTOR *response,SLONG *return_code)
{
	if(next_pid == (PROCESSDATA *)NULL)
	{
		create_pid_list(return_code);
		if(*return_code != MUMPS_SUCCESS)
			return;
		next_pid = pid_list;
	}
	else
		next_pid++;

#ifdef DEBUG
	(void)fprintf(stdout,"getprocid: next_pid->pid = %d\n",next_pid);
	(void)fflush(stdout);
#endif

	if(next_pid->pid != (SLONG)NULL)
		*pid = next_pid->pid;
	else
	{
		(void)strcpy(response->str,"EOL");
		response->length=strlen(response->str);
		next_pid = (PROCESSDATA *)NULL;
	}

#ifdef DEBUG
	(void)fprintf(stdout,"getprocid: pid = %d\n",*pid);
	(void)fflush(stdout);
#endif

	return;
}

void 
getimage(int count,SLONG *pid,STR_DESCRIPTOR *response,SLONG *return_code)
{
	register int i = 0;

	create_pid_list(return_code);
	if(*return_code != MUMPS_SUCCESS)
		return;

	if(*pid == (SLONG)NULL)
		*pid = getpid();

	for(i=0;i<PST_MAX_PROCS;i++)
	{
		if(*pid == pid_list[i].pid)
		{
			(void)strcpy(response->str,pid_list[i].job_name);
			response->length=strlen(response->str);
			break;
		}
	}

	if(i == PST_MAX_PROCS)
		*return_code = PST_MAX_PROCS;

	return;

}

void 
getprcnam(int count,SLONG *pid,STR_DESCRIPTOR *response,SLONG *return_code)
{
	register int 	i = 0;

	create_pid_list(return_code);
	if(*return_code != MUMPS_SUCCESS)
		return;

	if(*pid == (SLONG)NULL)
		*pid = getpid();

	for(i=0;i<PST_MAX_PROCS;i++)
	{
		if(*pid == pid_list[i].pid)
		{
#ifdef DEBUG
	(void)fprintf(stdout,"getprcnam: Job Name = %s\n",pid_list[i].job_name);
	(void)fflush(stdout);
#endif
			(void)strcpy(response->str,pid_list[i].job_name);
			response->length=strlen(response->str);
		}
	}

	if(i == PST_MAX_PROCS)
		*return_code = PST_MAX_PROCS;

}

void 
getlogintime(int count,SLONG *pid,STR_DESCRIPTOR *response,SLONG *return_code)
{
	register int i = 0;

	create_pid_list(return_code);
	if(*return_code != MUMPS_SUCCESS)
		return;

	if(*pid == (SLONG)NULL)
		*pid = getpid();

	for(i=0;i<PST_MAX_PROCS;i++)
	{
		if(*pid == pid_list[i].pid)
		{
			(void)strcpy(response->str,pid_list[i].login_time);
			response->length=strlen(response->str);
			break;
		}
	}

	if(i == PST_MAX_PROCS)
		*return_code = PST_MAX_PROCS;

}

void 
getcputime(int count,SLONG *pid,STR_DESCRIPTOR *response,SLONG *return_code)
{
	register int i = 0;

	create_pid_list(return_code);
	if(*return_code != MUMPS_SUCCESS)
		return;

	if(*pid == (SLONG)NULL)
		*pid = getpid();

	for(i=0;i<PST_MAX_PROCS;i++)
	{
		if(*pid == pid_list[i].pid)
		{
			(void)strcpy(response->str,pid_list[i].cpu_time);
			response->length=strlen(response->str);
			break;
		}
	}

	if(i == PST_MAX_PROCS)
		*return_code = PST_MAX_PROCS;

}

/* LYH 03/24/99 - rewrite function to return correct process parent id */
void 
getparentpid(int count,SLONG *pid,SLONG *ppid, SLONG *return_code)
{
	FILE 	*fd = (FILE *)NULL;
	char 	cmd[MAX_CMD_LEN],str_fill[MAX_CMD_LEN],line[256];
	int 	tmp_pid,tmp_ppid,found;

	*return_code = SUCCESS;

	if ((tmp_pid = getpid()) < 0)
	{
	   *return_code = errno;
	   return;
	}

	if ((*pid == (SLONG)NULL) || (*pid < 0))
	   *pid = tmp_pid;

	/*
	** simply call getppid and return if process id wasn't passed in, or
	** if it's the same with current process id. 
	*/

	if (*pid == tmp_pid)
	{
	   if((*ppid = getppid()) < 0)
	   {
	      *return_code = errno;
	   }
	   return;
	}

	/*
	** ok, we are looking for the parent pid for any process id.
	** we have to pipe a command and look for anything similar to
	** the current process id
	*/

	/*
	**	Build the ps command
	*/
	(void)sprintf(cmd,"ps -ef | cut -c 1-2000 | grep -E %d",*pid);

	/*
	*	Open pipe and execute command
	*/
	if ((fd = popen(cmd,"r")) == (FILE *)NULL)
	{
	   *return_code = errno;
	   return;
	}

	/*
	**	Read the result of executed command.
	*/
	found = 0;
	while ((fgets(line,256,fd) != NULL) && (!found))
	{
	      sscanf(line,"%s%d%d",str_fill,&tmp_pid,&tmp_ppid);
	      if (tmp_pid == *pid)
	      {
	         *ppid = tmp_ppid;
	         found = 1;
	      }
	} /* end of for loop */

	pclose(fd);

	if (!found)
	{
	   *return_code = FAILURE;
	}

	return;

}
/* LYH 03/24/99 - end */

void 
getjobtype(int count,SLONG *pid,SLONG *return_code)
{
	register int	i = 0;

	if(*pid == (SLONG)NULL)
		*pid = getpid();

	for(i=0;i<PST_MAX_PROCS;i++)
	{
		if(*pid == pid_list[i].pid)
		{
			if((*return_code = job_type(*pid,
										pid_list[i].tty,
										return_code)) == FAILURE)
				return;
			break;
		}
	}

#ifdef DEBUG
	(void)fprintf(stdout,"pidutils: pid = %d\n",*pid);
	(void)fprintf(stdout,"pidutils: pid_list[%d].pid = %d\n",i,pid_list[i].pid);
	(void)fprintf(stdout,"pidutils: job_type = %d\n",i,*return_code);
	(void)fflush(stdout);
#endif

	return;
}

SLONG
job_type(SLONG pid,char *tty,SLONG *return_code)
{
	RETURNSTATUS 	rc = SUCCESS;
	FILE 			*fd = (FILE *)NULL;
	char 			cmd[128];
	char 			str_fill[MAX_CMD_LEN];
	int				int_fill = 0;
	char			job_name[80];

	if((strcmp(tty,"?")) == 0)
	{
		return DETACH;
	}

#ifdef DEBUG
	(void)fprintf(stdout,"job_type\n");
	(void)fflush(stdout);
#endif

	/*
	*	Build the ps command
	*/
	(void)sprintf(cmd,"ps -e | cut -c 1-2000 | grep %s",tty);

	/*
	*	Open pipe and execute command
	*/
	if((fd = popen(cmd,"r")) == (FILE *)NULL)
	{
#ifdef DEBUG
	fprintf(stdout,"jobtype: errno = %d\n",errno);
	fflush(stdout);
#endif
		*return_code = errno;
		return FAILURE;
	}

#ifdef DEBUG
	(void)fprintf(stdout,"job_type: cmd = %s\n",cmd);
	(void)fflush(stdout);
#endif

	for(;;)
	{
		/*
		*	Read the "process data" of a mumps process.
		*/
		if((rc = fscanf(fd,
						"%d%s%s%s",
						&int_fill,
						str_fill,
						str_fill,
						job_name)) < 4)
		{
#ifdef DEBUG
	(void)fprintf(stdout,"Local Job\n");
	(void)fflush(stdout);
#endif
			pclose(fd);
			return LOCAL;
		}

#ifdef DEBUG
	(void)fprintf(stdout,"job_type: After fscanf rc = %d\n",rc);
	(void)fprintf(stdout,"job_type: job_name = %s\n",job_name);
	(void)fflush(stdout);
#endif
		if(((rc = strncmp(job_name,"rlogin",6)) == 0)
			|| ((rc = strncmp(job_name,"telnet",6)) == 0))
		{
#ifdef DEBUG
	(void)fprintf(stdout,"Remote Job\n");
	(void)fflush(stdout);
#endif
			pclose(fd);
			return NETWORK;
		}
	}

#ifdef DEBUG
	(void)fprintf(stdout,"Local Job\n");
	(void)fflush(stdout);
#endif
	pclose(fd);
	return LOCAL;
}

void 
create_pid_list(SLONG *return_code)
{
	RETURNSTATUS 	rc = SUCCESS;
	FILE 		*fd = (FILE *)NULL;
	char 		*rel_dir = (char *)NULL;
	char		mjob[24];
	char 		cmd[128];
	char 		str_fill[MAX_CMD_LEN];
	int		int_fill = 0;
	char 		job_name[MAX_CMD_LEN];
	char		cpu_time[24];
	char		login[24];
	char		login_time[24];
	char		tty[12];
	SLONG		pid = 0;
	SLONG		ppid = 0;
	register int	i=0;
	register int	j=0;

#ifdef DEBUG
	(void)fprintf(stdout,"create_pid_list\n");
	(void)fflush(stdout);
#endif

	for(i=0;i<PST_MAX_PROCS;i++)
		pid_list[i].pid = (int)NULL;
	i = 0;

	rel_dir=(char *)getenv("RELEASE_DIR");

#ifdef DEBUG
	/*
	*	Build the ps command
	*/
	(void)sprintf(cmd,"ps -elf | cut -c 1-2000 | grep -E \"[0-9] %s/gtm_dist/mu\"",rel_dir);

	/*
	*	Open pipe and execute command
	*/
	if((fd = popen(cmd,"r")) == (FILE *)NULL)
	{
#ifdef DEBUG
	fprintf(stdout,"create_pid_list: errno = %d\n",errno);
	fflush(stdout);
#endif
		*return_code = errno;
		return;
	}
	for(;;)
	{
		rc = fread(cmd,1,128,fd);
		if(rc < 1)
		{
			pclose(fd);
			break;
		}
		(void)fprintf(stdout,"create_pid_list: Line = %s\n",cmd);
		(void)fflush(stdout);
	}
#endif

	/*
	*	Build the ps command
	*/
	(void)sprintf(cmd,"ps -elf | cut -c 1-2000 | grep -E \"[0-9] %s/gtm_dist/mu\"",rel_dir);
	i = 0;

#ifdef DEBUG
	(void)fprintf(stdout,"create_pid_list: cmd = %s\n",cmd);
	(void)fflush(stdout);
#endif

	/*
	*	Open pipe and execute command
	*/
	if((fd = popen(cmd,"r")) == (FILE *)NULL)
	{
#ifdef DEBUG
	fprintf(stdout,"create_pid_list: 2 errno = %d\n",errno);
	fflush(stdout);
#endif
		*return_code = errno;
		return;
	}

	for(;;)
	{
		/*
		*	Read the "process data" of a mumps process.
		*/
		if((rc = fscanf(fd,
						"%d%s%s%d%d%d%d%d%s%s%s%s%s%s%s%s",
						&int_fill,
						str_fill,
						login,
						&pid,
						&ppid,
						&int_fill,
						&int_fill,
						&int_fill,
						str_fill,
						str_fill,
						str_fill,
						login_time,
						tty,
						cpu_time,
						job_name,
						str_fill)) < 16)
		{
			pclose(fd);
#ifdef DEBUG
	for(i=0;i<PST_MAX_PROCS;i++)
	{
		(void)fprintf(stdout,"create_pid_list: Pid = %d\n",pid_list[i].pid);
		(void)fflush(stdout);
	}
#endif
			return;
		}

#ifdef DEBUG
	(void)fprintf(stdout,"create_pid_list: After fscanf rc = %d\n",rc);
	(void)fflush(stdout);
	(void)fprintf(	stdout,
					"Login %s Login Time %s Pid %d PPID %d TTY %s Job Name %s Cpu Time %s\n",
					login,
					login_time,
					pid,
					ppid,
					tty,
					job_name,
					cpu_time);
	(void)fflush(stdout);
#endif
		(void)sprintf(mjob,"%s/gtm_dist/mumps",rel_dir);
		if((rc = strcmp(job_name,mjob)) == 0)
		{
			(void)strcpy(pid_list[i].login,login);
			(void)strcpy(pid_list[i].login_time,login_time);
			(void)strcpy(pid_list[i].tty,tty);
			(void)strcpy(pid_list[i].job_name,job_name);
			(void)strcpy(pid_list[i].cpu_time,cpu_time);
			pid_list[i].pid = pid;
			pid_list[i].ppid = ppid;
#ifdef DEBUG
	(void)fprintf(stdout,"create_pid_list: login = %s\n",pid_list[i].login);
	(void)fprintf(stdout,"create_pid_list: tty = %s\n",pid_list[i].tty);
	(void)fprintf(stdout,"create_pid_list: job_name = %s\n",pid_list[i].job_name);
	(void)fprintf(stdout,"create_pid_list: pid = %d\n",pid_list[i].pid);
	(void)fprintf(stdout,"create_pid_list: i = %d\n",i);
	(void)fflush(stdout);
#endif
			i++;
		}
	}
	pclose(fd);
}

void
permissions(int count,char *permission,SLONG *return_code)
{
	RETURNSTATUS	rc = SUCCESS;
	struct group	*grp_entry = (struct group *)NULL;
	char			grp_name[24];

	if(((rc = strcmp(permission,MTMPRIV)) == 0)
		|| ((rc = strcmp(permission,SPAWN)) == 0))
	{
		(void)strcpy(grp_name,MTMGRP);	
	}
	else 
	{
		(void)strcpy(grp_name,SYSGRP);	
	}

	*return_code = 0;
	grp_entry = getgrgid(getgid());

	if((rc = strcmp(grp_entry->gr_name,grp_name)) == 0)
	{
		*return_code = 1;
	}
	else
	{
		grp_entry = getgrgid(getegid());
		if((rc = strcmp(grp_entry->gr_name,grp_name)) == 0)
		{
			*return_code = 1;
		}
	}

	return;
}

