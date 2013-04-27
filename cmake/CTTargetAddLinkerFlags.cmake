include(CMakeParseArguments)

function (CTTargetAddLinkerFlags)
  cmake_parse_arguments(args "" "" "TARGETS;FLAGS" ${ARGN})

  foreach (target IN LISTS args_TARGETS)
    # This feels gross, but is apparently the canonical way to add linker flags
    # in CMake.
    target_link_libraries("${target}" ${args_FLAGS})
  endforeach ()
endfunction ()
