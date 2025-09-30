set_option relaxedAutoImplicit false

namespace MultiVector

-- TODO import array comprehension

/-- Fix Vector.set to handle setting values of type α -/
def _root_.Vector.setVal {α : Type u} {n : Nat} (v : Vector α n) (i : Nat) (x : α) : Vector α n :=
  if h : i < n then Vector.set v i x h else v

instance [Zero a] : Zero (Vector a n) where
  zero := ⟨Array.replicate n 0, by simp [Array.size_replicate]⟩

#eval! (⟨Array.replicate 3 0, by simp⟩ : Vector Int 3)

def _root_.Nat.factorial (n : Nat) : Nat :=
  match n with
  | 0 => 1
  | n + 1 => (n + 1) * n.factorial

def _root_.Nat.choose (n : Nat) (k : Nat) : Nat :=
  if k > n then 0
  else n.factorial / (k.factorial * (n - k).factorial)


/-- Multivector in 4D, unrolled.
-- 16 = 4 choose 0 + 4 choose 1 + 4 choose 2 + 4 choose 3 + 4 choose 4
--/
abbrev MV4 (a: Type u) := Vector a 16

#eval! (#v[3,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]:MV4 Float)

/-- Accessors for multivector components using +++- xyzt signature -/
def MV4.scalar (mv : MV4 a) : a := mv[0]
def MV4.x (mv : MV4 a) : a := mv[1]
def MV4.y (mv : MV4 a) : a := mv[2]
def MV4.z (mv : MV4 a) : a := mv[3]
def MV4.t (mv : MV4 a) : a := mv[4]
def MV4.xy (mv : MV4 a) : a := mv[5]
def MV4.xz (mv : MV4 a) : a := mv[6]
def MV4.xt (mv : MV4 a) : a := mv[7]
def MV4.yz (mv : MV4 a) : a := mv[8]
def MV4.yt (mv : MV4 a) : a := mv[9]
def MV4.zt (mv : MV4 a) : a := mv[10]
def MV4.xyz (mv : MV4 a) : a := mv[11]
def MV4.xyt (mv : MV4 a) : a := mv[12]
def MV4.xzt (mv : MV4 a) : a := mv[13]
def MV4.yzt (mv : MV4 a) : a := mv[14]
def MV4.xyzt (mv : MV4 a) : a := mv[15]


def BASIS_ONES : MV4 Float := #v[1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1]


variable {A: Type u} [OfNat A 1] [Zero A]
/--x-/
def MV4.e0 : MV4 A := #v[1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

/--x-/
def MV4.e1 : MV4 A := #v[0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

/--y-/
def MV4.e2 : MV4 A := #v[0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0]

/--z-/
def MV4.e3 : MV4 A := #v[0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0]
/--t-/
def MV4.e4 : MV4 A := #v[0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0]

/--xy-/
def MV4.e12 : MV4 A := #v[0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0]

/--xz-/
def MV4.e13 : MV4 A := #v[0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0]

/--xt-/
def MV4.e14 : MV4 A := #v[0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0]

/--yz-/
def MV4.e23 : MV4 A := #v[0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0]

/--yt-/
def MV4.e24 : MV4 A := #v[0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0]

/--zt-/
def MV4.e34 : MV4 A := #v[0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0]

/--xyz-/
def MV4.e123 : MV4 A := #v[0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0]

/--xyt-/
def MV4.e124 : MV4 A := #v[0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0]

/--xzt-/
def MV4.e134 : MV4 A := #v[0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0]

/--yzt-/
def MV4.e234 : MV4 A := #v[0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0]

/--xyzt-/
def MV4.e1234 : MV4 A := #v[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]

#eval
  let mv : MV4 _ := Vector.range 16
  (mv.scalar,
  mv.x,
  mv.y,
  mv.z,
  mv.t,
  mv.xy,
  mv.xz,
  mv.xt,
  mv.yz,
  mv.yt,
  mv.zt,
  mv.xyz,
  mv.xyt,
  mv.xzt,
  mv.yzt,
  mv.xyzt)

