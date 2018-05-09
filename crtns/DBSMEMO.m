DBSMEMO	;
	;
	; **** Routine compiled from DATA-QWIK Procedure DBSMEMO ****
	;
	; 11/08/2007 14:07 - chenardp
	;
	;
	; **********************************************************************
	; * IMPORTANT NOTE:                                                    *
	; * According to the rules that apply to PSL compiler upgrades,        *
	; * the generated M routine associated with this procedure must be     *
	; * checked into StarTeam and released with the procedure whenever     *
	; * changes are made to this procedure.                                *
	; *                                                                    *
	; * The mrtns version will be used during upgrades and will then be    *
	; * removed from the mrtns directory.  Therefore, other than in a      *
	; * development environment, or during an upgrade, an mrtns version of *
	; * this routine should not exist.                                     *
	; *                                                                    *
	; * Keep these comments as single line to ensure they exist in the     *
	; * generated M code.                                                  *
	; **********************************************************************
	;
	Q 
	;
BUF(fid,memo,membuf,bsize)	;
	;
	N seq
	;
	I ($get(bsize)<1) S bsize=450
	;
	F seq=1:1 Q:(memo="")  D
	.	;
	.	S membuf(seq)=$E(memo,1,bsize)
	.	S memo=$E(memo,bsize+1,1048575)
	.	Q 
	;
	Q 
	;
READ(ref)	; Global reference
	;
	N seq
	N memo
	;
	S memo=""
	S seq=0
	;
	; Add seq as bottom level key
	S ref=$E(ref,1,$L(ref)-1)_",seq)"
	;
	;  #ACCEPT Date=10/24/05; Pgm=RussellDS; CR=17834
	F  S seq=$order(@ref) Q:(seq="")  S memo=memo_@ref
	;
	Q memo
	;
PARSE(fid)	; Table name
	;
	N I
	N acckeys N global N ref
	;
	N dbtbl1,vop1,vop2,vop3,vop4 S vop1="SYSDEV",vop2=fid,dbtbl1=$$vDb3("SYSDEV",fid)
	 S vop3=$G(^DBTBL(vop1,1,vop2,0))
	 S vop4=$G(^DBTBL(vop1,1,vop2,16))
	;
	S global="^"_$P(vop3,$C(124),1)
	S acckeys=$P(vop4,$C(124),1)
	;
	S ref=""
	F I=1:1:$L(acckeys,",") D
	.	;
	.	N key
	.	;
	.	S key=$piece(acckeys,",",I)
	.	;
	.	I $E(key,1)="""" S key=$S(key'["""":""""_key_"""",1:$$QADD^%ZS(key,""""))
	.	E  I '(key=+key) D
	..		;
	..		N dbtbl1d S dbtbl1d=$$vDb4("SYSDEV",fid,key)
	..		;
	..		S key="["_fid_"]"_key
	..		;
	..		I ("N$LDC"'[$P(dbtbl1d,$C(124),9)) S key="$c(34)_"_key_"_$c(34)"
	..		Q 
	.	;
	.	S ref=ref_key_"_"",""_"
	.	Q 
	;
	S ref=$E(ref,1,$L(ref)-3)_")"""
	;
	S ref="$$READ^DBSMEMO("""_global_"(""_"_ref_")"
	;
	Q ref
	;
EDIT(memoin,memoout)	;
	;
	N RETURN
	N i N j N seq
	N line N VFMQ N vmemo
	;
	S RETURN=0
	;
	; Break up memo by CR/LF, and make sure no lines longer than 80
	S seq=1
	F i=1:1:$L(memoin,$C(13,10)) D
	.	;
	.	S line=$piece(memoin,$C(13,10),i)
	.	;
	.	F j=1:1 D  Q:(line="") 
	..		;
	..		S vmemo(seq)=$E(line,1,80)
	..		S line=$E(line,81,1048575)
	..		S seq=seq+1
	..		Q 
	.	Q 
	;
	D ^DBSWRITE("vmemo") ; Access editor
	;
	I (VFMQ'="Q") D
	.	;
	.	; Add CR/LF after each line
	.	S (seq,memoout)=""
	.	F  S seq=$order(vmemo(seq)) Q:(seq="")  S memoout=memoout_vmemo(seq)_$C(13,10)
	.	;
	.	S RETURN=1
	.	Q 
	;
	Q RETURN
	;
vSIG()	;
	Q "60257^34840^Dan Russell^5028" ; Signature - LTD^TIME^USER^SIZE
	;
vDb3(v1,v2)	;	voXN = Db.getRecord(DBTBL1,,0)
	;
	N dbtbl1
	S dbtbl1=$G(^DBTBL(v1,1,v2))
	I dbtbl1="",'$D(^DBTBL(v1,1,v2))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1" X $ZT
	Q dbtbl1
	;
vDb4(v1,v2,v3)	;	voXN = Db.getRecord(DBTBL1D,,0)
	;
	N dbtbl1d
	S dbtbl1d=$G(^DBTBL(v1,1,v2,9,v3))
	I dbtbl1d="",'$D(^DBTBL(v1,1,v2,9,v3))
	I $T S $ZS="-1,"_$ZPOS_",%PSL-E-RECNOFL,,DBTBL1D" X $ZT
	Q dbtbl1d
