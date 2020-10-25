--- src/lualib.h.orig	2017-04-19 23:20:42.000000000 +0600
+++ src/lualib.h	2020-01-25 11:47:39.054715000 +0600
@@ -47,7 +47,103 @@
 #define LUA_LOADLIBNAME	"package"
 LUAMOD_API int (luaopen_package) (lua_State *L);
 
+#ifdef LUA_COMPAT_BDB
+#define LUA_BDB "bdb"
+LUAMOD_API int (luaopen_libluabdb) (lua_State *L);
+#endif
+
+#ifdef LUA_COMPAT_ZFS
+#define LUA_ZFS "zfs"
+LUAMOD_API int (luaopen_libluazfs) (lua_State *L);
+#endif
+
+#ifdef LUA_COMPAT_SYSTEM 
+#define LUA_SYSTEM "system"
+LUAMOD_API int (luaopen_libluasystem_os) (lua_State *L);
+#endif
+
+#ifdef LUA_COMPAT_NETGRAPH
+#define LUA_NETGRAPH "netgraph"
+LUAMOD_API int (luaopen_libluangctl) (lua_State *L);
+#endif
+
+#ifdef LUA_COMPAT_BCRYPT
+#define LUA_BCRYPT "bcrypt"
+LUAMOD_API int (luaopen_bcrypt) (lua_State *L);
+#endif
+
+#ifdef LUA_COMPAT_JSON
+#define LUA_JSON "json"
+LUAMOD_API int (luaopen_json) (lua_State *L);
+#endif
+
+#ifdef LUA_COMPAT_CJSON
+#define LUA_CJSON "cjson"
+LUAMOD_API int (luaopen_cjson) (lua_State *L);
+#endif
+
+#ifdef LUA_COMPAT_IFNET
+#define LUA_IFNET "ifnet"
+LUAMOD_API int (luaopen_libluaknet) (lua_State *L);
+#endif
+
+#ifdef LUA_COMPAT_POSIX
+#define LUA_POSIX "posix"
+LUAMOD_API int (luaopen_posix) (lua_State *L);
+#endif
+
+#ifdef LUA_COMPAT_POSIX_SHM
+#define LUA_POSIX "pshm"
+LUAMOD_API int (luaopen_libluaposix_shm) (lua_State *L);
+#endif
+
+#ifdef LUA_COMPAT_SOCKET
+#define LUA_SOCKET "sock"
+LUAMOD_API int (luaopen_socket_core) (lua_State *L);
+#define LUA_SOCKET_UNIX "usock"
+LUAMOD_API int (luaopen_socket_unix) (lua_State *L);
+#endif
+
+#ifdef LUA_COMPAT_ZLIB
+#define LUA_ZLIB "zlib"
+LUAMOD_API int (luaopen_zlib) (lua_State *L);
+#endif
+
+#ifdef LUA_COMPAT_EXPAT
+#define LUA_EXPAT "expat"
+LUAMOD_API int luaopen_lxp (lua_State *L);
+#endif
 
+#ifdef LUA_COMPAT_SYSCTL
+#define LUA_SYSCTL "sysctl"
+LUAMOD_API int (luaopen_sysctl) (lua_State *L);
+#endif
+#ifdef LUA_COMPAT_CURL
+#define LUA_CURL "lcurl"
+LUAMOD_API int (luaopen_lcurl) (lua_State *L);
+#endif
+#ifdef LUA_COMPAT_LFS
+#define LUA_LFS "lfs"
+LUAMOD_API int (luaopen_lfs) (lua_State *L);
+#endif
+#ifdef LUA_COMPAT_DIALOG
+#define LUA_DIALOG "dialog"
+LUAMOD_API int (luaopen_libluadialog) (lua_State *L);
+#endif
+#ifdef LUA_COMPAT_LLTHREADS
+#define LUA_LLTHREADS "pthreads"
+LUAMOD_API int (luaopen_lanes_core) (lua_State *L);
+#endif
+#ifdef LUA_COMPAT_OPENSSL
+#define LUA_OPENSSL "openssl"
+LUAMOD_API int (luaopen_openssl) (lua_State *L);
+#endif
+#ifdef LUA_COMPAT_XUPNPD
+#define LUA_XUPNPD "xupnpd"
+LUAMOD_API int (luaopen_luajson) (lua_State *L);
+LUAMOD_API int (luaopen_luaxcore) (lua_State *L);
+LUAMOD_API int (luaopen_luaxlib) (lua_State *L);
+#endif
 /* open all previous libraries */
 LUALIB_API void (luaL_openlibs) (lua_State *L);
 
