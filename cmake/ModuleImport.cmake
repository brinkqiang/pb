
macro(SUBDIRLIST result curdir)
    FILE(GLOB children RELATIVE ${curdir} ${curdir}/*)
    SET(dirlist "")
    FOREACH(child ${children})
        IF(IS_DIRECTORY ${curdir}/${child})
            LIST(APPEND dirlist ${child})
        ENDIF()
    ENDFOREACH()
    SET(${result} ${dirlist})
endmacro()

macro(ModuleInclude ModuleName ModulePath)
    MESSAGE(STATUS "ModuleInclude ${ModuleName} ${ModulePath}")

    IF (WIN32)
        INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/src/windows)
        INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/src/${ModuleName}/windows)
    ENDIF(WIN32)

    INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath})
    INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/src)
    INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/src/${ModuleName})

    INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/include)
    INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/include/${ModuleName})

    INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/test)
    INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/test/${ModuleName})

endmacro(ModuleInclude)

macro(ModuleImport ModuleName ModulePath)
    MESSAGE(STATUS "ModuleImport ${ModuleName} ${ModulePath}")

    IF (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/CMakeLists.txt)
        ADD_SUBDIRECTORY(${ModulePath})
    ELSEIF(EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/cmake/CMakeLists.txt)
        ADD_SUBDIRECTORY(${ModulePath}/cmake)
    ELSE()
        MESSAGE(FATAL_ERROR "ModuleImport ${ModuleName} CMakeLists.txt not exist.")
    ENDIF()

    IF (IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/thirdparty)
        SUBDIRLIST(SUBDIRS ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/thirdparty)
        FOREACH(subdir ${SUBDIRS})
            ModuleInclude(${ModuleName} ${ModulePath}/thirdparty/${subdir})
        ENDFOREACH()
    ENDIF()

    ModuleInclude(${ModuleName} ${ModulePath})
endmacro(ModuleImport)

macro(ExeImport ModulePath DependsLib)
    MESSAGE(STATUS "ExeImport ${ModulePath} ${DependsLib}")

    IF (IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath})
        SUBDIRLIST(SUBDIRS ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath})
        FOREACH(subdir ${SUBDIRS})
            MESSAGE(STATUS "INCLUDE -> ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/${subdir}")
            INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/${subdir})
            FILE(GLOB_RECURSE BIN_SOURCES
            ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/${subdir}/*.cpp
            ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/${subdir}/*.cc
            ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/${subdir}/*.c
            ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/${subdir}/*.hpp
            ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/${subdir}/*.h)

            LIST(FILTER BIN_SOURCES EXCLUDE REGEX "${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/${subdir}/tpl/*")

            MESSAGE(STATUS "BIN_SOURCES ${LIB_SOURCES}")

            ADD_EXECUTABLE(${subdir} ${BIN_SOURCES})
            TARGET_LINK_LIBRARIES(${subdir} ${DependsLib})
        ENDFOREACH()
    ENDIF()

endmacro(ExeImport)

macro(LibImport ModuleName ModulePath)
    MESSAGE(STATUS "LibImport ${ModuleName} ${ModulePath}")

    IF (IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath})
        ModuleInclude(${ModuleName} ${ModulePath})
        FILE(GLOB_RECURSE LIB_SOURCES
        ${CMAKE_CURRENT_SOURCE_DIR}/include/*.hpp
        ${CMAKE_CURRENT_SOURCE_DIR}/include/*.h

        ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/*.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/*.cc
        ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/*.c
        ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/*.hpp
        ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/*.h
        )

        LIST(FILTER LIB_SOURCES EXCLUDE REGEX "${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/tpl/*")

        IF (WIN32)
            LIST(APPEND LIB_SOURCES)
        ENDIF(WIN32)

        ADD_LIBRARY(${ModuleName} ${LIB_SOURCES})
    ENDIF()
endmacro(LibImport)

macro(ModuleInclude2 ModuleName ModulePath)
    MESSAGE(STATUS "ModuleInclude2 ${ModuleName} ${ModulePath}")

    IF (WIN32)
        INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/include/${ModuleName})
        INCLUDE_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/include)

        LINK_DIRECTORIES(${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/lib)
    ELSE(WIN32)
        IF (EXISTS ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/cmake/Find${ModuleName}.cmake)
            INCLUDE(${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/cmake/Find${ModuleName}.cmake)
            INCLUDE_DIRECTORIES(${${ModuleName}_INCLUDE_DIRS})
        ELSE()
            MESSAGE(FATAL_ERROR "ModuleImport2 ${ModuleName} Find${ModuleName}.cmake not exist.")
        ENDIF()
    ENDIF(WIN32)

endmacro(ModuleInclude2)

macro(ModuleImport2 ModuleName ModulePath)
    MESSAGE(STATUS "ModuleImport2 ${ModuleName} ${ModulePath}")

    IF (IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/thirdparty)
        SUBDIRLIST(SUBDIRS ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/thirdparty)
        FOREACH(subdir ${SUBDIRS})
            ModuleInclude2(${ModuleName} ${ModulePath}/thirdparty/${subdir})
        ENDFOREACH()
    ENDIF()

    ModuleInclude2(${ModuleName} ${ModulePath})
endmacro(ModuleImport2)