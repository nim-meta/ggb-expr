
import std/sequtils

type
  GSeq*[T] = distinct seq[T]

converter toNimSeq[T](self: GSeq[T]): seq[T] = seq[T] self
func toGSeq*[T](s: seq[T]): GSeq[T] = GSeq[T] s

using self: GSeq
proc Length*(self): int = len self
proc Elememt*[T](self: GSeq[T], position: Positive): T = self[position-1]
proc `$`*(self): string =
  let le = Length(self)
  if le == 0:
    return "{}"
  result = newStringOfCap(le * 3)
  result.add "{"
  for i in 0..self.len - 2:
    result.add $self[i]
    result.add ", "
  result.add "}"

template toGSeq*(x: not seq): GSeq =
  bind toSeq, toGSeq
  toGSeq toSeq x
template newGSeq*[T](): GSeq[T] =
  bind toGSeq
  newSeq[T]().toGSeq
func newGSeqOfCap*[T](cap: int): GSeq[T] = newSeqOfCap[T](cap).toGSeq

iterator countUpDown[T](Start, End: T, increment: int): T =
  if increment > 0:
    for i in countup(Start, End, increment):
      yield i
  else:
    for i in countdown(Start, End, -increment):
      yield i

#[ If so, cannot compile, see https://github.com/nim-lang/Nim/issues/23662
template Sequence*[T](End: T): GSeq[T] = bind toSeq; toSeq 1..End
template Sequence*[T](Start, End: T): GSeq[T] = bind toSeq; toSeq Start..End
template Sequence*[T](Start, End: T, increment: int): GSeq[T] =
  bind toSeq, countUpDown; toSeq countUpDown(Start, End, increment) ]#

template Sequence*(End): GSeq = bind toSeq; toSeq 1..End
template Sequence*(Start, End): GSeq = bind toSeq; toSeq Start..End
template Sequence*(Start, End; increment: int): GSeq =
  runnableExamples:
    echo Sequence(1, 10, 2)
  bind toSeq, countUpDown;
  toGSeq countUpDown(Start, End, increment)

template Sequence*(Expression: untyped, Variable: untyped, Start, End: typed, increment: int): GSeq =
  runnableExamples:
    echo Sequence(i*i, i, 1, 10, 2)
  bind newGSeqOfCap
  let  # prevent multiply eval
    tEnd = End
    tStart = Start
    tIncr = increment

  template getExprType: untyped =
    typeof (for Variable in countup(tStart, tEnd): Expression)
  var res = newGSeqOfCap[getExprType]( 1 + (tEnd.ord - tStart.ord) div tIncr )
  for Variable in countUpDown(tStart, tEnd, tIncr):
    res.add Expression
  res

template Sequence*(Expression: untyped, Variable: untyped, Start, End: typed): GSeq =
  runnableExamples:
    echo Sequence(i*i, i, 1, 10)
  bind newGSeqOfCap
  let  # prevent multiply eval
    tEnd = End
    tStart = Start

  template getExprType: untyped =
    typeof (for Variable in countup(tStart, tEnd): Expression)
  var res = newGSeqOfCap[getExprType]( 1 + (tEnd.ord - tStart.ord)  )
  for Variable in countup(tStart, tEnd):
    res.add Expression
  res

