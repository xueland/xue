import unicode

type
    XueValueKind* = enum
        ## list of value kinds: notval, null, bool, int, char, double and others.
        VALUE_NOTVAL,
        VALUE_NULL,
        VALUE_BOOLEAN,
        VALUE_INTEGER,
        VALUE_CHARACTER,
        VALUE_DOUBLE,
        VALUE_COMPOSITE

    XueValue* = object
        ## xue value struct using kind and value union
        case kind*: XueValueKind
        of VALUE_NOTVAL, VALUE_NULL:
            discard
        of VALUE_BOOLEAN:
            boolean*: bool
        of VALUE_INTEGER:
            integer*: cint
        of VALUE_DOUBLE:
            double*: cdouble
        of VALUE_CHARACTER:
            character*: Rune
        of VALUE_COMPOSITE:
            composite*: XueComposite

    XueCompositeKind* = enum
        ## kinds of composite value: list, etc.
        COMPOSITE_LIST

    XueComposite* = ref object of RootObj
        ## just a composite base struct with "kind" member.
        kind*: XueCompositeKind

    XueList* = ref object of XueComposite
        ## list value - contains lists of XueValue
        items*: seq[XueValue]
