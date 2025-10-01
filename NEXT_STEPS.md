# Next Steps for TetraGray Lean 4 Port

## What We Just Accomplished (This Session)

### Major Features Added
1. **Enhanced Clifford Algebra** (`TetraGray/Clifford.lean`)
   - Grade involution and Clifford conjugation
   - Fixed dual operation (proper Hodge star)
   - Complete grade projections (grade0-4)

2. **Full Versor Implementation**
   - Restructured from Vector-based to named fields
   - Versor multiplication for rotation composition
   - Sandwich product for vector transformations
   - Identity versor and constructors

3. **Coordinate Systems Module** (`TetraGray/CoordSystems.lean`)
   - Spherical coordinates from Cartesian
   - Oblate spheroidal coordinates (Doran convention)
   - All basis vectors (ê_μ, ê_ν, ê_φ, ê_t)
   - Doran β parameter and gauge transformations

4. **Development Infrastructure**
   - `dev-loop.sh`: Build → Run → Convert → View
   - `watch-dev.sh`: Continuous rebuild with hwatch
   - `DEVELOPMENT.md`: Full workflow guide
   - `CPP_PARITY.md`: Feature comparison tracker

### Current Build Status
- ✅ All modules compile successfully
- ✅ PPM image generation works
- ✅ Basic raytracer renders spheres
- ✅ ~90% of core Clifford algebra complete

## Immediate Next Steps (Priority Order)

### 1. Test Suite (HIGH PRIORITY - Validates Correctness)

Create `TetraGray/Tests.lean` with tests from C++ `test.cu`:

```lean
-- Basic math tests
def ipow_test : Nat := 3 ^ 4  -- expect 81
def choose_test : Nat := Nat.choose 4 2  -- expect 6

-- Multivector tests
def multivector_zero_test : MV4 Float :=
  0  -- should be all zeros

def multivector_vector_test : MV4 Float :=
  MV4.makeMultivectorFromGrade1 #v[1, 3, 5, 7]
  -- expect: [0, 1, 3, 0, 5, 0, 0, 0, 7, ...]

def multivector_multiply_test : MV4 Float :=
  let v1 := MV4.makeMultivectorFromGrade1 #v[1, 3, 5, 7]
  let v2 := MV4.makeMultivectorFromGrade1 #v[2, 4, 6, 8]
  v1 * v2
  -- expect: [-12, 0, 0, -2, 0, -4, -2, ...]

-- Add tests for:
-- - multivector_add_test
-- - multivector_scalar_multiply_test
-- - multivector_grade_project_test
-- - single_multiply_test_left/right
-- - multivector_rotate_test
```

Create executable in `lakefile.lean`:
```lean
lean_exe Tests where
  root := `TetraGray.Tests
```

Compare output with C++ test results in `tetra-gray/test.txt`.

### 2. Dynamic Stepsize (CRITICAL for Black Holes)

Create `TetraGray/Stepsize.lean`:

```lean
-- DynamicStepsizeAdjuster: scales stepsize based on maximum velocity
structure DynamicStepsizeAdjuster where
  maxVelocity : Float
  baseStepsize : Float

-- Adjust stepsize to ensure no particle moves too far in one step
def adjustStepsize (adjuster : DynamicStepsizeAdjuster)
    (particles : Array Particle) : Float :=
  let maxVel := particles.foldl
    (fun acc p => max acc (vectorLength p.momentum))
    0.0
  adjuster.baseStepsize * adjuster.maxVelocity / (max maxVel 1e-10)

-- DynamicStepsizeStopCondition: stops when ratio exceeds threshold
def stepsizeRatioStopCondition
    (maxRatio : Float)
    (baseStepsize currentStepsize : Float) : Bool :=
  currentStepsize / baseStepsize > maxRatio
```

### 3. Stop Conditions (REQUIRED for Termination)

Create `TetraGray/StopConditions.lean`:

```lean
-- Distance-based stop condition
def distanceStopCondition (radius : Float) (particle : Particle) : Bool :=
  vectorLength particle.position > radius

-- Time-based stop condition
def timeStopCondition (maxTime : Float) (odeData : ODEData) : Bool :=
  odeData.param > maxTime

-- Combined stop conditions (all must pass)
def combinedStopCondition (conditions : Array (α → Bool)) (data : α) : Bool :=
  conditions.all (fun cond => cond data)

