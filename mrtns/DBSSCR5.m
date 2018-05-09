DBSSCR5	; DBS - U - V5.0 - Screen compiler, page #2
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/17/94 10:32:51 - XUS
	;     ORIG:  Bob (8447) - 04/08/87
	;     DESC: DECODE USER DEFINED REQ SET DEFINITIONS
	;
	;    INPUT:             X = (BAL,IRN) OR (BAL-,IRN-)
	;           %NAMCUR(DINAM)= LLTT
	;   OUTPUT:
        ; I18N=QUIT: Exculded from I18N standards.
	;
	;---------- Revision History -------------------------------------------
	;
	; 09/27/94 - Shaodong Tony Xu - I18N
	;            Change $N to $O.
	;
	; 07/26/94 - Steve Canfield - I18N
	;	     Converted msgid from DQnnnn to nnnn.
	;
	; 10/13/93 - Bob Chiang - I18N#7
	;
	;            Modified return message handling with a call to extrinsic
	;            function $$^MSG(msgid,p1,p2...) for I18N development
	;            (phrase independence).
	;-----------------------------------------------------------------------
DISET	;
	;
	;;N (%LIBS,%NAMCUR,X,SID,%MOD,%MODOFF,VRSEQ)
	;
	K XNS,LINE
	S XR9=1,Q=$C(34),QQ=Q_Q,$P(LINE,"_",60)=""
	;
	I X="" Q
	S XR0=X
	;
	I $D(^TMP($J,1000)) G NEXT0
	;
	S VRSEQ=0,XR8=1
	I $D(^DBTBL(%LIBS,2,SID,0,21)) G DISET1 ; REGULAR POST PROCESSOR
	;
	S ^TMP($J,1000,XR8)=" ;",XR8=XR8+1
	S ^(XR8)=" Q",^(XR8+1)=" ;",^(XR8+2)="VSPP ;",XR8=XR8+3
	;
DISET1	;
	;
	S ^TMP($J,1000,XR8)=" ;",^(XR8+1)="VSPPREQ ;",XR8=XR8+2
	S ^(XR8)=" ;"_$E(LINE,1,55),XR8=XR8+1
	S ^(XR8)=" ;  User Defined Required Data Item Definitions",XR8=XR8+1
	S ^(XR8)=" ;"_$E(LINE,1,55),^(XR8+1)=" ;",^(XR8+2)=" S ER=0"
	S XR7=XR8+5,XR8=XR8+100
	;
NEXT0	;
	;
	;
	;
	; Dispatch to set logic processing routine
	;
	S VRSEQ=VRSEQ+1
	;
	S ^TMP($J,1000,XR7)=" ;"
	;
	; Reserve next entry for later processing
	;
	S ZXR7=XR7+1
	S z=" F I=%MODS:1:%REPEAT+%MODS-1"
	S XR7VAR=z_" D VR"_VRSEQ_" I ER S NI=I-1*"_%MOD_"+1+%MODOFF Q"
	S XR7REG=" D VR"_VRSEQ_" I ER"
	;
	S ^(XR7+2)=" Q",XR7=XR7+2
	;
	S ^(XR8)=" ;",^(XR8+1)="VR"_VRSEQ_" ;",XR8=XR8+2
	;
NEXT	;
	;
	S XR1=$P(XR0,")",XR9) I XR1="" D DONE Q
	S XR1=$P(XR1,"(",2)
	;
	K CODE S CODE=" I "
	;
	F %I1=1:1 S DINAM=$P(XR1,",",%I1) Q:DINAM=""  D REQ I ER Q
	;
	; Remove , from end of command line
	;
	S ^TMP($J,1000,XR8)=" ;",XR8=XR8+1,^(XR8)=" ; ("_XR1_")",XR8=XR8+1
	S CODE=$E(CODE,1,$L(CODE)-1)
	I $O(CODE(""))="" S CODE=CODE_" Q"
	S ^(XR8)=" ;",XR8=XR8+1
	;
	S ^(XR8)=CODE,XR8=XR8+1
	;
	F I=1:1 Q:'$D(CODE(I))  S ^(XR8)=" I "_$E(CODE(I),1,$L(CODE(I))-1),XR8=XR8+1
	I $O(CODE(""))'="" S ^(XR8-1)=^(XR8-1)_" Q"
	;
