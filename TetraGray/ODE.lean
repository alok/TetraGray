import TetraGray.Clifford
import TetraGray.Particle

set_option relaxedAutoImplicit false

namespace ODE
open Particle
open MultiVector

/-- Definition of an ODE right-hand side function -/
abbrev RHSFunction := Particle Float → MV4 Float

/-- Definition of an integration method -/
abbrev IntegrationMethod := RHSFunction → Particle Float → Particle Float

/-- Definition of a step size controller function -/
abbrev StepSizeController := Particle Float → Particle Float

/-- Definition of a stop condition function -/
abbrev StopCondition := Particle Float → Bool

/-- Combine stop conditions for integration -/
def combinedStopCondition (extractRadius maxTime maxStepRatio stepSize : Float)
  (data : Particle Float) : Bool :=
  (data.time > maxTime) ||
  (data.position.norm > extractRadius) ||
  (data.stepSize > stepSize * maxStepRatio)

/-- Euler integration method -/
def euler (f : RHSFunction) (p : Particle Float) : Particle Float :=
  let dt := p.stepSize
  let accel := f p
  let newPos := p.position + dt * p.momentum
  let newMom := p.momentum + dt * accel
  { position := newPos, momentum := newMom, time := p.time + dt, stepSize := p.stepSize }

/-- Fourth-order Runge-Kutta integration method -/
def rk4 (f : RHSFunction) (p : Particle Float) : Particle Float :=
  let h := p.stepSize

  -- First stage (k1)
  let k1v := p.momentum
  let k1a := f p

  -- Second stage (k2)
  let halfH := h / 2
  let midPos := p.position + halfH * k1v
  let midMom := p.momentum + halfH * k1a
  let midP := { position := midPos, momentum := midMom, time := p.time + halfH, stepSize := p.stepSize }
  let k2v := midP.momentum
  let k2a := f midP

  -- Third stage (k3)
  let midPos2 := p.position + halfH * k2v
  let midMom2 := p.momentum + halfH * k2a
  let midP2 := { position := midPos2, momentum := midMom2, time := p.time + halfH, stepSize := p.stepSize }
  let k3v := midP2.momentum
  let k3a := f midP2

  -- Fourth stage (k4)
  let endPos := p.position + h * k3v
  let endMom := p.momentum + h * k3a
  let endP := { position := endPos, momentum := endMom, time := p.time + h, stepSize := p.stepSize }
  let k4v := endP.momentum
  let k4a := f endP

  -- Combine stages
  let newPos := p.position + (h/6) * (k1v + 2*k2v + 2*k3v + k4v)
  let newMom := p.momentum + (h/6) * (k1a + 2*k2a + 2*k3a + k4a)

  { position := newPos, momentum := newMom, time := p.time + h, stepSize := p.stepSize }

/-- Dynamic step size controller based on the momentum magnitude -/
def dynamicStepSize (maxRatio baseSize : Float) (p : Particle Float) : Particle Float :=
  let momMagnitude := p.momentum.norm
  if momMagnitude > 0 then
    let newStepSize := min (baseSize / momMagnitude) (baseSize * maxRatio)
    { p with stepSize := newStepSize }
  else
    { p with stepSize := baseSize }

/-- Maximum number of iterations for integration to prevent infinite loops -/
def MAX_ITERATIONS : Nat := 10000

/-- Integrate an ODE system from initial conditions until a stop condition is met
    Uses a simple non-recursive implementation with a loop counter to avoid termination issues -/
def integrate (initialState : Particle Float)
              (rhs : RHSFunction)
              (integrator : IntegrationMethod)
              (stepController : StepSizeController)
              (stopCondition : StopCondition) : Particle Float :=
  Id.run do
    let mut state := initialState
    let mut iterations := 0

    while iterations < MAX_ITERATIONS && !stopCondition state do
      let nextState := integrator rhs state
      state := stepController nextState
      iterations := iterations + 1

    return state

end ODE
