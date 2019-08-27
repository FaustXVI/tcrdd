#! /usr/bin/env bash
. ./test_utils.sh

test_commits_when_tests_are_ok() {
    headHash=$(runAsAlice git log -1 --pretty=%H)
    echo content > ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh true > /dev/null 2>&1
    status=$(runAsAlice git status -s)
    message=$(runAsAlice git log -1 --pretty=%B)
    currentHash=$(runAsAlice git log -1 --pretty=%H)
    assertFalse 'Alice s code is not commited' '[ "$headHash" = "$currentHash" ]'
    assertTrue 'Not everything is committed by alice' '[ -z "$status" ]'
    assertTrue 'Alice commit message should be empty' '[ -z "$message" ]'
    assertTrue 'Created file should still be there' '[ -f ${aliceClone}/aFile ]'
}

test_reverts_when_test_are_ko() {
    headHash=$(runAsAlice git log -1 --pretty=%H)
    echo content > ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh false > /dev/null 2>&1
    status=$(runAsAlice git status -s)
    currentHash=$(runAsAlice git log -1 --pretty=%H)
    assertTrue 'Alice s code is not reverted' '[ -z "$status" ]'
    assertTrue 'Alice head should be the same as before' '[ "$headHash" = "$currentHash" ]'
    assertFalse 'Created file should be removed' '[ -f ${aliceClone}/aFile ]'
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
