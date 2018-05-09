#include "libsql.h"
#include <stdio.h>
#include <stdlib.h>

/*Date Format*/
extern char sShortDate[25];

/*Decimal Format*/
extern char sDec[2];

/*Date Delimiter*/
extern char sDateDelim[2];

/****************************************************************************
Function Name	: int m_date(char *a_sDate,char *pDate)

Arguments	: char	*a_sDate	string date /TYP=S/FORMAT=MM/DD/YYYY
					or /FORMAT = NNNNN
		  char	*pDate		Number of Days since 12/31/1840
					or String Date Translation of Mumps
					Julian Date

Return		: 0 - Fail
		  1 - SUCCESS

Comments	: This function is used to convert mumps date to gregorian 
		  date orgregorian date to mumps. If the date is in 
		  /FORMAT=NNNNN it gets converted to MM/DD/YYYY format 
		  and vice versa.

******************************************************************************/
int m_date(char *a_sDate,char *pDate)
{

	long	ll_julien;
	int	lb_date = 0,lb_number = 0;
	int	li_year,li_day = 0,li_month = 1,li_LeapYear = 0;
	int	li_scratch = 0,li_Incr = 0,li_NumDays = 31;
	char	*pToken = NULL;
	int	nResult;

	int	M1 = 0,D1 = 0,Y1 = 0,ND1 = 0,count = 0;
	int	DaysInMonth[] = {31,28,31,30,31,30,31,31,30,31,30,31};
	int	noLeapDaysInMonth[]	= {0,31,59,90,120,151,181,212,243,273,304,334};
	int	leapDaysInMonth[]	= {0,31,60,91,121,152,182,213,244,274,305,335};

	if(a_sDate == NULL || a_sDate == "")
		return 0;

	pToken = (char *)strstr(a_sDate,"/");
	if(pToken)
		lb_date = 1;

	if(lb_date)
	{
		pToken = (char *)strtok(a_sDate,"/");
		if(pToken)
			M1 = atoi(pToken);
		pToken = (char *)strtok(NULL,"/");
		if(pToken)
			D1 = atoi(pToken);
		pToken = (char *)strtok(NULL,"/");
		if(pToken)
			Y1 = atoi(pToken);

		if(M1 == 0 || D1 == 0 || Y1 == 0)
			return 0;

		/* Is this year a leap year? And get days in current year */
		if ( Y1 % 400 == 0 || ( Y1 % 4 == 0 && (Y1 % 100 != 0 )))
			ND1 = D1 + leapDaysInMonth[M1 - 1];
		else
			ND1 = D1 + noLeapDaysInMonth[M1 - 1];

        	/* days in normal 365 days year */
        	ND1 = ND1 + (Y1 - 1841) * 365;
 
        	/* add one day for each leap year whiout considering current year */
        	ND1 = ND1 + (Y1 - 1841) / 4;
 
        	/* subtract one day for each century */
        	ND1 = ND1 - ((Y1-1) / 100 -18);
 
        	/* add one day for each fourth century */
        	ND1 = ND1 + ((Y1 - 1) / 400 - 4);

		sprintf(pDate, "%d", ND1);
	}
	else
	{
		if(atol(a_sDate) < 0)
			return 0;
		ll_julien = atol(a_sDate);
		if(ll_julien > 21914)
			++ll_julien;

		li_LeapYear = ll_julien / 1461;
		li_scratch = ll_julien%1461;
		li_year = li_LeapYear * 4 + 1841 + (li_scratch / 365);
		li_day = li_scratch%365;

		if(li_scratch == 1460 && li_LeapYear != 14)
		{
			li_day = 365;
			li_year--;
		}

		li_Incr = 0;
		li_NumDays = DaysInMonth[li_Incr];

		while(li_NumDays < li_day)
		{
			if((li_Incr == 1) && (li_scratch > 1154) && (li_LeapYear != 14))
				li_NumDays++;
			if((li_day == 29) && (li_NumDays == 29))
				continue;
			li_month++;
			li_day = li_day - li_NumDays;
			li_Incr++;
			li_NumDays = DaysInMonth[li_Incr];
		}

		if(li_day == 0)
		{
			--li_year;
			li_month = 12;
			li_day = 31;
		}

		nResult = GetDisplayDate(li_day,li_month,li_year,pDate);
		if(!nResult)
			return 0;
	}
	return 1;
}


