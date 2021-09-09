import strutils
import value, ../common/[ioutils, libc, tweaks]

type
    XueOpCode* = enum
        OP_PUSH,
        OP_POP,
        OP_ADD,
        OP_SUBTRACT,
        OP_NEGATE,
        OP_MULTIPLY,
        OP_DIVIDE,
        OP_MODULO,
        OP_POWER,
        OP_BITAND,
        OP_BITOR,
        OP_BITXOR,
        OP_BITLSH,
        OP_BITRSH,
        OP_LESS,
        OP_GREATER,
        OP_EQUAL,
        OP_NOT,
        OP_BITNOT,
        OP_RETURN

    LineStat* = tuple ## line status information struct
        offset, line: cint

    XueChunk* = object ## container for instructions, constant data, debug informations
        code*: seq[uint8]
        data*: seq[XueValue]
        line*: seq[LineStat]

proc writeChunk*(chunk: ptr XueChunk, u8: uint8 | XueOpCode, line: cint) =
    ## add u8 at given line to chunk.
    chunk.code.add((uint8)u8)
    if chunk.line.len() > 0 and
        chunk.line[^1].line == line:
            return
    chunk.line.add((offset: (cint)chunk.code.len() - 1, line: line))

proc addConstantChunk*(chunk: ptr XueChunk, constant: XueValue): int =
    ## add constant data to chunk's data section.
    chunk.data.add(constant)
    return chunk.data.len() - 1

proc searchLine(arr: seq[LineStat], offset: cint): int =
    ## just simple search. performance doesn't matter since this proc is invoked when error occurs.
    var start = 0
    var last = arr.len() - 1
    var mid = 0

    while start <= last:
        mid = (start + last) div 2
        if arr[mid].offset > offset:
            last = mid - 1
        elif mid == arr.len() - 1 or offset < arr[mid + 1].offset:
            return mid
        else:
            start = mid + 1
    return -1

proc getLineFromChunk*(chunk: ptr XueChunk, offset: cint): cint =
    ## get line number of instruction offset.
    let index = searchLine(chunk.line, offset)
    if index == -1:
        printPaddedLine("Oops, invalid or corrupted instruction chunk!")
        quit(EXIT_STATUS_FAILURE)
    return chunk.line[index].line

proc writeConstantChunk*(chunk: ptr XueChunk, constant: XueValue, line: cint) =
    ## add constant data to chunk's data section and write PUSH instruction
    writeChunk(chunk, OP_PUSH, line)
    let constantIndex = addConstantChunk(chunk, constant)
    # cast int( 32 bit ) -> 4 * u8 ( 8 bit )
    let u8s = cast[array[4, uint8]](constantIndex)
    for u8 in u8s:
        writeChunk(chunk, u8, line)

proc constantInstruction(name: string, chunk: ptr XueChunk, offset: cint): cint =
    if offset >= chunk.code.len() - 1:
        printPaddedLine("Oops, invalid or corrupted instruction chunk!")
        quit(EXIT_STATUS_FAILURE)

    let u8s = [
        chunk.code[offset + 1],
        chunk.code[offset + 2],
        chunk.code[offset + 3],
        chunk.code[offset + 4],
    ]

    let index: int = cast[cint](u8s)
    if index >= chunk.data.len():
        printPaddedLine("Oops, invalid PUSH instruction!")
        quit(EXIT_STATUS_FAILURE)

    fprintf(stderr, "%s %s\n", name, cstring($chunk.data[index]))
    return offset + 5

proc simpleInstruction(name: string, offset: cint): cint =
    fprintf(stderr, "%s\n", name); return offset + 1

proc disassembleInstruction*(chunk: ptr XueChunk, offset: cint): cint =
    ## disassemble instruction at given offset from a chunk
    fprintf(stderr, "%3u | %04u ", getLineFromChunk(chunk, offset), offset)
    let opcode = (XueOpCode)chunk.code[offset]
    case opcode
    of OP_PUSH:
        return constantInstruction("PUSH", chunk, offset)
    else:
        return simpleInstruction(replace($opcode, "OP_"), offset)

proc disassembleChunk*(chunk: ptr XueChunk, name: string) =
    ## disassemble code, data, debug message from a chunk
    fprintf(stderr, "[debug] disassemble '%s':\n", name)
    var offset: cint = 0
    while offset < chunk.code.len():
        fprintf(stderr, "[debug] ")
        offset = disassembleInstruction(chunk, offset)