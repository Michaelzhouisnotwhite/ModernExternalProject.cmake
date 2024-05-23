cmake_minimum_required(VERSION 3.22)
project(CXX_Playground)
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
include(FetchContent)

# function(fetch_content_check content_name)
# FetchContent_MakeAvailable(${content_name})
# message("---- ${content_name}_SOURCE_DIR is found in ${${content_name}_SOURCE_DIR}")
# endfunction()
# FetchContent_Declare(
# fmt
# GIT_REPOSITORY https://github.com/fmtlib/fmt
# GIT_TAG 10.0.0
# )
include(FetchContent)
FetchContent_Declare(fmt
    GIT_REPOSITORY https://github.com/fmtlib/fmt
    GIT_PROGRESS TRUE
    GIT_TAG 10.0.0
)

FetchContent_Declare(
    boost
    URL https://github.com/boostorg/boost/releases/download/boost-1.82.0/boost-1.82.0.tar.xz
    DOWNLOAD_EXTRACT_TIMESTAMP ON
    GIT_PROGRESS TRUE
    FETCHCONTENT_UPDATES_DISCONNECTED
)
include(../src/ModernExternalProject.cmake)

FetchContent_Enable(fmt boost)

ModernExternalProject_Add(fmt
    SOURCE_DIR ${fmt_SOURCE_DIR}
)

message("cmake pp: ${CMAKE_PREFIX_PATH} ${fmt_INSTALLED}") 
ModernExternalProject_Add(boost
    SOURCE_DIR ${boost_SOURCE_DIR}
    CMAKE_CACHE BOOST_ENABLE_PYTHON=OFF 
    VERBOSE configure
)

message("cmake pp: ${CMAKE_PREFIX_PATH} ${boost_INSTALLED}")
find_package(fmt REQUIRED)

add_executable(test_fmt test_fmt.cpp)
target_link_libraries(test_fmt PRIVATE fmt::fmt)

find_package(Boost REQUIRED COMPONENTS asio bind url beast)
add_executable(test_boost test_boost.cpp)
target_link_libraries(test_boost PRIVATE Boost::bind Boost::asio Boost::url Boost::beast fmt::fmt)

# FetchContent_Declare(
# Boost
# URL https://github.com/boostorg/boost/releases/download/boost-1.82.0/boost-1.82.0.tar.xz
# DOWNLOAD_EXTRACT_TIMESTAMP ON
# )

# FetchContent_Declare(
# toy
# GIT_REPOSITORY https://github.com/Michaelzhouisnotwhite/My-CXX-Small-Toys
# GIT_TAG main
# )
# FetchContent_Declare(cpr
# GIT_REPOSITORY
# https://github.com/libcpr/cpr.git
# GIT_TAG 1.10.4
# OVERRIDE_FIND_PACKAGE
# )

# FetchContent_Declare(
# clip
# GIT_REPOSITORY https://github.com/dacap/clip.git
# GIT_TAG main
# OVERRIDE_FIND_PACKAGE
# )
# set(CLIP_EXAMPLES OFF CACHE BOOL "Compile clip examples")
# set(CLIP_TESTS OFF CACHE BOOL "Compile clip tests")

# # Also requires one of: libbfd (gnu binutils), libdwarf, libdw (elfutils)
# FetchContent_Declare(backward
# GIT_REPOSITORY https://github.com/bombela/backward-cpp
# GIT_TAG master # or a version tag, such as v1.6
# SYSTEM # optional, the Backward include directory will be treated as system directory
# )
# FetchContent_MakeAvailable(backward)

# # Disable clip examples and tests
# set(BOOST_INCLUDE_LIBRARIES bind asio url beast)
# set(protobuf_BUILD_SHARED_LIBS ON)

# FetchContent_Declare(json URL https://github.com/nlohmann/json/releases/download/v3.11.3/json.tar.xz)
# FetchContent_MakeAvailable(json)

# fetch_content_check(Boost)
# fetch_content_check(fmt)
# fetch_content_check(toy)

# fetch_content_check(clip)

# fetch_content_check(Eigen)
