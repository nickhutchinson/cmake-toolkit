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
### CTInit
    CTInit([options...])
Call this in your top-most CMakeLists.txt file to perform some sanity checks. You may optionally disable a check by passing its corresponding option.

We support the following options:

- ALLOW_EMPTY_BUILD_TYPE: don't enforce a default "Debug" build type if none is set.
- ALLOW_IN_SOURCE_BUILDS: by default, we enforce out-of-source builds, i.e. that *CMAKE_SOURCE_DIR* is not the same as *CMAKE_BINARY_DIR*, and we abort early if this is not the case.
- OSX_ALLOW_UNSAFE_ASSERTMACROS: OS X has a very problematic header called AssertMacros.h that defines a set of unprefixed macros like `check()` and `verify()`. These often cause conflicts, and a series of bizarre compiler errors. By default, we disable the unprefixed versions.

## Platform Checks
### CTCheckDecls
### CTCheckFuncs
### CTCheckHeaders
    CTCheckDecls(decls... [REQUIRED])
    CTCheckFuncs(functions... [REQUIRED])
    CTCheckHeaders(headers... [REQUIRED])
  
**decls**, **functions** and **headers** are lists of declarations/functions/headers to check for. These functions define cached variables *HAVE\_DECL\_&lt;DECL&gt;*, *HAVE\_&lt;FUNCTION&gt;* or *HAVE\_&lt;HEADER&gt;* with the result of each test. (The name of the declaration, function or header is uppercased, and any character not matching `[A-Z0-9_]` is replaced with an underscore.)

As a convenience, pass the **REQUIRED** flag to abort the build if any test fails; in this case we *don't* set a cached variable, because we want the user to be able to fix the issue (e.g. *apt-get* the missing dependency) and re-configure without having to delete their CMakeCache.txt!

Note that you can use `CMAKE_REQUIRED_(DEFINITIONS|INCLUDES|LIBRARIES)` to change the behaviour of these checks, because they use *check\_symbol\_exists*, *check\_function\_exists* etc. internally.

### CTFindLibrary
    CTFindLibrary(<VAR> <name | NAMES names...> [STATIC|SHARED|FRAMEWORK] [REQUIRED] ...)
  
A drop-in replacement for CMake's `find_library()` with a few added options: you can specify if you only wish to find static, shared or OS X framework libraries, and you can pass **REQUIRED** to abort the build if the library could not be found.

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

## Target/source/directory manipulation

### CTAddCompilerFlags
    CTAddCompilerFlags(<DIRECTORY           |
                        SOURCES sources...  |
                        TARGETS targets...  >
                       FLAGS flags...)
Adds compiler flags on a per-directory, per-source or per-target basis.

### CTEnableCXX11
    CTEnableCXX11(<DIRECTORY | TARGETS targets...>)
Sets the appropriate compiler and/or linker flags to enable C++11 support for the given **targets**, or for all targets in the current directory. When compiling with Clang on OS X, we also set the C++ standard library to *libc++*.

### CTSetObjCARCEnabled
    CTSetObjCARCEnabled(<value>  
        <DIRECTORY | TARGETS targets... | SOURCES sources... >)
Enables or disables Objective-C Automatic Reference Counting on a per-directory, per-target or per-source basis.

### CTTargetAddLinkerFlags
    CTTargetAddLinkerFlags(TARGETS targets... FLAGS flags...)
Adds the given linker flags to the given targets.

### CTTargetAddPackageDependencies
    CTTargetAddPackageDependencies(TARGETS targets... PACKAGES packages...)
An easier and safer way to set up a target with the headers and libraries defined by a *FindXXX.cmake* package. CMake's packages often export variables with inconsistent naming, especially wrt. capitalisation (is it *Boost\_INCLUDE\_DIRS* vs *BOOST\_INCLUDE\_DIRS*?) and pluralisation (is it *OPENGL\_INCLUDE\_DIR* or *OPENGL\_INCLUDE\_DIRS*?) Fortunately, *CTTargetAddPackageDependencies* automatically handles the common permutations.

#### Sample usage:

    find_package(Boost)
    find_package(OpenGL)
    ...
    CTTargetAddPackageDependencies(TARGETS my_target PACKAGES OpenGL Boost)
