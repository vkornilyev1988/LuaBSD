# Created by: GreenDog <fiziologus@gmail.com>
# $FreeBSD: head/lang/lua53/Makefile 500722 2019-05-03 11:50:24Z swills $

PORTNAME=	lua
DISTVERSION=	5.3.5
PORTREVISION=	3
CATEGORIES=	lang
MASTER_SITES=	https://www.lua.org/ftp/
PKGNAMESUFFIX=	53

MAINTAINER=	russ.haley@gmail.com
COMMENT=	Powerful, efficient, lightweight, embeddable scripting language

LICENSE=	MIT

LUA_VER=	5.3
LUA_PREFIX?=	${PREFIX}
USE_LDCONFIG=	yes
SRC_TOP=	/usr/src
FETCH_ENV=	SSL_NO_VERIFY_PEER=1 SSL_NO_VERIFY_HOSTNAME=1
PLUGINS_SITES=https://git.syfy-host.com/aakauova/

# Overriding __MAKE_CONF makes sure that we don't re-parse
# /etc/make.conf during do-build, which would jeopardize the build
# if, for instance, the user set CFLAGS=mumble
# NOTE: /etc/make.conf is read BEFORE Makefile, so we already
# have its settings when we get here.
# See http://wiki.freebsd.org/MatthiasAndree/LuaLessonsLearnt
MAKE_ARGS=	__MAKE_CONF=${NONEXISTENT}

BUILD_WRKSRC=	${WRKSRC}/src

# Source, destination, and filenames to copy for the DOCS option
# (automatically added to pkg-plist if DOCS is set)
# We override DOCSDIR to get a per-version subdir.
# We put the docs for Lua proper in a lua/ subdir of the version subdir
# so that ports for Lua modules can use the version subdir too without
# making a mess.
DOCSDIR=	${PREFIX}/share/doc/lua${PKGNAMESUFFIX}/lua
PORTDOCS=	*
BUILD_WRKDOC=	${WRKSRC}/doc

LUA_PREFIX?=	${PREFIX}

# 2018-03-17: AG - These should match lua.mk, but we can't include that here
LUA_CMD=	lua${PKGNAMESUFFIX}
LUAC_CMD=	luac${PKGNAMESUFFIX}
LUA_INCDIR?=	${PREFIX}/include/lua${PKGNAMESUFFIX}
LUA_LIBDIR?=	${PREFIX}/lib

LUA_LIB_STATIC=	liblua-${LUA_VER}.a
LUA_LIB_SHARED=	liblua-${LUA_VER}.so
LUA_PC_FILE=	lua-${LUA_VER}.pc

# using the "bsd" target rather than "freebsd" saves patching out the
# assumption of using base libedit in order to make it configurable. "bsd"
# is "generic" plus the POSIX and DLOPEN options, plus -Wl,-E at link time;
# it doesn't set CC either, which makes it easier for us to control that too.
ALL_TARGET=bsd

# Options

OPTIONS_DEFAULT=LIBEDIT_DL

OPTIONS_GROUP=	PLGGRP DOCSGRP DEBUGGRP FLAGS KCSMOD PROG
OPTIONS_SINGLE=	EDITGRP FLAGS

OPTIONS_GROUP_DOCSGRP=	DOCS
OPTIONS_GROUP_DEBUGGRP=	ASSERT APICHECK
OPTIONS_GROUP_PLGGRP=	CURL PAM OPENSSL BCRYPT ADA CJSON BITOP CHECK SOCKET YML ABDI SYSCTL XAPIAN UNIT POSIX LFS SEC LDAP EXPAT PEG GI BITLIB LZLIB ROCKS 
OPTIONS_GROUP_KCSMOD=	BDB ZFS NETGRAPH IFNET SYSTEMOS PTHREADS DIALOG 
OPTIONS_GROUP_PROG=		XUPNPD

OPTIONS_SINGLE_EDITGRP=	EDITNONE LIBEDIT READLINE

OPTIONS_SINGLE_FLAGS=	STATIC DYNAMIC
DYNAMIC_DESC=		Build dynamic executables and/or libraries



OPTIONS_DEFAULT=	LIBEDIT JSON POSIX STATIC


# Option descriptions
PROG_DESC=		Programs lua script
XUPNPD_DESC=	DLNA MEDIA/TV SERVER
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

# Option implementations

ASSERT_EXTRA_PATCHES=	${PATCHDIR}/extra-patch-assert

APICHECK_CPPFLAGS=	-DLUA_USE_APICHECK

# EDITNONE currently requires no settings

LIBEDIT_DL_USES=	libedit
LIBEDIT_DL_CPPFLAGS=	-DLUA_USE_READLINE_DL

LIBEDIT_USES=		libedit
LIBEDIT_CPPFLAGS=	-DLUA_USE_LIBEDIT


READLINE_USES=		readline
READLINE_CPPFLAGS=	-DLUA_USE_READLINE

.include <bsd.port.options.mk>
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





.if ${PORT_OPTIONS:MCJSON}
CJSON_TRUE=			CJSON
CJSON_PLUGS=		lua-cjson
CJSON_SUFIX=		.tar.gz
CJSON_MK_ARGS=		CFLAGS+="-I${WRKSRC}/src" LDFLAGS+="${LIBSTATIC}"
CJSON_FETCH_CMD=	mv ${WRKSRC}/plugins/lua-cjson-master ${WRKSRC}/plugins/lua-cjson
CJSON_SITE=			https://github.com/mpx/
CJSON_DEST=			${LIBDIR} ${INCLUDEDIR} ${PREFIX}/lib/lua/${LUA_VER}
CJSON_SSUF=			/archive/master.tar.gz

