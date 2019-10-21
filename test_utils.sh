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
    runAsAlice git config user.name Alice
    runAsAlice git config user.email alice@tcr.com
    runAsAlice git commit --allow-empty -m "Initial commit" > /dev/null
    cp ./tcrdd.sh ${aliceClone}/tcrdd.sh
    runAsAlice git add tcrdd.sh
    runAsAlice git commit -m "Add tcrdd script" > /dev/null
    runAsAlice git push > /dev/null 2>&1
    
    git clone ${bareRepository} ${bobClone}
    runAsBob git config user.name Bob
    runAsBob git config user.email bob@tcr.com
}

deleteRepositories() {
    rm -rf ${bareRepository} ${aliceClone} ${bobClone}
}

getHeadHash() {
    git log HEAD -1 --pretty=%H
}

getHeadMessage() {
    git log HEAD -1 --pretty=%B
}

getOriginHeadHash() {
    git log origin/master -1 --pretty=%H
}
