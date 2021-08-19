import macros
import libc
import tweaks

macro print*(format: cstring, args: varargs[untyped]): untyped =
    ## Wrapper around libc `printf` and `fputs`.
    ## 
    ## Invoke `printf(format, args)` or `fputs(format, stdout)` based on args len passed to this macro.
    runnableExamples:
        print("Hello, World!\n") # -> "Hello, World!\n"
        print("%s\n", "Hello, World!") # -> "Hello, World!\n"

    if args.len() == 0:
        return quote do:
            fputs(`format`, stdout)
    else:
        return quote do:
            printf(`format`, `args`)

macro printLine*(format: cstring, args: varargs[untyped]): untyped =
    ## Wrapper around libc `printf` and `puts`.
    ## 
    ## Invoke `printf(format, args)` or `fputs(format, stdout)` based on args len passed to this macro with new-line at the end.
    runnableExamples:
        printLine("Hello, World!") # -> "Hello, World!\n"

    return quote do:
        print(`format` & "\n", `args`)

macro printPaddedLine*(format: cstring, args: varargs[untyped]): untyped =
    ## Wrapper around libc `printf` and `puts`.
    ## 
    ## Invoke `printf(format, args)` or `fputs(format, stdout)` based on args len passed to this macro with new-line at the beginning and end unless `NoNewLinePadding` is set to `true`.
    runnableExamples:
        printPaddedLine("Hello, World!") # -> "\nHello, World!\n\n" ( default behaviour )
        printPaddedLine("Hello, World!") # -> "Hello, World!\n" ( when `NoNewLinePadding` is `true` )

    when NoNewLinePadding:
        return quote do:
            print(`format` & "\n", `args`)
    else:
        return quote do:
            print("\n" & `format` & "\n\n", `args`)