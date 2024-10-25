import TetraGray.Basic
import Batteries.Data.Rat
import Aesop
-- TODO use girving's floating library for ord and stuff

@[simp]
theorem float_plus_zero_eq_self (a : Float) : a + 0.0 = a := by sorry
theorem float_plus_default_eq_self (a : Float) : a + 0 = a := by sorry

abbrev Scalar := Float

def _root_.Array.replicate {a : Type} (length : Nat) (default : a) : Array a :=
  ⟨List.replicate length default⟩

namespace TetraGray.Multivector


/-- A vector in 4D spacetime. time, x, y, z. time has negative metric, space has positive metric -/
@[ext] structure Vec4 where (t x y z : Float := 0) deriving Repr, BEq, Inhabited
/-- A bivector in 4D spacetime -/
@[ext] structure Bivec4 where (tx ty tz xy xz yz : Float := 0) deriving Repr, BEq, Inhabited
/-- A trivector in 4D spacetime -/
@[ext] structure Trivec4 where (txy txz tyz xyz : Float := 0) deriving Repr, BEq, Inhabited
/--A pseudoscalar in 4D spacetime-/
@[ext] structure Quadvec4 where (txyz : Float := 0) deriving Repr, BEq, Inhabited


instance : OfNat Vec4 0 where ofNat := default
instance : OfNat Bivec4 0 where ofNat := default
instance : OfNat Trivec4 0 where ofNat := default
instance : OfNat Quadvec4 0 where ofNat := default


/-- a versor is an even-grade multivector -/
@[ext] structure Versor where
  scalar: Float := 0
  bivector: Bivec4 := 0
  quadvector: Quadvec4 := 0
deriving Repr,Inhabited,BEq

/-- A general multivector in 4D spacetime -/
structure Multivector4 where
  scalar : Float := 0
  vector : Vec4 := 0
  bivector : Bivec4 := 0
  trivector : Trivec4 := 0
  quadvector : Quadvec4 := 0
deriving Repr, BEq, Inhabited


/--space basis vector-/
def x :Vec4 := { x:=1 }
/--space basis vector-/
def y :Vec4 := { y := 1 }
/--space basis vector-/
def z :Vec4 := { z:=1 }
/--time basis vector-/
def t : Vec4 := { t:=1 }
/-- bivector basis blades -/
def tx : Bivec4 := { tx := 1 }
def ty : Bivec4 := { ty := 1 }
def tz : Bivec4 := { tz := 1 }
def xy : Bivec4 := { xy := 1 }
def xz : Bivec4 := { xz := 1 }
def yz : Bivec4 := { yz := 1 }
/-- trivector basis blade -/
def txy : Trivec4 := { txy := 1 }
def txz : Trivec4 := { txz := 1 }
def tyz : Trivec4 := { tyz := 1 }
def xyz : Trivec4 := { xyz := 1 }

/-- pseudoscalar basis blade -/
def txyz : Quadvec4 := { txyz := 1 }
def zyxt : Quadvec4 := { txyz := 1 }
/-- scalar basis blade -/
def one : Multivector4 := { scalar := 1 }

instance : OfNat Versor 0 where ofNat := default
instance : OfNat Multivector4 0 where ofNat := default

instance : Coe Float Multivector4 where coe s := { scalar := s}
instance : Coe Float Versor where coe s := { scalar := s}
instance : Coe Vec4 Multivector4 where coe v := { vector := v}
instance : Coe Bivec4 Multivector4 where coe b := { bivector := b}
instance : Coe Versor Multivector4 where coe v := { scalar := v.scalar, bivector := v.bivector, quadvector := v.quadvector }
instance : Coe Trivec4 Multivector4 where coe t := { trivector := t}
instance : Coe Quadvec4 Multivector4 where coe q := { quadvector := q}
instance : Coe Quadvec4 Versor where coe q := { quadvector := q}
instance : Coe Versor Multivector4 where coe v := { scalar := v.scalar, bivector := v.bivector, quadvector := v.quadvector }

/-- A point in 4D space -/
structure Point4 where
  coords : Vec4 := 0
deriving Repr, BEq, Inhabited
/-- A direction in 4D space -/
structure Dir4 where
  vec : Vec4 := 0
deriving Repr, BEq, Inhabited

/-- RGB color representation -/
structure Color where
  /-- Red,green,blue components -/
  (r g b : Float := 0)
deriving Repr, BEq, Inhabited



def Vec4.zipWith (f : Float → Float → Float) (v1 v2 : Vec4) : Vec4 :=
  { t := f v1.t v2.t, x := f v1.x v2.x, y := f v1.y v2.y, z := f v1.z v2.z }


