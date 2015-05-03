import math, sdl2, glx, gui, camera, vector, simulator, mainmenu
import global, gui

var windowTitle* = "Nimatoad"

var window*: WindowPtr
var context*: GlContextPtr

var dt*: float

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
  dt = 0.0

  simulator.init()

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

  if (evt.kind == MouseButtonUp):
    if (not mainmenu.cursor):
      panelsMouseInput( b, true, (screenWidth/2).float, (screenHeight/2).float )
    else :
      panelsMouseInput( b, true, evt.x.float, evt.y.float )

  #we might not even need type, but i wrote it out anyways. pressing delete is alot easier

proc mouseMotion( evt: MouseMotionEventPtr ) =
  #Uint8 type;
  #Uint8 state;
  #Uint16 x, y;
  #Sint16 xrel, yrel;
  ShowCursor(mainmenu.cursor)
  if (not mainmenu.cursor):
    cameraEye(camera.pos, max(min(camera.pitch + evt.yrel.float, 89.9), -89.9), camera.yaw + evt.xrel.float)

#Handles Single Key Input
proc keyInput( evt: KeyboardEventPtr ) =
  var action = ""
  case evt.kind
  of KeyDown: action = "start"
  of KeyUp: action = "stop"
  else: action = "else"
  case evt.keysym.sym
  of K_W: simulator.controlInput("forward", action)
  of K_S: simulator.controlInput("back", action)
  of K_A: simulator.controlInput("left", action)
  of K_D: simulator.controlInput("right", action)
  of K_UP: simulator.controlInput("up", action)
  of K_DOWN: simulator.controlInput("down", action)
  of K_LEFT: simulator.controlInput("roll_left", action)
  of K_RIGHT: simulator.controlInput("roll_right", action)
  else: simulator.controlInput("else", action)

  if evt.keysym.sym == K_SPACE:
    if (action == "stop"):
      mainmenu.cursor = not mainmenu.cursor

  if evt.keysym.sym == K_ESCAPE:
    mainmenu.pullup()

let guiDraw = panelsDraw()

proc run*() =
  var
    evt = sdl2.defaultEvent
    runGame = true
    lastTime = getTicks()

  while runGame:
    dt = (getTicks() - lastTime).float / 1000.0
    lastTime = getTicks()

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

      if evt.kind == KeyDown or evt.kind == KeyUp:
        keyInput(evt.key)
      if evt.kind == MouseButtonDown or evt.kind == MouseButtonUp:
        mouseInput(evt.button)
      if evt.kind == MouseMotion:
        mouseMotion(evt.motion)

    simulator.update(dt)

    glx.drawScene()

    guiDraw()

    window.glSwapWindow()

    limitFrameRate()

proc destroy*() =
  destroy sdlx.window
