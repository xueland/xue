import value
import math, unicode

template numberOperation*(op, integerOp, doubleOp, errorMessage): untyped =
    ## arithmetic op proc generator
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

template bitOperation(xop, op): untyped =
    ## bitwise operation xop generator
    proc `xop`*(a: XueValue, b: XueValue): XueValue =
        if a.kind == VALUE_INTEGER and b.kind == VALUE_INTEGER:
            return XueValue(kind: VALUE_INTEGER, integer: op(a.integer, b.integer))
        elif a.kind == VALUE_INTEGER and b.kind == VALUE_DOUBLE:
            return XueValue(kind: VALUE_INTEGER, integer: op(a.integer, cint(b.double)))
        elif a.kind == VALUE_DOUBLE and b.kind == VALUE_INTEGER:
            return XueValue(kind: VALUE_INTEGER, integer: op(cint(a.double), b.integer))
        elif a.kind == VALUE_DOUBLE and b.kind == VALUE_DOUBLE:
            return XueValue(kind: VALUE_INTEGER, integer: op(cint(a.double), cint(b.double)))
        raise newException(ValueError, "cannot perform bitwise operation on non-numbers!")

numberOperation(`+`, `+`, `+`, "cannot perform addition on non-numbers!")
numberOperation(`-`, `-`, `-`, "cannot perform subtraction on non-numbers!")
numberOperation(`*`, `*`, `*`, "cannot perform multiplication on non-numbers!")
numberOperation(`/`, `div`, `/`, "cannot perform division on non-numbers!")
numberOperation(`mod`, `mod`, `mod`, "cannot calculate modulo on non-numbers!")
numberOperation(`^`, `^`, pow, "cannot calculate modulo on non-numbers!")

proc `-`*(value: XueValue): XueValue =
    ## number negation proc - negate a value to negative one
    case value.kind
    of VALUE_INTEGER:
        return XueValue(kind: VALUE_INTEGER, integer: - value.integer)
    of VALUE_DOUBLE:
        return XueValue(kind: VALUE_DOUBLE, double: - value.double)
    of VALUE_CHARACTER:
        return XueValue(kind: VALUE_INTEGER, integer: - (cint)value.character)
    else:
        raise newException(ValueError, "cannot negate non-numbers or non-characters!")

bitOperation(`bitand`, `and`)
bitOperation(`bitor`, `or`)
bitOperation(`bitxor`, `xor`)
bitOperation(`bitshl`, `shl`)
bitOperation(`bitshr`, `shr`)

proc `<`*(a: XueValue, b: XueValue): XueValue =
    ## compare if a is lesser than b.
    if a.kind == VALUE_INTEGER and b.kind == VALUE_INTEGER:
        return XueValue(kind: VALUE_BOOLEAN, boolean: a.integer < b.integer)
    elif a.kind == VALUE_INTEGER and b.kind == VALUE_DOUBLE:
        return XueValue(kind: VALUE_BOOLEAN, boolean: cdouble(a.integer) < b.double)
    elif a.kind == VALUE_DOUBLE and b.kind == VALUE_INTEGER:
        return XueValue(kind: VALUE_BOOLEAN, boolean: a.double < cdouble(b.integer))
    elif a.kind == VALUE_DOUBLE and b.kind == VALUE_DOUBLE:
        return XueValue(kind: VALUE_BOOLEAN, boolean: a.double < b.double)
    elif a.kind == VALUE_CHARACTER and b.kind == VALUE_CHARACTER:
        return XueValue(kind: VALUE_BOOLEAN, boolean: a.character <% b.character)
    raise newException(ValueError, "cannot compare two non-numbers or two characters!")

proc `>`*(a: XueValue, b: XueValue): XueValue =
    ## compare if a is greater than b.
    if a.kind == VALUE_INTEGER and b.kind == VALUE_INTEGER:
        return XueValue(kind: VALUE_BOOLEAN, boolean: a.integer > b.integer)
    elif a.kind == VALUE_INTEGER and b.kind == VALUE_DOUBLE:
        return XueValue(kind: VALUE_BOOLEAN, boolean: cdouble(a.integer) > b.double)
    elif a.kind == VALUE_DOUBLE and b.kind == VALUE_INTEGER:
        return XueValue(kind: VALUE_BOOLEAN, boolean: a.double > cdouble(b.integer))
    elif a.kind == VALUE_DOUBLE and b.kind == VALUE_DOUBLE:
        return XueValue(kind: VALUE_BOOLEAN, boolean: a.double > b.double)
    elif a.kind == VALUE_CHARACTER and b.kind == VALUE_CHARACTER:
        return XueValue(kind: VALUE_BOOLEAN, boolean: a.character <% b.character)
    raise newException(ValueError, "cannot compare two non-numbers or two characters!")

proc bitnot*(value: XueValue): XueValue =
    ## calculate bitwise-not of a value
    case value.kind
    of VALUE_INTEGER:
        return XueValue(kind: VALUE_INTEGER, integer: not value.integer)
    of VALUE_DOUBLE:
        return XueValue(kind: VALUE_INTEGER, integer: not cint(value.double))
    of VALUE_CHARACTER:
        return XueValue(kind: VALUE_INTEGER, integer: not cint(value.character))
    else:
        raise newException(ValueError, "cannot perform bitwise operation on non-numbers!")

proc `not`*(value: XueComposite): XueValue =
    ## calculate logic-not of a composite value
    case value.kind
        of COMPOSITE_LIST:
            return XueValue(kind: VALUE_BOOLEAN, boolean: XueList(value).items.len() == 0)

proc `not`*(value: XueValue): XueValue =
    ## calculate logic-not of a primitive value
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

proc `==`*(a: XueValue, b: XueValue): XueValue =
    ## check if value a and b are equal
    case a.kind
    of VALUE_INTEGER:
        if b.kind == VALUE_INTEGER:
            return XueValue(kind: VALUE_BOOLEAN, boolean: a.integer == b.integer)
        elif b.kind == VALUE_DOUBLE:
            return XueValue(kind: VALUE_BOOLEAN, boolean: cdouble(a.integer) == b.double)
    of VALUE_DOUBLE:
        if b.kind == VALUE_INTEGER:
            return XueValue(kind: VALUE_BOOLEAN, boolean: a.double == cdouble(b.integer))
        elif b.kind == VALUE_DOUBLE:
            return XueValue(kind: VALUE_BOOLEAN, boolean: a.double == b.double)
    else:
        if a.kind != b.kind:
            return XueValue(kind: VALUE_BOOLEAN, boolean: false)
        case a.kind
        of VALUE_BOOLEAN:
            return XueValue(kind: VALUE_BOOLEAN, boolean: a.boolean == b.boolean)
        of VALUE_CHARACTER:
            return XueValue(kind: VALUE_BOOLEAN, boolean: a.character == b.character)
        of VALUE_NULL:
            return XueValue(kind: VALUE_BOOLEAN, boolean: true)
        else:
            return XueValue(kind: VALUE_BOOLEAN, boolean: false)