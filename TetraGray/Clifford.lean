import TetraGray.Basic
-- import Mathlib.Group.Init.ZeroOne

def _root_.Array.replicate {a : Type} (length : Nat) (default : a) : Array a :=
  Array.mk (List.replicate length default)

namespace MultiVector

/-- NumericalArray structure -/
structure NumericalArray (a : Type := Float) (length : Nat) where
  /-- The raw data -/
  values : Array a
  /-- Proof that the length is the same as the size of the array -/
  _pf_length : values.size = length := by sorry
  deriving Repr




namespace TetraGray

/-- A vector in 4D space -/
structure Vec4 where
  /-- Time component -/
  t : Float := 0
  /-- X component -/
  x : Float := 0
  /-- Y component -/
  y : Float := 0
  /-- Z component -/
  z : Float := 0
deriving Repr, BEq, Inhabited

/--space basis vector-/
def x :Vec4 := { x:=1 }
/--space basis vector-/
def y :Vec4 := { y := 1 }
/--space basis vector-/
def z :Vec4 := { z:=1 }
/--time basis vector-/
def t : Vec4 := { t:=1 }

/-- A bivector in 4D space -/
structure Bivec4 where
  /-- Time-X plane component -/
  tx : Float := 0
  /-- Time-Y plane component -/
  ty : Float := 0
  /-- Time-Z plane component -/
  tz : Float := 0
  /-- X-Y plane component -/
  xy : Float := 0
  /-- X-Z plane component -/
  xz : Float := 0
  /-- Y-Z plane component -/
  yz : Float := 0
deriving Repr, BEq, Inhabited



-- TODO use girving's floating library for ord and stuff

/-- A trivector in 4D space -/
structure Trivec4 where
  txy : Float := 0
  txz : Float := 0
  tyz : Float := 0
  xyz : Float := 0
deriving Repr, BEq, Inhabited --, Ord

structure Quadvec4 where
  txyz : Float := 0
deriving Repr, BEq, Inhabited

structure Multivector4 where
  scalar : Float := 0
  vector : Vec4 := default
  bivector : Bivec4 := default
  trivector : Trivec4 := default
  quadvector : Quadvec4 := default
deriving Repr, BEq, Inhabited

instance : OfNat Vec4 0 where
  ofNat := default

instance : OfNat Bivec4 0 where
  ofNat := default

instance : OfNat Trivec4 0 where
  ofNat := default

instance : OfNat Quadvec4 0 where
  ofNat := default

instance : OfNat Multivector4 0 where
  ofNat := default

instance : Coe Float Multivector4 where
  coe s := { scalar := s}
instance : Coe Vec4 Multivector4 where
  coe v := { vector := v}
instance : Coe Bivec4 Multivector4 where
  coe b := { bivector := b}
instance : Coe Trivec4 Multivector4 where
  coe t := { trivector := t}
instance : Coe Quadvec4 Multivector4 where
  coe q := { quadvector := q}

/-- A point in 4D space -/
structure Point4 where
  coords : Vec4 := default
deriving Repr, BEq, Inhabited

/-- A direction in 4D space -/
structure Dir4 where
  vec : Vec4 := default
deriving Repr, BEq, Inhabited

/-- RGB color representation -/
structure Color where
  /-- Red component -/
  r : Float := 0
  /-- Green component -/
  g : Float := 0
  /-- Blue component -/
  b : Float := 0
  deriving Repr, BEq, Inhabited


/-- ZipWith for Vec4 -/
def Vec4.zipWith (f : Float → Float → Float) (v1 v2 : Vec4) : Vec4 :=
  { t := f v1.t v2.t, x := f v1.x v2.x, y := f v1.y v2.y, z := f v1.z v2.z }

/-- ZipWith for Bivec4 -/
def Bivec4.zipWith (f : Float → Float → Float) (b1 b2 : Bivec4) : Bivec4 :=
  { tx := f b1.tx b2.tx, ty := f b1.ty b2.ty, tz := f b1.tz b2.tz,
    xy := f b1.xy b2.xy, xz := f b1.xz b2.xz, yz := f b1.yz b2.yz }

/-- ZipWith for Trivec4 -/
def Trivec4.zipWith (f : Float → Float → Float) (t1 t2 : Trivec4) : Trivec4 :=
  { txy := f t1.txy t2.txy, txz := f t1.txz t2.txz,
    tyz := f t1.tyz t2.tyz, xyz := f t1.xyz t2.xyz }