/-- String representation of multivector in component form. Assumes ++++- signature -/
instance [ToString a] : Repr (MV4 a) where
  reprPrec mv _ := s!"{mv.scalar} + {mv.x}x + {mv.y}y + {mv.z}z + {mv.t}t + {mv.xy}xy + {mv.xz}xz + {mv.xt}xt + {mv.yz}yz + {mv.yt}yt + {mv.zt}zt + {mv.xyz}xyz + {mv.xyt}xyt + {mv.xzt}xzt + {mv.yzt}yzt + {mv.xyzt}xyzt"


/-Applies a mapping element-wise to a multivector. Should really be wedged to be an outermorphism?-/
instance : Functor (MV4 ·) where
  map f mv := mv.map f


instance [Add a] : Add (MV4 a) where
  add a b :=
    let result := Array.zipWith (· + ·) a.toArray b.toArray
    ⟨result, by
      rw [Array.size_zipWith, a.size_toArray, b.size_toArray]
      rfl⟩


/-- Scalar multiplication on the left -/
instance MV4.leftScalarMul {scalar : Type} [HMul scalar a scalar] : HMul scalar (MV4 a) (MV4 scalar) where
  hMul a v := v.map (a * ·)

/-- Scalar multiplication on the right -/
instance MV4.rightScalarMul {scalar : Type} [HMul a scalar scalar] : HMul (MV4 a) scalar (MV4 scalar) where
  hMul v a := v.map (· * a)

instance MV4.neg [Neg a] : Neg (MV4 a) where
  neg a := a.map Neg.neg

instance MV4.sub [Add a] [Neg a] : Sub (MV4 a) where
  sub a b := a + (-b)

/-- Scalar division is only defined on the right to avoid any ambiguity about what it means -/
instance MV4.scalarDiv {scalar : Type} [HDiv a scalar a] : HDiv (MV4 a) scalar (MV4 a) where
  hDiv xs a := xs.map (· / a)

/--Lift a scalar to a multivector -/
instance [Zero a] [OfNat a 1] : Coe a (MV4 a) where
  coe x := #v[x,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

/-- Lift a scalar to a multivector -/
instance MV4.ofNat [OfNat a n] [OfNat a 1][Zero a]: OfNat (MV4 a) n where
  ofNat := #v[OfNat.ofNat n,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

instance MV4.ofScientific [Zero a][OfScientific a ] : OfScientific (MV4 a) where
  ofScientific mantissa exponentSign decimalExponent := #v[OfScientific.ofScientific mantissa exponentSign decimalExponent,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

#eval (2.3:MV4 Float)
/-- Inner product (contraction) between vectors.
    This implements the Minkowski inner product with signature (-,+,+,+).
    For vectors v1 = (t,x,y,z) and v2 = (t',x',y',z'), returns:
    -tt' + xx' + yy' + zz'

    This signature makes time-like vectors have negative norm squared,
    while space-like vectors have positive norm squared.
    Null/light-like vectors have zero norm squared.

    XXX: This is not the contraction of multivectors, but just of vectors.
    -/
def MV4.inner {α : Type u} [Mul α] [Sub α] [Add α] [Neg α] (v1 v2 : MV4 α) : α :=
  v1.x * v2.x + v1.y * v2.y + v1.z * v2.z - v1.t * v2.t

/-- Notation for inner product using dot symbol -/
infixl:75 " ⋅ " => MV4.inner
#eval (MV4.e4 ⋅ MV4.e4)

