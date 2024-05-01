import std/[terminal, exitprocs, strutils]


type 
  Scroll = object
    down: Natural
    right: Natural

  TerminalBuffer = ref object
    width: int
    height: int
    buf: seq[string]
    cursorX: Natural
    cursorY: Natural
    scroll: Scroll

proc positionCursorTerminalBuffer(tb: TerminalBuffer, x, y: Natural): TerminalBuffer =
  if y >= tb.buf.len():
    tb.cursorY = tb.buf.len()
  else:
    tb.cursorY = y
  let lineLen = tb.buf[tb.cursorY].len()
  if x >= lineLen:
    tb.cursorX = lineLen
  else:
    tb.cursorX = x
  return tb

func handleInput(tb: TerminalBuffer, ch: char): TerminalBuffer = 
  var currX: Natural = tb.cursorX
  var currY: Natural = tb.cursorY
  case ch:
  of 'j':
    currY += 1
  of 'k':
    currY -= 1
  of 'l':
    currX += 1
  of 'h':
    currX -= 1
  of 'q':
    quit()
  else:
    return tb
  return tb.positionCursorTerminalBuffer(currX, currY)

proc createTerminalBuffer(width, height: Natural): TerminalBuffer =
  let tb: TerminalBuffer = TerminalBuffer()
  tb.width = width
  tb.height = height
  newSeq(tb.buf, height)
  tb.cursorX = 0
  tb.cursorY = 0
  return tb


func getVisibleBuffer(tb: TerminalBuffer): seq[string] = 
  # not implemented
  result = tb.buf

proc flushTerminalBuffer(tb: TerminalBuffer) =
  eraseScreen()
  for i, line in tb.getVisibleBuffer():
    setCursorPos(0, i)
    stdout.write(line)
  setCursorPos(tb.cursorX, tb.cursorY)

func inputTerminalBuffer(tb: TerminalBuffer, input: seq): TerminalBuffer =
  tb.buf = input
  return tb


exitprocs.addExitProc(resetAttributes)
eraseScreen()
#for i in 0..100:
#  stdout.styledWriteLine(fgRed, "0% ", fgWhite, '#'.repeat i, if i > 50: fgGreen else: fgYellow, "\t", $i , "%") fffffffffffffffffffffffffff
#  sleep 42
#  cursorUp 1
#  eraseLine()

setCursorPos(0, 0)
echo readFile("main.nim").type()
let entireFile = readFile("main.nim")
var tb: TerminalBuffer = 
  createTerminalBuffer(width=terminalWidth(), height=terminalHeight()).inputTerminalBuffer(entireFile.split('\n'))
# tb = tb.inputTerminalBuffer(entireFile.split('\n'))
while true:
  tb = tb.handleInput(getch())
  tb.flushTerminalBuffer()
