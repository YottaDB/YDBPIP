DBSPNTP	;; -  - V4.0 ; Format routine for PC mode
	;;Copyright(c)1994 Sanchez Computer Associates, Inc.  All Rights Reserved - 10/17/94 08:32:37 - XUS
	;     ORIG:  Robert Chiang
	;     DESC:  Print driver for PC
	;
        ; I18N=QUIT: Exculded from I18N standards.
	;
START	S VOZ=$C(17)
	D VTDISP
	K VO
	Q
	;
VTDISP	; PC format logic
	I '$D(%TAB) D VTAB^@VPGM
	;
	N D,GT,I,IST,IX,IY,V,VFIDDI,VSEQ,X
	S VSEQ=1
	;
	; Create data item/location index file
	K VFIDDI S X=0
	F  S X=$O(%TAB(X)) Q:X=""  S VFIDDI($A(%TAB(X))+1,$A(%TAB(X),2)+1)=$P(%TAB(X),"|",3)
	;
	; Convert VO array into OM array format   item name|size|data
	F I=1:1:+VO S X=VO(I) D DSPOBJ
	Q
	;
DSPOBJ	; Get next object
	;
	I $E(X,7) Q  ; Protected data item
	S VFIDDI=$G(VFIDDI($A(X),$A(X,2))) I VFIDDI="" Q
	I VFIDDI?1"[]".E S VFIDDI="["_DFID_"]"_$E(VFIDDI,3,99)
	;
	; OM(n) = [FID]DI | SIZE | DATA
	;
	S OM(VSEQ)=VFIDDI_"|"_$A(X,3)_"|"_$E(X,9,999)
	S VSEQ=VSEQ+1
	Q
