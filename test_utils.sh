#!/usr/bin/env bash
runInto() {
    currentDirectory=`pwd`
    cd $1
    shift
    "$@"
    cd $currentDirectory
}

runAsAlice() {
    runInto ${aliceClone} "$@"
}

runAsBob() {
    runInto ${bobClone} "$@"
}

createRepositories() {
    git init --bare ${bareRepository}
    git clone ${bareRepository} ${aliceClone}
    git clone ${bareRepository} ${bobClone}
    runAsAlice git config user.name Alice
    runAsAlice git config user.email alice@tcr.com
    runAsBob git config user.name Bob
    runAsBob git config user.email bob@tcr.com
}

deleteRepositories() {
    rm -rf ${bareRepository} ${aliceClone} ${bobClone}
}

