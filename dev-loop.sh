#!/bin/bash
# Development loop for TetraGray raytracer
# Builds, runs, converts PPM to PNG, and displays the result

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== TetraGray Development Loop ===${NC}"

# Build the project
echo -e "${BLUE}Building project...${NC}"
lake build SimpleRaytracer

# Run the raytracer
echo -e "${BLUE}Running raytracer...${NC}"
.lake/build/bin/SimpleRaytracer

# Check if the PPM file was created
if [ -f "sphere_render.ppm" ]; then
    echo -e "${GREEN}✓ Image generated: sphere_render.ppm${NC}"

    # Convert PPM to PNG if sips is available (macOS)
    if command -v sips &> /dev/null; then
        echo -e "${BLUE}Converting to PNG...${NC}"
        sips -s format png sphere_render.ppm --out sphere_render.png 2>/dev/null
        echo -e "${GREEN}✓ PNG created: sphere_render.png${NC}"

        # Open the PNG
        open sphere_render.png
    else
        # Just open the PPM (Preview on macOS can handle it)
        echo -e "${BLUE}Opening image...${NC}"
        open sphere_render.ppm
    fi
else
    echo -e "${RED}✗ Image file not found${NC}"
    exit 1
fi

echo -e "${GREEN}=== Done! ===${NC}"