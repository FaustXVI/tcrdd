#! /usr/bin/env bash
. ./test_utils.sh

test_print_usage_when_asked() {
    headHash=$(runAsAlice getHeadHash)
    echo content > ${aliceClone}/aFile
    startStatus=$(runAsAlice git status -s)
    runAsAlice ./tcrdd.sh -h true > $stdout
    status=$(runAsAlice git status -s)
    currentHash=$(runAsAlice getHeadHash)
    stdoutContent=$(cat $stdout)
    assertEquals 'Alice s code should not be commited' "$headHash" "$currentHash"
    assertEquals "Nothing should have changed for git" "$startStatus" "$status"
    assertContains "Usage should be displayed" "$stdoutContent" "Usage :"
}

test_print_usage_when_no_test_command_given() {
    headHash=$(runAsAlice getHeadHash)
    echo content > ${aliceClone}/aFile
    startStatus=$(runAsAlice git status -s)
    runAsAlice ./tcrdd.sh > $stdout
    status=$(runAsAlice git status -s)
    currentHash=$(runAsAlice getHeadHash)
    stdoutContent=$(cat $stdout)
    assertEquals 'Alice s code should not be commited' "$headHash" "$currentHash"
    assertEquals "Nothing should have changed for git" "$startStatus" "$status"
    assertContains "Usage should be displayed" "$stdoutContent" "Usage :"
}

test_print_usage_when_no_test_keyword_present() {
    unset TEST_KEYWORD
    headHash=$(runAsAlice getHeadHash)
    echo content > ${aliceClone}/aFile
    startStatus=$(runAsAlice git status -s)
    runAsAlice ./tcrdd.sh true > $stdout
    status=$(runAsAlice git status -s)
    currentHash=$(runAsAlice getHeadHash)
    stdoutContent=$(cat $stdout)
    assertEquals 'Alice s code should not be commited' "$headHash" "$currentHash"
    assertEquals "Nothing should have changed for git" "$startStatus" "$status"
    assertContains "Usage should be displayed" "$stdoutContent" "Usage :"
}

test_commits_push_when_tests_are_ok() {
    headHash=$(runAsAlice getHeadHash)
    echo content > ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh -g true > /dev/null 2>&1
    status=$(runAsAlice git status -s)
    message=$(runAsAlice getHeadMessage)
    currentHash=$(runAsAlice getHeadHash)
    originHash=$(runAsAlice getOriginHeadHash)
    assertNotEquals 'Alice s code is not commited' "$headHash" "$currentHash"
    assertNull 'Not everything is committed by alice' "$status"
    assertNull 'Alice commit message should be empty' "$message"
    assertTrue 'Created file should still be there' '[ -f ${aliceClone}/aFile ]'
    assertEquals 'Alice s should be pushed' "$originHash" "$currentHash"
}

test_reverts_on_green_when_assumed_red() {
    headHash=$(runAsAlice getHeadHash)
    echo content > ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh -r true > /dev/null 2>&1
    status=$(runAsAlice git status -s)
    currentHash=$(runAsAlice getHeadHash)
    assertNull 'Alice s code is not reverted' "$status"
    assertEquals 'Alice head should be the same as before' "$headHash" "$currentHash"
    assertFalse 'Created file should be removed' '[ -f ${aliceClone}/aFile ]'
}

test_reverts_when_test_are_ko() {
    headHash=$(runAsAlice getHeadHash)
    echo content > ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh -g false > /dev/null 2>&1
    status=$(runAsAlice git status -s)
    currentHash=$(runAsAlice getHeadHash)
    assertNull 'Alice s code is not reverted' "$status"
    assertEquals 'Alice head should be the same as before' "$headHash" "$currentHash"
    assertFalse 'Created file should be removed' '[ -f ${aliceClone}/aFile ]'
}

test_reverts_removes_new_files_when_test_are_ko() {
    headHash=$(runAsAlice getHeadHash)
    echo content > ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh -g false > /dev/null 2>&1
    status=$(runAsAlice git status -s)
    currentHash=$(runAsAlice getHeadHash)
    assertNull 'Alice s code is not reverted' "$status"
    assertEquals 'Alice head should be the same as before' "$headHash" "$currentHash"
    assertFalse 'Created file should be removed' '[ -f ${aliceClone}/aFile ]'
}

test_reverts_restores_files_when_test_are_ko() {
    headHash=$(runAsAlice getHeadHash)
    echo content > ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh -g true > /dev/null 2>&1
    echo otherContent >> ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh -g false > /dev/null 2>&1
    status=$(runAsAlice git status -s)
    content=$(runAsAlice cat aFile)
    currentHash=$(runAsAlice getHeadHash)
    assertNull 'Alice s code should be reverted' "$status"
    assertEquals 'File content should be reverted' "content" "$content"
}

