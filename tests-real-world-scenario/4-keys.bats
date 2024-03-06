#!/usr/bin/env bats

load _common/helpers

function setup() {

    TESTFILES=setup.d
}

@test "Bob sends a secret (random) 150GB file to Alice, using his ssh-key" {

    rm -f $TESTFILES/bob.sshkey{,.pub}

    # Bob creates an ssh-key (OpenSSH 6.5+)
    run ssh-keygen -t ed25519 -f $TESTFILES/bob.sshkey -N "${BOB_PASSPHRASE}"
    # Yeah, same passphrase, not very good, but good enough
    [ "$status" -eq 0 ]

    # Bob encrypts it for Alice
    export C4GH_PASSPHRASE=${BOB_PASSPHRASE}
    crypt4gh encrypt --sk $TESTFILES/bob.sshkey --recipient_pk ${ALICE_PUBKEY} < $TESTFILES/random.150GB > $TESTFILES/random.150GB.c4gh

    # Alice decrypts it
    export C4GH_PASSPHRASE=${ALICE_PASSPHRASE}
    crypt4gh decrypt --sk ${ALICE_SECKEY} < $TESTFILES/random.150GB.c4gh > $TESTFILES/random.150GB.received

    run diff $TESTFILES/random.150GB $TESTFILES/random.150GB.received
    [ "$status" -eq 0 ]

    unset C4GH_PASSPHRASE
}

@test "Bob sends a secret (random) 150GB file to Alice, using Alice's ssh-key" {

    rm -f $TESTFILES/alice.sshkey{,.pub}

    # Bob creates an ssh-key (OpenSSH 6.5+)
    run ssh-keygen -t ed25519 -f $TESTFILES/alice.sshkey -N "${ALICE_PASSPHRASE}"
    # Yeah, same passphrase, not very good, but good enough
    [ "$status" -eq 0 ]

    # Bob encrypts it for Alice
    export C4GH_PASSPHRASE=${BOB_PASSPHRASE}
    crypt4gh encrypt --sk ${BOB_SECKEY} --recipient_pk $TESTFILES/alice.sshkey.pub < $TESTFILES/random.150GB > $TESTFILES/random.150GB.c4gh

    # Alice decrypts it
    export C4GH_PASSPHRASE=${ALICE_PASSPHRASE}
    crypt4gh decrypt --sk $TESTFILES/alice.sshkey < $TESTFILES/random.150GB.c4gh > $TESTFILES/random.150GB.received

    run diff $TESTFILES/random.150GB $TESTFILES/random.150GB.received
    [ "$status" -eq 0 ]

    unset C4GH_PASSPHRASE
}

@test "Bob sends a secret (random) 150GB file to Alice, both using their ssh-keys" {

    # Clean up
    rm -f $TESTFILES/{bob,alice}.sshkey{,.pub}

    # Bob and Alice creates an ssh-key (OpenSSH 6.5+)
    run ssh-keygen -t ed25519 -f $TESTFILES/bob.sshkey -N "${BOB_PASSPHRASE}"
    [ "$status" -eq 0 ]
    run ssh-keygen -t ed25519 -f $TESTFILES/alice.sshkey -N "${ALICE_PASSPHRASE}"
    # Yeah, same passphrase, not very good, but good enough
    [ "$status" -eq 0 ]

    # Bob encrypts it for Alice
    export C4GH_PASSPHRASE=${BOB_PASSPHRASE}
    crypt4gh encrypt --sk $TESTFILES/bob.sshkey --recipient_pk $TESTFILES/alice.sshkey.pub < $TESTFILES/random.150GB > $TESTFILES/random.150GB.c4gh

    # Alice decrypts it
    export C4GH_PASSPHRASE=${ALICE_PASSPHRASE}
    crypt4gh decrypt --sk $TESTFILES/alice.sshkey < $TESTFILES/random.150GB.c4gh > $TESTFILES/random.150GB.received

    run diff $TESTFILES/random.150GB $TESTFILES/random.150GB.received
    [ "$status" -eq 0 ]

    unset C4GH_PASSPHRASE
}
