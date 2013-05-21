include (CMakeParseArguments)
include (./Internal/CTCheckBuildDirectorySanityOrDie)
include (./Internal/CTSanitiseBuildType)

function (CTInit)
  set (options
    ALLOW_EMPTY_BUILD_TYPE
    ALLOW_IN_SOURCE_BUILDS
    OSX_ALLOW_UNSAFE_ASSERTMACROS
  )

  cmake_parse_arguments(args "${options}" "" "" ${ARGV})

  if (NOT args_ALLOW_IN_SOURCE_BUILDS)
    CTCheckBuildDirectorySanityOrDie()
  endif ()

  if (NOT args_ALLOW_EMPTY_BUILD_TYPE)
    CTSanitiseBuildType()
    message(STATUS "Build type is: ${CMAKE_BUILD_TYPE}")
  endif ()

  if (NOT args_OSX_ALLOW_UNSAFE_ASSERTMACROS AND 
      CMAKE_SYSTEM_NAME STREQUAL Darwin)
  
    # OS X's AssertMacros.h is a real pain, and defines some macros that
    # conflict with some common third-party libraries unless you pass this
    # #define.
    add_definitions(-D__ASSERT_MACROS_DEFINE_VERSIONS_WITHOUT_UNDERSCORES=0)
  endif ()
endfunction ()
