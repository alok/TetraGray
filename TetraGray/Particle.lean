import TetraGray.Clifford
open TetraGray.Multivector
namespace TetraGray.Particle

/-- Basic particle state matching the C++ implementation -/
structure ParticleState where
  /-- Position in spacetime -/
  position : Vec4
  /-- 4-momentum of particle -/
  momentum : Vec4
  deriving Repr, BEq, Inhabited

/-- For relativistic integration, we need proper time and mass -/
structure RelativisticParticleState extends ParticleState where
  /-- Proper time along worldline -/
  properTime : Float
  /-- Rest mass of particle -/
  mass : Float := 1
  deriving Repr, BEq, Inhabited

/-- Propagates particle state forward using simple Euler integration -/
def propagate (state : ParticleState) (dt : Float) : ParticleState :=
  { position := state.position + state.momentum.map (· * dt)
    momentum := state.momentum }  -- Free particle

instance : HMul Float ParticleState ParticleState where
  hMul scalar state := {
    position := state.position.map (· * scalar)
    momentum := state.momentum.map (· * scalar)
  }

instance : HMul ParticleState Float ParticleState where
  hMul state scalar := scalar * state

instance : Add ParticleState where
  add a b := {
    position := a.position + b.position
    momentum := a.momentum + b.momentum
  }

#eval let p := { position := { t := 1, x := 2, y := 3, z := 4 }, momentum := { t := 0, x := 1, y := 0, z := 0 } : ParticleState }
      2.0 * p

end TetraGray.Particle
