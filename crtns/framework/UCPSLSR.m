 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCPSLSR ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
 ;  #PACKAGE framework.psl
 ;  #OPTION ResultClass ON
 ;
 ; I18N=QUIT
 ; *******************************************************************
 ; * IMPORTANT NOTE:                                                 *
 ; * According to the rules that apply to PSL compiler upgrades,     *
 ; * the generated M routine associated with this procedure must be  *
 ; * checked into StarTeam and released with the procedure whenever  *
 ; * changes are made to this procedure.                             *
 ; *                                                                 *
 ; * The M routine will be loaded to the mrtns directory during      *
 ; * upgrades and will then be removed from that directory as part   *
 ; * of the upgrade process.  Therefore, other than during an        *
 ; * upgrade an mrtns version of this routine should not exist.      *
 ; *                                                                 *
 ; * Keep these comments as single line to ensure they exist in the  *
 ; * generated M code.                                               *
 ; *******************************************************************
 Q 
 ;
 ; ---------------------------------------------------------------------
addCode(sr,code) ; line of code to add
 ;
 S append(sr,$order(append(sr,""),-1)+1)=code
 I $$hasWrap^UCREC4OP(code) D srAdd^UCREC4OP(.sr)
 Q 
 ;
 ; ---------------------------------------------------------------------
addExe(sr,code) ; line of code to add
 ;
 ; Step 1: Replace vsql(nr) by lvn specified in append(sr,-3,nr)
 N y S y=0 N yz
 N v
 ;
 F  S y=$F(code,"vsql(",y) Q:y=0  S yz=$F(code,")",y) Q:yz=0  D
 .	S v=$E(code,y,yz-2)
 .	I '($D(append(sr,-3,v))#2) S append(sr,-3,v)="vsql"_v
 .	S v=append(sr,-3,v)
 .	S code=$E(code,1,y-6)_v_$E(code,yz,1048575)
 .	S y=y-6+$L(v)
 .	Q 
 ;
 ; Step 2: Replace set vsql=line by GOTO
 ;
 N exeSub S exeSub=$get(append(sr,-2,-2),0)+1
 N tagnr
 N taggo
 ;
 I code["S vsql=" D
 .	S taggo=$piece(code,"S vsql=",2)
 .	I ($E(taggo,1,5)="vsql+") S taggo=exeSub++$piece(taggo,"vsql+",2)
 .	S tagnr=taggo+1
 .	S code=$piece(code,"S vsql=")_$$tagGoto(.sr,tagnr)
 .	D tagPatch(.sr,tagnr)
 .	Q 
 I code[",vsql=" D
 .	S taggo=$piece(code,",vsql=",2)
 .	I ($E(taggo,1,5)="vsql+") S taggo=exeSub++$piece(taggo,"vsql+",2)
 .	S tagnr=taggo+1
 .	S code=$piece($piece(code,",vsql="),"S vd")_" "_$$tagGoto(.sr,tagnr)
 .	D tagPatch(.sr,tagnr)
 .	Q 
 ;
 S append(sr,-2,-2)=exeSub
 ;
 I ($D(append(sr,-2,exeSub))#2) S code=$$getTag^UCPSLSR(sr,exeSub)_" "_code
 E  S code=" "_code
 ;
 D addCode^UCPSLSR(sr,code)
 ;
 Q 
 ;
 ; ---------------------------------------------------------------------
getTag(sr,tagnr) ; 
 ;
 Q append(sr,-2)_"a"_tagnr
 ;
 ; ---------------------------------------------------------------------
tagGoto(sr,tagnr) ; 
 ;
 N v S v=$get(append(sr,-2,tagnr))
 I (v="") S v="G "_$$getTag^UCPSLSR(sr,tagnr)
 Q v
 ;
 ; ---------------------------------------------------------------------
tagPatch(sr,tagnr) ; 
 ;
 I ($D(append(sr,-2,tagnr))#2) Q  ; already handled
 ;
 N n S n=$get(append(sr,-2,-2),0)
 I tagnr'>n S n=$order(append(sr,""),-1)-n+tagnr S append(sr,n)=append(sr,-2)_"a"_tagnr_append(sr,n)
 S append(sr,-2,tagnr)=""
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60946^40568^Frans S.C. Witte^12054" ; Signature - LTD^TIME^USER^SIZE
