include (CheckCXXCompilerFlag)

# TODO: Xcode

function (CMUTargetEnableCXX11 target)
  check_cxx_compiler_flag("-std=c++11" SUPPORTS_FLAG_STD_CXX11)
  if (SUPPORTS_FLAG_STD_CXX11)
    set_property(TARGET "${target}" APPEND_STRING PROPERTY COMPILE_FLAGS " -std=c++11")
  else ()
    check_cxx_compiler_flag("-std=c++0x" SUPPORTS_FLAG_STD_CXX0X)
    if (SUPPORTS_FLAG_STD_CXX0X)
      set_property(TARGET "${target}" APPEND_STRING PROPERTY COMPILE_FLAGS " -std=c++0x")
    else ()
      message(FATAL_ERROR "No C++11 support found")
    endif ()
  endif ()

  if (CMAKE_SYSTEM_NAME STREQUAL Darwin AND CMAKE_CXX_COMPILER_ID STREQUAL Clang)
    set_property(TARGET "${target}" APPEND_STRING PROPERTY COMPILE_FLAGS " -stdlib=libc++")
    target_link_libraries("${target}" -stdlib=libc++)
  endif ()
endfunction ()
