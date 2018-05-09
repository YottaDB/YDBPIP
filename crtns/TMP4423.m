TMP4423	; DBSEDIT temporary filer compiled program
	;
	; 11/09/2007 11:22 - chenardp
	;
	; Last compiled:  11/09/2007 11:22 AM - chenardp
	;
	; THIS IS A COMPILED ROUTINE.  Compiled by procedure DBSEDIT
	;
	Q:($J'=14423) 
	N rec S rec=$$vDb1("SCA$IBS")
	S:'$D(vobj(rec,-100,"0*","DESC")) vobj(rec,-100,"0*","DESC")="T001"_$P(vobj(rec),$C(124),1) S vobj(rec,-100,"0*")="",$P(vobj(rec),$C(124),1)="Profile Server"
	S:'$D(vobj(rec,-100,"0*","TIMEOUT")) vobj(rec,-100,"0*","TIMEOUT")="N008"_$P(vobj(rec),$C(124),8) S vobj(rec,-100,"0*")="",$P(vobj(rec),$C(124),8)="45"
	S:'$D(vobj(rec,-100,"0*","FAP")) vobj(rec,-100,"0*","FAP")="T002"_$P(vobj(rec),$C(124),2)_"||||||||||DESC]FAP" S vobj(rec,-100,"0*")="",$P(vobj(rec),$C(124),2)=""
	S:'$D(vobj(rec,-100,"0*","TRUST")) vobj(rec,-100,"0*","TRUST")="L003"_$P(vobj(rec),$C(124),3) S vobj(rec,-100,"0*")="",$P(vobj(rec),$C(124),3)="0"
	S:'$D(vobj(rec,-100,"0*","SVRPGM")) vobj(rec,-100,"0*","SVRPGM")="T004"_$P(vobj(rec),$C(124),4) S vobj(rec,-100,"0*")="",$P(vobj(rec),$C(124),4)=""
	S:'$D(vobj(rec,-100,"0*","STATTIM")) vobj(rec,-100,"0*","STATTIM")="N005"_$P(vobj(rec),$C(124),5) S vobj(rec,-100,"0*")="",$P(vobj(rec),$C(124),5)=""
	S:'$D(vobj(rec,-100,"0*","LOGMSG")) vobj(rec,-100,"0*","LOGMSG")="L006"_$P(vobj(rec),$C(124),6) S vobj(rec,-100,"0*")="",$P(vobj(rec),$C(124),6)="1"
	S:'$D(vobj(rec,-100,"0*","LOGREPLY")) vobj(rec,-100,"0*","LOGREPLY")="L007"_$P(vobj(rec),$C(124),7) S vobj(rec,-100,"0*")="",$P(vobj(rec),$C(124),7)="1"
	S:'$D(vobj(rec,-100,"0*","GETMSG")) vobj(rec,-100,"0*","GETMSG")="N009"_$P(vobj(rec),$C(124),9) S vobj(rec,-100,"0*")="",$P(vobj(rec),$C(124),9)=""
	S:'$D(vobj(rec,-100,"0*","TRAPMSG")) vobj(rec,-100,"0*","TRAPMSG")="L010"_$P(vobj(rec),$C(124),10) S vobj(rec,-100,"0*")="",$P(vobj(rec),$C(124),10)="1"
	S:'$D(vobj(rec,-100,"0*","MTNAME")) vobj(rec,-100,"0*","MTNAME")="T011"_$P(vobj(rec),$C(124),11)_"||||||||||DES]MTNAME" S vobj(rec,-100,"0*")="",$P(vobj(rec),$C(124),11)="MTM"
	S:'$D(vobj(rec,-100,"0*","MSGPGM")) vobj(rec,-100,"0*","MSGPGM")="T012"_$P(vobj(rec),$C(124),12) S vobj(rec,-100,"0*")="",$P(vobj(rec),$C(124),12)=""
	N vTp S vTp=0 S:($Tlevel=0) vTp=1 Tstart:vTp (vobj):transactionid="CS" D ^SVTYPFL(rec,"/CASDEL/INDEX/JOURNAL/LOG/TRIGAFT/TRIGBEF/UPDATE/VALDD/VALFK/VALREQ/VALRI/VALST/",1) K vobj(rec,-100) S vobj(rec,-2)=1 Tcommit:vTp  
	K vobj(+$G(rec)) Q 
	;
vDb1(v1)	;	vobj()=Db.getRecord(CTBLSVTYP,,1)
	;
	N vOid
	S vOid=$O(vobj(""),-1)+1,vobj(vOid,-1)="RecordCTBLSVTYP"
	S vobj(vOid)=$G(^CTBL("SVTYP",v1))
	I vobj(vOid)="",'$D(^CTBL("SVTYP",v1))
	S vobj(vOid,-2)='$T
	;
	S vobj(vOid,-3)=v1
	Q vOid
