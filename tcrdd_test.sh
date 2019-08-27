#! /usr/bin/env bash
. ./test_utils.sh

testAliceRepositoryIsInitialised() {
    assertTrue 'Alice is not initialised' "[ -d ${aliceClone}/.git ]"
}

oneTimeSetUp() {
    workingDirectory=`pwd`
    export HOME="${SHUNIT_TMPDIR}"
    tcrdd="${workingDirectory}/tcrdd.sh"
    bareRepository="${SHUNIT_TMPDIR}/repository"
    aliceClone="${SHUNIT_TMPDIR}/alice"
    bobClone="${SHUNIT_TMPDIR}/bob"
}

setUp() {
    createRepositories > /dev/null 2>&1
    runAsAlice git commit --allow-empty -m "Initial commit" > /dev/null
}

tearDown() {
    deleteRepositories > /dev/null 2>&1
}

. ./shunit2/shunit2
