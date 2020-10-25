--- src/lua.c.orig	2017-04-19 23:29:57.000000000 +0600
+++ src/lua.c	2020-01-06 02:46:07.183136000 +0600
@@ -77,16 +77,66 @@
 */
 #if !defined(lua_readline)	/* { */
 
-#if defined(LUA_USE_READLINE)	/* { */
+#if defined(LUA_USE_READLINE_DL)/* { */
+
+#include <dlfcn.h>
+
+#ifndef LUA_READLINE_LIBPATH
+#define LUA_READLINE_LIBPATH "/usr/local/lib/libedit.so"
+#endif
+
+typedef char *readline_functype(const char *);
+typedef int add_history_functype(const char *);
+
+static readline_functype *lua_readline_p = NULL;
+static add_history_functype *lua_saveline_p = NULL;
+
+static void lua_initreadline(lua_State *L)
+{
+  void *editlib = NULL;
+  union dl_func_hack {
+    void *ptr;
+    readline_functype *rlfunc;
+    add_history_functype *ahfunc;
+    char **rlnamevar;
+    int *icompvar;
+  } u;
+  (void) L;
+  if ((editlib = dlopen(LUA_READLINE_LIBPATH, RTLD_LAZY | RTLD_LOCAL))) {
+    u.ptr = dlsym(editlib, "readline");
+    lua_readline_p = u.rlfunc;
+    u.ptr = dlsym(editlib, "add_history");
+    lua_saveline_p = u.ahfunc;
+    if ((u.ptr = dlsym(editlib, "rl_readline_name")))
+      *u.rlnamevar = "lua";
+    if ((u.ptr = dlsym(editlib, "rl_inhibit_completion")))
+      *u.icompvar = 1;
+  }
+}
+
+#define lua_readline(L,b,p) \
+  ((void)L,                                                          \
+   (lua_readline_p)                                                  \
+   ? (((b)=lua_readline_p(p)) != NULL)                               \
+   : (fputs(p, stdout), fflush(stdout), fgets(b, LUA_MAXINPUT, stdin) != NULL))
+#define lua_saveline(L,line)	\
+  do { (void)L; if (lua_saveline_p) lua_saveline_p(line); } while(0)
+#define lua_freeline(L,b)	\
+  do { (void)L; if (lua_readline_p) free(b); } while(0)
+
+#elif defined(LUA_USE_READLINE)	/* { */
 
 #include <readline/readline.h>
 #include <readline/history.h>
+#define lua_initreadline(L)  \
+	((void)L, rl_readline_name="lua", rl_inhibit_completion=1)
 #define lua_readline(L,b,p)	((void)L, ((b)=readline(p)) != NULL)
 #define lua_saveline(L,line)	((void)L, add_history(line))
 #define lua_freeline(L,b)	((void)L, free(b))
 
 #else				/* }{ */
 
+#define lua_initreadline(L)	((void) L)
 #define lua_readline(L,b,p) \
         ((void)L, fputs(p, stdout), fflush(stdout),  /* show prompt */ \
         fgets(b, LUA_MAXINPUT, stdin) != NULL)  /* get line */
@@ -122,7 +172,7 @@
 ** interpreter.
 */
 static void laction (int i) {
-  signal(i, SIG_DFL); /* if another SIGINT happens, terminate process */
+  signal(i, SIG_IGN); /* if another SIGINT happens, terminate process */
   lua_sethook(globalL, lstop, LUA_MASKCALL | LUA_MASKRET | LUA_MASKCOUNT, 1);
 }
 
@@ -203,7 +253,7 @@
   globalL = L;  /* to be available to 'laction' */
   signal(SIGINT, laction);  /* set C-signal handler */
   status = lua_pcall(L, narg, nres, base);
-  signal(SIGINT, SIG_DFL); /* reset C-signal handler */
+  signal(SIGINT, SIG_IGN); /* reset C-signal handler */
   lua_remove(L, base);  /* remove message handler from the stack */
   return status;
 }
@@ -406,6 +456,7 @@
   int status;
   const char *oldprogname = progname;
   progname = NULL;  /* no 'progname' on errors in interactive mode */
+  lua_initreadline(L);
   while ((status = loadline(L)) != -1) {
     if (status == LUA_OK)
       status = docall(L, 0, LUA_MULTRET);
@@ -595,6 +646,7 @@
 
 int main (int argc, char **argv) {
   int status, result;
+  signal(SIGINT, SIG_IGN);
   lua_State *L = luaL_newstate();  /* create state */
   if (L == NULL) {
     l_message(argv[0], "cannot create state: not enough memory");
