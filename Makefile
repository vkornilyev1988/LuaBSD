# Created by: GreenDog <fiziologus@gmail.com>
# $FreeBSD: head/lang/lua53/Makefile 500722 2019-05-03 11:50:24Z swills $

PORTNAME=		FIRMWARE
SYSARCH!=		uname -p
MASTER_SITE_SUBDIR=		snapshots
EXTRACT_SUFX=	.txz
PORTVERSION=	11.3
PORTREVISION=	STABLE
CATEGORIES=		sysutils
DISTFILES=		src.txz
PKGNAMEPREFIX=	fw-
PKGNAMESUFFIX=	.img
MASTER_SITES=	https://mirror.yandex.ru/freebsd/${MASTER_SITE_SUBDIR}/${SYSARCH}/${PORTVERSION}-${PORTREVISION}/
PKGNAMESUFFIX=	13
WRKSRC=			${WRKDIR}/src
CC=				clang
CPP=			clang-cpp
CXX=			clang++
NCPU!=			echo "$$(($$(sysctl -nq hw.ncpu) -1 ))"
MDCONFIG!=		whereis -qb mdconfig
TRUNCATE!=		whereis -qb truncate
NEWFS!=			whereis -qb newfs
MAKEFS!=		whereis -qb makefs
KLDXREF!=		whereis -qb kldxref
NAMEKERN=		GENERIC
DD!=			whereis -qb dd
MFSSIZE=		64m
GPART!=			whereis -qb gpart

ZFS_ZPOOL=		zdata
ZFS_CFG=		cfg

MAINTAINER=	russ.haley@gmail.com
COMMENT=	Powerful, efficient, lightweight, embeddable scripting language

NO_CHECKSUM=	YES

FETCH_ENV=	SSL_NO_VERIFY_PEER=1 SSL_NO_VERIFY_HOSTNAME=1

MASTER_MAIN_SITE=	git.syfy-host.com

# Overriding __MAKE_CONF makes sure that we don't re-parse
# /etc/make.conf during do-build, which would jeopardize the build
# if, for instance, the user set CFLAGS=mumble
# NOTE: /etc/make.conf is read BEFORE Makefile, so we already
# have its settings when we get here.
# See http://wiki.freebsd.org/MatthiasAndree/LuaLessonsLearnt


BUILD_WRKSRC=	${WRKSRC}/src

# Source, destination, and filenames to copy for the DOCS option
# (automatically added to pkg-plist if DOCS is set)
# We override DOCSDIR to get a per-version subdir.
# We put the docs for Lua proper in a lua/ subdir of the version subdir
# so that ports for Lua modules can use the version subdir too without
# making a mess.


ALL_TARGET=bsd

# Options


OPTIONS_GROUP=			BSD FIRM FLAGS KCSMOD IM OPT PLUGINS MFSSIZE APPS
OPTIONS_SINGLE=			BSD FLAGS MFSSIZE TYPE


OPTIONS_GROUP_FIRM=		BOOT KERNEL NANOKERN LUAROOT PHP MPLAYERTV BSDSH WEBSHELL
OPTIONS_GROUP_IM=		ISO IMG TAR
OPTIONS_GROUP_OPT=		NANOKERN ROOTINMFS KLDINMFS UEFI BSD802QTRUNK ZFSCFG ZNETGRAPH \
						ZFWRULES
OPTIONS_GROUP_APPS=		XUPNPD WEBSERVERPHP ZBIT2


OPTIONS_SINGLE_BSD=		BSDINIT ROOTHACK 
OPTIONS_SINGLE_TYPE=	FREEBSD OPENBSD HARDENEDBSD 

OPTIONS_SINGLE_FLAGS=	STATIC DYNAMIC
OPTIONS_SINGLE_MFSSIZE=	16m 32m 64m 128m 256m 512m 900m
DYNAMIC_DESC=			Build dynamic executables and/or libraries

OPTIONS_GROUP_PLUGINS=	PLTERM LUABSD RCLOCAL SHELL SHELLLIB LUALOGIN ZFWNETGRAPH LANO DHCLIENT


OPTIONS_DEFAULT= BSDINIT STATIC 64M FREEBSD BSD802QTRUNK


