#! /usr/bin/env bash
. ./test_utils.sh

should_print_usage_when_given() {
    arguments=$@
    headHash=$(runAsAlice getHeadHash)
    echo content > ${aliceClone}/aFile
    startStatus=$(runAsAlice git status -s)
    runAsAlice ./tcrdd.sh ${arguments} > $stdout
    status=$(runAsAlice git status -s)
    currentHash=$(runAsAlice getHeadHash)
    stdoutContent=$(cat $stdout)
    assertEquals 'Alice s code should not be commited' "$headHash" "$currentHash"
    assertEquals "Nothing should have changed for git" "$startStatus" "$status"
    assertContains "Usage should be displayed" "$stdoutContent" "Usage :"
}

test_print_usage_when_given_short_option() {
    and_any_command=true
    should_print_usage_when_given -h $and_any_command
}

test_print_usage_when_given_long_option() {
    and_any_command=true
    should_print_usage_when_given --help $and_any_command
}

test_print_usage_when_given_no_test_command() {
    no_test_command=
    should_print_usage_when_given $no_test_command
}


should_commit_and_push_when_given() {
    arguments=$@
    headHash=$(runAsAlice getHeadHash)
    echo content > ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh ${arguments} > /dev/null 2>&1
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

test_commit_and_push_when_assumed_green_and_tests_pass__short_option() {
    should_commit_and_push_when_given -g $and_tests_pass
}

test_commit_and_push_when_assumed_green_and_tests_pass__long_option() {
    should_commit_and_push_when_given --green $and_tests_pass
}


should_revert_when_given() {
    arguments=$@
    headHash=$(runAsAlice getHeadHash)
    echo content > ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh ${arguments} > /dev/null 2>&1
    status=$(runAsAlice git status -s)
    currentHash=$(runAsAlice getHeadHash)
    assertNull 'Alice s code is not reverted' "$status"
    assertEquals 'Alice head should be the same as before' "$headHash" "$currentHash"
    assertFalse 'Created file should be removed' '[ -f ${aliceClone}/aFile ]'
}

test_revert_when_assumed_red_and_tests_pass__short_option() {
    should_revert_when_given -r $and_tests_pass
}

test_revert_when_assumed_red_and_tests_pass__long_option() {
    should_revert_when_given --red $and_tests_pass
}

test_revert_when_assumed_green_and_tests_fail__short_option() {
    should_revert_when_given -g $and_tests_fail
}

test_revert_when_assumed_green_and_tests_fail__long_option() {
    should_revert_when_given --green $and_tests_fail
}


should_remove_untracked_files_when_given() {
    arguments=$@
    headHash=$(runAsAlice getHeadHash)
    echo content > ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh $arguments > /dev/null 2>&1
    status=$(runAsAlice git status -s)
    currentHash=$(runAsAlice getHeadHash)
    assertNull 'Alice s code is not reverted' "$status"
    assertEquals 'Alice head should be the same as before' "$headHash" "$currentHash"
    assertFalse 'Created file should be removed' '[ -f ${aliceClone}/aFile ]'
}

test_remove_untracked_files_when_assumed_green_and_tests_fail__short_option() {
    should_remove_untracked_files_when_given -g $and_tests_fail
}

test_remove_untracked_files_when_assumed_green_and_tests_fail__long_option() {
    should_remove_untracked_files_when_given --green $and_tests_fail
}


should_restore_files_when_given() {
    arguments=$@
    headHash=$(runAsAlice getHeadHash)
    echo content > ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh --green true > /dev/null 2>&1
    echo otherContent >> ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh ${arguments} > /dev/null 2>&1
    status=$(runAsAlice git status -s)
    content=$(runAsAlice cat aFile)
    currentHash=$(runAsAlice getHeadHash)
    assertNull 'Alice s code should be reverted' "$status"
    assertEquals 'File content should be reverted' "content" "$content"
}

test_restore_files_when_assumed_green_and_tests_fail__short_option() {
    should_restore_files_when_given -g $and_tests_fail
}

test_restore_files_when_assumed_green_and_tests_fail__long_option() {
    should_restore_files_when_given --green $and_tests_fail
}


should_not_push_when_given() {
    arguments=$@
    headHash=$(runAsAlice getHeadHash)
    echo content > ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh ${arguments} > /dev/null 2>&1
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

test_does_not_push_when_assumed_red_and_tests_fail__short_option() {
    should_not_push_when_given -r $and_tests_fail
}

test_does_not_push_when_assumed_red_and_tests_fail__long_option() {
    should_not_push_when_given --red $and_tests_fail
}


should_amend_commit_and_not_push_when_given() {
    arguments=$@
    headHash=$(runAsAlice getHeadHash)
    echo content > ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh --red false > /dev/null 2>&1
    echo otherContent >> ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh ${arguments} > /dev/null 2>&1
    status=$(runAsAlice git status -s)
    nbCommits=$(runAsAlice git rev-list --count ${headHash}..HEAD)
    currentHash=$(runAsAlice getHeadHash)
    originHash=$(runAsAlice getOriginHeadHash)
    assertNull 'Everything should be committed by alice' "$status"
    assertNotEquals 'Alice s should not be pushed' "$originHash" "$currentHash" 
    assertEquals 'Only one commit should exist' 1 "${nbCommits}"
}

test_amend_last_red_commit_when_assumed_red_and_tests_fail__short_option() {
    should_amend_commit_and_not_push_when_given -r $and_tests_fail
}

test_amend_last_red_commit_when_assumed_red_and_tests_fail__long_option() {
    should_amend_commit_and_not_push_when_given --red $and_tests_fail
}


should_amend_commit_and_push_when_given() {
    arguments=$@
    headHash=$(runAsAlice getHeadHash)
    echo content > ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh --red false > /dev/null 2>&1
    echo otherContent >> ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh ${arguments} > /dev/null 2>&1
    status=$(runAsAlice git status -s)
    nbCommits=$(runAsAlice git rev-list --count ${headHash}..HEAD)
    currentHash=$(runAsAlice getHeadHash)
    originHash=$(runAsAlice getOriginHeadHash)
    assertNull 'Everything should be committed by alice' "$status"
    assertEquals 'Alice s should be pushed' "$originHash" "$currentHash"
    assertEquals 'Only one commit should exist' 1 "${nbCommits}"
}

test_amend_last_red_commit_and_push_when_assumed_green_and_tests_pass__short_option() {
    should_amend_commit_and_push_when_given -g $and_tests_pass
}

test_amend_last_red_commit_and_push_when_assumed_green_and_tests_pass__long_option() {
    should_amend_commit_and_push_when_given --green $and_tests_pass
}


should_amend_commit_with_message_when_given() {
    headHash=$(runAsAlice getHeadHash)
    echo content > ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh --red false > /dev/null 2>&1
    echo otherContent >> ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh $1 $2 "$3" $4 > /dev/null 2>&1
    nbCommits=$(runAsAlice git rev-list --count ${headHash}..HEAD)
    message=$(runAsAlice getHeadMessage)
    assertEquals 'Alice commit message should not be empty' "$message" "Commit message"
    assertEquals 'Only one commit should exist' 1 "${nbCommits}"
}

test_amend_commit_with_message_when_assumed_green_and_tests_pass__short_option() {
    should_amend_commit_with_message_when_given -g -m "Commit message" $and_tests_pass
}

test_amend_commit_with_message_when_assumed_green_and_tests_pass__long_option() {
    should_amend_commit_with_message_when_given --green --message "Commit message" $and_tests_pass
}


should_commit_with_message_when_given() {
    echo content > ${aliceClone}/aFile
    runAsAlice ./tcrdd.sh $1 $2 "$3" $4 > /dev/null 2>&1
    message=$(runAsAlice getHeadMessage)
    assertEquals 'Alice commit message should not be empty' "$message" "Commit message"
}

test_commit_with_message_when_assumed_green_and_tests_pass__short_option() {
    should_commit_with_message_when_given -g -m "Commit message" $and_tests_pass
}

test_commit_with_message_when_assumed_green_and_tests_pass__long_option() {
    should_commit_with_message_when_given --green --message "Commit message" $and_tests_pass
}

test_commit_with_message_when_assumed_red_and_tests_fail__short_option() {
    should_commit_with_message_when_given -r -m "Commit message" $and_tests_fail
}

test_commit_with_message_when_assumed_red_and_tests_fail__long_option() {
    should_commit_with_message_when_given --red --message "Commit message" $and_tests_fail
}


should_pull_when_given() {
    arguments=$@
    headHash=$(runAsAlice getHeadHash)
    
    echo content > ${bobClone}/aFile
    runAsBob git add . > /dev/null 2>&1
    runAsBob git commit -m "bob commit" > /dev/null 2>&1
    runAsBob git push > /dev/null 2>&1
    bobHash=$(runAsBob getHeadHash)

    echo otherContent >> ${aliceClone}/otherFile
    runAsAlice ./tcrdd.sh ${arguments} > /dev/null 2>&1
    searchBobCommit=$(runAsAlice git log --pretty=%H | grep ${bobHash})
    assertNotNull 'Bob s code should be found' "${searchBobCommit}"
    commitsSinceBob=$(runAsAlice git rev-list --count ${bobHash}..HEAD)
    currentHash=$(runAsAlice getHeadHash)
    originHash=$(runAsAlice getOriginHeadHash)
    assertEquals 'Bob s code should be pulled' 1 "${commitsSinceBob}"
}

test_pull_code_when_assumed_green_and_tests_pass__short_option() {
    should_pull_when_given -g $and_tests_pass
}

test_pull_code_when_assumed_green_and_tests_pass__long_option() {
    should_pull_when_given --green $and_tests_pass
}

test_pull_code_when_assumed_red_and_tests_fail__short_option() {
    should_pull_when_given -r $and_tests_fail
}

test_pull_code_when_assumed_red_and_tests_fail__long_option() {
    should_pull_when_given --red $and_tests_fail
}


oneTimeSetUp() {
    export HOME="${SHUNIT_TMPDIR}"
    workingDirectory=`pwd`
    bareRepository="${SHUNIT_TMPDIR}/repository"
    aliceClone="${SHUNIT_TMPDIR}/alice"
    bobClone="${SHUNIT_TMPDIR}/bob"
    stdout="${SHUNIT_TMPDIR}/stdout"
}

setUp() {
    createRepositories > /dev/null 2>&1
}

tearDown() {
    deleteRepositories > /dev/null 2>&1
    rm -f $stdout
}

. ./shunit2/shunit2
