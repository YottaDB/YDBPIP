 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSDEUTL ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSDEUTL(OPT,SID,FPRE) ; Public;Genearl purpose driver to create,modify and delete tables.
 ;
 ; Compile procedure DBSDEUTB (DBSDEUTA Builder)
 ;
 ; Generate DBSDEUTA
 ;
 N ARR N FID N files N fsn N IO N KVAR N PGM N POST N vdd N vfsn N vpgm N X
 N %O
 ;
 S %O=OPT
 S FPRE=$get(FPRE)
 ;
 I $get(SID)="" D GETSID I VFMQ="Q" Q 
 ;
 N dbtbl2,vop1,vop2,vop3,vop4 S vop1="SYSDEV",vop2=SID,dbtbl2=$$vRCgetRecord1Opt^RecordDBTBL2("SYSDEV",SID,0,.vop3)
  S vop4=$G(^DBTBL(vop1,2,vop2,0))
 I '$G(vop3) S ER=1 S RM=$$^MSG(1458,SID) Q 
 ;
 S files=$P(vop4,$C(124),1)
 S FID=$piece(files,",",1) ; primary table
 ;
 N dbtbl1 S dbtbl1=$$vRCgetRecord1^RecordDBTBL1("SYSDEV",FID,0)
 I '$G(vobj(dbtbl1,-2)) S ER=1 S RM="Invalid Table" K vobj(+$G(dbtbl1)) Q 
 ;
 D PROMPT(.dbtbl1,%O,.KEYS) ; prompt for access keys
 I VFMQ="Q" K vobj(+$G(dbtbl1)) Q 
 ;
 S %O=OPT
 I %O=2 D  I VFMQ="Q" K vobj(+$G(dbtbl1)) Q 
 .	N %READ N %TAB
 .	;
 .	S %TAB("IO")=$$IO^SCATAB($I)
 .	S %READ="@@%FN,,IO/REQ"
 .	D ^UTLREAD
 .	Q 
 ;
 I %O=2,IO'=$I D OPEN^SCAIO ; Open output device
 ; Call utility to process this screen and file data
 S RM=$$^DBSDEUTA(SID,%O,.KEYS,FPRE)
 I '(RM="") S ER=1
 ;
 I $get(ER)!(VFMQ="Q") D DINAM(FID,.dbtbl1) K vobj(+$G(dbtbl1)) Q 
 I ER="W" K vobj(+$G(dbtbl1)) Q 
 D DINAM(FID,.dbtbl1)
 ;
 ;  #ACCEPT Date=01/20/05;PGM=Pete Chenard;CR=14146
 I $get(KVAR)'="" XECUTE KVAR
 K vobj(+$G(dbtbl1)) Q 
 ;
DINAM(FID,dbtbl1) ; Finish up and display messages
  S:'$D(vobj(dbtbl1,16)) vobj(dbtbl1,16)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),16)),1:"")
 ;
 N DESC N I N J N KEY N keys N P1 N Y
 ;
 I ER,'(RM="") S ER="W" Q 
 ;
 S keys=$P(vobj(dbtbl1,16),$C(124),1)
 S P1=""
 ;
 I keys="" S P1=" "_FID ;Table w/ no access keys (e.g., CUVAR)
 E  F J=1:1:$L(keys,",") D
 .	S I=$piece(keys,",",J)
 .	I I="%LIBS" Q 
 .	I $$isLit^UCGM(I) Q  ; ignore literal keys
 .	S DESC=$$DES^DBSDD(FID_"."_I) ; To get the description of the data item
 .	S KEY=@I
 .	S P1=P1_" "_DESC_" "_KEY
 .	Q 
 Q:ER!(%O=2)!(%O=4) 
 ;
 S P1=$E(P1,2,1048575)
 I VFMQ="Q" D
 .	;
 .	;~p1 not created
 .	I %O=0 S RM=$$^MSG(6709,P1) Q 
 .	;~p1 not modified
 .	I %O=1 S RM=$$^MSG(6710,P1) Q 
 .	;~p1 not deleted
 .	I %O=3 S RM=$$^MSG(6711,P1)
 .	Q 
 E  D
 .	;~p1 created
 .	I %O=0 S RM=$$^MSG(6712,P1) Q 
 .	;~p1 modified
 .	I %O=1 S RM=$$^MSG(6713,P1) Q 
 .	;~p1 deleted
 .	I %O=3 S RM=$$^MSG(3028,P1)
 .	Q 
 ;
 S ER="W"
 Q 
 ;
GETSID ; Prompt for screen name
 ;
 N %FRAME N %NOPRMT N %READ N %TAB N PGM
 ;
 S %TAB("SID")=".SID1/REQ/TBL=[DBTBL2]"
 S %READ="@@%FN,,SID/REQ,"
 S %NOPRMT="F" S %FRAME=2
 D ^UTLREAD
 Q 
 ;
