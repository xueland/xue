import macros
import libc
import tweaks

macro print*(format: string, args: varargs[untyped]): untyped =
    ## Wrapper around libc `printf` and `fputs`.
    ## 
    ## Invoke `printf(format, args)` or `fputs(format, stdout)` based on args len passed to this macro.
    runnableExamples:
        print("Hello, World!\n") # -> "Hello, World!\n"
        print("%s\n", "Hello, World!") # -> "Hello, World!\n"

    if args.len() == 0:
        return quote do:
            fputs(cstring(`format`), stdout)
    else:
        return quote do:
            printf(cstring(`format`), `args`)

macro printLine*(format: string, args: varargs[untyped]): untyped =
    ## Wrapper around libc `printf` and `puts`.
    ## 
    ## Invoke `printf(format, args)` or `fputs(format, stdout)` based on args len passed to this macro with new-line at the end.
    runnableExamples:
        printLine("Hello, World!") # -> "Hello, World!\n"

    return quote do:
        print(`format` & "\n", `args`)

macro printPaddedLine*(format: string, args: varargs[untyped]): untyped =
    ## Wrapper around libc `printf` and `puts`.
    ## 
    ## Invoke `printf(format, args)` or `fputs(format, stdout)` based on args len passed to this macro with new-line at the beginning and end unless `NO_NEWLINE_PADDING` is set to `true`.
    runnableExamples:
        printPaddedLine("Hello, World!") # -> "\nHello, World!\n\n" ( default behaviour )
        printPaddedLine("Hello, World!") # -> "Hello, World!\n" ( when `NO_NEWLINE_PADDING` is `true` )

    when NO_NEWLINE_PADDING:
        return quote do:
            print(`format` & "\n", `args`)
    else:
        return quote do:
            print("\n" & `format` & "\n\n", `args`)