/-- ZipWith for Quadvec4 -/
def Quadvec4.zipWith (f : Float → Float → Float) (q1 q2 : Quadvec4) : Quadvec4 :=
  { txyz := f q1.txyz q2.txyz }

def Multivector4.zipWith (f : Float → Float → Float) (m1 m2 : Multivector4) : Multivector4 :=
  { scalar := f m1.scalar m2.scalar, vector := m1.vector.zipWith f m2.vector, bivector := m1.bivector.zipWith f m2.bivector, trivector := m1.trivector.zipWith f m2.trivector, quadvector := m1.quadvector.zipWith f m2.quadvector }

/-- Map for Vec4 -/
def Vec4.map (f : Float → Float) (v : Vec4) : Vec4 :=
  { t := f v.t, x := f v.x, y := f v.y, z := f v.z }

/-- Map for Bivec4 -/
def Bivec4.map (f : Float → Float) (b : Bivec4) : Bivec4 :=
  { tx := f b.tx, ty := f b.ty, tz := f b.tz,
    xy := f b.xy, xz := f b.xz, yz := f b.yz }

/-- Map for Trivec4 -/
def Trivec4.map (f : Float → Float) (t : Trivec4) : Trivec4 :=
  { txy := f t.txy, txz := f t.txz,
    tyz := f t.tyz, xyz := f t.xyz }

/-- Map for Quadvec4 -/
def Quadvec4.map (f : Float → Float) (q : Quadvec4) : Quadvec4 :=
  { txyz := f q.txyz }

/-- Map a function over a Multivector4 -/
def Multivector4.map (f : Float → Float) (m : Multivector4) : Multivector4 :=
  { scalar := f m.scalar, vector := m.vector.map f, bivector := m.bivector.map f, trivector := m.trivector.map f, quadvector := m.quadvector.map f }

/-- Scalar multiplication on the left -/
instance [HMul scalar Float Float] : HMul scalar Multivector4 Multivector4 where
  hMul a v := v.map (a * ·)

/-- Scalar multiplication on the right -/
instance [HMul Float scalar Float] : HMul Vec4 scalar Vec4 where
  hMul v a := v.map (· * a)

/-- Scalar division is only defined on the right to avoid any ambiguity about what it means -/
instance [HDiv Float scalar Float] : HDiv Multivector4 scalar Multivector4 where
  hDiv m a := m.map (· / a)

instance : Neg Multivector4 where
  neg m := m.map Neg.neg

instance : Add Multivector4 where
  add a b := a.zipWith (· + ·) b

instance: Sub Multivector4 where
  sub a b := a + (-b)

/-- Inner (dot) product between vectors. Time has negative signature, space positive. -/
def Vec4.dot (v₁ v₂ : Vec4) : Float :=
  -- Minkowski metric: (-,+,+,+)
  -v₁.t * v₂.t + v₁.x * v₂.x + v₁.y * v₂.y + v₁.z * v₂.z

/-- Outer (wedge) product between vectors -/
def Vec4.wedge (v₁ v₂ : Vec4) : Bivec4 := {
  tx := v₁.t * v₂.x - v₁.x * v₂.t,
  ty := v₁.t * v₂.y - v₁.y * v₂.t,
  tz := v₁.t * v₂.z - v₁.z * v₂.t,
  xy := v₁.x * v₂.y - v₁.y * v₂.x,
  xz := v₁.x * v₂.z - v₁.z * v₂.x,
  yz := v₁.y * v₂.z - v₁.z * v₂.y
}

/-- Dot product operator -/
infixl:70 " ⋅ " => Vec4.dot

/-- Wedge product operator -/
infixl:70 " ∧ " => Vec4.wedge

