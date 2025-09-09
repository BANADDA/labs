#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${BLUE}🚀 Starting Transformer Lab Container${NC}"

# Initialize conda
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
    
    # Start Transformer Lab in background
    ./run.sh &
    TLAB_PID=$!
    echo -e "${GREEN}✅ Transformer Lab started (PID: $TLAB_PID)${NC}"
    return $TLAB_PID
}

# Function to start VS Code Server
start_code_server() {
    echo -e "${GREEN}💻 Starting VS Code Server...${NC}"
    
    # Create code-server config directory
    mkdir -p ~/.config/code-server
    
    # Generate config if it doesn't exist
    if [ ! -f ~/.config/code-server/config.yaml ]; then
        cat > ~/.config/code-server/config.yaml << EOF
bind-addr: 0.0.0.0:8080
auth: ${CODE_SERVER_AUTH:-password}
password: ${CODE_SERVER_PASSWORD:-transformerlab}
cert: false
disable-telemetry: true
disable-update-check: true
EOF
    fi
    
    # Start code-server
    code-server \
        --bind-addr 0.0.0.0:8080 \
        --user-data-dir /home/coder/.config/code-server/data \
        --extensions-dir /home/coder/.config/code-server/extensions \
        --disable-telemetry \
        --disable-update-check \
        /home/coder/workspace \
        &
    
    CODE_SERVER_PID=$!
    echo -e "${GREEN}✅ VS Code Server started (PID: $CODE_SERVER_PID)${NC}"
    return $CODE_SERVER_PID
}

# Function to wait for services to be ready
wait_for_services() {
    echo -e "${BLUE}⏳ Waiting for services to be ready...${NC}"
    
    # Wait for Transformer Lab
    for i in {1..30}; do
        if curl -s http://localhost:8000/health >/dev/null 2>&1; then
            echo -e "${GREEN}✅ Transformer Lab is ready at http://localhost:8000${NC}"
            break
        fi
        sleep 2
    done
    
    # Wait for VS Code Server
    for i in {1..30}; do
        if curl -s http://localhost:8080 >/dev/null 2>&1; then
            echo -e "${GREEN}✅ VS Code Server is ready at http://localhost:8080${NC}"
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
    echo -e "${YELLOW}📊 Transformer Lab:${NC}     http://localhost:8000"
    echo -e "${YELLOW}💻 VS Code Server:${NC}      http://localhost:8080"
    echo -e "${YELLOW}🔑 VS Code Password:${NC}    ${CODE_SERVER_PASSWORD:-transformerlab}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
    echo -e "${BLUE}📁 Workspace:${NC}            /home/coder/workspace"
    echo -e "${BLUE}🧠 Transformer Lab:${NC}      ${TLAB_CODE_DIR}"
    echo -e "${BLUE}🐍 Conda Environment:${NC}    ${ENV_DIR}"
    echo -e "${BLUE}════════════════════════════════════════════════════════════════${NC}"
}

# Handle different startup modes
case "${1:-both}" in
    "transformerlab")
        start_transformerlab
        wait_for_services
        show_access_info
        # Keep container running
        tail -f /dev/null
        ;;
    "code-server")
        start_code_server
        wait_for_services
        show_access_info
        # Keep container running
        tail -f /dev/null
        ;;
    "both"|*)
        start_transformerlab
        start_code_server
        wait_for_services
        show_access_info
        
        # Keep container running and monitor processes
        while true; do
            if ! kill -0 $TLAB_PID 2>/dev/null; then
                echo -e "${RED}❌ Transformer Lab stopped, restarting...${NC}"
                start_transformerlab
            fi
            if ! kill -0 $CODE_SERVER_PID 2>/dev/null; then
                echo -e "${RED}❌ VS Code Server stopped, restarting...${NC}"
                start_code_server
            fi
            sleep 10
        done
        ;;
esac