DISET2	;
	S ^(XR8)=" ;",XR8=XR8+1
	;
	S XR9=XR9+1 G NEXT
	;
	;
REQ	;
	;
	; Default to ON condition ... either DI or DI+
	;
	S XON=1
	I DINAM["-",$P(DINAM,"-",2,99)="" S DINAM=$P(DINAM,"-",1),XON=0
	;
	I DINAM?1"@".E D VAR G REQ1
	;
	I DINAM'?1"["1E.E1"]"1E.E D DEFAULT I ER D ERR Q
	;
	S DLIB=%LIBS,DFID=$P(PFID,",",1),X=DINAM D ^DBSDI I ER D ERR
	S DINAM="["_LIB_","_FID_"]"_DI D ^DBSCHK I ER'="" D ERR Q
	;
	;
REQ1	;
	;
	; repeat region
	;
	; F I=%mods:1:%repeat+%mods-1 D VRn I ER S NI=... Q
	;
	S Z=$S(DINAM[",":"["_$P(DINAM,",",2,3),1:DINAM)
	;
	; ON SCREEN ??
	;
	I '$D(%NAMCUR(Z)) D ERR Q
	;
	I $G(%NAMCUR(Z))["+" S ^TMP($J,1000,ZXR7)=XR7VAR
	;
	I  S NS=$P(NS,"(1)",1)_"(I)"_$P(NS,"(1)",2,99) G REQ2
	;
	I $D(^TMP($J,1000,ZXR7)) G REQ2
	; D VRn I ER S NI=seq
	;
	S ^TMP($J,1000,ZXR7)=XR7REG
	;
	S XNS=1 I $D(%NAMCUR(Z)) S XNS=$P(%NAMCUR(Z),"|",2)
	S ^TMP($J,1000,ZXR7)=^TMP($J,1000,ZXR7)_" S NI="_XNS_" Q"
	;
REQ2	;
	;
	S X1="" I XON S X1="'"
	;
	I $L(CODE)>200 S z=$ZP(CODE(""))+1,CODE(z)=CODE,CODE=" I "
	S CODE=CODE_"("_NS_X1_"="_QQ_"),"
	;
	Q
	;
	; Add default file id
	;
DEFAULT	;
	S XXDINAM=DINAM
	S ZZFIL=1
DEFAULT1	;
	S DFID=$P(FILES,",",ZZFIL) I DFID="" S ER=1 G DEFAULT2
	S DLIB=%LIBS,X=XXDINAM D ^DBSDI
	I ER S ZZFIL=ZZFIL+1 G DEFAULT1
DEFAULT2	;
	S DFID=$P(FILES,",",1)
	Q
	;
ERR	;
	W !!,DINAM,?5," - Invalid Data Item Set Definition  ( "_XR1_" )",!!
	S ER=1 H 5
	Q
	;
DONE	;
	;
	S XR8=XR8+1,^TMP($J,1000,XR8)=" S ER=1 D VR99 Q"
	S XR8=XR8+1,^TMP($J,1000,XR8)=" ;",XR8=XR8+1
	; Missing required field(s)/data item set definition error
	S ^TMP($J,1000,XR8+1)="VR99 S RM="_Q_$$^MSG(1768)_Q	; *** - BC - 10/13/93
	S ^(XR8+2)=" S ER=1 Q"
	K XR1,XR9,LOOP,LINE,NS,DILNM,DINAM,SAVDI,XCOMP,XNS
	Q
	;
	;
VAR	;
	;
	N Z,x
	S NS=""
	I '$D(SID) Q
	I '$D(^DBTBL(%LIBS,2,SID,0)) Q
	S x=0 F I=1:1 S x=$O(^(x)) Q:x=""  I $P(^(x),"|",5)=DINAM Q
	I x<0 Q
	;
	S Z=$P(^(x),"|",11),NS=$E($P(Z,",",1),3,99) ; <<var,,,,,>>
	I NS[">>" S NS=$P(NS,">>",1)
	I $P(^(x),"|",22) S $P(Z,",",8)=$P(^(x),"|",22)
	I %NAMCUR(DINAM)["+" S NS=NS_"(1)" ; repeat region
	;
	; delimeter ?
	;
	I $P(Z,",",8) S NS="$P("_NS_","_$C(34,124,34)_","_($P(Z,",",8)+0)_")"
	Q
	;
	;
