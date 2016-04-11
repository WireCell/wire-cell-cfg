#!/bin/bash

set -e
set -x

testdir=$(dirname $(readlink -f $BASH_SOURCE))

for what in trackdepos drifter
do
    $testdir/test_${what}.sh
done
