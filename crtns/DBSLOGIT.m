DBSLOGIT(recobj,mode,vx)	; Log table changes to LOG table
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSLOGIT ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	N I
	N delim N keys N keyvals N table
	;
	I '($D(%LOGID)#2) S %LOGID=$$LOGID^SCADRV
	;
	Q:(+%LOGID'=+0) 
	;
	S table=$piece(vobj(recobj,-1),"Record",2,99)
	;
	N tblrec S tblrec=$$getSchTbl^UCXDD(table)
	;
	S delim=$char(($P(tblrec,"|",10)))
	S keys=$P(tblrec,"|",3)
	;
	S keyvals=""
	I '(keys="") F I=1:1:$L(keys,",") D
	.	N key N typ N val
	.	;
	.	S key=$piece(keys,",",I)
	.	;
	.	N dbtbl1d S dbtbl1d=$$vDb3("SYSDEV",table,key)
	.	;
	.	S typ=$P(dbtbl1d,$C(124),9)
	.	S val=vobj(recobj,-(I+2))
	.	;
	.	I (",T,U,F,"[(","_typ_",")) S val=$S(val'["""":""""_val_"""",1:$$QADD^%ZS(val,""""))
	.	E  I (",D,C,"[(","_typ_",")) S val=$$EXT^%ZM(val,typ)
	.	;
	.	S keyvals=keyvals_val_","
	.	Q 
	;
	S keyvals=$E(keyvals,1,$L(keyvals)-1)
	;
	; Convert change info in vobj(,-100) into vx() array
	I ($D(vx)=0) D AUDIT^UCUTILN(recobj,.vx,$P(tblrec,"|",4),delim)
	;
	Tstart (vobj):transactionid="CS"
	;
	; If mode is delete (3) or there are no columns audited, just file LOG
	I ((mode=3)!'$D(vx)) D
	.	;
	.	N SEQ
	.	;
	.	S SEQ=$$LOG(table,keys,keyvals,mode)
	.	Q 
	;
	; For create mode, file values under one SEQ, in blocks
	E  I (mode=0) D
	.	;
	.	N SEQ N SUBSEQ
	.	N collist N column N newval N oldval N vallist
	.	;
	.	; Insert into LOG table and return SEQ for LOG1
	.	S SEQ=$$LOG(table,keys,keyvals,mode)
	.	;
	.	S SUBSEQ=1
	.	S (collist,column,vallist)=""
	.	F  S column=$order(vx(column)) D  Q:(column="") 
	..		;
	..		I '(column="") D
	...			;
	...			S newval=$piece(vx(column),delim,2)
	...			;
	...			I (",T,U,F,"[(","_$piece(vx(column),delim,4)_",")) S newval=$S(newval'["""":""""_newval_"""",1:$$QADD^%ZS(newval,""""))
	...			Q 
	..		E  S newval=""
	..		;
	..		; If done or we get long enough, file and start again
	..		I ((column="")!($L(collist)+$L(column)>255)!($L(vallist)+$L(newval)>255)) D
	...			;
	...			S collist=$E(collist,1,$L(collist)-1)
	...			S vallist=$E(vallist,1,$L(vallist)-1)
	...			;
	...			D LOG1(SEQ,SUBSEQ,collist,vallist,"")
	...			;
	...			S SUBSEQ=SUBSEQ+1
	...			S (collist,vallist)=""
	...			Q 
	..		;
	..		S collist=collist_column_","
	..		S vallist=vallist_newval_$char(1)
	..		Q 
	.	Q 
	;
	; For update mode, file each value as separate SEQ
	E  I (mode=1) D
	.	;
	.	N SEQ
	.	N column N newval N oldval
	.	;
	.	S column=""
	.	F  S column=$order(vx(column)) Q:(column="")  D
	..		;
	..		; Insert into LOG table and return SEQ for LOG1
	..		S SEQ=$$LOG(table,keys,keyvals,mode)
	..		;
	..		S oldval=$piece(vx(column),delim,1)
	..		S newval=$piece(vx(column),delim,2)
	..		;
	..		I (",T,U,F,"[(","_$piece(vx(column),delim,4)_",")) D
	...			S oldval=$S(oldval'["""":""""_oldval_"""",1:$$QADD^%ZS(oldval,""""))
	...			S newval=$S(newval'["""":""""_newval_"""",1:$$QADD^%ZS(newval,""""))
	...			Q 
	..		;
	..		D LOG1(SEQ,1,column,newval,oldval)
	..		Q 
	.	Q 
	;
	Tcommit:$Tlevel 
	;
	Q 
	;
LOG(table,keys,keyvals,mode)	;
	;
	N SEQ
	;
	F  D  Q:(SEQ>0)  ; Loop on GETSEQ
	.	;
	.	N CNT N GETSEQ
	.	;
	.	; Get unique sequence number
	.	S GETSEQ=$$GETSEQ^SQLDD("LOG")
	.	S CNT=0
	.	;
	.	F  D  Q:(SEQ>0)  ; Loop on CNT
	..		;
	..		S SEQ=(GETSEQ*100)+CNT
	..		;
	..		N log,vop1,vop2,vop3 S vop2=$P($H,",",1),vop1=SEQ,log=$$vDb4(vop2,SEQ,.vop3)
	..		;
	..		I ($G(vop3)>0) D
	...			;
	...			S SEQ=0
	...			S CNT=CNT+1
	...			;
	...			I (CNT>99) D
	....				;
	....				HANG 1
	....				;
	....				S GETSEQ=$$GETSEQ^SQLDD("LOG")
	....				S CNT=0
	....				Q 
	...			Q 
	..		; Otherwise, log it
	..		E  D
	...			;
	...		 S $P(log,$C(124),1)=table
	...		 S $P(log,$C(124),2)=keys
	...		 S $P(log,$C(124),3)=keyvals
	...		 S $P(log,$C(124),4)=mode
	...		 S $P(log,$C(124),5)=$get(%UID)
	...		 S $P(log,$C(124),6)=$get(TLO)
	...		 S $P(log,$C(124),7)="SYSDEV"
	...		 S $P(log,$C(124),8)=$P($H,",",2)
	...			;
	...		 N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^LOG(vop2,vop1)=$$RTBAR^%ZFUNC(log) S vop3=1 Tcommit:vTp  
	...			Q 
	..		Q 
	.	Q 
	;
	Q SEQ
	;
LOG1(SEQ,SUBSEQ,columns,newvals,oldvals)	;
	;
	N log1,vop1,vop2,vop3,vop4 S log1="",vop3=$P($H,",",1),vop2=SEQ,vop1=SUBSEQ,vop4=0
	S $P(log1,$C(124),1)=columns
	S $P(log1,$C(124),2)=newvals
	S $P(log1,$C(124),3)=oldvals
	;
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" S ^LOG(vop3,vop2,vop1)=$$RTBAR^%ZFUNC(log1) S vop4=1 Tcommit:vTp  
	;
	Q 
	;
vSIG()	;
	Q "60736^67227^Dan Russell^5903" ; Signature - LTD^TIME^USER^SIZE
	;
vDb3(v1,v2,v3)	;	voXN = Db.getRecord(DBTBL1D,,0)
	;
	N dbtbl1d
	S dbtbl1d=$G(^DBTBL(v1,1,v2,9,v3))
	I dbtbl1d="",'$D(^DBTBL(v1,1,v2,9,v3))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1D" X $ZT
	Q dbtbl1d
	;
vDb4(v1,v2,v2out)	;	voXN = Db.getRecord(LOG,,1,-2)
	;
	N log
	S log=$G(^LOG(v1,v2))
	I log="",'$D(^LOG(v1,v2))
	S v2out='$T
	;
	Q log
