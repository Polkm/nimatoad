import entity, model, ship

proc update*(dt: float) =
  for ent in entities:
    ent.update(dt)
