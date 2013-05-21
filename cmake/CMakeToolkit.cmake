
include (./CTAddCompilerFlags)
include (./CTCheckBuildDirectorySanityOrDie)
include (./CTCheckDecls)
include (./CTCheckFuncs)
include (./CTCheckHeaders)
include (./CTEnableCXX11)
include (./CTFindLibrary)
include (./CTGenerateCopyFilesCommandString)
include (./CTObjCARCSetEnabled)
include (./CTSanitiseBuildType)
include (./CTSearchLibs)
include (./CTTargetAddLinkerFlags)
include (./CTTargetAddPackageDependencies)

###

CTCheckBuildDirectorySanityOrDie()

CTSanitiseBuildType()
message(STATUS "Build type is: ${CMAKE_BUILD_TYPE}")