. if defined(STATIC)
OPT_MAKE_ARGS+= 	${WRKSRC}/plugins/lua-cjson/fpconv.o ${WRKSRC}/plugins/lua-cjson/strbuf.o ${WRKSRC}/plugins/lua-cjson/lua_cjson.o
OPT_CFLAGS+=		-DLUA_COMPAT_CJSON
. else
OPT_MAKE_ARGS+= 	-lcjson
. endif
.else
CJSON_PLUG=
CJSON_SITES=
.endif


.if ${PORT_OPTIONS:MOPENSSL}
OPENSSL_TRUE=			OPENSSL
OPENSSL_PLUGS=		    lua-openssl
OPENSSL_SUFIX=			.tar.gz
OPENSSL_MK_ARGS=	


OPENSSL_WARN_MIN         = -Wall -Wno-unused-value -Wno-unused-function
OPENSSL_WARN             = -Wall
OPENSSL_WARN_MOST        = $(WARN) -W -Waggregate-return -Wcast-align -Wmissing-prototypes \
              	         -Wnested-externs -Wshadow -Wwrite-strings -pedantic
OPENSSL_CFLAGS           += $(WARN_MIN) -DPTHREADS -Ideps -Ideps/lua-compat/c-api \
        	             -I${WRKDIR}/${DISTNAME}/plugins/${OPENSSL_PLUGS}/deps/auxiliar -fPIC -I${WRKSRC}/src/

OPENSSL_MK_ARGS=		CFLAGS="${OPENSSL_CFLAGS}"

# OPENSSL_FETCH_CMD=	mv ${WRKSRC}/plugins/lua-openssl-master ${WRKSRC}/plugins/lua-openssl
OPENSSL_SITE=			https://git.syfy-host.com/vk/
OPENSSL_DEST=			${LIBDIR} ${INCLUDEDIR} ${PREFIX}/lib/lua/${LUA_VER}
OPENSSL_SSUF=			/archive/master.tar.gz
OPENSSL_MAKE_CMD=		gmake
OPENSSL_PATCH_CMD=		patch < ${WRKDIR}/../files/PLUGIN_PATCH-${OPENSSL_TRUE}


. if defined(STATIC)
OPT_MAKE_ARGS+= 	    ${WRKDIR}/${DISTNAME}/plugins/${OPENSSL_PLUGS}/lualibopenssl.a ${WRKDIR}/${DISTNAME}/plugins/${OPENSSL_PLUGS}/libopenssl.a
OPT_CFLAGS+=		    -DLUA_COMPAT_OPENSSL
. else
OPT_MAKE_ARGS+= 	
. endif
.else
CJSON_PLUG=
CJSON_SITES=
.endif

.if ${PORT_OPTIONS:MPAM}
PAM_TRUE=			PAM
PAM_PLUGS=			pam_lua
PAM_SUFIX=			.tar.gz
PAM_MK_ARGS=		CC=cc CFLAGS+="-I${WRKSRC}/src -I${WRKSRC}/plugins/pam_lua/src -DLUA_COMPAT_5_2 -fPIC" LDFLAGS+=""
PAM_FETCH_CMD=		mv  ${WRKSRC}/plugins/pam_lua-master ${WRKSRC}/plugins/pam_lua; \
					${REINPLACE_CMD} -e 's|$${CC} -pedantic -std=c99 -shared -rdynamic -fPIC $${CFLAGS} $${LDFLAGS} -o $$@ src/pam_lua.c|$${CC} -pedantic -std=c99 -shared -rdynamic -fPIC $${CFLAGS} $${LDFLAGS} src/pam_lua.c -c; $${AR} -scr libluapam.a pam_lua.o; $${CC} -pedantic -std=c99 -shared -rdynamic -fPIC $${CFLAGS} $${LDFLAGS} -o $$@ src/pam_lua.c|g' ${WRKSRC}/plugins/pam_lua/Makefile; 
PAM_SITE=			https://github.com/vifino/
PAM_DEST=			${LIBDIR} ${INCLUDEDIR} ${PREFIX}/lib/lua/${LUA_VER}
PAM_SSUF=			/archive/master.tar.gz
PAM_MAKE_CMD=		gmake

. if defined(STATIC)
OPT_MAKE_ARGS+= 	${WRKSRC}/plugins/pam_lua/libluapam.a /usr/lib/libpam.a 
OPT_CFLAGS+=		-DLUA_COMPAT_PAM
. else
OPT_MAKE_ARGS+= 	-lluapam
. endif
.else
PAM_PLUG=
PAM_SITES=
.endif

.if ${PORT_OPTIONS:MBDB}
BDB_TRUE=		BDB
BDB_PLUGS=		libkcs-bdb lua-bdb
BDB_SUFIX=		.tar.gz
BDB_MK_ARGS=	PREFIX=${PREFIX} KDEFINED="-I/usr/local/include/lua53 -DSTATIC -I${WRKSRC}/src -I${WRKSRC}/plugins/libkcs-bdb/src -fsanitize=safe-stack -fPIC" KLDFLAGS="${LIBSTATIC}"
BDB_SITE=		https://git.syfy-host.com/aakauova/
BDB_DEST=		${LIBDIR} ${INCLUDEDIR} ${PREFIX}/lib/lua/${LUA_VER}
BDB_SSUF=		/archive/master.tar.gz

