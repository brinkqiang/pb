
MACRO(SUBDIRLIST result curdir)
    FILE(GLOB children RELATIVE ${curdir} ${curdir}/*)
    SET(dirlist "")
    FOREACH(child ${children})
    IF(IS_DIRECTORY ${curdir}/${child})
        LIST(APPEND dirlist ${child})
    ENDIF()
    ENDFOREACH()
    SET(${result} ${dirlist})
ENDMACRO()

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

    LINK_DIRECTORIES(${CMAKE_SOURCE_DIR}/bin)
    SET(EXECUTABLE_OUTPUT_PATH ${CMAKE_SOURCE_DIR}/bin)
    SET(LIBRARY_OUTPUT_PATH ${CMAKE_SOURCE_DIR}/bin)

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

    LINK_DIRECTORIES(${CMAKE_SOURCE_DIR}/bin)
    SET(EXECUTABLE_OUTPUT_PATH ${CMAKE_SOURCE_DIR}/bin)
    SET(LIBRARY_OUTPUT_PATH ${CMAKE_SOURCE_DIR}/bin)

    IF (IS_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/thirdparty)
        SUBDIRLIST(SUBDIRS ${CMAKE_CURRENT_SOURCE_DIR}/${ModulePath}/thirdparty)
        FOREACH(subdir ${SUBDIRS})
            ModuleInclude2(${ModuleName} ${ModulePath}/thirdparty/${subdir})
        ENDFOREACH()
    ENDIF()

    ModuleInclude2(${ModuleName} ${ModulePath})
endmacro(ModuleImport2)