/*****************************************************************************
Function Name	: GetDisplayDate(int li_day, int li_month, int li_year, 
					char *pDate)

Arguments	: int li_day
		  int li_month 
	  	  int li_year
		  char *pDate

Return		: 0 - Fail
		  1 - SUCCESS

Comments	: This Function format the date according to Regional Settings 
		  of the User's Setting.
					
*****************************************************************************/
int GetDisplayDate(int li_day,int li_month,int li_year, char *pDate)
{
		char *s_part1,*s_part2,*s_part3;
		char *pszShortDate;
		char *pToken = NULL;
		char s_strMonth[3],s_strDay[3],s_strYear[5];
		ULONG ulShortDateLen = 24, ulDateDelimLen = 4;

		if((li_day < 0) || (li_month) < 0 || (li_year < 0))
			return 0;

		pszShortDate = (char *)calloc(25,1);
		strcpy(pszShortDate,sShortDate);

		pToken = (char *)strtok(pszShortDate,sDateDelim);
		s_part1 = (char *)calloc (strlen(pToken)+1,1);
		strcpy(s_part1,pToken);


		pToken = (char *)strtok(NULL,sDateDelim);
		s_part2 = (char *)calloc (strlen(pToken)+1,1);
		strcpy(s_part2,pToken);

		pToken = (char *)strtok(NULL,sDateDelim);
		s_part3 = (char *)calloc (strlen(pToken)+1,1);
		strcpy(s_part3,pToken);

		if(s_part1 == NULL || s_part2 == NULL || s_part3 == NULL)
			memset(pszShortDate,0,ulShortDateLen+1);
		else
		{
			memset(pszShortDate,0,ulShortDateLen+1);
			strncpy(pszShortDate,s_part1,1);
			strncat(pszShortDate,s_part2,1);
			strncat(pszShortDate,s_part3,1);
			/*strupr(pszShortDate);*/
		}

		if(li_month < 10)
			sprintf(s_strMonth,"%02d",li_month );
		else
			sprintf(s_strMonth,"%d",li_month );

		if(li_day < 10)
			sprintf(s_strDay,"%02d",li_day );
		else
			sprintf(s_strDay,"%d",li_day );

		sprintf(s_strYear,"%d",li_year );

		if(strcmp(pszShortDate,"MDY") == 0 || strcmp(pszShortDate,"MDR") == 0)
		{
			strcpy(pDate,s_strMonth);
			strcat(pDate, sDateDelim);
			strcat(pDate,s_strDay);
			strcat(pDate, sDateDelim);
			strcat(pDate,s_strYear);
		}
		else if(strcmp(pszShortDate,"DMY") == 0 || strcmp(pszShortDate,"MDR") == 0)
		{
			strcpy(pDate,s_strDay);
			strcat(pDate, sDateDelim);
			strcat(pDate,s_strMonth);
			strcat(pDate, sDateDelim);
			strcat(pDate,s_strYear);
		}
		else if(strcmp(pszShortDate,"YMD") == 0)
		{
			strcpy(pDate,s_strYear);
			strcat(pDate, sDateDelim);
			strcat(pDate,s_strMonth);
			strcat(pDate, sDateDelim);
			strcat(pDate,s_strDay);
		}
		else
		{
			strcpy(pDate,s_strMonth);
			strcat(pDate, sDateDelim);
			strcat(pDate,s_strDay);
			strcat(pDate, sDateDelim);
			strcat(pDate,s_strYear);
		}
	free(s_part1);
	free(s_part2);
	free(s_part3);
	free(pszShortDate);
	return 1;
}

