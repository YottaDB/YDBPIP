%FSEL	;M Utility;SCA - UTL - V4.0 - SCA file select into a local array
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 04/28/94 15:34:52 - SYSRUSSELL
	; ORIG:  RUSSELL -  11 Dec 1990
	;
	; Allows selection of a list of files from a specified directory.
	;
	; Entry from top will prompt for directory and file name(s).
	;
	; Entry at EXT is call by S X=$$EXT^%FSEL(dir,file,.array) to return 
	; selected file(s) in array.  Return 1 if success, i.e., found at 
	; least one file, otherwise returns 0.
	;
	; KEYWORDS:	File handling
	;
	; RETURNS:
	;	. %ZF			Count		/TYP=N
	;
	;	. %ZF(file_name		File name	/TYP=T
	;
	;	. %ZF(file_name)	null
	;
	n (%ZF)
	n $zt s %ZL=$zl,$ZT="zg %ZL:ERR^%FSEL"
	s dir=$$CURR^%DIR
ask	s dir=$$PROMPT^%READ("Directory:  ",dir) W ! q:dir=""
	s X=dir d ^%ZCHKDIR i $g(ER) w "Invalid directory" g ask
	i "]:"'[$e(dir,$l(dir)) s dir=dir_":"
	u "":(ctrap=$c(3):exc="zg %ZL:LOOP^%FSEL")
	s cnt=0,out=1
	d main
	u "":(ctrap="":exc="")
	q
	;
	;----------------------------------------------------------------------
EXT(dir,file,%ZF)	;System;External call to validate and/or return selected file
	;----------------------------------------------------------------------
	;
	; KEYWORDS:	File handling
	;
	; ARGUMENTS:
	;	. dir			Directory	/TYP=T/MECH=VAL:R
	;
	;	. file			File name	/TYP=T/MECH=VAL:R
	;
	;	. %ZF			Return count	/TYP=N/MECH=REF:W
	;
	;	. %ZF(file_name		File name	/TYP=T
	;
	;	. %ZF(file_name)	null
	;
	; EXAMPLE:
	;	S X=$$EXT^%FSEL(dir,file,.array)
	;
	n (dir,file,%ZF)
	i '$d(dir)!($g(file)="") q 0 ; No parameters passed
	s X=dir d ^%ZCHKDIR i $g(ER) q 0 ; Invalid directory
	i "]:"'[$e(dir,$l(dir)) s dir=dir_":"
	s (cnt,out)=0
	d setup,it
	i 'cnt q 0 ; No files selected
	q 1
	;
main	f  d inter q:file=""
	s %ZF=cnt
	q
	;
inter	S file=$$PROMPT^%READ("File:  ","") W ! q:file=""
	i $e(file)="?" d help q
	d setup,it k r
	w !,"Current total of ",cnt," file",$s(cnt=1:".",1:"s."),!
	q
setup	i $e(file)="'" s add=0,r=$e(file,2,999)
	e  s add=1,r=file
	i r'["." s r=r_".*"
	q
	;
it	s search=dir_r
	f  s r=$zsearch(search) q:'$l(r)  d save
	q
	;
save	;
	i add,'$d(%ZF(r)) s %ZF(r)="",cnt=cnt+1 d prt:out
	i 'add,$d(%ZF(r)) k %ZF(r) s cnt=cnt-1 d prt:out
	q
prt	w:$x>55 ! w $p(r,"]",2),?$x\25+1*25
	q
help	i $e(file)="?","Dd"[$e(file,2) d cur q
	w !,"<RET> to leave",!,"* for all",!,"file_name for 1 file"
	w !,"* as wildcard permitting any number of characters"
	w !,"% as a single character wildcard in any position"
	w !,"' as the 1st character to remove files from the list"
	w !,"?D for the currently selected files"
	q
cur	w ! s r="" 
	f  s r=$o(%ZF(r)) q:'$l(r)  w:$x>55 ! w $p(r,"]",2),?$x\25+1*25
	q
ERR	u "" w !,$p($ZS,",",2,999),!
	u "":(ctrap="":exc="")
	q
LOOP	d main
	u "":(ctrap="":exc="")
	q
