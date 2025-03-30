# TetraGray Justfile - Essential commands

# Build the project
build:
@echo "Building TetraGray..."
lake build
@echo "NOTE: The raytracer is still in development and not fully functional yet."

# Run the Doran scene (development only)
doran: build
@echo "Attempting to render Doran spinning black hole scene..."
@echo "NOTE: This feature is not fully implemented yet."
lake exe TetraGray doran || echo "Rendering failed. The raytracer is still in development."

# Clean all generated files
clean:
@echo "Cleaning build artifacts..."
lake clean
rm -f *.ppm *.png
