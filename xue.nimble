version             = "1.0.0"
author              = "Hein Thant Maung Maung"
description         = "Just a simple programming language called XueLand."
license             = "MIT"
bin                 = @["xue"]
namedBin["xue"]     = "bin/xue"

requires "nim >= 1.4.8"

###########################################################

import os

let executableOutput = joinPath(thisDir(), namedBin["xue"])
let main = joinPath(thisDir(), "xue.nim")

task docs, "serve documentation":
    exec "php -S localhost:8000 -t docs"

task docsgen, "generate documentation":
    rmDir "./docs"
    exec "nim doc --project --index:on --outdir:docs ./xue.nim"
    mvFile "./docs/xue.html", "./docs/index.html"