/****************************************************************************
Function Name	: m_time(char *a_sTime,char *pTime,int format)

Arguments	: char	*a_sDate string time /TYP=S/FORMAT=MM/DD/YYYY
				 or /FORMAT = NNNNN
		  char	*pDate	 Number of Days since 12/31/1840
				 or String Date Translation of Mumps
				 Julian Date

Format		: 0: h:mm AM/PM
		  1: hh:mm A/P
		  2: h:mm:ss am/pm 
		  3: h:mm	
		  4: hh:mm:ss

Return		: 0 - Fail
		  1 - SUCCESS

Comments	: This function converts the time which is passed in as a 
		  string in the appropriate time format i.e if the string 
		  that is passed in is a Mumps time format it returns the 
		  PB time in the format specified in argument number two 
		  else if the string passed in is PB time it returns a 
		  Mumps time. 
					
******************************************************************************/
int m_time(char *a_sTime,char *pTime,int format)
{
	long 	l_Mumpsseconds=0, l_hours=0, l_minutes=0, l_seconds=0,
		l_remseconds=0;
	int	b_Pbtime=0, b_Mtime=0;
	char	s_fmtHours[3], s_fmtMin[3], s_fmtSec[3];
	char	*pToken;
	int	HR = 0, MN = 0, SC = 0, julTime;

	if(a_sTime == NULL || a_sTime == "")
		return 0;

	pToken = (char *)strstr(a_sTime, ":");
	if(pToken)
		b_Mtime = 1;

	if(b_Mtime)
	{
		pToken = (char *)strtok(a_sTime,":");
		if(pToken)
			HR = atoi(pToken);
		pToken = (char *)strtok(NULL,":");
		if(pToken)
			MN = atoi(pToken);
		pToken = (char *)strtok(NULL,":");
		if(pToken)
			SC = atoi(pToken);

		julTime = HR * 3600 + MN * 60 + SC;
		
		sprintf(pTime,"%d",julTime);
	}
	else
	{
		l_hours = atol(a_sTime)/3600;
		if (l_hours>24 )
			return 0;
		l_remseconds = (atol( a_sTime ) - (l_hours*3600));
		l_minutes = l_remseconds/60;
		if(l_hours == 24 && l_minutes > 0 )
			return 0;		
		/*If time is greater than 24hrs return a null*/
		l_seconds = (l_remseconds - (l_minutes*60));

		/*If time is greater than 24hrs return*/
		if(l_hours== 24 && l_seconds > 0 )
			return 0;		

		if (atol(a_sTime)==0)
		{				
			/*If the input time is 0 then return 0*/
			l_hours		= 0;
			l_minutes	= 0;
			l_seconds	= 0;
		}
		/*Convert l_hours into string*/
		sprintf(s_fmtHours,	"%02d",	l_hours);	
		/*Convert l_minutes into string*/
		sprintf(s_fmtMin,	"%02d",	l_minutes);	
		/*Convert l_seconds into string*/
		sprintf(s_fmtSec,	"%02d",	l_seconds);	

		switch(format)
		{
		/*Format the return time to h:mm AM/PM format*/
		case 0:
			if(l_hours > 12)
			{
				l_hours = l_hours - 12;
				sprintf(s_fmtHours,	"%02d",	l_hours);
				strcpy(pTime,s_fmtHours);
				strcat(pTime,":");
				strcat(pTime,s_fmtMin);
				strcat(pTime," ");
				strcat(pTime,"PM");
			}
			else
			{
				sprintf(s_fmtHours,	"%02d",	l_hours);
				strcpy(pTime,s_fmtHours);
				strcat(pTime,":");
				strcat(pTime,s_fmtMin);
				strcat(pTime," ");
				strcat(pTime,"AM");
			}
			break;

		case 1:
			/*Format the return time to h:mm A/P format*/
			if( l_hours>12 )
			{
				l_hours = l_hours - 12;
				sprintf(s_fmtHours,	"%02d",	l_hours);
				strcpy(pTime,s_fmtHours);
				strcat(pTime,":");
				strcat(pTime,s_fmtMin);
				strcat(pTime," ");
				strcat(pTime,"P");
			}
			else
			{
				sprintf(s_fmtHours,	"%02d",	l_hours);
				strcpy(pTime,s_fmtHours);
				strcat(pTime,":");
				strcat(pTime,s_fmtMin);
				strcat(pTime," ");
				strcat(pTime,"A");
			}
			break;
		case 2:
			/*Format the return time to hh:mm am/pm format*/
			if(l_hours > 12)
			{
				l_hours = l_hours - 12;
				sprintf(s_fmtHours,	"%02d",	l_hours);
				strcpy(pTime,s_fmtHours);
				strcat(pTime,":");
				strcat(pTime,s_fmtMin);
				strcat(pTime,":");
				strcat(pTime,s_fmtSec);
				strcat(pTime," ");
				strcat(pTime,"PM");
			}
			else
			{
				sprintf(s_fmtHours,	"%02d",	l_hours);
				strcpy(pTime,s_fmtHours);
				strcat(pTime,":");
				strcat(pTime,s_fmtMin);
				strcat(pTime,":");
				strcat(pTime,s_fmtSec);
				strcat(pTime," ");
				strcat(pTime,"AM");
			}
			break;
		case 3:
			/*Format the return time to h:mm format*/
			strcpy(pTime,s_fmtHours);
			strcat(pTime,":");
			strcat(pTime,s_fmtMin);
			break;
		case 4:
			/*Format the return time to h:mm:ss format*/
			strcpy(pTime,s_fmtHours);
			strcat(pTime,":");
			strcat(pTime,s_fmtMin);
			strcat(pTime,":");
			strcat(pTime,s_fmtSec);
			break;
		default:
			break;
		}
	}
	return 1;
}