. if defined(STATIC)
OPT_MAKE_ARGS+= 	${WRKSRC}/plugins/lua-bdb/src/libluabdb.a ${WRKSRC}/plugins/libkcs-bdb/src/libbdb.a 
OPT_CFLAGS+=		-DLUA_COMPAT_BDB
. else
OPT_MAKE_ARGS+= 	-lbdb
. endif
.else
BDB_PLUG=
BDB_SITES=
.endif


.if ${PORT_OPTIONS:MDIALOG}
DIALOG_TRUE=		DIALOG
DIALOG_PLUGS=		lua-dialog
DIALOG_SUFIX=		.tar.gz
DIALOG_MK_ARGS=	PREFIX=${PREFIX} KDEFINED="-I/usr/local/include/lua53 -DSTATIC -I${WRKSRC}/src -I${WRKSRC}/plugins/libkcs-bdb/src -fsanitize=safe-stack -fPIC" KLDFLAGS="${LIBSTATIC}"
DIALOG_SITE=		https://git.syfy-host.com/aakauova/
DIALOG_DEST=		${LIBDIR} ${INCLUDEDIR} ${PREFIX}/lib/lua/${LUA_VER}
DIALOG_SSUF=		/archive/master.tar.gz

. if defined(STATIC)
OPT_MAKE_ARGS+= 	${WRKSRC}/plugins/lua-dialog/src/libluadialog.a /usr/lib/libdialog.a /usr/lib/libncurses.a
OPT_CFLAGS+=		-DLUA_COMPAT_DIALOG
. else
OPT_MAKE_ARGS+= 	-ldialog
. endif
.else
DIALOG_PLUG=
DIALOG_SITES=
.endif


.if ${PORT_OPTIONS:MLZLIB}
LZLIB_TRUE=			LZLIB
LZLIB_PLUGS=		lzlib
LZLIB_SUFIX=		.tar.gz
LZLIB_MK_ARGS=		CFLAGS+="-I${WRKSRC}/src"
LZLIB_SITE=			https://codeload.github.com/LuaDist/
LZLIB_DEST=			${LIBDIR} ${INCLUDEDIR} ${PREFIX}/lib/lua/${LUA_VER}
LZLIB_SSUF=			/tar.gz/0.4.3?dummy=/
LZLIB_FETCH_CMD=	mv ${WRKSRC}/plugins/lzlib-0.4.3 ${WRKSRC}/plugins/lzlib; \
					${REINPLACE_CMD} -e 's|$$(CC) -o $$@ -shared $$< $$(LIBS)|$${AR} -scr libluazlib.a lzlib.o; $$(CC) -o $$@ -shared $$< $$(LIBS)|g' ${WRKSRC}/plugins/lzlib/Makefile; 

. if defined(STATIC)
OPT_MAKE_ARGS+= 	 ${WRKSRC}/plugins/lzlib/libluazlib.a /usr/lib/libz.a
OPT_CFLAGS+=		-DLUA_COMPAT_ZLIB
. else
OPT_MAKE_ARGS+= 	#-lbdb
. endif
.else
LZLIB_PLUG=
LZLIB_SITES=
.endif

.if ${PORT_OPTIONS:MCURL}
CURL_TRUE=			CURL
CURL_PLUGS=			Lua-cURLv3
CURL_SUFIX=			.tar.gz		
CURL_MK_ARGS=		BIN="libluacurl.so" OS_FLAGS="-shared" CC=cc CFLAGS+="-I${WRKSRC}/src -I${LOCALBASE}/include" LDFLAGS+="${LOCALBASE}/lib/libcurl.a"
CURL_SITE=			https://github.com/Lua-cURL/
CURL_DEST=			${LIBDIR} ${INCLUDEDIR} ${PREFIX}/lib/lua/${LUA_VER}
CURL_SSUF=			/archive/master.zip
CURL_FETCH_CMD=		mv ${WRKSRC}/plugins/Lua-cURLv3-master ${WRKSRC}/plugins/Lua-cURLv3 ; \
					${REINPLACE_CMD} -e 's|= $$(T).so|?= $$(T).so|g' ${WRKSRC}/plugins/Lua-cURLv3/Makefile; \
					${REINPLACE_CMD} -e 's| -lcurl||g' ${WRKSRC}/plugins/Lua-cURLv3/Makefile; \
					${REINPLACE_CMD} -e 's|/usr/lib|/usr/local/lib|g' ${WRKSRC}/plugins/Lua-cURLv3/Makefile; \
					${REINPLACE_CMD} -e 's|$$(CC) $$(CF) -o $$@ $$^ $$(LF)|$$(CC) $$(CF) $$^ $$(LF) ${LIBSTATIC}; $${AR} -scr libluacurl.a *.o; $$(CC) $$(CF) -o $$@ $$^ $$(LF)|g' ${WRKSRC}/plugins/Lua-cURLv3/Makefile;
CURL_MAKE_CMD=	gmake
CURL_PATCH_CMD=		patch < ${WRKDIR}/../files/PLUGIN_PATCH-${CURL_TRUE}

