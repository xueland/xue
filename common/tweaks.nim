import strformat, strutils

const
    NoNewLinePadding* {.booldefine.} = false ## whether new-line padding should be inserted when `printPaddedLine` is called

    XUE_VERSION_MAJOR* {.intdefine.} = 1
    XUE_VERSION_MINOR* {.intdefine.} = 0
    XUE_VERSION_PATCH* {.intdefine.} = 0
    XUE_VERSION_BUILD* = fmt"{CompileDate}{CompileTime}".multiReplace(("-", ""), (":", ""))
    XUE_VERSION_STRING* = fmt"{XUE_VERSION_MAJOR}.{XUE_VERSION_MINOR}.{XUE_VERSION_PATCH}"
