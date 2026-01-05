#!/usr/bin/env bash
#
# finalshell-env-check
# A user-level preflight script to verify Linux environment compatibility
# with FinalShell server monitoring.
#
# Copyright (c) 2026 jysir99
# MIT License

# Don't exit on error - we want to complete all checks
set -uo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Exit codes
EXIT_SUCCESS=0
EXIT_COLLECTION_FAILED=104

# Track failures
FAIL=0

# Function to check if a command exists
check_cmd() {
    local cmd="$1"
    if command -v "$cmd" >/dev/null 2>&1; then
        echo -e "${GREEN}[ OK ]${NC} command '$cmd' exists"
        return 0
    else
        echo -e "${RED}[FAIL]${NC} command '$cmd' NOT found"
        FAIL=1
        return 1
    fi
}

# Function to check file readability
check_file_readable() {
    local f="$1"
    if [ -r "$f" ]; then
        echo -e "${GREEN}[ OK ]${NC} file '$f' is readable"
        return 0
    else
        echo -e "${RED}[FAIL]${NC} file '$f' is NOT readable"
        FAIL=1
        return 1
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
    check_cmd bash || true
    check_cmd free || true
    check_cmd uptime || true
    check_cmd df || true
    echo ""
    
    # Check required file access
    echo "Checking file access..."
    check_file_readable /proc/net/dev || true
    echo ""
    
    # Check locale compatibility
    echo "Checking locale compatibility..."
    if locale -a 2>/dev/null | grep -qi '^en_US'; then
        echo -e "${GREEN}[ OK ]${NC} locale 'en_US' is available"
    else
        echo -e "${YELLOW}[WARN]${NC} locale 'en_US' may not be available (non-critical)"
    fi
    echo ""
    
    # Simulate FinalShell's actual monitoring sequence
    echo "Simulating FinalShell monitoring sequence..."
    TMP_OUT=$(mktemp 2>/dev/null || echo /tmp/finalshell_check_$$)
    
    bash -c '
export LANG="en_US"
export LANGUAGE="en_US"
export LC_ALL="en_US"

free || exit 101
echo finalshell_separator
uptime || exit 102
echo finalshell_separator
cat /proc/net/dev || exit 103
echo finalshell_separator
df || exit 104
' >"$TMP_OUT" 2>&1

    RET=$?

    if [ $RET -eq 0 ]; then
        echo -e "${GREEN}[ OK ]${NC} FinalShell core data collection succeeded"
    else
        echo -e "${RED}[FAIL]${NC} FinalShell core data collection failed (exit code=$RET)"
        FAIL=1
    fi

    rm -f "$TMP_OUT" 2>/dev/null || true
    echo ""
    
    # Final verdict
    echo "=========================================="
    if [ $FAIL -eq 0 ]; then
        echo -e "${GREEN}✅ Environment is compatible with FinalShell server monitoring${NC}"
        exit $EXIT_SUCCESS
    else
        echo -e "${RED}❌ Environment is NOT compatible with FinalShell server monitoring${NC}"
        exit $EXIT_COLLECTION_FAILED
    fi
}

# Run main function
main "$@"

