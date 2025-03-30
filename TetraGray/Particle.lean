import TetraGray.Clifford

namespace MultiVector
/-- Calculate the norm of a multivector component (grade 1) -/
def MV4.norm (v : MV4 Float) : Float :=
  (v.x * v.x + v.y * v.y + v.z * v.z + v.t * v.t).sqrt
end MultiVector

namespace Particle

open MultiVector

/-- Dot product of two vectors -/
def _root_.Vector.dot [Zero α] [Add α] [Mul α] (v₁ v₂ : Vector α n) : α :=
  (v₁.zip v₂).foldl (fun acc (x₁, x₂) => acc + x₁ * x₂) 0

/-- A particle in 4D spacetime with position and momentum vectors -/
structure Particle (α : Type)  where
  /-- Position vector in 4D spacetime -/
  position : MV4 α
  /-- Momentum vector in 4D spacetime -/
  momentum : MV4 α
  time : α
  stepSize : α
  deriving Repr

/-- Create a zero particle with position and momentum at origin -/
instance [Zero α] : Zero (Particle α) where
  zero := ⟨0, 0, 0, 0⟩

/-- Scale a particle by a scalar value -/
instance [HMul α (MV4 α) (MV4 α)] : HMul α (Particle α) (Particle α) where
  hMul s p := ⟨s * p.position, s * p.momentum, p.time, p.stepSize⟩

/-- Add two particles -/
instance [Add (MV4 α)] : Add (Particle α) where
  add p1 p2 := ⟨p1.position + p2.position, p1.momentum + p2.momentum, p1.time, p1.stepSize⟩

/-- Scale a particle by a scalar value on the right -/
instance [HMul (MV4 α) α (MV4 α)] : HMul (Particle α) α (Particle α) where
  hMul p s := ⟨p.position * s, p.momentum * s, p.time, p.stepSize⟩

/-- Multiply a particle by a scalar value -/
def scale [HMul α (MV4 α) (MV4 α)] (s : α) (p : Particle α) : Particle α :=
  s * p

/-- Add a particle to another particle -/
def add [Add (MV4 α)] (p1 p2 : Particle α) : Particle α :=
  p1 + p2

end Particle
