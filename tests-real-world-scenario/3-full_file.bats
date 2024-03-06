#!/usr/bin/env bats

load _common/helpers

function setup() {

    TESTFILES=setup.d 
}

@test "Bob sends a secret (random) 150GB file to Alice" {

    # Bob encrypts it for Alice
    export C4GH_PASSPHRASE=${BOB_PASSPHRASE}
    crypt4gh encrypt --sk ${BOB_SECKEY} --recipient_pk ${ALICE_PUBKEY} < $TESTFILES/random.150GB > $TESTFILES/random.150GB.c4gh

    # Alice decrypts it
    export C4GH_PASSPHRASE=${ALICE_PASSPHRASE}
    crypt4gh decrypt --sk ${ALICE_SECKEY} < $TESTFILES/random.150GB.c4gh > $TESTFILES/random.150GB.received

    run diff $TESTFILES/random.150GB $TESTFILES/random.150GB.received
    [ "$status" -eq 0 ]

    unset C4GH_PASSPHRASE
}

@test "Bob sends the testfile secretly to Alice" {

    TESTFILE=${BATS_TEST_DIRNAME}/_common/testfile.abcd

    # Bob encrypts the testfile for Alice
    export C4GH_PASSPHRASE=${BOB_PASSPHRASE}
    crypt4gh encrypt --sk ${BOB_SECKEY} --recipient_pk ${ALICE_PUBKEY} < $TESTFILE > $TESTFILES/message.c4gh

    # Alice decrypts it
    export C4GH_PASSPHRASE=${ALICE_PASSPHRASE}
    crypt4gh decrypt --sk ${ALICE_SECKEY} < $TESTFILES/message.c4gh > $TESTFILES/message.received

    run diff $TESTFILE $TESTFILES/message.received
    [ "$status" -eq 0 ]

    unset C4GH_PASSPHRASE
}

@test "Bob encrypts the testfile for himself and reencrypts it for Alice" {

    TESTFILE=${BATS_TEST_DIRNAME}/_common/testfile.abcd

    # Bob encrypts the testfile for himself
    export C4GH_PASSPHRASE=${BOB_PASSPHRASE}
    crypt4gh encrypt --sk ${BOB_SECKEY} --recipient_pk ${BOB_PUBKEY} < $TESTFILE > $TESTFILES/message.bob.c4gh

    # Bob changes the header for Alice
    crypt4gh reencrypt --sk ${BOB_SECKEY} --recipient_pk ${ALICE_PUBKEY} < $TESTFILES/message.bob.c4gh > $TESTFILES/message.c4gh

    # Alice decrypts it
    export C4GH_PASSPHRASE=${ALICE_PASSPHRASE}
    crypt4gh decrypt --sk ${ALICE_SECKEY} < $TESTFILES/message.c4gh > $TESTFILES/message.received

    run diff $TESTFILE $TESTFILES/message.received
    [ "$status" -eq 0 ]

    unset C4GH_PASSPHRASE
}

@test "Bob sends a secret (random) 150GB file to Alice, without his key" {

    # Bob encrypts it for Alice, without a key
    crypt4gh encrypt --recipient_pk ${ALICE_PUBKEY} < $TESTFILES/random.150GB > $TESTFILES/random.150GB.c4gh

    # Alice decrypts it
    export C4GH_PASSPHRASE=${ALICE_PASSPHRASE}
    crypt4gh decrypt --sk ${ALICE_SECKEY} < $TESTFILES/random.150GB.c4gh > $TESTFILES/random.150GB.received

    run diff $TESTFILES/random.150GB $TESTFILES/random.150GB.received
    [ "$status" -eq 0 ]

    unset C4GH_PASSPHRASE
}