-- Horizon detection via stepsize explosion
def horizonStopCondition
    (maxRatio : Float)
    (baseStepsize : Float)
    (particle : Particle)
    (currentStepsize : Float) : Bool :=
  currentStepsize / baseStepsize > maxRatio
```

### 4. Update Doran Module

Modify `TetraGray/Doran.lean` to use new coordinate systems:

```lean
import TetraGray.CoordSystems
import TetraGray.Particle
import TetraGray.ODE

def doranRHS (a : Float) (particle : Particle) (affineParam : Float)
    : Particle :=
  -- Convert position to spheroidal coordinates
  let spheroidal := CoordSystems.spheroidalFromCartesian a particle.position
  let mu := spheroidal.x
  let nu := spheroidal.y
  let phi := spheroidal.z

  -- Compute trig functions
  let sinh_mu := Float.sinh mu
  let cosh_mu := Float.cosh mu
  let sin_nu := Float.sin nu
  let cos_nu := Float.cos nu
  let sin_phi := Float.sin phi
  let cos_phi := Float.cos phi

  -- Get basis vectors
  let muhat := CoordSystems.spheroidalBasisVectorEmu
    sinh_mu cosh_mu sin_nu cos_nu sin_phi cos_phi
  let nuhat := CoordSystems.spheroidalBasisVectorEnu
    sinh_mu cosh_mu sin_nu cos_nu sin_phi cos_phi
  let phihat := CoordSystems.spheroidalBasisVectorPhi sin_phi cos_phi
  let that := CoordSystems.spheroidalBasisVectorT

  -- Compute Doran parameters
  let beta := CoordSystems.doranBeta cosh_mu sin_nu
  let doran_v := CoordSystems.doranVectorV beta that phihat

  -- Position RHS
  let posrhs := CoordSystems.doranPositionGauge
    sinh_mu muhat a doran_v particle.momentum

  -- Momentum RHS (geodesic equation)
  let momrhs := -(CoordSystems.doranRotationGauge
    sinh_mu cos_nu muhat nuhat phihat that
    beta doran_v a particle.momentum
    ⋅ particle.momentum)

  Particle.mk posrhs momrhs
```

### 5. Spherical Colormap (For Visualization)

Create `TetraGray/Colormap.lean`:

```lean
-- Convert particle final state to RGB color
structure SphericalColormap where
  extractRadius : Float

def sphericalColormap (config : SphericalColormap)
    (particle : Particle) : RGB :=
  -- Convert position to spherical coordinates
  let spherical := CoordSystems.sphericalFromCartesian particle.position
  let r := spherical.x
  let theta := spherical.y
  let phi := spherical.z

  -- Create 4 colored regions based on latitude/longitude
  let latRegion := (theta / Float.pi * 4).floor.toUInt8 % 4
  let lonRegion := (phi / (2 * Float.pi) * 8).floor.toUInt8 % 8

  -- Paint gridlines
  let onGrid :=
    (theta % (Float.pi / 8) < 0.05) ||
    (phi % (Float.pi / 4) < 0.05)

  if onGrid then
    RGB.mk 1.0 1.0 1.0  -- white gridlines
  else
    -- Color regions
    match latRegion, lonRegion with
    | 0, _ => RGB.mk 1.0 0.0 0.0  -- red
    | 1, _ => RGB.mk 0.0 1.0 0.0  -- green
    | 2, _ => RGB.mk 0.0 0.0 1.0  -- blue
    | _, _ => RGB.mk 1.0 1.0 0.0  -- yellow
```

### 6. Full Raytracer Pipeline

Update `TetraGray/Raytracer.lean` or create new version:

```lean
-- Image initial data: convert pixel index to photon
def imageInitialData
    (cameraPos : MV4 Float)
    (cameraOrient : Versor Float)
    (imgWidth imgHeight : Nat)
    (hfov : Float)
    (stepsize : Float)
    (pixelIdx : Nat) : Particle :=
  let x := pixelIdx % imgWidth
  let y := pixelIdx / imgWidth

  -- Compute angles from center
  let aspectRatio := imgWidth.toFloat / imgHeight.toFloat
  let hAngle := hfov * (x.toFloat / imgWidth.toFloat - 0.5)
  let vAngle := (hfov / aspectRatio) * (y.toFloat / imgHeight.toFloat - 0.5)

  -- Create photon direction
  let direction := ... -- rotate camera forward by hAngle, vAngle

  -- Apply camera orientation
  let rotatedDir := cameraOrient.applyToVector direction

  Particle.mk cameraPos rotatedDir