def Bivec4.zipWith (f : Float → Float → Float) (b1 b2 : Bivec4) : Bivec4 :=
  { tx := f b1.tx b2.tx, ty := f b1.ty b2.ty, tz := f b1.tz b2.tz,
    xy := f b1.xy b2.xy, xz := f b1.xz b2.xz, yz := f b1.yz b2.yz }


def Trivec4.zipWith (f : Float → Float → Float) (t1 t2 : Trivec4) : Trivec4 :=
  { txy := f t1.txy t2.txy, txz := f t1.txz t2.txz,
    tyz := f t1.tyz t2.tyz, xyz := f t1.xyz t2.xyz }

def Quadvec4.zipWith (f : Float → Float → Float) (q1 q2 : Quadvec4) : Quadvec4 :=
  { txyz := f q1.txyz q2.txyz }

def Multivector4.zipWith (f : Float → Float → Float) (m1 m2 : Multivector4) : Multivector4 :=
  { scalar := f m1.scalar m2.scalar, vector := m1.vector.zipWith f m2.vector, bivector := m1.bivector.zipWith f m2.bivector, trivector := m1.trivector.zipWith f m2.trivector, quadvector := m1.quadvector.zipWith f m2.quadvector }


def Vec4.map (f : Float → Float) (v : Vec4) : Vec4 :=
  { t := f v.t, x := f v.x, y := f v.y, z := f v.z }


def Bivec4.map (f : Float → Float) (b : Bivec4) : Bivec4 :=
  { tx := f b.tx, ty := f b.ty, tz := f b.tz,
    xy := f b.xy, xz := f b.xz, yz := f b.yz }


def Trivec4.map (f : Float → Float) (t : Trivec4) : Trivec4 :=
  { txy := f t.txy, txz := f t.txz,
    tyz := f t.tyz, xyz := f t.xyz }


def Quadvec4.map (f : Float → Float) (q : Quadvec4) : Quadvec4 :=
  { txyz := f q.txyz }
def Versor.map (f : Float → Float) (v : Versor) : Versor :=
  { scalar := f v.scalar, bivector := v.bivector.map f, quadvector := v.quadvector.map f }
def Versor.zipWith (f : Float → Float → Float) (v1 v2 : Versor) : Versor :=
  { scalar := f v1.scalar v2.scalar, bivector := v1.bivector.zipWith f v2.bivector, quadvector := v1.quadvector.zipWith f v2.quadvector }

def Multivector4.map (f : Float → Float) (m : Multivector4) : Multivector4 :=
  { scalar := f m.scalar, vector := m.vector.map f, bivector := m.bivector.map f, trivector := m.trivector.map f, quadvector := m.quadvector.map f }

