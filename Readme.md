# CmakeUtilities

## About
CMake driving you to drink? Here, have some utility functions to make common CMake tasks less painful. 

We have:

- simpler platform checks for functions, headers and symbols. 
- a less cumbersome way to add the headers and libraries supplied by a `find_package()` command to a target. The variables defined by the various FindXXX.cmake packages are infuratingly inconsistent—is it *BOOST_INCLUDE_DIR* that I'm supposed to use? *BOOST_INCLUDE_DIRS*? Oh yeah... it's *Boost_INCLUDE_DIRS*. `CMUTargetAddPackageDependencies()` automatically handles the common permutations.
- a few other helpful odds and ends.

**Warning**: This is all quite rough around the edges. (But then again, so is CMake.)

### TODO:
- Better error checking/input validation
- Accurate documentation
- More robust testing

## Functions
### Housekeeping
- `CMUAssertSaneBuildDirectory()`
  
  Enforces that the user is doing an out-of-source build, i.e. that *CMAKE_SOURCE_DIR* is not the same as *CMAKE_BINARY_DIR*. Unfortunately, even if you include this as early as possible in your topmost CMakeLists.txt file, CMake will still clutter your source folder with a small amount of flotsam and jetsam, but it's better than nothing!

- `CMUSanitiseBuildType()`
  
  Ensures that *CMAKE_BUILD_TYPE* is not empty; sets it to *Debug* if it is.

### Platform Checks
- `CMUCheckDecls(decls... [REQUIRED])`
- `CMUCheckFuncs(functions... [REQUIRED])`
- `CMUCheckHeaders(headers... [REQUIRED])`
  
  **decls**, **functions** and **headers** are lists of declarations/functions/headers to check for. These functions define a cached variable *HAVE\_DECL\_&lt;DECL&gt;* (CMUCheckDecls), *HAVE\_&lt;FUNCTION&gt;* (CMUCheckFuncs) or *HAVE\_&lt;HEADER&gt;* (CMUCheckHeaders) with the result of each test.

  As a convience, pass the *REQUIRED* flag to abort the build if any test fails; in this case we *don't* set a cached variable: we want the user to be able to fix the issue (e.g. apt-get the missing dependency) and re-configure without having to delete their CMakeCache.txt. (If you haven't experienced this particular circle of hell yet, I envy you!)

  Note that you can use `CMAKE_REQUIRED_(DEFINITIONS|INCLUDES|LIBRARIES)` to change the behaviour of these checks. 

- `CMUSearchLibs(function LIBRARIES libraries... [REQUIRED])`
  
  Determines which of the given *libraries*—if any—are necessary to link the given library. For example, on Linux the C math functions—sin, cos, and so on—are typically found in libm, and require that your application links against this library, whereas on OS X these functions are part of the standard C library.

  **function** is the function to look for; **libraries** is a list of libraries to look in. Note that *libraries* are checked in order, and only if CMUSearchLibs determines that the function is not present in the standard C library.

  On return, defines a cached variables *&lt;FUNCTION&gt;_FOUND* set to *1* or *0*, and *&lt;FUNCTION&gt;_LIBRARIES*, set to either the empty string (if no libraries are required) or the first library in *libraries* that contained the given function.

  Sample usage:

        CMUSearchLibs(cos LIBRARIES m)
        if (COS_FOUND)
          set (MATH_LIBRARIES ${COS_LIBRARIES})
        endif ()
        ...
        target_link_libraries(my_target ${MATH_LIBRARIES})

### Target/source file configuration

- `CMUAddCompilerFlags(<[SOURCE sources...]|[TARGET targets...]> FLAGS flags...)`
- `CMUTargetAddLinkerFlags(TARGET targets... FLAGS flags...)`
- `CMUTargetAddPackageDependencies(TARGET targets... PACKAGES packages...)`

- `CMUTargetEnableCXX11(<target>)`

  Sets the appropriate build/linker flags to enable C++11 support for the given **target**, and works with GCC and Clang.
  When compiling with Clang on OS X, also makes the target use the libc++ C++ standard library.
