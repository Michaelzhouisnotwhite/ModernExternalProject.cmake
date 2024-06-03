set(__setup_dir ${CMAKE_BINARY_DIR}/.deps_setup)

function(ModernFetchContent_Declare contentName)
    set(oneValueArgs GIT_REPOSITORY GIT_TAG)
    cmake_parse_arguments(PARSE_ARGV 1 ARG "" "${oneValueArgs}" "")

    if(NOT ARG_GIT_REPOSITORY)
        message(FATAL_ERROR "GIT_REPOSITORY is empty. It must be specified.")
    endif()

    find_package(Git QUIET)
    set(cmd "${GIT_EXECUTABLE}" "clone")

    if(ARG_GIT_TAG)
        list(APPEND cmd "-b" "${ARG_GIT_TAG}")
    endif()

    set(${contentName}_SOURCE_DIR ${__setup_dir}/${contentName}-src PARENT_SCOPE)
    set(${contentName}_SOURCE_DIR ${__setup_dir}/${contentName}-src)
    list(APPEND cmd "${ARG_GIT_REPOSITORY}" "${${contentName}_SOURCE_DIR}")
    execute_process(COMMAND ${cmd} RESULT_VARIABLE result)

    if(result)
        message(WARNING "git failed: ${result}")
    endif()
endfunction()

function(FetchContent_Enable)
    foreach(__cmake_content_name IN ITEMS ${ARGV})
        FetchContent_GetProperties(${__cmake_content_name})
        set(${__cmake_content_name}_NEED_ADD FALSE PARENT_SCOPE)

        # message(FATAL_ERROR "${${__cmake_content_name}_POPULATED}")
        if(NOT ${__cmake_content_name}_POPULATED)
            FetchContent_Populate(${__cmake_content_name})
            set(${__cmake_content_name}_SOURCE_DIR ${${__cmake_content_name}_SOURCE_DIR} PARENT_SCOPE)
            set(${__cmake_content_name}_NEED_ADD TRUE PARENT_SCOPE)
        endif()

        message("${__cmake_content_name}_SOURCE_DIR ${${__cmake_content_name}_SOURCE_DIR}")
    endforeach()
endfunction(FetchContent_Enable)

function(ModernExternalProject_Add contentName)
    message(STATUS "Setting up ${contentName} ...")
    cmake_host_system_information(RESULT cores QUERY NUMBER_OF_LOGICAL_CORES)
    set(oneValueArgs SOURCE_DIR GENERATOR INSTALL_DIR BUILD_TYPE CMAKE_STEP VERBOSE)
    set(multiValueArgs CMAKE_CACHE)
    make_directory(${__setup_dir})
    cmake_parse_arguments(PARSE_ARGV 1 ARG "" "${oneValueArgs}" "${multiValueArgs}")

    if(NOT ARG_CMAKE_STEP)
        set(ARG_CMAKE_STEP install)
    endif()

    if(install IN_LIST ARG_CMAKE_STEP)
        set(_install_step TRUE)
    endif()

    if(NOT ARG_BUILD_TYPE)
        if(NOT CMAKE_BUILD_TYPE)
            set(ARG_BUILD_TYPE Release)
        else()
            set(ARG_BUILD_TYPE ${CMAKE_BUILD_TYPE})
        endif()
    endif()

    if(NOT ARG_SOURCE_DIR)
        message(FATAL_ERROR "${contentName}_SOURCE_DIR is empty. It must be specified.")
    endif()

    if(NOT ARG_GENERATOR)
        set(ARG_GENERATOR "${CMAKE_GENERATOR}")
    endif()

    if(NOT ARG_INSTALL_DIR)
        set(ARG_INSTALL_DIR "${__setup_dir}/${contentName}_install")
    endif()

    set(${contentName}_BINARY_DIR "${__setup_dir}/${contentName}_build")
    set(${contentName}_BINARY_DIR "${__setup_dir}/${contentName}_build" PARENT_SCOPE)
    make_directory(${${contentName}_BINARY_DIR})
    set(${contentName}_INSTALL_DIR "${ARG_INSTALL_DIR}")
    set(${contentName}_INSTALL_DIR "${ARG_INSTALL_DIR}" PARENT_SCOPE)
    set(cmd ${CMAKE_COMMAND})
    list(APPEND cmd "-B${${contentName}_BINARY_DIR}" "-S${ARG_SOURCE_DIR}" "-DCMAKE_INSTALL_PREFIX:PATH=${ARG_INSTALL_DIR}")
    list(APPEND cmd "-DCMAKE_CXX_COMPILER=${CMAKE_CXX_COMPILER}")
    list(APPEND cmd "-DCMAKE_C_COMPILER=${CMAKE_C_COMPILER}")
    list(APPEND cmd "-DCMAKE_BUILD_TYPE=${ARG_BUILD_TYPE}")
    list(APPEND cmd "-DCMAKE_MAKE_PROGRAM=${CMAKE_MAKE_PROGRAM}")
    list(APPEND cmd "-DCMAKE_PREFIX_PATH:PATH=${CMAKE_PREFIX_PATH}")

    foreach(arg ${ARG_CMAKE_CACHE})
        list(APPEND cmd "-D${arg}")
    endforeach()

    list(APPEND cmd "-G${ARG_GENERATOR}")

    set(config_cmd ${cmd})
    set(build_cmd ${CMAKE_COMMAND} --build ${${contentName}_BINARY_DIR} -j${cores})
    set(install_cmd ${CMAKE_COMMAND} --install ${${contentName}_BINARY_DIR})

    if(${contentName}_INSTALLED)
        set(cmd ${CMAKE_COMMAND} --build ${${contentName}_BINARY_DIR} -t clean)
        add_custom_target(${contentName}_clean
            COMMAND ${cmd}
        )

        add_custom_target(${contentName}_configure
            COMMAND ${config_cmd}
        )
        add_custom_target(${contentName}_install
            COMMAND ${install_cmd}
        )

        add_custom_target(${contentName}_build
            COMMAND ${build_cmd}
        )

        list(APPEND _PREFIX_PATH "${ARG_INSTALL_DIR}")
        set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}" "${_PREFIX_PATH}" PARENT_SCOPE)
        return()
    endif()

    if(configure IN_LIST ARG_VERBOSE)
        execute_process(
            COMMAND ${config_cmd}

            # OUTPUT_VARIABLE output
            # ECHO_OUTPUT_VARIABLE
            WORKING_DIRECTORY ${ARG_SOURCE_DIR}
            RESULT_VARIABLE result
        )
    else()
        execute_process(
            COMMAND ${config_cmd}
            OUTPUT_VARIABLE output
            WORKING_DIRECTORY ${ARG_SOURCE_DIR}
            RESULT_VARIABLE result
        )
    endif()

    if(result)
        message(FATAL_ERROR "configure ${contentName} failed")
        message(${output})
    endif()

    execute_process(COMMAND ${build_cmd} RESULT_VARIABLE result)

    if(result)
        message(FATAL_ERROR "build ${contentName} failed")
        message(${output})
    endif()

    execute_process(COMMAND ${install_cmd} RESULT_VARIABLE result)

    if(result)
        message(FATAL_ERROR "install ${contentName} failed")
        message(${output})
    endif()

    message(STATUS "Setting up ${contentName} completed")
    set(${contentName}_INSTALLED TRUE CACHE BOOL "" FORCE)

    list(APPEND _PREFIX_PATH "${ARG_INSTALL_DIR}")
    set(CMAKE_PREFIX_PATH "${CMAKE_PREFIX_PATH}" "${_PREFIX_PATH}" PARENT_SCOPE)
endfunction()