# Option descriptions
LANO_DESC=		LUA NANO TEXT EDITOR
BSD802QTRUNK_DESC=	Add function 802.11 trunc port in NetGraph
KLDINMFS_DESC=	Import modules kernel/*.ko in mfs modules
OPTIONS_GROUP_OPT_DESC=	Options build components
ROOTINMFS_DESC=	Import root.txz in mfsroot.gz file
IM_DESC=		Images type compilation
KCSMOD_DESC=	FOR PRO MODS
DEBUGGRP_DESC=	Debugging options
PLGGRP_DESC=	Plugins lua functions
ASSERT_DESC=	Enable interpreter assertions
APICHECK_DESC=	Enable API checks

DOCSGRP_DESC=	Documentation options
DOCS_DESC=	Install language and API reference (HTML, ~400kB)

EDITGRP_DESC=	Interactive command-line editing
EDITNONE_DESC=	No command-line editing
LIBEDIT_DL_DESC=Use dynamically loaded libedit (recommended)
LIBEDIT_DESC=	Use libedit (breaks lcurses)
READLINE_DESC=	Use GNU Readline (breaks lcurses)

# LIBRARIES MENU
CURL_DESC=		Command line tool and library for transferring data with URLs
PAM_DESC=		Lua module for PAM authentication
ZFS_DESC=		Library zfs and zpool funcrons support
JSON_DESC=		Json parser support
NETGRAPH=		NetGraph Lua implementation support
IFNET_DESC=		ifconfig/gw
SYSTEMOS_DESC=		System funtions support
BCRYPT_DESC=		Library providing OpenBSD's bcrypt hash function for Lua
ADA_DESC=		Ada binding for Lua
CJSON_DESC=		Fast JSON parsing and encoding support for Lua
BITOP_DESC=		Bitwise operations on numbers
BITLIB_DESC=		Tiny library for bitwise operations
GI_DESC=		Lua bindings to libraries using GObject-Introspection
CHECH_DESC=		Linter and static analyzer for lua files
ABDI_DESC=		LuaDBI driver
EXPAT_DESC=		LuaExpat is a SAX XML parser based on the Expat library
ROCKS_DESC=		Package manager for Lua modules
SEC_DESC=		Lua binding for the OpenSSL library to provide TLS/SSL communication
SOCKET_DESC=		IPv4 and IPv6 socket support for the Lua language
LFS_DESC=		Library to access directory structure and file attributes
LDAP_DESC=		LDAP support for the Lua language
ZLIB_DESC=		Lua bindings to the ZLib compression library
LZLIB_DESC=		Lua bindings to the GZIP compression library
YML_DESC=		LibYAML binding for Lua
SYSCTL_DESC=		Small sysctl(3) interface for lua
KENV_DESC=		Small kenv(3) interface for lua
XAPIAN_DESC=		Lua binding for Xapian
POSIX_DESC=		Lua bindings for POSIX APIs
CHECK_DESC=		Linter and static analyzer for lua files
UNIT_DESC=		Unit Testing Framework for Lua
PEG_DESC=		PEG-based pattern-matching library for Lua
NETGRAPH_DESC=		Lua netgraph network support



.include <bsd.port.options.mk>

.if ${PORT_OPTIONS:MHARDENEDBSD}
MASTER_SITES=	 https://ci-01.nyi.hardenedbsd.org/pub/hardenedbsd/11-stable/${SYSARCH}/${SYSARCH}/build-3/
.elif ${PORT_OPTIONS:MOPENBSD}
.else
MASTER_SITES=	 https://mirror.yandex.ru/freebsd/${MASTER_SITE_SUBDIR}/${SYSARCH}/${PORTVERSION}-${PORTREVISION}/
.endif

.if   ${PORT_OPTIONS:MDYNAMIC}
READLINE_LIBS=		-lreadline -L${PREFIX}/lib
LIBEDIT_LIBS=		-ledit
LIBSTATIC=			-L${PREFIX}/lib
OPT_CFLAGS=
.elif ${PORT_OPTIONS:MSTATIC}
READLINE_LIBS=		${LOCALBASE}/lib/libreadline.a /usr/lib/libncursesw.a
LIBEDIT_LIBS=		${LOCALBASE}/lib/libedit.a
STATIC=				-static
LIBSTATIC=			-c
.endif

.if ${PORT_OPTIONS:MLIBEDIT}
OPT_LINE_FLAGS=	${LIBEDIT_LIBS}
.elif ${PORT_OPTIONS:MREADLINE}
OPT_LINE_FLAGS=	${READLINE_LIBS}
.else
MY_LINE_FLAGS=
.endif

OPT_MK_ARGS=		${OPT_LINE_FLAGS} ${STATIC}
# end of option vars

.for MSIZE in ${OPTIONS_SINGLE_MFSSIZE}
. if ${PORT_OPTIONS:M${MSIZE}}
MFSSIZE=	${MSIZE}
. endif
.endfor

.if ${PORT_OPTIONS:MROOTHACK}
ROOTHACK_TRUE=				ROOTHACK
ROOTHACK_PATH=				usr/src/sbin/init
ROOTHACK_DIR=				sbin
ROOTHACK_INTERNAL=			YES
ROOTHACK_CFLAGS=			-O3 -pipe
ROOTHACK_EXTRA_PATCHES=		${PATCHDIR}/extrac-patch-roothack-sbin-init
ROOTHACK_CMD=				${MAKE} -C ${WRKSRC}/usr/src/sbin/init all install && mv ${WRKSRC}/usr/src/sbin/init/init ${WRKSRC}/usr/src/sbin/init/bsdinit && ${INSTALL} ${WRKSRC}/usr/src/sbin/init/bsdinit ${STAGEDIR}/sbin && ${MAKE} -C ${WRKSRC}/usr/src/sbin/init clean cleandepend && (cd ${WRKSRC}/usr/src && if [ ! -f "${WRKSRC}/${ROOTHACK_PATH}/init.c.orig" ]; then patch < ${ROOTHACK_EXTRA_PATCHES}; fi)

.else
.endif




.if ${PORT_OPTIONS:MZFSCFG}

 LUABSD_LOADER_CONF_ADD+= 		hvm.cfg.type="zfs"\nhvm.cfg.zfs.path="${ZFS_ZPOOL}/${ZFS_CFG}"\nhvm.cfg.fstype="zfs"\nhvm.cfg.fsdev="zdata/cfg"\nhvm.cfg.fspoint="/cfg"\nhvm.cfg.netgraph="netgraph"\nkcs.bdb.path="/data/db"\n


.endif

.if ${PORT_OPTIONS:MLUAROOT}
LUAROOT_TRUE=			LUAROOT	
LUAROOT_PATH=			lang/lua53-static
LUAROOT_ROOT=			rw
LUAROOT_ARGS_MAKE=		PREFIX=/
LUAROOT_TAR=			
LUAROOT_DIRS=			bin sbin usr etc lib usr dev proc dev proc tmp/log tmp/run root
LUAROOT_PORTS=			YES
LUAROOT_CMD=			[ -f "${STAGEDIR}/sbin/bsdinit" ] && ${INSTALL} ${STAGEDIR}/sbin/bsdinit ${STAGEDIR}/${LUAROOT_ROOT}/sbin/bsdinit || ${MAKE} -C ${WRKSRC}/usr/src/sbin/init all install DESTDIR=${STAGEDIR}/${UAROOT_ROOT} &&  ([ -f "${WRKSRC}/usr/src/etc/master.passwd" ] && pwd_mkdb -d ${STAGEDIR}/${LUAROOT_ROOT}/etc/ -p ${WRKSRC}/usr/src/etc/master.passwd || true ) && \
						${CP} ${WRKSRC}/usr/src/etc/group ${STAGEDIR}/${LUAROOT_ROOT}/etc/ && echo 'nameserver 8.8.8.8' > ${STAGEDIR}/${LUAROOT_ROOT}/etc/resolv.conf && ${INSTALL} ${PATCHDIR}/libinit.in ${STAGEDIR}/${LUAROOT_ROOT}/lib/init && ${TOUCH} ${STAGEDIR}/${LUAROOT_ROOT}/etc/rc.local && ${CHMOD} +x ${STAGEDIR}/${LUAROOT_ROOT}/etc/rc.local && echo '127.0.0.1 hostname' > ${STAGEDIR}/${LUAROOT_ROOT}/etc/hosts && \
						[ -f "${PATCHDIR}/rc.json.in" ] && ${CP} ${PATCHDIR}/rc.json.in ${STAGEDIR}/rw/etc/rc.json || true; [ -f "${PATCHDIR}/function.doc.in" ] && ${CP} ${PATCHDIR}/function.doc.in ${STAGEDIR}/rw/lib/function.doc || true
					
LUAROOT_PORTS_LIST=		bin/lua53 bin/luac53
LUAROOT_SMLINKS=		/bin/lua53|bin/lua
LUAROOT_PORT_STAGE!=	${MAKE} -v STAGEDIR -C ${PORTSDIR}/${LUAROOT_PATH}
.else
.endif

.if ${PORT_OPTIONS:MPHP}
PHP_TRUE=			PHP	
PHP_PATH=			lang/php73-static
PHP_ROOT=			rw
PHP_ARGS_MAKE=		PREFIX=/
PHP_TAR=			
PHP_DIRS=			bin sbin usr etc lib usr dev 
PHP_PORTS=			YES
PHP_CMD=			
PHP_PORTS_LIST=		bin/php
PHP_SMLINKS=		
PHP_PORT_STAGE!=	${MAKE} -v STAGEDIR -C ${PORTSDIR}/${PHP_PATH}
.else
.endif



.if ${PORT_OPTIONS:MZFWNETGRAPH}
ZFWNETGRAPH_TRUE=			ZFWNETGRAPH	
ZFWNETGRAPH_PATH=			netgraph.lua
ZFWNETGRAPH_ROOT=			rw
ZFWNETGRAPH_ARGS_MAKE=		PREFIX=/
ZFWNETGRAPH_TAR=			
ZFWNETGRAPH_DIRS=			lib
ZFWNETGRAPH_LIBS=			YES
ZFWNETGRAPH_CMD=			
ZFWNETGRAPH_LIBS_LIST=		lib/netgraph.lib
ZFWNETGRAPH_SMLINKS=		

.else
.endif

.if ${PORT_OPTIONS:MDHCLIENT}
DHCLIENT_TRUE=			DHCLIENT	
DHCLIENT_PATH=			dhclient.lib.lua
DHCLIENT_ROOT=			rw
DHCLIENT_ARGS_MAKE=		PREFIX=/
DHCLIENT_TAR=			
DHCLIENT_DIRS=			lib
DHCLIENT_LIBS=			YES
DHCLIENT_CMD=			
DHCLIENT_LIBS_LIST=		lib/dhclient.lib
DHCLIENT_SMLINKS=		

.else
.endif

.if ${PORT_OPTIONS:MPLTERM}
PLTERM_TRUE=			PLTERM	
PLTERM_PATH=			plterm.in
PLTERM_ROOT=			rw
PLTERM_ARGS_MAKE=		PREFIX=/
PLTERM_TAR=			
PLTERM_DIRS=			lib
PLTERM_LIBS=			YES
PLTERM_CMD=			
PLTERM_LIBS_LIST=		lib/plterm.lib
PLTERM_SMLINKS=		

.else
.endif

.if ${PORT_OPTIONS:MSUBR}
SUBR_TRUE=			SUBR	
SUBR_PATH=			subr.lib.in
SUBR_ROOT=			rw
SUBR_ARGS_MAKE=		PREFIX=/
SUBR_TAR=			
SUBR_DIRS=			lib
SUBR_LIBS=			YES
SUBR_CMD=			
SUBR_LIBS_LIST=		lib/subr.lib
SUBR_SMLINKS=		
.else
.endif

.if ${PORT_OPTIONS:MSHELL}
SHELL_TRUE=			SHELL	
SHELL_PATH=			shell.lua
SHELL_ROOT=			rw
SHELL_ARGS_MAKE=	PREFIX=/
SHELL_TAR=			
SHELL_DIRS=			bin
SHELL_LIBS=			YES
SHELL_CMD=			
SHELL_LIBS_LIST=	bin/shell
SHELL_SMLINKS=		

.else
.endif


.if ${PORT_OPTIONS:MLUALOGIN}
LUALOGIN_TRUE=			LUALOGIN	
LUALOGIN_PATH=			login.lib.in
LUALOGIN_ROOT=			rw
LUALOGIN_ARGS_MAKE=		PREFIX=/
LUALOGIN_TAR=			
LUALOGIN_DIRS=			bin
LUALOGIN_LIBS=			YES
LUALOGIN_CMD=			
LUALOGIN_LIBS_LIST=		lib/login.lib
LUALOGIN_SMLINKS=		

.else
.endif

.if ${PORT_OPTIONS:MLUALOGIN}
LUALOGINBIN_TRUE=			LUALOGINBIN	
LUALOGINBIN_PATH=			login.lua
LUALOGINBIN_ROOT=			rw
LUALOGINBIN_ARGS_MAKE=		PREFIX=/
LUALOGINBIN_TAR=			
LUALOGINBIN_DIRS=			bin
LUALOGINBIN_LIBS=			YES
LUALOGINBIN_CMD=			
LUALOGINBIN_LIBS_LIST=		sbin/login
LUALOGINBIN_SMLINKS=		

.else
.endif


.if ${PORT_OPTIONS:MSHELLLIB}
SHELLLIB_TRUE=			SHELLLIB	
SHELLLIB_PATH=			shell.lib.lua
SHELLLIB_ROOT=			rw
SHELLLIB_ARGS_MAKE=		PREFIX=/
SHELLLIB_TAR=			
SHELLLIB_DIRS=			bin
SHELLLIB_LIBS=			YES
SHELLLIB_CMD=			
SHELLLIB_LIBS_LIST=		lib/shell.lib
SHELLLIB_SMLINKS=		

.else
.endif


.if ${PORT_OPTIONS:MLANO}
LANO_TRUE=			LANO	
LANO_PATH=			ple.lua
LANO_ROOT=			rw
LANO_ARGS_MAKE=		PREFIX=/
LANO_TAR=			
LANO_DIRS=			bin
LANO_LIBS=			YES
LANO_CMD=			
LANO_LIBS_LIST=		lib/lano.lib
LANO_SMLINKS=		

.else
.endif

.if ${PORT_OPTIONS:MRCLOCAL}
RCLOCAL_TRUE=			RCLOCAL	
RCLOCAL_PATH=			rc.local.in
RCLOCAL_ROOT=			rw
RCLOCAL_ARGS_MAKE=		PREFIX=/
RCLOCAL_TAR=			
RCLOCAL_DIRS=			etc
RCLOCAL_LIBS=			YES
RCLOCAL_CMD=			
RCLOCAL_LIBS_LIST=		etc/rc.local
RCLOCAL_SMLINKS=		
.else
.endif

.if ${PORT_OPTIONS:MZNETGRAPH}
ZNETGRAPH_TRUE=			ZNETGRAPH
ZNETGRAPH_PATH=			netgraph.lua
ZNETGRAPH_ROOT=			rw
ZNETGRAPH_ARGS_MAKE=	PREFIX=/
ZNETGRAPH_TAR=			
ZNETGRAPH_DIRS=			etc
ZNETGRAPH_LIBS=			YES
ZNETGRAPH_CMD=			
ZNETGRAPH_LIBS_LIST=	/lib/netgraph.lib
ZNETGRAPH_SMLINKS=		
.else
.endif
.if ${PORT_OPTIONS:MZFWRULES}
ZFWRULES_TRUE=			ZFWRULES
ZFWRULES_PATH=			fwrules.lua
ZFWRULES_ROOT=			rw
ZFWRULES_ARGS_MAKE=		PREFIX=/
ZFWRULES_TAR=			
ZFWRULES_DIRS=			etc
ZFWRULES_LIBS=			YES
ZFWRULES_CMD=			
ZFWRULES_LIBS_LIST=		/lib/zfwrules.lib
ZFWRULES_SMLINKS=		
.else
.endif

.if ${PORT_OPTIONS:MLUABSD}
LUABSD_TRUE=			LUABSD	
LUABSD_PATH=			luabsd.lua
LUABSD_ROOT=			rw
LUABSD_ARGS_MAKE=		PREFIX=/
LUABSD_TAR=			
LUABSD_DIRS=			etc
LUABSD_LIBS=			YES
LUABSDL_CMD=			
LUABSD_LIBS_LIST=		lib/luabsd.lib
LUABSD_SMLINKS=		
.else
.endif


.if ${PORT_OPTIONS:MNANOKERN}
NAMEKERN=		LuaBSD
KERNCOMPRESS=
.endif

.if ${PORT_OPTIONS:MKERNEL}
KERNEL_TRUE=			KERNEL	
KERNEL_PATH=			usr/src/sys/${SYSARCH}/compile/${NAMEKERN}
KERNEL_ROOT=			
KERNEL_ARGS_MAKE=		clean cleandepend depend all -j${NCPU}
KERNEL_DIR=				boot
KERNEL_CMD=				(${MKDIR} ${WRKSRC}/${KERNEL_PATH}/../compile/${NAMEKERN} || true; cd ${WRKSRC}/${KERNEL_PATH}/../../conf && config ${NAMEKERN})
. if ${PORT_OPTIONS:MBSD802QTRUNK}
KERNEL_CMD+=			; cd ${WRKSRC} && ${PATCH} < ${PATCHDIR}/extrac-patch-usr-src-sys-modules-vlan.all;
. endif	
KERNEL_INTERNAL=		YES
. if defined(KERNCOMPRESS)
GZIP_ADD+=				boot/kernel/kernel
. endif
.else
.endif



.if ${PORT_OPTIONS:MWEBSHELL}
WEBSHELL_TRUE=			WEBSHELL
WEBSHELL_PATH=			www/shellinabox-static
WEBSHELL_ROOT=			rw
WEBSHELL_ARGS_MAKE=		PREFIX=/
WEBSHELL_TAR=			
WEBSHELL_DIRS=			bin
WEBSHELL_PORTS=			YES
WEBSHELL_CMD=			(cd ${PORTSDIR}/www; if [ ! -d "${PORTSDIR}/${WEBSHELL_PATH}" ]; then ${MKDIR} ${PORTSDIR}/${WEBSHELL_PATH}/files; echo "${PORTSDIR}/${WEBSHELL_PATH}"; ${PATCH} < ${PATCHDIR}/extrac-patch-port-www-shellinabox; ${FIND} ${PORTSDIR}/${WEBSHELL_PATH} -name "*.orig" -type f -delete; fi; make -C shellinabox-static clean)
WEBSHELL_PORTS_LIST=	bin/shellinaboxd
WEBSHELL_SMLINKS=		
WEBSHELL_PORT_STAGE=	${PORTSDIR}/${WEBSHELL_PATH}/work/stage
.else
.endif

.if ${PORT_OPTIONS:MISO}
IMAGES+=	iso
.endif
.if ${PORT_OPTIONS:MIMG}
IMAGES+=	img
.endif
.if ${PORT_OPTIONS:MTAR}
IMAGES+=	tar
.endif

.if ${PORT_OPTIONS:MBOOT}
BOOT_TRUE=			BOOT	
BOOT_PATH=			usr/src/stand
BOOT_ARGS_MAKE=		-j${NCPU}
BOOT_DIR=			boot
BOOT_CMD=			mkdir -p ${STAGEDIR}/boot/defaults && mkdir -p ${STAGEDIR}/boot/lua
BOOT_INTERNAL=		YES
.else
.endif

.if ${PORT_OPTIONS:MBSDSH}
BSDSH_TRUE=			BSDSH	
BSDSH_PATH=			usr/src/rescue
BSDSH_ROOT=			rw
BSDSH_ARGS_MAKE=	
BSDSH_DIR=			rescue
BSDSH_CMD=			
BSDSH_SMLINKS=		/rescue/sh|bin/sh
BSDSH_INTERNAL=		YES
.else
.endif

.if ${PORT_OPTIONS:MBOOT}
BOOT_TRUE=			BOOT	
BOOT_PATH=			usr/src/stand
BOOT_ARGS_MAKE=		-j${NCPU}
BOOT_DIR=			boot
BOOT_CMD=			mkdir -p ${STAGEDIR}/boot/defaults && mkdir -p ${STAGEDIR}/boot/lua
BOOT_INTERNAL=		YES
.else
.endif

.if ${PORT_OPTIONS:MKLDINMFS}
RW_CMD+=		    ${MKDIR} ${STAGEDIR}/rw/boot/modules && ${CP} -R ${STAGEDIR}/boot/kernel/*.ko ${STAGEDIR}/rw/boot/modules/ && ${KLDXREF} ${STAGEDIR}/rw/boot/modules; 
.else
RW_CMD+=
.endif

.if ${PORT_OPTIONS:MROOTINMFS}
RW_CMD+=			${TAR} cvpJf /mnt/root.txz -C ${STAGEDIR}/ rw; 
.else
RW_CMD+=			echo ;
.endif


.if ${PORT_OPTIONS:MXUPNPD}
XUPNPD_TRUE=			XUPNPD	
XUPNPD_PATH=			dlna.pkg.in
XUPNPD_ROOT=			rw
XUPNPD_ARGS_MAKE=		PREFIX=/
XUPNPD_TAR=			
XUPNPD_DIRS=			apps etc/dlna/plugins etc/dlna/playlists etc/dlna/config data/localmedia
XUPNPD_APP=				YES
XUPNPD_CMD=			
XUPNPD_LIBS_LIST=		apps/xupnpd.app
XUPNPD_SMLINKS=		

.else
.endif

.if ${PORT_OPTIONS:MZBIT2}
ZBIT2_TRUE=			ZBIT2	
ZBIT2_PATH=			zbitweb2.in
ZBIT2_ROOT=			rw
ZBIT2_ARGS_MAKE=	PREFIX=/
ZBIT2_TAR=			
ZBIT2_DIRS=			apps etc/dlna/plugins etc/dlna/playlists etc/dlna/config data/localmedia
ZBIT2_APP=			YES
ZBIT2_CMD=			
ZBIT2_LIBS_LIST=	apps/zbitweb2.app
ZBIT2_SMLINKS=		

.else
.endif

.if ${PORT_OPTIONS:MWEBSERVERPHP}
WEBSERVERPHP_TRUE=			WEBSERVERPHP	
WEBSERVERPHP_PATH=			easywebserver.in
WEBSERVERPHP_ROOT=			rw
WEBSERVERPHP_ARGS_MAKE=	PREFIX=/
WEBSERVERPHP_TAR=			
WEBSERVERPHP_DIRS=			apps
WEBSERVERPHP_APP=			YES
WEBSERVERPHP_CMD=			
WEBSERVERPHP_LIBS_LIST=		apps/easywebserver.app
WEBSERVERPHP_SMLINKS=		

.else
.endif

RW_CMD+=			echo

PLUGINS_LIST=		${BOOT_TRUE} ${KERNEL_TRUE} ${ROOTHACK_TRUE} ${LUAROOT_TRUE} ${BSDSH_TRUE} ${WEBSHELL_TRUE} ${PHP_TRUE} ${PLTERM_TRUE} ${RCLOCAL_TRUE} ${SHELLLIB_TRUE} ${SHELL_TRUE} ${SUBR_TRUE} \
					${XUPNPD_TRUE} ${ZBIT2_TRUE} ${WEBSERVERPHP_TRUE} ${LUABSD_TRUE} ${NETGRAPH_TRUE} ${ZFWRULES_TRUE} ${ZFWNETGRAPH_TRUE} ${LUALOGIN_TRUE} ${LUALOGINBIN_TRUE} ${LANO_TRUE} ${DHCLIENT_TRUE}

MAKE_ARGS+=			MAKEOBJDIRPREFIX=${WRKDIR}/obj \
					MK_MAN=no \
					WITHOUT_DOCCOMPRESS= \
					WITHOUT_BINUTILS= \
				    WITHOUT_CLANG= \
				    WITHOUT_CLANG_EXTRAS= \
				    WITHOUT_CLANG_FULL= \
				    WITHOUT_GCC= \
				    WITHOUT_GDB= \
				    WITHOUT_INCLUDES= \
				    WITHOUT_LLD= \
				    WITHOUT_LLDB= \
				    WITHOUT_LLVM_COV= \
				    WITHOUT_DEBUG_FILES=

#WITHOUT_NO_STRICT_ALIASING=yes



do-fetch:
.for i in ${DISTFILES}
	@${FETCH_CMD} -o ${DISTDIR} ${MASTER_SITES}/${i}
.endfor
do-extract:
	@${MKDIR} -p ${WRKSRC} 2>/dev/null || true
.for i in ${DISTFILES}
	@${TAR} xpf ${DISTDIR}/${i} -C ${WRKSRC}
	@chflags -R noschg ${WRKSRC}
.endfor	

do-configure:

BUILD:
.for i in ${PLUGINS_LIST}
. if ("${${i}_INTERNAL}" == "YES" )
	@echo "BUILD: ${i}"
	${MKDIR} ${STAGEDIR}/${${i}_ROOT}/${${i}_DIR} 2>/dev/null || true 
	${${i}_CMD}
	${MAKE} ${${i}_ARGS_MAKE} ${MAKE_ARGS} -C ${WRKSRC}/${${i}_PATH}  DESTDIR=${STAGEDIR}
	${MAKE} ${${i}_ARGS_INSTALL} ${MAKE_ARGS} -C ${WRKSRC}/${${i}_PATH}  DESTDIR=${STAGEDIR}/${${i}_ROOT} install
. elif ("${${i}_PORTS}" == "YES" )
	@echo "BUILD: ${i}"
	for dir in ${${i}_DIRS}; do \
	${MKDIR} ${STAGEDIR}/${${i}_ROOT}/$${dir} 2>/dev/null || true ;\
	done
	@${${i}_CMD}
	@${MAKE} -C ${PORTSDIR}/${${i}_PATH} ${${i}_ARGS_MAKE} clean config all
	@for i in ${${i}_PORTS_LIST}; do \
	${INSTALL} ${${i}_PORT_STAGE}/$${i} ${STAGEDIR}/${${i}_ROOT}/$$(dirname $${i}); \
	done
	@${MAKE} -C ${PORTSDIR}/${${i}_PATH} ${${i}_ARGS} clean
. elif ("${${i}_LIBS}" == "YES")
	@echo "LIBS LUA ${i}"
	for dir in ${${i}_DIRS}; do \
	${MKDIR} ${STAGEDIR}/${${i}_ROOT}/$${dir} 2>/dev/null || true ;\
	done
	@${${i}_CMD}
	for i in ${${i}_LIBS_LIST}; do \
	${INSTALL} ${PATCHDIR}/${${i}_PATH} ${STAGEDIR}/${${i}_ROOT}/$${i} || true; \
	done
. elif ("${${i}_APP}" == "YES")
	@echo "APPS LUA ${i}"
	for dir in ${${i}_DIRS}; do \
	${MKDIR} ${STAGEDIR}/${${i}_ROOT}/$${dir} 2>/dev/null || true ;\
	done
	@${${i}_CMD}
	${TAR} xvpf ${PATCHDIR}/${${i}_PATH} -C ${STAGEDIR}/${${i}_ROOT} || true; 
. endif
. for sym in ${${i}_SMLINKS}
	${LN} -sf $$(echo "${sym}" | cut -d '|' -f 1) ${STAGEDIR}/${${i}_ROOT}/$$(echo "${sym}" | cut -d '|' -f 2)
. endfor
.endfor

.if defined(GZIP_ADD)
. for gzip in ${GZIP_ADD}
	${GZIP_CMD} ${STAGEDIR}/${gzip}
. endfor
.endif


UEFIIMG: 
	@[ ! -d "${STAGEDIR}/images/cdboot" ] && ${MKDIR} ${STAGEDIR}/images || true
	@${TRUNCATE} -s 100M ${STAGEDIR}/images/efiboot.img
	MD=$$(${MDCONFIG} -a -t vnode -f ${STAGEDIR}/images/efiboot.img) && \
	${NEWFS}_msdos -F 32 -c 1 -m 0xf8 /dev/$${MD} && \
	${MOUNT} -t msdosfs /dev/$${MD} /mnt && \
	${MKDIR} /mnt/EFI/BOOT && \
	${INSTALL} ${PATCHDIR}/BOOTx64.efi.in /mnt/EFI/BOOT/BOOTX64.efi && \
	${UMOUNT} /mnt && \
	${MDCONFIG} -d -u $${MD}

compress: 
	@[ ! -d "${STAGEDIR}/images/rootfs" ] && ${MKDIR} ${STAGEDIR}/images/rootfs || true
	if [ -d "${STAGEDIR}/rw" -a -d "${STAGEDIR}/boot" ]; then \
		MD=$$(${MDCONFIG} -a -s${MFSSIZE}) && echo $${MD} && ${NEWFS} /dev/$${MD} && ${MOUNT} /dev/$${MD} /mnt && \
		${CP} -R ${STAGEDIR}/sbin/ /mnt/sbin/ && ${MKDIR} /mnt/mnt /mnt/dev /mnt/tmp /mnt/rw && \
		echo 'init_shell="/bin/lua"' > ${STAGEDIR}/boot/loader.conf && \
		echo 'init_script="/lib/init"' >> ${STAGEDIR}/boot/loader.conf && \
		echo 'loader_logo="beastie"' >> ${STAGEDIR}/boot/loader.conf && \
		echo 'zfs_load="YES"' >> ${STAGEDIR}/boot/loader.conf && \
		echo 'mfs_load="YES"' >> ${STAGEDIR}/boot/loader.conf && \
		echo 'mfs_type="mfs_root"' >> ${STAGEDIR}/boot/loader.conf && \
		echo 'mfs_name="/mfsroot"' >> ${STAGEDIR}/boot/loader.conf && \
		echo 'ahci_load="YES"' >> ${STAGEDIR}/boot/loader.conf && \
		echo 'geom_md_load="YES"' >> ${STAGEDIR}/boot/loader.conf && \
		echo 'geom_ccd_load="YES"' >> ${STAGEDIR}/boot/loader.conf && \
		echo 'geom_label_load="YES"' >> ${STAGEDIR}/boot/loader.conf && \
		echo 'geom_mirror_load="YES"' >> ${STAGEDIR}/boot/loader.conf && \
		echo 'geom_part_gpt_load="YES"' >> ${STAGEDIR}/boot/loader.conf && \
		echo 'geom_journal_load="YES"' >> ${STAGEDIR}/boot/loader.conf && \
		echo 'mdio_load="YES"' >> ${STAGEDIR}/boot/loader.conf && \
		echo 'tmpfs_load="YES"' >> ${STAGEDIR}/boot/loader.conf && \
		echo 'ipfw_load="YES"' >> ${STAGEDIR}/boot/loader.conf && \
		echo 'ipfw_nat_load="YES"' >> ${STAGEDIR}/boot/loader.conf && \
		echo 'boot_multicons="YES"' >> ${STAGEDIR}/boot/loader.conf && \
		echo 'boot_serial="YES"' >> ${STAGEDIR}/boot/loader.conf && \
		echo 'comconsole_speed="115200"' >> ${STAGEDIR}/boot/loader.conf && \
		echo 'console="comconsole,vidconsole"' >> ${STAGEDIR}/boot/loader.conf && \
		echo 'vfs.root.mountfrom="ufs:/dev/md0"' >> ${STAGEDIR}/boot/loader.conf && \
		${PRINTF} '${LUABSD_LOADER_CONF_ADD}' >> ${STAGEDIR}/boot/loader.conf && \
		echo '-Dh' > ${STAGEDIR}/boot.config && \
		[ -d "${STAGEDIR}/rw/usr" ] && ${RM} -R ${STAGEDIR}/rw/usr || true && \
		[ -n "${RW_CMD}" ] && (${RW_CMD}) 2>/dev/null || true; \
		${TAR} cvpJf ${STAGEDIR}/images/rootfs/root.txz -C ${STAGEDIR}/ rw ; \
		${UMOUNT} /mnt && ${GZIP_CMD}</dev/$${MD}>${STAGEDIR}/images/rootfs/mfsroot.gz && \
		${MDCONFIG} -d -u$${MD}; \
	else \
		${TAR} cvpJf ${STAGEDIR}/images/rootfs/root.txz -C ${STAGEDIR}/ rw ; \
	fi
.if ${PORT_OPTIONS:MUEFI}
	@[ -d "${STAGEDIR}/boot" ] && ${INSTALL} ${PATCHDIR}/loader.efi.in ${STAGEDIR}/boot/loader.efi || true
.endif


MKIMG:
.if defined(IMAGES)

. if ${PORT_OPTIONS:MISO}
	@echo Create iso image
	[ ! -d "${STAGEDIR}/images/cdboot" ] && ${MKDIR} ${STAGEDIR}/images/cdboot || true
	[ -f "${STAGEDIR}/images/rootfs/mfsroot.gz" -a -d "${STAGEDIR}/images/cdboot" ] && ${CP} ${STAGEDIR}/images/rootfs/mfsroot.gz ${STAGEDIR}/images/cdboot/ || true
	if [ -d "${STAGEDIR}/boot" ]; then \
		${CP} -R ${STAGEDIR}/boot/ ${STAGEDIR}/images/cdboot/boot/; \
		if [ -f "${STAGEDIR}/boot.config" ]; then ${CP} -R ${STAGEDIR}/boot.config ${STAGEDIR}/images/cdboot/boot/; fi; \
	else \
		${TOUCH} ${STAGEDIR}/images/cdboot/noboot; \
	fi
.  if empty(PORT_OPTIONS:MROOTINMFS)	
	@[ -f "${STAGEDIR}/images/rootfs/root.txz" ] && ${CP} ${STAGEDIR}/images/rootfs/root.txz ${STAGEDIR}/images/cdboot/root.txz || true
	@[ -d "${STAGEDIR}/images/cdboot/boot" ] && echo 'cd9660_iconv_load="YES"' >> ${STAGEDIR}/images/cdboot//boot/loader.conf
	@[ -d "${STAGEDIR}/images/cdboot/boot" ] && echo 'cd9660_load="YES"' >> ${STAGEDIR}/images/cdboot/boot/loader.conf
	@[ -d "${STAGEDIR}/images/cdboot/boot" ] && echo 'hvm.rootfs.cdrom="/dev/iso9660/LUABSD"' >> ${STAGEDIR}/images/cdboot/boot/loader.conf
.  endif	


.if ${PORT_OPTIONS:MUEFI}
	${MAKEFS}  -t cd9660 -o 'bootimage=i386;${STAGEDIR}/images/efiboot.img' -o no-emul-boot -o rockridge -o label="LuaBSD" -o publisher="LuaBSD" ${STAGEDIR}/images/LuaBSD-uefi-bootcd.iso ${STAGEDIR}/images/cdboot
	${MAKEFS} -t cd9660 -o rockridge,bootimage=i386\;/boot/cdboot,no-emul-boot,label=LuaBSD,publisher="LuaBSD" ${STAGEDIR}/images/LuaBSD-bootcd.iso ${STAGEDIR}/images/cdboot
.else
	${MAKEFS} -t cd9660 -o rockridge,bootimage=i386\;/boot/cdboot,no-emul-boot,label=LuaBSD,publisher="LuaBSD" ${STAGEDIR}/images/LuaBSD-bootcd.iso ${STAGEDIR}/images/cdboot
.endif
. endif
. if  ${PORT_OPTIONS:MIMG}
	@[ ! -d "${STAGEDIR}/images/stick" ] && ${MKDIR} ${STAGEDIR}/images/stick || true
	@[ -d "${STAGEDIR}/boot" -a -d "${STAGEDIR}/images/stick" ] && ${CP} -R ${STAGEDIR}/boot/ ${STAGEDIR}/images/stick/boot/
	@[ -d "${STAGEDIR}/boot" -a -d "${STAGEDIR}/images/stick" ] && ${CP} -R ${STAGEDIR}/images/rootfs/ ${STAGEDIR}/images/stick/
	@[ -d "${STAGEDIR}/images/stick" ] && ${DD} if=/dev/zero of=${STAGEDIR}/images/LuaBSD-uefi-stick.img bs=1M count=1024
	[ -f "${STAGEDIR}/images/LuaBSD-uefi-stick.img" ] && MD=$$(${MDCONFIG} -t vnode -f ${STAGEDIR}/images/LuaBSD-uefi-stick.img ) && ${GPART} create -s gpt $${MD} && \
	${GPART} add -t freebsd-boot -s 128K $${MD} &&  ${GPART} add -t EFI -s 10M $${MD} && ${GPART} add -t freebsd-ufs -l LUABSD $${MD} && ${NEWFS}_msdos /dev/$${MD}p2 && ${MOUNT}_msdosfs /dev/$${MD}p2 /mnt && \
	${MKDIR} /mnt/EFI/BOOT && ${CP} ${PATCHDIR}/loader.efi.in /mnt/EFI/BOOT/BOOTX64.efi && ${UMOUNT} /mnt && ${NEWFS} -O2 /dev/$${MD}p3 && ${MOUNT} /dev/$${MD}p3 /mnt && \
	${CP} -R ${STAGEDIR}/boot/ /mnt/boot/ && ${CP} -R ${STAGEDIR}/images/rootfs/ /mnt/ && ${UMOUNT} /mnt  && ${GPART} bootcode -b /boot/pmbr -p /boot/gptboot -i 1 $${MD} && ${MDCONFIG} -d -u$${MD}
.  if empty(PORT_OPTIONS:MROOTINMFS)	
	@[ -f "${STAGEDIR}/images/rootfs/root.txz" ] && ${CP} ${STAGEDIR}/images/rootfs/root.txz ${STAGEDIR}/images/cdboot/root.txz || true
	@[ -d "${STAGEDIR}/images/stick/boot" ] && echo 'hvm.rootfs.ufs="/dev/gpt/LUABSD"' >> ${STAGEDIR}/images/stick/boot/loader.conf

.  endif
. endif
. if  ${PORT_OPTIONS:MTAR}
	@[ -d "${STAGEDIR}/images/rootfs" -a -d "${STAGEDIR}/boot" ] && ${TAR} cvpf ${STAGEDIR}/images/LuaBSD-base.tar -C ${STAGEDIR}/images/rootfs . -C ${STAGEDIR} boot || true
	@[ -f "${STAGEDIR}/images/LuaBSD-base.tar" ] &&  ${GZIP_CMD} -9 ${STAGEDIR}/images/LuaBSD-base.tar || true
. endif
.endif
.if ${PORT_OPTIONS:MUEFI}
do-build: BUILD UEFIIMG compress MKIMG
.else
do-build: BUILD compress MKIMG
.endif

do-install:


pre-clean:
	@chflags -R noschg ${WRKDIR} 2>/dev/null || true

testim:
	${PRINTF} "${LUABSD_LOADER_CONF_ADD}"


.include <bsd.port.mk>
