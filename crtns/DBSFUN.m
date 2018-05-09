 ; 
 ; **** Routine compiled from DATA-QWIK Procedure DBSFUN ****
 ; 
 ; 02/24/2010 18:21 - pip
 ; 
DBSFUN ; 
 ;
 Q  ; Don't call from top
 ;
SELDI(FILES,X) ; Input table syntax [*]  //NOREQ
 ;
  S ER=0
 ;
 N FID N HDG N LIB
 ;
 K zztblfid
 ;
 Q:($get(FILES)="") 
 ;
 S X=$piece($get(X),"/",1)
 ;
 I (X[".") D
 .	;
 .	S FID=$piece(X,".",1)
 .	S X=$piece(X,".",2)
 .	Q 
 E  I ($E(X,1)="[") D
 .	;
 .	S FID=$piece($piece(X,"]",1),"[",2)
 .	S X=$piece(X,"]",2)
 .	Q 
 E  S FID=$$SELFID(FILES,.X)
 ;
 I (FID="") S ER=1 Q 
 ;
 ; Define lookup table display format and collating method
 S vREF="[DBTBL1D]DI/LE=12/RH=Name,DES/LE=37/RH=Description,TYP/LE=1/RH=Type,LEN/LE=5/RH=len,NOD/LE=7/RH=Field,POS/LE=2/RH=Pos,USER/LE=4/RH=User:QU ""[DBTBL1D]FID="""_FID_""""""
 S HDG="Name          Description ["_FID_"]"
 S HDG=HDG_$J("",52-$L(HDG))_" Type Size Field   Pos  User"
 S vINFO("HDG")=HDG
 ;
 ;  zztblfid can be used by post-proc to change table entry X TO [zztblfid]X
 S zztblfid=FID
 ;
 Q 
 ;
SELFID(FILES,DI) ; Column name
 ;
 N CNT N I N OP
 N FID N FIDS N VAR
 ;
 I '(FILES[",") Q FILES ; Single file
 ;
 F I=1:1:$L(FILES,",") D
 .	;
 .	S FID=$piece(FILES,",",I)
 .	;
 .	I (DI="") S FIDS(FID)=""
 .	;
 .	E  I ($D(^DBTBL("SYSDEV",1,FID,9,DI))#2) S FIDS(FID)=""
 .	Q 
 ;
 S CNT=0
 S FID=""
 F  S FID=$order(FIDS(FID)) Q:(FID="")  D
 .	;
 .	S CNT=CNT+1
 .	S VAR(CNT)=FID
 .	Q 
 ;
 I (CNT=1) Q VAR(CNT) ; Single match
 ;
 S OP=$$^DBSMBAR(20,"","","",.VAR)
 ;
 I (+OP=0) Q ""
 ;
 Q VAR(OP)
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61114^71587^Dan Russell^2985" ; Signature - LTD^TIME^USER^SIZE
