 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSLOGIT ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSLOGIT(recobj,mode,vx) ; Log table changes to LOG table
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
 N tblrec S tblrec=$$getPslTbl^UCXDD(table,0)
 ;
 S delim=$char($P(tblrec,"|",10))
 S keys=$P(tblrec,"|",3)
 ;
 S keyvals=""
 I '(keys="") F I=1:1:$L(keys,",") D
 .	N key N typ N val
 .	;
 .	S key=$piece(keys,",",I)
 .	;
 .	N dbtbl1d S dbtbl1d=$$vRCgetRecord0Opt^RecordDBTBL1D("SYSDEV",table,key,0,"")
 .	;
 .	S typ=$P(dbtbl1d,$C(124),9)
 .	S val=vobj(recobj,-(I+2))
 .	;
 .	I ((","_"T,U,F"_",")[(","_typ_",")) S val=$S(val'["""":""""_val_"""",1:$$QADD^%ZS(val,""""))
 .	E  I ((","_"D,C"_",")[(","_typ_",")) S val=$$EXT^%ZM(val,typ)
 .	;
 .	S keyvals=keyvals_val_","
 . Q 
 ;
 S keyvals=$E(keyvals,1,$L(keyvals)-1)
 ;
 ; Convert change info in vobj(,-100) into vx() array
 I ($D(vx)=0) D AUDIT^UCUTILN(recobj,.vx,$P(tblrec,"|",4),delim)
 ;
 TS (vobj):transactionid="CS"
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
 ...			I ((","_"T,U,F"_",")[(","_$piece(vx(column),delim,4)_",")) S newval=$S(newval'["""":""""_newval_"""",1:$$QADD^%ZS(newval,""""))
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
 ..		I ((","_"T,U,F"_",")[(","_$piece(vx(column),delim,4)_",")) D
 ...			S oldval=$S(oldval'["""":""""_oldval_"""",1:$$QADD^%ZS(oldval,""""))
 ...			S newval=$S(newval'["""":""""_newval_"""",1:$$QADD^%ZS(newval,""""))
 ...			Q 
 ..		;
 ..		D LOG1(SEQ,1,column,newval,oldval)
 ..		Q 
 .	Q 
 ;
  TC:$TL 
 ;
 Q 
 ;
LOG(table,keys,keyvals,mode) ; Access mode (%O)
 N vTp
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
 ..		N log S log=$$vRCgetRecord1^RecordLOG($P($H,",",1),SEQ,0)
 ..		;
 ..		I ($G(vobj(log,-2))>0) D
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
 ...		  S $P(vobj(log),$C(124),1)=table
 ...		  S $P(vobj(log),$C(124),2)=keys
 ...		  S $P(vobj(log),$C(124),3)=keyvals
 ...		  S $P(vobj(log),$C(124),4)=mode
 ...		  S $P(vobj(log),$C(124),5)=$get(%UID)
 ...		  S $P(vobj(log),$C(124),6)=$get(TLO)
 ...		  S $P(vobj(log),$C(124),7)="SYSDEV"
 ...		  S $P(vobj(log),$C(124),8)=$P($H,",",2)
 ...			;
 ...		 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordLOG(log,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(log,-100) S vobj(log,-2)=1 TC:vTp  
 ...			Q 
 ..		K vobj(+$G(log)) Q 
 .	Q 
 ;
 Q SEQ
 ;
LOG1(SEQ,SUBSEQ,columns,newvals,oldvals) ; New value(s)
 N vTp
 ;
 N log1 S log1=$$vcdmNew^RecordLOG1() S vobj(log1,-3)=$P($H,",",1) S vobj(log1,-4)=SEQ S vobj(log1,-5)=SUBSEQ
  S $P(vobj(log1),$C(124),1)=columns
  S $P(vobj(log1),$C(124),2)=newvals
  S $P(vobj(log1),$C(124),3)=oldvals
 ;
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordLOG1(log1,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(log1,-100) S vobj(log1,-2)=1 TC:vTp  
 ;
 K vobj(+$G(log1)) Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61254^68964^Dan Russell^6091" ; Signature - LTD^TIME^USER^SIZE