-- Full raytrace function
def raytrace
    (imgWidth imgHeight : Nat)
    (hfov : Float)
    (cameraPos : MV4 Float)
    (cameraOrient : Versor Float)
    (filename : String)
    (baseStepsize : Float)
    (rhs : Particle → Float → Particle)
    (stopCondition : Particle → Bool)
    (colormap : Particle → RGB)
    : IO Unit := do
  let numPixels := imgWidth * imgHeight
  let mut img := Image.black imgWidth imgHeight

  -- For each pixel
  for pixelIdx in [:numPixels] do
    -- Create initial photon
    let photon := imageInitialData cameraPos cameraOrient
      imgWidth imgHeight hfov baseStepsize pixelIdx

    -- Evolve photon with ODE integrator
    let finalPhoton := ODEIntegrator.integrate
      photon rhs stopCondition baseStepsize

    -- Convert to color
    let color := colormap finalPhoton

    -- Set pixel
    let x := pixelIdx % imgWidth
    let y := pixelIdx / imgWidth
    img := img.setPixel x y color

  -- Write image
  img.writePPM filename
```

## Testing Strategy

1. **Unit Tests First**
   - Run each test individually
   - Compare with C++ output in `tetra-gray/test.txt`
   - Fix any discrepancies

2. **Integration Tests**
   - Test coordinate transformations round-trip
   - Verify Doran RHS against known solutions
   - Check particle evolution conservation laws

3. **Visual Tests**
   - Render flat space with sphere (should match `images/flat.png`)
   - Render with black hole (compare to `images/doran.png`)
   - Verify gridlines and coloring

## Performance Notes

Current: Sequential CPU execution
- Expect ~100x slower than GPU initially
- Focus on correctness first

Future optimizations:
- Use `@[inline]` for hot functions
- Enable Lean's C backend optimizations
- Consider parallel array operations
- Profile with Lean's built-in profiler

## File Structure Summary

```
TetraGray/
├── Clifford.lean          ✅ Complete (90%)
├── CoordSystems.lean      ✅ Just added
├── Particle.lean          ✅ Exists
├── ODE.lean               ✅ Exists
├── Image.lean             ✅ Exists
├── Tests.lean             ❌ TODO (HIGH PRIORITY)
├── Stepsize.lean          ❌ TODO (CRITICAL)
├── StopConditions.lean    ❌ TODO (REQUIRED)
├── Colormap.lean          ❌ TODO
├── Raytracer.lean         ⚠️  Exists but needs update
├── Doran.lean             ⚠️  Exists but needs update
└── SimpleRaytracer.lean   ✅ Works
```

## Quick Wins (Can Do in <30 min each)

1. Add `makeMultivectorFromGrade1` helper to Clifford.lean
2. Add `vectorLength` helper to Particle.lean
3. Port 5-10 simple tests from test.cu
4. Add `max` and `min` helpers for Float arrays
5. Create `Particle.fromArrays` constructor

## Long-term Goals

1. **Proofs of Correctness**
   - Prove versor norm preservation
   - Prove coordinate transformation invertibility
   - Prove energy conservation in flat space

2. **Generic Dimensions**
   - Make Clifford algebra work for Cl(p,q,r)
   - Dependent types for dimensionality

3. **Performance**
   - Parallel photon evolution
   - GPU compilation via Lean backend

4. **Visualization**
   - Real-time image viewer
   - Interactive parameter adjustment
   - Animation support

## Commands for Next Session

```bash
# Create test suite
touch TetraGray/Tests.lean
# Add to lakefile.lean:
# lean_exe Tests where
#   root := `TetraGray.Tests

# Run tests
lake build Tests
.lake/build/bin/Tests

# Compare with C++
cd tetra-gray && ./test > ../lean_test_output.txt
cd .. && diff tetra-gray/test.txt lean_test_output.txt

# Visual test
./dev-loop.sh

# Watch mode while developing
./watch-dev.sh
```

## Key Insights

1. **Math is 90% done** - Core algebra works
2. **Infrastructure exists** - Build system, dev loop
3. **Missing: Integration** - Need to wire components together
4. **Test-driven next** - Verify correctness before adding features

## Expected Timeline

- Tests: 2-3 hours (port from C++)
- Dynamic stepsize: 1 hour
- Stop conditions: 1 hour
- Doran RHS update: 2 hours
- Colormap: 1-2 hours
- Full pipeline: 2-3 hours
- **Total: ~10-12 hours to full parity**

Then can focus on proofs, optimizations, and new features.
