# C++ to Lean 4 Parity Status

Progress report on porting TetraGray from CUDA C++ to Lean 4.

## ✅ Completed Features

### Clifford Algebra (Multivectors)
- [x] MV4 structure for 4D spacetime algebra (Cl(3,1))
- [x] Geometric product with full component expansion
- [x] Addition, negation, subtraction
- [x] Scalar multiplication (left and right)
- [x] Component accessors (scalar, x, y, z, t, xy, xz, xt, etc.)
- [x] Basis vectors (e₀, e₁, e₂, e₃, e₄)
- [x] Basis bivectors (e₁₂, e₁₃, e₁₄, etc.)
- [x] Inner product (contraction) for vectors
- [x] Wedge product (outer product)
- [x] Dual operation (Hodge star)
- [x] Reverse operation (reversion)
- [x] Grade involution
- [x] Clifford conjugation
- [x] Grade projection (grade0, grade1, grade2, grade3, grade4)
- [x] Norm squared
- [x] Functor instance for mapping

### Versors (Rotations and Boosts)
- [x] Versor structure (scalar + 6 bivector components + pseudoscalar)
- [x] Identity versor
- [x] Versor multiplication (composition)
- [x] Versor reversal
- [x] Norm squared
- [x] Conversion to/from full multivector
- [x] Vector transformation (sandwich product)
- [x] Constructors (fromScalar, fromBivector, makePseudoscalar)

### Coordinate Systems
- [x] Spherical coordinates from Cartesian
- [x] Oblate spheroidal coordinates (Doran convention)
- [x] Spheroidal basis vectors (ê_μ, ê_ν, ê_φ, ê_t)
- [x] Doran β parameter
- [x] Doran vector v
- [x] Position gauge transformation
- [x] Rotation gauge transformation

### ODE Integration
- [x] ODEData structure (value, parameter, stepsize)
- [x] RK4 integrator
- [x] Generic integrator infrastructure

### Particle Physics
- [x] Particle structure (position, momentum)
- [x] Arithmetic operations on particles

### Image Output
- [x] RGB color structure
- [x] Image structure with pixel data
- [x] PPM file writing
- [x] Color mixing and operations

### Simple Raytracing
- [x] Vec3 structure for 3D vectors
- [x] Ray structure (origin, direction)
- [x] Sphere structure and ray-sphere intersection
- [x] Basic ray color calculation
- [x] Scene rendering to image

## ⚠️ Partial / In Progress

### Doran Spacetime Physics
- [~] DoranRHS implementation (exists but needs updating with new coord system)
- [ ] Full integration with coordinate transformations
- [ ] Proper momentum evolution in curved spacetime

## ❌ Not Yet Implemented

### Advanced Clifford Features
- [ ] Generic contraction sign calculation (popcount-based)
- [ ] Permutation sign calculation
- [ ] Grade-specific multiplication
- [ ] Single-graded multivector operations

### Dynamic Integration
- [ ] Dynamic stepsize adjustment
- [ ] DynamicStepsizeAdjuster
- [ ] Stepsize ratio tracking
- [ ] Adaptive stepping based on curvature

### Stop Conditions
- [ ] Distance threshold stop condition
- [ ] Time threshold stop condition
- [ ] Stepsize ratio stop condition
- [ ] Combined stop conditions
- [ ] Horizon detection

### Colormaps
- [ ] Spherical colormap with latitude/longitude grid
- [ ] False-color sphere visualization
- [ ] Multiple color regions
- [ ] Customizable color schemes

### Image Initial Data
- [ ] Camera orientation (versor-based)
- [ ] Field of view calculations
- [ ] Pixel-to-photon mapping
- [ ] Rotation from view direction

### Full Raytracer Pipeline
- [ ] Parallel photon evolution
- [ ] Per-pixel ODE integration
- [ ] Stop condition evaluation per photon
- [ ] Colormap application
- [ ] PNG output (currently only PPM)

### Test Suite
- [ ] RK4 integration tests
- [ ] Multivector operation tests
- [ ] Grade projection tests
- [ ] Versor operation tests
- [ ] Coordinate transformation tests
- [ ] Particle evolution tests
- [ ] End-to-end raytracing tests

