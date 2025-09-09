#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting Transformer Lab Container${NC}"

# Handle PUID/PGID similar to LinuxServer containers
PUID=${PUID:-1000}
PGID=${PGID:-1000}

# Initialize conda environment
source "${MINIFORGE_ROOT}/etc/profile.d/conda.sh"
conda activate "${ENV_DIR}"

# Function to start Transformer Lab
start_transformerlab() {
    echo -e "${GREEN}📊 Starting Transformer Lab...${NC}"
    cd "${TLAB_CODE_DIR}"
    
    # Check if run.sh exists, if not create a simple startup script
    if [ ! -f "./run.sh" ]; then
        echo -e "${YELLOW}⚠️  Creating run.sh script${NC}"
        cat > run.sh << 'EOF'
#!/bin/bash
source ~/.transformerlab/miniforge3/etc/profile.d/conda.sh
conda activate ~/.transformerlab/envs/transformerlab
python -m uvicorn transformerlab.routers.main:app --host 0.0.0.0 --port 8000 --reload
EOF
        chmod +x run.sh
    fi
    
    # Start Transformer Lab
    echo -e "${GREEN}🔥 Launching Transformer Lab on port 8000...${NC}"
    exec ./run.sh
}

# Function to wait for service to be ready
wait_for_service() {
    echo -e "${BLUE}⏳ Waiting for Transformer Lab to be ready...${NC}"
    
    for i in {1..30}; do
        if curl -s http://localhost:8000/health >/dev/null 2>&1 || curl -s http://localhost:8000 >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Transformer Lab is ready!${NC}"
            break
        fi
        sleep 2
    done
}

# Function to display access information
show_access_info() {
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}🎉 Transformer Lab Container is Ready!${NC}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${YELLOW}📊 Transformer Lab Web UI:${NC}  http://localhost:8000"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}📁 Workspace:${NC}               /home/abc/workspace"
    echo -e "${BLUE}🧠 Transformer Lab Code:${NC}    ${TLAB_CODE_DIR}"
    echo -e "${BLUE}🐍 Conda Environment:${NC}       ${ENV_DIR}"
    echo -e "${BLUE}⚙️  Configuration:${NC}          /config"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
}

# Main execution
case "${1:-transformerlab}" in
    "transformerlab"|*)
        show_access_info
        start_transformerlab
        ;;
esac
