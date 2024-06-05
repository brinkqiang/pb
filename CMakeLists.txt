cmake_minimum_required(VERSION 3.8)

PROJECT(pb)

LIST(APPEND CMAKE_MODULE_PATH ${CMAKE_CURRENT_SOURCE_DIR}/cmake)
INCLUDE(cmake/ModuleImport.cmake)
INCLUDE(cmake/ModuleCompileOptions.cmake)
INCLUDE(cmake/LuaModule.cmake)
ModuleSetCompileOptions()
ModuleSetWinCompilerFlags()

SET(CMAKE_CXX_STANDARD 17)
SET(CMAKE_CXX_STANDARD_REQUIRED ON)

SET(LUA_MODULE lua54)

ADD_DEFINITIONS(-DLUA_COMPAT_MODULE -DLUA_COMPAT_APIINTCASTS)

LuaModuleImport("${LUA_MODULE}" "pb" "src/pb" "")
