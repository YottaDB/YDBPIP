 ; 
 ; **** Routine compiled from unknown source ****
 ; 
 ; 02/16/2010 16:04 - tc
 ; 
TMP4695 ; DBSEDIT temporary filer compiled program
 N vTp
 ; Last compiled:  02/16/2010 04:04 PM - tc
 ;
 ; THIS IS A COMPILED ROUTINE.  Compiled by procedure DBSEDIT
 ;
 Q:($J'=4695) 
 N rec S rec=$$vRCgetRecord1^RecordCTBLMTM("PIPV02",0)
  S:'$D(vobj(rec,-100,"0*","DESC")) vobj(rec,-100,"0*","DESC")="T001"_$P(vobj(rec),$C(124),1),vobj(rec,-100,"0*")="" S $P(vobj(rec),$C(124),1)="PIP V0.2 MTM"
  S:'$D(vobj(rec,-100,"0*","STARTUP")) vobj(rec,-100,"0*","STARTUP")="T002"_$P(vobj(rec),$C(124),2),vobj(rec,-100,"0*")="" S $P(vobj(rec),$C(124),2)="/home/tc/pip_V02/mtm/PIPMTM"
 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordCTBLMTM(rec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(rec,-100) S vobj(rec,-2)=1 TC:vTp  
 K vobj(+$G(rec)) Q 
