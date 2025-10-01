# 🚀 Quick Start for Next Context Window

## TL;DR - Where We Are

✅ **90% of math done** - Clifford algebra, versors, coordinates all work
⚠️ **Need integration** - Wire components together with tests
❌ **Missing features** - Dynamic stepsize, stop conditions, colormap

**Build status**: Everything compiles ✅
**Test status**: No tests yet ❌
**Next priority**: Port test suite → validate correctness

## Immediate Actions (Do These First)

### 1. Create Test Suite (30 minutes)
```bash
# Create the file
touch TetraGray/Tests.lean

# Add this content:
cat > TetraGray/Tests.lean << 'EOF'
import TetraGray.Clifford
import TetraGray.ODE
import TetraGray.Particle

open MultiVector

-- Test from test.cu line 100-106
def rk4_test : IO Unit := do
  let result := ODEIntegrator.integrate
    (ODEData.mk 0.0 (-1.0) 0.2)
    RK4
    (fun val param => -2.0 * val + param)
    (fun od => od.param >= 1.0)
  IO.println s!"rk4_test(): {result.value}"
  -- Expected: 0.263753

-- Test from test.cu line 145-148
def choose_test : IO Unit := do
  IO.println s!"choose_test(): {Nat.choose 4 2}"
  -- Expected: 6

def main : IO Unit := do
  rk4_test
  choose_test
EOF

# Update lakefile.lean - add this:
lean_exe Tests where
  root := `TetraGray.Tests

# Build and run
lake build Tests
.lake/build/bin/Tests
```

### 2. Implement Dynamic Stepsize (30 minutes)
```bash
touch TetraGray/Stepsize.lean
# See NEXT_STEPS.md section 2 for full code template
```

### 3. Implement Stop Conditions (20 minutes)
```bash
touch TetraGray/StopConditions.lean
# See NEXT_STEPS.md section 3 for full code template
```

## File Roadmap

```
Priority 1 (Do Now):
  TetraGray/Tests.lean              ❌ Create
  TetraGray/Stepsize.lean           ❌ Create
  TetraGray/StopConditions.lean     ❌ Create

Priority 2 (Next):
  TetraGray/Doran.lean              ⚠️  Update with CoordSystems
  TetraGray/Colormap.lean           ❌ Create
  TetraGray/Raytracer.lean          ⚠️  Update pipeline

Already Done:
  TetraGray/Clifford.lean           ✅ 530 lines, complete
  TetraGray/CoordSystems.lean       ✅ 120 lines, new
  TetraGray/Particle.lean           ✅ 50 lines
  TetraGray/ODE.lean                ✅ 80 lines
  TetraGray/Image.lean              ✅ 105 lines
```

## Testing Against C++

```bash
# Run C++ tests (for reference output)
cd tetra-gray
scons test
./test > ../cpp_test_output.txt
cd ..

# Run Lean tests
lake build Tests
.lake/build/bin/Tests > lean_test_output.txt

# Compare
diff cpp_test_output.txt lean_test_output.txt

# Expected: Small floating point differences only
```

## Quick Verification Commands

```bash
# Does it build?
lake build

# Does simple raytracer work?
./dev-loop.sh

# Watch mode
./watch-dev.sh

# Check what's uncommitted
git status

# See recent work
git log --oneline -10
```

## Key Files to Reference

- **NEXT_STEPS.md** - Detailed implementation templates
- **SESSION_SUMMARY.md** - What we just did
- **CPP_PARITY.md** - Feature comparison table
- **DEVELOPMENT.md** - General workflow guide
- **tetra-gray/test.cu** - C++ test reference (lines 54-97)

## Expected Test Output

From `tetra-gray/test.txt`:
```
rk4_test(): 0.263753
popcount_test(): 3
ipow_test(): 81
choose_test(): 6
multivector_zero_test(): [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 ]
multivector_multiply_test(): [-12 0 0 -2 0 -4 -2 0 0 -6 -4 0 -2 0 0 0 ]
...
```

Port these one by one, comparing output.

## What's Different from C++

| Feature | C++ | Lean 4 |
|---------|-----|--------|
| Dimensions | Generic (template) | 4D only |
| Parallelism | GPU (Thrust) | Sequential |
| Tests | 40+ in test.cu | 0 (need to port) |
| Images | PNG | PPM (PNG TODO) |
| Speed | Fast (GPU) | Slower (CPU) |
| Correctness | Runtime checks | Can prove properties |

## Known Issues

1. **No `Float.max`** - Use `if x > y then x else y`
2. **No `Float.copysign`** - Use `if x >= 0 then abs y else -abs y`
3. **No parallel operations yet** - Sequential only
4. **PPM only** - PNG needs external library or converter

All known, all manageable.

## Success Criteria

✅ Tests pass with <1% error vs C++
✅ Flat space image matches `images/flat.png`
✅ Black hole image qualitatively matches `images/doran.png`
✅ All modules build without warnings
✅ Documentation complete

Then we can say: **Feature parity achieved** 🎉

## Time Estimates

- Test suite: 2-3 hours
- Dynamic stepsize: 1 hour
- Stop conditions: 1 hour
- Doran update: 2 hours
- Colormap: 1-2 hours
- Integration: 2-3 hours
- **Total: 10-12 hours**

## Common Commands

```bash
# Build everything
lake build

# Build specific module
lake build TetraGray.Tests

# Run executable
.lake/build/bin/Tests

# Clean build
lake clean && lake build

# Format code (if using lean4-mode)
lean --run format TetraGray/Tests.lean

# Check for errors without building
lean TetraGray/Tests.lean
```

## Git State

Branch: `main`
Commits this session: 6
Uncommitted: None
Ready to continue: ✅

## Context for LLM

Previous agent accomplished:
1. Fixed all build errors
2. Enhanced Clifford algebra (grade operations, conjugation)
3. Restructured Versor with named fields
4. Created CoordSystems module (spherical, spheroidal)
5. Added development loop scripts
6. Documented C++ parity status

Current state:
- Math library ~90% complete
- Infrastructure ready
- Need: tests, integration, validation

Goal: Achieve feature parity with C++ implementation

---

**Start here**: Create `TetraGray/Tests.lean` and port tests from `tetra-gray/test.cu` 🎯