/-- Geometric product -/
instance : Mul Multivector4 where
  mul a b :=
  /-
  TEST_XS = 1e₀ + 2e₁ + 3e₂ + 4e₃
  TEST_YS = 5e₀ + 6e₁ + 7e₂ + 8e₃

  Scalar part should be dot product:
  -(1*5) + 2*6 + 3*7 + 4*8
  = -5 + 12 + 21 + 32
  = 60
  -/
  let s₁ := a.scalar
  let v₁ := a.vector
  let b₁ := a.bivector
  let t₁ := a.trivector
  let q₁ := a.quadvector

  let s₂ := b.scalar
  let v₂ := b.vector
  let b₂ := b.bivector
  let t₂ := b.trivector
  let q₂ := b.quadvector

  -- Common subexpressions
  let v₁₂Inner := v₁ ⋅ v₂  -- This gives the correct +60 for test case
  let v₁₂Outer := v₁ ∧ v₂

  let b₁₂ := b₁.tx * b₂.tx + b₁.ty * b₂.ty + b₁.tz * b₂.tz
             + b₁.xy * b₂.xy + b₁.xz * b₂.xz + b₁.yz * b₂.yz

  let t₁₂ := t₁.txy * t₂.txy + t₁.txz * t₂.txz + t₁.tyz * t₂.tyz + t₁.xyz * t₂.xyz

  -- Scalar part
  let scalar := s₁ * s₂ + v₁₂Inner + b₁₂ + t₁₂ + q₁.txyz * q₂.txyz

  -- Vector part common terms
  let v_b₁v₂ := (b₁.tx * v₂.x + b₁.ty * v₂.y + b₁.tz * v₂.z)
  let v_v₁b₂ := (v₁.x * b₂.tx + v₁.y * b₂.ty + v₁.z * b₂.tz)

  let vector := {
    t := s₁ * v₂.t + v₁.t * s₂ + v_b₁v₂ + v_v₁b₂,
    x := s₁ * v₂.x + v₁.x * s₂ + (b₁.tx * v₂.t + b₁.xy * v₂.y + b₁.xz * v₂.z)
         + (v₁.t * b₂.tx + v₁.y * b₂.xy + v₁.z * b₂.xz),
    y := s₁ * v₂.y + v₁.y * s₂ + (b₁.ty * v₂.t - b₁.xy * v₂.x + b₁.yz * v₂.z)
         + (v₁.t * b₂.ty - v₁.x * b₂.xy + v₁.z * b₂.yz),
    z := s₁ * v₂.z + v₁.z * s₂ + (b₁.tz * v₂.t - b₁.xz * v₂.x - b₁.yz * v₂.y)
         + (v₁.t * b₂.tz - v₁.x * b₂.xz - v₁.y * b₂.yz)
  }

  -- Bivector part
  let bivector := {
    tx := s₁ * b₂.tx + b₁.tx * s₂ + v₁₂Outer.tx,
    ty := s₁ * b₂.ty + b₁.ty * s₂ + v₁₂Outer.ty,
    tz := s₁ * b₂.tz + b₁.tz * s₂ + v₁₂Outer.tz,
    xy := s₁ * b₂.xy + b₁.xy * s₂ + v₁₂Outer.xy,
    xz := s₁ * b₂.xz + b₁.xz * s₂ + v₁₂Outer.xz,
    yz := s₁ * b₂.yz + b₁.yz * s₂ + v₁₂Outer.yz
  }

  -- Trivector part common terms
  let t_v₁b₂_xy := v₁.t * b₂.xy - v₁.x * b₂.ty + v₁.y * b₂.tx
  let t_b₁v₂_xy := b₁.xy * v₂.t - b₁.ty * v₂.x + b₁.tx * v₂.y

  let trivector := {
    txy := s₁ * t₂.txy + t₁.txy * s₂ + t_v₁b₂_xy + t_b₁v₂_xy,
    txz := s₁ * t₂.txz + t₁.txz * s₂
           + (v₁.t * b₂.xz - v₁.x * b₂.tz + v₁.z * b₂.tx)
           + (b₁.xz * v₂.t - b₁.tz * v₂.x + b₁.tx * v₂.z),
    tyz := s₁ * t₂.tyz + t₁.tyz * s₂
           + (v₁.t * b₂.yz - v₁.y * b₂.tz + v₁.z * b₂.ty)
           + (b₁.yz * v₂.t - b₁.tz * v₂.y + b₁.ty * v₂.z),
    xyz := s₁ * t₂.xyz + t₁.xyz * s₂
           + (v₁.x * b₂.yz - v₁.y * b₂.xz + v₁.z * b₂.xy)
           + (b₁.yz * v₂.x - b₁.xz * v₂.y + b₁.xy * v₂.z)
  }

  -- Quadvector part common terms
  let q_v₁t₂ := v₁.t * t₂.xyz - v₁.x * t₂.tyz + v₁.y * t₂.txz - v₁.z * t₂.txy
  let q_t₁v₂ := t₁.xyz * v₂.t - t₁.tyz * v₂.x + t₁.txz * v₂.y - t₁.txy * v₂.z

  let quadvector := {
    txyz := s₁ * q₂.txyz + q₁.txyz * s₂ + q_v₁t₂ + q_t₁v₂
  }

  { scalar := scalar
    vector := vector
    bivector := bivector
    trivector := trivector
    quadvector := quadvector }


