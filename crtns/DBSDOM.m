 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSDOM ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSDOM ; 
 ;
 Q  ; No entry from top
 ;
CREATE ; 
 N vTp
 ;
 N isDone
 N SYSSN
 ;
 S SYSSN=""
 ;
 S isDone=0
 F  D  Q:isDone 
 .	;
 .	N DELETE
 .	N DOM N MSG N VFMQ
 .	;
 .	S DOM=""
 .	S DELETE=0
 .	;
 .	N fDBSDOM S fDBSDOM=$$vcdmNew^RecordDBSDOM()
 .	;
 . N vo1 N vo2 N vo3 N vo4 D DRV^USID(0,"DBSDOM",.fDBSDOM,.vo1,.vo2,.vo3,.vo4) K vobj(+$G(vo1)) K vobj(+$G(vo2)) K vobj(+$G(vo3)) K vobj(+$G(vo4))
 .	;
 .	I VFMQ="F" D
 ..		;
 ..		I DELETE D
 ...			;
 ...			 N V1,V2 S V1=vobj(fDBSDOM,-3),V2=vobj(fDBSDOM,-4) D vDbDe1()
 ...			;
 ...			; Domain ~p1 deleted
 ...			S MSG=$$^MSG(853,vobj(fDBSDOM,-4))
 ...			Q 
 ..		E  D
 ...			;
 ...			; Domain ~p1 created
 ...			I ($G(vobj(fDBSDOM,-2))=0) S MSG=$$^MSG(852,vobj(fDBSDOM,-4))
 ...			; Domain ~p1 modified
 ...			E  S MSG=$$^MSG(854,vobj(fDBSDOM,-4))
 ...			;
 ...		 S vTp=($TL=0) TS:vTp (vobj):transactionid="CS" D vSave^RecordDBSDOM(fDBSDOM,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/") K vobj(fDBSDOM,-100) S vobj(fDBSDOM,-2)=1 TC:vTp  
 ...			Q 
 ..		;
 ..		; ~p1 ... Continue?
 ..		S MSG=$$^MSG(3008,MSG)
 ..		Q 
 .	; Continue?
 .	E  S MSG=$$^MSG(603)
 .	;
 .	I '$$YN^DBSMBAR("",MSG,1) S isDone=1
 .	K vobj(+$G(fDBSDOM)) Q 
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "60913^65027^Dan Russell^1480" ; Signature - LTD^TIME^USER^SIZE
 ; ----------------
 ;  #OPTION ResultClass 1
vDbDe1() ; DELETE FROM DBSDOM WHERE SYSSN=:V1 AND DOM=:V2
 ;
 ;  #OPTIMIZE FUNCTIONS OFF
 TS (vobj):transactionid="CS"
 N vRec S vRec=$$vRCgetRecord1^RecordDBSDOM(V1,V2,0)
 I $G(vobj(vRec,-2))=1 S vobj(vRec,-2)=3 D
 .	;     #ACCEPT Date=07/09/2008; Pgm=RussellDS; CR=30801; Group=BYPASS
 .	;*** Start of code by-passed by compiler
 .	D vSave^RecordDBSDOM(vRec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",0)
 .	;*** End of code by-passed by compiler ***
 .	Q 
  TC:$TL 
 K vobj(+$G(vRec)) Q 