. if defined(STATIC)
OPT_MAKE_ARGS+= 	 ${WRKSRC}/plugins/Lua-cURLv3/libluacurl.a ${LOCALBASE}/lib/libcurl.a  /usr/local/lib/libnghttp2.a  /usr/lib/libssl.a /usr/lib/libheimntlm.a /usr/lib/libhx509.a /usr/lib/libcom_err.a \
					 /usr/lib/libcrypto.a /usr/lib/libasn1.a /usr/lib/libwind.a /usr/lib/libheimbase.a /usr/lib/libroken.a /usr/lib/libcrypt.a /usr/lib/libz.a /usr/lib/libkrb5.a /usr/lib/libgssapi.a \
					 /usr/lib/libgssapi_krb5.a /usr/lib/libthr.a /usr/lib/libprivateheimipcc.a
OPT_CFLAGS+=		-DLUA_COMPAT_CURL
. else
OPT_MAKE_ARGS+= 	#-lbdb
. endif
.else
CURL_PLUG=
CURL_SITES=
.endif


.if ${PORT_OPTIONS:MLFS}
LFS_TRUE=			LFS
LFS_PLUGS=			luafilesystem
LFS_SUFIX=			.tar.gz		
LFS_MK_ARGS=		CC=cc CFLAGS+="-I${WRKSRC}/src -fPIC"
LFS_SITE=			https://codeload.github.com/keplerproject/
LFS_DEST=			${LIBDIR} ${INCLUDEDIR} ${PREFIX}/lib/lua/${LUA_VER}
LFS_SSUF=			/tar.gz/v1_7_0?dummy=/
LFS_FETCH_CMD=		mv  ${WRKSRC}/plugins/luafilesystem-1_7_0 ${WRKSRC}/plugins/luafilesystem
LFS_MAKE_CMD=	gmake


. if defined(STATIC)
OPT_MAKE_ARGS+= 	${WRKSRC}/plugins/luafilesystem/src/lfs.o 
OPT_CFLAGS+=		-DLUA_COMPAT_LFS
. else
OPT_MAKE_ARGS+= 	#-lbdb
. endif
.else
CURL_PLUG=
CURL_SITES=
.endif

.if ${PORT_OPTIONS:MNETGRAPH}
NETGRAPH_TRUE=		NETGRAPH
NETGRAPH_PLUGS=		libkcs-ngraph lua-ngctl
NETGRAPH_SUFIX=		.tar.gz
NETGRAPH_MK_ARGS=	PREFIX=${PREFIX} KDEFINED="-I/usr/local/include/lua53 -I${WRKSRC}/plugins/libkcs-ngraph/src -DSTATIC -I${WRKSRC}/src -fsanitize=safe-stack -fPIC" KLDFLAGS="${LIBSTATIC}"
NETGRAPH_SITE=		https://git.syfy-host.com/aakauova/
NETGRAPH_DEST=		${LIBDIR} ${INCLUDEDIR} ${PREFIX}/lib/lua/${LUA_VER}
NETGRAPH_SSUF=		/archive/master.tar.gz


. if defined(STATIC)
OPT_MAKE_ARGS+= 	${WRKSRC}/plugins/lua-ngctl/src/libluangctl.a ${WRKSRC}/plugins/libkcs-ngraph/src/libngraph.a /usr/lib/libnetgraph.a
OPT_CFLAGS+=		-DLUA_COMPAT_NETGRAPH
. else
OPT_MAKE_ARGS+= 	#-lbdb
. endif
.else
NETGRAPH_PLUG=
NETGRAPH_SITES=
.endif



.if ${PORT_OPTIONS:MIFNET}
IFNET_TRUE=			IFNET
IFNET_PLUGS=		lua-knet
IFNET_SUFIX=		.tar.gz
IFNET_MK_ARGS=		PREFIX=${PREFIX} KDEFINED="-I/usr/local/include/lua53 -I${WRKSRC}/plugins/libkcs-ngraph/src -DSTATIC -I${WRKSRC}/src -fsanitize=safe-stack -fPIC" KLDFLAGS="${LIBSTATIC}"
IFNET_SITE=			https://git.syfy-host.com/aakauova/
IFNET_DEST=			${LIBDIR} ${INCLUDEDIR} ${PREFIX}/lib/lua/${LUA_VER}
IFNET_SSUF=			/archive/master.tar.gz

. if defined(STATIC)
OPT_MAKE_ARGS+= 	${WRKSRC}/plugins/lua-knet/src/libluaknet.a /usr/lib/libjail.a
OPT_CFLAGS+=		-DLUA_COMPAT_IFNET
. else
OPT_MAKE_ARGS+= 	#-lbdb
. endif
.else
IFNET_PLUG=
IFNET_SITES=
.endif

.if ${PORT_OPTIONS:MSYSCTL}
SYSCTL_TRUE=			SYSCTL
SYSCTL_PLUGS=			lua-sysctl
SYSCTL_SUFIX=			.tar.gz
SYSCTL_MK_ARGS=			CFLAGS+="-I${WRKSRC}/src -O2 -pipe -Wall -Wextra -DLUA_COMPAT_5_2 -fPIC" LDFLAGS+="-shared -Wl,-soname,lua_sysct ${LIBSTATIC} -o ${WRKSRC}/plugins/lua-sysctl/build/luasysctl.o"
SYSCTL_FETCH_CMD=		mv ${WRKSRC}/plugins/lua-sysctl-master ${WRKSRC}/plugins/lua-sysctl && sed -ie 's|`pkg-config --cflags lua-5.2`||g' ${WRKSRC}/plugins/lua-sysctl/Makefile \
						&& sed -ie 's|$${CFLAGS} -o $${.TARGET}|$${CFLAGS} |g' ${WRKSRC}/plugins/lua-sysctl/Makefile && sed -ie 's|$${.ALLSRC}|$${.ALLSRC} ; $${AR} -csr build/libluasysctl.a build/luasysctl.o |g' ${WRKSRC}/plugins/lua-sysctl/Makefile
