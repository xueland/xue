import tokenizer

proc parse*(tokens: seq[XueToken]) =
    ## parse tokens to AST for later code generation
    for token in tokens:
        echo token