long FormatColData(char *colType, char *a_sColData, long a_lColData,
			char *a_sOutputColData)
{
	char	szBuf[50],format[50];
	char	*pTime = NULL, *pDate = NULL;
	double	i;
	int	index = 0;

	if( NULL == a_sOutputColData )
	{
		return -1;
	}

	switch(*colType)
	{
		case 'T' :
		case 'U' :
		case 'F' :
		case 'M' :
			strcpy(a_sOutputColData,a_sColData);
			break;

		case 'L' :
			if((strcmp((char *)a_sColData, "0") != 0) && 
					(strcmp((char *)a_sColData,"1") !=0))
			{
				sprintf(a_sColData,"%c",'0');
			}
			strcpy(a_sOutputColData,a_sColData);
			break;

		case 'D' :
			pDate = (char *)calloc(12,1);
			m_date(a_sColData,pDate);
			strcpy(a_sOutputColData,pDate);
			free(pDate);
			break;

		case 'C' :
			pTime = (char *)calloc(12,1);
			m_time(a_sColData,pTime,4);
			strcpy(a_sOutputColData,pTime);
			free(pTime);
			break;

		case '1':
		case '2':
		case '3':
		case '4':
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
		case '0':
		case '$':
			i = atof(a_sColData);
			if(strcmp((char *)colType, "$") == 0)
				strcpy(colType, "2");
			sprintf(format,"%%.%cf",colType[0]);
			sprintf(szBuf,format,i);
			index = 0;
			if(strcmp(sDec,"," ) == 0)
			{
				while(szBuf[index])
				{
					if(szBuf[index] == '.')
						szBuf[index] = ',';
					index++;
				}
			}
			strcpy(a_sOutputColData,szBuf);
			break;

		default:
			break;
	}
	return 1;
}

long FormatCurrentRow(char *a_sCurrentRow, char *a_sColAttrib, 
			char *a_sOutputNewRow)
{
	int	notDone = 1,ulOffset = 0;
	char	*pStart = a_sCurrentRow;
	char	*pEnd;
	char	*colData = NULL,*colDataType = NULL;
	int	ulCurrentCol = 0,index = 0,colLen = 0;
	char	*a_sOutputColData;

	colDataType = (char *)calloc(2,1);

	a_sOutputColData = (char *)calloc(32*1024 + 1,1);
	if(NULL == a_sCurrentRow || NULL == a_sColAttrib )
		return -1;

	pEnd = pStart;
	while (notDone)
	{
		if (NULL == pStart)
		{
			notDone = 0;
			continue;
		}
		if (pEnd[ulOffset] != 0 &&
			pEnd[ulOffset] != '\t')
		{
			ulOffset++;
			continue;
		}
		if (pEnd[ulOffset] == 0)
		{
			if(ulOffset)
				colData = (char *)calloc(ulOffset + 1 ,1);
			else
				colData = (char *)calloc(2 ,1);

			strncpy(colData,pStart,ulOffset);
			sprintf(colDataType,"%c",a_sColAttrib[ulCurrentCol]);
			colLen = strlen(colData);
			if (colLen > 0)
			{
				if(FormatColData(colDataType,colData,strlen(colData),a_sOutputColData))
					strcat(a_sOutputNewRow,a_sOutputColData);
			}
			notDone = 0;
			ulCurrentCol++;
			free(colData);
			continue;
		}
		if (pEnd[ulOffset] == '\t')
		{
			if(ulOffset)
				colData = (char *)calloc(ulOffset + 1 ,1);
			else
				colData = (char *)calloc(2 ,1);
			strncpy(colData,pStart,ulOffset);
			sprintf(colDataType,"%c",a_sColAttrib[ulCurrentCol]);

			if(*colData || *colDataType == 'L')
			{
				if(FormatColData(colDataType,colData,strlen(colData),a_sOutputColData))
				{
					strcat(a_sOutputNewRow,a_sOutputColData);
					strcat(a_sOutputNewRow,"\t");
				}
			}
			else
				strcat(a_sOutputNewRow,"\t");

			pStart = pEnd + ulOffset + 1;
			pEnd = pStart;
			ulOffset = 0;
			ulCurrentCol++;
			free(colData);
		}
	}
	free(colDataType);
	free(a_sOutputColData);
	return 1;
}