/-- Geometric product implementation -/
instance MV4.geoProd [Mul a][Add a][Sub a][Neg a]: Mul (MV4 a) where
  mul a b :=
    let s := a.scalar * b.scalar
    + a.x * b.x + a.y * b.y + a.z * b.z - a.t * b.t
    + a.xy * b.xy + a.xz * b.xz - a.xt * b.xt
    + a.yz * b.yz - a.yt * b.yt - a.zt * b.zt
    + a.xyz * b.xyz - a.xyt * b.xyt - a.xzt * b.xzt
    - a.yzt * b.yzt + a.xyzt * b.xyzt

    let x := a.scalar * b.x + a.x * b.scalar
    + a.y * b.xy + a.z * b.xz - a.t * b.xt
    + a.xy * b.y + a.xz * b.z - a.xt * b.t
    + a.yz * b.xyz - a.yt * b.xyt - a.zt * b.xzt
    + a.xyz * b.yz - a.xyt * b.yt - a.xzt * b.zt
    + a.yzt * b.xyzt + a.xyzt * b.yzt

    let y := a.scalar * b.y + a.y * b.scalar
    - a.x * b.xy + a.z * b.yz - a.t * b.yt
    - a.xy * b.x + a.yz * b.z - a.yt * b.t
    - a.xz * b.xyz + a.xt * b.xyt - a.zt * b.yzt
    - a.xyz * b.xz + a.xyt * b.xt - a.yzt * b.zt
    + a.xzt * b.xyzt + a.xyzt * b.xzt

    let z := a.scalar * b.z + a.z * b.scalar
    - a.x * b.xz - a.y * b.yz - a.t * b.zt
    - a.xz * b.x - a.yz * b.y - a.zt * b.t
    + a.xy * b.xyz + a.xt * b.xzt + a.yt * b.yzt
    + a.xyz * b.xy + a.xzt * b.xt + a.yzt * b.yt
    - a.xyt * b.xyzt - a.xyzt * b.xyt

    let t := a.scalar * b.t + a.t * b.scalar
    - a.x * b.xt - a.y * b.yt - a.z * b.zt
    - a.xt * b.x - a.yt * b.y - a.zt * b.z
    - a.xy * b.xyt - a.xz * b.xzt - a.yz * b.yzt
    - a.xyt * b.xy - a.xzt * b.xz - a.yzt * b.yz
    + a.xyz * b.xyzt + a.xyzt * b.xyz

    let xy := a.scalar * b.xy + a.xy * b.scalar
    + a.x * b.y - a.y * b.x + a.z * b.xyz - a.t * b.xyt
    + a.xz * b.yz - a.xt * b.yt + a.yz * b.xz - a.yt * b.xt
    + a.xyz * b.z - a.xyt * b.t + a.xzt * b.yzt - a.yzt * b.xzt
    + a.xyzt * b.zt

    let xz := a.scalar * b.xz + a.xz * b.scalar
    + a.x * b.z - a.z * b.x + a.y * b.xyz - a.t * b.xzt
    + a.xy * b.yz - a.xt * b.zt + a.yz * b.xy - a.zt * b.xt
    + a.xyz * b.y - a.xzt * b.t + a.xyt * b.yzt - a.yzt * b.xyt
    + a.xyzt * b.yt

    let xt := a.scalar * b.xt + a.xt * b.scalar
    + a.x * b.t - a.t * b.x + a.y * b.xyt - a.z * b.xzt
    + a.xy * b.yt - a.xz * b.zt + a.yt * b.xy - a.zt * b.xz
    + a.xyt * b.y - a.xzt * b.z + a.xyz * b.yzt - a.yzt * b.xyz
    + a.xyzt * b.yz

    let yz := a.scalar * b.yz + a.yz * b.scalar
    + a.y * b.z - a.z * b.y + a.x * b.xyz - a.t * b.yzt
    + a.xy * b.xz - a.yt * b.zt + a.xz * b.xy - a.zt * b.yt
    + a.xyz * b.x - a.yzt * b.t + a.xyt * b.xzt - a.xzt * b.xyt
    + a.xyzt * b.xt

    let yt := a.scalar * b.yt + a.yt * b.scalar
    + a.y * b.t - a.t * b.y + a.x * b.xyt - a.z * b.yzt
    + a.xy * b.xt - a.yz * b.zt + a.xt * b.xy - a.zt * b.yz
    + a.xyt * b.x - a.yzt * b.z + a.xyz * b.xzt - a.xzt * b.xyz
    + a.xyzt * b.xz

    let zt := a.scalar * b.zt + a.zt * b.scalar
    + a.z * b.t - a.t * b.z + a.x * b.xzt - a.y * b.yzt
    + a.xz * b.xt - a.yz * b.yt + a.xt * b.xz - a.yt * b.yz
    + a.xzt * b.x - a.yzt * b.y + a.xyz * b.xyt - a.xyt * b.xyz
    + a.xyzt * b.xy

    let xyz := a.scalar * b.xyz + a.xyz * b.scalar
    + a.x * b.yz - a.y * b.xz + a.z * b.xy
    + a.xy * b.z - a.xz * b.y + a.yz * b.x
    + a.xt * b.yzt - a.yt * b.xzt + a.zt * b.xyt
    + a.xyt * b.zt - a.xzt * b.yt + a.yzt * b.xt
    + a.xyzt * b.t

    let xyt := a.scalar * b.xyt + a.xyt * b.scalar
    + a.x * b.yt - a.y * b.xt + a.t * b.xy
    + a.xy * b.t - a.xt * b.y + a.yt * b.x
    + a.xz * b.yzt - a.yz * b.xzt + a.zt * b.xyz
    + a.xyz * b.zt - a.xzt * b.yz + a.yzt * b.xz
    + a.xyzt * b.z

    let xzt := a.scalar * b.xzt + a.xzt * b.scalar
    + a.x * b.zt - a.z * b.xt + a.t * b.xz
    + a.xz * b.t - a.xt * b.z + a.zt * b.x
    + a.xy * b.yzt - a.yz * b.xyt + a.yt * b.xyz
    + a.xyz * b.yt - a.xyt * b.yz + a.yzt * b.xy
    + a.xyzt * b.y

    let yzt := a.scalar * b.yzt + a.yzt * b.scalar
    + a.y * b.zt - a.z * b.yt + a.t * b.yz
    + a.yz * b.t - a.yt * b.z + a.zt * b.y
    + a.xy * b.xzt - a.xz * b.xyt + a.xt * b.xyz
    + a.xyz * b.xt - a.xyt * b.xz + a.xzt * b.xy
    + a.xyzt * b.x

    let xyzt := a.scalar * b.xyzt + a.xyzt * b.scalar
    + a.x * b.yzt - a.y * b.xzt + a.z * b.xyt - a.t * b.xyz
    + a.xy * b.zt - a.xz * b.yt + a.xt * b.yz
    + a.xyz * b.t - a.xyt * b.z + a.xzt * b.y - a.yzt * b.x
    + a.xyzt * b.scalar

    #v[s,x,y,z,t,xy,xz,xt,yz,yt,zt,xyz,xyt,xzt,yzt,xyzt]

