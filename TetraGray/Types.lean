import TetraGray.Basic

namespace TetraGray

/-- A vector in 4D space -/
structure Vec4 where
  /-- X component -/
  x : Float
  /-- Y component -/
  y : Float
  /-- Z component -/
  z : Float
  /-- Time component -/
  t : Float
  deriving Repr, BEq

/-- A point in 4D space -/
structure Point4 where
  coords : Vec4
  deriving Repr, BEq

/-- A direction in 4D space -/
structure Dir4 where
  vec : Vec4
  deriving Repr, BEq

/-- RGB color representation -/
structure Color where
  /-- Red component -/
  r : Float
  g : Float
  b : Float
  deriving Repr, BEq

end TetraGray
