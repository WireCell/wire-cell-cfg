#!/bin/bash

set -e
set -x

testdir=$(dirname $(readlink -f $BASH_SOURCE))
what="$1"

jpath="$testdir/.."
input="$testdir/test_${what}.jsonnet"
cfg="$testdir/test_${what}.cfg"

jsonnet -J $jpath $input > $cfg

wire-cell -c $cfg

