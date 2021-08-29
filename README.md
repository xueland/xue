# XueLand ( 雪 )

![LICENSE](https://img.shields.io/github/license/xueland/xue?color=green&label=LICENSE&style=flat-square)
![LANGUAGE](https://img.shields.io/static/v1?label=LANGUAGE&message=NIM&style=flat-square)

Just a simple programming language called XueLand. Imagine a Lua-inspired scripting language which supports multi-paradigms ( procedural, functional or OOP, etc. ) and has nice features borrowed from other languages.

## HOW TO CALL

You can call whatever as u like: Xue, XueLand or 雪地.

```text
雪 ( snow ) + Land = XueLand ( SnowLand )
```

## HOW TO BUILD

Just clone the repo, then run `nimble build`. But, now, this project is built on top of nim devel branch. So, some code won't work in current nim stable (1.4.8).

```bash
git clone https://github.com/xueland/xue && cd xue
nimble build -d:release
```

Generate and view documentations:

```bash
nimble docsgen && nimble docs
```

## THANKS AND RESOURCES

Special thanks to:

- [@mrthetkhine](https://github.com/mrthetkhine): I've got a lot of inspiration from SAYA THET KHINE!
- [@munificent](https://github.com/munificent): for his awesome book called [CRAFTING INTERPRETERS](https://craftinginterpreters.com).
- [@davidcallanan](https://github.com/davidcallanan): for his awesome tutorial on [MAKING BASIC INTERPRETER](https://www.youtube.com/playlist?list=PLZQftyCk7_SdoVexSmwy_tBgs7P0b97yD).

Other Resources:

- [Write an Interpreter in Go](https://interpreterbook.com)
- [Write a Compiler in Go](https://compilerbook.com)
- [Simple Virtual Machine in C](https://felix.engineer/blogs/virtual-machine-in-c)
- [Pratt Parser in Go](https://quasilyte.dev/blog/post/pratt-parsers-go/)
- [Pratt Parser in Java](https://journal.stuffwithstuff.com/2011/03/19/pratt-parsers-expression-parsing-made-easy)
- [Wren Programming Language](https://wren.io)

XueLand won't exists, without them!

## LICENSE

XueLand compiler, virtual machine and standard libs are licensed under MIT License. For more details, see [LICENSE](LICENSE).