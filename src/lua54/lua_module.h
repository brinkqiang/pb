
#ifndef __LUA_MODULE_H_INCLUDE__
#define __LUA_MODULE_H_INCLUDE__

#if defined(LUA_COMPAT_MODULE)
static const char* luaL_findtable(lua_State* L, int idx, const char* fname,
                                  int szhint);

static int libsize(const luaL_Reg* l);

LUALIB_API void luaL_pushmodule(lua_State* L, const char* modname,
                                int sizehint);
#endif

#endif // __LUA_MODULE_H_INCLUDE__
