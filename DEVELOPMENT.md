# TetraGray Development Guide

## Quick Start

```bash
# One-shot: build, run, and view
./dev-loop.sh

# Watch mode: auto-rebuild on file changes
./watch-dev.sh
```

## Development Workflow

### Build and View Images

The project includes two helper scripts for rapid development:

1. **`dev-loop.sh`**: One-shot build and display
   - Builds the SimpleRaytracer executable
   - Runs it to generate a sphere_render.ppm
   - Converts to PNG using `sips` (macOS)
   - Opens the image in Preview

2. **`watch-dev.sh`**: Continuous development
   - Monitors `TetraGray/*.lean` files for changes
   - Automatically rebuilds and regenerates images
   - Uses `hwatch` or `fswatch` for file watching
   - Falls back to manual polling if neither is available

### Manual Build Commands

```bash
# Build everything
lake build

# Build specific executable
lake build SimpleRaytracer

# Run executable
.lake/build/bin/SimpleRaytracer

# Convert PPM to PNG manually
sips -s format png sphere_render.ppm --out sphere_render.png
```

## Project Structure

```
TetraGray/
├── TetraGray/
│   ├── Clifford.lean       # Geometric algebra (multivectors)
│   ├── Image.lean           # Image types and PPM output
│   ├── SimpleRaytracer.lean # Basic raytracer implementation
│   ├── Doran.lean           # Physics simulations
│   ├── ODE.lean             # ODE solvers (RK4)
│   └── ...
├── dev-loop.sh              # Quick dev cycle
├── watch-dev.sh             # Continuous rebuild
└── lakefile.lean            # Build configuration
```

## Lean 4 Features Used

### Geometric Algebra (Clifford.lean)

The project implements spacetime algebra (Cl(1,3)) for geometric physics:

- **Multivectors**: 16-component vectors in 4D spacetime
- **Geometric product**: Full algebraic structure
- **Basis vectors**: e₀ (scalar), e₁-e₄ (vectors), bivectors, trivectors, pseudoscalar
- **Signature**: (-,+,+,+) Minkowski metric for spacetime

### Proofs and Tactics

Basic proofs are included demonstrating:
- `rfl`: Reflexivity for definitional equalities
- Vector algebra properties
- Basis vector relationships

The `grind` tactic (inspired by SMT solvers) can be used for:
- Congruence closure and equality reasoning
- Linear integer arithmetic
- Commutative ring solving
- Proof by contradiction

Example:
```lean
theorem e0_scalar : (MV4.e0 : MV4 α).scalar = 1 := by
  rfl
```

### Multivector Code Generation (mvcgen)

The reference manual mentions `mvcgen` for multivector operations.
Currently, the geometric product is implemented manually with all
256 component computations explicit. Future work could use code generation.

## Image Output

Images are generated in PPM format (simple ASCII):
```
P3
width height
255
r g b  r g b  ...
```

PPM files are then converted to PNG for viewing:
- macOS: `sips -s format png input.ppm --out output.png`
- ImageMagick: `convert input.ppm output.png`

## Dependencies

Build requirements:
- Lean 4 (nightly-2025-09-29 or compatible)
- Lake (Lean build system)

Optional for development:
- `hwatch` or `fswatch` for watch mode
- `sips` (macOS) or ImageMagick for PNG conversion

Install watch tools:
```bash
brew install hwatch
brew install fswatch
brew install imagemagick  # if not using sips
```

## Tips

1. **Fast iteration**: Use `watch-dev.sh` and keep Preview open. Images auto-update.
2. **Debugging**: Check `.lake/build/bin/` for executables
3. **Proofs**: Start simple with `rfl`, add complexity gradually
4. **Multivectors**: Use `#eval!` to test multivector operations
5. **Performance**: Compile with `lake build` for production runs

## References

- [Lean 4 Reference Manual](https://lean-lang.org/doc/reference/latest/)
- [Grind Tactic](https://lean-lang.org/doc/reference/latest/The--grind--tactic/)
- [Geometric Algebra Resources](http://geocalc.clas.asu.edu/)
- [Doran & Lasenby - Geometric Algebra for Physicists](https://www.cambridge.org/core/books/geometric-algebra-for-physicists/)