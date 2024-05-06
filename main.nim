import std/[terminal, exitprocs, strutils]


type 
  Scroll = object
    down: Natural
    right: Natural

  CursorAlignment = enum Position, End

  Cursor = object
    y: Natural
    case alignment: CursorAlignment
    of Position: x: Natural
    of End: discard 

  TerminalBuffer = ref object
    width: int
    height: int
    buf: seq[string]
    cursor: Cursor
    scroll: Scroll


func handleInput(tb: TerminalBuffer, ch: char): TerminalBuffer = 
  case ch:
  of 'j':
    if tb.buf.len <= tb.cursor.y + 1:
      tb.cursor.y = tb.buf.len - 1
    else:
      tb.cursor.y += 1
  of 'k':
    if tb.cursor.y == 0:
      tb.cursor.y = 0
    else:
      tb.cursor.y -= 1
  of 'l':
    case tb.cursor.alignment:
    of Position:
      let lineLen = tb.buf[tb.cursor.y].len()
      if tb.cursor.x + 1 > lineLen:
        tb.cursor.x = lineLen
      elif tb.cursor.x + 1 < 0:
        tb.cursor.x = 0
      else:
        tb.cursor.x += 1
    of End: discard
  of 'h':
    let lineLen = tb.buf[tb.cursor.y].len()
    case tb.cursor.alignment:
    of Position:
      if tb.cursor.x - 1 > lineLen:
        if lineLen > 0:
          tb.cursor.x = lineLen - 1
        else:
          tb.cursor.x = 0
      elif tb.cursor.x - 1 < 0:
        tb.cursor.x = 0
      else:
        tb.cursor.x -= 1
    of End:
      tb.cursor.alignment = Position
      if lineLen == 0:
        tb.cursor.x = 0
      else:
        tb.cursor.x = lineLen - 1
  of 'q':
    quit()
  else: discard

  return tb

proc createTerminalBuffer(width, height: Natural): TerminalBuffer =
  let tb: TerminalBuffer = TerminalBuffer()
  tb.width = width
  tb.height = height
  newSeq(tb.buf, height)
  tb.cursor.alignment = Position
  tb.cursor.x = 0
  tb.cursor.y = 0
  return tb


func getVisibleBuffer(tb: TerminalBuffer): seq[string] = 
  # not implemented
  result = tb.buf

proc flushTerminalBuffer(tb: TerminalBuffer) =
  eraseScreen()
  for i, line in tb.getVisibleBuffer():
    setCursorPos(0, i)
    stdout.write(line)
  case tb.cursor.alignment:
  of Position:
    if tb.cursor.x > tb.buf[tb.cursor.y].len:
      setCursorPos(tb.buf[tb.cursor.y].len, tb.cursor.y)
    else:
      setCursorPos(tb.cursor.x, tb.cursor.y)
  of End:
    setCursorPos(tb.buf[tb.cursor.y].len, tb.cursor.y)

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
