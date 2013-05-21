
include (./CTAddCompilerFlags)
include (./CTCheckBuildDirectorySanityOrDie)
include (./CTCheckDecls)
include (./CTCheckFuncs)
include (./CTCheckHeaders)
include (./CTFindLibrary)
include (./CTGenerateCopyFilesCommandString)
include (./CTObjCARCSetEnabled)
include (./CTSanitiseBuildType)
include (./CTSearchLibs)
include (./CTTargetAddLinkerFlags)
include (./CTTargetAddPackageDependencies)
include (./CTTargetEnableCXX11)

###

CTCheckBuildDirectorySanityOrDie()

CTSanitiseBuildType()
message(STATUS "Build type is: ${CMAKE_BUILD_TYPE}")
