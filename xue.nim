import common/[ioutils,tweaks]
import strutils, parseopt
import terminal

proc printVersion(shouldExit: bool = true) =
    when defined(release):
        const versionString = ["XueLand %s+%s ( %s / %s )", "(c) 2021 Hein Thant Maung Maung. Licensed under MIT License."].join("\n")
    else:
        const versionString = ["XueLand %s+%s ( %s / %s ) ( debug )", "(c) 2021 Hein Thant Maung Maung. Licensed under MIT License."].join("\n")
    printPaddedLine(versionString, XUE_VERSION_STRING, XUE_VERSION_BUILD, hostOS, hostCPU)
    if shouldExit: quit()

proc printHelp() =
    printVersion(false)
    const helpString = [
        "SYNOPSIS:\n",
        "   xue [options]... [script]...\n",
        "OPTIONS:\n",
        "    -r, --run          run the code pass with -r option\n",
        "    -v, --version      print Xue version and others.",
        "    -h, --help         print this help message like usage, options, etc.\n",
        "REPORTING:\n",
        "    https://github.com/xueland/xue/issues. Contributions are also welcome!\n"
    ].join("\n")
    printLine(helpString); quit(EXIT_STATUS_FAILURE)

when isMainModule:
    var
        inputScript: string ## xue script to interpret
        runnableCode: string ## code that's passed with -r option

    for kind, option, value in getopt(shortNoVal = {'h', 'v'},
            longNoVal = @["help", "version"]):
        case kind
        of cmdEnd:
            printPaddedLine("Oops, something went wrong while parsing CLI arguments!")
            quit(EXIT_STATUS_FAILURE)
        of cmdLongOption:
            case option
            of "help": printHelp()
            of "version": printVersion()
            of "run":
                runnableCode = value
            of "": discard
            else:
                printPaddedLine("Oops, --%s is not a valid option. See 'xue --help'.", option)
                quit(EXIT_STATUS_WRONG_USAGE)
        of cmdShortOption:
            case option
            of "h": printHelp()
            of "v": printVersion()
            of "r":
                runnableCode = value
            of "":
                inputScript = "-"
            else:
                printPaddedLine("Oops, -%s is not a valid option. See 'xue --help'.", option)
                quit(EXIT_STATUS_WRONG_USAGE)
        of cmdArgument:
            inputScript = option

    if runnableCode != "":
        printPaddedLine("running from code passed with -r.")
    elif inputScript != "":
        printPaddedLine("running from file: '%s'.", inputScript)
    elif isatty(stdin):
        printPaddedLine("running from REPL.")
    else:
        printPaddedLine("running from stdin.")