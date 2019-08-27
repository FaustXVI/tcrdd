#! /usr/bin/env bash
. ./test_utils.sh

test_commits_when_tests_are_ok() {
    echo content > ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh true > /dev/null 2>&1
    status=$(runAsAlice git status -s)
    assertTrue 'Alice s code is not commited' '[ -z "$status" ]'
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
}

tearDown() {
    deleteRepositories > /dev/null 2>&1
}

. ./shunit2/shunit2
