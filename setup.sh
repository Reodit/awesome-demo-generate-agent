#!/bin/bash

# awesome-demo-generate-agent setup script
# Usage: bash setup.sh

set -e

echo "========================================"
echo "  awesome-demo-generate-agent Setup"
echo "========================================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Get project directory
PROJECT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 1. Check Node.js
echo "1. Checking Node.js..."
if ! command -v node &> /dev/null; then
    echo -e "${RED}Error: Node.js is not installed${NC}"
    echo "Please install Node.js 18+ from https://nodejs.org"
    exit 1
fi

NODE_VERSION=$(node -v | cut -d'v' -f2 | cut -d'.' -f1)
if [ "$NODE_VERSION" -lt 18 ]; then
    echo -e "${RED}Error: Node.js 18+ required (current: $(node -v))${NC}"
    exit 1
fi
echo -e "${GREEN}   Node.js $(node -v) OK${NC}"

# 2. Check pnpm
echo ""
echo "2. Checking pnpm..."
if ! command -v pnpm &> /dev/null; then
    echo -e "${YELLOW}   pnpm not found. Installing...${NC}"
    npm install -g pnpm
fi
echo -e "${GREEN}   pnpm $(pnpm -v) OK${NC}"

# 3. Check Claude Code CLI
echo ""
echo "3. Checking Claude Code CLI..."
if ! command -v claude &> /dev/null; then
    echo -e "${YELLOW}   Claude Code CLI not found.${NC}"
    echo "   Install: npm install -g @anthropic-ai/claude-code"
    echo "   Or visit: https://claude.ai/claude-code"
else
    echo -e "${GREEN}   Claude Code CLI OK${NC}"
fi

# 4. Setup .mcp.json
echo ""
echo "4. Setting up MCP configuration..."
if [ -f "$PROJECT_DIR/.mcp.json" ]; then
    echo -e "${YELLOW}   .mcp.json already exists. Skipping...${NC}"
    echo "   Delete it and re-run setup to reconfigure."
else
    cp "$PROJECT_DIR/.mcp.json.example" "$PROJECT_DIR/.mcp.json"

    # Replace placeholder with actual project path
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s|/path/to/your/project|$PROJECT_DIR|g" "$PROJECT_DIR/.mcp.json"
    else
        sed -i "s|/path/to/your/project|$PROJECT_DIR|g" "$PROJECT_DIR/.mcp.json"
    fi

    echo -e "${GREEN}   .mcp.json created${NC}"
    echo ""
    echo "   Optional: Edit .mcp.json to add API keys:"
    echo "   - BRAVE_API_KEY: For web search (https://brave.com/search/api/)"
    echo "   - GITHUB_PERSONAL_ACCESS_TOKEN: For GitHub integration"
fi

# 5. Pre-install MCP server packages (optional)
echo ""
echo "5. Pre-installing MCP server packages..."
read -p "   Install MCP packages now? (recommended) [Y/n]: " install_mcp
install_mcp=${install_mcp:-Y}

if [[ "$install_mcp" =~ ^[Yy]$ ]]; then
    echo "   Installing @modelcontextprotocol/server-filesystem..."
    npx -y @modelcontextprotocol/server-filesystem --version 2>/dev/null || true

    echo "   Installing @modelcontextprotocol/server-puppeteer..."
    npx -y @modelcontextprotocol/server-puppeteer --version 2>/dev/null || true

    echo -e "${GREEN}   MCP packages installed${NC}"
else
    echo -e "${YELLOW}   Skipped. Packages will install on first use.${NC}"
fi

# 6. Install Playwright browsers (optional, for mobile validation)
echo ""
echo "6. Playwright browsers (for mobile screenshot validation)..."
read -p "   Install Playwright Chromium? [y/N]: " install_playwright
install_playwright=${install_playwright:-N}

if [[ "$install_playwright" =~ ^[Yy]$ ]]; then
    echo "   Installing Playwright Chromium..."
    npx -y playwright install chromium
    echo -e "${GREEN}   Playwright Chromium installed${NC}"
else
    echo -e "${YELLOW}   Skipped. Will install when needed.${NC}"
fi

# Done
echo ""
echo "========================================"
echo -e "${GREEN}  Setup Complete!${NC}"
echo "========================================"
echo ""
echo "Next steps:"
echo "  1. cd $PROJECT_DIR"
echo "  2. claude ."
echo ""
echo "Try asking:"
echo '  "포트폴리오 웹사이트를 만들어줘"'
echo ""
