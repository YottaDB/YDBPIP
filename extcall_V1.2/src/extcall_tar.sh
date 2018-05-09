rm extcall_linux.*

tar -cf extcall_linux.tar Makefile alerts.sl alerts.xc asc2ebc.c asc2ebc.o atmutils.c atmutils.o devutils.c devutils.o ebc2asc.c ebc2asc.o elfhash.c elfhash.o expsca.c expsca.o extcall.h extcall.sl extcall.xc getquijob.c lnx.c lnx.o logsca.c logsca.o md5.h md5c.c md5c.o password.c pidutils.c pidutils.o readport.c readport.o remote.c remote.o rtb.c rtb.o rtbar.c rtbar.o rules.mk scamd5.c scamd5.h scamd5.o sigutils.c slibrule.mk string.c string.o sysutils.c sysutils.o unpack.c unpack.o unpack2.c unpack2.o utils.c utils.o xor.c xor.o extcallversion version.c version.mk build.sh extcall_rm.sh extcall_tar.sh

gzip -9 *.tar
