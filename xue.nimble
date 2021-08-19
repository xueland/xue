version             = "1.0.0"
author              = "Hein Thant Maung Maung"
description         = "Just a simple programming language called XueLand."
license             = "MIT"
bin                 = @["xue"]
namedBin["xue"]     = "bin/xue"

requires "nim >= 1.4.8"

###########################################################

import os
import strformat

let executableOutput = joinPath(thisDir(), namedBin["xue"])
let main = joinPath(thisDir(), "xue.nim")

task docs, "serve documentation":
    exec "php -S localhost:8000 -t docs"

task docsgen, "generate documentation":
    rmDir "./docs"
    exec "nim doc --project --index:on --outdir:docs ./xue.nim"
    mvFile "./docs/xue.html", "./docs/index.html"

###########################################################

task universal, "create universal macos bin ( ARM, x86 )":
    let arm = "-l:'-target arm64-apple-macos11' -t:'-target arm64-apple-macos11'"
    let x86 = "-l:'-target x86_64-apple-macos10.8' -t:'-target x86_64-apple-macos10.8'"
    var nimbleFlags = fmt"--noNimblePath --colors:on --hints:off -d:NimblePkgVersion={version}"

    for i in countdown(paramCount(), 0):
        if paramStr(i) == "universal": break
        nimbleFlags = nimbleFlags & " " & paramStr(i)

    # build x86
    rmDir(nimcacheDir())
    exec ["nim c", nimbleFlags, x86, fmt"-o:{executableOutput}.x86-bin", main].join(" ")
    # build ARM
    rmDir(nimcacheDir())
    exec ["nim c", nimbleFlags, arm, fmt"-o:{executableOutput}.arm-bin", main].join(" ")
    # create universal bin
    exec fmt"lipo -create -output {executableOutput} {executableOutput}.x86-bin {executableOutput}.arm-bin"
