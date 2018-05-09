 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSEDIT ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSEDIT(opt,fid,sel,nu1,nu2,frame) ; 
 ;
 ; I18N=QUIT
 ;
  S ER=0
 ;
 N isDone N vDFLAG N vRFLAG
 N I N vDESLEN
 N %RECORD N keys N poke N predaen N syssn N vFSN N vGLOB N VREC N X
 ;
 S RM=""
 ;
 I (%UID="") D  Q 
 .	S ER=1
 .	; Must be a user
 .	S RM=$$^MSG(2849)
 .	WRITE $$MSG^%TRMVT(RM,0,1)
 .	Q 
 ;
 Q:($get(fid)="")  ; Required
 ;
 S opt=$get(opt)
 I ($get(sel)="") S sel="*"
 ;
 S vDESLEN=0 ; the max length of prompts
 D fsn^DBSDD(.vFSN,fid) Q:ER 
 ;
 S X=vFSN(fid)
 ;
 I (+$piece(X,"|",4)=0) D  Q 
 .	S ER=1
 .	; Record Type '0' Contains no Records
 .	S RM=$$^MSG(2339)
 .	Q 
 ;
 S keys=$piece(X,"|",3)
 I (keys="") D  Q 
 .	S ER=1
 .	; Invalid file structure
 .	S RM=$$^MSG(5531)
 .	Q 
 ;
 S vGLOB=$piece($piece(X,"|",2),"(",1)
 S vGLOB=$E(vGLOB,2,1048575)
 ;
 N dbtbl1 S dbtbl1=$$vRCgetRecord0^RecordDBTBL1("SYSDEV",fid,0)
  S vobj(dbtbl1,10)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),10))
  S vobj(dbtbl1,22)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),22))
 ;
 I ((vGLOB="UTBL")!(vGLOB="STBL")!(vGLOB="CTBL")) D  K:ER vobj(+$G(dbtbl1)) Q:ER 
 .	;
 .	N mode
 .	;
 .	I opt=3 S mode=3
 .	E  S mode=0
 .	;
 .	D CHKACCES^DBSTBLM(vGLOB,.dbtbl1,mode)
 .	 S:'$D(vobj(dbtbl1,10)) vobj(dbtbl1,10)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),10)),1:"")
 .	 S:'$D(vobj(dbtbl1,22)) vobj(dbtbl1,22)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),22)),1:"")
 .	Q 
 ;
 I ($P(vobj(dbtbl1,10),$C(124),12)=5) D  K vobj(+$G(dbtbl1)) Q  ; Dummy file type
 .	S ER=1
 .	; Invalid file structure
 .	S RM=$$^MSG(5531)
 .	Q 
 ;
 S syssn=$P(vobj(dbtbl1,10),$C(124),2) ; System name
 I (syssn'=$get(%SN)) D  K:ER vobj(+$G(dbtbl1)) Q:ER  ; Change system
 .	S %SN=syssn
 .	D %SN^SCADRV0
 .	Q 
 ;
 S predaen=$P(vobj(dbtbl1,22),$C(124),5) ; Data entry Pre-Processor
 S vRFLAG=$P(vobj(dbtbl1,22),$C(124),9) ; Restriction flag
 S vDFLAG=$P(vobj(dbtbl1,22),$C(124),10) ; deletion restriction flag
 ;
 I (opt'=2),vRFLAG D  K vobj(+$G(dbtbl1)) Q 
 .	S ER=1
 .	; File ~p1 is restricted
 .	S RM=$$^MSG(5634,fid)
 .	Q 
 ;
 I (opt=3),vDFLAG D  K vobj(+$G(dbtbl1)) Q 
 .	S ER=1
 .	; Deletion is restricted
 .	S RM=$$^MSG(806)
 .	Q 
 ;
 ;  #ACCEPT DATE=12/27/04; PGM=Dan Russell; CR=Unknown; GROUP=XECUTE,Deprecated
 I '(predaen="") XECUTE predaen K:ER vobj(+$G(dbtbl1)) Q:ER  ; Data Entry Pre-Proc
 ;
 ; Process wildcard
 I (sel="*") S sel=$$GETLIST^DBE(fid) K:ER vobj(+$G(dbtbl1)) Q:ER 
 ;
 ; Make sure keys are at front of select list, in order
 F I=1:1:$L(keys,",") D  ; Build Key Post Proc
 .	;
 .	N isLast
 .	N key
 .	;
 .	I (I=$L(keys,",")) S isLast=1
 .	E  S isLast=0
 .	S key=$piece(keys,",",I) ; Retrieve access key
 .	D BLDKEY(fid,key,I,opt,.poke,isLast) ; Build access key info
 .	;
 .	; Remove from select list if in it
 .	I ((","_sel_",")[(","_key_",")) D
 ..		S sel=","_sel_","
 ..		S sel=$$vStrRep(sel,","_key_",",",",0,0,"")
 ..		S sel=$E(sel,2,$L(sel)-1)
 ..		Q 
 .	Q 
 ;
 ; Add key(s) to select list
 S sel=keys_","_sel
 I ($E(sel,$L(sel))=",") S sel=$E(sel,1,$L(sel)-1)
 ;
 S %RECORD="VREC"
 S VREC="" ; Init record
 S isDone=0
 F  D  Q:isDone 
 .	;
 .	N UX
 .	;
 .	D TOP(.isDone) Q:isDone 
 .	I ER S VREC="" Q  ; Reset screen on error
 .	;
 .	; Continue?
 .	I '$$YN^DBSMBAR("",$$^MSG(5652,$get(RM),"Continue?"),1) D  Q 
 ..		S isDone=1
 ..		S RM=""
 ..		Q 
 .	;
 .	S ER=0
 .	S RM=""
 .	;
 .	I (%O=3) S VREC="" ; Reset screen when deleting a record
 .	Q 
 ;
 K vobj(+$G(dbtbl1)) Q 
 ;
TOP(DONE) ; Main routine
 ;
 N isDone N log
 N %PAGE N %PG N end N I N opttmp N start
 N fiddes N VFMQ N VPG
 ;
 N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=fid,dbtbl1=$$vRCgetRecord0Opt^RecordDBTBL1("SYSDEV",fid,0,"")
  S vop3=$G(^DBTBL(vop1,1,vop2,100))
 ;
 S DONE=0 ; Flag if quit out of screen
 ;
 S fiddes=$P(dbtbl1,$C(124),1)
 S log=$P(vop3,$C(124),5)
 ;
 ; Calculate number of pages
 S %PAGE=(($L(sel,",")-1)\17)+1
 S %PG=1
 ;
 I (%PAGE>1) F I=1:1:%PAGE D  ; Create Page Index
 .	;
 .	N di
 .	;
 .	S di=$piece(sel,",",((I-1)*17)+1)
 .	;
 .	N dbtbl1d S dbtbl1d=$$vRCgetRecord0Opt^RecordDBTBL1D("SYSDEV",fid,di,0,"")
 .	;
 .	S VPG(I)=$P(dbtbl1d,$C(124),10)
 . Q 
 ;
 S %O=0
 ;
 S VFMQ=""
 ;
 S isDone=0
 F  D  Q:isDone 
 .	;
 .	N %FRAME N %MAX N %VERSN N cnt N key N OLNTB
 .	N %READ N %TAB N DBSEDIT N KVAR N msgend N msghdr N PGM
 .	;
 .	S %MAX=0
 .	S KVAR="K %VERSN"
 .	S %VERSN=4
 .	S PGM=$T(+0)
 .	;
 .	S cnt=$L(sel,",")
 .	;
 .	I (%PG=1) D
 ..		S start=1
 ..		I (opt="") S end=16
 ..		E  S end=17
 ..		I (end>cnt) S end=cnt
 ..		Q 
 .	;
 .	E  I (%PG=2) D
 ..		S start=end+1
 ..		S end=start+16
 ..		I (end>cnt) S end=cnt
 ..		Q 
 .	;
 .	E  D
 ..		S start=((%PG-1)*17)+1
 ..		S end=start+16
 ..		I (end>cnt) S end=cnt
 ..		Q 
 .	;
 .	S msghdr="["_fid_"] " ; file name
 .	S msghdr=msghdr_" "_fiddes
 .	; Page ~p1 of ~p2
 .	I (%PAGE>1) S msgend=$$^MSG(2127,%PG,%PAGE)
 .	E  S msgend=""
 .	S msghdr=msghdr_$J(msgend,(80-$L(msghdr)))
 .	;
 .	S %READ="@msghdr/REV/CEN,"
 .	;
 .	F key=start:1:end D BUILD(key) ; Build VO,%TAB
 .	;
 .	I ($D(frame)#2) S %FRAME=2 ; check frame
 .	;
 .	I (vDESLEN>30) S OLNTB=vDESLEN ; Adjust the positions of prompts
 .	E  S OLNTB=30
 .	;
 .	I (%PG'=1),(%O=3) D DEL^UTLREAD ; deletion in multiple pages
 .	E  D
 ..		I (opt'=2) D ^UTLREAD ; create screen
 ..		E  D INQ^UTLREAD ; inquiry mode
 ..		Q 
 .	;
 .	; Action
 .	I ($D(opttmp)#2) S %O=opttmp
 .	E  S %O=opt
 .	;
 .	I (VFMQ="Q"),(%O'=2) D  Q  ; User terminated
 ..		; not Created,not Modified,not Displayed,not Deleted,not Printed
 ..		S RM=$$^MSG(8259)
 ..		S RM=$piece(RM,",",%O+1)
 ..		S (DONE,isDone)=1
 ..		Q 
 .	;
 .	I ((VFMQ="D")!(VFMQ="F")) D  Q  ; File Record
 ..		;
 ..		N cmperr N keylist N PGM N pslcode N TAB
 ..		;
 ..		; Generate filer routine
 ..		S PGM="TMP"_$piece(($J/10000),".",2)
 ..		;
 ..		S TAB=$char(9)
 ..		;
 ..		D addcode(0,PGM_TAB_"// DBSEDIT temporary filer compiled program")
 ..		D addcode(1,"// Last compiled:  "_$$vdat2str($P($H,",",1),"MM/DD/YEAR")_" "_$$TIM^%ZM_" - "_$$USERNAM^%ZFUNC)
 ..		D addcode(0,"")
 ..		D addcode(1,"// THIS IS A COMPILED ROUTINE.  Compiled by procedure DBSEDIT")
 ..		D addcode(0,"")
 ..		;
 ..		; Prevent accidental execution by other than this process
 ..		D addcode(1,"quit:(%ProcessID '= "_$J_")")
 ..		;
 ..		S keylist=""
 ..		F I=1:1:$L(keys,",") S keylist=keylist_$piece(keys,",",I)_"="""""_$piece(VREC,"|",I)_""""","
 ..		;
 ..		S keylist=$E(keylist,1,$L(keylist)-1)
 ..		;
 ..		I (log!(VFMQ="F")) D addcode(1,"type Record"_fid_" rec = Db.getRecord("""_fid_""","""_keylist_""",1)")
 ..		;
 ..		I VFMQ="F" D
 ...			D addcode(1,"do rec.setAuditFlag(1)")
 ...			F I=$L(keys,",")+1:1:$L(sel,",") D addcode(1,"set rec."_$piece(sel,",",I)_" = """_$piece(VREC,"|",I)_"""")
 ...			D addcode(1,"do rec.save()")
 ...			Q 
 ..		E  D
 ...			S keylist=$$vStrRep(keylist,","," AND ",0,0,"")
 ...			S keylist=$$vStrRep(keylist,"""""","'",0,0,"") ; Need single quotes for Db.delete
 ...			D addcode(1,"do Db.delete("""_fid_""","""_keylist_""")")
 ...			Q 
 ..		;
 ..		D addcode(1,"quit")
 ..		; Lock to ensure no conflict
 ..		L +DBSEDIT(PGM):5
 ..		E  D  Q 
 ...			S ER=1
 ...			S RM="Unable to generate temporary filer "_PGM
 ...			Q 
 ..		;
 ..		; Build compiled routine
 ..		;do BUILDRTN^UCGM(.pslcode, PGM, .CMPERR)
 ..		S cmperr=$$cmpA2F^PSLC(.pslcode,,PGM,.cmperr,"")
 ..		I (cmperr>0) D
 ...			S ER=1
 ...			S RM="Unable to generate temporary filer "_PGM
 ...			Q 
 ..		;
 ..		I 'ER D
 ...			;
 ...			N savepnt
 ...			;
 ...		  S savepnt=$TL TS (vobj):transactionid="CS"
 ...			;
 ...			; Call the temporary filer
 ...			D
 ....				;
 ....				N $ET,$ES,$ZYER S $ZYER="ZE^UCGMR",$ZE="",$EC="",$ET="D:$TL>"_$TL_" rollback^vRuntime("_$TL_") Q:$Q&$ES """" Q:$ES  N voxMrk s voxMrk="_+$O(vobj(""),-1)_" G vCatch1^"_$T(+0)
 ....				;
 ....				D @("^"_PGM)
 ....				Q 
 ...			;
 ...			I 'ER D
 ....				;
 ....			  TC:$TL 
 ....				;
 ....				; Created,Modified,Displayed,Deleted,Printed
 ....				S RM=$$^MSG(648)
 ....				S RM=$piece(RM,",",%O+1)
 ....				Q 
 ...			E   TRO:$TL>savepnt savepnt
 ...			Q 
 ..		;
 ..		S isDone=1
 ..		L -DBSEDIT(PGM)
 ..		Q 
 .	;
 .	S %PG=%PG+1 ; Next page
 .	Q 
 ;
 Q 
 ;
BLDKEY(fid,key,cnt,opt,poke,isLast) ; Is last key
 ;
 N tbl
 ;
 N dbtbl1d S dbtbl1d=$$vRCgetRecord0Opt^RecordDBTBL1D("SYSDEV",fid,key,0,"")
 ;
 S poke(cnt,6)="do PPK^DBSEDIT("_cnt_")" ; post-processor
 ;
 I '($P(dbtbl1d,$C(124),5)="") S tbl=$P(dbtbl1d,$C(124),5)
 E  I cnt=$L(keys,",") S tbl="["_fid_"]" ; Look-up table at bottom
 E  S tbl="["_fid_"]"_key_":DISTINCT"
 ;
 I (+opt=0),($P(dbtbl1d,$C(124),5)="") S tbl=tbl_":NOVAL"
 S poke(cnt,4)=$S(tbl'["""":""""_tbl_"""",1:$$QADD^%ZS(tbl,""""))
 ;
 Q 
 ;
BUILD(pos) ; Position
 ;
 N DI N xpo
 ;
 S DI=$piece(sel,",",pos)
 ;
 N dbtbl1d S dbtbl1d=$$vRCgetRecord0Opt^RecordDBTBL1D("SYSDEV",fid,DI,0,"")
 ;
 S xpo=$P(dbtbl1d,$C(124),30)
 ;
 S $piece(VDFT,"|",pos)=$P(dbtbl1d,$C(124),3) ; Default values
 ;
 I ($L($P(dbtbl1d,$C(124),10))>(vDESLEN-3)) S vDESLEN=$L($P(dbtbl1d,$C(124),10))+3
 ;
 S %READ=%READ_",["_fid_"]"_$piece(sel,",",pos)_"/POS="_pos
 I ($D(prot(pos))#2) S %READ=%READ_"/PRO" Q 
 ;
 I (opt>1),(%PG>1) S %READ=%READ_"/PRO" Q 
 I (opt>1),(pos>$L(keys,",")) S %READ=%READ_"/NOREQ" Q 
 I (opt>1),(pos=$L(keys,",")) S xpo="do GOTO^DBSMACRO(""END"")"
 ;
 I '($get(poke(pos,4))="") S %READ=%READ_"/TBL="_poke(pos,4)
 E  I '($P(dbtbl1d,$C(124),5)="") S %READ=%READ_"/TBL="_$$QADD^%ZS($P(dbtbl1d,$C(124),5),"""")
 ;
 I '($P(dbtbl1d,$C(124),29)="") S %READ=%READ_"/XPR="_$$QADD^%ZS($P(dbtbl1d,$C(124),29),"""")
 ;
 I ($D(poke(pos,6))#2) D
 .	;
 .	I (xpo="") S xpo=poke(pos,6)
 .	E  I '(xpo["I ") S xpo=xpo_" I 'ER "_poke(pos,6)
 .	E  S xpo=poke(pos,6)_" "_xpo
 .	Q 
 ;
 I '(xpo="") S %READ=%READ_"/XPP="_$S(xpo'["""":""""_xpo_"""",1:$$QADD^%ZS(xpo,""""))
 ;
 I (opt=""),(pos=$L(keys,",")) D  ; Delete prompt
 .	;
 .	S %READ=%READ_",,.FUN34/NOREQ/XPP=D DELETE^DBSEDIT/VAR=vDELETE,"
 .	S vDELETE="N"
 .	Q 
 ;
 Q 
 ;
DELETE ; post processor for "delete" field
 ;
 N global
 ;
 Q:vprotdi 
 ;
 S %O=opt ; get access mode
 S ER=0 ; initialize error signal
 I X=1 D  Q:ER  ; deletion mode
 .	;
 .	I vDFLAG D
 ..		S ER=1
 ..		; Deletion is restricted
 ..		S RM=$$^MSG(806)
 ..		Q 
 .	;
 .	S %O=3
 .	S opttmp=3 ; set access mode
 .	;
 .	N dbtbl1 S dbtbl1=$$vRCgetRecord0^RecordDBTBL1("SYSDEV",fid,0)
 .	 S vobj(dbtbl1,0)=$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),0))
 .	;
 .	S global=$P(vobj(dbtbl1,0),$C(124),1)
 .	I ((global="CTBL")!(global="UTBL")) D CHKACCES^DBSTBLM(global,.dbtbl1,3)
 .	;
 .	I 'ER D GOTO^DBSMACRO("END") ; go to the bottom of the screen
 .	I ER S X="N"
 .	K vobj(+$G(dbtbl1)) Q 
 ;
 I (+X=0),(opt'=2) S (%O,opttmp)=1 ; set modify mode
 I (opt=2) D GOTO^DBSMACRO("END") Q  ; inquiry mode
 ;
 I (%O=0) S I(3)="" ; Remove table lookup
 ;
 ; Create,Modify,Display,Delete,Print ... Record
 S RM=$$^MSG(647)
 S RM=$piece(RM,",",%O+1)_" "_$$^MSG(2326)
 ;
 I (%PAGE=1),((opt=2)!(opt=5)) D
 .	S vni=vni-1 ; Stay on bottom key
 .	S %O=0
 .	Q 
 ;
 Q 
 ;
PPK(keylvl) ; Key level
 ;
 N I N keycnt
 ;
 I (X=""),(+opt=0),(E8="L") S X=0 ; Treat null logical as zero
 ;
 Q:(X="") 
 I (E8="N"),(X'?.N) S ER=1 S RM="Data type defined as numeric" Q 
 S keycnt=$L(keys,",") ; Total Number of keys
 ;
 S X=$$vStrTrim(X,0," ")
 ;
 ; Assign keyname variable the value
 S @$piece(keys,",",keylvl)=X
 ;
 S $piece(VREC,"|",keylvl)=X ; Assign to key value array
 ;
 ; If next to last key, modify table reference for last key
 I (keylvl+1=keycnt) D
 .	;
 .	N I
 .	N query N tbl N z
 .	;
 .	S z=$get(%TAB(NI+1))
 .	Q:(z="")  ; No next %TAB entry
 .	;
 .	S tbl=$piece($piece(z,"|",4),":Q",1)
 .	Q:'$$vStrLike(tbl,"%["_fid_"]%","") 
 .	;
 .	S query=""
 .	F I=1:1:keylvl S query=query_$piece(keys,",",I)_"="""_$piece(VREC,"|",I)_""" AND "
 .	;
 .	S $piece(%TAB(NI+1),"|",4)=tbl_":QU """_$E(query,1,$L(query)-5)_""""
 .	Q 
 ;
 S vprotdi=0
 ;
 ; Bottom key
 I (keylvl=keycnt) D  S V=X Q 
 .	;
 .	N defined N isDifferent
 .	N I
 .	N acc N row
 .	;
 .	S acc=""
 .	S isDifferent=0
 .	I X'=V S isDifferent=1
 .	;
 .	F I=1:1:$L(keys,",") S $piece(acc,"|",I)=$piece(VREC,"|",I)
 .	;
 .	S defined=$$EXIST(fid,acc,124,,sel,.row)
 .	;
 .	I defined,(opt=0) D  Q 
 ..		S ER=1
 ..		; Record in file
 ..		S RM=$$^MSG(5651)
 ..		Q 
 .	;
 .	I 'defined,(opt>0) D  Q 
 ..		S ER=1
 ..		; Record not in file
 ..		S RM=$$^MSG(5521)
 ..		Q 
 .	;
 .	I defined,isDifferent S VREC=$translate(row,$char(9),"|")
 .	;
 .	; Otherwise, create VREC with key values and default values
 .	E  I isDifferent D
 ..		;set VREC = ""
 ..		;for I = 1:1:keycnt set VREC.piece("|", I) = vkey(I)
 ..		;
 ..		F I=keycnt+1:1:$L(VDFT,"|") D
 ...			N dft S dft=$piece(VDFT,"|",I)
 ...			;
 ...			Q:(dft="") 
 ...			;
 ...			I dft?1"<<".E1">>" D
 ....				S dft=$E(dft,3,$L(dft)-2)
 ....				;
 ....				I ($E($ZCONVERT(dft,"U"),1,6)="CUVAR.") D
 .....					;
 .....					N X S X=$ZCONVERT($piece(dft,".",2),"L")
 .....					;
 .....					N cuvar S cuvar=$$vRCgetRecord0^RecordCUVAR(0)
 .....					;
 .....					S dft=$$propGet^DBSDYNRA(cuvar,X)
 .....					K vobj(+$G(cuvar)) Q 
 ....				E  D
 .....					;       #ACCEPT DATE=12/27/04; PGM=Dan Russell; CR=unknown
 .....					XECUTE "set dft="_dft
 .....					Q 
 ....				Q 
 ...			S $piece(VREC,"|",I)=dft
 ...			Q 
 ..		Q 
 .	;
 .	D VDA^UTLREAD ; Update Screen Image
 .	D ^DBSPNT(1) ; Display Screen Image
 .	;
 .	I (opt=3) D  Q 
 ..		S %O=3
 ..		D GOTO^DBSMACRO("END")
 ..		Q 
 .	;
 .	Q:(opt>0) 
 .	;
 .	I 'defined D  ; Not in database
 ..		;
 ..		S opttmp=0
 ..		S %O=0
 ..		;do vinit^DBSFILER(fid)
 ..		D PROTECT^DBSMACRO("@vDELETE") ; protect the delete field
 ..		S vprotdi=1
 ..		;
 ..		; Create,Modify,Display,Delete,Print
 ..		S RM=$$^MSG(647)
 ..		;  Record
 ..		S RM=$piece(RM,",",1)_" "_$$^MSG(2326)
 ..		Q 
 .	E  D
 ..		D UNPROT^DBSMACRO("@vDELETE") ; unprotect the delete field
 ..		D DEFAULT^DBSMACRO("@vDELETE",0,1,0,1) ; set default value
 ..		Q 
 .	Q 
 ;
 I (X=V),'($piece(VREC,"|",keycnt+1,999)="") Q  ; Don't Change
 ;
 S $piece(VREC,"|",keylvl)=X ; reprint the current data
 I ($piece(VREC,"|",keylvl+1)="") Q  ; not UP Arrow
 S VREC=$piece(VREC,"|",1,keylvl)
 D VDA^UTLREAD
 D ^DBSPNT(1) ; Display data with format
 ;
 F I=keylvl+1:1:keycnt S vdft(I)=""
 ;
 S V=X ; Set previous value
 ;
 Q 
 ;
EXIST(fid,acc,del,fsn,sel,row) ; First row    /NOREQ/MECH=REFNAM:W
 ;
  S ER=0
 ;
 N RETURN
 N I
 N key N keys N keyvals N sellist
 ;
 I ($get(del)="") S del=124
 ;
 I '($D(fsn(fid))#2) D fsn^DBSDD(.fsn,fid) I ER Q ""
 ;
 S del=$char(del)
 ;
 S (keyvals,sellist)=""
 S keys=$piece(fsn(fid),"|",3)
 F I=1:1:$L(keys,",") D  Q:ER 
 .	;
 .	N value
 .	;
 .	S key=$piece(keys,",",I)
 .	S sellist=sellist_key_","
 .	S value=$piece(acc,del,I)
 .	I (value="") D
 ..		S ER=1
 ..		S RM="Access Key "_key_" cannot be null"
 ..		Q 
 .	E  S keyvals=keyvals_key_"='"_value_"' AND "
 .	Q 
 I ER Q ""
 ;
 S sellist=$E(sellist,1,$L(sellist)-1)
 I '($get(sel)="") S sellist=sel ; Use select list, if provided
 ;
 S keyvals=$E(keyvals,1,$L(keyvals)-5)
 ;
 ;  #ACCEPT DATE=12/27/04; PGM=Dan Russell; CR=Unknown; GROUP=DYNAMIC
 N rs,exe,sqlcur,vd,vi,vsql,vsub S rs=$$vOpen0(.exe,.vsql,sellist,fid,keyvals,"","","",1)
 ;
 I $$vFetch0(rs) D
 .	S RETURN=1
 .	S row=vobj(rs)
 .	Q 
 ;
 E  D
 .	S RETURN=0
 .	S row=""
 .	Q 
 ;
 K vobj(+$G(rs)) Q RETURN
 ;
DBLQ(X) ; Value to double quote
 ;
 Q $S(X'["""":""""_X_"""",1:$$QADD^%ZS(X,""""))
 ;
addcode(TABS,CODE) ; 
 ;
 N I N LINENO
 ;
 S LINENO=$order(pslcode(""),-1)+1 ; Add to end
 ;
 I TABS F I=1:1:TABS S CODE=$char(9)_CODE
 ;
 S pslcode(LINENO)=CODE
 ;
 Q 
 ;
PROMPT ; 
 ;
 N VFMQ
 ;
 S VFMQ=""
 ;
 F  D  Q:(VFMQ="Q") 
 .	;
 .	N %FRAME
 .	N %NOPRMT N %READ N %TAB N FIL
 .	;
 .	S %TAB("FIL")=$$TBLPRMPT^DBSGETID("DBTBL1")
 .	S FIL="" ; File name
 .	;
 .	S %READ="@@%FN,,FIL/REQ,"
 .	S %NOPRMT="F"
 .	S %FRAME=2
 .	;
 .	D ^UTLREAD Q:(VFMQ="Q") 
 .	;
 .	D DBSEDIT("",FIL,"","","",2)
 .	Q 
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61185^65717^Dan Russell^20304" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vStrRep(object,p1,p2,p3,p4,qt) ; String.replace
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;
 I p3<0 Q object
 I $L(p1)=1,$L(p2)<2,'p3,'p4,(qt="") Q $translate(object,p1,p2)
 ;
 N y S y=0
 F  S y=$$vStrFnd(object,p1,y,p4,qt) Q:y=0  D
 .	S object=$E(object,1,y-$L(p1)-1)_p2_$E(object,y,1048575)
 .	S y=y+$L(p2)-$L(p1)
 .	I p3 S p3=p3-1 I p3=0 S y=$L(object)+1
 .	Q 
 Q object
 ; ----------------
 ;  #OPTION ResultClass 1
vdat2str(vo,mask) ; Date.toString
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I (vo="") Q ""
 I (mask="") S mask="MM/DD/YEAR"
 N cc N lday N lmon
 I mask="DL"!(mask="DS") D  ; Long or short weekday
 .	;    #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL
 .	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
 .	I (cc="") S cc="US"
 .	;    #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL
 .	S lday=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
 .	S mask="DAY" ; Day of the week
 .	Q 
 I mask="ML"!(mask="MS") D  ; Long or short month
 .	;    #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL
 .	S cc=$get(^DBCTL("SYS","DVFM")) ; Country code
 .	I (cc="") S cc="US"
 .	;    #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=GLOBAL
 .	S lmon=$get(^DBCTL("SYS","*DVFM",cc,"D",mask))
 .	S mask="MON" ; Month of the year
 .	Q 
 ;  #ACCEPT PGM=FSCW;DATE=2007-03-30;CR=27800;GROUP=BYPASS
 ;*** Start of code by-passed by compiler
 set cc=$ZD(vo,mask,$G(lmon),$G(lday))
 ;*** End of code by-passed by compiler ***
 Q cc
 ; ----------------
 ;  #OPTION ResultClass 1
vStrTrim(object,p1,p2) ; String.trim
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I p1'<0 S object=$$RTCHR^%ZFUNC(object,p2)
 I p1'>0 F  Q:$E(object,1)'=p2  S object=$E(object,2,1048575)
 Q object
 ; ----------------
 ;  #OPTION ResultClass 1
vStrLike(object,p1,p2) ; String.isLike
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 I (p1="") Q (object="")
 I p2 S object=$ZCONVERT(object,"U") S p1=$ZCONVERT(p1,"U")
 I ($E(p1,1)="%"),($E(p1,$L(p1))="%") Q object[$E(p1,2,$L(p1)-1)
 I ($E(p1,1)="%") Q ($E(object,$L(object)-$L($E(p1,2,1048575))+1,1048575)=$E(p1,2,1048575))
 I ($E(p1,$L(p1))="%") Q ($E(object,1,$L($E(p1,1,$L(p1)-1)))=$E(p1,1,$L(p1)-1))
 Q object=p1
 ; ----------------
 ;  #OPTION ResultClass 1
vRsRowGC(vNms,vTps) ; Runtime ResultSet.getRow().getColumns()
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;
 N vL S vL="" N vN N vT N vO
 F vO=1:1:$S((vNms=""):0,1:$L(vNms,",")) D
 .	S vN=$piece(vNms,",",vO)
 .	S vT=$E(vTps,(vO-1)*2+1)
 .	I "TUF"[vT S vT="String"
 .	E  S vT=$piece("ByteString,Boolean,Date,Memo,Number,Number,Time",",",$F("BLDMN$C",vT)-1)
 .	S $piece(vL,",",v0)=vT_" "_vN
 .	Q 
 Q vL
 ; ----------------
 ;  #OPTION ResultClass 1
vStrFnd(object,p1,p2,p3,qt) ; String.find
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 ;
 I (p1="") Q $S(p2<1:1,1:+p2)
 I p3 S object=$ZCONVERT(object,"U") S p1=$ZCONVERT(p1,"U")
 S p2=$F(object,p1,p2)
 I '(qt=""),$L($E(object,1,p2-1),qt)#2=0 D
 .	F  S p2=$F(object,p1,p2) Q:p2=0!($L($E(object,1,p2-1),qt)#2) 
 .	Q 
 Q p2
 ;
vOpen0(exe,vsql,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist,vOff) ; Dynamic MDB ResultSet
 ;
 N vOid
 N ER,vExpr,mode,RM,vOpen,vTok S ER=0 ;=noOpti
 ;
 S vExpr="SELECT "_vSelect_" FROM "_vFrom
 I vWhere'="" S vExpr=vExpr_" WHERE "_vWhere
 I vOrderby'="" S vExpr=vExpr_" ORDER BY "_vOrderby
 I vGroupby'="" S vExpr=vExpr_" GROUP BY "_vGroupby
 S vExpr=$$UNTOK^%ZS($$SQL^%ZS(vExpr,.vTok),vTok)
 ;
 S sqlcur=$O(vobj(""),-1)+1
 ;
 I $$FLT^SQLCACHE(vExpr,vTok,.vParlist)
 E  S vOpen=$$OPEN^SQLM(.exe,vFrom,vSelect,vWhere,vOrderby,vGroupby,vParlist,,1,,sqlcur) I 'ER D SAV^SQLCACHE(vExpr,.vParlist) s vsql=vOpen
 I ER S $ZE="0,"_$ZPOS_",%PSL-E-SQLFAIL,"_$TR($G(RM),$C(10,44),$C(32,126)),$EC=",U1001,"
 ;
 S vOid=sqlcur
 S vobj(vOid,0)=vsql
 S vobj(vOid,-1)="ResultSet"
 S vobj(vOid,-2)="$$vFetch0^"_$T(+0)
 S vobj(vOid,-3)=$$RsSelList^UCDBRT(vSelect)
 S vobj(vOid,-4)=$G(vsql("D"))
 S vobj(vOid,-5)=0
 Q vOid
 ;
vFetch0(vOid) ; MDB dynamic FETCH
 ;
 ; type public String exe(),sqlcur,vd,vi,vsql()
 ;
 I vsql=0 S vobj(vOid)="" Q 0
 S vsql=$$^SQLF(.exe,.vd,.vi,.sqlcur)
 S vobj(vOid)=vd
 S vobj(vOid,0)=vsql
 S vobj(vOid,.1)=$G(vi)
 Q vsql
 ;
vCatch1 ; Error trap
 ;
 N error,$ET,$ES S error=$ZE,$EC="",$ET="Q",$ZE=""
 ;
 I $P(error,",",3)="%PSL-E-DBFILER" D
 .						;
 .						S ER=1
 .						S RM=$P(error,",",4)
 .						Q 
 E  S $ZE=error,$EC=",U1001,"
 D ZX^UCGMR(voxMrk) Q 
