
function (CTCheckBuildDirectorySanityOrDie)
  if ("${CMAKE_SOURCE_DIR}" MATCHES " " OR "${CMAKE_BINARY_DIR}" MATCHES " ")
    message(FATAL_ERROR
            "Your source or binary path contains whitespace, which Linux "
            "tools often mishandle. Aborting!\n"
            "Source path: ${CMAKE_SOURCE_DIR}\n"
            "Binary path: ${CMAKE_BINARY_DIR}")
  endif ()

  if ("${CMAKE_SOURCE_DIR}" STREQUAL "${CMAKE_BINARY_DIR}")
    message(FATAL_ERROR
            "We only allow out-of-source builds. Please build in some other "
            "directory.")
  endif ()
endfunction ()
