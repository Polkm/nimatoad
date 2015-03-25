import glfw/glfw, opengl, glx

glfw.init()
var win = newGLWin()
win.makeContextCurrent()

loadExtensions() # What is this black magic, opengl related for sure

var shaderProgram: TGLuint
glx.setup(shaderProgram)

while not win.shouldClose:
  glx.draw()

  win.swapBufs()

  pollEvents()

win.destroy()
glfw.terminate()
