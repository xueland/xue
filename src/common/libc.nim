proc printf*(format: cstring) {.importc: "printf", varargs, header: "<stdio.h>".}
    ## binding for `printf` from `stdio.h`

proc fprintf*(stream: File, format: cstring) {.importc: "fprintf", varargs, header: "<stdio.h>".}
    ## binding for `fprintf` from `stdio.h`

proc puts*(s: cstring) {.importc: "puts", header: "<stdio.h>".}
    ## binding for `puts` from `stdio.h`

proc fputs*(s: cstring, stream: File) {.importc: "fputs", header: "<stdio.h>".}
    ## binding for `fputs` from `stdio.h`

proc fflush*(stream: File) {.importc: "fputs", header: "<stdio.h>".}
    ## binding for `fflush` from `stdio.h`