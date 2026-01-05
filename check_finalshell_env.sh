#!/bin/bash
#
# finalshell-env-check
# A user-level preflight script to verify Linux environment compatibility
# with FinalShell server monitoring.
#
# Copyright (c) 2026 jysir99
# MIT License

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Exit codes
EXIT_SUCCESS=0
EXIT_MISSING_COMMAND=101
EXIT_READ_ERROR=102
EXIT_LOCALE_ERROR=103
EXIT_COLLECTION_FAILED=104

# Track failures
FAILURES=0
FAILURE_REASONS=()

# Function to check if a command exists
check_command() {
    local cmd=$1
    if command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}[ OK ]${NC} command '$cmd' exists"
        return 0
    else
        echo -e "${RED}[FAIL]${NC} command '$cmd' NOT found"
        FAILURES=$((FAILURES + 1))
        FAILURE_REASONS+=("Missing command: $cmd")
        return 1
    fi
}

# Function to check file readability
check_file_readable() {
    local file=$1
    if [ -r "$file" ]; then
        echo -e "${GREEN}[ OK ]${NC} file '$file' is readable"
        return 0
    else
        echo -e "${RED}[FAIL]${NC} file '$file' is NOT readable"
        FAILURES=$((FAILURES + 1))
        FAILURE_REASONS+=("Cannot read file: $file")
        return 1
    fi
}

# Function to check locale compatibility
check_locale() {
    if locale -a 2>/dev/null | grep -q "^en_US"; then
        echo -e "${GREEN}[ OK ]${NC} locale 'en_US' is available"
        return 0
    else
        echo -e "${YELLOW}[WARN]${NC} locale 'en_US' may not be available (non-critical)"
        return 0
    fi
}

# Function to simulate FinalShell's core data collection
simulate_finalshell_collection() {
    local exit_code=0
    
    # Simulate FinalShell's monitoring command sequence
    # Based on reverse analysis of FinalShell behavior
    
    # 1. Check uptime (used for system uptime)
    if ! uptime >/dev/null 2>&1; then
        exit_code=$EXIT_MISSING_COMMAND
        FAILURE_REASONS+=("uptime command failed")
    fi
    
    # 2. Check free (used for memory info)
    if ! free -m >/dev/null 2>&1; then
        exit_code=$EXIT_MISSING_COMMAND
        FAILURE_REASONS+=("free command failed")
    fi
    
    # 3. Check df (used for disk usage)
    if ! df -h >/dev/null 2>&1; then
        exit_code=$EXIT_MISSING_COMMAND
        FAILURE_REASONS+=("df command failed")
    fi
    
    # 4. Check /proc/net/dev (used for network stats)
    if ! cat /proc/net/dev >/dev/null 2>&1; then
        exit_code=$EXIT_READ_ERROR
        FAILURE_REASONS+=("Cannot read /proc/net/dev")
    fi
    
    if [ $exit_code -eq 0 ]; then
        echo -e "${GREEN}[ OK ]${NC} FinalShell core data collection succeeded"
        return 0
    else
        echo -e "${RED}[FAIL]${NC} FinalShell core data collection failed (exit code=$exit_code)"
        FAILURES=$((FAILURES + 1))
        return $exit_code
    fi
}

# Main execution
main() {
    echo "=========================================="
    echo "FinalShell Environment Compatibility Check"
    echo "=========================================="
    echo ""
    
    # Check required commands
    echo "Checking required commands..."
    check_command "bash"
    check_command "free"
    check_command "uptime"
    check_command "df"
    echo ""
    
    # Check required file access
    echo "Checking file access..."
    check_file_readable "/proc/net/dev"
    echo ""
    
    # Check locale (non-critical warning)
    echo "Checking locale compatibility..."
    check_locale
    echo ""
    
    # Simulate FinalShell's actual monitoring sequence
    echo "Simulating FinalShell monitoring sequence..."
    simulate_finalshell_collection || true
    echo ""
    
    # Final verdict
    echo "=========================================="
    if [ $FAILURES -eq 0 ]; then
        echo -e "${GREEN}✅ Environment is compatible with FinalShell server monitoring${NC}"
        exit $EXIT_SUCCESS
    else
        echo -e "${RED}❌ Environment is NOT compatible with FinalShell server monitoring${NC}"
        echo ""
        echo "Failure reasons:"
        for reason in "${FAILURE_REASONS[@]}"; do
            echo -e "  ${RED}•${NC} $reason"
        done
        exit $EXIT_COLLECTION_FAILED
    fi
}

# Run main function
main "$@"

