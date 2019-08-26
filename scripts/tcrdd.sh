#!/usr/bin/env bash
BRANCH=origin/master
TEST_KEYWORD="Expect"

function runTest() {
    ./node_modules/.bin/elm-test
}

# look for a new test in a + line in the diff
function testJustAdded(){
    [[ ! -z `git diff HEAD | grep "^\+.*${TEST_KEYWORD}"` ]]
}

RED_REF=refs/isRed

# amend in case of test refactoring (last commit is red, same test)
function commitOnRed() {
    git add . && \
    if lastCommitRed; then
        git commit --amend
    else
        git commit
    fi && \
    git update-ref ${RED_REF} HEAD
}

# amend if last commit was a test, with no change to the commit message
# in case if last commit was green commit with empty message (/?\ should refactoring have commit messages?)
# remove any RED tag reference
function commitOnGreen() {
    git add . && \
    if lastCommitRed; then
        git commit --amend --no-edit
    else
        git commit --allow-empty-message -m ""
    fi && \
    git update-ref -d ${RED_REF}
}

# finds a previous commit tagged Red, returns true if same as current work
function lastCommitRed(){
    [[ `git describe --all ${RED_REF} 2>/dev/null` && -z `git diff ${RED_REF} HEAD 2>/dev/null` ]]
}

# revert to the last version that was committed
function revert() {
    git reset --hard
    git clean -f
}

# pull branch if there's a remote change
# rebase so that our commit will come *after* remote changes
function pull(){
    if needsPull; then
        git pull --rebase
    fi
}

# detect remote changes (not actually fetching them)
function needsPull(){
    [[ ! -z `git fetch --dry-run 2>&1` ]]
}

# if push required, launch tests then push
function push() {
    if needsPush; then
        runTest && git push
    fi
}

# detect local changes wrt remote
function needsPush(){
    [[ ! -z `git diff ${BRANCH} HEAD` ]]
}

# main
ASSUMING_GREEN=false
ASSUMING_RED=false

while [[ $# -gt 0 ]]
do
    key="$1"

    case ${key} in
        -g|--green)
            ASSUMING_GREEN=true
            shift
            ;;
        -r|--red)
            ASSUMING_RED=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

if ${ASSUMING_RED} || (! ${ASSUMING_GREEN} && testJustAdded)
then
    echo red
    runTest && revert || commitOnRed
    pull
else
    echo green
    runTest && commitOnGreen || revert
    pull && push
fi

