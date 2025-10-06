#!/bin/bash

TEST_WORKSPACE="/tmp/devstack_test_$$"
mkdir -p "$TEST_WORKSPACE"

GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

# Test tracking variables
TOTAL_TESTS=0
PASSED_TESTS=0
FAILED_TESTS=0
TEST_RESULTS=()

print_pass() { 
    echo -e "${GREEN}PASS${NC}: $1"
    PASSED_TESTS=$((PASSED_TESTS + 1))
    TEST_RESULTS+=("PASS: $1")
}

print_fail() { 
    echo -e "${RED}FAIL${NC}: $1"
    FAILED_TESTS=$((FAILED_TESTS + 1))
    TEST_RESULTS+=("FAIL: $1")
}

show_remotes() {
    local repo_name=$1
    local label=$2
    echo "  $label - $repo_name:"
    if [ -d "$repo_name" ]; then
        cd "$repo_name"
        git remote -v | sed 's/^/    /'
        cd ..
    fi
}

create_test_repo() {
    local repo_name=$1
    local origin_url=$2
    mkdir -p "$repo_name"
    cd "$repo_name"
    git init -q
    git remote add origin "$origin_url"
    git config user.email "test@example.com"
    git config user.name "Test User"
    echo "# $repo_name" > README.md
    git add README.md
    git commit -q -m "Initial commit"
    cd ..
}

echo "TEST 1: EDX Origin Repository"
TOTAL_TESTS=$((TOTAL_TESTS + 1))
cd "$TEST_WORKSPACE"
create_test_repo "ecommerce" "https://github.com/edx/ecommerce.git"
show_remotes "ecommerce" "BEFORE"
cd /workspaces/devstack
echo "  Output:"
DEVSTACK_WORKSPACE="$TEST_WORKSPACE" make dev.setup-remotes
cd "$TEST_WORKSPACE"
show_remotes "ecommerce" "AFTER"
cd ecommerce
if git remote | grep -q "edx" && git remote | grep -q "openedx" && ! git remote | grep -q "origin"; then
    print_pass "EDX origin handling"
else
    print_fail "EDX origin handling"
fi
cd ..

echo
echo "TEST 2: EDX Origin Repository (edx-platform)"
TOTAL_TESTS=$((TOTAL_TESTS + 1))
create_test_repo "edx-platform" "https://github.com/edx/edx-platform.git"
show_remotes "edx-platform" "BEFORE"
cd /workspaces/devstack
echo "  Output:"
DEVSTACK_WORKSPACE="$TEST_WORKSPACE" make dev.setup-remotes
cd "$TEST_WORKSPACE"
show_remotes "edx-platform" "AFTER"
cd edx-platform
if git remote | grep -q "openedx" && git remote | grep -q "edx" && ! git remote | grep -q "origin"; then
    print_pass "EDX origin handling (edx-platform)"
else
    print_fail "EDX origin handling (edx-platform)"
fi
cd ..

echo
echo "TEST 3: OpenEDX Origin Repository (course-discovery)"
TOTAL_TESTS=$((TOTAL_TESTS + 1))
create_test_repo "course-discovery" "https://github.com/openedx/course-discovery.git"
show_remotes "course-discovery" "BEFORE"
cd /workspaces/devstack
echo "  Output:"
DEVSTACK_WORKSPACE="$TEST_WORKSPACE" make dev.setup-remotes
cd "$TEST_WORKSPACE"
show_remotes "course-discovery" "AFTER"
cd course-discovery
if git remote | grep -q "openedx" && git remote | grep -q "edx" && ! git remote | grep -q "origin"; then
    print_pass "OpenEDX origin handling (course-discovery)"
else
    print_fail "OpenEDX origin handling (course-discovery)"
fi
cd ..

echo
echo "TEST 4: Personal Fork Error"
TOTAL_TESTS=$((TOTAL_TESTS + 1))
create_test_repo "credentials" "https://github.com/personaluser/credentials.git"
show_remotes "credentials" "BEFORE"
cd /workspaces/devstack
echo "  Output:"
DEVSTACK_WORKSPACE="$TEST_WORKSPACE" make dev.setup-remotes
cd "$TEST_WORKSPACE"
show_remotes "credentials" "AFTER"
cd credentials
if git remote get-url origin | grep -q "personaluser"; then
    print_pass "Personal fork error detection"
else
    print_fail "Personal fork error detection"
fi
cd ..

echo
echo "TEST 5: Non-Forked Repository"
TOTAL_TESTS=$((TOTAL_TESTS + 1))
create_test_repo "unknown-repo" "https://github.com/edx/unknown-repo.git"
show_remotes "unknown-repo" "BEFORE"
cd /workspaces/devstack
echo "  Output:"
DEVSTACK_WORKSPACE="$TEST_WORKSPACE" make dev.setup-remotes
cd "$TEST_WORKSPACE"
show_remotes "unknown-repo" "AFTER"
cd unknown-repo
if git remote | grep -q "^origin$" && [ $(git remote | wc -l) -eq 1 ]; then
    print_pass "Non-forked repository handling"
else
    print_fail "Non-forked repository handling"
fi
cd ..

echo
echo "TEST 6: Idempotent Operations"
TOTAL_TESTS=$((TOTAL_TESTS + 1))
create_test_repo "ecommerce" "https://github.com/edx/ecommerce.git"
show_remotes "ecommerce" "BEFORE (fresh repo)"
cd /workspaces/devstack
echo "  First run output:"
DEVSTACK_WORKSPACE="$TEST_WORKSPACE" make dev.setup-remotes
cd "$TEST_WORKSPACE"
show_remotes "ecommerce" "AFTER FIRST RUN"
cd /workspaces/devstack
echo "  Second run output (should be idempotent):"
DEVSTACK_WORKSPACE="$TEST_WORKSPACE" make dev.setup-remotes
cd "$TEST_WORKSPACE"
show_remotes "ecommerce" "AFTER SECOND RUN (should be identical)"
cd ecommerce
if [ $(git remote | wc -l) -eq 2 ] && git remote | grep -q "edx" && git remote | grep -q "openedx"; then
    print_pass "Idempotent operations"
else
    print_fail "Idempotent operations"
fi
cd ..

echo
echo "TEST 7: Make Integration"
TOTAL_TESTS=$((TOTAL_TESTS + 1))
cd /workspaces/devstack
if make -n dev.setup-remotes >/dev/null 2>&1 && make help | grep -q "dev.setup-remotes"; then
    print_pass "Make command integration"
else
    print_fail "Make command integration"
fi

rm -rf "$TEST_WORKSPACE"

echo
echo "======================================================================"
echo -e "${BLUE}TEST SUMMARY${NC}"
echo "======================================================================"
echo "Total Test Cases: $TOTAL_TESTS"
echo -e "Passed: ${GREEN}$PASSED_TESTS${NC}"
echo -e "Failed: ${RED}$FAILED_TESTS${NC}"
echo
echo "Test Results:"
for result in "${TEST_RESULTS[@]}"; do
    if [[ $result == PASS:* ]]; then
        echo -e "  ${GREEN}${result}${NC}"
    else
        echo -e "  ${RED}${result}${NC}"
    fi
done
echo
if [ $FAILED_TESTS -eq 0 ]; then
    echo -e "${GREEN}All tests passed successfully!${NC}"
    exit 0
else
    echo -e "${RED}$FAILED_TESTS test(s) failed.${NC}"
    exit 1
fi
