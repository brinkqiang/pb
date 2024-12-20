
// Copyright (c) 2018 brinkqiang (brink.qiang@gmail.com)
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in all
// copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
// SOFTWARE.

#include "pb_module.h"
#include "pb.h"

#if LUA_VERSION_NUM == 501
LUALIB_API void luaL_requiref(lua_State *L, const char *modname,
                              lua_CFunction openf, int glb) {
    lua_pushcfunction(L, openf);        // 将模块的打开函数压入栈
    lua_pushstring(L, modname);        // 将模块名压入栈
    lua_call(L, 1, 1);                 // 调用打开函数，返回模块表

    if (glb) {                         // 只有当 glb 为真时才设置为全局变量
        lua_pushvalue(L, -1);          // 将模块表复制到栈顶
        lua_setglobal(L, modname);     // 设置为全局变量
    }
}
#endif
LUALIB_API int require_pb(lua_State* L)
{
    luaL_requiref(L, "pb", luaopen_pb, 0);

    printf("lua module: require pb\n");
    return 1;
}