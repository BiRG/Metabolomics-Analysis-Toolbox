#!/bin/sh
if [ ! -d cover_db ]; then
    mkdir cover_db;
fi
if [ ! -d cover_db ]; then
    echo "Could not create cover_db directory.  Aborting."
    exit -1;
fi
export HARNESS_PERL_SWITCHES=-MDevel::Cover
prove
cover

