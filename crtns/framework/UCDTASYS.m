 ; 
 ; **** Routine compiled from DATA-QWIK Procedure UCDTASYS ****
 ; 
 ; 02/24/2010 18:23 - pip
 ; 
 ;  #PACKAGE framework.psl
 ;  #OPTION  ResultClass ON
 Q 
 ;
 ; ---------------------------------------------------------------------
loadFunc(parMap,funcs) ; function cache /MECH=REFARR:RW
 ; NOTE: The 9.char() below is only safe because UCDTASYS is in the DATA group
 ;
 N return S return=""
 N BEG S BEG=$piece(parMap,"(",1)_"(" N END S END=BEG_999
 N list1 S list1=$piece($piece(parMap,"(",2),")",1)
 ;
 N rs,vos1,vos2,vos3,vos4,vos5,vos6 S rs=$$vOpen1()
 ;
 F  Q:'$$vFetch1()  D  I '(return="") Q 
 .	;
 .	; Convert all the condition parameters to 1, use alpha after 9 up to limit of 36
 .	;
 . N list2 S list2=$translate($piece($piece($P(rs,$C(9),1),"(",2),")",1),"023456789ABCDEFGHIJKLMNOPQRSTUVWXYZ","111111111111111111111111111111111111")
 . I ($E(list2,1,$L(list1))=list1) S return=rs S funcs(parMap)=return
 .	Q 
 ;
 N method S method=$piece($piece(return,$C(9),2),"(",1)
 N class S class=$piece(return,$C(9),3)
 I (class="") S class="String"
 ;
 I (return="") S funcs(parMap)=$C(9) ; No matches
 ;
 Q return
 ;
 ; ---------------------------------------------------------------------
xiniPSLFUNSUB() ; 1st initialization of table in MDB
 ;
 Q 
 ;  #OPTION ResultClass ON
vSIG() ; 
 Q "61565^25471^Sha H Mirza^6399" ; Signature - LTD^TIME^USER^SIZE
 ;
vOpen1() ; TEMPLATE,METHOD,CLASS,LITRESET FROM STBLPSLFUNSUB WHERE TEMPLATE BETWEEN :BEG AND :END ORDER BY TEMPLATE
 ;
 ;
 S vos1=2
 D vL1a1
 Q ""
 ;
vL1a0 S vos1=0 Q
vL1a1 S vos2=$$BYTECHAR^SQLUTL(254)
 S vos3=$G(BEG) I vos3="",'$D(BEG) G vL1a0
 S vos4=$G(END) I vos4="",'$D(END) G vL1a0
 S vos5=vos3
 I $D(^STBL("PSLFUNSUB",vos5)),'(vos5]]vos4) G vL1a7
vL1a6 S vos5=$O(^STBL("PSLFUNSUB",vos5),1) I vos5=""!(vos5]]vos4) G vL1a0
vL1a7 Q
 ;
vFetch1() ;
 ;
 ;
 I vos1=1 D vL1a6
 I vos1=2 S vos1=1
 ;
 I vos1=0 S rs="" Q 0
 ;
 S vos6=$G(^STBL("PSLFUNSUB",vos5))
 S rs=$S(vos5=vos2:"",1:vos5)_$C(9)_$P(vos6,"|",1)_$C(9)_$P(vos6,"|",2)_$C(9)_$P(vos6,"|",3)
 ;
 Q 1
