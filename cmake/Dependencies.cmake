include(FetchContent)

# nlohmann_json
FetchContent_Declare(
    nlohmann_json
    GIT_REPOSITORY https://github.com/nlohmann/json.git
    GIT_TAG v3.11.3
    GIT_SHALLOW TRUE
)

# spdlog
FetchContent_Declare(
    spdlog
    GIT_REPOSITORY https://github.com/gabime/spdlog.git
    GIT_TAG v1.12.0
    GIT_SHALLOW TRUE
)

# cpp-httplib
FetchContent_Declare(
    httplib
    GIT_REPOSITORY https://github.com/yhirose/cpp-httplib.git
    GIT_TAG v0.14.3
    GIT_SHALLOW TRUE
)

# GoogleTest
if(VECTORVAULT_BUILD_TESTS)
    FetchContent_Declare(
        googletest
        GIT_REPOSITORY https://github.com/google/googletest.git
        GIT_TAG v1.14.0
        GIT_SHALLOW TRUE
    )
    set(gtest_force_shared_crt ON CACHE BOOL "" FORCE)
endif()

# Make dependencies available
FetchContent_MakeAvailable(nlohmann_json spdlog httplib)

if(VECTORVAULT_BUILD_TESTS)
    FetchContent_MakeAvailable(googletest)
endif()

# Consume fetched dependencies through system include paths.
#
# We build our own targets with -Wall -Wextra -Werror, and those flags also
# apply to third-party headers pulled in by our translation units. A warning
# we cannot fix then breaks the build: GCC 13 added -Wdangling-reference,
# which fires inside spdlog's bundled fmt (fmt/bundled/core.h). Compilers do
# not report warnings from system headers, so marking these include paths
# SYSTEM keeps our own code fully strict while third-party headers stay quiet.
#
# FetchContent_Declare(... SYSTEM) does the same thing, but requires CMake
# 3.25 and we support 3.22, so promote the properties directly.
foreach(dep IN ITEMS
    nlohmann_json
    spdlog
    spdlog_header_only
    httplib
    gtest
    gtest_main
    gmock
    gmock_main
)
    if(TARGET ${dep})
        get_target_property(dep_include_dirs ${dep} INTERFACE_INCLUDE_DIRECTORIES)
        if(dep_include_dirs)
            set_target_properties(${dep} PROPERTIES
                INTERFACE_SYSTEM_INCLUDE_DIRECTORIES "${dep_include_dirs}"
            )
        endif()
    endif()
endforeach()