/-- Wedge product between two vectors -/
def MV4.wedge {α : Type u} [Mul α] [Sub α] [Add α] [Zero α] (v1 v2 : MV4 α) : MV4 α :=
  let xy := v1.x * v2.y - v1.y * v2.x
  let xz := v1.x * v2.z - v1.z * v2.x
  let xt := v1.x * v2.t - v1.t * v2.x
  let yz := v1.y * v2.z - v1.z * v2.y
  let yt := v1.y * v2.t - v1.t * v2.y
  let zt := v1.z * v2.t - v1.t * v2.z
  #v[0,0,0,0,0,xy,xz,xt,yz,yt,zt,0,0,0,0,0]

/-- Notation for wedge product using wedge symbol -/
infixl:75 " ∧ " => MV4.wedge

/-- Dual operation on multivectors -/
def MV4.dual {α : Type u} [Mul α] [Sub α] [Add α] [Zero α] [Neg α] (mv : MV4 α) : MV4 α :=
  #v[mv.xyzt,
     -mv.yzt, mv.xzt, -mv.xyt, mv.xyz,
     -mv.zt, mv.yt, -mv.yz, mv.xt, -mv.xz, mv.xy,
     -mv.t, mv.z, -mv.y, mv.x,
     mv.scalar]

/-- Reverse operation (reversion) - changes sign of bivectors and trivectors -/
def MV4.reverse {α : Type u} [Neg α] (mv : MV4 α) : MV4 α :=
  #v[mv.scalar,
     mv.x, mv.y, mv.z, mv.t,
     -mv.xy, -mv.xz, -mv.xt, -mv.yz, -mv.yt, -mv.zt,
     -mv.xyz, -mv.xyt, -mv.xzt, -mv.yzt,
     mv.xyzt]

