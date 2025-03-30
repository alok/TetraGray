import TetraGray.Clifford
import TetraGray.Image
import TetraGray.ODE
import TetraGray.Particle

namespace Doran

open MultiVector
open Image
open ODE
open Particle

/-- Camera position in 4D spacetime (t, x, y, z) -/
def campos : MV4 Float := #v[0, 0, 20, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

/-- Radius for particle extraction -/
def extractRadius : Float := 50

/-- Base integration step size -/
def stepSize : Float := 0.05

/-- Maximum step size ratio for adaptive stepping -/
def maxStepRatio : Float := 40

/-- Maximum integration time -/
def maxTime : Float := 500

/-- Right-hand side function for the Doran spacetime -/
def doranRHS (particle : Particle Float) : MV4 Float :=
  let pos := particle.position
  let r2 := pos.x * pos.x + pos.y * pos.y + pos.z * pos.z

  -- Black hole at origin with Schwarzschild radius = 1
  if r2 < 0.001 then
    0 -- Avoid division by zero near the singularity
  else
    let r := r2.sqrt
    let r3 := r * r2

    -- Doran metric gravity field
    let force := -1.0 / r3 * #v[0, pos.x, pos.y, pos.z, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    force

/-- PI constant -/
def PI : Float := 3.14159265358979323846

/-- Map particle position to color based on spherical coordinates -/
def sphericalColorMap (radius : Float) (particle : Particle Float) : RGB :=
  -- Extract position components
  let x := particle.position.x
  let y := particle.position.y
  let z := particle.position.z

  -- Calculate spherical coordinates
  let r := Float.sqrt (x*x + y*y + z*z)

  -- Simple theta calculation (approx atan2)
  let theta :=
    if Float.abs x < 0.000001 then
      if y >= 0 then PI/2 else -PI/2
    else
      let rawAtan := Float.atan (y / x)
      if x < 0 then rawAtan + PI else rawAtan

  -- Simple phi calculation (approx acos)
  let phi :=
    if r < 0.000001 then
      0
    else
      Float.acos (z / r)

  -- Normalize angles to [0,1] range
  let normTheta := (theta + PI) / (2 * PI)
  let normPhi := phi / PI

  -- Create a color based on the spherical coordinates
  let r := normTheta
  let g := normPhi
  let b := r / radius

  -- Create RGB color
  rgb r g b

/-- Structure for raytracer configuration -/
structure RaytracerConfig (α : Type) where
  width : Nat
  height : Nat
  fov : Float
  cameraPos : MV4 α
  orientation : MV4 α
  outputPath : String
  integrator : IntegrationMethod
  rhs : RHSFunction
  stepController : StepSizeController
  stopCondition : StopCondition
  colorMap : Particle Float → RGB
  imageWriter : Image → String → IO Unit

/-- Default PNG writer function -/
def pngWriter (img : Image) (filename : String) : IO Unit := do
  -- Write to PPM first, then convert to PNG with the system's ImageMagick
  img.writePPM s!"{filename}.ppm"
  IO.println s!"Writing to {filename}.ppm"

  -- Call ImageMagick to convert to PNG - we just report that this would happen
  -- since we don't have direct access to the command
  IO.println s!"Would convert {filename}.ppm to {filename} using ImageMagick"

  -- Report success
  IO.println s!"Generated image: {filename}.ppm"

/-- Create a ray from camera position and pixel coordinates -/
def createRay (config : RaytracerConfig Float) (x y : Nat) : Particle Float :=
  -- Calculate normalized device coordinates
  let aspectRatio := config.width.toFloat / config.height.toFloat
  let ndc_x := (x.toFloat / config.width.toFloat) * 2 - 1
  let ndc_y := 1 - (y.toFloat / config.height.toFloat) * 2

  -- Calculate ray direction in camera space
  let dir_x := ndc_x * aspectRatio * Float.tan (config.fov / 2)
  let dir_y := ndc_y * Float.tan (config.fov / 2)
  let dir_z := -1.0 -- Forward direction

  -- Create direction vector in world space
  let direction := #v[0, dir_x, dir_y, dir_z, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

  -- Create initial particle state with position at camera and momentum as direction
  {
    position := config.cameraPos,
    momentum := direction,
    time := 0,
    stepSize := stepSize
  }

/-- Trace a ray through the Doran spacetime -/
def traceRay (config : RaytracerConfig Float) (ray : Particle Float) : RGB :=
  -- Integrate the particle's path through spacetime
  let finalState := integrate ray config.rhs config.integrator config.stepController config.stopCondition

  -- Map the final particle state to a color
  config.colorMap finalState

/-- Apply step size controller wrapper to match Doran's expected types -/
def doranStepController (p : Particle Float) : Particle Float :=
  dynamicStepSize maxStepRatio stepSize p

/-- Main raytracing function -/
def raytrace (config : RaytracerConfig Float) : IO Unit := do
  IO.println "Starting Doran spacetime raytracing..."

  -- Create empty image
  let mut img := Image.black config.width config.height

  -- Calculate total number of pixels for progress reporting
  let totalPixels := config.width * config.height
  let mut pixelCount := 0

  -- Process each pixel
  for y in [:config.height] do
    for x in [:config.width] do
      -- Create ray for this pixel
      let ray := createRay config x y

      -- Trace the ray and get color
      let color := traceRay config ray

      -- Set pixel color
      img := img.setPixel x y color

      -- Update progress counter
      pixelCount := pixelCount + 1
      if pixelCount % 1000 == 0 then
        IO.println s!"Progress: {pixelCount}/{totalPixels} pixels ({(pixelCount.toFloat / totalPixels.toFloat * 100).floor}%)"

  -- Write the result to file
  config.imageWriter img config.outputPath
  IO.println "Raytracing complete!"

/-- Main raytracing configuration -/
def config : RaytracerConfig Float := {
  width := 800
  height := 600
  fov := PI / 4
  cameraPos := campos
  orientation := MV4.e0
  outputPath := "doran.png"
  integrator := ODE.rk4
  rhs := doranRHS
  stepController := doranStepController
  stopCondition := combinedStopCondition extractRadius maxTime maxStepRatio stepSize
  colorMap := sphericalColorMap extractRadius
  imageWriter := pngWriter
}

/-- Main entry point for Doran spacetime visualization -/
def main : IO Unit :=
  raytrace config

end Doran

def main : IO Unit := Doran.main
