import std/[terminal, exitprocs]

proc moveDown() = 
  cursorDown()

proc moveUp() = 
  cursorUp()

proc moveRight() =
  cursorForward()

proc moveLeft() =
  cursorBackward()

proc handleInput(ch: char) = 
  case ch:
  of 'j':
    moveDown()
  of 'k':
    moveUp()
  of 'l':
    moveRight()
  of 'h':
    moveLeft()
  of 'q':
    quit()
  else:
    discard

exitprocs.addExitProc(resetAttributes)
eraseScreen()
#for i in 0..100:
#  stdout.styledWriteLine(fgRed, "0% ", fgWhite, '#'.repeat i, if i > 50: fgGreen else: fgYellow, "\t", $i , "%") fffffffffffffffffffffffffff
#  sleep 42
#  cursorUp 1
#  eraseLine()
setCursorPos(0, 0)
let entireFile = readFile("main.nim")
echo entireFile
setCursorPos(0, 0)
while true:
  getch().handleInput()
