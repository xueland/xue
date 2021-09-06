import value
import math, unicode

template numberOperation*(integerOp, doubleOp, errorMessage): untyped =
    ## arithmetic operation proc generator
    proc `op`*(a: XueValue, b: XueValue): XueValue =
        if a.kind == VALUE_INTEGER and b.kind == VALUE_INTEGER:
            return XueValue(kind: VALUE_INTEGER, integer: integerOp(a.integer, b.integer))
        elif a.kind == VALUE_INTEGER and b.kind == VALUE_DOUBLE:
            return XueValue(kind: VALUE_DOUBLE, double: doubleOp(cdouble(a.integer), b.double))
        elif a.kind == VALUE_DOUBLE and b.kind == VALUE_INTEGER:
            return XueValue(kind: VALUE_DOUBLE, double: doubleOp(a.double, cdouble(b.integer)))
        elif a.kind == VALUE_DOUBLE and b.kind == VALUE_DOUBLE:
            return XueValue(kind: VALUE_DOUBLE, double: doubleOp(a.double, b.double))
        raise newException(ValueError, errorMessage)

template bitOperation(op): untyped =
    ## bitwise operation proc generator
    proc `op`*(a: XueValue, b: XueValue): XueValue =
        if a.kind == VALUE_INTEGER and b.kind == VALUE_INTEGER:
            return XueValue(kind: VALUE_INTEGER, integer: op(a.integer, b.integer))
        elif a.kind == VALUE_INTEGER and b.kind == VALUE_DOUBLE:
            return XueValue(kind: VALUE_INTEGER, integer: op(a.integer, cint(b.double)))
        elif a.kind == VALUE_DOUBLE and b.kind == VALUE_INTEGER:
            return XueValue(kind: VALUE_INTEGER, integer: op(cint(a.double), b.integer))
        elif a.kind == VALUE_DOUBLE and b.kind == VALUE_DOUBLE:
            return XueValue(kind: VALUE_INTEGER, integer: op(cint(a.double), cint(b.double)))
        raise newException(ValueError, "cannot perform bitwise operation on non-numbers!")

numberOperation(`+`, `+`, "cannot perform addition on non-numbers!")
numberOperation(`-`, `-`, "cannot perform subtraction on non-numbers!")
numberOperation(`*`, `*`, "cannot perform multiplication on non-numbers!")
numberOperation(`div`, `/`, "cannot perform division on non-numbers!")
numberOperation(`mod`, `mod`, "cannot calculate modulo on non-numbers!")
numberOperation(`^`, pow, "cannot calculate modulo on non-numbers!")

bitOperation(`and`)
bitOperation(`or`)
bitOperation(`xor`)
bitOperation(`shl`)
bitOperation(`shr`)

proc bitnot*(value: XueValue): XueValue =
    case value.kind
    of VALUE_INTEGER:
        return XueValue(kind: VALUE_INTEGER, integer: not value.integer)
    of VALUE_DOUBLE:
        return XueValue(kind: VALUE_INTEGER, integer: not cint(value.double))
    else:
        raise newException(ValueError, "cannot perform bitwise operation on non-numbers!")

proc `not`*(value: XueComposite): XueValue =
    case value.kind
        of COMPOSITE_LIST:
            return XueValue(kind: VALUE_BOOLEAN, boolean: XueList(value).items.len() == 0)

proc `not`*(value: XueValue): XueValue =
    case value.kind
    of VALUE_NOTVAL, VALUE_NULL:
        return XueValue(kind: VALUE_BOOLEAN, boolean: true)
    of VALUE_BOOLEAN:
        return XueValue(kind: VALUE_BOOLEAN, boolean: not value.boolean)
    of VALUE_INTEGER:
        return XueValue(kind: VALUE_BOOLEAN, boolean: value.integer == 0)
    of VALUE_DOUBLE:
        return XueValue(kind: VALUE_BOOLEAN, boolean: value.double == 0)
    of VALUE_CHARACTER:
        return XueValue(kind: VALUE_BOOLEAN, boolean: int32(value.character) == 0)
    of VALUE_COMPOSITE:
        return not value.composite
