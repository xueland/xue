import strformat, strutils

const
    NoNewLinePadding* {.booldefine.} = false ## whether new-line padding should be inserted when `printPaddedLine` is called

    XUE_VERSION_MAJOR* {.intdefine.} = 1 ## xue major version number
    XUE_VERSION_MINOR* {.intdefine.} = 0 ## xue minor version number
    XUE_VERSION_PATCH* {.intdefine.} = 0 ## xue patch version number
    XUE_VERSION_BUILD* = fmt"{CompileDate}{CompileTime}".multiReplace(("-", ""), (":", ""))
        ## build number is generated basded on `CompileDate` and `CompileTime`
    XUE_VERSION_STRING* = fmt"{XUE_VERSION_MAJOR}.{XUE_VERSION_MINOR}.{XUE_VERSION_PATCH}"
        ## build number is generated basded major, minor, patch version.

    EXIT_STATUS_SUCCESS* = 0        ## operation is succeeded
    EXIT_STATUS_FAILURE* = 1        ## operation is failed with some error
    EXIT_STATUS_WRONG_USAGE* = 2    ## operation is failed due to invalid CLI usage, etc.