/-- Grade involution - changes sign of odd grades -/
def MV4.gradeInvolution {α : Type u} [Neg α] (mv : MV4 α) : MV4 α :=
  #v[mv.scalar,
     -mv.x, -mv.y, -mv.z, -mv.t,
     mv.xy, mv.xz, mv.xt, mv.yz, mv.yt, mv.zt,
     -mv.xyz, -mv.xyt, -mv.xzt, -mv.yzt,
     mv.xyzt]

/-- Clifford conjugation (grade involution + reversion) -/
def MV4.conjugate {α : Type u} [Neg α] (mv : MV4 α) : MV4 α :=
  mv.gradeInvolution.reverse

/-- Grade projection operators -/
def MV4.grade0 {α : Type u} [Zero α] (mv : MV4 α) : MV4 α :=
  #v[mv.scalar,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

def MV4.grade1 {α : Type u} [Zero α] (mv : MV4 α) : MV4 α :=
  #v[0,mv.x,mv.y,mv.z,mv.t,0,0,0,0,0,0,0,0,0,0,0]

def MV4.grade2 {α : Type u} [Zero α] (mv : MV4 α) : MV4 α :=
  #v[0,0,0,0,0,mv.xy,mv.xz,mv.xt,mv.yz,mv.yt,mv.zt,0,0,0,0,0]

def MV4.grade3 {α : Type u} [Zero α] (mv : MV4 α) : MV4 α :=
  #v[0,0,0,0,0,0,0,0,0,0,0,mv.xyz,mv.xyt,mv.xzt,mv.yzt,0]

def MV4.grade4 {α : Type u} [Zero α] (mv : MV4 α) : MV4 α :=
  #v[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,mv.xyzt]

/-- The zero multivector.-/
instance [Zero α] : OfNat (MV4 α) 0 where
  ofNat := #v[0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]

/-- Test if a multivector is homogeneous (only one grade) -/
def MV4.isHomogeneous {α : Type u} [Zero α] [DecidableEq α] [DecidableEq (MV4 α)] (mv : MV4 α) : Bool :=
  let g0 := mv.grade0 ≠ (0 : MV4 α)
  let g1 := mv.grade1 ≠ (0 : MV4 α)
  let g2 := mv.grade2 ≠ (0 : MV4 α)
  let g3 := mv.grade3 ≠ (0 : MV4 α)
  let g4 := mv.grade4 ≠ (0 : MV4 α)
  let count := (if g0 then 1 else 0) +
               (if g1 then 1 else 0) +
               (if g2 then 1 else 0) +
               (if g3 then 1 else 0) +
               (if g4 then 1 else 0)
  count ≤ 1

/-- Norm squared of a multivector -/
def MV4.normSquared {α : Type u} [Mul α] [Add α] [Sub α] [Zero α] [Neg α] (mv : MV4 α) : α :=
  (mv * mv.reverse).scalar

/-- Test if a multivector is null (zero norm) -/
def MV4.isNull {α : Type u} [Mul α] [Add α] [Sub α] [Zero α] [Neg α] [DecidableEq α] (mv : MV4 α) : Bool :=
  mv.normSquared = 0

/- Common 4D vectors and basis elements -/
namespace Basis
  variable {α : Type u} [OfNat α 1] [Zero α] [Add α] [Mul α] [Neg α] [Sub α]

  /-- Unit basis vectors -/
  def e₀ : MV4 α := MV4.e1
  def e₁ : MV4 α := MV4.e2
  def e₂ : MV4 α := MV4.e3
  def e₃ : MV4 α := MV4.e4

  /-- Time, space, and spacetime vectors in various signatures -/
  def timeVec : MV4 α := e₃
  def spaceVec : MV4 α := e₀
  def nullVec : MV4 α := e₀ + e₃

  /-- Spatial rotation plane -/
  def xyPlane : MV4 α := MV4.wedge e₀ e₁
end Basis

