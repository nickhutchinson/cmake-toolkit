include (CheckCXXCompilerFlag)
include (CMakeParseArguments)

function (CTEnableCXX11 scope)
  __CheckForCXX11()

  cmake_parse_arguments(args "DIRECTORY" "" "TARGETS" ${ARGV})

  if (scope STREQUAL "TARGETS")
    foreach (target IN LISTS args_TARGETS)
      __TargetEnableCXX11("${target}")
    endforeach ()

  elseif (scope STREQUAL "DIRECTORY")
    if (CMAKE_GENERATOR STREQUAL "Xcode" AND
        CMAKE_SOURCE_DIR STREQUAL "${CMAKE_CURRENT_SOURCE_DIR}")
      __EnableCXX11Globally_Xcode()
    else ()
      set(required_flags "")
      if (SUPPORTS_FLAG_STD_CXX11)
        set (required_flags "${required_flags} -std=c++11")
      elseif (SUPPORTS_FLAG_STD_CXX0X)
        set (required_flags "${required_flags} -std=c++0x")
      endif ()

      if (CMAKE_SYSTEM_NAME STREQUAL Darwin AND
          CMAKE_CXX_COMPILER_ID STREQUAL Clang)
        set (required_flags "${required_flags} -stdlib=libc++")
      endif ()
    endif ()

    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} ${required_flags}" PARENT_SCOPE)

  else ()
    message(FATAL_ERROR "Invalid scope ${scope}")
  endif ()
endfunction ()


function (__CheckForCXX11)
  check_cxx_compiler_flag("-std=c++11" SUPPORTS_FLAG_STD_CXX11)
  if (NOT SUPPORTS_FLAG_STD_CXX11)
    check_cxx_compiler_flag("-std=c++0x" SUPPORTS_FLAG_STD_CXX0X)
    if (NOT SUPPORTS_FLAG_STD_CXX0X)
      message(FATAL_ERROR "No C++11 support found")
    endif ()
  endif ()
endfunction ()

function (__TargetEnableCXX11 target)
  if (CMAKE_GENERATOR STREQUAL "Xcode")
    __TargetEnableCXX11_Xcode("${target}")
    return ()
  endif ()

  if (CMAKE_SYSTEM_NAME STREQUAL Darwin AND CMAKE_CXX_COMPILER_ID STREQUAL Clang)
    set_property(TARGET "${target}" APPEND_STRING PROPERTY COMPILE_FLAGS " -stdlib=libc++")
    target_link_libraries("${target}" -stdlib=libc++)
  endif ()
endfunction ()

function (__TargetEnableCXX11_Xcode target)
  set_property (TARGET "${target}" PROPERTY
      XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY "libc++")
  set_property (TARGET "${target}" PROPERTY
      XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++0x")
endfunction ()

function (__EnableCXX11Globally_Xcode)
  set (CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY "libc++" PARENT_SCOPE)
  set (CMAKE XCODE_ATTRIBUTE_CLANG_CXX_LANGUAGE_STANDARD "c++0x" PARENT_SCOPE)
endfunction ()
