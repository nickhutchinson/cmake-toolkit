
include (./CTAddCompilerFlags)
include (./CTCheckBuildDirectorySanityOrDie)
include (./CTCheckDecls)
include (./CTCheckFuncs)
include (./CTCheckHeaders)
include (./CTGenerateCopyFilesCommandString)
include (./CTObjCARCSetIsEnabled)
include (./CTSanitiseBuildType)
include (./CTSearchLibs)
include (./CTTargetAddLinkerFlags)
include (./CTTargetAddPackageDependencies)
include (./CTTargetEnableCXX11)

###

CTCheckBuildDirectorySanityOrDie()

CTSanitiseBuildType()
message(STATUS "Build type is: ${CMAKE_BUILD_TYPE}")
