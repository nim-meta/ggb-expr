 
import std/macros


template toGSeqId: NimNode = ident "toGSeq"

macro ggb*(body) =
  runnableExamples:
    ggb:
      echo {1, 2}
  for iStmt, statement in body:
    if statement.len != 0:
      case statement.kind
      of nnkAsgn:
        let
          sym = statement[0]
          val = statement[1]
        var nStmt = quote do:
          when declared(`sym`):
            `statement`
          else:
            var `sym` = `val`
        body[iStmt] = nStmt
      else:
        for i, ele in statement:
          if ele.kind == nnkCurly:
            var ls = newNimNode nnkBracket
            for i in ele: ls.add i
            let n = newCall(toGSeqId, ls)
            statement[i] = n
  body

