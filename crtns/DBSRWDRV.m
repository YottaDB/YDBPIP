DBSRWDRV	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSRWDRV ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	Q 
	;
BUILD	; Prompt for reports to build, then build them
	;
	Q:'$$LIST^DBSGETID("DBTBL5H")  ; Prompt
	;
	D BUILDEM ; Build
	;
	Q 
	;
BUILDALL	; Build all reports
	;
	 N V1 S V1=$J D vDbDe1()
	;
	N rs,vos1,vos2 S rs=$$vOpen1()
	;
	F  Q:'($$vFetch1())  D
	.	;
	.	N tmpdq,vop1,vop2,vop3 S tmpdq="",vop2=$J,vop1=rs,vop3=0
	.	;
	. N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^TEMP(vop2,vop1)=tmpdq S vop3=1 Tcommit:vTp  
	.	Q 
	;
	D BUILDEM
	;
	Q 
	;
BUILDEM	; Generate run-time code for report(s)
	;
	N STOP
	N PID N RID
	;
	S STOP=0
	S PID=$J
	;
	N tmpdqrs,vos1,vos2,vos3 S tmpdqrs=$$vOpen2()
	;
	F  Q:'($$vFetch2())  D  Q:STOP 
	.	; If error, keep going, unless interrupt
	.	N $ZT S $ZT="D ZX^UCGMR("_+$O(vobj(""),-1)_","_$ZL_",""vtrap1^"_$T(+0)_""")"
	.	S RID=tmpdqrs
	.	D COMPILE(RID)
	.	Q 
	;
	 N V1 S V1=$J D vDbDe2()
	;
	Q 
	;
COPY	; Copy existing report definition
	;
	N DQSCR
	;
	S DQSCR=$$DQSCR
	I DQSCR'="" D COPY^DBSUTL("DBTBL5H")
	;
	Q 
	;
CREATE	;
	;
	N %O
	;
	S RID=$$FIND^DBSGETID("DBTBL5H",1) Q:(RID="") 
	;
	I ($D(^DBTBL("SYSDEV",5,RID))) Q 
	;
	S STATUS=$$SETHDR ; try to set up header
	I 'STATUS D  Q 
	.	S ER=1
	.	S RM=$piece(STATUS,"|",2)
	.	Q 
	;
	S %O=0
	D ^FORMDQ5(RID)
	;
	Q 
	;
DELETE	; Delete report definition
	;
	N DQSCR
	;
	S DQSCR=$$DQSCR
	I DQSCR'="" D DEL^DBSUTL("DBTBL5H")
	;
	Q 
	;
EXEC	;
	;
	N RID N PGM
	;
	S RID=$$FIND^DBSGETID("DBTBL5H",0) Q:(RID="") 
	;
	N dbtbl5h,vop1,vop2,vop3 S vop1="SYSDEV",vop2=RID,dbtbl5h=$$vDb3("SYSDEV",RID)
	 S vop3=$G(^DBTBL(vop1,5,vop2,0))
	S PGM=$P(vop3,$C(124),2)
	;
	; Check to see if needs to be compiled first
	I PGM'="",$$VALID^%ZRTNS(PGM)
	; Compile report first
	E  S ER=1 S RM=$$^MSG(7960) Q 
	;
	WRITE $$CLEAR^%TRMVT
	D ^@PGM
	Q 
	;
EXT	;
	;
	D BUILDEM
	;
	Q 
	;
LIST	; List report definition
	;
	 S ER=0
	;
	N CNT N VRWOPT
	N IO N RID N PGM N vudwhere
	;
	Q:'$$LIST^DBSGETID("DBTBL5H","List",.IO) 
	;
	S RID="DBSRPTLST"
	D ^URID Q:$get(PGM)="" 
	;
	S vudwhere="LIBS='SYSDEV' AND RID=:ZRID AND SEQ>0"
	;
	D OPEN^SCAIO Q:ER 
	;
	N tmpdqrs,vos1,vos2,vos3  N V1 S V1=$J S tmpdqrs=$$vOpen3()
	;
	S CNT=0
	F  Q:'($$vFetch3())  D  Q:ER 
	.	N ZRID
	.	;
	.	; If interactive, prompt to continue
	.	I CNT,IO=$P D  Q:ER 
	..		N MSG
	..		;
	..		S MSG=""
	..		I $$^DBSMBAR(161)'=1 S ER=1 S RM=""
	..		Q 
	.	;
	.	S ZRID=tmpdqrs
	.	S VRWOPT("NOOPEN")=1
	.	S VRWOPT("NOCLOSE")=1
	.	D @("V0^"_PGM)
	.	S CNT=CNT+1
	.	Q 
	;
	D CLOSE^SCAIO
	;
	 N V2 S V2=$J D vDbDe3()
	;
	Q 
	;
MODIFY	; Modify report definition
	;
	N RID
	;
	S RID=$$FIND^DBSGETID("DBTBL5H",0) Q:(RID="") 
	;
	D ^FORMDQ5(RID)
	;
	Q 
	;
PRINT	; Pring report definition(s)
	;
	D PNT^DBSEXE5
	;
	Q 
	;
DQSCR()	; Return program for DQ report control page
	;
	N SID S SID="DBTBL5H"
	N PGM
	;
	D ^USID I PGM="" Q ""
	;
	Q "^"_PGM
	;
COMPILE(RID)	;
	;
	N ER S ER=0
	N RM
	;
	D ^DBSRW(RID)
	;
	I ER,'($get(RM)="") WRITE !!,RM,!
	;
	Q 
	;
SETHDR()	;
	;
	N %A N %A N DQSCR N FID N PGM N %O
	N LIBS N RM N SID N SORT N VFMQ N X N Z
	N ER N I
	;
	S ER=0
	S (%A,%A(0))=""
	F I=1:1:10 S %A(I)="|1|1|*|A"
	;
	S DQSCR=$$DQSCR Q:DQSCR="" 
	S LIBS="SYSDEV"
	S %O=0
	D @DQSCR ; Main page
	I VFMQ="Q" Q 0
	;
	S SID="DBTBL5H1" ; Sequence by page
	D ^USID I PGM="" Q 0
	D ^@PGM
	I VFMQ="Q" Q 0
	;
	S $piece(%A(0),"|",15)=%UID
	;
	F I=1:1:10 D
	.	N X
	.	S X=$piece(%A(I),"|",1)
	.	I X'="" S SORT(X)=""
	.	Q 
	;
	S FID=$piece($piece(%A(0),"|",1),",",1)
	; Invalid file name - ~p1
	I '($D(^DBTBL("SYSDEV",1,FID))) Q 0_"|"_$$^MSG(1337,FID)
	;
	N dbtbl1,vop1,vop2,vop3 S vop1="SYSDEV",vop2=FID,dbtbl1=$$vDb4("SYSDEV",FID)
	 S vop3=$G(^DBTBL(vop1,1,vop2,16))
	;
	S Z=$P(vop3,$C(124),1)
	F I=1:1:$L(Z,",") D
	.	N KEY
	.	Q:$$isLit^UCGM($piece(Z,",",I)) 
	.	S KEY="[SYSDEV,"_FID_"]"_$piece(Z,",",I)
	.	I '$D(SORT(KEY)) D
	..		; Missing Key(s)
	..		I 'ER S ER=1 S RM=$$^MSG(7962)
	..		S RM=RM_" "_KEY
	..		Q 
	.	Q 
	I ER Q 0_"|"_RM
	;
	N dbtbl5h S dbtbl5h=$$vDbNew2("","")
	 S vobj(dbtbl5h,0)=""
	 S vobj(dbtbl5h,1)=""
	 S vobj(dbtbl5h,2)=""
	 S vobj(dbtbl5h,3)=""
	 S vobj(dbtbl5h,4)=""
	 S vobj(dbtbl5h,5)=""
	 S vobj(dbtbl5h,6)=""
	 S vobj(dbtbl5h,7)=""
	 S vobj(dbtbl5h,8)=""
	 S vobj(dbtbl5h,9)=""
	 S vobj(dbtbl5h,10)=""
	;
	S:'$D(vobj(dbtbl5h,-100,"0*","DESC")) vobj(dbtbl5h,-100,"0*","DESC")="T001"_$P(vobj(dbtbl5h),$C(124),1) S vobj(dbtbl5h,-100,"0*")="",$P(vobj(dbtbl5h),$C(124),1)=%A
	S:'$D(vobj(dbtbl5h,-100,"1*","LIBS")) vobj(dbtbl5h,-100,"1*","LIBS")="T001"_$G(vobj(dbtbl5h,-3)) S vobj(dbtbl5h,-100,"1*")="",vobj(dbtbl5h,-3)="SYSDEV"
	S:'$D(vobj(dbtbl5h,-100,"2*","RID")) vobj(dbtbl5h,-100,"2*","RID")="T002"_$G(vobj(dbtbl5h,-4)) S vobj(dbtbl5h,-100,"2*")="",vobj(dbtbl5h,-4)=RID
	S:'$D(vobj(dbtbl5h,-100,0,"PFID")) vobj(dbtbl5h,-100,0,"PFID")="U001"_$P(vobj(dbtbl5h,0),$C(124),1) S vobj(dbtbl5h,-100,0)="",$P(vobj(dbtbl5h,0),$C(124),1)=FID
	S:'$D(vobj(dbtbl5h,-100,0,"DATE")) vobj(dbtbl5h,-100,0,"DATE")="D003"_$P(vobj(dbtbl5h,0),$C(124),3) S vobj(dbtbl5h,-100,0)="",$P(vobj(dbtbl5h,0),$C(124),3)=$P($H,",",1)
	S:'$D(vobj(dbtbl5h,-100,0,"RSIZE")) vobj(dbtbl5h,-100,0,"RSIZE")="N005"_$P(vobj(dbtbl5h,0),$C(124),5) S vobj(dbtbl5h,-100,0)="",$P(vobj(dbtbl5h,0),$C(124),5)=$piece(%A(0),"|",5)
	S:'$D(vobj(dbtbl5h,-100,0,"PSIZE")) vobj(dbtbl5h,-100,0,"PSIZE")="N006"_$P(vobj(dbtbl5h,0),$C(124),6) S vobj(dbtbl5h,-100,0)="",$P(vobj(dbtbl5h,0),$C(124),6)=$piece(%A(0),"|",6)
	S:'$D(vobj(dbtbl5h,-100,0,"RESFLG")) vobj(dbtbl5h,-100,0,"RESFLG")="N007"_$P(vobj(dbtbl5h,0),$C(124),7) S vobj(dbtbl5h,-100,0)="",$P(vobj(dbtbl5h,0),$C(124),7)=$piece(%A(0),"|",7)
	S:'$D(vobj(dbtbl5h,-100,0,"FIXLEN")) vobj(dbtbl5h,-100,0,"FIXLEN")="L008"_$P(vobj(dbtbl5h,0),$C(124),8) S vobj(dbtbl5h,-100,0)="",$P(vobj(dbtbl5h,0),$C(124),8)=$piece(%A(0),"|",8)
	S:'$D(vobj(dbtbl5h,-100,0,"NORB")) vobj(dbtbl5h,-100,0,"NORB")="L009"_$P(vobj(dbtbl5h,0),$C(124),9) S vobj(dbtbl5h,-100,0)="",$P(vobj(dbtbl5h,0),$C(124),9)=$piece(%A(0),"|",9)
	S:'$D(vobj(dbtbl5h,-100,0,"VER")) vobj(dbtbl5h,-100,0,"VER")="T010"_$P(vobj(dbtbl5h,0),$C(124),10) S vobj(dbtbl5h,-100,0)="",$P(vobj(dbtbl5h,0),$C(124),10)=$piece(%A(0),"|",10)
	S:'$D(vobj(dbtbl5h,-100,0,"INLIST")) vobj(dbtbl5h,-100,0,"INLIST")="L011"_$P(vobj(dbtbl5h,0),$C(124),11) S vobj(dbtbl5h,-100,0)="",$P(vobj(dbtbl5h,0),$C(124),11)=$piece(%A(0),"|",11)
	S:'$D(vobj(dbtbl5h,-100,0,"OUTLIST")) vobj(dbtbl5h,-100,0,"OUTLIST")="L012"_$P(vobj(dbtbl5h,0),$C(124),12) S vobj(dbtbl5h,-100,0)="",$P(vobj(dbtbl5h,0),$C(124),12)=$piece(%A(0),"|",12)
	S:'$D(vobj(dbtbl5h,-100,0,"MSQL")) vobj(dbtbl5h,-100,0,"MSQL")="L013"_$P(vobj(dbtbl5h,0),$C(124),13) S vobj(dbtbl5h,-100,0)="",$P(vobj(dbtbl5h,0),$C(124),13)=$piece(%A(0),"|",13)
	S:'$D(vobj(dbtbl5h,-100,0,"UID")) vobj(dbtbl5h,-100,0,"UID")="T015"_$P(vobj(dbtbl5h,0),$C(124),15) S vobj(dbtbl5h,-100,0)="",$P(vobj(dbtbl5h,0),$C(124),15)=%UID
	S:'$D(vobj(dbtbl5h,-100,0,"BANNER")) vobj(dbtbl5h,-100,0,"BANNER")="L016"_$P(vobj(dbtbl5h,0),$C(124),16) S vobj(dbtbl5h,-100,0)="",$P(vobj(dbtbl5h,0),$C(124),16)=$piece(%A(0),"|",16)
	S:'$D(vobj(dbtbl5h,-100,0,"ALIGN")) vobj(dbtbl5h,-100,0,"ALIGN")="L017"_$P(vobj(dbtbl5h,0),$C(124),17) S vobj(dbtbl5h,-100,0)="",$P(vobj(dbtbl5h,0),$C(124),17)=$piece(%A(0),"|",17)
	S:'$D(vobj(dbtbl5h,-100,0,"NEWCOMP")) vobj(dbtbl5h,-100,0,"NEWCOMP")="L018"_$P(vobj(dbtbl5h,0),$C(124),18) S vobj(dbtbl5h,-100,0)="",$P(vobj(dbtbl5h,0),$C(124),18)=$piece(%A(0),"|",18)
	S:'$D(vobj(dbtbl5h,-100,0,"VARIABLE")) vobj(dbtbl5h,-100,0,"VARIABLE")="T019"_$P(vobj(dbtbl5h,0),$C(124),19) S vobj(dbtbl5h,-100,0)="",$P(vobj(dbtbl5h,0),$C(124),19)=$piece(%A(0),"|",19)
	S:'$D(vobj(dbtbl5h,-100,0,"DISTKEY")) vobj(dbtbl5h,-100,0,"DISTKEY")="T020"_$P(vobj(dbtbl5h,0),$C(124),20) S vobj(dbtbl5h,-100,0)="",$P(vobj(dbtbl5h,0),$C(124),20)=$piece(%A(0),"|",20)
	S:'$D(vobj(dbtbl5h,-100,0,"VARREPORT")) vobj(dbtbl5h,-100,0,"VARREPORT")="T021"_$P(vobj(dbtbl5h,0),$C(124),21) S vobj(dbtbl5h,-100,0)="",$P(vobj(dbtbl5h,0),$C(124),21)=$piece(%A(0),"|",21)
	S:'$D(vobj(dbtbl5h,-100,0,"INDEX")) vobj(dbtbl5h,-100,0,"INDEX")="T022"_$P(vobj(dbtbl5h,0),$C(124),22) S vobj(dbtbl5h,-100,0)="",$P(vobj(dbtbl5h,0),$C(124),22)=$piece(%A(0),"|",22)
	S:'$D(vobj(dbtbl5h,-100,1,"SEQ")) vobj(dbtbl5h,-100,1,"SEQ")="U001"_$P(vobj(dbtbl5h,1),$C(124),1) S vobj(dbtbl5h,-100,1)="",$P(vobj(dbtbl5h,1),$C(124),1)=$piece(%A(1),"|",1)
	S:'$D(vobj(dbtbl5h,-100,1,"PGBK")) vobj(dbtbl5h,-100,1,"PGBK")="L002"_$P(vobj(dbtbl5h,1),$C(124),2) S vobj(dbtbl5h,-100,1)="",$P(vobj(dbtbl5h,1),$C(124),2)=$piece(%A(1),"|",2)
	S:'$D(vobj(dbtbl5h,-100,1,"PHDR")) vobj(dbtbl5h,-100,1,"PHDR")="L003"_$P(vobj(dbtbl5h,1),$C(124),3) S vobj(dbtbl5h,-100,1)="",$P(vobj(dbtbl5h,1),$C(124),3)=$piece(%A(1),"|",3)
	S:'$D(vobj(dbtbl5h,-100,1,"PRNG")) vobj(dbtbl5h,-100,1,"PRNG")="T004"_$P(vobj(dbtbl5h,1),$C(124),4) S vobj(dbtbl5h,-100,1)="",$P(vobj(dbtbl5h,1),$C(124),4)=$piece(%A(1),"|",4)
	S:'$D(vobj(dbtbl5h,-100,1,"SORTORD")) vobj(dbtbl5h,-100,1,"SORTORD")="U005"_$P(vobj(dbtbl5h,1),$C(124),5) S vobj(dbtbl5h,-100,1)="",$P(vobj(dbtbl5h,1),$C(124),5)=$piece(%A(1),"|",5)
	S:'$D(vobj(dbtbl5h,-100,2,"SEQ2")) vobj(dbtbl5h,-100,2,"SEQ2")="U001"_$P(vobj(dbtbl5h,2),$C(124),1) S vobj(dbtbl5h,-100,2)="",$P(vobj(dbtbl5h,2),$C(124),1)=$piece(%A(2),"|",1)
	S:'$D(vobj(dbtbl5h,-100,2,"PGBK2")) vobj(dbtbl5h,-100,2,"PGBK2")="L002"_$P(vobj(dbtbl5h,2),$C(124),2) S vobj(dbtbl5h,-100,2)="",$P(vobj(dbtbl5h,2),$C(124),2)=$piece(%A(2),"|",2)
	S:'$D(vobj(dbtbl5h,-100,2,"PHDR2")) vobj(dbtbl5h,-100,2,"PHDR2")="L003"_$P(vobj(dbtbl5h,2),$C(124),3) S vobj(dbtbl5h,-100,2)="",$P(vobj(dbtbl5h,2),$C(124),3)=$piece(%A(2),"|",3)
	S:'$D(vobj(dbtbl5h,-100,2,"PRNG2")) vobj(dbtbl5h,-100,2,"PRNG2")="T004"_$P(vobj(dbtbl5h,2),$C(124),4) S vobj(dbtbl5h,-100,2)="",$P(vobj(dbtbl5h,2),$C(124),4)=$piece(%A(2),"|",4)
	S:'$D(vobj(dbtbl5h,-100,2,"SORTORD2")) vobj(dbtbl5h,-100,2,"SORTORD2")="U005"_$P(vobj(dbtbl5h,2),$C(124),5) S vobj(dbtbl5h,-100,2)="",$P(vobj(dbtbl5h,2),$C(124),5)=$piece(%A(2),"|",5)
	S:'$D(vobj(dbtbl5h,-100,3,"SEQ3")) vobj(dbtbl5h,-100,3,"SEQ3")="U001"_$P(vobj(dbtbl5h,3),$C(124),1) S vobj(dbtbl5h,-100,3)="",$P(vobj(dbtbl5h,3),$C(124),1)=$piece(%A(3),"|",1)
	S:'$D(vobj(dbtbl5h,-100,3,"PGBK3")) vobj(dbtbl5h,-100,3,"PGBK3")="L002"_$P(vobj(dbtbl5h,3),$C(124),2) S vobj(dbtbl5h,-100,3)="",$P(vobj(dbtbl5h,3),$C(124),2)=$piece(%A(3),"|",2)
	S:'$D(vobj(dbtbl5h,-100,3,"PHDR3")) vobj(dbtbl5h,-100,3,"PHDR3")="L003"_$P(vobj(dbtbl5h,3),$C(124),3) S vobj(dbtbl5h,-100,3)="",$P(vobj(dbtbl5h,3),$C(124),3)=$piece(%A(3),"|",3)
	S:'$D(vobj(dbtbl5h,-100,3,"PRNG3")) vobj(dbtbl5h,-100,3,"PRNG3")="T004"_$P(vobj(dbtbl5h,3),$C(124),4) S vobj(dbtbl5h,-100,3)="",$P(vobj(dbtbl5h,3),$C(124),4)=$piece(%A(3),"|",4)
	S:'$D(vobj(dbtbl5h,-100,3,"SORTORD3")) vobj(dbtbl5h,-100,3,"SORTORD3")="U005"_$P(vobj(dbtbl5h,3),$C(124),5) S vobj(dbtbl5h,-100,3)="",$P(vobj(dbtbl5h,3),$C(124),5)=$piece(%A(3),"|",5)
	S:'$D(vobj(dbtbl5h,-100,4,"SEQ4")) vobj(dbtbl5h,-100,4,"SEQ4")="U001"_$P(vobj(dbtbl5h,4),$C(124),1) S vobj(dbtbl5h,-100,4)="",$P(vobj(dbtbl5h,4),$C(124),1)=$piece(%A(4),"|",1)
	S:'$D(vobj(dbtbl5h,-100,4,"PGBK4")) vobj(dbtbl5h,-100,4,"PGBK4")="L002"_$P(vobj(dbtbl5h,4),$C(124),2) S vobj(dbtbl5h,-100,4)="",$P(vobj(dbtbl5h,4),$C(124),2)=$piece(%A(4),"|",2)
	S:'$D(vobj(dbtbl5h,-100,4,"PHDR4")) vobj(dbtbl5h,-100,4,"PHDR4")="L003"_$P(vobj(dbtbl5h,4),$C(124),3) S vobj(dbtbl5h,-100,4)="",$P(vobj(dbtbl5h,4),$C(124),3)=$piece(%A(4),"|",3)
	S:'$D(vobj(dbtbl5h,-100,4,"PRNG4")) vobj(dbtbl5h,-100,4,"PRNG4")="T004"_$P(vobj(dbtbl5h,4),$C(124),4) S vobj(dbtbl5h,-100,4)="",$P(vobj(dbtbl5h,4),$C(124),4)=$piece(%A(4),"|",4)
	S:'$D(vobj(dbtbl5h,-100,4,"SORTORD4")) vobj(dbtbl5h,-100,4,"SORTORD4")="U005"_$P(vobj(dbtbl5h,4),$C(124),5) S vobj(dbtbl5h,-100,4)="",$P(vobj(dbtbl5h,4),$C(124),5)=$piece(%A(4),"|",5)
	S:'$D(vobj(dbtbl5h,-100,5,"SEQ5")) vobj(dbtbl5h,-100,5,"SEQ5")="U001"_$P(vobj(dbtbl5h,5),$C(124),1) S vobj(dbtbl5h,-100,5)="",$P(vobj(dbtbl5h,5),$C(124),1)=$piece(%A(5),"|",1)
	S:'$D(vobj(dbtbl5h,-100,5,"PGBK5")) vobj(dbtbl5h,-100,5,"PGBK5")="L002"_$P(vobj(dbtbl5h,5),$C(124),2) S vobj(dbtbl5h,-100,5)="",$P(vobj(dbtbl5h,5),$C(124),2)=$piece(%A(5),"|",2)
	S:'$D(vobj(dbtbl5h,-100,5,"PHDR5")) vobj(dbtbl5h,-100,5,"PHDR5")="L003"_$P(vobj(dbtbl5h,5),$C(124),3) S vobj(dbtbl5h,-100,5)="",$P(vobj(dbtbl5h,5),$C(124),3)=$piece(%A(5),"|",3)
	S:'$D(vobj(dbtbl5h,-100,5,"PRNG5")) vobj(dbtbl5h,-100,5,"PRNG5")="T004"_$P(vobj(dbtbl5h,5),$C(124),4) S vobj(dbtbl5h,-100,5)="",$P(vobj(dbtbl5h,5),$C(124),4)=$piece(%A(5),"|",4)
	S:'$D(vobj(dbtbl5h,-100,5,"SORTORD5")) vobj(dbtbl5h,-100,5,"SORTORD5")="U005"_$P(vobj(dbtbl5h,5),$C(124),5) S vobj(dbtbl5h,-100,5)="",$P(vobj(dbtbl5h,5),$C(124),5)=$piece(%A(5),"|",5)
	S:'$D(vobj(dbtbl5h,-100,6,"SEQ6")) vobj(dbtbl5h,-100,6,"SEQ6")="U001"_$P(vobj(dbtbl5h,6),$C(124),1) S vobj(dbtbl5h,-100,6)="",$P(vobj(dbtbl5h,6),$C(124),1)=$piece(%A(6),"|",1)
	S:'$D(vobj(dbtbl5h,-100,6,"PGBK6")) vobj(dbtbl5h,-100,6,"PGBK6")="L002"_$P(vobj(dbtbl5h,6),$C(124),2) S vobj(dbtbl5h,-100,6)="",$P(vobj(dbtbl5h,6),$C(124),2)=$piece(%A(6),"|",2)
	S:'$D(vobj(dbtbl5h,-100,6,"PHDR6")) vobj(dbtbl5h,-100,6,"PHDR6")="L003"_$P(vobj(dbtbl5h,6),$C(124),3) S vobj(dbtbl5h,-100,6)="",$P(vobj(dbtbl5h,6),$C(124),3)=$piece(%A(6),"|",3)
	S:'$D(vobj(dbtbl5h,-100,6,"PRNG6")) vobj(dbtbl5h,-100,6,"PRNG6")="T004"_$P(vobj(dbtbl5h,6),$C(124),4) S vobj(dbtbl5h,-100,6)="",$P(vobj(dbtbl5h,6),$C(124),4)=$piece(%A(6),"|",4)
	S:'$D(vobj(dbtbl5h,-100,6,"SORTORD6")) vobj(dbtbl5h,-100,6,"SORTORD6")="U005"_$P(vobj(dbtbl5h,6),$C(124),5) S vobj(dbtbl5h,-100,6)="",$P(vobj(dbtbl5h,6),$C(124),5)=$piece(%A(6),"|",5)
	S:'$D(vobj(dbtbl5h,-100,7,"SEQ7")) vobj(dbtbl5h,-100,7,"SEQ7")="U001"_$P(vobj(dbtbl5h,7),$C(124),1) S vobj(dbtbl5h,-100,7)="",$P(vobj(dbtbl5h,7),$C(124),1)=$piece(%A(7),"|",1)
	S:'$D(vobj(dbtbl5h,-100,7,"PGBK7")) vobj(dbtbl5h,-100,7,"PGBK7")="L002"_$P(vobj(dbtbl5h,7),$C(124),2) S vobj(dbtbl5h,-100,7)="",$P(vobj(dbtbl5h,7),$C(124),2)=$piece(%A(7),"|",2)
	S:'$D(vobj(dbtbl5h,-100,7,"PHDR7")) vobj(dbtbl5h,-100,7,"PHDR7")="L003"_$P(vobj(dbtbl5h,7),$C(124),3) S vobj(dbtbl5h,-100,7)="",$P(vobj(dbtbl5h,7),$C(124),3)=$piece(%A(7),"|",3)
	S:'$D(vobj(dbtbl5h,-100,7,"PRNG7")) vobj(dbtbl5h,-100,7,"PRNG7")="T004"_$P(vobj(dbtbl5h,7),$C(124),4) S vobj(dbtbl5h,-100,7)="",$P(vobj(dbtbl5h,7),$C(124),4)=$piece(%A(7),"|",4)
	S:'$D(vobj(dbtbl5h,-100,7,"SORTORD7")) vobj(dbtbl5h,-100,7,"SORTORD7")="U005"_$P(vobj(dbtbl5h,7),$C(124),5) S vobj(dbtbl5h,-100,7)="",$P(vobj(dbtbl5h,7),$C(124),5)=$piece(%A(7),"|",5)
	S:'$D(vobj(dbtbl5h,-100,8,"SEQ8")) vobj(dbtbl5h,-100,8,"SEQ8")="U001"_$P(vobj(dbtbl5h,8),$C(124),1) S vobj(dbtbl5h,-100,8)="",$P(vobj(dbtbl5h,8),$C(124),1)=$piece(%A(8),"|",1)
	S:'$D(vobj(dbtbl5h,-100,8,"PGBK8")) vobj(dbtbl5h,-100,8,"PGBK8")="L002"_$P(vobj(dbtbl5h,8),$C(124),2) S vobj(dbtbl5h,-100,8)="",$P(vobj(dbtbl5h,8),$C(124),2)=$piece(%A(8),"|",2)
	S:'$D(vobj(dbtbl5h,-100,8,"PHDR8")) vobj(dbtbl5h,-100,8,"PHDR8")="L003"_$P(vobj(dbtbl5h,8),$C(124),3) S vobj(dbtbl5h,-100,8)="",$P(vobj(dbtbl5h,8),$C(124),3)=$piece(%A(8),"|",3)
	S:'$D(vobj(dbtbl5h,-100,8,"PRNG8")) vobj(dbtbl5h,-100,8,"PRNG8")="T004"_$P(vobj(dbtbl5h,8),$C(124),4) S vobj(dbtbl5h,-100,8)="",$P(vobj(dbtbl5h,8),$C(124),4)=$piece(%A(8),"|",4)
	S:'$D(vobj(dbtbl5h,-100,8,"SORTORD8")) vobj(dbtbl5h,-100,8,"SORTORD8")="U005"_$P(vobj(dbtbl5h,8),$C(124),5) S vobj(dbtbl5h,-100,8)="",$P(vobj(dbtbl5h,8),$C(124),5)=$piece(%A(8),"|",5)
	S:'$D(vobj(dbtbl5h,-100,9,"SEQ9")) vobj(dbtbl5h,-100,9,"SEQ9")="U001"_$P(vobj(dbtbl5h,9),$C(124),1) S vobj(dbtbl5h,-100,9)="",$P(vobj(dbtbl5h,9),$C(124),1)=$piece(%A(9),"|",1)
	S:'$D(vobj(dbtbl5h,-100,9,"PGBK9")) vobj(dbtbl5h,-100,9,"PGBK9")="L002"_$P(vobj(dbtbl5h,9),$C(124),2) S vobj(dbtbl5h,-100,9)="",$P(vobj(dbtbl5h,9),$C(124),2)=$piece(%A(9),"|",2)
	S:'$D(vobj(dbtbl5h,-100,9,"PHDR9")) vobj(dbtbl5h,-100,9,"PHDR9")="L003"_$P(vobj(dbtbl5h,9),$C(124),3) S vobj(dbtbl5h,-100,9)="",$P(vobj(dbtbl5h,9),$C(124),3)=$piece(%A(9),"|",3)
	S:'$D(vobj(dbtbl5h,-100,9,"PRNG9")) vobj(dbtbl5h,-100,9,"PRNG9")="T004"_$P(vobj(dbtbl5h,9),$C(124),4) S vobj(dbtbl5h,-100,9)="",$P(vobj(dbtbl5h,9),$C(124),4)=$piece(%A(9),"|",4)
	S:'$D(vobj(dbtbl5h,-100,9,"SORTORD9")) vobj(dbtbl5h,-100,9,"SORTORD9")="U005"_$P(vobj(dbtbl5h,9),$C(124),5) S vobj(dbtbl5h,-100,9)="",$P(vobj(dbtbl5h,9),$C(124),5)=$piece(%A(9),"|",5)
	S:'$D(vobj(dbtbl5h,-100,10,"SEQ10")) vobj(dbtbl5h,-100,10,"SEQ10")="U001"_$P(vobj(dbtbl5h,10),$C(124),1) S vobj(dbtbl5h,-100,10)="",$P(vobj(dbtbl5h,10),$C(124),1)=$piece(%A(10),"|",1)
	S:'$D(vobj(dbtbl5h,-100,10,"PGBK10")) vobj(dbtbl5h,-100,10,"PGBK10")="L002"_$P(vobj(dbtbl5h,10),$C(124),2) S vobj(dbtbl5h,-100,10)="",$P(vobj(dbtbl5h,10),$C(124),2)=$piece(%A(10),"|",2)
	S:'$D(vobj(dbtbl5h,-100,10,"PHDR10")) vobj(dbtbl5h,-100,10,"PHDR10")="L003"_$P(vobj(dbtbl5h,10),$C(124),3) S vobj(dbtbl5h,-100,10)="",$P(vobj(dbtbl5h,10),$C(124),3)=$piece(%A(10),"|",3)
	S:'$D(vobj(dbtbl5h,-100,10,"PRNG10")) vobj(dbtbl5h,-100,10,"PRNG10")="T004"_$P(vobj(dbtbl5h,10),$C(124),4) S vobj(dbtbl5h,-100,10)="",$P(vobj(dbtbl5h,10),$C(124),4)=$piece(%A(10),"|",4)
	S:'$D(vobj(dbtbl5h,-100,10,"SORTORD10")) vobj(dbtbl5h,-100,10,"SORTORD10")="U005"_$P(vobj(dbtbl5h,10),$C(124),5) S vobj(dbtbl5h,-100,10)="",$P(vobj(dbtbl5h,10),$C(124),5)=$piece(%A(10),"|",5)
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(dbtbl5h) K vobj(dbtbl5h,-100) S vobj(dbtbl5h,-2)=1 Tcommit:vTp  
	K vobj(+$G(dbtbl5h)) Q 1
	;
STAT	; Called by ^FORMDQ5C for Statistics page
	;
	N PGM N SID N VFMQ
	;
	S SID="DBTBL5SQ"
	D ^USID I PGM="" Q 
	D ^@PGM Q:VFMQ="Q" 
	;
	N dbtbl5h S dbtbl5h=$$vDb1("SYSDEV",RID)
	 S vobj(dbtbl5h,11)=$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),11))
	 S vobj(dbtbl5h,12)=$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),12))
	 S vobj(dbtbl5h,13)=$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),13))
	 S vobj(dbtbl5h,14)=$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),14))
	 S vobj(dbtbl5h,15)=$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),15))
	 S vobj(dbtbl5h,16)=$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),16))
	 S vobj(dbtbl5h,17)=$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),17))
	 S vobj(dbtbl5h,18)=$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),18))
	 S vobj(dbtbl5h,19)=$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),19))
	 S vobj(dbtbl5h,20)=$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),20))
	 S vobj(dbtbl5h,21)=$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),21))
	 S vobj(dbtbl5h,22)=$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),22))
	 S vobj(dbtbl5h,23)=$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),23))
	 S vobj(dbtbl5h,24)=$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),24))
	 S vobj(dbtbl5h,25)=$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),25))
	 S vobj(dbtbl5h,26)=$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),26))
	 S vobj(dbtbl5h,27)=$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),27))
	 S vobj(dbtbl5h,28)=$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),28))
	 S vobj(dbtbl5h,29)=$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),29))
	 S vobj(dbtbl5h,30)=$G(^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),30))
	;
	S vobj(dbtbl5h,-100,11)="",$P(vobj(dbtbl5h,11),$C(124),1)=$piece(%A(11),"|",1)
	S vobj(dbtbl5h,-100,11)="",$P(vobj(dbtbl5h,11),$C(124),4)=$piece(%A(11),"|",4)
	S vobj(dbtbl5h,-100,11)="",$P(vobj(dbtbl5h,11),$C(124),5)=$piece(%A(11),"|",5)
	S vobj(dbtbl5h,-100,12)="",$P(vobj(dbtbl5h,12),$C(124),1)=$piece(%A(12),"|",1)
	S vobj(dbtbl5h,-100,12)="",$P(vobj(dbtbl5h,12),$C(124),4)=$piece(%A(12),"|",4)
	S vobj(dbtbl5h,-100,12)="",$P(vobj(dbtbl5h,12),$C(124),5)=$piece(%A(12),"|",5)
	S vobj(dbtbl5h,-100,13)="",$P(vobj(dbtbl5h,13),$C(124),1)=$piece(%A(13),"|",1)
	S vobj(dbtbl5h,-100,13)="",$P(vobj(dbtbl5h,13),$C(124),4)=$piece(%A(13),"|",4)
	S vobj(dbtbl5h,-100,13)="",$P(vobj(dbtbl5h,13),$C(124),5)=$piece(%A(13),"|",5)
	S vobj(dbtbl5h,-100,14)="",$P(vobj(dbtbl5h,14),$C(124),1)=$piece(%A(14),"|",1)
	S vobj(dbtbl5h,-100,14)="",$P(vobj(dbtbl5h,14),$C(124),4)=$piece(%A(14),"|",4)
	S vobj(dbtbl5h,-100,14)="",$P(vobj(dbtbl5h,14),$C(124),5)=$piece(%A(14),"|",5)
	S vobj(dbtbl5h,-100,15)="",$P(vobj(dbtbl5h,15),$C(124),1)=$piece(%A(15),"|",1)
	S vobj(dbtbl5h,-100,15)="",$P(vobj(dbtbl5h,15),$C(124),4)=$piece(%A(15),"|",4)
	S vobj(dbtbl5h,-100,15)="",$P(vobj(dbtbl5h,15),$C(124),5)=$piece(%A(15),"|",5)
	S vobj(dbtbl5h,-100,16)="",$P(vobj(dbtbl5h,16),$C(124),1)=$piece(%A(16),"|",1)
	S vobj(dbtbl5h,-100,16)="",$P(vobj(dbtbl5h,16),$C(124),4)=$piece(%A(16),"|",4)
	S vobj(dbtbl5h,-100,16)="",$P(vobj(dbtbl5h,16),$C(124),5)=$piece(%A(16),"|",5)
	S vobj(dbtbl5h,-100,17)="",$P(vobj(dbtbl5h,17),$C(124),1)=$piece(%A(17),"|",1)
	S vobj(dbtbl5h,-100,17)="",$P(vobj(dbtbl5h,17),$C(124),4)=$piece(%A(17),"|",4)
	S vobj(dbtbl5h,-100,17)="",$P(vobj(dbtbl5h,17),$C(124),5)=$piece(%A(17),"|",5)
	S vobj(dbtbl5h,-100,18)="",$P(vobj(dbtbl5h,18),$C(124),1)=$piece(%A(18),"|",1)
	S vobj(dbtbl5h,-100,18)="",$P(vobj(dbtbl5h,18),$C(124),4)=$piece(%A(18),"|",4)
	S vobj(dbtbl5h,-100,18)="",$P(vobj(dbtbl5h,18),$C(124),5)=$piece(%A(18),"|",5)
	S vobj(dbtbl5h,-100,19)="",$P(vobj(dbtbl5h,19),$C(124),1)=$piece(%A(19),"|",1)
	S vobj(dbtbl5h,-100,19)="",$P(vobj(dbtbl5h,19),$C(124),4)=$piece(%A(19),"|",4)
	S vobj(dbtbl5h,-100,19)="",$P(vobj(dbtbl5h,19),$C(124),5)=$piece(%A(19),"|",5)
	S vobj(dbtbl5h,-100,20)="",$P(vobj(dbtbl5h,20),$C(124),1)=$piece(%A(20),"|",1)
	S vobj(dbtbl5h,-100,20)="",$P(vobj(dbtbl5h,20),$C(124),4)=$piece(%A(20),"|",4)
	S vobj(dbtbl5h,-100,20)="",$P(vobj(dbtbl5h,20),$C(124),5)=$piece(%A(20),"|",5)
	S vobj(dbtbl5h,-100,21)="",$P(vobj(dbtbl5h,21),$C(124),1)=$piece(%A(21),"|",1)
	S vobj(dbtbl5h,-100,21)="",$P(vobj(dbtbl5h,21),$C(124),4)=$piece(%A(21),"|",4)
	S vobj(dbtbl5h,-100,21)="",$P(vobj(dbtbl5h,21),$C(124),5)=$piece(%A(21),"|",5)
	S vobj(dbtbl5h,-100,22)="",$P(vobj(dbtbl5h,22),$C(124),1)=$piece(%A(22),"|",1)
	S vobj(dbtbl5h,-100,22)="",$P(vobj(dbtbl5h,22),$C(124),4)=$piece(%A(22),"|",4)
	S vobj(dbtbl5h,-100,22)="",$P(vobj(dbtbl5h,22),$C(124),5)=$piece(%A(22),"|",5)
	S vobj(dbtbl5h,-100,23)="",$P(vobj(dbtbl5h,23),$C(124),1)=$piece(%A(23),"|",1)
	S vobj(dbtbl5h,-100,23)="",$P(vobj(dbtbl5h,23),$C(124),4)=$piece(%A(23),"|",4)
	S vobj(dbtbl5h,-100,23)="",$P(vobj(dbtbl5h,23),$C(124),5)=$piece(%A(23),"|",5)
	S vobj(dbtbl5h,-100,24)="",$P(vobj(dbtbl5h,24),$C(124),1)=$piece(%A(24),"|",1)
	S vobj(dbtbl5h,-100,24)="",$P(vobj(dbtbl5h,24),$C(124),4)=$piece(%A(24),"|",4)
	S vobj(dbtbl5h,-100,24)="",$P(vobj(dbtbl5h,24),$C(124),5)=$piece(%A(24),"|",5)
	S vobj(dbtbl5h,-100,25)="",$P(vobj(dbtbl5h,25),$C(124),1)=$piece(%A(25),"|",1)
	S vobj(dbtbl5h,-100,25)="",$P(vobj(dbtbl5h,25),$C(124),4)=$piece(%A(25),"|",4)
	S vobj(dbtbl5h,-100,25)="",$P(vobj(dbtbl5h,25),$C(124),5)=$piece(%A(25),"|",5)
	S vobj(dbtbl5h,-100,26)="",$P(vobj(dbtbl5h,26),$C(124),1)=$piece(%A(26),"|",1)
	S vobj(dbtbl5h,-100,26)="",$P(vobj(dbtbl5h,26),$C(124),4)=$piece(%A(26),"|",4)
	S vobj(dbtbl5h,-100,26)="",$P(vobj(dbtbl5h,26),$C(124),5)=$piece(%A(26),"|",5)
	S vobj(dbtbl5h,-100,27)="",$P(vobj(dbtbl5h,27),$C(124),1)=$piece(%A(27),"|",1)
	S vobj(dbtbl5h,-100,27)="",$P(vobj(dbtbl5h,27),$C(124),4)=$piece(%A(27),"|",4)
	S vobj(dbtbl5h,-100,27)="",$P(vobj(dbtbl5h,27),$C(124),5)=$piece(%A(27),"|",5)
	S vobj(dbtbl5h,-100,28)="",$P(vobj(dbtbl5h,28),$C(124),1)=$piece(%A(28),"|",1)
	S vobj(dbtbl5h,-100,28)="",$P(vobj(dbtbl5h,28),$C(124),4)=$piece(%A(28),"|",4)
	S vobj(dbtbl5h,-100,28)="",$P(vobj(dbtbl5h,28),$C(124),5)=$piece(%A(28),"|",5)
	S vobj(dbtbl5h,-100,29)="",$P(vobj(dbtbl5h,29),$C(124),1)=$piece(%A(29),"|",1)
	S vobj(dbtbl5h,-100,29)="",$P(vobj(dbtbl5h,29),$C(124),4)=$piece(%A(29),"|",4)
	S vobj(dbtbl5h,-100,29)="",$P(vobj(dbtbl5h,29),$C(124),5)=$piece(%A(29),"|",5)
	S vobj(dbtbl5h,-100,30)="",$P(vobj(dbtbl5h,30),$C(124),1)=$piece(%A(30),"|",1)
	S vobj(dbtbl5h,-100,30)="",$P(vobj(dbtbl5h,30),$C(124),4)=$piece(%A(30),"|",4)
	S vobj(dbtbl5h,-100,30)="",$P(vobj(dbtbl5h,30),$C(124),5)=$piece(%A(30),"|",5)
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D vReSav1(dbtbl5h) K vobj(dbtbl5h,-100) S vobj(dbtbl5h,-2)=1 Tcommit:vTp  
	K vobj(+$G(dbtbl5h)) Q 
	;
QUERY	;
	;
	N WIDTH
	N DATA N I N MESSAGE
	;
	; ~p1 - QUERY DEFINITIONS
	S MESSAGE=$$^MSG(7965,RID)
	;
	D LOADDATA(RID,.DATA,31,.WIDTH)
	;
	D ^DBSWRITE("DATA",3,22,99999,WIDTH,MESSAGE)
	;
	I ($D(DATA)>0) D SAVEDATA(RID,.DATA,31)
	;
	Q 
	;
KEYS	;
	;
	F  Q:'$$GROUP 
	;
	Q 
	;
GROUP()	;
	;
	N GRPDSC N GRPNO N GRPSEQ N I N SEL N START N WIDTH
	N DATA N GROUP N GRP N MESSAGE N SEQBY N X
	;
	; MODIFY USER DEFINED INFORMATION
	WRITE $$CLEAR^%TRMVT,!!,$$^MSG(7963),!
	;
	N dbtbl5h,vop1,vop2,vop3,vop4,vop5,vop6,vop7,vop8,vop9,vop10,vop11,vop12 S vop1="SYSDEV",vop2=RID,dbtbl5h=$$vDb3("SYSDEV",RID)
	 S vop3=$G(^DBTBL(vop1,5,vop2,1))
	 S vop4=$G(^DBTBL(vop1,5,vop2,2))
	 S vop5=$G(^DBTBL(vop1,5,vop2,3))
	 S vop6=$G(^DBTBL(vop1,5,vop2,4))
	 S vop7=$G(^DBTBL(vop1,5,vop2,5))
	 S vop8=$G(^DBTBL(vop1,5,vop2,6))
	 S vop9=$G(^DBTBL(vop1,5,vop2,7))
	 S vop10=$G(^DBTBL(vop1,5,vop2,8))
	 S vop11=$G(^DBTBL(vop1,5,vop2,9))
	 S vop12=$G(^DBTBL(vop1,5,vop2,10))
	;
	; If old compiler, set up sort-by groups first
	S SEQBY(1)=$P(vop3,$C(124),1)
	S SEQBY(2)=$P(vop4,$C(124),1)
	S SEQBY(3)=$P(vop5,$C(124),1)
	S SEQBY(4)=$P(vop6,$C(124),1)
	S SEQBY(5)=$P(vop7,$C(124),1)
	S SEQBY(6)=$P(vop8,$C(124),1)
	S SEQBY(7)=$P(vop9,$C(124),1)
	S SEQBY(8)=$P(vop10,$C(124),1)
	S SEQBY(9)=$P(vop11,$C(124),1)
	S SEQBY(10)=$P(vop12,$C(124),1)
	;
	S GRPSEQ=1
	;
	S GROUP(1)="@PRERP|Report Pre-Processor (before QUERY)|"_($$vDbEx3()) S GRPSEQ=GRPSEQ+1
	S GROUP(2)="@PRE|Report Pre-Processor (after QUERY)|"_($$vDbEx4()) S GRPSEQ=GRPSEQ+1
	S GROUP(3)="@POST|Report Post-Processor|"_($$vDbEx5()) S GRPSEQ=GRPSEQ+1
	S GROUP(4)="@DOC|Report Documentation|"_($$vDbEx6()) S GRPSEQ=GRPSEQ+1
	;
	S GROUP(5)="@VOPENPR|OPEN Pre-Processor|"_($$vDbEx7()) S GRPSEQ=GRPSEQ+1
	S GROUP(6)="@VOPENPP|OPEN Post-Processor|"_($$vDbEx8()) S GRPSEQ=GRPSEQ+1
	S GROUP(7)="@VFETCHPR|FETCH Pre-Processor|"_($$vDbEx9()) S GRPSEQ=GRPSEQ+1
	S GROUP(8)="@VFETCHPP|FETCH Post-Processor|"_($$vDbEx10()) S GRPSEQ=GRPSEQ+1
	S GROUP(9)="@PRINT|PRINT Pre-Processor|"_($$vDbEx11()) S GRPSEQ=GRPSEQ+1
	;
	; Display group selection
	D
	.	WRITE $$CUP^%TRMVT(0,5),$$CLP^%TRMVT,$$LINE^%TRMVT(80)
	.	S GRP=""
	.	F  S GRP=$order(GROUP(GRP)) Q:GRP=""  D
	..		WRITE $$VIDOFF^%TRMVT
	..		WRITE !,GRP,")",?6
	..		I $piece(GROUP(GRP),"|",3) WRITE $$VIDREV^%TRMVT
	..		WRITE " ",$piece(GROUP(GRP),"|",2)," "
	..		Q 
	.	;
	.	WRITE $$VIDOFF^%TRMVT
	.	Q 
	;
	; Select group
	F I=1:1:GRPSEQ-1 S SEL(I)=I
	;
	S GRPNO=$$^DBSMBAR(18,"","","",.SEL)
	I GRPNO="" Q 0
	;
	S GRP=$piece(GROUP(GRPNO),"|",1) S GRPDSC=$piece(GROUP(GRPNO),"|",2)
	;
	; Edit group and save changes
	I GRP="@PRERP" S START=111
	E  I GRP="@PRE" S START=51
	E  I GRP="@POST" S START=71
	E  I GRP="@DOC" S START=91
	E  I GRP="@VOPENPR" S START=201
	E  I GRP="@VOPENPP" S START=221
	E  I GRP="@VFETCHPR" S START=241
	E  I GRP="@VFETCHPP" S START=261
	E  I GRP="@PRINT" S START=281
	;
	S MESSAGE=RID_" - "_GRPDSC
	;
	D LOADDATA(RID,.DATA,START,.WIDTH)
	;
	D ^DBSWRITE("DATA",3,22,99999,WIDTH,MESSAGE)
	;
	I ($D(DATA)>0) D SAVEDATA(RID,.DATA,START)
	;
	Q 1
	;
LOADDATA(RID,ARRAY,START,WIDTH)	;
	;
	N CNT N END
	;
	S WIDTH=80
	;
	S END=START+20 S START=START-.001
	S CNT=1
	;
	N rs,vos1,vos2,vos3,vos4,vos5,vos6 S rs=$$vOpen4()
	;
	F  Q:'($$vFetch4())  D
	.	S ARRAY(CNT)=rs
	.	I $L(ARRAY(CNT))>78 S WIDTH=132
	.	S CNT=CNT+1
	.	Q 
	;
	Q 
	;
SAVEDATA(RID,ARRAY,START)	;
	;
	N END N N N OK N SEQ
	;
	S END=START+20 S START=START-.001
	;
	; Delete old data first
	D vDbDe4()
	;
	S OK=0 ; Signal once get non-nulls
	S SEQ=START
	S N=""
	F  S N=$order(ARRAY(N)) Q:N=""  D
	.	;
	.	I OK!(ARRAY(N)'="") D
	..		N dbtbl5pr,vop1,vop2,vop3,vop4 S dbtbl5pr="",vop3="",vop2="",vop1="",vop4=0
	..		S SEQ=SEQ+.001
	..	 S vop3="SYSDEV"
	..	 S vop2=RID
	..	 S vop1=SEQ
	..	 S $P(dbtbl5pr,$C(12),1)=ARRAY(N)
	..	 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^DBTBL(vop3,5,vop2,vop1)=dbtbl5pr S vop4=1 Tcommit:vTp  
	..		S OK=1
	..		Q 
	.	Q 
	;
	Q 
	;
VERSION()	;
	;
	Q ""
	;
vSIG()	;
	Q "60571^42180^Dan Russell^17703" ; Signature - LTD^TIME^USER^SIZE
	; ----------------
	;  #OPTION ResultClass 0
vDbDe1()	; DELETE FROM TMPDQ WHERE PID=:V1
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen5()
	F  Q:'($$vFetch5())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^TEMP(v1,v2)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe2()	; DELETE FROM TMPDQ WHERE PID=:V1
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen6()
	F  Q:'($$vFetch6())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^TEMP(v1,v2)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe3()	; DELETE FROM TMPDQ WHERE PID=:V2
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3 S vRs=$$vOpen7()
	F  Q:'($$vFetch7())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^TEMP(v1,v2)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	; ----------------
	;  #OPTION ResultClass 0
vDbDe4()	; DELETE FROM DBTBL5PR WHERE RID=:RID AND SEQ>:START AND SEQ<:END
	;
	;  #OPTIMIZE FUNCTIONS OFF
	N v1 N v2 N v3
	Tstart (vobj):transactionid="CS"
	N vRs,vos1,vos2,vos3,vos4,vos5,vos6 S vRs=$$vOpen8()
	F  Q:'($$vFetch8())  D
	.	S v1=$P(vRs,$C(9),1) S v2=$P(vRs,$C(9),2) S v3=$P(vRs,$C(9),3)
	.	;     #ACCEPT CR=18163;DATE=2006-01-09;PGM=FSCW;GROUP=BYPASS
	.	;*** Start of code by-passed by compiler
	.	ZWI ^DBTBL(v1,5,v2,v3)
	.	;*** End of code by-passed by compiler ***
	.	Q 
	Tcommit:$Tlevel 
	Q 
	;
vDb1(v1,v2)	;	vobj()=Db.getRecord(DBTBL5H,,0)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL5H"
	S vobj(vOid)=$G(^DBTBL(v1,5,v2))
	I vobj(vOid)="",'$D(^DBTBL(v1,5,v2))
	S vobj(vOid,-2)=1
	I $T K vobj(vOid) S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL5H" X $ZT
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vDb3(v1,v2)	;	voXN = Db.getRecord(DBTBL5H,,0)
	;
	N dbtbl5h
	S dbtbl5h=$G(^DBTBL(v1,5,v2))
	I dbtbl5h="",'$D(^DBTBL(v1,5,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL5H" X $ZT
	Q dbtbl5h
	;
vDb4(v1,v2)	;	voXN = Db.getRecord(DBTBL1,,0)
	;
	N dbtbl1
	S dbtbl1=$G(^DBTBL(v1,1,v2))
	I dbtbl1="",'$D(^DBTBL(v1,1,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1" X $ZT
	Q dbtbl1
	;
vDbEx10()	;	min(1): DISTINCT LIBS,RID,SEQ FROM DBTBL5PR WHERE LIBS='SYSDEV' AND RID=:RID AND SEQ='261'
	;
	; No vsql* lvns needed
	;
	I '("261"]]30.999) Q 0
	I '($D(^DBTBL("SYSDEV",5,RID,"261"))#2) Q 0
	Q 1
	;
vDbEx11()	;	min(1): DISTINCT LIBS,RID,SEQ FROM DBTBL5PR WHERE LIBS='SYSDEV' AND RID=:RID AND SEQ='281'
	;
	; No vsql* lvns needed
	;
	I '("281"]]30.999) Q 0
	I '($D(^DBTBL("SYSDEV",5,RID,"281"))#2) Q 0
	Q 1
	;
vDbEx3()	;	min(1): DISTINCT LIBS,RID,SEQ FROM DBTBL5PR WHERE LIBS='SYSDEV' AND RID=:RID AND SEQ='111'
	;
	; No vsql* lvns needed
	;
	I '("111"]]30.999) Q 0
	I '($D(^DBTBL("SYSDEV",5,RID,"111"))#2) Q 0
	Q 1
	;
vDbEx4()	;	min(1): DISTINCT LIBS,RID,SEQ FROM DBTBL5PR WHERE LIBS='SYSDEV' AND RID=:RID AND SEQ='51'
	;
	; No vsql* lvns needed
	;
	I '("51"]]30.999) Q 0
	I '($D(^DBTBL("SYSDEV",5,RID,"51"))#2) Q 0
	Q 1
	;
vDbEx5()	;	min(1): DISTINCT LIBS,RID,SEQ FROM DBTBL5PR WHERE LIBS='SYSDEV' AND RID=:RID AND SEQ='71'
	;
	; No vsql* lvns needed
	;
	I '("71"]]30.999) Q 0
	I '($D(^DBTBL("SYSDEV",5,RID,"71"))#2) Q 0
	Q 1
	;
vDbEx6()	;	min(1): DISTINCT LIBS,RID,SEQ FROM DBTBL5PR WHERE LIBS='SYSDEV' AND RID=:RID AND SEQ='91'
	;
	; No vsql* lvns needed
	;
	I '("91"]]30.999) Q 0
	I '($D(^DBTBL("SYSDEV",5,RID,"91"))#2) Q 0
	Q 1
	;
vDbEx7()	;	min(1): DISTINCT LIBS,RID,SEQ FROM DBTBL5PR WHERE LIBS='SYSDEV' AND RID=:RID AND SEQ='201'
	;
	; No vsql* lvns needed
	;
	I '("201"]]30.999) Q 0
	I '($D(^DBTBL("SYSDEV",5,RID,"201"))#2) Q 0
	Q 1
	;
vDbEx8()	;	min(1): DISTINCT LIBS,RID,SEQ FROM DBTBL5PR WHERE LIBS='SYSDEV' AND RID=:RID AND SEQ='221'
	;
	; No vsql* lvns needed
	;
	I '("221"]]30.999) Q 0
	I '($D(^DBTBL("SYSDEV",5,RID,"221"))#2) Q 0
	Q 1
	;
vDbEx9()	;	min(1): DISTINCT LIBS,RID,SEQ FROM DBTBL5PR WHERE LIBS='SYSDEV' AND RID=:RID AND SEQ='241'
	;
	; No vsql* lvns needed
	;
	I '("241"]]30.999) Q 0
	I '($D(^DBTBL("SYSDEV",5,RID,"241"))#2) Q 0
	Q 1
	;
vDbNew2(v1,v2)	;	vobj()=Class.new(DBTBL5H)
	;
	N vOid
	 S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordDBTBL5H",vobj(vOid,-2)=0,vobj(vOid)=""
	S vobj(vOid,-3)=v1
	S vobj(vOid,-4)=v2
	Q vOid
	;
vOpen1()	;	RID FROM DBTBL5H WHERE LIBS='SYSDEV'
	;
	;
	S vos1=2
	D vL1a1
	Q ""
	;
vL1a0	S vos1=0 Q
vL1a1	S vos2=""
vL1a2	S vos2=$O(^DBTBL("SYSDEV",5,vos2),1) I vos2="" G vL1a0
	Q
	;
vFetch1()	;
	;
	;
	I vos1=1 D vL1a2
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S rs=$S(vos2=$C(254):"",1:vos2)
	;
	Q 1
	;
vOpen2()	;	ELEMENT FROM TMPDQ WHERE PID=:PID
	;
	;
	S vos1=2
	D vL2a1
	Q ""
	;
vL2a0	S vos1=0 Q
vL2a1	S vos2=$G(PID) I vos2="" G vL2a0
	S vos3=""
vL2a3	S vos3=$O(^TEMP(vos2,vos3),1) I vos3="" G vL2a0
	Q
	;
vFetch2()	;
	;
	;
	I vos1=1 D vL2a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S tmpdqrs=$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen3()	;	ELEMENT FROM TMPDQ WHERE PID=:V1
	;
	;
	S vos1=2
	D vL3a1
	Q ""
	;
vL3a0	S vos1=0 Q
vL3a1	S vos2=$G(V1) I vos2="" G vL3a0
	S vos3=""
vL3a3	S vos3=$O(^TEMP(vos2,vos3),1) I vos3="" G vL3a0
	Q
	;
vFetch3()	;
	;
	;
	I vos1=1 D vL3a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S tmpdqrs=$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen4()	;	DATA FROM DBTBL5PR WHERE LIBS='SYSDEV' AND RID=:RID AND SEQ>:START AND SEQ<:END ORDER BY SEQ ASC
	;
	;
	S vos1=2
	D vL4a1
	Q ""
	;
vL4a0	S vos1=0 Q
vL4a1	S vos2=$G(RID) I vos2="" G vL4a0
	S vos3=$G(START) I vos3="",'$D(START) G vL4a0
	S vos4=$G(END) I vos4="",'$D(END) G vL4a0
	S vos5=30.999
vL4a5	S vos5=$O(^DBTBL("SYSDEV",5,vos2,vos5),1) I vos5=""!(vos4']]vos5) G vL4a0
	I '(vos5]]vos3) G vL4a5
	Q
	;
vFetch4()	;
	;
	I vos1=1 D vL4a5
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vos6=$G(^DBTBL("SYSDEV",5,vos2,vos5))
	S rs=$P(vos6,$C(12),1)
	;
	Q 1
	;
vOpen5()	;	PID,ELEMENT FROM TMPDQ WHERE PID=:V1
	;
	;
	S vos1=2
	D vL5a1
	Q ""
	;
vL5a0	S vos1=0 Q
vL5a1	S vos2=$G(V1) I vos2="" G vL5a0
	S vos3=""
vL5a3	S vos3=$O(^TEMP(vos2,vos3),1) I vos3="" G vL5a0
	Q
	;
vFetch5()	;
	;
	;
	I vos1=1 D vL5a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen6()	;	PID,ELEMENT FROM TMPDQ WHERE PID=:V1
	;
	;
	S vos1=2
	D vL6a1
	Q ""
	;
vL6a0	S vos1=0 Q
vL6a1	S vos2=$G(V1) I vos2="" G vL6a0
	S vos3=""
vL6a3	S vos3=$O(^TEMP(vos2,vos3),1) I vos3="" G vL6a0
	Q
	;
vFetch6()	;
	;
	;
	I vos1=1 D vL6a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen7()	;	PID,ELEMENT FROM TMPDQ WHERE PID=:V2
	;
	;
	S vos1=2
	D vL7a1
	Q ""
	;
vL7a0	S vos1=0 Q
vL7a1	S vos2=$G(V2) I vos2="" G vL7a0
	S vos3=""
vL7a3	S vos3=$O(^TEMP(vos2,vos3),1) I vos3="" G vL7a0
	Q
	;
vFetch7()	;
	;
	;
	I vos1=1 D vL7a3
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=vos2_$C(9)_$S(vos3=$C(254):"",1:vos3)
	;
	Q 1
	;
vOpen8()	;	LIBS,RID,SEQ FROM DBTBL5PR WHERE RID=:RID AND SEQ>:START AND SEQ<:END
	;
	;
	S vos1=2
	D vL8a1
	Q ""
	;
vL8a0	S vos1=0 Q
vL8a1	S vos2=$G(RID) I vos2="" G vL8a0
	S vos3=$G(START) I vos3="",'$D(START) G vL8a0
	S vos4=$G(END) I vos4="",'$D(END) G vL8a0
	S vos5=""
vL8a5	S vos5=$O(^DBTBL(vos5),1) I vos5="" G vL8a0
	S vos6=30.999
vL8a7	S vos6=$O(^DBTBL(vos5,5,vos2,vos6),1) I vos6=""!(vos4']]vos6) G vL8a5
	I '(vos6]]vos3) G vL8a7
	Q
	;
vFetch8()	;
	;
	;
	I vos1=1 D vL8a7
	I vos1=2 S vos1=1
	;
	I vos1=0 Q 0
	;
	S vRs=$S(vos5=$C(254):"",1:vos5)_$C(9)_vos2_$C(9)_$S(vos6=$C(254):"",1:vos6)
	;
	Q 1
	;
vReSav1(dbtbl5h)	;	RecordDBTBL5H saveNoFiler()
	;
	S ^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4))=$$RTBAR^%ZFUNC($G(vobj(dbtbl5h)))
	N vD,vN S vN=-1
	I '$G(vobj(dbtbl5h,-2)) F  S vN=$O(vobj(dbtbl5h,vN)) Q:vN=""  S vD=$$RTBAR^%ZFUNC(vobj(dbtbl5h,vN)) S:vD'="" ^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),vN)=vD
	E  F  S vN=$O(vobj(dbtbl5h,-100,vN)) Q:vN=""  I $D(vobj(dbtbl5h,vN))#2 S vD=$$RTBAR^%ZFUNC(vobj(dbtbl5h,vN)) S:vD'="" ^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),vN)=vD I vD="" ZWI ^DBTBL(vobj(dbtbl5h,-3),5,vobj(dbtbl5h,-4),vN)
	Q
	;
vtrap1	;	Error trap
	;
	N error S error=$ZS
	N ET
	D ET^%ZT(.ET)
	I ET="INTERRUPT" S STOP=1
	E  USE 0 WRITE !!,$get(RID),?15,$P(error,",",2),",",$P(error,",",3),",",$P(error,",",4),!
	Q 