SYSCTL_SITE=			https://github.com/kAworu/
SYSCTL_DEST=			${LIBDIR} ${INCLUDEDIR} ${PREFIX}/lib/lua/${LUA_VER}
SYSCTL_SSUF=			/archive/master.tar.gz

. if defined(STATIC)
OPT_MAKE_ARGS+= 	${WRKSRC}/plugins/lua-sysctl/build/libluasysctl.a
OPT_CFLAGS+=		-DLUA_COMPAT_SYSCTL
. else
OPT_MAKE_ARGS+= 	#-lbdb
. endif
.else
SYSCTL_PLUG=
SYSCTL_SITES=
.endif

.if ${PORT_OPTIONS:MEXPAT}
EXPAT_TRUE=				EXPAT
EXPAT_PLUGS=			luaexpat
EXPAT_SUFIX=			.tar.gz
EXPAT_MK_ARGS=			CFLAGS+="-I${WRKSRC}/src -I${LOCALBASE}/include -DLUA_C89_NUMBERS -Wall -fPIC -DLUA_COMPAT_5_2 " LDFLAGS+="${LIBSTATIC}" EXPAT_LIB="${LOCALBASE}/lib/libexpat.a" 
. if defined(STATIC)
EXPAT_MK_ARGS+=			LIBNAME=lxp.o
. else
EXPAT_MK_ARGS+=			LIBNAME=lxp.so
. endif
LIB_DEPENDS+=			libexpat.so:${PORTSDIR}/textproc/expat2
EXPAT_FETCH_CMD=		mv ${WRKSRC}/plugins/luaexpat-master ${WRKSRC}/plugins/luaexpat && mv ${WRKSRC}/plugins/luaexpat/makefile ${WRKSRC}/plugins/luaexpat/Makefile ;\
						${REINPLACE_CMD} -e 's|= -lexpat|?=|g' ${WRKSRC}/plugins/luaexpat/Makefile; ${REINPLACE_CMD} -e 's|= $(T).so|?= $(T).so|g' ${WRKSRC}/plugins/luaexpat/Makefile; \
						${REINPLACE_CMD} -e 's|$$(CC) $$(CF) -o $$@ src/$$(T)lib.c $$(LF)|$$(CC) $$(CF) -o $$@ src/$$(T)lib.c $$(LF); $${AR} -scr src/lualxp.a src/lxp.o|g' ${WRKSRC}/plugins/luaexpat/Makefile
EXPAT_SITE=			https://github.com/LuaDist/
EXPAT_DEST=			${LIBDIR} ${INCLUDEDIR} ${PREFIX}/lib/lua/${LUA_VER}
EXPAT_SSUF=			/archive/master.tar.gz
EXPAT_MAKE_CMD=		gmake

. if defined(STATIC)
OPT_MAKE_ARGS+= 	${WRKSRC}/plugins/luaexpat/src/lualxp.a ${LOCALBASE}/lib/libexpat.a
OPT_CFLAGS+=		-DLUA_COMPAT_EXPAT
. else
OPT_MAKE_ARGS+= 	-lexpat
. endif
.else
EXPAT_PLUG=
EXPAT_SITES=
.endif

