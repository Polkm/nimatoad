import sdl2, glx

var windowTitle* = "Nimatoad"
var screenWidth*: cint = 640
var screenHeight*: cint = 480

var window*: WindowPtr
var context*: GlContextPtr

# Frame rate limiter
let targetFramePeriod: uint32 = 20 # 20 milliseconds corresponds to 50 fps
var frameTime: uint32 = 0
proc limitFrameRate() =
  let now = getTicks()
  if frameTime > now:
    delay(frameTime - now) # Delay to maintain steady frame rate
  frameTime += targetFramePeriod

proc draw*() =
  glx.draw()
  window.glSwapWindow() # Swap the front and back frame buffers (double buffering)

proc init*() =
  discard sdl2.init(INIT_EVERYTHING)
  window = createWindow(windowTitle, 100, 100, screenWidth, screenHeight, SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE)
  context = window.glCreateContext()
  glx.init()
  glx.reshape(screenWidth, screenHeight)

  var
    evt = sdl2.defaultEvent
    runGame = true

  while runGame:
    while pollEvent(evt):
      if evt.kind == QuitEvent:
        runGame = false
        break
      if evt.kind == WindowEvent:
        var windowEvent = cast[WindowEventPtr](addr(evt))
        if windowEvent.event == WindowEvent_Resized:
          let newWidth = windowEvent.data1
          let newHeight = windowEvent.data2
          glx.reshape(newWidth, newHeight)

    draw()

    limitFrameRate()

  destroy sdlx.window
