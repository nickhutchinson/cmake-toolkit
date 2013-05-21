include (CMakeParseArguments)

# CMake docs recommend `cmake -E copy <SOURCE> <DEST>` instead of the standard 
# cp <SOURCES>... <DEST> for cross-platform compatibility; it's a shame the 
# `cmake -E` commands are so cumbersome. For instance, *copy* command only
# takes a single file to copy. (Would it have killed them to make it mirror the
# UNIX-y version that takes multiple files?)
# 
# Anyway, rant over. Use this function to generate a command string that you
# can pass to `add_custom_command()`, `execute_process()`, etc.

function (CTGenerateCopyFilesCommandString result_var)
  cmake_parse_arguments(args "" "DESTINATION" "FILES" ${ARGN})

  set (command_string "")

  foreach (file IN LISTS args_FILES)
    list (APPEND command_string "${CMAKE_COMMAND}" -E copy "${file}" "${args_DESTINATION}" &&)
  endforeach ()

  # Remove trailing &&
  if (command_string)
    list (REMOVE_AT command_string -1)
  endif ()

  set (${result_var} "${command_string}" PARENT_SCOPE)
endfunction ()