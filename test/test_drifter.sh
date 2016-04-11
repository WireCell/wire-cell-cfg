#!/bin/bash

set -e
set -x
testdir=$(dirname $(readlink -f $BASH_SOURCE))

jpath="$testdir/.."
input="$testdir/test_drifter.jsonnet"
cfg="$testdir/test_drifter.cfg"

jsonnet -J $jpath $input > $cfg

wire-cell -p WireCellGen -p WireCellTbb -c $cfg -a TbbFlow