.if ${PORT_OPTIONS:MSOCKET}
SOCKET_TRUE=			SOCKET
SOCKET_PLUGS=			luasocket
SOCKET_SUFIX=			.tar.gz
SOCKET_MK_ARGS=			LDFLAGS+="-shared -o "  CFLAGS+="-fPIC -I${WRKSRC}/src -DLUA_COMPAT_5_2 -DLUASOCKET_NODEBUG -DLUA_NOCOMPAT_MODULE -DLUASOCKET_API='__attribute__((visibility(\"default\")))' -DUNIX_API='__attribute__((visibility(\"default\")))' -DMIME_API='__attribute__((visibility(\"default\")))'" INSTALL_TARGET=install-unix LUAV=5.3 PLAT=linux 
SOCKET_FETCH_CMD=		mv ${WRKSRC}/plugins/luasocket-3.0-rc1 ${WRKSRC}/plugins/luasocket || true ; mv ${WRKSRC}/plugins/luasocket/makefile ${WRKSRC}/plugins/luasocket/Makefile; \
						mv ${WRKSRC}/plugins/luasocket/src/makefile ${WRKSRC}/plugins/luasocket/src/Makefile; \
						${REINPLACE_CMD} -e 's|gcc|${CC}|g' ${WRKSRC}/plugins/luasocket/Makefile; \
						${REINPLACE_CMD} -e 's|gcc|${CC}|g' ${WRKSRC}/plugins/luasocket/src/Makefile; \
						${REINPLACE_CMD} -e 's|CFLAGS=|CFLAGS\+=|g' ${WRKSRC}/plugins/luasocket/Makefile; \
						${REINPLACE_CMD} -e 's|LDFLAGS=|LDFLAGS\+=|g' ${WRKSRC}/plugins/luasocket/Makefile; \
						${REINPLACE_CMD} -e 's|CFLAGS=|CFLAGS\+=|g' ${WRKSRC}/plugins/luasocket/Makefile; \
						${REINPLACE_CMD} -e 's|LDFLAGS=|LDFLAGS\+=|g' ${WRKSRC}/plugins/luasocket/src/Makefile; \
						${REINPLACE_CMD} -e 's/prefix/PREFIX/g' ${WRKSRC}/plugins/luasocket/src/Makefile; \
						${REINPLACE_CMD} -e 's|$$(LD) $$(SOCKET_OBJS)|$${AR} -scr luasocket.a $$(SOCKET_OBJS); $$(LD) $$(SOCKET_OBJS)|g' ${WRKSRC}/plugins/luasocket/src/Makefile; \
						${REINPLACE_CMD} -e 's|$$(LD) $$(SERIAL_OBJS)|$${AR} -scr luaserial.a $$(SERIAL_OBJS); $$(LD) $$(SERIAL_OBJS)|g' ${WRKSRC}/plugins/luasocket/src/Makefile; \
						${REINPLACE_CMD} -e 's|$$(LD) $$(MIME_OBJS)|$${AR} -scr luamime.a $$(MIME_OBJS); $$(LD) $$(MIME_OBJS)|g' ${WRKSRC}/plugins/luasocket/src/Makefile; \
						${REINPLACE_CMD} -e 's|$$(LD) $$(UNIX_OBJS)|$${AR} -scr luaunix.a $$(UNIX_OBJS); $$(LD) $$(UNIX_OBJS)|g' ${WRKSRC}/plugins/luasocket/src/Makefile; \
						${REINPLACE_CMD} -e 's|^PLAT=|PLAT?=|g' ${WRKSRC}/plugins/luasocket/src/Makefile; \
						${REINPLACE_CMD} -e 's|^PLAT=|PLAT?=|g' ${WRKSRC}/plugins/luasocket/Makefile; \
						${MV} ${WRKSRC}/plugins/luasocket/src/serial.c ${WRKSRC}/plugins/luasocket/src/serial.c.reback; echo '\#include "luasocket.h"' > ${WRKSRC}/plugins/luasocket/src/serial.c; ${CAT} ${WRKSRC}/plugins/luasocket/src/serial.c.reback >> ${WRKSRC}/plugins/luasocket/src/serial.c

SOCKET_SITE=			https://codeload.github.com/diegonehab/
SOCKET_MAKE_CMD=		gmake
SOCKET_DEST=			${LIBDIR} ${INCLUDEDIR} ${PREFIX}/lib/lua/${LUA_VER}
SOCKET_SSUF=			/tar.gz/v3.0-rc1?dummy=/

. if defined(STATIC)
OPT_MAKE_ARGS+= 	${WRKSRC}/plugins/luasocket/src/luaserial.a ${WRKSRC}/plugins/luasocket/src/luaunix.a ${WRKSRC}/plugins/luasocket/src/luasocket.a  ${WRKSRC}/plugins/luasocket/src/luamime.a
OPT_CFLAGS+=		-DLUA_COMPAT_SOCKET
. else
OPT_MAKE_ARGS+= 	#-lbdb
. endif
.else
SOCKET_PLUG=
SOCKET_SITES=
.endif


.if ${PORT_OPTIONS:MZFS}
ZFS_TRUE=		ZFS
ZFS_PLUGS=		libkcs-kzfs lua-zfs
ZFS_SUFIX=		.tar.gz
ZFS_MK_ARGS=	PREFIX=${PREFIX} DIR_SRCTOP="/usr/src" KDEFINED="-I/usr/local/include -I${WRKSRC}/src -I${WRKSRC}/src -I${WRKSRC}/plugins/libkcs-kzfs/src -DSTATIC_LIB -DZDEBUG" KLDFLAGS="${LIBSTATIC}" LDFLAGS+="${LIBSTATIC} -lgeom  -O3 -pipe -DHARDENEDBSD -shared -DBSD112"
ZFS_SITE=		https://git.syfy-host.com/aakauova/
ZFS_DEST=		${LIBDIR} ${INCLUDEDIR} ${PREFIX}/lib/lua/${LUA_VER}
ZFS_SSUF=		/archive/master.tar.gz

. if defined(STATIC)
OPT_MAKE_ARGS+= 	${WRKSRC}/plugins/lua-zfs/src/libluazfs.a ${WRKSRC}/plugins/libkcs-kzfs/src/libkzfs.a /usr/lib/libzfs.a /usr/lib/libzfs_core.a /usr/lib/libnvpair.a ${LOCALBASE}/lib/libintl.a /usr/lib/libuutil.a /usr/lib/libgeom.a /usr/lib/libz.a \
					/usr/lib/libbsdxml.a /usr/lib/libmd.a /usr/lib/libavl.a /usr/lib/libutil.a  /usr/lib/libumem.a /usr/lib/libsbuf.a
OPT_CFLAGS+=		-DLUA_COMPAT_ZFS
. else
OPT_MAKE_ARGS+= 	-lzfs
. endif
.else
ZFS_PLUG=
ZFS_SITES=
.endif

.if ${PORT_OPTIONS:MSYSTEMOS}
SYSTEMOS_TRUE=		SYSTEMOS
SYSTEMOS_PLUGS=		libkcs-base lua-system_os
SYSTEMOS_SUFIX=		.tar.gz
SYSTEMOS_MK_ARGS=	PREFIX=${PREFIX} KDEFINED="-I${WRKSRC}/plugins/libkcs-base/src -I/usr/local/include/lua53 -DSTATIC -I${WRKSRC}/src -fsanitize=safe-stack -fPIC" KLDFLAGS="${LIBSTATIC}"
SYSTEMOS_SITE=		https://git.syfy-host.com/aakauova/
SYSTEMOS_DEST=		${LIBDIR} ${INCLUDEDIR} ${PREFIX}/lib/lua/${LUA_VER}
SYSTEMOS_SSUF=		/archive/master.tar.gz

