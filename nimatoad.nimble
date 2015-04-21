[Package]
name          = "nimatoad"
version       = "0.1.0"
author        = "Aaron Bentley and @polkm1"
description   = "A game engine written in Nim, that uses SDL2 and OpenGL."
license       = "MIT"

bin = "src/nimatoad"

[Deps]
Requires: """
  nim >= 0.10.0
  sdl2 >= 1.0
  opengl >= 1.0
"""
