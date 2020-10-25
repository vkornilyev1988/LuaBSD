--- src/linit.c.orig	2017-04-19 23:20:42.000000000 +0600
+++ src/linit.c	2020-01-25 11:46:40.162363000 +0600
@@ -50,9 +50,72 @@
   {LUA_MATHLIBNAME, luaopen_math},
   {LUA_UTF8LIBNAME, luaopen_utf8},
   {LUA_DBLIBNAME, luaopen_debug},
-#if defined(LUA_COMPAT_BITLIB)
+#ifdef LUA_COMPAT_BDB
+  {LUA_BDB, luaopen_libluabdb},
+#endif
+#ifdef LUA_COMPAT_ZFS
+  {LUA_ZFS, luaopen_libluazfs},
+#endif
+#ifdef LUA_COMPAT_SYSTEM 
+  {LUA_SYSTEM, luaopen_libluasystem_os},
+#endif
+#ifdef LUA_COMPAT_NETGRAPH
+  {LUA_NETGRAPH, luaopen_libluangctl},
+#endif
+#ifdef LUA_COMPAT_BCRYPT
+  {LUA_BCRYPT, luaopen_bcrypt},
+#endif
+#ifdef LUA_COMPAT_JSON
+  {LUA_JSON, luaopen_json},
+#endif
+#ifdef LUA_COMPAT_CJSON
+  {LUA_CJSON, luaopen_cjson},
+#endif
+#ifdef LUA_COMPAT_IFNET
+  {LUA_IFNET, luaopen_libluaknet},
+#endif
+#ifdef LUA_COMPAT_POSIX
+  {LUA_POSIX, luaopen_posix},
+#endif
+#ifdef LUA_COMPAT_POSIX_SHM
+  {LUA_POSIX, luaopen_libluaposix_shm},
+#endif
+#ifdef LUA_COMPAT_SOCKET
+  {LUA_SOCKET, luaopen_socket_core},
+  {LUA_SOCKET_UNIX, luaopen_socket_unix},
+#endif
+#ifdef LUA_COMPAT_ZLIB
+  {LUA_ZLIB, luaopen_zlib},
+#endif
+#ifdef LUA_COMPAT_EXPAT
+  {LUA_EXPAT, luaopen_lxp},
+#endif
+#ifdef LUA_COMPAT_SYSCTL
+  {LUA_SYSCTL, luaopen_sysctl},
+#endif 
+#ifdef LUA_COMPAT_BITLIB
   {LUA_BITLIBNAME, luaopen_bit32},
 #endif
+#ifdef LUA_COMPAT_CURL
+  {LUA_CURL, luaopen_lcurl},
+#endif
+#ifdef LUA_COMPAT_LFS
+  {LUA_LFS, luaopen_lfs},
+#endif
+#ifdef LUA_COMPAT_LLTHREADS
+  {LUA_LLTHREADS, luaopen_lanes_core},
+#endif
+#ifdef LUA_COMPAT_DIALOG
+  {LUA_DIALOG, luaopen_libluadialog},
+#endif
+#ifdef LUA_COMPAT_OPENSSL
+  {LUA_OPENSSL,  luaopen_openssl},
+#endif
+#ifdef LUA_COMPAT_XUPNPD
+  {LUA_XUPNPD, luaopen_luajson},
+  {LUA_XUPNPD, luaopen_luaxcore},
+  {LUA_XUPNPD, luaopen_luaxlib},
+#endif
   {NULL, NULL}
 };
 