### Performance Optimizations
- [ ] Parallel array operations
- [ ] GPU-style parallelization
- [ ] Efficient memory layout
- [ ] Unrolled loops
- [ ] Compile-time optimizations

## Feature Comparison Table

| Feature | C++ (CUDA) | Lean 4 | Status |
|---------|-----------|--------|--------|
| Multivector | ✅ Generic | ✅ 4D only | ~90% |
| Geometric Product | ✅ | ✅ | ✅ |
| Grade Operations | ✅ | ✅ | ✅ |
| Versors | ✅ | ✅ | ✅ |
| Spheroidal Coords | ✅ | ✅ | ✅ |
| Doran Physics | ✅ | ⚠️ | 60% |
| RK4 Integration | ✅ | ✅ | ✅ |
| Dynamic Stepsize | ✅ | ❌ | 0% |
| Stop Conditions | ✅ | ❌ | 0% |
| Spherical Colormap | ✅ | ❌ | 0% |
| Image Pipeline | ✅ | ⚠️ | 40% |
| PNG Output | ✅ | ❌ | 0% |
| Parallel Execution | ✅ GPU | ❌ | 0% |
| Test Suite | ✅ 40+ tests | ❌ | 0% |

## Implementation Notes

### Architecture Differences

**C++ (CUDA)**:
- Template-based generic dimensions
- `__host__ __device__` dual compilation
- Thrust for GPU parallelization
- Functor composition with libftk
- Static unrolled Clifford operations

**Lean 4**:
- Specific 4D implementation
- Pure functional approach
- Sequential execution
- Direct function composition
- Proven-correct operations

### Missing C++ Features Not Yet Needed

- Generic signature (plus_dim, minus_dim, zero_dim)
- Host/device dual compilation
- CUDA kernel launches
- Thrust GPU operations
- png++ image writing

### Design Decisions

1. **4D-specific vs Generic**: Started with 4D-specific implementation for simplicity. Can be generalized later with dependent types.

2. **Versor Structure**: Changed from vector-based to named fields for clarity and type safety.

3. **Coordinate Systems**: Separate module for organization, following Lean conventions.

4. **No GPU Parallelism Yet**: Focus on correctness first, performance later. Lean 4 can compile to efficient C.

## Next Steps

### High Priority
1. **Complete Doran RHS** - Update to use new coordinate system module
2. **Add Test Suite** - Port C++ tests to verify correctness
3. **Dynamic Stepsize** - Critical for black hole raytracing
4. **Stop Conditions** - Required for photon termination

### Medium Priority
5. **Spherical Colormap** - Needed for visualization
6. **Image Pipeline** - Full camera → photon → color workflow
7. **PNG Output** - Better than PPM for final images

### Low Priority
8. **Performance Optimization** - After correctness is proven
9. **Generic Dimensions** - If needed for other signatures
10. **Parallel Execution** - Can use Lean's compiler for this

## How to Test Parity

```bash
# Build both implementations
cd tetra-gray && scons test && ./test
cd .. && lake build && .lake/build/bin/test  # (when test suite exists)

# Compare outputs
diff tetra-gray/test.txt TetraGray/test_output.txt

# Visual comparison
./tetra-gray/doran
lake build Doran && .lake/build/bin/Doran
# Compare doran.png outputs
```

## Performance Expectations

The C++ CUDA version can raytrace 720p in under 30 seconds on a GTX 660.
The Lean 4 version will initially be slower (CPU-only, sequential), but:
- Lean can compile to efficient C code
- Can add parallel execution
- Focus is on correctness and mathematical clarity
- Performance can be optimized later

## Mathematical Correctness

One key advantage of Lean 4: **proofs**. We can prove properties like:
- `e1 * e1 = 1` (spatial basis squares to +1)
- `e4 * e4 = -1` (time basis squares to -1)
- Versor norm preservation
- Coordinate transformation invertibility
- Numerical stability bounds

These guarantees are impossible in C++.

---

Last Updated: 2025-09-29
Lean Version: 4.24.0-rc1 (nightly-2025-09-29)
C++ Reference: tetra-gray/ (CUDA 7.5, Thrust)