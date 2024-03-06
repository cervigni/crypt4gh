#!/usr/bin/env bats

load _common/helpers

function setup() {
    # Defining the TMP dir
    TESTFILES=setup.d
}

@test "Cleanup of all temporary files" {
    rm -rf ${TESTFILES}
}