. if defined(STATIC)
OPT_MAKE_ARGS+= 	${WRKSRC}/plugins/lua-system_os/src/libluasystem_os.a ${WRKSRC}/plugins/libkcs-base/src/libbase.a  /usr/lib/libkvm.a /usr/lib/libutil.a \
					/usr/lib/libelf.a
OPT_CFLAGS+=		-DLUA_COMPAT_SYSTEM 
. else
OPT_MAKE_ARGS+= 	-lsystem_os
. endif
.else
SYSTEMOS_PLUG=
SYSTEMOS_SITES=
.endif


.if ${PORT_OPTIONS:MXUPNPD}
XUPNPD_TRUE=		XUPNPD
XUPNPD_PLUGS=		xupnpd
XUPNPD_SUFIX=		.tar.gz
XUPNPD_MK_ARGS=		CFLAGS="-I${WRKSRC}/src -DINET -DWITH_LIBUUID"
XUPNPD_SITE=		https://github.com/clark15b/
XUPNPD_DEST=		${LIBDIR} ${INCLUDEDIR} ${PREFIX}/lib/lua/${LUA_VER}
XUPNPD_SSUF=		/archive/master.tar.gz
XUPNPD_FETCH_CMD=	[ ! -d "${WRKSRC}/plugins/xupnpd" ] && mv ${WRKSRC}/plugins/xupnpd-master ${WRKSRC}/plugins/xupnpd  || true
# PTHREADS_MAKE_CMD=	${GMAKE}
XUPNPD_PATCH_CMD=	[ ! -f "${WRKSRC}/plugins/xupnpd/src/Makefile.orig" ] && patch < ${WRKDIR}/../files/PLUGIN_PATCH-${XUPNPD_TRUE} || true


. if defined(STATIC)
OPT_MAKE_ARGS+= 	${WRKSRC}/plugins/xupnpd/build/xupnpd.a  /usr/lib/libssl.a /usr/lib/libcrypto.a  /usr/lib/libdl.a /usr/local/lib/gcc48/libstdc++.a
OPT_CFLAGS+=		-DLUA_COMPAT_XUPNPD -DLUA_COMPAT_5_2 -DINET -DWITH_LIBUUID
. else
OPT_MAKE_ARGS+= 	
. endif
.else
XUPNPD_PLUG=
XUPNPD_SITES=
.endif


.if ${PORT_OPTIONS:MPTHREADS}
PTHREADS_TRUE=		PTHREADS
PTHREADS_PLUGS=		lanes
PTHREADS_SUFIX=		.tar.gz
# . if defined(STATIC)
# PTHREADS_MK_ARGS=	CFLAGS+="-I${WRKSRC}/src -I/usr/include"
# . else
# PTHREADS_MK_ARGS=	CFLAGS+="-I${WRKSRC}/src -DLUA_COMPAT_5_2 -SHARED"
# . endif
PTHREADS_MK_ARGS=	CC=gcc CFLAGS+="-I${WRKSRC}/src -I/usr/include -I${WRKSRC}/src -I/usr/local/include -shared -DLUA_COMPAT_5_2 -DLUA_USE_LINUX -D__APPLE__ -pthread -fPIC" LDFLAGS+="${WRKSRC}/src/liblua.a" LUA_PATH="${WRKSRC}"
PTHREADS_SITE=		https://github.com/LuaLanes/
PTHREADS_DEST=		${LIBDIR} ${INCLUDEDIR} ${PREFIX}/lib/lua/${LUA_VER}
PTHREADS_SSUF=		/archive/master.tar.gz
PTHREADS_FETCH_CMD=	[ ! -d "${WRKSRC}/plugins/lanes" ] && mv ${WRKSRC}/plugins/lanes-master ${WRKSRC}/plugins/lanes  || true
# PTHREADS_MAKE_CMD=	${GMAKE}
PTHREADS_PATCH_CMD=	[ ! -f "${WRKSRC}/plugins/lanes/src/Makefile.orig" ] && patch < ${WRKDIR}/../files/PLUGIN_PATCH-${PTHREADS_TRUE} || true


. if defined(STATIC)
OPT_MAKE_ARGS+= 	${WRKSRC}/plugins/lanes/src/lanes/liblanes.a /usr/lib/libpthread.a /usr/lib/libthr.a 
OPT_CFLAGS+=		-DLUA_COMPAT_LLTHREADS
. else
OPT_MAKE_ARGS+= 	
. endif
.else
PTHREADS_PLUG=
PTHREADS_SITES=
.endif


PLUGINS_LIST=	${BDB_TRUE} ${SYSTEMOS_TRUE} ${ZFS_TRUE} ${CJSON_TRUE} ${NETGRAPH_TRUE} ${IFNET_TRUE} ${SYSCTL_TRUE} ${SOCKET_TRUE} ${EXPAT_TRUE} ${LZLIB_TRUE} ${CURL_TRUE} ${LFS_TRUE} ${PAM_TRUE} ${PTHREADS_TRUE} ${XUPNPD_TRUE} \
				${DIALOG_TRUE} ${OPENSSL_TRUE}

