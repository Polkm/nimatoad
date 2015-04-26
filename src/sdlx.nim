import sdl2, glx, gui, camera, vector

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

proc init*() =
  discard sdl2.init(INIT_EVERYTHING)
  window = createWindow(windowTitle, 100, 100, screenWidth, screenHeight, SDL_WINDOW_OPENGL or SDL_WINDOW_RESIZABLE)
  context = window.glCreateContext()
  glx.init()
  glx.reshape(screenWidth, screenHeight)

#Handles Mouse Button Input ( LeftMouse, RightMouse, doesn't handle Mousewheel )
proc mouseInput( evt: MouseButtonEventPtr ) =
  # handle all the SDL enums in this handler, that way we don't have to include
  # SDL2 in every file we want to manipulate/utilize input

  var b: int # contains the button code

  case evt.button :
  of ButtonLeft : b = 0
  of ButtonRight : b = 1
  of ButtonMiddle : b = 2
  of ButtonX1 : b = 3
  of ButtonX2 : b = 4
  else : b = 5 # unrecognized input

  if (evt.kind == MouseButtonUp) :
    panelsMouseInput( b, true, evt.x.float, evt.y.float )

  #we might not even need type, but i wrote it out anyways. pressing delete is alot easier


#Handles Single Key Input
proc keyInput( evt: KeyboardEventPtr ) =
  if evt.keysym.sym == K_SPACE:
    echo("You pressed Space")
  if evt.keysym.sym == K_W:
    cameraPoint(camera.pos + vec3(-1, 0, 0), vec3(0, 0, 0))
  if evt.keysym.sym == K_S:
    cameraPoint(camera.pos + vec3(1, 0, 0), vec3(0, 0, 0))


proc run*() =
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

      if evt.kind == KeyDown or evt.kind == KeyUp :
        keyInput(evt.key)
      if evt.kind == MouseButtonDown or evt.kind == MouseButtonUp :
        mouseInput(evt.button)

    glx.drawScene()
    window.glSwapWindow()

    limitFrameRate()

proc destroy*() =
  destroy sdlx.window
