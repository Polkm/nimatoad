import ship

proc update*(dt: float) =
  for sh in ships:
    sh.update(dt)
