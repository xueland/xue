import strutils, parseopt, os
import terminal, rdstdin, unicode
import common/[ioutils,tweaks]
import machine/[opcode,machine,value]

proc printVersion(shouldExit: bool = true) =
    ## print interpreter version, license, etc.
    when defined(release):
        const versionString = ["XueLand %s+%s ( %s / %s )", "(c) 2021 Hein Thant Maung Maung. Licensed under MIT License."].join("\n")
    else:
        const versionString = ["XueLand %s+%s ( %s / %s ) ( debug )", "(c) 2021 Hein Thant Maung Maung. Licensed under MIT License."].join("\n")
    printPaddedLine(versionString, XUE_VERSION_STRING, XUE_VERSION_BUILD, hostOS, hostCPU)
    if shouldExit: quit()

proc printHelp() =
    ## print help message like usage, options, etc.
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

proc runCodeString*(code: string, sourcePath: string) =
    ## compile given code to instructions and then interpret using VM.
    var chunk: XueChunk
    writeConstantChunk(addr(chunk), XueValue(kind: VALUE_CHARACTER, character: "က".runeAt(0)), 123)
    writeChunk(addr(chunk), OP_RETURN, 123)
    disassembleChunk(addr(chunk), "test chunk")
    discard interpretChunk(addr(chunk))

proc readStringFromPath(path: string): string =
    ## read content of given path. read stdin if path is "-".
    try:
        if path == "-":
            return stdin.readAll()
        if not fileExists(path):
            if dirExists(path):
                printPaddedLine("Oops, '%s' is a DIRECTORY, please check the path!", path)
                quit(EXIT_STATUS_WRONG_USAGE)
            printPaddedLine("Oops, '%s' does NOT EXISTS, please check the path!", path)
            quit(EXIT_STATUS_WRONG_USAGE)
        return readFile(path)
    except IOError:
        printPaddedLine("Oops, something went wrong while reading code, check permission!")
        quit(EXIT_STATUS_FAILURE)

proc runFromFile*(path: string) =
    ## read code from given path, compile and interpret
    let code = readStringFromPath(path)
    if strutils.strip(code) != "":
        runCodeString(code, path)

proc readLine(prompt: string): string =
    ## read line wrapper. use linenoise on unix and just stdin.readLine() on windows.
    when defined(windows):
        stdout.write(prompt)
        try:
            return readLine(stdin)
        except IOError:
            printPaddedLine("Oops, something went wrong while reading input from terminal!")
            quit(EXIT_STATUS_FAILURE)
    else:
        try:
            return readLineFromStdin(prompt)
        except IOError:
            # this might be Ctrl - C
            quit(EXIT_STATUS_SUCCESS)

proc isREPLcommand(input: string): bool =
    ## check if input is REPL command, and execute it if it's a command
    case input
    of "exit", "quit":
        quit(EXIT_STATUS_SUCCESS)
    of "clear", "cls":
        when defined(windows):
            discard execShellCmd "cls"
        else:
            discard execShellCmd "clear"
        return true
    of "version":
        printVersion(false); return true
    return false

proc runFromREPL*() =
    ## spawn REPL shell, accept input, invoke REPL command, then interpret code
    printVersion(false)
    while true:
        let userInput = readLine("xue > ")
        let strippedInput = strutils.strip(userInput)

        if strippedInput == "":
            continue
        if isREPLcommand(strippedInput):
            continue
        runCodeString(userInput, "REPL")

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
                printPaddedLine(
                    "Oops, --%s is not a valid option. See 'xue --help'.", cstring(option))
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
                printPaddedLine(
                    "Oops, -%s is not a valid option. See 'xue --help'.", cstring(option))
                quit(EXIT_STATUS_WRONG_USAGE)
        of cmdArgument:
            inputScript = option

    if runnableCode != "":
        runCodeString(runnableCode, "")
    elif inputScript != "":
        runFromFile(inputScript)
    elif isatty(stdin):
        runFromREPL()
    else: runFromFile("-")