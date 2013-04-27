include (CMakeParseArguments)

# Annoyingly, compiler flags in CMake are a space-separated string,
# not a list. This function allows for more consistent behaviour.
function (CTAddCompilerFlags scope)
  cmake_parse_arguments(args "" "" "FLAGS" ${ARGN})

  set (space_separated_flags "")
  foreach (flag IN LISTS args_FLAGS)
    set (space_separated_flags "${space_separated_flags} ${flag}")
  endforeach ()

  if (scope STREQUAL "TARGETS")
    set_property(TARGET ${args_UNPARSED_ARGUMENTS} APPEND_STRING
      PROPERTY COMPILE_FLAGS "${space_separated_flags}")
  
  elseif (scope STREQUAL "SOURCES")
    set_property(SOURCE ${args_UNPARSED_ARGUMENTS} APPEND_STRING
      PROPERTY COMPILE_FLAGS "${space_separated_flags}")

  elseif (scope STREQUAL "DIRECTORY")
    # Using add_definitions() feels slightly seedy--these are *flags*, not
    # *definitions* dammit!--but the docs say you can do it. CMake has no
    # COMPILE_FLAGS directory property, and we can't really use
    # CMAKE_<LANG>_FLAGS because they're passed to the linker as well, which
    # is surprising.
    add_definitions(${args_FLAGS})
  else ()
    message(FATAL_ERROR "Invalid scope '${scope}' passed CTAddCompilerFlags")
  endif ()
endfunction ()
