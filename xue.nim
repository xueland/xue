import common/[ioutils,tweaks]
import strutils

proc printVersion(shouldExit: bool = true) =
    when defined(release):
        const versionString = ["XueLand %s+%s ( %s / %s )", "(c) 2021 Hein Thant Maung Maung. Licensed under MIT License."].join("\n")
    else:
        const versionString = ["XueLand %s+%s ( %s / %s ) ( debug )", "(c) 2021 Hein Thant Maung Maung. Licensed under MIT License."].join("\n")
    printPaddedLine(versionString, XUE_VERSION_STRING, XUE_VERSION_BUILD, hostOS, hostCPU)
    if shouldExit: quit()

when isMainModule:
    printVersion()