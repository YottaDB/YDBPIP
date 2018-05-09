DBSCRT8A	;;Display action menu 
	;;Copyright(c)2000 Sanchez Computer Associates, Inc.  All Rights Reserved - 03/15/00 18:47:11 - GRAY
	;     ORIG:  Frank R. Sanchez (2497)
	;     DESC:  Display action menu after screen
	;
	;---- Revision History ------------------------------------------------
	; 07/14/06 - RussellDS - CR22121
	;	     Replaced $A references with $$BSASCII^SQLUTL to ensure
	;	     Unicode compliance.
	;
	; 02/02/2000 - GRAY - 32507
	;	     Removed code no longer needed due to the Elimination of 
	;	     Teller/Character Branch Interface.
	;
	; 03/20/98 - Matt Krystopa - 25985
	;            Modified MENU section by changing the OP variable to be 
	;            vrptopt variable
	; 03/12/98 - Matt Krystopa - 25985
	;            Modified MENU section so OP variable would not new.
	;
	; 10/17/97 - Bob Chiang - 26385
	;            Modified %NEXT section to display NEXT option for screens
	;            compiled with Client/Server compil
	;
	;            Replaced $ZP references with $O.
	;
	; 01/30/97 - Bob Chiang - 23704
	;            Modified %NEXT section to suppress <next> prompt if input 
	;            data is limited to a single page. 
	;
	; 01/28/97 - Bob Chiang - 23623
	;            Modified %PAG0 section to correct an infinite loop
	;            condition.
	;
	; 12/12/95 - SPIER - arq19651
	;            Added reset of I to %O0 section, this prevents an
	;	     invalid table value in DBSMBAR. MENU section changed
	;	     to calulate %PG for repeating screens, due to cursor
	;	     up and down movement, the page number could be inaccurate.
	;
	; 12/06/95 - SPIER - 19651
	;            Modified sections %PAG0,%O0,MENU and %NEXT.
	;	     Changes involved the menu which is displayed for a
	;	     repeating screen. Users needed a NEXT page when %O=0.
	;	     This forced a redefinition of the MBAR used so that
	;	     next is the first option. Other changes basically were
	;	     required to prevent other options from being affected.
	; 01/18/95 - Bob Chiang - 207
	;            Modified EXIT section to set up the correct 'vjrnl' format.
	;
	; 07/26/94 - Steve Canfield - I18N
	;	     Converted msgid from DQnnnn to nnnn.
	;
	; 06/14/94 - Bob Chiang - SCA (OPBS)
	;
	;            Modified to set up default user action (VFMQ variable) in
	;	     batch mode.  The default is F(ile) if currently on the last
	;            page (%PG=%PAGE) or C(ontinue).
	;
	; 04/05/94 - GORMAN - 12622
	;            Disable use of PREV SCREEN option if variable vNOPREV
	;            variable defined.
	;
	; 03/07/94  Bob Chiang - 10572
	;
	;           Modified to not log user action <File,Modify,...> in the
	;           journal file.
	;
	;-----------------------------------------------------------------------
	;
	;-----------------------------------------------------------------------
	;
	S ER=0 S:'$D(%PAGE) %PAGE=1 S:'$D(%PG) %PG=1
	N D,fkterm,RM			
	;
	I $G(%IPMODE)'="" D:$G(%O)>1 ^DBSCRTNL(0,1) I $D(%NOPRMT),$G(vdsp) D YN
	;
	I '$D(%fkey) D ZBINIT^%TRMVT()			; *** BC - Init %fkey() table 09/27/93
	I '$D(vexit) N vexit S vexit="ENT" ;		Last terminator
	I '$D(vkeyb) N vkeyb S vkeyb=1 ;		Default to interactive
	S fkterm="END,ENT,SES,DSP" ;			Menu terminator list
	I $D(vgoto) S fkterm="CUU,"_fkterm
	;
	I vexit["ESC" S X="Q" G %PAG0 ; 		Escape
	I vexit["PUP"!(vexit["PDN") S X=$S(vexit["UP":"P",1:"N") G %PAG0
	;
%PAGE	;
	I $D(%NOPRMT) S X=%NOPRMT K %NOPRMT S:%O>1&(X="") X=$S(%PG=%PAGE:"Q",1:"N") G %PAG0
	I 'vkeyb S X=$S(%PG=%PAGE:"F",1:"C")	; *** BC - 06/14/94 - default batch mode option (Continue or File)
	I vkeyb I $$MENU() G %PAGE ; Display menu option again
	;
	I %fkey="CUU" Q
%PAG0	;
	I X="X" S X="Q"
	I X="C" S X="N"
	I X="O" D SEL I X="" G %PAGE
	I X="Q" X KVAR S VFMQ="Q" G EXIT
	I X="P" G %PAGE:%PG'>1 S X=$O(VPG(%PG),-1) S:X<1 X=%PG-1
	I X="D",%O=3,%PAGE=%PG S VFMQ="D" G EXIT
	I X="M",%O<2 S NI=$P(vexit,"|",2)-1,vexit="" S ER=1 Q
	I X="N",%PG=%PAGE,'($G(%REPEAT)) S X="F" G %PAGE
	I X="F",%O=1,'$D(UX) S X="Q" G %PAG0		; *** 01/28/97
	I X="F",%O=0,%PG<%PAGE,'$G(%REPEAT) S X="Q" G %PAGE   ;12/6/95
	;
	S ER=0 D CHKVR0 Q:ER
	G EXIT
	;
	;----------------------------------------------------------------------
MENU()	; Prompt Menu bar [F]ile  [M]odify ... [Q]uit
	;----------------------------------------------------------------------
	;
	N vrptopt,OPT,MASK,%JRNL,TERM,I,CD,CDPTR        ;MCK 3/12/98, 3/20/98
	; Page ~p1
	I $G(%REPEAT),$G(vrec) S %PG=vrec\%REPEAT+$S(vrec#%REPEAT>0:1,1:0)
	S RM=$S(%PG<1:"",1:$$^MSG(2125,%PG))
	;
	S CDPTR=0
	I %O=0 D %O0
	I %O=1 D %O1
	I %O=2 D %O2
	I %O=3 D %O3
	I %O>3 D %O4
	S CD=$S(CDPTR>0:11,%O<4:%O+10,1:14)	;12/6/95
	S X=$$^DBSMBAR(CD,fkterm,.MASK)
	;
	; ---------- Back to last prompt on the current screen
	;
	I %fkey="CUU" S NI=$$BSASCII^SQLUTL(vgoto,1)-1,vgoto=$E(vgoto,2,999) D DSP^DBSCRT(1) s vexit="",ER=1 Q 0
	I %fkey="SES" D:$$SES^DBSCRT(0) DSP^DBSCRT(0) Q 1
	I %fkey="DSP" D DSP^DBSCRT(1) Q 1
	;
	S vrptopt=X                                                 ;MCK 3/20/98
	I X,$P(OPT(X),"|",2)'="" X $P(OPT(X),"|",2) Q 1
	;
	S X=$S(vrptopt:$E(OPT(vrptopt)),1:"Q"),%fkey="ENT",ZB=13    ;MCK 3/20/98
	Q 0
	;
	;----------------------------------------------------------------------
EXIT	; Clean up screen variables
	;----------------------------------------------------------------------
	;
	;
	I X S %PG=X-1,X="N"			; Page number
	I X="N" S %fkey="PDN",VFMQ=%PG		; Next Page
	E  S VFMQ=X				; User action F,M,Q
	;
	I $D(%JRNL),VFMQ'="Q",$G(%MAX) D
	.	S $P(vjrnl,"|",%MAX)=$P($G(vjrnl),"|",%MAX)	; *** 01/18/95  BC
	.	S %JRNL=%JRNL+1,%JRNL(%JRNL)=$g(vjrnl)
	;
	I $D(vjrnlcmd) D @vjrnlcmd		; Journal post-processor
	;
	K VSCRPP,vtab				; Patched FRS 02/23/93
	;
	I $D(vkill) K @("vkill"_vkill)		; Clean up variables
	;
	I "QF"[VFMQ DO
	.	K %MOD,%SCR,%PAGE,%PG,%MAXPG,%NOPRMT,%MAXREQ,%MODS,%REPREQ
	.	I VFMQ="Q" K %JRNL
	Q
	;
	;----------------------------------------------------------------------
%O0	; %O=0 - Build menu selections for a new record
	; ^STBL("MBAR",10) is option list
	;----------------------------------------------------------------------
	;
	F I=1:1:7 S MASK(I)=""
	S I=0
	I %PG=%PAGE&($G(%REPEAT)<2!($G(%TAB)="")) D %FILE(1),%PREV(4),%MODIFY(5),%PRINT(6),%QUIT(7) Q ;File if on last page
	I $G(%REPEAT)'>1!($G(%TAB)="") D %NEXT(2),%PREV(4),%MODIFY(5),%PRINT(6),%QUIT(7) Q   ;;12/6/95
	;
	; Change to menu option 11 for repeating screens  ;12/6/95
	;
	F I=8:1:9 S MASK(I)=""
	S I=0,CDPTR=1			;CDPTR indicates we will use menu 11
	D %NEXT(1)
	I $G(%REPEAT) D %FILE(5)
	D %PREV(3),%MODIFY(6),%PRINT(8),%QUIT(9)
	Q
	;----------------------------------------------------------------------
%O1	; %O=1 - Build menu selections for modify record
	; ^STBL("MBAR",11) is option list
	;----------------------------------------------------------------------
	;
	F I=1:1:9 S MASK(I)=""
	S I=0
	;  of ~p1
	I %PG'<1 S RM=RM_$$^MSG(18,%PAGE)
	D %NEXT(1),%PREV(3),%OTHER(4) ;    	NEXT  PREV  OTHER
	I $D(UX),%PG'<1 D %FILE(5) ; 	FILE  (If changes were made to data)
	D %MODIFY(6),%BROWSE(7),%PRINT(8),%QUIT(9)
	Q
	;
	;----------------------------------------------------------------------
%O2	; %O=2 - Build menu selections for display record
	; ^STBL("MBAR",12) is option list
	;----------------------------------------------------------------------
	;
	F I=1:1:7 S MASK(I)=""
	S I=0
	;  of ~p1
	; End of report 
	I %PG'<1 S RM=RM_$$^MSG(18,%PAGE) I %PG=%PAGE S RM=RM_", "_$$^MSG(30) 
	D %NEXT(1),%PREV(3),%OTHER(4),%QUIT(5),%BROWSE(6),%PRINT(7)
	Q
	;
	;----------------------------------------------------------------------
%O3	; %O=3 - Build menu selections for delete record
	; ^STBL("MBAR",13) is option list
	;----------------------------------------------------------------------
	;
	F I=1:1:8 S MASK(I)=""
	S I=0
	;  of ~p1
	I %PG'<1 S RM=RM_$$^MSG(18,%PAGE)
	D %NEXT(1),%PREV(3),%OTHER(4),%QUIT(5),%DELETE(6),%BROWSE(7),%PRINT(8)
	Q
	;
	;----------------------------------------------------------------------
%O4	; %O>3 - Build menu selections for display record
	; ^STBL("MBAR",14) is option list
	;----------------------------------------------------------------------
	;
	F I=1,2 S MASK(I)=""
	S I=0
	;  of ~p1
	; , End of report 
	I %PG'<1 S RM=RM_$$^MSG(18,%PAGE) I %PG=%PAGE S RM=RM_$$^MSG(30) 
	D %QUIT(1),%PRINT(2)
	Q
	;
	;----------------------------------------------------------------------
	; Build Function key terminator list
	;----------------------------------------------------------------------
FKTERM(TERM,OP)	S fkterm(TERM)=OP I fkterm'[TERM s fkterm=fkterm_","_TERM
	Q
	;
CHKVR0	;
	N X
	I $G(VSCRPP),$G(PGM)'="" K VSNI D VSPP^@PGM I ER G ERROR
	Q
	;
	;----------------------------------------------------------------------
SEL	; Select from a list of pages
	;----------------------------------------------------------------------
	;
	N PGM,SID,OPT
	;
	I $D(VPG)<10!(%PG<1) S X="" Q
	S SID=$P(VPG(%PG),"|",2)
	I SID'="" D ^USID I PGM="" S X="" Q
	;
	S OPT=%O N %O,VPT,E67
	;
	S VPT=23-($O(VPG(""),-1)+1\2),E67=3
	S X=$$^DBSTBL("VPG(","","N","","",.VPT),%O=OPT
SEL1	;
	I X="" D DSP Q
	I OPT=0 S:'$D(%MAXPG) %MAXPG=1 S:%PG>%MAXPG %MAXPG=%PG
	I OPT=0,X,X-1>%MAXPG S X="" D DSP Q
	;
	I X,X=+X D CHKVR0 I ER S X="" D DSP Q
	I X>%PAGE!(%PG<1) S X="" D DSP Q
	S %PG=X-1,VFMQ=%PG
	Q
	;
DSP	;
	I $G(PGM)="" Q
	D DSP^DBSCRT(VPT) Q
	;
	;----------------------------------------------------------------------
ERROR	; Display error
	;----------------------------------------------------------------------
	;
	I '$D(RM) Q  ; error condition without message ??
	I $G(RM)="" S RM=$O(RM(""),-1),RM=$G(RM(RM)) ; Use last error message
	;
	I vkeyb=0 S VFMQ="Q" Q				; Quit in Batch **FRS
	;
	W $$MSG^%TRMVT(RM,1)				; Error Message
	S vexit="" K RM
	I NI>%MAX S NI=0 Q
	S NI=NI-1 Q
	;
YN	;
	N %IPMODE,%JRNL,vkeyb
	; End of Script
	I %NOPRMT="X" W $$MSG^%TRMVT($$^MSG(892),"",1) Q
	;
	;-----------------------------------------------------------------------
	; ^STBL("MBAR",15) is option list
	;  VAR array contains variable to append to option
	;-----------------------------------------------------------------------
	N I,MASK
	F I=1:1:4 S (MASK(I),VAR(I))=""
	S VAR(4)=%NOPRMT
	K MASK($S($F("NFP",%NOPRMT):$F("NFP",%NOPRMT)-1,1:4))
	S OP=$$^DBSMBAR(15,"",.MASK,"",.VAR) I OP=""!(OP=5) S %NOPRMT="Q"
	Q
	;
%BROWSE(OP)	I '$D(VO) Q
	S OPT(OP)="Browse|S X=$$^SCACLPBD($G(NI),.%TAB,.VO,0)",I=I+1 D FKTERM("MNU",I) K MASK(OP)
	Q
%CALC(OP)	S OPT(OP)="Calculator|D FUNCTION^DBSCALC",I=I+1 K MASK(OP) Q
%FILE(OP)	K MASK(OP) S OPT(OP)="File|",I=I+1 D FKTERM("END",I) Q
%MODIFY(OP)	I '$D(%TAB) Q
	S OPT(OP)="Modify|",I=I+1 K MASK(OP) Q
	;
	; ---------- PREV only for DQ generated linked screen (VPG array)
	;
%PREV(OP)	I '$D(vNOPREV)&(%PG>1)&($O(VPG(""))<%PG) S OPT(OP)="Previous|",I=I+1 D FKTERM("PUP",I) K MASK(OP)
	Q
%OTHER(OP)	I '$D(vNOPREV)&(%PAGE>1)&($O(VPG(""))) S OPT(OP)="Other|",I=I+1 D FKTERM("SEL",I)  K MASK(OP)
	Q
%PRINT(OP)	I $D(VO) S OPT(OP)="Print_Screen|D ^DBSCRT8D",I=I+1 D FKTERM("PRN",I) K MASK(OP)
	Q
%QUIT(OP)	S OPT(OP)="Quit|",I=I+1 K MASK(OP) Q
%DELETE(OP)	S OPT(OP)="Delete|",I=I+1 K MASK(OP) Q
	;
	; ---------- VPG() array not required for access NEXT option
	; set up page number to -1 to force CONTINUE option
	;
%NEXT(OP);	
	I %PG<1,$G(%PAGE)'=%PG,($G(%REPEAT)=""!($G(%REPEAT)=1)) S OPT(OP)="Continue|",I=I+1 D FKTERM("PDN",I) K MASK(OP) Q
	I $G(%REPEAT),$G(%TAB)'="",$P(%TAB,"|",2)+(%REPEAT*$P(%TAB,"|",4))<21 Q  ; C/S screen mode *** 10/17/97
	I $G(%REPEAT),$G(%TAB)="",%PG=%PAGE Q
	I $G(%REPEAT)!(%PAGE>1&(%PG<%PAGE)) S OPT(OP+1)="Next|",I=I+1 D FKTERM("PDN",I) K MASK(OP+1)
	Q
