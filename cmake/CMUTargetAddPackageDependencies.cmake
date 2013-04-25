include (CMakeParseArguments)

function (CMUTargetAddPackageDependencies target)
  cmake_parse_arguments(args "" "" "PACKAGES" ${ARGV})

  foreach (package IN LISTS args_PACKAGES)
    __TryGetCanonicalPackageName("${package}" canonical_package)
    if (canonical_package)
      __TargetAddPackageDependency("${target}" ${canonical_package})
    endif ()
  endforeach ()
endfunction ()

function (__TargetAddPackageDependency target package)
  if (DEFINED "${package}_INCLUDE_DIRS")
    set_property(TARGET "${target}" APPEND PROPERTY INCLUDE_DIRECTORIES ${${package}_INCLUDE_DIRS})
  elseif (DEFINED "${package}_INCLUDE_DIR")
    set_property(TARGET "${target}" APPEND PROPERTY INCLUDE_DIRECTORIES ${${package}_INCLUDE_DIR})
  endif ()

  if (DEFINED "${package}_LIBRARIES")
    target_link_libraries("${target}" ${${package}_LIBRARIES})
  elseif (DEFINED "${package}_LIBRARY")
    target_link_libraries("${target}" ${${package}_LIBRARY})
  endif ()
endfunction()

function (__TryGetCanonicalPackageName package result)
  # First, try as is
  if ("${package}_FOUND")
    set ("${result}" "${package}" PARENT_SCOPE)
    return ()
  endif ()

  # Okay, now try capitalised
  __CapitaliseString("${package}" capitalised_package)
  if ("${capitalised_package}_FOUND")
    set ("${result}" "${capitalised_package}" PARENT_SCOPE)
    return ()
  endif ()

  # Try uppercased
  string(TOUPPER "${package}" uppercase_pacakge)
  if ("${uppercase_pacakge}_FOUND")
    set ("${result}" "${uppercase_pacakge}" PARENT_SCOPE)
    return ()
  endif ()
endfunction ()

function (__CapitaliseString input output)
  string(REGEX REPLACE "^(.).*$" "\\1" head "${input}")
  string(TOUPPER "${head}" head)
  string(REGEX REPLACE "^.(.*)$" "\\1" tail "${input}")
  set ("${output}" "${head}${tail}" PARENT_SCOPE)
endfunction ()
