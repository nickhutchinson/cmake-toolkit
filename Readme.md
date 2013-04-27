# CMake Toolkit

A collection of utility functions to make common CMake tasks less painful. Note that these functions have only received cursory testing, and only with the Xcode, Makefile and Ninja generators, with Clang and GCC.

Notable features:

- simpler platform checks for functions, headers and symbols. Like Automake, you can check multiple items in a single command.
- a less error-prone way to add the headers and libraries supplied by a `find_package()` command to a target.
- a more uniform way to add compiler flags on a per-directory, per-source or per-target basis

#### TODO
- Better error checking and input validation
- Accurate documentation
- More robust testing

## General functions
### CTCheckBuildDirectorySanityOrDie
    CTCheckBuildDirectorySanityOrDie()
  
Enforces that the user is doing an out-of-source build, i.e. that *CMAKE_SOURCE_DIR* is not the same as *CMAKE_BINARY_DIR*. Unfortunately, even if you include this as early as possible in your topmost CMakeLists.txt file, CMake will still clutter your source folder with a small amount of flotsam and jetsam, but it's better than nothing.

### CTSanitiseBuildType
    CTSanitiseBuildType()

Ensures that *CMAKE_BUILD_TYPE* is not empty; sets it to *Debug* if it is.

## Platform-checking functions
### CTCheckDecls
### CTCheckFuncs
### CTCheckHeaders
    CTCheckDecls(decls... [REQUIRED])
    CTCheckFuncs(functions... [REQUIRED])
    CTCheckHeaders(headers... [REQUIRED])
  
**decls**, **functions** and **headers** are lists of declarations/functions/headers to check for. These functions define cached variables *HAVE\_DECL\_&lt;DECL&gt;*, *HAVE\_&lt;FUNCTION&gt;* or *HAVE\_&lt;HEADER&gt;* with the result of each test. (The name of the declaration, function or header is uppercased, and any character not matching `[A-Z0-9_]` is replaced with an underscore.)

As a convenience, pass the **REQUIRED** flag to abort the build if any test fails; in this case we *don't* set a cached variable, because we want the user to be able to fix the issue (e.g. *apt-get* the missing dependency) and re-configure without having to delete their CMakeCache.txt!

Note that you can use `CMAKE_REQUIRED_(DEFINITIONS|INCLUDES|LIBRARIES)` to change the behaviour of these checks. 

### CTSearchLibs
    CTSearchLibs(function LIBRARIES libraries... [REQUIRED])
  
Determines which one of the given libraries—if any—is necessary to link the given function. For example, on Linux the C maths functions—sin, cos, and so on—are typically found in *libm*, and require that your application links against this library, whereas on OS X these functions are part of the standard C library, and you don't have to do anything.

**function** is the function to look for; **libraries** is a list of libraries to look in. Note that *libraries* are checked in order, and only if *CTSearchLibs* determines that the function is not present in the standard C library.

On return, defines a cached variables *&lt;FUNCTION&gt;_FOUND* set to *1* or *0*, and *&lt;FUNCTION&gt;_LIBRARIES*, set to either the empty string (if no libraries are required) or the first library in *libraries* that contained the given function.

#### Sample usage:

    CTSearchLibs(cos LIBRARIES m)
    if (COS_FOUND)
      set (MATH_LIBRARIES ${COS_LIBRARIES})
    endif ()
    ...
    target_link_libraries(my_target ${MATH_LIBRARIES})

## Target/source/directory manipulation functions

### CTAddCompilerFlags
    CTAddCompilerFlags(<DIRECTORY | SOURCES sources... | TARGETS targets...> FLAGS flags...)
Adds compiler flags on a per-directory, per-source or per-target basis.

### CTSetCXXStandard
    CTSetCXXStandard(<standard> <DIRECTORY | TARGETS targets...>)
**standard** is one of *C++11*, *C++03*, etc.

Sets the appropriate compiler and/or linker flags to enable C++11 support for the given **targets**. When compiling with Clang on OS X, we also set the C++ standard library to *libc++*.

### CTSetObjCARCEnabled
    CTSetObjCARCEnabled(<value>  
        <DIRECTORY | TARGETS targets... | SOURCES sources... >)
Enables or disables Objective-C Automatic Reference Counting on a per-directory, per-target or per-source basis.

### CTTargetAddLinkerFlags
    CTTargetAddLinkerFlags(TARGETS targets... FLAGS flags...)
Adds the given linker flags to the given targets.

### CTTargetAddPackageDependencies
    CTTargetAddPackageDependencies(TARGETS targets... PACKAGES packages...)
This provides an easier and safer way to set up a target with the header folders and required libraries defined by a *FindXXX.cmake* package. These variables often have inconsistent naming, especially wrt. capitalisation (is it *Boost\_INCLUDE\_DIRS* vs *BOOST\_INCLUDE\_DIRS*?) and pluralisation (*OPENGL\_INCLUDE\_DIR* vs *OPENGL\_INCLUDE\_DIRS*). *CTTargetAddPackageDependencies* automatically handles the common permutations.
