TBXDQINT ;Public;TBX utility for SP and fix pack installl
	;;Copyright(c)2003 Sanchez Computer Associates, Inc.  All Rights Reserved - 09/20/05 14:45:49 - KWANL
	; ORIG: KWANL - 09/20/05
	; DESC: TBX utility for SP and fix pack installl
	;
	; KEYWORDS:
	;
	; INPUTS:
	; . (none)
	;
	; RETURNS:
	; . On return from this (sub)routine ^TMPDQS($J) will contain all
	;	possible phase 1 and phase 2 elements of the framework version
	;	that is being installed.
	;
	; RELATED:
	; . All elements from the StarTeam System_Areas PSL and SQL and all
	;	elements from the StarTeam System_Area DATA QWIK that are called
	;	in phase 0, phase 1, or phase 2 of an install or upgrade shall
	;	have a line in this routine that creates its ^TMPDQS($J) entry.
	;
	;-------- Comments -----------------------------------------------------
	; This program creates a temporary global for SP and FP install.
	; The global contains one entry for each element that is processed in
	; either phase 1 (PSL compiler and SQL engine upgrade) or phase 2
	; (framework completion) of an SP or FP install.
	; Please refer to the documents "Profile Environment Creation and
	; Upgrade Process Requirements and Design Document" and the "Framework
	; Upgrade Documentation" for additional information.
	;
	; This routine shall be kept in sync with the elements of the above
	; mentioned System_Areas.
	;
	;---- Revision History -------------------------------------------------
	; 02/28/2007 - RussellDS - CRs 25356 (04) / 25382 (72)
	;	* Removed reference to obsoleted DBSQRYA
	;
	; 01/23/2007 - Frans S.C. Witte - CRs 24902 / 24903 / 24974
	;	* Re-arranged phase1 and phase2 data and table elements
	;	  according to the following rules:
	;	  - if a phase1 element contains code that accesses the table,
	;		then the table element is listed as a phase1 element
	;		(because the compilation will fail if the DQ description
	;		of the table is not available).
	;	  - if a phase2 element contains code that accesses the table,
	;		then the table element is listed as a phase2 element.
	;	  - the data element that contains the data for the table
	;		element is listed in the same phase as that table
	;		element.
	;	  - for DBTBL* tables DBTBLn and DBTBLnx will always occur
	;		together (either all or none is listed).
	;	  - table (and data) elements that are not accessed by a phase1
	;		or phase2 element are not listed.
	;
	; 10/23/2006 - Frans S.C. Witte - CRs: 22719 / 20613
	;	* Added ^TMPDQS($JOB,"phase2","filer",) for SYSMAP*, DBTBL2, and
	;	  OBJECTMET.
	;	* Added SQLAG as phase2 procedure
	;
	; 07/07/2006 - Frans S.C. Witte - CRs: 22060 / 22061
	;	* Removed DBMAP, DBSDBASE, DBSDDMAP, DBSMACRO, DBSTBL, DBSDD,
	;	  DBSDI, and DBSDYNRA from phase 2, because they are now
	;	  correctly included in phase 1.
	;
	; 07/06/2006 - RussellDS - CR20967
	;	* Moved DBSDF, DBSDS, and DBSREL from phase2 routines to phase2
	;	  procedures.
	;
	;	* Removed obsolete phase2 routines DBSDF1, DBSMDD, DBSMDDCM,
	;	  DBSREL1, and DBSWRITE.
	;
	; 03/02/2006 - Frans S.C. Witte - CRs: 18981 / 18164
	;	* Corrected values stored for ^TMPDQS($j,"phase1").
	;
	; 02/14/2006 - Frans S.C. Witte - CRs: 18163 / 18164
	;	* Major clean up of "phase2" elements. All elements that are not
	;	  called (according to bootAll^ZFSWSTAT() dd 2006-02-08) have
	;	  been removed.
	;
	; 12/23/2005 - Frans S.C. Witte - CRs: 18727 / 18728
	;	* Rearranged entries per element type
	;	* "phase1" procedure and routine elements are now obtained by
	;	  calling $$getCompiler^UCGMCU()
	;	* added DBSFILB and DBSBCH to "phase2"
	;
	; 10/17/2005	KWANL
	;		This program setup a temp global for SP and FP install.
	;		phase1 and phase2 is the installation order when the
	;		elements will be compiled. Phase1 is PSL compiler upgrade
	;		and Phase2 is framework upgrade. Please refer to the
	;		Profile Environment Creation and Upgrade Process Design
	;		Document for more information.
	;-----------------------------------------------------------------------
