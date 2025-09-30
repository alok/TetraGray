#!/bin/bash
# Watch loop for TetraGray development
# Monitors Lean files and automatically rebuilds/displays on changes

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo -e "${BLUE}=== TetraGray Watch Mode ===${NC}"
echo -e "${YELLOW}Watching TetraGray/*.lean files for changes...${NC}"
echo -e "${YELLOW}Press Ctrl+C to stop${NC}"
echo ""

# Function to build and display
build_and_display() {
    echo -e "\n${BLUE}[$(date +%H:%M:%S)] Change detected, rebuilding...${NC}"

    if lake build SimpleRaytracer 2>&1 | grep -q "error:"; then
        echo -e "${YELLOW}Build has errors, skipping image generation${NC}"
        return
    fi

    .lake/build/bin/SimpleRaytracer

    if [ -f "sphere_render.ppm" ]; then
        sips -s format png sphere_render.ppm --out sphere_render.png 2>/dev/null
        echo -e "${GREEN}✓ Updated: sphere_render.png ($(date +%H:%M:%S))${NC}"
        # Don't auto-open on every change to avoid window spam
        # User can manually open/refresh the image
    fi
}

# Check if fswatch is available
if command -v fswatch &> /dev/null; then
    echo -e "${GREEN}Using fswatch${NC}"
    # Run once initially
    build_and_display
    # Then watch
    fswatch -o TetraGray/*.lean | while read; do
        build_and_display
    done
elif command -v hwatch &> /dev/null; then
    echo -e "${GREEN}Using hwatch${NC}"
    hwatch -n 2 "./dev-loop.sh"
else
    echo -e "${YELLOW}No file watcher found. Install fswatch or hwatch:${NC}"
    echo "  brew install fswatch"
    echo "  brew install hwatch"
    echo ""
    echo -e "${YELLOW}Falling back to manual loop (polling every 3 seconds)${NC}"

    build_and_display

    LAST_MOD=0
    while true; do
        sleep 3
        CURRENT_MOD=$(find TetraGray -name "*.lean" -type f -exec stat -f %m {} \; | sort -n | tail -1)
        if [ "$CURRENT_MOD" != "$LAST_MOD" ]; then
            LAST_MOD=$CURRENT_MOD
            build_and_display
        fi
    done
fi