/-- The scalar part of e₀ is 1 -/
theorem e0_scalar {α : Type u} [OfNat α 1] [Zero α] : (MV4.e0 : MV4 α).scalar = 1 := by
  rfl

/-- The x component of e1 is 1 -/
theorem e1_x {α : Type u} [OfNat α 1] [Zero α] : (MV4.e1 : MV4 α).x = 1 := by
  rfl

end MultiVector

/-- A 4D vector representing a point in spacetime. The name is `Vector₁` to avoid conflict with the builtin `Vector` . -/
abbrev Vector₁ (α : Type u) := Vector α 4

/-- A bivector representing an oriented plane segment -/
abbrev Bivector (α : Type u) := Vector α 6

/-- A trivector representing an oriented volume segment -/
abbrev Trivector (α : Type u) := Vector α 4

/-- A versor (even-graded multivector) with 8 components:
    1 scalar + 6 bivector + 1 pseudoscalar
    Versors represent rotations and boosts in spacetime -/
structure Versor (α : Type u) where
  /-- Scalar component -/
  scalar : α
  /-- Bivector components (xy, xz, xt, yz, yt, zt) -/
  xy : α
  xz : α
  xt : α
  yz : α
  yt : α
  zt : α
  /-- Pseudoscalar component -/
  xyzt : α
  deriving Repr

namespace Versor

variable {α : Type u}

/-- Convert versor to full multivector -/
def toMV4 [Zero α] (v : Versor α) : MultiVector.MV4 α :=
  #v[v.scalar, 0, 0, 0, 0, v.xy, v.xz, v.xt, v.yz, v.yt, v.zt, 0, 0, 0, 0, v.xyzt]

/-- Create a versor from just a scalar value -/
def fromScalar [Zero α] (s : α) : Versor α :=
  ⟨s, 0, 0, 0, 0, 0, 0, 0⟩

/-- Create identity versor -/
def identity [OfNat α 1] [Zero α] : Versor α :=
  ⟨1, 0, 0, 0, 0, 0, 0, 0⟩

/-- Create a versor from bivector components -/
def fromBivector [Zero α] (xy xz xt yz yt zt : α) : Versor α :=
  ⟨0, xy, xz, xt, yz, yt, zt, 0⟩

/-- Create a versor representing a pure pseudoscalar -/
def makePseudoscalar [Zero α] (p : α) : Versor α :=
  ⟨0, 0, 0, 0, 0, 0, 0, p⟩

/-- Versor multiplication (composition of rotations/boosts) -/
def mul [Mul α] [Add α] [Sub α] (v1 v2 : Versor α) : Versor α :=
  let s := v1.scalar * v2.scalar
         + v1.xy * v2.xy + v1.xz * v2.xz - v1.xt * v2.xt
         + v1.yz * v2.yz - v1.yt * v2.yt - v1.zt * v2.zt
         + v1.xyzt * v2.xyzt

  let xy := v1.scalar * v2.xy + v1.xy * v2.scalar
          + v1.xz * v2.yz - v1.xt * v2.yt
          + v1.yz * v2.xz - v1.yt * v2.xt
          + v1.xyzt * v2.zt

  let xz := v1.scalar * v2.xz + v1.xz * v2.scalar
          + v1.xy * v2.yz - v1.xt * v2.zt
          + v1.yz * v2.xy - v1.zt * v2.xt
          + v1.xyzt * v2.yt

  let xt := v1.scalar * v2.xt + v1.xt * v2.scalar
          + v1.xy * v2.yt - v1.xz * v2.zt
          + v1.yt * v2.xy - v1.zt * v2.xz
          + v1.xyzt * v2.yz

  let yz := v1.scalar * v2.yz + v1.yz * v2.scalar
          + v1.xy * v2.xz - v1.yt * v2.zt
          + v1.xz * v2.xy - v1.zt * v2.yt
          + v1.xyzt * v2.xt

  let yt := v1.scalar * v2.yt + v1.yt * v2.scalar
          + v1.xy * v2.xt - v1.yz * v2.zt
          + v1.xt * v2.xy - v1.zt * v2.yz
          + v1.xyzt * v2.xz

  let zt := v1.scalar * v2.zt + v1.zt * v2.scalar
          + v1.xz * v2.xt - v1.yz * v2.yt
          + v1.xt * v2.xz - v1.yt * v2.yz
          + v1.xyzt * v2.xy

  let xyzt := v1.scalar * v2.xyzt + v1.xyzt * v2.scalar
            + v1.xy * v2.zt - v1.xz * v2.yt + v1.xt * v2.yz
            + v1.xyzt * v2.scalar

  ⟨s, xy, xz, xt, yz, yt, zt, xyzt⟩

