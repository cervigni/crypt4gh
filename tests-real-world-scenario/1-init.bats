#!/usr/bin/env bats

load _common/helpers

function setup() {

    # Defining the TMP dir
    TESTFILES=setup.d
    mkdir -p "$TESTFILES"

}

@test "Initialise 150GB random file for tests" {

    # Generate a random 150 GB file, and keep it
    if ! test -f $TESTFILES/random.150GB
    then
      run dd if=/dev/urandom bs=1M count=153600 of=$TESTFILES/random.150GB
      [ "$status" -eq 0 ]
    fi
}
