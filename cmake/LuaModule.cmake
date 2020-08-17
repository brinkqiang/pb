
# Copyright (c) 2018 brinkqiang (brink.qiang@gmail.com)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

macro(LUA_SUBDIRLIST result curdir)
    FILE(GLOB children RELATIVE ${curdir} ${curdir}/*)
    SET(dirlist "")
    FOREACH(child ${children})
        IF(IS_DIRECTORY ${curdir}/${child})
            LIST(APPEND dirlist ${child})
        ENDIF()
    ENDFOREACH()
    SET(${result} ${dirlist})
endmacro()

macro(LuaModuleImport LuaVersion ModuleName ModulePath DependLibs)
    MESSAGE(STATUS "LuaModuleImport ${LuaVersion} ${ModuleName} ${ModulePath}")

    GET_PROPERTY(DMLIBS GLOBAL PROPERTY DMLIBS)

    LIST(FIND DMLIBS ${ModuleName} DMLIBS_FOUND)
    IF (NOT (DMLIBS_FOUND STREQUAL "-1"))
        MESSAGE(STATUS "LuaModuleImport repeat ModuleName:${ModuleName}" )
        RETURN()
    ENDIF()
    
    LINK_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/lib/${ModuleName})

    LIST(FIND DMLIBS ${LuaVersion} DMLIBS_FOUND)
    IF (DMLIBS_FOUND STREQUAL "-1")
        FILE(GLOB DMLUA_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/src/${LuaVersion}/*.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/src/${LuaVersion}/*.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/src/${LuaVersion}/*.c
        ${CMAKE_CURRENT_SOURCE_DIR}/src/${LuaVersion}/*.hpp
        ${CMAKE_CURRENT_SOURCE_DIR}/src/${LuaVersion}/*.h
        )

        LIST(FILTER DMLUA_SOURCES EXCLUDE REGEX "lua.c$")
        LIST(FILTER DMLUA_SOURCES EXCLUDE REGEX "luac.c$")
        LIST(FILTER DMLUA_SOURCES EXCLUDE REGEX "wmain.c$")

        FILE(GLOB LUA_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/src/${LuaVersion}/lua.c
        )
        IF (WIN32)
            ADD_LIBRARY(${LuaVersion} SHARED ${DMLUA_SOURCES})
            SET_TARGET_PROPERTIES(${LuaVersion} PROPERTIES COMPILE_FLAGS "-DLUA_BUILD_AS_DLL -DLUA_CORE")
            
            ADD_EXECUTABLE(lua ${LUA_SOURCES})
            TARGET_LINK_LIBRARIES(lua ${LuaVersion})

        ELSEIF (APPLE)
            ADD_DEFINITIONS(-DLUA_USE_MACOSX)

            ADD_LIBRARY(${LuaVersion} SHARED ${DMLUA_SOURCES})
            SET_TARGET_PROPERTIES(${LuaVersion} PROPERTIES COMPILE_FLAGS "-Wl,-undefined -Wl,dynamic_lookup")
            SET_TARGET_PROPERTIES(${LuaVersion} PROPERTIES PREFIX "")
            SET_TARGET_PROPERTIES(${LuaVersion} PROPERTIES SUFFIX ".so")
            ADD_EXECUTABLE(lua ${LUA_SOURCES})
            TARGET_LINK_LIBRARIES(lua ${LuaVersion} dl)
        ELSEIF (UNIX)
            ADD_DEFINITIONS(-DLUA_USE_LINUX)

            ADD_LIBRARY(${LuaVersion} SHARED ${DMLUA_SOURCES})
            SET_TARGET_PROPERTIES(${LuaVersion} PROPERTIES COMPILE_FLAGS "-Wl,-E" )
            ADD_EXECUTABLE(lua ${LUA_SOURCES})
            TARGET_LINK_LIBRARIES(lua ${LuaVersion} m dl)
        ENDIF ()
    ENDIF()


    LIST(APPEND DMLIBS ${ModuleName})
    SET_PROPERTY(GLOBAL PROPERTY DMLIBS ${DMLIBS})
    MESSAGE(STATUS "LIST APPEND ${ModuleName} ${DMLIBS}" )

    INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/)
    INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/include)
    INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/src)
    INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/src/${LuaVersion})
    INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath})
    INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/test)

    FILE(GLOB LUAMODULE_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/include/*.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/include/*.h

    ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/*.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/*.cc
    ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/*.c
    ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/*.hpp
    ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/*.h
    )

    IF (WIN32)
        ADD_LIBRARY(${ModuleName} SHARED ${LUAMODULE_SOURCES} ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/${ModuleName}_module.def)
        TARGET_LINK_LIBRARIES(${ModuleName} ${LUA_MODULE} ${DependLibs})

        SET_TARGET_PROPERTIES(${ModuleName} PROPERTIES COMPILE_FLAGS "-DLUA_BUILD_AS_DLL -DLUA_LIB")

        LUA_SUBDIRLIST(SUBDIRS ${CMAKE_CURRENT_SOURCE_DIR}/test)
        FOREACH(subdir ${SUBDIRS})
            FILE(GLOB_RECURSE DMMODULETEST_SOURCES
            ${CMAKE_CURRENT_SOURCE_DIR}/test/${subdir}/*.cpp
            ${CMAKE_CURRENT_SOURCE_DIR}/test/${subdir}/*.cc
            ${CMAKE_CURRENT_SOURCE_DIR}/test/${subdir}/*.c
            ${CMAKE_CURRENT_SOURCE_DIR}/test/${subdir}/*.hpp
            ${CMAKE_CURRENT_SOURCE_DIR}/test/${subdir}/*.h)

            ADD_EXECUTABLE(${subdir} ${DMMODULETEST_SOURCES})
            TARGET_LINK_LIBRARIES(${subdir} ${ModuleName} ${DependLibs})
            SET_TARGET_PROPERTIES(${subdir} PROPERTIES COMPILE_FLAGS "-DLUA_BUILD_AS_DLL")
        ENDFOREACH()

    ELSEIF (APPLE)
        ADD_DEFINITIONS(-DLUA_USE_MACOSX)

        ADD_LIBRARY(${ModuleName} SHARED ${LUAMODULE_SOURCES})
        SET_TARGET_PROPERTIES(${ModuleName} PROPERTIES COMPILE_FLAGS "-Wl,-undefined -Wl,dynamic_lookup" )
        SET_TARGET_PROPERTIES(${ModuleName} PROPERTIES PREFIX "")
        SET_TARGET_PROPERTIES(${ModuleName} PROPERTIES SUFFIX ".so")
        TARGET_LINK_LIBRARIES(${ModuleName} ${LUA_MODULE} ${DependLibs})

        LUA_SUBDIRLIST(SUBDIRS ${CMAKE_CURRENT_SOURCE_DIR}/test)
        FOREACH(subdir ${SUBDIRS})
            FILE(GLOB_RECURSE DMMODULETEST_SOURCES
            ${CMAKE_CURRENT_SOURCE_DIR}/test/${subdir}/*.cpp
            ${CMAKE_CURRENT_SOURCE_DIR}/test/${subdir}/*.cc
            ${CMAKE_CURRENT_SOURCE_DIR}/test/${subdir}/*.c
            ${CMAKE_CURRENT_SOURCE_DIR}/test/${subdir}/*.hpp
            ${CMAKE_CURRENT_SOURCE_DIR}/test/${subdir}/*.h)

            ADD_EXECUTABLE(${subdir} ${DMMODULETEST_SOURCES})
            TARGET_LINK_LIBRARIES(${subdir} ${ModuleName} ${DependLibs})
        ENDFOREACH()
    ELSEIF (UNIX)
        ADD_DEFINITIONS(-DLUA_USE_LINUX)

        ADD_LIBRARY(${ModuleName} SHARED ${LUAMODULE_SOURCES})
        SET_TARGET_PROPERTIES(${ModuleName} PROPERTIES COMPILE_FLAGS "-Wl,-E" )
        SET_TARGET_PROPERTIES(${ModuleName} PROPERTIES PREFIX "")
        TARGET_LINK_LIBRARIES(${ModuleName} ${LUA_MODULE} ${DependLibs})
  
        LUA_SUBDIRLIST(SUBDIRS ${CMAKE_CURRENT_SOURCE_DIR}/test)
        FOREACH(subdir ${SUBDIRS})
            FILE(GLOB_RECURSE DMMODULETEST_SOURCES
            ${CMAKE_CURRENT_SOURCE_DIR}/test/${subdir}/*.cpp
            ${CMAKE_CURRENT_SOURCE_DIR}/test/${subdir}/*.cc
            ${CMAKE_CURRENT_SOURCE_DIR}/test/${subdir}/*.c
            ${CMAKE_CURRENT_SOURCE_DIR}/test/${subdir}/*.hpp
            ${CMAKE_CURRENT_SOURCE_DIR}/test/${subdir}/*.h)

            ADD_EXECUTABLE(${subdir} ${DMMODULETEST_SOURCES})
            TARGET_LINK_LIBRARIES(${subdir} ${ModuleName} ${DependLibs})
        ENDFOREACH()
    ENDIF ()
endmacro(LuaModuleImport)
