
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

namespace NumericalArray

/-- Convert array to string representation -/
def toString {a : Type} [ToString a] (xs : NumericalArray a length) : String := Id.run do
  if xs.values.size = 0 then
    return "[]"
  else
    let mut acc := ""
    for x in xs.values do
      acc := s!"{acc}{x}, "
    -- remove trailing comma and space
    acc := acc.dropRight 2
    return s!"[{acc}]"

instance [ToString a] (length : Nat) : ToString (NumericalArray a length) where
  toString xs := xs.toString

/-- Empty Array always has default -/
instance : Inhabited (NumericalArray a 0) where
  default := { values := #[], _pf_length := by rfl }

/-- Array with all elements default -/
instance [Inhabited a] (length : Nat) : Inhabited (NumericalArray a length) where
  default := { values := Array.replicate length default}

#eval! (default : NumericalArray Float 3).toString

/-- Map over the array with index -/
def mapIdx {a b : Type} (f : Nat → a → b) (xs : NumericalArray a length) : NumericalArray b length :=
  { values := xs.values.mapIdx f}

/-- Map over the array -/
def map {a b : Type} (f : a → b) (xs : NumericalArray a length) : NumericalArray b length :=
  { values := xs.values.map f}

instance : Functor (NumericalArray · length) where
  map f xs := xs.map f

def TEST_XS : NumericalArray Float 4 := NumericalArray.mk #[1.0, 2.0, 3.0, 4.0]
def TEST_YS : NumericalArray Float 4 := NumericalArray.mk #[4.0, 5.0, 6.0, 7.0]

#eval! TEST_XS.map (· + 1.0)

/-- Zip with another array using the provided function -/
def zipWith (f : a → b → c) (xs : NumericalArray a length) (ys : NumericalArray b length) : NumericalArray c length := Id.run do
  let mut zs := Array.mkEmpty xs.values.size
  for (x,y) in xs.values.zip ys.values do
    zs := zs.push (f x y)
  { values := zs}

instance {a : Type} [Add a] (length : Nat) : Add (NumericalArray a length) where
  add a b := a.zipWith (· + ·) b

#eval! TEST_XS + TEST_YS

/-- Scalar multiplication on the left -/
instance [HMul scalar α α] : HMul scalar (NumericalArray α length) (NumericalArray α length) where
  hMul a v := v.map (a * ·)

/-- Scalar multiplication on the right -/
instance [HMul α scalar α] : HMul (NumericalArray α length) scalar (NumericalArray α length) where
  hMul v a := v.map (· * a)

instance [Neg α] (length : Nat) : Neg (NumericalArray α length) where
  neg a := a.map Neg.neg

instance [Add α] [Neg α] : Sub (NumericalArray α length) where
  sub a b := a + (-b)

#eval! TEST_XS - TEST_YS

/-- Scalar division is only defined on the right to avoid any ambiguity about what it means -/
instance [HDiv α scalar α] : HDiv (NumericalArray α length) scalar (NumericalArray α length) where
  hDiv xs a := xs.map (· / a)

#eval! TEST_XS / 2.0




instance : GetElem (NumericalArray α length) Nat α (fun _ i => i < length) where
  --TODO use that xs.values.size = length for proof that index is valid
  getElem xs i h := xs.values[i]'sorry

#eval! TEST_XS[2]

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