init	; phase 1
	;
	; Routines and procedures are obtained from $$getCompiler^UCGMCU()
	; This ensures a single place to maintain the list of phase 1 code
	; elements.
	; Even though not all elements occur as both routine and procedure, the
	; extra entries do not hurt. TBXxPIN uses ^TPMDQS($JOB) only for
	; "positive" matches.
	;
	new ea,elm,list
	set list=$$getComList^UCGMCU()
	for ea=1:1:$LENGTH(list,",") do
	.	set elm=$PIECE(list,",",ea)
	.	set ^TMPDQS($JOB,"phase1","procedure",elm_".PROC")=""
	.	set ^TMPDQS($JOB,"phase1","routine",elm_".m")=""
	;
	; Tables (and Columns) -------------------------------------------------
	;
	; In addition to the Framework tables listed below, the following
	; application tables are accessed by phase1 procedures:
	; - CUVAR	by UCNUMBER
	; - DBCTLDVFM	by UCDTAUTL
	; - EFD		by SQLEFD
	; - STBLER	by DBSDI
	; - STBLXBAD	by DBSDI
	; - SVCTRLT	by UCLREGEN
	; - TMPDQ	by DBSDBASE
	; - UTBLNBD	by UCDATE
	; - XBAD	by DBSDI
	;
	set ^TMPDQS($JOB,"phase1","dbmap","DBMAP.TBL")=""
	set ^TMPDQS($JOB,"phase1","dbmapidx","DBMAPIDX.TBL")=""
	set ^TMPDQS($JOB,"phase1","dbmapt","DBMAPT")=""
	set ^TMPDQS($JOB,"phase1","dbspid","DBSPID")=""
	;
	set ^TMPDQS($JOB,"phase1","dbtbl1","DBTBL1.TBL")=""
	set ^TMPDQS($JOB,"phase1","dbtbl1d","DBTBL1D.TBL")=""
	set ^TMPDQS($JOB,"phase1","dbtbl1f","DBTBL1F.TBL")=""
	;
	set ^TMPDQS($JOB,"phase1","dbtbl2","DBTBL2.TBL")=""   ; UCLREGEN
	set ^TMPDQS($JOB,"phase1","dbtbl2d","DBTBL2D.TBL")=""
	set ^TMPDQS($JOB,"phase1","dbtbl2pp","DBTBL2PP.TBL")=""
	;
	set ^TMPDQS($JOB,"phase1","dbtbl4","DBTBL4.TBL")=""   ; UCQRYBLD
	set ^TMPDQS($JOB,"phase1","dbtbl4d","DBTBL4D.TBL")=""
	;
	set ^TMPDQS($JOB,"phase1","dbtbl7","DBTBL7.TBL")=""
	set ^TMPDQS($JOB,"phase1","dbtbl7d","DBTBL7D.TBL")=""
	;
	set ^TMPDQS($JOB,"phase1","dbtbl8","DBTBL8.TBL")=""
	;
	set ^TMPDQS($JOB,"phase1","dbtbl9","DBTBL9.TBL")=""
	set ^TMPDQS($JOB,"phase1","dbtbl9d","DBTBL9D.TBL")=""
	;
	set ^TMPDQS($JOB,"phase1","dbtbl12","DBTBL12.TBL")="" ; DBSTBL
	;
	set ^TMPDQS($JOB,"phase1","dbtbl25","DBTBL25.TBL")=""
	set ^TMPDQS($JOB,"phase1","dbtbl25d","DBTBL25D.TBL")=""
	;
	set ^TMPDQS($JOB,"phase1","dbtbl33","DBTBL33.TBL")=""
	set ^TMPDQS($JOB,"phase1","dbtbl33d","DBTBL33D.TBL")=""
	;
	set ^TMPDQS($JOB,"phase1","object","OBJECT.TBL")=""
	set ^TMPDQS($JOB,"phase1","objectmet","OBJECTMET.TBL")=""
	set ^TMPDQS($JOB,"phase1","objectprop","OBJECTPROP.TBL")=""
	;
	set ^TMPDQS($JOB,"phase1","sqlcache","SQLCACHE.TBL")=""
	set ^TMPDQS($JOB,"phase1","sqlcur","SQLCUR.TBL")=""
	set ^TMPDQS($JOB,"phase1","sqlfunc","SQLFUNC.TBL")=""
	;
	set ^TMPDQS($JOB,"phase1","stbljrnfunc","STBLJRNFUNC.TBL")=""
	set ^TMPDQS($JOB,"phase1","stblmtbls","STBLMTBLS.TBL")=""
	set ^TMPDQS($JOB,"phase1","stblpslfunsub","STBLPSLFUNSUB.TBL")=""
	set ^TMPDQS($JOB,"phase1","stblreserved","STBLRESERVED.TBL")=""
	set ^TMPDQS($JOB,"phase1","stblsyskeywd","STBLSYSKEYWD.TBL")=""
	;
	set ^TMPDQS($JOB,"phase1","sysmapcalls","SYSMAPCALLS.TBL")=""
	set ^TMPDQS($JOB,"phase1","sysmapcommands","SYSMAPCOMMANDS.TBL")=""
	set ^TMPDQS($JOB,"phase1","sysmaplabels","SYSMAPLABELS.TBL")=""
	set ^TMPDQS($JOB,"phase1","sysmaplitfnc","SYSMAPLITFNC.TBL")=""
	set ^TMPDQS($JOB,"phase1","sysmapm","SYSMAPM.TBL")=""
	set ^TMPDQS($JOB,"phase1","sysmapmprops","SYSMAPMPROPS.TBL")=""
	set ^TMPDQS($JOB,"phase1","sysmappropdata","SYSMAPPROPDATA.TBL")=""
	set ^TMPDQS($JOB,"phase1","sysmapvar","SYSMAPVAR.TBL")=""
	set ^TMPDQS($JOB,"phase1","sysmaprtns","SYSMAPRTNS.TBL")=""
	;
	set ^TMPDQS($JOB,"phase1","uclregen","UCLREGEN.TBL")=""
	;
	; Data -----------------------------------------------------------------
	;
	set ^TMPDQS($JOB,"phase1","data","OBJECT.G")=""
	set ^TMPDQS($JOB,"phase1","data","SQLFUNC.DAT")=""
	set ^TMPDQS($JOB,"phase2","data","STBLJRNFUNC.DAT")=""
	set ^TMPDQS($JOB,"phase1","data","STBL-MTBLS.G")=""
	set ^TMPDQS($JOB,"phase1","data","STBLPSLFUNSUB.DAT")=""
	set ^TMPDQS($JOB,"phase1","data","STBL-RESERVED.G")=""
	set ^TMPDQS($JOB,"phase1","data","STBLSYSKEYWD.DAT")=""
	;
	;=======================================================================
	; phase 2
	;
	; Routines
	;
	; The routine subtree has only documentary value. This is implied by the
	; processing order of the TBXxPIN routines:
	; - ^TMPDQS($JOB) is killed at the start of the process
	; - obsoletions are handled first
	; - the M routines are loaded next
	; - ^TBXDQINT is called after the M routines and the system files are
	;	loaded, but before the other elements are loaded.
	; So despite the fact that TBXRTN contains code to flag the loading of a
	; phase 1 or phase 2 element, there are no ^TMPDQS() entries at the time
	; LOAD^TBXRTN is called.
	; The above execution order is on purpose: Calling ^TBXDQINT after the
	; loading of routines ensures that the latest version of TBXDQINT will
	; be invoked. "Missing" one or more phase 1 or phase 2 routines is not a
	; major issue given that:
	; - The correct version of the routine is present anyway
	; - The chance that the particular change would be the only change for
	;	phase 1 or phase 2, AND would require a complete reboot, is
	;	small.
	; - The number of routines will be decreasing in favor of procedures
	;	while the remaining functionality is converted to PSL.
	;
	set ^TMPDQS($JOB,"phase2","routine","DBSBLD.m")=""
	set ^TMPDQS($JOB,"phase2","routine","DBSCHK.m")=""
	set ^TMPDQS($JOB,"phase2","routine","DBSCMP.m")=""
	set ^TMPDQS($JOB,"phase2","routine","DBSCMPF.m")=""
	set ^TMPDQS($JOB,"phase2","routine","DBSCRT8.m")=""
	set ^TMPDQS($JOB,"phase2","routine","DBSDB.m")=""
	set ^TMPDQS($JOB,"phase2","routine","DBSDSMC.m")=""
	set ^TMPDQS($JOB,"phase2","routine","DBSDSMP.m")=""
	set ^TMPDQS($JOB,"phase2","routine","DBSEDT.m")=""
	set ^TMPDQS($JOB,"phase2","routine","DBSEXECU.m")=""
	set ^TMPDQS($JOB,"phase2","routine","DBSEXEP.m")=""
	set ^TMPDQS($JOB,"phase2","routine","DBSINT.m")=""
	set ^TMPDQS($JOB,"phase2","routine","DBSLOD.m")=""
	set ^TMPDQS($JOB,"phase2","routine","DBSLOG.m")=""
	set ^TMPDQS($JOB,"phase2","routine","DBSMBAR.m")=""
	set ^TMPDQS($JOB,"phase2","routine","DBSPARS.m")=""
	set ^TMPDQS($JOB,"phase2","routine","DBSPARS1.m")=""
	set ^TMPDQS($JOB,"phase2","routine","DBSPARS2.m")=""
	set ^TMPDQS($JOB,"phase2","routine","DBSPP.m")=""
	set ^TMPDQS($JOB,"phase2","routine","DBSQRY.m")=""
	set ^TMPDQS($JOB,"phase2","routine","DBSRTN.m")=""
	set ^TMPDQS($JOB,"phase2","routine","DBSSCR.m")=""
	set ^TMPDQS($JOB,"phase2","routine","DBSSCR0.m")=""
	set ^TMPDQS($JOB,"phase2","routine","DBSSCR1.m")=""
	set ^TMPDQS($JOB,"phase2","routine","DBSSCR3.m")=""
	set ^TMPDQS($JOB,"phase2","routine","DBSSCR4.m")=""
	set ^TMPDQS($JOB,"phase2","routine","DBSSCR5.m")=""
	set ^TMPDQS($JOB,"phase2","routine","DBSUTL3.m")=""
	;
	; Procedures -----------------------------------------------------------
	;
	set ^TMPDQS($JOB,"phase2","procedure","DBS2PSL.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBS2PSL0.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBS2PSL1.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBS2PSL3.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBS2PSL4.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBS2PSL5.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBSBCH.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBSDF.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBSDF9.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBSDS.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBSEDIT.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBSFILB.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBSFILER.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBSGETID.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBSINDXB.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBSINDXZ.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBSJRNC.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBSLINK.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBSLOGIT.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBSMEMO.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBSPROC.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBSPROT3.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBSPROT4.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBSREL.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBSRW.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBSRW2.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBSRW3.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBSRWQRY.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBSRWUTL.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBSTBLA.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBSTRG.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","DBSVER.PROC")=""
	set ^TMPDQS($JOB,"phase2","procedure","SQLAG.PROC")=""
	;
	; Tables (and Columns) -------------------------------------------------
	;
	; In addition to the Framework tables listed below, the following
	; application tables are accessed by phase2 procedures:
	; - CUVAR	by DBS2PSL0, DBS2PSL4, DBSFILB, DBSFILER, DBSLINK, DBSRW
	; - DBCTLDVFM	by DBSVER
	; - DBCTLQRY	by DBSRWQRY
	; - SCASYS	by DBSDF
	; - SCATBL	by DBSGETID
	; - TMPDQ	by DBSDF9, DBSDS, DBSFILB, DBSGETID, DBSPROC, DBSRW
	; - UTBLKILL	by DBSINDXB
	; - UTBLPRODRL	by DBSTRG
	; - TBLPRODRT	by DBSTRG
	;
	set ^TMPDQS($JOB,"phase2","dbtbl0","DBTBL0.TBL")=""
	;
	set ^TMPDQS($JOB,"phase2","dbtbl13","DBTBL13.TBL")=""
	set ^TMPDQS($JOB,"phase2","dbtbl13d","DBTBL13D.TBL")=""
	;
	set ^TMPDQS($JOB,"phase2","dbtbl14","DBTBL14.TBL")=""
	set ^TMPDQS($JOB,"phase2","dbtbl14q","DBTBL14Q.TBL")=""
	;
	set ^TMPDQS($JOB,"phase2","dbtbl1tbldoc","DBTBL1TBLDOC.TBL")=""
	;
	set ^TMPDQS($JOB,"phase2","dbtbl22","DBTBL22.TBL")=""
	set ^TMPDQS($JOB,"phase2","dbtbl22c","DBTBL22C.TBL")=""
	set ^TMPDQS($JOB,"phase2","dbtbl22r","DBTBL22R.TBL")=""
	;
	set ^TMPDQS($JOB,"phase2","dbtbl5d","DBTBL5D.TBL")=""
	set ^TMPDQS($JOB,"phase2","dbtbl5d1","DBTBL5D1.TBL")=""
	set ^TMPDQS($JOB,"phase2","dbtbl5dgc","DBTBL5DGC.TBL")=""
	set ^TMPDQS($JOB,"phase2","dbtbl5h","DBTBL5H.TBL")=""
	set ^TMPDQS($JOB,"phase2","dbtbl5pr","DBTBL5PR.TBL")=""
	set ^TMPDQS($JOB,"phase2","dbtbl5q","DBTBL5Q.TBL")=""
	set ^TMPDQS($JOB,"phase2","dbtbl5sq","DBTBL5SQ.TBL")=""
	;
	set ^TMPDQS($JOB,"phase2","log","LOG.TBL")=""		; DBSLOGIT
	set ^TMPDQS($JOB,"phase2","log1","LOG1.TBL")=""
	;
	set ^TMPDQS($JOB,"phase2","mprof","MPROF.TBL")=""	; DBSBCH
	set ^TMPDQS($JOB,"phase2","mprof0","MPROF0.TBL")=""
	;
	; Filers ---------------------------------------------------------------
	;
	; Only the filers that are called during phase 3 of an upgrade need to
	; be compiled as part of phase 2. The relevant tables are stored in
	; ^TBPDQS($JOB,"phase2","filer",table). An extension (eg DBTBL2.TBL) is
	; allowed, and will be ignored by TBXDQUTL.
	;
	; Note that there are no StarTeam elements associated with the entries
	; in this subtree.
	;
	set ^TMPDQS($JOB,"phase2","filer","DBTBL2.TBL")=""
	set ^TMPDQS($JOB,"phase2","filer","OBJECTMET.TBL")=""
	set ^TMPDQS($JOB,"phase2","filer","SYSMAPCALLS.TBL")=""
	set ^TMPDQS($JOB,"phase2","filer","SYSMAPCOMMANDS.TBL")=""
	set ^TMPDQS($JOB,"phase2","filer","SYSMAPLABELS.TBL")=""
	set ^TMPDQS($JOB,"phase2","filer","SYSMAPLITDTA.TBL")=""
	set ^TMPDQS($JOB,"phase2","filer","SYSMAPM.TBL")=""
	set ^TMPDQS($JOB,"phase2","filer","SYSMAPMPROPS.TBL")=""
	set ^TMPDQS($JOB,"phase2","filer","SYSMAPPROPDATA.TBL")=""
	set ^TMPDQS($JOB,"phase2","filer","SYSMAPVAR.TBL")=""
	;
	; Data -----------------------------------------------------------------
	;
	set ^TMPDQS($JOB,"phase2","data","DBCTL.G")=""
	quit
