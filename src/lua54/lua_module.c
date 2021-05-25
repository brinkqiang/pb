
#define luamodule_c
#define LUA_LIB

#include "lprefix.h"


#include <errno.h>
#include <stdarg.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>


/*
** This file uses only the official API of Lua.
** Any function declared here could be written as an application function.
*/

#include "lua.h"

#include "lauxlib.h"

#if defined(LUA_COMPAT_5_1) /* { */

/* Incompatibilities from 5.2 -> 5.3 */
#define LUA_COMPAT_MATHLIB
#define LUA_COMPAT_APIINTCASTS

/*
@@ LUA_COMPAT_UNPACK controls the presence of global 'unpack'.
** You can replace it with 'table.unpack'.
*/
#define LUA_COMPAT_UNPACK

/*
@@ LUA_COMPAT_LOADERS controls the presence of table 'package.loaders'.
** You can replace it with 'package.searchers'.
*/
#define LUA_COMPAT_LOADERS

/*
@@ macro 'lua_cpcall' emulates deprecated function lua_cpcall.
** You can call your C function directly (with light C functions).
*/
#define lua_cpcall(L,f,u)  \
    (lua_pushcfunction(L, (f)), \
     lua_pushlightuserdata(L,(u)), \
     lua_pcall(L,1,0,0))


/*
@@ LUA_COMPAT_LOG10 defines the function 'log10' in the math library.
** You can rewrite 'log10(x)' as 'log(x, 10)'.
*/
#define LUA_COMPAT_LOG10

/*
@@ LUA_COMPAT_LOADSTRING defines the function 'loadstring' in the base
** library. You can rewrite 'loadstring(s)' as 'load(s)'.
*/
#define LUA_COMPAT_LOADSTRING

/*
@@ LUA_COMPAT_MAXN defines the function 'maxn' in the table library.
*/
#define LUA_COMPAT_MAXN

/*
@@ The following macros supply trivial compatibility for some
** changes in the API. The macros themselves document how to
** change your code to avoid using them.
*/
#define lua_strlen(L,i)     lua_rawlen(L, (i))

#define lua_objlen(L,i)     lua_rawlen(L, (i))

#define lua_equal(L,idx1,idx2)      lua_compare(L,(idx1),(idx2),LUA_OPEQ)
#define lua_lessthan(L,idx1,idx2)   lua_compare(L,(idx1),(idx2),LUA_OPLT)

/*
@@ LUA_COMPAT_MODULE controls compatibility with previous
** module functions 'module' (Lua) and 'luaL_register' (C).
*/
#define LUA_COMPAT_MODULE

#endif              /* } */


/*
** {======================================================
** Compatibility with 5.1 module functions
** =======================================================
*/
#if defined(LUA_COMPAT_MODULE)

static const char* luaL_findtable( lua_State* L, int idx,
                                   const char* fname, int szhint ) {
    const char* e;

    if ( idx ) {
        lua_pushvalue( L, idx );
    }

    do {
        e = strchr( fname, '.' );

        if ( e == NULL ) {
            e = fname + strlen( fname );
        }

        lua_pushlstring( L, fname, e - fname );

        if ( lua_rawget( L, -2 ) == LUA_TNIL ) { /* no such field? */
            lua_pop( L, 1 ); /* remove this nil */
            lua_createtable( L, 0, ( *e == '.' ? 1 : szhint ) ); /* new table for field */
            lua_pushlstring( L, fname, e - fname );
            lua_pushvalue( L, -2 );
            lua_settable( L, -4 ); /* set new table into field */
        }
        else if ( !lua_istable( L, -1 ) ) {   /* field has a non-table value? */
            lua_pop( L, 2 ); /* remove table and value */
            return fname;  /* return problematic part of the name */
        }

        lua_remove( L, -2 ); /* remove previous table */
        fname = e + 1;
    }
    while ( *e == '.' );

    return NULL;
}


/*
** Count number of elements in a luaL_Reg list.
*/
static int libsize( const luaL_Reg* l ) {
    int size = 0;

    for ( ; l && l->name; l++ ) {
        size++;
    }

    return size;
}


/*
** Find or create a module table with a given name. The function
** first looks at the LOADED table and, if that fails, try a
** global variable with that name. In any case, leaves on the stack
** the module table.
*/
LUALIB_API void luaL_pushmodule( lua_State* L, const char* modname,
                                 int sizehint ) {
    luaL_findtable( L, LUA_REGISTRYINDEX, LUA_LOADED_TABLE, 1 );

    if ( lua_getfield( L, -1, modname ) != LUA_TTABLE ) { /* no LOADED[modname]? */
        lua_pop( L, 1 ); /* remove previous result */
        /* try global variable (and create one if it does not exist) */
        lua_pushglobaltable( L );

        if ( luaL_findtable( L, 0, modname, sizehint ) != NULL ) {
            luaL_error( L, "name conflict for module '%s'", modname );
        }

        lua_pushvalue( L, -1 );
        lua_setfield( L, -3, modname ); /* LOADED[modname] = new table */
    }

    lua_remove( L, -2 ); /* remove LOADED table */
}


LUALIB_API void luaL_openlib( lua_State* L, const char* libname,
                              const luaL_Reg* l, int nup ) {
    luaL_checkversion( L );

    if ( libname ) {
        luaL_pushmodule( L, libname, libsize( l ) ); /* get/create library table */
        lua_insert( L, -( nup + 1 ) ); /* move library table to below upvalues */
    }

    if ( l ) {
        luaL_setfuncs( L, l, nup );
    }
    else {
        lua_pop( L, nup );    /* remove upvalues */
    }
}

#endif

