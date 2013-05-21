include (CMakeParseArguments)

function (CTFindLibrary var)
  if (${var})
    return ()
  endif ()

  # find_library() takes either a single library as its second argument, 
  # or a named argument "NAMES" consisting of a list of libraries. We want to be
  # a drop-in replacement, so we should do the same.
  set (arg_list ${ARGN})
  if (NOT ARGV1 STREQUAL "NAMES")
    list (INSERT arg_list 0 "NAMES")
  endif ()

  cmake_parse_arguments(args "STATIC;SHARED;FRAMEWORK;REQUIRED" "" "NAMES" ${arg_list})
  
  if (args_FRAMEWORK)
    set (CMAKE_FIND_FRAMEWORK "ONLY")
  endif ()

  set (canonical_names "")

  if (args_SHARED)
    set (prefix "${CMAKE_SHARED_LIBRARY_PREFIX}")
    __CTRegexEscapeString(prefix_regex "${prefix}")
    
    set (suffix "${CMAKE_SHARED_LIBRARY_SUFFIX}")
    __CTRegexEscapeString(suffix_regex "${suffix}")

  elseif (args_STATIC)
    set (prefix "${CMAKE_STATIC_LIBRARY_PREFIX}")
    __CTRegexEscapeString(prefix_regex "${prefix}")

    set (suffix "${CMAKE_STATIC_LIBRARY_SUFFIX}")
    __CTRegexEscapeString(suffix_regex "${suffix}")
  endif ()  

  foreach (name IN LISTS args_NAMES)
    if ((args_STATIC OR args_SHARED)
        AND NOT name MATCHES "^${prefix_regex}.+${suffix_regex}$")
      list (APPEND canonical_names "${prefix}${name}${suffix}")
    else ()
      list (APPEND canonical_names "${name}")
    endif ()
  endforeach ()

  find_library(${var} NAMES ${canonical_names} ${args_UNPARSED_ARGUMENTS})

  if (NOT ${var} AND args_REQUIRED)
    unset (${var} CACHE)
    message(FATAL_ERROR "Required library '${var}' not found")
  endif ()
endfunction ()


# Escapes any characters that have a special regex meaning
function (__CTRegexEscapeString output_var input_string)
  string(REGEX REPLACE
         "\\[|\\]|\\(|\\)|\\^|\\$|\\.|\\*|\\+|\\?|\\|"
         "\\\\\\0" tmp "${input_string}")
  set (${output_var} "${tmp}" PARENT_SCOPE)
endfunction ()