test_commits_no_push_on_red_when_assumed_red() {
    headHash=$(runAsAlice getHeadHash)
    echo content > ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh -r false > /dev/null 2>&1
    status=$(runAsAlice git status -s)
    message=$(runAsAlice getHeadMessage)
    currentHash=$(runAsAlice getHeadHash)
    originHash=$(runAsAlice getOriginHeadHash)
    assertNotEquals 'Alice s code is not commited' "$headHash" "$currentHash"
    assertNull 'Not everything is committed by alice' "$status"
    assertNull 'Alice commit message should be empty' "$message"
    assertTrue 'Created file should still be there' '[ -f ${aliceClone}/aFile ]'
    assertNotEquals 'Alice s should not be pushed' "$originHash" "$currentHash"
}

test_auto_detects_red_step_with_new_test_file() {
    headHash=$(runAsAlice getHeadHash)
    echo "${TEST_KEYWORD} content" > ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh false > /dev/null 2>&1
    currentHash=$(runAsAlice getHeadHash)
    assertNotEquals 'Alice s code should be commited' "$headHash" "$currentHash"
}

test_auto_detects_green_step_when_no_new_test() {
    headHash=$(runAsAlice getHeadHash)
    echo content > ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh true > /dev/null 2>&1
    currentHash=$(runAsAlice getHeadHash)
    assertNotEquals 'Alice s code should be commited' "$headHash" "$currentHash"
}

test_amend_commit_with_two_red_steps() {
    headHash=$(runAsAlice getHeadHash)
    echo content > ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh -r false > /dev/null 2>&1
    echo otherContent >> ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh -r false > /dev/null 2>&1
    status=$(runAsAlice git status -s)
    nbCommits=$(runAsAlice git rev-list --count ${headHash}..HEAD)
    currentHash=$(runAsAlice getHeadHash)
    originHash=$(runAsAlice getOriginHeadHash)
    assertNull 'Everything should be committed by alice' "$status"
    assertNotEquals 'Alice s should not be pushed' "$originHash" "$currentHash" 
    assertEquals 'Only one commit should exist' 1 "${nbCommits}"
}

test_amend_commit_with_one_red_step_then_one_green_step() {
    headHash=$(runAsAlice getHeadHash)
    echo content > ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh -r false > /dev/null 2>&1
    echo otherContent >> ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh -g true > /dev/null 2>&1
    status=$(runAsAlice git status -s)
    nbCommits=$(runAsAlice git rev-list --count ${headHash}..HEAD)
    currentHash=$(runAsAlice getHeadHash)
    originHash=$(runAsAlice getOriginHeadHash)
    assertNull 'Everything should be committed by alice' "$status"
    assertEquals 'Alice s should be pushed' "$originHash" "$currentHash" 
    assertEquals 'Only one commit should exist' 1 "${nbCommits}"
}

test_amend_commit_with_message() {
    echo content > ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh -r false > /dev/null 2>&1
    echo otherContent >> ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh -g -m "Commit message" true > /dev/null 2>&1
    message=$(runAsAlice getHeadMessage)
    assertEquals 'Alice commit message should not be empty' "$message" "Commit message"
}

test_commits_with_message_on_green() {
    echo content > ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh -g -m "Commit message" true > /dev/null 2>&1
    message=$(runAsAlice getHeadMessage)
    assertEquals 'Alice commit message should not be empty' "$message" "Commit message"
}

test_commits_with_message_on_red() {
    echo content > ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh -r -m "Commit message" false > /dev/null 2>&1
    message=$(runAsAlice getHeadMessage)
    assertEquals 'Alice commit message should not be empty' "$message" "Commit message"
}

# TODO : test pull functionality

oneTimeSetUp() {
    export HOME="${SHUNIT_TMPDIR}"
    workingDirectory=`pwd`
    bareRepository="${SHUNIT_TMPDIR}/repository"
    aliceClone="${SHUNIT_TMPDIR}/alice"
    bobClone="${SHUNIT_TMPDIR}/bob"
    stdout="${SHUNIT_TMPDIR}/stdout"
}

setUp() {
    export TEST_KEYWORD="testKeyWord"
    createRepositories > /dev/null 2>&1
}

tearDown() {
    deleteRepositories > /dev/null 2>&1
    rm -f $stdout
}

. ./shunit2/shunit2
