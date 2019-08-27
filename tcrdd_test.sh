#! /usr/bin/env bash

testAliceRepositoryIsInitialised() {
    assertTrue 'Alice is not initialised' "[ -d ${aliceClone}/.git ]"
}

runInto() {
    currentDirectory=`pwd`
    cd $1
    shift
    "$@"
    cd $currentDirectory
}

createFirstCommit() {
    git init --bare ${bareRepository}
    git clone ${bareRepository} ${aliceClone}
    runInto ${aliceClone}\
        git commit --allow-empty -m "Initial commit"
}

oneTimeSetUp() {
    workingDirectory=`pwd`
    tcrdd="${workingDirectory}/tcrdd.sh"
    bareRepository="${SHUNIT_TMPDIR}/repository"
    aliceClone="${SHUNIT_TMPDIR}/alice"
    createFirstCommit > /dev/null 2>&1
}

. ./shunit2/shunit2