-- to get around scalar not defined in the macro
variable (scalar : Type)
/-- Macro to define common algebraic operations (add, mul, neg, sub, div) for blades and multivector-/
macro "#deriveAlgebraicOps" t:ident : command => `(
  instance : Add $t where add a b := (a).zipWith (· + ·) b
  /-- Scalar multiplication on the left -/
  instance [HMul scalar Float Float] : HMul scalar $t $t where hMul a v := v.map (a * ·)
  instance : HMul Nat $t $t where hMul n v := v.map (n.toFloat * ·)
  instance : HMul $t Nat $t where hMul v n := v.map (· * n.toFloat)
  instance : HMul Rat $t $t where hMul a v := v.map (a.toFloat * ·)
  instance : HMul $t Rat $t where hMul v a := v.map (· * a.toFloat)
  /-- Scalar multiplication on the right -/
  instance [HMul Float scalar Float] : HMul $t scalar $t where hMul v a := v.map (· * a)
  instance : Neg $t where neg m := m.map Neg.neg
  instance : Sub $t where sub a b := a + (-b)
  /-- Scalar division is only defined on the right to avoid any ambiguity about what it means -/
  instance [HDiv Float scalar Float] : HDiv $t scalar $t where hDiv m a := m.map (· / a)
)

#deriveAlgebraicOps Vec4
#deriveAlgebraicOps Bivec4
#deriveAlgebraicOps Trivec4
#deriveAlgebraicOps Quadvec4
#deriveAlgebraicOps Versor
#deriveAlgebraicOps Multivector4

#eval txyz+txyz


/-- Inner (dot) product between vectors with metric (t = -, x = +, y = +, z = +). -/
def Vec4.dot (v₁ v₂ : Vec4) : Float := -v₁.t * v₂.t + v₁.x * v₂.x + v₁.y * v₂.y + v₁.z * v₂.z
/-- Dot product notation -/
infixl:70 " ⋅ " => Vec4.dot

/-- Outer (wedge) product between vectors -/
def Vec4.wedge (v₁ v₂ : Vec4) : Bivec4 := {
  tx := v₁.t * v₂.x - v₁.x * v₂.t,
  ty := v₁.t * v₂.y - v₁.y * v₂.t,
  tz := v₁.t * v₂.z - v₁.z * v₂.t,
  xy := v₁.x * v₂.y - v₁.y * v₂.x,
  xz := v₁.x * v₂.z - v₁.z * v₂.x,
  yz := v₁.y * v₂.z - v₁.z * v₂.y
}

/--TODO: if the terms are linearly dependent, the result should be zero

Wedge product.
-/
class Wedge (a b c : Type) where
  wedge : a → b → c

/-- Wedge product notation -/
infixl:70 " ∧g " => Wedge.wedge

instance vec4_wedge : Wedge Vec4 Vec4 Bivec4 where wedge a b := a.wedge b
#eval (y ∧g y : Bivec4)


def Vec4.geometricProduct (a b : Vec4) : Multivector4 :=
  { scalar := -a.t * b.t + a.x * b.x + a.y * b.y + a.z * b.z,
    bivector := {
      tx := a.t * b.x - a.x * b.t,
      ty := a.t * b.y - a.y * b.t,
      tz := a.t * b.z - a.z * b.t,
      xy := a.x * b.y - a.y * b.x,
      xz := a.x * b.z - a.z * b.x,
      yz := a.y * b.z - a.z * b.y
    }
  }


instance : HMul Vec4 Vec4 Multivector4 where
  hMul a b := a.geometricProduct b

def dotwedge (a b : Vec4) : Multivector4 :=
  ↑(a ⋅ b) + ↑(a.wedge b)

-- theorem dotwedge_eq_mul (a b : Vec4) : dotwedge a b = a.geometricProduct b := by rw [dotwedge,Add.add,]
--   simp [dotwedge,Vec4.geometricProduct,Vec4.wedge,Vec4.dot,Inhabited.default,HAdd.hAdd]






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
  let v₁₂Inner : Float := v₁ ⋅ v₂  -- This gives the correct +60 for test case
  let v₁₂Outer :Bivec4 := v₁ ∧g v₂

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

instance : OfScientific Multivector4 where ofScientific mantissa exponentSign decimalExponent := { scalar := Float.ofScientific mantissa exponentSign decimalExponent }

def TEST_XS : Multivector4 := { vector := { t := 1, x := 2, y := 3, z := 4 } }
def TEST_YS : Multivector4 := { vector := { t := 5, x := 6, y := 7, z := 8 } }
#eval t * x == tx
#eval x * t == -tx
#eval
  let prod := TEST_XS * TEST_YS
  -- dot + wedge should work in this case since they're just vectors
  let dot:Multivector4 := TEST_XS.vector ⋅ TEST_YS.vector
  let wedge:Multivector4 := TEST_XS.vector.wedge TEST_YS.vector
  let total := dot + wedge
  prod - total
#eval  x * (2.3 : Multivector4)
-- TODO verify
-- TODO: test cases


def Vec4.reverse (v : Vec4) : Vec4 := v
def Bivec4.reverse (b : Bivec4) : Bivec4 := -b
def Trivec4.reverse (t : Trivec4) : Trivec4 := -t
def Quadvec4.reverse (q : Quadvec4) : Quadvec4 := q

def Vec4.conjugate (v : Vec4) : Vec4 := -v
def Bivec4.conjugate (b : Bivec4) : Bivec4 := b
def Trivec4.conjugate (t : Trivec4) : Trivec4 := -t
def Quadvec4.conjugate (q : Quadvec4) : Quadvec4 := q
def Versor.conjugate (v : Versor) : Versor := v


-- Conjugate/transpose notation
postfix:max "ᵀ" => Vec4.conjugate
postfix:max "ᵀ" => Bivec4.conjugate
postfix:max "ᵀ" => Trivec4.conjugate
postfix:max "ᵀ" => Quadvec4.conjugate
postfix:max "ᵀ" => Versor.conjugate


def Multivector4.conjugate (m : Multivector4) : Multivector4 :=
  { scalar := m.scalar, vector := m.vectorᵀ, bivector := m.bivectorᵀ, trivector := m.trivectorᵀ, quadvector := m.quadvectorᵀ }
postfix:max "ᵀ" => Multivector4.conjugate
-- Reverse notation
prefix:max "~" => Multivector4.reverse
prefix:max "~" => Vec4.reverse
prefix:max "~" => Bivec4.reverse
prefix:max "~" => Trivec4.reverse
prefix:max "~" => Quadvec4.reverse


def Multivector4.reverse (m : Multivector4) : Multivector4 :=
  { scalar := m.scalar, vector := ~m.vector, bivector := ~m.bivector, trivector := ~m.trivector, quadvector := ~m.quadvector }

#eval
  let xy : Multivector4 := { bivector := xy }
  let expr := (3 : Nat) * xy + (xyz:Multivector4) + (zyxt:Multivector4)
  expr.reverse.reverse == expr
-- TODO generate tests with slimcheck
instance : Coe Scalar Versor where
  coe s := {scalar := s}