OPT_MK_ARGS+= ${OPT_MAKE_ARGS}
CFLAGS+=	-fPIC ${OPT_CFLAGS}
# 2019-01-25: -pthread in LIBS is a work around for the following bug:
# https://bugs.freebsd.org/bugzilla/show_bug.cgi?id=235211
LIBS+= 	-pthread ${OPT_MK_ARGS} -fsanitize=safe-stack

WITHOUT_NO_STRICT_ALIASING=yes

MAKE_ARGS+=	CC="${CC}" \
		MYCFLAGS="${CPPFLAGS} ${CFLAGS}" \
		MYLDFLAGS="${LDFLAGS}" \
		MYLIBS="${LIBS}" \
		LUA_T=${LUA_CMD} \
		LUAC_T=${LUAC_CMD} \
		LUA_A=${LUA_LIB_STATIC} \
		LUA_SO=${LUA_LIB_SHARED} \
		LUA_SONAME=${LUA_LIB_SHARED} \
		TO_BIN="${LUA_CMD} ${LUAC_CMD}" \
		TO_LIB="${LUA_LIB_SHARED} ${LUA_LIB_STATIC}" \
		INSTALL_TOP=${STAGEDIR}${PREFIX} \
		INSTALL_INC=${STAGEDIR}${LUA_INCDIR} \
		INSTALL_EXEC="${INSTALL_PROGRAM}"

SUB_FILES=	${LUA_PC_FILE}
SUB_LIST=	version=${PORTVERSION} \
		includedir=${LUA_INCDIR} \
		libdir=${LUA_LIBDIR} \
		soname=lua-${LUA_VER}


LUA_ROOT?=${PREFIX}/



post-patch:
	@${REINPLACE_CMD} -e "/LUA_ROOT/s,/usr/local/,${LUA_ROOT}," \
		${WRKSRC}/src/luaconf.h
		@echo "LE: ${LIBEDIT_LIBS}" 
		@echo "RL: ${READLINE_LIBS}"
post-configure:
.for i in ${PLUGINS_LIST}
. for plug in ${${i}_PLUGS}
.  if !exists(${WRKSRC}/plugins/${plug}/Makefie)
	[ ! -d "${WRKSRC}/plugins" ] && ${MKDIR} ${WRKSRC}/plugins || true
	@echo "DOWNLOAD: ${plug}${${i}_SUFIX} ${${i}_SITE}${plug}${${i}_SSUF}"
	@[ ! -f "${DISTDIR}/${plug}${${i}_SUFIX}" ] && env ${FETCH_ENV} ${FETCH_CMD} -o ${DISTDIR}/${plug}${${i}_SUFIX} "${${i}_SITE}${plug}${${i}_SSUF}"; ${TAR} xvpf ${DISTDIR}/${plug}${${i}_SUFIX} -C ${WRKSRC}/plugins || true
	${${i}_FETCH_CMD}
	(cd  ${WRKSRC}/plugins/${plug} && ${${i}_PATCH_CMD} 2>/dev/null || true)
	@[ -n "${${i}_MAKE_CMD}" ] && ${${i}_MAKE_CMD} ${${i}_MK_ARGS} -C ${WRKSRC}/plugins/${plug} || ${MAKE} ${${i}_MK_ARGS} -C ${WRKSRC}/plugins/${plug}
.   if !defined(STATIC_LIB)
	for i in ${${i}_DEST}; do \
	[ ! -d "${STAGEDIR}/$${i}" ] && ${MKDIR} ${STAGEDIR}/$${i} || true; \
	done
	echo ${DESTDIR}
	# ${MAKE} DESTDIR=${STAGEDIR}${DESTDIR} ${${i}_MK_ARGS} -C ${WRKSRC}/plugins/${plug} deinstall install
.   endif 
.  endif
. endfor
.endfor
.if !exists(${SRC_TOP}/lib/libnetbsd/libnetbsd.a)
	@make -C ${SRC_TOP}/lib/libnetbsd
.endif
.if !exists(${SRC_TOP}/lib/libc/libc.a)
	@make -C ${SRC_TOP}/lib/libc
.endif
post-patch-LIBEDIT-on:
	@${REINPLACE_CMD} -e "s,readline/,editline/,g ; \
		/history\.h/d" ${WRKSRC}/src/lua.c

post-patch-LIBEDIT_DL-on:
	@${REINPLACE_CMD} \
		-e "/^#def.*LUA_READLINE_LIBPATH/s,${PREFIX},${PREFIX}," \
		${WRKSRC}/src/lua.c


post-install:
	${STRIP_CMD} ${STAGEDIR}${PREFIX}/lib/${LUA_LIB_SHARED}
	${MV} ${STAGEDIR}${PREFIX}/man/man1/lua.1 \
		${STAGEDIR}${PREFIX}/man/man1/${LUA_CMD}.1
	${MV} ${STAGEDIR}${PREFIX}/man/man1/luac.1 \
		${STAGEDIR}${PREFIX}/man/man1/${LUAC_CMD}.1
	${INSTALL_DATA} ${WRKDIR}/${LUA_PC_FILE} \
		${STAGEDIR}${PREFIX}/libdata/pkgconfig

post-install-DOCS-on:
	${MKDIR} ${STAGEDIR}${DOCSDIR}
	(cd ${BUILD_WRKDOC} && \
		${COPYTREE_SHARE} . ${STAGEDIR}${DOCSDIR} '-not -name *\.1')

.include <bsd.port.mk>