PROMPT(dbtbl1,%O,KEYS) ; Access Key Array /NOREQ/MECH=REF:W
  S:'$D(vobj(dbtbl1,16)) vobj(dbtbl1,16)=$S(vobj(dbtbl1,-2):$G(^DBTBL(vobj(dbtbl1,-3),1,vobj(dbtbl1,-4),16)),1:"")
 ;
  S ER=0
 ;
 N I N keycnt N OLNTB N vmode
 N %NOPRMT N %READ N %TAB N acckeys N fid N KEY N keys N MSG N msghdr N screen
 ;
 S fid=vobj(dbtbl1,-4)
 ;
 ; Get access keys
 S keys=""
 S keycnt=$$GETKEYS($P(vobj(dbtbl1,16),$C(124),1),.keys)
 ;
 ; Build UTLREAD info - prompt for primary keys
 S msghdr=$$BANNER^DBSGETID(%FN)
 ;
 S %READ="@msghdr/REV/CEN,,"
 ;
 F I=1:1:keycnt D
 .	;
 .	N size
 .	N key N X
 .	;
 .	S key=keys(I)
 .	;
 .	I key="%LIBS" S KEYS(I)="SYSDEV" Q  ; Don't prompt for Library
 .	;
 .	N dbtbl1d S dbtbl1d=$$vRCgetRecord0Opt^RecordDBTBL1D("SYSDEV",fid,key,0,"")
 .	;
 .	S size=$P(dbtbl1d,$C(124),19)
 .	I (size="") S size=$P(dbtbl1d,$C(124),2)
 .	;
 .	S X="/DES="_$$QADD^%ZS($P(dbtbl1d,$C(124),10),"""")_"/TYP="_$P(dbtbl1d,$C(124),9)_"/LEN="_$P(dbtbl1d,$C(124),2)
 .	S X=X_"/SIZ="_size
 .	;
 .	I '($P(dbtbl1d,$C(124),5)="") S X=X_"/TBL="_$P(dbtbl1d,$C(124),5)
 .	E  D
 ..		S X=X_"/TBL=["_fid_"]"
 ..		I (I'=keycnt) S X=X_key_":DISTINCT"
 ..		I (I>1) D
 ...			;
 ...			; Add queries for higher levels
 ...			N J
 ...			;
 ...			S X=X_":QU """
 ...			F J=1:1:I-1 S X=X_"["_fid_"]"_keys(J)_"=<<"_keys(J)_">> & "
 ...			S X=$E(X,1,$L(X)-3)_""""
 ...			Q 
 ..		Q 
 .	I %O=0 S X=X_":NOVAL"
 .	;
 .	I '($P(dbtbl1d,$C(124),12)="") S X=X_"/MIN="_$P(dbtbl1d,$C(124),12)
 .	I '($P(dbtbl1d,$C(124),13)="") S X=X_"/MAX="_$P(dbtbl1d,$C(124),13)
 .	I '($P(dbtbl1d,$C(124),14)="") S X=X_"/DEC="_$P(dbtbl1d,$C(124),14)
 .	I '($P(dbtbl1d,$C(124),6)="") S X=X_"/PAT="_$P(dbtbl1d,$C(124),6)
 .	S X=X_"/XPP=S KEYS("_I_")=X" ; set key name up
 .	;
 .	; Add check to make sure record doesn't already exist if create mode
 .	I (%O=0),(I=keycnt) S X=X_" D PP^DBSDEUTL(fid,.keys,.KEYS)"
 .	;
 .	S X=X_"/REQ"
 .	;
 .	S %TAB(key)=X
 .	;set %TAB("KEYS("_I_")") = X
 .	S KEYS(I)=""
 .	;set %READ = %READ_"KEYS("_I_"),"
 .	S %READ=%READ_key_","
 . Q 
 ;
 S %NOPRMT="F"
 S vmode=0
 S OLNTB=30
 ;
 D ^UTLREAD
 Q 
 ;
PP(fid,keys,KEYS) ; Key values
 ;
 N N
 N select N value N where
 ;
 S (N,select,where)=""
 F  S N=$order(keys(N)) Q:(N="")  D
 .	;
 .	S value=$S(KEYS(N)'["'":"'"_KEYS(N)_"'",1:$$QADD^%ZS(KEYS(N),"'"))
 .	;
 .	S select=select_keys(N)_","
 .	S where=where_keys(N)_"="_value_" AND "
 .	Q 
 ;
 S select=$E(select,1,$L(select)-1)
 S where=$E(where,1,$L(where)-5)
 ;
 ;  #ACCEPT Date=01/16/06; PGM=RussellDS; CR=19021
 N rs,vos1,vos2,sqlcur,exe,sqlcur,vd,vi,vsql,vsub S rs=$$vOpen0(.exe,.vsql,select,fid,where,"","","",1)
 ;
 I ''$G(vos1) D
 .	;
 .	S ER=1
 .	; Record already exists
 .	S RM=$$^MSG(2327)
 .	Q 
 ;
 Q 
 ;
GETKEYS(acckeys,keys,select,where) ; 
 ;
 N I N keycnt
 N key
 ;
 S keycnt=0
 S (select,where)=""
 ;
 F I=1:1:$L(acckeys,",") D
 .	;
 .	S key=$piece(acckeys,",",I)
 .	Q:$$isLit^UCGM(key)  ; Ignore literal keys
 .	;
 .	S keycnt=keycnt+1
 .	S keys(keycnt)=key
 .	;
 .	S select=select_key_","
 .	S where=where_key_"= :KEY("_keycnt_") AND "
 .	Q 
 ;
 S select=$E(select,1,$L(select)-1)
 S where=$E(where,1,$L(where)-5)
 ;
 Q keycnt
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61166^77119^Dan Russell^7797" ; Signature - LTD^TIME^USER^SIZE
 ;
vOpen0(exe,vsql,vSelect,vFrom,vWhere,vOrderby,vGroupby,vParlist,vOff) ; Dynamic MDB ResultSet
 ;
 set sqlcur="PP.rs"
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
 S vos1=vsql
 Q ""
 ;
vFetch0() ; MDB dynamic FETCH
 ;
 ; type public String exe(),sqlcur,vd,vi,vsql()
 ;
 I vsql=0 S rs="" Q 0
 S vsql=$$^SQLF(.exe,.vd,.vi,.sqlcur)
 S rs=vd
 S vos1=vsql
 S vos2=$G(vi)
 Q vsql
