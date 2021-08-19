version             = "1.0.0"
author              = "Hein Thant Maung Maung"
description         = "Just a simple programming language called XueLand."
license             = "MIT"
bin                 = @["xue"]
namedBin["xue"]     = "bin/xue"

requires "nim >= 1.4.8"

task docs, "serve documentation":
    exec "python3 -m http.server -d ./docs"

task docsgen, "generate documentation":
    exec "nim doc --project --index:on --outdir:docs ./xue.nim"
