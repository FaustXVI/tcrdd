#! /usr/bin/env bash
. ./test_utils.sh

test_print_usage_when_no_test_command_given() {
    headHash=$(runAsAlice getHeadHash)
    echo content > ${aliceClone}/aFile
    startStatus=$(runAsAlice git status -s)
    runAsAlice ./tcrdd.sh > /dev/null 2>&1
    status=$(runAsAlice git status -s)
    currentHash=$(runAsAlice getHeadHash)
    assertTrue 'Alice s code is not commited' '[ "$headHash" = "$currentHash" ]'
    assertTrue "Nothing should have changed for git, was \"$status\" expected \"$startStatus\"" '[ "$startStatus" = "$status" ]'
}

test_commits_when_tests_are_ok() {
    headHash=$(runAsAlice getHeadHash)
    echo content > ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh true > /dev/null 2>&1
    status=$(runAsAlice git status -s)
    message=$(runAsAlice getHeadMessage)
    currentHash=$(runAsAlice getHeadHash)
    assertFalse 'Alice s code is not commited' '[ "$headHash" = "$currentHash" ]'
    assertTrue 'Not everything is committed by alice' '[ -z "$status" ]'
    assertTrue 'Alice commit message should be empty' '[ -z "$message" ]'
    assertTrue 'Created file should still be there' '[ -f ${aliceClone}/aFile ]'
}

test_reverts_when_test_are_ko() {
    headHash=$(runAsAlice getHeadHash)
    echo content > ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh false > /dev/null 2>&1
    status=$(runAsAlice git status -s)
    currentHash=$(runAsAlice getHeadHash)
    assertTrue 'Alice s code is not reverted' '[ -z "$status" ]'
    assertTrue 'Alice head should be the same as before' '[ "$headHash" = "$currentHash" ]'
    assertFalse 'Created file should be removed' '[ -f ${aliceClone}/aFile ]'
}

oneTimeSetUp() {
    export HOME="${SHUNIT_TMPDIR}"
    export TEST_KEYWORD="testKeyWord"
    workingDirectory=`pwd`
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
