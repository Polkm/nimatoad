import matrix

type Entity* = object of RootObj
  matrix*: Mat4

proc newEntity*(): ref Entity = new Entity
