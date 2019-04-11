#!/bin/bash

mydir=$(dirname $BASH_SOURCE)
cfgdir=$(dirname $mydir)

for main in $(find $cfgdir/pgrapher -name '*wct-*.jsonnet') ; do
    echo $main
    jsonnet -J $cfgdir $main > /dev/null
done