def TEST_XS : Multivector4 := { vector := { t := 1, x := 2, y := 3, z := 4 } }
def TEST_YS : Multivector4 := { vector := { t := 5, x := 6, y := 7, z := 8 } }

#eval
  let prod := TEST_XS * TEST_YS
  -- dot + wedge should work in this case since they're just vectors
  let dot:Multivector4 := TEST_XS.vector ⋅ TEST_YS.vector
  let wedge:Multivector4 := TEST_XS.vector ∧ TEST_YS.vector
  let total := dot + wedge
  prod - total

-- TODO verify
-- TODO: test cases




#eval x ⋅ y
#eval x ∧ y





/-- Factorial, evaluated naively -/
def factorial (n : Nat) : Nat :=
  match n with
  | 0 => 1
  | n + 1 => (n + 1) * factorial n

/-- Binomial coefficient, evaluated naively -/
def _root_.Nat.choose (n : Nat) (k : Nat) : Nat :=
  if k > n then 0
  else factorial n / (factorial k * factorial (n - k))

#eval (4).choose 3


/-- Pure scalar -/
abbrev Scalar a := NumericalArray a ((4).choose 0)

instance : Coe a (Scalar a) where
  coe a := { values := #[a]}

/-- Pure vector -/
abbrev Vector a := NumericalArray a ((4).choose 1)
/-- Pure bivector -/
abbrev Bivector a := NumericalArray a ((4).choose 2)
/-- Pure trivector -/
abbrev Trivector a := NumericalArray a ((4).choose 3)
/-- Pure quadvector -/
abbrev Quadvector a := NumericalArray a ((4).choose 4)
/-- Pseudoscalar in 4D -/
abbrev Pseudoscalar a := Quadvector a
/--Even-graded multivector, i.e. scalar + bivector + quadvector -/
abbrev Versor a := NumericalArray a ((4).choose 0 + (4).choose 2 + (4).choose 4)

instance : Coe (Scalar a) (Versor a) where
  coe xs := { values := xs.values}

instance : Coe (Bivector a) (Versor a) where
  coe xs := { values := xs.values}

instance : Coe (Quadvector a) (Versor a) where
  coe xs := { values := xs.values}


instance : Coe (NumericalArray a ((4).choose 2)) (Bivector a) where
  coe xs := { values := xs.values}

#eval! (NumericalArray.mk #[1.0, 2.0, 3.0, 4.0, 5.0, 6.0] : Bivector Float)



def Versor.bivectorPart (xs : Versor a) : Bivector a :=
  { values := xs.values.extract 1 6 }

/-- Inner product (contraction) between vectors.
    This implements the Minkowski inner product with signature (-,+,+,+).
    For vectors v1 = (t,x,y,z) and v2 = (t',x',y',z'), returns:
    -tt' + xx' + yy' + zz'

    This signature makes time-like vectors have negative norm squared,
    while space-like vectors have positive norm squared.
    Null/light-like vectors have zero norm squared. -/
def Vector.inner (v1 v2 : Vector α) [Mul α] [Sub α] [Add α] [Neg α] : α :=
  -v1[0] * v2[0] + v1[1] * v2[1] + v1[2] * v2[2] + v1[3] * v2[3]

/-- Inner product between bivectors -/
def Bivector.inner (b1 b2 : Bivector α) [Mul α] [Sub α] [Add α] [Neg α] : α :=
  b1[0] * b2[0] + b1[1] * b2[1] - b1[2] * b2[2] + b1[3] * b2[3] - b1[4] * b2[4] - b1[5] * b2[5]

/-- Inner product between versors -/
def Versor.inner (e1 e2 : Versor α) [Mul α] [Sub α] [Add α] [Neg α] : α :=
  e1[0] * e2[0] - e1[7] * e2[7] + (e1.bivectorPart.inner e2.bivectorPart)

/-- Notation for inner product using dot symbol -/
infixl:75 " ⋅1 " => Vector.inner
infixl:75 " ⋅2 " => Bivector.inner
infixl:75 " ⋅even " => Versor.inner
#eval! (TEST_XS : Vector Float) ⋅1 TEST_YS

-- TODO use Vector4/bivector4 etc for names and unambiguous signature

end NumericalArray
end MultiVector
