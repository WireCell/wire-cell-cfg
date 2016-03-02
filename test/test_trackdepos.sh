#!/bin/bash

set -e
set -x
testdir=$(dirname $(readlink -f $BASH_SOURCE))

jpath="$testdir/.."
input="$testdir/test_trackdepos.jsonnet"
cfg="$testdir/test_trackdepos.cfg"

jsonnet -J $jpath $input > $cfg

wire-cell -p WireCellGen -c $cfg
