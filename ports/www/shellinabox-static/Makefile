# Created by: Olivier Cochard-Labbe <olivier@FreeBSD.org>
# $FreeBSD: head/www/shellinabox/Makefile 496469 2019-03-21 15:05:14Z olivier $

PORTNAME=	shellinabox
PORTVERSION=	2.20
DISTVERSIONPREFIX=	v
PORTREVISION=	3
CATEGORIES=	www

MAINTAINER=	olivier@FreeBSD.org
COMMENT=	Publish command line shell through AJAX interface

LICENSE=	GPLv2

USES=	autoreconf libtool ssl

OPTIONS_DEFINE=	CORES NOLOGIN
CORES_DESC=	Patch shellinaboxd to enable core dumps
NOLOGIN_DESC=	Login through ssh (not through login)

GNU_CONFIGURE=	yes
USE_GITHUB=	yes

USE_RC_SUBR=	shellinaboxd
USERS?=		shellinabox
GROUPS?=	shellinabox

PKGDEINSTALL=	${WRKDIR}/pkg-deinstall

SUB_FILES=	pkg-deinstall
SUB_LIST=	USERS=${USERS} GROUPS=${GROUPS}

CONFIGURE_ARGS=	--disable-runtime-loading --disable-pam \
		CFLAGS=-I${LOCALBASE}/include LDFLAGS=-L${LOCALBASE}/lib

NOLOGIN_CONFIGURE_ON=	--disable-login

.include <bsd.port.options.mk>

post-patch:
.if ${PORT_OPTIONS:MCORES}
	@${REINPLACE_CMD} \
		-e 's|prctl(PR_SET_DUMPABLE,|// &|' \
		-e 's|setrlimit(RLIMIT_CORE,|// &|' \
			${WRKSRC}/shellinabox/shellinaboxd.c
.endif

post-build:
	${AR} cr ${WRKSRC}/.libs/libhttp.a ${WRKSRC}/libhttp/hashmap.o ${WRKSRC}/libhttp/trie.o ${WRKSRC}/libhttp/httpconnection.o ${WRKSRC}/libhttp/server.o ${WRKSRC}/libhttp/ssl.o ${WRKSRC}/libhttp/url.o /usr/lib/libssl.a /usr/lib/libz.a /usr/lib/libcrypto.a /usr/lib/libm.a
	${CC} -g -std=gnu99 -Wall -I/usr/local/include -o ${WRKSRC}/shellinaboxd ${WRKSRC}/shellinabox/shellinaboxd.o ${WRKSRC}/shellinabox/externalfile.o ${WRKSRC}/shellinabox/launcher.o ${WRKSRC}/shellinabox/privileges.o ${WRKSRC}/shellinabox/service.o ${WRKSRC}/shellinabox/session.o \
	${WRKSRC}/shellinabox/usercss.o ${WRKSRC}/.libs/liblogging.a ${WRKSRC}/.libs/libhttp.a /usr/lib/libssl.a /usr/lib/libz.a /usr/lib/libcrypto.a /usr/lib/libutil.a /usr/lib/libc.a -static
do-install:
	${INSTALL_PROGRAM} ${WRKSRC}/shellinaboxd ${STAGEDIR}${PREFIX}/bin
	${INSTALL_MAN} ${WRKSRC}/shellinaboxd.1 ${STAGEDIR}${MAN1PREFIX}/man/man1
	@${MKDIR} ${STAGEDIR}${ETCDIR}

.include <bsd.port.mk>