instance [Mul α] [Add α] [Sub α] : Mul (Versor α) where
  mul := mul

/-- Versor reversal for computing inverse -/
def reverse [Neg α] (v : Versor α) : Versor α :=
  ⟨v.scalar, -v.xy, -v.xz, -v.xt, -v.yz, -v.yt, -v.zt, v.xyzt⟩

/-- Versor norm squared -/
def normSquared [Mul α] [Add α] [Sub α] [Neg α] (v : Versor α) : α :=
  (v.mul v.reverse).scalar

/-- Apply versor transformation to a vector (sandwich product: v * x * ~v) -/
def applyToVector [Mul α] [Add α] [Sub α] [Neg α] [Zero α] (v : Versor α) (vec : MultiVector.MV4 α) : MultiVector.MV4 α :=
  let mv := v.toMV4
  let result := mv * vec * mv.reverse
  result.grade1

end Versor

/-- Inner product between two 4D vectors using Minkowski metric (-,+,+,+) -/
def innerProduct [Zero α] [Add α] [Mul α] [Neg α] (v₁ v₂ : Vector₁ α) : α :=
  -v₁[0] * v₂[0] + v₁[1] * v₂[1] + v₁[2] * v₂[2] + v₁[3] * v₂[3]

/-- Inner product between two bivectors -/
def bivectorProduct [Zero α] [Add α] [Mul α] [Sub α] [Neg α] (b₁ b₂ : Bivector α) : α :=
  b₁[0] * b₂[0] + b₁[1] * b₂[1] - b₁[2] * b₂[2] +
  b₁[3] * b₂[3] - b₁[4] * b₂[4] - b₁[5] * b₂[5]

/-- Wedge product between two vectors, producing a bivector -/
def wedgeVV [Zero α] [Add α] [Mul α] [Sub α] [Neg α] (v₁ v₂ : Vector₁ α) : Bivector α :=

  let e₀₁ := v₁[0] * v₂[1] - v₁[1] * v₂[0]
  let e₀₂ := v₁[0] * v₂[2] - v₁[2] * v₂[0]
  let e₁₂ := v₁[1] * v₂[2] - v₁[2] * v₂[1]
  let e₀₃ := v₁[0] * v₂[3] - v₁[3] * v₂[0]
  let e₁₃ := v₁[1] * v₂[3] - v₁[3] * v₂[1]
  let e₂₃ := v₁[2] * v₂[3] - v₁[3] * v₂[2]

  #v[e₀₁,e₀₂,e₁₂,e₀₃,e₁₃,e₂₃]

/-- Wedge product between a bivector and vector, producing a trivector -/
def wedgeBV [Zero α] [Add α] [Mul α][Sub α][Neg α] (b : Bivector α) (v : Vector₁ α) : Trivector α :=
  let e₀₁₂ := b[0] * v[2] - b[1] * v[1] + b[2] * v[0]
  let e₀₁₃ := b[0] * v[3] - b[3] * v[1] + b[4] * v[0]
  let e₀₂₃ := b[0] * v[3] - b[3] * v[2] + b[5] * v[0]
  let e₁₂₃ := b[1] * v[3] - b[3] * v[2] + b[5] * v[1]
  #v[e₀₁₂,e₀₁₃,e₀₂₃,e₁₂₃]

/-- Dual of a bivector -/
def dualB [Zero α] [Neg α] (b : Bivector α) : Bivector α :=
  #v[
    -b[5],
    b[4],
    b[3],
    -b[2],
    -b[1],
    b[0]
  ]
