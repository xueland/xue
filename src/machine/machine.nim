import opcode, value, valueop
import ../common/[ioutils,tweaks,libc]

type
    XueVirtualMachine* = object ## the Xue VM
        chunk: ptr XueChunk
        eip: cint
        stack: seq[XueValue]

    XueInterpretResult* = enum  ## interpret result
        INTERPRET_OK,           ## it's OK ... it works!
        INTERPRET_RUNTIME_ERROR ## oops, we have runtime error

    XueRuntimeError* = object of CatchableError ## just runtime error struct with error message

var vm: XueVirtualMachine

proc pushStack(value: XueValue) =
    vm.stack.add(value)

proc popStack(): XueValue {.inline,discardable.} =
    return vm.stack.pop()

proc peekStack(distance: int = 0): XueValue =
    return vm.stack[^(distance + 1)]

proc getInstruction(): uint8 {.inline.} =
    vm.eip.inc()
    return vm.chunk.code[vm.eip - 1]

proc getIndexOperand(): cint =
    if vm.eip > vm.chunk.code.len() - 1:
        printPaddedLine("Oops, invalid or corrupted instruction chunk!")
    let u8s = [getInstruction(), getInstruction(), getInstruction(), getInstruction()]
    return cast[cint](u8s)

template BINARY_OP(op): untyped =
    try:
        let b = peekStack()
        let a = peekStack(1)
        let r = op(a, b)
        popStack(); popStack()
        pushStack(r)
    except ValueError as error:
        raise newException(XueRuntimeError, error.msg)

proc execute(): XueInterpretResult =
    try:
        while true:
            when DEBUG_TRACE_EXECUTION:
                fprintf(stderr, "[vmach] ")
                for value in vm.stack:
                    fprintf(stderr, "[ %s ]", cstring($value))
                fprintf(stderr, if vm.stack.len() == 0: cstring("no value in stack\n") else: cstring("\n"))
                fprintf(stderr, "[vmach] ")
                discard disassembleInstruction(vm.chunk, vm.eip)
            {.computedGoto.}
            let instruction = (XueOpCode)getInstruction()
            case instruction
            of OP_PUSH:
                let index = getIndexOperand()
                if index >= vm.chunk.data.len():
                    printPaddedLine("Oops, invalid PUSH instruction!")
                    return INTERPRET_RUNTIME_ERROR
                pushStack(vm.chunk.data[index])
            of OP_POP: popStack()
            of OP_ADD:
                BINARY_OP(`+`)
            of OP_SUBTRACT:
                BINARY_OP(`-`)
            of OP_NEGATE:
                try:
                    let value = peekStack()
                    pushStack(- value)
                except ValueError as error:
                    printPaddedLine(error.msg)
                    return INTERPRET_RUNTIME_ERROR
            of OP_MULTIPLY:
                BINARY_OP(`*`)
            of OP_DIVIDE:
                BINARY_OP(`/`)
            of OP_MODULO:
                BINARY_OP(`mod`)
            of OP_POWER:
                BINARY_OP(`^`)
            of OP_BITAND:
                BINARY_OP(`bitand`)
            of OP_BITOR:
                BINARY_OP(`bitor`)
            of OP_BITXOR:
                BINARY_OP(`bitxor`)
            of OP_BITLSH:
                BINARY_OP(`bitshl`)
            of OP_BITRSH:
                BINARY_OP(`bitshr`)
            of OP_LESS:
                BINARY_OP(`<`)
            of OP_GREATER:
                BINARY_OP(`>`)
            of OP_EQUAL:
                BINARY_OP(`==`)
            of OP_BITNOT:
                try:
                    let value = peekStack()
                    pushStack(bitnot value)
                except ValueError as error:
                    printPaddedLine(error.msg)
                    return INTERPRET_RUNTIME_ERROR
            of OP_NOT:
                try:
                    let value = peekStack()
                    pushStack(not value)
                except ValueError as error:
                    printPaddedLine(error.msg)
                    return INTERPRET_RUNTIME_ERROR
            of OP_RETURN:
                echo $vm.stack.pop()
                return INTERPRET_OK
    except XueRuntimeError as runtimeError:
        printPaddedLine(runtimeError.msg)
        return INTERPRET_RUNTIME_ERROR

proc interpretChunk*(chunk: ptr XueChunk): XueInterpretResult =
    ## interpret given xue chunk
    vm.chunk = chunk
    vm.eip = 0
    return execute()
